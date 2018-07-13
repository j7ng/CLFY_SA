CREATE TABLE sa.mtm_queue7_group3 (
  queue2group NUMBER(*,0) NOT NULL,
  group_access2queue NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_queue7_group3 ADD SUPPLEMENTAL LOG GROUP dmtsora945617653_0 (group_access2queue, queue2group) ALWAYS;