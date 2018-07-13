CREATE TABLE sa.table_rsc_rqt_scr (
  objid NUMBER,
  dev NUMBER,
  rsc_rqt_scr2r_rqst NUMBER,
  rsc_rqt_scr2rsrc NUMBER
);
ALTER TABLE sa.table_rsc_rqt_scr ADD SUPPLEMENTAL LOG GROUP dmtsora1593992647_0 (dev, objid, rsc_rqt_scr2rsrc, rsc_rqt_scr2r_rqst) ALWAYS;