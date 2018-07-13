CREATE OR REPLACE PACKAGE BODY sa.rtr_pkg AS
/****************************************************************************
*****************************************************************************
* $Revision: 1.148 $
* $Author: oimana $
* $Date: 2017/08/18 22:25:37 $
* $Log: RTR_PKB.sql,v $
* Revision 1.148  2017/08/18 22:25:37  oimana
* CR49195 - Package Body
*
*
* Revision 1.146  2017/06/29 22:00:29  vlaad
* CR48083 - Package Body
*
*****************************************************************************
*****************************************************************************/
--
  PROCEDURE update_response_code (p_trans_id      IN  NUMBER,
                                  p_response_code IN  VARCHAR2,
                                  p_error_code    OUT NUMBER,
                                  p_error_message OUT VARCHAR2) IS
  BEGIN
    UPDATE sa.x_rtr_trans
      SET x_response_code = p_response_code
    WHERE objid           = p_trans_id;
    p_error_code := 0;
  EXCEPTION WHEN OTHERS THEN
    p_error_code := 99;
    p_error_message := sqlerrm;
  END update_response_code;
--
  PROCEDURE validate_red_card (p_x_red_code     IN VARCHAR2,
                               p_error_code    OUT NUMBER,
                               p_error_message OUT VARCHAR2) IS

    CURSOR red_card_curs IS
      SELECT rc.x_red_code,rc.x_smp
        FROM table_x_red_card rc
       WHERE rc.x_red_code = p_x_red_code
         AND rc.x_result = 'Completed';

    red_card_rec red_card_curs%rowtype;

  BEGIN

    OPEN red_card_curs;
      FETCH red_card_curs INTO red_card_rec;

      IF red_card_curs%found THEN
        p_error_code := 30;
        p_error_message := 'COMPLETED';
      ELSE
        p_error_code := 31;
        p_error_message := 'FAILED';
      END IF;

    CLOSE red_card_curs;

  EXCEPTION WHEN OTHERS THEN
    p_error_code := 99;
    p_error_message := sqlerrm;
  END validate_red_card;
--
  PROCEDURE validate_dealer (p_partner_id     IN VARCHAR2,
                             p_sercurity_code IN VARCHAR2,
                             p_error_code    OUT NUMBER,
                             p_error_message OUT VARCHAR2) IS

    CURSOR dealer_curs IS
      SELECT pi.*
        FROM sa.table_site S,
             sa.x_partner_id pi
      WHERE S.site_id = pi.x_site_id
        AND pi.x_status = 'Active'
        AND pi.x_partner_id = p_partner_id
        AND pi.x_security_code = p_sercurity_code;

    dealer_rec dealer_curs%rowtype;

  BEGIN

    OPEN dealer_curs;
      FETCH dealer_curs INTO dealer_rec;

      IF dealer_curs%notfound THEN

        CLOSE dealer_curs;
        p_error_code := 1;
        p_error_message := 'INVALID DEALER';
        RETURN;

     END IF;

    CLOSE dealer_curs;

    p_error_code := 0;

  END validate_dealer;
--
  PROCEDURE sub_info (p_min               IN VARCHAR2,
                      p_part_status      OUT VARCHAR2,
                      p_plan_name        OUT VARCHAR2,
                      p_part_number      OUT VARCHAR2,
                      p_description      OUT VARCHAR2,
                      p_customer_price   OUT VARCHAR2,
                      p_future_date      OUT DATE,
                      p_brand            OUT VARCHAR2,
                      p_error_code       OUT NUMBER,
                      p_error_message    OUT VARCHAR2) IS

  BEGIN

    sub_info3 (p_min,
               NULL,
               NULL,
               NULL,
               p_part_status,
               p_plan_name,
               p_part_number,
               p_description,
               p_customer_price,
               p_future_date,
               p_brand,
               p_error_code,
               p_error_message);

  END sub_info;
--
  PROCEDURE sub_info2 (p_min               IN VARCHAR2,
                       p_card_part_number  IN VARCHAR2,
                       p_part_status      OUT VARCHAR2,
                       p_plan_name        OUT VARCHAR2,
                       p_part_number      OUT VARCHAR2,
                       p_description      OUT VARCHAR2,
                       p_customer_price   OUT VARCHAR2,
                       p_future_date      OUT DATE,
                       p_brand            OUT VARCHAR2,
                       p_error_code       OUT NUMBER,
                       p_error_message    OUT VARCHAR2) IS --CR44729 GO SMART

  ct customer_type;

  BEGIN

    --CR44729 GO SMART
    --these checks are applicable only if line is active.
    --For inactive lines, MIN will not be passed and hence customer type can not be initialized

    IF p_min IS NOT NULL THEN

      ct := customer_type (i_esn => NULL,
                           i_min => p_min);

      IF ct.response NOT LIKE '%SUCCESS%' THEN
        p_error_code    := 201;
        p_error_message := 'ERROR INITIALIZING CUSTOMER TYPE';
        RETURN;
      END IF;

    END IF;

    sub_info3 (p_min,
               NULL,
               NULL,
               p_card_part_number,
               p_part_status,
               p_plan_name,
               p_part_number,
               p_description,
               p_customer_price,
               p_future_date,
               p_brand,
               p_error_code,
               p_error_message);

  END sub_info2;
