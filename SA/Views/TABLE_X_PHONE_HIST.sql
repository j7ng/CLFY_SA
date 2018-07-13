CREATE OR REPLACE FORCE VIEW sa.table_x_phone_hist (site_objid,site_id,site_name,s_site_name,bin_name,agent,s_agent,hist_objid,x_change_date,x_status,x_deactivation_flag,x_domain,x_esn,x_iccid,x_change_reason,x_code_name,x_technology,x_sequence) AS
SELECT table_site.objid,
    table_site.site_id,
    table_site.name,
    table_site.S_name,
    table_inv_bin.bin_name,
    table_user.login_name,
    table_user.S_login_name,
    table_x_pi_hist.objid,
    table_x_pi_hist.x_change_date,
    table_x_pi_hist.x_part_inst_status,
    table_x_pi_hist.x_deactivation_flag,
    table_x_pi_hist.x_domain,
    table_x_pi_hist.x_part_serial_no,
    table_x_pi_hist.x_iccid,
    Table_X_Pi_Hist.X_Change_Reason,
    Table_X_Code_Table.X_Code_Name,
    Table_Part_Num.X_Technology,
    Table_X_Pi_Hist.X_Sequence
  FROM table_site,
    table_inv_bin,
    table_user,
    table_x_pi_hist,
    table_x_code_table,
    table_part_num,
    table_part_inst,
    table_mod_level,
    table_inv_locatn,
    table_inv_role
  WHERE table_inv_bin.objid    = table_x_pi_hist.x_pi_hist2inv_bin
  AND table_x_code_table.objid = table_x_pi_hist.status_hist2x_code_table
  AND table_part_inst.objid    = table_x_pi_hist.x_pi_hist2part_inst
  AND table_mod_level.objid    = table_part_inst.n_part_inst2part_mod
  AND table_inv_locatn.objid   = table_inv_role.inv_role2inv_locatn
  AND table_user.objid     (+) = table_x_pi_hist.x_pi_hist2user
  AND table_inv_locatn.objid   = table_inv_bin.inv_bin2inv_locatn
  And Table_Site.Objid         = Table_Inv_Role.Inv_Role2site
  AND table_part_num.objid     = table_mod_level.part_info2part_num ;
COMMENT ON TABLE sa.table_x_phone_hist IS '1514';
COMMENT ON COLUMN sa.table_x_phone_hist.site_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_phone_hist.site_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_x_phone_hist.site_name IS 'Name of the site';
COMMENT ON COLUMN sa.table_x_phone_hist.bin_name IS 'Unique name of the inventory bin within an inventory location';
COMMENT ON COLUMN sa.table_x_phone_hist.agent IS 'x_call_trans internal record number';
COMMENT ON COLUMN sa.table_x_phone_hist.hist_objid IS 'Part instance internal record number';
COMMENT ON COLUMN sa.table_x_phone_hist.x_change_date IS 'Part end date';
COMMENT ON COLUMN sa.table_x_phone_hist.x_status IS 'Part status - custom';
COMMENT ON COLUMN sa.table_x_phone_hist.x_deactivation_flag IS 'Line deactivation flag';
COMMENT ON COLUMN sa.table_x_phone_hist.x_domain IS 'Part domain';
COMMENT ON COLUMN sa.table_x_phone_hist.x_esn IS 'NPA information';
COMMENT ON COLUMN sa.table_x_phone_hist.x_iccid IS 'iccid';
COMMENT ON COLUMN sa.table_x_phone_hist.x_change_reason IS 'NPA information';
COMMENT ON COLUMN sa.table_x_phone_hist.x_code_name IS 'Text Status name';
COMMENT ON COLUMN sa.table_x_phone_hist.x_technology IS 'technology of phone';