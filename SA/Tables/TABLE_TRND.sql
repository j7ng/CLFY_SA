CREATE TABLE sa.table_trnd (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  output_fmt VARCHAR2(80 BYTE),
  status NUMBER,
  dev NUMBER,
  trnd_1query2query NUMBER(*,0),
  trnd_2query2query NUMBER(*,0),
  trnd_3query2query NUMBER(*,0),
  trnd_4query2query NUMBER(*,0),
  trnd_5query2query NUMBER(*,0),
  trnd_6query2query NUMBER(*,0),
  trnd_7query2query NUMBER(*,0),
  trnd_8query2query NUMBER(*,0),
  trnd_9query2query NUMBER(*,0),
  trnd_10query2query NUMBER(*,0),
  trnd_11query2query NUMBER(*,0),
  trnd_12query2query NUMBER(*,0),
  trnd2user NUMBER(*,0)
);
ALTER TABLE sa.table_trnd ADD SUPPLEMENTAL LOG GROUP dmtsora75523206_0 (dev, objid, output_fmt, status, title, trnd2user, trnd_10query2query, trnd_11query2query, trnd_12query2query, trnd_1query2query, trnd_2query2query, trnd_3query2query, trnd_4query2query, trnd_5query2query, trnd_6query2query, trnd_7query2query, trnd_8query2query, trnd_9query2query) ALWAYS;
COMMENT ON TABLE sa.table_trnd IS 'EIS object which defines the characteristics of a trend';
COMMENT ON COLUMN sa.table_trnd.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_trnd.title IS 'Name of trend';
COMMENT ON COLUMN sa.table_trnd.output_fmt IS 'Will be used to format trend results data. Reserved; future';
COMMENT ON COLUMN sa.table_trnd.status IS 'Current run status of the trend: i.e., 0=never has been run, 1=running, 2=stopped';
COMMENT ON COLUMN sa.table_trnd.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_trnd.trnd_1query2query IS 'First query used in generating the trend';
COMMENT ON COLUMN sa.table_trnd.trnd_2query2query IS 'Second query used in generating the trend';
COMMENT ON COLUMN sa.table_trnd.trnd_3query2query IS 'Third query used in generating the trend';
COMMENT ON COLUMN sa.table_trnd.trnd_4query2query IS 'Fourth query used in generating the trend';
COMMENT ON COLUMN sa.table_trnd.trnd_5query2query IS 'Fifth query used in generating the trend';
COMMENT ON COLUMN sa.table_trnd.trnd_6query2query IS 'Sixth query used in generating the trend';
COMMENT ON COLUMN sa.table_trnd.trnd_7query2query IS 'Seventh query used in generating the trend';
COMMENT ON COLUMN sa.table_trnd.trnd_8query2query IS 'Eighth query used in generating the trend';
COMMENT ON COLUMN sa.table_trnd.trnd_9query2query IS 'Ninth query used in generating the trend';
COMMENT ON COLUMN sa.table_trnd.trnd_10query2query IS 'Tenth query used in generating the trend';
COMMENT ON COLUMN sa.table_trnd.trnd_11query2query IS 'Eleventh query used in generating the trend';
COMMENT ON COLUMN sa.table_trnd.trnd_12query2query IS 'Twelfth query used in generating the trend';
COMMENT ON COLUMN sa.table_trnd.trnd2user IS 'Originator/owner of trend';