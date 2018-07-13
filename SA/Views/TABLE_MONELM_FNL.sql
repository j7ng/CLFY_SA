CREATE OR REPLACE FORCE VIEW sa.table_monelm_fnl (mon_objid,elm_objid,id_number,dspch_age,total_age,"CONDITION",s_condition,title,s_title,owner_name,s_owner_name) AS
select table_monitor.objid, table_probdesc.objid,
 table_probdesc.id_number, table_condition.dispatch_time,
 table_probdesc.creation_time, table_condition.title, table_condition.S_title,
 table_probdesc.title, table_probdesc.S_title, table_user.login_name, table_user.S_login_name
 from mtm_probdesc11_monitor8, table_monitor, table_probdesc, table_condition,
  table_user
 where table_user.objid = table_probdesc.probdesc_owner2user
 AND table_probdesc.objid = mtm_probdesc11_monitor8.probdesc_view2monitor
 AND mtm_probdesc11_monitor8.monitor2probdesc = table_monitor.objid 
 AND table_condition.objid = table_probdesc.probdesc2condition
 ;
COMMENT ON TABLE sa.table_monelm_fnl IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_fnl.mon_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_fnl.elm_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_fnl.id_number IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_fnl.dspch_age IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_fnl.total_age IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_fnl."CONDITION" IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_fnl.title IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monelm_fnl.owner_name IS 'Reserved; obsolete';