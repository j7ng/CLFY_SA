CREATE TABLE sa.mtm_user97_opportunity38 (
  viewer2opportunity NUMBER NOT NULL,
  opp_viewer2user NUMBER NOT NULL
);
ALTER TABLE sa.mtm_user97_opportunity38 ADD SUPPLEMENTAL LOG GROUP dmtsora500350310_0 (opp_viewer2user, viewer2opportunity) ALWAYS;