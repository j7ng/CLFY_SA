CREATE TABLE sa.mtm_employee13_time_bomb2 (
  recipient2time_bomb NUMBER(*,0) NOT NULL,
  recipient2employee NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_employee13_time_bomb2 ADD SUPPLEMENTAL LOG GROUP dmtsora1155265817_0 (recipient2employee, recipient2time_bomb) ALWAYS;