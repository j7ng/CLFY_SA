CREATE TABLE sa.mtm_part_class8_x_zipcode_obs (
  x_part_class2zipcode NUMBER NOT NULL,
  x_zipcode2part_class NUMBER NOT NULL,
  x_is_certified VARCHAR2(1 BYTE)
);
ALTER TABLE sa.mtm_part_class8_x_zipcode_obs ADD SUPPLEMENTAL LOG GROUP dmtsora82201505_0 (x_is_certified, x_part_class2zipcode, x_zipcode2part_class) ALWAYS;