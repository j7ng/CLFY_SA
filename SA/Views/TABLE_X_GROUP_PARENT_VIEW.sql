CREATE OR REPLACE FORCE VIEW sa.table_x_group_parent_view (objid,x_carrier_group_id,x_carrier_name,x_parent_objid,x_parent_name,x_parent_id,x_parent_x_status,x_carrier_group_x_status) AS
select table_x_carrier_group.objid, table_x_carrier_group.x_carrier_group_id,
 table_x_carrier_group.x_carrier_name, table_x_parent.objid,
 table_x_parent.x_parent_name, table_x_parent.x_parent_id,
 table_x_parent.x_status, table_x_carrier_group.x_status
 from table_x_carrier_group, table_x_parent
 where table_x_parent.objid (+) = table_x_carrier_group.x_carrier_group2x_parent
 ;