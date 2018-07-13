CREATE OR REPLACE FORCE VIEW sa.table_ccn_bill_view (objid,contr_objid,currency_objid,site_objid,cond_objid,"CONDITION",id_number,s_id_number,start_date,end_date,adm_name,s_adm_name,org_name,s_org_name,sched_id,s_sched_id,sched_title,struct_type,frequency,site_id,site_name,s_site_name,contract_title,s_contract_title,svc_start_dt,svc_expire_dt,sub_scale) AS
select table_contr_schedule.objid, table_contract.objid,
 table_currency.objid, table_site.objid,
 table_condition.objid, table_condition.condition,
 table_contract.id, table_contract.S_id, table_contract.start_date,
 table_contract.expire_date, table_user.login_name, table_user.S_login_name,
 table_bus_org.name, table_bus_org.S_name, table_contr_schedule.schedule_id, table_contr_schedule.S_schedule_id,
 table_contr_schedule.schedule_title, table_contract.struct_type,
 table_contr_schedule.frequency, table_site.site_id,
 table_site.name, table_site.S_name, table_contract.title, table_contract.S_title,
 table_contract.start_date, table_contract.expire_date,
 table_currency.sub_scale
 from table_contr_schedule, table_contract, table_currency,
  table_site, table_condition, table_user,
  table_bus_org
 where table_contract.objid = table_contr_schedule.schedule2contract
 AND table_currency.objid = table_contract.contract2currency
 AND table_bus_org.objid (+) = table_contract.sell_to2bus_org
 AND table_condition.objid = table_contract.contract2condition
 AND table_user.objid = table_contract.contract2admin
 AND table_site.objid (+) = table_contr_schedule.bill_to2site
 ;
COMMENT ON TABLE sa.table_ccn_bill_view IS 'This is used Contracts Billing. Used by forms Billing Review Schedule Selection (9160) and Merge Schedules (9172)';
COMMENT ON COLUMN sa.table_ccn_bill_view.objid IS 'Contract schedule internal record number';
COMMENT ON COLUMN sa.table_ccn_bill_view.contr_objid IS 'Contract internal record number';
COMMENT ON COLUMN sa.table_ccn_bill_view.currency_objid IS 'Currency internal record number';
COMMENT ON COLUMN sa.table_ccn_bill_view.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_ccn_bill_view.cond_objid IS 'Condition internal record number';
COMMENT ON COLUMN sa.table_ccn_bill_view."CONDITION" IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_ccn_bill_view.id_number IS 'Contract number; generated via auto-numbering';
COMMENT ON COLUMN sa.table_ccn_bill_view.start_date IS 'Contract start date';
COMMENT ON COLUMN sa.table_ccn_bill_view.end_date IS 'Title of contract condition';
COMMENT ON COLUMN sa.table_ccn_bill_view.adm_name IS 'Administrator login name';
COMMENT ON COLUMN sa.table_ccn_bill_view.org_name IS 'Sell to organization. name';
COMMENT ON COLUMN sa.table_ccn_bill_view.sched_id IS 'Unique identifier of the contract schedule';
COMMENT ON COLUMN sa.table_ccn_bill_view.sched_title IS 'Contract schedule name';
COMMENT ON COLUMN sa.table_ccn_bill_view.struct_type IS 'Type of contract/quote structure of the object; i.e., 0=service contract, 1=sales item';
COMMENT ON COLUMN sa.table_ccn_bill_view.frequency IS 'Frequency of the billing: i.e., 0=annual, 1=semi-annual, 2=quarterly, 3=monthly, 4=one-time, default=0';
COMMENT ON COLUMN sa.table_ccn_bill_view.site_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_ccn_bill_view.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_ccn_bill_view.contract_title IS 'Title of the contract or quote';
COMMENT ON COLUMN sa.table_ccn_bill_view.svc_start_dt IS 'The date the contract became active. Where line items are involved, this is the begin service date of the earliest line item';
COMMENT ON COLUMN sa.table_ccn_bill_view.svc_expire_dt IS 'The date the contract ends. Where contract line items are involved, this is the ending service date of the latest line item';
COMMENT ON COLUMN sa.table_ccn_bill_view.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';