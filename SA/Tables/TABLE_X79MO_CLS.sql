CREATE TABLE sa.table_x79mo_cls (
  objid NUMBER,
  dev NUMBER,
  class_id NUMBER,
  server_id NUMBER,
  class2x79trfmt_defn NUMBER
);
ALTER TABLE sa.table_x79mo_cls ADD SUPPLEMENTAL LOG GROUP dmtsora655236378_0 (class2x79trfmt_defn, class_id, dev, objid, server_id) ALWAYS;