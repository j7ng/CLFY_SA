CREATE TABLE sa.table_svc_rqst (
  objid NUMBER,
  dev NUMBER,
  "ID" VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  "TYPE" NUMBER,
  svc_name VARCHAR2(128 BYTE),
  duration NUMBER,
  max_retries NUMBER,
  retry_interval NUMBER,
  cb_exesub NUMBER,
  sub_service VARCHAR2(30 BYTE),
  sub_field VARCHAR2(64 BYTE),
  use_elapsed NUMBER,
  svc_rqst2rqst_def NUMBER
);
ALTER TABLE sa.table_svc_rqst ADD SUPPLEMENTAL LOG GROUP dmtsora629265363_0 (cb_exesub, description, dev, duration, "ID", max_retries, objid, retry_interval, sub_field, sub_service, svc_name, svc_rqst2rqst_def, "TYPE", use_elapsed) ALWAYS;
COMMENT ON TABLE sa.table_svc_rqst IS 'Contains one instance for each service request';
COMMENT ON COLUMN sa.table_svc_rqst.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_svc_rqst.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_svc_rqst."ID" IS 'Function ID';
COMMENT ON COLUMN sa.table_svc_rqst.description IS 'A description of the request';
COMMENT ON COLUMN sa.table_svc_rqst."TYPE" IS '0 = Action, 1 = Null, 2 = Fallout, 3 = Raise Error';
COMMENT ON COLUMN sa.table_svc_rqst.svc_name IS 'The Tuxedo service name that this function will call';
COMMENT ON COLUMN sa.table_svc_rqst.duration IS 'Maximum duration (number of seconds before timeout)';
COMMENT ON COLUMN sa.table_svc_rqst.max_retries IS 'Maximum retries';
COMMENT ON COLUMN sa.table_svc_rqst.retry_interval IS 'Retry Interval';
COMMENT ON COLUMN sa.table_svc_rqst.cb_exesub IS '0 = svc_name is Tux service, 1 = svc_name is sub func. name written to subfld, subsvc=Tux service, 2: Tux service = CB_EXESUB, subsvc is CLFY_SUB';
COMMENT ON COLUMN sa.table_svc_rqst.sub_service IS 'COntrolled by cb_exesub, the tux service, or sub-service to call';
COMMENT ON COLUMN sa.table_svc_rqst.sub_field IS 'The FML field that svc_name is written to';
COMMENT ON COLUMN sa.table_svc_rqst.use_elapsed IS 'For forecasting: 0 = use bizcal hours, 1 = use elapsed time';
COMMENT ON COLUMN sa.table_svc_rqst.svc_rqst2rqst_def IS 'The definition that this request is based on';