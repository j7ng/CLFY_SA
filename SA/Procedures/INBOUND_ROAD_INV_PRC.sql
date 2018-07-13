CREATE OR REPLACE PROCEDURE sa."INBOUND_ROAD_INV_PRC"
AS
/******************************************************************************/
/* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved              */
/*                                                                            */
/* Name         :   sp_inbound_inv_road_prc.sql                               */
/* Purpose      :   To extract roadside CARDS inventory data from             */
/*                  TF_TOSS_INTERFACE_TA                                      */
/*                  BLE in Oracle                                             */
/*                  Financials into TOSS and update the interface table onc   */
/*                  the extract is done                                       */
/*                                                                            */
/* Parameters   :   NONE                                                      */
/* Platforms    :   Oracle 8.0.6 AND newer versions                           */
/* Author      :   Miguel Leon                                                */
/* Date         :   02/25/2002                                                */
/* Revisions   :                                                              */
/* Version  Date      Who     Purpose                                         */
/* -------  --------  ------- ----------------------------------------------- */
/* 1.0     02/25/2002 Mleon   Initial revision                                */
/*                                                                            */
/* 1.1     05/31/2002 VAdapa  Specified columns in insert script to table_    */
/*                            x_part_script                                   */
/*                                                                            */
/* 1.2     09/11/2002 Mleon   Included functionality to invalidate and or     */
/*                            validate roadside cards(NOV and NOA). Change im */
/*                            plicit inserts into ERROR table to use the inser*/
/*                            error_table_prc from toss_util_pkg. Also replace*/
/*                            updates into the interface table jobs to insert */
/*                            a new record. Also clean up any old commented   */
/*                            out sections.                                   */
/*                            Commented out related to phones and changed mod */
/*                            level update/insrt logic  ALso included new     */
/*                            features as:                                    */
/*                            1. Update toss_redemption_code with x_part_inst */
/*                               status.                                      */
/*                            2. Update toss_extract_date with time stamp     */
/*                            3. Removed 'P' extract flag from main cursor    */
/* 1.3     04/10/03   SL      Clarify Upgrade - sequence                      */
/* 1.4     06/04/03   SL      Bug fix-open cursor and ora-164                 */
/*                                                                            */
/******************************************************************************/
   v_action VARCHAR2 (4000) := ' ';
   v_err_text VARCHAR2 (4000);
   v_dealer_status VARCHAR2 (20);
   v_serial_num VARCHAR2 (50);
   v_revision VARCHAR2 (10);
   v_part_inst2part_mod NUMBER;
   v_part_inst2part_mod_1 NUMBER;
   v_part_inst2part_mod_2 NUMBER;
   v_part_inst_seq NUMBER; --06/04/03
   v_creation_date DATE;
   v_site_id VARCHAR2 (80);
   validate_exp EXCEPTION;
   v_out_action VARCHAR2 (50);
   v_out_error VARCHAR2 (4000);
   v_dealer_valid_date DATE;
   refurb_exp EXCEPTION;   -- new
   no_site_id_exp EXCEPTION;
   v_procedure_name VARCHAR2 (50) := 'INBOUND_ROAD_INV_PRC';
   v_recs_processed NUMBER := 0;
   v_start_date DATE := SYSDATE;
   v_smp_status VARCHAR2(20);
   v_redemp_code VARCHAR2(20);
--

/* Cursor to extract CARDS data from TF_TOSS_INTERFACE_TABLE via database link*/
   CURSOR c_inv_inbound
   IS
      SELECT   /*+ RULE */a.ROWID, tf_part_num_parent, tf_part_num_transpose,
             toss_extract_flag, tf_serial_num, tf_part_type,
             tf_card_pin_num, transceiver_num, tf_manuf_location_code,
             tf_manuf_location_name, tf_ff_location_code,
             tf_ret_location_code, tf_order_num, creation_date,
             created_by, ff_receive_date, retailer_ship_date,
             serial_invalid_date, serial_valid_insert_date
        FROM tf.tf_toss_interface_table@ofsprdl1 a
       WHERE toss_extract_flag IN ('NO', 'NEWR', 'D2', 'NOV','NOA')
         AND tf_part_type || '' = 'CARDS'
         AND EXISTS(SELECT NULL
                      FROM tf_item_v@ofsprdl1
                     WHERE part_number = tf_part_num_parent
                       AND domain = 'ROADSIDE'
                       AND part_assignment = 'PARENT');
