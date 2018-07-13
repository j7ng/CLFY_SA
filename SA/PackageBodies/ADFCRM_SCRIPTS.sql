CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_SCRIPTS" is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_SCRIPTS_PKB.sql,v $
--$Revision: 1.62 $
--$Author: syenduri $
--$Date: 2017/11/09 20:37:48 $
--$ $Log: ADFCRM_SCRIPTS_PKB.sql,v $
--$ Revision 1.62  2017/11/09 20:37:48  syenduri
--$ CR50105-BOGO Script integration for WFM
--$
--$ Revision 1.61  2017/10/27 20:35:57  mmunoz
--$ Changes to include WFM autorefill check
--$
--$ Revision 1.60  2017/10/11 22:19:33  mmunoz
--$ CR53046  Checking autorefill
--$
--$ Revision 1.59  2017/10/09 16:01:07  mmunoz
--$ CR53046 TAS  Display script driven content in Transaction Summary
--$
--$ Revision 1.58  2017/01/06 15:55:46  hcampano
--$ CR44729 - GO Smart
--$
--$ Revision 1.57  2017/01/06 15:29:26  hcampano
--$ CR44729 - GO Smart
--$
--$ Revision 1.56  2016/11/18 23:57:40  mmunoz
--$ CR44787: Updated solution_script_func to initialize the variable for script text to empty string
--$
--$ Revision 1.55  2016/11/04 15:09:03  amishra
--$ CR44787: Corrected condition which includes BOGO script in transaction summary message
--$
--$ Revision 1.54  2016/11/01 22:06:32  amishra
--$ CR 45463, 44787 : Changes for BOGO promotion in transaction summary
--$
--$ Revision 1.53  2016/05/09 21:01:39  mmunoz
--$ CR39151: Added ip_source_system varchar2 default 'TAS'  in function solution_script_func
--$
--$ Revision 1.52  2016/04/29 21:02:55  syenduri
--$ CR39151 - Modifing Scripts : Check-in behalf of Zuber
--$
--$ Revision 1.51  2016/02/26 20:03:25  hcampano
--$ 40990 - 2G Migration Project ? Micro Site
--$
--$ Revision 1.50  2016/02/19 15:44:49  nguada
--$ Exception clause added to block alert function.
--$
--$ Revision 1.49  2016/02/17 16:33:52  hcampano
--$ TAS_2016_04A
--$
--$ Revision 1.48  2015/10/27 15:58:01  syenduri
--$ TAS_2015_21 - CR# 36435 Repl/Comp Changes
--$
--$ Revision 1.47  2015/06/08 16:28:17  mmunoz
--$ CR34313 : Added logic in get_script_message to display a warning when CARRIER_BUCKET_DOMINTL_FLAG  = YES and CARRIER <> TMO
--$
--$ Revision 1.46  2015/05/26 16:14:56  mmunoz
--$ CR32952 new function get_generic_brand_script
--$
--$ Revision 1.45  2015/02/05 16:40:25  mmunoz
--$ Added solution UPGRADE
--$
--$ Revision 1.44  2015/02/03 16:14:32  mmunoz
--$ 30534    Allow Purchase for Upgrades scenarios (solution_name)
--$
--$ Revision 1.43  2015/01/27 22:03:27  mmunoz
--$ Included function get_text_with_tokens
--$
--$ Revision 1.42  2014/11/13 17:35:04  mmunoz
--$ calling function getServPlanGroupType
--$
--$ Revision 1.41  2014/09/18 20:58:31  mmunoz
--$ added condition for query in table_x_red_card
--$
--$ Revision 1.40  2014/09/15 19:03:15  mmunoz
--$ updated get_feature_value for improvements
--$
--$ Revision 1.39  2014/09/05 23:05:01  mmunoz
--$ Added  check for RECURRING_SERVICE_PLAN feature
--$
--$ Revision 1.38  2014/08/26 21:00:43  mmunoz
--$ replacing function for adfcrm_get_serv_plan_value
--$
--$ Revision 1.37  2014/08/26 18:25:59  mmunoz
--$ added materialized view
--$
--------------------------------------------------------------------------------------------

  TYPE ild_plan_record is record (
       plan  number,
       ild   varchar2(30),
       ild_category varchar2(30)
  );

  --------------------------------------------------------------------------------------------
  function get_script_by_class (ip_script_type varchar2,
                                ip_script_id varchar2,
                                ip_language varchar2,
                                ip_part_class  varchar2) return varchar2
  as
    op_script_text  varchar2(4000);
    ip_sourcesystem varchar2(30);
  begin
    op_script_text := get_script_by_class_ss
                     (ip_script_type,
                     ip_script_id,
                     ip_language,
                     ip_part_class,
                     ip_sourcesystem);

    return op_script_text;

  end get_script_by_class;
  --------------------------------------------------------------------------------------------
  function get_script_by_class_ss (ip_script_type varchar2,
                                   ip_script_id varchar2,
                                   ip_language varchar2,
                                   ip_part_class  varchar2,
                                   ip_sourcesystem varchar2) return varchar2
  as
    ip_brand_name varchar2(30);
    ip_carrier_id varchar2(10);
    op_objid varchar2(30);
    op_description varchar2(1000);
    op_script_text varchar2(4000);
    op_publish_by varchar2(30);
    op_publish_date date;
    op_sm_link varchar2(300);
    v_script_id varchar2(30);
    v_language varchar2(30);
    v_sourcesystem     varchar2(30);

  begin

    if ip_sourcesystem is null then
       v_sourcesystem := 'TAS';
    else
       v_sourcesystem := ip_sourcesystem;
    end if;

    ip_brand_name := sa.adfcrm_scripts.get_script_brand(ip_pc => ip_part_class);

    ip_carrier_id := null;

    if ip_script_id = 'NA' then
       v_script_id := null;
    else
       v_script_id := ip_script_id;
    end if;


    if ip_language is null then
       v_language := 'ENGLISH';
    else
       select decode(upper(substr(ip_language,1,2)),'EN','ENGLISH','SPANISH')
       into v_language
       from dual;
    end if;
    scripts_pkg.get_script_prc(
      ip_sourcesystem => v_sourcesystem,
      ip_brand_name => ip_brand_name,
      ip_script_type => ip_script_type,
      ip_script_id => ip_script_id,
      ip_language => v_language,
      ip_carrier_id => ip_carrier_id,
      ip_part_class => ip_part_class,
      op_objid => op_objid,
      op_description => op_description,
      op_script_text => op_script_text,
      op_publish_by => op_publish_by,
      op_publish_date => op_publish_date,
      op_sm_link => op_sm_link
    );

    op_script_text := trim(op_script_text);
    --if op_script_text like 'SCRIPT MISSING%' then
    --   return null;
    --else
      return op_script_text;
    --end if;

  end get_script_by_class_ss;
  --------------------------------------------------------------------------------------------
  function get_script_by_esn (ip_script_type varchar2,
                              ip_script_id varchar2,
                              ip_language varchar2,
                              ip_esn  varchar2) return varchar2
  as
    ip_sourcesystem varchar2(30);
    ip_brand_name varchar2(30);
    ip_carrier_id varchar2(30);
    ip_part_class varchar2(30);
    op_objid varchar2(30);
    op_description varchar2(200);
    op_script_text varchar2(200);
    op_publish_by varchar2(200);
    op_publish_date date;
    op_sm_link varchar2(200);

  begin

    ip_sourcesystem := null;
    ip_brand_name := null;
    ip_carrier_id := null;
    ip_part_class := null;

    scripts_pkg.get_script_prc(
      ip_sourcesystem => ip_sourcesystem,
      ip_brand_name => ip_brand_name,
      ip_script_type => ip_script_type,
      ip_script_id => ip_script_id,
      ip_language => ip_language,
      ip_carrier_id => ip_carrier_id,
      ip_part_class => ip_part_class,
      op_objid => op_objid,
      op_description => op_description,
      op_script_text => op_script_text,
      op_publish_by => op_publish_by,
      op_publish_date => op_publish_date,
      op_sm_link => op_sm_link
    );

    return op_script_text;
  end get_script_by_esn;

--------------------------------------------------------------------------------------------

