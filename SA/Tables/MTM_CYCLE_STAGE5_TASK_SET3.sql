CREATE TABLE sa.mtm_cycle_stage5_task_set3 (
  stage2task_set NUMBER(*,0) NOT NULL,
  task_set2cycle_stage NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_cycle_stage5_task_set3 ADD SUPPLEMENTAL LOG GROUP dmtsora208049163_0 (stage2task_set, task_set2cycle_stage) ALWAYS;