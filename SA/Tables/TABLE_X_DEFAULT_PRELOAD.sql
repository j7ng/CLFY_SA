CREATE TABLE sa.table_x_default_preload (
  objid NUMBER,
  x_plan_id NUMBER,
  x_home_local_click NUMBER(4,2),
  x_home_ld_click NUMBER(4,2),
  x_roam_local_click NUMBER(4,2),
  x_roam_ld_click NUMBER(4,2),
  x_grace_period NUMBER,
  x_restrict_ld NUMBER,
  x_restrict_callop NUMBER,
  x_restrict_intl NUMBER,
  x_restrict_roam NUMBER,
  x_home_intl_click NUMBER(4,2),
  x_in_grace_period NUMBER,
  x_in_sms_click NUMBER(4,2),
  x_inbound_home NUMBER(4,2),
  x_inbound_roam NUMBER(4,2),
  x_out_sms_click NUMBER(4,2),
  x_restrict_inbound NUMBER,
  x_restrict_outbound NUMBER,
  x_roam_intl_click NUMBER(4,2),
  x_browsing_rate NUMBER(19,4),
  x_mms_inbound NUMBER(19,4),
  x_mms_outbound NUMBER(19,4)
);
ALTER TABLE sa.table_x_default_preload ADD SUPPLEMENTAL LOG GROUP dmtsora1665572902_0 (objid, x_browsing_rate, x_grace_period, x_home_intl_click, x_home_ld_click, x_home_local_click, x_inbound_home, x_inbound_roam, x_in_grace_period, x_in_sms_click, x_mms_inbound, x_mms_outbound, x_out_sms_click, x_plan_id, x_restrict_callop, x_restrict_inbound, x_restrict_intl, x_restrict_ld, x_restrict_outbound, x_restrict_roam, x_roam_intl_click, x_roam_ld_click, x_roam_local_click) ALWAYS;
COMMENT ON TABLE sa.table_x_default_preload IS 'Preloaded information from manufacturer';
COMMENT ON COLUMN sa.table_x_default_preload.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_default_preload.x_plan_id IS 'Plan Identification Number';
COMMENT ON COLUMN sa.table_x_default_preload.x_home_local_click IS 'Home local click';
COMMENT ON COLUMN sa.table_x_default_preload.x_home_ld_click IS 'Home LD Click';
COMMENT ON COLUMN sa.table_x_default_preload.x_roam_local_click IS 'Clicks for  Roaming Local';
COMMENT ON COLUMN sa.table_x_default_preload.x_roam_ld_click IS 'Clicks for Roaming Long Distance';
COMMENT ON COLUMN sa.table_x_default_preload.x_grace_period IS 'Grace Period for Customer';
COMMENT ON COLUMN sa.table_x_default_preload.x_restrict_ld IS 'TBD';
COMMENT ON COLUMN sa.table_x_default_preload.x_restrict_callop IS 'TBD';
COMMENT ON COLUMN sa.table_x_default_preload.x_restrict_intl IS 'TBD';
COMMENT ON COLUMN sa.table_x_default_preload.x_restrict_roam IS 'TBD';
COMMENT ON COLUMN sa.table_x_default_preload.x_home_intl_click IS 'Clicks for Home International';
COMMENT ON COLUMN sa.table_x_default_preload.x_in_grace_period IS 'Grace Period for incoming calls for customer';
COMMENT ON COLUMN sa.table_x_default_preload.x_in_sms_click IS 'Clicks for Inbound SMS';
COMMENT ON COLUMN sa.table_x_default_preload.x_inbound_home IS 'Clicks for home incoming calls';
COMMENT ON COLUMN sa.table_x_default_preload.x_inbound_roam IS 'Clicks for roam incoming calls';
COMMENT ON COLUMN sa.table_x_default_preload.x_out_sms_click IS 'Clicks for Outbound SMS';
COMMENT ON COLUMN sa.table_x_default_preload.x_restrict_inbound IS 'TBD';
COMMENT ON COLUMN sa.table_x_default_preload.x_restrict_outbound IS 'TBD';
COMMENT ON COLUMN sa.table_x_default_preload.x_roam_intl_click IS 'Clicks for Roaming International';
COMMENT ON COLUMN sa.table_x_default_preload.x_browsing_rate IS 'clicks rate for 1 minute or browsing';
COMMENT ON COLUMN sa.table_x_default_preload.x_mms_inbound IS 'Clicks for inbound MMS messages';
COMMENT ON COLUMN sa.table_x_default_preload.x_mms_outbound IS 'Clicks for outbound MMS messages';