CREATE TABLE sa.mtm_time_zone3_server0 (
  time_zone2server NUMBER NOT NULL,
  server2time_zone NUMBER NOT NULL
);
ALTER TABLE sa.mtm_time_zone3_server0 ADD SUPPLEMENTAL LOG GROUP dmtsora56813659_0 (server2time_zone, time_zone2server) ALWAYS;