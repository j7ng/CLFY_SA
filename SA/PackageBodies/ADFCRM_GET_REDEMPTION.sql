CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_GET_REDEMPTION"
as
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_GET_REDEMPTION_PKB.sql,v $
--$Revision: 1.16 $
--$Author: hcampano $
--$Date: 2017/09/07 15:09:48 $
--$ $Log: ADFCRM_GET_REDEMPTION_PKB.sql,v $
--$ Revision 1.16  2017/09/07 15:09:48  hcampano
--$ CR52985	 - Multi Denomination Cards - Customer Care Rel
--$
--$ Revision 1.15  2017/08/30 22:17:40  hcampano
--$ CR52985	 - Multi Denomination Cards - Customer Care Rel
--$
--$ Revision 1.14  2017/08/30 18:41:35  hcampano
--$ CR52985	 - Multi Denomination Cards - Customer Care Rel
--$
--$ Revision 1.13  2016/12/30 16:14:31  mmunoz
--$ CR47303: Safelink monthly benefit transactions count as paid redemptions.
--$
--$ Revision 1.12  2015/08/24 21:46:07  mmunoz
--$ CR36725 added red card status
--$
--$ Revision 1.11  2015/07/15 13:49:47  hcampano
--$ TAS_2015_14 - fixed issue w/sms_units query
--$
--$ Revision 1.10  2015/05/04 16:33:07  mmunoz
--$ Included redemption days related with BILLING PROGRAM
--$
--$ Revision 1.9  2015/05/04 16:06:40  mmunoz
--$ If red_type is  'PROMOTION' set red_days as promorec.x_access_days
--$
--$ Revision 1.8  2014/09/29 19:44:01  mmunoz
--$ added successes for purchases and refunds, X_ICS_RCODE in (a??1a??,a??100a??) and X_ICS_RFLAG in (a??SOKa??, a??ACCEPTa??).
--$
--$ Revision 1.7  2014/09/15 20:36:05  mmunoz
--$ TAS_2014_09 To Improve performance.
--$
--$ Revision 1.6  2014/08/12 15:48:40  mmunoz
--$ fixing bug with cases
--$
--$ Revision 1.5  2014/08/05 21:35:42  mmunoz
--$ changes in get_redeem_calc_date
--$
--$ Revision 1.4  2014/07/18 20:23:29  mmunoz
--$ added red_amount in type esnRedemption_rec
--$
--$ Revision 1.3  2014/06/23 19:15:59  mmunoz
--$ get_summary, condition for TRACFONE commented
--$
--$ Revision 1.2  2014/05/29 16:18:24  mmunoz
--$ Added language in get_summary
--$
--$ Revision 1.1  2014/04/30 21:37:29  mmunoz
--$ CR17975
--$
--------------------------------------------------------------------------------------------
function get_redeem_calc_date (ip_esn varchar2
                              ,ip_date date)
return date is
   default_date CONSTANT date := to_date('01/01/1900','dd/mm/yyyy');
   v_initial_act_date      date;
   v_clear_time_tank_date  date;
   v_date                  date;
   v_is_refurb             number;
begin
   SELECT COUNT(1) is_refurb
   into v_is_refurb
   from table_site_part sp_a
   WHERE sp_a.x_service_id = ip_esn
   AND sp_a.x_refurb_flag = 1;

   if v_is_refurb = 0 then
	  --nonrefurb_act_date
      select min(install_date) initial_act_date
      into   v_initial_act_date
      from   sa.table_site_part
      where  x_service_id = ip_esn
      and    part_status || '' IN ('Active','Inactive');
   else
	   --refurb_act_date
       select min(install_date) initial_act_date
       into   v_initial_act_date
       from table_site_part sp_b
       WHERE sp_b.x_service_id = ip_esn
       AND sp_b.part_status || '' IN ('Active','Inactive')
       AND NVL(sp_b.x_refurb_flag,0) <> 1;
    end if;

    select max(x_req_date_time) clear_time_tank_date
    into  v_clear_time_tank_date
    from  sa.table_x_zero_out_max
    where x_esn = ip_esn
    and  x_transaction_type = '2';

    v_date := greatest(nvl(v_initial_act_date,default_date),nvl(v_clear_time_tank_date,default_date));
    if ip_date is not null then
       v_date := greatest(v_date,ip_date);
    end if;
    --as per igate package Subtracting 1/48 to consider cases created just before the transaction
    v_date:= v_date-(1/48);

    return v_date;
end get_redeem_calc_date;

--********************************************************************************************************************
function default_values
return esnRedemption_rec
is
   esnredemption_rslt esnRedemption_rec;
