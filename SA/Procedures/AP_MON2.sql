CREATE OR REPLACE PROCEDURE sa.ap_mon2
AS
/*****************************************************************
   * Package Name: ap_mon2
   * Purpose     : This procedure deletes the records from the table
   *               `x_autopay_pending?, which are older than 90 days.
   * Author      : ???
   * Date        : 12/31/2002
   * History     :
   ---------------------------------------------------------------------
    12/31/2002          ???         Initial version
    ??????????          ???         ????????????????
    08/31/04            VA          CR3160 - Add exception block
   *********************************************************************/
   ----------------------------------------------------------------
   CURSOR max_send_ftp_auto_curs
   IS
   SELECT MAX(SEND_SEQ_NO) + 1 max_send_seq_no
   FROM X_SEND_FTP_AUTO;
   max_send_ftp_auto_rec max_send_ftp_auto_curs%ROWTYPE;
   ----------------------------------------------------------------
   CURSOR check_pending_curs
   IS
   SELECT *
   FROM x_autopay_pending
   WHERE x_end_date < SYSDATE - 90
   AND X_SOURCE_FLAG = 'D' UNION
   SELECT *
   FROM x_autopay_pending
   WHERE x_start_date < SYSDATE - 90
   AND X_SOURCE_FLAG != 'D';
   ----------------------------------------------------------------
   --CR3160 Changes
   l_action VARCHAR2(2000);
   l_serial_num VARCHAR2(20);
   l_procedure_name VARCHAR2(100) := 'SA.AP_MON2';
--End CR3160 Changes
BEGIN
   FOR check_pending_rec IN check_pending_curs
   LOOP
--CR3160 Changes
      BEGIN
         l_serial_num := check_pending_rec.x_esn;
         l_action := 'Insert into x_send_ftp_auto';
         --End CR3160 Changes
         OPEN max_send_ftp_auto_curs;
         FETCH max_send_ftp_auto_curs
         INTO max_send_ftp_auto_rec;
         CLOSE max_send_ftp_auto_curs;
         INSERT
         INTO X_SEND_FTP_AUTO(
            SEND_SEQ_NO,
            FILE_TYPE_IND,
            ESN,
            PROGRAM_TYPE,
            ACCOUNT_STATUS,
            AMOUNT_DUE
         )VALUES(
            max_send_ftp_auto_rec.max_send_seq_no,
            'D',
            check_pending_rec.X_ESN,
            check_pending_rec.X_PROGRAM_TYPE,
            'D',
            0
         );
         l_action := 'Update table_x_autopay_details'; --CR3160
         IF check_pending_rec.X_SOURCE_FLAG = 'E'
         THEN
            UPDATE table_x_autopay_details SET x_status = 'I', x_end_date =
            SYSDATE, X_ACCOUNT_STATUS = 9
            WHERE x_esn = check_pending_rec.x_esn
            AND x_end_date
            IS
            NULL;
         END IF;
         l_action := 'Insert into x_autopay_pending_hist'; --CR3160
         INSERT
         INTO x_autopay_pending_hist(
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
            X_UNIQUERECORD
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
            check_pending_rec.X_UNIQUERECORD
         );
         l_action := 'Delete from x_autopay_pending'; --CR3160
         DELETE
         FROM x_autopay_pending
         WHERE objid = check_pending_rec.objid;
         --CR3160 Changes
         EXCEPTION
         WHEN OTHERS
         THEN
            toss_util_pkg.insert_error_tab_proc ('Inner Loop : '|| l_action,
            l_serial_num, l_procedure_name );
            COMMIT;
      END;
--End CR3160 Changes
   END LOOP;
   --CR3160 Changes
   EXCEPTION
   WHEN OTHERS
   THEN
      toss_util_pkg.insert_error_tab_proc ( l_action, l_serial_num,
      l_procedure_name );
      COMMIT;
--End CR3160 Changes
END ap_mon2;
/