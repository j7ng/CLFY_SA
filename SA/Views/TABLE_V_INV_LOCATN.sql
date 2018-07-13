CREATE OR REPLACE FORCE VIEW sa.table_v_inv_locatn (objid,location_id,site_id,location_name,locdesc,inv_class,trans_auth,role_name,"RANK") AS
select table_inv_role.objid, table_inv_locatn.objid,
 table_inv_role.inv_role2site, table_inv_locatn.location_name,
 table_inv_locatn.location_descr, table_inv_locatn.inv_class,
 table_inv_locatn.trans_auth, table_inv_role.role_name,
 table_inv_role.rank
 from table_inv_role, table_inv_locatn
 where table_inv_locatn.objid = table_inv_role.inv_role2inv_locatn
 AND table_inv_role.inv_role2site IS NOT NULL
 ;
COMMENT ON TABLE sa.table_v_inv_locatn IS 'View of inventory location information used by form Picked Parts (552)';
COMMENT ON COLUMN sa.table_v_inv_locatn.objid IS 'Inventory role internal record number';
COMMENT ON COLUMN sa.table_v_inv_locatn.location_id IS 'Inventory location internal record number';
COMMENT ON COLUMN sa.table_v_inv_locatn.site_id IS 'Site internal record number';
COMMENT ON COLUMN sa.table_v_inv_locatn.location_name IS 'For physical inventory locations, the name of the location. For GL accounts, the account number';
COMMENT ON COLUMN sa.table_v_inv_locatn.locdesc IS 'Description of the inventory location or GL account';
COMMENT ON COLUMN sa.table_v_inv_locatn.inv_class IS 'Inventory location class; i.e.,0=inventory location, 1=capital GL account, 2=expense GL account';
COMMENT ON COLUMN sa.table_v_inv_locatn.trans_auth IS 'States the type of transactions authorized for the inventory location; i.e., 0=all, 1=none, 2=Authorized Parts only. An authorized part is one for which there is a part_auth object';
COMMENT ON COLUMN sa.table_v_inv_locatn.role_name IS 'Name of role played by the focus type; e.g., sites default-bad parts inventory location, inventory locations located-at site';
COMMENT ON COLUMN sa.table_v_inv_locatn."RANK" IS 'For servicing inventory locations, ranks the order in which locations should be displayed for a given site in the Pick form; e.g., 0=not applicable, 1=first displayed, 2=second displayed, etc., default=0';