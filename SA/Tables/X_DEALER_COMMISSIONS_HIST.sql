CREATE TABLE sa.x_dealer_commissions_hist (
  emp_objid NUMBER,
  col_name VARCHAR2(100 BYTE),
  old_val VARCHAR2(100 BYTE),
  new_val VARCHAR2(100 BYTE),
  operation VARCHAR2(20 BYTE),
  change_date DATE DEFAULT sysdate,
  osuser VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_dealer_commissions_hist IS 'TABLE TO HOLD THE HISTORY DATA OF  INDEPENDENT DEALERS';
COMMENT ON COLUMN sa.x_dealer_commissions_hist.emp_objid IS 'INTERNAL UNIQUE IDENTIFIER';
COMMENT ON COLUMN sa.x_dealer_commissions_hist.col_name IS 'NAME OF THE COLUM BEING UPDATED';
COMMENT ON COLUMN sa.x_dealer_commissions_hist.old_val IS 'CURRENT VALUE';
COMMENT ON COLUMN sa.x_dealer_commissions_hist.new_val IS 'NEW VALUE';
COMMENT ON COLUMN sa.x_dealer_commissions_hist.operation IS 'OPERATION BEING DONE';
COMMENT ON COLUMN sa.x_dealer_commissions_hist.change_date IS 'DATE IT WAS CHANGED';
COMMENT ON COLUMN sa.x_dealer_commissions_hist.osuser IS 'OSUSER OBJID FROM SYS_CONTEXT TO RECORD WHO DID THE CHANGE';