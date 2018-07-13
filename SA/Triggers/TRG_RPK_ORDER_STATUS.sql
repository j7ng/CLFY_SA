CREATE OR REPLACE TRIGGER sa.TRG_RPK_ORDER_STATUS
AFTER INSERT OR UPDATE OF LAST_ORDER_STATUS
ON sa.X_REPUBLIK_ORDER_HDR REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
/******************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         TRG_RPK_ORDER_STATUS                                         */
/* PURPOSE:      Keep track changes to order status                           */
/*                                                                            */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/*                                                                            */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO          PURPOSE                                  */
/* -------  ---------- -----  ---------------------------------------------   */
/*  1.0     10/25/02   SL     Initial  Revision                               */
/******************************************************************************/

  l_cancel_request_id NUMBER := NULL;
  CURSOR c_check_cancel ( c_check_acct_num VARCHAR2) IS
    SELECT * FROM x_republik_cancel_request
    WHERE check_acct_number = c_check_acct_num
    AND status = 'IN-PROCESS'
    ;
  l_check_cancel_rec c_check_cancel%ROWTYPE;

  CURSOR c_credit_cancel ( c_cc_number VARCHAR2) IS
    SELECT * FROM x_republik_cancel_request
    WHERE substr(cc_number,3) = substr(c_cc_number,3)
    AND status = 'IN-PROCESS'
    ;
  l_credit_cancel_rec c_credit_cancel%ROWTYPE;

BEGIN

  IF :new.last_order_status LIKE 'REFUND%' THEN
    IF :new.payment_method = 'CHECK' THEN
      OPEN c_check_cancel ( :new.check_acct_number );
      FETCH c_check_cancel INTO l_check_cancel_rec;
      IF c_check_cancel%NOTFOUND THEN
         CLOSE c_check_cancel;
      ELSE
         l_cancel_request_id := l_check_cancel_rec.request_id;
         CLOSE c_check_cancel;
      END IF;
    ELSIF :new.payment_method = 'CREDIT' THEN
      OPEN c_credit_cancel ( :new.cc_number );
      FETCH c_credit_cancel INTO l_credit_cancel_rec;
      IF c_credit_cancel%NOTFOUND THEN
         CLOSE c_credit_cancel;
      ELSE
         l_cancel_request_id := l_credit_cancel_rec.request_id;
         CLOSE c_credit_cancel;
      END IF;
    ELSE
       l_cancel_request_id := NULL;
    END IF;
  END IF;

  INSERT INTO x_republik_order_status_hist (
    TOSS_ORDER_ID  ,
    CANCEL_REQUEST_ID ,
    STATUS         ,
    CREATED_DATE  ) VALUES (
    :new.toss_order_id,
    l_cancel_request_id,
    :new.last_order_status,
    SYSDATE
    );

END;
/