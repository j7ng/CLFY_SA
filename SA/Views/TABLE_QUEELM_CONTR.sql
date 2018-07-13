CREATE OR REPLACE FORCE VIEW sa.table_queelm_contr (que_objid,elm_objid,clarify_state,"ID",s_id,age,"CONDITION",s_condition,status,s_status,title,s_title,"TYPE",struct_type) AS
select table_contract.contr_currq2queue, table_contract.objid,
 table_condition.condition, table_contract.id, table_contract.S_id,
 table_condition.queue_time, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_contract.title, table_contract.S_title,
 table_contract.type, table_contract.struct_type
 from table_contract, table_condition, table_gbst_elm
 where table_contract.contr_currq2queue IS NOT NULL
 AND table_gbst_elm.objid = table_contract.status2gbst_elm
 AND table_condition.objid = table_contract.contract2condition
 ;
COMMENT ON TABLE sa.table_queelm_contr IS 'View contract information for Queue';
COMMENT ON COLUMN sa.table_queelm_contr.que_objid IS 'Queue object ID number';
COMMENT ON COLUMN sa.table_queelm_contr.elm_objid IS 'Contract object ID number';
COMMENT ON COLUMN sa.table_queelm_contr.clarify_state IS 'Contract condition';
COMMENT ON COLUMN sa.table_queelm_contr."ID" IS 'Contract ID number';
COMMENT ON COLUMN sa.table_queelm_contr.age IS 'Age of contract in seconds';
COMMENT ON COLUMN sa.table_queelm_contr."CONDITION" IS 'Condition of contract';
COMMENT ON COLUMN sa.table_queelm_contr.status IS 'Status of contract';
COMMENT ON COLUMN sa.table_queelm_contr.title IS 'Title of contract';
COMMENT ON COLUMN sa.table_queelm_contr."TYPE" IS 'Contract type';
COMMENT ON COLUMN sa.table_queelm_contr.struct_type IS 'Type of contract/quote structure of the object; i.e., 0=service contract, 1=sales item';