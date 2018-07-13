CREATE TABLE sa.x_sl_upgrade_program_config (
  from_pgm_objid NUMBER,
  from_pgm_name VARCHAR2(100 BYTE),
  to_pgm_objid NUMBER,
  to_pgm_name VARCHAR2(100 BYTE)
);
COMMENT ON TABLE sa.x_sl_upgrade_program_config IS 'Safelink BYOP/Andriod upgrade config table';
COMMENT ON COLUMN sa.x_sl_upgrade_program_config.from_pgm_objid IS 'from Lifeline program obj id';
COMMENT ON COLUMN sa.x_sl_upgrade_program_config.from_pgm_name IS 'from Lifeline program name';
COMMENT ON COLUMN sa.x_sl_upgrade_program_config.to_pgm_objid IS 'to lifeline program obj id';
COMMENT ON COLUMN sa.x_sl_upgrade_program_config.to_pgm_name IS 'to lifeline program name';