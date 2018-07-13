CREATE TABLE sa.adp_tbl_oid_base (
  type_id NUMBER NOT NULL,
  obj_num_start NUMBER,
  CONSTRAINT sys_iot_top_863325 PRIMARY KEY (type_id)
)
ORGANIZATION INDEX;
ALTER TABLE sa.adp_tbl_oid_base ADD SUPPLEMENTAL LOG GROUP dmtsora382421923_0 (obj_num_start, type_id) ALWAYS;