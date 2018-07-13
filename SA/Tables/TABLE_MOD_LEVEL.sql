CREATE TABLE sa.table_mod_level (
  objid NUMBER,
  mod_level VARCHAR2(20 BYTE),
  s_mod_level VARCHAR2(20 BYTE),
  "ACTIVE" VARCHAR2(10 BYTE),
  replaces_date DATE,
  eff_date DATE,
  end_date DATE,
  dev NUMBER,
  part_info2part_num NUMBER(*,0),
  part_info2log_info NUMBER(*,0),
  part_info2part_stats NUMBER(*,0),
  replacedpn2mod_level NUMBER(*,0),
  x_timetank VARCHAR2(1 BYTE),
  part_info2inv_ctrl NUMBER,
  config_type NUMBER
);
ALTER TABLE sa.table_mod_level ADD SUPPLEMENTAL LOG GROUP dmtsora1118156398_0 ("ACTIVE", config_type, dev, eff_date, end_date, mod_level, objid, part_info2inv_ctrl, part_info2log_info, part_info2part_num, part_info2part_stats, replacedpn2mod_level, replaces_date, s_mod_level, x_timetank) ALWAYS;
COMMENT ON TABLE sa.table_mod_level IS 'Defines a version (sometimes called a revision) of a generic part (see part_num) to the system. A generic part must have at least one version';
COMMENT ON COLUMN sa.table_mod_level.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_mod_level.mod_level IS 'Name of the part revision';
COMMENT ON COLUMN sa.table_mod_level."ACTIVE" IS 'Active/inactive/obsolete';
COMMENT ON COLUMN sa.table_mod_level.replaces_date IS 'If obsolete, specifies date and time of obsolescence';
COMMENT ON COLUMN sa.table_mod_level.eff_date IS 'The date the support program version becomes effective';
COMMENT ON COLUMN sa.table_mod_level.end_date IS 'The date the support program version expires';
COMMENT ON COLUMN sa.table_mod_level.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_mod_level.part_info2log_info IS 'Reserved; future';
COMMENT ON COLUMN sa.table_mod_level.part_info2part_stats IS 'The inventory count metrics object for the product';
COMMENT ON COLUMN sa.table_mod_level.replacedpn2mod_level IS 'Part which replaces the current part';
COMMENT ON COLUMN sa.table_mod_level.x_timetank IS 'TimeTank code';
COMMENT ON COLUMN sa.table_mod_level.part_info2inv_ctrl IS 'Inventory control group for the part_revison';
COMMENT ON COLUMN sa.table_mod_level.config_type IS 'Declares Configurator constraints for the part: i.e., 0=not to be configured, 1=configure as a product, 2=configure as an option, default=0';