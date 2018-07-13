CREATE OR REPLACE PACKAGE BODY sa.ADFCRM_REFUND_PKG
AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_REFUND_PKB.sql,v $
--$Revision: 1.66 $
--$Author: pkapaganty $
--$Date: 2018/01/31 22:16:22 $
--$ $Log: ADFCRM_REFUND_PKB.sql,v $
--$ Revision 1.66  2018/01/31 22:16:22  pkapaganty
--$ CR50452 Net 10 Remove Service for Refunds SmartPhone
--$
--$ Revision 1.65  2018/01/12 14:14:56  pkapaganty
--$ CR50452 Net 10 Remove Service for Refunds SmartPhone - Compile Error
--$
--$ Revision 1.64  2018/01/11 22:42:08  pkapaganty
--$ CR50452 Net 10 Remove Service for Refunds SmartPhone
--$
--$ Revision 1.63  2017/10/23 20:42:54  pkapaganty
--$ CR52723 Show invalidation of Pins for refund process
--$   Modified query to fetch Red Card numbers by avoiding duplicate red cards
--$
--$ Revision 1.62  2017/10/17 20:56:13  pkapaganty
--$ CR52723 Show invalidation of Pins for refund process
--$ 2 Bugs Fixed.
--$    1. Refund is not considering the discounted amount from transaction. This is production Defect.
--$    2. Multiple PIN details are not returned in fetch_airtime_card_info API.
--$
--$ Revision 1.61  2017/10/11 20:34:25  pkapaganty
--$ CR52723 Show invalidation of Pins for refund process
--$ Added function to retrieve Airtime Card PIN Status information
--$
--$ Revision 1.60  2017/06/07 18:24:31  pkapaganty
--$ Merging REL863 changes on top of REL862 for CR48979
--$
--$ Revision 1.59  2017/06/01 15:50:32  pkapaganty
--$ Mergind REL862 changes to REL861 changes
--$
--$ Revision 1.58  2017/06/01 14:48:21  pkapaganty
--$ REL861 - Fix to insert correct x_ics_applications value on proper refund type.
--$Revision: 1.66 $
--$Author: pkapaganty $
--$Date: 2018/01/31 22:16:22 $
--$ $Log: ADFCRM_REFUND_PKB.sql,v $
--$ Revision 1.66  2018/01/31 22:16:22  pkapaganty
--$ CR50452 Net 10 Remove Service for Refunds SmartPhone
--$
--$ Revision 1.65  2018/01/12 14:14:56  pkapaganty
--$ CR50452 Net 10 Remove Service for Refunds SmartPhone - Compile Error
--$
--$ Revision 1.64  2018/01/11 22:42:08  pkapaganty
--$ CR50452 Net 10 Remove Service for Refunds SmartPhone
--$
--$ Revision 1.63  2017/10/23 20:42:54  pkapaganty
--$ CR52723 Show invalidation of Pins for refund process
--$   Modified query to fetch Red Card numbers by avoiding duplicate red cards
--$
--$ Revision 1.62  2017/10/17 20:56:13  pkapaganty
--$ CR52723 Show invalidation of Pins for refund process
--$ 2 Bugs Fixed.
--$    1. Refund is not considering the discounted amount from transaction. This is production Defect.
--$    2. Multiple PIN details are not returned in fetch_airtime_card_info API.
--$
--$ Revision 1.61  2017/10/11 20:34:25  pkapaganty
--$ CR52723 Show invalidation of Pins for refund process
--$ Added function to retrieve Airtime Card PIN Status information
--$
--$ Revision 1.60  2017/06/07 18:24:31  pkapaganty
--$ Merging REL863 changes on top of REL862 for CR48979
--$
--$ Revision 1.57  2017/05/25 14:22:16  sravulapalli
--$ CR48979: support for refunding freight amount
--$ Revision 1.56  2017/05/19 15:23:56  pkapaganty
--$ CR46214 Issue with inserting of new Dtl record
--$
--$ Revision 1.55  2017/05/19 14:05:58  pkapaganty
--$ CR46214 - Added Error msgs in post processing
--$
--$ Revision 1.54  2017/05/18 23:12:03  pkapaganty
--$ CR46214 - updating rem balance cursor
--$
--$ Revision 1.53  2017/05/18 17:10:03  pkapaganty
--$ CR46214 - updated calculating remaining balance from B2B partial refund
--$
--$ Revision 1.52  2017/05/18 14:47:19  pkapaganty
--$ CR46214 B2BB2C Partial Refunds process in TAS

