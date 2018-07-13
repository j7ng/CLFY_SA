CREATE OR REPLACE FORCE VIEW sa.table_get_child_site (objid,sub_objid,cloc_id,cname,s_cname,caddress,s_caddress) AS
select table_loc_child.child_site2site, table_loc_child.objid,
 table_loc_child.site_id, table_loc_child.name, table_loc_child.S_name,
 table_address.address, table_address.S_address
 from table_site table_loc_child, table_address
 where table_loc_child.child_site2site IS NOT NULL
 AND table_address.objid = table_loc_child.cust_primaddr2address
 ;
COMMENT ON TABLE sa.table_get_child_site IS 'Contains information on a child site';
COMMENT ON COLUMN sa.table_get_child_site.objid IS 'Parent site internal record number';
COMMENT ON COLUMN sa.table_get_child_site.sub_objid IS 'Child site internal record number';
COMMENT ON COLUMN sa.table_get_child_site.cloc_id IS 'Child site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_get_child_site.cname IS 'Child site name';
COMMENT ON COLUMN sa.table_get_child_site.caddress IS 'Child line 1 of address which includes street number, street name, office, building, or suite number, etc';