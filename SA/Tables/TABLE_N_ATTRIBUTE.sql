CREATE TABLE sa.table_n_attribute (
  objid NUMBER,
  dev NUMBER,
  n_name VARCHAR2(50 BYTE),
  n_description VARCHAR2(255 BYTE),
  n_type NUMBER,
  n_targetobject VARCHAR2(64 BYTE),
  n_expirationdate DATE,
  n_effectivedate DATE,
  n_modificationdate DATE,
  n_targetfield VARCHAR2(30 BYTE),
  n_required NUMBER,
  n_defaultvalue VARCHAR2(255 BYTE),
  n_validrange VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_n_attribute ADD SUPPLEMENTAL LOG GROUP dmtsora446528236_0 (dev, n_defaultvalue, n_description, n_effectivedate, n_expirationdate, n_modificationdate, n_name, n_required, n_targetfield, n_targetobject, n_type, n_validrange, objid) ALWAYS;
COMMENT ON TABLE sa.table_n_attribute IS 'Defines a flexible attribute';
COMMENT ON COLUMN sa.table_n_attribute.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_n_attribute.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_n_attribute.n_name IS 'Name of the attribute';
COMMENT ON COLUMN sa.table_n_attribute.n_description IS 'Description of the attribute';
COMMENT ON COLUMN sa.table_n_attribute.n_type IS 'Data type: 0=Relation, 3=Long, 4=float, 6=Decimal, 7=Datetime, 8=String, Boolean=11, 17=Dateonly';
COMMENT ON COLUMN sa.table_n_attribute.n_targetobject IS 'For relation types, the schema type_id target object of the relation; e.g., case=0, subcase=24. etc';
COMMENT ON COLUMN sa.table_n_attribute.n_expirationdate IS 'Last date when the information should be used';
COMMENT ON COLUMN sa.table_n_attribute.n_effectivedate IS 'The first date on which the information should be used';
COMMENT ON COLUMN sa.table_n_attribute.n_modificationdate IS 'Date and time when the information was last modified';
COMMENT ON COLUMN sa.table_n_attribute.n_targetfield IS 'This field holds the name of a field used to display data from the related target record';
COMMENT ON COLUMN sa.table_n_attribute.n_required IS '1 = Required field';
COMMENT ON COLUMN sa.table_n_attribute.n_defaultvalue IS 'Default value for attribute';
COMMENT ON COLUMN sa.table_n_attribute.n_validrange IS 'Valid Range of values for numeric attribute, name of user-defined popup list for string';