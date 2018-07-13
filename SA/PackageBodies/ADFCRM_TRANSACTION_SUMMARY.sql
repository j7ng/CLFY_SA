CREATE OR REPLACE package body sa.ADFCRM_TRANSACTION_SUMMARY
as
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_TRANSACTION_SUMMARY_PKB.sql,v $
--$Revision: 1.103 $
--$Author: pkapaganty $
--$Date: 2018/01/22 22:48:45 $
--$ $Log: ADFCRM_TRANSACTION_SUMMARY_PKB.sql,v $
--$ Revision 1.103  2018/01/22 22:48:45  pkapaganty
--$ CR53171 - Added purchase only condition for a msg in script tag on transaction summary
--$
--$ Revision 1.102  2018/01/18 14:17:25  mmunoz
--$ CR53171 Changes for service plan added script
--$
--$ Revision 1.101  2018/01/16 18:06:47  mmunoz
--$ CR53171 TAS Multiple Airtime Purchases for different airtime cards
--$
--$ Revision 1.100  2017/12/02 01:48:21  mmunoz
--$ Added current_esn for get_case_info required for upgrade scenarios
--$
--$ Revision 1.99  2017/12/01 18:13:07  mmunoz
--$ Added esn for get_case_info required for upgrade scenarios
--$
--$ Revision 1.98  2017/12/01 00:13:22  mmunoz
--$ Added condition for VAS eligible
--$
--$ Revision 1.97  2017/11/29 16:30:55  mmunoz
--$ Checking any UPGRADE  as solution name
--$
--$ Revision 1.96  2017/11/27 23:42:28  mmunoz
--$ CR55214 Asurion HPP for TF Web and TF TAS
--$
--$ Revision 1.95  2017/10/13 15:08:40  mmunoz
--$ CR53046 Updated function trans_script_group so email body is not changing.
--$
--$ Revision 1.94  2017/05/11 21:12:06  mmunoz
--$ CR47593 Multiple Redemptions, updated function getServiceVO to get scripts for more than one service plan added
--$
--$ Revision 1.93  2017/04/24 22:06:37  epaiva
--$ CR47593 - multiple redemptions, change to support multiple transaction id
--$
--$ Revision 1.93  2017/04/24 17:56:32  epaiva
--$ CR47593 - Multiple Redemptions for NT/TF/SL
--$
--$ Revision 1.92  2017/01/06 15:31:32  hcampano
--$ CR44729 - GO Smart
--$
--$ Revision 1.91  2016/12/07 16:44:08  mmunoz
--$ CR42459: Avoiding to show the same plan more than one time.
--$
--$ Revision 1.90  2016/11/18 22:01:02  mmunoz
--$ CR45711 : Updated getesntransactiondetail to retrieve bankaccount_id
--$
--$ Revision 1.89  2016/11/09 14:54:12  amishra
--$ CR45463 Changed data type of script text  from varchar2 to clob
--$
--$ Revision 1.88  2016/11/02 14:29:37  mmunoz
--$ CR 45463, 44787 : Changes for BOGO promotion in transaction summary, added ip_check_condition in getServiceVO and trans_script_group
--$
--$ Revision 1.87  2016/07/05 15:20:30  mmunoz
--$ CR43582: Added SERVICE_PLAN_PURCHASE_TAS feature in check for available plans
--$
--$ Revision 1.86  2016/05/09 21:04:55  mmunoz
--$ CR39151: Added ip_source_system when calling sa.adfcrm_scripts.solution_script_func in function trans_script_group
--$
--$ Revision 1.85  2016/05/09 19:00:46  mmunoz
--$ CR39151: Updated trans_script_group to consider solution_name with email body
--$
--$ Revision 1.84  2016/05/06 21:36:25  syenduri
--$ Added 'UPGRADE_AUTO_PORT','UPGRADE_ESN_EXCHANGE' to show SP Added in Trans Summary
--$
--$ Revision 1.83  2016/05/03 22:24:30  syenduri
--$ CR39400-Modified to show Added Service Plan in TS of Ports
--$
--$ Revision 1.82  2015/11/20 18:18:07  hcampano
--$ TAS_2015_24
--$
--$ Revision 1.81  2015/06/24 19:38:23  mmunoz
--$ CR35378  get_esn_info_rec.org_id = 'PAGEPLUS' instead !=
--$
--$ Revision 1.80  2015/06/22 18:30:44  mmunoz
--$ CR35378 - Do not offer ILD $10 Global if brand is not PAGEPLUS
--$
--$ Revision 1.79  2015/05/27 21:29:22  mmunoz
--$ CR33796: changes in function getEsnTransactionDetail, added union to include ILD transactions in total wireless that does not go into master esn
--$
--$ Revision 1.77  2015/04/08 20:07:31  hcampano
--$ TAS_2015_07 - Post Production issue with transaction summary.
--$
--$ Revision 1.76  2015/02/18 23:12:31  mmunoz
--$ initializing quantity to 0 in total
--$
--$ Revision 1.75  2015/02/11 23:03:12  mmunoz
--$ fixing paid until date.
--$
--$ Revision 1.74  2015/02/10 23:41:46  mmunoz
--$ Added solutions to show_billing flag
--$
--$ Revision 1.73  2015/02/09 23:26:24  mmunoz
--$ added quantity
--$
--$ Revision 1.72  2015/02/06 17:39:03  mmunoz
--$ updates for e911_fee_flag
--$
--$ Revision 1.71  2015/02/05 22:21:59  mmunoz
--$ Added column paid_until in function getEsnTransactionDetail
--$
--$ Revision 1.70  2015/02/05 21:20:22  mmunoz
--$ Updated function getEsnTransactionDetail for listagg
--$
--$ Revision 1.69  2015/02/05 16:23:39  mmunoz
--$ Added solution UPGRADE
--$
--$ Revision 1.68  2015/02/03 16:11:41  mmunoz
--$ 30534    Allow Purchase for Upgrades scenarios (solution_name)
--$
--$ Revision 1.67  2015/01/26 20:30:14  mmunoz
--$ updated getEsnTransactionDetail to call sa.adfcrm_group_trans_pkg.get_master_esn
--$
--$ Revision 1.66  2015/01/26 17:19:15  mmunoz
--$ Updated getEsnTransactionDetail added case for listagg
--$
--$ Revision 1.65  2015/01/23 16:28:02  mmunoz
--$ changes in new function
--$
--$ Revision 1.64  2015/01/22 00:30:44  mmunoz
--$ added function trans_script_group
--$
--$ Revision 1.63  2015/01/21 22:11:19  mmunoz
--$ adding distinct for cvs records
--$
--$ Revision 1.62  2014/12/15 22:24:15  mmunoz
--$ TAS_2014_10C_EME  amount-discount for table_x_purch records
--$
--$ Revision 1.61  2014/09/29 19:43:48  mmunoz
--$ added successes for purchases and refunds, X_ICS_RCODE in (a??1a??,a??100a??) and X_ICS_RFLAG in (a??SOKa??, a??ACCEPTa??).
--$
--$ Revision 1.60  2014/09/26 13:55:57  mmunoz
--$ Added some columns to return in getServiceVO
--$
--$ Revision 1.59  2014/09/19 21:42:05  mmunoz
--$ replacing call to airtime_card table function for a query
--$
--$ Revision 1.58  2014/09/05 23:00:56  mmunoz
--$ Added  check for RECURRING_SERVICE_PLAN feature
--$
--$ Revision 1.57  2014/08/26 22:27:37  mmunoz
--$ moving end if for service_plan_objid
--$
--$ Revision 1.56  2014/08/26 20:43:02  mmunoz
--$ replacing for  function SA.ADFCRM_GET_SERV_PLAN_VALUE
--$
--$ Revision 1.55  2014/08/26 18:28:56  mmunoz
--$ added materialized view
--$
--$ Revision 1.54  2014/08/25 15:36:39  mmunoz
--$ Changes in getServicesVO
--$
--$ Revision 1.53  2014/08/21 20:47:11  mmunoz
--$ TAS_2014_07 improving performance
--$
--$ Revision 1.52  2014/08/21 00:51:04  mmunoz
--$ new function getServiceVO
--$
--------------------------------------------------------------------------------------------
    cursor get_esn_info (p_esn in varchar2) is
        select
            pi.part_serial_no,
            pi.objid,
            pi.x_part_inst2contact,
            pn.x_manufacturer,
            Pi.Warr_End_Date,
            bo.org_id,
            pc.name part_class_name
        from
             sa.table_part_inst           pi
            ,sa.TABLE_MOD_LEVEL           ML
            ,sa.TABLE_PART_NUM            PN
            ,sa.TABLE_BUS_ORG             BO
            ,sa.table_part_class          pc
        where pi.part_serial_no = p_esn
        and pi.x_domain = 'PHONES'
        and ml.objid = pi.n_part_inst2part_mod
        AND PN.OBJID = ML.PART_INFO2PART_NUM
        and bo.objid = pn.part_num2bus_org
        and pc.objid = pn.part_num2part_class;

function getEsnTransactionDetail (
    ip_esn in varchar2,      --comma separated values
    ip_call in varchar2,     --comma separated values
    ip_purchase in varchar2,  --comma separated values
    ip_language in varchar2
    )
return esnTransactionDetail_tab
pipelined
is
  cnt_ota_pending            number;
  esntransactiondetail_rslt  esntransactiondetail_rec;
  esntransactiondetail_total esntransactiondetail_rec;
  esn_org_id varchar2(100);
begin
    begin
		select  bo.org_id
		into   esn_org_id
		from    table_part_inst pi,
				table_mod_level ml,
				table_part_num pn,
				table_bus_org bo
		where pi.part_serial_no  in (
					select P_ESN
					from (
						  SELECT REGEXP_SUBSTR(ip_esn,'[^,]+',1,LEVEL) P_ESN
						  FROM (select ip_esn ip_esn from dual)
						  CONNECT BY LEVEL<=REGEXP_COUNT(ip_esn,'[^,]+')
						  group by level, ip_esn
						 )
					WHERE ROWNUM < 2)
		and   pi.x_domain = 'PHONES'
		and   ml.objid = pi.n_part_inst2part_mod
		and   pn.objid = ml.part_info2part_num
		and   bo.objid = pn.part_num2bus_org;
    exception
        when others then esn_org_id := 'unknown';
    end;

-----------------------------------------------------------------------
--  Initialize totals
       esntransactiondetail_total.price          := 0;
       esntransactiondetail_total.discount       := 0;
       esntransactiondetail_total.e911_tax       := 0;
       esntransactiondetail_total.usf_tax        := 0;
       esntransactiondetail_total.rcrf_tax       := 0;
       esntransactiondetail_total.tax            := 0;
       esntransactiondetail_total.total          := 0;
       esntransactiondetail_total.quantity       := 0;
