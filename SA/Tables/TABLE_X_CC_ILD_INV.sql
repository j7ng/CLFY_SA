CREATE TABLE sa.table_x_cc_ild_inv (
  objid NUMBER,
  dev NUMBER,
  x_reserved_stmp DATE,
  x_red_code VARCHAR2(30 BYTE),
  x_part_serial_no VARCHAR2(30 BYTE),
  x_creation_date DATE,
  x_reserved_flag NUMBER,
  x_reserved_id NUMBER,
  x_domain VARCHAR2(30 BYTE),
  x_last_update DATE,
  x_macaw_id NUMBER,
  x_po_num VARCHAR2(30 BYTE),
  created_by2user NUMBER,
  cc_ild_inv2mod_level NUMBER,
  cc_ild_inv2inv_bin NUMBER,
  last_updated2user NUMBER
);
ALTER TABLE sa.table_x_cc_ild_inv ADD SUPPLEMENTAL LOG GROUP dmtsora2042336518_0 (cc_ild_inv2inv_bin, cc_ild_inv2mod_level, created_by2user, dev, last_updated2user, objid, x_creation_date, x_domain, x_last_update, x_macaw_id, x_part_serial_no, x_po_num, x_red_code, x_reserved_flag, x_reserved_id, x_reserved_stmp) ALWAYS;