CREATE OR REPLACE TRIGGER sa."TRIG_RTC_CASE_CREATION" after
INSERT ON sa.TABLE_CASE
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
--------------------------------------------------------------------------------------------
--$RCSfile: TRIG_RTC_CASE_CREATION.sql,v $
--$Revision: 1.7 $
--$Author: nmuthukkaruppan $
--$Date: 2016/09/22 19:27:30 $
--$ $Log: TRIG_RTC_CASE_CREATION.sql,v $
--$ Revision 1.7  2016/09/22 19:27:30  nmuthukkaruppan
--$ CR42764 - 2G Migration - Added Case Id input in the procedure call
--$
--$ Revision 1.6  2016/09/20 18:15:56  nmuthukkaruppan
--$ CR42764 - 2G Migration - Separate 2G Case Messages
--$
--$ Revision 1.1  2016/08/17 16:21:11  nmuthukkaruppan
--$ CR42674 - 2G Migration - Separate 2G Case Messages
--$
--------------------------------------------------------------------------------------------
  out_err_num   NUMBER;
  out_err_msg   VARCHAR2(200);
  l_bus_org   VARCHAR2(30);
  l_is_safelink  VARCHAR2(1);
BEGIN
   l_bus_org := util_pkg.get_bus_org_id (:new.x_esn) ;

  --Safelink Check
   IF l_bus_org IN ('TRACFONE','NET10')  THEN
        SELECT  DECODE(COUNT(*),0,'N','Y')
          INTO    l_is_safelink
          FROM    sa.x_sl_currentvals cur,
                  sa.table_site_part tsp,
                  sa.x_program_enrolled pe
          WHERE   tsp.x_service_id       = pe.x_esn
          AND     tsp.x_service_id       = cur.x_current_esn
          AND     pe.x_enrollment_status = 'ENROLLED'
          AND     cur.x_current_esn      = :new.x_esn
          AND     upper(tsp.part_status) = 'ACTIVE'
          AND     rownum                 = 1;

        IF l_is_safelink = 'Y' THEN
           l_bus_org  := 'SAFELINK';
        END IF;
   END IF;

  -- RTC Logging
  util_pkg.insert_rtc_log( IP_ACTION => 'RTC_case Triggered', IP_KEY => ' :new.objid '||:new.objid , IP_PROGRAM_NAME => 'trig_RTC_case_creation', ip_process_text => ':new.title '||:new.title ||' :new.x_case_type '||:new.x_case_type||'l_bus_org '||l_bus_org);

  --Calling proc to send RTC comm
  sa.sp_rtccomm_case_creation (:new.objid,:new.id_number,:new.title,:new.x_case_type,:new.x_esn,:new.x_min,:new.alt_e_mail,l_bus_org,out_err_num , out_err_msg);

EXCEPTION
   WHEN OTHERS THEN
    UTIL_PKG.insert_rtc_log ( IP_ACTION => 'Error in trig_RTC_case_creation', IP_KEY => ' :new.objid '||:new.objid , IP_PROGRAM_NAME => 'trig_RTC_case_creation', ip_process_text => SUBSTR(SQLERRM,1,300));
END;
/