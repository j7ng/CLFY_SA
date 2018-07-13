CREATE TABLE sa.adfcrm_script_token_variables (
  var_name VARCHAR2(30 BYTE),
  org_objid NUMBER,
  language VARCHAR2(30 BYTE),
  description VARCHAR2(30 BYTE),
  var_value VARCHAR2(4000 BYTE),
  CONSTRAINT constraint_name UNIQUE (var_name,org_objid,language)
);
COMMENT ON TABLE sa.adfcrm_script_token_variables IS 'TO STORE SCRIPTING ERROR MAPPINGS THAT WILL BE USED IN ADF/TAS.';
COMMENT ON COLUMN sa.adfcrm_script_token_variables.var_name IS 'NAME OF THE VARIABLE.';
COMMENT ON COLUMN sa.adfcrm_script_token_variables.org_objid IS 'BRAND. BUS ORG ID.';
COMMENT ON COLUMN sa.adfcrm_script_token_variables.language IS 'LANGUAGE';
COMMENT ON COLUMN sa.adfcrm_script_token_variables.description IS 'DETAILS OF VARIABLES.';
COMMENT ON COLUMN sa.adfcrm_script_token_variables.var_value IS 'VALUE OF THE VARIABLE.';