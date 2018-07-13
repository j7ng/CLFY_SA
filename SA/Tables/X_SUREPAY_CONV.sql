CREATE TABLE sa.x_surepay_conv (
  product_id VARCHAR2(50 BYTE),
  objid NUMBER,
  unit_voice NUMBER,
  unit_days NUMBER,
  trans_voice NUMBER,
  trans_text NUMBER,
  trans_data NUMBER,
  trans_days NUMBER,
  start_dt DATE,
  end_dt DATE,
  unit_data NUMBER,
  unit_text NUMBER,
  x_part_number VARCHAR2(30 BYTE),
  active_flag VARCHAR2(1 BYTE),
  safelink_flag VARCHAR2(1 BYTE)
);
COMMENT ON TABLE sa.x_surepay_conv IS 'CONVERSION TABLE FOR SUREPAY VOICE, TEXT AND DATA';
COMMENT ON COLUMN sa.x_surepay_conv.product_id IS 'UNIQUE PRODUCT ID';
COMMENT ON COLUMN sa.x_surepay_conv.objid IS 'INTERNAL RECORD NUMBER';
COMMENT ON COLUMN sa.x_surepay_conv.unit_voice IS 'UNIT VOICE';
COMMENT ON COLUMN sa.x_surepay_conv.unit_days IS 'UNIT DAYS';
COMMENT ON COLUMN sa.x_surepay_conv.trans_voice IS 'TRANSLATED VOICE';
COMMENT ON COLUMN sa.x_surepay_conv.trans_text IS 'TRANSLATED TEXT';
COMMENT ON COLUMN sa.x_surepay_conv.trans_data IS 'TRANSLATED DATA IN MB';
COMMENT ON COLUMN sa.x_surepay_conv.trans_days IS 'TRANSLATED DAYS';
COMMENT ON COLUMN sa.x_surepay_conv.start_dt IS 'START DATE';
COMMENT ON COLUMN sa.x_surepay_conv.end_dt IS 'END DATE';
COMMENT ON COLUMN sa.x_surepay_conv.unit_data IS 'DATA UNITS FOR THE PLAN';
COMMENT ON COLUMN sa.x_surepay_conv.unit_text IS 'TEXT UNITS FOR THE PLAN';
COMMENT ON COLUMN sa.x_surepay_conv.x_part_number IS 'PART NUMBER';
COMMENT ON COLUMN sa.x_surepay_conv.active_flag IS 'ACTIVE_FLAG FOR ENABLE OR DISABLE THE PLAN';