begin
   esnredemption_rslt.red_esn     := '';
   esnredemption_rslt.red_parent  := '';
   esnredemption_rslt.red_group     := '';
   esnredemption_rslt.red_trans_id  := '';
   esnredemption_rslt.red_trans_date  := null;
   esnredemption_rslt.red_trans_units := '';
   esnredemption_rslt.red_type := '';
   esnredemption_rslt.red_card := '';
   esnredemption_rslt.red_card_status := '';
   esnredemption_rslt.red_part_class  := '';
   esnredemption_rslt.red_part_number  := '';
   esnredemption_rslt.red_units  := '';
   esnredemption_rslt.red_sms  := '';
   esnredemption_rslt.red_data  := '';
   esnredemption_rslt.red_days    := '';
   esnredemption_rslt.red_service_plan  := '';
   esnredemption_rslt.red_promo_desc   := '';
   esnredemption_rslt.red_promo_units  := '';
   esnredemption_rslt.red_promo_type    := '';
   esnredemption_rslt.red_prog_name    := '';
   esnredemption_rslt.red_prog_class    := '';
   esnredemption_rslt.red_sweep_and_add_flag    := '';
   esnredemption_rslt.red_prog_units    := '';
   esnRedemption_rslt.red_vas  := '';
   esnRedemption_rslt.red_amount := 0;

   return esnredemption_rslt;
end default_values;

--********************************************************************************************************************
procedure set_service_plan(ip_language in varchar2
                          ,ip_sourcesystem in varchar2
                          ,site_part_id in number
                          ,serv_plan_id in number
                          ,sp_group in out varchar2
                          ,service_plan_desc in out varchar2)
IS
begin
   if serv_plan_id is not null
   then
       select sa.adfcrm_scripts.get_plan_description(serv_plan_id, ip_language, ip_sourcesystem) WEBCSR_DISPLAY_NAME,
              decode(sa.get_serv_plan_value(serv_plan_id,'SERVICE_PLAN_GROUP')
                    ,'PAY_GO','PAYGO'
                    ,'SERVICE PLAN') plan_group
       into   service_plan_desc, sp_group
       from   dual;
   else
       for sprec in (
                     select sa.adfcrm_scripts.get_plan_description (xsp.objid, ip_language, ip_sourcesystem) WEBCSR_DISPLAY_NAME,
                            decode(sa.get_serv_plan_value(xsp.objid,'SERVICE_PLAN_GROUP')
                                  ,'PAY_GO','PAYGO'
                                  ,'SERVICE PLAN') plan_group
                     from sa.x_service_plan_site_part spsp,
                          sa.x_service_plan xsp
                     where spsp.table_site_part_id = site_part_id
                     and   xsp.objid = spsp.x_service_plan_id
                     order by X_LAST_MODIFIED_DATE)
       loop
          sp_group := sprec.plan_group;
          service_plan_desc := sprec.WEBCSR_DISPLAY_NAME;
       end loop;
   end if;
end;
--********************************************************************************************************************
function get_amount_paid(rec red_card_record)
return number is
   amount number;
begin
  amount := 0;
  begin
         select nvl(phdr.x_amount,0)
         into   amount
         from   sa.TABLE_X_PURCH_DTL PDTL,
                sa.TABLE_X_PURCH_HDR PHDR
         WHERE PDTL.X_RED_CARD_NUMBER = rec.x_red_code
         and   PHDR.OBJID = PDTL.X_PURCH_DTL2X_PURCH_HDR
         and   phdr.x_esn = rec.esn
         and   phdr.x_ics_rcode in ('1','100')
         and   phdr.x_ics_rflag in ('SOK', 'ACCEPT')
         ;
  exception
         when others then null;
  end;
  if nvl(amount,0) = 0
  then
     begin
	    select max(nvl(pricing.x_retail_price,0)) amount
	    into   amount
	    from sa.table_part_num pn,
	         sa.table_x_pricing pricing
	    where pn.part_number = rec.part_number
	    and pricing.x_pricing2part_num = pn.objid
	    and pricing.x_end_date >= rec.transact_date
	    and pricing.x_start_date <= rec.transact_date;
     exception
	    when others then null;
     end;
  end if;
  return nvl(amount,0);
