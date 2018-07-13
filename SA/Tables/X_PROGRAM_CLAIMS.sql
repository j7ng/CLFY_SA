CREATE TABLE sa.x_program_claims (
  objid NUMBER,
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
  claim2pgm_enrolled NUMBER,
  claim2case NUMBER,
  x_email_id VARCHAR2(255 BYTE)
);
COMMENT ON TABLE sa.x_program_claims IS 'HOLDS CUSTOMER CLAIMS SUBMITTED THROUGH OF THIRD PARTY.';
COMMENT ON COLUMN sa.x_program_claims.objid IS 'INTERNAL UNIQUE IDENTIFIER.';
COMMENT ON COLUMN sa.x_program_claims.x_creation_date IS 'CLAIM CREATION DATE';
COMMENT ON COLUMN sa.x_program_claims.x_type IS 'TYPE C -CREATE, U -UPDATE';
COMMENT ON COLUMN sa.x_program_claims.x_status IS 'CLAIM STATUS  (NEW, APPROVED, REJECTED)';
COMMENT ON COLUMN sa.x_program_claims.x_status_date IS 'CLAIM STATUS DATE';
COMMENT ON COLUMN sa.x_program_claims.x_esn IS 'ESN';
COMMENT ON COLUMN sa.x_program_claims.x_firstname IS 'FIRST NAME';
COMMENT ON COLUMN sa.x_program_claims.x_lastname IS 'LAST NAME';
COMMENT ON COLUMN sa.x_program_claims.x_address_1 IS 'ADDRESS 1';
COMMENT ON COLUMN sa.x_program_claims.x_address_2 IS 'ADDRESS 2';
COMMENT ON COLUMN sa.x_program_claims.x_city IS 'CITY';
COMMENT ON COLUMN sa.x_program_claims.x_state IS 'STATE';
COMMENT ON COLUMN sa.x_program_claims.x_zipcode IS 'ZIP';
COMMENT ON COLUMN sa.x_program_claims.claim2pgm_enrolled IS 'REFERENCE TO X_PROGRAM_ENROLLED.OBJID';
COMMENT ON COLUMN sa.x_program_claims.claim2case IS 'REFERENCE TO TABLE_CASE.OBJID';