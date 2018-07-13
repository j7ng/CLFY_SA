CREATE TABLE sa.x_notifications_trans (
  x_esn VARCHAR2(50 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_email_type VARCHAR2(50 BYTE),
  x_program_name VARCHAR2(50 BYTE),
  x_insert_date DATE DEFAULT SYSDATE,
  x_action_text VARCHAR2(30 BYTE),
  x_email VARCHAR2(50 BYTE),
  x_payment_type VARCHAR2(50 BYTE),
  x_category VARCHAR2(50 BYTE),
  x_first_name VARCHAR2(90 BYTE),
  x_last_name VARCHAR2(90 BYTE),
  x_user_name VARCHAR2(100 BYTE),
  x_password VARCHAR2(255 BYTE),
  x_trans_date DATE,
  x_program_type VARCHAR2(50 BYTE),
  x_amount NUMBER,
  x_bill_amount NUMBER,
  x_merchant_ref_number VARCHAR2(50 BYTE),
  x_payment_method VARCHAR2(50 BYTE),
  x_decline_reason VARCHAR2(500 BYTE),
  x_card_number VARCHAR2(20 BYTE),
  x_next_charge_date DATE,
  x_status VARCHAR2(50 BYTE) DEFAULT 'PENDING',
  x_update_date DATE,
  objid NUMBER,
  brand VARCHAR2(100 BYTE)
);
COMMENT ON COLUMN sa.x_notifications_trans.x_esn IS 'ESN';
COMMENT ON COLUMN sa.x_notifications_trans.x_min IS 'MIN';
COMMENT ON COLUMN sa.x_notifications_trans.x_email_type IS 'Email type';
COMMENT ON COLUMN sa.x_notifications_trans.x_program_name IS 'Customer''s program name';
COMMENT ON COLUMN sa.x_notifications_trans.x_insert_date IS 'Insert date';
COMMENT ON COLUMN sa.x_notifications_trans.x_action_text IS 'Action text';
COMMENT ON COLUMN sa.x_notifications_trans.x_email IS 'Email';
COMMENT ON COLUMN sa.x_notifications_trans.x_payment_type IS 'Payment type';
COMMENT ON COLUMN sa.x_notifications_trans.x_category IS 'Category';
COMMENT ON COLUMN sa.x_notifications_trans.x_first_name IS 'Customer''s first name';
COMMENT ON COLUMN sa.x_notifications_trans.x_last_name IS 'Customer''s last name';
COMMENT ON COLUMN sa.x_notifications_trans.x_user_name IS 'Customer''s user name';
COMMENT ON COLUMN sa.x_notifications_trans.x_password IS 'Customer''s passwords';
COMMENT ON COLUMN sa.x_notifications_trans.x_trans_date IS 'Transaction date';
COMMENT ON COLUMN sa.x_notifications_trans.x_program_type IS 'Program type';
COMMENT ON COLUMN sa.x_notifications_trans.x_amount IS 'Amount';
COMMENT ON COLUMN sa.x_notifications_trans.x_bill_amount IS 'Bill amount';
COMMENT ON COLUMN sa.x_notifications_trans.x_merchant_ref_number IS 'Merchant ref number';
COMMENT ON COLUMN sa.x_notifications_trans.x_payment_method IS 'Payment method';
COMMENT ON COLUMN sa.x_notifications_trans.x_decline_reason IS 'Decline reason';
COMMENT ON COLUMN sa.x_notifications_trans.x_card_number IS 'Customer''s card number';
COMMENT ON COLUMN sa.x_notifications_trans.x_next_charge_date IS 'Next charge date';
COMMENT ON COLUMN sa.x_notifications_trans.x_status IS 'Status';
COMMENT ON COLUMN sa.x_notifications_trans.x_update_date IS 'Update date';
COMMENT ON COLUMN sa.x_notifications_trans.objid IS 'OBJID ';
COMMENT ON COLUMN sa.x_notifications_trans.brand IS 'Brand Name';