CREATE OR REPLACE PROCEDURE sa."RAISE_ESN_SEQUENCE"
(
  p_esn           IN table_part_inst.part_serial_no%TYPE
 ,p_min           IN table_part_inst.part_serial_no%TYPE DEFAULT NULL
 ,p_sequence      IN table_part_inst.x_sequence%TYPE
 ,p_debug         IN PLS_INTEGER DEFAULT 0
 ,p_error_code    OUT PLS_INTEGER
 ,p_error_message OUT VARCHAR2
) AS
  --
  --********************************************************************************
  --$RCSfile: RAISE_ESN_SEQUENCE.sql,v $
  --$Revision: 1.2 $
  --$Author: kacosta $
  --$Date: 2012/07/31 15:05:54 $
  --$ $Log: RAISE_ESN_SEQUENCE.sql,v $
  --$ Revision 1.2  2012/07/31 15:05:54  kacosta
  --$ CR21133 Provide some self healing for phones with sequence over system
  --$
  --$ Revision 1.1  2012/07/30 18:55:32  kacosta
  --$ CR21133 Provide some self healing for phones with sequence over system
  --$
  --$
  --********************************************************************************
  --
  CURSOR get_esn_tu_log_curs(c_v_esn toppapp.x_tu_log.esn%TYPE) IS
    SELECT "Reason" reason
      FROM toppapp.x_tu_log
     WHERE "Log_Date" > (SYSDATE) - 90
       AND "Action" = '100'
       AND esn = c_v_esn;
  --
  get_esn_tu_log_rec get_esn_tu_log_curs%ROWTYPE;
  --
  l_b_debug              BOOLEAN := FALSE;
  l_b_raise_esn_sequence BOOLEAN := TRUE;
  l_cv_subprogram_name CONSTANT VARCHAR2(30) := 'raise_esn_sequence';
  l_ex_business_error EXCEPTION;
  l_i_error_code       PLS_INTEGER := 0;
  l_n_agent_user_objid table_user.objid%TYPE;
  l_v_error_message    VARCHAR2(32767) := 'SUCCESS';
  l_v_position         VARCHAR2(32767) := l_cv_subprogram_name || '.1';
  l_v_note             VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
  l_v_esn              table_part_inst.part_serial_no%TYPE;
  --
