CREATE TABLE sa.table_anlys_rspns (
  objid NUMBER,
  "TEXT" VARCHAR2(25 BYTE),
  dev NUMBER,
  anlys_rspns2opp_analysis NUMBER(*,0),
  anlys_rspns2question NUMBER(*,0)
);
ALTER TABLE sa.table_anlys_rspns ADD SUPPLEMENTAL LOG GROUP dmtsora2200915_0 (anlys_rspns2opp_analysis, anlys_rspns2question, dev, objid, "TEXT") ALWAYS;