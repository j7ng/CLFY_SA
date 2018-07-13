CREATE OR REPLACE FORCE VIEW sa.table_queued_case_dfe (user_objid,case_objid,shared_pers,disptchfe_objid,appointment,duration,requested_eta,appt_confirm,cell_text,"CONDITION") AS
select table_user.objid, table_case.objid,
 table_queue.shared_pers, table_disptchfe.objid,
 table_disptchfe.appointment, table_disptchfe.duration,
 table_disptchfe.requested_eta, table_disptchfe.appt_confirm,
 table_disptchfe.cell_text, table_condition.condition
 from mtm_queue5_user24, table_user, table_case, table_queue,
  table_disptchfe, table_condition
 where table_case.objid = table_disptchfe.disptchfe2case
 AND table_condition.objid = table_case.case_state2condition
 AND table_queue.objid = mtm_queue5_user24.queue_supvr2user
 AND mtm_queue5_user24.supvr_assigned2queue = table_user.objid 
 AND table_queue.objid = table_case.case_currq2queue
 ;
COMMENT ON TABLE sa.table_queued_case_dfe IS 'Gets case-related dispatches in queues';
COMMENT ON COLUMN sa.table_queued_case_dfe.user_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_queued_case_dfe.case_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_queued_case_dfe.shared_pers IS 'Indicates whether queue is shared or personal';
COMMENT ON COLUMN sa.table_queued_case_dfe.disptchfe_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_queued_case_dfe.appointment IS 'Proposed date/time of scheduled appointment or commitment';
COMMENT ON COLUMN sa.table_queued_case_dfe.duration IS 'Expected amount of time to complete the task in seconds';
COMMENT ON COLUMN sa.table_queued_case_dfe.requested_eta IS 'Requested date and time of field engineer s arrival at dispatch site';
COMMENT ON COLUMN sa.table_queued_case_dfe.appt_confirm IS '0=unconfirmed, 1=confirmed, default=0';
COMMENT ON COLUMN sa.table_queued_case_dfe.cell_text IS 'Contains a concatination of locally-selected fields for display by Schedule Tracker. Default is field case.id_number';
COMMENT ON COLUMN sa.table_queued_case_dfe."CONDITION" IS 'Code number for the condition type';