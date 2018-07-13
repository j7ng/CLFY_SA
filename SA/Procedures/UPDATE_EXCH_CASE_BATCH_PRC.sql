CREATE OR REPLACE PROCEDURE sa."UPDATE_EXCH_CASE_BATCH_PRC" (
   strcaseobjid      IN       VARCHAR2,
   strnewesn         IN       VARCHAR2,
   strtracking       IN       VARCHAR2,
   struserobjid      IN       VARCHAR2,
   strgbstobjid      IN       VARCHAR2,
   p_error_message   OUT      VARCHAR2
)
AS
/********************************************************************************************/
   /*    Copyright   2004 Tracfone  Wireless Inc. All rights reserved
   /*
   /* NAME     :       UPDATE_EXCH_CASE_BATCH_PRC
   /* PURPOSE  :       This procedure is called from the Clarify form 1008
   /*                  when an Exchange case is processed. Existing CB code was
   /*                  commented out since it was crashing. Running code in a separate
   /*                  memory area fixed that problem
   /* FREQUENCY:
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.
   /*
   /* REVISIONS:
   /* VERSION  DATE        WHO                 PURPOSE
   /* -------  ---------- -----                ---------------------------------------------
   /*  1.0     03/09/04   Ritu Gandhi          Initial  Revision
   /*  1.1     03/23/04   Ritu Gandhi          CR 2543 - Changes for Sim Exchange cases.
   /*  1.2     07/14/04   Gerald Pintado       CR2834 Added Service_Deactivation.deactService
   /*  1.3     09/01/04   Ritu Gandhi          CR3200 Added new parameter for deactService call
   /*  1.4     09/07/04   Muralidhar Chinta    Case Modifications - Phase II
   /*  1.5-1.8                                 Check fraud Units while giving replacement Units
   /*  1.9     01/28/05   Ritu Gandhi          CR3373 Case Mod on Web
   /*                                          Assign a resolution to the case when it is closed
   /*  1.10-1.11  04/04/05                     Changed the revision to match PVCS
   /*  1.12     05/04/05   Muralidhar Chinta   CR3825
   /*         save tracking no to the case
   /*  1.13     05/05/05   Muralidhar Chinta   CR3590
   /*         To close case even if there are exceptions in SP
   /*  1.14     09/02/05   Gerald Pintado      CR4478 Passing In 2 in DeactService to byPass creating action item
   /*  1.15     09/05/05   Fernando Lasa       CR4187 To fix close issues of CR3590
   /*  1.16 and 1.18                             CR4384 Correct Version Label
   /*  1.19     09/30/05   Fernando Lasa       CR4513 To include transfer promotions
   /*  1.22     10/10/05   Natalio Guada       CR4541 Remove Close Case, It will be close upon received of old phone
   /*  1.23     10/12/05   Vani Adapa          Fix for CR4541
   /*  1.24     10/13/05   Vani Adapa          Fix for CR4541 - Added ACCESSORY NOT RECEIVED exception
   /*  1.26     05/01/06   Natalio Guada       CR5174 Esn with Accessory Case changed to status 57
   /*  1.27     05/19/06   Natalio Guada       CR4960 Increase Comp Units when Lesser phone exchanges (Data Services)
   /* 1.28     06/08/06   Curt Lindner       CR5349 - Fix for OPEN_CURSORS
   /* 1.29      06/23/06   Vani Adapa        CR5384-Eliminate the usage of status "Exchange" 57
   /* 1.30  08/31/06   Ingrid Canavan   CR5354 - Log and process ESN's where zipcode technology is not available
   /* 1.31  09/11/06   Natalio Guada      CR5541 - Number Portability Cases Missing Information
   /* 1.32  09/11/06   Natalio Guada      Fixed for CR5541
   /* 1.33/1.34/1.35  09/13/06   Vani Adapa        CR5581_5582
   /* 1.36          09/18/06   Vani Adapa       Removed CR5541
   /* 1.37 /1.38         08/21/06   Vani Adapa       Added CR5541 changes
   /* 1.39           08/29/06   Natalio Guada       Date added to case notes CR5541
   /* 1.40/1.43    06/01/07   Ingrid Canavan    CR5728 Remove Net10 + 300 on exchange

   /********************************************************************************************/

   --CR4960 START
   CURSOR exch_units_c (new_part IN VARCHAR2, old_part IN VARCHAR2)
   IS
      SELECT x_bonus_units, x_bonus_days
        FROM TABLE_X_CLASS_EXCH_OPTIONS
       WHERE (x_new_part_num = new_part OR x_used_part_num = new_part)
         AND source2part_class IN (SELECT part_num2part_class
                                     FROM TABLE_PART_NUM
                                    WHERE part_number = old_part)
         AND ROWNUM < 2;

   rec_exch_units        exch_units_c%ROWTYPE;

   --CR4960 END
   CURSOR flag57_c (esn IN VARCHAR2, TIME IN DATE)
   IS
      SELECT *
        FROM TABLE_X_PI_HIST
       WHERE x_part_serial_no = esn
         AND x_change_date >= TIME
         AND x_part_inst_status = '57';

   rec_flag57            flag57_c%ROWTYPE;

   --Get case details
   CURSOR shipped_c
   IS
      SELECT objid
        FROM TABLE_GBST_ELM e
       WHERE title = 'Shipped'
             AND e.gbst_elm2gbst_lst = (SELECT objid
                                          FROM TABLE_GBST_LST
                                         WHERE title = 'Open');

   rec_shipped_c         shipped_c%ROWTYPE;

   CURSOR esn_received_c
   IS
      SELECT *
        FROM TABLE_ACT_ENTRY
       WHERE act_entry2case = strcaseobjid AND act_code = 2000; --ESN Received

   rec_esn_received      esn_received_c%ROWTYPE;
   bool_esn_received     NUMBER;

   CURSOR case_c
   IS
      SELECT *
        FROM TABLE_CASE
       WHERE objid = strcaseobjid;

   rec_case_c            case_c%ROWTYPE;

   --Get the old esn
   CURSOR old_part_inst_c (p_esn VARCHAR2)
   IS
      SELECT *
        FROM TABLE_PART_INST
       WHERE part_serial_no = p_esn;

   rec_old_part_inst_c   old_part_inst_c%ROWTYPE;

   --Get dealer for old esn
   CURSOR old_dealer_c (p_esn VARCHAR2)
   IS
      SELECT i.*
        FROM TABLE_INV_BIN i, TABLE_PART_INST pi
       WHERE pi.part_serial_no = p_esn AND pi.part_inst2inv_bin = i.objid;

   rec_old_dealer        old_dealer_c%ROWTYPE;

   --Get old esn part_num record
   CURSOR old_part_num_c (mod_level_objid VARCHAR2)
   IS
      SELECT pn.*
        FROM TABLE_MOD_LEVEL m, TABLE_PART_NUM pn
       WHERE m.objid = mod_level_objid AND m.part_info2part_num = pn.objid;

   rec_old_part_num_c    old_part_num_c%ROWTYPE;

   --Get the new esn
   CURSOR new_part_inst_c (p_esn VARCHAR2)
   IS
      SELECT *
        FROM TABLE_PART_INST
       WHERE part_serial_no = p_esn;

   rec_new_part_inst_c   new_part_inst_c%ROWTYPE;

   --Get new esn part_num record
   CURSOR new_part_num_c (mod_level_objid VARCHAR2)
   IS
      SELECT pn.*
        FROM TABLE_MOD_LEVEL m, TABLE_PART_NUM pn
       WHERE m.objid = mod_level_objid AND m.part_info2part_num = pn.objid;

   rec_new_part_num_c    new_part_num_c%ROWTYPE;

   --Get dealer for new esn
   CURSOR new_dealer_c (p_esn VARCHAR2)
   IS
      SELECT i.*
        FROM TABLE_INV_BIN i, TABLE_PART_INST pi
       WHERE pi.part_serial_no = p_esn AND pi.part_inst2inv_bin = i.objid;

   rec_new_dealer        new_dealer_c%ROWTYPE;

   --Get default dealer
   CURSOR default_dealer_c
   IS
      SELECT i.*
        FROM TABLE_INV_BIN i, TABLE_X_CODE_TABLE c
       WHERE c.x_code_name = 'EXCHANGE_PARTNER' AND c.x_value = i.bin_name;

   rec_default_dealer    default_dealer_c%ROWTYPE;

   --Get the alt_esn record
   CURSOR alt_esn_c
   IS
      SELECT *
        FROM TABLE_X_ALT_ESN
       WHERE x_alt_esn2case = strcaseobjid;

   rec_alt_esn_c         alt_esn_c%ROWTYPE;

   --Get the case Extra Info record
   CURSOR ext_case_c
   IS
      SELECT *
        FROM TABLE_X_CASE_EXTRA_INFO ex
       WHERE ex.x_extra_info2x_case = strcaseobjid;

   rec_ext_case_c        ext_case_c%ROWTYPE;

   --Get Promotion linked to Old ESN
   CURSOR old_promo_c (mod_level_objid VARCHAR2)
   IS
      SELECT p.*
        FROM TABLE_X_PROMOTION p, TABLE_MOD_LEVEL m, TABLE_PART_NUM pn
       WHERE p.objid = pn.part_num2x_promotion
         AND pn.objid = m.part_info2part_num
         AND m.objid = mod_level_objid;

   rec_old_promo_c       old_promo_c%ROWTYPE;

   --Get Promotion linked to New ESN
   CURSOR new_promo_c (mod_level_objid VARCHAR2)
   IS
      SELECT p.*
        FROM TABLE_X_PROMOTION p, TABLE_MOD_LEVEL m, TABLE_PART_NUM pn
       WHERE p.objid = pn.part_num2x_promotion
         AND pn.objid = m.part_info2part_num
         AND m.objid = mod_level_objid;

   rec_new_promo_c       new_promo_c%ROWTYPE;

   --Get all alternative parts for New ESN
   CURSOR alt_part_c (mod_level_objid VARCHAR2)
   IS
      SELECT newpart.*
        FROM TABLE_MOD_LEVEL m,
             TABLE_PART_NUM oldpart,
             TABLE_PART_CLASS pc,
             TABLE_PART_NUM newpart
       WHERE m.objid = mod_level_objid
         AND m.part_info2part_num = oldpart.objid
         AND oldpart.part_num2part_class = pc.objid
         AND pc.objid = newpart.part_num2part_class;

   rec_alt_part_c        alt_part_c%ROWTYPE;

   --Get Promotion code
   CURSOR get_promotion_c (part_objid VARCHAR2)
   IS
      SELECT p.*
        FROM TABLE_X_PROMOTION p, TABLE_PART_NUM pn
       WHERE p.objid = pn.part_num2x_promotion AND pn.objid = part_objid;

   rec_get_promotion_c   get_promotion_c%ROWTYPE;

   --Get Mod level
   CURSOR get_mod_level_c (part_objid VARCHAR2)
   IS
      SELECT *
        FROM TABLE_MOD_LEVEL
       WHERE part_info2part_num = part_objid;

   rec_mod_level_c       get_mod_level_c%ROWTYPE;
   strzip                TABLE_CASE.x_activation_zip%TYPE;

   --Validate that the new ESN matches the technology available in the zip code
   CURSOR part_num_c
   IS
      SELECT pn.part_number
        FROM MTM_PART_NUM14_X_FREQUENCY0 mtm,
             TABLE_X_FREQUENCY fr,
             TABLE_PART_NUM pn
       WHERE pn.objid = mtm.part_num2x_frequency
         AND fr.objid = x_frequency2part_num
         AND (pn.x_technology, fr.x_frequency) IN (
                SELECT DISTINCT DECODE
                                   (tab2.cdma_tech,
                                    NULL, DECODE (tab2.tdma_tech,
                                                  NULL, DECODE (tab2.gsm_tech,
                                                                NULL, 'na',
                                                                tab2.gsm_tech
                                                               ),
                                                  tdma_tech
                                                 ),
                                    tab2.cdma_tech
                                   ) technology,
                                DECODE (tab2.frequency1,
                                        0, DECODE (tab2.frequency2,
                                                   0, 'na',
                                                   tab2.frequency2
                                                  ),
                                        tab2.frequency1
                                       ) frequency
                           FROM CARRIERPREF cp,
                                (SELECT DISTINCT b.state, b.county,
                                                 b.carrier_id, b.SID,
                                                 b.cdma_tech, b.tdma_tech,
                                                 b.gsm_tech, b.frequency1,
                                                 b.frequency2
                                            FROM NPANXX2CARRIERZONES b,
                                                 (SELECT DISTINCT A.ZONE,
                                                                  A.st
                                                             FROM CARRIERZONES A
                                                            WHERE A.zip =
                                                                        strzip) tab1
                                           WHERE b.ZONE = tab1.ZONE
                                             AND b.state = tab1.st) tab2
                          WHERE cp.county = tab2.county
                            AND cp.st = tab2.state
                            AND cp.carrier_id = tab2.carrier_id);

   rec_part_num_c        part_num_c%ROWTYPE;

   --Check if ESN was previously activated
   CURSOR get_site_part_count_c (p_esn VARCHAR2)
   IS
      SELECT COUNT (*) cnt
        FROM TABLE_SITE_PART
       WHERE x_service_id = p_esn AND LOWER (part_status) <> 'obsolete';

   intcount              INTEGER;

   --Get record from table_x_code_table for code type
   CURSOR get_code_table_c (p_code_no VARCHAR2)
   IS
      SELECT *
        FROM TABLE_X_CODE_TABLE
       WHERE x_code_number = p_code_no;

   rec_code_table_c      get_code_table_c%ROWTYPE;

   /*       --Get SID for the zipcode
       CURSOR get_sid IS
       SELECT DISTINCT  b.sid sid
       FROM carrierzones a, npanxx2carrierzones b
       WHERE a.sim_profile is not null
       AND b.GSM_TECH = 'GSM'
         AND a.bta_mkt_number = b.bta_mkt_number
       AND a.st = b.state
       AND a.zone = b.zone
       AND a.zip = strZip;

       rec_sid get_sid%ROWTYPE;

       --Get SIM record
       CURSOR get_sim_inv IS
       SELECT *
       FROM table_x_sim_inv
       WHERE x_sim_serial_no = strNewESN;

       rec_sim_inv get_sim_inv%ROWTYPE;*/
   -- CR2834  Check if old ESN is active
   CURSOR getactivesite (p_esn IN VARCHAR2)
   IS
      SELECT objid, x_min
        FROM TABLE_SITE_PART
       WHERE part_status = 'Active' AND x_service_id = p_esn;

   CURSOR checkmin
   IS
      SELECT COUNT (*)
        FROM NPANXX2CARRIERZONES nc,
             (SELECT x_carrier_id
                FROM TABLE_X_CARRIER carr,
                     TABLE_PART_INST line,
                     (SELECT x_min
                        FROM TABLE_SITE_PART
                       WHERE x_service_id = rec_case_c.x_esn
                         AND part_status = 'Active') tab5
               WHERE line.part_inst2carrier_mkt = carr.objid
                 AND line.part_serial_no = tab5.x_min) tab1,
             (SELECT   prt_num.x_technology,
                       MAX (DECODE (f.x_frequency, 800, 800, NULL)
                           ) x_frequency1,
                       MAX (DECODE (f.x_frequency, 1900, 1900, NULL)
                           ) x_frequency2
                  FROM TABLE_X_FREQUENCY f,
                       MTM_PART_NUM14_X_FREQUENCY0 pf,
                       TABLE_PART_NUM prt_num,
                       TABLE_MOD_LEVEL ml,
                       TABLE_PART_INST pi
                 WHERE pf.x_frequency2part_num = f.objid
                   AND prt_num.objid = pf.part_num2x_frequency
                   AND prt_num.objid = ml.part_info2part_num
                   AND pi.n_part_inst2part_mod = ml.objid
                   AND pi.part_serial_no = strnewesn
              GROUP BY prt_num.x_technology) tab4
       WHERE tab1.x_carrier_id = nc.carrier_id
         AND tab4.x_technology IN (nc.tdma_tech, nc.cdma_tech, nc.gsm_tech)
         AND (   nc.frequency1 IN (tab4.x_frequency1, tab4.x_frequency2)
              OR nc.frequency2 IN (tab4.x_frequency1, tab4.x_frequency2)
             );

   --CR3373 - Starts
   CURSOR csrclosecase (c_objid NUMBER)
   IS
      SELECT   *
          FROM TABLE_CLOSE_CASE
         WHERE last_close2case = c_objid
      ORDER BY close_date DESC;

   recclosecase          csrclosecase%ROWTYPE;

   CURSOR csrwebresol (
      c_case_type    VARCHAR2,
      c_case_title   VARCHAR2,
      c_resolution   VARCHAR2
   )
   IS
      SELECT *
        FROM TABLE_X_WEB_CASE_RESOLUTION
       WHERE x_case_type = c_case_type
         AND x_case_title = c_case_title
         AND x_case_status = 'Closed'
         AND x_resolution = c_resolution;

   recwebresol           csrwebresol%ROWTYPE;

   --CR3373 - Ends

   -- CR5728 - Begin
   CURSOR act_default_promo_c ( p_esn IN VARCHAR2 )
   IS
      SELECT TABLE_X_PROMO_HIST.objid
         FROM TABLE_X_PROMO_HIST, TABLE_X_PROMOTION, TABLE_X_CALL_TRANS
     WHERE promo_hist2x_promotion = TABLE_X_PROMOTION.objid
             AND upper(table_x_promotion.x_promo_type)='ACTIVATION'        --     AND x_promo_code = 'DEFNET10_2'
             AND TABLE_X_CALL_TRANS.objid  =
                  TABLE_X_PROMO_HIST.promo_hist2x_call_trans
             AND x_service_id = p_esn;

   rec_act_default_promo_c act_default_promo_c%ROWTYPE;

   -- CR5728 - Ends
   --CR5581_5582
   CURSOR get_esn_site_cur (p_ib_objid IN NUMBER)
   IS
      SELECT ts.objid
        FROM TABLE_SITE ts, TABLE_INV_BIN ib
       WHERE ib.bin_name = ts.site_id AND ib.objid = p_ib_objid;

   get_esn_site_rec      get_esn_site_cur%ROWTYPE;
   str_repl_units        NUMBER                             := 0;
   v_ret_repl_units      NUMBER                             := 0;
   str_old_site_id       NUMBER                             := 0;
   v_upd_repl_units      NUMBER                             := 0;
   --CR5581_5582
   icheckmin             INT;
   bvalue                VARCHAR2 (10);
   bvalid                BOOLEAN;
   bchangemodlevel       BOOLEAN;
   boldpromofound        BOOLEAN;
   bnewpromofound        BOOLEAN;
   bdefaultdealerfound   BOOLEAN;
   strhistory            TABLE_CASE.case_history%TYPE;
   v_status              VARCHAR2 (1);
   v_message             VARCHAR2 (250);
   strstatus             VARCHAR2 (5);
   binserted             BOOLEAN;
   strusername           TABLE_USER.login_name%TYPE;
   v_return              VARCHAR2 (20);
   v_returnmsg           VARCHAR2 (300);
   actualunits           NUMBER;
   temptitle             VARCHAR2 (20);
   tempesn               VARCHAR2 (20);
   tempobjid             VARCHAR2 (20);
   cnt                   NUMBER;
   intbypass             NUMBER                             := 0;
   err_num               NUMBER;
   err_desc              VARCHAR2 (1000);
   v_status_objid        NUMBER;
   v_act_default_promo VARCHAR2 ( 20 );                              -- CR5728
