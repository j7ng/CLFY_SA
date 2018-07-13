CREATE TABLE sa.mtm_mod_level50_lead15 (
  mod_level2lead NUMBER NOT NULL,
  lead2mod_level NUMBER NOT NULL
);
ALTER TABLE sa.mtm_mod_level50_lead15 ADD SUPPLEMENTAL LOG GROUP dmtsora1796865304_0 (lead2mod_level, mod_level2lead) ALWAYS;