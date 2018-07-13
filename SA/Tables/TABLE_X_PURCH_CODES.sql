CREATE TABLE sa.table_x_purch_codes (
  objid NUMBER,
  x_app VARCHAR2(20 BYTE),
  x_code_type VARCHAR2(20 BYTE),
  x_code_value VARCHAR2(20 BYTE),
  x_code_num VARCHAR2(20 BYTE),
  x_code_descr VARCHAR2(172 BYTE),
  x_internal_doc VARCHAR2(80 BYTE),
  x_language VARCHAR2(12 BYTE),
  x_auth_response VARCHAR2(300 BYTE),
  x_ics_rcode VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_purch_codes ADD SUPPLEMENTAL LOG GROUP dmtsora337834100_0 (objid, x_app, x_code_descr, x_code_num, x_code_type, x_code_value, x_internal_doc, x_language) ALWAYS;
COMMENT ON TABLE sa.table_x_purch_codes IS 'translates a variety of credit-card-purchase interface codes';
COMMENT ON COLUMN sa.table_x_purch_codes.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_purch_codes.x_app IS 'application that uses the codes - eg:  CyberSource Purchases';
COMMENT ON COLUMN sa.table_x_purch_codes.x_code_type IS 'name of the code set being translated;  eg rflag, score_factors, score_host_severity etc';
COMMENT ON COLUMN sa.table_x_purch_codes.x_code_value IS 'value of the code eg:  DAVSNO';
COMMENT ON COLUMN sa.table_x_purch_codes.x_code_num IS 'this will be Topp s error code number returned to the calling app';
COMMENT ON COLUMN sa.table_x_purch_codes.x_code_descr IS 'This is the error message we return to the Topp user eg Address Validation Failed';
COMMENT ON COLUMN sa.table_x_purch_codes.x_internal_doc IS 'Internal documentation of the error - not displayed to the user';
COMMENT ON COLUMN sa.table_x_purch_codes.x_language IS 'language description';