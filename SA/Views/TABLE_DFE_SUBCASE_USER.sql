CREATE OR REPLACE FORCE VIEW sa.table_dfe_subcase_user (user_objid,disptchfe_objid,appointment,duration,requested_eta,appt_confirm,cell_text,subcase_objid,queue_objid,wipbin_objid) AS
select table_subcase.subc_owner2user, table_disptchfe.objid,
 table_disptchfe.appointment, table_disptchfe.duration,
 table_disptchfe.requested_eta, table_disptchfe.appt_confirm,
 table_disptchfe.cell_text, table_subcase.objid,
 table_subcase.subc_currq2queue, table_subcase.subc_wip2wipbin
 from table_subcase, table_disptchfe
 where table_subcase.objid = table_disptchfe.disptchfe2subcase
 AND table_subcase.subc_owner2user IS NOT NULL
 ;
COMMENT ON TABLE sa.table_dfe_subcase_user IS 'Gets subcase dispatches associated with users. Used by Schedule Tracker form  (899)';
COMMENT ON COLUMN sa.table_dfe_subcase_user.user_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_dfe_subcase_user.disptchfe_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_dfe_subcase_user.appointment IS 'Proposed date/time of scheduled appointment or commitment';
COMMENT ON COLUMN sa.table_dfe_subcase_user.duration IS 'Expected amount of time to complete the task';
COMMENT ON COLUMN sa.table_dfe_subcase_user.requested_eta IS 'Requested date and time of field engineer s arrival at dispatch site';
COMMENT ON COLUMN sa.table_dfe_subcase_user.appt_confirm IS '0=unconfirmed, 1=confirmed, default=0';
COMMENT ON COLUMN sa.table_dfe_subcase_user.cell_text IS 'Contains a conatination of locally-selected fields for display by Schedule Tracker. Default is field case.id_number';
COMMENT ON COLUMN sa.table_dfe_subcase_user.subcase_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_dfe_subcase_user.queue_objid IS 'queue object ID';
COMMENT ON COLUMN sa.table_dfe_subcase_user.wipbin_objid IS 'wipbin object ID';