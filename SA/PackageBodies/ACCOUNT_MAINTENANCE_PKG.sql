CREATE OR REPLACE PACKAGE BODY sa."ACCOUNT_MAINTENANCE_PKG" as

 procedure replace_account (p_old_acct_num varchar2,
 p_old_acct_objid number,
 p_replace_acct_num varchar2,
 p_carr_objid number,
 p_status out varchar2,
 p_msg out varchar2)
 as
 l_step varchar2(100);
 l_replace_acct_objid number;
 l_new_acct_hist_objid number;
 l_current_time date := sysdate;
 l_i number;
 l_count number;
 l_create_acct_flag varchar2(1) := 'N';
 l_acct_num varchar2(30);

 cursor c1 is
 select a.account_hist2part_inst part_inst_objid,
 a.objid account_hist_objid
 from table_x_account_hist a
 where a.account_hist2x_account = p_old_acct_objid
 and ( a.x_end_date is null
 OR to_char(a.x_end_date,'DD-MON-RR') = '01-JAN-53')
 ;

 begin

 --
 -- To ensure that the old account number does match
 -- objid
 --
 l_step := 'validate old account number and objid';
 begin
 select x_acct_num into l_acct_num from table_x_account
 where objid = p_old_acct_objid;

 if l_acct_num <> p_old_acct_num then
     p_status := 'F';
      p_msg := 'Error on step <'||l_step||
      '>: Account number and objid do not match.';
      return;
 end if;
 exception
     when others then
      p_status := 'F';
      p_msg := 'Error on step <'||l_step||
      '>: Account number and objid do not match.';
      return;
 end ;

 --
 -- replacement account can not be the same as old account
 --
 l_step := 'validate old account and replacement account';
 if p_old_acct_num = p_replace_acct_num then
     p_status := 'F';
     p_msg := 'Error on step <'||l_step||
     '>: Can not replace the existing account with the same account number.';
 return;
 end if;
 --
 -- Old account is set to inactive
 --
 l_step := 'update table_x_account set status to Inactive';
 begin
 update table_x_account
 set x_status = 'Inactive'
 where objid = p_old_acct_objid;
 exception
 when others then
 rollback;
 p_status := 'F';
 p_msg := 'Error on step <'||l_step||'>: '||sqlerrm;
 return;
 end;

 --
 -- Insert a new account if replacement account is not
 -- exists in the database
 --
 l_step := 'get objid for replcement account';
 begin
      select objid into l_replace_acct_objid
      from table_x_account
      where account2x_carrier = p_carr_objid
      and x_acct_num = p_replace_acct_num ;
 exception
      when NO_DATA_FOUND then
      -- the replacement account is not in database
      l_create_acct_flag := 'Y';
      when others then
      p_msg := 'Error on step <'||l_step||'> '||SQLERRM;
      p_status := 'F';
      return;
 end ;

      if l_create_acct_flag = 'Y' then
 -- the replace account does not exist in table_x_account
 -- create a new account

 begin
 l_step := 'create new account';
 -- 04/01/03 select seq_x_account.nextval + power(2,28)
 select seq('x_account')
 into l_replace_acct_objid from dual;

 insert into table_x_account values
 ( l_replace_acct_objid ,
 p_carr_objid,
 p_replace_acct_num,
 'Active' );
 exception
 when others then
 rollback;
 p_status := 'F';
 p_msg := 'Error on step <'||l_step||'>: '||sqlerrm;
 return;
 end ;

 end if;

 --
 -- If lines exists under old account, for each line set
 -- x_account_hist.x_end_date to current date
 -- and insert a new line to relate account hist record
 -- to replacement account
 --
 l_i := 0;
 for c1_rec in c1 loop

 begin
 l_step := 'update table_x_account_hist for objid '||
 c1_rec.account_hist_objid;
 update table_x_account_hist
 set x_end_date = l_current_time
 where objid = c1_rec.account_hist_objid;
 exception
 when others then
 rollback;
 p_status := 'F';
 p_msg := 'Error on step <'||l_step||'>: '||sqlerrm;
 return;
 end ;

 -- Insert a new account hist record to relate account hist
 -- record to replacement account

 begin
 -- 04/01/03 select seq_x_account_hist.nextval + power(2,28)
 select seq('x_account_hist')
 into l_new_acct_hist_objid
 from dual;

 l_step := 'insert into table_x_account_hist ';

 insert into table_x_account_hist values
 (
 l_new_acct_hist_objid,
 c1_rec.part_inst_objid,
 l_replace_acct_objid,
 null, -- ACCOUNT_HIST2X_PI_HIST
 to_date('01-JAN-1753','DD-MON-RRRR'), -- X_END_DATE
 l_current_time -- X_START_DATE
 );
 exception
 when others then
 rollback;
 p_status := 'F';
 p_msg := 'Error on step <'||l_step||'>: '||sqlerrm;
 return;
 end;

 l_i := l_i + 1;
 end loop;

 p_msg := 'table_x_acct_hist, '||l_i|| ' records have been updated and '||l_i||
 'record(s) have been created';
 p_status := 'S';
 -- rollback;
 commit;
 exception
 when others then
 rollback;
 p_status := 'F';
 p_msg := 'Unexpected Error: '||sqlerrm;
 end replace_account;

---------------------------------------------------------

Procedure update_account (p_tran_type number,
 p_pi_objid number,
 p_acct_objid number,
 p_acct_num varchar2,
 p_carr_id number,
 p_status out varchar2,
 p_msg out varchar2)
 as
 l_step varchar2(100);
 l_acct_objid number;
 l_new_acct_hist_objid number;
 l_current_time date := sysdate;
 l_cnt number;
 l_c varchar2(3);


 cursor c1 is
 Select *
 From table_x_account_hist a
 Where account_hist2part_inst in (Select objid
 From table_part_inst
 Where x_domain = 'LINES'
 And part_inst2carrier_mkt =(Select objid
 From table_x_carrier
 Where x_carrier_id = p_carr_id))
 And (a.x_end_date is null
 Or a.x_end_date = Trunc(To_Date('01/01/1753','MM/DD/YYYY'))
 );

 cursor c2 is
 Select *
 From table_x_account_hist a
 Where account_hist2part_inst = p_pi_objid
 And (a.x_end_date is null
 Or a.x_end_date = Trunc(To_Date('01/01/1753','MM/DD/YYYY'))
 );

 Begin
 -- Getting objid of account number
 --
 l_step := 'Getting objid for account';
 l_acct_objid := p_acct_objid;

 -- If Account History exists, for each record found set
 -- x_account_hist.x_end_date to current date
 -- and insert a new line to relate account hist record
 -- to selected account
 --
 l_cnt := 0;

 -- If transaction is of selected lines then use cursor(c2)
 IF p_tran_type = 0 THEN
 For c_rec in c2 Loop
 Begin
 l_step := 'update table_x_account_hist for objid '||
 c_rec.objid;
 Update table_x_account_hist
 Set x_end_date = l_current_time
 Where objid = c_rec.objid;
 Exception
 When Others Then
 Rollback;
 p_status := 'F';
 p_msg := 'Error on step <'||l_step||'>: '||sqlerrm;
 Return;
 End;

 -- Insert a new account hist record to relate account hist
 -- record to replacement account

 Begin
 -- 04/01/03 Select seq_x_account_hist.nextval + power(2,28)
 select seq('x_account_hist')
 into l_new_acct_hist_objid
 From dual;

 l_step := 'insert into table_x_account_hist ';

 Insert into table_x_account_hist values
 (
 l_new_acct_hist_objid,
 c_rec.account_hist2part_inst,
 l_acct_objid,
 null, -- ACCOUNT_HIST2X_PI_HIST
 to_date('01-JAN-1753','DD-MON-RRRR'), -- X_END_DATE
 l_current_time -- X_START_DATE
 );
 Exception
 When Others Then
 Rollback;
 p_status := 'F';
 p_msg := 'Error on step <'||l_step||'>: '||sqlerrm;
 Return;
 End;
 l_cnt := l_cnt + 1;
 End Loop;

 -- else If transaction is of selected carrier then use cursor(c1)
 ELSIF p_tran_type = 1 THEN
 For c_rec in c1 Loop
 Begin
 l_step := 'update table_x_account_hist for objid '||
 c_rec.objid;
 Update table_x_account_hist
 Set x_end_date = l_current_time
 Where objid = c_rec.objid;
 Exception
 When Others Then
 Rollback;
 p_status := 'F';
 p_msg := 'Error on step <'||l_step||'>: '||sqlerrm;
 Return;
 End;

 -- Insert a new account hist record to relate account hist
 -- record to replacement account

 Begin
 -- 04/01/03 Select seq_x_account_hist.nextval + power(2,28)
 select seq('x_account_hist')
 into l_new_acct_hist_objid
 From dual;

 l_step := 'insert into table_x_account_hist ';

 Insert into table_x_account_hist values
 (
 l_new_acct_hist_objid,
 c_rec.account_hist2part_inst,
 l_acct_objid,
 null, -- ACCOUNT_HIST2X_PI_HIST
 to_date('01-JAN-1753','DD-MON-RRRR'), -- X_END_DATE
 l_current_time -- X_START_DATE
 );
 Exception
 When Others Then
 Rollback;
 p_status := 'F';
 p_msg := 'Error on step <'||l_step||'>: '||sqlerrm;
 Return;
 End;
 l_cnt := l_cnt + 1;
 End Loop;

 END IF;

 p_msg := 'Updated '|| l_cnt|| ' lines to carrier account number: '|| p_acct_num;
 p_status := 'S';
 Commit;
 Exception
 When Others Then
 Rollback;
 p_status := 'F';
 p_msg := 'Unexpected Error: '||sqlerrm;
 End update_account;

