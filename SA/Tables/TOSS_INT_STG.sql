CREATE TABLE sa.toss_int_stg (
  tf_serial_num VARCHAR2(100 BYTE),
  tf_order_num VARCHAR2(40 BYTE),
  tf_part_num_transpose VARCHAR2(100 BYTE),
  tf_invoiced_number NUMBER,
  tf_part_type VARCHAR2(100 BYTE),
  tf_po_num VARCHAR2(100 BYTE),
  retailer_ship_date DATE,
  ff_receive_date DATE,
  tf_ff_location_name VARCHAR2(100 BYTE),
  tf_ff_location_code VARCHAR2(100 BYTE),
  tf_ret_location_code VARCHAR2(100 BYTE),
  tf_ret_location_name VARCHAR2(100 BYTE),
  tf_part_num_parent VARCHAR2(100 BYTE)
);