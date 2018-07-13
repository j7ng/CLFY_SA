CREATE TABLE sa.table_x_scripts_hist (
  objid NUMBER,
  x_script_id VARCHAR2(20 BYTE),
  x_revision NUMBER,
  x_change_date DATE,
  x_change_by VARCHAR2(20 BYTE),
  x_script_type VARCHAR2(20 BYTE),
  x_sourcesystem VARCHAR2(20 BYTE),
  x_description VARCHAR2(255 BYTE),
  x_language VARCHAR2(10 BYTE),
  x_technology VARCHAR2(10 BYTE),
  x_script_text VARCHAR2(4000 BYTE),
  x_publish_by VARCHAR2(20 BYTE),
  x_publish_date DATE,
  x_action VARCHAR2(20 BYTE),
  x_action_log VARCHAR2(255 BYTE),
  script_hist2script NUMBER
);
ALTER TABLE sa.table_x_scripts_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1229418774_0 (objid, script_hist2script, x_action, x_action_log, x_change_by, x_change_date, x_description, x_language, x_publish_by, x_publish_date, x_revision, x_script_id, x_script_text, x_script_type, x_sourcesystem, x_technology) ALWAYS;