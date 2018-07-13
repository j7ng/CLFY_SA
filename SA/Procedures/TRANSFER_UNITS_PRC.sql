CREATE OR REPLACE PROCEDURE sa."TRANSFER_UNITS_PRC" (
   p_esn             IN       VARCHAR2,
   p_cru             IN       NUMBER,
   p_ttv_units       IN       NUMBER,
   p_grant_units     OUT      NUMBER,
   p_err_num         OUT      NUMBER,
   p_err_msg         OUT      VARCHAR2,
   p_custred_units   OUT      NUMBER
)
IS
/******************************************************************************
   /* Copyright (r) 2005 Tracfone Wireless Inc. All rights reserved
   /*
   /* Name         :   transfer_units_prc
   /* Purpose      :   return units to be granted to the customer during transfer
   /* Parameters   :
   /* Platforms    :   Oracle 8.0.6 AND newer versions
   /* Author       :   Vani Adapa
   /* Date         :   12/02/20025
   /* Revisions    :
   /*
   /* Version  Date         Who              Purpose
   /* -------  --------    -------          --------------------------------------
   /* 1.0      12/02/2005   VAdapa            Initial revision
   /* 1.1     12/12/2005   VAdapa           Modified to look for ">" instead of ">="
   /* 1.2     12/12/2005   NGuada           Modified to include trans type 2 and 5
   /* 1.3     12/12/2005   VAdapa         Modified to compare with timestamp
   /* 1.4     12/15/2005   VAdapa         Revert the 1.1 revision change and added tt exlcusion logic
   /* 1.5     12/30/2005   VAdapa		  Added new output paramter - customer redeemed units
   /******************************************************************************/
   CURSOR c_orig_act_date
   IS
      SELECT (DECODE (refurb_yes.is_refurb,
                      0, nonrefurb_act_date.init_act_date,
                      refurb_act_date.init_act_date
                     )
             ) orig_act_date
        FROM (SELECT COUNT (1) is_refurb
                FROM table_site_part sp_a
               WHERE sp_a.x_service_id = p_esn AND sp_a.x_refurb_flag = 1) refurb_yes,
             (SELECT MIN (install_date) init_act_date
                FROM table_site_part sp_b
               WHERE sp_b.x_service_id = p_esn
                 AND sp_b.part_status || '' IN ('Active', 'Inactive')
                 AND NVL (sp_b.x_refurb_flag, 0) <> 1) refurb_act_date,
             (SELECT MIN (install_date) init_act_date
                FROM table_site_part sp_c
               WHERE sp_c.x_service_id = p_esn
                 AND sp_c.part_status || '' IN ('Active', 'Inactive')) nonrefurb_act_date;

   r_orig_act_date       c_orig_act_date%ROWTYPE;

   CURSOR c_ctt_date
   IS
      SELECT   x_req_date_time, x_reac_date_time
          FROM table_x_zero_out_max
         WHERE x_esn = p_esn AND x_transaction_type IN (2, 5)
      ORDER BY objid DESC;

   r_ctt_date            c_ctt_date%ROWTYPE;

   CURSOR c_webcsr_param
   IS
      SELECT *
        FROM table_x_webcsr_log_param;

   r_webcsr_param        c_webcsr_param%ROWTYPE;

   CURSOR c_custred_units (ip_transact_date IN VARCHAR2)
   IS
      SELECT NVL (SUM (x_total_units), 0) cust_red_units
        FROM table_x_call_trans ct
       WHERE ct.x_service_id = p_esn
         AND x_transact_date >=
                          TO_DATE (ip_transact_date, 'MON/dd/rrrr hh24:mi:ss')
         AND x_result = 'Completed';

   r_custred_units       c_custred_units%ROWTYPE;

--
   CURSOR c_esn_tt_flag
   IS
      SELECT x_clear_tank
        FROM table_part_inst
       WHERE part_serial_no = p_esn;

   r_esn_tt_flag         c_esn_tt_flag%ROWTYPE;
   l_grant_units         NUMBER                    := 0;
--   l_last_handset_date   date;
   l_last_handset_date   VARCHAR2 (100);
   l_custred_units       NUMBER                    := 0;
   l_err_num             NUMBER                    := 0;
   l_err_msg             VARCHAR2 (1000);