--CR4541
BEGIN
--CR4541
   SELECT login_name
     INTO strusername
     FROM TABLE_USER
    WHERE objid = struserobjid;

   SELECT objid
     INTO v_status_objid
     FROM TABLE_X_CODE_TABLE
    WHERE x_code_number = '57';

   OPEN shipped_c;

   FETCH shipped_c
    INTO rec_shipped_c;

   IF shipped_c%NOTFOUND
   THEN
      p_error_message := 'Status Shipped not found';

      CLOSE shipped_c;

      RETURN;
   END IF;

   CLOSE shipped_c;                                --fix 06/08/06 OPEN_CURSORS

   OPEN esn_received_c;

   FETCH esn_received_c
    INTO rec_esn_received;

   IF esn_received_c%NOTFOUND
   THEN
      bool_esn_received := 0;
   ELSE
      bool_esn_received := 1;
   END IF;

   CLOSE esn_received_c;

   --Get the case details
   OPEN case_c;

   FETCH case_c
    INTO rec_case_c;

   IF case_c%NOTFOUND
   THEN
      p_error_message := 'Case not found';

      CLOSE case_c;

      RETURN;
   END IF;

   CLOSE case_c;

   --Get the old ESN record
   OPEN old_part_inst_c (rec_case_c.x_esn);

   FETCH old_part_inst_c
    INTO rec_old_part_inst_c;

   IF old_part_inst_c%NOTFOUND
   THEN
      p_error_message := 'Old ESN record not found in inventory';
