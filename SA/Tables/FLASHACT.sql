CREATE TABLE sa.flashact (
  x_service_id VARCHAR2(30 BYTE),
  transdate DATE,
  site_id VARCHAR2(80 BYTE)
);
ALTER TABLE sa.flashact ADD SUPPLEMENTAL LOG GROUP dmtsora105166693_0 (site_id, transdate, x_service_id) ALWAYS;