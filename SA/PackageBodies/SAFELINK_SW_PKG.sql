CREATE OR REPLACE PACKAGE BODY sa.safelink_sw_pkg AS
 PROCEDURE sp_retrieve_service_plan_id_sl (
 ip_program_name    IN  x_program_parameters.x_program_name%TYPE,
 ip_program_objid   IN  x_program_parameters.objid%TYPE,
 ip_esn             IN  x_program_enrolled.x_esn%TYPE,
 ip_biz_line        IN  table_bus_org.org_id%TYPE,
 op_program_name    OUT x_program_parameters.x_program_name%TYPE,
 op_program_objid   OUT x_program_parameters.objid%TYPE,
 op_service_plan_id OUT x_service_plan.objid%TYPE,
 op_error_code     OUT NUMBER,
 op_error_message  OUT VARCHAR2
)
AS
l_to_pgm_objid        NUMBER;
l_from_program_objid  NUMBER;

BEGIN

IF (ip_esn IS NULL AND ip_program_name IS NULL AND ip_program_objid IS NULL)
THEN
  op_error_code     := -1;
  op_error_message  := 'Mandatory input parameters not passed';
END IF;

IF (ip_biz_line IS NULL)
THEN
  op_error_code     := -1;
  op_error_message  := 'Mandatory input parameters not passed';
END IF;

IF (ip_esn IS NOT NULL)
THEN
BEGIN
  SELECT DISTINCT  pgm.objid
       INTO l_from_program_objid
  FROM x_program_enrolled pe,
       x_program_parameters pgm,
       x_sl_currentvals slcur,
       table_bus_org borg,
       table_x_promotion tp
  WHERE 1                   = 1
  AND pgm.objid             = pe.pgm_enroll2pgm_parameter
  AND slcur.x_current_esn   = pe.x_esn
  AND sysdate BETWEEN pgm.x_start_date AND pgm.x_end_date
  AND pgm.x_prog_class        = 'LIFELINE'
  AND pe.x_esn                = ip_esn
  AND pe.x_enrollment_status  = 'ENROLLED'
  AND borg.objid              = pgm.PROG_PARAM2BUS_ORG
  AND org_id                  = 'TRACFONE'
  AND pgm.x_promo_incl_min_at = tp.objid;

EXCEPTION
WHEN OTHERS THEN
   op_error_code     := -1;
   op_error_message  := 'Program name not found for given ESN';
RETURN;
END;
END IF;

IF (ip_program_name IS NOT NULL OR ip_program_objid IS  NOT NULL OR l_from_program_objid IS NOT NULL)
THEN
  BEGIN
    SELECT to_pgm_objid
    INTO l_to_pgm_objid
    FROM
    (SELECT to_pgm_objid
    FROM x_sl_upgrade_program_config
    WHERE from_pgm_objid = ip_program_objid
    UNION
    SELECT to_pgm_objid
    FROM x_sl_upgrade_program_config
    WHERE from_pgm_name = ip_program_name
    UNION
    SELECT to_pgm_objid
    FROM x_sl_upgrade_program_config
    WHERE from_pgm_objid = l_from_program_objid);
 EXCEPTION
  WHEN OTHERS THEN
      op_error_code     := -1;
      op_error_message  := 'To pgm name not found ';
      RETURN;
  END ;

  BEGIN
  SELECT
        mv.service_plan_objid,
        pp.objid,
        pp.x_program_name
   INTO op_service_plan_id,
        op_program_objid,
        op_program_name
   FROM table_x_promotion pm,
        x_program_parameters pp,
        service_plan_feat_pivot_mv mv,
        mtm_sp_x_program_param mtm
  WHERE pm.objid  = pp.x_promo_incl_min_at
    AND pp.objid    = l_to_pgm_objid
    AND mv.biz_line = ip_biz_line
    AND mtm.x_sp2program_param = pp.objid
    AND service_plan_objid = program_para2x_sp
    AND mv.safelink_only = 'Y'
    AND mv.voice = to_char(x_units);
  -- CR49050 Removed minutes check and replaced with prog_enroll_program_objid for mtm table.


  op_error_code:=0;
  op_error_message:='Success';
  EXCEPTION
    WHEN OTHERS THEN
       op_error_code     := -1;
       op_error_message  := 'To pgm features not found ';
       RETURN;
  END;
END IF;

EXCEPTION
WHEN OTHERS THEN
  op_error_code     := sqlcode;
  op_error_message  := sqlerrm;
