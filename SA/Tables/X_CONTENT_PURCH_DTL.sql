CREATE TABLE sa.x_content_purch_dtl (
  objid NUMBER,
  x_content2pgm_purch_hdr NUMBER,
  x_item_name VARCHAR2(255 BYTE),
  x_cat VARCHAR2(255 BYTE),
  x_subcat VARCHAR2(255 BYTE),
  x_artist VARCHAR2(255 BYTE),
  x_channel VARCHAR2(30 BYTE),
  x_retailer_id VARCHAR2(30 BYTE),
  x_delivery_status VARCHAR2(30 BYTE),
  content_provider VARCHAR2(255 BYTE),
  order_id VARCHAR2(30 BYTE),
  order_timestamp TIMESTAMP,
  distribution_point VARCHAR2(255 BYTE),
  prog_param2prtnum NUMBER,
  x_ip_address VARCHAR2(30 BYTE),
  x_content2purch_hdr NUMBER,
  x_client_id VARCHAR2(20 BYTE),
  x_content_payment_type VARCHAR2(16 BYTE),
  x_part_num VARCHAR2(20 BYTE),
  x_subscription_type VARCHAR2(16 BYTE),
  x_subscription_units NUMBER(22),
  x_tc_accepted VARCHAR2(3 BYTE),
  x_tracfone_revenue NUMBER(22),
  x_transaction_type VARCHAR2(16 BYTE),
  x_units_conversion_rate NUMBER(22),
  x_units_deduction NUMBER(22),
  x_vendor_id VARCHAR2(20 BYTE),
  x_vendor_product_sku VARCHAR2(30 BYTE),
  x_vendor_revenue NUMBER(22)
);
COMMENT ON TABLE sa.x_content_purch_dtl IS 'TO STORE THE DETAIL RECORD OF THE CONTENT PURCHASED';
COMMENT ON COLUMN sa.x_content_purch_dtl.objid IS 'THE OBJECT ID OF THE TABLE; PRIMARY KEY';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_content2pgm_purch_hdr IS 'FOREIGN KEY TO X_PROGRAM_PURCH_HDR';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_item_name IS 'NAME OF THE ITEM';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_cat IS 'CATEGORY OF THE ITEM';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_subcat IS 'SUB-CATEGORY OF THE ITEM';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_artist IS 'ARTIST OF THE ITEM';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_channel IS 'THE SOURCE BY WHICH THE LEAD, AND SUBSEQUENT CONVERSION, WAS GENERATED.  EX:  "MENU" (3CI MENU) "APP" (HANDSET APP) NULL (NOT KNOWN / GENERIC WRAP) "MYACCOUNT" (A LINK FROM THE MOBILE WEB MYACCOUNT) ETC. ';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_retailer_id IS 'THE B2B VENDOR THAT PROVIDES THE ITEM (CONTENT) THAT WAS SOLD TO THE CUSTOMER.  IT DIFFERS FROM MERCHANT ID BECAUSE IT IS INDEPENDENT OF THE CYBERSOURCE ACCOUNT ACTUALLY USED TO PERFORM THE CREDIT TRANSACTION.  IT IS THE VENDOR/RETAILED ESTABLISHED IN THE OFS SYSTEM.';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_delivery_status IS 'THE STATUS, IF ANY, OF THE PURCHASED ITEM:  "PROCESSING","DOWNLOADED","TO BE REFUNDED","REFUNDED","REFUND FAILED","DOWNLOADED, NOT REFUNDED" (THIS ONE IS FOR AN ITEM THAT WAS "TO BE REFUNDED" BUT WAS ULTIMATELY DECIDED NOT TO BE REFUNDED, DUE TO THE FACT THAT IT WAS DOWNLOADED.) ';
COMMENT ON COLUMN sa.x_content_purch_dtl.content_provider IS 'NAME OF CONTENT PROVIDER';
COMMENT ON COLUMN sa.x_content_purch_dtl.order_id IS 'UNIQUE ID FOR ORDER ';
COMMENT ON COLUMN sa.x_content_purch_dtl.order_timestamp IS 'TIME THE ORDER PLACED';
COMMENT ON COLUMN sa.x_content_purch_dtl.distribution_point IS 'DISTRIBUTION POINT';
COMMENT ON COLUMN sa.x_content_purch_dtl.prog_param2prtnum IS 'REFERENCE TOTABLE_PART_NUM';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_ip_address IS 'IP ADDRESS';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_content2purch_hdr IS 'FOREIGN KEY TO TABLE_X_PURCH_HDR';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_client_id IS 'The vendors client ID .';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_content_payment_type IS 'CC credit card, AIRTIME airtime.';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_part_num IS 'The Part Number from vendor.';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_subscription_type IS 'Null not a subscription sale.';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_subscription_units IS 'NEW for new enrollment, RENEWAL for renewals.';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_tc_accepted IS 'YES indicates customer has accepted the Terms and Conditions. Default is NO.';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_tracfone_revenue IS 'Revenue earned by TracFone for the sale.';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_transaction_type IS 'Number of days before renewal, number of items customer is entitled before renewal.';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_units_conversion_rate IS 'Conversion rate of airtime units to dollars.';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_units_deduction IS 'Units to be deducted from customer account for this sale.';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_vendor_id IS 'The vendor ID.';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_vendor_product_sku IS 'The content product SKU from vendor.';
COMMENT ON COLUMN sa.x_content_purch_dtl.x_vendor_revenue IS 'Revenue earned by vendor for the sale.';