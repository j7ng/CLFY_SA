CREATE OR REPLACE PACKAGE BODY sa.PRE_VAL_PURCHASE_PKG IS
/***************************************************************************************************************
 Program Name       :  	SP_INSERT_X_PRE_VAL_PURCH_HDR
 Program Type       :  	Stored procedure
 Program Arguments  :
 Returns            :
 Program Called     :  	None
 Description        :  	This stored procedure will insert record into X_PRE_VAL_PURCH_HDR
 Modified By            Modification     CR             Description
                          Date           Number
 =============          ============     ======      ===================================
 Jai Arza        	  	    09/09/2014     CR28571  	        Initial Creation
***************************************************************************************************************/
  PROCEDURE SP_INSERT_X_PRE_VAL_PURCH_HDR(
    IP_X_RQST_SOURCE            		VARCHAR2,
		IP_X_RQST_TYPE              		VARCHAR2,
		IP_X_RQST_DATE              		DATE,
		IP_X_PAYMENT_TYPE          		VARCHAR2,
		IP_X_BRAND_NAME					VARCHAR2,
		IP_X_LANGUAGE						VARCHAR2,
		IP_X_CARD_TYPE						VARCHAR2,
		IP_X_NEW_REGISTRATION				VARCHAR2,
		IP_X_CALLING_MODULE_ID				VARCHAR2,
		IP_X_WEB_USER_LOGIN_ID				VARCHAR2,
		IP_X_AGENT							VARCHAR2,
		IP_X_SKIP_ENROLLMENT				VARCHAR2,
		IP_X_MERCHANT_ID            		VARCHAR2,
		IP_X_ESN							VARCHAR2,
		IP_X_MERCHANT_REF_NUMBER			VARCHAR2,
		IP_X_CUSTOMER_HOSTNAME     		VARCHAR2,
		IP_X_CUSTOMER_IPADDRESS    		VARCHAR2,
		IP_X_CUSTOMER_FIRSTNAME     		VARCHAR2,
		IP_X_CUSTOMER_LASTNAME      		VARCHAR2,
		IP_X_CUSTOMER_PHONE         		VARCHAR2,
		IP_X_CUSTOMER_EMAIL         		VARCHAR2,
		IP_X_BILL_ADDRESS1         		VARCHAR2,
		IP_X_BILL_ADDRESS2         		VARCHAR2,
		IP_X_BILL_CITY             		VARCHAR2,
		IP_X_BILL_STATE            		VARCHAR2,
		IP_X_BILL_ZIP              		VARCHAR2,
		IP_X_BILL_COUNTRY          		VARCHAR2,
		IP_X_AMOUNT                 		NUMBER,
		IP_X_AUTH_AMOUNT            		NUMBER,
		IP_X_BILL_AMOUNT            		NUMBER,
		IP_X_E911_AMOUNT            		NUMBER,
		IP_X_USF_TAXAMOUNT          		NUMBER,
		IP_X_RCRF_TAX_AMOUNT        		NUMBER,
		IP_X_DISCOUNT_AMOUNT        		NUMBER,
		IP_X_TAX_AMOUNT             		NUMBER,
		IP_X_PREVAL_PURCH2CREDITCARD   	NUMBER,
		IP_X_PREVAL_PURCH2BANK_ACCT		NUMBER,
		IP_AGENT_NAME              	VARCHAR2,
		IP_X_PREVAL_PURCH2ESN          	NUMBER,
		IP_X_PREVAL_PURCH2PYMT_SRC     	NUMBER,
		IP_X_PREVAL_PURCH2WEB_USER       	NUMBER,
		IP_X_PREVAL_PURCH2CONTACT      	NUMBER,
		IP_X_PREVAL_PURCH2RMSG_CODES    	NUMBER,
		IP_X_ERROR_NUMBER					VARCHAR2,
		IP_X_ECOM_ORG_ID					VARCHAR2,
		IP_X_C_ORDERID						VARCHAR2,
		IP_X_ACCOUNT_ID					VARCHAR2,
		IP_X_IDN_USER_CHANGE_LAST			VARCHAR2,
    OP_OBJID             OUT   VARCHAR2
          ) IS
    V_OBJID                     sa.X_PRE_VAL_PURCH_HDR.OBJID%TYPE:=0;
    V_X_PREVAL_PURCH2USER      sa.X_PRE_VAL_PURCH_HDR.X_PREVAL_PURCH2USER%TYPE;
  BEGIN
    SELECT  sa.SEQU_X_PRE_VAL_PURCH_HDR.NEXTVAL
    INTO    V_OBJID
    FROM    DUAL;

    IF IP_AGENT_NAME IS NOT NULL THEN
      BEGIN
        SELECT  OBJID
        INTO    V_X_PREVAL_PURCH2USER
        FROM    TABLE_USER
        WHERE   S_LOGIN_NAME = upper(IP_AGENT_NAME);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    INSERT INTO sa.X_PRE_VAL_PURCH_HDR
      ( OBJID,
        X_RQST_SOURCE,
        X_RQST_TYPE,
        X_RQST_DATE,
        X_PAYMENT_TYPE,
        X_BRAND_NAME,
        X_LANGUAGE,
        X_CARD_TYPE,
        X_NEW_REGISTRATION,
        X_CALLING_MODULE_ID,
        X_WEB_USER_LOGIN_ID,
        X_AGENT,
        X_SKIP_ENROLLMENT,
        X_MERCHANT_ID,
        X_ESN	,
        X_MERCHANT_REF_NUMBER,
        X_CUSTOMER_HOSTNAME,
        X_CUSTOMER_IPADDRESS,
        X_CUSTOMER_FIRSTNAME,
        X_CUSTOMER_LASTNAME,
        X_CUSTOMER_PHONE,
        X_CUSTOMER_EMAIL,
        X_BILL_ADDRESS1,
        X_BILL_ADDRESS2,
        X_BILL_CITY,
        X_BILL_STATE,
        X_BILL_ZIP ,
        X_BILL_COUNTRY,
        X_AMOUNT ,
        X_AUTH_AMOUNT,
        X_BILL_AMOUNT,
        X_E911_AMOUNT,
        X_USF_TAXAMOUNT,
        X_RCRF_TAX_AMOUNT,
        X_DISCOUNT_AMOUNT ,
        X_TAX_AMOUNT,
        X_PREVAL_PURCH2CREDITCARD,
        X_PREVAL_PURCH2BANK_ACCT,
        X_PREVAL_PURCH2USER,
        X_PREVAL_PURCH2ESN,
        X_PREVAL_PURCH2PYMT_SRC,
        X_PREVAL_PURCH2WEB_USER,
        X_PREVAL_PURCH2CONTACT,
        X_PREVAL_PURCH2RMSG_CODES,
        X_ERROR_NUMBER,
        X_ECOM_ORG_ID,
        X_C_ORDERID,
        X_ACCOUNT_ID,
        X_IDN_USER_CHANGE_LAST,
        X_DTE_CHANGE_LAST)
    VALUES
      (
        V_OBJID,
        IP_X_RQST_SOURCE,
        IP_X_RQST_TYPE,
        IP_X_RQST_DATE,
        IP_X_PAYMENT_TYPE,
        IP_X_BRAND_NAME,
        IP_X_LANGUAGE,
        IP_X_CARD_TYPE,
        IP_X_NEW_REGISTRATION,
        IP_X_CALLING_MODULE_ID,
        IP_X_WEB_USER_LOGIN_ID,
        IP_X_AGENT,
        IP_X_SKIP_ENROLLMENT,
        IP_X_MERCHANT_ID,
        IP_X_ESN	,
        IP_X_MERCHANT_REF_NUMBER,
        IP_X_CUSTOMER_HOSTNAME,
        IP_X_CUSTOMER_IPADDRESS,
        IP_X_CUSTOMER_FIRSTNAME,
        IP_X_CUSTOMER_LASTNAME,
        IP_X_CUSTOMER_PHONE,
        IP_X_CUSTOMER_EMAIL,
        IP_X_BILL_ADDRESS1,
        IP_X_BILL_ADDRESS2,
        IP_X_BILL_CITY,
        IP_X_BILL_STATE,
        IP_X_BILL_ZIP ,
        IP_X_BILL_COUNTRY,
        IP_X_AMOUNT ,
        IP_X_AUTH_AMOUNT,
        IP_X_BILL_AMOUNT,
        IP_X_E911_AMOUNT,
        IP_X_USF_TAXAMOUNT,
        IP_X_RCRF_TAX_AMOUNT,
        IP_X_DISCOUNT_AMOUNT ,
        IP_X_TAX_AMOUNT,
        IP_X_PREVAL_PURCH2CREDITCARD,
        IP_X_PREVAL_PURCH2BANK_ACCT,
        V_X_PREVAL_PURCH2USER,
        IP_X_PREVAL_PURCH2ESN,
        IP_X_PREVAL_PURCH2PYMT_SRC,
        IP_X_PREVAL_PURCH2WEB_USER,
        IP_X_PREVAL_PURCH2CONTACT,
        IP_X_PREVAL_PURCH2RMSG_CODES,
        IP_X_ERROR_NUMBER,
        IP_X_ECOM_ORG_ID,
        IP_X_C_ORDERID,
        IP_X_ACCOUNT_ID,
        IP_X_IDN_USER_CHANGE_LAST,
        SYSDATE--X_DTE_CHANGE_LAST
        );
    OP_OBJID := V_OBJID;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END ;
