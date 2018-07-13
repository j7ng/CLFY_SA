CREATE TABLE sa.table_nap_msg_mapping (
  objid NUMBER NOT NULL,
  nap_msg VARCHAR2(2000 BYTE),
  error_no NUMBER,
  display_msg VARCHAR2(2000 BYTE),
  CONSTRAINT pk_table_nap_msg_mapping PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.table_nap_msg_mapping IS 'Mapping between Nap Digital Error to Display message';
COMMENT ON COLUMN sa.table_nap_msg_mapping.objid IS 'Unique record identifier for Nap digital message';
COMMENT ON COLUMN sa.table_nap_msg_mapping.nap_msg IS 'Nap digital message ';
COMMENT ON COLUMN sa.table_nap_msg_mapping.error_no IS 'Error No (0/1)';
COMMENT ON COLUMN sa.table_nap_msg_mapping.display_msg IS 'Display message';