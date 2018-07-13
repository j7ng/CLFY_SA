CREATE OR REPLACE PROCEDURE sa."INBOUND_PHONE_OTHER_INV_TMP"
AS
/*********************************************************************************/
/* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved                 */
/*                                                                               */
/* Name         :   inbound_phone_other_inv_tmp (formerly known as SP)           */
/* Purpose      :   To extract PHONE inventory data from TF_TOSS_INTERFACE_TA    */
/*                  BLE in Oracle                                                */
/*                  Financials into TOSS and update the interface table once     */
/*                  the extract is done                                          */
/*                                                                               */
/* Parameters   :   NONE                                                         */
/* Platforms    :   Oracle 8.0.6 AND newer versions                              */
/* Author      :   Miguel Leon                                                   */
/* Date         :   01/25/2001                                                   */
/* Revisions   :                                                                 */
/* Version  Date      Who      Purpose                                           */
/* -------  --------  -------  ----------------------------------------------    */
/* 1.0      01/25/2001 Mleon   Initial revision                                  */
/*                             CR2155_02 NOA NOV NOR                             */
/* 1.1      02/16/04   VAdapa  Changes for PSE  projects                         */
/* 1.2      04/07/04   VAdapa  Fix for MT45917                                   */
/* 1.3      04/07/04   VAdapa  CR2549 - Modified to accept value from            */
/*                             OFS for Exchange Type                             */
/* 1.4      12/27/04   Vadapa  CR3190 - Assign x_restricted_use to '3'           */
/*                             for NET10 phones                                  */
/* 1.8      04/07/05   VA      CR3886 - Increase column length in Clarify        */
/*                             mod_level table (MT64889)                         */
/* 1.9      10/13/05   GP      CR4659 - Removed logic that inserts new part_nums */
/* 1.10     11/22/05   VA      CR4799 - Clarify Reset Logic                      */
/* 1.11     11/22/05   VA      Fix for CR4799
/* 1.12     03/10/06   VA      CR4981_4982 Logic added to add information for DATA phones and CONVERSION rates
/* 1.13     04/10/06   VA      CR4981_4982 - Added an insert into table_x_ota_features
/* 1.14     05/17/06   va      Same version as in CLFYUPGQ
/* 1.15     05/17/06   va      Modified the database link to ofsprd
/* 1.16     06/01/06   VA      Short code - 31778
/* 1.17     06/08/06   VA      CR5349 - Fix for OPEN_CURSORS
/* 1.18     06/26/06   VA      CRdataE
/* 1.19     08/16/06   GP      CR5461 - Using TF partNumber transpose
/* 1.20     08/30/06   VA      CR5461- Changed the database link
/* 1.21     09/11/06   VA      CR5484 - LG 3280 (Assumption : Any esn with dll >= 21 will be preloaded with OTA features)
/* 1.23     10/11/06   GP      CR5575 - Get transpose UPC if not null
/* 1.24     10/12/06   VA      CR5553
/* 1.25     11/28/06   VA     CR5835
/* 1.26     05/15/07   TZ     CR5565 Phone Software Release -
                                Set PART_MOD in table_part_inst from TOSS_CHANGED_RETAILER_NAME in tf_toss_interface_phone_inv.
/*********************************************************************************/
   --   l_action                VARCHAR2 (50)                  := ' ';
   --   l_err_text               VARCHAR2 (4000);
   --   l_inv_status          VARCHAR2 (20);
   --   l_serial_num             VARCHAR2 (50);
   --   l_revision               VARCHAR2 (10);
   --   l_creation_date          DATE;
   --   l_part_inst2part_mod     NUMBER;
   --   l_site_id                VARCHAR2 (80);
   --   l_out_action             VARCHAR2 (50);
   --   l_procedure_name VARCHAR2(80) := 'INBOUND_INV_PHONE_PRC';
   --   l_recs_processed          NUMBER                 := 0;
   --   l_start_date              DATE                   := SYSDATE;
   ----FROM NEW C -------------------------------------------
   --Local Variables
   l_action                        VARCHAR2 (100)                      := ' ';
   l_err_text                      VARCHAR2 (4000);
   l_inv_status                    VARCHAR2 (20);
   l_serial_num                    VARCHAR2 (50);
   --CR3886 Start
   --   l_revision VARCHAR2 (10);
   l_inner_excep_flag              BOOLEAN                           := FALSE;
   l_revision                      VARCHAR2 (20);
   -- CR3886 Ends
   l_part_inst2part_mod            NUMBER;
   l_creation_date                 DATE;
   l_site_id                       VARCHAR2 (80);
   l_out_action                    VARCHAR2 (50);
   l_out_error                     VARCHAR2 (4000);
   l_procedure_name                VARCHAR2 (80)
                                            := '.inbound_phone_other_inv_tmp';
   l_recs_processed                NUMBER                                := 0;
   l_start_date                    DATE                            := SYSDATE;
   l_commit_counter                NUMBER                                := 0;
   l_out_error                     VARCHAR2 (4000);
   l_dealer_valid_date             DATE;
   l_reset_date                    DATE;
   l_reset_action_type             VARCHAR2 (80);
   l_part_inst2part_mod_1          NUMBER;
   l_part_inst2part_mod_2          NUMBER;
   l_part_inst_seq                 NUMBER;
   l_upd_pi_status                 VARCHAR2 (20);
   l_upd_pi_status_code_objid      NUMBER;
   --PSE
   l_promo_objid                   NUMBER;
   l_replacement_parts             VARCHAR2 (4000);
   l_tilde_pos                     NUMBER                                := 0;
   l_indv_replace_part             VARCHAR2 (4000);
   l_priority                      NUMBER                                := 0;
   l_seq_exch_options_val          NUMBER;
   l_source_part                   NUMBER;
   --End PSE
   --CR2549 Changes
   l_warranty_parts                VARCHAR2 (4000);
   l_warranty_tilde_pos            NUMBER                                := 0;
   l_indv_warranty_part            VARCHAR2 (4000);
   l_warranty_priority             NUMBER                                := 0;
   --End CR2549 Changes
   l_restricted_use                NUMBER                                := 0;
   --CR3190
   --l_reset                         CHAR (1)                            := 'T';
                                                                     --CR4799
   --CR4981_4982 start
   l_data_phone                    NUMBER;
   l_ota_seq                       NUMBER;
   l_conv_rate                     NUMBER;

   CURSOR c_get_ota_features (pi_objid IN NUMBER)
   IS
      SELECT 'X'
        FROM table_x_ota_features
       WHERE x_ota_features2part_inst = pi_objid;

   r_get_ota_features              c_get_ota_features%ROWTYPE;

   CURSOR c_get_pi_objid (p_esn IN VARCHAR2)
   IS
      SELECT objid
        FROM table_part_inst
       WHERE part_serial_no = p_esn;

   r_get_pi_objid                  c_get_pi_objid%ROWTYPE;
   --CR4981_4982 end
   --EXCEPTIONS Variables
   refurb_exp1                     EXCEPTION;
   refurb_exp2                     EXCEPTION;
   refurb_exp3                     EXCEPTION;
