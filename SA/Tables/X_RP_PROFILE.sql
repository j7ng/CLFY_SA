CREATE TABLE sa.x_rp_profile (
  profile_id NUMBER(38) NOT NULL,
  profile_desc VARCHAR2(100 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_rp_profile PRIMARY KEY (profile_id)
);
COMMENT ON COLUMN sa.x_rp_profile.profile_id IS 'Unique ID for each profile';
COMMENT ON COLUMN sa.x_rp_profile.profile_desc IS 'Description of the profile';