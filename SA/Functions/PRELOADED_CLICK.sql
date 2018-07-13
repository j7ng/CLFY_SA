CREATE OR REPLACE FUNCTION sa.PRELOADED_CLICK(
   ip_part_number IN VARCHAR2
)
   RETURN NUMBER
IS

   -- Part number based click plan
   CURSOR c1
   IS
   SELECT table_x_click_plan.objid
   FROM table_x_part_class_values, table_x_click_plan, table_part_num,table_x_part_class_params
   WHERE value2part_class = part_num2part_class
   AND Value2class_Param= table_x_part_class_params.objid
   AND table_x_part_class_params.x_param_name = 'FACTORY_CLICK_ID'
   AND to_number(x_param_value) = table_x_click_plan.x_plan_id
   AND part_number = ip_part_number;

   r1 c1%ROWTYPE;
   v_Return VARCHAR2(200);

BEGIN
   OPEN c1;
   FETCH c1
   INTO r1;
   IF c1%found THEN
     CLOSE c1;
     RETURN to_number(r1.objid);
   ELSE
     CLOSE c1;
     RETURN 0;
   END IF;
END;
/