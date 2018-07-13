CREATE OR REPLACE FORCE VIEW sa.table_locatn_view (loc_objid,location_name,location_descr,location_type,site_id,site_name,s_site_name,site_objid,reports_to_loc,role_name,gl_acct_no,inv_class,mdbk,"RANK",site_type,region,s_region,address,s_address,city,s_city,"STATE",s_state,zip,"ACTIVE") AS
select table_inv_locatn.objid, table_inv_locatn.location_name,
 table_inv_locatn.location_descr, table_inv_locatn.location_type,
 table_site.site_id, table_site.name, table_site.S_name,
 table_site.objid, table_inv_locatn.reports_to_loc,
 table_inv_role.role_name, table_inv_locatn.gl_acct_no,
 table_inv_locatn.inv_class, table_site.mdbk,
 table_inv_role.rank, table_site.site_type,
 table_site.region, table_site.S_region, table_address.address, table_address.S_address,
 table_address.city, table_address.S_city, table_address.state, table_address.S_state,
 table_address.zipcode, table_inv_locatn.active
 from table_inv_locatn, table_site, table_inv_role,
  table_address
 where table_inv_locatn.objid = table_inv_role.inv_role2inv_locatn
 AND table_site.objid = table_inv_role.inv_role2site
 AND table_address.objid = table_site.cust_primaddr2address
 ;
COMMENT ON TABLE sa.table_locatn_view IS 'Used by the Select Accounts and Locations form (515), Part Stocking Levels (517), Servicing Locations for Site (8418), Serv Sites for Location (8419) and Inventory Location Rollups (8431)';
COMMENT ON COLUMN sa.table_locatn_view.loc_objid IS 'Inventory location internal record number';
COMMENT ON COLUMN sa.table_locatn_view.location_name IS 'For physical inventory locations, the name of the location. For GL accounts, the account number';
COMMENT ON COLUMN sa.table_locatn_view.location_descr IS 'Description of the inventory location or GL account';
COMMENT ON COLUMN sa.table_locatn_view.location_type IS 'User-defined types of physical inventory location';
COMMENT ON COLUMN sa.table_locatn_view.site_id IS 'Site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_locatn_view.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_locatn_view.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_locatn_view.reports_to_loc IS 'The parent inventory location name or, if GL account, the parent GL account number';
COMMENT ON COLUMN sa.table_locatn_view.role_name IS 'Name of the inventory role';
COMMENT ON COLUMN sa.table_locatn_view.gl_acct_no IS 'If the current object is a physical location, the GL account number. If a GL account, the field is either empty, or contains the parent GL account number';
COMMENT ON COLUMN sa.table_locatn_view.inv_class IS '0=inventory location, 1=capital GL account, 2=expense GL account';
COMMENT ON COLUMN sa.table_locatn_view.mdbk IS 'Used, transiently, to hold the translation of inv_class';
COMMENT ON COLUMN sa.table_locatn_view."RANK" IS 'For servicing inventory locations, ranks the order in which locations should be displayed for a given site in the Pick form; e.g., 0=not applicable, 1=first displayed, 2=second displayed, etc., default=0';
COMMENT ON COLUMN sa.table_locatn_view.site_type IS 'Mnemonic representation of the integer site type field';
COMMENT ON COLUMN sa.table_locatn_view.region IS 'Region to which the site belongs';
COMMENT ON COLUMN sa.table_locatn_view.address IS 'Line 1 of address which includes street number, street name, office, building, or suite number, etc';
COMMENT ON COLUMN sa.table_locatn_view.city IS 'The city for the specified address';
COMMENT ON COLUMN sa.table_locatn_view."STATE" IS 'The state for the specified address';
COMMENT ON COLUMN sa.table_locatn_view.zip IS 'The state for the specified address';
COMMENT ON COLUMN sa.table_locatn_view."ACTIVE" IS 'Indicates whether the current part authorization is active; i.e., 0=inactive, 1=active, default=1';