end get_amount_paid;
--********************************************************************************************************************
      procedure classify_card(ip_language varchar2
                             ,ip_sourcesystem varchar2
                             ,rec red_card_record
                             ,esnredemption_rslt in out esnRedemption_rec)
      is
        v_case_title varchar2(400);
      begin

        esnredemption_rslt.red_type := 'REDEMPTION CARD';
        esnredemption_rslt.red_card := rec.x_red_code;
        esnredemption_rslt.red_card_status := rec.x_red_code_status;
        esnredemption_rslt.red_part_class := rec.part_class;
        esnredemption_rslt.red_part_number := rec.part_number;
        esnredemption_rslt.red_units := rec.x_redeem_units;
        esnredemption_rslt.red_days := rec.x_redeem_days;
        esnredemption_rslt.red_group   := 'PAYGO';
        esnredemption_rslt.red_parent  := 'PAID REDEMPTIONS';
        --Check that redemption is not part of a case
        for cases in (select c.objid,
                             c.title,
                             (select x_value
                              from table_x_case_detail
                              where detail2case = c.objid
                              and x_name = 'CALL_TRANS'
                              and rownum < 2)  case_call_trans,
                             case c.title
                             when 'Compensation Units' then 'COMPENSATION'
                             when 'Replacement Units' then 'REPLACEMENT'
                             when 'Compensation Service Plan' then 'COMPENSATION'
                             when 'Replacement Service Plan' then 'REPLACEMENT'
                             end red_parent
                    from  sa.table_case c
                    where c.x_esn = rec.esn
                    and   c.title ||'' in ('Compensation Units', 'Replacement Units','Compensation Service Plan', 'Replacement Service Plan')
                    and   c.creation_time between (rec.transact_date - 1/48) and rec.transact_date  --as per igate package
                    )
        loop
            if cases.case_call_trans is null or cases.case_call_trans = nvl(rec.call_trans_id,-1)
            then
               v_case_title := cases.title;
               esnredemption_rslt.red_parent  := cases.red_parent;
            end if;
        end loop;

           -- get service plan redeemed if it exists
          dbms_output.put_line('Call Trans Id: '||esnredemption_rslt.red_trans_id
                            ||' Part Class Objid : '||rec.pc_objid||'  rec.part_number:'||rec.part_number );
          for sprec in (
              select  spc.sp_objid objid,
			          sa.adfcrm_scripts.get_plan_description (spc.sp_objid, ip_language, ip_sourcesystem) webcsr_display_name,
					  decode(spf.fea_value
                            ,'PAY_GO','PAYGO'
                            ,'SERVICE PLAN') plan_group
			  from    sa.adfcrm_serv_plan_class_matview spc,
			          sa.adfcrm_serv_plan_feat_matview spf
			  where   spc.part_class_objid = rec.pc_objid
			  and     spf.sp_objid = spc.sp_objid
			  and     spf.fea_name = 'SERVICE_PLAN_GROUP'
              )
          loop
              esnredemption_rslt.red_group   := sprec.plan_group;
              esnRedemption_rslt.red_service_plan := sprec.WEBCSR_DISPLAY_NAME;
              ---------------------------------------------------------------
              -- Check any conversion
              if sa.device_util_pkg.get_smartphone_fun(rec.esn) = 0 and
                 NVL (rec.x_card_type, 'A') = 'A'
              then
                for ext in (select nvl(c.trans_voice,1) trans_voice, c.trans_text, c.trans_data, c.trans_days
                            from   sa.x_surepay_conv c
                                  ,sa.sp_mtm_surepay mtm
                            where mtm.service_plan_objid = sprec.objid
                            and   c.objid = mtm.surepay_conv_objid)
                loop
                    dbms_output.put_line('It is surepay sprec.objid: '||sprec.objid||'  red_units:'||esnredemption_rslt.red_units );
                    esnredemption_rslt.red_units := esnredemption_rslt.red_units * ext.trans_voice;
                    esnredemption_rslt.red_sms   := nvl(esnredemption_rslt.red_sms,0) * ext.trans_text;
                    esnredemption_rslt.red_data  := nvl(esnredemption_rslt.red_data,0)  * ext.trans_data;
                    esnredemption_rslt.red_days  := nvl(esnredemption_rslt.red_days,0)  * ext.trans_days;
                end loop;
              end if;
          end loop;

          -- get vas product
          for vasrec in (
                      select vv.vas_programs_objid, vp.vas_param_name, vv.vas_param_value
                      from x_vas_params vp, x_vas_values vv
                      where vp.vas_param_name = 'VAS_APP_CARD'
                      and   vv.vas_params_objid = vp.objid
                      and   vv.vas_param_value = rec.part_number)
          loop
            esnredemption_rslt.red_group     := 'VAS PRODUCT';
            esnredemption_rslt.red_vas := vasrec.vas_param_value;
            esnredemption_rslt.red_units := 1;
          end loop;

          --Reclasifying when ticket was created with wrong title
          if esnredemption_rslt.red_parent = 'COMPENSATION' and
             V_CASE_TITLE = 'Compensation Units' and
             ESNREDEMPTION_RSLT.RED_GROUP = 'SERVICE PLAN'
          then
             esnredemption_rslt.red_parent := 'REPLACEMENT';
          end if;

          if esnredemption_rslt.red_parent = 'PAID REDEMPTIONS' then
             esnredemption_rslt.red_amount  := get_amount_paid(rec);
          end if;
      end classify_card;

--*******************************************************************************************************************
procedure find_case (ip_language varchar2
                    ,ip_sourcesystem varchar2
                    ,ip_esn in varchar2
                    ,ip_transact_date in date
                    ,ip_ct_reason in varchar2
                    ,ip_site_part_id in number
                    ,esnredemption_rslt in out esnRedemption_rec
                    )
