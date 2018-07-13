CREATE OR REPLACE FORCE VIEW sa.table_ccc_rsp_v (objid,curr_r_name,s_curr_r_name,curr_r_action,s_curr_r_action,curr_r_score,curr_r_default,curr_r_seq_num,next_q_objid,next_q_seq_num,next_q_name,next_s_objid,next_s_name,s_next_s_name,play_s_objid,play_s_name,s_play_s_name,curr_q_objid,curr_q_name) AS
select table_curr_response.objid, table_curr_response.response, table_curr_response.S_response,
 table_curr_response.action, table_curr_response.S_action, table_curr_response.score,
 table_curr_response.is_default, table_curr_response.seq_num,
 table_next_question.objid, table_next_question.seq_num,
 table_next_question.question, table_next_script.objid,
 table_next_script.name, table_next_script.S_name, table_play_script.objid,
 table_play_script.name, table_play_script.S_name, table_curr_question.objid,
 table_curr_question.question
 from table_call_script table_next_script, table_call_script table_play_script, table_script_qstn table_curr_question, table_script_qstn table_next_question, table_scrqstn_rspns table_curr_response
 where table_curr_question.objid = table_curr_response.current2script_qstn
 AND table_next_script.objid (+) = table_curr_response.r_next_s2call_script
 AND table_play_script.objid (+) = table_curr_response.r_play_s2call_script
 AND table_next_question.objid (+) = table_curr_response.next2script_qstn
 ;
COMMENT ON TABLE sa.table_ccc_rsp_v IS 'Used to display script branch information on forms Script Writer (11300), Script Player (11301) and Script Tester (11302)';
COMMENT ON COLUMN sa.table_ccc_rsp_v.objid IS 'Current response internal record number';
COMMENT ON COLUMN sa.table_ccc_rsp_v.curr_r_name IS 'Current response name';
COMMENT ON COLUMN sa.table_ccc_rsp_v.curr_r_action IS 'Current response script action';
COMMENT ON COLUMN sa.table_ccc_rsp_v.curr_r_score IS 'Current response score';
COMMENT ON COLUMN sa.table_ccc_rsp_v.curr_r_default IS 'Current response is default flag';
COMMENT ON COLUMN sa.table_ccc_rsp_v.curr_r_seq_num IS 'Current response sequence number';
COMMENT ON COLUMN sa.table_ccc_rsp_v.next_q_objid IS 'Next question internal record number';
COMMENT ON COLUMN sa.table_ccc_rsp_v.next_q_seq_num IS 'Next question sequence number';
COMMENT ON COLUMN sa.table_ccc_rsp_v.next_q_name IS 'Next question name';
COMMENT ON COLUMN sa.table_ccc_rsp_v.next_s_objid IS 'Next script internal record number';
COMMENT ON COLUMN sa.table_ccc_rsp_v.next_s_name IS 'Next script name';
COMMENT ON COLUMN sa.table_ccc_rsp_v.play_s_objid IS 'Play script internal record number';
COMMENT ON COLUMN sa.table_ccc_rsp_v.play_s_name IS 'Play script name';
COMMENT ON COLUMN sa.table_ccc_rsp_v.curr_q_objid IS 'Current question internal record number';
COMMENT ON COLUMN sa.table_ccc_rsp_v.curr_q_name IS 'Current question name';