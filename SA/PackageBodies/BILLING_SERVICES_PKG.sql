CREATE OR REPLACE package body sa.billing_services_pkg
is

 -- is new my account added
 function is_new_acct_added (i_pgm_enrl2_part_inst in number, i_pgm_enrl2_pymt_src in number) return boolean
 is
 l_account_found NUMBER;
 begin
 select count(1)
 into   l_account_found
 from   sa.table_web_user wu,
        sa.table_x_contact_part_inst cpi,
        sa.x_payment_source ps,
        sa.table_x_credit_card cc
 where  cpi.x_contact_part_inst2part_inst = i_pgm_enrl2_part_inst--9991038983-- pe.pgm_enroll2part_inst
 and    cpi.x_contact_part_inst2contact   = wu.web_user2contact
 and    ps.objid                          = i_pgm_enrl2_pymt_src --27280602--pe.pgm_enroll2x_pymt_src
 and    ps.pymt_src2x_credit_card         = cc.objid
 and    ps.x_status                       ='ACTIVE'
 and    cc.x_card_status                  ='ACTIVE';

 if l_account_found > 0 then
 return true;
 else
 return false;
 end if;
 end;

 -- is enrolled without CC
 function is_enrolled_without_cc (i_pgm_enrl2_part_inst in number) return boolean --{
 is
 l_account_found NUMBER;
 begin
 select count(1)
 into   l_account_found
 from   sa.table_web_user wu,
        sa.table_x_contact_part_inst cpi
 where  cpi.x_contact_part_inst2part_inst = i_pgm_enrl2_part_inst--9991038983-- pe.pgm_enroll2part_inst
 and    cpi.x_contact_part_inst2contact   = wu.web_user2contact;

 if l_account_found > 0 then
 return true;
 else
 return false;
 end if;
 end ; --}

 -- byop or not
 function is_not_byop (i_esn in varchar2) return boolean
 is
 x_val NUMBER;
 begin
 select count(1)
 into x_val
 from table_part_inst pi,
 table_mod_level ml,
 table_part_num pn,
 table_x_part_class_values v,
 table_x_part_class_params n
 where 1 = 1
 and pi.part_serial_no = i_esn
 and pi.x_domain = 'PHONES'
 and ml.objid = pi.n_part_inst2part_mod
 and pn.objid = ml.part_info2part_num
 and v.value2part_class = pn.part_num2part_class
 and v.value2class_param = n.objid
 and v.x_param_value = 'BYOP'
 and n.x_param_name = 'DEVICE_TYPE';

 if x_val > 0 then
 return false;
 else
 return true;
 end if;
 end;

 -- for TAS
 function hpp_next_charge_date (i_esn in varchar2) return date
 is
 cursor cur_next_charge_date is
 select pe.*, pp.x_charge_frq_code plan_type
 from sa.x_program_enrolled pe,
 sa.x_program_parameters pp
 where 1 =1
 and pe.x_esn = i_esn
 and pe.pgm_enroll2pgm_parameter = pp.objid
 and pe.x_enrollment_status = 'ENROLLED_NO_ACCOUNT'
 and pp.x_prog_class = 'WARRANTY';
 rec_next_charge_date cur_next_charge_date%rowtype;

 cnt number := 0;
 l_next_change_date date;

 begin
 open cur_next_charge_date;
 fetch cur_next_charge_date into rec_next_charge_date;
 if cur_next_charge_date%found then
 --
 if rec_next_charge_date.plan_type = '365' and is_not_byop (rec_next_charge_date.x_esn) then
 --
 select count(*)
 into cnt
 from x_program_purch_hdr ph
 where objid in (select pgm_purch_dtl2prog_hdr
 from x_program_purch_dtl
 where 1 = 1
 and pgm_purch_dtl2pgm_enrolled in ( select pe.objid
 from x_program_enrolled pe,
 x_program_parameters pp
 where PE.PGM_ENROLL2PGM_PARAMETER = pp.objid
 and pp.x_prog_class = 'WARRANTY'
 and pe.x_esn = rec_next_charge_date.x_esn )
 )
 and ph.x_ics_rcode in ('1','100')
 and ph.x_payment_type='RECURRING';

 if cnt = 0 then
 --
 if rec_next_charge_date.x_charge_date >= sysdate - 365 then
 l_next_change_date := nvl(rec_next_charge_date.x_next_charge_date,rec_next_charge_date.x_charge_date + 365);
 else
 l_next_change_date := nvl(rec_next_charge_date.x_next_charge_date, trunc(sysdate) + 1);
 end if;

 end if; --cnt if


 --monthly plan
 elsif rec_next_charge_date.plan_type = 'MONTHLY' then
 --
 if rec_next_charge_date.x_charge_date > add_months (sysdate,-1) then
 l_next_change_date := sysdate + 1;
 else
 l_next_change_date := rec_next_charge_date.x_charge_date + 30;
 end if;
 end if;

 return l_next_change_date;
 else
 --
 return null; --no data found
 --
 end if;
 close cur_next_charge_date;

 end;


 procedure sp_enrolled_no_account (i_pgm_class in VARCHAR2) -- WARRANTY (HPP)
 is
 --
 /* ************************************************************************************************************
 Date Script created : 08/23/2016
 Problem Statement : Updating the ENROLLED_NO_ACCOUNT to ENROLLED if the ESN has valid account and payment source
 Ticket Requested Below (X) :
 Expected Number of records :
 Time of execution : Every day at 11.30 pm
 FIX Type : Data Cleanup for enrolled no accounts
 CRs/Tickets Related to Permanent Fix : CR 43005
************************************************************************************************************ */

 --
