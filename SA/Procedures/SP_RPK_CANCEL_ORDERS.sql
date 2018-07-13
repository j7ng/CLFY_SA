CREATE OR REPLACE PROCEDURE sa.SP_RPK_CANCEL_ORDERS ( p_check_release_date DATE)
IS
/******************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         SP_RPK_CANCEL_ORDERS                                         */
/* PURPOSE:      Cancel republik orders                                       */
/*                                                                            */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/*                                                                            */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO          PURPOSE                                  */
/* -------  ---------- -----  ---------------------------------------------   */
/*  1.0     10/25/02   SL     Initial  Revision                               */
/******************************************************************************/

  l_program_name VARCHAR2(30) := 'SP_RPK_CANCEL_ORDERS';
  l_check_release_date DATE := NVL(p_check_release_date,trunc(sysdate)+1);
  l_action VARCHAR2(100);
  l_error_reason VARCHAR2(1500);

  CURSOR c_cancel IS
    SELECT r.rowid, r.* FROM x_republik_cancel_request r
    WHERE STATUS = 'NEW'
    ; -- 11/22/02 delete "update nowait"

  CURSOR c_ord ( c_acct_num VARCHAR2, c_payment_method VARCHAR2) IS
    SELECT * FROM x_republik_order_hdr
    WHERE last_order_status = 'NEW'
    AND payment_method = c_payment_method
    AND ( ( check_acct_number = c_acct_num
            AND payment_method = 'CHECK'
            AND call_date < l_check_release_date)
         OR ( substr(cc_number,3)  = substr(c_acct_num,3)
              AND payment_method = 'CREDIT' )
         )
    ;

  l_cancel_status VARCHAR2(10);
  l_cancel_msg VARCHAR2(1000);
  l_tot_cancel_rqst NUMBER := 0;
  l_cancel_order_per_rqst NUMBER := 0;
  l_acct_number VARCHAR2(60);
  l_tot_cancel_order NUMBER := 0;
  l_err_cnt NUMBER := 0;

BEGIN
 --
 -- Process cancel request
 -- 10/25/02
 --
 FOR c_cancel_rec IN c_cancel LOOP

   l_cancel_order_per_rqst := 0;
   l_err_cnt := 0;

   IF c_cancel_rec.payment_method = 'CHECK' THEN
     l_acct_number := c_cancel_rec.check_acct_number;
   ELSE
     l_acct_number := c_cancel_rec.cc_number;
   END IF;

   SAVEPOINT cancel_request;
   UPDATE x_republik_cancel_request
   SET status = 'IN-PROCESS'
   WHERE rowid = c_cancel_rec.rowid;

   FOR c_ord_rec IN c_ord ( l_acct_number, c_cancel_rec.payment_method  ) LOOP

     IF c_ord_rec.payment_method = 'CHECK' AND c_ord_rec.call_date > l_check_release_date THEN
       -- we hold check for several days before issuing refund.
       -- release date will be calculated in sp_rpk_ff_outbound
       GOTO next_order;
     END IF;

     SP_RPK_ORDER_REFUND (c_ord_rec.toss_order_id, l_cancel_status, l_cancel_msg);

     l_action := 'Cancel order.';
     l_error_reason := l_cancel_msg;

     IF l_cancel_status <> 'S' THEN
       ROLLBACK TO SAVEPOINT cancel_request;
       insert_error_tab_proc ( ip_action=>l_action,
                               ip_key=> c_ord_rec.toss_order_id,
                               ip_program_name=>l_program_name,
                               ip_error_text=>l_error_reason);
       COMMIT;
       l_err_cnt := l_err_cnt + 1;
       l_cancel_order_per_rqst := 0;

       EXIT;
      END IF;

      l_cancel_order_per_rqst := l_cancel_order_per_rqst + 1;

      <<next_order>>
      NULL;
   END LOOP;

   IF l_cancel_order_per_rqst < 1 THEN
     ROLLBACK TO SAVEPOINT cancel_request;

     IF c_cancel_rec.created_date < trunc(sysdate) - 7 THEN

       SP_RPK_REMOVE_CANCEL_REQUEST(c_cancel_rec.request_id,'INVALID',l_cancel_status, l_cancel_msg);

       l_action := 'Process request of cancellation.';

       IF l_cancel_status <> 'S' THEN
        l_error_reason := 'No order found for request ID '||c_cancel_rec.request_id||
                          '. Error occurred when removing request--'||l_cancel_msg;
       ELSE
        l_error_reason := 'No order found for request ID '||c_cancel_rec.request_id;
       END IF;

       insert_error_tab_proc ( ip_action=>l_action,
                               ip_key=> c_cancel_rec.request_id,
                               ip_program_name=>l_program_name,
                               ip_error_text=>l_error_reason);
       COMMIT;

     END IF;

   ELSE

     IF l_err_cnt = 0  THEN
       l_cancel_status := NULL;
       l_cancel_msg := NULL;

       SP_RPK_REMOVE_CANCEL_REQUEST(c_cancel_rec.request_id,'COMPLETED',l_cancel_status, l_cancel_msg);

       IF l_cancel_status <> 'S' THEN

         ROLLBACK TO SAVEPOINT cancel_request;
         l_action := 'Process request of cancellation.';
         l_error_reason := 'No order found for request '||c_cancel_rec.request_id;
         insert_error_tab_proc ( ip_action=>l_action,
                                 ip_key=> c_cancel_rec.request_id,
                                 ip_program_name=>l_program_name,
                                 ip_error_text=>l_error_reason);
         COMMIT;

       ELSE

         l_tot_cancel_rqst := l_tot_cancel_rqst + 1;

       END IF;

     END IF;

   END IF;

   l_tot_cancel_order := l_tot_cancel_order + l_cancel_order_per_rqst;

 END LOOP;

 COMMIT;

 dbms_output.put_line('Total orders cancelled: '||l_tot_cancel_order);
 dbms_output.put_line('Total requests processed: '||l_tot_cancel_rqst);

EXCEPTION
  WHEN others THEN
    ROLLBACK;
    l_action := 'ANY';
    l_error_reason := 'Unexpected error: '||substr(sqlerrm,1,1000);
    insert_error_tab_proc ( ip_action=>l_action,
                            ip_key=> l_program_name,
                            ip_program_name=>l_program_name,
                            ip_error_text=>l_error_reason);
    COMMIT;
    dbms_output.put_line('Error occurred when executing '||l_program_name||'. >> '||
                         substr(l_error_reason,1,100));
    raise_application_error(-20001,l_error_reason);
END;
/