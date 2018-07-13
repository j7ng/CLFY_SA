CREATE TABLE sa.x_pcrf_request_log (
  objid NUMBER(22) NOT NULL,
  request_type VARCHAR2(30 BYTE) NOT NULL,
  request_time DATE,
  "MIN" VARCHAR2(50 BYTE),
  esn VARCHAR2(30 BYTE),
  xml_request CLOB,
  response_time DATE,
  xml_response CLOB,
  sourcesystem VARCHAR2(30 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT x_pcrf_request_log_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_pcrf_request_log IS 'Stores logging get and throttle requests from partners.';
COMMENT ON COLUMN sa.x_pcrf_request_log.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.x_pcrf_request_log.request_type IS 'Type of request';
COMMENT ON COLUMN sa.x_pcrf_request_log.request_time IS 'Time Requested';
COMMENT ON COLUMN sa.x_pcrf_request_log."MIN" IS 'Mobile Identification Number';
COMMENT ON COLUMN sa.x_pcrf_request_log.esn IS 'Electronic Serial Number';
COMMENT ON COLUMN sa.x_pcrf_request_log.xml_request IS 'XML code request';
COMMENT ON COLUMN sa.x_pcrf_request_log.response_time IS 'Time required for response';
COMMENT ON COLUMN sa.x_pcrf_request_log.xml_response IS 'XML Response Sent';
COMMENT ON COLUMN sa.x_pcrf_request_log.sourcesystem IS 'Source System';
COMMENT ON COLUMN sa.x_pcrf_request_log.insert_timestamp IS 'Record Inserted Timestamp';
COMMENT ON COLUMN sa.x_pcrf_request_log.update_timestamp IS 'Record Updated Timestamp';