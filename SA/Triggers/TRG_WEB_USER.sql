CREATE OR REPLACE TRIGGER sa."TRG_WEB_USER"
BEFORE INSERT OR
       update of login_name, x_secret_questn, x_secret_ans, password ON sa.TABLE_WEB_USER
referencing old as old new as new
for each row
declare
   is_b2b_acct number;
begin
  if INSERTING then
      :new.X_LAST_UPDATE_DATE := sysdate;
  end if;
  if UPDATING then

    --CR52479 : Begin Code Changes
	/*
	select count(*)
    into is_b2b_acct
    from X_SITE_WEB_ACCOUNTS
    where SITE_WEB_ACCT2WEB_USER = :new.objid;

    if (is_b2b_acct > 0 and NVL(:NEW.LOGIN_NAME,'xx')        <> NVL(:OLD.LOGIN_NAME,'xx')) then
        raise_application_error( -20001, 'Login_name cannot be changed for B2B Accounts');
    end if;
	*/
    --CR52479 : Begin Code Changes

      IF NVL(:NEW.LOGIN_NAME,'xx')        <> NVL(:OLD.LOGIN_NAME,'xx') OR
         NVL(:new.X_SECRET_QUESTN,'xx')   <> NVL(:old.X_SECRET_QUESTN,'xx') or
         nvl(:new.x_secret_ans,'xx')      <> nvl(:old.x_secret_ans,'xx') or
	 nvl(:new.password,'xx') 	  <> nvl(:old.password,'xx') then

            :new.X_LAST_UPDATE_DATE := sysdate;
      end if;
  end if;
end trg_web_user;
/