--
  PROCEDURE sub_info3 (p_min               IN  VARCHAR2,
                       p_esn               IN  VARCHAR2,
                       p_zip               IN  VARCHAR2,
                       p_card_part_number  IN  VARCHAR2,
                       p_part_status       OUT VARCHAR2,
                       p_plan_name         OUT VARCHAR2,
                       p_part_number       OUT VARCHAR2,
                       p_description       OUT VARCHAR2,
                       p_customer_price    OUT VARCHAR2,
                       p_future_date       OUT DATE,
                       p_brand             OUT VARCHAR2,
                       p_error_code        OUT NUMBER,
                       p_error_message     OUT VARCHAR2) IS

    v_count NUMBER := 0;

    CURSOR new_plan_curs (c_esn           IN VARCHAR2,
                          c_bus_org_objid IN NUMBER,
                          c_esn_pn_objid  IN NUMBER) IS
      SELECT DISTINCT
             pn.part_number,
             NVL(x_redeem_days,0) x_redeem_days,
             pn.description,   --CR39682
             DECODE(sp.objid,41, 130,
                             83, 130,
                             122,130,
                             209,130,
                             228,130,
                             42, 255,
                             84, 255,
                             123,255,
                             210,255,
                             229,255,
                             43, 495,
                             85, 495,
                             124,495,
                             211,495,
                             230,495,
                             101,50,
                             207,50,
                             225,50,
                             212,65,
                             217,65,
                             227,65,
                             187,30,
                             191,60,
                             194,100,
                    sp.customer_price) customer_price,
             sp.mkt_name
       FROM  x_serviceplanfeaturevalue_def a
            ,mtm_partclass_x_spf_value_def b
            ,x_serviceplanfeaturevalue_def c
            ,mtm_partclass_x_spf_value_def d
            ,x_serviceplanfeature_value spfv
            ,x_service_plan_feature spf
            ,x_service_plan sp
            ,table_part_num pn
      WHERE a.objid = b.spfeaturevalue_def_id
        AND b.part_class_id IN (SELECT pn.part_num2part_class
                                  FROM table_part_num pn
                                 WHERE 1=1
                                   AND pn.part_number          = p_card_part_number
                                   AND pn.part_num2bus_org     = c_bus_org_objid
                                   AND pn.domain               = 'REDEMPTION CARDS')
        AND C.objid = D.spfeaturevalue_def_id
        AND D.part_class_id IN (SELECT DISTINCT pn.part_num2part_class
                                  FROM table_part_num pn
                                 WHERE 1=1
                                   AND pn.objid            = c_esn_pn_objid
                                   AND pn.part_num2bus_org = c_bus_org_objid
                                   AND pn.domain           = 'PHONES')
        AND a.value_name = C.value_name
        AND spfv.value_ref = a.objid
        AND spf.objid = spfv.spf_value2spf
        AND sp.objid = spf.sp_feature2service_plan
        AND pn.part_number = p_card_part_number;

    CURSOR site_part_curs IS
      SELECT objid,
             x_service_id,
             part_status,
             install_date,
             x_expire_dt,
             x_zipcode,
             1 col1
        FROM table_site_part
       WHERE x_min = p_min
         AND part_status IN ('CarrierPending', 'Active')
       UNION
      SELECT /*+  ORDERED  INDEX(pi_min, IND_PART_INST_PSERIAL_U11) INDEX(pi_esn, IND_PART_INST_PSERIAL_U11) */
             sp.objid,
             sp.x_service_id,
             sp.part_status,
             sp.install_date,
             sp.x_expire_dt,
             sp.x_zipcode,
             2 col1
        FROM table_site_part sp
            ,table_part_inst pi_min
            ,table_part_inst pi_esn
       WHERE 1=1
         AND sp.x_min         = p_min
         AND sp.part_status||'' = 'Inactive'
         AND pi_min.part_serial_no = sp.x_min
         AND pi_min.x_part_inst_status||'' IN('37','39')
         AND pi_esn.part_serial_no = sp.x_service_id
         AND pi_esn.objid = pi_min.part_to_esn2part_inst
         AND pi_esn.x_part_inst_status||'' IN('54')
       UNION
      SELECT objid,
             x_service_id,
             part_status,
             install_date,
             x_expire_dt,
             x_zipcode,
             3 col1
        FROM table_site_part
       WHERE x_min = p_min
         AND part_status NOT IN ('Active','Obsolete')
      ORDER BY col1 ASC, install_date DESC;

    site_part_rec site_part_curs%rowtype;

    CURSOR brand_curs(c_esn IN VARCHAR2) IS
      SELECT bo.org_id,
             bo.objid bus_org_objid,
             pn.objid esn_pn_objid
        FROM table_part_inst pi
            ,table_mod_level ml
            ,table_part_num  pn
            ,table_bus_org   bo
      WHERE pi.part_serial_no = c_esn
        AND ml.objid = n_part_inst2part_mod
        AND pn.objid = ml.part_info2part_num
        AND bo.objid = pn.part_num2bus_org;

    brand_rec brand_curs%rowtype;

    CURSOR plan_curs (c_site_part_objid IN NUMBER) IS
      SELECT /*+ ORDERED */
             pn.part_number,
             NVL(x_redeem_days,0) x_redeem_days,
             pn.description,   --CR39682
             DECODE(sp.objid,41, 130,
                             83, 130,
                             122,130,
                             209,130,
                             228,130,
                             42, 255,
                             84, 255,
                             123,255,
                             210,255,
                             229,255,
                             43, 495,
                             85, 495,
                             124,495,
                             211,495,
                             230,495,
                             101,50,
                             207,50,
                             225,50,
                             212,65,
                             217,65,
                             227,65,
                             187,30,
                             191,60,
                             194,100,
                    sp.customer_price) customer_price,
             sp.mkt_name
        FROM x_service_plan_site_part spsp,
             x_service_plan sp,
             x_service_plan_feature spf,
             x_serviceplanfeaturevalue_def spfvdef,
             x_serviceplanfeature_value spfv,
             x_serviceplanfeaturevalue_def spfvdef2,
             table_part_num pn
       WHERE spsp.table_site_part_id     = c_site_part_objid
         AND sp.objid                    = spsp.x_service_plan_id
         AND spf.sp_feature2service_plan = sp.objid
         AND spfvdef.objid               = spf.sp_feature2rest_value_def
         AND spfvdef.value_name          = 'PLAN_PURCHASE_PART_NUMBER'
         AND spfv.spf_value2spf          = spf.objid
         AND spfvdef2.objid              = spfv.value_ref
         AND pn.part_number              = spfvdef2.value_name;

    plan_rec plan_curs%rowtype;

    CURSOR queue_card_days_curs(p_esn IN VARCHAR2) IS
      SELECT NVL(SUM(x_redeem_days),0) queued_days
        FROM table_part_inst pi_esn,
             table_part_inst pi_qc,
             table_mod_level ml,
             table_part_num pn
       WHERE pn.objid                    = ml.part_info2part_num
         AND ml.objid                    = pi_qc.n_part_inst2part_mod
         AND pi_qc.x_part_inst_status    = '400'
         AND pi_qc.part_to_esn2part_inst = pi_esn.objid
         AND pi_esn.x_domain             = 'PHONES'
         AND pi_esn.part_serial_no       = p_esn;

    queue_card_days_rec queue_card_days_curs%rowtype;

    CURSOR check_esn_status_curs IS
      SELECT x_part_inst_status
        FROM table_part_inst pi
       WHERE pi.x_domain = 'PHONES'
         AND pi.part_serial_no = p_esn
         AND pi.x_part_inst_status IN ('50','150','51');

    check_esn_status_rec check_esn_status_curs%rowtype;

    CURSOR check_pn_curs IS
      SELECT pn.part_num2part_class
        FROM table_part_num pn
       WHERE pn.domain       = 'REDEMPTION CARDS'
         AND pn.part_number  = p_card_part_number;

    check_pn_rec check_pn_curs%rowtype;

    CURSOR min_curs IS
      SELECT pa.x_parent_name
        FROM table_part_inst pi,
             table_x_carrier  ca,
             table_x_carrier_group cg,
             table_x_parent pa
       WHERE 1=1
         AND pi.part_serial_no = p_min
         AND pi.x_domain = 'LINES'
         AND ca.objid = pi.part_inst2carrier_mkt
         AND cg.objid = ca.carrier2carrier_group
         AND pa.objid = cg.x_carrier_group2x_parent;

    min_rec min_curs%rowtype;

    CURSOR esn_curs(c_esn IN VARCHAR2) IS
      SELECT pi.x_iccid,pn.x_technology
        FROM table_part_inst pi,
             table_mod_level ml,
             table_part_num pn
       WHERE pi.part_serial_no = c_esn
         AND pi.x_domain = 'PHONES'
         AND ml.objid =pi.n_part_inst2part_mod
         AND pn.objid =ml.part_info2part_num;

    esn_rec esn_curs%rowtype;

    ---CR38286
    CURSOR tracfone_pn_curs IS
      SELECT (SELECT mkt_name
                FROM x_service_plan
               WHERE objid = 252) mkt_name,
             (SELECT p.x_retail_price
                FROM table_x_pricing p
               WHERE P.x_pricing2part_num = pn.objid
                 AND P.x_channel = 'WEB'
                 AND sysdate BETWEEN x_start_date AND x_end_date) customer_price,
             pn.part_number,
             NVL(pn.x_redeem_days,0) x_redeem_days,
             pn.description
        FROM table_part_num pn,
             table_bus_org bo
       WHERE pn.part_number = p_card_part_number
         AND bo.objid = pn.part_num2bus_org
         AND bo.org_id = 'TRACFONE';

    tracfone_pn_rec tracfone_pn_curs%rowtype;

    --CR38286
    --CR44729 GO SMART
    --CR47757

    CURSOR safelink_pn_curs IS
      SELECT NULL mkt_name,
             (SELECT p.x_retail_price
                FROM table_x_pricing p
               WHERE p.x_pricing2part_num = pn.objid
                 AND sysdate BETWEEN x_start_date AND x_end_date
                 AND ROWNUM = 1) customer_price,
             pn.part_number,
             NVL(pn.x_redeem_days,0) x_redeem_days,
             pn.description
        FROM table_part_num pn,
             table_bus_org bo
       WHERE pn.part_number = p_card_part_number
         AND bo.objid       = pn.part_num2bus_org
         AND bo.org_id      = 'TRACFONE';

    safelink_pn_rec safelink_pn_curs%rowtype; --CR47757

  BEGIN

    IF p_card_part_number IS NOT NULL THEN

      OPEN check_pn_curs;
        FETCH check_pn_curs INTO check_pn_rec;

        IF check_pn_curs%notfound THEN
          check_pn_rec.part_num2part_class := -1;
        END IF;

      CLOSE check_pn_curs;

    END IF;

    IF p_min IS NOT NULL THEN

      OPEN site_part_curs;
        FETCH site_part_curs INTO site_part_rec;

        IF site_part_curs%notfound THEN
          CLOSE site_part_curs;
          p_error_code := 2;
          p_error_message := 'FAILURE_SUBSCRIBER_NOT_FOUND';
          RETURN;
        ELSIF site_part_rec.col1 NOT IN(1,2) THEN
          CLOSE site_part_curs;
          p_error_code := 8;
          p_error_message := 'SUBSCRIBER NOT ACTIVE';
          RETURN;
        END IF;

      CLOSE site_part_curs;

      OPEN min_curs;
        FETCH min_curs INTO min_rec;
      CLOSE min_curs;

      OPEN esn_curs(site_part_rec.x_service_id);
        FETCH esn_curs INTO esn_rec;
      CLOSE esn_curs;

      IF esn_rec.x_technology = 'GSM' THEN
        sa.nap_service_pkg.get_list (site_part_rec.x_zipcode, site_part_rec.x_service_id, NULL, esn_rec.x_iccid, NULL, NULL);
      ELSE
        sa.nap_service_pkg.get_list (site_part_rec.x_zipcode, site_part_rec.x_service_id, NULL, NULL, NULL, NULL);
      END IF;

      dbms_output.put_line('nap_SERVICE_pkg.big_tab.count: '||nap_service_pkg.big_tab.COUNT);

      IF sa.nap_service_pkg.big_tab.COUNT > 0 THEN

        dbms_output.put_line ((substr(min_rec.x_parent_name,1,2)));

        IF min_rec.x_parent_name LIKE '%VERIZON%' AND
           sa.nap_service_pkg.big_tab(1).carrier_info.x_parent_name NOT LIKE '%VERIZON%' OR
           min_rec.x_parent_name LIKE '%SPRINT%' AND
           sa.nap_service_pkg.big_tab(1).carrier_info.x_parent_name NOT LIKE '%SPRINT%' OR
           min_rec.x_parent_name LIKE 'T_MO%' AND
           sa.nap_service_pkg.big_tab(1).carrier_info.x_parent_name NOT LIKE 'T_MO%' OR
           substr(min_rec.x_parent_name,1,2) IN ('AT','CI') AND
           substr(sa.nap_service_pkg.big_tab(1).carrier_info.x_parent_name,1,2) NOT IN('AT','CI') THEN

          p_error_code := 13;
          p_error_message := 'FAILURE_NON_COMPATIBLE_HANDSET';
          RETURN;

        END IF;

      ELSE

        p_error_code := 40;
        p_error_message := 'PHONE INVALID FOR ZIPCODE';
        RETURN;

      END IF;

    ELSIF p_esn IS NOT NULL THEN

      OPEN check_esn_status_curs;
        FETCH check_esn_status_curs INTO check_esn_status_rec;

        IF check_esn_status_curs%notfound THEN
          CLOSE check_esn_status_curs;
          p_error_code := 41;
          p_error_message := 'PHONE NOT ACTIVATABLE STATUS';
          RETURN;
        END IF;

      CLOSE check_esn_status_curs;

      nap_service_pkg.get_list (p_zip, p_esn, NULL, NULL, NULL, NULL);

      dbms_output.put_line('nap_SERVICE_pkg.big_tab.count: '||nap_service_pkg.big_tab.COUNT);

      IF nap_service_pkg.big_tab.COUNT > 0 THEN
        NULL;
      ELSE
        p_error_code := 40;
        p_error_message := 'PHONE INVALID FOR ZIPCODE';
        RETURN;
      END IF;

    END IF;

    OPEN brand_curs (NVL(p_esn, site_part_rec.x_service_id));
      FETCH brand_curs INTO brand_rec;

      IF brand_curs%notfound OR
         brand_rec.org_id NOT IN ('SIMPLE_MOBILE','NET10','TRACFONE',/*CR39692*/'TOTAL_WIRELESS'/*CR39692*/,'TELCEL','STRAIGHT_TALK'/*cr25398*/) THEN

        CLOSE brand_curs;
        p_error_code := 20;
        p_error_message := 'INVALID BRAND';
        RETURN;

      END IF;

      p_brand := brand_rec.org_id;

    CLOSE brand_curs;

    OPEN queue_card_days_curs (site_part_rec.x_service_id);
      FETCH queue_card_days_curs INTO queue_card_days_rec;

      IF queue_card_days_curs%notfound THEN
        queue_card_days_rec.queued_days := 0;
      END IF;

    CLOSE queue_card_days_curs;

    dbms_output.put_line('site_part_rec.objid: '||site_part_rec.objid);
    dbms_output.put_line('p_card_part_number: '||p_card_part_number);
    dbms_output.put_line('check_pn_rec.part_num2part_class: '||check_pn_rec.part_num2part_class);

    IF (p_card_part_number IS NULL) OR (check_pn_rec.part_num2part_class = -1)  THEN

      IF (check_pn_rec.part_num2part_class = -1) THEN --CR49195

        p_error_code    := 28;                                                   --changed p_error_code for CR49195
        p_error_message := 'Card Part Number not found - Input value invalid.';  --changed p_error_message for CR49195
        dbms_output.put_line('p_card_part_number IS INVALID');
        dbms_output.put_line('site_part_rec.objid: '||site_part_rec.objid);
        RETURN;

      ELSE

        dbms_output.put_line('p_card_part_number IS NULL');
        dbms_output.put_line('site_part_rec.objid: '||site_part_rec.objid);

      END IF;

      OPEN plan_curs (site_part_rec.objid);
        FETCH plan_curs INTO plan_rec;

        IF plan_curs%notfound THEN

          CLOSE plan_curs;
          p_error_code    := 33;                                           --changed p_error_code for CR45002
          p_error_message := 'Service Plan not available for this item.';  --changed p_error_message for CR45002
          dbms_output.put_line('not found');
          RETURN;

        ELSE

          p_error_code     := 0;
          p_part_number    := plan_rec.part_number;
          p_description    := plan_rec.description;
          p_customer_price := plan_rec.customer_price; --CR34092
          p_plan_name      := plan_rec.mkt_name;
          p_future_date    := (site_part_rec.x_expire_dt + queue_card_days_rec.queued_days + plan_rec.x_redeem_days);
          p_part_status    := site_part_rec.part_status;

          dbms_output.put_line('site_part_rec.x_expire_dt: '||site_part_rec.x_expire_dt);
          dbms_output.put_line('queue_card_days_rec.queued_days: '||queue_card_days_rec.queued_days);

        END IF;

      CLOSE plan_curs;

    ELSIF p_brand != 'TRACFONE' THEN

      --FOR CR38286
      dbms_output.put_line('NVL(p_esn,site_part_rec.x_service_id): '||NVL(p_esn,site_part_rec.x_service_id));
      dbms_output.put_line('brand_rec.bus_org_objid: '||brand_rec.bus_org_objid);
      dbms_output.put_line('brand_rec.esn_pn_objid: '||brand_rec.esn_pn_objid);
      dbms_output.put_line('p_card_part_number: '||p_card_part_number);

      OPEN new_plan_curs (NVL(p_esn,site_part_rec.x_service_id),brand_rec.bus_org_objid,brand_rec.esn_pn_objid);
        FETCH new_plan_curs INTO plan_rec;

        dbms_output.put_line('plan_rec.mkt_name: '||plan_rec.mkt_name);

        IF new_plan_curs%notfound THEN

          CLOSE new_plan_curs;
          p_error_code := 13;
          p_error_message := 'FAILURE_NON_COMPATIBLE_HANDSET';
          RETURN;

        ELSE

          p_error_code     := 0;
          p_part_number    := plan_rec.part_number;
          p_description    := plan_rec.description;
          p_customer_price := plan_rec.customer_price; --CR34092
          p_plan_name      := plan_rec.mkt_name;
          p_future_date    := (site_part_rec.x_expire_dt + queue_card_days_rec.queued_days + plan_rec.x_redeem_days);

          dbms_output.put_line('site_part_rec.x_expire_dt: '||site_part_rec.x_expire_dt);
          dbms_output.put_line('queue_card_days_rec.queued_days: '||queue_card_days_rec.queued_days);

          IF p_esn IS NOT NULL THEN
            p_part_status    := 'NEW';
          ELSE
            p_part_status    := site_part_rec.part_status;
          END IF;

        END IF;

      CLOSE new_plan_curs;
      --CR38286

    ELSIF p_brand = 'TRACFONE' THEN

      --CR47757 - SafeLink Unlimited In RTR

      IF NVL(is_safelink(p_esn, p_min), 'N') = 'Y' THEN --{

      OPEN safelink_pn_curs;
        FETCH safelink_pn_curs INTO safelink_pn_rec;

        IF safelink_pn_curs%notfound THEN
          CLOSE safelink_pn_curs;
          p_error_code := 13;
          p_error_message := 'FAILURE_NON_COMPATIBLE_HANDSET';
          RETURN;
        ELSE
          p_error_code     := 0;
          p_part_number    := safelink_pn_rec.part_number;
          p_description    := safelink_pn_rec.description;
          p_customer_price := safelink_pn_rec.customer_price;
          p_plan_name      := safelink_pn_rec.mkt_name;
          p_future_date    := site_part_rec.x_expire_dt + queue_card_days_rec.queued_days + safelink_pn_rec.x_redeem_days;

          dbms_output.put_line('site_part_rec.x_expire_dt: '||site_part_rec.x_expire_dt);
          dbms_output.put_line('queue_card_days_rec.queued_days: '||queue_card_days_rec.queued_days);

          IF p_esn IS NOT NULL THEN
            p_part_status    := 'NEW';
          ELSE

            SELECT COUNT(1) INTO v_count
              FROM table_x_ota_transaction
             WHERE x_esn=site_part_rec.x_service_id
               AND x_status ='OTA PENDING';

            IF v_count =0 THEN
              p_part_status := site_part_rec.part_status;
            ELSE
              p_part_status := 'OTA PENDING';
            END IF;

          END IF;

        END IF;

      CLOSE safelink_pn_curs;

      --CR47757 - SafeLink Unlimited In RTR

      ELSE --}{

        OPEN tracfone_pn_curs;
          FETCH tracfone_pn_curs INTO tracfone_pn_rec;

          IF tracfone_pn_curs%notfound THEN

            CLOSE tracfone_pn_curs;
            p_error_code := 13;
            p_error_message := 'FAILURE_NON_COMPATIBLE_HANDSET';
            RETURN;

          ELSE

            p_error_code     := 0;
            p_part_number    := tracfone_pn_rec.part_number;
            p_description    := tracfone_pn_rec.description;
            p_customer_price := tracfone_pn_rec.customer_price; --CR34092
            p_plan_name      := tracfone_pn_rec.mkt_name;
            p_future_date    := site_part_rec.x_expire_dt + queue_card_days_rec.queued_days + tracfone_pn_rec.x_redeem_days;

            dbms_output.put_line('site_part_rec.x_expire_dt: '||site_part_rec.x_expire_dt);
            dbms_output.put_line('queue_card_days_rec.queued_days: '||queue_card_days_rec.queued_days);

            IF p_esn IS NOT NULL THEN

              p_part_status    := 'NEW';

            ELSE

              SELECT COUNT(1)
                INTO v_count
                FROM table_x_ota_transaction
               WHERE x_esn=site_part_rec.x_service_id
                 AND x_status ='OTA PENDING';

              IF v_count =0 THEN
                p_part_status := site_part_rec.part_status;
              ELSE
                p_part_status := 'OTA PENDING';
              END IF;

            END IF;

          END IF;

        CLOSE tracfone_pn_curs;  --CR38286

      END IF; --} --CR47757

    END IF;

  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    p_error_code := 99;
    p_error_message := sqlerrm;
  END sub_info3;
