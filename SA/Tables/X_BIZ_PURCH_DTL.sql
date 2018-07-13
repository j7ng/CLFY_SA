CREATE TABLE sa.x_biz_purch_dtl (
  objid NUMBER,
  x_esn VARCHAR2(255 BYTE),
  x_amount NUMBER(19,2),
  line_number NUMBER,
  part_number VARCHAR2(50 BYTE),
  biz_purch_dtl2biz_purch_hdr NUMBER,
  x_quantity NUMBER,
  domain VARCHAR2(100 BYTE),
  sales_rate FLOAT,
  salestax_amount NUMBER,
  e911_rate FLOAT,
  x_e911_tax_amount NUMBER,
  usf_rate FLOAT,
  x_usf_taxamount NUMBER,
  rcrf_rate FLOAT,
  x_rcrf_tax_amount NUMBER,
  total_tax_amount NUMBER,
  total_amount NUMBER,
  freight_amount NUMBER,
  freight_method VARCHAR2(100 BYTE),
  freight_carrier VARCHAR2(100 BYTE),
  discount_amount NUMBER,
  add_tax_1 NUMBER,
  add_tax_2 NUMBER,
  "CONDITION" VARCHAR2(25 BYTE),
  description VARCHAR2(100 BYTE),
  kind VARCHAR2(50 BYTE),
  taxable VARCHAR2(10 BYTE),
  smp VARCHAR2(30 BYTE),
  groupidentifier VARCHAR2(20 BYTE),
  sim VARCHAR2(50 BYTE),
  accessory_serial VARCHAR2(50 BYTE),
  CONSTRAINT biz_purch_dtl_unique UNIQUE (objid)
);
COMMENT ON TABLE sa.x_biz_purch_dtl IS 'Table having detail B2B order purchase information';
COMMENT ON COLUMN sa.x_biz_purch_dtl.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_biz_purch_dtl.x_esn IS 'ESN or Airtime SMP or any other product value';
COMMENT ON COLUMN sa.x_biz_purch_dtl.x_amount IS 'MSRP of the individual item';
COMMENT ON COLUMN sa.x_biz_purch_dtl.line_number IS '1 or 2 or 3 etc.,';
COMMENT ON COLUMN sa.x_biz_purch_dtl.part_number IS 'PART NUMBER of Phone or Airtime or Accessory or Bundled part number';
COMMENT ON COLUMN sa.x_biz_purch_dtl.biz_purch_dtl2biz_purch_hdr IS 'PURCH HDR OBJID relation';
COMMENT ON COLUMN sa.x_biz_purch_dtl.x_quantity IS 'QUANTITY';
COMMENT ON COLUMN sa.x_biz_purch_dtl.domain IS 'BUNDLE or AIRTIME or PHONES or ACCESSORY';
COMMENT ON COLUMN sa.x_biz_purch_dtl.sales_rate IS 'SALES RATE ';
COMMENT ON COLUMN sa.x_biz_purch_dtl.salestax_amount IS 'SALESTAX AMOUNT';
COMMENT ON COLUMN sa.x_biz_purch_dtl.x_e911_tax_amount IS 'E911 TAX AMOUNT';
COMMENT ON COLUMN sa.x_biz_purch_dtl.usf_rate IS 'USF RATE';
COMMENT ON COLUMN sa.x_biz_purch_dtl.x_usf_taxamount IS 'X USF TAXAMOUNT ';
COMMENT ON COLUMN sa.x_biz_purch_dtl.rcrf_rate IS 'RCRF RAte ';
COMMENT ON COLUMN sa.x_biz_purch_dtl.x_rcrf_tax_amount IS 'RCRF TAX AMOUNT ';
COMMENT ON COLUMN sa.x_biz_purch_dtl.total_tax_amount IS 'TOTAL TAX AMOUNT';
COMMENT ON COLUMN sa.x_biz_purch_dtl.total_amount IS 'TOTAL AMOUNT';
COMMENT ON COLUMN sa.x_biz_purch_dtl.freight_amount IS 'Shipping charges';
COMMENT ON COLUMN sa.x_biz_purch_dtl.freight_method IS '2 DAY, OVER NIGHT, 3 DAY etc.,';
COMMENT ON COLUMN sa.x_biz_purch_dtl.freight_carrier IS 'FEDEX, USPS, UPS';
COMMENT ON COLUMN sa.x_biz_purch_dtl.discount_amount IS 'discount through promotions, etc.,';
COMMENT ON COLUMN sa.x_biz_purch_dtl.add_tax_1 IS 'Additional tax';
COMMENT ON COLUMN sa.x_biz_purch_dtl.add_tax_2 IS 'Additional tax';
COMMENT ON COLUMN sa.x_biz_purch_dtl."CONDITION" IS 'To Indicate it is New, Refurbished, used';
COMMENT ON COLUMN sa.x_biz_purch_dtl.description IS 'Short description of the cart item.';
COMMENT ON COLUMN sa.x_biz_purch_dtl.kind IS 'To Indicate whether it is Device or Service plan purchase';
COMMENT ON COLUMN sa.x_biz_purch_dtl.taxable IS 'To indicate whether it is taxable';
COMMENT ON COLUMN sa.x_biz_purch_dtl.groupidentifier IS 'Group identifier for detail record. ';