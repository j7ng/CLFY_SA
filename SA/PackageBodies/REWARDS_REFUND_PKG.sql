CREATE OR REPLACE package body sa.rewards_refund_pkg
is
 --$RCSfile: REWARDS_REFUND_PKG.sql,v $
 --$Revision: 1.25 $
 --$Author: sethiraj $
 --$Date: 2016/09/16 12:49:44 $
 --$ $Log: REWARDS_REFUND_PKG.sql,v $
 --$ Revision 1.25  2016/09/16 12:49:44  sethiraj
 --$ CR41473-LRP2-Added Modification History Template
 --$
 --$ Revision 1.24  2016/09/12 09:30:21  sethiraj
 --$ CR41473-LRP2-Commented codes removed as per review comments.
 --$


PROCEDURE p_is_pin_refundable(
    in_esn                IN x_reward_program_enrollment.esn%TYPE,
    in_web_account_id     IN x_reward_program_enrollment.web_account_id%TYPE,
    in_service_plan_pin   IN x_reward_benefit_transaction.svc_plan_pin%TYPE,
    in_program_name       IN x_reward_benefit_program.program_name%TYPE,
    in_trans_type         IN x_reward_benefit_transaction.trans_type%TYPE,
    in_benefit_type_code  IN x_reward_benefit_program.benefit_type_code%TYPE,
    in_brand              IN x_reward_benefit_program.brand%TYPE,
    out_err_code          out NUMBER,
    out_err_msg           out VARCHAR2)
IS

  --------------------------------------------------------------------------------------------
  -- Author: Usha S
  -- Date: 2015/12/09
  -- <CR# 33098> REFUND
  --
  -- Revision 1.1  yyyy/mm/dd hh:mm:ss  <tf userid>
  -- <CR# Description>
  --
  --------------------------------------------------------------------------------------------

  l_is_enrolled        VARCHAR2(10);
  l_ENROLLMENT_STATUS  VARCHAR2(30);
  l_eligible_status     varchar2(50);
  validation_failed    exception;
  rc sa.customer_type               :=sa.customer_type ( i_esn => in_esn);
  cst sa.customer_type;
  l_web_account_id x_reward_program_enrollment.web_account_id%TYPE;


  lv_is_card_in_queue VARCHAR2(1) := 'N';


  btrans                      typ_lrp_benefit_trans;
  benefit                     typ_lrp_reward_benefit;

  CURSOR cur_card_in_queue
  IS
    SELECT 1 cnt_red_code
    FROM sa.table_part_inst esn,
      sa.table_part_inst lin
    WHERE 1                       = 1
    AND lin.part_to_esn2part_inst = esn.objid
    AND lin.x_part_inst_status    = '400'
    AND lin.x_domain              = 'REDEMPTION CARDS'
    AND lin.x_red_code            = trim(in_service_plan_pin)
    AND esn.x_domain              = 'PHONES'
    AND esn.part_serial_no        = in_esn;

  CURSOR cur_points_for_trans (c_web_account_id in x_reward_program_enrollment.web_account_id%TYPE)
  IS
    SELECT rbt.* FROM x_reward_benefit_transaction rbt, x_reward_program_enrollment rpe, x_reward_benefit_program rbp
    WHERE 1 = 1
    AND rbt.web_account_id = c_web_account_id
    AND rbt.esn = in_esn
    AND rbt.trans_type = in_trans_type
    AND rbt.svc_plan_pin = trim(in_service_plan_pin)
    AND rbt.brand = in_brand
    AND rpe.web_account_id = rbt.web_account_id
    AND rpe.esn =rbt.esn
    AND rpe.brand =rbt.brand
    AND rpe.benefit_type_code = rbt.benefit_type_code
    AND rbp.program_name = in_program_name
    AND rbp.benefit_type_code = in_benefit_type_code
    AND rpe.enrollment_flag = 'Y'
    AND rpe.deenroll_date IS  NULL
    AND rbp.program_name = rpe.program_name
    AND rpe.benefit_type_code = rbp.benefit_type_code
    AND rbt.benefit_type_code = rbp.benefit_type_code
    AND rpe.brand = rbp.brand
    AND rbt.brand = rbp.brand
    AND SYSDATE BETWEEN rbp.start_date AND rbp.end_date;
    rec_points_for_trans cur_points_for_trans%rowtype;

BEGIN

  out_err_code := 0;
  out_err_msg := 'SUCCESS';

  IF in_esn IS NULL THEN
    out_err_code   := -303;
    out_err_msg    := 'Error. Input ESN cannot be null';
    raise validation_failed;
  elsif in_service_plan_pin IS NULL THEN
    out_err_code   := -304;
    out_err_msg    := 'Error. Input Service Plan Pin cannot be null';
    raise validation_failed;
  END IF;

  IF in_web_account_id    IS NULL THEN
    cst              := rc.retrieve;
    l_web_account_id := cst.web_user_objid;
  ELSE
    l_web_account_id := in_web_account_id;
  END IF;
  --
  rewards_mgt_util_pkg.p_customer_is_enrolled (
                                in_cust_key             => 'ACCOUNT',
                                in_cust_value           => l_web_account_id,
                                in_program_name         => in_program_name,
                                in_enrollment_type      => 'PROGRAM_ENROLLMENT',
                                in_brand                => in_brand,
                                out_enrollment_status   => l_ENROLLMENT_STATUS,
                                out_enrollment_elig_status	=> l_eligible_status,
                                out_err_code            => out_err_code,
                                out_err_msg             => out_err_msg);
  --
  IF out_err_code <> 0 THEN
    out_err_code   := out_err_code;
    out_err_msg    := 'calling  rewards_mgt_util_pkg.p_customer_is_enrolled failed from refund procedure';
    RETURN;
  END IF;


   IF l_ENROLLMENT_STATUS NOT IN ('ENROLLED','SUSPENDED') -- no need to go further
   THEN
   out_err_code   := '310';
   out_err_msg    := 'STATUS not in Enrolled or Suspended';
   RETURN;
   END IF;


  FOR rec IN cur_card_in_queue
  loop
  lv_is_card_in_queue := 'Y';
  END loop;

  IF lv_is_card_in_queue = 'Y' THEN

  OPEN cur_points_for_trans (l_web_account_id);
  fetch cur_points_for_trans INTO rec_points_for_trans;

    IF cur_points_for_trans%found THEN

    IF rec_points_for_trans.amount > 0 THEN

      ---CREATE BENEFIT TRANSACTION RECORD
      btrans := typ_lrp_benefit_trans();

      btrans.objid                       := 0;
      btrans.trans_date                  := SYSDATE;
      btrans.web_account_id              := l_web_account_id;
      btrans.subscriber_id               := NULL;
      btrans.MIN                         := NULL;
      btrans.esn                         := in_esn;
      btrans.old_min                     := NULL;
      btrans.old_esn                     := NULL;
      btrans.trans_type                  := 'REFUND';
      btrans.trans_desc                  := NULL;
      btrans.amount                      := rec_points_for_trans.amount;
      btrans.benefit_type_code           := in_benefit_type_code;
      btrans.action                      := 'DEDUCT';
      btrans.action_type                 := 'REFUND';
      btrans.action_reason               := 'DEDCUT POINTS FOR REFUND';
      btrans.action_notes                := null;
      btrans.benefit_trans2benefit_trans := rec_points_for_trans.objid;
      btrans.svc_plan_pin                := in_service_plan_pin;
      btrans.svc_plan_id                 := NULL;
      btrans.brand                       := in_brand;
      btrans.benefit_trans2benefit       := rec_points_for_trans.benefit_trans2benefit;
      btrans.agent_login_name			       := NULL;

      --CREATE BENEFIT REWARD RECORD
      benefit := typ_lrp_reward_benefit ();

      benefit.objid             := 0;
      benefit.web_account_id    := l_web_account_id;
      benefit.subscriber_id     := NULL;
      benefit.MIN               := NULL;
      benefit.esn               := in_esn;
      benefit.benefit_owner     := 'ACCOUNT';
      benefit.created_date      := SYSDATE;
      benefit.status            := 'AVAILABLE';
      benefit.notes             := NULL;
      benefit.benefit_type_code := in_benefit_type_code;
      benefit.update_date       := NULL;
      benefit.expiry_date       := NULL;
      benefit.brand             := in_brand;
      benefit.quantity          := NULL;
      benefit.VALUE             := NULL;
      benefit.program_name      := in_program_name;

      rewards_mgt_util_pkg.p_compensate_reward_points( btrans => btrans,
                                                       benefit => benefit,
                                                       out_error_num => out_err_code,
                                                       out_error_message => out_err_msg );
      if out_err_code <> 0 then
        out_err_code := -305;
        out_err_msg  := 'Error. Unable to refund points for the passed Pin/Esn';
        raise validation_failed;
      end if;

     END IF; -- IF rec_points_for_trans.amount > 0 THEN
    END IF;
    --if cur_points_for_trans%found THEN

    CLOSE cur_points_for_trans;

  END IF;
  --IF cur_card_in_queue = 'Y' THEN

  exception
  WHEN validation_failed THEN
  --Modified for CR41118
   out_err_msg:='Error_code: '||out_err_code||' Error_msg: '||out_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
    --sa.ota_util_pkg.err_log ( p_action => 'VALIDATION FAILED', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'P_IS_PIN_REFUNDABLE', p_error_text => 'input params: ' || 'IN_ESN='||in_esn || ', IN_WEB_OBJID='|| in_web_account_id || ', IN_SERVICE_PLAN_PIN=' || in_service_plan_pin || ', out_error_code='||out_err_code || ', out_error_msg='|| out_err_msg );

  WHEN others THEN
    out_err_code := -99;
    out_err_msg  := 'P_IS_PIN_REFUNDABLE=' ||substr(sqlerrm, 1, 2000) || ' - ' ||dbms_utility.format_error_backtrace ;
    sa.ota_util_pkg.err_log ( p_action => 'OTHERS EXCEPTION', p_error_date => SYSDATE, p_key => 'LRP', p_program_name => 'P_IS_PIN_REFUNDABLE', p_error_text => 'input params: ' || 'IN_ESN='||in_esn || ', IN_WEB_OBJID='|| in_web_account_id || ', IN_SERVICE_PLAN_PIN=' || in_service_plan_pin || ', out_error_code='||out_err_code || ', out_error_msg='|| out_err_msg );
  END p_is_pin_refundable;

  FUNCTION country_code (ip_country_name IN VARCHAR2) RETURN VARCHAR2 IS
     CURSOR c1 IS
     SELECT * FROM sa.table_country
     WHERE s_name = upper(ip_country_name);

     r1 c1%rowtype;
     code VARCHAR2(20);

  BEGIN

     OPEN c1;
     fetch c1 INTO r1;
     IF c1%found THEN
        code:= r1.x_postal_code;
     ELSE
        code:=  ip_country_name;
     END IF;
     CLOSE c1;

     RETURN code;

  END;

