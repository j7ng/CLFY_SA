CREATE TABLE sa.table_pro_hgl_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  pro_hgl2hgbst_lst NUMBER(*,0),
  pro_hgl2exch_protocol NUMBER(*,0)
);
ALTER TABLE sa.table_pro_hgl_role ADD SUPPLEMENTAL LOG GROUP dmtsora563844013_0 ("ACTIVE", dev, focus_type, objid, pro_hgl2exch_protocol, pro_hgl2hgbst_lst, role_name) ALWAYS;