CREATE OR REPLACE PACKAGE BODY sa."TFSOA_BATCH_PROCESS_PKG" AS
PROCEDURE TF_CREATE_BATCH_RECORDS(
                                   p_bus_org   IN  VARCHAR2,
                                   in_priority IN  VARCHAR2 DEFAULT 20, ---CR25625
                                   op_result   OUT NUMBER,
                                   op_msg      OUT VARCHAR2
                                  )
AS

/*************************************************************************************************************************************
  * $Revision: 1.22 $
  * $Author: tbaney $
  * $Date: 2017/10/02 14:36:46 $
  * $Log: TFSOA_BATCH_PROCESS_PKG.sql,v $
  * Revision 1.22  2017/10/02 14:36:46  tbaney
  * Merged with production.
  *
  * Revision 1.21  2017/09/06 13:42:01  tbaney
  * CR50321_Update_RRP_DB2QUEUE_to_use_new_and_efficient_pojo_code
  *
  * Revision 1.19  2017/03/16 21:06:26  rpednekar
  * CR48488 - Added table_x_bank_account and x_payment_source table in main cursor c_info query.
  *
  * Revision 1.18  2017/03/07 21:57:19  rpednekar
  * CR48488 - Modified date condition for better performance.
  *
  * Revision 1.17  2016/11/02 22:15:19  mshah
  * CR46191
  *
  *************************************************************************************************************************************/

 L_Batch_Id  NUMBER;
 V_Total_Tax NUMBER;
 counter     NUMBER := 0; --Added for CR46191
 CURSOR c_info (p_batch_id IN NUMBER)
 IS
 SELECT
       pph.objid batch_objid, --CR46191 corrected
       pph.prog_hdr2prog_batch,
       pph.X_RQST_TYPE,
       pph.X_RQST_DATE,
       pph.X_ICS_APPLICATIONS,
       pph.X_MERCHANT_ID,
       pph.X_AUTH_REQUEST_ID,
       pph.X_MERCHANT_REF_NUMBER,
       pph.X_AMOUNT,
       pph.X_CUSTOMER_FIRSTNAME,
       pph.X_CUSTOMER_LASTNAME,
       pph.X_BILL_ADDRESS1,
       pph.X_BILL_CITY,
       pph.X_BILL_STATE,
       pph.X_BILL_ZIP,
       pph.X_BILL_COUNTRY,
       pph.X_CUSTOMER_EMAIL,
       pph.X_STATUS,
       (pph.X_AMOUNT + pph.X_TAX_AMOUNT + pph.X_E911_TAX_AMOUNT+pph.X_USF_TAXAMOUNT+pph.X_RCRF_TAX_AMOUNT) X_AMOUNT_PLUS_TAX, --CR11553
       pph.X_BILL_ADDRESS2,
       pph.X_IGNORE_AVS PPH_X_IGNORE_AVS,
       pph.X_AVS PPH_X_AVS,
       pph.X_DISABLE_AVS PPH_X_DISABLE_AVS,
       pph.X_CUSTOMER_HOSTNAME,
       pph.X_CUSTOMER_IPADDRESS,
       pph.X_TAX_AMOUNT,
       pph.X_E911_TAX_AMOUNT,
       pph.X_USF_TAXAMOUNT ,
       pph.X_RCRF_TAX_AMOUNT , --CR11553
       pph.X_AUTH_REQUEST_ID X_AUTH_REQUEST_ID_2,
       pph.X_CUSTOMER_PHONE,
       achpt.X_ECP_ACCOUNT_NO,
       NVL(achpt.X_ECP_ACCOUNT_TYPE, NVL(cc.X_CC_TYPE,'CREDITCARD')) X_ECP_ACCOUNT_TYPE,
       achpt.X_ECP_RDFI,
       achpt.X_BANK_NUM,
       achpt.X_ECP_SETTLEMENT_METHOD,
       achpt.X_DECLINE_AVS_FLAGS,
       achpt.X_ECP_PAYMENT_MODE,
       achpt.X_ECP_VERFICATION_LEVEL,
       achpt.X_ECP_DEBIT_REF_NUMBER,
       ccpt.X_CUSTOMER_CC_NUMBER,
       ccpt.X_CUSTOMER_CC_EXPMO,
       ccpt.X_CUSTOMER_CC_EXPYR,
       ccpt.X_CUSTOMER_CVV_NUM,
       ccpt.X_IGNORE_BAD_CV,
       ccpt.X_IGNORE_AVS CCPT_X_IGNORE_AVS,
       ccpt.X_AVS CCPT_X_AVS,
       ccpt.X_DISABLE_AVS CCPT_X_DISABLE_AVS,
       -- Modified for CR48488
       DECODE(pph.x_rqst_type,'CREDITCARD_PURCH',cc.CREDITCARD2CERT		,'ACH_PURCH',ba.BANK2CERT) CREDITCARD2CERT,
       DECODE(pph.x_rqst_type,'CREDITCARD_PURCH',cc.X_CUSTOMER_CC_NUMBER	,'ACH_PURCH',ba.X_CUSTOMER_ACCT) AS CC_HASH,
       DECODE(pph.x_rqst_type,'CREDITCARD_PURCH',cc.X_CUST_CC_NUM_KEY		,'ACH_PURCH',ba.X_CUSTOMER_ACCT_KEY) X_CUST_CC_NUM_KEY ,
       DECODE(pph.x_rqst_type,'CREDITCARD_PURCH',ct.X_CERT			,'ACH_PURCH',bact.X_CERT) X_CERT,
       DECODE(pph.x_rqst_type,'CREDITCARD_PURCH',ct.X_KEY_ALGO			,'ACH_PURCH',bact.X_KEY_ALGO) X_KEY_ALGO,
       DECODE(pph.x_rqst_type,'CREDITCARD_PURCH',ct.X_CC_ALGO			,'ACH_PURCH',bact.X_CC_ALGO) X_CC_ALGO,
       DECODE(pph.x_rqst_type,'CREDITCARD_PURCH',cc.X_CUST_CC_NUM_ENC		,'ACH_PURCH',ba.X_CUSTOMER_ACCT_ENC) X_CUST_CC_NUM_ENC,
       -- Modified for CR48488
       pph.X_PRIORITY
 FROM  x_program_purch_hdr pph,
       x_cc_prog_trans ccpt,
       x_ach_prog_trans achpt,
       table_x_credit_card cc,
       x_cert ct,
        -- CR48488
       x_cert bact,
       table_x_bank_account ba,
       x_payment_source ps
       -- CR48488
 WHERE 1 =1
 AND   ct.objid(+) = cc.CREDITCARD2CERT+0
 AND   cc.objid(+) = pph.PURCH_HDR2CREDITCARD
 AND   ( ccpt.X_CUSTOMER_CC_NUMBER IS NULL
 OR    ccpt.X_CUSTOMER_CC_NUMBER NOT LIKE '********%')
 AND   ccpt.x_cc_trans2x_purch_hdr(+) = pph.objid
 AND   pph.x_status = 'RECURINCOMPLETE'
 AND   achpt.ach_trans2x_purch_hdr(+) = pph.objid
 AND   pph.x_rqst_type = ANY ('ACH_PURCH', 'CREDITCARD_PURCH')
 --AND   TRUNC(pph.X_RQST_DATE) <= TRUNC(sysdate)	-- Commented and modified for CR48488
 AND   pph.X_RQST_DATE <= sysdate			-- Modified for CR48488
 AND   Pph.Prog_Hdr2prog_Batch = P_Batch_Id
 -- CR48488
 AND 	ba.objid(+) = ps.pymt_src2x_bank_account
 AND 	ps.objid(+) = pph.prog_hdr2x_pymt_src
 AND   bact.objid(+) = ba.BANK2CERT+0
 -- CR48488
 ;

