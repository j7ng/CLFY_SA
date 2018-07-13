CREATE OR REPLACE PROCEDURE sa."INBOUND_CARDS_INV_NEWC_PRC" (
   ip_completion_status   IN OUT   BOOLEAN
)
AS
/********************************************************************************************/
/* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved                            */
/*                                                                                          */
/* Name         :   INBOUND_CARDS_INV_NEWC_PRC.sql                                            */
/* Purpose      :   To extract CARDS inventory data from TF_TOSS_INTERFACE_TABLE in Oracle  */
/*                  Financials into TOSS for 'NEWC' flag and update the interface table once*/
/*                  the extract is done                                                     */
/* Parameters   :   NONE                                                                   */
/* Platforms    :   Oracle 8.0.6 AND newer versions                                         */
/* Author       :   Miguel Leon                                                             */
/* Date         :   01/25/2001                                                              */
/* Revisions    :                                                                           */
/* Version  Date      Who              Purpose                                              */
/* -------  --------  -------          -------------------------------------                */
/* 1.0     01/25/2001 Mleon            Initial revision                                     */
/* 1.1     02/06/2002 Mleon            Added "rule based hint to select statements          */
/*                                     referencing tf_toss_interface table.                 */
/* 1.1     02/07/2002 Mleon            Added application err handler for distribute         */
/*                                     transaction time out and record_locked(ora-54)       */
/* 1.3     03/01/2002 Mleon            Added logic to skip statuses changes if              */
/*                                     cards has been swiped. Also changed last_updated_by  */
/*                                     to the name of procedure instead way generic CLARIFY */
/* 1.4     03/02/2002 Mleon            Added IN OUT Boolean parameter to informed status of */
/*                                     completion to external caller procedure.             */
/*                                     TRUE = SUCCESS                                       */
/*                                     FALSE = FAILURE TRY AGAIN                            */
/* 1.5     03/18/2002 Mleon            Added filter to exclude roadside cards in            */
/*                                     inv_cur cur                                    */
/* 1.6     05/31/2002 VAdapa           Specified columns in the insert script to insert into*/
/*                                     table_x_part_script                                  */
/* 1.7     09/13/02   VAdapa           Modified the procedure for the following changes     */
/*                                     1.Update toss_redemption_code with x_part_inst_status*/
/*                                     2.Update toss_extract_date with timestamp            */
/*                                     3.Added the call to interface_jobs_fun to insert     */
/*                                       into x_toss_interface_jobs                         */
/*                                     4.Modified the mod_level inserts and updates logic   */
/*                                     5.Modified the logging of error logic - Logging now  */
/*                                       by calling a packaged function instead directly    */
/*                                     6.Removed the cycle count changes (not required)     */
/* 1.8    03/17/03    Curt             Clarify Upgrade -Posa                                */
/* 1.9    04/10/03    SL               Clarify Upgrade - sequence                           */
/* 2.1    06/06/03    GP               Changed logic to look for DIST and MANUF redemptions */
/*                                     in x_red_card instead of table_part_inst.            */
/* 2.2    11/12/2003  ML               Rewrote the entire procedure to simplified and       */
/*                                     avoid redundant an uncessary logic                   */
/* 2.3    12/27/04    VA               CR3190 - Assign x_restricted_use to '3'              */
/*                                     for NET10 phones                                     */
/* 2.4    10/13/05    GP               CR4659 - Removed logic to insert new part numbers   */
/* 2.5    03/09/06    VA               CR4981_4982 - Logic added to add information for DATA phones and CONVERSION rates
/*                                     (PVCS Revision 1.8)
/* 2.6/1.9  05/17/06  VA               Same verison as in CLFYUPGQ
/* 1.10     06/08/08  CL                CR5349 - Fix for OPEN_CURSORS
/* 1.11     08/16/06  GP               CR5461 - Using TF partNumber transpose
/*          05/02/07  CI               CR6178 - when importing Wagner Pics, make status of cards = 280
           12/20/2008 LS              CR8000 Commented out the partNumber insert
/********************************************************************************************/
/* CVS
/*  1.3-1.5 08/06/2012 CLindner CR21541 Family Plans - Cash Solutions Release               */
/********************************************************************************************/
--Local Variables
   l_action                     VARCHAR2 (50)                      := ' ';
   l_err_text                   VARCHAR2 (4000);
   l_inv_status                 VARCHAR2 (20);
   l_serial_num                 VARCHAR2 (50);
   l_revision                   VARCHAR2 (10);
   l_part_inst2part_mod         NUMBER;
   l_creation_date              DATE;
   l_site_id                    VARCHAR2 (80);
   l_out_action                 VARCHAR2 (50);
   l_out_error                  VARCHAR2 (4000);
   l_procedure_name             VARCHAR2 (80) := 'INBOUND_CARDS_INV_NEWC_PRC';
   l_recs_processed             NUMBER                             := 0;
   l_start_date                 DATE                               := SYSDATE;
   l_commit_counter             NUMBER                             := 0;
   r_seq_part_script_val        NUMBER;
   r_seq_part_num_val           NUMBER;
   r_seq_mod_level_val          NUMBER;
   l_wagner_param_value         VARCHAR2(20); --CR6178
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
   no_wagner_part_exp           EXCEPTION;                          -- CR6178
   distributed_trans_time_out   EXCEPTION;
   record_locked                EXCEPTION;
