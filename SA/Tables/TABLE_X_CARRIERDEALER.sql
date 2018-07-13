CREATE TABLE sa.table_x_carrierdealer (
  objid NUMBER,
  x_carrier_id NUMBER,
  x_dealer_id VARCHAR2(80 BYTE),
  x_cd2x_carrier NUMBER,
  x_cd2site NUMBER
);
ALTER TABLE sa.table_x_carrierdealer ADD SUPPLEMENTAL LOG GROUP dmtsora445588214_0 (objid, x_carrier_id, x_cd2site, x_cd2x_carrier, x_dealer_id) ALWAYS;
COMMENT ON TABLE sa.table_x_carrierdealer IS 'Holds information that represents dealers and their preferred carriers';
COMMENT ON COLUMN sa.table_x_carrierdealer.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_carrierdealer.x_carrier_id IS 'Carrier Market Identification Number';
COMMENT ON COLUMN sa.table_x_carrierdealer.x_dealer_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_x_carrierdealer.x_cd2x_carrier IS 'Carrier relation to carrierdealer';
COMMENT ON COLUMN sa.table_x_carrierdealer.x_cd2site IS 'Dealer relation to carrierdealer';