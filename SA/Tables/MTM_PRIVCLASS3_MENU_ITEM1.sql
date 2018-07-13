CREATE TABLE sa.mtm_privclass3_menu_item1 (
  privclass2menu_item NUMBER(*,0) NOT NULL,
  menu_item2privclass NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_privclass3_menu_item1 ADD SUPPLEMENTAL LOG GROUP dmtsora347766313_0 (menu_item2privclass, privclass2menu_item) ALWAYS;