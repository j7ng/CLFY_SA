CREATE TABLE sa.webcsr_scripts_bkp (
  objid NUMBER,
  dev NUMBER,
  x_script_id VARCHAR2(20 BYTE),
  x_script_type VARCHAR2(20 BYTE),
  x_sourcesystem VARCHAR2(20 BYTE),
  x_description VARCHAR2(255 BYTE),
  x_language VARCHAR2(10 BYTE),
  x_technology VARCHAR2(10 BYTE),
  x_script_text VARCHAR2(4000 BYTE),
  x_published_date DATE,
  x_published_by VARCHAR2(30 BYTE),
  x_script_manager_link VARCHAR2(255 BYTE),
  script2bus_org NUMBER
);