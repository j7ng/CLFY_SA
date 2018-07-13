CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_ESN_ACCOUNT" IS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_ESN_ACCOUNT_PKB.sql,v $
--$Revision: 1.67 $
--$Author: pkapaganty $
--$Date: 2018/06/01 19:34:57 $
--$ $Log: ADFCRM_ESN_ACCOUNT_PKB.sql,v $
--$ Revision 1.67  2018/06/01 19:34:57  pkapaganty
--$ CR55465 TW WEB TAS  Allow to remove an Active device from account
--$ Added channel to branding api.
--$
--$ Revision 1.66  2018/01/12 22:33:35  mbyrapaneni
--$ SMMLD_TAS_01: To block adding SM into GS account
--$
--$ Revision 1.65  2018/01/11 16:04:23  mbyrapaneni
--$ SMMLD_TAS_01: Defect fix 34931
--$
--$ Revision 1.64  2017/10/12 20:30:34  epaiva
--$ CR51354 - defect 31649 store sourcesystem on update
--$
--$ Revision 1.63  2017/09/28 21:58:48  epaiva
--$ CR51354 - updated to pick addi_info2user in the cursor
--$
--$ Revision 1.62  2017/09/25 19:46:33  epaiva
--$ CR51354 - Log history opt in out for communications
--$
--$ Revision 1.61  2017/07/10 16:42:08  syenduri
--$ Added get_esn_by_contact function - CR51441 -- Track Name and Address history (Function has been written by Mary)
--$
--$ Revision 1.60  2017/06/01 17:34:06  nguada
--$ Bug Fix 26686
--$
--$ Revision 1.59  2017/03/17 23:10:10  mmunoz
--$ CR46822 : Change in update_dummy_account,  Do not send ERROR if web_user_login_name is not dummy.
--$
--$ Revision 1.58  2017/03/17 15:53:19  mmunoz
--$ CR46822 : Checking if the account is dummy in update_dummy_account
--$
--$ Revision 1.57  2017/03/15 16:58:34  mmunoz
--$ CR46822 : fixes for  New procedure update_dummy_account
--$
--$ Revision 1.56  2017/03/15 16:51:59  mmunoz
--$ CR46822 : New procedure update_dummy_account
--$
--$ Revision 1.55  2016/10/19 16:14:42  mmunoz
--$ CR44361 New procedure link_esn_to_account
--$
--$ Revision 1.54  2016/09/26 17:55:34  mmunoz
--$ CR43005: Updated procedure add_esn_to_account_pymt  created v_next_charge_date
--$
--$ Revision 1.53  2016/09/21 15:58:50  mmunoz
--$ CR43005: Updated procedure add_esn_to_account_pymt to set x_next_charge_date for HPP programs
--$
--$ Revision 1.52  2016/09/14 20:45:18  mmunoz
--$ CR43005 : Procedure  REMOVE_ESN_FROM_ACCOUNT updated
--$
--$ Revision 1.51  2016/06/28 15:23:58  nguada
--$ removed CR43217
--$
--$ Revision 1.48  2016/05/11 23:16:26  mmunoz
--$ CR40766 TAS MY ACCOUNT Do not reuse account contact for ESN's contact, updated copy_contact_info
--$
--$ Revision 1.47  2016/05/11 16:44:02  mmunoz
--$ CR40766 TAS MY ACCOUNT Do not reuse account contact for ESN's contact
--$
--$ Revision 1.46  2016/04/08 19:06:10  syenduri
--$ CR41244 - Check-in behalf of Kalyan
--$
--$ Revision 1.45  2016/01/29 23:15:20  syenduri
--$ TAS_2016_04 - CR38603 - Implement option for 4 or 5 digits Security PIN
--$
--$ Revision 1.44  2015/10/01 20:22:38  syenduri
--$ TAS_2015_21 - CR 38378 - Account Creation Fixes. Modified get_enroll_info cursor to verify Part Inst Status
--$
--$ Revision 1.43  2015/07/07 17:52:18  hcampano
--$ TAS_2015_14 - Country now returns USA if nothing is passed in the Contact Function.
--$
--$ Revision 1.42  2015/01/29 17:32:19  mmunoz
--$ Merge with production release 01292015
--$
--$ Revision 1.41  2015/01/22 19:17:36  nguada
--$ TAS_2015_03
--$
--$ Revision 1.39  2014/09/30 19:47:22  hcampano
--$ FIX ISSUE WHEN ENTERING CONTACT DETAILS FLOW
--$ PROBLEM: CHECKBOXES AND UPDATE PROCEDURES BREAK BECAUSE OF MISSING
--$ BUS ORG IN THE ADD INFO TABLE
--$
--$ Revision 1.38  2014/09/30 15:01:43  mmunoz
--$ Updated variable sizes to 4000 in ADD_MISSING_CONTACT
--$
--$ Revision 1.37  2014/09/18 21:26:33  mmunoz
--$ Excluded WARRANTY programs when checking if ESN is enrolled in autorefill program
--$
--$ Revision 1.36  2014/09/18 20:36:00  mmunoz
--$ Adding changes for HPP phase II
--$
--$ Revision 1.35  2014/08/27 14:51:00  hcampano
--$ Simplified query in update_contact_consent
--$
--------------------------------------------------------------------------------------------

  cursor get_webuser_info (ip_web_user_objid in table_web_user.objid%type) is
    select web.*, bo.org_id
    from   table_web_user web,
           table_bus_org  bo
    where  web.objid = ip_web_user_objid
    and    bo.objid = web.WEB_USER2BUS_ORG;

  Get_Webuser_Info_Rec  Get_Webuser_Info%Rowtype;

  cursor get_contact (ip_contact_objid in table_contact.objid%type) is
        SELECT c.*
          FROM table_contact c
         WHERE c.objid = ip_contact_objid;
  get_contact_rec   get_contact%rowtype;

  cursor get_esn_info (ip_ESN in table_part_inst.part_serial_no%type) is
        SELECT
             PI.OBJID,
             PI.X_PART_INST2CONTACT,
             web.objid web_user_objid,
             WEB.WEB_USER2BUS_ORG,
             pn.part_num2bus_org,
             conpi.x_is_default,
             conpi.x_esn_nick_name,
             bo.org_id,
             pi.x_part_inst_status,
             pi.part_serial_no,
             pn.x_technology,
             pn.part_number,
             pc.name class_name,
             sa.get_param_by_name_fun(pc.NAME,'DEVICE_TYPE') device_type,
             c.first_name,
             c.last_name
        FROM table_part_inst pi,
             table_x_contact_part_inst conpi,
             table_web_user web,
             table_mod_level ml,
             table_part_num pn,
             table_bus_org bo,
             table_part_class pc,
             table_contact c
        WHERE pi.part_serial_no = ip_esn
        and   pi.x_domain = 'PHONES'
        and   conpi.x_contact_part_inst2part_inst (+) = pi.objid
        and   web.web_user2contact (+) = conpi.x_contact_part_inst2contact
        and   ml.objid = pi.n_part_inst2part_mod
        and   pn.objid = ml.part_info2part_num
        and   bo.objid = pn.part_num2bus_org
        and   pc.objid = pn.part_num2part_class
        and   c.objid (+) = pi.x_part_inst2contact;

  get_esn_info_rec  get_esn_info%rowtype;

  cursor get_enroll_info (ip_ESN in table_part_inst.part_serial_no%type) is
	SELECT PE.*, pp.x_prog_class
    FROM  sa.X_PROGRAM_ENROLLED   PE,
          sa.X_PROGRAM_PARAMETERS PP,
          sa.TABLE_PART_INST PI
    WHERE PE.X_ESN = ip_ESN
    AND   PE.X_ENROLLMENT_STATUS NOT IN ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
    AND   pp.objid = pe.pgm_enroll2pgm_parameter
    and   pp.x_prog_class <> 'WARRANTY'
    AND   PI.PART_SERIAL_NO = PE.X_ESN
    AND   PI.X_DOMAIN = 'PHONES'
    AND   PI.X_PART_INST_STATUS = '52'
    ;

  get_enroll_info_rec  get_enroll_info%rowtype;

procedure copy_contact_info (
    op_old_contact_id  in  table_contact.objid%type,
    op_new_contact_id out table_contact.objid%type,
    op_err_code       out varchar2,
    op_err_msg        out varchar2) is

  cursor get_current_acctinfo (op_old_contact_id in table_contact.objid%type) is
        SELECT
             c.objid contact_objid,
             decode(c.first_name,c.x_cust_id,null,c.first_name) first_name,
             decode(c.last_name,c.x_cust_id,null,c.last_name) last_name,
             c.x_middle_initial,
             c.fax_number,
             decode(c.phone,c.x_cust_id,null,c.phone) phone,
             c.e_mail,
             decode(a.address,c.x_cust_id,null,a.address) address,
             decode(a.address_2,c.x_cust_id,null,a.address_2) address_2,
             a.city,
             a.state,
             a.zipcode,
             cai.x_dateofbirth,
             bo.org_id,
             nvl(c.dev,0) copy_counter,
             cai.add_info2user  --CR51354 - log username for communication preferences
    from   table_contact c,
           table_x_contact_add_info cai,
           table_contact_role cr,
           table_address a,
           table_site s,
           table_bus_org bo
    where  1=1
    and    c.objid = op_old_contact_id
    and    c.objid        = cr.contact_role2contact
    And    S.Objid        = Cr.Contact_Role2site
    and    cr.primary_site = 1
    and    a.objid        = s.cust_primaddr2address
    and    c.objid        = cai.add_info2contact (+)
    and    cai.add_info2bus_org = bo.objid (+);

  get_current_acctinfo_rec  get_current_acctinfo%rowtype;
  esn_count number;
begin
   op_err_code := 0;
   op_err_msg := 'Contact duplicated, Successfully';
   /*---------------------------------------------------------------------*/
   /*   get Contact info for the given ESN                                */
   /*---------------------------------------------------------------------*/
   open get_current_acctinfo(op_old_contact_id);
   fetch get_current_acctinfo into get_current_acctinfo_rec;
   if get_current_acctinfo%notfound
   then
      op_err_code := '-201';
      op_err_msg := 'ERROR-00201 ADFCRM_ESN_ACCOUNT.COPY_CONTACT_INFO : Contact not found';
      close get_current_acctinfo;
      return;  --Procedure stops here
   end if;
   close get_current_acctinfo;

--insert into testlogs values (op_old_contact_id||'-inside copy contact info-'||op_new_contact_id);

   --CR40766 if get_current_acctinfo_rec.copy_counter>0 then
     contact_pkg.createcontact_prc(p_esn => null,
                                    p_first_name => get_current_acctinfo_rec.first_name ||' copy_'||to_char(get_current_acctinfo_rec.copy_counter+1),
                                    p_last_name => get_current_acctinfo_rec.last_name,
                                    p_middle_name => get_current_acctinfo_rec.x_middle_initial,
                                    p_phone => get_current_acctinfo_rec.phone,
                                    p_add1 => get_current_acctinfo_rec.address,
                                    p_add2 => get_current_acctinfo_rec.address_2,
                                    p_fax => get_current_acctinfo_rec.fax_number,
                                    p_city => get_current_acctinfo_rec.city,
                                    p_st => get_current_acctinfo_rec.state,
                                    p_zip => get_current_acctinfo_rec.zipcode,
                                    p_email => get_current_acctinfo_rec.e_mail,
                                    p_email_status => 0,
                                    p_roadside_status => 0,
                                    p_no_name_flag => null,
                                    p_no_phone_flag => null,
                                    p_no_address_flag => null,
                                    p_sourcesystem => 'TAS',
                                    p_brand_name => get_current_acctinfo_rec.org_id,
                                    p_do_not_email => 1,
                                    p_do_not_phone => 1,
                                    p_do_not_mail => 1,
                                    p_do_not_sms => 1,
                                    p_ssn => null,
                                    p_dob => get_current_acctinfo_rec.x_dateofbirth,
                                    p_do_not_mobile_ads => 1,
                                    p_contact_objid => op_new_contact_id,
                                    p_err_code => op_err_code,
                                    p_err_msg => op_err_msg,
                                    p_add_info2web_user => get_current_acctinfo_rec.add_info2user  --Cr51354 log username changes for communication preferences.

                                    );

  --    insert into testlogs values ('copy Contact'||op_new_contact_id);
   --CR40766 else
     -- Reuse Account Contact if it is the first ESN in the account
   --CR40766 i  op_new_contact_id:=get_current_acctinfo_rec.contact_objid;
   --CR40766 iend if;

   update table_contact
   set dev = nvl(get_current_acctinfo_rec.copy_counter,0)+1
   where objid = get_current_acctinfo_rec.contact_objid;

   commit;

    -- DO NOT CALL UPDATE CR27859, AFTER THE CONTACT IS CREATED
    -- UPDATE MIRROR THE ADD INFO TABLE
    for i in (select *
              from table_x_contact_add_info
              where add_info2contact = op_old_contact_id)
    loop
      update table_x_contact_add_info
      set x_do_not_email = i.x_do_not_email,
          x_do_not_phone = i.x_do_not_phone,
          x_do_not_sms = i.x_do_not_sms,
          x_do_not_mail = i.x_do_not_mail

      where add_info2contact = op_new_contact_id;
    end loop;
    commit;

EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     op_err_code := SQLCODE;
     op_err_msg  := TRIM(SUBSTR('ERROR COPY_CONTACT_INFO : '||SQLERRM ||CHR(10) ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1,4000));
     RETURN;
end copy_contact_info;

procedure create_dummy_contact (
    ip_zip_code       in  varchar2,
    ip_brand_name     in  varchar2,
    op_new_contact_id out table_contact.objid%type,
    op_err_code       out varchar2,
    op_err_msg        out varchar2) is

begin

     contact_pkg.createcontact_prc(p_esn => null,
                                    p_first_name => null,
                                    p_last_name => null,
                                    p_middle_name => null,
                                    p_phone => null,
                                    p_add1 => null,
                                    p_add2 => null,
                                    p_fax => null,
                                    p_city => null,
                                    p_st => null,
                                    p_zip => ip_zip_code,
                                    p_email => null,
                                    p_email_status => 0,
                                    p_roadside_status => 0,
                                    p_no_name_flag => null,
                                    p_no_phone_flag => null,
                                    p_no_address_flag => null,
                                    p_sourcesystem => 'TAS',
                                    p_brand_name => ip_brand_name,
                                    p_do_not_email => 1,
                                    p_do_not_phone => 1,
                                    p_do_not_mail => 1,
                                    p_do_not_sms => 1,
                                    p_ssn => null,
                                    p_dob => null,
                                    p_do_not_mobile_ads => 1,
                                    p_contact_objid => op_new_contact_id,
                                    p_err_code => op_err_code,
                                    p_err_msg => op_err_msg);


EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     op_err_code := SQLCODE;
     op_err_msg  := TRIM(SUBSTR('ERROR CREATING_DUMMY_CONTACT : '||SQLERRM ||CHR(10) ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1,4000));
     RETURN;

end;

function is_enrolled_no_account (ip_ESN sa.table_part_inst.part_serial_no%type)
return varchar2 is
   v_check varchar2(30);
   v_cnt   number;
begin
select count(1)
into   v_cnt
from   x_program_enrolled pe,
       x_program_parameters pp
where pe.x_esn = ip_ESN
and  pe.x_enrollment_status||''  = 'ENROLLED_NO_ACCOUNT'
AND  pp.objid = pe.pgm_enroll2pgm_parameter
and  pp.x_prog_class = 'WARRANTY';

if v_cnt > 0
then
   v_check := 'true';
else
   v_check := 'false';
end if;
return v_check;
end is_enrolled_no_account;

procedure add_esn_to_account_pymt (
    ip_web_user_objid  in sa.table_web_user.objid%type,
    ip_esn_nick_name   in sa.table_x_contact_part_inst.x_esn_nick_name%type,
    ip_ESN             in sa.table_part_inst.part_serial_no%type,
    ip_overwrite_esn   in number,  -- 1: Allow movement of an active esn between accounts, 0: Not allow movement of an active esn
    ip_user            in sa.table_user.s_login_name%type,
    ip_pymt_src        in sa.x_payment_source.objid%type,
    op_err_code        out varchar2,
    op_err_msg         out varchar2
) Is
    v_next_charge_date date;
begin

if ip_pymt_src is null and is_enrolled_no_account(ip_ESN) = 'true'
then
      op_err_code := '-1000';
      op_err_msg := 'Please select the payment source for the enrollment';
else

    add_esn_to_account (
        ip_web_user_objid,
        ip_esn_nick_name,
        ip_ESN,
        ip_overwrite_esn,
        ip_user,
        op_err_code,
        op_err_msg
    );

    if op_err_code = 0 and ip_pymt_src is not null
    then
      BEGIN
       /*----------------------------------------------------------------*/
       /* update status for HPP programs                                 */
       /*----------------------------------------------------------------*/
            v_next_charge_date :=  sa.billing_services_pkg.hpp_next_charge_date(ip_ESN);
            UPDATE x_program_enrolled
               SET x_enrollment_status = 'ENROLLED',
                   pgm_enroll2x_pymt_src = ip_pymt_src,
                   x_next_charge_date = v_next_charge_date  --CR43005 HPP My Account Fixes
             WHERE x_esn = ip_ESN
               AND x_enrollment_status||''  = 'ENROLLED_NO_ACCOUNT'
               AND pgm_enroll2pgm_parameter IN (SELECT objid
                                                  FROM x_program_parameters
                                                 WHERE x_prog_class = 'WARRANTY');
            COMMIT;
            op_err_code := 0;
            op_err_msg := 'ESN added to account, Successfully';
        EXCEPTION
          WHEN OTHERS THEN
             ROLLBACK;
             op_err_code := SQLCODE;
             op_err_msg  := TRIM(SUBSTR('ERROR ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : '||SQLERRM ||CHR(10) ||
                                   DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                            ,1,4000));
             RETURN;
      END;
    end if;
end if;
end add_esn_to_account_pymt;

procedure add_esn_to_account (
    ip_web_user_objid  in sa.table_web_user.objid%type,
    ip_esn_nick_name   in sa.table_x_contact_part_inst.x_esn_nick_name%type,
    ip_ESN             in sa.table_part_inst.part_serial_no%type,
    ip_overwrite_esn   in number,  -- 1: Allow movement of an active esn between accounts, 0: Not allow movement of an active esn
    ip_user            in sa.table_user.s_login_name%type,
    op_err_code        out varchar2,
    op_err_msg         out varchar2
) Is

  op_new_contact_id  number;
  cnt_records        number;
  v_sub_bus_org_acct varchar2(100);
  v_sub_bus_org_esn varchar2(100);
begin
   op_err_code := 0;
   op_err_msg := 'ESN added to account, Successfully';
   /*---------------------------------------------------------------------*/
   /*   get ESN  information                                              */
   /*---------------------------------------------------------------------*/
   open get_esn_info(ip_ESN);
   fetch get_esn_info into get_esn_info_rec;
   if get_esn_info%notfound
   then
      op_err_code := '-1';
      op_err_msg := 'ERROR-00001 ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : ESN not found';
      close get_esn_info;
      return;  --Procedure stops here
   end if;
   close get_esn_info;
   /*---------------------------------------------------------------------*/
   /*  Check if ESN is linked to the account                              */
   /*---------------------------------------------------------------------*/
   if nvl(get_esn_info_rec.web_user_objid,-1) = ip_web_user_objid
   then
      op_err_code := '-6';
      op_err_msg := 'ERROR-00006 ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : ESN already linked to the account';
      return;  --Procedure stops here
   end if;
   /*---------------------------------------------------------------------*/
   /*   Check if ESN is enrolled in autorefill program                    */
   /*---------------------------------------------------------------------*/
   open get_enroll_info(ip_ESN);
   fetch get_enroll_info into get_enroll_info_rec;
   if get_enroll_info%found
   then
      cnt_records := 1; --assumption: the esn belongs to an account
      if get_enroll_info_rec.pgm_enroll2web_user is null then
          --check if ESN belongs to any account
	      select count(*)
		  into cnt_records
	      from sa.table_part_inst pi, table_x_contact_part_inst  conpi, table_web_user web
	      where pi.part_serial_no = get_enroll_info_rec.x_esn
	      and   pi.x_domain = 'PHONES'
	      and   conpi.x_contact_part_inst2part_inst = pi.objid
	      and   web.web_user2contact = conpi.x_contact_part_inst2contact;
      end if;
      if cnt_records > 0 then
	      op_err_code := '-2';
	      op_err_msg := 'ERROR-00002 ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : ESN is enrolled in autorefill program';
	      close get_enroll_info;
	      return;  --Procedure stops here
	  end if;
   end if;
   close get_enroll_info;
   /*---------------------------------------------------------------------*/
   /*  Get target account information                                     */
   /*---------------------------------------------------------------------*/
   open get_webuser_info(ip_web_user_objid);
   fetch get_webuser_info into get_webuser_info_rec;
   if get_webuser_info%notfound
   then
      op_err_code := '-3';
      op_err_msg := 'ERROR-00003 ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Web User Account not found';
      close get_webuser_info;
      return;  --Procedure stops here
   end if;
   close get_webuser_info;

   if get_webuser_info_rec.web_user2contact IS NULL
   then
      op_err_code := '-4';
      op_err_msg := 'ERROR-00004 ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Target account contact not found';
      return;  --Procedure stops here
   end if;
   /*----------------------------------------------------------------------------------*/
   /*         If ESN is Home Alert then check valid phone number and email             */
   /*----------------------------------------------------------------------------------*/
   --if nvl(get_esn_info_rec.device_type,-1) = 'M2M'
   --if (sa.device_util_pkg.is_homealert(ip_ESN) = 0)
   if sa.adfcrm_cust_service.esn_type(ip_ESN) in ('HOME ALERT','CAR CONNECT')
   then
       open get_contact(get_webuser_info_rec.web_user2contact);
       fetch get_contact into get_contact_rec;
       if get_contact%notfound
       then
           op_err_code := '-9';
           op_err_msg := 'ERROR-00009 ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Account contact not found';
           close get_contact;
           return;  --Procedure stops here
	   else
           if
           --Email NOT valid
		   NOT (regexp_like(get_contact_rec.e_mail,'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,4}') and
		        length(get_contact_rec.e_mail) > 6 and
		        get_contact_rec.e_mail not like get_contact_rec.x_cust_id||'@'||'%')
		 /* ----------------------------------------------------------------------------------
       Phone Validation Commented - CR41244 - 03/31/2016 - kvara
       ----------------------------------------------------------------------------------
       OR
		   --Phone not valid
		   NOT (regexp_like(get_contact_rec.phone,'[0-9]{10,10}') and
		        length(get_contact_rec.phone) > 9 and
		        get_contact_rec.phone != get_contact_rec.x_cust_id)
      ----------------------------------------------------------------------------------*/
           then
               op_err_code := '-8';
               op_err_msg := 'ERROR-00008 ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Account should have a valid Email';
               close get_contact;
               return;  --Procedure stops here
           end if;
       end if;
       if get_contact%isopen then
           close get_contact;
       end if;
   end if;
   /*---------------------------------------------------------------------*/
   /*   Validate that movement between accounts is allowed for active ESN */
   /*---------------------------------------------------------------------*/
   if (nvl(ip_overwrite_esn,0) = 0 and
       get_esn_info_rec.x_part_inst_status = '52' and
       get_esn_info_rec.web_user_objid is not null)
   then
      op_err_code := '-7';
      op_err_msg := 'ERROR-00007 ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Movement between accounts is not allowed for active ESN';
      return;  --Procedure stops here
   end if;

   /*---------------------------------------------------------------------*/
   /*   Validate that target organization/brand is the same as            */
   /*   current ESN brand                                                 */
   /*---------------------------------------------------------------------*/
   if (get_webuser_info_rec.web_user2bus_org <> get_esn_info_rec.web_user2bus_org and
       get_esn_info_rec.web_user2bus_org is not null) OR
      (get_webuser_info_rec.web_user2bus_org <> get_esn_info_rec.part_num2bus_org and
       get_esn_info_rec.part_num2bus_org is not null)
   THEN
      IF GET_ESN_INFO_REC.ORG_ID = 'GENERIC'
      then
         --call procedure to link brand to esn
          phone_pkg.brand_esn(get_esn_info_rec.part_serial_no,
                              get_webuser_info_rec.org_id,
                              ip_user,
                              op_err_code,
                              op_err_msg,
                              ip_Rebrand_Channel => 'TAS');
          if op_err_code = '0'
          then
             op_err_msg := 'ESN added to account, Successfully';
          else
             OP_ERR_MSG := 'ERROR-PHONE_PKG.BRAND_ESN : '||OP_ERR_MSG;
             RETURN;  --Procedure stops here
          end if;
      ELSE
          OP_ERR_CODE := '-5';
          OP_ERR_MSG := 'ERROR-00005 ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Target organization/brand is not the same as the ESN has.';
          RETURN;  --Procedure stops here
      end if;
   end if;
   /*---------------------------------------------------------------------*/
   /*   Validate that target SUB organization/brand is the same as        */
   /*   current ESN sub brand                                             */
   /*---------------------------------------------------------------------*/
   if get_webuser_info_rec.org_id = 'SIMPLE_MOBILE' then
       sa.phone_pkg.get_sub_brand(i_contact_objid => get_webuser_info_rec.web_user2contact,o_sub_brand => v_sub_bus_org_acct,o_errnum => op_err_code,o_errstr => op_err_msg);
   end if;

   if v_sub_bus_org_acct is not null then
        sa.phone_pkg.get_sub_brand(
          I_ESN => ip_esn,
          o_sub_brand => v_sub_bus_org_esn,
          O_ERRNUM => op_err_code,
          o_errstr => op_err_msg
        );
        if v_sub_bus_org_acct != nvl(v_sub_bus_org_esn,get_esn_info_rec.org_id) then
           op_err_code := '-10';
           op_err_msg := 'ERROR-00010 ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Target organization/brand is not the same as the ESN has.';
           RETURN;  --Procedure stops here
        end if;
   end if;
   /*---------------------------------------------------------------------*/
   /*   Remove Link from existing account/contact                         */
   /*---------------------------------------------------------------------*/
   DELETE table_x_contact_part_inst
   WHERE x_contact_part_inst2part_inst = get_esn_info_rec.objid;

   /*---------------------------------------------------------------------*/
   /*  Check if the esn is the first in the account to set as primary
   /*---------------------------------------------------------------------*/
    select decode(COUNT(*),0,1,0) X_IS_DEFAULT   --setting the primary ESN.
    into   GET_ESN_INFO_REC.X_IS_DEFAULT
    from   TABLE_X_CONTACT_PART_INST
    where  X_CONTACT_PART_INST2CONTACT = GET_WEBUSER_INFO_REC.WEB_USER2CONTACT
    and    X_IS_DEFAULT = 1;

	--CR40766 Do not reuse account contact. NEVER
    -- If esn is primary then link to web_user2contact else copy contact info
    dbms_output.put_line('ESN default is '||GET_ESN_INFO_REC.X_IS_DEFAULT);
    --if GET_ESN_INFO_REC.X_IS_DEFAULT = 1
    --then
        -- Reuse Account Contact if it is the first ESN in the account
    --    op_new_contact_id := get_webuser_info_rec.web_user2contact;
    --    update table_contact
    --    set dev = nvl(dev,0)+1
    --    where objid = get_webuser_info_rec.web_user2contact;
    --else
       /*---------------------------------------------------------------------*/
       /*  Copy contact information from table_web_user.web_user2contact      */
       /*---------------------------------------------------------------------*/
      -- insert into testlogs values ('before copy contact '|| get_webuser_info_rec.web_user2contact);
       copy_contact_info(get_webuser_info_rec.web_user2contact,op_new_contact_id,op_err_code,op_err_msg);
       if op_err_code <> '0' then
          ROLLBACK;
          return;  --Procedure stops here
       end if;
    --end if;--CR40766 Do not reuse account contact. NEVER
    dbms_output.put_line('op_new_contact_id is '||op_new_contact_id);

  --   insert into testlogs values ('op_new_contact_id is '|| op_new_contact_id);

   /*---------------------------------------------------------------------*/
   /*   Link ESN to new contact copied                                    */
   /*---------------------------------------------------------------------*/
    UPDATE table_part_inst
       SET x_part_inst2contact = op_new_contact_id
     WHERE objid = get_esn_info_rec.objid;

   /*---------------------------------------------------------------------*/
   /*   Link ESN to Target account/contact                                */
   /*---------------------------------------------------------------------*/

    INSERT INTO table_x_contact_part_inst
    (objid
    ,x_contact_part_inst2contact
    ,x_contact_part_inst2part_inst
    ,X_ESN_NICK_NAME
    ,X_IS_DEFAULT)
    VALUES
    (seq('x_contact_part_inst')
    ,GET_WEBUSER_INFO_REC.WEB_USER2CONTACT
    ,get_esn_info_rec.objid
    ,IP_ESN_NICK_NAME
    ,get_esn_info_rec.X_IS_DEFAULT
    );

    COMMIT;
    op_err_code := 0;
    op_err_msg := 'ESN added to account, Successfully';
EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     op_err_code := SQLCODE;
     op_err_msg  := TRIM(SUBSTR('ERROR ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : '||SQLERRM ||CHR(10) ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1,4000));
     RETURN;
end ADD_ESN_TO_ACCOUNT;

procedure REMOVE_ESN_FROM_ACCOUNT (
    ip_web_user_objid  in table_web_user.objid%type,
    ip_ESN             in table_part_inst.part_serial_no%type,
    ip_user_login_name in varchar2 DEFAULT 'SA',
    op_err_code        out varchar2,
    op_err_msg         out varchar2
) Is
   op_new_contact_id number;
BEGIN
   op_err_code := 0;
   op_err_msg := 'ESN removed from account, Successfully';
   /*---------------------------------------------------------------------*/
   /*   get ESN  info  ASSUMPTION : ESN is INACTIVE                       */
   /*---------------------------------------------------------------------*/
   open get_esn_info(ip_ESN);
   fetch get_esn_info into get_esn_info_rec;
   if get_esn_info%notfound
   then
      op_err_code := '-101';
      op_err_msg := 'ERROR-00101 ADFCRM_ESN_ACCOUNT.REMOVE_ESN_FROM_ACCOUNT : ESN not found';
      close get_esn_info;
      return;  --Procedure stops here
   end if;
   close get_esn_info;
   /*---------------------------------------------------------------------*/
   /*  Check if ESN is linked to the account                              */
   /*---------------------------------------------------------------------*/
   if get_esn_info_rec.web_user_objid <> ip_web_user_objid
   then
      op_err_code := '-102';
      op_err_msg := 'ERROR-00101 ADFCRM_ESN_ACCOUNT.REMOVE_ESN_FROM_ACCOUNT : ESN is not linked to the account';
      return;  --Procedure stops here
   end if;
    /*--------------------------------------------------------------------------*/
    /*  If contact is linked to ESN (table_part_inst.x_part_inst2contact)       */
    /*  then Copy contact information from table_part_inst.x_part_inst2contact  */
    /*--------------------------------------------------------------------------*/
    if get_esn_info_rec.x_part_inst2contact is not null
    then
        create_dummy_contact ('33122',get_esn_info_rec.org_id,op_new_contact_id,op_err_code,op_err_msg);
        if op_err_code <> '0' then
           ROLLBACK;
           return;  --Procedure stops here
        end if;
        /* Link ESN to new contact (table_part_inst.x_part_inst2contact)  */
        Update Table_Part_Inst
           SET x_part_inst2contact = op_new_contact_id
         WHERE objid = get_esn_info_rec.objid;
    end if;
   /*----------------------------------------------------------------*/
   /* Remove link esn  from table_x_contact_part_inst                */
   /*----------------------------------------------------------------*/
    DELETE table_x_contact_part_inst
     WHERE x_contact_part_inst2part_inst = get_esn_info_rec.objid;

   /*----------------------------------------------------------------*/
   /* Remove link to x_payment_source, and update status for HPP programs*/
   /*----------------------------------------------------------------*/
        UPDATE x_program_enrolled
           SET x_enrollment_status = 'ENROLLED_NO_ACCOUNT',
               pgm_enroll2x_pymt_src = null
         WHERE x_esn = ip_ESN
           AND x_enrollment_status||'' in ('ENROLLED','ENROLLMENTPENDING')
           AND pgm_enroll2pgm_parameter IN (SELECT objid
                                              FROM x_program_parameters
                                             WHERE x_prog_class = 'WARRANTY');
            ---------------- CR43005 Insert a billing Log -----------------------------
           INSERT INTO x_billing_log
            (objid
            ,x_log_category
            ,x_log_title
            ,x_log_date
            ,x_details
            ,x_nickname
            ,x_esn
            ,x_originator
            ,x_contact_first_name
            ,x_contact_last_name
            ,x_agent_name
            ,x_sourcesystem
            ,billing_log2web_user)
          VALUES
            (sa.billing_seq('X_BILLING_LOG')
            ,'ESN'
            ,'REMOVE_ESN'
            ,SYSDATE
            ,'ESN ' || ip_ESN || ' has been successfully removed from your account.'
            ,get_esn_info_rec.x_esn_nick_name
            ,ip_ESN
            ,'System'
            ,get_esn_info_rec.first_name
            ,get_esn_info_rec.last_name
            ,upper(ip_user_login_name)
            ,'TAS'
            ,ip_web_user_objid);
    COMMIT;
    op_err_code := 0;
    op_err_msg := 'ESN removed from account, Successfully';
EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     op_err_code := SQLCODE;
     op_err_msg  := TRIM(SUBSTR('ERROR ADFCRM_ESN_ACCOUNT.REMOVE_ESN_FROM_ACCOUNT : '||SQLERRM ||CHR(10) ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1,4000));
     RETURN;
End Remove_Esn_From_Account;

procedure MAKE_ESN_PRIMARY (
   /*----------------------------------------------------------------*/
   /*  Make esn the primary/default of the account                   */
   /*----------------------------------------------------------------*/
    ip_web_user_objid  in table_web_user.objid%type,
    ip_esn             in table_part_inst.part_serial_no%type,
    op_err_code        out varchar2,
    op_err_msg         out varchar2) is

begin

   open get_webuser_info(ip_web_user_objid);
   fetch get_webuser_info into get_webuser_info_rec;
   if get_webuser_info%notfound
   then
      op_err_code := '-301';
      op_err_msg := 'ERROR-00301 ADFCRM_ESN_ACCOUNT.MAKE_ESN_PRIMARY : Web User Account not found';
      close get_webuser_info;
      return;  --Procedure stops here
   end if;
   close get_webuser_info;

   open get_esn_info(ip_ESN);
   fetch get_esn_info into get_esn_info_rec;
   if get_esn_info%notfound
   then
      op_err_code := '-302';
      op_err_msg := 'ERROR-00302 ADFCRM_ESN_ACCOUNT.MAKE_ESN_PRIMARY : ESN not found';
      close get_esn_info;
      return;  --Procedure stops here
   end if;
   close get_esn_info;

   if get_esn_info_rec.web_user_objid <> ip_web_user_objid then
      op_err_code := '-303';
      op_err_msg := 'ERROR-00303 ADFCRM_ESN_ACCOUNT.MAKE_ESN_PRIMARY : ESN does not belong to account.';
      return;  --Procedure stops here
   end if;

   update sa.table_x_contact_part_inst
   set x_is_default =0
   where x_contact_part_inst2contact = get_webuser_info_rec.WEB_USER2CONTACT;

   update sa.table_x_contact_part_inst
   set x_is_default =1
   where x_contact_part_inst2contact = get_webuser_info_rec.WEB_USER2CONTACT
   and x_contact_part_inst2part_inst = get_esn_info_rec.OBJID;

   COMMIT;
   op_err_code := 0;
   op_err_msg := 'ESN made primary fo account, Successfully';
EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     op_err_code := SQLCODE;
     op_err_msg  := TRIM(SUBSTR('ERROR ADFCRM_ESN_ACCOUNT.MAKE_ESN_PRIMARY : '||SQLERRM ||CHR(10) ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,1,4000));
     RETURN;
end;
--------------------------------------------------------------------------------
  procedure upd_cai(iv_col_name varchar2,
                    iv_col_val varchar2,
                    iv_con_objid varchar2,
                    iv_user_objid varchar2,
                    iv_bo_objid varchar2)
  is
    sqlstmt varchar2(1000);
  begin
    sqlstmt := ' update sa.table_x_contact_add_info '||
               ' set '||iv_col_name||' = nvl(:iv_col_val,'||iv_col_name||'), '||
               '    x_last_update_date = sysdate, '||
               '    add_info2user      = :iv_user_objid '||
               ' where  add_info2contact = :iv_con_objid '||
               ' and    add_info2bus_org = :iv_bo_objid';

    execute immediate sqlstmt using iv_col_val, iv_user_objid, iv_con_objid,iv_bo_objid;
    commit;
    --dbms_output.put_line(sqlstmt);
  end upd_cai;
