CREATE OR REPLACE PROCEDURE sa."INBOUND_CARDS_INV_D2_PRC" AS
--(ip_completion_status IN OUT BOOLEAN) AS
/********************************************************************************************/
/* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved */
/* */
/* Name : SA.INBOUND_CARDS_INV_D2_PRC.sql */
/* Purpose : To extract CARDS inventory data from TF_TOSS_INTERFACE_TABLE in Oracle */
/* Financials into TOSS for 'NEWC' flag and update the interface table once*/
/*                  the extract is done                                                     */
/* Parameters   :   NONE                                                                    */
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
/*                                     inv_cur cur                                          */
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
/* 2.4    10/13/05    GP               CR4659 - Avoid deletion of card if swipe has occured */
/*                                     also removed logic to insert new part numbers        */
/* 2.5/1.7 PVCS  08/16/06    GP        CR5461 - Using TF partNumber transpose
/*  1.8    12/20/2008 LSATULURI CR8000 Commented out the partNumber insert                   */
/********************************************************************************************/
/* CVS
/* 1.4-1.5  08/06/2012 CLindner CR21541 Family Plans - Cash Solutions Release                */
/********************************************************************************************/
--Local Variables
   l_action VARCHAR2 (400) := ' ';
   l_err_text VARCHAR2 (4000);
   l_inv_status VARCHAR2 (20);
   l_serial_num VARCHAR2 (50);
   l_revision VARCHAR2 (10);
   l_part_inst2part_mod NUMBER;
   l_creation_date DATE;
   l_site_id VARCHAR2 (80);
   l_out_action VARCHAR2 (50);
   l_out_error VARCHAR2 (4000);
   l_procedure_name VARCHAR2 (80) := 'INBOUND_CARDS_INV_D2_PRC';
   l_recs_processed NUMBER := 0;
   l_start_date DATE := SYSDATE;
   l_commit_counter NUMBER := 0;
   r_seq_part_script_val NUMBER ;
   r_seq_part_num_val NUMBER;
   r_seq_mod_level_val NUMBER;
   ip_completion_status BOOLEAN;
   l_intPosaSwipe NUMBER := 0; -- CR4659
------------- LOCAL VARIABLES TO AVOID UNNECESSARY TRIPS ---------
   l_previous_part_number VARCHAR2(100);
   l_current_part_number VARCHAR2(100);
--
   l_current_retailer VARCHAR2(100);
   l_previuos_retailer VARCHAR2(100);
--
   l_current_ff_center VARCHAR2(100);
   l_previuos_ff_center VARCHAR2(100);
--
   l_current_manf VARCHAR2(100);
   l_previuos_manf VARCHAR2(100);
--New variables added to update TOSS_REDEMPTION_CODE
   l_smp_status VARCHAR2 (20);
   l_redemp_code VARCHAR2 (20);
   l_pi_seq NUMBER;
   l_pi_hist_seq NUMBER;
   l_posa_card_inv_seq NUMBER;
   l_update_interface VARCHAR2(20);
   l_restricted_use NUMBER := 0; --CR3190
--Exception Variables
   no_site_id_exp EXCEPTION;
   no_part_num_exp EXCEPTION; -- CR4659
   distributed_trans_time_out EXCEPTION;
   record_locked EXCEPTION;
--
   PRAGMA EXCEPTION_INIT(distributed_trans_time_out,  -2049);
   PRAGMA EXCEPTION_INIT(record_locked,  -54);
--
/* Cursor to extract CARDS data from TF_TOSS_INTERFACE_TABLE via database link*/
   CURSOR inv_cur IS
      SELECT A.ROWID,A.*
        FROM TF_TOSS_INTERFACE_CARDS_D2 A ;
/* Cursor to extract new item information from TF_ITEM_V view via database link*/
   CURSOR item_cur (part_no_in IN VARCHAR2) IS
      SELECT *
        FROM TF_OF_ITEM_V_CARDS_D2
       WHERE part_number = part_no_in;
   item_rec item_cur%ROWTYPE;
   r_chkItemPromo item_cur%ROWTYPE;
--
/* Cursor to extract TOSS dealer id based on Financials Customer Id */
   CURSOR site_id_cur (fin_cust_id_in IN VARCHAR2) IS
      SELECT site_id
        FROM TABLE_SITE
       WHERE TYPE = 3
         AND x_fin_cust_id = fin_cust_id_in;
   site_id_rec site_id_cur%ROWTYPE;
--
/* Cursor to get the part clfy_domain object id */
   CURSOR domain_objid_cur (clfy_domain_in IN VARCHAR2) IS
      SELECT objid
        FROM TABLE_PRT_DOMAIN
       WHERE NAME = clfy_domain_in;
   domain_objid_rec domain_objid_cur%ROWTYPE;
--
/* Cursor to get the part number object id */
   CURSOR part_exists_cur (domain2_in IN VARCHAR2,  part_number_in IN VARCHAR2) IS
      SELECT objid
        FROM TABLE_PART_NUM
       WHERE part_number = part_number_in
         AND part_num2domain = domain2_in;
   r_part_exists part_exists_cur%ROWTYPE;
