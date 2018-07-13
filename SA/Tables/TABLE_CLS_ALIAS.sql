CREATE TABLE sa.table_cls_alias (
  objid NUMBER,
  appl_id VARCHAR2(20 BYTE),
  s_appl_id VARCHAR2(20 BYTE),
  function_num NUMBER,
  alias_type NUMBER,
  type_id NUMBER,
  from_name VARCHAR2(64 BYTE),
  "ALIAS" VARCHAR2(64 BYTE),
  cust_alias VARCHAR2(64 BYTE),
  "ACTIVE" NUMBER,
  description VARCHAR2(255 BYTE),
  from_db_type NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_cls_alias ADD SUPPLEMENTAL LOG GROUP dmtsora813882534_0 ("ACTIVE", "ALIAS", alias_type, appl_id, cust_alias, description, dev, from_db_type, from_name, function_num, objid, s_appl_id, type_id) ALWAYS;