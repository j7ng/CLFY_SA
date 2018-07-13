CREATE OR REPLACE package body sa.reward_benefits_n_vouchers_pkg as
/*
Project:  CR 32367 - Upgrade plans phase-2
Date started : 16-march-2015
*/
  lv_voucher_expiry_timeout   number := null;
  lv_token_expiry_timeout     number := null;
  lv_token_without_vouchers   varchar2(50) := null;
  lv_benefit_type             constant varchar2(50) := 'UPGRADE_BENEFITS';
  lc_point_category_reward    constant varchar2(50) := 'REWARD_POINTS';

  /* VS:05/06/2015 commenting to let deactived ESNS show point trasaction
  --cursor fetches specific min/esn details by checking if its active or not
  cursor cur_esn_min_dtl(in_key in varchar2, in_value in varchar2)
    is
      select
        pn.part_num2bus_org     as bus_org_objid,
        tsp.objid               as site_part_objid,
        tsp.x_service_id        as x_esn,
        tsp.x_min               as x_min,
        spsp.x_service_plan_id  as service_plan_objid
      from
        table_part_inst pi,
        table_mod_level ml,
        table_part_num pn,
        table_site_part tsp,
        x_service_plan_site_part spsp
      where 1=1
      and pi.part_serial_no = tsp.x_service_id
      and pi.x_domain = 'PHONES'
      and pi.n_part_inst2part_mod = ml.objid
      and ml.part_info2part_num = pn.objid
      and tsp.part_status || '' = 'Active'
      and tsp.x_min not like 'T%'
      and tsp.objid = spsp.table_site_part_id
      and (
              (in_key = 'ESN' and tsp.x_service_id  = in_value )
           or (in_key = 'MIN' and tsp.x_min         = in_value )
          )
      ;
  */
  cursor cur_esn_min_dtl(in_key in varchar2, in_value in varchar2)
    is
      select bus_org_objid, site_part_objid, x_esn, x_min, service_plan_objid
    from (
    select
        pn.part_num2bus_org     as bus_org_objid,
        tsp.objid               as site_part_objid,
        tsp.x_service_id        as x_esn,
        tsp.x_min               as x_min,
        spsp.x_service_plan_id  as service_plan_objid,
        row_number() over (partition by tsp.x_service_id order by tsp.update_stamp desc) esn_order,
        row_number() over (partition by tsp.x_min order by tsp.update_stamp desc) min_order
      from
        table_part_inst pi,
        table_mod_level ml,
        table_part_num pn,
        table_site_part tsp,
        x_service_plan_site_part spsp
      where 1=1
      and pi.part_serial_no = tsp.x_service_id
      and pi.x_domain = 'PHONES'
      and pi.n_part_inst2part_mod = ml.objid
      and ml.part_info2part_num = pn.objid
      and tsp.x_min not like 'T%'
      and tsp.objid = spsp.table_site_part_id
      and (
              (in_key = 'ESN' and tsp.x_service_id  = in_value )
           or (in_key = 'MIN' and tsp.x_min         = in_value )
          )
          )
    where ((in_key = 'ESN' and esn_order = 1)or (in_key = 'MIN' and min_order = 1))
      ;



  cursor cur_voucher_token (in_token in varchar2) is
      select
        vat.rowid as token_rowid
        ,vat.x_token_id
        ,vat.x_token_status
        ,vat.vendor_id
        ,vat.x_expiration_date
        ,vat.x_created_date
      from x_voucher_access_token vat
      where 1=1
      and vat.x_token_id = in_token ;

  cursor cur_vouchers (in_token in varchar2) is
    select
      rowid as voucher_rowid
      , objid as voucher_objid
      , voucher_id
      , x_token_id
      , x_created_date
      , x_expiration_date
      , x_voucher_status
      , x_vouchers2benefit    as benefit_objid
      , x_vouchers2order_hdr  as order_objid
    from table_x_vouchers
    where 1=1
    and x_token_id = in_token ;

  type typ_voucher_tab is table of cur_vouchers%rowtype index by pls_integer;

  cursor cur_txn_vouchers (in_trans_id in number)
   is
  select
  tv.rowid as voucher_rowid,
  tv.objid as voucher_objid,
  tv.voucher_id,
  tv.x_token_id,
  tv.x_created_date,
  tv.x_expiration_date
      , tv.x_voucher_status
      , tv.x_vouchers2benefit    as benefit_objid
      , tv.x_vouchers2order_hdr  as order_objid
       from
          table_x_vouchers tv,
          table_x_voucher_transactions tvt
          where tv.objid = tvt.voucher_trans2voucher
          and  tvt.transaction_id = in_trans_id;


  function f_get_unique_id
  return varchar2
  is
  begin
    return randomuuid;
    --this function is used to generate a random unique string
    --this unique value can be used as new voucher id / token id / etc
  end;

  function f_get_transaction_id
  return number
  is
  begin
    return
      to_number (
                     to_char(seq_voucher_transactions.nextval)
                    || to_char(trunc(dbms_random.value(1,99999999)))
                    || to_char(sysdate,'rrdddsssss')
                );
  exception
    when others then
      sa.ota_util_pkg.err_log (
        p_action => 'OTHERS EXCEPTION',
        p_error_date => sysdate,
        p_key => 'CR32367',
        p_program_name => 'f_get_transaction_id',
        p_error_text =>
               'unable to generate new transaction ID...'
              || ', sqlerrm='|| substr(sqlerrm,1,300)
              );

      return null;
  end f_get_transaction_id;

  function f_get_parameter_value (in_parameter in varchar2)
  return table_x_parameters.x_param_value%TYPE
  is
    lv_value table_x_parameters.x_param_value%TYPE;
  begin
    select x_param_value
    into lv_value
    from table_x_parameters
    where x_param_name = in_parameter ;

    return lv_value;
  exception
    when others then
      dbms_output.put_line('Parameter Value not found or is not Numeric for input Parameter name=' || in_parameter);
      return null;
  end f_get_parameter_value;

  procedure p_validate_input_token  ( in_token        in varchar2
                                    , in_vendor_id  in varchar2
                                    , out_err_code  out number
                                    , out_err_msg   out varchar2
                                  )
  is
    pragma autonomous_transaction;
    rec_token cur_voucher_token%rowtype;
    --this is internal procedure - used within this pkg only
  begin

    --check if input token is used or expired

    --check if input token is for input vendor only
    --if not then log transaction and return

    open cur_voucher_token(in_token);
    fetch cur_voucher_token into rec_token;
    close cur_voucher_token;


    if rec_token.x_token_id is null then
        out_err_code  :=  -316;
        out_err_msg   :=  'Error. Input token [' ||in_token || '] not found in database';

    elsif nvl(rec_token.vendor_id,'~') != nvl(in_vendor_id,'~') then
      out_err_code        := -317;
      out_err_msg         := 'Error. Input Vendor [' || in_vendor_id || '] dont have access to Input token [' ||in_token || '] ';

    elsif rec_token.x_token_status = '942' then
      out_err_code        := -318;
      out_err_msg         := 'Error. Input token [' ||in_token || '] is already used. Cannot be used again';

    elsif rec_token.x_expiration_date <= sysdate and rec_token.x_token_status != '964' then --964=EXPIRED

      update x_voucher_access_token
      set x_token_status = '964' ---964=EXPIRED
      where rowid = rec_token.token_rowid;

      out_err_code        := -319;
      out_err_msg         := 'Error. Input token [' ||in_token || '] is expired';

    else

      --if rec_token.x_token_status = '941' and rec_token.x_expiration_date > sysdate then
        --in this case only the voucher list should be returned
      update x_voucher_access_token
      set x_token_status = '942'
      where rowid = rec_token.token_rowid;

      out_err_code        := 0;
      out_err_msg         := 'SUCCESS';
    end if;

    commit;

