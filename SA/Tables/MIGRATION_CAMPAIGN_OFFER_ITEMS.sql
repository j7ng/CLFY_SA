CREATE TABLE sa.migration_campaign_offer_items (
  campaign_name VARCHAR2(200 BYTE),
  parent_item VARCHAR2(200 BYTE),
  item_description VARCHAR2(2000 BYTE),
  item_type VARCHAR2(30 BYTE),
  item_value VARCHAR2(200 BYTE)
);
COMMENT ON COLUMN sa.migration_campaign_offer_items.campaign_name IS 'The offer this item list belongs to these will appear as unordered list items';
COMMENT ON COLUMN sa.migration_campaign_offer_items.item_description IS 'What this will display in the list';
COMMENT ON COLUMN sa.migration_campaign_offer_items.item_type IS 'PROMO_UNITS,FREE_PHONE,etc.';
COMMENT ON COLUMN sa.migration_campaign_offer_items.item_value IS 'An actual value that will be passed at the offer level - promocode, part number, etc.';