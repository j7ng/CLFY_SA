CREATE TABLE sa.stg_x_red_card (
  part_number VARCHAR2(30 BYTE),
  x_card_type VARCHAR2(20 BYTE),
  rc_row_id ROWID,
  objid NUMBER,
  x_smp VARCHAR2(30 BYTE),
  x_status VARCHAR2(255 BYTE),
  x_result VARCHAR2(20 BYTE),
  x_red_date DATE,
  x_red_card2inv_bin NUMBER,
  x_red_card2part_mod NUMBER,
  red_card2call_trans NUMBER,
  x_red_code VARCHAR2(20 BYTE)
);
ALTER TABLE sa.stg_x_red_card ADD SUPPLEMENTAL LOG GROUP dmtsora832965552_0 (objid, part_number, rc_row_id, red_card2call_trans, x_card_type, x_red_card2inv_bin, x_red_card2part_mod, x_red_code, x_red_date, x_result, x_smp, x_status) ALWAYS;