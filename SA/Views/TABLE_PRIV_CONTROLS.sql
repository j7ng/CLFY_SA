CREATE OR REPLACE FORCE VIEW sa.table_priv_controls (objid,priv_objid,win_objid,win_id,win_name,control_name,control_label,dimmable,win_label,clarify_ver,customer_ver,control_type) AS
select table_control_db.objid, table_privclass.objid,
 table_window_db.objid, table_control_db.win_id,
 table_window_db.title, table_control_db.name,
 table_control_db.title, table_control_db.dimmable,
 table_window_db.dialog_name, table_window_db.ver_clarify,
 table_window_db.ver_customer, table_control_db.type
 from mtm_privclass1_control_db2, table_control_db, table_privclass, table_window_db
 where table_window_db.objid = table_control_db.control2window_db
 AND table_privclass.objid = mtm_privclass1_control_db2.privclass2control_db
 AND mtm_privclass1_control_db2.control_db2privclass = table_control_db.objid 
 ;
COMMENT ON TABLE sa.table_priv_controls IS 'View of controls and their forms.  Used in forms privilege class (743), Disabled Comments (744), Disabled Buttons (745), Readonly forms (746) and Disabled Context Menu Items (747)';
COMMENT ON COLUMN sa.table_priv_controls.objid IS 'Control db internal record number';
COMMENT ON COLUMN sa.table_priv_controls.priv_objid IS 'Privclass internal record number';
COMMENT ON COLUMN sa.table_priv_controls.win_objid IS 'Form db internal record number';
COMMENT ON COLUMN sa.table_priv_controls.win_id IS 'Form ID number';
COMMENT ON COLUMN sa.table_priv_controls.win_name IS 'Form title';
COMMENT ON COLUMN sa.table_priv_controls.control_name IS 'Name of the control';
COMMENT ON COLUMN sa.table_priv_controls.control_label IS 'Displayed label of the control';
COMMENT ON COLUMN sa.table_priv_controls.dimmable IS 'Indicates whether the item can be dimmed by the user; i.e., 0=dimmable, 1=not dimmable';
COMMENT ON COLUMN sa.table_priv_controls.win_label IS 'Name of form';
COMMENT ON COLUMN sa.table_priv_controls.clarify_ver IS 'Clarify baseline version';
COMMENT ON COLUMN sa.table_priv_controls.customer_ver IS 'Customer version; for forms that have been modified';
COMMENT ON COLUMN sa.table_priv_controls.control_type IS 'Type of control; e.g., menubutton, button, etc';