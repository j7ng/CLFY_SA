CREATE TABLE sa.x_multi_rate_plan_esns (
  x_esn VARCHAR2(30 BYTE),
  x_priority NUMBER,
  x_service_plan_id NUMBER,
  x_date_added DATE,
  x_reason VARCHAR2(300 BYTE),
  del_flag VARCHAR2(1 BYTE),
  x_product_id VARCHAR2(30 BYTE),
  CONSTRAINT mrpe_unique UNIQUE (x_esn,x_service_plan_id)
);
COMMENT ON TABLE sa.x_multi_rate_plan_esns IS 'This table defines the service plan preference for specific serial numbers.  Its content is maintained by carrier operations.  It is used in IGATE to find carrier features if no record is found other logic is used to find carrier features record.';
COMMENT ON COLUMN sa.x_multi_rate_plan_esns.x_esn IS 'Reference phone s Serial Number';
COMMENT ON COLUMN sa.x_multi_rate_plan_esns.x_priority IS 'Record s priority';
COMMENT ON COLUMN sa.x_multi_rate_plan_esns.x_service_plan_id IS 'Reference to Service Plan Table objid';
COMMENT ON COLUMN sa.x_multi_rate_plan_esns.x_date_added IS 'THE DATE THE ESN INSERTED.';
COMMENT ON COLUMN sa.x_multi_rate_plan_esns.x_reason IS 'CALL_TRANS.X_REASON.';