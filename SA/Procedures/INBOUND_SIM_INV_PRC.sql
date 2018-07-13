CREATE OR REPLACE PROCEDURE sa."INBOUND_SIM_INV_PRC"
AS
/*****************************************************************************/
/* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved             */
/*                                                                           */
/* Name         :   SA.INBOUND_SIM_INV_PRC                                   */
/* Purpose      :                                                            */
/*                  Financials into TOSS and update the interface table once */
/*                  the extract is done                                      */
/*                                                                           */
/* Parameters   :   NONE                                                     */
/* Platforms    :   Oracle 8.0.6 AND newer versions                          */
/* Author      :   Miguel Leon                                               */
/* Date         :   01/25/2001                                               */
/* Revisions   :                                                             */
/* Version  Date      Who      Purpose                                       */
/* -------  --------  -------  ----------------------------------------------*/
/* 1.0     01/25/2003 Mleon    Initial revision                              */
/* 1.1     09/23/2003 Mleon    Changed to used production db link            */
/*****************************************************************************/



   v_action                 VARCHAR2 (50)                  := ' ';
   v_err_text               VARCHAR2 (4000);
   v_dealer_status          VARCHAR2 (20);
   v_serial_num             VARCHAR2 (50);
   v_revision               VARCHAR2 (10);
   v_part_inst2part_mod     NUMBER;
   v_part_inst2part_mod_1   NUMBER;
   v_part_inst2part_mod_2   NUMBER;
   v_part_inst_seq          NUMBER; --06/04/03
   v_creation_date          DATE;
   v_site_id                VARCHAR2 (80);
   validate_exp             EXCEPTION;
   v_out_action             VARCHAR2 (50);
   v_out_error              VARCHAR2 (4000);
   v_dealer_valid_date      DATE;
   v_reset_date             DATE;
   v_reset_action_type      VARCHAR2(80);
   refurb_exp               EXCEPTION;   -- new
   no_site_id_exp           EXCEPTION;
   distributed_trans_time_out EXCEPTION;
   record_locked              EXCEPTION;
   v_procedure_name VARCHAR2(80) := 'INBOUND_SIM_INV_PRC';
   v_recs_processed          NUMBER                 := 0;
   v_start_date              DATE                   := SYSDATE;
   v_mnc                     VARCHAR2(6)   := NULL;

-- Motorola Digital variables

   frequency_string          VARCHAR2(1000);
   frequency_hold            VARCHAR2(1000);
   frequency_insert          VARCHAR2(1000);

   part_num14_x_freq0_rec    mtm_part_num14_x_frequency0%ROWTYPE;
   table_frequency_rec       table_x_frequency%ROWTYPE;
   table_part_rec            table_part_num%ROWTYPE;
   table_x_default_rec       table_x_default_preload%ROWTYPE;

   failed_insert_frequency  EXCEPTION;
   failed_insert_part_freq  EXCEPTION;
--
   PRAGMA EXCEPTION_INIT(distributed_trans_time_out, -2049);
   PRAGMA EXCEPTION_INIT(record_locked, -54);
--

/* Cursor to extract PHONES/CARDS data from TF_TOSS_INTERFACE_TABLE via database link*/
   CURSOR c_inv_inbound
   IS
          SELECT /*+ RULE */tf.rowid, tf.tf_part_num_parent, tf_part_num_transpose,
             toss_extract_flag, tf_serial_num, tf_part_type,
             tf_card_pin_num, transceiver_num, tf_manuf_location_code,
             tf_manuf_location_name, tf_ff_location_code,
             tf_ret_location_code, tf_order_num, creation_date,
             created_by, ff_receive_date, retailer_ship_date,
             serial_invalid_date, serial_valid_insert_date,
             TF_PHONE_REFURB_DATE
        FROM
            tf.tf_toss_interface_table@OFSPRD tf

       WHERE
            tf_part_type || '' = 'PHONE'
       AND
       toss_extract_flag = 'NO'
       AND EXISTS (
            SELECT 1
            FROM
             tf.tf_of_item_v@OFSPRD iv
             WHERE
          part_number = tf_part_num_parent
         AND clfy_domain = 'SIM CARDS'
         AND part_assignment = 'PARENT');



/* Cursor to extract new item information from TF_ITEM_V view via database link*/
   CURSOR c_new_item (c_ip_part_no IN VARCHAR2)
   IS
      SELECT *
        FROM tf.tf_of_item_v@OFSPRD
       WHERE part_number = c_ip_part_no;


   r_new_item               c_new_item%ROWTYPE;
   r_transpose              c_new_item%ROWTYPE;   --new item
--

/* Cursor to extract TOSS dealer id based on Financials Customer Id */
   CURSOR c_site_id (c_ip_fin_cust_id IN VARCHAR2)
   IS
      SELECT site_id
        FROM table_site
       WHERE type = 3
         AND x_fin_cust_id = c_ip_fin_cust_id;


   r_site_id                c_site_id%ROWTYPE;
--

/* Cursor to get the part domain object id */
   CURSOR c_get_domain_objid (c_ip_domain IN VARCHAR2)
   IS
      SELECT objid
        FROM table_prt_domain
       WHERE name = c_ip_domain;


   r_get_domain_objid       c_get_domain_objid%ROWTYPE;
--

/* Cursor to get the part number object id */
   CURSOR c_part_exists (c_ip_domain2 IN VARCHAR2,  c_ip_part_number IN VARCHAR2)
   IS
      SELECT objid
        FROM table_part_num
       WHERE part_number = c_ip_part_number
         AND part_num2domain = c_ip_domain2;


   r_part_exists            c_part_exists%ROWTYPE;
--

/* Cursor to get the mod_level information for the given part number */--Digital
   CURSOR c_mod_level_exists (
      c_ip_part_num_objid   IN   VARCHAR2,
      c_ip_revision         IN   VARCHAR2
   )
   IS
      SELECT objid
        FROM table_mod_level
       WHERE part_info2part_num = c_ip_part_num_objid
         AND active = 'Active'
         AND mod_level = c_ip_revision;


   r_mod_level_exists       c_mod_level_exists%ROWTYPE;
--

/* Cursor to get part number's programmable flag and DLL info */
   CURSOR c_get_2xs (c_ip_serno IN VARCHAR2)
   IS
      SELECT a.objid, a.x_dll, a.x_programmable_flag
        FROM table_part_num a, table_mod_level b, table_x_sim_inv c
       WHERE a.objid = b.part_info2part_num
         AND b.objid = c.x_sim_inv2part_mod
         AND c.x_sim_serial_no = c_ip_serno;


   r_get_2xs                c_get_2xs%ROWTYPE;
--

/* Cursor to generate an object id for new part script */
/* 06/04/03  CURSOR c_seq_part_script
   IS
      -- 04/10/03 SELECT seq_x_part_script.nextval + (power (2, 28)) val
        SELECT seq('x_part_script') val
        FROM dual;

   r_seq_part_script        c_seq_part_script%ROWTYPE;
   */
   r_seq_part_script_val    number; --06/04/03
--

/* Cursor to generate object id for new part number */

   r_seq_part_num_val       number; --06/04/03
--

/* Cursor to generate object id for new mod level */
/* 06/04/03   CURSOR c_seq_mod_level
   IS
      -- 04/10/03 SELECT seq_mod_level.nextval + (power (2, 28)) val
        SELECT seq('mod_level') val
        FROM dual;

   r_seq_mod_level          c_seq_mod_level%ROWTYPE; */
   r_seq_mod_level_val      number; --06/04/03
--

