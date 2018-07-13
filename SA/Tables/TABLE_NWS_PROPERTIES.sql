CREATE TABLE sa.table_nws_properties (
  objid NUMBER,
  dev NUMBER,
  n_name VARCHAR2(255 BYTE),
  n_sectionname VARCHAR2(255 BYTE),
  n_englishdescription VARCHAR2(255 BYTE),
  n_type NUMBER,
  n_reserved NUMBER,
  n_booleanvalue NUMBER,
  n_currencyvalue NUMBER(19,4),
  n_realnumbervalue NUMBER(19,4),
  n_integervalue NUMBER,
  n_stringvalue VARCHAR2(255 BYTE),
  n_timestampvalue DATE,
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE
);
ALTER TABLE sa.table_nws_properties ADD SUPPLEMENTAL LOG GROUP dmtsora1472242808_0 (dev, n_booleanvalue, n_currencyvalue, n_effectivedate, n_englishdescription, n_expirationdate, n_integervalue, n_modificationdate, n_name, n_realnumbervalue, n_reserved, n_sectionname, n_stringvalue, n_timestampvalue, n_type, objid) ALWAYS;