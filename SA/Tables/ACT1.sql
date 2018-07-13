CREATE TABLE sa.act1 (
  x_service_id VARCHAR2(30 BYTE),
  objid NUMBER,
  transdate DATE
);
ALTER TABLE sa.act1 ADD SUPPLEMENTAL LOG GROUP dmtsora1213356299_0 (objid, transdate, x_service_id) ALWAYS;