--
  PROCEDURE up_plan (p_min                    IN  VARCHAR2,
                     p_sourcesystem           IN  VARCHAR2,
                     p_rtr_vendor_name        IN  VARCHAR2,
                     p_rtr_merch_store_num    IN  VARCHAR2,
                     p_rtr_remote_trans_id    IN  VARCHAR2,
                     p_consumer               IN  VARCHAR2 DEFAULT NULL,--CR42260
                     p_trans_id               OUT NUMBER,
                     p_error_code             OUT NUMBER,
                     p_error_message          OUT VARCHAR2) IS

    hold            VARCHAR2(100);
    new_card_action VARCHAR2(100); --CR47757

  BEGIN

    up_plan3 (p_min,
              NULL,
              NULL,
              p_sourcesystem,
              p_rtr_vendor_name,
              p_rtr_merch_store_num,
              p_rtr_remote_trans_id,
              NULL,
              NULL,
              NULL,
              NULL,
              p_consumer,--CR42260
              p_trans_id,
              new_card_action, --CR47757
              hold,
              p_error_code,
              p_error_message);

  END;
--
  PROCEDURE up_plan2 (p_min                    IN VARCHAR2,
                      p_sourcesystem           IN VARCHAR2,
                      p_rtr_vendor_name        IN VARCHAR2,
                      p_rtr_merch_store_num    IN VARCHAR2,
                      p_rtr_remote_trans_id    IN VARCHAR2,
                      p_card_part_number       IN VARCHAR2,
                      p_rtr_merch_reg_num      IN VARCHAR2,
                      p_rtr_merch_store_name   IN VARCHAR2,
                      p_dummy1                 IN VARCHAR2,
                      p_consumer               IN VARCHAR2 DEFAULT NULL,--CR42260
                      p_trans_id               OUT NUMBER,
                      p_new_card_action        OUT VARCHAR2, --CR47757
                      p_error_code             OUT NUMBER,
                      p_error_message          OUT VARCHAR2) IS

  hold VARCHAR2(100);

  BEGIN

    up_plan3 (p_min,
              NULL,
              NULL,
              p_sourcesystem,
              p_rtr_vendor_name,
              p_rtr_merch_store_num,
              p_rtr_remote_trans_id,
              p_card_part_number,
              p_rtr_merch_reg_num ,
              p_rtr_merch_store_name,
              NULL,
              p_consumer ,
              p_trans_id,
              p_new_card_action, --CR47757
              hold,
              p_error_code,
              p_error_message);

  END up_plan2;
