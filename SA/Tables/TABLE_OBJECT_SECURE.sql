CREATE TABLE sa.table_object_secure (
  objid NUMBER,
  type_id NUMBER,
  flags NUMBER,
  "PATH" VARCHAR2(255 BYTE),
  prefix VARCHAR2(30 BYTE),
  "VALUE" VARCHAR2(255 BYTE),
  suffix VARCHAR2(30 BYTE),
  oper VARCHAR2(30 BYTE),
  dev NUMBER,
  object2privclass NUMBER(*,0),
  "RANK" NUMBER
);
ALTER TABLE sa.table_object_secure ADD SUPPLEMENTAL LOG GROUP dmtsora1022590676_0 (dev, flags, object2privclass, objid, oper, "PATH", prefix, "RANK", suffix, type_id, "VALUE") ALWAYS;