--
/* Cursor to get the mod_level information for the given part number */--Digital
   CURSOR mod_level_exists_cur (part_num_objid_in   IN   VARCHAR2,
                              revision_in         IN   VARCHAR2) IS
      SELECT objid
        FROM TABLE_MOD_LEVEL
       WHERE part_info2part_num = part_num_objid_in
         AND active = 'Active'
         AND mod_level = revision_in;
   mod_level_exists_rec mod_level_exists_cur%ROWTYPE;
/* Cursor to get user object id  */
   CURSOR user_objid_cur IS
      SELECT objid
        FROM TABLE_USER
       WHERE login_name = 'ORAFIN';
   user_objid_rec user_objid_cur%ROWTYPE;
--
/* Cursor to get bin object id */
   CURSOR inv_bin_objid_cur (customer_id_in IN VARCHAR2) IS
      SELECT objid
        FROM TABLE_INV_BIN
       WHERE bin_name = customer_id_in;
   inv_bin_objid_rec inv_bin_objid_cur%ROWTYPE;
--
/* Cursor to get code object id added POSA PHONES */
   CURSOR status_code_objid_cur (clfy_domain4_in IN VARCHAR2) IS
      SELECT objid
        FROM TABLE_X_CODE_TABLE
       WHERE x_code_number = DECODE (clfy_domain4_in,'REDEMPTION CARDS', '42',
                                                  'POSA CARDS', '45');
   status_code_objid_rec status_code_objid_cur%ROWTYPE;
/* Cursor to get part number object id associated with the revision of the part number */
   CURSOR mod_level_objid_cur (part_number_in   IN   VARCHAR2,
                                  revision_in      IN   VARCHAR2,
                                  domain_in        IN   VARCHAR2) IS
      SELECT A.objid
        FROM TABLE_MOD_LEVEL A, TABLE_PART_NUM b
       WHERE A.mod_level = revision_in
         AND A.part_info2part_num = b.objid
         AND A.active = 'Active'   --Digital
         AND b.part_number = part_number_in
         AND b.domain = domain_in;
   mod_level_objid_rec mod_level_objid_cur%ROWTYPE;
--
/* Cursor to check whether mod_level exists for the given part number with NULL revision */
   CURSOR mod_level_null_objid_cur (pn_objid_in IN NUMBER) IS
      SELECT objid
        FROM TABLE_MOD_LEVEL
       WHERE part_info2part_num = pn_objid_in
         AND active = 'Active'
         AND mod_level IS NULL;
   mod_level_null_objid_rec mod_level_null_objid_cur%ROWTYPE;
/* Cursor to check if the serial number exists in part_inst table */
   CURSOR check_part_inst_cur (serial_number_in   IN   VARCHAR2,
                                domain_in         IN   VARCHAR2)
   IS
      SELECT *
        FROM TABLE_PART_INST
       WHERE
          x_domain||'' = domain_in
          AND part_serial_no = serial_number_in;
   check_part_inst_rec check_part_inst_cur%ROWTYPE;
/* Cursor to check if the serial number exists in posa_card table */
   CURSOR check_posa_card_cur (serial_number_in   IN   VARCHAR2)IS
      SELECT *
        FROM TABLE_X_POSA_CARD_INV
       WHERE x_part_serial_no = serial_number_in;
   check_posa_card_rec check_posa_card_cur%ROWTYPE;
/* Cursor to check if the serial number exists in red_card table */
/* check only for completed ones (meaning only then is really redemmed */
   CURSOR check_red_card_cur (serial_number_in   IN   VARCHAR2)
   IS
      SELECT *
        FROM TABLE_X_RED_CARD
       WHERE
             x_result||'' = 'Completed'
         AND x_smp = serial_number_in;
   check_red_card_rec check_red_card_cur%ROWTYPE;
/** in the event of exceptions ***/
PROCEDURE CLEAN_UP_PRC
IS
BEGIN
     /** cleaning up **/
      IF site_id_cur%ISOPEN              THEN CLOSE site_id_cur; END IF;
      IF item_cur%ISOPEN             THEN CLOSE item_cur; END IF;
      IF domain_objid_cur%ISOPEN     THEN CLOSE domain_objid_cur; END IF;
      IF mod_level_null_objid_cur%ISOPEN  THEN CLOSE mod_level_null_objid_cur; END IF;
      IF mod_level_exists_cur%ISOPEN     THEN CLOSE mod_level_exists_cur; END IF;
      IF part_exists_cur%ISOPEN          THEN CLOSE part_exists_cur; END IF;
      IF mod_level_objid_cur%ISOPEN THEN CLOSE mod_level_objid_cur; END IF;
      IF user_objid_cur%ISOPEN      THEN CLOSE user_objid_cur; END IF;
      IF inv_bin_objid_cur%ISOPEN   THEN CLOSE inv_bin_objid_cur; END IF;
      IF status_code_objid_cur%ISOPEN      THEN CLOSE status_code_objid_cur; END IF;
    IF check_part_inst_cur%ISOPEN              THEN CLOSE check_part_inst_cur; END IF;
    IF  check_posa_card_cur%ISOPEN              THEN CLOSE  check_posa_card_cur; END IF;
    IF  check_red_card_cur%ISOPEN              THEN CLOSE  check_red_card_cur; END IF;