--
  PROCEDURE up_plan3 (p_min                     IN  VARCHAR2,
                      p_esn                     IN  VARCHAR2,
                      p_zip                     IN  VARCHAR2,
                      p_sourcesystem            IN  VARCHAR2,
                      p_rtr_merchant_id         IN  VARCHAR2,
                      p_rtr_merchant_location   IN  VARCHAR2,
                      p_rtr_remote_trans_id     IN  VARCHAR2,
                      p_card_part_number        IN  VARCHAR2,
                      p_rtr_reg_no              IN  VARCHAR2,
                      p_rtr_merchant_store_name IN  VARCHAR2,
                      p_rtr_merchant_store_num  IN  VARCHAR2,
                      p_consumer                IN  VARCHAR2 DEFAULT NULL,--CR42260
                      p_trans_id                OUT NUMBER,
                      p_new_card_action         OUT VARCHAR2, --CR47757
                      p_red_code                OUT VARCHAR2,
                      p_error_code              OUT NUMBER,
                      p_error_message           OUT VARCHAR2) IS

    PRAGMA autonomous_transaction;

    l_part_number           VARCHAR2(200);
    l_part_status           VARCHAR2(200);
    l_plan_name             VARCHAR2(200);
    l_future_date           DATE;
    l_brand                 VARCHAR2(200);
    l_description           VARCHAR2(200);
    l_customer_price        VARCHAR2(200);
    l_site_id               VARCHAR2(30);
    p_seq_name              VARCHAR2(200) := 'X_MERCH_REF_ID';
    o_next_value            NUMBER;
    o_format                VARCHAR2(200);
    p_total                 BINARY_INTEGER := 1;
    p_domain                VARCHAR2(200) := 'REDEMPTION CARDS';
    p_status                VARCHAR2(200);
    p_msg                   VARCHAR2(200);
    op_call_trans_objid     NUMBER;
    p_err_code              VARCHAR2(200);
    p_err_msg               VARCHAR2(200);
    l_rtr_trans_exists      VARCHAR2(1) := 'N';       --  CR39879 changes
    l_part_inst_status      table_part_inst.x_part_inst_status%TYPE; --  CR39879 changes
    l_src_sp_grp            x_serviceplanfeaturevalue_def.value_name%TYPE;  --CR47757
    l_dest_sp_grp           x_serviceplanfeaturevalue_def.value_name%TYPE;  --CR47757
    l_esn                   VARCHAR2(30);  --CR47757
    l_brand2                table_bus_org.org_id%TYPE := NULL; --CR51567
    cst                     sa.customer_type := sa.customer_type(); --CR51567
    S                       sa.customer_type := sa.customer_type(); --CR51567
    c_addon_flag            VARCHAR2(1); --CR44729
    ct                      customer_type;
    l_pn_sp                 x_service_plan.objid%TYPE; --CR47757
    v_redeem_cnt            NUMBER := 0; --CR48315 
    v_res_cnt               NUMBER := 0; --CR48315 
    --
    CURSOR pin_part_num_curs(c_pin_part_num IN VARCHAR2) IS
      SELECT m.objid mod_level_objid,
             bo.org_id,
             pn.x_upc,
             pn.part_number
        FROM table_part_num pn,
             table_mod_level m,
             table_bus_org bo
       WHERE 1=1
         AND pn.part_number = c_pin_part_num
         AND m.part_info2part_num = pn.objid
         AND bo.objid = pn.part_num2bus_org;

    pin_part_num_rec pin_part_num_curs%rowtype;

    CURSOR esn2_curs IS
     SELECT pi_esn.part_serial_no esn,
            pi_esn.objid pi_esn_objid,
            pi_esn.part_inst2inv_bin,  -- this need to change to the rtr machine dealer
            ib.bin_name site_id,
            2 col1
       FROM table_part_inst pi_esn,
            table_inv_bin ib
      WHERE 1=1
        AND pi_esn.part_serial_no = p_esn
        AND ib.objid = pi_esn.part_inst2inv_bin;

    CURSOR esn_curs IS
     SELECT pi_esn.part_serial_no esn,
            pi_esn.objid pi_esn_objid,
            pi_esn.part_inst2inv_bin,  -- this need to change to the rtr machine dealer
            ib.bin_name site_id,
            2 col1
       FROM table_part_inst pi_min,
            table_part_inst pi_esn,
            table_inv_bin ib
      WHERE 1=1
        AND pi_min.part_serial_no = p_min
        AND pi_esn.objid = pi_min.part_to_esn2part_inst
        AND ib.objid = pi_esn.part_inst2inv_bin
     UNION
     SELECT pi_esn.part_serial_no esn,
            pi_esn.objid pi_esn_objid,
            pi_esn.part_inst2inv_bin,  -- this need to change to the rtr machine dealer
            ib.bin_name site_id,
            1 col1
       FROM table_site_part sp,
            table_part_inst pi_esn,
            table_inv_bin ib
      WHERE sp.x_min = p_min
        AND sp.part_status IN ('CarrierPending', 'Active')
        AND pi_esn.part_serial_no = sp.x_service_id
        AND pi_esn.x_domain = 'PHONES'
        AND ib.objid = pi_esn.part_inst2inv_bin
     UNION
     SELECT /*+  ORDERED  INDEX(pi_min, IND_PART_INST_PSERIAL_U11) INDEX(pi_esn, IND_PART_INST_PSERIAL_U11) */
            pi_esn.part_serial_no esn,
            pi_esn.objid pi_esn_objid,
            pi_esn.part_inst2inv_bin,  -- this need to change to the rtr machine dealer
            ib.bin_name site_id,
            3 col1
       FROM table_site_part sp
           ,table_part_inst pi_min
           ,table_part_inst pi_esn
           ,table_inv_bin ib
      WHERE 1=1
        AND sp.x_min = p_min
        AND sp.part_status||'' = 'Inactive'
        AND pi_min.part_serial_no = sp.x_min
        AND pi_min.x_part_inst_status||'' IN ('37','39')
        AND pi_esn.part_serial_no = sp.x_service_id
        AND pi_esn.objid = pi_min.part_to_esn2part_inst
        AND pi_esn.x_part_inst_status||'' IN ('54')
        AND ib.objid = pi_esn.part_inst2inv_bin
      ORDER BY col1 ASC;

    esn_rec esn_curs%rowtype;

    CURSOR pin_curs(c_next_value IN NUMBER) IS
     SELECT *
       FROM table_x_cc_red_inv
      WHERE x_reserved_id = c_next_value;

    pin_rec pin_curs%rowtype;

    CURSOR user_curs IS
      SELECT objid,1 col2
        FROM table_user
       WHERE s_login_name = USER
      UNION
      SELECT objid,2 col2
        FROM table_user
       WHERE s_login_name = 'SA'
      ORDER BY col2;

    user_rec user_curs%rowtype;

    CURSOR check_trans_curs IS
      SELECT *
        FROM sa.x_rtr_trans
       WHERE 1=1
         AND rtr_vendor_name     = p_rtr_merchant_id
         AND rtr_remote_trans_id = p_rtr_remote_trans_id;

    check_trans_rec check_trans_curs%rowtype;

    CURSOR dealer_curs IS
      SELECT S.site_id,
             ib.objid ib_objid
        FROM sa.table_inv_bin ib,
             sa.table_site S,
             sa.x_partner_id pi
      WHERE 1=1
        AND ib.bin_name     = S.site_id
        AND S.site_id       = pi.x_site_id
        AND pi.x_status     = 'Active'
        AND pi.x_partner_id = p_rtr_merchant_id;

    dealer_rec dealer_curs%rowtype;

  BEGIN

    OPEN check_trans_curs;
      FETCH check_trans_curs INTO check_trans_rec;
      IF check_trans_curs%found THEN
        p_error_code := 11;
        p_error_message := 'DUPLICATE TRANSACTION';
        CLOSE check_trans_curs;
        RETURN;
      END IF;
    CLOSE check_trans_curs;

    OPEN dealer_curs;
      FETCH dealer_curs INTO dealer_rec;
      IF dealer_curs%notfound THEN
        CLOSE dealer_curs;
        p_error_code := 1;
        p_error_message := 'INVALID DEALER';
        RETURN;
      END IF;
    CLOSE dealer_curs;

    --CR47757 - SafeLink Unlimited In RTR
    l_esn := sa.util_pkg.get_esn_by_min(p_min);

    dbms_output.put_line('l_esn = '||l_esn);
    --CR51567 - Fix redemption service for net10 from redeeming and not queuing service plans.

    S := cst.retrieve_min (p_min);

    l_brand2 := sa.util_pkg.get_min_bus_org_id(p_min);
    IF l_brand2 IS NULL THEN
      l_brand2 := bau_util_pkg.get_esn_brand(l_esn);
    END IF;

    IF (l_brand2 = 'TRACFONE' OR  (l_brand2 = 'NET10' AND  S.service_plan_group = 'PAY_GO' )) THEN
      p_new_card_action := 'ADD_NOW';
    ELSE
      p_new_card_action := 'ADD_RESERVE'; --CR 51567
    END IF;

    dbms_output.put_line('l_brand2 = '||l_brand2);
    dbms_output.put_line('p_new_card_action = '||p_new_card_action);
    dbms_output.put_line('service_plan_group     => ' ||S.service_plan_group );

    IF NVL(is_safelink(l_esn, p_min), 'N') = 'Y' THEN

      p_get_source_dest_sp_group(
                              l_esn,
                              p_card_part_number,
                              l_src_sp_grp, --Based on ESN get the group
                              l_dest_sp_grp, --Based on FUTURE PART NUM get the group
                              p_error_code,
                              p_error_message
                              );

      IF p_error_code <> 0 THEN
        RETURN;
      END IF;

   dbms_output.put_line('l_src_sp_grp = '||l_src_sp_grp);
   dbms_output.put_line('l_dest_sp_grp = '||l_dest_sp_grp);
   dbms_output.put_line('p_error_code = '||p_error_code);
   dbms_output.put_line('p_error_message = '||p_error_message);
   --CR48315 
   get_add_res_cnt(l_esn,v_redeem_cnt,v_res_cnt);

   IF l_dest_sp_grp = 'NTSL_DATA_ONLY' AND  v_redeem_cnt = 0 THEN

    p_new_card_action := 'ADD_NOW';

   ELSIF l_dest_sp_grp = 'NTSL_DATA_ONLY' AND v_redeem_cnt = 1  AND v_res_cnt = 0 THEN

   p_new_card_action := 'ADD_RESERVE';

   ELSIF l_dest_sp_grp = 'NTSL_DATA_ONLY' AND v_redeem_cnt = 1  AND v_res_cnt > 0 THEN

   p_new_card_action := 'BLOCK';
   p_error_code      := '55';
   p_error_message   := 'More than one Redemption Card in QUEUE ';

   RETURN;

   ELSIF l_dest_sp_grp = 'NTSL_DEFAULT' THEN

    p_new_card_action := 'BLOCK';
    p_error_code      := '52';
    p_error_message   := 'Data Card is not Eligible to Redeem for SL NET10';
    RETURN;

   END IF;
   --CR48315 

   IF sa.get_device_type(l_esn) = 'FEATURE_PHONE' AND l_dest_sp_grp = 'TFSL_UNLIMITED' THEN --{

    BEGIN
      SELECT sp.objid
        INTO l_pn_sp
        FROM x_service_plan sp,
             adfcrm_serv_plan_class_matview spv,
             table_part_num tpn
       WHERE sp.objid                = spv.sp_objid
         AND tpn.part_num2part_class = spv.part_class_objid
         AND tpn.part_number         = p_card_part_number
         AND ROWNUM = 1;
    EXCEPTION
     WHEN OTHERS THEN
      l_pn_sp := NULL;
    END;

    IF l_pn_sp != '468' THEN --{

      p_new_card_action := 'BLOCK';
      p_error_code      := '51';
      p_error_message   := 'Phone(Feature Phone) is not eligible to redeem this card.';
      RETURN;

    END IF; --}

   END IF; --}

   IF    l_src_sp_grp = 'TFSL_UNLIMITED' AND l_dest_sp_grp <> 'TFSL_UNLIMITED' THEN --{
    p_new_card_action := 'BLOCK';
    p_error_code      := '50';
    p_error_message   := 'Not eligible Plan. SafeLink Unlimited plan present.';
    RETURN;
   ELSIF l_src_sp_grp = 'TFSL_UNLIMITED' AND l_dest_sp_grp = 'TFSL_UNLIMITED' THEN --}{
    p_new_card_action := 'ADD_RESERVE';
   END IF; --}

  ELSE --}{

   BEGIN --{
    SELECT sa.get_serv_plan_value(sp_objid, 'SERVICE_PLAN_GROUP')
    INTO   l_dest_sp_grp
    FROM   adfcrm_serv_plan_class_matview mv,
           table_part_num pn
    WHERE  part_num2part_class   = part_class_objid
    AND    pn.part_number        = p_card_part_number;
   EXCEPTION
    WHEN OTHERS THEN
     l_dest_sp_grp := '';
     dbms_output.put_line('EXCEPTION l_dest_sp_grp: ' || l_dest_sp_grp);
   END; --}

   IF l_dest_sp_grp = 'TFSL_UNLIMITED' THEN --{
    p_new_card_action := 'BLOCK';
    p_error_code      := '52';
    p_error_message   := 'Not eligible Plan. Not a SafeLink phone.';
    RETURN;
   END IF; --}

   --Below check added in CR47988
   IF NVL(validate_red_card_pkg.is_sl_red_pn(p_card_part_number), 'N') = 'Y' THEN --{
    p_new_card_action := 'BLOCK';
    p_error_code      := '52';
    p_error_message   := 'Not eligible Plan. Not a SafeLink phone.';
    RETURN;
   END IF; --}

  END IF; --}

  dbms_output.put_line('p_new_card_action = '||p_new_card_action);

  --CR47757 - SafeLink Unlimited In RTR

    sub_info3 (p_min,
               p_esn,
               p_zip,
               p_card_part_number,
               l_part_status,
               l_plan_name,
               l_part_number,
               l_description,
               l_customer_price,
               l_future_date,
               l_brand,
               p_error_code,
               p_error_message);

     dbms_output.put_line('p_esn: '||p_esn);
     dbms_output.put_line('p_min: '||p_min);
     dbms_output.put_line('p_error_code: '||p_error_code);
     dbms_output.put_line('l_part_number: '||l_part_number);
     dbms_output.put_line('l_plan_name: '||l_plan_name);

    IF p_error_code != 0 THEN
      RETURN;
    END IF;

     --------------------for CR39692--------
    IF UPPER(l_plan_name) LIKE '%ADD-ON%' THEN
    -- CR44729
    -- CHECK IF THE BRAND IS CONFIGURED TO ALLOW ADD ON THROUGH RTR.
    -- IF ALLOWED, THEN DO NOT RAISE AN ERROR

      IF p_min IS NOT NULL OR p_esn IS NOT NULL THEN

        ct := customer_type(i_esn => p_esn, i_min => p_min);

        IF ct.response NOT LIKE '%SUCCESS%' THEN
          p_error_code    := 201;
          p_error_message := 'ERROR INITIALIZING CUSTOMER TYPE';
          RETURN;
        END IF;

        BEGIN
          SELECT addon_rtr_applicable_flag
          INTO   c_addon_flag
          FROM   table_bus_org
          WHERE  org_id =  NVL(ct.get_sub_brand(),l_brand);
        EXCEPTION
          WHEN OTHERS THEN
            c_addon_flag := 'N';
        END;

        IF c_addon_flag != 'Y' THEN
          p_error_code := 4;
          p_error_message := 'Add-On plan is not allowed for Activation';
          RETURN;
        END IF;

      END IF;

    END IF;

    OPEN user_curs;
      FETCH user_curs INTO user_rec;
    CLOSE user_curs;

    IF p_min IS NOT NULL THEN
      OPEN esn_curs;
        FETCH esn_curs INTO esn_rec;
        IF esn_curs%notfound THEN
          CLOSE esn_curs;
          p_error_code := 2;
         p_error_message := 'FAILURE_SUBSCRIBER_NOT_FOUND';
         RETURN;
        END IF;
      CLOSE esn_curs;
    ELSE
      OPEN esn2_curs;
        FETCH esn2_curs INTO esn_rec;
        IF esn2_curs%notfound THEN
          CLOSE esn2_curs;
           p_error_code := 42;
           p_error_message := 'PHONE PART NOT FOUND';
         RETURN;
        END IF;
      CLOSE esn2_curs;
    END IF;
    --
    -- CR39879 Code changes Starts.
    BEGIN
      SELECT  x_part_inst_status
      INTO    l_part_inst_status
      FROM    table_part_inst
      WHERE   x_domain = 'PHONES'
      AND     part_serial_no  = esn_rec.esn;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        p_error_code    := 99;
        --p_error_message := SQLERRM;
        p_error_message := 'Data Not found for the given ESN';
    END;
    --
    IF l_part_inst_status = '54' THEN
      BEGIN
      SELECT  'Y'
      INTO    l_rtr_trans_exists
      FROM    x_rtr_trans
      WHERE   ((p_min IS NOT NULL AND NVL(tf_min,'x')    = p_min) OR
               (p_esn IS NOT NULL AND NVL(rtr_esn,'x')   = p_esn))
      AND     tf_trans_date > systimestamp  - 3 /1440;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      --
      IF l_rtr_trans_exists  = 'Y' THEN
        p_error_code       :=   33;
        p_error_message    :=   'Transaction is already being processed. Please try again in few minutes.';
        RETURN;
      END IF;

    END IF;
    -- CR39879 Code changes Ends.
    -- CR25398
    IF  p_rtr_merchant_id != 'IN_COMM' AND l_brand = 'STRAIGHT_TALK' THEN
        p_error_code := 20;
        p_error_message := 'INVALID BRAND';
       RETURN;
    END IF;

    OPEN pin_part_num_curs(l_part_number);
      FETCH pin_part_num_curs INTO pin_part_num_rec;
    CLOSE pin_part_num_curs;

    next_id (p_seq_name,
             o_next_value,
             o_format);

    dbms_output.put_line('O_NEXT_VALUE = ' || o_next_value);
    dbms_output.put_line('O_FORMAT = ' || o_format);

    sp_reserve_app_card (o_next_value,
                         p_total,
                         p_domain,
                         p_consumer ,--CR42260
                         p_status,
                         p_msg);

    dbms_output.put_line('P_STATUS = ' || p_status);
    dbms_output.put_line('P_MSG = ' || p_msg);

    IF p_msg != 'Completed' THEN
      p_error_code := 4;
      p_error_message := 'SP_RESERVE_APP_CARD'||': '||p_status||': '||p_msg;
      RETURN;
    END IF;

    dbms_output.put_line('1');
    OPEN pin_curs(o_next_value);
      FETCH pin_curs INTO pin_rec;
      IF pin_curs%notfound THEN
        p_error_code := 5;
        p_error_message := 'PIN CODE NOT FOUND';
        CLOSE pin_curs;
        RETURN;
      END IF;
    CLOSE pin_curs;

   UPDATE table_x_cc_red_inv
            SET    x_consumer = p_consumer  --CR42260
            WHERE  x_reserved_id = o_next_value;


   dbms_output.put_line('2');
   dbms_output.put_line('pin_part_num_rec.org_id'||pin_part_num_rec.org_id);
   dbms_output.put_line('pin_part_num_rec.org_id'||pin_part_num_rec.org_id);

   dbms_output.put_line('l_plan_name'||l_plan_name);
   --CR48315 
   IF (pin_part_num_rec.org_id IN ('TRACFONE','NET10') AND
      NVL(p_new_card_action, 'ADD_NOW') = 'ADD_NOW') OR
      (pin_part_num_rec.org_id='TOTAL_WIRELESS' AND
      UPPER(l_plan_name) LIKE '%ADD-ON%') THEN ----CR39692

   INSERT INTO table_part_inst (objid,
                                        last_pi_date,
                                        last_cycle_ct,
                                        next_cycle_ct,
                                        last_mod_time,
                                        last_trans_time,
                                        date_in_serv,
                                        repair_date,
                                        warr_end_date,
                                        x_cool_end_date,
                                        part_status,
                                        hdr_ind,
                                        x_sequence,
                                        x_insert_date,
                                        x_creation_date,
                                        x_domain,
                                        x_deactivation_flag,
                                        x_reactivation_flag,
                                       x_red_code,
                                        part_serial_no,
                                        x_part_inst_status,
                                        part_inst2inv_bin,
                                        created_by2user,
                                        status2x_code_table,
                                        n_part_inst2part_mod,
                                        part_to_esn2part_inst,
                                        x_ext)
                                VALUES ((seq('part_inst')),
                                sysdate,
                                TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
                                TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
                                sysdate,
                                sysdate,
                                TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
                                TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
                                TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
                                TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss'),
                                'Active',
                                0,
                                0,
                                sysdate,
                                sysdate,
                                'REDEMPTION CARDS',
                                0,
                                0,
                                pin_rec.x_red_card_number,
                                pin_rec.x_smp,
                                DECODE(l_part_status,'Active','40','Inactive','40','NEW','40'),
                                dealer_rec.ib_objid, --esn_rec.part_inst2inv_bin,
                                user_rec.objid,
                                (SELECT objid
                                   FROM table_x_code_table
                                  WHERE x_code_number = DECODE(l_part_status,'Active','40','Inactive','40','NEW','40')),
                                pin_part_num_rec.mod_level_objid,
                                esn_rec.pi_esn_objid,
                                NVL((SELECT MAX(to_number(x_ext) + 1)
                                         FROM table_part_inst
                                        WHERE part_to_esn2part_inst = esn_rec.pi_esn_objid
                                          AND x_domain = 'REDEMPTION CARDS') ,1)
                                                ) ;

    ELSE--CR38286

    INSERT INTO table_part_inst (objid,
                                        last_pi_date,
                                        last_cycle_ct,
                                        next_cycle_ct,
                                        last_mod_time,
                                        last_trans_time,
                                        date_in_serv,
                                        repair_date,
                                        warr_end_date,
                                        x_cool_end_date,
                                        part_status,
                                        hdr_ind,
                                        x_sequence,
                                        x_insert_date,
                                        x_creation_date,
                                        x_domain,
                                        x_deactivation_flag,
                                        x_reactivation_flag,
                                       x_red_code,
                                        part_serial_no,
                                        x_part_inst_status,
                                        part_inst2inv_bin,
                                        created_by2user,
                                        status2x_code_table,
                                        n_part_inst2part_mod,
                                        part_to_esn2part_inst,
                                        x_ext)
                                VALUES ((seq('part_inst')),
                                sysdate,
                                TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
                                TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
                                sysdate,
                                sysdate,
                                TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
                                TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
                                TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
                                TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss'),
                                'Active',
                                0,
                                0,
                                sysdate,
                                sysdate,
                                'REDEMPTION CARDS',
                                0,
                                0,
                                pin_rec.x_red_card_number,
                                pin_rec.x_smp,
                                DECODE(l_part_status,'Active','400','Inactive','40','NEW','40'),
                                dealer_rec.ib_objid, --esn_rec.part_inst2inv_bin,
                                user_rec.objid,
                                (SELECT objid
                                   FROM table_x_code_table
                                  WHERE x_code_number = DECODE(l_part_status,'Active','400','Inactive','40','NEW','40')),
                                pin_part_num_rec.mod_level_objid,
                                esn_rec.pi_esn_objid,
                                NVL((SELECT MAX(to_number(x_ext) + 1)
                                         FROM table_part_inst
                                        WHERE part_to_esn2part_inst = esn_rec.pi_esn_objid
                                          AND x_domain = 'REDEMPTION CARDS') ,1)
                                                ) ;
    dbms_output.put_line('2.5');

    convert_bo_to_sql_pkg.sp_create_call_trans(esn_rec.esn --ip_esn
                                                ,'401'--ip_action_type
                                                ,NVL(p_sourcesystem ,'RTR') --IP_SOURCESYSTEM
                                                ,pin_part_num_rec.org_id --IP_BRAND_NAME,
                                                ,pin_rec.x_red_card_number  --ip_reason
                                                ,'Completed' --IP_RESULT
                                                ,NULL --ip_ota_req_type,
                                                ,'402' --IP_OTA_TYPE,      -- CR15847 PM ST Steaking
                                                ,0 --ip_total_units
                                                ,op_call_trans_objid
                                                ,p_err_code
                                                ,p_err_msg);

    END IF;          ----CR38286

    dbms_output.put_line('3');

    UPDATE table_x_call_trans
       SET x_new_due_date = l_future_date
     WHERE objid = op_call_trans_objid;

    dbms_output.put_line('4');

    INSERT INTO sa.x_rtr_trans ( objid,
                                 tf_part_num_parent,
                                 tf_serial_num,
                                 tf_red_code,
                                 rtr_vendor_name,
                                 rtr_merch_store_num,
                                 tf_pin_status_code,
                                 tf_trans_date,
                                 tf_extract_flag,
                                 tf_extract_date,
                                 tf_site_id,
                                 rtr_trans_type,
                                 rtr_remote_trans_id,
                                 tf_sourcesystem,
                                 rtr_merch_reg_num,
                                 tf_upc,
                                 tf_min      ,
                                 rtr_merch_store_name,
                                 rtr_esn)
    VALUES(sa.sequ_x_rtr_trans.NEXTVAL,
           pin_part_num_rec.part_number,
           pin_rec.x_smp,
           pin_rec.x_red_card_number,
           p_rtr_merchant_id,
           p_rtr_merchant_location,
           DECODE(l_part_status,'Active','400','Inactive','40','NEW','40'),
           sysdate,
           DECODE(l_part_status,'Active','N','Inactive','P','NEW','P'),
           NULL,
           dealer_rec.site_id,
           DECODE(l_part_status,'NEW','ACT','ADD'),     --RTR_TRANS_TYPE     VARCHAR2(40 BYTE),
           p_rtr_remote_trans_id,
           p_sourcesystem,
           p_rtr_reg_no,     --RTR REG_NO             VARCHAR2(30 BYTE),
           pin_part_num_rec.x_upc,
           p_min ,
           p_rtr_merchant_store_name,
           esn_rec.esn
           );

    dbms_output.put_line('5');

    p_trans_id := sa.sequ_x_rtr_trans.CURRVAL;
    p_red_code := pin_rec.x_red_card_number;
    COMMIT;

  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    p_error_code := 99;
    p_error_message := sqlerrm;
  END up_plan3;
