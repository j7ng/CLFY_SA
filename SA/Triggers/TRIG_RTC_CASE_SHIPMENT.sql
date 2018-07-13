CREATE OR REPLACE TRIGGER sa."TRIG_RTC_CASE_SHIPMENT" after
UPDATE OF X_STATUS ON sa.TABLE_X_PART_REQUEST
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
--------------------------------------------------------------------------------------------
--$RCSfile: TRIG_RTC_CASE_SHIPMENT.sql,v $
--$Revision: 1.4 $
--$Author: nmuthukkaruppan $
--$Date: 2016/09/20 18:31:42 $
--$ $Log: TRIG_RTC_CASE_SHIPMENT.sql,v $
--$ Revision 1.4  2016/09/20 18:31:42  nmuthukkaruppan
--$ CR42764 - 2G Migration - Separate 2G Case Messages
--$
--$ Revision 1.1  2016/08/17 16:21:11  nmuthukkaruppan
--$ CR42764 - 2G Migration - Separate 2G Case Messages
--$
--------------------------------------------------------------------------------------------
  out_err_num   NUMBER;
  out_err_msg   VARCHAR2(300);
BEGIN
      --RTC Logging
      sa.util_pkg.insert_rtc_log ( IP_ACTION => 'RTC_case_shipment Triggered', IP_KEY => ':new.request2case: '||:new.request2case , IP_PROGRAM_NAME => 'trig_RTC_case_shipment', ip_process_text => ':old.X_STATUS is: '||:old.X_STATUS|| ':new.X_STATUS is: '||:new.X_STATUS||':old.X_SHIP_DATE is: '||:old.X_SHIP_DATE);

   IF (:old.X_STATUS <> 'SHIPPED' and :new.X_STATUS = 'SHIPPED' and :old.X_SHIP_DATE IS NULL) THEN
       sa.util_pkg.insert_rtc_log ( IP_ACTION => 'Calling sp_rtccomm_case_shipment ', IP_KEY => ':new.request2case: '||:new.request2case , IP_PROGRAM_NAME => 'trig_RTC_case_shipment', ip_process_text => ':new.request2case: '||:new.request2case);

       --Calling proc to send RTC comm
       sa.sp_rtccomm_case_shipment (:new.request2case,out_err_num , out_err_msg);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
     sa.util_pkg.insert_rtc_log ( IP_ACTION => 'Error in trig_RTC_case_shipment', IP_KEY => ':new.request2case: '||:new.request2case, IP_PROGRAM_NAME => 'trig_RTC_case_shipment', ip_process_text => SUBSTR(SQLERRM,1,300));
END;
/