END CLEAN_UP_PRC;
BEGIN /*OF MAIN  */
  l_previous_part_number := 'DUMMY_PART';
  l_current_part_number := 'DUMMY_PART';
  l_current_retailer := 'DUMMY_RET';
  l_previuos_retailer := 'DUMMY_RET';
  l_current_ff_center := 'DUMMY_FF';
  l_previuos_ff_center := 'DUMMY_FF';
--
  l_current_manf  := 'DUMMY_MANF';
  l_previuos_manf := 'DUMMY_MANF';
/*** GET USER ONLY ONCE ***/
  OPEN user_objid_cur;
    FETCH user_objid_cur INTO user_objid_rec;
  CLOSE user_objid_cur;
  FOR inv_rec IN inv_cur LOOP
    l_restricted_use := 0; --CR3190
    l_recs_processed := l_recs_processed + 1;
    l_commit_counter := l_commit_counter + 1;
    --CR5461 - TF PartNumber transpose
    OPEN item_cur (inv_rec.tf_part_num_transpose);
      FETCH item_cur INTO r_chkItemPromo;
    CLOSE item_cur;
    IF r_chkItemPromo.promo_code IS NULL OR r_chkItemPromo.promo_code = 'NONE' THEN
      NULL;
    ELSE /* Assumption: transpose partNo. has a valid promo_code attached
      replace parent value w/transpose value */
      inv_rec.tf_part_num_parent := inv_rec.tf_part_num_transpose;
    END IF;
    --End of CR5461 - TF PartNumber transpose
/**** set current ***********************************************/
    l_current_part_number :=  inv_rec.tf_part_num_parent;
    l_current_retailer := inv_rec.tf_ret_location_code;
    l_current_ff_center := inv_rec.tf_ff_location_code;
    l_current_manf := inv_rec.tf_manuf_location_code;
/***************************************************************/
    BEGIN /* MAIN INNER BLOCK */
      l_action := ' ';
      l_serial_num := inv_rec.tf_serial_num;
      IF inv_rec.tf_ret_location_code IS NOT NULL THEN
        IF  (l_current_retailer != l_previuos_retailer) THEN
          OPEN site_id_cur (inv_rec.tf_ret_location_code);
            FETCH site_id_cur INTO l_site_id;
            IF site_id_cur%FOUND THEN                                --CR 6451
              /** GET INV BIN OBJID ***/
              OPEN inv_bin_objid_cur (l_site_id);
                FETCH inv_bin_objid_cur INTO inv_bin_objid_rec;
              CLOSE inv_bin_objid_cur;
            ELSE
              RAISE no_site_id_exp;
            END IF;
          CLOSE site_id_cur;                                                --CR 6451
        END IF;
        l_creation_date := inv_rec.retailer_ship_date;
        /**  SET OTHERS TO DUMMY SINCE WE ARE NOT GOING TO USE IT */
        l_current_ff_center := 'USING RET';
        l_current_manf := 'USING RET';
      ELSIF inv_rec.tf_ff_location_code IS NOT NULL THEN
        IF  (l_current_ff_center != l_previuos_ff_center ) THEN
          OPEN site_id_cur (inv_rec.tf_ff_location_code);
            FETCH site_id_cur INTO l_site_id;
            IF site_id_cur%FOUND THEN                                  --CR 6451
              /** GET INV BIN OBJID ***/
              OPEN inv_bin_objid_cur (l_site_id);
                FETCH inv_bin_objid_cur INTO inv_bin_objid_rec;
              CLOSE inv_bin_objid_cur;
            ELSE RAISE no_site_id_exp;
            END IF;
          CLOSE site_id_cur;                                                   --CR 6451
        END IF;
        l_creation_date := inv_rec.ff_receive_date;
        /**  SET OTHERS TO DUMMY SINCE WE ARE NOT GOING TO USE IT */
        l_current_retailer := 'USING FF_CENTER';
        l_current_manf := 'USING FF_CENTER';
      ELSIF inv_rec.tf_manuf_location_code IS NOT NULL THEN
        IF  (l_current_manf  != l_previuos_manf) THEN
          OPEN site_id_cur (inv_rec.tf_manuf_location_code);
            FETCH site_id_cur INTO l_site_id;
            IF site_id_cur%FOUND THEN                                        --CR 6451
              /** GET INV BIN OBJID ***/
              OPEN inv_bin_objid_cur (l_site_id);
                FETCH inv_bin_objid_cur INTO inv_bin_objid_rec;
              CLOSE inv_bin_objid_cur;
            ELSE RAISE no_site_id_exp;
            END IF;
          CLOSE site_id_cur;                                                     --CR 6451
        END IF;
        l_creation_date := inv_rec.creation_date;
        /**  SET OTHERS TO DUMMY SINCE WE ARE NOT GOING TO USE IT */
        l_current_retailer := 'USING MANF';
        l_current_ff_center := 'USING MANF';
      END IF;
      dbms_output.put_line('inv_rec.tf_part_num_parent:'||inv_rec.tf_part_num_parent);
      l_action := 'Checking for existent of SITE in TOSS';
      dbms_output.put_line('l_site_id:'||l_site_id);
      IF l_site_id IS NOT NULL THEN
        /***** CHECK IF THE PART NUMBER IS EQUAL ********/
        IF l_previous_part_number != l_current_part_number THEN
      dbms_output.put_line('inv_rec.tf_part_num_parent:'||inv_rec.tf_part_num_parent);
          OPEN item_cur (inv_rec.tf_part_num_parent);
            FETCH item_cur INTO item_rec;
          CLOSE item_cur;