--
   PRAGMA EXCEPTION_INIT (distributed_trans_time_out, -2049);
   PRAGMA EXCEPTION_INIT (record_locked, -54);
--
/* Cursor to extract CARDS data from TF_TOSS_INTERFACE_TABLE via database link*/
   CURSOR inv_cur
   IS
      SELECT a.ROWID, a.*
        FROM tf_toss_interface_cards_newc a;
/* Cursor to extract new item information from TF_ITEM_V view via database link*/
   CURSOR item_cur (part_no_in IN VARCHAR2)
   IS
      SELECT *
        FROM tf_of_item_v_cards_newc
       WHERE part_number = part_no_in;
   item_rec                     item_cur%ROWTYPE;
   r_chkItemPromo               item_cur%ROWTYPE;
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
                        'POSA CARDS', '45',
                        'WAGNER_VALID','280');
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
   --CR6178
   CURSOR  wagner_param_value_cur
   is select x_param_value from table_x_parameters where x_param_name='WAGNER_PART';
   wagner_param_value_rec    wagner_param_value_cur%rowtype;
--CR4981_4982 End
   /** in the event of exceptions ***/
   PROCEDURE clean_up_prc
   IS
   BEGIN
      /** cleaning up **/
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
      IF get_conv_dtl%ISOPEN
      THEN
         CLOSE get_conv_dtl;
      END IF;
      IF get_conv_dtl%ISOPEN
      THEN
         CLOSE get_conv_dtl;
      END IF;                                                    --CR4981_4982
   END clean_up_prc;
