CREATE TABLE sa.table_n_attributedefinition (
  objid NUMBER,
  dev NUMBER,
  n_name VARCHAR2(30 BYTE),
  n_focusobject VARCHAR2(64 BYTE),
  n_productpath VARCHAR2(255 BYTE),
  n_expirationdate DATE,
  n_effectivedate DATE,
  n_modificationdate DATE,
  def2n_templates NUMBER
);
ALTER TABLE sa.table_n_attributedefinition ADD SUPPLEMENTAL LOG GROUP dmtsora1649286013_0 (def2n_templates, dev, n_effectivedate, n_expirationdate, n_focusobject, n_modificationdate, n_name, n_productpath, objid) ALWAYS;