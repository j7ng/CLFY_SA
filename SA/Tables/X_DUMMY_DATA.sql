CREATE TABLE sa.x_dummy_data (
  x_esn VARCHAR2(30 BYTE),
  x_sim VARCHAR2(30 BYTE),
  x_pin VARCHAR2(30 BYTE),
  x_smp VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_source_system VARCHAR2(30 BYTE),
  x_org_id VARCHAR2(40 BYTE),
  x_action_type NUMBER,
  x_change_esn VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_dummy_data ADD SUPPLEMENTAL LOG GROUP dmtsora1101060952_0 (x_action_type, x_change_esn, x_esn, x_min, x_org_id, x_pin, x_sim, x_smp, x_source_system) ALWAYS;