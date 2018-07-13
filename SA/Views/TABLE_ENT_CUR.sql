CREATE OR REPLACE FORCE VIEW sa.table_ent_cur (objid,entitle_id,"NAME",description,"TYPE","ACTIVE",unit_cost,unit_measure,incl_parts,incl_labor,taxable,cur_objid,cur_name,s_cur_name,cur_symbol,cur_desc,sub_scale) AS
select table_entitlement.objid, table_entitlement.entitle_id,
 table_entitlement.name, table_entitlement.description,
 table_entitlement.type, table_entitlement.active,
 table_entitlement.cost, table_entitlement.unit_measure,
 table_entitlement.incl_parts, table_entitlement.incl_labor,
 table_entitlement.taxable, table_currency.objid,
 table_currency.name, table_currency.S_name, table_currency.symbol,
 table_currency.description, table_currency.sub_scale
 from table_entitlement, table_currency
 where table_currency.objid = table_entitlement.curr_type2currency
 ;
COMMENT ON TABLE sa.table_ent_cur IS 'Assembles entitlement costs';
COMMENT ON COLUMN sa.table_ent_cur.objid IS 'Entitlement internal record number';
COMMENT ON COLUMN sa.table_ent_cur.entitle_id IS 'The unique identifier of a support entitlement';
COMMENT ON COLUMN sa.table_ent_cur."NAME" IS 'The textual name for the support entitlement';
COMMENT ON COLUMN sa.table_ent_cur.description IS 'The description of the support entitlement';
COMMENT ON COLUMN sa.table_ent_cur."TYPE" IS 'The type of the support entitlement';
COMMENT ON COLUMN sa.table_ent_cur."ACTIVE" IS 'Indicates if the support entitlement is currently available to use in building new support programs; i.e., 0=inactive, 1=active';
COMMENT ON COLUMN sa.table_ent_cur.unit_cost IS 'The cost of the support entitlement';
COMMENT ON COLUMN sa.table_ent_cur.unit_measure IS 'Unit of measure for the unit cost';
COMMENT ON COLUMN sa.table_ent_cur.incl_parts IS 'Indicates if the support entitlement includes parts-related coverage; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_ent_cur.incl_labor IS 'Indicates if the support entitlement includes labor-related coverage; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_ent_cur.taxable IS 'Indicates if the support entitlement is a taxable element of a support program; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_ent_cur.cur_objid IS 'Internal record number of the currency object';
COMMENT ON COLUMN sa.table_ent_cur.cur_name IS 'Name of the currency in which cost is denominated';
COMMENT ON COLUMN sa.table_ent_cur.cur_symbol IS 'Symbol for the currency; e.g., $ for US dollar, in which cost is denominated';
COMMENT ON COLUMN sa.table_ent_cur.cur_desc IS 'Description of the currency in which cost is denominated';
COMMENT ON COLUMN sa.table_ent_cur.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';