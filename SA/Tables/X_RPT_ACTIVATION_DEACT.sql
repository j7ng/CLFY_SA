CREATE TABLE sa.x_rpt_activation_deact (
  call_trans_objid NUMBER
);
ALTER TABLE sa.x_rpt_activation_deact ADD SUPPLEMENTAL LOG GROUP dmtsora1776690133_0 (call_trans_objid) ALWAYS;