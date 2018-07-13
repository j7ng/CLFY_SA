CREATE OR REPLACE FORCE VIEW sa.table_ripelm_subcase (rip_objid,elm_objid,id_number,title,s_title) AS
select table_subcase.subc_rip2ripbin, table_subcase.objid,
 table_subcase.id_number, table_subcase.title, table_subcase.S_title
 from table_subcase
 where table_subcase.subc_rip2ripbin IS NOT NULL
 ;
COMMENT ON TABLE sa.table_ripelm_subcase IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripelm_subcase.rip_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripelm_subcase.elm_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripelm_subcase.id_number IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripelm_subcase.title IS 'Reserved; obsolete';