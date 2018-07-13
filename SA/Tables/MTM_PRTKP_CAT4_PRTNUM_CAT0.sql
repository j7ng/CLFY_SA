CREATE TABLE sa.mtm_prtkp_cat4_prtnum_cat0 (
  prtkp_cat2prtnum_cat NUMBER(*,0) NOT NULL,
  prtnum_cat2prtkp_cat NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_prtkp_cat4_prtnum_cat0 ADD SUPPLEMENTAL LOG GROUP dmtsora1860914429_0 (prtkp_cat2prtnum_cat, prtnum_cat2prtkp_cat) ALWAYS;