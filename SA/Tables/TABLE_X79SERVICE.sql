CREATE TABLE sa.table_x79service (
  objid NUMBER,
  dev NUMBER,
  service_id VARCHAR2(128 BYTE),
  s_service_id VARCHAR2(128 BYTE),
  service_type VARCHAR2(128 BYTE),
  s_service_type VARCHAR2(128 BYTE),
  alarm_status NUMBER,
  usage_state NUMBER,
  description VARCHAR2(255 BYTE),
  server_id NUMBER,
  id_ind NUMBER,
  type_ind NUMBER,
  service2x79part_rev NUMBER,
  defn2x79trfmt_defn NUMBER
);
ALTER TABLE sa.table_x79service ADD SUPPLEMENTAL LOG GROUP dmtsora668805006_0 (alarm_status, defn2x79trfmt_defn, description, dev, id_ind, objid, server_id, service2x79part_rev, service_id, service_type, s_service_id, s_service_type, type_ind, usage_state) ALWAYS;
COMMENT ON TABLE sa.table_x79service IS 'Represents generic telecommunications capabilities that the customer buys or leases from a service provider. Reserved; future';
COMMENT ON COLUMN sa.table_x79service.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x79service.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x79service.service_id IS 'Idenfities the service independent of the Service Alias';
COMMENT ON COLUMN sa.table_x79service.service_type IS 'Identifies the distinguishing characteristics of the service';
COMMENT ON COLUMN sa.table_x79service.alarm_status IS 'Indicates the alarm status of the service: i.e., 0=under repair; 1=critical; 2=major; 3=minor; 4=alarm outstanding in bit string format';
COMMENT ON COLUMN sa.table_x79service.usage_state IS 'Indicates the usage state of the service: i.e., 0=idle; 1=active; 2=busy';
COMMENT ON COLUMN sa.table_x79service.description IS 'Description of the service instance';
COMMENT ON COLUMN sa.table_x79service.server_id IS 'Exchange protocol server ID number';
COMMENT ON COLUMN sa.table_x79service.id_ind IS 'Service_id may be transmitted either as string or integer. This field indicates its data type; i.e., 0=received as string (no data type conversion needed), 1=received as integer (data type conversion needed), default=0';
COMMENT ON COLUMN sa.table_x79service.type_ind IS 'Service_type may be transmitted either as string or integer. This field indicates its data type; i.e., 0=received as string (no data type conversion needed), 1=received as integer (data type conversion needed), default=0';
COMMENT ON COLUMN sa.table_x79service.service2x79part_rev IS 'The generic part revision of the service';
COMMENT ON COLUMN sa.table_x79service.defn2x79trfmt_defn IS 'Specialized trouble report format for the service';