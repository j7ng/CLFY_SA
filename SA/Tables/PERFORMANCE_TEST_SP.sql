CREATE TABLE sa.performance_test_sp (
  "ID" VARCHAR2(100 BYTE),
  mesg VARCHAR2(4000 BYTE),
  flex VARCHAR2(4000 BYTE)
);
ALTER TABLE sa.performance_test_sp ADD SUPPLEMENTAL LOG GROUP dmtsora1992918451_0 (flex, "ID", mesg) ALWAYS;