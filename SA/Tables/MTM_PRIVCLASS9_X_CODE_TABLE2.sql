CREATE TABLE sa.mtm_privclass9_x_code_table2 (
  x_privclass2x_code_table NUMBER(*,0) NOT NULL,
  x_code_table2privclass NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_privclass9_x_code_table2 ADD SUPPLEMENTAL LOG GROUP dmtsora2071771518_0 (x_code_table2privclass, x_privclass2x_code_table) ALWAYS;