--$
--$ Revision 1.51  2017/05/16 00:43:59  pkapaganty
--$ CR46380 Net10 Business TAS Refund ACH - Enaling ACH in B2BRefunds
--$
--$ Revision 1.50  2017/05/11 20:09:11  pkapaganty
--$ CR43884 - To enable validation for ACH transaction to happen based on x_bill_amount
--$
--$ Revision 1.49  2017/02/16 15:22:58  mmunoz
--$ CR47567  checking rqst_type in uppercase
--$
--$ Revision 1.48  2017/02/15 20:42:07  mmunoz
--$ CR47567 In x_program_purch_hdr x_ics_applications should be ecp_credit (for ACH)  ics_credit (for CC)
--$
--$ Revision 1.47  2017/02/15 20:37:13  mmunoz
--$ CR47567 In x_program_purch_hdr x_ics_applications should be ecp_credit (for ACH)  ics_credit (for CC)
--$
--$ Revision 1.46  2016/12/06 17:43:24  mmunoz
--$ CR45711 :  Updated post_processing to add  ach_refund in cursors
--$
--$ Revision 1.45  2016/11/28 16:50:13  mmunoz
--$ CR45711 : Updated pre_processing.  purch_hdr2bank_acct > 1 since BIZ transactions save 0 when registering cc purchase
--$
--$ Revision 1.44  2016/11/28 15:11:00  mmunoz
--$ CR45711 : Updated pre_processing. ACH_REFUND whenever purch_hdr2bank_acct != 1 since WEB is saving 1 when registering cc purchase
--$
--$ Revision 1.43  2016/11/23 19:43:11  mmunoz
--$ CR45711 : Updated pre_processing to set x_rqst_type (during insert) as ACH_REFUND whenever purch_hdr2bank_acct is not null
--$
--------------------------------------------------------------------------------------------
  function country_code (ip_country_name in varchar2) return varchar2 is
     cursor c1 is
     select * from sa.table_country
     where s_name = upper(ip_country_name);

     r1 c1%rowtype;
     code varchar2(20);

  begin

     open c1;
     fetch c1 into r1;
     if c1%found then
        code:= r1.x_postal_code;
     else
        code:=  ip_country_name;
     end if;
     close c1;

     return code;

  end;

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
  and    x_rqst_type in ('CREDITCARD_PURCH','PURCHASE','ACH_PURCH')
  and    x_ics_rcode in ('1','100')
  and    x_payment_type in ('SETTLEMENT', 'CHARGE','AUTH');

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
  --CR 48979 -
  cursor existing_shipping_refund_cur is
  select objid, x_request_id, x_status
  from sa.x_biz_purch_hdr
  where c_orderid = ip_purch_id and x_credit_reason like 'Freight%amount';

  existing_shipping_refund_rec existing_shipping_refund_cur%rowtype;
  ----------------------------------------------------------------------------------
 v_objid number;
 v_full_refund varchar2(100) := 'false';
 v_total_tax number;
 v_amount number;
 n_next_refund number;
 v_bill_country varchar2(20);
 v_bill_state varchar2(40);
 v_failed_refund_count number;
 v_rqst_type sa.table_x_purch_hdr.x_rqst_type%type;
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

        if nvl(purch_hdr_rec.x_purch_hdr2bank_acct,1) > 1 then  --From WEB cc purchase is saving 1 in this column.
            v_rqst_type := 'ach_refund';
        else
            v_rqst_type := 'cc_refund';
        end if;

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
            v_rqst_type,
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
            decode(v_full_refund,'true',(purch_hdr_rec.x_amount-purch_hdr_rec.x_discount_amount),ip_amount)*(-1), --x_amount,
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
        --Below validation will execute for CC transactions
        if prog_purch_hdr_rec.PURCH_HDR2CREDITCARD is not null and prog_purch_hdr_rec.PURCH_HDR2CREDITCARD > 0 and ip_amount > prog_purch_hdr_rec.x_auth_amount then
           op_err_code:='110';
           op_err_msg:='ERROR: amount of credit cannot exceed amount of original purchase';
           return;
        end if;
        --Below validation will execute for ACH transactions
        if prog_purch_hdr_rec.PURCH_HDR2BANK_ACCT is not null and prog_purch_hdr_rec.PURCH_HDR2BANK_ACCT > 0 and ip_amount > prog_purch_hdr_rec.x_bill_amount then
           op_err_code:='110';
           op_err_msg:='ERROR: amount of credit cannot exceed amount of original purchase';
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


        select sa.seq_x_program_purch_hdr.nextval into v_objid from dual;

        if nvl(prog_purch_hdr_rec.purch_hdr2bank_acct,1) > 1 then
            v_rqst_type := 'ACH_REFUND';
        else
            v_rqst_type := 'CREDITCARD_REFUND';
        end if;

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
          v_rqst_type, --x_rqst_type,
          sysdate, --x_rqst_date,
          decode(v_rqst_type,'ACH_REFUND','ecp_credit','ics_credit'), --'ics_auth, ics_bill', --x_ics_applications,
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

		if(ip_reason like 'Freight%amount') then
			open existing_shipping_refund_cur;
			fetch existing_shipping_refund_cur into existing_shipping_refund_rec;
			if existing_shipping_refund_cur%found then
				if existing_shipping_refund_rec.x_request_id is null then
					op_err_code:='50';
					op_err_msg:='ERROR: Transaction already exists for freight amount reversal, Please select the existing one.';
				elsif existing_shipping_refund_rec.x_status = 'SUCCESS' then
					op_err_code:='70';
					op_err_msg:='ERROR: Refund of freight amount is already processed for this Order.';
				end if;
				close existing_shipping_refund_cur;
				return;
			else
				close existing_shipping_refund_cur;
			end if;
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

        if nvl(biz_purch_hdr_rec.purch_hdr2bank_acct,1) > 1 then --From WEB cc purchase for BIZ is saving 0 in this column.
            v_rqst_type := 'ACH_REFUND';
        else
            v_rqst_type := 'CREDITCARD_REFUND';
        end if;

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
             v_rqst_type, -- x_rqst_type -- (REFUND IS WHAT I FOUND IN SCI, cc_refund IS WHAT WE USED IN THE PAST)
             sysdate, -- x_rqst_date,
             decode(v_rqst_type,'ACH_REFUND','ecp_credit','ics_credit'), --x_ics_applications, -- (WHAT WE USED IN TAS 'ics_credit', --'ics_auth, ics_bill',)
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
 and x_rqst_type in ('cc_refund','ach_refund');

 refund_hdr_rec refund_hdr_cur%rowtype;

 cursor prog_refund_hdr_cur is
 select * from sa.x_program_purch_hdr
 where objid = ip_refund_id
 and x_rqst_type in ('CREDITCARD_REFUND','ACH_REFUND');

 prog_refund_hdr_rec  prog_refund_hdr_cur%rowtype;

 cursor void_pins_cur (v_objid number) is
 select hdr.x_esn,dtl.x_red_card_number,dtl.x_smp,hdr.x_user
 from sa.table_x_purch_dtl dtl, sa.table_x_purch_hdr hdr
 where dtl.x_purch_dtl2x_purch_hdr= hdr.objid
 and hdr.objid = v_objid;

  --CR44760 Void BOGO cards Cursor
 cursor void_bogo_pins_cur (v_original_red_code varchar2) is
 select BOGO_RED_CARD_PIN,BOGO_SMP
 from sa.mtm_bogo_bi_info
 where ORIGINAL_RED_CODE =v_original_red_code;

