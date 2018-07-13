CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_TRANSACTIONS" AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_TRANSACTIONS_PKB.sql,v $
--$Revision: 1.18 $
--$Author: mmunoz $
--$Date: 2017/02/27 17:10:54 $
--$ $Log: ADFCRM_TRANSACTIONS_PKB.sql,v $
--$ Revision 1.18  2017/02/27 17:10:54  mmunoz
--$ CR46822 for credit card registration: address1, city, state should not be required field
--$
--$ Revision 1.17  2015/06/03 19:46:04  hcampano
--$ CR35422 - Remove state validation from Case Address Validation Procedure
--$
--$ Revision 1.16  2015/05/14 13:09:08  mmunoz
--$ Merged rev 1.14 and 1.15
--$
--$ Revision 1.15  2015/05/11 13:07:36  mmunoz
--$ CR29587  Changes in IS_BALANCE_INQ_REQUIRED to force Ericsson = SurePay Balance Metering + GSM
--$
--$ Revision 1.12  2015/03/18 22:20:23  mmunoz
--$ updated function is_balance_inq_required to Includ validation for Active ESN in EXCHANGE action
--$
--$ Revision 1.11  2015/03/09 20:44:21  mmunoz
--$ Exception in balance_metering for AWOP in TRACFONE,NET10 with PAY_GO
--$
--$ Revision 1.10  2015/02/10 22:11:02  nguada
--$ zip code changes
--$
--$ Revision 1.9  2014/12/08 21:11:10  hcampano
--$ TAS_2014_11 - Added change to accomodate new balance metering type PPE_DTT for the H350 home center
--$
--$ Revision 1.8  2014/11/04 20:13:41  nguada
--$ CR30533
--$
--$ Revision 1.7  2014/11/04 20:09:22  nguada
--$ CR30533
--$
--$ Revision 1.6  2014/10/27 22:05:16  mmunoz
--$ TAS_2014_09B changes in address (procedure)
--$
--$ Revision 1.5  2014/10/27 15:49:44  mmunoz
--$ commented code for TAS_2014_10B
--$
--$ Revision 1.4  2014/10/27 15:48:26  mmunoz
--$ Added procedure address
--$
--$ Revision 1.3  2014/10/22 22:10:22  mmunoz
--$ Added new function is_balance_inq_required
--$
--$ Revision 1.2  2014/08/21 22:14:10  mmunoz
--$ Added function balance_metering
--$
--$ Revision 1.1  2014/03/12 18:56:38  mmunoz
--$ CR26941
--$
--------------------------------------------------------------------------------------------

  function update_call_trans_user (p_esn              in varchar2,
                                   p_call_trans_objid in number,
                                   p_user_name        in varchar2) return varchar2
  as

  cursor user_cur is
  select objid from table_user
  where s_login_name = upper(p_user_name);

  user_rec user_cur%rowtype;
  msg varchar2(300);

  begin

  open user_cur;
  fetch user_cur into user_rec;
  if user_cur%found then
  if p_call_trans_objid is not null then
     update table_x_call_trans
     set x_call_trans2user = user_rec.objid
     where objid = p_call_trans_objid;
     msg:='Records Updated: ('||sql%rowcount||')';
  else
     if p_esn is not null then
        update table_x_call_trans
        set x_call_trans2user = user_rec.objid
        where x_service_id = p_esn
        and x_transact_date >= sysdate - (30/86400);  --30 seconds
        msg:='Records Updated: ('||sql%rowcount||')';
     else
        msg:='ERROR: Missing esn parameter';
     end if;
  end if;
  else
     msg:='ERROR: user not found';
  end if;
  close user_cur;
  commit;
  return msg;

  exception when others then
     return 'ERROR: '||SQLCODE||' '||SQLERRM;
  end update_call_trans_user;