--      CLOSE old_part_inst_c;  --CR4187
   --RETURN;  CR3590
   END IF;

   CLOSE old_part_inst_c;

   OPEN old_part_num_c (rec_old_part_inst_c.n_part_inst2part_mod);

   FETCH old_part_num_c
    INTO rec_old_part_num_c;

   IF old_part_num_c%NOTFOUND
   THEN
      IF p_error_message IS NULL OR LENGTH (p_error_message) < 5
      THEN
         p_error_message := 'Old ESN Part Number not found';
      END IF;
   ELSE
      -- CR5728 Begin fix 6/1/07
      OPEN act_default_promo_c ( rec_old_part_inst_c.part_serial_no );

      FETCH act_default_promo_c
       INTO rec_act_default_promo_c;

      v_act_default_promo := rec_act_default_promo_c.objid;
        IF v_act_default_promo IS NOT NULL
        THEN
             v_act_default_promo :='1' ;
        END IF ;
      CLOSE act_default_promo_c;
   -- CR5728 End
   END IF;

   CLOSE old_part_num_c;

   --Check if this is a SIM exchange case. Length of SIM is between 18 to 20 digits. This
   --will be used to differentiate the 2 cases.
   --CR5541
   IF rec_case_c.s_title IN
         ('DEFECTIVE PHONE',
          'DIGITAL EXCHANGE',
          'ANALOG EXCHANGE',
          'EXTERNAL TECH EXCH',
          'INT.CROSS/SIM EXCH',
    'INT.CROSS/TECH EXCH'
         )