/* EXPLAIN PLAN
SELECT STATEMENT    [HINT: RULE] Cost=0 Rows=0 Bytes=0
  CONCATENATION
    FILTER
      TABLE ACCESS BY INDEX ROWID TF_TOSS_INTERFACE_TABLE  [ANALYZED]
        INDEX RANGE SCAN TF_TOSS_INTERFACE_TABLE_N6
      SORT GROUP BY
        MERGE JOIN OUTER
          FILTER
            MERGE JOIN OUTER
              SORT JOIN
                NESTED LOOPS
                  NESTED LOOPS
                    NESTED LOOPS
                      NESTED LOOPS
                        NESTED LOOPS
                          TABLE ACCESS FULL FND_ID_FLEX_STRUCTURES  [ANALYZED]
                          INDEX RANGE SCAN MTL_ITEM_CATEGORIES_U1  [ANALYZED]
                            COUNT STOPKEY
                              TABLE ACCESS FULL MTL_PARAMETERS  [ANALYZED]
                        TABLE ACCESS BY INDEX ROWID MTL_CATEGORIES_B  [ANALYZED]
                          INDEX UNIQUE SCAN MTL_CATEGORIES_B_U1  [ANALYZED]
                      TABLE ACCESS BY INDEX ROWID MTL_SYSTEM_ITEMS_B  [ANALYZED]
                        INDEX UNIQUE SCAN MTL_SYSTEM_ITEMS_B_U1  [ANALYZED]
                    TABLE ACCESS BY INDEX ROWID MTL_CATEGORY_SETS_TL  [ANALYZED]
                      INDEX RANGE SCAN MTL_CATEGORY_SETS_TL_U1  [ANALYZED]
                  TABLE ACCESS BY INDEX ROWID MTL_CATEGORY_SETS_B  [ANALYZED]
                    INDEX UNIQUE SCAN MTL_CATEGORY_SETS_B_U1  [ANALYZED]
              SORT JOIN
                TABLE ACCESS FULL MTL_RELATED_ITEMS  [ANALYZED]
          SORT JOIN
            VIEW
              FILTER
                SORT GROUP BY
                  NESTED LOOPS
                    NESTED LOOPS
                      INDEX UNIQUE SCAN MTL_CROSS_REFERENCE_TYPES_U1  [ANALYZED]
                      TABLE ACCESS BY INDEX ROWID MTL_CROSS_REFERENCES  [ANALYZED]
                        INDEX RANGE SCAN MTL_CROSS_REFERENCES_U1  [ANALYZED]
                    TABLE ACCESS BY INDEX ROWID MTL_CROSS_REFERENCES  [ANALYZED]
                      INDEX RANGE SCAN MTL_CROSS_REFERENCES_N1  [ANALYZED]
    FILTER
      TABLE ACCESS BY INDEX ROWID TF_TOSS_INTERFACE_TABLE  [ANALYZED]
        INDEX RANGE SCAN TF_TOSS_INTERFACE_TABLE_N6
      SORT GROUP BY
        MERGE JOIN OUTER
          FILTER
            MERGE JOIN OUTER
              SORT JOIN
                NESTED LOOPS
                  NESTED LOOPS
                    NESTED LOOPS
                      NESTED LOOPS
                        NESTED LOOPS
                          TABLE ACCESS FULL FND_ID_FLEX_STRUCTURES  [ANALYZED]
                          INDEX RANGE SCAN MTL_ITEM_CATEGORIES_U1  [ANALYZED]
                            COUNT STOPKEY
                              TABLE ACCESS FULL MTL_PARAMETERS  [ANALYZED]
                        TABLE ACCESS BY INDEX ROWID MTL_CATEGORIES_B  [ANALYZED]
                          INDEX UNIQUE SCAN MTL_CATEGORIES_B_U1  [ANALYZED]
                      TABLE ACCESS BY INDEX ROWID MTL_SYSTEM_ITEMS_B  [ANALYZED]
                        INDEX UNIQUE SCAN MTL_SYSTEM_ITEMS_B_U1  [ANALYZED]
                    TABLE ACCESS BY INDEX ROWID MTL_CATEGORY_SETS_TL  [ANALYZED]
                      INDEX RANGE SCAN MTL_CATEGORY_SETS_TL_U1  [ANALYZED]
                  TABLE ACCESS BY INDEX ROWID MTL_CATEGORY_SETS_B  [ANALYZED]
                    INDEX UNIQUE SCAN MTL_CATEGORY_SETS_B_U1  [ANALYZED]
              SORT JOIN
                TABLE ACCESS FULL MTL_RELATED_ITEMS  [ANALYZED]
          SORT JOIN
            VIEW
              FILTER
                SORT GROUP BY
                  NESTED LOOPS
                    NESTED LOOPS
                      INDEX UNIQUE SCAN MTL_CROSS_REFERENCE_TYPES_U1  [ANALYZED]
                      TABLE ACCESS BY INDEX ROWID MTL_CROSS_REFERENCES  [ANALYZED]
                        INDEX RANGE SCAN MTL_CROSS_REFERENCES_U1  [ANALYZED]
                    TABLE ACCESS BY INDEX ROWID MTL_CROSS_REFERENCES  [ANALYZED]
                      INDEX RANGE SCAN MTL_CROSS_REFERENCES_N1  [ANALYZED]
*/






/* Cursor to extract new item information from TF_ITEM_V view via database
   link*/
   CURSOR c_new_item (c_ip_part_no IN VARCHAR2)
   IS
      SELECT *
        FROM tf.tf_item_v@ofsprdl1
       WHERE part_number = c_ip_part_no;


   r_new_item c_new_item%ROWTYPE;
   r_transpose c_new_item%ROWTYPE;   --new item
--

/* Cursor to extract TOSS dealer id based on Financials Customer Id */
   CURSOR c_site_id (c_ip_fin_cust_id IN VARCHAR2)
   IS
      SELECT site_id
        FROM table_site
       WHERE TYPE = 3
         AND x_fin_cust_id = c_ip_fin_cust_id;


   r_site_id c_site_id%ROWTYPE;
--

/* Cursor to get the part domain object id */
   CURSOR c_get_domain_objid (c_ip_domain IN VARCHAR2)
   IS
      SELECT objid
        FROM table_prt_domain
       WHERE name = c_ip_domain;


   r_get_domain_objid c_get_domain_objid%ROWTYPE;
