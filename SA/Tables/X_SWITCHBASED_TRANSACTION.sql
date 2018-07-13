CREATE TABLE sa.x_switchbased_transaction (
  objid NUMBER,
  x_sb_trans2x_call_trans NUMBER,
  status VARCHAR2(30 BYTE),
  x_type VARCHAR2(30 BYTE),
  x_value VARCHAR2(30 BYTE),
  exp_date DATE,
  rsid VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_switchbased_transaction ADD SUPPLEMENTAL LOG GROUP dmtsora1867819852_0 (exp_date, objid, rsid, status, x_sb_trans2x_call_trans, x_type, x_value) ALWAYS;
COMMENT ON TABLE sa.x_switchbased_transaction IS 'Switchbased Transaction Table, it complements table_x_call_trans when the service is switchbased.';
COMMENT ON COLUMN sa.x_switchbased_transaction.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_switchbased_transaction.x_sb_trans2x_call_trans IS 'Reference to table_x_call_trans';
COMMENT ON COLUMN sa.x_switchbased_transaction.status IS 'Status: CarrierPending,
Completed,
New';
COMMENT ON COLUMN sa.x_switchbased_transaction.x_type IS 'Type of transaction: A,ACR,AP,BI,CR,CRU,E,MINC';
COMMENT ON COLUMN sa.x_switchbased_transaction.x_value IS 'Switchbased Value';
COMMENT ON COLUMN sa.x_switchbased_transaction.exp_date IS 'Expiration Date';
COMMENT ON COLUMN sa.x_switchbased_transaction.rsid IS 'Client ID';