--
  PROCEDURE up_plan_cancel (p_rtr_vendor_name            IN  VARCHAR2,
                            p_add_rtr_remote_trans_id    IN  VARCHAR2,
                            p_cancel_rtr_remote_trans_id IN  VARCHAR2,
                            p_trans_id                   OUT NUMBER,
                            p_error_code                 OUT NUMBER,
                            p_error_message              OUT VARCHAR2) IS
  BEGIN

    up_plan_cancel2 (p_rtr_vendor_name,
                     NULL,
                     NULL,
                     NULL,
                     p_add_rtr_remote_trans_id,
                     p_cancel_rtr_remote_trans_id,
                     p_trans_id,
                     p_error_code,
                     p_error_message);

  END up_plan_cancel;
--
  PROCEDURE up_plan_cancel2 (p_rtr_vendor_name            IN  VARCHAR2,
                             p_rtr_merch_store_num        IN  VARCHAR2,
                             p_rtr_merch_reg_num          IN  VARCHAR2,
                             p_rtr_merch_store_name       IN VARCHAR2,
                             p_add_rtr_remote_trans_id    IN  VARCHAR2,
                             p_cancel_rtr_remote_trans_id IN  VARCHAR2,
                             p_trans_id                   OUT NUMBER,
                             p_error_code                 OUT NUMBER,
                             p_error_message              OUT VARCHAR2) IS

    PRAGMA autonomous_transaction;

    CURSOR check_trans_curs IS
     SELECT rt.* ,
             NVL((SELECT 1
                    FROM sa.x_rtr_trans rt
                    WHERE 1=1
                      AND rt.rtr_vendor_name     = p_rtr_vendor_name
                      AND rt.rtr_remote_trans_id = NVL(p_cancel_rtr_remote_trans_id,p_add_rtr_remote_trans_id||'C')),0) cancel_trans_id,
             NVL((SELECT 1
                   FROM sa.x_rtr_trans rt2
                  WHERE 1=1
                    AND rt2.tf_pin_status_code  = '44'
                    AND rt2.tf_red_code = rt.tf_red_code
                                    AND ROWNUM <2 ),0) cancel_flag,
             (SELECT 1
                FROM table_part_inst
               WHERE part_serial_no = rt.tf_serial_num
                 AND x_red_code     = rt.tf_red_code) pi_exists
        FROM sa.x_rtr_trans rt
       WHERE 1=1
         AND rt.tf_pin_status_code  IN ('40', '400')
         AND rt.rtr_vendor_name     = p_rtr_vendor_name
         AND rt.rtr_remote_trans_id = p_add_rtr_remote_trans_id;

    check_trans_rec check_trans_curs%rowtype;

  BEGIN

    dbms_output.put_line('inside cancel add fund');
    NULL;

    OPEN check_trans_curs;
    FETCH check_trans_curs INTO check_trans_rec;

    IF check_trans_curs%notfound THEN

      dbms_output.put_line('check_trans_curs%notfound');
      p_error_code    := 7;
      p_error_message := 'RTR TRANS NOT FOUND';
      CLOSE check_trans_curs;
      RETURN;

    ELSIF check_trans_rec.pi_exists IS NULL OR  check_trans_rec.cancel_flag = 1 THEN

      dbms_output.put_line('check_trans_rec.pi_exists IS NULL');
      p_error_code               := 9;
       p_error_message            := 'TRANSACTION ALREADY CANCELLED';
       dbms_output.put_line('before cancel_reactivation');
         cancel_reactivation( p_rtr_vendor_name ,p_add_rtr_remote_trans_id ,p_cancel_rtr_remote_trans_id,p_error_code , p_error_message, p_trans_id);
         dbms_output.put_line('after cancel_reactivation');
          --cr25928
        --p_error_code := 12;
        --p_error_message := 'CARD NOT FOUND IN PART INST';
        CLOSE check_trans_curs;
      RETURN;

    /*  elsif check_trans_rec.cancel_flag = 1 THEN
      dbms_output.put_line('check_trans_rec.cancel_flag = 1');
        p_error_code                   := 9;
        p_error_message                := 'TRANSACTION ALREADY CANCELLED';
        CLOSE check_trans_curs;
       RETURN;*/

      ELSIF check_trans_rec.cancel_trans_id = 1 THEN

       dbms_output.put_line('check_trans_rec.cancel_trans_id = 1');
        p_error_code                       := 11;
        p_error_message                    := 'DUPLICATE TRANSACTION';
        CLOSE check_trans_curs;
        RETURN;

      END IF;

    CLOSE check_trans_curs;

    UPDATE table_part_inst
    SET x_part_inst_status  = '44',
        part_to_esn2part_inst = NULL
    WHERE part_serial_no    = check_trans_rec.tf_serial_num
      AND x_red_code          = check_trans_rec.tf_red_code;

    dbms_output.put_line('insert');

    INSERT INTO sa.x_rtr_trans
      (
        objid,
        tf_part_num_parent,
        tf_serial_num,
        tf_red_code,
        rtr_vendor_name,
        rtr_merch_store_num,
        tf_pin_status_code,
        tf_trans_date,
        tf_extract_flag,
        tf_extract_date,
        tf_site_id,
        rtr_trans_type,
        rtr_remote_trans_id,
        tf_sourcesystem,
        rtr_merch_reg_num,
        tf_upc,
        tf_min,
        rtr_merch_store_name,
        rtr_esn
      )
      VALUES
      (
        sa.sequ_x_rtr_trans.NEXTVAL,
        check_trans_rec.tf_part_num_parent,
        check_trans_rec.tf_serial_num,
        check_trans_rec.tf_red_code,
        NVL(p_rtr_vendor_name, check_trans_rec.rtr_vendor_name),        --RTR_VENDOR_NAME    VARCHAR2(100 BYTE),
        NVL(p_rtr_merch_store_num,check_trans_rec.rtr_merch_store_num), --RTR_MERCH_STORE_NUM    VARCHAR2(100 BYTE),
        '44',
        sysdate,
        'N',
        NULL,
        check_trans_rec.tf_site_id,
        'REMOVE', --RTR_TRANS_TYPE     VARCHAR2(40 BYTE),
        NVL(p_cancel_rtr_remote_trans_id,p_add_rtr_remote_trans_id
        ||'C'), --RTR_REMOTE_TRANS_ID      VARCHAR2(20 BYTE),
        check_trans_rec.tf_sourcesystem,
        p_rtr_merch_reg_num,    --RTR REG_NO             VARCHAR2(30 BYTE),
        check_trans_rec.tf_upc, --TF_UPC                 VARCHAR2(30 BYTE)
        check_trans_rec.tf_min, --TF_MIN                 VARCHAR2(30 BYTE))
        p_rtr_merch_store_name,
        check_trans_rec.rtr_esn
      );

    p_trans_id := sa.sequ_x_rtr_trans.CURRVAL;

    COMMIT;

    p_error_code := 0;

  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line('exception in up_plan_cancel2 ');
    p_error_code    := 99;
    p_error_message := sqlerrm;
  END up_plan_cancel2;