--

/* Cursor to get the part number object id */
   CURSOR c_part_exists (c_ip_domain2 IN VARCHAR2,  c_ip_part_number IN VARCHAR2)
   IS
      SELECT objid
        FROM table_part_num
       WHERE part_number = c_ip_part_number
         AND part_num2domain = c_ip_domain2;


   r_part_exists c_part_exists%ROWTYPE;
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


   r_mod_level_exists c_mod_level_exists%ROWTYPE;
--

/* Cursor to get part number's programmable flag and DLL info */
   CURSOR c_get_2xs (c_ip_serno IN VARCHAR2)
   IS
      SELECT a.objid, a.x_dll, a.x_programmable_flag
--         FROM table_part_num a, table_mod_level b, table_road_inst c

        FROM table_part_num a, table_mod_level b, table_x_road_inst c
       WHERE a.objid = b.part_info2part_num
--          AND b.objid = c.n_part_inst2part_mod

         AND b.objid = c.n_road_inst2part_mod
         AND c.part_serial_no = c_ip_serno;


   r_get_2xs c_get_2xs%ROWTYPE;
--

/* Cursor to generate an object id for new part script */
/* 06/04/03   CURSOR c_seq_part_script
   IS
      -- 04/10/03 SELECT seq_x_part_script.nextval + (POWER (2, 28)) val
        select sa.seq('x_part_script') val
        FROM dual;

   r_seq_part_script c_seq_part_script%ROWTYPE; */
   r_seq_part_script_val number; --06/04/03
--

/* Cursor to generate object id for new part number */
/* 06/04/03  CURSOR c_seq_part_num
   IS
      -- 04/10/03 SELECT seq_part_num.nextval + (POWER (2, 28)) val
        select sa.seq('part_num') val
        FROM dual;

   r_seq_part_num c_seq_part_num%ROWTYPE; */
   r_seq_part_num_val number; --06/04/03
--

/* Cursor to generate object id for new mod level */
/*  CURSOR c_seq_mod_level
   IS
      -- 04/10/03 SELECT seq_mod_level.nextval + (POWER (2, 28)) val
        select sa.seq('mod_level') val
        FROM dual;
   r_seq_mod_level c_seq_mod_level%ROWTYPE; */
   r_seq_mod_level_val number; --06/04/03
--

/* Cursor to get script info for the part number */
   CURSOR c_part_script (c_ip_ps2pn IN NUMBER)
   IS
      SELECT x_type, x_sequence, x_script_text
        FROM table_x_part_script
       WHERE part_script2part_num = c_ip_ps2pn;


   r_part_script c_part_script%ROWTYPE;
--

/* Cursor to get user object id --> Looks for other users, G.P 12-27-2000 */
   CURSOR c_load_user_objid
   IS
      SELECT objid
        FROM table_user
       WHERE login_name = 'ORAFIN';


   r_load_user_objid c_load_user_objid%ROWTYPE;
--

/* Cursor to get bin object id */
   CURSOR c_load_inv_bin_objid (c_ip_customer_id IN VARCHAR2)
   IS
      SELECT objid
        FROM table_inv_bin
       WHERE bin_name = c_ip_customer_id;


   r_load_inv_bin_objid c_load_inv_bin_objid%ROWTYPE;
--

/* Cursor to get code object id */

   CURSOR c_load_code_table (c_ip_domain4 IN VARCHAR2)
   IS
      SELECT objid
        FROM table_x_code_table
       WHERE x_code_number =
                DECODE (
                   c_ip_domain4,
                   'POSA CARDS', '45',
                   'INVALIDATE CARD', '44',
                   'ROADSIDE', '42'
                );


   r_load_code_table c_load_code_table%ROWTYPE;
--

/* Cursor to check if the serial number exists in part_inst table */
   CURSOR c_check_part_inst (
      c_ip_serial_number   IN   VARCHAR2,
      c_ip_domain5         IN   VARCHAR2
   )
   IS
      SELECT *
        FROM table_x_road_inst
       WHERE part_serial_no = c_ip_serial_number
         AND x_domain = c_ip_domain5;


   r_check_part_inst c_check_part_inst%ROWTYPE;
--

/* Cursor to get part number object id associated with the revision of
   the part number */
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


   r_load_mod_level_objid c_load_mod_level_objid%ROWTYPE;
--

/* Cursor to check whether mod_level exists for the given part number
   with NULL revision */
   CURSOR c_mod_level_with_null (c_ip_pn_objid IN NUMBER)
   IS
      SELECT objid
        FROM table_mod_level
       WHERE part_info2part_num = c_ip_pn_objid
         AND active = 'Active'
         AND mod_level IS NULL;


   r_mod_level_with_null c_mod_level_with_null%ROWTYPE;
--

