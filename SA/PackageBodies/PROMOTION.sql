CREATE OR REPLACE PACKAGE BODY sa."PROMOTION"
AS
/***************************************************************
* Name: promotion (BODY)
*
* History
* Version           Date           Who          Description
* ============      ============== ==========   ================
* 1.0                                           Initial
* 1.1               04/10/03       SL           Clarify Upgrade
*                                               - sequence
*
*****************************************************************/
   PROCEDURE rebate (
      ip_esn       IN       VARCHAR2,
      ip_status    OUT      VARCHAR2,
      op_actdate   OUT      DATE
   )
   IS

      e_no_esn EXCEPTION;
      e_no_activation_date EXCEPTION;
      e_rebate_not_due EXCEPTION;
      e_disqualified EXCEPTION;


      CURSOR c_esn_found
      IS
         SELECT part_serial_no
           FROM table_part_inst
          WHERE part_serial_no = ip_esn
            AND x_domain = 'PHONES';


      CURSOR c_initial_act_date
      IS
         SELECT MIN (install_date) act_date
           FROM table_site_part
          WHERE x_service_id = ip_esn
            AND part_status IN ('Active',  'Inactive')
          GROUP BY x_service_id;


      CURSOR c_check_active (due_date IN DATE)
      IS
         SELECT objid
           FROM table_site_part
          WHERE (   TRUNC (service_end_dt) >= TRUNC (due_date - 10)
                 OR TO_CHAR (service_end_dt, 'dd-mon-yyyy') = '01-jan-1753'
                 OR service_end_dt IS NULL)
            AND TRUNC (install_date) <= TRUNC (due_date + 10)
            AND x_service_id = ip_esn
            AND part_status IN ('Active',  'Inactive');


      r_initial_act_date c_initial_act_date%ROWTYPE;
      r_check_active c_check_active%ROWTYPE;
      r_esn_found c_esn_found%ROWTYPE;
   BEGIN

      OPEN c_esn_found;
      FETCH c_esn_found INTO r_esn_found;


      IF c_esn_found%NOTFOUND
      THEN
         CLOSE c_esn_found;
         RAISE e_no_esn;
      ELSE
         CLOSE c_esn_found;
      END IF;

--Added by VAdapa on 02/18/2002 to "Disqualify" DIGITAL ESNs for "Rebate" offers
      IF NOT promotion.checkesntech (ip_esn)
      THEN
         RAISE e_disqualified;
      END IF;
--

      OPEN c_initial_act_date;
      FETCH c_initial_act_date INTO r_initial_act_date;


      IF c_initial_act_date%NOTFOUND
      THEN
         CLOSE c_initial_act_date;
         op_actdate := NULL;
         RAISE e_no_activation_date;
      ELSE
         op_actdate := r_initial_act_date.act_date;
         CLOSE c_initial_act_date;
      END IF;

      DBMS_OUTPUT.put_line (
         'Act Date =  ' || TO_CHAR (r_initial_act_date.act_date, 'dd-mon-yy')
      );
      DBMS_OUTPUT.put_line (
         'Due Date =  ' ||
         TO_CHAR ((r_initial_act_date.act_date + 90), 'dd-mon-yy')
      );


      IF r_initial_act_date.act_date > SYSDATE - 80
      THEN
         RAISE e_rebate_not_due;
      END IF;


      OPEN c_check_active (r_initial_act_date.act_date + 90);
      FETCH c_check_active INTO r_check_active;


      IF c_check_active%NOTFOUND
      THEN
         CLOSE c_check_active;
         RAISE e_disqualified;
      ELSE
         CLOSE c_check_active;
      END IF;


      ip_status := 'Qualified';
      DBMS_OUTPUT.put_line ('Qualified');

   EXCEPTION
      WHEN e_no_esn
      THEN
         ip_status := 'Not Found';
         DBMS_OUTPUT.put_line ('Not Found');
      WHEN e_no_activation_date
      THEN
         ip_status := 'Review';
         DBMS_OUTPUT.put_line ('Review');
      WHEN e_rebate_not_due
      THEN
         ip_status := 'Review';
         DBMS_OUTPUT.put_line ('Review');
      WHEN e_disqualified
      THEN
         ip_status := 'Disqualified';
         DBMS_OUTPUT.put_line ('Disqualified');
   END rebate;
