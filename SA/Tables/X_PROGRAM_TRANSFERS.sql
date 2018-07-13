CREATE TABLE sa.x_program_transfers (
  pgm_transfer2_pgm_enrolled NUMBER,
  x_old_esn VARCHAR2(30 BYTE),
  x_new_esn VARCHAR2(30 BYTE),
  x_prog_class VARCHAR2(10 BYTE),
  x_transfer_reason VARCHAR2(300 BYTE),
  x_transfer_date DATE
);
COMMENT ON TABLE sa.x_program_transfers IS 'Table stores the transfer of programs from one ESN to another ESN.';
COMMENT ON COLUMN sa.x_program_transfers.pgm_transfer2_pgm_enrolled IS 'refers  X_PROGRAM_ENROLLED.OBJID';
COMMENT ON COLUMN sa.x_program_transfers.x_old_esn IS 'Old ESN number from which the program gets transferred';
COMMENT ON COLUMN sa.x_program_transfers.x_new_esn IS 'New ESN number to which the program will get transferred';
COMMENT ON COLUMN sa.x_program_transfers.x_prog_class IS 'Indicates which program has got transferred from Old ESN to New ESN';
COMMENT ON COLUMN sa.x_program_transfers.x_transfer_reason IS 'Explanation why transfer of program have been made';
COMMENT ON COLUMN sa.x_program_transfers.x_transfer_date IS 'Date when the program got transferred from old to new ESN';