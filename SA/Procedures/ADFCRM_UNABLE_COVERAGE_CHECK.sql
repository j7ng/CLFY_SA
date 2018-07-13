CREATE OR REPLACE PROCEDURE sa."ADFCRM_UNABLE_COVERAGE_CHECK" (
    ip_esn IN VARCHAR2,
    ip_login_name IN VARCHAR2,
    op_curr_install_date out varchar2,
    op_curr_zip_code out varchar2,
    op_curr_carrier out varchar2,
    op_prev_carrier out varchar2,
    op_curr_carrrier_coverage out varchar2,
    op_upgraded out varchar2,
    op_prev_carrier_coverage out varchar2,
    op_min_changed_area out varchar2,
    op_solution_reason out varchar2,
    op_recomended_output OUT VARCHAR2,
    op_alternative_output OUT VARCHAR2,
    op_error_num OUT VARCHAR2,
    op_error_msg OUT VARCHAR2)
IS

cursor esn_part_num_cur (ip_esn varchar2) is
Select Pn.Part_Number,Pn.X_Technology,Pn.X_Dll,Pc.Name Part_Class,Bo.Org_Id
From Table_Part_Num pn, table_part_class pc, table_bus_org bo
Where Pn.Objid In (Select Part_Info2part_Num
From Table_Mod_Level
Where Objid In (Select n_part_inst2part_mod From Table_Part_Inst
where part_serial_no = ip_esn and x_domain = 'PHONES'))
and pn.part_num2part_class = pc.objid
and pn.part_num2bus_org = bo.objid;

esn_part_num_rec esn_part_num_cur%rowtype;

cursor current_service_cur (ip_esn varchar2) is
select sp.install_date, (sysdate - sp.install_date) days_active,sp.x_zipcode,sp.x_min, nvl(p.x_queue_name,p.x_parent_name) current_carrier
from table_site_part sp, table_x_parent p, table_x_carrier_group cg, table_x_carrier c, table_part_inst pi
where sp.x_service_id = ip_esn
and pi.part_serial_no = sp.x_min
and pi.x_domain = 'LINES'
and pi.part_inst2carrier_mkt = c.objid
and c.carrier2carrier_group = cg.objid
and cg.x_carrier_group2x_parent = p.objid
and sp.part_status in ('Active','CarrierPending');

current_service_rec current_service_cur%rowtype;

cursor previous_carrier_cur (ip_min varchar2, ip_current_carrier varchar2) is
select sp.install_date,sp.x_zipcode,sp.x_min, nvl(p.x_queue_name,p.x_parent_name) previous_carrier
from table_site_part sp, table_x_parent p, table_x_carrier_group cg, table_x_carrier c, table_x_pi_hist pi
where sp.x_min = ip_min
and  pi.x_part_serial_no = sp.x_min
and pi.x_domain = 'LINES'
and pi.x_change_date <= sp.SERVICE_END_DT
and pi.x_change_date >= sysdate -90
and pi.x_pi_hist2carrier_mkt = c.objid
and c.carrier2carrier_group = cg.objid
and cg.x_carrier_group2x_parent = p.objid
and sp.part_status = 'Inactive'
and nvl(p.x_queue_name,p.x_parent_name) <> ip_current_carrier
and sp.SERVICE_END_DT >= sysdate -90;

