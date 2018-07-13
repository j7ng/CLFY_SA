CREATE TABLE sa.table_csc_feature (
  objid NUMBER,
  description VARCHAR2(80 BYTE),
  prompt VARCHAR2(255 BYTE),
  valid_values VARCHAR2(255 BYTE),
  "COST" NUMBER,
  data_type NUMBER,
  server_id NUMBER,
  dev NUMBER,
  feature2csc_admin NUMBER(*,0),
  feature2csc_statement NUMBER(*,0)
);
ALTER TABLE sa.table_csc_feature ADD SUPPLEMENTAL LOG GROUP dmtsora1695216389_0 ("COST", data_type, description, dev, feature2csc_admin, feature2csc_statement, objid, prompt, server_id, valid_values) ALWAYS;