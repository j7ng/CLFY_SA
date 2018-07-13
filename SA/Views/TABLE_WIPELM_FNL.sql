CREATE OR REPLACE FORCE VIEW sa.table_wipelm_fnl (wip_objid,elm_objid,clarify_state,id_number,age,"CONDITION",s_condition,title,s_title) AS
select table_probdesc.probdesc_wip2wipbin, table_probdesc.objid,
 table_condition.condition, table_probdesc.id_number,
 table_condition.wipbin_time, table_condition.title, table_condition.S_title,
 table_probdesc.title, table_probdesc.S_title
 from table_probdesc, table_condition
 where table_condition.objid = table_probdesc.probdesc2condition
 AND table_probdesc.probdesc_wip2wipbin IS NOT NULL
 ;
COMMENT ON TABLE sa.table_wipelm_fnl IS 'Selects solution information for WIPbin display';
COMMENT ON COLUMN sa.table_wipelm_fnl.wip_objid IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_wipelm_fnl.elm_objid IS 'Probdesc internal record number';
COMMENT ON COLUMN sa.table_wipelm_fnl.clarify_state IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_wipelm_fnl.id_number IS 'Solution ID number';
COMMENT ON COLUMN sa.table_wipelm_fnl.age IS 'Date and time task was accepted into WIPbin';
COMMENT ON COLUMN sa.table_wipelm_fnl."CONDITION" IS 'Title of condition type';
COMMENT ON COLUMN sa.table_wipelm_fnl.title IS 'Solution title';