/* Cursor to get script info for the part number */
   CURSOR c_part_script (c_ip_ps2pn IN NUMBER)
   IS
      SELECT x_type, x_sequence, x_script_text
        FROM table_x_part_script
       WHERE part_script2part_num = c_ip_ps2pn;


   r_part_script            c_part_script%ROWTYPE;
--

/* Cursor to get user object id --> Looks for other users, G.P 12-27-2000 */
   CURSOR c_load_user_objid
   IS
      SELECT objid
        FROM table_user
       WHERE login_name = 'ORAFIN';


   r_load_user_objid        c_load_user_objid%ROWTYPE;
--

/* Cursor to get bin object id */
   CURSOR c_load_inv_bin_objid (c_ip_customer_id IN VARCHAR2)
   IS
      SELECT objid
        FROM table_inv_bin
       WHERE bin_name = c_ip_customer_id;


   r_load_inv_bin_objid     c_load_inv_bin_objid%ROWTYPE;
--

/* Cursor to get code object id */
/* added POSA PHONES            */
   CURSOR c_load_code_table (c_ip_domain4 IN VARCHAR2)
   IS
      SELECT objid
        FROM table_x_code_table
       WHERE x_code_number =
                DECODE (
                   c_ip_domain4,
                   'SIM', '253',
                   'POSA SIM', '253'
                );


   r_load_code_table        c_load_code_table%ROWTYPE;
--

/* Cursor to check if the serial number exists in part_inst table */
   CURSOR c_check_part_inst (
      c_ip_serial_number   IN   VARCHAR2--,
 --     c_ip_domain5         IN   VARCHAR2
   )
   IS
      SELECT *
       -- FROM table_part_inst
       FROM table_x_sim_inv
       WHERE x_sim_serial_no = c_ip_serial_number;
    --     AND x_domain = c_ip_domain5;


   r_check_part_inst        c_check_part_inst%ROWTYPE;
--

/* Cursor to get part number object id associated with the revision of the part number */
   CURSOR c_load_mod_level_objid (
      c_ip_part_number   IN   VARCHAR2,
      c_ip_revision      IN   VARCHAR2,
      c_ip_domain        IN   VARCHAR2
   )
   IS
      SELECT a.objid
        FROM table_mod_level a, table_part_num b
       WHERE a.mod_level = c_ip_revision
         AND a.part_info2part_num = b.objid
         AND a.active = 'Active'   --Digital
         AND b.part_number = c_ip_part_number
         AND b.domain = c_ip_domain;


   r_load_mod_level_objid   c_load_mod_level_objid%ROWTYPE;
--

/* Cursor to check whether mod_level exists for the given part number with NULL revision */
   CURSOR c_mod_level_with_null (c_ip_pn_objid IN NUMBER)
   IS
      SELECT objid
        FROM table_mod_level
       WHERE part_info2part_num = c_ip_pn_objid
         AND active = 'Active'
         AND mod_level IS NULL;


   r_mod_level_with_null    c_mod_level_with_null%ROWTYPE;
--

/* Cursor to check whether atleast one revision info exists for the analog part number */
   CURSOR c_analog_mod (c_ip_pn_objid_1 IN NUMBER)
   IS
      SELECT objid, mod_level
        FROM table_mod_level
       WHERE part_info2part_num = c_ip_pn_objid_1
         AND active = 'Active';


   r_analog_mod             c_analog_mod%ROWTYPE;
--
/* Cursor to check if there has been a posa transaction */
CURSOR posa_check_cur (ip_smp VARCHAR2)
IS
SELECT 'X'
FROM x_posa_phone
WHERE tf_serial_num = ip_smp;

  posa_check_rec         posa_check_cur%ROWTYPE;



/* cursor to get the active record from the table_site_part */
   CURSOR c_check_active_sp (ip_esn IN VARCHAR2)
   IS
      SELECT rowid
        FROM table_site_part sp
       WHERE x_service_id = ip_esn
         AND part_status = 'Active';


   r_check_active_sp        c_check_active_sp%ROWTYPE;
/*  get mod level cursor */
   CURSOR c_mod_level (c_ip_part_number IN VARCHAR2)
   IS
      SELECT a.objid
        FROM table_mod_level a, table_part_num b
       WHERE a.part_info2part_num = b.objid
         AND a.active = 'Active'
         AND b.part_number = c_ip_part_number;


   r_mod_level              c_mod_level%ROWTYPE;



   processed_counter        NUMBER                         := 0;
   inner_counter            NUMBER                         := 0;
BEGIN

      FOR r_inv_inbound IN c_inv_inbound
      LOOP

         v_recs_processed := v_recs_processed + 1;




         BEGIN
            v_serial_num := r_inv_inbound.tf_serial_num;
            v_site_id := null;
            v_creation_date := null;
            v_dealer_status := null;
            v_part_inst2part_mod_1 := null;
            v_part_inst2part_mod_2 := null;
            v_dealer_valid_date := null;


            IF r_inv_inbound.tf_ret_location_code IS NOT NULL THEN
               OPEN c_site_id (r_inv_inbound.tf_ret_location_code);
               FETCH c_site_id INTO v_site_id;
               CLOSE c_site_id;

               v_creation_date := r_inv_inbound.retailer_ship_date;

            ELSIF r_inv_inbound.tf_ff_location_code IS NOT NULL THEN
               OPEN c_site_id (r_inv_inbound.tf_ff_location_code);
               FETCH c_site_id INTO v_site_id;
               CLOSE c_site_id;

               v_creation_date := r_inv_inbound.ff_receive_date;

            ELSIF r_inv_inbound.tf_manuf_location_code IS NOT NULL THEN
               OPEN c_site_id (r_inv_inbound.tf_manuf_location_code);
               FETCH c_site_id INTO v_site_id;
               CLOSE c_site_id;

               v_creation_date := r_inv_inbound.creation_date;
            END IF;


            IF v_site_id IS NOT NULL THEN

               OPEN c_new_item (r_inv_inbound.tf_part_num_parent);
               FETCH c_new_item INTO r_new_item;
               CLOSE c_new_item;
/* combined new field part_subtype */
--                IF r_new_item.domain = 'PHONES' THEN
                  v_revision := r_inv_inbound.transceiver_num;
                  /* for phones check at tf_part_num_transpose */
                  OPEN c_new_item (r_inv_inbound.tf_part_num_transpose);
                  FETCH c_new_item INTO r_transpose;
                  CLOSE c_new_item;


             --     IF r_transpose.posa_type = 'POSA' THEN
               --      v_dealer_status := '253';
              --    ELSIF r_transpose.posa_type = 'NPOSA' THEN
              --       v_dealer_status := '253';
              --    ELSE
               --      v_dealer_status := null;
              --    END IF;

              v_dealer_status := '253'  ;




               v_action := ' ';


/********************************************************************************/
/*          Test to see if part number exists in the table_part_num table       */
/*  If the part number does not exist, insert into part num, table_script and   */
/*          mod_level tables,else update the part num and mod level tables      */
/********************************************************************************/

/* Get the domain object id */
               OPEN c_get_domain_objid (r_new_item.clfy_domain);
               FETCH c_get_domain_objid INTO r_get_domain_objid;
               CLOSE c_get_domain_objid;
