CREATE TABLE sa.x_bus_acc_esn (
  account_id NUMBER,
  order_id NUMBER,
  case_id VARCHAR2(255 BYTE),
  esn VARCHAR2(30 BYTE),
  returned NUMBER DEFAULT 0,
  refunded NUMBER DEFAULT 0,
  notes VARCHAR2(400 BYTE),
  price NUMBER,
  tax NUMBER,
  purch_hdr_objid NUMBER,
  refund_case_id VARCHAR2(30 BYTE),
  domain VARCHAR2(30 BYTE),
  combo NUMBER,
  part_number VARCHAR2(30 BYTE),
  tracking_no VARCHAR2(30 BYTE),
  combo_part_number VARCHAR2(30 BYTE),
  contact_objid NUMBER
);
COMMENT ON TABLE sa.x_bus_acc_esn IS 'This B2B Table stores all the serial numbers dispatched in association to sales orders.  It also controls the returns and refunds.';
COMMENT ON COLUMN sa.x_bus_acc_esn.account_id IS 'Account ID, references account_id in x_business_accounts';
COMMENT ON COLUMN sa.x_bus_acc_esn.order_id IS 'Order ID, Sales Order ID, references order_id in x_sales_orders';
COMMENT ON COLUMN sa.x_bus_acc_esn.case_id IS 'Case ID, refences id_number in table_case, for warehouse case associated to the shipment.';
COMMENT ON COLUMN sa.x_bus_acc_esn.esn IS 'Item Serial Number (mostly phones)';
COMMENT ON COLUMN sa.x_bus_acc_esn.returned IS 'Returned Flag: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_bus_acc_esn.refunded IS 'Refunded Flag: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_bus_acc_esn.notes IS 'Notes and Comments';
COMMENT ON COLUMN sa.x_bus_acc_esn.price IS 'Price charged for the phone.';
COMMENT ON COLUMN sa.x_bus_acc_esn.tax IS 'Tax charged for the phone';
COMMENT ON COLUMN sa.x_bus_acc_esn.purch_hdr_objid IS 'Reference to objid in table_x_purch_hdr';
COMMENT ON COLUMN sa.x_bus_acc_esn.refund_case_id IS 'Reference id_number in table_case for refund case.';
COMMENT ON COLUMN sa.x_bus_acc_esn.domain IS 'Domain for part number: PHONES, REDEMPTION_CARDS, etc.';
COMMENT ON COLUMN sa.x_bus_acc_esn.combo IS 'Como Part Flag: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_bus_acc_esn.part_number IS 'Part Number';
COMMENT ON COLUMN sa.x_bus_acc_esn.tracking_no IS 'Tracking Number';
COMMENT ON COLUMN sa.x_bus_acc_esn.combo_part_number IS 'Combo Part Number';
COMMENT ON COLUMN sa.x_bus_acc_esn.contact_objid IS 'Contact OBJID, reference objid in table_contact.';