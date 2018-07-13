CREATE OR REPLACE FORCE VIEW sa.table_queue_info (objid,title,s_title,shared_pers,allow_case,allow_subcase,allow_probdesc,allow_dmnd_dtl,allow_bug,allow_opp,allow_contract,allow_job,allow_task,allow_dialogue) AS
select table_queue.objid, table_queue.title, table_queue.S_title,
 table_queue.shared_pers, table_queue.allow_case,
 table_queue.allow_subcase, table_queue.allow_probdesc,
 table_queue.allow_dmnd_dtl, table_queue.allow_bug,
 table_queue.allow_opp, table_queue.allow_contract,
 table_queue.allow_job, table_queue.allow_task,
 table_queue.allow_dialogue
 from table_queue;
COMMENT ON TABLE sa.table_queue_info IS 'Used by Dispatch form (425).  DO NOT USE FOR ANY OTHER PURPOSE!';
COMMENT ON COLUMN sa.table_queue_info.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_queue_info.title IS 'Queue title';
COMMENT ON COLUMN sa.table_queue_info.shared_pers IS 'Indicates whether this queue is shared or personal';
COMMENT ON COLUMN sa.table_queue_info.allow_case IS 'Indicates whether cases may be dispatched to this queue';
COMMENT ON COLUMN sa.table_queue_info.allow_subcase IS 'Indicates whether subcases may be dispatched to this queue';
COMMENT ON COLUMN sa.table_queue_info.allow_probdesc IS 'Indicates whether solutions may be dispatched to this queue';
COMMENT ON COLUMN sa.table_queue_info.allow_dmnd_dtl IS 'Indicates whether RMA requests may be dispatched to this queue';
COMMENT ON COLUMN sa.table_queue_info.allow_bug IS 'Indicates whether CRs may be dispatched to this queue';
COMMENT ON COLUMN sa.table_queue_info.allow_opp IS 'Indicates whether opportunities are allowed to be dispatched to the queue';
COMMENT ON COLUMN sa.table_queue_info.allow_contract IS 'Indicates whether contracts are allowed to be dispatched to the queue';
COMMENT ON COLUMN sa.table_queue_info.allow_job IS 'Indicates whether job are allowed to be dispatched to the queue';
COMMENT ON COLUMN sa.table_queue_info.allow_task IS 'Indicates whether tasks are allowed to be dispatched to the queue';
COMMENT ON COLUMN sa.table_queue_info.allow_dialogue IS 'Indicates whether dialogues are allowed to be dispatched to the queue';