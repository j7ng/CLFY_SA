CREATE TABLE sa.mtm_keyphrase4_prtnum_kp1 (
  keyphrasechild2prtnum_kp NUMBER(*,0) NOT NULL,
  prtnum_kp_chld2keyphrase NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_keyphrase4_prtnum_kp1 ADD SUPPLEMENTAL LOG GROUP dmtsora1652280554_0 (keyphrasechild2prtnum_kp, prtnum_kp_chld2keyphrase) ALWAYS;