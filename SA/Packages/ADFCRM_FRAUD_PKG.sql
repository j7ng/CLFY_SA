CREATE OR REPLACE PACKAGE sa."ADFCRM_FRAUD_PKG"
AS
  /* TODO enter package declarations (types, exceptions, methods etc) here */
FUNCTION cancel_risk_alerts(
    ip_user_objid NUMBER,
    ip_esn_objid  NUMBER)
  RETURN VARCHAR2;
FUNCTION create_risk_alerts(
    ip_user_objid NUMBER,
    ip_esn_objid  NUMBER)
  RETURN VARCHAR2;
FUNCTION create_risk_alerts2(
    ip_user_objid NUMBER,
    ip_esn        VARCHAR2)
RETURN VARCHAR2;
FUNCTION set_status_risk_assessment(
    ip_esn        VARCHAR2,
    ip_user_objid VARCHAR2)
  RETURN VARCHAR2;
FUNCTION set_status_used(
    ip_esn          VARCHAR2,
    ip_user_objid   VARCHAR2,
    ip_zero_out_max VARCHAR2)
  RETURN VARCHAR2;
FUNCTION clear_time_tank(
    ip_esn          VARCHAR2,
    ip_user_objid   VARCHAR2)
  RETURN VARCHAR2;
FUNCTION create_ttv(
    ip_esn          VARCHAR2,
    ip_user_objid   VARCHAR2)
  RETURN VARCHAR2;
  END ADFCRM_FRAUD_PKG;
/