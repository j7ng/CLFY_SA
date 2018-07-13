CREATE TABLE sa.adfcrm_solution_script_tokens (
  token VARCHAR2(100 BYTE) NOT NULL,
  description VARCHAR2(400 BYTE) NOT NULL,
  token_value VARCHAR2(4000 BYTE) NOT NULL,
  changed_date DATE DEFAULT SYSDATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE),
  CONSTRAINT adfcrm_sol_script_token_pk PRIMARY KEY (token)
);
COMMENT ON TABLE sa.adfcrm_solution_script_tokens IS 'All tokens currently underway.';
COMMENT ON COLUMN sa.adfcrm_solution_script_tokens.token IS 'Token';
COMMENT ON COLUMN sa.adfcrm_solution_script_tokens.description IS 'Token description';
COMMENT ON COLUMN sa.adfcrm_solution_script_tokens.token_value IS 'Statement or Expression to replace token';
COMMENT ON COLUMN sa.adfcrm_solution_script_tokens.changed_date IS 'Date in which the change was done';
COMMENT ON COLUMN sa.adfcrm_solution_script_tokens.changed_by IS 'User that perform the change';
COMMENT ON COLUMN sa.adfcrm_solution_script_tokens.change_type IS 'Type of change INSERT/DELETE/UPDATE';