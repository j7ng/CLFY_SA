CREATE TABLE sa.x_autoclose_case (
  x_esn VARCHAR2(30 BYTE),
  x_case_type VARCHAR2(30 BYTE),
  x_case_title VARCHAR2(80 BYTE),
  x_contact_first_name VARCHAR2(30 BYTE),
  x_contact_last_name VARCHAR2(30 BYTE),
  x_cust_id VARCHAR2(80 BYTE),
  x_activation_zip_code VARCHAR2(5 BYTE),
  x_carrier_id NUMBER,
  x_carrier_name VARCHAR2(30 BYTE),
  x_phone_model VARCHAR2(30 BYTE),
  x_msid VARCHAR2(30 BYTE),
  x_activation_date DATE,
  x_prl NUMBER,
  x_soc VARCHAR2(30 BYTE),
  x_red_code VARCHAR2(20 BYTE),
  x_retailer VARCHAR2(80 BYTE),
  x_create_date DATE,
  x_agent_name VARCHAR2(30 BYTE),
  x_flow_type VARCHAR2(80 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  x_sub_sourcesystem VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_autoclose_case ADD SUPPLEMENTAL LOG GROUP dmtsora727748202_0 (x_activation_date, x_activation_zip_code, x_agent_name, x_carrier_id, x_carrier_name, x_case_title, x_case_type, x_contact_first_name, x_contact_last_name, x_create_date, x_cust_id, x_esn, x_flow_type, x_msid, x_phone_model, x_prl, x_red_code, x_retailer, x_soc, x_sourcesystem) ALWAYS;
COMMENT ON TABLE sa.x_autoclose_case IS 'this table logs each technical flow run, storing a lot of the data requried to create statistics and detect trends.';
COMMENT ON COLUMN sa.x_autoclose_case.x_esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_autoclose_case.x_case_type IS 'Case Type';
COMMENT ON COLUMN sa.x_autoclose_case.x_case_title IS 'Case Title';
COMMENT ON COLUMN sa.x_autoclose_case.x_contact_first_name IS 'Contact First Name';
COMMENT ON COLUMN sa.x_autoclose_case.x_contact_last_name IS 'Contact Last Name';
COMMENT ON COLUMN sa.x_autoclose_case.x_cust_id IS 'Customer ID';
COMMENT ON COLUMN sa.x_autoclose_case.x_activation_zip_code IS 'Activation Zip Code';
COMMENT ON COLUMN sa.x_autoclose_case.x_carrier_id IS 'Carrier ID';
COMMENT ON COLUMN sa.x_autoclose_case.x_carrier_name IS 'Carrier Name';
COMMENT ON COLUMN sa.x_autoclose_case.x_phone_model IS 'Phone Model, Part Number Description';
COMMENT ON COLUMN sa.x_autoclose_case.x_msid IS 'Line MSID';
COMMENT ON COLUMN sa.x_autoclose_case.x_activation_date IS 'Activation Date';
COMMENT ON COLUMN sa.x_autoclose_case.x_prl IS 'Line PRL';
COMMENT ON COLUMN sa.x_autoclose_case.x_soc IS 'Line SOC';
COMMENT ON COLUMN sa.x_autoclose_case.x_red_code IS 'Red Code if available';
COMMENT ON COLUMN sa.x_autoclose_case.x_retailer IS 'Phone Retailer';
COMMENT ON COLUMN sa.x_autoclose_case.x_create_date IS 'Creation Timestamp';
COMMENT ON COLUMN sa.x_autoclose_case.x_agent_name IS 'Login Name Agent Involved';
COMMENT ON COLUMN sa.x_autoclose_case.x_flow_type IS 'Flow Type';
COMMENT ON COLUMN sa.x_autoclose_case.x_sourcesystem IS 'Source Application';
COMMENT ON COLUMN sa.x_autoclose_case.x_sub_sourcesystem IS 'Brand Name: TRACFONE, NET10, STRAIGHT_TALK';