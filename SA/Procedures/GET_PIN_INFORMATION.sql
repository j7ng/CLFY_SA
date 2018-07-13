CREATE OR REPLACE PROCEDURE sa."GET_PIN_INFORMATION"
(
  p_service_pin_number IN table_part_inst.x_red_code%TYPE
 ,p_debug              IN INTEGER DEFAULT 0
 ,p_pin_status         OUT table_x_code_table.x_code_name%TYPE
 ,p_pin_description    OUT table_part_num.description%TYPE
 ,p_date_redeemed      OUT VARCHAR2
 ,p_esn                OUT table_part_inst.part_serial_no%TYPE
 ,p_error_code         OUT INTEGER
 ,p_error_message      OUT VARCHAR2
) IS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: GET_PIN_INFORMATION.sql,v $
  --$Revision: 1.2 $
  --$Author: kacosta $
  --$Date: 2012/10/15 19:34:14 $
  --$ $Log: GET_PIN_INFORMATION.sql,v $
  --$ Revision 1.2  2012/10/15 19:34:14  kacosta
  --$ CR21619 Simply Wireless URL Enhancement
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  l_cv_subprogram_name CONSTANT VARCHAR2(61) := 'get_pin_information';
  l_b_debug           BOOLEAN := FALSE;
  l_i_error_code      INTEGER := 0;
  l_v_error_message   VARCHAR2(32767) := 'SUCCESS';
  l_v_position        VARCHAR2(32767) := l_cv_subprogram_name || '.1';
  l_v_note            VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
  l_v_pin_status      table_x_code_table.x_code_name%TYPE;
  l_v_pin_description table_part_num.description%TYPE;
  l_v_date_redeemed   VARCHAR2(10);
  l_v_esn             table_part_inst.part_serial_no%TYPE;
  --
BEGIN
  --
  IF NVL(p_debug
        ,0) = 1 THEN
    --
    l_b_debug := TRUE;
    --
  ELSE
    --
    l_b_debug := FALSE;
    --
  END IF;
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    dbms_output.put_line('p_service_pin_number: ' || NVL(p_service_pin_number
                                                        ,'Value is null'));
    --
  END IF;
  --
  l_v_position := l_cv_subprogram_name || '.2';
  l_v_note     := 'Get PIN information';
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    --
  END IF;
  --
  SELECT pin_status
        ,pin_description
        ,TO_CHAR(date_redeemed
                ,'MM/DD/YYYY') date_redeemed
        ,esn
    INTO l_v_pin_status
        ,l_v_pin_description
        ,l_v_date_redeemed
        ,l_v_esn
    FROM (SELECT 1
                ,tpi_red_card.x_red_code  service_pin_number
                ,xct_red_card.x_code_name pin_status
                ,tpn_red_card.description pin_description
                ,NULL                     date_redeemed
                ,tpi_esn.part_serial_no   esn
            FROM table_part_inst tpi_red_card
            JOIN table_x_code_table xct_red_card
              ON tpi_red_card.x_part_inst_status = xct_red_card.x_code_number
            JOIN table_mod_level tml_red_card
              ON tpi_red_card.n_part_inst2part_mod = tml_red_card.objid
            JOIN table_part_num tpn_red_card
              ON tml_red_card.part_info2part_num = tpn_red_card.objid
            LEFT OUTER JOIN table_part_inst tpi_esn
              ON tpi_red_card.part_to_esn2part_inst = tpi_esn.objid
             AND tpi_esn.x_domain = 'PHONES'
           WHERE tpi_red_card.x_red_code = p_service_pin_number
             AND tpi_red_card.x_domain = 'REDEMPTION CARDS'
          UNION
          SELECT 2
                ,xrc.x_red_code service_pin_number
                ,CASE
                   WHEN UPPER(xrc.x_result) = 'BROKEN CARD' THEN
                    'BROKEN CARD'
                   WHEN UPPER(xrc.x_result) = 'COMPLETED'
                        AND UPPER(xct.x_result) <> 'FAILED' THEN
                    'REDEEMED'
                   WHEN UPPER(xct.x_result) = 'FAILED'
                        OR UPPER(xrc.x_result) = 'FAILED' THEN
                    'FAILED REDEMPTION'
                   ELSE
                    'UNDEFINED'
                 END pin_status
                ,tpn_red_card.description pin_description
                ,xrc.x_red_date date_redeemed
                ,xct.x_service_id esn
            FROM table_x_red_card xrc
            LEFT OUTER JOIN table_x_call_trans xct
              ON xrc.red_card2call_trans = xct.objid
            JOIN table_mod_level tml_red_card
              ON xrc.x_red_card2part_mod = tml_red_card.objid
            JOIN table_part_num tpn_red_card
              ON tml_red_card.part_info2part_num = tpn_red_card.objid
           WHERE xrc.x_red_code = p_service_pin_number
             AND xrc.objid = (SELECT MAX(xrc_max.objid)
                                FROM table_x_red_card xrc_max
                               WHERE xrc_max.x_red_code = xrc.x_red_code
                                 AND xrc_max.x_red_date = (SELECT MAX(xrc_max_date.x_red_date)
                                                             FROM table_x_red_card xrc_max_date
                                                            WHERE xrc_max_date.x_red_code = xrc_max.x_red_code))
           ORDER BY 1)
   WHERE ROWNUM <= 1;
  --
  l_v_position := l_cv_subprogram_name || '.3';
  l_v_note     := 'End executing ' || l_cv_subprogram_name;
  --
  IF l_b_debug THEN
    --
    dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                    ,' MM/DD/YYYY HH:MI:SS AM'));
    dbms_output.put_line('p_pin_status     : ' || NVL(l_v_pin_status
                                                     ,'Value is null'));
    dbms_output.put_line('p_pin_description: ' || NVL(l_v_pin_description
                                                     ,'Value is null'));
    dbms_output.put_line('p_date_redeemed  : ' || NVL(l_v_date_redeemed
                                                     ,'Value is null'));
    dbms_output.put_line('p_esn            : ' || NVL(l_v_esn
                                                     ,'Value is null'));
    dbms_output.put_line('p_error_code     : ' || NVL(TO_CHAR(l_i_error_code)
                                                     ,'Value is null'));
    dbms_output.put_line('p_error_message  : ' || NVL(l_v_error_message
                                                     ,'Value is null'));
    --
  END IF;
  --
  p_pin_status      := l_v_pin_status;
  p_pin_description := l_v_pin_description;
  p_date_redeemed   := l_v_date_redeemed;
  p_esn             := l_v_esn;
  p_error_code      := l_i_error_code;
  p_error_message   := l_v_error_message;
  --
EXCEPTION
  WHEN no_data_found THEN
    --
    p_pin_status      := NULL;
    p_pin_description := NULL;
    p_date_redeemed   := NULL;
    p_esn             := NULL;
    p_error_code      := 1;
    p_error_message   := 'No pin information found';
    --
    l_v_position := l_cv_subprogram_name || '.4';
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
  WHEN others THEN
    --
    p_pin_status      := NULL;
    p_pin_description := NULL;
    p_date_redeemed   := NULL;
    p_esn             := NULL;
    p_error_code      := SQLCODE;
    p_error_message   := SQLERRM;
    --
    l_v_position := l_cv_subprogram_name || '.5';
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
                        ,p_key          => p_service_pin_number
                        ,p_program_name => l_v_position
                        ,p_error_text   => p_error_message);
    --
END get_pin_information;
/