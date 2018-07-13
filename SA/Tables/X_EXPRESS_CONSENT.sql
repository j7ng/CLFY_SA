CREATE TABLE sa.x_express_consent (
  insert_date DATE,
  "SOURCE" VARCHAR2(30 BYTE),
  phone_number VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  address_1 VARCHAR2(200 BYTE),
  address_2 VARCHAR2(200 BYTE),
  city VARCHAR2(30 BYTE),
  "STATE" VARCHAR2(30 BYTE),
  zipcode VARCHAR2(30 BYTE),
  gender VARCHAR2(10 BYTE),
  birth_date DATE,
  prerecorded_consent NUMBER,
  x_cust_id VARCHAR2(80 BYTE),
  email VARCHAR2(100 BYTE)
);
COMMENT ON TABLE sa.x_express_consent IS 'Authorization to be contacted via automated phone calls is stored in this table.';
COMMENT ON COLUMN sa.x_express_consent.insert_date IS 'Sysdate at the time of record creation.';
COMMENT ON COLUMN sa.x_express_consent."SOURCE" IS 'Source of the Record: Application';
COMMENT ON COLUMN sa.x_express_consent.phone_number IS 'Phone Number authorized';
COMMENT ON COLUMN sa.x_express_consent.esn IS 'ESN associated to the authorization';
COMMENT ON COLUMN sa.x_express_consent.first_name IS 'First Name Customer';
COMMENT ON COLUMN sa.x_express_consent.last_name IS 'last Name Customer';
COMMENT ON COLUMN sa.x_express_consent.address_1 IS 'Address Customer 1st line';
COMMENT ON COLUMN sa.x_express_consent.address_2 IS 'Address Customer 2nd Line, Ussually Apt# or Suite';
COMMENT ON COLUMN sa.x_express_consent.city IS 'City';
COMMENT ON COLUMN sa.x_express_consent."STATE" IS 'State, 2 letter abrev.';
COMMENT ON COLUMN sa.x_express_consent.zipcode IS 'Zip Code';
COMMENT ON COLUMN sa.x_express_consent.gender IS 'Gender Male or Female';
COMMENT ON COLUMN sa.x_express_consent.birth_date IS 'Date of Bith';
COMMENT ON COLUMN sa.x_express_consent.prerecorded_consent IS 'Concent:  0=No,  1=Yes';
COMMENT ON COLUMN sa.x_express_consent.x_cust_id IS 'Reference to table_contact.x_cust_id';
COMMENT ON COLUMN sa.x_express_consent.email IS 'email address of the customer.';