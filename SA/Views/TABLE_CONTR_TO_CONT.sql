CREATE OR REPLACE FORCE VIEW sa.table_contr_to_cont (objid,loc_objid,"ID","NAME",s_name,p_phone,f_name,s_f_name,l_name,s_l_name,cnt_objid) AS
select table_contract.objid, table_site.objid,
 table_site.site_id, table_site.name, table_site.S_name,
 table_contact.phone, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.objid
 from mtm_site5_contract0, mtm_contact2_contract1, table_contract, table_site, table_contact
 where table_site.objid = mtm_site5_contract0.cust_loc2contract
 AND mtm_site5_contract0.contract2site = table_contract.objid
 AND table_contact.objid = mtm_contact2_contract1.caller2contract
 AND mtm_contact2_contract1.contract2contact = table_contract.objid
 ;
COMMENT ON TABLE sa.table_contr_to_cont IS 'View contract and allowed contacts';
COMMENT ON COLUMN sa.table_contr_to_cont.objid IS 'Contract object ID number';
COMMENT ON COLUMN sa.table_contr_to_cont.loc_objid IS 'Site object ID number';
COMMENT ON COLUMN sa.table_contr_to_cont."ID" IS 'Site ID number';
COMMENT ON COLUMN sa.table_contr_to_cont."NAME" IS 'Site name';
COMMENT ON COLUMN sa.table_contr_to_cont.p_phone IS 'Site phone number';
COMMENT ON COLUMN sa.table_contr_to_cont.f_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_contr_to_cont.l_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_contr_to_cont.cnt_objid IS 'Contact object ID number';