/* Get the part sequence number */
               OPEN c_part_exists (
                  r_get_domain_objid.objid,
                  r_inv_inbound.tf_part_num_parent
               );
               FETCH c_part_exists INTO r_part_exists;

               /** AS PER JIM ZIMMERMAN **/
               IF r_inv_inbound.tf_part_num_parent = 'TFSIMC2'
                  OR r_inv_inbound.tf_part_num_parent = 'TFSIMC3' THEN
                   v_mnc := 'G0150'; -- DCS market
               ELSIF r_inv_inbound.tf_part_num_parent = 'TFSIMC1' THEN
                   v_mnc := 'G0170'; -- PVW
               ELSE
                   v_mnc := NULL;

               END IF ;



               IF c_part_exists%NOTFOUND THEN

                  /* 06/04/03 OPEN c_seq_part_num;
                  FETCH c_seq_part_num INTO r_seq_part_num;
                  CLOSE c_seq_part_num; */
                  sp_seq('part_num', r_seq_part_num_val);

                  OPEN c_get_2xs (r_inv_inbound.tf_serial_num);
                  FETCH c_get_2xs INTO r_get_2xs;
                  CLOSE c_get_2xs;

                  OPEN Toss_Cursor_Pkg.table_x_default_preload_cur;
                  FETCH Toss_Cursor_Pkg.table_x_default_preload_cur INTO table_x_default_rec;
                  CLOSE Toss_Cursor_Pkg.table_x_default_preload_cur;

                  v_action := 'Insert into table_part_num';


                  INSERT INTO table_part_num
                              (
                                             objid,
                                             active,
                                             part_number,
                                             s_part_number,
                                             description,
                                             part_type,
                                             x_manufacturer,
                                             domain,
                                             x_redeem_days,
                                             x_redeem_units,
                                             part_num2domain,
                                             s_description,
                                             s_domain,
                                             x_dll,
                                             x_programmable_flag,
                                             x_technology,
                                             x_upc,
                               part_num2default_preload,
                                             x_restricted_use
                              )
                       VALUES(
                          -- 06/04/03 r_seq_part_num.val,
                          r_seq_part_num_val,
                          'Active',
                          r_inv_inbound.tf_part_num_parent,
                          UPPER (r_inv_inbound.tf_part_num_parent),
                          r_new_item.description,
                          r_new_item.charge_code,
                          substr (r_inv_inbound.tf_manuf_location_name, 1, 20),
                          r_new_item.clfy_domain,
                          r_new_item.redemption_days,
                          r_new_item.redemption_units,
                          r_get_domain_objid.objid,
                          UPPER (r_new_item.description),
                          UPPER (r_new_item.clfy_domain),
--                    r_get_2xs.x_dll,
--                    r_get_2xs.x_programmable_flag,
                          r_new_item.dll,
                          r_new_item.programming_flag,
                          r_new_item.technology,
                          r_new_item.upc,
                  table_x_default_rec.objid,
                          0
                       );

--                   OPEN Toss_Cursor_Pkg.table_pn_part_cur (r_new_item.part_number);
--                      FETCH Toss_Cursor_Pkg.table_pn_part_cur INTO table_part_rec;
--                   CLOSE Toss_Cursor_Pkg.table_pn_part_cur;

-- Insert frequency records and frequency, part_num swing table records

