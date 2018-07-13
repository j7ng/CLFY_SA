CREATE OR REPLACE TRIGGER sa."TRG_X_CODE_TABLE_BIUD"
   BEFORE INSERT OR UPDATE OR DELETE
   ON sa.table_x_code_table
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
   v_action           VARCHAR2 (1);
   v_osuser           VARCHAR2 (50);
   v_userid           VARCHAR2 (30);
   v_text             VARCHAR2 (4000);
   common_text        VARCHAR2 (70)
                  := 'Tracfone Auto POSA Redemption and Activation flag was ';
   dtntime            VARCHAR2 (20)
                                 := TO_CHAR (SYSDATE, 'DD-MON-RR HH24:MI:SS');
   v_email_req_flag   VARCHAR2 (1)    := 'N';
BEGIN
   IF INSERTING
   THEN
      v_action := 'I';
   ELSIF UPDATING
   THEN
      v_action := 'U';
   ELSE
      v_action := 'D';
   END IF;

   IF (    :OLD.x_code_number IN ('45', '59')
       AND NVL (:OLD.x_value, 99) <> NVL (:NEW.x_value, 99)
      )
   THEN
      SELECT DECODE (:NEW.x_value,
                     1, common_text || 'turned ON AT ' || dtntime,
                     0, common_text || 'turned OFF AT ' || dtntime,
                     common_text || 'changed AT ' || dtntime
                    )
        INTO v_text
        FROM DUAL;

      v_email_req_flag := 'Y';
   END IF;

--cwl 01-dec-09
--   SELECT objid, SYS_CONTEXT ('USERENV', 'OS_USER')
--     INTO v_userid, v_osuser
--     FROM table_user
--    WHERE UPPER (login_name) = UPPER (USER);
   SELECT objid, SYS_CONTEXT ('USERENV', 'OS_USER')
     INTO v_userid, v_osuser
     FROM table_user
    WHERE s_login_name = UPPER (USER);

   INSERT INTO x_code_table_hist
               (objid,
                x_code_name,
                x_code_number,
                x_code_type,
                x_value, x_text,
                new_x_value, email_require_flag,
                email_date, x_code_table_hist2user, x_change_date, osuser,
                triggering_record_type
               )
        VALUES (DECODE (v_action, 'I', :NEW.objid, :OLD.objid),
                DECODE (v_action, 'I', :NEW.x_code_name, :OLD.x_code_name),
                DECODE (v_action, 'I', :NEW.x_code_number, :OLD.x_code_number),
                DECODE (v_action, 'I', :NEW.x_code_type, :OLD.x_code_type),
                DECODE (v_action, 'I', :NEW.x_value, :OLD.x_value), v_text,
                DECODE (v_action, 'I', NULL, :NEW.x_value), v_email_req_flag,
                NULL, v_userid, SYSDATE, v_osuser,
                DECODE (v_action,
                        'I', 'INSERT',
                        'U', 'UPDATE',
                        'D', 'DELETE'
                       )
               );
EXCEPTION
   WHEN OTHERS
   THEN
      insert_error_tab_proc ('Exception caught ' || SQLERRM,
                             '',
                             'TRG_X_CODE_TABLE_BIUD'
                            );
END;
/