CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_CARRIER" is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_CARRIER_PKB.sql,v $
--$Revision: 1.26 $
--$Author: syenduri $
--$Date: 2017/11/15 23:21:39 $
--$ $Log: ADFCRM_CARRIER_PKB.sql,v $
--$ Revision 1.26  2017/11/15 23:21:39  syenduri
--$ CR53530 - Added get_ig_status_error_message function
--$
--$ Revision 1.25  2017/11/09 22:39:13  syenduri
--$ CR53530 - IG Action Item Status
--$
--$ Revision 1.24  2017/10/03 20:39:37  mmunoz
--$ Updated function reset_posa, user_name = upper(p_login_name) when checking security_access
--$
--$ Revision 1.23  2017/08/25 17:24:08  hcampano
--$ CR52985	 - Multi Denomination Cards - Customer Care Rel
--$
--$ Revision 1.22  2017/07/12 14:48:17  pkapaganty
--$ CR48187 and CR49838
--$
--$ Revision 1.21  2017/07/12 14:37:25  pkapaganty
--$ CR48187 and CR49838
--$
--$ Revision 1.20  2017/07/11 21:49:14  pkapaganty
--$ CR48187 and CR49838 API to check if 2 SIMs belong to same carrier or different carrier
--$
--$ Revision 1.19  2017/04/07 13:28:06  nguada
--$ Bug fix WFM
--$
--$ Revision 1.18  2017/04/06 18:15:43  nguada
--$ Unreserved blocked for WFM
--$
--$ Revision 1.17  2017/04/06 12:08:06  nguada
--$ WFM:  check Sa.x_part_inst_ext before unreserving
--$
--$ Revision 1.16  2017/01/18 23:18:29  nguada
--$ Bug Fix on log for failed attemps
--$
--$ Revision 1.15  2017/01/18 22:45:46  nguada
--$ write log for POSA always,  new action 999 for failed attempts
--$
--$ Revision 1.14  2016/07/19 22:15:13  nguada
--$ domain to x_domain
--$
--$ Revision 1.13  2016/07/19 22:02:24  nguada
--$ domian =  'LINES' added to reserve line to ESN utility to avoid removing reserved cards.
--$
--$ Revision 1.12  2014/10/20 21:15:42  nguada
--$ 31310	Update Change Ownership Tool for Sprint to use Order type POC
--$
--$ Revision 1.11  2014/08/13 21:27:07  hcampano
--$ Issue w/production and ESN vs red card validation. changed validation after speaking w/Elizabeth to just make sure ESN exists.
--$
--$ Revision 1.10  2014/08/11 19:39:30  nguada
--$ Fixes to getMSL to include SPC
--$
--$ Revision 1.9  2014/07/30 15:14:29  hcampano
--$ TAS_2014_06 - Mark Card invalid. Added validation to compare esn + pin brands and fail if different.
--$
--$ Revision 1.8  2014/07/30 14:33:35  hcampano
--$ TAS_2014_06 - Mark Card invalid. Added validation to compare esn + pin brands and fail if different.
--$
--$ Revision 1.7  2014/06/24 12:26:53  hcampano
--$ 7/2014 TAS release (TAS_2014_06) overloaded mark_card_invalid. CR29035
--$
--$ Revision 1.6  2014/04/15 17:22:23  nguada
--$ Defect fix
--$
--$ Revision 1.5  2014/04/09 17:59:21  nguada
--$ Bug fix
--$
--$ Revision 1.4  2014/04/09 17:56:06  nguada
--$ Bug fix
--$
--$ Revision 1.3  2014/04/09 15:37:08  hcampano
--$ CR27607
--$
--$ Revision 1.2  2013/12/17 20:42:13  mmunoz
--$ CR26679
--$
--$ Revision 1.1  2013/12/06 19:54:48  mmunoz
--$ CR26679  TAS Various Enhancments
--$
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
  function add_line (p_esn        in varchar2,
                     p_case_objid in varchar2,
                     p_carrier_id in varchar2,
                     p_account_no in varchar2,
                     p_mdn        in varchar2,
                     p_user_objid in varchar2,
                     p_expiration_date in  varchar2,
                     p_same_msid  in varchar2,
                     p_specify_msid in varchar2) return varchar2
  as
    --------------------------------------------------------------------------------
    -- PORT IN ADD A LINE
    -- CHECKS THE AVAILABILITY OF A MIN AND RESERVES IT TO AN ESN
    -- BASED ON THE "ADD LINE" FUNCTIONALITY IN THE FAT CLIENT
    --------------------------------------------------------------------------------
      n_msid                number;
      v_out_msg             varchar2(300);
    --------------------------------------------------------------------------------
      v_npa                 varchar2(3);
      v_nxx                 varchar2(3);
      v_ext                 varchar2(4);
      n_case_objid          number := P_CASE_OBJID;
      n_carrier_objid       number;
      n_carrier2personality number;
      n_carrier2rules       number;
      n_carrier_acc_objid   number;
      n_x_msid_check        number;
      n_pi_objid            number;
      n_acct_hist_objid     number;
      n_hist_rslt           number;
      n_mod_lvl_objid       table_mod_level.objid%type;
      n_esn_objid           table_part_inst.part_serial_no%type;
      n_x_code_objid        table_x_code_table.objid%type;
      v_domain              table_part_num.domain%type :='LINES';
      v_x_code_number       table_x_code_table.x_code_number%type;
    -------------------------------------------------------------------------------
    -- MAIN BODY
    --------------------------------------------------------------------------------
  begin
    v_npa := substr(trim(P_MDN),0,3);
    v_nxx := substr(trim(p_mdn),4,3);
    v_ext := substr(trim(p_mdn),7,4);

    if to_number(P_SAME_MSID) = 1 then
      n_msid := trim(p_mdn);
    else
      n_msid := trim(P_SPECIFY_MSID);
      if n_msid is null then
         n_msid := trim(P_MDN);
      end if;
    end if;

    -- GET THE ESN TO LINK THE NEW LINE TO
    begin
      select objid
      into   n_esn_objid
      from   table_part_inst
      where  1=1
      and    part_serial_no = p_ESN;
    exception
      when no_data_found then
        v_out_msg := 'ESN NOT FOUND';
        goto end_prc;
    end;

    -- THIS SHOULD RETURN ZERO IF EXISTS EXIT THE PRGRAM
    select count(*)
    into   n_x_msid_check
    from   table_part_inst
    where  1=1
    and    x_part_inst_status in ('11','12','13','15','16','34','37','73','38','39','110')
    and    x_domain = v_domain
    and   (x_msid   = to_char(n_msid)
    or     x_npa    = v_npa
    and    x_nxx    = v_nxx
    and    x_ext    = v_ext);

    if n_x_msid_check > 0 then
      v_out_msg := 'NUMBER '||trim(p_mdn)||' IS ALREADY IN USE OR HAS A STATUS THAT DOES NOT ALLOW IT TO BE ADDED.';
      goto end_prc;
    end if;

    -- GET THE CODE TABLE INFO FOR (PORT IN MIN RESERVED)
    begin
      select objid,
             x_code_number
      into   n_x_code_objid,
             v_x_code_number
      from   table_x_code_table
      where  1=1
      and    x_code_name = 'PORT IN MIN RESERVED'
      and    x_code_type = 'LS';
    exception
      when others then
      v_out_msg := 'ERROR - table_x_code_table - code:'||v_x_code_number||' - '||sqlerrm;
      goto end_prc;
    end;

    -- CARRIER PERSONALITY RECORD
    begin
      select objid,
             carrier2personality,
             carrier2rules
      into   n_carrier_objid,
             n_carrier2personality,
             n_carrier2rules
      from   table_x_carrier
      where  1=1
      and    x_carrier_id = P_CARRIER_ID;
    exception
      when others then
      v_out_msg := 'ERROR - table_x_carrier - n_carrier_objid:'||n_carrier_objid;
      v_out_msg := v_out_msg || ' - n_carrier2personality:'||n_carrier2personality;
      v_out_msg := v_out_msg || ' - n_carrier2rules:'||n_carrier2rules ||' '||sqlerrm;
      goto end_prc;
    end;

    -- GET THE MOD LEVEL
    begin
      select ml.objid
      into   n_mod_lvl_objid
      from   table_mod_level ml,
             table_part_num pn
      where  1=1
      and    ml.part_info2part_num = pn.objid
      and    pn.s_part_number = v_domain;
    exception
      when others then
      v_out_msg := 'ERROR - table_mod_level - n_mod_lvl_objid:'||n_mod_lvl_objid;
      goto end_prc;
    end;

    -- CHECK LUTS
    declare
      v_luts varchar2(3000);
    begin
      sp_check_luts(v_npa,v_nxx,v_luts);
      dbms_output.put_line(v_luts);
      --if v_luts <1 then
        --v_out_msg := 'ERROR - NPA AND NXX DO NOT EXIST IN LUTS TABLE LINE NOT ADDED.';
        -- goto end_prc;
      --end if;
    end;

    -- ISSUE W/SEQUENCE ORDER
    -- select sa.seq('part_inst') from dual;
    -- select max(objid) from table_part_inst

    -- GET THE PART INST OBJID
    select sa.seq('part_inst')
    into   n_pi_objid
    from   dual;

    -- GET THE ACCOUNT HIST OBJID
    select sa.seq('x_account_hist')
    into   n_acct_hist_objid
    from   dual;

    -- INSERT PART INST
    begin
      insert into table_part_inst
        (objid,
         part_good_qty,
         part_bad_qty,
         part_serial_no,
         last_pi_date,
         last_cycle_ct,
         next_cycle_ct,
         last_mod_time,
         last_trans_time,
         date_in_serv,
         warr_end_date,
         repair_date,
         part_status,
         good_res_qty,
         bad_res_qty,
         x_insert_date,
         x_sequence,
         x_creation_date,
         x_domain,
         x_deactivation_flag,
         x_reactivation_flag,
         x_cool_end_date,
         x_part_inst_status,
         x_npa,
         x_nxx,
         x_ext,
         n_part_inst2part_mod,
         part_inst2x_pers,
         part_inst2carrier_mkt,
         created_by2user,
         status2x_code_table,
         part_to_esn2part_inst,
         hdr_ind,
         x_msid,
         x_clear_tank,
         x_port_in)
      values
        (n_pi_objid,
         1,
         0,
         trim(p_mdn),
         to_date('1/1/1753', 'MM/DD/YYYY'), -- ( '1/1/1753', 'MM/DD/YYYY')
         to_date('1/1/1753', 'MM/DD/YYYY'),
         to_date('1/1/1753', 'MM/DD/YYYY'),
         to_date('1/1/1753', 'MM/DD/YYYY'),
         to_date('1/1/1753', 'MM/DD/YYYY'),
         to_date('1/1/1753', 'MM/DD/YYYY'),
         to_date(p_expiration_date,'MM/DD/YYYY'), -- 06/20/2011
         to_date('1/1/1753', 'MM/DD/YYYY'),
         'Active', -- part_status
         0,
         0,
         sysdate,
         0,
         sysdate,
         v_domain,
         0,
         0,
         to_date('1/1/1753', 'MM/DD/YYYY'),
         v_x_code_number,
         v_npa,
         v_nxx,
         v_ext,
         n_mod_lvl_objid,       --n_part_inst2part_mod,
         n_carrier2personality, --part_inst2x_pers
         n_carrier_objid,       --part_inst2carrier_mkt,
         P_USER_OBJID,          --created_by2user,
         n_x_code_objid,        --status2x_code_table,
         n_esn_objid,           --part_to_esn2part_inst,
         0,                     --hdr_ind,
         n_msid,                --x_msid,
         0,
         1);

    exception
      when others then
      v_out_msg := 'ERROR - table_part_inst:'||sqlerrm;
      goto end_prc;
    end;

    -- INSERT ACCOUNT HIST
    begin
      insert into table_x_account_hist
        (objid,
         account_hist2part_inst,
         account_hist2x_account,
         x_end_date,
         x_start_date)
      values
        (n_acct_hist_objid,
         n_pi_objid,
         n_carrier_acc_objid,
         to_date('1/1/1753', 'MM/DD/YYYY'),
         sysdate);

    exception
      when others then
      v_out_msg := 'ERROR - table_x_account_hist:'||sqlerrm;
      goto end_prc;
    end;

    -- INSERT PART INST HIST
    sa.insert_pi_hist_prc
      (p_user_objid,
       trim(p_mdn),
       '',
       '',
       '',
       'ADD LINE',
       n_hist_rslt);

    if n_hist_rslt > 0 then
      v_out_msg := 'ERROR - insert_pi_hist_prc';
      goto end_prc;
    end if;

    -- UPDATE MSID TABLE CASE
    begin

      update table_case
      set    x_min = trim(P_MDN),
             x_msid = to_char(n_msid)
      where  objid = to_char(n_case_objid);

    exception
      when others then
      v_out_msg := 'ERROR - table_case:'||n_case_objid;
      goto end_prc;
    end;

    goto end_prc;

    <<end_prc>>

    if v_out_msg is not null then
      rollback;
    else
      commit;
      v_out_msg := 'RESERVED '||P_ACCOUNT_NO||' SUCCESSFULLY';
    end if;

    return v_out_msg;

  exception
    when others then
      v_out_msg := 'ERROR - '|| sqlerrm;
      return v_out_msg;

  end add_line;
