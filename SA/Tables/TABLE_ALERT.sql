CREATE TABLE sa.table_alert (
  objid NUMBER,
  "TYPE" VARCHAR2(80 BYTE),
  alert_text LONG,
  start_date DATE,
  end_date DATE,
  "ACTIVE" NUMBER,
  title VARCHAR2(80 BYTE),
  "HOT" NUMBER,
  dev NUMBER,
  last_update2user NUMBER(*,0),
  alert2contact NUMBER(*,0),
  alert2site NUMBER(*,0),
  alert2contract NUMBER(*,0),
  alert2bus_org NUMBER,
  alert2lead NUMBER,
  alert2opportunity NUMBER,
  modify_stmp DATE,
  x_ivr_script_id VARCHAR2(10 BYTE),
  x_web_text_english VARCHAR2(2000 BYTE),
  x_web_text_spanish VARCHAR2(2000 BYTE),
  x_cancel_sql VARCHAR2(4000 BYTE),
  x_tts_english VARCHAR2(2000 BYTE),
  x_tts_spanish VARCHAR2(2000 BYTE),
  x_eval_sql NUMBER(1),
  x_condition_sql VARCHAR2(2000 BYTE),
  x_step NUMBER,
  sms_message VARCHAR2(100 BYTE),
  url VARCHAR2(500 BYTE),
  url_text_en VARCHAR2(100 BYTE),
  url_text_es VARCHAR2(100 BYTE),
  is_alert_suppressible VARCHAR2(1 BYTE)
);
ALTER TABLE sa.table_alert ADD SUPPLEMENTAL LOG GROUP dmtsora1190731688_0 ("ACTIVE", alert2bus_org, alert2contact, alert2contract, alert2lead, alert2opportunity, alert2site, dev, end_date, "HOT", last_update2user, modify_stmp, objid, start_date, title, "TYPE", x_cancel_sql, x_condition_sql, x_eval_sql, x_ivr_script_id, x_tts_english, x_tts_spanish, x_web_text_english, x_web_text_spanish) ALWAYS;
COMMENT ON TABLE sa.table_alert IS 'Hold alert information about a site, contact, or contract';
COMMENT ON COLUMN sa.table_alert.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_alert."TYPE" IS 'The type of alert';
COMMENT ON COLUMN sa.table_alert.alert_text IS 'Text of the alert message, for WEBCSR and classic client';
COMMENT ON COLUMN sa.table_alert.start_date IS 'Date the alert becomes effective';
COMMENT ON COLUMN sa.table_alert.end_date IS 'Last date the alert is effective';
COMMENT ON COLUMN sa.table_alert."ACTIVE" IS 'Indicates whether alert is active; i.e., 0=inactive, 1=active. In order to fire, an alert must be both effective and active';
COMMENT ON COLUMN sa.table_alert.title IS 'The title of the alert';
COMMENT ON COLUMN sa.table_alert."HOT" IS 'Indicates whether alert is flagged as hot; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_alert.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_alert.last_update2user IS 'The user that created or last modified the alert';
COMMENT ON COLUMN sa.table_alert.alert2bus_org IS 'Account which is the subject of the alert';
COMMENT ON COLUMN sa.table_alert.alert2lead IS 'Lead which is the subject of the alert';
COMMENT ON COLUMN sa.table_alert.alert2opportunity IS 'Opportunity which is the subject of the alert';
COMMENT ON COLUMN sa.table_alert.modify_stmp IS 'Date/time of last update to the alert';
COMMENT ON COLUMN sa.table_alert.x_ivr_script_id IS 'IVR script ID';
COMMENT ON COLUMN sa.table_alert.x_web_text_english IS 'TBD';
COMMENT ON COLUMN sa.table_alert.x_web_text_spanish IS 'TBD';
COMMENT ON COLUMN sa.table_alert.x_cancel_sql IS 'Dynamic SQL to calcel the alert, in case of any return value';
COMMENT ON COLUMN sa.table_alert.x_tts_english IS 'Text to Speech English';
COMMENT ON COLUMN sa.table_alert.x_tts_spanish IS 'TBD';
COMMENT ON COLUMN sa.table_alert.is_alert_suppressible IS 'Y/N flag set at alert creation to determine is TAS agent can suppress the alert ';