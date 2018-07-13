CREATE TABLE sa.table_x_web_case_resolution (
  objid NUMBER,
  x_case_type VARCHAR2(30 BYTE),
  x_case_title VARCHAR2(80 BYTE),
  x_case_status VARCHAR2(30 BYTE),
  x_txt_english VARCHAR2(400 BYTE),
  x_txt_spanish VARCHAR2(400 BYTE),
  x_resolution VARCHAR2(50 BYTE),
  x_std_resol_time NUMBER
);
ALTER TABLE sa.table_x_web_case_resolution ADD SUPPLEMENTAL LOG GROUP dmtsora245888112_0 (objid, x_case_status, x_case_title, x_case_type, x_resolution, x_std_resol_time, x_txt_english, x_txt_spanish) ALWAYS;