CREATE TABLE sa.table_cls_parm (
  objid NUMBER,
  seq_num NUMBER,
  parm_name VARCHAR2(80 BYTE),
  parm_value VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  dev NUMBER,
  parm2cls_opn NUMBER(*,0)
);
ALTER TABLE sa.table_cls_parm ADD SUPPLEMENTAL LOG GROUP dmtsora1599355289_0 (description, dev, objid, parm2cls_opn, parm_name, parm_value, seq_num) ALWAYS;