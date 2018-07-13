CREATE TABLE sa.red9 (
  rc_x_smp VARCHAR2(30 BYTE),
  rc_x_red_code VARCHAR2(20 BYTE),
  rc_x_red_card2inv_bin NUMBER,
  cardib_bin_name VARCHAR2(20 BYTE)
);
ALTER TABLE sa.red9 ADD SUPPLEMENTAL LOG GROUP dmtsora1564103560_0 (cardib_bin_name, rc_x_red_card2inv_bin, rc_x_red_code, rc_x_smp) ALWAYS;