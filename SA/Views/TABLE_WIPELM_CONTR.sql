CREATE OR REPLACE FORCE VIEW sa.table_wipelm_contr (wip_objid,elm_objid,clarify_state,"ID",s_id,age,"CONDITION",s_condition,status,s_status,title,s_title,struct_type) AS
select table_contract.contr_wip2wipbin, table_contract.objid,
 table_condition.condition, table_contract.id, table_contract.S_id,
 table_condition.wipbin_time, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_contract.title, table_contract.S_title,
 table_contract.struct_type
 from table_contract, table_condition, table_gbst_elm
 where table_contract.contr_wip2wipbin IS NOT NULL
 AND table_gbst_elm.objid = table_contract.status2gbst_elm
 AND table_condition.objid = table_contract.contract2condition
 ;
COMMENT ON TABLE sa.table_wipelm_contr IS 'View contract information';
COMMENT ON COLUMN sa.table_wipelm_contr.wip_objid IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_wipelm_contr.elm_objid IS 'Contract internal record number number';
COMMENT ON COLUMN sa.table_wipelm_contr.clarify_state IS 'Contract state';
COMMENT ON COLUMN sa.table_wipelm_contr."ID" IS 'Unique ID number ofr the contract';
COMMENT ON COLUMN sa.table_wipelm_contr.age IS 'Contract age in seconds';
COMMENT ON COLUMN sa.table_wipelm_contr."CONDITION" IS 'Contract condition';
COMMENT ON COLUMN sa.table_wipelm_contr.status IS 'Contract status';
COMMENT ON COLUMN sa.table_wipelm_contr.title IS 'Title of the contract or quote';
COMMENT ON COLUMN sa.table_wipelm_contr.struct_type IS 'Type of contract/quote structure of the object; i.e., 0=service contract, 1=sales item';