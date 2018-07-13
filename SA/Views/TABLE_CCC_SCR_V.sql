CREATE OR REPLACE FORCE VIEW sa.table_ccc_scr_v (objid,curr_s_name,s_curr_s_name,next_s_objid,next_s_name,s_next_s_name,originator_objid,originator_name,s_originator_name) AS
select table_curr_script.objid, table_curr_script.name, table_curr_script.S_name,
 table_next_script.objid, table_next_script.name, table_next_script.S_name,
 table_originator.objid, table_originator.login_name, table_originator.S_login_name
 from table_call_script table_curr_script, table_call_script table_next_script, table_user table_originator
 where table_next_script.objid (+) = table_curr_script.s_next_s2call_script
 AND table_originator.objid (+) = table_curr_script.scr_originator2user
 ;
COMMENT ON TABLE sa.table_ccc_scr_v IS 'Used to display script branch information on forms Script Writer (11300), Script Player (11301) and Script Tester (11302)';
COMMENT ON COLUMN sa.table_ccc_scr_v.objid IS 'Current script internal record number';
COMMENT ON COLUMN sa.table_ccc_scr_v.curr_s_name IS 'Current script name';
COMMENT ON COLUMN sa.table_ccc_scr_v.next_s_objid IS 'Next script internal record number';
COMMENT ON COLUMN sa.table_ccc_scr_v.next_s_name IS 'Next script name';
COMMENT ON COLUMN sa.table_ccc_scr_v.originator_objid IS 'Script originator internal record number';
COMMENT ON COLUMN sa.table_ccc_scr_v.originator_name IS 'Script originator name';