--------------------------------------------------------------------------------
  procedure update_contact_consent (ipv_cust_id             sa.table_contact.x_cust_id%type,
                                    ipv_contact_objid       sa.table_contact.objid%type,
                                    ipv_pin                 sa.table_x_contact_add_info.x_pin%type,
                                    ipv_dob                 varchar2, --(String mm/dd/yyyy format)
                                    ipv_consent_email       sa.table_x_contact_add_info.x_do_not_email%type,
                                    ipv_consent_phone       sa.table_x_contact_add_info.x_do_not_phone%type,
                                    ipv_consent_sms         sa.table_x_contact_add_info.x_do_not_sms%type,
                                    ipv_consent_mail        sa.table_x_contact_add_info.x_do_not_mail%type,
                                    ipv_consent_prerecorded sa.table_x_contact_add_info.x_prerecorded_consent%type,
                                    ipv_consent_mobile_ads  sa.table_x_contact_add_info.x_do_not_mobile_ads%type,
                                    ipv_user                sa.table_user.s_login_name%type
                                    )
  as
    p_cust_id     sa.table_contact.x_cust_id%type := ipv_cust_id;
    p_con_objid   sa.table_contact.objid%type;
    p_email       sa.table_contact.e_mail%type;
    p_address     sa.table_contact.address_1%type;
    p_zip         sa.table_contact.zipcode%type;
    n_con_bus_org sa.table_x_contact_add_info.add_info2bus_org%type;
    p_phone       sa.table_contact.phone%type;
    v_user_objid  sa.table_user.objid%type;

    type cntct_rslt is record (con_objid  sa.table_contact.objid%type,
                               cust_id    sa.table_contact.x_cust_id%type,
                               phone      sa.table_contact.phone%type,
                               address    sa.table_contact.address_1%type,
                               zip        sa.table_contact.zipcode%type,
                               email      sa.table_contact.e_mail%type,
                               bus_org    sa.table_x_contact_add_info.add_info2bus_org%type
                               );

    type cntct_rslt_rec is table of cntct_rslt index by pls_integer;
    cntct_rec cntct_rslt_rec;
    email_rec cntct_rslt_rec;
    phone_rec cntct_rslt_rec;
    sms_rec cntct_rslt_rec;
    mail_rec cntct_rslt_rec;

	PRAGMA AUTONOMOUS_TRANSACTION;
    row_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(row_locked, -54);
    cursor myupd_cur is
	    SELECT *
	    FROM   sa.table_x_contact_add_info
	    where  add_info2contact = p_con_objid
	    and    add_info2bus_org = n_con_bus_org
	    FOR UPDATE OF x_pin,
           x_dateofbirth,
           x_do_not_email,
           x_do_not_phone,
           x_do_not_sms,
           x_do_not_mail,
           x_prerecorded_consent,
           x_do_not_mobile_ads,
           x_last_update_date,
           add_info2user
		NOWAIT;
  begin

  /*///////////////////////////////////////////////////////////////////////
  // BASE LOGIC
  // WHEN OPTING OUT THE PROCEDURE WILL SWEEP FOR THE OPTION THE USER IS OPTING OUT + BRAND
  // FOR EXAMPLE (EMAIL + BRAND), (ADDRESS + BRAND), (SMS+BRAND), (PHONE+BRAND)
  // THE PROCEDURE WILL NOT SWEEP CHILD CONTACTS IF THE INFORMATION IS DIFFERENT
  // FOR EXAMPLE IF A CHILD CONTACT HAS A DIFFERENT MAILING ADDRESS THAN THE PARENT
  // AND THE CHILD ADDRESS IS BEING OPT'D OUT, THE PARENT REMAINS OPT'D IN
  //
  // PRECONSENT AND MOBILE ADS ARE LEFT AS IS
  // Per Waraire Hamilton - For the fields Email, Direct Mail, SMS and Phone
  // 0 = opt in, 1 = opt out (field is checked) still applies.
  // After checking WEBCSR, this is correct.
  // Per WEBCSR - Preconsent and Mobile ads are
  // 1 = yes (opt in), 0 = no (opt out) (field is checked)
  ///////////////////////////////////////////////////////////////////////*/

  -- MAIN BODY -----------------------------------------------------------------
    dbms_output.put_line('INPUT ipv_consent_email ('||ipv_consent_email||')');
    dbms_output.put_line('INPUT ipv_consent_phone ('||ipv_consent_phone||')');
    dbms_output.put_line('INPUT ipv_consent_sms ('||ipv_consent_sms||')');
    dbms_output.put_line('INPUT ipv_consent_mail ('||ipv_consent_mail||')');
    dbms_output.put_line('INPUT ipv_consent_prerecorded ('||ipv_consent_prerecorded||')');
    dbms_output.put_line('INPUT ipv_consent_mobile_ads ('||ipv_consent_mobile_ads||')'||chr(10));

    select objid
    into   v_user_objid
    from   table_user
    where  s_login_name = upper(ipv_user);


    -- GET CUST_ID AND BUS ORG INFO --------------------------------------------
    begin
      -- COLLECT SOURCE CONTACT INFO (THIS WILL BE USED AS THE SOURCE INFO FOR THE SEARCHES)
      -- THIS SELECT INTO MAY RETURN MULTIPLE AND BE AN ISSUE, BUT, IT SHOULDNT BECAUSE WE'RE GOING BY X_CUST_ID
      select c.objid,
             c.x_cust_id,
             a.address,
             a.zipcode,
             c.e_mail,
             cai.add_info2bus_org,
             c.phone
      into   p_con_objid,
             p_cust_id,
             p_address,
             p_zip,
             p_email,
             n_con_bus_org,
             p_phone
      from   table_contact c,
             table_contact_role cr,
             table_address a,
             table_site s,
             table_x_contact_add_info cai
      where  1=1
      and    rownum < 2
      and    a.objid        = s.cust_primaddr2address
      and    s.objid        = cr.contact_role2site
      and    c.objid        = cr.contact_role2contact
      and    c.objid        = cai.add_info2contact
      and    (c.objid = ipv_contact_objid --'274812630'
      or      c.x_cust_id = p_cust_id); --'8084221'

    -- UPDATE INFO OF CONTACT RULES --------------------------------------------
    -- UPDATE PIN AND DOB ON SOURCE CONTACT STRICTLY
    -- UPDATE SOURCE CONTACT AND SEARCH FOR OTHER ACCOUNTS SAME BRAND AND UPDATE EMAIL CONSENT
    -- UPDATE SOURCE CONTACT AND SEARCH FOR OTHER ACCOUNTS SAME BRAND AND UPDATE PHONE CONSENT
    -- UPDATE SOURCE CONTACT AND SEARCH FOR OTHER ACCOUNTS SAME BRAND AND UPDATE SMS CONSENT
    -- UPDATE SOURCE CONTACT AND SEARCH FOR OTHER ACCOUNTS SAME BRAND AND UPDATE DIRECT MAIL CONSENT
    for myupd_rec in myupd_cur
	LOOP
    update sa.table_x_contact_add_info
    set    x_pin                  = nvl(ipv_pin,x_pin),
           x_dateofbirth          = nvl(to_date(ipv_dob,'mm/dd/yyyy'),x_dateofbirth),
           x_do_not_email         = nvl(ipv_consent_email,x_do_not_email),
           x_do_not_phone         = nvl(ipv_consent_phone,x_do_not_phone),
           x_do_not_sms           = nvl(ipv_consent_sms,x_do_not_sms),
           x_do_not_mail          = nvl(ipv_consent_mail,x_do_not_mail),
           x_prerecorded_consent  = nvl(ipv_consent_prerecorded,x_prerecorded_consent),
           x_do_not_mobile_ads    = nvl(ipv_consent_mobile_ads,x_do_not_mobile_ads),
           x_last_update_date = sysdate,
           add_info2user      = v_user_objid
    where current of myupd_cur;
    --where  add_info2contact = p_con_objid
    --and    add_info2bus_org = n_con_bus_org;
    END LOOP;

    exception
	  when row_locked THEN
        dbms_output.put_line('Customer info is locked, please try again');  --raise_application_error(-20001, 'this row is locked...');
        return;
      when others then
        dbms_output.put_line('Customer info is not found');
        return;
    end;
    dbms_output.put_line('CONTACT INFO USED CUST_ID ('||p_cust_id||')');
    dbms_output.put_line('CONTACT INFO USED C_OBJID ('||p_con_objid||')');
    dbms_output.put_line('CONTACT INFO USED BUSORG ('||n_con_bus_org||')'||chr(10));

    -- Per Waraire Hamilton - For the fields Email, Direct Mail, SMS and Phone
    -- 0 = opt in, 1 = opt out (field is checked) still applies.

    -- BEGIN SEARCH ------------------------------------------------------------
    if ipv_consent_mail = 1 and p_address is not null then
      -- SWEEP ALL W/SAME ADDRESS
      dbms_output.put_line('SEARCH BY ADDRESS, ZIP ============================================================= '||p_address||','||p_zip);
      select c.objid,
             c.x_cust_id,
             c.phone,
             a.address,
             a.zipcode zip,
             c.e_mail email,
             cai.add_info2bus_org
      bulk collect into mail_rec
      from   table_contact c,
             table_contact_role cr,
             table_address a,
             table_site s,
             table_x_contact_add_info cai
      where  1=1
      and    a.objid              = s.cust_primaddr2address
      and    s.objid              = cr.contact_role2site
      and    c.objid              = cr.contact_role2contact
      and    c.objid              = cai.add_info2contact
      and    a.s_address          = upper(p_address)
      and    a.zipcode            = upper(p_zip)
      and    c.objid             != p_con_objid
      and    cai.add_info2bus_org = n_con_bus_org
      and    a.s_address not in ('NO ADDRESS PROVIDED','NULL','1295 CHARLESTON ROAD','DUMMY','TEST',
                                 'NO INFO AVAILABLE','NO ADDRESS','NULL|NULL','NO ADDRESS PROVIDED',
                                 '232 S 12TH AVE','390 9TH AVE','1','NO ADRESS','GENERAL DELIVERY',
                                 '9700 112TH AVE','NOT PROVIDED','NONE','9700 NW 112 AVE','NO ADRESS',
                                 'GENERAL DELIVERY','9700 NW 112th AVE','.','9700 NW','3 SILLOWAY ST',
                                 '9700 NW 112 AVE','9700 112th AVE','9700 NW 112th AVE','123',
                                 '1 NW 33RD TER','N/A','N/A','702 S 6TH AVE','9700 NW 112 AVE',
                                 '210 S RIO GRANDE ST','507 E CHURCH ST','2759 WEBSTER AVE','39 BOYLSTON ST',
                                 '3900 CAMBRIDGE ST STE 106','2100 LAKESIDE AVE E','310 N 3RD ST','945 N COLLEGE ST',
                                 '0','1550 N MIAMI AVE','NA','639 W CENTRAL BLVD','705 DREXEL ST',
                                 '6220 N NEBRASKA AVE','340 NORTH ST','60244 CR 35','218 IRON AVE SW',
                                 '                              ','9700','123 MAIN ST','NA','90',
                                 'GENERAL DELIVERY','1 HAVEN FOR HOPE WAY');
    end if;

    -- BEGIN SEARCH ------------------------------------------------------------
    if ipv_consent_email = 1 and p_email is not null then
      -- SWEEP ALL W/SAME EMAIL
      dbms_output.put_line('SEARCH BY EMAIL ============================================================= '||upper(p_email));
      select c.objid,
             c.x_cust_id,
             c.phone,
             a.address,
             a.zipcode zip,
             c.e_mail email,
             cai.add_info2bus_org
      bulk collect into email_rec
      from   table_contact c,
             table_contact_role cr,
             table_address a,
             table_site s,
             table_x_contact_add_info cai
      where  1=1
      and    a.objid              = s.cust_primaddr2address
      and    s.objid              = cr.contact_role2site
      and    c.objid              = cr.contact_role2contact
      and    c.objid              = cai.add_info2contact
      and    cai.add_info2bus_org = n_con_bus_org
      and    c.objid             != p_con_objid
      and    upper(c.e_mail)       = upper(p_email)
      and    c.objid in (select x_part_inst2contact
                         from   table_part_inst
                         where  objid in ( select cpi.x_contact_part_inst2part_inst
                                           from   table_x_contact_part_inst cpi,
                                                  table_web_user twu
                                           where  cpi.x_contact_part_inst2contact = twu.web_user2contact
                                           and    twu.s_login_name = upper(p_email)
                                           and    twu.web_user2bus_org = n_con_bus_org));
    end if;

    -- BEGIN SEARCH ------------------------------------------------------------
    if ipv_consent_phone = 1 and p_phone is not null then
      -- SWEEP ALL W/SAME PHONE
      dbms_output.put_line('SEARCH BY CONTACT PHONE ============================================================= '||upper(p_phone));
      select c.objid,
             c.x_cust_id,
             c.phone,
             null address,
             null zip,
             c.e_mail email,
             cai.add_info2bus_org
      bulk collect into phone_rec
      from   table_contact c,
             table_x_contact_add_info cai
      where  1=1
      and    c.objid              = cai.add_info2contact
      and    cai.add_info2bus_org = n_con_bus_org
      and    c.objid             != p_con_objid
      and    c.phone              = p_phone;
    end if;

    -- BEGIN SEARCH ------------------------------------------------------------
    if ipv_consent_sms = 1 then
      dbms_output.put_line('SEARCH BY MIN ============================================================= ');
      -- SWEEP ALL W/SAME MIN
      select c.objid,
             c.x_cust_id,
             c.phone,
             a.address,
             a.zipcode zip,
             c.e_mail email,
             cai.add_info2bus_org
      bulk collect into sms_rec
      from   table_contact c,
             table_contact_role cr,
             table_address a,
             table_site s,
             table_x_contact_add_info cai
      where  1=1
      and    a.objid              = s.cust_primaddr2address
      and    s.objid              = cr.contact_role2site
      and    c.objid              = cr.contact_role2contact
      and    c.objid              = cai.add_info2contact
      and    cai.add_info2bus_org = n_con_bus_org
      and    c.objid             != p_con_objid
      and    c.objid in  (select distinct c.objid --,x_cust_id
                          from   (select x_contact_part_inst2part_inst piobjid
                                  from   table_x_contact_part_inst ttl_pi,
                                         (select cpi.x_contact_part_inst2contact objid
                                          from   table_part_inst p,
                                                 table_contact c,
                                                 table_x_contact_part_inst cpi
                                          where  c.objid = p_con_objid
                                          and    p.x_part_inst2contact = c.objid
                                          and    cpi.x_contact_part_inst2part_inst = p.objid
                                          union
                                          select c.objid
                                          from   table_contact c
                                          where  c.objid = p_con_objid) ttl_c
                                  where ttl_pi.x_contact_part_inst2contact = ttl_c.objid) ttl_account_pi,
                                  table_part_inst pi,
                                  table_contact c
                          where   1=1
                          and     ttl_account_pi.piobjid = pi.objid
                          and     pi.x_part_inst2contact = c.objid);
    end if;

    -- PROCESS FROM RESULT -----------------------------------------------------
    if mail_rec.count >0 then
      for i in 1 .. mail_rec.count
      loop
        dbms_output.put_line('PROCESSING MAIL FOR CUST - '||mail_rec(i).con_objid);
        upd_cai('x_do_not_mail',ipv_consent_mail,mail_rec(i).con_objid,v_user_objid,n_con_bus_org);
      end loop;
    end if;
    -- PROCESS FROM RESULT -----------------------------------------------------
    if email_rec.count >0 then
      for i in 1 .. email_rec.count
      loop
        dbms_output.put_line('PROCESSING EMAIL FOR CUST - '||email_rec(i).con_objid||','||email_rec(i).cust_id);
        upd_cai('x_do_not_email',ipv_consent_email,email_rec(i).con_objid,v_user_objid,n_con_bus_org);
      end loop;
    end if;
    -- PROCESS FROM RESULT -----------------------------------------------------
    if phone_rec.count >0 then
      for i in 1 .. phone_rec.count
      loop
        dbms_output.put_line('PROCESSING PHONE FOR CUST - '||phone_rec(i).con_objid);
        upd_cai('x_do_not_phone',ipv_consent_phone,phone_rec(i).con_objid,v_user_objid,n_con_bus_org);
      end loop;
    end if;
    -- PROCESS FROM RESULT -----------------------------------------------------
    if sms_rec.count >0 then
      for i in 1 .. sms_rec.count
      loop
        dbms_output.put_line('PROCESSING MIN FOR CUST - '||sms_rec(i).con_objid||','||sms_rec(i).cust_id);
        upd_cai('x_do_not_sms',ipv_consent_sms,sms_rec(i).con_objid,v_user_objid,n_con_bus_org);
      end loop;
    end if;
    -- END PROCESS FROM RESULT -------------------------------------------------

    commit;
  end update_contact_consent;