--                   IF upper(r_new_item.frequency) = 'NONE' THEN  -- Frequency doesn't apply.
--                      null;
--                   ELSIF instr(r_new_item.frequency,'-') = 0 THEN -- Only one frequency exists.
--
--                      IF Toss_Util_Pkg.FREQUENCY_EXIST_FUN (
--                         r_new_item.frequency,
--                         v_procedure_name
--                       ) THEN
--
--                         OPEN Toss_Cursor_Pkg.table_x_frequency_cur (
--                           r_new_item.frequency
--                         );
--                            FETCH Toss_Cursor_Pkg.table_x_frequency_cur INTO table_frequency_rec;
--                         CLOSE Toss_Cursor_Pkg.table_x_frequency_cur;
--
--                         OPEN TOSS_CURSOR_PKG.part_num14_x_frequency0_cur (table_part_rec.objid, table_frequency_rec.objid);
--                            FETCH TOSS_CURSOR_PKG.part_num14_x_frequency0_cur INTO part_num14_x_freq0_rec;
--
--                         IF TOSS_CURSOR_PKG.part_num14_x_frequency0_cur%FOUND THEN
--                            NULL;
--                         ELSE
--                            IF Toss_Util_Pkg.insert_part_num2frequency_fun (
--                               table_part_rec.objid,
--                               table_frequency_rec.objid,
--                               v_procedure_name
--                            ) THEN
--                               COMMIT;
--                            ELSE
--                               v_action := 'Failed inserting part_num14_x_freq';
--                               RAISE failed_insert_part_freq;
--                            END IF;
--
--                         END IF;
--
--                         CLOSE TOSS_CURSOR_PKG.part_num14_x_frequency0_cur;
--
--                      ELSE
--
--                         IF Toss_Util_Pkg.INSERT_FREQUENCY_FUN (
--                            r_new_item.frequency,
--                            v_procedure_name
--                         ) THEN
--                            COMMIT;
--                         ELSE
--                            v_action := 'Failed inserting frequency';
--                            RAISE failed_insert_frequency;
--                         END IF;
--
--                         OPEN Toss_Cursor_Pkg.table_x_frequency_cur (
--                            r_new_item.frequency
--                         );
--                            FETCH Toss_Cursor_Pkg.table_x_frequency_cur INTO table_frequency_rec;
--                         CLOSE Toss_Cursor_Pkg.table_x_frequency_cur;
--
--                         OPEN TOSS_CURSOR_PKG.part_num14_x_frequency0_cur (table_part_rec.objid, table_frequency_rec.objid);
--                            FETCH TOSS_CURSOR_PKG.part_num14_x_frequency0_cur INTO part_num14_x_freq0_rec;
--
--                         IF TOSS_CURSOR_PKG.part_num14_x_frequency0_cur%FOUND THEN
--                            NULL;
--                         ELSE
--                            IF Toss_Util_Pkg.insert_part_num2frequency_fun (
--                               table_part_rec.objid,
--                               table_frequency_rec.objid,
--                               v_procedure_name
--                            ) THEN
--                               COMMIT;
--                            ELSE
--                               v_action := 'Failed inserting part_num14_x_freq';
--                               RAISE failed_insert_part_freq;
--                            END IF;
--
--                         END IF;
--
--                         CLOSE TOSS_CURSOR_PKG.part_num14_x_frequency0_cur;
--
--                      END IF;
--
--                   ELSE
--
--                      frequency_string := r_new_item.frequency;
--
--                      WHILE length(frequency_string) > 1 LOOP
--                         frequency_insert := substr(frequency_string,1,instr(frequency_string,'-')-1);
--                         frequency_hold   := substr(frequency_string,instr(frequency_string,'-')+ 1);
--
--                         if frequency_hold is not null then
--                            frequency_string := frequency_hold;
--                         else
--                            frequency_string := '-';
--                         end if;
--
--                         IF Toss_Util_Pkg.FREQUENCY_EXIST_FUN (
--                            frequency_insert,
--                            v_procedure_name
--                          ) THEN
--
--                            OPEN Toss_Cursor_Pkg.table_x_frequency_cur (
--                               frequency_insert);
--
--                               FETCH Toss_Cursor_Pkg.table_x_frequency_cur INTO table_frequency_rec;
--                            CLOSE Toss_Cursor_Pkg.table_x_frequency_cur;
--
--                            OPEN TOSS_CURSOR_PKG.part_num14_x_frequency0_cur (table_part_rec.objid, table_frequency_rec.objid);
--                               FETCH TOSS_CURSOR_PKG.part_num14_x_frequency0_cur INTO part_num14_x_freq0_rec;
--
--                            IF TOSS_CURSOR_PKG.part_num14_x_frequency0_cur%FOUND THEN
--                               NULL;
--                            ELSE
--                               IF Toss_Util_Pkg.insert_part_num2frequency_fun (
--                                  table_part_rec.objid,
--                                  table_frequency_rec.objid,
--                                  v_procedure_name
--                               ) THEN
--                                  COMMIT;
--                               ELSE
--                                  v_action := 'Failed inserting part_num14_x_freq';
--                                  RAISE failed_insert_part_freq;
--                               END IF;
--
--                            END IF;
--
--                            CLOSE TOSS_CURSOR_PKG.part_num14_x_frequency0_cur;
--
--                         ELSE
--
--                          IF Toss_Util_Pkg.INSERT_FREQUENCY_FUN (
--                               frequency_insert,
--                               v_procedure_name
--                            ) THEN
--                               COMMIT;
--                            ELSE
--                               v_action := 'Failed inserting frequency';
--                               RAISE failed_insert_frequency;
--
--                            END IF;
--
--                            OPEN Toss_Cursor_Pkg.table_x_frequency_cur (
--                              frequency_insert
--                             );
--                               FETCH Toss_Cursor_Pkg.table_x_frequency_cur INTO table_frequency_rec;
--                            CLOSE Toss_Cursor_Pkg.table_x_frequency_cur;
--
--                            OPEN TOSS_CURSOR_PKG.part_num14_x_frequency0_cur (table_part_rec.objid, table_frequency_rec.objid);
--                               FETCH TOSS_CURSOR_PKG.part_num14_x_frequency0_cur INTO part_num14_x_freq0_rec;
--
--                            IF TOSS_CURSOR_PKG.part_num14_x_frequency0_cur%FOUND THEN
--                               NULL;
--                            ELSE
--                               IF Toss_Util_Pkg.insert_part_num2frequency_fun (
--                               table_part_rec.objid,
--                               table_frequency_rec.objid,
--                               v_procedure_name
--                            ) THEN
--                                 COMMIT;
--                              ELSE
--                                 v_action := 'Failed inserting part_num14_x_freq';
--                                 RAISE failed_insert_part_freq;
--                              END IF;
--
--                            CLOSE TOSS_CURSOR_PKG.part_num14_x_frequency0_cur;
--
--                            END IF;
--
--                         END IF;
--                         IF instr(frequency_string,'-') = 0 THEN
--                            frequency_string := frequency_string||'-';
--                         END IF;
--                      END LOOP;
--                   END IF;

                  FOR r_part_script IN c_part_script (r_get_2xs.objid)
                  LOOP

                     v_action := 'Insert into table_x_part_script';

                     --06/04/03
                     sp_seq('x_part_script',r_seq_part_script_val);

                     INSERT INTO table_x_part_script
                         (OBJID,
                          PART_SCRIPT2PART_NUM,
                          X_SCRIPT_TEXT,
                          X_SEQUENCE,
                          X_TYPE)
                        VALUES(
                             -- 04/10/03 (seq_x_part_script.nextval + (power (2, 28))),
                             -- 06/04/03 seq('x_part_script'),
                             -- 06/04/03 r_seq_part_num.val,
                             r_seq_part_script_val,
                             r_seq_part_num_val,
                             r_part_script.x_script_text,
                             r_part_script.x_sequence,
                             r_part_script.x_type
                          );
                  END LOOP;   /* end of r_part_script loop */


                  v_action := 'Insert Table_Mod_Level - New Part';
                  /* 06/04/03 OPEN c_seq_mod_level;
                  FETCH c_seq_mod_level INTO r_seq_mod_level;
                  CLOSE c_seq_mod_level; */
                  sp_seq('mod_level',r_seq_mod_level_val);


                  INSERT INTO table_mod_level
                              (
                                             objid,
                                             active,
                                             mod_level,
                                             s_mod_level,
                                             eff_date,
                                             x_timetank,
                                             part_info2part_num
                              )
                       VALUES(
                          --06/04/03 r_seq_mod_level.val,
                          r_seq_mod_level_val,
                          'Active',
                          v_revision,
                          UPPER (v_revision),
                          sysdate,
                          0,
                          --06/04/03 r_seq_part_num.val
                          r_seq_part_num_val
                       );


                  -- 06/04/03 v_part_inst2part_mod_1 := r_seq_mod_level.val;
                  v_part_inst2part_mod_1 := r_seq_part_num_val;

               ELSE
                  v_action := 'Update table_part_num';


                  UPDATE table_part_num
                     SET part_type = r_new_item.charge_code,
                         x_manufacturer =
                            substr (r_inv_inbound.tf_manuf_location_name, 1, 20),
                         domain = r_new_item.clfy_domain,
                         s_domain = UPPER (r_new_item.clfy_domain),
                         x_technology = r_new_item.technology,
                         x_upc = r_new_item.upc
                   WHERE domain = r_new_item.clfy_domain
                     AND part_number = r_inv_inbound.tf_part_num_parent;

--                   OPEN Toss_Cursor_Pkg.table_pn_part_cur (r_new_item.part_number);
--                      FETCH Toss_Cursor_Pkg.table_pn_part_cur INTO table_part_rec;
--                   CLOSE Toss_Cursor_Pkg.table_pn_part_cur;

