CREATE TABLE sa.x_bogo_action_type (
  action_type VARCHAR2(240 BYTE) NOT NULL
);
COMMENT ON TABLE sa.x_bogo_action_type IS 'TF BOGO valid action type per brand';
COMMENT ON COLUMN sa.x_bogo_action_type.action_type IS 'BOGO application action type';