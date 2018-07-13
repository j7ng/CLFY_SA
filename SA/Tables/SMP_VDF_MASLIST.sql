CREATE TABLE sa.smp_vdf_maslist (
  mas_name VARCHAR2(128 BYTE),
  "TIMESTAMP" DATE
);
ALTER TABLE sa.smp_vdf_maslist ADD SUPPLEMENTAL LOG GROUP dmtsora1343158791_0 (mas_name, "TIMESTAMP") ALWAYS;