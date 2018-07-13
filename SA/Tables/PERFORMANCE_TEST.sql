CREATE TABLE sa.performance_test (
  "ID" VARCHAR2(100 BYTE),
  mesg VARCHAR2(4000 BYTE),
  flex VARCHAR2(4000 BYTE)
);
ALTER TABLE sa.performance_test ADD SUPPLEMENTAL LOG GROUP dmtsora501844330_0 (flex, "ID", mesg) ALWAYS;