--   refurb_exp4                     EXCEPTION;                        --CR4799
   no_site_id_exp                  EXCEPTION;
   no_part_num_exp                 EXCEPTION;                       -- CR4659
   distributed_trans_time_out      EXCEPTION;
   record_locked                   EXCEPTION;
   validate_exp                    EXCEPTION;
   ------------- LOCAL VARIABLES TO AVOID UNNECESSARY TRIPS ---------
   l_previous_part_number          VARCHAR2 (100);
   l_current_part_number           VARCHAR2 (100);
   l_previous_part_num_transpose   VARCHAR2 (100);
   l_current_part_num_transpose    VARCHAR2 (100);
   l_previous_transceiver_num      VARCHAR2 (100);
   l_current_transceiver_num       VARCHAR2 (100);
   --
   l_current_retailer              VARCHAR2 (100);
   l_previuos_retailer             VARCHAR2 (100);
   --
   l_current_ff_center             VARCHAR2 (100);
   l_previuos_ff_center            VARCHAR2 (100);
   --
   l_current_manf                  VARCHAR2 (100);
   l_previuos_manf                 VARCHAR2 (100);
   --------FROM NEW C END ----------------------------------
   -- Motorola Digital variables
   frequency_string                VARCHAR2 (1000);
   frequency_hold                  VARCHAR2 (1000);
   frequency_insert                VARCHAR2 (1000);
   part_num14_x_freq0_rec          mtm_part_num14_x_frequency0%ROWTYPE;
   table_frequency_rec             table_x_frequency%ROWTYPE;
   table_part_rec                  table_part_num%ROWTYPE;
   table_x_default_rec             table_x_default_preload%ROWTYPE;
   failed_insert_frequency         EXCEPTION;
   failed_insert_part_freq         EXCEPTION;
   --
   PRAGMA EXCEPTION_INIT (distributed_trans_time_out, -2049);
   PRAGMA EXCEPTION_INIT (record_locked, -54);

   --
   /* Cursor to extract PHONES/CARDS data from TF_TOSS_INTERFACE_TABLE via database link*/
   CURSOR inv_cur
   IS
      SELECT   /*+ RULE */
               ROWID, tf_part_num_parent, tf_part_num_transpose,
               transceiver_num, tf_manuf_location_code, tf_ff_location_code,
               tf_ret_location_code, toss_extract_flag, tf_serial_num,
               tf_part_type, tf_card_pin_num, tf_manuf_location_name,
               tf_order_num, creation_date, created_by, ff_receive_date,
               retailer_ship_date, serial_invalid_date,
               toss_changed_retailer_name,                          --CR5565
               serial_valid_insert_date, tf_phone_refurb_date
          FROM tf.tf_toss_interface_table@ofsprd
         WHERE toss_extract_flag IN ('NOR', 'NOA', 'NOV')
and tf_serial_num = '07407969334'
           AND tf_part_type || '' = 'PHONE'
           AND NOT EXISTS (
                  SELECT 1
                    FROM tf.tf_of_item_v@ofsprd iv
                   WHERE part_number = tf_part_num_parent
                     AND clfy_domain = 'SIM CARDS'
                     AND part_assignment = 'PARENT')
      ORDER BY tf_part_num_parent,
               tf_part_num_transpose,
               transceiver_num,
               tf_ret_location_code,
               tf_ff_location_code,
               tf_manuf_location_code;

   /* Cursor to extract new item information from TF_ITEM_V view via database link*/
   CURSOR item_cur (part_no_in IN VARCHAR2)
   IS
      SELECT *
        FROM tf.tf_of_item_v@ofsprd
       WHERE part_number = part_no_in;

   item_rec                        item_cur%ROWTYPE;
   r_transpose                     item_cur%ROWTYPE;
   r_chkitempromo                  item_cur%ROWTYPE;

   /* Cursor to extract TOSS dealer id based on Financials Customer Id */
   CURSOR site_id_cur (c_ip_fin_cust_id IN VARCHAR2)
   IS
      SELECT site_id
        FROM table_site
       WHERE TYPE = 3 AND x_fin_cust_id = c_ip_fin_cust_id;

   site_id_rec                     site_id_cur%ROWTYPE;

   --
   /* Cursor to get the part domain object id */
   CURSOR domain_objid_cur (c_ip_domain IN VARCHAR2)
   IS
      SELECT objid
        FROM table_prt_domain
       WHERE NAME = c_ip_domain;

   domain_objid_rec                domain_objid_cur%ROWTYPE;

   --
   /* Cursor to get the part number object id */
   CURSOR part_exists_cur (
      c_ip_domain2       IN   VARCHAR2,
      c_ip_part_number   IN   VARCHAR2
   )
   IS
      SELECT objid
        FROM table_part_num
       WHERE part_number = c_ip_part_number AND part_num2domain = c_ip_domain2;

   part_exists_rec                 part_exists_cur%ROWTYPE;

   --

   /* Cursor to get the mod_level information for the given part number */--Digital
   CURSOR mod_level_exists_cur (
      c_ip_part_num_objid   IN   VARCHAR2,
      c_ip_revision         IN   VARCHAR2
   )
   IS
      SELECT objid
        FROM table_mod_level
       WHERE part_info2part_num = c_ip_part_num_objid
         AND active = 'Active'
         AND mod_level = c_ip_revision;

   mod_level_exists_rec            mod_level_exists_cur%ROWTYPE;

   --
   /* Cursor to get part number's programmable flag and DLL info */
   --    CURSOR get_2xs_cur (c_ip_serno IN VARCHAR2)
   --    IS
   --       SELECT a.objid, a.x_dll, a.x_programmable_flag
   --         FROM table_part_num a, table_mod_level b, table_part_inst c
   --        WHERE a.objid = b.part_info2part_num
   --          AND b.objid = c.n_part_inst2part_mod
   --          AND c.part_serial_no = c_ip_serno;
   --
   --
   --    get_2xs_rec                get_2xs_cur%ROWTYPE;
   --PSE
   --    CURSOR get_2xs_cur (part_number_ip IN VARCHAR2)
   --    IS
   --       SELECT a.objid, a.x_dll, a.x_programmable_flag
   --         FROM table_part_num a
   --        WHERE part_number = part_number_ip;
   CURSOR get_2xs_cur (ip_dll IN NUMBER, ip_tech IN VARCHAR2)
   IS
      SELECT pn.objid, pn.part_num2part_class, pn.part_num2default_preload
        FROM table_part_class pc, table_part_num pn
       WHERE pc.NAME = pn.part_number
         AND pn.x_dll = ip_dll
         AND pn.x_technology = ip_tech;

   --End PSE
   get_2xs_rec                     get_2xs_cur%ROWTYPE;
   l_seq_part_script_val           NUMBER;
   l_seq_part_num_val              NUMBER;
   l_seq_mod_level_val             NUMBER;

   /* Cursor to get script info for the part number */
   CURSOR part_script_cur (c_ip_ps2pn IN NUMBER)
   IS
      SELECT x_type, x_sequence, x_script_text, x_language
        FROM table_x_part_script
       WHERE part_script2part_num = c_ip_ps2pn;

   part_script_rec                 part_script_cur%ROWTYPE;

   --
   /* Cursor to get user object id --> Looks for other users, G.P 12-27-2000 */
   CURSOR user_objid_cur
   IS
      SELECT objid
        FROM table_user
       WHERE login_name = 'ORAFIN';

   user_objid_rec                  user_objid_cur%ROWTYPE;

   --

   /* Cursor to get bin object id */
   CURSOR inv_bin_objid_cur (c_ip_customer_id IN VARCHAR2)
   IS
      SELECT objid
        FROM table_inv_bin
       WHERE bin_name = c_ip_customer_id;

   inv_bin_objid_rec               inv_bin_objid_cur%ROWTYPE;

   --
   /* Cursor to get code object id */
   /* added POSA PHONES            */
   CURSOR status_code_objid_cur (c_ip_domain4 IN VARCHAR2)
   IS
      SELECT objid
        FROM table_x_code_table
       WHERE x_code_number =
                    DECODE (c_ip_domain4,
                            'PHONES', '50',
                            'POSA PHONES', '59'
                           );

   status_code_objid_rec           status_code_objid_cur%ROWTYPE;

   --
   /* Cursor to check if the serial number exists in part_inst table */
   CURSOR check_part_inst_cur (
      c_ip_serial_number   IN   VARCHAR2,
      c_ip_domain5         IN   VARCHAR2
   )
   IS
      SELECT *
        FROM table_part_inst
       WHERE part_serial_no = c_ip_serial_number AND x_domain = c_ip_domain5;

   check_part_inst_rec             check_part_inst_cur%ROWTYPE;

   --
   /* Cursor to get part number object id associated with the revision of the part number */
   CURSOR mod_level_objid_cur (
      c_ip_part_number   IN   VARCHAR2,
      c_ip_revision      IN   VARCHAR2,
      c_ip_domain        IN   VARCHAR2
   )
   IS
      SELECT a.objid
        FROM table_mod_level a, table_part_num b
       WHERE a.mod_level = c_ip_revision
         AND a.part_info2part_num = b.objid
         AND a.active = 'Active'                                     --Digital
         AND b.part_number = c_ip_part_number
         AND b.domain = c_ip_domain;

   mod_level_objid_rec             mod_level_objid_cur%ROWTYPE;

   --
   /* Cursor to check whether mod_level exists for the given part number with NULL revision */
   CURSOR mod_level_null_objid_cur (c_ip_pn_objid IN NUMBER)
   IS
      SELECT objid
        FROM table_mod_level
       WHERE part_info2part_num = c_ip_pn_objid
         AND active = 'Active'
         AND mod_level IS NULL;

   mod_level_null_objid_rec        mod_level_null_objid_cur%ROWTYPE;

   --
   /* Cursor to check whether atleast one revision info exists for the analog part number */
   CURSOR analog_mod_level_cur (c_ip_pn_objid_1 IN NUMBER)
   IS
      SELECT objid, mod_level
        FROM table_mod_level
       WHERE part_info2part_num = c_ip_pn_objid_1 AND active = 'Active';

   analog_mod_level_rec            analog_mod_level_cur%ROWTYPE;

   --
   /* Cursor to check if there has been a posa transaction */
   CURSOR posa_check_cur (ip_smp VARCHAR2)
   IS
      SELECT 'X'
        FROM x_posa_phone
       WHERE tf_serial_num = ip_smp;

   posa_check_rec                  posa_check_cur%ROWTYPE;

   /* cursor to get the active record from the table_site_part */
   CURSOR check_active_sp_cur (ip_esn IN VARCHAR2)
   IS
      SELECT ROWID
        FROM table_site_part sp
       WHERE x_service_id = ip_esn AND part_status = 'Active';

   r_check_active_sp               check_active_sp_cur%ROWTYPE;

   /*  get mod level cursor */
   CURSOR mod_level2_cur (c_ip_part_number IN VARCHAR2)
   IS
      SELECT a.objid
        FROM table_mod_level a, table_part_num b
       WHERE a.part_info2part_num = b.objid
         AND a.active = 'Active'
         AND b.part_number = c_ip_part_number;

   mod_level2_rec                  mod_level2_cur%ROWTYPE;

   --PSE

   /*Cursor to get the promotion objid */
   CURSOR get_promo_objid_cur (ip_promo IN VARCHAR2)
   IS
      SELECT objid
        FROM table_x_promotion
       WHERE x_promo_code = ip_promo;

   get_promo_objid_rec             get_promo_objid_cur%ROWTYPE;