--cwl 8/14/2012
    if item_rec.clfy_domain = 'BUNDLE' then
    dbms_output.put_line('changing BUNDLE to REDEMPTION CARDS');
      item_rec.clfy_domain := 'REDEMPTION CARDS';
    end if;
--cwl 8/14/2012
          l_revision := item_rec.redemption_units;
          IF item_rec.posa_type = 'POSA' THEN
            l_inv_status := '45';
            OPEN status_code_objid_cur ('POSA CARDS');
              FETCH status_code_objid_cur INTO status_code_objid_rec;
            CLOSE status_code_objid_cur;
          ELSIF item_rec.posa_type = 'NPOSA' THEN
            l_inv_status := '42';
            OPEN status_code_objid_cur ('REDEMPTION CARDS');
              FETCH status_code_objid_cur INTO status_code_objid_rec;
            CLOSE status_code_objid_cur;
          END IF;
/********************************************************************************/
/*          Test to see if part number exists in the table_part_num table       */
/*  If the part number does not exist, insert into part num, table_script and   */
/*          mod_level tables,else update the part num and mod level tables      */
/********************************************************************************/
          /* Get the clfy_domain object id */
          OPEN domain_objid_cur (item_rec.clfy_domain);
            FETCH domain_objid_cur INTO domain_objid_rec;
          CLOSE domain_objid_cur;
          dbms_output.put_line('domain_objid_rec.objid:'||domain_objid_rec.objid);
-----Begin Remove the logic to check if part_num exists
          l_action := 'Checking for existent of PART_NUMBER in TOSS';
          OPEN part_exists_cur (domain_objid_rec.objid,
                                inv_rec.tf_part_num_parent);
            FETCH part_exists_cur INTO r_part_exists;
            IF part_exists_cur%NOTFOUND THEN
              dbms_output.put_line('part_exists_cur%NOTFOUND');
              RAISE no_part_num_exp; -- CR4659: Insert into error table
-------END Remove the logic to check if part_num exists
            ELSE
              dbms_output.put_line('part_exists_cur%FOUND');
              null;
            END IF;   /* end of part number check */---Not checking now
          CLOSE part_exists_cur;
          /* get mod level objid based on TABLE_PART_NUMBER **/
dbms_output.put_line('inv_rec.tf_part_num_parent:'||inv_rec.tf_part_num_parent);
dbms_output.put_line('l_revision:'||l_revision);
dbms_output.put_line(' item_rec.clfy_domain:'|| item_rec.clfy_domain);
          OPEN mod_level_objid_cur ( inv_rec.tf_part_num_parent,
                                          l_revision,
                                          item_rec.clfy_domain );
            FETCH mod_level_objid_cur INTO l_part_inst2part_mod;
              if mod_level_objid_cur%notfound then
                dbms_output.put_line('mod_level_objid_cur%notfound');
              end if;
          CLOSE mod_level_objid_cur;
        END IF; /*** of same part number check */
        /* Try part inst */
        OPEN check_part_inst_cur(inv_rec.tf_serial_num, item_rec.clfy_domain);
          FETCH check_part_inst_cur INTO check_part_inst_rec;
          IF check_part_inst_cur%FOUND THEN
            /* HANDLE UPDATE IN PART INST */
            l_action := 'insert part_inst and card_inv';
--cwl 7/30/12
            IF     l_inv_status ='45'
               and (   inv_rec.TF_MASTER_SERIAL_NUM is null
                    or (     inv_rec.TF_MASTER_SERIAL_NUM is not null
                         and inv_rec.TF_MASTER_SERIAL_NUM = inv_rec.tf_serial_num)) THEN  /* CONVERTING NON POSA TO POSA */
