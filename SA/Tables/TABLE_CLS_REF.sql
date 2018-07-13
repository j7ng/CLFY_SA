CREATE TABLE sa.table_cls_ref (
  objid NUMBER,
  from_type NUMBER,
  to_type NUMBER,
  "PATH" VARCHAR2(80 BYTE),
  sequence_num NUMBER,
  dev NUMBER,
  cls_ref2cls_factory NUMBER(*,0)
);
ALTER TABLE sa.table_cls_ref ADD SUPPLEMENTAL LOG GROUP dmtsora1494769056_0 (cls_ref2cls_factory, dev, from_type, objid, "PATH", sequence_num, to_type) ALWAYS;