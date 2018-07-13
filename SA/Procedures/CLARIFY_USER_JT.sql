CREATE OR REPLACE Procedure sa.Clarify_User_jt (
Ip_Priviledge_Class In Varchar2,
Ip_Sec_Grp_Name  In  varchar2,
Ip_Login_Name  In  Varchar2,
Ip_First_Name  In Varchar2,
Ip_Last_Name  In Varchar2,
Ip_Employee_Id  In  Varchar2,
Ip_Email In Varchar2,
OP_MESSAGE out varchar2)
AS

--DEFAULTS NO NEED TO CHANGE--
IP_DEFAULT_ENCODED_PASSWORD VARCHAR2(30):='[ScBhozpV1nkzzNPrE/';
IP_ADMIN_USER_OBJID NUMBER:=268435556;  --objid user attempting the creation of the account 'sa'
Ip_Site_Objid Number:=268435456;   --Default SITE OBJID
Ip_Group Varchar2(30):='Call Center';
Found_Rec Number;

V_Employee_Objid Number;
V_USER_OBJID number;
V_Wipbin_Objid Number;
V_Time_Bomb_Objid Number;
V_SEC_GRP_OBJID number;

cursor c1 is
Select * From Table_Privclass
Where  S_Class_Name = Upper(Ip_Priviledge_Class );

r1 c1%rowtype;

cursor c2 is
select * from table_x_sec_grp
where x_grp_name = Ip_Sec_Grp_Name;

R2 C2%Rowtype;
Sql_Stmt Varchar2(300);

BEGIN

Select nvl(objid, 0) 
Into Found_Rec
From TABLE_User
Where S_LOGIN_NAME = upper(Ip_Login_Name);


Open C1;
Fetch C1 Into R1;
If C1%Notfound Then
   Close C1;
   Op_Message :=  'Invalid Privilege Class -- '||Ip_Priviledge_Class ;
   Return;
Else
   Close C1;
end if;

Open c2;
fetch c2 into r2;
if c2%notfound then
   close c2;
   Op_Message := 'Invalid Security Group -- '||Ip_Sec_Grp_Name;
   return;
else
   V_SEC_GRP_OBJID:=r2.objid;
   close c2;
end if;

If Found_Rec>0 Then
  
   update table_user set user_access2privclass=r1.objid where s_login_name=upper(Ip_Login_Name);
  update  mtm_user125_x_sec_grp1   set  X_SEC_GRP2USER= r2.objid where USER2X_SEC_GRP=Found_Rec ;
 commit;
 op_message:='User Updated -- '||Ip_Login_Name ;
else

SELECT sa.seq('employee') into V_EMPLOYEE_OBJID FROM dual;
SELECT sa.seq('user') into V_USER_OBJID FROM dual;
Select sa.Seq('wipbin') Into V_Wipbin_Objid From Dual;
SELECT sa.seq('time_bomb') into V_TIME_BOMB_OBJID FROM dual;

--Insert new wipbin
--
insert into table_wipbin (objid,title, S_title,description,ranking_rule,icon_id,dialog_id,wipbin_owner2user)
values(V_Wipbin_Objid,'default','DEFAULT','','',0,375, V_USER_OBJID);

--
--insert new user
--
insert into table_user (objid,login_name, S_login_name,password,agent_id,status,equip_id,
CS_Lic,CSDE_Lic,CQ_Lic,passwd_chg,last_login,CLFO_Lic,cs_lic_type,cq_lic_type,
CSFTS_Lic,CSFTSDE_Lic,CQFTS_Lic,web_login,S_web_login,web_password,submitter_ind,
SFA_LIC,CCN_LIC,UNIV_LIC,NODE_ID,LOCALE,WIRELESS_EMAIL,ALT_LOGIN_NAME,
S_alt_login_name,user_default2wipbin,user_access2privclass,offline2privclass,USER2RC_CONFIG,dev, WEB_LAST_LOGIN, WEB_PASSWD_CHG)
 values(V_USER_OBJID,IP_LOGIN_NAME,upper(IP_LOGIN_NAME),
IP_DEFAULT_ENCODED_PASSWORD,'',1,'', TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
 TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
SYSDATE, SYSDATE,
 TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
0,0, TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),'','','Y2fEjdGT1W6nsLqtJbGUVeUp9e4=',0,
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
To_Date( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),'1',
0,'','','', V_WIPBIN_OBJID, r1.objid, 268435758,268436363,1,SYSDATE, SYSDATE);


--insert new employee
--
insert into table_employee (objid,first_name, S_first_name,last_name, S_last_name,mail_stop,phone,alt_phone,fax,beeper,e_mail,labor_rate,field_eng,acting_supvr,available,avail_note,
employee_no,normal_biz_high,normal_biz_mid,normal_biz_low,after_biz_high,after_biz_mid,after_biz_low,work_group,
wg_strt_date,site_strt_date,voice_mail_box,local_login,local_password,allow_proxy,printer,on_call_hw,on_call_sw,
case_threshold,title,salutation,x_q_maint,x_error_code_maint,x_select_trans_prof,x_update_set,x_order_types,
x_dashboard,x_allow_script,x_allow_roadside,employee2user,supp_person_off2site,emp_supvr2employee)
 values
(V_EMPLOYEE_OBJID,IP_FIRST_NAME,upper(IP_FIRST_NAME),
IP_LAST_NAME,upper(IP_LAST_NAME),
'','','','','',IP_EMAIL,0.000000,0,0,1,'',IP_EMPLOYEE_ID,'','','',IP_EMAIL,
IP_EMAIL,IP_EMAIL,IP_GROUP, TO_DATE( '1/1/1753 00:00:00' , 'MM/DD/YYYY HH24:MI:SS'),
 TO_DATE( '1/1/1753 00:00:00' , 'MM/DD/YYYY HH24:MI:SS'),
'','','',0,'',0,0,0,'','',0,0,0,0,0,0,0,0, V_USER_OBJID, IP_SITE_OBJID, 0);
--
-- insert new time_bomb (could be removed)
--

insert into table_time_bomb (
objid,title,escalate_time,end_time,focus_lowid,focus_type,suppl_info,time_period,flags,left_repeat,
report_title,property_set,users,creation_time) values(
V_TIME_BOMB_OBJID,
IP_LOGIN_NAME, TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),0,0,'',0,65540,0,'','','',sysdate);
--
-- Find Security Group OBJID
--

Insert Into Mtm_User125_X_Sec_Grp1
    (User2x_Sec_Grp, X_Sec_Grp2user)
    Values (V_User_Objid,V_Sec_Grp_Objid);

Commit;
op_message:='User Created -- '||Ip_Login_Name ;
end if;

End Clarify_User_jt;
/