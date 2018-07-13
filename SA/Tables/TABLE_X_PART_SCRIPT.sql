CREATE TABLE sa.table_x_part_script (
  objid NUMBER,
  part_script2part_num NUMBER,
  x_script_text LONG,
  x_sequence NUMBER,
  x_type VARCHAR2(30 BYTE),
  x_language VARCHAR2(12 BYTE),
  x_script_id NUMBER
);
ALTER TABLE sa.table_x_part_script ADD SUPPLEMENTAL LOG GROUP dmtsora1421132784_0 (objid, part_script2part_num, x_language, x_script_id, x_sequence, x_type) ALWAYS;