--------------------------------------------------------------------------------
-- NEW B2B
--------------------------------------------------------------------------------
  cursor biz_refund_hdr_cur(ip_refund_id varchar2)
  is
  select *
  from sa.x_biz_purch_hdr
  where objid = ip_refund_id
  and   x_rqst_type in ('CREDITCARD_REFUND','ACH_REFUND');

  biz_refund_hdr_rec biz_refund_hdr_cur%rowtype;

  cursor biz_refund_dtl_cur(ip_refund_id varchar2)
  is
  select *
  from sa.X_BIZ_ORDER_DTL dtl
  where dtl.BIZ_ORDER_DTL2BIZ_PURCH_HDR_CR = ip_refund_id;

  biz_refund_dtl_rec biz_refund_dtl_cur%rowtype;
--------------------------------------------------------------------------------


 v_result varchar2(300);
 v_points_flag boolean;
 v_error_num number;
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

             v_result := sa.ADFCRM_CARRIER.mark_card_invalid(p_reason => upper(refund_hdr_rec.x_rqst_type), --'CC_REFUND',
                                                             p_esn => void_pins_rec.x_esn,
                                                             p_card_no => void_pins_rec.x_red_card_number,
                                                             p_snp => void_pins_rec.x_smp,
                                                             p_login_name => void_pins_rec.x_user);

               --CR44760 Void BOGO cards
               for void_bogo_pins_rec in void_bogo_pins_cur(void_pins_rec.x_red_card_number) loop
                     v_result := sa.ADFCRM_CARRIER.mark_card_invalid(p_reason => upper(refund_hdr_rec.x_rqst_type), --'CC_REFUND',
                                                             p_esn => void_pins_rec.x_esn,
                                                             p_card_no => void_bogo_pins_rec.BOGO_RED_CARD_PIN,
                                                             p_snp => void_bogo_pins_rec.BOGO_SMP,
                                                             p_login_name => void_pins_rec.x_user);
               end loop;

				--CR32367 Remove the associated benefits
               sa.reward_benefits_n_vouchers_pkg.p_remove_pin_benefits  (
                        in_service_plan_pin       => void_pins_rec.x_red_card_number
                        ,out_err_code             => v_error_num
                        ,out_err_msg              => op_err_msg);
               if nvl(v_error_num,0) != 0 then
                  op_err_code:='185';
                  op_err_msg:='ERROR: '||nvl(v_error_num,0)||' '||op_err_msg;
               end if;

            end loop;
            if nvl(op_err_code,'0') = '185' then
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
              x_rcrf_tax_amount   = abs(i.x_rcrf_tax_amount)*-1,
			  freight_amount      = 0
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
              x_rcrf_tax_amount   = 0,
			  freight_amount      = 0
          where objid             = biz_refund_hdr_rec.objid;
        end if;
      end loop;

		--CR 48979: In case of shipping amount transaction, update the amount refunded to shipping amount
        if upper(biz_refund_hdr_rec.x_credit_reason) like upper('%Freight%amount') then
            update sa.x_biz_purch_hdr
            set freight_amount = abs(ip_auth_amount)*-1,
                x_amount = 0
            where objid = biz_refund_hdr_rec.objid;
        end if;

        if ( ip_ics_rflag in ('SOK','ACCEPT') or ip_ics_rcode in ('1','100')) then
            -- Any logic associated to succesfull refund here
             update sa.x_biz_purch_hdr
             set X_STATUS = 'SUCCESS'
             where objid = biz_refund_hdr_rec.objid;

             --when refund is partial and successfull and has balance to refund, insert new detail record with reference to current detail.
             if upper(biz_refund_hdr_rec.x_credit_reason) like upper('%Partial%Refund%') then
                  open biz_refund_dtl_cur(ip_refund_id => ip_refund_id);
                  fetch biz_refund_dtl_cur into biz_refund_dtl_rec;
                  if biz_refund_dtl_cur%found then
                      if biz_refund_dtl_rec.x_total_amount > (abs(ip_auth_amount-n_penny_adjuster) + (biz_refund_dtl_rec.x_total_amount - nvl(get_b2b_order_dtl_rem_bal(biz_refund_dtl_rec.objid),0))) then
                        -- insert new detail record for enabling further refund
                          BEGIN
                            INSERT INTO sa.x_biz_order_dtl
                            ( objid                         ,
                              x_item_type                    ,
                              x_item_value                   ,
                              x_item_part                    ,
                              x_ecom_order_number            ,
                              x_ofs_order_number             ,
                              x_order_line_number            ,
                              x_amount                       ,
                              x_sales_tax_amount             ,
                              x_e911_tax_amount              ,
                              x_usf_tax_amount               ,
                              x_rcrf_tax_amount              ,
                              x_total_tax_amount             ,
                              x_total_amount                 ,
                              x_ecom_group_id                ,
                              x_extract_flag                 ,
                              x_extract_date                 ,
                              x_creation_date                ,
                              x_create_by                    ,
                              x_last_update_date             ,
                              x_last_updated_by              ,
                              biz_order_dtl2biz_purch_hdr_cr ,
                              biz_order_dtl2biz_order_dtl_cr ,
                              SHIPMENT_TRACKING_NUMBER       ,
                              SHIPMENT_DATE                  ,
                              SHIPMENT_CARRIER               ,
                              X_VENDOR_ID
                              )
                              VALUES
                              (sa.sequ_order_dtl.nextval                   ,
                              biz_refund_dtl_rec.x_item_type                                      ,--ITEM_TYPE
                              biz_refund_dtl_rec.x_item_value                                      ,--ITEM_VALUE (Billing)
                              biz_refund_dtl_rec.x_item_part              ,--ITEM_PART
                              biz_refund_dtl_rec.x_ecom_order_number                ,--ECOM_ORDER_NUMBER
                              biz_refund_dtl_rec.x_ofs_order_number                                     ,--OFS ORDER NUMBER
                              biz_refund_dtl_rec.x_order_line_number              ,--ORDER LINE NUMBER
                              biz_refund_dtl_rec.x_amount                 ,
                              biz_refund_dtl_rec.x_sales_tax_amount          ,
                              biz_refund_dtl_rec.x_e911_tax_amount        ,
                              biz_refund_dtl_rec.x_usf_tax_amount          ,
                              biz_refund_dtl_rec.x_rcrf_tax_amount        ,
                              biz_refund_dtl_rec.x_total_tax_amount         ,
                              biz_refund_dtl_rec.x_total_amount             ,
                              biz_refund_dtl_rec.x_ecom_group_id          ,
                              biz_refund_dtl_rec.x_extract_flag                                    ,--x_extract_flag
                              SYSDATE                                     ,--x_extract_date
                              SYSDATE                                     ,--x_creation_date
                              biz_refund_dtl_rec.x_create_by                                   ,--x_create_by
                              SYSDATE                                     ,--x_last_update_date
                              biz_refund_dtl_rec.x_last_updated_by                                   ,--x_last_updated_by
                              null                                       ,--biz_order_dtl2biz_purch_hdr_cr
                              biz_refund_dtl_rec.objid                                        ,--biz_order_dtl2biz_order_dtl_cr
                              biz_refund_dtl_rec.SHIPMENT_TRACKING_NUMBER,      --SHIPMENT_TRACKING_NUMBER
                              biz_refund_dtl_rec.SHIPMENT_DATE     ,--SHIPMENT_DATE
                              biz_refund_dtl_rec.SHIPMENT_CARRIER    ,--SHIPMENT_CARRIER
                              biz_refund_dtl_rec.X_VENDOR_ID    --X_VENDOR_ID
                              );
                          EXCEPTION
                          WHEN OTHERS THEN
                            op_err_msg :=  'Error occurred while inserting detail record referencing current detail for remaining refund : '||substr(sqlerrm,1,100) ;
                          END;
                     else
                            op_err_msg :=  'Warning: Remaining amount is not less than refunded amount. Not inserting new detail record Total:'||biz_refund_dtl_rec.x_total_amount ||'   ip_auth_amount'||ip_auth_amount ||  '  Balance Before Cur Trans:'||get_b2b_order_dtl_rem_bal(biz_refund_dtl_rec.objid);
                     end if;
                  else
                            op_err_msg :=  'Warning: Not inserting new detail record as Current Detail record not found for refund Id:'||ip_refund_id ;
                  end if;
             else
                  op_err_msg :=  'Warning: Not inserting new detail record as it current refund is not Partial Refund : '||substr(sqlerrm,1,100) ;
             end if;

        else
             update sa.x_biz_purch_hdr
             set X_STATUS = 'FAILED'
             where objid = biz_refund_hdr_rec.objid;
           op_err_code:='230';
           op_err_msg:='ERROR: '||ip_auth_rmsg;
        end if;

    end if;

  end if;
