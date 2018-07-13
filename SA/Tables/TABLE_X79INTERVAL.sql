CREATE TABLE sa.table_x79interval (
  objid NUMBER,
  dev NUMBER,
  days_of_week NUMBER,
  start_intvl NUMBER,
  end_intvl NUMBER,
  server_id NUMBER,
  access2x79location NUMBER
);
ALTER TABLE sa.table_x79interval ADD SUPPLEMENTAL LOG GROUP dmtsora314793117_0 (access2x79location, days_of_week, dev, end_intvl, objid, server_id, start_intvl) ALWAYS;