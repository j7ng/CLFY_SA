CREATE TABLE sa.x_republik_ff_outbound (
  order_id NUMBER,
  part_serial_no VARCHAR2(20 BYTE),
  shipment_tracking_id VARCHAR2(50 BYTE),
  transpose_part_no VARCHAR2(150 BYTE)
);
ALTER TABLE sa.x_republik_ff_outbound ADD SUPPLEMENTAL LOG GROUP dmtsora481809433_0 (order_id, part_serial_no, shipment_tracking_id, transpose_part_no) ALWAYS;