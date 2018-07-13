CREATE TABLE sa.x_retention_scenarios (
  objid NUMBER,
  x_src_service_plan_grp VARCHAR2(50 BYTE),
  x_dest_service_plan_grp VARCHAR2(50 BYTE),
  x_ret_scn2bus_org NUMBER
);
COMMENT ON TABLE sa.x_retention_scenarios IS 'DIFFERENT SCENARIOS BASED ON BUSINESS ACTIONS.';
COMMENT ON COLUMN sa.x_retention_scenarios.objid IS 'UNIQUE VALUES POPULATED USING SEQUENCE(SEQ_RETENTION_SCNS).';
COMMENT ON COLUMN sa.x_retention_scenarios.x_src_service_plan_grp IS 'SOURCE SERVICE PLAN GROUP.';
COMMENT ON COLUMN sa.x_retention_scenarios.x_dest_service_plan_grp IS 'DESTINATION SERVICE PLAN GROUP.';
COMMENT ON COLUMN sa.x_retention_scenarios.x_ret_scn2bus_org IS 'OBJID OF TABLE_BUS_ORG.';