CREATE TABLE sa.table_web_filter (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  obj_type NUMBER,
  view_type NUMBER,
  is_default NUMBER,
  dev NUMBER,
  update_stamp DATE,
  web_filter2web_user NUMBER
);
ALTER TABLE sa.table_web_filter ADD SUPPLEMENTAL LOG GROUP dmtsora884089635_0 (dev, is_default, objid, obj_type, title, update_stamp, view_type, web_filter2web_user) ALWAYS;