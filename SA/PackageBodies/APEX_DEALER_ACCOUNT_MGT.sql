CREATE OR REPLACE PACKAGE BODY sa.apex_dealer_account_mgt AS

   PROCEDURE load_file (p_user  IN VARCHAR2, p_group IN VARCHAR2) AS

    TYPE split_tbl_ty  IS  TABLE OF VARCHAR2(500);
    st split_tbl_ty := split_tbl_ty();
    tblob BLOB;
    v_data_array      wwv_flow_global.vc_arr2;
    myrec              VARCHAR2(4000);
-----------------------------------------------------------------------------
PROCEDURE SPLIT( p_list IN OUT VARCHAR2 , p_del VARCHAR2,split_tbl IN OUT split_tbl_ty)
--------------------------------------------------------------------------------
IS
    l_idx    PLS_INTEGER;
    l_list    VARCHAR2(32767):= p_list;
    l_value    VARCHAR2(32767);
BEGIN
    LOOP
        l_idx :=instr(l_list,p_del);
        IF l_idx > 0 THEN
            split_tbl.extend;
            --dbms_output.put_line(substr(l_list,1,l_idx-1));
            split_tbl(split_tbl.COUNT) := substr(l_list,1,l_idx-1);
            l_list:= substr(l_list,l_idx+LENGTH(p_del));
        ELSE
            IF ( p_del = ',') THEN
              split_tbl.extend;
              split_tbl(split_tbl.COUNT) := l_list;
            ELSE
              p_list := l_list;
            END IF;
            EXIT;
        END IF;
    END LOOP;
END ;
----------------------------------------------------------------------------
-- SPLIT  BLOB
----------------------------------------------------------------------------
PROCEDURE SPLIT( p_blob BLOB , p_del VARCHAR2,split_tbl IN OUT split_tbl_ty)
--------------------------------------------------------------------------------
IS
    v_start    PLS_INTEGER := 1;
    v_blob    BLOB := p_blob;
    v_varchar    VARCHAR2(32767);
    n_buffer PLS_INTEGER := 32767;
    v_remaining VARCHAR2(32767);
BEGIN
     dbms_output.put_line('Length of blob '||dbms_lob.getlength(v_blob));
     FOR I IN 1..ceil(dbms_lob.getlength(v_blob) / n_buffer)
     LOOP
        v_varchar := v_remaining||
                     utl_raw.cast_to_varchar2(
                             dbms_lob.substr(v_blob,
                                             n_buffer-nvl(LENGTH(v_remaining),0),
                                             v_start+nvl(LENGTH(v_remaining),0)));
        /*dbms_output.put('rem='||substr(v_varchar,1,30)||'<....>'
                 ||substr(v_varchar,length(v_varchar)-10 )||'|  L='
                 ||v_start||' L1='||length(v_varchar) ); */
        --dbms_output.put_line('TAB COUNT='||split_tbl.count);
        SPLIT(v_varchar,p_del,split_tbl);
        v_remaining := v_varchar;
        --dbms_output.put_line(' <'||v_remaining||'>');
        v_start  := v_start  + n_buffer-nvl(LENGTH(v_remaining),0);
     END LOOP;
END ;

BEGIN
    BEGIN
       SELECT blob_content INTO tblob
       FROM wwv_flow_files A
       WHERE UPPER(updated_by) =UPPER(p_user)
       AND created_on =(SELECT MAX(created_on)
                        FROM wwv_flow_files
                        WHERE UPPER(updated_by)=UPPER(p_user));
     EXCEPTION
         WHEN no_data_found THEN
         dbms_output.put_line(CHR(10)||CHR(10)||'    "'|| '" :File not found. Exiting ..'||CHR(10));
         RETURN;
     END;

SPLIT(tblob,CHR(10),st);
FOR I IN 1..st.COUNT
   LOOP
         myrec := REPLACE(st(I), CHR(10) ,'');
