CREATE TABLE sa.x_rp_extension_link (
  objid NUMBER(38) NOT NULL,
  carrier_feature_objid NUMBER(38) NOT NULL,
  rp_extension_objid NUMBER(38) NOT NULL,
  profile_id NUMBER(38) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_rp_extension_link PRIMARY KEY (objid),
  CONSTRAINT fk1_rp_extension_link FOREIGN KEY (rp_extension_objid) REFERENCES sa.x_rp_extension (objid),
  CONSTRAINT fk2_rp_extension_link FOREIGN KEY (profile_id) REFERENCES sa.x_rp_profile (profile_id)
);
COMMENT ON COLUMN sa.x_rp_extension_link.carrier_feature_objid IS 'This links to table_x_carrier_features';
COMMENT ON COLUMN sa.x_rp_extension_link.rp_extension_objid IS 'Links to extension table based upon line and throttle status';
COMMENT ON COLUMN sa.x_rp_extension_link.profile_id IS 'Links to x_rp_profile table';