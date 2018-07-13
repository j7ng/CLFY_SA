CREATE OR REPLACE PROCEDURE sa."CREATE_MODIFY_SMOB_USER" (
 IP_EMAIL                 VARCHAR2,
 IP_PARENT_USER_NAME      VARCHAR2,
 IP_ROLE                  VARCHAR2,
 IP_FIRST_NAME            VARCHAR2,
 IP_LAST_NAME             VARCHAR2,
 IP_TITLE                 VARCHAR2,
 IP_PHONE_NUM             VARCHAR2,
 IP_ADDRESS1              VARCHAR2,
 IP_ADDRESS2              VARCHAR2,
 IP_CITY                  VARCHAR2,
 IP_STATE                 VARCHAR2,
 IP_ZIP                   VARCHAR2,
 IP_EPAY_ID               vARCHAR2,
 IP_EPAY_STATUS           VARCHAR2,
 IP_EPAY_LAST_UPDATE      DATE,
 OP_EMPLOYEE_NO       OUT VARCHAR2,
 OP_PASSWORD          OUT VARCHAR2,
 OP_MESSAGE           OUT VARCHAR2,
 IP_PWD_RESET_ONLY     VARCHAR2 default 'N'
) is
---------------------------------------------------------------------------------------------
--$RCSfile: create_modify_smob_user.sql,v $
--$Revision: 1.7 $
--$Author: akhan $
--$Date: 2014/04/09 21:58:24 $
--$Log: create_modify_smob_user.sql,v $
--Revision 1.7  2014/04/09 21:58:24  akhan
--change the senders email
--
--Revision 1.3  2013/09/13 22:31:17  akhan
--Modified to fix the email verbiage and rep spiff
--
--Revision 1.2  2013/06/15 01:24:42  akhan
--modified proc to send out email and generate spiff code upon user creation
--
---------------------------------------------------------------------------------------------
 ccu_output   varchar2(500);
 v_contact_objid number;
 v_len number;
 v_spiff varchar2(30);
 v_err varchar2(1500);
 v_user_count number := 0;
 ctr number := 0;
 emp_objid table_employee.objid%type;
 v_sup_id table_employee.objid%type;
 v_term_date date;
 v_epay_id          x_dealer_commissions.provider_id%type;
 v_epay_status      x_dealer_commissions.prov_cust_status%type;
 v_epay_last_update x_dealer_commissions.prov_cust_last_update%type;
 v_phone_num        x_dealer_commissions.phone_num%type;
 activity varchar2(100) := 'Begin';
-------------------------------------------------------------------------
procedure sendm(ip_pwd_reset_only varchar2,
                ip_pwd in varchar2,
                ip_email in varchar2,
                ip_emp_no in varchar2,
                ip_spiff in varchar2 ) is
msg_text varchar2(4000);
subject_line varchar2(200);
v_mail_result varchar2(100);
dummy1 varchar2(200);
dummy_date date;
dummy_num number;
begin

   SCRIPTS_PKG.GET_SCRIPT_PRC(
        IP_SOURCESYSTEM => 'ALL',
        IP_BRAND_NAME => 'GENERIC',
        IP_SCRIPT_TYPE => 'EMAIL',
        IP_SCRIPT_ID => '00031',
        IP_LANGUAGE => 'ENGLISH',
        IP_CARRIER_ID => null,
        IP_PART_CLASS => null,
        OP_OBJID => dummy1,
        OP_DESCRIPTION => dummy1,
        OP_SCRIPT_TEXT => subject_line,
        OP_PUBLISH_BY => dummy1,
        OP_PUBLISH_DATE => dummy_date,
        OP_SM_LINK => dummy1);
   SCRIPTS_PKG.GET_SCRIPT_PRC(
        IP_SOURCESYSTEM => 'ALL',
        IP_BRAND_NAME => 'GENERIC',
        IP_SCRIPT_TYPE => 'EMAIL',
        IP_SCRIPT_ID => '00032',
        IP_LANGUAGE => 'ENGLISH',
        IP_CARRIER_ID => null,
        IP_PART_CLASS => null,
        OP_OBJID => dummy1,
        OP_DESCRIPTION => dummy1,
        OP_SCRIPT_TEXT => msg_text,
        OP_PUBLISH_BY => dummy1,
        OP_PUBLISH_DATE => dummy_date,
        OP_SM_LINK => dummy1 );
  if  msg_text not like '%SCRIPT MISSING%' then
       msg_text := replace(msg_text,'[Email_ID]',ip_email);
       msg_text := replace(msg_text,'[Password]',ip_pwd);
       msg_text := replace(msg_text,'[PIN]',ip_emp_no);
       msg_text := replace(msg_text,'[Spiff_Code]',ip_spiff);
  else
      msg_text := 'Your Pwd has been set/reset to : ' || ip_pwd;
      msg_text := msg_text||'<br><br>Please keep the following info in safe place';
      msg_text := msg_text || '<br>'||'PIN: '|| ip_emp_no||'(You will need this when requesting Password reset)';
      msg_text := msg_text || '<br>'||'SPIFF Confirmation Code: ' || ip_spiff;
 end if;
 if subject_line like '%SCRIPT MISSING%'  then
    subject_line := 'Welcome to Simple Mobile!';
 end if;
    sa.send_mail (subject_line,
                 'newdealer@tracfone.com',
                 ip_email,
                 msg_text,
                 v_mail_result);
