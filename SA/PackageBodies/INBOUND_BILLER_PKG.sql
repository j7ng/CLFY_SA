CREATE OR REPLACE PACKAGE BODY sa."INBOUND_BILLER_PKG" as


 /*************************************************************************
  --  History
  --REVISIONS    VERSION  DATE        WHO               PURPOSE
  -------------------------------------------------------------------------
  --                1.0               CWL                   Rewrite after Initial Revision
  --                1.1	  04032003    Suganthi		    CR 1386 Change of funding
  --		    1.2   04/17/03    SL                    Clarify Upgrade- sequence
  --		    1.3   05102003    Suganthi              CR 1157 Correct Autopay Details table
  --  	            1.3   05102003    Raju	            CR 1142 Change Debit Date
  --		    1.4	  06102003    Suganthi		    CR 1171 Allow 10 days to Change Funding.
  ************************************************************************/

  procedure main_prc          (
                           p_cycleNumber   varchar2,
                           p_createDate    varchar2,
                           p_accountNumber varchar2,
                           p_enrollDate    varchar2,
                           p_paymentMode   number,
                           p_accountStatus number,
                           p_status        varchar2,
                           p_firstName     varchar2 DEFAULT NULL,
                           p_lastName      varchar2 DEFAULT NULL,
                           p_address       varchar2 DEFAULT NULL,
                           p_city          varchar2 DEFAULT NULL,
                           p_state         varchar2 DEFAULT NULL,
                           p_zipcode       varchar2 DEFAULT NULL,
                           p_contactPhone  varchar2 DEFAULT NULL,
                           p_msg       OUT varchar2,
                           c_p_status  OUT varchar2
                          )  as
--------------------------------------------------
  cursor user_curs(c_login_name in varchar2) is
    select objid
      from table_user
     where s_login_name = upper(c_login_name);
  user_rec user_curs%rowtype;
------------------------------------------------------------
  cursor site_part_curs(c_esn in varchar2) is
    select objid,site_part2site
      from table_site_part
     where x_service_id = c_esn
       and part_status = 'Active';
  site_part_rec site_part_curs%rowtype;
------------------------------------------------------------
  cursor contact_curs(c_site_objid in number) is
    select c.*
      from table_contact c,
           table_contact_role cr
     where c.objid = cr.contact_role2contact
       and cr.CONTACT_ROLE2SITE=c_site_objid;
  contact_rec contact_curs%rowtype;
------------------------------------------------------------
  CURSOR sp_curs_c(c_site_part_objid in number) iS
    Select sp.objid                    site_part_objid,
           sp.x_min                    x_min,
           ca.objid                    carrier_objid,
           ir.inv_role2site            site_objid,
           ca.x_carrier_id             x_carrier_id,
           sp.site_objid               cust_site_objid,
           sp.state_code               v_state_code
      from
           table_x_carrier  ca,
           table_part_inst  pi2, ---x_Domain=Line
           table_inv_role   ir,
           table_inv_bin    ib,
           table_part_inst  pi,  ---x_Domain=Phone
           table_site_part  sp
     where ca.objid                 = pi2.part_inst2carrier_mkt
       and initcap(pi2.x_domain)    = 'Lines'
       and pi2.part_serial_no       = sp.x_min
       and ir.inv_role2inv_locatn   = ib.inv_bin2inv_locatn
       and ib.objid                 = pi.part_inst2inv_bin
       and pi.x_part_inst2site_part = sp.objid
       and sp.objid                 = c_site_part_objid;
  sp_curs_rec sp_curs_c%rowtype;
--------------------------------------------------
  cursor check_radio_shack_curs(c_esn in varchar2) is
    select *
      from TABLE_X_AUTOPAY_DETAILS
    where x_esn = c_esn
      and x_receive_status is null
      and x_program_type = 3;
  check_radio_shack_rec check_radio_shack_curs%rowtype;
--------------------------------------------------
  cursor check_detail_status_curs(c_esn in varchar2) is
    select *
      from TABLE_X_AUTOPAY_DETAILS
    where x_esn = c_esn
      and x_status in ('A','E');
  check_detail_status_rec check_detail_status_curs%rowtype;
