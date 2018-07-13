CREATE OR REPLACE FORCE VIEW sa.table_act_cmitl (objid,title,sched_cmpltime,cond_name,s_cond_name) AS
select table_commit_log.objid, table_commit_log.title,
 table_commit_log.sched_cmpltime, table_gbst_elm.title, table_gbst_elm.S_title
 from table_commit_log, table_gbst_elm
 where table_gbst_elm.objid = table_commit_log.cmit_name2gbst_elm
 ;
COMMENT ON TABLE sa.table_act_cmitl IS 'Contains commitment log information used in commitment select form';
COMMENT ON COLUMN sa.table_act_cmitl.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_act_cmitl.title IS 'Commitment log title';
COMMENT ON COLUMN sa.table_act_cmitl.sched_cmpltime IS 'Date and time of scheduled completion; date/time completion is desired/requested';
COMMENT ON COLUMN sa.table_act_cmitl.cond_name IS 'Name of the item/element';