--End PSE
--cwl----------------------------------------------------------------------------
   CURSOR check_min_curs (ip_esn IN VARCHAR2)
   IS
      SELECT pi2.x_port_in
        FROM table_part_inst pi2, table_site_part sp
       WHERE INITCAP (pi2.x_domain) = 'Lines'
         AND pi2.part_serial_no = sp.x_min
         AND pi2.x_port_in = 1
         AND (sp.part_status) = 'Active'
         AND sp.x_service_id = ip_esn;

   check_min_rec                   check_min_curs%ROWTYPE;

   CURSOR check_esn_curs (ip_esn IN VARCHAR2)
   IS
      SELECT 1
        FROM table_part_inst
       WHERE x_domain = 'PHONES' AND part_serial_no = ip_esn;

   check_esn_rec                   check_esn_curs%ROWTYPE;

 --cwl-----------------------------------------------------------------------------
--CR4799 Starts
   CURSOR c_refurb_time_delay
   IS
      SELECT *
        FROM table_x_webcsr_log_param;

   c_refurb_time_delay_rec         c_refurb_time_delay%ROWTYPE;

     --CR4799 Ends
   /****************************** PRIVATE PROCEDURES ***************************/
   /********* CLEAN up routine **************************************************/
   PROCEDURE clean_up_prc
   IS
   BEGIN
      IF site_id_cur%ISOPEN
      THEN
         CLOSE site_id_cur;
      END IF;

      IF item_cur%ISOPEN
      THEN
         CLOSE item_cur;
      END IF;

      IF domain_objid_cur%ISOPEN
      THEN
         CLOSE domain_objid_cur;
      END IF;

      IF get_2xs_cur%ISOPEN
      THEN
         CLOSE get_2xs_cur;
      END IF;

      IF mod_level_null_objid_cur%ISOPEN
      THEN
         CLOSE mod_level_null_objid_cur;
      END IF;

      IF mod_level_exists_cur%ISOPEN
      THEN
         CLOSE mod_level_exists_cur;
      END IF;

      IF part_exists_cur%ISOPEN
      THEN
         CLOSE part_exists_cur;
      END IF;

      IF mod_level_objid_cur%ISOPEN
      THEN
         CLOSE mod_level_objid_cur;
      END IF;

      IF user_objid_cur%ISOPEN
      THEN
         CLOSE user_objid_cur;
      END IF;

      IF inv_bin_objid_cur%ISOPEN
      THEN
         CLOSE inv_bin_objid_cur;
      END IF;

      IF status_code_objid_cur%ISOPEN
      THEN
         CLOSE status_code_objid_cur;
      END IF;

      IF check_part_inst_cur%ISOPEN
      THEN
         CLOSE check_part_inst_cur;
      END IF;

      IF analog_mod_level_cur%ISOPEN
      THEN
         CLOSE analog_mod_level_cur;
      END IF;

      IF check_active_sp_cur%ISOPEN
      THEN
         CLOSE check_active_sp_cur;
      END IF;

      IF mod_level2_cur%ISOPEN
      THEN
         CLOSE mod_level2_cur;
      END IF;

      IF posa_check_cur%ISOPEN
      THEN
         CLOSE posa_check_cur;
      END IF;

      --PSE
      IF get_promo_objid_cur%ISOPEN
      THEN
         CLOSE get_promo_objid_cur;
      END IF;

--End PSE
--CR4799 Starts
      IF c_refurb_time_delay%ISOPEN
      THEN
         CLOSE c_refurb_time_delay;
      END IF;

--CR4799 Ends
      IF c_get_ota_features%ISOPEN
      THEN
         CLOSE c_get_ota_features;
      END IF;

      IF c_get_pi_objid%ISOPEN
      THEN
         CLOSE c_get_pi_objid;
      END IF;
   /** cleaning up **/
   END clean_up_prc;
/*****************************************************************************/
BEGIN
/* OF MAIN */
   DBMS_OUTPUT.put_line ('before setup vars');
   l_previous_part_number := 'DUMMY_PART';
   l_current_part_number := 'DUMMY_PART';
   l_previous_part_num_transpose := 'DUMMY_PART_TRANS';
   l_current_part_num_transpose := 'DUMMY_PART_TRANS';
   l_previous_transceiver_num := 'DUMMY_PART_TRANC_NUM';
   l_current_transceiver_num := 'DUMMY_PART_TRANC_NUM';
   l_current_retailer := 'DUMMY_RET';
   l_previuos_retailer := 'DUMMY_RET';
   l_current_ff_center := 'DUMMY_FF';
   l_previuos_ff_center := 'DUMMY_FF';
   --
   l_current_manf := 'DUMMY_MANF';
   l_previuos_manf := 'DUMMY_MANF';

   /*** GET USER ONLY ONCE ***/
   OPEN user_objid_cur;

   FETCH user_objid_cur
    INTO user_objid_rec;

   CLOSE user_objid_cur;

   DBMS_OUTPUT.put_line ('after setup vars');

   --CR4799 Starts
   OPEN c_refurb_time_delay;

   FETCH c_refurb_time_delay
    INTO c_refurb_time_delay_rec;

   CLOSE c_refurb_time_delay;

