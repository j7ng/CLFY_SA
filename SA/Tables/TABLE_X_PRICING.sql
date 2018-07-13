CREATE TABLE sa.table_x_pricing (
  objid NUMBER,
  x_start_date DATE,
  x_end_date DATE,
  x_web_link VARCHAR2(100 BYTE),
  x_web_description VARCHAR2(100 BYTE),
  x_retail_price NUMBER(8,2),
  x_type VARCHAR2(10 BYTE),
  x_pricing2part_num NUMBER,
  x_fin_priceline_id NUMBER,
  x_sp_web_description VARCHAR2(100 BYTE),
  x_card_type NUMBER,
  x_special_type VARCHAR2(20 BYTE),
  x_brand_name VARCHAR2(30 BYTE),
  x_channel VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_pricing ADD SUPPLEMENTAL LOG GROUP dmtsora930055490_0 (objid, x_card_type, x_end_date, x_fin_priceline_id, x_pricing2part_num, x_retail_price, x_special_type, x_sp_web_description, x_start_date, x_type, x_web_description, x_web_link) ALWAYS;
COMMENT ON TABLE sa.table_x_pricing IS 'Added by DR For Pricing';
COMMENT ON COLUMN sa.table_x_pricing.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_pricing.x_start_date IS 'Start date for the price';
COMMENT ON COLUMN sa.table_x_pricing.x_end_date IS 'End date for the price';
COMMENT ON COLUMN sa.table_x_pricing.x_web_link IS 'Web link description';
COMMENT ON COLUMN sa.table_x_pricing.x_web_description IS 'Description used by Web.';
COMMENT ON COLUMN sa.table_x_pricing.x_retail_price IS 'Price of the Part Number';
COMMENT ON COLUMN sa.table_x_pricing.x_type IS 'Type of System, WEB, IVR, Clent, All';
COMMENT ON COLUMN sa.table_x_pricing.x_pricing2part_num IS 'Pricing for a part number';
COMMENT ON COLUMN sa.table_x_pricing.x_fin_priceline_id IS 'used for OF interface';
COMMENT ON COLUMN sa.table_x_pricing.x_sp_web_description IS 'Spanish description for pricing item';
COMMENT ON COLUMN sa.table_x_pricing.x_card_type IS 'Card Type';
COMMENT ON COLUMN sa.table_x_pricing.x_special_type IS 'Type of special cards';