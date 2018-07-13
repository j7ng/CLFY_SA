CREATE OR REPLACE FORCE VIEW sa.table_sfa_tsk_mto_v (objid,acct_objid,con_objid,lead_objid,opp_objid,lit_objid,task_name,s_task_name,task_id,s_task_id,acct_name,s_acct_name,con_f_name,s_con_f_name,con_l_name,s_con_l_name,con_phone,opp_name,s_opp_name,opp_id,s_opp_id,lead_f_name,s_lead_f_name,lead_l_name,s_lead_l_name,lead_phone,s_lead_phone,lit_req_name,s_lit_req_name,lit_req_id) AS
select table_task.objid, table_bus_org.objid,
 table_contact.objid, table_lead.objid,
 table_opportunity.objid, table_lit_req.objid,
 table_task.title, table_task.S_title, table_task.task_id, table_task.S_task_id,
 table_bus_org.name, table_bus_org.S_name, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.phone,
 table_opportunity.name, table_opportunity.S_name, table_opportunity.id, table_opportunity.S_id,
 table_lead.first_name, table_lead.S_first_name, table_lead.last_name, table_lead.S_last_name,
 table_lead.phone, table_lead.S_phone, table_lit_req.title, table_lit_req.S_title,
 table_lit_req.lit_req_id
 from table_task, table_bus_org, table_contact,
  table_lead, table_opportunity, table_lit_req
 where table_opportunity.objid (+) = table_task.sm_task2opportunity
 AND table_contact.objid (+) = table_task.task2contact
 AND table_bus_org.objid (+) = table_task.task_for2bus_org
 AND table_lead.objid (+) = table_task.task2lead
 AND table_lit_req.objid (+) = table_task.task2lit_req
 ;
COMMENT ON TABLE sa.table_sfa_tsk_mto_v IS 'View Task parent objects. Used by Used by Account Mgr (11650), Console-Sales (12000), and Opportunity Mgr (13000), Lead (11610) and Action Item (14000)';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.objid IS 'Task internal record number';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.acct_objid IS 'Bus_org internal record number';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.con_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.lead_objid IS 'Lead internal record number';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.opp_objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.lit_objid IS 'Lit_req internal record number';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.task_name IS 'Name of the task';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.task_id IS 'Unique ID number of the task';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.acct_name IS 'bus_org name';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.con_f_name IS 'First name of the contact';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.con_l_name IS 'Last name of the contact';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.con_phone IS 'Contact s phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.opp_name IS 'Name of the opportunity';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.opp_id IS 'Unique ID number of the opportunity';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.lead_f_name IS 'Lead s first name';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.lead_l_name IS 'Lead s last name';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.lead_phone IS 'Lead s phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.lit_req_name IS 'Title of the literature request';
COMMENT ON COLUMN sa.table_sfa_tsk_mto_v.lit_req_id IS 'Unique ID number of the template; assigned according to auto-numbering definition';