--
  PROCEDURE up_plan_status (p_rtr_vendor_name     IN  VARCHAR2,
                            p_rtr_remote_trans_id IN  VARCHAR2,
                            p_trans_id            OUT NUMBER,
                            p_error_code          OUT NUMBER,
                            p_error_message       OUT VARCHAR2) IS

    CURSOR rtr_trans_curs IS
      SELECT *
        FROM sa.x_rtr_trans
       WHERE 1=1
         AND rtr_vendor_name     = p_rtr_vendor_name
         AND rtr_remote_trans_id = p_rtr_remote_trans_id;

    rtr_trans_rec rtr_trans_curs%rowtype;

  BEGIN

    OPEN rtr_trans_curs;
      FETCH rtr_trans_curs INTO rtr_trans_rec;
      IF rtr_trans_curs%notfound THEN
        CLOSE rtr_trans_curs;
        p_error_code := 7;
        p_error_message := 'RTR TRANS NOT FOUND';
        RETURN;
      END IF;
    CLOSE rtr_trans_curs;

    p_trans_id := rtr_trans_rec.objid;
    p_error_code := 0;

  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    p_error_code := 99;
    p_error_message := sqlerrm;
  END up_plan_status;
--
  PROCEDURE act_extra_info (p_trans_id             IN NUMBER,
                            p_esn                 OUT VARCHAR2,
                            p_zip                 OUT VARCHAR2,
                            p_pin                 OUT VARCHAR2,
                            p_iccid               OUT VARCHAR2,
                            p_error_code          OUT NUMBER,
                            p_error_message       OUT VARCHAR2) IS

  CURSOR c1 IS
      SELECT /*+  ORDERED */
             sp.x_service_id esn,
             sp.x_zipcode    zip,
             rtr.tf_red_code pin,
             sp.x_iccid      iccid
        FROM
             sa.x_rtr_trans rtr
            ,table_part_inst pi_min
            ,table_part_inst pi_card
            ,table_part_inst pi_esn
            ,table_site_part sp
       WHERE 1=1
         AND rtr.objid             = p_trans_id
         AND pi_min.part_serial_no = rtr.tf_min
         AND pi_card.x_red_code    = rtr.tf_red_code
         AND pi_esn.objid          = pi_min.part_to_esn2part_inst
         AND sp.objid              = pi_esn.x_part_inst2site_part;

  c1_rec c1%rowtype;

  BEGIN

    OPEN c1;
      FETCH c1 INTO c1_rec;
      IF c1%notfound THEN
        CLOSE c1;
        p_error_code := 7;
        p_error_message := 'RTR TRANS NOT FOUND';
        RETURN;
      END IF;
    CLOSE c1;

    p_esn   := c1_rec.esn;
    p_zip   := c1_rec.zip;
    p_pin   := c1_rec.pin;
    p_iccid := c1_rec.iccid;
    p_error_code := 0;

  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    p_error_code := 99;
    p_error_message := sqlerrm;
  END act_extra_info;
--
  PROCEDURE tf_redem_info (p_trans_id             IN  NUMBER,
                           p_esn                 OUT VARCHAR2,
                           p_zip                 OUT VARCHAR2,
                           p_pin                 OUT VARCHAR2,
                           p_iccid               OUT VARCHAR2,
                           p_ppe_flag            OUT NUMBER,
                           p_switch_base         OUT NUMBER,
                           p_contact_objid       OUT NUMBER,
                           p_technology          OUT VARCHAR2,
                           p_carrier_objid       OUT NUMBER,
                           p_error_code          OUT NUMBER,
                           p_error_message       OUT VARCHAR2) IS

    --for CR38286
    CURSOR c1 IS
      SELECT /*+  ORDERED */
             sp.x_service_id esn,
             sp.x_zipcode    zip,
                           rtr.tf_red_code pin,
                           sp.x_iccid      iccid,
                           sp.x_min MIN
        FROM
                           sa.x_rtr_trans rtr
            ,table_part_inst pi_min
          --  ,table_part_inst pi_card
            ,table_part_inst pi_esn
                    ,table_site_part sp
       WHERE 1=1
         AND rtr.objid             = p_trans_id
         AND pi_min.part_serial_no = rtr.tf_min
     --    and pi_card.x_red_code    = rtr.tf_red_code
                       AND pi_esn.objid          = pi_min.part_to_esn2part_inst
         AND sp.objid              = pi_esn.x_part_inst2site_part;

  c1_rec    c1%rowtype;
  rc        sa.customer_type := sa.customer_type ();
  cst       sa.customer_type;
  v_objid   NUMBER;

  BEGIN
    OPEN c1;
      FETCH c1 INTO c1_rec;
      IF c1%notfound THEN
                CLOSE c1;
        p_error_code := 7;
        p_error_message := 'RTR TRANS NOT FOUND';
                RETURN;
      END IF;
    CLOSE c1;

    cst := rc.retrieve_min(i_min => c1_rec.MIN);

      p_esn :=cst.esn;
      p_zip := cst.zipcode;
      IF cst.pin IS NOT NULL THEN
      p_pin :=  cst.pin;
      ELSE
      p_pin := c1_rec.pin;
      END IF;

      p_iccid := cst.iccid;
      p_ppe_flag :=   cst.non_ppe_flag;
      IF  cst.is_swb_carrier IS NOT NULL THEN
     p_switch_base :=   cst.is_swb_carrier;
     ELSE
     p_switch_base :=0;
     END IF;
      p_contact_objid := cst.contact_objid;
      p_technology := cst.technology;
      p_carrier_objid := cst.carrier_objid;
    p_error_code := 0;

    dbms_output.put_line('cst.carrier_objid'||cst.carrier_objid);
    dbms_output.put_line('cst.rate_plan'||cst.rate_plan);
    dbms_output.put_line('cst.data_speed'||cst.data_speed);

  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    p_error_code := 99;
    p_error_message := sqlerrm;
  END tf_redem_info;
