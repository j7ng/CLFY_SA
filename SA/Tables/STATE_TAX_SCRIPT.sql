CREATE TABLE sa.state_tax_script (
  x_state VARCHAR2(15 BYTE) NOT NULL,
  e911_tax_id VARCHAR2(255 BYTE),
  tax_footer_id VARCHAR2(255 BYTE),
  CONSTRAINT x_state_tax_script_zip_unique UNIQUE (x_state)
);
COMMENT ON COLUMN sa.state_tax_script.x_state IS 'STATE ABBREVIATION, DEF is default';
COMMENT ON COLUMN sa.state_tax_script.e911_tax_id IS 'E911 SCRIPT LABEL';
COMMENT ON COLUMN sa.state_tax_script.tax_footer_id IS 'TAX SCRIPT LABEL';