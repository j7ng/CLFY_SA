CREATE OR REPLACE PACKAGE sa.MA_INTEGRATION_PKG
AS
  /* TODO enter package declarations (types, exceptions, methods etc) here */
  PROCEDURE PROC_GET_ACCT_DETLS_BY_ACCTID(
      i_accountid IN TABLE_WEB_USER.OBJID%TYPE,
      OP_ERR_NUM OUT NUMBER,
      OP_ERR_STRING OUT VARCHAR2,
      OP_RESULT OUT VARCHAR2,
      OP_accountDetails OUT sys_refcursor);
END MA_INTEGRATION_PKG;
/