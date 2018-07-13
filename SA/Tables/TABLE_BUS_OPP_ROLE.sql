CREATE TABLE sa.table_bus_opp_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  role_type NUMBER,
  comments VARCHAR2(255 BYTE),
  focus_type NUMBER,
  products VARCHAR2(80 BYTE),
  close_date DATE,
  amount NUMBER(19,4),
  drop_date DATE,
  drop_reason VARCHAR2(255 BYTE),
  dev NUMBER,
  opp_role2opportunity NUMBER(*,0),
  bus_role2bus_org NUMBER(*,0)
);
ALTER TABLE sa.table_bus_opp_role ADD SUPPLEMENTAL LOG GROUP dmtsora912589533_0 ("ACTIVE", amount, bus_role2bus_org, close_date, comments, dev, drop_date, drop_reason, focus_type, objid, opp_role2opportunity, products, role_name, role_type) ALWAYS;