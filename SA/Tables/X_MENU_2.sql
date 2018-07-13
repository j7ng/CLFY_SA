CREATE TABLE sa.x_menu_2 (
  orderby NUMBER,
  mkey VARCHAR2(100 BYTE),
  "CATEGORY" VARCHAR2(100 BYTE),
  lang VARCHAR2(50 BYTE),
  description VARCHAR2(300 BYTE),
  channel VARCHAR2(30 BYTE),
  manufpartclass VARCHAR2(50 BYTE),
  brand_name VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_menu_2 IS 'Menu structure table 2,  created after brand separation, it describe the structure of the menues in the technical flows of WENCSR and WEB applications.';
COMMENT ON COLUMN sa.x_menu_2.orderby IS 'Order by sequence';
COMMENT ON COLUMN sa.x_menu_2.mkey IS 'Menu Key, code that describes the menu element.';
COMMENT ON COLUMN sa.x_menu_2."CATEGORY" IS 'Category that describes the menu options';
COMMENT ON COLUMN sa.x_menu_2.lang IS 'Language: ENGLISH, SPANISH';
COMMENT ON COLUMN sa.x_menu_2.description IS 'Description for the Menu Element, this is the value displayed.';
COMMENT ON COLUMN sa.x_menu_2.channel IS 'Channel: WEBCSR, WEB';
COMMENT ON COLUMN sa.x_menu_2.manufpartclass IS 'Part Class Name, menu elements are dependent of the part class selected.';
COMMENT ON COLUMN sa.x_menu_2.brand_name IS 'Brand Name: TRACFONE, NET10, STRAIGHT_TALK';