--------------------------------------------------------------------------------
  commit;


END post_processing;

  procedure add_item_to_refund (
        ip_hdr_objid in varchar2,
        ip_dtl_objid in varchar2,
        op_err_code  out varchar2,
        op_err_msg   out varchar2)
  is
    v_order_id sa.x_biz_purch_hdr.c_orderid%type;
    v_partial_refund_dtl_cnt number;

  begin

    for i in (select objid,decode(x_ics_rcode,'1','false','100','false','true') is_eligible_for_refund,x_rqst_type,c_orderid, x_credit_reason
              from   sa.x_biz_purch_hdr
              where  1=1
              and    objid = ip_hdr_objid
              )
    loop
      v_order_id := i.c_orderid;

      if i.is_eligible_for_refund != 'true' and
         i.x_rqst_type in ('REFUND', 'CREDITCARD_REFUND','ACH_REFUND') then
        op_err_code :='240';
        op_err_msg := 'Order Id has already been refunded.';
        return;
      end if;
      if i.x_rqst_type not in ('REFUND', 'CREDITCARD_REFUND','ACH_REFUND') then
        op_err_code :='250';
        op_err_msg := 'Unable to add item, because Order Id is not eligible.';
        return;
      end if;
      if upper(i.x_credit_reason) like upper('Freight%amount') then
        op_err_code :='280';
        op_err_msg := 'Refund transaction belongs to Freight amount Reason. It accepts only Freight Amount refunds.';
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
         i.x_rqst_type in ('REFUND', 'CREDITCARD_REFUND','ACH_REFUND')
      then
        op_err_code :='270';
        op_err_msg := 'The item you''re trying to add belongs to an order that was already refunded.';
        return;
      end if;
    end loop;

	--  Check for if current refund is partial and get the dtls added count.
    SELECT COUNT(dtl.objid) into v_partial_refund_dtl_cnt
    FROM X_BIZ_PURCH_HDR hd, X_BIZ_ORDER_DTL dtl
    WHERE dtl.BIZ_ORDER_DTL2BIZ_PURCH_HDR_CR=hd.OBJID
    AND hd.OBJID                       = ip_hdr_objid
    AND hd.x_payment_type                   = 'REFUND'
    AND hd.X_CREDIT_REASON LIKE '%Partial%refund%';

    IF(v_partial_refund_dtl_cnt = 1) THEN
      op_err_code              :='280';
      op_err_msg               := 'Only one detail item can be refunded during Partial refund process.';
      RETURN;
    END IF;

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
         i.x_rqst_type in ('REFUND', 'CREDITCARD_REFUND','ACH_REFUND') then
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

  PROCEDURE add_shipping_rec_to_orders(
    ip_order_id   in varchar2,
    ip_purch_id   in varchar2,
    ip_user_name  in varchar2,
    ip_source     in varchar2,
    ip_amount     in number,
    op_err_code out varchar2,
    op_err_msg out varchar2)
 IS

 BEGIN

 dbms_output.put_line('Order Id: ' || ip_order_id);
 dbms_output.put_line('Purchase Id: ' || ip_purch_id);
 dbms_output.put_line('Amount: ' || ip_amount);
 dbms_output.put_line('ip_user_name: ' || ip_user_name);
 dbms_output.put_line('ip_source: ' || ip_source);


 if nvl(ip_amount,0) < 0.01 then
     op_err_code:='15';
     op_err_msg:='ERROR: Freight amount is zero.';
     return;
  end if;

 if ip_purch_id is null then
     op_err_code:='20';
     op_err_msg:='ERROR: Invalid Purchase Id';
     return;
  end if;

  if ip_order_id is null then
     op_err_code:='25';
     op_err_msg:='ERROR: Invalid Order Id';
     return;
  end if;

  INSERT INTO sa.x_biz_order_dtl
	    ( objid,
        x_item_type,
        x_item_value,
        x_item_part,
        x_ecom_order_number,
        x_ofs_order_number,
        x_order_line_number,
        x_amount,
        x_sales_tax_amount,
        x_e911_tax_amount,
        x_usf_tax_amount,
        x_rcrf_tax_amount,
        x_total_tax_amount,
        x_total_amount,
        x_ecom_group_id,
        x_extract_flag,
        x_extract_date,
        x_creation_date,
        x_create_by,
        x_last_update_date,
        x_last_updated_by,
        biz_order_dtl2biz_purch_hdr_cr ,
        biz_order_dtl2biz_order_dtl_cr
      )
    VALUES
      (sa.sequ_order_dtl.nextval,
       'FREIGHT_AMOUNT'                ,--ITEM_TYPE
        NULL                           ,--ITEM_VALUE (Billing)
        'FREIGHT_AMOUNT'               ,--ITEM_PART
        ip_order_id                    ,--ECOM_ORDER_NUMBER
        NULL                           ,--OFS ORDER NUMBER
        NULL                           ,--ORDER LINE NUMBER
        0                              ,
        0                              ,
        0                              ,
        0                              ,
        0                              ,
        0                              ,
        ip_amount                      ,
        NULL                           ,
       'YES'                           ,--x_extract_flag
        SYSDATE                        ,--x_extract_date
        SYSDATE                        ,--x_creation_date
       'CORECBO'                       ,--x_create_by
        SYSDATE                        ,--x_last_update_date
      'CORECBO'                        ,--x_last_updated_by
        ip_purch_id                    ,--biz_order_dtl2biz_purch_hdr_cr
        NULL                            --biz_order_dtl2biz_order_dtl_cr
     );
    commit;
    op_err_code:='0';
   exception
    when others then
	 op_err_code:=SQLCODE;
     op_err_msg:='ERROR: '||SQLERRM;

  end add_shipping_rec_to_orders;

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

