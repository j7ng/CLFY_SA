CREATE TABLE sa."Clarify" (
  objid NUMBER(10),
  "VERSION" NUMBER(5),
  "NAME" VARCHAR2(31 BYTE),
  aliasname VARCHAR2(31 BYTE),
  typeid NUMBER(10),
  miscinfo1 NUMBER(10),
  miscinfo2 NUMBER(10),
  srcobjid NUMBER(10),
  srcversion NUMBER(5),
  destobjid NUMBER(10),
  destversion NUMBER(5),
  outofdate VARCHAR2(1 BYTE),
  createdate DATE,
  lastupdate DATE,
  infoblob LONG RAW,
  miscinfo3 NUMBER(10)
);