--------------------------------------------------------------------------------
  procedure update_contact_consent (ipv_contact_objid sa.table_contact.objid%type)
  as -- OVERLOADED FOR BATCH PROCESS
    p_cust_id               sa.table_contact.x_cust_id%type;
    p_con_objid             sa.table_contact.objid%type;
    p_email                 sa.table_contact.e_mail%type;
    p_address               sa.table_contact.address_1%type;
    p_zip                   sa.table_contact.zipcode%type;
    n_con_bus_org           sa.table_x_contact_add_info.add_info2bus_org%type;
    p_phone                 sa.table_contact.phone%type;
    v_user_objid            sa.table_user.objid%type;
    p_consent_email         sa.table_x_contact_add_info.x_do_not_email%type;
    p_consent_phone         sa.table_x_contact_add_info.x_do_not_phone%type;
    p_consent_sms           sa.table_x_contact_add_info.x_do_not_sms%type;
    p_consent_mail          sa.table_x_contact_add_info.x_do_not_mail%type;
    p_consent_prerecorded   sa.table_x_contact_add_info.x_prerecorded_consent%type;
    p_consent_mobile_ads    sa.table_x_contact_add_info.x_do_not_mobile_ads%type;
    p_wu_objid              sa.table_web_user.objid%type;
    bc_limit                number := 1000;

    type cntct_rslt is record (con_objid  sa.table_contact.objid%type);

    type cntct_rslt_rec is table of cntct_rslt index by pls_integer;
    web_rec cntct_rslt_rec;
    cntct_rec cntct_rslt_rec;
    email_rec cntct_rslt_rec;
    phone_rec cntct_rslt_rec;
    sms_rec cntct_rslt_rec;
    mail_rec cntct_rslt_rec;

    cursor web_account_cur(wa_p_con_objid number)
    is
    select c.objid
    from   sa.table_contact c,
           sa.table_part_inst pi
    where  1=1
    and pi.x_part_inst2contact = c.objid (+)
    and c.objid != wa_p_con_objid
    and pi.objid in (select cpi.x_contact_part_inst2part_inst
                     from   sa.table_x_contact_part_inst cpi
                     where  1=1
                     and cpi.x_contact_part_inst2contact in (select x_contact_part_inst2contact
                                                             from   table_x_contact_part_inst cpi2,
                                                                    table_part_inst pi,
                                                                    table_contact c
                                                             where  cpi2.x_contact_part_inst2part_inst = pi.objid
                                                             and    pi.x_part_inst2contact = c.objid
                                                             and    c.objid = wa_p_con_objid));

    cursor mail_cur(m_p_address varchar2,m_p_zip varchar2, m_p_con_objid number,m_n_con_bus_org number)
    is
    select c.objid
    from   table_contact c,
           table_contact_role cr,
           table_address a,
           table_site s,
           table_x_contact_add_info cai
    where  1=1
    and    a.objid              = s.cust_primaddr2address
    and    s.objid              = cr.contact_role2site
    and    c.objid              = cr.contact_role2contact
    and    c.objid              = cai.add_info2contact
    and    a.s_address          = upper(m_p_address)
    and    a.zipcode            = upper(m_p_zip)
    and    c.objid             != m_p_con_objid
    and    cai.add_info2bus_org = m_n_con_bus_org
    and    a.s_address not in ('NO ADDRESS PROVIDED','NULL','1295 CHARLESTON ROAD','DUMMY','TEST',
                               'NO INFO AVAILABLE','NO ADDRESS','NULL|NULL','NO ADDRESS PROVIDED',
                               '232 S 12TH AVE','390 9TH AVE','1','NO ADRESS','GENERAL DELIVERY',
                               '9700 112TH AVE','NOT PROVIDED','NONE','9700 NW 112 AVE','NO ADRESS',
                               'GENERAL DELIVERY','9700 NW 112th AVE','.','9700 NW','3 SILLOWAY ST',
                               '9700 NW 112 AVE','9700 112th AVE','9700 NW 112th AVE','123',
                               '1 NW 33RD TER','N/A','N/A','702 S 6TH AVE','9700 NW 112 AVE',
                               '210 S RIO GRANDE ST','507 E CHURCH ST','2759 WEBSTER AVE','39 BOYLSTON ST',
                               '3900 CAMBRIDGE ST STE 106','2100 LAKESIDE AVE E','310 N 3RD ST','945 N COLLEGE ST',
                               '0','1550 N MIAMI AVE','NA','639 W CENTRAL BLVD','705 DREXEL ST',
                               '6220 N NEBRASKA AVE','340 NORTH ST','60244 CR 35','218 IRON AVE SW',
                               '                              ','9700','123 MAIN ST','NA','90',
                               'GENERAL DELIVERY','1 HAVEN FOR HOPE WAY');

    cursor email_cur(e_p_email varchar2, e_n_con_bus_org varchar2, e_p_con_objid number)
    is
    select c.objid
    from   table_x_contact_part_inst cpi,
           table_web_user twu,
           table_part_inst pi,
           table_x_contact_add_info cai,
           table_contact c
    where  cpi.x_contact_part_inst2part_inst = pi.objid
    and    cpi.x_contact_part_inst2contact   = twu.web_user2contact
    and    pi.x_part_inst2contact            = cai.add_info2contact
    and    c.objid                           = cai.add_info2contact
    and    twu.s_login_name                  = upper(e_p_email)
    and    upper(c.e_mail)                   = upper(e_p_email)
    and    twu.web_user2bus_org              = e_n_con_bus_org
    and    pi.x_part_inst2contact           != e_p_con_objid;

    cursor phone_cur(p_n_con_bus_org number, p_p_con_objid number, p_p_phone varchar2)
    is
    select c.objid
    from   table_contact c,
           table_x_contact_add_info cai
    where  1=1
    and    c.objid              = cai.add_info2contact
    and    cai.add_info2bus_org = p_n_con_bus_org
    and    c.objid             != p_p_con_objid
    and    c.phone              = p_p_phone;

    cursor sms_cur(s_n_con_bus_org number, s_p_con_objid number)
    is
    select cai.add_info2contact objid
    from   table_x_contact_add_info cai
    where  1=1
    and    cai.add_info2bus_org = s_n_con_bus_org
    and    cai.add_info2contact in  (select distinct c.objid --,x_cust_id
                        from   (select x_contact_part_inst2part_inst piobjid
                                from   table_x_contact_part_inst ttl_pi,
                                       (select cpi.x_contact_part_inst2contact objid
                                        from   table_part_inst p,
                                               table_contact c,
                                               table_x_contact_part_inst cpi
                                        where  c.objid = s_p_con_objid
                                        and    p.x_part_inst2contact = c.objid
                                        and    cpi.x_contact_part_inst2part_inst = p.objid
                                        union
                                        select c.objid
                                        from   table_contact c
                                        where  c.objid = s_p_con_objid) ttl_c
                                where ttl_pi.x_contact_part_inst2contact = ttl_c.objid) ttl_account_pi,
                                table_part_inst pi,
                                table_contact c
                        where   1=1
                        and     ttl_account_pi.piobjid = pi.objid
                        and     pi.x_part_inst2contact = c.objid
                        and     c.objid != s_p_con_objid);

  begin

  /*///////////////////////////////////////////////////////////////////////
  // BASE LOGIC
  // WHEN OPTING OUT THE PROCEDURE WILL SWEEP FOR THE OPTION THE USER IS OPTING OUT + BRAND
  // FOR EXAMPLE (EMAIL + BRAND), (ADDRESS + BRAND), (SMS+BRAND), (PHONE+BRAND)
  // THE PROCEDURE WILL NOT SWEEP CHILD CONTACTS IF THE INFORMATION IS DIFFERENT
  // FOR EXAMPLE IF A CHILD CONTACT HAS A DIFFERENT MAILING ADDRESS THAN THE PARENT
  // AND THE CHILD ADDRESS IS BEING OPT'D OUT, THE PARENT REMAINS OPT'D IN
  //
  // COLLECT SOURCE CONTACT INFO (THIS WILL BE USED AS THE SOURCE INFO FOR THE SEARCHES)
  // THIS SELECT INTO MAY RETURN MULTIPLE AND BE AN ISSUE, BUT, IT SHOULDNT BECAUSE WE'RE GOING BY X_CUST_ID
  // SEARCH FOR CHILDREN/PARENT ACCOUNTS WITH SAME BRAND AND
  //   UPDATE EMAIL CONSENT
  //   UPDATE PHONE CONSENT
  //   UPDATE SMS CONSENT
  //   UPDATE DIRECT MAIL CONSENT
  //
  // PRECONSENT AND MOBILE ADS ARE LEFT AS IS
  // Per Waraire Hamilton - For the fields Email, Direct Mail, SMS and Phone
  // 0 = opt in, 1 = opt out (field is checked) still applies.
  // After checking WEBCSR, this is correct.
  // Per WEBCSR - Preconsent and Mobile ads are
  // 1 = yes (opt in), 0 = no (opt out) (field is checked)
  ///////////////////////////////////////////////////////////////////////*/

  -- MAIN BODY -----------------------------------------------------------------
    select objid
    into   v_user_objid
    from   table_user
    where  s_login_name = 'SA'; -- USING FOR BATCH

    -- COLLECT THE SOURCE CONTACT INFO
    select c.objid,
           c.x_cust_id,
           a.address,
           a.zipcode,
           c.e_mail,
           cai.add_info2bus_org,
           c.phone,
           cai.x_do_not_email,
           cai.x_do_not_phone,
           cai.x_do_not_sms,
           cai.x_do_not_mail,
           cai.x_prerecorded_consent,
           cai.x_do_not_mobile_ads
    into   p_con_objid,
           p_cust_id,
           p_address,
           p_zip,
           p_email,
           n_con_bus_org,
           p_phone,
           p_consent_email,
           p_consent_phone,
           p_consent_sms,
           p_consent_mail,
           p_consent_prerecorded,
           p_consent_mobile_ads
    from   table_contact c,
           table_contact_role cr,
           table_address a,
           table_site s,
           table_x_contact_add_info cai
    where  1=1
    and    rownum < 2
    and    a.objid        = s.cust_primaddr2address
    and    s.objid        = cr.contact_role2site
    and    c.objid        = cr.contact_role2contact
    and    c.objid        = cai.add_info2contact
    and    (c.objid = ipv_contact_objid);

    dbms_output.put_line('p_consent_mail ('||p_consent_mail||')');
    dbms_output.put_line('p_consent_email ('||p_consent_email||')');
    dbms_output.put_line('p_consent_phone ('||p_consent_phone||')');
    dbms_output.put_line('p_consent_sms ('||p_consent_sms||')');

    dbms_output.put_line('source contact p_con_objid ('||p_con_objid||')');
    dbms_output.put_line('source contact n_con_bus_org ('||n_con_bus_org||')');

    -- CONSENT PRERECORDED AND MOBILE ADS WERE NOT THE CONCERN SO LEFT OUT
    -- Per Waraire Hamilton - For the fields Email, Direct Mail, SMS and Phone
    -- 0 = opt in, 1 = opt out (field is checked) still applies.

    -- COLLECT THE MY ACCOUNT CHILD CONTACTS
    open  web_account_cur(wa_p_con_objid => p_con_objid);
    loop
      fetch web_account_cur bulk collect into web_rec limit bc_limit;
      -- PROCESS CONTACTS FROM MY ACCOUNT -----------------------------------------------------
      for i in 1 .. web_rec.count
      loop
        update table_x_contact_add_info
        set    x_do_not_email = decode(p_consent_email,'1',p_consent_email,x_do_not_email),
               x_do_not_phone = decode(p_consent_phone,'1',p_consent_phone,x_do_not_phone),
               x_do_not_sms   = decode(p_consent_sms,'1',p_consent_sms,x_do_not_sms),
               x_do_not_mail  = decode(p_consent_mail,'1',p_consent_mail,x_do_not_mail)
        where  add_info2contact = web_rec(i).con_objid;
        commit;
      end loop;
      exit when web_rec.count < bc_limit;
    end loop;
    close web_account_cur;

    -- SWEEP ALL W/SAME ADDRESS
    if p_consent_mail = 1 and p_address is not null then
      dbms_output.put_line('SEARCH BY ADDRESS, ZIP ============================================================= '||p_address||','||p_zip);
      open mail_cur(m_p_address => p_address,m_p_zip => p_zip, m_p_con_objid => p_con_objid,m_n_con_bus_org => n_con_bus_org);
      loop
        fetch mail_cur bulk collect into mail_rec limit bc_limit;
        -- PROCESS MAIL FROM RESULT -----------------------------------------------------
        for i in 1 .. mail_rec.count
        loop
          upd_cai('x_do_not_mail',p_consent_mail,mail_rec(i).con_objid,v_user_objid,n_con_bus_org);
        end loop;
        exit when mail_rec.count < bc_limit;
      end loop;
      close mail_cur;
    end if;

    -- SWEEP ALL W/SAME EMAIL
    if p_consent_email = 1 and p_email is not null then
      dbms_output.put_line('SEARCH BY EMAIL ============================================================= '||upper(p_email));
      open email_cur(e_p_email => p_email, e_n_con_bus_org => n_con_bus_org, e_p_con_objid => p_con_objid);
      loop
        fetch email_cur bulk collect into email_rec limit bc_limit;
        -- PROCESS EMAIL FROM RESULT -----------------------------------------------------
        for i in 1 .. email_rec.count
        loop
          upd_cai('x_do_not_email',p_consent_email,email_rec(i).con_objid,v_user_objid,n_con_bus_org);
        end loop;
        exit when email_rec.count < bc_limit;
      end loop;
      close email_cur;
    end if;

    -- SWEEP ALL W/SAME PHONE
    if p_consent_phone = 1 and p_phone is not null then
      dbms_output.put_line('SEARCH BY CONTACT PHONE ============================================================= '||upper(p_phone));
      open phone_cur(p_n_con_bus_org => n_con_bus_org, p_p_con_objid => p_con_objid, p_p_phone => p_phone);
      loop
        fetch phone_cur bulk collect into phone_rec limit bc_limit;
        -- PROCESS PHONE FROM RESULT -----------------------------------------------------
        for i in 1 .. phone_rec.count
        loop
          upd_cai('x_do_not_phone',p_consent_phone,phone_rec(i).con_objid,v_user_objid,n_con_bus_org);
        end loop;
        exit when phone_rec.count < bc_limit;
      end loop;
      close phone_cur;
    end if;

    -- SWEEP ALL W/SAME MIN
    if p_consent_sms = 1 then
      dbms_output.put_line('SEARCH BY MIN/SMS ============================================================= ');
      open sms_cur(s_n_con_bus_org => n_con_bus_org, s_p_con_objid => p_con_objid);
      loop
        fetch sms_cur bulk collect into sms_rec limit bc_limit;
        -- PROCESS SMS FROM RESULT -----------------------------------------------------
        for i in 1 .. sms_rec.count
        loop
          upd_cai('x_do_not_sms',p_consent_sms,sms_rec(i).con_objid,v_user_objid,n_con_bus_org);
        end loop;
        exit when sms_rec.count < bc_limit;
      end loop;
      close sms_cur;
    end if;

  end update_contact_consent;