--        myrec := REPLACE (st, ',', ':');
     myrec := REPLACE(myrec, CHR(13) ,'');
    v_data_array := wwv_flow_utilities.string_to_table(myrec||',',',');
    -- v_data_array := wwv_flow_utilities.string_to_table(myrec);
      BEGIN
         IF p_group ='AGENT SUPPORT' THEN
           EXECUTE IMMEDIATE 'insert into SA.X_DEALER_ACCOUNTS_STG(MASTER_AGENT_ID, MASTER_AGENT_NAME, FIRSTNAME, LASTNAME, EMAIL, ROLE, TYPE, BUSINESS_NAME,
           PHONE, ADDRESS, CITY, STATE, ZIP, INSERTED_BY, INSERTED_ON, SD_TICKET, CREATE_ACCOUNT)
           values (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17)'
            USING   v_data_array(1),
                    v_data_array(2),
                    v_data_array(3),
                    v_data_array(4),
                    v_data_array(5),
                    v_data_array(6),
                    v_data_array(7),
                    v_data_array(8),
                    v_data_array(9),
                    v_data_array(10),
                    v_data_array(11),
                    v_data_array(12),
                    v_data_array(13),
                    p_user,
                    sysdate,
                    'P1_SD',--P1_SD,
                    'N';

            COMMIT;
           ELSE
                  EXECUTE IMMEDIATE 'insert into SA.X_DEALER_ACCOUNTS_STG(MASTER_AGENT_ID, MASTER_AGENT_NAME, FIRSTNAME, LASTNAME, EMAIL, ROLE, TYPE, BUSINESS_NAME,
           PHONE, ADDRESS, CITY, STATE, ZIP, INSERTED_BY, INSERTED_ON, APPROVAL_FLAG)
           values (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16)'
            USING   v_data_array(1),
                    v_data_array(2),
                    v_data_array(3),
                    v_data_array(4),
                    v_data_array(5),
                    v_data_array(6),
                    v_data_array(7),
                    v_data_array(8),
                    v_data_array(9),
                    v_data_array(10),
                    v_data_array(11),
                    v_data_array(12),
                    v_data_array(13),
                    p_user,
                    sysdate,
                    'N';

            COMMIT;
         END IF;
      EXCEPTION
      WHEN no_data_found THEN
      NULL;
      WHEN OTHERS THEN
         NULL;
      END;

   --       commit;

END LOOP;
  EXECUTE IMMEDIATE ' DELETE FROM WWV_FLOW_FILES WHERE UPPER(UPDATED_BY) = :1 AND UPDATED_ON >= TRUNC(SYSDATE) ' USING UPPER(p_user);
  COMMIT;
END;


PROCEDURE  create_smob_users (
  ip_firstname        IN VARCHAR2,
  ip_lastname         IN VARCHAR2,
  ip_address_1          IN VARCHAR2,
  ip_address_2       IN VARCHAR2,
  ip_city                IN VARCHAR2,
  ip_state              IN VARCHAR2,
  ip_zip                   IN VARCHAR2,
  ip_phone              IN VARCHAR2,
  ip_email               IN  VARCHAR2,
  ip_dob                  IN DATE,
  ip_title                IN VARCHAR2,
  ip_role                 IN VARCHAR2,
  ip_prov_status    IN  VARCHAR2,
  ip_deal_phone      IN  VARCHAR2,
  ip_term_accept    IN  DATE,
  ip_ma                    IN VARCHAR2,
  ip_user                 IN VARCHAR2,
  op_message        OUT VARCHAR2) AS