BEGIN
  --
  IF (NVL(p_debug
         ,0) = 0) THEN
    --
    l_b_debug := FALSE;
    --
  ELSE
    --
    l_b_debug := TRUE;
    --
  END IF;
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    dbms_output.put_line('p_esn     : ' || NVL(p_esn
                                              ,'Value is null'));
    dbms_output.put_line('p_min     : ' || NVL(p_min
                                              ,'Value is null'));
    dbms_output.put_line('p_sequence: ' || NVL(TO_CHAR(p_sequence)
                                              ,'Value is null'));
    --
  END IF;
  --
  l_v_position := l_cv_subprogram_name || '.2';
  l_v_note     := 'Verify IN parameter values';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  IF (TRIM(p_esn) IS NULL) THEN
    --
    l_i_error_code    := 1;
    l_v_error_message := 'ESN parameter value is null; ESN must be provided';
    --
    RAISE l_ex_business_error;
    --
  END IF;
  --
  BEGIN
    --
    SELECT tpi.part_serial_no
      INTO l_v_esn
      FROM table_part_inst tpi
     WHERE tpi.part_serial_no = p_esn
       AND tpi.x_domain = 'PHONES';
    --
  EXCEPTION
    WHEN no_data_found THEN
      --
      l_i_error_code    := 2;
      l_v_error_message := 'ESN parameter value is not a valid ESN; valid ESN must be provided';
      --
      RAISE l_ex_business_error;
    WHEN others THEN
      --
      RAISE;
      --
  END;
  --
  IF (p_sequence IS NULL) THEN
    --
    l_i_error_code    := 3;
    l_v_error_message := 'ESN sequence parameter value is null; ESN sequence must be provided';
    --
    RAISE l_ex_business_error;
    --
  END IF;
  --
  l_v_position := l_cv_subprogram_name || '.3';
  l_v_note     := 'Get ESN TU_LOG records where Action is 100 and log date is within the last 90 days';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  IF get_esn_tu_log_curs%ISOPEN THEN
    --
    CLOSE get_esn_tu_log_curs;
    --
  END IF;
  --
  OPEN get_esn_tu_log_curs(c_v_esn => p_esn);
  --
  LOOP
    --
    FETCH get_esn_tu_log_curs
      INTO get_esn_tu_log_rec;
    --
    EXIT WHEN get_esn_tu_log_curs%NOTFOUND;
    --
    l_v_position := l_cv_subprogram_name || '.4';
    l_v_note     := 'ESN TU_LOG record found; check if SEQUENCE RAISED action';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF (get_esn_tu_log_rec.reason LIKE '%SEQUENCE RAISED%') THEN
      --
      l_v_position := l_cv_subprogram_name || '.5';
      l_v_note     := 'SEQUENCE RAISED action found; exit loop';
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        --
      END IF;
      --
      l_b_raise_esn_sequence := FALSE;
      --
      EXIT;
      --
    END IF;
    --
  END LOOP;
  --
  CLOSE get_esn_tu_log_curs;
  --
  l_v_position := l_cv_subprogram_name || '.6';
  l_v_note     := 'Check if SEQUENCE RAISED action TU_LOG record was found';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  IF l_b_raise_esn_sequence THEN
    --
    l_v_position := l_cv_subprogram_name || '.7';
    l_v_note     := 'SEQUENCE RAISED action TU_LOG record was not found; get TOSSUTILITY user objid';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    SELECT objid
      INTO l_n_agent_user_objid
      FROM table_user
     WHERE s_login_name = 'TOSSUTILITY';
    --
    l_v_position := l_cv_subprogram_name || '.8';
    l_v_note     := 'Calling set_counter to increase the sequence';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    set_counter(ip_esn      => p_esn
               ,ip_sequence => p_sequence
               ,ip_agent    => l_n_agent_user_objid
               ,ip_reason   => 'SEQUENCE RAISED');
    --
    l_v_position := l_cv_subprogram_name || '.9';
    l_v_note     := 'Calling toppapp.sp_tu_log insert TU_LOG record';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    toppapp.sp_tu_log(ip_agent   => l_n_agent_user_objid
                     ,ip_action  => '100'
                     ,ip_esn     => p_esn
                     ,ip_min     => p_min
                     ,ip_smp     => NULL
                     ,ip_reason  => 'SEQUENCE RAISED'
                     ,ip_storeid => NULL
                     ,op_result  => l_i_error_code
                     ,op_msg     => l_v_error_message);
    --
    IF (l_i_error_code = 1) THEN
      --
      l_i_error_code    := 0;
      l_v_error_message := 'SUCCESS';
      --
    ELSE
      --
      RAISE l_ex_business_error;
      --
    END IF;
    --
    COMMIT;
    --
  ELSE
    --
    l_v_position := l_cv_subprogram_name || '.10';
    l_v_note     := 'SEQUENCE RAISED action TU_LOG record was found; abort processing';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    l_i_error_code    := 3;
    l_v_error_message := 'SEQUENCE RAISED action has been executed for the ESN in the last 90 days';
    --
    RAISE l_ex_business_error;
    --
  END IF;
  --
  l_v_position := l_cv_subprogram_name || '.11';
  l_v_note     := 'End executing ' || l_cv_subprogram_name;
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(l_i_error_code)
                                                   ,'Value is null'));
    dbms_output.put_line('p_error_message: ' || NVL(l_v_error_message
                                                   ,'Value is null'));
    --
  END IF;
  --
  p_error_code    := l_i_error_code;
  p_error_message := l_v_error_message;
  --
EXCEPTION
  WHEN l_ex_business_error THEN
    --
    ROLLBACK;
    --
    p_error_code    := l_i_error_code;
    p_error_message := l_v_error_message;
    --
    l_v_position := l_cv_subprogram_name || '.12';
    l_v_note     := 'End executing with business error ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(p_error_code)
                                                     ,'Value is null'));
      dbms_output.put_line('p_error_message: ' || NVL(p_error_message
                                                     ,'Value is null'));
      --
    END IF;
    --
    IF get_esn_tu_log_curs%ISOPEN THEN
      --
      CLOSE get_esn_tu_log_curs;
      --
    END IF;
    --
  WHEN others THEN
    --
    ROLLBACK;
    --
    p_error_code    := SQLCODE;
    p_error_message := SQLERRM;
    --
    l_v_position := l_cv_subprogram_name || '.13';
    l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_error_code   : ' || NVL(TO_CHAR(p_error_code)
                                                     ,'Value is null'));
      dbms_output.put_line('p_error_message: ' || NVL(p_error_message
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
    IF get_esn_tu_log_curs%ISOPEN THEN
      --
      CLOSE get_esn_tu_log_curs;
      --
    END IF;
    --
END;
/