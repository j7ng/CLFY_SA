CREATE OR REPLACE TRIGGER sa."TRG_TABLE_USER_AIUD"
  AFTER INSERT OR DELETE OR UPDATE OF user_access2privclass, password, status, dev, x_end_date
  ON sa.table_user
  FOR EACH ROW

DECLARE
  FUNCTION get_privclass (ip_objid in number) return varchar2 is
      privc_name table_privclass.class_name%type;
  begin
      if ip_objid is null then
         return 'NULL';
      end if;
      select class_name
      into privc_name
      from table_privclass
      where objid = ip_objid;

      return(privc_name);
  exception
    when others then
       return(sqlcode);
  end;

  PROCEDURE insert_hist(ip_user_objid NUMBER,
                        ip_user_name varchar2,
                       ip_col_name    VARCHAR2,
                       ip_new_val     VARCHAR2,
                       ip_old_val     VARCHAR2,
                       ip_changed_by  varchar2,
                       ip_action      VARCHAR2) IS
   old_pc table_privclass.class_name%type;
   new_pc table_privclass.class_name%type;
  BEGIN

    INSERT INTO table_user_hist
              ( objid         ,
                user_hist2user,
                column_name   ,
                old_value     ,
                new_value     ,
                changed_date  ,
                changed_by    ,
                os_user       ,
                trig_event)
         VALUES
              ( seq_user_hist.NEXTVAL,
                ip_user_objid,
                ip_col_name  ,
                ip_old_val   ,
                ip_new_val   ,
                SYSDATE      ,
                UPPER(user)  ,
                nvl(ip_changed_by,sys_context('USERENV', 'OS_USER')),
                ip_action );


    if ( ip_col_name = 'USER_ACCESS2PRIVCLASS' ) then

       old_pc := get_privclass(ip_old_val);
       new_pc := get_privclass(ip_new_val);

       insert into sa.adfcrm_activity_log(objid,
                                       agent,
                                       log_date,
                                       flow_name,
                                       reason)
                              values  (sa.seq_adfcrm_activity_log.nextval ,
                                       ip_changed_by,
                                       sysdate,
                                       'User Privilege Class',
                                       'Changed PrivClass from ('||old_pc||') to ('
                                         ||new_pc||') for user '||ip_user_name );
    end if;


  END;

BEGIN

  DBMS_OUTPUT.PUT_LINE('Trigger fired trg_user_table');

  IF inserting THEN
    insert_hist(:NEW.objid,
                :new.s_login_name,
                'USER_ACCESS2PRIVCLASS',
                :NEW.user_access2privclass,
                '',
                :new.S_ALT_LOGIN_NAME,
                'I');
    RETURN;
  ELSIF deleting THEN
    insert_hist(:NEW.objid,
                :new.s_login_name,
                'USER_ACCESS2PRIVCLASS',
                '',
                :OLD.user_access2privclass,
                :old.S_ALT_LOGIN_NAME,
                'D');
    RETURN;
  END IF;

  ------------------------------------------------------------------
  --check for all changed columns and write a row for each change --
  ------------------------------------------------------------------
  IF NVL(:OLD.user_access2privclass, 0) <> NVL(:NEW.user_access2privclass, 0) THEN
    insert_hist(:NEW.objid,
                :new.s_login_name,
                'USER_ACCESS2PRIVCLASS',
                :NEW.user_access2privclass,
                :OLD.user_access2privclass,
                :new.S_ALT_LOGIN_NAME,
                'U');
  END IF;

  IF NVL(:OLD.PASSWORD, 'NULL') <> NVL(:NEW.PASSWORD, 'NULL') THEN
    insert_hist(:new.objid,
                :new.s_login_name,
                'PASSWORD',
                ''        ,
                ''        ,
                :new.S_ALT_LOGIN_NAME,
                'U');
  END IF;

  IF NVL(:OLD.status, 0) <> NVL(:NEW.status, 0) THEN
    insert_hist(:NEW.objid ,
                :new.s_login_name,
                'STATUS'   ,
                :NEW.status,
                :OLD.status,
                :new.S_ALT_LOGIN_NAME,
                'U');
  END IF;

  IF NVL(:OLD.dev, 0) <> NVL(:NEW.dev, 0) THEN
    insert_hist(:NEW.objid,
                :new.s_login_name,
                'DEV'     ,
                :NEW.dev  ,
                :OLD.dev  ,
                :new.S_ALT_LOGIN_NAME,
                'U');
  END IF;

  IF NVL(:OLD.x_end_date, '01-JAN-2500') <> NVL(:NEW.x_end_date, '01-JAN-2500') THEN
    insert_hist(:NEW.objid,
                :new.s_login_name,
                'X_END_DATE'   ,
                :NEW.x_end_date,
                :OLD.x_end_date,
                :new.S_ALT_LOGIN_NAME,
                'U');
  END IF;
  ----------------------------------------------------------------------
  --END check for all changed columns and write a row for each change --
  ----------------------------------------------------------------------

END;
/