--DEFAULTS NO NEED TO CHANGE--
    ip_default_encoded_password VARCHAR2(30):='[ScBhozpV1nkzzNPrE/';
    ip_site_objid NUMBER:=268435456;   --Default SITE OBJID
    ip_group      VARCHAR2(30):='Call Center';
    found_rec     NUMBER;

    v_employee_objid  NUMBER;
    v_user_objid      NUMBER;
    v_wipbin_objid    NUMBER;
    v_time_bomb_objid NUMBER;
    v_sec_grp_objid   NUMBER;
    v_contact_objid   NUMBER;
    v_sm_number       VARCHAR2(25);
    v_employee_id     VARCHAR2(20);
    v_spiff     VARCHAR2(50);
    v_sm_code  VARCHAR2(100);
    v_sup_objid       NUMBER;
    create_fn         VARCHAR2(100);
    create_ln         VARCHAR2(100);
    ip_login_name     VARCHAR2(100);
    ip_first_name       VARCHAR2(100);
    ip_last_name        VARCHAR2(100);
    v_len                   NUMBER;
    v_check                 NUMBER;
    v_comm                  x_dealer_commissions%rowtype;
    sql_stmt          VARCHAR2(300);

  BEGIN

  /*  CREATE_FN := REPLACE (TRIM(IP_FIRSTNAME), ' ', '');
    CREATE_LN := REPLACE (TRIM(IP_LASTNAME), ' ', '');
    V_LEN := LENGTH (CREATE_FN||CREATE_LN);
    FOR I IN 1 .. V_LEN
    LOOP
      SELECT   COUNT (*) INTO V_CHECK
      FROM     TABLE_USER
      WHERE    LOWER(LOGIN_NAME) =  LOWER (SUBSTR(CREATE_FN, 1, I))|| LOWER (CREATE_LN);
      V_LEN := I;
      EXIT WHEN V_CHECK = 0;
    END LOOP;
    IP_LOGIN_NAME := LOWER (SUBSTR (CREATE_FN, 1, V_LEN))|| LOWER (CREATE_LN);
    IP_LOGIN_NAME := REPLACE (IP_LOGIN_NAME, ' ', '');
    IP_LOGIN_NAME := REPLACE (IP_LOGIN_NAME, '.', '');
    IP_LOGIN_NAME := REGEXP_REPLACE (IP_LOGIN_NAME,'[^[a-z,A-Z,0-9,[:space:]]]*','n');
    IP_FIRST_NAME := REGEXP_REPLACE (IP_FIRSTNAME,'[^[a-z,A-Z,0-9,[:space:]]]*', 'n');
    IP_LAST_NAME :=  REGEXP_REPLACE (IP_LASTNAME, '[^[a-z,A-Z,0-9,[:space:]]]*', 'n');
*/
    ip_login_name := ip_email;
    SELECT  TRUNC (dbms_random.VALUE (0, 9999999999999)) INTO v_sm_number
    FROM    dual
    WHERE   1=1
    AND     NOT EXISTS (SELECT 1 FROM x_dealer_commissions WHERE signup_confirm_code = v_sm_number);


    SELECT  TRUNC (dbms_random.VALUE(0,99999)) INTO v_employee_id
    FROM    dual
    WHERE   NOT EXISTS (SELECT 1 FROM table_employee WHERE employee_no=v_employee_id);

    SELECT  COUNT(*) INTO found_rec
    FROM    table_user
    WHERE   s_login_name = UPPER(ip_login_name);
    IF found_rec>0 THEN
      op_message:='User already exists';
      RETURN;
    END IF;

    SELECT  sa.seq('employee') INTO v_employee_objid
    FROM    dual;
    SELECT  sa.seq('user') INTO v_user_objid
    FROM    dual;
    SELECT  sa.seq('wipbin') INTO v_wipbin_objid
    FROM    dual;
    SELECT  sa.seq('time_bomb') INTO v_time_bomb_objid
    FROM    dual;
    SELECT  sa.seq('CONTACT') INTO v_contact_objid
    FROM    dual;



    IF ip_role =  'REP' THEN
            SELECT  * INTO v_comm
            FROM    x_dealer_commissions--@clfyrtrp
            WHERE   signup_id = ip_ma;

          --  V_EMPLOYEE_ID := V_COMM.SMART_USER_ID;
            v_sm_code := v_comm.signup_confirm_code;
            v_spiff:=v_comm.signup_id;
            v_sup_objid:=v_comm.dealer_comms2employee;
     ELSE
             BEGIN
            SELECT A.* INTO v_comm
            FROM x_dealer_commissions A, table_employee b, table_user C--, SMOB_USER_VS D
            WHERE 1=1
            AND A.dealer_comms2employee = b.objid
            AND b.employee2user = C.objid
            AND A.ROLE LIKE 'MAS%'
            AND  UPPER(A.title)=  UPPER(ip_ma);
            v_sup_objid:=v_comm.dealer_comms2employee;
           EXCEPTION
               WHEN no_data_found THEN
                   SELECT     objid INTO v_sup_objid
                   FROM        table_employee
                   WHERE        employee2user IN ( SELECT    objid
                                                                           FROM     table_user
                                                                           WHERE agent_id='SMOB'
                                                                           AND     s_login_name='SA@MTSINT.COM');
                END;
            v_spiff:=ip_email;
            v_sm_code:='SM'||v_sm_number;
      END IF;
     /*   SELECT  A.OBJID INTO V_SUP_OBJID
        FROM    TABLE_EMPLOYEE A
        WHERE   1=1
        AND     S_FIRST_NAME = UPPER(IP_SUP_FIRSTNAME)
        AND     S_LAST_NAME  = UPPER(IP_SUP_LASTNAME)
        AND     EXISTS (SELECT 1 FROM TABLE_USER WHERE 1=1 AND OBJID= A.EMPLOYEE2USER AND AGENT_ID='SMOB');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_SUP_OBJID:=NULL;
    END; */