--------------------------------------------------------------------------------
  function add_promo (p_promotype varchar2,
					  p_bus_org varchar2,
					  p_start_date varchar2,
					  p_esn varchar2)
  return varchar2
  as
    pi_objid number;
    n_promotion_grp number;
    n_groupesn2x_promotion number;
    rec_found number := 0;
    rec_found2 number := 0;
    d_start_date date := nvl(to_date(p_start_date,'MM/DD/YYYY'),sysdate);
    d_end_date date := d_start_date+365;
    p_prg_grp_name varchar2(30);
    p_prg_code varchar2(30);
    op_msg varchar2(200);
    v_bus_org varchar2(40) := p_bus_org;

  begin

    if v_bus_org is null or v_bus_org = '' then
      begin
        select bo.org_id
        into   v_bus_org
        from   table_part_inst pi,
               table_mod_level m,
               table_part_num pn,
               table_bus_org bo
        where  pi.part_serial_no = p_esn
        and    pi.n_part_inst2part_mod = m.objid
        and    m.part_info2part_num = pn.objid
        and    pn.part_num2bus_org = bo.objid
        and    pi.x_domain = 'PHONES';
      exception
        when others then
          return 'Unable to identify bus org';
      end;
    end if;

    if p_promotype = 'DOUBLE' then
      p_prg_grp_name := 'DBLMIN_GRP';
      p_prg_code := 'RTDBL000';
      op_msg := 'Double Min Promo Added';
    elsif p_promotype = 'TRIPLE' then
      p_prg_grp_name := 'X3XMN_ACT_GRP';
      p_prg_code := 'X3XMN_ACT';
      op_msg := 'Triple Min Promo Added';
    else
      return 'Promotype is required.';
    end if;

    select count(*)
    into   rec_found
    from   table_x_group2esn,
           table_part_inst,
           table_x_promotion_group,
           table_x_promotion
    where  part_serial_no = p_esn
    and    groupesn2part_inst = table_part_inst.objid
    and    groupesn2x_promo_group = table_x_promotion_group.objid
    and    groupesn2x_promotion = table_x_promotion.objid
    and    x_promo_code='X3XMN_ACT'
    and    group_name='X3XMN_ACT_GRP'
    and    table_x_group2esn.x_end_date > sysdate;

    select count(*)
    into   rec_found2
    from   table_x_group2esn,
           table_part_inst,
           table_x_promotion_group,
           table_x_promotion
    where  part_serial_no = p_esn
    and    groupesn2part_inst = table_part_inst.objid
    and    groupesn2x_promo_group = table_x_promotion_group.objid
    and    group_name='DBLMIN_GRP'
    and    groupesn2x_promotion = table_x_promotion.objid
    and    x_promo_code='RTDBL000'
    and    table_x_group2esn.x_end_date > sysdate;

    if rec_found = 0 and
       rec_found2 = 0 and
       v_bus_org = 'TRACFONE' then

        select objid
        into   pi_objid
        from   table_part_inst
        where  part_serial_no = p_esn
        and    x_domain = 'PHONES';

        select objid
        into   n_promotion_grp
        from   table_x_promotion_group
        where  group_name = p_prg_grp_name;

        select objid
        into   n_groupesn2x_promotion
        from   table_x_promotion
        where  x_promo_code = p_prg_code;

        insert into table_x_group2esn
         (objid,
          x_annual_plan,
          groupesn2part_inst,
          groupesn2x_promo_group,
          x_end_date,
          x_start_date,
          groupesn2x_promotion)
        values
         (sa.seq('x_group2esn'),
          1,
          pi_objid,
          n_promotion_grp,
          d_end_date,
          d_start_date,
          n_groupesn2x_promotion);

      if p_promotype = 'TRIPLE' then
        -- IF TRIPLE MIN CARD PROCEED
        select objid
        into n_promotion_grp
        from table_x_promotion_group
        where group_name = 'X3XMN_GRP';

        insert into table_x_group2esn
         (objid,
          x_annual_plan,
          groupesn2part_inst,
          groupesn2x_promo_group,
          x_end_date,
          x_start_date,
          groupesn2x_promotion)
        values
         (sa.seq('x_group2esn'),
          0,
          pi_objid,
          n_promotion_grp,
          '31-DEC-2055',
          d_start_date,
          null);

      end if;

      commit;

      return op_msg;

    else
      return 'ESN ('||p_esn||') does not qualify for '||p_promotype||' min promo or is already member '||v_bus_org;
    end if;

  exception
    when others then
      return 'Unable to add '||p_promotype||' promotion ';
  end add_promo;
