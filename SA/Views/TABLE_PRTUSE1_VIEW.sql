CREATE OR REPLACE FORCE VIEW sa.table_prtuse1_view (objid,inst_pmlobjid,inst_name,s_inst_name,inst_part_type,s_inst_part_type,prd_inst_name,inst_active,inst_pmh_objid,serial_no,s_serial_no,invoice_no,pinst_objid,inst_part_number,s_inst_part_number,inst_mod_level,s_inst_mod_level,inst_model_num,s_inst_model_num,price,install_serial,remove_serial,status,failure_status,install_qty,remove_qty,part_used_date,trans_type,remove_prt_num,remove_prt_name,remove_mod,case_id_number,detail_number,inv_status,dtl_condtn) AS
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
 where table_site_part.objid = table_part_used.part_used2site_part
 AND table_mod_level.objid = table_part_used.part_used2inst_part_info
 AND table_part_num.objid = table_mod_level.part_info2part_num
 ;
COMMENT ON TABLE sa.table_prtuse1_view IS 'Information used in parts used form.  Includes installed part and removed part information';
COMMENT ON COLUMN sa.table_prtuse1_view.objid IS 'Part used internal record number';
COMMENT ON COLUMN sa.table_prtuse1_view.inst_pmlobjid IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_prtuse1_view.inst_name IS 'Maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_prtuse1_view.inst_part_type IS 'Part domanin name';
COMMENT ON COLUMN sa.table_prtuse1_view.prd_inst_name IS 'Part name';
COMMENT ON COLUMN sa.table_prtuse1_view.inst_active IS 'Active/inactive/obsolete';
COMMENT ON COLUMN sa.table_prtuse1_view.inst_pmh_objid IS 'Part num internal record number';
COMMENT ON COLUMN sa.table_prtuse1_view.serial_no IS 'Installed part serial number';
COMMENT ON COLUMN sa.table_prtuse1_view.invoice_no IS 'Installed part invoice number';
COMMENT ON COLUMN sa.table_prtuse1_view.pinst_objid IS 'Installed part internal record number';
COMMENT ON COLUMN sa.table_prtuse1_view.inst_part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_prtuse1_view.inst_mod_level IS 'Installed part revision';
COMMENT ON COLUMN sa.table_prtuse1_view.inst_model_num IS 'Installed part marketing model number of the part; within family and line';
COMMENT ON COLUMN sa.table_prtuse1_view.price IS 'Price of the part';
COMMENT ON COLUMN sa.table_prtuse1_view.install_serial IS 'Serial number of the installed part';
COMMENT ON COLUMN sa.table_prtuse1_view.remove_serial IS 'Serial number of the removed part';
COMMENT ON COLUMN sa.table_prtuse1_view.status IS 'Status of the transaction';
COMMENT ON COLUMN sa.table_prtuse1_view.failure_status IS 'Failure code for the removed part';
COMMENT ON COLUMN sa.table_prtuse1_view.install_qty IS 'Number of parts installed';
COMMENT ON COLUMN sa.table_prtuse1_view.remove_qty IS 'Number of parts removed';
COMMENT ON COLUMN sa.table_prtuse1_view.part_used_date IS 'Date/time of transaction';
COMMENT ON COLUMN sa.table_prtuse1_view.trans_type IS 'Transaction type; i.e., exchange/consume';
COMMENT ON COLUMN sa.table_prtuse1_view.remove_prt_num IS 'Part number of removed part';
COMMENT ON COLUMN sa.table_prtuse1_view.remove_prt_name IS 'Part description of removed part';
COMMENT ON COLUMN sa.table_prtuse1_view.remove_mod IS 'Revision level of the removed part';
COMMENT ON COLUMN sa.table_prtuse1_view.case_id_number IS 'Case number for transaction';
COMMENT ON COLUMN sa.table_prtuse1_view.detail_number IS 'The part request number for the part used action. Same as the part request, detail number';
COMMENT ON COLUMN sa.table_prtuse1_view.inv_status IS 'Status of the inventory update for the part used activity; i.e., new=not attempted, failed=attempted and failed, complete=completed successfully';
COMMENT ON COLUMN sa.table_prtuse1_view.dtl_condtn IS 'Used for temporary storage of the related part request s condition';