--CR5541
--   IF rec_case_c.s_title IN
--                   ('DEFECTIVE PHONE', 'DIGITAL EXCHANGE', 'ANALOG EXCHANGE')
   THEN
      --Get New ESN record
      OPEN new_part_inst_c (strnewesn);

      FETCH new_part_inst_c
       INTO rec_new_part_inst_c;

      IF new_part_inst_c%NOTFOUND
      THEN
         IF p_error_message IS NULL OR LENGTH (p_error_message) < 5
         THEN
            p_error_message := 'New ESN record not found in inventory';
         END IF;
      END IF;

      CLOSE new_part_inst_c;

      OPEN new_part_num_c (rec_new_part_inst_c.n_part_inst2part_mod);

      FETCH new_part_num_c
       INTO rec_new_part_num_c;

      IF new_part_num_c%NOTFOUND
      THEN
         IF p_error_message IS NULL OR LENGTH (p_error_message) < 5
         THEN
            p_error_message := 'New ESN Part Number not found';
         END IF;
      END IF;

      CLOSE new_part_num_c;                                           --CR4187

      IF (   rec_case_c.x_activation_zip IS NULL
          OR (LENGTH (rec_case_c.x_activation_zip) = 0)
         )
      THEN
         strzip := rec_case_c.alt_zipcode;
      ELSE
         strzip := rec_case_c.x_activation_zip;
      END IF;

      bvalid := FALSE;

      FOR rec_part_num_c IN part_num_c
      LOOP
         IF rec_new_part_num_c.part_number = rec_part_num_c.part_number
         THEN
            bvalid := TRUE;
            EXIT;
         END IF;
      END LOOP;

      IF NOT bvalid
      THEN
         IF p_error_message IS NULL OR LENGTH (p_error_message) < 5
         THEN
            p_error_message :=
                     'New ESN does not match Technology available at ZipCode';
