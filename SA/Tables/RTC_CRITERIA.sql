CREATE TABLE sa.rtc_criteria (
  objid NUMBER NOT NULL,
  criteria_name VARCHAR2(100 BYTE) NOT NULL,
  description VARCHAR2(200 BYTE),
  UNIQUE (objid),
  UNIQUE (criteria_name)
);
COMMENT ON COLUMN sa.rtc_criteria.objid IS 'From sequence SA.SEQU_RTC_CRITERIA';
COMMENT ON COLUMN sa.rtc_criteria.criteria_name IS 'Criteria to decide whether to send communication or not';