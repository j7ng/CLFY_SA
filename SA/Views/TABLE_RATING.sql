CREATE OR REPLACE FORCE VIEW sa.table_rating (objid,rating) AS
select table_prog_logic.objid, table_probdesc.rating
 from table_prog_logic, table_probdesc
 where table_probdesc.objid = table_prog_logic.prog_logic2probdesc
 ;
COMMENT ON TABLE sa.table_rating IS 'Rating of the solution/PD found in scanning. Reserved; not used';
COMMENT ON COLUMN sa.table_rating.objid IS 'Prog logic internal record number';
COMMENT ON COLUMN sa.table_rating.rating IS 'Solution rating';