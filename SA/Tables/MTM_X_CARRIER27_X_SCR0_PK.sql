CREATE TABLE sa.mtm_x_carrier27_x_scr0_pk (
  carrier2x_scr NUMBER(*,0) NOT NULL,
  x_scr2x_carrier NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_x_carrier27_x_scr0_pk ADD SUPPLEMENTAL LOG GROUP dmtsora1521680093_0 (carrier2x_scr, x_scr2x_carrier) ALWAYS;