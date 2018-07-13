CREATE TABLE sa.x_expire_acct_add_on_benefit (
  objid NUMBER(22) NOT NULL,
  "MIN" VARCHAR2(10 BYTE) NOT NULL,
  offer_id VARCHAR2(100 BYTE) NOT NULL,
  entitlement VARCHAR2(255 BYTE),
  add_on_redemption_date DATE NOT NULL,
  expire_timestamp DATE,
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  processed_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  CONSTRAINT pk_expire_acct_add_on_benefit PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_expire_acct_add_on_benefit IS 'This is a table for expiring the addons on x_subscriber_spr_detail.';
COMMENT ON COLUMN sa.x_expire_acct_add_on_benefit.objid IS 'Unique identifier of the table';
COMMENT ON COLUMN sa.x_expire_acct_add_on_benefit."MIN" IS 'Mobile number';
COMMENT ON COLUMN sa.x_expire_acct_add_on_benefit.offer_id IS 'Offer or COS value of the add-on';
COMMENT ON COLUMN sa.x_expire_acct_add_on_benefit.entitlement IS 'Entitlement';
COMMENT ON COLUMN sa.x_expire_acct_add_on_benefit.add_on_redemption_date IS 'Add-on redemption date';
COMMENT ON COLUMN sa.x_expire_acct_add_on_benefit.expire_timestamp IS 'Expiration date';
COMMENT ON COLUMN sa.x_expire_acct_add_on_benefit.insert_timestamp IS 'Date when the row was created';
COMMENT ON COLUMN sa.x_expire_acct_add_on_benefit.update_timestamp IS 'Date when the row was last updated';
COMMENT ON COLUMN sa.x_expire_acct_add_on_benefit.processed_flag IS 'Indicator when the record was processed';