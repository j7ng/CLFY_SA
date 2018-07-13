CREATE TABLE sa.archive_x_autoclose_case (
  x_esn VARCHAR2(15 BYTE),
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
  x_sourcesystem VARCHAR2(30 BYTE)
);
ALTER TABLE sa.archive_x_autoclose_case ADD SUPPLEMENTAL LOG GROUP dmtsora434803431_0 (x_activation_date, x_activation_zip_code, x_agent_name, x_carrier_id, x_carrier_name, x_case_title, x_case_type, x_contact_first_name, x_contact_last_name, x_create_date, x_cust_id, x_esn, x_flow_type, x_msid, x_phone_model, x_prl, x_red_code, x_retailer, x_soc, x_sourcesystem) ALWAYS;