function get_b2b_order_dtl_rem_bal(ip_dtl_objid varchar2) return number as

  CURSOR biz_detail_cur
  IS
    SELECT dtl.X_TOTAL_AMOUNT total,
      dtl.BIZ_ORDER_DTL2BIZ_ORDER_DTL_CR parent_dtl_id
    FROM X_BIZ_ORDER_DTL dtl
    WHERE dtl.OBJID = ip_dtl_objid;

  biz_detail_rec biz_detail_cur%rowtype;

  CURSOR remaining_balance_cur(ip_parent_dtl_objid VARCHAR2)
  IS
    SELECT hd.x_auth_amount refunded_amount,
      dtl.BIZ_ORDER_DTL2BIZ_ORDER_DTL_CR parent_dtl_id
    FROM sa.x_biz_purch_hdr hd,
      X_BIZ_ORDER_DTL dtl
    WHERE dtl.BIZ_ORDER_DTL2BIZ_PURCH_HDR_CR=hd.OBJID
    AND hd.x_payment_type = 'REFUND'
    AND hd.X_CREDIT_REASON LIKE '%Partial%refund%'
    AND dtl.objid=ip_parent_dtl_objid;

  remaining_balance_rec remaining_balance_cur%rowtype;

  v_parent_dtl_id  VARCHAR2(30) := NULL;
  v_total_amount   NUMBER       := 0;
  v_total_refunded NUMBER       := 0;

