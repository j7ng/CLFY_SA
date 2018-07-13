CREATE TABLE sa.mtm_stage_task4_task_set0 (
  task_assign2task_set NUMBER(*,0) NOT NULL,
  task_set2stage_task NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_stage_task4_task_set0 ADD SUPPLEMENTAL LOG GROUP dmtsora1581580675_0 (task_assign2task_set, task_set2stage_task) ALWAYS;