CREATE TABLE sa.tf_toss_interface_table_s_drop (
  row_id ROWID,
  tf_part_num_parent VARCHAR2(100 BYTE),
  tf_serial_num VARCHAR2(100 BYTE),
  tf_part_type VARCHAR2(100 BYTE),
  tf_card_pin_num VARCHAR2(100 BYTE),
  tf_manuf_location_code VARCHAR2(100 BYTE),
  tf_manuf_location_name VARCHAR2(100 BYTE),
  tf_ff_location_code VARCHAR2(100 BYTE),
  tf_ret_location_code VARCHAR2(100 BYTE),
  tf_order_num VARCHAR2(40 BYTE),
  creation_date DATE,
  created_by VARCHAR2(100 BYTE),
  ff_receive_date DATE,
  retailer_ship_date DATE,
  tf_po_num VARCHAR2(100 BYTE),
  toss_extract_flag VARCHAR2(100 BYTE),
  old_toss_extract_flag VARCHAR2(100 BYTE),
  toss_extract_date DATE,
  toss_redemption_code VARCHAR2(100 BYTE),
  last_update_date DATE,
  last_updated_by VARCHAR2(100 BYTE)
);
ALTER TABLE sa.tf_toss_interface_table_s_drop ADD SUPPLEMENTAL LOG GROUP dmtsora1298570967_0 (created_by, creation_date, ff_receive_date, last_updated_by, last_update_date, old_toss_extract_flag, retailer_ship_date, row_id, tf_card_pin_num, tf_ff_location_code, tf_manuf_location_code, tf_manuf_location_name, tf_order_num, tf_part_num_parent, tf_part_type, tf_po_num, tf_ret_location_code, tf_serial_num, toss_extract_date, toss_extract_flag, toss_redemption_code) ALWAYS;