/***************************************************************************************************************
 Program Name       :  	SP_INSERT_X_PRE_VAL_PURCH_DTL
 Program Type       :  	Stored procedure
 Program Arguments  :
 Returns            :
 Program Called     :  	None
 Description        :  	This stored procedure will insert record into X_PRE_VAL_PURCH_DTL
 Modified By            Modification     CR             Description
                          Date           Number
 =============          ============     ======      ===================================
 Jai Arza        	  	    09/09/2014     CR28571  	        Initial Creation
***************************************************************************************************************/
  PROCEDURE SP_INSERT_X_PRE_VAL_PURCH_DTL
    ( IP_X_PART_NUMBERS					VARCHAR2,
      IP_X_CARD_QTY						NUMBER,
      IP_X_ESN							VARCHAR2,
      IP_X_PROGRAM_TYPE					VARCHAR2,
      IP_X_PROGRAM_NAME					VARCHAR2,
	  IP_X_CC_SCHEDULE_DATE				VARCHAR2,
	  IP_X_COUNT_ESN_PRIMARY				VARCHAR2,
		IP_X_COUNT_ESN_SECONDARY			VARCHAR2,
		IP_X_CC_SCHEDULED					VARCHAR2,
		IP_X_PREVAL_PURCH2PROMOTION		NUMBER,
		IP_X_PROMO_CODE					VARCHAR2,
      IP_X_PREVAL_PUR_DTL2PROGRAM		NUMBER,
      IP_X_PREVAL_PUR_DTL2PREPUR_HDR	NUMBER,
      IP_X_IDN_USER_CHANGE_LAST			VARCHAR2,
      OP_OBJID               OUT VARCHAR2
      ) IS
      V_OBJID         sa.X_PRE_VAL_PURCH_DTL.OBJID%TYPE:=0;
  BEGIN
    SELECT  sa.SEQU_X_PRE_VAL_PURCH_DTL.NEXTVAL
    INTO    V_OBJID
    FROM    DUAL;

    INSERT INTO sa.X_PRE_VAL_PURCH_DTL
      (OBJID,
      X_PART_NUMBERS,
      X_CARD_QTY,
      X_ESN,
      X_PROGRAM_TYPE,
      X_PROGRAM_NAME,
	  X_CC_SCHEDULE_DATE,
	  X_COUNT_ESN_PRIMARY,
      X_COUNT_ESN_SECONDARY,
      X_CC_SCHEDULED,
      X_PREVAL_PURCH2PROMOTION,
        X_PROMO_CODE,
      X_PREVAL_PUR_DTL2PROGRAM,
      X_PREVAL_PUR_DTL2PRE_PURCH_HDR,
      X_IDN_USER_CHANGE_LAST,
      X_DTE_CHANGE_LAST)
    VALUES(V_OBJID,
      IP_X_PART_NUMBERS,
      IP_X_CARD_QTY,
      IP_X_ESN,
      IP_X_PROGRAM_TYPE,
      IP_X_PROGRAM_NAME,
	  IP_X_CC_SCHEDULE_DATE,
	  IP_X_COUNT_ESN_PRIMARY,
      IP_X_COUNT_ESN_SECONDARY,
	  IP_X_CC_SCHEDULED,
      IP_X_PREVAL_PURCH2PROMOTION,
        IP_X_PROMO_CODE,
      IP_X_PREVAL_PUR_DTL2PROGRAM,
      IP_X_PREVAL_PUR_DTL2PREPUR_HDR,
      IP_X_IDN_USER_CHANGE_LAST,
      SYSDATE--X_DTE_CHANGE_LAST
      )
    ;
     OP_OBJID := V_OBJID;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

END PRE_VAL_PURCHASE_PKG;
/