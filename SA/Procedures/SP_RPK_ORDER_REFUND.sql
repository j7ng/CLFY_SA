CREATE OR REPLACE PROCEDURE sa.SP_RPK_ORDER_REFUND (p_order_id NUMBER,
                                                    p_status OUT VARCHAR2,
                                                    p_msg OUT VARCHAR2)
/******************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         SP_RPK_ORDER_REFUND                                          */
/* PURPOSE:      Process refund by order                                      */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/*                                                                            */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO          PURPOSE                                  */
/* -------  ---------- -----  ---------------------------------------------   */
/*  1.0     10/25/02   SL     Initial version                                 */
/*                                                                            */
/******************************************************************************/
IS
 l_program_name VARCHAR2(30) := 'SP_RPK_ORDER_REFUND';
 l_action VARCHAR2(100);

 CURSOR c_ord_hdr ( c_order_id NUMBER) IS
   SELECT * FROM x_republik_order_hdr
   WHERE toss_order_id = c_order_id;

 CURSOR c_ord_dtl ( c_order_id NUMBER) IS
   SELECT * FROM x_republik_order_dtl
   WHERE toss_order_id = c_order_id;

 l_ord_hdr_rec c_ord_hdr%ROWTYPE;
 l_acct_number varchar2(50);
 l_action_code  VARCHAR2(2);
 l_payment_method VARCHAR2(2);
 l_expireation_date VARCHAR2(4);
 l_amount           VARCHAR2(12);

BEGIN
 IF p_order_id IS NULL THEN
   p_status := 'F';
   p_msg := 'Order Id is required.';
   RETURN;
 END IF;

 OPEN c_ord_hdr ( p_order_id );
 FETCH c_ord_hdr INTO l_ord_hdr_rec;
 IF c_ord_hdr%NOTFOUND THEN
   P_STATUS := 'F';
   p_msg := 'Order ID: '||p_order_id||' does not exist in the system.';
   CLOSE c_ord_hdr;
   RETURN;
 ELSE
   CLOSE c_ord_hdr;
 END IF;

 IF l_ord_hdr_rec.last_order_status LIKE 'REFUND%' THEN
   p_status := 'F';
   p_msg := 'Unable to process refund because refund for order ID '||l_ord_hdr_rec.toss_order_id
           ||' has been processed.';
   RETURN;

 ELSIF l_ord_hdr_rec.last_order_status = 'DENIED' THEN
   p_status := 'F';
   p_msg := 'Unable to process refund because this order has alraady been denied by paymentech.';
   RETURN;
 END IF;

 IF l_ord_hdr_rec.payment_method = 'CHECK' THEN
   l_action_code := 'N';
   l_acct_number := l_ord_hdr_rec.check_acct_number;
   l_payment_method := 'EC';

 ELSIF l_ord_hdr_rec.payment_method = 'CREDIT' THEN
   l_action_code := 'R';
   l_acct_number := l_ord_hdr_rec.check_acct_number;
   SELECT DECODE(l_ord_hdr_rec.cc_type,'A','AX',   -- AmericanExpress
                                       'M','MC',   -- MasterCard
                                       'S','DI',   -- Discover
                                       'V','VI',   -- Visa
                                       NULL)       -- unknown
   INTO  l_payment_method
   FROM DUAL;

   IF l_payment_method IS NULL THEN
     p_status := 'F';
     p_msg := 'Invalid credit type: '||l_ord_hdr_rec.cc_type;
     RETURN;
   END IF;

   l_expireation_date := TO_CHAR(l_ord_hdr_rec.cc_exp_date,'MMYY');
 ELSE
   p_status := 'F';
   p_msg := 'Unknown payment method '||l_ord_hdr_rec.payment_method;
   RETURN;
 END IF;

 l_amount := to_char(l_ord_hdr_rec.AUTHED_TOTAL * 100);
 SAVEPOINT refund;
 l_action := 'Create the refund record.';
 BEGIN
   INSERT INTO x_republik_refund (
    TOSS_ORDER_ID         ,
    PT_MERCH_ORDER_NUMBER ,
    PT_ACTION_CODE        ,
    PT_PAYMENT_METHOD     ,
    PT_ACCOUNT_NUMBER     ,
    PT_EXPIRATION_DATE    ,
    PT_AMOUNT             ,
    CREATED_DATE          ,
    STATUS
    ) VALUES (
    l_ord_hdr_rec.toss_order_id,
    l_ord_hdr_rec.merch_order_number,
    l_action_code ,
    l_payment_method,
    l_acct_number,
    l_expireation_date,
    l_amount          ,
    sysdate           ,
    'NEW'
    );

    IF l_ord_hdr_rec.payment_method = 'CHECK' THEN
      l_action := 'Create extension of the refund record.';
      INSERT INTO x_republik_refund_ext (
      toss_order_id ) VALUES (
      l_ord_hdr_rec.toss_order_id
      );
    END IF;

    FOR c_ord_dtl_rec IN c_ord_dtl (l_ord_hdr_rec.toss_order_id) LOOP
      l_action := 'Delete promotion record from ESN '||c_ord_dtl_rec.part_serial_no;
      DELETE FROM table_x_group2esn
      WHERE groupesn2part_inst = ( SELECT objid
                                   FROM table_part_inst
                                   WHERE part_serial_no = c_ord_dtl_rec.part_serial_no
                                   )
      ;
    END LOOP;

    l_action := 'Update order header record for order id '||p_order_id;
    UPDATE x_republik_order_hdr
    SET last_order_status = 'REFUND_SENT',
        last_updated_date = SYSDATE
    WHERE toss_order_id =  p_order_id;

  EXCEPTION
   WHEN others THEN
     ROLLBACK TO SAVEPOINT refund;
     p_status :='F';
     p_msg := l_action||'. '||substr(sqlerrm,1,100);
     RETURN;
  END;

  p_status := 'S';
  p_msg := 'Refund for order '||l_ord_hdr_rec.toss_order_id||' is processed.';
EXCEPTION
  WHEN others THEN
   P_STATUS := 'F';
   p_msg := l_program_name||'. Unexpected error occurred: '||substr(sqlerrm,1,100);
END;
/