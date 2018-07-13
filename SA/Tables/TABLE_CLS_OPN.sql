CREATE TABLE sa.table_cls_opn (
  objid NUMBER,
  operation VARCHAR2(80 BYTE),
  exceptn VARCHAR2(80 BYTE),
  seq_num NUMBER,
  dev NUMBER,
  opn2cls_prop NUMBER(*,0),
  opn2cls_ref NUMBER(*,0),
  opn2cls_factory NUMBER(*,0),
  opn2cls_group NUMBER(*,0)
);
ALTER TABLE sa.table_cls_opn ADD SUPPLEMENTAL LOG GROUP dmtsora1154325795_0 (dev, exceptn, objid, operation, opn2cls_factory, opn2cls_group, opn2cls_prop, opn2cls_ref, seq_num) ALWAYS;