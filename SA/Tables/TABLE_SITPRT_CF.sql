CREATE TABLE sa.table_sitprt_cf (
  objid NUMBER,
  def_id NUMBER,
  "VALUE" VARCHAR2(255 BYTE),
  dev NUMBER,
  prd_config2site_part NUMBER(*,0)
);
ALTER TABLE sa.table_sitprt_cf ADD SUPPLEMENTAL LOG GROUP dmtsora1414975967_0 (def_id, dev, objid, prd_config2site_part, "VALUE") ALWAYS;