CREATE TABLE sa.x_pageplus_cos (
  objid NUMBER NOT NULL,
  bundle_code VARCHAR2(50 BYTE) NOT NULL,
  cos_value VARCHAR2(30 BYTE) NOT NULL,
  propagate_flag NUMBER,
  start_date DATE,
  end_date DATE,
  creation_date DATE DEFAULT SYSDATE,
  update_date DATE DEFAULT SYSDATE,
  plan_value NUMBER,
  service_plan_id NUMBER,
  CONSTRAINT idx_x_pageplus_cos PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_pageplus_cos IS 'Pageplus COS Configuration';
COMMENT ON COLUMN sa.x_pageplus_cos.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.x_pageplus_cos.bundle_code IS 'Pageplus service plan';
COMMENT ON COLUMN sa.x_pageplus_cos.start_date IS 'Start date';
COMMENT ON COLUMN sa.x_pageplus_cos.end_date IS 'End date';
COMMENT ON COLUMN sa.x_pageplus_cos.creation_date IS 'Insert timesatmp';
COMMENT ON COLUMN sa.x_pageplus_cos.update_date IS 'Update timestamp';