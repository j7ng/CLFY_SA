CREATE OR REPLACE PROCEDURE sa."DEFECTIVE_PHONE_SIM_PRC" (
 ip_esn IN VARCHAR2,
 ip_zipcode IN VARCHAR2, --Only for inactive or want a new line
 ip_action IN VARCHAR2,
 op_curr_tech OUT VARCHAR2,
 op_status OUT VARCHAR2,
 op_model OUT VARCHAR2,
 op_curr_sim_prof OUT VARCHAR2,
 op_curr_min OUT VARCHAR2,
 op_curr_carrier_id OUT NUMBER,
 op_curr_parent_id OUT NUMBER,
 op_curr_zip_code OUT VARCHAR2,
 op1_port OUT VARCHAR2,
 op1_carr_id OUT NUMBER,
 op1_parent_id OUT NUMBER,
 op1_case_conf OUT NUMBER,
 op1_repl_part OUT VARCHAR2,
 op1_repl_sim_prof OUT VARCHAR2,
 op1_repl_units OUT NUMBER,
 op1_repl_days OUT NUMBER,
 op1_issue OUT VARCHAR2,
 op2_port OUT VARCHAR2,
 op2_carr_id OUT NUMBER,
 op2_parent_id OUT NUMBER,
 op2_case_conf OUT NUMBER,
 op2_repl_part OUT VARCHAR2,
 op2_repl_sim_prof OUT VARCHAR2,
 op2_repl_units OUT NUMBER,
 op2_repl_days OUT NUMBER,
 op2_issue OUT VARCHAR2,
 op2_bribe_units OUT NUMBER,
 op_error_num OUT VARCHAR2,
 op_error_msg OUT VARCHAR2
)
IS
 ---------------------------------------------------------------------------------------------
 --$RCSfile: DEFECTIVE_PHONE_SIM_PRC.sql,v $
 --$Revision: 1.50 $
 --$Author: rpednekar $
 --$Date: 2016/10/12 19:42:58 $
 --$ $Log: DEFECTIVE_PHONE_SIM_PRC.sql,v $
 --$ Revision 1.50  2016/10/12 19:42:58  rpednekar
 --$ CR45518 - Removed  'Warehouse' type cases check.
 --$
 --$ Revision 1.49  2016/07/28 18:52:50  nguada
 --$ Bug fix based on production incident 7/28/2016
 --$
 --$ Revision 1.48  2016/04/14 15:43:24  sraman
 --$ CR32498 - Merged with production code which got deployed on 4/14 (version 1.47)
 --$
  --$ Revision 1.47  2016/04/07 21:14:57  pamistry
  --$ CR39592 - FCC
  --$
  --$ Revision 1.41  2016/03/04 20:04:25  aganesan
  --$ CR39105 Defect fix for 10965
  --$
  --$ Revision 1.40  2016/03/03 20:02:56  aganesan
  --$ Defect10965 fix for CR39105
  --$
  --$ Revision 1.39  2015/08/12 18:27:13  nguada
  --$ CR36170 Defective Phone Fix
  --$
  --$ Revision 1.38  2015/06/11 19:49:42  clinder
  --$ CR34349
  --$
  --$ Revision 1.37  2015/03/19 13:34:33  clinder
  --$ CR25114
  --$
  --$ Revision 1.34  2015/02/19 14:19:02  clinder
  --$ CR25114
  --$
  --$ Revision 1.33  2015/02/18 20:35:10  clinder
  --$ CR25114
  --$
  --$ Revision 1.32  2014/06/07 15:31:12  clinder
  --$ CR25988
  --$
  --$ Revision 1.31  2014/06/06 20:34:34  clinder
  --$ CR25988
  --$
  --$ Revision 1.30  2014/05/09 17:19:18  clinder
  --$ CR23419
  --$
  --$ Revision 1.29  2014/05/08 15:33:46  clinder
  --$ CR23419
  --$
  --$ Revision 1.28  2014/04/22 15:12:11  clinder
  --$ CR23419
  --$
  --$ Revision 1.27  2014/04/22 13:03:49  clinder
  --$ CR23419
  --$
  --$ Revision 1.26  2014/04/17 16:03:30  clinder
  --$ CR23419
  --$
  --$ Revision 1.25  2013/12/11 14:48:20  ymillan
  --$ CR26532 add with natalio changes 12/11/13
  --$
  --$ Revision 1.22  2013/11/11 17:15:23  clinder
  --$ CR26532
  --$
  --$ Revision 1.17  2013/07/08 21:34:49  ymillan
  --$ CR22799 CR24253
  --$
  --$ Revision 1.15  2011/11/23 15:06:08  pmistry
  --$ Comment Added
  --$
  ---------------------------------------------------------------------------------------------


