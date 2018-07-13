CREATE TABLE sa.x_menu_change_log (
  "ACTION" VARCHAR2(30 BYTE),
  orderby NUMBER,
  mkey VARCHAR2(100 BYTE),
  "CATEGORY" VARCHAR2(100 BYTE),
  lang VARCHAR2(50 BYTE),
  new_description VARCHAR2(300 BYTE),
  old_description VARCHAR2(300 BYTE),
  channel VARCHAR2(30 BYTE),
  manufpartclass VARCHAR2(50 BYTE),
  brand_name VARCHAR2(30 BYTE),
  export_from CHAR(30 BYTE),
  export_to CHAR(30 BYTE),
  export_date DATE,
  exported_by VARCHAR2(30 BYTE),
  export_label VARCHAR2(30 BYTE)
);