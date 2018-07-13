CREATE TABLE sa.mtm_user47_search_control0 (
  search_prefs2search_control NUMBER(*,0) NOT NULL,
  search_prefs2user NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_user47_search_control0 ADD SUPPLEMENTAL LOG GROUP dmtsora159907049_0 (search_prefs2search_control, search_prefs2user) ALWAYS;