--------------------------------------------------------------------------------
  function add_upd_carr_zone (p_npa varchar2,
							  p_nxx varchar2,
							  p_carrier_id number,
							  p_carrier_name varchar2,
							  p_lead_time number,
							  p_target_level number,
							  p_ratecenter varchar2,
							  p_state varchar2,
							  p_carrier_id_description varchar2,
							  p_zone varchar2,
							  p_county varchar2,
							  p_marketid number,
							  p_mrkt_area varchar2,
							  p_sid varchar2,
							  p_technology varchar2,
							  p_frequency1 number,
							  p_frequency2 number,
							  p_bta_mkt_number varchar2,
							  p_bta_mkt_name varchar2,
							  p_gsm_tech varchar2,
							  p_cdma_tech varchar2,
							  p_mnc varchar2,
							  p_npanxxzoneid rowid)
  return varchar2
  as
    v_npanxxzoneid rowid := p_npanxxzoneid;
    v_entry_exists number;
    v_zone_exists number;
    v_cnt number;
    v_out_msg varchar2(100);

    procedure display_msg
    as
    begin
      dbms_output.put_line('==================================================');
      dbms_output.put_line('p_npa:'||p_npa);
      dbms_output.put_line('p_nxx:'||p_nxx);
      dbms_output.put_line('p_carrier_id:'||p_carrier_id);
      dbms_output.put_line('p_carrier_name:'||p_carrier_name);
      dbms_output.put_line('p_lead_time:'||p_lead_time);
      dbms_output.put_line('p_target_level:'||p_target_level);
      dbms_output.put_line('p_ratecenter:'||p_ratecenter);
      dbms_output.put_line('p_state:'||p_state);
      dbms_output.put_line('p_carrier_id_description:'||p_carrier_id_description);
      dbms_output.put_line('p_zone:'||p_zone);
      dbms_output.put_line('p_county:'||p_county);
      dbms_output.put_line('p_marketid:'||p_marketid);
      dbms_output.put_line('p_mrkt_area:'||p_mrkt_area);
      dbms_output.put_line('p_sid:'||p_sid);
      dbms_output.put_line('p_technology:'||p_technology);
      dbms_output.put_line('p_frequency1:'||p_frequency1);
      dbms_output.put_line('p_frequency2:'||p_frequency2);
      dbms_output.put_line('p_bta_mkt_number:'||p_bta_mkt_number);
      dbms_output.put_line('p_bta_mkt_name:'||p_bta_mkt_name);
      dbms_output.put_line('p_gsm_tech:'||p_gsm_tech);
      dbms_output.put_line('p_cdma_tech:'||p_cdma_tech);
      dbms_output.put_line('p_mnc:'||p_mnc);
      dbms_output.put_line('==================================================');
    end;

  begin
    display_msg;

    -- ALWAYS VERIFY CARRIER ZONE RETURNS AT LEAST ONE VALUE
    select count(*)
    into v_zone_exists
    from sa.carrierzones
    where  zone = p_zone
    and mrkt_area = p_mrkt_area
    and st = p_state
    and rate_cente = p_ratecenter;

    dbms_output.put_line('v_zone_exists:'||v_zone_exists);

    if v_zone_exists = 0 then
      return 'State, Zone, County, RateCenter,Market ID and Area are not in the Constraint Table. Please check Zone Information. Cannot continue.';
    end if;

    -- VALIDATE ROWID EXISTS. TRYING TO UPDATE W/NON EXISTENT ROW WILL RSLT IN EXCEPTION
    select count(*)
    into   v_entry_exists
    from   sa.npanxx2carrierzones
    where rowid = v_npanxxzoneid;

    dbms_output.put_line('v_npanxxzoneid '||v_npanxxzoneid);
    dbms_output.put_line('v_entry_exists:'||v_entry_exists);

    if v_entry_exists >0 then
      -- UPDATE THE CARRIER ZONE
      update npanxx2carrierzones
      set npa = p_npa,
          nxx = p_nxx,
          carrier_id = p_carrier_id,
          carrier_name = p_carrier_name,
          lead_time = p_lead_time,
          target_level = p_target_level,
          ratecenter = p_ratecenter,
          state = p_state,
          carrier_id_description = p_carrier_id_description,
          zone = p_zone,
          county = p_county,
          marketid = p_marketid,
          mrkt_area = p_mrkt_area,
          sid = p_sid,
          technology = p_technology,
          frequency1 = p_frequency1,
          frequency2 = p_frequency2,
          bta_mkt_number = p_bta_mkt_number,
          bta_mkt_name = p_bta_mkt_name,
          gsm_tech = decode(p_technology,'GSM',p_technology,null),
          cdma_tech = decode(p_technology,'CDMA',p_technology,null),
          mnc = p_mnc
      where rowid = v_npanxxzoneid;
      v_cnt := sql%rowcount;
      v_out_msg :='Carrier NPA/NXX Zone Updated';
    else
      -- INSERT NEW CARRIER ZONE,
      merge into sa.npanxx2carrierzones a
      using (select 1 from dual)
      on   (nvl(a.npa,0) = nvl(p_npa,0)
      and   nvl(a.nxx,0) = nvl(p_nxx,0)
      and   a.state = p_state
      and   a.zone = p_zone
      and   a.ratecenter = p_ratecenter
      and   a.county = p_county
      and   a.marketid = p_marketid
      and   a.carrier_id = p_carrier_id
      and   a.carrier_name = p_carrier_name
      and   a.frequency1 = p_frequency1
      and   a.frequency2 = p_frequency2
      and   a.carrier_id_description = p_carrier_id_description
      and   a.sid = p_sid)
      when not matched then
        insert(npa,nxx,carrier_id,carrier_name,lead_time,target_level,ratecenter,state,
               carrier_id_description,zone,county,marketid,mrkt_area,sid,technology,
               frequency1,frequency2,bta_mkt_number,bta_mkt_name,gsm_tech,cdma_tech,mnc)
        values (p_npa,p_nxx,p_carrier_id,p_carrier_name,p_lead_time,p_target_level,p_ratecenter,p_state,
                p_carrier_id_description,p_zone,p_county,p_marketid,p_mrkt_area,p_sid,p_technology,
                p_frequency1,p_frequency2,p_bta_mkt_number,p_bta_mkt_name,decode(p_technology,'GSM',p_technology,null),decode(p_technology,'CDMA',p_technology,null),p_mnc);
      v_cnt := sql%rowcount;
      if v_cnt > 0 then
        v_out_msg := 'Carrier NPA/NXX Zone Inserted';
      else
        v_out_msg := 'Carrier NPA/NXX Zone Already Exists';
      end if;
    end if;

    return v_out_msg||' ('||v_cnt||')';

  exception
    when others then
      return 'ERROR - '||sqlerrm;
  end add_upd_carr_zone;
--------------------------------------------------------------------------------
  function add_upd_carrier_pref (ip_pref_rowid varchar2,
								 ip_st varchar2,
								 ip_county varchar2,
								 ip_carrier_name varchar2, -- value is now passed from drop down no need to select into
								 ip_carrier_id number,
								 ip_rank number,
								 ip_user_name varchar2)
  return varchar2
  as
   cnt number;
   v_out_msg varchar2(400);
  begin
    if ip_rank is null or
       ip_carrier_id is null or
       ip_carrier_name is null or
       ip_user_name is null then
      return 'Missing criteria cannot continue. St ('||ip_st||') County ('||ip_county||') Rank ('||ip_rank||') Carrier ID ('||ip_carrier_id||') Carrier Name ('||ip_carrier_name||') User Name ('||ip_user_name||')';
    end if;

    if ip_pref_rowid is not null then
      update carrierpref
      set    new_rank = ip_rank,
             carrier_id = ip_carrier_id,
             carrier_name = ip_carrier_name
      where rowid = ip_pref_rowid;
      v_out_msg := ' updated ('||sql%rowcount||')';
    else
      insert into carrierpref
        (st,county,carrier_id,carrier_name,new_rank)
      values
        (ip_st,ip_county,ip_carrier_id,ip_carrier_name,ip_rank);
      v_out_msg := ' inserted ('||sql%rowcount||')';
    end if;

    insert into carrierpref_hist
      (uniqueid,agent,datestamp,action_text,st,county,carrier_id,carrier_name,new_rank)
    values
      (to_char(sysdate,'mmddyyhh24miss'),lower(ip_user_name),sysdate,'RANK_UPDATED',ip_st,ip_county,ip_carrier_id,ip_carrier_name,ip_rank);
    commit;

    return 'Successfully '||v_out_msg;
  exception
    when others then
      return 'Error processing Carrier Preference. '||sqlerrm;
  end add_upd_carrier_pref;
