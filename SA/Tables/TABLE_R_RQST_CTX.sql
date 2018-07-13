CREATE TABLE sa.table_r_rqst_ctx (
  objid NUMBER,
  dev NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  "NAME" VARCHAR2(30 BYTE),
  s_name VARCHAR2(30 BYTE),
  str_value VARCHAR2(255 BYTE),
  value_type NUMBER,
  i_value NUMBER,
  f_value NUMBER,
  d_value NUMBER(19,4),
  r_rqst_ctx2r_rqst NUMBER
);
ALTER TABLE sa.table_r_rqst_ctx ADD SUPPLEMENTAL LOG GROUP dmtsora1519800049_0 (dev, d_value, f_value, i_value, "NAME", objid, r_rqst_ctx2r_rqst, str_value, s_name, s_title, title, value_type) ALWAYS;