/************************************************************************************************
   |    Copyright   Tracfone  Wireless Inc. All rights reserved
   |
   | PURPOSE  :  Defective Phone Defective SIM Replacement Logic
   | FREQUENCY:  On Demand
   | PLATFORMS:  WEBCSR
   |
   | REVISIONS:
   | VERSION  DATE        WHO              PURPOSE
   | -------  ---------- -----             ------------------------------------------------------
   | 1.0      09/22/08   Natalio Guada      Bug fixes CR8013
   | 1.1      09/30/08   Natalio Guada      Bug fixes CR8013
   | 1.2      10/01/08   Natalio Guada      Bug fixes CR8013
   | 1.3      10/08/08   Vani Adapa         Added the right grant options
   | 1.4      11/12/08   Ingrid Canavan     CR7896 Add 2 more ways to find refurbished phones
   | 1.4.1.0-1.4.1.1 11/66/09 Natalio Guada CR12155 ST_BUNDLE_III
   | 1.4.1.2  01/05/10   Natalio Guada      CR11622   BRAND_SEP_IV

   | CVS REPOSITORY
   | 1.2      04/26/10  Natalio Guada       CR10777 Zip code Activation Phase 1 TMO
   |                                        modify cur_avail_carriers to use new table CARRIERSIMPREF
   | 1.3      07/23/10  Vadapa              ST_GSM_II
   | 1.7         10/20/10  Natalio Guada       Add Min Max restriction for SIM Exchanges
   | 1.8         10/22/10  Natalio Guada       CR14598
   | 1.13     07/29/2011   kacosta          CR16527 - SQLs on carrier tables causing contention
   |************************************************************************************************/

   CURSOR c_repl_part(c_tech IN VARCHAR2,
                      c_old_esn_part_num_objid IN NUMBER,
                      c_data_service IN NUMBER,
                      c_frequency_1 IN NUMBER,
                      c_frequency_2 IN NUMBER,
                      c_refurb_flag IN NUMBER,
                      c_parent_id IN NUMBER,
                      c_action IN VARCHAR2,
                      c_2g_turn_down in number)   IS
   SELECT f.x_frequency,
          exch.x_new_part_num,
          exch.x_used_part_num,
          DECODE(c_refurb_flag, 1, exch.x_used_part_num, exch.x_new_part_num)
          pref_part_num,
          exch.x_days_for_used_part,
          exch.X_BONUS_DAYS,
          exch.X_BONUS_UNITS,
          pn.x_technology,
          exch.x_priority,
          pn.x_dll,
          nvl((select v.x_param_value
                  from table_x_part_class_values v,
                       table_x_part_class_params n
                 where 1=1
                   and v.value2part_class     = pn.part_num2part_class
                   and v.value2class_param    = n.objid
                   and n.x_param_name         = 'PHONE_GEN'
                   and rownum <2),'2G') phone_gen
     FROM table_x_frequency f,
          mtm_part_num14_x_frequency0 pf,
          table_part_num pn,
          table_x_class_exch_options exch,
          table_x_part_class_values v,
          table_x_part_class_params n,
	  (select x_parent_name
             from table_x_parent pa
            where pa.x_parent_id = c_parent_id) pa
    WHERE 1 = 1
--
      and nvl(v.x_param_value,'2G') != decode(c_2g_turn_down,1,'2G','XX')
      and v.value2part_class(+)     = pn.part_num2part_class
      and n.x_param_name       = 'PHONE_GEN'
      and n.objid(+) = v.value2class_param
--
      AND f.x_frequency IN (c_frequency_1, c_frequency_2)
      AND f.objid = pf.x_frequency2part_num
      And Pf.Part_Num2x_Frequency = Pn.Objid
      AND pn.part_number = DECODE(c_refurb_flag, 1, exch.x_used_part_num, exch.x_new_part_num)
      AND exch.x_exch_type = DECODE(c_action, 'DEFECTIVE_PHONE', 'WAREHOUSE','GOODWILL', 'GOODWILL','UNLOCK','UNLOCK', 'WAREHOUSE')	-- CR45518 Removed "TECHNOLOGY"			-- CR39592 03/08/2016 PMistry Added exchange type Unlock
      AND exch.source2part_class = ( SELECT part_num2part_class
                                       FROM table_part_num
                                      WHERE objid = c_old_esn_part_num_objid)
      AND pn.x_technology = c_tech
      AND pn.part_num2part_class NOT IN ( SELECT x_part_class_objid
                                            FROM table_x_not_certify_models
                                           WHERE x_parent_id = c_parent_id
										   AND x_part_class_objid is not null)
      AND NVL(pn.x_meid_phone, 0) <= ( SELECT NVL(x_meid_carrier, 0)
                                         FROM table_x_parent
                                        WHERE x_parent_id = c_parent_id)
   ORDER BY exch.x_priority ASC;
   rec_repl_part c_repl_part%ROWTYPE;

   CURSOR get_refurb_cnt
   IS
   SELECT x_refurb_flag
   FROM table_site_part sp_a
   WHERE sp_a.x_service_id = ip_esn
   AND sp_a.x_refurb_flag = 1;
   get_refurb_cnt_rec get_refurb_cnt%ROWTYPE;

--CR26532
   CURSOR cur_plus_45_days(c_part_class_objid in number)
   IS
   select nvl(trunc(sysdate)-install_date,0) days_in_use
   from table_site_part
   where x_service_id = ip_esn
   and part_status in ('Active','Inactive','CarrierPending')
   and nvl(x_refurb_flag,0) = 0
   and nvl(trunc(sysdate)-install_date,0) >= (select nvl(min(x_days_for_used_part),0)
                                               from table_x_class_exch_options
                                               where source2part_class = c_part_class_objid
                                               and x_exch_type = DECODE(ip_action, 'DEFECTIVE_PHONE', 'WAREHOUSE','GOODWILL', 'GOODWILL','UNLOCK','UNLOCK','WAREHOUSE')    --CR45518 Removed "TECHNOLOGY"  -- CR39592 03/08/2016 PMistry Added exchange type Unlock
                                               and nvl(x_days_for_used_part,0) >0)
   order by install_date asc;
   rec_plus_45_days cur_plus_45_days%ROWTYPE;
--CR26532

   -- CR7896
   CURSOR get_refurb_150
   IS
   SELECT *
   FROM table_part_inst
   WHERE part_serial_no = ip_esn
   AND x_part_inst_status = '150' ;
   get_refurb_150_rec get_refurb_150%ROWTYPE;

   CURSOR get_refurb_desc
   IS
   select pn.part_number, pn.description
     from table_part_inst pi, table_part_num pn, table_mod_level ml,table_part_class pc
    where pi.n_part_inst2part_mod = ml.objid
      and ml.part_info2part_num=pn.objid
      and pn.part_num2part_class=pc.objid
      and pi.PART_SERIAL_NO = ip_esn
      and UPPER(pn.description) like '%REFURB%' ;
      get_refurb_desc_rec get_refurb_desc  %ROWTYPE;
   -- CR7896 end

