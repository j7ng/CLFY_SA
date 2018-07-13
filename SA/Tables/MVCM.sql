CREATE TABLE sa.mvcm (
  id_number VARCHAR2(255 BYTE),
  case_type VARCHAR2(30 BYTE),
  title VARCHAR2(80 BYTE),
  status_objid NUMBER,
  carrier_mkt_name VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  phone_model VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  "CONDITION" VARCHAR2(80 BYTE),
  cond_objid NUMBER,
  case_objid NUMBER,
  s_condition VARCHAR2(80 BYTE),
  creation_time DATE,
  x_iccid VARCHAR2(30 BYTE),
  con_rowid ROWID,
  case_rowid ROWID
);