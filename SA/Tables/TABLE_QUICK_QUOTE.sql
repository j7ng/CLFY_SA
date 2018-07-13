CREATE TABLE sa.table_quick_quote (
  objid NUMBER,
  "ID" VARCHAR2(30 BYTE),
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE),
  total_amt NUMBER,
  create_date DATE,
  expire_date DATE,
  issue_date DATE,
  request_date DATE,
  po_number VARCHAR2(30 BYTE),
  fob VARCHAR2(30 BYTE),
  ship_via VARCHAR2(80 BYTE),
  ship_to_attn VARCHAR2(50 BYTE),
  bill_to_attn VARCHAR2(50 BYTE),
  status VARCHAR2(30 BYTE),
  bill_addr1 VARCHAR2(200 BYTE),
  bill_addr2 VARCHAR2(200 BYTE),
  bill_city VARCHAR2(30 BYTE),
  bill_state VARCHAR2(30 BYTE),
  bill_zip VARCHAR2(20 BYTE),
  ship_addr1 VARCHAR2(200 BYTE),
  ship_addr2 VARCHAR2(200 BYTE),
  ship_city VARCHAR2(30 BYTE),
  ship_state VARCHAR2(30 BYTE),
  ship_zip VARCHAR2(20 BYTE),
  comments LONG,
  ship_country VARCHAR2(40 BYTE),
  bill_country VARCHAR2(40 BYTE),
  discount_pct NUMBER,
  discount_amt NUMBER,
  tax_pct NUMBER,
  tax_amt NUMBER,
  freight_amt NUMBER,
  pay_terms VARCHAR2(40 BYTE),
  dev NUMBER,
  q_quote2opportunity NUMBER(*,0),
  q_quote2contact NUMBER(*,0),
  q_quote2site NUMBER(*,0),
  q_quote2price_prog NUMBER(*,0),
  qq_editor2user NUMBER(*,0)
);
ALTER TABLE sa.table_quick_quote ADD SUPPLEMENTAL LOG GROUP dmtsora1636417413_1 (dev, qq_editor2user, q_quote2contact, q_quote2opportunity, q_quote2price_prog, q_quote2site) ALWAYS;
ALTER TABLE sa.table_quick_quote ADD SUPPLEMENTAL LOG GROUP dmtsora1636417413_0 (bill_addr1, bill_addr2, bill_city, bill_country, bill_state, bill_to_attn, bill_zip, create_date, description, discount_amt, discount_pct, expire_date, fob, freight_amt, "ID", issue_date, objid, pay_terms, po_number, request_date, ship_addr1, ship_addr2, ship_city, ship_country, ship_state, ship_to_attn, ship_via, ship_zip, status, s_description, tax_amt, tax_pct, total_amt) ALWAYS;
COMMENT ON TABLE sa.table_quick_quote IS 'A quote which contains minimum information; reserved obsolete, replaced by contract (86)';
COMMENT ON COLUMN sa.table_quick_quote.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_quick_quote."ID" IS 'Quote ID number';
COMMENT ON COLUMN sa.table_quick_quote.description IS 'Description of the quote';
COMMENT ON COLUMN sa.table_quick_quote.total_amt IS 'Total currency amount of the quote';
COMMENT ON COLUMN sa.table_quick_quote.create_date IS 'The create date of the quote';
COMMENT ON COLUMN sa.table_quick_quote.expire_date IS 'The expiration date of the quote';
COMMENT ON COLUMN sa.table_quick_quote.issue_date IS 'The issue date of the quote';
COMMENT ON COLUMN sa.table_quick_quote.request_date IS 'The date the quote was requested';
COMMENT ON COLUMN sa.table_quick_quote.po_number IS 'The purchase order for the request';
COMMENT ON COLUMN sa.table_quick_quote.fob IS 'Identifies the FOB for the quick quote';
COMMENT ON COLUMN sa.table_quick_quote.ship_via IS 'Requested means of shipment. This is from a Clarify-defined popup list';
COMMENT ON COLUMN sa.table_quick_quote.ship_to_attn IS 'Name of person to whom shipment will be directed';
COMMENT ON COLUMN sa.table_quick_quote.bill_to_attn IS 'Name of person to whom billing will be directed';
COMMENT ON COLUMN sa.table_quick_quote.status IS 'Status of the quote. This is from an user-defined popup list';
COMMENT ON COLUMN sa.table_quick_quote.bill_addr1 IS 'Line one of street address for billing';
COMMENT ON COLUMN sa.table_quick_quote.bill_addr2 IS 'Line two of street address for billing';
COMMENT ON COLUMN sa.table_quick_quote.bill_city IS 'City for billing address';
COMMENT ON COLUMN sa.table_quick_quote.bill_state IS 'State for billing address';
COMMENT ON COLUMN sa.table_quick_quote.bill_zip IS 'Zip or postal code for billing address';
COMMENT ON COLUMN sa.table_quick_quote.ship_addr1 IS 'Line one of street address for shiping';
COMMENT ON COLUMN sa.table_quick_quote.ship_addr2 IS 'Line two of street address for shiping';
COMMENT ON COLUMN sa.table_quick_quote.ship_city IS 'City for shiping address';
COMMENT ON COLUMN sa.table_quick_quote.ship_state IS 'State for shiping address';
COMMENT ON COLUMN sa.table_quick_quote.ship_zip IS 'Zip or postal code for shiping address';
COMMENT ON COLUMN sa.table_quick_quote.comments IS 'The multi-line field that contains the comments to be written to the quote';
COMMENT ON COLUMN sa.table_quick_quote.ship_country IS 'Country of the shiping address';
COMMENT ON COLUMN sa.table_quick_quote.bill_country IS 'Country of the billing address';
COMMENT ON COLUMN sa.table_quick_quote.discount_pct IS 'Percentage discount on the quote';
COMMENT ON COLUMN sa.table_quick_quote.discount_amt IS 'Discount amount on the quote';
COMMENT ON COLUMN sa.table_quick_quote.tax_pct IS 'Tax percentage';
COMMENT ON COLUMN sa.table_quick_quote.tax_amt IS 'Total tax amount';
COMMENT ON COLUMN sa.table_quick_quote.freight_amt IS 'Discount amount on the quote';
COMMENT ON COLUMN sa.table_quick_quote.pay_terms IS 'Payment terms; e.g., COD, FOD, installments';
COMMENT ON COLUMN sa.table_quick_quote.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_quick_quote.q_quote2opportunity IS 'Opportunity for which the quote was made';
COMMENT ON COLUMN sa.table_quick_quote.q_quote2contact IS 'Contact for the quote';
COMMENT ON COLUMN sa.table_quick_quote.q_quote2site IS 'Related site';
COMMENT ON COLUMN sa.table_quick_quote.q_quote2price_prog IS 'Price schedule used for the quote';
COMMENT ON COLUMN sa.table_quick_quote.qq_editor2user IS 'User currently editing the quote';