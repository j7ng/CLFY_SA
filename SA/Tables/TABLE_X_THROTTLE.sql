CREATE TABLE sa.table_x_throttle (
  x_esn VARCHAR2(30 BYTE) NOT NULL,
  x_min VARCHAR2(10 BYTE) NOT NULL,
  x_sp_min VARCHAR2(30 BYTE),
  x_action VARCHAR2(10 BYTE) NOT NULL,
  x_feature VARCHAR2(100 BYTE) NOT NULL,
  x_status VARCHAR2(100 BYTE),
  x_message VARCHAR2(255 BYTE),
  x_trans_id NUMBER,
  x_insert_date DATE DEFAULT sysdate,
  x_thrtl_date DATE,
  x_unthrtl_date DATE,
  x_process_date DATE,
  CONSTRAINT pk_thrtl_1 PRIMARY KEY (x_esn,x_min)
);
ALTER TABLE sa.table_x_throttle ADD SUPPLEMENTAL LOG GROUP tsora985732366_0 (x_action, x_esn, x_feature, x_insert_date, x_message, x_min, x_process_date, x_sp_min, x_status, x_thrtl_date, x_trans_id, x_unthrtl_date) ALWAYS;