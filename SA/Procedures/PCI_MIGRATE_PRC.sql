CREATE OR REPLACE PROCEDURE sa."PCI_MIGRATE_PRC" (
   jobid NUMBER
)
IS
   l_err_text VARCHAR2 (4000);
   --jobid NUMBER := - 1;
   CURSOR c0(
      c_jobid IN NUMBER
   )
   IS
   SELECT t.*
   FROM sa.TABLE_X_CREDIT_CARD cc, sa.temp_pci_migrate t
   WHERE 1 = 1
   AND cc.objid = t.credit_card_objid
   AND t.job_id = c_jobid
   AND t.new_x_customer_cc_number
   IS
   NOT NULL;
   CURSOR c1(
      c_jobid IN NUMBER
   )
   IS
   SELECT /*+ PARALLEL(t,12) */
      ph.objid ph_objid,
      t.*
   FROM sa.TABLE_X_PURCH_HDR ph, sa.temp_pci_migrate t
   WHERE 1 = 1
   AND ph.X_PURCH_HDR2CREDITCARD = t.credit_card_objid
   AND t.job_id = c_jobid
   AND t.new_x_customer_cc_number
   IS
   NOT NULL;
   CURSOR job_curs
   IS
   SELECT last_number - 1 jobid
   FROM all_sequences
   WHERE sequence_name = 'SEQU_PCI_MIGRATE';
   job_rec job_curs%ROWTYPE;
   cnt1 NUMBER := 0;
   cnt2 NUMBER := 0;
BEGIN

   --OPEN job_curs;
   --FETCH job_curs
   --INTO job_rec;
   --CLOSE job_curs;
   DBMS_OUTPUT.put_line('PL/SQL STARTING JOB '||jobid||'... ');
   --FOR c0_rec IN c0(job_rec.jobid)
   FOR c0_rec IN c0(jobid)
   LOOP
      BEGIN
         UPDATE sa.TABLE_X_CREDIT_CARD SET x_customer_cc_number = c0_rec.NEW_X_CUSTOMER_CC_NUMBER
         , x_cust_cc_num_key = c0_rec.new_x_cust_cc_num_key, x_cust_cc_num_enc
         = c0_rec.new_x_cust_cc_num_enc, creditcard2cert = c0_rec.new_creditcard2cert
         WHERE objid = c0_rec.credit_card_objid;
         EXCEPTION
         WHEN OTHERS
         THEN
            l_err_text := SQLERRM;
            INSERT
            INTO sa.error_table             values(
               l_err_text,
               SYSDATE,
               'update table_x_credit_card job:'||TO_CHAR(jobid),
               TO_CHAR(c0_rec.credit_card_objid),
               'ENCRYPTION PROGRAM'
            );
      END;

      --
      BEGIN
         UPDATE sa.X_CC_CHARGEBACK_TRANS SET x_cc_number = c0_rec.NEW_X_CUSTOMER_CC_NUMBER
         WHERE x_cc_number = c0_rec.old_x_customer_cc_number;
         EXCEPTION
         WHEN OTHERS
         THEN
            l_err_text := SQLERRM;
            INSERT
            INTO sa.error_table             values(
               l_err_text,
               SYSDATE,
               'update x_cc_chargeback_trans:'||TO_CHAR(jobid),
               TO_CHAR(c0_rec.credit_card_objid),
               'ENCRYPTION PROGRAM'
            );
      END;
      UPDATE sa.temp_pci_migrate t SET x_process_date = SYSDATE
      WHERE CREDIT_CARD_OBJID = c0_rec.CREDIT_CARD_OBJID
      AND job_id = c0_rec.job_id;
      cnt1 := cnt1 + 1;
      COMMIT;
   END LOOP;
   --FOR c1_rec IN c1(job_rec.jobid)
   FOR c1_rec IN c1(jobid)
   LOOP
      BEGIN
         UPDATE sa.X_CC_PROG_TRANS SET x_customer_cc_number = c1_rec.NEW_X_CUSTOMER_CC_NUMBER
         WHERE X_CC_TRANS2X_PURCH_HDR = c1_rec.ph_objid;
         EXCEPTION
         WHEN OTHERS
         THEN
            l_err_text := SQLERRM;
            INSERT
            INTO sa.error_table             values(
               l_err_text,
               SYSDATE,
               'update X_CC_PROG_TRANS :'||TO_CHAR(jobid),
               TO_CHAR(c1_rec.ph_objid),
               'ENCRYPTION PROGRAM'
            );
      END;
      BEGIN
         UPDATE sa.TABLE_X_PURCH_HDR SET x_customer_cc_number = c1_rec.NEW_X_CUSTOMER_CC_NUMBER
         WHERE objid = c1_rec.ph_objid;
         EXCEPTION
         WHEN OTHERS
         THEN
            l_err_text := SQLERRM;
            INSERT
            INTO sa.error_table             values(
               l_err_text,
               SYSDATE,
               'update TABLE_X_PURCH_HDR:'||TO_CHAR(jobid),
               TO_CHAR(c1_rec.ph_objid),
               'ENCRYPTION PROGRAM'
            );
      END;
      UPDATE sa.temp_pci_migrate t SET x_process_date = SYSDATE
      WHERE CREDIT_CARD_OBJID = c1_rec.CREDIT_CARD_OBJID
      AND job_id = c1_rec.job_id;
      --
      cnt2 := cnt2 + 1;
      COMMIT;
   END LOOP;
   DBMS_OUTPUT.put_line('PL/SQL DONE!');
   DBMS_OUTPUT.put_line('cnt1:'||cnt1);
   DBMS_OUTPUT.put_line('cnt2:'||cnt2);
   COMMIT;
END;
/