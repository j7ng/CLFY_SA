CREATE OR REPLACE FORCE VIEW sa.table_dfe_case_user (user_objid,disptchfe_objid,appointment,duration,requested_eta,appt_confirm,cell_text,case_objid,queue_objid,wipbin_objid) AS
select table_case.case_owner2user, table_disptchfe.objid,
 table_disptchfe.appointment, table_disptchfe.duration,
 table_disptchfe.requested_eta, table_disptchfe.appt_confirm,
 table_disptchfe.cell_text, table_case.objid,
 table_case.case_currq2queue, table_case.case_wip2wipbin
 from table_case, table_disptchfe
 where table_case.objid = table_disptchfe.disptchfe2case
 AND table_case.case_owner2user IS NOT NULL
 ;
COMMENT ON TABLE sa.table_dfe_case_user IS 'Gets case dispatches associated with users. Used by Schedule Tracker form  (899)';
COMMENT ON COLUMN sa.table_dfe_case_user.user_objid IS 'Employee objid';
COMMENT ON COLUMN sa.table_dfe_case_user.disptchfe_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_dfe_case_user.appointment IS 'Proposed date/time of scheduled appointment or commitment';
COMMENT ON COLUMN sa.table_dfe_case_user.duration IS 'Expected amount of time to complete the task';
COMMENT ON COLUMN sa.table_dfe_case_user.requested_eta IS 'Requested date and time of field engineer s arrival at dispatch site';
COMMENT ON COLUMN sa.table_dfe_case_user.appt_confirm IS '0=unconfirmed, 1=confirmed, default=0';
COMMENT ON COLUMN sa.table_dfe_case_user.cell_text IS 'Contains a conatination of locally-selected fields for display by Schedule Tracker. Default is field case.id_number';
COMMENT ON COLUMN sa.table_dfe_case_user.case_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_dfe_case_user.queue_objid IS 'queue object ID';
COMMENT ON COLUMN sa.table_dfe_case_user.wipbin_objid IS 'wipbin object ID';