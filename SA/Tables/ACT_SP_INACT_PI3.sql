CREATE TABLE sa.act_sp_inact_pi3 (
  x_service_id VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE)
);
ALTER TABLE sa.act_sp_inact_pi3 ADD SUPPLEMENTAL LOG GROUP dmtsora661755677_0 (x_min, x_service_id) ALWAYS;