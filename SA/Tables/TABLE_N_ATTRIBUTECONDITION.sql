CREATE TABLE sa.table_n_attributecondition (
  objid NUMBER,
  dev NUMBER,
  n_path VARCHAR2(255 BYTE),
  n_operator VARCHAR2(30 BYTE),
  n_value VARCHAR2(128 BYTE),
  n_expirationdate DATE,
  n_effectivedate DATE,
  n_modificationdate DATE,
  cond2n_attributedefinition NUMBER
);
ALTER TABLE sa.table_n_attributecondition ADD SUPPLEMENTAL LOG GROUP dmtsora930364146_0 (cond2n_attributedefinition, dev, n_effectivedate, n_expirationdate, n_modificationdate, n_operator, n_path, n_value, objid) ALWAYS;