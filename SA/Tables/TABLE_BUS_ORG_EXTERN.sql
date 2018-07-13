CREATE TABLE sa.table_bus_org_extern (
  objid NUMBER,
  dev NUMBER,
  last_update DATE,
  ext_src VARCHAR2(30 BYTE),
  ext_ref VARCHAR2(64 BYTE),
  bus_org_extern2bus_org NUMBER
);
ALTER TABLE sa.table_bus_org_extern ADD SUPPLEMENTAL LOG GROUP dmtsora918706616_0 (bus_org_extern2bus_org, dev, ext_ref, ext_src, last_update, objid) ALWAYS;