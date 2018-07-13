CREATE OR REPLACE FORCE VIEW sa.table_loc_to_sub (objid,sub_objid,ploc_id,pname,s_pname,paddress,s_paddress,cloc_id,cname,s_cname,caddress,s_caddress,caddress_objid,paddress_objid) AS
select table_loc_parent.objid, table_loc_child.objid,
 table_loc_parent.site_id, table_loc_parent.name, table_loc_parent.S_name,
 table_parent_addr.address, table_parent_addr.S_address, table_loc_child.site_id,
 table_loc_child.name, table_loc_child.S_name, table_child_addr.address, table_child_addr.S_address,
 table_child_addr.objid, table_parent_addr.objid
 from table_address table_child_addr, table_address table_parent_addr, table_site table_loc_child, table_site table_loc_parent
 where table_loc_parent.objid = table_loc_child.child_site2site
 AND table_child_addr.objid = table_loc_child.cust_primaddr2address
 AND table_parent_addr.objid = table_loc_parent.cust_primaddr2address
 ;
COMMENT ON TABLE sa.table_loc_to_sub IS 'Contains site information for parent/child sites.  Used by forms Site <name> 717, Site Contracts (718), Site Contracts, Site More Info (719)';
COMMENT ON COLUMN sa.table_loc_to_sub.objid IS 'Parent site internal record number';
COMMENT ON COLUMN sa.table_loc_to_sub.sub_objid IS 'Child site internal record number';
COMMENT ON COLUMN sa.table_loc_to_sub.ploc_id IS 'Parent site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_loc_to_sub.pname IS 'Parent site name';
COMMENT ON COLUMN sa.table_loc_to_sub.paddress IS 'Parent site line 1 of address which includes street number, street name, office, building, or suite number, etc';
COMMENT ON COLUMN sa.table_loc_to_sub.cloc_id IS 'Child site ID number assigned according to auto-numbering definition. Parent site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_loc_to_sub.cname IS 'Child site name';
COMMENT ON COLUMN sa.table_loc_to_sub.caddress IS 'Child site line 1 of address which includes street number, street name, office, building, or suite number, etc';
COMMENT ON COLUMN sa.table_loc_to_sub.caddress_objid IS 'Child_addr internal record number';
COMMENT ON COLUMN sa.table_loc_to_sub.paddress_objid IS 'Parent_addr internal record number';