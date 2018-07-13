CREATE OR REPLACE FORCE VIEW sa.table_wipelm_dtl (wip_objid,elm_objid,clarify_state,id_number,age,"CONDITION",s_condition,status,s_status,"PRIORITY",part_number,s_part_number,mod_level,s_mod_level,quantity,title,"OWNER",condition_code) AS
select table_demand_dtl.demand_dtl_wip2wipbin, table_demand_dtl.objid,
 table_condition.condition, table_demand_dtl.detail_number,
 table_condition.wipbin_time, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_demand_dtl.priority,
 table_part_num.part_number, table_part_num.S_part_number, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_demand_dtl.demand_qty, table_demand_dtl.title,
 table_demand_dtl.demand_dtl_owner2user, table_condition.condition
 from table_gbst_elm table_gse_status, table_demand_dtl, table_condition, table_part_num,
  table_mod_level
 where table_gse_status.objid = table_demand_dtl.dmnd_dtl_sts2gbst_elm
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_demand_dtl.demand_dtl_owner2user IS NOT NULL
 AND table_demand_dtl.demand_dtl_wip2wipbin IS NOT NULL
 AND table_condition.objid = table_demand_dtl.demand_dtl2condition
 AND table_mod_level.objid = table_demand_dtl.demand_dtl2part_info
 ;
COMMENT ON TABLE sa.table_wipelm_dtl IS 'Selects part request details for WIPbin presentation';
COMMENT ON COLUMN sa.table_wipelm_dtl.wip_objid IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_wipelm_dtl.elm_objid IS 'Demand_dlt internal record number';
COMMENT ON COLUMN sa.table_wipelm_dtl.clarify_state IS 'State of part request';
COMMENT ON COLUMN sa.table_wipelm_dtl.id_number IS 'Part request object ID Number';
COMMENT ON COLUMN sa.table_wipelm_dtl.age IS 'Age of part request in seconds';
COMMENT ON COLUMN sa.table_wipelm_dtl."CONDITION" IS 'Part request condition';
COMMENT ON COLUMN sa.table_wipelm_dtl.status IS 'Part request status';
COMMENT ON COLUMN sa.table_wipelm_dtl."PRIORITY" IS 'Part request Priority; from part request header priority';
COMMENT ON COLUMN sa.table_wipelm_dtl.part_number IS 'Part number of part request';
COMMENT ON COLUMN sa.table_wipelm_dtl.mod_level IS 'Revision level of part request';
COMMENT ON COLUMN sa.table_wipelm_dtl.quantity IS 'Quantity of part request';
COMMENT ON COLUMN sa.table_wipelm_dtl.title IS 'Part request title';
COMMENT ON COLUMN sa.table_wipelm_dtl."OWNER" IS 'Part request owner s internal record number';
COMMENT ON COLUMN sa.table_wipelm_dtl.condition_code IS 'Code number for part request condition';