CREATE OR REPLACE PROCEDURE sa."AP_MON1"
AS
/*****************************************************************
   * Package Name: ap_mon1
   * Purpose     :  This procedure will monitor the site part for activations of all esn's residing
   		   in the pending table and move it to the autopay detail table.
   * Author      : Curt Linder.
   * Date        :  12/15/2002
   * History     :
   ---------------------------------------------------------------------
    12/15/2002          CL          Initial version
    04/10/2003          SL          Clarify Upgrade - sequence
    05/10/2003          SU		    CR 1157. Correct autopay details table.
    08/31/04            VA          CR3160 - Add exception block
   *********************************************************************/
   ------------------------------------------------------------
   CURSOR check_pending_curs
   IS
   SELECT ap.*
   FROM sa.x_autopay_pending ap
   WHERE EXISTS (
   SELECT 1
   FROM table_site_part sp
   WHERE sp.x_service_id = ap.x_esn
   AND sp.part_status = 'Active')
   ORDER BY x_creation_date;
   ------------------------------------------------------------
   CURSOR user_curs(
      c_login_name IN VARCHAR2
   )
   IS
   SELECT objid
   FROM table_user
   WHERE s_login_name = UPPER(c_login_name);
   user_rec user_curs%ROWTYPE;
   ------------------------------------------------------------
   CURSOR carrier_curs(
      c_min IN VARCHAR2
   )
   IS
   SELECT part_inst2carrier_mkt
   FROM table_part_inst
   WHERE part_serial_no = c_min;
   carrier_rec carrier_curs%ROWTYPE;
   ------------------------------------------------------------
   CURSOR site_part_curs(
      c_esn IN VARCHAR2
   )
   IS
   SELECT *
   FROM table_site_part
   WHERE x_service_id = c_esn
   AND part_status = 'Active';
   site_part_rec site_part_curs%ROWTYPE;
   ------------------------------------------------------------
   CURSOR check_detail_status_curs(
      c_esn IN VARCHAR2,
      c_program_type IN NUMBER
   )
   IS
   SELECT *
   FROM TABLE_X_AUTOPAY_DETAILS
   WHERE x_esn = c_esn
   AND x_program_type = c_program_type
   AND x_status IN ('A', 'E');
   check_detail_status_rec check_detail_status_curs%ROWTYPE;
   ------------------------------------------------------------
   v_MSG VARCHAR2(1000);
   v_P_STATUS VARCHAR2(100);
   ------------------------------------------------------------
   --CR3160 Changes
   l_action VARCHAR2(2000);
   l_serial_num VARCHAR2(20);
   l_procedure_name VARCHAR2(100) := 'SA.AP_MON1';
--End CR3160 Changes
BEGIN
   DBMS_OUTPUT.put_line('start');
   --------------------------------------------------
   OPEN user_curs('SA');
   FETCH user_curs
   INTO user_rec;
   CLOSE user_curs;
   --------------------------------------------------
   FOR check_pending_rec IN check_pending_curs
   LOOP
