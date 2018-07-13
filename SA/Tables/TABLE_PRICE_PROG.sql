CREATE TABLE sa.table_price_prog (
  objid NUMBER,
  "NAME" VARCHAR2(20 BYTE),
  s_name VARCHAR2(20 BYTE),
  description VARCHAR2(80 BYTE),
  display NUMBER,
  "TYPE" NUMBER,
  effective_date DATE,
  expire_date DATE,
  "ACTIVE" NUMBER,
  displaycc NUMBER,
  displaycs NUMBER,
  dev NUMBER,
  price_prog2currency NUMBER,
  price_prog2site NUMBER
);
ALTER TABLE sa.table_price_prog ADD SUPPLEMENTAL LOG GROUP dmtsora1449277620_0 ("ACTIVE", description, dev, display, displaycc, displaycs, effective_date, expire_date, "NAME", objid, price_prog2currency, price_prog2site, s_name, "TYPE") ALWAYS;
COMMENT ON TABLE sa.table_price_prog IS 'A Price Schedule. It contains a set or prices for products and services. Sometimes called a Price Book';
COMMENT ON COLUMN sa.table_price_prog.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_price_prog."NAME" IS 'Name for the pricing program';
COMMENT ON COLUMN sa.table_price_prog.description IS 'Description of the pricing program';
COMMENT ON COLUMN sa.table_price_prog.display IS 'If true, display pricing program for ClearLogistics in list box on parts look-up form; i.e., 0=false, 1=true. Default=0';
COMMENT ON COLUMN sa.table_price_prog."TYPE" IS 'Price type; i.e., 0=Standard Cost, 1=Proposed Std. Cost, 2=Transfer Price, 3=List Price, 4=Repair Price, 5= Exchange Price, 6=Other, default=0';
COMMENT ON COLUMN sa.table_price_prog.effective_date IS 'Date the price program becomes effective';
COMMENT ON COLUMN sa.table_price_prog.expire_date IS 'Last date the price program is effective';
COMMENT ON COLUMN sa.table_price_prog."ACTIVE" IS 'Indicates whether the price program is active; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_price_prog.displaycc IS 'If true, display pricing program in Clear Contracts; i.e., 0=false, 1=true. Default=1';
COMMENT ON COLUMN sa.table_price_prog.displaycs IS 'If true, display pricing program in ClearSales; i.e., 0=false, 1=true. Default=1';
COMMENT ON COLUMN sa.table_price_prog.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_price_prog.price_prog2currency IS 'Currency in which the price program is denominated';
COMMENT ON COLUMN sa.table_price_prog.price_prog2site IS 'Site owning the price program';