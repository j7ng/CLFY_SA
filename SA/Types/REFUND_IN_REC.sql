CREATE OR REPLACE TYPE sa.REFUND_IN_REC
IS
 OBJECT
 ( ESN           VARCHAR2(50),
   SMP           VARCHAR2(30),
   LINE_NUMBER   NUMBER,
   PART_NUMBER   VARCHAR2(50),
   UNIT_PRICE    NUMBER,
   QUANTITY      NUMBER);
/