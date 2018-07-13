CREATE TABLE sa.table_opp_qstn (
  objid NUMBER,
  seq_num NUMBER,
  question VARCHAR2(80 BYTE),
  answer VARCHAR2(255 BYTE),
  poss_answer VARCHAR2(255 BYTE),
  status VARCHAR2(30 BYTE),
  dev NUMBER,
  opp_qstn2opportunity NUMBER(*,0)
);
ALTER TABLE sa.table_opp_qstn ADD SUPPLEMENTAL LOG GROUP dmtsora92362886_0 (answer, dev, objid, opp_qstn2opportunity, poss_answer, question, seq_num, status) ALWAYS;