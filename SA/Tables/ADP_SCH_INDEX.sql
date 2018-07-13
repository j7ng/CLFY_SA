CREATE TABLE sa.adp_sch_index (
  type_id NUMBER NOT NULL,
  index_name VARCHAR2(64 BYTE) NOT NULL,
  flags NUMBER NOT NULL,
  field_count NUMBER NOT NULL,
  field_names VARCHAR2(255 BYTE) NOT NULL,
  comments VARCHAR2(255 BYTE)
);
ALTER TABLE sa.adp_sch_index ADD SUPPLEMENTAL LOG GROUP dmtsora1907188940_0 (comments, field_count, field_names, flags, index_name, type_id) ALWAYS;