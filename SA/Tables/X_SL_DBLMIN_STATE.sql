CREATE TABLE sa.x_sl_dblmin_state (
  x_state VARCHAR2(40 BYTE),
  x_start DATE,
  x_end DATE
);
COMMENT ON TABLE sa.x_sl_dblmin_state IS 'Safelink Promotion Configuration Table.  states that are found in this table are given special treatment when granting runtime promotions.';
COMMENT ON COLUMN sa.x_sl_dblmin_state.x_state IS 'State Code';
COMMENT ON COLUMN sa.x_sl_dblmin_state.x_start IS 'Starts Date';
COMMENT ON COLUMN sa.x_sl_dblmin_state.x_end IS 'End Date';