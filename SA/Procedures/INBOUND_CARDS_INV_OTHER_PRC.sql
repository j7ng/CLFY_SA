CREATE OR REPLACE PROCEDURE sa."INBOUND_CARDS_INV_OTHER_PRC"
AS
--(ip_completion_status IN OUT BOOLEAN) AS
 /********************************************************************************************/
 /* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved */
 /* */
 /* Name : SA.INBOUND_CARDS_INV_OTHER_PRC.sql */
 /* Purpose : To extract CARDS inventory data from TF_TOSS_INTERFACE_TABLE in Oracle */
 /* Parameters   :   NONE                                                                    */
   /* Platforms    :   Oracle 8.0.6 AND newer versions                                         */
   /* Author       :   Miguel Leon                                                             */
   /* Date         :   01/25/2001                                                              */
   /* Revisions    :                                                                           */
   /* Version  Date      Who              Purpose                                              */
   /* -------  --------  -------          -------------------------------------                */
   /* 1.0     12/13/2001 Mleon            Initial revision                                     */
   /* 1.1     12/27/04    VA               CR3190 - Assign x_restricted_use to '3'             */
   /*                                     for NET10 phones                                     */
   /* 1.2     10/13/05    GP              CR4659 - Avoid deletion of card if swipe has occured */
   /*                                     and removed logic to insert new part numbers         */
   /* 1.3    03/09/06    VA               CR4981_4982 - Logic added to add information for DATA phones and CONVERSION rates
   /* 1.4    05/17/06    VA               Same version as in CLFYUPGQ
   /* 1.5    05/17/06    VA               Changed the database link to ofsprd
   /* 1.6      06/08/06    CL                  CR5349 - Fix for OPEN_CURSORS
   /* 1.7    08/16/06    GP               CR5461 - Using TF partNumber transpose
   /* 1.8     08/30/06     VA                  CR5461 - Changed the database link from OFSDEV2 to OFSPRD
   /* 1.9    12/20/2008  LS               CR8000 Commented out the partNumber insert
   /********************************************************************************************/
   --********************************************************************************************
   --$RCSfile: INBOUND_CARDS_INV_OTHER_PRC.sql,v $
   --$Revision: 1.3 $
   --$Author: kacosta $
   --$Date: 2011/09/26 15:17:47 $
   --$ $Log: INBOUND_CARDS_INV_OTHER_PRC.sql,v $
   --$ Revision 1.3  2011/09/26 15:17:47  kacosta
   --$ CR17825 Inbound Card Jobs Modifications
   --$
   --$
   --********************************************************************************************
   --Local Variables
   l_action                     VARCHAR2 (50)                      := ' ';
   l_err_text                   VARCHAR2 (4000);
   l_inv_status                 VARCHAR2 (20);
   l_serial_num                 VARCHAR2 (50);
   l_status_code_objid          NUMBER;
   l_revision                   VARCHAR2 (10);
   l_part_inst2part_mod         NUMBER;
   l_creation_date              DATE;
   l_site_id                    VARCHAR2 (80);
   l_out_action                 VARCHAR2 (50);
   l_out_error                  VARCHAR2 (4000);
   l_procedure_name             VARCHAR2 (80)
                                             := 'INBOUND_CARDS_INV_OTHER_PRC';
   l_recs_processed             NUMBER                             := 0;
   l_start_date                 DATE                               := SYSDATE;
   l_commit_counter             NUMBER                             := 0;
   r_seq_part_script_val        NUMBER;
   r_seq_part_num_val           NUMBER;
   r_seq_mod_level_val          NUMBER;
   ip_completion_status         BOOLEAN;
   l_intposaswipe               NUMBER                             := 0;
                                                                    -- CR4659
   ------------- LOCAL VARIABLES TO AVOID UNNECESSARY TRIPS ---------
   l_previous_part_number       VARCHAR2 (100);
   l_current_part_number        VARCHAR2 (100);
   --
   l_current_retailer           VARCHAR2 (100);
   l_previuos_retailer          VARCHAR2 (100);
   --
   l_current_ff_center          VARCHAR2 (100);
   l_previuos_ff_center         VARCHAR2 (100);
   --
   l_current_manf               VARCHAR2 (100);
   l_previuos_manf              VARCHAR2 (100);
   --New variables added to update TOSS_REDEMPTION_CODE
   l_smp_status                 VARCHAR2 (20);
   l_redemp_code                VARCHAR2 (20);
   l_pi_seq                     NUMBER;
   l_pi_hist_seq                NUMBER;
   l_posa_card_inv_seq          NUMBER;
   l_update_interface           VARCHAR2 (20);
   l_restricted_use             NUMBER                             := 0;
                                                                     --CR3190
   --Exception Variables
   no_site_id_exp               EXCEPTION;
   no_part_num_exp              EXCEPTION;                          -- CR4659
   distributed_trans_time_out   EXCEPTION;
   record_locked                EXCEPTION;
   --
   PRAGMA EXCEPTION_INIT (distributed_trans_time_out, -2049);
   PRAGMA EXCEPTION_INIT (record_locked, -54);

   --
   /* Cursor to extract CARDS data from TF_TOSS_INTERFACE_TABLE via database link*/
   CURSOR inv_cur
   IS
      SELECT   /*+ RULE */
               a.ROWID, tf_part_num_parent, tf_part_num_transpose,
               tf_serial_num, tf_part_type, tf_card_pin_num,
               tf_manuf_location_code, tf_manuf_location_name,
               tf_ff_location_code, tf_ret_location_code, tf_order_num,
               creation_date, created_by, ff_receive_date,
               retailer_ship_date, tf_po_num, toss_extract_flag
          FROM tf.tf_toss_interface_table@ofsprd a
         WHERE toss_extract_flag IN ('NOA', 'NOV')
           AND tf_part_type || '' = 'CARDS'
           AND EXISTS (
                  SELECT NULL
                    FROM tf.tf_of_item_v@ofsprd
                   WHERE part_number = tf_part_num_parent
                     AND clfy_domain = 'REDEMPTION CARDS'
                     AND part_assignment = 'PARENT')
      ORDER BY tf_part_num_parent,
               tf_ret_location_code,
               tf_ff_location_code,
               tf_manuf_location_code;

   /* Cursor to extract new item information from TF_ITEM_V view via database link*/
   CURSOR item_cur (part_no_in IN VARCHAR2)
   IS
      SELECT *
        FROM tf.tf_of_item_v@ofsprd
       WHERE part_number = part_no_in;

   item_rec                     item_cur%ROWTYPE;
   r_chkitempromo               item_cur%ROWTYPE;

   --
   /* Cursor to extract TOSS dealer id based on Financials Customer Id */
   CURSOR site_id_cur (fin_cust_id_in IN VARCHAR2)
   IS
      SELECT site_id
        FROM table_site
       WHERE TYPE = 3 AND x_fin_cust_id = fin_cust_id_in;

   site_id_rec                  site_id_cur%ROWTYPE;

   --
   /* Cursor to get the part clfy_domain object id */
   CURSOR domain_objid_cur (clfy_domain_in IN VARCHAR2)
   IS
      SELECT objid
        FROM table_prt_domain
       WHERE NAME = clfy_domain_in;

   domain_objid_rec             domain_objid_cur%ROWTYPE;

   --
   /* Cursor to get the part number object id */
   CURSOR part_exists_cur (domain2_in IN VARCHAR2, part_number_in IN VARCHAR2)
   IS
      SELECT objid
        FROM table_part_num
       WHERE part_number = part_number_in AND part_num2domain = domain2_in;

   r_part_exists                part_exists_cur%ROWTYPE;

   --
   /* Cursor to get the mod_level information for the given part number */--Digital
   CURSOR mod_level_exists_cur (
      part_num_objid_in   IN   VARCHAR2,
      revision_in         IN   VARCHAR2
   )
   IS
      SELECT objid
        FROM table_mod_level
       WHERE part_info2part_num = part_num_objid_in
         AND active = 'Active'
         AND mod_level = revision_in;

   mod_level_exists_rec         mod_level_exists_cur%ROWTYPE;

   /* Cursor to get user object id  */
   CURSOR user_objid_cur
   IS
      SELECT objid
        FROM table_user
       WHERE login_name = 'ORAFIN';

   user_objid_rec               user_objid_cur%ROWTYPE;

   --
   /* Cursor to get bin object id */
   CURSOR inv_bin_objid_cur (customer_id_in IN VARCHAR2)
   IS
      SELECT objid
        FROM table_inv_bin
       WHERE bin_name = customer_id_in;

   inv_bin_objid_rec            inv_bin_objid_cur%ROWTYPE;

   --

   /* Cursor to get code object id added POSA PHONES */
   CURSOR status_code_objid_cur (clfy_domain4_in IN VARCHAR2)
   IS
      SELECT objid
        FROM table_x_code_table
       WHERE x_code_number =
                DECODE (clfy_domain4_in,
                        'REDEMPTION CARDS', '42',
                        'POSA CARDS', '45'
                       );

   status_code_objid_rec        status_code_objid_cur%ROWTYPE;

   /* Cursor to get part number object id associated with the revision of the part number */
   CURSOR mod_level_objid_cur (
      part_number_in   IN   VARCHAR2,
      revision_in      IN   VARCHAR2,
      domain_in        IN   VARCHAR2
   )
   IS
      SELECT a.objid
        FROM table_mod_level a, table_part_num b
       WHERE a.mod_level = revision_in
         AND a.part_info2part_num = b.objid
         AND a.active = 'Active'                                     --Digital
         AND b.part_number = part_number_in
         AND b.domain = domain_in;

   mod_level_objid_rec          mod_level_objid_cur%ROWTYPE;

   --

   /* Cursor to check whether mod_level exists for the given part number with NULL revision */
   CURSOR mod_level_null_objid_cur (pn_objid_in IN NUMBER)
   IS
      SELECT objid
        FROM table_mod_level
       WHERE part_info2part_num = pn_objid_in
         AND active = 'Active'
         AND mod_level IS NULL;

   mod_level_null_objid_rec     mod_level_null_objid_cur%ROWTYPE;

   /* Cursor to check if the serial number exists in part_inst table */
   CURSOR check_part_inst_cur (
      serial_number_in   IN   VARCHAR2,
      domain_in          IN   VARCHAR2
   )
   IS
      SELECT *
        FROM table_part_inst
       WHERE x_domain || '' = domain_in AND part_serial_no = serial_number_in;

   check_part_inst_rec          check_part_inst_cur%ROWTYPE;

   /* Cursor to check if the serial number exists in posa_card table */
   CURSOR check_posa_card_cur (serial_number_in IN VARCHAR2)
   IS
      SELECT *
        FROM table_x_posa_card_inv
       WHERE x_part_serial_no = serial_number_in;

   check_posa_card_rec          check_posa_card_cur%ROWTYPE;

   /* Cursor to check if the serial number exists in red_card table */
   /* check only for completed ones (meaning only then is really redemmed */
   CURSOR check_red_card_cur (serial_number_in IN VARCHAR2)
   IS
      SELECT *
        FROM table_x_red_card
       WHERE x_result || '' = 'Completed' AND x_smp = serial_number_in;

   check_red_card_rec           check_red_card_cur%ROWTYPE;