BEGIN

  OPEN biz_detail_cur;
  FETCH biz_detail_cur INTO biz_detail_rec;
  IF biz_detail_cur%found THEN
    v_total_amount        := biz_detail_rec.total;
    v_parent_dtl_id       := biz_detail_rec.parent_dtl_id;
    WHILE v_parent_dtl_id IS NOT NULL
    LOOP
      OPEN remaining_balance_cur(v_parent_dtl_id);
      FETCH remaining_balance_cur INTO remaining_balance_rec;
      IF remaining_balance_cur%found THEN
        v_total_refunded := v_total_refunded + remaining_balance_rec.refunded_amount;
        v_parent_dtl_id  := remaining_balance_rec.parent_dtl_id;
      ELSE
        v_parent_dtl_id := null;
      end if;
      CLOSE remaining_balance_cur;
    END LOOP;
  END IF;
  CLOSE biz_detail_cur;
  return (v_total_amount + v_total_refunded);

END get_b2b_order_dtl_rem_bal;


/**
  *	API to fetch the red card status information based on refund purchase hdr objid
  *	@param in_hdrObjId  - Refund transaction header obj id
  */
FUNCTION fetch_airtime_card_info(
    in_hdrObjId VARCHAR2)
  RETURN airtime_card_status_tab pipelined