/*********************NEW CODE STARTS (Miguel Leon's Changes)******************/
/* new cursor that selects part_serial_no from part_inst table where the statu*/
/* = (41)'REDEEMED', the site_type "DIST" & "MANF" and for the domain 'CARD'  */
/******************************************************************************/
   CURSOR c_check_red_card (c_ip_serial_number IN VARCHAR2)
   IS
      SELECT 'X'
      FROM table_x_road_inst txri,
             table_inv_bin tib,
             table_inv_role tir,
             table_site ts
       WHERE txri.part_serial_no = c_ip_serial_number
         AND txri.x_domain = 'ROADSIDE'
         AND txri.x_part_inst_status = '41'   --REDEEMED
         AND txri.road_inst2inv_bin = tib.objid
         AND tib.inv_bin2inv_locatn = tir.inv_role2inv_locatn
         AND tir.inv_role2site = ts.objid
         AND ts.site_type IN ('DIST',  'MANF');


   r_check_red_card c_check_red_card%ROWTYPE;
/*************************************NEW CODE ENDS****************************/

/* cursor to get the active record from the table_site_part */
   CURSOR c_check_active_sp (ip_esn IN VARCHAR2)
   IS
      SELECT ROWID
        FROM table_site_part sp
       WHERE x_service_id = ip_esn
         AND part_status = 'Active';


   r_check_active_sp c_check_active_sp%ROWTYPE;
/*  get mod level cursor */
   CURSOR c_mod_level (c_ip_part_number IN VARCHAR2)
   IS
      SELECT a.objid
        FROM table_mod_level a, table_part_num b
       WHERE a.part_info2part_num = b.objid
         AND a.active = 'Active'
         AND b.part_number = c_ip_part_number;


   r_mod_level c_mod_level%ROWTYPE;
/* Cursor to check if there has been a posa transaction */
   CURSOR posa_check_cur (ip_smp VARCHAR2)
   IS
      SELECT 'X'
        FROM x_posa_road
       WHERE tf_serial_num = ip_smp;


   posa_check_rec posa_check_cur%ROWTYPE;

   processed_counter NUMBER := 0;
   inner_counter NUMBER := 0;


/* BEGIN OF MAIN */
BEGIN

   FOR r_inv_inbound IN c_inv_inbound
   LOOP

      v_recs_processed := v_recs_processed + 1;


      BEGIN
         v_serial_num := r_inv_inbound.tf_serial_num;
         v_site_id := NULL;
         v_creation_date := NULL;
         v_dealer_status := NULL;
         v_part_inst2part_mod_1 := NULL;
         v_part_inst2part_mod_2 := NULL;
         v_dealer_valid_date := NULL;
         v_smp_status := NULL;
         v_redemp_code := NULL;


         IF r_inv_inbound.tf_ret_location_code IS NOT NULL
         THEN
            OPEN c_site_id (r_inv_inbound.tf_ret_location_code);
            FETCH c_site_id INTO v_site_id;
            CLOSE c_site_id;

            v_creation_date := r_inv_inbound.retailer_ship_date;

         ELSIF r_inv_inbound.tf_ff_location_code IS NOT NULL
         THEN
            OPEN c_site_id (r_inv_inbound.tf_ff_location_code);
            FETCH c_site_id INTO v_site_id;
            CLOSE c_site_id;

            v_creation_date := r_inv_inbound.ff_receive_date;

         ELSIF r_inv_inbound.tf_manuf_location_code IS NOT NULL
         THEN
            OPEN c_site_id (r_inv_inbound.tf_manuf_location_code);
            FETCH c_site_id INTO v_site_id;
            CLOSE c_site_id;

            v_creation_date := r_inv_inbound.creation_date;
         END IF;


         IF v_site_id IS NOT NULL
         THEN

            OPEN c_new_item (r_inv_inbound.tf_part_num_parent);
            FETCH c_new_item INTO r_new_item;
            CLOSE c_new_item;

            v_revision := r_new_item.redeem_units;


            IF r_new_item.part_subtype = 'POSA'
            THEN
               v_dealer_status := '45';
            ELSIF r_new_item.part_subtype = 'NPOSA'
            THEN
               v_dealer_status := '42';
            ELSE
               v_dealer_status := NULL;
            END IF;
--                END IF;
            v_action := ' ';
--

/******************************************************************************/
/*          Test to see if part number exists in the table_part_num table     */
/*  If the part number does not exist, insert into part num, table_script an  */
/*          mod_level tables,else update the part num and mod level tables    */
/******************************************************************************/

/* Get the domain object id */
            OPEN c_get_domain_objid (r_new_item.domain);
            FETCH c_get_domain_objid INTO r_get_domain_objid;
            CLOSE c_get_domain_objid;