END sp_retrieve_service_plan_id_sl;
--CR41784 changes
PROCEDURE sp_retrieve_service_plan_id_sl ( --overloaded procedure to return service plan id based on ESN
 ip_esn              IN  x_program_enrolled.x_esn%TYPE,
 op_service_plan_id  OUT x_service_plan.objid%TYPE,
 op_rp_change_flag   OUT VARCHAR2, -- values 'Y','N'
 op_error_code       OUT NUMBER,
 op_error_message    OUT VARCHAR2
)
AS
 CURSOR get_enroll_details
  IS
  SELECT pe.ROWID          AS current_record_rowid ,
      pe.objid               AS current_pe_objid ,
      pe.x_esn               AS x_esn ,
      pe.pgm_enroll2web_user AS web_user_objid ,
      pp.x_program_name      AS prog_enroll_program_name ,
      pp.objid               AS prog_enroll_program_objid ,
      tsp.objid              AS site_part_objid,
      pp.prog_param2bus_org  AS bus_org_objid,
      --val.lid,
      pi.part_inst2inv_bin   AS inv_bin_objid,  --added for CR43607
      (SELECT x_units FROM table_x_promotion prom where prom.objid = pp.x_promo_incl_min_at) AS enrolled_units,
      (SELECT x_service_plan_id from x_service_plan_site_part spst where spst.table_site_part_id=tsp.objid) AS service_plan_id
    FROM --x_sl_currentvals val , Removed this check for CR55543
      x_program_enrolled pe ,
      x_program_parameters pp ,
      table_site_part tsp,
      table_part_inst pi
    WHERE 1                    = 1
	   --AND val.x_current_esn      = ip_esn
    --AND val.x_current_esn      = pe.x_esn
    AND pe.x_esn               = ip_esn
    AND pp.objid               = pe.pgm_enroll2pgm_parameter
    AND pp.x_prog_class        = 'LIFELINE'
    AND pe.x_enrollment_status = 'ENROLLED'
    AND tsp.x_service_id       = pe.x_esn
    AND tsp.part_status        = 'Active'
    AND tsp.x_service_id       = pi.part_serial_no;

    --CR43011
   CURSOR get_enroll_details_mvne
  IS
  SELECT pe.ROWID          AS current_record_rowid ,
      pe.objid               AS current_pe_objid ,
      pe.x_esn               AS x_esn ,
      pe.pgm_enroll2web_user AS web_user_objid ,
      pp.x_program_name      AS prog_enroll_program_name ,
      pp.objid               AS prog_enroll_program_objid ,
      tsp.objid              AS site_part_objid,
      pp.prog_param2bus_org  AS bus_org_objid,
      (SELECT x_units FROM table_x_promotion prom where prom.objid = pp.x_promo_incl_min_at) AS enrolled_units,
      (SELECT x_service_plan_id from x_service_plan_site_part spst where spst.table_site_part_id=tsp.objid) AS service_plan_id
    FROM   x_program_enrolled pe ,
      x_program_parameters pp ,
      table_site_part tsp
    WHERE 1                    =1
    AND pe.x_esn   =         ip_esn
    AND pp.objid               = pe.pgm_enroll2pgm_parameter
    AND pp.x_prog_class        = 'LIFELINE'
    AND pe.x_enrollment_status = 'ENROLLED'
    AND tsp.x_service_id       = pe.x_esn
    AND pp.x_program_name  IN ( 'Lifeline - BG - 4','Lifeline - BG - 3' )
    AND tsp.part_status        = 'Active' ;

     --CR43011

rec_get_enroll_details get_enroll_details%ROWTYPE;
rec_get_enroll_details_mvne get_enroll_details_mvne%ROWTYPE;

l_program_objid  NUMBER;
l_sp_objid NUMBER;
l_parent_name table_x_parent.x_parent_name%TYPE;
l_budget_dealer NUMBER ;

BEGIN

IF (ip_esn IS NULL )
THEN
  op_error_code     := -1;
  op_error_message  := 'Mandatory input parameters not passed';
  RETURN;
END IF;

  OPEN get_enroll_details;
  FETCH get_enroll_details INTO rec_get_enroll_details;

  IF get_enroll_details%NOTFOUND
  THEN
  --CR43011 changes
    OPEN get_enroll_details_mvne;
    FETCH get_enroll_details_mvne INTO rec_get_enroll_details_mvne;

    IF get_enroll_details_mvne%NOTFOUND
    THEN
      op_error_code :=-100;
      op_error_message	  :='Enroll record not found';
       CLOSE get_enroll_details;
       CLOSE get_enroll_details_mvne;
      RETURN;
    END IF;
    CLOSE get_enroll_details_mvne;
     --CR43011 changes
  END IF;

  CLOSE get_enroll_details;
  --CLOSE get_enroll_details_mvne;

    --CR43011 changes
    IF rec_get_enroll_details_mvne.x_esn is not null THEN
     IF rec_get_enroll_details_mvne.service_plan_id IS NOT NULL THEN

  -- CR43607 changes   update service plan if not matches

      op_service_plan_id := rec_get_enroll_details_mvne.service_plan_id;
      op_rp_change_flag  :='N' ;
      op_error_code:=0;
      op_error_message:='Success';
      RETURN;
     ELSE
        op_error_code    :=-200;
        op_error_message :='Service plan not found';
        RETURN;

     END IF;
    END IF;


    --CR43011 changes

   BEGIN
     SELECT service_plan_objid
     INTO l_sp_objid
     FROM sa.service_plan_feat_pivot_mv
     WHERE  biz_line='TF'
     AND safelink_only ='Y'
     --AND voice= to_char(rec_get_enroll_details.enrolled_units); --CR46184 Convert number to Char
     -- CR49050 Removed minutes check and replaced with prog_enroll_program_objid for mtm table.
     AND service_plan_objid IN (SELECT program_para2x_sp
                                  FROM mtm_sp_x_program_param mtm
                                 WHERE mtm.x_sp2program_param = rec_get_enroll_details.prog_enroll_program_objid);

  EXCEPTION
      WHEN OTHERS THEN
      l_sp_objid := NULL;
  END;

  IF l_sp_objid IS NOT NULL AND rec_get_enroll_details.service_plan_id IS NOT NULL THEN
      UPDATE x_service_plan_site_part
      SET x_service_plan_id=l_sp_objid,
          x_last_modified_date =sysdate
      WHERE table_site_part_id=rec_get_enroll_details.site_part_objid
      AND x_service_plan_id=252; --update only if they are in 252

      --CR43607 update added for budget enrolment CR
      BEGIN
          SELECT COUNT(1)
	  INTO l_budget_dealer
	  FROM table_inv_bin
	  WHERE bin_name IN (select x_param_value from table_x_parameters where x_param_name ='BUDGET_DEALER')
	  AND  objid = rec_get_enroll_details.inv_bin_objid;
      EXCEPTION WHEN
         OTHERS THEN
           l_budget_dealer := 0;
      END;

      IF l_budget_dealer >0 THEN
        UPDATE x_service_plan_site_part
        SET x_service_plan_id=l_sp_objid,
            x_last_modified_date =sysdate
        WHERE table_site_part_id=rec_get_enroll_details.site_part_objid
        AND x_service_plan_id<>l_sp_objid;
      END IF;
        --CR43607 update added for budget enrolment

      op_service_plan_id := l_sp_objid;
  ELSE
    op_error_code :=-200;
    op_error_message	:='Service plan not found';
    RETURN;
  END IF;


  l_parent_name := util_pkg.get_parent_name(ip_esn);

  IF l_parent_name IS NOT NULL THEN
   IF (l_parent_name NOT LIKE '%SAFELINK%') THEN --checking if existing carrier is not safelink and return rate plan change as 'Y'
     op_rp_change_flag :='Y';
   ELSE
     op_rp_change_flag :='N' ;
   END IF;
  ELSE
    op_error_code       :=-300;
    op_error_message	:='Parent carrier not found';
    RETURN;
  END IF;


 -- CLOSE get_enroll_details_mvne;

  op_error_code:=0;
  op_error_message:='Success';

