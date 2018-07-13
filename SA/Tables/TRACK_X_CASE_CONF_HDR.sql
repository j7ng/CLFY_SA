CREATE TABLE sa.track_x_case_conf_hdr (
  objid NUMBER,
  x_case_type_old VARCHAR2(30 BYTE),
  x_case_type_new VARCHAR2(30 BYTE),
  x_title_old VARCHAR2(80 BYTE),
  x_title_new VARCHAR2(80 BYTE),
  x_display_title_old VARCHAR2(80 BYTE),
  x_display_title_new VARCHAR2(80 BYTE),
  change_type VARCHAR2(2 BYTE),
  osuser VARCHAR2(30 BYTE),
  db_user VARCHAR2(30 BYTE),
  change_date DATE
);