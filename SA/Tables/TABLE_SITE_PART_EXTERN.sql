CREATE TABLE sa.table_site_part_extern (
  objid NUMBER,
  dev NUMBER,
  last_update DATE,
  ext_src VARCHAR2(30 BYTE),
  ext_ref VARCHAR2(64 BYTE),
  site_part_extern2site_part NUMBER
);
ALTER TABLE sa.table_site_part_extern ADD SUPPLEMENTAL LOG GROUP dmtsora1426312432_0 (dev, ext_ref, ext_src, last_update, objid, site_part_extern2site_part) ALWAYS;