end;
-------------------------------------------------------------------------
function get_parent_spiff_etc (ip_sup_id       in number,
                               op_term_date    out date,
                               op_epay_id      out varchar2,
                               op_epay_status  out varchar2,
                               op_epay_last_update out date)
return varchar2 is
-------------------------------------------------------------------------
 v_parent_spiff x_dealer_commissions.signup_confirm_code%type;
begin
     select signup_confirm_code ,
            terms_accept_date,
            provider_id,
            prov_cust_status,
            prov_cust_last_update
     into v_parent_spiff,
          op_term_date,
          op_epay_id,
          op_epay_status,
          op_epay_last_update
     from sa.x_dealer_commissions
     where dealer_comms2employee = ip_sup_id;
return v_parent_spiff;
exception
 when others then
  v_parent_spiff := '-1';
end;
-------------------------------------------------------------------------
function generate_spiff return varchar2 is
-------------------------------------------------------------------------
  v_spiff_temp varchar2(20);
  v_cnt number := 1;
begin
  activity := 'Generate random Spiff_confirm_code';
  while v_cnt > 0 --exit when not found
  loop
    v_spiff_temp:= 'SM' || round(dbms_random.value('100000000000','999999999999') )  ;
    select count(*)
    into v_cnt
    from sa.x_dealer_commissions
    where signup_confirm_code = v_spiff_temp;
  end loop;
  return v_spiff_temp;
end generate_spiff;
-------------------------------------------------------------------------
procedure insert_contact(p_first_name in varchar2,
                         p_last_name in varchar2,
                         p_address1 in varchar2,
                         p_address2 in varchar2,
                         p_city in varchar2,
                         p_state in varchar2,
                         p_zip in varchar2,
                         p_email in varchar2,
                         p_alt_phone in varchar2,
                         p_dateofbirth in date,
                         op_contact_objid out number) is
-------------------------------------------------------------------------
v_con_objid number := -1;
begin
activity := 'Inserting into table contact';
begin
   select objid
   into v_con_objid
   from table_contact
   where s_first_name= upper(p_first_name)
   and  s_last_name= upper(p_last_name)
   and x_cust_id like 'SMD%';
exception
  when others then
    v_con_objid := -1;
end;
if (v_con_objid  = -1 ) then
       v_con_objid  := sa.seq('contact');
       Insert into table_contact (OBJID,
            FIRST_NAME,
            S_FIRST_NAME,
            LAST_NAME,
            S_LAST_NAME,
            PHONE,
            E_MAIL,
            ADDRESS_1,
            ADDRESS_2,
            CITY,
            STATE,
            ZIPCODE,
            STATUS,
            DEV,
            X_CUST_ID,
            X_DATEOFBIRTH,
            X_NO_ADDRESS_FLAG,
            X_NO_NAME_FLAG,
            X_NO_PHONE_FLAG,
            UPDATE_STAMP,
            X_EMAIL_STATUS,
            X_HTML_OK,
            X_AUTOPAY_UPDATE_FLAG,
            X_SERV_DT_REMIND_FLAG,
            X_SIGN_REQD,
            X_SPL_OFFER_FLG,
            X_SPL_PROG_FLG)
       values (v_con_objid,                --OBJID,
             p_first_name,                 --FIRST_NAME,
             upper(p_first_name),          --S_FIRST_NAME,
             p_last_name,                  --LAST_NAME,
             upper(p_last_name),           --S_LAST_NAME,
             p_alt_phone,                  --PHONE,
             p_email,                      --E_MAIL,
             p_address1,                   --ADDRESS_1,
             p_address2,                   --ADDRESS_2,
             p_city,                       --CITY,
             p_state,                      --STATE,
             p_zip,                        --ZIPCODE,
             0,                            --STATUS,
             1,                            --DEV,
             'SMD'||custid.nextval,        --X_CUST_ID,
             p_dateofbirth,                --X_DATEOFBIRTH,
             0,                            --X_NO_ADDRESS_FLAG,
             0,                            --X_NO_NAME_FLAG,
             0,                            --X_NO_PHONE_FLAG,
             sysdate,                      --UPDATE_STAMP,
             0,                            --X_EMAIL_STATUS,
             0,                            --X_HTML_OK,
             0,                            --X_AUTOPAY_UPDATE_FLAG,
             1,                            --X_SERV_DT_REMIND_FLAG,
             1,                            --X_SIGN_REQD,
             0,                            --X_SPL_OFFER_FLG,
             0);                           --X_SPL_PROG_FLG)
else
  update table_contact
  set phone = p_alt_phone,
      e_mail = p_email,
      address_1 = p_address1,
      address_2 = p_address2,
      city      = p_city,
      state     = p_state,
      zipcode   = p_zip,
      x_dateofbirth = p_dateofbirth,
      update_stamp=sysdate
  where objid = v_con_objid;