--------------------------------------------------------------------------------
  function CONTACT(p_zip varchar2,
                          p_phone varchar2,
                          p_f_name varchar2,
                          p_l_name varchar2,
                          p_m_init varchar2,
                          p_add_1 varchar2,
                          p_add_2 varchar2,
                          p_city varchar2,
                          p_st varchar2,
                          P_Country Varchar2,
                          p_fax varchar2,
                          P_Email Varchar2,
                          p_dob varchar2, --(String mm/dd/yyyy format)
                          ip_do_not_phone in table_x_contact_add_info.x_do_not_phone%type, -- (NEW)
                          ip_do_not_mail in table_x_contact_add_info.x_do_not_mail%type, -- (NEW)
                          ip_do_not_sms in table_x_contact_add_info.x_do_not_sms%type, -- (NEW)
                          ip_prer_consent in table_x_contact_add_info.x_prerecorded_consent%type,
                          ip_mobile_ads in table_x_contact_add_info.x_do_not_mobile_ads%type,
                          ip_pin in table_x_contact_add_info.x_pin%type,
                          ip_squestion in table_web_user.x_secret_questn%type,
                          ip_sanswer in table_web_user.x_secret_ans%type,
                          ip_dummy_email in number,  -- 1:create a dummy account, 0: email should be provided
                          ip_overwrite_esn in number,  -- 1: Allow movement of an active esn between accounts, 0: Not allow movement of an active esn
                          ip_do_not_email in number, --1: Not Allow email communivations, 0: Allow email communications
                          P_Brand Varchar2, -- (creating a contact only)
                          p_pw in table_web_user.password%type,    --  (creating a contact only)
                          p_c_objid number, -- (updating a contact only)
                          p_esn in table_part_inst.part_serial_no%type,  -- (Add ESN to Account)
                          ip_user in sa.table_user.s_login_name%type
                          )
  return varchar2
  as
   CURSOR contact (
        c_phone      IN table_contact.phone%type
       ,c_first_name IN table_contact.s_first_name%type
       ,c_last_name  IN table_contact.s_last_name%type
      ) IS
        SELECT c.objid
          FROM table_contact c
         WHERE c.phone = c_phone
           AND c.s_first_name || '' = UPPER(c_first_name)
           AND c.s_last_name || '' = UPPER(c_last_name);

    contact_rec   contact%rowtype;

    CURSOR link2address (c_Objid in table_contact.objid%type
      ) IS
        SELECT s.cust_primaddr2address, s.objid site_objid
        from   table_contact_role cr,
               table_site s
        where  cr.contact_role2contact  = c_Objid
        and    cr.primary_site = 1
        And    S.Objid  = Cr.Contact_Role2site;

    link2address_rec link2address%rowtype;

    CURSOR zip_curs IS
      SELECT *
      FROM sa.table_x_zip_code
      WHERE x_zip = p_zip;

    zip_curs_rec zip_curs%rowtype;

    cursor brand_cur is
    select org_id
    from sa.table_bus_org bo,sa.table_part_inst pi, sa.table_mod_level ml, sa.table_part_num pn
    where pi.part_serial_no = p_esn
    and pi.x_domain = 'PHONES'
    and pi.n_part_inst2part_mod = ml.objid
    and ml.part_info2part_num = pn.objid
    and pn.part_num2bus_org = bo.objid
    and bo.org_id <> 'GENERIC';

    brand_rec brand_cur%rowtype;

	-- ESNs associated in no account
    cursor contact_esn_cur (c_objid number) is
    select part_serial_no,wu.objid web_user_objid
    from sa.table_part_inst a, table_web_user wu
    where X_PART_INST2CONTACT = c_objid
    and x_domain = 'PHONES'
    and not exists (select '1' from table_x_contact_part_inst b
                    where X_CONTACT_PART_INST2PART_INST = a.objid)
    and wu.web_user2contact = c_objid;

    contact_esn_rec contact_esn_cur%rowtype;

    v_country_objid number;
    v_country       varchar2(40);
    V_C_Objid       Number;
    v_err_code      varchar2(4000);
    v_err_msg       varchar2(4000);
    v_out_msg       varchar2(300);
    v_cnt           number;
    v_web_user_objid number;
    v_group_id     varchar2(30);

  function get_country (p_country in varchar2)
  return varchar2 is
     v_country sa.table_country.name%type := '';
  begin
    -- OBTAIN THE COUNTRY BY S_NAME
    begin
      select name
      into   v_country
      from   table_country
      where  s_name = upper(p_country);
    exception
      when no_data_found then
        -- OBTAIN THE COUNTRY BY OBJID
        begin
          select name
          into   v_country
          from   table_country
          where  objid = p_country;
        exception
          when others then
            null;
        end;
      when others then
        null;
    end;

    if v_country is null then
      v_country := 'USA';
    end if;

    return v_country;

  exception
    when others then
      v_country := 'USA'; --default value
  end get_country;
  Begin
     /*---------------------------------------------------------------------*/
     /*   Validate input parameters                                         */
     /*---------------------------------------------------------------------*/
     -- CR 38603 : Implement option for 4 or 5 digits Security PIN
     if ( ip_pin is not null and ( length(nvl(ip_pin,'0')) < 4 OR length(nvl(ip_pin,'0')) > 5 ) )
     then
          v_out_msg  := 'ERROR: Invalid Security PIN, this could be 4 or 5 digits.';
          return v_out_msg;  --Procedure stops here
     end if;

     if add_months( to_date(p_dob, 'mm/dd/yyyy'), 13*12) > trunc(sysdate)
     then
          v_out_msg  := 'ERROR-00099 ADFCRM_ESN_ACCOUNT.CONTACT : Contact age is not allowed, please check DOB';
          return v_out_msg;  --Procedure stops here
     end if;

     if p_zip is not null and P_Country = 'USA'
     then
        OPEN zip_curs;
        FETCH zip_curs INTO zip_curs_rec;
        IF zip_curs%NOTFOUND THEN
          close zip_curs;
          v_out_msg  := 'ERROR-00100 ADFCRM_ESN_ACCOUNT.CONTACT : Invalid Zipcode';
          return v_out_msg;  --Procedure stops here
        END IF;
        close zip_curs;
      end if;

    --  insert into testlogs values ('user-'||ip_user);
       /**CR51354 - Communication History preferences **/
             begin

         SELECT objid into v_web_user_objid FROM table_user WHERE s_login_name = UPPER(ip_user);
        exception
          when others then
                   null;
        end;
    --insert into testlogs values (v_web_user_objid||'-user-'||ip_user);
     /*---------------------------------------------------------------------*/
     /*   Check that don't exist a contact with same name and phone         */
     /*---------------------------------------------------------------------*/
     if p_c_objid is null then
       OPEN contact(p_phone,p_f_name,p_l_name);
       FETCH contact INTO contact_rec;
       IF contact%FOUND THEN
          close contact;
          v_out_msg  := 'ERROR-00101 ADFCRM_ESN_ACCOUNT.CONTACT : Contact Already Exists for that name and phone ';
          return v_out_msg;  --Procedure stops here
       END IF;
       close contact;


       /*---------------------------------------------------------------------*/
        -- Check brand name
       /*---------------------------------------------------------------------*/
       select count(*)
       into   v_cnt
       from   table_bus_org
       where  org_id = p_brand;

       if v_cnt = 0 then
          v_out_msg  := 'ERROR-00102 ADFCRM_ESN_ACCOUNT.CONTACT : Brand name is invalid';
          return v_out_msg;  --Procedure stops here
       end if;


       /*---------------------------------------------------------------------*/
        -- Check PIN Mandatory for TOTAL WIRELESS BRANDS
       /*---------------------------------------------------------------------*/
       -- REL736_Core 3/30/2016
       -- Defect 716 fix
      if( ip_pin is null and P_Brand = 'TOTAL_WIRELESS')
      then
        v_out_msg  := 'ERROR-00104 ADFCRM_ESN_ACCOUNT.CONTACT : Please provide 4 Digits Security PIN';
        return v_out_msg;
      end if;






    --insert into testlogs values (v_web_user_objid||'-create-'||ip_user);
     /*---------------------------------------------------------------------*/
      -- CREATE CONTACT INFO IF CONTACT AND ADDRESS OBJID MISSING
     /*---------------------------------------------------------------------*/
        contact_pkg.createcontact_prc(p_esn => null,
                                      p_first_name => p_f_name,
                                      p_last_name => p_l_name,
                                      p_middle_name => p_m_init,
                                      p_phone => p_phone,
                                      p_add1 => p_add_1,
                                      p_add2 => p_add_2,
                                      p_fax => p_fax,
                                      p_city => p_city,
                                      p_st => p_st,
                                      p_zip => p_zip,
                                      p_email => p_email,
                                      p_email_status => 0,
                                      p_roadside_status => 0,
                                      p_no_name_flag => null,
                                      p_no_phone_flag => null,
                                      p_no_address_flag => null,
                                      p_sourcesystem => 'TAS', -- USED TO BE 'APEX'
                                      p_brand_name => p_brand,
                                      p_do_not_email => nvl(ip_do_not_email,1),
                                      p_do_not_phone => 1,
                                      p_do_not_mail => 1,
                                      p_do_not_sms => 1,
                                      p_ssn => null,
                                      p_dob => to_date(p_dob,'mm/dd/yyyy'),
                                      p_do_not_mobile_ads => 1,
                                      p_contact_objid => v_c_objid,
                                      p_err_code => v_err_code,
                                      p_err_msg => v_err_msg,
                                      p_add_info2web_user => v_web_user_objid);  -- CR51354 log username for comm history

 --insert into testlogs values (v_web_user_objid||'-create-'||ip_user||'-'||v_err_msg||'-'||v_err_code||'-'||v_c_objid);

       if v_err_code <> '0' then

          ROLLBACK;
          v_out_msg := 'ERROR-00103 ADFCRM_ESN_ACCOUNT.CONTACT : Unable to create contact '||v_err_msg;
          return v_out_msg;  --Procedure stops here
       end if;
     Else

          V_C_Objid := P_C_Objid;
          V_Country := Get_Country(P_Country);
          If Length(V_Country) > 0 Then
             Select Objid
             Into   V_Country_Objid
             From   Table_Country
             Where  S_Name = Upper(V_Country);
          End If;

          update table_contact c
          set  c.first_name        = nvl(trim(p_f_name), c.first_name),
               c.s_first_name      = upper(nvl(trim(p_f_name),c.s_first_name)),
               c.last_name         = nvl(trim(p_l_name),c.last_name),
               c.s_last_name       = upper(nvl(trim(p_l_name),c.s_last_name)),
               c.x_middle_initial  = p_m_init,
               c.phone             = nvl(trim(p_phone),c.phone),
               C.Fax_Number        = P_Fax,
               c.e_mail            = nvl(trim(upper(p_email)),c.e_mail),
               c.address_1         = nvl(trim(p_add_1),c.address_1),
               c.address_2         = p_add_2,
               c.City              = nvl(trim(P_City),c.City),
               c.state             = nvl(trim(p_st),c.state),
               c.zipcode           = nvl(trim(p_zip),c.zipcode),
               c.x_dateofbirth     = nvl(to_date(p_dob,'mm/dd/yyyy'),c.x_dateofbirth),
               c.country           = decode(trim(p_country),null,c.country,v_country),
               c.update_stamp      = sysdate
          where  objid = v_c_Objid;

     /*---------------------------------------------------------------------*/
     /*   Validate input parameters                                         */
     /*---------------------------------------------------------------------*/
        OPEN link2address(v_c_Objid);
        FETCH link2address INTO link2address_rec;
        IF link2address%FOUND THEN

          if nvl(link2address_rec.cust_primaddr2address,0) < 0 then
             -- Create a new row in table_address and update the link
             select sa.seq('address') into link2address_rec.cust_primaddr2address from dual;
             --Insert record in table_address
                 INSERT INTO table_address
                     (objid
                     ,address
                     ,s_address
                     ,city
                     ,s_city
                     ,state
                     ,s_state
                     ,zipcode
                     ,address_2
                     ,dev
                     ,address2time_zone
                     ,address2country
                     ,address2state_prov
                     ,update_stamp)
                 VALUES
                     (link2address_rec.cust_primaddr2address
                     ,p_add_1
                     ,UPPER(p_add_1)
                     ,zip_curs_rec.x_city
                     ,UPPER(zip_curs_rec.x_city)
                     ,zip_curs_rec.x_state
                     ,UPPER(zip_curs_rec.x_state)
                     ,zip_curs_rec.x_zip
                     ,p_add_2
                     ,NULL
                     ,(SELECT objid FROM table_time_zone WHERE NAME = 'EST' and rownum < 2)
                     ,v_country_objid
                     ,(select objid from table_state_prov where s_name = upper(p_st) and state_prov2country = v_country_objid)
                     ,SYSDATE);
             --update table_site
                 update table_site
                 set    cust_primaddr2address = link2address_rec.cust_primaddr2address
                 where  objid = link2address_rec.SITE_OBJID;
          else
             if length(trim(p_add_1)) > 0 or
                Length(Trim(P_Add_2)) > 0 Or
                Length(Trim(P_City)) > 0 Or
                Length(Trim(P_St)) > 0 Or
                Length(Trim(P_Zip)) > 0 Or
                Length(Trim(P_Country)) > 0
             then
                 update table_address a
                 SET
                   a.address         = nvl(trim(p_add_1),a.address),
                   a.s_address         = upper(nvl(trim(p_add_1),a.address)),
                   a.address_2         = p_add_2,
                   a.City              = nvl(trim(P_City),a.City),
                   A.S_City            = Upper(Nvl(Trim(P_City),A.City)),
                   a.state             = nvl(trim(p_st),a.state),
                   A.Zipcode           = Nvl(Trim(P_Zip),A.Zipcode),
                   a.address2country   = decode(trim(p_country),null,a.address2country,v_country_objid),
                   a.address2state_prov= decode(trim(p_st),null,a.address2state_prov
                                                               ,nvl((select objid
                                                                     from table_state_prov
                                                                     where s_name = upper(p_st)
                                                                     and state_prov2country = nvl(v_country_objid,a.address2country) )
                                                                 ,a.address2state_prov)),
                   a.update_stamp      = sysdate
                 where  a.objid = link2address_rec.cust_primaddr2address;
                end if;
          end if;
        END IF;
        close link2address;
     end if;

     /*------------------------------------------------------------------------------------*/
      -- Update contact additional information
     /*------------------------------------------------------------------------------------*/
    -- BROUGHT BACK ORIGINAL CODE
  -- insert into testlogs values (v_web_user_objid||'-update-'||ip_user||'-'||v_c_Objid);

    update sa.table_x_contact_add_info
    set    x_pin                  = nvl(ip_pin,x_pin),
           x_dateofbirth          = nvl(to_date(p_dob,'mm/dd/yyyy'),x_dateofbirth),
           x_do_not_email         = nvl(ip_do_not_email,x_do_not_email),
           x_do_not_phone         = nvl(ip_do_not_phone,x_do_not_phone),
           x_do_not_sms           = nvl(ip_do_not_sms,x_do_not_sms),
           x_do_not_mail          = nvl(ip_do_not_mail,x_do_not_mail),
           x_prerecorded_consent  = nvl(ip_prer_consent,x_prerecorded_consent),
           x_do_not_mobile_ads    = nvl(ip_mobile_ads,x_do_not_mobile_ads),
           x_last_update_date 	  = sysdate,
          -- add_info2user          = (SELECT objid FROM table_user WHERE s_login_name = UPPER(USER)), commented for CR51354 to store TAS agent name
           add_info2user      = v_web_user_objid,  --CR51354 log username for communication history
           SOURCE_SYSTEM      ='TAS'  --CR51354 (defect 31649 - source system not updated)
     where ADD_INFO2CONTACT = v_c_Objid;

    -- START NEW CODE - CR DO NOT CALL BATCH ----------------------------------------
    merge into sa.adfcrm_cai_pend_batch
    using (select 1 from dual)
    on   ( contact_objid = v_c_objid)
    when not matched then
    insert (contact_objid)
    values (v_c_objid);
    -- END NEW CODE - CR DO NOT CALL BATCH ----------------------------------------

     -- START NEW CODE - CR DO NOT CALL ----------------------------------------
     -- CHANGE ONLY THE CONTACT INFO OF THE ACCOUNT YOU'RE VIEWING
