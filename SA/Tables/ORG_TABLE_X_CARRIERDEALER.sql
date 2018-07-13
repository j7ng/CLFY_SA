CREATE TABLE sa.org_table_x_carrierdealer (
  objid NUMBER,
  x_carrier_id NUMBER,
  x_dealer_id VARCHAR2(80 BYTE),
  x_cd2x_carrier NUMBER,
  x_cd2site NUMBER
);
ALTER TABLE sa.org_table_x_carrierdealer ADD SUPPLEMENTAL LOG GROUP dmtsora290702146_0 (objid, x_carrier_id, x_cd2site, x_cd2x_carrier, x_dealer_id) ALWAYS;