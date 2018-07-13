CREATE TABLE sa.x_nnsp_mapping (
  "ID" VARCHAR2(30 BYTE),
  description VARCHAR2(100 BYTE)
);
COMMENT ON COLUMN sa.x_nnsp_mapping."ID" IS 'New Service Provider code';
COMMENT ON COLUMN sa.x_nnsp_mapping.description IS 'New Service Provider code Description';