--CR4799 Ends
   FOR inv_rec IN inv_cur
   LOOP
      DBMS_OUTPUT.put_line ('inside loop');
      l_inner_excep_flag := FALSE;                                   --CR3886
      l_restricted_use := 0;                                         --CR3190
      l_upd_pi_status := NULL;
      l_upd_pi_status_code_objid := NULL;
      l_recs_processed := l_recs_processed + 1;
      l_commit_counter := l_commit_counter + 1;

      --CR5461 - TF PartNumber transpose
      OPEN item_cur (inv_rec.tf_part_num_transpose);

      FETCH item_cur
       INTO r_chkitempromo;

      CLOSE item_cur;

      IF    r_chkitempromo.promo_code IS NULL
         OR r_chkitempromo.promo_code = 'NONE'
      THEN
         IF r_chkitempromo.upc IS NULL                              -- CR5575
         THEN
            NULL;
         ELSE
            inv_rec.tf_part_num_parent := inv_rec.tf_part_num_transpose;
         END IF;
      ELSE    /* Assumption: transpose partNo. has a valid promo_code attached
                  replace parent value w/transpose value */
         inv_rec.tf_part_num_parent := inv_rec.tf_part_num_transpose;
      END IF;

      --End of CR5461 - TF PartNumber transpose

      /**** set current ***********************************************/
      l_current_part_number := inv_rec.tf_part_num_parent;
      l_current_part_num_transpose := inv_rec.tf_part_num_transpose;
      l_current_transceiver_num := inv_rec.transceiver_num;
      ----
      l_current_retailer := inv_rec.tf_ret_location_code;
      l_current_ff_center := inv_rec.tf_ff_location_code;
      l_current_manf := inv_rec.tf_manuf_location_code;
/***************************************************************/
--PSE
      l_indv_replace_part := NULL;
      l_tilde_pos := 0;
      l_priority := 0;
      l_replacement_parts := NULL;
      --End PSE
      --CR2549 Changes
      l_warranty_parts := NULL;
      l_warranty_tilde_pos := 0;
      l_indv_warranty_part := NULL;
      l_warranty_priority := 0;

      --End CR2549 Changes
--      l_reset := 'T';                                                --CR4799
      BEGIN
         l_data_phone := 0;                                     --CR4981_4982

/* MAIN INNER BLOCK */
         --cwl----------------------------------------------------------------------------------------
         IF TRANSLATE (SUBSTR (inv_rec.tf_serial_num, 1, 1),
                       '1234567890',
                       '1111111111'
                      ) != '1'
         THEN
            DBMS_OUTPUT.put_line ('bad esn:' || inv_rec.tf_serial_num);
            DBMS_OUTPUT.put_line (   'bad esn length:'
                                  || LENGTH (inv_rec.tf_serial_num)
                                 );
            RAISE refurb_exp1;
         END IF;

         DBMS_OUTPUT.put_line ('step exp1');

         OPEN check_esn_curs (inv_rec.tf_serial_num);

         FETCH check_esn_curs
          INTO check_esn_rec;

         IF check_esn_curs%NOTFOUND
         THEN
            DBMS_OUTPUT.put_line ('notfound esn');

            UPDATE tf.tf_toss_interface_table@ofsprd
               SET toss_extract_flag = 'NO',
                   toss_extract_date = SYSDATE,
                   last_update_date = SYSDATE,
                   last_updated_by = l_procedure_name
             WHERE ROWID = inv_rec.ROWID;

            CLOSE check_esn_curs;

            RAISE refurb_exp2;
         END IF;

         CLOSE check_esn_curs;

         DBMS_OUTPUT.put_line ('step exp2');
--cwl----------------------------------------------------------------------------------------
         l_action := ' ';
         l_serial_num := inv_rec.tf_serial_num;

         --             l_serial_num := inv_rec.tf_serial_num;
         --             l_site_id := null;
         --             l_creation_date := null;
         --             l_inv_status := null;
         --             l_part_inst2part_mod_1 := null;
         --             l_part_inst2part_mod_2 := null;
         --             l_dealer_valid_date := null;
         IF inv_rec.tf_ret_location_code IS NOT NULL
         THEN
            IF (l_current_retailer != l_previuos_retailer)
            THEN
               OPEN site_id_cur (inv_rec.tf_ret_location_code);

               FETCH site_id_cur
                INTO l_site_id;

               IF site_id_cur%FOUND THEN                                                   --CR 6451

               /** GET INV BIN OBJID ***/
               OPEN inv_bin_objid_cur (l_site_id);

               FETCH inv_bin_objid_cur
                INTO inv_bin_objid_rec;

               CLOSE inv_bin_objid_cur;
               ELSE RAISE no_site_id_exp;
               END IF;
               CLOSE site_id_cur;                                                                --CR 6451
            END IF;

            l_creation_date := inv_rec.retailer_ship_date;
            /**  SET OTHERS TO DUMMY SINCE WE ARE NOT GOING TO USE IT */
            l_current_ff_center := 'USING RET';
            l_current_manf := 'USING RET';
         ELSIF inv_rec.tf_ff_location_code IS NOT NULL
         THEN
            IF (l_current_ff_center != l_previuos_ff_center)
            THEN
               OPEN site_id_cur (inv_rec.tf_ff_location_code);

               FETCH site_id_cur
                INTO l_site_id;

               IF site_id_cur%FOUND THEN                                               --CR 6451

               /** GET INV BIN OBJID ***/
               OPEN inv_bin_objid_cur (l_site_id);

               FETCH inv_bin_objid_cur
                INTO inv_bin_objid_rec;

               CLOSE inv_bin_objid_cur;
               ELSE RAISE no_site_id_exp;
               END IF;
               CLOSE site_id_cur;                                                               --CR 6451
            END IF;

            l_creation_date := inv_rec.ff_receive_date;
            /**  SET OTHERS TO DUMMY SINCE WE ARE NOT GOING TO USE IT */
            l_current_retailer := 'USING FF_CENTER';
            l_current_manf := 'USING FF_CENTER';
         ELSIF inv_rec.tf_manuf_location_code IS NOT NULL
         THEN
            IF (l_current_manf != l_previuos_manf)
            THEN
               OPEN site_id_cur (inv_rec.tf_manuf_location_code);

               FETCH site_id_cur
                INTO l_site_id;

               IF site_id_cur%FOUND THEN                                                 --CR 6451

               /** GET INV BIN OBJID ***/
               OPEN inv_bin_objid_cur (l_site_id);

               FETCH inv_bin_objid_cur
                INTO inv_bin_objid_rec;

               CLOSE inv_bin_objid_cur;
               ELSE RAISE no_site_id_exp;
               END IF;
               CLOSE site_id_cur;                                                                --CR 6451
            END IF;

            l_creation_date := inv_rec.creation_date;
            /**  SET OTHERS TO DUMMY SINCE WE ARE NOT GOING TO USE IT */
            l_current_retailer := 'USING MANF';
            l_current_ff_center := 'USING MANF';
         END IF;

         l_action := 'Checking for existent of SITE in TOSS';

         IF l_site_id IS NOT NULL
         THEN
            /***** CHECK IF THE PART NUMBER IS EQUAL ********/
            IF    l_previous_part_number
               || l_previous_part_num_transpose
               || l_previous_transceiver_num !=
                     l_current_part_number
                  || l_current_part_num_transpose
                  || l_current_transceiver_num
            THEN
               OPEN item_cur (inv_rec.tf_part_num_parent);

               FETCH item_cur
                INTO item_rec;

               CLOSE item_cur;

               /* for phones check at tf_part_num_transpose */
               OPEN item_cur (inv_rec.tf_part_num_transpose);

               FETCH item_cur
                INTO r_transpose;

               CLOSE item_cur;

               --CR4981_4982 Start
               IF item_rec.data_phone IS NULL OR item_rec.data_phone = 'N'
               THEN
                  l_data_phone := 0;
               ELSE
                  l_data_phone := 1;
               END IF;

