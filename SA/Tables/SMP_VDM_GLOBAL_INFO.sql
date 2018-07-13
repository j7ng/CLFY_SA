CREATE TABLE sa.smp_vdm_global_info (
  service_type VARCHAR2(128 BYTE) NOT NULL,
  service_name VARCHAR2(128 BYTE) NOT NULL,
  property_name VARCHAR2(128 BYTE) NOT NULL,
  property_value VARCHAR2(256 BYTE)
);
ALTER TABLE sa.smp_vdm_global_info ADD SUPPLEMENTAL LOG GROUP dmtsora552292340_0 (property_name, property_value, service_name, service_type) ALWAYS;