-- Insert frequency records and frequency, part_num swing table records
--
--                   IF upper(r_new_item.frequency) = 'NONE' THEN  -- Frequency doesn't apply.
--                      null;
--                   ELSIF instr(r_new_item.frequency,'-') = 0 THEN -- Only one frequency exists.
--
--                      IF Toss_Util_Pkg.FREQUENCY_EXIST_FUN (
--                         r_new_item.frequency,
--                         v_procedure_name
--                       ) THEN
--
--                         OPEN Toss_Cursor_Pkg.table_x_frequency_cur (
--                           r_new_item.frequency
--                        );
--                            FETCH Toss_Cursor_Pkg.table_x_frequency_cur INTO table_frequency_rec;
--                         CLOSE Toss_Cursor_Pkg.table_x_frequency_cur;
--
--                         OPEN TOSS_CURSOR_PKG.part_num14_x_frequency0_cur (table_part_rec.objid, table_frequency_rec.objid);
--                            FETCH TOSS_CURSOR_PKG.part_num14_x_frequency0_cur INTO part_num14_x_freq0_rec;
--
--                         IF TOSS_CURSOR_PKG.part_num14_x_frequency0_cur%FOUND THEN
--                            NULL;
--                         ELSE
--                            IF Toss_Util_Pkg.insert_part_num2frequency_fun (
--                               table_part_rec.objid,
--                               table_frequency_rec.objid,
--                               v_procedure_name
--                            ) THEN
--                               COMMIT;
--                            ELSE
--                               v_action := 'Failed inserting part_num14_x_freq';
--                               RAISE failed_insert_part_freq;
--                            END IF;
--
--                         END IF;
--
--                         CLOSE TOSS_CURSOR_PKG.part_num14_x_frequency0_cur;
--
--                      ELSE
--
--                         IF Toss_Util_Pkg.INSERT_FREQUENCY_FUN (
--                            r_new_item.frequency,
--                            v_procedure_name
--                          ) THEN
--                            COMMIT;
--                         ELSE
--                            v_action := 'Failed inserting frequency';
--                            RAISE failed_insert_frequency;
--                         END IF;
--
--                         OPEN Toss_Cursor_Pkg.table_x_frequency_cur (
--                           r_new_item.frequency
--                          );
--                            FETCH Toss_Cursor_Pkg.table_x_frequency_cur INTO table_frequency_rec;
--                         CLOSE Toss_Cursor_Pkg.table_x_frequency_cur;
--
--                         OPEN TOSS_CURSOR_PKG.part_num14_x_frequency0_cur (table_part_rec.objid, table_frequency_rec.objid);
--                            FETCH TOSS_CURSOR_PKG.part_num14_x_frequency0_cur INTO part_num14_x_freq0_rec;
--
--                         IF TOSS_CURSOR_PKG.part_num14_x_frequency0_cur%FOUND THEN
--                            NULL;
--                         ELSE
--                            IF Toss_Util_Pkg.insert_part_num2frequency_fun (
--                               table_part_rec.objid,
--                               table_frequency_rec.objid,
--                               v_procedure_name
--                            ) THEN
--                               COMMIT;
--                            ELSE
--                               v_action := 'Failed inserting part_num14_x_freq';
--                               RAISE failed_insert_part_freq;
--                            END IF;
--
--                         END IF;
--
--                         CLOSE TOSS_CURSOR_PKG.part_num14_x_frequency0_cur;
--
--                      END IF;
--
--                   ELSE
--
--                      frequency_string := r_new_item.frequency;
--
--                      WHILE length(frequency_string) > 1 LOOP
--                         frequency_insert := substr(frequency_string,1,instr(frequency_string,'-')-1);
--                         frequency_hold   := substr(frequency_string,instr(frequency_string,'-')+ 1);
--
--                         if frequency_hold is not null then
--                            frequency_string := frequency_hold;
--                         else
--                            frequency_string := '-';
--                         end if;
--
--                         IF Toss_Util_Pkg.FREQUENCY_EXIST_FUN (
--                            frequency_insert,
--                            v_procedure_name
--                          ) THEN
--
--                            OPEN Toss_Cursor_Pkg.table_x_frequency_cur (
--                               frequency_insert);
--
--                               FETCH Toss_Cursor_Pkg.table_x_frequency_cur INTO table_frequency_rec;
--                            CLOSE Toss_Cursor_Pkg.table_x_frequency_cur;
--
--                            OPEN TOSS_CURSOR_PKG.part_num14_x_frequency0_cur (table_part_rec.objid, table_frequency_rec.objid);
--                               FETCH TOSS_CURSOR_PKG.part_num14_x_frequency0_cur INTO part_num14_x_freq0_rec;
--
--                            IF TOSS_CURSOR_PKG.part_num14_x_frequency0_cur%FOUND THEN
--                               NULL;
--                            ELSE
--                               IF Toss_Util_Pkg.insert_part_num2frequency_fun (
--                                  table_part_rec.objid,
--                                  table_frequency_rec.objid,
--                                  v_procedure_name
--                               ) THEN
--                                  COMMIT;
--                               ELSE
--                                  v_action := 'Failed inserting part_num14_x_freq';
--                                  RAISE failed_insert_part_freq;
--                               END IF;
--
--                            END IF;
--
--                            CLOSE TOSS_CURSOR_PKG.part_num14_x_frequency0_cur;
--
--                         ELSE
--
--                          IF Toss_Util_Pkg.INSERT_FREQUENCY_FUN (
--                               frequency_insert,
--                               v_procedure_name
--                            ) THEN
--                              COMMIT;
--                            ELSE
--                               v_action := 'Failed inserting frequency';
--                               RAISE failed_insert_frequency;
--
--                            END IF;
--
--                            OPEN Toss_Cursor_Pkg.table_x_frequency_cur (
--                              frequency_insert
--                             );
--                               FETCH Toss_Cursor_Pkg.table_x_frequency_cur INTO table_frequency_rec;
--                            CLOSE Toss_Cursor_Pkg.table_x_frequency_cur;
--
--                            OPEN TOSS_CURSOR_PKG.part_num14_x_frequency0_cur (table_part_rec.objid, table_frequency_rec.objid);
--                               FETCH TOSS_CURSOR_PKG.part_num14_x_frequency0_cur INTO part_num14_x_freq0_rec;
--
--                            IF TOSS_CURSOR_PKG.part_num14_x_frequency0_cur%FOUND THEN
--                               NULL;
--                            ELSE
--                               IF Toss_Util_Pkg.insert_part_num2frequency_fun (
--                                  table_part_rec.objid,
--                                  table_frequency_rec.objid,
--                                  v_procedure_name
--                               ) THEN
--                                  COMMIT;
--                               ELSE
--                                  v_action := 'Failed inserting part_num14_x_freq';
--                                  RAISE failed_insert_part_freq;
--                               END IF;
--
--                            END IF;
--
--                            CLOSE TOSS_CURSOR_PKG.part_num14_x_frequency0_cur;
--
--                         END IF;
--                         IF instr(frequency_string,'-') = 0 THEN
--                            frequency_string := frequency_string||'-';
--                         END IF;
--                      END LOOP;
--                   END IF;

-- Do not modify the TABLE_MOD_LEVEL for the exsiting ANALOG phones
--                   IF     r_inv_inbound.transceiver_num IS NULL
--                      AND r_inv_inbound.tf_part_type = 'SIM CARDS' THEN
--
--                      OPEN c_mod_level_with_null (r_part_exists.objid);
--                      FETCH c_mod_level_with_null INTO v_part_inst2part_mod_1;
--
--
--                      IF c_mod_level_with_null%NOTFOUND THEN
--
--                         OPEN c_analog_mod (r_part_exists.objid);
--                         FETCH c_analog_mod INTO r_analog_mod;
--
--
--                         IF c_analog_mod%NOTFOUND THEN
--
--                            /* 06/04/03 OPEN c_seq_mod_level;
--                            FETCH c_seq_mod_level INTO r_seq_mod_level;
--                            CLOSE c_seq_mod_level; */
--                            sp_seq('mod_level', r_seq_mod_level_val);
--
--                            v_action := 'Insert Table_Mod_Level - NULL';
--
--
--                            INSERT INTO table_mod_level
--                                        (
--                                                       objid,
--                                                       active,
--                                                       mod_level,
--                                                       s_mod_level,
--                                                       eff_date,
--                                                       x_timetank,
--                                                       part_info2part_num
--                                        )
--                                 VALUES(
--                                    -- 06/04/03 r_seq_mod_level.val,
--                                    r_seq_mod_level_val,
--                                    'Active',
--                                    NULL,
--                                    NULL,
--                                    sysdate,
--                                    0,
--                                    r_part_exists.objid
--                                 );
--
--
--                            -- 06/04/03 v_part_inst2part_mod_1 := r_seq_mod_level.val;
--                            v_part_inst2part_mod_1 := r_seq_mod_level_val;
--                         ELSE
--                            v_part_inst2part_mod_1 := r_analog_mod.objid;
--                         END IF;   --end of ananlog_mod check
--
--                         CLOSE c_analog_mod;
--                      END IF;   --end of mod_level_with_null check
--
--                      CLOSE c_mod_level_with_null;
--                   ELSE

                     OPEN c_mod_level_exists (r_part_exists.objid, v_revision);   --Digital
                     FETCH c_mod_level_exists INTO r_mod_level_exists;   --Digital


                     IF c_mod_level_exists%FOUND THEN

                        v_action := 'Update table_mod_level';


                        UPDATE table_mod_level
                           SET mod_level = v_revision,
                               s_mod_level = UPPER (v_revision),
                               eff_date = sysdate,
                               x_timetank = 0
                         WHERE part_info2part_num = r_part_exists.objid
                           AND active = 'Active'
                           AND mod_level = v_revision;
