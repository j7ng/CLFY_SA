CREATE TABLE sa.table_x_exch_shipping_dtl (
  objid NUMBER NOT NULL,
  x_shipping_category VARCHAR2(20 BYTE) NOT NULL,
  x_shipping_part_num VARCHAR2(40 BYTE),
  x_shipping_price VARCHAR2(20 BYTE),
  x_domain_type VARCHAR2(20 BYTE) NOT NULL,
  x_is_expedite VARCHAR2(1 BYTE),
  x_is_address_po_box VARCHAR2(1 BYTE),
  x_min_delivery_days NUMBER,
  x_max_delivery_days NUMBER,
  x_shipping_method VARCHAR2(40 BYTE),
  x_courier_id VARCHAR2(20 BYTE),
  CONSTRAINT table_x_exch_shipping_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.table_x_exch_shipping_dtl IS 'This table is being used to store exchange/case shipping details';
COMMENT ON COLUMN sa.table_x_exch_shipping_dtl.objid IS 'OBJID of exchange shipping details';
COMMENT ON COLUMN sa.table_x_exch_shipping_dtl.x_shipping_category IS 'Shipping category would be Free and Expedite';
COMMENT ON COLUMN sa.table_x_exch_shipping_dtl.x_shipping_part_num IS 'This Dummay Part Number for Exchange case Shipping';
COMMENT ON COLUMN sa.table_x_exch_shipping_dtl.x_shipping_price IS 'Shipping Price';
COMMENT ON COLUMN sa.table_x_exch_shipping_dtl.x_domain_type IS 'Shipping Part domain : PHONE and SIM';
COMMENT ON COLUMN sa.table_x_exch_shipping_dtl.x_is_expedite IS 'Flag to eligibility for expedit Shipping : Y/N';
COMMENT ON COLUMN sa.table_x_exch_shipping_dtl.x_is_address_po_box IS 'Flag for - Is Adress in PO Box or not : Y/N';
COMMENT ON COLUMN sa.table_x_exch_shipping_dtl.x_min_delivery_days IS 'Minimum number of days under shipping category';
COMMENT ON COLUMN sa.table_x_exch_shipping_dtl.x_max_delivery_days IS 'Maximum number of days under shipping category';
COMMENT ON COLUMN sa.table_x_exch_shipping_dtl.x_shipping_method IS 'Shipping Method Name';
COMMENT ON COLUMN sa.table_x_exch_shipping_dtl.x_courier_id IS 'Courier Id';