EXCEPTION
WHEN OTHERS THEN
  op_error_code     := sqlcode;
  op_error_message  := sqlerrm;
END sp_retrieve_service_plan_id_sl;
--CR41784 changes
PROCEDURE get_carrier_id_sl_dis
(
ip_carrier_objid  IN table_x_carrier.objid%TYPE,
ip_esn            IN VARCHAR2,
op_carrier_objid  OUT NUMBER,
op_error_code     OUT NUMBER,
op_error_msg      OUT VARCHAR2
)
AS
v_parent_name   table_x_parent.x_parent_name%TYPE ;
cst customer_type     := customer_type(ip_esn);
cst_ret customer_type := customer_type;
p_sim   VARCHAR2(100);
p_zip   VARCHAR2(100);
p_phone_frequency NUMBER;


 CURSOR c_dealer
      IS
      SELECT s.site_id,
         pn.x_technology tech ,
         pn.x_dll,
         NVL (pi.part_good_qty, 0) part_good_flag,
         pi.part_bin,  -- CR5028
         NVL(pn.x_meid_phone, 0) x_meid_phone,  --cdma meid check 5/16/07
         bo.org_id
      FROM table_part_num pn, table_mod_level ml, table_site s, table_inv_role
      ir, table_inv_bin ib, table_part_inst pi, table_bus_org bo
      WHERE pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND s.objid = ir.inv_role2site
      AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
      AND ib.objid = pi.part_inst2inv_bin
      AND pi.x_domain = 'PHONES'
      AND pi.part_serial_no = ip_esn
      AND pn.PART_NUM2BUS_ORG = bo.objid;

 CURSOR sim_part_num_curs is
   SELECT pn2.part_number
   FROM table_x_sim_inv sim,
        table_mod_level ml,
       table_part_num pn2
   WHERE 1 = 1
   AND ml.part_info2part_num = pn2.objid
   AND sim.x_sim_inv2part_mod = ml.objid
   AND sim.x_sim_serial_no = p_sim;      -- BRAND_SEP



CURSOR c_prf_carrier( c_dealer          IN VARCHAR2,
                      c_meid_phone      IN NUMBER,
                      c_sim_part_num    IN VARCHAR2,
                      c_dll             IN NUMBER,
                      c_tech IN VARCHAR2) IS
      SELECT ca.objid,
             ca.x_carrier_id,
             ca.x_react_analog,
             ca.x_react_technology ca_react_technology,
             ca.x_act_analog,
             ca.x_act_technology ca_act_technology,
             pt.x_technology pref_technology,
             f.x_frequency,
             pt.x_activation,  --CR5028
             pt.x_reac_exception_code,  --CR5028
             pt.x_reactivation--CR5028
        FROM table_x_frequency f,
             mtm_x_frequency2_x_pref_tech1 f2pt,
             table_x_pref_tech pt,
             table_x_carrier ca,
             table_x_carrierdealer c,
             table_x_carrier_group cg,
             table_x_parent p,
             (SELECT min(to_number(cp.new_rank)) new_rank, b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch
                FROM carrierpref cp,
                       npanxx2carrierzones b,
                     (SELECT DISTINCT
                             a.ZONE,
                             a.st,
                             s.sim_profile,
                             a.county,
                             s.min_dll_exch,
                             s.max_dll_exch,
                                     s.rank
                        FROM carrierzones a,
                             carriersimpref s
                       WHERE a.zip = p_zip
                         and a.CARRIER_NAME=s.CARRIER_NAME
                         and c_dll between s.MIN_DLL_EXCH and s.MAX_DLL_EXCH) a
               WHERE 1=1
                 AND cp.st = b.state
                 and cp.carrier_id = b.carrier_ID
                   and cp.county = a.county
                 AND (   b.gsm_tech =c_tech OR b.cdma_tech     = c_tech)
                   and a.sim_profile = decode(c_sim_part_num,null,'NA',c_sim_part_num)
                 AND b.ZONE = a.ZONE
                 AND b.state = a.st
               group by b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch) tab1,
             (select pn.part_num2bus_org,
                     pn.x_technology,
                     pn.PART_NUM2PART_CLASS,
                     NVL(pn.x_meid_phone, 0) meid_phone,
                     pi.x_part_inst_status,
                     nvl((select v.x_param_value
                            from table_x_part_class_values v,
                                 table_x_part_class_params n
                           where 1=1
                             and v.value2part_class     = pn.part_num2part_class
                             and v.value2class_param    = n.objid
                             and n.x_param_name         = 'PHONE_GEN'
                             and rownum <2),'2G') PHONE_GEN,
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
               from table_bus_org bo ,
                     table_part_num pn,
                     sa.table_mod_level ml,
                     table_part_inst pi
               where 1=1
                 and bo.objid          = pn.part_num2bus_org
                 and pn.objid          = ml.part_info2part_num
                 and ml.objid          = pi.n_part_inst2part_mod
                 AND pi.part_serial_no = ip_esn) tab2
       WHERE 1=1
         AND NOT EXISTS (SELECT 1
                           FROM table_x_not_certify_models cm
                          WHERE 1 = 1
                            AND cm.X_PART_CLASS_OBJID = tab2.PART_NUM2PART_CLASS
                            AND cm.X_PARENT_ID = p.x_parent_id)
         and f.objid = f2pt.x_frequency2x_pref_tech
         AND f.x_frequency + 0 <= NVL (p_phone_frequency, 800)
         AND f2pt.x_pref_tech2x_frequency = pt.objid
         AND pt.x_pref_tech2x_carrier = ca.objid
         AND ca.x_status || '' = 'ACTIVE' --CR5757
         AND ca.x_carrier_id = tab1.carrier_id
         AND c.x_carrier_id = tab1.carrier_id
         AND c.x_dealer_id <> '24920'  --to get non safelink dealer
     --CR38885
        /* AND c.x_dealer_id <> '24920'/*||'' = case when global_safelink = 'FOUND' then
                                         c.x_dealer_id,'
                                       else
                                         decode(c.x_dealer_id,'24920','XXXXXX','DEFAULT','XXXXXX',c.x_dealer_id)
                                       end*/
     --CR38885
         AND cg.objid = ca.CARRIER2CARRIER_GROUP
         and p.objid = cg.X_CARRIER_GROUP2X_PARENT
         and decode( p.x_meid_carrier,1,tab2.meid_phone,null,0,p.x_meid_carrier) = tab2.meid_phone