-----------------------------------------------------------------------
--  Purchase loop
   for rec in (
       select  PURCH.esn,
               PURCH.merchant_ref_number,
               PURCH.price,
               PURCH.e911_tax,
               PURCH.usf_tax,
               PURCH.rcrf_tax,
               PURCH.discount,
               PURCH.tax,
               PURCH.total,
               PURCH.purch_hdr2creditcard,
               purch.purch_hdr2bank_acct,
               PURCH.payment_type,
               --PURCH.red_code,
               pc.name part_class,
               pi.x_sequence,
               c.e_mail,
               purch.item_description,
               purch.paid_until,
               purch.quantity
       from
            (SELECT
               pdtl.x_esn esn,
               phdr.x_merchant_ref_number merchant_ref_number,
               nvl(phdr.x_amount,0) price,
               nvl(phdr.x_e911_tax_amount,0) e911_tax,
               nvl(phdr.x_usf_taxamount,0) usf_tax,
               nvl(phdr.x_rcrf_tax_amount,0) rcrf_tax,
               nvl(phdr.x_discount_amount,0) discount,
               nvl(phdr.x_tax_amount,0) tax,
               (nvl(phdr.x_amount,0)+
               nvl(phdr.x_tax_amount,0) +
               nvl(phdr.x_e911_tax_amount,0) +
               nvl(phdr.x_usf_taxamount,0) +
               nvl(phdr.x_rcrf_tax_amount,0)) total,
               phdr.purch_hdr2creditcard,
               phdr.purch_hdr2bank_acct,
               'Billing' payment_type,
               --'' red_code,
               sa.ADFCRM_TRANSACTION_SUMMARY.get_others_added('PURCHASE_PG', p.esn, 'en', p.merchant_number, p.call_id) item_description,
               null paid_until,
               1 quantity
            FROM  (select distinct nvl(sa.adfcrm_group_trans_pkg.get_master_esn('ESN',esn),esn) esn, merchant_number, call_id
                   from   (WITH t AS (select  ip_esn esns,
                                      ip_purchase purchaseids,
                                     ip_call callids
                              from dual)
                   select nvl(replace(regexp_substr(esns,'[^,]+',1,lvl),'null',''), nvl(sa.adfcrm_group_trans_pkg.get_master_esn('ESN',ip_esn),ip_esn)) esn,
                          replace(regexp_substr(purchaseids,'[^,]+',1,lvl),'null','') merchant_number,
                          replace(regexp_substr(callids,'[^,]+',1,lvl),'null','') call_id
                   from  (select esns,purchaseids,callids, level lvl
                          from   t
                          connect by level <= length(purchaseids) - length(replace(purchaseids,',')) + 1)
                  )) p,
                  x_program_purch_hdr phdr,
                  x_program_purch_dtl pdtl
            WHERE phdr.x_merchant_ref_number = p.merchant_number
            and   nvl(phdr.x_amount,0) > 0
            and   pdtl.x_esn = p.esn
            AND   pdtl.pgm_purch_dtl2prog_hdr = phdr.objid
            and   phdr.x_ics_rcode in ('1','100')
            and   phdr.x_ics_rflag in ('SOK', 'ACCEPT')
            UNION ALL
            select esn, merchant_ref_number, price, e911_tax, usf_tax, rcrf_tax, discount, tax, total, purch_hdr2creditcard, purch_hdr2bank_acct, payment_type,
                   --listagg(red_code,',') within group (order by esn) red_code,
                   listagg('('||cnt_red_card||') '||(case when get_plan_desc is null or esn_org_id = 'TRACFONE' then get_others_desc
                            else get_plan_desc
                            end
                            ),'<br>') within group (order by esn) item_description,
--                   case
--                   when count(distinct item_description) > 1
--                   then listagg(item_description,'<br>') within group (order by esn)
--                   else max(item_description)
--                   end item_description,
                   case
                   when max(nvl(e911_fee_qty,0)) > 0
                   then LAST_DAY(TO_DATE('01'||TO_CHAR(max(e911_fee_qty),'00')||TO_CHAR(SYSDATE,'YYYY'),'DDMMYYYY'))
                   else null
                   end  paid_until,
                   sum(cnt_red_card) quantity
            from
            (
 select
 esn, merchant_ref_number, price, e911_tax, usf_tax, rcrf_tax, discount, tax, total, purch_hdr2creditcard, purch_hdr2bank_acct, payment_type,
 get_plan_desc, get_others_desc, count(red_code) cnt_red_card, e911_fee_qty
 from
 (
            SELECT
               phdr.x_esn esn,
               phdr.x_merchant_ref_number merchant_ref_number,
               nvl(phdr.x_amount,0) price,
               nvl(phdr.x_e911_amount,0) e911_tax,
               nvl(phdr.x_usf_taxamount,0) usf_tax,
               nvl(phdr.x_rcrf_tax_amount,0) rcrf_tax,
               nvl(phdr.x_discount_amount,0) discount,
               nvl(phdr.x_tax_amount,0) tax,
               ((nvl(phdr.x_amount,0)-nvl(phdr.x_discount_amount,0))  +
               nvl(phdr.x_tax_amount,0) +
               nvl(phdr.x_e911_amount,0) +
               nvl(phdr.x_usf_taxamount,0) +
               nvl(phdr.x_rcrf_tax_amount,0)) total,
               phdr.x_purch_hdr2creditcard  purch_hdr2creditcard,
               phdr.x_purch_hdr2bank_acct  purch_hdr2bank_acct,
               'APP' payment_type,
               rc.X_RED_CODE red_code,
               sa.adfcrm_scripts.get_plan_description(sa.adfcrm_transaction_summary.get_service_plan_added(p.esn, p.call_id, p.merchant_number),'ENGLISH','ALL') get_plan_desc,
               sa.adfcrm_transaction_summary.get_others_added('PURCHASE_PG', p.esn, 'en', p.merchant_number, p.call_id) get_others_desc,
               --nvl(sa.adfcrm_scripts.get_plan_description(sa.adfcrm_transaction_summary.get_service_plan_added(p.esn, p.call_id, p.merchant_number),'ENGLISH','ALL')
               --   ,SA.ADFCRM_TRANSACTION_SUMMARY.get_others_added('PURCHASE_PG', p.esn, 'en', p.merchant_number, p.call_id)) item_description,
               null e911_fee_qty
            FROM  (select distinct nvl(sa.adfcrm_group_trans_pkg.get_master_esn('ESN',esn),esn) esn, merchant_number, call_id
                   from   (WITH t AS (select  ip_esn esns,
                                      ip_purchase purchaseids,
                                     ip_call callids
                              from dual)
                   select nvl(replace(regexp_substr(esns,'[^,]+',1,lvl),'null',''), nvl(sa.adfcrm_group_trans_pkg.get_master_esn('ESN',ip_esn),ip_esn)) esn,
                          replace(regexp_substr(purchaseids,'[^,]+',1,lvl),'null','') merchant_number,
                          replace(regexp_substr(callids,'[^,]+',1,lvl),'null','') call_id
                   from  (select esns,purchaseids,callids, level lvl
                          from   t
                          connect by level <= length(purchaseids) - length(replace(purchaseids,',')) + 1)
                  )) p,
                  sa.table_x_call_trans ct,
                  sa.TABLE_X_RED_CARD rc,
                  sa.TABLE_X_PURCH_DTL PDTL,
                  sa.TABLE_X_PURCH_HDR PHDR
             WHERE ct.objid = p.call_id
             AND   rc.red_card2call_trans = ct.objid
             AND   PDTL.X_RED_CARD_NUMBER = RC.X_RED_CODE
             AND   PDTL.X_SMP = RC.X_SMP
             AND   PHDR.OBJID = PDTL.X_PURCH_DTL2X_PURCH_HDR
             and   phdr.x_esn = p.esn
             and   phdr.x_ics_rcode in ('1','100')
             and   phdr.x_ics_rflag in ('SOK', 'ACCEPT')
            UNION
            SELECT
               phdr.x_esn esn,
               phdr.x_merchant_ref_number merchant_ref_number,
               nvl(phdr.x_amount,0) price,
               nvl(phdr.x_e911_amount,0) e911_tax,
               nvl(phdr.x_usf_taxamount,0) usf_tax,
               nvl(phdr.x_rcrf_tax_amount,0) rcrf_tax,
               nvl(phdr.x_discount_amount,0) discount,
               nvl(phdr.x_tax_amount,0) tax,
               ((nvl(phdr.x_amount,0)-nvl(phdr.x_discount_amount,0)) +
               nvl(phdr.x_tax_amount,0) +
               nvl(phdr.x_e911_amount,0) +
               nvl(phdr.x_usf_taxamount,0) +
               nvl(phdr.x_rcrf_tax_amount,0)) total,
               phdr.x_purch_hdr2creditcard  purch_hdr2creditcard,
               phdr.x_purch_hdr2bank_acct  purch_hdr2bank_acct,
               'APP' payment_type,
               pdtl.x_red_card_number red_code,
               --LISTAGG(PDTL.X_RED_CARD_NUMBER,',') WITHIN GROUP (ORDER BY phdr.x_esn) red_code,
               sa.adfcrm_scripts.get_plan_description(sa.adfcrm_transaction_summary.get_service_plan_added(p.esn, p.call_id, p.merchant_number),'ENGLISH','ALL') get_plan_desc,
               sa.adfcrm_transaction_summary.get_others_added('PURCHASE_PG', p.esn, 'en', p.merchant_number, p.call_id) get_others_desc,
               --nvl(sa.adfcrm_scripts.get_plan_description(sa.adfcrm_transaction_summary.get_service_plan_added(p.esn, p.call_id, p.merchant_number),'ENGLISH','ALL')
               --   ,sa.adfcrm_transaction_summary.get_others_added('PURCHASE_PG', p.esn, 'en', p.merchant_number, p.call_id)) item_description,
               (SELECT decode(vo.quantity,null,0, 12-vo.quantity) qty
                FROM table_mod_level ml,
                     table_part_num pn,
                     table(sa.ADFCRM_VO.getSafelinkSp(ip_esn,'SAFELINK',ip_language)) vo
                where ml.objid = pdtl.x_purch_dtl2mod_level
                and pn.objid = ml.part_info2part_num
                and  ServicePlanType = 'OTHER'
                and vo.part_number = pn.part_number
                and rownum < 2) e911_fee_qty
            FROM  (select distinct nvl(sa.adfcrm_group_trans_pkg.get_master_esn('ESN',esn),esn) esn, merchant_number, call_id
                   from   (WITH t AS (select  ip_esn esns,
                                      ip_purchase purchaseids,
                                     ip_call callids
                              from dual)
                   select nvl(replace(regexp_substr(esns,'[^,]+',1,lvl),'null',''), nvl(sa.adfcrm_group_trans_pkg.get_master_esn('ESN',ip_esn),ip_esn)) esn,
                          replace(regexp_substr(purchaseids,'[^,]+',1,lvl),'null','') merchant_number,
                          replace(regexp_substr(callids,'[^,]+',1,lvl),'null','') call_id
                   from  (select esns,purchaseids,callids, level lvl
                          from   t
                          connect by level <= length(purchaseids) - length(replace(purchaseids,',')) + 1)
                  )
                  --CR33796 union Included for ILD transactions in total wireless that doesn not go into master esn
                  UNION
                  select distinct esn, merchant_number, call_id
                   from   (WITH t AS (select  ip_esn esns,
                                      ip_purchase purchaseids,
                                     ip_call callids
                              from dual)
                   select nvl(replace(regexp_substr(esns,'[^,]+',1,lvl),'null',''), ip_esn) esn,
                          replace(regexp_substr(purchaseids,'[^,]+',1,lvl),'null','') merchant_number,
                          replace(regexp_substr(callids,'[^,]+',1,lvl),'null','') call_id
                   from  (select esns,purchaseids,callids, level lvl
                          from   t
                          connect by level <= length(purchaseids) - length(replace(purchaseids,',')) + 1)
                  )
                  ) p,
                  sa.TABLE_X_PURCH_DTL PDTL,
                  sa.TABLE_X_PURCH_HDR PHDR
             WHERE PDTL.X_RED_CARD_NUMBER = p.merchant_number
             and   PHDR.OBJID = PDTL.X_PURCH_DTL2X_PURCH_HDR
             and   phdr.x_esn = p.esn
             and   phdr.x_ics_rcode in ('1','100')
             and   phdr.x_ics_rflag in ('SOK', 'ACCEPT')
             ) pdtl
group by
      esn, merchant_ref_number, price, e911_tax, usf_tax, rcrf_tax, discount, tax, total, purch_hdr2creditcard, purch_hdr2bank_acct, payment_type,
      get_plan_desc, get_others_desc, e911_fee_qty
             ) pdtl
             group by
                 esn, merchant_ref_number, price, e911_tax, usf_tax, rcrf_tax, discount, tax, total, purch_hdr2creditcard, purch_hdr2bank_acct, payment_type
             ) purch,
             table_part_class pc,
             table_part_num pn,
             table_mod_level ml,
             table_part_inst pi,
             sa.table_contact c
       where pi.part_serial_no = purch.esn
       and   pi.x_domain ='PHONES'
       and   pi.n_part_inst2part_mod = ml.objid
       and   ml.part_info2part_num = pn.objid
       and   pn.part_num2part_class = pc.objid
       and   c.objid(+) = pi.x_part_inst2contact  --grab contact in the esn
       )
   loop

       -----------------------------------------------------------------------
       -- Check if ESN has OTA Pending
       select count(*)
       into   cnt_ota_pending
       from   table_x_code_hist h,
              table_x_code_hist_temp ht,
              table_x_call_trans t
       where  t.x_service_id = rec.esn
       and    h.code_hist2call_trans (+) = t.objid
       and    ht.x_code_temp2x_call_trans (+) = t.objid
       and    nvl(h.x_code_accepted,'OTAPENDING') = 'OTAPENDING'
       and    nvl(h.x_code_type,ht.x_type) is not null;

       esnTransactionDetail_rslt.part_class     := rec.part_class;
       esnTransactionDetail_rslt.esn            := rec.esn;
       esntransactiondetail_rslt.ref_number     := rec.merchant_ref_number;
       esnTransactionDetail_rslt.creditcard_id  := rec.purch_hdr2creditcard;
       esnTransactionDetail_rslt.bankaccount_id := rec.purch_hdr2bank_acct;
       esntransactiondetail_rslt.price          := rec.price;
       esntransactiondetail_rslt.discount       := rec.discount;
       esntransactiondetail_rslt.e911_tax       := rec.e911_tax;
       esntransactiondetail_rslt.usf_tax        := rec.usf_tax;
       esntransactiondetail_rslt.rcrf_tax       := rec.rcrf_tax;
       esntransactiondetail_rslt.tax            := rec.tax;
       esnTransactionDetail_rslt.total          := rec.total;
       esnTransactionDetail_rslt.payment_type   := rec.payment_type;
       --esnTransactionDetail_rslt.red_code       := rec.red_code;
       esnTransactionDetail_rslt.item_desc      := rec.item_description;
       if cnt_ota_pending > 0 then
           esntransactiondetail_rslt.ota_pending := 'Pending';
       else
           esntransactiondetail_rslt.ota_pending := 'NA';
       end if;
       esnTransactionDetail_rslt.x_sequence    := rec.x_sequence;
       esnTransactionDetail_rslt.contact_email := rec.e_mail;
       esnTransactionDetail_rslt.paid_until    := rec.paid_until;
       esnTransactionDetail_rslt.quantity      := rec.quantity;
       pipe row (esnTransactionDetail_rslt);

      -----------------------------------------------------------------------
      --  Adding to totals
       esntransactiondetail_total.price    := esntransactiondetail_rslt.price + esntransactiondetail_total.price;
       esntransactiondetail_total.discount  := esntransactiondetail_rslt.discount + esntransactiondetail_total.discount;
       esntransactiondetail_total.e911_tax := esntransactiondetail_rslt.e911_tax + esntransactiondetail_total.e911_tax;
       esntransactiondetail_total.usf_tax  := esntransactiondetail_rslt.usf_tax + esntransactiondetail_total.usf_tax;
       esntransactiondetail_total.rcrf_tax := esntransactiondetail_rslt.rcrf_tax + esntransactiondetail_total.rcrf_tax;
       esntransactiondetail_total.tax      := esntransactiondetail_rslt.tax + esntransactiondetail_total.tax;
       esntransactiondetail_total.total    := esntransactiondetail_rslt.total + esntransactiondetail_total.total;
       esntransactiondetail_total.quantity  := esnTransactionDetail_rslt.quantity + esntransactiondetail_total.quantity;
   END LOOP;

   esntransactiondetail_total.esn          := 'TOTAL';
   esnTransactionDetail_rslt.paid_until    := null;
   pipe row (esntransactiondetail_total);

   RETURN;
  END getEsnTransactionDetail;