--------------------------------------------------------------------------------
  function change_phone_dealer(p_esn varchar2,
							   p_dealer_id varchar2,
							   p_user varchar2)
  return varchar2
  as
    v_msg varchar2(200) := 'Dealer Changed ';
    v_log_msg_dmp varchar2(200);
    v_user varchar2(30) := lower(p_user);
  begin
    if p_esn is null or p_dealer_id is null or p_user is null then
      return 'ERROR - ESN, Dealer or User information is missing.';
    end if;

    -- UPDATE THE PART INST
    update table_part_inst
    set    part_inst2inv_bin = (select objid
                                from   table_inv_bin
                                where  bin_name = p_dealer_id)
    where  part_serial_no = p_esn;

    if sql%rowcount > 0 then
      toppapp.sp_tu_log(IP_AGENT => v_user,
                        IP_ACTION => 305,
                        IP_ESN => p_esn,
                        IP_MIN => '',
                        IP_SMP => '',
                        IP_REASON => 'Wrong Dealer',
                        IP_STOREID  => '',
                        OP_RESULT => v_log_msg_dmp,
                        op_msg => v_log_msg_dmp);

    else
      return 'No Updated was made.';
    end if;

    commit;

    return v_msg || ' - New Dealer ('||p_dealer_id||')';

  exception
    when others then
      return 'ERROR - While trying to change dealer '||sqlerrm;
  end change_phone_dealer;
--------------------------------------------------------------------------------
  function change_phone_model(p_esn varchar2,
							  p_new_part_number varchar2,
							  p_user varchar2)
  return varchar2
  as
    v_cnt number := 0;
    v_msg varchar2(200) := 'Model Updated';
    n_ml_objid number;
    v_log_msg_dmp varchar2(200);
    v_user varchar2(30) := lower(p_user);
  begin
    -- GET THE MOD LEVEL
    begin
      select a.objid
      into   n_ml_objid
      from   table_mod_level  a,
             table_part_num  b
      where  a.active = 'Active'
      and    b.part_number =  p_new_part_number
      and    b.objid = a.part_info2part_num
      and    rownum < 2;
    exception
      when others then
        return 'ERROR - The Part Number you are trying to assign to this esn not applicable.';
    end;

    -- UPDATE THE PART INST
    update table_part_inst
    set    n_part_inst2part_mod = n_ml_objid
    where  part_serial_no = p_esn
    and    x_part_inst_status <> '52';

    -- UPDATE AND LOG THE CHANGE IF A LINE EXISTS
    if sql%rowcount > 0 then

      update table_part_inst
      set    x_part_inst_status = decode(x_part_inst_status,
                                         '37','11',
                                         '39','12',
                                         x_part_inst_status),
             status2x_code_table = decode(status2x_code_table,
                                          969,958,
                                          1040,959,
                                          status2x_code_table),
             part_to_esn2part_inst  = null
      where  part_to_esn2part_inst = (select objid
                                      from   table_part_inst
                                      where  part_serial_no = p_esn
                                      and    x_part_inst_status <> '52')
      and    x_domain = 'LINES';

      if sql%rowcount > 0 then
        v_msg := 'Updated Model and Removed Line';
      end if;

      toppapp.sp_tu_log(IP_AGENT => v_user,
                        IP_ACTION => 300,
                        IP_ESN => p_esn,
                        IP_MIN => '',
                        IP_SMP => '',
                        IP_REASON => 'Wrong Model',
                        IP_STOREID  => '',
                        OP_RESULT => v_log_msg_dmp,
                        op_msg => v_log_msg_dmp);

    else
      return 'No Update was made.';
    end if;

    commit;

    return v_msg || ' - New Model ('||p_new_part_number||')';

  exception
    when others then
      return 'ERROR - While trying to change phone model '||sqlerrm;
  end change_phone_model;
--------------------------------------------------------------------------------
  function del_carrier_pref (ip_pref_rowid varchar2,
							 ip_st varchar2,
							 ip_county varchar2,
							 ip_carrier_name varchar2, -- value is now passed from drop down no need to select into
							 ip_carrier_id number,
							 ip_rank number,
							 ip_user_name varchar2)
  return varchar2
  as
   v_out_msg varchar2(400);
  begin

    delete from carrierpref
    where rowid = ip_pref_rowid;
    v_out_msg := ' deleted ('||sql%rowcount||')';

    insert into carrierpref_hist
      (uniqueid,agent,datestamp,action_text,st,county,carrier_id,carrier_name,new_rank)
    values
      (to_char(sysdate,'mmddyyhh24miss'),lower(ip_user_name),sysdate,'RANK_DELETED',ip_st,ip_county,ip_carrier_id,ip_carrier_name,ip_rank);
    commit;

    return 'Successfully '||v_out_msg;
  exception
    when others then
      return 'Error deleting Carrier Preference. '||sqlerrm;

  end del_carrier_pref;
--------------------------------------------------------------------------------
  function fix_esn_mismatch (ip_esn varchar2,
                             ip_user varchar2)
  return varchar2
  as
    rslt number;
    msg varchar2(200);
    op_msg varchar2(400) := 'ERROR - FIX ESN MISMATCH: While fixing ESN service, ESN: '||ip_esn;
  begin
    /*** UPDATES MISMATCHED ESN AND/OR MIN STATUS DEPENDING ON TABLE_SITE_PART RECORDS FOUND. ***/
    toppapp.sp_fix_esn_mismatch (
        ip_esn => ip_esn,
        op_msg => op_msg,
        op_result => rslt
    );

    if rslt = 0 then
      op_msg := 'FIX ESN MISMATCH : '||op_msg||', ESN: '||ip_esn;

      toppapp.sp_tu_log (
          ip_agent => ip_user,
          ip_action => 320,
          ip_esn => ip_esn,
          ip_min => '',
          ip_smp => '',
          ip_reason => 'ESN Mismatch',
          ip_storeid  => '',
          op_result => rslt,
          op_msg => msg);
    end if;

    return op_msg;

  exception
    when others then
      return op_msg||sqlerrm;
  end fix_esn_mismatch;
--------------------------------------------------------------------------------
  function insertcard (p_dealerid    in varchar2,
					   p_red_code    in varchar2,
					   p_snp         in varchar2, -- SNP
					   p_part_number in varchar2,
					   p_part_status in varchar2,
					   p_login_name  in varchar2) return varchar2
  as
    p_reason varchar2(200);
    g_print_success_message varchar2(2000);
    op_result        number;
    op_num_units     number;
    op_msg           varchar2(200);
    l_part_status_id varchar2(200);
  begin
    if nvl(p_dealerid,' ') != ' '  and
      nvl(p_red_code,' ') != ' '  and
      nvl(p_part_status,' ') != ' '
    then

      --Derive part status code:
      select x_code_number
      into l_part_status_id
      from table_x_code_table
      where upper(trim(x_code_name)) = upper(trim(p_part_status))
      and rownum <2;

      /*** Inserts cards that are not in table_part_inst, in table_x_posa_card_inv ***/
      toppapp.sp_insert_card  (
             ip_snp               => p_snp,
             ip_red_code          => p_red_code,
             ip_part_number	      => p_part_number,
             ip_site_id           => p_dealerid,
             ip_part_status       => l_part_status_id,
             op_result            => op_result,
             op_msg               => op_msg);

      if op_result = 0
      then
           p_reason := 'Card not in the system';
           toppapp.sp_tu_log (
               ip_agent          => p_login_name,
               ip_action         => 520,
               ip_esn            => p_snp,
               ip_min            => '',
               ip_smp            => p_red_code,
               ip_reason         => p_reason,
               ip_storeid        => '',
               op_result         => op_result,
               op_msg            => op_msg
           );
           g_print_success_message := 'Inserted successfully with dealer: ' ||p_dealerid;
      else
           g_print_success_message := 'ERROR INSERT CARD: '||
                                       'Fatal Error Occurred while inserting card into system '
                                      ||'OP_MSG: '      || op_msg
                                      ||' SNP: '        || p_snp
                                      ||' RED CODE: '   || p_red_code
                                      ||' PART NUMBER: '|| p_part_number
                                      ||' Dealer ID: '  || p_dealerid
                                      ||' PART STATUS: '|| p_part_status;
      end if;

    else
      g_print_success_message := 'ERROR INSERT CARD: Action cannot be performed due some values are missing';
    end if;

    return g_print_success_message;

  exception
    when others then
      return dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
  end insertcard;
