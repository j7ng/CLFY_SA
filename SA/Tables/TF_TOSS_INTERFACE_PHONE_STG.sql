CREATE TABLE sa.tf_toss_interface_phone_stg (
  tf_part_num_parent VARCHAR2(100 BYTE),
  tf_part_num_transpose VARCHAR2(100 BYTE),
  transceiver_num VARCHAR2(100 BYTE),
  tf_manuf_location_code VARCHAR2(100 BYTE),
  tf_ff_location_code VARCHAR2(100 BYTE),
  tf_ret_location_code VARCHAR2(100 BYTE),
  toss_extract_flag VARCHAR2(100 BYTE),
  tf_serial_num VARCHAR2(100 BYTE),
  tf_part_type VARCHAR2(100 BYTE),
  tf_card_pin_num VARCHAR2(100 BYTE),
  tf_manuf_location_name VARCHAR2(100 BYTE),
  tf_order_num VARCHAR2(40 BYTE),
  creation_date DATE,
  created_by VARCHAR2(100 BYTE),
  ff_receive_date DATE,
  retailer_ship_date DATE,
  serial_invalid_date DATE,
  serial_valid_insert_date DATE,
  tf_phone_refurb_date DATE,
  toss_extract_date DATE,
  last_update_date DATE,
  last_updated_by VARCHAR2(100 BYTE)
);
ALTER TABLE sa.tf_toss_interface_phone_stg ADD SUPPLEMENTAL LOG GROUP dmtsora573563245_0 (created_by, creation_date, ff_receive_date, last_updated_by, last_update_date, retailer_ship_date, serial_invalid_date, serial_valid_insert_date, tf_card_pin_num, tf_ff_location_code, tf_manuf_location_code, tf_manuf_location_name, tf_order_num, tf_part_num_parent, tf_part_num_transpose, tf_part_type, tf_phone_refurb_date, tf_ret_location_code, tf_serial_num, toss_extract_date, toss_extract_flag, transceiver_num) ALWAYS;