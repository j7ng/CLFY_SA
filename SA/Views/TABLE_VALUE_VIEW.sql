CREATE OR REPLACE FORCE VIEW sa.table_value_view (objid,"VALUE",control_id) AS
select table_value_item.objid, table_value_item.value1,
 table_value_item.value2control_db
 from table_value_item
 where table_value_item.value2control_db IS NOT NULL
 ;
COMMENT ON TABLE sa.table_value_view IS 'Indexed by value_item';
COMMENT ON COLUMN sa.table_value_view.objid IS 'Value item internal control number';
COMMENT ON COLUMN sa.table_value_view."VALUE" IS 'Multi-purpose integer attribute; use depends on type of the control that owns the item';
COMMENT ON COLUMN sa.table_value_view.control_id IS 'Control db internal record number';