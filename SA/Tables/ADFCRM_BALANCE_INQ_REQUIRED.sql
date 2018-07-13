CREATE TABLE sa.adfcrm_balance_inq_required (
  "ACTION" VARCHAR2(100 BYTE) NOT NULL,
  service_plan_group VARCHAR2(100 BYTE) NOT NULL,
  brand_name VARCHAR2(100 BYTE) NOT NULL,
  from_balance_metering VARCHAR2(100 BYTE) NOT NULL,
  to_balance_metering VARCHAR2(100 BYTE) NOT NULL,
  CONSTRAINT adfcrm_balance_inq_required_pk PRIMARY KEY ("ACTION",service_plan_group,brand_name,from_balance_metering,to_balance_metering)
);
COMMENT ON TABLE sa.adfcrm_balance_inq_required IS 'Hold the scenarios for which is necessary to perform balance inquiry';
COMMENT ON COLUMN sa.adfcrm_balance_inq_required."ACTION" IS 'Action to be taken example: Transfer units, upgrade';
COMMENT ON COLUMN sa.adfcrm_balance_inq_required.service_plan_group IS 'Service plan group related with the service installed in the part serial number';
COMMENT ON COLUMN sa.adfcrm_balance_inq_required.brand_name IS 'Brand Name or Organization';
COMMENT ON COLUMN sa.adfcrm_balance_inq_required.from_balance_metering IS 'Balance metering defined for the part class in the original part serial number';
COMMENT ON COLUMN sa.adfcrm_balance_inq_required.to_balance_metering IS 'Balance metering defined for the part class in the target part serial number';