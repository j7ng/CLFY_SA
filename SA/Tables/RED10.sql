CREATE TABLE sa.red10 (
  rc_x_smp VARCHAR2(30 BYTE),
  rc_x_red_code VARCHAR2(20 BYTE),
  rc_x_red_card2inv_bin NUMBER,
  cardib_bin_name VARCHAR2(20 BYTE),
  cardst_name VARCHAR2(80 BYTE),
  cardst_objid NUMBER,
  cardst_site_id VARCHAR2(80 BYTE)
);
ALTER TABLE sa.red10 ADD SUPPLEMENTAL LOG GROUP dmtsora1210017150_0 (cardib_bin_name, cardst_name, cardst_objid, cardst_site_id, rc_x_red_card2inv_bin, rc_x_red_code, rc_x_smp) ALWAYS;