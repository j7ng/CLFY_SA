CREATE TABLE sa.adfcrm_sui_actions (
  action_objid NUMBER NOT NULL,
  action_name VARCHAR2(50 BYTE),
  ig_order_type VARCHAR2(20 BYTE),
  display_label VARCHAR2(50 BYTE),
  action_parent_id NUMBER,
  task_flow VARCHAR2(100 BYTE),
  on_demand VARCHAR2(50 BYTE),
  agent_restricted VARCHAR2(50 BYTE),
  x_permission VARCHAR2(50 BYTE),
  carrier_tech_script_type VARCHAR2(10 BYTE),
  CONSTRAINT adfcrm_sui_actions_pk PRIMARY KEY (action_objid)
);
COMMENT ON COLUMN sa.adfcrm_sui_actions.carrier_tech_script_type IS 'Speficy the type of script that will be used, current values supported are C (Carrier),CT (Carrier and Technology), and T (Technology) or null for regular script';