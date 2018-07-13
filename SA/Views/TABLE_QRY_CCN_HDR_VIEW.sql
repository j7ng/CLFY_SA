CREATE OR REPLACE FORCE VIEW sa.table_qry_ccn_hdr_view (ccn_objid,id_number,s_id_number,"OWNER",s_owner,"CONDITION",s_condition,status,s_status,"TYPE",cont_start_date,cont_exp_date,q_start_date,q_end_date,org_name,s_org_name,contact_fname,s_contact_fname,contact_lname,s_contact_lname,title,s_title,"ADMINISTRATOR",s_administrator,fsvc_end_date,struct_type,contact_objid,owner_objid,admin_objid,status_objid,bus_org_objid,cndtn_objid,ord_submit_dt,order_status) AS
select table_contract.objid, table_contract.id, table_contract.S_id,
 table_owner.login_name, table_owner.S_login_name, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_contract.type,
 table_contract.start_date, table_contract.expire_date,
 table_contract.q_start_date, table_contract.q_end_date,
 table_bus_org.name, table_bus_org.S_name, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contract.title, table_contract.S_title,
 table_admin.login_name, table_admin.S_login_name, table_contract.fsvc_end_date,
 table_contract.struct_type, table_contact.objid,
 table_owner.objid, table_admin.objid,
 table_gbst_elm.objid, table_bus_org.objid,
 table_condition.objid, table_contract.ord_submit_dt,
 table_contract.order_status
 from table_user table_admin, table_user table_owner, table_contract, table_condition, table_gbst_elm,
  table_bus_org, table_contact
 where table_condition.objid = table_contract.contract2condition
 AND table_admin.objid (+) = table_contract.contract2admin
 AND table_contact.objid (+) = table_contract.primary2contact
 AND table_bus_org.objid (+) = table_contract.sell_to2bus_org
 AND table_gbst_elm.objid = table_contract.status2gbst_elm
 AND table_owner.objid = table_contract.owner2user
 ;
COMMENT ON TABLE sa.table_qry_ccn_hdr_view IS 'Used to display information about Contracts. Used by forms Contracts from Query (9129), Sites (8501), Contacts (8502), Contracts (8503), Account Team (8504),Quotes (8525) and others';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.ccn_objid IS 'Contract internal record number';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.id_number IS 'Contract number; generated via auto-numbering';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view."OWNER" IS 'Owner login name';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view."CONDITION" IS 'Title of contract condition';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.status IS 'Contract status';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view."TYPE" IS 'Contract type';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.cont_start_date IS 'Contract start date';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.cont_exp_date IS 'Contract expiration date';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.q_start_date IS 'Quote start date';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.q_end_date IS 'Quote end date';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.org_name IS 'Organization name';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.contact_fname IS 'Contact first name';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.contact_lname IS 'Contacat last name';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.title IS 'Title of the contract';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view."ADMINISTRATOR" IS 'Administrator login name';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.fsvc_end_date IS 'The end date of earliest ending service under the contract. Used for renewal of non-coterminous contracts';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.struct_type IS 'Type of contract/quote structure of the object; i.e., 0=service contract, 1=sales item';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.owner_objid IS 'Owner user internal record number';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.admin_objid IS 'Administrator user internal record number';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.status_objid IS 'Status gbst_elm internal record number';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.bus_org_objid IS 'Bus_org internal record number';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.cndtn_objid IS 'Condition internal record number';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.ord_submit_dt IS 'Date the order was submitted';
COMMENT ON COLUMN sa.table_qry_ccn_hdr_view.order_status IS 'MACD order status field';