--cwl 7/30/12
              -- CR4659: Added to check PosaSwipe existence
              SELECT COUNT(1) INTO l_intPosaSwipe
                FROM X_POSA_CARD
               WHERE tf_serial_num = inv_rec.TF_SERIAL_NUM;
              IF l_intPosaSwipe = 0 THEN -- CR4659: No POSA swipe exists
                /*** INSERT INTO X_POSA_INV ***/
                l_posa_card_inv_seq := Seq('x_posa_card_inv');
                INSERT INTO TABLE_X_POSA_CARD_INV(OBJID                          ,
                                                       X_PART_SERIAL_NO               ,
                                                       X_DOMAIN                       ,
                                                       X_RED_CODE                     ,
                                                       X_POSA_INV_STATUS              ,
                                                       X_INV_INSERT_DATE              ,
                                                       X_LAST_SHIP_DATE               ,
                                                       X_TF_PO_NUMBER                 ,
                                                       X_TF_ORDER_NUMBER              ,
                                                       X_LAST_UPDATE_DATE             ,
                                                       X_CREATED_BY2USER              ,
                                                       X_LAST_UPDATE_BY2USER          ,
                                                       X_POSA_STATUS2X_CODE_TABLE,
                                                       X_POSA_INV2PART_MOD        ,
                                                       X_POSA_INV2INV_BIN             )
                                                VALUES(
                                                       l_posa_card_inv_seq,
                                                       inv_rec.TF_SERIAL_NUM,
                                                       item_rec.clfy_domain,
                                                       inv_rec.tf_card_pin_num,
                                                       l_inv_status,
                                                       inv_rec.creation_date,
                                                       NVL(inv_rec.retailer_ship_date,NVL(inv_rec.creation_date,inv_rec.FF_RECEIVE_DATE)),
                                                       inv_rec.TF_PO_NUM,
                                                       inv_rec.tf_order_num,
                                                       SYSDATE,
                                                       user_objid_rec.objid,
                                                       user_objid_rec.objid,
                                                       status_code_objid_rec.objid,
                                                       l_part_inst2part_mod,
                                                       inv_bin_objid_rec.objid);
                                    /*** INSERT CHANGE  in HIST  ***/
                l_pi_hist_seq := Seq('x_pi_hist');
                INSERT INTO TABLE_X_PI_HIST(objid,
                                               X_CHANGE_DATE            ,
                                               X_CHANGE_REASON           ,
                                               X_PI_HIST2PART_INST,
                                               X_PART_SERIAL_NO,
                                               X_DOMAIN         ,
                                               X_RED_CODE,
                                               X_PART_INST_STATUS,
                                               X_INSERT_DATE,
                                               X_CREATION_DATE,
                                               X_PO_NUM,
                                               X_ORDER_NUMBER,
                                               X_LAST_MOD_TIME,
                                               X_PI_HIST2USER,
                                               STATUS_HIST2X_CODE_TABLE,
                                               X_PI_HIST2PART_MOD,
                                               X_PI_HIST2INV_BIN
                                              )
                                        VALUES(
                                               l_pi_hist_seq,
                                               SYSDATE,
                                               'NPOSA TO POSA',
                                               l_pi_seq,
                                               check_part_inst_rec.PART_SERIAL_NO,
                                               check_part_inst_rec.X_DOMAIN,
                                               check_part_inst_rec.X_RED_CODE,
                                               check_part_inst_rec.x_part_inst_STATUS,
                                               check_part_inst_rec.X_INSERT_DATE,
                                               check_part_inst_rec.x_creation_date,
                                               check_part_inst_rec.X_PO_NUM,
                                               check_part_inst_rec.X_ORDER_NUMBER,
                                               check_part_inst_rec.LAST_MOD_TIME,
                                               check_part_inst_rec.CREATED_BY2USER,
                                               check_part_inst_rec.STATUS2X_CODE_TABLE,
                                               check_part_inst_rec.n_part_inst2part_mod,
                                               check_part_inst_rec.part_inst2inv_bin);
                                    /*** DELETE FROM TABLE_PART_INST ***/
                                    DELETE FROM TABLE_PART_INST
                                           WHERE part_serial_no = inv_rec.TF_SERIAL_NUM;
              END IF;
              l_action := 'Update tf_toss_interface_table';
              l_redemp_code := l_inv_status;
              l_action := 'Update tf_toss_interface_table 3';
              UPDATE TF_TOSS_INTERFACE_CARDS_D2
                 SET toss_extract_flag    = 'YES',
                     toss_extract_date    = SYSDATE,   --update with timestamp
                     toss_redemption_code = l_redemp_code,
                     last_update_date     = SYSDATE,
                     last_updated_by      = l_procedure_name
               WHERE ROWID = inv_rec.ROWID;
--cwl 7/30/12
            ELSIF    l_inv_status = '42'    /* UPDATING  NON POSA */
                  or (    l_inv_status ='45'
                      and inv_rec.TF_MASTER_SERIAL_NUM is not null
                      and inv_rec.TF_MASTER_SERIAL_NUM != inv_rec.tf_serial_num) THEN  /* CONVERTING NON POSA TO POSA */
--cwl 7/30/12
              /*** HANDLE 75 AND 44 **********/
              UPDATE TABLE_PART_INST
                 SET x_part_inst_status   = CASE WHEN x_part_inst_status IN ('263','400')
                                                            OR l_inv_status = '45' THEN
                                                            x_part_inst_status
                                                          ELSE
                                                            l_inv_status
                                                        END,
                     status2x_code_table  = CASE WHEN x_part_inst_status IN ('263','400')
                                                            OR l_inv_status = '45' THEN
                                                            status2x_code_table
                                                          ELSE
                                                            status_code_objid_rec.objid
                                                          END,
                     -- CR17825 End kacosta 09/26/2011
                     x_creation_date      = l_creation_date,
                     x_order_number       = inv_rec.tf_order_num,
                     created_by2user      = user_objid_rec.objid,
                     x_domain             = item_rec.clfy_domain,
                     last_pi_date         = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                     last_cycle_ct        = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                     next_cycle_ct        = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                     last_mod_time        = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                     last_trans_time      = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                     date_in_serv         = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                     repair_date          = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                     n_part_inst2part_mod = l_part_inst2part_mod,
                     part_inst2inv_bin    = inv_bin_objid_rec.objid,
