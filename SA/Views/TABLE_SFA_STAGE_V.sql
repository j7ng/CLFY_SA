CREATE OR REPLACE FORCE VIEW sa.table_sfa_stage_v (objid,stage_objid,process_objid,status_objid,cond_objid,stage_name,s_stage_name,stage_prob,stage_status,s_stage_status,stage_cond,process_name,stage_seq_num,stage_cond_cd) AS
select table_stage_assign.objid, table_cycle_stage.objid,
 table_life_cycle.objid, table_gbst_elm.objid,
 table_gbst_lst.objid, table_cycle_stage.name, table_cycle_stage.S_name,
 table_cycle_stage.close_pct, table_gbst_elm.title, table_gbst_elm.S_title,
 table_gbst_lst.title, table_life_cycle.name,
 table_stage_assign.seq_num, table_gbst_lst.addnl_info
 from table_stage_assign, table_cycle_stage, table_life_cycle,
  table_gbst_elm, table_gbst_lst
 where table_life_cycle.objid = table_stage_assign.assign2life_cycle
 AND table_gbst_lst.objid = table_gbst_elm.gbst_elm2gbst_lst
 AND table_cycle_stage.objid = table_stage_assign.assign2cycle_stage
 AND table_gbst_elm.objid = table_cycle_stage.stage_status2gbst_elm
 ;
COMMENT ON TABLE sa.table_sfa_stage_v IS 'Used Sales stage dropdown for opportunity. Used by Account Mgr (11650), Console-Sales (12000), and Opportunity Mgr (13000)';
COMMENT ON COLUMN sa.table_sfa_stage_v.objid IS 'Stage_assign internal record number';
COMMENT ON COLUMN sa.table_sfa_stage_v.stage_objid IS 'Stage internal record number';
COMMENT ON COLUMN sa.table_sfa_stage_v.process_objid IS 'Life_cycle internal record number';
COMMENT ON COLUMN sa.table_sfa_stage_v.status_objid IS 'Gbst_elm internal number';
COMMENT ON COLUMN sa.table_sfa_stage_v.cond_objid IS 'Gbst_lst internal number';
COMMENT ON COLUMN sa.table_sfa_stage_v.stage_name IS 'Name of the stage in the sales process';
COMMENT ON COLUMN sa.table_sfa_stage_v.stage_prob IS 'Average percent of deals that eventually close from the stage';
COMMENT ON COLUMN sa.table_sfa_stage_v.stage_status IS 'Status assigned to the cycle stage';
COMMENT ON COLUMN sa.table_sfa_stage_v.stage_cond IS 'Condition title, stored in gbst_lst title field';
COMMENT ON COLUMN sa.table_sfa_stage_v.process_name IS 'Sales process name';
COMMENT ON COLUMN sa.table_sfa_stage_v.stage_seq_num IS 'Sequence number of the stage within the life cycle';
COMMENT ON COLUMN sa.table_sfa_stage_v.stage_cond_cd IS 'Condtion code stored in gbst_lst addnl_info field';