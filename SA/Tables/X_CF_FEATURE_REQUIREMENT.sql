CREATE TABLE sa.x_cf_feature_requirement (
  feature_requirement VARCHAR2(3 BYTE) NOT NULL,
  description VARCHAR2(20 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_cf_feature_requirement PRIMARY KEY (feature_requirement)
);
COMMENT ON COLUMN sa.x_cf_feature_requirement.feature_requirement IS 'Feature requirement (Optional, required)';