--CR23419
         and exists(select 1
                      from table_x_carrier_features cf
                     where 1=1
         and cf.X_FEATURES2BUS_ORG = tab2.part_num2bus_org
         and cf.x_technology = tab2.x_technology
         and cf.x_data=tab2.data_speed
         and decode(cf.X_SWITCH_BASE_RATE,null,tab2.non_ppe,1) = tab2.non_ppe
         and (  cf.x_feature2x_carrier = ca.objid
              or (      tab2.org_id = 'NET10'
                   and  exists(SELECT 1
                               FROM table_x_carrier_group cg2,
                                    table_x_carrier c2
                              WHERE cg2.x_carrier_group2x_parent = p.objid
                                AND c2.carrier2carrier_group = cg2.objid
                                and c2.objid = cf.x_feature2x_carrier))))
         and 1=(case when tab2.phone_gen = '2G' then
                       (select count(*)
                         from table_x_carrier_rules cr
                        where (   (    cr.objid = decode(tab2.x_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                                       'GSM' , nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)
                                   and cr.x_allow_2g_react = '2G'
                                   and tab2.x_part_inst_status not in ('50','150'))
                               or (    cr.objid = decode(tab2.x_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                                        'GSM' , nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)
                                   and cr.x_allow_2g_act = '2G'
                                   and tab2.x_part_inst_status in ('50','150')))
                          and rownum < 2)
                     else
                       1
                     end)
--CR23419
      ORDER BY f.x_frequency DESC;
    c_dealer_rec     c_dealer%ROWTYPE;
    sim_part_num_rec sim_part_num_curs%ROWTYPE;

BEGIN
   cst_ret       := cst.retrieve;
   p_sim         := cst_ret.iccid;
   p_zip         := cst_ret.zipcode;
   BEGIN
      SELECT MAX (f.x_frequency)phone_frequency
      INTO p_phone_frequency
      FROM table_x_frequency f, mtm_part_num14_x_frequency0 pf, table_part_num
      pn, table_mod_level ml, table_part_inst pi
      WHERE pf.x_frequency2part_num = f.objid
      AND pn.objid = pf.part_num2x_frequency
      AND pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND pi.part_serial_no = ip_esn
      AND pi.x_domain = 'PHONES';
   EXCEPTION
    WHEN OTHERS THEN
      op_error_code :=-1;
      op_error_msg  :='Not able to get phone frequency';
      RETURN;
    END;

  IF ((p_sim IS NULL AND (cst_ret.technology='GSM' OR lte_service_pkg.is_esn_lte_cdma (ip_esn) =1 )OR p_zip IS NULL))
  --IF (p_sim IS NULL OR p_zip IS NULL)
  THEN
    op_error_code :=-1;
    op_error_msg  :='Not able to retrive sim or zip code';
    RETURN;
  END IF;

  BEGIN
    SELECT pa.x_parent_name
    INTO v_parent_name
    FROM
    table_x_carrier ca,
    table_x_carrier_group cg,
    table_x_parent pa
    WHERE ca.carrier2carrier_group = cg.objid
    AND cg.x_carrier_group2x_parent=pa.objid
    AND ca.objid = ip_carrier_objid
    AND pa.x_status ='ACTIVE';
  EXCEPTION
  WHEN OTHERS THEN
    op_error_code :=-1;
    op_error_msg  :='Parent Carrier not found';
    RETURN;
  END;

  IF (v_parent_name LIKE '%SAFELINK%')
  THEN

     FOR dealer_rec IN c_dealer
        LOOP

        --FOR sim_part_num_rec IN sim_part_num_curs
        --  LOOP
	OPEN sim_part_num_curs;
	FETCH sim_part_num_curs INTO sim_part_num_rec;
	CLOSE sim_part_num_curs;

            FOR prf_carrier_rec IN c_prf_carrier(dealer_rec.site_id,dealer_rec.x_meid_phone,sim_part_num_rec.part_number,dealer_rec.x_dll,dealer_rec.tech)
              LOOP
                  op_carrier_objid := prf_carrier_rec.objid;
                  op_error_code    := 0;
                  op_error_msg := 'Success';
                  RETURN;
            END LOOP;


         --END LOOP;

     END LOOP;
     IF (op_carrier_objid IS NULL) THEN
        op_error_code    := -1;
        op_error_msg    := 'No Carrier found';
        RETURN;
     END IF;
  ELSE
    op_error_code    := -1;
    op_error_msg    := 'Carrier is not safelink';
    RETURN;

  END IF;

