CREATE TABLE sa.table_job (
  objid NUMBER,
  id_number VARCHAR2(32 BYTE),
  title VARCHAR2(50 BYTE),
  s_title VARCHAR2(50 BYTE),
  job_history LONG,
  arch_ind NUMBER,
  dev NUMBER,
  job2life_cycle NUMBER(*,0),
  job_result2case NUMBER(*,0),
  job_sts2gbst_elm NUMBER(*,0),
  job_state2condition NUMBER(*,0),
  job_owner2user NUMBER(*,0),
  job_wip2wipbin NUMBER(*,0),
  job_originator2user NUMBER(*,0),
  job_prevq2queue NUMBER(*,0),
  job_currq2queue NUMBER(*,0),
  x_min VARCHAR2(30 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_program_objid NUMBER,
  x_web_user_objid NUMBER,
  x_zip VARCHAR2(5 BYTE),
  x_iccid VARCHAR2(30 BYTE),
  x_contact_objid NUMBER,
  x_old_esn VARCHAR2(30 BYTE),
  x_idn_user_created NUMBER(38),
  x_dte_created DATE,
  x_idn_user_change_last NUMBER(38),
  x_dte_change_last DATE
);
ALTER TABLE sa.table_job ADD SUPPLEMENTAL LOG GROUP dmtsora47601272_0 (arch_ind, dev, id_number, job2life_cycle, job_currq2queue, job_originator2user, job_owner2user, job_prevq2queue, job_result2case, job_state2condition, job_sts2gbst_elm, job_wip2wipbin, objid, s_title, title) ALWAYS;
COMMENT ON TABLE sa.table_job IS 'This table is use to schedule an Activation after a Warehouse Exchange Process.';
COMMENT ON COLUMN sa.table_job.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_job.id_number IS 'Unique job number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_job.title IS 'Title of the job';
COMMENT ON COLUMN sa.table_job.job_history IS 'The multi-line field that contains the history of the job';
COMMENT ON COLUMN sa.table_job.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_job.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_job.job2life_cycle IS 'Business process to which the job belongs';
COMMENT ON COLUMN sa.table_job.job_result2case IS 'Reserved; future';
COMMENT ON COLUMN sa.table_job.job_sts2gbst_elm IS 'Status of the job ';
COMMENT ON COLUMN sa.table_job.job_state2condition IS 'The condition of the job';
COMMENT ON COLUMN sa.table_job.job_owner2user IS 'User that owns the job';
COMMENT ON COLUMN sa.table_job.job_wip2wipbin IS 'The WIPbin the job is accepted into';
COMMENT ON COLUMN sa.table_job.job_originator2user IS 'User that originated the job';
COMMENT ON COLUMN sa.table_job.job_prevq2queue IS 'Used to record which queue job was accepted from; for temporary accept';
COMMENT ON COLUMN sa.table_job.job_currq2queue IS 'The queue the job is currently dispatched to';
COMMENT ON COLUMN sa.table_job.x_min IS 'MIN ASSOCIATED WITH THE JOB';
COMMENT ON COLUMN sa.table_job.x_esn IS 'ESN ASSOCIATED WITH THE JOB';
COMMENT ON COLUMN sa.table_job.x_program_objid IS 'OBJID OF THE PROGRAM ASSOCIATED WITH THE JOB';
COMMENT ON COLUMN sa.table_job.x_web_user_objid IS 'OBJID OF THE WEB USER ASSOCIATED WITH THE JOB';
COMMENT ON COLUMN sa.table_job.x_zip IS 'ZIP CODE ASSOCIATED WITH THE JOB';
COMMENT ON COLUMN sa.table_job.x_iccid IS 'ICCID ASSOCIATED WITH THE JOB';
COMMENT ON COLUMN sa.table_job.x_contact_objid IS 'OBJID OF THE CONTACT ASSOCIATED WITH THE JOB';
COMMENT ON COLUMN sa.table_job.x_old_esn IS 'OLD ESN ASSOCIATED WITH THE JOB';
COMMENT ON COLUMN sa.table_job.x_idn_user_created IS 'User who created this record ';
COMMENT ON COLUMN sa.table_job.x_dte_created IS 'Date when this record is created ';
COMMENT ON COLUMN sa.table_job.x_idn_user_change_last IS 'User who last updated this record ';
COMMENT ON COLUMN sa.table_job.x_dte_change_last IS 'Date when this record is last updated ';