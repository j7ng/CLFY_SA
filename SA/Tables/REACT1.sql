CREATE TABLE sa.react1 (
  x_service_id VARCHAR2(30 BYTE),
  objid NUMBER,
  transdate DATE
);
ALTER TABLE sa.react1 ADD SUPPLEMENTAL LOG GROUP dmtsora1215060542_0 (objid, transdate, x_service_id) ALWAYS;