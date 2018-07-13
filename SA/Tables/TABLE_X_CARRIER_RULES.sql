CREATE TABLE sa.table_x_carrier_rules (
  objid NUMBER,
  x_cooling_period NUMBER,
  x_esn_change_flag NUMBER,
  x_line_expire_days NUMBER,
  x_line_return_days NUMBER,
  x_cooling_after_insert NUMBER,
  x_npa_nxx_flag NUMBER,
  x_used_line_expire_days NUMBER,
  x_gsm_grace_period NUMBER,
  x_technology VARCHAR2(10 BYTE),
  x_reserve_on_suspend NUMBER,
  x_reserve_period NUMBER,
  x_deac_after_grace NUMBER,
  x_cancel_suspend_days NUMBER,
  x_cancel_suspend NUMBER,
  x_block_create_act_item NUMBER(22),
  x_allow_2g_act VARCHAR2(30 BYTE),
  x_allow_2g_react VARCHAR2(30 BYTE),
  allow_non_hd_acts NUMBER(22),
  allow_non_hd_reacts NUMBER(22)
);
ALTER TABLE sa.table_x_carrier_rules ADD SUPPLEMENTAL LOG GROUP dmtsora1198959447_0 (objid, x_cancel_suspend, x_cancel_suspend_days, x_cooling_after_insert, x_cooling_period, x_deac_after_grace, x_esn_change_flag, x_gsm_grace_period, x_line_expire_days, x_line_return_days, x_npa_nxx_flag, x_reserve_on_suspend, x_reserve_period, x_technology, x_used_line_expire_days) ALWAYS;
COMMENT ON TABLE sa.table_x_carrier_rules IS 'Contains rules for all the carriers';
COMMENT ON COLUMN sa.table_x_carrier_rules.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_cooling_period IS 'Days for which lines are kept unallocated after deactivation';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_esn_change_flag IS 'Flag for ESN Change: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_line_expire_days IS 'Days after which unused lines expire';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_line_return_days IS 'Days after which lines that are disconnected can be returned';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_cooling_after_insert IS 'Elapsed time in Seconds for insert cooling';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_npa_nxx_flag IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_used_line_expire_days IS 'Days after which used lines expire';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_gsm_grace_period IS 'Days after which gsm used lines will expire';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_technology IS 'Technology assigned to the rule';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_reserve_on_suspend IS '0=No, 1=Yes Keep the line reserved until x_reserve_period expires';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_reserve_period IS 'number os days to keep line reserved after suspend';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_deac_after_grace IS 'Send Deac Action Item after reserve period expires, to be used with x_reserve_on_suspend 0=No, 1=Yes';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_cancel_suspend_days IS 'number os days to keep line suspend before to cacel';
COMMENT ON COLUMN sa.table_x_carrier_rules.x_cancel_suspend IS 'Send Deac Action Item when begin grace periodo, to be used with x_cancel_suspend_days,0=No,1=Yes';