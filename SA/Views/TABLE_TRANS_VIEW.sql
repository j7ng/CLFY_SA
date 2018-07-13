CREATE OR REPLACE FORCE VIEW sa.table_trans_view (transition_id,from_state_id,to_state_id,"RANK",dialog_id,fr_state_state,to_state_state,from_title,s_from_title,to_title,s_to_title,to_state_rank,focus_type,focus_subtype,from_condition,to_condition,from_cond_id,to_cond_id) AS
select table_transition.objid, table_from_state.objid,
 table_to_state.objid, table_transition.rank,
 table_transition.dialog_id, table_from_state.state,
 table_to_state.state, table_from_state.title, table_from_state.S_title,
 table_to_state.title, table_to_state.S_title, table_to_state.rank,
 table_transition.focus_type, table_transition.focus_subtype,
 table_from_condition.title, table_to_condition.title,
 table_from_condition.objid, table_to_condition.objid
 from table_gbst_elm table_from_state, table_gbst_elm table_to_state, table_gbst_lst table_from_condition, table_gbst_lst table_to_condition, table_transition
 where table_from_state.objid = table_transition.from_state2gbst_elm
 AND table_to_condition.objid = table_to_state.gbst_elm2gbst_lst
 AND table_to_state.objid = table_transition.to_state2gbst_elm
 AND table_from_condition.objid = table_from_state.gbst_elm2gbst_lst
 ;
COMMENT ON TABLE sa.table_trans_view IS 'New transistion state in a change transaction. Used by form CR (334), CR More (335), Customer Info (336), New CR (337), CCList (339), State Transitions (851), Change Status (852)';
COMMENT ON COLUMN sa.table_trans_view.transition_id IS 'Transition internal record number';
COMMENT ON COLUMN sa.table_trans_view.from_state_id IS 'FROM gbst_elm internal record number';
COMMENT ON COLUMN sa.table_trans_view.to_state_id IS 'TO gbst_elm internal record number';
COMMENT ON COLUMN sa.table_trans_view."RANK" IS 'Transition number which identifies entry in privilege mask';
COMMENT ON COLUMN sa.table_trans_view.dialog_id IS 'ID of form which should be posted during the transition';
COMMENT ON COLUMN sa.table_trans_view.fr_state_state IS 'From state/status of the item; i.e., 0=active, 1=inactive, 2=Default';
COMMENT ON COLUMN sa.table_trans_view.to_state_state IS 'To state/status of the item; i.e., 0=active, 1=inactive, 2=Default';
COMMENT ON COLUMN sa.table_trans_view.from_title IS 'FROM name of the item/element';
COMMENT ON COLUMN sa.table_trans_view.to_title IS 'TO name of the item/element';
COMMENT ON COLUMN sa.table_trans_view.to_state_rank IS 'TO position of the item in the list; important in tracking scheduled/unscheduled and config time for service interuption report';
COMMENT ON COLUMN sa.table_trans_view.focus_type IS 'Object type ID (e.g., Case=0, Probdesc=1) of the transition s focus object. The combination of focus_type and focus_subtype fully identify the transition s focus object';
COMMENT ON COLUMN sa.table_trans_view.focus_subtype IS 'Subtype of the focus object; e.g.,demand_dtl.demand_subtype';
COMMENT ON COLUMN sa.table_trans_view.from_condition IS 'FROM state of the transition';
COMMENT ON COLUMN sa.table_trans_view.to_condition IS 'TO state of the transition';
COMMENT ON COLUMN sa.table_trans_view.from_cond_id IS 'FROM state internal record number';
COMMENT ON COLUMN sa.table_trans_view.to_cond_id IS 'TO state internal record number';