is
begin
    -- Identify case related with the action.
   for ctcase in (select c.objid case_objid,
                         c.title,
                         c.x_case_type,
                        (select x_value
                         from table_x_case_detail
                         where detail2case = c.objid
                         and x_name = 'CALL_TRANS'
                         and rownum < 2)  case_call_trans,
                         case c.title
                             when 'Compensation Units' then 'COMPENSATION'
                             when 'Replacement Units' then 'REPLACEMENT'
                             when 'Compensation Service Plan' then 'COMPENSATION'
                             when 'Replacement Service Plan' then 'REPLACEMENT'
                         end red_parent,
                                 (select max(Nvl(Cd.X_Value,''))
                                     from sa.table_x_case_detail cd
                                     where cd.detail2case = c.objid
                                     and cd.x_name in ('COMP_SERVICE_PLAN_ID','REPL_SERVICE_PLAN_ID')
                                 and Nvl(Cd.X_Value,'0') != '0' )  Service_Plan_id,
                                     (select Nvl(Cd.X_Value,'')
                                     from sa.table_x_case_detail cd
                                     where cd.detail2case = c.objid
                                     and Cd.X_Name in ('SERVICE_PLAN','COMP_SERVICE_PLAN','REPL_SERVICE_PLAN')
                                 and Nvl(Cd.X_Value,'0') != '0' )  Service_Plan,
                                     (select sum(nvl(to_number(cd.x_value),0))
                                     from sa.table_x_case_detail cd
                                     WHERE cd.detail2case = c.objid
                                     and Cd.X_Name in ('AIRTIME_UNITS','VOICE_UNITS','COMP_UNITS','REPLACE_UNITS','REPLACEMENT_UNITS','REPL_UNITS'))  Minutes,
                                     (select sum(nvl(to_number(cd.x_value),0))
                                     from sa.table_x_case_detail cd
                                     WHERE cd.detail2case = c.objid
                                     and Cd.X_Name in ('AIRTIME_DATA','DATA_UNITS','REPL_DATA','COMP_DATA'))  Data_units,
                                     (select nvl(sum(nvl(to_number(decode(cd.x_value,'Unlimited',null,cd.x_value)),0)),0)
                                     from sa.table_x_case_detail cd
                                     WHERE cd.detail2case = c.objid
                                     and Cd.X_Name in ('AIRTIME_SMS','SMS_UNITS','REPL_SMS','COMP_SMS'))  sms_units,
                                     (SELECT sum(nvl(to_number(cd.x_value),0))
                                     from sa.table_x_case_detail cd
                                     WHERE cd.detail2case = c.objid
                                     and Cd.X_Name in ('AIRTIME_DAYS','SERVICE_DAYS','COMP_SERVICE_DAYS','REPL_SERVICE_DAYS','REPLACEMENT_DAYS','REPL_DAYS','REPLACE_DAYS','COMP_DAYS'))  days
                  from  sa.table_case c
                  where c.x_esn = ip_esn
                  and   c.title ||'' in ('Compensation Units', 'Replacement Units','Compensation Service Plan', 'Replacement Service Plan')
                  and   c.creation_time between (ip_transact_date - 3/(24*60)) and (ip_transact_date + (1/(24*60))) --as per igate package
                  order by c.creation_time)
    loop
        esnredemption_rslt.red_parent  := ctcase.red_parent;


        IF (UPPER(ip_ct_reason) NOT LIKE '%COMPLAINT%' and UPPER(ip_ct_reason) NOT LIKE '%COMPENSATION%') AND
           ESNREDEMPTION_RSLT.RED_PARENT = 'COMPENSATION'
        THEN
           ESNREDEMPTION_RSLT.RED_PARENT  := 'REPLACEMENT';
        END IF;

        if nvl(ctcase.Minutes,0) = 0 and nvl(ctcase.Data_units,0) = 0 and nvl(ctcase.sms_units,0) = 0
        then
           set_service_plan(ip_language
                          ,ip_sourcesystem
                          ,ip_site_part_id
                          ,ctcase.Service_Plan_id
                          ,esnredemption_rslt.red_group
                          ,esnRedemption_rslt.red_service_plan);
--           esnredemption_rslt.red_group  := 'SERVICE PLAN';
        else
           esnredemption_rslt.red_group  := 'PAYGO';
        end if;

        /****
                    --Reclasifying when ticket was created with wrong title
                    if esnredemption_rslt.red_parent = 'COMPENSATION' and
                        esnredemption_rslt.red_promo_desc = 'Compensation Units' and
                        esnredemption_rslt.red_group = 'SERVICE PLAN'
                    then
                         esnredemption_rslt.red_parent := 'REPLACEMENT';
                    end if;
        ****/

        esnredemption_rslt.red_type := 'CASE';
        esnredemption_rslt.red_units := ctcase.Minutes;
        esnredemption_rslt.red_sms    := ctcase.sms_units;
        esnredemption_rslt.red_data   := ctcase.Data_units;
        esnredemption_rslt.red_days   := ctcase.days;
        esnredemption_rslt.red_promo_units := ctcase.minutes;
        esnredemption_rslt.red_promo_desc := ctcase.Title;
        esnredemption_rslt.red_promo_type := ctcase.x_case_type;

    end loop; -- CASES
