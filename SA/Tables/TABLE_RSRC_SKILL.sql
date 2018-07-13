CREATE TABLE sa.table_rsrc_skill (
  objid NUMBER,
  dev NUMBER,
  rsrc_skill2skill NUMBER,
  rsrc_skill2rsrc NUMBER
);
ALTER TABLE sa.table_rsrc_skill ADD SUPPLEMENTAL LOG GROUP dmtsora1179356788_0 (dev, objid, rsrc_skill2rsrc, rsrc_skill2skill) ALWAYS;