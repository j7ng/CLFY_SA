CREATE TABLE sa.x_password_audit (
  login_name VARCHAR2(30 BYTE),
  "ACTION" VARCHAR2(20 BYTE),
  date_login DATE,
  "PASSWORD" VARCHAR2(100 BYTE),
  result VARCHAR2(20 BYTE)
);
ALTER TABLE sa.x_password_audit ADD SUPPLEMENTAL LOG GROUP dmtsora1174656678_0 ("ACTION", date_login, login_name, "PASSWORD", result) ALWAYS;