CREATE TABLE sa.table_site_part (
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
  site_part2x_plan NUMBER,
  x_msid VARCHAR2(30 BYTE),
  x_refurb_flag NUMBER,
  cmmtmnt_end_dt DATE,
  instance_id VARCHAR2(30 BYTE),
  site_part_ind NUMBER,
  status_dt DATE,
  x_iccid VARCHAR2(30 BYTE),
  x_actual_expire_dt DATE,
  update_stamp DATE
);
ALTER TABLE sa.table_site_part ADD SUPPLEMENTAL LOG GROUP dmtsora1600061515_1 (all_site_part2site, cmmtmnt_end_dt, instance_id, site_part2backup, site_part2part_detail, site_part2part_info, site_part2primary, site_part2productbin, site_part2site, site_part2site_part, site_part2x_new_plan, site_part2x_plan, site_part_ind, status_dt, x_iccid, x_msid, x_refurb_flag) ALWAYS;
ALTER TABLE sa.table_site_part ADD SUPPLEMENTAL LOG GROUP dmtsora1092409398_0 (bin_objid, comments, dev, dir_site_objid, install_date, instance_name, inst_objid, invoice_no, level_to_bin, level_to_part, machine_id, mdbk, modified, objid, part_status, quantity, selected_prd, serial_no, service_end_dt, ship_date, site_objid, state_code, state_value, s_serial_no, warranty_date, x_deact_reason, x_expire_dt, x_min, x_min_change_flag, x_notify_carrier, x_pin, x_service_id, x_zipcode) ALWAYS;
ALTER TABLE sa.table_site_part ADD SUPPLEMENTAL LOG GROUP dmtsora1092409398_1 (all_site_part2site, cmmtmnt_end_dt, instance_id, site_part2backup, site_part2part_detail, site_part2part_info, site_part2primary, site_part2productbin, site_part2site, site_part2site_part, site_part2x_new_plan, site_part2x_plan, site_part_ind, status_dt, x_iccid, x_msid, x_refurb_flag) ALWAYS;
COMMENT ON TABLE sa.table_site_part IS 'Defines an instance of an installed part to the system. See part_inst for instances of inventory parts';
COMMENT ON COLUMN sa.table_site_part.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_site_part.instance_name IS 'Default is the concatination of part name, part number, and part revision. May be customized';
COMMENT ON COLUMN sa.table_site_part.serial_no IS 'Installed part serial number';
COMMENT ON COLUMN sa.table_site_part.invoice_no IS 'Installed part invoice number';
COMMENT ON COLUMN sa.table_site_part.ship_date IS 'Installed part ship date';
COMMENT ON COLUMN sa.table_site_part.install_date IS 'Part installation date';
COMMENT ON COLUMN sa.table_site_part.warranty_date IS 'Installed part warranty end date';
COMMENT ON COLUMN sa.table_site_part.quantity IS 'Installed part quantity; equal to 1 for serialized parts';
COMMENT ON COLUMN sa.table_site_part.mdbk IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site_part.state_code IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site_part.state_value IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site_part.modified IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site_part.level_to_part IS 'Relative installation hierarchy level to a part';
COMMENT ON COLUMN sa.table_site_part.selected_prd IS 'Selected product';
COMMENT ON COLUMN sa.table_site_part.part_status IS 'Site Configuration installed part status. This is a user-defined popup with default name PART_STATUS';
COMMENT ON COLUMN sa.table_site_part.comments IS 'Installed part comment';
COMMENT ON COLUMN sa.table_site_part.level_to_bin IS 'Relative level to a bin';
COMMENT ON COLUMN sa.table_site_part.bin_objid IS 'Productbin internal object number';
COMMENT ON COLUMN sa.table_site_part.site_objid IS 'Site objid';
COMMENT ON COLUMN sa.table_site_part.inst_objid IS 'Objid of parent-installed part in the part s BOM';
COMMENT ON COLUMN sa.table_site_part.dir_site_objid IS 'Site at which the part is installed. Derived from all_site_part2site. Not applicable to parts installed at more than one site';
COMMENT ON COLUMN sa.table_site_part.machine_id IS 'Parent site_part machine ID. Used for SMS compare';
COMMENT ON COLUMN sa.table_site_part.service_end_dt IS 'Last day part was/will be in service';
COMMENT ON COLUMN sa.table_site_part.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_site_part.x_service_id IS 'Serial Number of the Phone for Wireless or Service Id for Wireline';
COMMENT ON COLUMN sa.table_site_part.x_min IS 'Line Number/Phone Number';
COMMENT ON COLUMN sa.table_site_part.x_pin IS 'Personal Identification Number given by Manufacturer';
COMMENT ON COLUMN sa.table_site_part.x_deact_reason IS 'Deactivation Reason';
COMMENT ON COLUMN sa.table_site_part.x_min_change_flag IS 'Flag used to denote that the user needs a MIN Change due to Fraud or Area Code Change: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_site_part.x_notify_carrier IS 'Flag to notify carrier during deactivation: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_site_part.x_expire_dt IS 'Last day part was/will be in service';
COMMENT ON COLUMN sa.table_site_part.x_zipcode IS 'Zipcode';
COMMENT ON COLUMN sa.table_site_part.site_part2productbin IS 'Bin in which the part resides';
COMMENT ON COLUMN sa.table_site_part.site_part2site IS 'For top-level parts in a configuration only; indicates the site at which they are located';
COMMENT ON COLUMN sa.table_site_part.site_part2site_part IS 'Relation to another installed part as part of part hierarchy; this is the parent relation';
COMMENT ON COLUMN sa.table_site_part.site_part2part_info IS 'Part revision of the installed part';
COMMENT ON COLUMN sa.table_site_part.site_part2primary IS 'Primary employee';
COMMENT ON COLUMN sa.table_site_part.site_part2backup IS 'Backup employee';
COMMENT ON COLUMN sa.table_site_part.all_site_part2site IS 'Indicates the site at which the part is installed';
COMMENT ON COLUMN sa.table_site_part.site_part2part_detail IS 'System management detail for the part';
COMMENT ON COLUMN sa.table_site_part.site_part2x_new_plan IS 'Site Part to Click Plan';
COMMENT ON COLUMN sa.table_site_part.site_part2x_plan IS 'Site Part to Click Plan';
COMMENT ON COLUMN sa.table_site_part.x_msid IS 'MSID';
COMMENT ON COLUMN sa.table_site_part.x_refurb_flag IS '0 - No, 1 - Yes';
COMMENT ON COLUMN sa.table_site_part.cmmtmnt_end_dt IS 'Installed part s service commitment end date';
COMMENT ON COLUMN sa.table_site_part.instance_id IS 'Installed part unique instnace id';
COMMENT ON COLUMN sa.table_site_part.site_part_ind IS 'Used for read-only installed part';
COMMENT ON COLUMN sa.table_site_part.status_dt IS 'Date on which subscriber status changed';
COMMENT ON COLUMN sa.table_site_part.x_iccid IS 'SIM Serial Number';
COMMENT ON COLUMN sa.table_site_part.x_actual_expire_dt IS 'Actual Expiry Date';