--------------------------------------------------
  cursor check_active_type_curs(c_esn in varchar2,
                                c_paymentMode in number) is
    select 1
      from table_x_autopay_details
    where x_esn = c_esn
      and x_status in ('A','E')
      and X_PROGRAM_TYPE = c_paymentmode;
  check_active_type_rec check_active_type_curs%rowtype;
--------------------------------------------------
  v_part_inst_objid number ;
  hold_seq_number number;
  cnt number := 0;
  dayVal varchar2(30); ---for CR 1142
------------------------------------------------------------
  cursor check1_curs(c_esn            in varchar2,
                     c_program_type   in number,
                     c_account_status in number) is
    select objid
      from table_x_autopay_details
     where x_esn            = c_esn
       and x_program_type   = c_program_type
       and x_account_status = c_account_status
       and x_cycle_number   is null
       and x_promocode      is not null
       and X_ENROLL_AMOUNT  is not null
       and X_SOURCE         is not null
       and x_receive_status = 'R'
       and x_status         = 'A';
  check1_rec check1_curs%rowtype;
------------------------------------------------------------
  cursor check2_curs(c_esn in varchar2) is
    select objid
      from table_x_autopay_details
     where x_esn            = c_esn
       and x_receive_status is null
       and x_program_type   = 3
       and x_status         = 'A';
  check2_rec check2_curs%rowtype;
------------------------------------------------------------
  cursor check3_curs(c_esn in varchar2) is
    select objid
      from x_autopay_pending
     where x_esn = c_esn
       and x_source_flag = 'R'
       and x_receive_status = 'R'
       and x_status = 'A';
  check3_rec check3_curs%rowtype;
------------------------------------------------------------
--Start CR 1386
 cursor rev_check1_curs (c_esn          in varchar2,
                    c_program_type in number) is

  select objid from
   table_x_autopay_details
    where
     x_esn = c_esn
    and x_status  = 'I'
    and x_program_type = c_program_type
    and objid in ( select max(objid ) from table_x_autopay_details  where x_Esn= c_esn);

 rev_check1_rec  rev_check1_curs%rowtype;

-------------------------------------------------------------

 cursor rev_check2_curs (c_esn          in varchar2,
                     c_program_type in number) is
 select * from
 x_receive_ftp_auto
 where
 esn = c_esn
 and pay_type_ind ='REV'
 and program_type = c_program_type
 and rec_seq_no in (select max(rec_seq_no ) from sa.x_receive_ftp_auto where esn =c_esn);

 rev_check2_rec  rev_check2_curs%rowtype;

 --End  CR 1386
 --------------------------------------------------------------------
 -- Start CR 1171

 cursor late_funding_curs(p_esn in varchar2 ,p_program_type in number) is
 SELECT  * FROM  sa.x_send_ftp_auto
 WHERE account_status ='D'
 AND esn = p_esn
 AND program_type = p_program_type
 AND SEND_SEQ_NO in (select max(SEND_SEQ_NO) from sa.x_send_ftp_auto where
                    esn = p_esn
                    AND program_type = p_program_type);

late_funding_rec late_funding_curs%rowtype;

 -- End CR 1171
 -------------------------------------------------------------------
begin
dbms_output.put_line('RUNNING BILLER PACKAGE');
  open site_part_curs(p_accountNumber);
    fetch site_part_curs into site_part_rec;
    if site_part_curs%notfound then
      open check3_curs(p_accountnumber);
        fetch check3_curs into check3_rec;
        if check3_curs%found then
          update x_autopay_pending
             set x_receive_status = 'Y',
                 x_cycle_number   = p_cycleNumber,
                 x_creation_date  = TO_DATE(p_createDate,'yyyymmdd'),
                 x_enroll_date    = TO_DATE(p_enrollDate,'yyyymmdd'),
                 X_PROGRAM_TYPE   = p_paymentMode,
                 X_ACCOUNT_STATUS = p_accountStatus,
	         x_status         = decode (p_status,'I','I','A'), --changed by US 03172003
	         --x_status         = p_status -- commented out by Dan D., requested by Suganthi
                 x_first_name     = p_firstName,
                 x_last_name      = p_lastName,
                 x_address1       = p_address,
                 x_city           = p_city,
                 x_state          = p_state,
                 x_zipcode        = p_zipcode,
                 x_contact_phone  = p_contactPhone
               --  x_start_date     = sysdate    --CR 1157
           where objid = check3_rec.objid;
           close check3_curs;   -- added 1/23/03 to ensure cursor gets closed before returning
           c_p_status:= 'S';
           p_msg :='Sucessfull';
