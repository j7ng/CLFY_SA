CREATE TABLE sa.mtm_menu_bar1_rc_config3 (
  menu_bar2rc_config NUMBER(*,0) NOT NULL,
  rc_config2menu_bar NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_menu_bar1_rc_config3 ADD SUPPLEMENTAL LOG GROUP dmtsora1174148673_0 (menu_bar2rc_config, rc_config2menu_bar) ALWAYS;