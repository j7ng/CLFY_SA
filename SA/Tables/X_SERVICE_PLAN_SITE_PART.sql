CREATE TABLE sa.x_service_plan_site_part (
  table_site_part_id NUMBER NOT NULL,
  x_service_plan_id NUMBER NOT NULL,
  x_switch_base_rate VARCHAR2(10 BYTE),
  x_new_service_plan_id NUMBER,
  x_last_modified_date DATE
);
ALTER TABLE sa.x_service_plan_site_part ADD SUPPLEMENTAL LOG GROUP dmtsora575908742_0 (table_site_part_id, x_service_plan_id, x_switch_base_rate) ALWAYS;
COMMENT ON TABLE sa.x_service_plan_site_part IS 'Current Service Plan associated to a service instace defined in table_site_part.';
COMMENT ON COLUMN sa.x_service_plan_site_part.table_site_part_id IS 'Reference to table_site_part';
COMMENT ON COLUMN sa.x_service_plan_site_part.x_service_plan_id IS 'Reference to x_service_plan';
COMMENT ON COLUMN sa.x_service_plan_site_part.x_switch_base_rate IS 'Switchbased Rate';
COMMENT ON COLUMN sa.x_service_plan_site_part.x_new_service_plan_id IS 'Reference to new service plan, x_service_plan';
COMMENT ON COLUMN sa.x_service_plan_site_part.x_last_modified_date IS 'Timestamp last update';