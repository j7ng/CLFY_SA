CREATE TABLE sa.adfcrm_sui_actions_mtm (
  rule_objid NUMBER,
  action_objid NUMBER,
  actions_mtm_objid NUMBER NOT NULL,
  on_demand VARCHAR2(50 BYTE),
  agent_restricted VARCHAR2(50 BYTE),
  x_permission VARCHAR2(50 BYTE),
  task_flow VARCHAR2(100 BYTE),
  display_sequence NUMBER,
  CONSTRAINT adfcrm_sui_actions_mtm_pk PRIMARY KEY (actions_mtm_objid)
);