--Insert new wipbin
--
    INSERT INTO table_wipbin  ( objid, title, s_title, DESCRIPTION, ranking_rule, icon_id, dialog_id, wipbin_owner2user)
    VALUES                    ( v_wipbin_objid, 'default', 'DEFAULT', '', '', 0, 375, v_user_objid);
    COMMIT;
--
    INSERT INTO table_user (  objid, login_name, s_login_name, PASSWORD, agent_id, status, equip_id,
                              cs_lic,csde_lic,cq_lic,passwd_chg,last_login,clfo_lic,cs_lic_type,cq_lic_type,
                              csfts_lic,csftsde_lic,cqfts_lic,web_login,s_web_login,web_password,submitter_ind,
                              sfa_lic,ccn_lic,univ_lic,node_id,locale,wireless_email,alt_login_name,
                              s_alt_login_name,user_default2wipbin,user_access2privclass,offline2privclass,
                              user2rc_config,dev, web_last_login, web_passwd_chg,x_start_date)
    VALUES                  ( v_user_objid,ip_login_name,UPPER(ip_login_name), ip_default_encoded_password,'SMOB',1,'',
                              TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                              TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                              TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'), sysdate, sysdate,
                              TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'), 0,0,
                              TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                              TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                              TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                              '','','Y2fEjdGT1W6nsLqtJbGUVeUp9e4=',0,
                              TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                              TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                              TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),'1',
                              0,'','','', v_wipbin_objid, 536874944, 268435758,268436363,1,
                              sysdate, sysdate,sysdate);
    COMMIT;

    INSERT INTO table_employee (  objid, first_name, s_first_name, last_name, s_last_name, mail_stop, phone, alt_phone,
                                  fax,beeper,e_mail,labor_rate,field_eng,acting_supvr,available,avail_note,
                                  employee_no, normal_biz_high, normal_biz_mid, normal_biz_low, after_biz_high, after_biz_mid,
                                  after_biz_low, work_group, wg_strt_date, site_strt_date, voice_mail_box, local_login,
                                  local_password, allow_proxy, printer, on_call_hw, on_call_sw, case_threshold,
                                  title, salutation, x_q_maint, x_error_code_maint, x_select_trans_prof, x_update_set,
                                  x_order_types, x_dashboard, x_allow_script, x_allow_roadside, employee2user, supp_person_off2site,
                                  emp_supvr2employee, employee2contact)
    VALUES                      ( v_employee_objid, ip_firstname, UPPER(ip_firstname), ip_lastname, UPPER(ip_lastname),
                                  '','','','','', ip_email,0.000000, 0, 0, 1, '', v_employee_id,'','','', substr(ip_email,1,32),
                                  substr(ip_email,1,32), substr(ip_email,1,32), ip_group, TO_DATE( '1/1/1753 00:00:00' , 'MM/DD/YYYY HH24:MI:SS'),
                                  TO_DATE( '1/1/1753 00:00:00' , 'MM/DD/YYYY HH24:MI:SS'), '', '', '', 0, '', 0, 0, 0,'',
                                  '', 0, 0, 0, 0, 0, 0, 0, 0, v_user_objid, ip_site_objid, v_sup_objid ,v_contact_objid);
    COMMIT;

