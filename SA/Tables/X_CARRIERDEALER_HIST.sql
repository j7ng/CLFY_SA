CREATE TABLE sa.x_carrierdealer_hist (
  objid NUMBER,
  x_carrier_id NUMBER,
  x_dealer_id VARCHAR2(80 BYTE),
  x_cd2x_carrier NUMBER,
  x_cd2site NUMBER,
  carrierdealer_hist2carrierdelr NUMBER,
  x_carrierdealer_hist2user NUMBER,
  x_change_date DATE,
  osuser VARCHAR2(30 BYTE),
  triggering_record_type VARCHAR2(6 BYTE)
);
ALTER TABLE sa.x_carrierdealer_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1875013088_0 (carrierdealer_hist2carrierdelr, objid, osuser, triggering_record_type, x_carrierdealer_hist2user, x_carrier_id, x_cd2site, x_cd2x_carrier, x_change_date, x_dealer_id) ALWAYS;
COMMENT ON TABLE sa.x_carrierdealer_hist IS 'This log table tracks the changes to the table: table_x_carrierdealer.';
COMMENT ON COLUMN sa.x_carrierdealer_hist.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_carrierdealer_hist.x_carrier_id IS 'Carrier ID';
COMMENT ON COLUMN sa.x_carrierdealer_hist.x_dealer_id IS 'Dealer ID';
COMMENT ON COLUMN sa.x_carrierdealer_hist.x_cd2x_carrier IS 'Reference table_x_carrier';
COMMENT ON COLUMN sa.x_carrierdealer_hist.x_cd2site IS 'Reference table_site';
COMMENT ON COLUMN sa.x_carrierdealer_hist.carrierdealer_hist2carrierdelr IS 'References table_x_carrierdealer';
COMMENT ON COLUMN sa.x_carrierdealer_hist.x_carrierdealer_hist2user IS 'Reference table_user';
COMMENT ON COLUMN sa.x_carrierdealer_hist.x_change_date IS 'Change Date';
COMMENT ON COLUMN sa.x_carrierdealer_hist.osuser IS 'Operating System User';
COMMENT ON COLUMN sa.x_carrierdealer_hist.triggering_record_type IS 'Type of Change that trigger creation of the record.
';