CREATE OR REPLACE FORCE VIEW sa.table_contr_sp_chk (objid,site_objid,site_part_objid,sp_dir_site_objid,sched_objid,contr_objid,mod_objid,cond_objid,line_no,parent_line_no,quote_sn,cancel_dt,auto_inst_ind,site_name,s_site_name,site_id,warranty_dt,serial_no,s_serial_no,sched_id,s_sched_id,sched_cancel_dt,contr_id,s_contr_id,struct_type,"CONDITION",cond_title,s_cond_title) AS
select table_contr_itm.objid, table_site.objid,
 table_site_part.objid, table_site_part.dir_site_objid,
 table_contr_schedule.objid, table_contract.objid,
 table_contr_itm.contr_itm2mod_level, table_condition.objid,
 table_contr_itm.line_no, table_contr_itm.p_line_no,
 table_contr_itm.quote_sn, table_contr_itm.cancel_dt,
 table_contr_itm.auto_inst_ind, table_site.name, table_site.S_name,
 table_site.site_id, table_site_part.warranty_date,
 table_site_part.serial_no, table_site_part.S_serial_no, table_contr_schedule.schedule_id, table_contr_schedule.S_schedule_id,
 table_contr_schedule.close_eff_dt, table_contract.id, table_contract.S_id,
 table_contract.struct_type, table_condition.condition,
 table_condition.title, table_condition.S_title
 from table_contr_itm, table_site, table_site_part,
  table_contr_schedule, table_contract, table_condition
 where table_contr_schedule.objid = table_contr_itm.contr_itm2contr_schedule
 AND table_site.objid = table_contr_itm.quoted_at2site
 AND table_contr_itm.contr_itm2mod_level IS NOT NULL
 AND table_condition.objid = table_contract.contract2condition
 AND table_site_part.objid = table_contr_itm.contr_itm2site_part
 AND table_contract.objid = table_contr_schedule.schedule2contract
 ;
COMMENT ON TABLE sa.table_contr_sp_chk IS 'Used by forms Incoming Call (IC) (8110), IC Contact Info (8111), IC Site Contracts (8112), IC Product Contracts (8113), IC Parts (8114) IC Cases (8115) and IC Flash (8116)';
COMMENT ON COLUMN sa.table_contr_sp_chk.objid IS 'Contract line item internal record number';
COMMENT ON COLUMN sa.table_contr_sp_chk.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_contr_sp_chk.site_part_objid IS 'Site_part internal record number';
COMMENT ON COLUMN sa.table_contr_sp_chk.sp_dir_site_objid IS 'Site at which the part is installed. Derived from all_site_part2site. Not applicable to parts installed at more than one site';
COMMENT ON COLUMN sa.table_contr_sp_chk.sched_objid IS 'Contract schedule internal record number';
COMMENT ON COLUMN sa.table_contr_sp_chk.contr_objid IS 'Contract internal record number';
COMMENT ON COLUMN sa.table_contr_sp_chk.mod_objid IS 'Mod level internal record number';
COMMENT ON COLUMN sa.table_contr_sp_chk.cond_objid IS 'Condition internal record number';
COMMENT ON COLUMN sa.table_contr_sp_chk.line_no IS 'Contract line item line no';
COMMENT ON COLUMN sa.table_contr_sp_chk.parent_line_no IS 'Line number of the parent contract item';
COMMENT ON COLUMN sa.table_contr_sp_chk.quote_sn IS 'The serial number of the product to be installed under the contract line item';
COMMENT ON COLUMN sa.table_contr_sp_chk.cancel_dt IS 'If a line is canceled or closed, the date when the cancel or close becomes effective';
COMMENT ON COLUMN sa.table_contr_sp_chk.auto_inst_ind IS 'Indicates whether indicates whether a generic part is to be auto installed: 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_contr_sp_chk.site_name IS 'Contract line item site name';
COMMENT ON COLUMN sa.table_contr_sp_chk.site_id IS 'Contract line item site ID';
COMMENT ON COLUMN sa.table_contr_sp_chk.warranty_dt IS 'Contract line item warranty date';
COMMENT ON COLUMN sa.table_contr_sp_chk.serial_no IS 'Contract line item serial no';
COMMENT ON COLUMN sa.table_contr_sp_chk.sched_id IS 'Contract schedule ID number';
COMMENT ON COLUMN sa.table_contr_sp_chk.sched_cancel_dt IS 'If the schedule is prematurely closed, the date when the close becomes effective';
COMMENT ON COLUMN sa.table_contr_sp_chk.contr_id IS 'Contract ID number';
COMMENT ON COLUMN sa.table_contr_sp_chk.struct_type IS 'Type of contract/quote structure of the object; i.e., 0=service contract, 1=sales item';
COMMENT ON COLUMN sa.table_contr_sp_chk."CONDITION" IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_contr_sp_chk.cond_title IS 'Title of condition';