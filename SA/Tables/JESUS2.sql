CREATE TABLE sa.jesus2 (
  x_service_id VARCHAR2(30 BYTE),
  objid NUMBER,
  x_technology VARCHAR2(20 BYTE),
  x_restricted_use NUMBER,
  new_click_plan_objid NUMBER
);
ALTER TABLE sa.jesus2 ADD SUPPLEMENTAL LOG GROUP dmtsora459253103_0 (new_click_plan_objid, objid, x_restricted_use, x_service_id, x_technology) ALWAYS;