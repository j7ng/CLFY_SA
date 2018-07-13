CREATE TABLE sa.mtm (
  queue2user NUMBER(*,0) NOT NULL,
  user_assigned2queue NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm ADD SUPPLEMENTAL LOG GROUP dmtsora579203377_0 (queue2user, user_assigned2queue) ALWAYS;