END get_carrier_id_sl_dis;
PROCEDURE create_call_trans_carrier_id
(
 ip_esn                IN       VARCHAR2,
 ip_action_type        IN       VARCHAR2,
 ip_sourcesystem       IN       VARCHAR2,
 ip_brand_name         IN       VARCHAR2,
 ip_reason             IN       VARCHAR2,
 ip_result             IN       VARCHAR2,
 ip_ota_req_type       IN       VARCHAR2,
 ip_ota_type           IN       VARCHAR2,
 ip_total_units        IN       NUMBER,
 ip_orig_login_objid   IN       NUMBER,
 ip_action_text        IN       VARCHAR2,
 ip_calltrans2carrier  IN       NUMBER,
 op_calltranobj        OUT      NUMBER,
 op_err_code           OUT      VARCHAR2,
 op_err_msg            OUT      VARCHAR2
) AS
  -- call trans type
  ct  sa.call_trans_type := call_trans_type ();
  c   sa.call_trans_type;
BEGIN
 -- instantiate call trans values
  ct := call_trans_type ( i_esn                 => ip_esn ,
                          i_action_type         => ip_action_type ,
                          i_sourcesystem        => ip_sourcesystem ,
                          i_sub_sourcesystem    => ip_brand_name ,
                          i_reason              => ip_reason ,
                          i_result              => ip_result,
                          i_ota_req_type        => ip_ota_req_type ,
                          i_ota_type            => ip_ota_type ,
                          i_total_units         => ip_total_units ,
                          i_total_days          => NULL ,
                          i_total_sms_units     => NULL ,
                          i_total_data_units    => NULL ,
                          i_user_objid          => NULL ,
                          i_action_text         => ip_action_text,
                          i_new_due_date        => NULL,
                          i_call_trans_objid    => NULL,
                          i_calltrans2carrier   => ip_calltrans2carrier
                        );
  -- call the insert method
  c := ct.ins;
  commit;
    -- if call_trans was not created successfully
  IF c.response <> 'SUCCESS' THEN
    op_err_msg  := c.response;
    op_err_code := -1;
    -- exit the program and transfer control to the calling process
    RETURN;
  ELSE
    op_calltranobj  := c.call_trans_objid;
    op_err_msg      := 'Success';
    op_err_code     := 0;
  END IF;

  DBMS_OUTPUT.put_line ('RESPONSE :|'||c.response);

EXCEPTION
    WHEN OTHERS THEN
      op_err_code := sqlcode;
      op_err_msg  := substr(sqlerrm,1,100);
END create_call_trans_carrier_id;
PROCEDURE sp_is_safelink
(
ip_esn           IN  VARCHAR2,
out_flag         OUT VARCHAR2,
out_units        OUT NUMBER,
op_error_code    OUT INTEGER,
op_error_message OUT VARCHAR2
)
AS

  v_esn         x_program_enrolled.x_esn%type;
  v_units table_x_promotion.x_units%type;
  v_flag        VARCHAR2(25);
BEGIN

  SELECT DISTINCT x_esn,x_units,'Y'
  INTO v_esn,
  v_units,
  v_flag
  FROM x_program_enrolled pe,
  x_program_parameters pgm,
  x_sl_currentvals slcur,
  table_bus_org borg,
  table_x_promotion tp
  WHERE 1                 = 1
  AND pgm.objid           = pe.pgm_enroll2pgm_parameter
  AND slcur.x_current_esn = pe.x_esn
  AND sysdate BETWEEN pgm.x_start_date AND pgm.x_end_date
  AND pgm.x_prog_class        = 'LIFELINE'
  AND pe.x_esn                = ip_esn
  AND pe.x_enrollment_status  = 'ENROLLED'
  AND borg.objid              = pgm.PROG_PARAM2BUS_ORG
  AND org_id                  = 'TRACFONE'
  AND pgm.x_promo_incl_min_at = tp.objid;


  out_flag          :=v_flag;
  out_units         :=v_units;
  op_error_code     :=0;
  op_error_message  :='Success';

EXCEPTION
WHEN NO_DATA_FOUND THEN
 op_error_code     :=0;
 op_error_message  :='No Data found';
WHEN OTHERS THEN
 op_error_code     :=sqlcode;
 op_error_message  :=substr(sqlerrm,1,200);