dbms_output.put_line('B4 the return.');
          return;
dbms_output.put_line('after the return.');
        end if;
      close check3_curs;
    end if;
  close site_part_curs;
------------------------------------------------------------
dbms_output.put_line('p_accountNumber:'||p_accountNumber);
dbms_output.put_line('p_paymentmode:'||p_paymentmode);
dbms_output.put_line('p_accountstatus:'||p_accountstatus);
  open check1_curs(p_accountNumber,p_paymentMode,p_accountstatus);
  open check2_curs(p_accountNumber);
    fetch check1_curs into check1_rec;
    fetch check2_curs into check2_rec;
    if check1_curs%found or check2_curs%found then
dbms_output.put_line('check1_curs%found or check2_curs%found:'||check1_rec.objid);
      if check1_curs%notfound then
        check1_rec.objid := check2_rec.objid;
dbms_output.put_line('check2_curs%found:'||check1_rec.objid);
      end if;
      INSERT INTO sa.x_autopay_contact
        (OBJID,
         ESN,
         FIRST_NAME,
         LAST_NAME,
         ADDRESS,
         CITY,
         STATE,
         ZIP,
         PHONE,
         CONTACT2AUTOPAY_DETAILS)
      VALUES
        (SEQ_x_autopay_contact.NEXTVAL,
         p_accountNumber,
         p_firstName,
         p_lastName,
         p_address,
         p_city,
         p_state,
         p_zipcode,
         p_contactPhone,
         check1_rec.objid);
      update table_x_autopay_details
         set x_creation_date  = TO_DATE(p_createDate,'yyyymmdd'),
             x_cycle_number   = p_cyclenumber,
             x_enroll_date    = TO_DATE(p_enrollDate,'yyyymmdd'),
             x_receive_status = 'Y',
             X_FIRST_NAME     = p_firstname,
             X_LAST_NAME      = p_lastname
             --x_start_date     = sysdate --CR 1157
       where objid = check1_rec.objid;
      close check1_curs;
      close check2_curs;
      c_p_status:= 'S';
      p_msg :='Sucessfull';
      return;
    end if;
  close check1_curs;
  close check2_curs;
--------------------------------------------------------------------------------
  open check_active_type_curs(p_accountNumber,p_paymentmode);
    fetch check_active_type_curs into check_active_type_rec;
    if check_active_type_curs%found and p_status = 'E' and  p_accountStatus!=5 then --changed by raju
      c_p_status:= 'S';
      p_msg :='Sucessfull';
      dbms_output.put_line('c_p_status:'||c_p_status);
      dbms_output.put_line('p_msg:'||p_msg);
      return;
    end if;
  close check_active_type_curs;
--1
dbms_output.put_line('cnt:'||cnt);cnt := cnt+ 1;
  open user_curs('SA');
    fetch user_curs into user_rec;
  close user_curs;
--------------------------------------------------
--2
dbms_output.put_line('cnt:'||cnt);cnt := cnt+ 1;
--------------------------------------------------
  v_part_inst_objid :=SP_RUNTIME_PROMO.get_esn_part_inst_objid(p_accountNumber);
--------------------------------------------------
--3
dbms_output.put_line('cnt:'||cnt);cnt := cnt+ 1;
--------------------------------------------------
  open site_part_curs(p_accountNumber);
  open check_detail_status_curs(p_accountNumber);
    fetch site_part_curs into site_part_rec;
    fetch check_detail_status_curs into check_detail_status_rec;