end find_case;

--********************************************************************************************************************
function discard_record(esnredemption_rslt in esnRedemption_rec)
return number is
    discard_flag number;
begin
    discard_flag := 0;
    IF (esnredemption_rslt.red_parent IN ('COMPENSATION','REPLACEMENT') AND
        esnredemption_rslt.red_type = 'PROMOTION')
    THEN
      --Check if redemption was already summarize when looking for ct.x_action_type not in ('3','6','401','1')
        select COUNT(*)
        into   discard_flag
        from  sa.TABLE_X_CALL_TRANS CT, sa.TABLE_CASE C
        where ct.x_result = 'Completed'
        and  ct.x_action_type not in ('3','6','401','1')
        and  ct.x_service_id = esnredemption_rslt.red_esn
        and  ct.x_transact_date >= esnredemption_rslt.red_trans_date  - (5/(24*60))
        AND  ct.objid < esnredemption_rslt.red_trans_id
        AND  c.x_esn = ct.x_service_id
        and  C.TITLE ||'' in ('Compensation Units', 'Replacement Units','Compensation Service Plan', 'Replacement Service Plan')
        and  c.creation_time between (ct.x_transact_date - 3/(24*60)) and (ct.x_transact_date + (1/(24*60)));
    end if;
    return discard_flag;
end discard_record;

--********************************************************************************************************************
function get_summary(
  IP_ESN IN VARCHAR2,
  ip_date in date,
  p_language in varchar2
  )
  RETURN esnRedemption_tab pipelined
  is
      esnredemption_rslt esnredemption_rec;
      red_card_info    red_card_record;
      v_date             date;
      ip_language varchar2(100);
      ip_sourcesystem varchar2(100) := 'TAS';
  BEGIN

	ip_language := nvl(p_language,'ENGLISH');

  	if upper(ip_language) in ('ES','SPANISH')
	then
	   ip_language := 'SPANISH';
	else
	   ip_language := 'ENGLISH';
	end if;

--************************** BEGIN function getEsnRedemption *********************************************************
    v_date := get_redeem_calc_date(ip_esn, ip_date);

--********************************************************************************************************************
    -- grab records related with replacement/compensation
    for ctrec in (select  ct.objid, ct.x_service_id esn, ct.x_transact_date transact_date,
                        ct.x_total_units, ct.call_trans2site_part, ct.x_action_type, ct.x_reason
                  from  sa.table_x_call_trans ct
                  where ct.x_result = 'Completed'
                   and  ct.x_action_type not in ('3','6','401','1')
                   and  ct.x_service_id = ip_esn
                   and  ct.x_transact_date >= v_date
                  )
    loop
        --Compensation Service Plan x_action_type = '8' and x_action_text= 'CUST SERVICE'  x_promo_type = 'Customer Service'
        --Compensation Service Plan x_action_type = '111' and x_action_text= 'PORT CREDIT'  x_reason = 'Internal Port Credit'
        esnredemption_rslt := default_values();
        esnredemption_rslt.red_esn := ctrec.esn;
        esnredemption_rslt.red_trans_id  := ctrec.objid;
        esnredemption_rslt.red_trans_date  := ctrec.transact_date;
        esnredemption_rslt.red_trans_units := ctrec.x_total_units;
        find_case(ip_language
                 ,ip_sourcesystem
                 ,ctrec.esn
                 ,ctrec.transact_date
                 ,ctrec.x_reason
                 ,ctrec.call_trans2site_part
                 ,esnredemption_rslt
                 );
        pipe row (esnredemption_rslt);

    end loop;  --CALL TRANS

--********************************************************************************************************************
--     grab cards RESERVED
--********************************************************************************************************************
  for pi_card in (select
                       pi.part_serial_no,
                       rc.x_red_code,
                       pc.objid pc_objid,
                       pc.name part_class,
                       pn.part_number,
                       pn.x_redeem_units,
                       pn.x_redeem_days,
                       rc.x_creation_date,
                       pn.x_card_type,
                       rc.x_part_inst_status
                from   sa.table_part_inst pi,
                       sa.table_part_inst rc,
                       sa.table_mod_level ml,
                       sa.table_part_num pn,
                       sa.table_part_class pc
                where  pi.part_serial_no = ip_esn
                and    pi.x_domain = 'PHONES'
                and    rc.part_to_esn2part_inst = pi.objid
                and    rc.x_creation_date >= v_date
                and    rc.x_domain      = 'REDEMPTION CARDS'
                and    rc.x_part_inst_status  = '40' --RESERVED
                and    ml.objid = rc.n_part_inst2part_mod
                and    pn.objid = ml.part_info2part_num
                and    pc.objid = pn.part_num2part_class)
  loop
      esnredemption_rslt := default_values();
      esnredemption_rslt.red_esn := pi_card.part_serial_no;
      esnredemption_rslt.red_trans_units := pi_card.x_redeem_units;

      red_card_info.esn  := pi_card.part_serial_no;
      red_card_info.transact_date := pi_card.x_creation_date;
      red_card_info.x_red_code := pi_card.x_red_code;
      red_card_info.x_red_code_status := pi_card.x_part_inst_status;
      red_card_info.pc_objid := pi_card.pc_objid;
      red_card_info.part_class := pi_card.part_class;
      red_card_info.part_number := pi_card.part_number;
      red_card_info.x_redeem_units := pi_card.x_redeem_units;
      red_card_info.x_redeem_days := pi_card.x_redeem_days;
      red_card_info.x_card_type := pi_card.x_card_type;
      red_card_info.call_trans_id := null;

      classify_card(ip_language,ip_sourcesystem,red_card_info,esnRedemption_rslt);
      pipe row (esnRedemption_rslt);
  end loop;

