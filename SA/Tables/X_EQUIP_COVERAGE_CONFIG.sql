CREATE TABLE sa.x_equip_coverage_config (
  x_action VARCHAR2(30 BYTE),
  x_keep_data_serv NUMBER,
  x_port_type VARCHAR2(50 BYTE),
  x_handset_change NUMBER,
  x_sim_change NUMBER,
  x_cust_value NUMBER,
  x_trac_cost NUMBER,
  x_case_conf_objid NUMBER,
  x_case_issue VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_equip_coverage_config IS 'This configuration table is used during defective phone sim flow, to determine the best value alternative for the customer in terms of equipment changes or port requests.';
COMMENT ON COLUMN sa.x_equip_coverage_config.x_action IS 'Action: DEFECTIVE_SIM, DEFECTIVE_PHONE';
COMMENT ON COLUMN sa.x_equip_coverage_config.x_keep_data_serv IS 'Keep data service flag 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_equip_coverage_config.x_port_type IS 'Port request type, LINE_RESERVED, SAME_CARRIER, MANUAL, BLOCKED, NEW_LINE';
COMMENT ON COLUMN sa.x_equip_coverage_config.x_handset_change IS 'Handset Change Flag, 0=No 1=Yes';
COMMENT ON COLUMN sa.x_equip_coverage_config.x_sim_change IS 'SIM Change Flag, SIM Change Required 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_equip_coverage_config.x_cust_value IS 'Relative Value of the option for the customer.  Option of greater value will be selected from the available ones.';
COMMENT ON COLUMN sa.x_equip_coverage_config.x_trac_cost IS 'Not use, Obsolete';
COMMENT ON COLUMN sa.x_equip_coverage_config.x_case_conf_objid IS 'Foreign Key to table_x_case_conf_hdr';
COMMENT ON COLUMN sa.x_equip_coverage_config.x_case_issue IS 'Case Issue Literal to be use when creating the case.';