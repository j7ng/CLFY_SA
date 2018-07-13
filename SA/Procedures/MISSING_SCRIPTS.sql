CREATE OR REPLACE PROCEDURE sa.Missing_Scripts
AS
    lDate      VARCHAR2(30 CHAR);
    OUT_RESULT VARCHAR2(200);
  dbname     VARCHAR2(30);
  Lname      VARCHAR2(4000);
  lmsg         VARCHAR2(4000);
    IP_LABEL VARCHAR2(32767);
  IP_ID VARCHAR2(32767);
  OUT_ERROR_TEXT VARCHAR2(32767);
  V_SOURCEDB VARCHAR2(32767);
  V_SRC_OBJID NUMBER;
  V_DEBUG_FLAG BOOLEAN;
BEGIN
  SELECT TO_CHAR(sysdate,'mmdd_HH24MI') INTO lDate FROM dual;
  SELECT name
  INTO dbname
  FROM v$database;
  /* Code to check missing labels*/
      BEGIN
        FOR i IN
          (SELECT DISTINCT label_name
            FROM crm.export_label_release_dates@apexprd elrd,crm.export_labels@apexprd el
            WHERE 1=1
            AND el.label_name = elrd.export_label
            AND freeze_flag   = 'Y'
            AND freeze_date   > = (SELECT TRUNC(MAX(DDL_DATE ))ref_date  FROM ddl_log
                                  WHERE object_type='TABLE'
                                  AND OBJECT       ='SA.TABLE_X_SCRIPTS'
                                  AND dDl_type     ='TRUNCATE'
                                  AND DDL_DATE     >sysdate-180
                                  )
            AND label_name NOT                     IN
             (select distinct script_rev_id
                     --             (SELECT DISTINCT trim(NVL(SUBSTR(script_rev_id, 0, INSTR(script_rev_id, '.')-1), script_rev_id)) script_rev_id
                                  FROM SCRIPTS_EXPORT_LOG
                                  WHERE insert_date  >=(SELECT TRUNC(MAX(DDL_DATE ))ref_date  FROM ddl_log
                                  WHERE object_type='TABLE'
                                  AND OBJECT       ='SA.TABLE_X_SCRIPTS'
                                  AND dDl_type     ='TRUNCATE'
                                  AND DDL_DATE     >sysdate-180
                                  )
                                  AND script_rev_id IS NOT NULL
                                  )
            )
        LOOP
          lname := lname||chr(10)||', '||i.label_name;
            IP_ID := NULL;
  OUT_ERROR_TEXT := NULL;
  V_SOURCEDB := 'APEXPRD';
  V_SRC_OBJID := NULL;
  V_DEBUG_FLAG := FALSE;
  sa.IMPORT_SCPT_2 ( i.label_name, IP_ID, OUT_ERROR_TEXT, V_SOURCEDB, V_SRC_OBJID, V_DEBUG_FLAG );
  COMMIT; 
    dbms_output.put_line ('error'||OUT_ERROR_TEXT);
        END LOOP;
        IF lname IS NOT NULL THEN
          lmsg := 'The following labels are added: '||CHR(10)||lname;
          dbms_output.put_line(lname);
          dbms_output.put_line(lmsg);
          SEND_MAIL( 'New Labels added in '||dbname, 'oradev@dpe1487002.tracfone.com', 'jtong@tracfone.com', lmsg, out_result );
          IF out_result IS NULL THEN
            out_result  := 'SUCCESS';
          END IF;
          DBMS_OUTPUT.PUT_LINE('RESULT = ' || OUT_RESULT);
          COMMIT;
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Missing Labels found  Error : '||sqlerrm);
      END;
  EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Missing Labels found  Error : '||sqlerrm);
  END Missing_Scripts;
/