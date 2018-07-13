CREATE OR REPLACE FORCE VIEW sa.table_sfa_quote_v (objid,user_objid,acct_objid,status_objid,contact_objid,currency_objid,quote_id,s_quote_id,quote_title,s_quote_title,quote_amount,quote_owner,s_quote_owner,quote_status,s_quote_status,q_start_date,q_end_date,acct_name,s_acct_name,contact_fname,s_contact_fname,contact_lname,s_contact_lname,contact_phone,quote_currency,s_quote_currency,sub_scale,q_issue_date,create_date,submit_date,order_status) AS
select table_contract.objid, table_user.objid,
 table_bus_org.objid, table_gbst_elm.objid,
 table_contact.objid, table_currency.objid,
 table_contract.id, table_contract.S_id, table_contract.title, table_contract.S_title,
 table_contract.total_net, table_user.login_name, table_user.S_login_name,
 table_gbst_elm.title, table_gbst_elm.S_title, table_contract.q_start_date,
 table_contract.q_end_date, table_bus_org.name, table_bus_org.S_name,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_contact.phone, table_currency.name, table_currency.S_name,
 table_currency.sub_scale, table_contract.q_issue_dt,
 table_contract.create_dt, table_contract.ord_submit_dt,
 table_contract.order_status
 from table_contract, table_user, table_bus_org,
  table_gbst_elm, table_contact, table_currency
 where table_user.objid = table_contract.owner2user
 AND table_currency.objid = table_contract.contract2currency
 AND table_contact.objid (+) = table_contract.primary2contact
 AND table_bus_org.objid (+) = table_contract.sell_to2bus_org
 AND table_gbst_elm.objid = table_contract.status2gbst_elm
 ;
COMMENT ON TABLE sa.table_sfa_quote_v IS 'Used by forms Account Mgr (11650), Opportunity Mgr (13000), Sales Console (12000) and many tabs';
COMMENT ON COLUMN sa.table_sfa_quote_v.objid IS 'Contract internal record number';
COMMENT ON COLUMN sa.table_sfa_quote_v.user_objid IS 'User owner internal record number';
COMMENT ON COLUMN sa.table_sfa_quote_v.acct_objid IS 'Account internal record number';
COMMENT ON COLUMN sa.table_sfa_quote_v.status_objid IS 'Quote status internal record number';
COMMENT ON COLUMN sa.table_sfa_quote_v.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_sfa_quote_v.currency_objid IS 'Currency internal record number';
COMMENT ON COLUMN sa.table_sfa_quote_v.quote_id IS 'System-generated quote ID number';
COMMENT ON COLUMN sa.table_sfa_quote_v.quote_title IS 'Title of the quote';
COMMENT ON COLUMN sa.table_sfa_quote_v.quote_amount IS 'Total net amount of the quote';
COMMENT ON COLUMN sa.table_sfa_quote_v.quote_owner IS 'Owner s login name';
COMMENT ON COLUMN sa.table_sfa_quote_v.quote_status IS 'Title of the quote status';
COMMENT ON COLUMN sa.table_sfa_quote_v.q_start_date IS 'Quote start date';
COMMENT ON COLUMN sa.table_sfa_quote_v.q_end_date IS 'Quote end date';
COMMENT ON COLUMN sa.table_sfa_quote_v.acct_name IS 'Name of the prospect Account';
COMMENT ON COLUMN sa.table_sfa_quote_v.contact_fname IS 'Contact s first name';
COMMENT ON COLUMN sa.table_sfa_quote_v.contact_lname IS 'Contact s last name';
COMMENT ON COLUMN sa.table_sfa_quote_v.contact_phone IS 'Contact s phone';
COMMENT ON COLUMN sa.table_sfa_quote_v.quote_currency IS 'Name of the quote s currency';
COMMENT ON COLUMN sa.table_sfa_quote_v.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';
COMMENT ON COLUMN sa.table_sfa_quote_v.q_issue_date IS 'Quote issue date';
COMMENT ON COLUMN sa.table_sfa_quote_v.create_date IS 'Date the quote/order was created';
COMMENT ON COLUMN sa.table_sfa_quote_v.submit_date IS 'Date the quote/order was submitted';
COMMENT ON COLUMN sa.table_sfa_quote_v.order_status IS 'MACD order status';