CREATE TABLE sa.x_score_card_mkt3 (
  part_serial_no VARCHAR2(30 BYTE),
  x_mkt_submkt_name VARCHAR2(30 BYTE),
  x_carrier_name VARCHAR2(30 BYTE),
  parent_name VARCHAR2(40 BYTE),
  npa VARCHAR2(10 BYTE),
  nxx VARCHAR2(10 BYTE),
  ext VARCHAR2(10 BYTE),
  exp_date DATE,
  carrier_id NUMBER
);
ALTER TABLE sa.x_score_card_mkt3 ADD SUPPLEMENTAL LOG GROUP dmtsora104757835_0 (carrier_id, exp_date, ext, npa, nxx, parent_name, part_serial_no, x_carrier_name, x_mkt_submkt_name) ALWAYS;