-- CR12155 ADDED PCV.X_PARAM_VALUE TO CURSOR
   CURSOR cur_esn_details(ip_esn VARCHAR2) IS
     SELECT PI.X_PART_INST_STATUS ESN_STATUS,
            pn.X_TECHNOLOGY  x_technology,
            pc.name part_class,
            pn.X_DATA_CAPABLE,
            pi.X_ICCID,
            NVL(pn.x_meid_phone, 0) x_meid_phone,
            nvl((SELECT 800
                   FROM MTM_PART_NUM14_X_FREQUENCY0 pf,
                        TABLE_X_FREQUENCY f
                  WHERE 1=1
                    AND pf.part_num2x_frequency = pn.objid
                    and f.objid = pf.x_frequency2part_num
                   and  f.x_frequency = 800),0) x_frequency1,
            nvl((SELECT 1900
                   FROM MTM_PART_NUM14_X_FREQUENCY0 pf,
                        TABLE_X_FREQUENCY f
                  WHERE 1=1
                    AND pf.part_num2x_frequency = pn.objid
                    and f.objid = pf.x_frequency2part_num
                   and  f.x_frequency = 1900),0) x_frequency2,
            pn.objid part_num_objid,
            pn.part_num2part_class,
            pc.name,
            pn.x_dll,
            nvl((select v.x_param_value
                  from table_x_part_class_values v,
                       table_x_part_class_params n
                 where 1=1
                   and v.value2part_class     = pn.part_num2part_class
                   and v.value2class_param    = n.objid
                   and n.x_param_name         = 'PHONE_GEN'
                   and rownum <2),'2G') phone_gen,
            (SELECT COUNT(*)
               FROM x_sl_currentvals
              WHERE x_current_esn= pi.part_serial_no
                AND rownum < 2) safelink
       FROM
            sa.TABLE_PART_INST pi,
            sa.TABLE_MOD_LEVEL ml,
            sa.TABLE_PART_NUM  pn,
            sa.TABLE_PART_CLASS pc
      WHERE 1=1
        AND pi.x_domain = 'PHONES'
        AND pi.part_serial_no = ip_esn
        AND ml.objid = pi.n_part_inst2part_mod
        and pn.objid = ml.part_info2part_num
        AND pc.objid = pn.part_num2part_class;

   rec_esn_details cur_esn_details%ROWTYPE;
   CURSOR cur_service(ip_esn IN VARCHAR2 ) IS
     SELECT sp.x_min,
            pi.x_part_inst_status line_status,
	    pn.part_num2part_class part_class_objid,
            ca.x_carrier_id,
            pa.x_parent_id,
            pa.x_parent_name,
            sp.x_zipcode,
            pa.X_AUTO_PORT_OUT,
            sp.X_ICCID,
            nvl(( select 'YES'
                    from table_x_carrier_rules cr
                   where cr.objid = decode(pn.x_technology,'CDMA', ca.CARRIER2RULES_CDMA,
                                                           'GSM' , ca.CARRIER2RULES_GSM , ca.CARRIER2RULES)
                     and cr.x_allow_2g_react = '2G'
                     and rownum < 2 ),'NO') react_2g,
            nvl(( select 'YES'
                    from table_x_carrier_rules cr
                   where cr.objid = decode(pn.x_technology,'CDMA', ca.CARRIER2RULES_CDMA,
                                                           'GSM' , ca.CARRIER2RULES_GSM , ca.CARRIER2RULES)
                     and cr.x_allow_2g_react = '2G'
                     and rownum < 2 ),'NO') act_2g
       FROM sa.table_site_part sp,
            sa.table_part_inst pi_esn,
            sa.table_mod_level ml,
            sa.table_part_num pn,
            sa.table_part_inst pi,
            sa.table_x_carrier ca,
            sa.table_x_carrier_group cg,
            sa.table_x_parent pa
      WHERE sp.X_SERVICE_ID = ip_esn
        AND sp.PART_STATUS = 'Active'
        AND pi_esn.PART_SERIAL_NO = ip_esn
        AND pi_esn.X_DOMAIN = 'PHONES'
        and ml.objid = pi_esn.N_PART_INST2PART_MOD
        and pn.objid = ml.part_info2part_num
        AND pi.PART_SERIAL_NO = sp.x_min
        AND pi.X_DOMAIN = 'LINES'
        AND ca.OBJID = pi.PART_INST2CARRIER_MKT
        AND cg.OBJID = ca.CARRIER2CARRIER_GROUP
        AND pa.objid = cg.X_CARRIER_GROUP2X_PARENT;
   rec_service cur_service%ROWTYPE;

   CURSOR cur_sim_profile(
      ip_iccid IN VARCHAR2
   )
   IS
   SELECT x_sim_inv_status,
      part_number sim_profile
   FROM sa.table_x_sim_inv sim, sa.table_mod_level ml, sa.table_part_num pn
   WHERE sim.X_SIM_INV2PART_MOD = ml.OBJID
   AND ml.PART_INFO2PART_NUM = pn.OBJID
   AND sim.x_sim_serial_no = ip_iccid;
   rec_sim_profile cur_sim_profile%ROWTYPE;

-- CR12155 ST_BUNDLE_III MODIFIED WITH IP_NON_PPE
-- CR10777 Zip code Activation Phase 1 TMO
   CURSOR cur_avail_carriers( ip_zip VARCHAR2,
                              ip_dll NUMBER,
                              ip_parent_name varchar2 ) IS
     select distinct
            tab1.carrier_id
           ,tab1.frequency1
           ,tab1.frequency2
           ,tab1.sim_profile
           ,DECODE(tab1.cdma_tech,'CDMA',1,0) cdma_tech
           ,DECODE(tab1.tdma_tech,'TDMA',1,0) tdma_tech
           ,DECODE(tab1.gsm_tech,'GSM',1,0) gsm_tech
           ,NVL(pa.x_auto_port_in ,0) auto_port_in
           ,NVL(pa.x_meid_carrier,0) meid_allowed
           ,NVL(pa.x_block_port_in,0) block_port_in
           ,NVL(ca.x_data_service,0) data_service
           ,pa.x_parent_id
           ,pa.x_parent_name
           ,tab1.new_rank
           ,tab1.RANK
           ,nvl(( select 'YES'
                    from table_x_carrier_rules cr
                   where cr.objid = decode(tab2.x_technology,'CDMA', ca.CARRIER2RULES_CDMA,
                                                           'GSM' , ca.CARRIER2RULES_GSM , ca.CARRIER2RULES)
                     and cr.x_allow_2g_react = '2G'
                     and rownum < 2 ),'NO') react_2g
           ,nvl(( select 'YES'
                    from table_x_carrier_rules cr
                   where cr.objid = decode(tab2.x_technology,'CDMA', ca.CARRIER2RULES_CDMA,
                                                           'GSM' , ca.CARRIER2RULES_GSM , ca.CARRIER2RULES)
                     and cr.x_allow_2g_react = '2G'
                     and rownum < 2 ),'NO') act_2g
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
                    and decode(cf.X_SWITCH_BASE_RATE,null,tab2.non_ppe,1) = tab2.non_ppe)
   ORDER BY
   --CR32498 begin
              sa.is_shippable(tab1.sim_profile) DESC  ,
    --CR32498 ends
           decode(decode(substr(pa.x_parent_name,1,2),'AT','AT','CI','AT',substr(pa.x_parent_name,1,2)),
		  decode(substr(ip_parent_name,1,2),'AT','AT','CI','AT',substr(ip_parent_name,1,2)),1,2)
           , decode(substr(tab1.sim_profile,1,2),'TF',1,2)--CR26651
           ,tab1.new_rank
           ,Tab1.rank;
