CREATE OR REPLACE PACKAGE sa."ACCESS_TOKEN"
AS
  /***************************************************************************************************/
  --$RCSfile: ACCESS_TOKEN_PKG.sql,v $
  --$Revision: 1.19 $
  --$Author: jarza $
  --$Date: 2015/06/17 15:52:51 $
  --$ $Log: ACCESS_TOKEN_PKG.sql,v $
  --$ Revision 1.19  2015/06/17 15:52:51  jarza
  --$ CR32782 changes - added a new procedure to expire user token immediatly.
  --$ When SOA calls this procedure all the tokens linked to this user will expire.
  --$
  --$ Revision 1.18  2015/02/02 14:16:13  ahabeeb
  --$ Added new proc - getAccountFromToken
  --$
  --$ Revision 1.17  2014/02/26 20:26:10  mvadlapally
  --$ CR25065 - Safelink friends
  --$
  --$ Revision 1.13  2012/08/13 21:13:04  mmunoz
  --$ CR21540 : Rename CreatePartner for CreateOrUpdatePartner
  --$
  --$ Revision 1.12  2012/07/23 20:50:18  mmunoz
  --$ CR15547 : PROCEDURE UpdateRequestToken updated and ValidateTokensGetAccInfo, CreatePartner added
  --$
  --$ Revision 1.11  2011/11/07 19:15:05  mmunoz
  --$ Added op_email in check_myaccount and CheckAccountLogin  is not longer needed
  --$
  --$ Revision 1.10  2011/10/27 15:12:32  mmunoz
  --$ Changes in procedure Check_login
  --$
  --$ Revision 1.7  2011/10/19 15:07:49  akhan
  --$ Adding CVS header
  --$
  /***************************************************************************************************/
  /*===============================================================================================*/
  /*                                                                                               */
  /* PURPOSE  : Package has been developed to manage token information related with                */
  /*            interfacing between Antenna and Tracfone for Savings Club                          */
  /*                                                                                               */
  /* REVISIONS  DATE       WHO            PURPOSE                                                  */
  /* --------------------------------------------------------------------------------------------- */
  /*            10/17/11   mmunoz     CR15547: Mobile Marketing - Savings Club. Initial  Revision  */
  /*===============================================================================================*/
  PROCEDURE Check_MyAccount(
      ip_esn IN VARCHAR2 ,
      op_email OUT VARCHAR2 ,
      op_accountid OUT NUMBER ,
      op_contactObjid OUT NUMBER ,
      op_user_token OUT VARCHAR2 ,
      op_brand OUT VARCHAR2 ,
      op_model OUT VARCHAR2 ,
      op_url OUT VARCHAR2 ,
      op_loginlevel OUT NUMBER ,
      op_isEmailValidated OUT NUMBER ,
      op_err_num OUT NUMBER ,
      op_err_string OUT VARCHAR2 );
  PROCEDURE ValidateUserToken(
      ip_user_token IN VARCHAR2 ,
      op_err_num OUT NUMBER ,
      op_err_string OUT VARCHAR2 );
  PROCEDURE GetUserTokenAccountInfo(
      ip_user_token IN VARCHAR2 ,
      op_accountid OUT VARCHAR2 ,
      op_contactObjid OUT NUMBER ,
      op_brand OUT VARCHAR2 ,
      op_model OUT VARCHAR2 ,
      op_loginlevel OUT VARCHAR2 ,
      op_isEmailValidated OUT NUMBER ,
      op_err_num OUT NUMBER ,
      op_err_string OUT VARCHAR2 );
  PROCEDURE ValidateRequestToken(
      ip_request_token IN VARCHAR2 ,
      op_err_num OUT NUMBER ,
      op_err_string OUT VARCHAR2 );
  PROCEDURE getAccountFromToken(
      ip_request_token IN VARCHAR2 ,
      op_login_name OUT VARCHAR2 ,
      op_err_num OUT NUMBER ,
      op_err_string OUT VARCHAR2 );
  PROCEDURE Validate_Login_ESN(
      ip_user_name IN VARCHAR2 ,
      ip_password  IN VARCHAR2 ,
      ip_esn       IN VARCHAR2 ,
      op_accountid OUT NUMBER ,
      op_user_token OUT VARCHAR2 ,
      op_brand_name OUT VARCHAR2 ,
      op_model_number OUT VARCHAR2 ,
      op_url OUT VARCHAR2 ,
      op_err_num OUT NUMBER ,
      op_err_string OUT VARCHAR2 );
  /***    CheckAccountLogin  is not longer needed. Using another existing service (Authentication)
  PROCEDURE CheckAccountLogin (
  ip_user_name        in varchar2
  ,ip_password        in varchar2
  ,ip_brand           in varchar2
  ,op_accountid       out number
  ,op_contactObjid    out number
  ,op_model           out varchar2
  ,op_err_num         out number
  ,op_err_string      out varchar2
  );
  ***/
  PROCEDURE ValidateB2BUser(
      ip_user_name IN VARCHAR2 ,
      ip_password  IN VARCHAR2 ,
      op_err_num OUT NUMBER ,
      op_err_string OUT VARCHAR2 ) ;
  PROCEDURE UpdateUserToken(
      ip_accountid  IN NUMBER ,
      ip_token      IN VARCHAR2 ,
      ip_loginlevel IN NUMBER ,
      op_err_num OUT NUMBER ,
      op_err_string OUT VARCHAR2 );
  PROCEDURE UpdateRequestToken(
      ip_token     IN VARCHAR2 ,
      ip_user_name IN VARCHAR2 ,
      op_err_num OUT NUMBER ,
      op_err_string OUT VARCHAR2 );
  PROCEDURE ValidateTokensGetAccInfo(
      ip_user_token    IN VARCHAR2 ,
      ip_partner_token IN VARCHAR2 ,
      op_accountid OUT VARCHAR2 ,
      op_contactObjid OUT NUMBER ,
      op_brand OUT VARCHAR2 ,
      op_model OUT VARCHAR2 ,
      op_loginlevel OUT VARCHAR2 ,
      op_isEmailValidated OUT NUMBER ,
      op_err_num OUT NUMBER ,
      op_err_string OUT VARCHAR2 );
  PROCEDURE CreateOrUpdatePartner(
      ip_user_name    IN VARCHAR2 ,
      ip_password     IN VARCHAR2 ,
      ip_company_name IN VARCHAR2 ,
      op_err_num OUT NUMBER ,
      op_err_string OUT VARCHAR2 );
  PROCEDURE EXPIRE_USER_TOKEN_IMMEDIATE(
      ip_accountid  IN NUMBER ,
      op_err_num OUT NUMBER ,
      op_err_string OUT VARCHAR2 );
END ACCESS_TOKEN;
/