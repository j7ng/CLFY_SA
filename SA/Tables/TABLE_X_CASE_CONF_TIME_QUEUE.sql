CREATE TABLE sa.table_x_case_conf_time_queue (
  time_queue2conf_hdr NUMBER NOT NULL,
  hours_open NUMBER NOT NULL,
  time_queue2queue NUMBER NOT NULL
);
COMMENT ON TABLE sa.table_x_case_conf_time_queue IS 'This table holds the configuration for the queues based on age of the case.';
COMMENT ON COLUMN sa.table_x_case_conf_time_queue.time_queue2conf_hdr IS 'Reference to sa.table_x_case_conf_hdr.objid';
COMMENT ON COLUMN sa.table_x_case_conf_time_queue.hours_open IS 'Number of hours since the case was created, Twenty-four-hour time';
COMMENT ON COLUMN sa.table_x_case_conf_time_queue.time_queue2queue IS 'Reference to sa.table_queue.objid';