--CR4981_4982 Start
   CURSOR get_conv_dtl (ip_part IN VARCHAR2)
   IS
      SELECT x_conversion
        FROM table_x_ext_conversion_hist
       WHERE (SYSDATE BETWEEN x_start_date AND x_end_date
              OR x_end_date IS NULL
             )
         AND conv_hist2part_num = (SELECT objid
                                     FROM table_part_num
                                    WHERE part_number = ip_part);

   get_conv_dtl_rec             get_conv_dtl%ROWTYPE;
   l_convhist_objid             NUMBER;

--CR4981_4982 End

   /** in the event of exceptions ***/
   PROCEDURE clean_up_prc
   IS
   BEGIN
      /** cleaning up **/
      IF check_posa_card_cur%ISOPEN
      THEN
         CLOSE check_posa_card_cur;
      END IF;

      IF check_part_inst_cur%ISOPEN
      THEN
         CLOSE check_part_inst_cur;
      END IF;

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

      IF get_conv_dtl%ISOPEN
      THEN
         CLOSE get_conv_dtl;
      END IF;                                                    --CR4981_4982
   END clean_up_prc;
BEGIN
/*OF MAIN  */
   l_previous_part_number := 'DUMMY_PART';
   l_current_part_number := 'DUMMY_PART';
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

   FOR inv_rec IN inv_cur
   LOOP
      l_restricted_use := 0;                                         --CR3190
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
         NULL;
      ELSE    /* Assumption: transpose partNo. has a valid promo_code attached
                  replace parent value w/transpose value */
         inv_rec.tf_part_num_parent := inv_rec.tf_part_num_transpose;
      END IF;

      --End of CR5461 - TF PartNumber transpose

      /**** set current ***********************************************/
      l_current_part_number := inv_rec.tf_part_num_parent;
      l_current_retailer := inv_rec.tf_ret_location_code;
      l_current_ff_center := inv_rec.tf_ff_location_code;
      l_current_manf := inv_rec.tf_manuf_location_code;

/***************************************************************/
      BEGIN
