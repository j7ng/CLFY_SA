CREATE TABLE sa.x_part_num_notify (
  part_number VARCHAR2(30 BYTE),
  add_date DATE
);
ALTER TABLE sa.x_part_num_notify ADD SUPPLEMENTAL LOG GROUP dmtsora593296223_0 (add_date, part_number) ALWAYS;