--cwl 7/30/12
             x_parent_part_serial_no = inv_rec.TF_MASTER_SERIAL_NUM
--cwl 7/30/12
               WHERE part_serial_no       = inv_rec.tf_serial_num
                 AND x_domain             = item_rec.clfy_domain;
              IF SQL%ROWCOUNT != 0 THEN
                l_action := 'Update tf_toss_interface_table';
                l_redemp_code := l_inv_status;
                l_action := 'Update tf_toss_interface_table 3';
                UPDATE TF_TOSS_INTERFACE_CARDS_D2
                  SET toss_extract_flag    = 'YES',
                       toss_extract_date    = SYSDATE,   --update with timestamp
                       toss_redemption_code = l_redemp_code,
                       last_update_date     = SYSDATE,
                       last_updated_by      = l_procedure_name
                 WHERE ROWID = inv_rec.ROWID;
              END IF; /* of sqlrowcount */
            END IF;
          ELSE
            /* Try if posa inventory */
            OPEN check_posa_card_cur(inv_rec.tf_serial_num);
              FETCH check_posa_card_cur INTO check_posa_card_rec;
              IF check_posa_card_cur%FOUND THEN
                /* HANDLE UPDATE POSA CARD*/
                l_action := 'insert part_inst and card_inv';
--cwl 7/30/12
                IF   l_inv_status ='42'
                  or (    l_inv_status ='45'
                      and inv_rec.TF_MASTER_SERIAL_NUM is not null
                      and inv_rec.TF_MASTER_SERIAL_NUM != inv_rec.tf_serial_num) THEN  /* CONVERTING NON POSA TO POSA */
--cwl 7/30/12
                  l_pi_seq := Seq('part_inst');
                  INSERT INTO TABLE_PART_INST(objid,
                                               part_serial_no,
                                               x_part_inst_status,
                                               x_sequence,
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
                                               last_pi_date,
                                               last_cycle_ct,
                                               next_cycle_ct,
                                               last_mod_time,
                                               last_trans_time,
                                               date_in_serv,
                                               repair_date,
--cwl 7/30/12
                                       x_parent_part_serial_no )
--cwl 7/30/12
                  VALUES(
                               l_pi_seq,
                               inv_rec.tf_serial_num,
                               l_inv_status,
                               0,
                               inv_rec.tf_card_pin_num,
                               inv_rec.tf_order_num,
                               l_creation_date,   -- changed from sysdate G.P. 12-15-2000
                               user_objid_rec.objid,
                               item_rec.clfy_domain,
                               l_part_inst2part_mod,
                               inv_bin_objid_rec.objid,
                               'Active',
                               inv_rec.creation_date,   --SYSDATE,
                               status_code_objid_rec.objid,
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                               TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
--cwl 7/30/12
                       inv_rec.TF_MASTER_SERIAL_NUM );
--cwl 7/30/12
                  l_pi_hist_seq := Seq('x_pi_hist');
                  INSERT INTO TABLE_X_PI_HIST(objid,
                                               X_CHANGE_DATE,
                                               X_CHANGE_REASON,
                                               X_PI_HIST2PART_INST,
                                               X_PART_SERIAL_NO,
                                               X_DOMAIN,
                                               X_RED_CODE,
                                               X_PART_INST_STATUS,
                                               X_INSERT_DATE,
                                               X_CREATION_DATE,
                                               X_PO_NUM,
                                               X_ORDER_NUMBER,
                                               X_LAST_MOD_TIME,
                                               X_PI_HIST2USER,
                                               STATUS_HIST2X_CODE_TABLE,
                                               X_PI_HIST2PART_MOD,
                                               X_PI_HIST2INV_BIN
                                              )
                  VALUES(
                                               l_pi_hist_seq,
                                               SYSDATE,
                                               'POSA TO NPOSA',
                                               l_pi_seq,
                                               check_posa_card_rec.X_PART_SERIAL_NO,
                                               check_posa_card_rec.X_DOMAIN,
                                               check_posa_card_rec.X_RED_CODE,
                                               check_posa_card_rec.X_POSA_INV_STATUS,
                                               check_posa_card_rec.X_INV_INSERT_DATE,
                                               check_posa_card_rec.X_LAST_SHIP_DATE,
                                               check_posa_card_rec.X_TF_PO_NUMBER,
                                               check_posa_card_rec.X_TF_ORDER_NUMBER,
                                               check_posa_card_rec.X_LAST_UPDATE_DATE,
                                               check_posa_card_rec.X_CREATED_BY2USER,
                                               check_posa_card_rec.X_POSA_STATUS2X_CODE_TABLE,
                                               check_posa_card_rec.X_POSA_INV2PART_MOD,
                                               check_posa_card_rec.X_POSA_INV2INV_BIN);
                  DELETE FROM TABLE_X_POSA_CARD_INV
                   WHERE X_PART_SERIAL_NO = inv_rec.TF_SERIAL_NUM;
                  IF SQL%ROWCOUNT != 0 THEN
                    l_action := 'Update tf_toss_interface_table';
                    l_redemp_code := l_inv_status;
                    l_action := 'Update tf_toss_interface_table 3';
                    UPDATE TF_TOSS_INTERFACE_CARDS_D2
                       SET toss_extract_flag    = 'YES',
                           toss_extract_date    = SYSDATE,   --update with timestamp
                           toss_redemption_code = l_redemp_code,
                           last_update_date     = SYSDATE,
                           last_updated_by      = l_procedure_name
                     WHERE ROWID = inv_rec.ROWID;
                  END IF; /* of sqlrowcount */
