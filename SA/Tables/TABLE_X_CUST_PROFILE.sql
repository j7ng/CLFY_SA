CREATE TABLE sa.table_x_cust_profile (
  objid NUMBER,
  x_ranking VARCHAR2(80 BYTE),
  x_roi NUMBER,
  x_dollars NUMBER,
  x_dev NUMBER,
  x_service_id VARCHAR2(30 BYTE),
  x_cust_prof2contact NUMBER,
  x_cust_prof2bus_org NUMBER
);
ALTER TABLE sa.table_x_cust_profile ADD SUPPLEMENTAL LOG GROUP dmtsora1577051299_0 (objid, x_cust_prof2bus_org, x_cust_prof2contact, x_dev, x_dollars, x_ranking, x_roi, x_service_id) ALWAYS;