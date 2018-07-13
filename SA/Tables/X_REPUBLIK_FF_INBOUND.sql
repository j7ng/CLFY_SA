CREATE TABLE sa.x_republik_ff_inbound (
  order_id NUMBER NOT NULL,
  part_serial_no VARCHAR2(20 BYTE) NOT NULL,
  shipment_tracking_id VARCHAR2(50 BYTE),
  transpose_part_no VARCHAR2(40 BYTE)
);
ALTER TABLE sa.x_republik_ff_inbound ADD SUPPLEMENTAL LOG GROUP dmtsora647354438_0 (order_id, part_serial_no, shipment_tracking_id, transpose_part_no) ALWAYS;