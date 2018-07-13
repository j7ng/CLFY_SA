CREATE OR REPLACE PACKAGE body sa.ma_integration_pkg
AS
PROCEDURE proc_get_acct_detls_by_acctid(
    i_accountid IN TABLE_WEB_USER.OBJID%TYPE,
    op_err_num OUT NUMBER,
    op_err_string OUT VARCHAR2,
    op_result OUT VARCHAR2,
    op_accountdetails OUT sys_refcursor)
IS
BEGIN
  OPEN op_accountdetails FOR SELECT CT.FIRST_NAME,
									CT.LAST_NAME,
									AD.ADDRESS ADDRESS_1,
									AD.ADDRESS_2,
									AD.CITY,
									AD.STATE,
									AD.ZIPCODE,
									CT.PHONE,
									CT.X_DATEOFBIRTH,
									CT.OBJID CONTACT_ID,
									TXCI.X_PIN,
									WB.X_SECRET_QUESTN X_SECRET_QUESTN,
									WB.X_SECRET_ANS X_SECRET_ANS,
									WB.LOGIN_NAME E_MAIL
								FROM TABLE_WEB_USER WB
									INNER JOIN TABLE_CONTACT CT
									ON WB.WEB_USER2CONTACT = CT.OBJID
									INNER JOIN TABLE_CONTACT_ROLE TR
									ON TR.CONTACT_ROLE2CONTACT = CT.OBJID
									LEFT OUTER JOIN TABLE_SITE TS
									ON TS.OBJID = TR.CONTACT_ROLE2SITE
									LEFT OUTER JOIN TABLE_ADDRESS AD
									ON TS.CUST_PRIMADDR2ADDRESS = AD.OBJID
									INNER JOIN TABLE_X_CONTACT_ADD_INFO TXCI
									ON TXCI.ADD_INFO2CONTACT = CT.OBJID
									WHERE 1=1 AND
									WB.OBJID = i_accountid;

  op_err_num   	:= 0;
  op_err_string := 'SUCCESS';
  op_result 	:= 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
  op_result     := 'ERROR';
  op_err_num    := SQLCODE;
  op_err_string := SQLCODE || SUBSTR (SQLERRM, 1, 100);
END proc_get_acct_detls_by_acctid;
END ma_integration_pkg;
/