PROCEDURE copy_contact_info ( i_old_contact_id  IN  table_contact.objid%type,
                              i_sourcesystem    IN  VARCHAR2,
                              o_new_contact_id  OUT table_contact.objid%type,
                              o_err_code        OUT NUMBER,
                              o_err_msg         OUT VARCHAR2) IS

  CURSOR get_current_acctinfo (p_old_contact_id in table_contact.objid%TYPE) IS
    SELECT c.objid contact_objid,
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
           nvl(c.dev,0) copy_counter
    FROM   table_contact c,
           table_x_contact_add_info cai,
           table_contact_role cr,
           table_address a,
           table_site s,
           table_bus_org bo
    WHERE  1 = 1
    AND    c.objid = p_old_contact_id
    AND    c.objid = cr.contact_role2contact
    AND    s.objid = cr.contact_role2site
    AND    cr.primary_site = 1
    AND    a.objid = s.cust_primaddr2address
    AND    c.objid = cai.add_info2contact (+)
    AND    cai.add_info2bus_org = bo.objid (+);

  get_current_acctinfo_rec  get_current_acctinfo%ROWTYPE;
  esn_count number;
begin

   -- get Contact info for the given ESN
   open get_current_acctinfo(i_old_contact_id);
   fetch get_current_acctinfo into get_current_acctinfo_rec;
   IF get_current_acctinfo%notfound THEN
      o_err_code := 210;
      o_err_msg := 'CONTACT NOT FOUND';
      close get_current_acctinfo;
      RETURN;
   END IF;
   CLOSE get_current_acctinfo;


   IF get_current_acctinfo_rec.copy_counter > 0 THEN
     contact_pkg.createcontact_prc ( p_esn               => null,
                                     p_first_name        => get_current_acctinfo_rec.first_name ||' copy_'||to_char(get_current_acctinfo_rec.copy_counter+1),
                                     p_last_name         => get_current_acctinfo_rec.last_name,
                                     p_middle_name       => get_current_acctinfo_rec.x_middle_initial,
                                     p_phone             => get_current_acctinfo_rec.phone,
                                     p_add1              => get_current_acctinfo_rec.address,
                                     p_add2              => get_current_acctinfo_rec.address_2,
                                     p_fax               => get_current_acctinfo_rec.fax_number,
                                     p_city              => get_current_acctinfo_rec.city,
                                     p_st                => get_current_acctinfo_rec.state,
                                     p_zip               => get_current_acctinfo_rec.zipcode,
                                     p_email             => get_current_acctinfo_rec.e_mail,
                                     p_email_status      => 0,
                                     p_roadside_status   => 0,
                                     p_no_name_flag      => null,
                                     p_no_phone_flag     => null,
                                     p_no_address_flag   => null,
                                     p_sourcesystem      => i_sourcesystem,
                                     p_brand_name        => get_current_acctinfo_rec.org_id,
                                     p_do_not_email      => 1,
                                     p_do_not_phone      => 1,
                                     p_do_not_mail       => 1,
                                     p_do_not_sms        => 1,
                                     p_ssn               => null,
                                     p_dob               => get_current_acctinfo_rec.x_dateofbirth,
                                     p_do_not_mobile_ads => 1,
                                     p_contact_objid     => o_new_contact_id,
                                     p_err_code          => o_err_code,
                                     p_err_msg           => o_err_msg );

   ELSE
     -- Reuse Account Contact if it is the first ESN in the account
     o_new_contact_id := get_current_acctinfo_rec.contact_objid;
   END IF;

   UPDATE table_contact
   SET    dev = NVL(get_current_acctinfo_rec.copy_counter,0) + 1
   WHERE  objid = get_current_acctinfo_rec.contact_objid;

   -- UPDATE MIRROR THE ADD INFO TABLE
   FOR i IN ( SELECT *
              FROM   table_x_contact_add_info
              WHERE  add_info2contact = i_old_contact_id)
   LOOP
      UPDATE table_x_contact_add_info
      SET    x_do_not_email = i.x_do_not_email,
             x_do_not_phone = i.x_do_not_phone,
             x_do_not_sms = i.x_do_not_sms,
             x_do_not_mail = i.x_do_not_mail
      WHERE  add_info2contact = o_new_contact_id;

   END LOOP; -- i

EXCEPTION
  WHEN OTHERS THEN
    o_err_code := 999;
    o_err_msg  := SUBSTR('ERROR IN COPY_CONTACT_INFO : ' || SQLERRM , 1, 4000);
    RETURN;
END copy_contact_info;


-- Procedure used to add an esn to an existing web account
PROCEDURE add_esn_to_account ( i_web_user_objid     IN  sa.table_web_user.objid%type,
                               i_esn_nick_name      IN  sa.table_x_contact_part_inst.x_esn_nick_name%type,
                               i_esn                IN  sa.table_part_inst.part_serial_no%type,
                               i_transfer_esn_flag  IN  VARCHAR2 DEFAULT 'N',  -- Y: Allow movement of an active esn between accounts, N: Not allow movement of an active esn
                               i_user_login_name    IN  sa.table_user.s_login_name%TYPE,
                               i_sourcesystem       IN  VARCHAR2,
                               o_err_code           OUT NUMBER,
                               o_err_msg            OUT VARCHAR2 ) IS

  n_new_contact_id  NUMBER;
  n_cnt_records     NUMBER := 1;
  cst               customer_type;
  c                 customer_type;
  c_result          VARCHAR2(100);

  --CR54704 LIFELINE changes start
  c_is_lifeline_enrolled  VARCHAR2(1);
  n_enrolled_esn_count    NUMBER;
  --CR54704 LIFELINE changes end
  CURSOR get_webuser_info IS
    SELECT web.web_user2bus_org,
           web.web_user2contact,
           bo.org_id           ,
           web.login_name      ,
           web.objid
    FROM   table_web_user web,
           table_bus_org  bo
    WHERE  web.objid = i_web_user_objid
    AND    bo.objid = web.web_user2bus_org;

  get_webuser_info_rec  get_webuser_info%ROWTYPE;

  CURSOR get_contact ( p_contact_objid in table_contact.objid%TYPE ) IS
    SELECT *
    FROM   table_contact
    WHERE  objid = p_contact_objid;

  get_contact_rec   get_contact%ROWTYPE;

  CURSOR get_esn_info IS
    SELECT pi_esn.objid,
           pi_esn.x_part_inst2contact,
           web.objid web_user_objid,
           web.web_user2bus_org,
           pn.part_num2bus_org,
           conpi.x_is_default,
           bo.org_id,
           pi_esn.x_part_inst_status,
           pi_esn.part_serial_no,
           pn.x_technology,
           pn.part_number,
           pc.name class_name
    FROM   table_part_inst pi_esn,
           table_x_contact_part_inst conpi,
           table_web_user web,
           table_mod_level ml,
           table_part_num pn,
           table_bus_org bo,
           table_part_class pc
    WHERE  pi_esn.part_serial_no = i_esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    conpi.x_contact_part_inst2part_inst (+) = pi_esn.objid
    AND    web.web_user2contact (+) = conpi.x_contact_part_inst2contact
    AND    ml.objid = pi_esn.n_part_inst2part_mod
    AND    pn.objid = ml.part_info2part_num
    AND    bo.objid = pn.part_num2bus_org
    AND    pc.objid = pn.part_num2part_class;

  get_esn_info_rec  get_esn_info%ROWTYPE;


  CURSOR get_enroll_info IS
    SELECT pe.*,
           pp.x_prog_class
    FROM   sa.x_program_enrolled pe,
           sa.x_program_parameters pp,
           sa.table_part_inst pi
    WHERE  pe.x_esn = i_esn
    AND    pe.x_enrollment_status NOT IN ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
    AND    pp.objid = pe.pgm_enroll2pgm_parameter
    and    pp.x_prog_class <> 'WARRANTY'
    AND    pi.part_serial_no = pe.x_esn
    AND    pi.x_domain = 'PHONES'
    AND    pi.x_part_inst_status = '52';

  get_enroll_info_rec  get_enroll_info%ROWTYPE;

