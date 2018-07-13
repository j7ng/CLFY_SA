CREATE TABLE sa.x_mtm_ct_spr_config (
  objid NUMBER(22) NOT NULL,
  action_type VARCHAR2(20 BYTE) NOT NULL,
  order_type_code VARCHAR2(2 BYTE),
  description VARCHAR2(50 BYTE) NOT NULL,
  comments VARCHAR2(200 BYTE),
  spr_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  pcr_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  upgrade_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  replacement_applicable_flag VARCHAR2(1 BYTE),
  delete_spr_flag VARCHAR2(1 BYTE),
  pir_flag VARCHAR2(1 BYTE),
  create_new_sub_id_flag VARCHAR2(1 BYTE),
  ipi_flag VARCHAR2(1 BYTE),
  epir_flag VARCHAR2(1 BYTE),
  get_case_flag VARCHAR2(1 BYTE),
  minc_flag VARCHAR2(1 BYTE),
  e_flag VARCHAR2(1 BYTE),
  queued_cards_flag VARCHAR2(1 BYTE),
  call_trans_reason VARCHAR2(500 BYTE),
  priority_order NUMBER(1) DEFAULT 1,
  inactive_flag VARCHAR2(1 BYTE) DEFAULT 'Y',
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT x_mtm_ct_spr_config_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_mtm_ct_spr_config IS 'Table to store call trans configuration for spr tables';
COMMENT ON COLUMN sa.x_mtm_ct_spr_config.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.x_mtm_ct_spr_config.action_type IS 'Action Type';
COMMENT ON COLUMN sa.x_mtm_ct_spr_config.order_type_code IS 'Order type code';
COMMENT ON COLUMN sa.x_mtm_ct_spr_config.description IS 'Order type description';
COMMENT ON COLUMN sa.x_mtm_ct_spr_config.comments IS 'Comments';
COMMENT ON COLUMN sa.x_mtm_ct_spr_config.spr_applicable_flag IS 'Flag value for SPR applicable';
COMMENT ON COLUMN sa.x_mtm_ct_spr_config.pcr_applicable_flag IS 'Flag value for PCRF applicable';
COMMENT ON COLUMN sa.x_mtm_ct_spr_config.insert_timestamp IS 'Record Inserted Timestamp';
COMMENT ON COLUMN sa.x_mtm_ct_spr_config.update_timestamp IS 'Record Updated Timestamp';