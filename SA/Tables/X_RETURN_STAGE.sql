CREATE TABLE sa.x_return_stage (
  return_stage_code VARCHAR2(10 BYTE) NOT NULL,
  description VARCHAR2(50 BYTE),
  refund_flag VARCHAR2(1 BYTE),
  CONSTRAINT x_return_stage_prime_idx PRIMARY KEY (return_stage_code)
);
COMMENT ON COLUMN sa.x_return_stage.return_stage_code IS 'It denotes the Stage code ';
COMMENT ON COLUMN sa.x_return_stage.description IS 'It denotes the description of the stage';
COMMENT ON COLUMN sa.x_return_stage.refund_flag IS 'It determines if the stage belongs to Refund';