CREATE TABLE sa.x_account_group (
  objid NUMBER(22) NOT NULL,
  account_group_name VARCHAR2(50 BYTE),
  service_plan_id NUMBER(22),
  service_plan_feature_date DATE,
  program_enrolled_id NUMBER(22),
  status VARCHAR2(30 BYTE),
  start_date DATE,
  end_date DATE,
  bus_org_objid NUMBER(22),
  account_group_uid VARCHAR2(50 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT x_account_group_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_account_group IS 'Store group information.';
COMMENT ON COLUMN sa.x_account_group.objid IS 'Unique identifier of the group.';
COMMENT ON COLUMN sa.x_account_group.account_group_name IS 'Nickname of the group.';
COMMENT ON COLUMN sa.x_account_group.service_plan_id IS 'Service plan identifier. Reference to x_service_plan table.';
COMMENT ON COLUMN sa.x_account_group.service_plan_feature_date IS 'Date when the service plan was changed.';
COMMENT ON COLUMN sa.x_account_group.program_enrolled_id IS 'Reference to x_program_enrolled (master ESN).';
COMMENT ON COLUMN sa.x_account_group.status IS 'Status of the master.';
COMMENT ON COLUMN sa.x_account_group.start_date IS 'Date when the activation of the master was completed.';
COMMENT ON COLUMN sa.x_account_group.end_date IS 'Date when the group is inactive.';
COMMENT ON COLUMN sa.x_account_group.insert_timestamp IS 'Date when record was created.';
COMMENT ON COLUMN sa.x_account_group.update_timestamp IS 'Date when record was last updated.';