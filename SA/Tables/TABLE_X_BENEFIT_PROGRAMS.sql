CREATE TABLE sa.table_x_benefit_programs (
  objid NUMBER NOT NULL,
  x_program_name VARCHAR2(40 BYTE) NOT NULL,
  x_program_desc VARCHAR2(1000 BYTE),
  x_benefit_type VARCHAR2(50 BYTE),
  x_benefit_unit VARCHAR2(100 BYTE),
  x_benefit_value VARCHAR2(100 BYTE),
  x_priority NUMBER DEFAULT 1,
  partial_usage_allowed VARCHAR2(1 BYTE) DEFAULT 'N',
  purch_usage_allowed VARCHAR2(100 BYTE) DEFAULT 'ANY',
  x_benefit_owner VARCHAR2(100 BYTE),
  benefit_program2bus_org NUMBER,
  x_start_date DATE,
  x_end_date DATE
);
COMMENT ON TABLE sa.table_x_benefit_programs IS 'Lookup table which stores the benefit program that customer can earn';
COMMENT ON COLUMN sa.table_x_benefit_programs.objid IS 'Unique record identifier';
COMMENT ON COLUMN sa.table_x_benefit_programs.x_program_name IS 'benefit program name';
COMMENT ON COLUMN sa.table_x_benefit_programs.x_program_desc IS 'Description of the program';
COMMENT ON COLUMN sa.table_x_benefit_programs.x_benefit_type IS 'The benefit offered by this benefit program';
COMMENT ON COLUMN sa.table_x_benefit_programs.x_benefit_unit IS 'Unit of Benefit being offered (DOLLARS | MINUTES | POINTS | DATA | etc';
COMMENT ON COLUMN sa.table_x_benefit_programs.x_benefit_value IS 'Actual value of the Benefit';
COMMENT ON COLUMN sa.table_x_benefit_programs.x_priority IS 'Priority of the benefit program (1, 2, 3, etc)';
COMMENT ON COLUMN sa.table_x_benefit_programs.partial_usage_allowed IS 'Defines whether this benefit can be partially used ( Y=yes, N=No )';
COMMENT ON COLUMN sa.table_x_benefit_programs.purch_usage_allowed IS 'What can be purchased using this benefit (DEVICE_ONLY , ANY, AIRTIME_ONLY etc)';
COMMENT ON COLUMN sa.table_x_benefit_programs.x_benefit_owner IS 'The owner of the benefit (ESN or MIN or SID ACCOUNT etc)';
COMMENT ON COLUMN sa.table_x_benefit_programs.benefit_program2bus_org IS 'brand of the benefit - Refers Table_Bus_Org.Objid';
COMMENT ON COLUMN sa.table_x_benefit_programs.x_start_date IS 'Date program starts being available for customers';
COMMENT ON COLUMN sa.table_x_benefit_programs.x_end_date IS 'Date program stops being available for customers';