CREATE TABLE sa.table_r_rqst (
  objid NUMBER,
  dev NUMBER,
  source_type NUMBER,
  source_lowid NUMBER,
  "TYPE" NUMBER,
  request_state NUMBER,
  last_update DATE,
  skill_rule_ind NUMBER,
  skill_ind NUMBER,
  rsrc_rule_ind NUMBER,
  resource_ind NUMBER,
  dest_type NUMBER,
  "PRIORITY" NUMBER,
  arch_ind NUMBER,
  r_rqst2rsrc NUMBER,
  r_contact2contact NUMBER
);
ALTER TABLE sa.table_r_rqst ADD SUPPLEMENTAL LOG GROUP dmtsora895182817_0 (arch_ind, dest_type, dev, last_update, objid, "PRIORITY", request_state, resource_ind, rsrc_rule_ind, r_contact2contact, r_rqst2rsrc, skill_ind, skill_rule_ind, source_lowid, source_type, "TYPE") ALWAYS;