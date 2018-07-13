CREATE TABLE sa.table_server_stats (
  objid NUMBER,
  dev NUMBER,
  server_type VARCHAR2(80 BYTE),
  duration_unit NUMBER,
  obsv_begin_date DATE,
  stat_value NUMBER(19,4),
  create_timestamp DATE,
  arch_ind NUMBER,
  focus_type NUMBER,
  focus_lowid NUMBER,
  st_func2gbst_elm NUMBER,
  st_unit2gbst_elm NUMBER,
  server_stats2server NUMBER
);
ALTER TABLE sa.table_server_stats ADD SUPPLEMENTAL LOG GROUP dmtsora1160747624_0 (arch_ind, create_timestamp, dev, duration_unit, focus_lowid, focus_type, objid, obsv_begin_date, server_stats2server, server_type, stat_value, st_func2gbst_elm, st_unit2gbst_elm) ALWAYS;