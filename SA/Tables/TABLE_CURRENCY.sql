CREATE TABLE sa.table_currency (
  objid NUMBER,
  "NAME" VARCHAR2(20 BYTE),
  s_name VARCHAR2(20 BYTE),
  symbol VARCHAR2(5 BYTE),
  description VARCHAR2(255 BYTE),
  base_ind NUMBER,
  conv_rate NUMBER,
  iso_code VARCHAR2(3 BYTE),
  dev NUMBER,
  sub_scale NUMBER,
  pegged_to2currency NUMBER
);
ALTER TABLE sa.table_currency ADD SUPPLEMENTAL LOG GROUP dmtsora78862356_0 (base_ind, conv_rate, description, dev, iso_code, "NAME", objid, pegged_to2currency, sub_scale, symbol, s_name) ALWAYS;
COMMENT ON TABLE sa.table_currency IS 'Defines a currency in which monetary amounts may be denominated';
COMMENT ON COLUMN sa.table_currency.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_currency."NAME" IS 'Name of the currency';
COMMENT ON COLUMN sa.table_currency.symbol IS 'Symbol for the currency; e.g., $ for US dollar';
COMMENT ON COLUMN sa.table_currency.description IS 'Description of the currency';
COMMENT ON COLUMN sa.table_currency.base_ind IS 'Indicates whether the currency is the system base currency; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_currency.conv_rate IS 'The current conversion rate being used for the currency. Reserved; obsolete. See curr_conv object';
COMMENT ON COLUMN sa.table_currency.iso_code IS 'ISO 4217 currency code for the currency';
COMMENT ON COLUMN sa.table_currency.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_currency.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';
COMMENT ON COLUMN sa.table_currency.pegged_to2currency IS 'Currency which the currency is pegged to for conversion purposes';