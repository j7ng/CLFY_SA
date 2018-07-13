CREATE TABLE sa.table_prog_logic (
  objid NUMBER,
  id_number VARCHAR2(32 BYTE),
  description VARCHAR2(255 BYTE),
  is_cmn NUMBER,
  creation_time DATE,
  modify_time DATE,
  dev NUMBER,
  prog_logic2probdesc NUMBER(*,0),
  prog_logic2part_class NUMBER(*,0),
  prog_logic2part_info NUMBER(*,0)
);
ALTER TABLE sa.table_prog_logic ADD SUPPLEMENTAL LOG GROUP dmtsora2088611029_0 (creation_time, description, dev, id_number, is_cmn, modify_time, objid, prog_logic2part_class, prog_logic2part_info, prog_logic2probdesc) ALWAYS;
COMMENT ON TABLE sa.table_prog_logic IS 'Linking device which links cases, diagnostic elements, and their related solutions to one another';
COMMENT ON COLUMN sa.table_prog_logic.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_prog_logic.id_number IS 'Unique ID number for the path; consists of solution-#';
COMMENT ON COLUMN sa.table_prog_logic.description IS 'Description of the path';
COMMENT ON COLUMN sa.table_prog_logic.is_cmn IS 'Reserved; future';
COMMENT ON COLUMN sa.table_prog_logic.creation_time IS 'The date and time the path was created';
COMMENT ON COLUMN sa.table_prog_logic.modify_time IS 'The date and time the logic was modified';
COMMENT ON COLUMN sa.table_prog_logic.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_prog_logic.prog_logic2probdesc IS 'Solution applicable to the logic';
COMMENT ON COLUMN sa.table_prog_logic.prog_logic2part_class IS 'Part class, generic part, related to the logic';
COMMENT ON COLUMN sa.table_prog_logic.prog_logic2part_info IS 'Part revisions on which the logic was defined';