--            RETURN;  -- CR5354
         END IF;
      END IF;

      bchangemodlevel := FALSE;
      boldpromofound := TRUE;
      bnewpromofound := TRUE;

      --Get the alternate part num record that has the same promotion as the original ESN
      OPEN old_promo_c (rec_old_part_inst_c.n_part_inst2part_mod);

      FETCH old_promo_c
       INTO rec_old_promo_c;

      IF old_promo_c%NOTFOUND
      THEN
         boldpromofound := FALSE;
      END IF;

      CLOSE old_promo_c;

      OPEN new_promo_c (rec_new_part_inst_c.n_part_inst2part_mod);

      FETCH new_promo_c
       INTO rec_new_promo_c;

      IF new_promo_c%NOTFOUND
      THEN
         bnewpromofound := FALSE;
      END IF;

      CLOSE new_promo_c;

      IF boldpromofound AND NOT bnewpromofound
      THEN
         FOR rec_alt_part_c IN
            alt_part_c (rec_new_part_inst_c.n_part_inst2part_mod)
         LOOP
            FOR rec_get_promotion_c IN get_promotion_c (rec_alt_part_c.objid)
            LOOP
               IF rec_get_promotion_c.x_promo_code =
                                                 rec_old_promo_c.x_promo_code
               THEN
                  OPEN get_mod_level_c (rec_alt_part_c.objid);

                  FETCH get_mod_level_c
                   INTO rec_mod_level_c;

                  CLOSE get_mod_level_c;

                  bchangemodlevel := TRUE;
                  EXIT;
               END IF;
            END LOOP;
         END LOOP;
      END IF;

      --Get the old Dealer record
      OPEN old_dealer_c (rec_case_c.x_esn);

      FETCH old_dealer_c
       INTO rec_old_dealer;

      IF old_dealer_c%NOTFOUND
      THEN
         IF p_error_message IS NULL OR LENGTH (p_error_message) < 5
         THEN
--CR3590
            p_error_message :=
               'Old dealer record not found. Please contact a system administrator';
         END IF;
--CR3590
      --          CLOSE old_dealer_c;  --CR4187
      -- return;    CR3590
     --CR5581_5582
      ELSE
         OPEN get_esn_site_cur (rec_old_dealer.objid);

         FETCH get_esn_site_cur
          INTO get_esn_site_rec;

         IF get_esn_site_cur%NOTFOUND
         THEN
            str_old_site_id := 0;

            IF p_error_message IS NULL OR LENGTH (p_error_message) < 5
            THEN
--CR3590
               p_error_message :=
                  'Old dealer record not found. Please contact a system administrator';
            END IF;
         ELSE
            str_old_site_id := get_esn_site_rec.objid;
         END IF;

         CLOSE get_esn_site_cur;
      --Cr5581_5582
      END IF;

      CLOSE old_dealer_c;

      --Check if the new ESN is valid for Exchange
      IF rec_case_c.x_require_return <> 2
      THEN
         IF     rec_new_part_inst_c.x_part_inst_status <> '50'
            AND rec_new_part_inst_c.x_part_inst_status <> '51'
            AND rec_new_part_inst_c.x_part_inst_status <> '150'
         THEN
            IF p_error_message IS NULL OR LENGTH (p_error_message) < 5
            THEN
--CR3590
               p_error_message := 'This ESN is not valid for exchange';
            END IF;
