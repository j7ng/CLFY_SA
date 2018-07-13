CREATE OR REPLACE PROCEDURE sa.proc_RTC_eq_dequeuing
IS
  RTC_msg_prop              DBMS_AQ.message_properties_t;
  RTC_deq_opt               DBMS_AQ.dequeue_options_t;
  RTC_recipients            DBMS_AQ.aq$_recipient_list_t;
  RTC_deq_msgid             RAW(16);
  RTC_payload_deqd          RAW(200);
  l_count_msgs_in_RTC_eq     NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_count_msgs_in_RTC_eq FROM sa.AQ$RTC_Q_TABLE WHERE MSG_STATE='EXPIRED';
  RTC_deq_opt.consumer_name         := null;
  RTC_deq_opt.visibility              := DBMS_AQ.IMMEDIATE;
  FOR i IN 1..l_count_msgs_in_RTC_eq LOOP
  DBMS_AQ.dequeue(
  	queue_name                      => 'SA.RTC_EXCEPTION_QUEUE',
  	dequeue_options                 => RTC_deq_opt,
  	message_properties              => RTC_msg_prop,
  	payload                         => RTC_payload_deqd,
  	msgid                           => RTC_deq_msgid
	);
  END LOOP;
  EXCEPTION WHEN OTHERS THEN
    NULL;
--dbms_output.put_line(sqlerrm);
END proc_RTC_eq_dequeuing;
/