CREATE TABLE sa.x_mtm_program_msrp (
  objid NUMBER,
  pgm_msrp2handset_msrp_tier NUMBER,
  pgm_msrp2pgm_parameter NUMBER
);
COMMENT ON TABLE sa.x_mtm_program_msrp IS 'HOLDS MAPPINGS BETWEEN PROGRAMS AND MSRP TIERS.';
COMMENT ON COLUMN sa.x_mtm_program_msrp.objid IS 'INTERNAL UNIQUE IDENTIFIER.';
COMMENT ON COLUMN sa.x_mtm_program_msrp.pgm_msrp2handset_msrp_tier IS 'REFERENCES TO TABLE_HANDSET_MSRP_TIERS.HANDSET_MSRP_TIER';
COMMENT ON COLUMN sa.x_mtm_program_msrp.pgm_msrp2pgm_parameter IS 'REFERENCES TO X_PROGRAM_PARAMETERS.OBJID.';