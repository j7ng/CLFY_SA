CREATE OR REPLACE FUNCTION sa.check_x_parameter
(
  p_v_x_param_name  table_x_parameters.x_param_name%TYPE
 ,p_v_x_param_value table_x_parameters.x_param_value%TYPE
) RETURN BOOLEAN IS
  --
  CURSOR check_x_parameter_cur
  (
    cur_v_x_param_name  table_x_parameters.x_param_name%TYPE
   ,cur_v_x_param_value table_x_parameters.x_param_value%TYPE
  ) IS
    SELECT 1
      FROM sa.table_x_parameters txp
     WHERE txp.x_param_name = cur_v_x_param_name
       AND txp.x_param_value = cur_v_x_param_value;
  --
  check_x_parameter_rec check_x_parameter_cur%ROWTYPE;
  --
  l_b_check_x_parameter BOOLEAN := FALSE;
  --
BEGIN
  --
  IF check_x_parameter_cur%ISOPEN THEN
    --
    CLOSE check_x_parameter_cur;
    --
  END IF;
  --
  OPEN check_x_parameter_cur(cur_v_x_param_name  => p_v_x_param_name
                            ,cur_v_x_param_value => p_v_x_param_value);
  FETCH check_x_parameter_cur
    INTO check_x_parameter_rec;
  --
  IF check_x_parameter_cur%FOUND THEN
    --
    l_b_check_x_parameter := TRUE;
    --
  END IF;
  --
  CLOSE check_x_parameter_cur;
  --
  RETURN(l_b_check_x_parameter);
  --
EXCEPTION
  WHEN others THEN
    --
    IF check_x_parameter_cur%ISOPEN THEN
      --
      CLOSE check_x_parameter_cur;
      --
    END IF;
    --
    raise_application_error(-20000
                           ,'Failure retreiving from TABLE_X_PARAMETERS table with Oracle error: ' || SQLERRM);
    --
END check_x_parameter;
/