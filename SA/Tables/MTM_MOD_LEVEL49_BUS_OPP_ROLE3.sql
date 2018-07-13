CREATE TABLE sa.mtm_mod_level49_bus_opp_role3 (
  mod_level2bus_opp_role NUMBER NOT NULL,
  bus_opp_role2mod_level NUMBER NOT NULL
);
ALTER TABLE sa.mtm_mod_level49_bus_opp_role3 ADD SUPPLEMENTAL LOG GROUP dmtsora2052641948_0 (bus_opp_role2mod_level, mod_level2bus_opp_role) ALWAYS;