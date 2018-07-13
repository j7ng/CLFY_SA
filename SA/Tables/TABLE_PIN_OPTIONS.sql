CREATE TABLE sa.table_pin_options (
  objid NUMBER NOT NULL,
  flow_scenario VARCHAR2(100 BYTE) NOT NULL,
  from_phone_scenario VARCHAR2(100 BYTE),
  to_phone_scenario VARCHAR2(100 BYTE),
  pin_reqd VARCHAR2(10 BYTE),
  created_date DATE DEFAULT SYSDATE,
  CONSTRAINT pk_pin_options PRIMARY KEY (objid),
  CONSTRAINT uk_pin_options UNIQUE (flow_scenario,from_phone_scenario,to_phone_scenario)
);
COMMENT ON TABLE sa.table_pin_options IS 'Pin options based on flow Scenario for PHONE Activation';
COMMENT ON COLUMN sa.table_pin_options.flow_scenario IS 'Flow Scenario (External Port/ Cross Company Port/ New Line Activation/ Phone Upgrade) ';
COMMENT ON COLUMN sa.table_pin_options.from_phone_scenario IS 'From Phone condition';
COMMENT ON COLUMN sa.table_pin_options.to_phone_scenario IS 'To Phone Condition';
COMMENT ON COLUMN sa.table_pin_options.pin_reqd IS 'PIN Required Options';