CREATE OR REPLACE FORCE VIEW sa.b2b_display_update_view_2 (org_id,part_number,x_technology,description,b2b_description,display_priority,objid,x_retail_price,domain,part_class,x_manufacturer) AS
SELECT Org_Id,
    Part_Number,
    X_Technology,
    table_part_num.Description description,
    table_x_pricing.x_web_description b2b_description,
    nvl(table_x_pricing.x_special_type,'9') display_priority,
    table_x_pricing.objid objid,
    X_Retail_Price,
    Domain,
    table_part_class.Name part_class,
    X_Manufacturer
  FROM table_x_pricing,
    table_part_num,
    table_bus_org,
    table_part_class
  WHERE x_pricing2part_num = table_part_num.objid
  AND x_channel            = 'ECOMMERCE'
  AND domain               = 'PHONES'
  AND x_technology in ('GSM','CDMA')
  AND x_start_date            <= sysdate
  AND x_end_date              >= sysdate
  AND part_num2bus_org         = table_bus_org.objid
  AND part_num2part_class      = table_part_class.objid ;