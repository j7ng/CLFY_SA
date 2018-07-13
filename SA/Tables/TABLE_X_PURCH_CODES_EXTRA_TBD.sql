CREATE TABLE sa.table_x_purch_codes_extra_tbd (
  objid NUMBER NOT NULL,
  purch_extra2purch_code NUMBER,
  x_script_id VARCHAR2(100 BYTE),
  x_ics_rcode VARCHAR2(30 BYTE),
  x_auth_response VARCHAR2(300 BYTE),
  CONSTRAINT pcdid PRIMARY KEY (objid),
  CONSTRAINT purch_code_extra_unique UNIQUE (purch_extra2purch_code,x_script_id,x_ics_rcode,x_auth_response)
);
COMMENT ON TABLE sa.table_x_purch_codes_extra_tbd IS 'DETAILS FOR PURCHASE CODE FROM TABLE_X_PURCH_CODES';
COMMENT ON COLUMN sa.table_x_purch_codes_extra_tbd.objid IS 'INTERNAL UNIQUE IDENTIFIER FROM SEQUENCE SEQ_X_PURCH_CODES_EXTRA';
COMMENT ON COLUMN sa.table_x_purch_codes_extra_tbd.purch_extra2purch_code IS 'REFERENCE TO OBJID OF THE MASTER TABLE TABLE_X_PURCH_CODES';
COMMENT ON COLUMN sa.table_x_purch_codes_extra_tbd.x_script_id IS 'SCRIPT ID FOR THE CODE';
COMMENT ON COLUMN sa.table_x_purch_codes_extra_tbd.x_ics_rcode IS 'ICS RESPONSE CODE';
COMMENT ON COLUMN sa.table_x_purch_codes_extra_tbd.x_auth_response IS 'AUTHORIZATION RESPONSE CODE';