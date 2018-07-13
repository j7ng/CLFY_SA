CREATE TABLE sa.x_parameters_hist (
  objid NUMBER,
  dev NUMBER,
  x_param_name VARCHAR2(50 BYTE),
  x_param_value VARCHAR2(2000 BYTE),
  x_notes VARCHAR2(255 BYTE),
  x_param_hist2param NUMBER,
  x_text VARCHAR2(2000 BYTE),
  x_param_hist2user NUMBER,
  x_change_date DATE,
  osuser VARCHAR2(30 BYTE),
  email_require_flag VARCHAR2(1 BYTE),
  email_date DATE,
  triggering_record_type VARCHAR2(6 BYTE)
);
ALTER TABLE sa.x_parameters_hist ADD SUPPLEMENTAL LOG GROUP tsora9127964_0 (dev, email_date, email_require_flag, objid, osuser, triggering_record_type, x_change_date, x_notes, x_param_hist2param, x_param_hist2user, x_param_name, x_param_value, x_text) ALWAYS;