--CR3590
         -- return;    CR3590
         END IF;
      END IF;

      --Get dealer for new ESN
      OPEN new_dealer_c (strnewesn);

      FETCH new_dealer_c
       INTO rec_new_dealer;

      IF new_dealer_c%NOTFOUND
      THEN
         IF p_error_message IS NULL OR LENGTH (p_error_message) < 5
         THEN
--CR3590
            p_error_message :=
               'New dealer record not found. Please contact a system administrator';
         END IF;
--CR3590
      --          CLOSE new_dealer_c;  --CR4187
      -- return;    CR3590
      END IF;

      CLOSE new_dealer_c;

      --Get default dealer
      bdefaultdealerfound := TRUE;

      OPEN default_dealer_c;

      FETCH default_dealer_c
       INTO rec_default_dealer;

      IF default_dealer_c%NOTFOUND
      THEN
         bdefaultdealerfound := FALSE;
      END IF;

      CLOSE default_dealer_c;

      IF rec_case_c.x_require_return <> 2
      THEN
         UPDATE TABLE_PART_INST
            SET part_inst2inv_bin = rec_old_dealer.objid
          WHERE objid = rec_new_part_inst_c.objid;

         IF bdefaultdealerfound
         THEN
            UPDATE TABLE_PART_INST
               SET part_inst2inv_bin = rec_default_dealer.objid
             WHERE objid = rec_old_part_inst_c.objid;
         ELSE
            UPDATE TABLE_PART_INST
               SET part_inst2inv_bin = rec_new_dealer.objid
             WHERE objid = rec_old_part_inst_c.objid;
         END IF;
      END IF;

      --Get alt_esn record
      OPEN alt_esn_c;

      FETCH alt_esn_c
       INTO rec_alt_esn_c;

      CLOSE alt_esn_c;

      --Get Extra_case record
      OPEN ext_case_c;

      FETCH ext_case_c
       INTO rec_ext_case_c;

      CLOSE ext_case_c;

      --Update the replacement ESN
      UPDATE TABLE_X_ALT_ESN
         SET x_replacement_esn = rec_new_part_inst_c.part_serial_no,
             x_replacement_esn2part_inst = rec_new_part_inst_c.objid,
             x_status = 'CLOSED'
       WHERE objid = rec_alt_esn_c.objid;

      --Update case table
      strhistory :=
            rec_case_c.case_history
         || CHR (10)
         || CHR (13)
         ||'*** WAREHOUSE LOG '||TO_CHAR(SYSDATE,'mm/dd/yyy HH:MI AM')||' '||strusername
         || CHR (10)
         || CHR (13)
         || 'Exchange ESN Shipped : ';

      strhistory := strhistory || strnewesn;
      strhistory :=
            strhistory
         || CHR (10)
         || CHR (13)
         || ' Tracking Number : '
         || strtracking;


      DBMS_OUTPUT.put_line (   'new esn status '
                            || rec_new_part_inst_c.part_serial_no
                           );

--CR5581/CR5582
      IF rec_case_c.s_title IN ('DEFECTIVE PHONE')
      THEN
         IF (    rec_new_part_inst_c.x_part_inst_status = '50'
             AND rec_new_part_num_c.x_restricted_use <> 3
            )
         THEN
            Convert_Bo_To_Sql_Pkg.enroll_for_tech_exch
                                         (rec_new_part_inst_c.part_serial_no,
                                          v_ret_repl_units,
                                          1
                                         );
         END IF;

         DBMS_OUTPUT.put_line (' v_ret_repl_units ' || v_ret_repl_units);

         IF v_ret_repl_units = 0.5
         THEN
            str_repl_units := NVL (rec_case_c.x_replacement_units, 0);
         END IF;

         IF NVL (v_ret_repl_units, 0) = 0
         THEN
            IF (    rec_old_part_inst_c.x_part_inst_status = '50'
                AND rec_old_part_num_c.x_restricted_use <> 3
               )
            THEN
               Convert_Bo_To_Sql_Pkg.enroll_for_tech_exch
                                         (rec_old_part_inst_c.part_serial_no,
                                          v_ret_repl_units,
                                          str_old_site_id
                                         );
            END IF;
         END IF;

         DBMS_OUTPUT.put_line (' v_ret_repl_units ' || v_ret_repl_units);

         IF v_ret_repl_units > 1
         THEN
            str_repl_units :=
                    NVL (rec_case_c.x_replacement_units, 0)
                    + v_ret_repl_units;
            strhistory :=
                  strhistory
               || CHR (10)
               || 'BUNDLE Minutes (60) added as the original phone was qualified';
         ELSE
            str_repl_units := NVL (rec_case_c.x_replacement_units, 0);
         END IF;
      ELSE
         str_repl_units := NVL (rec_case_c.x_replacement_units, 0);
      END IF;
--CR5728 05/03/07 BEGIN
-- CR5728 6/1/07 fixed restricted use
      IF rec_case_c.s_title IN ('DEFECTIVE PHONE')
            AND rec_new_part_num_c.x_restricted_use = 3
                AND v_act_default_promo='1'
       THEN
                str_repl_units := str_repl_units-300 ;
       END IF ;
 --CR5728 05/03/07 END
      DBMS_OUTPUT.put_line (' str_repl_units ' || str_repl_units);

