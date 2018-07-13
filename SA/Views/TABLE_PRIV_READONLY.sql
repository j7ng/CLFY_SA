CREATE OR REPLACE FORCE VIEW sa.table_priv_readonly (objid,priv_objid,win_objid,win_id,win_name,dimmable,win_label) AS
select table_readonly.objid, table_readonly.readonly2privclass,
 table_window_db.objid, table_window_db.id,
 table_window_db.title, table_window_db.dimmable,
 table_window_db.dialog_name
 from table_readonly, table_window_db
 where table_window_db.objid = table_readonly.readonly2window_db
 AND table_readonly.readonly2privclass IS NOT NULL
 ;
COMMENT ON TABLE sa.table_priv_readonly IS 'Reserved; future';
COMMENT ON COLUMN sa.table_priv_readonly.objid IS 'Readonly internal record number';
COMMENT ON COLUMN sa.table_priv_readonly.priv_objid IS 'Privclass internal record number';
COMMENT ON COLUMN sa.table_priv_readonly.win_objid IS 'Form db internal record number';
COMMENT ON COLUMN sa.table_priv_readonly.win_id IS 'Form ID number';
COMMENT ON COLUMN sa.table_priv_readonly.win_name IS 'Form title';
COMMENT ON COLUMN sa.table_priv_readonly.dimmable IS 'Indicates if user is allowed to make a form readonly; i.e., 0=allowed, 1=not allowed';
COMMENT ON COLUMN sa.table_priv_readonly.win_label IS 'Name of form';