--cwl 7/30/12
                ELSIF     l_inv_status = '45'
                      and (   inv_rec.TF_MASTER_SERIAL_NUM is null
                           or (    inv_rec.TF_MASTER_SERIAL_NUM is not null
                               and inv_rec.TF_MASTER_SERIAL_NUM = inv_rec.tf_serial_num)) THEN  /* CONVERTING NON POSA TO POSA */
--cwl 7/30/12
                  UPDATE TABLE_X_POSA_CARD_INV
                     SET X_PART_SERIAL_NO           = inv_rec.TF_SERIAL_NUM,
                         X_DOMAIN                   = item_rec.clfy_domain,
                         X_RED_CODE                 = inv_rec.tf_card_pin_num,
                         X_POSA_INV_STATUS          = l_inv_status,
                         X_INV_INSERT_DATE          = inv_rec.creation_date,
                         X_LAST_SHIP_DATE           = NVL(inv_rec.retailer_ship_date,NVL(inv_rec.creation_date,inv_rec.FF_RECEIVE_DATE)),
                         X_TF_PO_NUMBER             = inv_rec.TF_PO_NUM,
                         X_TF_ORDER_NUMBER          = inv_rec.tf_order_num,
                         X_LAST_UPDATE_DATE         = SYSDATE,
                         X_CREATED_BY2USER          = X_CREATED_BY2USER,
                         X_LAST_UPDATE_BY2USER      = user_objid_rec.objid,
                         X_POSA_STATUS2X_CODE_TABLE = status_code_objid_rec.objid,
                         X_POSA_INV2PART_MOD        = l_part_inst2part_mod,
                         X_POSA_INV2INV_BIN         = inv_bin_objid_rec.objid
                   WHERE X_PART_SERIAL_NO           = inv_rec.TF_SERIAL_NUM;
                  l_action := 'Update tf_toss_interface_table 5';
                  IF SQL%ROWCOUNT != 0 THEN
                    l_action := 'Update tf_toss_interface_table';
                    l_redemp_code := l_inv_status;
                    UPDATE TF_TOSS_INTERFACE_CARDS_D2
                       SET toss_extract_flag    = 'YES',
                           toss_extract_date    = SYSDATE,   --update with timestamp
                           toss_redemption_code = l_redemp_code,
                           last_update_date     = SYSDATE,
                           last_updated_by = l_procedure_name
                     WHERE ROWID = inv_rec.ROWID;
                  END IF; /* sql rowcount check */
                END IF; /* of check 42 45 inside posa card */
              ELSE
                OPEN check_red_card_cur(inv_rec.tf_serial_num);
                  FETCH check_red_card_cur INTO check_red_card_rec ;
                  IF check_red_card_cur%FOUND THEN
                    /* HANDLE UPDATE RED CARD*/
                    l_action := 'Update  table_x_red_card';
                    UPDATE TABLE_X_RED_CARD
                       SET x_inv_insert_date = inv_rec.creation_date,
                           x_last_ship_date =  NVL(inv_rec.retailer_ship_date,NVL(inv_rec.creation_date,inv_rec.FF_RECEIVE_DATE)),
                           x_order_number = inv_rec.tf_order_num,
                           x_po_num       = inv_rec.TF_PO_NUM,
                           x_created_by2user = x_created_by2user,
                           x_red_card2part_mod = l_part_inst2part_mod,
                           x_red_card2inv_bin = inv_bin_objid_rec.objid
                     WHERE X_SMP = inv_rec.TF_SERIAL_NUM;
                    l_action := 'Update tf_toss_interface_table 5';
                    IF SQL%ROWCOUNT != 0 THEN
                      l_action := 'Update tf_toss_interface_table';
                      l_redemp_code := l_inv_status;
                      UPDATE TF_TOSS_INTERFACE_CARDS_D2
                         SET toss_extract_flag    = 'YES',
                             toss_extract_date    = SYSDATE,   --update with timestamp
                            toss_redemption_code = l_redemp_code,
                             last_update_date     = SYSDATE,
                             last_updated_by = l_procedure_name
                       WHERE ROWID = inv_rec.ROWID;
                    END IF; /* sql rowcount check */
                  ELSE
                    /* NOT FOUND ANYWHERE */
                    /* UPDATE OFS side with NEWC */
                    /* UPDATE FLAG TO D2 */
                    UPDATE TF_TOSS_INTERFACE_CARDS_D2
                       SET toss_extract_flag = 'NEWC',
                           last_update_date = SYSDATE,
                           last_updated_by = l_procedure_name
                     WHERE ROWID = inv_rec.ROWID;
                    COMMIT;
                  END IF;
                CLOSE check_red_card_cur;
              END IF;
            CLOSE check_posa_card_cur;
          END IF;
        CLOSE  check_part_inst_cur;
      ELSE   /* new skip status on tf_toss_interface */
        RAISE no_site_id_exp;
      END IF;   /* end of site_id existence check */
      EXCEPTION
         WHEN no_site_id_exp THEN
            Toss_Util_Pkg.Insert_Error_Tab_Proc (
               'Inner Block : ' || l_action,
               l_serial_num,
               l_procedure_name,
               'NO SITE ID'
            );
            CLEAN_UP_PRC;
         WHEN distributed_trans_time_out THEN
            Toss_Util_Pkg.Insert_Error_Tab_Proc (
               'Inner Block : ' ||
               l_action ||
               ' Caught distributed_trans_time_out',
               l_serial_num,
               l_procedure_name
            );
            CLEAN_UP_PRC;
         WHEN record_locked THEN
            Toss_Util_Pkg.Insert_Error_Tab_Proc (
               'Inner Block : ' || l_action || ' Caught record_locked ',
               l_serial_num,
               l_procedure_name
            );
            CLEAN_UP_PRC;
         WHEN DUP_VAL_ON_INDEX THEN
            Toss_Util_Pkg.Insert_Error_Tab_Proc (
               l_action,
               l_serial_num,
               l_procedure_name,
               'Inner Block Error : Duplicate Value on index: Updating extract flag to D2'
            );
            /* UPDATE FLAG TO D2 */
              UPDATE TF_TOSS_INTERFACE_CARDS_D2
                  SET toss_extract_flag = 'D2',
                      last_update_date = SYSDATE,
                      last_updated_by = l_procedure_name
                WHERE ROWID = inv_rec.ROWID;
                CLEAN_UP_PRC;
         WHEN OTHERS THEN
            Toss_Util_Pkg.Insert_Error_Tab_Proc (
               'Inner Block : ' || l_action,
               l_serial_num,
               l_procedure_name
            );
            CLEAN_UP_PRC;
      END;
            CLEAN_UP_PRC;
     /** commit every 1000 */
      --  IF MOD(l_commit_counter,1000) = 0 THEN
          COMMIT;
      --  END IF;
    /***************** Set current to previous  *******************/
    l_previous_part_number := l_current_part_number ;
    l_previuos_retailer := l_current_retailer  ;
    l_previuos_ff_center := l_current_ff_center  ;
    --
    l_previuos_manf := l_current_manf;
    /***************************************************/
   END LOOP;   /* end of inv_rec loop */
   COMMIT;