--------------------------------------------------------------------------------
  function insertcard2 (p_dealerid in varchar2,
					    p_red_code in varchar2,
					    p_snp in varchar2, -- SNP
					    p_part_number in varchar2,
					    p_part_status in varchar2,
					    p_login_user  in varchar2) return varchar2
  as
       p_reason varchar2(200);
       g_print_success_message varchar2(200);
       op_result     number;
       op_msg        varchar2(200);
       op_num_units  number;
  begin
     if nvl(p_dealerid,' ') != ' '  and
        nvl(p_red_code,' ') != ' '  and
        nvl(p_part_status,' ') != ' '
     then
     /*** Inserts cards that are not in table_part_inst, in table_x_posa_card_inv ***/
          toppapp.sp_insert_card  (
                 ip_snp               => p_snp,
                 ip_red_code          => p_red_code,
                 ip_part_number	 => p_part_number,
                 ip_site_id           => p_dealerid,
                 ip_part_status       => p_part_status,
                 op_result            => op_result,
                 op_msg               => op_msg);

           if op_result = 0
           then
                 p_reason := 'Card not in the system';
                 toppapp.sp_tu_log (
                     ip_agent          => p_login_user,
                     ip_action         => 520,
                     ip_esn            => p_snp,
                     ip_min            => '',
                     ip_smp            => p_red_code,
                     ip_reason         => p_reason,
                     ip_storeid        => '',
                     op_result         => op_result,
                     op_msg            => op_msg
                 );
                 g_print_success_message := 'Inserted successfully with dealer: '
                                                           ||p_dealerid;
           else
                 g_print_success_message := 'ERROR INSERT CARD: '||
                                             'Fatal Error Occurred while inserting card into system '
                                            ||op_msg ||'  SNP: '||p_snp||' RED CODE: '||p_red_code
                                            ||' PART NUMBER: '||p_part_number
                                            ||' SITE ID: '||p_dealerid||' PART STATUS: '||p_part_status;
           end if;

     else
        g_print_success_message := 'ERROR INSERT CARD: Action cannot be performed due some values are missing';
     end if;

     return g_print_success_message;
  exception
     when others then
        return dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
  end insertcard2;
--------------------------------------------------------------------------------
  function mark_card_invalid (p_reason in varchar2,
							  p_card_no in varchar2,
							  p_snp     in varchar2,
							  p_login_name in varchar2)
  return varchar2
  as
    op_result   number;
    op_msg      varchar2 (200);
    g_print_success_message varchar2(200) := 'Error marking card invalid';
  begin
    if     length (trim (p_reason)) > 0
       and length (trim (p_card_no)) > 0
       and length (trim (p_snp)) > 0
    then
      sa.apex_toss_util_pkg.sp_mark_card_invalid (ip_snp => p_snp, op_result => op_result, op_msg => op_msg);

      if op_result = 0
      then
         toppapp.sp_tu_log (ip_agent        => p_login_name
                           ,ip_action       => 500
                           ,ip_esn          => ''
                           ,ip_min          => ''
                           ,ip_smp          => p_snp
                           ,ip_reason       => p_reason
                           ,ip_storeid      => ''
                           ,op_result       => op_result
                           ,op_msg          => op_msg
                           );
         g_print_success_message := 'Card Update Complete, Application will now refresh Card Info.';
      else
         g_print_success_message := 'ERROR MARK INVALID : Error occurred while updating card SNP: ' || p_snp
                                          || ' SA.APEX_TOSS_UTIL_PKG.SP_MARK_CARD_INVALID  op_msg= '|| op_msg;
      end if;

    else
      g_print_success_message := 'ERROR MARK INVALID : Action cannot be performed.';
    end if;
    return g_print_success_message;

  exception
     when others then
        return dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
  end mark_card_invalid;
--------------------------------------------------------------------------------
-- OVERLOADED
--------------------------------------------------------------------------------
  function mark_card_invalid (p_reason in varchar2,
                p_esn in varchar2,
							  p_card_no in varchar2,
							  p_snp     in varchar2,
							  p_login_name in varchar2)
  return varchar2
  as
    op_result   number;
    op_msg      varchar2 (200);
    g_print_success_message varchar2(200) := 'Error marking card invalid';
  begin

    select count(*) -- THE ESN MUST EXIST
    into   op_result
    from   table_part_inst p
    where  p.part_serial_no = p_esn;

    if op_result < 1 then
      return  'ESN does not exist';
    else
      op_result := null;
    end if;

    if     length (trim (p_reason)) > 0
       and length (trim (p_card_no)) > 0
       and length (trim (p_snp)) > 0
    then
      sa.apex_toss_util_pkg.sp_mark_card_invalid (ip_snp => p_snp, ip_esn => p_esn, op_result => op_result, op_msg => op_msg);

      if op_result = 0
      then
         toppapp.sp_tu_log (ip_agent        => p_login_name
                           ,ip_action       => 500
                           ,ip_esn          => ''
                           ,ip_min          => ''
                           ,ip_smp          => p_snp
                           ,ip_reason       => p_reason
                           ,ip_storeid      => ''
                           ,op_result       => op_result
                           ,op_msg          => op_msg
                           );
         g_print_success_message := 'Card Update Complete, Application will now refresh Card Info.';
      else
         g_print_success_message := 'ERROR MARK INVALID : Error occurred while updating card SNP: ' || p_snp
                                          || ', '|| op_msg;
      end if;

    else
      g_print_success_message := 'ERROR MARK INVALID : Action cannot be performed.';
    end if;
    return g_print_success_message;

  exception
     when others then
        return dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
  end mark_card_invalid;
--------------------------------------------------------------------------------
  function min_entry_batch (ip_user varchar2,
						    ip_file varchar2,
						    ip_batch_type varchar2)  -- 1 = INSERT, 2 = DELETE
  return varchar2
  as
  ---------------------------------------------------------------------------------------
    new_status varchar2(30);
    v_out_msg varchar2(1000);
    v_action  number;
    v_min        varchar2(30);
    v_carrier_id varchar2(30);
    v_msid       varchar2(30);
    v_file_name  varchar2(30) := substr(ip_file,1,30);
    v_file_type  varchar2(30);
    v_exp_date   varchar2(30);

    op_msid         varchar2(30);
    op_carrier_id   number;
    op_carrier_name varchar2(200);
    op_result       number;
    op_msg          varchar2(200);

    f_counter number:=0; -- Failures
    c_counter number:=0; -- Successes

    n_dtl_action number;

    cursor batch_cur is
      select rowid,min,msid,status,carrier_id,rec_type
      from   sa.x_luts_batch_file_temp
      where  status   = 'PENDING'
      and    rec_type in ('INSERT','DELETE')
      and    app_user = ip_user;

    batch_rec batch_cur%rowtype;

  begin

    dbms_output.put_line('ip_batch_type:'||ip_batch_type);

    for batch_rec in batch_cur
    loop
      v_min         := substr(batch_rec.min,1,10);
      v_carrier_id  := batch_rec.carrier_id;
      v_msid        := substr(batch_rec.msid,1,10);
      v_file_type   := '1';
      v_exp_date    := 'NA';

      if batch_rec.rec_type = 'INSERT' then
        -- INSERTING LINES
        begin
          n_dtl_action := 1;
          -- THIS PACKAGE CONTAINS A ROLLBACK ON EXCEPTION
          TOPPAPP.LINE_INSERT_PKG.LINE_VALIDATION
            (v_msid,
             v_min,
             v_carrier_id,
             v_file_name,
             v_file_type,
             v_exp_date,
             op_carrier_id,
             op_carrier_name,
             op_result,
             op_msg);
        end;
      else
        -- DELETING LINES
        begin
          n_dtl_action := 2;
          -- THIS PACKAGE CONTAINS A ROLLBACK ON EXCEPTION
          TOPPAPP.LINE_INSERT_PKG.DELETE_LINE
            (v_min,
             op_msid,
             op_carrier_id,
             op_carrier_name,
             op_result,
             op_msg);
        end;
      end if;

      update x_luts_batch_file_temp
      set status = to_char(op_result)||'-'||op_msg
      where rowid = batch_rec.rowid;

      if OP_RESULT = 1 then
        c_counter:=c_counter+1;
        -- THIS PACKAGE CONTAINS A ROLLBACK ON EXCEPTION
        TOPPAPP.LINE_INSERT_PKG.INSERT_LUTS_LOG_DETAIL
            (n_dtl_action,
             ip_user,
             v_file_name,
             v_min,
             v_msid,
             '',
             op_carrier_id,
             op_carrier_name,
             'COMPLETED',
             op_result,
             op_msg,
             op_result);
      else
        f_counter:=f_counter+1;
      end if;

      commit;
    end loop;

    -- THIS PACKAGE CONTAINS A ROLLBACK ON EXCEPTION
    if ip_batch_type ='INSERT' then
      v_action:=1;
    else
      v_action:=2;
    end if;

    TOPPAPP.LINE_INSERT_PKG.INSERT_LUTS_LOG
      (v_action,
       ip_user,
       v_file_name,
       c_counter,
       f_counter,
       op_result);

    return  v_out_msg||'Total Processed: '||c_counter||' Successful / '||f_counter||' Failed';

  exception
    when others then
      if instr(sqlerrm,'ORA-01403')>0 then
        return ' Check the csv has the correct columns';
      else
        return ' Failed - ' || ip_file|| ' ' ||sqlerrm;
      end if;
  end min_entry_batch;
