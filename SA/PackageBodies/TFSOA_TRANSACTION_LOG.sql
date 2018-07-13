CREATE OR REPLACE PACKAGE BODY sa."TFSOA_TRANSACTION_LOG" AS
--------------------------------------------------------------------------------------------
--$RCSfile: TFSOA_TRANSACTION_LOG_PKB.sql,v $
--$Revision: 1.3 $
--$Author: mmunoz $
--$Date: 2012/04/23 22:30:34 $
--$ $Log: TFSOA_TRANSACTION_LOG_PKB.sql,v $
--$ Revision 1.3  2012/04/23 22:30:34  mmunoz
--$ CR20557 Adding column SIM
--$
--$ Revision 1.2  2012/04/23 18:41:11  mmunoz
--$ *** empty log message ***
--$
--$ Revision 1.1  2012/04/23 18:31:30  mmunoz
--$ CR20557 Manage partner's transactions
--$
--------------------------------------------------------------------------------------------
PROCEDURE INSERT_TRANS_LOG (
		ip_TRANSACTION_ID         IN VARCHAR2
		,ip_CLIENT_ID             IN VARCHAR2
		,ip_SOURCE_SYSTEM         IN VARCHAR2
		,ip_ZIPCODE               IN VARCHAR2
		,ip_ESN                   IN VARCHAR2
		,ip_SIM                   IN VARCHAR2
		,ip_PIN                   IN VARCHAR2
		,ip_ENROLL_PLAN_ID        IN NUMBER
		,ip_PYMT_FIRST_NAME       IN VARCHAR2
		,ip_PYMT_LAST_NAME        IN VARCHAR2
		,ip_PYMT_PHONE_NUMBER     IN VARCHAR2
		,ip_PYMT_EMAIL	          IN VARCHAR2
		,ip_PYMT_ADDRESS_1        IN VARCHAR2
		,ip_PYMT_ADDRESS_2        IN VARCHAR2
		,ip_PYMT_CITY             IN VARCHAR2
		,ip_PYMT_STATE	          IN VARCHAR2
		,ip_PYMT_ZIPCODE          IN VARCHAR2
		,ip_PYMT_SOURCE_TYPE      IN VARCHAR2
		,ip_PYMT_NICKNAME         IN VARCHAR2
		,ip_PYMT_CARDTYPE         IN VARCHAR2
		,ip_PYMT_ACCOUNT_NUMBER	  IN VARCHAR2
		,ip_PYMT_EXP_YEAR         IN VARCHAR2
		,ip_PYMT_EXP_MONTH        IN VARCHAR2
		,ip_PYMT_CVV              IN VARCHAR2
		,ip_ACCOUNT_EMAIL         IN VARCHAR2
		,ip_ACCOUNT_PSWD          IN VARCHAR2
		,ip_SERVICE_NAME          IN VARCHAR2
		,ip_TRANSACTION_STATUS	  IN VARCHAR2
		,ip_PAYMENTOBJID          IN NUMBER
		,ip_AUTHCODE              IN VARCHAR2
		,op_err_num               out number
		,op_err_string            out varchar2
) IS
--============================================
-- Insert a record for one transaction log
--============================================
BEGIN
	op_err_num	:= 0;
	op_err_string	:= 'SUCCESS';
	BEGIN
		INSERT INTO X_PARTNER_TRANSACTION_LOG (
			OBJID
			,CREATION_DATE
			,TRANSACTION_ID
			,CLIENT_ID
			,SOURCE_SYSTEM
			,ZIPCODE
			,ESN
			,SIM
			,PIN
			,ENROLL_PLAN_ID
 			,PYMT_FIRST_NAME
			,PYMT_LAST_NAME
			,PYMT_PHONE_NUMBER
 			,PYMT_EMAIL
			,PYMT_ADDRESS_1
			,PYMT_ADDRESS_2
 			,PYMT_CITY
			,PYMT_STATE
			,PYMT_ZIPCODE
			,PYMT_SOURCE_TYPE
 			,PYMT_NICKNAME
			,PYMT_CARDTYPE
			,PYMT_ACCOUNT_NUMBER
			,PYMT_EXP_YEAR
			,PYMT_EXP_MONTH
			,PYMT_CVV
			,ACCOUNT_EMAIL
			,ACCOUNT_PSWD
			,SERVICE_NAME
			,TRANSACTION_STATUS
			,PAYMENTOBJID
 			,AUTHCODE)
		VALUES (
			sa.SEQ_X_PARTNER_TRAN.nextval
			,sysdate
			,ip_TRANSACTION_ID
			,ip_CLIENT_ID
			,ip_SOURCE_SYSTEM
			,ip_ZIPCODE
			,ip_ESN
			,ip_SIM
			,ip_PIN
			,ip_ENROLL_PLAN_ID
			,ip_PYMT_FIRST_NAME
			,ip_PYMT_LAST_NAME
			,ip_PYMT_PHONE_NUMBER
			,ip_PYMT_EMAIL
			,ip_PYMT_ADDRESS_1
			,ip_PYMT_ADDRESS_2
			,ip_PYMT_CITY
			,ip_PYMT_STATE
			,ip_PYMT_ZIPCODE
			,ip_PYMT_SOURCE_TYPE
			,ip_PYMT_NICKNAME
			,ip_PYMT_CARDTYPE
			,ip_PYMT_ACCOUNT_NUMBER
			,ip_PYMT_EXP_YEAR
			,ip_PYMT_EXP_MONTH
			,ip_PYMT_CVV
			,ip_ACCOUNT_EMAIL
			,ip_ACCOUNT_PSWD
			,ip_SERVICE_NAME
			,ip_TRANSACTION_STATUS
			,ip_PAYMENTOBJID
			,ip_AUTHCODE
		);
	EXCEPTION
	WHEN OTHERS THEN
		op_err_num		:= SQLCODE;
		op_err_string	:= SQLERRM;
	END;
	RETURN;
END INSERT_TRANS_LOG;
BEGIN
NULL;
END;
/