CREATE TABLE sa.adp_view_join_info (
  view_type_id NUMBER NOT NULL,
  obj_type_id NUMBER NOT NULL,
  obj_spec_rel_id NUMBER NOT NULL,
  palias VARCHAR2(64 BYTE),
  falias VARCHAR2(64 BYTE),
  comments VARCHAR2(255 BYTE),
  flags NUMBER NOT NULL,
  join_flag NUMBER NOT NULL
);
ALTER TABLE sa.adp_view_join_info ADD SUPPLEMENTAL LOG GROUP dmtsora1005138555_0 (comments, falias, flags, join_flag, obj_spec_rel_id, obj_type_id, palias, view_type_id) ALWAYS;