BEGIN
  IF i_sourcesystem IS NULL THEN
    o_err_code := 100;
    o_err_msg := 'SOURCESYSTEM CANNOT BE EMPTY';
  END IF;

  IF i_esn IS NULL THEN
    o_err_code := 110;
    o_err_msg := 'ESN CANNOT BE EMPTY';
  END IF;

  cst := customer_type ( i_esn => i_esn );
  c   := cst.retrieve;

  -- get ESN information
  open get_esn_info;
  fetch get_esn_info into get_esn_info_rec;
  if get_esn_info%notfound then
     o_err_code := 120;
     o_err_msg := 'ESN NOT FOUND';
     close get_esn_info;
     return;
  end if;
  close get_esn_info;
  --CR54704 LIFELINE changes start
  --Check if ESN is enrolled in LIFELINE
  BEGIN
    SELECT 'Y'
    INTO   c_is_lifeline_enrolled
    FROM   ll_subscribers
    WHERE  current_esn = i_esn
    AND    enrollment_status = 'ENROLLED'
    AND    TRUNC(NVL(projected_deenrollment, SYSDATE)) >= TRUNC(SYSDATE);
  EXCEPTION
    WHEN OTHERS THEN
      c_is_lifeline_enrolled := 'N';
  END;

  IF NVL(c_is_lifeline_enrolled, 'N') = 'Y'
  THEN
    --Check if target account already has a LIFELINE enrolled ESN
    BEGIN
      SELECT count(pi_esn.part_serial_no)
      INTO   n_enrolled_esn_count
      FROM   table_part_inst pi_esn,
             table_x_contact_part_inst cpi,
             table_web_user wu,
             ll_subscribers llsub
      WHERE  wu.objid = i_web_user_objid
      AND    cpi.x_contact_part_inst2contact = wu.web_user2contact
      AND    cpi.x_contact_part_inst2part_inst = pi_esn.objid
      AND    llsub.current_esn = pi_esn.part_serial_no
      AND    llsub.enrollment_status = 'ENROLLED'
      AND    TRUNC(NVL(llsub.projected_deenrollment, SYSDATE+1)) >= TRUNC(SYSDATE);
    EXCEPTION
      WHEN OTHERS THEN
        n_enrolled_esn_count := 0;
    END;

    IF n_enrolled_esn_count > 0
    THEN
      o_err_code := 230;
      o_err_msg := 'TARGET ACCOUNT ALREADY HAS A LIFELINE ENROLLED ESN';
      RETURN;
    END IF;
  END IF;
  --CR54704 LIFELINE changes end

  -- Check if ESN is linked to the account
  IF nvl(get_esn_info_rec.web_user_objid,-1) = i_web_user_objid THEN
    o_err_code := 130;
    o_err_msg := 'ESN ALREADY LINKED TO THE ACCOUNT';
    RETURN;
  END IF;

  -- Check if the ESN is enrolled in autorefill program
  OPEN get_enroll_info;
  FETCH get_enroll_info INTO get_enroll_info_rec;
  IF get_enroll_info%FOUND THEN
    -- Assume the ESN belongs to an account already
    IF get_enroll_info_rec.pgm_enroll2web_user IS NULL THEN
      -- Check if ESN belongs to any account
      SELECT COUNT(1)
      INTO   n_cnt_records
      FROM   sa.table_part_inst pi,
             table_x_contact_part_inst conpi,
             table_web_user web
      WHERE  pi.part_serial_no = get_enroll_info_rec.x_esn
      AND    pi.x_domain = 'PHONES'
      AND    conpi.x_contact_part_inst2part_inst = pi.objid
      AND    web.web_user2contact = conpi.x_contact_part_inst2contact;
    END IF;
    IF n_cnt_records > 0 THEN
      o_err_code := 140;
      o_err_msg := 'ESN IS ENROLLED IN AUTOREFILL PROGRAM';
      CLOSE get_enroll_info;
      RETURN;
    END IF;
  END IF;
  CLOSE get_enroll_info;

  -- Get target account information
  open get_webuser_info;
  fetch get_webuser_info into get_webuser_info_rec;
  if get_webuser_info%notfound
  then
    o_err_code := 150;
    o_err_msg := 'WEB USER ACCOUNT NOT FOUND';
    close get_webuser_info;
    return;
  end if;
  close get_webuser_info;

  if get_webuser_info_rec.web_user2contact IS NULL then
    o_err_code := 160;
    o_err_msg := 'TARGET ACCOUNT CONTACT NOT FOUND';
    return;
  end if;

  -- If ESN is Home Alert then check valid phone number and email
  IF c.model_type IN ('HOME ALERT','CAR CONNECT') THEN
      open get_contact(get_webuser_info_rec.web_user2contact);
      fetch get_contact into get_contact_rec;
      if get_contact%notfound then
        o_err_code := 170;
        o_err_msg := 'ACCOUNT CONTACT NOT FOUND';
        close get_contact;
        return;
      else
        -- Email NOT valid
        IF NOT (regexp_like(get_contact_rec.e_mail,'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,4}') AND
             length(get_contact_rec.e_mail) > 6 AND
             get_contact_rec.e_mail not like get_contact_rec.x_cust_id||'@'||'%')
        OR
        -- Phone not valid
        NOT (regexp_like(get_contact_rec.phone,'[0-9]{10,10}') AND
             length(get_contact_rec.phone) > 9 and
             get_contact_rec.phone != get_contact_rec.x_cust_id)
        THEN
          o_err_code := 180;
          o_err_msg := 'ACCOUNT SHOULD HAVE A VALID PHONE NUMBER AND EMAIL';
          CLOSE get_contact;
          RETURN;
        end if;
      end if;
      if get_contact%isopen then
        close get_contact;
      end if;
  end if;

  -- Validate that movement between accounts is allowed for active ESN
  IF ( i_transfer_esn_flag = 'N' and
       get_esn_info_rec.x_part_inst_status = '52' and
       get_esn_info_rec.web_user_objid is not null )
  THEN
    o_err_code := 190;
    o_err_msg := 'MOVEMENT BETWEEN ACCOUNTS IS NOT ALLOWED FOR ACTIVE ESN';
    RETURN;
  END IF;

  --   Validate that target organization/brand is the same as current ESN brand
  IF (get_webuser_info_rec.web_user2bus_org <> get_esn_info_rec.web_user2bus_org AND
      get_esn_info_rec.web_user2bus_org IS NOT NULL) OR
     (get_webuser_info_rec.web_user2bus_org <> get_esn_info_rec.part_num2bus_org AND
      get_esn_info_rec.part_num2bus_org IS NOT NULL)
  THEN
     IF get_esn_info_rec.org_id = 'GENERIC' THEN
       -- Call procedure to link the brand to the ESN
       phone_pkg.brand_esn ( ip_esn    => get_esn_info_rec.part_serial_no,
                             ip_org_id => get_webuser_info_rec.org_id,
                             ip_user   => i_user_login_name,
                             op_result => c_result,
                             op_msg    => o_err_msg );

       IF c_result <> '0' THEN
         o_err_code := 200;
         o_err_msg := 'ERROR IN PHONE_PKG.BRAND_ESN: RESULT: ' || c_result || ' : MSG: ' || o_err_msg;
         RETURN;
       END IF;
     ELSE
       o_err_code := 210;
       o_err_msg := 'TARGET ORGANIZATION/BRAND IS NOT THE SAME AS THE ESN';
       RETURN;
     END IF;
  END IF;

  -- Remove Link from existing account/contact
  DELETE table_x_contact_part_inst
  WHERE  x_contact_part_inst2part_inst = get_esn_info_rec.objid;

  --  Check if the esn is the first in the account to set as primary
  SELECT DECODE(COUNT(1),0,1,0) X_IS_DEFAULT -- Setting the primary ESN
  INTO   get_esn_info_rec.x_is_default
  FROM   table_x_contact_part_inst
  WHERE  x_contact_part_inst2contact = get_webuser_info_rec.web_user2contact
  AND    x_is_default = 1;

  -- If esn is primary then link to web_user2contact else copy contact info
  IF get_esn_info_rec.x_is_default = 1 THEN
    -- Reuse Account Contact if it is the first ESN in the account
    n_new_contact_id := get_webuser_info_rec.web_user2contact;
    UPDATE table_contact
    SET    dev = NVL(dev,0) + 1
    WHERE  objid = get_webuser_info_rec.web_user2contact;
  ELSE
    -- Copy contact information from table_web_user.web_user2contact
    copy_contact_info ( i_old_contact_id  => get_webuser_info_rec.web_user2contact,
                        i_sourcesystem    => i_sourcesystem,
                        o_new_contact_id  => n_new_contact_id,
                        o_err_code        => o_err_code,
                        o_err_msg         => o_err_msg );
    --
    IF o_err_code <> '0' THEN
      RETURN;
    END IF;
  END IF;

  -- Link ESN to new contact copied
  UPDATE table_part_inst
  SET    x_part_inst2contact = n_new_contact_id
  WHERE  objid = get_esn_info_rec.objid;

  -- Link ESN to Target account/contact
  BEGIN
    INSERT
    INTO   table_x_contact_part_inst
           ( objid,
             x_contact_part_inst2contact,
             x_contact_part_inst2part_inst,
             x_esn_nick_name,
             x_is_default
           )
    VALUES
    ( seq('x_contact_part_inst'),
      get_webuser_info_rec.web_user2contact,
      get_esn_info_rec.objid,
      i_esn_nick_name,
      get_esn_info_rec.x_is_default )
    RETURNING objid
    INTO      c.numeric_value;
    --
    DBMS_OUTPUT.PUT_LINE(NVL(SQL%ROWCOUNT,0) || ' row created in TABLE_X_CONTACT_PART_INST (' || c.numeric_value || ')');
    --
   EXCEPTION
     WHEN others THEN
       o_err_code := 220;
       o_err_msg := 'ERROR INSERTING CONTACT/PART INST: ' || SQLERRM;
  END;

   -- CR53621 -- Begin here
  IF c.min IS NOT NULL AND
     c.min NOT LIKE 'T%'
  THEN
   BEGIN
      UPDATE sa.table_contact
      SET    dev = dev
      WHERE  objid = get_webuser_info_rec.web_user2contact;
    EXCEPTION
    WHEN OTHERS
    THEN
       NULL;
    END;
  END IF;
	-- CR53621  - End

  --CR48260_MultiLine Discount on SM - call sp_notify_affpart_discount_BRM
  enqueue_transactions_pkg.sp_notify_affpart_discount_BRM   (i_web_user_objid    => get_webuser_info_rec.objid              ,
                                                             i_login_name        => get_webuser_info_rec.login_name         ,
                                                             i_bus_org_id        => get_webuser_info_rec.org_id             ,
                                                             i_web_user2contact  => get_webuser_info_rec.web_user2contact   ,
                                                             o_response          => o_err_msg)	;
  DBMS_OUTPUT.PUT_LINE ('Enqueue_Transactions_Pkg.Sp_Notify_Affpart_Discount_Brm | o_response :'|| o_err_msg);
 ----CR48260 Ends
  o_err_code := 0;
  o_err_msg := 'SUCCESS';

 EXCEPTION
  WHEN OTHERS THEN
    o_err_code := 999;
    o_err_msg  := SUBSTR('ERROR IN ADD_ESN_TO_ACCOUNT : '||SQLERRM, 1, 4000);
    RETURN;