--CR5581_5582
-- CR5728
      UPDATE TABLE_CASE
         SET site_time = SYSDATE,
             x_require_return = 2,
             case_history = strhistory,
             casests2gbst_elm = rec_shipped_c.objid,
             x_po_number = strtracking,                               --CR3825
             x_replacement_units = str_repl_units,               --CR5581_5582 --CR5728
             support_type = v_act_default_promo                      -- CR5728
       WHERE objid = strcaseobjid;

      COMMIT;

      SELECT NVL (x_replacement_units, 0)
        INTO v_upd_repl_units
        FROM TABLE_CASE
       WHERE objid = strcaseobjid;                               --CR5581_5582

      --CR4541 END
      /*CR3373 - starts - Case mod on the Web - Assign resolution 'Shipped' to the closed case*/
      OPEN csrclosecase (rec_case_c.objid);

      FETCH csrclosecase
       INTO recclosecase;

      CLOSE csrclosecase;

      OPEN csrwebresol (rec_case_c.x_case_type, rec_case_c.title, 'Shipped');

      FETCH csrwebresol
       INTO recwebresol;

      CLOSE csrwebresol;

      UPDATE TABLE_CLOSE_CASE
         SET close_case2case_resol = recwebresol.objid
       WHERE objid = recclosecase.objid;

      COMMIT;
      /*CR3373 - End - Case mod on the Web*/
      binserted :=
         Toss_Util_Pkg.insert_pi_hist_fun (rec_new_part_inst_c.part_serial_no,
                                           rec_new_part_inst_c.x_domain,
                                           strstatus,
                                           'UPDATE_EXCH_CASE_BATCH_PRC'
                                          );

      INSERT INTO TABLE_ACT_ENTRY
                  (objid, act_code, entry_time,
                   addnl_info,
                   act_entry2case, act_entry2user, entry_name2gbst_elm
                  )
           VALUES (Seq ('act_entry'), '1500', SYSDATE,
                   'ESN Exchange Batch process - New ESN Linked and Shipped',
                   strcaseobjid, struserobjid, strgbstobjid
                  );

      IF bchangemodlevel
      THEN
         UPDATE TABLE_PART_INST
            SET n_part_inst2part_mod = rec_mod_level_c.objid
          WHERE objid = rec_new_part_inst_c.objid;
      END IF;

      /***** CR2834 New Code to DEACTIVATE Old ESN and associate MIN with New ESN  ****/
      IF (   rec_new_part_inst_c.warr_end_date IS NULL
          OR (rec_new_part_inst_c.warr_end_date <
                                             rec_old_part_inst_c.warr_end_date
             )
         )
      THEN
         UPDATE TABLE_PART_INST
            SET warr_end_date = rec_old_part_inst_c.warr_end_date
          WHERE objid = rec_new_part_inst_c.objid;
      END IF;

      FOR rec_activesite IN getactivesite (rec_old_part_inst_c.part_serial_no)
      LOOP
         OPEN checkmin;

         FETCH checkmin
          INTO icheckmin;

         CLOSE checkmin;

         IF icheckmin > 0
         THEN
            bvalue := 'true';
            intbypass := 2;
         ELSE
            bvalue := 'false';
            intbypass := 0;
         END IF;

         -- Call Deactivate package
         --CR4478 - ByPass Creating action item
         sa.Service_Deactivation.deactservice
                                          ('Clarify',
                                           struserobjid,
                                           rec_old_part_inst_c.part_serial_no,
                                           rec_activesite.x_min,
                                           'WAREHOUSE PHONE',
                                           intbypass,
                                           rec_new_part_inst_c.part_serial_no,
                                           bvalue,
                                           v_return,
                                           v_returnmsg
                                          );
         DBMS_OUTPUT.put_line (   'ServiceDeactivation:'
                               || v_return
                               || ': '
                               || v_returnmsg
                              );
--CR5384 Start
--          --CR5174 Start
--    --
--          OPEN flag57_c (rec_old_part_inst_c.part_serial_no,rec_case_c.creation_time);
--          FETCH flag57_c INTO rec_flag57;
--
--          IF flag57_c%NOTFOUND THEN
--
--             UPDATE table_part_inst SET x_parT_inst_status = '57',
--             status2x_code_table = v_Status_objid
--             WHERE part_serial_no = rec_old_part_inst_c.part_serial_no;
--             COMMIT;
--          bInserted := toss_util_pkg.insert_pi_hist_fun(rec_old_part_inst_c.part_serial_no,
--             rec_old_part_inst_c.x_domain, strStatus, 'UPDATE_EXCH_CASE_BATCH_PRC');
--
--          END IF;
--    CLOSE flag57_c;
--
--       --CR5174 End
--CR5384 End
      END LOOP;

      -- To move the promotions from the Old ESN to the new ESN
      Migra_Intellitrack.transferpromotions (rec_case_c.x_esn,
                                             strnewesn,
                                             err_num,
                                             err_desc
                                            );

      -- Issue Replacement Units on customer's new ESN
      -- CR3221  to add new ESN to fraud case and to append fraud units to replacement units if the warehouse case is still open
      --get the new ESN
      IF rec_case_c.s_title = 'DEFECTIVE PHONE'
      THEN
         tempesn := rec_case_c.x_stock_type;
      ELSE
         tempesn := rec_alt_esn_c.x_replacement_esn;
      END IF;

      -- Get Objid of Fraud case
      IF     rec_ext_case_c.x_fraud_id != ''
         AND rec_ext_case_c.x_fraud_id IS NOT NULL
         AND rec_ext_case_c.x_fraud_id != 0
      THEN
         SELECT objid
           INTO tempobjid
           FROM TABLE_CASE
          WHERE id_number = rec_ext_case_c.x_fraud_id;
      END IF;

      -- update the new esn to Fraud case
      SELECT COUNT (*)
        INTO cnt
        FROM TABLE_CASE, TABLE_X_ALT_ESN
       WHERE TABLE_X_ALT_ESN.x_alt_esn2case = TABLE_CASE.objid
         AND TABLE_X_ALT_ESN.x_alt_esn2case =
                                    (SELECT objid
                                       FROM TABLE_CASE
                                      WHERE objid = rec_ext_case_c.x_fraud_id);

      IF cnt = 0
      THEN
         INSERT INTO TABLE_X_ALT_ESN
                     (objid, x_replacement_esn, x_alt_esn2case
                     )
              VALUES (Seq ('x_alt_esn'), tempesn, tempobjid
                     );
      ELSE
         UPDATE TABLE_X_ALT_ESN
            SET x_replacement_esn = tempesn
          WHERE rec_case_c.objid = rec_alt_esn_c.x_alt_esn2case
            AND rec_alt_esn_c.x_alt_esn2case = tempobjid;
      END IF;

      --
