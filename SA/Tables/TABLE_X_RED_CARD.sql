CREATE TABLE sa.table_x_red_card (
  objid NUMBER,
  red_card2call_trans NUMBER,
  red_smp2inv_smp NUMBER,
  red_smp2x_pi_hist NUMBER,
  x_access_days NUMBER,
  x_red_code VARCHAR2(20 BYTE),
  x_red_date DATE,
  x_red_units NUMBER,
  x_smp VARCHAR2(30 BYTE),
  x_status VARCHAR2(255 BYTE),
  x_result VARCHAR2(20 BYTE),
  x_created_by2user NUMBER,
  x_inv_insert_date DATE,
  x_last_ship_date DATE,
  x_order_number VARCHAR2(40 BYTE),
  x_po_num VARCHAR2(30 BYTE),
  x_red_card2inv_bin NUMBER,
  x_red_card2part_mod NUMBER
);
ALTER TABLE sa.table_x_red_card ADD SUPPLEMENTAL LOG GROUP dmtsora1522591116_0 (objid, red_card2call_trans, red_smp2inv_smp, red_smp2x_pi_hist, x_access_days, x_created_by2user, x_inv_insert_date, x_last_ship_date, x_order_number, x_po_num, x_red_card2inv_bin, x_red_card2part_mod, x_red_code, x_red_date, x_red_units, x_result, x_smp, x_status) ALWAYS;
ALTER TABLE sa.table_x_red_card ADD SUPPLEMENTAL LOG GROUP dmtsora2073807733_0 (objid, red_card2call_trans, red_smp2inv_smp, red_smp2x_pi_hist, x_access_days, x_created_by2user, x_inv_insert_date, x_last_ship_date, x_order_number, x_po_num, x_red_card2inv_bin, x_red_card2part_mod, x_red_code, x_red_date, x_red_units, x_result, x_smp, x_status) ALWAYS;
COMMENT ON TABLE sa.table_x_red_card IS 'Contains information about redeemed cards';
COMMENT ON COLUMN sa.table_x_red_card.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_red_card.red_card2call_trans IS 'Call Transaction relation to Redemption Card';
COMMENT ON COLUMN sa.table_x_red_card.red_smp2inv_smp IS 'Inventory SMP Relation to Redemption Card';
COMMENT ON COLUMN sa.table_x_red_card.red_smp2x_pi_hist IS 'History: Redemption Card SMP relation to Inventory';
COMMENT ON COLUMN sa.table_x_red_card.x_access_days IS 'Access Days on the Card';
COMMENT ON COLUMN sa.table_x_red_card.x_red_code IS 'Redemption Code';
COMMENT ON COLUMN sa.table_x_red_card.x_red_date IS 'Date on which the card was redeemed';
COMMENT ON COLUMN sa.table_x_red_card.x_red_units IS 'Number of Units on the redeemed card';
COMMENT ON COLUMN sa.table_x_red_card.x_smp IS 'Card Inventory Number';
COMMENT ON COLUMN sa.table_x_red_card.x_status IS 'Status of the redemption card';
COMMENT ON COLUMN sa.table_x_red_card.x_result IS 'Result of redemption attempt during a call transaction';
COMMENT ON COLUMN sa.table_x_red_card.x_created_by2user IS 'Creator of the part instance';
COMMENT ON COLUMN sa.table_x_red_card.x_inv_insert_date IS 'The Date on which the line was received from carrier';
COMMENT ON COLUMN sa.table_x_red_card.x_last_ship_date IS 'The Date on which the line was received from carrier';
COMMENT ON COLUMN sa.table_x_red_card.x_order_number IS 'Order Number';
COMMENT ON COLUMN sa.table_x_red_card.x_po_num IS 'PO Number';
COMMENT ON COLUMN sa.table_x_red_card.x_red_card2inv_bin IS 'Inventory bin in which the instance is currently located';
COMMENT ON COLUMN sa.table_x_red_card.x_red_card2part_mod IS 'The part version of the inventory part';