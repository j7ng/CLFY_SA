CREATE OR REPLACE FORCE VIEW sa.table_ripelm_bug (rip_objid,elm_objid,id_number,title,s_title) AS
select table_bug.bug_rip2ripbin, table_bug.objid,
 table_bug.id_number, table_bug.title, table_bug.S_title
 from table_bug
 where table_bug.bug_rip2ripbin IS NOT NULL
 ;
COMMENT ON TABLE sa.table_ripelm_bug IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripelm_bug.rip_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripelm_bug.elm_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripelm_bug.id_number IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripelm_bug.title IS 'Reserved; obsolete';