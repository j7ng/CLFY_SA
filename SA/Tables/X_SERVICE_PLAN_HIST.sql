CREATE TABLE sa.x_service_plan_hist (
  plan_hist2site_part NUMBER,
  x_start_date DATE,
  plan_hist2service_plan NUMBER,
  x_insert_date DATE DEFAULT SYSDATE NOT NULL,
  x_last_modified_date DATE DEFAULT SYSDATE NOT NULL
);
COMMENT ON TABLE sa.x_service_plan_hist IS 'Service Plan History Tables, applicable to all service that use the concept of Service Plan';
COMMENT ON COLUMN sa.x_service_plan_hist.plan_hist2site_part IS 'Reference to table_site_part';
COMMENT ON COLUMN sa.x_service_plan_hist.x_start_date IS 'Service Plan Start Date';
COMMENT ON COLUMN sa.x_service_plan_hist.plan_hist2service_plan IS 'Reference to x_service_plan table';
COMMENT ON COLUMN sa.x_service_plan_hist.x_insert_date IS 'Date record was inserted into table';
COMMENT ON COLUMN sa.x_service_plan_hist.x_last_modified_date IS 'Last Date record was modified';