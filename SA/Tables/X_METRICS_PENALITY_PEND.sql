CREATE TABLE sa.x_metrics_penality_pend (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_reason VARCHAR2(255 BYTE),
  penal_pend2prog_enrol NUMBER,
  penal_pend2prtnum_penal NUMBER,
  penal_pend2web_user NUMBER
);
ALTER TABLE sa.x_metrics_penality_pend ADD SUPPLEMENTAL LOG GROUP dmtsora1787826708_0 (objid, penal_pend2prog_enrol, penal_pend2prtnum_penal, penal_pend2web_user, x_esn, x_reason) ALWAYS;