--********************************************************************************************************************
    -- grab records related with activation, reactivation, redemption, cards in queued and activation
    for ctrec in (select  ct.objid, ct.x_service_id esn, ct.x_transact_date, ct.x_total_units,
                         ct.call_trans2site_part, ct.x_action_type, ct.x_reason, ct.x_sub_sourcesystem
                  from  sa.table_x_call_trans ct
                  where ct.x_result = 'Completed'
                   and  ct.x_action_type in ('3','6','401','1')
                   and  ct.x_service_id = ip_esn
                   and  ct.x_transact_date >= v_date
                  )
    loop
        esnredemption_rslt := default_values();
        esnredemption_rslt.red_esn := ctrec.esn;
        esnredemption_rslt.red_trans_id  := ctrec.objid;
        esnredemption_rslt.red_trans_date  := ctrec.x_transact_date;
        esnredemption_rslt.red_trans_units := ctrec.x_total_units;
        -- get redemption cards
        for rec in (select x_red_code, pc_objid, part_class, part_number, x_redeem_units, x_redeem_days, x_card_type, x_red_code_status, rownum
                  from  (
                          select rc.x_red_code,
                                 pc.objid pc_objid,
                                 pc.name part_class,
                                 pn.part_number,
                                 pn.x_redeem_units,
                                 pn.x_redeem_days,
                                 pn.x_card_type,
                                 '41' x_red_code_status
                          from   sa.table_x_red_card rc,
                                 sa.table_mod_level ml,
                                 sa.table_part_num pn,
                                 sa.table_part_class pc
                          where  rc.red_card2call_trans = ctrec.objid
                          AND    ml.objid = rc.x_red_card2part_mod
                          and    pn.objid = ml.part_info2part_num
                          and    pc.objid = pn.part_num2part_class
                          union
                          select rc.x_red_code,
                                 pc.objid pc_objid,
                                 pc.name part_class,
                                 pn.part_number,
                                 pn.x_redeem_units,
                                 pn.x_redeem_days,
                                 pn.x_card_type,
                                 rc.x_part_inst_status x_red_code_status
                          from   sa.table_part_inst rc,
                                 sa.table_mod_level ml,
                                 sa.table_part_num pn,
                                 sa.table_part_class pc
                          where  rc.x_red_code = ctrec.x_reason
                          and    rc.x_domain      = 'REDEMPTION CARDS'
                          AND    rc.x_part_inst_status  = '400'
                          AND    ml.objid = rc.n_part_inst2part_mod
                          and    pn.objid = ml.part_info2part_num
                          and    pc.objid = pn.part_num2part_class)
              )
        loop
            if rec.rownum > 1 then
               --more than one card for the same call trans
               pipe row (esnredemption_rslt);
               esnredemption_rslt := default_values();
               esnredemption_rslt.red_esn := ctrec.esn;
               esnredemption_rslt.red_trans_id  := ctrec.objid;
               esnredemption_rslt.red_trans_date  := ctrec.x_transact_date;
               esnredemption_rslt.red_trans_units := ctrec.x_total_units;
            end if;

            red_card_info.esn  := ctrec.esn;
            red_card_info.transact_date := ctrec.x_transact_date;
            red_card_info.x_red_code := rec.x_red_code;
            red_card_info.x_red_code_status := rec.x_red_code_status;
            red_card_info.pc_objid := rec.pc_objid;
            red_card_info.part_class := rec.part_class;
            red_card_info.part_number := rec.part_number;
            red_card_info.x_redeem_units := rec.x_redeem_units;
            red_card_info.x_redeem_days := rec.x_redeem_days;
            red_card_info.x_card_type := rec.x_card_type;
            red_card_info.call_trans_id := ctrec.objid;

            classify_card(ip_language,ip_sourcesystem,red_card_info,esnRedemption_rslt);
        end loop;

        -- get billing plans linked with table_x_call_trans without record in table_x_red_card
        if esnredemption_rslt.red_parent is null
        then
            for billrec in (
                    select pp.x_program_name,
                           pp.x_prog_class,
                           pp.x_sweep_and_add_flag,
                           pp.objid pp_objid,
                           pe.pgm_enroll2site_part,
                           (select sum(nvl(pn.x_redeem_units,0)) redeem_units
                           from    table_part_num pn
                           where   pn.objid in (pp.prog_param2prtnum_monfee, pp.prog_param2prtnum_enrlfee)) redeem_units,
                           (select sum(nvl(pn.x_redeem_days,0)) redeem_days
                           from    table_part_num pn
                           where   pn.objid in (pp.prog_param2prtnum_monfee, pp.prog_param2prtnum_enrlfee)) redeem_days,
                           pe.x_amount
                    from   sa.x_program_enrolled pe,
                           sa.x_program_parameters pp
                    WHERE  pe.x_esn = ctrec.esn
                    and    pe.pgm_enroll2pgm_parameter = pp.objid
                    --and    pe.pgm_enroll2site_part = ctrec.call_trans2site_part
                    and    ctrec.x_transact_date between pe.x_insert_date-(1/(24*60))
					and  nvl(pe.x_exp_date,nvl(pe.x_next_delivery_date,nvl(pe.x_next_charge_date,pe.x_charge_date))) + (1/(24*60))) --CR47303 Using x_next_delivery_date for Safelink
            loop
                esnredemption_rslt.red_parent := 'PAID REDEMPTIONS';
                set_service_plan(ip_language
                                ,ip_sourcesystem
                                ,billrec.pgm_enroll2site_part
                                ,null
                                ,esnredemption_rslt.red_group
                                ,esnRedemption_rslt.red_service_plan);

                if esnRedemption_rslt.red_service_plan is null
                then
                   esnRedemption_rslt.red_service_plan := billrec.x_program_name;
                   if billrec.x_sweep_and_add_flag = 1 --Safelink sweep and add plans
                   then
                        esnredemption_rslt.red_group  := 'SERVICE PLAN';
                   else
                        esnredemption_rslt.red_group  := 'PAYGO';
                   end if;
                end if;

                esnredemption_rslt.red_type := case
                                               when esnredemption_rslt.red_type is null then 'BILLING PROGRAM'
                                               else esnRedemption_rslt.red_type||',BILLING PROGRAM'
                                               end;
                esnredemption_rslt.red_prog_name := billrec.x_program_name;
                esnredemption_rslt.red_prog_class := case
                                                     when esnredemption_rslt.red_prog_class is null then billrec.x_prog_class
                                                     else esnredemption_rslt.red_prog_class||'||'||billrec.x_prog_class
                                                     end;
                esnRedemption_rslt.red_sweep_and_add_flag := billrec.x_sweep_and_add_flag;
                esnRedemption_rslt.red_prog_units := billrec.redeem_units;
                esnredemption_rslt.red_amount  := billrec.x_amount;
                esnredemption_rslt.red_days  := billrec.redeem_days;
            end loop;
        end if;

        -- get promotions linked with table_x_call_trans
        if esnredemption_rslt.red_parent is null
        then
        for promorec in (
                select p.x_promo_type, p.x_units, p.x_promo_desc, rownum, x_revenue_type,x_access_days
                from   sa.table_x_promo_hist ph,
                       sa.table_x_promotion p
                where  ph.promo_hist2x_call_trans = ctrec.objid
                and    p.objid = ph.promo_hist2x_promotion
                )
        loop
                if promorec.rownum > 1 or esnredemption_rslt.red_type = 'REDEMPTION CARD' then
                   --more than one promotion
                   if discard_record(esnredemption_rslt) = 0 then
                      pipe row (esnredemption_rslt);
                   end if;
                end if;

                if promorec.x_promo_type = 'BPRedemption'
                then
                    esnredemption_rslt.red_parent  := 'PAID REDEMPTIONS';
                    esnredemption_rslt.red_group  := 'PAYGO';

                elsif promorec.x_promo_type = 'Customer Service' and promorec.x_revenue_type = 'FREE' then
                    esnredemption_rslt.red_parent  := 'COMPENSATION';
                    if esnredemption_rslt.red_group is null
                    then
                        if nvl(promorec.x_units,0) = 0 and nvl(promorec.x_access_days,0) = 0
                        then
                            esnredemption_rslt.red_group  := 'SERVICE PLAN';
                        else
                            esnredemption_rslt.red_group  := 'PAYGO';
                        end if;
                    end if;

                elsif promorec.x_revenue_type = 'REPL' then
                    esnredemption_rslt.red_parent  := 'REPLACEMENT';
                    if esnredemption_rslt.red_group is null
                    then
                        if nvl(promorec.x_units,0) = 0 --and nvl(promorec.x_access_days,0) = 0
                        then
                            set_service_plan(ip_language
                                            ,ip_sourcesystem
                                            ,ctrec.call_trans2site_part
                                            ,null
                                            ,esnredemption_rslt.red_group
                                            ,esnRedemption_rslt.red_service_plan);
                        else
                            esnredemption_rslt.red_group  := 'PAYGO';
                        end if;
                    end if;
                else
                    esnredemption_rslt.red_parent  := 'BONUS MINUTES';
                    esnredemption_rslt.red_group   := 'BONUS MINUTES';
                end if;

                esnredemption_rslt.red_type := 'PROMOTION';
                esnredemption_rslt.red_promo_desc := promorec.x_promo_desc;
                esnredemption_rslt.red_promo_units := promorec.x_units;
                --esnredemption_rslt.red_days        := nvl(esnredemption_rslt.red_days,promorec.x_access_days);
                esnredemption_rslt.red_days        := nvl(promorec.x_access_days,0);
                esnredemption_rslt.red_promo_type := promorec.x_promo_type;
        end loop;
        end if;

        if esnredemption_rslt.red_parent is null and
           --ctrec.x_sub_sourcesystem = 'TRACFONE' and
           ctrec.x_reason = 'COMPENSATION'
         -- For these transactions, the action_type = 8 is not found in table_x_call_trans
        then
                dbms_output.put_line('Call Trans Id: '||esnredemption_rslt.red_trans_id||' Executing code when esnredemption_rslt.red_parent is null ');
                find_case(ip_language
                         ,ip_sourcesystem
                         ,ctrec.esn
                         ,ctrec.x_transact_date
                         ,ctrec.x_reason
                         ,ctrec.call_trans2site_part
                         ,esnredemption_rslt
                         );
        END IF;


        if discard_record(esnredemption_rslt) = 0 then
           pipe row (esnredemption_rslt);
        end if;
    end loop;     -- grab records related with redemption
    return;
