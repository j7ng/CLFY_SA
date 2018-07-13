CREATE TABLE sa.table_web_lease (
  objid NUMBER,
  lic_type VARCHAR2(30 BYTE),
  "CLASS" NUMBER,
  precedence NUMBER,
  expires DATE,
  host_id VARCHAR2(16 BYTE),
  dev NUMBER,
  owner2web_user NUMBER(*,0)
);
ALTER TABLE sa.table_web_lease ADD SUPPLEMENTAL LOG GROUP dmtsora2075383950_0 ("CLASS", dev, expires, host_id, lic_type, objid, owner2web_user, precedence) ALWAYS;