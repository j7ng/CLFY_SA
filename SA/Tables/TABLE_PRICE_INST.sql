CREATE TABLE sa.table_price_inst (
  objid NUMBER,
  price NUMBER(19,4),
  effective_date DATE,
  expire_date DATE,
  price_type NUMBER,
  type_string VARCHAR2(25 BYTE),
  dev NUMBER,
  price_inst2price_prog NUMBER(*,0),
  price_inst2part_info NUMBER(*,0),
  price_inst2part_num NUMBER(*,0),
  price_inst2price_qty NUMBER(*,0),
  ref_price2price_qty NUMBER(*,0),
  create_date DATE,
  modify_stmp DATE,
  price_modifier2user NUMBER,
  price_orig2user NUMBER
);
ALTER TABLE sa.table_price_inst ADD SUPPLEMENTAL LOG GROUP dmtsora1745228151_0 (create_date, dev, effective_date, expire_date, modify_stmp, objid, price, price_inst2part_info, price_inst2part_num, price_inst2price_prog, price_inst2price_qty, price_modifier2user, price_orig2user, price_type, ref_price2price_qty, type_string) ALWAYS;
COMMENT ON TABLE sa.table_price_inst IS 'Contains instances of prices for related products and services appearing on a Price Schedule';
COMMENT ON COLUMN sa.table_price_inst.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_price_inst.price IS 'Price for a given product';
COMMENT ON COLUMN sa.table_price_inst.effective_date IS 'Date the price instance becomes effective';
COMMENT ON COLUMN sa.table_price_inst.expire_date IS 'Last date the price instance is effective';
COMMENT ON COLUMN sa.table_price_inst.price_type IS 'Type of value in the price field; i.e., 0=currency amount, 1=percent of parent from price_qty, 2=percent of child';
COMMENT ON COLUMN sa.table_price_inst.type_string IS 'Translates price_type';
COMMENT ON COLUMN sa.table_price_inst.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_price_inst.ref_price2price_qty IS 'For percentage pricing, the price quantity of the part the percentage will be applied against ';
COMMENT ON COLUMN sa.table_price_inst.create_date IS 'Date and time when object was created';
COMMENT ON COLUMN sa.table_price_inst.modify_stmp IS 'Date and time when object was last saved';
COMMENT ON COLUMN sa.table_price_inst.price_modifier2user IS 'User who last modified the price instance';
COMMENT ON COLUMN sa.table_price_inst.price_orig2user IS 'User who originated the price instance';