BEGIN --{
 --create the Batch Id
 BEGIN --{
  SELECT sa.seq_X_BATCH_ID.nextval
  INTO   l_batch_id
  FROM   dual;
 EXCEPTION
  WHEN OTHERS THEN
  op_result := '99';
  op_msg    := 'Error while generating Batch ID due to '||SUBSTR(SQLERRM, 1, 100);
  util_pkg.insert_error_tab(
                            i_action       => 'TFSOA_BATCH_PROCESS SEQUENCE FAILED',
                            i_key          => p_bus_org,
                            i_program_name => 'TFSOA_BATCH_PROCESS_PKG.TF_CREATE_BATCH_RECORDS',
                            i_error_text   => 'Error while generating Batch ID due to '||SUBSTR(SQLERRM, 1, 100)
                           );
  RETURN;
 END; --}

 --Insert the created Batch Id into X_Program_Batch
 BEGIN --{
  INSERT INTO X_Program_Batch
                             (
                              Objid,
                              Batch_Sub_Date,
                              Payment_Batch2x_Cc_Parms,
                              Batch_Status,
                              X_Batch_Id
                             )
                        VALUES
                             (
                              sa.Seq_X_Program_Batch.Nextval,
                              sysdate,
                              536871141,
                              'SCHEDULED',
                              l_batch_id
                             );
 EXCEPTION
  WHEN OTHERS THEN
  op_result := '99';
  op_msg    := 'Error while creating Batch record due to '||SUBSTR(SQLERRM, 1, 100);
  util_pkg.insert_error_tab(
                            i_action       => 'TFSOA_BATCH_PROCESS X_PROGRAM_BATCH INSERTION FAILED',
                            i_key          => L_Batch_Id,
                            i_program_name => 'TFSOA_BATCH_PROCESS_PKG.TF_CREATE_BATCH_RECORDS',
                            i_error_text   => 'Error while creating Batch record due to '||SUBSTR(SQLERRM, 1, 100)
                           );
  RETURN;
 END; --}

 --Invoke Recurring payment to set up the data
 BEGIN --{
  sa.billing_job_pkg.recurring_payment(
                                       p_bus_org,
                                       in_priority,
                                       op_result,
                                       op_msg
                                       );
 EXCEPTION
  WHEN OTHERS THEN
  op_result := '99';
  op_msg    := 'Error while Invoking Recurring pmt to set up the data '||SUBSTR(SQLERRM, 1, 100);
  util_pkg.insert_error_tab(
                            i_action       => 'TFSOA_BATCH_PROCESS RECURRING_PAYMENT FAILED',
                            i_key          => L_Batch_Id,
                            i_program_name => 'TFSOA_BATCH_PROCESS_PKG.TF_CREATE_BATCH_RECORDS',
                            i_error_text   => 'Error while Invoking Recu pmt to set up the data '||SUBSTR(SQLERRM, 1, 100)
                           );
  RETURN;
 END; --}
 --sa.billing_job_pkg.recurring_payment(p_bus_org=> P_Bus_Org,
 -- op_result=> Op_Result,
 -- op_msg=> Op_Msg);

 -- Updating the qualifying records to be sent to x_program_purch_hdr
 -- with the common Batch Id.
 BEGIN --{
  UPDATE x_program_purch_hdr
  Set    Prog_Hdr2prog_Batch = L_Batch_Id
  WHERE  X_MERCHANT_ID IN
                        (
                         SELECT X_MERCHANT_ID
                         FROM   table_x_cc_parms
                         WHERE  X_MERCHANT_ID LIKE '%billing%'
                        )
  AND   x_status    = 'RECURINCOMPLETE'
  AND   x_rqst_type IN ('ACH_PURCH', 'CREDITCARD_PURCH')
  AND   prog_hdr2prog_batch IS NULL
  --AND   TRUNC (x_rqst_date) <= TRUNC (SYSDATE);	-- Commented and modified for CR48488
  AND   x_rqst_date <= SYSDATE;				-- Modified for CR48488
 EXCEPTION
  WHEN OTHERS THEN
  op_result := '99';
  op_msg    := 'Error while Updating the qualifying records '||SUBSTR(SQLERRM, 1, 100);
  util_pkg.insert_error_tab(
                            i_action       => 'TFSOA_BATCH_PROCESS X_PROGRAM_PURCH_HDR UPT FAILED',
                            i_key          => L_Batch_Id,
                            i_program_name => 'TFSOA_BATCH_PROCESS_PKG.TF_CREATE_BATCH_RECORDS',
                            i_error_text   => 'Error while updating x_program_purch_hdr '||SUBSTR(SQLERRM, 1, 100)
                           );
  RETURN;
 END; --}

-- Insert records to Tfsoa_Batch_Process to be sent to Payment Gateway.
 FOR L_Info IN C_Info(L_Batch_Id)
 Loop

 V_Total_Tax := L_Info.X_Tax_Amount + L_Info.X_E911_Tax_Amount + L_Info.X_Usf_Taxamount + l_info.X_RCRF_TAX_AMOUNT; --CR11553

 BEGIN --{

 INSERT
 INTO Tfsoa_Batch_Process
 (
  Objid ,
  Prog_Purch_Hdr_Objid ,
  PROG_HDR2PROG_BATCH ,
  X_RQST_TYPE ,
  X_RQST_DATE ,
  X_ICS_APPLICATIONS ,
  X_MERCHANT_ID ,
  X_AUTH_REQUEST_ID ,
  X_MERCHANT_REF_NUMBER ,
  X_AMOUNT ,
  X_CUSTOMER_FIRSTNAME ,
  X_CUSTOMER_LASTNAME ,
  X_BILL_ADDRESS1 ,
  X_BILL_CITY ,
  X_BILL_STATE ,
  X_BILL_ZIP ,
  X_BILL_COUNTRY ,
  X_CUSTOMER_EMAIL ,
  X_STATUS ,
  X_AMOUNT_PLUS_TAX ,
  X_BILL_ADDRESS2 ,
  PPH_X_IGNORE_AVS ,
  PPH_X_AVS ,
  PPH_X_DISABLE_AVS ,
  X_CUSTOMER_HOSTNAME ,
  X_CUSTOMER_IPADDRESS ,
  X_TAX_AMOUNT ,
  X_E911_TAX_AMOUNT ,
  X_USF_TAXAMOUNT ,
  X_RCRF_TAX_AMOUNT ,
  X_TOTAL_TAX_AMOUNT ,
  X_AUTH_REQUEST_ID_2 ,
  X_CUSTOMER_PHONE ,
  X_ECP_ACCOUNT_NO ,
  X_ECP_ACCOUNT_TYPE ,
  X_ECP_RDFI ,
  X_BANK_NUM ,
  X_ECP_SETTLEMENT_METHOD ,
  X_DECLINE_AVS_FLAGS ,
  X_ECP_PAYMENT_MODE ,
  X_ECP_VERFICATION_LEVEL ,
  X_ECP_DEBIT_REF_NUMBER ,
  X_CUSTOMER_CC_NUMBER ,
  X_CUSTOMER_CC_EXPMO ,
  X_CUSTOMER_CC_EXPYR ,
  X_CUSTOMER_CVV_NUM ,
  X_IGNORE_BAD_CV ,
  CCPT_X_IGNORE_AVS ,
  CCPT_X_AVS ,
  CCPT_X_DISABLE_AVS ,
  CREDITCARD2CERT ,
  CC_HASH ,
  X_CUST_CC_NUM_KEY ,
  X_CERT ,
  X_KEY_ALGO ,
  X_CC_ALGO ,
  X_CUST_CC_NUM_ENC ,
  PROCESS_STATUS ,
  ROW_INSERT_DATE ,
  ROW_UPDATE_DATE ,
  X_PRIORITY
 )
 VALUES
 (
  Sequ_Batch_Process_Obj.Nextval,
  l_info.batch_objid, --CR46191 corrected
  l_info.PROG_HDR2PROG_BATCH ,
  l_info.X_RQST_TYPE ,
  l_info.X_RQST_DATE ,
  l_info.X_ICS_APPLICATIONS ,
  l_info.X_MERCHANT_ID ,
  l_info.X_AUTH_REQUEST_ID ,
  l_info.X_MERCHANT_REF_NUMBER ,
  l_info.X_AMOUNT ,
  l_info.X_CUSTOMER_FIRSTNAME ,
  l_info.X_CUSTOMER_LASTNAME ,
  l_info.X_BILL_ADDRESS1 ,
  l_info.X_BILL_CITY ,
  l_info.X_BILL_STATE ,
  l_info.X_BILL_ZIP ,
  l_info.X_BILL_COUNTRY ,
  l_info.X_CUSTOMER_EMAIL ,
  l_info.X_STATUS ,
  l_info.X_AMOUNT_PLUS_TAX ,
  l_info.X_BILL_ADDRESS2 ,
  l_info.PPH_X_IGNORE_AVS ,
  l_info.PPH_X_AVS ,
  l_info.PPH_X_DISABLE_AVS ,
  l_info.X_CUSTOMER_HOSTNAME ,
  l_info.X_CUSTOMER_IPADDRESS ,
  l_info.X_TAX_AMOUNT ,
  l_info.X_E911_TAX_AMOUNT ,
  l_info.X_USF_TAXAMOUNT ,
  L_Info.X_RCRF_Tax_Amount , --CR11553
  V_Total_Tax ,
  l_info.X_AUTH_REQUEST_ID_2 ,
  l_info.X_CUSTOMER_PHONE ,
  l_info.X_ECP_ACCOUNT_NO ,
  l_info.X_ECP_ACCOUNT_TYPE ,
  l_info.X_ECP_RDFI ,
  l_info.X_BANK_NUM ,
  l_info.X_ECP_SETTLEMENT_METHOD ,
  l_info.X_DECLINE_AVS_FLAGS ,
  l_info.X_ECP_PAYMENT_MODE ,
  l_info.X_ECP_VERFICATION_LEVEL ,
  l_info.X_ECP_DEBIT_REF_NUMBER ,
  l_info.X_CUSTOMER_CC_NUMBER ,
  l_info.X_CUSTOMER_CC_EXPMO ,
  l_info.X_CUSTOMER_CC_EXPYR ,
  l_info.X_CUSTOMER_CVV_NUM ,
  l_info.X_IGNORE_BAD_CV ,
  l_info.CCPT_X_IGNORE_AVS ,
  l_info.CCPT_X_AVS ,
  l_info.CCPT_X_DISABLE_AVS ,
  l_info.CREDITCARD2CERT ,
  l_info.CC_HASH ,
  l_info.X_CUST_CC_NUM_KEY ,
  l_info.X_CERT ,
  l_info.X_KEY_ALGO ,
  l_info.X_CC_ALGO ,
  l_info.X_CUST_CC_NUM_ENC ,
  'VNEW' ,
  SYSDATE ,
  SYSDATE ,
  l_info.X_PRIORITY
 );

 counter := counter + 1; --CR46191

 EXCEPTION
  WHEN OTHERS THEN
  counter := counter + 1; --CR46191
  util_pkg.insert_error_tab(
                            i_action       => 'TFSOA_BATCH_PROCESS INSERTION FAILED',
                            i_key          => l_info.batch_objid, --CR46191 corrected
                            i_program_name => 'TFSOA_BATCH_PROCESS_PKG.TF_CREATE_BATCH_RECORDS',
                            i_error_text   => 'Failed for Merchant# '||l_info.X_MERCHANT_REF_NUMBER||' L_Batch_Id:'||L_Batch_Id||' counter:'||counter||' due to '||SUBSTR(SQLERRM, 1, 100)
                           );
 END; --}

 End Loop;

 DBMS_OUTPUT.PUT_LINE('Staging table loop count = '||counter);

 --Update the credit cards
 BEGIN --{
  UPDATE X_Program_Purch_Hdr
  SET    X_Status            = 'SUBMITTED',
         X_PRODUCT_CODE      = 'Submitted to Cybersource-RRP'
  Where  Prog_Hdr2prog_Batch = L_Batch_Id
  And    X_Rqst_Type         = 'CREDITCARD_PURCH';
 EXCEPTION
  WHEN OTHERS THEN
  op_result:= '99';
  op_msg   := 'Error while updating CREDITCARD_PURCH: '||SUBSTR (SQLERRM, 1, 100);
  util_pkg.insert_error_tab(
                            i_action       => 'TFSOA_BATCH_PROCESS CREDITCARD_PURCH UPT FAILED',
                            i_key          => L_Batch_Id,
                            i_program_name => 'TFSOA_BATCH_PROCESS_PKG.TF_CREATE_BATCH_RECORDS',
                            i_error_text   => 'Error while updating CREDITCARD_PURCH: '||SUBSTR(SQLERRM, 1, 100)
                           );
  RETURN;
 END; --}

 --Update the ACH
 BEGIN --{
  UPDATE X_Program_Purch_Hdr
  SET    X_Status            = 'RECURACHPENDING',
         X_PRODUCT_CODE      = 'Submitted to Cybersource-RRP'
  Where  Prog_Hdr2prog_Batch = L_Batch_Id
  And    X_Rqst_Type         = 'ACH_PURCH';
 EXCEPTION
  WHEN OTHERS THEN
  op_result:= '99';
  op_msg   := 'Error while updating ACH_PURCH: '||SUBSTR (SQLERRM, 1, 100);
  util_pkg.insert_error_tab(
                            i_action       => 'TFSOA_BATCH_PROCESS ACH_PURCH UPT FAILED',
                            i_key          => L_Batch_Id,
                            i_program_name => 'TFSOA_BATCH_PROCESS_PKG.TF_CREATE_BATCH_RECORDS',
                            i_error_text   => 'Error while updating ACH_PURCH: '||SUBSTR(SQLERRM, 1, 100)
                           );
  RETURN;
 END; --}

 --Update the Master table Batches
 /* Change made on 2/2/2011
 Update X_Program_Batch
 SET batch_status= 'SUBMITTED'
 where x_batch_id= L_Batch_Id;
 **/

 -- Change made on 2/2/2011 - after discuss with Ramu we are updating x_program_batch table with status = 'Processed'
 -- not using the above update.
 BEGIN --{
  Update X_Program_Batch
  SET    batch_status   = 'PROCESSED',
         batch_rec_date = sysdate
  where  x_batch_id     = L_Batch_Id;
 EXCEPTION
  WHEN OTHERS THEN
  op_result:= '99';
  op_msg   := 'Error while updating batch status: '||SUBSTR (SQLERRM, 1, 100);
  util_pkg.insert_error_tab(
                            i_action       => 'TFSOA_BATCH_PROCESS X_PROGRAM_BATCH UPT FAILED',
                            i_key          => L_Batch_Id,
                            i_program_name => 'TFSOA_BATCH_PROCESS_PKG.TF_CREATE_BATCH_RECORDS',
                            i_error_text   => 'Error while updating batch status: '||SUBSTR(SQLERRM, 1, 100)
                           );
  RETURN;
 END; --}

EXCEPTION
WHEN OTHERS THEN
 op_result:= '99';
 op_msg   := 'Update error: '||SUBSTR (SQLERRM, 1, 100);
 util_pkg.insert_error_tab(
                          i_action       => 'TFSOA_BATCH_PROCESS MAIN EXCEPTION',
                          i_key          => L_Batch_Id,
                          i_program_name => 'TFSOA_BATCH_PROCESS_PKG.TF_CREATE_BATCH_RECORDS',
                          i_error_text   => 'Error in main exception: '||SUBSTR(SQLERRM, 1, 100)
                         );
 RETURN;
END TF_CREATE_BATCH_RECORDS ; --}

