CREATE TABLE sa.table_opp_data (
  objid NUMBER,
  seq_num NUMBER,
  text_value LONG,
  dev NUMBER,
  opp_data2bus_opp_role NUMBER(*,0),
  opp_data2opportunity NUMBER(*,0)
);
ALTER TABLE sa.table_opp_data ADD SUPPLEMENTAL LOG GROUP dmtsora1117183297_0 (dev, objid, opp_data2bus_opp_role, opp_data2opportunity, seq_num) ALWAYS;