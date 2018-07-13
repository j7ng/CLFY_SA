CREATE OR REPLACE FORCE VIEW sa.table_scn_finale (objid,title,s_title,rating) AS
select table_probdesc.objid, table_probdesc.title, table_probdesc.S_title,
 table_probdesc.rating
 from table_probdesc;
COMMENT ON TABLE sa.table_scn_finale IS 'Selects solutions';
COMMENT ON COLUMN sa.table_scn_finale.objid IS 'Solution object ID number';
COMMENT ON COLUMN sa.table_scn_finale.title IS 'Solution title';
COMMENT ON COLUMN sa.table_scn_finale.rating IS 'Solution rating';