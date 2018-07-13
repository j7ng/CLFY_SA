CREATE TABLE sa.table_proc_forecast (
  objid NUMBER,
  dev NUMBER,
  bizcal_daylength NUMBER,
  top2proc_fc_item NUMBER,
  fc2proc_inst NUMBER
);
ALTER TABLE sa.table_proc_forecast ADD SUPPLEMENTAL LOG GROUP dmtsora1465894398_0 (bizcal_daylength, dev, fc2proc_inst, objid, top2proc_fc_item) ALWAYS;
COMMENT ON TABLE sa.table_proc_forecast IS 'Records a forecast for a process instance';
COMMENT ON COLUMN sa.table_proc_forecast.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_proc_forecast.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_proc_forecast.bizcal_daylength IS 'Length in seconds of a working day from the business calendar';
COMMENT ON COLUMN sa.table_proc_forecast.top2proc_fc_item IS 'The forecast for the top level func group';
COMMENT ON COLUMN sa.table_proc_forecast.fc2proc_inst IS 'The process instance being forecasted';