CREATE OR REPLACE PROCEDURE sa."UPDATE_FRAUD_CASE_PRC" (
   strFraudId IN VARCHAR2,
   strEsn IN VARCHAR2,
   strActdate IN VARCHAR2,
   strRedemptionUnits IN VARCHAR2,
   strUsageUnits IN VARCHAR2,
   strUserObjid IN VARCHAR2,
   strGbstObjid IN VARCHAR2,
   p_error_message OUT VARCHAR2
)
AS
/********************************************************************************************/
   /*    Copyright   2004 Tracfone  Wireless Inc. All rights reserved                          */
   /* NAME     :       UPDATE_FRAUD_CASE_PRC                                                   */
   /* PURPOSE  :       This procedure is called from the Clarify Clear Support-->Action        */
   /*                  when an Fraud cases is processed and closed.                            */
   /* FREQUENCY:                                                                               */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                           */
   /*                                                                                          */
   /* REVISIONS:                                                                               */
   /* VERSION  DATE        WHO                 PURPOSE                                         */
   /* -------  ---------- -----                ---------------------------------------------   */
   /*  1.0     09/01/04   Muralidhar Chinta    Initial  Revision                               */
   /*  1.1     12/01/04   Muralidhar Chinta    changed notes added to Fraud cases  for CR3368  */
   /*  1.2 / 1.3 / 1.4    -----
   /*  1.5     01/28/05   Ritu Gandhi          CR3373 - Case Mod on Web                        */
   /*                                          Assign a resolution to the case when  it is closed*/
   /* 1.6      04/04/05                        Changed the revision to match PVCS              */
   /* 1.7      04/29/05                        CR3348 to see that we process only Open Fraud cases*/
   /********************************************************************************************/
   --Get Fraud case Info from fraud case id
   CURSOR case_c
   IS
   SELECT c.*
   FROM table_case c, table_condition con
   WHERE c.case_state2condition = con.objid -- CR3348
   AND con.s_title <> 'CLOSED' --CR3348
   AND c.id_number = strFraudId;
   rec_case_c case_c%ROWTYPE;
   --get Warehouse case details.
   CURSOR whcase_c(
      fraud_id VARCHAR2
   )
   IS
   SELECT wc.*
   FROM table_case wc, table_x_case_extra_info E
   WHERE wc.objid = E.x_extra_info2x_case
   AND E.x_fraud_id = fraud_id;
   rec_whcase_c whcase_c%ROWTYPE;
   -- To get Condition of WareHouse Case
   CURSOR casecond_c(
      whcase_id VARCHAR2
   )
   IS
   SELECT cond.*
   FROM table_case a, table_condition cond
   WHERE cond.objid = a.case_state2condition
   AND a.id_number = whcase_id;
   rec_casecond_c casecond_c%ROWTYPE;
   -- To get Replacement ESN(new)
   CURSOR alt_esn_c(
      altwhCase_id VARCHAR2
   )
   IS
   SELECT ae.*
   FROM table_x_alt_esn ae, table_case ce
   WHERE ae.x_alt_esn2case = ce.objid
   AND ce.id_number = altwhCase_id;
   rec_alt_esn_c alt_esn_c%ROWTYPE;
   --get Case Extra info details.
   CURSOR excase_c(
      whobjid VARCHAR2
   )
   IS
   SELECT excase.*
   FROM table_case exc, table_x_case_extra_info excase
   WHERE exc.objid = excase.x_extra_info2x_case
   AND excase.x_extra_info2x_case = whobjid;
   rec_excase_c excase_c%ROWTYPE;
   --Get the new esn
   CURSOR new_part_inst_c(
      p_esn VARCHAR2
   )
   IS
   SELECT *
   FROM table_part_inst
   WHERE part_serial_no = p_esn;
   rec_new_part_inst_c new_part_inst_c%ROWTYPE;
   --CR3373 - Starts
   CURSOR csrCloseCase(
      c_objid NUMBER
   )
   IS
   SELECT *
   FROM table_close_case
   WHERE last_close2case = c_objid;
   recCloseCase csrCloseCase%ROWTYPE;
   CURSOR csrWebResol(
      c_case_type VARCHAR2,
      c_case_title VARCHAR2,
      c_resolution VARCHAR2
   )
   IS
   SELECT *
   FROM table_x_web_case_resolution
   WHERE x_case_type = c_case_type
   AND x_case_title = c_case_title
   AND x_case_status = 'Closed'
   AND x_resolution = c_resolution;
   recWebResol csrWebResol%ROWTYPE;
   --CR3373 - Ends
   strFraudHistory table_case.case_history%TYPE;
   strWhHistory table_case.case_history%TYPE;
   strUserName VARCHAR2(50);
   strreplUnits VARCHAR2(10);
   v_units NUMBER;
   v_status VARCHAR2(1);
   v_message VARCHAR2(250);
   v_notes VARCHAR2(250);
   strWhId VARCHAR2(10);
   strreplEsn VARCHAR2(15);
   strAppendEsn VARCHAR2(15);
   strcustclaimUnits VARCHAR2(10);
   cnt VARCHAR2(10);
   strX NUMBER; --CR3368
   strY NUMBER; --CR3368
   v_return VARCHAR2(20);
   v_returnMsg VARCHAR2(300);
   Temperror VARCHAR2(300);
   Temp_fraud VARCHAR2(300);
