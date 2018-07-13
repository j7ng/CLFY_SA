CREATE TABLE sa.table_cl_rule (
  objid NUMBER,
  dev NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE),
  "RANK" NUMBER,
  expression LONG,
  confidence NUMBER,
  "ACTIVE" NUMBER,
  focus_type NUMBER,
  locale NUMBER,
  stop_eval_ind NUMBER
);
ALTER TABLE sa.table_cl_rule ADD SUPPLEMENTAL LOG GROUP dmtsora1456296496_0 ("ACTIVE", confidence, description, dev, focus_type, locale, objid, "RANK", stop_eval_ind, s_description, s_title, title) ALWAYS;