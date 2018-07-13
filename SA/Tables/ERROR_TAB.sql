CREATE TABLE sa.error_tab (
  err_num NUMBER(5),
  err_column VARCHAR2(20 BYTE),
  err_table VARCHAR2(50 BYTE),
  err_message VARCHAR2(80 BYTE)
);
ALTER TABLE sa.error_tab ADD SUPPLEMENTAL LOG GROUP dmtsora2075607136_0 (err_column, err_message, err_num, err_table) ALWAYS;