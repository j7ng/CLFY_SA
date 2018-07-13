CREATE TABLE sa.table_x_password_hist (
  objid NUMBER,
  dev NUMBER,
  x_password_hist VARCHAR2(30 BYTE),
  x_password_chg DATE,
  x_login_name VARCHAR2(30 BYTE),
  s_x_login_name VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_password_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1757640123_0 (dev, objid, s_x_login_name, x_login_name, x_password_chg, x_password_hist) ALWAYS;