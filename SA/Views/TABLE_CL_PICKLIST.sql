CREATE OR REPLACE FORCE VIEW sa.table_cl_picklist (objid,template_objid,focus_type,focus_lowid,rule_rank,action_rank,auto_exec_ind,confidence,id_number,s_id_number,title,s_title,"ACTIVE") AS
select table_cl_result.objid, table_template.objid,
 table_cl_result.focus_type, table_cl_result.focus_lowid,
 table_cl_result.rule_rank, table_cl_result.action_rank,
 table_cl_result.action_auto_exec, table_cl_result.rule_confidence,
 table_template.id_number, table_template.S_id_number, table_template.title, table_template.S_title,
 table_template.active
 from table_cl_result, table_template
 where table_template.objid = table_cl_result.cl_result2template
 ;
COMMENT ON TABLE sa.table_cl_picklist IS 'Displays classification results for auto-suggest. Used by Preview Template form (15142)';
COMMENT ON COLUMN sa.table_cl_picklist.objid IS 'Cl_result internal record number';
COMMENT ON COLUMN sa.table_cl_picklist.template_objid IS 'Template internal record number';
COMMENT ON COLUMN sa.table_cl_picklist.focus_type IS 'The object type of the object which was classified';
COMMENT ON COLUMN sa.table_cl_picklist.focus_lowid IS 'The internal record number of the object which was classified';
COMMENT ON COLUMN sa.table_cl_picklist.rule_rank IS 'The value of cl_rule.rank at the time the result was generated';
COMMENT ON COLUMN sa.table_cl_picklist.action_rank IS 'The value of cl_action.rank at the time the result was generated';
COMMENT ON COLUMN sa.table_cl_picklist.auto_exec_ind IS 'The value of cl_action.auto_exec_ind at the time the result was generated';
COMMENT ON COLUMN sa.table_cl_picklist.confidence IS 'The value of cl_rule.confidence at the time the result was generated';
COMMENT ON COLUMN sa.table_cl_picklist.id_number IS 'Unique template number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_cl_picklist.title IS 'Title of the template';
COMMENT ON COLUMN sa.table_cl_picklist."ACTIVE" IS 'Indicates whether the template is active; i.e., 0=inactive, 1=active';