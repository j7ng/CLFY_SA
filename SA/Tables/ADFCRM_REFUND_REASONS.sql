CREATE TABLE sa.adfcrm_refund_reasons (
  reason_text VARCHAR2(255 BYTE),
  reason_type VARCHAR2(255 BYTE),
  display VARCHAR2(2 BYTE)
);
COMMENT ON TABLE sa.adfcrm_refund_reasons IS 'This table is used to hold refund reasons.';
COMMENT ON COLUMN sa.adfcrm_refund_reasons.reason_text IS 'reason text';
COMMENT ON COLUMN sa.adfcrm_refund_reasons.reason_type IS 'reason type ';
COMMENT ON COLUMN sa.adfcrm_refund_reasons.display IS 'holds yes or no values on displaying reasons ';