--------------------------------------------------------------------------------------------
function balance_metering (
   p_esn varchar2,
   p_action varchar2,  --COMPENSATION / REPLACEMENT
   p_serv_plan_group varchar2
)
return varchar2 is
cursor get_esn_info is
   select pc.name part_class,
          bo.org_id,
          pn.x_dll
   from table_part_inst pi
       ,sa.table_mod_level ml
       ,sa.table_part_num pn
       ,sa.table_bus_org bo
       ,sa.table_part_class pc
  where 1 = 1
  and   pi.part_serial_no = p_esn
  and   pi.x_domain = 'PHONES'
  and   ml.objid = pi.n_part_inst2part_mod
  and   pn.objid = ml.part_info2part_num
  and   bo.objid = pn.part_num2bus_org
  and   pc.objid = pn.part_num2part_class
 ;

cursor get_carrier is
		 select caparent.x_queue_name
         from table_part_inst pi
              ,table_x_carrier ca
              ,table_part_inst piline
              ,table_x_carrier_group cagrp
              ,table_x_parent caparent
         where ca.objid = piline.part_inst2carrier_mkt
         and   ca.carrier2carrier_group = cagrp.objid
         and   cagrp.x_carrier_group2x_parent = caparent.objid
         and   piline.objid = (select max(objid)
                               from   table_part_inst maxline
                               where  maxline.part_to_esn2part_inst = pi.objid)
         and   pi.part_serial_no = p_esn
         and   pi.x_domain = 'PHONES'
		 ;

get_carrier_rec get_carrier%rowtype;
get_esn_info_rec get_esn_info%rowtype;
v_bal_metering  varchar2(100);
begin
   open get_esn_info;
   fetch get_esn_info into get_esn_info_rec;
   if get_esn_info%found then
      v_bal_metering := sa.get_param_by_name_fun(get_esn_info_rec.part_class,'BALANCE_METERING');
      if v_bal_metering = 'PPE_DTT' then
        return v_bal_metering;
      end if;
   end if;
   close get_esn_info;

   open get_carrier;
   fetch get_carrier into get_carrier_rec;
   if get_carrier%found then

    if get_carrier_rec.x_queue_name = 'VERIZON' and
         get_esn_info_rec.org_id = 'STRAIGHT_TALK' and
         NOT(p_serv_plan_group  like '%UNLIMITED%' OR p_serv_plan_group  like 'VOICE_ONLY%' OR p_serv_plan_group  like 'DATA_ONLY%') --ALL YOU NEED
      then
         v_bal_metering := 'SUREPAY';
      end if;
    if get_carrier_rec.x_queue_name <> 'VERIZON' and
         get_esn_info_rec.org_id = 'STRAIGHT_TALK' and
         NOT(p_serv_plan_group  like '%UNLIMITED%' OR p_serv_plan_group  like 'VOICE_ONLY%' OR p_serv_plan_group  like 'DATA_ONLY%')  --ALL YOU NEED
      then
         v_bal_metering := 'PPE_MTT';
      end if;
    if v_bal_metering = 'NOT FOUND' and p_action = 'AWOP' and p_serv_plan_group = 'PAY_GO' and get_esn_info_rec.org_id in ('TRACFONE','NET10') and
       get_esn_info_rec.x_dll >= 10
      then
         v_bal_metering := 'PPE_STT';
      end if;
    if v_bal_metering = 'NOT FOUND' and p_action = 'AWOP' and p_serv_plan_group = 'PAY_GO' and get_esn_info_rec.org_id in ('TRACFONE','NET10') and
       get_esn_info_rec.x_dll <= 0
      then
         v_bal_metering := 'SUREPAY';
      end if;
   end if;
   close get_carrier;
   return v_bal_metering;
