CREATE TABLE sa.table_x_ota_reload_options (
  objid NUMBER,
  dev NUMBER,
  x_ota_feature VARCHAR2(10 BYTE),
  x_ota_opt_handset VARCHAR2(30 BYTE),
  x_ota_opt_access_days NUMBER,
  x_ota_opt_my_date DATE,
  x_ota_opt_date DATE,
  x_ota_esn VARCHAR2(30 BYTE),
  x_ota_recharge_part_number VARCHAR2(30 BYTE),
  x_ota_reload2part_num NUMBER
);
ALTER TABLE sa.table_x_ota_reload_options ADD SUPPLEMENTAL LOG GROUP dmtsora934434894_0 (dev, objid, x_ota_esn, x_ota_feature, x_ota_opt_access_days, x_ota_opt_date, x_ota_opt_handset, x_ota_opt_my_date, x_ota_recharge_part_number, x_ota_reload2part_num) ALWAYS;