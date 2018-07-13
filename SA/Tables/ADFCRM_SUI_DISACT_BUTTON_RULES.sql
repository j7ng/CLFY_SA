CREATE TABLE sa.adfcrm_sui_disact_button_rules (
  rule_objid NUMBER,
  action_objid NUMBER,
  criteria VARCHAR2(30 BYTE),
  search_string VARCHAR2(200 BYTE),
  sql_string CLOB
);
COMMENT ON COLUMN sa.adfcrm_sui_disact_button_rules.criteria IS 'Speficy the criteria type to determine what action to take. by default the criteria is SQL, i left it open for scalability in the future.';
COMMENT ON COLUMN sa.adfcrm_sui_disact_button_rules.sql_string IS 'Speficy an sql statement. it must always return FAIL or PASS. it must always select into v_out_var. example: select decode(count(*),''0'',''FAIL'',''PASS'') into v_out_var from table_part_inst where part_serial_no  = v_esn';