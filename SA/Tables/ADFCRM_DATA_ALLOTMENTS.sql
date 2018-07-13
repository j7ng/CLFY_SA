CREATE TABLE sa.adfcrm_data_allotments (
  objid NUMBER NOT NULL,
  x_offer_id VARCHAR2(10 BYTE),
  addon_part_number VARCHAR2(100 BYTE),
  x_provision_data_gb VARCHAR2(40 BYTE),
  action_type VARCHAR2(30 BYTE),
  allotment2bus_org NUMBER,
  service_plan_max VARCHAR2(40 BYTE),
  description VARCHAR2(1000 BYTE),
  CONSTRAINT adfcrm_data_allotments_pk PRIMARY KEY (objid) USING INDEX sa.adfcrm_data_allotments_idx
);
COMMENT ON TABLE sa.adfcrm_data_allotments IS 'This table is used to store Data Allotments for Compensation and Replacement.';
COMMENT ON COLUMN sa.adfcrm_data_allotments.objid IS 'OBJID of DATA ALLOTMENTS';
COMMENT ON COLUMN sa.adfcrm_data_allotments.x_offer_id IS 'Offer Id for Data Provisioning';
COMMENT ON COLUMN sa.adfcrm_data_allotments.addon_part_number IS 'Add on Part Number Details';
COMMENT ON COLUMN sa.adfcrm_data_allotments.x_provision_data_gb IS 'Provisioning Data in GB';
COMMENT ON COLUMN sa.adfcrm_data_allotments.action_type IS 'For Compensation - Action Type will be "COMP" or For Replacment - Action Type will be "REPL" ';
COMMENT ON COLUMN sa.adfcrm_data_allotments.allotment2bus_org IS 'Brand for Data Allotment';
COMMENT ON COLUMN sa.adfcrm_data_allotments.service_plan_max IS 'To present different data options up to the maximum of what the plan had.';
COMMENT ON COLUMN sa.adfcrm_data_allotments.description IS 'Description of the row';