END add_esn_to_account;

-- Overloaded procedure to use reference esn (instead of web user objid)
PROCEDURE add_esn_to_account ( i_reference_esn      IN  VARCHAR2,
                               i_esn_nick_name      IN  sa.table_x_contact_part_inst.x_esn_nick_name%type,
                               i_esn                IN  sa.table_part_inst.part_serial_no%type,
                               i_transfer_esn_flag  IN  VARCHAR2 DEFAULT 'N',  -- Y: Allow movement of an active esn between accounts, N: Not allow movement of an active esn
                               i_user_login_name    IN  sa.table_user.s_login_name%TYPE,
                               i_sourcesystem       IN  VARCHAR2,
                               o_err_code           OUT NUMBER,
                               o_err_msg            OUT VARCHAR2 ) IS

  n_new_contact_id  NUMBER;
  n_cnt_records     NUMBER := 1;
  cst               customer_type;
  c                 customer_type;
  cstf              customer_type;
  cf                customer_type;
  c_result          VARCHAR2(100);
  --CR54704 LIFELINE changes start
  c_is_lifeline_enrolled  VARCHAR2(1);
  n_enrolled_esn_count    NUMBER;
  --CR54704 LIFELINE changes end

  CURSOR get_webuser_info ( p_web_user_objid IN NUMBER ) IS
    SELECT web.web_user2bus_org,
           web.web_user2contact,
           bo.org_id           ,
           web.login_name      ,
           web.objid
    FROM   table_web_user web,
           table_bus_org  bo
    WHERE  web.objid = p_web_user_objid
    AND    bo.objid = web.web_user2bus_org;

  get_webuser_info_rec  get_webuser_info%ROWTYPE;

  CURSOR get_contact ( p_contact_objid in table_contact.objid%TYPE ) IS
    SELECT *
    FROM   table_contact
    WHERE  objid = p_contact_objid;

  get_contact_rec   get_contact%ROWTYPE;

  CURSOR get_esn_info IS
    SELECT pi_esn.objid,
           pi_esn.x_part_inst2contact,
           web.objid web_user_objid,
           web.web_user2bus_org,
           pn.part_num2bus_org,
           conpi.x_is_default,
           bo.org_id,
           pi_esn.x_part_inst_status,
           pi_esn.part_serial_no,
           pn.x_technology,
           pn.part_number,
           pc.name class_name
    FROM   table_part_inst pi_esn,
           table_x_contact_part_inst conpi,
           table_web_user web,
           table_mod_level ml,
           table_part_num pn,
           table_bus_org bo,
           table_part_class pc
    WHERE  pi_esn.part_serial_no = i_esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    conpi.x_contact_part_inst2part_inst (+) = pi_esn.objid
    AND    web.web_user2contact (+) = conpi.x_contact_part_inst2contact
    AND    ml.objid = pi_esn.n_part_inst2part_mod
    AND    pn.objid = ml.part_info2part_num
    AND    bo.objid = pn.part_num2bus_org
    AND    pc.objid = pn.part_num2part_class;

  get_esn_info_rec  get_esn_info%ROWTYPE;


  CURSOR get_enroll_info IS
    SELECT pe.*,
           pp.x_prog_class
    FROM   sa.x_program_enrolled pe,
           sa.x_program_parameters pp,
           sa.table_part_inst pi
    WHERE  pe.x_esn = i_esn
    AND    pe.x_enrollment_status NOT IN ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
    AND    pp.objid = pe.pgm_enroll2pgm_parameter
    and    pp.x_prog_class <> 'WARRANTY'
    AND    pi.part_serial_no = pe.x_esn
    AND    pi.x_domain = 'PHONES'
    AND    pi.x_part_inst_status = '52';

  get_enroll_info_rec  get_enroll_info%ROWTYPE;

