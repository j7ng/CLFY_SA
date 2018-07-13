CREATE TABLE sa.table_prtnum_kp (
  objid NUMBER,
  last_mod_time DATE,
  dev NUMBER,
  prtnum_kp_prnt2keyphrase NUMBER(*,0),
  parent2prtnum_kp NUMBER(*,0),
  prtnum_kp2prtnum_cat NUMBER(*,0),
  prtnum_kp2prtkp_cat NUMBER(*,0)
);
ALTER TABLE sa.table_prtnum_kp ADD SUPPLEMENTAL LOG GROUP dmtsora1729448213_0 (dev, last_mod_time, objid, parent2prtnum_kp, prtnum_kp2prtkp_cat, prtnum_kp2prtnum_cat, prtnum_kp_prnt2keyphrase) ALWAYS;