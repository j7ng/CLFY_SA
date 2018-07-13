CREATE OR REPLACE FORCE VIEW sa.table_scrqstnrsq_v (objid,seq_num,response,s_response,score,nxtqstn_seq_num,nxtqstn_objid,nxtqstn_question,parqstn_objid) AS
select table_scrqstn_rspns.objid, table_scrqstn_rspns.seq_num,
 table_scrqstn_rspns.response, table_scrqstn_rspns.S_response, table_scrqstn_rspns.score,
 table_next_qstn.seq_num, table_next_qstn.objid,
 table_next_qstn.question, table_scrqstn_rspns.current2script_qstn
 from table_script_qstn table_next_qstn, table_scrqstn_rspns
 where table_next_qstn.objid (+) = table_scrqstn_rspns.next2script_qstn
 AND table_scrqstn_rspns.current2script_qstn IS NOT NULL
 ;
COMMENT ON TABLE sa.table_scrqstnrsq_v IS 'Displays answers and next question. Used by form Call Script Questions (9542), Call Script Detail (9541), and Call Script Campaigns (9543)';
COMMENT ON COLUMN sa.table_scrqstnrsq_v.objid IS 'Internal record number of the answer';
COMMENT ON COLUMN sa.table_scrqstnrsq_v.seq_num IS 'Sequence number of the question';
COMMENT ON COLUMN sa.table_scrqstnrsq_v.response IS 'Text of the response';
COMMENT ON COLUMN sa.table_scrqstnrsq_v.score IS 'Numeric score of the response';
COMMENT ON COLUMN sa.table_scrqstnrsq_v.nxtqstn_seq_num IS 'Sequence number of the next question';
COMMENT ON COLUMN sa.table_scrqstnrsq_v.nxtqstn_objid IS 'Internal record number of the question';
COMMENT ON COLUMN sa.table_scrqstnrsq_v.nxtqstn_question IS 'Text of the question';
COMMENT ON COLUMN sa.table_scrqstnrsq_v.parqstn_objid IS 'Objid of the parent question';