CREATE OR REPLACE FORCE VIEW sa.table_acd_case_view (case_oid,agent_oid,customer_oid,case_id,agent_name,s_agent_name,agent_id,customer_id,equip_id) AS
select table_case.objid, table_user.objid,
 table_site.objid, table_case.id_number,
 table_user.login_name, table_user.S_login_name, table_user.agent_id,
 table_site.site_id, table_user.equip_id
 from table_case, table_user, table_site
 where table_site.objid = table_case.case_reporter2site
 AND table_user.objid = table_case.case_owner2user
 ;
COMMENT ON TABLE sa.table_acd_case_view IS 'Contains agent information used with ACD';
COMMENT ON COLUMN sa.table_acd_case_view.case_oid IS 'Internal record number';
COMMENT ON COLUMN sa.table_acd_case_view.agent_oid IS 'Internal record number';
COMMENT ON COLUMN sa.table_acd_case_view.customer_oid IS 'Internal record number';
COMMENT ON COLUMN sa.table_acd_case_view.case_id IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_acd_case_view.agent_name IS 'User login name';
COMMENT ON COLUMN sa.table_acd_case_view.agent_id IS 'Used by ACD to identify agent number';
COMMENT ON COLUMN sa.table_acd_case_view.customer_id IS 'Site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_acd_case_view.equip_id IS 'Used by ACD to identify telephone set ID';