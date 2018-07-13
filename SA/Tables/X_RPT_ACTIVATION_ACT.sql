CREATE TABLE sa.x_rpt_activation_act (
  x_service_id VARCHAR2(30 BYTE),
  call_trans_objid NUMBER,
  transdate DATE
);
ALTER TABLE sa.x_rpt_activation_act ADD SUPPLEMENTAL LOG GROUP dmtsora835895843_0 (call_trans_objid, transdate, x_service_id) ALWAYS;