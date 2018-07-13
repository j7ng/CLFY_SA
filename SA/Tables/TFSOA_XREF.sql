CREATE TABLE sa.tfsoa_xref (
  auth_auth_response VARCHAR2(60 BYTE) NOT NULL,
  auth_rcode NUMBER,
  auth_rflag VARCHAR2(30 BYTE),
  auth_rmsg VARCHAR2(1000 BYTE),
  ics_rcode NUMBER,
  ics_rflag VARCHAR2(30 BYTE),
  ics_rmsg VARCHAR2(1000 BYTE),
  decission VARCHAR2(4000 BYTE),
  process_type VARCHAR2(20 BYTE) NOT NULL,
  "ENABLE" CHAR DEFAULT 'Y',
  CONSTRAINT tfsoa_xref_auth_response_pk PRIMARY KEY (auth_auth_response,process_type)
);
COMMENT ON TABLE sa.tfsoa_xref IS 'SOA Reference table';
COMMENT ON COLUMN sa.tfsoa_xref.auth_auth_response IS 'Authorization Response code';
COMMENT ON COLUMN sa.tfsoa_xref.auth_rcode IS 'Authorization code';
COMMENT ON COLUMN sa.tfsoa_xref.auth_rflag IS 'Authorization Flag';
COMMENT ON COLUMN sa.tfsoa_xref.auth_rmsg IS 'Authorization Message';
COMMENT ON COLUMN sa.tfsoa_xref.ics_rcode IS 'ICS code';
COMMENT ON COLUMN sa.tfsoa_xref.ics_rflag IS 'ICS Flag';
COMMENT ON COLUMN sa.tfsoa_xref.ics_rmsg IS 'ICS Message';
COMMENT ON COLUMN sa.tfsoa_xref.decission IS 'Decision made for the Autorization';
COMMENT ON COLUMN sa.tfsoa_xref.process_type IS 'Process types';
COMMENT ON COLUMN sa.tfsoa_xref."ENABLE" IS 'Enable flag';