--CR23419
   v_sim_change NUMBER;
   v_bribe_param VARCHAR2(30) := 'INTPORTIN_PROMO_UNITS';
   v_bribe_units NUMBER;
   v_port_type VARCHAR2(30);
   v_carrier_id NUMBER;
   v_parent_id NUMBER;
   v_handset_change NUMBER ;
   v_2g_turn_down NUMBER := 0;
   v_keep_data NUMBER;
   v_coverage BOOLEAN;
   v_value NUMBER := 0;
   v_max_value NUMBER := 0;
   v_case_config NUMBER;
   v_case_issue VARCHAR2(50);
   keep_data NUMBER;
   handset_change1 NUMBER;
   port_type VARCHAR2(30);
   sim_change NUMBER;
   new_tech VARCHAR2(50);
   sim_prof VARCHAR2(30);
   refurb_flag NUMBER;
   freq_1 NUMBER;
   freq_2 NUMBER;
   repl_part VARCHAR2(30);
   zip_code VARCHAR2(10);
   v_value2 NUMBER := 0;
   v_max_value2 NUMBER := 0;
   sim_change2 NUMBER;
   handset_change2 NUMBER;
   new_tech2 VARCHAR2(50);
   sim_prof2 VARCHAR2(50);
   op1_keep_data NUMBER;
   op2_keep_data NUMBER;
   res_min VARCHAR2(30);
   MEID_FLAG1 NUMBER;
   MEID_FLAG2 NUMBER;
   IS_ESN_LTE NUMBER; --CR22799
   X_DLL     VARCHAR2(30); --CR22799

   CURSOR cur_eval_carrier(
      ip_port IN VARCHAR2
   )
   IS
   SELECT *
   FROM sa.X_EQUIP_COVERAGE_CONFIG
   WHERE x_port_type = ip_port
   AND x_handset_change = v_handset_change
   AND x_sim_change = v_sim_change
   AND x_keep_data_serv = v_keep_data
   AND x_action = ip_action;
   rec_eval_carrier cur_eval_carrier%ROWTYPE;
   -- Line reserved for an inactive phone
   CURSOR cur_line_reserved(
      ip_esn IN VARCHAR2,
      ip_carrier_id IN VARCHAR2
   )
   IS
   SELECT lp.part_serial_no
   FROM table_part_inst lp, table_x_carrier ca
   WHERE lp.part_to_esn2part_inst IN (
   SELECT ep.objid
   FROM table_part_inst ep
   WHERE ep.part_serial_no = ip_esn
   AND ep.x_domain||'' = 'PHONES'
   AND ep.x_part_inst_status||'' <> '52')
   AND lp.x_domain||'' = 'LINES'
   AND lp.x_part_inst_status IN ('37', '39')
   AND ca.x_carrier_id = ip_carrier_id
   AND lp.PART_INST2CARRIER_MKT = ca.objid;
   rec_line_reserved cur_line_reserved%ROWTYPE;
   CURSOR cur_same_zipcode(
      ip_esn IN VARCHAR2,
      ip_min IN VARCHAR2,
      ip_zip IN VARCHAR2
   )
   IS
   SELECT *
   FROM table_site_part
   WHERE x_service_id = ip_esn
   AND x_min = ip_min
   AND x_zipcode = ip_zip;
   rec_same_zipcode cur_same_zipcode%ROWTYPE;
   CURSOR cur_not_certify_model(ip_part_class_objid IN NUMBER,
                                ip_parent_id        IN NUMBER ) IS
     SELECT *
       FROM table_x_not_certify_models
      WHERE x_part_class_objid = ip_part_class_objid
        AND x_parent_id = ip_parent_id;
   rec_not_certify_model cur_not_certify_model%ROWTYPE;
