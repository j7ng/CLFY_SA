CREATE TABLE sa.table_opp_response (
  objid NUMBER,
  response VARCHAR2(255 BYTE),
  question VARCHAR2(255 BYTE),
  score NUMBER,
  seq_num NUMBER,
  dev NUMBER,
  answer2scrqstn_rspns NUMBER(*,0),
  response2opp_scr_role NUMBER(*,0)
);
ALTER TABLE sa.table_opp_response ADD SUPPLEMENTAL LOG GROUP dmtsora298496787_0 (answer2scrqstn_rspns, dev, objid, question, response, response2opp_scr_role, score, seq_num) ALWAYS;