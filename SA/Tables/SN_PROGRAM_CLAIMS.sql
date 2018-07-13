CREATE TABLE sa.sn_program_claims (
  x_creation_date DATE,
  x_type VARCHAR2(30 BYTE),
  x_status VARCHAR2(20 BYTE),
  x_status_date DATE,
  x_esn VARCHAR2(30 BYTE),
  x_firstname VARCHAR2(30 BYTE),
  x_lastname VARCHAR2(30 BYTE),
  x_address_1 VARCHAR2(200 BYTE),
  x_address_2 VARCHAR2(200 BYTE),
  x_city VARCHAR2(30 BYTE),
  x_state VARCHAR2(40 BYTE),
  x_zipcode VARCHAR2(20 BYTE),
  claim2pgm_enrolled NUMBER(38,10),
  claim2case NUMBER(38,10),
  claim_file_name VARCHAR2(30 BYTE),
  load_date DATE,
  objid NUMBER(38,10),
  x_email_id VARCHAR2(255 BYTE)
);
COMMENT ON TABLE sa.sn_program_claims IS 'THIS TABLE STORES SERVICE NET ACKNOWLEDGEMENTS';
COMMENT ON COLUMN sa.sn_program_claims.x_creation_date IS 'CLAIM CREATION DATE';
COMMENT ON COLUMN sa.sn_program_claims.x_type IS 'CLAIM TYPE';
COMMENT ON COLUMN sa.sn_program_claims.x_status IS 'CLAIM STATUS';
COMMENT ON COLUMN sa.sn_program_claims.x_status_date IS 'CLAIM DATE';
COMMENT ON COLUMN sa.sn_program_claims.x_esn IS 'ESN';
COMMENT ON COLUMN sa.sn_program_claims.x_firstname IS 'FIRST NAME';
COMMENT ON COLUMN sa.sn_program_claims.x_lastname IS 'LAST NAME  ';
COMMENT ON COLUMN sa.sn_program_claims.x_address_1 IS 'ADDRESS LINE ONE';
COMMENT ON COLUMN sa.sn_program_claims.x_address_2 IS 'ADDRESS LINE TWO';
COMMENT ON COLUMN sa.sn_program_claims.x_city IS 'CITY NAME ';
COMMENT ON COLUMN sa.sn_program_claims.x_state IS 'STATE NAME ';
COMMENT ON COLUMN sa.sn_program_claims.x_zipcode IS 'ZIP CODE ';
COMMENT ON COLUMN sa.sn_program_claims.claim2pgm_enrolled IS 'REFERENCE TO X_PROGRAM_ENROLLED.OBJID';
COMMENT ON COLUMN sa.sn_program_claims.claim2case IS 'REFERENCE TO TABLE_CASE OBJID';
COMMENT ON COLUMN sa.sn_program_claims.claim_file_name IS 'CLAIM FILE NAME';
COMMENT ON COLUMN sa.sn_program_claims.load_date IS 'CURRENT DATE';
COMMENT ON COLUMN sa.sn_program_claims.objid IS 'INTERNAL UNIQUE IDENTIFIER';