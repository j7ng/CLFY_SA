CREATE OR REPLACE PACKAGE BODY sa."CARRIERS_VERIFICATION" AS
  /********************************************************************************/
  /*    Copyright 2011 Tracfone  Wireless Inc. All rights reserved                */
  /*                                                                              */
  /* NAME     : carriers_verification                                                     */
  /* PURPOSE  : Package to handle all ESN service verification functionality      */
  /* FREQUENCY:                                                                   */
  /* PLATFORMS:                                                                   */
  /* REVISIONS:                                                                   */
  /*                                                                              */
  /* VERSION DATE       WHO        PURPOSE                                        */
  /* ------- ---------- ---------- -----------------------------------------------*/
  /* 1.1     03/21/2011 kacosta    Initial  Revision                              */
  /*                               Package body was developed to support CR15767  */
  /*                               FIX ST MIN CHANGE ISSUES                       */
  /*                               Originally written by Curt Lindner             */
  /********************************************************************************/
  --
  -- Private Package Variables
  --
  l_cv_package_name CONSTANT VARCHAR2(30) := 'carriers_verification';
  --
  -- Public Functions
  --
  --********************************************************************************
  -- Function retreives the active site part objid by ESN
  --********************************************************************************
  --
  FUNCTION f_actve_site_part_objid_by_esn(p_esn IN table_site_part.x_service_id%TYPE) RETURN table_site_part.objid%TYPE AS
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.f_actve_site_part_objid_by_esn';
    l_i_error_code    INTEGER := 0;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    l_v_position      VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note          VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    --
    CURSOR actv_ste_prt_objid_by_esn_curs(l_v_x_service_id table_site_part.x_service_id%TYPE) IS
      SELECT MAX(tsp.objid) objid
        FROM table_site_part tsp
       WHERE tsp.x_service_id = l_v_x_service_id
         AND tsp.part_status = 'Active';
    --
    actv_ste_prt_objid_by_esn_rec actv_ste_prt_objid_by_esn_curs%ROWTYPE;
    --
  BEGIN
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('p_esn: ' || NVL(p_esn
                                           ,'Value is null'));
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Get active site part objid by ESN';
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      --
    END IF;
    --
    IF actv_ste_prt_objid_by_esn_curs%ISOPEN THEN
      --
      CLOSE actv_ste_prt_objid_by_esn_curs;
      --
    END IF;
    --
    OPEN actv_ste_prt_objid_by_esn_curs(l_v_x_service_id => p_esn);
    FETCH actv_ste_prt_objid_by_esn_curs
      INTO actv_ste_prt_objid_by_esn_rec;
    CLOSE actv_ste_prt_objid_by_esn_curs;
    --
    l_v_position := l_cv_subprogram_name || '.4';
    l_v_note     := 'End executing ' || l_cv_subprogram_name;
    --
    IF l_b_debug THEN
      --
      dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                      ,' MM/DD/YYYY HH:MI:SS AM'));
      dbms_output.put_line('actv_ste_prt_objid_by_esn_rec.objid: ' || NVL(TO_CHAR(actv_ste_prt_objid_by_esn_rec.objid)
                                                                         ,'Value is null'));
      --
    END IF;
    --
    RETURN actv_ste_prt_objid_by_esn_rec.objid;
    --
  EXCEPTION
    WHEN others THEN
      --
      l_i_error_code    := SQLCODE;
      l_v_error_message := SQLERRM;
      --
      l_v_position := l_cv_subprogram_name || '.5';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
      --
      IF l_b_debug THEN
        --
        dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE
                                                                        ,' MM/DD/YYYY HH:MI:SS AM'));
        dbms_output.put_line('l_i_error_code   : ' || NVL(TO_CHAR(l_i_error_code)
                                                         ,'Value is null'));
        dbms_output.put_line('l_v_error_message: ' || NVL(l_v_error_message
                                                         ,'Value is null'));
        --
      END IF;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => p_esn
                          ,p_program_name => l_v_position
                          ,p_error_text   => l_v_error_message);
      --
      RAISE;
      --
  END f_actve_site_part_objid_by_esn;
  --
  -- Public Procedures
  --
  PROCEDURE min_change_allowed
  (
    p_esn             IN VARCHAR2
   ,p_zip             IN VARCHAR2
   ,p_site_part_objid IN NUMBER
   ,p_msg             OUT VARCHAR2
   ,p_sim_out         OUT VARCHAR2
  ) IS
    --
    CURSOR zone_info_curs
    (
      c_carrier_id      IN NUMBER
     ,c_old_carrier_id  IN NUMBER
     ,c_parent_id       IN NUMBER
     ,c_old_parent_id   IN NUMBER
     ,c_parent_name     IN VARCHAR2
     ,c_old_parent_name IN VARCHAR2
     ,c_new_zip         IN VARCHAR2
     ,c_old_zip         IN VARCHAR2
    ) IS
      SELECT (CASE
               WHEN c_carrier_id = c_old_carrier_id THEN
                1
               ELSE
                0
             END) same_carrier
            ,(CASE
               WHEN c_parent_name = 'CINGULAR'
                    AND c_old_parent_name = 'CINGULAR'
                    AND EXISTS (SELECT mkt
                           ,rc_number
                       FROM sa.x_cingular_mrkt_info
                      WHERE zip = c_old_zip
                     INTERSECT
                     SELECT mkt
                           ,rc_number
                       FROM sa.x_cingular_mrkt_info
                      WHERE zip = c_new_zip) THEN
                1
--CR22615
              WHEN c_parent_name like '%SPRINT%' AND c_old_parent_name like '%SPRINT%' then
                1
              WHEN c_parent_name like '%VERIZON%' AND c_old_parent_name like '%VERIZON%' then
                1
               WHEN c_parent_name like 'T-MO%' AND c_old_parent_name like 'T-MO%' then
                1
               WHEN c_parent_id = c_old_parent_id
                    AND EXISTS (SELECT b.state
                           ,b.zone
                       FROM npanxx2carrierzones b
                           ,carrierzones        a
                      WHERE 1 = 1
                        AND b.carrier_id = c_carrier_id
                        AND b.state = a.st
                        AND b.zone = a.zone
                        AND a.zip = c_new_zip
                     INTERSECT
                     SELECT b.state
                           ,b.zone
                       FROM npanxx2carrierzones b
                           ,carrierzones        a
                      WHERE 1 = 1
                        AND b.carrier_id = c_old_carrier_id
                        AND b.state = a.st
                        AND b.zone = a.zone
                        AND a.zip = c_old_zip) THEN
                1
               ELSE
                0
             END) same_zone
            ,(CASE
               WHEN c_parent_id = c_old_parent_id THEN
                1
               ELSE
                0
             END) same_parent
        FROM dual;
    --
    zone_info_rec zone_info_curs%ROWTYPE;
    --
    CURSOR site_part_curs IS
      SELECT sp.x_zipcode
            ,p.x_parent_name
            ,p.x_parent_id
            ,ca.x_carrier_id
            ,(SELECT pn2.part_number
                FROM table_x_sim_inv sim
                    ,table_mod_level ml
                    ,table_part_num  pn2
               WHERE 1 = 1
                 AND ml.part_info2part_num = pn2.objid
                 AND sim.x_sim_inv2part_mod = ml.objid
                 AND sim.x_sim_serial_no = sp.x_iccid) sim_part_number
        FROM table_site_part       sp
            ,table_part_inst       pi
            ,table_x_carrier       ca
            ,table_x_carrier_group cg
            ,table_x_parent        p
       WHERE 1 = 1
         AND sp.objid = p_site_part_objid
         AND pi.part_serial_no = sp.x_min
         AND ca.objid = pi.part_inst2carrier_mkt
         AND cg.objid = ca.carrier2carrier_group
         AND p.objid = cg.x_carrier_group2x_parent;
    --
    site_part_rec site_part_curs%ROWTYPE;
    --
    CURSOR esn_curs IS
      SELECT (SELECT s.site_id
                FROM table_inv_bin ib
                    ,table_site    s
               WHERE s.site_id = ib.bin_name
                 AND ib.objid = pi.part_inst2inv_bin) dealer_id
            ,pi.part_serial_no esn
            ,pi.x_part_inst_status
            ,pi.objid esn_objid
            ,pi.x_iccid
            ,(SELECT COUNT(*)
                FROM table_part_inst pi_min
               WHERE pi_min.part_to_esn2part_inst = pi.objid
                 AND pi_min.x_part_inst_status = '37'
                 AND ROWNUM < 2) reserved_line
            ,(SELECT COUNT(*)
                FROM table_part_inst pi_min
               WHERE pi_min.part_to_esn2part_inst = pi.objid
                 AND pi_min.x_part_inst_status = '39'
                 AND ROWNUM < 2) reserved_used_line
            ,(SELECT COUNT(*)
                FROM table_site_part sp_a
               WHERE sp_a.x_service_id = pi.part_serial_no
                 AND sp_a.x_refurb_flag = 1
                 AND ROWNUM < 2) x_refurb_flag
            ,(SELECT COUNT(*)
                FROM table_site_part sp
               WHERE sp.x_service_id = pi.part_serial_no
                 AND sp.part_status = 'Active'
                 AND ROWNUM < 2) is_active
            ,(SELECT COUNT(*)
                FROM table_site_part sp
               WHERE sp.x_service_id = pi.part_serial_no
                 AND sp.part_status = 'CarrierPending'
                 AND ROWNUM < 2) carrier_pending
            ,(SELECT sim.x_sim_inv_status
                FROM table_x_sim_inv sim
                    ,table_mod_level ml
                    ,table_part_num  pn
               WHERE 1 = 1
                 AND sim.x_sim_inv2part_mod = ml.objid
                 AND ml.part_info2part_num = pn.objid
                 AND sim.x_sim_serial_no = pi.x_iccid) sim_part_status
            ,(SELECT pn2.part_number
                FROM table_x_sim_inv sim
                    ,table_mod_level ml
                    ,table_part_num  pn2
               WHERE 1 = 1
                 AND sim.x_sim_inv2part_mod = ml.objid
                 AND ml.part_info2part_num = pn2.objid
                 AND sim.x_sim_serial_no = pi.x_iccid) sim_part_number
            ,ml.part_info2part_num part_num_objid
            ,(SELECT s_part_number
                FROM table_part_num
               WHERE objid = ml.part_info2part_num) esn_part_number
        FROM table_part_inst pi
            ,table_mod_level ml
       WHERE 1 = 1
         AND ml.objid = pi.n_part_inst2part_mod
         AND pi.part_serial_no = p_esn;
    --
    esn_rec esn_curs%ROWTYPE;
    --
    CURSOR esn_part_num_info_curs(p_part_num_objid IN NUMBER) IS
      SELECT /*+ ORDERED */
       pn.part_number esn_part_number
      ,pn.x_technology
      ,pn.x_dll
      ,NVL(pn.x_meid_phone ,0) x_meid_phone
      ,NVL(pn.x_data_capable ,0) x_data_capable
      ,nvl((select v.x_param_value
              from table_x_part_class_values v,
                   table_x_part_class_params n
             where 1=1
               and v.value2part_class     = pn.part_num2part_class
               and v.value2class_param    = n.objid
               and n.x_param_name         = 'DATA_SPEED'
               and rownum <2),NVL(pn.x_data_capable, 0)) data_speed
      ,(SELECT COUNT(*) sr
          FROM table_x_part_class_values v
              ,table_x_part_class_params n
         WHERE 1 = 1
           AND v.value2part_class = pn.part_num2part_class
           AND v.value2class_param = n.objid
           AND n.x_param_name = 'UNLIMITED_PLAN'
           AND v.x_param_value = 'NTU'
           AND ROWNUM < 2) unlimited_plan
      ,(SELECT COUNT(*) sr
          FROM table_x_part_class_values v
              ,table_x_part_class_params n
         WHERE 1 = 1
           AND v.value2part_class = pn.part_num2part_class
           AND v.value2class_param = n.objid
           AND n.x_param_name = 'NON_PPE'
           AND v.x_param_value IN ('0'
                                  ,'1')
           AND ROWNUM < 2) non_ppe
      ,(SELECT MAX(DECODE(f.x_frequency
                         ,800
                         ,800
                         ,0)) phone_frequency
          FROM sa.table_x_frequency           f
              ,sa.mtm_part_num14_x_frequency0 pf
         WHERE pf.x_frequency2part_num = f.objid
           AND pn.objid = pf.part_num2x_frequency) phone_frequency
      ,(SELECT MAX(DECODE(f.x_frequency
                         ,1900
                         ,1900
                         ,0)) phone_frequency2
          FROM sa.table_x_frequency           f
              ,sa.mtm_part_num14_x_frequency0 pf
         WHERE pf.x_frequency2part_num = f.objid
           AND pn.objid = pf.part_num2x_frequency) phone_frequency2
      ,pn.part_num2bus_org bus_org_objid
      ,(SELECT bo.org_id
          FROM table_bus_org bo
         WHERE bo.objid = pn.part_num2bus_org) org_id
      ,pn.part_num2part_class
        FROM table_part_num pn
       WHERE 1 = 1
         AND pn.objid = p_part_num_objid;
    --
    CURSOR carrier_curs
    (
      c_dealer_id        IN VARCHAR2
     ,c_zip              IN VARCHAR2
     ,c_phone_frequency  IN VARCHAR2
     ,c_phone_frequency2 IN VARCHAR2
     ,c_technology       IN VARCHAR2
     ,c_sim_part_number  IN VARCHAR2
     ,c_esn_part_number  IN VARCHAR2
     ,c_data_capable     IN VARCHAR2
     ,c_meid_phone       IN VARCHAR2
     ,c_non_ppe          IN NUMBER
     ,c_unlimited_plan   IN VARCHAR2
     ,c_bus_org_objid    IN NUMBER
     ,c_dll              IN NUMBER
    ) IS
      SELECT *
        FROM (SELECT /*+ ORDERED */
               ca.objid
              ,ca.x_carrier_id
              ,ca.x_mkt_submkt_name
              ,NVL(ca.x_data_service ,0) x_data_service
              ,p.x_parent_name
              ,p.x_parent_id
              ,NVL(p.x_meid_carrier ,0) x_meid_carrier
              ,(SELECT (CASE
                         WHEN cf.x_switch_base_rate IS NOT NULL THEN
                          1
                         ELSE
                          0
                       END) sr
                  FROM table_x_carrier_features cf
                 WHERE cf.x_feature2x_carrier = ca.objid
                   AND ROWNUM < 2) non_ppe
              ,(CASE
                 WHEN NVL(p.x_no_inventory
                         ,0) = 0
                      AND NVL(p.x_next_available
                             ,0) = 0
                      AND NOT EXISTS (SELECT 1
                         FROM sa.x_next_avail_carrier nac
                        WHERE nac.x_carrier_id = ca.x_carrier_id) THEN
                  0
                 ELSE
                  1
               END) no_inventory_carrier
              ,c.x_dealer_id
              ,(SELECT bo.org_id
                  FROM table_bus_org            bo
                      ,table_x_carrier_features cf
                 WHERE bo.objid = cf.x_features2bus_org
                   AND cf.x_feature2x_carrier = ca.objid
                   AND cf.x_technology = c_technology
                   AND cf.x_features2bus_org = c_bus_org_objid
                   AND ROWNUM < 2) org_id
              ,(SELECT MIN(f.x_frequency) || ':' || MAX(f.x_frequency)
                  FROM table_x_frequency             f
                      ,mtm_x_frequency2_x_pref_tech1 f2pt
                      ,table_x_pref_tech             pt
                 WHERE f.objid = f2pt.x_frequency2x_pref_tech
                   AND f2pt.x_pref_tech2x_frequency = pt.objid
                   AND pt.x_pref_tech2x_carrier = ca.objid) frequency
              ,tab1.new_rank
              ,tab1.sim_profile
              ,tab1.min_dll_exch
              ,tab1.max_dll_exch
              --CR32498_SIM Warranty Exchange Enhancements added below
              ,sa.is_shippable(tab1.sim_profile) as shippable
              --CR32498 Ends
              ,(SELECT COUNT(*)
                  FROM table_x_not_certify_models cm
                      ,table_part_num             pn
                 WHERE 1 = 1
                   AND cm.x_parent_id = p.x_parent_id
                   AND cm.x_part_class_objid = pn.part_num2part_class
                   AND pn.part_number = c_esn_part_number
                   AND ROWNUM < 2) not_certified
              ,RANK() over(PARTITION BY ca.objid ORDER BY DECODE(c.x_dealer_id, 'DEFAULT', 2, 1), TO_NUMBER(tab1.new_rank)) rnk
                FROM (SELECT MIN(TO_NUMBER(cp.new_rank)) new_rank
                            ,b.carrier_id
                            ,a.sim_profile
                            ,a.min_dll_exch
                            ,a.max_dll_exch
                        FROM carrierpref cp
                            ,npanxx2carrierzones b
                            ,(SELECT DISTINCT a.zone
                                             ,a.st
                                             ,s.sim_profile
                                             ,a.county
                                             ,s.min_dll_exch
                                             ,s.max_dll_exch
                                             ,s.rank
                                FROM carrierzones   a
                                    ,carriersimpref s
                               WHERE a.zip = c_zip
                                 AND a.carrier_name = s.carrier_name
                                 AND c_dll BETWEEN s.min_dll_exch AND s.max_dll_exch
                               ORDER BY s.rank ASC) a
                       WHERE 1 = 1
                         AND cp.st = b.state
                         AND cp.carrier_id = b.carrier_id
                         AND cp.county = a.county
                         AND (b.cdma_tech = c_technology OR b.gsm_tech = c_technology)
                         AND a.sim_profile = CASE
                               WHEN c_technology = 'CDMA' THEN
                                'NA'
                               WHEN c_technology = 'GSM'
                                    AND c_sim_part_number IS NOT NULL THEN
                                c_sim_part_number
                               WHEN c_technology = 'GSM'
                                    AND c_sim_part_number IS NULL THEN
                                DECODE(a.sim_profile
                                      ,'NA'
                                      ,'NULL'
                                      ,a.sim_profile)
                               ELSE
                                'NULL'
                             END
                         AND b.zone = a.zone
                         AND b.state = a.st
                       GROUP BY b.carrier_id
                               ,a.sim_profile
                               ,a.min_dll_exch
                               ,a.max_dll_exch) tab1
                    ,table_x_carrierdealer c
                    ,table_x_carrier ca
                    ,table_x_carrier_group cg
                    ,table_x_parent p
               WHERE 1 = 1
	         and exists (select cf.X_FEATURES2BUS_ORG
                               from table_x_carrier_features cf
                              where cf.X_FEATURE2X_CARRIER = ca.objid
                                and cf.x_technology        = c_technology
                                and cf.X_FEATURES2BUS_ORG  = c_bus_org_objid
                                and cf.x_data              = c_data_capable
		                and decode(cf.X_SWITCH_BASE_RATE,null,c_non_ppe,1) = c_non_ppe)
                 AND NVL(c.x_dealer_id ,'1') || '' IN (NVL(c_dealer_id ,'2') ,'DEFAULT')
                 AND c.x_dealer_id = (CASE WHEN c_dealer_id = '24920' THEN
                                             '24920'
                                           ELSE
                                             DECODE(c.x_dealer_id ,'24920' ,'00' ,c.x_dealer_id)
                                           END)
                 AND c.x_carrier_id = tab1.carrier_id
                 AND ca.x_status || '' = 'ACTIVE'
                 AND ca.x_carrier_id = tab1.carrier_id
                 AND cg.objid = ca.carrier2carrier_group
                 AND p.objid = cg.x_carrier_group2x_parent
                 AND EXISTS (SELECT 1
                               FROM table_x_frequency             f
                                   ,mtm_x_frequency2_x_pref_tech1 f2pt
                                   ,table_x_pref_tech             pt
                              WHERE f.objid = f2pt.x_frequency2x_pref_tech
                                AND f.x_frequency + 0 IN (c_phone_frequency ,c_phone_frequency2)
                                AND f2pt.x_pref_tech2x_frequency = pt.objid
                                AND pt.x_pref_tech2x_carrier = ca.objid)
                 AND p.x_parent_id = (CASE WHEN c_unlimited_plan = 1 THEN
                                             '74'
                                           ELSE
                                             DECODE(p.x_parent_id ,'74' ,'00' ,p.x_parent_id)
                                           END))
       WHERE rnk = 1
       ORDER BY DECODE(x_dealer_id
                      ,'DEFAULT'
                      ,2
                      ,1)
               ,TO_NUMBER(new_rank);
    --
    CURSOR sim_exists2_curs(c_sim_part_number IN VARCHAR2) IS
      SELECT pn2.part_number
        FROM table_part_num pn2
       WHERE 1 = 1
         AND pn2.part_number = c_sim_part_number;
    --
    sim_exists2_rec sim_exists2_curs%ROWTYPE;
    --
    TYPE big_rec IS RECORD(
       carrier_info      carrier_curs%ROWTYPE
      ,phone_part_number VARCHAR2(30)
      ,same_carrier      NUMBER
      ,same_zone         NUMBER
      ,same_parent       NUMBER);
    --
    TYPE big_type IS TABLE OF big_rec;
    --
    big_tab                 big_type := big_type();
    cnt                     NUMBER;
    l_esn_part_number_objid NUMBER;
    l_sim_part_number       VARCHAR2(30);
    v_repl_sim_found        VARCHAR2(1) := 'N' ; --CR32498
    --
  BEGIN
    --
    IF p_site_part_objid IS NOT NULL THEN
      --
      OPEN site_part_curs;
      FETCH site_part_curs
        INTO site_part_rec;
      --
      IF site_part_curs%NOTFOUND THEN
        --
        dbms_output.put_line('site_part does not exists continue with p_site_part_objid as NULL');
        --
        p_msg := 'SITE PART OBJID DOES NOT EXIST';
        --
        RETURN;
        --
      END IF;
      --
      dbms_output.put_line('site_part_rec.sim_part_number:' || site_part_rec.sim_part_number);
      dbms_output.put_line('site_part_rec.x_zipcode:' || site_part_rec.x_zipcode);
      dbms_output.put_line('site_part_rec.x_parent_name:' || site_part_rec.x_parent_name);
      dbms_output.put_line('site_part_rec.x_parent_id:' || site_part_rec.x_parent_id);
      dbms_output.put_line('site_part_rec.x_carreir_id:' || site_part_rec.x_carrier_id);
      --
      CLOSE site_part_curs;
      --
    END IF;
    --
    IF p_esn IS NOT NULL THEN
      --
      OPEN esn_curs;
      FETCH esn_curs
        INTO esn_rec;
      --
      IF esn_curs%NOTFOUND THEN
        --
        CLOSE esn_curs;
        --
        dbms_output.put_line('esn is not valid');
        --
        RETURN;
        --
      END IF;
      --
      dbms_output.put_line('esn info-------------------------------------------------------------------');
      dbms_output.put_line('esn info-------------------------------------------------------------------');
      dbms_output.put_line('esn_rec.esn:' || esn_rec.esn);
      dbms_output.put_line('esn_rec.is_active:' || esn_rec.is_active);
      dbms_output.put_line('esn_rec.carrier_pending:' || esn_rec.carrier_pending);
      dbms_output.put_line('esn_rec.x_part_inst_status:' || esn_rec.x_part_inst_status);
      dbms_output.put_line('esn_rec.X_ICCID:' || esn_rec.x_iccid);
      dbms_output.put_line('esn_rec.dealer_id:' || esn_rec.dealer_id);
      dbms_output.put_line('esn_rec.part_num_objid:' || esn_rec.part_num_objid);
      dbms_output.put_line('esn_rec.esn_part_number:' || esn_rec.esn_part_number);
      dbms_output.put_line('esn_rec.reserved_line:' || esn_rec.reserved_line);
      dbms_output.put_line('esn_rec.reserved_used_line:' || esn_rec.reserved_used_line);
      --
      l_esn_part_number_objid := esn_rec.part_num_objid;
      --
      CLOSE esn_curs;
      --
    ELSE
      --
      p_msg := 'P_ESN IS NULL';
      --
      RETURN;
      --
    END IF;
    --
    dbms_output.put_line('p_zip:' || p_zip);
    --
    FOR esn_part_num_info_rec IN esn_part_num_info_curs(l_esn_part_number_objid) LOOP
      --
      dbms_output.put_line('esn part num info-------------------------------------------------------------------');
      dbms_output.put_line('esn part num info-------------------------------------------------------------------');
      dbms_output.put_line('esn_part_num_info_rec.x_dll:' || esn_part_num_info_rec.x_dll);
      dbms_output.put_line('esn_part_num_info_rec.phone_frequency:' || esn_part_num_info_rec.phone_frequency);
      dbms_output.put_line('esn_part_num_info_rec.phone_frequency2:' || esn_part_num_info_rec.phone_frequency2);
      dbms_output.put_line('esn_part_num_info_rec.x_technology:' || esn_part_num_info_rec.x_technology);
      dbms_output.put_line('esn_part_num_info_rec.non_ppe:' || esn_part_num_info_rec.non_ppe);
      dbms_output.put_line('esn_part_num_info_rec.x_meid_phone:' || esn_part_num_info_rec.x_meid_phone);
      dbms_output.put_line('esn_part_num_info_rec.x_data_capable:' || esn_part_num_info_rec.x_data_capable);
      dbms_output.put_line('esn_part_num_info_rec.data_speed:' || esn_part_num_info_rec.data_speed);
      dbms_output.put_line('esn_part_num_info_rec.bus_org_objid:' || esn_part_num_info_rec.bus_org_objid);
      dbms_output.put_line('esn_part_num_info_rec.org_id:' || esn_part_num_info_rec.org_id);
      dbms_output.put_line('esn_part_num_info_rec.unlimited_plan:' || esn_part_num_info_rec.unlimited_plan);
      --
      IF esn_part_num_info_rec.x_technology = 'GSM'
         AND site_part_rec.sim_part_number IS NULL THEN
        --
        p_msg := 'TECH IS GSM AND SIM IS NULL';
        --
        RETURN;
        --
      END IF;
      --
      FOR carrier_rec IN carrier_curs(esn_rec.dealer_id
                                     ,p_zip
                                     ,esn_part_num_info_rec.phone_frequency
                                     ,esn_part_num_info_rec.phone_frequency2
                                     ,esn_part_num_info_rec.x_technology
                                     ,site_part_rec.sim_part_number
                                     ,esn_part_num_info_rec.esn_part_number
                                     ,esn_part_num_info_rec.data_speed               --x_data_capable
                                     ,esn_part_num_info_rec.x_meid_phone
                                     ,esn_part_num_info_rec.non_ppe
                                     ,esn_part_num_info_rec.unlimited_plan
                                     ,esn_part_num_info_rec.bus_org_objid
                                     ,esn_part_num_info_rec.x_dll) LOOP
        --
        dbms_output.put_line('carrier info-------------------------------------------------------------------');
        dbms_output.put_line('carrier info-------------------------------------------------------------------');
        dbms_output.put_line('carrier_rec.x_carrier_id:' || carrier_rec.x_carrier_id);
        dbms_output.put_line('carrier_rec.objid:' || carrier_rec.objid);
        dbms_output.put_line('carrier_rec.x_parent_name:' || carrier_rec.x_parent_name);
        dbms_output.put_line('carrier_rec.x_parent_id:' || carrier_rec.x_parent_id);
        dbms_output.put_line('carrier_rec.no_inventory_carrier:' || carrier_rec.no_inventory_carrier);
        dbms_output.put_line('carrier_rec.x_data_service:' || carrier_rec.x_data_service);
        dbms_output.put_line('carrier_rec.x_meid_carrier:' || carrier_rec.x_meid_carrier);
        dbms_output.put_line('carrier_rec.non_ppe:' || carrier_rec.non_ppe);
        dbms_output.put_line('carrier_rec.x_dealer_id:' || carrier_rec.x_dealer_id);
        dbms_output.put_line('carrier_rec.new_rank:' || carrier_rec.new_rank);
        dbms_output.put_line('carrier_rec.org_id:' || carrier_rec.org_id);
        dbms_output.put_line('carrier_rec.sim_profile:' || carrier_rec.sim_profile);
        dbms_output.put_line('carrier_rec.min_dll_exch:' || carrier_rec.min_dll_exch);
        dbms_output.put_line('carrier_rec.max_dll_exch:' || carrier_rec.max_dll_exch);
        dbms_output.put_line('carrier_rec.frequency:' || carrier_rec.frequency);
        dbms_output.put_line('carrier_rec.not_certified:' || carrier_rec.not_certified);
        dbms_output.put_line('carrier_rec.rnk:' || carrier_rec.rnk);
        dbms_output.put_line('carrier_rec.new_rank:' || carrier_rec.new_rank);
        --
        IF p_site_part_objid IS NOT NULL THEN
          --
          big_tab.extend;
          cnt := big_tab.count;
          --
          dbms_output.put_line('cnt:' || cnt);
          --
          big_tab(cnt).carrier_info := carrier_rec;
          big_tab(cnt).phone_part_number := esn_part_num_info_rec.esn_part_number;
          --
          OPEN zone_info_curs(carrier_rec.x_carrier_id
                             ,site_part_rec.x_carrier_id
                             ,carrier_rec.x_parent_id
                             ,site_part_rec.x_parent_id
                             ,carrier_rec.x_parent_name
                             ,site_part_rec.x_parent_name
                             ,p_zip
                             ,site_part_rec.x_zipcode);
          --
          FETCH zone_info_curs
            INTO big_tab(cnt).same_carrier
                ,big_tab(cnt).same_zone
                ,big_tab(cnt).same_parent;
          --
          dbms_output.put_line('same carrier:' || big_tab(cnt).same_carrier);
          dbms_output.put_line('same zone:' || big_tab(cnt).same_zone);
          dbms_output.put_line('same parent:' || big_tab(cnt).same_parent);
          --
          CLOSE zone_info_curs;
          --
        END IF;
        --
      END LOOP;
      --
    END LOOP;
    --
    IF big_tab.count > 0 THEN
      --
      FOR i IN big_tab.first .. big_tab.last LOOP
        --
        dbms_output.put_line(big_tab(i).carrier_info.x_parent_name);
        dbms_output.put_line(big_tab(i).carrier_info.sim_profile);
        dbms_output.put_line(big_tab(i).same_carrier);
        dbms_output.put_line(big_tab(i).same_zone);
        dbms_output.put_line(big_tab(i).same_parent);
        --
        IF big_tab(i).same_carrier = 1
            AND big_tab(i).same_zone = 1 THEN
          --
          p_msg := 'MIN CHANGE ALLOWED';
          --
          RETURN;
          --
        END IF;
        --
      END LOOP;
      --
      FOR i IN big_tab.first .. big_tab.last LOOP
        --
        dbms_output.put_line(big_tab(i).carrier_info.x_parent_name);
        dbms_output.put_line(big_tab(i).carrier_info.sim_profile);
        dbms_output.put_line(big_tab(i).same_carrier);
        dbms_output.put_line(big_tab(i).same_zone);
        dbms_output.put_line(big_tab(i).same_parent);
        --
        IF big_tab(i).same_zone = 1 THEN
          --
          p_msg := 'MIN CHANGE ALLOWED';
          --
          RETURN;
          --
        END IF;
        --
      END LOOP;
      --
      FOR i IN big_tab.first .. big_tab.last LOOP
        --
        dbms_output.put_line(big_tab(i).carrier_info.x_parent_name);
        dbms_output.put_line(big_tab(i).carrier_info.sim_profile);
        dbms_output.put_line(big_tab(i).same_carrier);
        dbms_output.put_line(big_tab(i).same_zone);
        dbms_output.put_line(big_tab(i).same_parent);
        --
        --CR32498_SIM Warranty Exchange Enhancements added big_tab(i).shippable='Y' condition below
        IF big_tab(i).same_parent = 1 AND big_tab(i).carrier_info.shippable='Y'
        THEN
          --
          p_msg     := 'SIM EXCHANGE';
          p_sim_out := big_tab(i).carrier_info.sim_profile;
          --
          RETURN;
          --
        END IF;
        --
      END LOOP;
      --
    END IF;
    --
    FOR esn_part_num_info_rec IN esn_part_num_info_curs(l_esn_part_number_objid) LOOP
      --
      dbms_output.put_line('esn part num info-------------------------------------------------------------------');
      dbms_output.put_line('esn part num info-------------------------------------------------------------------');
      dbms_output.put_line('esn_part_num_info_rec.x_dll:' || esn_part_num_info_rec.x_dll);
      dbms_output.put_line('esn_part_num_info_rec.phone_frequency:' || esn_part_num_info_rec.phone_frequency);
      dbms_output.put_line('esn_part_num_info_rec.phone_frequency2:' || esn_part_num_info_rec.phone_frequency2);
      dbms_output.put_line('esn_part_num_info_rec.x_technology:' || esn_part_num_info_rec.x_technology);
      dbms_output.put_line('esn_part_num_info_rec.non_ppe:' || esn_part_num_info_rec.non_ppe);
      dbms_output.put_line('esn_part_num_info_rec.x_meid_phone:' || esn_part_num_info_rec.x_meid_phone);
      dbms_output.put_line('esn_part_num_info_rec.x_data_capable:' || esn_part_num_info_rec.x_data_capable);
      dbms_output.put_line('esn_part_num_info_rec.data_speed:' || esn_part_num_info_rec.data_speed);
      dbms_output.put_line('esn_part_num_info_rec.bus_org_objid:' || esn_part_num_info_rec.bus_org_objid);
      dbms_output.put_line('esn_part_num_info_rec.org_id:' || esn_part_num_info_rec.org_id);
      dbms_output.put_line('esn_part_num_info_rec.unlimited_plan:' || esn_part_num_info_rec.unlimited_plan);
      --
      FOR carrier_rec IN carrier_curs(esn_rec.dealer_id
                                     ,p_zip
                                     ,esn_part_num_info_rec.phone_frequency
                                     ,esn_part_num_info_rec.phone_frequency2
                                     ,esn_part_num_info_rec.x_technology
                                     ,NULL
                                     ,esn_part_num_info_rec.esn_part_number
                                     ,esn_part_num_info_rec.data_speed                --x_data_capable
                                     ,esn_part_num_info_rec.x_meid_phone
                                     ,esn_part_num_info_rec.non_ppe
                                     ,esn_part_num_info_rec.unlimited_plan
                                     ,esn_part_num_info_rec.bus_org_objid
                                     ,esn_part_num_info_rec.x_dll) LOOP
        --
        dbms_output.put_line('carrier info-------------------------------------------------------------------');
        dbms_output.put_line('carrier info-------------------------------------------------------------------');
        dbms_output.put_line('carrier_rec.x_carrier_id:' || carrier_rec.x_carrier_id);
        dbms_output.put_line('carrier_rec.objid:' || carrier_rec.objid);
        dbms_output.put_line('carrier_rec.x_parent_name:' || carrier_rec.x_parent_name);
        dbms_output.put_line('carrier_rec.x_parent_id:' || carrier_rec.x_parent_id);
        dbms_output.put_line('carrier_rec.no_inventory_carrier:' || carrier_rec.no_inventory_carrier);
        dbms_output.put_line('carrier_rec.x_data_service:' || carrier_rec.x_data_service);
        dbms_output.put_line('carrier_rec.x_meid_carrier:' || carrier_rec.x_meid_carrier);
        dbms_output.put_line('carrier_rec.non_ppe:' || carrier_rec.non_ppe);
        dbms_output.put_line('carrier_rec.x_dealer_id:' || carrier_rec.x_dealer_id);
        dbms_output.put_line('carrier_rec.new_rank:' || carrier_rec.new_rank);
        dbms_output.put_line('carrier_rec.org_id:' || carrier_rec.org_id);
        dbms_output.put_line('carrier_rec.sim_profile:' || carrier_rec.sim_profile);
        dbms_output.put_line('carrier_rec.min_dll_exch:' || carrier_rec.min_dll_exch);
        dbms_output.put_line('carrier_rec.max_dll_exch:' || carrier_rec.max_dll_exch);
        dbms_output.put_line('carrier_rec.frequency:' || carrier_rec.frequency);
        dbms_output.put_line('carrier_rec.not_certified:' || carrier_rec.not_certified);
        dbms_output.put_line('carrier_rec.rnk:' || carrier_rec.rnk);
        dbms_output.put_line('carrier_rec.new_rank:' || carrier_rec.new_rank);
        --
        --CR32498_SIM Warranty Exchange Enhancements added below IF block
        IF v_repl_sim_found = 'N' THEN
          v_repl_sim_found := 'Y';
          p_msg     := 'SIM EXCHANGE';
          p_sim_out := carrier_rec.sim_profile;
        END IF;

        --CR32498_SIM Warranty Exchange Enhancements added below IF condition
        IF carrier_rec.shippable = 'Y' THEN
          p_msg     := 'SIM EXCHANGE';
          p_sim_out := carrier_rec.sim_profile;
          RETURN;
        END IF;
        --
      END LOOP;
      --
    END LOOP;
    --
  END min_change_allowed;
  --
  PROCEDURE min_change_allowed
  (
    p_esn     IN VARCHAR2
   ,p_zip     IN VARCHAR2
   ,p_msg     OUT VARCHAR2
   ,p_sim_out OUT VARCHAR2
  ) IS
    --
  BEGIN
    --
    min_change_allowed(p_esn             => p_esn
                      ,p_zip             => p_zip
                      ,p_site_part_objid => f_actve_site_part_objid_by_esn(p_esn => p_esn)
                      ,p_msg             => p_msg
                      ,p_sim_out         => p_sim_out);
    --
  END min_change_allowed;
  --
END carriers_verification;
/