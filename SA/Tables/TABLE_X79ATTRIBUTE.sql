CREATE TABLE sa.table_x79attribute (
  objid NUMBER,
  dev NUMBER,
  attribute_id NUMBER,
  server_id NUMBER,
  single2x79trfmt_defn NUMBER,
  must2x79trfmt_defn NUMBER,
  may2x79trfmt_defn NUMBER
);
ALTER TABLE sa.table_x79attribute ADD SUPPLEMENTAL LOG GROUP dmtsora1850189145_0 (attribute_id, dev, may2x79trfmt_defn, must2x79trfmt_defn, objid, server_id, single2x79trfmt_defn) ALWAYS;