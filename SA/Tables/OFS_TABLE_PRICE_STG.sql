CREATE TABLE sa.ofs_table_price_stg (
  tf_part_num_parent VARCHAR2(100 BYTE),
  tf_part_num_transpose VARCHAR2(100 BYTE),
  tf_part_type VARCHAR2(100 BYTE),
  tf_serial_num VARCHAR2(100 BYTE),
  order_number VARCHAR2(40 BYTE),
  asn_type_code VARCHAR2(5 BYTE),
  header_id NUMBER,
  shipment_line_num NUMBER,
  unit_selling_price NUMBER
);