--CR4981_4982 End
               l_revision := inv_rec.transceiver_num;

               IF r_transpose.posa_type = 'POSA'
               THEN
                  l_inv_status := '59';

                  OPEN status_code_objid_cur ('POSA PHONES');

                  FETCH status_code_objid_cur
                   INTO status_code_objid_rec;

                  CLOSE status_code_objid_cur;
               ELSIF r_transpose.posa_type = 'NPOSA'
               THEN
                  l_inv_status := '50';

                  OPEN status_code_objid_cur ('PHONES');

                  FETCH status_code_objid_cur
                   INTO status_code_objid_rec;

                  CLOSE status_code_objid_cur;
               ELSE
                  l_inv_status := NULL;
               END IF;

               l_action := ' ';

               --PSE (Get the annual promo objid to associate with the part number. If NONE, pass NULL)
               OPEN get_promo_objid_cur (item_rec.promo_code);

               FETCH get_promo_objid_cur
                INTO get_promo_objid_rec;

               IF get_promo_objid_cur%NOTFOUND
               THEN
                  CLOSE get_promo_objid_cur;

                  l_promo_objid := NULL;
               ELSE
                  l_promo_objid := get_promo_objid_rec.objid;
               END IF;

               IF get_promo_objid_cur%ISOPEN
               THEN
                  CLOSE get_promo_objid_cur;
               END IF;

--End PSE
/********************************************************************************/
/*          Test to see if part number exists in the table_part_num table       */
/*  If the part number does not exist, insert into part num, table_script and   */
/*          mod_level tables,else update the part num and mod level tables      */
/********************************************************************************/
/* Get the domain object id */
               OPEN domain_objid_cur (item_rec.clfy_domain);

               FETCH domain_objid_cur
                INTO domain_objid_rec;

               CLOSE domain_objid_cur;

               l_action := 'Checking for existent of PART_NUMBER in TOSS';

               OPEN part_exists_cur (domain_objid_rec.objid,
                                     inv_rec.tf_part_num_parent
                                    );

               FETCH part_exists_cur
                INTO part_exists_rec;

               IF part_exists_cur%NOTFOUND
               THEN
                  RAISE no_part_num_exp;   -- CR4659: Insert into error table
               ELSE
                  l_action := 'Update table_part_num';

                  IF l_current_part_number LIKE 'NT%'
                  THEN
                     l_restricted_use := 3;
                     l_conv_rate := 10;
                  ELSE
                     l_restricted_use := 0;
                     l_conv_rate := 3;
                  END IF;

                  IF part_exists_cur%ISOPEN
                  THEN
                     CLOSE part_exists_cur;
                  END IF;

                  UPDATE table_part_num
                     SET part_type = item_rec.charge_code,
                         x_manufacturer =
                                         SUBSTR (item_rec.manufacturer, 1, 20),
                         domain = item_rec.clfy_domain,
                         s_domain = UPPER (item_rec.clfy_domain),
                         x_technology = item_rec.technology,
                         x_upc = item_rec.upc,
                         part_num2x_promotion = l_promo_objid,           --PSE
                         x_cardless_bundle = item_rec.cardless_bundle_flag,
                         --EBIZ
                         x_data_capable = l_data_phone           --CR4981_4982
                   WHERE domain = item_rec.clfy_domain
                     AND part_number = inv_rec.tf_part_num_parent;

                  --PSE (Insert into TABLE_X_EXCH_OPTIONS)
                  OPEN part_exists_cur (domain_objid_rec.objid,
                                        inv_rec.tf_part_num_parent
                                       );

                  FETCH part_exists_cur
                   INTO part_exists_rec;

                  CLOSE part_exists_cur;

                  OPEN toss_cursor_pkg.table_pn_part_cur (item_rec.part_number);

                  FETCH toss_cursor_pkg.table_pn_part_cur
                   INTO table_part_rec;

                  CLOSE toss_cursor_pkg.table_pn_part_cur;

                  IF UPPER (item_rec.frequency) = 'NONE'
                  THEN
                     -- Frequency doesn't apply.
                     NULL;
                  ELSIF INSTR (item_rec.frequency, '-') = 0
                  THEN
                     -- Only one frequency exists.
                     IF toss_util_pkg.frequency_exist_fun
                                                         (item_rec.frequency,
                                                          l_procedure_name
                                                         )
                     THEN
                        OPEN toss_cursor_pkg.table_x_frequency_cur
                                                          (item_rec.frequency);

                        FETCH toss_cursor_pkg.table_x_frequency_cur
                         INTO table_frequency_rec;

                        CLOSE toss_cursor_pkg.table_x_frequency_cur;

                        OPEN toss_cursor_pkg.part_num14_x_frequency0_cur
                                                   (table_part_rec.objid,
                                                    table_frequency_rec.objid
                                                   );

                        FETCH toss_cursor_pkg.part_num14_x_frequency0_cur
                         INTO part_num14_x_freq0_rec;

                        IF toss_cursor_pkg.part_num14_x_frequency0_cur%FOUND
                        THEN
                           NULL;
                        ELSE
                           IF toss_util_pkg.insert_part_num2frequency_fun
                                                  (table_part_rec.objid,
                                                   table_frequency_rec.objid,
                                                   l_procedure_name
                                                  )
                           THEN
                              COMMIT;
                           ELSE
                              l_action :=
                                         'Failed inserting part_num14_x_freq';
                              RAISE failed_insert_part_freq;
                           END IF;
                        END IF;

                        CLOSE toss_cursor_pkg.part_num14_x_frequency0_cur;
                     ELSE
                        IF toss_util_pkg.insert_frequency_fun
                                                         (item_rec.frequency,
                                                          l_procedure_name
                                                         )
                        THEN
                           COMMIT;
                        ELSE
                           l_action := 'Failed inserting frequency';
                           RAISE failed_insert_frequency;
                        END IF;

                        OPEN toss_cursor_pkg.table_x_frequency_cur
                                                           (item_rec.frequency);

                        FETCH toss_cursor_pkg.table_x_frequency_cur
                         INTO table_frequency_rec;

                        CLOSE toss_cursor_pkg.table_x_frequency_cur;

                        OPEN toss_cursor_pkg.part_num14_x_frequency0_cur
                                                    (table_part_rec.objid,
                                                     table_frequency_rec.objid
                                                    );

                        FETCH toss_cursor_pkg.part_num14_x_frequency0_cur
                         INTO part_num14_x_freq0_rec;

                        IF toss_cursor_pkg.part_num14_x_frequency0_cur%FOUND
                        THEN
                           NULL;
                        ELSE
                           IF toss_util_pkg.insert_part_num2frequency_fun
                                                  (table_part_rec.objid,
                                                   table_frequency_rec.objid,
                                                   l_procedure_name
                                                  )
                           THEN
                              COMMIT;
                           ELSE
                              l_action :=
                                         'Failed inserting part_num14_x_freq';
                              RAISE failed_insert_part_freq;
                           END IF;
                        END IF;

                        CLOSE toss_cursor_pkg.part_num14_x_frequency0_cur;
                     END IF;
                  ELSE
                     frequency_string := item_rec.frequency;

                     WHILE LENGTH (frequency_string) > 1
                     LOOP
                        frequency_insert :=
                           SUBSTR (frequency_string,
                                   1,
                                   INSTR (frequency_string, '-') - 1
                                  );
                        frequency_hold :=
                           SUBSTR (frequency_string,
                                   INSTR (frequency_string, '-') + 1
                                  );

                        IF frequency_hold IS NOT NULL
                        THEN
                           frequency_string := frequency_hold;
                        ELSE
                           frequency_string := '-';
                        END IF;

                        IF toss_util_pkg.frequency_exist_fun
                                                            (frequency_insert,
                                                             l_procedure_name
                                                            )
                        THEN
                           OPEN toss_cursor_pkg.table_x_frequency_cur
                                                            (frequency_insert);

                           FETCH toss_cursor_pkg.table_x_frequency_cur
                            INTO table_frequency_rec;

                           CLOSE toss_cursor_pkg.table_x_frequency_cur;

                           OPEN toss_cursor_pkg.part_num14_x_frequency0_cur
                                                   (table_part_rec.objid,
                                                    table_frequency_rec.objid
                                                   );

                           FETCH toss_cursor_pkg.part_num14_x_frequency0_cur
                            INTO part_num14_x_freq0_rec;

                           IF toss_cursor_pkg.part_num14_x_frequency0_cur%FOUND
                           THEN
                              NULL;
                           ELSE
                              IF toss_util_pkg.insert_part_num2frequency_fun
                                                  (table_part_rec.objid,
                                                   table_frequency_rec.objid,
                                                   l_procedure_name
                                                  )
                              THEN
                                 COMMIT;
                              ELSE
                                 l_action :=
                                         'Failed inserting part_num14_x_freq';
                                 RAISE failed_insert_part_freq;
                              END IF;
                           END IF;

                           CLOSE toss_cursor_pkg.part_num14_x_frequency0_cur;
                        ELSE
                           IF toss_util_pkg.insert_frequency_fun
                                                           (frequency_insert,
                                                            l_procedure_name
                                                           )
                           THEN
                              COMMIT;
                           ELSE
                              l_action := 'Failed inserting frequency';
                              RAISE failed_insert_frequency;
                           END IF;

                           OPEN toss_cursor_pkg.table_x_frequency_cur
                                                             (frequency_insert);

                           FETCH toss_cursor_pkg.table_x_frequency_cur
                            INTO table_frequency_rec;

                           CLOSE toss_cursor_pkg.table_x_frequency_cur;

                           OPEN toss_cursor_pkg.part_num14_x_frequency0_cur
                                                    (table_part_rec.objid,
                                                     table_frequency_rec.objid
                                                    );

                           FETCH toss_cursor_pkg.part_num14_x_frequency0_cur
                            INTO part_num14_x_freq0_rec;

                           IF toss_cursor_pkg.part_num14_x_frequency0_cur%FOUND
                           THEN
                              NULL;
                           ELSE
                              IF toss_util_pkg.insert_part_num2frequency_fun
                                                  (table_part_rec.objid,
                                                   table_frequency_rec.objid,
                                                   l_procedure_name
                                                  )
                              THEN
                                 COMMIT;
                              ELSE
                                 l_action :=
                                         'Failed inserting part_num14_x_freq';
                                 RAISE failed_insert_part_freq;
                              END IF;
                           END IF;

                           CLOSE toss_cursor_pkg.part_num14_x_frequency0_cur;
                        END IF;

                        IF INSTR (frequency_string, '-') = 0
                        THEN
                           frequency_string := frequency_string || '-';
                        END IF;
                     END LOOP;
                  END IF;

                  --MT45917 Changes
                  OPEN part_exists_cur (domain_objid_rec.objid,
                                        inv_rec.tf_part_num_parent
                                       );

                  FETCH part_exists_cur
                   INTO part_exists_rec;

                  --End MT45917 Changes
                  -- Do not modify the TABLE_MOD_LEVEL for the exsiting ANALOG phones
                  IF inv_rec.transceiver_num IS NULL
                  THEN
                     --   AND inv_rec.tf_part_type = 'PHONE' THEN
                     OPEN mod_level_null_objid_cur (part_exists_rec.objid);

                     FETCH mod_level_null_objid_cur
                      INTO l_part_inst2part_mod_1;

                     IF mod_level_null_objid_cur%NOTFOUND
                     THEN
                        OPEN analog_mod_level_cur (part_exists_rec.objid);

                        FETCH analog_mod_level_cur
                         INTO analog_mod_level_rec;

                        IF analog_mod_level_cur%NOTFOUND
                        THEN
                           sp_seq ('mod_level', l_seq_mod_level_val);
                           l_action := 'Insert Table_Mod_Level - NULL';

                           INSERT INTO table_mod_level
                                       (objid, active, mod_level,
                                        s_mod_level, eff_date, x_timetank,
                                        part_info2part_num
                                       )
                                VALUES (l_seq_mod_level_val, 'Active', NULL,
                                        NULL, SYSDATE, 0,
                                        part_exists_rec.objid
                                       );

                           l_part_inst2part_mod_1 := l_seq_mod_level_val;
                        ELSE
                           l_part_inst2part_mod_1 :=
                                                   analog_mod_level_rec.objid;
                        END IF;                     --end of ananlog_mod check

                        CLOSE analog_mod_level_cur;
                     END IF;                --end of mod_level_with_null check

                     CLOSE mod_level_null_objid_cur;
                  ELSE
                     OPEN mod_level_exists_cur (part_exists_rec.objid,
                                                l_revision
                                               );                    --Digital

                     FETCH mod_level_exists_cur
                      INTO mod_level_exists_rec;                     --Digital

                     IF mod_level_exists_cur%FOUND
                     THEN
                        l_action := 'Update table_mod_level';

                        UPDATE table_mod_level
                           SET mod_level = l_revision,
                               s_mod_level = UPPER (l_revision),
                               eff_date = SYSDATE,
                               x_timetank = 0
                         WHERE part_info2part_num = part_exists_rec.objid
                           AND active = 'Active'
                           AND mod_level = l_revision;
