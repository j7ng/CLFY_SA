CREATE TABLE sa.mtm_life_cycle6_task_set2 (
  cycle2task_set NUMBER(*,0) NOT NULL,
  task_set2life_cycle NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_life_cycle6_task_set2 ADD SUPPLEMENTAL LOG GROUP dmtsora1836152339_0 (cycle2task_set, task_set2life_cycle) ALWAYS;