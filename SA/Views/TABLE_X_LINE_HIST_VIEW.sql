CREATE OR REPLACE FORCE VIEW sa.table_x_line_hist_view (hist_objid,x_change_date,x_status,x_deactivation_flag,x_domain,x_min,x_iccid,x_change_reason,carrier_objid,x_carrier_id,x_mkt_submkt_name,carrier_group_objid,x_carrier_group_id,x_carrier_name,agent,s_agent,x_code_name,x_msid) AS
select table_x_pi_hist.objid, table_x_pi_hist.x_change_date,
 table_x_pi_hist.x_part_inst_status, table_x_pi_hist.x_deactivation_flag,
 table_x_pi_hist.x_domain, table_x_pi_hist.x_part_serial_no,
 table_x_pi_hist.x_iccid, table_x_pi_hist.x_change_reason,
 table_x_carrier.objid, table_x_carrier.x_carrier_id,
 table_x_carrier.x_mkt_submkt_name, table_x_carrier_group.objid,
 table_x_carrier_group.x_carrier_group_id, table_x_carrier_group.x_carrier_name,
 table_user.login_name, table_user.S_login_name, table_x_code_table.x_code_name,
 table_x_pi_hist.x_msid
 from table_x_pi_hist, table_x_carrier, table_x_carrier_group,
  table_user, table_x_code_table
 where table_x_carrier_group.objid = table_x_carrier.carrier2carrier_group
 AND table_x_code_table.objid = table_x_pi_hist.status_hist2x_code_table
 AND table_x_carrier.objid = table_x_pi_hist.x_pi_hist2carrier_mkt
 AND table_user.objid = table_x_pi_hist.x_pi_hist2user
 ;
COMMENT ON TABLE sa.table_x_line_hist_view IS 'Used by Line Management Forms; FORM #1400';
COMMENT ON COLUMN sa.table_x_line_hist_view.hist_objid IS 'Part instance internal record number';
COMMENT ON COLUMN sa.table_x_line_hist_view.x_change_date IS 'Part end date';
COMMENT ON COLUMN sa.table_x_line_hist_view.x_status IS 'Part status - custom';
COMMENT ON COLUMN sa.table_x_line_hist_view.x_deactivation_flag IS 'Line deactivation flag';
COMMENT ON COLUMN sa.table_x_line_hist_view.x_domain IS 'Part domain';
COMMENT ON COLUMN sa.table_x_line_hist_view.x_min IS 'NPA information';
COMMENT ON COLUMN sa.table_x_line_hist_view.x_iccid IS 'iccid';
COMMENT ON COLUMN sa.table_x_line_hist_view.x_change_reason IS 'NPA information';
COMMENT ON COLUMN sa.table_x_line_hist_view.carrier_objid IS 'Carrier internal record number';
COMMENT ON COLUMN sa.table_x_line_hist_view.x_carrier_id IS 'Carrier market ID number';
COMMENT ON COLUMN sa.table_x_line_hist_view.x_mkt_submkt_name IS 'Carrier market name';
COMMENT ON COLUMN sa.table_x_line_hist_view.carrier_group_objid IS 'Carrier group internal record number';
COMMENT ON COLUMN sa.table_x_line_hist_view.x_carrier_group_id IS 'Carrier group ID number';
COMMENT ON COLUMN sa.table_x_line_hist_view.x_carrier_name IS 'Carrier group name';
COMMENT ON COLUMN sa.table_x_line_hist_view.agent IS 'x_call_trans internal record number';
COMMENT ON COLUMN sa.table_x_line_hist_view.x_code_name IS 'Text Status name';
COMMENT ON COLUMN sa.table_x_line_hist_view.x_msid IS 'MSID';