--
--
   PROCEDURE referral
/**************************************************************************/
/* Name        : REFERRAL                                                */
/* Author      : Gerald Pintado                                         */
/* Date        : 01/06/2000                                              */
/* Input Paramaters  : ip_esn,                                        */
/* Output Paramaters    : ip_status                                     */
/* Purpose : Checks to see if ip_esn has been active for more             */
/*           than 90 days. If not active it gets a (disqualified) status, */
/*           else if active but still hasn't completed its 90 days it     */
/*           gets a (review) status.                                      */
/**************************************************************************/
                      (
      ip_esn       IN       VARCHAR2,
      ip_status    OUT      VARCHAR2,
      op_actdate   OUT      DATE
   )
   IS
      e_no_esn EXCEPTION;
      e_no_activation_date EXCEPTION;
      e_rebate_not_due EXCEPTION;
      e_disqualified EXCEPTION;


      CURSOR c_esn_found
      IS
         SELECT part_serial_no
           FROM table_part_inst
          WHERE part_serial_no = ip_esn
            AND x_domain = 'PHONES';


      CURSOR c_initial_act_date
      IS
         SELECT MIN (install_date) act_date
           FROM table_site_part
          WHERE x_service_id = ip_esn
            AND part_status IN ('Active',  'Inactive')
          GROUP BY x_service_id;


      CURSOR c_check_active (due_date IN DATE)
      IS
         SELECT objid
           FROM table_site_part
          WHERE (   TRUNC (service_end_dt) >= TRUNC (due_date - 10)
                 OR TO_CHAR (service_end_dt, 'dd-mon-yyyy') = '01-jan-1753'
                 OR service_end_dt IS NULL)
            AND TRUNC (install_date) <= TRUNC (due_date + 10)
            AND x_service_id = ip_esn
            AND part_status IN ('Active',  'Inactive');


      r_initial_act_date c_initial_act_date%ROWTYPE;
      r_check_active c_check_active%ROWTYPE;
      r_esn_found c_esn_found%ROWTYPE;
   BEGIN

      OPEN c_esn_found;
      FETCH c_esn_found INTO r_esn_found;


      IF c_esn_found%NOTFOUND
      THEN
         CLOSE c_esn_found;
         RAISE e_no_esn;
      ELSE
         CLOSE c_esn_found;
      END IF;


      OPEN c_initial_act_date;
      FETCH c_initial_act_date INTO r_initial_act_date;


      IF c_initial_act_date%NOTFOUND
      THEN
         op_actdate := NULL;
         CLOSE c_initial_act_date;
         RAISE e_no_activation_date;
      ELSE
         CLOSE c_initial_act_date;
         op_actdate := r_initial_act_date.act_date;
      END IF;

      DBMS_OUTPUT.put_line (
         'Act Date =  ' || TO_CHAR (r_initial_act_date.act_date, 'dd-mon-yy')
      );
      DBMS_OUTPUT.put_line (
         'Due Date =  ' ||
         TO_CHAR ((r_initial_act_date.act_date + 90), 'dd-mon-yy')
      );


      IF r_initial_act_date.act_date > SYSDATE - 80
      THEN
         RAISE e_rebate_not_due;
      END IF;


      OPEN c_check_active (r_initial_act_date.act_date + 90);
      FETCH c_check_active INTO r_check_active;


      IF c_check_active%NOTFOUND
      THEN
         CLOSE c_check_active;
         RAISE e_disqualified;
      ELSE
         CLOSE c_check_active;
      END IF;


      ip_status := 'Qualified';
      DBMS_OUTPUT.put_line ('Qualified');
   EXCEPTION
      WHEN e_no_esn
      THEN
         ip_status := 'Not Found';
         DBMS_OUTPUT.put_line ('Not Found');
      WHEN e_no_activation_date
      THEN
         ip_status := 'Review';
         DBMS_OUTPUT.put_line ('Review');
      WHEN e_rebate_not_due
      THEN
         ip_status := 'Review';
         DBMS_OUTPUT.put_line ('Review');
      WHEN e_disqualified
      THEN
         ip_status := 'Disqualified';
         DBMS_OUTPUT.put_line ('Disqualified');
   END referral;
