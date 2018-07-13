CREATE TABLE sa.table_menu_bar (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  menu_bar NUMBER,
  description VARCHAR2(255 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  menu_time_stamp DATE,
  ver_clarify VARCHAR2(40 BYTE),
  ver_customer VARCHAR2(40 BYTE),
  dev NUMBER,
  child2menu_bar NUMBER,
  "TYPE" NUMBER
);
ALTER TABLE sa.table_menu_bar ADD SUPPLEMENTAL LOG GROUP dmtsora941113193_0 (child2menu_bar, description, dev, menu_bar, menu_time_stamp, "NAME", objid, title, "TYPE", ver_clarify, ver_customer) ALWAYS;