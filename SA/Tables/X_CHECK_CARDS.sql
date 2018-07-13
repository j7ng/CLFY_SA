CREATE TABLE sa.x_check_cards (
  part_inst_objid NUMBER,
  card_no VARCHAR2(30 BYTE),
  current_dealer VARCHAR2(30 BYTE),
  correct_dealer VARCHAR2(30 BYTE),
  current_status VARCHAR2(30 BYTE),
  correct_statis VARCHAR2(30 BYTE),
  current_order_no VARCHAR2(30 BYTE),
  correct_order_no VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_check_cards ADD SUPPLEMENTAL LOG GROUP dmtsora70912318_0 (card_no, correct_dealer, correct_order_no, correct_statis, current_dealer, current_order_no, current_status, part_inst_objid) ALWAYS;