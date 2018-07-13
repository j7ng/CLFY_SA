CREATE OR REPLACE PACKAGE BODY sa.context_api IS
  /********************************************************************************/
  /*    Copyright 2011 Tracfone  Wireless Inc. All rights reserved                */
  /*                                                                              */
  /* NAME     : context_api                                                       */
  /* PURPOSE  : Package to handle set parameter namespace context functionality   */
  /* FREQUENCY:                                                                   */
  /* PLATFORMS:                                                                   */
  /* REVISIONS:                                                                   */
  /*                                                                              */
  /* VERSION DATE     WHO        PURPOSE                                          */
  /* ------- -------- ---------- -------------------------------------------------*/
  /* 1.0     02/17/11 kacosta    Initial  Revision                                */
  /*                             Package body was developed to support CR15468    */
  /*                             Tune high cpu/io sql from web csr                */
  /********************************************************************************/
  --
  -- Private Package Variables
  --
  l_cv_package_name CONSTANT VARCHAR2(30) := 'context_api';
  --
  -- Public Procedures
  --
  PROCEDURE set_parameter
  (
    p_name          IN VARCHAR2
   ,p_value         IN VARCHAR2
   ,p_error_code    OUT INTEGER
   ,p_error_message OUT VARCHAR2
  ) IS
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.set_parameter';
    l_i_error_code    INTEGER := 0;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    l_v_position      VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note          VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_name : ' || NVL(p_name
                                             ,'Value is null'));
      dbms_output.put_line('p_value: ' || NVL(p_value
                                             ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Setting parameter namespace context';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    dbms_session.set_context('parameter'
                            ,p_name
                            ,p_value);
    --
    l_v_position := l_cv_subprogram_name || '.3';
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
    WHEN others THEN
      --
      p_error_code    := SQLCODE;
      p_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.4';
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
                          ,p_key          => p_name
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
  END set_parameter;
  --
BEGIN
  --
  NULL;
  --
END context_api;
/