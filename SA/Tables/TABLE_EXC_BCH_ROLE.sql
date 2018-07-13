CREATE TABLE sa.table_exc_bch_role (
  objid NUMBER,
  dev NUMBER,
  role_name VARCHAR2(80 BYTE),
  "ACTIVE" NUMBER,
  focus_type NUMBER,
  server_id NUMBER,
  exc_bch_role2biz_cal_hdr NUMBER,
  exc_bch_role2exchange NUMBER
);
ALTER TABLE sa.table_exc_bch_role ADD SUPPLEMENTAL LOG GROUP dmtsora1052599983_0 ("ACTIVE", dev, exc_bch_role2biz_cal_hdr, exc_bch_role2exchange, focus_type, objid, role_name, server_id) ALWAYS;