BEGIN                                                            /*OF MAIN  */
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
   --CR6178
   open wagner_param_value_cur;
   fetch wagner_param_value_cur into wagner_param_value_rec;
   if wagner_param_value_cur%notfound then
     raise no_wagner_part_exp;
   end if;
   fetch wagner_param_value_cur into wagner_param_value_rec;
   l_wagner_param_value:=wagner_param_value_rec.x_param_value;
   close wagner_param_value_cur;
   --end CR6178
   FOR inv_rec IN inv_cur
   LOOP
      l_restricted_use := 0;                                         --CR3190
      l_recs_processed := l_recs_processed + 1;
      l_commit_counter := l_commit_counter + 1;
      --CR5461 - TF PartNumber transpose
             OPEN item_cur (inv_rec.tf_part_num_transpose);
             FETCH item_cur
              INTO r_chkItemPromo;
             CLOSE item_cur;
             IF r_chkItemPromo.promo_code IS NULL OR r_chkItemPromo.promo_code = 'NONE'
             THEN
               NULL;
             ELSE /* Assumption: transpose partNo. has a valid promo_code attached
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
      BEGIN                                            /* MAIN INNER BLOCK */
         l_action := ' ';
         l_serial_num := inv_rec.tf_serial_num;
         IF inv_rec.tf_ret_location_code IS NOT NULL
         THEN
            IF (l_current_retailer != l_previuos_retailer)
            THEN
               OPEN site_id_cur (inv_rec.tf_ret_location_code);
               FETCH site_id_cur
                INTO l_site_id;
               IF site_id_cur%FOUND THEN                                      --CR 6451
                 /** GET INV BIN OBJID ***/
                 OPEN inv_bin_objid_cur (l_site_id);
                 FETCH inv_bin_objid_cur
                 INTO inv_bin_objid_rec;
                 CLOSE inv_bin_objid_cur;
               ELSE RAISE no_site_id_exp;
               END IF;
               CLOSE site_id_cur;                                                      --CR 6451
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
               IF site_id_cur%FOUND THEN                                          --CR 6451
                 /** GET INV BIN OBJID ***/
                 OPEN inv_bin_objid_cur (l_site_id);
                 FETCH inv_bin_objid_cur
                 INTO inv_bin_objid_rec;
                 CLOSE inv_bin_objid_cur;
               ELSE RAISE no_site_id_exp;
               END IF;
               CLOSE site_id_cur;                                                           --CR 6451
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
               IF site_id_cur%FOUND THEN                                              --CR 6451
                 /** GET INV BIN OBJID ***/
                 OPEN inv_bin_objid_cur (l_site_id);
                 FETCH inv_bin_objid_cur
                 INTO inv_bin_objid_rec;
                 CLOSE inv_bin_objid_cur;
               ELSE RAISE no_site_id_exp;
               END IF;
               CLOSE site_id_cur;                                                             --CR 6451
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
--cwl 7/30/12
                if item_rec.clfy_domain = 'BUNDLE' then
                  item_rec.clfy_domain := 'REDEMPTION CARDS';
                end if;
--cwl 7/30/12
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
               l_action := 'Checking for existent of PART_NUMBER in TOSS';
               OPEN part_exists_cur (domain_objid_rec.objid,
                                     inv_rec.tf_part_num_parent
                                    );
               FETCH part_exists_cur
                INTO r_part_exists;
               IF part_exists_cur%NOTFOUND
               THEN
                  RAISE no_part_num_exp;   -- CR4659: Insert into error table
----------End remove logic to update part_num
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
                     IF item_rec.conversion_rate <>
                                                get_conv_dtl_rec.x_conversion
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
               END IF;                          /* end of part number check */
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
            IF (item_rec.posa_type = 'NPOSA')
--cwl 7/30/12
                or (inv_rec.TF_MASTER_SERIAL_NUM is not null
                    and inv_rec.TF_MASTER_SERIAL_NUM != inv_rec.tf_serial_num)
--cwl 7/30/12
            THEN
               l_action := 'Insert into table_part_inst';
               l_pi_seq := seq ('part_inst');
               --CR6178
               if inv_rec.tf_part_num_parent=l_wagner_param_value then
                 l_inv_status:='280';
                 OPEN status_code_objid_cur ('WAGNER_VALID');
                 FETCH status_code_objid_cur
                 INTO status_code_objid_rec;
                 CLOSE status_code_objid_cur;
               end if;
               INSERT INTO table_part_inst
                           (objid, part_serial_no, x_part_inst_status,
                            x_sequence, x_red_code,
                            x_order_number, x_creation_date,
                            created_by2user, x_domain,
                            n_part_inst2part_mod, part_inst2inv_bin,
                            part_status, x_insert_date,
                            status2x_code_table,
                            last_pi_date,
                            last_cycle_ct,
                            next_cycle_ct,
                            last_mod_time,
                            last_trans_time,
                            date_in_serv,
                            repair_date,
--cwl 7/30/12
                x_parent_part_serial_no
--cwl 7/30/12
                           )
                    VALUES (l_pi_seq, inv_rec.tf_serial_num,
                            l_inv_status,
                            0, inv_rec.tf_card_pin_num,
                            inv_rec.tf_order_num, l_creation_date,
                            user_objid_rec.objid, item_rec.clfy_domain,
                            l_part_inst2part_mod, inv_bin_objid_rec.objid,
                            'Active', inv_rec.creation_date,        --SYSDATE,
                            status_code_objid_rec.objid,
                            TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                            TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--cwl 7/30/12
                            inv_rec.TF_MASTER_SERIAL_NUM
--cwl 7/30/12
                           );
            ELSE
               --06/04/03
               l_posa_card_inv_seq := seq ('x_posa_card_inv');