END sp_is_safelink;
--CR41784 changes
PROCEDURE get_carrier_id_sl_rp_change
(
ip_carrier_objid IN table_x_carrier.objid%TYPE,
ip_esn           IN VARCHAR2,
ip_reason   IN VARCHAR2, --values i?`DEENROLLi??,i??REENROLLi??
op_carrier_objid OUT NUMBER,
op_error_code    OUT  NUMBER,
op_error_msg     OUT  VARCHAR2
)
AS
l_parent_name   table_x_parent.x_parent_name%TYPE ;
cst customer_type     := customer_type(ip_esn);
cst_ret customer_type := customer_type;
l_sim   VARCHAR2(100);
l_zip   VARCHAR2(100);
l_phone_frequency NUMBER;
l_safelink VARCHAR2(1);
l_sim_part_number VARCHAR2(100);
l_carrier_objid NUMBER;



 CURSOR c_dealer
      IS
      SELECT s.site_id,
         pn.x_technology tech ,
         pn.x_dll,
         NVL (pi.part_good_qty, 0) part_good_flag,
         pi.part_bin,  -- CR5028
         NVL(pn.x_meid_phone, 0) x_meid_phone,  --cdma meid check 5/16/07
         bo.org_id
      FROM table_part_num pn, table_mod_level ml, table_site s, table_inv_role
      ir, table_inv_bin ib, table_part_inst pi, table_bus_org bo
      WHERE pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND s.objid = ir.inv_role2site
      AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
      AND ib.objid = pi.part_inst2inv_bin
      AND pi.x_domain = 'PHONES'
      AND pi.part_serial_no = ip_esn
      AND pn.part_num2bus_org = bo.objid;

CURSOR c_prf_carrier( c_dealer          IN VARCHAR2,
                      c_meid_phone      IN NUMBER,
                      c_sim_part_num    IN VARCHAR2,
                      c_dll             IN NUMBER,
                      c_tech            IN VARCHAR2,
                      c_safelink	IN VARCHAR2) IS
      SELECT ca.objid,
             ca.x_carrier_id,
             ca.x_react_analog,
             ca.x_react_technology ca_react_technology,
             ca.x_act_analog,
             ca.x_act_technology ca_act_technology,
             pt.x_technology pref_technology,
             f.x_frequency,
             pt.x_activation,  --CR5028
             pt.x_reac_exception_code,  --CR5028
             pt.x_reactivation--CR5028
        FROM table_x_frequency f,
             mtm_x_frequency2_x_pref_tech1 f2pt,
             table_x_pref_tech pt,
             table_x_carrier ca,
             table_x_carrierdealer cd,
             table_x_carrier_group cg,
             table_x_parent p,
             (SELECT min(to_number(cp.new_rank)) new_rank, b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch
                FROM carrierpref cp,
                       npanxx2carrierzones b,
                     (SELECT DISTINCT
                             a.ZONE,
                             a.st,
                             s.sim_profile,
                             a.county,
                             s.min_dll_exch,
                             s.max_dll_exch,
                                     s.rank
                        FROM carrierzones a,
                             carriersimpref s
                       WHERE a.zip = l_zip
                         and a.carrier_name=s.carrier_name
                         and c_dll between s.min_dll_exch and s.max_dll_exch) a
               WHERE 1=1
                 AND cp.st = b.state
                 and cp.carrier_id = b.carrier_ID
                   and cp.county = a.county
                 AND (   b.gsm_tech =c_tech OR b.cdma_tech     = c_tech)
                   and a.sim_profile = decode(c_sim_part_num,null,'NA',c_sim_part_num)
                 AND b.ZONE = a.ZONE
                 AND b.state = a.st
               group by b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch) tab1,
             (select pn.part_num2bus_org,
                     pn.x_technology,
                     pn.part_num2part_class,
                     NVL(pn.x_meid_phone, 0) meid_phone,
                     pi.x_part_inst_status,
                     nvl((select v.x_param_value
                            from table_x_part_class_values v,
                                 table_x_part_class_params n
                           where 1=1
                             and v.value2part_class     = pn.part_num2part_class
                             and v.value2class_param    = n.objid
                             and n.x_param_name         = 'PHONE_GEN'
                             and rownum <2),'2G') PHONE_GEN,
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
               from table_bus_org bo ,
                     table_part_num pn,
                     sa.table_mod_level ml,
                     table_part_inst pi
               where 1=1
                 and bo.objid          = pn.part_num2bus_org
                 and pn.objid          = ml.part_info2part_num
                 and ml.objid          = pi.n_part_inst2part_mod
                 AND pi.part_serial_no = ip_esn) tab2
       WHERE 1=1
         AND NOT EXISTS (SELECT 1
                           FROM table_x_not_certify_models cm
                          WHERE 1 = 1
                            AND cm.x_part_class_objid = tab2.part_num2part_class
                            AND cm.x_parent_id = p.x_parent_id)
         and f.objid = f2pt.x_frequency2x_pref_tech
         AND f.x_frequency + 0 <= NVL (l_phone_frequency, 800)
         AND f2pt.x_pref_tech2x_frequency = pt.objid
         AND pt.x_pref_tech2x_carrier = ca.objid
         AND ca.x_status || '' = 'ACTIVE' --CR5757
         AND ca.x_carrier_id = tab1.carrier_id
         AND cd.x_carrier_id = tab1.carrier_id
         --AND c.x_dealer_id <> '24920'  --to get non safelink dealer
		 AND cd.x_dealer_id = CASE WHEN c_safelink = 'Y' THEN
							  '24920'
							  ELSE
							  DECODE(cd.x_dealer_id,'24920','XXXXXXX',cd.x_dealer_id)
							  END
         AND cg.objid = ca.carrier2carrier_group
         and p.objid = cg.x_carrier_group2x_parent
         and decode( p.x_meid_carrier,1,tab2.meid_phone,null,0,p.x_meid_carrier) = tab2.meid_phone
--CR23419
         and exists(select 1
                      from table_x_carrier_features cf
                     where 1=1
         and cf.x_features2bus_org = tab2.part_num2bus_org
         and cf.x_technology = tab2.x_technology
         and cf.x_data=tab2.data_speed
         and decode(cf.x_switch_base_rate,null,tab2.non_ppe,1) = tab2.non_ppe
         and (  cf.x_feature2x_carrier = ca.objid
              or (      tab2.org_id = 'NET10'
                   and  exists(SELECT 1
                               FROM table_x_carrier_group cg2,
                                    table_x_carrier c2
                              WHERE cg2.x_carrier_group2x_parent = p.objid
                                AND c2.carrier2carrier_group = cg2.objid
                                and c2.objid = cf.x_feature2x_carrier))))
         and 1=(case when tab2.phone_gen = '2G' then
                       (select count(*)
                         from table_x_carrier_rules cr
                        where (   (    cr.objid = decode(tab2.x_technology,'CDMA', nvl(ca.carrier2rules_cdma, ca.carrier2rules),
                                                                       'GSM' , nvl(ca.carrier2rules_gsm, ca.carrier2rules), ca.carrier2rules)
                                   and cr.x_allow_2g_react = '2G'
                                   and tab2.x_part_inst_status not in ('50','150'))
                               or (    cr.objid = decode(tab2.x_technology,'CDMA', nvl(ca.carrier2rules_cdma, ca.carrier2rules),
                                                                        'GSM' , nvl(ca.carrier2rules_gsm, ca.carrier2rules), ca.carrier2rules)
                                   and cr.x_allow_2g_act = '2G'
                                   and tab2.x_part_inst_status in ('50','150')))
                          and rownum < 2)
                     else
                       1
                     end)
--CR23419
      ORDER BY f.x_frequency DESC;
    c_dealer_rec     c_dealer%ROWTYPE;

BEGIN
    IF ip_reason NOT IN ('Safelink De-Enrollment','Safelink Re-Enrollment') THEN
      op_error_code :=-5;
      op_error_msg  :='Invalid reason';
      RETURN;
    END IF;

   cst_ret           := cst.retrieve;
   l_sim             := cst_ret.iccid;
   l_zip             := cst_ret.zipcode;
   l_sim_part_number := cst_ret.sim_part_number;


   BEGIN
      SELECT MAX (f.x_frequency)phone_frequency
      INTO l_phone_frequency
      FROM table_x_frequency f, mtm_part_num14_x_frequency0 pf, table_part_num
      pn, table_mod_level ml, table_part_inst pi
      WHERE pf.x_frequency2part_num = f.objid
      AND pn.objid = pf.part_num2x_frequency
      AND pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND pi.part_serial_no = ip_esn
      AND pi.x_domain = 'PHONES';
   EXCEPTION
    WHEN OTHERS THEN
      op_error_code :=-1;
      op_error_msg  :='Not able to get phone frequency';
      RETURN;
    END;

  IF   ip_carrier_objid IS NULL THEN
    l_carrier_objid := cst_ret.carrier_objid;
  ELSE
    l_carrier_objid :=   ip_carrier_objid;
  END IF;

  l_parent_name := cst_ret.parent_name;

  IF l_parent_name IS NULL THEN
    op_error_code :=-1;
    op_error_msg  :='Parent Carrier not found';
    RETURN;
  END IF;

  /*BEGIN
    SELECT pa.x_parent_name
    INTO l_parent_name
    FROM
    table_x_carrier ca,
    table_x_carrier_group cg,
    table_x_parent pa
    WHERE ca.carrier2carrier_group = cg.objid
    AND cg.x_carrier_group2x_parent=pa.objid
    AND ca.objid = l_carrier_objid
    AND pa.x_status ='ACTIVE';
  EXCEPTION
  WHEN OTHERS THEN
    op_error_code :=-1;
    op_error_msg  :='Parent Carrier not found';
    RETURN;
  END;*/
  l_safelink:=NULL;

  IF (ip_reason= 'Safelink De-Enrollment' AND l_parent_name LIKE '%SAFELINK%')  THEN
    l_safelink := 'N';
  ELSIF (ip_reason= 'Safelink De-Enrollment' AND l_parent_name NOT LIKE '%SAFELINK%') THEN
    op_error_code :=-2;
    op_error_msg  :='Existing Carrier is not safelink for de enrollment';
    RETURN;
  ELSIF (ip_reason= 'Safelink Re-Enrollment' AND l_parent_name LIKE '%SAFELINK%') THEN
     op_carrier_objid := cst_ret.carrier_objid;
     op_error_code    := 0;
     op_error_msg     := 'Success';
  RETURN;
  ELSIF (ip_reason= 'Safelink Re-Enrollment' AND l_parent_name NOT LIKE '%SAFELINK%')	THEN
    l_safelink := 'Y';
  ELSE
    op_error_code :=-4;
    op_error_msg  :='Safelink flag not set';
	RETURN;
  END IF;
  --sa.lte_service_pkg.is_esn_lte_cdma (p_esn)
  dbms_output.put_line('safelink flag '||l_safelink);
  IF ((l_sim IS NULL AND (cst_ret.technology='GSM' OR lte_service_pkg.is_esn_lte_cdma (ip_esn) =1 )OR l_zip IS NULL))
  THEN
    op_error_code :=-1;
    op_error_msg  :='Not able to retrive sim or zip code';
    RETURN;
  END IF;


     FOR dealer_rec IN c_dealer
        LOOP
            FOR prf_carrier_rec IN c_prf_carrier(dealer_rec.site_id,dealer_rec.x_meid_phone,l_sim_part_number,dealer_rec.x_dll,dealer_rec.tech,l_safelink)
              LOOP
                  op_carrier_objid := prf_carrier_rec.objid;
                  op_error_code    := 0;
                  op_error_msg := 'Success';
                  RETURN;
            END LOOP;
     END LOOP;

     IF (op_carrier_objid IS NULL) THEN
        op_error_code    := -1;
        op_error_msg    := 'No Carrier found';
        RETURN;
     END IF;
END get_carrier_id_sl_rp_change;

PROCEDURE process_sl_reenrollment
(
ip_esn                     IN  VARCHAR2,
ip_lid                     IN  VARCHAR2,
op_err_code                OUT VARCHAR2,
op_err_msg                 OUT VARCHAR2
) AS
 CURSOR get_enroll_details
  IS
  SELECT pe.ROWID          AS current_record_rowid ,
      pe.objid               AS current_pe_objid ,
      pe.x_esn               AS x_esn ,
      pe.pgm_enroll2web_user AS web_user_objid ,
      pp.x_program_name      AS prog_enroll_program_name ,
      pp.objid               AS prog_enroll_program_objid ,
      tsp.objid              AS site_part_objid,
      pp.prog_param2bus_org  AS bus_org_objid,
      val.lid,
      get_device_type(pe.x_esn) device_type,
      (SELECT x_units FROM table_x_promotion prom where prom.objid = pp.x_promo_incl_min_at) AS enrolled_units
    FROM x_sl_currentvals val ,
      x_program_enrolled pe ,
      x_program_parameters pp ,
      table_site_part tsp,
      table_bus_org borg
    WHERE 1                    =1
    AND val.x_current_esn      = ip_esn
    AND val.lid                = ip_lid
    AND val.x_current_esn      = pe.x_esn
    AND pp.objid               = pe.pgm_enroll2pgm_parameter
    AND pp.x_prog_class        = 'LIFELINE'
    AND pe.x_enrollment_status = 'ENROLLED'
    AND tsp.x_service_id       = pe.x_esn
    AND tsp.part_status        = 'Active'
    AND borg.objid             = pp.prog_param2bus_org
    AND org_id                 = 'TRACFONE';

	rec_get_enroll_details get_enroll_details%ROWTYPE;
	l_parent_name  table_x_parent.x_parent_name%TYPE;
	l_sp_objid x_service_plan.objid%type;
	l_benefits_dlvrd_flag VARCHAR2(1):='N';
BEGIN

OPEN get_enroll_details;
  FETCH get_enroll_details INTO rec_get_enroll_details;

  IF get_enroll_details%NOTFOUND
  THEN
    op_err_code :='-100';
    op_err_msg	  :='Enroll record not found';
    CLOSE get_enroll_details;
  RETURN;
  END IF;
  CLOSE get_enroll_details;

  IF rec_get_enroll_details.device_type IN ('BYOP','SMARTPHONE') THEN
   BEGIN
      SELECT service_plan_objid
      INTO l_sp_objid
      FROM sa.service_plan_feat_pivot_mv
      WHERE  biz_line='TF'
      AND safelink_only ='Y'
  -- CR49050 Removed minutes check and replaced with prog_enroll_program_objid for mtm table.
      AND service_plan_objid IN (SELECT program_para2x_sp
                                   FROM mtm_sp_x_program_param mtm
                                  WHERE Mtm.x_sp2program_param = rec_get_enroll_details.prog_enroll_program_objid);

   EXCEPTION
       WHEN OTHERS THEN
       l_sp_objid := NULL;
   END;


   BEGIN
    SELECT
    'Y'
    INTO l_benefits_dlvrd_flag
    FROM x_sl_hist
    WHERE x_esn =ip_esn
    AND lid     =rec_get_enroll_details.lid
    AND x_event_dt >= trunc(sysdate,'MM') --check whether there is event code 617 for current month
    AND x_event_code =617
    AND rownum =1;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
 	 l_benefits_dlvrd_flag :='N';
     WHEN OTHERS THEN
          op_err_code :=sqlcode;
 	 op_err_msg  :=sqlerrm;
     RETURN;
   END;

   IF l_benefits_dlvrd_flag ='N' THEN

    update x_program_enrolled
     set x_next_delivery_date=trunc(sysdate),
         x_update_stamp=sysdate
     where objid =rec_get_enroll_details.current_pe_objid;

   ELSIF l_benefits_dlvrd_flag='Y' THEN

     IF l_sp_objid IS NOT NULL THEN
       UPDATE x_service_plan_site_part
       SET x_service_plan_id=l_sp_objid,
          x_last_modified_date =sysdate
       WHERE table_site_part_id=rec_get_enroll_details.site_part_objid;
     ELSE
        op_err_code :='-200';
        op_err_msg :='Service plan not found';
     RETURN;
    END IF ;
   ELSE
       op_err_code :=-'400';
       op_err_msg :='Error in fetching benefits delivered flag';
       RETURN;
   END IF;


   update x_program_gencode set x_status ='TFProcessed'
   where x_esn=ip_esn
   AND sw_flag='SW_RP'
   AND x_status='SW_INSERTED'
   AND x_insert_date >trunc(sysdate,'MM'); --for current month

   op_err_code :='0';
   op_err_msg:='SUCCESS';

  ELSE
   op_err_code:='0';
   op_err_msg:='Not Supported device type';
  END IF;



EXCEPTION
 WHEN OTHERS THEN
  op_err_code :=sqlcode;
  op_err_msg  :=sqlerrm;
END process_sl_reenrollment;
--CR41784 changes
END safelink_sw_pkg;
/