/* Get the part sequence number */
            OPEN c_part_exists (
               r_get_domain_objid.objid,
               r_inv_inbound.tf_part_num_parent
            );
            FETCH c_part_exists INTO r_part_exists;


            IF c_part_exists%NOTFOUND
            THEN

               /* 06/04/03 OPEN c_seq_part_num;
               FETCH c_seq_part_num INTO r_seq_part_num;
               CLOSE c_seq_part_num;*/
               sp_seq('part_num',r_seq_part_num_val);

               OPEN c_get_2xs (r_inv_inbound.tf_serial_num);
               FETCH c_get_2xs INTO r_get_2xs;
               CLOSE c_get_2xs;

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
                                          x_upc
                           )
                    VALUES(
                       --06/04/03 r_seq_part_num.val,
                       r_seq_part_num_val,
                       'Active',
                       r_inv_inbound.tf_part_num_parent,
                       UPPER (r_inv_inbound.tf_part_num_parent),
                       r_new_item.description,
                       r_new_item.card_type,
                       SUBSTR (r_inv_inbound.tf_manuf_location_name, 1, 20),
                       r_new_item.domain,
                       r_new_item.redeem_days,
                       r_new_item.redeem_units,
                       r_get_domain_objid.objid,
                       UPPER (r_new_item.description),
                       UPPER (r_new_item.domain),
                       r_new_item.dll,
                       r_new_item.programming_flag,
                       r_new_item.technology,
                       r_new_item.upc
                    );


               FOR r_part_script IN c_part_script (r_get_2xs.objid)
               LOOP

                  v_action := 'Insert into table_x_part_script';

                  --06/04/03
                  sp_seq('x_part_script',r_seq_part_script_val);

                  INSERT INTO table_x_part_script
                              (
                                             objid,
                                             part_script2part_num,
                                             x_script_text,
                                             x_sequence,
                                             x_type
                              )
                       VALUES(
                          -- 06/04/03 sa.seq('x_part_script'),  --04/10/03
                          r_seq_part_script_val,
                          -- 06/04/03 r_seq_part_num.val,
                          r_seq_part_num_val,
                          r_part_script.x_script_text,
                          r_part_script.x_sequence,
                          r_part_script.x_type
                       );
               END LOOP;   /* end of r_part_script loop */


               v_action := 'Insert Table_Mod_Level - New Part';
               /* 06/04/03 OPEN c_seq_mod_level;
               FETCH c_seq_mod_level INTO r_seq_mod_level;
               CLOSE c_seq_mod_level;*/
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
                       -- 06/04/03 r_seq_mod_level.val,
                       r_seq_mod_level_val,
                       'Active',
                       v_revision,
                       UPPER (v_revision),
                       SYSDATE,
                       0,
                       --06/04/03 r_seq_part_num.val
                       r_seq_part_num_val
                    );


               -- 06/04/03 v_part_inst2part_mod_1 := r_seq_mod_level.val;
               v_part_inst2part_mod_1 := r_seq_mod_level_val;
            ELSE
               v_action := 'Update table_part_num';


               UPDATE table_part_num
                  SET part_type = r_new_item.card_type,
                      x_manufacturer =
                         SUBSTR (r_inv_inbound.tf_manuf_location_name, 1, 20),
                      domain = r_new_item.domain,
                      s_domain = UPPER (r_new_item.domain),
                      x_technology = r_new_item.technology,
                      x_upc = r_new_item.upc
                WHERE domain = r_new_item.domain
                  AND part_number = r_inv_inbound.tf_part_num_parent;


               OPEN c_mod_level_exists (r_part_exists.objid, v_revision);
               FETCH c_mod_level_exists INTO r_mod_level_exists;


               IF c_mod_level_exists%FOUND
               THEN

                  v_action := 'Update table_mod_level';


                  UPDATE table_mod_level
                     SET mod_level = v_revision,
                         s_mod_level = UPPER (v_revision),
                         eff_date = SYSDATE,
                         x_timetank = 0
                   WHERE part_info2part_num = r_part_exists.objid
                     AND active = 'Active'
                     AND mod_level = v_revision;
               ELSE

                  OPEN c_mod_level_with_null (r_part_exists.objid);
                  FETCH c_mod_level_with_null INTO r_mod_level_with_null;


                  IF c_mod_level_with_null%FOUND
                  THEN
                     v_action := 'Update Mod_Level - Existing Part with NULL revision for NULL revision';


                     UPDATE table_mod_level
                        SET mod_level = v_revision,
                            s_mod_level = UPPER (v_revision),
                            eff_date = SYSDATE,
                            x_timetank = 0
                      WHERE objid = r_mod_level_with_null.objid;
                  ELSE
                     /* 06/04/03 OPEN c_seq_mod_level;
                     FETCH c_seq_mod_level INTO r_seq_mod_level;
                     CLOSE c_seq_mod_level; */
                     sp_seq('mod_level',r_seq_mod_level_val);

                     v_action := 'Insert Mod_Level - Existing Part with NULL revision ';


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
                             SYSDATE,
                             0,
                             r_part_exists.objid
                          );
                  END IF;

                  CLOSE c_mod_level_with_null;

               END IF;   /* end of mod level check */

               CLOSE c_mod_level_exists;

--End Digital
--
--                   END IF;   /* end of transceiver_num check */

            END IF;   /* end of part number check */

            CLOSE c_part_exists;
--

/******************************************************************************/
/*              Test to see if part exists in the table_road_inst table       */
/*   If part does not exist, insert into part inst and update interface table */
/*    else if the part exists and the information is from Oracle Financials,  */
/* update part inst and interface tables, otherwise update only interface tabl*/
/******************************************************************************/
            OPEN c_load_mod_level_objid (
               r_inv_inbound.tf_part_num_parent,
               v_revision,
               r_new_item.domain
            );
            FETCH c_load_mod_level_objid INTO v_part_inst2part_mod_2;
            CLOSE c_load_mod_level_objid;

            OPEN c_load_user_objid;
            FETCH c_load_user_objid INTO r_load_user_objid;
            CLOSE c_load_user_objid;

            OPEN c_load_inv_bin_objid (v_site_id);
            FETCH c_load_inv_bin_objid INTO r_load_inv_bin_objid;
            CLOSE c_load_inv_bin_objid;

            IF v_dealer_status = '42'
            THEN
               OPEN c_load_code_table ('ROADSIDE');
               FETCH c_load_code_table INTO r_load_code_table;
               CLOSE c_load_code_table;
            ELSIF v_dealer_status = '45'
            THEN
               OPEN c_load_code_table ('POSA CARDS');
               FETCH c_load_code_table INTO r_load_code_table;
               CLOSE c_load_code_table;
            END IF;


            OPEN c_check_part_inst (
               r_inv_inbound.tf_serial_num,
               r_new_item.domain
            );
            FETCH c_check_part_inst INTO r_check_part_inst;

            v_part_inst2part_mod := v_part_inst2part_mod_2;

            IF c_check_part_inst%NOTFOUND
            THEN