--
--
   PROCEDURE gettimecode
/***************************************************************************/
/* Name        : GetTimeCode                                              */
/* Author      : Gerald Pintado                                          */
/* Date        : 01/06/2000                                               */
/* Input Paramaters  : ip_sub_esn,ip_ref_esn,ip_promo_type,             */
/*                        ip_part_number                               */
/* Output Paramaters    : op_code                                     */
/* Purpose : Will get a new time code in x_promotion_code_pool             */
/*           and insert it into table_part_inst, associating it with the   */
/*           part_number selected from the rebate/referral program.        */
/***************************************************************************/
                         (
      ip_sub_esn       IN       VARCHAR2,
      ip_ref_esn       IN       VARCHAR2,
      ip_promo_type    IN       NUMBER,   -- 0=REBATE,1=REFERRAL
      ip_part_number   IN       VARCHAR2,
      op_code          OUT      VARCHAR2
   )
   IS
      e_no_esn EXCEPTION;
      e_no_newcode EXCEPTION;
      e_code_exists EXCEPTION;
      e_diff_sub_esn EXCEPTION;
      e_no_esn_objid EXCEPTION;
      v_red_code VARCHAR2 (50);
      v_esn VARCHAR2 (11);
      v_esn_objid NUMBER;
--
      CURSOR c_getcodereferral
      IS
         SELECT red_code, esn
           FROM x_referral_info
          WHERE esn_referred = ip_ref_esn;
--
      CURSOR c_getcoderebate
      IS
         SELECT red_code
           FROM x_rebate_info
          WHERE esn = ip_sub_esn;
--
      CURSOR c_getnewcode
      IS
         SELECT x_red_code, part_serial_no
           FROM x_promotion_code_pool
          WHERE ROWNUM < 2;
--
      CURSOR c_getmodlevel
      IS
         SELECT objid
           FROM table_mod_level
          WHERE part_info2part_num = (SELECT objid
                                        FROM table_part_num
                                       WHERE part_number = ip_part_number);
--
      CURSOR c_getesnobjid
      IS
         SELECT objid
           FROM table_part_inst
          WHERE x_domain = 'PHONES'
            AND part_serial_no = ip_sub_esn;
