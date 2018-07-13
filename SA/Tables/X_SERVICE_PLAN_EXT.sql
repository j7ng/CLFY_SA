CREATE TABLE sa.x_service_plan_ext (
  sp_objid NUMBER NOT NULL,
  claro_carrier_bucket VARCHAR2(50 BYTE),
  claro_data_bucket VARCHAR2(50 BYTE),
  claro_voice_bucket VARCHAR2(50 BYTE),
  claro_sms_bucket VARCHAR2(50 BYTE),
  tmo_data_bucket VARCHAR2(50 BYTE),
  tmo_voice_bucket VARCHAR2(50 BYTE),
  tmo_sms_bucket VARCHAR2(50 BYTE),
  tmo_dom_bucket VARCHAR2(50 BYTE),
  vzw_data_bucket VARCHAR2(50 BYTE),
  vzw_voice_bucket VARCHAR2(50 BYTE),
  vzw_sms_bucket VARCHAR2(50 BYTE),
  data_bucket_value VARCHAR2(50 BYTE),
  voice_bucket_value VARCHAR2(50 BYTE),
  sms_bucket_value VARCHAR2(50 BYTE),
  dom_bucket_value VARCHAR2(50 BYTE),
  intl_bucket_name VARCHAR2(50 BYTE),
  intl_bucket_value VARCHAR2(50 BYTE)
);
COMMENT ON TABLE sa.x_service_plan_ext IS 'Service plan extension table to hold additional features not created through APEX';
COMMENT ON COLUMN sa.x_service_plan_ext.sp_objid IS 'Service Plan Objid';
COMMENT ON COLUMN sa.x_service_plan_ext.claro_carrier_bucket IS 'Holds the carrier bucket specific to Claro';