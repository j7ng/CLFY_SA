CREATE TABLE sa.x_user_referrers (
  objid NUMBER,
  x_program_id VARCHAR2(30 BYTE),
  x_referrer_id VARCHAR2(30 BYTE),
  x_ref_promo_code VARCHAR2(10 BYTE),
  x_cashcard_da VARCHAR2(30 BYTE),
  x_cashcard_proxy VARCHAR2(30 BYTE),
  x_cashcard_person_id VARCHAR2(30 BYTE),
  x_client_acnt_id VARCHAR2(50 BYTE),
  x_client_acnt_num NUMBER,
  x_validated NUMBER,
  x_payout_option VARCHAR2(30 BYTE),
  x_create_date DATE,
  x_update_date DATE,
  x_user_ref2contact NUMBER,
  x_user_ref2webuser NUMBER,
  x_client_status VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_user_referrers IS 'Table having referrer data with personal and account information.';
COMMENT ON COLUMN sa.x_user_referrers.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_user_referrers.x_program_id IS 'Program ID';
COMMENT ON COLUMN sa.x_user_referrers.x_referrer_id IS 'Referrer ID';
COMMENT ON COLUMN sa.x_user_referrers.x_ref_promo_code IS 'Referrer promo code';
COMMENT ON COLUMN sa.x_user_referrers.x_cashcard_da IS 'Direct Access Number from FIS. This field is NOT currently used';
COMMENT ON COLUMN sa.x_user_referrers.x_cashcard_proxy IS 'Client account Proxy Number';
COMMENT ON COLUMN sa.x_user_referrers.x_cashcard_person_id IS 'Response ID from FIS after creating an account';
COMMENT ON COLUMN sa.x_user_referrers.x_client_acnt_id IS 'Client(Kobie) Account ID created after creating an account';
COMMENT ON COLUMN sa.x_user_referrers.x_client_acnt_num IS 'Client(Kobie)Account Number created after creating an account';
COMMENT ON COLUMN sa.x_user_referrers.x_validated IS 'User email gets validated or not. Validation code (NULL/0 => NOT validated / 1 => validated)';
COMMENT ON COLUMN sa.x_user_referrers.x_payout_option IS 'pay out option: Cash or Cheque';
COMMENT ON COLUMN sa.x_user_referrers.x_create_date IS 'Record creation date';
COMMENT ON COLUMN sa.x_user_referrers.x_update_date IS 'Record update date';
COMMENT ON COLUMN sa.x_user_referrers.x_user_ref2contact IS 'User referrer to contact';
COMMENT ON COLUMN sa.x_user_referrers.x_user_ref2webuser IS 'User referrer to web user';
COMMENT ON COLUMN sa.x_user_referrers.x_client_status IS 'Client provision status';