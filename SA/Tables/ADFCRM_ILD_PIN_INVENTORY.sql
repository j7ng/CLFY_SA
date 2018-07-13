CREATE TABLE sa.adfcrm_ild_pin_inventory (
  pin VARCHAR2(30 BYTE) NOT NULL,
  ild_part_objid NUMBER NOT NULL,
  insert_date DATE,
  status VARCHAR2(30 BYTE),
  insert_by VARCHAR2(30 BYTE),
  rqst_esn VARCHAR2(30 BYTE),
  rqst_user VARCHAR2(30 BYTE),
  rqst_date DATE,
  CONSTRAINT adfcrm_ild_inventory_pk PRIMARY KEY (pin),
  CONSTRAINT adfcrm_ild_inventory_fk FOREIGN KEY (ild_part_objid) REFERENCES sa.adfcrm_ild_pin_part_num (objid)
);
COMMENT ON TABLE sa.adfcrm_ild_pin_inventory IS 'ILD 3rd Party PIN Inventory';
COMMENT ON COLUMN sa.adfcrm_ild_pin_inventory.ild_part_objid IS 'External Reference to ADFCRM_ILD_PIN_PART_NUM.OBJID';
COMMENT ON COLUMN sa.adfcrm_ild_pin_inventory.insert_date IS 'Date record was created';
COMMENT ON COLUMN sa.adfcrm_ild_pin_inventory.status IS 'Status of the record';
COMMENT ON COLUMN sa.adfcrm_ild_pin_inventory.insert_by IS 'User Id that created the record.';
COMMENT ON COLUMN sa.adfcrm_ild_pin_inventory.rqst_esn IS 'ESN that requested the PIN';
COMMENT ON COLUMN sa.adfcrm_ild_pin_inventory.rqst_user IS 'User Id that requested the PIN';
COMMENT ON COLUMN sa.adfcrm_ild_pin_inventory.rqst_date IS 'Date PIN was requested';