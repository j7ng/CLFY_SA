CREATE OR REPLACE package body sa.ADFCRM_VO
AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_VO_PKB.sql,v $
--$Revision: 1.217 $
--$Author: epaiva $
--$Date: 2018/05/24 19:37:12 $
--$ $Log: ADFCRM_VO_PKB.sql,v $
--$ Revision 1.217  2018/05/24 19:37:12  epaiva
--$ CR57565 - add sourcesystem check in get_sp_info
--$
--$ Revision 1.216  2018/03/18 20:57:07  epaiva
--$ Cr56582 - AWOP NT SL description field change
--$
--$ Revision 1.215  2018/03/16 23:43:24  epaiva
--$ CR56582 - AWOP changes for NT SL
--$
--$ Revision 1.214  2018/02/21 16:51:09  epaiva
--$ CR55069 Enable GS Add on plans in replacement tab
--$
--$ Revision 1.213  2018/02/14 16:16:58  mbyrapaneni
--$ SMMLD_TAS_02: To enable buckets for GO_SMART
--$
--$ Revision 1.212  2018/01/29 21:30:38  syenduri
--$ Merged REL945 changes into REL946
--$
--$ Revision 1.210  2018/01/17 00:19:03  epaiva
--$ CR55070 Remove PPE condition for NET10 Data Add On
--$
--$ Revision 1.209  2018/01/15 21:23:28  epaiva
--$ CR55070 NET10 Data Add on - Filter Add on for NET10 in Comp/Repl Query
--$
--$ Revision 1.207  2018/01/05 23:03:12  epaiva
--$ CR55070 NET10 DATA ADD ON changes
--$
--$ Revision 1.206  2018/01/04 20:25:54  epaiva
--$ CR55070 getAvailableSpPurchase NET10 DATA ADD ON changes
--$
--$ Revision 1.205  2018/01/03 17:30:25  epaiva
--$ CR55070  getAvailableSpPurchase NET10 Data Add On changes
--$
--$ Revision 1.204  2017/11/27 23:06:11  mmunoz
--$ Merge REL933 and HPP Asurion CR55214
--$
--$ Revision 1.203  2017/11/20 18:35:45  syenduri
--$ CR53530 - To getting action item status considering ig_transaction_history too
--$
--$ Revision 1.202  2017/11/09 22:39:13  syenduri
--$ CR53530 - IG Action Item Status
--$
--$ Revision 1.201  2017/10/16 14:26:34  hcampano
--$ CR50209 Service Plan Description in TAS
--$
--$ Revision 1.200  2017/10/09 16:52:53  hcampano
--$ Fixing merge issues between WFM2_TAS and REL904_TAS
--$
--$ Revision 1.199  2017/10/06 14:02:17  hcampano
--$ Fixing merge issues between WFM2_TAS and REL904_TAS
--$
--$ Revision 1.198  2017/10/05 16:48:40  hcampano
--$ CR50209 Service Plan Description in TAS
--$
--$ Revision 1.197  2017/10/02 15:37:49  mbyrapaneni
--$ Commented Lifeline Changes for SIT1 deployment
--$
--$ Revision 1.196  2017/09/28 20:26:46  hcampano
--$ CR50209 Service Plan Description in TAS
--$
--$ Revision 1.195  2017/09/27 15:48:34  hcampano
--$ CR50209 Service Plan Description in TAS
--$
--$ Revision 1.194  2017/07/24 19:55:22  mmunoz
--$ CR49915: Lifeline changes, added program name and status
--$
--$ Revision 1.193  2017/07/20 14:55:44  mmunoz
--$ CR 49915: WFM lifeline changes, new ll_id variable
--$
--$ Revision 1.188  2017/07/12 14:01:51  epaiva
--$ updated veribiage for throttling info
--$
--$ Revision 1.187  2017/07/11 21:27:35  epaiva
--$ updated verbiage for throttling message
--$
--$ Revision 1.186  2017/07/11 18:33:23  hcampano
--$ CR50209 - CR50209 Service Plan Description in TAS - CR code was removed, however, left the columns.
--$
--$ Revision 1.185  2017/07/11 18:27:33  hcampano
--$ CR50209 - CR50209 Service Plan Description in TAS - Last check in before the CR was removed due to issues w/conflicts in service plan data to the logic we tried to implement.
--$
--$ Revision 1.184  2017/07/10 11:46:53  hcampano
--$ CR50209 - CR50209 Service Plan Description in TAS
--$
--$ Revision 1.183  2017/07/07 21:39:04  nguada
--$ Lease status change from 'No' to 'Paid'
--$
--$ Revision 1.182  2017/07/03 22:07:12  hcampano
--$ CR50209 - CR50209 Service Plan Description in TAS
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
            pc.name part_class_name,
            pc.objid part_class_objid,
            pn.part_number
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

--********************************************************************************************************************
  function get_language (p_language in varchar2)
  return varchar2 is
     ip_language  varchar2(100);
  begin
    ip_language := nvl(p_language,'ENGLISH');
      if upper(ip_language) in ('ES','SPANISH')
    then
       ip_language := 'SPANISH';
    else
       ip_language := 'ENGLISH';
    end if;
    return ip_language;
  end;
--********************************************************************************************************************
  function get_org_objid (p_org_id in varchar2)
  return varchar2 is
     org_id  number;
  begin
    SELECT OBJID
    into   org_id
    FROM TABLE_BUS_ORG
    WHERE ORG_ID =  p_org_id;
    return org_id;
  exception when others then
    return 0;
  end;
--********************************************************************************************************************
FUNCTION get_smartphone_fun
  ( in_part_class IN VARCHAR2)
  RETURN  NUMBER  IS

      CURSOR c_droid( in_part_class IN VARCHAR2) IS
        SELECT (select x_param_value
                  FROM table_x_part_class_params pcp,
                       table_x_part_class_values pcv
                 WHERE pcp.objid = pcv.value2class_param
                   AND pcv.value2part_class = pc.objid
                   AND x_param_name = 'BALANCE_METERING') BALANCE_METERING,
               (select x_param_value
                  FROM table_x_part_class_params pcp,
                       table_x_part_class_values pcv
                 WHERE pcp.objid = pcv.value2class_param
                   AND pcv.value2part_class = pc.objid
                   AND x_param_name = 'BUS_ORG') BUS_ORG,
               (select x_param_value
                  FROM table_x_part_class_params pcp,
                       table_x_part_class_values pcv
                 WHERE pcp.objid = pcv.value2class_param
                   AND pcv.value2part_class = pc.objid
                   AND pcp.x_param_name = 'NON_PPE') non_ppe
          FROM sa.table_part_class pc
          where pc.name = in_part_class;

      r_droid c_droid%ROWTYPE ;

   return_value                 NUMBER ;

BEGIN

           OPEN c_droid(in_part_class);
           FETCH c_droid INTO r_droid;
           CLOSE c_droid;
                if (r_droid.BALANCE_METERING= 'SUREPAY') THEN
                  IF r_droid.non_ppe = 1 THEN
                      return_value := 0;      --------------------- surepay android non ppe phone
                  ELSE
                      return_value := 2;     --------------------- surepay android ppe phone
                  END IF ;
                else
                       return_value := 1; ---  not surepay phone (PPE_STT, PPE_MTT, Unlimited,)
                end if;

    RETURN return_value ;
EXCEPTION
   WHEN others THEN
       return_value:= NULL ;
END get_smartphone_fun;
--********************************************************************************************************************
  function get_vas_app_card(p_prog_id in varchar2)
  return varchar2 is
     v_vas_app_card  varchar2(50);
  begin
    select distinct vas_app_card
    into v_vas_app_card
    from vas_programs_view
    where program_parameters_objid = p_prog_id;

    return v_vas_app_card;
  exception
    when no_data_found then return null;
    when others then return null;
  end;
--********************************************************************************************************************
    function default_values_AvailableSp
    return getAvailableSp_rec
    is
       getAvailableSp_rslt getAvailableSp_rec;
    begin
       getAvailableSp_rslt.objid                := 0;
       getAvailableSp_rslt.Mkt_Name             := '';
       getAvailableSp_rslt.SP_Description       := '';
       getAvailableSp_rslt.Description          := '';
       getAvailableSp_rslt.Customer_Price       := 0;
       getAvailableSp_rslt.Ivr_Plan_Id          := 0;
       getAvailableSp_rslt.Webcsr_Display_Name  := '';
       getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := 0;
       getAvailableSp_rslt.X_Program_Name       := '';
       getAvailableSp_rslt.spObjid              := 0;
       getAvailableSp_rslt.value_name           := '';
       getAvailableSp_rslt.part_number          := '0';
--       getAvailableSp_rslt.prog_script_id       := '';
--       getAvailableSp_rslt.prog_script_desc     := '';
       getAvailableSp_rslt.x_card_type          := '';
       getAvailableSp_rslt.units                := null;
       getAvailableSp_rslt.ServicePlanType      := '';
       getAvailableSp_rslt.sp_biz_line          := '';
       getAvailableSp_rslt.sp_number_of_lines   := '';
       getAvailableSp_rslt.sp_add_on_card_flag  := '';
       getAvailableSp_rslt.quantity             := 0;
       getAvailableSp_rslt.x_prg_script_text        := null;  --CR32952
       getAvailableSp_rslt.x_prg_desc_script_text   := null;  --CR32952
       getAvailableSp_rslt.x_prog_class := null; --CR36130
       getAvailableSp_rslt.x_prog_app_part_number := null;

       return getAvailableSp_rslt;
    end default_values_AvailableSp;
--********************************************************************************************************************
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
           DBMS_OUTPUT.PUT_LINE('servicesforphone_rec.PROGRAM_PARAMETERS_OBJID = ' || servicesforphone_rec.PROGRAM_PARAMETERS_OBJID);
     end loop;
     close servicesforphone;
  end if;

  return servicesforphone_rec.PROGRAM_PARAMETERS_OBJID;
end getVASservice;
--********************************************************************************************************************
  function getAvailableSpEnrollment(
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getAvailableSp_tab pipelined
  is
      --*** This table function is called from uc245 ***
      org_objid number;
      p_language varchar2(100);
      getAvailableSp_rslt getAvailableSp_rec;
      get_esn_info_rec  get_esn_info%rowtype;
      v_sub_bus_org varchar2(30);
      n_sub_bus_org_obj number;
      o_dummy varchar2(30);
      v_script_id varchar2(100);
      isEsnTripleBenefit varchar2(1);  -- CR48383

  BEGIN
      p_language := get_language(ip_language);
      getAvailableSp_rslt := default_values_AvailableSp;
      getAvailableSp_rslt.Mkt_Name := 'Select Plan';
      getAvailableSp_rslt.X_Program_Name := 'Select Plan';
      pipe row (getAvailableSp_rslt);

      org_objid := get_org_objid(ip_org_id);

      if ip_org_id = 'SIMPLE_MOBILE' then
        sa.phone_pkg.get_sub_brand(
          I_ESN => ip_esn,
          o_sub_brand => v_sub_bus_org,
          O_ERRNUM => o_dummy,
          o_errstr => o_dummy
        );
        if v_sub_bus_org = 'GO_SMART' then
          select objid
          into n_sub_bus_org_obj
          from table_bus_org
          where org_id = v_sub_bus_org;
        end if;

      end if;
      open get_esn_info(ip_esn);
      fetch get_esn_info into get_esn_info_rec;
      close get_esn_info;

      if ip_org_id = 'NET10' and sa.adfcrm_safelink.is_phone_safelink(ip_esn) = 'true'
      then
      /*************  Safelink   **********/
      null;
      else
      if ip_org_id <> 'TRACFONE'
      then
          for notrac_rec in
                (select distinct
                        SP.OBJID objid, SP.MKT_NAME mkt_name, SP.DESCRIPTION sp_Description,
                        (select nvl(script_description,description)
                        from sa.adfcrm_service_plan_scripts_mv spmv
                        where spmv.objid = sp.objid
                        and spmv.x_language = upper(ip_language)
                        ) description
                       ,SP.CUSTOMER_PRICE CUSTOMER_PRICE, SP.IVR_PLAN_ID IVR_PLAN_ID, SP.WEBCSR_DISPLAY_NAME WEBCSR_DISPLAY_NAME
                       ,SPXPP.X_SP2PROGRAM_PARAM X_SP2PROGRAM_PARAM, XPP.X_PROGRAM_NAME X_PROGRAM_NAME
                       ,'PLAN_PURCHASE_PART_NUMBER' VALUE_NAME
                       ,sa.ADFCRM_GET_SERV_PLAN_VALUE(SP.OBJID,'PLAN_PURCHASE_PART_NUMBER')  part_number
                       , sp.objid spObjid
                       ,xpp.x_prog_class --CR36130
                       ,ppmv.x_prg_script_text --CR44010
                       ,ppmv.x_prg_desc_script_text --CR44010
                 FROM  TABLE_PART_INST PI,
                       TABLE_MOD_LEVEL ML,
                       TABLE_PART_NUM PN,
                       sa.adfcrm_serv_plan_class_matview spmv,
                       X_SERVICE_PLAN SP,
                       MTM_SP_X_PROGRAM_PARAM SPXPP,
                       X_PROGRAM_PARAMETERS XPP,
                       (select prg_objid, x_prg_script_text, x_prg_desc_script_text
                       from sa.adfcrm_prg_enrolled_script_mv
                       where x_language = upper(ip_language)) ppmv
                 WHERE  1 =1
                 AND   PI.PART_SERIAL_NO = ip_esn
                 AND   PI.X_PART_INST_STATUS = '52'
                 AND   ML.OBJID = PI.N_PART_INST2PART_MOD
                 and   pn.objid = ml.part_info2part_num
                 AND   spmv.part_class_objid = PN.PART_NUM2PART_CLASS
                 and   sp.objid = spmv.sp_objid
                 AND   SPXPP.X_SP2PROGRAM_PARAM  is not null
                 and   SPXPP.PROGRAM_PARA2X_SP = SP.OBJID
                 and   XPP.OBJID = SPXPP.X_SP2PROGRAM_PARAM
                 AND   NVL(SPXPP.X_RECURRING,1) = 1
                 and   NVL(sa.adfcrm_GET_SERV_PLAN_VALUE(SP.OBJID,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') IN ('AVAILABLE','ENROLL_ALLOW')
                 AND   sa.ADFCRM_PLAN_SWITCH_ALLOWED(ip_esn, SP.OBJID) = 'true'
                 and   sa.ADFCRM_GET_SERV_PLAN_VALUE(SP.OBJID,'RECURRING_SERVICE_PLAN') is null
                 and   ppmv.prg_objid = XPP.OBJID
            )
          loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := notrac_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := notrac_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := notrac_rec.sp_Description;
            getAvailableSp_rslt.Description          := notrac_rec.Description;
            getAvailableSp_rslt.Customer_Price       := notrac_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := notrac_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := notrac_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := notrac_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := notrac_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := notrac_rec.part_number;
            getAvailableSp_rslt.spObjid              := notrac_rec.spObjid;
            getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
            getAvailableSp_rslt.sp_number_of_lines   := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'NUMBER_OF_LINES');
            getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');
            --CR32952 begin
            getAvailableSp_rslt.x_prg_script_text := notrac_rec.x_prg_script_text;
            getAvailableSp_rslt.x_prg_desc_script_text := notrac_rec.x_prg_desc_script_text;
            --CR32952 end

            --CR48200 Begin Exceptions for program scripts
            v_script_id := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'PROGRAM_NAME_SCRIPT');
            if v_script_id is not null then
                getAvailableSp_rslt.x_prg_script_text      := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => substr(v_script_id,1,instr(v_script_id,'_')-1),
                                                                       ip_script_id => substr(v_script_id,instr(v_script_id,'_')+1),
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'ALL',
                                                                       ip_brand_name => ip_org_id);
            end if;
            v_script_id := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'PROGRAM_DESC_SCRIPT');
            if v_script_id is not null then
                getAvailableSp_rslt.x_prg_desc_script_text := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type =>  substr(v_script_id,1,instr(v_script_id,'_')-1),
                                                                       ip_script_id => substr(v_script_id,instr(v_script_id,'_')+1),
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'ALL',
                                                                       ip_brand_name => ip_org_id);
            end if;
            --CR48200 End
            getAvailableSp_rslt.x_prog_class := notrac_rec.x_prog_class; --CR36130

            pipe row (getAvailableSp_rslt);
          end loop;

          --CR36130 Adding programs that are not service plan related.
          for no_serv_plan in
            (
            select
                x_program_parameters.objid OBJID, x_program_parameters.x_program_name MKT_NAME, x_program_parameters.x_program_desc DESCRIPTION
              , table_part_num.description sp_description
              , table_x_pricing.x_retail_price CUSTOMER_PRICE, null IVR_PLAN_ID, x_program_parameters.x_program_name WEBCSR_DISPLAY_NAME
              , x_program_parameters.objid X_SP2PROGRAM_PARAM, x_program_parameters.x_program_name X_PROGRAM_NAME
              , table_part_num.part_number  part_number
              , 0 spObjid
              --,substr(x_program_parameters.x_prg_script_id,1,instr(x_program_parameters.x_prg_script_id,'_')-1) prg_script_type,  --CR32952
              --substr(x_program_parameters.x_prg_script_id,instr(x_program_parameters.x_prg_script_id,'_')+1) prg_script_id,  --CR32952
              --substr(x_program_parameters.x_prg_desc_script_id,1,instr(x_program_parameters.x_prg_desc_script_id,'_')-1) prg_desc_script_type,  --CR32952
              --substr(x_program_parameters.x_prg_desc_script_id,instr(x_program_parameters.x_prg_desc_script_id,'_')+1) prg_desc_script_id  --CR32952
              ,x_program_parameters.x_prog_class --CR36130
              ,ppmv.x_prg_script_text --CR44010
              ,ppmv.x_prg_desc_script_text --CR44010
            from sa.x_program_parameters, sa.table_x_pricing, sa.table_part_num,
                       (select prg_objid, x_prg_script_text, x_prg_desc_script_text
                       from sa.adfcrm_prg_enrolled_script_mv
                       where x_language = upper(ip_language)) ppmv
            where x_program_parameters.prog_param2bus_org = decode(v_sub_bus_org,'GO_SMART',n_sub_bus_org_obj,org_objid)
            and prog_param2prtnum_monfee = table_x_pricing.x_pricing2part_num
            and table_x_pricing.x_channel = 'BILLING'
            and table_x_pricing.x_end_date >= sysdate
            and table_x_pricing.x_start_date <= sysdate
            and x_program_parameters.x_csr_channel = 1
            and (case
                when x_program_parameters.x_handset_value = 'RESTRICTED' and
                     (SELECT count(*)
                      FROM sa.X_MTM_PROGRAM_HANDSET MTM
                      WHERE PROGRAM_PARAM_OBJID = x_program_parameters.objid
                      AND PART_CLASS_OBJID = get_esn_info_rec.part_class_objid) > 0
                then 'true'
                else 'false'
                end) = 'false'
            and x_program_parameters.x_type = 'INDIVIDUAL'
            and x_program_parameters.x_start_date <= sysdate
            and x_program_parameters.x_end_date >= sysdate
            and x_program_parameters.prog_param2prtnum_monfee = table_part_num.objid
            and table_x_pricing.x_retail_price > 0
            and x_program_parameters.objid not in (select X_SP2PROGRAM_PARAM
                                                   from MTM_SP_X_PROGRAM_PARAM)
            and x_program_parameters.x_prog_class = 'LOWBALANCE'
            and ppmv.prg_objid = x_program_parameters.OBJID
            )
          loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := no_serv_plan.objid;
            getAvailableSp_rslt.Mkt_Name             := no_serv_plan.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := no_serv_plan.sp_Description;
            getAvailableSp_rslt.Description          := no_serv_plan.Description;
            getAvailableSp_rslt.Customer_Price       := no_serv_plan.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := no_serv_plan.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := no_serv_plan.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := no_serv_plan.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := no_serv_plan.X_Program_Name;
            getAvailableSp_rslt.part_number          := no_serv_plan.part_number;
            getAvailableSp_rslt.spObjid              := no_serv_plan.spObjid;
            getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
            /** CR44010
            getAvailableSp_rslt.x_prg_script_text      := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => no_serv_plan.prg_script_type,
                                                                       ip_script_id => no_serv_plan.prg_script_id,
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => ip_org_id);
            getAvailableSp_rslt.x_prg_desc_script_text := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => no_serv_plan.prg_desc_script_type,
                                                                       ip_script_id => no_serv_plan.prg_desc_script_id,
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => ip_org_id);
            ***/
            getAvailableSp_rslt.x_prg_script_text := no_serv_plan.x_prg_script_text;
            getAvailableSp_rslt.x_prg_desc_script_text := no_serv_plan.x_prg_desc_script_text;
            /** CR44010 **/
            getAvailableSp_rslt.x_prog_class := no_serv_plan.x_prog_class; --CR36130
            getAvailableSp_rslt.x_prog_app_part_number := get_vas_app_card(no_serv_plan.objid); --CR36130
            if getAvailableSp_rslt.x_prog_app_part_number is not null then  --VAS service
                if no_serv_plan.objid = getVASservice(ip_esn) then --CR39958   TAS Display $10 Global Card where applicable
                   pipe row (getAvailableSp_rslt);
                end if;
            else
               pipe row (getAvailableSp_rslt);   --No VAS service
            end if;
          end loop;
      end if;

      if ip_org_id = 'TRACFONE'
      then
         --CR48383 for ESN with no triple benefits, do not display REDEMPTION CARDS
		--  if isEsnTripleBenefit ='N' then
          for trac_rec in
          (select
                x_program_parameters.objid OBJID, x_program_parameters.x_program_name MKT_NAME, x_program_parameters.x_program_desc DESCRIPTION
              , table_part_num.description sp_description
              , table_x_pricing.x_retail_price CUSTOMER_PRICE, null IVR_PLAN_ID, x_program_parameters.x_program_name WEBCSR_DISPLAY_NAME
              , x_program_parameters.objid X_SP2PROGRAM_PARAM, x_program_parameters.x_program_name X_PROGRAM_NAME
              , table_part_num.part_number  part_number
              , 0 spObjid
              --,substr(x_program_parameters.x_prg_script_id,1,instr(x_program_parameters.x_prg_script_id,'_')-1) prg_script_type,  --CR32952
              --substr(x_program_parameters.x_prg_script_id,instr(x_program_parameters.x_prg_script_id,'_')+1) prg_script_id,  --CR32952
              --substr(x_program_parameters.x_prg_desc_script_id,1,instr(x_program_parameters.x_prg_desc_script_id,'_')-1) prg_desc_script_type,  --CR32952
              --substr(x_program_parameters.x_prg_desc_script_id,instr(x_program_parameters.x_prg_desc_script_id,'_')+1) prg_desc_script_id  --CR32952
              ,x_program_parameters.x_prog_class --CR36130
              ,ppmv.x_prg_script_text --CR44010
              ,ppmv.x_prg_desc_script_text --CR44010
            from sa.x_program_parameters, sa.table_x_pricing, sa.table_part_num,
                       (select prg_objid, x_prg_script_text, x_prg_desc_script_text
                       from sa.adfcrm_prg_enrolled_script_mv
                       where x_language = upper(ip_language)) ppmv
            where x_program_parameters.prog_param2bus_org = org_objid
            and prog_param2prtnum_monfee = table_x_pricing.x_pricing2part_num
            and table_x_pricing.x_channel = 'BILLING'
            and table_x_pricing.x_end_date >= sysdate
            and table_x_pricing.x_start_date <= sysdate
            and x_program_parameters.x_csr_channel = 1
          --  and x_program_parameters.x_handset_value <> 'RESTRICTED'-- commented for CR48383
          --do not implement this code below until review all TRACFONE scenarios
            and (case
                when x_program_parameters.x_handset_value = 'RESTRICTED' and
                     (SELECT count(*)
                      FROM sa.X_MTM_PROGRAM_HANDSET MTM
                      WHERE PROGRAM_PARAM_OBJID = x_program_parameters.objid
                      AND PART_CLASS_OBJID = get_esn_info_rec.part_class_objid) > 0
                then 'true'
                else 'false'
                end) = 'false'

            and x_program_parameters.x_type = 'INDIVIDUAL'
            and x_program_parameters.x_start_date <= sysdate
            and x_program_parameters.x_end_date >= sysdate
            and x_program_parameters.prog_param2prtnum_monfee = table_part_num.objid
            and table_x_pricing.x_retail_price > 0
            and upper(x_program_parameters.x_program_name) not like '%LIFELINE%'
            and ppmv.prg_objid = x_program_parameters.OBJID
            and  nvl(x_program_parameters.x_prog_class,'N') not in ('WARRANTY', 'ONDEMAND', 'LIFELINE', 'HMO')  --for CR48383 to avoid displaying pay go plans for  handsets without triple benefits
          )
          loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := trac_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := trac_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := trac_rec.sp_Description;
            getAvailableSp_rslt.Description          := trac_rec.Description;
            getAvailableSp_rslt.Customer_Price       := trac_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := trac_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := trac_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := trac_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := trac_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := trac_rec.part_number;
--            getAvailableSp_rslt.prog_script_id       := ''; --trac_rec.prog_script_id;
--            getAvailableSp_rslt.prog_script_desc     := ''; --trac_rec.prog_script_desc;
            getAvailableSp_rslt.spObjid              := trac_rec.spObjid;
            getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
--            getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid ,'NUMBER_OF_LINES');
--            getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');
            --CR32952 begin
             /** CR44010
            getAvailableSp_rslt.x_prg_script_text      := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => trac_rec.prg_script_type,
                                                                       ip_script_id => trac_rec.prg_script_id,
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => ip_org_id);
            getAvailableSp_rslt.x_prg_desc_script_text := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => trac_rec.prg_desc_script_type,
                                                                       ip_script_id => trac_rec.prg_desc_script_id,
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => ip_org_id);
            ***/
            getAvailableSp_rslt.x_prg_script_text := trac_rec.x_prg_script_text;
            getAvailableSp_rslt.x_prg_desc_script_text := trac_rec.x_prg_desc_script_text;
            /** CR44010 **/
            --CR32952 end
            getAvailableSp_rslt.x_prog_class := trac_rec.x_prog_class; --CR36130
            getAvailableSp_rslt.x_prog_app_part_number := get_vas_app_card(trac_rec.objid); --CR36130
            if getAvailableSp_rslt.x_prog_app_part_number is not null then  --VAS service
                if trac_rec.objid = getVASservice(ip_esn) then --CR39958   TAS Display $10 Global Card where applicable
                   pipe row (getAvailableSp_rslt);
                end if;
            else
               pipe row (getAvailableSp_rslt);   --No VAS service
            end if;
          end loop;
      end if;


      if ip_org_id in ('TRACFONE', 'NET10')
      then
          for tracnet10_rec in
          (select
            x_program_parameters.objid OBJID, x_program_parameters.x_program_name MKT_NAME, x_program_parameters.x_program_desc DESCRIPTION
              ,  table_part_num.description sp_description
              ,  table_x_pricing.x_retail_price CUSTOMER_PRICE, null IVR_PLAN_ID, x_program_parameters.x_program_name WEBCSR_DISPLAY_NAME
              , x_program_parameters.objid X_SP2PROGRAM_PARAM, x_program_parameters.x_program_name X_PROGRAM_NAME
              , table_part_num.part_number  part_number
              , 0 spObjid
              --,substr(x_program_parameters.x_prg_script_id,1,instr(x_program_parameters.x_prg_script_id,'_')-1) prg_script_type,  --CR32952
              --substr(x_program_parameters.x_prg_script_id,instr(x_program_parameters.x_prg_script_id,'_')+1) prg_script_id,  --CR32952
              --substr(x_program_parameters.x_prg_desc_script_id,1,instr(x_program_parameters.x_prg_desc_script_id,'_')-1) prg_desc_script_type,  --CR32952
              --substr(x_program_parameters.x_prg_desc_script_id,instr(x_program_parameters.x_prg_desc_script_id,'_')+1) prg_desc_script_id  --CR32952
              ,x_program_parameters.x_prog_class --CR36130
              ,ppmv.x_prg_script_text --CR44010
              ,ppmv.x_prg_desc_script_text --CR44010
            FROM sa.X_PROGRAM_PARAMETERS, sa.TABLE_X_PRICING, sa.TABLE_PART_NUM,
                       (select prg_objid, x_prg_script_text, x_prg_desc_script_text
                       from sa.adfcrm_prg_enrolled_script_mv
                       where x_language = upper(ip_language)) ppmv
            WHERE X_PROGRAM_PARAMETERS.PROG_PARAM2BUS_ORG = org_objid
            AND PROG_PARAM2PRTNUM_MONFEE = TABLE_X_PRICING.X_PRICING2PART_NUM
            AND table_x_pricing.x_channel = 'BUYNOW'
            and table_x_pricing.x_end_date >= sysdate
            and table_x_pricing.x_start_date <= sysdate
            AND X_PROGRAM_PARAMETERS.X_CSR_CHANNEL = 1
            and (case
                when x_program_parameters.x_handset_value = 'RESTRICTED' and
                     (SELECT count(*)
                      FROM sa.X_MTM_PROGRAM_HANDSET MTM
                      WHERE PROGRAM_PARAM_OBJID = x_program_parameters.objid
                      AND PART_CLASS_OBJID = get_esn_info_rec.part_class_objid) > 0
                then 'true'
                else 'false'
                end) = 'false'
            and x_program_parameters.x_type = 'INDIVIDUAL'
            and x_program_parameters.x_start_date <= sysdate
            and x_program_parameters.x_end_date >= sysdate
            AND X_PROGRAM_PARAMETERS.PROG_PARAM2PRTNUM_MONFEE = TABLE_PART_NUM.OBJID
            AND TABLE_X_PRICING.X_RETAIL_PRICE = 0
            and upper(x_program_parameters.x_program_name)  like '%BUY%'
            and ppmv.prg_objid = x_program_parameters.OBJID
          )
          loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := tracnet10_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := tracnet10_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := tracnet10_rec.sp_Description;
            getAvailableSp_rslt.Description          := tracnet10_rec.Description;
            getAvailableSp_rslt.Customer_Price       := tracnet10_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := tracnet10_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := tracnet10_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := tracnet10_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := tracnet10_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := tracnet10_rec.part_number;
--            getAvailableSp_rslt.prog_script_id       := ''; --tracnet10_rec.prog_script_id;
--            getAvailableSp_rslt.prog_script_desc     := ''; --tracnet10_rec.prog_script_desc;
            getAvailableSp_rslt.spObjid              := tracnet10_rec.spObjid;
--            getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
--            getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');
            --CR32952 begin
             /** CR44010
            getAvailableSp_rslt.x_prg_script_text      := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => tracnet10_rec.prg_script_type,
                                                                       ip_script_id => tracnet10_rec.prg_script_id,
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => ip_org_id);
            getAvailableSp_rslt.x_prg_desc_script_text := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => tracnet10_rec.prg_desc_script_type,
                                                                       ip_script_id => tracnet10_rec.prg_desc_script_id,
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => ip_org_id);
            ***/
            getAvailableSp_rslt.x_prg_script_text := tracnet10_rec.x_prg_script_text;
            getAvailableSp_rslt.x_prg_desc_script_text := tracnet10_rec.x_prg_desc_script_text;
            /** CR44010 **/
            --CR32952 end
            getAvailableSp_rslt.x_prog_class := tracnet10_rec.x_prog_class; --CR36130
            getAvailableSp_rslt.x_prog_app_part_number := get_vas_app_card(tracnet10_rec.objid); --CR36130
            if getAvailableSp_rslt.x_prog_app_part_number is not null then  --VAS service
                if tracnet10_rec.objid = getVASservice(ip_esn) then --CR39958   TAS Display $10 Global Card where applicable
                   pipe row (getAvailableSp_rslt);
                end if;
            else
               pipe row (getAvailableSp_rslt);   --No VAS service
            end if;
          end loop;
      end if;

--CR38177  Bestbuy Beast - Net10 Promo added in TAS
      if get_esn_info_rec.part_number = 'NTZEZ930G3P5P' --Only Part #(NTZEZ930G3P5P) can enroll in service plans with 'ENROLL_ALLOW'='YES'
      then
          for bestbuy_rec in
                (select distinct
                        SP.OBJID objid, SP.MKT_NAME mkt_name, SP.DESCRIPTION sp_Description
                       ,(select nvl(script_description,description)
                         from sa.adfcrm_service_plan_scripts_mv spmv
                         where spmv.objid = sp.objid
                         and spmv.x_language = upper(ip_language)
                         ) description
                       --, (select sa.adfcrm_scripts.get_plan_description(sp.objid,p_language,'ALL') from dual) description
                       , SP.CUSTOMER_PRICE CUSTOMER_PRICE, SP.IVR_PLAN_ID IVR_PLAN_ID, SP.WEBCSR_DISPLAY_NAME WEBCSR_DISPLAY_NAME
                       ,SPXPP.X_SP2PROGRAM_PARAM X_SP2PROGRAM_PARAM, XPP.X_PROGRAM_NAME X_PROGRAM_NAME
                       ,sa.ADFCRM_GET_SERV_PLAN_VALUE(SP.OBJID,'PLAN_PURCHASE_PART_NUMBER')  part_number
                       , sp.objid spObjid
                       --,substr(XPP.x_prg_script_id,1,instr(XPP.x_prg_script_id,'_')-1) prg_script_type,  --CR32952
                       --substr(XPP.x_prg_script_id,instr(XPP.x_prg_script_id,'_')+1) prg_script_id,  --CR32952
                       --substr(XPP.x_prg_desc_script_id,1,instr(XPP.x_prg_desc_script_id,'_')-1) prg_desc_script_type,  --CR32952
                       --substr(XPP.x_prg_desc_script_id,instr(XPP.x_prg_desc_script_id,'_')+1) prg_desc_script_id  --CR32952
                       ,xpp.x_prog_class x_prog_class--CR36130
                       ,ppmv.x_prg_script_text --CR44010
                       ,ppmv.x_prg_desc_script_text --CR44010
                 FROM  TABLE_PART_INST PI,
                       TABLE_MOD_LEVEL ML,
                       TABLE_PART_NUM PN,
                       sa.adfcrm_serv_plan_class_matview spmv,
                       X_SERVICE_PLAN SP,
                       MTM_SP_X_PROGRAM_PARAM SPXPP,
                       X_PROGRAM_PARAMETERS XPP,
                       (select prg_objid, x_prg_script_text, x_prg_desc_script_text
                       from sa.adfcrm_prg_enrolled_script_mv
                       where x_language = upper(ip_language)) ppmv
                 WHERE  1 =1
                 AND   PI.PART_SERIAL_NO = ip_esn
                 AND   PI.X_PART_INST_STATUS = '52'
                 AND   ML.OBJID = PI.N_PART_INST2PART_MOD
                 and   pn.objid = ml.part_info2part_num
                 AND   spmv.part_class_objid = PN.PART_NUM2PART_CLASS
                 and   sp.objid = spmv.sp_objid
                 and   SPXPP.PROGRAM_PARA2X_SP = SP.OBJID
                 and   XPP.OBJID = SPXPP.X_SP2PROGRAM_PARAM
                 AND   NVL(SPXPP.X_RECURRING,1) = 1
                 and   NVL(sa.adfcrm_GET_SERV_PLAN_VALUE(SP.OBJID,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') not in ('AVAILABLE','ENROLL_ALLOW')
                 and   NVL(sa.adfcrm_GET_SERV_PLAN_VALUE(SP.OBJID,'SERVICE_PLAN_PURCHASE_TAS'),'NOT AVAILABLE') in ('AVAILABLE','ENROLL_ALLOW') -- TAS_2016_03 - CR 38654 - Bestbuy Beast- Modify Reactivation and Activation flows
                 AND   sa.ADFCRM_PLAN_SWITCH_ALLOWED(ip_esn, SP.OBJID) = 'true'
                 and exists (select 'x'
                            from sa.x_program_enrolled
                            where x_sourcesystem = 'BEAST'
                            and pgm_enroll2pgm_parameter = XPP.OBJID
                            and x_esn = ip_esn
                            and x_enrollment_status != 'ENROLLED')  --Checking if customer was enrolled from BEAST

                 and   ppmv.prg_objid = XPP.OBJID
                )
          loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := bestbuy_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := bestbuy_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := bestbuy_rec.sp_Description;
            getAvailableSp_rslt.Description          := bestbuy_rec.Description;
            getAvailableSp_rslt.Customer_Price       := bestbuy_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := bestbuy_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := bestbuy_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := bestbuy_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := bestbuy_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := bestbuy_rec.part_number;
            getAvailableSp_rslt.spObjid              := bestbuy_rec.spObjid;
            getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
            getAvailableSp_rslt.sp_number_of_lines   := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'NUMBER_OF_LINES');
            getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');
            --CR32952 begin
             /** CR44010
            getAvailableSp_rslt.x_prg_script_text      := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => bestbuy_rec.prg_script_type,
                                                                       ip_script_id => bestbuy_rec.prg_script_id,
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => ip_org_id);
            getAvailableSp_rslt.x_prg_desc_script_text := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => bestbuy_rec.prg_desc_script_type,
                                                                       ip_script_id => bestbuy_rec.prg_desc_script_id,
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => ip_org_id);
            ***/
            getAvailableSp_rslt.x_prg_script_text := bestbuy_rec.x_prg_script_text;
            getAvailableSp_rslt.x_prg_desc_script_text := bestbuy_rec.x_prg_desc_script_text;
            /** CR44010 **/
            --CR32952 end
            getAvailableSp_rslt.x_prog_class := bestbuy_rec.x_prog_class; --CR36130
            pipe row (getAvailableSp_rslt);
          end loop;
      end if;

      end if; -- else if ip_org_id = 'NET10' and sa.adfcrm_safelink.is_phone_safelink(ip_esn) = 'true'
      return;
  END getAvailableSpEnrollment;
--********************************************************************************************************************
  function getAvailableSpPurchase(
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getAvailableSp_tab pipelined
  is
      --*** This table function is called from uc241 ***
      org_objid number;
      p_language varchar2(100);
      getAvailableSp_rslt getAvailableSp_rec;
      v_is_ppe varchar2(30);
      smartphone_fun_flag number;
      is_safelink boolean := false; --CR42459
	  filter_addon boolean := false; --CR49890
      v_esn_plan_group varchar2(100); --CR42459
      v_sub_bus_org varchar2(30);
      o_dummy varchar2(30);
      isEsnTripleBenefit varchar2(1); -- CR48383

      cursor esn_plan_group (p_esn in varchar2) is --CR42459
         select nvl(sa.adfcrm_serv_plan.getServPlanGroupType(spsp.x_service_plan_id),'PAY_GO')  plan_group,
	 	spsp.x_service_plan_id
         from sa.table_part_inst pi,
              sa.x_service_plan_site_part spsp
         where pi.part_serial_no = p_esn
         and pi.x_domain = 'PHONES'
         and spsp.table_site_part_id = pi.x_part_inst2site_part
         order by spsp.x_last_modified_date desc;
      esn_plan_group_rec esn_plan_group%rowtype;
      n_service_plan_id number;

      --CR49808 Tracfone Safelink Assist
      cursor get_card_by_promo (p_esn varchar2, p_promo_group_name varchar2, p_purch_card varchar2) is
        select pn.objid objid, null mkt_name,pn.description sp_description,pn.description, p.x_retail_price customer_price,null ivr_plan_id,
                null webcsr_display_name,null x_sp2program_param,null x_program_name,
                null value_name, pn.part_number, pn.part_number property_display
                , pn.x_card_type, pn.x_redeem_units units
                , 0 spObjid
        from   sa.table_part_inst pi,
               sa.table_x_promotion_group pg,
               sa.table_x_group2esn gesn,
               sa.table_part_num pn,
               sa.table_x_pricing p
        where  pi.part_serial_no = p_esn
        and    pi.x_domain = 'PHONES'
        and    pg.group_name = p_promo_group_name
        and    gesn.groupesn2part_inst = pi.objid
        and    gesn.groupesn2x_promo_group = pg.objid
        and    sysdate between gesn.x_start_date and gesn.x_end_date
        and    pn.part_num2x_promotion = gesn.groupesn2x_promotion
        and    pn.domain = 'REDEMPTION CARDS'
        and    nvl(pn.x_purch_card,0) = p_purch_card
        and    p.x_pricing2part_num=pn.objid
        and    p.x_channel='WEBCSR'
        and    sysdate between p.X_START_DATE and p.X_END_DATE;

      function is_ppe(ip_esn varchar2)
          return varchar2
          is
            ret_value varchar2(30) := 'false';
          begin
            select decode(sa.get_param_by_name_fun(pc.name ,'NON_PPE'),'0','true','false') is_ppe
            into ret_value
            from  table_part_inst pi,
                  table_mod_level m,
                  table_part_num pn,
                  table_part_class pc
            where pi.n_part_inst2part_mod = m.objid
            and   m.part_info2part_num = pn.objid
            and   pn.part_num2part_class = pc.objid
            and   pi.part_serial_no = ip_esn;
            return ret_value;
          exception
            when others then
              return ret_value;
          end is_ppe;

  BEGIN

  if ip_esn is not null
  then
     v_is_ppe := is_ppe(ip_esn);
     smartphone_fun_flag := sa.device_util_pkg.get_smartphone_fun(ip_esn);
     p_language := get_language(ip_language);
      org_objid := get_org_objid(ip_org_id);

      if ip_org_id = 'SIMPLE_MOBILE' then
        sa.phone_pkg.get_sub_brand(
          I_ESN => ip_esn,
          o_sub_brand => v_sub_bus_org,
          O_ERRNUM => o_dummy,
          o_errstr => o_dummy
        );

        if v_sub_bus_org = 'GO_SMART' then
          open esn_plan_group(ip_esn);
          fetch esn_plan_group into esn_plan_group_rec;
          close esn_plan_group;
	  n_service_plan_id := esn_plan_group_rec.x_service_plan_id;
        end if;
      end if;

     if sa.adfcrm_safelink.is_still_safelink(ip_esn,ip_org_id) = 'true'
     then
        is_safelink := true;
        --CR42459 If customer is on an Unlimited plan, the system should block the ability to add a PAYGO card
        open esn_plan_group(ip_esn);
        fetch esn_plan_group into esn_plan_group_rec;
        close esn_plan_group;
        esn_plan_group_rec.plan_group := nvl(esn_plan_group_rec.plan_group,'PAY_GO');
     end if;


      if is_safelink
      then
        for safelink_rec in
        (SELECT *
        FROM table(sa.ADFCRM_VO.getSafelinkSp(ip_esn,ip_org_id,ip_language))
        where ServicePlanType = 'AIRTIME'
        AND (ip_org_id <> 'TRACFONE'  --CR42459
             OR
             (ip_org_id = 'TRACFONE' and ( (esn_plan_group_rec.plan_group = 'UNLIMITED' and nvl(service_plan_group,'PAY_GO') <> 'PAY_GO') --CR42459 Only show unlimited plan if current plan is UNLIMITED
                                            or esn_plan_group_rec.plan_group <> 'UNLIMITED'
                                          )
              )
            )
        order by customer_price
        )
        loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := safelink_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := safelink_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := safelink_rec.sp_Description;
            getAvailableSp_rslt.Description          := safelink_rec.Description;
            getAvailableSp_rslt.Customer_Price       := safelink_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := safelink_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := safelink_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := safelink_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := safelink_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := safelink_rec.part_number;
--            getAvailableSp_rslt.prog_script_id       := safelink_rec.prog_script_id;
--            getAvailableSp_rslt.prog_script_desc     := safelink_rec.prog_script_desc;
            getAvailableSp_rslt.x_card_type          := safelink_rec.x_card_type;
            getAvailableSp_rslt.units                := safelink_rec.units;
            getAvailableSp_rslt.ServicePlanType         := safelink_rec.ServicePlanType;
            getAvailableSp_rslt.spObjid              := safelink_rec.spobjid;
            getAvailableSp_rslt.service_plan_group  := safelink_rec.service_plan_group;
            getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
            getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
            getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');
			getAvailableSp_rslt.org_id := ip_org_id;  --CR55070
            pipe row (getAvailableSp_rslt);
        end loop;
      end if; --is_safelink
      if not(is_safelink) and ip_org_id <> 'TRACFONE'
      then

		--CR49890 check if esn is addon compatible if org_id is ST
		--CR55070 added NET10 to filter DATA ADD ON for paygo
		if ip_org_id in ('STRAIGHT_TALK','NET10') and sa.validate_red_card_pkg.is_addon_exclusion(ip_esn) = 'Y' then
            filter_addon := true;
        end if;

        for notrac_rec in
        (select
            SP.OBJID OBJID, SP.MKT_NAME MKT_NAME,
            --SA.ADFCRM_SCRIPTS.GET_PLAN_DESCRIPTION(sp.objid,p_language,'ALL') DESCRIPTION,
            (select nvl(script_description,description)
            from sa.adfcrm_service_plan_scripts_mv spmv
            where spmv.objid = sp.objid
            and spmv.x_language = upper(ip_language)
            ) description,
            sp.description sp_description,
            SP.CUSTOMER_PRICE CUSTOMER_PRICE, SP.IVR_PLAN_ID IVR_PLAN_ID, SP.WEBCSR_DISPLAY_NAME WEBCSR_DISPLAY_NAME
          , SP.OBJID spObjid
          , sp.VALUE_NAME
          , sp.property_value  property_value
          , sp.property_value  property_display
          , null x_card_type
          , null units
        from
            (select distinct
                    SP.OBJID, SP.MKT_NAME, SP.DESCRIPTION, SP.CUSTOMER_PRICE, SP.IVR_PLAN_ID, SP.WEBCSR_DISPLAY_NAME
                   ,'PLAN_PURCHASE_PART_NUMBER' VALUE_NAME
                   ,sa.adfcrm_get_serv_plan_value(SP.OBJID,'PLAN_PURCHASE_PART_NUMBER')  property_value
                   ,'AIRTIME' ServicePlanType
             from  TABLE_PART_INST PI,
                   TABLE_MOD_LEVEL ML,
                   TABLE_PART_NUM PN,
                   sa.adfcrm_serv_plan_class_matview spmv,
                   X_SERVICE_PLAN SP
             where  1 =1
             and   PI.PART_SERIAL_NO = ip_esn
             and   ML.OBJID = PI.N_PART_INST2PART_MOD
             and   pn.objid = ml.part_info2part_num
             and   spmv.part_class_objid = PN.PART_NUM2PART_CLASS
             and   SP.OBJID = spmv.sp_objid
             and   (NVL(sa.adfcrm_get_serv_plan_value(SP.OBJID,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE'
                    OR NVL(sa.adfcrm_get_serv_plan_value(SP.OBJID,'SERVICE_PLAN_PURCHASE_TAS'),'NOT AVAILABLE') = 'AVAILABLE'  -- TAS_2016_03 - CR 38654 - Bestbuy Beast- Modify Reactivation and Activation flows
                    or (nvl(sa.adfcrm_get_serv_plan_value(sp.objid,decode(v_sub_bus_org,'GO_SMART','LEGACY','NOT AVAILABLE')),'NOT AVAILABLE') in ('Y')
                        and sp.objid = n_service_plan_id)
                    )
             ) SP
        WHERE SP.property_value IS NOT NULL
        )
        loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := notrac_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := notrac_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := notrac_rec.sp_Description;
            getAvailableSp_rslt.Description          := notrac_rec.Description;
            getAvailableSp_rslt.Customer_Price       := notrac_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := notrac_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := notrac_rec.Webcsr_Display_Name;
            begin
                select SPXPP.X_SP2PROGRAM_PARAM, XPP.X_PROGRAM_NAME
                into   getAvailableSp_rslt.X_SP2PROGRAM_PARAM, getAvailableSp_rslt.X_Program_Name
                from   MTM_SP_X_PROGRAM_PARAM SPXPP,
                       X_PROGRAM_PARAMETERS XPP
                where SPXPP.PROGRAM_PARA2X_SP = notrac_rec.objid
                and   XPP.OBJID = SPXPP.X_SP2PROGRAM_PARAM
                and   NVL(SPXPP.X_RECURRING,1) = 1
                and   rownum < 2;
            exception
                when others then null;
            end;
            getAvailableSp_rslt.part_number          := notrac_rec.Property_Value;
--            getAvailableSp_rslt.prog_script_id       := ''; --notrac_rec.prog_script_id;
--            getAvailableSp_rslt.prog_script_desc     := ''; --notrac_rec.prog_script_desc;
            getAvailableSp_rslt.ServicePlanType         := 'AIRTIME';
            getAvailableSp_rslt.spObjid              := notrac_rec.spobjid;
			getAvailableSp_rslt.org_id := ip_org_id;  --CR55070
            if nvl(getAvailableSp_rslt.spObjid ,0) <> 0 then
               getAvailableSp_rslt.service_plan_group := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'SERVICE_PLAN_GROUP');
               getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
               getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
               getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');

            end if;
			--CR49890 filter Addons for Straight Talk
			if filter_addon and getAvailableSp_rslt.service_plan_group = 'ADD_ON_DATA' then
				DBMS_OUTPUT.PUT_LINE('Filtered the Add On Plan during Purchase if ESN is not compatible ' || getAvailableSp_rslt.objid);
			else
				pipe row (getAvailableSp_rslt);
			end if;
        end loop;
      end if; --not(is_safelink) and ip_org_id <> 'TRACFONE'
      if ip_org_id = 'TRACFONE'
         and NOT(is_safelink and esn_plan_group_rec.plan_group = 'UNLIMITED') --CR42459
      then
      --CR48383 for ESN with no triple benefits, do not display REDEMPTION CARDS
      isEsnTripleBenefit:= get_EsnTripleBenefit(ip_esn);
      dbms_output.put_line('Value -' || isEsnTripleBenefit);
      if isEsnTripleBenefit ='N' then
        for trac_rec in
        (select pn.objid objid, null mkt_name,pn.description sp_description,pn.description,p.x_retail_price customer_price,null ivr_plan_id,
                null webcsr_display_name,null x_sp2program_param,null x_program_name,
                null value_name, pn.part_number, pn.part_number property_display
                , pn.x_card_type, pn.x_redeem_units units
                , 0 spObjid
        from table_part_num pn, table_part_class pc, table_x_pricing p, table_part_inst pi
        where pn.part_num2bus_org = org_objid
        AND PN.DOMAIN='REDEMPTION CARDS'
        AND PN.X_PURCH_CARD=1
        and pn.x_display_seq is not null
        AND pn.X_UPC <> '999999999999'
        AND PC.OBJID = PN.PART_NUM2PART_CLASS
        and (--CR38145,38153,38161,38162
             nvl(pn.x_sourcesystem,'default') <> 'SMARTPHONE RED CARD' or
             nvl(pn.x_sourcesystem,'default') = 'SMARTPHONE RED CARD' and smartphone_fun_flag = 0)
        AND ((smartphone_fun_flag = 0
             and PN.PART_NUM2X_PROMOTION is null and Pc.Name<>'TFTRACSIZECARD' )
        OR  (smartphone_fun_flag <> 0 and  nvl(PN.X_CARD_TYPE,'NA') <> 'DATA CARD' ))
        and p.x_pricing2part_num=pn.objid
        and ((v_is_ppe = 'false' and nvl(pn.x_card_type,'N/A') = 'TEXT ONLY') or nvl(pn.x_card_type,'N/A') != 'TEXT ONLY') --CR32572 - $10 TracFone Text only Card for Smart Phones
        and (select count(*)
               from   table_part_inst dmpi,
                      table_x_group2esn dmg2e,
                      table_x_promotion_group dmg,
                      table_x_promotion dmp
               where  1=1
               and    dmpi.objid  = groupesn2part_inst
               and    dmg2e.groupesn2x_promo_group = dmg.objid
               and    dmg2e.groupesn2x_promotion   = dmp.objid
               and    dmpi.part_serial_no         = ip_esn
               and    dmg2e.x_start_date <= sysdate
               and    dmg2e.x_end_date >= sysdate
               and    dmg.group_name like '%DBL%'
               and rownum < 2) <= decode(pn.part_number,'TSAPP4DM01',0,
                                                        'TSAPP4DM02',0,
                                                        'TSAPP5TM01',0,
                                                        'TSAPP5TM02',0,1)    -- CR36959 block offering of double minites cards if already in double minutes.
                                    -- Can be blocked Double/Triple min part numbers by checking in-String with DM or TM
                                    --decode(INSTR(part_number, 'DM'), 0,1,
                                           --INSTR(part_number, 'TM'), 0,1,0,0)
        and p.x_channel='WEBCSR'
        AND p.X_START_DATE <= SYSDATE
        AND p.X_END_DATE >= SYSDATE
        AND pi.part_serial_no = ip_esn
        AND pi.x_domain = 'PHONES'
        AND ((pi.x_part_inst_status = '52')
              OR  (nvl(PN.x_redeem_days,0) > 0 and pi.x_part_inst_status <> '52')
              OR  (nvl(pi.warr_end_date,'01-jan-1753') > SYSDATE ))
        )
        loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := trac_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := trac_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := trac_rec.sp_Description;
            getAvailableSp_rslt.Description          := trac_rec.Description;
            getAvailableSp_rslt.Customer_Price       := trac_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := trac_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := trac_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := trac_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := trac_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := trac_rec.part_number;
--            getAvailableSp_rslt.prog_script_id       := ''; --trac_rec.prog_script_id;
--            getAvailableSp_rslt.prog_script_desc     := ''; --trac_rec.prog_script_desc;
            getAvailableSp_rslt.x_card_type          := trac_rec.x_card_type;
            getAvailableSp_rslt.units                := trac_rec.units;
            getAvailableSp_rslt.ServicePlanType         := 'AIRTIME';
            getAvailableSp_rslt.spObjid              := trac_rec.spObjid;
			getAvailableSp_rslt.org_id := ip_org_id;  --CR55070
            if nvl(getAvailableSp_rslt.spObjid ,0) <> 0 then
               getAvailableSp_rslt.service_plan_group := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'SERVICE_PLAN_GROUP');
               getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
               getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
               getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');

            end if;
            pipe row (getAvailableSp_rslt);
        end loop;
--CR48383 do not display pay go plans for esn that are not applicable for Triple Benefits
        else
                  for trac_rec in
        (select pn.objid objid, null mkt_name,pn.description sp_description,pn.description,p.x_retail_price customer_price,null ivr_plan_id,
                null webcsr_display_name,null x_sp2program_param,null x_program_name,
                null value_name, pn.part_number, pn.part_number property_display
                , pn.x_card_type, pn.x_redeem_units units
                , 0 spObjid
        from table_part_num pn, table_part_class pc, table_x_pricing p, table_part_inst pi
        where pn.part_num2bus_org = org_objid
        AND PN.DOMAIN='REDEMPTION CARDS'
        AND PN.X_PURCH_CARD=1
        and pn.x_display_seq is not null
        AND pn.X_UPC <> '999999999999'
        AND PC.OBJID = PN.PART_NUM2PART_CLASS
      --  and (--CR38145,38153,38161,38162 commented for CR 48383
      --       nvl(pn.x_sourcesystem,'default') <> 'SMARTPHONE RED CARD' or
      --       nvl(pn.x_sourcesystem,'default') = 'SMARTPHONE RED CARD' and smartphone_fun_flag = 0)
      and (--added for CR48383
            (nvl(pn.x_sourcesystem,'default') = 'REDEMPTION CARD' and nvl(pn.x_card_type,'N/A') = 'TEXT ONLY') or
          nvl(pn.x_sourcesystem,'default') = 'DATA CARD'
          or nvl(pn.x_sourcesystem,'default') = 'SMARTPHONE RED CARD' and smartphone_fun_flag = 0)
        AND ((smartphone_fun_flag = 0
             and PN.PART_NUM2X_PROMOTION is null and Pc.Name<>'TFTRACSIZECARD' )
        OR  (smartphone_fun_flag <> 0 and  nvl(PN.X_CARD_TYPE,'NA') <> 'DATA CARD' ))
        and p.x_pricing2part_num=pn.objid
        and ((v_is_ppe = 'false' and nvl(pn.x_card_type,'N/A') = 'TEXT ONLY') or nvl(pn.x_card_type,'N/A') != 'TEXT ONLY') --CR32572 - $10 TracFone Text only Card for Smart Phones
        and (select count(*)
               from   table_part_inst dmpi,
                      table_x_group2esn dmg2e,
                      table_x_promotion_group dmg,
                      table_x_promotion dmp
               where  1=1
               and    dmpi.objid  = groupesn2part_inst
               and    dmg2e.groupesn2x_promo_group = dmg.objid
               and    dmg2e.groupesn2x_promotion   = dmp.objid
               and    dmpi.part_serial_no         = ip_esn
               and    dmg2e.x_start_date <= sysdate
               and    dmg2e.x_end_date >= sysdate
               and    dmg.group_name like '%DBL%'
               and rownum < 2) <= decode(pn.part_number,'TSAPP4DM01',0,
                                                        'TSAPP4DM02',0,
                                                        'TSAPP5TM01',0,
                                                        'TSAPP5TM02',0,1)    -- CR36959 block offering of double minites cards if already in double minutes.
                                    -- Can be blocked Double/Triple min part numbers by checking in-String with DM or TM
                                    --decode(INSTR(part_number, 'DM'), 0,1,
                                           --INSTR(part_number, 'TM'), 0,1,0,0)
        and p.x_channel='WEBCSR'
        AND p.X_START_DATE <= SYSDATE
        AND p.X_END_DATE >= SYSDATE
        AND pi.part_serial_no = ip_esn
        AND pi.x_domain = 'PHONES'
        AND ((pi.x_part_inst_status = '52')
              OR  (nvl(PN.x_redeem_days,0) > 0 and pi.x_part_inst_status <> '52')
              OR  (nvl(pi.warr_end_date,'01-jan-1753') > SYSDATE ))
        )
        loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := trac_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := trac_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := trac_rec.sp_Description;
            getAvailableSp_rslt.Description          := trac_rec.Description;
            getAvailableSp_rslt.Customer_Price       := trac_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := trac_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := trac_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := trac_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := trac_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := trac_rec.part_number;
--            getAvailableSp_rslt.prog_script_id       := ''; --trac_rec.prog_script_id;
--            getAvailableSp_rslt.prog_script_desc     := ''; --trac_rec.prog_script_desc;
            getAvailableSp_rslt.x_card_type          := trac_rec.x_card_type;
            getAvailableSp_rslt.units                := trac_rec.units;
            getAvailableSp_rslt.ServicePlanType         := 'AIRTIME';
            getAvailableSp_rslt.spObjid              := trac_rec.spObjid;
			getAvailableSp_rslt.org_id := ip_org_id;  --CR55070
            if nvl(getAvailableSp_rslt.spObjid ,0) <> 0 then
               getAvailableSp_rslt.service_plan_group := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'SERVICE_PLAN_GROUP');
               getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
               getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
               getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');

            end if;
            pipe row (getAvailableSp_rslt);
            end loop;
        end if;
        --CR34599 TF_AP Test 365 Days only-2015 Q2  AP_SERVICE_GRP
        for trac_rec in
        (select pn.objid objid, null mkt_name,pn.description sp_description,pn.description, p.x_retail_price customer_price,null ivr_plan_id,
                null webcsr_display_name,null x_sp2program_param,null x_program_name,
                null value_name, pn.part_number, pn.part_number property_display
                , pn.x_card_type, pn.x_redeem_units units
                , 0 spObjid
        from   sa.table_part_inst pi,
               sa.table_x_promotion_group pg,
               sa.table_x_group2esn gesn,
               sa.table_part_num pn,
               sa.table_x_pricing p
        where  pi.part_serial_no = ip_esn
        and    pi.x_domain = 'PHONES'
        and    pg.group_name = 'AP_SERVICE_GRP'
        and    gesn.groupesn2part_inst = pi.objid
        and    gesn.groupesn2x_promo_group = pg.objid
        and    sysdate between gesn.x_start_date and gesn.x_end_date
        and    pn.part_num2x_promotion = gesn.groupesn2x_promotion
        and    pn.domain = 'REDEMPTION CARDS'
        and    p.x_pricing2part_num=pn.objid
        and    p.x_channel='WEBCSR'
        and    sysdate between p.X_START_DATE and p.X_END_DATE
        )
        loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := trac_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := trac_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := trac_rec.sp_Description;
            getAvailableSp_rslt.Description          := trac_rec.Description;
            getAvailableSp_rslt.Customer_Price       := trac_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := trac_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := trac_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := trac_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := trac_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := trac_rec.part_number;
--            getAvailableSp_rslt.prog_script_id       := ''; --trac_rec.prog_script_id;
--            getAvailableSp_rslt.prog_script_desc     := ''; --trac_rec.prog_script_desc;
            getAvailableSp_rslt.x_card_type          := trac_rec.x_card_type;
            getAvailableSp_rslt.units                := trac_rec.units;
            getAvailableSp_rslt.ServicePlanType         := 'AIRTIME';
            getAvailableSp_rslt.spObjid              := trac_rec.spObjid;
			getAvailableSp_rslt.org_id := ip_org_id;  --CR55070
            if nvl(getAvailableSp_rslt.spObjid ,0) <> 0 then
               getAvailableSp_rslt.service_plan_group := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'SERVICE_PLAN_GROUP');
               getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
               getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
               getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');

            end if;
            pipe row (getAvailableSp_rslt);
        end loop;

        for trac_rec in get_card_by_promo(ip_esn,'SLA_GRP',1)  --CR49808 Tracfone Safelink Assist
        loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := trac_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := trac_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := trac_rec.sp_Description;
            getAvailableSp_rslt.Description          := trac_rec.Description;
            getAvailableSp_rslt.Customer_Price       := trac_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := trac_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := trac_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := trac_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := trac_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := trac_rec.part_number;
--            getAvailableSp_rslt.prog_script_id       := ''; --trac_rec.prog_script_id;
--            getAvailableSp_rslt.prog_script_desc     := ''; --trac_rec.prog_script_desc;
            getAvailableSp_rslt.x_card_type          := trac_rec.x_card_type;
            getAvailableSp_rslt.units                := trac_rec.units;
            getAvailableSp_rslt.ServicePlanType         := 'AIRTIME';
            getAvailableSp_rslt.spObjid              := trac_rec.spObjid;
			getAvailableSp_rslt.org_id := ip_org_id;  --CR55070
            if nvl(getAvailableSp_rslt.spObjid ,0) <> 0 then
               getAvailableSp_rslt.service_plan_group := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'SERVICE_PLAN_GROUP');
               getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
               getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
               getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');

            end if;
            pipe row (getAvailableSp_rslt);
        end loop;
      end if; --ip_org_id = 'TRACFONE'
   end if;   --  if ip_esn is not null
   return;
  END getAvailableSpPurchase;
--********************************************************************************************************************
  function getAvailableSpPurchaseBypClass(
    ip_part_class in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getAvailableSp_tab pipelined
  is
      --*** This table function is called from uc241 ***
      org_objid number;
      p_language varchar2(100);
      getAvailableSp_rslt getAvailableSp_rec;
      smartphone_fun_flag number;
  BEGIN
    if ip_part_class is not null
    then
      p_language := get_language(ip_language);
      --getAvailableSp_rslt := default_values_AvailableSp;
      --getAvailableSp_rslt.Mkt_Name := 'Select Plan';
      --getAvailableSp_rslt.X_Program_Name := 'Select Plan';

      --pipe row (getAvailableSp_rslt);

      org_objid := get_org_objid(ip_org_id);

      if ip_org_id <> 'TRACFONE'
      then
        for notrac_rec in
        (select
            SP.OBJID OBJID, SP.MKT_NAME MKT_NAME,
            --SA.ADFCRM_SCRIPTS.GET_PLAN_DESCRIPTION(sp.objid,p_language,'ALL') DESCRIPTION,
            (select nvl(script_description,description)
            from sa.adfcrm_service_plan_scripts_mv spmv
            where spmv.objid = sp.objid
            and spmv.x_language = upper(ip_language)
            ) description,
            sp.description sp_description,
            SP.CUSTOMER_PRICE CUSTOMER_PRICE, SP.IVR_PLAN_ID IVR_PLAN_ID, SP.WEBCSR_DISPLAY_NAME WEBCSR_DISPLAY_NAME
          , sp.X_SP2PROGRAM_PARAM X_SP2PROGRAM_PARAM, sp.X_PROGRAM_NAME X_PROGRAM_NAME
          , SP.OBJID spObjid
          , sp.VALUE_NAME
          , sp.property_value  property_value
          , sp.property_value  property_display
          , null x_card_type
          , null units
        from
            (select distinct
                    SP.OBJID, SP.MKT_NAME, SP.DESCRIPTION, SP.CUSTOMER_PRICE, SP.IVR_PLAN_ID, SP.WEBCSR_DISPLAY_NAME
                   ,SPXPP.X_SP2PROGRAM_PARAM, XPP.X_PROGRAM_NAME
                   ,'PLAN_PURCHASE_PART_NUMBER' VALUE_NAME
                   ,sa.adfcrm_get_serv_plan_value(SP.OBJID,'PLAN_PURCHASE_PART_NUMBER')  property_value
                   ,'AIRTIME' ServicePlanType
             from  sa.adfcrm_serv_plan_class_matview spmv,
                   X_SERVICE_PLAN SP,
                   MTM_SP_X_PROGRAM_PARAM SPXPP,
                   X_PROGRAM_PARAMETERS XPP
             where  1 =1
             and   spmv.part_class_name = ip_part_class
             and   SP.OBJID = spmv.sp_objid
             and   NVL(sa.adfcrm_get_serv_plan_value(SP.OBJID,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE'
             and   SPXPP.PROGRAM_PARA2X_SP (+) = SP.OBJID
             and   XPP.OBJID (+) = SPXPP.X_SP2PROGRAM_PARAM
             and   NVL(SPXPP.X_RECURRING,1) = 1
             ) SP
        WHERE SP.property_value IS NOT NULL
        )
        loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := notrac_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := notrac_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := notrac_rec.sp_Description;
            getAvailableSp_rslt.Description          := notrac_rec.Description;
            getAvailableSp_rslt.Customer_Price       := notrac_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := notrac_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := notrac_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := notrac_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := notrac_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := notrac_rec.Property_Value;
--            getAvailableSp_rslt.prog_script_id       := ''; --notrac_rec.prog_script_id;
--            getAvailableSp_rslt.prog_script_desc     := ''; --notrac_rec.prog_script_desc;
            getAvailableSp_rslt.ServicePlanType         := 'AIRTIME';
            getAvailableSp_rslt.spObjid              := notrac_rec.spobjid;
            getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
            getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
            getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');

            pipe row (getAvailableSp_rslt);
        end loop;
      end if;
      if ip_org_id = 'TRACFONE'
      then
        smartphone_fun_flag := get_smartphone_fun(ip_part_class);
        for trac_rec in
        (select pn.objid objid, null mkt_name,pn.description sp_description,pn.description,p.x_retail_price customer_price,null ivr_plan_id,
                null webcsr_display_name,null x_sp2program_param,null x_program_name,
                null value_name, pn.part_number, pn.part_number property_display
                , pn.x_card_type, pn.x_redeem_units units
                , 0 spObjid
        from table_part_num pn, table_part_class pc, table_x_pricing p
        where pn.part_num2bus_org = org_objid
        AND PN.DOMAIN='REDEMPTION CARDS'
        AND PN.X_PURCH_CARD=1
        and pn.x_display_seq is not null
        AND pn.X_UPC <> '999999999999'
        AND PC.OBJID = PN.PART_NUM2PART_CLASS
        and (--CR38145,38153,38161,38162
             nvl(pn.x_sourcesystem,'default') <> 'SMARTPHONE RED CARD' or
             nvl(pn.x_sourcesystem,'default') = 'SMARTPHONE RED CARD' and smartphone_fun_flag = 0)
        AND ((smartphone_fun_flag = 0
             and PN.PART_NUM2X_PROMOTION is null and Pc.Name<>'TFTRACSIZECARD' )
        OR  (smartphone_fun_flag <> 0 and  nvl(PN.X_CARD_TYPE,'NA') <> 'DATA CARD' ))
        and p.x_pricing2part_num=pn.objid
        and p.x_channel='WEBCSR'
        AND p.X_START_DATE <= SYSDATE
        AND p.X_END_DATE >= SYSDATE
        AND nvl(PN.x_redeem_days,0) > 0
        )
        loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := trac_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := trac_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := trac_rec.sp_Description;
            getAvailableSp_rslt.Description          := trac_rec.Description;
            getAvailableSp_rslt.Customer_Price       := trac_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := trac_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := trac_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := trac_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := trac_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := trac_rec.part_number;
--            getAvailableSp_rslt.prog_script_id       := ''; --trac_rec.prog_script_id;
--            getAvailableSp_rslt.prog_script_desc     := ''; --trac_rec.prog_script_desc;
            getAvailableSp_rslt.x_card_type          := trac_rec.x_card_type;
            getAvailableSp_rslt.units                := trac_rec.units;
            getAvailableSp_rslt.ServicePlanType         := 'AIRTIME';
            getAvailableSp_rslt.spObjid              := trac_rec.spObjid;
            getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
            --getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
            --getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');
            pipe row (getAvailableSp_rslt);
        end loop;
      end if;
   end if;
   return;
  END getAvailableSpPurchaseBypClass;
  --********************************************************************************************************************
  function getWorkForcePins(
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2,
    ip_type in varchar2
  )
  RETURN getAvailableSp_tab pipelined
  is
      --*** This table function is called from uc200 ***
      org_objid number;
      p_language varchar2(100);
      getAvailableSp_rslt getAvailableSp_rec;
      get_esn_info_rec  get_esn_info%rowtype;
      cnt_lid number := 0;
  BEGIN
      p_language := get_language(ip_language);
      org_objid := get_org_objid(ip_org_id);
   --if ip_org_id = 'NET10' and sa.adfcrm_safelink.is_phone_safelink(ip_esn) = 'true'
   --CR44956 Only check in x_sl_currentvals to verify if phone is safelink
   select count(*)
   into cnt_lid
   from sa.x_sl_currentvals
   where x_current_esn = ip_esn;

   if ip_org_id = 'NET10' and cnt_lid > 0
   then
        for safelink_rec in
        (select distinct spmv.sp_objid sp_objid
               ,sp.description sp_description
               ,sa.adfcrm_scripts.get_plan_description(spmv.sp_objid,p_language,'ALL') description
               ,pin_pn.part_number workforce_part_number
         from  table_part_num pin_pn,
               sa.adfcrm_serv_plan_class_matview spmv,
               table_part_inst pi,
               table_mod_level ml,
               table_part_num esn_pn,
               sa.adfcrm_serv_plan_class_matview spmv2,
               sa.x_service_plan sp
         where pin_pn.x_card_type = 'WORKFORCE'
          and pin_pn.part_type <> 'PAIDACT'
          and pin_pn.part_num2bus_org = org_objid
          and spmv.part_class_objid = pin_pn.part_num2part_class
          and pi.part_serial_no = ip_esn
          and ml.objid = pi.n_part_inst2part_mod
          and esn_pn.objid = ml.part_info2part_num
          and spmv2.part_class_objid = esn_pn.part_num2part_class
          and spmv.sp_objid = spmv2.sp_objid --check service plan compatible
          and sp.objid = spmv.sp_objid
          and nvl(sa.adfcrm_get_serv_plan_value(sp.objid,'SAFELINK_ONLY'),'N') = 'Y'
        )
        loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := safelink_rec.sp_objid;
            getAvailableSp_rslt.sp_Description       := safelink_rec.sp_Description;
            getAvailableSp_rslt.Description          := safelink_rec.description;
            getAvailableSp_rslt.part_number          := safelink_rec.workforce_part_number;
            getAvailableSp_rslt.ServicePlanType         := 'WORKFORCE';
            pipe row (getAvailableSp_rslt);
        end loop;
   else
      if ip_org_id  <> 'TRACFONE' and ip_type = 'REGULAR'
      then
         open get_esn_info(ip_esn);
         fetch get_esn_info into get_esn_info_rec;
         if get_esn_info%found then
            for rec in
            (select distinct spmv.sp_objid sp_objid
                   ,sp.description sp_description
                   ,sa.adfcrm_scripts.get_plan_description(spmv.sp_objid,p_language,'ALL') description
                   ,pin_pn.part_number workforce_part_number
                   ,0 spObjid
             from  table_part_num pin_pn,
                   sa.adfcrm_serv_plan_class_matview spmv,
                   table_part_inst pi,
                   table_mod_level ml,
                   table_part_num esn_pn,
                   sa.adfcrm_serv_plan_class_matview spmv2,
                   sa.x_service_plan sp
             where pin_pn.x_card_type = 'WORKFORCE'
              and pin_pn.part_type <> 'PAIDACT'
              and pin_pn.part_num2bus_org = org_objid
              and spmv.part_class_objid = pin_pn.part_num2part_class
              and pi.part_serial_no = ip_esn
              and ml.objid = pi.n_part_inst2part_mod
              and esn_pn.objid = ml.part_info2part_num
              and spmv2.part_class_objid = esn_pn.part_num2part_class
              and spmv.sp_objid = spmv2.sp_objid --check service plan compatible
              and sp.objid = spmv.sp_objid
              and nvl(sa.adfcrm_get_serv_plan_value(sp.objid,'IGNORE_IG_FLAG'),'N') <> 'Y' -- 39916 : For not displaying ADD_ON Service Plans
              and nvl(sa.adfcrm_get_serv_plan_value(sp.objid,'SAFELINK_ONLY'),'N') = 'N'
            )
            loop
                getAvailableSp_rslt := default_values_AvailableSp;
                getAvailableSp_rslt.objid                := rec.sp_objid;
                getAvailableSp_rslt.sp_Description       := rec.sp_Description;
                getAvailableSp_rslt.Description          := rec.description;
                getAvailableSp_rslt.part_number          := rec.workforce_part_number;
                getAvailableSp_rslt.ServicePlanType         := 'WORKFORCE';
                pipe row (getAvailableSp_rslt);
            end loop;
        else
            if ip_org_id  = 'TOTAL_WIRELESS' then
                for rec in
                (select distinct spmv.sp_objid sp_objid
                       ,sp.description sp_description
                       ,sa.adfcrm_scripts.get_plan_description(spmv.sp_objid,p_language,'ALL') description
                       ,pin_pn.part_number workforce_part_number
                       ,0 spObjid
                 from  table_part_num pin_pn,
                       sa.adfcrm_serv_plan_class_matview spmv,
                       sa.adfcrm_serv_plan_class_matview spmv2,
                       sa.x_service_plan sp
                 where pin_pn.x_card_type = 'WORKFORCE'
                  and pin_pn.part_type <> 'PAIDACT'
                  and pin_pn.part_num2bus_org = org_objid
                  and spmv.part_class_objid = pin_pn.part_num2part_class
                  and spmv2.part_class_name = 'TWBYOPVZ'   --default part class for TOTAL_WIRELESS
                  and spmv.sp_objid = spmv2.sp_objid --check service plan compatible
                  and sp.objid = spmv.sp_objid
                  and nvl(sa.adfcrm_get_serv_plan_value(sp.objid,'SAFELINK_ONLY'),'N') = 'N'
                )
                loop
                    getAvailableSp_rslt := default_values_AvailableSp;
                    getAvailableSp_rslt.objid                := rec.sp_objid;
                    getAvailableSp_rslt.sp_Description       := rec.sp_Description;
                    getAvailableSp_rslt.Description          := rec.description;
                    getAvailableSp_rslt.part_number          := rec.workforce_part_number;
                    getAvailableSp_rslt.ServicePlanType         := 'WORKFORCE';
                    pipe row (getAvailableSp_rslt);
                end loop;
            end if;
        end if;
        close get_esn_info;
      end if;

      if  (ip_org_id  = 'TRACFONE' and ip_type = 'REGULAR') or
          (ip_type = 'BYOP')
      then
        for rec in
        (select pn1.objid --sp_objid
                ,pn1.description --sp_description,
                ,pn1.part_number  --workforce_part_number
         from table_part_num pn1
         where pn1.part_num2bus_org = org_objid
         and pn1.x_card_type = 'WORKFORCE'
         and (case
              when ip_type = 'BYOP' and pn1.part_type = 'PAIDACT' then  1
              when ip_type = 'REGULAR' and ip_org_id = 'TRACFONE' and pn1.part_type <> 'PAIDACT'  then 1
              else 0
              end) = 1
        and (--CR42459 exclude SL Unlimited for no Safelink customers
               (cnt_lid = 0 and
                pn1.part_number not like 'SL%' and
                not exists (select svpc.*
                            from sa.adfcrm_serv_plan_class_matview svpc,
                                 sa.adfcrm_serv_plan_feat_matview svpf
                            where 1 = 1
                            and svpc.part_class_objid = pn1.part_num2part_class
                            and svpf.sp_objid = svpc.sp_objid
                            and svpf.fea_name = 'SAFELINK_ONLY'
                            and svpf.fea_value = 'Y'
                            )
               )
            OR cnt_lid > 0
            )
        and (--CR49808 Tracfone Safelink Assist
             nvl(pn1.part_num2x_promotion,-1) <= 0 or
             (nvl(pn1.part_num2x_promotion,-1) > 0 and
                   exists (select 'x'
                          from   sa.table_part_inst pi,
                                 sa.table_x_promotion_group pg,
                                 sa.table_x_group2esn gesn
                          where  pi.part_serial_no = ip_esn
                          and    pi.x_domain = 'PHONES'
                          and    gesn.groupesn2part_inst = pi.objid
                          and    gesn.groupesn2x_promo_group = pg.objid
                          and    sysdate between gesn.x_start_date and gesn.x_end_date
                          and    gesn.groupesn2x_promotion = pn1.part_num2x_promotion
                          )
             )
            )
        )
        loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := rec.objid;
            getAvailableSp_rslt.sp_Description       := rec.Description;
            getAvailableSp_rslt.Description          := rec.Description;
            getAvailableSp_rslt.part_number          := rec.part_number;
            getAvailableSp_rslt.ServicePlanType         := 'WORKFORCE';
            pipe row (getAvailableSp_rslt);
        end loop;
      end if;
   end if;
   return;
  END getWorkForcePins;
--********************************************************************************************************************

  function get_rtr_trans_func(
    ip_min in varchar2,
    ip_serial in varchar2,
    ip_red_code in varchar2)

  return x_rtr_trans_tab pipelined
  is
    x_rtr_trans_rslt x_rtr_trans_rec;
    rtr_cur          sys_refcursor;
    stmt             varchar2(4000);
    n_objid                number;
    v_tf_serial_num        varchar2(100);
    v_tf_red_code          varchar2(30);
    v_tf_pin_status_code   varchar2(100);
    d_tf_trans_date        date;
    v_rtr_trans_type       varchar2(40);
    v_tf_min               varchar2(30);
  begin
    stmt := ' select objid, tf_serial_num, tf_red_code, tf_pin_status_code, tf_trans_date, rtr_trans_type, tf_min from sa.x_rtr_trans where 1=1 ';

    if ip_min is not null then
      stmt := stmt || 'and tf_min = '''||ip_min||''' ';
    end if;
    if ip_serial is not null then
      stmt := stmt || 'and tf_serial_num = '''||ip_serial||''' ';
    end if;
    if ip_red_code is not null then
      stmt := stmt || 'and tf_red_code = '''||ip_red_code||''' ';
    end if;

    if ip_min is null and
       ip_serial is null and
       ip_red_code is null then
       stmt := 'select null objid, null tf_serial_num, null tf_red_code, null tf_pin_status_code, null tf_trans_date, null rtr_trans_type, null tf_min from dual where rownum <1';
    end if;

    dbms_output.put_line(stmt);
    open rtr_cur for stmt;
    loop
    fetch rtr_cur
    into n_objid, v_tf_serial_num, v_tf_red_code, v_tf_pin_status_code, d_tf_trans_date, v_rtr_trans_type, v_tf_min;
    exit when rtr_cur%notfound;

      x_rtr_trans_rslt.objid              := n_objid;
      x_rtr_trans_rslt.tf_serial_num      := v_tf_serial_num;
      x_rtr_trans_rslt.tf_red_code        := v_tf_red_code;
      x_rtr_trans_rslt.tf_pin_status_code := v_tf_pin_status_code;
      x_rtr_trans_rslt.tf_trans_date      := d_tf_trans_date;
      x_rtr_trans_rslt.rtr_trans_type     := v_rtr_trans_type;
      x_rtr_trans_rslt.tf_min             := v_tf_min;

      pipe row (x_rtr_trans_rslt);
    end loop;
    close rtr_cur;
    return;
  end get_rtr_trans_func;

  ------------------------------------------------------------------------------

  --********************************************************************************************************************
    function default_values_FamilySp
    return getFamilySp_rec
    is
       getFamilySp_rslt getFamilySp_rec;
    begin
       getFamilySp_rslt.web_user_objid       := 0;
       getFamilySp_rslt.objid                := 0;
       getFamilySp_rslt.Description          := '';
       getFamilySp_rslt.display_name         := '';
       getFamilySp_rslt.part_number          := null;
       getFamilySp_rslt.customer_price       := null;
       getFamilySp_rslt.ph_count             := 0;
       getFamilySp_rslt.billing_recurring_id := 0;
       getFamilySp_rslt.part_number_grp      := null;
       getFamilySp_rslt.customer_price_grp   := 0;

       return getFamilySp_rslt;
    end default_values_FamilySp;

--********************************************************************************************************************
  function getFamilyPlan(
    ip_web_user_id in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getFamilySp_tab pipelined
  is
      --*** This table function is called from uc236 ***
      cursor get_ph_count (ip_web_user_id in number,
                           ip_prog_param_id in number)
        is (select count(1) ph_count
            from sa.x_program_enrolled pe,
                 sa.table_part_inst pi,
                 sa.table_web_user wu,
                 sa.table_x_contact_part_inst cpi
            where pe.pgm_enroll2pgm_parameter = ip_prog_param_id
            and pe.x_enrollment_status = 'ENROLLED'
            and pi.part_serial_no = pe.x_esn
            and wu.objid = ip_web_user_id
            and cpi.x_contact_part_inst2contact = wu.web_user2contact
            and cpi.x_contact_part_inst2part_inst = pi.objid);
      get_ph_count_rec get_ph_count%rowtype;
      org_objid number;
      p_language varchar2(100);
      getFamilySp_rslt getFamilySp_rec;
  BEGIN
      p_language := get_language(ip_language);
      getFamilySp_rslt := default_values_FamilySp;
      getFamilySp_rslt.Description := 'Select Plan';
      getFamilySp_rslt.display_name := 'Select Plan';
      pipe row (getFamilySp_rslt);

      org_objid := get_org_objid(ip_org_id);
      if  ip_org_id  = 'NET10'
      then
        for rec in
        (select distinct
               pp.objid objid,pp.x_program_name description, pp.x_program_name display_name,
               sa.adfcrm_get_serv_plan_value(sp.objid,'PLAN_PURCHASE_PART_NUMBER') part_number,
               sp.customer_price,
               pp.objid billing_recurring_id, null part_number_grp, 0 customer_price_grp,
               sp.objid spObjid
               ,substr(pp.x_prg_script_id,1,instr(pp.x_prg_script_id,'_')-1) prg_script_type,  --CR32952
                substr(pp.x_prg_script_id,instr(pp.x_prg_script_id,'_')+1) prg_script_id,  --CR32952
                substr(pp.x_prg_desc_script_id,1,instr(pp.x_prg_desc_script_id,'_')-1) prg_desc_script_type,  --CR32952
                substr(pp.x_prg_desc_script_id,instr(pp.x_prg_desc_script_id,'_')+1) prg_desc_script_id  --CR32952
         from  sa.x_program_parameters pp,
               sa.mtm_sp_x_program_param mtm,
               sa.adfcrm_serv_plan_feat_matview spfmv,
               sa.x_service_plan sp
         where pp.objid in (5801160,5801323)
         and   mtm.x_sp2program_param = pp.objid
         and   mtm.program_para2x_sp = sp.objid
         and   spfmv.sp_objid = mtm.program_para2x_sp
         and   spfmv.fea_name = 'SERVICE_PLAN_PURCHASE'
         and   spfmv.fea_value in ('AVAILABLE','ENROLL_ALLOW')
         and   sa.adfcrm_get_serv_plan_value(spfmv.sp_objid,'RECURRING_SERVICE_PLAN') is null
        )
        loop
            getFamilySp_rslt.web_user_objid       := ip_web_user_id;
            getFamilySp_rslt.objid                := rec.objid;
            getFamilySp_rslt.Description          := rec.description;
            getFamilySp_rslt.display_name         := rec.display_name;
            getFamilySp_rslt.part_number          := rec.part_number;
            getFamilySp_rslt.customer_price       := rec.customer_price;
            open get_ph_count(ip_web_user_id,rec.billing_recurring_id);
            fetch get_ph_count into get_ph_count_rec;
            if get_ph_count%found then
               getFamilySp_rslt.ph_count          := get_ph_count_rec.ph_count;
            else
               getFamilySp_rslt.ph_count          := 0;
            end if;
            close get_ph_count;
            getFamilySp_rslt.billing_recurring_id := rec.billing_recurring_id;
            getFamilySp_rslt.part_number_grp      := rec.part_number_grp;
            getFamilySp_rslt.customer_price_grp   := rec.customer_price_grp;
            --CR32952 begin
            getFamilySp_rslt.x_prg_script_text      := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => rec.prg_script_type,
                                                                       ip_script_id => rec.prg_script_id,
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => ip_org_id);
            getFamilySp_rslt.x_prg_desc_script_text := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => rec.prg_desc_script_type,
                                                                       ip_script_id => rec.prg_desc_script_id,
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => ip_org_id);
            --CR32952 end
            pipe row (getFamilySp_rslt);
        end loop;
      end if;
        for rec in
        (select distinct
               pp.objid objid,pp.x_program_name description, pp.x_program_name display_name,
               pn1.part_number, pr1.x_retail_price customer_price,
               pp.objid billing_recurring_id, pn2.part_number part_number_grp, pr2.x_retail_price customer_price_grp
               , 0 spObjid
               ,substr(pp.x_prg_script_id,1,instr(pp.x_prg_script_id,'_')-1) prg_script_type,  --CR32952
                substr(pp.x_prg_script_id,instr(pp.x_prg_script_id,'_')+1) prg_script_id,  --CR32952
                substr(pp.x_prg_desc_script_id,1,instr(pp.x_prg_desc_script_id,'_')-1) prg_desc_script_type,  --CR32952
                substr(pp.x_prg_desc_script_id,instr(pp.x_prg_desc_script_id,'_')+1) prg_desc_script_id  --CR32952
         from  sa.x_program_parameters pp,
               sa.table_part_num pn1,
               sa.table_x_pricing pr1,
               sa.table_part_num pn2,
               sa.table_x_pricing pr2
         where pp.x_type = 'GROUP'
         and   pp.x_csr_channel = 1
         and   pp.prog_param2bus_org = org_objid
         and   pp.x_start_date <= sysdate
         and   pp.x_end_date >= sysdate
         and   pn1.objid = pp.prog_param2prtnum_monfee
         and   pr1.x_pricing2part_num = pn1.objid
         and   pr1.x_channel = 'BILLING'
         and   pr1.x_end_date >= sysdate
         and   pr1.x_start_date <= sysdate
         and   pn2.objid = pp.prog_param2prtnum_grpmonfee
         and   pr2.x_pricing2part_num = pn2.objid
         and   pr2.x_channel = 'BILLING'
         and   pr2.x_end_date >= sysdate
         and   pr2.x_start_date <= sysdate
         )
        loop
            getFamilySp_rslt.web_user_objid       := ip_web_user_id;
            getFamilySp_rslt.objid                := rec.objid;
            getFamilySp_rslt.Description          := rec.description;
            getFamilySp_rslt.display_name         := rec.display_name;
            getFamilySp_rslt.part_number          := rec.part_number;
            getFamilySp_rslt.customer_price       := rec.customer_price;
            open get_ph_count(ip_web_user_id,rec.billing_recurring_id);
            fetch get_ph_count into get_ph_count_rec;
            if get_ph_count%found then
               getFamilySp_rslt.ph_count          := get_ph_count_rec.ph_count;
            else
               getFamilySp_rslt.ph_count          := 0;
            end if;
            close get_ph_count;
            getFamilySp_rslt.billing_recurring_id := rec.billing_recurring_id;
            getFamilySp_rslt.part_number_grp      := rec.part_number_grp;
            getFamilySp_rslt.customer_price_grp   := rec.customer_price_grp;
            --CR32952 begin
            getFamilySp_rslt.x_prg_script_text      := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => rec.prg_script_type,
                                                                       ip_script_id => rec.prg_script_id,
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => ip_org_id);
            getFamilySp_rslt.x_prg_desc_script_text := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => rec.prg_desc_script_type,
                                                                       ip_script_id => rec.prg_desc_script_id,
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => ip_org_id);
            --CR32952 end

            pipe row (getFamilySp_rslt);
        end loop;
      return;
  end getFamilyPlan;
--********************************************************************************************************************
  function getAvailableSpCompRepl(
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getAvailableSp_tab pipelined
  is
      getAvailableSp_rslt getAvailableSp_rec;
  begin
      for rec in (select * from table(sa.adfcrm_vo.getavailablespcomprepl(ip_esn,ip_org_id,ip_language,null)))
      loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := rec.objid;
            getAvailableSp_rslt.Mkt_Name             := rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := rec.sp_Description;
            getAvailableSp_rslt.Description          := rec.Description;
            getAvailableSp_rslt.Customer_Price       := rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := rec.X_Program_Name;
            getavailablesp_rslt.part_number          := rec.part_number;
--            getavailablesp_rslt.prog_script_id       := rec.prog_script_id;
--            getAvailableSp_rslt.prog_script_desc     := rec.prog_script_desc;
            getAvailableSp_rslt.spObjid              := rec.spObjid;
            getAvailableSp_rslt.ServicePlanType  := rec.ServicePlanType;
            getAvailableSp_rslt.Service_Plan_Group := rec.Service_Plan_Group;
            getAvailableSp_rslt.sp_biz_line          := rec.sp_biz_line;
            getAvailableSp_rslt.sp_number_of_lines   := rec.sp_number_of_lines;
            getAvailableSp_rslt.sp_add_on_card_flag  := rec.sp_add_on_card_flag;
            pipe row (getAvailableSp_rslt);
      end loop;
   return;
  end;
--********************************************************************************************************************
  function getAvailableSpCompRepl(
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2,
    ip_value in varchar2 -- CR32367
  )
  RETURN getAvailableSp_tab pipelined
  is
      --*** This table function is called from uc215 ***
      --org_objid number;
      cursor esn_plan_group (p_esn in varchar2) is --CR42459
         select nvl(sa.adfcrm_serv_plan.getServPlanGroupType(spsp.x_service_plan_id),'PAY_GO')  plan_group
         from sa.table_part_inst pi,
              sa.x_service_plan_site_part spsp
         where pi.part_serial_no = p_esn
         and pi.x_domain = 'PHONES'
         and spsp.table_site_part_id = pi.x_part_inst2site_part
         order by spsp.x_last_modified_date desc;
      esn_plan_group_rec esn_plan_group%rowtype;
      p_language varchar2(100);
      is_safelink varchar2(100) := 'false';
      v_show_paygo varchar2(100) := 'true';
      v_paygo_plans number := 0;
      getAvailableSp_rslt getAvailableSp_rec;

     v_addonfilter varchar2(30); --CR55070
            function is_ppe(ip_esn varchar2)
          return varchar2
          is
            ret_value varchar2(30) := 'false';
          begin
            select decode(sa.get_param_by_name_fun(pc.name ,'NON_PPE'),'0','true','false') is_ppe
            into ret_value
            from  table_part_inst pi,
                  table_mod_level m,
                  table_part_num pn,
                  table_part_class pc
            where pi.n_part_inst2part_mod = m.objid
            and   m.part_info2part_num = pn.objid
            and   pn.part_num2part_class = pc.objid
            and   pi.part_serial_no = ip_esn;
            return ret_value;
          exception
            when others then
              return ret_value;
          end is_ppe;

  BEGIN
      p_language := get_language(ip_language);
      getAvailableSp_rslt := default_values_AvailableSp;
      getAvailableSp_rslt.objid := -2;
      getAvailableSp_rslt.Mkt_Name := 'Please select a Service Plan';
      getAvailableSp_rslt.X_Program_Name := 'Select Plan';
      pipe row (getAvailableSp_rslt);
      --org_objid := get_org_objid(ip_org_id);
      is_safelink := sa.adfcrm_safelink.is_still_safelink(ip_esn,ip_org_id);
      if ip_org_id ='TRACFONE' and is_safelink = 'true'
      then
          --CR42459 If customer is on an Unlimited plan, the system should block the ability to add a PAYGO card
          open esn_plan_group(ip_esn);
          fetch esn_plan_group into esn_plan_group_rec;
          close esn_plan_group;
          esn_plan_group_rec.plan_group := nvl(esn_plan_group_rec.plan_group,'PAY_GO');
          if esn_plan_group_rec.plan_group = 'UNLIMITED'
          then
              v_show_paygo := 'false';
          end if;
      end if;

   if ip_org_id = 'NET10' and is_safelink = 'true'
   then
        for safelink_rec in
        (
        -- CR36435 -- To show Paygo Plans as single Item in drop down
        select
         -1 OBJID, 'Pay as You Go' MKT_NAME, 'Pay as You Go' sp_description,
          'Pay as You Go' DESCRIPTION,
          0 CUSTOMER_PRICE, 0 IVR_PLAN_ID, 'Pay as You Go' WEBCSR_DISPLAY_NAME
        , null X_SP2PROGRAM_PARAM, null X_PROGRAM_NAME
        , null spObjid
        , null VALUE_NAME
        , null  property_value
        , null  property_display
      from dual
      where
      (select
        count(*) as paygo_count
      from
          (select distinct
                    SP.OBJID, SP.MKT_NAME, SP.DESCRIPTION, SP.CUSTOMER_PRICE, SP.IVR_PLAN_ID, SP.WEBCSR_DISPLAY_NAME
                   ,'' X_SP2PROGRAM_PARAM, '' X_PROGRAM_NAME
                   ,'PLAN_PURCHASE_PART_NUMBER' VALUE_NAME
                   ,spfmv.fea_value  property_value
             from  sa.TABLE_PART_INST PI,
                   sa.x_program_enrolled pe,
                   sa.mtm_program_safelink mtmsp,
                   sa.table_part_num pn2mtmsp,
                   sa.TABLE_MOD_LEVEL ML,
                   sa.TABLE_PART_NUM PN,
                   sa.adfcrm_serv_plan_class_matview spmv,
                   sa.X_SERVICE_PLAN SP,
                   sa.adfcrm_serv_plan_feat_matview spfmv
                   --sa.MTM_SP_X_PROGRAM_PARAM SPXPP,
                   --sa.X_PROGRAM_PARAMETERS XPP
             where  1 =1
             and   PI.PART_SERIAL_NO = ip_esn
             and   pe.x_esn = PI.PART_SERIAL_NO
             and   pe.x_enrollment_status not in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
             and   mtmsp.program_param_objid = pe.pgm_enroll2pgm_parameter
             and   mtmsp.start_date <= SYSDATE
             and   mtmsp.end_date   > trunc(SYSDATE)+1
             and   pn2mtmsp.objid = mtmsp.part_num_objid
             and   ML.OBJID = PI.N_PART_INST2PART_MOD
             and   pn.objid = ml.part_info2part_num
             and   spmv.part_class_objid = PN.PART_NUM2PART_CLASS
             and   SP.OBJID = spmv.sp_objid
             and   spfmv.sp_objid = sp.objid
             and   spfmv.fea_name = 'PLAN_PURCHASE_PART_NUMBER'
             and   spfmv.fea_value = pn2mtmsp.s_part_number
             and   NVL(sa.adfcrm_get_serv_plan_value(SP.OBJID,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE'
             --and   SPXPP.PROGRAM_PARA2X_SP = SP.OBJID
             --and   XPP.OBJID = SPXPP.X_SP2PROGRAM_PARAM
             --and   NVL(SPXPP.X_RECURRING,1) = 1
             and   sa.ADFCRM_GET_SERV_PLAN_VALUE(SP.OBJID,'SAFELINK_ONLY') = 'Y'
             and NVL(SP.WEBCSR_DISPLAY_NAME, 'Not Paygo') = 'Paygo' -- CR36435
          ) paygo ) > 0

        union all

        select
            SP.OBJID OBJID, SP.MKT_NAME MKT_NAME, sp.description sp_description,
            sa.ADFCRM_SCRIPTS.GET_PLAN_DESCRIPTION(sp.objid,p_language,'ALL') DESCRIPTION,
            SP.CUSTOMER_PRICE CUSTOMER_PRICE, SP.IVR_PLAN_ID IVR_PLAN_ID, SP.WEBCSR_DISPLAY_NAME WEBCSR_DISPLAY_NAME
          , sp.X_SP2PROGRAM_PARAM X_SP2PROGRAM_PARAM, sp.X_PROGRAM_NAME X_PROGRAM_NAME
          , SP.OBJID spObjid
          , sp.VALUE_NAME
          , sp.property_value  property_value
          , sp.property_value  property_display
        from
            (select distinct
                    SP.OBJID, SP.MKT_NAME, SP.DESCRIPTION, SP.CUSTOMER_PRICE, SP.IVR_PLAN_ID, SP.WEBCSR_DISPLAY_NAME
                   ,'' X_SP2PROGRAM_PARAM, '' X_PROGRAM_NAME
                   ,'PLAN_PURCHASE_PART_NUMBER' VALUE_NAME
                   ,spfmv.fea_value  property_value
             from  sa.TABLE_PART_INST PI,
                   sa.x_program_enrolled pe,
                   sa.mtm_program_safelink mtmsp,
                   sa.table_part_num pn2mtmsp,
                   sa.TABLE_MOD_LEVEL ML,
                   sa.TABLE_PART_NUM PN,
                   sa.adfcrm_serv_plan_class_matview spmv,
                   sa.X_SERVICE_PLAN SP,
                   sa.adfcrm_serv_plan_feat_matview spfmv
                   --sa.MTM_SP_X_PROGRAM_PARAM SPXPP,
                   --sa.X_PROGRAM_PARAMETERS XPP
             where  1 =1
             and   PI.PART_SERIAL_NO = ip_esn
             and   pe.x_esn = PI.PART_SERIAL_NO
             and   pe.x_enrollment_status not in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
             and   mtmsp.program_param_objid = pe.pgm_enroll2pgm_parameter
             and   mtmsp.start_date <= SYSDATE
             and   mtmsp.end_date   > trunc(SYSDATE)+1
             and   pn2mtmsp.objid = mtmsp.part_num_objid
             and   ML.OBJID = PI.N_PART_INST2PART_MOD
             and   pn.objid = ml.part_info2part_num
             and   spmv.part_class_objid = PN.PART_NUM2PART_CLASS
             and   SP.OBJID = spmv.sp_objid
             and   spfmv.sp_objid = sp.objid
             and   spfmv.fea_name = 'PLAN_PURCHASE_PART_NUMBER'
             and   spfmv.fea_value = pn2mtmsp.s_part_number
             and   NVL(sa.adfcrm_get_serv_plan_value(SP.OBJID,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE'
             --and   SPXPP.PROGRAM_PARA2X_SP = SP.OBJID
             --and   XPP.OBJID = SPXPP.X_SP2PROGRAM_PARAM
             --and   NVL(SPXPP.X_RECURRING,1) = 1
             and   sa.ADFCRM_GET_SERV_PLAN_VALUE(SP.OBJID,'SAFELINK_ONLY') = 'Y'
             and NVL(SP.WEBCSR_DISPLAY_NAME, 'Not Paygo') <> 'Paygo' -- CR36435
             ) SP
         )
        loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := safelink_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := safelink_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := safelink_rec.Description;
            getAvailableSp_rslt.Description          := safelink_rec.Description;
            getAvailableSp_rslt.Customer_Price       := safelink_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := safelink_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := safelink_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := safelink_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := safelink_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := safelink_rec.property_value;
--            getAvailableSp_rslt.prog_script_id       := '';
--            getAvailableSp_rslt.prog_script_desc     := '';
            getAvailableSp_rslt.ServicePlanType         := 'AIRTIME';
            getAvailableSp_rslt.spObjid              := safelink_rec.spObjid;
            if nvl(getAvailableSp_rslt.spObjid ,0) <> 0 then
               getAvailableSp_rslt.service_plan_group := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'SERVICE_PLAN_GROUP');
               getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
               getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
               getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');
            end if;

            pipe row (getAvailableSp_rslt);
        end loop;
   else
      --NOT (ip_org_id = 'NET10' and is_safelink = 'true')

    if NOT(ip_org_id = 'TRACFONE' and is_safelink = 'true') then
        --Check if there is any PayGo plan
        select count(*)
        into  v_paygo_plans
        from  sa.TABLE_PART_INST PI,
            sa.TABLE_MOD_LEVEL ML,
            sa.TABLE_PART_NUM PN,
            sa.adfcrm_serv_plan_class_matview spmv,
            sa.X_SERVICE_PLAN SP
        where  1 =1
        and   PI.PART_SERIAL_NO = ip_esn
        and   ML.OBJID = PI.N_PART_INST2PART_MOD
        and   pn.objid = ml.part_info2part_num
        and   spmv.part_class_objid = PN.PART_NUM2PART_CLASS
        and   SP.OBJID = spmv.sp_objid
        and   decode(ip_value,'REWARD_POINTS',sa.get_serv_plan_value(sp.objid,'REWARD_POINTS'),'NOT_SPECIFIED') is not null -- CR32367
        and   NVL(sa.adfcrm_get_serv_plan_value(SP.OBJID,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE'
        and NVL(SP.WEBCSR_DISPLAY_NAME, 'Not Paygo') = 'Paygo';
      end if;

      if v_paygo_plans > 0 then
            -- CR36435 -- To show Paygo Plans as single Item in drop down
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := -1;
            getAvailableSp_rslt.Mkt_Name             := 'Pay as You Go';
            getAvailableSp_rslt.sp_Description       := 'Pay as You Go' ;
            getAvailableSp_rslt.Description          := 'Pay as You Go' ;
            getAvailableSp_rslt.Customer_Price       := 0;
            getAvailableSp_rslt.Ivr_Plan_Id          := 0;
            getAvailableSp_rslt.Webcsr_Display_Name  := 'Pay as You Go';
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := null;
            getAvailableSp_rslt.X_Program_Name       := null;
            getAvailableSp_rslt.part_number          := null;
            getAvailableSp_rslt.spObjid              := null;
            pipe row (getAvailableSp_rslt);
      end if;
	  --CR55070
     if( ip_org_id = 'NET10' and sa.validate_red_card_pkg.is_addon_exclusion(ip_esn) = 'Y') then
     v_addonfilter :='true';
     end if;

      for rec in
        (
        select
            SP.OBJID OBJID, SP.MKT_NAME MKT_NAME, sp.description sp_description,
            sa.ADFCRM_SCRIPTS.GET_PLAN_DESCRIPTION(sp.objid,p_language,'ALL') DESCRIPTION,
            SP.CUSTOMER_PRICE CUSTOMER_PRICE, SP.IVR_PLAN_ID IVR_PLAN_ID, SP.WEBCSR_DISPLAY_NAME WEBCSR_DISPLAY_NAME
          , sp.X_SP2PROGRAM_PARAM X_SP2PROGRAM_PARAM, sp.X_PROGRAM_NAME X_PROGRAM_NAME
          , SP.OBJID spObjid
          , sp.VALUE_NAME
          , sp.property_value  property_value
          , sp.property_value  property_display
        from
            (select distinct
                    SP.OBJID, SP.MKT_NAME, SP.DESCRIPTION, SP.CUSTOMER_PRICE, SP.IVR_PLAN_ID, SP.WEBCSR_DISPLAY_NAME
                   ,NULL X_SP2PROGRAM_PARAM, NULL X_PROGRAM_NAME
                   ,'PLAN_PURCHASE_PART_NUMBER' VALUE_NAME
                   ,sa.adfcrm_get_serv_plan_value(SP.OBJID,'PLAN_PURCHASE_PART_NUMBER')  property_value
             from  sa.TABLE_PART_INST PI,
                   sa.TABLE_MOD_LEVEL ML,
                   sa.TABLE_PART_NUM PN,
                   sa.adfcrm_serv_plan_class_matview spmv,
                   sa.X_SERVICE_PLAN SP
             where  1 =1
             and   PI.PART_SERIAL_NO = ip_esn
             and   ML.OBJID = PI.N_PART_INST2PART_MOD
             and   pn.objid = ml.part_info2part_num
             and   spmv.part_class_objid = PN.PART_NUM2PART_CLASS
             and   SP.OBJID = spmv.sp_objid
             and   decode(ip_value,'REWARD_POINTS',sa.get_serv_plan_value(sp.objid,'REWARD_POINTS'),'NOT_SPECIFIED') is not null -- CR32367
             and   NVL(sa.adfcrm_get_serv_plan_value(SP.OBJID,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE'
             and NVL(SP.WEBCSR_DISPLAY_NAME, 'Not Paygo') <> 'Paygo' -- CR36435
             and ( (ip_org_id = 'TRACFONE' and nvl(sa.adfcrm_serv_plan.getServPlanGroupType(sp.objid),'PAY_GO') = 'UNLIMITED')  --CR42459 Show only UNLIMITED for TRACFONE
                   or
                   ip_org_id <> 'TRACFONE'
                 )
             ) SP
        )
      loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := rec.objid;
            getAvailableSp_rslt.Mkt_Name             := rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := rec.sp_Description;
            getAvailableSp_rslt.Description          := rec.Description;
            getAvailableSp_rslt.Customer_Price       := rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := rec.property_value;
--            getAvailableSp_rslt.prog_script_id       := '';
--            getAvailableSp_rslt.prog_script_desc     := '';
            getAvailableSp_rslt.spObjid              := rec.spObjid;
            if nvl(getAvailableSp_rslt.spObjid ,0) <> 0 then
               getAvailableSp_rslt.service_plan_group := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'SERVICE_PLAN_GROUP');
               getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
               getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
               getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');
            end if;

	if (ip_org_id = 'STRAIGHT_TALK' ) and (getAvailableSp_rslt.service_plan_group = 'ADD_ON_DATA'  or getAvailableSp_rslt.service_plan_group = 'ADD_ON_ILD') then
	DBMS_OUTPUT.PUT_LINE('Filtered the Add On Plan in Compensation/Replacement flow ' || getAvailableSp_rslt.objid);
	    --CR55070
        elsif v_addonfilter= 'true' and getAvailableSp_rslt.service_plan_group = 'ADD_ON_DATA' then
        DBMS_OUTPUT.PUT_LINE('Filtered the Add On Plan in Compensation/Replacement flow ' || getAvailableSp_rslt.objid);
        --CR55069
        elsif (ip_org_id = 'SIMPLE_MOBILE') and (getAvailableSp_rslt.service_plan_group = 'ADD_ON_ILD') then
        DBMS_OUTPUT.PUT_LINE('Filtered the Add On Plan in Compensation/Replacement flow ' || getAvailableSp_rslt.objid);
			else
				pipe row (getAvailableSp_rslt);
			end if;
      end loop;

   end if;
   --CR42459 SafeLink Unlimited Plans
     if ip_org_id = 'TRACFONE' and
        is_safelink = 'true'
     then
        for safelink_rec in
        (
        --To show Paygo Plans as single Item in drop down only when it was not already added (v_paygo_plans = 0)
        select
         -1 OBJID, 'Pay as You Go' MKT_NAME, 'Pay as You Go' sp_description,
          'Pay as You Go' DESCRIPTION,
          0 CUSTOMER_PRICE, 0 IVR_PLAN_ID, 'Pay as You Go' WEBCSR_DISPLAY_NAME
        , null X_SP2PROGRAM_PARAM, null X_PROGRAM_NAME
        , null spObjid
        , null VALUE_NAME
        , null  property_value
        , null  property_display
         ,'AIRTIME' ServicePlanType
         ,'PAY_GO' service_plan_group
         ,null part_number
         ,null x_card_type
         ,null units
        from dual
        where v_paygo_plans = 0
        and v_show_paygo = 'true'
        union
        --Safelink plans
        SELECT objid, mkt_name, sp_description, Description, Customer_Price, Ivr_Plan_Id,
               Webcsr_Display_Name, X_SP2PROGRAM_PARAM, X_Program_Name, objid spObjid
        , null VALUE_NAME
        , null  property_value
        , null  property_display
        ,ServicePlanType
        ,service_plan_group
        ,part_number
        ,x_card_type
        ,units
        FROM table(sa.ADFCRM_VO.getSafelinkSp(ip_esn,ip_org_id,ip_language))
        where ServicePlanType = 'AIRTIME'
        and service_plan_group <> 'PAY_GO'
        order by customer_price
        )
        loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := safelink_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := safelink_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := safelink_rec.sp_Description;
            getAvailableSp_rslt.Description          := safelink_rec.Description;
            getAvailableSp_rslt.Customer_Price       := safelink_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := safelink_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := safelink_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := safelink_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := safelink_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := safelink_rec.part_number;
--            getAvailableSp_rslt.prog_script_id       := safelink_rec.prog_script_id;
--            getAvailableSp_rslt.prog_script_desc     := safelink_rec.prog_script_desc;
            getAvailableSp_rslt.x_card_type          := safelink_rec.x_card_type;
            getAvailableSp_rslt.units                := safelink_rec.units;
            getAvailableSp_rslt.ServicePlanType         := safelink_rec.ServicePlanType;
            getAvailableSp_rslt.spObjid              := safelink_rec.spObjid;
            getAvailableSp_rslt.service_plan_group  := safelink_rec.service_plan_group;
            if safelink_rec.spobjid is not null then
               getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
               getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
               getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');
            end if;
            pipe row (getAvailableSp_rslt);
        end loop;
     end if;
     return;
  END getAvailableSpCompRepl;

--********************************************************************************************************************
  function getAvailableSpAWOP(
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getAvailableSp_tab pipelined
  is
      --*** This table function is called from uc217 ***
      --org_objid number;
      p_language varchar2(100);
      getAvailableSp_rslt getAvailableSp_rec;
      get_esn_info_rec  get_esn_info%rowtype;
	  n_lid number;
  BEGIN
      p_language := get_language(ip_language);
      --Avoiding duplicate values in service plan drop down by
      --Filtering the service plan for ENROLL_ALLOW that are already offered with the corresponding AVAILABLE service plan
      open get_esn_info(ip_esn);
      fetch get_esn_info into get_esn_info_rec;
      close get_esn_info;
      --org_objid := get_org_objid(ip_org_id);
      n_lid:= sa.adfcrm_safelink.GET_LID(ip_esn);
      --EME CR56582 - display NT SL (CA plans only) in AWOP flow
      if ip_org_id = 'NET10' and n_lid is not null
      then
        /******************   Safelink  **********************/
     --   null; commented for EME CR56582

        --EME CR56582 - display NT SL (CA plans only) in AWOP flow
         for safelink_rec in
        (
       SELECT   sp.objid,
                sp.mkt_name,
                sp.DESCRIPTION  AS spdescription,
				sp.DESCRIPTION  AS description,
                sp.customer_price  ,
                sp.ivr_plan_id,
                sp.webcsr_display_name,
                sppp.x_sp2program_param  ,
                pp.x_program_name,
                sp.objid spobjid,
                NULL AS value_name,
                spmv.plan_purchase_part_number AS property_value,
                spmv.plan_purchase_part_number AS property_display
       FROM     sa.x_sl_subs  slsub,
                sa.x_program_parameters pp,
                sa.mtm_sp_x_program_param  sppp,
                sa.x_service_plan          sp,
                sa.service_plan_feat_pivot_mv spmv
         WHERE  1 = 1
         AND    slsub.lid = n_lid
         AND    slsub.x_requested_plan = pp.x_program_name
         AND    pp.objid = sppp.x_sp2program_param
         AND    sppp.program_para2x_sp = sp.objid
         AND    spmv.service_plan_objid = sp.objid
         order by  sp.customer_price
        )
        loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := safelink_rec.objid;
            getAvailableSp_rslt.Mkt_Name             := safelink_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := safelink_rec.SPDescription;
            getAvailableSp_rslt.Description          := safelink_rec.Description;
            getAvailableSp_rslt.Customer_Price       := safelink_rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := safelink_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := safelink_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := safelink_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := safelink_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := safelink_rec.property_display;
--            getAvailableSp_rslt.prog_script_id       := safelink_rec.prog_script_id;
--            getAvailableSp_rslt.prog_script_desc     := safelink_rec.prog_script_desc;
    --        getAvailableSp_rslt.x_card_type          := safelink_rec.x_card_type;
     --       getAvailableSp_rslt.units                := safelink_rec.units;
     --       getAvailableSp_rslt.ServicePlanType         := safelink_rec.ServicePlanType;
            getAvailableSp_rslt.spObjid              := safelink_rec.spobjid;
          --  getAvailableSp_rslt.service_plan_group  := safelink_rec.service_plan_group;
            getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
            getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
            getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');

            pipe row (getAvailableSp_rslt);
        end loop;

      else
      for rec in
        (select
            SP.OBJID OBJID, SP.MKT_NAME MKT_NAME, sp.description sp_description,
            sa.ADFCRM_SCRIPTS.GET_PLAN_DESCRIPTION(sp.objid,p_language,'ALL') DESCRIPTION,
            SP.CUSTOMER_PRICE CUSTOMER_PRICE, SP.IVR_PLAN_ID IVR_PLAN_ID, SP.WEBCSR_DISPLAY_NAME WEBCSR_DISPLAY_NAME
          , sp.X_SP2PROGRAM_PARAM X_SP2PROGRAM_PARAM, sp.X_PROGRAM_NAME X_PROGRAM_NAME
          , SP.OBJID spobjid
          , sp.VALUE_NAME
          , sp.property_value  property_value
          , sp.property_value  property_display
        from
            (select distinct
                    SP.OBJID, SP.MKT_NAME, SP.DESCRIPTION, SP.CUSTOMER_PRICE, SP.IVR_PLAN_ID, SP.WEBCSR_DISPLAY_NAME
                   , null X_SP2PROGRAM_PARAM, null X_PROGRAM_NAME
                   ,'PLAN_PURCHASE_PART_NUMBER' VALUE_NAME
                   ,sa.adfcrm_get_serv_plan_value(SP.OBJID,'PLAN_PURCHASE_PART_NUMBER')  property_value
             from  (select spmv.sp_objid, spmv.part_class_objid, spmv.part_class_name
                    from sa.adfcrm_serv_plan_class_matview spmv
                    where  spmv.part_class_objid = get_esn_info_rec.part_class_objid
                    and nvl(sa.adfcrm_get_serv_plan_value(spmv.sp_objid,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE'
                    union
                    select spmv.sp_objid, spmv.part_class_objid, spmv.part_class_name
                    from sa.adfcrm_serv_plan_class_matview spmv,
                         (select to_number(sa.ADFCRM_GET_SERV_PLAN_VALUE(sp.sp_objid,'RECURRING_SERVICE_PLAN')) recurring_service_plan,
                                 sp.part_class_objid
                         from sa.adfcrm_serv_plan_class_matview sp
                         where  sp.part_class_objid = get_esn_info_rec.part_class_objid
                         and nvl(sa.adfcrm_get_serv_plan_value(sp.sp_objid,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'AVAILABLE') sp_available
                    where spmv.part_class_objid = get_esn_info_rec.part_class_objid
                    and nvl(sa.adfcrm_get_serv_plan_value(spmv.sp_objid,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') = 'ENROLL_ALLOW'
                    and sp_available.part_class_objid (+) = spmv.part_class_objid
                    and sp_available.recurring_service_plan (+) = spmv.sp_objid
                    and sp_available.recurring_service_plan is null
                    ) spmv,
                   X_SERVICE_PLAN SP
             where SP.OBJID = spmv.sp_objid
             ) SP
        )
      loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := rec.objid;
            getAvailableSp_rslt.Mkt_Name             := rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := rec.sp_Description;
            getAvailableSp_rslt.Description          := rec.Description;
            getAvailableSp_rslt.Customer_Price       := rec.Customer_Price;
            getAvailableSp_rslt.Ivr_Plan_Id          := rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := rec.property_value;
--            getAvailableSp_rslt.prog_script_id       := '';
--            getAvailableSp_rslt.prog_script_desc     := '';
            getAvailableSp_rslt.spObjid              := rec.spObjid;
            getAvailableSp_rslt.sp_biz_line          := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'BIZ LINE');
            getAvailableSp_rslt.sp_number_of_lines    := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid,'NUMBER_OF_LINES');
            getAvailableSp_rslt.sp_add_on_card_flag  := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'ADD_ON_CARD_FLAG');
			getAvailableSp_rslt.service_plan_group := sa.adfcrm_get_serv_plan_value(getAvailableSp_rslt.spObjid, 'SERVICE_PLAN_GROUP');
            -- CR48979  - filter Add-ons during Activation
			-- CR47852  -  filter Add-on-ild type during AWOP
			if getAvailableSp_rslt.service_plan_group = 'ADD_ON_DATA' or getAvailableSp_rslt.service_plan_group = 'ADD_ON_ILD' then
				DBMS_OUTPUT.PUT_LINE('Filtered the Add On Plan in Activation without Purchase ' || getAvailableSp_rslt.objid);
			else
				pipe row (getAvailableSp_rslt);
			end if;
      end loop;
      end if;
      return;
  END getAvailableSpAWOP;

--********************************************************************************************************************
  function getSafelinkSp (
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getAvailableSp_tab pipelined
  is
    v_safelink_rec sa.safelink_validations_pkg.populate_sp_dtl_record;

    op_actiontype varchar2(200);
    op_enroll_zip     varchar2(200);
    op_web_user_id    number;
    op_lid            number;
    op_esn            varchar2(200);
    op_contact_objid number;
    op_refcursor sys_refcursor;
    op_err_num number;
    op_err_string varchar2(200);
    getAvailableSp_rslt getAvailableSp_rec;
  BEGIN
      sa.safelink_validations_pkg.p_validate_min(
          ip_key => 'ESN',
          ip_value => ip_esn,
          ip_source_system => 'TAS',
          op_actiontype => op_actiontype,
          op_enroll_zip => op_enroll_zip,
          op_web_user_id => op_web_user_id,
          op_lid => op_lid,
          op_esn => op_esn,
          op_contact_objid => op_contact_objid,
          op_refcursor => op_refcursor,
          op_err_num => op_err_num,
          op_err_string => op_err_string
        );

DBMS_OUTPUT.PUT_LINE('OP_ACTIONTYPE = ' || OP_ACTIONTYPE);
DBMS_OUTPUT.PUT_LINE('OP_ERR_NUM = ' || OP_ERR_NUM);
DBMS_OUTPUT.PUT_LINE('OP_ERR_STRING = ' || OP_ERR_STRING);

      if OP_REFCURSOR%isopen then
         fetch OP_REFCURSOR into v_safelink_rec;
         while OP_REFCURSOR%found loop
            getAvailableSp_rslt := default_values_AvailableSp;
            getAvailableSp_rslt.objid                := v_safelink_rec.sp_objid;
            getAvailableSp_rslt.Mkt_Name             := v_safelink_rec.Mkt_Name;
            getAvailableSp_rslt.sp_Description       := v_safelink_rec.sp_Desc;
            if (v_safelink_rec.sp_objid is not null) then
               --getAvailableSp_rslt.Description          := SA.ADFCRM_SCRIPTS.GET_PLAN_DESCRIPTION(v_safelink_rec.sp_objid,ip_language,'ALL');
               begin
                    select objid, nvl(script_description,description)
                    into getAvailableSp_rslt.spObjid, getAvailableSp_rslt.Description
                    from sa.adfcrm_service_plan_scripts_mv spmv
                    where spmv.objid = v_safelink_rec.sp_objid
                    and spmv.x_language = upper(ip_language);
               exception
                    when others then null;
               end;
               if (getAvailableSp_rslt.Description is null) then
                   getAvailableSp_rslt.Description := v_safelink_rec.pn_desc;
               end if;
            else
               getAvailableSp_rslt.Description          := v_safelink_rec.pn_desc;
            end if;
            getAvailableSp_rslt.Customer_Price       := nvl(v_safelink_rec.Customer_Price,v_safelink_rec.x_retail_price);
            getAvailableSp_rslt.Ivr_Plan_Id          := v_safelink_rec.Ivr_Plan_Id;
            getAvailableSp_rslt.Webcsr_Display_Name  := v_safelink_rec.Webcsr_Display_Name;
            getAvailableSp_rslt.X_SP2PROGRAM_PARAM   := v_safelink_rec.X_SP2PROGRAM_PARAM;
            getAvailableSp_rslt.X_Program_Name       := v_safelink_rec.X_Program_Name;
            getAvailableSp_rslt.part_number          := v_safelink_rec.part_number;
            if (v_safelink_rec.part_number is not null) then
                begin
                    select pn.x_card_type, pn.x_redeem_units
                    into getAvailableSp_rslt.x_card_type, getAvailableSp_rslt.units
                    from sa.table_part_num pn
                    where pn.part_number = v_safelink_rec.part_number;
                exception when others then null;
                end;
            end if;
--            getAvailableSp_rslt.prog_script_id       := '';
--            getAvailableSp_rslt.prog_script_desc     := '';
            if (v_safelink_rec.sp_objid is not null) then
                getAvailableSp_rslt.ServicePlanType         := 'AIRTIME';
            else
                getAvailableSp_rslt.ServicePlanType         := 'OTHER';
            end if;
            getAvailableSp_rslt.quantity             := nvl(v_safelink_rec.quantity,0);
            getAvailableSp_rslt.service_plan_group := v_safelink_rec.service_plan_group;

            pipe row (getAvailableSp_rslt);
                --DBMS_OUTPUT.PUT_LINE('part_number = ' || v_safelink_rec.part_number);
                --DBMS_OUTPUT.PUT_LINE('sp_objid = ' || v_safelink_rec.sp_objid);
                --DBMS_OUTPUT.PUT_LINE('mkt_name = ' || v_safelink_rec.mkt_name);
            fetch OP_REFCURSOR into v_safelink_rec;
         end loop;
      end if;
  return;
  END getSafelinkSp;

--********************************************************************************************************************
function default_enrollment_details_rec
return get_enrollment_details_rec is
    get_enrollment_details_rslt get_enrollment_details_rec;
begin
    get_enrollment_details_rslt.objid                    := null;
    get_enrollment_details_rslt.x_program_name           := null;
    get_enrollment_details_rslt.pgm_enroll2x_pymt_src    := null;
    get_enrollment_details_rslt.x_program_desc           := null;
    get_enrollment_details_rslt.x_amount                 := null;
    get_enrollment_details_rslt.x_enrollment_status      := null;
    get_enrollment_details_rslt.x_enroll_amount          := null;
    get_enrollment_details_rslt.prog_class               := null;
    get_enrollment_details_rslt.pgm_enroll2pgm_parameter := null;
    get_enrollment_details_rslt.allowpaynow              := null;
    get_enrollment_details_rslt.allow_de_enroll          := null;
    get_enrollment_details_rslt.allow_re_enroll          := null;
    get_enrollment_details_rslt.reversible_flag          := null;
    get_enrollment_details_rslt.x_prg_script_text        := null;  --CR32952
    get_enrollment_details_rslt.x_prg_desc_script_text   := null;  --CR32952
    get_enrollment_details_rslt.make_recurrent_flag      := 'false';  --CR49058
    get_enrollment_details_rslt.stop_recurrent_flag := 'false';  --CR49058
    get_enrollment_details_rslt.vas_service_id := null; --CR49058
    get_enrollment_details_rslt.is_vas_flag  := 'false';  --CR49058
    get_enrollment_details_rslt.vas_subscription_id := null;  --CR49058
    get_enrollment_details_rslt.part_number := null;  --CR49058
    get_enrollment_details_rslt.is_recurring := null;  --CR49058
    get_enrollment_details_rslt.request_user_info_flag := 'false';  --CR49058
    return get_enrollment_details_rslt;
end;

  function get_enrollment_details (
    ip_esn in varchar2,
    ip_language in varchar2 -- EN ES
  )
  return get_enrollment_details_tab pipelined
  is
    --*** This table function is called from uc245 ***
    cursor esn_site_info (p_esn varchar2) is
        select
            pi.part_serial_no,
            pn.part_num2part_class,
            spsp.x_service_plan_id,
            bo.org_id,
            (select max(Mtm.X_Sp2program_Param) program_id
             from sa.mtm_sp_x_program_param mtm
             where mtm.program_para2x_sp = spsp.x_service_plan_id) program_id,
            pn.x_manufacturer,
            (select lpi.part_serial_no lpi_min
            from sa.table_part_inst lpi
            where lpi.part_to_esn2part_inst = pi.objid
            and lpi.x_domain = 'LINES') pi_min
        from
             sa.table_part_inst           pi
            ,sa.TABLE_MOD_LEVEL           ML
            ,sa.TABLE_PART_NUM            PN
            ,sa.x_service_plan_site_part spsp
            ,sa.table_bus_org             bo
        where pi.part_serial_no = p_esn
        and pi.x_domain = 'PHONES'
        and ml.objid = pi.n_part_inst2part_mod
        AND PN.OBJID = ML.PART_INFO2PART_NUM
        and spsp.table_site_part_id (+) = pi.x_part_inst2site_part
        and bo.objid = pn.part_num2bus_org
		order by spsp.x_last_modified_date desc;

    esn_site_info_rec esn_site_info%rowtype;
    p_language varchar2(100);
    get_enrollment_details_rslt get_enrollment_details_rec;
    p_master_esn varchar2(30);
    v_script_id varchar2(100);
	prgm_plans  number := 0;
	exception_flag varchar2(10) := 'false';
  begin
    p_language := get_language(ip_language);
    p_master_esn := sa.adfcrm_group_trans_pkg.get_master_esn(ip_search_type =>'ESN', ip_search_value =>ip_esn);

    if p_master_esn is null then
      p_master_esn := ip_esn;
    end if;

    open esn_site_info(ip_esn);
    fetch esn_site_info into esn_site_info_rec;
    close esn_site_info;

	if esn_site_info_rec.org_id = 'TOTAL_WIRELESS'
	then
	    select count(mtm.program_para2x_sp) plans
		into  prgm_plans
		from sa.mtm_sp_x_program_param mtm,
		     sa.Adfcrm_Serv_Plan_Class_Matview spclass
		where Spclass.Part_Class_Objid = esn_site_info_rec.part_num2part_class
		and  mtm.X_Sp2program_Param = esn_site_info_rec.program_id
		and  mtm.program_para2x_sp = Spclass.Sp_Objid
		group by Mtm.X_Sp2program_Param
        ;
		if prgm_plans > 2 then
		   exception_flag := 'true';
		end if;
	end if;

    get_enrollment_details_rslt := default_enrollment_details_rec();

      for rec in  (select distinct x.objid,
                           p.x_program_name,
                           x.pgm_enroll2x_pymt_src,
                           --nvl(sa.adfcrm_scripts.get_plan_description(x_service_plan.objid,decode(upper('en'),'ES','SPANISH','ENGLISH'),'ALL'),p.x_program_desc) x_program_desc,
                           (select nvl(script_description,description)
                            from sa.adfcrm_service_plan_scripts_mv spmv
                            where spmv.objid = x_service_plan.objid
                            and spmv.x_language = upper(ip_language)
                           ) x_program_desc,
                           x.x_amount,
                           x.x_enrollment_status,
                           x.x_enroll_amount,
                           nvl(p.x_prog_class, 'DEFAULT') prog_class,
                           x.pgm_enroll2pgm_parameter,
                           case
                             when p.x_prog_class = 'WARRANTY' and sa.billing_is_paynow_enabled(x.objid) in (2,4,1)
                           then 'TRUE'
                           else
                             case
                               when bo.org_id in ('TRACFONE','NET10')
                                  then
                                     case
                                       when  sa.billing_is_paynow_enabled(x.objid) in (2,4)
                                         then  'TRUE'
                                       when  sa.billing_is_paynow_enabled(x.objid) = 1 and
                                         bo.org_id in 'TRACFONE'
                                         then  'TRUE'
                                       when  sa.billing_is_paynow_enabled(x.objid) = 1 and
                                         bo.org_id in 'NET10' and
                                         sa.get_serv_plan_value(x_service_plan.objid,'BENEFIT_TYPE') = 'STACK'
                                         then  'TRUE'
                                       else 'FALSE'
                                      end
                                 else 'FALSE'
                                end
                              end  allowpaynow
                        ,bo.org_id --CR32952
                        ,ppmv.x_prg_script_text --CR44010
                        ,ppmv.x_prg_desc_script_text --CR44010
--                        ,substr(p.x_prg_script_id,1,instr(p.x_prg_script_id,'_')-1) prg_script_type,   --CR32952
--                         substr(p.x_prg_script_id,instr(p.x_prg_script_id,'_')+1) prg_script_id,   --CR32952
--                         substr(p.x_prg_desc_script_id,1,instr(p.x_prg_desc_script_id,'_')-1) prg_desc_script_type,   --CR32952
--                         substr(p.x_prg_desc_script_id,instr(p.x_prg_desc_script_id,'_')+1) prg_desc_script_id   --CR32952
                        ,x_service_plan.objid sp_objid
                        ,p.x_is_recurring
                        ,p.x_charge_frq_code
            from x_program_parameters p,
                 (select prg_objid, x_prg_script_text, x_prg_desc_script_text
                 from sa.adfcrm_prg_enrolled_script_mv
                 where x_language = upper(ip_language)) ppmv,
                 x_program_enrolled x,
                 table_bus_org bo,
                (select mtm.x_sp2program_param,
                        spmv.sp_objid objid
                       ,spmv.part_class_name --CR32952
                 from   sa.table_part_inst pi,
                        sa.table_mod_level ml,
                        sa.table_part_num pn,
                        sa.adfcrm_serv_plan_class_matview spmv,
                        sa.mtm_sp_x_program_param mtm
                 where  pi.part_serial_no = p_master_esn
                 and    pi.x_domain ='PHONES'
                 and    ml.objid = pi.n_part_inst2part_mod
                 and    pn.objid = ml.part_info2part_num
                 and    spmv.part_class_objid = pn.part_num2part_class
                 and    mtm.program_para2x_sp = spmv.sp_objid
                 and    nvl(sa.adfcrm_get_serv_plan_value(spmv.sp_objid,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') in ('AVAILABLE','ENROLL_ALLOW')
                 and    sa.adfcrm_get_serv_plan_value(spmv.sp_objid,'RECURRING_SERVICE_PLAN') is null
                 --CR48200 Exception for program scripts    Refer Defect 22293
                 and    (exception_flag = 'false' or (exception_flag = 'true' and mtm.program_para2x_sp = esn_site_info_rec.x_service_plan_id))
                 ) x_service_plan
            where x.pgm_enroll2pgm_parameter = p.objid
            and (x.x_esn = p_master_esn and nvl(p.x_prog_class,'empty') <> 'LOWBALANCE' or --CR35665 - $10 Total Wireless Auto Refill
                 x.x_esn = ip_esn and nvl(p.x_prog_class,'empty') = 'LOWBALANCE')          --CR35665 - $10 Total Wireless Auto Refill
            and ((x.x_enrollment_status = 'ENROLLED' ) or (x.x_enrollment_status not in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')))
            and p.objid = x_service_plan.x_sp2program_param (+)
            and bo.objid = p.prog_param2bus_org
            and ppmv.prg_objid = p.objid
            )
      loop
        get_enrollment_details_rslt := default_enrollment_details_rec();
        get_enrollment_details_rslt.objid                    := rec.objid;
        get_enrollment_details_rslt.x_program_name           := rec.x_program_name;
        get_enrollment_details_rslt.pgm_enroll2x_pymt_src    := rec.pgm_enroll2x_pymt_src;
        get_enrollment_details_rslt.x_program_desc           := rec.x_program_desc;
        get_enrollment_details_rslt.x_amount                 := rec.x_amount;
        get_enrollment_details_rslt.x_enrollment_status      := rec.x_enrollment_status;
        get_enrollment_details_rslt.x_enroll_amount          := rec.x_enroll_amount;
        get_enrollment_details_rslt.prog_class               := rec.prog_class;
        get_enrollment_details_rslt.pgm_enroll2pgm_parameter := rec.pgm_enroll2pgm_parameter;
        get_enrollment_details_rslt.allowpaynow              := rec.allowpaynow;
        get_enrollment_details_rslt.is_recurring := rec.x_is_recurring;
            --CR32952 begin
            get_enrollment_details_rslt.x_prg_script_text      := rec.x_prg_script_text;
            get_enrollment_details_rslt.x_prg_desc_script_text := rec.x_prg_desc_script_text;
            --CR32952 end
            --CR48200 Begin Exceptions for program scripts
            if exception_flag = 'true' and nvl(rec.sp_objid,esn_site_info_rec.x_service_plan_id) is not null then
                v_script_id := sa.adfcrm_get_serv_plan_value(nvl(rec.sp_objid,esn_site_info_rec.x_service_plan_id), 'PROGRAM_NAME_SCRIPT');
                if v_script_id is not null then
                    get_enrollment_details_rslt.x_prg_script_text      := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => substr(v_script_id,1,instr(v_script_id,'_')-1),
                                                                       ip_script_id => substr(v_script_id,instr(v_script_id,'_')+1),
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'ALL',
                                                                       ip_brand_name => rec.org_id);
                end if;
                v_script_id := sa.adfcrm_get_serv_plan_value(nvl(rec.sp_objid,esn_site_info_rec.x_service_plan_id), 'PROGRAM_DESC_SCRIPT');
                if v_script_id is not null then
                    get_enrollment_details_rslt.x_prg_desc_script_text := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type =>  substr(v_script_id,1,instr(v_script_id,'_')-1),
                                                                       ip_script_id => substr(v_script_id,instr(v_script_id,'_')+1),
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'ALL',
                                                                       ip_brand_name => rec.org_id);
                end if;
            end if;
            --CR48200 End

        --CR49058  Check for VAS programs
        if esn_site_info_rec.org_id = 'TRACFONE' then
            for vasrec in (select *
                          FROM TABLE(sa.ADFCRM_VAS.get_eligible_vas_services(
                                I_ESN => ip_esn,
                                I_MIN => esn_site_info_rec.pi_min,
                                I_BUS_ORG => esn_site_info_rec.org_id,
                                I_ECOMMERCE_ORDERID => NULL,
                                I_PHONE_MAKE => NULL,
                                I_PHONE_MODEL => NULL,
                                I_PHONE_PRICE => NULL,
                                i_activation_zipcode => NULL,
                                i_is_byod => decode(esn_site_info_rec.x_manufacturer,'BYOP','Y','N'),
                                I_ENROLLED_ONLY => 'Y',
                                i_to_esn => null,
                                I_PROCESS_FLOW => NULL
                                )) vas_enroll
                           where vas_enroll.prog_id = rec.pgm_enroll2pgm_parameter
                          )
            loop
                get_enrollment_details_rslt.vas_service_id := vasrec.vas_service_id;
                get_enrollment_details_rslt.is_vas_flag := 'true';
                get_enrollment_details_rslt.vas_subscription_id := vasrec.vas_subscription_id;
                get_enrollment_details_rslt.part_number := vasrec.part_number;
                if vasrec.auto_pay_enrolled = 'N' --rec.x_is_recurring = '0'
                then
                    if vasrec.auto_pay_available = 'Y' and rec.x_enrollment_status != 'SUSPENDED'
                    then
                        get_enrollment_details_rslt.make_recurrent_flag := 'true';
                    end if;
                    get_enrollment_details_rslt.stop_recurrent_flag := 'false';
                else
                    get_enrollment_details_rslt.make_recurrent_flag := 'false';
                    --if vasrec.auto_pay_available= 'Y'  --rec.x_charge_frq_code in ('MONTHLY','30')
                    --then
                        get_enrollment_details_rslt.stop_recurrent_flag := 'true';
                    --end if;
                end if;
                if vasrec.status = 'SUSPENDED' and vasrec.is_due_flag = 'Y' then
                    get_enrollment_details_rslt.allowpaynow := 'true';
                else
                    get_enrollment_details_rslt.allowpaynow := 'false';
                end if;
                if vasrec.refund_applicable_flag = 'Y' then
                    get_enrollment_details_rslt.request_user_info_flag := 'true';
                end if;
            end loop;
        end if;
        pipe row (get_enrollment_details_rslt);
      end loop;
      return;
  end get_enrollment_details;

--********************************************************************************************************************
  function get_sl_enrollment_details (
    ip_esn in varchar2,
    ip_lid in varchar2,
    ip_language in varchar2 -- EN ES
  )
  return get_enrollment_details_tab pipelined
  is
    --*** This table function is called from uc245 ***
    p_language varchar2(100);
    get_enrollment_details_rslt get_enrollment_details_rec;
    p_master_esn varchar2(30);
    sl_refcursor   SYS_REFCURSOR;
    p_prg_script_type varchar2(100);
    p_prg_script_id varchar2(100);
    p_prg_desc_script_type varchar2(100);
    p_prg_desc_script_id varchar2(100);
    p_org_id varchar2(100);
  begin
    --p_master_esn := sa.adfcrm_group_trans_pkg.get_master_esn(ip_search_type =>'ESN', ip_search_value =>ip_esn);
    p_language := get_language(ip_language);
    if p_master_esn is null then
      p_master_esn := ip_esn;
    end if;
    get_enrollment_details_rslt := default_enrollment_details_rec();

      for rec in  (select x.objid, p.x_program_name, x.pgm_enroll2x_pymt_src, x_amount, x_enroll_amount
                    ,p.x_program_desc, x.x_enrollment_status
                    ,nvl(p.x_prog_class, 'DEFAULT') prog_class, x.pgm_enroll2pgm_parameter
                    ,case
                     when x.x_enrollment_status = 'ENROLLED'
                     then 'true'
                     else 'false'
                     end de_enroll
                    ,case
                     when x.x_esn = cv.x_current_esn and
                          x.x_enrollment_status in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL') and
                          ((select count(*)
                            from sa.x_sl_deenroll_flag df
                            where cv.x_deenroll_reason like (case
                                         when regexp_like(df.x_deenroll_flag,'^[0-9]*$')  --if number
                                         then (trim(df.x_bill_flag)||trim(to_char(trim(df.x_deenroll_flag),'00')))||'%'
                                         else (trim(df.x_bill_flag)||trim(df.x_deenroll_flag))||'%'
                                         end)
                            and nvl(df.reversible,'Y') = 'Y'
                          ) > 0)
                     then 'true'
                     else 'false'
                     end re_enroll
                    ,ip_lid  lid
                    ,case
                     when x.x_enrollment_status = 'ENROLLED'
                     then 'true'
                     when x.x_esn = cv.x_current_esn and
                          (select count(*)
                            from sa.x_sl_deenroll_flag df
                            where cv.x_deenroll_reason like (case
                                         when regexp_like(df.x_deenroll_flag,'^[0-9]*$')  --if number
                                         then (trim(df.x_bill_flag)||trim(to_char(trim(df.x_deenroll_flag),'00')))||'%'
                                         else (trim(df.x_bill_flag)||trim(df.x_deenroll_flag))||'%'
                                         end)
                            and nvl(df.reversible,'Y') = 'Y'
                            ) > 0
                     then 'true'
                     else 'false'
                     end  reversible_flag,
                     'FALSE' allowpaynow
                     ,(select bo.org_id from table_bus_org bo where bo.objid = p.prog_param2bus_org) org_id --CR32952
--                        ,substr(p.x_prg_script_id,1,instr(p.x_prg_script_id,'_')-1) prg_script_type,   --CR32952
--                         substr(p.x_prg_script_id,instr(p.x_prg_script_id,'_')+1) prg_script_id,   --CR32952
--                         substr(p.x_prg_desc_script_id,1,instr(p.x_prg_desc_script_id,'_')-1) prg_desc_script_type,   --CR32952
--                         substr(p.x_prg_desc_script_id,instr(p.x_prg_desc_script_id,'_')+1) prg_desc_script_id   --CR32952
                       ,ppmv.x_prg_script_text --CR44010
                       ,ppmv.x_prg_desc_script_text --CR44010
                    from x_program_enrolled x
                        ,x_program_parameters p
                        ,sa.x_sl_currentvals cv
                        ,(select prg_objid, x_prg_script_text, x_prg_desc_script_text
                       from sa.adfcrm_prg_enrolled_script_mv
                       where x_language = upper(ip_language)) ppmv
                    where x.x_esn = ip_esn
                    and x.pgm_enroll2pgm_parameter = p.objid
                    and x.x_sourcesystem = 'VMBC'
                    and cv.lid = ip_lid
                    and x.x_enrollment_status||'' = 'ENROLLED'
                    and   ppmv.prg_objid = p.objid
                    order by x.objid desc
      )
      loop
        get_enrollment_details_rslt.objid                    := rec.objid;
        get_enrollment_details_rslt.x_program_name           := rec.x_program_name;
        get_enrollment_details_rslt.pgm_enroll2x_pymt_src    := rec.pgm_enroll2x_pymt_src;
        get_enrollment_details_rslt.x_program_desc           := rec.x_program_desc;
        get_enrollment_details_rslt.x_amount                 := rec.x_amount;
        get_enrollment_details_rslt.x_enrollment_status      := rec.x_enrollment_status;
        get_enrollment_details_rslt.x_enroll_amount          := rec.x_enroll_amount;
        get_enrollment_details_rslt.prog_class               := rec.prog_class;
        get_enrollment_details_rslt.pgm_enroll2pgm_parameter := rec.pgm_enroll2pgm_parameter;
        get_enrollment_details_rslt.allowpaynow              := null;
        get_enrollment_details_rslt.allow_de_enroll          := rec.de_enroll;
        get_enrollment_details_rslt.allow_re_enroll          := rec.re_enroll;
        get_enrollment_details_rslt.reversible_flag          := rec.reversible_flag;
            --CR32952 begin
            get_enrollment_details_rslt.x_prg_script_text      := rec.x_prg_script_text;
--            sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => rec.prg_script_type,
--                                                                       ip_script_id => rec.prg_script_id,
--                                                                       ip_language => p_language,
--                                                                       ip_sourcesystem  => 'TAS',
--                                                                       ip_brand_name => rec.org_id);
            get_enrollment_details_rslt.x_prg_desc_script_text := rec.x_prg_desc_script_text;
--            sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => rec.prg_desc_script_type,
--                                                                       ip_script_id => rec.prg_desc_script_id,
--                                                                       ip_language => p_language,
--                                                                       ip_sourcesystem  => 'TAS',
--                                                                       ip_brand_name => rec.org_id);
            --CR32952 end

        pipe row (get_enrollment_details_rslt);
      end loop;
      -- If no ENROLLED records then display the most recent DEENROLLED record.
      if get_enrollment_details_rslt.objid is null then
         open sl_refcursor for
             select x.objid, p.x_program_name, x.pgm_enroll2x_pymt_src, x_amount, x_enroll_amount
                    ,p.x_program_desc, x.x_enrollment_status
                    ,nvl(p.x_prog_class, 'DEFAULT') prog_class, x.pgm_enroll2pgm_parameter
                    ,case
                     when x.x_enrollment_status = 'ENROLLED'
                     then 'true'
                     else 'false'
                     end de_enroll
                    ,case
                     when x.x_esn = cv.x_current_esn and
                          x.x_enrollment_status in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL') and
                          ((select count(*)
                            from sa.x_sl_deenroll_flag df
                            where cv.x_deenroll_reason like (case
                                         when regexp_like(df.x_deenroll_flag,'^[0-9]*$')  --if number
                                         then (trim(df.x_bill_flag)||trim(to_char(trim(df.x_deenroll_flag),'00')))||'%'
                                         else (trim(df.x_bill_flag)||trim(df.x_deenroll_flag))||'%'
                                         end)
                            and nvl(df.reversible,'Y') = 'Y'
                          ) > 0)
                     then 'true'
                     else 'false'
                     end re_enroll
                    ,case
                     when x.x_enrollment_status = 'ENROLLED'
                     then 'true'
                     when x.x_esn = cv.x_current_esn and
                          (select count(*)
                            from sa.x_sl_deenroll_flag df
                            where cv.x_deenroll_reason like (case
                                         when regexp_like(df.x_deenroll_flag,'^[0-9]*$')  --if number
                                         then (trim(df.x_bill_flag)||trim(to_char(trim(df.x_deenroll_flag),'00')))||'%'
                                         else (trim(df.x_bill_flag)||trim(df.x_deenroll_flag))||'%'
                                         end)
                            and nvl(df.reversible,'Y') = 'Y'
                            ) > 0
                     then 'true'
                     else 'false'
                     end  reversible_flag,
                     'FALSE' allowpaynow
                     ,(select bo.org_id from table_bus_org bo where bo.objid = p.prog_param2bus_org) org_id --CR32952
--                        ,substr(p.x_prg_script_id,1,instr(p.x_prg_script_id,'_')-1) prg_script_type,   --CR32952
--                         substr(p.x_prg_script_id,instr(p.x_prg_script_id,'_')+1) prg_script_id,   --CR32952
--                         substr(p.x_prg_desc_script_id,1,instr(p.x_prg_desc_script_id,'_')-1) prg_desc_script_type,   --CR32952
--                         substr(p.x_prg_desc_script_id,instr(p.x_prg_desc_script_id,'_')+1) prg_desc_script_id   --CR32952
                       ,ppmv.x_prg_script_text --CR44010
                       ,ppmv.x_prg_desc_script_text --CR44010
                    from x_program_enrolled x
                        ,x_program_parameters p
                        ,sa.x_sl_currentvals cv
                        ,(select prg_objid, x_prg_script_text, x_prg_desc_script_text
                       from sa.adfcrm_prg_enrolled_script_mv
                       where x_language = upper(ip_language)) ppmv
                    where x.x_esn = ip_esn
                    and x.pgm_enroll2pgm_parameter = p.objid
                    and x.x_sourcesystem = 'VMBC'
                    and cv.lid = ip_lid
                    and x.x_enrollment_status||'' in ('DEENROLLED','READYTOREENROLL')
                    and ppmv.prg_objid = p.objid
                    order by x.objid desc
            ;
          fetch sl_refcursor into
            get_enrollment_details_rslt.objid,
            get_enrollment_details_rslt.x_program_name,
            get_enrollment_details_rslt.pgm_enroll2x_pymt_src,
            get_enrollment_details_rslt.x_amount,
            get_enrollment_details_rslt.x_enroll_amount,
            get_enrollment_details_rslt.x_program_desc,
            get_enrollment_details_rslt.x_enrollment_status,
            get_enrollment_details_rslt.prog_class,
            get_enrollment_details_rslt.pgm_enroll2pgm_parameter,
            get_enrollment_details_rslt.allow_de_enroll,
            get_enrollment_details_rslt.allow_re_enroll,
            get_enrollment_details_rslt.reversible_flag,
            get_enrollment_details_rslt.allowpaynow
            ,p_org_id--CR32952
            ,get_enrollment_details_rslt.x_prg_script_text --CR44010
            ,get_enrollment_details_rslt.x_prg_desc_script_text --CR44010
--            ,p_prg_script_type--CR32952
--            ,p_prg_script_id--CR32952
--            ,p_prg_desc_script_type--CR32952
--            ,p_prg_desc_script_id--CR32952
            ;
            --CR32952 begin
--            get_enrollment_details_rslt.x_prg_script_text      := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => p_prg_script_type,
--                                                                       ip_script_id => p_prg_script_id,
--                                                                       ip_language => p_language,
--                                                                       ip_sourcesystem  => 'TAS',
--                                                                       ip_brand_name => p_org_id);
--            get_enrollment_details_rslt.x_prg_desc_script_text := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => p_prg_desc_script_type,
--                                                                       ip_script_id => p_prg_desc_script_id,
--                                                                       ip_language => p_language,
--                                                                       ip_sourcesystem  => 'TAS',
--                                                                       ip_brand_name => p_org_id);
            --CR32952 end

            pipe row (get_enrollment_details_rslt);
          close sl_refcursor;
      end if;
      return;
  end get_sl_enrollment_details;

    -- NEW PENDING REDEMPTION FUNCTION
    function has_pending_redemption (ip_esn varchar2)
    return varchar2
    as
      ret_val varchar2(5) := 'false';
      cnt number;
    begin
      -- QUERY UNDER WORKS COMMENTED OUT ORIGINAL
      select --x_service_id ,
             count(1)
      into   cnt
      from   table_x_pending_redemption pendunits,
             table_site_part sp
      where  pendunits.x_pend_red2site_part = sp.objid
      and    sp.x_service_id in (ip_esn)
      and    part_status||'' = 'Active';
     -- group by x_service_id;

      if cnt > 0 then
        ret_val := 'true';
      end if;

      return ret_val;

    exception
      when others then
        return ret_val;
    end has_pending_redemption;

--********************************************************************************************************************
  function get_service_profile(ip_part_serial_no in varchar2, ip_language in varchar2)
  return get_service_profile_tab pipelined
  is
    --*** This table function is called from uc245 ***
    v_missing_master varchar2(15) := 'MASTER MISSING';
    v_err_num number;
    p_language varchar2(100);
    get_service_profile_rslt get_service_profile_rec;
    ----------------------------------------------------------------------------
    v_part_serial_no              sa.table_part_inst.part_serial_no%type :=  ip_part_serial_no;
    v_x_hex_serial_no             sa.table_part_inst.x_hex_serial_no%type;
    v_x_sequence                  sa.table_part_inst.x_sequence%type;
    v_x_iccid                     sa.table_part_inst.x_iccid%type;
    v_warr_end_date               sa.table_part_inst.warr_end_date%type;
    v_x_part_inst_status          sa.table_part_inst.x_part_inst_status%type;
    v_esn_objid                   sa.table_part_inst.objid%type;
    v_warranty_exchanges          sa.table_part_inst.part_bad_qty%type;
    v_x_domain                    sa.table_part_inst.x_domain%type;
    v_n_part_inst2part_mod        sa.table_part_inst.n_part_inst2part_mod%type;
    v_part_inst2inv_bin           sa.table_part_inst.part_inst2inv_bin%type;
    v_x_part_inst2site_part       sa.table_part_inst.x_part_inst2site_part%type;
    v_x_part_inst2contact         sa.table_part_inst.x_part_inst2contact%type;
    v_objid                       sa.table_part_inst.objid%type;
    v_x_contact_part_inst2contact sa.table_x_contact_part_inst.x_contact_part_inst2contact%type;
    v_x_dll                       sa.table_part_num.x_dll%type;
    v_part_number                 sa.table_part_num.part_number%type;
    v_pn_description              sa.table_part_num.description%type;
    v_part_info2part_num          sa.table_mod_level.part_info2part_num%type;
    v_part_num2bus_org            sa.table_part_num.part_num2bus_org%type;
    v_part_num2part_class         sa.table_part_num.part_num2part_class%type;
    v_brand                       sa.table_bus_org.org_id%type;
    v_class_name                  sa.table_part_class.name%type;
    v_phone_status                sa.table_x_code_table.x_code_name%type;
    v_inv_bin2inv_locatn          sa.table_inv_bin.inv_bin2inv_locatn%type;
    v_inv_locatn2site             sa.table_inv_locatn.inv_locatn2site%type;
    v_dealer_id                   sa.table_site.site_id%type;
    v_dealer_name                 sa.table_site.name%type;
    v_site_part_objid             sa.table_site_part.objid%type;
    v_service_end_dt              sa.table_site_part.service_end_dt%type;
    v_part_status                 sa.table_site_part.part_status%type;
    v_x_min                       sa.table_site_part.x_min%type;
    v_x_zipcode                   sa.table_site_part.x_zipcode%type;
    v_x_msid                      sa.table_site_part.x_msid%type;
    v_install_date                sa.table_site_part.install_date%type;
    v_x_refurb_flag               sa.table_site_part.x_refurb_flag%type;
    v_service_exp_date            sa.table_site_part.cmmtmnt_end_dt%type;
    v_contact_objid               sa.table_contact.objid%type;
    v_customer_id                 sa.table_contact.x_cust_id%type;
    v_first_name                  sa.table_contact.first_name%type;
    v_last_name                   sa.table_contact.last_name%type;
    v_phone                       sa.table_contact.phone%type;
    v_e_mail                      sa.table_contact.e_mail%type;
    v_reserved_min                sa.table_part_inst.part_serial_no%type;
    v_carrier                     varchar2(300);
    v_carrier_id                  number;
    v_carrier_objid               number;
    vm_part_inst2carrier_mkt      sa.table_part_inst.part_inst2carrier_mkt%type;
    vm_x_part_inst_status         sa.table_part_inst.x_part_inst_status%type;
    v_min_status                  sa.table_x_code_table.x_code_name%type;
    v_sim_status                  sa.table_x_code_table.x_code_name%type;
    v_is_smartphone               varchar2(10) := 'false';
    v_is_ota_pending              varchar2(10) := 'false';
    v_projected_end_date          date;
    v_get_expire_date             date;
    v_ext_warranty                sa.x_program_parameters.x_program_name%type := 'Duplicate Error Found'; -- varchar2(40);
    v_basic_warranty              varchar2(100);
    v_policy_description          w3ci.table_x_throttling_policy.x_policy_description%type; -- varchar2(40);
    v_cards_in_queue              number;
    v_hide_balance                varchar2(10) := 'false';
    v_hide_sim                    varchar2(10);
    v_hide_min                    varchar2(10);
    v_device_type                 varchar2(30);
    v_groupid                     x_account_group_member.account_group_id%type; -- number
    v_group_nick_name             x_account_group.account_group_name%type; -- VARCHAR2(50)
    v_group_status                x_account_group.status%type; -- VARCHAR2(30)
    v_group_total_devices         number;
    v_service_plan_objid          varchar2(100); -- x_service_plan.objid is the source however wrapper method outputs as varchar2

    v_sp_carry_over               varchar2(100); -- CR50209
    v_sp_script_id                varchar2(30);  -- CR50209
    v_sp_script_text              varchar2(4000); -- CR50209
    v_sp_addl_script_text         varchar2(4000); -- CR50209
    v_sp_cos_value                varchar2(30); -- CR50209
    v_sp_threshold_value          varchar2(30); -- CR50209
    v_subscriber_cos_value        varchar2(30); -- CR50209
    v_subscriber_threshold_value  varchar2(30); -- CR50209

    v_service_type                varchar2(100); -- x_service_plan.webcsr_display_name varchar2(50) is the source however wrapper method outputs as varchar2
    v_program_type                varchar2(100); -- x_program_parameters.x_program_name varchar2(40) is the source however wrapper method outputs as varchar2
    v_next_charge_date            date;          --varchar2(100), -- original was varchar, changed to date - x_program_enrolled.x_next_charge_date date
    v_program_units               number;        --varchar2(100), -- original was varchar, changed to number - validate this value remove when complete
    v_program_days                number;        --varchar2(100), -- original was varchar, changed to number - validate this value remove when complete
    v_rate_plan                   varchar2(100);  -- table_x_carrier_features.x_rate_plan%type varchar2(60)
    v_prg_script_id               varchar2(30);  -- x_program_parameters.x_prg_script_id
    v_prg_desc_script_id          varchar2(30);  -- x_program_parameters.x_prg_desc_script_id
    v_error_num                   number;
    v_master_part_serial_no       sa.table_part_inst.part_serial_no%type;
    v_technology                  sa.table_part_num.x_technology%type;
    v_esn_type                    varchar2(30);
    v_web_user_login_name     table_web_user.login_name%type;                     --GET ACCOUNT INFO VARIABLES
    v_web_user_objid          table_web_user.objid%type;                          --GET ACCOUNT INFO VARIABLES
    v_acc_cust_id             table_contact.x_cust_id%type;                       --GET ACCOUNT INFO VARIABLES
    v_acc_contact_objid       table_contact.objid%type;                           --GET ACCOUNT INFO VARIABLES
    v_x_pin                   table_x_contact_add_info.x_pin%type;                --GET ACCOUNT INFO VARIABLES
    v_x_dateofbirth           table_contact.x_dateofbirth%type;                   --GET ACCOUNT INFO VARIABLES
    v_x_secret_questn         table_web_user.x_secret_questn%type;                --GET ACCOUNT INFO VARIABLES
    v_x_secret_ans            table_web_user.x_secret_ans%type;                   --GET ACCOUNT INFO VARIABLES
   -- v_contact_objid           table_contact.objid%type; -- already declared
    v_bus_org_objid           table_web_user.web_user2bus_org%type;               --GET ACCOUNT INFO VARIABLES
    v_lid                     number; -- NEW SAFELINK
    v_sl_enrollment_status    varchar2(4000); -- NEW SAFELINK
    v_sl_next_delivery_date   varchar2(4000); -- NEW SAFELINK
    v_phone_gen                 varchar2(30); -- Added by kvara to get Phone Gen - Part Class Parameter.
    v_action_item_status			varchar2(100);  -- CR53530
    v_ig_action_item_status			varchar2(10);  -- CR53530
    -- NEW ESN_TYPE FUNCTION
    function get_esn_type(ip_part_class varchar2)
    return varchar2
    is
      v_dt varchar2(30);
      v_mt varchar2(30);
      v_mf varchar2(30);
      v_bm varchar2(30);
      v_os varchar2(30);
      v_final varchar2(30);
    begin

      select device_type,model_type,manufacturer,balance_metering,operating_system
      into v_dt,v_mt,v_mf,v_bm,v_os
      from sa.pcpv
      where part_class = ip_part_class;

      if v_dt = 'WIRELESS_HOME_PHONE' then
        v_final := 'HOME PHONE';
      elsif v_dt = 'MOBILE_BROADBAND' then
        v_final := 'HOTSPOT';
      elsif v_mt = 'HOME ALERT' then
        v_final := v_mt;
      elsif v_mf = 'BYOT' then
        v_final := v_mf;
      elsif v_dt = 'BYOP' then
        v_final := v_dt;
      elsif v_bm = 'SUREPAY' then
        v_final := v_bm;
      elsif v_mt = 'CAR CONNECT' then
        v_final := v_mt;
      elsif v_os = 'IOS' then
        v_final := 'IPHONE';
      else
        v_final := v_dt;
      end if;

      return v_final;
    exception
      when others then
        return null;
    end get_esn_type;



    -- NEW HIDE SIM FUNCTION
    function hide_sim(ip_technology varchar2, ip_part_serial_no varchar2, ip_esn_type varchar2)
    return varchar2
    is
      v_hide_sim varchar2(30);
    begin
      if ip_esn_type in ('CAR CONNECT') then
        v_hide_sim := 'true';
      -- BLOCK ALL CDMA, EXCEPT LTE SIM REMOVABLE SIM PHONES
      elsif ip_technology = 'CDMA' and lte_service_pkg.is_esn_lte_cdma(p_esn => ip_part_serial_no) in (0,2) then
      -- return 1 if ESN is LTE Spring CDMA with SIM removable CR22799
      -- return 0 if ESN is not LTE Spring CDMA with SIM removable CR22799
      -- return 2 other errors
        v_hide_sim := 'true';
      else
        v_hide_sim := 'false';
      end if;
      return v_hide_sim;
    end hide_sim;

    -- NEW HIDE MIN FUNCTION
    function hide_min(ip_esn_type varchar2)
    return varchar2
    is
      v_hide_min varchar2(30) := 'false';
    begin
      if ip_esn_type in ('BYOT','CAR CONNECT','HOME ALERT','HOTSPOT') then
        v_hide_min  := 'true';
      end if;
      return v_hide_min;
    end hide_min;

    -- FUNCTION GET INSTALL DATE
    function get_install_date(part_serial_no varchar2)
    return date
    as
      install_date date;
      n_is_refurb number;
    begin
      select count(1)
      into   n_is_refurb
      from   table_site_part sp_a
      where  sp_a.x_service_id = part_serial_no
      and    sp_a.x_refurb_flag = 1;

      if n_is_refurb = 0 then
        select min(install_date)
        into   install_date
        from   sa.table_site_part
        where  x_service_id = part_serial_no
        and    part_status || '' in ('Active','Inactive');
      else
        select min(install_date)
        into   install_date
        from   table_site_part sp_b
        where  sp_b.x_service_id = part_serial_no
        and    sp_b.part_status || '' in ('Active','Inactive')
        and    nvl(sp_b.x_refurb_flag,0) <> 1;
      end if;

      return install_date;
    exception
      when others then
        return null;
    end get_install_date;

    -- FUNCTION TO OBTAIN THE CARRIER PENDING STATUS BASED OFF THE SWITCHBASED TRANS TABLE
    function sb_carrier_pending(ip_esn varchar2, ip_part_status varchar2)
    return varchar2
    is
    begin
      for i in (select count(swbtx.status) counter,
                       swbtx.status, swbtx.x_type cp_type
                from   sa.table_x_call_trans calltx,
                       sa.x_switchbased_transaction swbtx
                where  calltx.objid =  swbtx.x_sb_trans2x_call_trans
                and    calltx.x_service_id = ip_esn
                and    swbtx.status = 'CarrierPending'
                and    nvl(calltx.x_action_type,'NA') != '7'
                group by swbtx.status, swbtx.x_type)
      loop
        if i.status = 'CarrierPending' then
          return i.status;
        end if;
      end loop;

      return ip_part_status;
    end;

  begin
      get_service_profile_rslt.part_serial_no := null;
      get_service_profile_rslt.x_hex_serial_no := null;
      get_service_profile_rslt.part_number := null;
      get_service_profile_rslt.description := null;
      get_service_profile_rslt.technology := null;
      get_service_profile_rslt.technology_alt := null;
      get_service_profile_rslt.brand := null;
      get_service_profile_rslt.sequence := null;
      get_service_profile_rslt.dealer_id := null;
      get_service_profile_rslt.dealer_name := null;
      get_service_profile_rslt.phone_status := null;
      get_service_profile_rslt.sim := null;
      get_service_profile_rslt.sim_status := null;
      get_service_profile_rslt.site_part_objid := null;
      get_service_profile_rslt.install_date := null;
      get_service_profile_rslt.service_end_dt := null;
      get_service_profile_rslt.x_expire_dt := null;
      get_service_profile_rslt.part_status := null;
      get_service_profile_rslt.x_min := null;
      get_service_profile_rslt.min_status := null;
      get_service_profile_rslt.carrier := null;
      get_service_profile_rslt.carrier_id := null;
      get_service_profile_rslt.carrier_objid := null;
      get_service_profile_rslt.warr_end_date := null;
      get_service_profile_rslt.projected_end_date := null;
      get_service_profile_rslt.contact_objid := null;
      get_service_profile_rslt.customer_id := null;
      get_service_profile_rslt.first_name := null;
      get_service_profile_rslt.last_name := null;
      get_service_profile_rslt.phone := null;
      get_service_profile_rslt.e_mail := null;
      get_service_profile_rslt.x_part_inst_status := null;
      get_service_profile_rslt.class_name := null;
      get_service_profile_rslt.web_user_login_name := null;
      get_service_profile_rslt.web_user_objid := null;
      get_service_profile_rslt.x_zipcode := null;
      get_service_profile_rslt.esn_objid := null;
      get_service_profile_rslt.x_msid := null;
      get_service_profile_rslt.cards_in_queue := null;
      get_service_profile_rslt.warranty_exchanges := null;
      get_service_profile_rslt.smartphone := null;
      get_service_profile_rslt.x_dll := null;
      get_service_profile_rslt.reserved_min := null;
      get_service_profile_rslt.hide_balance := null;
      get_service_profile_rslt.hide_sim := null;
      get_service_profile_rslt.ota_pending := null;
      get_service_profile_rslt.device_type := null;
      get_service_profile_rslt.groupid := null;
      get_service_profile_rslt.group_nick_name := null;
      get_service_profile_rslt.group_status := null;
      get_service_profile_rslt.group_total_devices := null;
      get_service_profile_rslt.groupid := null;
      get_service_profile_rslt.group_nick_name := null;
      get_service_profile_rslt.group_status := null;
      get_service_profile_rslt.group_total_devices := null;
      get_service_profile_rslt.basic_warranty := null;
      get_service_profile_rslt.extended_warranty := null;
      get_service_profile_rslt.is_wty_recurrent_flag := null;
      get_service_profile_rslt.wty_enroll_status := null;
      get_service_profile_rslt.wty_next_charge_date := null;
      get_service_profile_rslt.acc_cust_id := null;
      get_service_profile_rslt.acc_contact_objid  := null;
      get_service_profile_rslt.x_pin := null;
      get_service_profile_rslt.x_dateofbirth := null;
      get_service_profile_rslt.x_secret_questn  := null;
      get_service_profile_rslt.x_secret_ans := null;
      get_service_profile_rslt.bus_org_objid := null;
      get_service_profile_rslt.x_policy_description := null;
      get_service_profile_rslt.service_plan_objid := null;
      get_service_profile_rslt.service_type := null;
      get_service_profile_rslt.program_type := null;
      get_service_profile_rslt.program_objid := null;
      get_service_profile_rslt.next_charge_date := null;
      get_service_profile_rslt.program_units := null;
      get_service_profile_rslt.program_days := null;
      get_service_profile_rslt.rate_plan := null;
      get_service_profile_rslt.x_prg_script_text  := null;  --CR32952
      get_service_profile_rslt.x_prg_desc_script_text  := null;  --CR32952
      get_service_profile_rslt.adf_next_charge_date := null;
      get_service_profile_rslt.adf_next_refill_date := null;
      get_service_profile_rslt.sl_enrollment_status    := null; -- NEW SAFELINK STUFF
      get_service_profile_rslt.sl_program_name    := null; -- NEW SAFELINK STUFF
      get_service_profile_rslt.sl_current_enrolled    := null; -- NEW SAFELINK STUFF
      get_service_profile_rslt.sl_deenroll_reason    := null; -- NEW SAFELINK STUFF
      get_service_profile_rslt.sl_lifeline_status    := null; -- NEW SAFELINK STUFF
      get_service_profile_rslt.sl_verify_dd    := null; -- NEW SAFELINK STUFF
      get_service_profile_rslt.sl_verify_latestd    := null; -- NEW SAFELINK STUFF
      get_service_profile_rslt.sl_new_plan_effect    := null; -- NEW SAFELINK STUFF
      get_service_profile_rslt.sl_next_delivery_date     := null; -- NEW SAFELINK STUFF
      get_service_profile_rslt.lid    := null; -- NEW SAFELINK STUFF
      get_service_profile_rslt.ll_id  := null; -- NEW lifeline id for no Safelink
      get_service_profile_rslt.redemption_pending := null;
      get_service_profile_rslt.minutes_type := null;    --CR36553 Minutes Type : Regular Minutes / Double Minutes / Triple Minutes
      get_service_profile_rslt.lease_status_flag := null;   --CR36553 Leased to Better Finance : Yes / No
      get_service_profile_rslt.lease_status_name := null;  --CR36553 Lease status Name : Review / Approved ..etc
      get_service_profile_rslt.port_in_progress := null;  --CR36553
      get_service_profile_rslt.stgPortTicket := null;  --CR39428
      get_service_profile_rslt.service_order_stage := 'COMPLETED';  --CR42459
      get_service_profile_rslt.special_offer := null;

      get_service_profile_rslt.sp_carry_over              := null;  -- CR50209
      get_service_profile_rslt.sp_script_id               := null;  -- CR50209
      get_service_profile_rslt.sp_script_text             := null;  -- CR50209
      get_service_profile_rslt.sp_addl_script_text        := null;  -- CR50209
      get_service_profile_rslt.sp_cos_value               := null;  -- CR50209
      get_service_profile_rslt.sp_threshold_value         := null;  -- CR50209
      get_service_profile_rslt.subscriber_cos_value       := null;  -- CR50209
      get_service_profile_rslt.subscriber_threshold_value := null;  -- CR50209

      get_service_profile_rslt.action_item_status				  := null;  -- CR53530

  ----------------------------------------------------------------------------
  -- START THE CODE HERE
  ----------------------------------------------------------------------------
    p_language := get_language(ip_language);
    -- FIRST FIND OUT IF ESN IS PART OF TOTAL WIRELESS' GROUP
    -- THIS WILL DETERMINE CERTAIN FUNCTIONALITY, get_projected_end_date, get_expire_date, get_cards_in_queue
    sa.adfcrm_group_trans_pkg.get_group_info(ip_esn => v_part_serial_no,
                                             op_account_group_id => v_groupid,
                                             op_account_group_name => v_group_nick_name,
                                             op_status => v_group_status,
                                             op_count => v_group_total_devices);

    if v_groupid = '-1' then
      v_master_part_serial_no := v_part_serial_no;
    else
      v_master_part_serial_no := sa.adfcrm_group_trans_pkg.get_master_esn(ip_search_type =>'GROUP_ID', ip_search_value => v_groupid);
      if v_master_part_serial_no is null or v_master_part_serial_no = '' then
        v_master_part_serial_no := v_part_serial_no;
        v_group_status := v_missing_master;
      end if;
    end if;

    get_service_profile_rslt.port_in_progress := 'No';  --CR36553
    -- THIS QUERY MUST NEVER FAIL IF IT DOES, THEN THE ESN DOESN'T EXIST
    select  part_serial_no,
            x_hex_serial_no,
            x_sequence,
            x_iccid,
            warr_end_date,
            x_part_inst_status, -- DONE
            objid,
            part_bad_qty,
            x_domain,
            n_part_inst2part_mod, -- DONE
            nvl(part_inst2inv_bin,(select  b.objid -- part_inst2inv_bin HAS TO RETURN A VALUE
                                   from    sa.table_inv_bin b,
                                           sa.table_site s
                                   where   b.bin_name = s.site_id
                                   and     s.s_name = 'BYOP'
                                   and     s.type=3)) part_inst2inv_bin, -- DONE
            x_part_inst2site_part, -- DONE
            x_part_inst2contact, -- DONE
            objid,
            decode(x_port_in,1,'Yes','No') port_in_progress  --CR36553
    into    v_part_serial_no,
            v_x_hex_serial_no,
            v_x_sequence,
            v_x_iccid,
            v_warr_end_date,
            v_x_part_inst_status,
            v_esn_objid,
            v_warranty_exchanges,
            v_x_domain,
            v_n_part_inst2part_mod,
            v_part_inst2inv_bin,
            v_x_part_inst2site_part,
            v_x_part_inst2contact,
            v_objid,
            get_service_profile_rslt.port_in_progress
    from    table_part_inst
    where   x_domain = 'PHONES'
    and     part_serial_no = v_part_serial_no;

    -- THIS MAY RETURN W/NO VALUE
    begin
      select  objid,
              service_end_dt,
              part_status,
              x_min,
              x_zipcode,
              x_msid
      into    v_site_part_objid,
              v_service_end_dt,
              v_part_status,
              v_x_min,
              v_x_zipcode,
              v_x_msid
      from    table_site_part
      where   objid = v_x_part_inst2site_part;
    exception
      when others then
        null;
    end;

    begin --CR49808 Tracfone Safelink Assist
      select decode(pg.group_name,'SLA_GRP','SAFELINK ASSIST',pg.group_name) special_offer
      into get_service_profile_rslt.special_offer
      from sa.table_x_group2esn g2e,
           sa.table_x_promotion_group pg
      where g2e.groupesn2part_inst = v_esn_objid
      and pg.objid = g2e.groupesn2x_promo_group
      and pg.group_name = 'SLA_GRP'
      and sysdate between nvl(pg.x_start_date,sysdate) and nvl(pg.x_end_date,sysdate)
      and rownum < 2
      ;
    exception
      when others then
        get_service_profile_rslt.special_offer := null;
    end;

    get_service_profile_rslt.stgPortTicket := '';  --CR39428
    --CR39428 added stgPortTicket idNumber for external port transaction.
    begin
      select max(c.id_number)
      into get_service_profile_rslt.stgPortTicket
      from sa.table_case c, sa.table_gbst_elm ge
      where c.x_esn = v_part_serial_no
      and   c.s_title = 'EXTERNAL'
      and   c.x_case_type= 'Transaction'
      and ge.objid = c.casests2gbst_elm
      and ge.title <>  'Closed'
      ;
    exception
      when others then
        null;
    end;

    -- INSTALL DATE LOGIC - AKA ACTIVATION DATE
    begin
      v_install_date := get_install_date(part_serial_no => v_part_serial_no);
    exception
      when others then
        null;
    end;

    v_reserved_min := 'NA';
    begin
      select lpi.part_serial_no
      into v_reserved_min
      from table_part_inst lpi
      where lpi.part_to_esn2part_inst = v_esn_objid
      and lpi.x_domain = 'LINES'
      and length(lpi.part_serial_no) = 10
      and rownum < 2;
    exception
      when others then
        null;
    end;

    if v_x_min is null then
        v_x_min := v_reserved_min;
    end if;

    --NEW MIN OBJID AND MIN STATUS
    begin
      select  part_inst2carrier_mkt,
              x_part_inst_status
      into    vm_part_inst2carrier_mkt,
              vm_x_part_inst_status
      from    table_part_inst
      where   part_serial_no = v_x_min;

      select (select ct3.x_code_name
              from   table_x_code_table ct3
              where  ct3.x_code_number = vm_x_part_inst_status)
      into v_min_status
      from dual;
    exception
      when others then
        null;
    end;

    begin
      select  part_info2part_num
      into    v_part_info2part_num
      from    table_mod_level
      where   objid = v_n_part_inst2part_mod;

      select  part_num2bus_org,
              part_num2part_class,
              x_technology,
              part_number,
              description,
              x_dll
      into    v_part_num2bus_org,
              v_part_num2part_class,
              v_technology,
              v_part_number,
              v_pn_description,
              v_x_dll
      from    table_part_num
      where   objid = v_part_info2part_num;

      select  org_id
      into    v_brand
      from    table_bus_org
      where   objid = v_part_num2bus_org;

      select  name
      into    v_class_name
      from    table_part_class
      where   objid = v_part_num2part_class;
    exception
      when others then
        null;
    end;

    begin
      select  x_code_name
      into    v_phone_status
      from    table_x_code_table
      where   x_code_number = v_x_part_inst_status;
    exception
      when others then
        null;
    end;

    -- THIS MAY FAIL IF NO CONTACT EXISTS
    begin
      select  objid,
              x_cust_id,
              first_name,
              last_name,
              phone,
              e_mail
      into    v_contact_objid,
              v_customer_id,
              v_first_name,
              v_last_name,
              v_phone,
              v_e_mail
      from    table_contact
      where   objid = v_x_part_inst2contact;
    exception
      when others then
        null;
    end;

    begin
      v_esn_type := get_esn_type(ip_part_class => v_class_name);
    exception
      when others then
        null;
    end;

  ---- THIS IS USED TO GET THE WEB USER INFO CAN BE REMOVED BECAUSE WE HAVE ANOTHER QUERY TO CAPTURE THAT
  ----  select  x_contact_part_inst2contact
  ----  into    v_x_contact_part_inst2contact
  ----  from    table_x_contact_part_inst
  ----  where   x_contact_part_inst2part_inst = v_esn_objid;
  --
  ---- THE WEB USER INFO CAN BE REMOVED BECAUSE WE HAVE ANOTHER QUERY TO CAPTURE THAT
  ----  select  login_name web_user_login_name,
  ----          objid web_user_objid
  ----  from    table_web_user
  ----  where   web_user2contact = v_x_contact_part_inst2contact;

    begin
      select  inv_bin2inv_locatn
      into    v_inv_bin2inv_locatn
      from    table_inv_bin
      where   objid = v_part_inst2inv_bin;

      select  inv_locatn2site
      into    v_inv_locatn2site
      from    table_inv_locatn
      where   objid = v_inv_bin2inv_locatn;

      select  site_id,
              name dealer_name
      into    v_dealer_id,
              v_dealer_name
      from    table_site
      where   objid = v_inv_locatn2site;
    exception when others then
      null;
    end;


    begin
      select car.x_carrier_id carrier_id, car.x_carrier_id||' '||car.x_mkt_submkt_name carrier, car.objid
      into   v_carrier_id,v_carrier, v_carrier_objid
      from   table_x_carrier car
      where  car.objid = vm_part_inst2carrier_mkt;
    exception
      when others then
        null;
    end;

    select (select c.x_code_name
            from   table_x_sim_inv si,
                   table_x_code_table c
            where  si.x_sim_inv_status = c.x_code_number
            and    si.x_sim_serial_no = v_x_iccid)
    into   v_sim_status
    from dual;

    if sa.device_util_pkg.get_smartphone_fun(v_part_serial_no) = 0 then
      v_is_smartphone := 'true';
    end if;

    if sa.adfcrm_cust_service.has_ota_cdma_pending(ip_esn => v_part_serial_no) = 1 then
      v_is_ota_pending := 'true';
    end if;

    begin --CR47564 - Walmart Family Mobile Program  This new function can be applied for all brands.
        v_projected_end_date := sa.CUSTOMER_INFO.get_service_forecast_due_date (i_esn => v_master_part_serial_no);
    exception
      when others then
        DBMS_OUTPUT.PUT_LINE('ERROR when intempting to get projected end date '||substr(sqlerrm,1,100));
    end;

    begin
      if v_groupid = '-1' then
        select x_expire_dt, cmmtmnt_end_dt service_exp_date
        into   v_get_expire_date, v_service_exp_date --CR42459
        from   table_site_part s
        where  s.objid = v_x_part_inst2site_part;
      else
        select x_expire_dt, cmmtmnt_end_dt service_exp_date
        into   v_get_expire_date, v_service_exp_date --CR42459
        from   table_site_part s,
               table_part_inst p
        where  s.objid = p.x_part_inst2site_part
        and    p.part_serial_no = v_master_part_serial_no;
      end if;
    exception
      when others then
        null;
    end;

    begin
      select (case when (sysdate - (select decode(refurb_yes.is_refurb, 0,nonrefurb_act_date,refurb_act_date) warranty_activation_date
                                    from (select count (1) is_refurb
                                          from table_site_part sp_a
                                          where sp_a.x_service_id = v_part_serial_no
                                          and sp_a.x_refurb_flag = 1) refurb_yes,
                                         (select min (install_date) refurb_act_date
                                          from table_site_part sp_b
                                          where sp_b.x_service_id = v_part_serial_no
                                          and sp_b.part_status || '' in ('Active', 'Inactive')
                                          and nvl (sp_b.x_refurb_flag, 0) <> 1) refurb_act_date,
                                         (select min (install_date) nonrefurb_act_date
                                          from table_site_part sp_c
                                          where sp_c.x_service_id = v_part_serial_no
                                          and sp_c.part_status || '' in ('Active', 'Inactive')) nonrefurb_act_date )) > 365 then 'Expired'
              else 'Active'
              end) basic_warranty
      into v_basic_warranty
      from dual;
    exception
      when others then
        null;
    end;

    begin
      select /*+ ORDERED */
            pp.x_program_name
            ,decode(pp.x_is_recurring,'1','YES','NO')
            ,pe.x_enrollment_status
            ,to_char(pe.x_next_charge_date,'MM/DD/YYYY')
      into  v_ext_warranty,
            get_service_profile_rslt.is_wty_recurrent_flag,
            get_service_profile_rslt.wty_enroll_status,
            get_service_profile_rslt.wty_next_charge_date
      from  sa.x_program_enrolled   pe,
            sa.x_program_parameters pp,
            sa.table_part_num       pn
      where pe.x_esn = v_part_serial_no
      and   pe.x_enrollment_status not in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
      and   pp.objid = pe.pgm_enroll2pgm_parameter
      and   pp.x_prog_class = 'WARRANTY'
      and   pn.objid = pp.prog_param2prtnum_monfee
      order by x_insert_date desc;
    exception when others then
      if instr(sqlerrm,'ORA-01403')>0 then
        v_ext_warranty := null;
      end if;
    end;

    begin
      select tp.x_policy_description
      into   v_policy_description
      from   w3ci.table_x_throttling_cache tc,
             w3ci.table_x_throttling_policy tp
      where  tc.x_esn = v_part_serial_no
      and tp.objid = tc.x_policy_id
      and x_status = 'A';
    exception
      when others then
        null;
    end;

    begin
      if v_groupid = '-1' then
        select count(1)
        into v_cards_in_queue
        from table_part_inst
        where x_part_inst_status = '400'
        and x_domain = 'REDEMPTION CARDS'
        and part_to_esn2part_inst in (v_esn_objid);
      else
        select count(1)
        into v_cards_in_queue
        from table_part_inst
        where x_part_inst_status = '400'
        and x_domain = 'REDEMPTION CARDS'
        and part_to_esn2part_inst in (select objid
                                      from table_part_inst pi
                                      where pi.part_serial_no = v_master_part_serial_no);
      end if;
    exception
      when others then
        null;
    end;

    if v_esn_type in ('CAR CONNECT','HOME ALERT') then  --CR29587 removed BYOT
        v_hide_balance := 'true';
    end if;

    v_hide_sim := hide_sim(ip_technology =>v_technology, ip_part_serial_no =>v_part_serial_no, ip_esn_type =>v_esn_type);

    v_hide_min := hide_min(ip_esn_type =>v_esn_type);

    begin
      v_device_type := sa.get_param_by_name_fun(ip_part_class_name=>v_class_name,ip_parameter=>'DEVICE_TYPE');
    exception
      when others then
        null;
    end;

    -- Added by kvara to get Phone Gen - Part Class Parameter.
    begin
      v_phone_gen := sa.get_param_by_name_fun(ip_part_class_name=>v_class_name,ip_parameter=>'PHONE_GEN');
    exception
      when others then
        null;
    end;

    begin
      get_service_profile_rslt.technology_alt := v_phone_gen;
      if v_phone_gen not in ('4G_LTE','4G') then
          get_service_profile_rslt.technology_alt := sa.get_param_by_name_fun(ip_part_class_name=>v_class_name,ip_parameter=>'CDMA LTE SIM');
        if get_service_profile_rslt.technology_alt in ('REMOVABLE','NON REMOVABLE') then
          get_service_profile_rslt.technology_alt := 'LTE SIM '||get_service_profile_rslt.technology_alt;
        else
          get_service_profile_rslt.technology_alt := v_phone_gen;
        end if;
      end if;
    exception
      when others then
        null;
    end;

    -- REVIEW THIS QUERY
  --  for i in (select * from table(adfcrm_vo.get_account_info(ip_contact_objid => 672041274))) --v_x_part_inst2contact)))
      for i in (select wu.login_name web_user_login_name,
                         wu.objid web_user_objid,
                         con.x_cust_id acc_cust_id,
                         con.objid acc_contact_objid,
                         ai.x_pin,
                         con.x_dateofbirth,
                         wu.x_secret_questn,
                         wu.x_secret_ans,
                         pi.x_part_inst2contact  contact_objid,
                         wu.web_user2bus_org bus_org_objid
                  from   table_web_user wu,
                         table_contact con,
                         table_x_contact_add_info ai,
                         table_part_inst pi,
                         table_x_contact_part_inst cpi
                  where  pi.objid = cpi.x_contact_part_inst2part_inst
                  and    cpi.x_contact_part_inst2contact = con.objid
                  and    con.objid = ai.add_info2contact
                  and    con.objid= wu.web_user2contact
                  and    pi.x_part_inst2contact = v_x_part_inst2contact)
    loop
      v_web_user_login_name     := i.web_user_login_name;
      v_web_user_objid          := i.web_user_objid;
      v_acc_cust_id             := i.acc_cust_id;
      v_acc_contact_objid       := i.acc_contact_objid;
      v_x_pin                   := i.x_pin;
      v_x_dateofbirth           := i.x_dateofbirth;
      v_x_secret_questn         := i.x_secret_questn;
      v_x_secret_ans            := i.x_secret_ans;
      v_contact_objid           := i.contact_objid;
      v_bus_org_objid           := i.bus_org_objid;
    end loop;

    -- REMOVED UNION MADE INTO TWO QUERIES
    if v_web_user_login_name is null then
      for j in (select wu.login_name web_user_login_name,
                       wu.objid web_user_objid,
                       con.x_cust_id acc_cust_id,
                       con.objid acc_contact_objid,
                       ai.x_pin,
                       con.x_dateofbirth,
                       wu.x_secret_questn,
                       wu.x_secret_ans,
                       con.objid contact_objid,
                       wu.web_user2bus_org bus_org_objid
                from   table_web_user wu,
                       table_contact con,
                       table_x_contact_add_info ai
                where  con.objid = ai.add_info2contact
                and    con.objid= wu.web_user2contact
                and    con.objid= v_x_part_inst2contact)
      loop
        v_web_user_login_name     := j.web_user_login_name;
        v_web_user_objid          := j.web_user_objid;
        v_acc_cust_id             := j.acc_cust_id;
        v_acc_contact_objid       := j.acc_contact_objid;
        v_x_pin                   := j.x_pin;
        v_x_dateofbirth           := j.x_dateofbirth;
        v_x_secret_questn         := j.x_secret_questn;
        v_x_secret_ans            := j.x_secret_ans;
        v_contact_objid           := j.contact_objid;
        v_bus_org_objid           := j.bus_org_objid;
      end loop;
    end if;

		-- CR53530 - Get Latest IG Action Item Status
		begin
			WITH task AS
				(SELECT MAX(task_id) task_id
				FROM sa.table_task t,
					sa.table_contact c
				WHERE 1            =1
				AND t.task2contact = c.objid
				AND c.objid        = v_contact_objid
				)
			SELECT status into v_ig_action_item_status
			FROM
				(SELECT status
				FROM task,
					gw1.ig_transaction ig
				WHERE ig.ACTION_ITEM_ID = task.task_id
				UNION
				SELECT status
				FROM task,
					gw1.ig_transaction_history igh
				WHERE igh.ACTION_ITEM_ID = task.task_id
				)
			WHERE rownum < 2;

			v_action_item_status := sa.adfcrm_carrier.get_action_item_status_code(v_ig_action_item_status);

    exception
      when others then
				null;
    end;
		-- End CR53530

    --WFM     Consider all active ESNs in the account and those with a port in progress
    if v_brand = 'WFM' then
        select  count(*) acct_active_esns
        into    v_group_total_devices
        from    sa.table_web_user            web,
                sa.table_x_contact_part_inst cpi,
                sa.table_part_inst           pi
        where web.objid = v_web_user_objid
        and   cpi.x_contact_part_inst2contact = web.web_user2contact
        and   pi.objid = cpi.x_contact_part_inst2part_inst
        and   (pi.x_part_inst_status = '52'
               OR EXISTS
                  (SELECT '1'
                  FROM sa.table_case c,
                       sa.table_condition co
                  WHERE c.x_esn              = pi.part_serial_no
                  AND c.x_case_type          = 'Port In'
                  AND c.case_state2condition = co.objid
                  AND co.title              <> 'Closed')
              )
        ;
    end if;

    begin
      if v_groupid = '-1' then
        sa.adfcrm_group_trans_pkg.get_program_info( p_esn => v_part_serial_no,
                                                    p_service_plan_objid => v_service_plan_objid,
                                                    p_service_type => v_service_type,
                                                    p_program_type => v_program_type,
                                                    p_next_charge_date => v_next_charge_date,
                                                    p_program_units => v_program_units,
                                                    p_program_days => v_program_days,
                                                    p_rate_plan => v_rate_plan,
                                                    p_x_prg_script_id => v_prg_script_id, --CR32952
                                                    p_x_prg_desc_script_id  => v_prg_desc_script_id, --CR32952
                                                    p_error_num => v_error_num);
      else
        sa.phone_pkg.get_program_info (p_esn => v_part_serial_no,
                                    p_service_plan_objid => v_service_plan_objid,
                                    p_service_type => v_service_type,
                                    p_program_type => v_program_type,
                                    p_next_charge_date => v_next_charge_date,
                                    p_program_units => v_program_units,
                                    p_program_days => v_program_days,
                                    p_rate_plan => v_rate_plan,
                                    p_x_prg_script_id => v_prg_script_id, --CR32952
                                    p_x_prg_desc_script_id  => v_prg_desc_script_id, --CR32952
                                    p_error_num => v_error_num);
      end if;
    exception
      when others then
        null;
    end;
    /* CR44010 Find the program objid by the program type found
    */
    if v_program_type is not null then
         begin
            SELECT pgmprm.objid
            INTO get_service_profile_rslt.program_objid
            FROM  x_program_enrolled pgmenr,
                  x_program_parameters pgmprm
            WHERE  1                          = 1
            AND pgmenr.x_esn                  = v_part_serial_no
            AND pgmenr.x_enrollment_status    = 'ENROLLED'
            AND pgmprm.objid                  = pgmenr.pgm_enroll2pgm_parameter
            AND pgmprm.x_program_name         = v_program_type
            ;
        exception
               when others then null;
         end;
    end if;
    if v_prg_script_id is not null     --CR32952
    then
         if v_service_plan_objid in (487,488) then
            --CR48200 Exception for program scripts    Refer Defect 22293
                    v_prg_script_id := sa.adfcrm_get_serv_plan_value(v_service_plan_objid, 'PROGRAM_NAME_SCRIPT');
            if v_prg_script_id is not null then
               get_service_profile_rslt.x_prg_script_text := sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => substr(v_prg_script_id,1,instr(v_prg_script_id,'_')-1),
                                                                       ip_script_id => substr(v_prg_script_id,instr(v_prg_script_id,'_')+1),
                                                                       ip_language => p_language,
                                                                       ip_sourcesystem  => 'ALL',
                                                                       ip_brand_name => v_brand);
            end if;
       else
           begin
               get_service_profile_rslt.x_prg_script_text := v_prg_script_id;
           exception
               when others then null;
           end;
       end if;
    ---------------------------------------------------------------------------------------------------------------------------
    --CR41304 Begin
    --AUTO-REFILL ENROLLMENT STATUS IN PROFILE SHOULD INCLUDE VISIBILITY FOR CUSTOMERS WHO HAD AN ENROLLMENT IN THE LAST 30 DAYS
    --TO GET THE ENROLLMENT STATUS OF THE ESN WHEN IT IS OTHER THAN ENROLLED STATUS AND DECODE IT UNDER AGENT SPECIFIC DISPLAY
    --ZMOHAMMED 5/12/16 BAU RELEASE
    ----------------------------------------------------------------------------------------------------------------------------
       else
         begin
             SELECT (case when pgmenr.x_enrollment_status IN('READYTOREENROLL','DEENROLLED')
                          THEN 'DEENROLLED'||'('||(to_char(TRUNC(max(trans.x_trans_date)),'MON-dd-rr'))||')'
                          when pgmenr.x_enrollment_status IN('SUSPENDED','ENROLLMENTPENDING','ENROLLED_NO_ACCOUNT', 'ENROLLMENTSCHEDULED')
                          THEN 'ONHOLD'
                    END) INTO get_service_profile_rslt.x_prg_script_text
            FROM  x_program_parameters pgmprm,
                  x_program_enrolled pgmenr,
                  x_program_trans trans
            WHERE  1                          = 1
            AND pgmprm.objid                  = pgmenr.pgm_enroll2pgm_parameter
            AND  pgmprm.x_is_recurring        = 1
            AND NVL(pgmprm.x_prog_class ,' ') NOT IN ('HMO','ONDEMAND','WARRANTY','LOWBALANCE')
            and trans.x_esn = pgmenr.x_esn
            AND trans.pgm_tran2pgm_entrolled = pgmenr.objid
            AND trunc(sysdate-trans.x_trans_date)   <=30
            AND pgmenr.x_esn                  = v_part_serial_no
            group by pgmenr.x_enrollment_status;
        exception
               when others then null;
         end;
     --------------------------------------------------------------------------------------------------------------------------
     --CR41304 End
     --------------------------------------------------------------------------------------------------------------------------
     end if;     --CR32952
    if v_prg_desc_script_id is not null     --CR32952
    then
       begin
          get_service_profile_rslt.x_prg_desc_script_text := v_prg_desc_script_id;
       exception
          when others then null;
       end;
     end if;     --CR32952

    --CR49915 WFM LIFELINE Changes start
    IF v_brand = 'WFM' THEN
      begin
        --New variable for lifeline id that are not Safelink
        get_service_profile_rslt.ll_id := sa.adfcrm_lifeline.get_lid(i_esn => ip_part_serial_no, i_min => v_x_min);
        if get_service_profile_rslt.ll_id is not null
        then
            for ll in (select x_program_name, x_enrollment_status
                       from table(sa.adfcrm_lifeline.get_ll_enrollment_details( i_esn => ip_part_serial_no,
                                       i_min        => v_x_min,
                                       i_lid        => get_service_profile_rslt.ll_id,
                                       i_language   => p_language
                                     ))
                      )
            loop
                get_service_profile_rslt.sl_program_name := ll.x_program_name;
                get_service_profile_rslt.sl_enrollment_status := ll.x_enrollment_status;
            end loop;
        end if;
      exception
        when others then
          null;
      end;
    ELSE
      begin
        v_lid := sa.adfcrm_safelink.get_lid(ip_esn =>ip_part_serial_no);
      exception
        when others then
          null;
      end;
    end if;
    --CR49915 WFM LIFELINE Changes end

      if v_lid is not null then
        for k in (select col, val
                  from   table(sa.adfcrm_safelink.ret_info(ip_esn => ip_part_serial_no))) --
        loop
          if k.col = 'x_enrollment_status' then
            v_sl_enrollment_status := k.val;
            get_service_profile_rslt.sl_enrollment_status := k.val;
          end if;
          if k.col = 'x_program_name' then
            get_service_profile_rslt.sl_program_name := k.val;
          end if;
          if k.col = 'x_current_enrolled' then
            get_service_profile_rslt.sl_current_enrolled := k.val;
          end if;
          if k.col = 'x_deenroll_reason' then
            get_service_profile_rslt.sl_deenroll_reason := k.val;
          end if;
          if k.col = 'lifeline_status' then
            get_service_profile_rslt.sl_lifeline_status := k.val;
          end if;
          if k.col = 'verification_due_date' then
            get_service_profile_rslt.sl_verify_dd := k.val;
          end if;
          if k.col = 'latest_verify_date' then
            get_service_profile_rslt.sl_verify_latestd := k.val;
          end if;
          if k.col = 'new_plan_effective_date' then
            get_service_profile_rslt.sl_new_plan_effect := k.val;
          end if;
          if k.col = 'next_delivery_date' then
            v_sl_next_delivery_date := k.val;
            get_service_profile_rslt.sl_next_delivery_date := k.val;
          end if;
          if k.col = 'lid' then
            get_service_profile_rslt.lid := k.val;
          end if;
        end loop;
      end if;

      --if v_service_plan_objid is not null then
      -- CR50209 -- THIS QUERY IS STILL UNDER REVIEW AND PENDING RESPONSE BY ELIZABETH VEGA AND GONZALO
      -- NEW FEILDS ADDED (PRICE,DAYS,CARRIER_OVER,VOICE,SMS,DATA)
      -- DETERMINING WHERE TO GRAB THE DATA VALUE
      -------------------------------------------------------------------------------------------------
      get_sp_info(
                  ip_part_class =>v_class_name,
                  ip_min => v_x_min,
                  ip_bus_org_objid => v_part_num2bus_org,
                  ip_spobjid => v_service_plan_objid,
                  op_sp_carry_over => v_sp_carry_over,
                  op_script_id => v_sp_script_id, -- NEW
                  op_sp_script_text => v_sp_script_text, -- NEW - MAIN SCRIPT TO SHOW
                  op_sp_addl_script_text => v_sp_addl_script_text, -- NEW - IF THE SP'S COS DOES NOT MATCH THE MIN'S COS - SCRIPT TO SHOW
                  op_sp_cos_value => v_sp_cos_value, -- NEW - SP COS
                  op_sp_threshold_value => v_sp_threshold_value, -- NEW - SP THRESHOLD VALUE
                  op_subscriber_cos_value => v_subscriber_cos_value, -- MIN COS
                  op_subscriber_threshold_value => v_subscriber_threshold_value -- MIN'S THRESHOLD VALUE
                  );
      -------------------------------------------------------------------------------------------------
      --end if;

      v_part_status := sb_carrier_pending(ip_esn =>v_part_serial_no, ip_part_status =>v_part_status);

      get_service_profile_rslt.part_serial_no := v_part_serial_no;
      get_service_profile_rslt.x_hex_serial_no := v_x_hex_serial_no;
      get_service_profile_rslt.part_number := v_part_number;
      get_service_profile_rslt.description := v_pn_description;
      get_service_profile_rslt.technology := v_technology;
      get_service_profile_rslt.brand := v_brand;
      get_service_profile_rslt.sequence := v_x_sequence;
      get_service_profile_rslt.dealer_id := v_dealer_id;
      get_service_profile_rslt.dealer_name := v_dealer_name;
      get_service_profile_rslt.phone_status := v_phone_status;
      get_service_profile_rslt.sim := v_x_iccid;
      get_service_profile_rslt.sim_status := v_sim_status;
      get_service_profile_rslt.site_part_objid := v_site_part_objid;
      get_service_profile_rslt.install_date := to_char(v_install_date,'MM/DD/YYYY');
      get_service_profile_rslt.service_end_dt := to_char(v_service_end_dt,'MM/DD/YYYY');
      get_service_profile_rslt.x_expire_dt := to_char(v_get_expire_date,'MM/DD/YYYY');
      get_service_profile_rslt.part_status := v_part_status;
      get_service_profile_rslt.x_min := v_x_min;
      get_service_profile_rslt.min_status := v_min_status;
      if v_reserved_min != 'NA' then
        get_service_profile_rslt.carrier := v_carrier;
        get_service_profile_rslt.carrier_id := v_carrier_id;
        get_service_profile_rslt.carrier_objid := v_carrier_objid;
      end if;
      get_service_profile_rslt.warr_end_date := to_char(v_warr_end_date,'MM/DD/YYYY');
      if v_x_part_inst_status = '52' then
        get_service_profile_rslt.projected_end_date := to_char(v_projected_end_date,'MM/DD/YYYY');
      end if;
      get_service_profile_rslt.contact_objid := v_contact_objid;
      get_service_profile_rslt.customer_id := v_customer_id;
      get_service_profile_rslt.first_name := v_first_name;
      get_service_profile_rslt.last_name := v_last_name;
      get_service_profile_rslt.phone := v_phone;
      get_service_profile_rslt.e_mail := v_e_mail;
      get_service_profile_rslt.x_part_inst_status := v_x_part_inst_status;
      get_service_profile_rslt.class_name := v_class_name;
      get_service_profile_rslt.web_user_login_name := v_web_user_login_name;
      get_service_profile_rslt.web_user_objid := v_web_user_objid;
      get_service_profile_rslt.x_zipcode := v_x_zipcode;
      get_service_profile_rslt.esn_objid := v_esn_objid;
      get_service_profile_rslt.x_msid := v_x_msid;
      get_service_profile_rslt.cards_in_queue := v_cards_in_queue;
      get_service_profile_rslt.warranty_exchanges := v_warranty_exchanges;
      get_service_profile_rslt.smartphone := v_is_smartphone;
      get_service_profile_rslt.x_dll := v_x_dll;
      get_service_profile_rslt.reserved_min := v_reserved_min;
      get_service_profile_rslt.hide_balance := v_hide_balance;
      get_service_profile_rslt.hide_sim := v_hide_sim;
      get_service_profile_rslt.hide_min := v_hide_min;
      get_service_profile_rslt.ota_pending := v_is_ota_pending;
      get_service_profile_rslt.device_type := v_device_type;
      get_service_profile_rslt.phone_gen := v_phone_gen; -- Added by kvara to get Phone Gen - Part Class Parameter.
      get_service_profile_rslt.groupid := v_groupid;
      get_service_profile_rslt.group_nick_name := v_group_nick_name;

      if v_group_status != 'MASTER MISSING' then
        get_service_profile_rslt.group_status := v_group_status;
      end if;

      get_service_profile_rslt.group_total_devices := v_group_total_devices;
      get_service_profile_rslt.basic_warranty := v_basic_warranty;
      get_service_profile_rslt.extended_warranty := v_ext_warranty;
      get_service_profile_rslt.acc_cust_id := v_acc_cust_id;
      get_service_profile_rslt.acc_contact_objid  := v_acc_contact_objid;
      get_service_profile_rslt.x_pin := v_x_pin;
      get_service_profile_rslt.x_dateofbirth := to_char(v_x_dateofbirth,'MM/DD/YYYY');
      get_service_profile_rslt.x_secret_questn  := v_x_secret_questn;
      get_service_profile_rslt.x_secret_ans := v_x_secret_ans;
      get_service_profile_rslt.bus_org_objid := v_bus_org_objid;
      get_service_profile_rslt.x_policy_description := v_policy_description;
      get_service_profile_rslt.service_plan_objid := v_service_plan_objid;

      get_service_profile_rslt.sp_carry_over            := v_sp_carry_over;               -- CR50209
      get_service_profile_rslt.sp_script_id               := v_sp_script_id;                -- CR50209
      get_service_profile_rslt.sp_script_text             := v_sp_script_text;              -- CR50209
      get_service_profile_rslt.sp_addl_script_text        := v_sp_addl_script_text;         -- CR50209
      get_service_profile_rslt.sp_cos_value               := v_sp_cos_value;                -- CR50209
      get_service_profile_rslt.sp_threshold_value         := v_sp_threshold_value;          -- CR50209
      get_service_profile_rslt.subscriber_cos_value       := v_subscriber_cos_value;        -- CR50209
      get_service_profile_rslt.subscriber_threshold_value := v_subscriber_threshold_value;  -- CR50209

      get_service_profile_rslt.action_item_status := v_action_item_status;					--CR53530

      get_service_profile_rslt.service_type := v_service_type;
      get_service_profile_rslt.program_type := v_program_type;
      get_service_profile_rslt.next_charge_date := to_char(v_next_charge_date,'MM/DD/YYYY');
      get_service_profile_rslt.program_units := v_program_units;
      get_service_profile_rslt.program_days := v_program_days;
      get_service_profile_rslt.rate_plan := v_rate_plan;
      get_service_profile_rslt.redemption_pending := has_pending_redemption (ip_esn => v_part_serial_no);

      -- REPLACES THE NEXT CHARGE DATE LOGIC WE DISPLAY IN TAS
      -- VALUE #{(bindings.CardsInQueue.inputValue eq "0")? bindings.NextChargeDate.inputValue : bindings.ProjectedEndDate.inputValue}
      if v_program_type is not null then
        if v_cards_in_queue = 0 then
          get_service_profile_rslt.adf_next_charge_date := to_char(v_next_charge_date,'MM/DD/YYYY');
        else
          get_service_profile_rslt.adf_next_charge_date := to_char(v_projected_end_date,'MM/DD/YYYY');
        end if;
      end if;

      -- REPLACES THE NEXT REFILL DATE LOGIC WE DISPLAY IN TAS
      -- VALUE #{(pageFlowScope.sl_enrollment_status eq  'ENROLLED')? pageFlowScope.sl_next_delivery_date: bindings.XExpireDt.inputValue}
      if v_cards_in_queue != 0 or v_sl_enrollment_status = 'ENROLLED' then
        if v_sl_enrollment_status = 'ENROLLED' then
          get_service_profile_rslt.adf_next_refill_date := nvl(to_char(v_service_exp_date,'MM/DD/YYYY'),v_sl_next_delivery_date);
        else
          get_service_profile_rslt.adf_next_refill_date := to_char(nvl(v_service_exp_date,v_get_expire_date),'MM/DD/YYYY');  --CR42459
        end if;
      else
        get_service_profile_rslt.adf_next_refill_date := to_char(v_service_exp_date,'MM/DD/YYYY');  --CR42459
      end if;

      get_service_profile_rslt.minutes_type := 'Regular Minutes';    --CR36553 Minutes Type : Regular Minutes / Double Minutes / Triple Minutes
      for rec in (select group_name promo_group,
                  CASE group_name
                  WHEN 'DBLMIN_ADVAN_GRP' THEN 'Double Minutes'
                  WHEN 'DBLMIN_GRP' THEN 'Double Minutes'
                  WHEN 'DBLMN_3390_GRP' THEN 'Double Minutes'
                  WHEN 'DBLMN_ACT2_GRP' THEN 'Double Minutes'
                  WHEN 'DBLMN_ACT3_GRP' THEN 'Double Minutes'
                  WHEN 'DBLMN_ACT4_GRP' THEN 'Double Minutes'
                  WHEN 'DBLMN_ACT5_GRP' THEN 'Double Minutes'
                  WHEN 'DBLMN_ACTL_GRP' THEN 'Double Minutes'
                  WHEN 'DBLMN_ACT_GRP' THEN 'Double Minutes'
                  WHEN 'LG225DBLMN_GRP' THEN 'Double Minutes'
                  WHEN 'RTAUG07DBL_GRP' THEN 'Double Minutes'
                  WHEN 'RTDBL02_GRP' THEN 'Double Minutes'
                  WHEN 'X3XMN_ACT_GRP' THEN 'Triple Minutes'
                  WHEN 'X3XMN_ACT_GRP2' THEN 'Triple Minutes'
                  WHEN 'X3XMN_GRP' THEN 'Triple Minutes'
                  ELSE 'Regular Minutes'
                  END minutes_type
                  from   sa.table_part_inst,
                         sa.table_x_group2esn,
                         sa.table_x_promotion_group,
                         sa.table_x_promotion
                  where  1=1
                  and    table_part_inst.objid  = groupesn2part_inst
                  and    groupesn2x_promo_group = table_x_promotion_group.objid
                  and    groupesn2x_promotion   = table_x_promotion.objid
                  and    table_part_inst.part_serial_no         = get_service_profile_rslt.part_serial_no
                  and    table_part_inst.x_domain = 'PHONES'
                  and    table_x_group2esn.x_start_date <= sysdate
                  and    table_x_group2esn.x_end_date >= sysdate
                  )
      loop
          get_service_profile_rslt.minutes_type := rec.minutes_type;
      end loop;

      get_service_profile_rslt.lease_status_flag := 'No';   --CR36553 Leased to Better Finance : Yes / No
      get_service_profile_rslt.lease_status_name := null;  --CR36553 Lease status Name : Review / Approved ..etc
      for rec in (select cl.x_esn, cl.lease_status, ls.lease_status_name,ls.remove_leased_group_flag
                  from sa.x_customer_lease cl ,
                        sa.x_lease_status ls
                  where cl.x_esn = get_service_profile_rslt.part_serial_no
                  and  cl.lease_status = ls.lease_status
                  order by UPDATE_DT asc
                 )
      loop
	      if rec.remove_leased_group_flag ='Y' then
				--get_service_profile_rslt.lease_status_flag := 'No';
				get_service_profile_rslt.lease_status_flag := 'Paid';
				get_service_profile_rslt.lease_status_name := rec.lease_status_name;
				exit;
		  else
				get_service_profile_rslt.lease_status_flag := 'Yes';
				get_service_profile_rslt.lease_status_name := rec.lease_status_name;
		  end if;
      end loop;

      pipe row (get_service_profile_rslt);
      return;
  end get_service_profile;
--********************************************************************************************************************
  function get_account_info(ip_contact_objid in varchar2)
  return get_account_info_tab pipelined
  is
    --*** This table function is replaces the SEARCH ACCOUNT VO from the master use case ***
    p_language varchar2(100);
    get_account_info_rslt get_account_info_rec;
  begin
      get_account_info_rslt.web_user_login_name := null;
      get_account_info_rslt.web_user_objid := null;
      get_account_info_rslt.acc_cust_id := null;
      get_account_info_rslt.acc_contact_objid := null;
      get_account_info_rslt.x_pin := null;
      get_account_info_rslt.x_dateofbirth := null;
      get_account_info_rslt.x_secret_questn := null;
      get_account_info_rslt.x_secret_ans := null;
      get_account_info_rslt.contact_objid := null;
      get_account_info_rslt.bus_org_objid := null;

      for rec in (select wu.login_name web_user_login_name,
                         wu.objid web_user_objid,
                         con.x_cust_id acc_cust_id,
                         con.objid acc_contact_objid,
                         ai.x_pin,
                         con.x_dateofbirth,
                         wu.x_secret_questn,
                         wu.x_secret_ans,
                         con.objid contact_objid,
                         wu.web_user2bus_org bus_org_objid
                  from   table_web_user wu,
                         table_contact con,
                         table_x_contact_add_info ai
                  where  con.objid = ai.add_info2contact
                  and    con.objid= wu.web_user2contact
                  and    con.objid= ip_contact_objid
                  union
                  select wu.login_name web_user_login_name,
                         wu.objid web_user_objid,
                         con.x_cust_id acc_cust_id,
                         con.objid acc_contact_objid,
                         ai.x_pin,
                         con.x_dateofbirth,
                         wu.x_secret_questn,
                         wu.x_secret_ans,
                         pi.x_part_inst2contact  contact_objid,
                         wu.web_user2bus_org bus_org_objid
                  from   table_web_user wu,
                         table_contact con,
                         table_x_contact_add_info ai,
                         table_part_inst pi,
                         table_x_contact_part_inst cpi
                  where  pi.objid = cpi.x_contact_part_inst2part_inst
                  and    cpi.x_contact_part_inst2contact = con.objid
                  and    con.objid = ai.add_info2contact
                  and    con.objid= wu.web_user2contact
                  and    pi.x_part_inst2contact = ip_contact_objid)
      loop
        get_account_info_rslt.web_user_login_name := rec.web_user_login_name;
        get_account_info_rslt.web_user_objid := rec.web_user_objid;
        get_account_info_rslt.acc_cust_id := rec.acc_cust_id;
        get_account_info_rslt.acc_contact_objid := rec.acc_contact_objid;
        get_account_info_rslt.x_pin := rec.x_pin;
        get_account_info_rslt.x_dateofbirth := rec.x_dateofbirth;
        get_account_info_rslt.x_secret_questn := rec.x_secret_questn;
        get_account_info_rslt.x_secret_ans := rec.x_secret_ans;
        get_account_info_rslt.contact_objid := rec.contact_objid;
        get_account_info_rslt.bus_org_objid := rec.bus_org_objid;

        pipe row (get_account_info_rslt);
      end loop;
      return;
  end get_account_info;

--********************************************************************************************************************
    function default_values_purch_hist_rec
    return get_purch_history_rec
    is
       get_purch_history_rslt get_purch_history_rec;
    begin
       get_purch_history_rslt.esn                        := '';
       get_purch_history_rslt.cc_lastfour                := '';
       get_purch_history_rslt.acct_lastfour              := '';
       get_purch_history_rslt.cc_objid                   := null;
       get_purch_history_rslt.ach_objid                  := null;
       get_purch_history_rslt.cc_type                    := '';
       get_purch_history_rslt.aba_transit                := '';
       get_purch_history_rslt.transaction_id             := '';
       get_purch_history_rslt.price                      := null;
       get_purch_history_rslt.discounts                  := null;
       get_purch_history_rslt.sales_tax                  := null;
       get_purch_history_rslt.e911_tax                   := null;
       get_purch_history_rslt.usf_tax                    := null;
       get_purch_history_rslt.rcrf_tax                   := null;
       get_purch_history_rslt.amount                     := null;
       get_purch_history_rslt.transaction_date           := null;
       get_purch_history_rslt.status                     := '';
       get_purch_history_rslt.promo_sponsor              := '';
       get_purch_history_rslt.details                    := '';
       get_purch_history_rslt.payment_type               := '';
       get_purch_history_rslt.s_login_name               := '';
       get_purch_history_rslt.channel                    := '';
       get_purch_history_rslt.vendor                     := '';
       get_purch_history_rslt.product                    := '';
       get_purch_history_rslt.group_id                   := '';
       get_purch_history_rslt.group_name                 := '';
       return get_purch_history_rslt;
    end default_values_purch_hist_rec;

--********************************************************************************************************************
  function get_purch_part_number_desc(ip_purch_objid in number, ip_rqst_date in date, ip_rqst_source in varchar2)
  return varchar2 is
     v_part_number_desc sa.table_part_num.description%type;
  begin
     v_part_number_desc := '';
     begin
          select pn.description
          into v_part_number_desc
          from sa.table_x_purch_dtl pdtl,
               sa.table_mod_level ml,
               sa.table_part_num pn
          where pdtl.x_purch_dtl2x_purch_hdr = ip_purch_objid
          and ml.objid = pdtl.x_purch_dtl2mod_level
          and pn.objid = ml.part_info2part_num
          and 0 = nvl((SELECT tp.x_retail_price
                       FROM table_x_pricing tp
                       WHERE 1 = 1
                       AND tp.x_end_date + 0 > ip_rqst_date
                       AND tp.x_channel || '' = DECODE(ip_rqst_source ,'HANDSET' , 'BUYNOW' ,
                                                            'WAP'   , 'WEB' ,
                                                            'BEAST' , 'WEB' ,
                                                            'APP'   , 'WEB' ,
                                                            'WMKIOSK','WEB' ,
                                                            'UDP'    ,'WEB' ,
                                                            'TAS'  , 'WEBCSR',
                                                            ip_rqst_source)
                       AND tp.x_pricing2part_num = pn.objid
                       ),0)
          and rownum < 2;
     exception when others then
          null;
     end;
     return v_part_number_desc;
  end get_purch_part_number_desc;
--********************************************************************************************************************
  --SELECT *
  --FROM table(sa.ADFCRM_VO.get_purch_history_by_esn(ip_esn))
  -- uc040
  function get_purch_history_by_esn (ip_esn in varchar2)
  return get_purch_history_tab pipelined
  is
      get_purch_history_rslt get_purch_history_rec;
  begin
      get_purch_history_rslt := default_values_purch_hist_rec();
--********************************************************************************************************************
-- BEGIN  Billing payments
--********************************************************************************************************************
     for rec in (
                        select
                               phdr.x_merchant_ref_number transaction_id, --phdr.x_merchant_ref_number,
                               NVL(phdr.x_amount,0) price, --phdr.x_amount,
                               NVL(phdr.x_e911_tax_amount,0) e911_tax, --phdr.x_e911_tax_amount,
                               NVL(phdr.x_usf_taxamount,0) usf_tax, --phdr.x_usf_taxamount,
                               NVL(phdr.x_rcrf_tax_amount,0) rcrf_tax, --phdr.x_rcrf_tax_amount,
                               NVL(phdr.x_discount_amount,0) DISCOUNTS, --phdr.x_discount_amount,
                               NVL(phdr.x_tax_amount,0) SALES_TAX, --phdr.x_tax_amount,
                               NVL(phdr.x_amount,0)+ NVL(phdr.x_tax_amount,0) + NVL(phdr.x_e911_tax_amount,0) + NVL(phdr.x_usf_taxamount,0)+ NVL(phdr.x_rcrf_tax_amount,0) AMOUNT, --phdr.x_bill_amount,
                               phdr.purch_hdr2creditcard,
                               phdr.purch_hdr2bank_acct,
                               pdtl.X_ESN,
                               CASE
                                   WHEN phdr.x_rqst_date > SYSDATE
                                   THEN to_date(phdr.x_bill_request_time,'MM/dd/yyyy hh24:mi:ss')
                                   ELSE phdr.x_rqst_date
                               END TransactionDate,
                               CASE
                                   WHEN (phdr.x_rqst_type = 'CREDITCARD_PURCH' OR phdr.x_rqst_type = 'ACH_PURCH' OR phdr.x_rqst_type = 'LIFELINE_PURCH') THEN
                                         CASE
                                           WHEN (phdr.x_status LIKE 'CHARGEBACK%') THEN
                                            'Chargeback'
                                           WHEN ((phdr.x_ics_rcode = '1' OR phdr.x_ics_rcode = '100' OR phdr.x_ics_rcode IS NULL) AND phdr.x_status LIKE '%PENDING') THEN
                                            'Pending Response'
                                           WHEN (phdr.x_ics_rcode IS NULL) THEN
                                            'Pending Response'
                                           WHEN ((phdr.x_ics_rcode = '1' OR phdr.x_ics_rcode = '100')) THEN
                                            CASE
                                                 WHEN (phdr.x_ics_applications like '%ics_auth%' AND phdr.x_ics_applications like '%ics_score%' AND phdr.x_ics_applications like '%ics_bill%') THEN
                                                    'Approved'
                                                 WHEN (phdr.x_ics_applications like '%ics_auth%' AND phdr.x_ics_applications like '%ics_bill%') THEN
                                                    'Approved'
                                                 WHEN (phdr.x_ics_applications like '%ics_auth%' AND phdr.x_ics_applications like '%ics_score%') THEN
                                                    'Pre-Auth Approved'
                                                 WHEN (trim(phdr.x_ics_applications) = 'ics_auth') THEN
                                                    'Pre-Auth Approved'
                                                 WHEN (trim(phdr.x_ics_applications) = 'ecp_debit') THEN
                                                    'Approved'
                                                 WHEN (trim(phdr.x_ics_applications) = 'ics_credit' OR trim(phdr.x_ics_applications) = 'ecp_credit') THEN
                                                    'Refund Approved'
						 ELSE
						    'Processed'
                                              END
                                           WHEN (phdr.x_status LIKE 'SUBMITTED') THEN
                                            'Pending Response'
                                            WHEN (phdr.x_status LIKE 'INCOMPLETE') THEN
                                            'Incomplete'
                                           ELSE
                                            'Declined'
                                         END
                                   ELSE
                                         CASE
                                           WHEN (phdr.x_ics_rcode in ('1','100') or phdr.x_ics_rflag in ('SOK','ACCEPT') ) THEN
                                            'Refund Approved'
                                           ELSE
                                            'Refund Declined'
                                         END
                                END Status,
                               (SELECT pr.x_promo_sponsor
                                         FROM x_enroll_promo_grp2esn g2e
                                             ,x_enroll_promo_rule    pr
                                        WHERE pr.promo_objid = g2e.promo_objid
                                          AND SYSDATE BETWEEN g2e.x_start_date AND NVL(g2e.x_end_date,SYSDATE)
                                          AND g2e.x_esn = pdtl.x_esn
                                          AND ROWNUM < 2) x_promo_sponsor,
                               CASE
                                   WHEN (phdr.x_payment_type = 'REFUND') THEN
                                         'Refund for Original Transaction: ' || sa.billing_getpaymentdetails(phdr.purch_hdr2cr_purch)
                                   ELSE
                                         sa.billing_getpaymentdetails(phdr.objid)
                               END Details,
                               'Billing' payment_type,
                               (select u.s_login_name from table_user u where u.objid = phdr.purch_hdr2user) s_login_name,
                               --(select c.x_channel from sa.x_content_purch_dtl c where c.x_content2pgm_purch_hdr = phdr.objid and rownum < 2)
                               ' ' channel,
                               --(select c.CONTENT_PROVIDER from sa.x_content_purch_dtl c where c.x_content2pgm_purch_hdr = phdr.objid and rownum < 2)
                               ' '  vendor,
                               --(select c.X_ITEM_NAME from sa.x_content_purch_dtl c where c.x_content2pgm_purch_hdr = phdr.objid and rownum < 2)
                               ' ' product
                       from  x_program_purch_hdr phdr,
                             x_program_purch_dtl pdtl
                       where pdtl.pgm_purch_dtl2prog_hdr in (phdr.objid,phdr.purch_hdr2cr_purch)
                       AND phdr.x_payment_type != 'REDEBIT'
                       AND PHDR.X_AMOUNT IS NOT NULL
                       AND pdtl.X_ESN = ip_esn
      )
      loop
        get_purch_history_rslt := default_values_purch_hist_rec();
        get_purch_history_rslt.esn                        := rec.x_esn;
        if rec.purch_hdr2creditcard is not null
        then
           begin
              select substr(cc.x_customer_cc_number,-4) cc_lastfour,
                     cc.objid  cc_objid,
                     cc.x_cc_type
              into   get_purch_history_rslt.cc_lastfour,
                     get_purch_history_rslt.cc_objid,
                     get_purch_history_rslt.cc_type
              from   sa.table_x_credit_card cc
              where  cc.objid = rec.purch_hdr2creditcard;
           exception
              when others then null;
           end;
        end if;
        if rec.purch_hdr2bank_acct is not null
        then
           begin
              select substr(bank.x_customer_acct,-4) acct_lastfour,
                     bank.x_aba_transit,
                     bank.objid
              into   get_purch_history_rslt.acct_lastfour,
                     get_purch_history_rslt.aba_transit,
                     get_purch_history_rslt.ach_objid
              from   sa.table_x_bank_account bank
              where  bank.objid = rec.purch_hdr2bank_acct;
           exception
              when others then null;
           end;
        end if;
        get_purch_history_rslt.transaction_id             := rec.transaction_id;
        get_purch_history_rslt.price                      := rec.price;
        get_purch_history_rslt.discounts                  := rec.discounts;
        get_purch_history_rslt.sales_tax                  := rec.sales_tax;
        get_purch_history_rslt.e911_tax                   := rec.e911_tax;
        get_purch_history_rslt.usf_tax                    := rec.usf_tax;
        get_purch_history_rslt.rcrf_tax                   := rec.rcrf_tax;
        get_purch_history_rslt.amount                     := rec.amount;
        get_purch_history_rslt.transaction_date           := rec.transactiondate;
        get_purch_history_rslt.status                     := rec.status;
        get_purch_history_rslt.promo_sponsor              := rec.x_promo_sponsor;
        get_purch_history_rslt.details                    := rec.details;
        get_purch_history_rslt.payment_type               := rec.payment_type;
        get_purch_history_rslt.s_login_name               := rec.s_login_name;
        get_purch_history_rslt.channel                    := rec.channel;
        get_purch_history_rslt.vendor                     := rec.vendor;
        get_purch_history_rslt.product                    := rec.product;
        get_purch_history_rslt.group_id                   := sa.brand_x_pkg.get_account_group_id(ip_esn => rec.x_esn, ip_effective_date => rec.transactiondate);
        if get_purch_history_rslt.group_id is not null
        then
           begin
              select ag.account_group_name group_name
              into   get_purch_history_rslt.group_name
              from   sa.x_account_group ag
              where  ag.objid = to_number(get_purch_history_rslt.group_id);
           exception
              when others then null;
           end;
        end if;
        pipe row (get_purch_history_rslt);
      end loop;
--********************************************************************************************************************
-- END  Billing payments
--********************************************************************************************************************

--********************************************************************************************************************
-- BEGIN  APP payments
--********************************************************************************************************************
      for rec in (
                       select
                               phdr.x_merchant_ref_number transaction_id,
                               (nvl(phdr.x_amount,0)-nvl(phdr.x_discount_amount,0))  price,
                               NVL(phdr.x_e911_amount,0) e911_tax, --phdr.x_e911_amount x_e911_tax_amount,
                               NVL(phdr.x_usf_taxamount,0) usf_tax, --phdr.x_usf_taxamount,
                               NVL(phdr.x_rcrf_tax_amount,0) rcrf_tax, --phdr.x_rcrf_tax_amount,
                               NVL(phdr.x_discount_amount,0) DISCOUNTS, --phdr.x_discount_amount,
                               NVL(phdr.x_tax_amount,0) SALES_TAX, --phdr.x_tax_amount,
                               (nvl(phdr.x_amount,0)-nvl(phdr.x_discount_amount,0)) + NVL(phdr.x_tax_amount,0) + NVL(phdr.x_e911_amount,0) + NVL(phdr.x_usf_taxamount,0)+ NVL(phdr.x_rcrf_tax_amount,0) AMOUNT,
                               phdr.x_bill_amount,
                               phdr.x_purch_hdr2creditcard purch_hdr2creditcard,
                               phdr.x_purch_hdr2bank_acct purch_hdr2bank_acct,
                               phdr.x_esn,
                               CASE
                                   WHEN phdr.x_rqst_date > SYSDATE
                                   THEN to_date(phdr.x_bill_request_time,'MM/dd/yyyy hh24:mi:ss')
                                   ELSE phdr.x_rqst_date
                               END TransactionDate,
                               CASE
                                     WHEN phdr.x_rqst_type = 'cc_purch' THEN
                                         CASE
                                           WHEN ((phdr.x_ics_rcode = '1' OR phdr.x_ics_rcode = '100' OR phdr.x_ics_rcode IS NULL) AND phdr.x_ics_rflag LIKE '%Pending') THEN
                                           'Pending Response'
                                           WHEN (phdr.x_ics_rflag IS NULL OR phdr.x_ics_rflag LIKE '%Pending') THEN
                                           'Pending Response'
                                           WHEN (phdr.x_ics_rcode IN ('1','100')) THEN
                                            CASE
                                                 WHEN (phdr.x_ics_applications like '%ics_auth%' AND phdr.x_ics_applications like '%ics_score%' AND phdr.x_ics_applications like '%ics_bill%') THEN
                                                    'Approved'
                                                 WHEN (phdr.x_ics_applications like '%ics_auth%' AND phdr.x_ics_applications like '%ics_bill%') THEN
                                                    'Approved'
                                                 WHEN (phdr.x_ics_applications like '%ics_auth%' AND phdr.x_ics_applications like '%ics_score%') THEN
                                                    'Pre-Auth Approved'
                                                 WHEN (trim(phdr.x_ics_applications) = 'ics_auth') THEN
                                                    'Pre-Auth Approved'
                                                 WHEN (trim(phdr.x_ics_applications) = 'ecp_debit') THEN
                                                    'Approved'
                                                 WHEN (trim(phdr.x_ics_applications) = 'ics_credit' OR trim(phdr.x_ics_applications) = 'ecp_credit') THEN
                                                    'Refund Approved'
						 ELSE
						    'Processed'
                                              END
                                           WHEN (phdr.x_ics_rflag LIKE '%INCOMPLETE') THEN
											'InComplete'
                                           WHEN (phdr.x_ics_rcode NOT IN ('1','100')) THEN
                                            'Declined'
                                           ELSE
                                            ''
                                           END
                                        WHEN x_rqst_type = 'cc_refund' THEN
                                        CASE
                                        WHEN (phdr.x_ics_rcode in ('1','100') or phdr.x_ics_rflag in ('SOK','ACCEPT') ) THEN
                                             'Refund Approved'
                                             ELSE
                                             'Refund Declined'
                                           END
                               END Status,
                               '' x_promo_sponsor,
                               CASE
                                   WHEN (phdr.x_rqst_type = 'cc_refund') THEN
                                        'Airtime refund for $' || phdr.x_amount
                                  ELSE
                                        'Airtime purchase for $' || phdr.x_amount
                               END details,
                               'APP' payment_type,
                               (select u.s_login_name from table_user u where u.objid = phdr.x_purch_hdr2user) s_login_name,
                               NULL  channel,
                               NULL  vendor,
                               NULL  product,
                               phdr.x_rqst_source purch_source,
                               phdr.objid purch_objid
                       from  sa.table_x_purch_hdr phdr
                       where phdr.x_amount is not null
                       and   phdr.x_esn = ip_esn
      )
      loop
        get_purch_history_rslt := default_values_purch_hist_rec();
        get_purch_history_rslt.esn                        := rec.x_esn;
        if rec.purch_hdr2creditcard is not null
        then
           begin
              select substr(cc.x_customer_cc_number,-4) cc_lastfour,
                     cc.objid  cc_objid,
                     cc.x_cc_type
              into   get_purch_history_rslt.cc_lastfour,
                     get_purch_history_rslt.cc_objid,
                     get_purch_history_rslt.cc_type
              from   sa.table_x_credit_card cc
              where  cc.objid = rec.purch_hdr2creditcard;
           exception
              when others then null;
           end;
        end if;
        if rec.purch_hdr2bank_acct is not null
        then
           begin
              select substr(bank.x_customer_acct,-4) acct_lastfour,
                     bank.x_aba_transit,
                     bank.objid
              into   get_purch_history_rslt.acct_lastfour,
                     get_purch_history_rslt.aba_transit,
                     get_purch_history_rslt.ach_objid
              from   sa.table_x_bank_account bank
              where  bank.objid = rec.purch_hdr2bank_acct;
           exception
              when others then null;
           end;
        end if;
        get_purch_history_rslt.transaction_id             := rec.transaction_id;
        get_purch_history_rslt.price                      := rec.price;
        get_purch_history_rslt.discounts                  := rec.discounts;
        get_purch_history_rslt.sales_tax                  := rec.sales_tax;
        get_purch_history_rslt.e911_tax                   := rec.e911_tax;
        get_purch_history_rslt.usf_tax                    := rec.usf_tax;
        get_purch_history_rslt.rcrf_tax                   := rec.rcrf_tax;
        get_purch_history_rslt.amount                     := rec.amount;
        get_purch_history_rslt.transaction_date           := rec.transactiondate;
        get_purch_history_rslt.status                     := rec.status;
        get_purch_history_rslt.promo_sponsor              := rec.x_promo_sponsor;
        get_purch_history_rslt.details                    := get_purch_part_number_desc(rec.purch_objid, rec.transactiondate, rec.purch_source);
        if (get_purch_history_rslt.details is null) then
           get_purch_history_rslt.details                    := rec.details;
        end if;
        get_purch_history_rslt.payment_type               := rec.payment_type;
        get_purch_history_rslt.s_login_name               := rec.s_login_name;
        get_purch_history_rslt.channel                    := rec.channel;
        get_purch_history_rslt.vendor                     := rec.vendor;
        get_purch_history_rslt.product                    := rec.product;
        get_purch_history_rslt.group_id                   := sa.brand_x_pkg.get_account_group_id(ip_esn => rec.x_esn, ip_effective_date => rec.transactiondate);
        if get_purch_history_rslt.group_id is not null
        then
           begin
              select ag.account_group_name group_name
              into   get_purch_history_rslt.group_name
              from   sa.x_account_group ag
              where  ag.objid = to_number(get_purch_history_rslt.group_id);
           exception
              when others then null;
           end;
        end if;

        pipe row (get_purch_history_rslt);
      end loop;
--********************************************************************************************************************
-- END  APP payments
--********************************************************************************************************************
      /* CR29021 Safelink e911 changes starts  moneygram transactions*/
      for rec in (
            select
              mg.x_esn                  as x_esn,
              null                      as cc_lastfour,
              null                      as acct_lastfour,
              null                      as cc_objid,
              null                      as x_cc_type,
              mg.x_vendor_name          as x_aba_transit,
              mg.x_mg_reference_number  as transaction_id,
              nvl(mg.x_bill_amount,0)   as price,
              0                         as discounts,
              0                         as sales_tax,
              0                         as e911_tax,
              0                         as usf_tax,
              0                         as rcrf_tax,
              nvl(mg.x_bill_amount,0)   as amount,
              mg.x_date_trans           as transactiondate,
              mg.x_status               as status,
              null                      as x_promo_sponsor,
              ML.X_DESCRIPTION ||' Payment through ' || mg.x_vendor_name AS DETAILS, -- CR39488
              --'Safelink E911 Fee Payment through ' || mg.x_vendor_name as details,
              mg.x_vendor_name          as payment_type,
              null                      as s_login_name,
              mg.x_rqst_type            as channel,
              mg.x_vendor_name          as vendor,
              ML.x_part_number          as product -- CR39488
              --'Safelink E911 Fee'       as product
              --x_lid                     as lid
            from x_mg_transactions mg,
            X_MONEYGRAM_LOOKUP ml
            where 1=1
            and mg.X_Paycode = ml.X_Paycode
            --and mg.x_paycode = '68974165' --  <= this paycode is for Safelink e911
            and mg.x_esn = ip_esn
      )
      loop
        get_purch_history_rslt := default_values_purch_hist_rec();
        get_purch_history_rslt.esn                        := rec.x_esn;
        get_purch_history_rslt.cc_lastfour                := rec.cc_lastfour;
        get_purch_history_rslt.acct_lastfour              := rec.acct_lastfour;
        get_purch_history_rslt.cc_objid                   := rec.cc_objid;
        get_purch_history_rslt.cc_type                    := rec.x_cc_type;
        get_purch_history_rslt.aba_transit                := rec.x_aba_transit;
        get_purch_history_rslt.ach_objid                  := null;
        get_purch_history_rslt.transaction_id             := rec.transaction_id;
        get_purch_history_rslt.price                      := rec.price;
        get_purch_history_rslt.discounts                  := rec.discounts;
        get_purch_history_rslt.sales_tax                  := rec.sales_tax;
        get_purch_history_rslt.e911_tax                   := rec.e911_tax;
        get_purch_history_rslt.usf_tax                    := rec.usf_tax;
        get_purch_history_rslt.rcrf_tax                   := rec.rcrf_tax;
        get_purch_history_rslt.amount                     := rec.amount;
        get_purch_history_rslt.transaction_date           := rec.transactiondate;
        get_purch_history_rslt.status                     := rec.status;
        get_purch_history_rslt.promo_sponsor              := rec.x_promo_sponsor;
        get_purch_history_rslt.details                    := rec.details;
        get_purch_history_rslt.payment_type               := rec.payment_type;
        get_purch_history_rslt.s_login_name               := rec.s_login_name;
        get_purch_history_rslt.channel                    := rec.channel;
        get_purch_history_rslt.vendor                     := rec.vendor;
        get_purch_history_rslt.product                    := rec.product;
        get_purch_history_rslt.group_id                   := '';
        get_purch_history_rslt.group_name                 := '';

        pipe row (get_purch_history_rslt);
      end loop;

      /* CR29021 Safelink e911 changes starts checks transactions */
      for rec in (
            select
              checks.esn                as x_esn,
              null                      as cc_lastfour,
              null                      as acct_lastfour,
              null                      as cc_objid,
              null                      as x_cc_type,
              ''                        as x_aba_transit,
              checks.cash_receipt_id    as transaction_id,
              nvl(checks.check_amount,0)   as price,
              0                         as discounts,
              0                         as sales_tax,
              0                         as e911_tax,
              0                         as usf_tax,
              0                         as rcrf_tax,
              nvl(checks.check_amount,0)   as amount,
              checks.receipt_date       as transactiondate,
              case
              when checks.returned is not null
              then 'Returned'
              else 'Received'
              end                       as status,
              null                      as x_promo_sponsor,
              'Safelink E911 Fee Payment through ' || checks.payment_type as details,
              checks.payment_type       as payment_type,
              null                      as s_login_name,
              null                      as channel,
              null                      as vendor,
              'Safelink E911 Fee'       as product
              --checks.llid                     as lid
            from sa.xxtf_e911_tax_recon_tbl checks
            where 1=1
            and checks.esn = ip_esn
      )
      loop
        get_purch_history_rslt := default_values_purch_hist_rec();
        get_purch_history_rslt.esn                        := rec.x_esn;
        get_purch_history_rslt.cc_lastfour                := rec.cc_lastfour;
        get_purch_history_rslt.acct_lastfour              := rec.acct_lastfour;
        get_purch_history_rslt.cc_objid                   := rec.cc_objid;
        get_purch_history_rslt.cc_type                    := rec.x_cc_type;
        get_purch_history_rslt.aba_transit                := rec.x_aba_transit;
        get_purch_history_rslt.ach_objid                  := null;
        get_purch_history_rslt.transaction_id             := rec.transaction_id;
        get_purch_history_rslt.price                      := rec.price;
        get_purch_history_rslt.discounts                  := rec.discounts;
        get_purch_history_rslt.sales_tax                  := rec.sales_tax;
        get_purch_history_rslt.e911_tax                   := rec.e911_tax;
        get_purch_history_rslt.usf_tax                    := rec.usf_tax;
        get_purch_history_rslt.rcrf_tax                   := rec.rcrf_tax;
        get_purch_history_rslt.amount                     := rec.amount;
        get_purch_history_rslt.transaction_date           := rec.transactiondate;
        get_purch_history_rslt.status                     := rec.status;
        get_purch_history_rslt.promo_sponsor              := rec.x_promo_sponsor;
        get_purch_history_rslt.details                    := rec.details;
        get_purch_history_rslt.payment_type               := rec.payment_type;
        get_purch_history_rslt.s_login_name               := rec.s_login_name;
        get_purch_history_rslt.channel                    := rec.channel;
        get_purch_history_rslt.vendor                     := rec.vendor;
        get_purch_history_rslt.product                    := rec.product;
        get_purch_history_rslt.group_id                   := '';
        get_purch_history_rslt.group_name                 := '';

        pipe row (get_purch_history_rslt);
      end loop;
      /* CR29021 Safelink e911 changes ends */
      return;
  end get_purch_history_by_esn;

--********************************************************************************************************************
  --SELECT *
  --FROM table(sa.ADFCRM_VO.get_purch_history_by_acct(ip_contact_objid))
  -- uc060
  function get_purch_history_by_acct (ip_contact_objid in varchar2)
  return get_purch_history_tab pipelined
  is
      get_purch_history_rslt get_purch_history_rec;
  begin
      get_purch_history_rslt := default_values_purch_hist_rec();
      for rec in (
                select purch.X_ESN,
                       substr(cc.x_customer_cc_number,-4) cc_lastfour,
                       substr(bank.x_customer_acct,-4) acct_lastfour,
                       nvl(cc.objid,bank.objid)  cc_objid,
                       cc.x_cc_type,
                       bank.x_aba_transit,
                       bank.objid bank_objid,
                       purch.x_merchant_ref_number transaction_id,
                       NVL(purch.x_amount,0) price,
                       NVL(purch.x_discount_amount,0) DISCOUNTS,
                       NVL(purch.x_tax_amount,0) SALES_TAX,
                       NVL(purch.x_e911_tax_amount,0) e911_tax,
                       NVL(purch.x_usf_taxamount,0) usf_tax,
                       NVL(purch.x_rcrf_tax_amount,0) rcrf_tax,
                       NVL(purch.x_amount,0)+ NVL(purch.x_tax_amount,0) + NVL(purch.x_e911_tax_amount,0) + NVL(purch.x_usf_taxamount,0)+ NVL(purch.x_rcrf_tax_amount,0) AMOUNT,
                       TransactionDate,
                       purch.status,
                       purch.x_promo_sponsor,
                       purch.details,
                       purch.payment_type,
                       purch.s_login_name,
                       purch.channel  channel,
                       purch.vendor   vendor,
                       purch.product  product
                from   sa.table_x_credit_card cc,
                       sa.table_x_bank_account bank,
                       (select phdr.x_merchant_ref_number,
                               phdr.x_amount,
                               phdr.x_e911_tax_amount,
                               phdr.x_usf_taxamount,
                               phdr.x_rcrf_tax_amount,
                               phdr.x_discount_amount,
                               phdr.x_tax_amount,
                               phdr.x_bill_amount,
                               phdr.purch_hdr2creditcard,
                               phdr.purch_hdr2bank_acct,
                               pdtl.X_ESN,
                               CASE
                                   WHEN phdr.x_rqst_date > SYSDATE
                                   THEN to_date(phdr.x_bill_request_time,'MM/dd/yyyy hh24:mi:ss')
                                   ELSE phdr.x_rqst_date
                               END TransactionDate,
                               CASE
                                   WHEN (phdr.x_rqst_type = 'CREDITCARD_PURCH' OR phdr.x_rqst_type = 'ACH_PURCH' OR phdr.x_rqst_type = 'LIFELINE_PURCH') THEN
                                         CASE
                                           WHEN (phdr.x_status LIKE 'CHARGEBACK%') THEN
                                            'Chargeback'
                                           WHEN ((phdr.x_ics_rcode = '1' OR phdr.x_ics_rcode = '100' OR phdr.x_ics_rcode IS NULL) AND phdr.x_status LIKE '%PENDING') THEN
                                            'Pending Response'
                                           WHEN (phdr.x_ics_rcode IS NULL) THEN
                                            'Pending Response'
                                           WHEN ((phdr.x_ics_rcode = '1' OR phdr.x_ics_rcode = '100')) THEN
                                            'Approved'
                                           WHEN (phdr.x_status LIKE 'SUBMITTED') THEN
                                            'Pending Response'
                                            WHEN (phdr.x_status LIKE 'INCOMPLETE') THEN
                                            'Incomplete'
                                           ELSE
                                            'Declined'
                                         END
                                   ELSE
                                         CASE
                                           WHEN (phdr.x_ics_rcode in ('1','100') or phdr.x_ics_rflag in ('SOK','ACCEPT') ) THEN
                                            'Refund Approved'
                                           ELSE
                                            'Refund Declined'
                                         END
                                END Status,
                               (SELECT pr.x_promo_sponsor
                                         FROM x_enroll_promo_grp2esn g2e
                                             ,x_enroll_promo_rule    pr
                                        WHERE pr.promo_objid = g2e.promo_objid
                                          AND SYSDATE BETWEEN g2e.x_start_date AND NVL(g2e.x_end_date,SYSDATE)
                                          AND g2e.x_esn = pdtl.x_esn
                                          AND ROWNUM < 2) x_promo_sponsor,
                               CASE
                                   WHEN (phdr.x_payment_type = 'REFUND') THEN
                                         'Refund for Original Transaction: ' || sa.billing_getpaymentdetails(phdr.purch_hdr2cr_purch)
                                   ELSE
                                         sa.billing_getpaymentdetails(phdr.objid)
                               END Details,
                               'Billing' payment_type,
                               u.s_login_name,
                               --(select c.x_channel from sa.x_content_purch_dtl c where c.x_content2pgm_purch_hdr = phdr.objid and rownum < 2)
                               ' ' channel,
                               --(select c.CONTENT_PROVIDER from sa.x_content_purch_dtl c where c.x_content2pgm_purch_hdr = phdr.objid and rownum < 2)
                               ' '  vendor,
                               --(select c.X_ITEM_NAME from sa.x_content_purch_dtl c where c.x_content2pgm_purch_hdr = phdr.objid and rownum < 2)
                               ' ' product
                       from  x_program_purch_hdr phdr,
                             x_program_purch_dtl pdtl,
                             (select  pi.part_serial_no
                             from    sa.table_web_user            web,
                                     sa.table_x_contact_part_inst cpi,
                                     sa.TABLE_PART_INST           PI
                             WHERE WEB.WEB_USER2CONTACT = ip_contact_objid
                             AND   CPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT
                             AND   pi.objid = cpi.x_contact_part_inst2part_inst
                             union
                             select  pi.part_serial_no
                             from    sa.TABLE_PART_INST           PI
                             where   pi.x_part_inst2contact = ip_contact_objid
                             ) acc_esns,
                             x_program_enrolled pe,
                             table_user u
                       where pdtl.pgm_purch_dtl2prog_hdr in (phdr.objid,phdr.purch_hdr2cr_purch)
                       AND phdr.x_payment_type != 'REDEBIT'
                       AND PHDR.X_AMOUNT IS NOT NULL
                       AND PE.X_ESN = acc_esns.part_serial_no
                       AND PDTL.PGM_PURCH_DTL2PGM_ENROLLED = PE.OBJID
                       AND pdtl.X_ESN = PE.X_ESN
                       AND u.objid (+) = phdr.purch_hdr2user
                       ) purch
                where cc.objid (+)= purch.purch_hdr2creditcard
                and  bank.objid (+) = purch.purch_hdr2bank_acct
                ORDER BY TRANSACTIONDATE DESC
      )
      loop
        get_purch_history_rslt := default_values_purch_hist_rec();
        get_purch_history_rslt.esn                        := rec.x_esn;
        get_purch_history_rslt.cc_lastfour                := rec.cc_lastfour;
        get_purch_history_rslt.acct_lastfour              := rec.acct_lastfour;
        get_purch_history_rslt.cc_objid                   := rec.cc_objid;
        get_purch_history_rslt.cc_type                    := rec.x_cc_type;
        get_purch_history_rslt.aba_transit                := rec.x_aba_transit;
        get_purch_history_rslt.ach_objid                  := rec.bank_objid;
        get_purch_history_rslt.transaction_id             := rec.transaction_id;
        get_purch_history_rslt.price                      := rec.price;
        get_purch_history_rslt.discounts                  := rec.discounts;
        get_purch_history_rslt.sales_tax                  := rec.sales_tax;
        get_purch_history_rslt.e911_tax                   := rec.e911_tax;
        get_purch_history_rslt.usf_tax                    := rec.usf_tax;
        get_purch_history_rslt.rcrf_tax                   := rec.rcrf_tax;
        get_purch_history_rslt.amount                     := rec.amount;
        get_purch_history_rslt.transaction_date           := rec.transactiondate;
        get_purch_history_rslt.status                     := rec.status;
        get_purch_history_rslt.promo_sponsor              := rec.x_promo_sponsor;
        get_purch_history_rslt.details                    := rec.details;
        get_purch_history_rslt.payment_type               := rec.payment_type;
        get_purch_history_rslt.s_login_name               := rec.s_login_name;
        get_purch_history_rslt.channel                    := rec.channel;
        get_purch_history_rslt.vendor                     := rec.vendor;
        get_purch_history_rslt.product                    := rec.product;
        get_purch_history_rslt.group_id                   := '';
        get_purch_history_rslt.group_name                 := '';

        pipe row (get_purch_history_rslt);
      end loop;

      for rec in (
                select purch.X_ESN,
                       substr(cc.x_customer_cc_number,-4) cc_lastfour,
                       substr(bank.x_customer_acct,-4) acct_lastfour,
                       nvl(cc.objid,bank.objid)  cc_objid,
                       cc.x_cc_type,
                       bank.x_aba_transit,
                       bank.objid bank_objid,
                       purch.x_merchant_ref_number transaction_id,
                       NVL(purch.x_amount,0) price,
                       NVL(purch.x_discount_amount,0) DISCOUNTS,
                       NVL(purch.x_tax_amount,0) SALES_TAX,
                       NVL(purch.x_e911_tax_amount,0) e911_tax,
                       NVL(purch.x_usf_taxamount,0) usf_tax,
                       NVL(purch.x_rcrf_tax_amount,0) rcrf_tax,
                       NVL(purch.x_amount,0)+ NVL(purch.x_tax_amount,0) + NVL(purch.x_e911_tax_amount,0) + NVL(purch.x_usf_taxamount,0)+ NVL(purch.x_rcrf_tax_amount,0) AMOUNT,
                       TransactionDate,
                       purch.status,
                       purch.x_promo_sponsor,
                       purch.details,
                       purch.payment_type,
                       purch.s_login_name,
                       purch.channel  channel,
                       purch.vendor   vendor,
                       purch.product  product,
                       purch.purch_source  purch_source,
                       purch.purch_objid   purch_objid
                from   sa.table_x_credit_card cc,
                       sa.table_x_bank_account bank,
                       (
                       select  phdr.x_merchant_ref_number,
                               (phdr.x_amount-nvl(phdr.x_discount_amount,0))  x_amount,
                               phdr.x_e911_amount x_e911_tax_amount,
                               phdr.x_usf_taxamount,
                               phdr.x_rcrf_tax_amount,
                               phdr.x_discount_amount,
                               phdr.x_tax_amount,
                               phdr.x_bill_amount,
                               phdr.x_purch_hdr2creditcard purch_hdr2creditcard,
                               phdr.x_purch_hdr2bank_acct purch_hdr2bank_acct,
                               phdr.x_esn,
                               CASE
                                   WHEN phdr.x_rqst_date > SYSDATE
                                   THEN to_date(phdr.x_bill_request_time,'MM/dd/yyyy hh24:mi:ss')
                                   ELSE phdr.x_rqst_date
                               END TransactionDate,
                               CASE
                                     WHEN phdr.x_rqst_type = 'cc_purch' THEN
                                         CASE
                                           WHEN ((phdr.x_ics_rcode = '1' OR phdr.x_ics_rcode = '100' OR phdr.x_ics_rcode IS NULL) AND phdr.x_ics_rflag LIKE '%Pending') THEN
                                           'Pending Response'
                                           WHEN (phdr.x_ics_rflag IS NULL OR phdr.x_ics_rflag LIKE '%Pending') THEN
                                           'Pending Response'
                                           WHEN (phdr.x_ics_rcode IN ('1'
                                                    ,'100')) THEN
                                                                   'Approved'
                                                                   WHEN (phdr.x_ics_rflag LIKE '%INCOMPLETE') THEN
                                           'InComplete'
                                           WHEN (phdr.x_ics_rcode NOT IN ('1'
                                                        ,'100')) THEN
                                                                       'Declined'
                                                                       ELSE
                                           ''
                                           END
                                         WHEN x_rqst_type = 'cc_refund' THEN
                                           CASE
                                             WHEN (phdr.x_ics_rcode in ('1','100') or phdr.x_ics_rflag in ('SOK','ACCEPT') ) THEN
                                             'Refund Approved'
                                             ELSE
                                             'Refund Declined'
                                           END
                               END Status,
                               '' x_promo_sponsor,
                               CASE
                                   WHEN (phdr.x_rqst_type = 'cc_refund') THEN
                                        'Airtime refund for $' || phdr.x_amount
                                   ELSE
                                        'Airtime purchase for $' || phdr.x_amount
                               END details,
                               'APP' payment_type,
                               U.S_LOGIN_NAME,
                               NULL  channel,
                               NULL  vendor,
                               NULL  product,
                               phdr.x_rqst_source purch_source,
                               phdr.objid purch_objid
                       from  sa.table_x_purch_hdr phdr,
                             (select  pi.x_part_inst2contact
                             from    sa.table_web_user            web,
                                     sa.table_x_contact_part_inst cpi,
                                     sa.TABLE_PART_INST           PI
                             WHERE WEB.WEB_USER2CONTACT = ip_contact_objid
                             AND   CPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT
                             AND   PI.OBJID = CPI.X_CONTACT_PART_INST2PART_INST
                             UNION
                             select to_number(nvl(ip_contact_objid,-1)) from dual
                             ) acc_contacts,
                             table_user u
                       WHERE PHDR.X_AMOUNT IS NOT NULL
                       and   phdr.X_PURCH_HDR2CONTACT = acc_contacts.x_part_inst2contact
                       and   u.objid (+) = phdr.x_purch_hdr2user
                       ) purch
                where cc.objid (+)= purch.purch_hdr2creditcard
                and  bank.objid (+) = purch.purch_hdr2bank_acct
                ORDER BY TRANSACTIONDATE DESC
      )
      loop
        get_purch_history_rslt := default_values_purch_hist_rec();
        get_purch_history_rslt.esn                        := rec.x_esn;
        get_purch_history_rslt.cc_lastfour                := rec.cc_lastfour;
        get_purch_history_rslt.acct_lastfour              := rec.acct_lastfour;
        get_purch_history_rslt.cc_objid                   := rec.cc_objid;
        get_purch_history_rslt.cc_type                    := rec.x_cc_type;
        get_purch_history_rslt.aba_transit                := rec.x_aba_transit;
        get_purch_history_rslt.ach_objid                  := rec.bank_objid;
        get_purch_history_rslt.transaction_id             := rec.transaction_id;
        get_purch_history_rslt.price                      := rec.price;
        get_purch_history_rslt.discounts                  := rec.discounts;
        get_purch_history_rslt.sales_tax                  := rec.sales_tax;
        get_purch_history_rslt.e911_tax                   := rec.e911_tax;
        get_purch_history_rslt.usf_tax                    := rec.usf_tax;
        get_purch_history_rslt.rcrf_tax                   := rec.rcrf_tax;
        get_purch_history_rslt.amount                     := rec.amount;
        get_purch_history_rslt.transaction_date           := rec.transactiondate;
        get_purch_history_rslt.status                     := rec.status;
        get_purch_history_rslt.promo_sponsor              := rec.x_promo_sponsor;
        get_purch_history_rslt.details                    := get_purch_part_number_desc(rec.purch_objid, rec.transactiondate, rec.purch_source);
        if (get_purch_history_rslt.details is null) then
           get_purch_history_rslt.details                    := rec.details;
        end if;
        get_purch_history_rslt.payment_type               := rec.payment_type;
        get_purch_history_rslt.s_login_name               := rec.s_login_name;
        get_purch_history_rslt.channel                    := rec.channel;
        get_purch_history_rslt.vendor                     := rec.vendor;
        get_purch_history_rslt.product                    := rec.product;
        get_purch_history_rslt.group_id                   := '';
        get_purch_history_rslt.group_name                 := '';

        pipe row (get_purch_history_rslt);
      end loop;

      /* CR29021 Safelink e911 changes starts moneygram transactions */
      for rec in (
            select
              mg.x_esn                  as x_esn,
              null                      as cc_lastfour,
              null                      as acct_lastfour,
              null                      as cc_objid,
              null                      as x_cc_type,
              mg.x_vendor_name          as x_aba_transit,
              mg.x_mg_reference_number  as transaction_id,
              nvl(mg.x_bill_amount,0)   as price,
              0                         as discounts,
              0                         as sales_tax,
              0                         as e911_tax,
              0                         as usf_tax,
              0                         as rcrf_tax,
              nvl(mg.x_bill_amount,0)   as amount,
              mg.x_date_trans           as transactiondate,
              mg.x_status               as status,
              null                      as x_promo_sponsor,
              'Safelink E911 Fee Payment through ' || mg.x_vendor_name as details,
              mg.x_vendor_name          as payment_type,
              null                      as s_login_name,
              mg.x_rqst_type            as channel,
              mg.x_vendor_name          as vendor,
              'Safelink E911 Fee'       as product
              --x_lid                     as lid
            from x_mg_transactions mg
            where 1=1
            --and mg.x_paycode = '68974165' --  <= this paycode is for Safelink e911
            and mg.x_esn in (
                select  pi.part_serial_no ---pi.x_part_inst2contact
                from    sa.table_web_user            web,
                        sa.table_x_contact_part_inst cpi,
                        sa.table_part_inst           pi
                where web.web_user2contact = ip_contact_objid
                and   cpi.x_contact_part_inst2contact = web.web_user2contact
                and   pi.objid = cpi.x_contact_part_inst2part_inst
                        )
            order by mg.x_date_trans
      )
      loop
        get_purch_history_rslt := default_values_purch_hist_rec();
        get_purch_history_rslt.esn                        := rec.x_esn;
        get_purch_history_rslt.cc_lastfour                := rec.cc_lastfour;
        get_purch_history_rslt.acct_lastfour              := rec.acct_lastfour;
        get_purch_history_rslt.cc_objid                   := rec.cc_objid;
        get_purch_history_rslt.cc_type                    := rec.x_cc_type;
        get_purch_history_rslt.aba_transit                := rec.x_aba_transit;
        get_purch_history_rslt.ach_objid                  := null;
        get_purch_history_rslt.transaction_id             := rec.transaction_id;
        get_purch_history_rslt.price                      := rec.price;
        get_purch_history_rslt.discounts                  := rec.discounts;
        get_purch_history_rslt.sales_tax                  := rec.sales_tax;
        get_purch_history_rslt.e911_tax                   := rec.e911_tax;
        get_purch_history_rslt.usf_tax                    := rec.usf_tax;
        get_purch_history_rslt.rcrf_tax                   := rec.rcrf_tax;
        get_purch_history_rslt.amount                     := rec.amount;
        get_purch_history_rslt.transaction_date           := rec.transactiondate;
        get_purch_history_rslt.status                     := rec.status;
        get_purch_history_rslt.promo_sponsor              := rec.x_promo_sponsor;
        get_purch_history_rslt.details                    := rec.details;
        get_purch_history_rslt.payment_type               := rec.payment_type;
        get_purch_history_rslt.s_login_name               := rec.s_login_name;
        get_purch_history_rslt.channel                    := rec.channel;
        get_purch_history_rslt.vendor                     := rec.vendor;
        get_purch_history_rslt.product                    := rec.product;
        get_purch_history_rslt.group_id                   := '';
        get_purch_history_rslt.group_name                 := '';

        pipe row (get_purch_history_rslt);
      end loop;

      /* CR29021 Safelink e911 changes starts checks transactions */
      for rec in (
            select
              checks.esn                as x_esn,
              null                      as cc_lastfour,
              null                      as acct_lastfour,
              null                      as cc_objid,
              null                      as x_cc_type,
              ''                        as x_aba_transit,
              checks.cash_receipt_id    as transaction_id,
              nvl(checks.check_amount,0)   as price,
              0                         as discounts,
              0                         as sales_tax,
              0                         as e911_tax,
              0                         as usf_tax,
              0                         as rcrf_tax,
              nvl(checks.check_amount,0)   as amount,
              checks.receipt_date       as transactiondate,
              case
              when checks.returned is not null
              then 'Returned'
              else 'Received'
              end                       as status,
              null                      as x_promo_sponsor,
              'Safelink E911 Fee Payment through ' || checks.payment_type as details,
              checks.payment_type       as payment_type,
              null                      as s_login_name,
              null                      as channel,
              null                      as vendor,
              'Safelink E911 Fee'       as product
              --checks.llid                     as lid
            from sa.xxtf_e911_tax_recon_tbl checks
            where 1=1
            --and mg.x_paycode = '68974165' --  <= this paycode is for Safelink e911
            and checks.esn in (
                select  pi.part_serial_no ---pi.x_part_inst2contact
                from    sa.table_web_user            web,
                        sa.table_x_contact_part_inst cpi,
                        sa.table_part_inst           pi
                where web.web_user2contact = ip_contact_objid
                and   cpi.x_contact_part_inst2contact = web.web_user2contact
                and   pi.objid = cpi.x_contact_part_inst2part_inst
                        )
      )
      loop
        get_purch_history_rslt := default_values_purch_hist_rec();
        get_purch_history_rslt.esn                        := rec.x_esn;
        get_purch_history_rslt.cc_lastfour                := rec.cc_lastfour;
        get_purch_history_rslt.acct_lastfour              := rec.acct_lastfour;
        get_purch_history_rslt.cc_objid                   := rec.cc_objid;
        get_purch_history_rslt.cc_type                    := rec.x_cc_type;
        get_purch_history_rslt.aba_transit                := rec.x_aba_transit;
        get_purch_history_rslt.ach_objid                  := null;
        get_purch_history_rslt.transaction_id             := rec.transaction_id;
        get_purch_history_rslt.price                      := rec.price;
        get_purch_history_rslt.discounts                  := rec.discounts;
        get_purch_history_rslt.sales_tax                  := rec.sales_tax;
        get_purch_history_rslt.e911_tax                   := rec.e911_tax;
        get_purch_history_rslt.usf_tax                    := rec.usf_tax;
        get_purch_history_rslt.rcrf_tax                   := rec.rcrf_tax;
        get_purch_history_rslt.amount                     := rec.amount;
        get_purch_history_rslt.transaction_date           := rec.transactiondate;
        get_purch_history_rslt.status                     := rec.status;
        get_purch_history_rslt.promo_sponsor              := rec.x_promo_sponsor;
        get_purch_history_rslt.details                    := rec.details;
        get_purch_history_rslt.payment_type               := rec.payment_type;
        get_purch_history_rslt.s_login_name               := rec.s_login_name;
        get_purch_history_rslt.channel                    := rec.channel;
        get_purch_history_rslt.vendor                     := rec.vendor;
        get_purch_history_rslt.product                    := rec.product;
        get_purch_history_rslt.group_id                   := '';
        get_purch_history_rslt.group_name                 := '';

        pipe row (get_purch_history_rslt);
      end loop;
      /* CR29021 Safelink e911 changes ends */

      return;
  end get_purch_history_by_acct;

  function get_esn_contact_flashes (ip_esn in varchar2)
  return get_esn_contact_flashes_tab pipelined
  is
    title varchar2(200);
    alert_text    clob;
    eng_text      table_alert.x_web_text_english%type;
    spa_text      table_alert.x_web_text_spanish%type;
    ivr_scr_id    table_alert.X_IVR_SCRIPT_ID%type;
    tts_english   table_alert.x_tts_english%type;
    tts_spanish   table_alert.x_tts_spanish%type;
    hot           varchar2(200);
    err           varchar2(500);
    msg           varchar2(100);
  --*** This table function is called from uc245 ***
    get_esn_contact_flashes_rslt get_esn_contact_flashes_rec;
  begin

    sa.alert_pkg.get_alert(esn => ip_esn,
                        step => '0',
                        channel => 'TAS', --CR35705 - Configure Flashes Individually per Channel
                        title => title,
                        csr_text => alert_text,
                        eng_text => eng_text,
                        spa_text => spa_text,
                        ivr_scr_id => ivr_scr_id,
                        tts_english => tts_english,
                        tts_spanish => tts_spanish,
                        hot => hot,
                        err => err,
                        msg => msg);

    if title is not null then
      get_esn_contact_flashes_rslt.part_serial_no := ip_esn;
      get_esn_contact_flashes_rslt.objid := -1;
      get_esn_contact_flashes_rslt.title := title;
      get_esn_contact_flashes_rslt.alert_text := alert_text;
      get_esn_contact_flashes_rslt.hot := hot;
      get_esn_contact_flashes_rslt.flash_src := 'alert_pkg.get_alert';
      pipe row (get_esn_contact_flashes_rslt);
    end if;

    for esn_rec in (select a.title,a.alert_text,a.hot,a.alert2contract,a.objid alert_objid
                    from   sa.table_alert a,
                           sa.table_part_inst pi
                    where 1=1
                    and a.active = 1
                    and a.alert2contract = pi.objid
                    and pi.part_serial_no = ip_esn
                    and a.start_date < sysdate
                    and a.end_date > sysdate)
    loop
      if title is null or esn_rec.title != title then -- PREVENT DUPLICATES FROM THE PROCEDURE
        get_esn_contact_flashes_rslt.part_serial_no := ip_esn;
        get_esn_contact_flashes_rslt.title := esn_rec.title;
        get_esn_contact_flashes_rslt.alert_text := esn_rec.alert_text;
        get_esn_contact_flashes_rslt.hot := esn_rec.hot;
        get_esn_contact_flashes_rslt.objid := esn_rec.alert_objid;
        get_esn_contact_flashes_rslt.flash_src := 'esn_rec';
        pipe row (get_esn_contact_flashes_rslt);
      end if;
    end loop;
    return;
  end get_esn_contact_flashes;
--********************************************************************************************************************
  function F_GET_REWARD_BENEFITS (
             IN_KEY                     IN VARCHAR2
            ,IN_VALUE                   IN VARCHAR2
            ,IN_PROGRAM_NAME            IN VARCHAR2
            ,IN_BENEFIT_TYPE            IN VARCHAR2 )
  return REWARD_BENEFITS_TAB pipelined
  is
     OUT_REWARD_BENEFITS_LIST REWARD_BENEFITS_TAB;
     OUT_ERR_CODE  NUMBER;
     OUT_ERR_MSG   VARCHAR2(10000);
  begin
      sa.REWARD_BENEFITS_N_VOUCHERS_PKG.P_GET_REWARD_BENEFITS (
                 IN_KEY => IN_KEY
                ,IN_VALUE => IN_VALUE
                ,IN_PROGRAM_NAME => IN_PROGRAM_NAME
                ,IN_BENEFIT_TYPE => IN_BENEFIT_TYPE
                ,OUT_REWARD_BENEFITS_LIST => OUT_REWARD_BENEFITS_LIST
                ,OUT_ERR_CODE => OUT_ERR_CODE
                ,OUT_ERR_MSG => OUT_ERR_MSG
      );
     FOR indx IN OUT_REWARD_BENEFITS_LIST.FIRST .. OUT_REWARD_BENEFITS_LIST.LAST
     LOOP
         pipe row (OUT_REWARD_BENEFITS_LIST(indx));
     END LOOP;
     return;
  exception
    when others then
     return;
  end F_GET_REWARD_BENEFITS;

--********************************************************************************************************************
  --CR32952 new function default_values_program and  getEligibleWtyPrograms
--********************************************************************************************************************
    function default_values_program
    return get_program_rec
    is
       get_program_rslt get_program_rec;
    begin
       get_program_rslt.objid                  := 0;
       get_program_rslt.x_program_name         := '';
       get_program_rslt.x_program_desc         := '';
       get_program_rslt.x_retail_price         := 0;
       get_program_rslt.x_prg_script_text      := null;
       get_program_rslt.x_prg_desc_script_text := null;

       return get_program_rslt;
    end default_values_program;

  function getEligibleWtyPrograms (
    ip_esn in varchar2,
    ip_language in varchar2 -- EN ES
  )
  return get_program_tab pipelined
  is
     p_language varchar2(100);
     get_program_rslt get_program_rec;
  begin
      p_language := get_language(ip_language);
      get_program_rslt := default_values_program();
      get_program_rslt.x_program_name := 'Select Program';
      get_program_rslt.x_program_desc := 'Select Program';
      get_program_rslt.x_prg_script_text      := 'Select Program';
      get_program_rslt.x_prg_desc_script_text := 'Select Program';
      pipe row (get_program_rslt);

      for rec in (
                  Select ewp.prog_id ee_prog_id ,
                         ewp.x_program_name ee_x_program_name,
                         ewp.x_program_desc ee_x_program_desc,
                         ewp.x_retail_price ee_program_price,
                         bo.org_id,
                         ppmv.x_prg_script_text --CR44010
                         ,ppmv.x_prg_desc_script_text --CR44010
--                         substr(pp.x_prg_script_id,1,instr(pp.x_prg_script_id,'_')-1) prg_script_type,
--                         substr(pp.x_prg_script_id,instr(pp.x_prg_script_id,'_')+1) prg_script_id,
--                         substr(pp.x_prg_desc_script_id,1,instr(pp.x_prg_desc_script_id,'_')-1) prg_desc_script_type,
--                         substr(pp.x_prg_desc_script_id,instr(pp.x_prg_desc_script_id,'_')+1) prg_desc_script_id
                  FROM TABLE(sa.VALUE_ADDEDPRG.getEligibleWtyPrograms(ip_esn)) ewp,
                       sa.x_program_parameters pp,
                       (select prg_objid, x_prg_script_text, x_prg_desc_script_text
                       from sa.adfcrm_prg_enrolled_script_mv
                       where x_language = upper(ip_language)) ppmv,
                       sa.table_bus_org bo
                  where pp.objid = ewp.prog_id
                  and bo.objid = pp.prog_param2bus_org
                  and ppmv.prg_objid = ewp.prog_id
                  )
      loop
         get_program_rslt := default_values_program();
         get_program_rslt.objid                  := rec.ee_prog_id;
         get_program_rslt.x_program_name         := rec.ee_x_program_name;
         get_program_rslt.x_program_desc         := rec.ee_x_program_desc;
         get_program_rslt.x_retail_price         := rec.ee_program_price;
         get_program_rslt.x_prg_script_text      := rec.x_prg_script_text;
--         sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => rec.prg_script_type,
--                                                                       ip_script_id => rec.prg_script_id,
--                                                                       ip_language => p_language,
--                                                                       ip_sourcesystem  => 'TAS',
--                                                                       ip_brand_name => rec.org_id);
         get_program_rslt.x_prg_desc_script_text := rec.x_prg_desc_script_text;
--         sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => rec.prg_desc_script_type,
--                                                                       ip_script_id => rec.prg_desc_script_id,
--                                                                       ip_language => p_language,
--                                                                       ip_sourcesystem  => 'TAS',
--                                                                       ip_brand_name => rec.org_id);
         pipe row (get_program_rslt);
      end loop;
  end getEligibleWtyPrograms;

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

    for i in (select objid, title||' Ticket Number' title_label, id_number ,
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
              where id_number = ip_case_id)
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
      pipe row (get_case_info_rslt);
    end loop;
  end get_case_info;
  ------------------------------------------------------------------------------

  --********************Check if the ESN is SafeLink enrolled in the past*******************--
FUNCTION is_past_safelink_enrolled(
    ip_esn VARCHAR2)
  RETURN VARCHAR2
AS
  ret_val VARCHAR2(5) := 'false';
  cnt     NUMBER;
BEGIN
  SELECT COUNT(1)
  INTO cnt
  FROM x_program_enrolled pe,
    x_program_parameters pgm,
    x_sl_currentvals slcur,
    x_sl_subs slsub
  WHERE 1                     = 1
  AND pgm.objid               = pe.pgm_enroll2pgm_parameter
  AND slcur.x_current_esn     = pe.x_esn
  AND slcur.lid               = slsub.lid
  AND pgm.x_prog_class        = 'LIFELINE'
  AND pe.x_sourcesystem      IN ('VMBC', 'WEB')
  AND pgm.x_is_recurring      = 1
  AND pe.x_esn                = ip_esn
  AND pe.x_enrollment_status <> 'ENROLLED'
  AND pe.x_enrolled_date      =
    (SELECT MAX(i_pe.x_enrolled_date)
    FROM x_program_enrolled i_pe,
      x_program_parameters i_pgm
    WHERE i_pe.X_ESN         = pe.x_esn
    AND i_pgm.objid          = i_pe.pgm_enroll2pgm_parameter
    AND i_pgm.x_prog_class   = 'LIFELINE'
    AND i_pgm.x_is_recurring = 1
    )
  AND NOT EXISTS
    (SELECT 1
    FROM x_program_enrolled i_pe,
      x_program_parameters i_pgm
    WHERE i_pe.X_ESN             = pe.x_esn
    AND i_pgm.objid              = i_pe.pgm_enroll2pgm_parameter
    AND i_pgm.x_prog_class       = 'LIFELINE'
    AND i_pgm.x_is_recurring     = 1
    AND i_pe.x_enrollment_status = 'ENROLLED'
    ) ;
  IF cnt     > 0 THEN
    ret_val := 'true';
  END IF;
  RETURN ret_val;
EXCEPTION
WHEN OTHERS THEN
  RETURN ret_val;
END is_past_safelink_enrolled;
--********************************************************************************************************************--

    function get_payment_method (
        ip_web_user_objid in varchar2,
        ip_contact_objid in varchar2,
        ip_transaction_type in varchar2 default 'PURCHASE'  --PURCHASE, ENROLLMENT
    )
    return get_payment_method_tab pipelined is
      v_sub_bus_org varchar2(30);
      v_errstr varchar2(200);

      cursor web_user_login (ip_web_user_objid varchar2) is
        select bo.org_id
        From   Table_Web_User web, table_bus_org bo
        where  web.objid = ip_web_user_objid
        and    bo.objid = web.web_user2bus_org;

      web_user_login_rec  web_user_login%rowtype;

      cursor contact (ip_contact_objid varchar2) is
        select bo.org_id
        from   table_contact c,
               table_x_contact_add_info cai,
               table_bus_org bo
        where  c.objid = ip_contact_objid
        and    cai.ADD_INFO2CONTACT = c.objid
        and    bo.objid = cai.add_info2bus_org
        ;

      contact_rec  contact%rowtype;
        -- Find out as ACH is Allowed or not
        cursor allow_ach (ip_org_id varchar2, ip_trans_type varchar2) is
            SELECT tnx.brand,
              tnx.x_source_system,
              tnx.txn_flow,
              tnx.is_flag_on
            FROM sa.TABLE_ACH_FLAG_CONFIG tnx,
              sa.TABLE_ACH_FLAG_CONFIG tnx_all
            WHERE tnx.brand         = ip_org_id
            AND tnx.x_source_system = 'TAS'
            AND tnx.txn_flow        = DECODE(ip_trans_type,'PURCHASE', 'BUYNOW', 'ENROLLMENT', 'AUTO_REFILL', ip_trans_type)
              --AND tnx.is_flag_on          = 'TRUE'
            AND tnx_all.brand           = ip_org_id
            AND tnx_all.x_source_system = 'TAS'
            AND tnx_all.txn_flow        = 'ALL'
            AND tnx_all.is_flag_on      = 'TRUE';
        web_user_allow_ach_rec  allow_ach%rowtype;
        contact_allow_ach_rec  allow_ach%rowtype;
        sub_bus_org_allow_ach_rec allow_ach%rowtype;

        get_payment_method_rslt  get_payment_method_rec;
        procedure default_values_pymt is
        begin
            get_payment_method_rslt.pymt_src_objid := null;
            get_payment_method_rslt.pymt_src_name := null;
            get_payment_method_rslt.pymt_src_type := null;
            get_payment_method_rslt.pymt_src_status := null;
            get_payment_method_rslt.pymt_src_email := null;
            get_payment_method_rslt.pymt_src_default := null;
            get_payment_method_rslt.pymt_method_objid := null;
            get_payment_method_rslt.pymt_method_secure_num := null;
            get_payment_method_rslt.pymt_method_number := null;
            get_payment_method_rslt.pymt_method_type := null;
            get_payment_method_rslt.pymt_method_status := null;
            get_payment_method_rslt.max_purch_amt := null;
            get_payment_method_rslt.expmo := null;
            get_payment_method_rslt.expyr := null;
            get_payment_method_rslt.exp_date := null;
            get_payment_method_rslt.first_name := null;
            get_payment_method_rslt.last_name := null;
            get_payment_method_rslt.phone := null;
            get_payment_method_rslt.email := null;
            get_payment_method_rslt.address_objid := null;
            get_payment_method_rslt.address := null;
            get_payment_method_rslt.address2 := null;
            get_payment_method_rslt.zipcode := null;
            get_payment_method_rslt.city := null;
            get_payment_method_rslt.state := null;
            get_payment_method_rslt.country := null;
        end default_values_pymt;
    begin
        default_values_pymt;
        get_payment_method_rslt.pymt_method_secure_num := 'Please select payment method';
        pipe row (get_payment_method_rslt);

        --get brand
        if ip_web_user_objid is not null then
            open web_user_login(ip_web_user_objid);
            fetch web_user_login into web_user_login_rec;
            close web_user_login;
        end if;
        if ip_contact_objid is not null and web_user_login_rec.org_id is null then
            open contact(ip_contact_objid);
            fetch contact into contact_rec;
            close contact;
        end if;

        for cc_rec in (
                SELECT  cc.objid,
                        cc.credit_card,
                        cc.cc_Type,
                        cc.Exp_Date,
                        cc.First_Name,
                        cc.Last_Name,
                        cc.Phone,
                        cc.Status,
                        cc.Expyr,
                        cc.Expmo,
                        cc.Email,
                        cc.Hash,
                        Addr.objid address_objid,
                        Addr.zipcode Zipcode,
                        Addr.address Address,
                        Addr.address_2 Address2,
                        Addr.city City,
                        Addr.state State,
                        Country.name Country,
                        pymt.objid pymt_objid,
                        pymt.x_pymt_src_name srcname,
                        pymt.x_pymt_type pymttype,
                        pymt.x_is_default isdefault,
                        pymt.x_status pymtstatus,
                        pymt.x_billing_email
                FROM (
                        SELECT Cc.Objid,
                          '************'
                          ||SUBSTR(Cc.X_Customer_Cc_Number,-4) Credit_Card,
                          Cc.X_Cc_Type cc_Type,
                          Cc.X_Customer_Cc_Expmo
                          ||'/'
                          ||Cc.X_Customer_Cc_Expyr Exp_Date,
                          cc.X_Customer_Firstname First_Name,
                          cc.X_Customer_Lastname Last_Name,
                          cc.X_Customer_Phone Phone,
                          Cc.X_Credit_Card2address,
                          cc.X_Card_Status Status,
                          cc.x_customer_cc_expyr Expyr,
                          cc.x_customer_cc_expmo Expmo,
                          cc.x_customer_email Email,
                          cc.x_customer_cc_number Hash
                        FROM Table_X_Credit_Card Cc
                        WHERE Cc.X_Credit_Card2contact IN (select objid c_objid from table_contact where objid = ip_contact_objid
                                                           UNION
                                                           SELECT wu.web_user2contact c_objid FROM table_web_user wu
                                                           WHERE wu.objid = ip_web_user_objid
                                                           )
                        AND Cc.X_card_status = 'ACTIVE'
                        union
                        SELECT Cc.Objid,
                          '************'
                          ||SUBSTR(Cc.X_Customer_Cc_Number,-4) Credit_Card,
                          Cc.X_Cc_Type cc_Type,
                          Cc.X_Customer_Cc_Expmo
                          ||'/'
                          ||Cc.X_Customer_Cc_Expyr Exp_Date,
                          cc.X_Customer_Firstname First_Name,
                          cc.X_Customer_Lastname Last_Name,
                          cc.X_Customer_Phone Phone,
                          Cc.X_Credit_Card2address,
                          cc.X_Card_Status Status,
                          cc.x_customer_cc_expyr Expyr,
                          cc.x_customer_cc_expmo Expmo,
                          cc.x_customer_email Email,
                          cc.x_customer_cc_number Hash
                        FROM Mtm_Contact46_X_Credit_Card3 Mtm,
                             Table_X_Credit_Card Cc
                        WHERE Mtm.Mtm_Contact2x_Credit_Card in (select objid c_objid from table_contact where objid = ip_contact_objid
                                                           UNION
                                                           SELECT wu.web_user2contact c_objid FROM table_web_user wu
                                                           WHERE wu.objid = ip_web_user_objid)
                        AND Cc.Objid = Mtm.Mtm_Credit_Card2contact
                        AND Cc.X_card_status = 'ACTIVE'
                    ) CC,
                    Table_Address Addr,
                    Table_Country Country,
                    (select *
                     from sa.x_payment_source pymt
                     where pymt.pymt_src2web_user = ip_web_user_objid
                     and pymt.x_pymt_type = 'CREDITCARD'
                     and pymt.x_status = 'ACTIVE') pymt
                where addr.objid       = Cc.X_Credit_Card2address
                and Country.objid = addr.address2country
                and pymt.pymt_src2x_credit_card (+) = cc.objid
                )
        loop
            if ip_transaction_type = 'PURCHASE' or
               (ip_transaction_type = 'ENROLLMENT' and cc_rec.pymt_objid is not null)
            then
                get_payment_method_rslt.pymt_src_objid := cc_rec.pymt_objid;
                get_payment_method_rslt.pymt_src_name := cc_rec.srcname;
                get_payment_method_rslt.pymt_src_type := cc_rec.pymttype;
                get_payment_method_rslt.pymt_src_status := cc_rec.pymtstatus;
                get_payment_method_rslt.pymt_src_email := cc_rec.x_billing_email;
                get_payment_method_rslt.pymt_src_default := cc_rec.isdefault;
                get_payment_method_rslt.pymt_method_objid := cc_rec.objid;
                get_payment_method_rslt.pymt_method_secure_num := cc_rec.credit_card;
                get_payment_method_rslt.pymt_method_number := cc_rec.Hash;
                get_payment_method_rslt.pymt_method_type := cc_rec.cc_Type;
                get_payment_method_rslt.pymt_method_status := cc_rec.status;
                get_payment_method_rslt.max_purch_amt := null;
                get_payment_method_rslt.expmo := cc_rec.Expmo;
                get_payment_method_rslt.expyr := cc_rec.Expyr;
                get_payment_method_rslt.exp_date := cc_rec.Exp_Date;
                get_payment_method_rslt.first_name := cc_rec.first_name;
                get_payment_method_rslt.last_name := cc_rec.last_name;
                get_payment_method_rslt.phone := cc_rec.phone;
                get_payment_method_rslt.email := cc_rec.email;
                get_payment_method_rslt.address_objid := cc_rec.address_objid;
                get_payment_method_rslt.address := cc_rec.address;
                get_payment_method_rslt.address2 := cc_rec.address2;
                get_payment_method_rslt.zipcode := cc_rec.zipcode;
                get_payment_method_rslt.city := cc_rec.city;
                get_payment_method_rslt.state := cc_rec.state;
                get_payment_method_rslt.country := cc_rec.country;
                pipe row (get_payment_method_rslt);
            end if;
        end loop;
        default_values_pymt;

        --For now, only TRACFONE and NET10 can add ACH and GO_SMART (SUB BRAND OF SIMPLE_MOBILE)
        if web_user_login_rec.org_id = 'SIMPLE_MOBILE' then
          sa.phone_pkg.get_sub_brand(i_contact_objid => ip_contact_objid,o_sub_brand => v_sub_bus_org,o_errnum => v_errstr,o_errstr => v_errstr);
        end if;
        -- Find out ACH allowed or not
        -- ACH based on web user
        if web_user_login_rec.org_id is not null and ip_transaction_type is not null then
            open allow_ach (web_user_login_rec.org_id, ip_transaction_type);
            fetch allow_ach into web_user_allow_ach_rec;
            close allow_ach;
        end if;

        -- ACH based on contact
        if contact_rec.org_id is not null and ip_transaction_type is not null then
            open allow_ach (contact_rec.org_id, ip_transaction_type);
            fetch allow_ach into contact_allow_ach_rec;
            close allow_ach;
        end if;
        -- ACH for GO_SMART
        if v_sub_bus_org is not null and ip_transaction_type is not null then
            open allow_ach (v_sub_bus_org, ip_transaction_type);
            fetch allow_ach into sub_bus_org_allow_ach_rec;
            close allow_ach;
        end if;
        --if nvl(web_user_login_rec.org_id,'empty') in ('TRACFONE','NET10','WFM') or
        --   nvl(contact_rec.org_id,'empty') in ('TRACFONE','NET10','WFM') or
        --   (nvl(web_user_login_rec.org_id,'empty') in ('SIMPLE_MOBILE') and v_sub_bus_org = 'GO_SMART')
		if nvl(web_user_allow_ach_rec.is_flag_on, 'FALSE') = 'TRUE' or
           nvl(contact_allow_ach_rec.is_flag_on, 'FALSE') = 'TRUE' or
           nvl(sub_bus_org_allow_ach_rec.is_flag_on, 'FALSE') = 'TRUE'
        then

        for ach_rec in (
                SELECT  ach.Objid,
                        '************'
                          ||substr(ach.x_customer_acct,-4) secure_number,
                        ach.x_aba_transit ach_Type,
                        ach.x_max_purch_amt max_purch_amt,
                        '00/0000' Exp_Date,
                        ach.X_Customer_Firstname First_Name,
                        ach.X_Customer_Lastname Last_Name,
                        ach.X_Customer_Phone Phone,
                        ach.x_status Status,
                        '0000' Expyr,
                        '00' Expmo,
                        ach.x_customer_email Email,
                        '******'||substr(ach.x_routing,-4) Hash,
                        Addr.objid address_objid,
                        Addr.zipcode Zipcode,
                        Addr.address Address,
                        Addr.address_2 Address2,
                        Addr.city City,
                        Addr.state State,
                        Country.name Country,
                        pymt.objid pymt_objid,
                        pymt.x_pymt_src_name srcname,
                        pymt.x_pymt_type pymttype,
                        pymt.x_is_default isdefault,
                        pymt.x_status pymtstatus,
                        pymt.x_billing_email
                FROM
                    sa.table_x_bank_account ach,
                    sa.Table_Address Addr,
                    sa.Table_Country Country,
                    (select *
                     from sa.x_payment_source pymt
                     where pymt.pymt_src2web_user = ip_web_user_objid
                     and pymt.x_pymt_type = 'ACH'
                     and pymt.x_status = 'ACTIVE') pymt
                where addr.objid       = ach.x_bank_acct2address
                and Country.objid (+) = addr.address2country
                and pymt.pymt_src2x_bank_account = ach.objid
                and ach.x_status = 'ACTIVE'
                )
        loop
                get_payment_method_rslt.pymt_src_objid := ach_rec.pymt_objid;
                get_payment_method_rslt.pymt_src_name := ach_rec.srcname;
                get_payment_method_rslt.pymt_src_type := ach_rec.pymttype;
                get_payment_method_rslt.pymt_src_status := ach_rec.pymtstatus;
                get_payment_method_rslt.pymt_src_email := ach_rec.x_billing_email;
                get_payment_method_rslt.pymt_src_default := ach_rec.isdefault;
                get_payment_method_rslt.pymt_method_objid := ach_rec.objid;
                get_payment_method_rslt.pymt_method_secure_num := ach_rec.secure_number;
                get_payment_method_rslt.pymt_method_number := ach_rec.Hash;
                get_payment_method_rslt.pymt_method_type := ach_rec.ach_Type;
                get_payment_method_rslt.pymt_method_status := ach_rec.status;
                get_payment_method_rslt.max_purch_amt := ach_rec.max_purch_amt;
                get_payment_method_rslt.expmo := ach_rec.Expmo;
                get_payment_method_rslt.expyr := ach_rec.Expyr;
                get_payment_method_rslt.exp_date := ach_rec.Exp_Date;
                get_payment_method_rslt.first_name := ach_rec.first_name;
                get_payment_method_rslt.last_name := ach_rec.last_name;
                get_payment_method_rslt.phone := ach_rec.phone;
                get_payment_method_rslt.email := ach_rec.email;
                get_payment_method_rslt.address_objid := ach_rec.address_objid;
                get_payment_method_rslt.address := ach_rec.address;
                get_payment_method_rslt.address2 := ach_rec.address2;
                get_payment_method_rslt.zipcode := ach_rec.zipcode;
                get_payment_method_rslt.city := ach_rec.city;
                get_payment_method_rslt.state := ach_rec.state;
                get_payment_method_rslt.country := ach_rec.country;
                pipe row (get_payment_method_rslt);
        end loop;

        end if;  --only TRACFONE and NET10

    end get_payment_method;

---------------------------------------------------------------------------------------------------------------
    function get_payment_method (
    --CR46822 TAS Credit Card Modifications
        ip_web_user_objid in varchar2,
        ip_contact_objid in varchar2,
        ip_transaction_type in varchar2 default 'PURCHASE',  --PURCHASE, ENROLLMENT,
        ip_cc_objid in varchar2
    )
    return get_payment_method_tab pipelined is
      v_sub_bus_org varchar2(30);
      v_errstr varchar2(200);

      cursor web_user_login (ip_web_user_objid varchar2) is
        select bo.org_id
        From   Table_Web_User web, table_bus_org bo
        where  web.objid = ip_web_user_objid
        and    bo.objid = web.web_user2bus_org;

      web_user_login_rec  web_user_login%rowtype;
      -- Find out as ACH is Allowed or not
      cursor allow_ach (ip_org_id varchar2, ip_trans_type varchar2) is
        SELECT tnx.brand,
          tnx.x_source_system,
          tnx.txn_flow,
          tnx.is_flag_on
        FROM sa.TABLE_ACH_FLAG_CONFIG tnx,
          sa.TABLE_ACH_FLAG_CONFIG tnx_all
        WHERE tnx.brand         = ip_org_id
        AND tnx.x_source_system = 'TAS'
        AND tnx.txn_flow        = DECODE(ip_trans_type,'PURCHASE', 'BUYNOW', 'ENROLLMENT', 'AUTO_REFILL', ip_trans_type)
          --AND tnx.is_flag_on          = 'TRUE'
        AND tnx_all.brand           = ip_org_id
        AND tnx_all.x_source_system = 'TAS'
        AND tnx_all.txn_flow        = 'ALL'
        AND tnx_all.is_flag_on      = 'TRUE';
        web_user_allow_ach_rec  allow_ach%rowtype;
        sub_bus_org_allow_ach_rec allow_ach%rowtype;

        get_payment_method_rslt  get_payment_method_rec;
        procedure default_values_pymt is
        begin
            get_payment_method_rslt.pymt_src_objid := null;
            get_payment_method_rslt.pymt_src_name := null;
            get_payment_method_rslt.pymt_src_type := null;
            get_payment_method_rslt.pymt_src_status := null;
            get_payment_method_rslt.pymt_src_email := null;
            get_payment_method_rslt.pymt_src_default := null;
            get_payment_method_rslt.pymt_method_objid := null;
            get_payment_method_rslt.pymt_method_secure_num := null;
            get_payment_method_rslt.pymt_method_number := null;
            get_payment_method_rslt.pymt_method_type := null;
            get_payment_method_rslt.pymt_method_status := null;
            get_payment_method_rslt.max_purch_amt := null;
            get_payment_method_rslt.expmo := null;
            get_payment_method_rslt.expyr := null;
            get_payment_method_rslt.exp_date := null;
            get_payment_method_rslt.first_name := null;
            get_payment_method_rslt.last_name := null;
            get_payment_method_rslt.phone := null;
            get_payment_method_rslt.email := null;
            get_payment_method_rslt.address_objid := null;
            get_payment_method_rslt.address := null;
            get_payment_method_rslt.address2 := null;
            get_payment_method_rslt.zipcode := null;
            get_payment_method_rslt.city := null;
            get_payment_method_rslt.state := null;
            get_payment_method_rslt.country := null;
            get_payment_method_rslt.change_date := null;
            get_payment_method_rslt.original_insert_date := null;
            get_payment_method_rslt.is_new_pymt := null;
        end default_values_pymt;
    begin
        default_values_pymt;
        get_payment_method_rslt.pymt_method_secure_num := 'Please select payment method';
        pipe row (get_payment_method_rslt);

        --get brand
        if ip_web_user_objid is not null then
            open web_user_login(ip_web_user_objid);
            fetch web_user_login into web_user_login_rec;
            close web_user_login;
        end if;

        if ip_cc_objid is not null then
        for cc_rec in (
                SELECT  Cc.Objid objid,
                        '************'
                          ||SUBSTR(Cc.X_Customer_Cc_Number,-4) credit_card,
                        Cc.X_Cc_Type cc_Type,
                        Cc.X_Customer_Cc_Expmo
                          ||'/'
                          ||Cc.X_Customer_Cc_Expyr Exp_Date,
                        cc.X_Customer_Firstname First_Name,
                        cc.X_Customer_Lastname Last_Name,
                        cc.X_Customer_Phone Phone,
                        cc.X_Card_Status Status,
                        cc.x_customer_cc_expyr Expyr,
                        cc.x_customer_cc_expmo Expmo,
                        cc.x_customer_email Email,
                        cc.x_customer_cc_number Hash,
                        cc.x_changedate,
                        cc.x_original_insert_date,
                        Addr.objid address_objid,
                        Addr.zipcode Zipcode,
                        Addr.address Address,
                        Addr.address_2 Address2,
                        Addr.city City,
                        Addr.state State,
                        Country.name Country,
                        pymt.objid pymt_objid,
                        pymt.x_pymt_src_name srcname,
                        nvl(pymt.x_pymt_type,'CREDITCARD') pymttype,
                        pymt.x_is_default isdefault,
                        pymt.x_status pymtstatus,
                        pymt.x_billing_email
                FROM sa.Table_X_Credit_Card Cc,
                    sa.Table_Address Addr,
                    sa.Table_Country Country,
                    (select *
                     from sa.x_payment_source pymt
                     where pymt.pymt_src2web_user = ip_web_user_objid
                     and pymt.x_pymt_type = 'CREDITCARD'
                     and pymt.x_status = 'ACTIVE') pymt
                WHERE Cc.objid = ip_cc_objid
                and Cc.X_card_status = 'ACTIVE'
                and addr.objid       = Cc.X_Credit_Card2address
                and Country.objid = addr.address2country
                and pymt.pymt_src2x_credit_card (+) = cc.objid
                )
        loop
                get_payment_method_rslt.pymt_src_objid := cc_rec.pymt_objid;
                get_payment_method_rslt.pymt_src_name := cc_rec.srcname;
                get_payment_method_rslt.pymt_src_type := cc_rec.pymttype;
                get_payment_method_rslt.pymt_src_status := cc_rec.pymtstatus;
                get_payment_method_rslt.pymt_src_email := cc_rec.x_billing_email;
                get_payment_method_rslt.pymt_src_default := cc_rec.isdefault;
                get_payment_method_rslt.pymt_method_objid := cc_rec.objid;
                get_payment_method_rslt.pymt_method_secure_num := cc_rec.credit_card;
                get_payment_method_rslt.pymt_method_number := cc_rec.Hash;
                get_payment_method_rslt.pymt_method_type := cc_rec.cc_Type;
                get_payment_method_rslt.pymt_method_status := cc_rec.status;
                get_payment_method_rslt.max_purch_amt := null;
                get_payment_method_rslt.expmo := cc_rec.Expmo;
                get_payment_method_rslt.expyr := cc_rec.Expyr;
                get_payment_method_rslt.exp_date := cc_rec.Exp_Date;
                get_payment_method_rslt.first_name := cc_rec.first_name;
                get_payment_method_rslt.last_name := cc_rec.last_name;
                get_payment_method_rslt.phone := cc_rec.phone;
                get_payment_method_rslt.email := cc_rec.email;
                get_payment_method_rslt.address_objid := cc_rec.address_objid;
                get_payment_method_rslt.address := cc_rec.address;
                get_payment_method_rslt.address2 := cc_rec.address2;
                get_payment_method_rslt.zipcode := cc_rec.zipcode;
                get_payment_method_rslt.city := cc_rec.city;
                get_payment_method_rslt.state := cc_rec.state;
                get_payment_method_rslt.country := cc_rec.country;
                get_payment_method_rslt.change_date := cc_rec.x_changedate;
                get_payment_method_rslt.original_insert_date := cc_rec.x_original_insert_date;
                if (cc_rec.x_changedate > trunc(sysdate) or cc_rec.x_original_insert_date > trunc(sysdate))
                then
                    get_payment_method_rslt.is_new_pymt := 'Y';
                else
                    get_payment_method_rslt.is_new_pymt := 'N';
                end if;
                pipe row (get_payment_method_rslt);
        end loop;
        end if;

        if ip_web_user_objid is not null then
        for pymt_cc_rec in (
                SELECT  Cc.Objid objid,
                        '************'
                          ||SUBSTR(Cc.X_Customer_Cc_Number,-4) credit_card,
                        Cc.X_Cc_Type cc_Type,
                        Cc.X_Customer_Cc_Expmo
                          ||'/'
                          ||Cc.X_Customer_Cc_Expyr Exp_Date,
                        cc.X_Customer_Firstname First_Name,
                        cc.X_Customer_Lastname Last_Name,
                        cc.X_Customer_Phone Phone,
                        cc.X_Card_Status Status,
                        cc.x_customer_cc_expyr Expyr,
                        cc.x_customer_cc_expmo Expmo,
                        cc.x_customer_email Email,
                        cc.x_customer_cc_number Hash,
                        cc.x_changedate,
                        cc.x_original_insert_date,
                        Addr.objid address_objid,
                        Addr.zipcode Zipcode,
                        Addr.address Address,
                        Addr.address_2 Address2,
                        Addr.city City,
                        Addr.state State,
                        Country.name Country,
                        pymt.objid pymt_objid,
                        pymt.x_pymt_src_name srcname,
                        pymt.x_pymt_type pymttype,
                        pymt.x_is_default isdefault,
                        pymt.x_status pymtstatus,
                        pymt.x_billing_email
                FROM sa.Table_X_Credit_Card Cc,
                    sa.Table_Address Addr,
                    sa.Table_Country Country,
                    sa.x_payment_source pymt
                WHERE Cc.objid != nvl(ip_cc_objid,-1)
                AND Cc.X_card_status = 'ACTIVE'
                and addr.objid       = Cc.X_Credit_Card2address
                and Country.objid = addr.address2country
                and pymt.pymt_src2x_credit_card = cc.objid
                and pymt.pymt_src2web_user = ip_web_user_objid
                and pymt.x_pymt_type = 'CREDITCARD'
                and pymt.x_status = 'ACTIVE'
                )
        loop
                default_values_pymt;
                get_payment_method_rslt.pymt_src_objid := pymt_cc_rec.pymt_objid;
                get_payment_method_rslt.pymt_src_name := pymt_cc_rec.srcname;
                get_payment_method_rslt.pymt_src_type := pymt_cc_rec.pymttype;
                get_payment_method_rslt.pymt_src_status := pymt_cc_rec.pymtstatus;
                get_payment_method_rslt.pymt_src_email := pymt_cc_rec.x_billing_email;
                get_payment_method_rslt.pymt_src_default := pymt_cc_rec.isdefault;
                get_payment_method_rslt.pymt_method_objid := pymt_cc_rec.objid;
                get_payment_method_rslt.pymt_method_secure_num := pymt_cc_rec.credit_card;
                get_payment_method_rslt.pymt_method_number := pymt_cc_rec.Hash;
                get_payment_method_rslt.pymt_method_type := pymt_cc_rec.cc_Type;
                get_payment_method_rslt.pymt_method_status := pymt_cc_rec.status;
                get_payment_method_rslt.max_purch_amt := null;
                get_payment_method_rslt.expmo := pymt_cc_rec.Expmo;
                get_payment_method_rslt.expyr := pymt_cc_rec.Expyr;
                get_payment_method_rslt.exp_date := pymt_cc_rec.Exp_Date;
                get_payment_method_rslt.first_name := pymt_cc_rec.first_name;
                get_payment_method_rslt.last_name := pymt_cc_rec.last_name;
                get_payment_method_rslt.phone := pymt_cc_rec.phone;
                get_payment_method_rslt.email := pymt_cc_rec.email;
                get_payment_method_rslt.address_objid := pymt_cc_rec.address_objid;
                get_payment_method_rslt.address := pymt_cc_rec.address;
                get_payment_method_rslt.address2 := pymt_cc_rec.address2;
                get_payment_method_rslt.zipcode := pymt_cc_rec.zipcode;
                get_payment_method_rslt.city := pymt_cc_rec.city;
                get_payment_method_rslt.state := pymt_cc_rec.state;
                get_payment_method_rslt.country := pymt_cc_rec.country;
                get_payment_method_rslt.change_date := pymt_cc_rec.x_changedate;
                get_payment_method_rslt.original_insert_date := pymt_cc_rec.x_original_insert_date;
                if (pymt_cc_rec.x_changedate > trunc(sysdate) or pymt_cc_rec.x_original_insert_date > trunc(sysdate))
                then
                    get_payment_method_rslt.is_new_pymt := 'Y';
                else
                    get_payment_method_rslt.is_new_pymt := 'N';
                end if;
                pipe row (get_payment_method_rslt);
        end loop;

        --For now, only TRACFONE and NET10 can add ACH and GO_SMART (SUB BRAND OF SIMPLE_MOBILE)
        if web_user_login_rec.org_id = 'SIMPLE_MOBILE' then
          sa.phone_pkg.get_sub_brand(i_contact_objid => ip_contact_objid,o_sub_brand => v_sub_bus_org,o_errnum => v_errstr,o_errstr => v_errstr);
        end if;
        -- Find out ACH allowed or not
        -- ACH based on web user
        dbms_output.put_line('web_user_login_rec.org_id' || web_user_login_rec.org_id );
        dbms_output.put_line('ip_transaction_type' || ip_transaction_type );
        if web_user_login_rec.org_id is not null and ip_transaction_type is not null then
            open allow_ach (web_user_login_rec.org_id, ip_transaction_type);
            fetch allow_ach into web_user_allow_ach_rec;
            dbms_output.put_line ('In side cursor - web_user_allow_ach_rec :: ' || web_user_allow_ach_rec.is_flag_on );
            close allow_ach;
        end if;

        -- ACH for GO_SMART
        if v_sub_bus_org is not null and ip_transaction_type is null then
            open allow_ach (v_sub_bus_org, ip_transaction_type);
            fetch allow_ach into sub_bus_org_allow_ach_rec;
            dbms_output.put_line ('In side cursor - web_user_allow_ach_rec :: ' || sub_bus_org_allow_ach_rec.is_flag_on );
            close allow_ach;
        end if;
        --if nvl(web_user_login_rec.org_id,'empty') in ('TRACFONE','NET10','WFM') or
        --   (nvl(web_user_login_rec.org_id,'empty') in ('SIMPLE_MOBILE') and v_sub_bus_org = 'GO_SMART')
        if nvl(web_user_allow_ach_rec.is_flag_on, 'FALSE') = 'TRUE' or
           nvl(sub_bus_org_allow_ach_rec.is_flag_on, 'FALSE') = 'TRUE'
        then

        for ach_rec in (
                SELECT  ach.Objid,
                        '************'
                          ||substr(ach.x_customer_acct,-4) secure_number,
                        ach.x_aba_transit ach_Type,
                        ach.x_max_purch_amt max_purch_amt,
                        '00/0000' Exp_Date,
                        ach.X_Customer_Firstname First_Name,
                        ach.X_Customer_Lastname Last_Name,
                        ach.X_Customer_Phone Phone,
                        ach.x_status Status,
                        '0000' Expyr,
                        '00' Expmo,
                        ach.x_customer_email Email,
                        '******'||substr(ach.x_routing,-4) Hash,
                        ach.x_changedate,
                        ach.x_original_insert_date,
                        Addr.objid address_objid,
                        Addr.zipcode Zipcode,
                        Addr.address Address,
                        Addr.address_2 Address2,
                        Addr.city City,
                        Addr.state State,
                        Country.name Country,
                        pymt.objid pymt_objid,
                        pymt.x_pymt_src_name srcname,
                        pymt.x_pymt_type pymttype,
                        pymt.x_is_default isdefault,
                        pymt.x_status pymtstatus,
                        pymt.x_billing_email
                FROM
                    sa.table_x_bank_account ach,
                    sa.Table_Address Addr,
                    sa.Table_Country Country,
                    sa.x_payment_source pymt
                where addr.objid       = ach.x_bank_acct2address
                and Country.objid (+) = addr.address2country
                and ach.x_status = 'ACTIVE'
                and pymt.pymt_src2x_bank_account = ach.objid
                and pymt.pymt_src2web_user = ip_web_user_objid
                and pymt.x_pymt_type = 'ACH'
                and pymt.x_status = 'ACTIVE'
                )
        loop
                default_values_pymt;
                get_payment_method_rslt.pymt_src_objid := ach_rec.pymt_objid;
                get_payment_method_rslt.pymt_src_name := ach_rec.srcname;
                get_payment_method_rslt.pymt_src_type := ach_rec.pymttype;
                get_payment_method_rslt.pymt_src_status := ach_rec.pymtstatus;
                get_payment_method_rslt.pymt_src_email := ach_rec.x_billing_email;
                get_payment_method_rslt.pymt_src_default := ach_rec.isdefault;
                get_payment_method_rslt.pymt_method_objid := ach_rec.objid;
                get_payment_method_rslt.pymt_method_secure_num := ach_rec.secure_number;
                get_payment_method_rslt.pymt_method_number := ach_rec.Hash;
                get_payment_method_rslt.pymt_method_type := ach_rec.ach_Type;
                get_payment_method_rslt.pymt_method_status := ach_rec.status;
                get_payment_method_rslt.max_purch_amt := ach_rec.max_purch_amt;
                get_payment_method_rslt.expmo := ach_rec.Expmo;
                get_payment_method_rslt.expyr := ach_rec.Expyr;
                get_payment_method_rslt.exp_date := ach_rec.Exp_Date;
                get_payment_method_rslt.first_name := ach_rec.first_name;
                get_payment_method_rslt.last_name := ach_rec.last_name;
                get_payment_method_rslt.phone := ach_rec.phone;
                get_payment_method_rslt.email := ach_rec.email;
                get_payment_method_rslt.address_objid := ach_rec.address_objid;
                get_payment_method_rslt.address := ach_rec.address;
                get_payment_method_rslt.address2 := ach_rec.address2;
                get_payment_method_rslt.zipcode := ach_rec.zipcode;
                get_payment_method_rslt.city := ach_rec.city;
                get_payment_method_rslt.state := ach_rec.state;
                get_payment_method_rslt.country := ach_rec.country;
                get_payment_method_rslt.change_date := ach_rec.x_changedate;
                get_payment_method_rslt.original_insert_date := ach_rec.x_original_insert_date;
                if (ach_rec.x_changedate > trunc(sysdate) or ach_rec.x_original_insert_date > trunc(sysdate))
                then
                    get_payment_method_rslt.is_new_pymt := 'Y';
                else
                    get_payment_method_rslt.is_new_pymt := 'N';
                end if;
                pipe row (get_payment_method_rslt);
        end loop;

        end if;  --only TRACFONE and NET10
        end if;  --ip_web_user_objid is not null
    end get_payment_method;
---------------------------------------------------------------------------------------------------------------

    function get_buckets (
        ip_esn in varchar2,
        ip_org_id in varchar2,
        ip_service_plan_id in varchar2 default '-1',
        ip_action in varchar2 default 'COMPENSATION',
        ip_type in varchar2 default '3', --1 Reference ESN, 2 Reference Pin, 3 Open Access
        ip_language in varchar2 default 'en'
    )
    return get_buckets_tab pipelined is
        get_buckets_rslt  get_buckets_rec;
    begin
        for rec in (
        select
          nvl(ip_service_plan_id,-1) objid, 'Service Plan Description' description,
          max(action) action, max(voice) voice, max(sms) sms, max(data) data, max(serv_plan) serv_plan,
          max(days) days, max(org_id) org_id, max(Service_Plan_Group) Service_Plan_Group, max(metering) metering
        from (
            select sp.objid,sp.description,
            buckets.action, buckets.voice,buckets.sms,buckets.data,buckets.serv_plan,days,
            buckets.org_id, Buckets.Service_Plan_Group, Buckets.metering
            from x_service_plan sp,
                 table_part_inst pi,
                 table_mod_level ml,
                 table_part_num pn,
                 table_bus_org bo,
                 table_part_class tpc,
                 adfcrm_serv_plan_group2buckets buckets
            where 1= 1
            and sp.Objid = ip_service_plan_id
            and pi.part_serial_no = ip_esn
            and pi.x_domain = 'PHONES'
            and Pi.N_Part_Inst2part_Mod = ml.objid
            and Ml.Part_Info2part_Num = pn.objid
            and Pn.Part_Num2bus_Org = bo.objid
            and tpc.objid = pn.part_num2part_class
            --and bo.org_id <> 'TRACFONE'
            and buckets.org_id = nvl(get_sub_brand(ip_esn),bo.org_id)
            and Buckets.Service_Plan_Group = nvl(sa.GET_SERV_PLAN_VALUE(sp.objid,'SERVICE_PLAN_GROUP'),'PAY_GO')
            and Buckets.action = ip_action
            and Buckets.metering =  sa.adfcrm_transactions.balance_metering(ip_esn,ip_action,Buckets.Service_Plan_Group)
            union
            select sp.objid,sp.description,
            buckets.action, buckets.voice,buckets.sms,buckets.data,buckets.serv_plan,days,
            buckets.org_id, Buckets.Service_Plan_Group, Buckets.metering
            from (select objid, description, service_plan_group
                  from  table(sa.ADFCRM_VO.getSafelinkSp(ip_esn,ip_org_id,ip_language)) A
                  where ip_org_id = 'TRACFONE' and ip_action = 'REPLACEMENT' and ip_type = '3'
                  and ServicePlanType = 'AIRTIME' and nvl(spobjid,0) != 0) sp,
                 table_part_inst pi,
                 table_mod_level ml,
                 table_part_num pn,
                 table_bus_org bo,
                 table_part_class tpc,
                 adfcrm_serv_plan_group2buckets buckets
            where 1= 1
            and pi.part_serial_no = ip_esn
            and pi.x_domain = 'PHONES'
            and Pi.N_Part_Inst2part_Mod = ml.objid
            and Ml.Part_Info2part_Num = pn.objid
            and Pn.Part_Num2bus_Org = bo.objid
            and tpc.objid = pn.part_num2part_class
            and bo.org_id = 'TRACFONE'
            and buckets.org_id = nvl(get_sub_brand(ip_esn),bo.org_id)
            and Buckets.Service_Plan_Group = sp.service_plan_group
            and Buckets.action = ip_action
            and Buckets.metering =  sa.adfcrm_transactions.balance_metering(ip_esn,ip_action,Buckets.Service_Plan_Group)
            union
            select -1 objid, 'PAY_GO' description,
            buckets.action, buckets.voice,buckets.sms,buckets.data,buckets.serv_plan,days,
            buckets.org_id, Buckets.Service_Plan_Group, Buckets.metering
            from
              table_part_class pc,
              table_part_num pn,
              table_part_inst pi,
              table_bus_org bo,
              Table_Mod_Level ml,
              adfcrm_serv_plan_group2buckets buckets
            where 1=1
            AND pi.part_serial_no = ip_esn
            AND pi.x_domain = 'PHONES'
            and pi.N_Part_Inst2part_Mod = ml.objid
            and Ml.Part_Info2part_Num = pn.objid
            and Pn.Part_Num2bus_Org = bo.objid
            and Pn.Part_Num2part_Class = pc.objid
            and bo.org_id = 'TRACFONE'
            and Buckets.Org_Id = nvl(get_sub_brand(ip_esn),bo.org_id)
            and buckets.action = ip_action
            and buckets.service_plan_group = 'PAY_GO'
            AND Buckets.Metering = sa.adfcrm_transactions.balance_metering(ip_esn,ip_action,Buckets.Service_Plan_Group)
            and nvl(ip_service_plan_id,-1) = -1
            union
            select -1 objid, 'PAY_GO' description,
            buckets.action, buckets.voice,buckets.sms,buckets.data,buckets.serv_plan,days,
            buckets.org_id, Buckets.Service_Plan_Group, Buckets.metering
            from
              table_part_class pc,
              table_part_num pn,
              table_part_inst pi,
              table_bus_org bo,
              Table_Mod_Level ml,
              adfcrm_serv_plan_group2buckets buckets
            where 1=1
            AND pi.part_serial_no = ip_esn
            AND pi.x_domain = 'PHONES'
            and pi.N_Part_Inst2part_Mod = ml.objid
            and Ml.Part_Info2part_Num = pn.objid
            and Pn.Part_Num2bus_Org = bo.objid
            and Pn.Part_Num2part_Class = pc.objid
            and bo.org_id = 'NET10'
            and Buckets.Org_Id = nvl(get_sub_brand(ip_esn),bo.org_id)
            and buckets.action = ip_action
            and buckets.service_plan_group = 'PAY_GO'
            AND Buckets.Metering = sa.adfcrm_transactions.balance_metering(ip_esn,ip_action,Buckets.Service_Plan_Group)
            and nvl(ip_service_plan_id,-1) = -1
            )
        ) loop
            get_buckets_rslt.objid := rec.objid;
            get_buckets_rslt.description := rec.description;
            get_buckets_rslt.org_id := rec.org_id;
            get_buckets_rslt.service_plan_group := rec.service_plan_group;
            get_buckets_rslt.action := rec.action;
            get_buckets_rslt.metering := rec.metering;
            get_buckets_rslt.voice := rec.voice;
            get_buckets_rslt.sms := rec.sms;
            get_buckets_rslt.data := rec.data;
            get_buckets_rslt.serv_plan := rec.serv_plan;
            get_buckets_rslt.days := rec.days;
            pipe row (get_buckets_rslt);
        end loop;
    end;
--********************************************************************************************************************
 --CR48383 To identify TF ESN that is blocked for triple minutes

        function get_EsnTripleBenefit (ip_esn varchar2)
    return varchar2 IS
    isEsnTripleBenefit varchar2(1):='';
    Begin

    isEsnTripleBenefit:= sa.BLOCK_TRIPLE_BENEFITS(ip_esn);
    dbms_output.put_line('Value - '||isEsnTripleBenefit );
    return isEsnTripleBenefit;
    End;

 --CR48491 To get throttling info for an ESN
     function get_throttle_func(
    ip_esn in varchar2,
    ip_lang in varchar2)
    return get_throttle_rec_tab pipelined
    is
    v_param_value varchar2(200);
    get_throttle_rslt get_throttle_rec;
    v_unthrottled_date date;
    v_unthrottled_desc varchar2(200);
    v_agent_msg varchar2(2000);
    v_throttle_duration date;
    begin

    dbms_output.put_line('Fetch Throttle Status for ESN===================='||ip_esn);
    begin
    select nvl(tp.x_policy_description,'N/A'), tc.x_creation_date
    into   get_throttle_rslt.x_throttle_desc, get_throttle_rslt.x_throttle_date
      from   w3ci.table_x_throttling_cache tc,  w3ci.table_x_throttling_policy tp
      where  1 = 1
      and tp.objid = tc.x_policy_id
      and x_status  in ('A','P')
       and tc.objid = (select max(objid) from w3ci.table_x_throttling_cache where x_esn = ip_esn);
      exception
    when others then
     get_throttle_rslt.x_throttle_desc:='N/A';
     get_throttle_rslt.x_throttle_date:='';
    end;

     dbms_output.put_line('Throttle info for ESN===================='||get_throttle_rslt.x_throttle_desc||'-'||get_throttle_rslt.x_throttle_date);

    begin
    Select x_transact_date into get_throttle_rslt.x_redemption_date from  TABLE_X_CALL_TRANS where objid = (SELECT max(objid)  FROM TABLE_X_CALL_TRANS CT WHERE X_SERVICE_ID = ip_esn and x_action_type='6');
    exception
    when others then
    get_throttle_rslt.x_redemption_date:='';
    end;

    dbms_output.put_line('Last Redemption date for ESN===================='||get_throttle_rslt.x_redemption_date);
    begin
      select x_param_value
      into v_param_value
      from table_x_parameters
      where x_param_name ='ADFCRM_THROTTLE_DURATION';
      exception
      when others then
      v_param_value:='';
      end;

      dbms_output.put_line('Set Agent Message ===================='||v_param_value);

     begin
    select nvl(tp.x_policy_description,'N/A'),tc.update_timestamp
    into   v_unthrottled_desc, v_unthrottled_date
      from   w3ci.table_x_throttling_cache tc,  w3ci.table_x_throttling_policy tp
      where  1 = 1
      and tp.objid = tc.x_policy_id
      and x_status ='I'
      and tc.objid = (select max(objid) from w3ci.table_x_throttling_cache where x_esn = ip_esn);
      exception
      when others then
      dbms_output.put_line('Throttled');
      v_unthrottled_desc:='N/A';
     -- v_unthrottled_date:='';
      end;

       dbms_output.put_line('Get Duration');
      select sysdate - (v_param_value/24) into v_throttle_duration from dual;

     dbms_output.put_line('UnThrottled info for ESN===================='||v_unthrottled_desc||'-'||v_throttle_duration);

      if v_unthrottled_date is not null then
       -- unthrottled less than the duration set
       if to_char(v_unthrottled_date,'MM/DD/YYYY HH24:MI:SS') > to_char(v_throttle_duration,'MM/DD/YYYY HH24:MI:SS') then
       dbms_output.put_line('Unthrottled recently====================');
         v_agent_msg:=  sa.adfcrm_scripts.get_generic_brand_script  ('BI' ,
                                '5005',
                                ip_lang,
                                'TAS',
                                'ALL');

       get_throttle_rslt.x_agent_msg:=v_agent_msg;
       else
       -- unthrottled more than the duration set
       dbms_output.put_line('Unthrottled beyond the duration====================');
       v_agent_msg:=sa.adfcrm_scripts.get_generic_brand_script  ('BI' ,
                                '5006',
                                ip_lang,
                                'TAS',
                                'ALL');
       get_throttle_rslt.x_agent_msg:=v_agent_msg;
       end if;
      end if;
      if get_throttle_rslt.x_throttle_date is not null then--throttled
      if (instr(get_throttle_rslt.x_throttle_desc,'NO_DATA') > 0 or instr(get_throttle_rslt.x_throttle_desc,'NODATA') > 0 or instr(get_throttle_rslt.x_throttle_desc,'DATA_CAP')> 0) then
       dbms_output.put_line('Throttle policy name contains NO_DATA or DATA_CAP or NODATA====================');
            v_agent_msg:=sa.adfcrm_scripts.get_generic_brand_script  ('BI' ,
                                '5008',
                                ip_lang,
                                'TAS',
                                'ALL');
       get_throttle_rslt.x_agent_msg:=v_agent_msg;

      else
       dbms_output.put_line('Throttled ====================');
      v_agent_msg:=sa.adfcrm_scripts.get_generic_brand_script  ('BI' ,
                                '5007',
                                ip_lang,
                                'TAS',
                                'ALL');

        v_agent_msg:= replace(v_agent_msg,'<<Throttled DATE>>', get_throttle_rslt.x_throttle_date);
        get_throttle_rslt.x_agent_msg:=v_agent_msg;
      end if;

      end if;

      if get_throttle_rslt.x_throttle_desc ='SIMPLE_FLEX_DOMROAM' then
      get_throttle_rslt.x_throttle_desc:='FLEX';
      end if;
      --updated verbiage for throttling message
     if get_throttle_rslt.x_throttle_desc ='' or get_throttle_rslt.x_throttle_desc ='N/A'   then
      get_throttle_rslt.x_throttle_desc:='Data should be working IF the customer has a plan that allows data, including PayGo for data capable phones';
      end if;

        dbms_output.put_line('Agent Message===================='||get_throttle_rslt.x_agent_msg);
      pipe row(get_throttle_rslt);
      return;
    end;
--********************************************************************************************************************
  --CR50209
  procedure get_sp_info(
                        ip_part_class varchar2,
                        ip_min varchar2,
                        ip_spobjid varchar2,
                        ip_bus_org_objid varchar2,
                        op_sp_carry_over out varchar2,
                        op_script_id out varchar2,
                        op_sp_script_text out varchar2, -- MAIN SCRIPT TO SHOW
                        op_sp_addl_script_text out varchar2, -- IF THE SP'S COS DOES NOT MATCH THE MIN'S COS - SCRIPT TO SHOW
                        op_sp_cos_value out varchar2, -- SP COS
                        op_sp_threshold_value out varchar2, -- SP THRESHOLD VALUE
                        op_subscriber_cos_value out varchar2, -- MIN COS
                        op_subscriber_threshold_value out varchar2 -- MIN'S THRESHOLD VALUE
                        )
  is
    v_script_id varchar2(30);
    v_script_bus_org varchar2(30);
    v_bo_objid varchar2(30);
    n_val number;
    function rn(char_to_num in out varchar2)
    return varchar2
    is
      n_char_to_num number;
    begin
      --dbms_output.put_line('char_to_num ('||char_to_num||')');
      n_char_to_num := to_number(nvl(char_to_num,0));

      if n_char_to_num = '0' then
        return char_to_num;
      elsif n_char_to_num >= 1000000 then
        select round(to_number(n_char_to_num)/1012000,1)
        into char_to_num
        from dual;
        char_to_num := char_to_num||'TB';
      elsif n_char_to_num >= 1024 then
        select round(to_number(n_char_to_num)/1024,1)
        into char_to_num
        from dual;
        char_to_num := char_to_num||'GB';
      else
        char_to_num := char_to_num||'MB';
      end if;

      return char_to_num;
    exception
      when others then
        return char_to_num;
    end rn;
  begin
    if ip_spobjid is null or ip_spobjid = '' then
      op_sp_carry_over := 'Yes';
      return;
    end if;

    v_bo_objid := ip_bus_org_objid;

    begin
      select org_id
      into  v_script_bus_org
      from table_bus_org
      where objid = v_bo_objid;

      if v_script_bus_org = 'SIMPLE_MOBILE' then
        begin
          select sub_brand
          into  v_script_bus_org
          from   pcpv_mv
          where  part_class = ip_part_class;

          if v_script_bus_org = 'GO_SMART' then
            select objid
            into  v_bo_objid
            from table_bus_org
            where org_id = v_script_bus_org;
          end if;
        exception
          when others then
            null;
        end;
      end if;

    exception
      when others then
        null;
    end;
    dbms_output.put_line('v_script_bus_org = ' || v_script_bus_org);
    dbms_output.put_line('v_bo_objid = ' || v_bo_objid);

    for sp_info in (
                    select sp_objid,
                      decode(fea_name,'BENEFIT_TYPE','CARRY_OVER',
                                      'SERVICE DAYS', 'SERVICE_DAYS',
                                      fea_name) fea_name,
                      decode(fea_name,
                              'BENEFIT_TYPE', decode(fea_value,'SWEEP_ADD','No',
                                                               'STACK','Yes',
                                                               'TRANSFER','N/A',
                                                                fea_display),
                                fea_display) fea_display,
                                fea_value
                      from (
                        select sp_objid, fea_name,fea_value,fea_display
                        from adfcrm_serv_plan_feat_matview
                        where (
                               fea_name LIKE 'SERVICE DAYS' or
                               fea_name like 'BENEFIT_TYPE' or
                               fea_name like '%COS%' or
                               fea_name like 'CUST_PROFILE_SCRIPT'
                               )
                        and sp_objid = ip_spobjid
                        )
                    )
      loop
          if sp_info.fea_name = 'CARRY_OVER' then
            op_sp_carry_over := sp_info.fea_display;
          end if;
          if sp_info.fea_name = 'COS' then
            op_sp_cos_value := sp_info.fea_display;
          end if;
          if sp_info.fea_name = 'CUST_PROFILE_SCRIPT' then
            v_script_id := sp_info.fea_display;
            op_script_id := sp_info.fea_display;
          end if;
      end loop;

      if v_script_bus_org = 'TRACFONE' then
        return;
      end if;

      -- BEFORE END IF CARRY OVER = 'YES'
      -- NOW ONLY END IF TRACFONE, CONTINUE FOR ALL OTHER BRANDS
      if op_sp_carry_over = 'Yes' then
        op_sp_cos_value := null;
        if v_script_bus_org = 'TRACFONE' then
          op_script_id := null;
          return;
        end if;
      else
        if ip_min not like 'T%' then
          for pmap in (
                        select cos, threshold
                        from x_policy_mapping_config a,
                             x_subscriber_spr b
                        where b.pcrf_min = ip_min
                        and a.cos = b.pcrf_cos
                        and a.usage_tier_id = 2
                        and rownum < 2
                        )
          loop
            op_subscriber_cos_value  := pmap.cos;
            op_subscriber_threshold_value   := pmap.threshold;
          end loop;
        end if;

        begin
          -- THIS IS THE ALLOTED HIGHSPEED BASE FOR THIS SERVICE PLAN
          -- USE THE MIN INSTEAD OF SERVICE PLAN
          select mc.threshold
          into op_sp_threshold_value
          from x_policy_mapping_config mc
          where mc.cos = op_sp_cos_value
          and  mc.usage_tier_id = '2'
          and mc.inactive_flag = 'N'
          and rownum < 2;
        exception
          when others then
            op_sp_threshold_value := 'UNABLE_TO_FIND';
        end;

      end if;

      for stxt in (
                   select x_script_text
                   from   sa.table_x_scripts
                   where  1=1
                   and x_script_type = substr(v_script_id,0,instr(v_script_id,'_')-1)
                   and x_script_id = substr(v_script_id,instr(v_script_id,'_')+1)
                   and x_language = 'ENGLISH'
				   and x_sourcesystem ='TAS'
                   and script2bus_org = v_bo_objid
                   )
      loop
        op_sp_script_text := stxt.x_script_text;
      end loop;

      if op_sp_script_text is null and
          v_script_id is NOT null then
        op_sp_script_text := 'SCRIPT MISSING ('||v_script_id||') ';
      end if;
      if op_sp_script_text is null and
          v_script_id is null
      then
        op_sp_script_text := 'NO SCRIPT ID ASSIGNED';
      end if;

      -- THE ADDITIONAL SCRIPT ONLY APPLIES IF THE BENEFITS DON'T CARRY OVER
      if op_sp_carry_over != 'Yes' then

        op_subscriber_threshold_value := rn(char_to_num => op_subscriber_threshold_value);
        op_sp_threshold_value := rn(char_to_num => op_sp_threshold_value);
        n_val := instr(op_subscriber_threshold_value,'TB');
        if op_subscriber_cos_value != op_sp_cos_value then
          if n_val = 0 then
            for astxt in (
                            select x_script_text,x_script_id
                            from   sa.table_x_scripts
                            where x_script_type = 'TAS'
                            and x_script_id = '5008'
                            and x_language = 'ENGLISH'
                          )
            loop
              op_sp_addl_script_text := replace(astxt.x_script_text,'[cos_threshold_data]',op_subscriber_threshold_value);
            end loop;
          else
            for astxt in (
                          select x_script_text,x_script_id
                          from   sa.table_x_scripts
                          where x_script_type = 'TAS'
                          and x_script_id = '5009'
                          and x_language = 'ENGLISH'
                        )
            loop
              op_sp_addl_script_text := replace(astxt.x_script_text,'[cos_threshold_data]',op_subscriber_threshold_value);
            end loop;
          end if;
        end if;
      end if;
  exception
    when others then
      dbms_output.put_line('ERROR OBTAINING SP_INFO=>'||sqlerrm||'<=');
  end get_sp_info;
--********************************************************************************************************************
end adfcrm_vo;
-- ANTHILL_TEST PLSQL/SA/PackageBodies/ADFCRM_VO_PKB.sql 	REL957_TAS: 1.217
/