BEGIN
   IF i_sourcesystem IS NULL THEN
     o_err_code := 100;
     o_err_msg := 'SOURCESYSTEM CANNOT BE EMPTY';
   END IF;

   IF i_esn IS NULL THEN
     o_err_code := 110;
     o_err_msg := 'ESN CANNOT BE EMPTY';
   END IF;

  -- get the attributes for the new esn
  cst := customer_type ( i_esn => i_esn );
  c   := cst.retrieve;


  IF c.response NOT LIKE '%SUCCESS%' THEN
    o_err_code := 100;
    o_err_msg := 'NEW ESN NOT FOUND';
  END IF;

  -- get the attributes for the esn used as a reference
  cstf := customer_type ( i_esn => i_reference_esn );
  cf  := cstf.retrieve;

  IF cf.response NOT LIKE '%SUCCESS%' THEN
    o_err_code := 200;
    o_err_msg := 'REFERENCE ESN NOT FOUND';
  END IF;

  IF cf.web_user_objid IS NULL THEN
    o_err_code := 210;
    o_err_msg := 'WEB ACCOUNT NOT FOUND FOR REFERENCE ESN';
  END IF;

  -- get ESN information
  open get_esn_info;
  fetch get_esn_info into get_esn_info_rec;
  if get_esn_info%notfound then
     o_err_code := 100;
     o_err_msg := 'ESN NOT FOUND';
     close get_esn_info;
     return;
  end if;
  close get_esn_info;

  -- Check if ESN is linked to the account
  IF nvl(get_esn_info_rec.web_user_objid,-1) = cf.web_user_objid THEN
    o_err_code := 110;
    o_err_msg := 'ESN ALREADY LINKED TO THE ACCOUNT';
    RETURN;
  END IF;
  --CR54704 LIFELINE changes start
  --Check if ESN is enrolled in LIFELINE
  BEGIN
    SELECT 'Y'
    INTO   c_is_lifeline_enrolled
    FROM   ll_subscribers
    WHERE  current_esn = i_esn
    AND    enrollment_status = 'ENROLLED'
    AND    TRUNC(NVL(projected_deenrollment, SYSDATE)) >= TRUNC(SYSDATE);
  EXCEPTION
    WHEN OTHERS THEN
      c_is_lifeline_enrolled := 'N';
  END;

  IF NVL(c_is_lifeline_enrolled, 'N') = 'Y'
  THEN
    --Check if target account already has a LIFELINE enrolled ESN
    BEGIN
      SELECT count(pi_esn.part_serial_no)
      INTO   n_enrolled_esn_count
      FROM   table_part_inst pi_esn,
             table_x_contact_part_inst cpi,
             table_web_user wu,
             ll_subscribers llsub
      WHERE  wu.objid = cf.web_user_objid
      AND    cpi.x_contact_part_inst2contact = wu.web_user2contact
      AND    cpi.x_contact_part_inst2part_inst = pi_esn.objid
      AND    llsub.current_esn = pi_esn.part_serial_no
      AND    llsub.enrollment_status = 'ENROLLED'
      AND    TRUNC(NVL(llsub.projected_deenrollment, SYSDATE+1)) >= TRUNC(SYSDATE);
    EXCEPTION
      WHEN OTHERS THEN
        n_enrolled_esn_count := 0;
    END;

    IF n_enrolled_esn_count > 0
    THEN
      o_err_code := 230;
      o_err_msg := 'TARGET ACCOUNT ALREADY HAS A LIFELINE ENROLLED ESN';
      RETURN;
    END IF;
  END IF;
  --CR54704 LIFELINE changes end

  -- Check if the ESN is enrolled in autorefill program
  OPEN get_enroll_info;
  FETCH get_enroll_info INTO get_enroll_info_rec;
  IF get_enroll_info%FOUND THEN
    -- Assume the ESN belongs to an account already
    IF get_enroll_info_rec.pgm_enroll2web_user IS NULL THEN
      -- Check if ESN belongs to any account
      SELECT COUNT(1)
      INTO   n_cnt_records
      FROM   sa.table_part_inst pi,
             table_x_contact_part_inst conpi,
             table_web_user web
      WHERE  pi.part_serial_no = get_enroll_info_rec.x_esn
      AND    pi.x_domain = 'PHONES'
      AND    conpi.x_contact_part_inst2part_inst = pi.objid
      AND    web.web_user2contact = conpi.x_contact_part_inst2contact;
    END IF;
    IF n_cnt_records > 0 THEN
      o_err_code := 120;
      o_err_msg := 'ESN IS ENROLLED IN AUTOREFILL PROGRAM';
      CLOSE get_enroll_info;
      RETURN;
    END IF;
  END IF;
  CLOSE get_enroll_info;

  -- Get target account information
  open get_webuser_info ( cf.web_user_objid );
  fetch get_webuser_info into get_webuser_info_rec;
  if get_webuser_info%notfound
  then
     o_err_code := 130;
     o_err_msg := 'WEB USER ACCOUNT NOT FOUND';
     close get_webuser_info;
     return;
  end if;
  close get_webuser_info;

  if get_webuser_info_rec.web_user2contact IS NULL then
     o_err_code := 140;
     o_err_msg := 'TARGET ACCOUNT CONTACT NOT FOUND';
     return;
  end if;

  -- If ESN is Home Alert then check valid phone number and email
  IF c.model_type IN ('HOME ALERT','CAR CONNECT') THEN
      open get_contact(get_webuser_info_rec.web_user2contact);
      fetch get_contact into get_contact_rec;
      if get_contact%notfound then
        o_err_code := 150;
        o_err_msg := 'ACCOUNT CONTACT NOT FOUND';
        close get_contact;
        return;
      else
        -- Email NOT valid
        IF NOT (regexp_like(get_contact_rec.e_mail,'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,4}') AND
             length(get_contact_rec.e_mail) > 6 AND
             get_contact_rec.e_mail not like get_contact_rec.x_cust_id||'@'||'%')
        OR
        -- Phone not valid
        NOT (regexp_like(get_contact_rec.phone,'[0-9]{10,10}') AND
             length(get_contact_rec.phone) > 9 and
             get_contact_rec.phone != get_contact_rec.x_cust_id)
        THEN
          o_err_code := 160;
          o_err_msg := 'ACCOUNT SHOULD HAVE A VALID PHONE NUMBER AND EMAIL';
          CLOSE get_contact;
          RETURN;
        end if;
      end if;
      if get_contact%isopen then
          close get_contact;
      end if;
  end if;

  -- Validate that movement between accounts is allowed for active ESN
  if ( i_transfer_esn_flag = 'N' and
       get_esn_info_rec.x_part_inst_status = '52' and
       get_esn_info_rec.web_user_objid is not null )
  then
     o_err_code := 170;
     o_err_msg := 'MOVEMENT BETWEEN ACCOUNTS IS NOT ALLOWED FOR ACTIVE ESN';
     RETURN;
  end if;

  --   Validate that target organization/brand is the same as current ESN brand
  IF (get_webuser_info_rec.web_user2bus_org <> get_esn_info_rec.web_user2bus_org AND
      get_esn_info_rec.web_user2bus_org IS NOT NULL) OR
     (get_webuser_info_rec.web_user2bus_org <> get_esn_info_rec.part_num2bus_org AND
      get_esn_info_rec.part_num2bus_org IS NOT NULL)
  THEN
     IF get_esn_info_rec.org_id = 'GENERIC' THEN
       -- Call procedure to link the brand to the ESN
       phone_pkg.brand_esn ( ip_esn    => get_esn_info_rec.part_serial_no,
                             ip_org_id => get_webuser_info_rec.org_id,
                             ip_user   => i_user_login_name,
                             op_result => c_result,
                             op_msg    => o_err_msg );

       IF c_result <> '0' THEN
         o_err_code := 180;
         o_err_msg := 'ERROR IN PHONE_PKG.BRAND_ESN: RESULT: ' || c_result || ' : MSG: ' || o_err_msg;
         RETURN;
       END IF;
     ELSE
         o_err_code := 190;
         o_err_msg := 'TARGET ORGANIZATION/BRAND IS NOT THE SAME AS THE ESN';
         RETURN;
     END IF;
  END IF;

  -- Remove Link from existing account/contact
  DELETE table_x_contact_part_inst
  WHERE  x_contact_part_inst2part_inst = get_esn_info_rec.objid;

  --  Check if the esn is the first in the account to set as primary
  SELECT DECODE(COUNT(1),0,1,0) X_IS_DEFAULT -- Setting the primary ESN
  INTO   get_esn_info_rec.x_is_default
  FROM   table_x_contact_part_inst
  WHERE  x_contact_part_inst2contact = get_webuser_info_rec.web_user2contact
  AND    x_is_default = 1;

  -- If esn is primary then link to web_user2contact else copy contact info
  IF get_esn_info_rec.x_is_default = 1 THEN
    -- Reuse Account Contact if it is the first ESN in the account
    n_new_contact_id := get_webuser_info_rec.web_user2contact;
    UPDATE table_contact
    SET    dev = NVL(dev,0) + 1
    WHERE  objid = get_webuser_info_rec.web_user2contact;
  ELSE
    -- Copy contact information from table_web_user.web_user2contact
    copy_contact_info ( i_old_contact_id  => get_webuser_info_rec.web_user2contact,
                        i_sourcesystem    => i_sourcesystem,
                        o_new_contact_id  => n_new_contact_id,
                        o_err_code        => o_err_code,
                        o_err_msg         => o_err_msg );
    --
    IF o_err_code <> '0' THEN
      RETURN;
    END IF;
  END IF;

  -- Link ESN to new contact copied
  UPDATE table_part_inst
  SET    x_part_inst2contact = n_new_contact_id
  WHERE  objid = get_esn_info_rec.objid;

  -- Link ESN to Target account/contact
  INSERT
  INTO   table_x_contact_part_inst
         ( objid,
           x_contact_part_inst2contact,
           x_contact_part_inst2part_inst,
           x_esn_nick_name,
           x_is_default
         )
  VALUES
  ( seq('x_contact_part_inst'),
    get_webuser_info_rec.web_user2contact,
    get_esn_info_rec.objid,
    i_esn_nick_name,
    get_esn_info_rec.x_is_default );

  -- CR53621 -- Begin
  IF c.min IS NOT NULL AND
     c.min NOT LIKE 'T%'
  THEN
    BEGIN
     UPDATE sa.table_contact
     SET    dev = dev
     WHERE  objid = get_webuser_info_rec.web_user2contact;
    EXCEPTION
    WHEN OTHERS
    THEN
      NULL;
    END;
  END IF;
  -- CR53621  - End

  --CR48260_MultiLine Discount on SM - call sp_notify_affpart_discount_BRM
  enqueue_transactions_pkg.sp_notify_affpart_discount_BRM   (i_web_user_objid    => get_webuser_info_rec.objid              ,
                                                             i_login_name        => get_webuser_info_rec.login_name         ,
                                                             i_bus_org_id        => get_webuser_info_rec.org_id             ,
                                                             i_web_user2contact  => get_webuser_info_rec.web_user2contact   ,
                                                             o_response          => o_err_msg)	;
  DBMS_OUTPUT.PUT_LINE ('Enqueue_Transactions_Pkg.Sp_Notify_Affpart_Discount_Brm | o_response :'|| o_err_msg);
 ----CR48260 Ends

  o_err_code := 0;
  o_err_msg := 'SUCCESS';

 EXCEPTION
  WHEN OTHERS THEN
    o_err_code := 999;
    o_err_msg  := SUBSTR('ERROR IN ADD_ESN_TO_ACCOUNT : '||SQLERRM, 1, 4000);
    RETURN;
END add_esn_to_account;

--CR43088 WARP 2.0
--New procedure added
PROCEDURE  remove_esn_from_account (  ip_web_user_objid  IN table_web_user.objid%TYPE,
                                      ip_esn             IN table_part_inst.part_serial_no%TYPE,
                                      op_err_code        OUT varchar2,
                                      op_err_msg         OUT varchar2,
                                      --CR48846
                                      i_dummy_account_flag  IN VARCHAR2 DEFAULT 'N'
                                   )
IS

   CURSOR get_esn_info
   IS
   SELECT pi.*,bo.org_id
   FROM table_part_inst pi,
    table_mod_level ml,
    table_part_num pn,
    table_bus_org bo
  WHERE 1                     = 1
  AND pi.part_serial_no       = ip_esn
  AND pi.x_domain             = 'PHONES'
  AND pi.n_part_inst2part_mod = ml.objid
  AND ml.part_info2part_num   = pn.objid
  AND pn.domain               = 'PHONES'
  AND pn.part_num2bus_org     = bo.objid;

   get_esn_info_rec get_esn_info%ROWTYPE;
   --CR48846
   c_dummy_account_check VARCHAR2(30);
