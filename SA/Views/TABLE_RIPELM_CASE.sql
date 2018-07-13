CREATE OR REPLACE FORCE VIEW sa.table_ripelm_case (rip_objid,elm_objid,id_number,title,s_title) AS
select table_case.case_rip2ripbin, table_case.objid,
 table_case.id_number, table_case.title, table_case.S_title
 from table_case
 where table_case.case_rip2ripbin IS NOT NULL
 ;
COMMENT ON TABLE sa.table_ripelm_case IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripelm_case.rip_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripelm_case.elm_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripelm_case.id_number IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripelm_case.title IS 'Reserved; obsolete';