CREATE OR REPLACE PROCEDURE sa.SP_RPK_PAYMENTECH_INBOUND
IS
/******************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         SP_RPK_PAYMENTTECH_INBOUND                                   */
/* PURPOSE:      Update order records                                         */
/*               Records received from paymentech are check returned/rejected */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/*                                                                            */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO          PURPOSE                                  */
/* -------  ---------- -----  ---------------------------------------------   */
/*  1.0     09/16/02   SL     Initial  Revision                               */
/*  1.1     10/14/02   SL     Return OS with error if unexpected occurred     */
/*  1.2     10/25/02   SL     Add logic to handle refund                      */
/*                                                                            */
/******************************************************************************/
  l_program_name varchar2(30) := 'SP_RPK_PAYMENTTECH_INBOUND';

  CURSOR c_pt_in IS
    SELECT pt.*, pt.rowid FROM x_republik_paymentech pt
    WHERE NVL(processed,'N') = 'N';

  l_order_rec x_republik_order_hdr%rowtype;
  l_action varchar2(100);
  l_error_reason VARCHAR2(1500);
  l_payment_process_flag VARCHAR2(30);
  l_upd_order_hdr BOOLEAN;
  l_order_rowid ROWID;
  l_today date := sysdate;
  l_tot_upd NUMBER := 0;
  l_tot_err NUMBER := 0;

BEGIN
  FOR c_pt_in_rec IN c_pt_in LOOP
   l_upd_order_hdr := FALSE;
   l_payment_process_flag := NULL;
   BEGIN
    l_action := 'Retrieve Republik order hdr';
    SELECT * INTO l_order_rec
    FROM x_republik_order_hdr
    WHERE merch_order_number = c_pt_in_rec.merch_order_number;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_error_reason := 'Merchin ID '||c_pt_in_rec.merch_order_number||
                          ' not exists in republik order system.';
        insert_error_tab_proc ( ip_action=>l_action,
                                ip_key=> c_pt_in_rec.merch_order_number,
                                ip_program_name=>l_program_name,
                                ip_error_text=>l_error_reason);
        l_payment_process_flag := 'E';
        l_action := NULL;
        l_error_reason := NULL;
        GOTO next_rec;
     WHEN TOO_MANY_ROWS THEN
        l_error_reason := 'Too many records exist in republik order system for the same Merchin ID '||
                          c_pt_in_rec.merch_order_number;
        insert_error_tab_proc ( ip_action=>l_action,
                                ip_key=> c_pt_in_rec.merch_order_number,
                                ip_program_name=>l_program_name,
                                ip_error_text=>l_error_reason);
        COMMIT;
        l_payment_process_flag := 'E';
        l_action := NULL;
        l_error_reason := NULL;
        GOTO next_rec;
   END;

   --10/25/02
   -- Add logic to hand refund
   IF ( l_order_rec.last_order_status in  ('COMPLETED','SENT_TO_FF','DENIED')
        OR l_order_rec.last_order_status LIKE 'REFUND%' ) THEN
       l_action := 'Validate last order status.';

       IF l_order_rec.last_order_status = 'COMPLETED' THEN
        l_error_reason := 'The order is completed. Inbound Paymentech record ignored.';
       ELSIF l_order_rec.last_order_status = 'SENT_TO_FF' THEN
        l_error_reason := 'The order is sent to fullfillment center. Inbound Paymentech record ignored.';
       ELSIF l_order_rec.last_order_status = 'DENIED' THEN
        l_error_reason := 'The order has already been denied. Inbound Paymentech record ignored.';
       ELSE
        --10/25/02
        l_error_reason := 'The order has already been refunded. Inbound Paymentech record ignored.';
       END IF;

       insert_error_tab_proc ( ip_action=>l_action,
                               ip_key=> l_order_rec.toss_order_id,
                               ip_program_name=>l_program_name,
                               ip_error_text=>l_error_reason);
       COMMIT;
       l_payment_process_flag := 'E';
       l_action := NULL;
       l_error_reason := NULL;
       GOTO next_rec;
   END IF;

   IF NVL(l_order_rec.payment_method,'N/A') <> 'CHECK' THEN
     l_action := 'Validate payment method.';
     l_error_reason := 'Payment method does not match. Existing payment method is '||
                       NVL(l_order_rec.payment_method,'N/A')||' while CHECK payment is expected.';
     insert_error_tab_proc ( ip_action=>l_action,
                             ip_key=> c_pt_in_rec.merch_order_number,
                             ip_program_name=>l_program_name,
                             ip_error_text=>l_error_reason);
     COMMIT;
     l_payment_process_flag := 'E';
     l_action := NULL;
     l_error_reason := NULL;
     GOTO next_rec;
   END IF;

   l_payment_process_flag := 'Y';
   l_upd_order_hdr := TRUE;

   <<next_rec>>
   SAVEPOINT UPD_ORDER ;
   BEGIN
    IF l_upd_order_hdr THEN
      l_action := 'Update Republik order hdr with payment info from PAYMENTTECH.';
      UPDATE x_republik_order_hdr
      SET   last_updated_by = l_program_name
           ,last_order_status = 'DENIED'
           ,last_updated_date = l_today
           ,approval_status = c_pt_in_rec.approval_status
      WHERE toss_order_id = l_order_rec.toss_order_id;
    END IF;

    l_action := 'Update paymentech flag after order header is updated.';
    UPDATE x_republik_paymentech
    SET   PROCESSED = l_payment_process_flag
          ,PROCESSED_DATE = sysdate
    WHERE rowid = c_pt_in_rec.rowid;

    IF l_payment_process_flag = 'Y' THEN
     l_tot_upd := l_tot_upd + 1;
    ELSE
     l_tot_err := l_tot_err + 1;
    END IF;

   EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT UPD_ORDER;
        l_error_reason := 'Failed to update record. '||sqlerrm;
        insert_error_tab_proc ( ip_action=>l_action,
                                ip_key=> c_pt_in_rec.merch_order_number,
                                ip_program_name=>l_program_name,
                                ip_error_text=>l_error_reason);
        COMMIT;
        l_action := NULL;
        l_error_reason := NULL;
   END;

   IF mod(l_tot_upd+l_tot_err,500) = 0 THEN
     COMMIT;
   END IF;
  END LOOP;

  COMMIT;

  dbms_output.put_line('Inbound PaymenTech batch processed. ');
  dbms_output.put_line('Total records processed without error: '||l_tot_upd);
  dbms_output.put_line('Total records processed with error: '||l_tot_err);

EXCEPTION
  WHEN others THEN
      ROLLBACK;
      l_action := 'ANY';
      l_error_reason := 'Unexpected Error: '||substr(sqlerrm,1,1000);
      insert_error_tab_proc ( ip_action=>l_action,
                              ip_key=> l_program_name,
                              ip_program_name=>l_program_name,
                              ip_error_text=>l_error_reason);
      COMMIT;
      /* 10/14/02 return to OS with error */
      dbms_output.put_line('Error occurred when executing '||l_program_name||'. >> '||
                           substr(l_error_reason,1,100));
      raise_application_error(-20001,l_error_reason);
END;
/