CREATE OR REPLACE PROCEDURE sa."CREATE_CLARIFY_USER" (
              ip_priviledge_class IN VARCHAR2,
              ip_sec_grp_name  IN  VARCHAR2,
              ip_login_name  IN  VARCHAR2,
              ip_first_name  IN VARCHAR2,
              ip_last_name  IN VARCHAR2,
              ip_employee_id  IN  VARCHAR2,
              ip_email IN VARCHAR2,
              op_message OUT VARCHAR2,
              ip_site_id IN VARCHAR2 DEFAULT NULL) AS

/******************************************************************************/
/* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved              */
/* Author       :   Natalio Guada                                             */
/* Date         :   05/12/2010                                                */
/* Revisions   :                                                              */
/* Version  Date      Who     Purpose                                         */
/* -------  --------  ------- ----------------------------------------------- */
/* 1.0     05/12/2010 NGuada     Initial revision                             */
/* 2.0     07/23/2012 SKarumuri  Eliminate database account                   */
/******************************************************************************/

--DEFAULTS NO NEED TO CHANGE--
v_default_encoded_password VARCHAR2(30):='[ScBhozpV1nkzzNPrE/';
v_admin_user_objid NUMBER := 268435556;  --objid user attempting the creation of the account 'sa'
v_site_objid NUMBER;
v_group VARCHAR2(30) := 'Call Center';
found_rec NUMBER;
activity VARCHAR2(30);

v_employee_objid NUMBER;
v_user_objid NUMBER;
v_wipbin_objid NUMBER;
v_time_bomb_objid NUMBER;
v_sec_grp_objid NUMBER;

CURSOR c1 IS
SELECT * FROM table_privclass
WHERE  s_class_name = UPPER(ip_priviledge_class );

r1 c1%rowtype;

CURSOR c2 IS
SELECT * FROM table_x_sec_grp
WHERE x_grp_name = ip_sec_grp_name;

r2 c2%rowtype;
sql_stmt VARCHAR2(300);

BEGIN

SELECT COUNT(*)
INTO found_rec
FROM table_user
WHERE s_login_name = UPPER(ip_login_name);

IF found_rec>0 THEN
   op_message:='User already exists';
   RETURN;
END IF;

OPEN c1;
FETCH c1 INTO r1;
IF c1%notfound THEN
   CLOSE c1;
   op_message := 'Invalid Privilege Class';
   RETURN;
ELSE
   CLOSE c1;
END IF;

OPEN c2;
FETCH c2 INTO r2;
IF c2%notfound THEN
   CLOSE c2;
   op_message := 'Invalid Security Group';
   RETURN;
ELSE
   v_sec_grp_objid:=r2.objid;
   CLOSE c2;
END IF;

-- CR 21542
/*
Select count(*)
Into Found_Rec
From Table_Privclass,Table_User
Where User_Access2privclass = Table_Privclass.Objid
And S_Login_Name In (Select User From Dual)
And Class_Name = 'System Administrator';

If Found_Rec=0 Then
   Op_Message:='Not a System Administrator, cannot create users';
   Return;
End If;
*/
activity := 'Getting site';
IF ip_site_id IS NULL THEN
 v_site_objid := 268435456;
ELSE
   BEGIN  -- Added this block for Simple Mobile
     SELECT objid
     INTO v_site_objid
     FROM table_site
     WHERE TYPE = '3'
     AND external_id = ip_site_id
     AND ROWNUM < 2 ;
   EXCEPTION
     WHEN no_data_found THEN
        v_site_objid := 268435456;
     WHEN OTHERS THEN
        RAISE;
   END;
END IF;

--sql_stmt := 'grant connect to '||Ip_Login_Name||' identified by "efg4563456"';
--Execute Immediate Sql_Stmt;
--Sql_Stmt := 'grant clarify_user to '||Ip_Login_Name;
--Execute Immediate Sql_Stmt;

