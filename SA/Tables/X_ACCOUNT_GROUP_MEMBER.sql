CREATE TABLE sa.x_account_group_member (
  objid NUMBER(22) NOT NULL,
  account_group_id NUMBER(22) NOT NULL,
  esn VARCHAR2(30 BYTE),
  member_order NUMBER(2) NOT NULL,
  site_part_id NUMBER(22),
  promotion_id NUMBER(22),
  status VARCHAR2(30 BYTE) NOT NULL,
  master_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  program_param_id NUMBER(22),
  start_date DATE,
  end_date DATE,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  receive_text_alerts_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  subscriber_uid VARCHAR2(50 BYTE),
  CONSTRAINT x_account_group_member_pk PRIMARY KEY (objid),
  CONSTRAINT x_account_group_member_fk1 FOREIGN KEY (account_group_id) REFERENCES sa.x_account_group (objid)
);
COMMENT ON TABLE sa.x_account_group_member IS 'Store group members information.';
COMMENT ON COLUMN sa.x_account_group_member.objid IS 'Unique identifier of the group member.';
COMMENT ON COLUMN sa.x_account_group_member.account_group_id IS 'Unique identifier of the account group.';
COMMENT ON COLUMN sa.x_account_group_member.esn IS 'Member ESN.';
COMMENT ON COLUMN sa.x_account_group_member.member_order IS 'Service plan identifier. Reference to x_service_plan table.';
COMMENT ON COLUMN sa.x_account_group_member.site_part_id IS 'Reference to table_site_part.';
COMMENT ON COLUMN sa.x_account_group_member.promotion_id IS 'Reference to x_program_enrolled (master ESN).';
COMMENT ON COLUMN sa.x_account_group_member.status IS 'Status of the master.';
COMMENT ON COLUMN sa.x_account_group_member.master_flag IS 'Flag to identify the master.';
COMMENT ON COLUMN sa.x_account_group_member.program_param_id IS 'For enrollment.';
COMMENT ON COLUMN sa.x_account_group_member.start_date IS 'Date when the member became part of the group.';
COMMENT ON COLUMN sa.x_account_group_member.end_date IS 'Date when the member ended the group membership.';
COMMENT ON COLUMN sa.x_account_group_member.insert_timestamp IS 'Date when record was created.';
COMMENT ON COLUMN sa.x_account_group_member.update_timestamp IS 'Date when record was last updated.';
COMMENT ON COLUMN sa.x_account_group_member.subscriber_uid IS 'Unique sequence generated to identify a customer.';