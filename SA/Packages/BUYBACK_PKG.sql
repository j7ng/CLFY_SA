CREATE OR REPLACE PACKAGE sa.BUYBACK_PKG AS

  FUNCTION FN_GET_ACTIVE_DAYS_BY_ESN(IP_ESN IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION FN_GET_REDEM_PAID_DAYS_BY_ESN(IP_ESN IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION FN_GET_AR_PAID_DAYS_BY_ESN(IP_ESN IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION FN_GET_PAID_DAYS_BY_ESN(IP_ESN IN VARCHAR2) RETURN VARCHAR2;

END BUYBACK_PKG;
/