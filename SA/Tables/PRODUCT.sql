CREATE TABLE sa.product (
  prodid NUMBER(6),
  descrip CHAR(30 BYTE)
);
ALTER TABLE sa.product ADD SUPPLEMENTAL LOG GROUP dmtsora1207207847_0 (descrip, prodid) ALWAYS;