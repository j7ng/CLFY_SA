CREATE OR REPLACE FORCE VIEW sa.table_prtuse2_view (objid,rem_pmlobjid,rem_name,s_rem_name,rem_part_type,s_rem_part_type,prd_inst_name,rem_active,rem_pmh_objid,serial_no,s_serial_no,invoice_no,pinst_objid,rem_part_number,s_rem_part_number,rem_mod_level,s_rem_mod_level,rem_model_num,s_rem_model_num,price,install_serial,remove_serial,status,failure_status,install_qty,remove_qty,part_used_date,trans_type,remove_prt_num,remove_prt_name,remove_mod,case_id_number,detail_number,inv_status,dtl_condtn) AS
select table_part_used.objid, table_mod_level.objid,
 table_part_num.description, table_part_num.S_description, table_part_num.domain, table_part_num.S_domain,
 table_site_part.instance_name, table_mod_level.active,
 table_part_num.objid, table_site_part.serial_no, table_site_part.S_serial_no,
 table_site_part.invoice_no, table_site_part.objid,
 table_part_num.part_number, table_part_num.S_part_number, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_part_num.model_num, table_part_num.S_model_num, table_part_used.price,
 table_part_used.install_serial, table_part_used.remove_serial,
 table_part_used.status, table_part_used.failure_status,
 table_part_used.install_qty, table_part_used.remove_qty,
 table_part_used.part_used_date, table_part_used.trans_type,
 table_part_used.rem_part_num, table_part_used.rem_part_name,
 table_part_used.rem_mod_level, table_part_used.case_id_number,
 table_part_used.detail_number, table_part_used.inv_status,
 table_part_used.dtl_condtn
 from table_part_used, table_mod_level, table_part_num,
  table_site_part
 where table_mod_level.objid = table_part_used.part_used2rem_part_info
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_site_part.objid = table_part_used.part_used2site_part
 ;
COMMENT ON TABLE sa.table_prtuse2_view IS 'Information used in parts used transactions';
COMMENT ON COLUMN sa.table_prtuse2_view.objid IS 'Part used internal record number';
COMMENT ON COLUMN sa.table_prtuse2_view.rem_pmlobjid IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_prtuse2_view.rem_name IS 'Maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_prtuse2_view.rem_part_type IS 'Name';
COMMENT ON COLUMN sa.table_prtuse2_view.prd_inst_name IS 'Installed part name';
COMMENT ON COLUMN sa.table_prtuse2_view.rem_active IS 'Active/inactive/obsolete';
COMMENT ON COLUMN sa.table_prtuse2_view.rem_pmh_objid IS 'Part internal record number';
COMMENT ON COLUMN sa.table_prtuse2_view.serial_no IS 'Installed part serial number';
COMMENT ON COLUMN sa.table_prtuse2_view.invoice_no IS 'Installed part invoice number';
COMMENT ON COLUMN sa.table_prtuse2_view.pinst_objid IS 'Installed part internal record number';
COMMENT ON COLUMN sa.table_prtuse2_view.rem_part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_prtuse2_view.rem_mod_level IS 'Removed part revision';
COMMENT ON COLUMN sa.table_prtuse2_view.rem_model_num IS 'Removed part marketing model number of the part; within family and line';
COMMENT ON COLUMN sa.table_prtuse2_view.price IS 'Price of the part';
COMMENT ON COLUMN sa.table_prtuse2_view.install_serial IS 'Serial number of the installed part';
COMMENT ON COLUMN sa.table_prtuse2_view.remove_serial IS 'Serial number of the removed part';
COMMENT ON COLUMN sa.table_prtuse2_view.status IS 'Status of the transaction';
COMMENT ON COLUMN sa.table_prtuse2_view.failure_status IS 'Failure code for the removed part';
COMMENT ON COLUMN sa.table_prtuse2_view.install_qty IS 'Number of parts installed';
COMMENT ON COLUMN sa.table_prtuse2_view.remove_qty IS 'Number of parts removed';
COMMENT ON COLUMN sa.table_prtuse2_view.part_used_date IS 'Date/time of transaction';
COMMENT ON COLUMN sa.table_prtuse2_view.trans_type IS 'Transaction type; i.e., exchange/consume';
COMMENT ON COLUMN sa.table_prtuse2_view.remove_prt_num IS 'Part number of removed part';
COMMENT ON COLUMN sa.table_prtuse2_view.remove_prt_name IS 'Part description of removed part';
COMMENT ON COLUMN sa.table_prtuse2_view.remove_mod IS 'Revision level of the removed part';
COMMENT ON COLUMN sa.table_prtuse2_view.case_id_number IS 'Case number for transaction';
COMMENT ON COLUMN sa.table_prtuse2_view.detail_number IS 'The part request number for the part used action. Same as the part request, detail number';
COMMENT ON COLUMN sa.table_prtuse2_view.inv_status IS 'Status of the inventory update for the part used activity; i.e., new=not attempted, failed=attempted and failed, complete=completed successfully';
COMMENT ON COLUMN sa.table_prtuse2_view.dtl_condtn IS 'Used for temporary storage of the related part request s condition';