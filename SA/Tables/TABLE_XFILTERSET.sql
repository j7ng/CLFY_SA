CREATE TABLE sa.table_xfilterset (
  objid NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  "TYPE" VARCHAR2(30 BYTE),
  is_default NUMBER,
  update_stamp DATE,
  dev NUMBER,
  is_shared NUMBER,
  addnl_info VARCHAR2(255 BYTE),
  xfilterset2user NUMBER,
  xfiltersets2xfilter NUMBER
);
ALTER TABLE sa.table_xfilterset ADD SUPPLEMENTAL LOG GROUP dmtsora1012187884_0 (addnl_info, dev, is_default, is_shared, "NAME", objid, "TYPE", update_stamp, xfilterset2user, xfiltersets2xfilter) ALWAYS;