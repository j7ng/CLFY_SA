CREATE OR REPLACE procedure sa.create_clfy_user ( ip_first_name  in varchar2,
                             ip_last_name  in varchar2,
                             ip_employee_id  in  varchar2,
                             ip_access_priv in varchar2,
                             ip_sec_group in varchar2,
                             op_message out varchar2,
                             ip_login_name  in  varchar2 default null,
                             ip_email in varchar2 default null,
                             ip_debug_flag boolean default false)
as
--defaults no need to change--
ip_default_encoded_password varchar2(30):='[ScBhozpV1nkzzNPrE/';
ip_admin_user_objid number:=268435556;  --objid user attempting the creation of the account 'sa'
ip_site_objid number:=268435456;   --default site objid
ip_group varchar2(30):='call center';
found_rec number;

v_employee_objid number;
v_user_objid number;
v_wipbin_objid number;
v_time_bomb_objid number;
v_sec_grp_objid number;
v_login_name varchar2(50);
v_email varchar2(80);

Cursor C1 Is
Select * From Table_Privclass
where  s_class_name = upper(ip_access_priv );
--'call center agent';
--'app - supervisor';


r1 c1%rowtype;

Cursor C2 Is
Select * From Table_X_Sec_Grp
where x_grp_name = ip_sec_group;

r2 c2%rowtype;
sql_stmt varchar2(300);