--CR3160 Changes
      BEGIN
         l_serial_num := check_pending_rec.x_esn;
         l_action := 'Check Pending Esn Records';
         --End CR3160 Changes
         DBMS_OUTPUT.put_line('check_pending_rec.x_esn:'||check_pending_rec.x_esn
         );
         OPEN site_part_curs(check_pending_rec.x_esn);
         OPEN check_detail_status_curs(check_pending_rec.x_esn,
         check_pending_rec.X_PROGRAM_TYPE);
         FETCH site_part_curs
         INTO site_part_rec;
         FETCH check_detail_status_curs
         INTO check_detail_status_rec;
         --
         IF site_part_curs%found
         THEN
            DBMS_OUTPUT.put_line('site_part_curs%found');
         ELSE
            DBMS_OUTPUT.put_line('site_part_curs%notfound');
         END IF;
         IF check_detail_status_curs%notfound
         THEN
            DBMS_OUTPUT.put_line('check_detail_status_curs%notfound');
         ELSE
            DBMS_OUTPUT.put_line('check_detail_status_curs%found');
         END IF;
         DBMS_OUTPUT.put_line('check_pending_rec.X_SOURCE_FLAG:'||
         check_pending_rec.X_SOURCE_FLAG);
         DBMS_OUTPUT.put_line('check_pending_rec.x_status:'||check_pending_rec.x_status
         );
         DBMS_OUTPUT.put_line('check_pending_rec.X_PROGRAM_TYPE:'||
         check_pending_rec.X_PROGRAM_TYPE);
         DBMS_OUTPUT.put_line('check_detail_status_rec.x_status:'||
         check_detail_status_rec.x_status);
         --
         IF (site_part_curs%found
         AND check_detail_status_curs%notfound
         AND check_pending_rec.X_SOURCE_FLAG = 'B'
         AND check_pending_rec.x_status IN ('A', 'E'))
         OR (site_part_curs%found
         AND check_detail_status_curs%notfound
         AND check_pending_rec.X_SOURCE_FLAG = 'E'
         AND check_pending_rec.x_status = 'A')
         OR (site_part_curs%found
         AND check_detail_status_curs%found
         AND check_detail_status_rec.x_status = 'E'
         AND check_pending_rec.X_SOURCE_FLAG IN ('B', 'E')
         AND check_pending_rec.x_status = 'A' )
         OR (check_pending_rec.X_SOURCE_FLAG = 'D')
         OR (site_part_curs%found
         AND check_detail_status_curs%found
         AND check_detail_status_rec.x_status = 'A'
         AND (check_detail_status_rec.x_receive_status = 'R'
         OR check_detail_status_rec.x_receive_status
         IS
         NULL )) --fixed by SUganthi -03132003
         THEN
            IF check_pending_rec.X_SOURCE_FLAG = 'D'
            THEN
               DBMS_OUTPUT.put_line('site_part_rec.x_min:'||site_part_rec.x_min
               );
               OPEN carrier_curs(site_part_rec.x_min);
               FETCH carrier_curs
               INTO carrier_rec;
               CLOSE carrier_curs;
               l_action := 'Insert into table_x_autopay_Details'; --CR3160
               -- Start CR 1157
               INSERT
               INTO table_X_autopay_details(
                  OBJID,
                  X_CREATION_DATE,
                  X_ESN,
                  X_PROGRAM_TYPE,
                  X_ACCOUNT_STATUS,
                  X_STATUS,
                  X_START_DATE,
                  X_END_DATE,
                  X_CYCLE_NUMBER,
                  X_PROGRAM_NAME,
                  X_ENROLL_DATE,
                  X_FIRST_NAME,
                  X_LAST_NAME,
                  X_RECEIVE_STATUS,
                  X_AUTOPAY_DETAILS2SITE_PART,
                  X_AUTOPAY_DETAILS2X_PART_INST,
                  X_AUTOPAY_DETAILS2CONTACT,
                  X_ENROLL_AMOUNT,
                  X_LANGUAGE_FLAG,
                  X_PAYMENT_TYPE,
                  X_PROMOCODE,
                  X_SOURCE
               )VALUES(
                  sa.seq('X_AUTOPAY_DETAILS'),
                  check_pending_rec.X_CREATION_DATE,
                  check_pending_rec.X_ESN,
                  check_pending_rec.X_PROGRAM_TYPE,
                  check_pending_rec.X_ACCOUNT_STATUS,
                  check_pending_rec.X_STATUS,
                  SYSDATE,
                  NULL,
                  check_pending_rec.X_CYCLE_NUMBER,
                  check_pending_rec.X_PROGRAM_NAME,
                  check_pending_rec.X_ENROLL_DATE,
                  check_pending_rec.X_FIRST_NAME,
                  check_pending_rec.X_LAST_NAME,
                  check_pending_rec.X_RECEIVE_STATUS,
                  site_part_rec.objid,  --relates to the 'Active' Site Part record.
                  check_pending_rec.X_AUTOPAY_DETAILS2X_PART_INST,
                  check_pending_rec.X_AUTOPAY_DETAILS2CONTACT,
                  check_pending_rec.X_ENROLL_AMOUNT,
                  check_pending_rec.X_LANGUAGE_FLAG,
                  check_pending_rec.X_PAYMENT_TYPE,
                  check_pending_rec.X_PROMOCODE,
                  check_pending_rec.X_SOURCE
               );
               /* update table_x_autopay_details
               set x_status = 'A',
                 X_ACCOUNT_STATUS = 3,
                 x_end_date = null
               where objid = check_pending_rec.objid;
                      */
               -- End CR 1157
               l_action := 'Insert into table_x_call_Trans'; --CR3160
               INSERT
               INTO TABLE_X_CALL_TRANS(
                  objid,
                  call_trans2site_part,
                  x_action_type,
                  x_call_trans2carrier,
                  x_call_trans2dealer,
                  x_call_trans2user,
                  x_line_status,
                  x_min,
                  x_service_id,
                  x_sourcesystem,
                  x_transact_date,
                  x_total_units,
                  x_action_text,
                  x_reason,
                  x_result,
                  x_sub_sourcesystem
               )VALUES(
                  -- 04/10/03 (seq_x_call_trans.NEXTVAL + POWER (2, 28)),
                  sa.seq('x_call_trans'),
                  site_part_rec.objid,
                  '82',
                  carrier_rec.part_inst2carrier_mkt,
                  site_part_rec.SITE_PART2SITE,
                  user_rec.objid,
                  '13',
                  site_part_rec.x_min,
                  site_part_rec.x_service_id,
                  'AUTOPAY_BATCH',
                  SYSDATE,
                  0,
                  'STAYACT SUBSCRIBE',  --'Enrollment',--CR 1157
                  DECODE(check_pending_rec.X_PROGRAM_TYPE, 2, '(2)Autopay', 3,
                  '(3)Double Min', 4, '(4)DPP'),  --'STAYACT SUBSCRIBE',--CR 1157
                  'Completed',
                  '202'
               );
            END IF;
            IF check_pending_rec.X_SOURCE_FLAG = 'B'
            THEN
