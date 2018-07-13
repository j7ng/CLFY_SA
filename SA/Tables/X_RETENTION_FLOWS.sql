CREATE TABLE sa.x_retention_flows (
  objid NUMBER,
  x_flow_name VARCHAR2(30 BYTE),
  x_flow_description VARCHAR2(100 BYTE),
  x_source_system VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_retention_flows IS 'FLOWS(JAVA) BASED ON THE BUSINESS ACTIONS.';
COMMENT ON COLUMN sa.x_retention_flows.objid IS 'UNIQUE VALUES POPULATED USING SEQUENCE(SEQ_RETENTION_FLOWS).';
COMMENT ON COLUMN sa.x_retention_flows.x_flow_name IS 'NAME OF EACH FLOW.';
COMMENT ON COLUMN sa.x_retention_flows.x_flow_description IS 'PURPOSE OF THE PARTICULAR FLOW.';
COMMENT ON COLUMN sa.x_retention_flows.x_source_system IS 'DIFFERENT CHANNELS WHERE IS FLOW EXISTS.';