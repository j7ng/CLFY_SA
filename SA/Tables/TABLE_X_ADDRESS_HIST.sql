CREATE TABLE sa.table_x_address_hist (
  objid NUMBER,
  x_old_street VARCHAR2(200 BYTE),
  x_old_city VARCHAR2(30 BYTE),
  x_old_state VARCHAR2(40 BYTE),
  x_old_zip VARCHAR2(10 BYTE),
  x_new_street VARCHAR2(200 BYTE),
  x_new_city VARCHAR2(30 BYTE),
  x_new_state VARCHAR2(40 BYTE),
  x_change_date DATE,
  x_address_type VARCHAR2(30 BYTE),
  x_login_name VARCHAR2(40 BYTE),
  x_new_zip VARCHAR2(10 BYTE),
  x_address_hist2address NUMBER,
  x_address_hist2site NUMBER
);
ALTER TABLE sa.table_x_address_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1634904516_0 (objid, x_address_hist2address, x_address_hist2site, x_address_type, x_change_date, x_login_name, x_new_city, x_new_state, x_new_street, x_new_zip, x_old_city, x_old_state, x_old_street, x_old_zip) ALWAYS;