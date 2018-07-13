CREATE TABLE sa.table_mail_list (
  objid NUMBER,
  "NAME" VARCHAR2(50 BYTE),
  description VARCHAR2(255 BYTE),
  comments VARCHAR2(255 BYTE),
  start_date DATE,
  dev NUMBER
);
ALTER TABLE sa.table_mail_list ADD SUPPLEMENTAL LOG GROUP dmtsora1768365407_0 (comments, description, dev, "NAME", objid, start_date) ALWAYS;