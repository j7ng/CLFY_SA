CREATE TABLE sa.package_switch (
  package_id NUMBER NOT NULL,
  package_active VARCHAR2(1 BYTE) NOT NULL CONSTRAINT check_package CHECK (package_active in ('A','B')),
  package_a VARCHAR2(50 BYTE) NOT NULL,
  package_b VARCHAR2(50 BYTE)
);
ALTER TABLE sa.package_switch ADD SUPPLEMENTAL LOG GROUP dmtsora2053061802_0 (package_a, package_active, package_b, package_id) ALWAYS;