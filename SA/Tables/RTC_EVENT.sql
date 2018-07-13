CREATE TABLE sa.rtc_event (
  objid NUMBER NOT NULL,
  rtc_event VARCHAR2(50 BYTE) NOT NULL,
  rtc_comm_on VARCHAR2(10 BYTE) NOT NULL,
  description VARCHAR2(200 BYTE),
  queue_active_flag VARCHAR2(1 BYTE),
  CONSTRAINT rtc_event_comm_on_unique UNIQUE (rtc_event,rtc_comm_on),
  UNIQUE (objid),
  UNIQUE (rtc_event)
);
COMMENT ON TABLE sa.rtc_event IS 'RTC event activities for QUEUEING messages';
COMMENT ON COLUMN sa.rtc_event.objid IS 'From sequence SA.SEQU_RTC_EVENT';
COMMENT ON COLUMN sa.rtc_event.rtc_event IS 'Name of the triggering RTC event';
COMMENT ON COLUMN sa.rtc_event.rtc_comm_on IS 'Is RTC on for the event: (Y/N) = (1/0)';
COMMENT ON COLUMN sa.rtc_event.description IS 'Description';
COMMENT ON COLUMN sa.rtc_event.queue_active_flag IS 'Is RTC event for QUEUE message process: (Y/N)';