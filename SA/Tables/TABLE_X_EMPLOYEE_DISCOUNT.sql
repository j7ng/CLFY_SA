CREATE TABLE sa.table_x_employee_discount (
  employee_id VARCHAR2(100 BYTE),
  login_name VARCHAR2(200 BYTE),
  emp_status_cd VARCHAR2(20 BYTE),
  start_date DATE,
  end_date DATE,
  partner_name VARCHAR2(100 BYTE),
  partner_code VARCHAR2(200 BYTE),
  brand VARCHAR2(40 BYTE),
  first_name VARCHAR2(100 BYTE),
  last_name VARCHAR2(100 BYTE),
  web_user_objid NUMBER,
  partner_type VARCHAR2(100 BYTE),
  brm_notified_flag VARCHAR2(1 BYTE),
  CONSTRAINT txed_uk UNIQUE (login_name,partner_name,brand,partner_type)
);
COMMENT ON TABLE sa.table_x_employee_discount IS 'Enrollment details of Affiliated partner / Member signup program';
COMMENT ON COLUMN sa.table_x_employee_discount.employee_id IS 'Employee ID from Affiliated Partner';
COMMENT ON COLUMN sa.table_x_employee_discount.login_name IS 'Login Email id';
COMMENT ON COLUMN sa.table_x_employee_discount.emp_status_cd IS 'STATUS (ACTIVE /INACTIVE)';
COMMENT ON COLUMN sa.table_x_employee_discount.start_date IS 'Start Date';
COMMENT ON COLUMN sa.table_x_employee_discount.end_date IS 'Expiry Date';
COMMENT ON COLUMN sa.table_x_employee_discount.partner_name IS 'Partner Name configured in TABLE_AFFILIATED_PARTNERS';
COMMENT ON COLUMN sa.table_x_employee_discount.partner_code IS 'Partner code configured in TABLE_AFFILIATED_PARTNERS';
COMMENT ON COLUMN sa.table_x_employee_discount.brand IS 'BRAND';
COMMENT ON COLUMN sa.table_x_employee_discount.web_user_objid IS 'WEB USER OBJID';
COMMENT ON COLUMN sa.table_x_employee_discount.partner_type IS 'Partner Type from TABLE_AFFILIATED_PARTNERS';