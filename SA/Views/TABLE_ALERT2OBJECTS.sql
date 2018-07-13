CREATE OR REPLACE FORCE VIEW sa.table_alert2objects (alert_objid,site_objid,contact_objid,contract_objid,login_name,s_login_name,"ACTIVE",alert_text,alert_end_date,alert_start_date,alert_title,alert_type,"HOT",active_str,hot_str) AS
select table_alert.objid, table_alert.alert2site,
 table_alert.alert2contact, table_alert.alert2contract,
 table_user.login_name, table_user.S_login_name, table_alert.active,
 table_alert.alert_text, table_alert.end_date,
 table_alert.start_date, table_alert.title,
 table_alert.type, table_alert.hot,
 table_alert.title, table_alert.title
 from table_alert, table_user
 where table_user.objid = table_alert.last_update2user
 ;
COMMENT ON TABLE sa.table_alert2objects IS 'Joins alerts with the alerted objects. Used by Select Flashes TAB (Form 8511) and many tabs';
COMMENT ON COLUMN sa.table_alert2objects.alert_objid IS 'Alert internal record number';
COMMENT ON COLUMN sa.table_alert2objects.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_alert2objects.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_alert2objects.contract_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_alert2objects.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_alert2objects."ACTIVE" IS 'Indicates whether alert is active; i.e., 0=inactive, 1=active. In order to fire, an alert must be both effective and active';
COMMENT ON COLUMN sa.table_alert2objects.alert_text IS 'Alert internal record number';
COMMENT ON COLUMN sa.table_alert2objects.alert_end_date IS 'Last date the alert is effective';
COMMENT ON COLUMN sa.table_alert2objects.alert_start_date IS 'Date the alert becomes effective';
COMMENT ON COLUMN sa.table_alert2objects.alert_title IS 'The title of the alert';
COMMENT ON COLUMN sa.table_alert2objects.alert_type IS 'The type of alert';
COMMENT ON COLUMN sa.table_alert2objects."HOT" IS 'Indicates whether the alert is hot; 1=hot, 0=not hot';
COMMENT ON COLUMN sa.table_alert2objects.active_str IS 'Title replaced with "active"/"inactive" indicator';
COMMENT ON COLUMN sa.table_alert2objects.hot_str IS 'Title replaced with "yes"/"no" for hot indicator';