--Digital

                     ELSE

                        OPEN c_analog_mod (r_part_exists.objid);
                        FETCH c_analog_mod INTO r_analog_mod;


                        IF c_analog_mod%FOUND THEN

                           IF    (r_new_item.technology = 'ANALOG')
                              OR (r_analog_mod.mod_level IS NULL) THEN
                              v_action := 'Update Mod_Level for Existing Analog ESN';


                              UPDATE table_mod_level
                                 SET mod_level = v_revision,
                                     s_mod_level = UPPER (v_revision),
                                     eff_date = sysdate,
                                     x_timetank = 0
                               WHERE objid = r_analog_mod.objid
                                 AND part_info2part_num = r_part_exists.objid
                                 AND active = 'Active';
                           ELSE
                              /* 06/04/03 OPEN c_seq_mod_level;
                              FETCH c_seq_mod_level INTO r_seq_mod_level;
                              CLOSE c_seq_mod_level; */
                              sp_seq('mod_level', r_seq_mod_level_val);

                              v_action := 'Insert Mod_Level - Digital 1 ';


                              INSERT INTO table_mod_level
                                          (
                                                         objid,
                                                         active,
                                                         mod_level,
                                                         s_mod_level,
                                                         eff_date,
                                                         x_timetank,
                                                         part_info2part_num
                                          )
                                   VALUES(
                                      -- 06/04/03 r_seq_mod_level.val,
                                      r_seq_mod_level_val,
                                      'Active',
                                      v_revision,
                                      UPPER (v_revision),
                                      sysdate,
                                      0,
                                      r_part_exists.objid
                                   );
                           END IF;
                        ELSE

                           /* 06/04/03 OPEN c_seq_mod_level;
                           FETCH c_seq_mod_level INTO r_seq_mod_level;
                           CLOSE c_seq_mod_level; */
                           sp_seq('mod_level',r_seq_mod_level_val);

                           v_action := 'Insert Mod_Level - Digital 2';


                           INSERT INTO table_mod_level
                                       (
                                                      objid,
                                                      active,
                                                      mod_level,
                                                      s_mod_level,
                                                      eff_date,
                                                      x_timetank,
                                                      part_info2part_num
                                       )
                                VALUES(
                                   -- 06/04/03 r_seq_mod_level.val,
                                   r_seq_mod_level_val,
                                   'Active',
                                   v_revision,
                                   UPPER (v_revision),
                                   sysdate,
                                   0,
                                   r_part_exists.objid
                                );
                        END IF;   --end analog_mod check

                        CLOSE c_analog_mod;
                     END IF;   /* end of mod level check */

                     CLOSE c_mod_level_exists;
--End Digital

               --   END IF;   /* end of transceiver_num check */
               END IF;   /* end of part number check */

               CLOSE c_part_exists;
--

/********************************************************************************/
/*              Test to see if part exists in the table_part_inst table         */
/*   If part does not exist, insert into part inst and update interface table   */
/*    else if the part exists and the information is from Oracle Financials,    */
/* update part inst and interface tables, otherwise update only interface table */
/********************************************************************************/
               OPEN c_load_mod_level_objid (
                  r_inv_inbound.tf_part_num_parent,
                  v_revision,
                  r_new_item.clfy_domain
               );
               FETCH c_load_mod_level_objid INTO v_part_inst2part_mod_2;
               CLOSE c_load_mod_level_objid;

               OPEN c_load_user_objid;
               FETCH c_load_user_objid INTO r_load_user_objid;
               CLOSE c_load_user_objid;

               OPEN c_load_inv_bin_objid (v_site_id);
               FETCH c_load_inv_bin_objid INTO r_load_inv_bin_objid;
               CLOSE c_load_inv_bin_objid;




                  IF v_dealer_status = '253' THEN
                     OPEN c_load_code_table ('SIM');
                     FETCH c_load_code_table INTO r_load_code_table;
                     CLOSE c_load_code_table;
--                   ELSIF v_dealer_status = '253' THEN
--                      OPEN c_load_code_table ('POSA SIM');
--                      FETCH c_load_code_table INTO r_load_code_table;
--                      CLOSE c_load_code_table;
                  END IF;



               OPEN c_check_part_inst (
                  r_inv_inbound.tf_serial_num--,
              --    r_new_item.clfy_domain
               );
               FETCH c_check_part_inst INTO r_check_part_inst;


 /*              IF     r_inv_inbound.transceiver_num IS NULL
                  AND r_inv_inbound.tf_part_type = 'PHONE' THEN
                  v_part_inst2part_mod := v_part_inst2part_mod_1;
               ELSE*/
                  v_part_inst2part_mod := v_part_inst2part_mod_2;
           --    END IF;


               IF c_check_part_inst%NOTFOUND THEN

                  v_action := 'Insert into table_x_sim_inv';

                  --06/04/03
                  sp_seq('part_inst',v_part_inst_seq);

               --   INSERT INTO table_part_inst
                INSERT INTO table_x_sim_inv
                              (
                                             objid,
                                            x_sim_serial_no, --  part_serial_no,
                                            X_SIM_INV_STATUS, -- x_part_inst_status,
                                           --  x_sequence,
                                            -- x_red_code,
                                            X_SIM_ORDER_NUMBER, -- x_order_number,
                                           --  x_creation_date,
                                            X_CREATED_BY2USER, -- created_by2user,
                                            -- x_domain,
                                            X_SIM_INV2PART_MOD, -- n_part_inst2part_mod,
                                            X_SIM_INV2INV_BIN, -- part_inst2inv_bin,
                                            -- part_status,
                                            X_INV_INSERT_DATE, -- x_insert_date,
                                            X_SIM_STATUS2X_CODE_TABLE, --, -- status2x_code_table,
                                            X_SIM_MNC
                                            -- last_pi_date,
                                             --last_cycle_ct,
                                            -- next_cycle_ct,
                                            -- last_mod_time,
                                            -- last_trans_time,
                                            -- date_in_serv,
                                            -- repair_date
                              )
                       VALUES(
                          v_part_inst_seq,
                          r_inv_inbound.tf_serial_num,
                          v_dealer_status,
                      --    0,
                      --    r_inv_inbound.tf_card_pin_num,
                          r_inv_inbound.tf_order_num,
                      --    v_creation_date,   -- changed from sysdate G.P. 12-15-2000
                          r_load_user_objid.objid,
                        --  r_new_item.clfy_domain,
                          v_part_inst2part_mod,
                          r_load_inv_bin_objid.objid,
                         -- 'Active',
                          r_inv_inbound.creation_date,   --SYSDATE,
                          r_load_code_table.objid,
                          v_mnc
                          /*,
                          TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                          TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                          TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                          TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                          TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                          TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                          TO_DATE ('01-01-1753', 'DD-MM-YYYY')*/
                       );
--Moved code here in order to distinguish from Insert or Update, G.P 12/20/2000
                  v_action := 'Update tf_toss_interface_table 1';


                  UPDATE tf.tf_toss_interface_table@OFSPRD
                     SET toss_extract_flag = 'YES',
                         toss_extract_date = sysdate,
                         last_update_date = sysdate,
                        last_updated_by = v_procedure_name
                   WHERE rowid = r_inv_inbound.rowid;
               /** new branch for refurb phones **/
               --ELSE