previous_carrier_rec previous_carrier_cur%rowtype;

   CURSOR cur_avail_carriers( ip_zip VARCHAR2,
                              ip_dll NUMBER,
                              ip_esn VARCHAR2) IS
     select distinct
           ca.x_carrier_id
           ,pa.x_parent_id
           ,pa.x_parent_name
           ,pa.x_queue_name
       from ( select DISTINCT b.carrier_id
                           ,b.frequency1
                           ,b.frequency2
                           ,a.sim_profile
                           ,b.cdma_tech
                           ,b.tdma_tech
                           ,b.gsm_tech
                           ,TO_NUMBER(cp.new_rank) new_rank
                           ,TO_NUMBER(a.rank) RANK
              FROM carrierpref cp,
                   npanxx2carrierzones b,
                   (SELECT DISTINCT a.ZONE,
                                    a.st,
                                    s.sim_profile,
                                    a.county,
                                    s.min_dll_exch,
                                    s.max_dll_exch,
                                    s.rank
                      FROM carrierzones a,
                           carriersimpref s
                     WHERE a.zip = ip_zip
                       and a.CARRIER_NAME=s.CARRIER_NAME
                       and ip_dll between s.MIN_DLL_EXCH and s.MAX_DLL_EXCH) a
             WHERE 1=1
               AND cp.st = b.state
               and cp.carrier_id = b.carrier_ID
               and cp.county = a.county
               AND (   (b.cdma_tech = 'CDMA' AND a.sim_profile = 'NA')
                    OR (b.gsm_tech = 'GSM' AND a.sim_profile IS NOT NULL AND a.sim_profile <> 'NA')
                    or (b.cdma_tech = 'CDMA' AND a.sim_profile IS NOT NULL) )
               AND b.ZONE = a.ZONE
               AND b.state = a.st) tab1,
          ( select /*+ USE_NL(pi) USE_NL(ml) USE_NL(pn) USE_NL(bo) */
		   distinct
		   pn.part_num2bus_org,
                   pn.x_technology,
                   pi.x_part_inst_status,
                   nvl((select v.x_param_value
                          from table_x_part_class_values v,
                               table_x_part_class_params n
                         where 1=1
                           and v.value2part_class     = pn.part_num2part_class
                           and v.value2class_param    = n.objid
                           and n.x_param_name         = 'PHONE_GEN'
                           and rownum <2),'2G') phone_gen,
                   nvl((select v.x_param_value
                          from table_x_part_class_values v,
                               table_x_part_class_params n
                         where 1=1
                           and v.value2part_class     = pn.part_num2part_class
                           and v.value2class_param    = n.objid
                           and n.x_param_name         = 'DATA_SPEED'
                           and rownum <2),NVL(pn.x_data_capable, 0)) data_speed,
                   nvl((SELECT COUNT(*) sr
                           FROM table_x_part_class_values v, table_x_part_class_params n
                          WHERE 1 = 1
                            AND v.value2part_class = pn.part_num2part_class
                            AND v.value2class_param = n.objid
                            AND n.x_param_name = 'NON_PPE'
                            AND v.x_param_value in ( '1','0') -- CR15018 --12/02/10 invalid number fix
                            AND ROWNUM < 2),0) non_ppe,
                   bo.org_id
              from
                   table_part_inst pi,
                   sa.table_mod_level ml,
                   table_part_num pn,
	           table_bus_org bo
             where 1=1
               and bo.objid          = pn.part_num2bus_org
               and pn.objid          = ml.part_info2part_num
               and ml.objid          = pi.n_part_inst2part_mod
               AND pi.part_serial_no = ip_esn) tab2,
          table_x_carrier ca,
          table_x_carrier_group grp,
          table_x_parent pa
    where 1=1
      and ca.x_carrier_id = tab1.carrier_id
      AND grp.objid = ca.carrier2carrier_group
      AND pa.objid = grp.x_carrier_group2x_parent
      and exists(select 1
                   from table_x_carrier_features cf
                  where 1=1
                    and cf.x_feature2x_carrier = ca.objid
                    --NEG--FIXand cf.x_technology        = tab2.x_technology
                    and cf.X_FEATURES2BUS_ORG  = tab2.part_num2bus_org
                   -- and cf.x_data              = tab2.data_speed --CR39105
                    and decode(cf.X_SWITCH_BASE_RATE,null,tab2.non_ppe,1) = tab2.non_ppe
                 union
                 select cf.X_FEATURES2BUS_ORG
                   from table_x_carrier_features cf
                  where cf.X_FEATURE2X_CARRIER in( SELECT c2.objid
                                                     FROM table_x_carrier_group cg2,
                                                          table_x_carrier c2
                                                    WHERE cg2.x_carrier_group2x_parent = pa.objid
                                                      AND c2.carrier2carrier_group = cg2.objid)
                    and cf.x_technology        = tab2.x_technology
                    and cf.X_FEATURES2BUS_ORG  = (select bo.objid
                                                    from table_bus_org bo
                                                   where bo.org_id = 'NET10'
                                                     and bo.objid  = tab2.part_num2bus_org)
                    and cf.x_data              = tab2.data_speed
                    and decode(cf.X_SWITCH_BASE_RATE,null,tab2.non_ppe,1) = tab2.non_ppe);

    rec_avail_carriers cur_avail_carriers%rowtype;

    v_days_active number;
    v_dll varchar2(10);
    v_curr_carrier varchar2(50);
    v_prev_carrier varchar2(50);
    v_min varchar2(30);
    v_curr_carrier_coverage varchar2(5):='NO';
    v_prev_carrier_coverage varchar2(5):='NO';
    v_line_moved number;
    v_zipcode varchar2(10);
    v_new_carrier varchar2(100) := null;
    v_alternative number:=0;

