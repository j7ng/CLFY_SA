CREATE TABLE sa.table_x_webcsr_log_param (
  objid NUMBER,
  dev NUMBER,
  x_counter_1 NUMBER,
  x_counter_2 NUMBER,
  x_counter_3 NUMBER,
  x_interaction_switch NUMBER,
  x_refurb_delay NUMBER,
  x_max_phone_units NUMBER,
  x_percen_extra_units NUMBER,
  x_expire_days NUMBER,
  x_create_sim_case_web NUMBER
);
ALTER TABLE sa.table_x_webcsr_log_param ADD SUPPLEMENTAL LOG GROUP dmtsora465932349_0 (dev, objid, x_counter_1, x_counter_2, x_counter_3, x_create_sim_case_web, x_expire_days, x_interaction_switch, x_max_phone_units, x_percen_extra_units, x_refurb_delay) ALWAYS;
COMMENT ON TABLE sa.table_x_webcsr_log_param IS 'webcsr log parameters';
COMMENT ON COLUMN sa.table_x_webcsr_log_param.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_webcsr_log_param.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_webcsr_log_param.x_counter_1 IS 'TBD';
COMMENT ON COLUMN sa.table_x_webcsr_log_param.x_counter_2 IS 'TBD';
COMMENT ON COLUMN sa.table_x_webcsr_log_param.x_counter_3 IS 'TBD';
COMMENT ON COLUMN sa.table_x_webcsr_log_param.x_interaction_switch IS '0 = Interactions Off, 1 = Interactions On';
COMMENT ON COLUMN sa.table_x_webcsr_log_param.x_refurb_delay IS 'number of days to protect recent activations from accidental refurbising';
COMMENT ON COLUMN sa.table_x_webcsr_log_param.x_max_phone_units IS 'Maximum number of units a phone would be allowed';
COMMENT ON COLUMN sa.table_x_webcsr_log_param.x_percen_extra_units IS '% Difference allowed when giving units';
COMMENT ON COLUMN sa.table_x_webcsr_log_param.x_expire_days IS 'Case expiration limit for R_U_T cases';
COMMENT ON COLUMN sa.table_x_webcsr_log_param.x_create_sim_case_web IS 'Flag to allow the creation of SIM exchanges in the WEB 0 = No, 1 = Yes';