/* MAIN INNER BLOCK */
         l_action := ' ';
         l_serial_num := inv_rec.tf_serial_num;

         IF inv_rec.tf_ret_location_code IS NOT NULL
         THEN
            IF (l_current_retailer != l_previuos_retailer)
            THEN
               OPEN site_id_cur (inv_rec.tf_ret_location_code);

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
               CLOSE site_id_cur;                                                              --CR 6451
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

               IF site_id_cur%FOUND THEN                                                 --CR 6451

               /** GET INV BIN OBJID ***/
               OPEN inv_bin_objid_cur (l_site_id);

               FETCH inv_bin_objid_cur
                INTO inv_bin_objid_rec;

               CLOSE inv_bin_objid_cur;
               ELSE RAISE no_site_id_exp;
               END IF;
               CLOSE site_id_cur;                                                              --CR 6451
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

               IF site_id_cur%FOUND THEN                                                --CR 6451

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
            IF l_previous_part_number != l_current_part_number
            THEN
               OPEN item_cur (inv_rec.tf_part_num_parent);

               FETCH item_cur
                INTO item_rec;

               CLOSE item_cur;

               l_revision := item_rec.redemption_units;

               IF item_rec.posa_type = 'POSA'
               THEN
                  l_inv_status := '45';

                  OPEN status_code_objid_cur ('POSA CARDS');

                  FETCH status_code_objid_cur
                   INTO status_code_objid_rec;

                  CLOSE status_code_objid_cur;
               ELSIF item_rec.posa_type = 'NPOSA'
               THEN
                  l_inv_status := '42';

                  OPEN status_code_objid_cur ('REDEMPTION CARDS');

                  FETCH status_code_objid_cur
                   INTO status_code_objid_rec;

                  CLOSE status_code_objid_cur;
               END IF;

/********************************************************************************/
/*          Test to see if part number exists in the table_part_num table       */
/*  If the part number does not exist, insert into part num, table_script and   */
/*          mod_level tables,else update the part num and mod level tables      */
/********************************************************************************/
/* Get the clfy_domain object id */
               OPEN domain_objid_cur (item_rec.clfy_domain);

               FETCH domain_objid_cur
                INTO domain_objid_rec;

               CLOSE domain_objid_cur;

  --       l_action := 'Checking for existent of PART_NUMBER in TOSS';

               OPEN part_exists_cur (domain_objid_rec.objid,
                                     inv_rec.tf_part_num_parent
                                    );

               FETCH part_exists_cur
                INTO r_part_exists;

              IF part_exists_cur%NOTFOUND
               THEN
                  RAISE no_part_num_exp;   -- CR4659: Insert into error table
-- CR4659 - Remove logic to insert part number.

--                  sp_seq('part_num', r_seq_part_num_val);
--                  l_action := 'Insert into table_part_num';
--                  --CR3190 starts
--                  IF inv_rec.tf_part_num_parent LIKE 'NT%'
--                  THEN
--                     l_restricted_use := 3;
--                  ELSE
--                     l_restricted_use := 0;
--                  END IF;
--                  --CR3190 Ends
--                  INSERT
--                  INTO table_part_num(
--                     objid,
--                     active,
--                     part_number,
--                     s_part_number,
--                     description,
--                     part_type,
--                     x_manufacturer,
--                     domain,
--                     x_redeem_days,
--                     x_redeem_units,
--                     part_num2domain,
--                     s_description,
--                     s_domain,
--                     x_dll,
--                     x_programmable_flag,
--                     x_technology,
--                     x_upc,
--                     x_restricted_use --CR3190
--                  ) VALUES(
--                     r_seq_part_num_val,
--                     'Active',
--                     inv_rec.tf_part_num_parent,
--                     UPPER (inv_rec.tf_part_num_parent),
--                     item_rec.description,
--                     item_rec.charge_code,
--                     SUBSTR (inv_rec.tf_manuf_location_name, 1, 20),
--                     item_rec.clfy_domain,
--                     item_rec.redemption_days,
--                     item_rec.redemption_units,
--                     domain_objid_rec.objid,
--                     UPPER (item_rec.description),
--                     UPPER (item_rec.clfy_domain),
--                     item_rec.dll,
--                     item_rec.programming_flag,
--                     item_rec.technology,
--                     item_rec.upc,
--                     l_restricted_use --CR3190
--                  );
--                  l_action := 'Insert Table_Mod_Level - New Part';
--                  sp_seq('mod_level', r_seq_mod_level_val);
--                  INSERT
--                  INTO table_mod_level(
--                     objid,
--                     active,
--                     mod_level,
--                     s_mod_level,
--                     eff_date,
--                     x_timetank,
--                     part_info2part_num
--                  ) VALUES(
--                     r_seq_mod_level_val,
--                     'Active',
--                     l_revision,
--                     UPPER (l_revision),
--                     SYSDATE,
--                     0,
--                     r_seq_part_num_val
--                  );
-----Begin Remove logic to update table_part_num
    --  ELSE
                 -- l_action := 'Update table_part_num';

                /*  UPDATE table_part_num
                     SET part_type = item_rec.charge_code,
                         x_manufacturer =
                                SUBSTR (inv_rec.tf_manuf_location_name, 1, 20),
                         domain = item_rec.clfy_domain,
                         s_domain = UPPER (item_rec.clfy_domain),
                         x_technology = item_rec.technology,
                         x_upc = item_rec.upc,
                         x_conversion = NVL (item_rec.conversion_rate, 0)
                   --CR4981_4982
                  WHERE  domain = item_rec.clfy_domain
                     AND part_number = inv_rec.tf_part_num_parent;
                     */
-----end Remove logic to update table_part_num
--CR4981_4982 Start
                  OPEN get_conv_dtl (item_rec.part_number);

                  FETCH get_conv_dtl
                   INTO get_conv_dtl_rec;

                  IF get_conv_dtl%NOTFOUND
                  THEN
                     CLOSE get_conv_dtl;

                     sa.sp_seq ('x_ext_conversion_hist', l_convhist_objid);

                     INSERT INTO table_x_ext_conversion_hist
                                 (objid, dev, x_start_date, x_end_date,
                                  x_conversion,
                                  conv_hist2part_num
                                 )
                          VALUES (l_convhist_objid, 1, SYSDATE, NULL,
                                  item_rec.conversion_rate,
                                  r_part_exists.objid
                                 );
                  ELSE
                     IF NVL (item_rec.conversion_rate, 0) <>
                                       NVL (get_conv_dtl_rec.x_conversion, 0)
                     THEN
                        UPDATE table_x_ext_conversion_hist
                           SET x_end_date = SYSDATE - 1
                         WHERE conv_hist2part_num = r_part_exists.objid;

                        sa.sp_seq ('x_ext_conversion_hist', l_convhist_objid);

                        INSERT INTO table_x_ext_conversion_hist
                                    (objid, dev, x_start_date, x_end_date,
                                     x_conversion,
                                     conv_hist2part_num
                                    )
                             VALUES (l_convhist_objid, 1, SYSDATE, NULL,
                                     item_rec.conversion_rate,
                                     r_part_exists.objid
                                    );
                     END IF;
                  END IF;

                  COMMIT;

                  CLOSE get_conv_dtl;

