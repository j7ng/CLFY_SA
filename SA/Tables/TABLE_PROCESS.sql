CREATE TABLE sa.table_process (
  objid NUMBER,
  dev NUMBER,
  "ID" VARCHAR2(30 BYTE),
  s_id VARCHAR2(30 BYTE),
  description VARCHAR2(255 BYTE),
  duration NUMBER,
  "VERSION" NUMBER,
  status VARCHAR2(20 BYTE),
  focus_object VARCHAR2(64 BYTE),
  bizcal_path VARCHAR2(255 BYTE),
  bizcal_rev_path VARCHAR2(255 BYTE),
  bizcal_filter_list VARCHAR2(255 BYTE),
  bizcal_sqlfrom VARCHAR2(255 BYTE),
  bizcal_sqlwhere VARCHAR2(255 BYTE),
  owner_path VARCHAR2(255 BYTE),
  owner_rev_path VARCHAR2(255 BYTE),
  owner_filter_list VARCHAR2(255 BYTE),
  owner_sqlfrom VARCHAR2(255 BYTE),
  owner_sqlwhere VARCHAR2(255 BYTE),
  forecasting NUMBER
);
ALTER TABLE sa.table_process ADD SUPPLEMENTAL LOG GROUP dmtsora843177766_0 (bizcal_filter_list, bizcal_path, bizcal_rev_path, bizcal_sqlfrom, bizcal_sqlwhere, description, dev, duration, focus_object, forecasting, "ID", objid, owner_filter_list, owner_path, owner_rev_path, owner_sqlfrom, owner_sqlwhere, status, s_id, "VERSION") ALWAYS;
COMMENT ON TABLE sa.table_process IS 'Contains one instance for each generic process';
COMMENT ON COLUMN sa.table_process.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_process.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_process."ID" IS 'Process ID';
COMMENT ON COLUMN sa.table_process.description IS 'A brief description of the nature of the process';
COMMENT ON COLUMN sa.table_process.duration IS 'Max. duration (number of seconds before timeout)';
COMMENT ON COLUMN sa.table_process."VERSION" IS 'Version';
COMMENT ON COLUMN sa.table_process.status IS 'Status of the process - New, Verified, Active, Obsolete';
COMMENT ON COLUMN sa.table_process.focus_object IS 'The focus object of the process';
COMMENT ON COLUMN sa.table_process.bizcal_path IS 'Business calendar path';
COMMENT ON COLUMN sa.table_process.bizcal_rev_path IS 'Business calendar reverse path';
COMMENT ON COLUMN sa.table_process.bizcal_filter_list IS 'Business calendar reverse path filter list';
COMMENT ON COLUMN sa.table_process.bizcal_sqlfrom IS 'FROM clause for business calendar path SQL statement';
COMMENT ON COLUMN sa.table_process.bizcal_sqlwhere IS 'WHERE clause for business calendar path SQL statement';
COMMENT ON COLUMN sa.table_process.owner_path IS 'Owner path';
COMMENT ON COLUMN sa.table_process.owner_rev_path IS 'Owner reverse path';
COMMENT ON COLUMN sa.table_process.owner_filter_list IS 'Owner reverse path filter list';
COMMENT ON COLUMN sa.table_process.owner_sqlfrom IS 'FROM clause for owner path SQL statement';
COMMENT ON COLUMN sa.table_process.owner_sqlwhere IS 'WHERE clause for owner path SQL statement';
COMMENT ON COLUMN sa.table_process.forecasting IS 'Forecasting mode: 0 = None, 1 = Forecast at creation, 2 = Reforecast each step';