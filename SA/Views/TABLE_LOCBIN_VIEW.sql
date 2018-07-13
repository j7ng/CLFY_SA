CREATE OR REPLACE FORCE VIEW sa.table_locbin_view (loc_objid,location_name,location_descr,location_type,reports_to_loc,role_name,gl_acct_no,inv_class,loc_type,bin_name,bin_objid,"ACTIVE",id_number,opened_ind,fixed_ind,bin_type,fixed_bin_name,loc_active) AS
select table_inv_locatn.objid, table_inv_locatn.location_name,
 table_inv_locatn.location_descr, table_inv_locatn.location_type,
 table_inv_locatn.reports_to_loc, table_inv_role.role_name,
 table_inv_locatn.gl_acct_no, table_inv_locatn.inv_class,
 table_inv_bin.location_name, table_inv_bin.bin_name,
 table_inv_bin.objid, table_inv_bin.active,
 table_inv_bin.id_number, table_inv_bin.opened_ind,
 table_inv_bin.fixed_ind, table_inv_bin.bin_type,
 table_inv_bin.fixed_bin_name, table_inv_locatn.active
 from table_inv_locatn, table_inv_role, table_inv_bin
 where table_inv_locatn.objid = table_inv_role.inv_role2inv_locatn
 AND table_inv_locatn.objid = table_inv_bin.inv_bin2inv_locatn
 ;
COMMENT ON TABLE sa.table_locbin_view IS 'Used by the Select GL Accounts and Locations form (524), Mass Part Transfer (531), Upgrade Item (8407), Transact Material (8408), Depot Repair: De-Bundle (8422) and De-Manufacturing (8424)';
COMMENT ON COLUMN sa.table_locbin_view.loc_objid IS 'Inventory location internal record number';
COMMENT ON COLUMN sa.table_locbin_view.location_name IS 'For physical inventory locations, the name of the location. For GL accounts, the account number';
COMMENT ON COLUMN sa.table_locbin_view.location_descr IS 'Description of the inventory location or GL account';
COMMENT ON COLUMN sa.table_locbin_view.location_type IS 'User-defined types of physical inventory location';
COMMENT ON COLUMN sa.table_locbin_view.reports_to_loc IS 'The parent inventory location name or, if GL account, the parent GL account number';
COMMENT ON COLUMN sa.table_locbin_view.role_name IS 'Name of the inventory role';
COMMENT ON COLUMN sa.table_locbin_view.gl_acct_no IS 'If the current object is a physical location, the GL account number. If a GL account, the field is either empty, or contains the parent GL account number';
COMMENT ON COLUMN sa.table_locbin_view.inv_class IS '0=inventory location, 1=capital GL account, 2=expense GL account';
COMMENT ON COLUMN sa.table_locbin_view.loc_type IS 'For display only of the inventory location type';
COMMENT ON COLUMN sa.table_locbin_view.bin_name IS 'Unique name of the inventory bin within an inventory location';
COMMENT ON COLUMN sa.table_locbin_view.bin_objid IS 'Inventory bin internal record number';
COMMENT ON COLUMN sa.table_locbin_view."ACTIVE" IS 'Indicates whether the bin is in use; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_locbin_view.id_number IS 'Unique bin number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_locbin_view.opened_ind IS 'Indicates whether the bin allows parts to be moved in/out or not; i.e, 0=no, it s sealed, 1=yes it is opened, default=1';
COMMENT ON COLUMN sa.table_locbin_view.fixed_ind IS 'Indicates whether the bin is movable or not; i.e., 0=no it is fixed, 1=yes, it is moveable, default=0';
COMMENT ON COLUMN sa.table_locbin_view.bin_type IS 'User-defined type of bins; i.e., 0=fixed bin, 1=container, 2=pallet, default=0';
COMMENT ON COLUMN sa.table_locbin_view.fixed_bin_name IS 'For containers, the name of the fixed bin within which the container resides, for fixed bins this field is blank, default=';
COMMENT ON COLUMN sa.table_locbin_view.loc_active IS 'Indicates whether the inventory location is active; i.e., 0=inactive, 1=active, default=1';