--                ELSIF     r_new_item.clfy_domain = 'PHONES'
--                           AND (r_inv_inbound.toss_extract_flag = 'NOR'
--                           OR r_inv_inbound.toss_extract_flag = 'NOA'
--                           OR r_inv_inbound.toss_extract_flag = 'NOV') THEN
--
--                     IF     r_inv_inbound.toss_extract_flag = 'NOR' THEN
--
--                         /*         serial_invalid_date, serial_valid_insert_date,
--              TF_PHONE_REFURB_DATE*/
--                         v_reset_date := r_inv_inbound.TF_PHONE_REFURB_DATE;
--                         v_reset_action_type := 'REFURBISHED';
--
--                     ELSIF r_inv_inbound.toss_extract_flag = 'NOA' THEN
--
--                         v_reset_date := r_inv_inbound.serial_valid_insert_date;
--                         v_reset_action_type := 'REPAIRED';
--
--                     ELSIF r_inv_inbound.toss_extract_flag = 'NOV' THEN
--
--                            v_reset_date := r_inv_inbound.serial_invalid_date;
--                         v_reset_action_type := 'UNREPAIRABLE';
--
--                     END IF;
--
--
--                /* evaluate if if was succesfully reset */
--                IF NOT sa.reset_esn_fun (
--                      r_inv_inbound.tf_serial_num,
--                      v_reset_date,
--                      r_inv_inbound.tf_order_num,
--                      r_load_user_objid.objid,
--                      v_part_inst2part_mod,
--                      r_load_inv_bin_objid.objid,
--                      v_reset_action_type,
--                      v_dealer_status,
--                      v_procedure_name,
--                                v_creation_date  -- 01/30/03 Change
--                  )
--               THEN
--                   /** UPDATE OUTSIDE THE RESET FUN becuase it failed */
--                   UPDATE table_part_inst
--                      SET --x_creation_date = v_reset_date, -- 01/30/03 Change
--                          x_creation_date = v_creation_date, -- 01/30/03 Change
--                          x_order_number = r_inv_inbound.tf_order_num,
--                          created_by2user = r_load_user_objid.objid,
--                          last_pi_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--                          last_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--                          next_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--                          last_mod_time = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--                          last_trans_time = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--                          date_in_serv = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--                          repair_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--                          n_part_inst2part_mod = v_part_inst2part_mod,
--                          part_inst2inv_bin = r_load_inv_bin_objid.objid
--                    WHERE x_domain = 'PHONES'
--                      AND part_serial_no = r_inv_inbound.tf_serial_num;
--
--                     -- RAISE refurb_exp;
--                --ELSE
--
--                   END IF;
--
--                   /* NOw go ahead and update regardless if the phone was */
--                   /* refurb of not. Other data was updated anyway        */
--                      v_action := 'Update tf_toss_interface_table refurbs';
--
--
--                      UPDATE tf.tf_toss_interface_table@OFSPRD
--                         SET toss_extract_flag = 'YES',
--                             toss_extract_date = sysdate,
--                             last_update_date = sysdate,
--                             last_updated_by = v_procedure_name
--                       WHERE rowid = r_inv_inbound.rowid;
                 -- END IF;
               ELSE




                        v_action := 'Update table_x_sim_inv ';

                        /* NOW CHECK IF there has been a posa transaction*/
                        /* against this serial_num (assumption here is:  */
                        /* if there was a swipe or unswipe or multiple combi */
                        /* nations of this events.. the phone was,is and will */
                        /* be a posa phone and it should remain a posa card   */

--                         OPEN posa_check_cur(r_inv_inbound.tf_serial_num);
--                         FETCH posa_check_cur INTO posa_check_rec;
--
--                         IF posa_check_cur%FOUND THEN
--                                /* leave the status unchanged */
--                                /* posa transaction exists */
--                                v_dealer_status :=
--                                           r_check_part_inst.x_part_inst_status;
--
--                                /* get the status2x_code_table objid for */
--                                /* this newly reset status               */
--                                 IF v_dealer_status = '50' THEN
--                                  OPEN c_load_code_table ('PHONES');
--                                  FETCH c_load_code_table INTO r_load_code_table;
--                                  CLOSE c_load_code_table;
--                                 ELSIF v_dealer_status = '59' THEN
--                                  OPEN c_load_code_table ('POSA PHONES');
--                                  FETCH c_load_code_table INTO r_load_code_table;
--                                  CLOSE c_load_code_table;
--                                 END IF;
--
--                         END IF;
--                         CLOSE posa_check_cur;


                        UPDATE table_x_sim_inv
                           SET
                           --x_part_inst_status =
                             --     DECODE (
                                --     x_part_inst_status,
                                --     '50', v_dealer_status,   --new
                                     --'59',
                            X_SIM_INV_STATUS =         v_dealer_status,   --new
                                --     x_part_inst_status
                               --   ),
                             --  status2x_code_table =
                                 -- DECODE (
                                   --  x_part_inst_status,
                                    -- '50', r_load_code_table.objid,   --new
                                    -- '59',
                               X_SIM_STATUS2X_CODE_TABLE=     r_load_code_table.objid,   --new
                                    -- status2x_code_table
                                 -- ),
                         --      x_creation_date = v_creation_date,   -- changed from sysdate G.P. 12-15-2000
                              -- x_order_number
                              X_SIM_ORDER_NUMBER = r_inv_inbound.tf_order_num,
                               --created_by2user
                              X_CREATED_BY2USER = r_load_user_objid.objid,
                           --    x_domain = r_new_item.clfy_domain,
--                          x_insert_date        = SYSDATE,
--                                last_pi_date =
--                                   TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--                                last_cycle_ct =
--                                   TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--                                next_cycle_ct =
--                                   TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--                                last_mod_time =
--                                   TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--                                last_trans_time =
--                                   TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--                                date_in_serv =
--                                   TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--                                repair_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               --n_part_inst2part_mod
                               X_SIM_INV2PART_MOD = v_part_inst2part_mod,   --part_exists_rec.objid,
                              -- part_inst2inv_bin =
                              X_SIM_INV2INV_BIN = r_load_inv_bin_objid.objid,
                              X_SIM_MNC  = v_mnc
                         WHERE X_SIM_SERIAL_NO = r_inv_inbound.tf_serial_num;
                        --   AND x_domain = r_new_item.clfy_domain;








/* Moved code here in order to distinguish from Insert or Update, G.P 12/20/2000 */
                  v_action := 'Update tf_toss_interface_table 2';


                  UPDATE tf.tf_toss_interface_table @OFSPRD
                     SET toss_extract_flag = 'YES',
                         toss_extract_date = sysdate,
                         last_update_date = sysdate,
                         last_updated_by = v_procedure_name
                   WHERE rowid = r_inv_inbound.rowid;
               END IF;   /* end of part id check */

               CLOSE c_check_part_inst;
/** Now update the table_site_part.site_part2part_info **/
--                OPEN c_check_active_sp (r_inv_inbound.tf_serial_num);
--                FETCH c_check_active_sp INTO r_check_active_sp;
--
--
--                IF c_check_active_sp%FOUND THEN
--
--                   OPEN c_mod_level (r_inv_inbound.tf_part_num_parent);
--                   FETCH c_mod_level INTO r_mod_level;
--                   CLOSE c_mod_level;
--
--
--                   UPDATE table_site_part sp
--                      SET site_part2part_info = r_mod_level.objid
--                    WHERE sp.rowid = r_check_active_sp.rowid;
--
--                   CLOSE c_check_active_sp;
--                END IF;



               COMMIT;


            ELSE

               RAISE no_site_id_exp;
            END IF;   /* end of site_id existence check */

         EXCEPTION
            WHEN validate_exp THEN

                                      TOSS_UTIL_PKG.insert_error_tab_proc (
        v_out_action, --ip_action     IN   VARCHAR2,
        v_serial_num, --ip_key        IN   VARCHAR2,
        v_procedure_name, --ip_program_name IN VARCHAR2,
        'Inner Block Error '--ip_error_text  IN VARCHAR2 DEFAULT NULL
        );

