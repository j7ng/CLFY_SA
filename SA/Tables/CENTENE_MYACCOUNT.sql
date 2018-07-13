CREATE TABLE sa.centene_myaccount (
  x_esn VARCHAR2(40 BYTE),
  x_status VARCHAR2(40 BYTE) DEFAULT 'PENDING',
  x_insert_date DATE DEFAULT sysdate,
  x_program_name VARCHAR2(100 BYTE)
);