--------------------------------------------------
--4
dbms_output.put_line('cnt:'||cnt);cnt := cnt+ 1;
--------------------------------------------------
-- active or inactive code
---------------------------------------------------
 --start CR 1386
 open rev_check2_curs(p_accountNumber,p_paymentmode);
    fetch rev_check2_curs into rev_check2_rec ;
   open rev_check1_curs(p_accountNumber,p_paymentmode);
    fetch rev_check1_curs into rev_check1_rec ;
   -- end CR 1386

-- CR Start 1171
 open late_funding_curs(p_accountNumber,p_paymentmode);
 fetch late_funding_curs into late_funding_rec;

    IF (p_accountstatus = 5  and rev_check1_curs%found and rev_check2_curs%found
    and late_funding_curs%found)
    THEN
    close late_funding_curs ;
    c_p_status:= 'S';
    p_msg :='Sucessfull';
    return;
    END IF;

close late_funding_curs ;

-- CR End 1171
--------------------------------------------------
    if (site_part_curs%notfound and p_status = 'E') or
       (p_accountStatus=5 and check_detail_status_curs%found and p_status = 'E'and
        (rev_check1_curs%notfound or rev_check2_curs%notfound)) then  --CR 1386
--------------------------------------------------
dbms_output.put_line('site_part_curs%notfound and p_status = E cnt:'||cnt);cnt := cnt+ 1;
--------------------------------------------------
      --04/17/03
      select seq('x_autopay_details') into hold_seq_number from dual;
      insert into x_autopay_pending
      (OBJID                          ,
       X_CYCLE_NUMBER                 ,
       X_CREATION_DATE                ,
       X_ESN                          ,
       X_PROGRAM_TYPE                 ,
       X_ACCOUNT_STATUS               ,
       X_STATUS                       ,
       X_START_DATE                   ,
       X_FIRST_NAME                   ,
       X_LAST_NAME                    ,
       X_ENROLL_DATE                  ,
       X_PROGRAM_NAME                 ,
       X_AUTOPAY_DETAILS2SITE_PART    ,
       X_AUTOPAY_DETAILS2X_PART_INST  ,
       X_AUTOPAY_DETAILS2CONTACT      ,
       X_RECEIVE_STATUS               ,
       X_ADDRESS1                     ,
       X_CITY                         ,
       X_STATE                        ,
       X_ZIPCODE                      ,
       X_CONTACT_PHONE                ,
       X_END_DATE                     ,
       X_AGENT_ID                     ,
       X_TRANSACTION_TYPE             ,
       X_SOURCE_FLAG                  ,
       X_TRANSACTION_AMOUNT           ,
       X_PROMOCODE                    ,
       X_ENROLL_FEE_FLAG)
      values
      ( -- 04/17/03 SEQ_X_AUTOPAY_DETAILS.nextval + power(2,28),
       hold_seq_number,
       p_cycleNumber,
       TO_DATE(p_createDate,'yyyymmdd')+1 - 1/86400 ,--(TO_DATE(p_createDate,'yyyymmdd')),
       p_accountNumber,
       p_paymentMode,
       p_accountStatus,
       p_status,
       NULL, --SYSDATE,--CR 1157
       p_firstName,
       p_lastName,
       (TO_DATE(p_enrollDate,'yyyymmdd')),
       (decode(p_paymentmode,2,'AutoPay',
                             3,'Bonus Plan',
                             4,'Deactivation Protection')),
       site_part_rec.objid,
       v_part_inst_objid,
       contact_rec.objid,
       'Y',
       p_address,
       p_city,
       p_state,
       p_zipcode,
       p_contactPhone,
       null,
       null,
       null,
       null,
       null,
       null,
       null
       );
--------------------------------------------------
--4
dbms_output.put_line('cnt:'||cnt);cnt := cnt+ 1;
--------------------------------------------------
      /* 04/17/03 select SEQ_X_AUTOPAY_DETAILS.currval + power(2,28)
          into hold_seq_number
          from dual; --- changed by raju   */
      if site_part_curs%notfound then
