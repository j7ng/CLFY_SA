CREATE TABLE sa.adp_view_field_info (
  view_type_id NUMBER NOT NULL,
  view_spec_field_id NUMBER NOT NULL,
  from_obj_type NUMBER NOT NULL,
  from_field_id NUMBER NOT NULL,
  "ALIAS" VARCHAR2(64 BYTE),
  comments VARCHAR2(255 BYTE),
  flags NUMBER NOT NULL
);
ALTER TABLE sa.adp_view_field_info ADD SUPPLEMENTAL LOG GROUP dmtsora1312971951_0 ("ALIAS", comments, flags, from_field_id, from_obj_type, view_spec_field_id, view_type_id) ALWAYS;