PROCEDURE pre_processing(
    ip_purch_id   in varchar2,
    ip_purch_type in varchar2,
    ip_user_name  in varchar2,
    ip_source     in varchar2,
    ip_reason     in varchar2,
    ip_amount     in number,
    op_refund_id out varchar2,
    op_err_code out varchar2,
    op_err_msg out varchar2)
IS

 cursor user_cur
 is select objid,login_name
 from sa.table_user
 where upper(login_name) = upper(ip_user_name);

 user_rec user_cur%rowtype;

 cursor purch_hdr_cur is
 select * from sa.table_x_purch_hdr
 where objid = ip_purch_id;

 purch_hdr_rec purch_hdr_cur%rowtype;

 cursor existing_refund_cur is
 select objid
 from sa.table_x_purch_hdr
 where x_purch_hdr2cr_purch = ip_purch_id
 and ( X_ICS_RFLAG  in ('SOK','ACCEPT') or X_ICS_RCODE in ('1','100'));

 existing_refund_rec existing_refund_cur%rowtype;

 cursor prog_purch_hdr_cur is
 select * from sa.x_program_purch_hdr
 where objid = ip_purch_id;

 prog_purch_hdr_rec  prog_purch_hdr_cur%rowtype;

 cursor existing_prog_refund_cur is
 select objid
 from sa.x_program_purch_hdr
 where purch_hdr2cr_purch = ip_purch_id
 and  ( X_ICS_RFLAG  in ('SOK','ACCEPT') or X_ICS_RCODE in ('1','100'));

 existing_prog_refund_rec existing_prog_refund_cur%rowtype;

  ------------------------------------------------------------------------------
  -- NEW B2B
  ------------------------------------------------------------------------------
  cursor biz_purch_hdr_cur(ip_purch_id varchar2)
  is
  select *
  from   sa.x_biz_purch_hdr
  where  c_orderid = ip_purch_id
  and    x_rqst_type in ('CREDITCARD_PURCH','PURCHASE')
  and    x_ics_rcode in ('1','100')
  and    x_payment_type = 'SETTLEMENT';

  biz_purch_hdr_rec biz_purch_hdr_cur%rowtype;

  cursor existing_biz_refund_cur(ip_purch_id varchar2)
  is
  select objid
  from   sa.x_biz_purch_hdr hd
  where  1=1
  and    hd.x_payment_type = 'REFUND'
  and    x_ics_rcode in ('1','100')
  and    hd.c_orderid = ip_purch_id;

  existing_biz_refund_rec existing_biz_refund_cur%rowtype;
  ------------------------------------------------------------------------------
  -- new cursor for CR32367
  cursor purch_pins(ip_purch_id varchar2)
  is
  select pdtl.x_red_card_number
  from sa.table_x_purch_dtl pdtl
  where pdtl.x_purch_dtl2x_purch_hdr = ip_purch_id
  and pdtl.x_red_card_number is not null;

  ------------------------------------------------------------------------------

 v_objid number;
 v_full_refund varchar2(100) := 'false';
 v_total_tax number;
 v_amount number;
 n_next_refund number;
 v_bill_country varchar2(20);
 v_bill_state varchar2(40);
 v_failed_refund_count number;

