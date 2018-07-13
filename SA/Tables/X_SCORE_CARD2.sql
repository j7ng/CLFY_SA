CREATE TABLE sa.x_score_card2 (
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  start_date DATE,
  card_due_date DATE,
  x_zipcode VARCHAR2(20 BYTE),
  region VARCHAR2(40 BYTE),
  dma VARCHAR2(100 BYTE),
  "STATE" VARCHAR2(100 BYTE),
  x_mkt_submkt_name VARCHAR2(30 BYTE),
  x_carrier_name VARCHAR2(30 BYTE),
  carrier_id NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  x_technology VARCHAR2(20 BYTE),
  x_amigo_user_flag NUMBER,
  esn_part_number_product_code NUMBER,
  contact_objid NUMBER
);
ALTER TABLE sa.x_score_card2 ADD SUPPLEMENTAL LOG GROUP dmtsora1632590265_0 (card_due_date, carrier_id, contact_objid, dma, esn, esn_part_number_product_code, "MIN", "NAME", region, start_date, "STATE", x_amigo_user_flag, x_carrier_name, x_mkt_submkt_name, x_technology, x_zipcode) ALWAYS;