--    dbms_output.put_line('*** out_err_code=' || out_err_code
--    ||', db vendor='|| nvl(rec_token.vendor_id,'~')
--    ||', input vendor='|| nvl(in_vendor_id,'~')
--    );
  exception
    when others then
      rollback;
      out_err_code := -99;
      out_err_msg := 'Unable to validate input token=' || in_token || ' : err='|| sqlerrm;
  end p_validate_input_token;


    procedure p_create_reward_benefits_nobon (
          in_min          in varchar2 default null
          ,out_err_code   out integer
          ,out_err_msg    out varchar2
  )
  is
  /*
  this procedure will read the total points that are accumulated
  and if eligible it will create the reward benefits for that points
  after reward benefits are created points get reset.
  CR 32367
  03/17/2015
  */
  cursor cur_total_points (in_date in date) is
    select  pa.rowid, pa.*, rpv.x_conversion_points
    from table_x_point_account pa
      , (   select distinct bus_org_objid, x_conversion_points
            from x_reward_point_values
            where 1=1
            and x_point_category = lc_point_category_reward
            and sysdate between x_start_date and x_end_date
          )
        rpv
    where 1=1
    and (pa.x_min = in_min or in_min is null)
    and pa.x_last_calc_date >= in_date
    and pa.x_points_category = lc_point_category_reward
    and pa.account_status = 'ACTIVE'
    and pa.total_points >= rpv.x_conversion_points
    and pa.bus_org_objid = rpv.bus_org_objid
    ;

  /*CR35343:070815: Changed benefit creation logic to use plan benefit value.*/
  cursor cur_point_serv_plan_used (in_point_acc_objid in number,
                                       in_esn in varchar2)
   is
   with esn_serv_plan
          as
         (select distinct x2.sp_objid,
                y.FEA_DISPLAY,
                y.FEA_NAME,
                y.FEA_VALUE,
                y.SP_MKT_NAME
           from
             table_part_inst pi,
          sa.TABLE_MOD_LEVEL ML2,
         sa.TABLE_PART_NUM PN2 ,
          adfcrm_serv_plan_CLASS_matview x2,
          adfcrm_serv_plan_feat_matview y
          where
           pi.PART_SERIAL_NO = in_esn
          and ML2.OBJID = PI.N_PART_INST2PART_MOD
          and pn2.objid = ml2.part_info2part_num
          and x2.part_class_objid   = PN2.PART_NUM2PART_CLASS
          and y.fea_name   = lc_point_category_reward
          and y.sp_objid  = x2.sp_objid
          ),
          ded_plans as(
             select esp.sp_objid as plan_used,
            pt.point_trans2service_plan,
            abs(pt.x_points),
            pt.point_trans2point_account,
            row_number() over (partition by esp.sp_objid order by esp.sp_objid) rnum
           from table_x_point_trans pt,
                 esn_serv_plan  esp
          where 1=1
          and pt.point_trans2point_account = in_point_acc_objid
          and pt.x_points_category  =lc_point_category_reward
          and pt.x_points_action          in ( 'DEDUCT')
          and pt.point_trans2service_plan is not null
          and  abs(pt.x_points) = esp.fea_value
           and pt.point_trans2benefit      is null ) ,
      serv_plan as
          ( select pts.*
             , sum(pts.x_points) over (order by pts.x_trans_date ,pts.objid  rows between unbounded preceding and current row) cumm_points
             from
             ( select
             esp.sp_objid plan_used,
            to_number(bp.x_benefit_value) x_benefit_value,
            pt.point_trans2service_plan,
            x_points,
            pt.point_trans2point_account,
            row_number() over (partition by esp.sp_objid order by esp.sp_objid) rnum,
            pt.objid,
            pt.x_trans_date
           from table_x_point_trans pt,
                 esn_serv_plan  esp,
                 table_x_point_account pa,
                 x_reward_point_values rpv,
                 table_x_benefit_programs bp
          where 1=1
          and pt.point_trans2point_account = in_point_acc_objid
          and pt.x_points_category  = lc_point_category_reward
           and pt.x_points_action          in ('ADD', 'ESNUPGRADE')
         and  pt.point_trans2service_plan is not null
          and   pt.x_points  = esp.fea_value
          and  pt.point_trans2point_account = pa.objid
          and  pa.bus_org_objid = rpv.bus_org_objid
          and  esp.sp_objid = rpv.service_plan_objid
          and  pt.x_points_category  = rpv.x_point_category
          and rpv.benefit_program_objid = bp.objid
          and sysdate between rpv.x_start_date and rpv.x_end_date
           and pt.point_trans2benefit      is null
           union /*CR35343: 070715 union for bonus points*/
           select null plan_used , to_number(bp.x_benefit_value) x_benefit_value,  pt.point_trans2service_plan,
             x_points,
            pt.point_trans2point_account,
            rownum rnum,
            pt.objid,
            pt.x_trans_date
          from table_x_point_trans pt,
                 table_x_point_account pa,
                 x_reward_point_values rpv,
                 table_x_benefit_programs bp
          where pt.POINT_TRANS2POINT_ACCOUNT = in_point_acc_objid
                and pt.point_trans2service_plan is null
                and pt.x_points_action  ='ADD'
                and pt.x_points_category = 'BONUS_POINTS'
                and rpv.x_point_category = pt.x_points_category
                and  nvl(pt.point_trans2service_plan, -999) = nvl(rpv.service_plan_objid, -999)
                and  pt.point_trans2point_account = pa.objid
                and  pa.bus_org_objid = rpv.bus_org_objid
                and rpv.benefit_program_objid = bp.objid
                and sysdate between rpv.x_start_date and rpv.x_end_date
                and pt.point_trans2benefit      is null  ) pts
           where not exists
           (select 1
              from  ded_plans dp
              where
              dp.plan_used = pts.plan_used
              and
              dp.rnum = pts.rnum
            )
           )
            select distinct x.x_benefit_value,
            count(nvl(x.x_benefit_value, -999)) over (partition by nvl(x.x_benefit_value, -999) )  as plan_frequency
         from serv_plan x
        where x.cumm_points <=
          (select min(cumm_points) from serv_plan spx where spx.cumm_points >= 18
          )
          and x.plan_used is not null;



    type typ_points_tab is table of cur_total_points%rowtype index by pls_integer;

    points_tab                typ_points_tab ;
    lv_service_plan_used      number;
    lv_benefit_value          number;
    lv_service_plan_frequency number;
    lv_service_plan_priority  number;
    lv_benefit_program_id     number;
    lv_x_benefits_objid       number;
    lv_limit_point_objid      number;
    lv_benefit_owner          table_x_benefits.x_benefit_owner_value%type;
    lv_err_code               number;
    lv_err_msg                varchar2(2000);
    lv_benefit_service_plan   number;

  begin
  /*
  find all MINs whcih has collected 18 or more points
  for each MIN, find the most frequently used service plan
  get the reward benefit program name based on service plan, brand and priority
  */

      begin
       DBMS_OUTPUT.PUT_LINE ('Inside create benefits');
        open cur_total_points(sysdate-1);
        loop
          fetch cur_total_points bulk collect into points_tab limit 500;
          exit when points_tab.count = 0;
          DBMS_OUTPUT.PUT_LINE(' in_min= ' || in_min || ' points_tab.count=' || points_tab.count);
          -----raise no_data_found;

          for i in 1..points_tab.count loop
            --start processing each point account
            --if one fails, skip it and continue processing next record
            begin
              lv_benefit_value          := 0;
              lv_service_plan_used      := 0;
              lv_service_plan_frequency := 0;
              lv_service_plan_priority  := 0;
              lv_benefit_program_id     := null;

               dbms_output.put_line(' loop started.....points_tab(i).objid= ' || points_tab(i).objid );

              --find out which plan is used most no. of times to collect 18(or whatever is max.value) points
              --if its a tie then get the priority from the table

               /*CR35343 change to address QC2358 : added x_esn to input*/
              for jrec in cur_point_serv_plan_used (points_tab(i).objid, points_tab(i).x_esn)
              loop
                  dbms_output.put_line('checking the serv.plan');
                  begin
                     dbms_output.put_line('jrec.plan_frequency:'||jrec.plan_frequency);

                    if jrec.plan_frequency > lv_service_plan_frequency
                    then
                     /*CR35343:070815: using benefit value to identify benefit program*/
                      lv_benefit_value          := jrec.x_benefit_value;
                      lv_service_plan_frequency := jrec.plan_frequency;
                      lv_service_plan_priority  := null;
                      --no need to check priority here since its clear that what plan is used

                    elsif jrec.plan_frequency = lv_service_plan_frequency then
                     /*CR35343:070815: using benefit value to identify benefit program*/
                      if (lv_benefit_value  > jrec.x_benefit_value or lv_benefit_value  = jrec.x_benefit_value)
                      then
                      null;
                      elsif jrec.x_benefit_value > lv_benefit_value
                      then
                      lv_benefit_value := jrec.x_benefit_value ;
                      end if;

                     end if;

                    dbms_output.put_line('lv_benefit_value:'||lv_benefit_value);
                    dbms_output.put_line('lv_service_plan_used:'||lv_service_plan_used);
                    dbms_output.put_line('lv_benefit_program_id:'||lv_benefit_program_id);
                    dbms_output.put_line('lv_service_plan_priority:'||lv_service_plan_priority);

                  exception
                    when no_data_found then
                      dbms_output.put_line(
                      'NO DATA FOUND .....points_tab(i).objid= ' || points_tab(i).objid
                      || ', lv_service_plan_used='||lv_service_plan_used
                       || ', brand='|| points_tab(i).bus_org_objid
                      );

                      raise no_data_found;
                  end;

              end loop;

              /*CR35343:070815: using benefit value to identify benefit program*/

              if lv_benefit_value is not null then

                select min(bp.objid)
                into lv_benefit_program_id
                from table_x_benefit_programs bp
                 where bp.benefit_program2bus_org = points_tab(i).bus_org_objid
                  and bp.X_benefit_value = to_char(lv_benefit_value);

                begin
                /*CR35343: 071415: fetching the service plan to associate to benefit*/
                    WITH esn_serv_plan AS
                    (SELECT DISTINCT x2.sp_objid,
                      y.FEA_DISPLAY,
                      y.FEA_NAME,
                      y.FEA_VALUE,
                      y.SP_MKT_NAME
                    FROM table_part_inst pi,
                      sa.TABLE_MOD_LEVEL ML2,
                      sa.TABLE_PART_NUM PN2 ,
                      adfcrm_serv_plan_CLASS_matview x2,
                      adfcrm_serv_plan_feat_matview y
                    WHERE pi.PART_SERIAL_NO = points_tab(i).x_esn
                    AND ML2.OBJID           = PI.N_PART_INST2PART_MOD
                    AND pn2.objid           = ml2.part_info2part_num
                    AND x2.part_class_objid = PN2.PART_NUM2PART_CLASS
                    AND y.fea_name          = lc_point_category_reward
                    AND y.sp_objid          = x2.sp_objid
                    ) ,
                    serv_plan AS
                    (SELECT esp.sp_objid ,
                      row_number() over (partition BY esp.sp_objid order by esp.sp_objid) rnum
                    FROM table_x_point_trans pt,
                      esn_serv_plan esp
                    WHERE 1=1
                    AND pt.point_trans2point_account = points_tab(i).objid
                    AND esp.FEA_VALUE                = pt.x_points
                      -- CR35343:070715 in condition to handle bonus points
                    AND pt.x_points_category = lc_point_category_reward
                    AND pt.x_points_action  IN ('ADD', 'ESNUPGRADE')
                      -- CR35343:070715 added or condition to handle bonus points
                    AND pt.point_trans2service_plan IS NOT NULL
                    AND pt.point_trans2benefit      IS NULL
                    MINUS
                    SELECT esp.sp_objid ,
                      row_number() over (partition BY esp.sp_objid order by esp.sp_objid) rnum
                    FROM table_x_point_trans pt,
                      esn_serv_plan esp
                    WHERE 1=1
                    AND pt.point_trans2point_account = points_tab(i).objid
                    AND esp.FEA_VALUE                = ABS(pt.x_points)
                     AND pt.x_points_category = lc_point_category_reward
                    AND pt.x_points_action  IN ( 'DEDUCT')
                     AND pt.point_trans2service_plan IS NOT NULL
                    AND pt.point_trans2benefit      IS NULL
                    UNION
                    -- CR35343:071415 to handle bonus points
                    SELECT NULL ,
                      rownum rnum
                    FROM table_x_point_trans pt
                    WHERE 1=1
                    AND pt.point_trans2point_account = points_tab(i).objid
                     AND pt.x_points_category = 'BONUS_POINTS'
                    AND pt.x_points_action   = 'ADD'
                     AND pt.point_trans2benefit IS NULL
                    )
                  SELECT MIN(sp_objid)
                  INTO lv_benefit_service_plan
                  FROM
                    (SELECT sp.*,
                      COUNT(*) over (partition BY sp_objid) sp_cnt
                    FROM serv_plan sp ,
                      x_reward_point_values rpv,
                      table_x_benefit_programs tbp
                    WHERE NVL(rpv.service_plan_objid, -999) = NVL(sp.sp_objid, -999)
                    AND rpv.bus_org_objid                   = points_tab(i).bus_org_objid
                    AND tbp.objid                           = rpv.benefit_program_objid
                    AND rpv.bus_org_objid                   = tbp.benefit_program2bus_org
                    AND tbp.x_benefit_value                 = lv_benefit_value
                    ) ;

                   exception
                   when others then
                   lv_benefit_service_plan := null;
                   end;

              end if;

              /*
              if lv_benefit_value is not null then
                select min(bp.objid)
                into lv_benefit_program_id
                from table_x_benefit_programs bp
                    ,x_reward_point_values rpv
                where rpv.benefit_program_objid = bp.objid
                  and rpv.bus_org_objid = points_tab(i).bus_org_objid
                  and bp.X_benefit_value = to_char(lv_benefit_value);
              end if;  */



              --finally, here we got the right benefit to be given to customer
              --insert in table_x_benefits with status AVAILABLE
              if lv_benefit_program_id is not null then

                 if (points_tab(i).subscriber_uid is not null )
                 then
                     lv_benefit_owner:= points_tab(i).subscriber_uid;
                 else
                     --dbms_output.put_line ('GET_RBEN going to call GET_SUB');
                      p_get_subscriber_id (
                        in_key               => 'ESN'
                        ,in_value            => points_tab(i).x_esn
                        ,out_subscriber_id   => lv_benefit_owner
                        ,out_err_code        => lv_err_code
                        ,out_err_msg         => lv_err_msg
                        ) ;
                 end if;

                begin
                  lv_x_benefits_objid :=  seq_x_benefits.nextval;
                  --dbms_output.put_line('step 1');
                  insert into table_x_benefits
                    (
                      objid,
                      x_benefit_owner_type,
                      x_benefit_owner_value,
                      x_created_date,
                      x_status,
                      x_notes,
                      benefits2benefit_program,
                      x_update_date
                    )
                    values
                    (
                     lv_x_benefits_objid
                      ,'SID'
                      ,lv_benefit_owner
                      ,sysdate
                      ,'961'    --AVAILABLE
                      ,'Benefits created since total reward points are = ' || points_tab(i).total_points
                      ,lv_benefit_program_id
                      ,sysdate -- added on 052815 to support ETL/Reports team req.
                    );
                    --dbms_output.put_line('step 2');
                    --update the existing point_trans records to identify
                    --which points were considered to create the benefit
                    --this is useful in future for refund transactions

                    /*vs:05/03/2015: Adding the next select block to get the last
                     of the points record that were used in the benefit creation.
                      This record will help in identifying the point records that
                      need to be associated to the benefit that got created above*/
                    with point_trans as
                    (
                       select   pt.objid,
                        sum(x_points) over (order by pt.X_TRANS_DATE, pt.objid ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) cumm_points
                        from table_x_point_trans pt
                        where 1=1
                        and pt.point_trans2point_account = points_tab(i).objid
                        -- CR35343:070715 in condition to handle bonus points
                        and pt.x_points_category in ( lc_point_category_reward, 'BONUS_POINTS')
                        and pt.x_points_action in ('ADD', 'ESNUPGRADE', 'DEDUCT')
                        -- CR35343:070715 added or condition to handle bonus points
                        and (pt.point_trans2service_plan is not null or pt.x_points_category = 'BONUS_POINTS')
                        and pt.point_trans2benefit is null
                    )
                    select max(objid)
                    into lv_limit_point_objid
                    from point_trans x
                    where  x.cumm_points <= (select min(cumm_points) from point_trans ptx where ptx.cumm_points >= 18)
                    order by 1 desc;

                    dbms_output.put_line('lv_limit_point_objid: '||lv_limit_point_objid);
                    dbms_output.put_line('lv_x_benefits_objid: '||lv_x_benefits_objid);

                    update table_x_point_trans
                    set point_trans2benefit = lv_x_benefits_objid
                    where 1=1
                    and point_trans2point_account = points_tab(i).objid
                    --below conditions should be exactly same as that in cursor: cur_point_serv_plan_used
                    -- CR35343:070715 in condition to handle bonus points
                    and x_points_category in ( lc_point_category_reward, 'BONUS_POINTS')
                    ---and x_points_action in ('ADD', 'ESNUPGRADE')
                    and objid <= lv_limit_point_objid --vs:adding this to limit point update to what points actually got used
                    -- CR35343:070715 added or condition to handle bonus points
                    and (point_trans2service_plan is not null or x_points_category = 'BONUS_POINTS')
                    and point_trans2benefit is null
                    ;

                   -- dbms_output.put_line('step 2.1  rows updated in point_trans after limit change=' || sql%rowcount);

                   -- dbms_output.put_line('step 3');
                    --remove the 18 points from total points since they are converted to benefit
                    update table_x_point_account
                    set total_points = total_points - points_tab(i).x_conversion_points
                    ,account_status_reason =  'Most recently, '
                      || points_tab(i).x_conversion_points
                      || ' Points converted to benefit on: '
                      || to_char(sysdate, 'dd-mon-rrrr hh24:mi:sssss')
                      || ', benefit objid=' || lv_x_benefits_objid
                    ,x_last_calc_date = sysdate
                    where objid = points_tab(i).objid ;

                   -- dbms_output.put_line('step 4');
                    --log the activity of subtracting the total points and to notify when the benefit was created
                    insert into table_x_point_trans (
                      objid,
                      x_trans_date,
                      x_min,
                      x_esn,
                      x_points,
                      x_points_category,
                      x_points_action,
                      points_action_reason,
                      point_trans2ref_table_objid,
                      ref_table_name,
                      point_trans2service_plan,
                      point_trans2point_account,
                      point_trans2purchase_objid,
                      purchase_table_name,
                      point_trans2site_part,
                      point_trans2benefit,
                      point_display_reason
                      )
                    values (
                      sa.seq_x_point_trans.nextval
                      ,sysdate
                      ,points_tab(i).x_min
                      ,points_tab(i).x_esn
                      ,-1 * points_tab(i).x_conversion_points
                      ,points_tab(i).x_points_category
                      ,'CONVERT'
                      ,points_tab(i).x_conversion_points || ' Points converted to benefit on: '
                          || to_char(sysdate, 'dd-mon-rrrr hh24:mi:sssss')
                          ||', benefit objid=' || lv_x_benefits_objid
                      ,lv_x_benefits_objid
                      ,'TABLE_X_BENEFITS'
                      ,lv_benefit_service_plan ----serv.plan used max.# of times to create this benefit
                       ,points_tab(i).objid
                      ,null
                      ,null
                      ,(select max(objid)
                          from table_site_part
                          where x_min = points_tab(i).x_min
                          and x_service_id=points_tab(i).x_esn
                          and part_status='Active'
                          )
                      ,lv_x_benefits_objid
                      ,'Converted to Benefit'
                      );
                    --- commit;;
                    --dbms_output.put_line('Step 5 Hurray...benefit created');
                end;
              end if;
            exception
              when others then
                rollback;

            end;
          end loop;

        end loop;

      end;

      --- commit;;
      out_err_code    := 0;
      out_err_msg     := 'SUCCESS';
  exception
      when others then
        rollback;
        dbms_output.put_line(' ERR=' ||
        substr(dbms_utility.format_error_backtrace,1,500));
        out_err_code    := sqlcode;
        out_err_msg     := 'p_create_reward_benefits='||substr(sqlerrm, 1, 200);
  end p_create_reward_benefits_nobon  ;

  /*CR35343:070815: Changed benefit creation logic to use plan benefit value.*/
  procedure p_create_reward_benefits  (
          in_min          in varchar2 default null
          ,out_err_code   out integer
          ,out_err_msg    out varchar2
  )
  is
  /*
  this procedure will read the total points that are accumulated
  and if eligible it will create the reward benefits for that points
  after reward benefits are created points get reset.
  CR 32367
  03/17/2015
  */
  cursor cur_total_points (in_date in date) is
    select  pa.rowid, pa.*, rpv.x_conversion_points
    from table_x_point_account pa
      , (   select distinct bus_org_objid, x_conversion_points
            from x_reward_point_values
            where 1=1
            and x_point_category = lc_point_category_reward
            and sysdate between x_start_date and x_end_date
          )
        rpv
    where 1=1
    and (pa.x_min = in_min or in_min is null)
    and pa.x_last_calc_date >= in_date
    and pa.x_points_category = lc_point_category_reward
    and pa.account_status = 'ACTIVE'
    and pa.total_points >= rpv.x_conversion_points
    and pa.bus_org_objid = rpv.bus_org_objid
    ;

  /*CR35343:070815: Changed benefit creation logic to use plan benefit value.*/
  cursor cur_point_serv_plan_used (in_point_acc_objid in number,
                                       in_esn in varchar2)
   is
   with esn_serv_plan
          as
         (select distinct x2.sp_objid,
                y.FEA_DISPLAY,
                y.FEA_NAME,
                y.FEA_VALUE,
                y.SP_MKT_NAME
           from
             table_part_inst pi,
          sa.TABLE_MOD_LEVEL ML2,
         sa.TABLE_PART_NUM PN2 ,
          adfcrm_serv_plan_CLASS_matview x2,
          adfcrm_serv_plan_feat_matview y
          where
           pi.PART_SERIAL_NO = in_esn
          and ML2.OBJID = PI.N_PART_INST2PART_MOD
          and pn2.objid = ml2.part_info2part_num
          and x2.part_class_objid   = PN2.PART_NUM2PART_CLASS
          and y.fea_name   = lc_point_category_reward
          and y.sp_objid  = x2.sp_objid
          ),
          ded_plans as(
             select esp.sp_objid as plan_used,
            pt.point_trans2service_plan,
            abs(pt.x_points),
            pt.point_trans2point_account,
            row_number() over (partition by esp.sp_objid order by esp.sp_objid) rnum
           from table_x_point_trans pt,
                 esn_serv_plan  esp
          where 1=1
          and pt.point_trans2point_account = in_point_acc_objid
          and pt.x_points_category  =lc_point_category_reward
          and pt.x_points_action          in ( 'DEDUCT')
          and pt.point_trans2service_plan is not null
          and  abs(pt.x_points) = esp.fea_value
           and pt.point_trans2benefit      is null ) ,
      serv_plan as
          ( select pts.*
             , sum(pts.x_points) over (order by pts.x_trans_date ,pts.objid  rows between unbounded preceding and current row) cumm_points
             from
             ( select
             esp.sp_objid plan_used,
            to_number(bp.x_benefit_value) x_benefit_value,
            pt.point_trans2service_plan,
            x_points,
            pt.point_trans2point_account,
            row_number() over (partition by esp.sp_objid order by esp.sp_objid) rnum,
            pt.objid,
            pt.x_trans_date
           from table_x_point_trans pt,
                 esn_serv_plan  esp,
                 table_x_point_account pa,
                 x_reward_point_values rpv,
                 table_x_benefit_programs bp
          where 1=1
          and pt.point_trans2point_account = in_point_acc_objid
          and pt.x_points_category  = lc_point_category_reward
           and pt.x_points_action          in ('ADD', 'ESNUPGRADE')
         and  pt.point_trans2service_plan is not null
          and   pt.x_points  = esp.fea_value
          and  pt.point_trans2point_account = pa.objid
          and  pa.bus_org_objid = rpv.bus_org_objid
          and  esp.sp_objid = rpv.service_plan_objid
          and  pt.x_points_category  = rpv.x_point_category
          and rpv.benefit_program_objid = bp.objid
          and sysdate between rpv.x_start_date and rpv.x_end_date
           and pt.point_trans2benefit      is null
           union /*CR35343: 070715 union for bonus points*/
           select null plan_used , to_number(bp.x_benefit_value) x_benefit_value,  pt.point_trans2service_plan,
             x_points,
            pt.point_trans2point_account,
            rownum rnum,
            pt.objid,
            pt.x_trans_date
          from table_x_point_trans pt,
                 table_x_point_account pa,
                 x_reward_point_values rpv,
                 table_x_benefit_programs bp
          where pt.POINT_TRANS2POINT_ACCOUNT = in_point_acc_objid
                and pt.point_trans2service_plan is null
                and pt.x_points_action  ='ADD'
                and pt.x_points_category = 'BONUS_POINTS'
                and rpv.x_point_category = pt.x_points_category
                and  nvl(pt.point_trans2service_plan, -999) = nvl(rpv.service_plan_objid, -999)
                and  pt.point_trans2point_account = pa.objid
                and  pa.bus_org_objid = rpv.bus_org_objid
                and rpv.benefit_program_objid = bp.objid
                and sysdate between rpv.x_start_date and rpv.x_end_date
                and pt.point_trans2benefit      is null  ) pts
           where not exists
           (select 1
              from  ded_plans dp
              where
              dp.plan_used = pts.plan_used
              and
              dp.rnum = pts.rnum
            )
           )
            select distinct x.x_benefit_value,
            count(nvl(x.x_benefit_value, -999)) over (partition by nvl(x.x_benefit_value, -999) )  as plan_frequency
         from serv_plan x
        where x.cumm_points <=
          (select min(cumm_points) from serv_plan spx where spx.cumm_points >= 18
          );



    type typ_points_tab is table of cur_total_points%rowtype index by pls_integer;

    points_tab                typ_points_tab ;
    lv_service_plan_used      number;
    lv_benefit_value          number;
    lv_service_plan_frequency number;
    lv_service_plan_priority  number;
    lv_benefit_program_id     number;
    lv_x_benefits_objid       number;
    lv_limit_point_objid      number;
    lv_benefit_owner          table_x_benefits.x_benefit_owner_value%type;
    lv_err_code               number;
    lv_err_msg                varchar2(2000);
    lv_benefit_service_plan   number;

  begin
  /*
  find all MINs whcih has collected 18 or more points
  for each MIN, find the most frequently used service plan
  get the reward benefit program name based on service plan, brand and priority
  */

      begin
       DBMS_OUTPUT.PUT_LINE ('Inside create benefits');
        open cur_total_points(sysdate-1);
        loop
          fetch cur_total_points bulk collect into points_tab limit 500;
          exit when points_tab.count = 0;
          DBMS_OUTPUT.PUT_LINE(' in_min= ' || in_min || ' points_tab.count=' || points_tab.count);
          -----raise no_data_found;

          for i in 1..points_tab.count loop
            --start processing each point account
            --if one fails, skip it and continue processing next record
            begin
              lv_benefit_value          := 0;
              lv_service_plan_used      := 0;
              lv_service_plan_frequency := 0;
              lv_service_plan_priority  := 0;
              lv_benefit_program_id     := null;

               dbms_output.put_line(' loop started.....points_tab(i).objid= ' || points_tab(i).objid );

              --find out which plan is used most no. of times to collect 18(or whatever is max.value) points
              --if its a tie then get the priority from the table

               /*CR35343 change to address QC2358 : added x_esn to input*/
              for jrec in cur_point_serv_plan_used (points_tab(i).objid, points_tab(i).x_esn)
              loop
                  dbms_output.put_line('checking the serv.plan');
                  begin
                     dbms_output.put_line('jrec.plan_frequency:'||jrec.plan_frequency);

                    if jrec.plan_frequency > lv_service_plan_frequency
                    then
                     /*CR35343:070815: using benefit value to identify benefit program*/
                      lv_benefit_value          := jrec.x_benefit_value;
                      lv_service_plan_frequency := jrec.plan_frequency;
                      lv_service_plan_priority  := null;
                      --no need to check priority here since its clear that what plan is used

                    elsif jrec.plan_frequency = lv_service_plan_frequency then
                     /*CR35343:070815: using benefit value to identify benefit program*/
                      if (lv_benefit_value  > jrec.x_benefit_value or lv_benefit_value  = jrec.x_benefit_value)
                      then
                      null;
                      elsif jrec.x_benefit_value > lv_benefit_value
                      then
                      lv_benefit_value := jrec.x_benefit_value ;
                      end if;

                     end if;

                    dbms_output.put_line('lv_benefit_value:'||lv_benefit_value);
                    dbms_output.put_line('lv_service_plan_used:'||lv_service_plan_used);
                    dbms_output.put_line('lv_benefit_program_id:'||lv_benefit_program_id);
                    dbms_output.put_line('lv_service_plan_priority:'||lv_service_plan_priority);

                  exception
                    when no_data_found then
                      dbms_output.put_line(
                      'NO DATA FOUND .....points_tab(i).objid= ' || points_tab(i).objid
                      || ', lv_service_plan_used='||lv_service_plan_used
                       || ', brand='|| points_tab(i).bus_org_objid
                      );

                      raise no_data_found;
                  end;

              end loop;

              /*CR35343:070815: using benefit value to identify benefit program*/

              if lv_benefit_value is not null then

                select min(bp.objid)
                into lv_benefit_program_id
                from table_x_benefit_programs bp
                 where bp.benefit_program2bus_org = points_tab(i).bus_org_objid
                  and bp.X_benefit_value = to_char(lv_benefit_value);

                begin
                /*CR35343: 071415: fetching the service plan to associate to benefit*/
                    WITH esn_serv_plan AS
                    (SELECT DISTINCT x2.sp_objid,
                      y.FEA_DISPLAY,
                      y.FEA_NAME,
                      y.FEA_VALUE,
                      y.SP_MKT_NAME
                    FROM table_part_inst pi,
                      sa.TABLE_MOD_LEVEL ML2,
                      sa.TABLE_PART_NUM PN2 ,
                      adfcrm_serv_plan_CLASS_matview x2,
                      adfcrm_serv_plan_feat_matview y
                    WHERE pi.PART_SERIAL_NO = points_tab(i).x_esn
                    AND ML2.OBJID           = PI.N_PART_INST2PART_MOD
                    AND pn2.objid           = ml2.part_info2part_num
                    AND x2.part_class_objid = PN2.PART_NUM2PART_CLASS
                    AND y.fea_name          = lc_point_category_reward
                    AND y.sp_objid          = x2.sp_objid
                    ) ,
                    serv_plan AS
                    (SELECT esp.sp_objid ,
                      row_number() over (partition BY esp.sp_objid order by esp.sp_objid) rnum
                    FROM table_x_point_trans pt,
                      esn_serv_plan esp
                    WHERE 1=1
                    AND pt.point_trans2point_account = points_tab(i).objid
                    AND esp.FEA_VALUE                = pt.x_points
                      -- CR35343:070715 in condition to handle bonus points
                    AND pt.x_points_category = lc_point_category_reward
                    AND pt.x_points_action  IN ('ADD', 'ESNUPGRADE')
                      -- CR35343:070715 added or condition to handle bonus points
                    AND pt.point_trans2service_plan IS NOT NULL
                    AND pt.point_trans2benefit      IS NULL
                    MINUS
                    SELECT esp.sp_objid ,
                      row_number() over (partition BY esp.sp_objid order by esp.sp_objid) rnum
                    FROM table_x_point_trans pt,
                      esn_serv_plan esp
                    WHERE 1=1
                    AND pt.point_trans2point_account = points_tab(i).objid
                    AND esp.FEA_VALUE                = ABS(pt.x_points)
                     AND pt.x_points_category = lc_point_category_reward
                    AND pt.x_points_action  IN ( 'DEDUCT')
                     AND pt.point_trans2service_plan IS NOT NULL
                    AND pt.point_trans2benefit      IS NULL
                    UNION
                    -- CR35343:071415 to handle bonus points
                    SELECT NULL ,
                      rownum rnum
                    FROM table_x_point_trans pt
                    WHERE 1=1
                    AND pt.point_trans2point_account = points_tab(i).objid
                     AND pt.x_points_category = 'BONUS_POINTS'
                    AND pt.x_points_action   = 'ADD'
                     AND pt.point_trans2benefit IS NULL
                    )
                  SELECT MIN(sp_objid)
                  INTO lv_benefit_service_plan
                  FROM
                    (SELECT sp.*,
                      COUNT(*) over (partition BY sp_objid) sp_cnt
                    FROM serv_plan sp ,
                      x_reward_point_values rpv,
                      table_x_benefit_programs tbp
                    WHERE NVL(rpv.service_plan_objid, -999) = NVL(sp.sp_objid, -999)
                    AND rpv.bus_org_objid                   = points_tab(i).bus_org_objid
                    AND tbp.objid                           = rpv.benefit_program_objid
                    AND rpv.bus_org_objid                   = tbp.benefit_program2bus_org
                    AND tbp.x_benefit_value                 = lv_benefit_value
                    ) ;

                   exception
                   when others then
                   lv_benefit_service_plan := null;
                   end;

              end if;

              /*
              if lv_benefit_value is not null then
                select min(bp.objid)
                into lv_benefit_program_id
                from table_x_benefit_programs bp
                    ,x_reward_point_values rpv
                where rpv.benefit_program_objid = bp.objid
                  and rpv.bus_org_objid = points_tab(i).bus_org_objid
                  and bp.X_benefit_value = to_char(lv_benefit_value);
              end if;  */



              --finally, here we got the right benefit to be given to customer
              --insert in table_x_benefits with status AVAILABLE
              if lv_benefit_program_id is not null then

                 if (points_tab(i).subscriber_uid is not null )
                 then
                     lv_benefit_owner:= points_tab(i).subscriber_uid;
                 else
                     --dbms_output.put_line ('GET_RBEN going to call GET_SUB');
                      p_get_subscriber_id (
                        in_key               => 'ESN'
                        ,in_value            => points_tab(i).x_esn
                        ,out_subscriber_id   => lv_benefit_owner
                        ,out_err_code        => lv_err_code
                        ,out_err_msg         => lv_err_msg
                        ) ;
                 end if;

                begin
                  lv_x_benefits_objid :=  seq_x_benefits.nextval;
                  --dbms_output.put_line('step 1');
                  insert into table_x_benefits
                    (
                      objid,
                      x_benefit_owner_type,
                      x_benefit_owner_value,
                      x_created_date,
                      x_status,
                      x_notes,
                      benefits2benefit_program,
                      x_update_date
                    )
                    values
                    (
                     lv_x_benefits_objid
                      ,'SID'
                      ,lv_benefit_owner
                      ,sysdate
                      ,'961'    --AVAILABLE
                      ,'Benefits created since total reward points are = ' || points_tab(i).total_points
                      ,lv_benefit_program_id
                      ,sysdate -- added on 052815 to support ETL/Reports team req.
                    );
                    --dbms_output.put_line('step 2');
                    --update the existing point_trans records to identify
                    --which points were considered to create the benefit
                    --this is useful in future for refund transactions

                    /*vs:05/03/2015: Adding the next select block to get the last
                     of the points record that were used in the benefit creation.
                      This record will help in identifying the point records that
                      need to be associated to the benefit that got created above*/
                    with point_trans as
                    (
                       select   pt.objid,
                        sum(x_points) over (order by pt.X_TRANS_DATE, pt.objid ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) cumm_points
                        from table_x_point_trans pt
                        where 1=1
                        and pt.point_trans2point_account = points_tab(i).objid
                        -- CR35343:070715 in condition to handle bonus points
                        and pt.x_points_category in ( lc_point_category_reward, 'BONUS_POINTS')
                        and pt.x_points_action in ('ADD', 'ESNUPGRADE', 'DEDUCT')
                        -- CR35343:070715 added or condition to handle bonus points
                        and (pt.point_trans2service_plan is not null or pt.x_points_category = 'BONUS_POINTS')
                        and pt.point_trans2benefit is null
                    )
                    select max(objid)
                    into lv_limit_point_objid
                    from point_trans x
                    where  x.cumm_points <= (select min(cumm_points) from point_trans ptx where ptx.cumm_points >= 18)
                    order by 1 desc;

                    dbms_output.put_line('lv_limit_point_objid: '||lv_limit_point_objid);
                    dbms_output.put_line('lv_x_benefits_objid: '||lv_x_benefits_objid);

                    update table_x_point_trans
                    set point_trans2benefit = lv_x_benefits_objid
                    where 1=1
                    and point_trans2point_account = points_tab(i).objid
                    --below conditions should be exactly same as that in cursor: cur_point_serv_plan_used
                    -- CR35343:070715 in condition to handle bonus points
                    and x_points_category in ( lc_point_category_reward, 'BONUS_POINTS')
                    ---and x_points_action in ('ADD', 'ESNUPGRADE')
                    and objid <= lv_limit_point_objid --vs:adding this to limit point update to what points actually got used
                    -- CR35343:070715 added or condition to handle bonus points
                    and (point_trans2service_plan is not null or x_points_category = 'BONUS_POINTS')
                    and point_trans2benefit is null
                    ;

                   -- dbms_output.put_line('step 2.1  rows updated in point_trans after limit change=' || sql%rowcount);

                   -- dbms_output.put_line('step 3');
                    --remove the 18 points from total points since they are converted to benefit
                    update table_x_point_account
                    set total_points = total_points - points_tab(i).x_conversion_points
                    ,account_status_reason =  'Most recently, '
                      || points_tab(i).x_conversion_points
                      || ' Points converted to benefit on: '
                      || to_char(sysdate, 'dd-mon-rrrr hh24:mi:sssss')
                      || ', benefit objid=' || lv_x_benefits_objid
                    ,x_last_calc_date = sysdate
                    where objid = points_tab(i).objid ;

                   -- dbms_output.put_line('step 4');
                    --log the activity of subtracting the total points and to notify when the benefit was created
                    insert into table_x_point_trans (
                      objid,
                      x_trans_date,
                      x_min,
                      x_esn,
                      x_points,
                      x_points_category,
                      x_points_action,
                      points_action_reason,
                      point_trans2ref_table_objid,
                      ref_table_name,
                      point_trans2service_plan,
                      point_trans2point_account,
                      point_trans2purchase_objid,
                      purchase_table_name,
                      point_trans2site_part,
                      point_trans2benefit,
                      point_display_reason
                      )
                    values (
                      sa.seq_x_point_trans.nextval
                      ,sysdate
                      ,points_tab(i).x_min
                      ,points_tab(i).x_esn
                      ,-1 * points_tab(i).x_conversion_points
                      ,points_tab(i).x_points_category
                      ,'CONVERT'
                      ,points_tab(i).x_conversion_points || ' Points converted to benefit on: '
                          || to_char(sysdate, 'dd-mon-rrrr hh24:mi:sssss')
                          ||', benefit objid=' || lv_x_benefits_objid
                      ,lv_x_benefits_objid
                      ,'TABLE_X_BENEFITS'
                      ,lv_benefit_service_plan ----serv.plan used max.# of times to create this benefit
                       ,points_tab(i).objid
                      ,null
                      ,null
                      ,(select max(objid)
                          from table_site_part
                          where x_min = points_tab(i).x_min
                          and x_service_id=points_tab(i).x_esn
                          and part_status='Active'
                          )
                      ,lv_x_benefits_objid
                      ,'Converted to Benefit'
                      );
                    --- commit;;
                    --dbms_output.put_line('Step 5 Hurray...benefit created');
                end;
              end if;
            exception
              when others then
                rollback;

            end;
          end loop;

        end loop;

      end;

      --- commit;;
      out_err_code    := 0;
      out_err_msg     := 'SUCCESS';
  exception
      when others then
        rollback;
        dbms_output.put_line(' ERR=' ||
        substr(dbms_utility.format_error_backtrace,1,500));
        out_err_code    := sqlcode;
        out_err_msg     := 'p_create_reward_benefits='||substr(sqlerrm, 1, 200);
  end p_create_reward_benefits  ;


