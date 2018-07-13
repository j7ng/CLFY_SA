CREATE TABLE sa.x_rp_ancillary_code_config (
  extension_objid NUMBER,
  profile_id NUMBER,
  feature_name VARCHAR2(200 BYTE),
  "FEATURE_VALUE" VARCHAR2(200 BYTE),
  feature_requirement VARCHAR2(500 BYTE),
  toggle_flag VARCHAR2(1 BYTE) CONSTRAINT ck1_rp_extension_code_config CHECK (toggle_flag IN ('Y','N')),
  notes VARCHAR2(500 BYTE),
  restrict_sui_flag VARCHAR2(1 BYTE) CONSTRAINT ck2_rp_extension_code_config CHECK (restrict_sui_flag IN ('Y','N')),
  display_sui_flag VARCHAR2(1 BYTE) CONSTRAINT ck3_rp_extension_code_config CHECK (display_sui_flag IN ('Y','N')),
  CONSTRAINT fk1_rp_ancillary_code_config FOREIGN KEY (feature_requirement) REFERENCES sa.x_rp_feature_requirement (feature_requirement),
  CONSTRAINT fk2_rp_ancillary_code_config FOREIGN KEY (profile_id) REFERENCES sa.x_rp_profile (profile_id)
);