CREATE TABLE sa.phone_sim_mapping (
  phone_part_number VARCHAR2(30 BYTE),
  sim_part_number VARCHAR2(30 BYTE),
  CONSTRAINT uq_phone_part_number UNIQUE (phone_part_number)
);