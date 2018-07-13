CREATE TABLE sa.x_broken_card_3 (
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
ALTER TABLE sa.x_broken_card_3 ADD SUPPLEMENTAL LOG GROUP dmtsora887095469_0 (objid, red_card2call_trans, red_smp2inv_smp, red_smp2x_pi_hist, x_access_days, x_created_by2user, x_inv_insert_date, x_last_ship_date, x_order_number, x_po_num, x_red_card2inv_bin, x_red_card2part_mod, x_red_code, x_red_date, x_red_units, x_result, x_smp, x_status) ALWAYS;