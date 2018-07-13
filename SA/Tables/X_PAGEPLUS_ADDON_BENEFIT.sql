CREATE TABLE sa.x_pageplus_addon_benefit (
  objid NUMBER NOT NULL,
  pcrf_esn VARCHAR2(40 BYTE) NOT NULL,
  pcrf_min VARCHAR2(40 BYTE) NOT NULL,
  plan_value NUMBER,
  status VARCHAR2(30 BYTE) NOT NULL,
  start_date DATE,
  end_date DATE,
  reason VARCHAR2(500 BYTE),
  pageplus_stg_id NUMBER,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pageplus_addon_benefit_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_pageplus_addon_benefit IS 'Store data add on cards for pageplus or any other benefits.';
COMMENT ON COLUMN sa.x_pageplus_addon_benefit.objid IS 'Unique identifier of the pageplus benefit.';
COMMENT ON COLUMN sa.x_pageplus_addon_benefit.pcrf_esn IS 'Pageplus ESN.';
COMMENT ON COLUMN sa.x_pageplus_addon_benefit.pcrf_min IS 'Pageplus MIN.';
COMMENT ON COLUMN sa.x_pageplus_addon_benefit.plan_value IS 'Addon plan value .';
COMMENT ON COLUMN sa.x_pageplus_addon_benefit.status IS 'Status of the benefit.';
COMMENT ON COLUMN sa.x_pageplus_addon_benefit.start_date IS 'Date of redemption.';
COMMENT ON COLUMN sa.x_pageplus_addon_benefit.end_date IS 'Inactive date.';
COMMENT ON COLUMN sa.x_pageplus_addon_benefit.pageplus_stg_id IS 'Pageplus stg table objid';
COMMENT ON COLUMN sa.x_pageplus_addon_benefit.insert_timestamp IS 'Date when record was created.';
COMMENT ON COLUMN sa.x_pageplus_addon_benefit.update_timestamp IS 'Date when record was last updated.';