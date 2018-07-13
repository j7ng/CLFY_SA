CREATE TABLE sa.x_fixed_minchange (
  "MIN" VARCHAR2(30 BYTE),
  esn VARCHAR2(40 BYTE),
  actionitem_objid NUMBER,
  fix_date DATE
);
ALTER TABLE sa.x_fixed_minchange ADD SUPPLEMENTAL LOG GROUP dmtsora232179962_0 (actionitem_objid, esn, fix_date, "MIN") ALWAYS;