--
  PROCEDURE cancel_reactivation (p_rtr_vendor_name            IN  VARCHAR2,
                                 p_add_rtr_remote_trans_id    IN  VARCHAR2,
                                 p_cancel_rtr_remote_trans_id IN  VARCHAR2,
                                 p_error_code                 OUT NUMBER,
                                 p_error_message              OUT VARCHAR2)
  IS

  v_trans_id VARCHAR2(100);

  BEGIN
    --Added in CR45278
    cancel_reactivation (p_rtr_vendor_name,
                         p_add_rtr_remote_trans_id,
                         p_cancel_rtr_remote_trans_id,
                         p_error_code,
                         p_error_message,
                         v_trans_id);

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      dbms_output.put_line('40');
      p_error_code    := 99;
      p_error_message := 'EXCEPTION CANCEL REACTIVATION -';
      RETURN;
  END cancel_reactivation;
--
  PROCEDURE cancel_reactivation (p_rtr_vendor_name            IN  VARCHAR2,
                                 p_add_rtr_remote_trans_id    IN  VARCHAR2,
                                 p_cancel_rtr_remote_trans_id IN  VARCHAR2,
                                 p_error_code                 OUT NUMBER,
                                 p_error_message              OUT VARCHAR2,
                                 p_trans_id                   OUT VARCHAR2) IS
    --For CR36452
    --For CR45278
    CURSOR esn_curs(c_esn IN VARCHAR2) IS
      SELECT pi.objid
        FROM table_part_inst pi,
      table_mod_level ml,
      table_part_num pn
       WHERE pi.part_serial_no = c_esn
         AND pi.x_domain = 'PHONES'
         AND ml.objid =pi.n_part_inst2part_mod
         AND pn.objid =ml.part_info2part_num;

    esn_rec esn_curs%rowtype;

  CURSOR site_part_status(p_esn IN VARCHAR2, p_rank IN NUMBER)
  IS
    SELECT x_deact_reason,
      objid
    FROM
      (SELECT x_deact_reason,
        objid,
        DENSE_RANK() OVER(PARTITION BY x_service_id ORDER BY DECODE(part_status,'Active',1,'CarrierPending',1,'Inactive',2,3), install_date DESC, objid DESC) x_rank
      FROM table_site_part
      WHERE x_service_id =p_esn
      )
  WHERE x_rank = p_rank;

  site_part_status_rec site_part_status%rowtype ;

  CURSOR rtr_trans(p_add_rtr_remote_trans_id IN VARCHAR2)
  IS
    SELECT *
    FROM x_rtr_trans
    WHERE rtr_remote_trans_id=p_add_rtr_remote_trans_id;

  rtr_trans_rec rtr_trans%rowtype;
  CURSOR call_trans(p_esn IN VARCHAR2,p_site_objid IN NUMBER)
  IS
    SELECT *
    FROM table_x_call_trans
    WHERE x_service_id      =p_esn
    AND call_trans2site_part=p_site_objid
    AND x_action_type       =3;
  call_trans_rec call_trans%rowtype;
  CURSOR red_card(p_red_card IN VARCHAR2)
  IS
    SELECT *
    FROM table_x_red_card
    WHERE x_red_code = p_red_card
    AND x_result     ='Completed';
  red_card_rec red_card%rowtype;
  CURSOR part_inst(p_red_card IN VARCHAR2)
  IS
    SELECT * FROM table_part_inst WHERE x_red_code=p_red_card ;
  part_inst_rec part_inst%rowtype;
  CURSOR ig_trans(p_esn IN VARCHAR2)
  IS
    SELECT
      /*+ use_invisible_indexes */
      *
    FROM ig_transaction
    WHERE esn       =p_esn
    AND order_type IN('Q','L','CP','W','S');
  ig_trans_rec ig_trans%rowtype;
  v_days        NUMBER;
  v_hours       NUMBER;
  v_minutes     NUMBER;
  v_cancel_fund VARCHAR2(10) := 'N';
  v_user table_user.objid%TYPE;
  p_error_flag VARCHAR2(100);

  BEGIN

  dbms_output.put_line('inside CANCEL_REACTIVATION');
  OPEN rtr_trans(p_add_rtr_remote_trans_id);
  FETCH rtr_trans INTO rtr_trans_rec;

  IF rtr_trans%found THEN
  dbms_output.put_line('RTR_TRANS%FOUND');
    SELECT TRUNC(sysdate   -rtr_trans_rec.tf_trans_date) DAYS,
      MOD( TRUNC( ( sysdate-rtr_trans_rec.tf_trans_date ) * 24 ), 24) HOURS,
      MOD( TRUNC( ( sysdate-rtr_trans_rec.tf_trans_date ) * 1440 ), 60 )
    INTO v_days,
      v_hours,
      v_minutes
    FROM dual;
      dbms_output.put_line('V_DAYS'||v_days);
      dbms_output.put_line('V_HOURS'||v_hours);
      dbms_output.put_line('V_MINUTES'||v_minutes);
    IF v_days        =0 AND v_hours =0 AND v_minutes <=10 THEN
     dbms_output.put_line('22');
      v_cancel_fund := 'Y';
    ELSE
    dbms_output.put_line('23');
     p_error_code               := 9;
      p_error_message := 'RTR TRANSACTION IS GREATER THAN 10 MINUTES';
     RETURN;
    END IF;
  END IF;
  CLOSE rtr_trans;
  OPEN site_part_status(rtr_trans_rec.rtr_esn,2);
  FETCH site_part_status INTO site_part_status_rec;
  IF site_part_status%found THEN
   dbms_output.put_line('24');
    IF site_part_status_rec.x_deact_reason = 'PASTDUE' THEN
      v_cancel_fund                       := 'Y';
    ELSE
     dbms_output.put_line('25');
     p_error_code               := 9;
      p_error_message := 'DEACT REASON IS NOT PASTDUE';
      RETURN;
    END IF;
  END IF;

  CLOSE site_part_status;

  OPEN site_part_status(rtr_trans_rec.rtr_esn,1);
  FETCH site_part_status INTO site_part_status_rec;

  IF site_part_status%found THEN

    dbms_output.put_line('26');

    OPEN call_trans(rtr_trans_rec.rtr_esn,site_part_status_rec.objid);
    FETCH call_trans INTO call_trans_rec;

    IF call_trans%found THEN
      dbms_output.put_line('27');
      v_cancel_fund := 'Y';
      CLOSE call_trans;
    ELSE
      dbms_output.put_line('28');
      p_error_code               := 9;
      p_error_message := 'CALL TRANS NOT FOUND';
      CLOSE call_trans;
      RETURN;
    END IF;
     END IF;
  CLOSE site_part_status;

  OPEN red_card(rtr_trans_rec.tf_red_code);
  FETCH red_card INTO red_card_rec;

  IF red_card%found THEN
    dbms_output.put_line('29');
    v_cancel_fund := 'Y';
  ELSE
    dbms_output.put_line('30');
    p_error_code               := 9;
    p_error_message := 'RED CARD IS NOT FOUND';
    RETURN;
  END IF;

  CLOSE red_card;

  OPEN ig_trans(rtr_trans_rec.rtr_esn);
  FETCH ig_trans INTO ig_trans_rec;

  IF ig_trans%found THEN
   dbms_output.put_line('31');
    v_cancel_fund := 'Y';
  ELSE
   dbms_output.put_line('32');
   p_error_code               := 9;
    p_error_message := 'IG STATUS IS NOT IN Q,L,CP,W,S';
    RETURN;
  END IF;

  CLOSE ig_trans;

  OPEN part_inst(rtr_trans_rec.tf_red_code);

  FETCH part_inst INTO part_inst_rec;

  IF part_inst%notfound THEN
    v_cancel_fund := 'Y';
     dbms_output.put_line('33');
  ELSE
   dbms_output.put_line('34');
  p_error_code               := 9;
    p_error_message := 'RED CARD IS NULL IN PART INST';
    RETURN;
  END IF;

  CLOSE part_inst;

  IF v_cancel_fund = 'Y' THEN

    dbms_output.put_line('35');
    SELECT objid INTO v_user FROM table_user WHERE s_login_name = 'SA';

    service_deactivation_code.deactservice ('PAST_DUE_BATCH',
                                            v_user,
                                            rtr_trans_rec.rtr_esn,
                                            rtr_trans_rec.tf_min,
                                            'PASTDUE',
                                            0,
                                            NULL,
                                            'true',
                                            p_error_flag,
                                            p_error_message);

    UPDATE table_x_red_card
       SET x_result    ='Failed'
      WHERE x_red_code=rtr_trans_rec.tf_red_code;

    -- CR42819 insert into table_part_inst to mark x_part_inst_status as cancelled

  OPEN red_card(rtr_trans_rec.tf_red_code);
  FETCH red_card
   INTO red_card_rec;
  CLOSE red_card;

  OPEN esn_curs(rtr_trans_rec.rtr_esn);
  FETCH esn_curs
    INTO esn_rec;
  CLOSE esn_curs;

  INSERT INTO table_part_inst (
    objid,
    last_pi_date,
    last_cycle_ct,
    next_cycle_ct,
    last_mod_time,
    last_trans_time,
    date_in_serv,
    repair_date,
    warr_end_date,
    x_cool_end_date,
    part_status,
    hdr_ind,
    x_sequence,
    x_insert_date,
    x_creation_date,
    x_domain,
    x_deactivation_flag,
    x_reactivation_flag,
    x_red_code,-- from red_card
    part_serial_no,-- from red_card
    x_part_inst_status,-- 44
    part_inst2inv_bin,-- from red_card
    created_by2user,
    status2x_code_table,-- code_table for 44
    n_part_inst2part_mod,-- from red_card
    part_to_esn2part_inst,-- RTR_TRANS_REC.TF_SERIAL_NUM
    x_ext
  )
  VALUES
  (
    (seq('part_inst')),-- objid
    sysdate,-- last_pi_date
    TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,--last_cycle_ct
    TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,--next_cycle_ct
    sysdate,-- last_mod_time
    sysdate,-- last_trans_time
    TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,-- date_in_serv
    TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,-- repair_date
    TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,-- warr_end_date
    TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,-- x_cool_end_date
    'Active',-- part_status
    0,-- hdr_ind
    0,-- x_sequence
    sysdate,-- x_insert_date
    sysdate,-- x_creation_date
    'REDEMPTION CARDS',-- x_domain
    0,-- x_deactivation_flag
    0,-- x_reactivation_flag
    rtr_trans_rec.tf_red_code,-- x_red_code, -- from red_card
    rtr_trans_rec.tf_serial_num,-- part_serial_no, -- from red_card
    '44',--x_part_inst_status, -- 44
    red_card_rec.x_red_card2inv_bin,--esn_rec.part_inst2inv_bin, ---- from red_card
    v_user,
    (
   SELECT   objid
     FROM table_x_code_table
     WHERE x_code_number = '44'
    ),-- code_table for 44
    red_card_rec.x_red_card2part_mod,-- from red_card -- n_part_inst2part_mod
    esn_rec.objid,-- part_to_esn2part_inst
    1 -- x_ext
  ) ;
  --
  COMMIT;

  dbms_output.put_line('36');

  INSERT INTO sa.x_rtr_trans (
        objid,
        tf_part_num_parent,
        tf_serial_num,
        tf_red_code,
        rtr_vendor_name,
        rtr_merch_store_num,
        tf_pin_status_code,
        tf_trans_date,
        tf_extract_flag,
        tf_extract_date,
        tf_site_id,
        rtr_trans_type,
        rtr_remote_trans_id,
        tf_sourcesystem,
        rtr_merch_reg_num,
        tf_upc,
        tf_min,
        rtr_merch_store_name,
        rtr_esn
      )
      VALUES
      (
        sa.sequ_x_rtr_trans.NEXTVAL,
        rtr_trans_rec.tf_part_num_parent,
        rtr_trans_rec.tf_serial_num,
        rtr_trans_rec.tf_red_code,
        NVL(p_rtr_vendor_name, rtr_trans_rec.rtr_vendor_name),        --RTR_VENDOR_NAME    VARCHAR2(100 BYTE),
        rtr_trans_rec.rtr_merch_store_num, --RTR_MERCH_STORE_NUM    VARCHAR2(100 BYTE),
        '44', -- 'REDEEMED', changed pin status from REDEEMED to 44 as suggested by Asim --45278
        sysdate,
        'N',
        NULL,
        rtr_trans_rec.tf_site_id,
        'REMOVE-DEACT', --RTR_TRANS_TYPE     VARCHAR2(40 BYTE),
        NVL(p_cancel_rtr_remote_trans_id,p_add_rtr_remote_trans_id
        ||'C'), --RTR_REMOTE_TRANS_ID      VARCHAR2(20 BYTE),
        'SYSTEM',
        rtr_trans_rec.rtr_merch_reg_num,    --RTR REG_NO             VARCHAR2(30 BYTE),
        rtr_trans_rec.tf_upc, --TF_UPC                 VARCHAR2(30 BYTE)
        rtr_trans_rec.tf_min, --TF_MIN                 VARCHAR2(30 BYTE))
        rtr_trans_rec.rtr_merch_store_name,
        rtr_trans_rec.rtr_esn
      );

    p_trans_id := sa.sequ_x_rtr_trans.CURRVAL; --45278

    dbms_output.put_line('37 '||p_trans_id);

    p_error_code := 0;

    COMMIT;

  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
   dbms_output.put_line('38');
    p_error_code    :=99;
    p_error_message := 'EXCEPTION CANCEL REACTIVATION';
    RETURN;
  END cancel_reactivation;----END -CR33105
