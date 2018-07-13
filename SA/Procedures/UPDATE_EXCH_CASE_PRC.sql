CREATE OR REPLACE PROCEDURE sa."UPDATE_EXCH_CASE_PRC" (
   strCaseObjid IN VARCHAR2,
   strNewESN IN VARCHAR2,
   strTracking IN VARCHAR2,
   strUserObjid IN VARCHAR2,
   strGbstObjid IN VARCHAR2,
   p_error_message OUT VARCHAR2
)
AS
/********************************************************************************************/
   /*    Copyright   2004 Tracfone  Wireless Inc. All rights reserved                          */
   /*                                                                                          */
   /* NAME     :       UPDATE_EXCH_CASE_PRC                                                    */
   /* PURPOSE  :       This procedure is called from the Clarify form 776                      */
   /*                  when an Exchange case is processed. Existing CB code was                */
   /*                  commented out since it was crashing. Running code in a separate         */
   /*                  memory area fixed that problem                                          */
   /* FREQUENCY:                                                                               */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                           */
   /*                                                                                          */
   /* REVISIONS:                                                                               */
   /* VERSION  DATE        WHO                 PURPOSE                                         */
   /* -------  ---------- -----                ---------------------------------------------   */
   /*  1.0     03/09/04   Ritu Gandhi          Initial  Revision                               */
   /*  1.1     07/14/04   Gerald Pintado       CR2834 Added Service_Deactivation.deactService  */
   /*  1.2     09/01/04   Ritu Gandhi          CR3200 Added new parameter for deactService call*/
   /*  1.4     09/07/04   Muralidhar Chinta    CR3221 Case Modifications - Phase II         */
   /*                        Check fraud Units while giving replacement Units*/
   /*  1.5....
   /*  1.6     05/04/05   Muralidhar Chinta    CR3825                         */
   /*                        save tracking no to the case            */
   /********************************************************************************************/
   --Get case details
   CURSOR case_c
   IS
   SELECT *
   FROM table_case
   WHERE objid = strCaseObjid;
   rec_case_c case_c%ROWTYPE;
   --Get the old esn
   CURSOR old_part_inst_c(
      p_esn VARCHAR2
   )
   IS
   SELECT *
   FROM table_part_inst
   WHERE part_serial_no = p_esn;
   rec_old_part_inst_c old_part_inst_c%ROWTYPE;
   --Get old esn part_num record
   CURSOR old_part_num_c(
      mod_level_objid VARCHAR2
   )
   IS
   SELECT PN.*
   FROM table_mod_level M, table_part_num PN
   WHERE M.Objid = mod_level_objid
   AND M.Part_Info2part_Num = PN.Objid;
   rec_old_part_num_c old_part_num_c%ROWTYPE;
   --Get dealer for old esn
   CURSOR old_dealer_c(
      p_esn VARCHAR2
   )
   IS
   SELECT I.*
   FROM table_inv_bin I, table_part_inst PI
   WHERE PI.Part_Serial_No = p_esn
   AND PI.PART_INST2INV_BIN = I.Objid;
   rec_old_dealer old_dealer_c%ROWTYPE;
   --Get the new esn
   CURSOR new_part_inst_c(
      p_esn VARCHAR2
   )
   IS
   SELECT *
   FROM table_part_inst
   WHERE part_serial_no = p_esn;
   rec_new_part_inst_c new_part_inst_c%ROWTYPE;
   --Get new esn part_num record
   CURSOR new_part_num_c(
      mod_level_objid VARCHAR2
   )
   IS
   SELECT PN.*
   FROM table_mod_level M, table_part_num PN
   WHERE M.Objid = mod_level_objid
   AND M.Part_Info2part_Num = PN.Objid;
   rec_new_part_num_c new_part_num_c%ROWTYPE;
   --Get dealer for new esn
   CURSOR new_dealer_c(
      p_esn VARCHAR2
   )
   IS
   SELECT I.*
   FROM table_inv_bin I, table_part_inst PI
   WHERE PI.Part_Serial_No = p_esn
   AND PI.PART_INST2INV_BIN = I.Objid;
   rec_new_dealer new_dealer_c%ROWTYPE;
   --Get default dealer
   CURSOR default_dealer_c
   IS
   SELECT I.*
   FROM table_inv_bin I, table_x_code_table C
   WHERE C.x_Code_Name = 'EXCHANGE_PARTNER'
   AND C.x_Value = I.BIN_NAME;
   rec_default_dealer default_dealer_c%ROWTYPE;
   --Get the alt_esn record
   CURSOR alt_esn_c
   IS
   SELECT *
   FROM table_x_alt_esn
   WHERE x_alt_esn2case = strCaseObjid;
   rec_alt_esn_c alt_esn_c%ROWTYPE;
   --CR3221 Start
   --Get the case Extra Info record
   CURSOR ext_case_c
   IS
   SELECT *
   FROM table_x_case_extra_info ex
   WHERE ex.x_extra_info2x_case = strCaseObjid;
   rec_ext_case_c ext_case_c%ROWTYPE;
   --CR3221 End
   --Get Promotion linked to Old ESN
   CURSOR old_promo_c(
      mod_level_objid VARCHAR2
   )
   IS
   SELECT P.*
   FROM table_x_promotion P, table_mod_level M, table_part_num PN
   WHERE p.objid = pn.part_num2x_promotion
   AND pn.objid = m.part_info2part_num
   AND m.objid = mod_level_objid;
   rec_old_promo_c old_promo_c%ROWTYPE;
   --Get Promotion linked to New ESN
   CURSOR new_promo_c(
      mod_level_objid VARCHAR2
   )
   IS
   SELECT P.*
   FROM table_x_promotion P, table_mod_level M, table_part_num PN
   WHERE p.objid = pn.part_num2x_promotion
   AND pn.objid = m.part_info2part_num
   AND m.objid = mod_level_objid;
   rec_new_promo_c new_promo_c%ROWTYPE;
   --Get all alternative parts for New ESN
   CURSOR alt_part_c(
      mod_level_objid VARCHAR2
   )
   IS
   SELECT NewPart.*
   FROM table_mod_level M, table_part_num OldPart, table_part_class PC,
   table_part_num NewPart
   WHERE m.Objid = mod_level_objid
   AND M.PART_INFO2PART_NUM = OldPart.Objid
   AND OldPart.Part_Num2part_Class = PC.Objid
   AND PC.Objid = NewPart.Part_Num2part_Class;
   rec_alt_part_c alt_part_c%ROWTYPE;
   --Get Promotion code
   CURSOR get_promotion_c(
      part_objid VARCHAR2
   )
   IS
   SELECT P.*
   FROM table_x_promotion P, table_part_num PN
   WHERE P.Objid = PN.PART_NUM2X_PROMOTION
   AND Pn.Objid = part_objid;
   rec_get_promotion_c get_promotion_c%ROWTYPE;
   --Get Mod level
   CURSOR get_mod_level_c(
      part_objid VARCHAR2
   )
   IS
   SELECT *
   FROM table_mod_level
   WHERE part_info2part_num = part_objid;
   rec_mod_level_c get_mod_level_c%ROWTYPE;
   strZip table_case.x_activation_zip%TYPE;
   --Validate that the new ESN matches the technology available in the zip code
   CURSOR part_num_c
   IS
   SELECT pn.part_number
   FROM mtm_part_num14_x_frequency0 mtm, table_x_frequency fr, table_part_num
   pn
   WHERE pn.objid = mtm.part_num2x_frequency
   AND fr.objid = x_frequency2part_num
   AND (pn.x_technology, fr.x_frequency) IN (
   SELECT DISTINCT DECODE (tab2.cdma_tech, NULL, DECODE (tab2.tdma_tech, NULL,
   DECODE (tab2.gsm_tech, NULL, 'na', tab2.gsm_tech ), tdma_tech), tab2.cdma_tech
   ) technology,
      DECODE (tab2.frequency1, 0, DECODE (tab2.frequency2, 0, 'na', tab2.frequency2
      ), tab2.frequency1 ) frequency
   FROM carrierpref cp, (
      SELECT DISTINCT b.state,
         b.county,
         b.carrier_id,
         b.sid,
         b.cdma_tech,
         b.tdma_tech,
         b.gsm_tech,
         b.frequency1,
         b.frequency2
      FROM npanxx2carrierzones b, (
         SELECT DISTINCT a.zone,
            a.st
         FROM carrierzones a
         WHERE a.zip = strZip)tab1
      WHERE b.zone = tab1.zone
      AND b.state = tab1.st)tab2
   WHERE cp.county = tab2.county
   AND cp.st = tab2.state
   AND cp.carrier_id = tab2.carrier_id);
   rec_part_num_c part_num_c%ROWTYPE;
   --Check if ESN was previously activated
   CURSOR get_site_part_count_c(
      p_esn VARCHAR2
   )
   IS
   SELECT COUNT(*) cnt
   FROM table_site_part
   WHERE x_service_id = p_esn
   AND LOWER(part_status) <> 'obsolete';
   intCount INTEGER;
   --Get record from table_x_code_table for code type
   CURSOR get_code_table_c(
      p_code_no VARCHAR2
   )
   IS
   SELECT *
   FROM table_x_code_table
   WHERE x_code_number = p_code_no;
   rec_code_table_c get_code_table_c%ROWTYPE;
   -- CR2834  Check if old ESN is active
   CURSOR getActiveSite(
      p_esn IN VARCHAR2
   )
   IS
   SELECT objid,
      x_min
   FROM table_site_part
   WHERE part_status = 'Active'
   AND x_service_id = p_esn;
   CURSOR checkMin
   IS
   SELECT COUNT(*)
   FROM npanxx2carrierzones nc, (
      SELECT x_carrier_id
      FROM table_x_carrier carr, table_part_inst line, (
         SELECT x_min
         FROM table_site_part
         WHERE x_service_id = rec_case_c.x_esn
         AND part_status = 'Active' )tab5
      WHERE line.part_inst2carrier_mkt = carr.objid
      AND line.part_serial_no = tab5.x_min )tab1, (
      SELECT prt_num.x_technology,
         MAX(DECODE(f.x_frequency, 800, 800, NULL)) x_frequency1,
         MAX(DECODE(f.x_frequency, 1900, 1900, NULL)) x_frequency2
      FROM table_x_frequency f, mtm_part_num14_x_frequency0 pf, table_part_num
      prt_Num, table_mod_level ml, table_part_inst pi
      WHERE pf.x_frequency2part_num = f.objid
      AND prt_num.objid = pf.part_num2x_frequency
      AND prt_Num.objid = ml.part_info2part_num
      AND pi.n_part_inst2part_mod = ml.objid
      AND pi.part_serial_no = strNewESN
      GROUP BY prt_num.x_technology )tab4
   WHERE tab1.x_carrier_id = nc.carrier_id
   AND tab4.x_technology IN (nc.tdma_tech, nc.cdma_tech, nc.gsm_tech)
   AND ( nc.frequency1 IN (tab4.x_frequency1, tab4.x_frequency2)
   OR nc.frequency2 IN (tab4.x_frequency1, tab4.x_frequency2));
   iCheckMin int;
   bValue VARCHAR2(10);
   bValid BOOLEAN;
   bChangeModLevel BOOLEAN;
   bOldPromoFound BOOLEAN;
   bNewPromoFound BOOLEAN;
   bDefaultDealerFound BOOLEAN;
   strHistory table_case.case_history%TYPE;
   v_status VARCHAR2(1);
   v_message VARCHAR2(250);
   strStatus VARCHAR2(5);
   bInserted BOOLEAN;
   v_return VARCHAR2(20);
   v_returnMsg VARCHAR2(300);
   ActualUnits NUMBER;
   temptitle VARCHAR2(20);
   tempEsn VARCHAR2(20);
   tempobjid VARCHAR2(20);
   cnt NUMBER;
