CREATE TABLE sa.table_x_app_menu (
  objid NUMBER,
  x_menu_item VARCHAR2(100 BYTE),
  x_seq NUMBER,
  x_action VARCHAR2(30 BYTE),
  x_item VARCHAR2(50 BYTE),
  x_value VARCHAR2(50 BYTE),
  x_menu VARCHAR2(50 BYTE)
);
ALTER TABLE sa.table_x_app_menu ADD SUPPLEMENTAL LOG GROUP dmtsora2111520064_0 (objid, x_action, x_item, x_menu, x_menu_item, x_seq, x_value) ALWAYS;