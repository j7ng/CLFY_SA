CREATE OR REPLACE FORCE VIEW sa.table_queelm_dtl (que_objid,elm_objid,clarify_state,id_number,age,"CONDITION",s_condition,status,s_status,"PRIORITY","TYPE",part_number,s_part_number,mod_level,s_mod_level,quantity,title,"OWNER",condition_code) AS
select table_demand_dtl.demand_dtl_curq2queue, table_demand_dtl.objid,
 table_condition.condition, table_demand_dtl.detail_number,
 table_condition.queue_time, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_demand_dtl.priority,
 table_demand_dtl.request_type, table_part_num.part_number, table_part_num.S_part_number,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_demand_dtl.demand_qty,
 table_demand_dtl.title, table_demand_dtl.demand_dtl_owner2user,
 table_condition.condition
 from table_gbst_elm table_gse_status, table_demand_dtl, table_condition, table_part_num,
  table_mod_level
 where table_condition.objid = table_demand_dtl.demand_dtl2condition
 AND table_demand_dtl.demand_dtl_curq2queue IS NOT NULL
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_mod_level.objid = table_demand_dtl.demand_dtl2part_info
 AND table_demand_dtl.demand_dtl_owner2user IS NOT NULL
 AND table_gse_status.objid = table_demand_dtl.dmnd_dtl_sts2gbst_elm
 ;
COMMENT ON TABLE sa.table_queelm_dtl IS 'Selects Part Request part request details for queue presentation';
COMMENT ON COLUMN sa.table_queelm_dtl.que_objid IS 'Unique object ID of queue';
COMMENT ON COLUMN sa.table_queelm_dtl.elm_objid IS 'Part request object ID';
COMMENT ON COLUMN sa.table_queelm_dtl.clarify_state IS 'State of part request';
COMMENT ON COLUMN sa.table_queelm_dtl.id_number IS 'Part request object ID Number';
COMMENT ON COLUMN sa.table_queelm_dtl.age IS 'Age of part request in seconds';
COMMENT ON COLUMN sa.table_queelm_dtl."CONDITION" IS 'Part request condition';
COMMENT ON COLUMN sa.table_queelm_dtl.status IS 'Part request status';
COMMENT ON COLUMN sa.table_queelm_dtl."PRIORITY" IS 'Priority of the demand';
COMMENT ON COLUMN sa.table_queelm_dtl."TYPE" IS 'Type of the demand';
COMMENT ON COLUMN sa.table_queelm_dtl.part_number IS 'Part number of part request';
COMMENT ON COLUMN sa.table_queelm_dtl.mod_level IS 'Revision level of part request';
COMMENT ON COLUMN sa.table_queelm_dtl.quantity IS 'Quantity of part request';
COMMENT ON COLUMN sa.table_queelm_dtl.title IS 'Part request title';
COMMENT ON COLUMN sa.table_queelm_dtl."OWNER" IS 'Part request owner s internal record number';
COMMENT ON COLUMN sa.table_queelm_dtl.condition_code IS 'Code number for part request condition';