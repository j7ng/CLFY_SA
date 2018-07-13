CREATE TABLE sa.jjw_site_part_rel (
  x_site_objid NUMBER,
  x_site_part_objid NUMBER
);
ALTER TABLE sa.jjw_site_part_rel ADD SUPPLEMENTAL LOG GROUP dmtsora547774706_0 (x_site_objid, x_site_part_objid) ALWAYS;