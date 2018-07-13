CREATE OR REPLACE FUNCTION sa."ADFCRM_VERIFY_UNLOCK_EXCHANGE" (
   p_class_name     IN   VARCHAR2,
   p_esn            IN   VARCHAR2,
   p_overwrite      IN   VARCHAR2 DEFAULT 'false',
   p_lid            IN   VARCHAR2 DEFAULT NULL
)
   RETURN VARCHAR2
IS

  v_error varchar2(200);
  v_device_type varchar2(50);
  v_old_act_count number;
  v_days_paid number;
  v_days_paid_sl number;
  v_days_in_queue number;
  v_part_request varchar2(50);
  v_total_days number;
  v_case_type  varchar2(50);
  v_title varchar2(50);
  v_unlock_elegible varchar2(30);
  v_start_date date;
  v_min_paid_days number;
  v_min_active_days number;

  --Cursor to find Exchange part Number
  cursor c1 is select ex.x_new_part_num,ex.x_airbil_part_number,ex.x_exch_type
  from sa.table_x_class_exch_options ex,
     sa.table_part_class pc
  where ex.source2part_class = pc.objid
  and pc.name = p_class_name
  and ex.x_exch_type = 'UNLOCK'
  and ex.x_priority = 1;

  r1 c1%rowtype;

  --Cursor to find Case Configuration
  cursor c2 is select * from sa.table_x_case_conf_hdr
  where objid in (select x_param_value from sa.table_x_parameters where x_param_name = 'ADFCRM_UNLOCK_CASE_CONF');

  r2 c2%rowtype;

  --Cusor to find Similar Case Created Previously
  cursor c3
  is select id_number
  from sa.table_case
  where x_esn = p_esn
  and x_case_type = v_case_type
  and title = v_title;

  r3 c3%rowtype;

  --Cursor to Find Total Days Active
  cursor c4 is
  select (select nvl(sum(sp1.service_end_dt-sp1.install_date),0)
  from sa.table_site_part sp1
  where sp1.x_service_id = p_esn
  and sp1.part_status = 'Inactive'
  and nvl(x_refurb_flag,0) = 0) +
  (select nvl(sum(sysdate - install_date),0)
  from sa.table_site_part sp2
  where sp2.x_service_id = p_esn
  and sp2.part_status in ('Active','CarrierPending')) act_days
  from dual;

  r4 c4%rowtype;

  --Cursor to find total days for current Active Service.
  cursor c5 is
  select count(*) rec_count
  from sa.table_site_part
  where x_service_id = p_esn
  and (part_status in ('Active','CarrierPending')
  or (nvl(x_refurb_flag,0) = 0 and part_status = 'Inactive' and  service_end_dt > sysdate - 60));

  r5 c5%rowtype;

  --Cursor to find Account State or Contact Address State (Code=1 ==> Allowed)
  cursor c6 is
  select st.name,st.code
  from table_part_inst pi,
       table_x_contact_part_inst cpi,
       table_contact c,
       table_contact_role cr,
       table_site s,
       table_address a,
       table_state_prov st
  where pi.part_serial_no = p_esn
  and pi.x_domain = 'PHONES'
  and pi.objid = cpi.x_contact_part_inst2part_inst
  and cpi.x_contact_part_inst2contact = c.objid
  and cr.contact_role2contact = c.objid
  and cr.contact_role2site = s.objid
  and s.cust_primaddr2address = a.objid
  and a.state = st.name
  and a.address2country = st.state_prov2country
  union
  select st.name,st.code
  from table_part_inst pi,
       table_contact c,
       table_contact_role cr,
       table_site s,
       table_address a,
       table_state_prov st
  where pi.part_serial_no = p_esn
  and pi.x_domain = 'PHONES'
  and pi.x_part_inst2contact = c.objid
  and cr.contact_role2contact = c.objid
  and cr.contact_role2site = s.objid
  and s.cust_primaddr2address = a.objid
  and a.state = st.name
  and a.address2country = st.state_prov2country;

  r6 c6%rowtype;

