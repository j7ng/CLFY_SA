CREATE TABLE sa.ubi_page_ele (
  element_id NUMBER,
  config_objid NUMBER,
  balance_element VARCHAR2(30 BYTE),
  html_type VARCHAR2(30 BYTE),
  html_label VARCHAR2(30 BYTE),
  source_system VARCHAR2(30 BYTE),
  lang VARCHAR2(30 BYTE),
  display_order NUMBER,
  parent_element NUMBER,
  display_unit VARCHAR2(30 BYTE),
  display_row NUMBER,
  display_col NUMBER,
  overwrite_val_with VARCHAR2(30 BYTE)
);
COMMENT ON COLUMN sa.ubi_page_ele.html_type IS 'SECTION - This is a header and content box,SCRIPT_CONTENT - This is an area that contains text like a div or p tag,DISPLAY_FIELD - This is UBI label/value field';
COMMENT ON COLUMN sa.ubi_page_ele.display_unit IS 'This is the value that we need to convert the value to - KB,MB,GB,UNITS,Money, etc.';
COMMENT ON COLUMN sa.ubi_page_ele.overwrite_val_with IS 'A value here will overwrite whatever comes back from the database';