/*
     update_contact_consent (ipv_cust_id             => null,
                             ipv_contact_objid       => v_c_objid,
                             ipv_pin                 => ip_pin,
                             ipv_dob                 => p_dob,
                             ipv_consent_email       => ip_do_not_email,
                             ipv_consent_phone       => ip_do_not_phone,
                             ipv_consent_sms         => ip_do_not_sms,
                             ipv_consent_mail        => ip_do_not_mail,
                             ipv_consent_prerecorded => ip_prer_consent,
                             ipv_consent_mobile_ads  => ip_mobile_ads,
                             ipv_user                => ip_user);
*/
     -- END NEW CODE - CR DO NOT CALL ------------------------------------------
     /*------------------------------------------------------------------------------------*/
      -- Check if contact already has an account then update security question and answer
      -- otherwise create an account with ramdon and default passwd
     /*------------------------------------------------------------------------------------*/

      sa.Adfcrm_esn_account.Web_User_Prc(Ip_Webuser2contact => V_C_Objid,
                             Ip_Login => P_Email,
                             Ip_Squestion => Ip_Squestion,
                             Ip_Sanswer => Ip_Sanswer,
                             Ip_pw => p_pw,
                             ip_dummy_email => ip_dummy_email,
                             Op_web_user_objid => v_web_user_objid,
                             Op_Err_Code => V_Err_Code,
                             op_err_msg => v_err_msg);

      if V_Err_Code <> '0' then
         rollback;
         V_Out_Msg := v_err_msg;
         return v_out_msg;
      end if;

      if p_esn is not null then   -- Add ESN to Account

             sa.ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT(
                 ip_web_user_objid  => v_web_user_objid,
                 ip_ESN_NICK_NAME => 'Default',
                 ip_ESN => p_esn,
                 ip_overwrite_esn => ip_overwrite_esn,
                 ip_user => ip_user,
                 op_err_code => v_err_code,
                 op_err_msg => v_err_msg);

      else
         --Add Orphan ESNs from Contact to Account
         for contact_esn_rec in contact_esn_cur(v_c_Objid) loop
               ADD_ESN_TO_ACCOUNT(
                 ip_web_user_objid  => contact_esn_rec.web_user_objid,
                 ip_ESN_NICK_NAME => 'Default',
                 ip_ESN => contact_esn_rec.part_serial_no,
                 ip_overwrite_esn => ip_overwrite_esn,
                 ip_user => ip_user,
                 op_err_code => v_err_code,
                 op_err_msg => v_err_msg);

         end loop;

      end if;

      if V_Err_Code <> '0' then
         rollback;
         V_Out_Msg := v_err_msg;
         return v_out_msg;
      end if;

    commit;

    Select X_Cust_Id
    Into V_Out_Msg
    From table_contact
    Where Objid = V_C_Objid;

    return v_out_msg;
  exception
    when others then
      rollback;
      V_Out_Msg := 'ERROR ADFCRM_ESN_ACCOUNT.CONTACT : Unable to perform action for this contact '||Sqlerrm;
      return v_out_msg;
  end contact;
--------------------------------------------------------------------------------
  Procedure Web_User_Prc (
      ip_webuser2contact in table_web_user.web_user2contact%type,
      ip_login  in table_web_user.login_name%type,
      ip_squestion in table_web_user.x_secret_questn%type,
      ip_sanswer in table_web_user.x_secret_ans%type,
      ip_pw in  table_web_user.password%type,
      ip_dummy_email in number,  -- 1:create a dummy account, 0: email should be provided
      op_web_user_objid out table_web_user.objid%type,
      op_err_code OUT VARCHAR2,
      op_err_msg OUT VARCHAR2
  ) IS

     /*------------------------------------------------------------------------------------*/
      -- Check if contact already has an account then update security question and answer
      -- otherwise create an account with ramdon and default passwd
     /*------------------------------------------------------------------------------------*/
      cursor web_user_info (
         ip_webuser2contact in table_web_user.web_user2contact%type,
         ip_bus_org in table_bus_org.objid%type
      ) is
        select *
        from   table_web_user
        where  WEB_USER2CONTACT = ip_webuser2contact
        and    web_user2bus_org = ip_bus_org;

      web_user_info_rec  web_user_info%rowtype;

      cursor web_user_login (
         ip_login  in table_web_user.login_name%type,
         ip_bus_org in table_bus_org.objid%type
      ) is
        select Table_Web_User.*, bo.org_id
        From   Table_Web_User, table_bus_org bo
        where  s_login_name = upper(ip_login)
        and    web_user2bus_org = ip_bus_org
        and    bo.objid = web_user2bus_org ;


      web_user_login_rec  web_user_login%rowtype;

      cursor contact is
        select c.objid,
               cai.add_info2bus_org,
               c.x_cust_id,
               c.x_cust_id||'@'||ltrim(web_site,'www.') dummy_email
        from   table_contact c,
               table_x_contact_add_info cai,
               table_bus_org bo
        where  c.objid = ip_webuser2contact
        and    cai.ADD_INFO2CONTACT = c.objid
        and    bo.objid = cai.add_info2bus_org
        ;

      contact_rec  contact%rowtype;

      cursor get_related_contact (
         ip_contact_id in table_part_inst.x_part_inst2contact%type
      ) is
          select
               web.objid web_user_objid,
               web.web_user2contact accowner_contact_id,
               web.web_user2bus_org
          FROM table_part_inst pi,
               table_x_contact_part_inst conpi,
               table_web_user web
          WHERE pi.x_part_inst2contact = ip_contact_id
          and   conpi.x_contact_part_inst2part_inst = pi.objid
          and   web.web_user2contact = conpi.x_contact_part_inst2contact
          ;

      get_related_contact_rec  get_related_contact%rowtype;

      v_web_user_objid table_web_user.objid%type;
      v_login          table_web_user.login_name%type;
  BEGIN

      v_login := ip_login;

      if nvl(ip_dummy_email,0) = 0 and v_login is null
      then
           op_err_code := -600;
           op_err_msg := 'ERROR-00600 ADFCRM_ESN_ACCOUNT.WEB_USER_PRC : Login/Email missing';
           return;  --Procedure stops here
      end if;

      if ip_webuser2contact is null
      then
           op_err_code := -601;
           op_err_msg := 'ERROR-00601 ADFCRM_ESN_ACCOUNT.WEB_USER_PRC : Contact missing ';
           return;  --Procedure stops here
      else
          OPEN contact;
          FETCH contact INTO contact_rec;
          IF contact%notFOUND THEN
             close contact;
             op_err_code := -602;
             op_err_msg := 'ERROR-00602 ADFCRM_ESN_ACCOUNT.WEB_USER_PRC : Contact not found';
             return;  --Procedure stops here
          END IF;
          close contact;
      end if;

      if nvl(ip_dummy_email,0) = 1
      then
         v_login := contact_rec.dummy_email;
         UPDATE TABLE_CONTACT C
         set    c.e_mail =  contact_rec.dummy_email
         where  c.objid =  contact_rec.objid;
      end if;

      /*---------------------------------------------------------------------*/
           --   Check if contact is linked  with an account
      /*---------------------------------------------------------------------*/
      open get_related_contact(ip_webuser2contact);
      FETCH get_related_contact INTO get_related_contact_rec;
      if get_related_contact%found then
             if get_related_contact_rec.accowner_contact_id <> ip_webuser2contact
             then
                close get_related_contact;
                op_err_code := '0';
                op_err_msg := 'Contact is not account owner and is already linked to that account';
                return;  --Procedure stops here
             end if;
      END IF;
      close get_related_contact;

      /*---------------------------------------------------------------------*/
          --     Check if login already exists
      /*---------------------------------------------------------------------*/
      OPEN web_user_login(v_login,contact_rec.add_info2bus_org);
      FETCH web_user_login INTO web_user_login_rec;
      IF web_user_login%FOUND THEN
             if web_user_login_rec.web_user2contact  <> ip_webuser2contact then
               close web_user_login;
               Op_Err_Code := -604;
               op_err_msg := 'ERROR-00602 ADFCRM_ESN_ACCOUNT.WEB_USER_PRC : Account already exists for login/email provided  brand:'||web_user_login_rec.org_id;
               return;  --Procedure stops here
             end if;
      END IF;
      close web_user_login;

     /*---------------------------------------------------------------------*/
     --   Check if contact is linked directly with an account
     /*---------------------------------------------------------------------*/
      OPEN web_user_info(ip_webuser2contact,contact_rec.add_info2bus_org);
      FETCH web_user_info INTO web_user_info_rec;
      IF web_user_info%FOUND THEN
          close web_user_info;
          /*---------------------------------------------------------------------*/
          --     Update security question and answer
          /*---------------------------------------------------------------------*/
          update table_web_user w
          set   w.x_secret_questn   = nvl(ip_squestion,w.x_secret_questn),
                w.s_x_secret_questn = upper(nvl(ip_squestion,w.s_x_secret_questn)),
                w.x_secret_ans      = nvl(ip_sanswer,w.x_secret_ans),
                w.s_x_secret_ans    = upper(nvl(ip_sanswer,w.s_x_secret_ans)),
                w.login_name        = nvl(v_login,w.login_name),
                w.s_login_name      = upper(nvl(v_login,w.login_name))
          where  w.objid = web_user_info_rec.objid;

          op_web_user_objid:=web_user_info_rec.objid;

          /*---------------------------------------------------------------------*/
          --     Update customer email in credit card information
          /*---------------------------------------------------------------------*/
          update TABLE_X_CREDIT_CARD
          set    x_customer_email = nvl(v_login,x_customer_email)
          where  x_credit_card2contact = ip_webuser2contact;

      ELSE
           close web_user_info;

          /*---------------------------------------------------------------------*/
          --     Create an account and link with the contact
          /*---------------------------------------------------------------------*/
          if v_login is null
          then
             op_err_code := -603;
             op_err_msg := 'ERROR-00603 ADFCRM_ESN_ACCOUNT.WEB_USER_PRC : Login/Email missing';
             return;  --Procedure stops here
          end if;

          select sa.seq('web_user')
          into v_web_user_objid
          from dual;

          insert into table_web_user
          (objid
          ,login_name
          ,s_login_name
          ,password
          ,status
          ,x_secret_questn
          ,s_x_secret_questn
          ,x_secret_ans
          ,s_x_secret_ans
          ,web_user2user
          ,web_user2contact
          ,web_user2bus_org
          ,x_last_update_date)
          values (v_web_user_objid
                 ,v_login
                 ,upper(v_login)
                 ,ip_pw
                 ,1
                 ,ip_squestion
                 ,upper(ip_squestion)
                 ,ip_sanswer
                 ,upper(ip_sanswer)
                 ,(SELECT objid FROM table_user WHERE s_login_name = UPPER(USER))
                 ,contact_rec.objid
                 ,contact_rec.add_info2bus_org
                 ,null);
      END IF;

      op_web_user_objid := v_web_user_objid;
      op_err_code := '0';
      op_err_msg := 'Account successfully processed';
      return;
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK;
       op_err_code := SQLCODE;
       op_err_msg  := TRIM(SUBSTR('ERROR ADFCRM_ESN_ACCOUNT.WEB_USER_PRC : '||SQLERRM ||CHR(10) ||
                             DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                      ,1,4000));
       return;
  end web_user_prc;
--------------------------------------------------------------------------------

 function ADD_MISSING_CONTACT (ip_esn varchar2,
                               ip_user varchar2) return varchar2 as

    cursor account_cur is
    select wu.objid, pi.x_part_inst2contact,Cpi.X_Esn_Nick_Name
    from Table_X_Contact_Part_Inst cpi,
         table_web_user wu,
         table_part_inst pi
    where 1=1
    and pi.part_serial_no = ip_esn
    and pi.x_domain = 'PHONES'
    and pi.objid = Cpi.X_Contact_Part_Inst2part_Inst
    and Cpi.X_Contact_Part_Inst2contact = Wu.Web_User2contact;

    account_rec account_cur%rowtype;

    v_error_code varchar2(4000);
    v_error_msg varchar2(4000);

 begin

    open account_cur;
    fetch account_cur into account_rec;
    if account_cur%found then
       if account_rec.x_part_inst2contact is null then
          REMOVE_ESN_FROM_ACCOUNT(
            IP_WEB_USER_OBJID => account_rec.objid,
            IP_ESN => IP_ESN,
            OP_ERR_CODE => v_error_code,
            OP_ERR_MSG => v_error_msg
          );
          ADD_ESN_TO_ACCOUNT(
            IP_WEB_USER_OBJID => account_rec.objid,
            IP_ESN_NICK_NAME => account_rec.X_Esn_Nick_Name,
            IP_ESN => IP_ESN,
            IP_OVERWRITE_ESN => 1,
            IP_USER => IP_USER,
            OP_ERR_CODE => v_error_code,
            OP_ERR_MSG => v_error_msg
          );
       end if;
    end if;
    close account_cur;

    return v_error_msg;

 end ADD_MISSING_CONTACT;

--------------------------------------------------------------------------------
  procedure fix_missing_cai_bus_org(ip_contact_objid varchar2)
  as
  begin
    -- TO FIX ISSUE WHEN ENTERING CONTACT DETAILS FLOW
    -- PROBLEM: CHECKBOXES AND UPDATE PROCEDURES BREAK BECAUSE OF MISSING
    -- BUS ORG IN THE ADD INFO TABLE.
    if ip_contact_objid is null then
      return;
    end if;

    for i in (select c.objid, count(cai.objid) cai_obj, count(cai.add_info2bus_org) bo_obj
              from   table_x_contact_add_info cai,
                     table_contact c
              where  cai.add_info2contact = c.objid
              and    c.objid = ip_contact_objid
              group by c.objid)
    loop
      if i.objid is not null then
        if i.cai_obj > 0 then
          if i.bo_obj > 0 then
            dbms_output.put_line('BUS ORG EXISTS EXITING');
            return;
          else
            -- CONTACT EXISTS, ADD INFO TABLE EXISTS, BUT, BUS ORG IS MISSING
            for j in (select pn.part_num2bus_org
                      from   sa.table_x_contact_part_inst cpi,
                             sa.table_part_inst pi,
                             sa.table_mod_level m,
                             sa.table_part_num pn
                      where  1=1
                      and    m.part_info2part_num = pn.objid
                      and    pi.n_part_inst2part_mod = m.objid
                      and    cpi.x_contact_part_inst2part_inst = pi.objid
                      and cpi.x_contact_part_inst2contact in (select x_contact_part_inst2contact
                                                              from   table_x_contact_part_inst cpi2,
                                                                     table_part_inst pi,
                                                                     table_contact c
                                                              where  cpi2.x_contact_part_inst2part_inst = pi.objid
                                                              and    pi.x_part_inst2contact = c.objid
                                                              and    c.objid = i.objid--wa_p_con_objid
                                                             )
                      union
                      select pn.part_num2bus_org
                      from   table_part_inst pi,
                             sa.table_mod_level m,
                             sa.table_part_num pn
                      where  1=1
                      and    m.part_info2part_num = pn.objid
                      and    pi.n_part_inst2part_mod = m.objid
                      and    pi.x_part_inst2contact = i.objid
                      )
            loop
              dbms_output.put_line('ASSIGNING BUS ORG ================='||j.part_num2bus_org);
              update table_x_contact_add_info
              set add_info2bus_org = j.part_num2bus_org
              where add_info2contact = i.objid;
              commit;
              return;
            end loop;
          end if;
        end if;
      end if;
    end loop;
  end fix_missing_cai_bus_org;