begin

  -- Find ADFCRM_UNLOCK_MIN_PAID_SERVICE_DAYS configuration
  Begin
     select to_number(x_param_value)
     into v_min_paid_days
     from sa.table_x_parameters where x_param_name = 'ADFCRM_UNLOCK_MIN_PAID_SERVICE_DAYS';
  exception
     when others then
        v_min_paid_days := 360;
  end;

  -- Find ADFCRM_UNLOCK_START_DATE configuration
  Begin
     select to_date(x_param_value)
     into v_start_date
     from sa.table_x_parameters where x_param_name = 'ADFCRM_UNLOCK_START_DATE';
  exception
     when others then
        v_start_date := '01-feb-2014';
  end;

  --Find ADFCRM_UNLOCK_MIN_ACTIVE_DAYS configuration
  Begin
     select to_number(x_param_value)
     into v_min_active_days
     from sa.table_x_parameters where x_param_name = 'ADFCRM_UNLOCK_MIN_ACTIVE_DAYS';
  exception
     when others then
        v_min_active_days := 60;
  end;

  --Find Device Type,  Only Phones are allowed.
  v_device_type := sa.GET_PARAM_BY_NAME_FUN(
    IP_PART_CLASS_NAME => p_class_name,
    IP_PARAMETER => 'DEVICE_TYPE');

  if v_device_type <> 'FEATURE_PHONE' and v_device_type <> 'SMARTPHONE' and v_device_type <> 'NOT FOUND' then
     v_error:='ERROR: Device is not a cell phone, Unlock Exchange not allowed for: '||v_device_type;
     return v_error;
  end if;

  if p_overwrite <> 'true' then
    --If the Past Class Allowed??
    v_unlock_elegible := sa.GET_PARAM_BY_NAME_FUN(
      IP_PART_CLASS_NAME => p_class_name,
      IP_PARAMETER => 'UNLOCK_ELEGIBLE');

    if v_unlock_elegible <> 'Y' then
       v_error:='ERROR: Part class is not elegible for Unlock Exchange';
       return v_error;
    end if;
  end if;

  open c2;
  fetch c2 into r2;
  if c2%notfound then
     close c2;
     v_error:='ERROR: Unlock Exchange Case not defined in Parameters Table';
     return v_error;
  else
     close c2;
     v_case_type:=r2.x_case_type;
     v_title := r2.x_title;
     open c3;
     fetch c3 into r3;
     if c3%found then
        close c3;
        v_error:='ERROR: Previous Unlock Exchange Case Found for Serial Number';
        return v_error;
     else
        close c3;
     end if;
  end if;

  if p_class_name like '%BYOP%' then
     v_error:= 'ERROR: Unlock Exchange is not allowed for BYOP devices';
     return v_error;
  end if;

  select count(*)
  into v_old_act_count
  from sa.table_site_part
  where x_service_id = p_esn
  and install_date < v_start_date;

  if v_old_act_count >0 then
     v_error := 'ERROR: Unlock Exchange is not allowed for Phones Activated earlier than (02/01/2014)';
     return v_error;
  end if;

  --Days Paid
  select nvl(sum(red_days),0)
  into v_days_paid
  from table(sa.adfcrm_get_redemption.get_summary( p_esn , null ,'English'))
  where red_parent in ('PAID REDEMPTIONS','BILLING PROGRAM');

  --Days Paid SL
  if p_lid is not null then
    select count(*) * 30
    into v_days_paid_sl
    from x_sl_hist
    where x_esn = p_esn
    and x_event_code = '616';
  end if;

  --Days in Queue
  select nvl(sum (pnc.x_redeem_days),0)
  into v_days_in_queue
  from table_part_num pnc,
       table_mod_level mlc,
       table_part_inst pic,
       table_part_inst pi
  where pi.part_serial_no = p_esn
  and pi.x_domain = 'PHONES'
  and pic.part_to_esn2part_inst = pi.objid
  and pic.n_part_inst2part_mod = mlc.objid
  and pnc.domain ='REDEMPTION CARDS'
  and pic.x_part_inst_status = '400'
  and mlc.part_info2part_num = pnc.objid;

  v_total_days:= nvl(v_days_paid,0) + nvl(v_days_paid_sl,0);

  if p_overwrite <> 'true' then
      if v_total_days < v_min_paid_days  then
         v_error := 'ERROR: Unlock Exchange is not allowed for Phones with less than '||v_min_paid_days||' days of service paid and/or in reserve';
         return v_error;
      end if;

      open c4;
      fetch c4 into r4;
      if c4%found then
         close c4;
         if r4.act_days < v_min_active_days then
            v_error := 'ERROR: Unlock Exchange is not allowed for Phones that have been Active less than '||v_min_active_days||' days in total';
            return v_error;
         end if;
      else
         close c4;
      end if;

    open c5;
    fetch c5 into r5;
    if r5.rec_count = 0 then
       close c5;
          v_error := 'ERROR: Unlock Exchange is not allowed for Phones that have not been Active within the last 60 days';
          return v_error;
    else
       close c5;
    end if;

    open c6;
    fetch c6 into r6;
    if c6%notfound then  -- Cursor Order will chec Account State First and Then Contact State.
       close c6;
       v_error := 'ERROR: State of residence could not be determine';
       return v_error;
    else
       close c6;
       if r6.code <> 1 then
         v_error := 'ERROR: Unlock Exchange is not available for State: '||r6.name;
         return v_error;
       end if;
    end if;
  end if;

  open c1;
  fetch c1 into r1;
  if c1%found then
      close c1;
     if r1.x_new_part_num is not null then
        v_part_request:= r1.x_new_part_num;
        if r1.x_airbil_part_number is not null then
           v_part_request:= v_part_request||'||'||r1.x_airbil_part_number;
        end if;
     end if;
  else
     close c1;
     --v_error := 'ERROR: Unlock Exchange Part Number not defined for this model';
     --return v_error;
     v_part_request:='UNLOCK_PN_TBD||'||'AIRBILL';
  end if;


  return  v_part_request;

end;
/