function get_ESN_contact_info(
    ip_esn in varchar2
) return adfcrm_esn_structure
is
    esn_tab  sa.adfcrm_esn_structure := sa.adfcrm_esn_structure();
BEGIN
    for rec in (select
                      c.first_name          contact_first_name,
                      c.last_name           contact_last_name,
                      c.e_mail              contact_email,
                      c.objid               contact_objid,
                      bo.org_id             brand_name,
                      wu_c.first_name       acct_contact_first_name,
                      wu_c.last_name        acct_contact_last_name,
                      wu_c.e_mail           acct_contact_email,
                      wu_c.objid            acct_contact_objid
                from
                      sa.table_part_inst           pi
                     ,sa.TABLE_MOD_LEVEL           ML
                     ,sa.TABLE_PART_NUM            PN
                     ,sa.TABLE_BUS_ORG             BO
                     ,sa.table_contact             c
                     ,sa.table_x_contact_part_inst conpi
                     ,sa.table_contact             wu_c
                where 1 = 1
                and   pi.part_serial_no = ip_esn
                and   pi.x_domain = 'PHONES'
                and   ml.objid = pi.n_part_inst2part_mod
                AND   PN.OBJID = ML.PART_INFO2PART_NUM
                AND   BO.OBJID = PN.PART_NUM2BUS_ORG
                and   c.objid = pi.x_part_inst2contact  --grab contact in the esn.
                and   conpi.x_contact_part_inst2part_inst = pi.objid
                and   wu_c.objid =  conpi.x_contact_part_inst2contact  --grab contact in the account.
                )
    loop
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('contact_first_name', rec.contact_first_name);
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('contact_last_name', rec.contact_last_name);
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('contact_email', rec.contact_email);
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('contact_objid', rec.contact_objid);
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('brand_name', rec.brand_name);
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('acct_contact_first_name', rec.acct_contact_first_name);
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('acct_contact_last_name', rec.acct_contact_last_name);
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('acct_contact_email', rec.acct_contact_email);
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('acct_contact_objid', rec.acct_contact_objid);
    end loop;

    return esn_tab;
end get_ESN_contact_info;

function get_Service_Plan_Script(
  ip_objid             sa.x_service_plan.objid%type,
  ip_language          varchar2
) return varchar2
IS
    V_SCRIPT_TEXT VARCHAR2(4000);
begin
    V_SCRIPT_TEXT := get_Service_Plan_Script(ip_objid,ip_language,NULL);
    return V_SCRIPT_TEXT;
end;

function get_Service_Plan_Script(
    ip_objid             sa.x_service_plan.objid%type,
    ip_language          varchar2,
    ip_brand_name         varchar2
  ) return varchar2
is
    cursor get_brand (ip_sp_objid in number) is
        select sa.get_param_by_name_fun(tpc.name ,'BUS_ORG')
        from  TABLE_PART_CLASS TPC,
              sa.adfcrm_serv_plan_class_matview spc
        where tpc.objid = spc.part_class_objid
        and   sa.get_param_by_name_fun(tpc.name ,'BUS_ORG') <> 'NOT FOUND'
        and   spc.sp_objid = ip_sp_objid;

    V_brand_name  VARCHAR2(100);
    v_language      VARCHAR2(100);
    V_SP_OBJID    sa.x_service_plan.objid%type;
    V_SCRIPT_TYPE VARCHAR2(100);
    V_SCRIPT_ID   VARCHAR2(100);
    V_SCRIPT_TEXT VARCHAR2(4000);
    OP_OBJID VARCHAR2(200);
    OP_DESCRIPTION VARCHAR2(200);
    OP_PUBLISH_BY VARCHAR2(200);
    OP_PUBLISH_DATE DATE;
    op_sm_link VARCHAR2(200);
