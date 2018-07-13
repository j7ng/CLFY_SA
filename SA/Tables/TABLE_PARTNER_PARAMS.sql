CREATE TABLE sa.table_partner_params (
  objid NUMBER NOT NULL,
  param_name VARCHAR2(50 BYTE) NOT NULL,
  param_value VARCHAR2(100 BYTE) NOT NULL,
  link_objid NUMBER,
  notes VARCHAR2(1000 BYTE),
  created_date DATE NOT NULL,
  modified_date DATE NOT NULL,
  PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.table_partner_params IS 'Table to maintain different tracfone partners and their parameters';
COMMENT ON COLUMN sa.table_partner_params.objid IS 'Uniquely Identifies the record';
COMMENT ON COLUMN sa.table_partner_params.param_name IS 'Parameter Name';
COMMENT ON COLUMN sa.table_partner_params.param_value IS 'Parameter Value';
COMMENT ON COLUMN sa.table_partner_params.link_objid IS 'Link to the Objid';
COMMENT ON COLUMN sa.table_partner_params.notes IS 'Remarks';