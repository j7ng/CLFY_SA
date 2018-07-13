CREATE TABLE sa.adfcrm_upgrade_credit (
  org_id VARCHAR2(50 BYTE) NOT NULL,
  coupon VARCHAR2(100 BYTE) NOT NULL,
  denomination NUMBER NOT NULL,
  insert_date DATE NOT NULL,
  inserted_by VARCHAR2(50 BYTE) NOT NULL,
  ticket_id VARCHAR2(50 BYTE)
);
COMMENT ON TABLE sa.adfcrm_upgrade_credit IS 'This table is used to hold FCC Upgrade Credit.';
COMMENT ON COLUMN sa.adfcrm_upgrade_credit.org_id IS 'Brand Name or Organization Id';
COMMENT ON COLUMN sa.adfcrm_upgrade_credit.coupon IS 'Serialized Coupon Value';
COMMENT ON COLUMN sa.adfcrm_upgrade_credit.denomination IS 'Trade-in value/Dollar amount associated with the Serialized Coupon';
COMMENT ON COLUMN sa.adfcrm_upgrade_credit.insert_date IS 'Date in which the coupon was inserted';
COMMENT ON COLUMN sa.adfcrm_upgrade_credit.inserted_by IS 'Login name of the user that perform the transaction to upload the coupon';
COMMENT ON COLUMN sa.adfcrm_upgrade_credit.ticket_id IS 'References to table_case.id_number to indicate the ticket in which the coupon was used';