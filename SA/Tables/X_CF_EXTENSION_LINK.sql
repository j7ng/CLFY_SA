CREATE TABLE sa.x_cf_extension_link (
  objid NUMBER(38) NOT NULL,
  carrier_feature_objid NUMBER(38) NOT NULL,
  cf_extension_objid NUMBER(38) NOT NULL,
  profile_id NUMBER(38) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_cf_extension_link PRIMARY KEY (objid),
  CONSTRAINT uk1_x_cf_extension_link UNIQUE (carrier_feature_objid,cf_extension_objid) USING INDEX sa.idx1_cf_extension_link,
  CONSTRAINT fk1_cf_extension_link FOREIGN KEY (cf_extension_objid) REFERENCES sa.x_cf_extension (objid),
  CONSTRAINT fk2_cf_extension_link FOREIGN KEY (profile_id) REFERENCES sa.x_cf_profile (profile_id)
);
COMMENT ON COLUMN sa.x_cf_extension_link.carrier_feature_objid IS 'This links to table_x_carrier_features';
COMMENT ON COLUMN sa.x_cf_extension_link.cf_extension_objid IS 'Links to extension table based upon line and throttle status';
COMMENT ON COLUMN sa.x_cf_extension_link.profile_id IS 'Links to x_cf_profile table';