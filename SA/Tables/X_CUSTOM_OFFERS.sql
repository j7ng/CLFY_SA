CREATE TABLE sa.x_custom_offers (
  part_number VARCHAR2(40 BYTE),
  offer1_part_number VARCHAR2(40 BYTE),
  offer2_part_number VARCHAR2(40 BYTE),
  offer3_part_number VARCHAR2(40 BYTE),
  plan_speciality VARCHAR2(4 BYTE)
);
COMMENT ON TABLE sa.x_custom_offers IS 'Table to store the tracsize offers that are shown given by part number';
COMMENT ON COLUMN sa.x_custom_offers.part_number IS 'part number that drives the selection of the offers.';
COMMENT ON COLUMN sa.x_custom_offers.offer1_part_number IS 'part number for offer 1';
COMMENT ON COLUMN sa.x_custom_offers.offer2_part_number IS 'part number for offer 2';
COMMENT ON COLUMN sa.x_custom_offers.offer3_part_number IS 'part number for offer 3';
COMMENT ON COLUMN sa.x_custom_offers.plan_speciality IS 'RG Regular |  DM Double Minutes';