--CR3368
BEGIN
   p_error_message := '';
   --Get the Fraud case details
   OPEN case_c;
   FETCH case_c
   INTO rec_case_c;
   IF case_c%NOTFOUND
   THEN
      p_error_message := 'Fraud Case not found / Already Closed'; --CR3348
      CLOSE case_c;
      RETURN;
   END IF;
   CLOSE case_c;
   --get Warehouse case details.
   OPEN whcase_c(rec_case_c.id_number);
   FETCH whcase_c
   INTO rec_whcase_c;
   -- CR3295 Start
   -- Commented the below 4 lines
   IF whcase_c%NOTFOUND
   THEN
      strWhId := '';
      strreplUnits := 0;
      strcustclaimUnits := 0;
      --Get Extra_Info record
      OPEN excase_c(rec_case_c.objid);
      FETCH excase_c
      INTO rec_excase_c;
      IF excase_c%FOUND
      THEN
         strcustclaimUnits := rec_excase_c.x_cust_units_claim;
         strcustclaimUnits := NVL(strcustclaimUnits, '0');
      END IF;
      CLOSE excase_c;
--        p_error_message := 'WareHouse Case not found';
   --        CLOSE case_c;
   --        return;
   ELSE

      --get Wh case Codition
      OPEN casecond_c(rec_whcase_c.id_number);
      FETCH casecond_c
      INTO rec_casecond_c;
      CLOSE casecond_c;
      --Get alt_esn record
      OPEN alt_esn_c(rec_whcase_c.id_number);
      FETCH alt_esn_c
      INTO rec_alt_esn_c;
      CLOSE alt_esn_c;
      --Get Extra_Info record
      OPEN excase_c(rec_whcase_c.objid);
      FETCH excase_c
      INTO rec_excase_c;
      CLOSE excase_c;
      --Get New ESN record
      OPEN new_part_inst_c(rec_alt_esn_c.x_replacement_esn);
      FETCH new_part_inst_c
      INTO rec_new_part_inst_c;
      CLOSE new_part_inst_c;
      strWhId := rec_whcase_c.id_number;
      strreplUnits := rec_whcase_c.x_replacement_units;
      strcustclaimUnits := rec_excase_c.x_cust_units_claim;
   END IF;
   CLOSE whcase_c;
   DBMS_OUTPUT.put_line('strWhId' || strWhId);
   DBMS_OUTPUT.put_line('strreplUnits' || strreplUnits);
   DBMS_OUTPUT.put_line('strUsageUnits' || strUsageUnits);
   DBMS_OUTPUT.put_line('strRedemptionUnits' || strRedemptionUnits);
   DBMS_OUTPUT.put_line('strreplEsn' || strreplEsn);
   DBMS_OUTPUT.put_line('strcustclaimUnits' || strcustclaimUnits);
   strX := (strRedemptionUnits - strUsageUnits - strreplUnits);
   strY := strcustclaimUnits - strreplUnits;
   DBMS_OUTPUT.put_line('strX' || strX);
   DBMS_OUTPUT.put_line('strY' || strY);
   IF (strX < 1)
   THEN
     v_units := 0;

   ELSIF (strY < 1)
   THEN
     v_units := strX;

   ELSIF (strX <= strY)
   THEN
     v_units := strX;

   ELSE
     v_units := strY;

   END IF;
   v_units := TRUNC(v_units);
   IF (MOD(v_units, 10) < 5)
   THEN
     v_units := v_units - MOD(v_units, 10);

   ELSE
     v_units := v_units + (10 - MOD(v_units, 10));

   END IF;
   DBMS_OUTPUT.put_line('v_units ' || v_units);
   --' CR3368 Changed Text for v_notes
   IF ((rec_casecond_c.s_title LIKE 'CLOSED'))
   THEN

      IF v_units > 0
      THEN
             v_notes := v_units ||
' Units are approved by Fraud and are available with next redemption after' ||
TO_CHAR(SYSDATE, 'mm/dd/yyyy') ||
'.Please verify HISTORY to confirm Redemption before granting additional Units'
;

      ELSE
     v_notes :=
