CREATE TABLE sa.safelink_fee (
  program_name VARCHAR2(200 BYTE),
  connection_fee NUMBER,
  usac_amount NUMBER,
  state_support NUMBER,
  other_fee_1 NUMBER,
  other_fee_2 NUMBER,
  start_date DATE,
  end_date DATE
);
COMMENT ON COLUMN sa.safelink_fee.program_name IS 'PROGRAM_NAME on SAFELINK_FEE table';
COMMENT ON COLUMN sa.safelink_fee.connection_fee IS 'CONNECTION_FEE INTO SAFELINK_FEE';
COMMENT ON COLUMN sa.safelink_fee.usac_amount IS 'USAC_AMOUNT INTO SAFELINK_FEE';
COMMENT ON COLUMN sa.safelink_fee.state_support IS 'STATE_SUPPORT INTO SAFELINK_FEE';
COMMENT ON COLUMN sa.safelink_fee.other_fee_1 IS 'NAME OTHER_FEE_1 SAFELINK_FEE';
COMMENT ON COLUMN sa.safelink_fee.other_fee_2 IS 'OTHER_FEE_2 INTO SAFELINK_FEE';
COMMENT ON COLUMN sa.safelink_fee.start_date IS 'START_DATE INTO SAFELINK_FEE';
COMMENT ON COLUMN sa.safelink_fee.end_date IS 'END_DATE INTO SAFELINK_FEE';