CREATE TABLE sa.carrierpref (
  st VARCHAR2(30 BYTE),
  county VARCHAR2(50 BYTE),
  carrier_id NUMBER,
  carrier_name VARCHAR2(255 BYTE),
  carrier_rank VARCHAR2(30 BYTE),
  new_rank NUMBER
);
ALTER TABLE sa.carrierpref ADD SUPPLEMENTAL LOG GROUP dmtsora81994004_3 (carrier_id, carrier_name, carrier_rank, county, new_rank, st) ALWAYS;
COMMENT ON TABLE sa.carrierpref IS 'Carrier preference based on State and County (ranking)';
COMMENT ON COLUMN sa.carrierpref.st IS 'State Code';
COMMENT ON COLUMN sa.carrierpref.county IS 'County Name';
COMMENT ON COLUMN sa.carrierpref.carrier_id IS 'References table_x_carrier';
COMMENT ON COLUMN sa.carrierpref.carrier_name IS 'Carrier Name';
COMMENT ON COLUMN sa.carrierpref.carrier_rank IS 'not used';
COMMENT ON COLUMN sa.carrierpref.new_rank IS 'Carrier Rank: 1,2,3...';