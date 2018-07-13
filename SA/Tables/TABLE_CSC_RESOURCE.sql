CREATE TABLE sa.table_csc_resource (
  objid NUMBER,
  resource_type VARCHAR2(30 BYTE),
  unit_of_measure VARCHAR2(20 BYTE),
  quantity NUMBER,
  server_id NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_csc_resource ADD SUPPLEMENTAL LOG GROUP dmtsora1448119784_0 (dev, objid, quantity, resource_type, server_id, unit_of_measure) ALWAYS;