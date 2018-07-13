CREATE TABLE sa.mtm_user50_config_itm0 (
  user_prefs2config_itm NUMBER(*,0) NOT NULL,
  config_itm2user NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_user50_config_itm0 ADD SUPPLEMENTAL LOG GROUP dmtsora1302246922_0 (config_itm2user, user_prefs2config_itm) ALWAYS;