end balance_metering;
--------------------------------------------------------------------------------------------
function is_balance_inq_required (
   from_esn varchar2,
   to_esn varchar2,
   ip_action varchar2  --TRANSFER_UNITS, UPGRADE, EXCHANGE
)
return varchar2 is
    cursor get_esn_info (ip_esn varchar2) is
       select pc.name part_class,
              bo.org_id,
              sa.get_param_by_name_fun(pc.name,'BALANCE_METERING') balance_metering,
              decode(sa.get_param_by_name_fun(pc.name,'NON_PPE'),'1','false','0','true','false') IS_PPE,
              pn.x_technology
       from table_part_inst pi
           ,sa.table_mod_level ml
           ,sa.table_part_num pn
           ,sa.table_bus_org bo
           ,sa.table_part_class pc
      where 1 = 1
      and   pi.part_serial_no = ip_esn
      and   pi.x_domain = 'PHONES'
      and   ml.objid = pi.n_part_inst2part_mod
      and   pn.objid = ml.part_info2part_num
      and   bo.objid = pn.part_num2bus_org
      and   pc.objid = pn.part_num2part_class
     ;

   cursor get_esn_serv_plan (ip_esn in varchar2) is
      select sp.x_service_id , xspsp.x_service_plan_id service_plan_id
             ,NVL(sa.ADFCRM_GET_SERV_PLAN_VALUE(xspsp.x_service_plan_id,'SERVICE_PLAN_GROUP')
                 ,'PAY_GO') service_plan_group
             ,sp.part_status
      from  sa.table_site_part          sp
           ,sa.x_service_plan_site_part xspsp
      where sp.x_service_id =  ip_esn
      --and   sp.part_status in ('Active','CarrierPending')
      and  xspsp.table_site_part_id (+) = sp.objid
      order by sp.install_date desc;

get_from_esn_rec get_esn_info%rowtype;
get_to_esn_rec get_esn_info%rowtype;
get_esn_serv_plan_rec get_esn_serv_plan%rowtype;
op_result  varchar2(400);
v_bal_inq_flag number;
begin
   v_bal_inq_flag := 0;
   op_result := 'false';
/***************** TAS_2014_10B  ************************************/
   open get_esn_info(from_esn);
   fetch get_esn_info into get_from_esn_rec;
   close get_esn_info;

   if get_from_esn_rec.balance_metering = 'NOT FOUND' and
      get_from_esn_rec.is_ppe = 'true'
   then
      get_from_esn_rec.balance_metering := 'PPE_STT';
   end if;

   if get_from_esn_rec.balance_metering = 'SUREPAY' and
      get_from_esn_rec.x_technology = 'GSM'
   then
      get_from_esn_rec.balance_metering := 'ERICSSON';
   end if;

   open get_esn_serv_plan(from_esn);
   fetch get_esn_serv_plan into get_esn_serv_plan_rec;
   close get_esn_serv_plan;

   if get_esn_serv_plan_rec.part_status != 'Active' and
      ip_action = 'EXCHANGE'
   then
      return 'false';
   end if;

   open get_esn_info(to_esn);
   fetch get_esn_info into get_to_esn_rec;
   close get_esn_info;

   if get_to_esn_rec.balance_metering = 'NOT FOUND' and
      get_to_esn_rec.is_ppe = 'true'
   then
      get_to_esn_rec.balance_metering := 'PPE_STT';
   end if;

   if get_to_esn_rec.balance_metering = 'SUREPAY' and
      get_to_esn_rec.x_technology = 'GSM'
   then
      get_to_esn_rec.balance_metering := 'ERICSSON';
   end if;

   select count(*)
   into v_bal_inq_flag
   from adfcrm_balance_inq_required
   where action = ip_action
   and service_plan_group = get_esn_serv_plan_rec.service_plan_group
   and brand_name  = get_from_esn_rec.org_id
   and from_balance_metering  = get_from_esn_rec.balance_metering
   and to_balance_metering  = get_to_esn_rec.balance_metering;

   if v_bal_inq_flag > 0
   then
      op_result := 'true';
   else
      op_result := 'false';
   end if;
/***************** TAS_2014_10B  ************************************/
   return op_result;
