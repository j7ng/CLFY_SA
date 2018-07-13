CREATE TABLE sa.table_handset_msrp_tiers (
  objid NUMBER,
  handset_msrp_tier NUMBER,
  tier_price_low NUMBER,
  tier_price_high NUMBER,
  product_type VARCHAR2(50 BYTE),
  price_deductible NUMBER(10,2),
  msrp_tiers2vas_programs NUMBER
);
COMMENT ON TABLE sa.table_handset_msrp_tiers IS 'DEFINES TIERS RELATED TO HANDSET MANUFACTURER SUGGESTED RETAIL PRICE.';
COMMENT ON COLUMN sa.table_handset_msrp_tiers.objid IS 'INTERNAL UNIQUE IDENTIFIER.';
COMMENT ON COLUMN sa.table_handset_msrp_tiers.handset_msrp_tier IS 'HANDSET MSRP TIER NUMBER.';
COMMENT ON COLUMN sa.table_handset_msrp_tiers.tier_price_low IS 'THE LOW PRICE FOR THE TIER.';
COMMENT ON COLUMN sa.table_handset_msrp_tiers.tier_price_high IS 'THE HIGH PRICE FOR THE TIER.';
COMMENT ON COLUMN sa.table_handset_msrp_tiers.product_type IS 'SPECIFIES THE PRODUCT FOR WHICH THE TIER IS AVAILABLE';
COMMENT ON COLUMN sa.table_handset_msrp_tiers.msrp_tiers2vas_programs IS 'VAS Program - Tiers belongs to';