--------------------------------------------------------------------------------

procedure add_esn_to_group (
    ip_user            in varchar2,
    ip_web_user_objid  in varchar2,
    ip_group_objid     in varchar2,
    ip_esn             in varchar2,
    ip_esn_nick_name   in varchar2,
    op_err_code        out varchar2,
    op_err_msg         out varchar2) is


   v_error_code varchar2(200);
   v_error_msg varchar2(200);
   v_group_id varchar2(20);
   v_group_found number;
   v_master varchar2(1):='N';
   v_subscriber_id number;
   v_member_id number;
   v_members number;
begin
   op_err_code:= '0';
   op_err_msg := 'ESN added to group';


     add_esn_to_account (
        ip_web_user_objid,
        ip_esn_nick_name,
        ip_esn,
        0, --ip_overwrite_esn
        ip_user,
        v_error_code,
        v_error_msg);

     if v_error_code in ('0','-6')  then

        select count(*)
        into v_group_found
        from sa.x_account_group
        where objid = ip_group_objid;

        if v_group_found > 0 then

          select count(*)
          into v_members
          from sa.x_account_group_member
          where v_group_id = ip_group_objid
          and status <> 'EXPIRED';

          --v_subscriber_id:= SA.BRAND_X_PKG.get_subscriber_id(ip_esn);

          sa.BRAND_X_PKG.create_member ( ip_group_objid,
                          ip_esn,
                          null,
                          'PENDING_ENROLLMENT',
                          v_members+1,
                          v_subscriber_id,
                          v_member_id,
                          v_error_code,
                          v_error_msg);
            COMMIT;

--          SA.BRAND_X_PKG.INSERT_MEMBER(
--            IP_ACCOUNT_GROUP_ID => ip_group_objid,
--            IP_ESN => ip_esn,
--            IP_PROMOTION_ID => null,
--            IP_STATUS => 'PENDING_ENROLLMENT',
--            IP_MEMBER_ORDER => v_members+1,
--            IP_SUBSCRIBER_ID => v_subscriber_id,
--            IP_MASTER_FLAG => v_master,
--            IP_SITE_PART_ID => null,
--            IP_PROGRAM_PARAM_ID => null,
--            OP_ACCOUNT_GROUP_MEMBER_ID => v_member_id,
--            OP_ERR_CODE => v_error_code,
--            OP_ERR_MSG => v_error_msg
--          );

          if v_error_code<>'0' then
             op_err_code:= v_error_code;
             op_err_msg := v_error_msg;
          end if;
        end if;
     else
        op_err_code:= v_error_code;
        op_err_msg := v_error_msg;
        return;
     end if;

end;

function delete_group_member (
    ip_esn      in varchar2,
    ip_reason   in varchar2) return varchar2 as

    cursor c1 is
    select remove_account_group_flag
    from sa.table_x_code_table
    where x_code_name = ip_reason
    and x_code_type = 'DA';

    r1 c1%rowtype;

    cursor c2 is
    select  ag.OBJID GROUP_ID,agm.OBJID MEMBER_ID
    from TABLE_WEB_USER WEB, TABLE_X_CONTACT_PART_INST CONPI, TABLE_PART_INST PI, x_account_group ag, x_account_group_member agm
    where 1=1
    and PI.part_serial_no = ip_esn
    and PI.x_domain = 'PHONES'
    and PI.OBJID = CONPI.X_CONTACT_PART_INST2PART_INST
    and CONPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT
    and agm.esn = PI.PART_SERIAL_NO
    and agm.ACCOUNT_GROUP_ID = ag.objid
    and agm.STATUS <> 'EXPIRED';

    r2 c2%rowtype;

    v_error_code varchar2(200):='0';
    v_error_msg varchar2(200);
    v_esn varchar2(30);
begin

   v_esn := ip_esn;

   open c1;
   fetch c1 into r1;
   if c1%found then
      if r1.remove_account_group_flag=1 then
         open c2;
         fetch c2 into r2;
         if c2%found then
            BEGIN
               sa.BRAND_X_PKG.DELETE_MEMBER(
               IP_ACCOUNT_GROUP_ID => r2.GROUP_ID,
               IOP_ESN => v_esn,
               IP_ACCOUNT_GROUP_MEMBER_ID => r2.MEMBER_ID,
               ip_bypass_last_mbr_flag => 'Y',
               OP_ERR_CODE => v_error_code,
               OP_ERR_MSG => v_error_msg);

               COMMIT;
            EXCEPTION
               when others then null;
            END;
         end if;
         close c2;
      end if;
   end if;
   close c1;

   if v_error_code <> '0' then
      return 'ERROR: '||v_error_msg;
   else
      return 'SUCCESS';
   end if;
end delete_group_member;

procedure link_esn_to_account (
    ip_user            in varchar2,
    ip_web_user_objid  in varchar2,
    ip_group_objid     in varchar2,
    ip_esn             in varchar2,
    ip_esn_nick_name   in varchar2,
    op_err_code        out varchar2,
    op_err_msg         out varchar2) is
    v_is_default number;
begin
    if ip_web_user_objid is null or ip_esn is null then
        op_err_code := -700;
        op_err_msg := 'ERROR-00700 ADFCRM_ESN_ACCOUNT.link_esn_to_account web_user_objid or ESN is missing';
        return;  --Procedure stops here
    end if;
   /*---------------------------------------------------------------------*/
   /*  Get target account information                                     */
   /*---------------------------------------------------------------------*/
   open get_webuser_info(ip_web_user_objid);
   fetch get_webuser_info into get_webuser_info_rec;
   if get_webuser_info%notfound
   then
      op_err_code := '-701';
      op_err_msg := 'ERROR-00003 ADFCRM_ESN_ACCOUNT.ADD_ESN_TO_ACCOUNT : Web User Account not found';
      close get_webuser_info;
      return;  --Procedure stops here
   end if;
   close get_webuser_info;
   /*---------------------------------------------------------------------*/
   /*  Check if the esn is the first in the account to set as primary
   /*---------------------------------------------------------------------*/
    select decode(count(*),0,1,0) x_is_default   --setting the primary esn.
    into   v_is_default
    from   table_x_contact_part_inst
    where  x_contact_part_inst2contact = get_webuser_info_rec.web_user2contact
    and    x_is_default = 1;
    begin
        /*---------------------------------------------------------------------*/
        /*   Link ESN to Target account/contact                                */
        /*---------------------------------------------------------------------*/
        INSERT INTO table_x_contact_part_inst
            (objid
            ,x_contact_part_inst2contact
            ,x_contact_part_inst2part_inst
            ,X_ESN_NICK_NAME
            ,X_IS_DEFAULT)
        SELECT
             sa.seq('x_contact_part_inst') seq_contact_part_inst
            ,get_webuser_info_rec.web_user2contact
            ,pi.objid
            ,ip_esn_nick_name
            ,v_is_default
        FROM sa.table_part_inst pi
        WHERE pi.part_serial_no = ip_esn
        AND x_domain = 'PHONES';

        op_err_code := 0;
        op_err_msg := 'ESN linked to account, Successfully';
    exception
    when others then
        op_err_code := -710;
        op_err_msg := 'ERROR-00700 ADFCRM_ESN_ACCOUNT.link_esn_to_account '||sqlcode;
    end;
end link_esn_to_account;

procedure update_dummy_account (
    ip_user            in varchar2,
    ip_web_user_objid  in varchar2,
    ip_new_login_name  in varchar2,
    ip_new_pin         in varchar2,
    ip_new_dob         in varchar2,
    ip_first_name      in varchar2,
    ip_last_name       in varchar2,
    op_err_code        out varchar2,
    op_err_msg         out varchar2) is

      cursor web_user_info (
         ip_web_user_objid in table_web_user.objid%type
      ) is
        select wu.*,
               substr(login_name,1,instr(login_name,'@')-1) acct_name
        from   table_web_user wu
        where  objid = ip_web_user_objid;

      web_user_info_rec  web_user_info%rowtype;

      cursor web_user_login (
         ip_login  in table_web_user.login_name%type,
         ip_bus_org in table_bus_org.objid%type
      ) is
        select Table_Web_User.*, bo.org_id
        From   Table_Web_User, table_bus_org bo
        where  s_login_name = upper(ip_login)
        and    web_user2bus_org = ip_bus_org
        and    bo.objid = web_user2bus_org ;

      web_user_login_rec  web_user_login%rowtype;

begin
      OPEN web_user_info(ip_web_user_objid);
      FETCH web_user_info INTO web_user_info_rec;
      IF web_user_info%FOUND THEN
          close web_user_info;
          if not(regexp_like(web_user_info_rec.acct_name,'^[0-9]*$')) then
            --Do not send ERROR if it is not dummy.
            op_err_code := '0';
            op_err_msg := 'Account successfully processed';

            --Op_Err_Code := -805;
            --op_err_msg := 'ERROR-00805 UPDATE_DUMMY_ACCOUNT : Accounr registered is not dummy, '||web_user_login_rec.login_name;
            return;  --Procedure stops here
          end if;
     /*---------------------------------------------------------------------*/
     /*   Validate input parameters                                         */
     /*---------------------------------------------------------------------*/
      if ip_new_login_name is null or ip_new_pin is null or ip_new_dob is null
      then
           op_err_code := -800;
           op_err_msg := 'ERROR-00800 UPDATE_DUMMY_ACCOUNT : Please provide the account information Login/Email, PIN and DOB';
           return;  --Procedure stops here
      end if;

     if ( ip_new_pin is not null and ( length(nvl(ip_new_pin,'0')) < 4 OR length(nvl(ip_new_pin,'0')) > 5 ) )
     then
           op_err_code := -801;
           op_err_msg := 'ERROR-00801 UPDATE_DUMMY_ACCOUNT : Invalid Security PIN, this could be 4 or 5 digits.';
           return;  --Procedure stops here
     end if;

     if add_months( to_date(ip_new_dob, 'mm/dd/yyyy'), 13*12) > trunc(sysdate)
     then
        op_err_code := -802;
        op_err_msg := 'ERROR-00802 UPDATE_DUMMY_ACCOUNT :  Contact age is not allowed, please check DOB.';
        return;  --Procedure stops here
     end if;

          /*---------------------------------------------------------------------*/
          --     Check if new login already exists
          /*---------------------------------------------------------------------*/
          OPEN web_user_login(ip_new_login_name,web_user_info_rec.web_user2bus_org);
          FETCH web_user_login INTO web_user_login_rec;
          IF web_user_login%FOUND THEN
            Op_Err_Code := -810;
            op_err_msg := 'ERROR-00810 UPDATE_DUMMY_ACCOUNT : Login/email provided already exists for this brand '||web_user_login_rec.org_id;
            return;  --Procedure stops here
          END IF;
          close web_user_login;

          /*---------------------------------------------------------------------*/
          --     Update login name
          /*---------------------------------------------------------------------*/
          update table_web_user w
          set   w.login_name        = nvl(ip_new_login_name,w.login_name),
                w.s_login_name      = upper(nvl(ip_new_login_name,w.login_name))
          where  w.objid = web_user_info_rec.objid;

          update table_contact c
          set  c.first_name        = nvl(trim(ip_first_name), c.first_name),
               c.s_first_name      = upper(nvl(trim(ip_first_name),c.s_first_name)),
               c.last_name         = nvl(trim(ip_last_name),c.last_name),
               c.s_last_name       = upper(nvl(trim(ip_last_name),c.s_last_name)),
               c.x_dateofbirth     = nvl(to_date(ip_new_dob,'mm/dd/yyyy'),c.x_dateofbirth),
               c.update_stamp      = sysdate
          where  objid = web_user_info_rec.web_user2contact;

          update sa.table_x_contact_add_info
          set  x_pin                  = nvl(ip_new_pin,x_pin),
               x_dateofbirth          = nvl(to_date(ip_new_dob,'mm/dd/yyyy'),x_dateofbirth),
               x_last_update_date 	  = sysdate,
               add_info2user          = (SELECT objid FROM table_user WHERE s_login_name = UPPER(ip_user))
          where ADD_INFO2CONTACT = web_user_info_rec.web_user2contact;
      ELSE
         close web_user_info;
      END IF;
      commit;
      op_err_code := '0';
      op_err_msg := 'Account successfully processed';
      return;
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK;
       op_err_code := SQLCODE;
       op_err_msg  := TRIM(SUBSTR('ERROR UPDATE_DUMMY_ACCOUNT : '||SQLERRM ||CHR(10) ||
                             DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                      ,1,4000));
       return;
end update_dummy_account;

function get_esn_by_contact (ip_contact_objid in varchar2)
return varchar2 is

	cursor get_primary_by_contact(ip_contact_objid in varchar2) is
	  select  pi.part_serial_no
	  from    sa.table_x_contact_part_inst cpi,
			  sa.table_part_inst           pi
	   where cpi.x_contact_part_inst2contact = ip_contact_objid
	   and   pi.objid = cpi.x_contact_part_inst2part_inst
	   order by nvl(cpi.x_is_default,0) desc;

	cursor get_esn_by_contact(ip_contact_objid in varchar2) is
	   select pi.part_serial_no
	   from   sa.table_part_inst           pi
	   where  pi.x_part_inst2contact = ip_contact_objid
	   order by warr_end_date desc
	   ;

	rec get_primary_by_contact%rowtype;

begin
	--Search assuming ip_contact_objid is web_user2contact
	open get_primary_by_contact(ip_contact_objid);
	fetch get_primary_by_contact into rec;
	close get_primary_by_contact;

	--Search when ip_contact_objid is x_part_inst2contact
	if rec.part_serial_no is null then
	  open get_esn_by_contact(ip_contact_objid);
	  fetch get_esn_by_contact into rec;
	  close get_esn_by_contact;
	end if;

	return rec.part_serial_no;
end get_esn_by_contact;

END ADFCRM_ESN_ACCOUNT;
/