--------------------------------------------------------------------------------
  function reset_posa (p_reason       in   varchar2,
					   p_card_no      in   varchar2,
					   p_storeid      in   varchar2,
					   p_esn          in   varchar2,
					   p_snp          in   varchar2,
					   p_login_name   in   varchar2)
  return varchar2
  as
    p_action                  VARCHAR2 (200)  := 'Reset_POSA';
    op_msg                    VARCHAR2 (200);
    op_result                 NUMBER;
    op_num_units              NUMBER;
    found_rec                 NUMBER;
    g_print_success_message   VARCHAR2 (4000) := 'ERROR';
	v_action				  NUMBER;

  begin
    for i in (
              select count(*) cnt
              from security_access
              where permission_name = 'TOSS_RESET_POSA'
              and user_name = upper(p_login_name)
              )
    loop
      if i.cnt = '0' then
        return 'REQUIRED PERMISSION IS NOT GRANTED';
      end if;
    end loop;

     /*** ESN Validation ***/
     if length (trim (p_esn)) > 0
     then
        select count (*)
          into found_rec
          from table_part_inst
         where part_serial_no = to_char(p_esn)
           and x_domain = 'PHONES';

        if found_rec = 0
        then
           g_print_success_message := 'ERROR RESET POSA: ESN ' || p_esn || ' was not found';
        end if;
     else
        g_print_success_message := 'ERROR RESET POSA: ESN must be entered';
     end if;

     if     p_action = 'Reset_POSA'
        and found_rec != 0
     then
        if     length (trim (p_reason)) > 0
           and length (trim (p_card_no)) > 0
           and length (trim (p_storeid)) > 0
           and length (trim (p_snp)) > 0
        then
           /*** User SA, Package POSA, procedure MAKE_CARD_REDEEMABLE ***/
           /*** to change the status of an Inactive (45) card to Active/redeemable (42)  ***/
           sa.posa.make_card_redeemable (ip_smp_num           => p_snp
                                        ,ip_date              => ''
                                        ,ip_time              => ''
                                        ,ip_trans_id          => ''
                                        ,ip_trans_type        => ''
                                        ,ip_merchant_id       => ''
                                        ,ip_store_detail      => ''
                                        ,op_num_units         => op_num_units
                                        ,op_result            => op_result
                                        ,ip_sourcesystem      => 'TOSSUTILITY'
                                        );

           if op_result = 0  then
              v_action:=510;
              g_print_success_message := 'RESET POSA Card Update Complete, Application will now refresh Card Info.';   -- SNP '||p_SNP;
           else
              v_action:=999;
              g_print_success_message := 'ERROR RESET POSA : Error occurred while updating card SNP: '
                                                   || p_snp
                                                   || ' SA.POSA.MAKE_CARD_REDEEMABLE op_result= '
                                                   || op_result;

           end if;

              toppapp.sp_tu_log (ip_agent        => p_login_name
                                ,ip_action       => v_action
                                ,ip_esn          => p_esn
                                ,ip_min          => ''
                                ,ip_smp          => p_snp
                                ,ip_reason       => p_reason
                                ,ip_storeid      => p_storeid
                                ,op_result       => op_result
                                ,op_msg          => op_msg
                                );
           end if;
        else
           g_print_success_message := 'ERROR RESET POSA : Action cannot be performed due all values must be entered';
        end if;

     return g_print_success_message;
  exception
     when others then
        return 'Error calling reset_posa: ' || dbms_utility.format_error_backtrace;
  end reset_posa;
--------------------------------------------------------------------------------
  function sui_ttoff (ip_esn varchar2,
                      ip_min varchar2)
  return varchar2
  -- TTOFF Request for ADF SUI
  as
    cursor c1 is
    select po.x_policy_name
    from W3CI.table_x_throttling_cache ca, W3CI.table_x_throttling_policy po
    where ca.x_esn = ip_esn
    and ca.x_min = ip_min
    and ca.x_status = 'A'
    and ca.x_policy_id = po.objid;

    r1 c1%rowtype;
    P_ERROR_CODE number;
    P_ERROR_MESSAGE varchar2(200);
    v_out_msg varchar2(100) := 'Successful';

  begin
     open c1;
     fetch c1 into r1;
     if c1%found then
        close c1;
        v_out_msg:='Customer is currently throttle. Cannot process your request';
     else
        close c1;
        W3CI.THROTTLING.SP_EXPIRE_CACHE(
          P_MIN => ip_min,
          P_ESN => ip_esn,
          P_ERROR_CODE => P_ERROR_CODE,
          P_ERROR_MESSAGE => P_ERROR_MESSAGE
        );
        IF p_error_CODE <> 0 THEN
            v_out_msg:=P_ERROR_MESSAGE;
        END IF;
     end if;
     return v_out_msg;

  exception
    when others then
      return 'ERROR - '||sqlerrm;
  end sui_ttoff;
--------------------------------------------------------------------------------
  function sui_tton (ip_esn varchar2,
                     ip_min varchar2)

  return varchar2
  -- TTON Request for ADF SUI
  as
    cursor c1 is
    select po.x_policy_name
    from W3CI.table_x_throttling_cache ca, W3CI.table_x_throttling_policy po
    where ca.x_esn = ip_esn
    and ca.x_min = ip_min
    and ca.x_status = 'A'
    and ca.x_policy_id = po.objid;

    r1 c1%rowtype;
    v_out_msg varchar2(200) := 'Successful';
    P_ERROR_CODE NUMBER;
    P_ERROR_MESSAGE varchar2(200);

  begin
     open c1;
     fetch c1 into r1;
     if c1%found then
        close c1;
        W3CI.THROTTLING.SP_THROTTLING_VALVE(
          P_MIN => ip_min,
          P_ESN => ip_esn,
          P_POLICY_NAME => r1.x_policy_name,
          P_CREATION_DATE => sysdate,
          P_TRANSACTION_NUM => null,
          P_ERROR_CODE => P_ERROR_CODE,
          P_ERROR_MESSAGE => P_ERROR_MESSAGE
        );

        if p_error_code <> 0 then
           v_out_msg:=P_ERROR_MESSAGE;
        end if;

     else
        close c1;
        v_out_msg:='Customer is not currently throttled. Please choose FIX DATA if customer is having issues with Data Services';
     end if;

    return v_out_msg;

  exception
    when others then
      return 'ERROR - '||sqlerrm;
  end sui_tton;
--------------------------------------------------------------------------------
  function transfer_promo (p_part_serial_no varchar2,
                           p_new_part_serial_no varchar2)
  return varchar2
  as
    n_new_pi_objid number;

    cursor c1 is
      select g.*
      from   table_part_inst pi,
             table_x_group2esn g
      where  pi.part_serial_no = p_part_serial_no
      and    pi.objid = g.groupesn2part_inst
      and    g.x_end_date > sysdate;

  begin
    if p_new_part_serial_no is null then
      return 'ERROR - A serial number is required.';
    end if;

    if p_part_serial_no = p_new_part_serial_no then
      return 'ERROR - Cannot transfer promo to same serial.';
    end if;

    begin
      select objid
      into   n_new_pi_objid
      from   table_part_inst
      where  part_serial_no = p_new_part_serial_no
      and    x_domain = 'PHONES';
    exception
      when others then
        return 'ERROR - New Part Serial No ('||p_new_part_serial_no||') does not exist.';
    end;

    for r1 in c1 loop
      insert into table_x_group2esn
        (objid,
         x_annual_plan,
         groupesn2part_inst,
         groupesn2x_promo_group,
         x_end_date,
         x_start_date,
         groupesn2x_promotion)
      values
        (sa.seq('x_group2esn'),
         r1.x_annual_plan,
         n_new_pi_objid,
         r1.groupesn2x_promo_group,
         r1.x_end_date,r1.
         x_start_date,
         r1.groupesn2x_promotion);

      update table_x_group2esn
      set x_end_date = sysdate
      where objid = r1.objid;

    end loop;
    commit;

    return 'Transfered promo from '||p_part_serial_no||' to '||p_new_part_serial_no;

  end transfer_promo;
