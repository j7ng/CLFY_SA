CREATE TABLE sa.table_account (
  objid NUMBER,
  account_id VARCHAR2(40 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  "TYPE" VARCHAR2(40 BYTE),
  ptl_revn NUMBER(19,4),
  annual_revn NUMBER(19,4),
  size_empl NUMBER,
  description VARCHAR2(255 BYTE),
  sales_rating VARCHAR2(25 BYTE),
  product VARCHAR2(255 BYTE),
  comp_product VARCHAR2(255 BYTE),
  comp_psn VARCHAR2(40 BYTE),
  cust_since DATE,
  inst_prod VARCHAR2(255 BYTE),
  stock_sym VARCHAR2(10 BYTE),
  "OWNERSHIP" VARCHAR2(25 BYTE),
  tax_exempt VARCHAR2(25 BYTE),
  dev NUMBER,
  account2bus_org NUMBER(*,0),
  default2price_prog NUMBER(*,0)
);
ALTER TABLE sa.table_account ADD SUPPLEMENTAL LOG GROUP dmtsora921487154_0 (account2bus_org, account_id, annual_revn, comp_product, comp_psn, cust_since, default2price_prog, description, dev, inst_prod, "NAME", objid, "OWNERSHIP", product, ptl_revn, sales_rating, size_empl, stock_sym, tax_exempt, "TYPE") ALWAYS;