--
      r_getcodereferral c_getcodereferral%ROWTYPE;
      r_getcoderebate c_getcoderebate%ROWTYPE;
      r_getnewcode c_getnewcode%ROWTYPE;
      r_getmodlevel c_getmodlevel%ROWTYPE;
      r_getesnobjid c_getesnobjid%ROWTYPE;
   BEGIN
      -- Fetches esn objid from table_part_inst
      OPEN c_getesnobjid;
      FETCH c_getesnobjid INTO r_getesnobjid;


      IF c_getesnobjid%NOTFOUND
      THEN
         CLOSE c_getesnobjid;
         RAISE e_no_esn_objid;
      END IF;

      CLOSE c_getesnobjid;


      IF ip_promo_type = 0
      THEN
         OPEN c_getcoderebate;
         FETCH c_getcoderebate INTO r_getcoderebate;

         --checks to see if ip_ref_esn exists in table (x_referral_info).
         IF c_getcoderebate%NOTFOUND
         THEN
            CLOSE c_getcoderebate;
            RAISE e_no_esn;
         END IF;

         --if it does exist then it will assign red_code to the variable below.
         v_red_code := r_getcoderebate.red_code;
         CLOSE c_getcoderebate;
      ELSE
         OPEN c_getcodereferral;
         FETCH c_getcodereferral INTO r_getcodereferral;

         --checks if ip_ref_esn exists in table (x_referral_info).
         IF c_getcodereferral%NOTFOUND
         THEN
            CLOSE c_getcodereferral;
            RAISE e_no_esn;
         END IF;

         CLOSE c_getcodereferral;
         --if it does exist then it will assign red_code and esn to the variables below.
         v_red_code := r_getcodereferral.red_code;
         v_esn := r_getcodereferral.esn;

         --if ip_sub_esn is <> to v_esn, then ip_ref_esn has been referred
         --by another ip_sub_esn already
         IF v_esn <> ip_sub_esn
         THEN
            RAISE e_diff_sub_esn;
         END IF;
      END IF;
      <<retry_insert>>
      -- checks if a time code already exists for esn given,
      -- if null it will continue on, else will raise e_code_exists
      IF v_red_code IS NULL
      THEN
         OPEN c_getnewcode;
         FETCH c_getnewcode INTO r_getnewcode;

         -- Checks if code pool has not run out of codes.
         IF c_getnewcode%NOTFOUND
         THEN
            CLOSE c_getnewcode;
            RAISE e_no_newcode;
         END IF;

         CLOSE c_getnewcode;
         op_code := r_getnewcode.x_red_code;


         BEGIN
            --Deleting given serial_number from x_promotion_code_pool.
            DELETE x_promotion_code_pool
             WHERE part_serial_no = r_getnewcode.part_serial_no;

            COMMIT;
            -- Fetches mod level objid
            OPEN c_getmodlevel;
            FETCH c_getmodlevel INTO r_getmodlevel;
            CLOSE c_getmodlevel;

            -- Insert new code into table_part_inst with new part_number.
            INSERT INTO table_part_inst   /* Insert into the table_part_inst table */
                        (
                                       objid,
                                       part_serial_no,
                                       x_part_inst_status,
                                       x_sequence,
                                       x_po_num,
                                       x_red_code,
                                       x_order_number,
                                       x_creation_date,
                                       created_by2user,
                                       x_domain,
                                       n_part_inst2part_mod,
                                       part_inst2inv_bin,
                                       part_status,
                                       x_insert_date,
                                       status2x_code_table,
                                       part_to_esn2part_inst,
                                       last_pi_date,
                                       last_cycle_ct,
                                       next_cycle_ct,
                                       last_mod_time,
                                       last_trans_time,
                                       date_in_serv,
                                       repair_date
                        )
                 VALUES(
                   -- 04/10/03 (seq_part_inst.nextval + (POWER (2, 28))),
                    seq('part_inst'),
                    r_getnewcode.part_serial_no,
                    '40',
                    0,
                    NULL,
                    r_getnewcode.x_red_code,
                    NULL,
                    SYSDATE,
                    268435556,   -- SA objid in table_user
                    'REDEMPTION CARDS',
                    r_getmodlevel.objid,
--                    268488622,   -- Topp Telecom Marketing objid in table_inv_bin where bin_name = 2359
                    268490709,   -- "TRACFONE REBATE" objid in table_inv_bin where bin_name = 20740
                    'Active',
                    SYSDATE,
                    982,
                    r_getesnobjid.objid,
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY')
                 );

            --Updating x_rebate_info or x_referreal_info to have new code.
            IF ip_promo_type = 0
            THEN
               UPDATE x_rebate_info
                  SET red_code = op_code
                WHERE esn = ip_sub_esn;
            ELSE
               UPDATE x_referral_info
                  SET red_code = op_code
                WHERE esn_referred = ip_ref_esn;
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               GOTO retry_insert;
            WHEN OTHERS
            THEN
               op_code := 'Error occured while updating';
               RETURN;
         END;
      ELSE   --esn given already has a time code assigned to it.
         RAISE e_code_exists;
      END IF;
   EXCEPTION
      WHEN e_diff_sub_esn
      THEN
         op_code := 'ESN is referred by ' || v_esn;
      WHEN e_no_newcode
      THEN
         op_code := 'No codes available';
      WHEN e_no_esn
      THEN
         op_code := 'Referred esn not found';
      WHEN e_code_exists
      THEN
         op_code := v_red_code;
      WHEN e_no_esn_objid
      THEN
         op_code := 'Subscriber esn not found';
   END gettimecode;

--Added by VAdapa on 02/18/2002 to check the technology of an ESN
   FUNCTION checkesntech (ip_esn IN VARCHAR2)
      RETURN BOOLEAN
   AS

      v_tech VARCHAR2 (20);
   BEGIN

      SELECT pn.x_technology
        INTO v_tech
        FROM table_part_num pn, table_mod_level ml, table_part_inst pi
       WHERE pi.n_part_inst2part_mod = ml.objid
         AND ml.part_info2part_num = pn.objid
         AND pi.part_serial_no = ip_esn;


      IF v_tech = 'ANALOG'
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END checkesntech;
END promotion;
/