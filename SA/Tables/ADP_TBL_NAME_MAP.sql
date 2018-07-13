CREATE TABLE sa.adp_tbl_name_map (
  type_id NUMBER NOT NULL,
  type_flags NUMBER NOT NULL,
  type_name VARCHAR2(128 BYTE) NOT NULL,
  comments VARCHAR2(255 BYTE),
  obj_group VARCHAR2(255 BYTE),
  "SQL" LONG
);
ALTER TABLE sa.adp_tbl_name_map ADD SUPPLEMENTAL LOG GROUP dmtsora925166881_0 (comments, obj_group, type_flags, type_id, type_name) ALWAYS;