BEGIN

  if ip_reason is null then
     op_err_code:='5';
     op_err_msg:='ERROR: Reason must be selected';
     return;
  end if;


  if ip_purch_type <> 'CC_REFUND' and ip_purch_type <> 'BILLING_REFUND' and ip_purch_type <> 'BIZ_REFUND' then
     op_err_code:='10';
     op_err_msg:='ERROR: Invalid Purchase Type';
     return;
  end if;

  if nvl(ip_amount,0) < 0.01 and ip_purch_type <> 'BIZ_REFUND' then
     op_err_code:='15';
     op_err_msg:='ERROR: Credit Amount must not be blank or less than a penny';
     return;
  end if;


  if ip_purch_id is null then
     op_err_code:='20';
     op_err_msg:='ERROR: Invalid Purchase Id';
     return;
  end if;

  open user_cur;
  fetch user_cur into user_rec;
  if user_cur%notfound then
     close user_cur;
     op_err_code:='25';
     op_err_msg:='ERROR: Invalid User Name';
     return;
  else
     close user_cur;
  end if;

  if ip_purch_type = 'CC_REFUND' then
     open purch_hdr_cur;
     fetch purch_hdr_cur into purch_hdr_rec;
     if purch_hdr_cur%found then
        close purch_hdr_cur;
        if ( purch_hdr_rec.X_ICS_RFLAG in ('SOK','ACCEPT') or purch_hdr_rec.X_ICS_RCODE in ('1','100')) then
           --CR32367 Check if PINs can be refunded.
           for rec in purch_pins(purch_hdr_rec.objid) loop
               if not(sa.reward_benefits_n_vouchers_pkg.f_is_pin_refundable(rec.x_red_card_number)) then
                  op_err_code:='27';
                  op_err_msg:='ERROR: The customer has used the points earned for the pin card associated with the selected transaction.  Cannot issue a credit';
               end if;
           end loop;
           if nvl(op_err_code,'0') = '27' then
              return;
           end if;
        else
           op_err_code:='30';
           op_err_msg:='ERROR: The selected transaction was not a successful purchase.  Cannot issue a credit';
           return;
        end if;
        if purch_hdr_rec.x_amount <0 then
           op_err_code:='40';
           op_err_msg:='ERROR: selected row is a CREDIT transaction; No additional credit will be issued';
           return;
        end if;
        if ip_amount > purch_hdr_rec.x_auth_amount then
           op_err_code:='50';
           op_err_msg:='ERROR: amount of credit cannot exceed amount of original purchas';
           return;
        end if;
        if (sysdate - purch_hdr_rec.x_rqst_date) > 180 then
           op_err_code:='60';
           op_err_msg:='ERROR: transaction is >= 180 days old.  No credit will be issued.';
           return;
        end if;

        if ip_amount = purch_hdr_rec.x_auth_amount then
           v_full_refund := 'true';
        end if;

        open existing_refund_cur;
        fetch existing_refund_cur into existing_refund_rec;
        if existing_refund_cur%found then
          close existing_refund_cur;
           op_err_code:='70';
           op_err_msg:='ERROR: credit was previously issued on this transaction. No additional credit will be issued';
           return;
        else
          close existing_refund_cur;
        end if;

        select count(*)
        into v_failed_refund_count
        from sa.table_x_purch_hdr
        where x_purch_hdr2cr_purch = ip_purch_id;

        --conver country name into country code if applicable
        if purch_hdr_rec.x_bill_country = 'USA' and purch_hdr_rec.x_bill_state = 'PR' then
           v_bill_state:=null;
           v_bill_country:='PR';
        else
           v_bill_state:=purch_hdr_rec.x_bill_state;
           v_bill_country:=country_code(purch_hdr_rec.x_bill_country);
        end if;
        -- end country code conversion

        select sa.seq('x_purch_hdr') into v_objid from dual;

        insert into sa.table_x_purch_hdr
          (
            objid,
            x_rqst_source,
            x_rqst_type,
            x_rqst_date,
            x_ics_applications,
            x_merchant_id,
            x_merchant_ref_number,
            x_offer_num,
            x_quantity,
            x_merchant_product_sku,
            x_product_name,
            x_product_code,
            x_ignore_bad_cv,
            x_ignore_avs,
            x_user_po,
            x_avs,
            x_disable_avs,
            x_customer_hostname,
            x_customer_ipaddress,
            x_auth_request_id,
            x_auth_code,
            x_auth_type,
            x_ics_rcode,
            x_ics_rflag,
            x_ics_rmsg,
            x_request_id,
            x_auth_avs,
            x_auth_response,
            x_auth_time,
            x_auth_rcode,
            x_auth_rflag,
            x_auth_rmsg,
            x_auth_cv_result,
            x_score_factors,
            x_score_host_severity,
            x_score_rcode,
            x_score_rflag,
            x_score_rmsg,
            x_score_result,
            x_score_time_local,
            x_bill_request_time,
            x_bill_rcode,
            x_bill_rflag,
            x_bill_rmsg,
            x_bill_trans_ref_no,
            x_customer_cc_number,
            x_customer_cc_expmo,
            x_customer_cc_expyr,
            x_customer_cc_cv_number,
            x_customer_firstname,
            x_customer_lastname,
            x_customer_phone,
            x_customer_email,
            x_bank_num,
            x_customer_acct,
            x_routing,
            x_aba_transit,
            x_bank_name,
            x_status,
            x_bill_address1,
            x_bill_address2,
            x_bill_city,
            x_bill_state,
            x_bill_zip,
            x_bill_country,
            x_esn,
            x_cc_lastfour,
            x_amount,
            x_tax_amount,
            x_auth_amount,
            x_bill_amount,
            x_user,
            x_purch_hdr2creditcard,
            x_purch_hdr2bank_acct,
            x_purch_hdr2contact,
            x_purch_hdr2user,
            x_purch_hdr2esn,
            x_purch_hdr2x_rmsg_codes,
            x_purch_hdr2cr_purch ,
            x_credit_code,
            x_credit_reason,
            x_e911_amount,
            x_shipping_cost,
            x_usf_taxamount,
            x_rcrf_tax_amount,
            x_discount_amount,
            x_total_tax
          )
          values
          (
            v_objid,
            ip_source,
            'cc_refund',
            sysdate,
            'ics_credit', --'ics_auth, ics_bill',
            purch_hdr_rec.x_merchant_id,
            purch_hdr_rec.x_merchant_ref_number||'_CR'||v_failed_refund_count,
            purch_hdr_rec.x_offer_num,
            purch_hdr_rec.x_quantity,
            null, --x_merchant_product_sku,
            null, --x_product_name,
            null, --x_product_code,
            'YES', --x_ignore_bad_cv,
            'YES', --x_ignore_avs,
            null, --x_user_po,
            null, --x_avs,
            'FALSE', --x_disable_avs,
            null, --x_customer_hostname,
            purch_hdr_rec.x_customer_ipaddress,
            null, --x_auth_request_id,
            null, --x_auth_code,
            null, --x_auth_type,
            null, --x_ics_rcode,
            null, --x_ics_rflag,
            null, --x_ics_rmsg,
            null, --x_request_id,
            null, --x_auth_avs,
            null, --x_auth_response,
            null, --x_auth_time,
            null, --x_auth_rcode,
            null, --x_auth_rflag,
            null, --x_auth_rmsg,
            null, --x_auth_cv_result,
            null, --x_score_factors,
            null, --x_score_host_severity,
            null, --x_score_rcode,
            null, --x_score_rflag,
            null, --x_score_rmsg,
            null, --x_score_result,
            null, --x_score_time_local,
            null, --x_bill_request_time,
            null, --x_bill_rcode,
            null, --x_bill_rflag,
            null, --x_bill_rmsg,
            null, --x_bill_trans_ref_no,
            purch_hdr_rec.x_customer_cc_number,
            purch_hdr_rec.x_customer_cc_expmo,
            purch_hdr_rec.x_customer_cc_expyr,
            purch_hdr_rec.x_customer_cc_cv_number,
            purch_hdr_rec.x_customer_firstname,
            purch_hdr_rec.x_customer_lastname,
            purch_hdr_rec.x_customer_phone,
            purch_hdr_rec.x_customer_email,
            purch_hdr_rec.x_bank_num,
            purch_hdr_rec.x_customer_acct,
            purch_hdr_rec.x_routing,
            purch_hdr_rec.x_aba_transit,
            purch_hdr_rec.x_bank_name,
            purch_hdr_rec.x_status,
            purch_hdr_rec.x_bill_address1,
            purch_hdr_rec.x_bill_address2,
            purch_hdr_rec.x_bill_city,
            v_bill_state,
            purch_hdr_rec.x_bill_zip,
            v_bill_country,
            purch_hdr_rec.x_esn,
            purch_hdr_rec.x_cc_lastfour,
            decode(v_full_refund,'true',purch_hdr_rec.x_amount,ip_amount)*(-1), --x_amount,
            decode(v_full_refund,'true',purch_hdr_rec.x_tax_amount,0)*(-1), --x_tax_amount,
            null, --x_auth_amount,
            null, --x_bill_amount,
            upper(ip_user_name), --x_user,
            purch_hdr_rec.x_purch_hdr2creditcard,
            purch_hdr_rec.x_purch_hdr2bank_acct,
            purch_hdr_rec.x_purch_hdr2contact,
            user_rec.objid, --x_purch_hdr2user,
            purch_hdr_rec.x_purch_hdr2esn,
            purch_hdr_rec.x_purch_hdr2x_rmsg_codes,
            ip_purch_id, --x_purch_hdr2cr_purch ,
            null, --x_credit_code,
            substr(trim(ip_reason),1,30), --x_credit_reason,
            decode(v_full_refund,'true',purch_hdr_rec.x_e911_amount,0)*(-1),  --x_e911_amount,
            decode(v_full_refund,'true',purch_hdr_rec.x_shipping_cost,0)*(-1),  --x_shipping_cost,
            decode(v_full_refund,'true',purch_hdr_rec.x_usf_taxamount,0)*(-1), --x_usf_taxamount,
            decode(v_full_refund,'true',purch_hdr_rec.x_rcrf_tax_amount,0)*(-1),  --x_rcrf_tax_amount,
            decode(v_full_refund,'true',purch_hdr_rec.x_discount_amount,0)*(-1),  --x_discount_amount,
            decode(v_full_refund,'true',purch_hdr_rec.x_total_tax,0)*(-1) --x_total_tax
          );

          commit;
          op_refund_id := v_objid;
          op_err_code:='0';
          op_err_msg:='SUCCESS: Refund request created.';
          return;

     else
        close purch_hdr_cur;
        op_err_code:='80';
        op_err_msg:='ERROR: Purchase record not found';
        return;

     end if;

  elsif ip_purch_type = 'BILLING_REFUND' then
     open prog_purch_hdr_cur;
     fetch prog_purch_hdr_cur into prog_purch_hdr_rec;
     if prog_purch_hdr_cur%found then
        close prog_purch_hdr_cur;
        if ( prog_purch_hdr_rec.X_ICS_RFLAG in ('SOK','ACCEPT') or prog_purch_hdr_rec.X_ICS_RCODE in ('1','100')) then
           null; --OK
        else
           op_err_code:='90';
           op_err_msg:='ERROR: The selected transaction was not a successful purchase.  Cannot issue a credit';
           return;
        end if;
        if prog_purch_hdr_rec.x_amount <0 then
           op_err_code:='100 ';
           op_err_msg:='ERROR: selected row is a CREDIT transaction; No additional credit will be issued';
           return;
        end if;
        if ip_amount > prog_purch_hdr_rec.x_auth_amount then
           op_err_code:='110';
           op_err_msg:='ERROR: amount of credit cannot exceed amount of original purchas';
           return;
        end if;
        if (sysdate - prog_purch_hdr_rec.x_rqst_date) > 180 then
           op_err_code:='120';
           op_err_msg:='ERROR: transaction is >= 180 days old.  No credit will be issued.';
           return;
        end if;

        open existing_prog_refund_cur;
        fetch existing_prog_refund_cur into existing_prog_refund_rec;
        if existing_prog_refund_cur%found then
          close existing_prog_refund_cur;
           op_err_code:='130';
           op_err_msg:='ERROR: credit was previously issued on this transaction. No additional credit will be issued';
           return;
        else
          close existing_prog_refund_cur;
        end if;


       select count(*)
       into v_failed_refund_count
       from sa.x_program_purch_hdr
       where purch_hdr2cr_purch = ip_purch_id;

        v_total_tax := nvl(prog_purch_hdr_rec.x_tax_amount,0)
                          + nvl(prog_purch_hdr_rec.x_e911_tax_amount,0)
                          + nvl(prog_purch_hdr_rec.x_usf_taxamount,0)
                          + nvl(prog_purch_hdr_rec.x_rcrf_tax_amount,0);

        dbms_output.put_line('v_total_tax: '||v_total_tax);
        dbms_output.put_line('ip_amount: '||ip_amount);
        dbms_output.put_line('purch_hdr_rec.x_amoun: '||prog_purch_hdr_rec.x_amount);

        if ip_amount = prog_purch_hdr_rec.x_amount+v_total_tax then
           v_full_refund := 'true';
           v_amount := ip_amount - v_total_tax;
        else
           v_amount := ip_amount;
        end if;

        --conver country name into country code if applicable
        if v_bill_country = 'USA' and prog_purch_hdr_rec.x_bill_state = 'PR' then
           v_bill_state:=null;
           v_bill_country:='PR';
        else
           v_bill_state:=prog_purch_hdr_rec.x_bill_state;
           v_bill_country:=country_code(prog_purch_hdr_rec.x_bill_country);
        end if;
        -- end country code conversion


        select seq_x_program_purch_hdr.nextval into v_objid from dual;


        INSERT
        INTO sa.x_program_purch_hdr
          ( objid,
            x_rqst_source,
            x_rqst_type,
            x_rqst_date,
            x_ics_applications,
            x_merchant_id,
            x_merchant_ref_number,
            x_offer_num,
            x_quantity,
            x_merchant_product_sku,
            x_payment_line2program,
            x_product_code,
            x_ignore_avs,
            x_user_po,
            x_avs,
            x_disable_avs,
            x_customer_hostname,
            x_customer_ipaddress,
            x_auth_request_id,
            x_auth_code,
            x_auth_type,
            x_ics_rcode,
            x_ics_rflag,
            x_ics_rmsg,
            x_request_id,
            x_auth_avs,
            x_auth_response,
            x_auth_time,
            x_auth_rcode,
            x_auth_rflag,
            x_auth_rmsg,
            x_bill_request_time,
            x_bill_rcode,
            x_bill_rflag,
            x_bill_rmsg,
            x_bill_trans_ref_no,
            x_customer_firstname,
            x_customer_lastname,
            x_customer_phone,
            x_customer_email,
            x_status,
            x_bill_address1,
            x_bill_address2,
            x_bill_city,
            x_bill_state,
            x_bill_zip,
            x_bill_country,
            x_esn,
            x_amount,
            x_tax_amount,
            x_auth_amount,
            x_bill_amount,
            x_user,
            purch_hdr2creditcard,
            purch_hdr2bank_acct,
            purch_hdr2user,
            purch_hdr2esn,
            purch_hdr2rmsg_codes,
            purch_hdr2cr_purch,
            x_credit_code,
            x_e911_tax_amount,
            x_usf_taxamount,
            x_rcrf_tax_amount,
            x_discount_amount,
            prog_hdr2x_pymt_src,
            prog_hdr2web_user,
            prog_hdr2prog_batch,
            x_payment_type,
            x_process_date,
            x_priority --,
            --x_credit_reason
            )
          VALUES
          ( v_objid,
          ip_source, --x_rqst_source,
          'CREDITCARD_REFUND', --x_rqst_type,
          sysdate, --x_rqst_date,
          'ics_credit', --'ics_auth, ics_bill', --x_ics_applications,
          prog_purch_hdr_rec.x_merchant_id,
          prog_purch_hdr_rec.x_merchant_ref_number||'_CR'||v_failed_refund_count,
          prog_purch_hdr_rec.x_offer_num,
          prog_purch_hdr_rec.x_quantity,
          null, --x_merchant_product_sku,
          null, --x_payment_line2program,
          null, --x_product_code,
          'YES', --x_ignore_avs,
          null, --x_user_po,
          null, --x_avs,
          'FALSE', --x_disable_avs,
          null, --x_customer_hostname,
          prog_purch_hdr_rec.x_customer_ipaddress,
          null, --x_auth_request_id,
          null, --x_auth_code,
          null, --x_auth_type,
          null, --x_ics_rcode,
          null, --x_ics_rflag,
          null, --x_ics_rmsg,
          null, --x_request_id,
          null, --x_auth_avs,
          null, --x_auth_response,
          null, --x_auth_time,
          null, --x_auth_rcode,
          null, --x_auth_rflag,
          null, --x_auth_rmsg,
          null, --x_bill_request_time,
          null, --x_bill_rcode,
          null, --x_bill_rflag,
          null, --x_bill_rmsg,
          null, --x_bill_trans_ref_no,
          prog_purch_hdr_rec.x_customer_firstname,
          prog_purch_hdr_rec.x_customer_lastname,
          prog_purch_hdr_rec.x_customer_phone,
          prog_purch_hdr_rec.x_customer_email,
          prog_purch_hdr_rec.x_status,
          prog_purch_hdr_rec.x_bill_address1,
          prog_purch_hdr_rec.x_bill_address2,
          prog_purch_hdr_rec.x_bill_city,
          v_bill_state,
          prog_purch_hdr_rec.x_bill_zip,
          v_bill_country,
          prog_purch_hdr_rec.x_esn,
          v_amount*-1, --x_amount,
          decode(v_full_refund,'true',nvl(prog_purch_hdr_rec.x_tax_amount,0),0)*(-1), -- round((prog_purch_hdr_rec.x_tax_amount/prog_purch_hdr_rec.x_auth_amount)*(ip_amount * -1),2), -- x_tax_amount,
          null, --x_auth_amount,
          null, --x_bill_amount,
          upper(ip_user_name), --x_user,
          prog_purch_hdr_rec.purch_hdr2creditcard,
          prog_purch_hdr_rec.purch_hdr2bank_acct,
          user_rec.objid, --purch_hdr2user,
          prog_purch_hdr_rec.purch_hdr2esn,
          prog_purch_hdr_rec.purch_hdr2rmsg_codes,
          ip_purch_id, --purch_hdr2cr_purch,
          null, --x_credit_code,
          decode(v_full_refund,'true',nvl(prog_purch_hdr_rec.x_e911_tax_amount,0),0)*(-1), --x_e911_tax_amount,
          decode(v_full_refund,'true',nvl(prog_purch_hdr_rec.x_usf_taxamount,0),0)*(-1), --x_usf_taxamount,
          decode(v_full_refund,'true',nvl(prog_purch_hdr_rec.x_rcrf_tax_amount,0),0)*(-1), --x_rcrf_tax_amount,
          decode(v_full_refund,'true',nvl(prog_purch_hdr_rec.x_discount_amount,0),0)*(-1), --x_discount_amount,
          prog_purch_hdr_rec.prog_hdr2x_pymt_src,
          prog_purch_hdr_rec.prog_hdr2web_user,
          null, --prog_hdr2prog_batch,
          'REFUND', --x_payment_type,
          sysdate, --x_process_date,
          null --, --x_priority
          --ip_reason --x_credit_reason
          );

          commit;
          op_refund_id := v_objid;
          op_err_code:='0';
          op_err_msg:='SUCCESS: Refund request created.';
          return;

     else
        close purch_hdr_cur;
        op_err_code:='140';
        op_err_msg:='ERROR: Purchase record not found';
        return;

     end if;
  ------------------------------------------------------------------------------
  -- NEW B2B
  ------------------------------------------------------------------------------
  elsif ip_purch_type = 'BIZ_REFUND' then
      open biz_purch_hdr_cur(ip_purch_id => ip_purch_id);
      fetch biz_purch_hdr_cur into biz_purch_hdr_rec;
      if biz_purch_hdr_cur%found then
        if (biz_purch_hdr_rec.x_ics_rcode in ('1','100')) then
           null; --OK
        else
           op_err_code:='150';
           op_err_msg:='ERROR: The selected transaction was not a successful purchase.  Cannot issue a credit';
           return;
        end if;
        if (sysdate - biz_purch_hdr_rec.x_rqst_date) > 180 then
           op_err_code:='160';
           op_err_msg:='ERROR: transaction is >= 180 days old.  No credit will be issued.';
           return;
        end if;

