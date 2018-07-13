CREATE TABLE sa.udp_tx_log_table (
  objid NUMBER NOT NULL,
  x_dealer_username VARCHAR2(50 BYTE) NOT NULL,
  x_functionname VARCHAR2(50 BYTE) NOT NULL,
  x_transaction_date DATE NOT NULL,
  x_app_uri VARCHAR2(300 BYTE),
  x_app_name VARCHAR2(50 BYTE),
  x_remote_ip VARCHAR2(20 BYTE),
  x_sim VARCHAR2(30 BYTE),
  x_min VARCHAR2(40 BYTE),
  x_status VARCHAR2(20 BYTE) NOT NULL,
  dealer_objid NUMBER(22),
  x_esn VARCHAR2(200 BYTE),
  x_sequence VARCHAR2(200 BYTE),
  x_employee_id VARCHAR2(6 BYTE),
  x_rental_agreement_no VARCHAR2(11 BYTE),
  call_trans_objid NUMBER
);