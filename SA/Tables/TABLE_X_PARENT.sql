CREATE TABLE sa.table_x_parent (
  objid NUMBER,
  x_parent_name VARCHAR2(40 BYTE),
  x_parent_id VARCHAR2(30 BYTE),
  x_status VARCHAR2(30 BYTE),
  x_hold_analog_deac NUMBER,
  x_hold_digital_deac NUMBER,
  x_parent2temp_queue NUMBER,
  x_no_inventory NUMBER,
  x_vm_access_num VARCHAR2(20 BYTE),
  x_auto_port_in NUMBER,
  x_auto_port_out NUMBER,
  x_no_msid NUMBER,
  x_ota_carrier VARCHAR2(30 BYTE),
  x_ota_end_date DATE,
  x_ota_psms_address VARCHAR2(30 BYTE),
  x_ota_start_date DATE,
  x_next_available NUMBER,
  x_queue_name VARCHAR2(50 BYTE),
  x_block_port_in NUMBER,
  x_meid_carrier NUMBER,
  x_ota_react NUMBER,
  x_agg_carr_code NUMBER,
  sui_rule_objid NUMBER(22),
  deact_sim_exp_days VARCHAR2(100 BYTE)
);
ALTER TABLE sa.table_x_parent ADD SUPPLEMENTAL LOG GROUP dmtsora512206860_0 (objid, x_auto_port_in, x_auto_port_out, x_block_port_in, x_hold_analog_deac, x_hold_digital_deac, x_meid_carrier, x_next_available, x_no_inventory, x_no_msid, x_ota_carrier, x_ota_end_date, x_ota_psms_address, x_ota_react, x_ota_start_date, x_parent2temp_queue, x_parent_id, x_parent_name, x_queue_name, x_status, x_vm_access_num) ALWAYS;
COMMENT ON TABLE sa.table_x_parent IS 'Contains parent records for carriers and groups';
COMMENT ON COLUMN sa.table_x_parent.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_parent.x_parent_name IS 'Name of carrier parent';
COMMENT ON COLUMN sa.table_x_parent.x_parent_id IS 'TBD';
COMMENT ON COLUMN sa.table_x_parent.x_status IS 'TBD';
COMMENT ON COLUMN sa.table_x_parent.x_hold_analog_deac IS 'Prevent analog deactivations from reaching the carrier';
COMMENT ON COLUMN sa.table_x_parent.x_hold_digital_deac IS 'Prevent digital deactivations from reaching the carrier';
COMMENT ON COLUMN sa.table_x_parent.x_parent2temp_queue IS 'Relation to Temp Queue';
COMMENT ON COLUMN sa.table_x_parent.x_no_inventory IS 'This carrier does not provide reserved inventory, online request is required (0,1)';
COMMENT ON COLUMN sa.table_x_parent.x_vm_access_num IS 'Voice mail access number, it may not be aplicable to all carrier ids under a given parent';
COMMENT ON COLUMN sa.table_x_parent.x_auto_port_in IS 'carrier allows internal automatic port in';
COMMENT ON COLUMN sa.table_x_parent.x_auto_port_out IS 'carrier allows internal automatic port out';
COMMENT ON COLUMN sa.table_x_parent.x_no_msid IS 'This carrier does not provide MSID in advance (0,1)';
COMMENT ON COLUMN sa.table_x_parent.x_ota_carrier IS 'Carrier Eligible for OTA functionality';
COMMENT ON COLUMN sa.table_x_parent.x_ota_end_date IS 'The date when the Over The Air was stopped for this carrier';
COMMENT ON COLUMN sa.table_x_parent.x_ota_psms_address IS 'OTA PSMS address';
COMMENT ON COLUMN sa.table_x_parent.x_ota_start_date IS 'The date when the Over The Air was started for this carrier';
COMMENT ON COLUMN sa.table_x_parent.x_next_available IS '(0,1) next available logic on or off';
COMMENT ON COLUMN sa.table_x_parent.x_queue_name IS 'Queue name for OTA connection';
COMMENT ON COLUMN sa.table_x_parent.x_block_port_in IS 'Block External Port In 0=No, 1=Yes';
COMMENT ON COLUMN sa.table_x_parent.x_meid_carrier IS 'MEID Capable Carrier 0=No, 1=Yes';
COMMENT ON COLUMN sa.table_x_parent.x_ota_react IS 'OTA Reactivation available';