procedure p_create_reward_benefits_old (
          in_min          in varchar2 default null
          ,out_err_code   out integer
          ,out_err_msg    out varchar2
  )
  is
  /*
  this procedure will read the total points that are accumulated
  and if eligible it will create the reward benefits for that points
  after reward benefits are created points get reset.
  CR 32367
  03/17/2015
  */
  cursor cur_total_points (in_date in date) is
    select  pa.rowid, pa.*, rpv.x_conversion_points
    from table_x_point_account pa
      , (   select distinct bus_org_objid, x_conversion_points
            from x_reward_point_values
            where 1=1
            and x_point_category = lc_point_category_reward
            and sysdate between x_start_date and x_end_date
          )
        rpv
    where 1=1
    and (pa.x_min = in_min or in_min is null)
    and pa.x_last_calc_date >= in_date
    and pa.x_points_category = lc_point_category_reward
    and pa.account_status = 'ACTIVE'
    and pa.total_points >= rpv.x_conversion_points
    and pa.bus_org_objid = rpv.bus_org_objid
    ;

    /* commenting this code to remove it after testing is successful with new code
    cursor cur_point_serv_plan_used (in_point_acc_objid in number) is
      select  distinct pt.point_trans2service_plan as plan_used,
      count(point_trans2service_plan) over (partition by pt.point_trans2service_plan order by pt.point_trans2service_plan )
      as plan_frequency
      from table_x_point_trans pt
      where 1=1
      and pt.point_trans2point_account = in_point_acc_objid ---99807 --rtrp
      and pt.x_points_category = lc_point_category_reward
      ---and pt.x_points > 0
      and pt.x_points_action in ('ADD', 'ESNUPGRADE', 'DEDUCT')
      and pt.point_trans2service_plan is not null
      and pt.point_trans2benefit is null
      ;

      cursor cur_point_serv_plan_used (in_point_acc_objid in number)
        is
        with serv_plan as
          (select pt.point_trans2service_plan as plan_used,
            count(point_trans2service_plan) over (partition by pt.point_trans2service_plan order by pt.point_trans2service_plan ) as plan_frequency,
            sum(x_points) over (order by pt.x_trans_date ,pt.objid  rows between unbounded preceding and current row) cumm_points,
            pt.x_trans_date
          from table_x_point_trans pt
          where 1=1
          and pt.point_trans2point_account = in_point_acc_objid
          and pt.x_points_category         = lc_point_category_reward
            ---and pt.x_points > 0
          and pt.x_points_action          in ('ADD', 'ESNUPGRADE', 'DEDUCT')
          and pt.point_trans2service_plan is not null
          and pt.point_trans2benefit      is null
          )
        select distinct x.plan_used, x.plan_frequency
        from serv_plan x
        where x.cumm_points <=
          (select min(cumm_points) from serv_plan spx where spx.cumm_points >= 18
          );
         */

       /*VS:062915:CR35343 changes to get the exact service plan used in point
         accumulation*/
      /* cursor cur_point_serv_plan_used (in_point_acc_objid in number)
        is
           with serv_plan as
          (select pt.point_trans2service_plan as plan_used,
            x_points,
            pt.x_esn,
            pt.point_trans2service_plan,
            sum(x_points) over (order by pt.x_trans_date ,pt.objid  rows between unbounded preceding and current row) cumm_points,
            pt.x_trans_date
          from table_x_point_trans pt
          where 1=1
          and pt.point_trans2point_account = in_point_acc_objid
          and pt.x_points_category         = lc_point_category_reward
            ---and pt.x_points > 0
          and pt.x_points_action          in ('ADD', 'ESNUPGRADE', 'DEDUCT')
          and pt.point_trans2service_plan is not null
          and pt.point_trans2benefit      is null
          )
          , esn_serv_plan
          as
         (select distinct x2.sp_objid,
                y.FEA_DISPLAY,
                y.FEA_NAME,
                y.FEA_VALUE,
                y.SP_MKT_NAME
           from
             table_part_inst pi,
          sa.TABLE_MOD_LEVEL ML2,
         sa.TABLE_PART_NUM PN2 ,
          adfcrm_serv_plan_CLASS_matview x2,
          adfcrm_serv_plan_feat_matview y,
          serv_plan sp
          where
           pi.PART_SERIAL_NO = sp.x_esn
          and ML2.OBJID = PI.N_PART_INST2PART_MOD
          and pn2.objid = ml2.part_info2part_num
          and x2.part_class_objid   = PN2.PART_NUM2PART_CLASS
          and y.fea_name   = lc_point_category_reward
          and y.sp_objid  = x2.sp_objid
          )
        select distinct esp.sp_objid plan_used,
               count(esp.sp_objid) over (partition by esp.sp_objid ) as plan_frequency
         from serv_plan x, esn_serv_plan esp
        where x.cumm_points <=
          (select min(cumm_points) from serv_plan spx where spx.cumm_points >= 18
          )
          and  x.x_points = esp.fea_value
          ;*/

      /*CR35343 change to address QC2358*/
      cursor cur_point_serv_plan_used (in_point_acc_objid in number,
                                       in_esn in varchar2)
      is
      with esn_serv_plan
          as
         (select distinct x2.sp_objid,
                y.FEA_DISPLAY,
                y.FEA_NAME,
                y.FEA_VALUE,
                y.SP_MKT_NAME
           from
             table_part_inst pi,
          sa.TABLE_MOD_LEVEL ML2,
         sa.TABLE_PART_NUM PN2 ,
          adfcrm_serv_plan_CLASS_matview x2,
          adfcrm_serv_plan_feat_matview y
          where
           pi.PART_SERIAL_NO = in_esn
          and ML2.OBJID = PI.N_PART_INST2PART_MOD
          and pn2.objid = ml2.part_info2part_num
          and x2.part_class_objid   = PN2.PART_NUM2PART_CLASS
          and y.fea_name   = lc_point_category_reward
          and y.sp_objid  = x2.sp_objid
          ),
          ded_plans as(
             select esp.sp_objid as plan_used,
            pt.point_trans2service_plan,
            abs(pt.x_points),
            pt.point_trans2point_account,
            row_number() over (partition by esp.sp_objid order by esp.sp_objid) rnum
           from table_x_point_trans pt,
                 esn_serv_plan  esp
          where 1=1
          and pt.point_trans2point_account = in_point_acc_objid
          and pt.x_points_category  =lc_point_category_reward
          and pt.x_points_action          in ( 'DEDUCT')
          and pt.point_trans2service_plan is not null
          and  abs(pt.x_points) = esp.fea_value
           and pt.point_trans2benefit      is null ) ,
      serv_plan as
          ( select pts.*
             , sum(pts.x_points) over (order by pts.x_trans_date ,pts.objid  rows between unbounded preceding and current row) cumm_points
             from
             ( select
            esp.sp_objid as plan_used,
            pt.point_trans2service_plan,
            x_points,
            pt.point_trans2point_account,
            row_number() over (partition by esp.sp_objid order by esp.sp_objid) rnum,
            pt.objid,
            pt.x_trans_date
           from table_x_point_trans pt,
                 esn_serv_plan  esp
          where 1=1
          and pt.point_trans2point_account = in_point_acc_objid
          and pt.x_points_category  = lc_point_category_reward
           and pt.x_points_action          in ('ADD', 'ESNUPGRADE')
         and  pt.point_trans2service_plan is not null
          and   pt.x_points  = esp.fea_value
           and pt.point_trans2benefit      is null
           union /*CR35343: 070715 union for bonus points*/
           select null,  pt.point_trans2service_plan,
             x_points,
            pt.point_trans2point_account,
            rownum rnum,
            pt.objid,
            pt.x_trans_date
          from table_x_point_trans pt
          where pt.POINT_TRANS2POINT_ACCOUNT = in_point_acc_objid
                and pt.point_trans2service_plan is null
                and pt.x_points_action  ='ADD'
                and pt.x_points_category = 'BONUS_POINTS'
                and pt.point_trans2benefit      is null  ) pts
           where not exists
           (select 1
              from  ded_plans dp
              where
              dp.plan_used = pts.plan_used
              and
              dp.rnum = pts.rnum
            )
           )
            select distinct x.plan_used plan_used,
               count(nvl(x.plan_used, -999)) over (partition by nvl(x.plan_used, -999) ) as plan_frequency
         from serv_plan x
        where x.cumm_points <=
          (select min(cumm_points) from serv_plan spx where spx.cumm_points >= 18
          )
          ;


    type typ_points_tab is table of cur_total_points%rowtype index by pls_integer;

    points_tab                typ_points_tab ;
    lv_service_plan_used      number;
    lv_service_plan_frequency number;
    lv_service_plan_priority  number;
    lv_benefit_program_id     number;
    lv_x_benefits_objid       number;
    lv_limit_point_objid      number;
    lv_benefit_owner          table_x_benefits.x_benefit_owner_value%type;
    lv_err_code               number;
    lv_err_msg                varchar2(2000);

  begin
  /*
  find all MINs whcih has collected 18 or more points
  for each MIN, find the most frequently used service plan
  get the reward benefit program name based on service plan, brand and priority
  */

      begin
        open cur_total_points(sysdate-1);
        loop
          fetch cur_total_points bulk collect into points_tab limit 500;
          exit when points_tab.count = 0;
          DBMS_OUTPUT.PUT_LINE(' in_min= ' || in_min || ' points_tab.count=' || points_tab.count);
          -----raise no_data_found;

          for i in 1..points_tab.count loop
            --start processing each point account
            --if one fails, skip it and continue processing next record
            begin
              lv_service_plan_used      := 0;
              lv_service_plan_frequency := 0;
              lv_service_plan_priority  := 0;
              lv_benefit_program_id     := null;

               dbms_output.put_line(' loop started.....points_tab(i).objid= ' || points_tab(i).objid );

              --find out which plan is used most no. of times to collect 18(or whatever is max.value) points
              --if its a tie then get the priority from the table

               /*CR35343 change to address QC2358 : added x_esn to input*/
              for jrec in cur_point_serv_plan_used (points_tab(i).objid, points_tab(i).x_esn)
              loop
                  dbms_output.put_line('checking the serv.plan');
                  begin
                    dbms_output.put_line('jrec.plan_used:'||jrec.plan_used);
                    dbms_output.put_line('jrec.plan_frequency:'||jrec.plan_frequency);

                    if jrec.plan_frequency > lv_service_plan_frequency
                    then
                      lv_service_plan_used      := jrec.plan_used;
                      lv_service_plan_frequency := jrec.plan_frequency;
                      lv_service_plan_priority  := null;
                      --no need to check priority here since its clear that what plan is used


                    elsif jrec.plan_frequency = lv_service_plan_frequency then
                      null;
                      --if its a tie then get the service plan based on priority defined from the table
                     -- minimum function applied to get one plan in case of conflicts in priority
                      select min(tt.service_plan_objid), min(tt.benefit_program_objid), min(tt.x_priority)
                      into lv_service_plan_used, lv_benefit_program_id, lv_service_plan_priority
                      from x_reward_point_values tt
                      where 1=1
                      -- CR35343:070715 nvl added to handle bonus points
                      and nvl(tt.service_plan_objid, -999) in (nvl(lv_service_plan_used, -999), nvl(jrec.plan_used,-999))
                      and tt.bus_org_objid = points_tab(i).bus_org_objid
                      and sysdate between tt.x_start_date and tt.x_end_date
                      and tt.x_priority = (
                                              select min(rpv.x_priority)
                                              from x_reward_point_values rpv
                                              where rpv.x_point_category = lc_point_category_reward
                                               -- CR35343:070715 nvl added to handle bonus points
                                              and nvl(rpv.service_plan_objid, -999) in (nvl(lv_service_plan_used, -999), nvl(jrec.plan_used, -999))
                                              and rpv.bus_org_objid = points_tab(i).bus_org_objid
                                              and sysdate between rpv.x_start_date and rpv.x_end_date
                                          );


                      --dbms_output.put_line('lv_service_plan_priority='|| lv_service_plan_priority);
                    end if;

                    dbms_output.put_line('lv_service_plan_used:'||lv_service_plan_used);
                    dbms_output.put_line('lv_benefit_program_id:'||lv_benefit_program_id);
                    dbms_output.put_line('lv_service_plan_priority:'||lv_service_plan_priority);

                  exception
                    when no_data_found then
                      dbms_output.put_line(
                      'NO DATA FOUND .....points_tab(i).objid= ' || points_tab(i).objid
                      || ', lv_service_plan_used='||lv_service_plan_used
                      || ', jrec.plan_used='|| jrec.plan_used
                      || ', brand='|| points_tab(i).bus_org_objid
                      );

                      raise no_data_found;
                  end;

              end loop;

              if lv_service_plan_priority is null then
                     /* dbms_output.put_line('points_tab(i).objid= ' || points_tab(i).objid
                      || ', lv_service_plan_used='||lv_service_plan_used
                      || ', brand='|| points_tab(i).bus_org_objid
                      );*/

                    begin
                      select tt.service_plan_objid, tt.benefit_program_objid
                      into lv_service_plan_used, lv_benefit_program_id
                      from x_reward_point_values tt
                      where 1=1
                      -- CR35343:070715 in condition to handle bonus points
                      and tt.x_point_category in(lc_point_category_reward, 'BONUS_POINTS')
                      -- CR35343:070715 nvl added to handle bonus points
                      and nvl(tt.service_plan_objid, -999) = nvl(lv_service_plan_used, -999)
                      and tt.bus_org_objid = points_tab(i).bus_org_objid
                      and sysdate between tt.x_start_date and tt.x_end_date ;
                    exception
                      when no_data_found then
                        dbms_output.put_line( 'no POINTS SETUP for '
                        || ' serv.plan='|| lv_service_plan_used
                        || ', brand='|| points_tab(i).bus_org_objid
                        );
                        raise no_data_found;
                    end;

              end if;

              --finally, here we got the right benefit to be given to customer
              --insert in table_x_benefits with status AVAILABLE
              if lv_benefit_program_id is not null then

                 if (points_tab(i).subscriber_uid is not null )
                 then
                     lv_benefit_owner:= points_tab(i).subscriber_uid;
                 else
                     --dbms_output.put_line ('GET_RBEN going to call GET_SUB');
                      p_get_subscriber_id (
                        in_key               => 'ESN'
                        ,in_value            => points_tab(i).x_esn
                        ,out_subscriber_id   => lv_benefit_owner
                        ,out_err_code        => lv_err_code
                        ,out_err_msg         => lv_err_msg
                        ) ;
                 end if;

                begin
                  lv_x_benefits_objid :=  seq_x_benefits.nextval;
                  --dbms_output.put_line('step 1');
                  insert into table_x_benefits
                    (
                      objid,
                      x_benefit_owner_type,
                      x_benefit_owner_value,
                      x_created_date,
                      x_status,
                      x_notes,
                      benefits2benefit_program,
                      x_update_date
                    )
                    values
                    (
                     lv_x_benefits_objid
                      ,'SID'
                      ,lv_benefit_owner
                      ,sysdate
                      ,'961'    --AVAILABLE
                      ,'Benefits created since total reward points are = ' || points_tab(i).total_points
                      ,lv_benefit_program_id
                      ,sysdate -- added on 052815 to support ETL/Reports team req.
                    );
                    --dbms_output.put_line('step 2');
                    --update the existing point_trans records to identify
                    --which points were considered to create the benefit
                    --this is useful in future for refund transactions

                    /*vs:05/03/2015: Adding the next select block to get the last
                     of the points record that were used in the benefit creation.
                      This record will help in identifying the point records that
                      need to be associated to the benefit that got created above*/
                    with point_trans as
                    (
                       select   pt.objid,
                        sum(x_points) over (order by pt.X_TRANS_DATE, pt.objid ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) cumm_points
                        from table_x_point_trans pt
                        where 1=1
                        and pt.point_trans2point_account = points_tab(i).objid
                        -- CR35343:070715 in condition to handle bonus points
                        and pt.x_points_category in ( lc_point_category_reward, 'BONUS_POINTS')
                        and pt.x_points_action in ('ADD', 'ESNUPGRADE', 'DEDUCT')
                        -- CR35343:070715 added or condition to handle bonus points
                        and (pt.point_trans2service_plan is not null or pt.x_points_category = 'BONUS_POINTS')
                        and pt.point_trans2benefit is null
                    )
                    select max(objid)
                    into lv_limit_point_objid
                    from point_trans x
                    where  x.cumm_points <= (select min(cumm_points) from point_trans ptx where ptx.cumm_points >= 18)
                    order by 1 desc;

                    dbms_output.put_line('lv_limit_point_objid: '||lv_limit_point_objid);
                    dbms_output.put_line('lv_x_benefits_objid: '||lv_x_benefits_objid);

                    update table_x_point_trans
                    set point_trans2benefit = lv_x_benefits_objid
                    where 1=1
                    and point_trans2point_account = points_tab(i).objid
                    --below conditions should be exactly same as that in cursor: cur_point_serv_plan_used
                    -- CR35343:070715 in condition to handle bonus points
                    and x_points_category in ( lc_point_category_reward, 'BONUS_POINTS')
                    ---and x_points_action in ('ADD', 'ESNUPGRADE')
                    and objid <= lv_limit_point_objid --vs:adding this to limit point update to what points actually got used
                    -- CR35343:070715 added or condition to handle bonus points
                    and (point_trans2service_plan is not null or x_points_category = 'BONUS_POINTS')
                    and point_trans2benefit is null
                    ;

                   -- dbms_output.put_line('step 2.1  rows updated in point_trans after limit change=' || sql%rowcount);

                   -- dbms_output.put_line('step 3');
                    --remove the 18 points from total points since they are converted to benefit
                    update table_x_point_account
                    set total_points = total_points - points_tab(i).x_conversion_points
                    ,account_status_reason =  'Most recently, '
                      || points_tab(i).x_conversion_points
                      || ' Points converted to benefit on: '
                      || to_char(sysdate, 'dd-mon-rrrr hh24:mi:sssss')
                      || ', benefit objid=' || lv_x_benefits_objid
                    ,x_last_calc_date = sysdate
                    where objid = points_tab(i).objid ;

                   -- dbms_output.put_line('step 4');
                    --log the activity of subtracting the total points and to notify when the benefit was created
                    insert into table_x_point_trans (
                      objid,
                      x_trans_date,
                      x_min,
                      x_esn,
                      x_points,
                      x_points_category,
                      x_points_action,
                      points_action_reason,
                      point_trans2ref_table_objid,
                      ref_table_name,
                      point_trans2service_plan,
                      point_trans2point_account,
                      point_trans2purchase_objid,
                      purchase_table_name,
                      point_trans2site_part,
                      point_trans2benefit,
                      point_display_reason
                      )
                    values (
                      sa.seq_x_point_trans.nextval
                      ,sysdate
                      ,points_tab(i).x_min
                      ,points_tab(i).x_esn
                      ,-1 * points_tab(i).x_conversion_points
                      ,points_tab(i).x_points_category
                      ,'CONVERT'
                      ,points_tab(i).x_conversion_points || ' Points converted to benefit on: '
                          || to_char(sysdate, 'dd-mon-rrrr hh24:mi:sssss')
                          ||', benefit objid=' || lv_x_benefits_objid
                      ,lv_x_benefits_objid
                      ,'TABLE_X_BENEFITS'
                      ,lv_service_plan_used ----serv.plan used max.# of times to create this benefit
                      ,points_tab(i).objid
                      ,null
                      ,null
                      ,(select max(objid)
                          from table_site_part
                          where x_min = points_tab(i).x_min
                          and x_service_id=points_tab(i).x_esn
                          and part_status='Active'
                          )
                      ,lv_x_benefits_objid
                      ,'Converted to Benefit'
                      );
                    --- commit;;
                    --dbms_output.put_line('Step 5 Hurray...benefit created');
                end;
              end if;
            exception
              when others then
                rollback;

            end;
          end loop;

        end loop;

      end;

      --- commit;;
      out_err_code    := 0;
      out_err_msg     := 'SUCCESS';
  exception
      when others then
        rollback;
        dbms_output.put_line(' ERR=' ||
        substr(dbms_utility.format_error_backtrace,1,500));
        out_err_code    := sqlcode;
        out_err_msg     := 'p_create_reward_benefits='||substr(sqlerrm, 1, 200);
  end p_create_reward_benefits_old ;

  procedure p_get_subscriber_id (
            in_key               in varchar2
            ,in_value            in varchar2
            ,out_subscriber_id   out varchar2
            ,out_err_code        out number
            ,out_err_msg         out varchar2
  ) as
    rec_esn           cur_esn_min_dtl%rowtype;
    lb_subid          table_x_point_account.subscriber_uid%type;
    lv_points_rowid   rowid;
    --sub sa.subscriber_type := sa.subscriber_type (); --added vn 21-APR-15
                                                       --SQA#2344 commenting to use Asim's pacakge instead
  begin
    if in_key is null
      or in_value is null then
      out_subscriber_id := null;
      out_err_code      := -12;
      out_err_msg       := 'IN_KEY and IN_VALUE should not be null';
      return;
    elsif in_key not in ('ESN', 'MIN') then
      out_subscriber_id := null;
      out_err_code      := -11;
      out_err_msg       := 'Error. Unsupported values received for IN_KEY and IN_VALUE';
      return;
    end if;

    open cur_esn_min_dtl(in_key, in_value);
    fetch cur_esn_min_dtl into rec_esn;
    close cur_esn_min_dtl ;

    if rec_esn.x_esn is null then
      out_subscriber_id := null;
      out_err_code      := -2;
      out_err_msg       := 'Input ' || in_key || ' [' || in_value || '] not found or is not Active';
      return;
    end if;

    begin
      select subscriber_uid, rowid
      into lb_subid, lv_points_rowid
      from table_x_point_account pa
      where 1=1
      and pa.x_esn = rec_esn.x_esn
      and pa.x_min = rec_esn.x_min
      and pa.bus_org_objid = rec_esn.bus_org_objid
      and pa.account_status = 'ACTIVE'
      and pa.x_points_category = lc_point_category_reward;

      if lb_subid is null then
        /*21-apr-15:veda: commenting the call to brandx and using new get subscriber
         uid call provided by juda*/
        --lb_subid := sa.brand_x_pkg.get_subscriber_uid ( ip_esn => rec_esn.x_esn ) ;
       -- lb_subid := sub.get_subscriber_uid ( i_esn => rec_esn.x_esn ) ;
       -- 052815:Commenting the above call to use package call provided by Asim SQA#2344
          lb_subid := service_profile_pkg.get_subscriber_uid(rec_esn.x_esn);

        update table_x_point_account
        set subscriber_uid = lb_subid
        where rowid = lv_points_rowid;

        --- commit;;

        out_subscriber_id := lb_subid;
        out_err_code      := 0;
        out_err_msg       := 'SUCCESS';

      end if;
    exception
      when no_data_found then
        out_subscriber_id := null;
        out_err_code      := -19;
        out_err_msg       := 'Error. Could not get subscriber ID of ' || in_key || ' = ' || in_value ;
        return;
    end;

  exception
    when others then
      out_subscriber_id := null ;
      out_err_code      := -99;
      out_err_msg       := 'p_get_subscriber_id='||substr(sqlerrm, 1, 200);
  end p_get_subscriber_id;

  procedure p_get_reward_benefits (
            in_key                      in varchar2
            ,in_value                   in varchar2
            ,in_program_name            in varchar2    --  "UPGRADE_PLANS"
            ,in_benefit_type            in varchar2    -- "REWARD_BENEFITS"
            ,out_reward_benefits_list   out sa.reward_benefits_tab
            ,out_err_code               out number
            ,out_err_msg                out varchar2
  ) as
    lv_rec    typ_reward_benefits;
    lv_list   reward_benefits_tab ;
    i                               number;
    lv_my_min                       varchar2(30);
    get_benefit_validation_failed   exception;
    lv_expiry_dt                    date;

    cursor cur_reward_benefits is
      select
        b.objid as benefit_id
        ,b.x_status as benefit_status
        ,b.x_created_date  as created_date
        ,tbp.x_program_name as benefit_program_name
        ,tbp.objid as benefit_program_objid
        ,tbp.x_benefit_type as benefit_type
        ,tbp.x_benefit_unit as benefit_unit
        ,tbp.x_benefit_value as benefit_value
        ,tbp.partial_usage_allowed as partial_usage_allowed
        ,tbp.purch_usage_allowed as purch_usage_allowed
      from table_x_benefits b
        ,table_x_benefit_programs tbp
      where 1=1
      and b.x_benefit_owner_type = in_key
      and b.x_benefit_owner_value = in_value
      and b.x_status = '961' -- 961=available -refer table_x_code_table
      and tbp.objid = b.benefits2benefit_program
      and tbp.x_program_name = in_program_name
      and tbp.x_benefit_type = in_benefit_type
      and(b.x_expiry_date is null or b.x_expiry_date > sysdate) --VS:051515:CR32367
      ;

  begin
    out_reward_benefits_list  := reward_benefits_tab(null);

    if nvl(trim(in_key),'~') not in ('ESN', 'MIN', 'SID', 'ACCOUNT') or trim(in_value) is null then
      out_err_code      := -311;
      out_err_msg       := 'Error. Unsupported or Null values received for IN_KEY and IN_VALUE';
      raise get_benefit_validation_failed;

    elsif nvl(trim(in_program_name),'~') != 'UPGRADE_PLANS' then
      out_err_code      := -312;
      out_err_msg       := 'Error. Unsupported or Null values received for IN_PROGRAM_NAME';
      raise get_benefit_validation_failed;

    elsif nvl(trim(in_benefit_type),'~') != lv_benefit_type then
      out_err_code      := -313;
      out_err_msg       := 'Error. Unsupported or Null values received for IN_BENEFIT_TYPE';
      raise get_benefit_validation_failed;

    end if;

    --generate here the reward benefits for input sub-id
    begin
      select x_min , x_expiry_date
      into lv_my_min , lv_expiry_dt
      from table_x_point_account
      where 1=1
      and subscriber_uid = in_value
      and account_status = 'ACTIVE'
      and x_points_category = lc_point_category_reward ;

      if (lv_expiry_dt is not null and  lv_expiry_dt < sysdate)
      then
        out_err_code      := 401;
        out_err_msg       := 'No benefits available for input ' || in_key
                              || ' [' || in_value || ']' ;
        return;
      end if;
      --check if total points have reached the maximum value
      --and may be eligible to create a reward benefit
      --03/24/2015 CR32367
      sa.reward_benefits_n_vouchers_pkg.p_create_reward_benefits (
                in_min  =>  lv_my_min
                ,out_err_code => out_err_code
                ,out_err_msg => out_err_msg
          );



    exception
      when others then
        null;
        dbms_output.put_line('Could not refresh the Benefits for in_value=' || in_value) ;
    end;

    lv_rec := typ_reward_benefits.initialize;
    lv_list := reward_benefits_tab(lv_rec);
    lv_list.delete;
    i := 0;
    for icur in cur_reward_benefits
    loop
      lv_rec.benefit_id               := icur.benefit_id ;
      lv_rec.benefit_type             := icur.benefit_type ;
      lv_rec.benefit_program_name     := icur.benefit_program_name ;
      lv_rec.benefit_program_objid    := icur.benefit_program_objid ;
      lv_rec.benefit_unit             := icur.benefit_unit ;
      lv_rec.benefit_value            := icur.benefit_value ;
      lv_rec.partial_usage_allowed    := icur.partial_usage_allowed ;
      lv_rec.purch_usage_allowed      := icur.purch_usage_allowed ;

      i := i + 1;
      lv_list.extend();
      lv_list(i)  :=  lv_rec;
    end loop;

    out_reward_benefits_list := lv_list ;

    if out_reward_benefits_list.count = 0 then
      out_err_code      := 401;
      out_err_msg       := 'No benefits available for input ' || in_key
                            || ' [' || in_value || ']' ;
    else
      out_err_code      := 0;
      out_err_msg       := 'SUCCESS';
    end if;

    --dbms_output.put_line('This is last Step...count=' || out_reward_benefits_list.count);

  exception
    when get_benefit_validation_failed then
      out_reward_benefits_list.delete;

    when others then
      out_reward_benefits_list.delete;
      out_err_code      := -99;
      out_err_msg       := 'p_get_reward_benefits='||substr(sqlerrm, 1, 2000);
  end p_get_reward_benefits;

  procedure p_create_voucher_access_token (
            in_key                      in varchar2
            ,in_value                   in varchar2
            ,in_program_name            in varchar2    --  "UPGRADE_PLANS"
            ,in_benefit_type            in varchar2    --  "REWARD_BENEFITS"
            ,in_vendor_id               in varchar2    --
            ,out_voucher_access_token   out varchar2
            ,out_err_code               out number
            ,out_err_msg                out varchar2
  ) as

  lv_token_id       varchar2(50);
  lv_token_expiry   number;
  lv_err_code       number;
  lv_err_msg        varchar2(2000);
  lv_vouchers_list  sa.reward_vouchers_tab;
  create_token_validation_failed exception;

  begin
    if nvl(trim(in_key),'~') not in ('ESN', 'MIN', 'SID', 'ACCOUNT') or trim(in_value) is null then
      out_err_code      := -311;
      out_err_msg       := 'Error. Unsupported or Null values received for IN_KEY and IN_VALUE';
      raise create_token_validation_failed;

    elsif nvl(trim(in_program_name),'~') != 'UPGRADE_PLANS' then
      out_err_code      := -312;
      out_err_msg       := 'Error. Unsupported or Null values received for IN_PROGRAM_NAME';
      raise create_token_validation_failed;

    elsif nvl(trim(in_benefit_type),'~') != lv_benefit_type then
      out_err_code      := -313;
      out_err_msg       := 'Error. Unsupported or Null values received for IN_BENEFIT_TYPE';
      raise create_token_validation_failed;

    elsif trim(in_vendor_id) is null then
      out_err_code      := -314;
      out_err_msg       := 'Error. Please provide value for input IN_VENDOR_ID';
      raise create_token_validation_failed;

    end if;

    if lv_token_expiry_timeout is null then
      lv_token_expiry_timeout := (1/1440) * to_number(f_get_parameter_value ('VOUCHER_TOKEN_EXPIRY_TIME_IN_MINUTES'));
    end if;

    lv_token_id := f_get_unique_id;

    --for the new generated token, create the reward vouchers
    p_create_reward_vouchers (
            in_key                    =>  in_key
            ,in_value                 =>  in_value
            ,in_program_name          =>  in_program_name
            ,in_benefit_type          =>  in_benefit_type
            ,in_voucher_access_token  =>  lv_token_id
            ,out_vouchers_list        =>  lv_vouchers_list
            ,out_err_code             =>  lv_err_code
            ,out_err_msg              =>  lv_err_msg
    );

    ---dbms_output.put_line('** output = ' || lv_err_code  ||', msg='|| lv_err_msg  );

    if lv_err_code = 0 then

      insert into x_voucher_access_token (
        x_token_id,
        x_token_status,
        x_created_date,
        x_expiration_date,
        vendor_id
      )
      values (
        lv_token_id
        ,'941'
        ,sysdate
        ,sysdate + nvl(lv_token_expiry_timeout,0)
        ,in_vendor_id
      );

      out_err_code      := 0;
      out_err_msg       := 'SUCCESS';

    else

      if lv_token_without_vouchers is null then
        lv_token_without_vouchers := f_get_parameter_value('TOKEN_WITHOUT_VOUCHER');
      end if;

      lv_token_id       := lv_token_without_vouchers;
      out_err_code      := 0;
      out_err_msg       := 'SUCCESS';
    end if;

    /*
      out_err_code      := 0;
      out_err_msg       := 'SUCCESS';

    else

      if lv_err_code = -13 then
        out_err_code      := lv_err_code;
        out_err_msg       := lv_err_msg;
      end if;

      dbms_output.put_line('err='|| out_err_code || '# '|| out_err_msg);

    end if;
    */

    out_voucher_access_token  :=  lv_token_id;
    --out_err_code      := 0;
    --out_err_msg       := 'SUCCESS';
    dbms_output.put_line('err='|| out_err_code || '# '|| out_err_msg);

  exception
    when create_token_validation_failed then
      out_voucher_access_token := null ;
      dbms_output.put_line('create_token_validation_failed...'|| out_err_code || '# '|| out_err_msg);

    when others then
      out_voucher_access_token := null ;
      out_err_code      := -99;
      out_err_msg       := 'p_create_voucher_access_token='||substr(sqlerrm, 1, 2000);
      dbms_output.put_line('OTHERS...'|| out_err_code || '# '|| out_err_msg);
  end p_create_voucher_access_token;

  procedure p_create_reward_vouchers (
            in_key                    in varchar2    -- "SID"
            ,in_value                 in varchar2
            ,in_program_name          in varchar2    -- "UPGRADE_PLANS"
            ,in_benefit_type          in varchar2    -- "REWARD_BENEFITS"
            ,in_voucher_access_token  in varchar2
            ,out_vouchers_list        out sa.reward_vouchers_tab
            ,out_err_code             out number
            ,out_err_msg              out varchar2
  ) as
    cursor cur_reward_benefits is
        select
          txb.objid as benefit_objid
          ,tbp.x_benefit_type
          ,txb.benefits2benefit_program  as benefit_program_objid
          ,tbp.x_program_name
          ,tbp.x_benefit_unit
          ,tbp.x_benefit_value
          ,tbp.partial_usage_allowed
          ,tbp.purch_usage_allowed
          ,txb.x_created_date
        from table_x_benefits txb
          , table_x_benefit_programs tbp
          , table_x_point_account ta --VS:05/10/15
        where 1=1
        and txb.x_benefit_owner_type = in_key
        and txb.x_benefit_owner_value = in_value
        and txb.benefits2benefit_program = tbp.objid
        and txb.x_status = '961'  --refer table_x_code_table
        and ta.subscriber_uid = txb.x_benefit_owner_value
        and (ta.x_expiry_date is null or  ta.x_expiry_date > sysdate)
        and ta.account_status = 'ACTIVE'
        and sysdate between tbp.x_start_date and tbp.x_end_date
        order by txb.x_created_date
        ;
    type typ_benefits_tab is table of cur_reward_benefits%rowtype index by pls_integer;
    benefits_tab  typ_benefits_tab;

    lv_voucher_id   table_x_vouchers.voucher_id%type;
    rec_voucher     sa.typ_reward_vouchers ;

    no_benefits_available exception;

  begin
    --initialise the voucher list
    out_vouchers_list := reward_vouchers_tab(null);
    out_vouchers_list.delete;

    if nvl(trim(in_key),'~') not in ('ESN', 'MIN', 'SID', 'ACCOUNT') or trim(in_value) is null then
      out_err_code      := -311;
      out_err_msg       := 'Error. Unsupported or Null values received for IN_KEY and IN_VALUE';
      return;

    elsif nvl(trim(in_program_name),'~') != 'UPGRADE_PLANS' then
      out_err_code      := -312;
      out_err_msg       := 'Error. Unsupported or Null values received for IN_PROGRAM_NAME';
      return;

    elsif nvl(trim(in_benefit_type),'~') != lv_benefit_type then
      out_err_code      := -313;
      out_err_msg       := 'Error. Unsupported or Null values received for IN_BENEFIT_TYPE';
      return;

    elsif trim(in_voucher_access_token) is null then
      out_err_code      := -315;
      out_err_msg       := 'Error. Please specify value for input IN_VOUCHER_ACCESS_TOKEN';
      return;

    end if;

    if lv_voucher_expiry_timeout is null then
      lv_voucher_expiry_timeout := (1/1440)* to_number(f_get_parameter_value('REWARD_VOUCHER_EXPIRY_TIME_IN_MINUTES'));
    end if;

    --read the benefits which are available and for each benefit, create the voucher
    --1 benefit 1 voucher
    open cur_reward_benefits;
    fetch cur_reward_benefits bulk collect into benefits_tab;
    close cur_reward_benefits;

    if benefits_tab.count = 0 then
      raise no_benefits_available;
    end if;

    --initialise the voucher list
    out_vouchers_list.delete;

    for i in 1..benefits_tab.count
    loop
      lv_voucher_id := f_get_unique_id;
      rec_voucher   := TYP_REWARD_VOUCHERS.initialize;

      insert into table_x_vouchers   (
          objid
          ,voucher_id
          ,x_created_date
          ,x_expiration_date
          ,x_voucher_status
          ,x_token_id
          ,x_vouchers2benefit
          ,x_update_date
      )
      values (
        seq_x_vouchers.nextval
        ,lv_voucher_id
        ,sysdate
        ,sysdate + NVL(lv_voucher_expiry_timeout,0)
        ,'971'
        ,in_voucher_access_token
        ,benefits_tab(i).benefit_objid
        ,null
      );
      rec_voucher.voucher_id              := lv_voucher_id;
      rec_voucher.benefit_id              := benefits_tab(i).benefit_objid;
      rec_voucher.benefit_type            := benefits_tab(i).x_benefit_type;
      rec_voucher.benefit_program_name    := benefits_tab(i).x_program_name;
      rec_voucher.benefit_program_objid   := benefits_tab(i).benefit_program_objid;
      rec_voucher.benefit_unit            := benefits_tab(i).x_benefit_unit;
      rec_voucher.benefit_value           := benefits_tab(i).x_benefit_value;
      rec_voucher.partial_usage_allowed   := benefits_tab(i).partial_usage_allowed;
      rec_voucher.purch_usage_allowed     := benefits_tab(i).purch_usage_allowed;
      out_vouchers_list.extend;
      out_vouchers_list(out_vouchers_list.last) := rec_voucher;
    end loop;

    out_err_code      := 0;
    out_err_msg       := 'SUCCESS';
  exception
    when no_benefits_available then
      out_vouchers_list.delete;
      out_err_code      := -13;
      out_err_msg       := 'Error. No Reward Benefits available to create the Reward Vouchers';

    when others then
      rollback;
      out_vouchers_list.delete;
      out_err_code      := -99;
      out_err_msg       := 'p_create_reward_vouchers='||substr(sqlerrm, 1, 2000);
  end p_create_reward_vouchers;

  procedure p_log_voucher_transaction (
            in_vendor_id            in varchar2
            ,in_voucher_objid       in varchar2
            ,in_order_objid         in varchar2
            ,in_voucher_status      in varchar2
            ,in_transaction_id      in number
            ,in_transaction_type    in varchar2
            ,in_transaction_notes   in varchar2
            ,in_ref_transaction_id  in  number
            ,out_err_code           out number
            ,out_err_msg            out varchar2
  ) as
    pragma autonomous_transaction;
  begin
    insert into table_x_voucher_transactions(
        transaction_id,
        transaction_type,
        transaction_date,
        vendor_id,
        voucher_trans2voucher,
        voucher_status,
        voucher_trans2order,
        x_notes,
        ref_transaction_id
      )
      values (
        in_transaction_id
        ,in_transaction_type
        ,sysdate
        ,in_vendor_id
        ,in_voucher_objid
        ,in_voucher_status
        ,in_order_objid
        ,in_transaction_notes
        ,in_ref_transaction_id
      );

    out_err_code      := 0;
    out_err_msg       := 'SUCCESS';
    commit;

  exception
    when others then
      rollback;
      out_err_code      := -99;
      out_err_msg       := 'p_log_voucher_transaction=' || substr(sqlerrm, 1, 2000);
      dbms_output.put_line ('ERROR in p_log_voucher_transaction...=' || out_err_msg);
  end p_log_voucher_transaction;

  procedure p_get_voucher_info (
            in_vendor_id              in varchar2
            ,in_voucher_access_token  in varchar2
            ,out_vouchers_list        out sa.reward_vouchers_tab
            ,out_transaction_id       out number
            ,out_err_code             out number
            ,out_err_msg              out varchar2
  ) as

  cursor cur_reward_vouchers is
        select
          tv.objid  as voucher_objid
          ,tv.voucher_id
          ,tv.x_voucher_status  as voucher_status
          ,tv.x_created_date  as voucher_created_date
          ,tv.x_expiration_date as voucher_expiration_date
          ,tv.x_token_id
          ,txb.objid as benefit_objid
          ,tbp.x_benefit_type
          ,txb.benefits2benefit_program  as benefit_program_objid
          ,tbp.x_program_name
          ,tbp.x_benefit_unit
          ,tbp.x_benefit_value
          ,tbp.partial_usage_allowed
          ,tbp.purch_usage_allowed
          ,txb.x_created_date as benefit_created_date
        from
          table_x_vouchers tv
          , table_x_benefits txb
          , table_x_benefit_programs tbp
        where 1=1
        and tv.x_token_id = in_voucher_access_token
        --and tv.X_VOUCHER_STATUS = ''      DOES IT REQUIR TO CHECK THE STATUS ?????
        and tv.x_vouchers2benefit = txb.objid
        and txb.benefits2benefit_program = tbp.objid
        and sysdate between tbp.x_start_date and tbp.x_end_date
        and(txb.x_expiry_date is null or txb.x_expiry_date > sysdate)
        order by tv.x_created_date;

  type typ_vouchers_tab is table of cur_reward_vouchers%rowtype index by pls_integer;

  lv_validation_err_code  number;
  lv_validation_err_msg   varchar2(2000);
  lv_new_transaction_id   table_x_voucher_transactions.transaction_id%type;

  vouchers_tab            typ_vouchers_tab ;
  lv_list                 sa.reward_vouchers_tab := reward_vouchers_tab(null);
  rec_voucher             sa.typ_reward_vouchers;

  validation_failed       exception;

  begin

    --if token is expired then
      --log transaction and return

    --if token is not expired and already used then
      --log transaction and return

    --if token is not expired and not used then
      --fetch all vouchers associated with token
      --mark the token as used
      --log the transaction as "vouchers read"
      --return


    --initialize the collections
    rec_voucher :=  typ_reward_vouchers.initialize;
    out_vouchers_list := reward_vouchers_tab(null);

    --generate new transaction id
    lv_new_transaction_id := f_get_transaction_id;

    if lv_token_without_vouchers is null then
      lv_token_without_vouchers := f_get_parameter_value('TOKEN_WITHOUT_VOUCHER');
    end if;

