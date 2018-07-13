CREATE TABLE sa.x_part_inst_ext (
  part_inst_objid NUMBER NOT NULL,
  smp VARCHAR2(30 BYTE),
  brm_service_days NUMBER(3) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  discount_code_list sa.discount_code_tab,
  lifeline_discount_code VARCHAR2(30 BYTE),
  lifeline_discount_amount NUMBER,
  CONSTRAINT pk_part_inst_ext PRIMARY KEY (part_inst_objid)
)
NESTED TABLE discount_code_list STORE AS discount_code_list_nt;
COMMENT ON TABLE sa.x_part_inst_ext IS 'Table to PIN serial numbers and their service days calculated at BRM';
COMMENT ON COLUMN sa.x_part_inst_ext.part_inst_objid IS 'Part instance objid from TABLE_PART_INST';
COMMENT ON COLUMN sa.x_part_inst_ext.smp IS 'PIN serial number from TABLE_PART_INST';
COMMENT ON COLUMN sa.x_part_inst_ext.brm_service_days IS 'Service days calculated by BRM for the PIN';
COMMENT ON COLUMN sa.x_part_inst_ext.discount_code_list IS 'Nested table column to store list of applicable discount codes for a PIN which are sent by BRM';