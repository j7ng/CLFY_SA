CREATE TABLE sa.eg_cdma37 (
  objid NUMBER,
  part_serial_no VARCHAR2(30 BYTE),
  warr_end_date DATE,
  x_part_inst_status VARCHAR2(20 BYTE),
  status2x_code_table NUMBER,
  part_to_esn2part_inst NUMBER,
  x_domain VARCHAR2(20 BYTE),
  x_carrier_id NUMBER,
  x_parent_name VARCHAR2(40 BYTE)
);
ALTER TABLE sa.eg_cdma37 ADD SUPPLEMENTAL LOG GROUP dmtsora1987085534_0 (objid, part_serial_no, part_to_esn2part_inst, status2x_code_table, warr_end_date, x_carrier_id, x_domain, x_parent_name, x_part_inst_status) ALWAYS;