CREATE TABLE sa.mtm_keyphrase5_prog_logic2 (
  keyphrase2prog_logic NUMBER(*,0) NOT NULL,
  prog_logic2keyphrase NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_keyphrase5_prog_logic2 ADD SUPPLEMENTAL LOG GROUP dmtsora1964120346_0 (keyphrase2prog_logic, prog_logic2keyphrase) ALWAYS;