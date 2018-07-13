CREATE TABLE sa.table_x_cust_membership (
  objid NUMBER,
  x_dev NUMBER,
  x_service_id VARCHAR2(30 BYTE),
  x_cust_memb2contact NUMBER,
  x_cust_memb2bus_org NUMBER,
  x_cust_memb2code_table NUMBER,
  x_cust_memb2site NUMBER
);
ALTER TABLE sa.table_x_cust_membership ADD SUPPLEMENTAL LOG GROUP dmtsora942776118_0 (objid, x_cust_memb2bus_org, x_cust_memb2code_table, x_cust_memb2contact, x_cust_memb2site, x_dev, x_service_id) ALWAYS;