BEGIN
   p_error_message := '';
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
   OPEN old_part_inst_c(rec_case_c.x_esn);
   FETCH old_part_inst_c
   INTO rec_old_part_inst_c;
   IF old_part_inst_c%NOTFOUND
   THEN
      p_error_message := 'Old ESN record not found in inventory';
      CLOSE old_part_inst_c;
      RETURN;
   END IF;
   CLOSE old_part_inst_c;
   --Get New ESN record
   OPEN new_part_inst_c(strNewESN);
   FETCH new_part_inst_c
   INTO rec_new_part_inst_c;
   IF new_part_inst_c%NOTFOUND
   THEN
      p_error_message := 'New ESN record not found in inventory';
      CLOSE new_part_inst_c;
      RETURN;
   END IF;
   CLOSE new_part_inst_c;
   --Inventory Validation
   IF rec_new_part_inst_c.x_part_inst_status <> '50'
   AND rec_new_part_inst_c.x_part_inst_status <> '51'
   AND rec_new_part_inst_c.x_part_inst_status <> '150'
   THEN
      p_error_message := 'This ESN is not valid for exchange';
      RETURN;
   END IF;
   IF (rec_case_c.x_activation_zip
   IS
   NULL
   OR (LENGTH(rec_case_c.x_activation_zip) = 0))
   THEN
      strZip := rec_case_c.alt_zipcode;
   ELSE
      strZip := rec_case_c.x_activation_zip;
   END IF;
   --Get the part_num for the new ESN
   OPEN new_part_num_c(rec_new_part_inst_c.n_part_inst2part_mod);
   FETCH new_part_num_c
   INTO rec_new_part_num_c;
   IF new_part_num_c%NOTFOUND
   THEN
      p_error_message := 'New ESN Part Number not found';
      CLOSE new_part_num_c;
      RETURN;
   END IF;
   --Get the part_num for the old ESN
   OPEN old_part_num_c(rec_old_part_inst_c.n_part_inst2part_mod);
   FETCH old_part_num_c
   INTO rec_old_part_num_c;
   IF old_part_num_c%NOTFOUND
   THEN
      p_error_message := 'Old ESN Part Number not found';
      CLOSE old_part_num_c;
      RETURN;
   END IF;
   --Check if the new ESN is valid for the zip code
   bValid := FALSE;
   FOR rec_part_num_c IN part_num_c
   LOOP
      IF rec_new_part_num_c.part_number = rec_part_num_c.part_number
      THEN
         bValid := TRUE;
         EXIT;
      END IF;
   END LOOP;
   IF NOT bValid
   THEN
      p_error_message :=
      'New ESN does not match Technology available at ZipCode';
      RETURN;
   END IF;
   --Get the old Dealer record
   OPEN old_dealer_c(rec_case_c.x_esn);
   FETCH old_dealer_c
   INTO rec_old_dealer;
   IF old_dealer_c%NOTFOUND
   THEN
      p_error_message :=
      'Old dealer record not found. Please contact a system administrator';
      CLOSE old_dealer_c;
      RETURN;
   END IF;
   CLOSE old_dealer_c;
   --Get dealer for new ESN
   OPEN new_dealer_c(strNewESN);
   FETCH new_dealer_c
   INTO rec_new_dealer;
   IF new_dealer_c%NOTFOUND
   THEN
      p_error_message :=
      'New dealer record not found. Please contact a system administrator';
      CLOSE new_dealer_c;
      RETURN;
   END IF;
   CLOSE new_dealer_c;
   bChangeModLevel := FALSE;
   bOldPromoFound := TRUE;
   bNewPromoFound := TRUE;
   --Get the alternate part num record that has the same promotion as the original ESN
   OPEN old_promo_c(rec_old_part_inst_c.n_part_inst2part_mod);
   FETCH old_promo_c
   INTO rec_old_promo_c;
   IF old_promo_c%NOTFOUND
   THEN
      bOldPromoFound := FALSE;
   END IF;
   CLOSE old_promo_c;
   OPEN new_promo_c(rec_new_part_inst_c.n_part_inst2part_mod);
   FETCH new_promo_c
   INTO rec_new_promo_c;
   IF new_promo_c%NOTFOUND
   THEN
      bNewPromoFound := FALSE;
   END IF;
   CLOSE new_promo_c;
   IF bOldPromoFound
   AND NOT bNewPromoFound
   THEN
      FOR rec_alt_part_c IN alt_part_c(rec_new_part_inst_c.n_part_inst2part_mod
      )
      LOOP
         FOR rec_get_promotion_c IN get_promotion_c(rec_alt_part_c.objid)
         LOOP
            IF rec_get_promotion_c.x_promo_code = rec_old_promo_c.x_promo_code
            THEN
               OPEN get_mod_level_c(rec_alt_part_c.objid);
               FETCH get_mod_level_c
               INTO rec_mod_level_c;
               CLOSE get_mod_level_c;
               bChangeModLevel := TRUE;
               EXIT;
            END IF;
         END LOOP;
      END LOOP;
   END IF;
   --Get default dealer
   bDefaultDealerFound := TRUE;
   OPEN default_dealer_c;
   FETCH default_dealer_c
   INTO rec_default_dealer;
   IF default_dealer_c%NOTFOUND
   THEN
      bDefaultDealerFound := FALSE;
   END IF;
   CLOSE default_dealer_c;
   IF rec_case_c.x_require_return <> 2
   THEN
      UPDATE table_part_inst SET part_inst2inv_bin = rec_old_dealer.objid
      WHERE objid = rec_new_part_inst_c.objid;
      IF bDefaultDealerFound
      THEN
         UPDATE table_part_inst SET part_inst2inv_bin = rec_default_dealer.objid
         WHERE objid = rec_old_part_inst_c.objid;
      ELSE
         UPDATE table_part_inst SET part_inst2inv_bin = rec_new_dealer.objid
         WHERE objid = rec_old_part_inst_c.objid;
      END IF;
   END IF;
   --Get alt_esn record
   OPEN alt_esn_c;
   FETCH alt_esn_c
   INTO rec_alt_esn_c;
   CLOSE alt_esn_c;
   --CR3221 Start
   --Get Extra_case record
   OPEN ext_case_c;
   FETCH ext_case_c
   INTO rec_ext_case_c;
   CLOSE ext_case_c;
   --CR3221 End
   --Update the replacement ESN
   UPDATE table_x_alt_esn SET x_replacement_esn = rec_new_part_inst_c.part_serial_no
   , x_replacement_esn2part_inst = rec_new_part_inst_c.objid
   WHERE objid = rec_alt_esn_c.objid;
   --Update case table
   strHistory := rec_case_c.case_history || CHR(10) || CHR(13) ||
   ' Exchange ESN Shipped : ';
   strHistory := strHistory || strNewESN;
   strHistory := strHistory || CHR(10) || CHR(13) || ' Tracking Number : ' ||
   strTracking;
   UPDATE table_case SET site_time = SYSDATE, x_require_return = 2,
   case_history = strHistory, casests2gbst_elm = rec_case_c.casests2gbst_elm,
   x_po_number = strTracking --CR3825
   WHERE objid = strCaseObjid;
   sp_chg_esn(rec_case_c.x_esn, v_status, v_message);
   IF v_status <> 'F'
   THEN
      UPDATE table_x_alt_esn SET x_status = 'CLOSED'
      WHERE objid = rec_alt_esn_c.objid;
      IF rec_new_part_inst_c.x_part_inst_status = '58'
      THEN
         OPEN get_site_part_count_c(rec_new_part_inst_c.part_serial_no);
         FETCH get_site_part_count_c
         INTO intCount;
         CLOSE get_site_part_count_c;
         IF intCount > 0
         THEN
            OPEN get_code_table_c('51');
            FETCH get_code_table_c
            INTO rec_code_table_c;
            CLOSE get_code_table_c;
            UPDATE table_part_inst SET x_part_inst_status = '51',
            status2x_code_table = rec_code_table_c.objid
            WHERE objid = rec_new_part_inst_c.objid;
            strStatus := 'USED';
         ELSE
            OPEN get_code_table_c('50');
            FETCH get_code_table_c
            INTO rec_code_table_c;
            CLOSE get_code_table_c;
            UPDATE table_part_inst SET x_part_inst_status = '50',
            status2x_code_table = rec_code_table_c.objid
            WHERE objid = rec_new_part_inst_c.objid;
            strStatus := 'NEW';
         END IF;
         bInserted := toss_util_pkg.insert_pi_hist_fun(rec_new_part_inst_c.part_serial_no
         , rec_new_part_inst_c.x_domain, strStatus, 'UPDATE_WAREHOUSE_CASE_PRC'
         );
      END IF;
   END IF;
   COMMIT;
   INSERT
   INTO table_act_entry(
      objid,
      act_code,
      entry_time,
      addnl_info,
      act_entry2case,
      act_entry2user,
      entry_name2gbst_elm
   ) VALUES(
      seq('act_entry'),
      '1500',
      SYSDATE,
      'New ESN Linked and Shipped',
      strCaseObjid,
      strUserObjid,
      strGbstObjid
   );
   IF bChangeModLevel
   THEN
      UPDATE table_part_inst SET n_part_inst2part_mod = rec_mod_level_c.objid
      WHERE objid = rec_new_part_inst_c.objid;
   END IF;
   /***** CR2834 New Code to DEACTIVATE Old ESN and associate MIN with New ESN  ****/
   IF (rec_new_part_inst_c.WARR_END_DATE
   IS
   NULL
   OR (rec_new_part_inst_c.WARR_END_DATE < rec_old_part_inst_c.WARR_END_DATE))
   THEN
      UPDATE table_part_inst SET warr_end_date = rec_old_part_inst_c.WARR_END_DATE
      WHERE objid = rec_new_part_inst_c.objid;
   END IF;
   FOR rec_ActiveSite IN getActiveSite(rec_old_part_inst_c.part_serial_no)
   LOOP
      OPEN checkMin;
      FETCH checkMin
      INTO iCheckMin;
      CLOSE checkMin;
      IF iCheckMin > 0
      THEN
         bValue := 'true';
      ELSE
         bValue := 'false';
      END IF;
      -- Call Deactivate package
      sa.SERVICE_DEACTIVATION.deactService('Clarify', strUserObjid,
      rec_old_part_inst_c.part_serial_no, rec_ActiveSite.X_MIN,
      'WAREHOUSE PHONE',      0, rec_new_part_inst_c.part_serial_no, bValue,
      v_return, v_returnMsg);
      DBMS_OUTPUT.put_line('ServiceDeactivation:' ||v_return || ': '||
      v_returnMsg);
   END LOOP;
   -- Issue Replacement Units on customer's new ESN
   --CR3221 Start Modified this part
   -- CR3221  to add new ESN to fraud case and to append fraud units to replacement units if the warehouse case is still open
   --get the new ESN
   IF rec_case_c.s_title = 'DEFECTIVE PHONE'
   THEN
      tempEsn := rec_case_c.x_stock_type;
   ELSE
      tempEsn := rec_alt_esn_c.x_replacement_esn;
   END IF;
   -- Get Objid of Fraud case
   IF rec_ext_case_c.x_fraud_id != ''
   AND rec_ext_case_c.x_fraud_id
   IS
   NOT NULL
   AND rec_ext_case_c.x_fraud_id != 0
   THEN
      SELECT objid
      INTO tempobjid
      FROM table_CAse
      WHERE id_number = rec_ext_case_c.x_fraud_id;
   END IF;
   -- update the new esn to Fraud case
   SELECT COUNT(*)
   INTO cnt
   FROM table_Case, table_x_alt_esn
   WHERE table_x_alt_esn.x_alt_esn2case = table_case.Objid
   AND table_x_alt_esn.x_alt_esn2case = (
   SELECT objid
   FROM table_Case
   WHERE objid = rec_ext_case_c.x_fraud_id);
   IF cnt = 0
   THEN
      INSERT
      INTO table_x_alt_esn(
         objid,
         x_replacement_esn,
         x_alt_esn2case
      )VALUES(
         seq('x_alt_esn'),
         tempEsn,
         tempobjid
      );
   ELSE
