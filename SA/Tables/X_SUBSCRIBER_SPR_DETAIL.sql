CREATE TABLE sa.x_subscriber_spr_detail (
  objid NUMBER(22) NOT NULL,
  subscriber_spr_objid NUMBER(22) NOT NULL,
  add_on_offer_id VARCHAR2(50 BYTE),
  add_on_ttl DATE,
  add_on_redemption_date DATE,
  expired_usage_date DATE,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  acct_grp_benefit_objid NUMBER,
  CONSTRAINT x_subscriber_spr_detail_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_subscriber_spr_detail IS 'Store data add on cards or entitlement information for each spr base record.';
COMMENT ON COLUMN sa.x_subscriber_spr_detail.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.x_subscriber_spr_detail.subscriber_spr_objid IS 'Subscriber SPR Identifier';
COMMENT ON COLUMN sa.x_subscriber_spr_detail.add_on_offer_id IS 'Add On Offer Identifier';
COMMENT ON COLUMN sa.x_subscriber_spr_detail.add_on_ttl IS 'Add on Timeline';
COMMENT ON COLUMN sa.x_subscriber_spr_detail.add_on_redemption_date IS 'Add on Redemption date';
COMMENT ON COLUMN sa.x_subscriber_spr_detail.expired_usage_date IS 'Expired Usage Date';
COMMENT ON COLUMN sa.x_subscriber_spr_detail.insert_timestamp IS 'Record Inserted Timestamp';
COMMENT ON COLUMN sa.x_subscriber_spr_detail.update_timestamp IS 'Record last updated timestamp';
COMMENT ON COLUMN sa.x_subscriber_spr_detail.acct_grp_benefit_objid IS 'To capture the account grp benefits objid';