--CR4981_4982 End
----Remove logic to insert/update table_mod_level.
            /*      OPEN mod_level_exists_cur (r_part_exists.objid, l_revision);

                  FETCH mod_level_exists_cur
                   INTO mod_level_exists_rec;

                  IF mod_level_exists_cur%FOUND
                  THEN
                     l_action := 'Update table_mod_level';

                     UPDATE table_mod_level
                        SET mod_level = l_revision,
                            s_mod_level = UPPER (l_revision),
                            eff_date = SYSDATE,
                            x_timetank = 0
                      WHERE part_info2part_num = r_part_exists.objid
                        AND active = 'Active'
                        AND mod_level = l_revision;
                  ELSE
                     OPEN mod_level_null_objid_cur (r_part_exists.objid);

                     FETCH mod_level_null_objid_cur
                      INTO mod_level_null_objid_rec;

                     IF mod_level_null_objid_cur%FOUND
                     THEN
                        l_action :=
                           'Update Mod_Level - Existing Part with NULL revision for NULL revision';

                        UPDATE table_mod_level
                           SET mod_level = l_revision,
                               s_mod_level = UPPER (l_revision),
                               eff_date = SYSDATE,
                               x_timetank = 0
                         WHERE objid = mod_level_null_objid_rec.objid;
                     ELSE
                        sp_seq ('mod_level', r_seq_mod_level_val);
                        l_action :=
                           'Insert Mod_Level - Existing Part with NULL revision ';

                        INSERT INTO table_mod_level
                                    (objid, active,
                                     mod_level, s_mod_level,
                                     eff_date, x_timetank, part_info2part_num
                                    )
                             VALUES (r_seq_mod_level_val, 'Active',
                                     l_revision, UPPER (l_revision),
                                     SYSDATE, 0, r_part_exists.objid
                                    );
                     END IF;

                     CLOSE mod_level_null_objid_cur;
                  END IF;                         -- end of mod level check

                  CLOSE mod_level_exists_cur;
                  */
         END IF;                      /* end of part number check */

         CLOSE part_exists_cur;

               /* get mod level objid based on TABLE_PART_NUMBER **/
               OPEN mod_level_objid_cur (inv_rec.tf_part_num_parent,
                                         l_revision,
                                         item_rec.clfy_domain
                                        );

               FETCH mod_level_objid_cur
                INTO l_part_inst2part_mod;

               CLOSE mod_level_objid_cur;
            END IF;                          /*** of same part number check */
                                     /* Check ACTIVATION */

            IF inv_rec.toss_extract_flag = 'NOA'
            THEN
               /* Try part inst */
               OPEN check_part_inst_cur (inv_rec.tf_serial_num,
                                         item_rec.clfy_domain
                                        );

               FETCH check_part_inst_cur
                INTO check_part_inst_rec;

               IF check_part_inst_cur%FOUND
               THEN
                  /* HANDLE UPDATE IN PART INST */
                  l_action := 'insert part_inst and card_inv';

                  IF l_inv_status = '45'
                  THEN
                     -- CR4659: Added to check PosaSwipe existence
                     SELECT COUNT (1)
                       INTO l_intposaswipe
                       FROM x_posa_card
                      WHERE tf_serial_num = inv_rec.tf_serial_num;

                     IF l_intposaswipe = 0
                     THEN                          -- CR4659 : No swipes exist
                         /* CONVERTING NON POSA TO POSA */
                        /*** INSERT INTO X_POSA_INV ***/
                        sp_seq ('x_posa_card_inv', l_posa_card_inv_seq);

                        INSERT INTO table_x_posa_card_inv
                                    (objid,
                                     x_part_serial_no,
                                     x_domain,
                                     x_red_code, x_posa_inv_status,
                                     x_inv_insert_date,
                                     x_last_ship_date,
                                     x_tf_po_number,
                                     x_tf_order_number, x_last_update_date,
                                     x_created_by2user,
                                     x_last_update_by2user,
                                     x_posa_status2x_code_table,
                                     x_posa_inv2part_mod,
                                     x_posa_inv2inv_bin
                                    )
                             VALUES (l_posa_card_inv_seq,
                                     inv_rec.tf_serial_num,
                                     item_rec.clfy_domain,
                                     inv_rec.tf_card_pin_num, l_inv_status,
                                     inv_rec.creation_date,
                                     NVL (inv_rec.retailer_ship_date,
                                          NVL (inv_rec.creation_date,
                                               inv_rec.ff_receive_date
                                              )
                                         ),
                                     inv_rec.tf_po_num,
                                     inv_rec.tf_order_num, SYSDATE,
                                     user_objid_rec.objid,
                                     user_objid_rec.objid,
                                     status_code_objid_rec.objid,
                                     l_part_inst2part_mod,
                                     inv_bin_objid_rec.objid
                                    );

                        /*** INSERT CHANGE  in HIST  ***/
                        sp_seq ('x_pi_hist', l_pi_hist_seq);

                        INSERT INTO table_x_pi_hist
                                    (objid, x_change_date,
                                     x_change_reason, x_pi_hist2part_inst,
                                     x_part_serial_no,
                                     x_domain,
                                     x_red_code,
                                     x_part_inst_status,
                                     x_insert_date,
                                     x_creation_date,
                                     x_po_num,
                                     x_order_number,
                                     x_last_mod_time,
                                     x_pi_hist2user,
                                     status_hist2x_code_table,
                                     x_pi_hist2part_mod,
                                     x_pi_hist2inv_bin
                                    )
                             VALUES (l_pi_hist_seq, SYSDATE,
                                     'INVENTORY ADJUSTMENT', l_pi_seq,
                                     check_part_inst_rec.part_serial_no,
                                     check_part_inst_rec.x_domain,
                                     check_part_inst_rec.x_red_code,
                                     check_part_inst_rec.x_part_inst_status,
                                     check_part_inst_rec.x_insert_date,
                                     check_part_inst_rec.x_creation_date,
                                     check_part_inst_rec.x_po_num,
                                     check_part_inst_rec.x_order_number,
                                     check_part_inst_rec.last_mod_time,
                                     check_part_inst_rec.created_by2user,
                                     check_part_inst_rec.status2x_code_table,
                                     check_part_inst_rec.n_part_inst2part_mod,
                                     check_part_inst_rec.part_inst2inv_bin
                                    );

                        /*** DELETE FROM TABLE_PART_INST ***/
                        DELETE FROM table_part_inst
                              WHERE part_serial_no = inv_rec.tf_serial_num;
                     END IF;

                     l_action := 'Update tf_toss_interface_table';
                     l_redemp_code := l_inv_status;
                     l_action := 'Update tf_toss_interface_table 3';

                     UPDATE tf.tf_toss_interface_table@ofsprd
                        SET toss_extract_flag = 'YES',
                            toss_extract_date = SYSDATE,
                            --update with timestamp
                            toss_redemption_code = l_redemp_code,
                            last_update_date = SYSDATE,
                            last_updated_by = l_procedure_name
                      WHERE ROWID = inv_rec.ROWID;
                  /* of sqlrowcount */
                  ELSIF l_inv_status = '42'
                  THEN
                     /* UPDATING  NON POSA */
                     /*** HANDLE 75 AND 44 **********/
                     UPDATE table_part_inst
                        -- CR17825 Start kacosta 09/26/2011
                        --SET x_part_inst_status =
                        --       DECODE (l_inv_status,
                        --               '45', x_part_inst_status,
                        --               '42', l_inv_status,
                        --               x_part_inst_status
                        --              ),
                        --    status2x_code_table =
                        --       DECODE (l_inv_status,
                        --               '45', status2x_code_table,
                        --               '42', status_code_objid_rec.objid,
                        --               status2x_code_table
                        --              ),
                        SET x_part_inst_status = CASE
                                                   WHEN x_part_inst_status IN ('263','400')
                                                     OR l_inv_status = '45' THEN
                                                     x_part_inst_status
                                                   ELSE
                                                     l_inv_status
                                                 END,
                            status2x_code_table = CASE
                                                   WHEN x_part_inst_status IN ('263','400')
                                                     OR l_inv_status = '45' THEN
                                                     status2x_code_table
                                                   ELSE
                                                     status_code_objid_rec.objid
                                                 END,
                            -- CR17825 End kacosta 09/26/2011
                            x_creation_date = l_creation_date,
                            x_order_number = inv_rec.tf_order_num,
                            created_by2user = user_objid_rec.objid,
                            x_domain = item_rec.clfy_domain,
                            last_pi_date =
                                          TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            last_cycle_ct =
                                          TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            next_cycle_ct =
                                          TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            last_mod_time =
                                          TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            last_trans_time =
                                          TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            date_in_serv =
                                          TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            repair_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            n_part_inst2part_mod = l_part_inst2part_mod,
                            part_inst2inv_bin = inv_bin_objid_rec.objid
                      WHERE part_serial_no = inv_rec.tf_serial_num
                        AND x_domain = item_rec.clfy_domain;

                     sp_seq ('x_pi_hist', l_pi_hist_seq);

                     INSERT INTO table_x_pi_hist
                                 (objid, x_change_date,
                                  x_change_reason, x_pi_hist2part_inst,
                                  x_part_serial_no,
                                  x_domain,
                                  x_red_code,
                                  x_part_inst_status,
                                  x_insert_date,
                                  x_creation_date,
                                  x_po_num,
                                  x_order_number,
                                  x_last_mod_time,
                                  x_pi_hist2user,
                                  status_hist2x_code_table,
                                  x_pi_hist2part_mod,
                                  x_pi_hist2inv_bin
                                 )
                          VALUES (l_pi_hist_seq, SYSDATE,
                                  'INVENTORY ADJUSTMENT', l_pi_seq,
                                  check_part_inst_rec.part_serial_no,
                                  check_part_inst_rec.x_domain,
                                  check_part_inst_rec.x_red_code,
                                  check_part_inst_rec.x_part_inst_status,
                                  check_part_inst_rec.x_insert_date,
                                  check_part_inst_rec.x_creation_date,
                                  check_part_inst_rec.x_po_num,
                                  check_part_inst_rec.x_order_number,
                                  check_part_inst_rec.last_mod_time,
                                  check_part_inst_rec.created_by2user,
                                  check_part_inst_rec.status2x_code_table,
                                  check_part_inst_rec.n_part_inst2part_mod,
                                  check_part_inst_rec.part_inst2inv_bin
                                 );

                     IF SQL%ROWCOUNT != 0
                     THEN
                        l_action := 'Update tf_toss_interface_table';
                        l_redemp_code := l_inv_status;
                        l_action := 'Update tf_toss_interface_table 3';

                        UPDATE tf.tf_toss_interface_table@ofsprd
                           SET toss_extract_flag = 'YES',
                               toss_extract_date = SYSDATE,
                               --update with timestamp
                               toss_redemption_code = l_redemp_code,
                               last_update_date = SYSDATE,
                               last_updated_by = l_procedure_name
                         WHERE ROWID = inv_rec.ROWID;
                     END IF;
                  /* of sqlrowcount */
                  END IF;
               ELSE
                  /* Try if posa inventory */
                  OPEN check_posa_card_cur (inv_rec.tf_serial_num);

                  FETCH check_posa_card_cur
                   INTO check_posa_card_rec;

                  IF check_posa_card_cur%FOUND
                  THEN
                     /* HANDLE UPDATE POSA CARD*/
                     l_action := 'insert part_inst and card_inv';

                     IF l_inv_status = '42'
                     THEN
                        sp_seq ('part_inst', l_pi_seq);

                        INSERT INTO table_part_inst
                                    (objid, part_serial_no,
                                     x_part_inst_status, x_sequence,
                                     x_red_code,
                                     x_order_number, x_creation_date,
                                     created_by2user,
                                     x_domain,
                                     n_part_inst2part_mod,
                                     part_inst2inv_bin, part_status,
                                     x_insert_date,
                                     status2x_code_table,
                                     last_pi_date,
                                     last_cycle_ct,
                                     next_cycle_ct,
                                     last_mod_time,
                                     last_trans_time,
                                     date_in_serv,
                                     repair_date
                                    )
                             VALUES (l_pi_seq, inv_rec.tf_serial_num,
                                     l_inv_status, 0,
                                     inv_rec.tf_card_pin_num,
                                     inv_rec.tf_order_num, l_creation_date,
                                     -- changed from sysdate G.P. 12-15-2000
                                     user_objid_rec.objid,
                                     item_rec.clfy_domain,
                                     l_part_inst2part_mod,
                                     inv_bin_objid_rec.objid, 'Active',
                                     inv_rec.creation_date,         --SYSDATE,
                                     status_code_objid_rec.objid,
                                     TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                                     TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                                     TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                                     TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                                     TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                                     TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                                     TO_DATE ('01-01-1753', 'DD-MM-YYYY')
                                    );

                        sp_seq ('x_pi_hist', l_pi_hist_seq);

                        INSERT INTO table_x_pi_hist
                                    (objid, x_change_date,
                                     x_change_reason, x_pi_hist2part_inst,
                                     x_part_serial_no,
                                     x_domain,
                                     x_red_code,
                                     x_part_inst_status,
                                     x_insert_date,
                                     x_creation_date,
                                     x_po_num,
                                     x_order_number,
                                     x_last_mod_time,
                                     x_pi_hist2user,
                                     status_hist2x_code_table,
                                     x_pi_hist2part_mod,
                                     x_pi_hist2inv_bin
                                    )
                             VALUES (l_pi_hist_seq, SYSDATE,
                                     'INVENTORY ADJUSTMENT', l_pi_seq,
                                     check_posa_card_rec.x_part_serial_no,
                                     check_posa_card_rec.x_domain,
                                     check_posa_card_rec.x_red_code,
                                     check_posa_card_rec.x_posa_inv_status,
                                     check_posa_card_rec.x_inv_insert_date,
                                     check_posa_card_rec.x_last_ship_date,
                                     check_posa_card_rec.x_tf_po_number,
                                     check_posa_card_rec.x_tf_order_number,
                                     check_posa_card_rec.x_last_update_date,
                                     check_posa_card_rec.x_created_by2user,
                                     check_posa_card_rec.x_posa_status2x_code_table,
                                     check_posa_card_rec.x_posa_inv2part_mod,
                                     check_posa_card_rec.x_posa_inv2inv_bin
                                    );

                        DELETE FROM table_x_posa_card_inv
                              WHERE x_part_serial_no = inv_rec.tf_serial_num;

                        IF SQL%ROWCOUNT != 0
                        THEN
                           l_action := 'Update tf_toss_interface_table';
                           l_redemp_code := l_inv_status;
                           l_action := 'Update tf_toss_interface_table 3';

                           UPDATE tf.tf_toss_interface_table@ofsprd
                              SET toss_extract_flag = 'YES',
                                  toss_extract_date = SYSDATE,
                                  --update with timestamp
                                  toss_redemption_code = l_redemp_code,
                                  last_update_date = SYSDATE,
                                  last_updated_by = l_procedure_name
                            WHERE ROWID = inv_rec.ROWID;
                        END IF;
                     /* of sqlrowcount */
                     ELSIF l_inv_status = '45'
                     THEN
                        UPDATE table_x_posa_card_inv
                           SET x_part_serial_no = inv_rec.tf_serial_num,
                               x_domain = item_rec.clfy_domain,
                               x_red_code = inv_rec.tf_card_pin_num,
                               x_posa_inv_status = l_inv_status,
                               x_inv_insert_date = inv_rec.creation_date,
                               x_last_ship_date =
                                  NVL (inv_rec.retailer_ship_date,
                                       NVL (inv_rec.creation_date,
                                            inv_rec.ff_receive_date
                                           )
                                      ),
                               x_tf_po_number = inv_rec.tf_po_num,
                               x_tf_order_number = inv_rec.tf_order_num,
                               x_last_update_date = SYSDATE,
                               x_created_by2user = x_created_by2user,
                               x_last_update_by2user = user_objid_rec.objid,
                               x_posa_status2x_code_table =
                                                   status_code_objid_rec.objid,
                               x_posa_inv2part_mod = l_part_inst2part_mod,
                               x_posa_inv2inv_bin = inv_bin_objid_rec.objid
                         WHERE x_part_serial_no = inv_rec.tf_serial_num;

                        sp_seq ('x_pi_hist', l_pi_hist_seq);

                        INSERT INTO table_x_pi_hist
                                    (objid, x_change_date,
                                     x_change_reason, x_pi_hist2part_inst,
                                     x_part_serial_no,
                                     x_domain,
                                     x_red_code,
                                     x_part_inst_status,
                                     x_insert_date,
                                     x_creation_date,
                                     x_po_num,
                                     x_order_number,
                                     x_last_mod_time,
                                     x_pi_hist2user,
                                     status_hist2x_code_table,
                                     x_pi_hist2part_mod,
                                     x_pi_hist2inv_bin
                                    )
                             VALUES (l_pi_hist_seq, SYSDATE,
                                     'INVENTORY ADJUSTMENT', l_pi_seq,
                                     check_posa_card_rec.x_part_serial_no,
                                     check_posa_card_rec.x_domain,
                                     check_posa_card_rec.x_red_code,
                                     check_posa_card_rec.x_posa_inv_status,
                                     check_posa_card_rec.x_inv_insert_date,
                                     check_posa_card_rec.x_last_ship_date,
                                     check_posa_card_rec.x_tf_po_number,
                                     check_posa_card_rec.x_tf_order_number,
                                     check_posa_card_rec.x_last_update_date,
                                     check_posa_card_rec.x_created_by2user,
                                     check_posa_card_rec.x_posa_status2x_code_table,
                                     check_posa_card_rec.x_posa_inv2part_mod,
                                     check_posa_card_rec.x_posa_inv2inv_bin
                                    );

                        l_action := 'Update tf_toss_interface_table 5';

                        IF SQL%ROWCOUNT != 0
                        THEN
                           l_action := 'Update tf_toss_interface_table';
                           l_redemp_code := l_inv_status;

                           UPDATE tf.tf_toss_interface_table@ofsprd
                              SET toss_extract_flag = 'YES',
                                  toss_extract_date = SYSDATE,
                                  --update with timestamp
                                  toss_redemption_code = l_redemp_code,
                                  last_update_date = SYSDATE,
                                  last_updated_by = l_procedure_name
                            WHERE ROWID = inv_rec.ROWID;
                        END IF;
                     /* sql rowcount check */
                     END IF;
                  /* of check 42 45 inside posa card */
                  ELSE
                     /* NOT FOUND IN INVENTORY TABLE.. MIGHT BE MARKE WRONGLY **/
                     l_action :=
                        'Could not validate/activate card. NO inventory found';
                     toss_util_pkg.insert_error_tab_proc
                                                        (   'Inner Block : '
                                                         || l_action
                                                         || ' Could not ',
                                                         l_serial_num,
                                                         l_procedure_name
                                                        );
                  END IF;

                  CLOSE check_posa_card_cur;
               END IF;

               CLOSE check_part_inst_cur;
            ELSIF inv_rec.toss_extract_flag = 'NOV'
            THEN
               /* now check NOV **/
               IF inv_rec.tf_ret_location_code IS NOT NULL
               THEN
                  l_inv_status := '75';                 -- return to retailer
                  l_status_code_objid := 2544;
               ELSE
                  l_inv_status := '44';                        --invalidating
                  l_status_code_objid := 1144;
               END IF;

               OPEN check_part_inst_cur (inv_rec.tf_serial_num,
                                         item_rec.clfy_domain
                                        );

               FETCH check_part_inst_cur
                INTO check_part_inst_rec;

               IF check_part_inst_cur%FOUND
               THEN
                  /* HANDLE UPDATE IN PART INST */
                  UPDATE table_part_inst
                     -- CR17825 Start kacosta 09/26/2011
                     --SET x_part_inst_status = l_inv_status,
                     --    status2x_code_table = l_status_code_objid,
                     SET x_part_inst_status = CASE
                                                WHEN x_part_inst_status IN ('263','400') THEN
                                                  x_part_inst_status
                                                ELSE
                                                  l_inv_status
                                              END,
                         status2x_code_table = CASE
                                                 WHEN x_part_inst_status IN ('263','400') THEN
                                                   status2x_code_table
                                                 ELSE
                                                   l_status_code_objid
                                               END,
                     -- CR17825 End kacosta 09/26/2011
                         n_part_inst2part_mod = l_part_inst2part_mod,
                         part_inst2inv_bin = inv_bin_objid_rec.objid
                   WHERE part_serial_no = inv_rec.tf_serial_num;

                  sp_seq ('x_pi_hist', l_pi_hist_seq);              --06/16/03

                  INSERT INTO table_x_pi_hist
                              (objid, status_hist2x_code_table,
                               x_change_date, x_change_reason,
                               x_cool_end_date,
                               x_creation_date,
                               x_deactivation_flag,
                               x_domain,
                               x_ext,
                               x_insert_date,
                               x_npa,
                               x_nxx, x_old_ext, x_old_npa, x_old_nxx,
                               x_part_bin, x_part_inst_status,
                               x_part_mod,
                               x_part_serial_no,
                               x_part_status,
                               x_pi_hist2carrier_mkt,
                               x_pi_hist2inv_bin,
                               x_pi_hist2part_inst,
                               x_pi_hist2part_mod,
                               x_pi_hist2user,
                               x_pi_hist2x_new_pers,
                               x_pi_hist2x_pers,
                               x_po_num,
                               x_reactivation_flag,
                               x_red_code,
                               x_sequence,
                               x_warr_end_date,
                               dev,
                               fulfill_hist2demand_dtl,
                               part_to_esn_hist2part_inst,
                               x_bad_res_qty,
                               x_date_in_serv,
                               x_good_res_qty,
                               x_last_cycle_ct,
                               x_last_mod_time,
                               x_last_pi_date,
                               x_last_trans_time,
                               x_next_cycle_ct,
                               x_order_number,
                               x_part_bad_qty,
                               x_part_good_qty,
                               x_pi_tag_no,
                               x_pick_request,
                               x_repair_date,
                               x_transaction_id
                              )
                       VALUES (l_pi_hist_seq, l_status_code_objid,
                               SYSDATE, 'DESTROYED',
                               check_part_inst_rec.x_cool_end_date,
                               check_part_inst_rec.x_creation_date,
                               check_part_inst_rec.x_deactivation_flag,
                               check_part_inst_rec.x_domain,
                               check_part_inst_rec.x_ext,
                               check_part_inst_rec.x_insert_date,
                               check_part_inst_rec.x_npa,
                               check_part_inst_rec.x_nxx, NULL, NULL, NULL,
                               check_part_inst_rec.part_bin, l_inv_status,
                               check_part_inst_rec.part_mod,
                               check_part_inst_rec.part_serial_no,
                               check_part_inst_rec.part_status,
                               check_part_inst_rec.part_inst2carrier_mkt,
                               inv_bin_objid_rec.objid,
                               check_part_inst_rec.objid,
                               l_part_inst2part_mod,
                               check_part_inst_rec.created_by2user,
                               check_part_inst_rec.part_inst2x_new_pers,
                               check_part_inst_rec.part_inst2x_pers,
                               check_part_inst_rec.x_po_num,
                               check_part_inst_rec.x_reactivation_flag,
                               check_part_inst_rec.x_red_code,
                               check_part_inst_rec.x_sequence,
                               check_part_inst_rec.warr_end_date,
                               check_part_inst_rec.dev,
                               check_part_inst_rec.fulfill2demand_dtl,
                               check_part_inst_rec.part_to_esn2part_inst,
                               check_part_inst_rec.bad_res_qty,
                               check_part_inst_rec.date_in_serv,
                               check_part_inst_rec.good_res_qty,
                               check_part_inst_rec.last_cycle_ct,
                               check_part_inst_rec.last_mod_time,
                               check_part_inst_rec.last_pi_date,
                               check_part_inst_rec.last_trans_time,
                               check_part_inst_rec.next_cycle_ct,
                               check_part_inst_rec.x_order_number,
                               check_part_inst_rec.part_bad_qty,
                               check_part_inst_rec.part_good_qty,
                               check_part_inst_rec.pi_tag_no,
                               check_part_inst_rec.pick_request,
                               check_part_inst_rec.repair_date,
                               check_part_inst_rec.transaction_id
                              );

                  /** UPDATE HISTORY **/
                  IF SQL%ROWCOUNT != 0
                  THEN
                     l_action := 'Update tf_toss_interface_table';
                     l_redemp_code := l_inv_status;
                     l_action := 'Update tf_toss_interface_table 3';

                     UPDATE tf.tf_toss_interface_table@ofsprd
                        SET toss_extract_flag = 'YES',
                            toss_extract_date = SYSDATE,
                            --update with timestamp
                            toss_redemption_code = l_redemp_code,
                            last_update_date = SYSDATE,
                            last_updated_by = l_procedure_name
                      WHERE ROWID = inv_rec.ROWID;
                  END IF;
               /* of sqlrowcount */
               ELSE
                  /* Try if posa inventory */
                  OPEN check_posa_card_cur (inv_rec.tf_serial_num);

                  FETCH check_posa_card_cur
                   INTO check_posa_card_rec;

                  IF check_posa_card_cur%FOUND
                  THEN
                     /* HANDLE UPDATE POSA CARD*/
                     l_action := 'insert part_inst and card_inv';

                     UPDATE table_x_posa_card_inv
                        SET x_posa_inv_status = l_inv_status,
                            x_posa_status2x_code_table = l_status_code_objid,
                            x_posa_inv2part_mod = l_part_inst2part_mod,
                            x_posa_inv2inv_bin = inv_bin_objid_rec.objid
                      WHERE x_part_serial_no = inv_rec.tf_serial_num;

                     sp_seq ('x_pi_hist', l_pi_hist_seq);

                     INSERT INTO table_x_pi_hist
                                 (objid, x_change_date, x_change_reason,
                                  x_pi_hist2part_inst,
                                  x_part_serial_no,
                                  x_domain,
                                  x_red_code,
                                  x_part_inst_status,
                                  x_insert_date,
                                  x_creation_date,
                                  x_po_num,
                                  x_order_number,
                                  x_last_mod_time,
                                  x_pi_hist2user,
                                  status_hist2x_code_table,
                                  x_pi_hist2part_mod,
                                  x_pi_hist2inv_bin
                                 )
                          VALUES (l_pi_hist_seq, SYSDATE, 'DESTROYED',
                                  l_pi_seq,
                                  check_posa_card_rec.x_part_serial_no,
                                  check_posa_card_rec.x_domain,
                                  check_posa_card_rec.x_red_code,
                                  check_posa_card_rec.x_posa_inv_status,
                                  check_posa_card_rec.x_inv_insert_date,
                                  check_posa_card_rec.x_last_ship_date,
                                  check_posa_card_rec.x_tf_po_number,
                                  check_posa_card_rec.x_tf_order_number,
                                  check_posa_card_rec.x_last_update_date,
                                  check_posa_card_rec.x_created_by2user,
                                  check_posa_card_rec.x_posa_status2x_code_table,
                                  check_posa_card_rec.x_posa_inv2part_mod,
                                  check_posa_card_rec.x_posa_inv2inv_bin
                                 );

                     l_action := 'Update tf_toss_interface_table 5';

                     IF SQL%ROWCOUNT != 0
                     THEN
                        l_action := 'Update tf_toss_interface_table';
                        l_redemp_code := l_inv_status;

                        UPDATE tf.tf_toss_interface_table@ofsprd                  -- Change the database link to ofsprd
                           SET toss_extract_flag = 'YES',
                               toss_extract_date = SYSDATE,
                               --update with timestamp
                               toss_redemption_code = l_redemp_code,
                               last_update_date = SYSDATE,
                               last_updated_by = l_procedure_name
                         WHERE ROWID = inv_rec.ROWID;
                     END IF;
                  /* sql rowcount check */
                  ELSE
                     /* NOT FOUND IN INVENTORY TABLE.. MIGHT BE MARKE WRONGLY **/
                     l_action :=
                              'Could not invalidate card. NO inventory found';
                     toss_util_pkg.insert_error_tab_proc
                                                        (   'Inner Block : '
                                                         || l_action
                                                         || ' Could not ',
                                                         l_serial_num,
                                                         l_procedure_name
                                                        );
                  END IF;

                  CLOSE check_posa_card_cur;
               END IF;

               CLOSE check_part_inst_cur;
            END IF;
         ELSE
            /* new skip status on tf_toss_interface */
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
            clean_up_prc;
         WHEN no_site_id_exp
         THEN
            toss_util_pkg.insert_error_tab_proc ('Inner Block : ' || l_action,
                                                 l_serial_num,
                                                 l_procedure_name,
                                                 'NO SITE ID'
                                                );
            clean_up_prc;
         WHEN distributed_trans_time_out
         THEN
            toss_util_pkg.insert_error_tab_proc
                                       (   'Inner Block : '
                                        || l_action
                                        || ' Caught distributed_trans_time_out',
                                        l_serial_num,
                                        l_procedure_name
                                       );
            clean_up_prc;
         WHEN record_locked
         THEN
            toss_util_pkg.insert_error_tab_proc (   'Inner Block : '
                                                 || l_action
                                                 || ' Caught record_locked ',
                                                 l_serial_num,
                                                 l_procedure_name
                                                );
            clean_up_prc;
         WHEN DUP_VAL_ON_INDEX
         THEN
            toss_util_pkg.insert_error_tab_proc
               (l_action,
                l_serial_num,
                l_procedure_name,
                'Inner Block Error : Duplicate Value on index: Updating extract flag to D2'
               );

            /* UPDATE FLAG TO D2 */
            UPDATE tf.tf_toss_interface_table@ofsprd
               SET toss_extract_flag = 'D2',
                   last_update_date = SYSDATE,
                   last_updated_by = l_procedure_name
             WHERE ROWID = inv_rec.ROWID;

            clean_up_prc;
         WHEN OTHERS
         THEN
            toss_util_pkg.insert_error_tab_proc ('Inner Block : ' || l_action,
                                                 l_serial_num,
                                                 l_procedure_name
                                                );
            clean_up_prc;
      END;

      /** commit every 1000 */
      -- IF MOD(l_commit_counter,1000) = 0 THEN
      COMMIT;
      -- END IF;
      /***************** Set current to previous  *******************/
      l_previous_part_number := l_current_part_number;
      l_previuos_retailer := l_current_retailer;
      l_previuos_ff_center := l_current_ff_center;
      --
      l_previuos_manf := l_current_manf;
