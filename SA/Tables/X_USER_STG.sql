CREATE TABLE sa.x_user_stg (
  first_name VARCHAR2(100 BYTE),
  last_name VARCHAR2(100 BYTE),
  "ROLE" VARCHAR2(100 BYTE),
  pin VARCHAR2(25 BYTE),
  call_center VARCHAR2(10 BYTE),
  status VARCHAR2(200 BYTE),
  login_name VARCHAR2(50 BYTE),
  created_on DATE,
  insert_date DATE DEFAULT SYSDATE,
  change_order_number VARCHAR2(30 BYTE),
  file_name VARCHAR2(30 BYTE),
  insert_user VARCHAR2(50 BYTE)
);