end if;
  op_contact_objid := v_con_objid;
exception
  when others then
   dbms_output.put_line('activity: ' || sqlerrm);
end;
-------------------------------------------------------------------------------
------Main/MAIN/main/
-------------------------------------------------------------------------------
begin
       if ( nvl(ip_email,' ') not like '%@%.%' ) then
            op_message := 'Invalid email provided';
            return;
       end if;
       begin
          select e.objid
          into v_sup_id
          from table_employee e
          where   e.employee2user in (select objid from table_user where agent_id = 'SMOB'
                                   and s_login_name = upper(nvl(ip_parent_user_name,'SA@MTSINT.COM')));
       exception
           when others then
               op_message := 'Supervisor data '||sqlerrm;
            return;
       end;
       begin
              activity:= 'Create Clarify User';
               ccu_output := null;
               select sequ_smob_employee_no.nextval
               into op_employee_no
               from dual;
               Create_Clarify_User
                        ('SMOB_ACCESS_PC', --** Change me to Create_Clarify_User
                           'SMOB_ACCESS',
                           ip_email,
                           ip_first_name,
                           ip_last_name,
                           op_EMPLOYEE_NO,
                           ip_email,
                           ccu_output,
                           op_employee_no --sip_email
                            );
                if ccu_output like 'Invalid%' then
                  raise_application_error(-20001,ccu_output);
                elsif (ccu_output not like '%already%' or IP_PWD_RESET_ONLY = 'Y') then
                    activity := 'Updating table_user';
                     op_password := dbms_random.string('A', 8);
                     update table_user
                     set web_password = sa.encryptPassword(op_password),
                         x_start_date = sysdate,
                         web_passwd_chg=sysdate,
                         status=1,
                         dev = 1,
                         submitter_ind=0,
                         web_last_login=sysdate
                     where s_login_name = upper(ip_email);
                  if ip_PWD_RESET_ONLY='Y' then
                      goto SEND_MAIL;
                  end if;
                end if;
        end;
         insert_contact(substr(ip_first_name,1,30),
                        substr(ip_last_name,1,30),
                        ip_address1,
                        ip_address2,
                        ip_city,
                        ip_state,
                        ip_zip,
                        ip_email,
                        '', --rec.phone_num,
                        null,
                        v_contact_objid);
       -- dbms_output.put_line('v_contact_objid: ' || v_contact_objid );
         begin
            activity := 'Getting emp_objid';
            select e.objid
            into  emp_objid
            from table_employee e
            where e.employee2user in (select objid from table_user where agent_id = 'SMOB'
                        and s_login_name = upper(ip_email));
         exception
           when others then
               op_message := 'User creation Error '||sqlerrm;
               return;
         end;
         activity := 'Updating table_employee with v_sup_id and v_contact_objid';
         update table_employee a
         set EMP_SUPVR2EMPLOYEE = v_sup_id,
             employee2contact = v_contact_objid
         where objid = emp_objid ;
         begin
             activity := 'inserting into x_dealer_commissions';
             if (ip_role <> 'REP') then

                 v_spiff := generate_spiff;
                 v_term_date := sysdate;
                 v_epay_id   := ip_epay_id;
                 v_epay_status := ip_epay_status;
                 v_epay_last_update := ip_epay_last_update;
             else

                 v_spiff := get_parent_spiff_etc (v_sup_id,v_term_date,v_epay_id,v_epay_status,v_epay_last_update);

             end if;
             insert into x_dealer_commissions( objid ,
                                         dealer_comms2employee,
                                         role,
                                         title,
                                         signup_id,
                                         signup_confirm_code,
                                         terms_accept_date,
                                         provider_id,
                                         prov_cust_status,
                                         prov_cust_last_update,
                                         phone_num)
                                values ( seq_dealer_commissions.nextval, --objid
                                         emp_objid,                      --dealer_comms2employee
                                         ip_role,                        --role
                                         ip_title,                       --title
                                         ip_email,                       --signup_id
                                         v_spiff,                        --signup_confirm_code
                                         v_term_date,                    --terms_accept_date
                                         v_epay_id,                      --provider_id
                                         v_epay_status,                  --prov_cust_status
                                         v_epay_last_update,             --prov_cust_last_update
                                         v_phone_num);                   --phone_num
        exception
         when dup_val_on_index then
          activity := 'updating x_dealer_commissions';
          update  x_dealer_commissions
          set role = ip_role,
              title = ip_title,
              provider_id = ip_epay_id,
              prov_cust_status = ip_epay_status,
              prov_cust_last_update = ip_epay_last_update,
              phone_num = ip_phone_num
           where dealer_comms2employee = emp_objid
           and ip_epay_id is not null;
        end;
<<SEND_MAIL>>
sendm(IP_PWD_RESET_ONLY,op_password,upper(ip_email), op_employee_no,v_spiff);
 commit;
 op_message := 'Success';
exception
 when others then
  op_message := 'Error '||sqlerrm;
end;
/