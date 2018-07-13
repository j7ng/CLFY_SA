CREATE TABLE sa.table_x_credit_card (
  objid NUMBER,
  x_customer_cc_number VARCHAR2(255 BYTE),
  x_customer_cc_expmo VARCHAR2(2 BYTE),
  x_customer_cc_expyr VARCHAR2(4 BYTE),
  x_cc_type VARCHAR2(20 BYTE),
  x_customer_cc_cv_number VARCHAR2(20 BYTE),
  x_customer_firstname VARCHAR2(20 BYTE),
  x_customer_lastname VARCHAR2(20 BYTE),
  x_customer_phone VARCHAR2(20 BYTE),
  x_customer_email VARCHAR2(50 BYTE),
  x_max_purch_amt NUMBER,
  x_max_trans_per_month NUMBER,
  x_max_purch_amt_per_month NUMBER,
  x_changedate DATE,
  x_original_insert_date DATE,
  x_changedby VARCHAR2(20 BYTE),
  x_cc_comments LONG,
  x_moms_maiden VARCHAR2(20 BYTE),
  x_credit_card2contact NUMBER,
  x_credit_card2address NUMBER,
  x_card_status VARCHAR2(10 BYTE),
  x_max_ild_purch_amt NUMBER,
  x_max_ild_purch_month NUMBER,
  x_credit_card2bus_org NUMBER,
  x_cust_cc_num_key VARCHAR2(255 BYTE),
  x_cust_cc_num_enc VARCHAR2(255 BYTE),
  creditcard2cert NUMBER
);
ALTER TABLE sa.table_x_credit_card ADD SUPPLEMENTAL LOG GROUP dmtsora2145856270_0 (creditcard2cert, objid, x_card_status, x_cc_type, x_changedate, x_changedby, x_credit_card2address, x_credit_card2bus_org, x_credit_card2contact, x_customer_cc_cv_number, x_customer_cc_expmo, x_customer_cc_expyr, x_customer_cc_number, x_customer_email, x_customer_firstname, x_customer_lastname, x_customer_phone, x_cust_cc_num_enc, x_cust_cc_num_key, x_max_ild_purch_amt, x_max_ild_purch_month, x_max_purch_amt, x_max_purch_amt_per_month, x_max_trans_per_month, x_moms_maiden, x_original_insert_date) ALWAYS;
COMMENT ON TABLE sa.table_x_credit_card IS 'Contains credit card information for a given customer';
COMMENT ON COLUMN sa.table_x_credit_card.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_credit_card.x_customer_cc_number IS 'encrypted (by app) except for last 4 characters';
COMMENT ON COLUMN sa.table_x_credit_card.x_customer_cc_expmo IS 'card expiration month number eg =12';
COMMENT ON COLUMN sa.table_x_credit_card.x_customer_cc_expyr IS 'card expiration year number eg =2001';
COMMENT ON COLUMN sa.table_x_credit_card.x_cc_type IS 'AMEX, VISA, DISCOVER, MASTERCARD, etc';
COMMENT ON COLUMN sa.table_x_credit_card.x_customer_cc_cv_number IS 'CVV2 number for additional card validation eg =47E';
COMMENT ON COLUMN sa.table_x_credit_card.x_customer_firstname IS 'cardholder first name  eg =Olga';
COMMENT ON COLUMN sa.table_x_credit_card.x_customer_lastname IS 'cardholder last name  eg =Smiff';
COMMENT ON COLUMN sa.table_x_credit_card.x_customer_phone IS 'Phone number credit card company has on file as billing address; usually not a TracFone';
COMMENT ON COLUMN sa.table_x_credit_card.x_customer_email IS 'customer email address, needed for purchase validation eg =test@cybersource.com';
COMMENT ON COLUMN sa.table_x_credit_card.x_max_purch_amt IS 'preliminary fraud checking, overrides default in table_cc_parms';
COMMENT ON COLUMN sa.table_x_credit_card.x_max_trans_per_month IS 'preliminary fraud checking, overrides default in table_cc_parms';
COMMENT ON COLUMN sa.table_x_credit_card.x_max_purch_amt_per_month IS 'preliminary fraud checking, overrides default in table_cc_parms';
COMMENT ON COLUMN sa.table_x_credit_card.x_changedate IS 'date this row was last updated';
COMMENT ON COLUMN sa.table_x_credit_card.x_original_insert_date IS 'date this row was originally inserted';
COMMENT ON COLUMN sa.table_x_credit_card.x_changedby IS 'user loginname of person who last modified the row';
COMMENT ON COLUMN sa.table_x_credit_card.x_cc_comments IS 'multi-line text for user comments on credit card.  eg: card is stolen';
COMMENT ON COLUMN sa.table_x_credit_card.x_moms_maiden IS 'mothers maiden name for preliminary validation';
COMMENT ON COLUMN sa.table_x_credit_card.x_credit_card2contact IS 'Customer Relation to Credit Card';
COMMENT ON COLUMN sa.table_x_credit_card.x_credit_card2address IS 'Address for the Credit Card';
COMMENT ON COLUMN sa.table_x_credit_card.x_card_status IS 'TBD';
COMMENT ON COLUMN sa.table_x_credit_card.x_max_ild_purch_amt IS 'Max ILD Purchase Amount';
COMMENT ON COLUMN sa.table_x_credit_card.x_max_ild_purch_month IS 'TBD';
COMMENT ON COLUMN sa.table_x_credit_card.x_credit_card2bus_org IS 'bus org for the Credit Card';
COMMENT ON COLUMN sa.table_x_credit_card.x_cust_cc_num_key IS 'Credit Card Number Public Key';
COMMENT ON COLUMN sa.table_x_credit_card.x_cust_cc_num_enc IS 'Credit Card Encrypted Value';
COMMENT ON COLUMN sa.table_x_credit_card.creditcard2cert IS 'This field is a relation to the x_cert table, it is defined as a filed and not as a relation,x_cert is not a clarify table.';