-- insert new time_bomb (could be removed)

    INSERT INTO table_contact ( objid, first_name, s_first_name, last_name, s_last_name, phone, e_mail, address_1, address_2,
                                city, STATE, zipcode, status, dev,  x_cust_id, x_dateofbirth, x_no_address_flag, x_no_name_flag,
                                x_no_phone_flag,update_stamp,  x_email_status, x_html_ok,  x_autopay_update_flag,
                                x_serv_dt_remind_flag, x_sign_reqd, x_spl_offer_flg, x_spl_prog_flg)
    VALUES                    ( v_contact_objid,  ip_firstname, UPPER(ip_firstname), ip_lastname, UPPER(ip_lastname),
                                ip_phone,  ip_email, ip_address_1, ip_address_2, ip_city, ip_state, ip_zip,
                                0, 1, 'SMB'||custid.NEXTVAL, ip_dob, 0, 0, 0, sysdate, 0, 0, 0, 1, 1, 0, 0);
    COMMIT;

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
                                 users,
                                 creation_time)
                         VALUES (v_time_bomb_objid,
                                 ip_login_name,
                                 TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                                 TO_DATE( '1/1/1753 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
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

    COMMIT;
*/

   /*
            V_EMPLOYEE_ID := V_COMM.PROVIDER_ID;
            V_SM_CODE := V_COMM.SIGNUP_CONFIRM_CODE;
            V_SPIFF:=V_COMM.SIGNUP_ID; */

    INSERT INTO x_dealer_commissions
    VALUES (  seq_dealer_commissions.NEXTVAL, v_employee_objid, ip_role, ip_title,v_spiff,
              v_sm_code, ip_term_accept, NULL, NULL, NULL, ip_deal_phone, sysdate,sysdate, 0 );
    COMMIT;

    INSERT INTO mtm_user125_x_sec_grp1  ( user2x_sec_grp, x_sec_grp2user)
    VALUES                              ( v_user_objid,536873397);
    COMMIT;

    INSERT INTO sa.x_user_acct_mgt_stg (login_name, first_name, last_name, pin, status, insert_date,updated_by,  ROLE, new_acct)
    VALUES (ip_email, ip_firstname, ip_lastname, v_employee_id, 'DEALER/REP ACCOUNT CREATED',sysdate,'SA',ip_role, 'Y');
    COMMIT;

  END;

   PROCEDURE reset_pwd(p_user IN VARCHAR2, p_login IN VARCHAR2, p_sd IN VARCHAR2, p_pin IN VARCHAR2, p_msg OUT VARCHAR2) AS
       v_user            sa.table_user%rowtype;
    v_emp             sa.table_employee%rowtype;
    v_temp2           VARCHAR2(10);
    v_temp1           NUMBER;
    v_acct            VARCHAR2(30);
    v_passwd        VARCHAR2(10);
        --P_MSG VARCHAR2(250);
    pen1 VARCHAR2(100);
    pen  VARCHAR2(100);
    inactive_user     EXCEPTION;

  BEGIN

   BEGIN
    SELECT  *
    INTO    v_user
    FROM    sa.table_user
    WHERE   s_login_name=UPPER(p_login);
   EXCEPTION
     WHEN no_data_found THEN
       p_msg:='Username is Invalid.';
       RETURN;
   END;

   BEGIN
    SELECT  *
    INTO    v_emp
    FROM    sa.table_employee
    WHERE   employee2user=v_user.objid;
   -- AND     EMPLOYEE_NO=NVL(P_PIN,'NA');
    IF (v_emp.employee_no IS NOT NULL AND v_emp.employee_no<>p_pin) THEN
        p_msg:='Incorrect Pin';
        RETURN;
    END IF;
   EXCEPTION
     WHEN no_data_found THEN
      p_msg:='Employee Not Found. ';
       RETURN;
   END;

          SELECT    dbms_random.STRING('U',1)||
                    CASE
                      WHEN dbms_random.VALUE(0, 1) <0.25 THEN '!'
                      WHEN dbms_random.VALUE(0, 1)  BETWEEN 0.25 AND 0.5 THEN '*'
                    ELSE '@'
                    END ||
                    dbms_random.STRING('L',1)||
                    ABS(round(dbms_random.VALUE(11,99)))||
                    dbms_random.STRING('L',1)||
                    ABS(round(dbms_random.VALUE(11,99))) INTO v_passwd
          FROM      dual;
          pen:=pencrypt(v_passwd);
          UPDATE  sa.table_user
          SET     web_password = pen,
                  web_passwd_chg= '01-JAN-1753',
                  web_last_login = sysdate,
                  dev=1,
                  status=1,
                  submitter_ind = 0
                  --USER2RC_CONFIG = 268436363
          WHERE   s_login_name = UPPER(p_login);
          COMMIT;
          p_msg:='New Password : '|| v_passwd;
          INSERT INTO sa.x_user_acct_mgt_stg(
                      first_name,
                      last_name,
                      pin,
                      status,
                      insert_date,
                      update_date,
                      updated_by,
                      reset_acct,
                      sd_type,
                      sd_number)
              VALUES (v_emp.s_first_name,
                      v_emp.s_last_name,
                      v_emp.employee_no,
                      'PASSWORD IS RESET',
                      sysdate,
                      sysdate,
                      p_user,
                      'Y',
                      'TICKET',
                      p_sd);
          COMMIT;

  END;
      ------------------------

     PROCEDURE create_smob_user (p_user IN VARCHAR2) IS
      CURSOR c_acct IS
          SELECT    *
          FROM        x_dealer_accounts_stg
          WHERE        inserted_on>=TRUNC(sysdate)
          AND            create_account='N';

        v_msg     VARCHAR2(500);
      BEGIN
          FOR rec IN c_acct
          LOOP
              /*   PROCEDURE Create_smob_UserS ( Ip_FirstName Varchar2, Ip_LastName Varchar2, ip_address_1 varchar2,
                                IP_ADDRESS_2 VARCHAR2, IP_CITY VARCHAR2, IP_STATE VARCHAR2, IP_ZIP VARCHAR2,
                                IP_PHONE varchar2, IP_EMAIL varchar2, IP_DOB date, IP_TITLE varchar2,
                                IP_ROLE varchar2, IP_PROV_STATUS varchar2, IP_DEAL_PHONE varchar2, IP_TERM_ACCEPT date,
                                IP_MA VARCHAR2, IP_USER VARCHAR2, OP_MESSAGE VARCHAR2);*/

            create_smob_users(rec.firstname, rec.lastname, rec.address, '', rec.city, rec.STATE, rec.zip,
                                            rec.phone, rec.email, '',rec.business_name, rec.ROLE,'' , rec.phone ,sysdate , rec.master_agent_name, p_user,v_msg);

          END LOOP;
      END;

  PROCEDURE create_smob_user_fraud (p_user IN VARCHAR2) IS
      CURSOR c_acct IS
          SELECT    *
          FROM        x_dealer_accounts_stg
          WHERE        inserted_on>=TRUNC(sysdate)
          AND            UPPER(approval_flag)='Y';

        v_msg     VARCHAR2(500);
      BEGIN
          FOR rec IN c_acct
          LOOP

              create_smob_users(rec.firstname, rec.lastname, rec.address, '', rec.city, rec.STATE, rec.zip,
                                            rec.phone, rec.email, '',rec.business_name, rec.ROLE,'' , rec.phone ,sysdate , rec.master_agent_name, p_user,v_msg);

          END LOOP;
      END;

END apex_dealer_account_mgt;
/