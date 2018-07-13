CREATE TABLE sa.tf_soaprocess_activity_details (
  activity_details_id NUMBER NOT NULL,
  activity_info_id NUMBER,
  paramname VARCHAR2(500 BYTE) NOT NULL,
  paramvalue VARCHAR2(1000 BYTE) NOT NULL,
  row_insert_date DATE DEFAULT SYSDATE,
  row_upd_date DATE DEFAULT SYSDATE,
  CONSTRAINT pk_soaprocess_details_id PRIMARY KEY (activity_details_id)
);
COMMENT ON TABLE sa.tf_soaprocess_activity_details IS 'SOA Activity Details';
COMMENT ON COLUMN sa.tf_soaprocess_activity_details.activity_details_id IS 'Sequential ID Number';
COMMENT ON COLUMN sa.tf_soaprocess_activity_details.activity_info_id IS 'Reference to ACTIVITY_INFO_ID of table TF_SOAPROCESS_ACTIVITY_INFO';
COMMENT ON COLUMN sa.tf_soaprocess_activity_details.paramname IS 'Name of Parameters';
COMMENT ON COLUMN sa.tf_soaprocess_activity_details.paramvalue IS 'Value of Parameters';
COMMENT ON COLUMN sa.tf_soaprocess_activity_details.row_insert_date IS 'inserted date';
COMMENT ON COLUMN sa.tf_soaprocess_activity_details.row_upd_date IS 'update date';