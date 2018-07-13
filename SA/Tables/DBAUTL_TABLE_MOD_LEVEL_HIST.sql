CREATE TABLE sa.dbautl_table_mod_level_hist (
  objid NUMBER,
  mod_level VARCHAR2(20 BYTE),
  s_mod_level VARCHAR2(20 BYTE),
  "ACTIVE" VARCHAR2(10 BYTE),
  replaces_date DATE,
  eff_date DATE,
  end_date DATE,
  dev NUMBER,
  part_info2part_num NUMBER(*,0),
  part_info2log_info NUMBER(*,0),
  part_info2part_stats NUMBER(*,0),
  replacedpn2mod_level NUMBER(*,0),
  x_timetank VARCHAR2(1 BYTE),
  part_info2inv_ctrl NUMBER,
  config_type NUMBER,
  delete_dt TIMESTAMP,
  delete_by VARCHAR2(50 BYTE)
);