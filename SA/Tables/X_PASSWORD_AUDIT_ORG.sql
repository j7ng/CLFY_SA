CREATE TABLE sa.x_password_audit_org (
  login_name VARCHAR2(30 BYTE),
  "ACTION" VARCHAR2(20 BYTE),
  date_login DATE,
  "PASSWORD" VARCHAR2(100 BYTE),
  result VARCHAR2(20 BYTE)
);
ALTER TABLE sa.x_password_audit_org ADD SUPPLEMENTAL LOG GROUP dmtsora1979974081_0 ("ACTION", date_login, login_name, "PASSWORD", result) ALWAYS;