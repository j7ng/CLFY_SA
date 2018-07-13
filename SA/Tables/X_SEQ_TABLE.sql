CREATE TABLE sa.x_seq_table (
  objid NUMBER NOT NULL,
  x_table_name VARCHAR2(50 BYTE),
  x_seq_number NUMBER,
  x_seq_comments VARCHAR2(255 BYTE),
  x_update_stamp DATE,
  x_update_status CHAR,
  x_update_user VARCHAR2(20 BYTE)
);
ALTER TABLE sa.x_seq_table ADD SUPPLEMENTAL LOG GROUP dmtsora336064022_0 (objid, x_seq_comments, x_seq_number, x_table_name, x_update_stamp, x_update_status, x_update_user) ALWAYS;