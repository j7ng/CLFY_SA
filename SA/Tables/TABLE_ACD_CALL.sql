CREATE TABLE sa.table_acd_call (
  objid NUMBER,
  creation_time DATE,
  call_id NUMBER,
  dev NUMBER,
  acd_call_case2case NUMBER(*,0),
  acd_call_site2site NUMBER(*,0),
  acd_call_empl2user NUMBER(*,0),
  acd_call_subcase2subcase NUMBER(*,0)
);
ALTER TABLE sa.table_acd_call ADD SUPPLEMENTAL LOG GROUP dmtsora505157530_0 (acd_call_case2case, acd_call_empl2user, acd_call_site2site, acd_call_subcase2subcase, call_id, creation_time, dev, objid) ALWAYS;