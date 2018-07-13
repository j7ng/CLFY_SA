CREATE TABLE sa.smp_vdu_principals_table (
  principal_id NUMBER NOT NULL,
  "TYPE" VARCHAR2(128 BYTE) NOT NULL,
  principal_name VARCHAR2(128 BYTE) NOT NULL,
  "PASSWORD" RAW(128) NOT NULL,
  UNIQUE (principal_id)
);
ALTER TABLE sa.smp_vdu_principals_table ADD SUPPLEMENTAL LOG GROUP dmtsora1686541669_0 ("PASSWORD", principal_id, principal_name, "TYPE") ALWAYS;