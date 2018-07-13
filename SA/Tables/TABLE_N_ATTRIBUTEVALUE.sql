CREATE TABLE sa.table_n_attributevalue (
  objid NUMBER,
  dev NUMBER,
  n_name VARCHAR2(50 BYTE),
  n_type NUMBER,
  n_focustype NUMBER,
  n_focuslowid NUMBER,
  n_stringvalue VARCHAR2(255 BYTE),
  n_longvalue NUMBER,
  n_datevalue DATE,
  n_decimalvalue NUMBER(19,4),
  n_targettype NUMBER,
  n_targetlowid NUMBER,
  n_modificationdate DATE,
  n_targetfield VARCHAR2(30 BYTE),
  n_status NUMBER,
  n_required NUMBER,
  n_configvalue NUMBER,
  value2n_properties NUMBER
);
ALTER TABLE sa.table_n_attributevalue ADD SUPPLEMENTAL LOG GROUP dmtsora786971497_0 (dev, n_configvalue, n_datevalue, n_decimalvalue, n_focuslowid, n_focustype, n_longvalue, n_modificationdate, n_name, n_required, n_status, n_stringvalue, n_targetfield, n_targetlowid, n_targettype, n_type, objid, value2n_properties) ALWAYS;
COMMENT ON TABLE sa.table_n_attributevalue IS 'Contains an instance of a flexible attribute';
COMMENT ON COLUMN sa.table_n_attributevalue.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_n_attributevalue.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_n_attributevalue.n_name IS 'Name of the attribute - copied from N_Attribute';
COMMENT ON COLUMN sa.table_n_attributevalue.n_type IS 'See N_Type on N_Attribute';
COMMENT ON COLUMN sa.table_n_attributevalue.n_focustype IS 'The schema type_id of the instance of the attribute; e.g., case=0, subcase=24. etc';
COMMENT ON COLUMN sa.table_n_attributevalue.n_focuslowid IS 'Focus objid of owning object instance';
COMMENT ON COLUMN sa.table_n_attributevalue.n_stringvalue IS 'If a string attribute, the string value';
COMMENT ON COLUMN sa.table_n_attributevalue.n_longvalue IS 'If a long attribute, the long value';
COMMENT ON COLUMN sa.table_n_attributevalue.n_datevalue IS 'If a datetime or dateonly attribute, the datetime or dateonly value';
COMMENT ON COLUMN sa.table_n_attributevalue.n_decimalvalue IS 'If a decimal attribute, the decimal value';
COMMENT ON COLUMN sa.table_n_attributevalue.n_targettype IS 'If a relation type, the schema type_id the target object of the relation; e.g., case=0, subcase=24. etc';
COMMENT ON COLUMN sa.table_n_attributevalue.n_targetlowid IS 'If a relation type the objid of the related object';
COMMENT ON COLUMN sa.table_n_attributevalue.n_modificationdate IS 'Date and time when the information was last modified';
COMMENT ON COLUMN sa.table_n_attributevalue.n_targetfield IS 'This field holds the name of a field used to display data from the related target record';
COMMENT ON COLUMN sa.table_n_attributevalue.n_status IS 'The status of the value for Process Manager. 0 = OK, 1 = Request(s) pending for dependent field, 2 = Requests pending for activation';
COMMENT ON COLUMN sa.table_n_attributevalue.n_required IS '1 = Required field';
COMMENT ON COLUMN sa.table_n_attributevalue.n_configvalue IS 'Set to 1 if the attribute was instantiated by the Configurator';
COMMENT ON COLUMN sa.table_n_attributevalue.value2n_properties IS 'N_Properties that defines the attribute instance';