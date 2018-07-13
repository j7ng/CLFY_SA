CREATE TABLE sa.x_rpt_activation_react (
  x_service_id VARCHAR2(30 BYTE),
  call_trans_objid NUMBER,
  transdate DATE
);
ALTER TABLE sa.x_rpt_activation_react ADD SUPPLEMENTAL LOG GROUP dmtsora1613453948_0 (call_trans_objid, transdate, x_service_id) ALWAYS;