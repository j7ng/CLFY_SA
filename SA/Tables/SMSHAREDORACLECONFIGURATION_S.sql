CREATE TABLE sa.smsharedoracleconfiguration_s (
  namedobject_id_sequenceid_ NUMBER(10),
  namedobject_id_objecttype_ NUMBER(10),
  soconfig_name_ VARCHAR2(512 BYTE),
  soconfig_os_ VARCHAR2(512 BYTE),
  soconfig_sosetting_ NUMBER(10),
  soconfig_kind_ NUMBER(10)
);
ALTER TABLE sa.smsharedoracleconfiguration_s ADD SUPPLEMENTAL LOG GROUP dmtsora567400744_0 (namedobject_id_objecttype_, namedobject_id_sequenceid_, soconfig_kind_, soconfig_name_, soconfig_os_, soconfig_sosetting_) ALWAYS;