/***************************************************/
   END LOOP;                                         /* end of inv_rec loop */

   COMMIT;
   clean_up_prc;

   --Change the call to interface_jobs_fun from "update" to "insert" into x_toss_interface_jobs
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

   /** procedure executed sucessfully (graceous exiting--not hiting outer exception handler */
   ip_completion_status := TRUE;
EXCEPTION
   WHEN distributed_trans_time_out
   THEN
      toss_util_pkg.insert_error_tab_proc
                                       (   l_action
                                        || ' Caught distributed_trans_time_out',
                                        l_serial_num,
                                        l_procedure_name
                                       );

      --Change the call to interface_jobs_fun from "update" to "insert" into x_toss_interface_jobs
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

      clean_up_prc;
      /** procedure exited hiting the outer exception handler (major application failure) */
      ip_completion_status := FALSE;
   WHEN record_locked
   THEN
      toss_util_pkg.insert_error_tab_proc (l_action
                                           || ' Caught record_locked ',
                                           l_serial_num,
                                           l_procedure_name
                                          );

      --Change the call to interface_jobs_fun from "update" to "insert" into x_toss_interface_jobs
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

      clean_up_prc;
      /** procedure exited hiting the outer exception handler (major application failure) */
      ip_completion_status := FALSE;
   WHEN OTHERS
   THEN
      toss_util_pkg.insert_error_tab_proc (l_action,
                                           l_serial_num,
                                           l_procedure_name
                                          );

      --Change the call to interface_jobs_fun from "update" to "insert" into x_toss_interface_jobs
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

      clean_up_prc;
      /** procedure exited hiting the outer exception handler (major application failure) */
      ip_completion_status := FALSE;
END inbound_cards_inv_other_prc;
/