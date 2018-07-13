CREATE TABLE sa.x_pending_payment (
  x_pend_pay_id NUMBER,
  status VARCHAR2(20 BYTE),
  esn VARCHAR2(20 BYTE),
  "MIN" VARCHAR2(20 BYTE),
  mid VARCHAR2(30 BYTE),
  mdn VARCHAR2(20 BYTE),
  promo_code VARCHAR2(20 BYTE),
  source_system VARCHAR2(20 BYTE),
  amount NUMBER,
  action_type VARCHAR2(8 BYTE),
  resent_date DATE,
  red_card_pin VARCHAR2(20 BYTE),
  denomination VARCHAR2(20 BYTE),
  dll NUMBER(*,0),
  user_id VARCHAR2(20 BYTE),
  customer_id VARCHAR2(20 BYTE),
  site_part_id VARCHAR2(20 BYTE),
  carrier_id VARCHAR2(20 BYTE),
  creditcard_id VARCHAR2(20 BYTE)
);
ALTER TABLE sa.x_pending_payment ADD SUPPLEMENTAL LOG GROUP dmtsora858861031_0 (action_type, amount, carrier_id, creditcard_id, customer_id, denomination, dll, esn, mdn, mid, "MIN", promo_code, red_card_pin, resent_date, site_part_id, source_system, status, user_id, x_pend_pay_id) ALWAYS;
COMMENT ON TABLE sa.x_pending_payment IS 'Transaction Log for Buy Now transactions.  Handset based Airtime Purchase.';
COMMENT ON COLUMN sa.x_pending_payment.x_pend_pay_id IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_pending_payment.status IS 'Status of the Transaction';
COMMENT ON COLUMN sa.x_pending_payment.esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_pending_payment."MIN" IS 'Mobile Identification Number, References part_serial_no from table_part_inst for x_domain = LINES.';
COMMENT ON COLUMN sa.x_pending_payment.mid IS 'SMS Message ID';
COMMENT ON COLUMN sa.x_pending_payment.mdn IS 'Mobile Directory Number';
COMMENT ON COLUMN sa.x_pending_payment.promo_code IS 'Promo Code, references the promo code stored in table_x_promotion, it is optional.';
COMMENT ON COLUMN sa.x_pending_payment.source_system IS 'Sourcesystem originating the transaction, currently HANDSET or NETHANDSET.';
COMMENT ON COLUMN sa.x_pending_payment.amount IS 'Transaction Amount.';
COMMENT ON COLUMN sa.x_pending_payment.action_type IS 'For future use.';
COMMENT ON COLUMN sa.x_pending_payment.resent_date IS 'Transaction Date';
COMMENT ON COLUMN sa.x_pending_payment.red_card_pin IS 'Redemption Card Pin Number';
COMMENT ON COLUMN sa.x_pending_payment.denomination IS 'Reference the part number record.';
COMMENT ON COLUMN sa.x_pending_payment.dll IS 'DLL of the phone originating the transaction.';
COMMENT ON COLUMN sa.x_pending_payment.user_id IS 'Reference to objid table_user';
COMMENT ON COLUMN sa.x_pending_payment.customer_id IS 'Reference to objid in table_contact.';
COMMENT ON COLUMN sa.x_pending_payment.site_part_id IS 'reference to objid table_site';
COMMENT ON COLUMN sa.x_pending_payment.carrier_id IS 'reference to objid table_x_carrier.';
COMMENT ON COLUMN sa.x_pending_payment.creditcard_id IS 'reference to objid table_x_credit_card.';