--Change the call to interface_jobs_fun from "update" to "insert" into x_toss_interface_jobs
   IF Toss_Util_Pkg.insert_interface_jobs_fun (l_procedure_name,
                                               l_start_date,
                                               SYSDATE,
                                               l_recs_processed,
                                               'SUCCESS',
                                               l_procedure_name) THEN
      COMMIT;
      NULL;
   END IF;
   /** procedure executed sucessfully (graceous exiting--not hiting outer exception handler */
   ip_completion_status := TRUE;
EXCEPTION
   WHEN distributed_trans_time_out THEN
      Toss_Util_Pkg.Insert_Error_Tab_Proc (l_action || ' Caught distributed_trans_time_out',
                                           l_serial_num,
                                           l_procedure_name);
--Change the call to interface_jobs_fun from "update" to "insert" into x_toss_interface_jobs
      IF Toss_Util_Pkg.insert_interface_jobs_fun (l_procedure_name,
                                                  l_start_date,
                                                  SYSDATE,
                                                  l_recs_processed,
                                                  'FAILED',
                                                  l_procedure_name) THEN
         COMMIT;
         NULL;
      END IF;
      /** procedure exited hiting the outer exception handler (major application failure) */
      ip_completion_status := FALSE;
   WHEN record_locked THEN
      Toss_Util_Pkg.Insert_Error_Tab_Proc (l_action || ' Caught record_locked ',
                                           l_serial_num,
                                           l_procedure_name);
--Change the call to interface_jobs_fun from "update" to "insert" into x_toss_interface_jobs
      IF Toss_Util_Pkg.insert_interface_jobs_fun ( l_procedure_name,
                                                   l_start_date,
                                                   SYSDATE,
                                                   l_recs_processed,
                                                   'FAILED',
                                                   l_procedure_name) THEN
         COMMIT;
         NULL;
      END IF;
      /** procedure exited hiting the outer exception handler (major application failure) */
      ip_completion_status := FALSE;
   WHEN OTHERS THEN
      Toss_Util_Pkg.Insert_Error_Tab_Proc (l_action,
                                           l_serial_num,
                                           l_procedure_name);
--Change the call to interface_jobs_fun from "update" to "insert" into x_toss_interface_jobs
      IF Toss_Util_Pkg.insert_interface_jobs_fun (l_procedure_name,
                                                  l_start_date,
                                                  SYSDATE,
                                                  l_recs_processed,
                                                  'FAILED',
                                                  l_procedure_name) THEN
         --COMMIT;
         NULL;
      END IF;
      /** procedure exited hiting the outer exception handler (major application failure) */
      ip_completion_status := FALSE;
END Inbound_Cards_Inv_D2_Prc;
/