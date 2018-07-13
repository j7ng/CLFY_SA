CREATE TABLE sa.x_next_avail_carrier (
  x_carrier_id NUMBER NOT NULL
);
ALTER TABLE sa.x_next_avail_carrier ADD SUPPLEMENTAL LOG GROUP dmtsora1724748103_0 (x_carrier_id) ALWAYS;
COMMENT ON TABLE sa.x_next_avail_carrier IS 'List of carrier thar provide inventory at the time of activation, opposite to carriers for which we control the inventory insternally.';
COMMENT ON COLUMN sa.x_next_avail_carrier.x_carrier_id IS 'references the x_carrier_id from table_x_carrier';