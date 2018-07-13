CREATE OR REPLACE FORCE VIEW sa.adfcrm_flashcontact_v (title,start_date,end_date,web_text_english,web_text_spanish,status,status_code,status_id,urgent,alert_text,created_by,alert_objid,alert2contact,last_update2user,"HOT") AS
SELECT a.title                                            AS title ,
    a.start_date                                            AS start_date ,
    a.end_date                                              AS end_date ,
    a.X_WEB_TEXT_ENGLISH                                    AS web_text_english ,
    a.X_WEB_TEXT_SPANISH                                    AS web_text_spanish ,
    DECODE (a.active, '1', 'Active', '0', 'Inactive', NULL) AS status ,
    DECODE (a.active, '1', 'Active', '0', 'Inactive', NULL) AS status_code ,
    a.active                                                AS status_id ,
    DECODE (a.hot, '1', 'Urgent', NULL)                     AS urgent ,
    a.alert_text                                            AS alert_text ,
    u.login_name                                            AS created_by
    /* Below used for querying */
    ,
    a.objid            AS alert_objid ,
    a.alert2contact    AS alert2contact ,
    a.last_update2user AS last_update2user -- last update USER OBJID
    ,
    a.hot AS hot
  FROM table_alert a ,
    table_user u
  WHERE a.last_update2user = u.objid
  ORDER BY hot;