CREATE TABLE sa.adp_tbl_oid_unused (
  type_id NUMBER NOT NULL,
  min_obj NUMBER NOT NULL,
  num_obj NUMBER NOT NULL
);
ALTER TABLE sa.adp_tbl_oid_unused ADD SUPPLEMENTAL LOG GROUP dmtsora1655964312_0 (min_obj, num_obj, type_id) ALWAYS;