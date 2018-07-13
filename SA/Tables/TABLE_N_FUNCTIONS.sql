CREATE TABLE sa.table_n_functions (
  objid NUMBER,
  dev NUMBER,
  n_itemid NUMBER,
  n_itemtypeid NUMBER,
  n_functionname VARCHAR2(80 BYTE),
  n_sourcecode LONG,
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE
);
ALTER TABLE sa.table_n_functions ADD SUPPLEMENTAL LOG GROUP dmtsora1915751167_0 (dev, n_effectivedate, n_expirationdate, n_functionname, n_itemid, n_itemtypeid, n_modificationdate, objid) ALWAYS;
COMMENT ON TABLE sa.table_n_functions IS 'Contains all the functions that modify behavior of the ClearConfigurator application. For example, the proposal script or job upload script would reside in this table. Also contains the product and option rules';
COMMENT ON COLUMN sa.table_n_functions.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_n_functions.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_n_functions.n_itemid IS 'Used by the function_for Exclusive Relations set. Contains the objid of the related object. See N_ItemTypeId field for the type identification of the related object';
COMMENT ON COLUMN sa.table_n_functions.n_itemtypeid IS 'Used by the function_for Exclusive Relations set. Contains the object type_id of the related object See N_ItemId for the related object type';
COMMENT ON COLUMN sa.table_n_functions.n_functionname IS 'The name of the function';
COMMENT ON COLUMN sa.table_n_functions.n_sourcecode IS 'SalesBasic source code for the function';
COMMENT ON COLUMN sa.table_n_functions.n_expirationdate IS 'Last date when the information should be used';
COMMENT ON COLUMN sa.table_n_functions.n_modificationdate IS 'Date and time when the information was last modified';
COMMENT ON COLUMN sa.table_n_functions.n_effectivedate IS 'The first date on which the information should be used';