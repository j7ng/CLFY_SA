CREATE TABLE sa.table_x_ota_code_hist (
  objid NUMBER,
  dev NUMBER,
  x_transaction_type VARCHAR2(30 BYTE),
  x_code_resent_counter VARCHAR2(10 BYTE),
  x_code_resent_date DATE
);
ALTER TABLE sa.table_x_ota_code_hist ADD SUPPLEMENTAL LOG GROUP dmtsora470619207_0 (dev, objid, x_code_resent_counter, x_code_resent_date, x_transaction_type) ALWAYS;
COMMENT ON TABLE sa.table_x_ota_code_hist IS 'All the codes stored that was sent by OTA for that Handset';
COMMENT ON COLUMN sa.table_x_ota_code_hist.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ota_code_hist.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_ota_code_hist.x_transaction_type IS 'OTA Transaction between Handset & Tracfone System';
COMMENT ON COLUMN sa.table_x_ota_code_hist.x_code_resent_counter IS 'OTA tarnsaction for the same code to Handset';
COMMENT ON COLUMN sa.table_x_ota_code_hist.x_code_resent_date IS 'The date when the code was sent againg using OTA';