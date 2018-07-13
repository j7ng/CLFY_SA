CREATE TABLE sa.table_asaf_result (
  objid NUMBER,
  start_time DATE,
  end_time DATE,
  avail_min NUMBER,
  after_hour_min NUMBER,
  sched_down_min NUMBER,
  unsched_down_min NUMBER,
  asaf_ratio NUMBER,
  is_current NUMBER,
  period_number NUMBER,
  sort_order NUMBER,
  dev NUMBER,
  asaf_result2user NUMBER(*,0),
  asaf_result2site NUMBER(*,0)
);
ALTER TABLE sa.table_asaf_result ADD SUPPLEMENTAL LOG GROUP dmtsora342644176_0 (after_hour_min, asaf_ratio, asaf_result2site, asaf_result2user, avail_min, dev, end_time, is_current, objid, period_number, sched_down_min, sort_order, start_time, unsched_down_min) ALWAYS;