CREATE TABLE sa.table_script_qstn (
  objid NUMBER,
  seq_num NUMBER,
  question VARCHAR2(255 BYTE),
  answer VARCHAR2(255 BYTE),
  status VARCHAR2(30 BYTE),
  long_question LONG,
  "ACTION" VARCHAR2(255 BYTE),
  s_action VARCHAR2(255 BYTE),
  parm VARCHAR2(255 BYTE),
  s_parm VARCHAR2(255 BYTE),
  dev NUMBER,
  question2call_script NUMBER(*,0),
  q_next_q2script_qstn NUMBER(*,0),
  resp_type2gbst_elm NUMBER(*,0),
  q_next_s2call_script NUMBER(*,0),
  q_play_s2call_script NUMBER(*,0),
  embed_func VARCHAR2(255 BYTE),
  s_embed_func VARCHAR2(255 BYTE),
  embed_parm VARCHAR2(255 BYTE),
  s_embed_parm VARCHAR2(255 BYTE),
  x_end_qstn NUMBER
);
ALTER TABLE sa.table_script_qstn ADD SUPPLEMENTAL LOG GROUP dmtsora636636885_0 ("ACTION", answer, dev, embed_func, embed_parm, objid, parm, question, question2call_script, q_next_q2script_qstn, q_next_s2call_script, q_play_s2call_script, resp_type2gbst_elm, seq_num, status, s_action, s_embed_func, s_embed_parm, s_parm, x_end_qstn) ALWAYS;
COMMENT ON TABLE sa.table_script_qstn IS 'Prompts (questions) for call scripts';
COMMENT ON COLUMN sa.table_script_qstn.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_script_qstn.seq_num IS 'Sequence number of the question';
COMMENT ON COLUMN sa.table_script_qstn.question IS 'Text of the question if length is within 255 characters';
COMMENT ON COLUMN sa.table_script_qstn.answer IS 'Text of the answer to the question';
COMMENT ON COLUMN sa.table_script_qstn.status IS 'Question status. This is from a user-defined popup';
COMMENT ON COLUMN sa.table_script_qstn.long_question IS 'Text of the question if longer than 255 characters';
COMMENT ON COLUMN sa.table_script_qstn."ACTION" IS 'Action to take if the response is selected';
COMMENT ON COLUMN sa.table_script_qstn.parm IS 'Parameter set for the action';
COMMENT ON COLUMN sa.table_script_qstn.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_script_qstn.q_next_q2script_qstn IS 'Next question to be branched to';
COMMENT ON COLUMN sa.table_script_qstn.resp_type2gbst_elm IS 'Type of response expected: e.g., multi-select, single select, etc';
COMMENT ON COLUMN sa.table_script_qstn.q_next_s2call_script IS 'Next script to be branched to';
COMMENT ON COLUMN sa.table_script_qstn.q_play_s2call_script IS 'Next script to be played';
COMMENT ON COLUMN sa.table_script_qstn.embed_func IS 'Embeded function used for processing embeded text';
COMMENT ON COLUMN sa.table_script_qstn.embed_parm IS 'Parameter set for the embed func';
COMMENT ON COLUMN sa.table_script_qstn.x_end_qstn IS 'TBD';