--                INSERT INTO ERROR_TABLE
--                            (error_text, error_date, action, key, program_name)
--                     VALUES(
--                        'Inner Block Error ' || v_out_error,
--                        sysdate,
--                        v_out_action,
--                        v_serial_num,
--                        v_procedure_name
--                     );




               COMMIT;

            WHEN refurb_exp THEN

                   NULL;


               COMMIT;

            WHEN no_site_id_exp THEN
              TOSS_UTIL_PKG.insert_error_tab_proc (
              v_out_action || ' NO SITE ID', --ip_action     IN   VARCHAR2,
              v_serial_num, --ip_key        IN   VARCHAR2,
              v_procedure_name, --ip_program_name IN VARCHAR2,
             'Inner Block Error '--ip_error_text  IN VARCHAR2 DEFAULT NULL
            );



             WHEN distributed_trans_time_out   THEN
                TOSS_UTIL_PKG.insert_error_tab_proc (
                 v_out_action ||  ' Caught distributed_trans_time_out', --ip_action     IN   VARCHAR2,
                v_serial_num, --ip_key        IN   VARCHAR2,
                v_procedure_name, --ip_program_name IN VARCHAR2,
               'Inner Block Error '--ip_error_text  IN VARCHAR2 DEFAULT NULL
              );




            WHEN record_locked  THEN
               TOSS_UTIL_PKG.insert_error_tab_proc (
                v_out_action ||  ' Caught distributed_trans_time_out', --ip_action     IN   VARCHAR2,
                v_serial_num, --ip_key        IN   VARCHAR2,
                v_procedure_name, --ip_program_name IN VARCHAR2,
                'Inner Block Error '--ip_error_text  IN VARCHAR2 DEFAULT NULL
              );



            WHEN OTHERS THEN
               v_err_text := sqlerrm;


             TOSS_UTIL_PKG.insert_error_tab_proc (
             'Inner Block Error -When others' , --ip_action     IN   VARCHAR2,
              v_serial_num, --ip_key        IN   VARCHAR2,
              v_procedure_name
             );




         END;

         /** cleaning up **/
         IF c_site_id%ISOPEN THEN
            CLOSE c_site_id;
         END IF;


         IF c_new_item%ISOPEN THEN
            CLOSE c_new_item;
         END IF;


         IF c_get_domain_objid%ISOPEN THEN
            CLOSE c_get_domain_objid;
         END IF;


         /* 06/04/03 IF c_seq_part_num%ISOPEN THEN
            CLOSE c_seq_part_num;
         END IF; */


         IF c_get_2xs%ISOPEN THEN
            CLOSE c_get_2xs;
         END IF;


         /* 06/04/03 IF c_seq_mod_level%ISOPEN THEN
            CLOSE c_seq_mod_level;
         END IF; */


         IF c_mod_level_with_null%ISOPEN THEN
            CLOSE c_mod_level_with_null;
         END IF;


         IF c_mod_level_exists%ISOPEN THEN
            CLOSE c_mod_level_exists;
         END IF;


         IF c_part_exists%ISOPEN THEN
            CLOSE c_part_exists;
         END IF;


         IF c_load_mod_level_objid%ISOPEN THEN
            CLOSE c_load_mod_level_objid;
         END IF;


         IF c_load_user_objid%ISOPEN THEN
            CLOSE c_load_user_objid;
         END IF;


         IF c_load_inv_bin_objid%ISOPEN THEN
            CLOSE c_load_inv_bin_objid;
         END IF;


         IF c_load_code_table%ISOPEN THEN
            CLOSE c_load_code_table;
         END IF;


         IF c_check_part_inst%ISOPEN THEN
            CLOSE c_check_part_inst;
         END IF;


         IF c_analog_mod%ISOPEN THEN
            CLOSE c_analog_mod;
         END IF;


         IF c_check_active_sp%ISOPEN THEN
            CLOSE c_check_active_sp;
         END IF;


         IF c_mod_level%ISOPEN THEN
            CLOSE c_mod_level;
         END IF;

         IF posa_check_cur%ISOPEN THEN
            CLOSE posa_check_cur;
         END IF;

         COMMIT;
         /* Reset v_mnc */
         v_mnc := NULL;

      END LOOP;   /* end of r_inv_inbound loop */

   COMMIT;



  IF toss_util_pkg.insert_interface_jobs_fun (
         v_procedure_name,
         v_start_date,
         SYSDATE,
         v_recs_processed,
         'SUCCESS',
         v_procedure_name
      )
   THEN
      COMMIT;
   END IF;


EXCEPTION
             WHEN failed_insert_frequency   THEN

               TOSS_UTIL_PKG.insert_error_tab_proc (
                   v_out_action, --ip_action     IN   VARCHAR2,
                   v_serial_num, --ip_key        IN   VARCHAR2,
                   v_procedure_name, --ip_program_name IN VARCHAR2,
                   ' error inserting frequency'--ip_error_text  IN VARCHAR2 DEFAULT NULL
               );

               COMMIT;

             WHEN failed_insert_part_freq   THEN

               TOSS_UTIL_PKG.insert_error_tab_proc (
                   v_out_action, --ip_action     IN   VARCHAR2,
                   v_serial_num, --ip_key        IN   VARCHAR2,
                   v_procedure_name, --ip_program_name IN VARCHAR2,
                   ' error inserting part_num frequency swing'--ip_error_text  IN VARCHAR2 DEFAULT NULL
               );

               COMMIT;

             WHEN distributed_trans_time_out   THEN



               TOSS_UTIL_PKG.insert_error_tab_proc (
                   v_out_action, --ip_action     IN   VARCHAR2,
                   v_serial_num, --ip_key        IN   VARCHAR2,
                   v_procedure_name, --ip_program_name IN VARCHAR2,
                   ' Caught distributed_trans_time_out'--ip_error_text  IN VARCHAR2 DEFAULT NULL
               );

               COMMIT;


               IF toss_util_pkg.insert_interface_jobs_fun (
                  v_procedure_name,
                  v_start_date,
                  SYSDATE,
                  v_recs_processed,
                  'FAILED',
                  v_procedure_name
                )
               THEN
                 COMMIT;
               END IF;


            WHEN record_locked  THEN

              TOSS_UTIL_PKG.insert_error_tab_proc (
                v_out_action, --ip_action     IN   VARCHAR2,
                v_serial_num, --ip_key        IN   VARCHAR2,
                v_procedure_name, --ip_program_name IN VARCHAR2,
                ' Caught record_locked'--ip_error_text  IN VARCHAR2 DEFAULT NULL
                 );


              IF toss_util_pkg.insert_interface_jobs_fun (
                  v_procedure_name,
                  v_start_date,
                  SYSDATE,
                  v_recs_processed,
                  'FAILED',
                  v_procedure_name
               )
               THEN
                 COMMIT;
               END IF;



   WHEN OTHERS THEN
      v_err_text := sqlerrm;


        TOSS_UTIL_PKG.insert_error_tab_proc (
                v_out_action, --ip_action     IN   VARCHAR2,
                v_serial_num, --ip_key        IN   VARCHAR2,
                v_procedure_name
        );


        IF toss_util_pkg.insert_interface_jobs_fun (
             v_procedure_name,
             v_start_date,
             SYSDATE,
             v_recs_processed,
             'FAILED',
             v_procedure_name
        )
        THEN
             COMMIT;
        END IF;


END INBOUND_SIM_INV_PRC;
/