--------------------------------------------------------------------------------
  function unreserve_reset_voided (p_action  in varchar2,
                                   p_reason  in varchar2,
                                   p_card_no in varchar2,
                                   p_snp     in varchar2,
                                   p_login_name in varchar2)
  return varchar2
  as
    op_result number;
    op_msg    varchar2(200);
    tag       number;
    g_print_success_message varchar2(2000) := 'Error';
	v_brm_count number:=0;

  begin

     -- WFM SATRT
     select count('1')
	 into v_brm_count
	 from sa.x_part_inst_ext
     where smp = p_snp;

	 if v_brm_count > 0 then
	    g_print_success_message := 'ERROR RESET VOIDED: Temporarily Disabled for WFM';
		return g_print_success_message;
	 end if;
	 --WFM END

     if p_action = 'Reset_Voided'  or
        p_action = 'Un-Reserve' or
        p_action = 'Reset'
     then
        tag := case p_action when 'Un-Reserve' then 410
                                else 400
               end;
        if length(trim(p_reason)) > 0 and
           length(trim(p_card_no)) > 0 and
           length(trim(p_snp)) > 0
        then
              sa.apex_toss_util_pkg.sp_resetvoided_unreserve (
                    ip_snp => p_snp,
                    op_result  => op_result,
                    op_msg => op_msg);

              if op_result = 0
              then

                  toppapp.sp_tu_log (
                      ip_agent => p_login_name,
                      ip_action => tag,
                      ip_esn => '',
                      ip_min => '',
                      ip_smp => p_snp,
                      ip_reason => p_reason,
                      ip_storeid  => '',
                      op_result => op_result,
                      op_msg => op_msg
                      );
                 g_print_success_message := 'Card Update Complete, Application will now refresh Card Info.';
              else
                 g_print_success_message :=
                 'ERROR RESET VOIDED : Error occurred while updating card SNP: '||p_snp                 ||' SA.APEX_TOSS_UTIL_PKG.SP_RESETVOIDED_UNRESERVE   op_msg= '||op_msg;
              end if;
        else
           g_print_success_message := 'ERROR RESET VOIDED: Action cannot be performed.';
        end if;
     else
        g_print_success_message := 'ERROR RESET VOIDED: Invalid Action: ' || p_action;
     end if;
     return g_print_success_message;

  exception
    when others then
      return dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
  end unreserve_reset_voided;
--------------------------------------------------------------------------------
  function upd_carrier_zones (ip_from_state varchar2,
                              ip_from_zone varchar2,
                              ip_from_carr_name varchar2,
                              ip_from_county varchar2,
                              ip_from_rate_center varchar2,
                              ip_new_state varchar2,
                              ip_new_zone varchar2,
                              ip_existing_carr_name varchar2)

  return varchar2
  as
    --------------------------------------------------------------------------------
    -- ORIGINAL CODE DOES NOT DO NEW INSERTS, IT'S GOAL IS SIMPLY TO MOVE CARRIERS BETWEEN ZONES.
    -- IF CARRIER NAME IS SUPPLIED THE STATE AND ZONE IS ASSUMED TO BE EXISTING
    -- IF MOVING BETWEEEN EXISTING ZONES, THEY MUST SHARE THE SAME CARRIERS, IF NOT REJECT
    -- IF RATE CENTER IS NULL, UPDATE ALL RATE CENTERS
    --------------------------------------------------------------------------------
      cnt number := 0;

    procedure print_info
    as
     v_m varchar2(1000);
    begin
      if ip_existing_carr_name is not null then
        v_m := 'MOVE TO EXISTING ZONE';
      else
        v_m := 'MOVE TO NEW ZONE';
      end if;
        v_m := v_m||chr(10)||'ip_new_zone:'||ip_new_zone||chr(10)||'ip_new_state:'||ip_new_state||chr(10)||
                             'ip_existing_carr_name:'||ip_existing_carr_name||chr(10)||'ip_from_zone:'||ip_from_zone||chr(10)||'ip_from_state:'||ip_from_state||chr(10)||
                             'ip_from_carr_name:'||ip_from_carr_name||chr(10)||'ip_from_county:'||ip_from_county||chr(10);

      if ip_from_rate_center is null then
        v_m := v_m||'ip_from_rate_center:'||'ALL RATE CENTERS';
      else
        v_m := v_m||'ip_from_rate_center:'||ip_from_rate_center;
      end if;
      dbms_output.put_line(v_m);
    end;
    --------------------------------------------------------------------------------
  begin
    -- print_info;
    if ip_existing_carr_name is not null and (ip_from_carr_name != ip_existing_carr_name) then
      return 'ERROR - Carriers must equal in order to move to an existing zone';
    end if;

    update sa.carrierzones
    set zone = ip_new_zone,
        st   = ip_new_state
    where  zone         = ip_from_zone
    and    st           = ip_from_state
    and    carrier_name = ip_from_carr_name
    and    county       = ip_from_county
    -- and    decode(ip_from_rate_center,null,'0','All','0',rate_cente)   = nvl(ip_from_rate_center,'0');
    -- CHANGED THIS LINE 1.8.13
    and    decode(ip_from_rate_center,null,'0','All','0',rate_cente)   = decode(ip_from_rate_center,null,'0','All','0',ip_from_rate_center);

    cnt := sql%rowcount;
    commit;
    return chr(10)||'Moved ('||cnt||') zones successfully.';

  exception
    when others then
      return 'ERROR - Unable to update the constraint table. '||sqlerrm;
  end upd_carrier_zones;
--------------------------------------------------------------------------------
  function reserve_min2esn (p_min                   in   varchar2,
                            p_esn                   in   varchar2,
                            p_port_in_min_reserve   in   number,  --yes --no passed as (1,0)
                            p_reserve_reason        in   long,
                            p_login_name            in   varchar2) return varchar2
  as
     g_print_success_message   varchar2 (200)   := '';

     cursor pi_cur (
        ip_serial   varchar2
       ,ip_domain   varchar2
     )
     is
        select *
          from table_part_inst
         where part_serial_no = ip_serial
           and x_domain = ip_domain;

     min_rec                   pi_cur%rowtype;
     esn_rec                   pi_cur%rowtype;
     user_objid                number;
     pi_result                 number;
     ip_action                 number;
     op_result                 number;
     op_msg                    varchar2 (200);
  begin
    select objid
    into user_objid
    from table_user
    where upper(s_login_name) = upper(p_login_name);

    open pi_cur (p_min, 'LINES');

    fetch pi_cur
    into min_rec;

    if pi_cur%notfound
    then
      close pi_cur;
      return 'No record found on MIN';
    end if;

    close pi_cur;

    if min_rec.x_part_inst_status = '13'
    then
      return 'This MIN is active';
    else
      open pi_cur (p_esn, 'PHONES');

      fetch pi_cur
      into esn_rec;

      if pi_cur%notfound
      then
         close pi_cur;
         return 'No record found on ESN';
      end if;

      close pi_cur;

      if esn_rec.x_part_inst_status = '52'
      then
         return 'This ESN is active';
      else
        --Unreserve any line
        update table_part_inst
          set part_to_esn2part_inst = null
             ,x_part_inst_status = decode (x_part_inst_status, '39', '12', '37', '11')
             ,status2x_code_table = decode (x_part_inst_status, '39', 959, '37', 958)
        where part_to_esn2part_inst = esn_rec.objid
		and x_domain = 'LINES';

        if p_port_in_min_reserve = 1
        then
          update table_part_inst
             set x_part_inst_status = '73'
                ,status2x_code_table = 268441728
                ,part_to_esn2part_inst = esn_rec.objid
           where objid = min_rec.objid;

          g_print_success_message := 'Port-In MIN Reserve completed';
          --Log Transaction
          sa.insert_pi_hist_prc (ip_user_objid      => user_objid
                                ,ip_min             => p_min
                                ,ip_old_npa         => substr (p_min, 1, 3)
                                ,ip_old_nxx         => substr (p_min, 4, 3)
                                ,ip_old_ext         => substr (p_min, 7, 4)
                                ,ip_reason          => 'PORT-IN RESERVED'
                                ,ip_out_val         => pi_result
                                );
          ip_action := 225;                                                           --Port-In-Min Reserve Min To Esn
          toppapp.sp_tu_log (ip_agent        => p_login_name
                            ,ip_action       => ip_action
                            ,ip_esn          => p_esn
                            ,ip_min          => p_min
                            ,ip_smp          => null
                            ,ip_reason       => p_reserve_reason
                            ,ip_storeid      => null
                            ,op_result       => op_result
                            ,op_msg          => op_msg
                            );
        else
          update table_part_inst
             set x_part_inst_status = decode (x_part_inst_status, '11', '37', '12', '39', '39')
                ,status2x_code_table = decode (x_part_inst_status, '11', 969, '12', 1040, 1040)
                ,part_to_esn2part_inst = esn_rec.objid
           where objid = min_rec.objid;

          g_print_success_message := 'Reserve completed';
          --Log Transaction
          sa.insert_pi_hist_prc (ip_user_objid      => user_objid
                                ,ip_min             => p_min
                                ,ip_old_npa         => substr (p_min, 1, 3)
                                ,ip_old_nxx         => substr (p_min, 4, 3)
                                ,ip_old_ext         => substr (p_min, 7, 4)
                                ,ip_reason          => 'RESERVED'
                                ,ip_out_val         => pi_result
                                );
          ip_action := 220;                                                                       --Reserve MIN to ESN
          toppapp.sp_tu_log (ip_agent        => p_login_name
                            ,ip_action       => ip_action
                            ,ip_esn          => p_esn
                            ,ip_min          => p_min
                            ,ip_smp          => null
                            ,ip_reason       => p_reserve_reason
                            ,ip_storeid      => null
                            ,op_result       => op_result
                            ,op_msg          => op_msg
                            );
        end if;
      end if;
    end if;

    return g_print_success_message;

  exception
    when others then
      return  dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
  end reserve_min2esn;