--Digital
                     ELSE
                        OPEN analog_mod_level_cur (part_exists_rec.objid);

                        FETCH analog_mod_level_cur
                         INTO analog_mod_level_rec;

                        IF analog_mod_level_cur%FOUND
                        THEN
                           IF    (item_rec.technology = 'ANALOG')
                              OR (analog_mod_level_rec.mod_level IS NULL)
                           THEN
                              l_action :=
                                   'Update Mod_Level for Existing Analog ESN';

                              UPDATE table_mod_level
                                 SET mod_level = l_revision,
                                     s_mod_level = UPPER (l_revision),
                                     eff_date = SYSDATE,
                                     x_timetank = 0
                               WHERE objid = analog_mod_level_rec.objid
                                 AND part_info2part_num =
                                                         part_exists_rec.objid
                                 AND active = 'Active';
                           ELSE
                              sp_seq ('mod_level', l_seq_mod_level_val);
                              l_action := 'Insert Mod_Level - Digital 1 ';

                              INSERT INTO table_mod_level
                                          (objid, active,
                                           mod_level, s_mod_level,
                                           eff_date, x_timetank,
                                           part_info2part_num
                                          )
                                   VALUES (
                                           -- 06/04/03 r_seq_mod_level.val,
                                           l_seq_mod_level_val, 'Active',
                                           l_revision, UPPER (l_revision),
                                           SYSDATE, 0,
                                           part_exists_rec.objid
                                          );
                           END IF;
                        ELSE
                           sp_seq ('mod_level', l_seq_mod_level_val);
                           l_action := 'Insert Mod_Level - Digital 2';

                           INSERT INTO table_mod_level
                                       (objid, active,
                                        mod_level, s_mod_level,
                                        eff_date, x_timetank,
                                        part_info2part_num
                                       )
                                VALUES (l_seq_mod_level_val, 'Active',
                                        l_revision, UPPER (l_revision),
                                        SYSDATE, 0,
                                        part_exists_rec.objid
                                       );
                        END IF;                         --end analog_mod check

                        CLOSE analog_mod_level_cur;
                     END IF;                      /* end of mod level check */

                     CLOSE mod_level_exists_cur;
                  --End Digital
                  END IF;
               /* end of transceiver_num check */
               END IF;                          /* end of part number check */

               CLOSE part_exists_cur;                        --MT45917 Changes

