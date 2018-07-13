CREATE OR REPLACE FORCE VIEW sa.table_group_view (objid,"NAME",status) AS
select table_group.objid, table_group.name,
 table_group.status
 from table_group;
COMMENT ON TABLE sa.table_group_view IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_group_view.objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_group_view."NAME" IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_group_view.status IS 'Reserved; obsolete';