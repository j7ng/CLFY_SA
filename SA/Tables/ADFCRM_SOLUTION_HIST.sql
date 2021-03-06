CREATE TABLE sa.adfcrm_solution_hist (
  solution_id NUMBER NOT NULL,
  solution_name VARCHAR2(100 BYTE) NOT NULL,
  solution_description VARCHAR2(400 BYTE) NOT NULL,
  keywords VARCHAR2(100 BYTE) NOT NULL,
  access_type NUMBER NOT NULL,
  phone_status VARCHAR2(100 BYTE) NOT NULL,
  script_type VARCHAR2(20 BYTE),
  script_id VARCHAR2(20 BYTE),
  parent_id NUMBER,
  case_conf_hdr_id NUMBER,
  carrrier_parents VARCHAR2(30 BYTE),
  send_by_email VARCHAR2(10 BYTE),
  file_id NUMBER,
  show_in_popup_window VARCHAR2(20 BYTE),
  file_id_2 NUMBER(22),
  file_id_3 NUMBER(22),
  file_id_4 NUMBER(22),
  file_id_5 NUMBER(22),
  warranty_flag VARCHAR2(10 BYTE),
  changed_date DATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE)
);