BEGIN
   op_error_num := '0';
   op_error_msg := '';
   V_COVERAGE := FALSE;
   IS_ESN_LTE:=1;
   x_dll := null;
   -- Make Sure we receive A Valid Action
   IF ip_action <> 'DEFECTIVE_SIM'
   AND IP_ACTION <> 'DEFECTIVE_PHONE'
   and ip_action <> 'GOODWILL'      -- CR14033 PM 11/14/2011
   and ip_action <> 'UNLOCK'        -- CR39592 03/08/2016 PMistry Added exchange type Unlock
   THEN
      op_error_num := '5';
      op_error_msg := 'Not a valid action';
      RETURN;
   END IF;
   -- Get ESN Details
   OPEN cur_esn_details(ip_esn);
   FETCH cur_esn_details
   INTO rec_esn_details;
   IF cur_esn_details%NOTFOUND
   THEN
      CLOSE cur_esn_details;
      op_error_num := '10';
      op_error_msg := 'ESN Not Found';
      RETURN;
   END IF;
   CLOSE cur_esn_details;

  dbms_output.put_line ('found ESN detail  ');
   -- id Refurbish phone
   -- search by x_refurb flag in table_site_part
   -- search by x_part_inst_status in table_part_inst
   -- search by description in table_part_num
   --CR22799
   begin
   SELECT sa.LTE_SERVICE_PKG.IS_LTE_4G_SIM_REM(IP_ESN)
   INTO IS_ESN_LTE
   FROM DUAL;
    EXCEPTION
      WHEN others THEN
        IS_ESN_LTE := 1;
        NULL;
    END;

    OPEN get_refurb_cnt;
   FETCH get_refurb_cnt
    INTO get_refurb_cnt_rec;
    OPEN get_refurb_150;
   FETCH get_refurb_150
    INTO get_refurb_150_rec;
    OPEN get_refurb_desc;
   FETCH get_refurb_desc
    INTO get_refurb_desc_rec;

   IF get_refurb_cnt%found or get_refurb_150%found or get_refurb_desc%found
   THEN
      refurb_flag := 1;
   ELSE
      OPEN cur_plus_45_days(rec_esn_details.part_num2part_class); --CR26532
      FETCH cur_plus_45_days
      INTO rec_plus_45_days;
      IF cur_plus_45_days%found
      THEN
         refurb_flag := 1;
      ELSE
         refurb_flag := 0;
      END IF;
      CLOSE cur_plus_45_days;
   END IF;
   CLOSE get_refurb_cnt;
   CLOSE get_refurb_150;
   CLOSE get_refurb_desc;

   DBMS_OUTPUT.put_line('Refurb Flag: '||refurb_flag);

   -- DEFECTIVE SIM only valid for GSM
   IF IP_ACTION = 'DEFECTIVE_SIM'
   AND ( REC_ESN_DETAILS.X_TECHNOLOGY <> 'GSM' and IS_ESN_LTE <> 0 ) --CR22799
   THEN
      OP_ERROR_NUM := '15';
      op_error_msg := 'Invalid Action, ESN is not GSM';
      RETURN;
   END IF;
   op_curr_tech := rec_esn_details.x_technology;
   op_status := rec_esn_details.esn_status;
   OP_MODEL := REC_ESN_DETAILS.PART_CLASS;
   DBMS_OUTPUT.PUT_LINE ('found op_curr_tech:'||OP_CURR_TECH);
   DBMS_OUTPUT.PUT_LINE ('found op_status:'||op_status);
   dbms_output.put_line ('found OP_MODEL:'||OP_MODEL);
   -- Ivalid Data, Active ESN with No SITE PART
   IF REC_ESN_DETAILS.ESN_STATUS = '52'
    or (REC_ESN_DETAILS.ESN_STATUS = '50' and IS_ESN_LTE = 0 ) --CR22799
   THEN
      dbms_output.put_line ('Into ESN detail');
      OPEN CUR_SERVICE(IP_ESN);
      FETCH cur_service
      INTO REC_SERVICE;
      IF cur_service%notfound and IS_ESN_LTE <> 0
      THEN
         CLOSE cur_service;
         op_error_num := '20';
         op_error_msg := 'Active Site Part Not Found';
         RETURN;
      ELSE
         IF OP_CURR_TECH = 'GSM' OR
            (op_curr_tech = 'CDMA' and IS_ESN_LTE = 0 )
         THEN
          --  DBMS_OUTPUT.PUT_LINE ('GSM PHONE');
            OPEN cur_sim_profile(rec_service.x_iccid);
            FETCH cur_sim_profile
            INTO rec_sim_profile;
            IF cur_sim_profile%found
            THEN
              -- dbms_output.put_line ('found SIM '||to_char(rec_service.x_iccid));
               OP_CURR_SIM_PROF := REC_SIM_PROFILE.SIM_PROFILE;
            END IF;
            CLOSE cur_sim_profile;
         END IF;
         op_curr_min := rec_service.x_min;
         op_curr_carrier_id := rec_service.x_carrier_id;
         op_curr_parent_id := rec_service.x_parent_id;
         OP_CURR_ZIP_CODE := REC_SERVICE.X_ZIPCODE;
     ---    DBMS_OUTPUT.PUT_LINE ('found MIN '||TO_CHAR(REC_SERVICE.X_MIN));
     --    DBMS_OUTPUT.PUT_LINE ('found carrier_id '||TO_CHAR(REC_SERVICE.X_CARRIER_ID));
      --   DBMS_OUTPUT.PUT_LINE ('found parent_id '||TO_CHAR(REC_SERVICE.X_PARENT_ID));
     --    dbms_output.put_line ('found zip_code '||to_char(REC_SERVICE.X_ZIPCODE));

      END IF;
      CLOSE cur_service;
      IF ip_zipcode
      IS
      NULL
      THEN
         zip_code := rec_service.x_zipcode;
      ELSE
         zip_code := ip_zipcode;
      END IF;
   ELSE

      -- Validate zip code here
      zip_code := ip_zipcode;
   END IF;
   DBMS_OUTPUT.put_line('Zip Code: '||zip_code);
   --UPG_UNITS_PKG.GET_PROMO_UNITS(v_bribe_param, v_bribe_units, ip_esn);
   op2_bribe_units := v_bribe_units;

 -- CR12155 ST_BUNDLE_III MODIFIED WITH NON_PPE
   DBMS_OUTPUT.put_line('rec_esn_details.x_dll: '||to_char(rec_esn_details.x_dll));
   DBMS_OUTPUT.put_line('rec_esn_details.safelink: '||to_char(rec_esn_details.safelink));
   FOR rec_carrier IN cur_avail_carriers(zip_code,rec_esn_details.x_dll,rec_service.x_parent_name ) LOOP
     v_handset_change := 0;
     dbms_output.put_line('rec_service.x_parent_name:'||rec_service.x_parent_name);
     dbms_output.put_line('rec_service.x_parent_id:'||rec_service.x_parent_id);
     dbms_output.put_line('rec_carrier.x_parent_name:'||rec_carrier.x_parent_name);
     dbms_output.put_line('rec_service.act_2g:'||rec_service.act_2g);
     dbms_output.put_line('rec_service.react_2g:'||rec_service.react_2g);
     dbms_output.put_line('rec_service.part_class_objid:'||rec_service.part_class_objid);
     dbms_output.put_line('rec_esn_details.phone_gen:'||rec_esn_details.phone_gen);
     dbms_output.put_line('rec_carrier.sim_profile:'||rec_carrier.sim_profile);
     dbms_output.put_line('rec_esn_details.safelink:'||rec_esn_details.safelink);
     if     (rec_service.x_parent_name like 'AT%' or rec_service.x_parent_name = 'CINGULAR')
        and upper(rec_service.act_2g) = 'NO'
        and upper(rec_service.react_2g) = 'NO'
        and rec_esn_details.phone_gen = '2G'
        --and rec_esn_details.safelink != 1
        then
       v_handset_change := 1;
       v_2g_turn_down := 1;
       dbms_output.put_line(' v_2g_turn_down := 1; ');
     elsif  rec_esn_details.phone_gen = '2G'
        and upper(rec_carrier.react_2g) = 'NO' then
       v_handset_change := 1;
     end if;
     DBMS_OUTPUT.put_line('rec_carrier.carrier_id: '||rec_carrier.carrier_id);
     DBMS_OUTPUT.put_line('rec_service.x_carrier_id: '||rec_service.x_carrier_id);
     DBMS_OUTPUT.put_line('rec_esn_details.esn_status: '||rec_esn_details.esn_status);
     DBMS_OUTPUT.put_line('rec_carrier.auto_port_in: '||rec_carrier.auto_port_in);
     DBMS_OUTPUT.put_line('rec_service.x_auto_port_out: '||rec_service.x_auto_port_out);
     -- DBMS_OUTPUT.put_line('rec_esn_details.x_dll: '||to_char(rec_esn_details.x_dll));
     -- ESN is Active and does not want a new number
     -- Determine Port Type
      freq_1 := rec_carrier.frequency1;
      freq_2 := rec_carrier.frequency2;
      IF rec_esn_details.esn_status = '52' AND ip_zipcode IS NULL THEN
         IF rec_carrier.carrier_id = rec_service.x_carrier_id
         OR (rec_carrier.auto_port_in = 2
         AND rec_service.x_auto_port_out = 2)
         THEN
            v_port_type := 'SAME_CARRIER';
            dbms_output.put_line('v_port_type := ''SAME_CARRIER''');
         ELSE
           dbms_output.put_line('else v_port_type := ''SAME_CARRIER''');
            --if rec_carrier.auto_port_in = 1
            --   and rec_service.x_auto_port_out=1 then
            --    v_port_type := 'AUTO';
            --else
            IF rec_carrier.block_port_in = 1
            THEN
               v_port_type := 'BLOCKED';
            ELSE
               v_port_type := 'MANUAL';
            END IF;

         --end if;
         END IF;
         dbms_output.put_line('v_port_type:'||v_port_type);
      ELSE
  	dbms_output.put_line('else v_port_type := ''NEW_LINE''');
         v_port_type := 'NEW_LINE';
         IF ip_action = 'DEFECTIVE_SIM'
         THEN

         --  dbms_output.put_line('Go by DEFECTIVE_SIM 1');
            OPEN cur_line_reserved(ip_esn, rec_carrier.carrier_id);
            FETCH cur_line_reserved
            INTO rec_line_reserved;
            IF cur_line_reserved%found
            THEN
               res_min := rec_line_reserved.part_serial_no;
               OPEN cur_same_zipcode(ip_esn, res_min, zip_code);
               FETCH cur_same_zipcode
               INTO rec_same_zipcode;
               IF cur_same_zipcode%found
               THEN
                  v_port_type := 'LINE_RESERVED';
                  DBMS_OUTPUT.put_line('Port Type: '||v_port_type);
               END IF;
               CLOSE cur_same_zipcode;
            END IF;
            CLOSE cur_line_reserved;
         END IF;
      END IF;
      IF rec_carrier.gsm_tech = 1
      THEN
         v_sim_change := 1;
      ELSE
      --cr22799
         IF IS_ESN_LTE = 0 THEN
            V_SIM_CHANGE := 1;
         ELSE
            V_SIM_CHANGE := 0;
         end if;

      END IF;