IS

  CURSOR redCardCur
  IS
    SELECT rc.X_RED_CODE X_RED_CODE
    FROM table_x_purch_hdr hdr,
      table_x_purch_dtl dtl,
      table_x_red_card rc
    WHERE dtl.x_purch_dtl2x_purch_hdr=hdr.objid
    AND dtl.X_RED_CARD_NUMBER        =rc.x_red_code
    AND ( hdr.X_ICS_RFLAG           IN ('SOK')
    OR hdr.X_ICS_RCODE              IN ('100'))
    AND rc.RED_CARD2CALL_TRANS is null -- to avoid duplicate records for Redeemed PINs
    AND hdr.objid                   IN
      (SELECT rHdr.X_PURCH_HDR2CR_PURCH
      FROM sa.TABLE_X_PURCH_HDR rHdr
      WHERE rHdr.objid=in_hdrObjId
      );

  redCardCurRec redCardCur%rowtype;

  CURSOR redCardStatusInfoCur(in_redCodeNo varchar2)
  IS
    SELECT CARD_NO RED_CODE,
      '***********'
      ||SUBSTR(CARD_NO,-4) MASKED_RED_CODE,
      SNP_ESN,
      PART_NUMBER,
      DESCRIPTION,
      CARD_UNITS RED_UNITS,
      ACCESS_DAYS,
      STATUS,
      STATUS_DESC
    FROM TABLE(sa.apex_toss_util_pkg.airtime_cards(in_redCodeNo));

  redCardStatusInfoCurRec redCardStatusInfoCur%rowtype;
  airtime_card_status_rslt airtime_card_status_rec;

  v_x_rqst_type varchar2(20);

BEGIN

  if(trim(in_hdrObjId) is null) then
    dbms_output.put_line('Refund transaction header Obj Id is empty. Please provide valid refund header Obj Id');
    return;
  end if;

  select x_rqst_type into v_x_rqst_type from TABLE_X_PURCH_HDR hdr where hdr.OBJID=in_hdrObjId;

  if(upper(v_x_rqst_type) not like upper('%refund') ) then
    dbms_output.put_line('Header Obj Id is not a refund transaction. Please provide valid refund header Obj Id');
    return;
  end if;

  FOR redCardCurRec IN redCardCur
  LOOP
      IF redCardCurRec.X_RED_CODE IS NOT NULL THEN
      -- initialize
      airtime_card_status_rslt.RED_CODE        := NULL;
      airtime_card_status_rslt.MASKED_RED_CODE := NULL;
      airtime_card_status_rslt.SNP_ESN         := NULL;
      airtime_card_status_rslt.PART_NUMBER     := NULL;
      airtime_card_status_rslt.DESCRIPTION     := NULL;
      airtime_card_status_rslt.RED_UNITS       := NULL;
      airtime_card_status_rslt.ACCESS_DAYS     := NULL;
      airtime_card_status_rslt.STATUS          := NULL;
      airtime_card_status_rslt.STATUS_DESC     := NULL;

      FOR redCardStatusInfoCurRec IN redCardStatusInfoCur(redCardCurRec.X_RED_CODE)
      LOOP
        airtime_card_status_rslt.RED_CODE        := redCardStatusInfoCurRec.RED_CODE;
        airtime_card_status_rslt.MASKED_RED_CODE := redCardStatusInfoCurRec.MASKED_RED_CODE;
        airtime_card_status_rslt.SNP_ESN         := redCardStatusInfoCurRec.SNP_ESN;
        airtime_card_status_rslt.PART_NUMBER     := redCardStatusInfoCurRec.PART_NUMBER;
        airtime_card_status_rslt.DESCRIPTION     := redCardStatusInfoCurRec.DESCRIPTION;
        airtime_card_status_rslt.RED_UNITS       := redCardStatusInfoCurRec.RED_UNITS;
        airtime_card_status_rslt.ACCESS_DAYS     := redCardStatusInfoCurRec.ACCESS_DAYS;
        airtime_card_status_rslt.STATUS          := redCardStatusInfoCurRec.STATUS;
        airtime_card_status_rslt.STATUS_DESC     := redCardStatusInfoCurRec.STATUS_DESC;
        pipe row (airtime_card_status_rslt);
      END LOOP;

    ELSE
        dbms_output.put_line('There are no Red Cards associated to this Refund transaction');
    END IF;
  END LOOP;
