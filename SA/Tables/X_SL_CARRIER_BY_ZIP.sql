CREATE TABLE sa.x_sl_carrier_by_zip (
  objid NUMBER NOT NULL,
  x_zip_code VARCHAR2(20 BYTE),
  x_parent_id VARCHAR2(30 BYTE),
  PRIMARY KEY (objid)
);