CREATE OR REPLACE PROCEDURE sa."PROCESS_OPEN_FRAUD_CASES_PRC"
IS
/********************************************************************************/
   /* Copyright ? 2005 Tracfone Wireless Inc. All rights reserved                  */
   /*                                                                              */
   /* Name         :   process_open_fraud_cases.sql                                */
   /* Purpose      :   Close all open cases greater then 40 days		        */
   /*                  						                */
   /*                                                                              */
   /* Parameters   :                          					*/
   /* Platforms    :   Oracle 8.0.6 AND newer versions                             */
   /* Author	:   Muralidhar Chinta                                		*/
   /*                  TCS			                               		*/
   /* Date         :   April 26,2005                                               */
   /* Revisions	:   Version  Date      Who       Purpose                        */
   /*                  -------  --------  -------   ------------------------------ */
   /*               1.0     04/26/05   TCS
   /*               1.1     05/02/05   VAdapa       Fix for the insert statement
   /*               1.2     05/04/05   MChintha     Modified to handle the additional requirements
   /********************************************************************************/
   --Get all open fraud cases that were opened more that x_fraud_params.No_Of_Days ago.
   CURSOR csrFraudCases
   IS
   SELECT C.Objid,
      C.Id_Number,
      C.x_Esn
   FROM TABLE_CASE C, TABLE_CONDITION CO,TABLE_X_CASE_EXTRA_INFO ce  --, X_FRAUD_PARAMS FP
   WHERE  CO.OBJID = C.CASE_STATE2CONDITION
   AND c.objid = ce.x_extra_info2x_case
   AND CO.TITLE LIKE 'Open%'
   AND ce.x_cust_units_claim > 0
   AND C.s_Title = 'UNITS VERIFICATION'
   AND c.x_case_type = 'Loss Prevention'
   AND C.Creation_Time <= TRUNC(SYSDATE - 40);
  -- and c.id_number = '7261771';


   recFraudCases csrFraudCases%ROWTYPE;
   --Get the extra info for the fraud case
   CURSOR csrCaseExtraInfo(
      case_objid NUMBER
   )
   IS
   SELECT x_cust_units_claim
   FROM TABLE_X_CASE_EXTRA_INFO
   WHERE x_extra_info2x_case = case_objid;
   v_iUnitsClaimed NUMBER := 0;
   --Get the parent case for the fraud case
   CURSOR csrParentCase(
      c_fraud_case_id VARCHAR2
   )
   IS
   SELECT C.x_Replacement_Units,
      CE.x_Cust_Units_Claim,
      C.s_Title,
      C.Objid,
      C.x_stock_type
   FROM TABLE_CASE C, TABLE_X_CASE_EXTRA_INFO CE
   WHERE C.OBJID = CE.X_EXTRA_INFO2X_CASE
   AND CE.x_Fraud_Id = c_fraud_case_id;
   recParentCase csrParentCase%ROWTYPE;
   v_esn_objid NUMBER;
   v_return VARCHAR2(10);
   v_return_msg VARCHAR2(200);
   v_iReplacementUnits NUMBER := 0;
   v_repl_esn VARCHAR2(30);
   blnParentFound BOOLEAN := FALSE;
   frdcnt NUMBER;
   iTotalRecords INT :=0;
   iLessThan500 INT :=0;
   iMoreThan500 INT :=0;
   issueUnits NUMBER := 0;
   iFailed INT := 0;
