CREATE OR REPLACE TYPE sa.error_log_type AS OBJECT (
error_code            VARCHAR2(100),
error_msg             VARCHAR2(4000),
response                                 VARCHAR2(1000),
CONSTRUCTOR FUNCTION error_log_type RETURN SELF AS RESULT,
--
MEMBER FUNCTION   ins_job_err(  i_job_id          IN  VARCHAR2,
                                i_request_type    IN  VARCHAR2,
                                i_request         IN  VARCHAR2,
                                i_error_msg       IN  VARCHAR2,
                                i_ordinal         IN  NUMBER,
                                i_status_code     IN  NUMBER,
                                i_reject          IN  NUMBER,
                                i_resent          IN  NUMBER
                             )  RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY sa.error_log_type
AS
CONSTRUCTOR FUNCTION error_log_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END error_log_type;
--
MEMBER FUNCTION ins_job_err  (  i_job_id          IN  VARCHAR2,
                                i_request_type    IN  VARCHAR2,
                                i_request         IN  VARCHAR2,
                                i_error_msg       IN  VARCHAR2,
                                i_ordinal         IN  NUMBER,
                                i_status_code     IN  NUMBER,
                                i_reject          IN  NUMBER,
                                i_resent          IN  NUMBER
                             )
RETURN VARCHAR2
IS
  pragma autonomous_transaction;
  elog  error_log_type  :=  error_log_type();
BEGIN
  INSERT
  INTO x_job_errors
    (
      objid,
      x_source_job_id,
      x_request_type,
      x_request,
      ordinal,
      x_status_code,
      x_reject,
      x_insert_date,
      x_update_date,
      x_resent,
      x_error_msg
    )
    VALUES
    (
      sa.seq_x_job_errors.nextval,
      i_job_id,
      i_request_type,
      i_request,
      i_ordinal,--0,
      i_status_code,-- -200,
      i_reject, -- 0,
      sysdate,
      sysdate,
      0,
      i_error_msg
    );
  elog.response  := 'SUCCESS';

  RETURN elog.response;
  COMMIT;
END ins_job_err;
--
END;
/