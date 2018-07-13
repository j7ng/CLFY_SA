CREATE TABLE sa.table_per_opp_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  rating VARCHAR2(20 BYTE),
  win_result VARCHAR2(255 BYTE),
  comments VARCHAR2(255 BYTE),
  split_percent NUMBER,
  "TYPE" VARCHAR2(20 BYTE),
  ind_mode VARCHAR2(20 BYTE),
  dev NUMBER,
  per_role2opportunity NUMBER(*,0),
  opp_role2person NUMBER(*,0)
);
ALTER TABLE sa.table_per_opp_role ADD SUPPLEMENTAL LOG GROUP dmtsora2024561905_0 ("ACTIVE", comments, dev, ind_mode, objid, opp_role2person, per_role2opportunity, rating, role_name, split_percent, "TYPE", win_result) ALWAYS;