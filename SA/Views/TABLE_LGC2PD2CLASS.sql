CREATE OR REPLACE FORCE VIEW sa.table_lgc2pd2class (objid,pd_objid,lgc_number,lgc_desc,"NAME",pmh_objid) AS
select table_prog_logic.objid, table_prog_logic.prog_logic2probdesc,
 table_prog_logic.id_number, table_prog_logic.description,
 table_part_class.name, table_part_class.objid
 from table_prog_logic, table_part_class
 where table_prog_logic.prog_logic2probdesc IS NOT NULL
 AND table_part_class.objid = table_prog_logic.prog_logic2part_class
 ;
COMMENT ON TABLE sa.table_lgc2pd2class IS 'Solution path/logic, with its solution/PD, and Class. Reserved; not used';
COMMENT ON COLUMN sa.table_lgc2pd2class.objid IS 'Prog logic internal record number';
COMMENT ON COLUMN sa.table_lgc2pd2class.pd_objid IS 'Probdesc internal record number';
COMMENT ON COLUMN sa.table_lgc2pd2class.lgc_number IS 'Prog logic internal record number';
COMMENT ON COLUMN sa.table_lgc2pd2class.lgc_desc IS 'Description of the path';
COMMENT ON COLUMN sa.table_lgc2pd2class."NAME" IS 'A unique name for the part class';
COMMENT ON COLUMN sa.table_lgc2pd2class.pmh_objid IS 'Part class internal record number';