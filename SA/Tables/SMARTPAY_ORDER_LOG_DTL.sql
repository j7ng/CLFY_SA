CREATE TABLE sa.smartpay_order_log_dtl (
  objid NUMBER NOT NULL,
  "GROUP_ID" VARCHAR2(20 BYTE),
  esn VARCHAR2(30 BYTE),
  smp VARCHAR2(30 BYTE),
  sp_ord_log_dtl2sp_ord_log_hdr NUMBER,
  quantity NUMBER,
  product_amount NUMBER(19,2),
  product_type VARCHAR2(50 BYTE),
  product_description VARCHAR2(255 BYTE),
  merchant_product_sku VARCHAR2(30 BYTE),
  CONSTRAINT smartpay_ord_log_dtl_pk PRIMARY KEY (objid) USING INDEX sa.smartpay_ord_log_dtl_unique,
  CONSTRAINT smartpay_ord_log_dtl_fk FOREIGN KEY (sp_ord_log_dtl2sp_ord_log_hdr) REFERENCES sa.smartpay_order_log_hdr (objid)
);
COMMENT ON COLUMN sa.smartpay_order_log_dtl.objid IS 'Internal record number';
COMMENT ON COLUMN sa.smartpay_order_log_dtl."GROUP_ID" IS 'Group Identifier';
COMMENT ON COLUMN sa.smartpay_order_log_dtl.esn IS 'Part Serial Number';
COMMENT ON COLUMN sa.smartpay_order_log_dtl.smp IS 'SMP used for the transaction';
COMMENT ON COLUMN sa.smartpay_order_log_dtl.sp_ord_log_dtl2sp_ord_log_hdr IS 'Reference to sa.smartpay_order_log_hdr.objid';
COMMENT ON COLUMN sa.smartpay_order_log_dtl.quantity IS 'Quantity of Line Item';
COMMENT ON COLUMN sa.smartpay_order_log_dtl.product_amount IS 'Amoutn of Line Item';
COMMENT ON COLUMN sa.smartpay_order_log_dtl.product_type IS 'Product Identifier';
COMMENT ON COLUMN sa.smartpay_order_log_dtl.product_description IS 'Product Description';
COMMENT ON COLUMN sa.smartpay_order_log_dtl.merchant_product_sku IS 'SKU Number';