CURSOR get_enrolled_no_account is
SELECT /*+ PARALLEL(8) */
       pe.*, pe.x_esn esn, pp.x_charge_frq_code plan_type, bl.x_log_date
FROM   sa.x_billing_log bl,
       sa.x_program_enrolled pe,
       sa.x_program_parameters pp
where  1                           = 1
and    bl.x_log_category           = 'ESN'
and    bl.x_log_title              = 'REMOVE_ESN'
and    pe.x_esn                    = bl.x_esn
and    pe.pgm_enroll2pgm_parameter = pp.objid
and    pe.x_enrollment_status      = 'ENROLLED_NO_ACCOUNT'
and    pp.x_prog_class             = i_pgm_class;

 TYPE r_enrolled_no_account IS TABLE OF get_enrolled_no_account%rowtype;
 rec_enrolled_no_account r_enrolled_no_account;

 l_next_change_date date := NULL;
 cnt number := 0;

 --
 i_cc_pmt_id   NUMBER := 0;
 --
 v_is_new_acct_added boolean;
 v_is_enrolled_without_cc boolean;

 begin
 --
 open get_enrolled_no_account;
 loop
 FETCH get_enrolled_no_account BULK COLLECT INTO rec_enrolled_no_account limit 1000;

 for i in 1..rec_enrolled_no_account.count loop

 v_is_new_acct_added := is_new_acct_added (rec_enrolled_no_account(i).pgm_enroll2part_inst,rec_enrolled_no_account(i).pgm_enroll2x_pymt_src);
 v_is_enrolled_without_cc := is_enrolled_without_cc (rec_enrolled_no_account(i).pgm_enroll2part_inst);
 --account and payment src added
 if v_is_new_acct_added
    OR
    v_is_enrolled_without_cc
 then


 --get payment source start --{

   IF NOT v_is_new_acct_added
   THEN --{
      BEGIN --{
      SELECT objid
      INTO   i_cc_pmt_id
      FROM
             (
              SELECT ps.objid objid
              FROM   table_x_credit_card cc,
                     x_payment_source    ps,
                     table_web_user      wu
              WHERE  ps.pymt_src2x_credit_card    = cc.objid
              AND    ps.x_status                  = 'ACTIVE'
              AND    ps.pymt_src2web_user         = wu.objid
              AND    wu.objid                     = sa.CUSTOMER_INFO.get_web_user_attributes(rec_enrolled_no_account(i).esn, 'WEB_USER_ID')
              AND    ps.x_pymt_type               = 'CREDITCARD'
              AND    x_credit_card2bus_org        = sa.util_pkg.get_bus_org_objid(rec_enrolled_no_account(i).esn)
              ORDER  BY ps.objid desc
             )
      WHERE ROWNUM <= 1;
      EXCEPTION
       WHEN OTHERS THEN
        i_cc_pmt_id := 0;
      END; --}
   END IF; --}

 --get payment source end --}

 IF NVL(rec_enrolled_no_account(i).pgm_enroll2x_pymt_src, i_cc_pmt_id) > 0 --CC Check
 THEN --{

        --annual plan
        if rec_enrolled_no_account(i).plan_type = '365' and is_not_byop (rec_enrolled_no_account(i).x_esn) then
        --
          select count(*)
          into cnt
          from x_program_purch_hdr ph
          where objid in (select pgm_purch_dtl2prog_hdr
          from x_program_purch_dtl
          where 1 = 1
          and pgm_purch_dtl2pgm_enrolled in ( select pe.objid
          from x_program_enrolled pe,
          x_program_parameters pp
          where PE.PGM_ENROLL2PGM_PARAMETER = pp.objid
          and pp.x_prog_class = 'WARRANTY'
          and pe.x_esn = rec_enrolled_no_account(i).x_esn )
          )
          and ph.x_ics_rcode in ('1','100')
          and ph.x_payment_type='RECURRING';

         if cnt = 0 then
          --
           if rec_enrolled_no_account(i).x_charge_date <= sysdate - 365 then
           l_next_change_date := nvl(rec_enrolled_no_account(i).x_next_charge_date,rec_enrolled_no_account(i).x_charge_date + 365);
           else
           l_next_change_date := nvl(rec_enrolled_no_account(i).x_next_charge_date, trunc(sysdate) + 1);
           end if;

         end if; --cnt if


        --monthly plan
        elsif rec_enrolled_no_account(i).plan_type = 'MONTHLY' then
        --
         if rec_enrolled_no_account(i).x_charge_date < add_months (sysdate,-1) then
         l_next_change_date := sysdate + 1;
         else
         l_next_change_date := rec_enrolled_no_account(i).x_charge_date + 30;
         end if;

        -- other program classes (need to check wity Ramu for the rules)
        elsif rec_enrolled_no_account(i).plan_type in ( '30','60','90', 'LOWBALANCE') then
         --
         if rec_enrolled_no_account(i).x_charge_date < add_months (sysdate,-1) then
         l_next_change_date := sysdate + 1;
         else
         l_next_change_date := rec_enrolled_no_account(i).x_charge_date + 30;
         end if;
        end if; --plans

        -- enrolled
        IF v_is_new_acct_added
        THEN  --{
         UPDATE sa.x_program_enrolled
         SET    x_enrollment_status     = 'ENROLLED',
                x_next_charge_date      = l_next_change_date,
                x_update_stamp          = SYSDATE,
                x_wait_exp_date         = NULL
         WHERE  objid                   = rec_enrolled_no_account(i).objid;
        ELSE
         UPDATE sa.x_program_enrolled
         SET    x_enrollment_status     = 'ENROLLED',
                x_next_charge_date      = l_next_change_date,
                x_update_stamp          = SYSDATE,
                x_wait_exp_date         = NULL,
                pgm_enroll2x_pymt_src   = i_cc_pmt_id
         WHERE  objid                   = rec_enrolled_no_account(i).objid;
        END IF; --}

 ELSE --}{ --No CC present

  IF   rec_enrolled_no_account(i).x_log_date >= add_months(sysdate,-2)
  THEN --{
   -- set wait period 60 days from log date
   UPDATE sa.x_program_enrolled
   SET    x_wait_exp_date = (rec_enrolled_no_account(i).x_log_date + 60),
          x_update_stamp  = SYSDATE
   WHERE  objid           = rec_enrolled_no_account(i).objid;

  ELSE --}{

   -- suspend after 60 days from log date
   UPDATE   sa.x_program_enrolled
   SET      x_enrollment_status = 'SUSPENDED',
            x_wait_exp_date     = (rec_enrolled_no_account(i).x_log_date + 60),
            x_update_stamp      = SYSDATE
   WHERE    objid               = rec_enrolled_no_account(i).objid;

  END IF; --}

 END IF; --} --CC Check

 else --no account added

 if rec_enrolled_no_account(i).x_log_date >= add_months(sysdate,-2) then
  -- set wait period 60 days from log date
  update sa.x_program_enrolled
  set x_wait_exp_date = (rec_enrolled_no_account(i).x_log_date + 60),
  x_update_stamp = SYSDATE
  where objid = rec_enrolled_no_account(i).objid;

 else
  -- suspend after 60 days from log date
  update sa.x_program_enrolled
  set x_enrollment_status = 'SUSPENDED',
  x_wait_exp_date = (rec_enrolled_no_account(i).x_log_date + 60),
  x_update_stamp = SYSDATE
  where objid = rec_enrolled_no_account(i).objid;
 end if;

 end if; --acct if


 end loop; --inner loop
 commit;

 exit when get_enrolled_no_account%notfound;
 end loop; --main loop

 close get_enrolled_no_account;


 exception
 when others then
 raise;
 end sp_enrolled_no_account;

end billing_services_pkg;
/