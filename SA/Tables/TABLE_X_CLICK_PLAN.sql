CREATE TABLE sa.table_x_click_plan (
  objid NUMBER,
  x_plan_id NUMBER,
  x_click_local NUMBER(4,2),
  x_click_ld NUMBER(4,2),
  x_click_rl NUMBER(4,2),
  x_click_rld NUMBER(4,2),
  x_grace_period NUMBER,
  x_is_default VARCHAR2(20 BYTE),
  x_status NUMBER,
  click_plan2dealer NUMBER,
  click_plan2carrier NUMBER,
  x_click_home_intl NUMBER(4,2),
  x_click_in_sms NUMBER(4,2),
  x_click_out_sms NUMBER(4,2),
  x_click_roam_intl NUMBER(4,2),
  x_click_type VARCHAR2(50 BYTE),
  x_grace_period_in NUMBER,
  x_home_inbound NUMBER(4,2),
  x_roam_inbound NUMBER(4,2),
  click_plan2part_num NUMBER,
  x_browsing_rate NUMBER(19,4),
  x_bus_org VARCHAR2(20 BYTE),
  x_mms_inbound NUMBER(19,4),
  x_mms_outbound NUMBER(19,4),
  x_technology VARCHAR2(20 BYTE),
  x_click_ild NUMBER(4,2),
  CONSTRAINT unq_x_click_plan UNIQUE (click_plan2part_num) USING INDEX sa.x_click_plan_plan2part_num_idx
);
ALTER TABLE sa.table_x_click_plan ADD SUPPLEMENTAL LOG GROUP dmtsora937774043_0 (click_plan2carrier, click_plan2dealer, click_plan2part_num, objid, x_browsing_rate, x_bus_org, x_click_home_intl, x_click_in_sms, x_click_ld, x_click_local, x_click_out_sms, x_click_rl, x_click_rld, x_click_roam_intl, x_click_type, x_grace_period, x_grace_period_in, x_home_inbound, x_is_default, x_mms_inbound, x_mms_outbound, x_plan_id, x_roam_inbound, x_status, x_technology) ALWAYS;
COMMENT ON TABLE sa.table_x_click_plan IS 'Contains the click plan details that are available for a customer';
COMMENT ON COLUMN sa.table_x_click_plan.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_click_plan.x_plan_id IS 'Plan Identification Number';
COMMENT ON COLUMN sa.table_x_click_plan.x_click_local IS 'Clicks for Local Calls';
COMMENT ON COLUMN sa.table_x_click_plan.x_click_ld IS 'Clicks for Long Distance';
COMMENT ON COLUMN sa.table_x_click_plan.x_click_rl IS 'Clicks for  Roaming Local';
COMMENT ON COLUMN sa.table_x_click_plan.x_click_rld IS 'Clicks for Roaming Long Distance';
COMMENT ON COLUMN sa.table_x_click_plan.x_grace_period IS 'Grace Period for Customer';
COMMENT ON COLUMN sa.table_x_click_plan.x_is_default IS 'IS Default;i.e.,DEFAULT or NULL';
COMMENT ON COLUMN sa.table_x_click_plan.x_status IS 'Status of Click Plan; i.e., 1=active, 0=inactive';
COMMENT ON COLUMN sa.table_x_click_plan.click_plan2dealer IS ' Click Plan Relation to Dealer';
COMMENT ON COLUMN sa.table_x_click_plan.click_plan2carrier IS 'Click Plan Relation to Carrier';
COMMENT ON COLUMN sa.table_x_click_plan.x_click_home_intl IS 'Clicks for Home International';
COMMENT ON COLUMN sa.table_x_click_plan.x_click_in_sms IS 'Clicks for Inbound SMS';
COMMENT ON COLUMN sa.table_x_click_plan.x_click_out_sms IS 'Clicks for Outbound SMS';
COMMENT ON COLUMN sa.table_x_click_plan.x_click_roam_intl IS 'Clicks for Roaming International';
COMMENT ON COLUMN sa.table_x_click_plan.x_click_type IS 'R1 or R2 for part number dlls < or > 8 respectively';
COMMENT ON COLUMN sa.table_x_click_plan.x_grace_period_in IS 'Grace Period for incoming calls for customer';
COMMENT ON COLUMN sa.table_x_click_plan.x_home_inbound IS 'Clicks for home Inbound calls';
COMMENT ON COLUMN sa.table_x_click_plan.x_roam_inbound IS 'Clicks for roam inbound calls';
COMMENT ON COLUMN sa.table_x_click_plan.click_plan2part_num IS ' Relation between part number and click plan, created as MTO for consistency with other relations.';
COMMENT ON COLUMN sa.table_x_click_plan.x_browsing_rate IS 'rate for browsing';
COMMENT ON COLUMN sa.table_x_click_plan.x_bus_org IS 'Company Name: Tracfone / Net10';
COMMENT ON COLUMN sa.table_x_click_plan.x_mms_inbound IS 'Clicks for inbound MMS messages';
COMMENT ON COLUMN sa.table_x_click_plan.x_mms_outbound IS 'Clicks for outbound MMS messages';
COMMENT ON COLUMN sa.table_x_click_plan.x_technology IS 'Technology associated to the rate';