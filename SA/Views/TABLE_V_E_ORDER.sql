CREATE OR REPLACE FORCE VIEW sa.table_v_e_order (objid,id_number,s_id_number,status,s_status,ord_submit_dt,contact_objid,status_objid,cndtn_objid,"CONDITION",struct_type) AS
select table_contract.objid, table_contract.id, table_contract.S_id,
 table_gbst_elm.title, table_gbst_elm.S_title, table_contract.ord_submit_dt,
 table_contract.primary2contact, table_gbst_elm.objid,
 table_condition.objid, table_condition.condition,
 table_contract.struct_type
 from table_contract, table_gbst_elm, table_condition
 where table_condition.objid = table_contract.contract2condition
 AND table_gbst_elm.objid = table_contract.status2gbst_elm
 AND table_contract.primary2contact IS NOT NULL
 ;
COMMENT ON TABLE sa.table_v_e_order IS 'View of (contract) web user s order entry information used in LaunchPad';
COMMENT ON COLUMN sa.table_v_e_order.objid IS 'Contract internal record number';
COMMENT ON COLUMN sa.table_v_e_order.id_number IS 'Contract number; generated via auto-numbering';
COMMENT ON COLUMN sa.table_v_e_order.status IS 'Contract status';
COMMENT ON COLUMN sa.table_v_e_order.ord_submit_dt IS 'E-order submit date';
COMMENT ON COLUMN sa.table_v_e_order.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_v_e_order.status_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_v_e_order.cndtn_objid IS 'Condition internal record number';
COMMENT ON COLUMN sa.table_v_e_order."CONDITION" IS 'Title of contract condition';
COMMENT ON COLUMN sa.table_v_e_order.struct_type IS 'The record type of the object; i.e., 0=service contract, 1=sales item, 2=eOrder, 3=shopping list';