CREATE OR REPLACE FORCE VIEW sa.x_byop_models (manufacturer,"MODEL") AS
SELECT manufacturer,
    model
  FROM
    ( SELECT 'OTHER' manufacturer, 'OTHER' model, 1 col3 FROM dual
    UNION
    SELECT 'SONY' manufacturer, 'OTHER' model, 2 col3 FROM dual
    UNION
    SELECT manufacturer,
      model,
      3 col3
    FROM
      (SELECT DISTINCT pn.part_num2part_class,
        v.x_param_value model
      FROM table_part_num pn,
        table_x_part_class_values v,
        table_x_part_class_params n
      WHERE 1                 =1
      AND v.value2part_class  = pn.part_num2part_class
      AND v.value2class_param = n.objid
      AND x_param_name        = --'DEVICE_ID_ENGLISH'
        'DISPLAY_DESCRIPTION'
      ) tab1,
      ( SELECT DISTINCT pn.part_num2part_class,
        v.x_param_value manufacturer
      FROM table_part_num pn,
        table_x_part_class_values v,
        table_x_part_class_params n
      WHERE 1                 =1
      AND v.value2part_class  = pn.part_num2part_class
      AND v.value2class_param = n.objid
      AND n.x_param_name      ='MANUFACTURER'
      ) tab2
    WHERE TAB1.PART_NUM2PART_CLASS =TAB2.PART_NUM2PART_CLASS
    )
ORDER BY COL3,1,2;