--
/********************************************************************************/
/*              Test to see if part exists in the table_part_inst table         */
/*   If part does not exist, insert into part inst and update interface table   */
/*    else if the part exists and the information is from Oracle Financials,    */
/* update part inst and interface tables, otherwise update only interface table */
/********************************************************************************/
               OPEN mod_level_objid_cur (inv_rec.tf_part_num_parent,
                                         l_revision,
                                         item_rec.clfy_domain
                                        );

               FETCH mod_level_objid_cur
                INTO l_part_inst2part_mod_2;

               CLOSE mod_level_objid_cur;

               OPEN inv_bin_objid_cur (l_site_id);

               FETCH inv_bin_objid_cur
                INTO inv_bin_objid_rec;

               CLOSE inv_bin_objid_cur;
            END IF;                          /*** of same part number check */

            OPEN check_part_inst_cur (inv_rec.tf_serial_num,
                                      item_rec.clfy_domain
                                     );

            FETCH check_part_inst_cur
             INTO check_part_inst_rec;

            IF inv_rec.transceiver_num IS NULL
            THEN
               l_part_inst2part_mod := l_part_inst2part_mod_1;
            ELSE
               l_part_inst2part_mod := l_part_inst2part_mod_2;
            END IF;

            IF inv_rec.toss_extract_flag = 'NOR'
            THEN
               l_reset_date := inv_rec.tf_phone_refurb_date;

               --CR4799 Starts
               IF l_reset_date >
                     SYSDATE
                     - NVL (c_refurb_time_delay_rec.x_refurb_delay, 0)
               THEN
                  l_reset_date :=
                        l_reset_date - c_refurb_time_delay_rec.x_refurb_delay;
               END IF;

               --CR4799 Ends
               l_reset_action_type := 'REFURBISHED';
               l_inv_status := '150';
            --will set to 150
            ELSIF inv_rec.toss_extract_flag = 'NOA'
            THEN
               l_reset_date := inv_rec.serial_valid_insert_date;

               IF l_reset_date >
                     SYSDATE
                     - NVL (c_refurb_time_delay_rec.x_refurb_delay, 0)
               THEN
                  l_reset_date :=
                        l_reset_date - c_refurb_time_delay_rec.x_refurb_delay;
               END IF;

               --CR4799 Ends
               l_reset_action_type := 'REPAIRED';
               l_inv_status := '150';
            --will set to 150 per muhammad request
            ELSIF inv_rec.toss_extract_flag = 'NOV'
            THEN
               l_reset_date := inv_rec.serial_invalid_date;
               l_reset_action_type := 'UNREPAIRABLE';
               l_inv_status := '49';
            --will set to 49  (final state)
            END IF;

            /* evaluate if if was succesfully reset */
            IF NOT sa.reset_esn_fun (inv_rec.tf_serial_num,
                                     l_reset_date,
                                     inv_rec.tf_order_num,
                                     user_objid_rec.objid,
                                     l_part_inst2part_mod,
                                     inv_bin_objid_rec.objid,
                                     l_reset_action_type,
                                     l_inv_status,
                                     l_procedure_name,
                                     l_creation_date        -- 01/30/03 Change
                                    )
            THEN
/** UPDATE OUTSIDE THE RESET FUN becuase it failed */
--cwl---------------------------------------------------------------------------------------------------------------
               OPEN check_min_curs (inv_rec.tf_serial_num);

               FETCH check_min_curs
                INTO check_min_rec;

               IF check_min_curs%FOUND
               THEN
                  UPDATE table_part_inst
                     SET x_creation_date = l_creation_date,
                         x_order_number = inv_rec.tf_order_num,
                         created_by2user = user_objid_rec.objid,
                         last_mod_time = TO_DATE (SYSDATE),
                         last_trans_time = TO_DATE (SYSDATE),
                         n_part_inst2part_mod = l_part_inst2part_mod,
                         part_inst2inv_bin = inv_bin_objid_rec.objid
                   WHERE x_domain = 'PHONES'
                     AND part_serial_no = inv_rec.tf_serial_num;

                  UPDATE tf.tf_toss_interface_table@ofsprd
                     SET toss_extract_flag = 'YES',
                         toss_extract_date = SYSDATE,
                         last_update_date = SYSDATE,
                         last_updated_by = l_procedure_name
                   WHERE ROWID = inv_rec.ROWID;

                  CLOSE check_min_curs;

                  RAISE refurb_exp3;
               END IF;

               CLOSE check_min_curs;

               DBMS_OUTPUT.put_line ('step exp3');

--cwl---------------------------------------------------------------------------------------------------------------
               UPDATE table_part_inst
                  SET x_creation_date = l_creation_date,
                      x_order_number = inv_rec.tf_order_num,
                      created_by2user = user_objid_rec.objid,
                      last_pi_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                      last_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                      next_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                      last_mod_time = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                      last_trans_time = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                      date_in_serv = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                      repair_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                      n_part_inst2part_mod = l_part_inst2part_mod,
                      part_mod = inv_rec.toss_changed_retailer_name,                            --CR5565
                      part_inst2inv_bin = inv_bin_objid_rec.objid
                WHERE x_domain = 'PHONES'
                  AND part_serial_no = inv_rec.tf_serial_num;
            END IF;

            /* NOw go ahead and update regardless if the phone was */
            /* refurb of not. Other data was updated anyway        */
            /** ONLY UPDATE IF SUCCESSFUL INSERT OR UPDATE **/
            IF SQL%ROWCOUNT = 1
            THEN
               --06/26/06 CRdataE
               IF    l_data_phone = 1
                  OR item_rec.dll > 21                                --CR5835
                  OR l_current_part_number LIKE 'TF2126I%'            --CR5484
               THEN
                  --CR4981_4982 start
                  l_action := 'Insert into ota_features';
                  sa.sp_seq ('x_ota_features', l_ota_seq);

                  OPEN c_get_ota_features (check_part_inst_rec.objid);

                  FETCH c_get_ota_features
                   INTO r_get_ota_features;

                  IF c_get_ota_features%NOTFOUND
                  THEN
                     INSERT INTO table_x_ota_features
                                 (objid, dev, x_redemption_menu,
                                  x_handset_lock, x_low_units,
                                  x_ota_features2part_num,
                                  x_ota_features2part_inst,
                                  x_psms_destination_addr, x_ild_account,
                                  x_ild_carr_status, x_ild_prog_status,
                                  x_ild_counter, x_current_conv_rate,
                                  x_close_count
                                 )
                          VALUES (l_ota_seq, NULL, 'Y',
                                  'Y', 'N',
                                  NULL,
                                  check_part_inst_rec.objid,
                                  '31778', NULL,
                                  'Inactive', 'Completed',
                                  NULL, l_conv_rate,
                                  0
                                 );
                  END IF;

                  CLOSE c_get_ota_features;
               END IF;                                      --06/26/06 CRdataE

--CR4981_4982 end
               l_action := 'Update tf_toss_interface_table refurbs';

               --
               --
               UPDATE tf.tf_toss_interface_table@ofsprd
                  SET toss_extract_flag = 'YES',
                      toss_extract_date = SYSDATE,
                      last_update_date = SYSDATE,
                      last_updated_by = l_procedure_name
                WHERE ROWID = inv_rec.ROWID;

               -- /** Now update the table_site_part.site_part2part_info **/
               OPEN check_active_sp_cur (inv_rec.tf_serial_num);

               FETCH check_active_sp_cur
                INTO r_check_active_sp;

               IF check_active_sp_cur%FOUND
               THEN
                  OPEN mod_level2_cur (inv_rec.tf_part_num_parent);

                  FETCH mod_level2_cur
                   INTO mod_level2_rec;

                  CLOSE mod_level2_cur;

                  UPDATE table_site_part sp
                     SET site_part2part_info = mod_level2_rec.objid
                   WHERE sp.ROWID = r_check_active_sp.ROWID;
               END IF;

               CLOSE check_active_sp_cur;
            END IF;                                 /** of row count check **/

            CLOSE check_part_inst_cur;

            COMMIT;
         ELSE
            RAISE no_site_id_exp;
         END IF;                          /* end of site_id existence check */
      EXCEPTION
         WHEN no_part_num_exp
         THEN
            toss_util_pkg.insert_error_tab_proc ('Inner Block : ' || l_action,
                                                 l_serial_num,
                                                 l_procedure_name,
                                                 'PART_NUM NOT EXISTS '
                                                );
            l_inner_excep_flag := TRUE;                               --CR3886
            COMMIT;
         WHEN validate_exp
         THEN
            toss_util_pkg.insert_error_tab_proc
               (l_out_action,                   --ip_action     IN   VARCHAR2,
                l_serial_num,                   --ip_key        IN   VARCHAR2,
                l_procedure_name,               --ip_program_name IN VARCHAR2,
                'Inner Block Error ' --ip_error_text  IN VARCHAR2 DEFAULT NULL
               );
            l_inner_excep_flag := TRUE;                               --CR3886
            COMMIT;
         WHEN refurb_exp1
         THEN
            DBMS_OUTPUT.put_line ('refurb_exp1 exception');
            toss_util_pkg.insert_error_tab_proc
               (l_out_action || ' ESN has bad character',
                --ip_action     IN   VARCHAR2,
                inv_rec.tf_serial_num,          --ip_key        IN   VARCHAR2,
                l_procedure_name,               --ip_program_name IN VARCHAR2,
                'Inner Block Error ' --ip_error_text  IN VARCHAR2 DEFAULT NULL
               );
            l_inner_excep_flag := TRUE;                               --CR3886
            COMMIT;
         WHEN refurb_exp2
         THEN
            toss_util_pkg.insert_error_tab_proc
               (' esn not found toss_extract_flag set to NO',
                --ip_action     IN   VARCHAR2,
                inv_rec.tf_serial_num,          --ip_key        IN   VARCHAR2,
                l_procedure_name,               --ip_program_name IN VARCHAR2,
                'Inner Block Error ' --ip_error_text  IN VARCHAR2 DEFAULT NULL
               );
            l_inner_excep_flag := TRUE;                               --CR3886
            COMMIT;
         WHEN refurb_exp3
         THEN
            toss_util_pkg.insert_error_tab_proc
               (   l_out_action
                || ' esn not deactivated it has ported min associated',
                --ip_action     IN   VARCHAR2,
                l_serial_num,                   --ip_key        IN   VARCHAR2,
                l_procedure_name,               --ip_program_name IN VARCHAR2,
                'Inner Block Error ' --ip_error_text  IN VARCHAR2 DEFAULT NULL
               );
            l_inner_excep_flag := TRUE;                               --CR3886
            COMMIT;
         WHEN no_site_id_exp
         THEN
            toss_util_pkg.insert_error_tab_proc
               (l_out_action || ' NO SITE ID',  --ip_action     IN   VARCHAR2,
                l_serial_num,                   --ip_key        IN   VARCHAR2,
                l_procedure_name,               --ip_program_name IN VARCHAR2,
                'Inner Block Error ' --ip_error_text  IN VARCHAR2 DEFAULT NULL
               );
            l_inner_excep_flag := TRUE;
         --CR3886
         WHEN distributed_trans_time_out
         THEN
            toss_util_pkg.insert_error_tab_proc
               (l_out_action || ' Caught distributed_trans_time_out',
                --ip_action     IN   VARCHAR2,
                l_serial_num,                   --ip_key        IN   VARCHAR2,
                l_procedure_name,               --ip_program_name IN VARCHAR2,
                'Inner Block Error ' --ip_error_text  IN VARCHAR2 DEFAULT NULL
               );
            l_inner_excep_flag := TRUE;
