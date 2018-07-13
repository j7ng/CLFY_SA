CREATE TABLE sa.table_scr_response (
  objid NUMBER,
  response VARCHAR2(255 BYTE),
  s_response VARCHAR2(255 BYTE),
  question VARCHAR2(255 BYTE),
  s_question VARCHAR2(255 BYTE),
  score NUMBER,
  seq_num NUMBER,
  create_date DATE,
  dev NUMBER,
  answ2scrqstn_rspns NUMBER(*,0),
  response2scr_run NUMBER(*,0),
  first_scr2scr_run NUMBER(*,0)
);
ALTER TABLE sa.table_scr_response ADD SUPPLEMENTAL LOG GROUP dmtsora1314658893_0 (answ2scrqstn_rspns, create_date, dev, first_scr2scr_run, objid, question, response, response2scr_run, score, seq_num, s_question, s_response) ALWAYS;