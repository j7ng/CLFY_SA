CREATE OR REPLACE TYPE sa.job_type AS OBJECT (
job_run_objid         NUMBER,
job_master_id         NUMBER,
error_code            VARCHAR2(100),
error_msg             VARCHAR2(4000),
response              VARCHAR2(1000),
CONSTRUCTOR FUNCTION job_type RETURN SELF AS RESULT,
--
MEMBER FUNCTION create_job_instance( i_job_name           IN    VARCHAR2,
                                     i_status             IN    VARCHAR2,
                                     i_job_run_mode       IN    NUMBER DEFAULT NULL,
                                     i_seq_name           IN    VARCHAR2,
                                     i_owner_name         IN    VARCHAR2 DEFAULT NULL,
                                     i_reason             IN    VARCHAR2 DEFAULT NULL,
                                     i_status_code        IN    VARCHAR2 DEFAULT NULL,
                                     i_sub_sourcesystem   IN    VARCHAR2 DEFAULT NULL )
RETURN NUMBER,
--
MEMBER FUNCTION  update_job_instance
                                   (
                                   i_job_run_objid    IN  NUMBER,
                                   i_owner_name       IN  VARCHAR2 DEFAULT NULL,
                                   i_reason           IN  VARCHAR2 DEFAULT NULL,
                                   i_status           IN  VARCHAR2,
                                   i_status_code      IN  VARCHAR2,
                                   i_sub_sourcesystem IN  VARCHAR2 DEFAULT NULL
                                   )
RETURN VARCHAR2
--
);
/
CREATE OR REPLACE TYPE BODY sa.job_type
AS
CONSTRUCTOR FUNCTION job_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END job_type;
--
MEMBER FUNCTION create_job_instance(
                                     i_job_name           IN    VARCHAR2,
                                     i_status             IN    VARCHAR2,
                                     i_job_run_mode       IN    NUMBER DEFAULT NULL,
                                     i_seq_name           IN    VARCHAR2,
                                     i_owner_name         IN    VARCHAR2 DEFAULT NULL,
                                     i_reason             IN    VARCHAR2 DEFAULT NULL,
                                     i_status_code        IN    VARCHAR2 DEFAULT NULL,
                                     i_sub_sourcesystem   IN    VARCHAR2 DEFAULT NULL )
RETURN NUMBER
IS
  PRAGMA autonomous_transaction;
   jt  job_type := job_type();
BEGIN
  -- Initialize entire jt type with an empty object
  jt := job_type ();
  --
  BEGIN
    SELECT MAX (objid)
    INTO   jt.job_master_id
    FROM   x_job_master
    WHERE  1 = 1
    AND    x_job_name = i_job_name;
    --
    jt.job_run_objid := billing_seq (i_seq_name);
    --
    INSERT
    INTO x_job_run_details
    (
    objid,
    x_scheduled_run_date,
    x_actual_run_date,
    x_insert_date,
    x_status,
    x_job_run_mode,
    x_start_time,
    run_details2job_master,
    owner_name,
    x_reason,
    x_status_code,
    x_sub_sourcesystem
    )
    VALUES
    (
    jt.job_run_objid,
    SYSDATE,
    SYSDATE,
    SYSDATE,
    i_status,
    i_job_run_mode,
    SYSDATE,
    jt.job_master_id,
    i_owner_name,
    i_reason,
    i_status_code,
    i_sub_sourcesystem
    );
    --
    COMMIT;
    RETURN jt.job_run_objid;
  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    jt.job_run_objid  :=  0;
    jt.error_msg      :=  'Failed to insert record into x_job_run_details: '||sqlerrm;
    jt.response       :=  'FAILED';
  END;
END create_job_instance;
--
MEMBER FUNCTION  update_job_instance
                                   (
                                   i_job_run_objid    IN  NUMBER,
                                   i_owner_name       IN  VARCHAR2 DEFAULT NULL,
                                   i_reason           IN  VARCHAR2 DEFAULT NULL,
                                   i_status           IN  VARCHAR2,
                                   i_status_code      IN  VARCHAR2,
                                   i_sub_sourcesystem IN  VARCHAR2 DEFAULT NULL
                                   )
RETURN VARCHAR2
IS
 PRAGMA autonomous_transaction;
 jt  job_type := job_type();
BEGIN
  -- Initialize entire jt type with an empty object
  jt := job_type ();
  --
  UPDATE x_job_run_details
  SET    x_end_time          = SYSDATE,
        x_status            = i_status,
        x_status_code       = i_status_code,
        x_reason            = i_reason,
        owner_name          = i_owner_name,
        x_sub_sourcesystem  = i_sub_sourcesystem
  WHERE  objid               = i_job_run_objid;
  --
  COMMIT;
  --
  jt.response :=  'SUCCESS';
  --
  RETURN jt.response;
  --
EXCEPTION
WHEN OTHERS THEN
 ROLLBACK;
 jt.error_msg      :=  'Failed to insert record into x_job_run_details: '||sqlerrm;
 jt.response       :=  'FAILED';
END update_job_instance;
--
END;
/