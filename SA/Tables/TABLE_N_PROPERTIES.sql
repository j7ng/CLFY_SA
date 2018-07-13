CREATE TABLE sa.table_n_properties (
  objid NUMBER,
  dev NUMBER,
  n_itemid NUMBER,
  n_itemtypeid NUMBER,
  n_name VARCHAR2(50 BYTE),
  n_type NUMBER,
  n_booleanvalue NUMBER,
  n_currencyvalue NUMBER(19,4),
  n_realnumbervalue NUMBER(19,4),
  n_integervalue NUMBER,
  n_stringvalue VARCHAR2(50 BYTE),
  n_timestampvalue DATE,
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE,
  n_propts2n_attribute NUMBER
);
ALTER TABLE sa.table_n_properties ADD SUPPLEMENTAL LOG GROUP dmtsora32931980_0 (dev, n_booleanvalue, n_currencyvalue, n_effectivedate, n_expirationdate, n_integervalue, n_itemid, n_itemtypeid, n_modificationdate, n_name, n_propts2n_attribute, n_realnumbervalue, n_stringvalue, n_timestampvalue, n_type, objid) ALWAYS;
COMMENT ON TABLE sa.table_n_properties IS 'Holds the extended properties for items in the database. This object would have all the user-defined properties for products, options, option templates, product templates, packages, and attachments';
COMMENT ON COLUMN sa.table_n_properties.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_n_properties.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_n_properties.n_itemid IS 'The ID of the item that has the property';
COMMENT ON COLUMN sa.table_n_properties.n_itemtypeid IS 'Item type from N_ItemType table. It is used in conjunction with the N_ItemId field to identify to the item to which the property belongs';
COMMENT ON COLUMN sa.table_n_properties.n_name IS 'The name of the property';
COMMENT ON COLUMN sa.table_n_properties.n_type IS 'The type of the property';
COMMENT ON COLUMN sa.table_n_properties.n_booleanvalue IS 'If the property involves a boolean value, the value';
COMMENT ON COLUMN sa.table_n_properties.n_currencyvalue IS 'If the property involves a currency value, the value';
COMMENT ON COLUMN sa.table_n_properties.n_realnumbervalue IS 'If the property involves a decimal value, the value';
COMMENT ON COLUMN sa.table_n_properties.n_integervalue IS 'If the property involves an integer value, the value';
COMMENT ON COLUMN sa.table_n_properties.n_stringvalue IS 'If the property involves a string value, the value';
COMMENT ON COLUMN sa.table_n_properties.n_timestampvalue IS ' If the property involves a datetime value, the value';
COMMENT ON COLUMN sa.table_n_properties.n_expirationdate IS 'Last date when the information should be used';
COMMENT ON COLUMN sa.table_n_properties.n_modificationdate IS 'Date and time when the information was last modified';
COMMENT ON COLUMN sa.table_n_properties.n_effectivedate IS 'The first date on which the information should be used';
COMMENT ON COLUMN sa.table_n_properties.n_propts2n_attribute IS 'Attribute defined for the property';