dbms_output.put_line('ip_action:'||ip_action);
dbms_output.put_line('DEFECTIVE_SIM v_handset_change:'||v_handset_change);
      IF ip_action = 'DEFECTIVE_SIM' --THEN
        and  nvl(v_handset_change,0) != 1 then
        dbms_output.put_line('Go by DEFECTIVE_SIM 2');
        v_handset_change := 0; -- Default Value
        IF    (rec_esn_details.x_technology = 'GSM' AND rec_carrier.gsm_tech = 1 )
           OR (rec_esn_details.x_technology = 'CDMA' AND rec_carrier.cdma_tech = 1)
           OR (rec_esn_details.x_technology = 'TDMA' AND rec_carrier.tdma_tech = 1) THEN
          v_handset_change := 0;  -- Default Value
        ELSE
          v_handset_change := 1;
          DBMS_OUTPUT.put_line ('handset change because Tech mismatch');
        END IF;
        IF     rec_esn_details.x_frequency1 <> rec_carrier.frequency1
           AND rec_esn_details.x_frequency2 <> rec_carrier.frequency1
           AND rec_esn_details.x_frequency1 <> rec_carrier.frequency2
           AND rec_esn_details.x_frequency2 <> rec_carrier.frequency2 THEN
          v_handset_change := 1;
          DBMS_OUTPUT.put_line ('handset change because Frequency mismatch');
        END IF;
        IF rec_esn_details.x_meid_phone = 1 AND NVL(rec_carrier.meid_allowed, 0) = 0 THEN
          v_handset_change := 1;
          DBMS_OUTPUT.put_line ('handset change because MEID');
        END IF;

        DBMS_OUTPUT.PUT_LINE('part_class : '||REC_ESN_DETAILS.PART_NUM2PART_CLASS);
        DBMS_OUTPUT.PUT_LINE('parent_id : '|| rec_carrier.x_parent_id);

        OPEN cur_not_certify_model (rec_esn_details.part_num2part_class,
                                    rec_carrier.x_parent_id);
          FETCH cur_not_certify_model INTO rec_not_certify_model;
          IF cur_not_certify_model%found THEN
            v_handset_change := 1;
            DBMS_OUTPUT.put_line ('handset change because not certified model');
          END IF;
        CLOSE cur_not_certify_model;

      ELSE -- Defective Phone
         v_handset_change := 1;
      END IF;
dbms_output.put_line('after DEFECTIVE_SIM v_handset_change:'||v_handset_change);
      dbms_output.put_line('tech check:'||rec_carrier.cdma_tech);
      IF rec_carrier.gsm_tech = 1
      THEN
         new_tech := 'GSM';
      ELSE
         IF rec_carrier.cdma_tech = 1
         THEN
            new_tech := 'CDMA';
         ELSE
            IF rec_carrier.tdma_tech = 1
            THEN
               new_tech := 'TDMA';
            ELSE
               new_tech := 'Not found';
            END IF;
         END IF;
      END IF;
