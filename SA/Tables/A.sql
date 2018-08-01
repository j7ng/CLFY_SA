CREATE TABLE sa."A" (
  "NAME" VARCHAR2(100 BYTE), date_mod date default sysdate, JT varchar2(30) default "JT"
);
ALTER TABLE sa."A" ADD SUPPLEMENTAL LOG GROUP dmtsora1036313094_0 ("NAME") ALWAYS;
