CREATE TABLE sa.x_referral_programs (
  objid NUMBER,
  x_program_id VARCHAR2(30 BYTE),
  x_program_desc VARCHAR2(100 BYTE),
  x_referral_program2bus_org NUMBER,
  x_start_date DATE,
  x_end_date DATE,
  x_units VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_referral_programs IS 'Table having list of Referral programs.';
COMMENT ON COLUMN sa.x_referral_programs.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_referral_programs.x_program_id IS 'Program ID';
COMMENT ON COLUMN sa.x_referral_programs.x_program_desc IS 'Program Description';
COMMENT ON COLUMN sa.x_referral_programs.x_referral_program2bus_org IS 'Business entity or Brand name';
COMMENT ON COLUMN sa.x_referral_programs.x_start_date IS 'Referral program Start date';
COMMENT ON COLUMN sa.x_referral_programs.x_end_date IS 'Referral program end date';
COMMENT ON COLUMN sa.x_referral_programs.x_units IS 'Features of the program';