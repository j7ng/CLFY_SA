CREATE TABLE sa.adfcrm_ild_pin_part_num (
  objid NUMBER NOT NULL,
  description VARCHAR2(255 BYTE) NOT NULL,
  target_system VARCHAR2(30 BYTE) NOT NULL,
  org_id VARCHAR2(30 BYTE) NOT NULL,
  CONSTRAINT adfcrm_ild_part_num_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.adfcrm_ild_pin_part_num IS 'ILD 3rd Party PIN Part Numbers';
COMMENT ON COLUMN sa.adfcrm_ild_pin_part_num.objid IS 'Internal unique identifier for records in ADFCRM_ILD_PIN_PART_NUM.';
COMMENT ON COLUMN sa.adfcrm_ild_pin_part_num.description IS 'ILD PIN Description';
COMMENT ON COLUMN sa.adfcrm_ild_pin_part_num.target_system IS 'System that uses the part number';
COMMENT ON COLUMN sa.adfcrm_ild_pin_part_num.org_id IS 'Brand that uses the part number';