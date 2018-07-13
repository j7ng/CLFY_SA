CREATE TABLE sa.x_mvne_partnum_mapping (
  x_mvne_partnum VARCHAR2(100 BYTE),
  x_tf_partnum VARCHAR2(100 BYTE),
  x_price NUMBER(8,2),
  brand VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_mvne_partnum_mapping IS 'mvne part number mapping table';
COMMENT ON COLUMN sa.x_mvne_partnum_mapping.x_mvne_partnum IS 'mvne part number';
COMMENT ON COLUMN sa.x_mvne_partnum_mapping.x_tf_partnum IS 'tracfone part number';
COMMENT ON COLUMN sa.x_mvne_partnum_mapping.x_price IS 'pricing info';