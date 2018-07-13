CREATE OR REPLACE FORCE VIEW sa.table_prtused_view (objid,inst_pmlobjid,rem_pmlobjid,rem_name,s_rem_name,rem_part_type,s_rem_part_type,inst_name,s_inst_name,inst_part_type,s_inst_part_type,prd_inst_name,inst_active,rem_active,rem_pmh_objid,inst_pmh_objid,serial_no,s_serial_no,invoice_no,pinst_objid,inst_part_number,s_inst_part_number,inst_mod_level,s_inst_mod_level,inst_model_num,s_inst_model_num,rem_part_number,s_rem_part_number,rem_mod_level,s_rem_mod_level,rem_model_num,s_rem_model_num,price,install_serial,remove_serial,status,failure_status,install_qty,remove_qty,part_used_date,trans_type,remove_prt_num,remove_prt_name,remove_mod,part_used_oid,case_id_number,detail_number,inv_status,dtl_condtn) AS
select table_part_used.objid, table_inst_part_mod.objid,
 table_rem_part_mod.objid, table_rem_part_num.description, table_rem_part_num.S_description,
 table_rem_part_num.domain, table_rem_part_num.S_domain, table_inst_part_num.description, table_inst_part_num.S_description,
 table_inst_part_num.domain, table_inst_part_num.S_domain, table_site_part.instance_name,
 table_inst_part_mod.active, table_rem_part_mod.active,
 table_rem_part_num.objid, table_inst_part_num.objid,
 table_site_part.serial_no, table_site_part.S_serial_no, table_site_part.invoice_no,
 table_site_part.objid, table_inst_part_num.part_number, table_inst_part_num.S_part_number,
 table_inst_part_mod.mod_level, table_inst_part_mod.S_mod_level, table_inst_part_num.model_num, table_inst_part_num.S_model_num,
 table_rem_part_num.part_number, table_rem_part_num.S_part_number, table_rem_part_mod.mod_level, table_rem_part_mod.S_mod_level,
 table_rem_part_num.model_num, table_rem_part_num.S_model_num, table_part_used.price,
 table_part_used.install_serial, table_part_used.remove_serial,
 table_part_used.status, table_part_used.failure_status,
 table_part_used.install_qty, table_part_used.remove_qty,
 table_part_used.part_used_date, table_part_used.trans_type,
 table_part_used.rem_part_num, table_part_used.rem_part_name,
 table_part_used.rem_mod_level, table_part_used.objid,
 table_part_used.case_id_number, table_part_used.detail_number,
 table_part_used.inv_status, table_part_used.dtl_condtn
 from table_mod_level table_inst_part_mod, table_mod_level table_rem_part_mod, table_part_num table_inst_part_num, table_part_num table_rem_part_num, table_part_used, table_site_part
 where table_inst_part_mod.objid = table_part_used.part_used2inst_part_info
 AND table_rem_part_num.objid = table_rem_part_mod.part_info2part_num
 AND table_rem_part_mod.objid = table_part_used.part_used2rem_part_info
 AND table_inst_part_num.objid = table_inst_part_mod.part_info2part_num
 AND table_site_part.objid = table_part_used.part_used2site_part
 ;
COMMENT ON TABLE sa.table_prtused_view IS 'The installed part. Used by form Parts Used (690) and Select Installed Serial No (691)';
COMMENT ON COLUMN sa.table_prtused_view.objid IS 'Part used internal record number';
COMMENT ON COLUMN sa.table_prtused_view.inst_pmlobjid IS 'Installed part revision internal record number';
COMMENT ON COLUMN sa.table_prtused_view.rem_pmlobjid IS 'Removed part revision internal record number';
COMMENT ON COLUMN sa.table_prtused_view.rem_name IS 'Removed product number maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_prtused_view.rem_part_type IS 'Removed part name';
COMMENT ON COLUMN sa.table_prtused_view.inst_name IS 'Installed part maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_prtused_view.inst_part_type IS 'Installed part domain name';
COMMENT ON COLUMN sa.table_prtused_view.prd_inst_name IS 'Installed part name';
COMMENT ON COLUMN sa.table_prtused_view.inst_active IS 'Installed part state; i.e., active/inactive/obsolete';
COMMENT ON COLUMN sa.table_prtused_view.rem_active IS 'Removed part state; i.e., active/inactive/obsolete';
COMMENT ON COLUMN sa.table_prtused_view.rem_pmh_objid IS 'Removed part num internal record number';
COMMENT ON COLUMN sa.table_prtused_view.inst_pmh_objid IS 'Installed part number internal record number';
COMMENT ON COLUMN sa.table_prtused_view.serial_no IS 'Installed part serial number';
COMMENT ON COLUMN sa.table_prtused_view.invoice_no IS 'Installed part invoice number';
COMMENT ON COLUMN sa.table_prtused_view.pinst_objid IS 'Installed part internal record number';
COMMENT ON COLUMN sa.table_prtused_view.inst_part_number IS 'Installed part number/name';
COMMENT ON COLUMN sa.table_prtused_view.inst_mod_level IS 'Installed part revision';
COMMENT ON COLUMN sa.table_prtused_view.inst_model_num IS 'Installed part marketing model number of the part; within family and line';
COMMENT ON COLUMN sa.table_prtused_view.rem_part_number IS 'Removed part number/name';
COMMENT ON COLUMN sa.table_prtused_view.rem_mod_level IS 'Removed part revision';
COMMENT ON COLUMN sa.table_prtused_view.rem_model_num IS 'Removed part marketing model number of the part; within family and line';
COMMENT ON COLUMN sa.table_prtused_view.price IS 'Price of the part';
COMMENT ON COLUMN sa.table_prtused_view.install_serial IS 'Serial number of the installed part';
COMMENT ON COLUMN sa.table_prtused_view.remove_serial IS 'Serial number of the removed part';
COMMENT ON COLUMN sa.table_prtused_view.status IS 'Status of the transaction';
COMMENT ON COLUMN sa.table_prtused_view.failure_status IS 'Failure code for the removed part';
COMMENT ON COLUMN sa.table_prtused_view.install_qty IS 'Number of parts installed';
COMMENT ON COLUMN sa.table_prtused_view.remove_qty IS 'Number of parts removed';
COMMENT ON COLUMN sa.table_prtused_view.part_used_date IS 'Date/time of transaction';
COMMENT ON COLUMN sa.table_prtused_view.trans_type IS 'Transaction type; i.e., exchange/consume';
COMMENT ON COLUMN sa.table_prtused_view.remove_prt_num IS 'Part number of removed part';
COMMENT ON COLUMN sa.table_prtused_view.remove_prt_name IS 'Part description of removed part';
COMMENT ON COLUMN sa.table_prtused_view.remove_mod IS 'Revision level of the removed part';
COMMENT ON COLUMN sa.table_prtused_view.part_used_oid IS 'Part used internal record number';
COMMENT ON COLUMN sa.table_prtused_view.case_id_number IS 'Case number for transaction';
COMMENT ON COLUMN sa.table_prtused_view.detail_number IS 'The part request number for the part used action. Same as the part request, detail number';
COMMENT ON COLUMN sa.table_prtused_view.inv_status IS 'Status of the inventory update for the part used activity; i.e., new=not attempted, failed=attempted and failed, complete=completed successfully';
COMMENT ON COLUMN sa.table_prtused_view.dtl_condtn IS 'Used for temporary storage of the related part request s condition';