CREATE OR REPLACE PROCEDURE sa."SP_UPD_SIM_STATUS_AFTER_EXPIRY" (
    op_err_msg OUT VARCHAR2,
    op_err_code OUT NUMBER)
IS
BEGIN

  UPDATE sa.table_x_sim_inv
  SET x_sim_inv_status   = '252', --SIM VOID
    x_last_update_date   = SYSDATE
  WHERE x_sim_inv_status = '253' -- SIM NEW
  AND SYSDATE            > expiration_date ;

  DBMS_OUTPUT.PUT_lINE ('Total records updated: '||SQL%ROWCOUNT);

  COMMIT;

  op_err_msg  := 'SUCCESS';
  op_err_code := 0;
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_lINE (SQLERRM);

  op_err_msg  := 'FAILED';
  op_err_code := 1;

  RAISE;
END sp_upd_sim_status_after_expiry;
/