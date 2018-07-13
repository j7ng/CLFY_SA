CREATE OR REPLACE PROCEDURE sa."SP_GET_ESN_PARAMETER_VALUE"
(
  p_esn             IN table_part_inst.part_serial_no%TYPE
 ,p_parameter_name  IN table_x_part_class_params.x_param_name%TYPE
 ,p_debug           IN INTEGER DEFAULT 0
 ,p_parameter_value OUT table_x_part_class_values.x_param_value%TYPE
 ,p_error_code      OUT INTEGER
 ,p_error_message   OUT VARCHAR2
) IS
  --
  -----------------------------------------------------------------------------------------
  --$RCSfile: SP_GET_ESN_PARAMETER_VALUE.sql,v $
  --$Revision: 1.1 $
  --$Author: kacosta $
  --$Date: 2012/01/18 22:46:10 $
  --$ $Log: SP_GET_ESN_PARAMETER_VALUE.sql,v $
  --$ Revision 1.1  2012/01/18 22:46:10  kacosta
  --$ CR19554 Enhancement number of calls to sql
  --$
  --$
  -----------------------------------------------------------------------------------------
  --
  CURSOR get_esn_part_information_curs(c_v_esn table_part_inst.part_serial_no%TYPE) IS
    SELECT tpn.x_technology technology
          ,TO_CHAR(tpn.x_data_capable) data_capable
          ,tpn.part_num2part_class part_class_objid
          ,tpc.name class_name
      FROM table_part_inst tpi
      JOIN table_mod_level tml
        ON tpi.n_part_inst2part_mod = tml.objid
      JOIN table_part_num tpn
        ON tml.part_info2part_num = tpn.objid
      JOIN table_part_class tpc
        ON tpn.part_num2part_class = tpc.objid
     WHERE tpi.part_serial_no = c_v_esn;
  --
  get_esn_part_information_rec get_esn_part_information_curs%ROWTYPE;
  --
  CURSOR get_parameter_value_curs
  (
    c_i_part_class_objid table_part_class.objid%TYPE
   ,c_v_parameter_name   table_x_part_class_params.x_param_name%TYPE
  ) IS
    SELECT pcv.x_param_value parameter_value
      FROM table_x_part_class_values pcv
      JOIN table_x_part_class_params pcp
        ON pcv.value2class_param = pcp.objid
     WHERE pcv.value2part_class = c_i_part_class_objid
       AND UPPER(pcp.x_param_name) = UPPER(c_v_parameter_name);
  --
  get_parameter_value_rec get_parameter_value_curs%ROWTYPE;
  --
  l_cv_subprogram_name CONSTANT VARCHAR2(61) := 'phone_pkg.sp_get_esn_parameter_value';
  l_b_debug           BOOLEAN := FALSE;
  l_i_error_code      INTEGER := 0;
  l_v_error_message   VARCHAR2(32767) := 'SUCCESS';
  l_v_position        VARCHAR2(32767) := l_cv_subprogram_name || '.1';
  l_v_note            VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
  l_v_parameter_value table_x_part_class_values.x_param_value%TYPE;
  --
BEGIN
  --
  IF (NVL(p_debug
         ,0) = 1) THEN
    --
    l_b_debug := TRUE;
    --
  END IF;
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    dbms_output.put_line('p_esn           : ' || NVL(p_esn
                                                    ,'Value is null'));
    dbms_output.put_line('p_parameter_name: ' || NVL(p_parameter_name
                                                    ,'Value is null'));
    --
  END IF;
  --
  l_v_position := l_cv_subprogram_name || '.2';
  l_v_note     := 'Opening get_esn_part_information_curs to retrieve part information for the ESN';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  IF get_esn_part_information_curs%ISOPEN THEN
    --
    CLOSE get_esn_part_information_curs;
    --
  END IF;
  --
  OPEN get_esn_part_information_curs(c_v_esn => p_esn);
  FETCH get_esn_part_information_curs
    INTO get_esn_part_information_rec;
  CLOSE get_esn_part_information_curs;
  --
  l_v_position := l_cv_subprogram_name || '.3';
  l_v_note     := 'Check which ESN part information value to retrieve';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  CASE UPPER(p_parameter_name)
    WHEN 'TECHNOLOGY' THEN
      --
      l_v_position := l_cv_subprogram_name || '.4';
      l_v_note     := 'Retreive the ESN technology value';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      l_v_parameter_value := get_esn_part_information_rec.technology;
      --
    WHEN 'DATA_CAPABLE' THEN
      --
      l_v_position := l_cv_subprogram_name || '.5';
      l_v_note     := 'Retreive the ESN data capble value';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      l_v_parameter_value := get_esn_part_information_rec.data_capable;
      --
    WHEN 'CLASS_NAME' THEN
      --
      l_v_position := l_cv_subprogram_name || '.6';
      l_v_note     := 'Retreive the ESN class name value';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      l_v_parameter_value := get_esn_part_information_rec.class_name;
      --
    ELSE
      --
      l_v_position := l_cv_subprogram_name || '.7';
      l_v_note     := 'Retreive the ESN ' || LOWER(p_parameter_name) || ' value';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      IF get_parameter_value_curs%ISOPEN THEN
        --
        CLOSE get_parameter_value_curs;
        --
      END IF;
      --
      OPEN get_parameter_value_curs(c_i_part_class_objid => get_esn_part_information_rec.part_class_objid
                                   ,c_v_parameter_name   => UPPER(p_parameter_name));
      FETCH get_parameter_value_curs
        INTO get_parameter_value_rec;
      CLOSE get_parameter_value_curs;
      --
      l_v_parameter_value := get_parameter_value_rec.parameter_value;
      --
  END CASE;
  --
  l_v_position := l_cv_subprogram_name || '.8';
  l_v_note     := 'End executing ' || l_cv_subprogram_name;
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    dbms_output.put_line('p_parameter_value: ' || NVL(l_v_parameter_value
                                                     ,'Value is null'));
    dbms_output.put_line('p_error_code     : ' || NVL(TO_CHAR(l_i_error_code)
                                                     ,'Value is null'));
    dbms_output.put_line('p_error_message  : ' || NVL(l_v_error_message
                                                     ,'Value is null'));
    --
  END IF;
  --
  p_parameter_value := l_v_parameter_value;
  p_error_code      := l_i_error_code;
  p_error_message   := l_v_error_message;
  --
EXCEPTION
  WHEN others THEN
    --
    p_parameter_value := NULL;
    p_error_code      := SQLCODE;
    p_error_message   := SQLERRM;
    --
    l_v_position := l_cv_subprogram_name || '.9';
    l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_parameter_value: ' || NVL(p_parameter_value
                                                       ,'Value is null'));
      dbms_output.put_line('p_error_code     : ' || NVL(TO_CHAR(p_error_code)
                                                       ,'Value is null'));
      dbms_output.put_line('p_error_message  : ' || NVL(p_error_message
                                                       ,'Value is null'));
      --
    END IF;
    --
    ota_util_pkg.err_log(p_action       => l_v_note
                        ,p_error_date   => SYSDATE
                        ,p_key          => p_esn
                        ,p_program_name => l_v_position
                        ,p_error_text   => p_error_message);
    --
    IF get_esn_part_information_curs%ISOPEN THEN
      --
      CLOSE get_esn_part_information_curs;
      --
    END IF;
    --
    IF get_parameter_value_curs%ISOPEN THEN
      --
      CLOSE get_parameter_value_curs;
      --
    END IF;
    --
END sp_get_esn_parameter_value;
/