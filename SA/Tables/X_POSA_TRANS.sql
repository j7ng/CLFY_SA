CREATE TABLE sa.x_posa_trans (
  trans_id VARCHAR2(20 BYTE) NOT NULL,
  trans_date DATE NOT NULL,
  trans_type VARCHAR2(20 BYTE) NOT NULL,
  store_id VARCHAR2(20 BYTE) NOT NULL,
  smp_num VARCHAR2(30 BYTE) NOT NULL
);
ALTER TABLE sa.x_posa_trans ADD SUPPLEMENTAL LOG GROUP dmtsora1750719118_0 (smp_num, store_id, trans_date, trans_id, trans_type) ALWAYS;