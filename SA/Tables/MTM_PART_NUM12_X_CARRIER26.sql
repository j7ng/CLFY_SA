CREATE TABLE sa.mtm_part_num12_x_carrier26 (
  x_part_num2x_carrier NUMBER(*,0) NOT NULL,
  x_carrier2part_num NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_part_num12_x_carrier26 ADD SUPPLEMENTAL LOG GROUP dmtsora709998474_0 (x_carrier2part_num, x_part_num2x_carrier) ALWAYS;