'Fraud case resolved.No Units can be issued to the customer.Logged Notes on '
|| TO_CHAR(SYSDATE, 'mm/dd/yyyy');

      END IF;

   ELSE

      IF v_units > 0
      THEN
             v_notes := v_units ||
' Units have been approved by Fraud.Units will be pended automatically to New handset.Logged notes on '
|| TO_CHAR(SYSDATE, 'mm/dd/yyyy');

      ELSE
     v_notes :=
'Fraud case resolved.No Units can be issued to the customer.Logged Notes on '
|| TO_CHAR(SYSDATE, 'mm/dd/yyyy');

      END IF;

   END IF;
   --' CR3368 Start
   IF ((strWhId != '')
   OR (strWhId
   IS
   NOT NULL))
   THEN
      Temp_fraud := '.Units associated to Case ID ' || strWhId;
   ELSE
      Temp_fraud := '';
   END IF;
   --' CR3368 End
   DBMS_OUTPUT.put_line('v_units' || v_units);
   DBMS_OUTPUT.put_line('v_notes' || v_notes);
   --Update Fraud case table History
   strFraudHistory := rec_case_c.case_history || CHR(10) || CHR(13) || v_notes
   || Temp_fraud; --' CR3368
   --Update Fraud case table History
   UPDATE table_case         SET case_history = strFraudHistory
   WHERE objid = rec_case_c.objid;
   -- Update fraud Units field on both cases
   SELECT COUNT(*)
   INTO cnt
   FROM table_case c, table_x_case_extra_info ex
   WHERE ex.x_extra_info2x_case = c.objid
   AND c.id_number = rec_case_c.id_number;
   IF cnt = 0
   THEN
INSERT
      INTO table_x_case_extra_info(
         objid,
         x_extra_info2x_case,
         x_fraud_units
      )VALUES(
         Seq('x_case_extra_info'),
         rec_case_c.objid,
         v_units
      );
   ELSE
      UPDATE table_x_case_extra_info SET x_fraud_units = v_units
      WHERE x_extra_info2x_case = rec_case_c.objid;
   END IF;
   --' CR3368 Start
   IF ((strWhId != '')
   OR (LENGTH(strWhId) > 3) )
   THEN

      --' To add additional notes if the Warehouse case is not closed.
      Temp_fraud := '';
      IF ((rec_casecond_c.s_title <> 'CLOSED'))
      THEN
         Temp_fraud := '.Units from Unit verification case ' ||rec_case_c.id_number
         ;
      ELSE
         Temp_fraud := '';
      END IF;
      --Update WareHouse case table History
      strWhHistory := rec_whcase_c.case_history || CHR(10) || CHR(13) ||
      v_notes || Temp_fraud;
      --' CR3368 End
      --Warehouse case
      UPDATE table_case         SET case_history = strWhHistory
      WHERE objid = rec_whcase_c.objid;
      ---WareHouse case
      SELECT COUNT(*)
      INTO cnt
      FROM table_case c1, table_x_case_extra_info ex1
      WHERE ex1.x_extra_info2x_case = c1.objid
      AND ex1.x_extra_info2x_case = rec_whcase_c.objid;
      IF cnt = 0
      THEN
INSERT
         INTO table_x_case_extra_info(
            objid,
            x_extra_info2x_case,
            x_fraud_units
         )VALUES(
            Seq('x_case_extra_info'),
            rec_whcase_c.objid,
            v_units
         );
      ELSE
UPDATE table_x_case_extra_info SET x_fraud_units = v_units
         WHERE x_extra_info2x_case = rec_whcase_c.objid;
      END IF;
   END IF;
   IF (((strWhId != '')
   OR (strWhId
   IS
   NOT NULL))
   AND (rec_casecond_c.s_title LIKE 'CLOSED'))
   THEN
--' CR3368 Start
      --Update the replacement ESN to Fraud case
      --        Check to see if its Phone upgrade/Warranty or any other case
      IF ((rec_whcase_c.s_title = 'DEFECTIVE PHONE')
      OR (rec_whcase_c.s_title = 'PHONE UPGRADE')
      OR (rec_whcase_c.s_title = 'UNIT TRANSFER'))
      THEN
         SELECT x_stock_type
         INTO strreplEsn
         FROM table_Case
         WHERE objid = rec_whcase_c.objid;
      ELSE
         SELECT x_replacement_esn
         INTO strreplEsn
         FROM table_case, table_x_alt_esn
         WHERE table_x_alt_esn.x_alt_esn2case = table_Case.Objid
         AND table_x_alt_esn.x_alt_esn2case = rec_whcase_c.objid;
      END IF;
      SELECT COUNT(*)
      INTO cnt
      FROM table_Case, table_x_alt_esn
      WHERE table_x_alt_esn.x_alt_esn2case = table_case.Objid
      AND table_x_alt_esn.x_alt_esn2case = rec_case_c.objid;
      IF cnt = 0
      THEN
         INSERT
         INTO table_x_alt_esn(
            objid,
            x_replacement_esn,
            x_alt_esn2case
         )VALUES(
            Seq('x_alt_esn'),
            strreplEsn,
            rec_case_c.objid
         );
      ELSE