BEGIN
    OPEN get_esn_info;
    FETCH get_esn_info INTO get_esn_info_rec;

    IF get_esn_info%notfound
    THEN
       op_err_code := '-101';
       op_err_msg := 'ESN not found';
       CLOSE get_esn_info;
       RETURN;  --Procedure stops here
    END IF;
    CLOSE get_esn_info;

    --CR48846
    IF NVL(i_dummy_account_flag,'N') = 'Y'
    THEN
    -- CHECK IF THE ACCOUNT IS DUMMY, IF NOT THEN RAISE ERROR
      c_dummy_account_check := get_account_status(i_esn => ip_esn);
      IF c_dummy_account_check != 'DUMMY_ACCOUNT'
      THEN
        op_err_code := '-102';
        op_err_msg := 'NOT A DUMMY ACCOUNT';
        RETURN;
      END IF;
    END IF;

    IF get_esn_info_rec.x_part_inst2contact IS NOT NULL
    THEN

        UPDATE Table_Part_Inst
           SET x_part_inst2contact = null
         WHERE objid = get_esn_info_rec.objid;
    END IF;
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

   -- COMMIT;
    op_err_code := 0;
    op_err_msg := 'ESN removed from account, Successfully';
EXCEPTION
  WHEN OTHERS THEN
   -- ROLLBACK;
     op_err_code := SQLCODE;
     op_err_msg  := substr(SQLERRM,1,500);
     RETURN;
END Remove_Esn_From_Account;
--CR43088 WARP 2.0
--New procedure added

-- CR47564
PROCEDURE validate_login_pin ( i_login_name IN VARCHAR2,
 i_esn IN VARCHAR2,
 i_min IN VARCHAR2,
 i_security_pin IN VARCHAR2,
 i_bus_org_id IN VARCHAR2,
 o_err_code OUT NUMBER ,
 o_err_msg OUT VARCHAR2 )
IS
 -- instantiate initial values
 rc sa.customer_type := customer_type();
 wu sa.customer_type := customer_type();
 -- type to hold retrieved attributes
 cst sa.customer_type :=customer_type();
BEGIN
 --
 IF i_login_name IS NULL AND i_esn IS NULL AND i_min IS NULL
 THEN
 o_err_code := 600;
 o_err_msg := 'LOGIN NAME / ESN / MIN NOT PASSED';
 RETURN;
 END IF;
 --
 IF i_security_pin IS NULL THEN
 o_err_code := 610;
 o_err_msg := 'SECURITY PIN NOT PASSED';
 RETURN;
 END IF;
 --
 IF i_login_name IS NULL
 THEN
 IF i_min IS NOT NULL
 THEN
 --
 wu.esn := rc.get_esn ( i_min => i_min);
 ELSE
 wu.esn := i_esn;
 END IF;
 --
 wu := wu.get_web_user_attributes;
 --
 ELSE
 wu.web_login_name := i_login_name;
 END IF;
 -- call the retrieve function by min
 cst := rc.retrieve_login ( i_login_name => wu.web_login_name ,
 i_bus_org_id => i_bus_org_id );
 --
 IF cst.web_user_objid IS NULL THEN
 o_err_code := 630;
 o_err_msg := 'LOGIN NAME NOT FOUND';
 RETURN;
 END IF;
 --
 IF cst.security_pin IS NULL THEN
 o_err_code := 640;
 o_err_msg := 'SECURITY PIN NOT FOUND IN ACCOUNT';
 RETURN;
 END IF;
 --
 IF cst.security_pin != i_security_pin THEN
 o_err_code := 650;
 o_err_msg := 'SECURITY PIN NOT VALID FOR THE ACCOUNT ASSOCIATED WITH THE MIN';
 RETURN;
 END IF;
 --
 o_err_code := 0;
 o_err_msg := 'SUCCESS';
 --
 EXCEPTION
 WHEN others THEN
 o_err_code := 999;
 o_err_msg := 'ERROR VALIDATING ESN AND SECURITY PIN: ' || SQLERRM;
END validate_login_pin;
--CR47564 - WFM Changes
FUNCTION get_account_status  (i_esn  in VARCHAR2) RETURN VARCHAR2
IS
  --
  CURSOR get_esn_info_cur(p_Esn IN table_part_inst.part_serial_no%TYPE)
  IS
   SELECT esn.part_serial_no esn ,
          cpi.X_Esn_Nick_Name NICKNAME,
          ESN.X_PART_INST_STATUS STATUS,
          tpn.x_technology technology ,
          TBO.ORG_ID BRAND ,
          WU.LOGIN_NAME EMAIL,
          WU.OBJID ACCOUNTID,
          ESN.X_ICCID SIM,
          line.part_serial_no MIN,
          CASE swa.objid
            WHEN NULL
            THEN 0
            WHEN swa.objid
            THEN 1
          END b2b,
          tpn.part_number part_num,
          pc.name part_class,
          cpi.x_is_default,
          decode(ESN.X_PORT_IN,1,'Y','N') port_in_progress,
          esn.objid esn_partinst_objid
        FROM TABLE_PART_INST ESN,
          table_part_inst line,
          TABLE_MOD_LEVEL TML,
          TABLE_PART_NUM TPN,
          TABLE_PART_Class pc,
          TABLE_BUS_ORG TBO,
          TABLE_X_CONTACT_PART_INST CPI,
          table_web_user wu,
          x_site_web_accounts swa
        WHERE 1                             = 1
        AND ESN.N_PART_INST2PART_MOD        = TML.OBJID
        AND TML.PART_INFO2PART_NUM          = TPN.OBJID
        AND TPN.PART_NUM2BUS_ORG            = TBO.OBJID
        AND tpn.part_num2part_class         = pc.objid
        AND ESN.OBJID                       = CPI.X_CONTACT_PART_INST2PART_INST(+)
        AND CPI.X_CONTACT_PART_INST2CONTACT = wu.WEB_USER2CONTACT(+)
        AND Wu.OBJID                        = SWA.SITE_WEB_ACCT2WEB_USER(+)
        AND ESN.PART_SERIAL_NO              = p_esn
        AND ESN.X_DOMAIN                    = 'PHONES'
        AND LINE.PART_TO_ESN2PART_INST(+)   = ESN.OBJID
        AND line.x_domain(+)                = 'LINES';
  get_esn_info_rec  get_esn_info_cur%rowtype;
  --
  l_account_status   VARCHAR2(20);
  --
BEGIN
  --
  OPEN get_esn_info_cur(i_esn);
  FETCH get_esn_info_cur into get_esn_info_rec;
    DBMS_OUTPUT.PUT_LINE ('email'||get_esn_info_rec.EMAIL);
    CLOSE get_esn_info_cur;  -- CR47564 changes
  IF get_esn_info_rec.EMAIL IS NULL
  THEN
    l_account_status := 'NO_ACCOUNT';
  ELSE
    l_account_status := CASE
                        WHEN ((UPPER(get_esn_info_rec.email) LIKE '%@'||UPPER(get_esn_info_rec.brand)||'.COM') AND
                              UPPER(get_esn_info_rec.brand) <>  'WFM')
                          OR (UPPER(get_esn_info_rec.email) LIKE '%@TF'||UPPER(get_esn_info_rec.brand)||'.COM') --WFM is @TFWFM.COM
                          OR (get_esn_info_rec.brand = 'NET10' AND UPPER(get_esn_info_rec.email) LIKE '%@NET10WIRELESS.COM') --CR48846
                          OR (INSTR (get_esn_info_rec.brand,'_') > 0 AND  UPPER(get_esn_info_rec.email) LIKE '%@'||UPPER(REPLACE(get_esn_info_rec.brand,'_',''))||'.COM') --CR48846
                        THEN 'DUMMY_ACCOUNT'
                        ELSE 'VALID_ACCOUNT'
                        END;
  END IF;
  --
  RETURN l_account_status;
  --
END get_account_status;
--
PROCEDURE Remove_account (i_login_name IN VARCHAR2,
 i_brand IN VARCHAR2,
 i_commit_flag IN VARCHAR2 DEFAULT 'Y',
                         i_web_user_objid IN VARCHAR2,
 o_err_code OUT NUMBER ,
 o_err_msg OUT VARCHAR2)
IS
 v_account_type VARCHAR2(25) ;
 l_override_flag VARCHAR2(1) ;
 wu web_user_type := web_user_type();
 c customer_type := customer_type();
 c_multiline_discount_flag varchar2(1);

 CURSOR c_web_user (p_login_name IN VARCHAR2,p_brand IN VARCHAR2) IS
 SELECT wb.objid web_user_objid ,
 wb.web_user2bus_org bus_org_objid
 FROM table_web_user wb,
 table_bus_org tb
 WHERE wb.web_user2bus_org=tb.objid
 AND wb.s_login_name = upper(p_login_name)
 AND tb.s_org_id = upper(p_brand);