--        open existing_biz_refund_cur(ip_purch_id => ip_purch_id);
--        fetch existing_biz_refund_cur into existing_biz_refund_rec;
--          if existing_biz_refund_cur%found then
--            close existing_biz_refund_cur;
--            op_err_code:='70';
--            op_err_msg:='ERROR: credit was previously issued on this transaction. No additional credit will be issued';
--            return;
--          else
--            close existing_biz_refund_cur;
--          end if;

          --conver country name into country code if applicable
          if biz_purch_hdr_rec.x_bill_country = 'USA' and biz_purch_hdr_rec.x_bill_state = 'PR' then
             v_bill_state:=null;
             v_bill_country:='PR';
          else
             v_bill_state:=biz_purch_hdr_rec.x_bill_state;
             v_bill_country:=country_code(biz_purch_hdr_rec.x_bill_country);
          end if;
          -- end country code conversion


          select sa.sequ_biz_purch_hdr.nextval
          into v_objid
          from dual;

          select count(*)
          into n_next_refund
          from sa.x_biz_purch_hdr
          where c_orderid = ip_purch_id;

          insert into x_biz_purch_hdr
            (objid,
             x_promo_code,
             x_auth_rcode,
             x_auth_rflag,
             x_auth_rmsg,
             x_bill_request_time,
             x_bill_rcode,
             x_bill_rflag,
             x_bill_rmsg,
             x_bill_trans_ref_no,
             x_score_rcode,
             x_score_rflag,
             x_score_rmsg,
             x_customer_firstname,
             x_customer_lastname,
             x_customer_phone,
             x_customer_email,
             x_status,
             x_bill_address1,
             x_bill_address2,
             x_bill_city,
             x_bill_state,
             x_bill_zip,
             x_bill_country,
             x_ship_address1,
             x_ship_address2,
             x_ship_city,
             x_ship_state,
             x_ship_zip,
             x_ship_country,
             x_esn,
             x_amount,
             x_tax_amount,
             x_sales_tax_amount,
             x_e911_tax_amount,
             x_usf_taxamount,
             x_rcrf_tax_amount,
             x_add_tax1,
             x_add_tax2,
             discount_amount,
             freight_amount,
             x_auth_amount,
             x_bill_amount,
             x_user,
             purch_hdr2creditcard,
             purch_hdr2bank_acct,
             purch_hdr2other_funds,
             prog_hdr2x_pymt_src,
             prog_hdr2web_user,
             x_payment_type,
             x_process_date,
             x_rqst_source,
             channel,
             ecom_org_id,
             order_type,
             c_orderid,
             account_id,
             x_auth_request_id,
             groupidentifier,
             x_rqst_type,
             x_rqst_date,
             x_ics_applications,
             x_merchant_id,
             x_merchant_ref_number, x_offer_num, x_quantity, x_ignore_avs, x_avs, x_disable_avs, x_customer_hostname, x_customer_ipaddress,
             x_auth_code,
             x_ics_rcode,
             x_ics_rflag,
             x_ics_rmsg,
             x_request_id,
             x_auth_request_token,
             x_auth_avs,
             x_auth_response,
             x_auth_time,
             x_credit_reason)
          values
            (v_objid,
             biz_purch_hdr_rec.x_promo_code, -- NOT SURE
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             null,
             biz_purch_hdr_rec.x_customer_firstname,
             biz_purch_hdr_rec.x_customer_lastname,
             biz_purch_hdr_rec.x_customer_phone,
             biz_purch_hdr_rec.x_customer_email,
             'PENDING', --x_status,
             biz_purch_hdr_rec.x_bill_address1,
             biz_purch_hdr_rec.x_bill_address2,
             biz_purch_hdr_rec.x_bill_city,
             v_bill_state,
             biz_purch_hdr_rec.x_bill_zip,
             v_bill_country,
             biz_purch_hdr_rec.x_ship_address1,
             biz_purch_hdr_rec.x_ship_address2,
             biz_purch_hdr_rec.x_ship_city,
             biz_purch_hdr_rec.x_ship_state,
             biz_purch_hdr_rec.x_ship_zip,
             biz_purch_hdr_rec.x_ship_country,
             biz_purch_hdr_rec.x_esn,
             null, --decode(v_full_refund,'true',biz_purch_hdr_rec.x_amount,ip_amount)*(-1), --x_amount,  -- ADOPTED LOGIC FROM TAS (REMOVED VALIDATION AFTER DISCUSSING W/NATALIO)
             null, --decode(v_full_refund,'true',biz_purch_hdr_rec.x_tax_amount,0)*(-1), --x_tax_amount,  -- ADOPTED LOGIC FROM TAS (REMOVED VALIDATION AFTER DISCUSSING W/NATALIO)
             null, --biz_purch_hdr_rec.x_sales_tax_amount, -- PER PAUL LTAIF REMOVE
             null, --decode(v_full_refund,'true',biz_purch_hdr_rec.x_e911_tax_amount,0)*(-1),  --x_e911_tax_amount, -- ADOPTED LOGIC FROM TAS (REMOVED VALIDATION AFTER DISCUSSING W/NATALIO)
             null, --decode(v_full_refund,'true',biz_purch_hdr_rec.x_usf_taxamount,0)*(-1), --x_usf_taxamount, -- ADOPTED LOGIC FROM TAS (REMOVED VALIDATION AFTER DISCUSSING W/NATALIO)
             null, --decode(v_full_refund,'true',biz_purch_hdr_rec.x_rcrf_tax_amount,0)*(-1),  --x_rcrf_tax_amount, -- ADOPTED LOGIC FROM TAS  (REMOVED VALIDATION AFTER DISCUSSING W/NATALIO)
             biz_purch_hdr_rec.x_add_tax1,
             biz_purch_hdr_rec.x_add_tax2,
             null, --decode(v_full_refund,'true',biz_purch_hdr_rec.discount_amount,0)*(-1),  --x_discount_amount, -- ADOPTED LOGIC FROM TAS  (REMOVED VALIDATION AFTER DISCUSSING W/NATALIO)
             null, --decode(v_full_refund,'true',biz_purch_hdr_rec.freight_amount,0)*(-1),  --x_shipping_cost, -- ADOPTED LOGIC FROM TAS  (REMOVED VALIDATION AFTER DISCUSSING W/NATALIO)
             null, --x_auth_amount,
             null, --x_bill_amount,
             upper(ip_user_name), --x_user,
             biz_purch_hdr_rec.purch_hdr2creditcard,
             biz_purch_hdr_rec.purch_hdr2bank_acct,
             biz_purch_hdr_rec.purch_hdr2other_funds,
             biz_purch_hdr_rec.prog_hdr2x_pymt_src,
             biz_purch_hdr_rec.prog_hdr2web_user,
             'REFUND', -- x_payment_type,
             biz_purch_hdr_rec.x_process_date,
             ip_source, -- x_rqst_source,
             biz_purch_hdr_rec.channel,
             biz_purch_hdr_rec.ecom_org_id,
             biz_purch_hdr_rec.order_type,
             biz_purch_hdr_rec.c_orderid,
             biz_purch_hdr_rec.account_id,
             biz_purch_hdr_rec.x_auth_request_id,
             biz_purch_hdr_rec.groupidentifier,
             'CREDITCARD_REFUND', -- x_rqst_type -- (REFUND IS WHAT I FOUND IN SCI, cc_refund IS WHAT WE USED IN THE PAST)
             sysdate, -- x_rqst_date,
             'ics_credit', --x_ics_applications, -- (WHAT WE USED IN TAS 'ics_credit', --'ics_auth, ics_bill',)
             biz_purch_hdr_rec.x_merchant_id,
             biz_purch_hdr_rec.x_merchant_ref_number||'_CR'||n_next_refund, --biz_purch_hdr_rec.x_merchant_ref_number, -- WATCH NOT TO VALIDATE INDEX
             biz_purch_hdr_rec.x_offer_num,
             biz_purch_hdr_rec.x_quantity,
             'YES', -- x_ignore_avs,
             biz_purch_hdr_rec.x_avs,
             'FALSE', -- x_disable_avs,
             biz_purch_hdr_rec.x_customer_hostname,
             biz_purch_hdr_rec.x_customer_ipaddress,
             null,
             null,
             null,
             null,
             null,
             biz_purch_hdr_rec.x_auth_request_token, -- NOT SURE
             null,
             null,
             null,
             substr(trim(ip_reason),1,50) --x_credit_reason
             );

            commit;
            -- no column for total tax in x_biz_purch_hdr decode(v_full_refund,'true',purch_hdr_rec.x_total_tax,0)*(-1) --x_total_tax
            op_refund_id := v_objid;
            op_err_code:='0';
            op_err_msg:='SUCCESS: Refund request created.';
        return;
      end if;
  ------------------------------------------------------------------------------
  end if;

  exception
     when others then
          op_err_code:=SQLCODE;
          op_err_msg:='ERROR: '||substr(SQLERRM,1,3990);

