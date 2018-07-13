CREATE TABLE sa.mtm_queue4_user23 (
  queue2user NUMBER(*,0) NOT NULL,
  user_assigned2queue NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_queue4_user23 ADD SUPPLEMENTAL LOG GROUP dmtsora605174392_0 (queue2user, user_assigned2queue) ALWAYS;