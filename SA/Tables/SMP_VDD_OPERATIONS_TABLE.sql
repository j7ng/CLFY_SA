CREATE TABLE sa.smp_vdd_operations_table (
  request_id NUMBER(9) NOT NULL,
  request_subtype VARCHAR2(128 BYTE) NOT NULL,
  request_type VARCHAR2(128 BYTE) NOT NULL,
  target VARCHAR2(128 BYTE) NOT NULL,
  node VARCHAR2(128 BYTE) NOT NULL,
  user_name VARCHAR2(128 BYTE) NOT NULL,
  "OWNER" VARCHAR2(128 BYTE),
  "CALLBACK" VARCHAR2(128 BYTE),
  "TIMESTAMP" NUMBER(20),
  outgoing CHAR,
  sequence_num NUMBER(*,0)
);
ALTER TABLE sa.smp_vdd_operations_table ADD SUPPLEMENTAL LOG GROUP dmtsora211849079_0 ("CALLBACK", node, outgoing, "OWNER", request_id, request_subtype, request_type, sequence_num, target, "TIMESTAMP", user_name) ALWAYS;