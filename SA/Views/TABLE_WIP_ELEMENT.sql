CREATE OR REPLACE FORCE VIEW sa.table_wip_element (wip_objid,elm_objid,clarify_state,id_number,age,"CONDITION",s_condition,status,s_status,title,s_title,"PRIORITY",s_priority,severity,s_severity,part_number,s_part_number,mod_level,s_mod_level,quantity,x_carrier_id,x_carrier_name,x_creation_time,x_esn) AS
select table_case.case_wip2wipbin, table_case.objid,
 table_bug_cond.condition, table_case.id_number,
 table_bug_cond.wipbin_time, table_bug_cond.title, table_bug_cond.S_title,
 table_gse_status.title, table_gse_status.S_title, table_case.title, table_case.S_title,
 table_gse_priority.title, table_gse_priority.S_title, table_gse_severity.title, table_gse_severity.S_title,
 table_part_num.part_number, table_part_num.S_part_number, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_demand_dtl.demand_qty, table_case.x_text_car_id,
 table_case.x_carrier_name, table_case.creation_time,
 table_case.x_esn
 from table_condition table_bug_cond, table_condition table_dtl_cond, table_condition table_fnl_cond, table_condition table_sub_cond, table_gbst_elm table_gse_priority, table_gbst_elm table_gse_severity, table_gbst_elm table_gse_status, table_case, table_part_num, table_mod_level,
  table_demand_dtl, table_bug, table_subcase,
  table_probdesc
 where table_gse_priority.objid = table_case.respprty2gbst_elm
 AND table_bug_cond.objid = table_case.case_state2condition
 AND table_gse_severity.objid = table_case.respsvrty2gbst_elm
 AND table_bug_cond.objid = table_bug.bug_condit2condition
 AND table_mod_level.objid = table_demand_dtl.demand_dtl2part_info
 AND table_case.case_wip2wipbin IS NOT NULL
 AND table_sub_cond.objid = table_subcase.subc_state2condition
 AND table_fnl_cond.objid = table_probdesc.probdesc2condition
 AND table_dtl_cond.objid = table_demand_dtl.demand_dtl2condition
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_gse_status.objid = table_case.casests2gbst_elm
 ;
COMMENT ON TABLE sa.table_wip_element IS 'Used to allocate data structures to like columns in multiple views named wipelm_* by mapping them to the same generic field ID. Not run against the database. Used by form WipBin WipName (381)';
COMMENT ON COLUMN sa.table_wip_element.wip_objid IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_wip_element.elm_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_wip_element.clarify_state IS 'Condition/state of the change request';
COMMENT ON COLUMN sa.table_wip_element.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_wip_element.age IS 'Date and time the task was accepted into WIPbin';
COMMENT ON COLUMN sa.table_wip_element."CONDITION" IS 'Title of the object s condition';
COMMENT ON COLUMN sa.table_wip_element.status IS 'Status of the object';
COMMENT ON COLUMN sa.table_wip_element.title IS 'Title of the object';
COMMENT ON COLUMN sa.table_wip_element."PRIORITY" IS 'Priority of the object';
COMMENT ON COLUMN sa.table_wip_element.severity IS 'Severity of the object';
COMMENT ON COLUMN sa.table_wip_element.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_wip_element.mod_level IS 'Revision level';
COMMENT ON COLUMN sa.table_wip_element.quantity IS 'The order quantity';
COMMENT ON COLUMN sa.table_wip_element.x_carrier_id IS 'Carrier ID stored as text from the case';
COMMENT ON COLUMN sa.table_wip_element.x_carrier_name IS 'Carrier Market/Submarket Name';
COMMENT ON COLUMN sa.table_wip_element.x_creation_time IS 'The date and time the case was created';
COMMENT ON COLUMN sa.table_wip_element.x_esn IS 'Serial Number of the Phone for Wireless or Service Id for Wireline';