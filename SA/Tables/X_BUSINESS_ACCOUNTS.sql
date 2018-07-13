CREATE TABLE sa.x_business_accounts (
  account_id NUMBER NOT NULL,
  "NAME" VARCHAR2(80 BYTE) NOT NULL,
  tax_exempt VARCHAR2(5 BYTE),
  bus_org VARCHAR2(10 BYTE),
  business_desc VARCHAR2(255 BYTE),
  web_site VARCHAR2(255 BYTE),
  comments VARCHAR2(255 BYTE),
  acc_status VARCHAR2(30 BYTE),
  fed_tax_id VARCHAR2(40 BYTE),
  sales_tax_id VARCHAR2(40 BYTE),
  default_act_zipcode VARCHAR2(10 BYTE),
  bus_primary2contact NUMBER,
  created_by VARCHAR2(60 BYTE) NOT NULL,
  creation_date DATE NOT NULL,
  last_updated_by VARCHAR2(60 BYTE) NOT NULL,
  last_update_date DATE NOT NULL,
  CONSTRAINT x_bus_account_pk PRIMARY KEY (account_id)
);
COMMENT ON COLUMN sa.x_business_accounts.account_id IS 'Account ID';
COMMENT ON COLUMN sa.x_business_accounts."NAME" IS 'Name of the Business';
COMMENT ON COLUMN sa.x_business_accounts.tax_exempt IS 'Tax Exempt Flag: 0=No,1=Yes';
COMMENT ON COLUMN sa.x_business_accounts.bus_org IS 'not used';
COMMENT ON COLUMN sa.x_business_accounts.business_desc IS 'Business Description';
COMMENT ON COLUMN sa.x_business_accounts.web_site IS 'URL Web Site, Optional';
COMMENT ON COLUMN sa.x_business_accounts.comments IS 'Commnet about the account';
COMMENT ON COLUMN sa.x_business_accounts.acc_status IS 'not used';
COMMENT ON COLUMN sa.x_business_accounts.fed_tax_id IS 'Federal Tax ID';
COMMENT ON COLUMN sa.x_business_accounts.sales_tax_id IS 'Sales Tax ID';
COMMENT ON COLUMN sa.x_business_accounts.default_act_zipcode IS 'Default Zip Code for Activations';
COMMENT ON COLUMN sa.x_business_accounts.bus_primary2contact IS 'Reference to table_contact';
COMMENT ON COLUMN sa.x_business_accounts.created_by IS 'Created by';
COMMENT ON COLUMN sa.x_business_accounts.creation_date IS 'Account Creation Date';
COMMENT ON COLUMN sa.x_business_accounts.last_updated_by IS 'Last Update Timestamp';
COMMENT ON COLUMN sa.x_business_accounts.last_update_date IS 'Last Updated By';