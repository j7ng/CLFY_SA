CREATE TABLE sa.x_expire_account_group_benefit (
  objid NUMBER(22) NOT NULL,
  account_group_id NUMBER(22) NOT NULL,
  expire_timestamp DATE NOT NULL,
  insert_timestamp DATE NOT NULL,
  processed_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  CONSTRAINT x_expire_acc_group_benefit_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_expire_account_group_benefit IS 'Table used for expiring the account group benefit table from max feedback job';