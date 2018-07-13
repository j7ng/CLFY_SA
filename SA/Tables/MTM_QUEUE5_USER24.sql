CREATE TABLE sa.mtm_queue5_user24 (
  queue_supvr2user NUMBER(*,0) NOT NULL,
  supvr_assigned2queue NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_queue5_user24 ADD SUPPLEMENTAL LOG GROUP dmtsora701852723_0 (queue_supvr2user, supvr_assigned2queue) ALWAYS;