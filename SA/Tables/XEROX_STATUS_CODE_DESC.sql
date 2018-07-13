CREATE TABLE sa.xerox_status_code_desc (
  code VARCHAR2(30 BYTE),
  "VALUE" VARCHAR2(330 BYTE),
  "TYPE" VARCHAR2(30 BYTE),
  courtesy_pin VARCHAR2(1 BYTE)
);
COMMENT ON COLUMN sa.xerox_status_code_desc.code IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.xerox_status_code_desc."VALUE" IS 'Descrition of the record';
COMMENT ON COLUMN sa.xerox_status_code_desc."TYPE" IS 'Logical grouping of multiple codes';
COMMENT ON COLUMN sa.xerox_status_code_desc.courtesy_pin IS 'Provide deerolled customer pin';