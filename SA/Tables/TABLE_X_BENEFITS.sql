CREATE TABLE sa.table_x_benefits (
  objid NUMBER NOT NULL,
  x_benefit_owner_type VARCHAR2(50 BYTE),
  x_benefit_owner_value VARCHAR2(50 BYTE),
  x_created_date DATE DEFAULT SYSDATE,
  x_status VARCHAR2(20 BYTE),
  x_notes VARCHAR2(1000 BYTE),
  benefits2benefit_program NUMBER,
  x_update_date DATE,
  x_expiry_date DATE
);
COMMENT ON TABLE sa.table_x_benefits IS 'benefits transaction table; stores the actual benefits that belong to an ESN or MIN or SUBID or ACCOUNT etc.';
COMMENT ON COLUMN sa.table_x_benefits.objid IS 'unique record identifier';
COMMENT ON COLUMN sa.table_x_benefits.x_benefit_owner_type IS 'who owns the benefit { ESN | MIN | SID | ACCOUNT }';
COMMENT ON COLUMN sa.table_x_benefits.x_benefit_owner_value IS 'value of the owner';
COMMENT ON COLUMN sa.table_x_benefits.x_created_date IS 'date when this record is created (ie benefit is created )';
COMMENT ON COLUMN sa.table_x_benefits.x_status IS 'the status of benefits (eg AVAILABLE | USED | EXPIRED etc)';
COMMENT ON COLUMN sa.table_x_benefits.x_notes IS 'descriptive info about the benefits';
COMMENT ON COLUMN sa.table_x_benefits.benefits2benefit_program IS 'refers TABLE_X_BENEFIT_PROGRAMS.OBJID';
COMMENT ON COLUMN sa.table_x_benefits.x_update_date IS 'date when the record is last updated';
COMMENT ON COLUMN sa.table_x_benefits.x_expiry_date IS 'Date when the benefits will expire and cannot be used; this date will be populated as deactivation date + X days';