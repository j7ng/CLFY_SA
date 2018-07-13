CREATE TABLE sa.mtm_carr_scr_bkup (
  carrier2x_scr NUMBER(*,0) NOT NULL,
  x_scr2x_carrier NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_carr_scr_bkup ADD SUPPLEMENTAL LOG GROUP dmtsora2012149933_0 (carrier2x_scr, x_scr2x_carrier) ALWAYS;