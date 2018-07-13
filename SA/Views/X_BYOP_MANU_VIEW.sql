CREATE OR REPLACE FORCE VIEW sa.x_byop_manu_view (manufacturer) AS
select 'OTHER' manufacturer
    from dual
union all
(
  select distinct ltrim(rtrim(v.x_param_value)) manufacturer
  FROM
       table_x_part_class_values v,
       table_x_part_class_params n
 WHERE 1=1
   AND v.value2class_param = n.objid
   AND n.x_param_name      ='MANUFACTURER'
   AND V.X_PARAM_VALUE NOT IN ('TRACFONE','BYOP','RIM')
union
  select 'SONY' manufacturer
    from dual
);