dbms_output.put_line('rec_esn_details.x_data_capable:'||rec_esn_details.x_data_capable);
dbms_output.put_line('rec_carrier.data_service:'||rec_carrier.data_service);
      IF rec_esn_details.x_data_capable = 1 THEN
         IF rec_carrier.data_service = 1 THEN
            OPEN c_repl_part (new_tech, rec_esn_details.part_num_objid, 1, -- check for data
            freq_1, freq_2, refurb_flag, rec_carrier.x_parent_id, ip_action,v_2g_turn_down);
            FETCH c_repl_part
            INTO rec_repl_part;
            IF c_repl_part%found
            THEN
               v_keep_data := 1;
            ELSE
               v_keep_data := 0;
            END IF;
            CLOSE c_repl_part;
         ELSE
            v_keep_data := 0;
         END IF;
      ELSE
         v_keep_data := 0;
      END IF;
     -- DBMS_OUTPUT.put_line ('New Tech:'||new_tech);
     -- DBMS_OUTPUT.put_line ('Port Type:'||v_port_type);
     -- DBMS_OUTPUT.put_line ('Keep Data:'||v_keep_data);
     -- DBMS_OUTPUT.put_line ('Handset Change:'||v_handset_change);
     -- DBMS_OUTPUT.put_line ('Sim Change:'||v_sim_change);
      -- Evaluating First Option
      dbms_output.put_line('v_port_type:'||v_port_type);

      dbms_output.put_line('v_handset_change:'||v_handset_change);
      dbms_output.put_line('v_sim_change:'||v_sim_change);
      dbms_output.put_line('v_keep_data:'||v_keep_data);
      dbms_output.put_line('ip_action:'||ip_action);
      OPEN cur_eval_carrier(v_port_type);
        FETCH cur_eval_carrier INTO rec_eval_carrier;
        IF cur_eval_carrier%found THEN
         v_value := NVL(rec_eval_carrier.x_cust_value, 0);
         IF v_handset_change = 1 THEN
            DBMS_OUTPUT.put_line ('Freq 1:'||TO_CHAR(freq_1));
            DBMS_OUTPUT.put_line ('Freq 2:'||TO_CHAR(freq_2));
            DBMS_OUTPUT.PUT_LINE ('Parent ID:'||TO_CHAR(REC_CARRIER.X_PARENT_ID));
            DBMS_OUTPUT.PUT_LINE ('new_tech:'||TO_CHAR(NEW_TECH));
            DBMS_OUTPUT.PUT_LINE ('rec_esn_details.part_num_objid:'||TO_CHAR(REC_ESN_DETAILS.PART_NUM_OBJID));
            DBMS_OUTPUT.PUT_LINE ('refurb_flag:'||TO_CHAR(REFURB_FLAG));
            DBMS_OUTPUT.PUT_LINE ('v_keep_data:'||TO_CHAR(v_keep_data));
            DBMS_OUTPUT.PUT_LINE ('ip_action:'||ip_action);

            OPEN c_repl_part (new_tech, rec_esn_details.part_num_objid,
            v_keep_data, freq_1, freq_2, refurb_flag, rec_carrier.x_parent_id,
            ip_action,v_2g_turn_down);
              FETCH c_repl_part INTO rec_repl_part;
              IF c_repl_part%found THEN --first try
               IF (rec_esn_details.x_technology = 'GSM'
               AND rec_carrier.gsm_tech = 1)
               OR (rec_esn_details.x_technology = 'CDMA'
               AND rec_carrier.cdma_tech = 1)
               OR (rec_esn_details.x_technology = 'TDMA'
               AND rec_carrier.tdma_tech = 1)
               THEN
                  v_value := v_value + 1;
                  DBMS_OUTPUT.put_line ('Same Thech Bonus added Option1:'|| TO_CHAR(v_value));
               END IF;
            ELSE
               v_value := 0; --Not a valid carrier
               DBMS_OUTPUT.put_line ('Carrier has no replacements, value:'|| TO_CHAR(v_value));
            END IF;
            CLOSE c_repl_part;
         END IF;
         IF v_value > 0
         THEN
            v_coverage := TRUE;
         END IF;
         DBMS_OUTPUT.put_line ('Value Option1:'||TO_CHAR(v_value));
         DBMS_OUTPUT.put_line ('MAX Value Option1:'||TO_CHAR(v_max_value));
         dbms_output.put_line('v_handset_change:'||v_handset_change);
         IF v_value > v_max_value
         THEN
         dbms_output.put_line('v_value > v_max_value');
            IF v_handset_change = 1
            THEN
               dbms_output.put_line('rec_repl_part.phone_gen:'||rec_repl_part.phone_gen);
               repl_part := rec_repl_part.pref_part_num;
               op1_repl_part := repl_part;
               op1_repl_units := rec_repl_part.x_bonus_units;
               op1_repl_days := rec_repl_part.x_bonus_days;
            ELSE
               repl_part := NULL;
               op1_repl_part := NULL;
               op1_repl_units := NULL;
               op1_repl_days := NULL;
            END IF;
            v_max_value := v_value;
            op1_port := v_port_type;
            op1_carr_id := rec_carrier.carrier_id;
            op1_parent_id := rec_carrier.x_parent_id;
            op1_case_conf := rec_eval_carrier.x_case_conf_objid;
            op1_issue := rec_eval_carrier.x_case_issue;
            op1_keep_data := v_keep_data;
            HANDSET_CHANGE1 := V_HANDSET_CHANGE;
            DBMS_OUTPUT.PUT_LINE ('V_HANDSET_CHANGE ||TO_CHAR(V_HANDSET_CHANGE):'||V_HANDSET_CHANGE ||TO_CHAR(V_HANDSET_CHANGE ));
            DBMS_OUTPUT.PUT_LINE ('REC_CARRIER.GSM_TECH||TO_CHAR(REC_CARRIER.GSM_TECH ):'||REC_CARRIER.GSM_TECH||TO_CHAR(REC_CARRIER.GSM_TECH ));
            DBMS_OUTPUT.PUT_LINE ('REC_CARRIER.CDMA_TECH||TO_CHAR(REC_CARRIER.CDMA_TECH):'||REC_CARRIER.CDMA_TECH||TO_CHAR(REC_CARRIER.CDMA_TECH));
            DBMS_OUTPUT.PUT_LINE ('rec_carrier.sim_profile:'||rec_carrier.sim_profile);


               IF     new_tech = 'GSM'
                  or (    REC_CARRIER.CDMA_TECH = 1
                      and IS_ESN_LTE = 0) THEN
                 op1_repl_sim_prof := rec_carrier.sim_profile;
               elsif REC_CARRIER.CDMA_TECH = 1 then
                 OP1_REPL_SIM_PROF := 'NA-CDMA';
               else
                 op1_repl_sim_prof := null;
               END IF;


         END IF;
      ELSE
         DBMS_OUTPUT.put_line ('No Value Found Option1');
      END IF;
       DBMS_OUTPUT.PUT_LINE ('op1_repl_sim_prof:'||op1_repl_sim_prof);
      CLOSE cur_eval_carrier;
      -- End Evaluation First Option
      -- Evaluating Second Option
      IF v_port_type <> 'NEW_LINE' THEN
         OPEN cur_eval_carrier('NEW_LINE');
         FETCH cur_eval_carrier
         INTO rec_eval_carrier;
         IF cur_eval_carrier%found
         THEN
            v_value2 := NVL(rec_eval_carrier.x_cust_value, 0);
            DBMS_OUTPUT.put_line ('Max 2 Value:'||TO_CHAR(v_max_value2));
            IF v_handset_change = 1 THEN
               OPEN c_repl_part (new_tech, rec_esn_details.part_num_objid,
               v_keep_data, freq_1, freq_2, refurb_flag, rec_carrier.x_parent_id
               , ip_action,v_2g_turn_down);
               FETCH c_repl_part INTO rec_repl_part;
               IF c_repl_part%notfound THEN
