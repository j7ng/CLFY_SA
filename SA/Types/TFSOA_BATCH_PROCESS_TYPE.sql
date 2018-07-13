CREATE OR REPLACE TYPE sa.TFSOA_BATCH_PROCESS_TYPE
AS
  OBJECT
  (
       ROW_ID                       VARCHAR2(30)
      ,OBJID                        NUMBER
      ,PROG_HDR2PROG_BATCH          NUMBER
      ,X_RQST_TYPE                  VARCHAR2(20)
      ,X_RQST_DATE                  DATE
      ,X_ICS_APPLICATIONS           VARCHAR2(50)
      ,X_MERCHANT_ID                VARCHAR2(30)
      ,X_AUTH_REQUEST_ID            VARCHAR2(30)
      ,X_MERCHANT_REF_NUMBER        VARCHAR2(30)
      ,X_AMOUNT                     NUMBER(19,2)
      ,X_CUSTOMER_FIRSTNAME         VARCHAR2(20)
      ,X_CUSTOMER_LASTNAME          VARCHAR2(20)
      ,X_BILL_ADDRESS1              VARCHAR2(200)
      ,X_BILL_CITY                  VARCHAR2(30)
      ,X_BILL_STATE                 VARCHAR2(40)
      ,X_BILL_ZIP                   VARCHAR2(20)
      ,X_BILL_COUNTRY               VARCHAR2(20)
      ,X_CUSTOMER_EMAIL             VARCHAR2(50)
      ,X_STATUS                     VARCHAR2(20)
      ,X_AMOUNT_PLUS_TAX            NUMBER
      ,X_BILL_ADDRESS2              VARCHAR2(200)
      ,PPH_X_IGNORE_AVS             VARCHAR2(10)
      ,PPH_X_AVS                    VARCHAR2(30)
      ,PPH_X_DISABLE_AVS            VARCHAR2(30)
      ,X_CUSTOMER_HOSTNAME          VARCHAR2(60)
      ,X_CUSTOMER_IPADDRESS         VARCHAR2(30)
      ,X_TAX_AMOUNT                 NUMBER(19,2)
      ,X_E911_TAX_AMOUNT            NUMBER(19,2)
      ,X_USF_TAXAMOUNT              NUMBER
      ,X_RCRF_TAX_AMOUNT            NUMBER(19,4)
      ,X_AUTH_REQUEST_ID_2          VARCHAR2(30)
      ,X_CUSTOMER_PHONE             VARCHAR2(20)
      ,X_ECP_ACCOUNT_NO             VARCHAR2(400)
      ,X_ECP_ACCOUNT_TYPE           VARCHAR2(20)
      ,X_ECP_RDFI                   VARCHAR2(30)
      ,X_BANK_NUM                   VARCHAR2(30)
      ,X_ECP_SETTLEMENT_METHOD      VARCHAR2(30)
      ,X_DECLINE_AVS_FLAGS          VARCHAR2(255)
      ,X_ECP_PAYMENT_MODE           VARCHAR2(30)
      ,X_ECP_VERFICATION_LEVEL      VARCHAR2(30)
      ,X_ECP_DEBIT_REF_NUMBER       VARCHAR2(70)
      ,X_CUSTOMER_CC_NUMBER         VARCHAR2(255)
      ,X_CUSTOMER_CC_EXPMO          VARCHAR2(2)
      ,X_CUSTOMER_CC_EXPYR          VARCHAR2(4)
      ,X_CUSTOMER_CVV_NUM           VARCHAR2(20)
      ,X_IGNORE_BAD_CV              VARCHAR2(30)
      ,CCPT_X_IGNORE_AVS            VARCHAR2(30)
      ,CCPT_X_AVS                   VARCHAR2(30)
      ,CCPT_X_DISABLE_AVS           VARCHAR2(30)
      ,CREDITCARD2CERT              NUMBER
      ,CC_HASH                      VARCHAR2(255)
      ,X_CUST_CC_NUM_KEY            VARCHAR2(400)
      ,X_CERT                       VARCHAR2(64)
      ,X_KEY_ALGO                   VARCHAR2(128)
      ,X_CC_ALGO                    VARCHAR2(128)
      ,X_CUST_CC_NUM_ENC            VARCHAR2(400)
      ,PROCESS_STATUS               VARCHAR2(30)
      ,ROW_INSERT_DATE              DATE
      ,ROW_UPDATE_DATE              DATE
      ,PROG_PURCH_HDR_OBJID         NUMBER
      ,X_TOTAL_TAX_AMOUNT           NUMBER
      ,X_PRIORITY                   NUMBER
    ,CONSTRUCTOR  FUNCTION TFSOA_BATCH_PROCESS_TYPE RETURN SELF AS  RESULT
  );
/