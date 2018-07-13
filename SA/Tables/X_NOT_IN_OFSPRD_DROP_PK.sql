CREATE TABLE sa.x_not_in_ofsprd_drop_pk (
  card_smp VARCHAR2(30 BYTE),
  redemption_date DATE,
  x_part_inst_status VARCHAR2(20 BYTE),
  x_creation_date DATE,
  x_insert_date DATE,
  action_type VARCHAR2(30 BYTE),
  card_dealer_id VARCHAR2(80 BYTE),
  card_part_number VARCHAR2(30 BYTE),
  redemption_type VARCHAR2(30 BYTE),
  sourcesystem VARCHAR2(30 BYTE),
  user_login_name VARCHAR2(30 BYTE),
  login_name VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_not_in_ofsprd_drop_pk ADD SUPPLEMENTAL LOG GROUP dmtsora1572542079_0 (action_type, card_dealer_id, card_part_number, card_smp, login_name, redemption_date, redemption_type, sourcesystem, user_login_name, x_creation_date, x_insert_date, x_part_inst_status) ALWAYS;