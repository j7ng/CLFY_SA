CREATE OR REPLACE PROCEDURE sa."SP_SWB_CARR_RATE_PLAN" (
    IP_ESN IN VARCHAR2,
    OP_LAST_RATE_PLAN_SENT OUT TABLE_X_CARRIER_FEATURES.X_RATE_PLAN%TYPE,
    OP_IS_SWB_CARR OUT VARCHAR2,
    OP_ERROR_CODE OUT INTEGER,
    OP_ERROR_MESSAGE OUT VARCHAR2 )
AS
  --- VARIABLES DECLARATION ---
  l_action        VARCHAR2(1000) := '';
  l_error_code    INTEGER        :=0;
  l_error_message VARCHAR2(100)  := '';
  l_exception     EXCEPTION;
BEGIN
  IF ip_esn         IS NULL THEN
    l_error_code    := -20002;
    l_error_message := 'Input ESN is NULL';
    RAISE l_exception;
  END IF;
  sa.carrier_is_swb_rate_plan.sp_swb_carr_rate_plan(ip_esn, null,op_last_rate_plan_sent,op_is_swb_carr,op_error_code,op_error_message);
EXCEPTION
WHEN l_exception THEN
  OP_LAST_RATE_PLAN_SENT := NULL;
  op_is_swb_carr         := NULL;
  op_error_code          := l_error_code;
  op_error_message       := l_error_message;
  -- write to error_table
  ota_util_pkg.err_log(p_action => L_ACTION, p_error_date => SYSDATE, p_key => ip_esn, p_program_name => 'SA.CARRIER_IS_SWB_RATE_PLAN.SP_SWB_CARR_RATE_PLAN', p_error_text => op_error_message );
END sp_swb_carr_rate_plan;
/