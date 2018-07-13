CREATE TABLE sa.x_multiodenom_posa_log (
  objid NUMBER NOT NULL,
  smp VARCHAR2(100 BYTE) NOT NULL,
  upc VARCHAR2(50 BYTE),
  domain VARCHAR2(50 BYTE) NOT NULL,
  original_mod_level NUMBER NOT NULL,
  updated_mod_level NUMBER NOT NULL,
  action_type VARCHAR2(1 BYTE) NOT NULL,
  update_date DATE NOT NULL,
  incident_id VARCHAR2(15 BYTE),
  PRIMARY KEY (objid)
);
COMMENT ON COLUMN sa.x_multiodenom_posa_log.original_mod_level IS 'Mod level for the BHN bar code only part number';
COMMENT ON COLUMN sa.x_multiodenom_posa_log.updated_mod_level IS 'Mod level of the part number corresponding to the UPC being sent in request';
COMMENT ON COLUMN sa.x_multiodenom_posa_log.incident_id IS 'Store incident id from TAS';