CREATE TABLE sa.table_con_pym_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  displayeo NUMBER,
  cn_pm_role2contact NUMBER,
  cn_pm_role2pay_means NUMBER
);
ALTER TABLE sa.table_con_pym_role ADD SUPPLEMENTAL LOG GROUP dmtsora1252608376_0 ("ACTIVE", cn_pm_role2contact, cn_pm_role2pay_means, dev, displayeo, focus_type, objid, role_name) ALWAYS;