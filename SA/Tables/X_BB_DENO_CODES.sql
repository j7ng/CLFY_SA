CREATE TABLE sa.x_bb_deno_codes (
  x_paycode VARCHAR2(30 BYTE),
  x_denocode NUMBER,
  x_receive_code VARCHAR2(10 BYTE),
  x_req_plan VARCHAR2(100 BYTE),
  x_state VARCHAR2(30 BYTE),
  x_pn_pina VARCHAR2(60 BYTE),
  x_pn_pinm VARCHAR2(60 BYTE),
  x_pn_ph1 VARCHAR2(60 BYTE),
  x_taxable VARCHAR2(1 BYTE)
);
COMMENT ON TABLE sa.x_bb_deno_codes IS 'TO SAVE INFORMATION FOR VALIDATION AND MONEYTRANSAFER FOR STATE AND NEW SAFELINE PLAN';
COMMENT ON COLUMN sa.x_bb_deno_codes.x_paycode IS 'UNIQUE IDENTIFIER FOR CODE FOR TYPE OF PAYMENT';
COMMENT ON COLUMN sa.x_bb_deno_codes.x_denocode IS 'DENOMINATION FOR THE PAYMENT';
COMMENT ON COLUMN sa.x_bb_deno_codes.x_receive_code IS 'RECEIVE GENERATED FOR TYPE OF TRANSACTION ACTIVATION, REDEMPTION';
COMMENT ON COLUMN sa.x_bb_deno_codes.x_req_plan IS 'NAME OF PROGRAM THAT IS REQUIRE ENROLLED';
COMMENT ON COLUMN sa.x_bb_deno_codes.x_state IS 'STATE FOR APPLIED RULE FOR MONEYGRAM';
COMMENT ON COLUMN sa.x_bb_deno_codes.x_pn_pina IS 'AIRTIME CARDS PART NUMBER FOR APPLIED.ONE TIME INITIAL';
COMMENT ON COLUMN sa.x_bb_deno_codes.x_pn_pinm IS 'SOFT PIN CODE PART NUMBER FOR APPLIED MONTHLY';
COMMENT ON COLUMN sa.x_bb_deno_codes.x_pn_ph1 IS 'HANDSET PART NUMBER';
COMMENT ON COLUMN sa.x_bb_deno_codes.x_taxable IS 'to identify is the plan is taxable or not';