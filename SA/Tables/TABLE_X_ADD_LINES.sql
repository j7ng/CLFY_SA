CREATE TABLE sa.table_x_add_lines (
  objid NUMBER,
  x_npa VARCHAR2(3 BYTE),
  x_nxx VARCHAR2(3 BYTE),
  x_add_lines2x_carrier NUMBER
);
ALTER TABLE sa.table_x_add_lines ADD SUPPLEMENTAL LOG GROUP dmtsora2022998461_0 (objid, x_add_lines2x_carrier, x_npa, x_nxx) ALWAYS;
COMMENT ON TABLE sa.table_x_add_lines IS 'Contains the NPA/NXX Values for carriers';
COMMENT ON COLUMN sa.table_x_add_lines.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_add_lines.x_npa IS 'TBD';
COMMENT ON COLUMN sa.table_x_add_lines.x_nxx IS 'TBD';