end get_summary;

  function is_multi_denom(ip_snp varchar2)
  return varchar2
  is
    ret varchar2(30);
    v_esn_or_snp varchar2(30);
  begin
    for h in (
              select nvl(x_parent_part_serial_no,part_serial_no) x_parent_serial_no
                FROM table_part_inst pi
                where pi.x_red_code = ip_snp
                union
                select x_part_serial_no  x_parent_serial_no
                FROM sa.table_x_posa_card_inv posa
                where posa.x_red_code = ip_snp
                union
                select x_smp  x_parent_serial_no
                FROM sa.table_x_red_card rc
                where rc.x_red_code = ip_snp
                union
                select nvl(x_parent_part_serial_no,part_serial_no) x_parent_serial_no
                FROM table_part_inst pi,
                     sa.table_mod_level b,
                     sa.table_part_num c
                where pi.part_serial_no = ip_snp
                 and  b.objid = pi.n_part_inst2part_mod
                 and  c.objid = b.part_info2part_num
                 and  c.domain = 'REDEMPTION CARDS'
                --AND pi.x_domain = 'REDEMPTION CARDS'  10/18/2013 checking this condition in table_part_num
                UNION
                select x_part_serial_no  x_parent_serial_no
                FROM sa.table_x_posa_card_inv posa,
                     sa.table_mod_level b,
                     sa.table_part_num c
                where posa.x_part_serial_no = ip_snp
                 and  b.objid = posa.x_posa_inv2part_mod
                 and  c.objid = b.part_info2part_num
                 and  c.domain = 'REDEMPTION CARDS'
                --AND posa.x_domain = 'REDEMPTION CARDS'  10/18/2013 checking this condition in table_part_num
                union
                select x_smp  x_parent_serial_no
                from sa.table_x_red_card rc
                WHERE rc.x_smp = ip_snp
              )
    loop
      v_esn_or_snp := h.x_parent_serial_no;
    end loop;

  	-- CREATED FOR UC235 TO DETERMINE FAILURE TYPE
    for i in (
              SELECT pn.x_sourcesystem ss
              FROM  sa.TABLE_X_POSA_CARD_INV pc,
                    sa.table_mod_level ml,
                    sa.table_part_num pn
              WHERE pn.objid= ml.part_info2part_num
              and ml.objid = pc.x_posa_inv2part_mod
              and pc.x_domain='REDEMPTION CARDS'
              and pc.x_part_serial_no = v_esn_or_snp
              union
              select pn.x_sourcesystem ss
              from  sa.table_part_inst pc,
                    sa.table_mod_level ml,
                    sa.table_part_num pn
              where ml.objid= pc.N_PART_INST2PART_MOD
              and pn.objid = ml.part_info2part_num
              and pc.x_domain='REDEMPTION CARDS'
              and pc.part_serial_no = v_esn_or_snp
             )
    loop
      ret := i.ss;
    end loop;
    if ret = 'MULTI DENOM RED CARD' then
      return 'true';
    else
      return 'false';
    end if;
  exception
  	when others then
  		return 'false';
  end is_multi_denom;

END ADFCRM_GET_REDEMPTION;
/