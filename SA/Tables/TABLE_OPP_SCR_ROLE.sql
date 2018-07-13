CREATE TABLE sa.table_opp_scr_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  as_of_date DATE,
  score NUMBER,
  dev NUMBER,
  scr_role2call_script NUMBER(*,0),
  scr_role2opportunity NUMBER(*,0)
);
ALTER TABLE sa.table_opp_scr_role ADD SUPPLEMENTAL LOG GROUP dmtsora715079517_0 ("ACTIVE", as_of_date, dev, focus_type, objid, role_name, score, scr_role2call_script, scr_role2opportunity) ALWAYS;