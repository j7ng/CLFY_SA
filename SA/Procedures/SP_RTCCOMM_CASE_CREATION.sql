CREATE OR REPLACE PROCEDURE sa."SP_RTCCOMM_CASE_CREATION"
( i_case_objid IN  VARCHAR2,
  i_id_number  IN  VARCHAR2,
  i_title     IN  VARCHAR2,
  i_case_type IN  VARCHAR2,
  i_esn       IN  VARCHAR2,
  i_min       IN  VARCHAR2,
  i_alt_e_mail IN  VARCHAR2,
  i_bus_org    IN  VARCHAR2,
  Out_Err_Num   OUT NUMBER,
  Out_Err_Msg   OUT VARCHAR2
 )
 IS
  /*******************************************************************************************************
 --$RCSfile: SP_RTCCOMM_CASE_CREATION.sql,v $
 --$Revision: 1.7 $
 --$Author: nmuthukkaruppan $
 --$Date: 2016/09/22 19:24:37 $
 --$ $Log: SP_RTCCOMM_CASE_CREATION.sql,v $
 --$ Revision 1.7  2016/09/22 19:24:37  nmuthukkaruppan
 --$ CR42764 - 2G Migration - Added Case_id number in the input
 --$
 --$ Revision 1.6  2016/09/20 18:34:18  nmuthukkaruppan
 --$ CR42764 - 2G Migration - Separate 2G Case Messages
 --$
 --$ Revision 1.4  2016/09/12 15:34:15  nmuthukkaruppan
 --$ CR42764 - 2G Migration - Separate 2G Case Messages
 --$
 --$ Revision 1.0 2016/08/12 15:26:28 nmuthukkaruppan
 --$ CR42764 - 2G Migration - Separate 2G Case Messages
 --$
 * Description: This proc is to send RTC communcation for case creation
 *
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/
    l_rtc_comm   NUMBER;

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

    p_case_id  table_case.id_number%type;
    p_alt_email   table_case.alt_e_mail%type;

    Input_validation_Failed EXCEPTION;
  BEGIN
     -- Initial validation
     IF i_title IS NULL OR i_case_type IS NULL OR i_min IS NULL THEN
        Out_Err_Num := 1;
        Out_Err_Msg  := 'Title,case_type,min cannot be empty';
        raise Input_validation_Failed ;
     END IF;

    -- Is RTC enabled check
     BEGIN
        select NVL(rtc_comm,0)
        into l_rtc_comm
        from table_x_case_conf_hdr
        where x_title = i_title
         and x_case_type = i_case_type;
     EXCEPTION
       WHEN OTHERS THEN
        Out_Err_Num := 1;
        Out_Err_Msg  := 'Exception - '||SUBSTR (SQLERRM, 1, 300);
        sa.util_pkg.insert_rtc_log ( IP_ACTION => 'Error in getting the rtc_comm', IP_KEY => 'i_case_objid: '||i_case_objid , IP_PROGRAM_NAME => 'sp_rtccomm_case_creation', ip_process_text => OUT_Err_MSg);
        RETURN;
     END;

     -- RTC logging
     sa.util_pkg.insert_rtc_log( IP_ACTION => 'RTC_COMM flag', IP_KEY => 'i_case_objid: '||i_case_objid , IP_PROGRAM_NAME => 'sp_rtccomm_case_creation', ip_process_text => 'l_rtc_comm '||l_rtc_comm);

     IF l_rtc_comm = 1 THEN
        p_event       := 'CASE_CREATION';
        p_bus_org     := i_bus_org;
        p_min         := i_min;
        p_priority    := 0;
        p_expiry      := 86400;
        p_queue       := 'SA.RTC_queue';
        p_ex_queue    := 'SA.RTC_Exception_Queue';
        p_correlation := 'RTC_Queue';
        p_esn         := i_esn;
        p_language    := 'ENG';

        p_case_id     := i_id_number;
        p_alt_email   := i_alt_e_mail;

        BEGIN
         --p_msg_string := (p_event || ',' || p_esn || ',' || p_min || ',' || p_bus_org || ',' || '');
         --p_msg_string := (p_event || ',' || p_esn || ',' || p_min || ',' || p_bus_org || ',' || i_case_objid || '');
           p_msg_string := (p_event || ',' || p_esn || ',' || p_min || ',' || p_bus_org ||',' || p_alt_email ||',' || p_language || ',' || p_case_id || '');

           --Enqueue begins
           sa.rtc_pkg.enqueue(p_msg_string,p_priority,p_expiry,p_queue,p_ex_queue,p_correlation,out_err_num,out_err_msg);
           sa.util_pkg.insert_rtc_log ( IP_ACTION => 'Enqueue Begins', IP_KEY =>  'i_case_objid: '||i_case_objid, IP_PROGRAM_NAME => 'sp_rtccomm_case_creation', ip_process_text => p_msg_string);
        EXCEPTION
        WHEN OTHERS THEN
          Out_Err_Num := 1;
          Out_Err_Msg  := 'Exception in enqueue - '||SUBSTR (SQLERRM, 1, 300);
          sa.util_pkg.insert_rtc_log ( IP_ACTION => 'Error in enqueue', IP_KEY =>'i_case_objid: '||i_case_objid , IP_PROGRAM_NAME => 'sp_rtccomm_case_creation', ip_process_text => OUT_Err_MSg);
        END;

       Out_Err_Num := 0;
       Out_Err_Msg := 'SUCCESS';
    END IF;
EXCEPTION
 WHEN Input_validation_Failed THEN
    	sa.util_pkg.insert_rtc_log ( IP_ACTION => 'Input_validation_Failed', IP_KEY => 'i_case_objid: '||i_case_objid , IP_PROGRAM_NAME => 'sp_rtccomm_case_creation', ip_process_text => OUT_Err_MSg);
 WHEN OTHERS THEN
    Out_Err_Num  := 1  ;
    Out_Err_Msg  :=  'Exception others'||SUBSTR (SQLERRM, 1, 300);
    sa.util_pkg.insert_rtc_log ( IP_ACTION => 'Exception in sp_rtccomm_case_creation', IP_KEY => 'i_case_objid: '||i_case_objid, IP_PROGRAM_NAME => 'sp_rtccomm_case_creation', ip_process_text => OUT_Err_MSg);
END;
/