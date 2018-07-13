CREATE TABLE sa.table_opp_analysis (
  objid NUMBER,
  as_of_date DATE,
  dev NUMBER,
  analysis2opportunity NUMBER(*,0),
  analysis2bus_org NUMBER(*,0)
);
ALTER TABLE sa.table_opp_analysis ADD SUPPLEMENTAL LOG GROUP dmtsora1363033937_0 (analysis2bus_org, analysis2opportunity, as_of_date, dev, objid) ALWAYS;