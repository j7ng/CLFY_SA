CREATE TABLE sa.smp_vdu_privilege_table (
  principal_oid NUMBER NOT NULL,
  privilege_string VARCHAR2(128 BYTE) NOT NULL,
  object_oid NUMBER NOT NULL
);
ALTER TABLE sa.smp_vdu_privilege_table ADD SUPPLEMENTAL LOG GROUP dmtsora570436229_0 (object_oid, principal_oid, privilege_string) ALWAYS;