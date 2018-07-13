CREATE TABLE sa.x_reward_point_values (
  objid NUMBER NOT NULL,
  bus_org_objid NUMBER NOT NULL,
  service_plan_objid NUMBER,
  x_unit_points NUMBER,
  x_conversion_points NUMBER,
  benefit_program_objid NUMBER,
  x_point_category VARCHAR2(50 BYTE),
  x_priority NUMBER(3) DEFAULT 1,
  x_start_date DATE,
  x_end_date DATE
);
COMMENT ON TABLE sa.x_reward_point_values IS 'Configuration table which stores the points against equivalent dollar amount and priority';
COMMENT ON COLUMN sa.x_reward_point_values.objid IS 'UNIQUE RECORD IDENTIFIER';
COMMENT ON COLUMN sa.x_reward_point_values.bus_org_objid IS 'Refers the brand - Table_Bus_Org.Objid';
COMMENT ON COLUMN sa.x_reward_point_values.service_plan_objid IS 'Refers the service plan - X_SERVICE_PLAN.OBJID';
COMMENT ON COLUMN sa.x_reward_point_values.x_unit_points IS 'The points that a single use of service plan can offer (points per redemption)';
COMMENT ON COLUMN sa.x_reward_point_values.x_conversion_points IS 'How many points are equivalent to dollar amount';
COMMENT ON COLUMN sa.x_reward_point_values.benefit_program_objid IS 'Refers the program for which, the earned points can be converted to dollar amount - TABLE_X_BENEFIT_PROGRAMS.Objid';
COMMENT ON COLUMN sa.x_reward_point_values.x_point_category IS 'Points category';
COMMENT ON COLUMN sa.x_reward_point_values.x_priority IS 'Priority of service plan over each other';
COMMENT ON COLUMN sa.x_reward_point_values.x_start_date IS 'Start date - from date when the points can be converted to amount';
COMMENT ON COLUMN sa.x_reward_point_values.x_end_date IS 'End date - till what date the points can be converted to amount';