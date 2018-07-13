CREATE TABLE sa.table_sce_revision (
  objid NUMBER,
  cl_sch_rev VARCHAR2(10 BYTE),
  cl_eff_date VARCHAR2(20 BYTE),
  cust_sch_rev VARCHAR2(10 BYTE),
  cust_eff_date VARCHAR2(20 BYTE),
  db_hist LONG,
  dev NUMBER
);
ALTER TABLE sa.table_sce_revision ADD SUPPLEMENTAL LOG GROUP dmtsora331472693_0 (cl_eff_date, cl_sch_rev, cust_eff_date, cust_sch_rev, dev, objid) ALWAYS;