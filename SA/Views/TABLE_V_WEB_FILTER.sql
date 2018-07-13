CREATE OR REPLACE FORCE VIEW sa.table_v_web_filter (objid,title,obj_type,view_type,is_default,web_user_objid) AS
select table_web_filter.objid, table_web_filter.title,
 table_web_filter.obj_type, table_web_filter.view_type,
 table_web_filter.is_default, table_web_filter.web_filter2web_user
 from table_web_filter
 where table_web_filter.web_filter2web_user IS NOT NULL
 ;
COMMENT ON TABLE sa.table_v_web_filter IS 'View of web filter information used in LaunchPad';
COMMENT ON COLUMN sa.table_v_web_filter.objid IS 'Web filter internal record number';
COMMENT ON COLUMN sa.table_v_web_filter.title IS 'The name of the web filter';
COMMENT ON COLUMN sa.table_v_web_filter.obj_type IS 'Object type ID for which the filter is created; e.g., 0=case, 52=site';
COMMENT ON COLUMN sa.table_v_web_filter.view_type IS 'Schema type ID of the view being used for the web filter';
COMMENT ON COLUMN sa.table_v_web_filter.is_default IS 'Indicates whether the filter is the web user s default filter, 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_v_web_filter.web_user_objid IS 'Web_user internal record number';