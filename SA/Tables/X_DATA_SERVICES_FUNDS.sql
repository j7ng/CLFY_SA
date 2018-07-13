CREATE TABLE sa.x_data_services_funds (
  objid NUMBER,
  x_credit_amt NUMBER,
  x_debit_amt NUMBER,
  x_date DATE,
  x_balance_amt NUMBER,
  data_ser2web_user NUMBER,
  data_ser2pgm_enroll NUMBER
);
ALTER TABLE sa.x_data_services_funds ADD SUPPLEMENTAL LOG GROUP dmtsora757678074_0 (data_ser2pgm_enroll, data_ser2web_user, objid, x_balance_amt, x_credit_amt, x_date, x_debit_amt) ALWAYS;