--
  PROCEDURE p_get_source_dest_sp_group (p_esn          IN  VARCHAR2,
                                        p_partnumber   IN  VARCHAR2,
                                        op_src_sp_grp  OUT VARCHAR2,
                                        op_dest_sp_grp OUT VARCHAR2,
                                        op_err_num     OUT NUMBER,
                                        op_err_msg     OUT VARCHAR2) AS

  --CR47757 - SafeLink Unlimited In RTR
  v_esn_sp_rec  x_service_plan%rowtype;
  v_src_sp_grp  x_serviceplanfeaturevalue_def.value_name%TYPE;
  v_dest_sp_grp x_serviceplanfeaturevalue_def.value_name%TYPE;
  l_sp_objid    NUMBER;

  CURSOR brand_curs(c_esn IN VARCHAR2) IS
   SELECT bo.org_id,
          bo.objid bus_org_objid,
          pn.objid esn_pn_objid
   FROM   table_part_inst pi,
          table_mod_level ml,
          table_part_num  pn,
          table_bus_org   bo
   WHERE  pi.part_serial_no = c_esn
   AND    ml.objid          = n_part_inst2part_mod
   AND    pn.objid          = ml.part_info2part_num
   AND    bo.objid          = pn.part_num2bus_org;

   brand_rec brand_curs%rowtype;

  BEGIN

  IF p_esn IS NULL OR p_partnumber IS NULL THEN --{
    op_err_num := 54;
    op_err_msg := 'ESN/PARTNUMBER Cannot be NULL';
    RETURN;
  END IF; --}

  v_esn_sp_rec := service_plan.get_service_plan_by_esn(p_esn);

  dbms_output.put_line('service_plan_id ' || v_esn_sp_rec.objid);
  --CR48315 
  OPEN brand_curs(p_esn);
  FETCH brand_curs INTO brand_rec;

    IF brand_curs%found THEN

    dbms_output.put_line('Org Id : '||brand_rec.org_id);
    IF brand_rec.org_id = 'TRACFONE' THEN
      --CR48315 
      v_src_sp_grp  := sa.get_serv_plan_value(v_esn_sp_rec.objid, 'SERVICE_PLAN_GROUP');

      IF v_src_sp_grp <> 'TFSL_UNLIMITED' THEN --{
        v_src_sp_grp := 'TF_DEFAULT';
      END IF; --}

      BEGIN --{
        SELECT DISTINCT DECODE(sa.get_serv_plan_value(sp_objid, 'SERVICE_PLAN_GROUP'), 'TFSL_UNLIMITED', 'TFSL_UNLIMITED', 'TF_DEFAULT')
        INTO   v_dest_sp_grp
        FROM   adfcrm_serv_plan_class_matview mv,
             table_part_num pn
        WHERE  part_num2part_class   = part_class_objid
        AND    pn.part_number        = p_partnumber;

      EXCEPTION
       WHEN OTHERS THEN
         v_dest_sp_grp := 'TF_DEFAULT';
         dbms_output.put_line('EXCEPTION v_dest_sp_grp: ' || v_dest_sp_grp);
      END; --}

      -- CR48315 
    ELSIF brand_rec.org_id = 'NET10' THEN

      BEGIN --{

      SELECT DISTINCT DECODE(sa.get_serv_plan_value(sp_objid, 'SERVICE_PLAN_GROUP'), 'SL DATA', 'NTSL_DATA_ONLY', 'NTSL_DEFAULT')
      INTO   v_dest_sp_grp
      FROM   adfcrm_serv_plan_class_matview mv,
          table_part_num pn
      WHERE  part_num2part_class   = part_class_objid
      AND    pn.part_number        = p_partnumber;

      EXCEPTION
        WHEN OTHERS THEN
          v_dest_sp_grp := 'NTSL_DEFAULT';
          dbms_output.put_line('EXCEPTION v_dest_sp_grp: ' || v_dest_sp_grp);
      END; --}
    END IF;

  END IF;

  CLOSE brand_curs;

  -- CR48315 
  dbms_output.put_line('v_src_sp_grp:  ' || v_src_sp_grp);
  dbms_output.put_line('v_dest_sp_grp: ' || v_dest_sp_grp);

  op_src_sp_grp  := v_src_sp_grp;
  op_dest_sp_grp := v_dest_sp_grp;
  op_err_num     := 0;
  op_err_msg     := 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN
      op_err_num := 53;
      op_err_msg := 'UNHANDLED EXCEPTION: ' || sqlerrm;
  END p_get_source_dest_sp_group;
--
  FUNCTION is_safelink (p_esn IN VARCHAR2,
                        p_min IN VARCHAR2)
  RETURN VARCHAR2 IS

   l_is_safelink VARCHAR2(2) := 'N'; --CR47757

  BEGIN --{

  SELECT  DECODE(COUNT(*),0,'N','Y')
  INTO    l_is_safelink
  FROM    sa.x_sl_currentvals   cur,
         sa.table_site_part    tsp,
         sa.x_program_enrolled pe,
         sa.x_program_parameters xpp,
         sa.table_bus_org tbo
  WHERE   tsp.x_service_id         = pe.x_esn
  AND     tsp.x_service_id         = cur.x_current_esn
  AND     (
         cur.x_current_esn = p_esn
         OR
         tsp.x_min = p_min
        )
  AND     (
           (pe.x_enrollment_status = 'ENROLLED')
           OR
           --(tbo.org_id = 'NET10' AND pe.x_enrollment_status   IN ('READYTOREENROLL', 'DEENROLLED') AND SYSDATE  - (X_UPDATE_STAMP) < 31) -- commented as part of CR48315 
           --OR
           (tbo.org_id = 'TRACFONE' AND pe.x_enrollment_status   IN ('READYTOREENROLL', 'DEENROLLED'))
         )
  AND     UPPER(tsp.part_status)   = 'ACTIVE'
  AND     xpp.x_prog_class         = 'LIFELINE'
  AND     pgm_enroll2pgm_parameter = xpp.objid
  AND     tbo.objid                = xpp.prog_param2bus_org
  AND     ROWNUM = 1;

  RETURN l_is_safelink;

  EXCEPTION
    WHEN OTHERS THEN
      l_is_safelink := 'N';
      RETURN l_is_safelink;
  END is_safelink; --}
--
  PROCEDURE get_add_res_cnt (p_esn     IN  VARCHAR2,
                             p_red_cnt OUT NUMBER,
                             p_res_cnt OUT NUMBER) IS
  --CR48315 
  v_redeemed_cnt NUMBER := 0;
  v_reserve_cnt  NUMBER := 0;

  BEGIN --{

   SELECT COUNT(1)
   INTO v_redeemed_cnt
   FROM table_x_call_trans ct,
        table_x_red_card rc,
        table_part_inst pi,
        table_site_part sp,
        table_mod_level ml,
        table_part_num pn,
        adfcrm_serv_plan_class_matview x
  WHERE rc.red_card2call_trans   = ct.objid
    AND pi.part_serial_no        = p_esn
    AND pi.x_part_inst2site_part = sp.objid
    AND ct.call_trans2site_part  = sp.objid
    AND ml.objid                 = rc.x_red_card2part_mod
    AND pn.objid                 = ml.part_info2part_num
    AND pn.part_num2part_class   = x.part_class_objid
    AND TRUNC(sp.warranty_date) >= TRUNC(sysdate)
    AND sa.get_serv_plan_value(x.sp_objid, 'SERVICE_PLAN_GROUP') = 'SL DATA'
    AND x_action_type            = '6' ;
  --
  IF v_redeemed_cnt = 1 THEN
  SELECT COUNT(1)
    INTO v_reserve_cnt
   FROM table_part_inst pi,
        table_part_inst rd,
        table_site_part sp,
        table_mod_level ml,
        table_part_num pn,
        adfcrm_serv_plan_class_matview x
  WHERE pi.part_serial_no        = p_esn
    AND rd.part_to_esn2part_inst = pi.objid
    AND rd.x_domain              = 'REDEMPTION CARDS'
    AND rd.x_part_inst_status    IN ('40','400')
    AND ml.objid                 = rd.n_part_inst2part_mod
    AND pi.x_part_inst2site_part = sp.objid
    AND pn.objid                 = ml.part_info2part_num
    AND pn.part_num2part_class   = x.part_class_objid
    AND sa.get_serv_plan_value(x.sp_objid, 'SERVICE_PLAN_GROUP') = 'SL DATA';
  END IF;

  p_red_cnt := v_redeemed_cnt;
  p_res_cnt := v_reserve_cnt;

  dbms_output.put_line('p_red_cnt: ' || p_red_cnt);
  dbms_output.put_line('p_res_cnt: ' || p_res_cnt);

  EXCEPTION
    WHEN OTHERS THEN
      p_red_cnt :=  0;
      p_res_cnt :=  0;
      dbms_output.put_line('In Exception get_add_res_cnt: ' || sqlerrm);
  END get_add_res_cnt; --}
--
END rtr_pkg;
/