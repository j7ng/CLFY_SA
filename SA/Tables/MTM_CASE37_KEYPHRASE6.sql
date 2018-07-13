CREATE TABLE sa.mtm_case37_keyphrase6 (
  case2keyphrase NUMBER(*,0) NOT NULL,
  keyphrase2case NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_case37_keyphrase6 ADD SUPPLEMENTAL LOG GROUP dmtsora1260089899_0 (case2keyphrase, keyphrase2case) ALWAYS;