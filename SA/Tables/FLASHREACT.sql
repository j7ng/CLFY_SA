CREATE TABLE sa.flashreact (
  x_service_id VARCHAR2(30 BYTE),
  transdate DATE,
  site_id VARCHAR2(80 BYTE)
);
ALTER TABLE sa.flashreact ADD SUPPLEMENTAL LOG GROUP dmtsora1129294802_0 (site_id, transdate, x_service_id) ALWAYS;