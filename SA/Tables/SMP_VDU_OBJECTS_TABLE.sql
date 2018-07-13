CREATE TABLE sa.smp_vdu_objects_table (
  object_id NUMBER NOT NULL,
  "TYPE" VARCHAR2(128 BYTE) NOT NULL,
  "OWNER" VARCHAR2(128 BYTE) NOT NULL,
  object_name VARCHAR2(128 BYTE) NOT NULL,
  UNIQUE (object_id)
);
ALTER TABLE sa.smp_vdu_objects_table ADD SUPPLEMENTAL LOG GROUP dmtsora1573622123_0 (object_id, object_name, "OWNER", "TYPE") ALWAYS;