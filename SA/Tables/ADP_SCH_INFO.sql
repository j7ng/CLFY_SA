CREATE TABLE sa.adp_sch_info (
  type_id NUMBER NOT NULL,
  field_name VARCHAR2(64 BYTE) NOT NULL,
  cmn_type NUMBER NOT NULL,
  db_type NUMBER NOT NULL,
  array_size NUMBER NOT NULL,
  dec_p NUMBER NOT NULL,
  dec_s NUMBER NOT NULL,
  flags NUMBER NOT NULL,
  gen_field_id NUMBER NOT NULL,
  spec_field_id NUMBER NOT NULL,
  fld_default VARCHAR2(255 BYTE),
  comments VARCHAR2(255 BYTE)
);
ALTER TABLE sa.adp_sch_info ADD SUPPLEMENTAL LOG GROUP dmtsora1810783207_0 (array_size, cmn_type, comments, db_type, dec_p, dec_s, field_name, flags, fld_default, gen_field_id, spec_field_id, type_id) ALWAYS;