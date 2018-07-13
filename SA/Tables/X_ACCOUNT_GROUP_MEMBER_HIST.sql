CREATE TABLE sa.x_account_group_member_hist (
  objid NUMBER(22) NOT NULL,
  member_objid NUMBER(22) NOT NULL,
  account_group_id NUMBER(22),
  esn VARCHAR2(30 BYTE),
  member_order NUMBER(2),
  site_part_id NUMBER(22),
  promotion_id NUMBER(22),
  status VARCHAR2(30 BYTE),
  master_flag VARCHAR2(1 BYTE),
  program_param_id NUMBER(22),
  start_date DATE,
  end_date DATE,
  insert_timestamp DATE,
  update_timestamp DATE,
  receive_text_alerts_flag VARCHAR2(1 BYTE),
  subscriber_uid VARCHAR2(50 BYTE),
  osuser VARCHAR2(30 BYTE),
  change_date DATE NOT NULL,
  CONSTRAINT x_account_group_member_hist_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_account_group_member_hist IS 'Store expired group members information.';
COMMENT ON COLUMN sa.x_account_group_member_hist.objid IS 'Unique identifier of the group member history.';
COMMENT ON COLUMN sa.x_account_group_member_hist.member_objid IS 'Unique identifier of the group member.';
COMMENT ON COLUMN sa.x_account_group_member_hist.account_group_id IS 'Unique identifier of the account group.';
COMMENT ON COLUMN sa.x_account_group_member_hist.esn IS 'Member ESN.';
COMMENT ON COLUMN sa.x_account_group_member_hist.member_order IS 'Service plan identifier. Reference to x_service_plan table.';
COMMENT ON COLUMN sa.x_account_group_member_hist.site_part_id IS 'Reference to table_site_part.';
COMMENT ON COLUMN sa.x_account_group_member_hist.promotion_id IS 'Reference to x_program_enrolled (master ESN).';
COMMENT ON COLUMN sa.x_account_group_member_hist.status IS 'Status of the master.';
COMMENT ON COLUMN sa.x_account_group_member_hist.master_flag IS 'Flag to identify the master.';
COMMENT ON COLUMN sa.x_account_group_member_hist.program_param_id IS 'For enrollment.';
COMMENT ON COLUMN sa.x_account_group_member_hist.start_date IS 'Date when the member became part of the group.';
COMMENT ON COLUMN sa.x_account_group_member_hist.end_date IS 'Date when the member ended the group membership.';
COMMENT ON COLUMN sa.x_account_group_member_hist.insert_timestamp IS 'Date when record was created.';
COMMENT ON COLUMN sa.x_account_group_member_hist.update_timestamp IS 'Date when record was last updated.';
COMMENT ON COLUMN sa.x_account_group_member_hist.subscriber_uid IS 'Unique sequence generated to identify a customer.';
COMMENT ON COLUMN sa.x_account_group_member_hist.osuser IS 'OS User Name';
COMMENT ON COLUMN sa.x_account_group_member_hist.change_date IS 'History/Changed Date';