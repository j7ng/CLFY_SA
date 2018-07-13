CREATE TABLE sa.x_program_upgrade (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_replacement_esn VARCHAR2(30 BYTE),
  x_type VARCHAR2(30 BYTE),
  x_date DATE,
  x_status VARCHAR2(30 BYTE),
  x_description VARCHAR2(250 BYTE),
  pgm_upgrade2case NUMBER
);
ALTER TABLE sa.x_program_upgrade ADD SUPPLEMENTAL LOG GROUP dmtsora1832598658_0 (objid, pgm_upgrade2case, x_date, x_description, x_esn, x_replacement_esn, x_status, x_type) ALWAYS;
COMMENT ON TABLE sa.x_program_upgrade IS 'Support table for billing program upgrades, billing program moves from one ESN to a New ESN';
COMMENT ON COLUMN sa.x_program_upgrade.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_program_upgrade.x_esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_program_upgrade.x_replacement_esn IS 'Replacement ESN, Serial Number New Phone';
COMMENT ON COLUMN sa.x_program_upgrade.x_type IS 'Type of Upgrade';
COMMENT ON COLUMN sa.x_program_upgrade.x_date IS 'Timestamp of Upgrade';
COMMENT ON COLUMN sa.x_program_upgrade.x_status IS 'Status of the upgrade: SUCCESS, FAILED';
COMMENT ON COLUMN sa.x_program_upgrade.x_description IS 'Description of the transaction outcome';
COMMENT ON COLUMN sa.x_program_upgrade.pgm_upgrade2case IS 'Reference to table_case';