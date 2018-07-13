CREATE TABLE sa.adfcrm_cc_no_consent (
  cc_objid NUMBER NOT NULL,
  web_user_objid NUMBER,
  contact_objid NUMBER
);
COMMENT ON TABLE sa.adfcrm_cc_no_consent IS 'Store the reference to the credit card that can not be used for future purchases';
COMMENT ON COLUMN sa.adfcrm_cc_no_consent.cc_objid IS 'Reference to table_x_credit_card.objid ';
COMMENT ON COLUMN sa.adfcrm_cc_no_consent.web_user_objid IS 'Reference to table_web_user.objid';
COMMENT ON COLUMN sa.adfcrm_cc_no_consent.contact_objid IS 'Reference to table_contact.objid';