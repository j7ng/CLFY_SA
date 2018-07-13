CREATE TABLE sa.rtc_criteria_values (
  objid NUMBER NOT NULL,
  values2serviceplan NUMBER,
  values2event NUMBER,
  values2criteria NUMBER NOT NULL,
  values2bus_org NUMBER,
  criteria_value VARCHAR2(4000 BYTE),
  description VARCHAR2(200 BYTE),
  x_language VARCHAR2(10 BYTE),
  start_date DATE,
  end_date DATE,
  value2carrier NUMBER(22),
  UNIQUE (objid)
);
COMMENT ON COLUMN sa.rtc_criteria_values.objid IS 'From sequence SA.SEQU_RTC_CRITERIA_VALUES';
COMMENT ON COLUMN sa.rtc_criteria_values.values2serviceplan IS 'Join with table SA.X_SERVICE_PLAN';
COMMENT ON COLUMN sa.rtc_criteria_values.values2event IS 'Join with table SA.RTC_EVENT';
COMMENT ON COLUMN sa.rtc_criteria_values.values2criteria IS 'Join with table SA.RTC_CRITERIA';
COMMENT ON COLUMN sa.rtc_criteria_values.criteria_value IS 'Values for the criteria';
COMMENT ON COLUMN sa.rtc_criteria_values.description IS 'Description';
COMMENT ON COLUMN sa.rtc_criteria_values.value2carrier IS 'Carrier ID';