--and check_detail_status_curs%notfound then -- fixed by --Suganthi03132003
               DBMS_OUTPUT.put_line('B');
               inbound_biller_pkg.MAIN_PRC (check_pending_rec.X_CYCLE_NUMBER,
               TO_CHAR(check_pending_rec.X_CREATION_DATE, 'yyyymmdd'),
               check_pending_rec.X_ESN, TO_CHAR(check_pending_rec.X_ENROLL_DATE
               , 'yyyymmdd'), --'mmddyyyy'),fixed by suganthi
               check_pending_rec.X_PROGRAM_TYPE, 3, --check_pending_rec.X_ACCOUNT_STATUS, fixed by SUganthi
               'E', check_pending_rec.X_FIRST_NAME, check_pending_rec.X_LAST_NAME
               , check_pending_rec.X_ADDRESS1, check_pending_rec.X_CITY,
               check_pending_rec.X_STATE, check_pending_rec.X_ZIPCODE,
               check_pending_rec.X_CONTACT_PHONE, v_MSG, v_P_STATUS );
            END IF;
            IF check_pending_rec.x_status = 'A'
            AND check_pending_rec.X_SOURCE_FLAG IN ('B', 'E')
            THEN
               DBMS_OUTPUT.put_line('A');
               inbound_elocknote_pkg.MAIN_PRC (check_pending_rec.X_CYCLE_NUMBER
               , 'PAY', TO_CHAR(check_pending_rec.X_CREATION_DATE, 'yyyymmdd'),
               check_pending_rec.X_TRANSACTION_AMOUNT, check_pending_rec.X_ESN,
               check_pending_rec.X_FIRST_NAME, check_pending_rec.X_LAST_NAME,
               check_pending_rec.X_ACCOUNT_STATUS, check_pending_rec.X_PROGRAM_TYPE
               , check_pending_rec.X_UNIQUERECORD, check_pending_rec.X_STATUS,
               check_pending_rec.X_ENROLL_FEE_FLAG, check_pending_rec.X_PROMOCODE
               , v_MSG, v_P_STATUS );
            END IF;
            l_action := 'Move to Hist'; --CR3160
            DBMS_OUTPUT.put_line('move to hist');
         END IF;
         IF ( site_part_curs%found
         AND check_pending_rec.X_SOURCE_FLAG = 'R'
         AND check_pending_rec.x_status = 'A'
         AND check_pending_rec.X_RECEIVE_STATUS = 'R')
         THEN
            realtime_autopay_pkg.hold(check_pending_rec.x_esn,
            check_pending_rec.x_promocode, check_pending_rec.X_ENROLL_AMOUNT,
            check_pending_rec.x_program_type, check_pending_rec.X_PAYMENT_TYPE,
            check_pending_rec.X_SOURCE, check_pending_rec.X_LANGUAGE_FLAG,
            v_msg, v_p_status);
         END IF;
         IF ( site_part_curs%found
         AND check_pending_rec.X_SOURCE_FLAG = 'R'
         AND check_pending_rec.x_status = 'A'
         AND check_pending_rec.X_RECEIVE_STATUS = 'Y'
         AND check_pending_rec.x_enroll_fee_flag
         IS
         NULL)
         THEN
            realtime_autopay_pkg.hold(check_pending_rec.x_esn,
            check_pending_rec.x_promocode, check_pending_rec.X_ENROLL_AMOUNT,
            check_pending_rec.x_program_type, check_pending_rec.X_PAYMENT_TYPE,
            check_pending_rec.X_SOURCE, check_pending_rec.X_LANGUAGE_FLAG,
            v_msg, v_p_status);
            inbound_biller_pkg.MAIN_PRC (check_pending_rec.X_CYCLE_NUMBER,
            TO_CHAR(check_pending_rec.X_CREATION_DATE, 'yyyymmdd'),
            check_pending_rec.X_ESN, TO_CHAR(check_pending_rec.X_ENROLL_DATE,
            'yyyymmdd'), --'mmddyyyy'),fixed by suganthi
            check_pending_rec.X_PROGRAM_TYPE, 3, -- check_pending_rec.X_ACCOUNT_STATUS, fixed by Suganthi.
            'E', -- 'A' ,fixed by Suganthi.
            check_pending_rec.X_FIRST_NAME, check_pending_rec.X_LAST_NAME,
            check_pending_rec.X_ADDRESS1, check_pending_rec.X_CITY,
            check_pending_rec.X_STATE, check_pending_rec.X_ZIPCODE,
            check_pending_rec.X_CONTACT_PHONE, v_MSG, v_P_STATUS );
         END IF;
         IF ( site_part_curs%found
         AND check_pending_rec.X_SOURCE_FLAG = 'R'
         AND check_pending_rec.x_status = 'A'
         AND check_pending_rec.X_RECEIVE_STATUS = 'Y'
         AND check_pending_rec.x_enroll_fee_flag
         IS
         NOT NULL)
         THEN
		 DBMS_OUTPUT.put_line('entered realtime1');
            l_action := 'Entered Realtime'; --CR3160
            realtime_autopay_pkg.hold(check_pending_rec.x_esn,
            check_pending_rec.x_promocode, check_pending_rec.X_ENROLL_AMOUNT,
            check_pending_rec.x_program_type, check_pending_rec.X_PAYMENT_TYPE,
            check_pending_rec.X_SOURCE, check_pending_rec.X_LANGUAGE_FLAG,
            v_msg, v_p_status);
            inbound_biller_pkg.MAIN_PRC (check_pending_rec.X_CYCLE_NUMBER,
            TO_CHAR(check_pending_rec.X_CREATION_DATE, 'yyyymmdd'),
            check_pending_rec.X_ESN, TO_CHAR(check_pending_rec.X_ENROLL_DATE,
            'yyyymmdd'), --'mmddyyyy'),fixed by suganthi
            check_pending_rec.X_PROGRAM_TYPE, 3, --check_pending_rec.X_ACCOUNT_STATUS fixed by SUganthi
            'E', -- 'A' ,fixed by Suganthi.
            check_pending_rec.X_FIRST_NAME, check_pending_rec.X_LAST_NAME,
            check_pending_rec.X_ADDRESS1, check_pending_rec.X_CITY,
            check_pending_rec.X_STATE, check_pending_rec.X_ZIPCODE,
            check_pending_rec.X_CONTACT_PHONE, v_MSG, v_P_STATUS);
            inbound_elocknote_pkg.MAIN_PRC (check_pending_rec.X_CYCLE_NUMBER,
            'PAY', --check_pending_rec.X_TRANSACTION_TYPE, --fixed by Suganthi
            TO_CHAR(check_pending_rec.X_CREATION_DATE, 'yyyymmdd'),
            check_pending_rec.X_TRANSACTION_AMOUNT, check_pending_rec.X_ESN,
            check_pending_rec.X_FIRST_NAME, check_pending_rec.X_LAST_NAME,
            check_pending_rec.X_ACCOUNT_STATUS, check_pending_rec.X_PROGRAM_TYPE
            , check_pending_rec.X_UNIQUERECORD, check_pending_rec.X_STATUS,
            check_pending_rec.X_ENROLL_FEE_FLAG, check_pending_rec.X_PROMOCODE,
            v_MSG, v_P_STATUS);
         END IF;
         CLOSE site_part_curs;
         CLOSE check_detail_status_curs;
         l_action := 'Insert into x_autopay_pending_hist'; --CR3160
         INSERT
         INTO sa.x_autopay_pending_hist(
            OBJID,
            X_CREATION_DATE,
            X_ESN,
            X_PROGRAM_TYPE,
            X_ACCOUNT_STATUS,
            X_STATUS,
            X_START_DATE,
            X_END_DATE,
            X_CYCLE_NUMBER,
            X_PROGRAM_NAME,
            X_ENROLL_DATE,
            X_FIRST_NAME,
            X_LAST_NAME,
            X_RECEIVE_STATUS,
            X_AGENT_ID,
            X_AUTOPAY_DETAILS2SITE_PART,
            X_AUTOPAY_DETAILS2X_PART_INST,
            X_AUTOPAY_DETAILS2CONTACT,
            X_TRANSACTION_TYPE,
            X_SOURCE_FLAG,
            X_ADDRESS1,
            X_CITY,
            X_STATE,
            X_ZIPCODE,
            X_CONTACT_PHONE,
            X_TRANSACTION_AMOUNT,
            X_PROMOCODE,
            X_ENROLL_FEE_FLAG,
            X_INSERT_DATE,
            X_UNIQUERECORD,
            X_ENROLL_AMOUNT,
            X_SOURCE,
            X_LANGUAGE_FLAG,
            X_PAYMENT_TYPE
         )VALUES(
            check_pending_rec.OBJID,
            check_pending_rec.X_CREATION_DATE,
            check_pending_rec.X_ESN,
            check_pending_rec.X_PROGRAM_TYPE,
            check_pending_rec.X_ACCOUNT_STATUS,
            check_pending_rec.X_STATUS,
            check_pending_rec.X_START_DATE,
            check_pending_rec.X_END_DATE,
            check_pending_rec.X_CYCLE_NUMBER,
            check_pending_rec.X_PROGRAM_NAME,
            check_pending_rec.X_ENROLL_DATE,
            check_pending_rec.X_FIRST_NAME,
            check_pending_rec.X_LAST_NAME,
            check_pending_rec.X_RECEIVE_STATUS,
            check_pending_rec.X_AGENT_ID,
            check_pending_rec.X_AUTOPAY_DETAILS2SITE_PART,
            check_pending_rec.X_AUTOPAY_DETAILS2X_PART_INST,
            check_pending_rec.X_AUTOPAY_DETAILS2CONTACT,
            check_pending_rec.X_TRANSACTION_TYPE,
            check_pending_rec.X_SOURCE_FLAG,
            check_pending_rec.X_ADDRESS1,
            check_pending_rec.X_CITY,
            check_pending_rec.X_STATE,
            check_pending_rec.X_ZIPCODE,
            check_pending_rec.X_CONTACT_PHONE,
            check_pending_rec.X_TRANSACTION_AMOUNT,
            check_pending_rec.X_PROMOCODE,
            check_pending_rec.X_ENROLL_FEE_FLAG,
            SYSDATE,
            check_pending_rec.X_UNIQUERECORD,
            check_pending_rec.X_ENROLL_AMOUNT,
            check_pending_rec.X_SOURCE,
            check_pending_rec.X_LANGUAGE_FLAG,
            check_pending_rec.X_PAYMENT_TYPE
         );
         l_action := 'Delete from pending'; --CR3160
         DBMS_OUTPUT.put_line('delete from pending');
         DELETE
         FROM sa.x_autopay_pending
         WHERE objid = check_pending_rec.objid;
         DBMS_OUTPUT.put_line('deleted from pending');
         --CR3160 Changes
         EXCEPTION
         WHEN OTHERS
         THEN
            toss_util_pkg.insert_error_tab_proc ('Inner Loop : '|| l_action,
            l_serial_num, l_procedure_name );
            COMMIT;
--End CR3160 Changes
      END;
   END LOOP;
   --CR3160 Changes
   EXCEPTION
   WHEN OTHERS
   THEN
      toss_util_pkg.insert_error_tab_proc ( l_action, l_serial_num,
      l_procedure_name );
      COMMIT;
--End CR3160 Changes
END;
/