END fetch_airtime_card_info;

--Below API will be used for checking if benefits can be removed for APP and BILLING transactions.
--in_transactionType : APP or BILLING
FUNCTION is_Benefits_Removable(
    in_purchID         VARCHAR2,
    in_esn             VARCHAR2,
    in_brand           VARCHAR2,
    in_deviceType      VARCHAR2,
    in_transactionType VARCHAR2)
  RETURN VARCHAR2
IS
  CURSOR cur_LatestAPPTransaction
  IS
    SELECT *
    FROM
      (SELECT hdr.OBJID purchHdrID,
        hdr.X_AUTH_AMOUNT,
        hdr.X_TOTAL_TAX,
        rc.X_ACCESS_DAYS,
        ct.X_TOTAL_UNITS,
        cte.X_TOTAL_DATA_UNITS,
        cte.X_TOTAL_SMS_UNITS,
        rc.X_RED_CODE
      FROM table_x_purch_hdr hdr,
        table_x_purch_dtl dtl,
        table_x_red_card rc,
        table_x_call_trans ct,
        table_x_call_trans_ext cte
      WHERE dtl.x_purch_dtl2x_purch_hdr=hdr.objid
      AND dtl.X_RED_CARD_NUMBER        =rc.x_red_code
      AND ct.objid                     =rc.RED_CARD2CALL_TRANS
      AND cte.CALL_TRANS_EXT2CALL_TRANS=ct.OBJID
      AND ( hdr.X_ICS_RFLAG           IN ('SOK','ACCEPT')
      OR hdr.X_ICS_RCODE              IN ('100'))
      AND ct.X_RESULT                  ='Completed'
      AND ( nvl(rc.X_ACCESS_DAYS,0)            > 0
      OR nvl(ct.X_TOTAL_UNITS,0)              >0
      OR nvl(cte.X_TOTAL_DATA_UNITS,0)        > 0
      OR nvl(cte.X_TOTAL_SMS_UNITS,0)         > 0)
      AND hdr.X_ESN                    =in_esn
      ORDER BY rc.X_RED_DATE DESC
      )
  WHERE rownum = 1;

  rec_LatestAPPTransaction cur_LatestAPPTransaction%rowtype;

  CURSOR cur_LatestBillingTransaction
  IS
    SELECT *
    FROM
      (SELECT XProgramPurchHdr.OBJID purchHdrID
      FROM X_PROGRAM_PURCH_HDR XProgramPurchHdr,
        sa.x_program_purch_dtl XProgramPurchDtl ,
        sa.x_program_gencode pg
      WHERE XProgramPurchHdr.objid  = XProgramPurchDtl.PGM_PURCH_DTL2PROG_HDR
      AND XProgramPurchDtl.X_ESN    = in_esn
      AND pg.GENCODE2PROG_PURCH_HDR = XProgramPurchDtl.pgm_purch_dtl2prog_hdr
      ORDER BY x_process_date DESC
      )
  WHERE rownum = 1;

  rec_LatestBillingTransaction cur_LatestBillingTransaction%rowtype;
  removable VARCHAR2(1) := 'N';

BEGIN
  IF in_brand             = 'NET10' AND (in_deviceType = 'SMARTPHONE' OR in_deviceType = 'BYOP') THEN
    IF in_transactionType = 'APP' THEN
      OPEN cur_LatestAPPTransaction;
      FETCH cur_LatestAPPTransaction INTO rec_LatestAPPTransaction;
      IF cur_LatestAPPTransaction%found THEN
        IF rec_LatestAPPTransaction.purchHdrID = in_purchID THEN
          removable                            := 'Y';
        END IF;
      END IF;
      CLOSE cur_LatestAPPTransaction;
    END IF;

    IF in_transactionType = 'BILLING' THEN
      OPEN cur_LatestBillingTransaction;
      FETCH cur_LatestBillingTransaction INTO rec_LatestBillingTransaction;
      IF cur_LatestBillingTransaction%found THEN
        IF rec_LatestBillingTransaction.purchHdrID = in_purchID THEN
          removable                                := 'Y';
        END IF;
      END IF;
      CLOSE cur_LatestBillingTransaction;
    END IF;
  END IF;

  RETURN removable;
END is_Benefits_Removable;

end adfcrm_refund_pkg;
/