UPDATE table_x_alt_esn SET x_replacement_esn = strreplEsn
         WHERE rec_case_c.objid = rec_alt_esn_c.x_alt_esn2case;
      END IF;
      -- Pend Units to the ESN
      -- Issue Replacement Units on customer's new ESN
      SELECT p.objid
      INTO strAppendEsn
      FROM table_part_inst p
      WHERE p.part_serial_no = strreplEsn;
      IF (v_units > 0 )
      THEN
         sa.Sp_Issue_Compunits(strAppendEsn, v_units, rec_whcase_c.id_number,
         v_return, v_returnMsg);
         DBMS_OUTPUT.put_line('Replacement Units:' ||v_return || ': '||
         v_returnMsg);
      END IF;
   END IF;
   -- Pend Units to NEW ESN if present for fraud case.
   IF ((strWhId = '')
   OR (strWhId
   IS
   NULL))
   THEN
      SELECT x_stock_type
      INTO strAppendEsn
      FROM table_case
      WHERE objid = rec_case_c.objid ;
      IF (strAppendEsn
      IS
      NOT NULL
      OR (LENGTH(strAppendEsn) > 8))
      THEN
         IF (v_units > 0 )
         THEN
            sa.Sp_Issue_Compunits(strAppendEsn, v_units, rec_case_c.id_number,
            v_return, v_returnMsg);
            DBMS_OUTPUT.put_line('Replacement Units:' ||v_return || ': '||
            v_returnMsg);
         END IF;
      END IF;
   END IF;
   COMMIT;
   --'CR3368 Start
   --' Close the Alt_Esn record associated to Fraud Case.
   /*     sp_chg_esn(rec_case_c.x_esn,v_status,v_message);
       if v_status <> 'F' THEN
        UPDATE table_x_alt_esn
        SET x_status = 'CLOSED'
       WHERE objid = rec_alt_esn_c.objid;
     END IF;
   */
   UPDATE table_x_alt_esn SET x_status = 'CLOSED'
   WHERE x_alt_esn2case = rec_case_c.objid;
   --'CR3368 End.
   --' Inserting into Act_entry table
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
      Seq('act_entry'),
      '1500',
      SYSDATE,
      'Fraud Units Updated',
      rec_case_c.objid,
      strUserObjid,
      strGbstObjid
   );
   IF strWhId <> ''
   THEN
     INSERT
      INTO table_act_entry(
         objid,
         act_code,
         entry_time,
         addnl_info,
         act_entry2case,
         act_entry2user,
         entry_name2gbst_elm
      )      VALUES(
         Seq('act_entry'),
         '1500',
         SYSDATE,
         'Fraud Units Updated',
         rec_whcase_c.objid,
         strUserObjid,
         strGbstObjid
      );
   END IF;
   -- Closing Fraud Case
   SELECT login_name
   INTO strUserName
   FROM table_user
   WHERE objid = strUserObjid;
   DBMS_OUTPUT.put_line('v_status' || v_status);
   DBMS_OUTPUT.put_line('v_message' || v_message);
   Igate.SP_CLOSE_CASE(rec_case_c.id_number, strUserName, 'CLARIFY',
   'Resolution Given', v_status, v_message);
   /*CR3373 - Starts - Case mod on the Web - Assign resolution to the closed case depending on the units granted*/
   OPEN csrCloseCase(rec_case_c.objid);
   FETCH csrCloseCase
   INTO recCloseCase;
   CLOSE csrCloseCase;
   IF v_units > 0
   THEN
      OPEN csrWebResol(rec_case_c.x_case_type, rec_case_c.title, 'Pend units');
   ELSE
      OPEN csrWebResol(rec_case_c.x_case_type, rec_case_c.title,
      'No ESN associated to the case');
   END IF;
   FETCH csrWebResol
   INTO recWebResol;
   CLOSE csrWebResol;
   UPDATE table_close_case SET close_case2case_resol = recWebResol.objid
   WHERE objid = recCloseCase.objid;
   COMMIT;
   /*CR3373 - Ends - Case mod on the Web*/
   DBMS_OUTPUT.put_line('v_statusout' || v_status);
   DBMS_OUTPUT.put_line('v_messageout' || v_message);
   COMMIT;
   EXCEPTION
   WHEN OTHERS
   THEN
      Temperror := p_error_message;
      IF Temperror = ''
      THEN
         p_error_message := 'Exception occured while running procedure';
      ELSE
         p_error_message := Temperror;
      END IF;
      RETURN;
END Update_Fraud_Case_Prc;
/