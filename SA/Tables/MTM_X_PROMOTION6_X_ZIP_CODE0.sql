CREATE TABLE sa.mtm_x_promotion6_x_zip_code0 (
  x_promotion2x_zip_code NUMBER(*,0) NOT NULL,
  x_zip_code2x_promotion NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_x_promotion6_x_zip_code0 ADD SUPPLEMENTAL LOG GROUP dmtsora120862783_0 (x_promotion2x_zip_code, x_zip_code2x_promotion) ALWAYS;