begin
   if (ip_login_name is null ) then
      v_login_name := substr(ip_first_name,1,1)||ip_last_name;
   else
      v_login_name := ip_login_name;
   end if;
   if (ip_email is null ) then
      v_email := substr(ip_first_name,1,1)||ip_last_name||'@tracfone.com';
   else
      v_email := ip_email;
   end if;

   if ip_debug_flag then
    dbms_Output.Put_Line('=======CREATE CLFY USER ==============');
    dbms_Output.Put_Line('FN='''||Ip_First_Name||'''');
    dbms_Output.Put_Line('LN='''||Ip_Last_Name||'''');
    dbms_Output.Put_Line('EMPID='''||Ip_employee_id||'''');
    dbms_Output.Put_Line('UN='''||Ip_Login_Name||'''');
    dbms_Output.Put_Line('ACC='''||Ip_Access_Priv||'''');
    dbms_Output.Put_Line('SP='''||Ip_Sec_Group||'''');
    dbms_output.put_line('EMAIL='''||v_email||'''');
    dbms_Output.Put_Line('======= CLFY USER ==============');
   end if;
   select count(*)
   into found_rec
   from table_User u, all_users a
   where a.Username = u.S_Login_Name
   And  Username = Upper(V_Login_Name);
   If Found_Rec > 0 Then
      op_message:='user already exists';
      return;
   End If;

--  select * from table_privclass
-- Where  s_class_name = upper(
open c1;
fetch c1 into r1;
if c1%notfound then
   close c1;
   op_message := 'invalid privilege class';
   return;
else
   close c1;
end if;

open c2;
fetch c2 into r2;
if c2%notfound then
   close c2;
   op_message := 'invalid security group';
   return;
else
   v_sec_grp_objid:=r2.objid;
   close c2;
end if;

sql_stmt := 'grant connect to '||v_login_name||' identified by abc123';
execute immediate sql_stmt;

sql_stmt := 'grant clarify_user to '||v_login_name;
execute immediate sql_stmt;

select sa.seq('employee') into v_employee_objid from dual;
select sa.seq('user') into v_user_objid from dual;
select sa.seq('wipbin') into v_wipbin_objid from dual;
select sa.seq('time_bomb') into v_time_bomb_objid from dual;

--insert new wipbin
--
insert into table_wipbin (objid,
                          title,
                          s_title,
                          description,
                          ranking_rule,
                          icon_id,
                          dialog_id,
                          wipbin_owner2user)
                   values(v_wipbin_objid,
                          'default',
                          'default',
                          '',
                          '',
                          0,
                          375,
                          v_user_objid);

--
--insert new user
--
insert into table_user (objid,
                        login_name,
                        s_login_name,
                        password,
                        agent_id,
                        status,
                        equip_id,
                        cs_lic,
                        csde_lic,
                        cq_lic,
                        passwd_chg,
                        last_login,
                        clfo_lic,
                        cs_lic_type,
                        cq_lic_type,
                        csfts_lic,
                        csftsde_lic,
                        cqfts_lic,
                        web_login,
                        s_web_login,
                        web_password,
                        submitter_ind,
                        sfa_lic,
                        ccn_lic,
                        univ_lic,
                        node_id,
                        locale,
                        wireless_email,
                        alt_login_name,
                        s_alt_login_name,
                        user_default2wipbin,
                        user_access2privclass,
                        offline2privclass,
                        user2rc_config,
                        dev,
                        web_last_login,
                        web_passwd_chg)
                 values(v_user_objid,
                        v_login_name,
                        upper(v_login_name),
                        ip_default_encoded_password,
                        '',
                        1,
                        '',
                        to_date( '1/1/1753', 'mm/dd/yyyy'),
                        to_date( '1/1/1753', 'mm/dd/yyyy'),
                        to_date( '1/1/1753', 'mm/dd/yyyy'),
                        to_date( '1/1/1753', 'mm/dd/yyyy'),
                        to_date('1/1/1753', 'mm/dd/yyyy'),
                        to_date( '1/1/1753', 'mm/dd/yyyy'),
                        0,
                        0,
                        to_date( '1/1/1753', 'mm/dd/yyyy'),
                        to_date( '1/1/1753', 'mm/dd/yyyy'),
                        to_date( '1/1/1753', 'mm/dd/yyyy'),
                        '',
                        '',
                        'y2fejdgt1w6nslqtjbguveup9e4=',
                        0,
                        to_date( '1/1/1753', 'mm/dd/yyyy'),
                        to_date( '1/1/1753', 'mm/dd/yyyy'),
                        to_date( '1/1/1753', 'mm/dd/yyyy'),
                        '1',
                        0,
                        '',
                        '',
                        '',
                        v_wipbin_objid,
                        r1.objid,
                        268435758,
                        268436363,
                        1,
                        sysdate,
                        sysdate);


--insert new employee
--
insert into table_employee (objid,
                            first_name,
                            s_first_name,
                            last_name,
                            s_last_name,
                            mail_stop,
                            phone,
                            alt_phone,
                            fax,
                            beeper,
                            e_mail,
                            labor_rate,
                            field_eng,
                            acting_supvr,
                            available,
                            avail_note,
                            employee_no,
                            normal_biz_high,
                            normal_biz_mid,
                            normal_biz_low,
                            after_biz_high,
                            after_biz_mid,
                            after_biz_low,
                            work_group,
                            wg_strt_date,
                            site_strt_date,
                            voice_mail_box,
                            local_login,
                            local_password,
                            allow_proxy,
                            printer,
                            on_call_hw,
                            on_call_sw,
                            case_threshold,
                            title,
                            salutation,
                            x_q_maint,
                            x_error_code_maint,
                            x_select_trans_prof,
                            x_update_set,
                            x_order_types,
                            x_dashboard,
                            x_allow_script,
                            x_allow_roadside,
                            employee2user,
                            supp_person_off2site,
                            emp_supvr2employee)
                    values (v_employee_objid,
                            ip_first_name,
                            upper(ip_first_name),
                            ip_last_name,
                            upper(ip_last_name),

                            '',
                            '',
                            '',
                            '',
                            '',
                            v_email,
                            0.000000,
                            0,
                            0,
                            1,
                            '',
                            ip_employee_id,
                            '',
                            '',
                            '',
                            v_email,
                            v_email,
                            v_email,
                            ip_group,
                            to_date( '1/1/1753' , 'mm/dd/yyyy'),
                            to_date( '1/1/1753' , 'mm/dd/yyyy'),
                            '',
                            '',
                            '',
                            0,
                            '',
                            0,
                            0,
                            0,
                            '',
                            '',
                            0,
                            0,
                            0,
                            0,
                            0,
                            0,
                            0,
                            0,
                            v_user_objid,
                            ip_site_objid,
                            0);
--
-- insert new time_bomb (could be removed)
--

insert into table_time_bomb (
                         objid,
                         title,
                         escalate_time,
                         end_time,
                         focus_lowid,
                         focus_type,
                         suppl_info,
                         time_period,
                         flags,
                         left_repeat,
                         report_title,
                         property_set,
                         users,
                         creation_time)
                 values( v_time_bomb_objid,
                         v_login_name,
                         to_date( '1/1/1753', 'mm/dd/yyyy'),
                         to_date( '1/1/1753', 'mm/dd/yyyy'),
                         0,
                         0,
                         '',
                         0,
                         65540,
                         0,
                         '',
                         '',
                         '',
                         sysdate);
--
-- find security group objid
--

insert into mtm_user125_x_sec_grp1
                         (user2x_sec_grp,
                          x_sec_grp2user)
                  values (v_user_objid,
                          v_sec_grp_objid);

commit;

op_message:='user created';

end;
/