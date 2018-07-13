CREATE TABLE sa.x_score_card_inv_bin3 (
  part_serial_no VARCHAR2(30 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  dealer_parent VARCHAR2(21 BYTE),
  x_technology VARCHAR2(20 BYTE),
  x_restricted_use NUMBER,
  contact_objid NUMBER,
  site_part_objid NUMBER
);
ALTER TABLE sa.x_score_card_inv_bin3 ADD SUPPLEMENTAL LOG GROUP dmtsora16236232_0 (contact_objid, dealer_parent, "NAME", part_serial_no, site_part_objid, x_restricted_use, x_technology) ALWAYS;