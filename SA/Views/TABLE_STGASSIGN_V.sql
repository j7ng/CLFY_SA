CREATE OR REPLACE FORCE VIEW sa.table_stgassign_v (objid,seq_num,lfc_objid,lfc_name,stage_objid,stage_name,s_stage_name) AS
select table_stage_assign.objid, table_stage_assign.seq_num,
 table_life_cycle.objid, table_life_cycle.name,
 table_cycle_stage.objid, table_cycle_stage.name, table_cycle_stage.S_name
 from table_stage_assign, table_life_cycle, table_cycle_stage
 where table_life_cycle.objid = table_stage_assign.assign2life_cycle
 AND table_cycle_stage.objid = table_stage_assign.assign2cycle_stage
 ;
COMMENT ON TABLE sa.table_stgassign_v IS 'Used to assign stages to life cycles. Used by form Sales Process Def Untitled (9666)';
COMMENT ON COLUMN sa.table_stgassign_v.objid IS 'Stage_assign internal record number';
COMMENT ON COLUMN sa.table_stgassign_v.seq_num IS 'Sequence number of the stage within the life cycle';
COMMENT ON COLUMN sa.table_stgassign_v.lfc_objid IS 'Life_cycle internal record number';
COMMENT ON COLUMN sa.table_stgassign_v.lfc_name IS 'Name of the sales process';
COMMENT ON COLUMN sa.table_stgassign_v.stage_objid IS 'Cycle_stage internal record number';
COMMENT ON COLUMN sa.table_stgassign_v.stage_name IS 'Name of the sales process stage';