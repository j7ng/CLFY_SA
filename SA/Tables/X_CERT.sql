CREATE TABLE sa.x_cert (
  objid NUMBER,
  x_cert VARCHAR2(64 BYTE),
  x_key_algo VARCHAR2(128 BYTE),
  x_cc_algo VARCHAR2(128 BYTE),
  create_date TIMESTAMP,
  notes VARCHAR2(255 BYTE)
);
COMMENT ON TABLE sa.x_cert IS 'Cybersource Security Certificate Entries';
COMMENT ON COLUMN sa.x_cert.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_cert.x_cert IS 'Certificate';
COMMENT ON COLUMN sa.x_cert.x_key_algo IS 'KEY ALGO';
COMMENT ON COLUMN sa.x_cert.x_cc_algo IS 'Credit Card ALGO';
COMMENT ON COLUMN sa.x_cert.create_date IS 'Creation Timestamp';
COMMENT ON COLUMN sa.x_cert.notes IS 'Notes, Remarks';