--first try
                  v_value2 := 0; --Not a valid carrier
                  DBMS_OUTPUT.put_line (
                  'Option 2 Carrier has no replacements, value:'||TO_CHAR(
                  v_value));
               END IF;
               CLOSE c_repl_part;
            END IF;
            IF v_value2 > v_max_value2
            THEN
               v_max_value2 := v_value2;
               IF v_handset_change = 1
               THEN
                  dbms_output.put_line('rec_repl_part.phone_gen:'||rec_repl_part.phone_gen);
                  repl_part := rec_repl_part.pref_part_num;
                  op2_repl_part := repl_part;
                  op2_repl_units := rec_repl_part.x_bonus_units;
                  op2_repl_days := rec_repl_part.x_bonus_days;
               ELSE
                  repl_part := NULL;
                  op2_repl_part := NULL;
                  op2_repl_units := NULL;
                  op2_repl_days := NULL;
               END IF;
               DBMS_OUTPUT.put_line ('Value Option2:'||TO_CHAR(v_value2));
               sim_change2 := v_sim_change;
               op2_port := 'NEW_LINE';
               op2_carr_id := rec_carrier.carrier_id;
               op2_parent_id := rec_carrier.x_parent_id;
               op2_case_conf := rec_eval_carrier.x_case_conf_objid;
               op2_issue := rec_eval_carrier.x_case_issue;
               op2_keep_data := v_keep_data;
               handset_change2 := v_handset_change;
               IF v_handset_change = 0
               THEN
                  new_tech2 := rec_esn_details.x_technology;
                  IF new_tech2 = 'GSM'
                  THEN
                     op2_repl_sim_prof := rec_carrier.sim_profile;
                  END IF;
               ELSE
                  IF rec_carrier.gsm_tech = 1
                  THEN
                     new_tech2 := 'GSM';
                     op2_repl_sim_prof := rec_carrier.sim_profile;
                  ELSE
                     IF rec_carrier.cdma_tech = 1
                     THEN
                        new_tech2 := 'CDMA';
                        op2_repl_sim_prof := 'NA-CDMA';
                     ELSE
                        IF rec_carrier.tdma_tech = 1
                        THEN
                           new_tech2 := 'TDMA';
                           op2_repl_sim_prof := 'NA-TDMA';
                        ELSE
                           new_tech2 := 'Not found';
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         ELSE
            DBMS_OUTPUT.put_line ('No Value Found Option2');
         END IF;
         CLOSE cur_eval_carrier;
      END IF;

   -- End Evaluating Second Option
   END LOOP;
     --cr22799
        IF IS_ESN_LTE = 0 THEN
            X_DLL := sa.LTE_SERVICE_PKG.DLL_LTE_4G(IP_ESN);
            OP_CURR_SIM_PROF := sa.LTE_SERVICE_PKG.PN_SIM_LTE_4G(X_DLL,OP1_CARR_ID );
            op1_repl_sim_prof := OP_CURR_SIM_PROF ;
        END IF;
    --cr27799
   --Invalidate Second Option if first option selected in NEW_LINE or SAME_CARRIER
   IF op1_port = 'NEW_LINE'
   OR op1_port = 'SAME_CARRIER'
   THEN
      op2_port := NULL;
      op2_carr_id := NULL;
      op2_parent_id := NULL;
      op2_case_conf := NULL;
      op2_issue := NULL;
      handset_change2 := 0;
      op2_repl_part := NULL;
      op2_repl_sim_prof := NULL;
      op2_bribe_units := NULL;
   END IF;
   --Clean up if no carriers found
   IF v_coverage = FALSE
   THEN
      op_error_num := '30';
      op_error_msg := 'No coverage';
      op1_port := NULL;
      op1_carr_id := NULL;
      op1_parent_id := NULL;
      op1_case_conf := NULL;
      op1_issue := NULL;
      handset_change1 := 0;
      op1_repl_part := NULL;
      op1_repl_sim_prof := NULL;
      op2_port := NULL;
      op2_carr_id := NULL;
      op2_parent_id := NULL;
      op2_case_conf := NULL;
      op2_issue := NULL;
      op2_repl_part := NULL;
      handset_change2 := 0;
      op2_repl_sim_prof := NULL;
      op2_bribe_units := NULL;
      RETURN;
   END IF;
end;
/