--CR3886
         WHEN record_locked
         THEN
            toss_util_pkg.insert_error_tab_proc
               (l_out_action || ' Caught distributed_trans_time_out',
                --ip_action     IN   VARCHAR2,
                l_serial_num,                   --ip_key        IN   VARCHAR2,
                l_procedure_name,               --ip_program_name IN VARCHAR2,
                'Inner Block Error ' --ip_error_text  IN VARCHAR2 DEFAULT NULL
               );
            l_inner_excep_flag := TRUE;
--CR3886
         WHEN OTHERS
         THEN
            l_err_text := SQLERRM;
            toss_util_pkg.insert_error_tab_proc
                                 ('Inner Block Error -When others',
                                  --ip_action     IN   VARCHAR2,
                                  l_serial_num, --ip_key        IN   VARCHAR2,
                                  l_procedure_name
                                 );
            l_inner_excep_flag := TRUE;
--CR3886
      END;

      /** cleaning up **/
      DBMS_OUTPUT.put_line ('before cleanup');
      clean_up_prc;
      DBMS_OUTPUT.put_line ('after cleanup');

      /** commit every 1000 */
      IF MOD (l_commit_counter, 1000) = 0
      THEN
         COMMIT;
      END IF;

      --CR3886 Starts
      IF l_inner_excep_flag
      THEN
         l_previous_part_number := 'DUMMY_PART';
         l_previous_part_num_transpose := 'DUMMY_PART_TRANS';
         l_previous_transceiver_num := 'DUMMY_PART_TRANC_NUM';
         l_previuos_retailer := 'DUMMY_RET';
         l_previuos_ff_center := 'DUMMY_FF';
         l_previuos_manf := 'DUMMY_MANF';
      ELSE
--CR3886 Ends
         /***************** Set current to previous  *******************/
         l_previous_part_number := l_current_part_number;
         l_previous_part_num_transpose := l_current_part_num_transpose;
         l_previous_transceiver_num := l_current_transceiver_num;
         l_previuos_retailer := l_current_retailer;
         l_previuos_ff_center := l_current_ff_center;
         l_previuos_manf := l_current_manf;
/***************************************************/
      END IF;                                                         --CR3886

      COMMIT;
   END LOOP;                                         /* end of inv_rec loop */

   COMMIT;

   IF toss_util_pkg.insert_interface_jobs_fun (l_procedure_name,
                                               l_start_date,
                                               SYSDATE,
                                               l_recs_processed,
                                               'SUCCESS',
                                               l_procedure_name
                                              )
   THEN
      COMMIT;
   END IF;

   clean_up_prc;
EXCEPTION
   WHEN failed_insert_frequency
   THEN
      toss_util_pkg.insert_error_tab_proc
                             (l_out_action,     --ip_action     IN   VARCHAR2,
                              l_serial_num,     --ip_key        IN   VARCHAR2,
                              l_procedure_name, --ip_program_name IN VARCHAR2,
                              ' error inserting frequency'
                             --ip_error_text  IN VARCHAR2 DEFAULT NULL
                             );
      clean_up_prc;
      COMMIT;
   WHEN failed_insert_part_freq
   THEN
      toss_util_pkg.insert_error_tab_proc
                             (l_out_action,     --ip_action     IN   VARCHAR2,
                              l_serial_num,     --ip_key        IN   VARCHAR2,
                              l_procedure_name, --ip_program_name IN VARCHAR2,
                              ' error inserting part_num frequency swing'
                             --ip_error_text  IN VARCHAR2 DEFAULT NULL
                             );
      clean_up_prc;
      COMMIT;
   WHEN distributed_trans_time_out
   THEN
      toss_util_pkg.insert_error_tab_proc
                             (l_out_action,     --ip_action     IN   VARCHAR2,
                              l_serial_num,     --ip_key        IN   VARCHAR2,
                              l_procedure_name, --ip_program_name IN VARCHAR2,
                              ' Caught distributed_trans_time_out'
                             --ip_error_text  IN VARCHAR2 DEFAULT NULL
                             );
      COMMIT;
      clean_up_prc;

      IF toss_util_pkg.insert_interface_jobs_fun (l_procedure_name,
                                                  l_start_date,
                                                  SYSDATE,
                                                  l_recs_processed,
                                                  'FAILED',
                                                  l_procedure_name
                                                 )
      THEN
         COMMIT;
      END IF;
   WHEN record_locked
   THEN
      toss_util_pkg.insert_error_tab_proc
            (l_out_action,                      --ip_action     IN   VARCHAR2,
             l_serial_num,                      --ip_key        IN   VARCHAR2,
             l_procedure_name,                  --ip_program_name IN VARCHAR2,
             ' Caught record_locked' --ip_error_text  IN VARCHAR2 DEFAULT NULL
            );
      clean_up_prc;

      IF toss_util_pkg.insert_interface_jobs_fun (l_procedure_name,
                                                  l_start_date,
                                                  SYSDATE,
                                                  l_recs_processed,
                                                  'FAILED',
                                                  l_procedure_name
                                                 )
      THEN
         COMMIT;
      END IF;
   WHEN OTHERS
   THEN
      l_err_text := SQLERRM;
      toss_util_pkg.insert_error_tab_proc
                                 (l_out_action,
                                  --ip_action     IN   VARCHAR2,
                                  l_serial_num, --ip_key        IN   VARCHAR2,
                                  l_procedure_name
                                 );
      clean_up_prc;

      IF toss_util_pkg.insert_interface_jobs_fun (l_procedure_name,
                                                  l_start_date,
                                                  SYSDATE,
                                                  l_recs_processed,
                                                  'FAILED',
                                                  l_procedure_name
                                                 )
      THEN
         COMMIT;
      END IF;
END inbound_phone_other_inv_tmp;
/