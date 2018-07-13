CREATE OR REPLACE FORCE VIEW sa.table_anlysrspn_v (objid,response,question,seq_num,anlys_objid) AS
select table_anlys_rspns.objid, table_anlys_rspns.text,
 table_question.text, table_question.seq_num,
 table_anlys_rspns.anlys_rspns2opp_analysis
 from table_anlys_rspns, table_question
 where table_question.objid = table_anlys_rspns.anlys_rspns2question
 AND table_anlys_rspns.anlys_rspns2opp_analysis IS NOT NULL
;
COMMENT ON TABLE sa.table_anlysrspn_v IS 'Responses to questions on an opportunity (9599)';
COMMENT ON COLUMN sa.table_anlysrspn_v.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_anlysrspn_v.response IS 'Response to the question';
COMMENT ON COLUMN sa.table_anlysrspn_v.question IS 'The question itself';
COMMENT ON COLUMN sa.table_anlysrspn_v.seq_num IS 'Order of the questions';
COMMENT ON COLUMN sa.table_anlysrspn_v.anlys_objid IS 'Opportunity analysis internal record number';