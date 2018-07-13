CREATE OR REPLACE FORCE VIEW sa.table_win_control (objid,win_id,win_name,control_name,control_label,dimmable,win_label,clarify_ver,customer_ver,control_type) AS
select table_control_db.objid, table_control_db.win_id,
 table_window_db.title, table_control_db.name,
 table_control_db.title, table_control_db.dimmable,
 table_window_db.dialog_name, table_window_db.ver_clarify,
 table_window_db.ver_customer, table_control_db.type
 from table_control_db, table_window_db
 where table_window_db.objid = table_control_db.control2window_db
 ;
COMMENT ON TABLE sa.table_win_control IS 'Used by form Privilege Class <Privilege Class Name> (743), Disabled Commands (744), Disabled Buttons (745), Readonly forms (746), and Disabled Context Menu Items (747)';
COMMENT ON COLUMN sa.table_win_control.objid IS 'Control db internal record number';
COMMENT ON COLUMN sa.table_win_control.win_id IS 'ID of form in which the control appears';
COMMENT ON COLUMN sa.table_win_control.win_name IS 'Form title';
COMMENT ON COLUMN sa.table_win_control.control_name IS 'Name of the control';
COMMENT ON COLUMN sa.table_win_control.control_label IS 'Displayed label of the control';
COMMENT ON COLUMN sa.table_win_control.dimmable IS 'Indicates whether the item can be dimmed by the user; i.e., 0=dimmable, 1=not dimmable';
COMMENT ON COLUMN sa.table_win_control.win_label IS 'Name of form';
COMMENT ON COLUMN sa.table_win_control.clarify_ver IS 'Clarify baseline version';
COMMENT ON COLUMN sa.table_win_control.customer_ver IS 'Customer version; for forms that have been modified';
COMMENT ON COLUMN sa.table_win_control.control_type IS 'Type of control; e.g., menubutton, button, etc';