function get_ild_feature (
      part_class_name varchar2,
      ip_purchase_id  varchar2,
      ip_call_id varchar2
) return ild_plan_record is
  ild_plan_rec ild_plan_record;
  v_card2part_mod  number;
  v_part_num2part_class number;
  v_part_class_name varchar2(100);
BEGIN
v_part_class_name := part_class_name;
ild_plan_rec.ild := 'NO';

/************  BEGIN check by ip_purchase_id  *********/

if ip_purchase_id is not null then
--dbms_output.put_line('*****************ADFCRM_SCRIPTS ip_purchase_id='||ip_purchase_id||'  '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
    v_card2part_mod := -1;
    begin
        select n_part_inst2part_mod card2part_mod
        into   v_card2part_mod
        from   table_part_inst
        where  x_red_code = ip_purchase_id
        ;
    exception
        when others then
           begin
             select x_red_card2part_mod  card2part_mod
             into   v_card2part_mod
             from   table_x_red_card rc
             where  x_red_code = ip_purchase_id
             and    x_result <> 'Failed';
          exception
             when others then v_card2part_mod := -1;
          end;
    end;

--dbms_output.put_line('*****************ADFCRM_SCRIPTS v_card2part_mod='||v_card2part_mod||'  '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
    if v_card2part_mod <> -1
    then
        select part_num2part_class
        into   v_part_num2part_class
        from  table_mod_level ml,
              table_part_num pn
        where ml.objid = v_card2part_mod
        and   ml.part_info2part_num = pn.objid;
    else
        v_part_num2part_class := -1;
    end if;

    if nvl(ild_plan_rec.ild ,'NO') = 'NO' then
    /************************************************************************/
    /*  Check if pin card is a VAS Service that allows international calls  */
    /************************************************************************/
    for ild_rec in
       (select vi.vas_service_id plan, 'YES' ild, 'VAS' ild_category
        from table_part_class pc,
             vas_programs_view vi
       where pc.objid = v_part_num2part_class
       and vi.vas_card_class =pc.name
       and vi.vas_category = 'ILD_REUP'
       )
    loop
       ild_plan_rec.plan := ild_rec.plan;
       ild_plan_rec.ild := ild_rec.ild;
       ild_plan_rec.ild_category := ild_rec.ild_category;
    end loop;
    end if;

    if nvl(ild_plan_rec.ild ,'NO') = 'NO' then
    /***************************************************************************/
    /*  Check if service plan linked to the program allows international calls */
    /***************************************************************************/
    for ild_rec in
          (select spxpp.program_para2x_sp plan, 'YES' ild, 'SERVICE PLAN' ild_category
           from   x_program_purch_hdr phdr,
                  x_program_purch_dtl pdtl,
                  x_program_enrolled pe,
                  sa.mtm_sp_x_program_param   spxpp
           where phdr.x_merchant_ref_number  = ip_purchase_id
           and pdtl.pgm_purch_dtl2prog_hdr = phdr.objid
           and pe.objid = pdtl.pgm_purch_dtl2pgm_enrolled
           and pdtl.x_esn = pe.x_esn
           and spxpp.x_sp2program_param = pe.pgm_enroll2pgm_parameter+0
           and spxpp.x_recurring = 1
           and sa.ADFCRM_GET_SERV_PLAN_VALUE(spxpp.program_para2x_sp,'RECURRING_SERVICE_PLAN') is null
           )
    loop
        if sa.adfcrm_get_serv_plan_value(ild_rec.plan,'ILD') = 'YES' then
           --and sa.adfcrm_cust_service.is_sp_compatible(ild_rec.plan,part_class_name) > 0 then
           ild_plan_rec.plan := ild_rec.plan;
           ild_plan_rec.ild := ild_rec.ild;
           ild_plan_rec.ild_category := ild_rec.ild_category;
        end if;
    end loop;
    end if;

    if nvl(ild_plan_rec.ild ,'NO') = 'NO' then
    /************************************************************************/
    /*  Check if service plan linked to pin card allows international calls */
    /************************************************************************/
    for ild_rec in
       (select sp_pin.sp_objid plan, 'YES' ild, 'SERVICE PLAN' ild_category
        from sa.adfcrm_serv_plan_class_matview sp_pin,
             sa.adfcrm_serv_plan_class_matview sp_esn
        where sp_pin.PART_CLASS_OBJID = v_part_num2part_class
        and   NVL(sa.ADFCRM_GET_SERV_PLAN_VALUE(sp_pin.sp_objid,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE'
        and   sp_esn.PART_CLASS_NAME = v_part_class_name
        and   sp_esn.sp_objid = sp_pin.sp_objid
       )
    loop
        if sa.adfcrm_get_serv_plan_value(ild_rec.plan,'ILD') = 'YES' then
           --and  sa.adfcrm_cust_service.is_sp_compatible(ild_rec.plan,part_class_name) > 0 then
           ild_plan_rec.plan := ild_rec.plan;
           ild_plan_rec.ild := ild_rec.ild;
           ild_plan_rec.ild_category := ild_rec.ild_category;
        end if;
    end loop;
    end if;
end if;
/************  END check by ip_purchase_id  *********/

/************  BEGIN check by ip_call_id  *********/
if ip_call_id is not null and nvl(ild_plan_rec.ild ,'NO') = 'NO' then
--dbms_output.put_line('*****************ADFCRM_SCRIPTS ip_call_id='||ip_call_id||'  '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
    v_card2part_mod := -1;
    begin
        select x_red_card2part_mod  card2part_mod
        into   v_card2part_mod
        from   table_x_red_card rc
        where  rc.red_card2call_trans = ip_call_id
        and    x_result <> 'Failed';
--dbms_output.put_line('*****************ADFCRM_SCRIPTS 328 v_card2part_mod='||v_card2part_mod||'  '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
    exception
        when others then
           begin
              select n_part_inst2part_mod card2part_mod
              into   v_card2part_mod
              from   table_part_inst,
                     table_x_call_trans ct
              where  x_red_code = nvl(ct.x_reason,'#')
              and    ct.objid = ip_call_id;
--dbms_output.put_line('*****************ADFCRM_SCRIPTS 338 v_card2part_mod='||v_card2part_mod||'  '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
         exception
             when others then v_card2part_mod := -1;
          end;
    end;
    if v_card2part_mod <> -1
    then
        select part_num2part_class
        into   v_part_num2part_class
        from  table_mod_level ml,
              table_part_num pn
        where ml.objid = v_card2part_mod
        and   pn.objid = ml.part_info2part_num;
    else
        v_part_num2part_class := -1;
    end if;
--dbms_output.put_line('*****************ADFCRM_SCRIPTS v_part_num2part_class='||v_part_num2part_class||'  '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
    if nvl(ild_plan_rec.ild ,'NO') = 'NO' and v_part_num2part_class != -1 then
    /************************************************************************/
    /*  Check if pin card is a VAS Service that allows international calls  */
    /************************************************************************/
    for ild_rec in
           (select vi.vas_service_id plan, 'YES' ild, 'VAS' ild_category
            from  table_part_class pc,
                  vas_programs_view vi
            where pc.objid = v_part_num2part_class
            and vi.vas_card_class =pc.name
            and vi.vas_category = 'ILD_REUP'
            )
    loop
       ild_plan_rec.plan := ild_rec.plan;
       ild_plan_rec.ild := ild_rec.ild;
       ild_plan_rec.ild_category := ild_rec.ild_category;
    end loop;
    end if;
--dbms_output.put_line('*****************ADFCRM_SCRIPTS line 358 ild_plan_rec.plan ='||ild_plan_rec.plan ||'  ild ='||ild_plan_rec.ild||'  '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
    if nvl(ild_plan_rec.ild ,'NO') = 'NO' and v_part_num2part_class != -1  then
    /*********************************************************************************/
    /*  Check if service plan linked to pin card redeemed allows international calls */
    /*********************************************************************************/
    for ild_rec in
       (select sp_pin.sp_objid plan, 'YES' ild, 'SERVICE PLAN' ild_category
        from sa.adfcrm_serv_plan_class_matview sp_pin,
             sa.adfcrm_serv_plan_class_matview sp_esn
        where sp_pin.PART_CLASS_OBJID = v_part_num2part_class
        and   NVL(sa.ADFCRM_GET_SERV_PLAN_VALUE(sp_pin.sp_objid,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE'
        and   sp_esn.PART_CLASS_NAME = v_part_class_name
        and   sp_esn.sp_objid = sp_pin.sp_objid
       )
    loop
        if sa.adfcrm_get_serv_plan_value(ild_rec.plan,'ILD') = 'YES' then
           --if sa.adfcrm_cust_service.is_sp_compatible(ild_rec.plan,part_class_name) > 0 then
              ild_plan_rec.plan := ild_rec.plan;
              ild_plan_rec.ild := ild_rec.ild;
              ild_plan_rec.ild_category := ild_rec.ild_category;
           --end if;
        end if;
    end loop;
    end if;
--dbms_output.put_line('*****************ADFCRM_SCRIPTS line 388 ild_plan_rec.plan ='||ild_plan_rec.plan ||'  ild ='||ild_plan_rec.ild||'  '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
    if nvl(ild_plan_rec.ild ,'NO') = 'NO' then
    /************************************************************************/
    /*  Check if service plan in table_site_part allows international calls */
    /************************************************************************/
    for ild_rec in
           (
            select xsp.objid plan, 'YES' ild, 'SERVICE PLAN' ild_category
            from  sa.table_x_call_trans ct,
                  sa.x_service_plan_site_part spsp,
                  sa.x_service_plan xsp
            where ct.objid = ip_call_id
            and  spsp.table_site_part_id = ct.call_trans2site_part
            and  xsp.objid = spsp.x_service_plan_id
            )
    loop
        if sa.adfcrm_get_serv_plan_value(ild_rec.plan,'ILD') = 'YES'
        then
           ild_plan_rec.plan := ild_rec.plan;
           ild_plan_rec.ild := ild_rec.ild;
           ild_plan_rec.ild_category := ild_rec.ild_category;
       end if;
    end loop;
    end if;
end if;
/************  END check by ip_call_id  *********/

dbms_output.put_line('ild_plan_rec  PLAN='||ild_plan_rec.plan||'  ILD='||ild_plan_rec.ild ||'  ILD_CATEGORY='||ild_plan_rec.ild_category||'  '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
return ild_plan_rec;
END;

  --------------------------------------------------------------------------------------------
  function solution_script_func (ip_solution_name sa.adfcrm_solution.solution_name%type,
                                 ip_esn sa.table_part_inst.part_serial_no%type,
                                 ip_language varchar2,
                                 ip_param_list varchar2) return clob
  is
  begin
      return solution_script_func (ip_solution_name,
                                 ip_esn,
                                 ip_language,
                                 ip_param_list,
                                 null,
                                 null);
  end;

  function solution_script_func (ip_solution_name sa.adfcrm_solution.solution_name%type,
                                 ip_esn sa.table_part_inst.part_serial_no%type,
                                 ip_language varchar2,
                                 ip_param_list varchar2,
                                 ip_transaction_id varchar2,
                                 ip_case_id varchar2,
                                 ip_source_system varchar2 default 'TAS',
                                 ip_check_condition varchar2 default 'BOGO=NO'
                                 ) return clob
  as
    final_script            clob;
    ild_plan_feature        sa.x_serviceplanfeaturevalue_def.value_name%type;
    ip_sourcesystem         varchar2(50);
    v_language              varchar2(50);
    SHOW_SCRIPT             varchar2(50);
    creditcard_cnt          number;
    v_solution_name         varchar2(150);
    script_text             varchar2(4000);


    CURSOR get_esns (IP_ESN VARCHAR2)
    IS
        SELECT ESN
        from
          (WITH t AS (SELECT IP_ESN  esn  FROM dual)
                   select replace(regexp_substr(esn,'[^,]+',1,lvl),'null','') ESN
                   from  (select esn, level lvl
                          FROM   t
                          CONNECT BY LEVEL <= LENGTH(esn) - LENGTH(REPLACE(esn,',')) + 1)
           ) p;

    get_esns_rec    get_esns%rowtype;

    cursor get_purchases (ip_param_list varchar2)
    is
    select purchase_id
    from
          (with t as (select ip_param_list purchaseid  from dual)
                   select replace(regexp_substr(purchaseid,'[^,]+',1,lvl),'null','') purchase_id
                   from  (select purchaseid, level lvl
                          from   t
                          connect by level <= length(purchaseid) - length(replace(purchaseid,',')) + 1)
           ) p;

    get_purchases_rec    get_purchases%rowtype;

    cursor get_calls (ip_transaction_id varchar2)
    is
    select call_id
    from
          (with t as (select ip_transaction_id callid  from dual)
                   select replace(regexp_substr(callid,'[^,]+',1,lvl),'null','') call_id
                   from  (select callid, level lvl
                          from   t
                          connect by level <= length(callid) - length(replace(callid,',')) + 1)
           ) p;

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

    cursor get_script (ip_solution_name sa.adfcrm_solution.solution_name%type
                  ,ip_esn sa.table_part_inst.part_serial_no%type
                  ,ip_language varchar2)
    is
    select
    sol_script.solution_name,
    ''  script_text,
    sol_script.step,
    sol_script.script_type,
    sol_script.script_id
    from
    (
     select adfcrm_solution.solution_name,
            adfcrm_solution.script_id,
            adfcrm_solution.script_type,
            0 step,
            adfcrm_solution.keywords
     from  adfcrm_solution
     where adfcrm_solution.script_id is not null
     and   adfcrm_solution.access_type = -1
     union
     select adfcrm_solution.solution_name,
            adfcrmsolutionscripts.script_id,
            adfcrmsolutionscripts.script_type,
            adfcrmsolutionscripts.step,
            adfcrm_solution.keywords
     from  adfcrm_solution,
           adfcrm_solution_scripts adfcrmsolutionscripts
     where adfcrmsolutionscripts.solution_id  = adfcrm_solution.solution_id
     and   adfcrm_solution.access_type = -1
     ) sol_script
    where sol_script.solution_name = ip_solution_name
    order by sol_script.step asc;

    get_ild_feature_rec     ild_plan_record;

    cursor part_class_script_cur (ip_script_type   varchar2
                                ,ip_script_id     varchar2
                                ,ip_language      varchar2
                                ,ip_part_class    varchar2
                                ,ip_sourcesystem  varchar2
    ) is
    select xs.*
    from sa.table_x_scripts xs,
         sa.mtm_part_class6_x_scripts1 mtm,
         sa.table_part_class pc
    where mtm.part_class2script=pc.objid
    and  mtm.script2part_class    = xs.objid
    and  xs.x_script_type         = ip_script_type
    and  xs.x_script_id           = ip_script_id
    and  xs.x_language            = ip_language
    and  pc.name                  = ip_part_class
    and  (xs.x_sourcesystem       = decode(ip_sourcesystem, 'WAP','WEB','APP','WEB',ip_sourcesystem)
         or xs.x_sourcesystem         = 'ALL')
    and  xs.script2bus_org is not null
    order by xs.x_sourcesystem desc, xs.x_published_date desc;

    cursor get_program_info (ip_esn varchar2)
    is
      SELECT pgmprm.objid
            ,pgmprm.x_program_name
            ,pgmenr.x_next_charge_date
        FROM
              x_program_enrolled   pgmenr
             ,x_program_parameters pgmprm
       WHERE 1 = 1
         AND pgmenr.x_esn = ip_esn
         AND pgmenr.x_enrollment_status||'' = 'ENROLLED'
         AND pgmprm.objid = pgmenr.pgm_enroll2pgm_parameter + 0
         AND pgmprm.x_is_recurring = 1
         AND NVL(pgmprm.x_prog_class,' ') not in ('ONDEMAND','WARRANTY');

    get_program_info_rec    get_program_info%rowtype;
    part_class_script_rec   part_class_script_cur%rowtype;

    cursor check_parameter (ip_parameter varchar2) is--comma separated values
        select parameter
        from (
              select regexp_substr(input_value,'[^,]+',1,level) parameter
              from (select ip_check_condition input_value from dual)
              connect by level<=regexp_count(input_value,'[^,]+')
              group by level, input_value
             )
        where parameter = ip_parameter;
    check_parameter_rec   check_parameter%rowtype;

    check_service_plan_ild    number;
    v_service_plan_ild        varchar2(100);
    v_autorefill      varchar2(100) := 'NO';
    v_safelink        varchar2(100) := 'NO';
    v_cursor   SYS_REFCURSOR;
  begin
    check_service_plan_ild := 0;
    v_service_plan_ild := '';
    final_script := '';
    v_solution_name := ip_solution_name;
    ---------------------------------------------------------------------
    -- Transform ACTIVATION_PG_PURCHASE, REDEMPTION_PG_PURCHASE,PORTS_PG_PURCHASE in PURCHASE_PG...
    ---------------------------------------------------------------------
    if v_solution_name like '%PURCHASE%' then
       v_solution_name := replace(v_solution_name,'REDEMPTION_PG_PURCHASE','PURCHASE_PG');
       v_solution_name := replace(v_solution_name,'ACTIVATION_PG_PURCHASE','ACTIVATION_PG');
       v_solution_name := replace(v_solution_name,'REACTIVATION_PG_PURCHASE','REACTIVATION_PG');
       v_solution_name := replace(v_solution_name,'PORTS_PG_PURCHASE','PORTS_PG');
       v_solution_name := replace(v_solution_name,'UPGRADE_MANUAL_PORT_PURCHASE','UPGRADE_MANUAL_PORT');
       v_solution_name := replace(v_solution_name,'UPGRADE_ESN_EXCHANGE_PURCHASE','UPGRADE_ESN_EXCHANGE');
       v_solution_name := replace(v_solution_name,'UPGRADE_AUTO_PORT_PURCHASE','UPGRADE_AUTO_PORT');
       v_solution_name := replace(v_solution_name,'UPGRADE_PURCHASE','UPGRADE');
    end if;

    select decode(upper(substr(nvl(ip_language,'EN'),1,2)),'EN','ENGLISH','SPANISH')
    into   v_language
    from   dual;

    open check_parameter('AUTOREFILL');
    fetch check_parameter into check_parameter_rec;
    if check_parameter%notfound
    then
           v_autorefill := 'NO';
    else
           v_autorefill := 'YES';
    end if;
    close check_parameter;

    open check_parameter('SAFELINK');
    fetch check_parameter into check_parameter_rec;
    if check_parameter%notfound
    then
           v_safelink := 'NO';
    else
           v_safelink := 'YES';
    end if;
    close check_parameter;
--dbms_output.put_line('*****************ADFCRM_SCRIPTS Request for '||v_solution_name ||' '||ip_esn ||' '|| ip_language ||' '||ip_param_list||' '|| ip_transaction_id ||' '||ip_case_id||' '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));

   --Included get_esns for family plans. Get one esn from the csv list.
   --OPEN get_esns(IP_ESN);
   --FETCH get_esns INTO get_esns_rec;
   --CLOSE get_esns;
   if instr(IP_ESN,',') > 0
   then
      get_esns_rec.esn := substr(IP_ESN,1,instr(IP_ESN,',',1,1)-1);
   else
      get_esns_rec.esn := IP_ESN;
   end if;

   OPEN GET_ESN_INFO(get_esns_rec.esn);
   FETCH GET_ESN_INFO INTO GET_ESN_INFO_REC;
   IF GET_ESN_INFO%FOUND THEN

--dbms_output.put_line('*****************ADFCRM_SCRIPTS Open rec '||v_solution_name ||' '||GET_ESN_INFO_REC.ESN ||' '|| ip_language||' '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));

   FOR rec IN GET_SCRIPT(v_solution_name,GET_ESN_INFO_REC.ESN,IP_LANGUAGE)
   loop
    IP_SOURCESYSTEM :=  ip_source_system;
    script_text := '';
    SHOW_SCRIPT := 'YES';
    ---------------------------------------------------------------------
    -- Check autorefill
    ---------------------------------------------------------------------
    IF ((rec.script_type = 'ENRO' AND rec.script_id = '5001')
        or
        (rec.script_type = 'BAT' AND rec.script_id = '25009'))
    THEN
--dbms_output.put_line('*****************ADFCRM_SCRIPTS get_esn_info_rec.autorefill '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
       --get_esn_info_rec.autorefill := SA.ADFCRM_SCRIPTS.SOLUTION_TOKEN_FUNC(get_esns_rec.esn,null,'[autoreup]');
        if v_autorefill = 'NO'
        then
            open get_program_info(get_esns_rec.esn);
            fetch get_program_info into get_program_info_rec;
            if get_program_info%found then
                v_autorefill := 'YES';
            else
                v_autorefill := 'NO';
            end if;
            close get_program_info;
        end if;
   END IF;
    ---------------------------------------------------------------------
    -- Script for autorefill
    ---------------------------------------------------------------------
    if rec.script_type = 'ENRO' AND rec.script_id = '5001' and v_autorefill = 'NO'
    then
        SHOW_SCRIPT := 'NO';
    end if;
    ---------------------------------------------------------------------
    -- Script for BOGO
    ---------------------------------------------------------------------
    if rec.script_type = 'ACRE' AND rec.script_id = '6384' --BOGO script
    then
        open check_parameter('BOGO=YES');
        fetch check_parameter into check_parameter_rec;
        if check_parameter%notfound
        then
            SHOW_SCRIPT := 'NO';
        end if;
        close check_parameter;
    end if;
        ---------------------------------------------------------------------
    -- Script for BOGO - WFM
    ---------------------------------------------------------------------
    if rec.script_type = 'ACRE' AND rec.script_id = '7388' --BOGO script
    then
        open check_parameter('BOGO=YES');
        fetch check_parameter into check_parameter_rec;
        if check_parameter%notfound
        then
            SHOW_SCRIPT := 'NO';
        end if;
        close check_parameter;
    end if;
    ---------------------------------------------------------------------
    -- Script for ADD NOW CR53046
    ---------------------------------------------------------------------
    if rec.script_type = 'REDE' AND rec.script_id = '194' ----ADD NOW
    then
        open check_parameter('ADD NOW');
        fetch check_parameter into check_parameter_rec;
        if check_parameter%notfound
        then
            SHOW_SCRIPT := 'NO';
        end if;
        close check_parameter;
    end if;
    ---------------------------------------------------------------------
    -- Script for ADD RESERVE CR53046
    ---------------------------------------------------------------------
    if rec.script_type = 'REDE' AND rec.script_id = '195' ----ADD RESERVE
    then
        open check_parameter('ADD RESERVE');
        fetch check_parameter into check_parameter_rec;
        if check_parameter%notfound
        then
            SHOW_SCRIPT := 'NO';
        end if;
        close check_parameter;
    end if;
    ---------------------------------------------------------------------
    -- Script excluded for AUTOREFILL CR53046
    ---------------------------------------------------------------------
    if (rec.script_type = 'BAT' AND rec.script_id = '25009' ---- Remember refill script
        )
        and v_autorefill = 'YES'
    then
        SHOW_SCRIPT := 'NO';
    end if;

    ---------------------------------------------------------------------
    -- Script excluded for SAFELINK  CR53046
    ---------------------------------------------------------------------
    if ((rec.script_type = 'BAT' AND rec.script_id = '25009') or-- Remember refill script
        (rec.script_type = 'BI' AND rec.script_id = '5010') -- download My Account App
        )
        and v_safelink = 'YES'
    then
        SHOW_SCRIPT := 'NO';
    end if;

    --dbms_output.put_line('*****************ADFCRM_SCRIPTS   '||rec.script_type ||' '||rec.script_id ||' '|| ip_language ||' '||get_esn_info_rec.part_class ||' '||ip_sourcesystem||' '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
    ---------------------------------------------------------------------
    --  IF SOLUTION NAME IS RELATED WITH EMAIL AND THE SCRIPT
    --  IS PHONE MODEL DEPENDANT THEN GRAB SCRIPT FROM WEB IF IT EXISTS
    --  8/30/2013 SCRIPTS IN TAS CHANNEL ARE GOOD FOR SENDING EMAIL,  DO NOT APPLY THIS
    ---------------------------------------------------------------------
    --    open part_class_script_cur(REC.script_type
    --                              ,REC.script_id
    --                              ,V_LANGUAGE
    --                              ,GET_ESN_INFO_REC.PART_CLASS
    --                              ,'WEB');
    --    fetch part_class_script_cur into part_class_script_rec;
    -----------------------------------------------------------------------------
    -- CR39151 START
    -- SEND CUSTOMER A WEB VERSION OF THE TS FROM TAS - SYSTEM IMPROVEMENTS
    -- 5/12/16 BAU RELEASE
    -----------------------------------------------------------------------------
       IF  REC.SOLUTION_NAME LIKE '%EMAIL_BODY' --AND part_class_script_cur%found
       THEN
            IP_SOURCESYSTEM := 'WEB';
        END IF;
  -------------------------------------------------------------------------------
  -- CR39151 END
  -------------------------------------------------------------------------------
    --    CLOSE part_class_script_cur;

--dbms_output.put_line('*****************ADFCRM_SCRIPTS************************line 680 '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
    ild_plan_feature := 'NO';
     -------------------------------------------------------------------------
     -- ILD plan dependant script should be displayed only when plan has ILD
     -------------------------------------------------------------------------
     if (rec.script_type = 'ILD' and
         rec.script_id = '153')
        or
        (rec.script_type = 'ILD' and
         rec.script_id = '156')
     then
        if ip_param_list is null and ip_transaction_id is null
        then
            ild_plan_feature := 'NO';
            if check_service_plan_ild = 0
            then
                begin
                    check_service_plan_ild := 1;
                    open v_cursor for select nvl(sa.adfcrm_get_serv_plan_value(xspsp.x_service_plan_id,'ILD'),'NO') service_plan_ild
                                     from  sa.table_site_part          sp
                                          ,sa.x_service_plan_site_part xspsp
                                     where sp.x_service_id = get_esn_info_rec.esn
                                     and   xspsp.table_site_part_id = sp.objid
                                     order by sp.install_date desc;
                    fetch v_cursor into v_service_plan_ild;
                    if v_cursor%notfound then
                        v_service_plan_ild := 'NO';
                    end if;
                    close v_cursor;
                --exception
                    --when others then v_service_plan_ild := 'NO';
                end;
            end if;
            ild_plan_feature := v_service_plan_ild;
        else
            if check_service_plan_ild = 0
            then
                check_service_plan_ild := 1;
                v_service_plan_ild := 'NO';
                if ip_param_list is not null then
                    open get_purchases(ip_param_list);
                    loop
                    fetch get_purchases into get_purchases_rec;
                    exit when get_purchases%notfound or v_service_plan_ild = 'YES';
                         get_ild_feature_rec := get_ild_feature(get_esn_info_rec.part_class,get_purchases_rec.purchase_id,'');
                         v_service_plan_ild := get_ild_feature_rec.ild;
                    end loop;
                    close get_purchases;
                end if;
                if ip_transaction_id is not null and v_service_plan_ild = 'NO' then
                    --Looking for transaction id
                    open get_calls(ip_transaction_id);
                    loop
                    fetch get_calls into get_calls_rec;
                    exit when get_calls%notfound or v_service_plan_ild = 'YES';
                         get_ild_feature_rec := get_ild_feature(get_esn_info_rec.part_class,'',get_calls_rec.call_id);
                         v_service_plan_ild := get_ild_feature_rec.ild;
                    end loop;
                    close get_calls;
                end if;
            end if;
            ild_plan_feature := v_service_plan_ild;
        end if;

        if ild_plan_feature = 'YES'
        then
            if rec.script_id = '153' then
--dbms_output.put_line('*****************ADFCRM_SCRIPTS************************line 759 '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
                if SHOW_SCRIPT = 'YES' then
                    --rec.script_text
                    script_text
                    := get_script_by_class_ss
                                            (rec.script_type
                                            , rec.script_id
                                            , ip_language
                                            , get_esn_info_rec.part_class
                                            , ip_sourcesystem
                                            );
                end if;
               final_script := final_script||script_text;
            elsif rec.script_id = '156' and get_ild_feature_rec.ild_category = 'VAS' then
            -- SCRIPT ILD_156 (DISCLAIMER) SHOULD BE DISPLAYED ONLY WHEN IS RELATED WITH 10$ ILD CARD
--dbms_output.put_line('*****************ADFCRM_SCRIPTS************************line 774 '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
                if SHOW_SCRIPT = 'YES' then
                    --rec.script_text
                    script_text
                    := get_script_by_class_ss
                                            (rec.script_type
                                            , rec.script_id
                                            , ip_language
                                            , get_esn_info_rec.part_class
                                            , ip_sourcesystem
                                            );
                end if;
                final_script := final_script||script_text;
            end if;
        end if;

     else
--dbms_output.put_line('*****************ADFCRM_SCRIPTS************************line 791 '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
        if SHOW_SCRIPT = 'YES' then
            --rec.script_text
            script_text
            := get_script_by_class_ss
                                    (rec.script_type
                                    , rec.script_id
                                    , ip_language
                                    , get_esn_info_rec.part_class
                                    , ip_sourcesystem
                                    );
        end if;

        final_script := final_script||script_text;

     end if;

    end loop;
--dbms_output.put_line('*****************ADFCRM_SCRIPTS************************line 809 '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
    -- Replace token for token value
       final_script := get_text_with_tokens (ip_esn,
                                             get_esn_info_rec.part_class,
                                             ip_transaction_id,
                                             ip_param_list,
                                             ip_language,
                                             final_script,
                                             ip_sourcesystem);
    end if;  --GET_ESN_INFO%FOUND
    close get_esn_info;

--dbms_output.put_line('*****************ADFCRM_SCRIPTS************************line 865 '||to_char(systimestamp,'DD-MON-YYYY HH24:MI:SSFF3'));
    final_script := rtrim(final_script);

    return final_script;
  end solution_script_func;
  --------------------------------------------------------------------------------------------

  function solution_token_func (ip_esn varchar2,ip_params_list varchar2,ip_token varchar2)
  return varchar2
  as
     result varchar2(4000);
     p_call_id  varchar2(4000) := '';
     p_language varchar2(4000) := 'en';
  begin
     result := solution_token_func(ip_esn,p_call_id,ip_params_list,p_language,ip_token);
     return result;
  end;
  --------------------------------------------------------------------------------------------
  function solution_token_func (ip_esn varchar2,
                                ip_call_id varchar2,
                                ip_purchase_id varchar2,
                                ip_language varchar2,
                                ip_token varchar2
                                )
  return varchar2
  as
    plsql_block number;
    sqlstmt sa.adfcrm_solution_script_tokens.token_value%type;
  begin
    -- PARAMS LIST FOR NOW IS ONE PARAMETER, IF THERE IS TO BE MORE THAN ONE THE EXECUTE IMMEDIATE NEEDS TO BE ALTERED
    select  token_value
    into   sqlstmt
    from   adfcrm_solution_script_tokens
    where  token = ip_token;

    if instr(upper(sqlstmt),'BEGIN',1,1) > 0 and  instr(upper(sqlstmt),'END;',1,1) > 0
    then
      plsql_block := 1;
    else
      plsql_block := 0;
    end if;

    if plsql_block = 0
    then

          if instr(replace(sqlstmt,':p_esn',''),':',1,1) = 0 then  --just p_esn variable in the sqlstmt
             execute immediate sqlstmt into sqlstmt using ip_esn;
          else
             if instr(sqlstmt,':',1,3)  = 0  --only 2 variables in the script
             then
                execute immediate sqlstmt into sqlstmt using ip_esn,ip_purchase_id;
             elsif instr(sqlstmt,':',1,4)  > 0  --4 variables in the script
                then
                    execute immediate sqlstmt into sqlstmt using ip_esn,ip_call_id,ip_purchase_id,ip_language;
                else
                    sqlstmt := ip_token;
             end if;
          end if;
    else
      execute immediate sqlstmt using in ip_esn, out sqlstmt;  --just p_esn as input variable in the sqlstmt
    end if;

    if sqlstmt is null then
      sqlstmt := ' ';
    end if;

    return sqlstmt;

  exception
    when others then
      dbms_output.put_line(ip_token ||chr(10)||sqlerrm);
      sqlstmt := ip_token;
      return sqlstmt;
  end solution_token_func;
  --------------------------------------------------------------------------------------------
  function get_text_with_tokens (ip_esn in varchar2,
                                ip_part_class in varchar2,
                                ip_transaction_id in varchar2,
                                ip_param_list in varchar2,
                                ip_language in varchar2,
                                ip_script_text in clob,
                                ip_sourcesystem in varchar2)
  return clob is
    final_script             clob;
    replacement_token        varchar2(4000);
    replacement_token_script varchar2(4000);
  begin
    final_script := ip_script_text;
    -- Replace token for token value when it is found
    -- If token value returned is a script, find the script text
    if instr(final_script,'[',1,1) > 0 and instr(final_script,']',1,1) > 0
    then

    for token in (select token
                 from   adfcrm_solution_script_tokens)
    loop
      if instr(final_script,token.token,1,1) > 0
      then
           replacement_token :=
                                 solution_token_func(
                                ip_esn,
                                ip_transaction_id,
                                ip_param_list,
                                ip_language,
                                token.token
                                );

           replacement_token_script := '';
           if token.token = '['||replacement_token||']' then
              begin
                    select get_script_by_class_ss( x_script_type
                                                  , x_script_id
                                                  , ip_language
                                                  , ip_part_class
                                                  , nvl(ip_sourcesystem,'TAS')
                                                  )
                    into  replacement_token_script
                    from  (select x_script_type, x_script_id
                           from table_x_scripts
                           where x_script_type = SUBSTR(replacement_token,1,INSTR(replacement_token,'_',1,1)-1)
                           and x_script_id = SUBSTR(replacement_token,INSTR(replacement_token,'_',1,1)+1,LENGTH(replacement_token))
                           and rownum < 2);

                   dbms_output.put_line(' replacement_token_script  ===='|| replacement_token_script);
                   final_script := replace(final_script,token.token,replacement_token_script);
              exception
              when others then
                      DBMS_OUTPUT.PUT_LINE(TRIM(SUBSTR(SQLERRM ||CHR(10) ||
                                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                                           ,1,4000)) );
                      final_script := replace(final_script,token.token,replacement_token_script);
              end;
           else
               final_script := replace(final_script
                                      ,token.token
                                      ,replacement_token);
           end if;
      end if;  --if instr(final_script,token.token,1,1) > 0
    end loop;
    end if;  --if instr(final_script,'[',1,1) > 0 and instr(final_script,']',1,1) > 0
    final_script := rtrim(final_script);

    return final_script;
  end get_text_with_tokens;
  --------------------------------------------------------------------------------------------
  function update_ticker (v_tf_script_text in varchar2,
                          v_nt_script_text in varchar2,
                          v_tf_objid in varchar2,
                          v_nt_objid in varchar2,
                          v_login_name in varchar2)
     return varchar2
  is
  begin
     -- UPDATE TRACFONE TICKER
     update table_x_scr
        set x_script_text = v_tf_script_text
      where objid = v_tf_objid;

     -- INSERT HISTORY
     insert into ticker_history
                 (objid
                 ,create_date
                 ,created_by
                 ,script_text
                 ,script_objid
                 )
          values (ticker_history_seq.nextval
                 ,sysdate
                 ,v_login_name
                 ,v_tf_script_text
                 ,v_tf_objid
                 );

     -- UPDATE NET10 TICKER
     update table_x_scr
        set x_script_text = v_nt_script_text
      where objid = v_nt_objid;

     -- INSERT HISTORY
     insert into ticker_history
                 (objid
                 ,create_date
                 ,created_by
                 ,script_text
                 ,script_objid
                 )
          values (ticker_history_seq.nextval
                 ,sysdate
                 ,v_login_name
                 ,v_nt_script_text
                 ,v_nt_objid
                 );

     commit;

     return 'UPDATED TICKER INFORMATION - SUCCESS';
  exception
     when others
     then
        return 'UPDATED TICKER INFORMATION - FAILED - ' || sqlerrm;
  end update_ticker;
  --------------------------------------------------------------------------------------------
FUNCTION get_feature_value(
    p_sp_objid IN NUMBER,
    p_feature  IN VARCHAR2)
  RETURN VARCHAR2
AS
  CURSOR c1
  IS
    SELECT DISTINCT sp_objid,
           fea_name,
           fea_value,
           fea_display
    from sa.adfcrm_serv_plan_feat_matview
    where sp_objid = p_sp_objid
    and   fea_name = p_feature;
    /******* old version
    SELECT DISTINCT Spf.Sp_Feature2service_Plan Sp_Objid,
      Spfvdef.Value_Name Fea_Name,
      spfvdef2.value_name Fea_value,
      spfvdef2.DISPLAY_NAME FEA_DISPLAY
    FROM X_SERVICEPLANFEATUREVALUE_DEF spfvdef,
      X_SERVICEPLANFEATURE_VALUE spfv,
      X_SERVICE_PLAN_FEATURE spf,
      X_Serviceplanfeaturevalue_Def Spfvdef2,
      X_Serviceplanfeaturevalue_Def Spfvdef3
    WHERE spf.sp_feature2rest_value_def = spfvdef.objid
    AND spf.objid                       = spfv.spf_value2spf
    AND Spfvdef2.Objid                  = Spfv.Value_Ref
    AND Spfvdef3.Objid (+)              = Spfv.Child_Value_Ref
    AND Spfvdef.Value_Name              = p_feature
    AND Spf.Sp_Feature2service_Plan     = p_sp_objid;
    *****/

    r1 c1%rowtype;
BEGIN

  OPEN c1;
  FETCH c1 INTO r1;
  IF c1%found THEN
    CLOSE c1;
    RETURN r1.Fea_value;

  ELSE
    CLOSE c1;
    RETURN 'NA';
  END IF;

EXCEPTION
   when others then
      RETURN 'NA';
END get_feature_value;

-----------------------------------------------------------------------------------------------------------------------------


  function get_generic_script  (ip_script_type varchar2,
                                ip_script_id varchar2,
                                ip_language varchar2,
                                ip_sourcesystem  varchar2) return varchar2

  as

    ip_brand_name varchar2(30);
    ip_carrier_id varchar2(10);
    op_objid varchar2(30);
    op_description varchar2(1000);
    op_script_text varchar2(4000);
    op_publish_by varchar2(30);
    op_publish_date date;
    op_sm_link varchar2(300);

    v_language varchar2(30);
    v_sourcesystem     varchar2(30);

  begin

    if ip_sourcesystem is null then
       v_sourcesystem := 'TAS';
    else
       v_sourcesystem := ip_sourcesystem;
    end if;

    if ip_language is null then
       v_language := 'ENGLISH';
    else
       select decode(upper(substr(ip_language,1,2)),'EN','ENGLISH','SPANISH')
       into v_language
       from dual;
    end if;

    scripts_pkg.get_script_prc(
      ip_sourcesystem => v_sourcesystem,
      ip_brand_name => 'GENERIC',
      ip_script_type => ip_script_type,
      ip_script_id => ip_script_id,
      ip_language => v_language,
      ip_carrier_id => null,
      ip_part_class => null,
      op_objid =>   op_objid,
      op_description => op_description,
      op_script_text => op_script_text,
      op_publish_by => op_publish_by,
      op_publish_date => op_publish_date,
      op_sm_link => op_sm_link
    );

    return op_script_text;

  end get_generic_script;


  --------------------------------------------------------------------------------------------

  function get_plan_description (p_sp_objid in number, p_language in varchar2, p_sourcesystem in varchar2) return varchar2


     --Get Generic Script Description Associated to Service Plan
     --'GENERIC'
     --Script_type+Script_id stored as SHORT_SCRIPT in Service Plan features
     --If the script is not found the regular sp description will be returned.

  as
     cursor c1 is
     select * from x_service_plan
     where objid = p_sp_objid;

     r1 c1%rowtype;

     v_script_type varchar2(100);
     v_script_id varchar2(100);
     v_short_script varchar2(100);
     v_description varchar2(300);
     v_script varchar2(4000);
     v_language varchar2(100);

  begin
    select decode(upper(substr(nvl(p_language,'EN'),1,2)),'EN','ENGLISH','SPANISH')
    into   v_language
    from   dual;

    open c1;
    fetch c1 into r1;
    if c1%found then
       v_description := r1.DESCRIPTION;
       v_script := v_description;
       v_short_script := get_feature_value(r1.objid,'SHORT_SCRIPT');

       if v_short_script <> 'NA' then
          v_script_type := substr(v_short_script,1,instr(v_short_script,'_')-1);
          v_script_id := substr(v_short_script,instr(v_short_script,'_')+1);
          v_script := get_generic_script(v_script_type,v_script_id,v_language,p_sourcesystem);

          if v_script like 'SCRIPT MISSING%' then
             v_script:=v_description;
          end if;
       end if;
    else
       v_script := null;
    end if;
    close c1;
    return v_script;

  end get_plan_description;

--*******************************************************************************************
  function get_script_message(ip_function varchar2,            --USE THE FUNCTIONALITY NAME
                                ip_flow varchar2,                --USE THE PERMISSION NAME TO ACCESS THE PAGE, DEFAULT ALL
                                ip_language varchar2,            --ENGLISH,SPANISH
                                ip_sourcesystem  varchar2,       --TAS
                                ip_esn varchar2,
                                ip_pin_value varchar2            --pin part number or red code
                                ) return varchar2 is
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_language varchar2(100);
        v_error    varchar2(100);
        v_solution_name  varchar2(100);
        v_type     varchar2(100);
        v_message  varchar2(4000);
        ip_pin_part_number varchar2(100);
        op_script_text varchar2(4000);

        cursor get_esn_info(ip_esn varchar2) is
            select  pi.part_serial_no esn,
                    pc.name part_class,
                    bo.org_id,
                    nvl(xof.x_ild_plus,'N') x_ild_plus,
                    sa.get_param_by_name_fun(pc.name,'TECHNOLOGY')  technology,
                    pi.x_part_inst_status
            from    table_part_inst pi,
                    table_mod_level ml,
                    table_part_num pn,
                    table_part_class pc,
                    table_bus_org bo,
                    table_x_ota_features xof
            where pi.part_serial_no = ip_esn
            and   pi.x_domain = 'PHONES'
            and   ml.objid = pi.n_part_inst2part_mod
            and   pn.objid = ml.part_info2part_num
            and   pc.objid = pn.part_num2part_class
            and   bo.objid = pn.part_num2bus_org
            and   xof.x_ota_features2part_inst (+) = pi.objid;

        get_esn_info_rec    get_esn_info%rowtype;

        cursor get_pin_part_number (ip_pin_value varchar2) is
            select  pn.part_number
            from    table_part_inst pi,
                    table_mod_level ml,
                    table_part_num pn
            where pi.x_red_code = ip_pin_value
            and   pi.x_domain = 'REDEMPTION CARDS'
            and   ml.objid = pi.n_part_inst2part_mod
            and   pn.objid = ml.part_info2part_num;

        get_pin_part_number_rec get_pin_part_number%rowtype;

        cursor get_part_number_info (ip_part_number varchar2) is
            select nvl(sa.adfcrm_get_serv_plan_value(spc.sp_objid,'ILD_ROAM'),'NO') ild_roam,
                   sa.adfcrm_serv_plan.getServPlanGroupType(spc.sp_objid)  plan_group,
                   nvl(sa.adfcrm_get_serv_plan_value(spc.sp_objid,'CARRIER_BUCKET_DOM_INTL_FLAG'),'NO') carrier_bucket_flag
            from    table_part_num pn,
                    table_part_class pc,
                    sa.adfcrm_serv_plan_class_matview spc
            where pn.part_number = ip_part_number
            and   pc.objid = pn.part_num2part_class
            and   spc.part_class_objid (+) = pc.objid
            ;

        get_part_number_info_rec    get_part_number_info%rowtype;

        cursor get_esn_plan_info (ip_esn varchar2) is
            select xsp.objid,
                   sa.adfcrm_serv_plan.getServPlanGroupType(xsp.objid)  plan_group
            from  sa.table_site_part          sp
                 ,sa.x_service_plan_site_part xspsp
                 ,sa.x_service_plan           xsp
            where sp.x_service_id =  ip_esn
            and xspsp.table_site_part_id (+) = sp.objid
            and xsp.objid (+) = xspsp.x_service_plan_id
            order by sp.install_date desc;

        get_esn_plan_info_rec    get_esn_plan_info%rowtype;

        cursor get_carrier (ip_esn varchar2) is
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
         and   pi.part_serial_no = ip_esn
         and   pi.x_domain = 'PHONES'
         ;

        get_carrier_rec get_carrier%rowtype;

        p_service_plan_objid varchar2(200);
        p_service_type varchar2(200);
        p_program_type varchar2(200);
        p_next_charge_date date;
        p_program_units number;
        p_program_days number;
        p_error_num number;
    BEGIN
        v_error := '';
        v_solution_name := '';

        if upper(ip_language) in ('ES','SPANISH')
        then
           v_language := 'SPANISH';
        else
           v_language := 'ENGLISH';
        end if;

        open get_esn_info(ip_esn);
        fetch get_esn_info into get_esn_info_rec;
        if get_esn_info%notfound
        then
            v_message := 'Error: ESN provided does not exist in our database';
            return v_message;
        end if;
        close get_esn_info;

        open get_esn_plan_info(ip_esn);
        fetch get_esn_plan_info into get_esn_plan_info_rec;
        if get_esn_plan_info%notfound
        then
            --v_message := 'Error: adfcrm_scriptsget_script_message MIN does not exist in table_site_part';
            null;
        end if;
        close get_esn_plan_info;

        open get_carrier(ip_esn);
        fetch get_carrier into get_carrier_rec;

        if ip_pin_value is not null then
            open get_pin_part_number(ip_pin_value);
            fetch get_pin_part_number into get_pin_part_number_rec;
            if get_pin_part_number%found
            then
                ip_pin_part_number := get_pin_part_number_rec.part_number;
            else
                ip_pin_part_number := ip_pin_value;
            end if;
            close get_pin_part_number;

            open get_part_number_info(ip_pin_part_number);
            fetch get_part_number_info into get_part_number_info_rec;
            if get_part_number_info%notfound
            then
                v_message := 'Error: PIN provided does not exist in our database';
                return v_message;
            end if;
            close get_part_number_info;
        end if;

        if get_esn_info_rec.technology = 'CDMA' then
            if get_part_number_info_rec.ild_roam = 'YES'  --Redemption card allows roaming
            then
                if get_esn_info_rec.x_ild_plus = 'N' then
                    v_type := 'Warning: ';
                    v_error := '-5000';
                    v_message := 'ESN provided will not be able to use the roaming functionality included in the chosen airtime';
                end if;
            else
                if get_esn_info_rec.x_ild_plus = 'Y' then
                    v_type := 'Warning: ';
                    v_error := '-5001';
                    v_message := 'Your phone is elegible to redeem airtime including roaming';
                end if;
            end if;
        end if;

        if get_esn_info_rec.x_part_inst_status = '52' then
            if nvl(v_error,'###') = '###' and
               get_esn_plan_info_rec.plan_group = 'PAYGO' and
               get_part_number_info_rec.plan_group = 'UNLIMITED'
            then
                v_type := 'Warning: ';
                v_error := '-5002';
                v_message := 'PayGo to UNLIMITED';
            end if;

            if nvl(v_error,'###') = '###' and
               get_esn_plan_info_rec.plan_group = 'UNLIMITED' and
               get_part_number_info_rec.plan_group = 'PAYGO'
            then
                v_type := 'Warning: ';
                v_error := '-5003';
                v_message := 'UNLIMITED to PayGo';
            end if;

            if nvl(v_error,'###') in ('-5002','-5003')
            then
                --Check if customer is enrolled in refill program
                sa.phone_pkg.get_program_info(
                   p_esn => ip_esn,
                   p_service_plan_objid => p_service_plan_objid,
                   p_service_type => p_service_type,
                   p_program_type => p_program_type,
                   p_next_charge_date => p_next_charge_date,
                   p_program_units => p_program_units,
                   p_program_days => p_program_days,
                   p_error_num => p_error_num
                );

                if p_program_type is not null
                then
                    v_error := '';
                    v_solution_name := 'WARNING_ENROLLMENT_SWITCH';
                    v_message := v_message||'. Customer is enrolled in refill program';
                end if;
            end if;
        end if;

        if get_part_number_info_rec.carrier_bucket_flag = 'YES' and
           get_carrier_rec.x_queue_name <> 'T-MOBILE'
        then
                    v_type := 'Warning: ';
                    v_error := '-5100';
                    v_message := 'Please note that Roaming in Mexico only applies to some phone models and is not available for your phone.';
        end if;

        if nvl(v_error,'###') != '###' then
            begin
                sa.scripts_pkg.get_error_map_script(ip_func_name => ip_function,
                                            ip_flow_name => nvl(ip_flow,'ALL'),
                                            ip_error_code => v_error,
                                            ip_default_msg => v_message,
                                            ip_default_script_id => null,
                                            ip_brand => get_esn_info_rec.org_id,
                                            ip_language => v_language,
                                            ip_source_system => 'TAS',
                                            ip_part_class => get_esn_info_rec.part_class,
                                            ip_replace_tokens => 'Y',
                                            op_script_text => op_script_text);
                commit;
            exception
                when others then
                    v_message := 'Error: Calling sa.scripts_pkg.get_error_map_script '||sqlcode;
                    return v_message;
            end;
        end if;

        if nvl(v_solution_name,'###') != '###' then
            op_script_text := solution_script_func(v_solution_name,
                                                   ip_esn,
                                                   v_language,
                                                   null);
        end if;

        return v_type||nvl(op_script_text,v_message);
    END get_script_message;

--********************************************************************************************

  --CR32952 new function get_generic_brand_script
  function get_generic_brand_script  (ip_script_type varchar2,
                                ip_script_id varchar2,
                                ip_language varchar2,
                                ip_sourcesystem  varchar2,
                                ip_brand_name varchar2)
  return varchar2
  as
    ip_carrier_id varchar2(10);
    op_objid varchar2(30);
    op_description varchar2(1000);
    op_script_text varchar2(4000);
    op_publish_by varchar2(30);
    op_publish_date date;
    op_sm_link varchar2(300);

    v_language varchar2(30);
    v_sourcesystem     varchar2(30);

  begin

    if ip_sourcesystem is null then
       v_sourcesystem := 'TAS';
    else
       v_sourcesystem := ip_sourcesystem;
    end if;

    if ip_language is null then
       v_language := 'ENGLISH';
    else
       select decode(upper(substr(ip_language,1,2)),'EN','ENGLISH','SPANISH')
       into v_language
       from dual;
    end if;

    scripts_pkg.get_script_prc(
      ip_sourcesystem => v_sourcesystem,
      ip_brand_name => ip_brand_name,
      ip_script_type => ip_script_type,
      ip_script_id => ip_script_id,
      ip_language => v_language,
      ip_carrier_id => null,
      ip_part_class => null,
      op_objid =>   op_objid,
      op_description => op_description,
      op_script_text => op_script_text,
      op_publish_by => op_publish_by,
      op_publish_date => op_publish_date,
      op_sm_link => op_sm_link
    );

    return op_script_text;

  end get_generic_brand_script;

  function get_plan_desc_frm_cvge_script (p_sp_objid in number, p_language in varchar2, p_sourcesystem in varchar2) return varchar2


     --Get Coverage Script Description Associated to Service Plan
     --'COVERAGE_SCRIPT'
     --Script_type+Script_id stored as COVERAGE_SCRIPT in Service Plan features
     --If the script is not found the regular sp description will be returned.

  as
     cursor c1 is
     select * from x_service_plan
     where objid = p_sp_objid;

     r1 c1%rowtype;

     v_script_type varchar2(100);
     v_script_id varchar2(100);
     v_short_script varchar2(100);
     v_description varchar2(300);
     v_script varchar2(4000);
     v_language varchar2(100);

  begin
    select decode(upper(substr(nvl(p_language,'EN'),1,2)),'EN','ENGLISH','SPANISH')
    into   v_language
    from   dual;

    open c1;
    fetch c1 into r1;
    if c1%found then
       v_description := r1.DESCRIPTION;
       v_script := v_description;
       v_short_script := get_feature_value(r1.objid,'COVERAGE_SCRIPT');

       if v_short_script <> 'NA' then
          v_script_type := substr(v_short_script,1,instr(v_short_script,'_')-1);
          v_script_id := substr(v_short_script,instr(v_short_script,'_')+1);
          v_script := get_generic_script(v_script_type,v_script_id,v_language,p_sourcesystem);

          if v_script like 'SCRIPT MISSING%' then
             v_script:=v_description;
          end if;
       end if;
    else
       v_script := null;
    end if;
    close c1;
    return v_script;

  end get_plan_desc_frm_cvge_script;



  function get_alert_block_script (ip_permission in varchar2,
                                   ip_alert_title in varchar2,
                                   ip_esn in varchar2,
                                   ip_language in varchar2,
                                   ip_sourcesystem in varchar2) return varchar2 as


      -- 1 KEYWORD FOUND IN THE ALERT TEXT WILL RETURN A BLOCKING SCRIPT

      cursor c1(c1_title varchar2) is
      select script_type,script_id,keywords
      from sa.adfcrm_solution
      where access_type = -2
      and solution_name = 'BLOCK_'||ip_permission
      and instr(upper(keywords),upper(c1_title))>0
      and instr(phone_status,(select x_part_inst_status from sa.table_part_inst where part_serial_no = ip_esn and x_domain = 'PHONES'))>0;

      r1 c1%rowtype;
      script_text varchar2(4000):='false';  --false--> Continue Process

      v_title clob;

  begin

    v_title := ip_alert_title;
    v_title := substr(substr(v_title,instr(v_title,'- ')+2),0,instr(substr(v_title,instr(v_title,'- ')+2),'<')-1);
    --dbms_output.put_line(v_title);

     open c1(c1_title => v_title);
     fetch c1 into r1;
     if c1%found then
         --dbms_output.put_line(r1.script_type||'_'||r1.script_id||' - '||r1.keywords);
         script_text := get_generic_script  (r1.script_type,r1.script_id,ip_language,ip_sourcesystem);
     end if;
     close c1;

     return script_text;

     exception when others then
        return 'false';

  end get_alert_block_script;

  function get_script_brand(ip_pc varchar2)
  return varchar2
  is
    ip_brand_name varchar2(30);
  begin
      ip_brand_name := sa.get_param_by_name_fun(ip_pc,'BUS_ORG');
      if ip_brand_name = 'SIMPLE_MOBILE' then
        begin
          select decode(count(*),'1','GO_SMART',ip_brand_name) sb
          into ip_brand_name
          from pc_params_view
          where param_name ='SUB_BRAND'
          and PARAM_VALUE = 'GO_SMART'
          and part_class = ip_pc;
        exception
          when others then
            null;
        end;
      end if;

      return ip_brand_name;
  end get_script_brand;

  function get_script_brand(ip_pc_objid number)
  return varchar2
  is
    ip_brand_name varchar2(30);
    v_pc varchar2(30);
  begin
      select name
      into v_pc
      from table_part_class
      where objid = ip_pc_objid;

      ip_brand_name := sa.get_param_by_name_fun(v_pc,'BUS_ORG');
      if ip_brand_name = 'SIMPLE_MOBILE' then
        begin
          select decode(count(*),'1','GO_SMART',ip_brand_name) sb
          into ip_brand_name
          from pc_params_view
          where param_name ='SUB_BRAND'
          and PARAM_VALUE = 'GO_SMART'
          and pc_objid = ip_pc_objid;
        exception
          when others then
            null;
        end;
      end if;

      return ip_brand_name;
  end get_script_brand;

end adfcrm_scripts;
/