web_user_rec c_web_user%ROWTYPE;
BEGIN
 -- CR48260  setting override flag to Y only for brands with multiline discount
 c_multiline_discount_flag:=c.get_multiline_discount_flag ( i_bus_org_id => i_brand );

 IF c_multiline_discount_flag = 'Y' THEN
 l_override_flag := 'Y';
 ELSE
 l_override_flag := 'N';
 END IF;
 IF i_web_user_objid IS NOT NULL THEN
 wu := web_user_type ( i_web_user_objid => i_web_user_objid);
 ELSE
 wu.login_name := i_login_name;
 END IF;
 OPEN c_web_user (wu.login_name,i_brand) ;
 FETCH c_web_user INTO web_user_rec;
 IF c_web_user%NOTFOUND THEN
 o_err_code := '101';
 o_err_msg := 'Web user not found' ;
 CLOSE c_web_user;
 RETURN;
 END IF;
 CLOSE c_web_user;
 v_account_type := CASE WHEN ((UPPER(wu.login_name) LIKE '%@'||UPPER(i_brand)||'.COM') AND
 UPPER(i_brand) <> 'WFM')
 OR (UPPER(wu.login_name) LIKE '%@TF'||UPPER(i_brand)||'.COM') --WFM is @TFWFM.COM
 THEN 'DUMMY_ACCOUNT'
 ELSE 'VALID_ACCOUNT'
 END;
 IF v_account_type ='DUMMY_ACCOUNT' THEN
 wu := wu.Del ( i_s_login_name =>UPPER(wu.login_name) ,
 i_web_user2bus_org => web_user_rec.bus_org_objid,
                 i_override_flag => l_override_flag
                 );
 IF wu.response NOT LIKE '%SUCCESS%' THEN
 o_err_code := '99';
 o_err_msg := 'Web user delete failed:'||wu.response ;
 RETURN;
 END IF;
 ELSE
 o_err_code := '100';
 o_err_msg := 'Not a Dummy Account';
 RETURN;
 END IF;
 IF i_commit_flag = 'Y' THEN
 commit;
 END IF ;
 o_err_code:=0;
 o_err_msg:='SUCCESS';
EXCEPTION WHEN OTHERS THEN
 o_err_code := SQLCODE;
 o_err_msg := substr(SQLERRM,1,500);
END remove_account;
-- Overloaded procedure to use for WFM Brand
PROCEDURE add_esn_to_account ( i_web_user_objid IN sa.table_web_user.objid%type,
 i_esn IN sa.table_part_inst.part_serial_no%type,
 i_brand IN VARCHAR2,
 i_pin IN VARCHAR2,
 i_esn_nick_name IN sa.table_x_contact_part_inst.x_esn_nick_name%type,
 i_language IN VARCHAR2,
 i_sourcesystem IN VARCHAR2,
 o_err_code OUT NUMBER,
 o_err_msg OUT VARCHAR2 )
 IS

 c_contact_o_err_code VARCHAR2 (100);
 c_contact_o_err_msg VARCHAR2 (500);
 n_contact_o_objid NUMBER;
  --CR54704 LIFELINE changes start
  c_is_lifeline_enrolled  VARCHAR2(1);
  n_enrolled_esn_count    NUMBER;
  --CR54704 LIFELINE changes end

 c customer_type := customer_type();

 CURSOR get_webuser_info ( p_web_user_objid IN NUMBER ) IS
 SELECT    web.web_user2bus_org,
           web.web_user2contact,
           bo.org_id           ,
           web.login_name      ,
           web.objid
 FROM table_web_user web,
 table_bus_org bo
 WHERE web.objid = p_web_user_objid
 AND bo.objid = web.web_user2bus_org;
 get_webuser_info_rec get_webuser_info%ROWTYPE;
 CURSOR get_contact ( p_contact_objid in table_contact.objid%TYPE ) IS
 SELECT *
 FROM table_contact
 WHERE objid = p_contact_objid;
 get_contact_rec get_contact%ROWTYPE;
 CURSOR get_esn_info IS
 SELECT pi_esn.objid,
 pi_esn.x_part_inst2contact,
 web.objid web_user_objid,
 web.web_user2bus_org,
 pn.part_num2bus_org,
 conpi.x_is_default,
 bo.org_id,
 pi_esn.x_part_inst_status,
 pi_esn.part_serial_no,
 pn.x_technology,
 pn.part_number,
 pc.name class_name
 FROM table_part_inst pi_esn,
 table_x_contact_part_inst conpi,
 table_web_user web,
 table_mod_level ml,
 table_part_num pn,
 table_bus_org bo,
 table_part_class pc
 WHERE pi_esn.part_serial_no = i_esn
 AND pi_esn.x_domain = 'PHONES'
 AND conpi.x_contact_part_inst2part_inst (+) = pi_esn.objid
 AND web.web_user2contact (+) = conpi.x_contact_part_inst2contact
 AND ml.objid = pi_esn.n_part_inst2part_mod
 AND pn.objid = ml.part_info2part_num
 AND bo.objid = pn.part_num2bus_org
 AND pc.objid = pn.part_num2part_class;
 get_esn_info_rec get_esn_info%ROWTYPE;
