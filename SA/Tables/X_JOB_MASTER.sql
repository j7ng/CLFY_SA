CREATE TABLE sa.x_job_master (
  objid NUMBER NOT NULL,
  x_job_name VARCHAR2(30 BYTE),
  x_job_desc VARCHAR2(255 BYTE),
  x_job_class VARCHAR2(255 BYTE),
  x_job_sourcesystem VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_job_master ADD SUPPLEMENTAL LOG GROUP dmtsora1444443830_0 (objid, x_job_class, x_job_desc, x_job_name, x_job_sourcesystem) ALWAYS;