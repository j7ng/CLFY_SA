CREATE TABLE sa.x_posa_lite_trans (
  trans_id VARCHAR2(30 BYTE) NOT NULL,
  trans_date VARCHAR2(10 BYTE),
  trans_type VARCHAR2(20 BYTE),
  store_id VARCHAR2(20 BYTE),
  smp_num VARCHAR2(30 BYTE),
  acc_code VARCHAR2(10 BYTE),
  auth_code VARCHAR2(10 BYTE),
  reg_num VARCHAR2(10 BYTE),
  esn_num VARCHAR2(20 BYTE),
  upc VARCHAR2(13 BYTE),
  merchant_id VARCHAR2(30 BYTE),
  status_code VARCHAR2(4 BYTE)
);
ALTER TABLE sa.x_posa_lite_trans ADD SUPPLEMENTAL LOG GROUP dmtsora1069832596_0 (acc_code, auth_code, esn_num, merchant_id, reg_num, smp_num, status_code, store_id, trans_date, trans_id, trans_type, upc) ALWAYS;