--Cycle Count Changes -
               IF r_inv_inbound.serial_valid_insert_date IS NOT NULL
               THEN
                  v_creation_date := r_inv_inbound.creation_date;
               ELSIF r_inv_inbound.serial_invalid_date IS NOT NULL
               THEN
                  v_creation_date := r_inv_inbound.creation_date;
                  v_dealer_status := '44';
                  OPEN c_load_code_table ('INVALIDATE CARD');
                  FETCH c_load_code_table INTO r_load_code_table;
                  CLOSE c_load_code_table;
               END IF;
--End Cycle Count Changes

               v_action := 'Insert into table_road_inst';
               --06/04/03
               sp_seq('part_inst', v_part_inst_seq);

               INSERT INTO table_x_road_inst
                           (
                                          objid,
                                          part_serial_no,
                                          x_part_inst_status,
                                          x_sequence,
                                          x_red_code,
                                          x_order_number,
                                          x_creation_date,
                                          rd_create2user,
                                          x_domain,
                                          n_road_inst2part_mod,
                                          road_inst2inv_bin,
                                          part_status,
                                          x_insert_date,
                                          rd_status2x_code_table,
                                          x_hist_update   --stupid approach

                           )
                    VALUES(
                       -- 06/04/03 seq('part_inst'), --04/10/03
                       v_part_inst_seq,
                       r_inv_inbound.tf_serial_num,
                       v_dealer_status,
                       0,
                       r_inv_inbound.tf_card_pin_num,
                       r_inv_inbound.tf_order_num,
                       v_creation_date,   -- changed from sysdate G.P. 12-15-2000
                       r_load_user_objid.objid,
                       r_new_item.domain,
                       v_part_inst2part_mod,
                       r_load_inv_bin_objid.objid,
                       'Active',
                       r_inv_inbound.creation_date,   --SYSDATE,
                       r_load_code_table.objid,   --,
                       1   --meaning do not fire the trigger
                    );
--Moved code here in order to distinguish from Insert or Update, G.P 12/20/2000
               v_action := 'Update tf_toss_interface_table 1';

               v_redemp_code := v_dealer_status; --new


               UPDATE tf.tf_toss_interface_table@ofsprdl1
                  SET toss_extract_flag = 'YES',
                      toss_extract_date = SYSDATE,
                      toss_redemption_code =  v_redemp_code, --new
                      last_update_date = SYSDATE,
                      last_updated_by = v_procedure_name
                WHERE ROWID = r_inv_inbound.ROWID;
            ELSE

               v_smp_status := r_check_part_inst.x_part_inst_status;  -- new

               OPEN c_check_red_card (r_inv_inbound.tf_serial_num);
               FETCH c_check_red_card INTO r_check_red_card;


               IF c_check_red_card%NOTFOUND
               THEN   /* continue as before */
/***********************NEW CODE ENDS (Miguel Leon's Changes)******************/
/** For cards:                                                                */
/** Distributor / Manufacturer site_id will be replaced by the corre  dealerid*/
/** always since now all the cards will have a generic dealer id with the     */
/** new card generation process.                                              */
/******************************************************************************/

--Cycle Count Changes - VAdapa 11/26/01
                  IF     r_new_item.domain = 'ROADSIDE'
                         AND r_inv_inbound.toss_extract_flag = 'NOV'
                         AND r_inv_inbound.serial_invalid_date IS NOT NULL
                  THEN

                     OPEN c_load_code_table ('INVALIDATE CARD');
                     FETCH c_load_code_table INTO r_load_code_table;
                     CLOSE c_load_code_table;

                     v_dealer_status  := '44';  --new


                     IF NOT load_road_hist_fun (
                           r_new_item.domain,
                           r_inv_inbound.tf_serial_num,
                           v_dealer_status, --new
                          -- '44',
                           r_load_code_table.objid,
                           r_load_inv_bin_objid.objid,
                           v_part_inst2part_mod,
                           'INVALIDATE',
                           v_out_action,
                           v_out_error
                        )
                     THEN

                        RAISE validate_exp;
                     END IF;

                  ELSIF     r_new_item.domain = 'ROADSIDE'
                         AND r_inv_inbound.toss_extract_flag = 'NOA'
                         AND r_inv_inbound.serial_valid_insert_date IS NOT NULL

                  THEN

                     IF NOT load_road_hist_fun (
                           r_new_item.domain,
                           r_inv_inbound.tf_serial_num,
                           v_dealer_status,
                           r_load_code_table.objid,
                           r_load_inv_bin_objid.objid,
                           v_part_inst2part_mod,
                           'REVALIDATE',
                           v_out_action,
                           v_out_error
                        )
                     THEN

                        RAISE validate_exp;
                     END IF;
