CREATE OR REPLACE PROCEDURE sa."SP_RTCCOMM_CASE_SHIPMENT"
( i_case_objid   IN  NUMBER,
  Out_Err_Num   OUT NUMBER,
  Out_Err_Msg   OUT VARCHAR2
 )
 IS
  /*******************************************************************************************************
 --$RCSfile: SP_RTCCOMM_CASE_SHIPMENT.sql,v $
 --$Revision: 1.8 $
 --$Author: nmuthukkaruppan $
 --$Date: 2016/09/22 17:04:29 $
 --$ $Log: SP_RTCCOMM_CASE_SHIPMENT.sql,v $
 --$ Revision 1.8  2016/09/22 17:04:29  nmuthukkaruppan
 --$ CR42764 - 2G Migration - Separate 2G Case Messages
 --$
 --$ Revision 1.7  2016/09/20 18:36:49  nmuthukkaruppan
 --$ CR42764 - 2G Migration - Separate 2G Case Messages
 --$
 --$ Revision 1.5  2016/09/12 15:34:15  nmuthukkaruppan
 --$ CR42764 - 2G Migration - Separate 2G Case Messages
 --$
 --$ Revision 1.0 2016/08/15 15:26:28 nmuthukkaruppan
 --$ CR42764 - 2G Migration - Separate 2G Case Messages
 --$
 * Description: This proc is to send RTC communcation for case shipment
 *
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/
    l_title      table_case.title%type;
    l_case_type  table_case.x_case_type%type;
    l_min        table_case.x_min%type;
    l_esn        table_case.x_esn%type;
    l_alt_e_mail table_case.alt_e_mail%type;
    l_id_number  table_case.id_number%type;
    l_bus_org    table_bus_org.org_id%type;
    l_rtc_comm   NUMBER;
    l_is_safelink  VARCHAR2(1);

    p_esn         table_case.x_esn%type;
    p_min         table_case.x_min%type;
    p_bus_org     table_bus_org.org_id%type;
    p_event       table_x_call_trans.x_action_text%type;
    p_msg_string  VARCHAR2(200);
    p_priority    NUMBER;
    p_expiry      NUMBER;
    p_queue       VARCHAR2(200);
    p_ex_queue    VARCHAR2(200);
    p_correlation VARCHAR2(200);
    p_language    VARCHAR2(10);

    p_case_id     table_case.id_number%type;
    p_alt_email   table_case.alt_e_mail%type;

    Input_validation_Failed EXCEPTION;
  BEGIN
    -- Initial Validation
    IF i_case_objid IS NULL THEN
       Out_Err_Num := 1;
       Out_Err_Msg  := 'Case objid cannot be empty';
       raise Input_validation_Failed ;
    END IF;

    BEGIN
      SELECT title,x_case_type,x_esn,x_min,alt_e_mail,id_number
      INTO l_title,l_case_type,l_esn,l_min,l_alt_e_mail,l_id_number
      FROM table_case
      WHERE objid = i_case_objid;

      l_bus_org := sa.util_pkg.get_bus_org_id (l_esn) ;
        -- Safelink Check
      IF l_bus_org IN ('TRACFONE','NET10')  THEN
          SELECT  DECODE(COUNT(*),0,'N','Y')
            INTO    l_is_safelink
            FROM    sa.x_sl_currentvals cur,
                    sa.table_site_part tsp,
                    sa.x_program_enrolled pe
            WHERE   tsp.x_service_id       = pe.x_esn
            AND     tsp.x_service_id       = cur.x_current_esn
            AND     pe.x_enrollment_status = 'enrolled'
            AND     cur.x_current_esn      = l_esn
            AND     upper(tsp.part_status) = 'active'
            AND     rownum                 = 1;

          IF l_is_safelink = 'Y' THEN
             l_bus_org  := 'SAFELINK';
          END IF;
       END IF;
       -- Is RTC enabled check
          SELECT nvl(rtc_comm,0)
            INTO l_rtc_comm
            FROM table_x_case_conf_hdr
           WHERE x_title     = l_title
             AND x_case_type = l_case_type;
        -- RTC logging
          sa.util_pkg.insert_rtc_log ( IP_ACTION => 'RTC_COMM Flag', IP_KEY => 'case_objid: ' || i_case_objid , IP_PROGRAM_NAME => 'sp_rtccomm_case_shipment', ip_process_text => 'l_rtc_comm '|| l_rtc_comm);
     EXCEPTION
       WHEN OTHERS THEN
        Out_Err_Num := 1;
        Out_Err_Msg  := 'Exception - '||SUBSTR (SQLERRM, 1, 300);
        sa.util_pkg.insert_rtc_log ( IP_ACTION => 'Error in getting the rtc_comm value', IP_KEY => 'case_objid: ' || i_case_objid , IP_PROGRAM_NAME => 'sp_rtccomm_case_shipment', ip_process_text => OUT_Err_MSg);
     END;
   IF l_rtc_comm = 1 THEN
        p_event       := 'CASE_SHIPMENT';
        p_bus_org     := l_bus_org;
        p_min         := l_min;
        p_priority    := 0;
        p_expiry      := 86400;
        p_queue       := 'SA.RTC_queue';
        p_ex_queue    := 'SA.RTC_Exception_Queue';
        p_correlation := 'RTC_Queue';
        p_esn         := l_esn;
        p_language    := 'ENG';
        p_case_id     := l_id_number;
        p_alt_email   := l_alt_e_mail;

       -- p_msg_string := (p_event || ',' || p_esn || ',' || p_min || ',' || p_bus_org || ',' || i_case_objid || '');
        p_msg_string := (p_event || ',' || p_esn || ',' || p_min || ',' || p_bus_org ||',' || p_alt_email ||',' || p_language || ',' || p_case_id || '');

         BEGIN
           sa.util_pkg.insert_rtc_log ( IP_ACTION => 'Enqueue begins', IP_KEY => 'i_case_objid: ' || i_case_objid , IP_PROGRAM_NAME => 'sp_rtccomm_case_shipment', ip_process_text => p_msg_string);
           --Engueue begins
           sa.rtc_pkg.enqueue(p_msg_string,p_priority,p_expiry,p_queue,p_ex_queue,p_correlation,out_err_num,out_err_msg);
         EXCEPTION
         WHEN OTHERS THEN
          Out_Err_Num := 1;
          Out_Err_Msg  := 'Exception in enqueue- '||SUBSTR (SQLERRM, 1, 300);
          sa.util_pkg.insert_rtc_log ( IP_ACTION => 'Exception in enqueue', IP_KEY => 'case_objid: ' || i_case_objid , IP_PROGRAM_NAME => 'sp_rtccomm_case_shipment', ip_process_text => OUT_Err_MSg);
         END;
       Out_Err_Num := 0;
       Out_Err_Msg := 'SUCCESS';
   END IF;
EXCEPTION
 WHEN Input_validation_Failed THEN
    	sa.util_pkg.insert_rtc_log ( IP_ACTION => 'Input_validation_Failed', IP_KEY => 'case_objid: '||i_case_objid , IP_PROGRAM_NAME => 'sp_rtccomm_case_shipment', ip_process_text => OUT_Err_MSg);
 WHEN OTHERS THEN
    Out_Err_Num  := 1  ;
    Out_Err_Msg  :=  'Exception others '||SUBSTR (SQLERRM, 1, 300);
    sa.util_pkg.insert_rtc_log ( IP_ACTION => 'Exception others', IP_KEY =>  'case_objid: '||i_case_objid  , IP_PROGRAM_NAME => 'sp_rtccomm_case_shipment', ip_process_text => OUT_Err_MSg);
END;
/