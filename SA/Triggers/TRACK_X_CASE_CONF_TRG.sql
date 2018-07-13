CREATE OR REPLACE TRIGGER sa.track_x_case_conf_trg
     BEFORE INSERT OR DELETE OR UPDATE ON sa.TABLE_X_CASE_CONF_HDR     FOR EACH ROW
DECLARE
      v_ChangeType CHAR(1);
    BEGIN
      IF INSERTING THEN
       v_ChangeType := 'I';
       INSERT INTO sa.TRACK_X_CASE_CONF_HDR
              ( OBJID,
    X_CASE_TYPE_OLD,
    X_CASE_TYPE_NEW,
    X_TITLE_OLD,
    X_TITLE_NEW,
    X_DISPLAY_TITLE_OLD,
    X_DISPLAY_TITLE_NEW,
    CHANGE_TYPE,
    OSUSER,
    DB_USER,
                CHANGE_DATE)
              VALUES
              (:new.OBJID,
               NULL,
               :new.X_CASE_TYPE,
               NULL,
               :new.X_TITLE,
   NULL,
               :new.X_DISPLAY_TITLE,
        'I',
               sys_context('USERENV', 'OS_USER'),
               UPPER(user),
               sysdate);
     ELSIF UPDATING THEN
       v_ChangeType := 'U';
              INSERT INTO sa.TRACK_X_CASE_CONF_HDR
               ( OBJID,
    X_CASE_TYPE_OLD,
    X_CASE_TYPE_NEW,
    X_TITLE_OLD,
    X_TITLE_NEW,
    X_DISPLAY_TITLE_OLD,
    X_DISPLAY_TITLE_NEW,
    CHANGE_TYPE,
    OSUSER,
    DB_USER,
                CHANGE_DATE)
              VALUES
              (:old.OBJID,
               :old.X_CASE_TYPE,
               :new.X_CASE_TYPE,
               :old.X_TITLE,
               :new.X_TITLE,
         :old.X_DISPLAY_TITLE,
               :new.X_DISPLAY_TITLE,
        'U',
               sys_context('USERENV', 'OS_USER'),
               UPPER(user),
               sysdate);
     ELSE
       v_ChangeType := 'D';
           INSERT INTO sa.TRACK_X_CASE_CONF_HDR
              ( OBJID,
    X_CASE_TYPE_OLD,
    X_CASE_TYPE_NEW,
    X_TITLE_OLD,
    X_TITLE_NEW,
    X_DISPLAY_TITLE_OLD,
    X_DISPLAY_TITLE_NEW,
    CHANGE_TYPE,
    OSUSER,
    DB_USER,
                CHANGE_DATE)
              VALUES
              (:old.OBJID,
               :old.X_CASE_TYPE,
               NULL,
               :old.X_TITLE,
               NULL,
         :old.X_DISPLAY_TITLE,
               NULL,
        'D',
               sys_context('USERENV', 'OS_USER'),
               UPPER(user),
               sysdate);
     END IF;
   END track_x_case_conf_trg;
/