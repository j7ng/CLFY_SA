CREATE OR REPLACE FORCE VIEW sa.table_ccc_srun_v (objid,response,s_response,question,s_question,seqnum,score,r_objid,r_response,s_r_response,r_action,s_r_action,curr_srun_objid,curr_srun_title,s_curr_srun_title,curr_srun_score,curr_srun_stime,curr_srun_etime,first_srun_objid,first_srun_title,s_first_srun_title,first_srun_score,first_srun_stime,first_srun_etime) AS
select table_curr_response.objid, table_curr_response.response, table_curr_response.S_response,
 table_curr_response.question, table_curr_response.S_question, table_curr_response.seq_num,
 table_curr_response.score, table_orig_response.objid,
 table_orig_response.response, table_orig_response.S_response, table_orig_response.action, table_orig_response.S_action,
 table_curr_scr_run.objid, table_curr_scr_run.title, table_curr_scr_run.S_title,
 table_curr_scr_run.score, table_curr_scr_run.start_time,
 table_curr_scr_run.end_time, table_first_scr_run.objid,
 table_first_scr_run.title, table_first_scr_run.S_title, table_first_scr_run.score,
 table_first_scr_run.start_time, table_first_scr_run.end_time
 from table_scr_response table_curr_response, table_scrqstn_rspns table_orig_response, table_scr_run table_curr_scr_run, table_scr_run table_first_scr_run
 where table_curr_scr_run.objid = table_curr_response.response2scr_run
 AND table_first_scr_run.objid = table_curr_response.first_scr2scr_run
 AND table_orig_response.objid (+) = table_curr_response.answ2scrqstn_rspns 
 ;
COMMENT ON TABLE sa.table_ccc_srun_v IS 'Used to display form Script Report (11307) for script responses. The names used in the fields represent their text contents';
COMMENT ON COLUMN sa.table_ccc_srun_v.objid IS 'Current response internal record number';
COMMENT ON COLUMN sa.table_ccc_srun_v.response IS 'Current response name';
COMMENT ON COLUMN sa.table_ccc_srun_v.question IS 'Current response script action';
COMMENT ON COLUMN sa.table_ccc_srun_v.seqnum IS 'Current prompt sequence number';
COMMENT ON COLUMN sa.table_ccc_srun_v.score IS 'Current response score';
COMMENT ON COLUMN sa.table_ccc_srun_v.r_objid IS 'Original response internal record number';
COMMENT ON COLUMN sa.table_ccc_srun_v.r_response IS 'Predefined response to the question';
COMMENT ON COLUMN sa.table_ccc_srun_v.r_action IS 'Predefined response sequence number';
COMMENT ON COLUMN sa.table_ccc_srun_v.curr_srun_objid IS 'Script run instance internal record number';
COMMENT ON COLUMN sa.table_ccc_srun_v.curr_srun_title IS 'Name of the script that was run';
COMMENT ON COLUMN sa.table_ccc_srun_v.curr_srun_score IS 'Total score attained during the run of the call script';
COMMENT ON COLUMN sa.table_ccc_srun_v.curr_srun_stime IS 'Starting date and time of the call script run';
COMMENT ON COLUMN sa.table_ccc_srun_v.curr_srun_etime IS 'Ending date and time of the call script run';
COMMENT ON COLUMN sa.table_ccc_srun_v.first_srun_objid IS 'First script that was run internal record number';
COMMENT ON COLUMN sa.table_ccc_srun_v.first_srun_title IS 'Name of the call script that was run first';
COMMENT ON COLUMN sa.table_ccc_srun_v.first_srun_score IS 'Total score obtained from the first script that was run';
COMMENT ON COLUMN sa.table_ccc_srun_v.first_srun_stime IS 'Starting date and time of the first script that was run';
COMMENT ON COLUMN sa.table_ccc_srun_v.first_srun_etime IS 'Ending date and time of the first script that was run';