end is_balance_inq_required;
--------------------------------------------------------------------------------------------
  procedure address (p_add_1 in varchar2,
                            p_add_2 in varchar2,
                            p_city in varchar2,
                            p_st in varchar2,
                            p_zip in varchar2,
                            p_country in varchar2,
                            p_address_objid in out number,  -- null--> Create / not null --> Update Address
                            p_address_type in varchar2, --PRIMARY, BILLING, SHIPPING
                            p_contact_objid in varchar2,
                            p_err_code out varchar2,
                            p_err_msg  out varchar2)
  is
    cursor timezone_curs is
      select *
        from table_time_zone
       where name = 'EST';

    timezone_rec timezone_curs%rowtype;

    cursor country_curs (c_country in varchar2) is
      select *
        from table_country
       where name = c_country;

    country_rec country_curs%rowtype;

    cursor state_curs
    (
      c_st            in varchar2
     ,c_country_objid in number
    ) is
      select *
        from table_state_prov
       where s_name = upper(c_st)
         and state_prov2country = c_country_objid;

    state_rec state_curs%rowtype;

    cursor address_curs (c_add_objid in varchar2) is
    select * from table_address
    where objid = c_add_objid;

    address_rec address_curs%rowtype;

    cursor zip_cur (c_zip in varchar2) is
      select *
        from sa.table_x_zip_code
       where x_zip = c_zip;

    zip_rec zip_cur%rowtype;

    v_site_cnt number;
	v_address_objid number;
  begin
     p_err_code := '0';
     p_err_msg  := 'Address Updated';
     v_site_cnt := 0;

     open country_curs(c_country => nvl(p_country,'USA'));
     fetch country_curs into country_rec;
     if country_curs%found then
         close country_curs;
     else
         close country_curs;
         p_err_code := '161';
         p_err_msg  := 'Country record Not found ('||p_country||')';
         return;
     end if;

     if p_address_objid is NOT null and p_address_type = 'BILLING' then
          --check if customer primary address is the same as billing
          select count(s.objid)
          into  v_site_cnt
          from table_site s
          where s.cust_primaddr2address = p_address_objid
          and  s.cust_billaddr2address = p_address_objid;

          if nvl(v_site_cnt,0) > 0 then
               --reset the address objid to create a new one
               p_address_objid := null;
               v_address_objid := p_address_objid;
          end if;
     end if;

    --CR46822 for credit card registration, address1, city, state should not be required field
    if (p_country is not null and p_city is not null and p_st is not null and p_zip is not null)
    then
           validate_address(p_add_1,
                            p_add_2,
                            p_city,
                            p_st,
                            p_zip,
                            p_country,
                            p_err_code,
                            p_err_msg);
    end if;

    if p_err_code != '0' then
        return;
    end if;

    if p_address_objid is not null then

        open address_curs(p_address_objid);
        fetch address_curs into address_rec;
        if address_curs%found then
            close address_curs;
            update table_address
            set address = p_add_1
            ,s_address = upper(p_add_1)
            ,city = p_city
            ,s_city = upper(p_city)
            ,state = p_st
            ,s_state = upper(p_st)
            ,zipcode = p_zip
            ,address_2 = p_add_2
            ,address2time_zone = timezone_rec.objid
            ,address2country = country_rec.objid
            ,address2state_prov = state_rec.objid
            ,update_stamp = sysdate
            where objid = p_address_objid;
        else
            close address_curs;
            p_err_code := '160';
            p_err_msg  := 'Address Record Not found (objid: '||to_char(p_address_objid)||')';
            return;

        end if;
    else

      select sa.seq('address') into p_address_objid from dual;

      insert into table_address
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
    values
      (p_address_objid
      ,p_add_1
      ,upper(p_add_1)
      ,nvl(zip_rec.x_city,p_city)
      ,upper(nvl(zip_rec.x_city,p_city))
      ,nvl(zip_rec.x_state,p_st)
      ,upper(nvl(zip_rec.x_state,p_st))
      ,nvl(zip_rec.x_zip,p_zip)
      ,p_add_2
      ,null
      ,timezone_rec.objid
      ,country_rec.objid
      ,state_rec.objid
      ,sysdate);

      if nvl(v_site_cnt,0) > 0 then
	     --update site part record with new address created
	     update table_site s
	     set s.cust_billaddr2address = p_address_objid
	     where s.cust_primaddr2address = v_address_objid
	     and  s.cust_billaddr2address = v_address_objid;
      end if;
    end if;
  commit;

  exception
    when others then
      rollback;
      p_err_code := sqlcode;
      p_err_msg  := sqlerrm;
      return;
  end address;