--End Cycle Count Changes

                  ELSE

                     v_action := 'Update table_x_road_inst 1';
                     /* NOW CHECK IF there has been a posa transaction*/
                     /* against this serial_num (assumption here is:  */
                     /* if there was a swipe or unswipe or multiple combi */
                     /* nations of this events.. the card was,is and will */
                     /* be a posa roadside card and it should remain a posa */
                     /* roadside card   */
                     OPEN posa_check_cur (r_inv_inbound.tf_serial_num);
                     FETCH posa_check_cur INTO posa_check_rec;


                     IF posa_check_cur%FOUND
                     THEN
                        /* leave the status unchanged */
                        /* posa transaction exists */
                        v_dealer_status := r_check_part_inst.x_part_inst_status;

                        /* get the status2x_code_table objid for */
                        /* this newly reset status               */
                        IF v_dealer_status = '42'
                        THEN
                           OPEN c_load_code_table ('ROADSIDE');
                           FETCH c_load_code_table INTO r_load_code_table;
                           CLOSE c_load_code_table;
                        ELSIF v_dealer_status = '45'
                        THEN
                           OPEN c_load_code_table ('POSA CARDS');
                           FETCH c_load_code_table INTO r_load_code_table;
                           CLOSE c_load_code_table;
                        END IF;
                     END IF;

                     CLOSE posa_check_cur;


                     UPDATE table_x_road_inst
                        SET x_part_inst_status =
                               DECODE (
                                  x_part_inst_status,
                                  '45', v_dealer_status,
                                  '42', v_dealer_status,
                                  x_part_inst_status
                               ),
                            rd_status2x_code_table =
                               DECODE (
                                  x_part_inst_status,
                                  '45', r_load_code_table.objid,
                                  '42', r_load_code_table.objid,
                                  rd_status2x_code_table
                               ),
                            x_creation_date = v_creation_date,   -- changed from sysdate G.P. 12-15-2000
                            x_order_number = r_inv_inbound.tf_order_num,
                            rd_create2user = r_load_user_objid.objid,
                            x_domain = r_new_item.domain,
                            x_insert_date = SYSDATE,
                            repair_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            n_road_inst2part_mod = v_part_inst2part_mod,
                            road_inst2inv_bin = r_load_inv_bin_objid.objid,
                            x_hist_update = 1   --meaning do not fire trigger
                      WHERE part_serial_no = r_inv_inbound.tf_serial_num
                        AND x_domain = r_new_item.domain;
                  END IF;   /* end of validate  check */
/***********************NEW CODE STARTS (Miguel Leon's Changes)*****************/
/* Update card's dealer ID and RED_DATE to SYSDATE  */

               ELSE

                  v_action := 'Update table_x_road_inst 2';
                  UPDATE table_x_road_inst
                     SET road_inst2inv_bin = r_load_inv_bin_objid.objid,
                         x_creation_date = v_creation_date,
                         n_road_inst2part_mod = v_part_inst2part_mod,
                         x_order_number = r_inv_inbound.tf_order_num,
                         x_hist_update = 1   --meaning do not fire trigger
                   WHERE part_serial_no = r_inv_inbound.tf_serial_num
                     AND x_domain = r_new_item.domain;
--11/08/01  VAdapa
--Do the retailer validate date update only if SMP is associated with a retailer
                  IF r_inv_inbound.tf_ret_location_code IS NOT NULL
                  THEN
                     v_dealer_valid_date := SYSDATE;

--Update the status of validated SMP in X_ROAD_INVALID_REDEMPTION table
                     v_action := 'Update x_road_invalid_redemption';


                     UPDATE x_road_invalid_redemption
                        SET valid_dealer = 'Y',
                            validated_date = v_dealer_valid_date
                      WHERE part_serial_no = r_inv_inbound.tf_serial_num
                        AND valid_dealer = 'N';
                  END IF;   /* end of retailer association check */
--

               END IF;   /* end of redeemed card check */

               CLOSE c_check_red_card;
/***********************NEW CODE ENDS (Miguel Leon's Changes)******************/




