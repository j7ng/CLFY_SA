CREATE TABLE sa.x_referral_events (
  objid NUMBER,
  x_cashcard_da VARCHAR2(30 BYTE),
  x_cashcard_proxy VARCHAR2(30 BYTE),
  x_cashcard_person_id VARCHAR2(30 BYTE),
  x_client_acnt_id VARCHAR2(50 BYTE),
  x_client_acnt_num NUMBER,
  x_payout_option VARCHAR2(30 BYTE),
  x_event_desc VARCHAR2(3000 BYTE),
  x_create_date DATE,
  x_event2user_referrers VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_referral_events IS 'Logging referral events.';
COMMENT ON COLUMN sa.x_referral_events.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_referral_events.x_cashcard_da IS 'Direct Access Number from FIS. This field is NOT currently used';
COMMENT ON COLUMN sa.x_referral_events.x_cashcard_proxy IS 'Client account Proxy Number';
COMMENT ON COLUMN sa.x_referral_events.x_cashcard_person_id IS 'Response ID from FIS after creating an account';
COMMENT ON COLUMN sa.x_referral_events.x_client_acnt_id IS 'Client(Kobie) Account ID created after creating an account';
COMMENT ON COLUMN sa.x_referral_events.x_client_acnt_num IS 'Client(Kobie)Account Number created after creating an account';
COMMENT ON COLUMN sa.x_referral_events.x_payout_option IS 'pay out option: Cash or Cheque';
COMMENT ON COLUMN sa.x_referral_events.x_event_desc IS 'Event description';
COMMENT ON COLUMN sa.x_referral_events.x_create_date IS 'Event create date';
COMMENT ON COLUMN sa.x_referral_events.x_event2user_referrers IS 'referral events to user referrers';