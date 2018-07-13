CREATE TABLE sa.x_nlad_request_log (
  objid NUMBER,
  x_transactiontype VARCHAR2(200 BYTE),
  x_lastname VARCHAR2(200 BYTE),
  x_firstname VARCHAR2(200 BYTE),
  x_middlename VARCHAR2(200 BYTE),
  x_dob VARCHAR2(255 BYTE),
  x_last4ssn VARCHAR2(255 BYTE),
  x_eligiblelastname VARCHAR2(200 BYTE),
  x_eligiblefirstname VARCHAR2(200 BYTE),
  x_eligiblemiddlename VARCHAR2(200 BYTE),
  x_eligibledob VARCHAR2(255 BYTE),
  x_eligiblelast4ssn VARCHAR2(255 BYTE),
  x_addressline1 VARCHAR2(200 BYTE),
  x_addressline2 VARCHAR2(200 BYTE),
  x_city VARCHAR2(200 BYTE),
  x_state VARCHAR2(200 BYTE),
  x_zipcode VARCHAR2(200 BYTE),
  x_shippingaddressline1 VARCHAR2(200 BYTE),
  x_shippingaddressline2 VARCHAR2(200 BYTE),
  x_shippingcity VARCHAR2(200 BYTE),
  x_shippingstate VARCHAR2(200 BYTE),
  x_shippingzipcode VARCHAR2(200 BYTE),
  x_addressistemporary VARCHAR2(200 BYTE),
  x_addressisrural VARCHAR2(200 BYTE),
  x_sac VARCHAR2(200 BYTE),
  x_enrollmentnumber VARCHAR2(200 BYTE),
  x_enrollmentchannel VARCHAR2(200 BYTE),
  x_reference_id VARCHAR2(400 BYTE),
  x_batch_file_date DATE,
  x_nladphonenumber VARCHAR2(200 BYTE),
  x_phonenumber VARCHAR2(200 BYTE),
  x_lehcertificationdate VARCHAR2(200 BYTE)
);
COMMENT ON COLUMN sa.x_nlad_request_log.objid IS 'Unique identifier for transaction NLAD';