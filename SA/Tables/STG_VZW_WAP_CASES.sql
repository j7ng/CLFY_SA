CREATE TABLE sa.stg_vzw_wap_cases (
  id_number VARCHAR2(30 BYTE) NOT NULL,
  notes VARCHAR2(300 BYTE) NOT NULL,
  process_date DATE,
  insert_date DATE DEFAULT SYSDATE,
  inserted_by VARCHAR2(50 BYTE)
);