END pre_processing;

procedure post_processing(
    ip_refund_id         in varchar2,
    ip_refund_type       in varchar2,
    ip_auth_request_id   in varchar2,
    ip_auth_code         in varchar2,
    ip_ics_rcode         in varchar2,
    ip_ics_rflag         in varchar2,
    ip_ics_rmsg          in varchar2,
    ip_request_id        in varchar2,
    ip_auth_avs          in varchar2,
    ip_auth_response     in varchar2,
    ip_auth_time         in varchar2,
    ip_auth_rcode        in varchar2,
    ip_auth_rflag        in varchar2,
    ip_auth_rmsg         in varchar2,
    ip_auth_cv_result    in varchar2,
    ip_score_factors     in varchar2,
    ip_scope_host_severity     in varchar2,
    ip_score_rcode       in varchar2,
    ip_score_rflag       in varchar2,
    ip_score_rmsg        in varchar2,
    ip_score_result      in varchar2,
    ip_score_time_local  in varchar2,
    ip_bill_request_time in varchar2,
    ip_bill_rcode        in varchar2,
    ip_bill_rflag        in varchar2,
    ip_bill_rmsg         in varchar2,
    ip_bill_trans_ref_no in varchar2,
    ip_auth_amount       in varchar2,
    ip_bill_amount       in varchar2,
    op_err_code          out varchar2,
    op_err_msg           out varchar2)
is

  n_penny_adjuster number := 0.00; -- INTRODUCED BECAUSE PARTIAL REFUNDS ARE ALWAYS OFF BY + .01

 cursor refund_hdr_cur is
 select *  from sa.table_x_purch_hdr
 where objid = ip_refund_id
 and x_rqst_type = 'cc_refund';

 refund_hdr_rec refund_hdr_cur%rowtype;

 cursor prog_refund_hdr_cur is
 select * from sa.x_program_purch_hdr
 where objid = ip_refund_id
 and x_rqst_type = 'CREDITCARD_REFUND';

 prog_refund_hdr_rec  prog_refund_hdr_cur%rowtype;

 cursor void_pins_cur (v_objid number) is
 select hdr.x_esn,dtl.x_red_card_number,dtl.x_smp,hdr.x_user
 from sa.table_x_purch_dtl dtl, sa.table_x_purch_hdr hdr
 where dtl.x_purch_dtl2x_purch_hdr= hdr.objid
 and hdr.objid = v_objid;

--------------------------------------------------------------------------------
-- NEW B2B
--------------------------------------------------------------------------------
  cursor biz_refund_hdr_cur(ip_refund_id varchar2)
  is
  select *
  from sa.x_biz_purch_hdr
  where objid = ip_refund_id
  and   x_rqst_type = 'CREDITCARD_REFUND';

  biz_refund_hdr_rec biz_refund_hdr_cur%rowtype;
--------------------------------------------------------------------------------


 v_result varchar2(300);
 v_points_flag boolean;
 v_error_num number;

 lv_reward_program_name x_reward_benefit_program.program_name%TYPE := 'LOYALTY_PROGRAM';
 lv_trans_type          x_reward_benefit_transaction.trans_type%TYPE := 'REDEMPTION';
 lv_benefit_type_code   x_reward_benefit_program.benefit_type_code%TYPE := 'LOYALTY_POINTS';
 lv_brand               x_reward_benefit_program.brand%TYPE;

  rc                                customer_type;
  cst                               customer_type;

BEGIN

  --Default Values
  op_err_code:='0';
  op_err_msg:='SUCCESS: Refund request updated.';
  --**************

  if ip_refund_type <> 'CC_REFUND' and ip_refund_type <> 'BILLING_REFUND' and ip_refund_type <> 'BIZ_REFUND' then
     op_err_code:='170';
     op_err_msg:='ERROR: Invalid Refund Type';
     return;
  end if;

  if ip_refund_id is null then
     op_err_code:='180';
     op_err_msg:='ERROR: Invalid Refund Id';
     return;
  end if;

  if ip_refund_type = 'CC_REFUND' then
     open refund_hdr_cur;
     fetch refund_hdr_cur into refund_hdr_rec;
     if refund_hdr_cur%found then
        close refund_hdr_cur;
        update sa.table_x_purch_hdr
        set x_auth_request_id   = ip_auth_request_id,
          x_auth_code           = ip_auth_code,
          x_ics_rcode           = ip_ics_rcode,
          x_ics_rflag           = ip_ics_rflag,
          x_ics_rmsg            = ip_ics_rmsg,
          x_request_id          = ip_request_id,
          x_auth_avs            = ip_auth_avs,
          x_auth_response       = ip_auth_response,
          x_auth_time           = ip_auth_time,
          x_auth_rcode          = ip_auth_rcode,
          x_auth_rflag          = ip_auth_rflag,
          x_auth_rmsg           = ip_auth_rmsg,
          x_auth_cv_result      = ip_auth_cv_result,
          x_score_factors       = ip_score_factors,
          x_score_host_severity = ip_scope_host_severity,
          x_score_rcode         = ip_score_rcode,
          x_score_rflag         = ip_score_rflag,
          x_score_rmsg          = ip_score_rmsg,
          x_score_result        = ip_score_result,
          x_score_time_local    = ip_score_time_local,
          x_bill_request_time   = ip_bill_request_time,
          x_bill_rcode          = ip_bill_rcode,
          x_bill_rflag          = ip_bill_rflag,
          x_bill_rmsg           = ip_bill_rmsg,
          x_bill_trans_ref_no   = ip_bill_trans_ref_no,
          x_auth_amount         = abs(ip_auth_amount)*-1,
          x_bill_amount         = abs(nvl(ip_bill_amount,ip_auth_amount))*-1
        where objid             = refund_hdr_rec.objid;

        if ( ip_ics_rflag in ('SOK','ACCEPT') or ip_ics_rcode in ('1','100')) then


            for void_pins_rec in void_pins_cur(refund_hdr_rec.x_purch_hdr2cr_purch) loop

             v_result := sa.ADFCRM_CARRIER.mark_card_invalid(p_reason => 'CC_REFUND',
                                                             p_esn => void_pins_rec.x_esn,
                                                             p_card_no => void_pins_rec.x_red_card_number,
                                                             p_snp => void_pins_rec.x_smp,
                                                             p_login_name => void_pins_rec.x_user);
               --CR32367 Remove the associated benefits
               sa.reward_benefits_n_vouchers_pkg.p_remove_pin_benefits  (
                        in_service_plan_pin       => void_pins_rec.x_red_card_number
                        ,out_err_code             => v_error_num
                        ,out_err_msg              => op_err_msg);
               if nvl(v_error_num,0) != 0 then
                  op_err_code:='185';
                  op_err_msg:='ERROR: '||nvl(v_error_num,0)||' '||op_err_msg;
               end if;

              --v_error_num:=0;
              --op_err_msg:='';


    --
    -- initializing the type to assign the esn
    rc := customer_type ( i_esn => void_pins_rec.x_esn );
    -- with the esn, this is getting all the information related to that esn
    cst := rc.retrieve;
