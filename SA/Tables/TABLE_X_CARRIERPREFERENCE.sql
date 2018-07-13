CREATE TABLE sa.table_x_carrierpreference (
  objid NUMBER,
  x_ca_id_pref NUMBER,
  x_ca_id_2 NUMBER,
  x_preferred2x_carrier NUMBER,
  x_secondary2x_carrier NUMBER
);
ALTER TABLE sa.table_x_carrierpreference ADD SUPPLEMENTAL LOG GROUP dmtsora318122826_0 (objid, x_ca_id_2, x_ca_id_pref, x_preferred2x_carrier, x_secondary2x_carrier) ALWAYS;
COMMENT ON TABLE sa.table_x_carrierpreference IS 'Holds information that represents preferred carriers';
COMMENT ON COLUMN sa.table_x_carrierpreference.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_carrierpreference.x_ca_id_pref IS 'Preferred Carrier Market Identification Number';
COMMENT ON COLUMN sa.table_x_carrierpreference.x_ca_id_2 IS 'Secondary Carrier Market Identification Number';
COMMENT ON COLUMN sa.table_x_carrierpreference.x_preferred2x_carrier IS 'Preferred Carrier relation to carrierpreference';
COMMENT ON COLUMN sa.table_x_carrierpreference.x_secondary2x_carrier IS 'Carrier relation to carrierpreference';