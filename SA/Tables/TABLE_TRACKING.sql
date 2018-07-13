CREATE TABLE sa.table_tracking (
  objid NUMBER,
  creation_time DATE,
  cs_high_count NUMBER,
  csde_high_count NUMBER,
  cq_high_count NUMBER,
  clfo_high_count NUMBER,
  csfts_high_cnt NUMBER,
  csftsde_high NUMBER,
  cqfts_high_cnt NUMBER,
  sfa_high_count NUMBER,
  ccn_high_count NUMBER,
  univ_high_cnt NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_tracking ADD SUPPLEMENTAL LOG GROUP dmtsora197323879_0 (ccn_high_count, clfo_high_count, cqfts_high_cnt, cq_high_count, creation_time, csde_high_count, csftsde_high, csfts_high_cnt, cs_high_count, dev, objid, sfa_high_count, univ_high_cnt) ALWAYS;