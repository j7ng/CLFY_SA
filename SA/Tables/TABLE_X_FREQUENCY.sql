CREATE TABLE sa.table_x_frequency (
  objid NUMBER,
  x_frequency NUMBER
);
ALTER TABLE sa.table_x_frequency ADD SUPPLEMENTAL LOG GROUP dmtsora2108180914_0 (objid, x_frequency) ALWAYS;
COMMENT ON TABLE sa.table_x_frequency IS 'Stores the available frequencies for carriers and part numbers.';
COMMENT ON COLUMN sa.table_x_frequency.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_frequency.x_frequency IS 'Carrier/ PartNum frequency';