SELECT sa.seq('employee') INTO v_employee_objid FROM dual;
SELECT sa.seq('user') INTO v_user_objid FROM dual;
SELECT sa.seq('wipbin') INTO v_wipbin_objid FROM dual;
SELECT sa.seq('time_bomb') INTO v_time_bomb_objid FROM dual;

--Insert new wipbin
--
activity := 'Inserting wipbin';
INSERT INTO table_wipbin (objid,
                          title,
                          s_title,
                          DESCRIPTION,
                          ranking_rule,
                          icon_id,
                          dialog_id,
                          wipbin_owner2user)
                   VALUES(v_wipbin_objid,
                          'default',
                          'DEFAULT',
                          '',
                          '',
                          0,
                          375,
                          v_user_objid);

--
--insert new user
--
activity := 'Ins User';
INSERT INTO table_user (
                 objid,
                 login_name,
                 s_login_name,
                 PASSWORD,
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
                 dev)
          VALUES(v_user_objid,
                 ip_login_name,
                 UPPER(ip_login_name),
                 v_default_encoded_password,
                 decode(ip_site_id,NULL,NULL,'SMOB'), --smobile
                 1,
                 '',
                 TO_DATE('1/1/1753', 'MM/DD/YYYY'),
                 TO_DATE('1/1/1753', 'MM/DD/YYYY'),
                 TO_DATE('1/1/1753', 'MM/DD/YYYY'),
                 TO_DATE('1/1/1753', 'MM/DD/YYYY'),
                 TO_DATE('1/1/1753', 'MM/DD/YYYY'),
                 TO_DATE('1/1/1753', 'MM/DD/YYYY'),
                 0,
                 0,
                 TO_DATE('1/1/1753', 'MM/DD/YYYY'),
                 TO_DATE('1/1/1753', 'MM/DD/YYYY'),
                 TO_DATE('1/1/1753', 'MM/DD/YYYY'),
                 '',
                 '',
                 '',
                 0,
                 TO_DATE('1/1/1753', 'MM/DD/YYYY'),
                 TO_DATE('1/1/1753', 'MM/DD/YYYY'),
                 TO_DATE('1/1/1753', 'MM/DD/YYYY'),
                 '1',
                 0,
                 '',
                 '',
                 '',
                 v_wipbin_objid,
                 r1.objid,
                 268435758,
                 268436363,
                 1);


--insert new employee
--
activity := 'Ins employee';
       INSERT INTO table_employee
                  (objid,
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
           VALUES (v_employee_objid,
                   ip_first_name,
                   UPPER(ip_first_name),
                   ip_last_name,
                   UPPER(ip_last_name),
                   '',
                   '',
                   '',
                   '',
                   '',
                   ip_email,
                   0.000000,
                   0,
                   0,
                   1,
                   '',
                   ip_employee_id,
                   '',
                   '',
                   '',
                   NULL,
                   NULL,
                   NULL,
                   v_group,
                   TO_DATE('1/1/1753' , 'MM/DD/YYYY'),
                   TO_DATE('1/1/1753' , 'MM/DD/YYYY'),
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
                   v_site_objid,
                   0);
--
-- insert new time_bomb (could be removed)
--

activity := 'Ins TB';
--
/*  --CR51768 suppressing the use of table sa.table_time_bomb.//OImana
INSERT INTO table_time_bomb (objid,
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
              USERS,
              creation_time)
      VALUES( v_time_bomb_objid,
              substr(ip_login_name,1,40),
              TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
              TO_DATE( '1/1/1753', 'MM/DD/YYYY'),
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
*/
--
-- Find Security Group OBJID
--

INSERT INTO mtm_user125_x_sec_grp1
    (user2x_sec_grp, x_sec_grp2user)
    VALUES (v_user_objid,v_sec_grp_objid);

COMMIT;

op_message:='User Created';
EXCEPTION
  WHEN OTHERS THEN
   ROLLBACK;
--   dbms_output.put_line(activity||' '||op_message||' '||sqlerrm);
   op_message := activity||' '||sqlerrm;
   raise_application_error(-20001,activity||sqlerrm);

END create_clarify_user;
/