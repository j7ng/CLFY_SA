CREATE TABLE sa.x_voucher_order_dtl (
  objid NUMBER NOT NULL,
  order_dtl2order_hdr NUMBER,
  x_description VARCHAR2(200 BYTE),
  x_type VARCHAR2(50 BYTE),
  x_part_number VARCHAR2(50 BYTE),
  x_serial_number VARCHAR2(50 BYTE),
  x_quantity NUMBER,
  x_market_price NUMBER,
  x_sold_price NUMBER
);
COMMENT ON TABLE sa.x_voucher_order_dtl IS 'Table - used to store the order detailed info.';
COMMENT ON COLUMN sa.x_voucher_order_dtl.objid IS 'unique record identifier';
COMMENT ON COLUMN sa.x_voucher_order_dtl.order_dtl2order_hdr IS 'reference to order summary table objid';