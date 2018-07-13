CREATE TABLE sa.x_e911_state_label (
  x_state VARCHAR2(15 BYTE) NOT NULL,
  x_script_id VARCHAR2(255 BYTE)
);
COMMENT ON TABLE sa.x_e911_state_label IS 'Script Label for E911 states ';
COMMENT ON COLUMN sa.x_e911_state_label.x_state IS 'State Name';
COMMENT ON COLUMN sa.x_e911_state_label.x_script_id IS 'Script Label';