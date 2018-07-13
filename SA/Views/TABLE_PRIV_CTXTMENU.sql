CREATE OR REPLACE FORCE VIEW sa.table_priv_ctxtmenu (objid,priv_objid,ctrl_objid,win_objid,win_id,win_name,control_name,menu_name,menu_label,intval9,win_label,clarify_ver,customer_ver) AS
select table_value_item.objid, table_privclass.objid,
 table_control_db.objid, table_window_db.objid,
 table_window_db.id, table_window_db.title,
 table_control_db.name, table_value_item.value2,
 table_value_item.value1, table_value_item.intval9,
 table_window_db.dialog_name, table_window_db.ver_clarify,
 table_window_db.ver_customer
 from mtm_privclass7_value_item2, table_value_item, table_privclass, table_control_db,
  table_window_db
 where table_window_db.objid = table_control_db.control2window_db
 AND table_control_db.objid = table_value_item.value2control_db
 AND table_window_db.objid = table_value_item.item2window_db
 AND table_privclass.objid = mtm_privclass7_value_item2.privclass2value_item
 AND mtm_privclass7_value_item2.value_item2privclass = table_value_item.objid 
 ;
COMMENT ON TABLE sa.table_priv_ctxtmenu IS 'Used by forms Privilege Class <Privilege Class Name> (743), Disabled Commands (744), Disabled Buttons (745), Readonly Dialogs (746), and Disabled Context Menu Items (747)';
COMMENT ON COLUMN sa.table_priv_ctxtmenu.objid IS 'Value item internal record number';
COMMENT ON COLUMN sa.table_priv_ctxtmenu.priv_objid IS 'Privclass internal record number';
COMMENT ON COLUMN sa.table_priv_ctxtmenu.ctrl_objid IS 'Control db internal record number';
COMMENT ON COLUMN sa.table_priv_ctxtmenu.win_objid IS 'Form db internal record number';
COMMENT ON COLUMN sa.table_priv_ctxtmenu.win_id IS 'Form ID number';
COMMENT ON COLUMN sa.table_priv_ctxtmenu.win_name IS 'Form title';
COMMENT ON COLUMN sa.table_priv_ctxtmenu.control_name IS 'Name of the control';
COMMENT ON COLUMN sa.table_priv_ctxtmenu.menu_name IS 'Name of the context menu item';
COMMENT ON COLUMN sa.table_priv_ctxtmenu.menu_label IS 'Displayed label of the context menu item';
COMMENT ON COLUMN sa.table_priv_ctxtmenu.intval9 IS 'Multi-purpose integer attribute; use depends on type of the control that owns the item';
COMMENT ON COLUMN sa.table_priv_ctxtmenu.win_label IS 'Name of form';
COMMENT ON COLUMN sa.table_priv_ctxtmenu.clarify_ver IS 'Clarify baseline version';
COMMENT ON COLUMN sa.table_priv_ctxtmenu.customer_ver IS 'Customer version; for forms that have been modified';