--                 insert/* APPEND */ into table_x_posa_card_inv(OBJID                          ,
               INSERT INTO table_x_posa_card_inv
                           (objid, x_part_serial_no,
                            x_domain, x_red_code,
                            x_posa_inv_status, x_inv_insert_date,
                            x_last_ship_date,
                            x_tf_po_number, x_tf_order_number,
                            x_last_update_date, x_created_by2user,
                            x_last_update_by2user,
                            x_posa_status2x_code_table,
                            x_posa_inv2part_mod, x_posa_inv2inv_bin
                           )
                    VALUES (l_posa_card_inv_seq, inv_rec.tf_serial_num,
                            item_rec.clfy_domain, inv_rec.tf_card_pin_num,
                            l_inv_status, inv_rec.creation_date,
                            NVL (inv_rec.retailer_ship_date,
                                 NVL (inv_rec.creation_date,
                                      inv_rec.ff_receive_date
                                     )
                                ),
                            inv_rec.tf_po_num, inv_rec.tf_order_num,
                            SYSDATE, user_objid_rec.objid,
                            user_objid_rec.objid,
                            status_code_objid_rec.objid,
                            l_part_inst2part_mod, inv_bin_objid_rec.objid
                           );
            END IF;
            /** ONLY UPDATE IF SUCCESSFUL INSERT OR UPDATE **/
            IF SQL%ROWCOUNT = 1
            THEN
               l_action := 'Update tf_toss_interface_table';
               l_redemp_code := l_inv_status;
               UPDATE tf_toss_interface_cards_newc
                  SET toss_extract_flag = 'YES',
                      toss_extract_date = SYSDATE,
                      toss_redemption_code = l_redemp_code,
                      last_update_date = SYSDATE,
                      last_updated_by = l_procedure_name
                WHERE ROWID = inv_rec.ROWID;
            END IF;
         ELSE                       /* new skip status on tf_toss_interface */
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
            UPDATE tf_toss_interface_cards_newc
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
      IF MOD (l_commit_counter, 100) = 0
      THEN
         COMMIT;
      END IF;
      /***************** Set current to previous  *******************/
      l_previous_part_number := l_current_part_number;
      l_previuos_retailer := l_current_retailer;
      l_previuos_ff_center := l_current_ff_center;
--
      l_previuos_manf := l_current_manf;
/***************************************************/
   END LOOP;                                         /* end of inv_rec loop */
   COMMIT;
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
   clean_up_prc;
EXCEPTION
   WHEN no_wagner_part_exp
   THEN
      toss_util_pkg.insert_error_tab_proc (l_action
                                           || 'WANGER Card not set up in table_x_parameters ',
                                           l_serial_num,
                                           l_procedure_name
                                          );
      clean_up_prc;
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
      /** procedure exited hiting the outer exception handler (major application failure) */
      ip_completion_status := FALSE;
   WHEN distributed_trans_time_out
   THEN
      toss_util_pkg.insert_error_tab_proc
                                       (   l_action
                                        || ' Caught distributed_trans_time_out',
                                        l_serial_num,
                                        l_procedure_name
                                       );
      clean_up_prc;
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
      /** procedure exited hiting the outer exception handler (major application failure) */
      ip_completion_status := FALSE;
   WHEN record_locked
   THEN
      toss_util_pkg.insert_error_tab_proc (l_action
                                           || ' Caught record_locked ',
                                           l_serial_num,
                                           l_procedure_name
                                          );
      clean_up_prc;
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
      /** procedure exited hiting the outer exception handler (major application failure) */
      ip_completion_status := FALSE;
   WHEN OTHERS
   THEN
      toss_util_pkg.insert_error_tab_proc (l_action,
                                           l_serial_num,
                                           l_procedure_name
                                          );
      clean_up_prc;
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
      /** procedure exited hiting the outer exception handler (major application failure) */
      ip_completion_status := FALSE;
END inbound_cards_inv_newc_prc;
/