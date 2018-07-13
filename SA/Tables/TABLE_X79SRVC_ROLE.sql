CREATE TABLE sa.table_x79srvc_role (
  objid NUMBER,
  dev NUMBER,
  role_name VARCHAR2(80 BYTE),
  server_id NUMBER,
  spt_role2x79service NUMBER,
  service2x79service NUMBER
);
ALTER TABLE sa.table_x79srvc_role ADD SUPPLEMENTAL LOG GROUP dmtsora1580390449_0 (dev, objid, role_name, server_id, service2x79service, spt_role2x79service) ALWAYS;