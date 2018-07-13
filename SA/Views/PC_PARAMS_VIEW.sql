CREATE OR REPLACE FORCE VIEW sa.pc_params_view (pc_objid,part_class,param_name,param_value) AS
select pc.objid   pc_objid,
         name          part_class ,
         x_param_name  param_name,
         x_param_value param_value
  from table_x_part_class_params pcp,
       table_x_part_class_values pcv,
       table_part_class pc
  where value2part_class(+) = pc.objid
  and pcv.value2class_param = pcp.objid (+);