--------------------------------------------------
--4
dbms_output.put_line('if notfound cnt:'||cnt);cnt := cnt+ 1;
--------------------------------------------------
         update x_autopay_pending
            set X_SOURCE_FLAG = 'B'
                --,x_start_date = decode(x_start_date,null,sysdate)--CR 1157
          where objid = hold_seq_number;

      elsif (p_accountStatus=5 and check_detail_status_curs%found and p_status = 'E'and
              (rev_check1_curs%notfound or rev_check2_curs%notfound)) then --CR 1386
---------------------------------------------------------
--4
dbms_output.put_line('if elsecnt:'||cnt);cnt := cnt+ 1;
--------------------------------------------------
        update x_autopay_pending
           set X_SOURCE_FLAG = 'U'
               --,x_start_date = decode(x_start_date,null,sysdate)--CR 1157
         where objid = hold_seq_number; ---changed by raju
      end if;
      close site_part_curs;
      close check_detail_status_curs;
      close rev_check2_curs ;
      close rev_check1_curs ;
      c_p_status:= 'S';
      p_msg :='Sucessfull';
      dbms_output.put_line('c_p_status:'||c_p_status);
      dbms_output.put_line('p_msg:'||p_msg);
      return;
    end if;
--------------------------------------------------
  close site_part_curs;
  close check_detail_status_curs;
  close rev_check2_curs ;
  close rev_check1_curs ;
--------------------------------------------------
  open contact_curs(site_part_rec.site_part2site);
    fetch contact_curs into contact_rec;
  close contact_curs;
--------------------------------------------------
  OPEN sp_curs_c(site_part_rec.objid);
    Fetch sp_curs_c into sp_curs_rec;
  CLOSE sp_curs_c;
--------------------------------------------------
  c_p_status:= 'S';
  p_msg :='Sucessfull';
--------------------------------------------------
--------------------------------------------------
--5
dbms_output.put_line('5cnt:'||cnt);cnt := cnt+ 1;
--------------------------------------------------
  IF p_status in ('E','I') THEN
--------------------------------------------------
--6
dbms_output.put_line('cnt:'||cnt);cnt := cnt+ 1;
--------------------------------------------------
      open check_radio_shack_curs(p_accountNumber);
      fetch check_radio_shack_curs into check_radio_shack_rec;
      IF p_status = 'E' and check_radio_shack_curs%found THEN
--------------------------------------------------
dbms_output.put_line('p_status = E and check_radio_shack_curs found cnt:'||cnt);cnt := cnt+ 1;
--------------------------------------------------
        UPDATE table_x_autopay_details
        SET   x_creation_date = TO_DATE(p_createDate,'yyyymmdd')
              ,x_cycle_number = p_cycleNumber
              ,x_program_name = 'Bonus Plan'
              ,x_first_name   = p_firstName
              ,x_last_name    = p_lastName
              ,x_receive_status = 'Y'
              --,x_start_date = sysdate  --CR 1157
        where objid = check_radio_shack_rec.objid;
        INSERT INTO sa.x_autopay_contact
        (OBJID,
         ESN,
         FIRST_NAME,
         LAST_NAME,
         ADDRESS,
         CITY,
         STATE,
         ZIP,
         PHONE,
         CONTACT2AUTOPAY_DETAILS)
        VALUES
        (SEQ_x_autopay_contact.NEXTVAL,
         p_accountNumber,
         p_firstName,
         p_lastName,
         p_address,
         p_city,
         p_state,
         p_zipcode,
         p_contactPhone,
         check_radio_shack_rec.objid);
      else
--------------------------------------------------
dbms_output.put_line('else not radio shack cnt:'||cnt);cnt := cnt+ 1;
--------------------------------------------------
If p_status = 'I' THEN --CR 1157
      /* -- Commented out for CR 1157
        delete from TABLE_X_AUTOPAY_DETAILS
         where x_esn = p_accountNumber
          AND x_status in ('E')
          AND X_PROGRAM_TYPE in (2,3,4);

--------------------------------------------------
         delete from x_autopay_contact
         where esn = p_accountNumber;
      */
--------------------------------------------------

