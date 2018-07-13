CREATE TABLE sa.table_n_packages (
  objid NUMBER,
  dev NUMBER,
  n_templateid NUMBER,
  n_partnumber VARCHAR2(50 BYTE),
  n_description VARCHAR2(50 BYTE),
  n_listprice NUMBER(19,4),
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE,
  n_pricebookobjid NUMBER,
  n_priceqty NUMBER,
  n_priceqtycontext NUMBER,
  n_pkg2n_templates NUMBER
);
ALTER TABLE sa.table_n_packages ADD SUPPLEMENTAL LOG GROUP dmtsora1896463656_0 (dev, n_description, n_effectivedate, n_expirationdate, n_listprice, n_modificationdate, n_partnumber, n_pkg2n_templates, n_pricebookobjid, n_priceqty, n_priceqtycontext, n_templateid, objid) ALWAYS;