/*
Update toss_redemption_code to '42' or '45' if it is new, '44' if it is invali
dated, else update with the x_part_inst_status
*/


              IF  (v_smp_status IN ('42','45')) OR
                   ((v_smp_status <> '41')
                   AND (r_inv_inbound.toss_extract_flag in ('NOA','NOV')) ) THEN

                v_redemp_code   := v_dealer_status;

              ELSE
                v_redemp_code    := v_smp_status;
              END IF;


               v_action := 'Update tf_toss_interface_table 2';


               UPDATE tf.tf_toss_interface_table@ofsprdl1
                  SET toss_extract_flag = 'YES',
                      toss_extract_date = SYSDATE,
                      last_update_date = SYSDATE,
                      toss_redemption_code = v_redemp_code, --new
                      last_updated_by = v_procedure_name
                WHERE ROWID = r_inv_inbound.ROWID;
            END IF;   /* end of part id check */

            CLOSE c_check_part_inst;


            COMMIT;


         ELSE   /* new skip status on tf_toss_interface */

            COMMIT;
            RAISE no_site_id_exp;
         END IF;   /* end of site_id existence check */

      EXCEPTION
         WHEN validate_exp
         THEN

            TOSS_UTIL_PKG.insert_error_tab_proc (
       v_out_action, --ip_action     IN   VARCHAR2,
       v_serial_num, --ip_key        IN   VARCHAR2,
       v_procedure_name, --ip_program_name IN VARCHAR2,
       'Inner Block Error ' || v_out_error--ip_error_text  IN VARCHAR2 DEFAULT NULL
   );



         WHEN refurb_exp
         THEN


                     TOSS_UTIL_PKG.insert_error_tab_proc (
       v_out_action, --ip_action     IN   VARCHAR2,
       v_serial_num, --ip_key        IN   VARCHAR2,
       v_procedure_name, --ip_program_name IN VARCHAR2,
       'Inner Block Error ' || v_out_error--ip_error_text  IN VARCHAR2 DEFAULT NULL
   );


         WHEN no_site_id_exp
         THEN

                     TOSS_UTIL_PKG.insert_error_tab_proc (
       v_out_action|| '::NO SITE ID', --ip_action     IN   VARCHAR2,
       v_serial_num, --ip_key        IN   VARCHAR2,
       v_procedure_name, --ip_program_name IN VARCHAR2,
       'Inner Block Error ' || v_out_error--ip_error_text  IN VARCHAR2 DEFAULT NULL
   );



         WHEN OTHERS
         THEN
            v_err_text := SQLERRM;
                        TOSS_UTIL_PKG.insert_error_tab_proc (
                            v_out_action, --ip_action     IN   VARCHAR2,
                            v_serial_num, --ip_key        IN   VARCHAR2,
                            v_procedure_name, --ip_program_name IN VARCHAR2,
                            'Inner Block Error ' || v_err_text--ip_error_text  IN VARCHAR2 DEFAULT NULL
                            );


      END;

      /** cleaning up **/
      IF c_site_id%ISOPEN
      THEN
         CLOSE c_site_id;
      END IF;


      IF c_new_item%ISOPEN
      THEN
         CLOSE c_new_item;
      END IF;


      IF c_get_domain_objid%ISOPEN
      THEN
         CLOSE c_get_domain_objid;
      END IF;


      /* 06/04/03 IF c_seq_part_num%ISOPEN
      THEN
         CLOSE c_seq_part_num;
      END IF; */


      IF c_get_2xs%ISOPEN
      THEN
         CLOSE c_get_2xs;
      END IF;


      /* 06/04/03 IF c_seq_mod_level%ISOPEN
      THEN
         CLOSE c_seq_mod_level;
      END IF; */


      IF c_mod_level_with_null%ISOPEN
      THEN
         CLOSE c_mod_level_with_null;
      END IF;


      IF c_mod_level_exists%ISOPEN
      THEN
         CLOSE c_mod_level_exists;
      END IF;


      IF c_part_exists%ISOPEN
      THEN
         CLOSE c_part_exists;
      END IF;


      IF c_load_mod_level_objid%ISOPEN
      THEN
         CLOSE c_load_mod_level_objid;
      END IF;


      IF c_load_user_objid%ISOPEN
      THEN
         CLOSE c_load_user_objid;
      END IF;


      IF c_load_inv_bin_objid%ISOPEN
      THEN
         CLOSE c_load_inv_bin_objid;
      END IF;


      IF c_load_code_table%ISOPEN
      THEN
         CLOSE c_load_code_table;
      END IF;


      IF c_check_red_card%ISOPEN
      THEN
         CLOSE c_check_red_card;
      END IF;


      IF c_check_part_inst%ISOPEN
      THEN
         CLOSE c_check_part_inst;
      END IF;


      IF c_check_active_sp%ISOPEN
      THEN
         CLOSE c_check_active_sp;
      END IF;


      IF c_mod_level%ISOPEN
      THEN
         CLOSE c_mod_level;
      END IF;


      IF posa_check_cur%ISOPEN
      THEN
         CLOSE posa_check_cur;
      END IF;

      COMMIT;
   END LOOP;   /* end of r_inv_inbound loop */

   COMMIT;


   IF toss_util_pkg.insert_interface_jobs_fun (
         v_procedure_name,
         v_start_date,
         SYSDATE,
         v_recs_processed,
         'SUCESS',
         v_procedure_name
      )
   THEN
      COMMIT;
   END IF;

EXCEPTION

   WHEN DUP_VAL_ON_INDEX
   THEN


      TOSS_UTIL_PKG.insert_error_tab_proc (
        v_out_action, --ip_action     IN   VARCHAR2,
        v_serial_num, --ip_key        IN   VARCHAR2,
        v_procedure_name, --ip_program_name IN VARCHAR2,
        'Duplicate Value on index'--ip_error_text  IN VARCHAR2 DEFAULT NULL
        );
--       INSERT INTO error_table
--                   (error_text, error_date, action, key, program_name)
--            VALUES(
--               'Duplicate Value on index',
--               SYSDATE,
--               v_action,
--               v_serial_num,
--               'SA.SP_INBOUND_INV_ROAD_PRC'
--            );
--
--       COMMIT;


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

   WHEN OTHERS
   THEN
      --v_err_text := SQLERRM;


--       INSERT INTO error_table
--                   (error_text, error_date, action, key, program_name)
--            VALUES(
--               v_err_text,
--               SYSDATE,
--               v_action,
--               v_serial_num,
--               'SA.SP_INBOUND_INV_ROAD_PRC'
--            );
--
--       COMMIT;

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
END inbound_road_inv_prc;
/