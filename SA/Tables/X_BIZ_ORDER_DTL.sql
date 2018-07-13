CREATE TABLE sa.x_biz_order_dtl (
  objid NUMBER NOT NULL,
  x_item_type VARCHAR2(255 BYTE) NOT NULL,
  x_item_value VARCHAR2(255 BYTE),
  x_item_part VARCHAR2(50 BYTE) NOT NULL,
  x_ecom_order_number VARCHAR2(50 BYTE) NOT NULL,
  x_ofs_order_number NUMBER,
  x_order_line_number NUMBER,
  x_amount NUMBER(19,2),
  x_sales_tax_amount NUMBER,
  x_e911_tax_amount NUMBER,
  x_usf_tax_amount NUMBER,
  x_rcrf_tax_amount NUMBER,
  x_total_tax_amount NUMBER,
  x_total_amount NUMBER,
  x_ecom_group_id VARCHAR2(50 BYTE),
  x_extract_flag VARCHAR2(3 BYTE),
  x_extract_date DATE,
  x_creation_date DATE,
  x_create_by VARCHAR2(100 BYTE),
  x_last_update_date DATE,
  x_last_updated_by VARCHAR2(100 BYTE),
  biz_order_dtl2biz_purch_hdr_cr NUMBER,
  biz_order_dtl2biz_order_dtl_cr NUMBER,
  shipment_tracking_number VARCHAR2(50 BYTE),
  shipment_date DATE,
  shipment_carrier VARCHAR2(20 BYTE),
  x_vendor_id VARCHAR2(100 BYTE),
  x_ship_tax_amount NUMBER(22)
);
COMMENT ON TABLE sa.x_biz_order_dtl IS 'Table Will Record Garnular Level Of Order At Fulfillment Process';
COMMENT ON COLUMN sa.x_biz_order_dtl.objid IS 'Unique Identifier';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_item_type IS 'ESN/Plan etc..';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_item_value IS 'ESN/Plan Value';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_item_part IS 'ESN/Plan Part Number';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_ecom_order_number IS 'Ecommerce Order Number';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_ofs_order_number IS 'OFS Order Number';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_amount IS 'Amount With Out Taxes';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_sales_tax_amount IS 'Sales Tax Amount';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_e911_tax_amount IS 'E911 Tax Amount';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_usf_tax_amount IS 'Usf Taxamount';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_rcrf_tax_amount IS 'Rcrf Tax Amountr';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_total_tax_amount IS 'Total Tax Amount';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_total_amount IS 'Total Amount With Taxes';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_ecom_group_id IS 'ESN and PLAN Group ID Generated by Ecommerece';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_extract_flag IS 'To Identify Item Status';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_extract_date IS 'Date of Item Extraction';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_creation_date IS 'Date OF Item Creation';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_create_by IS 'NAME OF OFS PROCESS';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_last_update_date IS 'Last Update Date';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_last_updated_by IS 'NAME OF CLARIFY PROCESS';
COMMENT ON COLUMN sa.x_biz_order_dtl.biz_order_dtl2biz_purch_hdr_cr IS 'X_biz_purch_hdr Refund Refernce';
COMMENT ON COLUMN sa.x_biz_order_dtl.biz_order_dtl2biz_order_dtl_cr IS 'X_biz_order_dtl Refund Refernce';
COMMENT ON COLUMN sa.x_biz_order_dtl.shipment_tracking_number IS 'Tracking Number of the Shipment';
COMMENT ON COLUMN sa.x_biz_order_dtl.shipment_date IS 'Shipment date';
COMMENT ON COLUMN sa.x_biz_order_dtl.shipment_carrier IS 'Shipment Carrier';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_vendor_id IS 'Vendor Id for the line Item';
COMMENT ON COLUMN sa.x_biz_order_dtl.x_ship_tax_amount IS 'The Shipping tax at the line item level';