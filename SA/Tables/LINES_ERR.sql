CREATE TABLE sa.lines_err (
  s_x_insert_date DATE,
  s_x_sequence NUMBER(7),
  s_x_creation_date DATE,
  s_x_created_by2user VARCHAR2(30 BYTE),
  s_x_po_num VARCHAR2(25 BYTE),
  s_x_red_code NUMBER(20),
  s_x_warr_end_date DATE,
  s_x_npa VARCHAR2(20 BYTE),
  s_x_nxx VARCHAR2(20 BYTE),
  s_x_ext VARCHAR2(20 BYTE),
  part_inst2inv_bin VARCHAR2(38 BYTE),
  s_part_serial_no VARCHAR2(30 BYTE),
  s_part_status VARCHAR2(40 BYTE),
  s_x_pi_status VARCHAR2(40 BYTE),
  part_inst2carrier_mkt VARCHAR2(38 BYTE),
  s_x_deactivation_flag NUMBER(1),
  s_x_reactivation_flag NUMBER(1),
  s_x_cool_end_date DATE,
  s_description VARCHAR2(255 BYTE),
  s_part_number VARCHAR2(30 BYTE),
  s_active VARCHAR2(20 BYTE),
  error_text VARCHAR2(2000 BYTE)
);
ALTER TABLE sa.lines_err ADD SUPPLEMENTAL LOG GROUP dmtsora724817911_0 (error_text, part_inst2carrier_mkt, part_inst2inv_bin, s_active, s_description, s_part_number, s_part_serial_no, s_part_status, s_x_cool_end_date, s_x_created_by2user, s_x_creation_date, s_x_deactivation_flag, s_x_ext, s_x_insert_date, s_x_npa, s_x_nxx, s_x_pi_status, s_x_po_num, s_x_reactivation_flag, s_x_red_code, s_x_sequence, s_x_warr_end_date) ALWAYS;