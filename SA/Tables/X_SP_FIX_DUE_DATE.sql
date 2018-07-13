CREATE TABLE sa.x_sp_fix_due_date (
  objid NUMBER,
  x_service_id VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_sp_fix_due_date ADD SUPPLEMENTAL LOG GROUP dmtsora724409052_0 (objid, x_service_id) ALWAYS;