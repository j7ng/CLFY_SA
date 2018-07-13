CREATE TABLE sa.table_trnd_inst (
  objid NUMBER,
  start_date DATE,
  frequency NUMBER,
  dev NUMBER,
  trnd_inst2trnd NUMBER(*,0)
);
ALTER TABLE sa.table_trnd_inst ADD SUPPLEMENTAL LOG GROUP dmtsora183998020_0 (dev, frequency, objid, start_date, trnd_inst2trnd) ALWAYS;
COMMENT ON TABLE sa.table_trnd_inst IS 'EIS object which stores a commitment template, which causes trend to run <trigger>';
COMMENT ON COLUMN sa.table_trnd_inst.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_trnd_inst.start_date IS 'Date and/or time the trend is to run';
COMMENT ON COLUMN sa.table_trnd_inst.frequency IS 'How often the trend should run in seconds';
COMMENT ON COLUMN sa.table_trnd_inst.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_trnd_inst.trnd_inst2trnd IS 'Relation to the trend with its queries';