BEGIN
   l_grant_units := 0;

   OPEN c_esn_tt_flag;

   FETCH c_esn_tt_flag
    INTO r_esn_tt_flag;

   IF c_esn_tt_flag%NOTFOUND
   THEN
      p_err_num := 1;
      p_err_msg := 'Failure - No Esn';
      p_grant_units := 0;

      CLOSE c_esn_tt_flag;

      RETURN;
   END IF;

   CLOSE c_esn_tt_flag;

   IF r_esn_tt_flag.x_clear_tank = 1
   THEN
      p_err_num := 1;
      p_err_msg := 'Failure - Esn flagged for TimeTank';
      p_grant_units := 0;
   ELSE
      OPEN c_orig_act_date;

      FETCH c_orig_act_date
       INTO r_orig_act_date;

      IF c_orig_act_date%NOTFOUND
      THEN
         p_err_num := 1;
         p_err_msg := 'Failure - No Activation Date';
         p_grant_units := 0;

         CLOSE c_orig_act_date;

         RETURN;
      ELSE
         l_last_handset_date :=
            TO_CHAR (r_orig_act_date.orig_act_date, 'MON/dd/rrrr hh24:mi:ss');
      END IF;

      CLOSE c_orig_act_date;

--   dbms_output.put_line('l_last_handset_date act '||l_last_handset_date);
      OPEN c_ctt_date;

      FETCH c_ctt_date
       INTO r_ctt_date;

      IF c_ctt_date%FOUND
      THEN
         IF r_ctt_date.x_reac_date_time IS NOT NULL
         THEN
--          IF r_ctt_date.x_reac_date_time > to_date(l_last_handset_date,'MON/dd/rrrr hh24:mi:ss')
            IF r_ctt_date.x_req_date_time >
                      TO_DATE (l_last_handset_date, 'MON/dd/rrrr hh24:mi:ss')
            THEN
               l_last_handset_date :=
                  TO_CHAR (r_ctt_date.x_req_date_time,
                           'MON/dd/rrrr hh24:mi:ss'
                          );
--        dbms_output.put_line('l_last_handset_date react '||l_last_handset_date);
            END IF;
         ELSE
            IF r_ctt_date.x_req_date_time >
                      TO_DATE (l_last_handset_date, 'MON/dd/rrrr hh24:mi:ss')
            THEN
               l_last_handset_date :=
                  TO_CHAR (r_ctt_date.x_req_date_time,
                           'MON/dd/rrrr hh24:mi:ss'
                          );
--        dbms_output.put_line('l_last_handset_date req '||l_last_handset_date);
            END IF;
         END IF;
      END IF;

      OPEN c_custred_units (l_last_handset_date);

      FETCH c_custred_units
       INTO r_custred_units;

      CLOSE c_custred_units;

      CLOSE c_ctt_date;

      OPEN c_webcsr_param;

      FETCH c_webcsr_param
       INTO r_webcsr_param;

      CLOSE c_webcsr_param;

      IF     p_ttv_units > 0
         AND p_ttv_units <= NVL (r_custred_units.cust_red_units, 0)
      THEN                                                      --TTV avilable
         l_grant_units := r_webcsr_param.x_percen_extra_units * p_ttv_units;

         IF l_grant_units >= p_cru
         THEN
            l_err_num := 0;
            l_err_msg := 'Success';
         ELSE
            l_err_num := 2;
            l_err_msg := 'Customer Request More';
         END IF;
      ELSIF (   p_ttv_units = 0
             OR p_ttv_units > NVL (r_custred_units.cust_red_units, 0)
            )
      THEN                                                  --TTV not avilable
         l_grant_units := NVL (r_custred_units.cust_red_units, 0);
         l_err_num := 0;
         l_err_msg := 'Success';
      END IF;

      IF l_grant_units <= r_webcsr_param.x_max_phone_units
      THEN
         p_err_num := l_err_num;
         p_err_msg := l_err_msg;
         p_grant_units := l_grant_units;
         p_custred_units := r_custred_units.cust_red_units;
      ELSE
         p_err_num := 3;
         p_err_msg := 'Granted units exceeds CAP';
         p_grant_units := r_webcsr_param.x_max_phone_units;
         p_custred_units := r_custred_units.cust_red_units;
      END IF;
   END IF;

   RETURN;
EXCEPTION
   WHEN OTHERS
   THEN
      p_err_num := 4;
      p_err_msg := 'Error in Procedure';
      p_grant_units := 0;
      p_custred_units := 0;
      RETURN;
END transfer_units_prc;
/