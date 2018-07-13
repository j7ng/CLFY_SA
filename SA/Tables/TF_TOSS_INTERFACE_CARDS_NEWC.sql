CREATE TABLE sa.tf_toss_interface_cards_newc (
  row_id UROWID NOT NULL,
  tf_part_num_parent VARCHAR2(100 BYTE) NOT NULL,
  tf_serial_num VARCHAR2(100 BYTE) NOT NULL,
  tf_part_type VARCHAR2(100 BYTE) NOT NULL,
  tf_card_pin_num VARCHAR2(100 BYTE),
  tf_manuf_location_code VARCHAR2(100 BYTE),
  tf_manuf_location_name VARCHAR2(100 BYTE),
  tf_ff_location_code VARCHAR2(100 BYTE),
  tf_ret_location_code VARCHAR2(100 BYTE),
  tf_order_num VARCHAR2(40 BYTE),
  creation_date DATE NOT NULL,
  created_by VARCHAR2(100 BYTE) NOT NULL,
  ff_receive_date DATE,
  retailer_ship_date DATE,
  tf_po_num VARCHAR2(100 BYTE) NOT NULL,
  toss_extract_flag VARCHAR2(100 BYTE) NOT NULL,
  old_toss_extract_flag VARCHAR2(100 BYTE) NOT NULL,
  toss_extract_date DATE,
  toss_redemption_code VARCHAR2(100 BYTE),
  last_update_date DATE NOT NULL,
  old_last_update_date DATE NOT NULL,
  last_updated_by VARCHAR2(100 BYTE) NOT NULL,
  tf_part_num_transpose VARCHAR2(100 BYTE) NOT NULL,
  tf_master_serial_num VARCHAR2(40 BYTE),
  ship_to_id NUMBER(15)
);