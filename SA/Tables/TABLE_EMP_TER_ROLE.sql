CREATE TABLE sa.table_emp_ter_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  emp_ter_role2territory NUMBER(*,0),
  emp_ter_role2employee NUMBER(*,0)
);
ALTER TABLE sa.table_emp_ter_role ADD SUPPLEMENTAL LOG GROUP dmtsora1855551787_0 ("ACTIVE", dev, emp_ter_role2employee, emp_ter_role2territory, focus_type, objid, role_name) ALWAYS;