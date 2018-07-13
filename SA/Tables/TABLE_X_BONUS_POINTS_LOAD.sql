CREATE TABLE sa.table_x_bonus_points_load (
  objid NUMBER NOT NULL,
  x_min VARCHAR2(30 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_points NUMBER(12,2),
  x_reason VARCHAR2(2000 BYTE),
  x_benefit_type VARCHAR2(50 BYTE),
  x_load_dt DATE,
  status VARCHAR2(40 BYTE),
  error_msg VARCHAR2(4000 BYTE),
  CONSTRAINT pk_x_bonus_points_load PRIMARY KEY (objid)
);