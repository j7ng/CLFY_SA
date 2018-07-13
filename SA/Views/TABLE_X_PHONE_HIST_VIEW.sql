CREATE OR REPLACE FORCE VIEW sa.table_x_phone_hist_view (hist_objid,agent,s_agent,site_objid,site_id,site_name,s_site_name,x_bin_name,x_code_name,x_change_date,x_status,x_deactivation_flag,x_domain,x_esn,x_change_reason) AS
select table_x_pi_hist.objid, table_user.login_name, table_user.S_login_name,
 table_site.objid, table_site.site_id,
 table_site.name, table_site.S_name, table_inv_bin.bin_name,
 table_x_code_table.x_code_name, table_x_pi_hist.x_change_date,
 table_x_pi_hist.x_part_inst_status, table_x_pi_hist.x_deactivation_flag,
 table_x_pi_hist.x_domain, table_x_pi_hist.x_part_serial_no,
 table_x_pi_hist.x_change_reason
 from table_x_pi_hist, table_user, table_site,
  table_inv_bin, table_x_code_table, table_inv_role,
  table_inv_locatn
 where table_x_code_table.objid = table_x_pi_hist.status_hist2x_code_table
 AND table_site.objid = table_inv_role.inv_role2site
 AND table_user.objid = table_x_pi_hist.x_pi_hist2user
 AND table_inv_locatn.objid = table_inv_role.inv_role2inv_locatn
 AND table_inv_locatn.objid = table_inv_bin.inv_bin2inv_locatn
 AND table_inv_bin.objid = table_x_pi_hist.x_pi_hist2inv_bin
 ;
COMMENT ON TABLE sa.table_x_phone_hist_view IS '1514';
COMMENT ON COLUMN sa.table_x_phone_hist_view.hist_objid IS 'Part instance internal record number';
COMMENT ON COLUMN sa.table_x_phone_hist_view.agent IS 'x_call_trans internal record number';
COMMENT ON COLUMN sa.table_x_phone_hist_view.site_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_phone_hist_view.site_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_x_phone_hist_view.site_name IS 'Name of the site';
COMMENT ON COLUMN sa.table_x_phone_hist_view.x_bin_name IS 'Name of Inventory Bin';
COMMENT ON COLUMN sa.table_x_phone_hist_view.x_code_name IS 'Text Status name';
COMMENT ON COLUMN sa.table_x_phone_hist_view.x_change_date IS 'Part end date';
COMMENT ON COLUMN sa.table_x_phone_hist_view.x_status IS 'Part status - custom';
COMMENT ON COLUMN sa.table_x_phone_hist_view.x_deactivation_flag IS 'Line deactivation flag';
COMMENT ON COLUMN sa.table_x_phone_hist_view.x_domain IS 'Part domain';
COMMENT ON COLUMN sa.table_x_phone_hist_view.x_esn IS 'NPA information';
COMMENT ON COLUMN sa.table_x_phone_hist_view.x_change_reason IS 'NPA information';