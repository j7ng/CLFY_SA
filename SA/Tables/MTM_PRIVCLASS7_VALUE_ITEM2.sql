CREATE TABLE sa.mtm_privclass7_value_item2 (
  privclass2value_item NUMBER(*,0) NOT NULL,
  value_item2privclass NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_privclass7_value_item2 ADD SUPPLEMENTAL LOG GROUP dmtsora615481166_0 (privclass2value_item, value_item2privclass) ALWAYS;