--    dbms_output.put_line(cst.bus_org_id);

              P_IS_PIN_REFUNDABLE ( refund_hdr_rec.x_esn,
                                  null,--in_web_objid,
                                  void_pins_rec.x_red_card_number,
                                  lv_reward_program_name,
                                  lv_trans_type,
                                  lv_benefit_type_code,
                                  cst.bus_org_id,
                                  v_error_num,
                                  op_err_msg);

              IF nvl(v_error_num,0) != 0 THEN
                op_err_code :=  '186';
                op_err_msg  :=  'ERROR: '||nvl(op_err_code,0)||' '||op_err_msg;
              END IF;

            END LOOP;

            if nvl(op_err_code,'0') in ('185','186') then
               return;
            end if;


            v_points_flag:= remove_reward_points(ip_purch_objid => refund_hdr_rec.x_purch_hdr2cr_purch,
                                                ip_esn => refund_hdr_rec.x_esn,
                                                ip_user_objid => refund_hdr_rec.x_purch_hdr2user );


        else
           op_err_code:='190';
           op_err_msg:='ERROR: '||ip_auth_rmsg;
        end if;
      else
        close refund_hdr_cur;
        op_err_code:='200';
        op_err_msg:='ERROR: CC Refund Not Found';
        return;
      end if;

  elsif  ip_refund_type = 'BILLING_REFUND' then
     open prog_refund_hdr_cur;
     fetch prog_refund_hdr_cur into prog_refund_hdr_rec;
     if prog_refund_hdr_cur%found then
        close prog_refund_hdr_cur;
        update sa.x_program_purch_hdr
        set x_auth_request_id   = ip_auth_request_id,
          x_auth_code           = ip_auth_code,
          x_ics_rcode           = ip_ics_rcode,
          x_ics_rflag           = ip_ics_rflag,
          x_ics_rmsg            = ip_ics_rmsg,
          x_request_id          = ip_request_id,
          x_auth_avs            = ip_auth_avs,
          x_auth_response       = ip_auth_response,
          x_auth_time           = ip_auth_time,
          x_auth_rcode          = ip_auth_rcode,
          x_auth_rflag          = ip_auth_rflag,
          x_auth_rmsg           = ip_auth_rmsg,
          x_bill_request_time   = ip_bill_request_time,
          x_bill_rcode          = ip_bill_rcode,
          x_bill_rflag          = ip_bill_rflag,
          x_bill_rmsg           = ip_bill_rmsg,
          x_bill_trans_ref_no   = ip_bill_trans_ref_no,
          x_auth_amount         = abs(ip_auth_amount)*-1,
          x_bill_amount         = abs(nvl(ip_bill_amount,ip_auth_amount))*-1
        where objid = prog_refund_hdr_rec.objid;

            --Temp Fix for Full Refund
           -- if ABS(ip_auth_amount) = ABS(refund_hdr_rec.x_amount) then
           --    update  sa.x_program_purch_hdr
           --    set x_auth_amount         = abs(refund_hdr_rec.x_amount + refund_hdr_rec.x_total_tax)*-1,
           --        x_bill_amount         = abs(refund_hdr_rec.x_amount + refund_hdr_rec.x_total_tax)*-1
           --    where OBJID = prog_refund_hdr_rec.objid;
           -- end if;
            --
        if ( ip_ics_rflag in ('SOK','ACCEPT') or ip_ics_rcode in ('1','100')) then
            -- Any logic associated to succesfull refund here
            v_points_flag:= remove_reward_points(ip_purch_objid => prog_refund_hdr_rec.purch_hdr2cr_purch,
                                                ip_esn => prog_refund_hdr_rec.x_esn,
                                                ip_user_objid => prog_refund_hdr_rec.purch_hdr2user );
        else
           op_err_code:='210';
           op_err_msg:='ERROR: '||ip_auth_rmsg;
        end if;

     else
        close prog_refund_hdr_cur;
        op_err_code:='220';
        op_err_msg:='ERROR: Billing Refund Not Found';
        return;

     end if;
  elsif ip_refund_type = 'BIZ_REFUND' then
--------------------------------------------------------------------------------
-- NEW B2B
--------------------------------------------------------------------------------
    open biz_refund_hdr_cur(ip_refund_id => ip_refund_id);
    fetch biz_refund_hdr_cur into biz_refund_hdr_rec;
    if biz_refund_hdr_cur%found then
      close biz_refund_hdr_cur;

      for i in (select sum(d.x_amount) x_amount,sum(d.x_sales_tax_amount) x_sales_tax_amount, sum(d.x_e911_tax_amount) x_e911_tax_amount, sum(d.x_usf_tax_amount) x_usf_tax_amount, sum(d.x_rcrf_tax_amount) x_rcrf_tax_amount,sum(d.x_total_tax_amount) total_tax_amount,sum(d.x_total_amount) x_total_amount
                from   sa.x_biz_order_dtl d
                where  d.x_ecom_order_number = biz_refund_hdr_rec.c_orderid
                )
      loop
        if to_number(trim(ip_auth_amount)) = i.x_total_amount then
          dbms_output.put_line('auth amount matches total amount from details.');
          update sa.x_biz_purch_hdr
          set x_auth_request_id   = ip_auth_request_id,
              x_auth_code         = ip_auth_code,
              x_ics_rcode         = ip_ics_rcode,
              x_ics_rflag         = ip_ics_rflag,
              x_ics_rmsg          = ip_ics_rmsg,
              x_request_id        = ip_request_id,
              x_auth_avs          = ip_auth_avs,
              x_auth_response     = ip_auth_response,
              x_auth_time         = ip_auth_time,
              x_auth_rcode        = ip_auth_rcode,
              x_auth_rflag        = ip_auth_rflag,
              x_auth_rmsg         = ip_auth_rmsg,
              x_score_rcode       = ip_score_rcode,
              x_score_rflag       = ip_score_rflag,
              x_score_rmsg        = ip_score_rmsg,
              x_bill_request_time = ip_bill_request_time,
              x_bill_rcode        = ip_bill_rcode,
              x_bill_rflag        = ip_bill_rflag,
              x_bill_rmsg         = ip_bill_rmsg,
              x_bill_trans_ref_no = ip_bill_trans_ref_no,
              x_auth_amount       = abs(ip_auth_amount)*-1, --
              x_bill_amount       = abs(nvl(ip_bill_amount,ip_auth_amount))*-1, --
              x_amount            = abs(i.x_amount)*-1, --
              x_tax_amount        = abs(i.total_tax_amount)*-1,  -- SAW THIS POSSIBLE ISSUE 8.28 AFTER ROLLOUT WAS MADE i.x_total_tax_amount COLUMN TO USE
              x_sales_tax_amount  = abs(i.x_sales_tax_amount)*-1, -- FIXED HERE
              x_e911_tax_amount   = abs(i.x_e911_tax_amount)*-1,
              x_usf_taxamount     = abs(i.x_usf_tax_amount)*-1,
              x_rcrf_tax_amount   = abs(i.x_rcrf_tax_amount)*-1
          where objid             = biz_refund_hdr_rec.objid;
        else
          dbms_output.put_line('auth amount does not match total amount from details.');
          update sa.x_biz_purch_hdr
          set x_auth_request_id   = ip_auth_request_id,
              x_auth_code         = ip_auth_code,
              x_ics_rcode         = ip_ics_rcode,
              x_ics_rflag         = ip_ics_rflag,
              x_ics_rmsg          = ip_ics_rmsg,
              x_request_id        = ip_request_id,
              x_auth_avs          = ip_auth_avs,
              x_auth_response     = ip_auth_response,
              x_auth_time         = ip_auth_time,
              x_auth_rcode        = ip_auth_rcode,
              x_auth_rflag        = ip_auth_rflag,
              x_auth_rmsg         = ip_auth_rmsg,
              x_score_rcode       = ip_score_rcode,
              x_score_rflag       = ip_score_rflag,
              x_score_rmsg        = ip_score_rmsg,
              x_bill_request_time = ip_bill_request_time,
              x_bill_rcode        = ip_bill_rcode,
              x_bill_rflag        = ip_bill_rflag,
              x_bill_rmsg         = ip_bill_rmsg,
              x_bill_trans_ref_no = ip_bill_trans_ref_no,
              x_auth_amount       = abs(ip_auth_amount-n_penny_adjuster)*-1,
              x_bill_amount       = abs(nvl(ip_bill_amount,ip_auth_amount-n_penny_adjuster))*-1,
              x_amount            = abs(ip_auth_amount-n_penny_adjuster)*-1,
              x_tax_amount        = 0,
              x_e911_tax_amount   = 0,
              x_usf_taxamount     = 0,
              x_rcrf_tax_amount   = 0
          where objid             = biz_refund_hdr_rec.objid;
        end if;
      end loop;

        if ( ip_ics_rflag in ('SOK','ACCEPT') or ip_ics_rcode in ('1','100')) then
            -- Any logic associated to succesfull refund here
            null;
        else
           op_err_code:='230';
           op_err_msg:='ERROR: '||ip_auth_rmsg;
        end if;

    end if;

  end if;
--------------------------------------------------------------------------------
  commit;


END;

  procedure add_item_to_refund (
        ip_hdr_objid in varchar2,
        ip_dtl_objid in varchar2,
        op_err_code  out varchar2,
        op_err_msg   out varchar2)
  is
    v_order_id sa.x_biz_purch_hdr.c_orderid%type;
  begin

    for i in (select objid,decode(x_ics_rcode,'1','false','100','false','true') is_eligible_for_refund,x_rqst_type,c_orderid
              from   sa.x_biz_purch_hdr
              where  1=1
              and    objid = ip_hdr_objid
              )
    loop
      v_order_id := i.c_orderid;

      if i.is_eligible_for_refund != 'true' and
         i.x_rqst_type in ('REFUND', 'CREDITCARD_REFUND') then
        op_err_code :='240';
        op_err_msg := 'Order Id has already been refunded.';
        return;
      end if;
      if i.x_rqst_type not in ('REFUND', 'CREDITCARD_REFUND') then
        op_err_code :='250';
        op_err_msg := 'Unable to add item, because Order Id is not eligible.';
        return;
      end if;
    end loop;

    for i in (select h.objid,decode(h.x_ics_rcode,'1','false','100','false','true') is_eligible_for_refund,h.x_rqst_type, d.x_ecom_order_number
              from   sa.x_biz_purch_hdr h,
                     sa.x_biz_order_dtl d
              where  1=1
              and    h.objid(+) = d.biz_order_dtl2biz_purch_hdr_cr
              and    d.objid = ip_dtl_objid
              )

    loop
      if i.x_ecom_order_number != v_order_id then
        op_err_code :='260';
        op_err_msg := 'The item you''re trying to add belongs to a different order.';
        return;
      end if;
      if i.is_eligible_for_refund != 'true' and
         i.x_rqst_type in ('REFUND', 'CREDITCARD_REFUND')
      then
        op_err_code :='270';
        op_err_msg := 'The item you''re trying to add belongs to an order that was already refunded.';
        return;
      end if;
    end loop;

    update sa.x_biz_order_dtl
    set biz_order_dtl2biz_purch_hdr_cr = ip_hdr_objid
    where objid = ip_dtl_objid;

    if sql%rowcount > 0 then
      op_err_code :='0';
      op_err_msg := 'Item added to refund';
    else
      op_err_code :='0';
      op_err_msg := 'Item was not updated';
    end if;

    commit;

  end add_item_to_refund;

  procedure remove_item_from_refund (
        ip_dtl_objid in varchar2,
        op_err_code  out varchar2,
        op_err_msg   out varchar2) is

  begin

    for i in (select h.objid,h.x_ics_rcode,h.x_rqst_type, d.x_ecom_order_number
              from   sa.x_biz_purch_hdr h,
                     sa.x_biz_order_dtl d
              where  1=1
              and    h.objid(+) = d.biz_order_dtl2biz_purch_hdr_cr
              and    d.objid = ip_dtl_objid
              )
    loop
      if i.x_ics_rcode in ('1','100') and
         i.x_rqst_type in ('REFUND', 'CREDITCARD_REFUND') then
        op_err_code :='280';
        op_err_msg := 'Item has already been refunded.';
        return;
      end if;
    end loop;

    update sa.x_biz_order_dtl
    set BIZ_ORDER_DTL2BIZ_PURCH_HDR_CR = null
    where objid = ip_dtl_objid;

    if sql%rowcount > 0 then
      op_err_code :='0';
      op_err_msg := 'Item removed from refund';
    else
      op_err_code :='0';
      op_err_msg := 'Item was not updated';
    end if;

    commit;

  end remove_item_from_refund;


  function remove_reward_points (ip_purch_objid in varchar2,
                                 ip_esn varchar2,
                                 ip_user_objid in varchar2) return boolean is

  v_purch_type varchar2(100);
  v_points number;
  v_category varchar2(30);
  v_error_code varchar2(30);
  v_error_msg varchar2(200);
  v_return varchar2(1000);
  v_contact_objid number;

  cursor part_inst_cur is
  select x_part_inst2contact from sa.table_part_inst
  where part_serial_no = ip_esn
  and x_domain = 'PHONES';

  part_inst_rec part_inst_cur%rowtype;

  begin


    sa.REWARD_POINTS_PKG.P_GET_POINTS_FOR_PURCH_TRANS(
    IN_PURCH_OBJID => ip_purch_objid,
    OUT_PURCH_TYPE => v_purch_type,
    OUT_POINTS => v_points,
    OUT_POINTS_CATEGORY => v_category,
    OUT_ERR_CODE => v_error_code,
    OUT_ERR_MSG => v_error_msg);

    if v_error_code = '0' and v_points>0 then

    open part_inst_cur;
    fetch part_inst_cur into part_inst_rec;
    if part_inst_cur%found then
       v_contact_objid:=part_inst_rec.x_part_inst2contact;
    end if;
    close part_inst_cur;

    v_Return := ADFCRM_CASE.COMPENSATE_REWARD_POINTS(
                              IP_ESN => ip_esn,
                              IP_ACTION => 'DEDUCT',
                              IP_POINTS => v_points,
                              ip_service_plan_objid => null,
                              IP_REASON => 'REFUND',
                              IP_NOTES => 'Refund Purchase Id: '||ip_purch_objid,
                              IP_CONTACT_OBJID => v_contact_objid,
                              IP_USER_OBJID => ip_user_objid);

    end if;
    return true;
  exception
    when others then
      return false;
  end remove_reward_points;
  --
