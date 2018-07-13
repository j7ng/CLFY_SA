CREATE TABLE sa.table_x_pref_tech (
  objid NUMBER,
  x_technology VARCHAR2(30 BYTE),
  x_frequency VARCHAR2(30 BYTE),
  x_pref_tech2x_carrier NUMBER,
  x_activation NUMBER,
  x_reactivation NUMBER,
  x_reac_exception_code VARCHAR2(20 BYTE)
);
ALTER TABLE sa.table_x_pref_tech ADD SUPPLEMENTAL LOG GROUP dmtsora977026120_0 (objid, x_activation, x_frequency, x_pref_tech2x_carrier, x_reactivation, x_reac_exception_code, x_technology) ALWAYS;
COMMENT ON TABLE sa.table_x_pref_tech IS 'Carrier Prefer Technology';
COMMENT ON COLUMN sa.table_x_pref_tech.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_pref_tech.x_technology IS 'Digital Technology: GSM, ANALOG, CDMA, TDMA';
COMMENT ON COLUMN sa.table_x_pref_tech.x_frequency IS 'Frequency Description';
COMMENT ON COLUMN sa.table_x_pref_tech.x_pref_tech2x_carrier IS 'Relation to Carrier Table';
COMMENT ON COLUMN sa.table_x_pref_tech.x_activation IS 'Activation Allowed under this technology 1=Yes, 0=No';
COMMENT ON COLUMN sa.table_x_pref_tech.x_reactivation IS 'Reactivation Allowed: 1=Yes, 0=No';
COMMENT ON COLUMN sa.table_x_pref_tech.x_reac_exception_code IS 'If present, reactivation will be allowed for phones with the same code in table_part_inst.part_bin';