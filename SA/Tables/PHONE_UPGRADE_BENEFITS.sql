CREATE TABLE sa.phone_upgrade_benefits (
  "ACTION" VARCHAR2(100 BYTE),
  service_plan_group VARCHAR2(100 BYTE),
  brand_name VARCHAR2(100 BYTE),
  from_balance_metering_id NUMBER(5),
  from_balance_metering VARCHAR2(100 BYTE),
  to_balance_metering_id NUMBER(5),
  to_balance_metering VARCHAR2(100 BYTE),
  get_balance_flag VARCHAR2(10 BYTE),
  get_balance_info VARCHAR2(100 BYTE)
);
COMMENT ON TABLE sa.phone_upgrade_benefits IS 'Hold the scenarios for which is necessary to perform balance inquiry';
COMMENT ON COLUMN sa.phone_upgrade_benefits."ACTION" IS 'Action to be taken example: Transfer units, upgrade';
COMMENT ON COLUMN sa.phone_upgrade_benefits.service_plan_group IS 'Service plan group related with the service installed in the part serial number';
COMMENT ON COLUMN sa.phone_upgrade_benefits.brand_name IS 'Brand Name or Organization';
COMMENT ON COLUMN sa.phone_upgrade_benefits.from_balance_metering_id IS 'Balance metering id mapped to x_usage_host';
COMMENT ON COLUMN sa.phone_upgrade_benefits.from_balance_metering IS 'Balance metering defined for the part class in the original part serial number';
COMMENT ON COLUMN sa.phone_upgrade_benefits.to_balance_metering_id IS 'Balance metering id mapped to x_usage_host';
COMMENT ON COLUMN sa.phone_upgrade_benefits.to_balance_metering IS 'Balance metering defined for the part class in the target part serial number';
COMMENT ON COLUMN sa.phone_upgrade_benefits.get_balance_flag IS 'Flag to determine balance inquiry needed or not';
COMMENT ON COLUMN sa.phone_upgrade_benefits.get_balance_info IS 'Field to determine how to get balance';