CREATE TABLE sa.table_part_stats (
  objid NUMBER,
  calc_mtbf VARCHAR2(10 BYTE),
  exhi_mtbf VARCHAR2(10 BYTE),
  mttr VARCHAR2(8 BYTE),
  turns_ratio VARCHAR2(8 BYTE),
  average_usage VARCHAR2(8 BYTE),
  cs_serv_level VARCHAR2(8 BYTE),
  cs_stockout VARCHAR2(8 BYTE),
  all_stockout VARCHAR2(8 BYTE),
  all_serv_level VARCHAR2(8 BYTE),
  pi_date DATE,
  last_cycle_ct DATE,
  next_cycle_ct DATE,
  cs_good_qoh NUMBER,
  cs_good_pct VARCHAR2(8 BYTE),
  field_good_qoh NUMBER,
  field_good_pct VARCHAR2(8 BYTE),
  rtv_qoh NUMBER,
  rtv_pct VARCHAR2(8 BYTE),
  bad_qoh NUMBER,
  bad_pct VARCHAR2(8 BYTE),
  in_transit_qoh NUMBER,
  in_transit_pct VARCHAR2(8 BYTE),
  total_qoh NUMBER,
  open_orders NUMBER,
  open_order_age VARCHAR2(8 BYTE),
  back_orders NUMBER,
  back_order_age VARCHAR2(8 BYTE),
  open_reqs NUMBER,
  open_reqs_age VARCHAR2(8 BYTE),
  cust_qoh NUMBER,
  cust_qoh_age VARCHAR2(8 BYTE),
  dev NUMBER,
  abc_code VARCHAR2(8 BYTE),
  turn_ratio NUMBER(19,4)
);
ALTER TABLE sa.table_part_stats ADD SUPPLEMENTAL LOG GROUP dmtsora829626402_0 (all_serv_level, all_stockout, average_usage, back_orders, back_order_age, bad_pct, bad_qoh, calc_mtbf, cs_good_pct, cs_good_qoh, cs_serv_level, cs_stockout, cust_qoh, cust_qoh_age, dev, exhi_mtbf, field_good_pct, field_good_qoh, in_transit_pct, in_transit_qoh, last_cycle_ct, mttr, next_cycle_ct, objid, open_orders, open_order_age, open_reqs, open_reqs_age, pi_date, rtv_pct, rtv_qoh, total_qoh, turns_ratio) ALWAYS;
ALTER TABLE sa.table_part_stats ADD SUPPLEMENTAL LOG GROUP dmtsora829626402_1 (abc_code, turn_ratio) ALWAYS;
COMMENT ON TABLE sa.table_part_stats IS 'Holds system-wide inventory and performance statistics on products';
COMMENT ON COLUMN sa.table_part_stats.objid IS 'Part_stat internal record number';
COMMENT ON COLUMN sa.table_part_stats.calc_mtbf IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.exhi_mtbf IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.mttr IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.turns_ratio IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.average_usage IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.cs_serv_level IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.cs_stockout IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.all_stockout IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.all_serv_level IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.pi_date IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.last_cycle_ct IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.next_cycle_ct IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.cs_good_qoh IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.cs_good_pct IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.field_good_qoh IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.field_good_pct IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.rtv_qoh IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.rtv_pct IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.bad_qoh IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.bad_pct IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.in_transit_qoh IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.in_transit_pct IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.total_qoh IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.open_orders IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.open_order_age IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.back_orders IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.back_order_age IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.open_reqs IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.open_reqs_age IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.cust_qoh IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_stats.cust_qoh_age IS 'TBD';
COMMENT ON COLUMN sa.table_part_stats.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_part_stats.abc_code IS 'ABC code classification for the mod_level';
COMMENT ON COLUMN sa.table_part_stats.turn_ratio IS 'Part usage for parts included in a cycle count profile';