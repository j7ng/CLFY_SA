CREATE OR REPLACE FORCE VIEW sa.table_ccc_qsn_v (objid,curr_q_name,curr_q_seqnum,next_q_objid,next_q_name,next_q_seq_num,next_s_objid,next_s_name,s_next_s_name,play_s_objid,play_s_name,s_play_s_name,curr_s_objid,curr_s_name,s_curr_s_name) AS
select table_curr_question.objid, table_curr_question.question,
 table_curr_question.seq_num, table_next_question.objid,
 table_next_question.question, table_next_question.seq_num,
 table_next_script.objid, table_next_script.name, table_next_script.S_name,
 table_play_script.objid, table_play_script.name, table_play_script.S_name,
 table_curr_script.objid, table_curr_script.name, table_curr_script.S_name
 from table_call_script table_curr_script, table_call_script table_next_script, table_call_script table_play_script, table_script_qstn table_curr_question, table_script_qstn table_next_question
 where table_curr_script.objid = table_curr_question.question2call_script
 AND table_play_script.objid (+) = table_curr_question.q_play_s2call_script
 AND table_next_question.objid (+) = table_curr_question.q_next_q2script_qstn
 AND table_next_script.objid (+) = table_curr_question.q_next_s2call_script
 ;
COMMENT ON TABLE sa.table_ccc_qsn_v IS 'Used to display script branch information on forms Script Writer (11300), Script Player (11301) and Script Tester (11302)';
COMMENT ON COLUMN sa.table_ccc_qsn_v.objid IS 'Current question internal record number';
COMMENT ON COLUMN sa.table_ccc_qsn_v.curr_q_name IS 'Current question name';
COMMENT ON COLUMN sa.table_ccc_qsn_v.curr_q_seqnum IS 'Current question sequence number';
COMMENT ON COLUMN sa.table_ccc_qsn_v.next_q_objid IS 'Next question internal record number';
COMMENT ON COLUMN sa.table_ccc_qsn_v.next_q_name IS 'Next quesiton name';
COMMENT ON COLUMN sa.table_ccc_qsn_v.next_q_seq_num IS 'Next quesiton sequence number';
COMMENT ON COLUMN sa.table_ccc_qsn_v.next_s_objid IS 'Next script internal record number';
COMMENT ON COLUMN sa.table_ccc_qsn_v.next_s_name IS 'Next script name';
COMMENT ON COLUMN sa.table_ccc_qsn_v.play_s_objid IS 'Play script internal record number';
COMMENT ON COLUMN sa.table_ccc_qsn_v.play_s_name IS 'Play script name';
COMMENT ON COLUMN sa.table_ccc_qsn_v.curr_s_objid IS 'Current script internal record number';
COMMENT ON COLUMN sa.table_ccc_qsn_v.curr_s_name IS 'Current script name';