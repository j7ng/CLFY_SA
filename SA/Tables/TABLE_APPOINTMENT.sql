CREATE TABLE sa.table_appointment (
  objid NUMBER,
  description VARCHAR2(255 BYTE),
  start_time DATE,
  end_time DATE,
  duration NUMBER,
  "CONDITION" NUMBER,
  cell_text VARCHAR2(255 BYTE),
  dev NUMBER,
  appt2schedule NUMBER(*,0),
  appt2appt_type NUMBER(*,0),
  appt2sub_type NUMBER(*,0),
  appt2case NUMBER(*,0)
);
ALTER TABLE sa.table_appointment ADD SUPPLEMENTAL LOG GROUP dmtsora1275573564_0 (appt2appt_type, appt2case, appt2schedule, appt2sub_type, cell_text, "CONDITION", description, dev, duration, end_time, objid, start_time) ALWAYS;