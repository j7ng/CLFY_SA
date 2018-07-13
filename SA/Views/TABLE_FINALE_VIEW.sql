CREATE OR REPLACE FORCE VIEW sa.table_finale_view (usr_objid,elm_objid,id_number,title,s_title,"OWNER",s_owner) AS
select table_monitor_member.objid, table_probdesc.objid,
 table_probdesc.id_number, table_probdesc.title, table_probdesc.S_title,
 table_fnl_creator.login_name, table_fnl_creator.S_login_name
 from mtm_user20_monitor0, mtm_probdesc11_monitor8, table_user table_fnl_creator, table_user table_monitor_member, table_probdesc, table_monitor
 where table_fnl_creator.objid = table_probdesc.probdesc_owner2user
 AND table_monitor_member.objid = mtm_user20_monitor0.user_access2monitor
 AND mtm_user20_monitor0.monitor2user = table_monitor.objid 
 AND table_probdesc.objid = mtm_probdesc11_monitor8.probdesc_view2monitor
 AND mtm_probdesc11_monitor8.monitor2probdesc = table_monitor.objid 
 ;
COMMENT ON TABLE sa.table_finale_view IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_finale_view.usr_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_finale_view.elm_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_finale_view.id_number IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_finale_view.title IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_finale_view."OWNER" IS 'Reserved; obsolete';