BEGIN
 IF i_sourcesystem IS NULL THEN
 o_err_code := 100;
 o_err_msg := 'SOURCESYSTEM CANNOT BE EMPTY';
 END IF;
 IF i_esn IS NULL THEN
 o_err_code := 110;
 o_err_msg := 'ESN CANNOT BE EMPTY';
 END IF;
 -- get ESN information
 open get_esn_info;
 fetch get_esn_info into get_esn_info_rec;
 if get_esn_info%notfound then
 o_err_code := 101;
 o_err_msg := 'ESN NOT FOUND';
 close get_esn_info;
 return;
 end if;
 close get_esn_info;
 -- Check if ESN is linked to the account
 IF get_esn_info_rec.web_user_objid IS NOT NULL THEN
 o_err_code := 112;
 o_err_msg := 'ESN ALREADY LINKED TO AN ACCOUNT';
 RETURN;
 END IF;
 -- Get target account information
 open get_webuser_info ( i_web_user_objid );
 fetch get_webuser_info into get_webuser_info_rec;
 if get_webuser_info%notfound
 then
 o_err_code := 130;
 o_err_msg := 'WEB USER ACCOUNT NOT FOUND';
 close get_webuser_info;
 return;
 end if;
 close get_webuser_info;
 if get_webuser_info_rec.web_user2contact IS NULL then
 o_err_code := 140;
 o_err_msg := 'TARGET WEB ACCOUNT CONTACT NOT FOUND';
 return;
 end if;
 open get_contact ( p_contact_objid => get_webuser_info_rec.web_user2contact );
 fetch get_contact into get_contact_rec ;
 if get_contact%notfound then
 o_err_code := 140;
 o_err_msg := 'TARGET WEB ACCOUNT CONTACT NOT FOUND';
     close get_contact;
 return;
 end if;
 close get_contact;
 -- Validate that target organization/brand is the same as current ESN brand
 IF (get_webuser_info_rec.web_user2bus_org <> get_esn_info_rec.web_user2bus_org AND
 get_esn_info_rec.web_user2bus_org IS NOT NULL) OR
 (get_webuser_info_rec.web_user2bus_org <> get_esn_info_rec.part_num2bus_org AND
 get_esn_info_rec.part_num2bus_org IS NOT NULL)
 THEN
 --IF get_esn_info_rec.org_id = 'GENERIC' THEN
 -- Call procedure to link the brand to the ESN
 --phone_pkg.brand_esn ( ip_esn => get_esn_info_rec.part_serial_no,
 -- ip_org_id => get_webuser_info_rec.org_id,
 -- ip_user => i_user_login_name,
 -- op_result => c_result,
 -- op_msg => o_err_msg );
 --IF c_result <> '0' THEN
 -- o_err_code := 180;
 -- o_err_msg := 'ERROR IN PHONE_PKG.BRAND_ESN: RESULT: ' || c_result || ' : MSG: ' || o_err_msg;
 -- RETURN;
 --END IF;
 --ELSE
 o_err_code := 190;
 o_err_msg := 'TARGET ORGANIZATION/BRAND IS NOT THE SAME AS THE ESN';
 RETURN;
 --END IF;
 END IF;
   --CR54704 LIFELINE changes start
  --Check if ESN is enrolled in LIFELINE
  BEGIN
    SELECT 'Y'
    INTO   c_is_lifeline_enrolled
    FROM   ll_subscribers
    WHERE  current_esn = i_esn
    AND    enrollment_status = 'ENROLLED'
    AND    TRUNC(NVL(projected_deenrollment, SYSDATE)) >= TRUNC(SYSDATE);
  EXCEPTION
    WHEN OTHERS THEN
      c_is_lifeline_enrolled := 'N';
  END;

  IF NVL(c_is_lifeline_enrolled, 'N') = 'Y'
  THEN
    --Check if target account already has a LIFELINE enrolled ESN
    BEGIN
      SELECT count(pi_esn.part_serial_no)
      INTO   n_enrolled_esn_count
      FROM   table_part_inst pi_esn,
             table_x_contact_part_inst cpi,
             table_web_user wu,
             ll_subscribers llsub
      WHERE  wu.objid = i_web_user_objid
      AND    cpi.x_contact_part_inst2contact = wu.web_user2contact
      AND    cpi.x_contact_part_inst2part_inst = pi_esn.objid
      AND    llsub.current_esn = pi_esn.part_serial_no
      AND    llsub.enrollment_status = 'ENROLLED'
      AND    TRUNC(NVL(llsub.projected_deenrollment, SYSDATE+1)) >= TRUNC(SYSDATE);
    EXCEPTION
      WHEN OTHERS THEN
        n_enrolled_esn_count := 0;
    END;

    IF n_enrolled_esn_count > 0
    THEN
      o_err_code := 230;
      o_err_msg := 'TARGET ACCOUNT ALREADY HAS A LIFELINE ENROLLED ESN';
      RETURN;
    END IF;
  END IF;
  --CR54704 LIFELINE changes end
 -- Remove Link from existing account/contact
 DELETE table_x_contact_part_inst
 WHERE x_contact_part_inst2part_inst = get_esn_info_rec.objid;
 -- Check if the esn is the first in the account to set as primary
 BEGIN
 SELECT DECODE(COUNT(1),0,1,0) X_IS_DEFAULT -- Setting the primary ESN
 INTO get_esn_info_rec.x_is_default
 FROM table_x_contact_part_inst
 WHERE x_contact_part_inst2contact = get_webuser_info_rec.web_user2contact
 AND x_is_default = 1;
 EXCEPTION
 WHEN others THEN
 get_esn_info_rec.x_is_default := 0;
 END;
 -- create contact related information
 sa.contact_pkg.createcontact_prc ( p_esn => i_esn,
 p_first_name => i_esn,
 p_last_name => i_esn,
 p_middle_name => NULL,
 p_phone => NULL,
 p_add1 => NULL,
 p_add2 => NULL,
 p_fax => NULL,
 p_city => get_contact_rec.city,
 p_st => get_contact_rec.state,
 p_zip => get_contact_rec.zipcode,
 p_email => NULL,
 p_email_status => '0',
 p_roadside_status => '0',
 p_no_name_flag => '0',
 p_no_phone_flag => '0',
 p_no_address_flag => '0',
 p_sourcesystem => i_sourcesystem,
 p_brand_name => i_brand,
 p_do_not_email => '0',
 p_do_not_phone => '0',
 p_do_not_mail => '0',
 p_do_not_sms => '0',
 p_ssn => NULL,
 p_dob => NULL,
 p_do_not_mobile_ads => NULL,
 p_contact_objid => n_contact_o_objid,
 p_err_code => c_contact_o_err_code,
 p_err_msg => c_contact_o_err_msg);
 IF c_contact_o_err_code <> '0' OR n_contact_o_objid IS NULL
 THEN
 o_err_code := 191;
    o_err_msg := 'CREATE CONTACT FAILED: ' || c_contact_o_err_msg;
 RETURN;
 END IF;
 -- update language pref and PIN
 UPDATE table_x_contact_add_info
 SET x_lang_pref = NVL(i_language,x_lang_pref ),
 x_pin = NVL(i_pin, x_pin)
 WHERE add_info2contact = n_contact_o_objid;
 -- Link ESN to new contact copied
 UPDATE table_part_inst
 SET x_part_inst2contact = n_contact_o_objid
 WHERE objid = get_esn_info_rec.objid;
 -- Link ESN to Target account/contact
 BEGIN
 INSERT
 INTO table_x_contact_part_inst
 ( objid,
 x_contact_part_inst2contact,
 x_contact_part_inst2part_inst,
 x_esn_nick_name,
 x_is_default
 )
 VALUES
 ( seq('x_contact_part_inst'),
 get_webuser_info_rec.web_user2contact,
 get_esn_info_rec.objid,
 i_esn_nick_name,
 get_esn_info_rec.x_is_default );
 EXCEPTION
 WHEN others THEN
 o_err_code := 192;
 o_err_msg := 'ERROR CREATING CONTACT PART INST: '||SQLERRM;
 RETURN;
 END;

  -- CR53621 -- Begin
  c.min := c.get_min ( i_esn => i_esn );

  IF c.min IS NOT NULL AND
     c.min NOT LIKE 'T%'
  THEN
    --
    BEGIN
      UPDATE sa.table_contact
      SET    dev = dev
      WHERE  objid = get_webuser_info_rec.web_user2contact;
     EXCEPTION
     WHEN OTHERS
     THEN
       NULL;
    END;
    --
  END IF;
  -- CR53621  - End

 --CR48260_MultiLine Discount on SM - call sp_notify_affpart_discount_BRM
  enqueue_transactions_pkg.sp_notify_affpart_discount_BRM   (i_web_user_objid    => get_webuser_info_rec.objid              ,
                                                             i_login_name        => get_webuser_info_rec.login_name         ,
                                                             i_bus_org_id        => get_webuser_info_rec.org_id             ,
                                                             i_web_user2contact  => get_webuser_info_rec.web_user2contact   ,
                                                             o_response          => o_err_msg)	;
  DBMS_OUTPUT.PUT_LINE ('Enqueue_Transactions_Pkg.Sp_Notify_Affpart_Discount_Brm | o_response :'|| o_err_msg);
 ----CR48260 Ends

 o_err_code := 0;
 o_err_msg := 'SUCCESS';
 EXCEPTION
 WHEN OTHERS
 THEN
 o_err_code := 999;
 o_err_msg := SUBSTR('ERROR IN ADD_ESN_TO_ACCOUNT : '||SQLERRM, 1, 4000);
 RETURN;
END add_esn_to_account;
--Validate verification code with last 6 digits of the ESN
PROCEDURE validate_verification_code ( i_esn IN VARCHAR2 ,
 i_verification_code IN VARCHAR2 ,
 o_error_code OUT VARCHAR2 ,
 o_error_msg OUT VARCHAR2 ) IS
 -- cursor to get all active ESNs under the web account
 CURSOR web_user ( p_web_user_id NUMBER )
 IS
 SELECT wu.objid ,
 wu.login_name ,
 wu.web_user2contact,
 pi.objid esn_objid,
 pi.part_serial_no esn
 FROM table_x_contact_part_inst cpi,
 table_web_user wu,
 table_part_inst pi
 WHERE 1 = 1
 AND cpi.x_contact_part_inst2part_inst = pi.objid
 AND wu.web_user2contact = cpi.x_contact_part_inst2contact
 AND wu.objid = p_web_user_id
 AND pi.x_part_inst_status = '52'; --Active
 c sa.customer_type := sa.customer_type();
 cst sa.customer_type;
BEGIN
 --
 IF i_esn IS NULL THEN
 o_error_code := '100';
 o_error_msg := 'ESN NOT PASSED';
 END IF;
 --
 IF i_verification_code IS NULL THEN
 o_error_code := '110';
 o_error_msg := 'VERIFICATION CODE NOT PASSED';
 END IF;
 -- get the esn part inst status
 IF c.get_esn_part_inst_status ( i_esn => i_esn ) = '52' THEN
 IF SUBSTR(i_esn,-6) = i_verification_code THEN
 o_error_code := '0';
 o_error_msg := 'PASSED';
 ELSE
 o_error_code := '1';
 o_error_msg := 'FAILED VERIFICATION';
 END IF;
 RETURN;
 END IF;
 -- get web user objid for the input ESN
 c.esn := i_esn;
 cst := c.get_web_user_attributes;
 -- fail when the web user objid is not found
 IF cst.web_user_objid IS NULL THEN
 o_error_code := '120';
 o_error_msg := 'WEB ACCOUNT NOT FOUND';
 END IF;
 --
 FOR web_user_rec IN web_user ( cst.web_user_objid )
 LOOP
 c := sa.customer_type();
 IF c.get_esn_part_inst_status ( i_esn => web_user_rec.esn ) = '52' AND SUBSTR(web_user_rec.esn,-6) = i_verification_code
 THEN
 o_error_code := '0';
 o_error_msg := 'PASSED';
 RETURN;
 END IF;
 END LOOP;
 -- No matching ESNs found in the account. So returning as failed
 o_error_code := '1';
 o_error_msg := 'FAILED VERIFICATION';
 EXCEPTION
 WHEN OTHERS THEN
 o_error_code := '99';
 o_error_msg := 'FAILED IN WHEN OTHERS: ' || SQLERRM;
END validate_verification_code;


-- CR53621 -> The following function is to get the Dummy Account or Real Accont
-- Copied the logic from account_maintance.get_account_status Function
 FUNCTION get_account_status(i_login_name     IN VARCHAR2,
                             i_bus_org_objid  IN NUMBER) RETURN VARCHAR2
 IS
 l_account_status VARCHAR2(100);
 l_brand          VARCHAR2(100);

 BEGIN

  --CR53621  begins
   BEGIN
    SELECT name
      INTO l_brand
      FROM table_bus_org
     WHERE objid= i_bus_org_objid ;
   EXCEPTION
   WHEN OTHERS THEN
     l_brand := NULL;
   END;

  --CR53621  end

    l_account_status := CASE
                        WHEN ((UPPER(i_login_name) LIKE '%@'||UPPER(l_brand)||'.COM') AND
                              UPPER(l_brand) <>  'WFM')
                          OR (UPPER(i_login_name) LIKE '%@TF'||UPPER(l_brand)||'.COM')
                          OR (l_brand = 'NET10' AND UPPER(i_login_name) LIKE '%@NET10WIRELESS.COM')
                          OR (INSTR (l_brand,'_') > 0 AND  UPPER(i_login_name) LIKE '%@'||UPPER(REPLACE(l_brand,'_',''))||'.COM')
                        THEN 'DUMMY_ACCOUNT'
                        ELSE 'VALID_ACCOUNT'
                       END;
    RETURN(l_account_status);
    EXCEPTION
    WHEN OTHERS THEN
       RETURN(NULL);

END get_account_status;
end Account_Maintenance_pkg;
/