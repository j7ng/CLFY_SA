CREATE TABLE sa.table_rqst_skill (
  objid NUMBER,
  dev NUMBER,
  rqst_skill2skill NUMBER,
  rqst_skill2r_rqst NUMBER
);
ALTER TABLE sa.table_rqst_skill ADD SUPPLEMENTAL LOG GROUP dmtsora838913527_0 (dev, objid, rqst_skill2r_rqst, rqst_skill2skill) ALWAYS;