BEGIN
    V_SP_OBJID    := -1;
    V_SCRIPT_ID   := '';
    V_SCRIPT_TEXT := '';

    IF ip_objid IS NOT NULL THEN
    BEGIN
        SELECT sa.ADFCRM_GET_SERV_PLAN_VALUE(SP.OBJID,'SCRIPT TYPE') SCRIPT,
               SP.OBJID
        INTO   V_SCRIPT_ID, V_SP_OBJID
        FROM   X_SERVICE_PLAN SP
        WHERE  OBJID = ip_objid;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             BEGIN
                SELECT sa.ADFCRM_GET_SERV_PLAN_VALUE(SPXPP.PROGRAM_PARA2X_SP,'SCRIPT TYPE') SCRIPT,
                       SPXPP.PROGRAM_PARA2X_SP  SP_OBJID
                INTO   V_SCRIPT_ID, V_SP_OBJID
                FROM   MTM_SP_X_PROGRAM_PARAM SPXPP
                WHERE  SPXPP.X_SP2PROGRAM_PARAM = ip_objid
                AND   (NVL(sa.adfcrm_GET_SERV_PLAN_VALUE(SPXPP.PROGRAM_PARA2X_SP,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') IN ('AVAILABLE','ENROLL_ALLOW') OR
                       NVL(sa.adfcrm_GET_SERV_PLAN_VALUE(SPXPP.PROGRAM_PARA2X_SP,'SERVICE_PLAN_PURCHASE_TAS'),'NOT AVAILABLE') IN ('AVAILABLE','ENROLL_ALLOW')
                      )
                and   sa.ADFCRM_GET_SERV_PLAN_VALUE(SPXPP.PROGRAM_PARA2X_SP,'RECURRING_SERVICE_PLAN') is null
                AND    ROWNUM < 2;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     V_SCRIPT_ID   := '';
                     V_SP_OBJID    := -1;
             END;
    END;

    IF V_SCRIPT_ID IS NOT NULL
    THEN
--dbms_output.put_line('********line 421  script='||V_SCRIPT_TYPE||'_'||V_SCRIPT_ID);
        V_SCRIPT_TYPE := substr(V_SCRIPT_ID,1,instr(V_SCRIPT_ID,'_',1,1)-1);
        V_SCRIPT_ID := SUBSTR(V_SCRIPT_ID,-(length(V_SCRIPT_ID)-INSTR(V_SCRIPT_ID,'_',1,1)));

        if ip_language is null then
           v_language := 'ENGLISH';
        else
           select decode(upper(substr(ip_language,1,2)),'EN','ENGLISH','SPANISH')
           into v_language
           from dual;
        end if;

        if ip_brand_name is null then
            open get_brand(V_SP_OBJID);
            fetch get_brand into v_brand_name;
            close get_brand;
            if V_brand_name is null then
                V_brand_name := 'GENERIC';
            end if;
        else
            v_brand_name := ip_brand_name;
        end if;
--dbms_output.put_line('********line 456  V_brand_name='||V_brand_name);
        sa.SCRIPTS_PKG.GET_SCRIPT_PRC(
            IP_SOURCESYSTEM => 'WEB',
            IP_brand_name => V_brand_name,
            IP_SCRIPT_TYPE => V_SCRIPT_TYPE,
            IP_SCRIPT_ID => V_SCRIPT_ID,
            IP_LANGUAGE => v_language,
            IP_CARRIER_ID => NULL,
            IP_PART_CLASS => NULL,
            OP_OBJID => OP_OBJID,
            OP_DESCRIPTION => OP_DESCRIPTION,
            OP_SCRIPT_TEXT => V_SCRIPT_TEXT,
            OP_PUBLISH_BY => OP_PUBLISH_BY,
            OP_PUBLISH_DATE => OP_PUBLISH_DATE,
            op_sm_link => op_sm_link
        );
    END IF;
    END IF;

    return V_SCRIPT_TEXT;
END get_Service_Plan_Script;

function get_service_plan_added(
    ip_purchase in varchar2
) return number
IS
BEGIN
    return get_service_plan_added(null, null, ip_purchase);
END get_service_plan_added;

function get_service_plan_added(
/*************** ************************************************
 ** Return the service plan objid added in the                 **
 ** purchase, redemption, enrollment                           **
 ****************************************************************/
    ip_esn in varchar2,
    ip_call in varchar2,
    ip_purchase in varchar2  --X_PROGRAM_PURCH_HDR.x_merchant_ref_number or TABLE_X_RED_CARD.x_red_code
) return number
IS
    cursor get_purchases (ip_param_list varchar2)
    is
    select purchase_id
    from
          (select distinct *
                   from  (with t as (select ip_param_list purchaseid  from dual)
                   select replace(regexp_substr(purchaseid,'[^,]+',1,lvl),'null','') purchase_id
                   from  (select purchaseid, level lvl
                          from   t
                          connect by level <= length(purchaseid) - length(replace(purchaseid,',')) + 1)
           )) p;

    get_purchases_rec    get_purchases%rowtype;

    cursor get_calls (ip_param_list varchar2)
    is
    select call_id
    from
          (select distinct *
                   from  (with t as (select ip_param_list callid  from dual)
                   select replace(regexp_substr(callid,'[^,]+',1,lvl),'null','') call_id
                   from  (select callid, level lvl
                          from   t
                          connect by level <= length(callid) - length(replace(callid,',')) + 1)
           )) p;

    get_calls_rec    get_calls%rowtype;

    cursor get_esn_info (ip_esn sa.table_part_inst.part_serial_no%type)
    is
    select  pi.part_serial_no esn, pc.objid part_class_objid, pc.name part_class, bo.org_id, bo.objid bus_org_objid
    from    table_part_inst pi,
            table_mod_level ml,
            table_part_num pn,
            table_part_class pc,
            table_bus_org bo
    where pi.part_serial_no = ip_esn
    and   pi.x_domain = 'PHONES'
    and   ml.objid = pi.n_part_inst2part_mod
    and   pn.objid = ml.part_info2part_num
    and   pc.objid = pn.part_num2part_class
    and   bo.objid = pn.part_num2bus_org;

    get_esn_info_rec    get_esn_info%rowtype;

    V_OBJID    NUMBER;
BEGIN
   open get_esn_info(ip_esn);
   fetch get_esn_info into get_esn_info_rec;
   if get_esn_info%found then

    V_OBJID    := -1;
    IF ip_purchase IS NOT NULL
    THEN
    OPEN get_purchases(ip_purchase);
    LOOP
    FETCH get_purchases INTO get_purchases_rec;
    EXIT WHEN get_purchases%NOTFOUND OR V_OBJID <> -1;
        dbms_output.put_line('get_service_plan_added Looking with get_purchases_rec.purchase_id ref :'||get_purchases_rec.purchase_id);
        BEGIN
             SELECT SPXPP.PROGRAM_PARA2X_SP
             INTO   V_OBJID
             FROM   X_PROGRAM_PURCH_HDR PPHDR,
                    X_PROGRAM_PURCH_DTL PPDTL,
                    x_program_enrolled pe,
                    MTM_SP_X_PROGRAM_PARAM SPXPP,
                    adfcrm_serv_plan_class_matview spc
             WHERE PPHDR.x_merchant_ref_number  = get_purchases_rec.purchase_id
              AND  PPDTL.PGM_PURCH_DTL2PROG_HDR = PPHDR.OBJID
              AND  pe.objid = PPDTL.PGM_PURCH_DTL2PGM_ENROLLED
              AND  SPXPP.X_SP2PROGRAM_PARAM = pe.PGM_ENROLL2PGM_PARAMETER
              --check plans compatible with esn
              and  spc.part_class_objid = get_esn_info_rec.part_class_objid
              and  spc.sp_objid = SPXPP.PROGRAM_PARA2X_SP
              AND  (NVL(sa.adfcrm_GET_SERV_PLAN_VALUE(spc.sp_objid,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') IN ('AVAILABLE','ENROLL_ALLOW') OR
                    NVL(sa.adfcrm_GET_SERV_PLAN_VALUE(spc.sp_objid,'SERVICE_PLAN_PURCHASE_TAS'),'NOT AVAILABLE') IN ('AVAILABLE','ENROLL_ALLOW')
                   )
              and   sa.ADFCRM_GET_SERV_PLAN_VALUE(spc.sp_objid,'RECURRING_SERVICE_PLAN') is null
              ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 BEGIN
                    SELECT spc_pin.sp_objid
                    INTO   V_OBJID
                    FROM   (select part_number, part_num2part_class
                            from   (select x_red_card2part_mod mod_level_id
                                    from table_x_red_card
                                    where x_red_code = get_purchases_rec.purchase_id
                                    union
                                    select n_part_inst2part_mod mod_level_id
                                    from table_part_inst
                                    where x_red_code = get_purchases_rec.purchase_id) rc
                                    ,table_mod_level ml
                                    ,table_part_num pn
                            where ml.objid = rc.mod_level_id
                            and pn.objid = ml.part_info2part_num) pn,
                           adfcrm_serv_plan_class_matview spc_pin,
                           adfcrm_serv_plan_class_matview spc
                    WHERE  spc_pin.part_class_objid = pn.part_num2part_class
                    --check plans compatible with esn
                    and    spc.part_class_objid = get_esn_info_rec.part_class_objid
                    and    spc.sp_objid = spc_pin.sp_objid
                    and    (nvl(sa.adfcrm_get_serv_plan_value(spc.sp_objid,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE'  OR
                            NVL(sa.adfcrm_GET_SERV_PLAN_VALUE(spc.sp_objid,'SERVICE_PLAN_PURCHASE_TAS'),'NOT AVAILABLE') = 'AVAILABLE'
                            );
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         V_OBJID    := -1;
                 END;
        END;
    END LOOP;
    CLOSE get_purchases;
    END IF;

    IF ip_call IS NOT NULL
    THEN
    OPEN get_calls(ip_call);
    LOOP
    FETCH get_calls INTO get_calls_rec;
    EXIT WHEN get_calls%NOTFOUND OR V_OBJID <> -1;
        dbms_output.put_line('get_service_plan_added Looking with get_calls_rec.call_id ref :'||get_calls_rec.call_id);
        BEGIN
            select spc_pin.sp_objid
            INTO   V_OBJID
            from   (select part_number, part_num2part_class
                   from   (select x_red_card2part_mod mod_level_id
                           from table_x_red_card
                           where x_red_code = (select ct.x_reason red_code from table_x_call_trans ct where ct.objid = get_calls_rec.call_id)
                           union
                           select n_part_inst2part_mod mod_level_id
                           from table_part_inst
                           where x_red_code = (select ct.x_reason red_code from table_x_call_trans ct where ct.objid = get_calls_rec.call_id)
                           ) rc
                           ,table_mod_level ml
                           ,table_part_num pn
                   where ml.objid = rc.mod_level_id
                   and pn.objid = ml.part_info2part_num) pn,
                   adfcrm_serv_plan_class_matview spc_pin,
                   adfcrm_serv_plan_class_matview spc
            where  spc_pin.part_class_objid = pn.part_num2part_class
            --check plans compatible with esn
            and    spc.part_class_objid = get_esn_info_rec.part_class_objid
            and    spc.sp_objid = spc_pin.sp_objid
            and    (nvl(sa.adfcrm_get_serv_plan_value(spc.sp_objid,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE'   OR
                    NVL(sa.adfcrm_GET_SERV_PLAN_VALUE(spc.sp_objid,'SERVICE_PLAN_PURCHASE_TAS'),'NOT AVAILABLE') = 'AVAILABLE'
                   );
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 BEGIN
                    select spc_pin.sp_objid
                    INTO   V_OBJID
                    from   sa.table_x_red_card rc,
                           sa.table_mod_level ml,
                           table_part_num pn,
                           adfcrm_serv_plan_class_matview spc_pin,
                           adfcrm_serv_plan_class_matview spc
                    where  rc.red_card2call_trans = get_calls_rec.call_id
                    and    ml.objid = rc.x_red_card2part_mod
                    and    pn.objid = ml.part_info2part_num
                    AND    spc_pin.part_class_objid = pn.part_num2part_class
                    --check plans compatible with esn
                    and    spc.part_class_objid = get_esn_info_rec.part_class_objid
                    and    spc.sp_objid = spc_pin.sp_objid
                    and    (nvl(sa.adfcrm_get_serv_plan_value(spc.sp_objid,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE' OR
                            NVL(sa.adfcrm_GET_SERV_PLAN_VALUE(spc.sp_objid,'SERVICE_PLAN_PURCHASE_TAS'),'NOT AVAILABLE') = 'AVAILABLE'
                           );
                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                         BEGIN
                            select  xsp.objid
                            INTO   V_OBJID
                            from sa.table_x_call_trans ct,
                                 sa.x_service_plan_site_part spsp,
                                 sa.x_service_plan xsp,
                                 adfcrm_serv_plan_class_matview spc
                            where ct.objid = get_calls_rec.call_id
                            and  spsp.table_site_part_id = ct.call_trans2site_part
                            and   xsp.objid = spsp.x_service_plan_id
                            --check plans compatible with esn
                            and    spc.part_class_objid = get_esn_info_rec.part_class_objid
                            and    spc.sp_objid = xsp.objid
                            and    (nvl(sa.adfcrm_get_serv_plan_value(spc.sp_objid,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE' OR
                                    NVL(sa.adfcrm_GET_SERV_PLAN_VALUE(spc.sp_objid,'SERVICE_PLAN_PURCHASE_TAS'),'NOT AVAILABLE') = 'AVAILABLE'
                                   );
                         EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                 V_OBJID    := -1;
                         END;
                 END;
        END;
    END LOOP;
    CLOSE get_calls;
    END IF;

    end if;
    close get_esn_info;

    return V_OBJID;
exception
  when others then
    return '-10000';
END get_service_plan_added;

  function get_others_added (ip_solution_name sa.adfcrm_solution.solution_name%type,
                             ip_esn sa.table_part_inst.part_serial_no%type,
                             ip_language varchar2,
                             ip_param_list varchar2,
                             ip_transaction_id varchar2)
/*************** ************************************************
 ** Return the service/program description added in the        **
 ** purchase, redemption, enrollment                           **
 ****************************************************************/
    return varchar2 IS

    cursor get_purchases (ip_param_list varchar2)
    is
    select purchase_id
    from
          (select distinct *
                   from  (with t as (select ip_param_list purchaseid  from dual)
                   select replace(regexp_substr(purchaseid,'[^,]+',1,lvl),'null','') purchase_id
                   from  (select purchaseid, level lvl
                          from   t
                          connect by level <= length(purchaseid) - length(replace(purchaseid,',')) + 1)
           )) p;

    get_purchases_rec    get_purchases%rowtype;

    cursor get_calls (ip_param_list varchar2)
    is
    select call_id
    from
          (select distinct *
                   from  (with t as (select ip_param_list callid  from dual)
                   select replace(regexp_substr(callid,'[^,]+',1,lvl),'null','') call_id
                   from  (select callid, level lvl
                          from   t
                          connect by level <= length(callid) - length(replace(callid,',')) + 1)
           )) p;

    get_calls_rec    get_calls%rowtype;

    script_text  varchar2(4000) := '';
    v_added      varchar2(4000) := '';
    vas_added      varchar2(4000) := '';
    cnt_added    number;
 BEGIN
    cnt_added := 0;
    IF ip_param_list IS NOT NULL
    THEN
    OPEN get_purchases(ip_param_list);
    LOOP
    FETCH get_purchases INTO get_purchases_rec;
    EXIT WHEN get_purchases%NOTFOUND;
       dbms_output.put_line('get_others_added Looking with ref :'||get_purchases_rec.purchase_id);
       BEGIN
           select vas_param_value
           INTO   vas_added
           from  vas_params_view
           where vas_service_id = (
                    SELECT vas.vas_service_id
                    FROM   (select part_number, part_num2part_class
                            from   (select x_red_card2part_mod mod_level_id
                                    from table_x_red_card
                                    where x_red_code = get_purchases_rec.purchase_id
                                    union
                                    select n_part_inst2part_mod mod_level_id
                                    from table_part_inst
                                    where x_red_code = get_purchases_rec.purchase_id) rc
                                    ,table_mod_level ml
                                    ,table_part_num pn
                            where ml.objid = rc.mod_level_id
                            and pn.objid = ml.part_info2part_num) pn,
                           table_part_class pc,
                           vas_params_view vas
                    WHERE  pc.objid = pn.part_num2part_class
                    and    vas_param_name = 'VAS_CARD_CLASS'
                    and    vas_param_value = pc.name
                    AND    ROWNUM < 2)
           and vas_param_name =  decode(upper(substr(nvl(ip_language,'EN'),1,2)),'EN','VAS_DESCRIPTION_ENGLISH','VAS_DESCRIPTION_SPANISH');

           cnt_added := cnt_added + 1;
--*********CR53171 Add vas description as single item.
           script_text := script_text ||
                                         case
                                         when SCRIPT_TEXT is null then vas_added
                                         else '<br>'|| vas_added
                                         end;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
           BEGIN
              SELECT pp.x_program_name
              INTO   v_added
              FROM   X_PROGRAM_PURCH_HDR PPHDR,
                     X_PROGRAM_PURCH_DTL PPDTL,
                     x_program_enrolled pe,
                     x_program_parameters pp
              WHERE PPHDR.x_merchant_ref_number  = get_purchases_rec.purchase_id
              AND  PPDTL.PGM_PURCH_DTL2PROG_HDR = PPHDR.OBJID
              AND  pe.objid = PPDTL.PGM_PURCH_DTL2PGM_ENROLLED
              AND  pp.objid = pe.PGM_ENROLL2PGM_PARAMETER
              AND  ROWNUM < 2;

              script_text := script_text ||
                             case
                             when SCRIPT_TEXT is null then v_added
                             else '<br>'|| v_added
                             end;
           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                       BEGIN
                                SELECT pn.description
                                INTO   v_added
                                FROM   (select a.n_part_inst2part_mod join_mov_level
                                        FROM   sa.table_part_inst A
                                        where  a.x_red_code = get_purchases_rec.purchase_id
                                        union
                                        select b.x_red_card2part_mod join_mov_level
                                        FROM sa.table_x_red_card b
                                        where b.x_red_code = get_purchases_rec.purchase_id
                                       ) rc,
                                       sa.table_mod_level ml,
                                       sa.table_part_num pn
                                WHERE ml.objid = rc.join_mov_level
                                and  pn.objid = ml.part_info2part_num;

                          script_text := script_text ||
                                         case
                                         when SCRIPT_TEXT is null then v_added
                                         else '<br>'|| v_added
                                         end;
                       EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                               NULL;
                       END;
           END;
       END;
   END LOOP;
   CLOSE get_purchases;
   END IF;

   /** CR53171 code commented
   if cnt_added > 0 then
                     script_text := script_text ||
                                         case
                                         when SCRIPT_TEXT is null then trim(to_char(cnt_added)) ||' ' ||vas_added
                                         else '<br>'|| trim(to_char(cnt_added)) ||' ' ||vas_added
                                         end;
   end if;
   **/

   IF ip_transaction_id IS NOT NULL
   THEN
    OPEN get_calls(ip_transaction_id);
    LOOP
    FETCH get_calls INTO get_calls_rec;
    EXIT WHEN get_calls%NOTFOUND;
    dbms_output.put_line('get_others_added Looking with get_calls_rec.call_id ref :'||get_calls_rec.call_id);
                       BEGIN
                                SELECT pn.description
                                INTO   v_added
                                FROM   (select a.n_part_inst2part_mod join_mov_level, a.x_red_code
                                        FROM   sa.table_part_inst A
                                        where  a.x_red_code = (select ct.x_reason from table_x_call_trans ct where ct.objid = get_calls_rec.call_id)
                                        union
                                        select b.x_red_card2part_mod join_mov_level, b.x_red_code
                                        FROM sa.table_x_red_card b
                                        where b.red_card2call_trans = get_calls_rec.call_id
                                       ) rc,
                                       sa.table_mod_level ml,
                                       sa.table_part_num pn
                                WHERE ml.objid = rc.join_mov_level
                                and  pn.objid = ml.part_info2part_num
                                --CR42459 Avoiding to show the same plan more than one time.
                                and  rc.x_red_code not in
                                       (select purchase_id
                                        from  (select distinct *
                                               from  (with t as (select ip_param_list purchaseid  from dual)
                                                          select replace(regexp_substr(purchaseid,'[^,]+',1,lvl),'null','') purchase_id
                                                          from  (select purchaseid, level lvl
                                                                 from   t
                                                                 connect by level <= length(purchaseid) - length(replace(purchaseid,',')) + 1)
                                                                 ))
                                       )
                                and  rownum < 2;

                          script_text := script_text ||
                                         case
                                         when SCRIPT_TEXT is null then v_added
                                         else '<br>'|| v_added
                                         end;
                       EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                               NULL;
                       END;
    END LOOP;
    CLOSE get_calls;
   END IF;

   script_text := nvl(script_text,'Paygo');

   return script_text||
          case
          when instr(script_text,'<br>',1,1) > 0 then '</br>'
          else ''
          end;
 END get_others_added;

function get_ESN_buckets_info(
    ip_solution in varchar2,
    ip_esn in varchar2,
    ip_call in varchar2,
    ip_purchase in varchar2
) return esnBucketsDetail_tab pipelined
is
  cursor conversion_curs (p_esn varchar2) is
     select c.trans_voice,
            c.trans_text,
            C.TRANS_DATA,
            c.trans_days,
            MTM.service_plan_objid
     from  sa.table_site_part          sp
          ,sa.x_service_plan           xsp
          ,sa.x_service_plan_site_part xspsp
          ,sa.x_surepay_conv c
          ,sa.sp_mtm_surepay mtm
     where sp.x_service_id =  p_esn
     --and sp.objid = (SELECT MAX(objid)
     --                  from table_site_part
     --                  WHERE x_service_id =  p_esn)
     and   xspsp.table_site_part_id = sp.objid
     and   xsp.objid = xspsp.x_service_plan_id
     and   C.OBJID = MTM.SUREPAY_CONV_OBJID
     AND   MTM.service_plan_objid = xsp.objid
     ORDER BY sp.install_date DESC;

  conv_rec               conversion_curs%rowtype;
  esnBucketsDetail_rslt  esnBucketsDetail_rec;
BEGIN
    --------------------------------------------------------------------------------------
    -- Return values for solution other than upgrade, enrollments and portability
    --------------------------------------------------------------------------------------
    if ip_solution not in ('UPGRADE_AUTO_PORT'
                          ,'UPGRADE_ESN_EXCHANGE'
                          ,'UPGRADE_MANUAL_PORT'
                          ,'ENROLLMENT_PG'
                          ,'CANCEL_ENROLLMENT_PG'
                          ,'PORTS_PG'
                          ,'PORTS_REACTIVATION'
                          ,'PORTS_MANUAL'
                          ,'COMPLETE_PORT_PG') and
        ip_solution not like 'UPGRADE%'
    then

    for rec in (select ct.x_service_id
                      ,ct.x_total_units       voice_units
                      ,ct.x_new_due_date      due_date
                      ,ext.x_total_days       days
                      ,ext.x_total_sms_units  sms_units
                      ,ext.x_total_data_units data_units
                from   table_x_call_trans ct,
                       table_x_call_trans_ext ext
            --    where  ct.objid = ip_call commented for CR47593 and added below for multiple transaction id
            where ct.objid IN ( select purchase_id
                                from
                               (with t as (select ip_call purchaseid  from dual)
                                  select replace(regexp_substr(purchaseid,'[^,]+',1,lvl),'null','') purchase_id
                                  from  (select purchaseid, level lvl
                                  from   t
                                  connect by level <= length(purchaseid) - length(replace(purchaseid,',')) + 1)
           ))
                and    ext.call_trans_ext2call_trans (+) = ct.objid
                )
    loop
        esnBucketsDetail_rslt.esn := rec.x_service_id;
        esnBucketsDetail_rslt.days  := rec.days;
        esnBucketsDetail_rslt.voice_units := rec.voice_units;
        if (  --ip_solution in ('UPGRADE_AUTO_PORT','UPGRADE_ESN_EXCHANGE','UPGRADE_MANUAL_PORT')
            ip_solution like 'UPGRADE%'
        and nvl(rec.sms_units,0) = 0)
        then
            esnBucketsDetail_rslt.sms_units := rec.voice_units;
        else
            esnBucketsDetail_rslt.sms_units := rec.sms_units;
        end if;
        if (--ip_solution in ('UPGRADE_AUTO_PORT','UPGRADE_ESN_EXCHANGE','UPGRADE_MANUAL_PORT')
            ip_solution like 'UPGRADE%'
        and nvl(rec.data_units,0) = 0)
        then
            esnBucketsDetail_rslt.data_units := rec.voice_units;
        else
            esnBucketsDetail_rslt.data_units := rec.data_units;
        end if;
        esnBucketsDetail_rslt.due_date := rec.due_date;

        pipe row (esnBucketsDetail_rslt);
    end loop;

/** DO NOT IMPLEMENT THIS
    for rec in (select PP.OBJID OBJID_PROG_PARAM,
                       PN.X_REDEEM_DAYS  days,
                       pn.x_redeem_units redeem_units,
                       pe.x_esn
                from
                       X_PROGRAM_PURCH_HDR HDR,
                       X_PROGRAM_PURCH_DTL DTL,
                       X_PROGRAM_ENROLLED PE,
                       X_PROGRAM_PARAMETERS PP,
                       TABLE_PART_NUM PN
                where HDR.X_MERCHANT_REF_NUMBER = ip_purchase
                and   DTL.PGM_PURCH_DTL2PROG_HDR = HDR.OBJID+0
                and   PE.OBJID = DTL.PGM_PURCH_DTL2PGM_ENROLLED
                and   PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
                and   pn.objid = PP.PROG_PARAM2PRTNUM_MONFEE
                )
    loop

        OPEN conversion_curs(rec.x_esn);
        FETCH conversion_curs INTO conv_rec;
        CLOSE conversion_curs;

        esnBucketsDetail_rslt.esn := rec.x_esn;
        esnBucketsDetail_rslt.days  := conv_rec.trans_days * rec.days;
        esnBucketsDetail_rslt.voice_units := conv_rec.trans_voice * rec.redeem_units;
        esnBucketsDetail_rslt.sms_units := conv_rec.trans_text * rec.redeem_units;
        esnBucketsDetail_rslt.data_units := conv_rec.trans_data * rec.redeem_units;

        pipe row (esnBucketsDetail_rslt);
    end loop;
DO NOT IMPLEMENT THIS  ***/
    end if;

    RETURN;
end get_ESN_buckets_info;


  function refnumber_by_redcard (
      ip_red_card sa.table_x_red_card.x_red_code%type
  ) return varchar2
  as
    cursor get_refnumber (
        ip_red_card sa.table_x_red_card.x_red_code%type
    ) is
        select x_merchant_ref_number
        from   sa.table_x_red_card rc,
               sa.table_x_purch_dtl pdtl,
               sa.table_x_purch_hdr phdr
        where  rc.x_red_code = ip_red_card
        and    pdtl.x_red_card_number = rc.x_red_code
        and    pdtl.x_smp = rc.x_smp
        and    phdr.objid = pdtl.x_purch_dtl2x_purch_hdr
        and   phdr.x_ics_rcode in ('1','100')
        and   phdr.x_ics_rflag in ('SOK', 'ACCEPT')
        ;

    get_refnumber_rec get_refnumber%rowtype;
    v_ref_number      sa.table_x_purch_hdr.x_merchant_ref_number%type;
  begin
    open get_refnumber(ip_red_card);
    fetch get_refnumber into get_refnumber_rec;
    if get_refnumber%found then
       v_ref_number := get_refnumber_rec.x_merchant_ref_number;
    else
       v_ref_number := '';
    end if;
    close get_refnumber;

    return v_ref_number;
  end refnumber_by_redcard;

function getEasyExchangeScriptName (
    ip_esn in varchar2,      --just one esn
    ip_purchase in varchar2  --comma separated values
    )
return varchar2 IS
  OP_RESULT_SET SYS_REFCURSOR;
  OP_ERROR_CODE VARCHAR2(200);
  op_error_text varchar2(200);
  rows_processed      integer;
  CURRENTWTYPROGRAMS_rec sa.VALUE_ADDEDPRG.CURRENTWTYPROGRAMS_record;
  script_name   varchar2(200);
begin
  script_name := '';
  sa.VALUE_ADDEDPRG.GETCURRENTWARRANTYPROGRAM(
    IP_ESN => IP_ESN,
    OP_RESULT_SET => OP_RESULT_SET,
    OP_ERROR_CODE => OP_ERROR_CODE,
    OP_ERROR_TEXT => OP_ERROR_TEXT
  );

  if op_error_code = 0 and OP_RESULT_SET%isopen then
    FETCH OP_RESULT_SET INTO CURRENTWTYPROGRAMS_rec;
    /** If esn is currently enrolled, then verify if it was purchased in this transaction **/
    if op_result_set%found then
            SELECT COUNT(*)
            INTO   rows_processed
            FROM  (select distinct *
                   from  (WITH t AS (select  ip_esn esn,
                                      ip_purchase purchaseids
                              from dual)
                   select nvl(replace(regexp_substr(esn,'[^,]+',1,lvl),'null',''),ip_esn) esn,
                          replace(regexp_substr(purchaseids,'[^,]+',1,lvl),'null','') merchant_number
                   from  (select esn,purchaseids, level lvl
                          from   t
                          connect by level <= length(purchaseids) - length(replace(purchaseids,',')) + 1)
                  )) p,
                  x_program_purch_hdr phdr,
                  x_program_purch_dtl pdtl
            WHERE phdr.x_merchant_ref_number = p.merchant_number
            and   nvl(phdr.x_amount,0) > 0
            and   pdtl.x_esn = p.esn
            AND   pdtl.pgm_purch_dtl2prog_hdr = phdr.objid
            AND   pdtl.pgm_purch_dtl2pgm_enrolled = CURRENTWTYPROGRAMS_rec.PROG_ID
            and   phdr.x_ics_rcode in ('1','100')
            and   phdr.x_ics_rflag in ('SOK', 'ACCEPT')
            ;

            if rows_processed > 0 then
                script_name := 'EASY_EXCHANGE_ENROLLED';
            end if;
    else
        /*** veriy if esn is eligible ***/
        SELECT COUNT(*)
        INTO rows_processed
        FROM table(sa.VALUE_ADDEDPRG.GETELIGIBLEWTYPROGRAMS(IP_ESN));

        if rows_processed > 0 then
            script_name := 'EASY_EXCHANGE_ELIGIBLE';
        end if;
    end if;
  end if;
  if OP_RESULT_SET%isopen then
     close OP_RESULT_SET;
  end if;
  return script_name;
end getEasyExchangeScriptName;

function getVASservice (
    ip_esn in varchar2 )     --just one esn
return varchar2 IS
  IP_TYPE VARCHAR2(200);
  IP_VALUE VARCHAR2(200);
  servicesforphone sys_refcursor;
  servicesforphone_rec  sa.VAS_PROGRAMS_VIEW%rowtype;
  OP_RETURN_VALUE NUMBER;
  OP_RETURN_STRING VARCHAR2(200);
begin
  ip_type := 'ESN';
  IP_VALUE := ip_esn;

  sa.VAS_MANAGEMENT_PKG.GETAVAILABLESERVICESFORPHONE(
    IP_TYPE => IP_TYPE,
    IP_VALUE => IP_VALUE,
    SERVICESFORPHONE => SERVICESFORPHONE,
    OP_RETURN_VALUE => OP_RETURN_VALUE,
    OP_RETURN_STRING => OP_RETURN_STRING
  );

  if servicesforphone%isopen then
     loop
     fetch servicesforphone into servicesforphone_rec;
     exit when servicesforphone%notfound;
           DBMS_OUTPUT.PUT_LINE('servicesforphone_rec.VAS_NAME = ' || servicesforphone_rec.VAS_NAME);
     end loop;
     close servicesforphone;
  end if;

  return servicesforphone_rec.VAS_NAME;
end getVASservice;

function getServiceVO (
    p_solution_name in varchar2,
    p_esn in varchar2,
    p_language in varchar2,
    p_purchase_id in varchar2,
    p_transaction_id in varchar2,
    p_case_id in varchar2,
    p_check_condition varchar2 default 'BOGO=NO'
    )
return esnServiceVO_tab
pipelined
is
    esnServiceVO_rslt esnServiceVO_rec;
    get_esn_info_rec  get_esn_info%rowtype;

    cursor get_site_part (p_esn in varchar2) is
        select    sp.objid sp_objid,
                sp.x_min,
                sp.x_zipcode
        from    sa.table_site_part           sp
        where    sp.x_service_id =  p_esn
        order by sp.install_date desc
        ;

    get_site_part_rec    get_site_part%rowtype;

    cursor get_line_info (p_min in varchar2) is
        SELECT    CT3.X_CODE_NAME status
        FROM    TABLE_PART_INST PI_LINE,
                TABLE_X_CODE_TABLE CT3
        WHERE  PI_LINE.X_PART_INST_STATUS = CT3.X_CODE_NUMBER
        AND    CT3.X_CODE_TYPE = 'LS'
        AND    PI_LINE.PART_SERIAL_NO = p_min
        AND    PI_LINE.X_DOMAIN = 'LINES';

    get_line_info_rec  get_line_info%rowtype;

    cursor get_serv_plan (p_site_part_id in number) is
        select    xsp.objid service_plan_objid,
                xsp.webcsr_display_name
        from    sa.x_service_plan           xsp,
                sa.x_service_plan_site_part xspsp
        where 1 = 1
        and xspsp.table_site_part_id = p_site_part_id
        and xsp.objid = xspsp.x_service_plan_id;

    get_serv_plan_rec get_serv_plan%rowtype;

    cursor get_contact (p_contact_id in number) is
        select c.first_name, c.last_name, c.e_mail, c.objid contact_objid
        from sa.table_contact             c
        where c.objid = p_contact_id;

    get_contact_rec  get_contact%rowtype;
    v_initial_act_date      date;
    v_is_refurb             number;
    v_days_card_reserved    number;
    v_language                varchar2(30);
  P_SERVICE_PLAN_OBJID VARCHAR2(200);
  P_SERVICE_TYPE VARCHAR2(200);
  P_PROGRAM_TYPE VARCHAR2(200);
  P_NEXT_CHARGE_DATE DATE;
  P_PROGRAM_UNITS NUMBER;
  P_PROGRAM_DAYS NUMBER;
  P_RATE_PLAN VARCHAR2(200);
  P_ERROR_NUM NUMBER;
  v_part_class VARCHAR2(30);
  v_script_bus_org VARCHAR2(30);
  cnt_eligible_vas number := 0;
  v_solution_name2 varchar2(100);
  upg_vas_script_type varchar2(100);
  upg_vas_script_id varchar2(100);
BEGIN
    if upper(p_language) = 'ES'
    then
        v_language := 'SPANISH';
    else
        v_language := 'ENGLISH';
    end if;

    esnServiceVO_rslt.serial_number := p_esn;
    open get_site_part(p_esn);
    fetch get_site_part into get_site_part_rec;
    close get_site_part;

    open get_line_info(get_site_part_rec.x_min);
    fetch get_line_info into get_line_info_rec;
    close get_line_info;

   SELECT COUNT(1) is_refurb
   into v_is_refurb
   from table_site_part sp_a
   WHERE sp_a.x_service_id = p_esn
   AND sp_a.x_refurb_flag = 1;

   if v_is_refurb = 0 then
      --nonrefurb_act_date
      select min(install_date) initial_act_date
      into   v_initial_act_date
      from   sa.table_site_part
      where  x_service_id = p_esn
      and    part_status || '' IN ('Active','Inactive');
   else
       --refurb_act_date
       select min(install_date) initial_act_date
       into   v_initial_act_date
       from table_site_part sp_b
       WHERE sp_b.x_service_id = p_esn
       AND sp_b.part_status || '' IN ('Active','Inactive')
       AND NVL(sp_b.x_refurb_flag,0) <> 1;
    end if;

    esnServiceVO_rslt.x_min := get_site_part_rec.x_min;
    esnServiceVO_rslt.line_status := get_line_info_rec.status;
    esnServiceVO_rslt.orig_act_date := v_initial_act_date;

    --****************************************** flag to display sections in the page ******************************************
    esnServiceVO_rslt.show_billing := 'false';
    if p_solution_name in
    ('ENROLLMENT_PG'
    ,'ENROLLMENT_PAYNOW_PG'
    ,'ENROLLMENT_VAS_PG'
    ,'ACTIVATION_PG_PURCHASE'
    ,'REDEMPTION_PG_PURCHASE'
    ,'PORTS_PG_PURCHASE'
    ,'REACTIVATION_PG_PURCHASE'
    ,'UPGRADE_MANUAL_PORT_PURCHASE'
    ,'UPGRADE_ESN_EXCHANGE_PURCHASE'
    ,'UPGRADE_AUTO_PORT_PURCHASE'
    ,'UPGRADE_PURCHASE'
    ,'PURCHASE_PG'
    ,'PURCHASE_OTHER_PG'
    ) or p_solution_name like 'UPGRADE%'
    then
        esnServiceVO_rslt.show_billing := 'true';
    end if;

    esnServiceVO_rslt.show_item_bill := 'false';
    if p_solution_name in ('ENROLLMENT_PAYNOW_PG')
    then
        esnServiceVO_rslt.show_item_bill := 'true';
    end if;

    esnServiceVO_rslt.show_granted := 'false';
    if p_solution_name in ('COMPENSATION_PG','REPLACEMENT_PG')
    then
        esnServiceVO_rslt.show_granted := 'true';
    end if;

    esnServiceVO_rslt.show_service := 'true';
    esnServiceVO_rslt.show_email_opt :=  'true';
    if p_solution_name in ('CANCEL_PORT_PG','COMPLETE_PORT_PG','MAKE_RECURRENT_PG','ENROLLMENT_PAYNOW_PG','STOP_RECURRENT_PG','CANCEL_VAS_ENROLLMENT_PG','ENROLLMENT_VAS_PG')
    then
        esnServiceVO_rslt.show_service := 'false';
        esnServiceVO_rslt.show_email_opt :=  'false';
    end if;
    if p_solution_name in ('MAKE_RECURRENT_PG','STOP_RECURRENT_PG','CANCEL_VAS_ENROLLMENT_PG','ENROLLMENT_VAS_PG')
    then
        esnServiceVO_rslt.show_email_opt :=  'true';
    end if;
    open get_esn_info(p_esn);
    fetch get_esn_info into get_esn_info_rec;
    if get_esn_info%notfound then
        close get_esn_info;
        return;
    end if;
    close get_esn_info;
    v_part_class := get_esn_info_rec.part_class_name;
    v_script_bus_org := sa.adfcrm_scripts.get_script_brand(ip_pc => v_part_class);

    esnServiceVO_rslt.org_id := get_esn_info_rec.org_id;
    esnServiceVO_rslt.x_manufacturer := get_esn_info_rec.x_manufacturer;

    esnServiceVO_rslt.upgrade_flow := 'false';
    if p_solution_name like 'UPGRADE%'
    then
        esnServiceVO_rslt.upgrade_flow := 'true';
    end if;

    esnServiceVO_rslt.hide_min := sa.adfcrm_cust_service.hide_min(p_esn);

    --***************************CR49058 DISPLAY VAS ENROLLMENT INFORMATION BEGIN ******************************************
    esnServiceVO_rslt.vas_prg_script_text := null;
    esnServiceVO_rslt.vas_auto_pay := null;
    esnServiceVO_rslt.vas_enroll_date := null;
    esnServiceVO_rslt.vas_next_charge_date := null;
    esnServiceVO_rslt.vas_enroll_price := null;
    esnServiceVO_rslt.vas_header_script := null;
    esnServiceVO_rslt.vas_footer_script := null;
    if esnServiceVO_rslt.org_id = 'TRACFONE'
    then

        if p_solution_name in ('ENROLLMENT_PG'
                           ,'ENROLLMENT_PAYNOW_PG'
                           ,'ACTIVATION_PG_PURCHASE'
                           ,'REDEMPTION_PG_PURCHASE'
                           ,'MAKE_RECURRENT_PG'
                           ,'STOP_RECURRENT_PG'
                           ,'ENROLLMENT_VAS_PG'
                           ,'CANCEL_VAS_ENROLLMENT_PG')
        then
            for vasrec in (
                            select
                                  mv.x_prg_script_text
                                  ,decode(nvl(vas.auto_pay_enrolled,'N'),'N','NO','YES') auto_pay_enrolled
                                  ,vas.x_enrolled_date
                                  ,vas.next_charge_date
                                  ,vas.program_purch_hdr_objid, pe.pgm_enroll2prog_hdr
                                  ,pphdr.x_merchant_ref_number
                                  ,vas.x_retail_price
                            from table(sa.adfcrm_vas.get_enrolled_vas_services(p_esn)) vas,
                                  sa.adfcrm_prg_enrolled_script_mv mv,
                                  sa.x_program_enrolled pe,
                                  sa.x_program_purch_hdr pphdr
                            where mv.prg_objid = vas.prog_id
                            and mv.x_language = upper(p_language)
                            and pe.objid = vas.program_enrolled_id
                            and pphdr.objid (+) = pe.pgm_enroll2prog_hdr
                            )
            loop
                if (p_purchase_id like '%'|| vasrec.x_merchant_ref_number||'%') or
                   p_solution_name in ('MAKE_RECURRENT_PG','STOP_RECURRENT_PG','CANCEL_VAS_ENROLLMENT_PG')
                then
                    esnServiceVO_rslt.vas_prg_script_text := vasrec.x_prg_script_text;
                    esnServiceVO_rslt.vas_auto_pay := vasrec.auto_pay_enrolled;
                    esnServiceVO_rslt.vas_enroll_date := to_char(vasrec.x_enrolled_date,'MM/DD/YYYY');
                    esnServiceVO_rslt.vas_next_charge_date := to_char(vasrec.next_charge_date,'MM/DD/YYYY');
                    esnServiceVO_rslt.vas_enroll_price := vasrec.x_retail_price;
                    --Transaction summary solution script will display the script
                    If p_solution_name not in ('MAKE_RECURRENT_PG','ENROLLMENT_PAYNOW_PG','ENROLLMENT_VAS_PG','STOP_RECURRENT_PG')
                    then
                        esnServiceVO_rslt.vas_header_script := 'Handset Protection Program enrolled';
                    end if;
                    --This script will show when ESN is enrolled the first time and only for BYOP devices
                    If p_solution_name not in ('MAKE_RECURRENT_PG','ENROLLMENT_PAYNOW_PG','STOP_RECURRENT_PG','CANCEL_VAS_ENROLLMENT_PG') and
                       esnServiceVO_rslt.x_manufacturer = 'BYOP'
                    then
                        esnServiceVO_rslt.vas_footer_script := --'IMPORTANT! Please complete your Device Eligibility Check by going to  www.asuriondhc.com';
                        sa.adfcrm_scripts.get_generic_brand_script(ip_script_type =>  'HPP',
                                                                   ip_script_id => '281',
                                                                   ip_language => v_language,
                                                                   ip_sourcesystem  => 'TAS',
                                                                   ip_brand_name => esnServiceVO_rslt.org_id);
                    end if;
                end if;
            end loop;
        end if;
        if p_solution_name like 'UPGRADE%'
        then
            begin
                select
                    --substr(parameter,16) script_type_id,
                    substr(substr(parameter,16),1,instr(substr(parameter,16),'_')-1) script_type,
                    substr(substr(parameter,16),instr(substr(parameter,16),'_')+1) script_id
                into upg_vas_script_type, upg_vas_script_id
                from (
                      select regexp_substr(input_value,'[^,]+',1,level) parameter
                      from (select p_check_condition input_value from dual)
                      connect by level<=regexp_count(input_value,'[^,]+')
                      group by level, input_value
                     )
                where parameter like 'UPG_VAS_SCRIPT%';
            exception
                when others then null;
            end;


            if length(upg_vas_script_type) > 0 and length(upg_vas_script_id) > 0 then
                esnServiceVO_rslt.vas_header_script :=
                        sa.adfcrm_scripts.get_generic_brand_script(ip_script_type =>  upg_vas_script_type,
                                                                   ip_script_id => upg_vas_script_id,
                                                                   ip_language => v_language,
                                                                   ip_sourcesystem  => 'TAS',
                                                                   ip_brand_name => esnServiceVO_rslt.org_id);
            end if;
        end if;
    end if;
    --***************************CR49058 DISPLAY VAS ENROLLMENT INFORMATION END   ******************************************

    --/****************************************** OFFER_VAS_SERVICE_ILD  BEGIN ******************************************/
    esnServiceVO_rslt.OFFER_VAS := 'NO';
    esnServiceVO_rslt.offer_vas_script_text := '';
    if get_esn_info_rec.org_id = 'PAGEPLUS' then --CR35378
        if p_solution_name = 'REDEMPTION_PG' and sa.ADFCRM_TRANSACTION_SUMMARY.getVASservice(p_esn) is not null
        then
            esnServiceVO_rslt.OFFER_VAS := 'YES';
        end if;
        if esnServiceVO_rslt.offer_vas = 'YES'
        then
            esnServiceVO_rslt.offer_vas_script_text := sa.adfcrm_scripts.solution_script_func('OFFER_VAS_SERVICE_ILD',p_esn,p_language,p_purchase_id);
        end if;
    end if;  --CR35378
    --/****************************************** OFFER_VAS_SERVICE_ILD  END ******************************************/

    --*************************** EASY_EXCHANGE_ELIGIBLE OR VAS (NO ILD) ELIGIBLE BEGIN ******************************************

        if esnServiceVO_rslt.org_id != 'TRACFONE' and p_solution_name in ('REDEMPTION_PG','ACTIVATION_PG','AWOP_PG')
        then
            esnServiceVO_rslt.easy_exchange_script_name :=
                    sa.ADFCRM_TRANSACTION_SUMMARY.getEasyExchangeScriptName(p_esn,p_purchase_id);

            if  esnServiceVO_rslt.easy_exchange_script_name = 'EASY_EXCHANGE_ELIGIBLE'
            then
                esnServiceVO_rslt.offer_E_Exch := 'YES';
            else
                esnServiceVO_rslt.offer_E_Exch := 'NO';
            end if;
        end if;
        if esnServiceVO_rslt.org_id = 'TRACFONE' and p_solution_name in ('REDEMPTION_PG','ACTIVATION_PG','AWOP_PG','REACTIVATION_PG')
        then
            select count(*)
            into cnt_eligible_vas
            from table(sa.ADFCRM_VAS.get_eligible_vas_services(
                        I_ESN => esnServiceVO_rslt.serial_number,
                        I_MIN => esnServiceVO_rslt.x_min,
                        I_BUS_ORG => esnServiceVO_rslt.org_id,
                        I_ECOMMERCE_ORDERID => NULL,
                        I_PHONE_MAKE => NULL,
                        I_PHONE_MODEL => NULL,
                        I_PHONE_PRICE => NULL,
                        i_activation_zipcode => get_site_part_rec.x_zipcode,
                        i_is_byod => decode(esnServiceVO_rslt.x_manufacturer,'BYOP','Y','N'),
                        I_ENROLLED_ONLY => 'N',
                        I_TO_ESN => NULL,
                        I_PROCESS_FLOW => NULL
                    )) vas
            where vas.status = 'ELIGIBLE';
            if  cnt_eligible_vas > 0
            then
                esnServiceVO_rslt.offer_E_Exch := 'YES';
                esnServiceVO_rslt.easy_exchange_script_name := 'EASY_EXCHANGE_ELIGIBLE';  --CR49058
            else
                esnServiceVO_rslt.offer_E_Exch := 'NO';
            end if;
        end if;

    --*************************** EASY_EXCHANGE_ELIGIBLE OR VAS_MOBILE PROTECTION END ******************************************

    esnServiceVO_rslt.easy_exchange_script_text := '';
    if nvl(esnServiceVO_rslt.easy_exchange_script_name,'####') != '####'
    then
        esnServiceVO_rslt.easy_exchange_script_text :=
        sa.ADFCRM_SCRIPTS.SOLUTION_SCRIPT_FUNC(esnServiceVO_rslt.easy_exchange_script_name,p_esn,p_language,p_purchase_id);
    end if;

      sa.PHONE_PKG.GET_PROGRAM_INFO(
        P_ESN => P_ESN,
        P_SERVICE_PLAN_OBJID => P_SERVICE_PLAN_OBJID,
        P_SERVICE_TYPE => P_SERVICE_TYPE,
        P_PROGRAM_TYPE => P_PROGRAM_TYPE,
        P_NEXT_CHARGE_DATE => P_NEXT_CHARGE_DATE,
        P_PROGRAM_UNITS => P_PROGRAM_UNITS,
        P_PROGRAM_DAYS => P_PROGRAM_DAYS,
        P_RATE_PLAN => P_RATE_PLAN,
        P_ERROR_NUM => P_ERROR_NUM
      );

    esnServiceVO_rslt.autorefill := 'NO';
    IF P_PROGRAM_TYPE IS NOT NULL
    THEN
        esnServiceVO_rslt.autorefill := 'YES';
    END IF;
    --esnServiceVO_rslt.rate_plan := sa.service_plan.f_get_esn_rate_plan_all_status(p_esn);
    esnServiceVO_rslt.rate_plan := P_RATE_PLAN;

    esnServiceVO_rslt.service_plan := 'Paygo';
    esnServiceVO_rslt.service_plan_script := 'Paygo';
    if P_SERVICE_PLAN_OBJID is not null
    then
        esnServiceVO_rslt.service_plan_objid := P_SERVICE_PLAN_OBJID;
        esnServiceVO_rslt.service_plan_script :=
            NVL(sa.ADFCRM_TRANSACTION_SUMMARY.GET_SERVICE_PLAN_SCRIPT(esnServiceVO_rslt.service_plan_objid,p_language,v_script_bus_org/*get_esn_info_rec.org_id*/)
                ,P_SERVICE_TYPE);

        esnServiceVO_rslt.service_plan :=
            sa.ADFCRM_SCRIPTS.GET_PLAN_DESCRIPTION(esnServiceVO_rslt.service_plan_objid,v_language,'ALL');

        esnServiceVO_rslt.broadband := sa.ADFCRM_GET_SERV_PLAN_VALUE(esnServiceVO_rslt.service_plan_objid ,'BROADBAND');
    end if;

    esnServiceVO_rslt.serv_plan_added_script := '';
    if p_solution_name in ('REDEMPTION_PG','PURCHASE_PG','ENROLLMENT_PG','REDEMPTION_PG_PURCHASE','PORTS_PG','UPGRADE_AUTO_PORT','UPGRADE_ESN_EXCHANGE') -- PORTS_PG being added to show SP being ADDED
    then
       --CR47593 Multiple Redemptions
       for rec in (select --p.esn, p.call_id ,p.merchant_number,
                          sa.ADFCRM_TRANSACTION_SUMMARY.get_service_plan_added(p.esn, p.call_id ,p.merchant_number) sp_objid,
                          count(*) quantity
                    from
                        (             select distinct esn, merchant_number, call_id
                                       from   (WITH t AS (select  p_esn esns,
                                                          p_purchase_id purchaseids,
                                                          p_transaction_id callids
                                                  from dual)
                                       select nvl(replace(regexp_substr(esns,'[^,]+',1,lvl),'null',''), p_esn ) esn,
                                              replace(regexp_substr(purchaseids,'[^,]+',1,lvl),'null','') merchant_number,
                                              replace(regexp_substr(callids,'[^,]+',1,lvl),'null','') call_id
                                       from  (select esns,purchaseids,callids, level lvl
                                              from   t
                                              connect by level <= length(purchaseids) - length(replace(purchaseids,',')) + 1)
                                              )
                        ) p
                    group by sa.ADFCRM_TRANSACTION_SUMMARY.get_service_plan_added(p.esn, p.call_id ,p.merchant_number)
                    order by 1 desc
                   )
        loop
            esnServiceVO_rslt.plan_added_objid := rec.sp_objid;
            --esnServiceVO_rslt.plan_added_objid := SA.ADFCRM_TRANSACTION_SUMMARY.get_service_plan_added(p_esn,p_transaction_id,p_purchase_id);

            if nvl(esnServiceVO_rslt.plan_added_objid,0) != nvl(esnServiceVO_rslt.service_plan_objid,0)
            then
                if nvl(esnServiceVO_rslt.plan_added_objid,0) in (-1,252)
                then
                    if p_solution_name like '%_PURCHASE' then
                      esnServiceVO_rslt.serv_plan_added_script := esnServiceVO_rslt.serv_plan_added_script||'<br><br>Please check Total Charge Summary for more details';
                    end if;
                else
                    esnServiceVO_rslt.serv_plan_added_script :=
                        esnServiceVO_rslt.serv_plan_added_script
                        ||case when esnServiceVO_rslt.serv_plan_added_script is null then '' else '<br>' end ||
                        NVL(sa.ADFCRM_TRANSACTION_SUMMARY.GET_SERVICE_PLAN_SCRIPT(esnServiceVO_rslt.plan_added_objid,p_language,v_script_bus_org/*get_esn_info_rec.org_id*/)
                          ,nvl(sa.adfcrm_scripts.get_plan_description(esnServiceVO_rslt.plan_added_objid,v_language,'ALL')
                              ,sa.ADFCRM_TRANSACTION_SUMMARY.get_others_added(p_solution_name, p_esn, p_language, p_purchase_id,p_transaction_id)
                              ));
                end if;
            else
                esnServiceVO_rslt.serv_plan_added_script := esnServiceVO_rslt.serv_plan_added_script
                                                            ||case when esnServiceVO_rslt.serv_plan_added_script is null then '' else '<br>' end
                                                            ||esnServiceVO_rslt.service_plan_script;
                if nvl(esnServiceVO_rslt.plan_added_objid,0) in (-1,252) and p_solution_name like '%_PURCHASE'
                then
                    esnServiceVO_rslt.serv_plan_added_script := esnServiceVO_rslt.serv_plan_added_script||'<br><br>Please check Total Charge Summary for more details';
                end if;
            end if;
        end loop;
    end if;

    esnServiceVO_rslt.trans_script := sa.ADFCRM_SCRIPTS.SOLUTION_SCRIPT_FUNC
                      (p_solution_name,
                      p_esn,
                      p_language,
                      p_purchase_id,
                      p_transaction_id,
                      p_case_id,
                      'TAS',
                      p_check_condition);

    v_days_card_reserved := 0;
    select sum(pnc.x_redeem_days)
    into   v_days_card_reserved
    from table_part_num pnc,table_mod_level mlc,table_part_inst pic
    where pic.part_to_esn2part_inst = get_esn_info_rec.objid
    and pic.n_part_inst2part_mod = mlc.objid
    and mlc.part_info2part_num = pnc.objid
    and pic.x_part_inst_status = '400'
    and pnc.domain ='REDEMPTION CARDS';

    esnServiceVO_rslt.service_end_date := get_esn_info_rec.Warr_End_Date + nvl(v_days_card_reserved,0);

    if get_esn_info_rec.x_part_inst2contact is not null
    then
        open get_contact(get_esn_info_rec.x_part_inst2contact);
        fetch get_contact into get_contact_rec;
        close get_contact;
    end if;

    esnServiceVO_rslt.first_name := get_contact_rec.first_name;
    esnServiceVO_rslt.last_name := get_contact_rec.last_name;
    esnServiceVO_rslt.e_mail := get_contact_rec.e_mail;
    esnServiceVO_rslt.contact_objid  := get_contact_rec.contact_objid;

   pipe row (esnServiceVO_rslt);

   RETURN;
END getServiceVO;

  function trans_script_group   (ip_solution_name in sa.adfcrm_solution.solution_name%type,
                                 ip_esn  in varchar2,
                                 ip_language  in varchar2,
                                 ip_purchase in  varchar2,
                                 ip_call_id in varchar2,
                                 ip_case_id  in varchar2,
                                 ip_action_type in varchar2,
                                 ip_check_condition varchar2 default 'BOGO=NO') return clob
  is
     cursor input_values is
            select distinct *
            from   (WITH t AS (select ip_esn esns,
                                      ip_purchase purchaseids,
                                      ip_call_id callids,
                                      ip_action_type actiontypes,
                                      ip_case_id caseids
                              from dual)
                   select nvl(replace(regexp_substr(esns,'[^,]+',1,lvl),'null',''),ip_esn) esn,
                          replace(regexp_substr(purchaseids,'[^,]+',1,lvl),'null','') purchase,
                          replace(regexp_substr(callids,'[^,]+',1,lvl),'null','') call_id,
                          replace(regexp_substr(actiontypes,'[^,]+',1,lvl),'null','') action_type,
                          replace(regexp_substr(caseids,'[^,]+',1,lvl),'null','') case_id
                   from  (select esns,purchaseids,callids,actiontypes,caseids, level lvl
                          from   t
                          connect by level <= length(esns) - length(replace(esns,',')) + 1)
                  )
             ;
     final_script            clob;
     script_text             clob;
     solution                varchar2(100);
     ip_sourcesystem         varchar2(50) := 'TAS';
  begin
     final_script := '';
     for rec in input_values loop
         solution := case
                     when rec.action_type = 'ACTIVATION' then 'ACTIVATION_PG'
                     when rec.action_type = 'REDEMPTION' then
                            case
                            when ip_solution_name like '%_EMAIL_BODY' then 'GRP_REDEMPTION_PG_EMAIL_BODY'
                            else 'REDEMPTION_PG'
                            end
                     when rec.action_type = 'PORT' then 'PORTS_PG'
                     else ''
                     end;
         if solution is not null then
            if ip_solution_name like '%_EMAIL_BODY' then
                ip_sourcesystem := 'WEB';
            end if;

            script_text := '<strong>Device '||rec.esn||' instructions</strong><p></p>'||
            nvl(
            sa.adfcrm_scripts.solution_script_func( ip_solution_name => solution,
                                                    ip_esn => rec.esn,
                                                    ip_language => ip_language,
                                                    ip_param_list => rec.purchase,
                                                    ip_transaction_id => rec.call_id,
                                                    ip_case_id => rec.case_id,
                                                    ip_source_system => ip_sourcesystem,
                                                    ip_check_condition => ip_check_condition
                                                   )
            ,'ERROR: Script Text not found for solution '||solution||'. Please contact system support');
            final_script := final_script||script_text||'<p></p>';
         end if;
     end loop;
     return final_script;
  end trans_script_group;

    ------------------------------------------------------------------------------
  -- get_case_info (UC300) - New - To fix issue where the word "Unlimited" was being
  -- inserted into the sms_units column of the case info query in TAS. This
  -- will default to "0" if it encounters this issue. Externalized the query
  -- from TAS, to simplify fixing these to_number issues. TAS_2015_14 Release
  ------------------------------------------------------------------------------
  function get_case_info (ip_case_id in varchar2)
  return get_case_info_tab pipelined
  is
    get_case_info_rslt get_case_info_rec;
  begin
    get_case_info_rslt.objid           := null;
    get_case_info_rslt.title_label     := null;
    get_case_info_rslt.id_number       := null;
    get_case_info_rslt.service_plan_id := null;
    get_case_info_rslt.service_plan    := null;
    get_case_info_rslt.minutes         := null;
    get_case_info_rslt.data_units      := null;
    get_case_info_rslt.sms_units       := null;
    get_case_info_rslt.days            := null;
    get_case_info_rslt.s_title := null;
    get_case_info_rslt.case_address := null;
    get_case_info_rslt.esn := null;
	get_case_info_rslt.current_esn := null;

    for i in (select objid, title||' Ticket Number' title_label, id_number ,
                         alt_address||', '||alt_city ||', '||alt_state||' '||alt_zipcode case_address,
                         s_title, c.x_esn,
						 (select max(Nvl(Cd.X_Value,''))
                             from sa.table_x_case_detail cd
                             where cd.detail2case = c.objid
                             and cd.x_name ='CURRENT_ESN') current_esn,
                         (select max(Nvl(Cd.X_Value,''))
                             from sa.table_x_case_detail cd
                             where cd.detail2case = c.objid
                             and cd.x_name in ('COMP_SERVICE_PLAN_ID','REPL_SERVICE_PLAN_ID')
                         and Nvl(Cd.X_Value,'0') != '0' )  Service_Plan_id ,
                             (select Nvl(Cd.X_Value,'')
                             from sa.table_x_case_detail cd
                             where cd.detail2case = c.objid
                             and cd.x_name in ('SERVICE_PLAN','COMP_SERVICE_PLAN','REPL_SERVICE_PLAN')
                         and Nvl(Cd.X_Value,'0') != '0' )  Service_Plan ,
                             (select sum(nvl(to_number(regexp_replace(cd.x_value,'[^0-9]','')),0))
                             from sa.table_x_case_detail cd
                             where cd.detail2case = c.objid
                             and Cd.X_Name in ('AIRTIME_UNITS','VOICE_UNITS','COMP_UNITS','REPLACE_UNITS','REPLACEMENT_UNITS','REPL_UNITS'))  Minutes ,
                             (select sum(nvl(to_number(regexp_replace(cd.x_value,'[^0-9]','')),0))
                             from sa.table_x_case_detail cd
                             where cd.detail2case = c.objid
                             and Cd.X_Name in ('AIRTIME_DATA','DATA_UNITS','REPL_DATA','COMP_DATA'))  Data_units ,
                             (select nvl(sum(nvl(to_number(regexp_replace(cd.x_value,'[^0-9]','')),0)),0)
                             --decode(cd.x_value,'Unlimited',null,cd.x_value)),0)),0)
                             from sa.table_x_case_detail cd
                             where cd.detail2case = c.objid
                             and Cd.X_Name in ('AIRTIME_SMS','SMS_UNITS','REPL_SMS','COMP_SMS'))  sms_units ,
                             (SELECT sum(nvl(to_number(regexp_replace(cd.x_value,'[^0-9]','')),0))
                             from sa.table_x_case_detail cd
                             WHERE cd.detail2case = c.objid
                             and Cd.X_Name in ('AIRTIME_DAYS','SERVICE_DAYS','COMP_SERVICE_DAYS','REPL_SERVICE_DAYS','REPLACEMENT_DAYS','REPL_DAYS','REPLACE_DAYS','COMP_DAYS'))  days
              from table_case c
              where id_number in
                     (
                      select regexp_substr(input_value,'[^,]+',1,level) parameter
                      from (select ip_case_id input_value from dual)
                      connect by level<=regexp_count(input_value,'[^,]+')
                      group by level, input_value
                     )
              )
    loop
      get_case_info_rslt.objid           := i.objid;
      get_case_info_rslt.title_label     := i.title_label;
      get_case_info_rslt.id_number       := i.id_number;
      get_case_info_rslt.service_plan_id := i.service_plan_id;
      get_case_info_rslt.service_plan    := i.service_plan;
      get_case_info_rslt.minutes         := i.minutes;
      get_case_info_rslt.data_units      := i.data_units;
      get_case_info_rslt.sms_units       := i.sms_units;
      get_case_info_rslt.days            := i.days;
      get_case_info_rslt.s_title := i.s_title;
      get_case_info_rslt.case_address := i.case_address;
      get_case_info_rslt.esn := i.x_esn;
      get_case_info_rslt.current_esn := i.current_esn;
      pipe row (get_case_info_rslt);
    end loop;
  end get_case_info;
END;
/