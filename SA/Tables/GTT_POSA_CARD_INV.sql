CREATE GLOBAL TEMPORARY TABLE sa.gtt_posa_card_inv (
  objid NUMBER NOT NULL,
  x_part_serial_no VARCHAR2(30 BYTE),
  x_domain VARCHAR2(20 BYTE),
  x_red_code VARCHAR2(30 BYTE),
  x_posa_inv_status VARCHAR2(20 BYTE),
  x_inv_insert_date DATE,
  x_last_ship_date DATE,
  x_tf_po_number VARCHAR2(30 BYTE),
  x_tf_order_number VARCHAR2(40 BYTE),
  x_last_update_date DATE,
  x_created_by2user NUMBER,
  x_last_update_by2user NUMBER,
  x_posa_status2x_code_table NUMBER,
  x_posa_inv2part_mod NUMBER,
  x_posa_inv2inv_bin NUMBER,
  CONSTRAINT pk_gtt_posa_card_inv PRIMARY KEY (objid)
)
ON COMMIT PRESERVE ROWS;
COMMENT ON TABLE sa.gtt_posa_card_inv IS 'Global Temporary table to hold a posa card inventory dummy record';