PROCEDURE p_refund_for_pin (
                in_esn               IN   varchar2,
                in_svc_plan_pin      IN   varchar2,
                In_Program_Name  	   IN   varchar2, -- 'LOYALTY_PROGRAM'
                In_Benefit_Type 	   IN   varchar2, --'LOYALTY_POINTS'
                out_err_code         OUT  number,
                out_err_msg          OUT  varchar2)
IS
--
  l_awarded_points                  x_reward_benefit_transaction.amount%TYPE;
  btrans                            typ_lrp_benefit_trans;
  benefit                           typ_lrp_reward_benefit;
  bobjid                            x_reward_benefit.objid%TYPE;
  l_reward_trans_rec                x_reward_benefit_transaction%ROWTYPE;
  l_reward_benefit_trans_objid      x_reward_benefit_transaction.objid%TYPE;
  l_transaction_status              x_reward_benefit_transaction.transaction_status%type;     -- CR41473 PMistry 08/03/2016 LRP2
  l_action_notes                    x_reward_benefit_transaction.action_notes%TYPE;           -- CR41473 - LRP2
--
BEGIN
--
  -- Initialize BENEFIT TRANSACTION
  btrans := typ_lrp_benefit_trans();
  -- Initialize BENEFIT REWARD RECORD
  benefit := typ_lrp_reward_benefit ();
  --
  IF in_esn IS NULL OR  in_svc_plan_pin IS NULL
  THEN
    out_err_code  :=  100;
    out_err_msg   :=  'ESN or Service Plan Pin cannot be null';
    RETURN;
  END IF;
  --
  IF NVL(In_Program_Name,'X') <> 'LOYALTY_PROGRAM' OR  NVL(In_Benefit_Type,'X') <> 'LOYALTY_POINTS'
  THEN
    out_err_code  :=  110;
    out_err_msg   :=  'Invalid values for Program Name or Benefit type';
    RETURN;
  END IF;
  --
  BEGIN
    SELECT  SUM(amount)
    INTO    l_awarded_points
    FROM    x_reward_benefit_transaction
    WHERE   esn                 =   in_esn
    AND     SVC_PLAN_PIN        =   in_svc_plan_pin
    AND     BENEFIT_TYPE_CODE   =   In_Benefit_Type;
  EXCEPTION
    WHEN OTHERS THEN
      l_awarded_points  :=  0;
  END;
  --
  BEGIN
    SELECT  *
    INTO    l_reward_trans_rec
    FROM    x_reward_benefit_transaction
    WHERE   esn                 =   in_esn
    AND     SVC_PLAN_PIN        =   in_svc_plan_pin
    AND     BENEFIT_TYPE_CODE   =   In_Benefit_Type
    AND     ROWNUM              =   1;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  --CREATE BENEFIT TRANSACTION RECORD
  btrans.objid                       := 0;
  btrans.trans_date                  := SYSDATE;
  btrans.web_account_id              := l_reward_trans_rec.web_account_id;
  btrans.subscriber_id               := l_reward_trans_rec.subscriber_id;
  btrans.MIN                         := l_reward_trans_rec.min;
  btrans.esn                         := l_reward_trans_rec.esn;
  btrans.old_min                     := NULL;
  btrans.old_esn                     := NULL;
  btrans.trans_type                  := 'REFUND';
  btrans.trans_desc                  := 'PIN removed from Reserve'; --Modified for 2175
  btrans.amount                      := l_awarded_points * -1;
  btrans.benefit_type_code           := in_benefit_type;
  btrans.action                      := 'DEDUCT';
  btrans.action_type                 := 'FREE';
  btrans.action_reason               := 'PIN removed from Reserve'; --Modified for 2175
  btrans.action_notes                := NULL;
  btrans.benefit_trans2benefit_trans := NULL;
  btrans.svc_plan_pin                := in_svc_plan_pin;
  btrans.svc_plan_id                 := NULL;
  btrans.brand                       := l_reward_trans_rec.brand;
  btrans.benefit_trans2benefit       := NULL;
  btrans.agent_login_name			       := NULL;
  --
  --CREATE BENEFIT REWARD RECORD
  --
  benefit.objid             := 0;
  benefit.web_account_id    := l_reward_trans_rec.web_account_id;
  benefit.subscriber_id     := l_reward_trans_rec.subscriber_id;
  benefit.MIN               := NULL;
  benefit.esn               := NULL;
  benefit.benefit_owner     := 'ACCOUNT';
  benefit.created_date      := SYSDATE;
  benefit.status            := 'AVAILABLE';
  benefit.notes             := NULL;
  benefit.benefit_type_code := in_benefit_type;
  benefit.update_date       := NULL;
  benefit.expiry_date       := NULL;
  benefit.brand             := l_reward_trans_rec.brand;
  benefit.quantity          := NULL;
  benefit.VALUE             := NULL;
  benefit.program_name      := in_program_name;
  --
  rewards_mgt_util_pkg.p_create_benefit_trans( ben_trans => btrans,
                                                reward_benefit_trans_objid => l_reward_benefit_trans_objid,
                                                o_transaction_status => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.

  --
  bobjid      := rewards_mgt_util_pkg.f_get_cust_benefit_id ( 'ACCOUNT',
                                                              btrans.WEB_ACCOUNT_ID,
                                                              'LOYALTY_PROGRAM',
                                                              'LOYALTY_POINTS');
  --
  IF (trim(bobjid)            <> 0 )  THEN
    -- CR41473 08/11/2016 added deduction check if the customer is not having enough points to deduct from it's account.
    IF rewards_mgt_util_pkg.deduct_benefit_points( i_benefit_objid      => bobjid,
                                                   i_transaction_status => l_transaction_status,
                                                   i_points_to_deduct   => btrans.amount
                                                   )  = 'N' THEN
      --
      l_transaction_status := 'FAILED';
      l_action_notes       := 'Not enough qty to deduct';
    ELSE
      rewards_mgt_util_pkg.p_update_benefit(in_cust_key            =>  'OBJID',
                                            in_cust_value          =>  bobjid,
                                            in_program_name        =>  '',
                                            in_benefit_type        =>  '',
                                            in_brand               =>  '',
                                            in_new_min             =>  '',
                                            in_new_esn             =>  '',
                                            in_new_status          =>  benefit.status,
                                            in_new_notes           =>  '',
                                            in_new_expiry_date     =>  NULL,
                                            in_change_quantity     =>  btrans.amount,        -- CR41473-LRP2
                                            in_transaction_status  =>  l_transaction_status, -- CR41473-LRP2
                                            in_value               =>  NULL,
                                            in_account_status      =>  '');
    END IF;
  END IF;
  --
  UPDATE  x_reward_benefit_transaction rbt
  SET     rbt.benefit_trans2benefit = bobjid,
          rbt.transaction_status  = l_transaction_status,
          rbt.action_notes        = CASE WHEN l_transaction_status = 'FAILED' THEN
                                            l_action_notes
                                         ELSE
                                           rbt.action_notes
                                     END
  WHERE   rbt.objid                 = l_reward_benefit_trans_objid;
  --
  out_err_code  :=  0;
  out_err_msg   :=  'SUCCESS';
  --
EXCEPTION
  -- CR42235 Changes Starts
  WHEN DUP_VAL_ON_INDEX THEN
  out_err_code := -99;
  out_err_msg  := 'p_refund_for_pin ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
  -- CR42235 Changes Ends
  WHEN OTHERS THEN
    NULL;
END p_refund_for_pin;
--
PROCEDURE p_refund_for_charge_back (
                in_cust_key             in  varchar2, -- table_x_purch_hdr / x_biz_purch_hdr
                in_cust_value           IN  number, -- objid of table_x_purch_hdr / X_Biz_Purch_Hdr
                in_brand                IN  varchar2,
                in_program_name         IN  varchar2 ,-- 'LOYALTY_PROGRAM'
                in_benefit_type         IN  varchar2, --'LOYALTY_POINTS'
                in_partial_pymt_flag    IN  varchar2 DEFAULT 'N',
                in_partial_pymt_amount  IN  number, --- Only when partial flag = Y
                out_err_code            OUT number,
                out_err_msg             OUT varchar2)
IS
--
  l_red_code                        TABLE_X_RED_CARD.x_red_code%TYPE;
  l_reward_trans_rec                x_reward_benefit_transaction%ROWTYPE;
  l_prev_awarded_amount             NUMBER;
  btrans                            typ_lrp_benefit_trans;
  benefit                           typ_lrp_reward_benefit;
  bobjid                            x_reward_benefit.objid%TYPE;
  l_reward_benefit_trans_objid      x_reward_benefit_transaction.objid%TYPE;
  l_calculated_amount               NUMBER;
  l_esn                             table_x_purch_hdr.x_esn%TYPE;
  l_smp                             VARCHAR2(30);
  l_auth_amount                     NUMBER;

  l_transaction_status              x_reward_benefit_transaction.transaction_status%type;     -- CR41473 PMistry 08/03/2016 LRP2
  l_action_notes                    x_reward_benefit_transaction.action_notes%TYPE;           -- CR41473 - LRP2
--
BEGIN
  --
  -- Initialize BENEFIT TRANSACTION
  btrans := typ_lrp_benefit_trans();
  -- Initialize BENEFIT REWARD RECORD
  benefit := typ_lrp_reward_benefit ();
  --
  IF UPPER(NVL(in_cust_key,'X'))  NOT IN ('TABLE_X_PURCH_HDR','X_BIZ_PURCH_HDR')
  THEN
    out_err_code    :=  '100';
    out_err_msg     :=  'Invalid Cust key';
    RETURN;
  END IF;
  --
  IF in_cust_value <= 0
  THEN
    out_err_code    :=  '110';
    out_err_msg     :=  'Invalid in_cust_value';
    RETURN;
  END IF;
  --
  IF NVL(in_program_name,'X') <> 'LOYALTY_PROGRAM' OR  NVL(in_benefit_type,'X') <> 'LOYALTY_POINTS'
  THEN
    out_err_code  :=  110;
    out_err_msg   :=  'Invalid values for Program Name or Benefit type';
    RETURN;
  END IF;
  --
  IF UPPER(NVL(in_cust_key,'X'))  = ('TABLE_X_PURCH_HDR')
  THEN
    BEGIN
      SELECT  ph.X_ESN,
              pd.X_RED_CARD_NUMBER,
              pd.X_SMP,
              ph.X_AUTH_AMOUNT
      INTO    l_esn,
              l_red_code,
              l_smp,
              l_auth_amount
      FROM    sa.table_x_purch_hdr     ph,
              sa.TABLE_X_PURCH_DTL     pd
      WHERE   pd.X_PURCH_DTL2X_PURCH_HDR  = ph.objid
      AND     ph.objid                    = in_cust_value;
    EXCEPTION
      WHEN OTHERS THEN
        out_err_code  :=  120;
        out_err_msg   :=  'Invalid X_PURCH_HDR objid value';
        RETURN;
    END;
  ELSIF UPPER(NVL(in_cust_key,'X'))  = ('X_BIZ_PURCH_HDR')
  THEN
    BEGIN
      SELECT  ph.X_ESN,
              pd.SMP,
              ph.X_AUTH_AMOUNT
      INTO    l_esn,
              l_smp,
              l_auth_amount
      FROM    sa.x_biz_purch_hdr     ph,
              sa.x_biz_purch_DTL     pd
      WHERE   pd.BIZ_PURCH_DTL2BIZ_PURCH_HDR  = ph.objid
      AND     ph.objid                        = in_cust_value;
    EXCEPTION
      WHEN OTHERS THEN
        out_err_code  :=  130;
        out_err_msg   :=  'Invalid BIZ_PURCH_HDR objid value';
        RETURN;
    END;
  END IF;
  --
  BEGIN
    SELECT x_red_code
    INTO   l_red_code
    FROM   sa.TABLE_X_RED_CARD rc
    WHERE  rc.x_smp         =  l_smp
    AND    rc.x_red_code    IS NOT NULL
    AND    rc.objid         = ( SELECT  MAX(rc1.objid)
                                FROM    TABLE_X_RED_CARD rc1
                                WHERE   rc1.x_smp       =   rc.x_smp
                                AND     rc1.x_red_code  =   rc.x_red_code);
  EXCEPTION
    WHEN OTHERS THEN
      l_red_code  := NULL;
  END;
  --
  -- Get prev. awarded points
  BEGIN
    SELECT *
    INTO   l_reward_trans_rec
    FROM   x_reward_benefit_transaction
    WHERE  esn                  =  l_esn
    AND    SVC_PLAN_PIN         =  l_red_code
    AND    BENEFIT_TYPE_CODE    =  In_Benefit_Type
    AND    ROWNUM               =  1;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  --
  l_prev_awarded_amount   :=  l_reward_trans_rec.amount;
  --
  IF NVL(in_partial_pymt_flag,'N') = 'Y' AND in_partial_pymt_amount > 0
  THEN-- logic for partial payment
    l_calculated_amount :=   ROUND((in_partial_pymt_amount /l_auth_amount) * l_prev_awarded_amount);
  ELSE
    l_calculated_amount :=  l_prev_awarded_amount;
  END IF;
  --
  --CREATE BENEFIT TRANSACTION RECORD
  btrans.objid                       := 0;
  btrans.trans_date                  := SYSDATE;
  btrans.web_account_id              := l_reward_trans_rec.web_account_id;
  btrans.subscriber_id               := l_reward_trans_rec.subscriber_id;
  btrans.MIN                         := l_reward_trans_rec.min;
  btrans.esn                         := l_reward_trans_rec.esn;
  btrans.old_min                     := NULL;
  btrans.old_esn                     := NULL;
  btrans.trans_type                  := 'REFUND';
  btrans.trans_desc                  := 'AT Card Refund';  --Modified for 2175
  btrans.amount                      := l_calculated_amount * -1;
  btrans.benefit_type_code           := in_benefit_type;
  btrans.action                      := 'DEDUCT';
  btrans.action_type                 := 'FREE';
  btrans.action_reason               := 'AT Card Refund';
  btrans.action_notes                := NULL;
  btrans.benefit_trans2benefit_trans := NULL;
  btrans.svc_plan_pin                := l_red_code;
  btrans.svc_plan_id                 := NULL;
  btrans.brand                       := l_reward_trans_rec.brand;
  btrans.benefit_trans2benefit       := NULL;
  btrans.agent_login_name			       := NULL;
  --
  --CREATE BENEFIT REWARD RECORD
  --
  benefit.objid             := 0;
  benefit.web_account_id    := l_reward_trans_rec.web_account_id;
  benefit.subscriber_id     := l_reward_trans_rec.subscriber_id;
  benefit.MIN               := NULL;
  benefit.esn               := NULL;
  benefit.benefit_owner     := 'ACCOUNT';
  benefit.created_date      := SYSDATE;
  benefit.status            := 'AVAILABLE';
  benefit.notes             := NULL;
  benefit.benefit_type_code := in_benefit_type;
  benefit.update_date       := NULL;
  benefit.expiry_date       := NULL;
  benefit.brand             := l_reward_trans_rec.brand;
  benefit.quantity          := NULL;
  benefit.VALUE             := NULL;
  benefit.program_name      := in_program_name;
  --
  rewards_mgt_util_pkg.p_create_benefit_trans( ben_trans => btrans,
                                                  reward_benefit_trans_objid => l_reward_benefit_trans_objid,
                                                  o_transaction_status => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.

  --
  bobjid      := rewards_mgt_util_pkg.f_get_cust_benefit_id ( 'ACCOUNT',
                                                              btrans.WEB_ACCOUNT_ID,
                                                              'LOYALTY_PROGRAM',
                                                              'LOYALTY_POINTS');
  --
  IF (trim(bobjid)            <> 0 ) THEN
    -- CR41473 08/11/2016 added deduction check if the customer is not having enough points to deduct from it's account.
    IF rewards_mgt_util_pkg.deduct_benefit_points( i_benefit_objid      => bobjid,
                                                   i_transaction_status => l_transaction_status,
                                                   i_points_to_deduct   => btrans.amount
                                                   )  = 'N' THEN
      --
      l_transaction_status := 'FAILED';
      l_action_notes       := 'Not enough qty to deduct';
    ELSE
      rewards_mgt_util_pkg.p_update_benefit(in_cust_key            =>  'OBJID',
                                            in_cust_value          =>  bobjid,
                                            in_program_name        =>  '',
                                            in_benefit_type        =>  '',
                                            in_brand               =>  '',
                                            in_new_min             =>  '',
                                            in_new_esn             =>  '',
                                            in_new_status          =>  benefit.status,
                                            in_new_notes           =>  '',
                                            in_new_expiry_date     =>  NULL,
                                            in_change_quantity     =>  btrans.amount,        -- CR41473-LRP2
                                            in_transaction_status  =>  l_transaction_status, -- CR41473-LRP2
                                            in_value               =>  NULL,
                                            in_account_status      =>  '');
    END IF;
  END IF;
  --
  UPDATE  x_reward_benefit_transaction rbt
  SET     rbt.benefit_trans2benefit = bobjid,
          rbt.transaction_status  = l_transaction_status,
          rbt.action_notes        = CASE WHEN l_transaction_status = 'FAILED' THEN
                                            l_action_notes
                                         ELSE
                                           rbt.action_notes
                                     END
  WHERE   rbt.objid                 = l_reward_benefit_trans_objid;
  --
  out_err_code  :=  0;
  out_err_msg   :=  'SUCCESS';
  --
EXCEPTION
  -- CR42235 Changes Starts
  WHEN DUP_VAL_ON_INDEX THEN
  out_err_code := -99;
  out_err_msg  := 'p_refund_for_charge_back ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
  -- CR42235 Changes Ends
  WHEN OTHERS THEN
    out_err_code := -99;
    out_err_msg  := 'P_REFUND_FOR_CHARGE_BACK=' ||substr(sqlerrm, 1, 2000) || ' - ' ||dbms_utility.format_error_backtrace ;
    sa.ota_util_pkg.err_log ( p_action => 'OTHERS EXCEPTION',
                              p_error_date => SYSDATE,
                              p_key => in_cust_value,
                              p_program_name => 'P_REFUND_FOR_CHARGE_BACK',
                              p_error_text => 'input params: ' || 'in_cust_value='||in_cust_value || ', out_error_code='||out_err_code || ', out_error_msg='|| out_err_msg );
END p_refund_for_charge_back;
--
end rewards_refund_pkg;
/