CREATE TABLE sa.ord (
  ordid NUMBER(4) NOT NULL,
  orderdate DATE,
  commplan CHAR,
  custid NUMBER(6) NOT NULL,
  shipdate DATE,
  total NUMBER(8,2) CONSTRAINT total_zero CHECK (TOTAL >= 0)
);
ALTER TABLE sa.ord ADD SUPPLEMENTAL LOG GROUP dmtsora59236317_0 (commplan, custid, orderdate, ordid, shipdate, total) ALWAYS;