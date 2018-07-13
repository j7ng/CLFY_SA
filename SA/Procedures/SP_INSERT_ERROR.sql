CREATE OR REPLACE PROCEDURE sa."SP_INSERT_ERROR" ( i_esn           IN VARCHAR2,
                                              i_sim           IN VARCHAR2,
                                              i_zipcode       IN VARCHAR2,
                                              i_process_step  IN VARCHAR2,
                                              i_error_code    IN VARCHAR2,
                                              i_error_string  IN VARCHAR2
                                               ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF i_error_string IS NULL THEN
    return;
  END IF;

  INSERT
  INTO   x_mvne_error_log
   ( objid,
     x_esn,
     x_sim,
     x_zipcode,
     x_process_step,
     x_error_code,
     x_error_string,
     x_error_date
    )
  VALUES
  (
    seq_x_mvne_error_log.nextval,
    i_esn,
    i_sim,
    i_zipcode,
    i_process_step,
    i_error_code,
    i_error_string  ,
    SYSDATE
  );

  COMMIT;

END sp_insert_error;
/