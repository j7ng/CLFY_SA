CREATE TABLE sa.table_trans_record (
  objid NUMBER,
  ref_objid NUMBER,
  creation_date DATE,
  mod_crt_dt DATE,
  stop_date DATE,
  mod_stop_dt DATE,
  extract_date DATE,
  site_id VARCHAR2(80 BYTE),
  expense_type VARCHAR2(20 BYTE),
  billable NUMBER,
  bill_to VARCHAR2(30 BYTE),
  included NUMBER,
  extension NUMBER,
  mod_extn NUMBER,
  quantity NUMBER,
  mod_qty NUMBER,
  rate NUMBER,
  mod_rate NUMBER,
  "TIME" NUMBER,
  mod_time NUMBER,
  serial_no VARCHAR2(30 BYTE),
  part_number VARCHAR2(30 BYTE),
  subtotal_cat VARCHAR2(10 BYTE),
  case_id VARCHAR2(255 BYTE),
  approved NUMBER,
  rem_part_num VARCHAR2(30 BYTE),
  rem_qty NUMBER,
  rem_serial VARCHAR2(30 BYTE),
  focus_type NUMBER,
  txn_comment VARCHAR2(255 BYTE),
  appl_id VARCHAR2(20 BYTE),
  datetime_6 DATE,
  datetime_7 DATE,
  datetime_8 DATE,
  datetime_9 DATE,
  datetime_10 DATE,
  datetime_11 DATE,
  datetime_12 DATE,
  datetime_13 DATE,
  datetime_14 DATE,
  datetime_15 DATE,
  datetime_16 DATE,
  datetime_17 DATE,
  datetime_18 DATE,
  decimal_1 NUMBER(19,4),
  decimal_2 NUMBER(19,4),
  decimal_3 NUMBER(19,4),
  int_6 NUMBER,
  int_7 NUMBER,
  int_8 NUMBER,
  int_9 NUMBER,
  int_10 NUMBER,
  int_11 NUMBER,
  int_12 NUMBER,
  varchar8_1 VARCHAR2(8 BYTE),
  varchar20_3 VARCHAR2(20 BYTE),
  varchar20_4 VARCHAR2(20 BYTE),
  varchar20_5 VARCHAR2(20 BYTE),
  varchar30_6 VARCHAR2(30 BYTE),
  varchar40_1 VARCHAR2(40 BYTE),
  varchar40_2 VARCHAR2(40 BYTE),
  varchar60_1 VARCHAR2(60 BYTE),
  varchar80_1 VARCHAR2(80 BYTE),
  varchar80_2 VARCHAR2(80 BYTE),
  varchar80_3 VARCHAR2(80 BYTE),
  varchar80_4 VARCHAR2(80 BYTE),
  int_13 NUMBER,
  dev NUMBER,
  details2trans_record NUMBER(*,0),
  trans_record2site NUMBER(*,0),
  trans_record2case NUMBER(*,0),
  trans_record2trans_map NUMBER(*,0),
  trans_record2user NUMBER(*,0),
  tr2contr_schedule NUMBER(*,0)
);
ALTER TABLE sa.table_trans_record ADD SUPPLEMENTAL LOG GROUP dmtsora820040511_0 (appl_id, approved, billable, bill_to, case_id, creation_date, datetime_6, datetime_7, expense_type, extension, extract_date, focus_type, included, mod_crt_dt, mod_extn, mod_qty, mod_rate, mod_stop_dt, mod_time, objid, part_number, quantity, rate, ref_objid, rem_part_num, rem_qty, rem_serial, serial_no, site_id, stop_date, subtotal_cat, "TIME", txn_comment) ALWAYS;
ALTER TABLE sa.table_trans_record ADD SUPPLEMENTAL LOG GROUP dmtsora820040511_1 (datetime_10, datetime_11, datetime_12, datetime_13, datetime_14, datetime_15, datetime_16, datetime_17, datetime_18, datetime_8, datetime_9, decimal_1, decimal_2, decimal_3, int_10, int_11, int_12, int_6, int_7, int_8, int_9, varchar20_3, varchar20_4, varchar20_5, varchar30_6, varchar40_1, varchar40_2, varchar60_1, varchar80_1, varchar80_2, varchar80_3, varchar80_4, varchar8_1) ALWAYS;
ALTER TABLE sa.table_trans_record ADD SUPPLEMENTAL LOG GROUP dmtsora820040511_2 (details2trans_record, dev, int_13, tr2contr_schedule, trans_record2case, trans_record2site, trans_record2trans_map, trans_record2user) ALWAYS;