CREATE TABLE sa.x_digitalonly_carrier (
  x_carrier_objid NUMBER,
  x_carrier_id NUMBER
);
ALTER TABLE sa.x_digitalonly_carrier ADD SUPPLEMENTAL LOG GROUP dmtsora2144093842_0 (x_carrier_id, x_carrier_objid) ALWAYS;