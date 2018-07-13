CREATE OR REPLACE TRIGGER sa."TRG_X_DEALER_COMMISSIONS"
BEFORE INSERT OR UPDATE OR DELETE ON sa.x_dealer_commissions
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
v_action VARCHAR2(500);
v_osuser  varchar2(50);
v_userid varchar2(30);
v_col_name varchar2(300);
v_old_val varchar2(100);
v_new_val varchar2(100);
BEGIN
      IF INSERTING  THEN
         v_action := 'I' ;
      ELSIF  UPDATING THEN
         v_action := 'U' ;
      ELSE
         v_action := 'D' ;
      END IF;

      select objid,
             sys_context('USERENV','OS_USER')
      into  v_userid,
            v_osuser
      from table_user where upper(login_name) = upper(user);

   if :new.DEALER_COMMS2EMPLOYEE <> :old.DEALER_COMMS2EMPLOYEE then
      raise_application_error(-20001,'Changing of the DEALER_COMMS2EMPLOYEE field is not allowed');
   end if;

   if nvl(:new.ROLE,' ') <> nvl(:old.ROLE,' ') then
        v_col_name := 'ROLE';
        v_old_val := :old.ROLE;
        v_new_val := :NEW.ROLE;
   end if;

   if nvl(:new.TITLE,' ') <> nvl(:old.TITLE,' ') then
        v_col_name := 'TITLE';
        v_old_val := :old.TITLE;
        v_new_val := :NEW.TITLE;
   end if;

   if nvl(:new.SIGNUP_ID,' ') <> nvl(:old.SIGNUP_ID,' ') then
        v_col_name := 'SIGNUP_ID';
        v_old_val := :old.SIGNUP_ID;
        v_new_val := :NEW.SIGNUP_ID;
   end if;

   if nvl(:new.SIGNUP_CONFIRM_CODE,' ') <> nvl(:old.SIGNUP_CONFIRM_CODE,' ') then
        v_col_name := 'SIGNUP_CONFIRM_CODE';
        v_old_val := :old.SIGNUP_CONFIRM_CODE;
        v_new_val := :NEW.SIGNUP_CONFIRM_CODE;
   end if;

   if nvl(:new.TERMS_ACCEPT_DATE,trunc(sysdate)) <> nvl(:old.TERMS_ACCEPT_DATE,trunc(sysdate)) then
        v_col_name := 'TERMS_ACCEPT_DATE';
        v_old_val := to_char(:old.TERMS_ACCEPT_DATE,'MM/DD/YYYY HH24:MI:SS');
        v_new_val := to_char(:NEW.TERMS_ACCEPT_DATE,'MM/DD/YYYY HH24:MI:SS');
   end if;

   if nvl(:new.PROVIDER_ID,' ') <> nvl(:old.PROVIDER_ID,' ') then
        v_col_name := 'PROVIDER_ID';
        v_old_val := :old.PROVIDER_ID;
        v_new_val := :NEW.PROVIDER_ID;
   end if;

   if nvl(:new.PROV_CUST_STATUS,' ') <> nvl(:old.PROV_CUST_STATUS,' ') then
        v_col_name := 'PROV_CUST_STATUS';
        v_old_val := :old.PROV_CUST_STATUS;
        v_new_val := :NEW.PROV_CUST_STATUS;
   end if;

   if nvl(:new.PROV_CUST_LAST_UPDATE,trunc(sysdate)) <> nvl(:old.PROV_CUST_LAST_UPDATE,trunc(sysdate)) then
        v_col_name := 'PROV_CUST_LAST_UPDATE';
        v_old_val := to_char(:old.PROV_CUST_LAST_UPDATE,'MM/DD/YYYY HH24:MI:SS');
        v_new_val := to_char(:NEW.PROV_CUST_LAST_UPDATE,'MM/DD/YYYY HH24:MI:SS');
   end if;

   if nvl(:new.PHONE_NUM,' ') <> nvl(:old.PHONE_NUM,' ') then
        v_col_name := 'PHONE_NUM';
        v_old_val := :old.PHONE_NUM;
        v_new_val := :NEW.PHONE_NUM;
   end if;

   insert into x_dealer_commissions_hist
               (emp_objid,
                col_name,
                old_val,
                new_val,
                operation,
                change_date,
                osuser)
        values (:new.DEALER_COMMS2EMPLOYEE,
                v_col_name,
                v_old_val,
                v_new_val,
                v_action,
                sysdate,
                v_osuser);
exception
when others then
null ;
end;
/