-- Added for CR 1157
        Update TABLE_X_AUTOPAY_DETAILS
        set x_status ='O',
           x_receive_status ='Y',
           x_account_status =9 ,
           x_end_date = sysdate
        where
  	    x_esn = p_accountNumber
           AND x_status in ('E')
           AND X_PROGRAM_TYPE= p_paymentmode;

        update TABLE_X_AUTOPAY_DETAILS
           set x_status = 'I',
               X_receive_status='Y', --- changed by raju
               x_account_status = 9,
               --x_start_date=decode(x_start_date,null,sysdate),  --CR 1157
               X_END_DATE=sysdate
         where x_esn = p_accountNumber
           AND x_status in ('A')
           --AND X_PROGRAM_TYPE (2,3,4);   --CR 1157
           AND X_PROGRAM_TYPE = p_paymentmode;
--------------------------------------------------
        Update table_x_call_trans
           set x_result='Cancel',
               x_transact_date=sysdate
         where x_action_type='82'
           and x_service_id= p_accountNumber
           and x_result='Pending';
--------------------------------------------------
END IF;   --CR 1157

   --start CR 1386
   open rev_check2_curs(p_accountNumber,p_paymentmode);
     fetch rev_check2_curs into rev_check2_rec ;
   open rev_check1_curs(p_accountNumber,p_paymentmode);
    fetch rev_check1_curs into rev_check1_rec ;
   -- end CR 1386



    If (p_accountstatus = 5  and rev_check1_curs%found and rev_check2_curs%found )or p_accountstatus in (3,9) --CR 1386
    then

        INSERT INTO TABLE_X_CALL_TRANS
            (objid,
             call_trans2site_part,
             x_action_type,
             x_call_trans2carrier,
             x_call_trans2dealer,
             x_call_trans2user,
             x_line_status,
             x_min,
             x_service_id,
             x_sourcesystem,
             x_transact_date,
             x_total_units,
             x_action_text,
             x_reason,
             x_result,
             x_sub_sourcesystem
            )
        VALUES(
            -- 04/17/03 (seq_x_call_trans.NEXTVAL + POWER (2, 28)),
             seq('x_call_trans'),
             sp_curs_rec.site_part_objid,
             (decode(p_status,'E','82','I','83')),
             sp_curs_rec.carrier_objid,
             sp_curs_rec.site_objid,
             user_rec.objid,
             '13',
             sp_curs_rec.x_min,
             p_accountNumber,
             'AUTOPAY_BATCH',
             (sysdate+(1/86400)),
             0,
             --(decode(p_status,'E','Enrollment','I','Cancellation')),     --CR 1157
             (decode(p_status,'E','STAYACT SUBSCRIBE','I','STAYACT UNSUBSCRIBE')),
             --(decode(p_status,'E','STAYACT SUBSCRIBE','I','STAYACT UNSUBSCRIBE')),   --CR 1157
             (decode(p_status,'E',decode(p_paymentmode,2,'(2)Autopay',3,'(3)Double Min',4,'(4)DPP'),'I','Customer-Voluntary')),
             (decode(p_status,'E','Pending','I','Completed')),
             '202');

      End if;
        if
         ( p_status = 'E' and p_accountstatus =3) or
         (p_status ='E'and p_accountstatus = 5  and rev_check1_curs%found and rev_check2_curs%found ) --CR1386
         then