PROCEDURE get_tfsoa_batch_process_data (i_rownum                          IN  NUMBER   DEFAULT 100      ,
                                        i_process_status                  IN  VARCHAR2 DEFAULT 'VNEW'   ,
                                        o_tfsoa_batch_process_data        OUT TFSOA_BATCH_PROCESS_tab   ,
                                        o_data_count                      OUT NUMBER                 ) is

   CURSOR c_get_data IS
    SELECT TFSOA_BATCH_PROCESS_TYPE (
                                     ROW_ID
                                    ,OBJID
                                    ,PROG_HDR2PROG_BATCH
                                    ,X_RQST_TYPE
                                    ,X_RQST_DATE
                                    ,X_ICS_APPLICATIONS
                                    ,X_MERCHANT_ID
                                    ,X_AUTH_REQUEST_ID
                                    ,X_MERCHANT_REF_NUMBER
                                    ,X_AMOUNT
                                    ,X_CUSTOMER_FIRSTNAME
                                    ,X_CUSTOMER_LASTNAME
                                    ,X_BILL_ADDRESS1
                                    ,X_BILL_CITY
                                    ,X_BILL_STATE
                                    ,X_BILL_ZIP
                                    ,X_BILL_COUNTRY
                                    ,X_CUSTOMER_EMAIL
                                    ,X_STATUS
                                    ,X_AMOUNT_PLUS_TAX
                                    ,X_BILL_ADDRESS2
                                    ,PPH_X_IGNORE_AVS
                                    ,PPH_X_AVS
                                    ,PPH_X_DISABLE_AVS
                                    ,X_CUSTOMER_HOSTNAME
                                    ,X_CUSTOMER_IPADDRESS
                                    ,X_TAX_AMOUNT
                                    ,X_E911_TAX_AMOUNT
                                    ,X_USF_TAXAMOUNT
                                    ,X_RCRF_TAX_AMOUNT
                                    ,X_AUTH_REQUEST_ID_2
                                    ,X_CUSTOMER_PHONE
                                    ,X_ECP_ACCOUNT_NO
                                    ,X_ECP_ACCOUNT_TYPE
                                    ,X_ECP_RDFI
                                    ,X_BANK_NUM
                                    ,X_ECP_SETTLEMENT_METHOD
                                    ,X_DECLINE_AVS_FLAGS
                                    ,X_ECP_PAYMENT_MODE
                                    ,X_ECP_VERFICATION_LEVEL
                                    ,X_ECP_DEBIT_REF_NUMBER
                                    ,X_CUSTOMER_CC_NUMBER
                                    ,X_CUSTOMER_CC_EXPMO
                                    ,X_CUSTOMER_CC_EXPYR
                                    ,X_CUSTOMER_CVV_NUM
                                    ,X_IGNORE_BAD_CV
                                    ,CCPT_X_IGNORE_AVS
                                    ,CCPT_X_AVS
                                    ,CCPT_X_DISABLE_AVS
                                    ,CREDITCARD2CERT
                                    ,CC_HASH
                                    ,X_CUST_CC_NUM_KEY
                                    ,X_CERT
                                    ,X_KEY_ALGO
                                    ,X_CC_ALGO
                                    ,X_CUST_CC_NUM_ENC
                                    ,PROCESS_STATUS
                                    ,ROW_INSERT_DATE
                                    ,ROW_UPDATE_DATE
                                    ,PROG_PURCH_HDR_OBJID
                                    ,X_TOTAL_TAX_AMOUNT
                                    ,X_PRIORITY
                                 )
    FROM   ( SELECT
                                     ROWID ROW_ID
                                    ,OBJID
                                    ,PROG_HDR2PROG_BATCH
                                    ,X_RQST_TYPE
                                    ,X_RQST_DATE
                                    ,X_ICS_APPLICATIONS
                                    ,X_MERCHANT_ID
                                    ,X_AUTH_REQUEST_ID
                                    ,X_MERCHANT_REF_NUMBER
                                    ,X_AMOUNT
                                    ,X_CUSTOMER_FIRSTNAME
                                    ,X_CUSTOMER_LASTNAME
                                    ,X_BILL_ADDRESS1
                                    ,X_BILL_CITY
                                    ,X_BILL_STATE
                                    ,X_BILL_ZIP
                                    ,X_BILL_COUNTRY
                                    ,X_CUSTOMER_EMAIL
                                    ,X_STATUS
                                    ,X_AMOUNT_PLUS_TAX
                                    ,X_BILL_ADDRESS2
                                    ,PPH_X_IGNORE_AVS
                                    ,PPH_X_AVS
                                    ,PPH_X_DISABLE_AVS
                                    ,X_CUSTOMER_HOSTNAME
                                    ,X_CUSTOMER_IPADDRESS
                                    ,X_TAX_AMOUNT
                                    ,X_E911_TAX_AMOUNT
                                    ,X_USF_TAXAMOUNT
                                    ,X_RCRF_TAX_AMOUNT
                                    ,X_AUTH_REQUEST_ID_2
                                    ,X_CUSTOMER_PHONE
                                    ,X_ECP_ACCOUNT_NO
                                    ,X_ECP_ACCOUNT_TYPE
                                    ,X_ECP_RDFI
                                    ,X_BANK_NUM
                                    ,X_ECP_SETTLEMENT_METHOD
                                    ,X_DECLINE_AVS_FLAGS
                                    ,X_ECP_PAYMENT_MODE
                                    ,X_ECP_VERFICATION_LEVEL
                                    ,X_ECP_DEBIT_REF_NUMBER
                                    ,X_CUSTOMER_CC_NUMBER
                                    ,X_CUSTOMER_CC_EXPMO
                                    ,X_CUSTOMER_CC_EXPYR
                                    ,X_CUSTOMER_CVV_NUM
                                    ,X_IGNORE_BAD_CV
                                    ,CCPT_X_IGNORE_AVS
                                    ,CCPT_X_AVS
                                    ,CCPT_X_DISABLE_AVS
                                    ,CREDITCARD2CERT
                                    ,CC_HASH
                                    ,X_CUST_CC_NUM_KEY
                                    ,X_CERT
                                    ,X_KEY_ALGO
                                    ,X_CC_ALGO
                                    ,X_CUST_CC_NUM_ENC
                                    ,PROCESS_STATUS
                                    ,ROW_INSERT_DATE
                                    ,ROW_UPDATE_DATE
                                    ,PROG_PURCH_HDR_OBJID
                                    ,X_TOTAL_TAX_AMOUNT
                                    ,X_PRIORITY
             FROM   sa.tfsoa_batch_process
             WHERE  process_status  = i_process_status
        )
  WHERE  ROWNUM <= i_rownum
  FOR UPDATE OF process_status;

 BEGIN

  --
  o_tfsoa_batch_process_data := TFSOA_BATCH_PROCESS_tab();

  --
  OPEN c_get_data;
  FETCH c_get_data BULK COLLECT INTO o_tfsoa_batch_process_data;
  CLOSE c_get_data;

  o_data_count := o_tfsoa_batch_process_data.COUNT;

  --
  IF o_tfsoa_batch_process_data IS NULL THEN
    o_data_count := 0;
    RETURN;
  END IF;

  IF o_data_count = 0 THEN
    RETURN;
  END IF;

  --
  FORALL  i IN 1 .. o_tfsoa_batch_process_data.COUNT
     UPDATE sa.tfsoa_batch_process SET process_status = 'PROCESSED' where rowid=o_tfsoa_batch_process_data(i).row_id;

 EXCEPTION
   WHEN others THEN
     DBMS_OUTPUT.PUT_LINE('ERROR : ' || SQLERRM );
     o_data_count := -1;
 END get_tfsoa_batch_process_data;


END TFSOA_BATCH_PROCESS_PKG ;
/