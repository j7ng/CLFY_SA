CREATE TABLE sa.table_x79tr_number (
  objid NUMBER,
  dev NUMBER,
  tr_rpt_id VARCHAR2(64 BYTE),
  s_tr_rpt_id VARCHAR2(64 BYTE),
  server_id NUMBER,
  tr_number2x79telcom_tr NUMBER,
  pt_nmb2x79provider_tr NUMBER
);
ALTER TABLE sa.table_x79tr_number ADD SUPPLEMENTAL LOG GROUP dmtsora2017009422_0 (dev, objid, pt_nmb2x79provider_tr, server_id, s_tr_rpt_id, tr_number2x79telcom_tr, tr_rpt_id) ALWAYS;