CREATE TABLE sa.x_vas_event_counter (
  objid NUMBER,
  vas_objectvalue VARCHAR2(50 BYTE),
  vas_event VARCHAR2(30 BYTE),
  objectvalue_event_counter NUMBER
);
COMMENT ON TABLE sa.x_vas_event_counter IS 'TRACK THE TIMES WE OFFER A VAS BY THE ENTRY TYPE';
COMMENT ON COLUMN sa.x_vas_event_counter.objid IS 'UNIQUE KEY';
COMMENT ON COLUMN sa.x_vas_event_counter.vas_objectvalue IS 'ESN / MIN / SIM / ACCOUNT';
COMMENT ON COLUMN sa.x_vas_event_counter.vas_event IS 'NAME OF THE EVENT';
COMMENT ON COLUMN sa.x_vas_event_counter.objectvalue_event_counter IS 'TOTAL COUNT';