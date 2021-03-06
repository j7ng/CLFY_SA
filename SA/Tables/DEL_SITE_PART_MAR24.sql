CREATE TABLE sa.del_site_part_mar24 (
  objid NUMBER,
  instance_name VARCHAR2(80 BYTE),
  serial_no VARCHAR2(30 BYTE),
  s_serial_no VARCHAR2(30 BYTE),
  invoice_no VARCHAR2(30 BYTE),
  ship_date DATE,
  install_date DATE,
  warranty_date DATE,
  quantity NUMBER,
  mdbk VARCHAR2(80 BYTE),
  state_code NUMBER,
  state_value VARCHAR2(20 BYTE),
  modified NUMBER,
  level_to_part NUMBER,
  selected_prd VARCHAR2(5 BYTE),
  part_status VARCHAR2(40 BYTE),
  comments VARCHAR2(255 BYTE),
  level_to_bin NUMBER,
  bin_objid NUMBER,
  site_objid NUMBER,
  inst_objid NUMBER,
  dir_site_objid NUMBER,
  machine_id VARCHAR2(80 BYTE),
  service_end_dt DATE,
  dev NUMBER,
  x_service_id VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_pin VARCHAR2(20 BYTE),
  x_deact_reason VARCHAR2(30 BYTE),
  x_min_change_flag NUMBER,
  x_notify_carrier NUMBER,
  x_expire_dt DATE,
  x_zipcode VARCHAR2(20 BYTE),
  site_part2productbin NUMBER,
  site_part2site NUMBER,
  site_part2site_part NUMBER,
  site_part2part_info NUMBER,
  site_part2primary NUMBER,
  site_part2backup NUMBER,
  all_site_part2site NUMBER,
  site_part2part_detail NUMBER,
  site_part2x_new_plan NUMBER,
  site_part2x_plan NUMBER
);