-----------------------------------------------------------------------------------------------------------------------------
--New procedure validate_address for CR32682
-----------------------------------------------------------------------------------------------------------------------------
procedure validate_address(p_add_1 in varchar2,
                            p_add_2 in varchar2,
                            p_city in varchar2,
                            p_st in varchar2,
                            p_zip in varchar2,
                            p_country in varchar2,
                            p_err_code out varchar2,
                            p_err_msg  out varchar2)
  is
    cursor timezone_curs is
      select *
        from table_time_zone
       where name = 'EST';

    timezone_rec timezone_curs%rowtype;

    cursor country_curs (c_country in varchar2) is
      select *
        from table_country
       where name = c_country;

    country_rec country_curs%rowtype;

    cursor state_curs
    (
      c_st            in varchar2
     ,c_country_objid in number
    ) is
      select *
        from table_state_prov
       where s_name = upper(c_st)
         and state_prov2country = c_country_objid;

    state_rec state_curs%rowtype;

    cursor address_curs (c_add_objid in varchar2) is
    select * from table_address
    where objid = c_add_objid;

    address_rec address_curs%rowtype;

    cursor zip_cur (c_zip in varchar2) is
      select *
        from sa.table_x_zip_code
       where x_zip = c_zip;

    zip_rec zip_cur%rowtype;

  begin
     p_err_code := '0';
     p_err_msg  := 'Address Valid';

    if p_add_1 is null then
        p_err_code := '100';
        p_err_msg  := 'Invalid Address';
        return;
    end if;

    open timezone_curs;

    fetch timezone_curs
      into timezone_rec;

    if timezone_curs%notfound then
      p_err_code := '130';
      p_err_msg  := 'No Valid Time Zone found';
      return;
    end if;

    close timezone_curs;

    open country_curs(p_country);

    fetch country_curs
      into country_rec;

    if country_curs%notfound then
      p_err_code := '140';
      p_err_msg  := 'No Valid Country found';
      return;
    end if;

    close country_curs;

    -- Validate State Only for US
    if country_rec.name in ('USA','US') then
      open state_curs(p_st,country_rec.objid);
      --1.1
      fetch state_curs
        into state_rec;
      if state_curs%notfound then
        -- use the zipcode to get the state
        -- IF STATE VALIDATION FAILS
        -- CONTINUE FORWARD AND VALIDATE AGAINST
        -- THE ZIPCODE
        -- BASED OFF CASE CREATION 6/2/2015 ROLLOUT
        -- EMERGENCY CREATED BECAUSE THIS FAILURE POINT
        -- CAUSED EXCEPTIONS IN THE CASE CREATION
        -- CR35422 - Remove state validation from Case Address Validation Procedure
        NULL;
--
--        p_err_code := '150';
--        p_err_msg  := 'No Valid State Code found';
--        return;
      end if;
      close state_curs;

    open zip_cur (p_zip);
    fetch zip_cur
      into zip_rec;

    if zip_cur%found then
      fetch zip_cur
        into zip_rec;

      if zip_cur%found then
        close zip_cur;

        p_err_code := '110';
        p_err_msg  := 'Multiple zipcode data found';
        return;
      end if;
    else
      close zip_cur;

      p_err_code := '120';
      p_err_msg  := 'Invalid Zipcode';
      return;
    end if;

    end if;

  exception
    when others then
      p_err_code := sqlcode;
      p_err_msg  := sqlerrm;
      return;
  end validate_address;

END ADFCRM_TRANSACTIONS;
/