CREATE TABLE sa.table_scrqstn_rspns (
  objid NUMBER,
  seq_num NUMBER,
  response VARCHAR2(255 BYTE),
  s_response VARCHAR2(255 BYTE),
  score NUMBER,
  is_default NUMBER,
  editable_ind NUMBER,
  "ACTION" VARCHAR2(255 BYTE),
  s_action VARCHAR2(255 BYTE),
  parm VARCHAR2(255 BYTE),
  s_parm VARCHAR2(255 BYTE),
  dev NUMBER,
  current2script_qstn NUMBER(*,0),
  next2script_qstn NUMBER(*,0),
  r_next_s2call_script NUMBER(*,0),
  r_play_s2call_script NUMBER(*,0)
);
ALTER TABLE sa.table_scrqstn_rspns ADD SUPPLEMENTAL LOG GROUP dmtsora1860243310_0 ("ACTION", current2script_qstn, dev, editable_ind, is_default, next2script_qstn, objid, parm, response, r_next_s2call_script, r_play_s2call_script, score, seq_num, s_action, s_parm, s_response) ALWAYS;
COMMENT ON TABLE sa.table_scrqstn_rspns IS 'Predefined responses or possible choices for script prompts (questions)';
COMMENT ON COLUMN sa.table_scrqstn_rspns.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_scrqstn_rspns.seq_num IS 'Sequence number of the response';
COMMENT ON COLUMN sa.table_scrqstn_rspns.response IS 'Text of the response';
COMMENT ON COLUMN sa.table_scrqstn_rspns.score IS 'Numeric score of the response';
COMMENT ON COLUMN sa.table_scrqstn_rspns.is_default IS 'Is the default response. For multi-select prompts, there may be more than one default response';
COMMENT ON COLUMN sa.table_scrqstn_rspns.editable_ind IS 'Actual response may be modified when used: 0= no, 1=yes';
COMMENT ON COLUMN sa.table_scrqstn_rspns."ACTION" IS 'Action to take if the response is selected';
COMMENT ON COLUMN sa.table_scrqstn_rspns.parm IS 'Parameter set for the action';
COMMENT ON COLUMN sa.table_scrqstn_rspns.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_scrqstn_rspns.current2script_qstn IS 'Current call script question';
COMMENT ON COLUMN sa.table_scrqstn_rspns.next2script_qstn IS 'Next call script question. The response traggers a jump to an out-of-sequence script question';
COMMENT ON COLUMN sa.table_scrqstn_rspns.r_next_s2call_script IS 'Script branched to from the response';
COMMENT ON COLUMN sa.table_scrqstn_rspns.r_play_s2call_script IS 'Script played from the current response';