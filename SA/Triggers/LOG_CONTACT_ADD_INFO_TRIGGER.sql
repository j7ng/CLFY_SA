CREATE OR REPLACE TRIGGER sa."LOG_CONTACT_ADD_INFO_TRIGGER"
before insert or update on sa.table_x_contact_add_info
referencing new as new old as old
for each row
declare
  v_action varchar2(10);
begin

  :new.x_last_update_date := sysdate;

  if inserting then
    v_action := 'INSERTING';
  end if;

  if updating then
    v_action := 'UPDATING';
  end if;

  dbms_output.put_line(v_action);

  if NVL(:old.x_do_not_email,10) = NVL(:new.x_do_not_email,10) and -- CR51354_Log_history_for_OPT_INOUT_on_communications 10/18/17 Tim ADDED NVL for validation test.
     NVL(:old.X_DO_NOT_PHONE,10) = NVL(:new.x_do_not_phone,10) and
     NVL(:old.X_DO_NOT_SMS,10) = NVL(:new.X_DO_NOT_SMS,10) and
     NVL(:old.X_DO_NOT_MAIL,10) = NVL(:new.X_DO_NOT_MAIL,10) and
     NVL(:old.x_do_not_mobile_ads,10) = NVL(:new.x_do_not_mobile_ads,10) and
     NVL(:old.x_prerecorded_consent,10) = NVL(:new.x_prerecorded_consent,10) then
    -- DON'T LOG ANYTHING, BECAUSE NOTHING CHANGED
    return;
  end if;

  insert into table_x_cai_log
    (objid,
     action,
     old_em_val,
     new_em_val,
     old_ph_val,
     new_ph_val,
     old_sms_val,
     new_sms_val,
     old_mail_val,
     new_mail_val,
     old_mads_val,
     new_mads_val,
     old_prerec_consent,
     new_prerec_consent,
     add_info2contact,
     add_info2user,
     change_date,
     cai_objid,
     source_system,
     add_info2web_user,
     x_esn,
     x_min)
  values
    (table_x_cai_log_seq.nextval,
     v_action,
     :old.X_DO_NOT_EMAIL,
     :new.X_DO_NOT_EMAIL,
     :old.X_DO_NOT_PHONE,
     :new.X_DO_NOT_PHONE,
     :old.X_DO_NOT_SMS,
     :new.X_DO_NOT_SMS,
     :old.X_DO_NOT_MAIL,
     :new.X_DO_NOT_MAIL,
     :old.x_do_not_mobile_ads,
     :new.x_do_not_mobile_ads,
     :old.x_prerecorded_consent,
     :new.x_prerecorded_consent,
     :new.add_info2contact,
     :new.add_info2user,
     sysdate,
     :new.objid,
     :new.source_system,
     :new.add_info2web_user,
     :new.x_esn,
     :new.x_min
     );

end;
/