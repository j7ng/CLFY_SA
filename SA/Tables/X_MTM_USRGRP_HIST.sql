CREATE TABLE sa.x_mtm_usrgrp_hist (
  objid NUMBER,
  user2x_sec_grp NUMBER,
  x_sec_grp2user NUMBER,
  mtm_usrgrp_hist2user NUMBER,
  x_change_date DATE,
  osuser VARCHAR2(30 BYTE),
  triggering_record_type VARCHAR2(6 BYTE)
);