--------------------------------------------------------------------------------
function get_msl (IP_ESN varchar2)
return varchar2
as
  msl varchar2(30);

  cursor c1 is
  select 'MSL: '||X_MSL_CODE code
  from   sa.TABLE_X_BYOP
  where  x_esn = ip_esn
  union
  select 'SPC: '||spc_code code
  from sa.x_spc_code
  where esn = ip_esn;

  r1 c1%rowtype;

begin

  open c1;
  fetch c1 into r1;

  if c1%notfound then
     close c1;
     msl := 'No MSL/SPC code found.';
  else
     close c1;
     msl := r1.code;
  end if;

  return msl;
  exception
     when others then
      return SQLCODE||' '||SQLERRM;

end get_msl;
-------------------------------------------------------------------------------
FUNCTION CHANGE_OWNERSHIP (p_esn VARCHAR2,
                           p_action_item_id VARCHAR2)
RETURN VARCHAR2 AS

   v_template varchar2(10):='SPRINT';
   v_app_system varchar2(10):='TAS_CO';
   --v_order_type varchar2(10):='VD';
   v_order_type varchar2(10):='POC'; --CR31310
   v_status varchar2(1):='Q';
   v_message varchar2(30):='ESN NOT FOUND';
   v_transaction_id varchar2(30);

   cursor c1 is
   select part_serial_no
   from sa.table_part_inst
   where part_serial_no = p_esn
   and x_domain= 'PHONES';

BEGIN

IF p_esn IS NOT NULL AND p_action_item_id IS NOT NULL THEN

  SELECT gw1.trans_id_seq.nextval + (POWER(2 ,28))
  INTO v_transaction_id
  FROM dual;
  FOR r1 IN c1
  LOOP
    INSERT
    INTO gw1.ig_transaction
      (
        template,
        creation_date,
        update_date,
        action_item_id,
        application_system,
        order_type,
        esn,
        esn_hex,
        status,
        transaction_id
      )
      VALUES
      (
        v_template,
        sysdate,
        sysdate,
        p_action_item_id,
        v_app_system,
        v_order_type,
        p_esn,
        (SELECT MEIDDECTOHEX(p_esn) FROM dual
        ),
        v_status,
        v_transaction_id
      );
    v_message := 'SUCCESS';
  END LOOP;

  COMMIT;
END IF;
RETURN v_message;
EXCEPTION
WHEN OTHERS THEN
  RETURN sqlerrm;
END CHANGE_OWNERSHIP;
---------------------------------------------------------------------------

--This API is to check if both the SIMs passed belongs to same carrier or different carrier.
FUNCTION check_cross_carrier(
    p_sim1 IN VARCHAR2,
    p_sim2 IN VARCHAR2)
  RETURN VARCHAR2
AS
  CURSOR sim_pn(ip_sim VARCHAR2)
  IS
    SELECT pn.PART_NUMBER
    FROM table_x_sim_inv si,
      sa.TABLE_MOD_LEVEL ml,
      sa.TABLE_PART_NUM pn
    WHERE si.X_SIM_INV2PART_MOD=ml.OBJID
    AND ml.PART_INFO2PART_NUM  =pn.OBJID
    AND pn.S_DOMAIN            = 'SIM CARDS'
    AND si.X_SIM_SERIAL_NO     = ip_sim;
  sim1_rec sim_pn%rowtype;
  sim2_rec sim_pn%rowtype;
  carrier_match_cnt NUMBER;
BEGIN

  -- This part fetches the part number for SIM1
  IF p_sim1 IS NULL THEN
    RETURN '100'; --SIM should be provided
  ELSE
    OPEN sim_pn (p_sim1);
    FETCH sim_pn INTO sim1_rec;
    IF sim_pn%notfound THEN
      CLOSE sim_pn;
      RETURN '101'; --Invalid SIM
    END IF;
    CLOSE sim_pn;
  END IF;

  IF p_sim2 IS NULL THEN
    RETURN '102'; --target SIM should be provided
  ELSE
    -- This part fetches the part number for SIM2
    OPEN sim_pn (p_sim2);
    FETCH sim_pn INTO sim2_rec;
    IF sim_pn%notfound THEN
      CLOSE sim_pn;
      RETURN '103'; --Invalid SIM
    END IF;
    CLOSE sim_pn;
  END IF;

  --This part checks the matching carrier name records in table carriersimpref. If count of matches is more than 0, then it is determined as same carrier.
  SELECT COUNT(*)
  INTO carrier_match_cnt
  FROM carriersimpref sf1,
    carriersimpref sf2
  WHERE sf1.sim_profile = sim1_rec.PART_NUMBER
  AND sf2.sim_profile   = sim2_rec.PART_NUMBER
  AND sf1.CARRIER_NAME  = sf2.CARRIER_NAME ;

  IF(carrier_match_cnt  > 0) THEN
    RETURN 'NO';
  ELSE
    RETURN 'YES';
  END IF;

END check_cross_carrier;

-- Return Status Code for give IG Action Item Status
FUNCTION get_action_item_status_code(
    ip_action_item_status VARCHAR2)
  RETURN VARCHAR2
IS
  v_action_item_status VARCHAR2(2000);
BEGIN
  SELECT x_text
  INTO v_action_item_status
  FROM sa.table_x_code_table code
  WHERE code.x_code_number = ip_action_item_status
  AND code.x_code_type     = 'IGAIS';

  RETURN v_action_item_status;
EXCEPTION
WHEN OTHERS THEN
  RETURN ip_action_item_status;
END get_action_item_status_code;

FUNCTION get_ig_status_error_message(
    ip_status_message VARCHAR2)
  RETURN VARCHAR2
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
  v_status_error_message VARCHAR2(2000);

  CURSOR c1
  IS
    SELECT x_default_error_msg
    FROM sa.ig_status_error_message
    WHERE ip_status_message LIKE X_ERROR_CRITERIA;
  r1 c1%rowtype;

BEGIN

	IF ip_status_message is not null THEN
		OPEN c1;
		FETCH c1 INTO r1;
		IF c1%found AND r1.x_default_error_msg IS NOT NULL THEN
			CLOSE c1;
			v_status_error_message:= r1.x_default_error_msg;
		ELSE
			CLOSE c1;
			v_status_error_message := ip_status_message;
			-- INSERT a new criteria with status message. Later need to update to generic criteria
			INSERT
			INTO sa.IG_STATUS_ERROR_MESSAGE
				(
					OBJID,
					X_ERROR_CODE,
					X_ERROR_GROUP,
					X_ERROR_CRITERIA,
					X_DEFAULT_ERROR_MSG
				)
				VALUES
				(
					sa.sequ_ig_status_error_message.nextval,
					NULL,
					NULL,
					ip_status_message,
					NULL
				);

			COMMIT;
		END IF;
	END IF;
  RETURN v_status_error_message;
EXCEPTION
WHEN OTHERS THEN
	--dbms_output.put_line('Error code ' || SQLCODE || ': ' || SQLERRM);
  RETURN ip_status_message;
END get_ig_status_error_message;

end adfcrm_carrier;
/