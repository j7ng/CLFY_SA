CREATE TABLE sa.table_bus_prt_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  bus_prt_role2bus_org NUMBER(*,0),
  bprt_role2site_part NUMBER(*,0)
);
ALTER TABLE sa.table_bus_prt_role ADD SUPPLEMENTAL LOG GROUP dmtsora1259149877_0 ("ACTIVE", bprt_role2site_part, bus_prt_role2bus_org, dev, focus_type, objid, role_name) ALWAYS;