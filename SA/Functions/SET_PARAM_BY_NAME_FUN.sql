CREATE OR REPLACE FUNCTION sa.set_param_by_name_fun(
   ip_part_class_name IN VARCHAR2,
   ip_parameter IN VARCHAR2,
   ip_value IN VARCHAR2
)
   RETURN VARCHAR2
IS
   CURSOR c1
   IS
   SELECT v.objid value_objid,
      n.objid param_objid,
      pc.objid part_class_objid
   FROM table_x_part_class_values v, table_x_part_class_params n,
   table_part_class pc
   WHERE value2class_param = n.objid
   AND n.x_param_name = ip_parameter
   AND v.value2part_class = pc.objid
   AND pc.name = ip_part_class_name;
   r1 c1%ROWTYPE;
   CURSOR c2
   IS
   SELECT objid
   FROM table_part_class
   WHERE name = ip_part_class_name;
   r2 c2%ROWTYPE;
   CURSOR c3
   IS
   SELECT objid
   FROM table_x_part_class_params
   WHERE x_param_name = ip_parameter;
   r3 c3%ROWTYPE;
   return_value VARCHAR2(30);
   param_objid NUMBER;
BEGIN
   OPEN c3;
   FETCH c3
   INTO r3;
   IF c3%found
   THEN
      param_objid := r3.objid;
   ELSE
      param_objid := sa.seq('x_part_class_params');
      INSERT
      INTO table_x_part_class_params       values(
         param_objid,
         NULL,
         ip_parameter,
         NULL
      );
      COMMIT;
   END IF;
   CLOSE c3;
   OPEN c1;
   FETCH c1
   INTO r1;
   IF c1%found
   THEN
      UPDATE table_x_part_class_values SET x_param_value = ip_value
      WHERE objid = r1.value_objid;
      COMMIT;
      return_value := 'Value Updated';
   ELSE
      OPEN c2;
      FETCH c2
      INTO r2;
      IF c2%found
      THEN
         INSERT
         INTO table_x_part_class_values(
            objid,
            dev,
            x_param_value,
            value2class_param,
            value2part_class
         )         values(
            sa.seq('x_part_class_values'),
            0,
            ip_value,
            param_objid,
            r2.objid
         );
         return_value := 'Value Inserted';
         COMMIT;
      END IF;
      CLOSE c2;
   END IF;
   CLOSE c1;
   RETURN return_value;
END set_param_by_name_fun;
/