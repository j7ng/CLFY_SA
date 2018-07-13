CREATE TABLE sa.mtm_privclass10_x_app_menu0 (
  x_privclass2x_app_menu NUMBER(*,0) NOT NULL,
  x_app_menu2privclass NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_privclass10_x_app_menu0 ADD SUPPLEMENTAL LOG GROUP dmtsora2140248182_0 (x_app_menu2privclass, x_privclass2x_app_menu) ALWAYS;