BEGIN
   FOR recFraudCases IN csrFraudCases
   LOOP
     BEGIN
        iTotalRecords := iTotalRecords + 1;
        blnParentFound := FALSE;
        v_iUnitsClaimed := 0;
        v_iReplacementUnits := 0;
        v_repl_esn := recFraudCases.x_esn;
        OPEN csrCaseExtraInfo(recFraudCases.objid);
        FETCH csrCaseExtraInfo
        INTO v_iUnitsClaimed;
        CLOSE csrCaseExtraInfo;
        --Get the parent case
        OPEN csrParentCase(recFraudCases.id_number);
        FETCH csrParentCase
        INTO recParentCase;
        IF csrParentCase%FOUND
        THEN
           blnParentFound := TRUE;
           v_iReplacementUnits := recParentCase.x_replacement_units;
           --v_iUnitsClaimed := recParentCase.x_Cust_Units_Claim;
           IF recParentCase.s_title = 'DEFECTIVE PHONE'
           OR recParentCase.s_title = 'PHONE UPGRADE'
           OR recParentCase.s_title = 'UNIT TRANSFER'
           THEN
              v_repl_esn := recParentCase.x_stock_type;
           ELSE
              SELECT x_replacement_esn
              INTO v_repl_esn
              FROM TABLE_CASE, TABLE_X_ALT_ESN
              WHERE TABLE_X_ALT_ESN.x_alt_esn2case = TABLE_CASE.Objid
              AND TABLE_X_ALT_ESN.x_alt_esn2case = recParentCase.objid;
           END IF;
        END IF;
        CLOSE csrParentCase;
       --dbms_output.put_line ('Case ID ' || recFraudCases.id_number || 'Units ' ||v_iUnitsClaimed);
        IF v_iUnitsClaimed > 0 AND v_iUnitsClaimed <= 500 THEN
           iLessThan500 := iLessThan500 + 1;
           IF v_repl_esn IS NOT NULL OR LENGTH(v_repl_esn) <= 15  THEN
             SELECT objid
             INTO v_esn_objid
             FROM TABLE_PART_INST
             WHERE part_serial_no = v_repl_esn;

             issueUnits := v_iUnitsClaimed - v_iReplacementUnits;
                IF (MOD(issueUnits, 10) < 5) THEN
              	 issueUnits := issueUnits - MOD(issueUnits, 10);
                 ELSE
              	 issueUnits := issueUnits + (10 - MOD(issueUnits, 10));
                ENd IF;
             Sp_Issue_Compunits(v_esn_objid, issueUnits,recFraudCases.id_number, v_return, v_return_msg);
           END IF;
        UPDATE TABLE_X_CASE_EXTRA_INFO SET x_fraud_units = v_iUnitsClaimed - v_iReplacementUnits
        WHERE x_extra_info2x_case = recFraudCases.objid;
        COMMIT;
        IF blnParentFound = TRUE THEN
           UPDATE TABLE_X_CASE_EXTRA_INFO SET x_fraud_units = v_iUnitsClaimed - v_iReplacementUnits
           WHERE x_extra_info2x_case = recParentCase.objid;
        END IF;
       COMMIT;
       SELECT COUNT(*) INTO frdcnt FROM X_FRAUD_CASES WHERE x_case_id = recFraudCases.id_number;
     --  dbms_output.put_line ('frdcnt <500 ' || frdcnt );
       IF frdcnt = 0 THEN
          INSERT INTO sa.X_FRAUD_CASES(
                x_case_id,
                x_esn,
                x_units,
                x_date_issued,
                x_insert_date
           )VALUES(
                recFraudCases.id_number,
                recFraudCases.x_esn,
                v_iUnitsClaimed,
                SYSDATE,
                SYSDATE
           );
           COMMIT;
        END IF;
           Igate.sp_close_case(recFraudCases.id_number, 'sa',
           'process_open_fraud_cases', 'Resolution Given', v_return, v_return_msg
           );
           COMMIT;
        ELSIF v_iUnitsClaimed > 500 THEN
          iMoreThan500 := iMoreThan500 + 1;
          SELECT COUNT(*) INTO frdcnt FROM X_FRAUD_CASES WHERE x_case_id = recFraudCases.id_number;
         --         dbms_output.put_line ('frdcnt > 500 ' || frdcnt );
          IF frdcnt = 0 THEN
           INSERT INTO sa.X_FRAUD_CASES(
              x_case_id,
              x_esn,
              x_units,
              x_insert_date
           ) VALUES(
              recFraudCases.id_number,
              recFraudCases.x_esn,
              v_iUnitsClaimed,
              SYSDATE
           );
           COMMIT;
          END IF;
           COMMIT;
        END IF;
   --     dbms_output.put_line ('Case ID ' || recFraudCases.id_number );
      EXCEPTION
          WHEN OTHERS THEN
               iFailed := iFailed + 1;
               GOTO next_case;
      END;
      <<next_case>>
      NULL;
   END LOOP;
   dbms_output.put_line('Total records processed = ' || iTotalRecords);
   dbms_output.put_line('Total records with units <=500 = ' || iLessThan500);
   dbms_output.put_line('Total records with units >500 = ' || iMoreThan500);
   dbms_output.put_line('Total failed records = ' || iFailed);
END Process_Open_Fraud_Cases_Prc;
/