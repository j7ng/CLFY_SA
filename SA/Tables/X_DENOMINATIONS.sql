CREATE TABLE sa.x_denominations (
  x_deno2bus_org NUMBER,
  x_deno2part_class NUMBER,
  x_deno2_phone_part NUMBER,
  x_deno_code NUMBER,
  x_deno2_red_part NUMBER
);
ALTER TABLE sa.x_denominations ADD SUPPLEMENTAL LOG GROUP dmtsora1761052794_0 (x_deno2bus_org, x_deno2part_class, x_deno2_phone_part, x_deno2_red_part, x_deno_code) ALWAYS;
COMMENT ON TABLE sa.x_denominations IS 'this table is used to translate the Buy Airtime Denominations into Redemption Cards part numbers.';
COMMENT ON COLUMN sa.x_denominations.x_deno2bus_org IS 'Not used / Obsolete';
COMMENT ON COLUMN sa.x_denominations.x_deno2part_class IS 'Foreign Key to table_part_class, identify the models that use this translation.';
COMMENT ON COLUMN sa.x_denominations.x_deno2_phone_part IS 'Not used / Obsolete';
COMMENT ON COLUMN sa.x_denominations.x_deno_code IS 'Denomination Code for Buy Now - OTA Request.';
COMMENT ON COLUMN sa.x_denominations.x_deno2_red_part IS 'Foreign Key to Part Numberto be Purchase/Redeemed.';