--      IF (rec_case_c.x_replacement_units > 9)
      IF (v_upd_repl_units > 9)                                  --CR5581_5582
      THEN
         SELECT cond.s_title
           INTO temptitle
           FROM TABLE_CONDITION cond, TABLE_CASE ca
          WHERE cond.objid = ca.case_state2condition
            AND ca.objid = rec_case_c.objid;

         IF temptitle <> 'CLOSED'
         THEN
            actualunits :=
                           --rec_case_c.x_replacement_units
                           v_upd_repl_units + rec_ext_case_c.x_fraud_units;
         --CR5581_5582
         ELSE
            actualunits := v_upd_repl_units;                    ---R5581_5582
         -- rec_case_c.x_replacement_units;
         END IF;

         --CR4960 START
         OPEN exch_units_c (rec_new_part_num_c.part_number,
                            rec_case_c.x_model);

         FETCH exch_units_c
          INTO rec_exch_units;

         IF exch_units_c%FOUND
         THEN
            actualunits :=
                          actualunits + NVL (rec_exch_units.x_bonus_units, 0);
         END IF;

         CLOSE exch_units_c;

         --CR4960 END
         sa.Sp_Issue_Compunits (rec_new_part_inst_c.objid,
                                actualunits,
                                rec_case_c.id_number,
                                v_return,
                                v_returnmsg
                               );
         DBMS_OUTPUT.put_line (   'Compensation Units:'
                               || v_return
                               || ': '
                               || v_returnmsg
                              );
      END IF;
-- End CR3221
   /***** CR2834 Ends Here ***********************************************************/
   ELSE
      --Code for SIM Exchange
      IF rec_case_c.s_title LIKE '%SIM%'
      THEN
         --Get alt_esn record
         OPEN alt_esn_c;

         FETCH alt_esn_c
          INTO rec_alt_esn_c;

         CLOSE alt_esn_c;

         --Update the replacement ESN
         UPDATE TABLE_X_ALT_ESN
            SET x_new_sim = strnewesn
          WHERE objid = rec_alt_esn_c.objid;

         --Update the case table
         strhistory :=
               rec_case_c.case_history
         || CHR (10)
         || CHR (13)
         ||'*** WAREHOUSE LOG '||TO_CHAR(SYSDATE,'mm/dd/yyy HH:MI AM')||' '||strusername
            || CHR (10)
            || CHR (13)
            || ' Exchange SIM Shipped : ';
         strhistory := strhistory || strnewesn;
         strhistory :=
               strhistory
            || CHR (10)
            || CHR (13)
            || ' Tracking Number : '
            || strtracking;
      END IF;

      IF rec_case_c.s_title = 'ACCESSORY NOT RECEIVED'
      THEN
         strhistory :=
               rec_case_c.case_history
            || CHR (10)
            || CHR (13)
            || ' ACCESSORIES Shipped : ';
      END IF;

      UPDATE TABLE_CASE
         SET site_time = SYSDATE,
             x_require_return = 2,
             case_history = strhistory,
             casests2gbst_elm = rec_shipped_c.objid,
             x_po_number = strtracking
       WHERE objid = strcaseobjid;

      IF    bool_esn_received = 1
         OR rec_case_c.s_title LIKE '%SIM%'
         OR rec_case_c.s_title = 'ACCESSORY NOT RECEIVED'
      THEN
         Igate.sp_close_case (rec_case_c.id_number,
                              strusername,
                              'CLARIFY',
                              'Cust Exchanged Phone',
                              v_status,
                              v_message
                             );

         /*CR3373 - starts - Case mod on the Web - Assign resolution 'Shipped' to the closed case*/
         OPEN csrclosecase (rec_case_c.objid);

         FETCH csrclosecase
          INTO recclosecase;

         CLOSE csrclosecase;

         OPEN csrwebresol (rec_case_c.x_case_type, rec_case_c.title,
                           'Shipped');

         FETCH csrwebresol
          INTO recwebresol;

         CLOSE csrwebresol;

         UPDATE TABLE_CLOSE_CASE
            SET close_case2case_resol = recwebresol.objid
          WHERE objid = recclosecase.objid;
      END IF;

      COMMIT;
      /*CR3373 - End - Case mod on the Web*/
      binserted :=
         Toss_Util_Pkg.insert_pi_hist_fun (rec_new_part_inst_c.part_serial_no,
                                           rec_new_part_inst_c.x_domain,
                                           strstatus,
                                           'UPDATE_EXCH_CASE_BATCH_PRC'
                                          );

      INSERT INTO TABLE_ACT_ENTRY
                  (objid, act_code, entry_time,
                   addnl_info,
                   act_entry2case, act_entry2user, entry_name2gbst_elm
                  )
           VALUES (Seq ('act_entry'), '1500', SYSDATE,
                   'ESN Exchange Batch process - New SIM or ACC Linked and Shipped',
                   strcaseobjid, struserobjid, strgbstobjid
                  );
   END IF;

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      p_error_message :=
                       'Exception occured while running procedure' || SQLERRM;
      RETURN;
END Update_Exch_Case_Batch_Prc;
/