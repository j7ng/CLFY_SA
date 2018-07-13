CREATE TABLE sa.x_flows (
  x_flow_objid NUMBER,
  x_flow_name VARCHAR2(100 BYTE),
  x_flow_descr VARCHAR2(200 BYTE),
  create_date DATE,
  CONSTRAINT flow_uq UNIQUE (x_flow_name)
);
COMMENT ON TABLE sa.x_flows IS 'Error Mapping,Process Flow Entries';
COMMENT ON COLUMN sa.x_flows.x_flow_objid IS 'Primary Key, Unique Identifier';
COMMENT ON COLUMN sa.x_flows.x_flow_name IS 'Name of the process flow';
COMMENT ON COLUMN sa.x_flows.x_flow_descr IS 'Description of the process flow';
COMMENT ON COLUMN sa.x_flows.create_date IS 'Sysdate at the time of record creation';