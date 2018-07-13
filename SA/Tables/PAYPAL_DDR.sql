CREATE TABLE sa.paypal_ddr (
  load_name VARCHAR2(255 BYTE),
  load_date DATE,
  case_type VARCHAR2(255 BYTE),
  case_id VARCHAR2(255 BYTE),
  original_transaction_id VARCHAR2(255 BYTE),
  transaction_date VARCHAR2(255 BYTE),
  transaction_invoice_id VARCHAR2(255 BYTE),
  card_type VARCHAR2(255 BYTE),
  case_reason VARCHAR2(255 BYTE),
  claimant_name VARCHAR2(255 BYTE),
  claimant_email_address VARCHAR2(255 BYTE),
  case_filing_date VARCHAR2(255 BYTE),
  case_status VARCHAR2(255 BYTE),
  response_due_date VARCHAR2(255 BYTE),
  disputed_amount VARCHAR2(255 BYTE),
  disputed_currency VARCHAR2(255 BYTE),
  disputed_transaction_id VARCHAR2(255 BYTE),
  money_movement VARCHAR2(255 BYTE),
  settlement_type VARCHAR2(255 BYTE),
  seller_protection VARCHAR2(255 BYTE),
  seller_protec_payout_amt VARCHAR2(255 BYTE),
  seller_protection_currency VARCHAR2(255 BYTE),
  payment_tracking_id VARCHAR2(255 BYTE),
  buyer_comments VARCHAR2(255 BYTE),
  store_id VARCHAR2(255 BYTE),
  chargeback_reason_code VARCHAR2(255 BYTE),
  outcome VARCHAR2(255 BYTE)
);
COMMENT ON COLUMN sa.paypal_ddr.transaction_date IS 'Completion date of the transaction.';
COMMENT ON COLUMN sa.paypal_ddr.claimant_name IS 'Name of the claimant as it appears in the original PayPal payment being disputed.';
COMMENT ON COLUMN sa.paypal_ddr.claimant_email_address IS 'PayPal email address of the buyer as it appeared in the disputed transaction. The email address is also the account contact point between buyers and sellers within the PayPal system.';
COMMENT ON COLUMN sa.paypal_ddr.disputed_amount IS 'Amount being disputed by the buyer in the original transaction. Because buyers may sometimes dispute only part of the payment, the disputed amount may be different than the total gross or net amount of the original transaction. There is no specific maximum limit.';