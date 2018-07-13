CREATE TABLE sa.table_con_opp_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  comments VARCHAR2(255 BYTE),
  focus_type NUMBER,
  orientation VARCHAR2(25 BYTE),
  time_spent VARCHAR2(25 BYTE),
  your_status VARCHAR2(25 BYTE),
  dev NUMBER,
  con_role2opportunity NUMBER(*,0),
  opp_role2contact NUMBER(*,0)
);
ALTER TABLE sa.table_con_opp_role ADD SUPPLEMENTAL LOG GROUP dmtsora1730388235_0 ("ACTIVE", comments, con_role2opportunity, dev, focus_type, objid, opp_role2contact, orientation, role_name, time_spent, your_status) ALWAYS;