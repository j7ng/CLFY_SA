CREATE OR REPLACE FUNCTION sa.get_param_by_name_fun (
   ip_part_class_name     IN   VARCHAR2,
   ip_parameter           IN   VARCHAR2
)
   RETURN VARCHAR2
IS

cursor c1 is
select x_param_value
from table_x_part_class_values v,
     table_x_part_class_params n,
     table_part_class pc
where value2class_param = n.objid
and n.x_param_name =ip_parameter
and v.value2part_class=pc.objid
and pc.name=ip_part_class_name;

r1 c1%rowtype;
return_value varchar2(30);

begin

   open c1;
   fetch c1 into r1;
   if c1%found then
      return_value:=r1. x_param_value;
   else
      return_value:='NOT FOUND';
   end if;
   close c1;

   return return_value;

END get_param_by_name_fun;
/