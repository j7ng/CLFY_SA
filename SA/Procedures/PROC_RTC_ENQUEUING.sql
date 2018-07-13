CREATE OR REPLACE PROCEDURE sa.proc_RTC_enqueuing(
  RTC_msg                  IN       VARCHAR2,
  RTC_msg_priority         IN       NUMBER)
IS
  RTC_msg_prop           DBMS_AQ.message_properties_t;
  RTC_enq_opt            DBMS_AQ.enqueue_options_t;
  --RTC_recipients         DBMS_AQ.aq$_recipient_list_t;
  RTC_enq_msgid          RAW(16);
  RTC_payload            RAW(300);
BEGIN
  RTC_payload 			              := UTL_RAW.CAST_TO_RAW(RTC_msg);
  RTC_enq_opt.visibility		      := DBMS_AQ.IMMEDIATE;
  RTC_enq_opt.delivery_mode       := DBMS_AQ.PERSISTENT;
  RTC_msg_prop.delivery_mode      := DBMS_AQ.PERSISTENT;
  RTC_msg_prop.priority           := RTC_msg_priority;
  --RTC_msg_prop.recipient_list     :=  RTC_recipients;
  RTC_msg_prop.expiration         := 86400;
  --RTC_msg_prop.expiration         := 30; --
  RTC_msg_prop.correlation        := 'RTC_Queue';
  RTC_msg_prop.exception_queue    := 'SA.RTC_Exception_Queue';
  DBMS_AQ.enqueue(
  	queue_name                      => 'SA.RTC_queue',
  	enqueue_options                 => RTC_enq_opt,
  	message_properties              => RTC_msg_prop,
  	payload                         => RTC_payload,
  	msgid                           => RTC_enq_msgid
	);
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END proc_RTC_enqueuing;
/