CREATE TABLE sa.table_x_script_controls (
  objid NUMBER,
  x_control_status NUMBER,
  x_control_input VARCHAR2(30 BYTE),
  x_control_label VARCHAR2(30 BYTE),
  x_control_type VARCHAR2(255 BYTE),
  x_scr_control2script_qstn NUMBER
);
ALTER TABLE sa.table_x_script_controls ADD SUPPLEMENTAL LOG GROUP dmtsora1303933609_0 (objid, x_control_input, x_control_label, x_control_status, x_control_type, x_scr_control2script_qstn) ALWAYS;