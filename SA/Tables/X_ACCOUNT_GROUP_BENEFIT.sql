CREATE TABLE sa.x_account_group_benefit (
  objid NUMBER(22) NOT NULL,
  account_group_id NUMBER(22) NOT NULL,
  service_plan_id NUMBER(22),
  part_num NUMBER(22),
  status VARCHAR2(30 BYTE) NOT NULL,
  start_date DATE,
  end_date DATE,
  sweep_and_clean_text VARCHAR2(500 BYTE),
  reason VARCHAR2(500 BYTE),
  call_trans_id NUMBER(22),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT x_account_group_benefit_pk PRIMARY KEY (objid),
  CONSTRAINT x_account_group_benefit_fk1 FOREIGN KEY (account_group_id) REFERENCES sa.x_account_group (objid)
);
COMMENT ON TABLE sa.x_account_group_benefit IS 'Store data add on cards or any other benefits members redeem.';
COMMENT ON COLUMN sa.x_account_group_benefit.objid IS 'Unique identifier of the account group benefit.';
COMMENT ON COLUMN sa.x_account_group_benefit.account_group_id IS 'Unique identifier of the account group.';
COMMENT ON COLUMN sa.x_account_group_benefit.service_plan_id IS 'Service plan identifier. Reference to x_service_plan table.';
COMMENT ON COLUMN sa.x_account_group_benefit.part_num IS 'Redemption card part number.';
COMMENT ON COLUMN sa.x_account_group_benefit.status IS 'Status of the benefit.';
COMMENT ON COLUMN sa.x_account_group_benefit.start_date IS 'Date of redemption.';
COMMENT ON COLUMN sa.x_account_group_benefit.end_date IS 'Inactive date.';
COMMENT ON COLUMN sa.x_account_group_benefit.insert_timestamp IS 'Date when record was created.';
COMMENT ON COLUMN sa.x_account_group_benefit.update_timestamp IS 'Date when record was last updated.';