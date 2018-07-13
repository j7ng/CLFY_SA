CREATE OR REPLACE procedure sa.handset_imgs(ipv_pc varchar2,
                       ipv_env varchar2 default 'handset')
as
  v_pc varchar2(30) := ipv_pc; --'handset'; -- IF NULL DEFAULTS TO WWW
  v_env varchar2(30) := ipv_env; --'NTLGL95G';
  -- ONLY APPLIES TO INSERT BATT AND SIM IMAGES
  -- 1 = large.jpg AND 2 = large.jpg + small.jpg
  n_insert_battery number := 2;
  n_insert_sim number := 2;
  -- RAPID REFILL SHOULD ALWAYS BE 4 STEPS UNLESS OTHERWISE DISCUSSED
  n_rapid_refill_step_cnt number := 4;
  n_buy_now_step_cnt number;
  n_find_esn number := 1;
  n_find_min number := 1;
  n_find_sim number := 1;
  n_turn_on   number := 1;
  v_img_path varchar2(80) := '/static/common/images/phones/'||v_pc;
  cnt number := 0;
  n_non_ppe number;
  v_bus_org varchar2(30);
  v_tech    varchar2(4);
  v_out     varchar2(4000);
  v_android_msg varchar2(100);
  is_avail number;
begin
  if v_env is null then
    v_env := 'www';
  end if;
  v_env := 'http://'||v_env||'.';
  -- FIRST IS THE HANDSET IN THE VIEW ------------------------------------------
  select count(*)
  into   is_avail
  from   released_phone_models
  where  name = v_pc;
  if is_avail = 0 then
    v_out := 'ERROR - HANDSET IS NOT DISPLAYING IN THE VIEW - NEEDS EXPORT - CONTACT PRODUCT MANAGEMENT';
    goto end_proc;
  end if;
  -- GATHER THE INFO -----------------------------------------------------------
  begin
    select to_number(param_value)
    into   n_non_ppe
    from   pc_params_view
    where  1=1
    and    part_class = v_pc
    and    param_name in ('NON_PPE');
  exception
    when others then
      n_non_ppe := 0;
      -- v_out := 'ERROR - NON_PPE VALUE ERROR';
      -- goto end_proc;
  end;
  begin
    select param_value
    into   v_tech
    from   pc_params_view
    where  1=1
    and    part_class = v_pc
    and    param_name in ('TECHNOLOGY');
  exception
    when others then
      v_out := 'ERROR - MISSING TECHNOLOGY CANNOT CONTINUE';
      goto end_proc;
  end;
  begin
    select param_value
    into   v_bus_org
    from   pc_params_view
    where  1=1
    and    part_class = v_pc
    and    param_name in ('BUS_ORG');
  exception
    when others then
      v_out := 'ERROR - MISSING BUS_ORG CANNOT CONTINUE';
      goto end_proc;
  end;
  -- AUGMENT PATH W/BRAND ------------------------------------------------------
  if (v_bus_org = 'STRAIGHT_TALK')then
    v_img_path := v_env||'straighttalk.com'||v_img_path;
  elsif (v_bus_org = 'NET10') then
    v_img_path := v_env||'net10.com'||v_img_path;
  else
    v_img_path := v_env||'tracfone.com'||v_img_path;
  end if;
  -- MANUALS AND ROOT IMAGES ---------------------------------------------------
  if (v_bus_org = 'STRAIGHT_TALK') then
    v_out := v_out||v_img_path||'/small.gif'||chr(10);
    v_out := v_out||v_img_path||'/manuals/manual_en.pdf'||chr(10);
    goto end_proc;
  else
    v_out := v_out||v_img_path||'/manuals/manual_en.pdf'||chr(10);
    v_out := v_out||v_img_path||'/manuals/manual_es.pdf'||chr(10);
    v_out := v_out||v_img_path||'/small.gif'||chr(10);
    v_out := v_out||v_img_path||'/large.gif'||chr(10);
    v_out := v_out||v_img_path||'/xlarge.jpg'||chr(10);
  end if;
  -- BUY NOW AND RAPID REFILL IMAGES -------------------------------------------
  if (n_non_ppe = 0) then
    -- BUY NOW
    if (v_bus_org = 'NET10') then
      n_buy_now_step_cnt := 7;
    else
      n_buy_now_step_cnt := 8;
    end if;
    for cnt in 1..n_buy_now_step_cnt
    loop
      v_out := v_out||v_img_path||'/buy_now/Step'||cnt||'.jpg'||chr(10);
    end loop;
    -- RAPID REFILL
    for cnt in 1..n_rapid_refill_step_cnt
    loop
      v_out := v_out||v_img_path||'/rapid_refill/Step'||cnt||'.jpg'||chr(10);
    end loop;
  else
    v_android_msg := v_android_msg||'HANDSET IS ANDROID'||chr(10);
    v_android_msg := v_android_msg||'NO RAPID REFILL IMAGES'||chr(10);
    v_android_msg := v_android_msg||'NO BUY NOW IMAGES'||chr(10);
  end if;
  -- INSERT BATTERY ------------------------------------------------------------
  v_out := v_out||v_img_path||'/insert_battery/large.jpg'||chr(10);
  if n_insert_battery > 1 then
    v_out := v_out||v_img_path||'/insert_battery/small.jpg'||chr(10);
  end if;
  -- INSERT SIM AND FIND SIM IMAGES --------------------------------------------
  if (v_tech = 'GSM') then
    v_out := v_out||v_img_path||'/insert_sim/large.jpg'||chr(10);
    if n_insert_sim > 1 then
      v_out := v_out||v_img_path||'/insert_sim/small.jpg'||chr(10);
    end if;
    v_out := v_out||v_img_path||'/find_sim/large.jpg'||chr(10);
    if n_find_sim > 1 then
      v_out := v_out||v_img_path||'/find_sim/small.jpg'||chr(10);
    end if;
  end if;
  -- FIND ESN ------------------------------------------------------------------
  v_out := v_out||v_img_path||'/find_esn/large.jpg'||chr(10);
  if n_find_esn > 1 then
    v_out := v_out||v_img_path||'/find_esn/small.jpg'||chr(10);
  end if;
  -- FIND MIN ------------------------------------------------------------------
  v_out := v_out||v_img_path||'/find_min/large.jpg'||chr(10);
  if n_find_min > 1 then
    v_out := v_out||v_img_path||'/find_min/small.jpg'||chr(10);
  end if;
  -- TURN PHONE ON -------------------------------------------------------------
  v_out := v_out||v_img_path||'/turn_on/large.jpg'||chr(10);
  <<end_proc>>
  v_out := v_android_msg ||v_out;
  dbms_output.put_line('---------------------------------------------------------');
  dbms_output.put_line('ASSOC ACTIVATION/REACTIVATION SCRIPT ID''S ');
  dbms_output.put_line('---------------------------------------------------------');
  dbms_output.put_line('TEC_22314 - insert SIM');
  dbms_output.put_line('TEC_22263 - insert batteries');
  dbms_output.put_line('TEC_22502 - Find ESN');
  dbms_output.put_line('TEC_22638 - Find MIN');
  dbms_output.put_line('TEC_22630 - Find SIM');
  dbms_output.put_line('---------------------------------------------------------');
  dbms_output.put_line('PARTCLASS: '||v_pc||' BUS_ORG: '||v_bus_org||' TECH: '||v_tech);
  dbms_output.put_line('STATIC IMAGE LIST');
  dbms_output.put_line('---------------------------------------------------------');
  dbms_output.put_line(v_out);
end handset_imgs;
/