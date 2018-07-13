CREATE TABLE sa.table_n_extramenuitems (
  objid NUMBER,
  dev NUMBER,
  n_menuname VARCHAR2(100 BYTE),
  n_menutext VARCHAR2(100 BYTE),
  n_ischecked NUMBER,
  n_isenabled NUMBER,
  n_isvisible NUMBER,
  n_statusbartext VARCHAR2(255 BYTE),
  n_command VARCHAR2(255 BYTE),
  n_commandtype VARCHAR2(30 BYTE),
  n_arguments VARCHAR2(255 BYTE),
  n_directory VARCHAR2(255 BYTE),
  n_sequencenumber NUMBER,
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE
);
ALTER TABLE sa.table_n_extramenuitems ADD SUPPLEMENTAL LOG GROUP dmtsora651030393_0 (dev, n_arguments, n_command, n_commandtype, n_directory, n_effectivedate, n_expirationdate, n_ischecked, n_isenabled, n_isvisible, n_menuname, n_menutext, n_modificationdate, n_sequencenumber, n_statusbartext, objid) ALWAYS;