CREATE TABLE sa.table_user_touch (
  objid NUMBER,
  dev NUMBER,
  source_type NUMBER,
  source_lowid NUMBER,
  last_touch_time DATE,
  touch_type NUMBER,
  touched_by2user NUMBER
);
ALTER TABLE sa.table_user_touch ADD SUPPLEMENTAL LOG GROUP dmtsora341088014_0 (dev, last_touch_time, objid, source_lowid, source_type, touched_by2user, touch_type) ALWAYS;