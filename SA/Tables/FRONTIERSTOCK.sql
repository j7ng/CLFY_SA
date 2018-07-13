CREATE TABLE sa.frontierstock (
  avnumb VARCHAR2(15 BYTE)
);
ALTER TABLE sa.frontierstock ADD SUPPLEMENTAL LOG GROUP dmtsora193688296_0 (avnumb) ALWAYS;