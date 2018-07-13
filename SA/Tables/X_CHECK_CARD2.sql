CREATE TABLE sa.x_check_card2 (
  part_inst_objid NUMBER,
  card_no NUMBER,
  current_dealer VARCHAR2(30 BYTE),
  correct_dealer VARCHAR2(30 BYTE),
  current_status VARCHAR2(30 BYTE),
  correct_status VARCHAR2(30 BYTE),
  current_order_no VARCHAR2(30 BYTE),
  correct_order_no VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_check_card2 ADD SUPPLEMENTAL LOG GROUP dmtsora101384865_0 (card_no, correct_dealer, correct_order_no, correct_status, current_dealer, current_order_no, current_status, part_inst_objid) ALWAYS;