CREATE OR REPLACE FORCE VIEW sa.table_priv_menu_item (objid,priv_objid,mbar_objid,menu_bar,menu_tag,dimmable) AS
select table_menu_item.objid, table_privclass.objid,
 table_menu_item.menu_item2menu_bar, table_menu_item.menu_bar,
 table_menu_item.menu_tag, table_menu_item.dimmable
 from mtm_privclass3_menu_item1, table_menu_item, table_privclass
 where table_menu_item.menu_item2menu_bar IS NOT NULL
 AND table_privclass.objid = mtm_privclass3_menu_item1.privclass2menu_item
 AND mtm_privclass3_menu_item1.menu_item2privclass = table_menu_item.objid 
 ;
COMMENT ON TABLE sa.table_priv_menu_item IS 'View of menu bar items. Used in privilege class commands form';
COMMENT ON COLUMN sa.table_priv_menu_item.objid IS 'Menu item internal record number';
COMMENT ON COLUMN sa.table_priv_menu_item.priv_objid IS 'Privclass internal record number';
COMMENT ON COLUMN sa.table_priv_menu_item.mbar_objid IS 'Menu bar internal record number';
COMMENT ON COLUMN sa.table_priv_menu_item.menu_bar IS 'ID of the menu bar for this item';
COMMENT ON COLUMN sa.table_priv_menu_item.menu_tag IS 'ID of the menu item. Used to bind menu item with its callback function';
COMMENT ON COLUMN sa.table_priv_menu_item.dimmable IS 'Indicates whether this menu item can be dimmed or not';