--------------------------------------------------
dbms_output.put_line('cnt:'||cnt||'p_accountNumber:'||p_accountNumber);cnt := cnt+ 1;
dbms_output.put_line('cnt:'||cnt||'p_createDate:'||p_createDate);cnt := cnt+ 1;
dbms_output.put_line('cnt:'||cnt||'p_enrollDate:'||p_enrollDate);cnt := cnt+ 1;
--------------------------------------------------
          -- 04/17/03
          select seq('x_autopay_details') into hold_seq_number from dual;
          INSERT INTO table_x_autopay_details
            (OBJID,
             X_CYCLE_NUMBER,
             X_CREATION_DATE,
             X_ESN,
             X_PROGRAM_TYPE,
             X_ACCOUNT_STATUS,
             X_STATUS,
             X_START_DATE,
             X_FIRST_NAME,
             X_LAST_NAME,
             X_ENROLL_DATE,
             X_PROGRAM_NAME,
             X_AUTOPAY_DETAILS2SITE_PART,
             X_AUTOPAY_DETAILS2X_PART_INST,
             X_AUTOPAY_DETAILS2CONTACT,
             X_RECEIVE_STATUS)
          VALUES
            (-- 04/17/03 SEQ_X_AUTOPAY_DETAILS.nextval + power(2,28),
             hold_seq_number,
             p_cycleNumber,
             (TO_DATE(p_createDate,'yyyymmdd')),
             p_accountNumber,
             p_paymentMode,
             p_accountStatus,
             p_status,
             NULL,--SYSDATE, --CR 1157
             p_firstName,
             p_lastName,
             (TO_DATE(p_enrollDate,'yyyymmdd')),
             (decode(p_paymentmode,2,'AutoPay',
                                   3,'Bonus Plan',
                                   4,'Deactivation Protection')),
             site_part_rec.objid,
             v_part_inst_objid,
             contact_rec.objid,
             'Y');
--------------------------------------------------
dbms_output.put_line('cnt:'||cnt);cnt := cnt+ 1;
--------------------------------------------------
          INSERT INTO sa.x_autopay_contact
            (OBJID,
             ESN,
             FIRST_NAME,
             LAST_NAME,
             ADDRESS,
             CITY,
             STATE,
             ZIP,
             PHONE,
             CONTACT2AUTOPAY_DETAILS)
          VALUES
            (SEQ_x_autopay_contact.NEXTVAL,
             p_accountNumber,
             p_firstName,
             p_lastName,
             p_address,
             p_city,
             p_state,
             p_zipcode,
             p_contactPhone,
             -- 04/17/03 SEQ_X_AUTOPAY_DETAILS.currval + power(2,28)
             hold_seq_number );

             --start CR 1386
             If (p_status ='E'and p_accountstatus = 5  and rev_check1_curs%found and rev_check2_curs%found )
             then
             select trim(to_char(sysdate,'DAY')) into dayVal from dual; -- CR 1142
             INSERT INTO sa.X_SEND_FTP_AUTO
             (  SEND_SEQ_NO ,
		CYCLE_NUMBER ,
		SENT_DATE     ,
		FILE_TYPE_IND  ,
		ESN           ,
		PROGRAM_TYPE   ,
		ACCOUNT_STATUS  ,
		AMOUNT_DUE   ,
		DEBIT_DATE
             )
              VALUES
             ( SEQ_X_SEND_FTP_AUTO.NEXTVAL,
                NULL,
                NULL,
                'D',
                rev_check2_REC.ESN,
                rev_check2_rec.program_type,
                'U', --decode (rev_check2_rec.enroll_flag,'Y','U','A'),
                rev_check2_rec.trans_amount,
                decode(dayVal,'FRIDAY',sysdate+3,'SATURDAY',sysdate+2,sysdate+1) -- CR 1142
                );
                 end if;                --end CR 1386
        end if;
      close check_radio_shack_curs;
    end if;
    close rev_check2_curs;
    close rev_check1_curs;

    c_p_status:= 'S';
    p_msg :='Sucessfull';
  ELSIF(p_status = 'CP') THEN
    if length(ltrim(rtrim(p_contactPhone)))=10 then
      update table_contact
         set phone=ltrim(rtrim(p_contactPhone)),
             x_autopay_update_flag=1
       where objid=contact_rec.objid
         and phone!=ltrim(rtrim(p_contactPhone));
    end if;
    c_p_status:= 'S';
    p_msg :='Sucessfull';
  END IF;
  c_p_status:= 'S';
  p_msg :='Sucessfull';
dbms_output.put_line('c_p_status:'||c_p_status);
dbms_output.put_line('p_msg:'||p_msg);
EXCEPTION WHEN OTHERS THEN
  c_p_status := 'F';
  p_msg := 'Failure >> '||SUBSTR(SQLERRM,1,100);
  dbms_output.put_line('c_p_status:'||c_p_status);
  dbms_output.put_line('p_msg:'||p_msg);
  RETURN;
end main_prc;
end inbound_biller_pkg;
/