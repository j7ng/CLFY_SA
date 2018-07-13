CREATE TABLE sa.x_pymt_processor (
  objid NUMBER NOT NULL,
  x_name VARCHAR2(50 BYTE) NOT NULL,
  x_description VARCHAR2(255 BYTE),
  x_type VARCHAR2(50 BYTE) NOT NULL,
  x_active VARCHAR2(10 BYTE) NOT NULL,
  x_create_date DATE NOT NULL,
  x_update_date DATE NOT NULL,
  CONSTRAINT pymt_proc_objid_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_pymt_processor IS 'STORES INFORMATION ABOUT PAYMENT PROCESSOR';
COMMENT ON COLUMN sa.x_pymt_processor.objid IS 'INTERNAL RECORD ID';
COMMENT ON COLUMN sa.x_pymt_processor.x_name IS 'Gateway name';
COMMENT ON COLUMN sa.x_pymt_processor.x_description IS 'Gateway description';
COMMENT ON COLUMN sa.x_pymt_processor.x_type IS 'Gateway type i.e. Credit Card or Rewards etc';
COMMENT ON COLUMN sa.x_pymt_processor.x_active IS 'Y if gateway is active N otherwise';
COMMENT ON COLUMN sa.x_pymt_processor.x_create_date IS 'Record create date';
COMMENT ON COLUMN sa.x_pymt_processor.x_update_date IS 'Record update date';