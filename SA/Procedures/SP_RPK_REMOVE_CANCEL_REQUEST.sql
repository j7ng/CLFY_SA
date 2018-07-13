CREATE OR REPLACE PROCEDURE sa.SP_RPK_REMOVE_CANCEL_REQUEST ( p_request_id NUMBER ,
                                                              p_request_status VARCHAR2 ,
                                                              p_status OUT VARCHAR2 ,
                                                              p_msg OUT VARCHAR2)
/******************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         SP_RPK_REMOVE_CANCEL_REQUEST                                 */
/* PURPOSE:      Remove cancel request from x_republik_cancel_request table   */
/*               once refund records created.                                 */
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
 l_program_name VARCHAR2(30) := 'SP_RPK_REMOVE_CANCEL_REQUEST';
 l_request_status VARCHAR2(20) := ltrim(rtrim(p_request_status));
 CURSOR c_cancel_rqst IS
   SELECT * FROM x_republik_cancel_request
   WHERE request_id = p_request_id;
 l_cancel_rqst_rec c_cancel_rqst%ROWTYPE;
BEGIN
  IF p_request_id IS NULL THEN
    p_status := 'F';
    p_msg := 'Request ID is required.';
    RETURN;
  END IF;

  IF l_request_status IS NULL THEN
    l_request_status := 'COMPLETED';
  END IF;

  OPEN c_cancel_rqst;
  FETCH c_cancel_rqst INTO l_cancel_rqst_rec;
  IF c_cancel_rqst%NOTFOUND THEN
    CLOSE c_cancel_rqst;
    p_status := 'F';
    p_msg := 'Request ID '||p_request_id||' does not exist in the system.';
    RETURN;
  ELSE
    CLOSE c_cancel_rqst;
  END IF;

  SAVEPOINT remove_request;
  BEGIN
    INSERT INTO x_republik_cancel_request_hist (
      REQUEST_ID             ,
      PAYMENT_METHOD         ,
      CC_NUMBER              ,
      CHECK_ACCT_NUMBER      ,
      CUSTOMER_PHONE         ,
      CUSTOMER_EMAIL         ,
      CUSTOMER_FIRSTNAME     ,
      CUSTOMER_LASTNAME      ,
      CREATED_BY             ,
      CREATED_DATE           ,
      STATUS                 ,
      LAST_UPDATED_DATE
    ) VALUES (
      l_cancel_rqst_rec.REQUEST_ID             ,
      l_cancel_rqst_rec.PAYMENT_METHOD         ,
      l_cancel_rqst_rec.CC_NUMBER              ,
      l_cancel_rqst_rec.CHECK_ACCT_NUMBER      ,
      l_cancel_rqst_rec.CUSTOMER_PHONE         ,
      l_cancel_rqst_rec.CUSTOMER_EMAIL         ,
      l_cancel_rqst_rec.CUSTOMER_FIRSTNAME     ,
      l_cancel_rqst_rec.CUSTOMER_LASTNAME      ,
      l_cancel_rqst_rec.CREATED_BY             ,
      l_cancel_rqst_rec.CREATED_DATE           ,
      l_request_status                         ,
      sysdate
    );

    DELETE FROM x_republik_cancel_request
    WHERE request_id = l_cancel_rqst_rec.REQUEST_ID;

  EXCEPTION
    WHEN others THEN
     ROLLBACK TO SAVEPOINT remove_request;
     p_status := 'F';
     p_msg := 'Unable to remove cancel request. '||substr(sqlerrm,1,100);
     RETURN;
  END;

  p_status := 'S';
  p_msg := NULL;

EXCEPTION
  WHEN others THEN
    ROLLBACK TO SAVEPOINT remove_request;
    p_status := 'F';
    p_msg := l_program_name||'. Unexpected error occurred: '||substr(sqlerrm,1,100);
END;
/