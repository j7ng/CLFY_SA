CREATE TABLE sa.table_bus_prf_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  bu_pf_role2bus_org NUMBER,
  bu_pf_role2price_factor NUMBER
);
ALTER TABLE sa.table_bus_prf_role ADD SUPPLEMENTAL LOG GROUP dmtsora2072267987_0 ("ACTIVE", bu_pf_role2bus_org, bu_pf_role2price_factor, dev, focus_type, objid, role_name) ALWAYS;