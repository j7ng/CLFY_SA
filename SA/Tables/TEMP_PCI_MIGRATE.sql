CREATE TABLE sa.temp_pci_migrate (
  credit_card_objid NUMBER,
  old_x_cust_cc_num_key VARCHAR2(255 BYTE),
  old_x_customer_cc_number VARCHAR2(255 BYTE),
  old_x_cust_cc_num_enc VARCHAR2(255 BYTE),
  old_creditcard2cert NUMBER,
  new_x_cust_cc_num_key VARCHAR2(255 BYTE),
  new_x_customer_cc_number VARCHAR2(255 BYTE),
  new_x_cust_cc_num_enc VARCHAR2(255 BYTE),
  new_creditcard2cert NUMBER,
  job_id NUMBER,
  x_insert_date DATE,
  x_process_date DATE
);