UPDATE table_x_alt_esn SET x_replacement_esn = tempEsn
      WHERE rec_case_c.objid = rec_alt_esn_c.x_alt_esn2case
      AND rec_alt_esn_c.x_alt_esn2case = tempobjid;
   END IF;
   IF (rec_case_c.x_replacement_units > 9)
   THEN

      SELECT cond.s_title
      INTO temptitle
      FROM table_condition cond, table_case ca
      WHERE cond.objid = ca.case_state2condition
      AND         ca.objid = rec_case_c.objid;
      IF temptitle <> 'CLOSED'
      THEN
        ActualUnits := rec_case_c.x_replacement_units + rec_ext_case_c.x_fraud_units;
      ELSE
        ActualUnits := rec_case_c.x_replacement_units;
      END IF;
      sa.SP_ISSUE_COMPUNITS(rec_new_part_inst_c.objid, ActualUnits, rec_case_c.id_number
      , v_return, v_returnMsg);
      DBMS_OUTPUT.put_line('Compensation Units:' ||v_return || ': '||
      v_returnMsg);
   END IF;
   --CR3221 End
   /***** CR2834 Ends Here ***********************************************************/
   COMMIT;
   EXCEPTION
   WHEN OTHERS
   THEN
      p_error_message := 'Exception occured while running procedure';
      RETURN;
END UPDATE_EXCH_CASE_PRC;
/