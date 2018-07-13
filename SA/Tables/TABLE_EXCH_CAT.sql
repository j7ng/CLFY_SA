CREATE TABLE sa.table_exch_cat (
  objid NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  "VERSION" VARCHAR2(10 BYTE),
  s_version VARCHAR2(10 BYTE),
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE),
  "ACTIVE" NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_exch_cat ADD SUPPLEMENTAL LOG GROUP dmtsora330784770_0 ("ACTIVE", description, dev, "NAME", objid, s_description, s_name, s_version, "VERSION") ALWAYS;
COMMENT ON TABLE sa.table_exch_cat IS 'Defines transaction set roles for a category';
COMMENT ON COLUMN sa.table_exch_cat.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_exch_cat."NAME" IS 'User defined name of the category of exchange transactions';
COMMENT ON COLUMN sa.table_exch_cat."VERSION" IS 'Version of the exchange transaction category';
COMMENT ON COLUMN sa.table_exch_cat.description IS 'Describes a category which manages the set of associated exchange transactions';
COMMENT ON COLUMN sa.table_exch_cat."ACTIVE" IS ' Indicates whether or not the exchange transaction category is being used: i.e., 0= inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_exch_cat.dev IS 'Row version number for mobile distribution purposes';