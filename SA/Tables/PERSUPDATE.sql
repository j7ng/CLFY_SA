CREATE TABLE sa.persupdate (
  ph_esn_num CHAR(11 BYTE) NOT NULL,
  ph_carrier_id CHAR(7 BYTE),
  ph_pers CHAR(5 BYTE),
  ca_pers CHAR(5 BYTE) NOT NULL
);
ALTER TABLE sa.persupdate ADD SUPPLEMENTAL LOG GROUP dmtsora590365932_0 (ca_pers, ph_carrier_id, ph_esn_num, ph_pers) ALWAYS;