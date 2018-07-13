CREATE TABLE sa.carrierpref_1 (
  st VARCHAR2(30 BYTE),
  county VARCHAR2(50 BYTE),
  carrier_id NUMBER,
  carrier_name VARCHAR2(255 BYTE),
  carrier_rank VARCHAR2(30 BYTE),
  new_rank VARCHAR2(30 BYTE)
);
ALTER TABLE sa.carrierpref_1 ADD SUPPLEMENTAL LOG GROUP dmtsora81994004_0 (carrier_id, carrier_name, carrier_rank, county, new_rank, st) ALWAYS;