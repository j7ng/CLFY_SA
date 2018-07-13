CREATE TABLE sa.table_rpt_param (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  "PARAM" LONG,
  frequency NUMBER,
  printer VARCHAR2(80 BYTE),
  e_mail VARCHAR2(80 BYTE),
  file_name VARCHAR2(255 BYTE),
  suppl_info VARCHAR2(80 BYTE),
  dev NUMBER,
  param2rpt NUMBER(*,0),
  param2user NUMBER(*,0)
);
ALTER TABLE sa.table_rpt_param ADD SUPPLEMENTAL LOG GROUP dmtsora734367028_0 (dev, e_mail, file_name, frequency, objid, param2rpt, param2user, printer, suppl_info, title) ALWAYS;
COMMENT ON TABLE sa.table_rpt_param IS 'EIS object which defines the default output and scheduling options for a report';
COMMENT ON COLUMN sa.table_rpt_param.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_rpt_param.title IS 'Title of the option set';
COMMENT ON COLUMN sa.table_rpt_param."PARAM" IS 'Parameters used in running the report';
COMMENT ON COLUMN sa.table_rpt_param.frequency IS 'Reserved; frequency handled through time bombs in seconds';
COMMENT ON COLUMN sa.table_rpt_param.printer IS 'Printer to which the report will be sent.  Reserved; not used';
COMMENT ON COLUMN sa.table_rpt_param.e_mail IS 'Email address to which the report will be sent if it is emailed.  Reserved; not used';
COMMENT ON COLUMN sa.table_rpt_param.file_name IS 'File name of the file to which the report will be sent.  Reserved; not used';
COMMENT ON COLUMN sa.table_rpt_param.suppl_info IS 'Additional information about the option set.  Reserved; not used';
COMMENT ON COLUMN sa.table_rpt_param.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_rpt_param.param2rpt IS 'Report owning the report parameter set';
COMMENT ON COLUMN sa.table_rpt_param.param2user IS 'User that created/owns the set of parameters';