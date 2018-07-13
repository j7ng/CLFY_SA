CREATE OR REPLACE TRIGGER sa.trg_crm_perms2priv_class
    AFTER INSERT OR DELETE OR UPDATE ON sa.x_crm_perms2priv_class
    FOR EACH ROW
declare
  v_trig_event varchar2(1);
begin

    if updating then
       raise_application_error(-20001,'update operation not allowed on this table');
    elsif inserting then
      v_trig_event := 'I';
    elsif deleting then
      v_trig_event := 'D';
    end if;

null;
    insert into x_crm_perms2priv_class_hist( PERMISSION_OBJID ,
                                             PRIV_CLASS_OBJID ,
                                             OSUSER ,
                                             CHANGE_BY ,
                                             CHANGE_DATE,
                                             TRIG_EVENT
                                            )
                                  values  ( nvl(:old.permission_objid, :new.permission_objid),
                                            nvl(:old.priv_class_objid,:new.priv_class_objid),
                                            sys_context('USERENV', 'OS_USER'),
                                            UPPER(user)  ,
                                            sysdate,
                                            v_trig_event);
end;
/