begin
    op_error_num := '0';
    op_error_msg := 'SUCCESS';
    op_solution_reason:= 'Unable Unable Coverage';
    op_prev_carrier := 'NA';
    op_prev_carrier_coverage := 'NA';
	op_curr_carrrier_coverage := 'NO';
    op_alternative_output:='';

    open esn_part_num_cur(ip_esn);
    fetch esn_part_num_cur into esn_part_num_rec;
    if esn_part_num_cur%found then
       close esn_part_num_cur;
       v_dll := esn_part_num_rec.x_dll;
    else
       close esn_part_num_cur;
       op_error_num := '50';
       op_error_msg := 'Serial No not found';
       return;
    end if;

    select count('1')
    into v_alternative
    from sa.x_crm_perms2priv_class
    where permission_objid in (select objid from sa.X_CRM_PERMISSIONS where  PERMISSION_NAME = 'UNABLE_EXCH_ALTERNATIVE_OPTION')
    and priv_class_objid in (select user_access2privclass from sa.table_user where upper(login_name) = upper(ip_login_name));

    open current_service_cur(ip_esn);
    fetch current_service_cur into current_service_rec;
    if current_service_cur%found then
       close current_service_cur;
       v_days_active := current_service_rec.days_active;
       v_curr_carrier := current_service_rec.current_carrier;
       v_min := current_service_rec.x_min;
       v_zipcode := current_service_rec.x_zipcode;
       op_curr_install_date:=current_service_rec.install_date;
       op_curr_zip_code:=current_service_rec.x_zipcode;
       op_curr_carrier:=v_curr_carrier;

    else
       close current_service_cur;
       op_error_num := '100';
       op_error_msg := 'Service is not active';
       return;
    end if;

    open previous_carrier_cur(v_min,v_curr_carrier);
    fetch previous_carrier_cur into previous_carrier_rec;
    if previous_carrier_cur%found then
       close previous_carrier_cur;
       v_prev_carrier:= previous_carrier_rec.previous_carrier;
       op_prev_carrier:=v_prev_carrier;
       op_upgraded:='YES';
    else
       close previous_carrier_cur;
       v_prev_carrier := 'NA';
       op_upgraded:='NO';

    end if;

    for rec_avail_carriers in cur_avail_carriers (v_zipcode,v_dll,ip_esn) loop

      if rec_avail_carriers.x_queue_name = v_prev_carrier or
         rec_avail_carriers.x_parent_name = v_prev_carrier then
         v_prev_carrier_coverage := 'YES';
         op_prev_carrier_coverage:=v_prev_carrier_coverage;
      end if;

      if rec_avail_carriers.x_queue_name = v_curr_carrier or
         rec_avail_carriers.x_parent_name = v_curr_carrier then
         v_curr_carrier_coverage := 'YES';
         op_curr_carrrier_coverage:=v_curr_carrier_coverage;

      end if;

      if rec_avail_carriers.x_queue_name <> v_curr_carrier and rec_avail_carriers.x_queue_name <> v_prev_carrier and
         rec_avail_carriers.x_parent_name <> v_curr_carrier and rec_avail_carriers.x_parent_name <> v_prev_carrier then
         v_new_carrier:= nvl(rec_avail_carriers.x_queue_name,rec_avail_carriers.x_parent_name);
      end if;

    end loop;

    select count('1')
    into v_line_moved
    from table_site_part sp, table_x_parent p, table_x_carrier_group cg, table_x_carrier c, table_part_inst pi
    where sp.x_min = v_min
    and sp.x_zipcode <> v_zipcode
    and  pi.part_serial_no = sp.x_min
    and pi.x_domain = 'LINES'
    and pi.part_inst2carrier_mkt = c.objid
    and c.carrier2carrier_group = cg.objid
    and cg.x_carrier_group2x_parent = p.objid
    and sp.part_status = 'Inactive'
    and sp.SERVICE_END_DT >= sysdate -90;

    if v_line_moved>0 then
       op_min_changed_area:='YES';
    else
       op_min_changed_area:='NO';
    end if;

    --#1

    if v_days_active <= 45 and v_prev_carrier <> 'NA' and v_prev_carrier_coverage='YES' then
      op_recomended_output := 'Return to previous carrier ['||v_prev_carrier||']';
      if v_alternative > 0 and v_curr_carrier_coverage = 'YES' then
          op_alternative_output := 'Same carrier exchange ['||v_curr_carrier||']';
      end if;
      return;
    end if;

    --#3
    if v_days_active <= 45 and v_prev_carrier = 'NA' and v_line_moved > 0 then
      if v_new_carrier is not null then
        op_recomended_output := 'New Carrier Exchange ['||v_new_carrier||']';
      end if;
      if v_alternative > 0 and v_curr_carrier_coverage = 'YES' then
          op_alternative_output := 'Same carrier exchange ['||v_curr_carrier||']';
      end if;

      return;
    end if;

	--#2
    if v_days_active <= 45 and v_prev_carrier = 'NA' and v_curr_carrier_coverage='YES' then    --modified from requirement (v_prev_carrier_coverage = 'YES' but there is no previous carrier)
      op_recomended_output := 'Same carrier exchange ['||v_curr_carrier||']';
      return;
    end if;

    --#4
    if v_days_active <= 45 and v_curr_carrier_coverage = 'NO' and v_prev_carrier <> 'NA' and v_prev_carrier_coverage='YES' then
      op_recomended_output := 'Return to previous carrier ['||v_prev_carrier||']';
      --- commenting below code as offerring same carrier coverage is not valid when current carrier has no coverage in the area
      --if v_alternative > 0 then
      --    op_alternative_output := 'Same carrier exchange ['||v_curr_carrier||']';
      --end if;

      return;
    end if;

    --#5
    IF v_days_active <= 45 and v_prev_carrier <> 'NA' and v_prev_carrier_coverage='NO' then
      op_recomended_output  := 'Same carrier exchange ['||v_curr_carrier||']';
    END IF;

    --#6
    if v_days_active > 45 and v_curr_carrier_coverage = 'YES' then
      op_recomended_output := 'Same carrier exchange ['||v_curr_carrier||']';
      return;
    end if;

    --#7
    if v_days_active > 45 and v_curr_carrier_coverage = 'NO'  and v_prev_carrier = 'NA'  then
      if v_new_carrier is not null then
        op_recomended_output := 'New Carrier Exchange ['||v_new_carrier||']';
      end if;
      --- commenting below code as offerring same carrier coverage is not valid when current carrier has no coverage in the area
      --if v_alternative > 0 then
      --    op_alternative_output := 'Same carrier exchange ['||v_curr_carrier||']';
      --end if;

      return;
    end if;

    --#8
    if v_days_active > 45 and v_curr_carrier_coverage = 'NO' and v_prev_carrier <> 'NA'  and v_prev_carrier_coverage ='YES' then
      op_recomended_output := 'Return to previous carrier ['||v_prev_carrier||']';
      --- commenting below code as offerring same carrier coverage is not valid when current carrier has no coverage in the area
      --if v_alternative > 0 then
      --    op_alternative_output := 'Same carrier exchange ['||v_curr_carrier||']';
      --end if;

      return;
    end if;

    --#9
    if v_days_active > 45 and v_curr_carrier_coverage = 'NO' and v_prev_carrier <> 'NA'  and v_prev_carrier_coverage ='NO' then
      if v_new_carrier is not null then
        op_recomended_output := 'New Carrier Exchange ['||v_new_carrier||']';
      end if;
      --- commenting below code as offerring same carrier coverage is not valid when current carrier has no coverage in the area
      --if v_alternative > 0 then
      --    op_alternative_output := 'Same carrier exchange ['||v_curr_carrier||']';
      --end if;

      return;
    end if;

end adfcrm_unable_coverage_check;
/