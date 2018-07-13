CREATE OR REPLACE FORCE VIEW sa.x_b2b_phone_view (org_id,part_number,x_technology,simprofile,description,x_retail_price,domain,inventory,part_class,manufacturer,display_priority) AS
SELECT Org_Id,
    Part_Number,
    X_Technology,
    decode(instr(part_number,'P4')+instr(part_number,'R4'),0,
    decode(instr(part_number,'P5')+instr(part_number,'R5'),0,
    decode(instr(part_number,'P6')+instr(part_number,'R6'),0,'NA',6),'5'),'4') Simprofile,
    nvl(table_x_pricing.X_WEB_DESCRIPTION,table_part_num.Description) description,
    X_Retail_Price,
    Domain,
    Inventory,
    table_part_class.Name part_class,
    X_Manufacturer,
    nvl(table_x_pricing.x_special_type,'D') display_priority
  FROM table_x_pricing,
    table_part_num,
    table_bus_org,
    table_part_class,
    (SELECT item_no,
      SUM(available) inventory
    FROM tf.tf_iday@ofsprd
   WHERE upper(warehouse) IN
      (SELECT X_PARAM_VALUE
      FROM TABLE_X_PARAMETERS
      WHERE X_PARAM_NAME='B2B_WAREHOUSE'
      )
-- CR16292    WHERE upper(warehouse) ='BP_TFD8_SS'
    GROUP BY item_no
    HAVING SUM(available)>= 100
    ) inv
  WHERE x_pricing2part_num = table_part_num.objid
  AND x_channel            = 'ECOMMERCE'
  AND x_technology         = 'GSM'
  AND domain               = 'PHONES'
  AND (part_number LIKE '%P4%' or part_number like '%P5%' or part_number like '%P6%'
    or part_number LIKE '%R4%' or part_number like '%R5%' or part_number like '%R6%')
  AND x_start_date            <= sysdate
  AND x_end_date              >= sysdate
  AND part_num2bus_org         = table_bus_org.objid
  AND Trim(Inv.Item_no)        = Part_Number
  AND part_num2part_class      = table_part_class.objid
  AND part_num2part_class NOT IN
    (SELECT value2part_class
    FROM table_x_part_class_params,
      table_x_part_class_values
    WHERE value2class_param= table_x_part_class_params.objid
    AND x_param_name       = 'UNLIMITED_PLAN'
    AND x_param_value      = 'NTU'
    )
  UNION
  SELECT Org_Id,
    Part_Number,
    X_Technology,
    'NA' Simprofile,
    nvl(table_x_pricing.X_WEB_DESCRIPTION,table_part_num.Description) description,
    X_Retail_Price,
    Domain,
    Inventory,
    table_part_class.Name part_class,
    X_Manufacturer,
    nvl(table_x_pricing.x_special_type,'D') display_priority
  FROM table_x_pricing,
    table_part_num,
    table_bus_org,
    table_part_class,
    (SELECT item_no,
      SUM(available) inventory
    FROM tf.tf_iday@ofsprd
   WHERE upper(warehouse) IN
      (SELECT X_PARAM_VALUE
      FROM TABLE_X_PARAMETERS
      WHERE X_PARAM_NAME='B2B_WAREHOUSE'
      )
--   CR16292 WHERE upper(warehouse) ='BP_TFD8_SS'
    GROUP BY item_no
    HAVING SUM(available)>= 100
    ) inv
  WHERE x_pricing2part_num     = table_part_num.objid
  AND x_channel                = 'ECOMMERCE'
  AND x_technology             = 'CDMA'
  AND domain                   = 'PHONES'
  AND x_start_date            <= sysdate
  AND x_end_date              >= sysdate
  AND part_num2bus_org         = table_bus_org.objid
  AND Trim(Inv.Item_no)        = Part_Number
  AND part_num2part_class      = table_part_class.objid
  AND part_num2part_class NOT IN
    (SELECT value2part_class
    FROM table_x_part_class_params,
      table_x_part_class_values
    WHERE value2class_param= table_x_part_class_params.objid
    AND x_param_name       = 'UNLIMITED_PLAN'
    AND x_param_value      = 'NTU'
    )
  UNION
  SELECT Org_Id,
    Part_Number,
    X_Technology,
    'NA' Simprofile,
    nvl(table_x_pricing.X_WEB_DESCRIPTION,table_part_num.Description) description,
    X_Retail_Price,
    Domain,
    Inventory,
    table_part_class.Name part_class,
    X_Manufacturer,
    nvl(table_x_pricing.x_special_type,'D') display_priority
  FROM table_x_pricing,
    table_part_num,
    table_bus_org,
    table_part_class,
    (SELECT item_no,
      SUM(available) inventory
    FROM tf.tf_iday@ofsprd
 WHERE upper(warehouse) IN
      (SELECT X_PARAM_VALUE
      FROM TABLE_X_PARAMETERS
      WHERE X_PARAM_NAME='B2B_WAREHOUSE'
      )
-- CR16292 WHERE upper(warehouse) ='BP_TFD8_SS'
    GROUP BY item_no
    HAVING SUM(available)>= 100
    ) inv
  WHERE x_pricing2part_num     = table_part_num.objid
  AND x_channel                = 'ECOMMERCE'
  AND domain                  <> 'PHONES'
  AND part_num2bus_org         = table_bus_org.objid
  AND x_start_date            <= sysdate
  AND x_end_date              >= sysdate
  AND Trim(Inv.Item_no)        = Part_Number
  AND part_num2part_class      = table_part_class.objid
  AND part_num2part_class NOT IN
    (SELECT value2part_class
    FROM table_x_part_class_params,
      table_x_part_class_values
    WHERE value2class_param= table_x_part_class_params.objid
    AND x_param_name       = 'UNLIMITED_PLAN'
    AND x_param_value      = 'NTU'
    )
  UNION
  SELECT 'NTU',
    part_number,
    x_technology,
    '5' simprofile,
    nvl(table_x_pricing.X_WEB_DESCRIPTION,table_part_num.Description) description,
    x_retail_price,
    domain,
    inventory,
    table_part_class.name part_class,
    x_manufacturer,
    nvl(table_x_pricing.x_special_type,'D') display_priority
  FROM table_x_pricing,
    table_part_num ,
    table_bus_org,
    table_part_class,
    table_x_part_class_params,
    table_x_part_class_values,
    (SELECT item_no,
      SUM(available) inventory
    FROM tf.tf_iday@ofsprd
 WHERE upper(warehouse) IN
      (SELECT X_PARAM_VALUE
      FROM TABLE_X_PARAMETERS
      WHERE X_PARAM_NAME='B2B_WAREHOUSE'
      )
-- CR16292 WHERE upper(warehouse) ='BP_TFD8_SS'
    GROUP BY item_no
    HAVING SUM(available)>= 100
    ) inv
  WHERE x_pricing2part_num = table_part_num.objid
  AND x_channel            = 'ECOMMERCE'
  AND domain               = 'PHONES'
  AND x_start_date        <= sysdate
  AND x_end_date          >= sysdate
  AND part_num2bus_org     = table_bus_org.objid
  AND part_num2part_class  = table_part_class.objid
  AND value2part_class     = table_part_class.objid
  AND value2class_param    = table_x_part_class_params.objid
  AND x_param_name         = 'UNLIMITED_PLAN'
  AND x_param_value        = 'NTU'
  AND inv.item_no          = part_number;