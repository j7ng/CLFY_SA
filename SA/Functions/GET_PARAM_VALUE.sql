CREATE OR REPLACE FUNCTION sa."GET_PARAM_VALUE" ( i_param_name IN VARCHAR2)
  RETURN VARCHAR2 DETERMINISTIC
AS
  c_param_value table_x_parameters.x_param_value%TYPE;

BEGIN
      SELECT x_param_value
      INTO c_param_value
      FROM table_x_parameters
      WHERE x_param_name =  i_param_name
      AND ROWNUM =1;

  RETURN c_param_value;

EXCEPTION
WHEN OTHERS THEN
  c_param_value :=NULL;
  RETURN c_param_value;
END;
/