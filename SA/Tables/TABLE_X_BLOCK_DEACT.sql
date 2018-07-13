CREATE TABLE sa.table_x_block_deact (
  objid NUMBER,
  dev NUMBER,
  x_parent_id VARCHAR2(30 BYTE),
  x_code_number VARCHAR2(20 BYTE),
  x_code_name VARCHAR2(20 BYTE),
  x_block_active NUMBER,
  x_created_by VARCHAR2(50 BYTE),
  x_created_date DATE,
  x_removed_by VARCHAR2(50 BYTE),
  x_removed_date DATE
);
ALTER TABLE sa.table_x_block_deact ADD SUPPLEMENTAL LOG GROUP dmtsora52558018_0 (dev, objid, x_block_active, x_code_name, x_code_number, x_created_by, x_created_date, x_parent_id, x_removed_by, x_removed_date) ALWAYS;