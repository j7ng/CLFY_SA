CREATE TABLE sa.table_retrn_info (
  objid NUMBER,
  return_sn VARCHAR2(30 BYTE),
  return_qty NUMBER,
  return_mod VARCHAR2(8 BYTE),
  exp_rcpt_date DATE,
  cust_rqst_date DATE,
  act_rqst_date DATE,
  sch_ship_date DATE,
  orig_so VARCHAR2(20 BYTE),
  orig_po VARCHAR2(30 BYTE),
  new_qty NUMBER,
  new_mod VARCHAR2(8 BYTE),
  cred_amt NUMBER,
  dev NUMBER,
  new_part_mod2part_info NUMBER(*,0)
);
ALTER TABLE sa.table_retrn_info ADD SUPPLEMENTAL LOG GROUP dmtsora1965067392_0 (act_rqst_date, cred_amt, cust_rqst_date, dev, exp_rcpt_date, new_mod, new_part_mod2part_info, new_qty, objid, orig_po, orig_so, return_mod, return_qty, return_sn, sch_ship_date) ALWAYS;
COMMENT ON TABLE sa.table_retrn_info IS 'Return information for a part request. Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.objid IS 'Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.return_sn IS 'Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.return_qty IS 'Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.return_mod IS 'Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.exp_rcpt_date IS 'Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.cust_rqst_date IS 'Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.act_rqst_date IS 'Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.sch_ship_date IS 'Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.orig_so IS 'Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.orig_po IS 'Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.new_qty IS 'Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.new_mod IS 'Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.cred_amt IS 'Reserved; future';
COMMENT ON COLUMN sa.table_retrn_info.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_retrn_info.new_part_mod2part_info IS 'Reserved; future';