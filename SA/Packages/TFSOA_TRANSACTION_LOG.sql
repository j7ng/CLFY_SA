CREATE OR REPLACE PACKAGE sa."TFSOA_TRANSACTION_LOG" AS
--------------------------------------------------------------------------------------------
--$RCSfile: TFSOA_TRANSACTION_LOG_PKG.sql,v $
--$Revision: 1.2 $
--$Author: mmunoz $
--$Date: 2012/04/23 22:19:14 $
--$ $Log: TFSOA_TRANSACTION_LOG_PKG.sql,v $
--$ Revision 1.2  2012/04/23 22:19:14  mmunoz
--$ CR20557 Adding SIM
--$
--$ Revision 1.1  2012/04/23 18:30:05  mmunoz
--$ CR20557 Manage partner's transactions
--$
--------------------------------------------------------------------------------------------

  /*===============================================================================================*/
  /*                                                                                               */
  /* PURPOSE  : Package has been developed to manage information related with the transactions     */
  /*            between partners (Antenna, BestBuy...) and Tracfone                                */
  /*                                                                                               */
  /*===============================================================================================*/

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
);

END TFSOA_TRANSACTION_LOG;
/