CREATE TABLE sa.carriersimpref (
  carrier_name VARCHAR2(255 BYTE),
  "RANK" NUMBER,
  sim_profile VARCHAR2(30 BYTE),
  min_dll_exch NUMBER,
  max_dll_exch NUMBER
);
COMMENT ON TABLE sa.carriersimpref IS 'Sim Profile Available for a Given Carrier Name, with DLL Limitations as some models are not capable of using certain profiles.';
COMMENT ON COLUMN sa.carriersimpref.carrier_name IS 'Carrier Name, References carrier_name in carrierzones table';
COMMENT ON COLUMN sa.carriersimpref."RANK" IS 'Ranking';
COMMENT ON COLUMN sa.carriersimpref.sim_profile IS 'Reference table_part_num, part_number';
COMMENT ON COLUMN sa.carriersimpref.min_dll_exch IS 'Minimum DLL number that cas use the SIM Profile';
COMMENT ON COLUMN sa.carriersimpref.max_dll_exch IS 'Maximum DLL number that cas use the SIM Profile';