/*
    if in_vendor_id is null or in_voucher_access_token is null then
        lv_validation_err_code  :=  -1;
        lv_validation_err_msg   :=  'Error. Please provide values for input IN_VENDOR_ID and IN_VOUCHER_ACCESS_TOKEN';
        raise validation_failed;
    end if;
*/
    if trim(in_vendor_id) is null then
        lv_validation_err_code  :=  -314;
        lv_validation_err_msg   :=  'Error. Please provide value for input IN_VENDOR_ID';
        raise validation_failed;
    elsif trim(in_voucher_access_token) is null then
        lv_validation_err_code  :=  -315;
        lv_validation_err_msg   :=  'Error. Please provide value for input IN_VOUCHER_ACCESS_TOKEN [ '|| in_voucher_access_token ||' ]';
        raise validation_failed;
    elsif nvl(in_voucher_access_token,'~') = lv_token_without_vouchers then
        lv_validation_err_code  :=  402;
        lv_validation_err_msg   :=  'No Vouchers found for input IN_VOUCHER_ACCESS_TOKEN [ '|| in_voucher_access_token ||' ]';
        raise validation_failed;
    end if;

    p_validate_input_token  ( in_token      => in_voucher_access_token
                            , in_vendor_id  => in_vendor_id
                            , out_err_code  => lv_validation_err_code
                            , out_err_msg   => lv_validation_err_msg
                          );

    ---dbms_output.put_line (' token validated.....out_err_code='||out_err_code);

    if lv_validation_err_code = 0 then
      null;
    else
      raise validation_failed;
    end if;

    open cur_reward_vouchers;
    fetch cur_reward_vouchers bulk collect into vouchers_tab;
    close cur_reward_vouchers;

    out_vouchers_list.delete;

    for i in 1..vouchers_tab.count
    loop
      p_log_voucher_transaction (
                in_vendor_id             => in_vendor_id
                ,in_voucher_objid        => vouchers_tab(i).voucher_objid
                ,in_order_objid          => null
                ,in_voucher_status       => vouchers_tab(i).voucher_status
                ,in_transaction_id       => lv_new_transaction_id
                ,in_transaction_type     => '956' -----GET_VOUCHER
                ,in_transaction_notes    => 'Voucher accessed from new token = ' || in_voucher_access_token
                ,in_ref_transaction_id   => null
                ,out_err_code            => lv_validation_err_code
                ,out_err_msg             => lv_validation_err_msg
      );

     -- dbms_output.put_line ('txn logged..err=' || lv_validation_err_code );
      if lv_validation_err_code = 0 then
        null;

        rec_voucher.voucher_id               := vouchers_tab(i).voucher_id;
        rec_voucher.benefit_id               := vouchers_tab(i).benefit_objid;
        rec_voucher.benefit_type             := vouchers_tab(i).x_benefit_type;
        rec_voucher.benefit_program_name     := vouchers_tab(i).x_program_name;
        rec_voucher.benefit_program_objid    := vouchers_tab(i).benefit_program_objid;
        rec_voucher.benefit_unit             := vouchers_tab(i).x_benefit_unit;
        rec_voucher.benefit_value            := vouchers_tab(i).x_benefit_value;
        rec_voucher.partial_usage_allowed    := vouchers_tab(i).partial_usage_allowed;
        rec_voucher.purch_usage_allowed      := vouchers_tab(i).purch_usage_allowed;

        out_vouchers_list.extend;
        out_vouchers_list(out_vouchers_list.last) := rec_voucher;
      else
        lv_validation_err_msg := 'Error. System cannot log Voucher transactions';
        raise validation_failed;
      end if;

    end loop;

    if out_vouchers_list.count = 0 then
        lv_validation_err_code  :=  402;
        lv_validation_err_msg   :=  'No Vouchers found for input IN_VOUCHER_ACCESS_TOKEN [' || in_voucher_access_token|| ']';
        raise validation_failed;
    end if;

    out_transaction_id  := lv_new_transaction_id;
    out_err_code        := 0;
    out_err_msg         := 'SUCCESS';

  exception
    when validation_failed then
      out_vouchers_list.delete;
      out_err_code        := lv_validation_err_code;
      out_err_msg         := lv_validation_err_msg;

      p_log_voucher_transaction (
                in_vendor_id             => in_vendor_id
                ,in_voucher_objid        => null
                ,in_order_objid          => null
                ,in_voucher_status       => null
                ,in_transaction_id       => lv_new_transaction_id
                ,in_transaction_type     => '956'
                ,in_transaction_notes    => 'FAILED. Attempt to get list of vouchers for token = ' || in_voucher_access_token
                                              ||'. Notes= ' || out_err_msg
                ,in_ref_transaction_id   => null
                ,out_err_code            => lv_validation_err_code
                ,out_err_msg             => lv_validation_err_msg
      );

    when others then
      out_vouchers_list.delete;
      out_err_code        := sqlcode;
      out_err_msg         := 'p_get_voucher_info='||substr(sqlerrm, 1, 200);
  end p_get_voucher_info;

  procedure p_invalidate_vouchers (
             in_voucher_access_token  in varchar2
            ,in_vouchers_id_list      in sa.typ_vouchers_id_tab
            ,in_vendor_id             in varchar2
            ,out_transaction_id       out number
            ,out_err_code             out number
            ,out_err_msg              out varchar2
  ) as

  db_vouchers               typ_voucher_tab ;

  lv_new_invalidate_trans_id           table_x_voucher_transactions.transaction_id%type;

  lv_voucher_modified           number;
  lv_err_code                   number;
  lv_err_msg                    varchar2(2000);
  invalid_voucher_input_failed  exception;
  invalid_vouchers_failed       exception;

  begin
    if trim(in_vendor_id) is null then
        lv_err_code  :=  -314;
        lv_err_msg   :=  'Error. Please provide value for input IN_VENDOR_ID';
        raise invalid_voucher_input_failed;

    elsif trim(in_voucher_access_token) is null then
        lv_err_code  :=  -315;
        lv_err_msg   :=  'Error. Please provide value for input IN_VOUCHER_ACCESS_TOKEN';
        raise invalid_voucher_input_failed;

    elsif in_vouchers_id_list is null or in_vouchers_id_list.count = 0 then
        lv_err_code  :=  -320;
        lv_err_msg   :=  'Error. Please provide list of Voucher ID';
        raise invalid_voucher_input_failed;
    end if;

    --retrive the vouchers requested as per input voucher's id list
    open cur_vouchers (in_voucher_access_token);
    fetch cur_vouchers bulk collect into db_vouchers;
    close cur_vouchers ;
   -- dbms_output.put_line ('db_vouchers.count ='|| db_vouchers.count  );
   -- dbms_output.put_line ('input list count ='|| in_vouchers_id_list.count  );

    if nvl(db_vouchers.count,0) = 0 then
      lv_err_code := 402;
      lv_err_msg := 'No Vouchers found for input IN_VOUCHER_ACCESS_TOKEN [' || in_voucher_access_token|| ']';

      raise invalid_voucher_input_failed;
    end if;

    --generate new transaction id for Invalidate activity
    lv_new_invalidate_trans_id :=  f_get_transaction_id ;
    out_transaction_id  := lv_new_invalidate_trans_id;

    lv_voucher_modified := 0;
    for j in 1..in_vouchers_id_list.count
    loop
      for i in 1..db_vouchers.count
      loop

        if db_vouchers(i).voucher_id = in_vouchers_id_list(j) then

              --check the voucher status - voucher can be invalidated only if its valid
              --expired / authorized / canceled vouchers can not be invalidated
              if db_vouchers(i).x_expiration_date <= sysdate and db_vouchers(i).x_voucher_status != '964' then

                begin
                    --log the transaction
                    p_log_voucher_transaction (
                              in_vendor_id             => in_vendor_id
                              ,in_voucher_objid        => db_vouchers(i).voucher_objid
                              ,in_order_objid          => null
                              ,in_voucher_status       => '964'
                              ,in_transaction_id       => lv_new_invalidate_trans_id
                              ,in_transaction_type     => '955'
                              ,in_transaction_notes    => 'Request received to INVALIDATE voucher but its already EXPIRED...'
                                                          || ', input Token='||in_voucher_access_token
                              ,in_ref_transaction_id   => null
                              ,out_err_code            => lv_err_code
                              ,out_err_msg             => lv_err_msg
                    );
                    if lv_err_code = 0 then

                      ---make the voucher status as expired and log transaction
                      update table_x_vouchers
                      set  x_voucher_status = '964' --expired
                        , x_update_date = sysdate
                      where objid = db_vouchers(i).voucher_objid;

                      --no need to update benefits for invalidation
                      lv_voucher_modified := lv_voucher_modified + 1;
                    end if;

                end;

              elsif db_vouchers(i).x_voucher_status = '971' then --971=valid

                begin
                  --log the transaction
                  p_log_voucher_transaction (
                            in_vendor_id             => in_vendor_id
                            ,in_voucher_objid        => db_vouchers(i).voucher_objid
                            ,in_order_objid          => null
                            ,in_voucher_status       => '972'
                            ,in_transaction_id       => lv_new_invalidate_trans_id
                            ,in_transaction_type     => '955'
                            ,in_transaction_notes    => 'Request received to INVALIDATE voucher...'
                                                  || ' Earlier status= '|| db_vouchers(i).x_voucher_status
                            ,in_ref_transaction_id   => null
                            ,out_err_code            => lv_err_code
                            ,out_err_msg             => lv_err_msg
                  );
                  if lv_err_code = 0 then
                    ---make the voucher status as invalid and log transaction
                    update table_x_vouchers
                    set  x_voucher_status = '972' --972=invalid
                      , x_update_date = sysdate
                    where objid = db_vouchers(i).voucher_objid;

                    --no need to update benefits for invalidation
                    lv_voucher_modified := lv_voucher_modified + 1;
                  end if;
                end;

              else
                null;
                --in this scenario, voucher could have already been invalidated / auth / settled / canceled / refunded
                --so these vouchers cannot be invalidated
              end if;
        end if;
      end loop;

    end loop;

    if nvl(lv_voucher_modified,0) = nvl(in_vouchers_id_list.count,0) then
      out_err_code        := 0;
      out_err_msg         := 'SUCCESS';

    elsif (nvl(lv_voucher_modified,0) > 0)
              and (lv_voucher_modified < nvl(in_vouchers_id_list.count,0) )then
      out_err_code := 403;
      out_err_msg := 'One or more Vouchers to be invalidated are already Invalidated / Expired / Settled / canceled';

    end if;

  exception
    when invalid_voucher_input_failed then
      out_transaction_id  :=  null;
      out_err_code := lv_err_code;
      out_err_msg := lv_err_msg;
     -- dbms_output.put_line ('p_invalidate_vouchers_failed...err=' || out_err_code);

    when others then
      rollback;
      out_err_code        := -99;
      out_err_msg         := 'p_invalidate_vouchers='||substr(sqlerrm, 1, 200);
    --  dbms_output.put_line ('p_invalidate_vouchers OTHERS...err=' || out_err_msg);

      sa.ota_util_pkg.err_log (
        p_action => 'OTHERS EXCEPTION',
        p_error_date => sysdate,
        p_key => 'CR32367',
        p_program_name => 'P_INVALIDATE_VOUCHERS',
        p_error_text =>
               'input params: in_voucher_access_token='||in_voucher_access_token
              || ', in_vendor_id='|| in_vendor_id
              || ', out_err_code='||out_err_code
              || ', out_err_msg='|| out_err_msg
              );

  end p_invalidate_vouchers;

  procedure p_authorize_voucher_payment (
             in_voucher_access_token  in varchar2
            ,in_vouchers_id_list      in sa.typ_vouchers_id_tab
            ,in_vendor_id             in varchar2
            ,in_settlement_flag       in varchar2 default 'N'
            ,in_order_info            in sa.typ_voucher_order
            ,in_order_details_tab     in sa.typ_voucher_order_details_tab
            ,out_transaction_id       out number
            ,out_err_code             out number
            ,out_err_msg              out varchar2
  ) as
  lv_new_auth_trans_id      table_x_voucher_transactions.transaction_id%type;
  lv_token_rec              cur_voucher_token%rowtype;

  auth_input_failed         exception;
  auth_transaction_failed   exception;
  lv_auth_succeed           number;
  lv_order_hdr_objid        number;
  lv_err_code               number;
  lv_err_msg                varchar2(2000);
  lv_steps_completed        number;
  lv_benefit_value          number;  --CR35343 070615
  db_vouchers               typ_voucher_tab ;
  rec_order_det             sa.typ_voucher_order_details;

  begin
    lv_steps_completed := 0;

    if trim(in_vendor_id) is null then
        lv_err_code  :=  -314;
        lv_err_msg   :=  'Error. Please provide value for input IN_VENDOR_ID';
        raise auth_input_failed;

    elsif trim(in_voucher_access_token) is null then
        lv_err_code  :=  -315;
        lv_err_msg   :=  'Error. Please provide value for input IN_VOUCHER_ACCESS_TOKEN';
        raise auth_input_failed;

    elsif in_vouchers_id_list is null or in_vouchers_id_list.count = 0 then
        lv_err_code  :=  -320;
        lv_err_msg   :=  'Error. Please provide list of Voucher ID';
        raise auth_input_failed;

    elsif in_order_info is null then
        lv_err_code  :=  -321;
        lv_err_msg   :=  'Error. Invalid or Null value received for input IN_ORDER_INFO';
        raise auth_input_failed;

    elsif nvl(in_order_info.order_id,'~') = '~' and nvl(in_settlement_flag, 'N') = 'Y' then
        lv_err_code  :=  -336;
        lv_err_msg   :=  'Error. Invalid or Null value received for input ORDER ID';
        raise auth_input_failed;

    elsif in_order_details_tab is null or in_order_details_tab.count = 0 then
        lv_err_code  :=  -322;
        lv_err_msg   :=  'Error. Invalid or Null value received for input IN_ORDER_DETAILS_TAB';
        raise auth_input_failed;

    elsif trim(in_order_info.customer_min) is null then
        lv_err_code  :=  -323;
        lv_err_msg   :=  'Error. Invalid or null value received for Input Customer MIN';
        raise auth_input_failed;

    else
        lv_steps_completed := 1;
        --check whether input token is expired or not
        open cur_voucher_token(in_voucher_access_token);
        fetch cur_voucher_token into lv_token_rec;
        close cur_voucher_token;

        if in_vendor_id <> nvl(lv_token_rec.vendor_id,'~') then
          lv_err_code        := -317;
          lv_err_msg         := 'Error. Input Vendor [' || in_vendor_id || '] dont have access to Input token [' ||in_voucher_access_token || '] ';
          raise auth_input_failed;
        end if;
        lv_steps_completed := 2;
    end if;

    --check whether the custmer MIN is same as in table_x_point_account
    --if its not then raise error
    --vs:05/11/15: swapped point trans join with benefits table to make it work for min change case
    begin
      lv_err_code := 0;
      select count(1)--pa.x_min
      into lv_err_code
      from table_x_vouchers tv
        , table_x_benefits txb
        , table_x_point_account pa
      where 1=1
      and tv.x_token_id = in_voucher_access_token
      and tv.x_vouchers2benefit = txb.objid
      and txb.x_benefit_owner_value = pa.subscriber_uid
      and txb.x_benefit_owner_type = 'SID'
      and pa.x_min = in_order_info.customer_min
      and pa.account_status = 'ACTIVE'
      and pa.x_points_category = lc_point_category_reward
      ;
    exception
      when others then
        lv_err_code := 0;
    end;

    lv_steps_completed := 3;

    if lv_err_code = 0 then
      lv_err_code        := -335;
      lv_err_msg         := 'Error. Input Customer MIN ['|| in_order_info.customer_min || '] dont match with Benefits MIN';
      raise auth_input_failed;
    end if;

    lv_steps_completed := 4;

    open cur_vouchers (in_voucher_access_token);
    fetch cur_vouchers bulk collect into db_vouchers;
    close cur_vouchers ;

    --generate new transaction id
    lv_new_auth_trans_id :=  f_get_transaction_id ;
    lv_order_hdr_objid := seq_voucher_orders.nextval;

    lv_auth_succeed := 0;

   -- dbms_output.put_line (' starting..voucher count ='||  in_vouchers_id_list.count  );

    for i in 1..in_vouchers_id_list.count
    loop
      --check voucher is valid and can be authorized
      --voucher can be authorized only if its valid
      for j in 1..db_vouchers.count
      loop
        begin
            if db_vouchers(j).voucher_id = in_vouchers_id_list(i) then
            --  dbms_output.put_line (' voucher found');
              if db_vouchers(j).x_expiration_date <= sysdate and db_vouchers(j).x_voucher_status <> '964' then
                  begin
                      --dbms_output.put_line (' voucher is expired');

                      update table_x_vouchers
                      set x_voucher_status = '964' ---964=expired
                        , x_update_date = sysdate
                      where objid = db_vouchers(j).voucher_objid;
                      lv_err_msg := 'One of the Voucher cannot be authorized';

                      --mark the benefits as available
                      update table_x_benefits
                      set x_status = '961'
                        , x_notes = 'benefits are available again since associated voucher was expired'
                        , x_update_date = sysdate
                      where objid = db_vouchers(j).benefit_objid;

                      --log transaction
                      p_log_voucher_transaction (
                                in_vendor_id             => in_vendor_id
                                ,in_voucher_objid        => db_vouchers(j).voucher_objid
                                ,in_order_objid          => lv_order_hdr_objid
                                ,in_voucher_status       => '964'
                                ,in_transaction_id       => lv_new_auth_trans_id
                                ,in_transaction_type     =>
                                        case
                                          when nvl(in_settlement_flag,'~') = 'Y' then
                                              '952' -----settlement
                                          else
                                              '951' -----authorization
                                        end
                                ,in_transaction_notes    => 'Voucher has been expired'
                                ,in_ref_transaction_id   => null
                                ,out_err_code            => lv_err_code
                                ,out_err_msg             => lv_err_msg
                      );
                      --dbms_output.put_line (' expire txn logging  response='|| lv_err_code );

                  end;

              elsif db_vouchers(j).x_voucher_status = '971' then  --971=available
                 -- dbms_output.put_line (' voucher is available');
                  begin
                      lv_steps_completed := 5;

                      --set voucher as auth / settled
                      update table_x_vouchers
                      set x_voucher_status =
                                        case
                                          when nvl(in_settlement_flag,'~') = 'Y' then
                                              '974' ---974=settlement
                                          else
                                              '973' ---973=auth
                                        end
                        , x_vouchers2order_hdr = lv_order_hdr_objid
                        , x_update_date = sysdate
                      where objid = db_vouchers(j).voucher_objid;

                      --set benefit as used
                      update table_x_benefits
                      set x_status =
                                        case
                                          when nvl(in_settlement_flag,'~') = 'Y' then
                                              '963' ---963=used
                                          else
                                              '962'---962=unavailable (ie authorized)
                                        end
                        , x_notes = 'benefits are marked as used during Authorization with settlement_flag='||in_settlement_flag
                        , x_update_date = sysdate
                      where objid = db_vouchers(j).benefit_objid;

                      --log transaction
                      p_log_voucher_transaction (
                                in_vendor_id             => in_vendor_id
                                ,in_voucher_objid        => db_vouchers(j).voucher_objid
                                ,in_order_objid          => lv_order_hdr_objid
                                ,in_voucher_status       => '973'
                                ,in_transaction_id       => lv_new_auth_trans_id
                                ,in_transaction_type     =>
                                        case
                                          when nvl(in_settlement_flag,'~') = 'Y' then
                                              '952' -----settlement
                                          else
                                              '951' -----authorization
                                        end

                                ,in_transaction_notes    =>
                                        case
                                          when nvl(in_settlement_flag,'~') = 'Y' then
                                              'Trying to Settle Voucher from token = ' || in_voucher_access_token
                                          else
                                              'Tryign to Authorize Voucher from token = ' || in_voucher_access_token
                                        end
                                ,in_ref_transaction_id   => null
                                ,out_err_code            => lv_err_code
                                ,out_err_msg             => lv_err_msg
                      );

                      --dbms_output.put_line (' auth txn logging  response='|| lv_err_code );

                      lv_auth_succeed := lv_auth_succeed + 1;
                      lv_steps_completed := 7;

                  end;
              end if;
            end if;
        end;
      end loop;
    end loop;


    --if one of voucher could not be authorized / settled then
    if lv_auth_succeed = in_vouchers_id_list.count  then
        lv_steps_completed := 9;
        --save input order info

       /*CR35343:070615:determining the total benefit amount redeemed in the transaction*/
       select sum (to_number(txbp.x_benefit_value))
        into lv_benefit_value
         from
        table_x_vouchers txv,
        table_x_benefits txb,
         table_x_benefit_programs txbp,
         table(cast(in_vouchers_id_list as sa.typ_vouchers_id_tab)) vchrs
        where
        txv.x_vouchers2benefit = txb.objid
        and
        txbp.objid = txb.benefits2benefit_program
        and
        vchrs.column_value = txv.voucher_id;

      /*CR35343:070615: added new column x_benefit_value to record the redeemed benefit amount*/
        insert into x_voucher_order_hdr (
            objid, order_id, order_source, vendor_id, x_order_date,
            x_order_amount, benefit_amount_used, x_brand, customer_name,
            customer_account_id, customer_min, shipping_address_1, shipping_address_2, shipping_zipcode,
            shipping_city, shipping_state, shipping_country, shipping_amount, shipping_method,
            tax_total, tax_sales, tax_sales_rate, tax_e911, tax_e911_rate,
            tax_usf, tax_usf_rate, tax_rcrf, tax_rcrf_rate, order_status
            , x_benefit_value --CR35343
        )
        values (
          lv_order_hdr_objid, in_order_info.order_id, in_order_info.order_source, in_vendor_id, in_order_info.order_date,
          in_order_info.order_amount, in_order_info.x_benefit_amount, in_order_info.x_brand, in_order_info.customer_name,
          in_order_info.customer_account_id, in_order_info.customer_min, in_order_info.shipping_address_1, in_order_info.shipping_address_2, in_order_info.shipping_zipcode,
          in_order_info.shipping_city, in_order_info.shipping_state, in_order_info.shipping_country, in_order_info.shipping_amount, in_order_info.shipping_method,
          in_order_info.tax_total, in_order_info.tax_sales, in_order_info.tax_sales_rate, in_order_info.tax_e911, in_order_info.tax_e911_rate,
          in_order_info.tax_usf, in_order_info.tax_usf_rate, in_order_info.tax_rcrf, in_order_info.tax_rcrf_rate,
           case
              when nvl(in_settlement_flag,'~') = 'Y' then
                  '982' -----confirmed
              else
                  '981' -----pending
            end
         , lv_benefit_value --CR35343
        );

        --save input order details
        for i in 1..in_order_details_tab.count
        loop
          lv_steps_completed := 10;
          rec_order_det := in_order_details_tab(i);
          insert into x_voucher_order_dtl (
              objid, order_dtl2order_hdr, x_description, x_type, x_part_number,
              x_serial_number, x_quantity, x_market_price, x_sold_price
          )
          values (
              seq_voucher_orders.nextval,lv_order_hdr_objid, rec_order_det.x_description, rec_order_det.x_type, rec_order_det.x_part_number,
              rec_order_det.x_part_serial, rec_order_det.x_quantity, rec_order_det.x_market_price, rec_order_det.x_sold_price
          );
        end loop;

        --- commit;;
        out_transaction_id  := lv_new_auth_trans_id;
        out_err_code        := 0;
        out_err_msg         := 'SUCCESS';
        lv_steps_completed := 11;

    else
        lv_err_code := -324;
        lv_err_msg := 'AUTHORIZATION FAILED. One or more voucher could not be authorized / Settled';
        --dbms_output.put_line (' 324 2 lv_err_msg='|| lv_err_msg);
        raise auth_transaction_failed;

    end if;

  exception
    when auth_input_failed then
      out_err_code        := lv_err_code;
      out_err_msg         := '['|| lv_steps_completed || '] ' ||lv_err_msg;
      out_transaction_id  := null;

    when auth_transaction_failed then
      lv_steps_completed := 12;
      rollback;
      out_err_code        := lv_err_code;
      out_err_msg         := '['|| lv_steps_completed || '] ' || lv_err_msg;
      out_transaction_id  := lv_new_auth_trans_id;

      p_log_voucher_transaction (
                in_vendor_id             => in_vendor_id
                ,in_voucher_objid        => null---vouchers_tab(i).voucher_id
                ,in_order_objid          => null
                ,in_voucher_status       => null---vouchers_tab(i).voucher_status
                ,in_transaction_id       => lv_new_auth_trans_id
                ,in_transaction_type     => '951' -----AUTHORIZATION
                ,in_transaction_notes    => 'FAILED. Trying to authorize / settle Voucher from token = ' || in_voucher_access_token
                ,in_ref_transaction_id   => null
                ,out_err_code            => lv_err_code
                ,out_err_msg             => lv_err_msg
      );

    when others then
      rollback;
      out_transaction_id  := lv_new_auth_trans_id;
      out_err_code        := -99;
      out_err_msg         := '['|| lv_steps_completed || '] p_authorize_voucher_payment=' ||substr(sqlerrm, 1, 2000);

      sa.ota_util_pkg.err_log (
        p_action => 'OTHERS EXCEPTION',
        p_error_date => sysdate,
        p_key => 'CR32367',
        p_program_name => 'p_authorize_voucher_payment',
        p_error_text =>
               'input params: '
              || 'in_voucher_access_token='||in_voucher_access_token
              || ', in_vendor_id='|| in_vendor_id
              || ', out_trans_id= ' || lv_new_auth_trans_id
              || ', out_err_code='||out_err_code
              || ', out_err_msg='|| out_err_msg
              );

  end p_authorize_voucher_payment;

  procedure p_settle_voucher_payment (
            in_auth_trans_id            in number
            ,in_voucher_access_token    in varchar2
            ,in_vendor_id               in varchar2
            ,in_order_id                in varchar2
            ,out_transaction_id         out number
            ,out_err_code               out number
            ,out_err_msg                out varchar2
  ) as

  settle_input_failed         exception;
  settle_transaction_failed   exception;

  lv_settle_succeed         number;
  lv_err_code               number;
  lv_err_msg                varchar2(2000);
  lv_new_settle_trans_id    table_x_voucher_transactions.transaction_id%type;

  lv_token_rec              cur_voucher_token%rowtype;

  db_vouchers               typ_voucher_tab ;
  lv_auth_voucher_cnt       number;
  begin

    if trim(in_vendor_id) is null then
        lv_err_code  :=  -314;
        lv_err_msg   :=  'Error. Please provide value for input IN_VENDOR_ID';
        raise settle_input_failed;

    elsif in_auth_trans_id is null then
        lv_err_code  :=  -326;
        lv_err_msg   :=  'Error. Invalid or Null value received for Input Auth transaction ID';
        raise settle_input_failed;

    elsif trim(in_voucher_access_token) is null then
        lv_err_code  :=  -315;
        lv_err_msg   :=  'Error. Please provide value for input IN_VOUCHER_ACCESS_TOKEN';
        raise settle_input_failed;

    elsif trim(in_order_id) is null then
        lv_err_code  :=  -327;
        lv_err_msg   :=  'Error. Invalid or Null value received for Input Order ID';
        raise settle_input_failed;

    else

        ---check vendor has access to token but dont check token expiry
        open cur_voucher_token(in_voucher_access_token);
        fetch cur_voucher_token into lv_token_rec;
        close cur_voucher_token;

        if in_vendor_id <> nvl(lv_token_rec.vendor_id,'~') then
          lv_err_code        := -317;
          lv_err_msg         := 'Error. Input Vendor [' || in_vendor_id || '] dont have access to Input token [' ||in_voucher_access_token || '] ';
          raise settle_input_failed;
        end if;

        --check input auth trans id is valid and present in database
        lv_err_code := 0;

        begin
          select count(1)
          into lv_err_code
          from table_x_voucher_transactions
          where transaction_id = in_auth_trans_id
          and transaction_type = '951';   --951=authorization transaction
        exception
          when others then
            lv_err_code := 0;
        end;

        --raise error if auth trans id not found
        if lv_err_code = 0 then
            lv_err_code  :=  -326;
            lv_err_msg   :=  'Error. Invalid or Null value received for Input Auth transaction ID';
            raise settle_input_failed;
        end if;

    end if;

    -- get the count of vouchers associated to the transaction id
    select count(*) into lv_auth_voucher_cnt
          from
          table_x_vouchers tv,
          table_x_voucher_transactions tvt
          where tv.objid = tvt.voucher_trans2voucher
          and  tvt.transaction_id = in_auth_trans_id;

    open cur_txn_vouchers(in_auth_trans_id);
    fetch cur_txn_vouchers bulk collect into db_vouchers;
    close cur_txn_vouchers ;

    --generate new transaction id
    lv_new_settle_trans_id :=  f_get_transaction_id ;
    out_transaction_id  :=  lv_new_settle_trans_id;

    lv_settle_succeed := 0;

    --check voucher is authorized and can be settled
    --voucher can be settled only if its authorized and not expired
    for i in 1..db_vouchers.count
    loop
      begin
          if db_vouchers(i).x_expiration_date <= sysdate and db_vouchers(i).x_voucher_status <> '964' then
              begin
                --generate the transaction for the voucher
                p_log_voucher_transaction (
                          in_vendor_id             => in_vendor_id
                          ,in_voucher_objid        => db_vouchers(i).voucher_objid
                          ,in_order_objid          => db_vouchers(i).order_objid
                          ,in_voucher_status       => '964'
                          ,in_transaction_id       => lv_new_settle_trans_id
                          ,in_transaction_type     => '952' -----settlement
                          ,in_transaction_notes    => 'SETTLEMENT FAILED. Cannot settle Voucher since it has been expired'
                          ,in_ref_transaction_id   => in_auth_trans_id
                          ,out_err_code            => lv_err_code
                          ,out_err_msg             => lv_err_msg
                );
                if lv_err_code = 0 then
                  --mark the voucher as expired
                  update table_x_vouchers
                  set x_voucher_status = '964' ---964=expired
                    , x_update_date = sysdate
                  where objid = db_vouchers(i).voucher_objid;

                  --mark the benefits as available
                  update table_x_benefits
                  set x_status = '961'
                    , x_update_date = sysdate
                  where objid = db_vouchers(i).benefit_objid;

                  --mark the voucher order as cancelled
                  update x_voucher_order_hdr
                  set order_status = '983'
                    , order_id = in_ordeR_id
                    , x_update_date = sysdate
                  where objid = db_vouchers(i).order_objid;
                end if;
                lv_err_msg := 'One of the Voucher cannot be Settled';
              end;

          elsif db_vouchers(i).x_voucher_status = '973' then  --973=authorized
              begin
                  --generate the transaction for the voucher
                  p_log_voucher_transaction (
                            in_vendor_id             => in_vendor_id
                            ,in_voucher_objid        => db_vouchers(i).voucher_objid
                            ,in_order_objid          => db_vouchers(i).order_objid
                            ,in_voucher_status       => '974'
                            ,in_transaction_id       => lv_new_settle_trans_id
                            ,in_transaction_type     => '952' -----settlement
                            ,in_transaction_notes    => 'Voucher has been Settled from token = ' || in_voucher_access_token
                            ,in_ref_transaction_id   => null
                            ,out_err_code            => lv_err_code
                            ,out_err_msg             => lv_err_msg
                  );

                  if lv_err_code = 0 then

                    --dbms_output.put_line('log settle txn response='|| lv_err_code );

                    --mark the voucher as settled
                    update table_x_vouchers
                    set x_voucher_status = '974' ---974=settled
                      , x_update_date = sysdate
                    where objid = db_vouchers(i).voucher_objid;

                    --mark the benefits as used
                    update table_x_benefits
                    set x_status = '963'
                      , x_notes = 'Benefits are used and settled by the voucher'
                      , x_update_date = sysdate
                    where objid = db_vouchers(i).benefit_objid;

                    --mark the voucher order as confirmed
                    update x_voucher_order_hdr
                    set order_status = '982'
                      , ordeR_id = in_order_id
                      , x_update_date = sysdate
                    where objid = db_vouchers(i).order_objid;

                    lv_settle_succeed := lv_settle_succeed + 1;
                  end if;
              end;
          else
              lv_err_msg := 'One of the Voucher is not Authorized';
          end if;
      end ;
    end loop;

      --  if db_vouchers.count  = lv_settle_succeed then commenting due to defect
      --- commit;;
      if lv_auth_voucher_cnt = lv_settle_succeed -- using the auth count to fix defect
      then
      out_err_code        := 0;
      out_err_msg         := 'SUCCESS';
    else
      raise settle_transaction_failed;
    end if;


  exception
    when settle_input_failed then
      out_err_code        := lv_err_code;
      out_err_msg         := lv_err_msg;
      out_transaction_id  := null;

    when settle_transaction_failed then
      rollback;
      out_err_code        := -328;
      out_err_msg         := 'SETTLEMENT FAILED. One or more voucher could not be Settled';

    when others then
      rollback;
      out_err_code        := -99;
      out_err_msg         := 'p_settle_voucher_payment='||substr(sqlerrm, 1, 2000);
  end p_settle_voucher_payment;

  procedure p_cancel_voucher_payment (
            in_auth_trans_id            in number
            ,in_voucher_access_token    in varchar2
            ,in_vendor_id               in varchar2
            ,in_order_id                in varchar2
            ,out_transaction_id         out number
            ,out_err_code               out number
            ,out_err_msg                out varchar2
  ) as

  lv_new_cancel_trans_id      number;
  cancel_input_failed         exception;
  cancel_voucher_failed       exception;

  lv_cancel_succeed           number;
  lv_err_code                 number;
  lv_err_msg                  varchar2(2000);

  lv_token_rec              cur_voucher_token%rowtype;

  db_vouchers               typ_voucher_tab ;
  lv_auth_voucher_cnt       number;
  begin

  lv_cancel_succeed := 0;

    if trim(in_vendor_id) is null then
        lv_err_code  :=  -314;
        lv_err_msg   :=  'Error. Please provide value for input IN_VENDOR_ID';
        raise cancel_input_failed;

    elsif trim(in_voucher_access_token) is null then
        lv_err_code  :=  -315;
        lv_err_msg   :=  'Error. Please provide value for input IN_VOUCHER_ACCESS_TOKEN';
        raise cancel_input_failed;

    elsif in_auth_trans_id is null then
        lv_err_code  :=  -326;
        lv_err_msg   :=  'Error. Invalid or Null value received for Input Auth transaction ID';
        raise cancel_input_failed;

    else
        --check input auth trans id is valid and present in database
        lv_err_code := 0;

        begin
          select count(1)
          into lv_err_code
          from table_x_voucher_transactions
          where transaction_id = in_auth_trans_id
          and transaction_type = '951';   --951=authorization transaction
        exception
          when others then
            lv_err_code := 0 ;
        end;

        --raise error if auth trans id not found
        if lv_err_code = 0 then
            lv_err_code  :=  -326;
            lv_err_msg   :=  'Error. Invalid or Null value received for Input Auth transaction ID';
            raise cancel_input_failed;
        end if;

    end if;

    -- get the count of vouchers associated to the transaction id
    select count(*) into lv_auth_voucher_cnt
          from
          table_x_vouchers tv,
          table_x_voucher_transactions tvt
          where tv.objid = tvt.voucher_trans2voucher
          and  tvt.transaction_id = in_auth_trans_id;

    --dbms_output.put_line ('count:'|| lv_auth_voucher_cnt);

    open cur_vouchers (in_voucher_access_token);
    fetch cur_vouchers bulk collect into db_vouchers;
    close cur_vouchers ;

    if db_vouchers.count = 0 then
        lv_err_code  :=  -335;
        lv_err_msg   :=  'Error. Input Voucher Token does not match with Input Auth Transaction ID';
        raise cancel_input_failed;
    end if;

    --generate new transaction id
    lv_new_cancel_trans_id      := f_get_transaction_id ;
    out_transaction_id  := lv_new_cancel_trans_id;

    for i in 1..db_vouchers.count
    loop
          if db_vouchers(i).x_expiration_date <= sysdate and db_vouchers(i).x_voucher_status <> '964' then
              begin
                --log the transaction for the voucher
                p_log_voucher_transaction (
                          in_vendor_id             => in_vendor_id
                          ,in_voucher_objid        => db_vouchers(i).voucher_objid
                          ,in_order_objid          => db_vouchers(i).order_objid
                          ,in_voucher_status       => '964'
                          ,in_transaction_id       => lv_new_cancel_trans_id
                          ,in_transaction_type     => '953' -----cancellation
                          ,in_transaction_notes    => 'Voucher has been Expired from token = ' || in_voucher_access_token
                                                      || '. earlier status ='|| db_vouchers(i).x_voucher_status
                          ,in_ref_transaction_id   => null
                          ,out_err_code            => lv_err_code
                          ,out_err_msg             => lv_err_msg
                );

                if lv_err_code = 0 then
                    update table_x_vouchers
                    set x_voucher_status = '964' ---964=expired
                      , x_update_date = sysdate
                    where objid = db_vouchers(i).voucher_objid;
                    lv_err_msg := 'One of the Voucher cannot be canceled since it is expired due to timeout';

                    --mark the benefits as available since voucher is not used
                    update table_x_benefits
                    set x_status = '961'    --961=available
                      , x_update_date = sysdate
                    where objid = db_vouchers(i).benefit_objid;

                    --mark the voucher order as cancelled
                    update x_voucher_order_hdr
                    set order_status = '983'
                      , x_update_date = sysdate
                    where objid = db_vouchers(i).order_objid;

                end if;
              end;

          elsif db_vouchers(i).x_voucher_status = '974' then  --974=settled
              null;
              lv_err_msg := 'One of the Voucher cannot be canceled since it is already Settled';
              --what to do here

          elsif db_vouchers(i).x_voucher_status = '973' then  --973=authorized
              begin

                --log the transaction for the voucher
                p_log_voucher_transaction (
                          in_vendor_id             => in_vendor_id
                          ,in_voucher_objid        => db_vouchers(i).voucher_objid
                          ,in_order_objid          => db_vouchers(i).order_objid
                          ,in_voucher_status       => db_vouchers(i).x_voucher_status
                          ,in_transaction_id       => lv_new_cancel_trans_id
                          ,in_transaction_type     => '953' -----cancel
                          ,in_transaction_notes    => 'Voucher has been Canceled from token = ' || in_voucher_access_token
                          ,in_ref_transaction_id   => null
                          ,out_err_code            => lv_err_code
                          ,out_err_msg             => lv_err_msg
                );
                if lv_err_code = 0 then
                  --mark the voucher as canceled
                  update table_x_vouchers
                  set x_voucher_status = '975' ---975=canceled
                    , x_update_date = sysdate
                  where objid = db_vouchers(i).voucher_objid;

                  --mark the benefits as available
                  update table_x_benefits
                  set x_status = '961'    --961=available
                    , x_update_date = sysdate
                    , x_notes = 'Benefit made available on voucher cancellation'
                  where objid = db_vouchers(i).benefit_objid;

                  --mark the voucher order as cancelled
                  update x_voucher_order_hdr
                  set order_status = '983'
                    , x_update_date = sysdate
                  where objid = db_vouchers(i).order_objid;

                lv_cancel_succeed := lv_cancel_succeed + 1;

                else
                  raise cancel_voucher_failed;
                end if;

              end;
          else
              lv_err_msg := 'One of the Voucher is not Authorized';
          end if;
    end loop;

    --dbms_output.put_line('lv_cancel_succeed:'||lv_cancel_succeed);
    --- commit;;

   -- if lv_cancel_succeed = db_vouchers.count then -- fixed as below
   if lv_cancel_succeed = lv_auth_voucher_cnt
      then
      out_err_code        := 0;
      out_err_msg         := 'SUCCESS';
    else
      out_err_code        := 405;
      out_err_msg         := 'One of the voucher cannot be canceled since its Settled / already Canceled';
    end if;

  exception
    when cancel_input_failed then
      out_err_code        := lv_err_code;
      out_err_msg         := lv_err_msg;
      out_transaction_id  := null;

    when others then
      rollback;
      out_err_code        := -99;
      out_err_msg         := 'p_cancel_voucher_payment='||substr(sqlerrm, 1, 2000);
  end p_cancel_voucher_payment;

  function f_is_pin_refundable (
             in_service_plan_pin   in number
  ) return boolean
  is
    lv_return_value   boolean  := true;
    lv_number         number := 0;
    lv_q_number         number := 0;
    lv_flag_rec_cnt   number := 0;
    lv_upgrd_plan_flg varchar2(1); --vs 05/01/15
    lv_service_plan_pin varchar2(30);

  begin
    begin

      lv_service_plan_pin := to_char(in_service_plan_pin);

         /** 05/01/2015 : VS: identifying if the PIN is associated to upgrade plan**/
         select  upgrd_plan_flg
                     into lv_upgrd_plan_flg
                     from (
          select distinct
                     nvl2(rpv.service_plan_objid, 'Y', 'N') as  upgrd_plan_flg
              from table_part_inst pi, table_part_num pn, table_mod_level ml, table_part_class pc,
              (SELECT sp.objid serv_objid,
                    pc.objid part_class_objid,
                    pc.name part_class_name,
                    sp.objid service_plan_objid,
                    sp.mkt_name
                  FROM X_SERVICEPLANFEATUREVALUE_DEF spfvdef,
                    X_SERVICEPLANFEATURE_VALUE spfv,
                    X_SERVICE_PLAN_FEATURE spf,
                    X_Serviceplanfeaturevalue_Def Spfvdef2,
                    X_Serviceplanfeaturevalue_Def Spfvdef3,
                    X_Service_Plan Sp,
                    Mtm_Partclass_X_Spf_Value_Def Mtm,
                    table_part_class pc
                  WHERE spf.sp_feature2rest_value_def = spfvdef.objid
                  AND spf.objid                       = spfv.spf_value2spf
                  AND Spfvdef2.Objid                  = Spfv.Value_Ref
                  AND Spfvdef3.Objid (+)              = Spfv.Child_Value_Ref
                  AND Spfvdef.Value_Name              = 'SUPPORTED PART CLASS'
                  AND Sp.Objid                        = Spf.Sp_Feature2service_Plan
                  AND Spfvdef2.Objid                  = Mtm.Spfeaturevalue_Def_Id
                  AND Pc.Objid                        = Mtm.Part_Class_Id
                  ) sp_pc_table
                  ,x_reward_point_values rpv
              where pi.n_part_inst2part_mod=ml.objid
              and ml.part_info2part_num=pn.objid
              and pn.domain='REDEMPTION CARDS'
              and pn.part_num2part_class=pc.objid
              and pi.x_red_code = lv_service_plan_pin
              and sp_pc_table.part_class_objid = pc.OBJID
              and sp_pc_table.service_plan_objid = rpv.service_plan_objid(+)
              union -- CR32367:SQA2166:ITQ136:VS:05/20/15:union to find burnt card's plan
              SELECT distinct nvl2(rpv.service_plan_objid, 'Y', 'N') as  upgrd_plan_flg
              FROM   table_part_num pn,
                     table_mod_level ml,
                     table_x_red_card rc,
                     adfcrm_serv_plan_class_matview apcmv,
                     x_reward_point_values rpv
              WHERE  rc.x_red_code = lv_service_plan_pin
              AND    rc.x_red_card2part_mod = ml.objid
              AND    ml.part_info2part_num  = pn.objid
              AND    apcmv.part_class_objid = pn.part_num2part_class
              AND    pn.domain = 'REDEMPTION CARDS'
              AND   rpv.service_plan_objid(+) = apcmv.sp_objid )
              ;

       if lv_upgrd_plan_flg = 'N'
       then
       lv_return_value := true;
       else
       -- if the PIN is under upgrades plan then

       select count(*)
       into lv_flag_rec_cnt
       from table_x_point_trans pt, table_x_red_card rc
       where pt.point_trans2ref_table_objid = rc.red_card2call_trans
       and pt.ref_table_name = 'TABLE_X_CALL_TRANS'
       and rc.x_red_code = lv_service_plan_pin
       and pt.x_points = 0
       and pt.x_points_action = 'REFUND';

         if lv_flag_rec_cnt > 0 -- if block that checks inside upgrade plans
         then
         lv_return_value := false;

         else
          --input redemption pin is refundable only if the benefits earned through that pin are available
          --if the benefits earned are Unavailable/used/expired  then the pin is not refundable

            select count(*)
            into lv_number
            from table_x_red_card rc
              , table_x_point_trans pt
              , table_x_benefits tb
            where 1=1
            and rc.x_red_code = lv_service_plan_pin
            and rc.red_card2call_trans = pt.point_trans2ref_table_objid
            and pt.ref_table_name = 'TABLE_X_CALL_TRANS'
            and tb.objid = pt.point_trans2benefit
            and tb.x_status <> '961'; --available

            --SQA2922 05262015 VS
            if nvl(lv_number,0) = 0
            then
             select count(*)
             into lv_q_number
            from table_x_call_trans rc
              , table_x_point_trans pt
              , table_x_benefits tb
            where 1=1
            and rc.x_reason = lv_service_plan_pin
            and rc.objid = pt.point_trans2ref_table_objid
            and pt.ref_table_name = 'TABLE_X_CALL_TRANS'
            and tb.objid = pt.point_trans2benefit
            and tb.x_status <> '961';
            end if ;

            if (lv_number > 0 or lv_q_number > 0)  -- the benefit exists in a non-avaliable state
             then
             lv_return_value := false;
             else -- either benefit doesnt exist or its in availabale state
             lv_return_value := true;
            end if ;

          end if; -- closing the if block that checks inside upgrade plans
        end if;

    exception
      when others then
        lv_return_value := TRUE;
    end;

    return lv_return_value ;

  end f_is_pin_refundable;

  procedure p_remove_pin_benefits  (
             in_service_plan_pin       in varchar2
            ,out_err_code             out number
            ,out_err_msg              out varchar2
  ) as

    lv_remove_succeed         number;
    lv_err_code               number;
    lv_err_msg                varchar2(2000);
    lv_acc_pts                number;
    lv_acc_objid              number;
    lv_recalc_total           number;

    remove_input_failed exception;

    /*vs:05/02/15
    Find the points and benefits associated to the redemption pin that is
    issued. An outer join to benefits and points is necessary because there
    can be cases where there are no benefits that are asscoaited to a point yet
    and there can be cases where redemption point has not made it to point trans
    table yet*/
    cursor cur_pin_benefits (in_pin in varchar2
                             ) is
      select
        rc.objid      as red_card_objid
        , rc.red_card2call_trans
        , tb.objid    as benefit_objid
        , tb.x_status as benefit_status
        , pt.objid    as point_trans_objid
        , pt.x_min
        , pt.x_esn
        , pt.x_points
        , pt.x_points_category
        , pt.point_trans2site_part  as site_part_objid
        , pt.point_trans2service_plan as service_plan_objid
        , pt.point_trans2point_account as point_account_objid
        , pt.point_trans2benefit
      from table_x_red_card rc
        , table_x_point_trans pt
        , table_x_benefits tb
      where 1=1
      and rc.x_red_code = in_pin
      and rc.red_card2call_trans = pt.point_trans2ref_table_objid(+)
      and pt.ref_table_name(+) = 'TABLE_X_CALL_TRANS'
      and pt.point_trans2benefit = tb.objid (+)
      and rc.red_card2call_trans is not null
      union   -- CR32367:VS:05/14/15 Following union is in place to take care of Queue cards
       select
        ct.objid      as red_card_objid
        , ct.objid
        , tb.objid    as benefit_objid
        , tb.x_status as benefit_status
        , pt.objid    as point_trans_objid
        , pt.x_min
        , pt.x_esn
        , pt.x_points
        , pt.x_points_category
        , pt.point_trans2site_part  as site_part_objid
        , pt.point_trans2service_plan as service_plan_objid
        , pt.point_trans2point_account as point_account_objid
        , pt.point_trans2benefit
        from
      table_x_call_trans ct
      ,table_x_point_trans pt
      ,table_x_benefits tb
      where
      ct.objid = pt.point_trans2ref_table_objid(+)
      and ct.x_service_id = pt.x_esn(+)
      and pt.ref_table_name(+) = 'TABLE_X_CALL_TRANS'
      and pt.point_trans2benefit = tb.objid (+)
      and ct.x_service_id = '999999999999999999'
      and ct.x_reason||'' = in_pin
      and ct.x_action_type = '401'
      ;

    rec_pin_benefits      cur_pin_benefits%rowtype;
    lv_calculate_flg    varchar2(1) := 'N';
    lv_pts_objid   number;
  begin
    if in_service_plan_pin is null then
      lv_err_code        := -329;
      lv_err_msg         := 'Error. Invalid or Null value received for Input Pin';
      raise remove_input_failed ;
    end if;

    --see if any benefits were delivered using the input pin
    --if no benefits are there then return err code 404
    open cur_pin_benefits(in_service_plan_pin);
    fetch cur_pin_benefits into rec_pin_benefits ;
    close cur_pin_benefits;

    /*vs: 02/05/15 commented out as there can be point that need to be removed
      that are not associated to benefit yet.
      if rec_pin_benefits.benefit_objid is null then
      lv_err_code        := 404;
      lv_err_msg         := 'No benefits found in database to be removed for Input redemption Pin [' || in_service_plan_pin || ']';
      raise remove_input_failed ;*/

   if rec_pin_benefits.benefit_objid is not null
      and rec_pin_benefits.benefit_status <> '961' then --961=available
      lv_err_code        := -330;
      lv_err_msg         := 'Cannot remove the benefits since benefits are already used';
      raise remove_input_failed ;
    end if;

    --if benefits are available then
    --make the benefits REMOVED, mention in x_notes
    --subtract the points for the pin
    --recalculate the points
    --commit
    if rec_pin_benefits.benefit_status = '961' then --961=available
      begin

        /***070215 CR35343: select the availble pts on the account using ESN***/
         select total_points , objid
         into lv_acc_pts , lv_acc_objid
         from table_x_point_account
         where objid = rec_pin_benefits.point_account_objid
         and account_status = 'ACTIVE';

          if rec_pin_benefits.x_points > lv_acc_pts  --if block added for CR35343
          then

          update table_x_benefits
          set x_status = '967'  --967=benefit removed
            , x_update_date = sysdate
            , x_notes = 'benefits have been removed since PIN [' || in_service_plan_pin || '] is refunded'
          where objid = rec_pin_benefits.benefit_objid;

           --revert the points back (those points which were converted to benefit)
          lv_pts_objid:= seq_x_point_trans.nextval;

           insert into table_X_point_trans
          select
            lv_pts_objid --objid
            , sysdate   --X_TRANS_DATE
            , x_min
            , x_esn
            , -1 * (x_points)   --X_POINTS
            , x_points_category
            , 'CONVERT'   --X_POINTS_ACTION -- CR35343:070215 changing to CONVERT from ADD
            , 'Points added back because of PIN refund; the benefits associated are removed' ---POINTS_ACTION_REASON
            , point_trans2ref_table_objid
            , ref_table_name
            , point_trans2service_plan
            , point_trans2point_account
            , point_trans2purchase_objid
            , purchase_table_name
            , point_trans2site_part
            , null      ----dont set any benefit-id here; this refund can be used to get new benefit
            ,'Restored from Benefit'
          from table_x_point_trans
          where 1=1
          and point_trans2point_account = rec_pin_benefits.point_account_objid
          and ref_table_name = 'TABLE_X_BENEFITS'
          and point_trans2ref_table_objid = rec_pin_benefits.benefit_objid
          and x_points_action = 'CONVERT'
          ;


           /*****CR35343 change to address QC2358******/
           select     (x_points)
           into
            lv_recalc_total
           from table_x_point_trans
           where 1=1
           and objid = lv_pts_objid;


            /*CR35343 change to address QC2358*/
             update table_x_point_trans
             set POINT_TRANS2BENEFIT = null
             where
             POINT_TRANS2BENEFIT = rec_pin_benefits.benefit_objid
             --QC4142 08/13/2015
             and  x_points <> -18
             and  x_points_action <> 'CONVERT';

            /*****CR35343 change to address QC2358
             updating the total here as the point trans cleared of benefits
             and need to be added to point account total. calculate points will
             ignore old transactions******/
           update table_x_point_account acc
           set total_points = nvl(total_points,0) + nvl(lv_recalc_total, 0)
           --,x_last_calc_date = sysdate
           where
           acc.objid = lv_acc_objid
           and account_status = 'ACTIVE';


          end if ; --CR35343


          --now subtract the actual points because of PIN refund
          insert into table_x_point_trans (
            objid,
            x_trans_date,
            x_min,
            x_esn,
            x_points,
            x_points_category,
            x_points_action,
            points_action_reason,
            point_trans2ref_table_objid,
            ref_table_name,
            point_trans2service_plan,
            point_trans2point_account,
            point_trans2purchase_objid,
            purchase_table_name,
            point_trans2site_part,
            point_trans2benefit,
            point_display_reason
            )
          values (
            sa.seq_x_point_trans.nextval
            ,sysdate
            ,rec_pin_benefits.x_min
            ,rec_pin_benefits.x_esn
            ,-1 * (rec_pin_benefits.x_points)
            ,rec_pin_benefits.x_points_category
            ,'DEDUCT' --is this correct action ?
            ,'Benefits associated with this point transaction were removed.'
            ,rec_pin_benefits.red_card2call_trans
            ,'TABLE_X_CALL_TRANS'
            ,rec_pin_benefits.service_plan_objid
            ,rec_pin_benefits.point_account_objid
            ,null
            ,null
            ,rec_pin_benefits.site_part_objid
            ,null --SQA#2335 052715
            ,'AT Card Refund'
            );

          lv_calculate_flg := 'Y';
      exception
      when others then
      null;
      end;
     /*************************************************************************
      vs:05/02/15
      the case where a redemption card was refunded and there is point associated
      to that is not yet converted to benefit
      **************************************************************************/
      elsif ( rec_pin_benefits.benefit_objid is null and rec_pin_benefits.point_trans_objid is not null
             and rec_pin_benefits.x_points > 0 )
      then
       insert into table_x_point_trans (
            objid,
            x_trans_date,
            x_min,
            x_esn,
            x_points,
            x_points_category,
            x_points_action,
            points_action_reason,
            point_trans2ref_table_objid,
            ref_table_name,
            point_trans2service_plan,
            point_trans2point_account,
            point_trans2purchase_objid,
            purchase_table_name,
            point_trans2site_part,
            point_trans2benefit,
            point_display_reason
            )
          values (
            sa.seq_x_point_trans.nextval
            ,sysdate
            ,rec_pin_benefits.x_min
            ,rec_pin_benefits.x_esn
            ,-1 * (rec_pin_benefits.x_points)
            ,rec_pin_benefits.x_points_category
            ,'DEDUCT' --is this correct action ?
            ,'Point earning Redemption card got refunded'
            ,rec_pin_benefits.red_card2call_trans
            ,'TABLE_X_CALL_TRANS'
            ,rec_pin_benefits.service_plan_objid
            ,rec_pin_benefits.point_account_objid
            ,null
            ,null
            ,rec_pin_benefits.site_part_objid
            ,null --SQA#2335 052715
            ,'AT Card Refund'
            );

            lv_calculate_flg := 'Y';
      /*************************************************************************
      vs:05/02/15
      the case where a redemption card was refunded and there is still no points
      delivered for this card in the Point transaction table. It can kick in when
      the upgrade poins job runs next and add a point. to prevent this we add a
      flag record with 0 points so that the call trans look up ignores this
      transaction.
      **************************************************************************/
      elsif (rec_pin_benefits.point_trans_objid is null and
             rec_pin_benefits.red_card2call_trans is not null)
      then
       insert into table_x_point_trans (
            objid,
            x_trans_date,
            x_min,
            x_esn,
            x_points,
            x_points_category,
            x_points_action,
            points_action_reason,
            point_trans2ref_table_objid,
            ref_table_name,
            point_trans2service_plan,
            point_trans2point_account,
            point_trans2purchase_objid,
            purchase_table_name,
            point_trans2site_part,
            point_trans2benefit
            )
          values (
            sa.seq_x_point_trans.nextval
            ,sysdate
            ,rec_pin_benefits.x_min
            ,rec_pin_benefits.x_esn
            ,0 -- 0 points as this is a flag record
            ,rec_pin_benefits.x_points_category
            ,'NOTE' --is this correct action ?
            ,'Flag record to prevent points job from adding points for refunded PIN'
            ,rec_pin_benefits.red_card2call_trans
            ,'TABLE_X_CALL_TRANS'
            ,rec_pin_benefits.service_plan_objid
            ,rec_pin_benefits.point_account_objid
            ,null
            ,null
            ,rec_pin_benefits.site_part_objid    --null
            ,null --SQA#2335 052715
            );
    -- dont have to make a calculate points call in this case as this is a flag record
    end if;

    -- call the calculate points proc if any changes to points or benefit was made
    if (lv_calculate_flg = 'Y')
    then
    --dbms_output.put_line('before sleep: '||sysdate);
    --setting sleep to make sure teh calculation picks up teh recent transaction correctly
    --DBMS_LOCK.SLEEP(1);
    dbms_output.put_line('calling calculate from refund: '||sysdate);
          reward_points_pkg.p_calculate_points (
              in_min        => rec_pin_benefits.x_min
              , out_err_code  => lv_err_code
              , out_err_msg   => lv_err_msg
          );

         p_create_reward_benefits (
                in_min  =>  rec_pin_benefits.x_min
                ,out_err_code => out_err_code
                ,out_err_msg => out_err_msg
          );
    end if;

    out_err_code        := 0;
    out_err_msg         := 'SUCCESS';

  exception
    when remove_input_failed then
      rollback;
      out_err_code        := lv_err_code;
      out_err_msg         := lv_err_msg;

    when others then
      rollback;
      out_err_code        := -99;
      out_err_msg         := 'p_remove_pin_benefits=' || substr(sqlerrm, 1, 2000);
  end p_remove_pin_benefits;

  procedure p_refund_voucher_payment (
            in_settlement_trans_id      in number
            ,in_voucher_access_token    in varchar2
            ,in_vendor_id               in varchar2
            ,in_order_id                in varchar2
            ,out_transaction_id         out number
            ,out_err_code               out number
            ,out_err_msg                out varchar2
  ) as
    refund_input_failed       exception;
    lv_err_code               number;
    lv_err_msg                varchar2(2000);

    lv_new_refund_trans_id    number;

    lv_token_rec              cur_voucher_token%rowtype;

    cursor cur_voucher_benefits (in_token in varchar2) is
      select
        tv.objid as voucher_objid
        , tv.voucher_id
        , tv.x_token_id
        , tv.x_created_date
        , tv.x_expiration_date
        , tv.x_voucher_status
        , tv.x_vouchers2benefit    as benefit_objid
        , tv.x_vouchers2order_hdr  as order_objid
        , tb.x_status as benefit_status
        , tb.x_benefit_owner_type
        , tb.x_benefit_owner_value
        , tb.benefits2benefit_program
        , tb.x_expiry_date
      from table_x_vouchers tv
        , table_x_benefits tb
      where 1=1
      and tv.x_token_id = in_token
      and tb.objid = tv.x_vouchers2benefit
      and tv.x_voucher_status = '974' --voucher is settled
      and tb.x_status = '963'       --benefit is used
      ;

      type typ_voucher_benefit is table of cur_voucher_benefits%rowtype index by pls_integer;

      tab_voucher_benefit typ_voucher_benefit;

  begin
    if trim(in_vendor_id) is null then
        lv_err_code  :=  -314;
        lv_err_msg   :=  'Error. Please provide value for input IN_VENDOR_ID';
        raise refund_input_failed;

    elsif in_settlement_trans_id is null then
        lv_err_code  :=  -326;
        lv_err_msg   :=  'Error. Invalid or Null value received for Input Settlement transaction ID';
        raise refund_input_failed;

    elsif trim(in_voucher_access_token) is null then
        lv_err_code  :=  -315;
        lv_err_msg   :=  'Error. Please provide value for input IN_VOUCHER_ACCESS_TOKEN';
        raise refund_input_failed;

    elsif trim(in_order_id) is null then
        lv_err_code  :=  -327;
        lv_err_msg   :=  'Error. Invalid or Null value received for Input Order ID';
        raise refund_input_failed;

    else

        --check whether input vendor have access to input token
        open cur_voucher_token(in_voucher_access_token);
        fetch cur_voucher_token into lv_token_rec;
        close cur_voucher_token;

        if in_vendor_id <> nvl(lv_token_rec.vendor_id,'~') then
          lv_err_code        := -317;
          lv_err_msg         := 'Error. Input Vendor [' || in_vendor_id || '] dont have access to Input token [' ||in_voucher_access_token || '] ';
          raise refund_input_failed;
        end if;

        --check input auth trans id is valid and present in database
        lv_err_code := 0;

        begin
          select count(1)
          into lv_err_code
          from table_x_voucher_transactions
          where transaction_id = in_settlement_trans_id
          and transaction_type = '952';   --952=settlement transaction
        exception
          when others then
            lv_err_code := 0;
        end;

        if lv_err_code > 0 then
          null;
        else
          lv_err_code  :=  -326;
          lv_err_msg   :=  'Error. Invalid or Null value received for Input Settlement Transaction ID';
          raise refund_input_failed;
        end if;

    end if;


    --verify that Refund is already processed; if its already processed then return error
    lv_err_code := 0;
    begin
      select count(1)
      into lv_err_code
      from table_x_voucher_transactions
      where ref_transaction_id = in_settlement_trans_id
      and transaction_type = '954';   --954=refund transaction
    exception
      when others then
        lv_err_code := 0;
    end;
   -- dbms_output.put_line('checking duplicate refund...'||lv_err_code);

    if lv_err_code > 0 then
      lv_err_code  :=  -337;
      lv_err_msg   :=  'Error. Refund is already processed for Input Settlement Transaction ID';
      raise refund_input_failed;
    end if;

    --generate new transaction id
    lv_new_refund_trans_id :=  f_get_transaction_id ;
    out_transaction_id  := lv_new_refund_trans_id;

    open cur_voucher_benefits (in_voucher_access_token);
    fetch cur_voucher_benefits bulk collect into tab_voucher_benefit;
    close cur_voucher_benefits;

    if tab_voucher_benefit.count = 0 then
      dbms_output.put_line('no vouchers to refund');
    end if;

    --for each refunded voucher follow below steps
    for i in 1..tab_voucher_benefit.count
    loop
      --pull vouchers and benefits for token
      --log the transaction
      p_log_voucher_transaction (
                in_vendor_id             => in_vendor_id
                ,in_voucher_objid        => tab_voucher_benefit(i).voucher_objid
                ,in_order_objid          => tab_voucher_benefit(i).order_objid
                ,in_voucher_status       => '976'
                ,in_transaction_id       => lv_new_refund_trans_id
                ,in_transaction_type     => '954' -----954=refund
                ,in_transaction_notes    => 'Trying to Refund Voucher from token = ' || in_voucher_access_token
                ,in_ref_transaction_id   => in_settlement_trans_id
                ,out_err_code            => lv_err_code
                ,out_err_msg             => lv_err_msg
      );
      if lv_err_code = 0 then

            --update the voucher orders as Refunded
            update x_voucher_order_hdr
            set order_status = '984'
            , x_update_date = sysdate
            where objid = tab_voucher_benefit(i).order_objid;

            --update voucher as REFUNDED,
            update table_x_vouchers
            set x_voucher_status = '976'
            , x_update_date = sysdate
            where objid = tab_voucher_benefit(i).voucher_objid;

            --update benefit as available o
            update table_x_benefits
            set x_status = '961'
            , x_notes = 'this Benefit has been refunded using Voucher OBJID='|| tab_voucher_benefit(i).voucher_objid
            , x_update_date = sysdate
            where objid = tab_voucher_benefit(i).benefit_objid;

            --create new benefits in AVAILABLE status which are exactly same as above REFUNDED benefits
            -- vs:05/01/2015  removing logic to add new benefit on refund.
          /*  insert into table_x_benefits   (
                objid,
                x_benefit_owner_type,
                x_benefit_owner_value,
                x_created_date,
                x_status,
                x_notes,
                benefits2benefit_program,
                x_update_date,
                x_expiry_date
            )
            values   (
                seq_x_benefits.nextval
                ,tab_voucher_benefit(i).x_benefit_owner_type
                ,tab_voucher_benefit(i).x_benefit_owner_value
                ,sysdate
                ,'961'
                ,'Benefits created as a result of Voucher Refund'
                ,tab_voucher_benefit(i).benefits2benefit_program
                ,null
                ,tab_voucher_benefit(i).x_expiry_date
            );
            */
            --mark this new benefits record as earned due to refund existing voucher
            --no need to create new vouchers for above REFUNDED vouchers since those will be created runtime whenever customer want to use
      end if;
    end loop;

    out_err_code        := 0;
    out_err_msg         := 'SUCCESS';

  exception
    when refund_input_failed then
      out_err_code        := lv_err_code;
      out_err_msg         := lv_err_msg;
      out_transaction_id  := null;

    when others then
      rollback;
      out_err_code        := -99;
      out_err_msg         := 'p_refund_voucher_payment='|| substr(sqlerrm, 1, 2000);
  end p_refund_voucher_payment;

  function f_get_effective_service_plan (
            in_key                      in varchar2
            ,in_value                   in varchar2
  )
  return varchar2
  is
  ---this function accepts input as ESN or MIN
  ---and returns the service plan that mostly used by ESN/MIN to earn the reward points
  ---if there are 2 or more service plans at same # of times then
  ---if returns the service plan based on priority set in x_reward_point_values
  ---the returned service plan is the efective service plan that may give any upgrade benefits

    cursor cur_points_plan_used is
      select
        distinct pt.point_trans2service_plan as plan_used
        ,pa.objid as point_account_objid
        ,pa.bus_org_objid
        ,count(point_trans2service_plan) over (partition by pt.point_trans2service_plan order by pt.point_trans2service_plan )
        as plan_frequency
      from table_x_point_trans pt, table_X_point_account pa
      where 1=1
      and ( (pa.x_min = in_value and in_key = 'MIN')  or  (pa.x_esn = in_value and in_key = 'ESN') )
      and pa.account_status = 'ACTIVE'
      and pt.point_trans2point_account = pa.objid ---99807 --rtrp
      and pa.x_points_category = pt.x_points_category
      and pt.x_points_category = lc_point_category_reward
      and pt.x_points_action in ('ADD', 'ESNUPGRADE')
      and pt.point_trans2service_plan is not null
      and pt.point_trans2benefit is null
      ;

    type typ_points_plan_tab is table of cur_points_plan_used%rowtype index by pls_integer;

    points_plan_tab           typ_points_plan_tab ;
    lv_service_plan_used      number;
    lv_service_plan_frequency number;
    lv_service_plan_priority  number;
    lv_benefit_program_id     number;
    lv_x_benefits_objid       number;

    lv_service_plan_name      x_service_plan.mkt_name%type;


  begin
     -- dbms_output.put_line('STARTED ');
      lv_service_plan_used      := 0;
      lv_service_plan_frequency := 0;
      lv_service_plan_priority  := 0;
      lv_benefit_program_id     := null;

      for jrec in cur_points_plan_used
      loop
          --dbms_output.put_line('checking the serv.plan');
          begin
            if jrec.plan_frequency > lv_service_plan_frequency then
              lv_service_plan_used      := jrec.plan_used;
              lv_service_plan_frequency := jrec.plan_frequency;
              lv_service_plan_priority  := null;
              --no need to check priority here since its clear that what plan is used


            elsif jrec.plan_frequency = lv_service_plan_frequency then
              null;
              --if its a tie then get the service plan based on priority defined from the table
              select tt.service_plan_objid, tt.benefit_program_objid, tt.x_priority
              into lv_service_plan_used, lv_benefit_program_id, lv_service_plan_priority
              from x_reward_point_values tt
              where 1=1
              and tt.service_plan_objid in (lv_service_plan_used, jrec.plan_used)
              and tt.bus_org_objid = jrec.bus_org_objid
              and sysdate between tt.x_start_date and tt.x_end_date
              and tt.x_priority = (
                                      select min(rpv.x_priority)
                                      from x_reward_point_values rpv
                                      where rpv.x_point_category = lc_point_category_reward
                                      and rpv.service_plan_objid in (lv_service_plan_used, jrec.plan_used)
                                      and rpv.bus_org_objid = jrec.bus_org_objid
                                      and sysdate between rpv.x_start_date and rpv.x_end_date
                                  );

            --  dbms_output.put_line('lv_service_plan_priority='|| lv_service_plan_priority);
            end if;
          exception
            when no_data_found then
              dbms_output.put_line(
              'NO DATA FOUND .....points_tab(i).objid= ' || jrec.point_account_objid
              || ', lv_service_plan_used='||lv_service_plan_used
              || ', jrec.plan_used='|| jrec.plan_used
              || ', brand='|| jrec.bus_org_objid
              );

              raise no_data_found;
          end;

      end loop;

      select mkt_name
      into lv_service_plan_name
      from x_servicE_plan
      where objid = lv_service_plan_used;

      return lv_service_plan_name;

  exception
    when others then
      return null;
  end f_get_effective_service_plan;


  function F_GET_EFF_SERVICE_PLAN_ID (
            in_key                      in varchar2
            ,in_value                   in varchar2
  )
  return number
  is
  ---this function accepts input as ESN or MIN
  ---and returns the service plan that mostly used by ESN/MIN to earn the reward points
  ---if there are 2 or more service plans at same # of times then
  ---if returns the service plan based on priority set in x_reward_point_values
  ---the returned service plan is the efective service plan that may give any upgrade benefits

   /* cursor cur_points_plan_used is
      select
        distinct pt.point_trans2service_plan as plan_used
        ,pa.objid as point_account_objid
        ,pa.bus_org_objid
        ,count(point_trans2service_plan) over (partition by pt.point_trans2service_plan order by pt.point_trans2service_plan )
        as plan_frequency
      from table_x_point_trans pt, table_X_point_account pa
      where 1=1
      and ( (pa.x_min = in_value and in_key = 'MIN')  or  (pa.x_esn = in_value and in_key = 'ESN') )
      and pa.account_status = 'ACTIVE'
      and pt.point_trans2point_account = pa.objid ---99807 --rtrp
      and pa.x_points_category = pt.x_points_category
      and pt.x_points_category = lc_point_category_reward
      and pt.x_points_action in ('ADD', 'ESNUPGRADE')
      and pt.point_trans2service_plan is not null
      and pt.point_trans2benefit is null
      ;*/

     /*VS:062915:CR35343 changes to get the effective service plan used in point
         accumulation*/
      cursor cur_points_plan_used
        is
        with serv_plan as
                  (select pt.point_trans2service_plan as plan_used,
                    x_points,
                    pt.x_esn,
                    pt.point_trans2service_plan,
                     pt.x_points_category,
                     row_number() over (partition by pt.point_trans2service_plan order by pt.point_trans2service_plan) rnum
                  from table_x_point_trans pt
                  where 1=1
                  and ( (pt.x_min = in_value and in_key = 'MIN')  or  (pt.x_esn = in_value and in_key = 'ESN') )
                  and pt.x_points_category         = lc_point_category_reward
                  and pt.x_points_action          in ('ADD', 'ESNUPGRADE')
                  and pt.point_trans2service_plan is not null
                  and pt.point_trans2benefit      is null
                   union
                  select null plan_used ,
                      x_points,
                    pt.x_esn,
                    pt.point_trans2service_plan,
                    'BONUS_POINTS',
                     rownum
                  from table_x_point_trans pt
                       where
                   ( (pt.x_min = in_value and in_key = 'MIN')  or  (pt.x_esn = in_value and in_key = 'ESN') )
                  and pt.x_points_category         ='BONUS_POINTS'
                    ---and pt.x_points > 0
                  and pt.x_points_action          in ('ADD', 'ESNUPGRADE', 'DEDUCT')
                  and pt.point_trans2benefit      is null
                  minus
                  select pt.point_trans2service_plan as plan_used,
                    abs(x_points),
                    pt.x_esn,
                    pt.point_trans2service_plan,
                    pt.x_points_category,
                      row_number() over (partition by pt.point_trans2service_plan order by pt.point_trans2service_plan) rnum
                  from table_x_point_trans pt
                  where 1=1
                  and ( (pt.x_min = in_value and in_key = 'MIN')  or  (pt.x_esn = in_value and in_key = 'ESN') )
                  and pt.x_points_category         = lc_point_category_reward
                    ---and pt.x_points > 0
                  and pt.x_points_action          in ('DEDUCT')
                  and pt.point_trans2service_plan is not null
                  and pt.point_trans2benefit      is null
                  )
                  , esn_serv_plan
                  as
                 (select distinct x2.sp_objid,
                        y.FEA_DISPLAY,
                        y.FEA_NAME,
                        y.FEA_VALUE,
                        y.SP_MKT_NAME
                   from
                     table_part_inst pi,
                  sa.TABLE_MOD_LEVEL ML2,
                 sa.TABLE_PART_NUM PN2 ,
                  adfcrm_serv_plan_CLASS_matview x2,
                  adfcrm_serv_plan_feat_matview y,
                  serv_plan sp
                  where
                   pi.PART_SERIAL_NO = sp.x_esn
                  and ML2.OBJID = PI.N_PART_INST2PART_MOD
                  and pn2.objid = ml2.part_info2part_num
                  and x2.part_class_objid   = PN2.PART_NUM2PART_CLASS
                  and y.fea_name   = lc_point_category_reward
                  and y.sp_objid  = x2.sp_objid
                  )
                 select distinct esp.sp_objid plan_used
                              ,pa.objid as point_account_objid
                              ,pa.bus_org_objid
                               , count(esp.sp_objid) over (partition by esp.sp_objid ) as plan_frequency
                 from serv_plan x, esn_serv_plan esp ,
                      table_X_point_account pa
                where   x.x_points = esp.fea_value
                  and ( (pa.x_min = in_value and in_key = 'MIN')
                         or
                        (pa.x_esn = in_value and in_key = 'ESN')
                      )
                  and pa.account_status = 'ACTIVE'
                  and pa.x_points_category = x.x_points_category
                  and x.x_points_category =lc_point_category_reward
                  union
                   select distinct x.plan_used plan_used
                              ,pa.objid as point_account_objid
                              ,pa.bus_org_objid
                              ,count(nvl(x.plan_used, -999))over (partition by nvl(x.plan_used, -999)) as plan_frequency
                 from serv_plan x ,
                      table_X_point_account pa
                where   ( (pa.x_min = in_value and in_key = 'MIN')
                         or
                        (pa.x_esn = in_value and in_key = 'ESN')
                      )
                  and pa.account_status = 'ACTIVE'
                   and x.x_points_category ='BONUS_POINTS'
                   and x.x_esn = pa.x_esn;

    type typ_points_plan_tab is table of cur_points_plan_used%rowtype index by pls_integer;

    points_plan_tab           typ_points_plan_tab ;
    lv_service_plan_used      number;
    lv_service_plan_frequency number;
    lv_service_plan_priority  number;
    lv_benefit_program_id     number;
    lv_x_benefits_objid       number;

    lv_service_plan_name      x_service_plan.mkt_name%type;


  begin
     -- dbms_output.put_line('STARTED ');
      lv_service_plan_used      := 0;
      lv_service_plan_frequency := 0;
      lv_service_plan_priority  := 0;
      lv_benefit_program_id     := null;

      for jrec in cur_points_plan_used
      loop
         -- dbms_output.put_line('checking the serv.plan');
          begin
            if jrec.plan_frequency > lv_service_plan_frequency then
              lv_service_plan_used      := jrec.plan_used;
              lv_service_plan_frequency := jrec.plan_frequency;
              lv_service_plan_priority  := null;
              --no need to check priority here since its clear that what plan is used


            elsif jrec.plan_frequency = lv_service_plan_frequency then
              null;
              dbms_output.put_line('plan freq conf');
              --if its a tie then get the service plan based on priority defined from the table
              -- minimum function applied to get one plan in case of conflicts in priority
              select min(tt.service_plan_objid), min(tt.benefit_program_objid), min(tt.x_priority)
              into lv_service_plan_used, lv_benefit_program_id, lv_service_plan_priority
              from x_reward_point_values tt
              where 1=1
              and tt.service_plan_objid in (lv_service_plan_used, jrec.plan_used)
              and tt.bus_org_objid = jrec.bus_org_objid
              and sysdate between tt.x_start_date and tt.x_end_date
              and tt.x_priority = (
                                      select min(rpv.x_priority)
                                      from x_reward_point_values rpv
                                      where rpv.x_point_category = lc_point_category_reward
                                      and rpv.service_plan_objid in (lv_service_plan_used, jrec.plan_used)
                                      and rpv.bus_org_objid = jrec.bus_org_objid
                                      and sysdate between rpv.x_start_date and rpv.x_end_date
                                  );

           --   dbms_output.put_line('lv_service_plan_priority='|| lv_service_plan_priority);
            end if;
          exception
            when no_data_found then
              dbms_output.put_line(
              'NO DATA FOUND .....points_tab(i).objid= ' || jrec.point_account_objid
              || ', lv_service_plan_used='||lv_service_plan_used
              || ', jrec.plan_used='|| jrec.plan_used
              || ', brand='|| jrec.bus_org_objid
              );

              raise no_data_found;
          end;

      end loop;


      return lv_service_plan_used;

  exception
    when others then
      return null;
  end F_GET_EFF_SERVICE_PLAN_ID;

 function F_GET_EFF_SERVICE_PLAN_ID_OLD (
            in_key                      in varchar2
            ,in_value                   in varchar2
  )
  return number
  is
  ---this function accepts input as ESN or MIN
  ---and returns the service plan that mostly used by ESN/MIN to earn the reward points
  ---if there are 2 or more service plans at same # of times then
  ---if returns the service plan based on priority set in x_reward_point_values
  ---the returned service plan is the efective service plan that may give any upgrade benefits

   /* cursor cur_points_plan_used is
      select
        distinct pt.point_trans2service_plan as plan_used
        ,pa.objid as point_account_objid
        ,pa.bus_org_objid
        ,count(point_trans2service_plan) over (partition by pt.point_trans2service_plan order by pt.point_trans2service_plan )
        as plan_frequency
      from table_x_point_trans pt, table_X_point_account pa
      where 1=1
      and ( (pa.x_min = in_value and in_key = 'MIN')  or  (pa.x_esn = in_value and in_key = 'ESN') )
      and pa.account_status = 'ACTIVE'
      and pt.point_trans2point_account = pa.objid ---99807 --rtrp
      and pa.x_points_category = pt.x_points_category
      and pt.x_points_category = lc_point_category_reward
      and pt.x_points_action in ('ADD', 'ESNUPGRADE')
      and pt.point_trans2service_plan is not null
      and pt.point_trans2benefit is null
      ;*/

     /*VS:062915:CR35343 changes to get the effective service plan used in point
         accumulation*/
      cursor cur_points_plan_used
        is
           with serv_plan as
          (select pt.point_trans2service_plan as plan_used,
            x_points,
            pt.x_esn,
            pt.point_trans2service_plan,
            sum(x_points) over (order by pt.x_trans_date ,pt.objid  rows between unbounded preceding and current row) cumm_points,
            pt.x_trans_date,
            pt.x_points_category
          from table_x_point_trans pt
          where 1=1
          and ( (pt.x_min = in_value and in_key = 'MIN')  or  (pt.x_esn = in_value and in_key = 'ESN') )
          and pt.x_points_category         = lc_point_category_reward
            ---and pt.x_points > 0
          and pt.x_points_action          in ('ADD', 'ESNUPGRADE', 'DEDUCT')
          and pt.point_trans2service_plan is not null
          and pt.point_trans2benefit      is null
          )
          , esn_serv_plan
          as
         (select distinct x2.sp_objid,
                y.FEA_DISPLAY,
                y.FEA_NAME,
                y.FEA_VALUE,
                y.SP_MKT_NAME
           from
             table_part_inst pi,
          sa.TABLE_MOD_LEVEL ML2,
         sa.TABLE_PART_NUM PN2 ,
          adfcrm_serv_plan_CLASS_matview x2,
          adfcrm_serv_plan_feat_matview y,
          serv_plan sp
          where
           pi.PART_SERIAL_NO = sp.x_esn
          and ML2.OBJID = PI.N_PART_INST2PART_MOD
          and pn2.objid = ml2.part_info2part_num
          and x2.part_class_objid   = PN2.PART_NUM2PART_CLASS
          and y.fea_name   = lc_point_category_reward
          and y.sp_objid  = x2.sp_objid
          )
        select distinct esp.sp_objid plan_used
                      ,pa.objid as point_account_objid
                      ,pa.bus_org_objid
                       , count(esp.sp_objid) over (partition by esp.sp_objid ) as plan_frequency
         from serv_plan x, esn_serv_plan esp ,
              table_X_point_account pa
        where x.x_points = esp.fea_value
          and ( (pa.x_min = in_value and in_key = 'MIN')  or  (pa.x_esn = in_value and in_key = 'ESN') )
          and pa.account_status = 'ACTIVE'
          and pa.x_points_category = x.x_points_category
          and x.x_points_category = lc_point_category_reward
          ;





    type typ_points_plan_tab is table of cur_points_plan_used%rowtype index by pls_integer;

    points_plan_tab           typ_points_plan_tab ;
    lv_service_plan_used      number;
    lv_service_plan_frequency number;
    lv_service_plan_priority  number;
    lv_benefit_program_id     number;
    lv_x_benefits_objid       number;

    lv_service_plan_name      x_service_plan.mkt_name%type;


  begin
     -- dbms_output.put_line('STARTED ');
      lv_service_plan_used      := 0;
      lv_service_plan_frequency := 0;
      lv_service_plan_priority  := 0;
      lv_benefit_program_id     := null;

      for jrec in cur_points_plan_used
      loop
         -- dbms_output.put_line('checking the serv.plan');
          begin
            if jrec.plan_frequency > lv_service_plan_frequency then
              lv_service_plan_used      := jrec.plan_used;
              lv_service_plan_frequency := jrec.plan_frequency;
              lv_service_plan_priority  := null;
              --no need to check priority here since its clear that what plan is used


            elsif jrec.plan_frequency = lv_service_plan_frequency then
              null;
              --if its a tie then get the service plan based on priority defined from the table
              -- minimum function applied to get one plan in case of conflicts in priority
              select min(tt.service_plan_objid), min(tt.benefit_program_objid), min(tt.x_priority)
              into lv_service_plan_used, lv_benefit_program_id, lv_service_plan_priority
              from x_reward_point_values tt
              where 1=1
              and tt.service_plan_objid in (lv_service_plan_used, jrec.plan_used)
              and tt.bus_org_objid = jrec.bus_org_objid
              and sysdate between tt.x_start_date and tt.x_end_date
              and tt.x_priority = (
                                      select min(rpv.x_priority)
                                      from x_reward_point_values rpv
                                      where rpv.x_point_category = lc_point_category_reward
                                      and rpv.service_plan_objid in (lv_service_plan_used, jrec.plan_used)
                                      and rpv.bus_org_objid = jrec.bus_org_objid
                                      and sysdate between rpv.x_start_date and rpv.x_end_date
                                  );

           --   dbms_output.put_line('lv_service_plan_priority='|| lv_service_plan_priority);
            end if;
          exception
            when no_data_found then
              dbms_output.put_line(
              'NO DATA FOUND .....points_tab(i).objid= ' || jrec.point_account_objid
              || ', lv_service_plan_used='||lv_service_plan_used
              || ', jrec.plan_used='|| jrec.plan_used
              || ', brand='|| jrec.bus_org_objid
              );

              raise no_data_found;
          end;

      end loop;


      return lv_service_plan_used;

  exception
    when others then
      return null;
  end F_GET_EFF_SERVICE_PLAN_ID_OLD;

   FUNCTION f_get_benefits_history(
        in_key   IN VARCHAR2,
        in_value IN VARCHAR2 )
      RETURN tab_benefits_hist pipelined
    IS
      rec_esn cur_esn_min_dtl%rowtype;
      rec_benefits_hist typ_rec_benefits_hist;
      lv_my_esn VARCHAR2(30);
      lv_my_min VARCHAR2(30);

      -- Querying only by ESN if a ESN change occurs then only the current ESN history will be returned.
      CURSOR cur_benefits_hist (in_esn IN VARCHAR2)
      IS
         SELECT xb.objid benefit_id,
          xt.x_trans_date,
          xt.x_min ,
          xt.x_esn ,
          xt.x_points_action,
          xbp.x_benefit_value,
          xt.point_display_reason
        FROM table_x_point_trans xt,
         table_x_point_account pa,
          table_x_benefits xb,
          table_x_benefit_programs xbp
        WHERE 1 =1
        AND xt.x_esn                    = in_esn
        AND xt.point_trans2benefit      = xb.objid
        AND (xt.x_points_action         IN ('CONVERT'))
        AND xt.point_trans2benefit      = xb.objid
        AND xb.benefits2benefit_program = xbp.objid
        AND pa.subscriber_uid = xb.x_benefit_owner_value
        and xb.x_benefit_owner_type = 'SID'
        and pa.account_status = 'ACTIVE'
        and pa.x_esn= xt.x_esn
        and pa.x_min= xt.x_min
        and xt.x_points = -18 --QC4142 08/13/2015
      UNION
      SELECT xb.objid benefit_id,
           xb.x_created_date,
          pa.x_min ,
          pa.x_esn ,
          'CONVERT',
          xbp.x_benefit_value,
          'Converted to Benefit'
          from
         table_x_point_account pa,
          table_x_benefits xb,
          table_x_benefit_programs xbp
         where   1 =1
        AND pa.x_esn = in_esn
         AND xb.benefits2benefit_program = xbp.objid
        AND pa.subscriber_uid = xb.x_benefit_owner_value
        and xb.x_benefit_owner_type = 'SID'
        and pa.account_status = 'ACTIVE'
        and not exists (
        select 1 from table_x_point_trans pt where
        pt.x_esn = pa.x_esn
        and pt.x_min = pa.x_min
        and pt.point_trans2benefit = xb.objid)
      UNION
        SELECT xb.objid benefit_id,
          xt.x_trans_date,
          xt.x_min ,
          xt.x_esn ,
          'DEDUCT',
          xbp.x_benefit_value,
          xt.point_display_reason
        FROM table_x_point_trans xt,
          table_x_benefits xb,
          table_x_benefit_programs xbp
        WHERE 1                         =1
        AND xt.x_esn  = in_esn
        AND xt.x_points_action = 'CONVERT'
        AND Xt.x_points = 18
        AND xt.point_trans2ref_table_objid = xb.objid
        AND xt.ref_table_name = 'TABLE_X_BENEFITS'
        AND xb.benefits2benefit_program = xbp.objid
      UNION
      SELECT xb.objid benefit_id,
        xvt.TRANSACTION_DATE,
        xp.x_min,
        xp.x_esn,
        DECODE (xvt.transaction_type, '951', 'AUTHORIZATION', '952', 'USED', '953', 'CANCELLATION', '954', 'ADD', '955', 'CANCELLATION', xvt.transaction_type),
        xbp.x_benefit_value,
        DECODE (xvt.transaction_type, '952', 'Benefit Used', '954', 'Device Returned', 'Reason undocumented')
      FROM table_x_voucher_transactions xvt,
        table_x_vouchers xv,
        table_x_benefits xb,
        table_x_point_account xp,
        table_x_benefit_programs xbp
      WHERE 1                       =1
      AND xvt.transaction_type     in ('952', '954') -- dont include access records
      AND xvt.voucher_trans2voucher = xv.objid
      AND xv.x_vouchers2benefit     = xb.objid
      AND xb.x_benefit_owner_type   = 'SID'
      AND xb.x_benefit_owner_value  = xp.subscriber_uid
      AND xp.subscriber_uid         =
        (SELECT subscriber_uid
        FROM table_x_point_account
        WHERE x_esn       = in_esn
        AND account_status='ACTIVE'
        )
      AND xb.benefits2benefit_program = xbp.objid
      union
      SELECT xb.objid benefit_id,
          xb.x_expiry_date,
          xt.x_min ,
          xt.x_esn ,
          'DEDUCT',
          xbp.x_benefit_value,
         'Expired'
        FROM table_x_point_trans xt,
          table_x_benefits xb,
          table_x_benefit_programs xbp
        WHERE 1                         =1
        AND xt.x_esn                    = in_esn
        AND xt.point_trans2benefit      = xb.objid
        AND xt.x_points_action         IN ('CONVERT')
        AND xt.point_trans2benefit      = xb.objid
        AND xb.benefits2benefit_program = xbp.objid
        AND  xb.x_expiry_date <= sysdate
      ORDER BY 1,
        2;


    BEGIN

      OPEN cur_esn_min_dtl(in_key, in_value);
      FETCH cur_esn_min_dtl INTO rec_esn;
      CLOSE cur_esn_min_dtl;

      IF rec_esn.x_esn IS NOT NULL AND rec_esn.x_min IS NOT NULL THEN
        lv_my_esn      := rec_esn.x_esn;
        lv_my_min      := rec_esn.x_min;
      ELSE
        SELECT x_min,
          x_service_id
        INTO lv_my_min,
          lv_my_esn
        FROM table_site_part tsp
        WHERE tsp.objid =
          (SELECT MAX(objid)
          FROM table_site_part tsp_inactive
          WHERE 1                        =1
          AND ( tsp_inactive.part_status = 'Inactive')
          AND ( ( in_key                 = 'ESN'
          AND tsp_inactive.x_service_id  = in_value )
          OR ( in_key                    = 'MIN'
          AND tsp_inactive.x_min         = in_value ) )
          ) ;
      END IF;

      FOR irec IN cur_benefits_hist (lv_my_esn)
      LOOP

      rec_benefits_hist.objid                     := irec.benefit_id;
      rec_benefits_hist.x_trans_date             := irec.x_trans_date;
      rec_benefits_hist.x_min                     := irec.x_min;
      rec_benefits_hist.x_esn                     := irec.x_esn;
      rec_benefits_hist.x_points_action           := irec.x_points_action;
      rec_benefits_hist.x_benefit_value        := irec.x_benefit_value;
      rec_benefits_hist.points_action_reason     := irec.point_display_reason;
      rec_benefits_hist.display_action_reason     := irec.point_display_reason;

        pipe row (rec_benefits_hist);
      END LOOP;

    EXCEPTION
    WHEN OTHERS THEN
      NULL;
      RETURN;
    END f_get_benefits_history;

end reward_benefits_n_vouchers_pkg;
/