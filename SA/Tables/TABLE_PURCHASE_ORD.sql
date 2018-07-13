CREATE TABLE sa.table_purchase_ord (
  objid NUMBER,
  po_id VARCHAR2(60 BYTE),
  po_date DATE,
  pay_option VARCHAR2(40 BYTE),
  po_terms VARCHAR2(40 BYTE),
  po_amt NUMBER(19,4),
  expire_date DATE,
  status VARCHAR2(40 BYTE),
  first_name VARCHAR2(30 BYTE),
  card_num VARCHAR2(25 BYTE),
  auth_num VARCHAR2(25 BYTE),
  address VARCHAR2(80 BYTE),
  zipcode VARCHAR2(25 BYTE),
  ref_num VARCHAR2(25 BYTE),
  last_name VARCHAR2(30 BYTE),
  auth_status VARCHAR2(2 BYTE),
  dev NUMBER,
  cc_name VARCHAR2(80 BYTE),
  cc_type VARCHAR2(20 BYTE),
  cc_exp_mo VARCHAR2(2 BYTE),
  cc_exp_yr VARCHAR2(4 BYTE),
  city VARCHAR2(30 BYTE),
  state_prov VARCHAR2(80 BYTE),
  country VARCHAR2(40 BYTE),
  payment2contr_schedule NUMBER,
  payment2quick_quote NUMBER,
  payment2pay_means NUMBER
);
ALTER TABLE sa.table_purchase_ord ADD SUPPLEMENTAL LOG GROUP dmtsora284510259_0 (address, auth_num, auth_status, card_num, cc_exp_mo, cc_exp_yr, cc_name, cc_type, city, country, dev, expire_date, first_name, last_name, objid, payment2contr_schedule, payment2pay_means, payment2quick_quote, pay_option, po_amt, po_date, po_id, po_terms, ref_num, state_prov, status, zipcode) ALWAYS;
COMMENT ON TABLE sa.table_purchase_ord IS 'Describes a payment method, often a purchase order, related to a contract schedule or line items';
COMMENT ON COLUMN sa.table_purchase_ord.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_purchase_ord.po_id IS 'The unique purchase order ID';
COMMENT ON COLUMN sa.table_purchase_ord.po_date IS 'The date identified on the payment method';
COMMENT ON COLUMN sa.table_purchase_ord.pay_option IS 'The payment option for this line item; e.g., purchase order, credit card, etc. This is from a user-defined popup with default name PAY_METHOD';
COMMENT ON COLUMN sa.table_purchase_ord.po_terms IS 'The type of payment. This is from a user-defined popup with default name PAYMENT_TERMS';
COMMENT ON COLUMN sa.table_purchase_ord.po_amt IS 'Total currency amount of the purchase order';
COMMENT ON COLUMN sa.table_purchase_ord.expire_date IS 'The last date the payment means is effective';
COMMENT ON COLUMN sa.table_purchase_ord.status IS 'User-defined status of the payment means. This is a user-defined popup with default name PO Status';
COMMENT ON COLUMN sa.table_purchase_ord.first_name IS 'For personal payment means, the first name of person that owns it';
COMMENT ON COLUMN sa.table_purchase_ord.card_num IS 'For credit cards, the credit card number';
COMMENT ON COLUMN sa.table_purchase_ord.auth_num IS 'Authorization number returned by the credit card company';
COMMENT ON COLUMN sa.table_purchase_ord.address IS 'Street address of the person whose name appears on the payment means';
COMMENT ON COLUMN sa.table_purchase_ord.zipcode IS 'Zipcode or postal code of the person whose name appears on the payment means';
COMMENT ON COLUMN sa.table_purchase_ord.ref_num IS 'Reference number for letter of credit, etc';
COMMENT ON COLUMN sa.table_purchase_ord.last_name IS 'Last name of person who appears on the payment means';
COMMENT ON COLUMN sa.table_purchase_ord.auth_status IS 'Status of the authorization returned by the validation system';
COMMENT ON COLUMN sa.table_purchase_ord.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_purchase_ord.cc_name IS 'Complete name of the credit card owner as it appears on the card';
COMMENT ON COLUMN sa.table_purchase_ord.cc_type IS ' The credit card type populated from a user defined pop-up with the title cctype';
COMMENT ON COLUMN sa.table_purchase_ord.cc_exp_mo IS '2-digit number of the month when the card expires';
COMMENT ON COLUMN sa.table_purchase_ord.cc_exp_yr IS '2- or 4-digit number of the year in which the credit card expires';
COMMENT ON COLUMN sa.table_purchase_ord.city IS 'The city for the bill address ';
COMMENT ON COLUMN sa.table_purchase_ord.state_prov IS 'The state/province of the bill address';
COMMENT ON COLUMN sa.table_purchase_ord.country IS 'The country of the bill address';
COMMENT ON COLUMN sa.table_purchase_ord.payment2pay_means IS 'The payment means used by the payment';