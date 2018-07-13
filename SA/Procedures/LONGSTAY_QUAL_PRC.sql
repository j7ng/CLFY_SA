CREATE OR REPLACE PROCEDURE sa."LONGSTAY_QUAL_PRC" (
   p_esn       IN       VARCHAR2,
   p_err_no    OUT      NUMBER,
   p_err_msg   OUT      VARCHAR2
)
IS
/********************************************************************************/
/* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved                */
/*                                                                              */
/* Name         :   longstay_qual_prc                                                 */
/* Purpose      :   To check whether the esn is qualified for "Long you staty promotion"                                            */
/* Parameters   :                                                               */
/* Platforms    :   Oracle 8.0.6 AND newer versions                             */
/* Author       :                                                               */
/* Date         :   04/17/06                                                  */
/* Revisions    :                                                               */
/*                                                                              */
/* Version  Date        Who             Purpose                                 */
/* -------  --------    -------         --------------------------------------  */
/* 1.0    04/17/06      VA             CR5221 changes
/* 1.1     04/18/06     VA          Added a '/' at the end
/* 1.2	   05/08/06		VA			CR5221-1
/* 1.3	   05/09/06		VA			Fix for CR5221-1
/********************************************************************************/
   CURSOR c_get_g2esn
   IS
      SELECT 1
        FROM table_part_inst pi,
             table_x_promotion_group pg,
             table_x_group2esn ge
       WHERE pg.group_name = 'LONG_STAY_GRP'
         AND ge.groupesn2x_promo_group + 0 = pg.objid
         AND ge.groupesn2part_inst = pi.objid
         AND pi.part_serial_no = p_esn;

   r_get_g2esn       c_get_g2esn%ROWTYPE;

   CURSOR c_act_date
   IS
      SELECT MAX (install_date) act_date
        FROM table_site_part sp
       WHERE x_service_id = p_esn
         AND part_status || '' IN ('Inactive', 'Active');

   r_act_date        c_act_date%ROWTYPE;

   CURSOR c_react_date
   IS
      SELECT install_date act_date
        FROM table_site_part sp
       WHERE x_service_id = p_esn AND part_status || '' = 'Active';

   r_react_date      c_react_date%ROWTYPE;

   CURSOR c_inact_count
   IS
      SELECT COUNT (1) cnt
        FROM table_site_part sp1
       WHERE sp1.x_service_id = p_esn
         AND part_status || '' = 'Inactive'
         AND x_deact_reason IN
                ('PASTDUE',
                 'SELL PHONE',
                 'NO NEED OF PHONE',
                 'REFURBISHED',
                 'CUSTOMER REQD'
                );

   r_inact_count     c_inact_count%ROWTYPE;

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

   r_orig_act_date   c_orig_act_date%ROWTYPE;
   l_qual_cnt        NUMBER                    := 0;
   l_act_date        DATE;
BEGIN
   p_err_no := 0;
   p_err_msg := 'Qualified';

   --check group2esn start
   OPEN c_get_g2esn;

   FETCH c_get_g2esn
    INTO r_get_g2esn;

   IF c_get_g2esn%NOTFOUND
   THEN
      p_err_no := 1;
      p_err_msg := 'Not Qualified : Esn not in GROUP2ESN';

      CLOSE c_get_g2esn;

      RETURN;
   END IF;

   CLOSE c_get_g2esn;

   --check group2esn end
--
   --check 90day activity start
   OPEN c_act_date;

   FETCH c_act_date
    INTO r_act_date;

   IF c_act_date%NOTFOUND
   THEN
      p_err_no := 2;
      p_err_msg := 'Not Qualified : Esn not ACTIVE';
      RETURN;

      CLOSE c_act_date;
   ELSE
      CLOSE c_act_date;

      OPEN c_inact_count;

      FETCH c_inact_count
       INTO r_inact_count;

      CLOSE c_inact_count;

      IF r_inact_count.cnt = 0
      THEN
         OPEN c_orig_act_date;

         FETCH c_orig_act_date
          INTO r_orig_act_date;

         CLOSE c_orig_act_date;

         l_act_date := r_orig_act_date.orig_act_date;
      ELSE
         OPEN c_react_date;

         FETCH c_react_date
          INTO r_react_date;

         IF c_react_date%FOUND
         THEN
            l_act_date := r_react_date.act_date;
         ELSE
            l_act_date := SYSDATE;
         END IF;

         CLOSE c_react_date;
      END IF;

      IF l_act_date >= TO_DATE ('01-jan-06')
      THEN
         IF (SYSDATE - l_act_date) >= 90
         THEN
            p_err_no := 0;
            p_err_msg := 'Success';
            RETURN;
         ELSE
            p_err_no := 3;
            p_err_msg :=
                    'Not Qualified : Esn (new history) with <90 DAY Activity';
            RETURN;
         END IF;
      ELSE
         IF (SYSDATE - TO_DATE ('01-jan-06')) >= 90
         THEN
            p_err_no := 0;
            p_err_msg := 'Success';
            RETURN;
         ELSE
            p_err_no := 4;
            p_err_msg :=
                    'Not Qualified : Esn (old history) with <90 DAY Activity';
            RETURN;
         END IF;
      END IF;
   END IF;

   CLOSE c_act_date;
--check 90day activity end
END longstay_qual_prc;
/