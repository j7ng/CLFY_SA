CREATE TABLE sa.wex_bp_inv_receipts (
  doc_date VARCHAR2(150 BYTE),
  doc_no VARCHAR2(30 BYTE),
  site VARCHAR2(50 BYTE),
  doc VARCHAR2(250 BYTE),
  item_code VARCHAR2(50 BYTE),
  short_des VARCHAR2(150 BYTE),
  item_sub_class VARCHAR2(50 BYTE),
  qty VARCHAR2(50 BYTE),
  vendor_code VARCHAR2(30 BYTE),
  vendor_name VARCHAR2(50 BYTE),
  tracfone_po VARCHAR2(50 BYTE),
  bp_order VARCHAR2(30 BYTE),
  creation_date DATE
);