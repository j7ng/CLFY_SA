CREATE TABLE sa.table_x_cc_auth_days (
  card_type VARCHAR2(50 BYTE) NOT NULL,
  s_card_type VARCHAR2(50 BYTE) NOT NULL,
  auth_validity_days NUMBER NOT NULL,
  UNIQUE (card_type),
  UNIQUE (s_card_type)
);
COMMENT ON COLUMN sa.table_x_cc_auth_days.card_type IS 'credit card type Example VISA';
COMMENT ON COLUMN sa.table_x_cc_auth_days.s_card_type IS 'credit card type capitalized Example MASTER CARD';
COMMENT ON COLUMN sa.table_x_cc_auth_days.auth_validity_days IS 'Number of days the authorization is valid for';