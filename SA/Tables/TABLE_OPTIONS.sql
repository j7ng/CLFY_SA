CREATE TABLE sa.table_options (
  objid NUMBER,
  option1 NUMBER,
  option2 NUMBER,
  option3 NUMBER,
  option4 NUMBER,
  option5 NUMBER,
  option6 NUMBER,
  option6a NUMBER,
  option6b NUMBER,
  option6c NUMBER,
  option6d NUMBER,
  option6e NUMBER,
  option7 NUMBER,
  option7a NUMBER,
  option7b NUMBER,
  option7c NUMBER,
  option7d NUMBER,
  option7e NUMBER,
  option8 NUMBER,
  option9 NUMBER,
  option10 NUMBER,
  option20 NUMBER,
  option21 NUMBER,
  option22 NUMBER,
  option40 NUMBER,
  option41 NUMBER,
  default1 VARCHAR2(20 BYTE),
  default2 VARCHAR2(20 BYTE),
  default3 VARCHAR2(20 BYTE),
  default4 NUMBER,
  default5 VARCHAR2(20 BYTE),
  default6 VARCHAR2(20 BYTE),
  default7 VARCHAR2(20 BYTE),
  default8 VARCHAR2(20 BYTE),
  default9 VARCHAR2(20 BYTE),
  default10 VARCHAR2(20 BYTE),
  default11 VARCHAR2(20 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_options ADD SUPPLEMENTAL LOG GROUP dmtsora387018390_0 (default1, default2, default3, default4, default5, default6, default7, objid, option1, option10, option2, option20, option21, option22, option3, option4, option40, option41, option5, option6, option6a, option6b, option6c, option6d, option6e, option7, option7a, option7b, option7c, option7d, option7e, option8, option9) ALWAYS;
ALTER TABLE sa.table_options ADD SUPPLEMENTAL LOG GROUP dmtsora387018390_1 (default10, default11, default8, default9, dev) ALWAYS;