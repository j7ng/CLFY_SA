CREATE TABLE sa.x_cf_extension_config (
  objid NUMBER(38) NOT NULL,
  profile_id NUMBER(38) NOT NULL,
  feature_name VARCHAR2(100 BYTE) NOT NULL,
  "FEATURE_VALUE" VARCHAR2(100 BYTE) NOT NULL,
  feature_requirement VARCHAR2(3 BYTE) NOT NULL,
  toggle_flag VARCHAR2(1 BYTE) DEFAULT 'Y' NOT NULL CONSTRAINT ck1_cf_extension_config CHECK (toggle_flag IN ('Y','N')),
  notes CLOB,
  restrict_sui_flag VARCHAR2(1 BYTE) DEFAULT 'Y' NOT NULL CONSTRAINT ck2_cf_extension_config CHECK (restrict_sui_flag IN ('Y','N')),
  display_sui_flag VARCHAR2(1 BYTE) DEFAULT 'Y' NOT NULL CONSTRAINT ck3_cf_extension_config CHECK (display_sui_flag IN ('Y','N')),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_cf_extension_config PRIMARY KEY (objid),
  CONSTRAINT fk1_cf_extension_config FOREIGN KEY (feature_requirement) REFERENCES sa.x_cf_feature_requirement (feature_requirement),
  CONSTRAINT fk2_cf_extension_config FOREIGN KEY (profile_id) REFERENCES sa.x_cf_profile (profile_id)
);
COMMENT ON COLUMN sa.x_cf_extension_config.profile_id IS 'Profile ID dervied from x_cf_profile';
COMMENT ON COLUMN sa.x_cf_extension_config.feature_name IS 'Name of the feature';
COMMENT ON COLUMN sa.x_cf_extension_config."FEATURE_VALUE" IS 'Feature Code. This value will be passed to Intergate';
COMMENT ON COLUMN sa.x_cf_extension_config.feature_requirement IS 'Whether the feature is required, optional or to be removed';
COMMENT ON COLUMN sa.x_cf_extension_config.toggle_flag IS 'Switch that allows turning the SOC to ON/OFF';
COMMENT ON COLUMN sa.x_cf_extension_config.restrict_sui_flag IS 'Whether SUI can update this feature';
COMMENT ON COLUMN sa.x_cf_extension_config.display_sui_flag IS 'Whether to display this feature on TAS';