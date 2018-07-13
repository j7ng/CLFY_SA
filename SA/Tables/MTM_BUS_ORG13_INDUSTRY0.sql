CREATE TABLE sa.mtm_bus_org13_industry0 (
  bus_industry2industry NUMBER(*,0) NOT NULL,
  bus_industry2bus_org NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_bus_org13_industry0 ADD SUPPLEMENTAL LOG GROUP dmtsora1389433302_0 (bus_industry2bus_org, bus_industry2industry) ALWAYS;