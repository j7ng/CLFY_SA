CREATE TABLE sa.x_safelink_plan_state (
  x_name_state VARCHAR2(40 BYTE),
  x_sms_rate NUMBER,
  x_ild NUMBER,
  x_sweep_and_add NUMBER,
  safe_st2prog_param NUMBER,
  x_date DATE,
  x_plan NUMBER,
  x_min NUMBER
);
COMMENT ON TABLE sa.x_safelink_plan_state IS 'Safelink Configuration Table, maps state to programs parameters.';
COMMENT ON COLUMN sa.x_safelink_plan_state.x_name_state IS 'State Abbreviation';
COMMENT ON COLUMN sa.x_safelink_plan_state.x_sms_rate IS 'Reference x_plan_id in table_x_click_plan';
COMMENT ON COLUMN sa.x_safelink_plan_state.x_ild IS 'ILD Service Flag: 0=No,1=Yes';
COMMENT ON COLUMN sa.x_safelink_plan_state.x_sweep_and_add IS 'Sweep and Add Flag: 0=No,1=Yes';
COMMENT ON COLUMN sa.x_safelink_plan_state.safe_st2prog_param IS 'Reference x_program_parameters';
COMMENT ON COLUMN sa.x_safelink_plan_state.x_date IS 'Date of record creation';
COMMENT ON COLUMN sa.x_safelink_plan_state.x_plan IS 'Plan Number withing the state: 1,2,3';
COMMENT ON COLUMN sa.x_safelink_plan_state.x_min IS 'Mobile Phone Number';