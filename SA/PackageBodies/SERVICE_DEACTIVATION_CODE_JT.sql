CREATE OR REPLACE PACKAGE BODY sa.SERVICE_DEACTIVATION_CODE_jt AS
 --------------------------------------------------------------------------------------------
 --$RCSfile: SERVICE_DEACTIVATION_CODE_jt.sql,v $
  --$Revision: 1.125 $
  --$Author: mshah $
  --$Date: 2018/05/22 14:39:02 $
  --$ $Log: SERVICE_DEACTIVATION_CODE_jt.sql,v $
  --$ Revision 1.125  2018/05/22 14:39:02  mshah
  --$ CR57185 TMO AND VERIZON SIM EXPIRATION RULE
  --$
  --$ Revision 1.123  2018/05/11 16:34:46  mdave
  --$ Merged with CR52412
  --$
  --$ Revision 1.109  2018/04/24 15:11:54  oimana
  --$ CR52412 - Package Body
  --$
  --$ Revision 1.98  2017/12/06 22:33:35  smeganathan
  --$ Added x_domain condition while retrieving data from table_part_inst
  --$
  --$ Revision 1.97  2017/11/24 23:08:02  sinturi
  --$ Merged with Jeny code
  --$
  --$ Revision 1.96  2017/11/16 22:43:29  jcheruvathoor
  --$ CR54668  Deact ServiceChange Default to Suspend
  --$
  --$ Revision 1.95  2017/11/08 21:48:14  jcheruvathoor
  --$ CR54668  Deact ServiceChange Default to Suspend
  --$
  --$ Revision 1.92  2017/06/29 14:20:24  nsurapaneni
  --$ Correct action item logic for WFM brm notifications via POJO (SERVICE_DEACTIVATION_CODE_jt).
  --$
  --$ Revision 1.91  2017/04/24 15:21:07  spokala
  --$ CR48810
  --$
  --$ Revision 1.90  2017/03/24 21:39:01  aganesan
  --$ CR47564 Deactivation failure reason condition modified
  --$
  --$ Revision 1.89  2017/03/16 21:10:55  aganesan
  --$ CR47564 enqueue deactivation procedure error handling modified
  --$
  --$ Revision 1.87  2017/03/15 01:10:54  aganesan
  --$ CR47564 -  enqueue deactivation procedure called to notify BRM for deactivations
  --$
  --$ Revision 1.84  2016/05/09 13:58:28  jpena
  --$ Modifications for upgrade fixes.
  --$
  --$ Revision 1.79  2016/03/15 22:32:03  rpednekar
  --$ CR37046 - Changes done in procedure deactservice.
  --$
  --$ Revision 1.78  2016/03/15 16:38:48  rpednekar
  --$ CR37046 - Merging and removed deact reason check.
  --$
  --$ Revision 1.75  2016/03/09 17:49:44  nmuthukkaruppan
  --$ This is same as ver 1.70 -  to Rollback the changes that are done for 2G Migration project.
  --$
  --$ Revision 1.70  2016/01/15 19:47:23  smeganathan
  --$ CR39389 changes for TW plus
  --$
  --$ Revision 1.69  2015/10/27 19:28:10  mmunoz
  --$  CR38664  Merge 1.67 and 1.68
  --$
  --$ Revision 1.68  2015/10/22 09:03:22  pvenkata
  --$ CR37951
  --$
  --$ Revision 1.66  2015/08/07 18:11:59  jarza
  --$ CR34962
  --$
  --$ Revision 1.64  2015/07/21 16:24:35  vsugavanam
  --$ CR33199: Srini: Modified expired CDMA SIMS procedure
  --$
  --$ Revision 1.62  2015/06/24 15:56:47  kparkhi
  --$ CR35398 - Super carrier changes for 06/25
  --$
  --$ Revision 1.61  2015/05/12 20:23:21  aganesan
  --$ CR29586 - Super Carrier Changes
  --$
  --$ Revision 1.60  2015/02/13 17:40:41  jpena
  --$ Added Logic by Juda Pena to validate when there is a queued pin as the master of the account group (only for brand x) in the deactivate_past_due stored procedure.
  --$
  --$ Revision 1.60  2015/02/09 22:33:53  jpena
  --$ CR32463 - Brand X Changes
  --$
  --------------------------------------------------------------------------------------------

  v_package_name VARCHAR2(80) := '.SERVICE_DEACTIVATION()';
  --
  CURSOR check_esn_curs (c_esn IN VARCHAR2) IS
    SELECT 1
      FROM sa.table_site_part sp2
     WHERE 1 = 1
       AND NVL(sp2.part_status,'Obsolete') IN('CarrierPending','Active')
       AND sp2.x_service_id = c_esn
       AND NVL(sp2.x_expire_dt,TO_DATE('1753-01-01 00:00:00' ,'yyyy-mm-dd hh24:mi:ss')) > TRUNC(SYSDATE);

  check_esn_rec check_esn_curs%ROWTYPE;

  /*********************************************************************************
   CR38664  cursor used in function get_deact_line_status and procedure deactservice
  ***********************************************************************************/
    CURSOR cur_min (ip_min IN VARCHAR2,
                    c_tech IN VARCHAR2,
                    ip_deactreason in varchar2) IS
      SELECT pi.objid
            ,pi.part_serial_no
            ,pi.part_inst2carrier_mkt
            ,NVL(pi.x_port_in ,0) x_port_in
            ,pi.x_part_inst_status
            ,pi.x_npa
            ,pi.x_nxx
            ,pi.x_ext
            ,pi.rowid min_rowid
            ,pi.status2x_code_table
            ,pi.x_cool_end_date
            ,pi.warr_end_date
            ,pi.last_trans_time
            ,pi.repair_date
            ,pi.part_inst2x_pers
            ,pi.part_inst2x_new_pers
            ,pi.part_to_esn2part_inst
            ,pi.last_cycle_ct
            ,p.x_parent_id
            ,cr.x_line_return_days
            ,cr.x_cooling_period
            ,cr.x_used_line_expire_days
            ,cr.x_gsm_grace_period
            ,cr.x_reserve_on_suspend
            ,cr.x_reserve_period
            ,cr.x_deac_after_grace
            ,cr.x_block_create_act_item
            ,cr.x_cancel_suspend_days--cwl 2/10/2011 CR15335
            ,cr.x_cancel_suspend
            ,
             --cwl 2/10/2011 CR15335
             (SELECT COUNT(1)
                FROM sa.table_x_block_deact
               WHERE x_block_active = 1
                 AND x_parent_id = p.x_parent_id
                 AND UPPER(x_code_name) = UPPER(ip_deactreason)
                 AND ROWNUM < 2) block_deact_exists
        FROM sa.table_x_parent        p
            ,sa.table_x_carrier_group cg
            ,sa.table_x_carrier_rules cr
            ,sa.table_x_carrier       c
            ,sa.table_part_inst       pi
       WHERE 1 = 1
         AND p.objid = cg.x_carrier_group2x_parent
         AND cg.objid = c.carrier2carrier_group
         AND cr.objid = DECODE(c_tech
                              ,'GSM'
                              ,c.carrier2rules_gsm
                              ,'CDMA'
                              ,c.carrier2rules_cdma
                              ,c.carrier2rules)
         AND c.objid = pi.part_inst2carrier_mkt
         AND pi.part_serial_no = ip_min
         AND pi.x_domain = 'LINES';
--
--
  /********************************************************************************/
  /*
  /* Name:         create_vas_ild_trans
  /* Description:  Insert into sa.table_x_ild_transaction for those VAS (Add-on)
  /*               for $10 ILD enrollments when deactivating ESN - CR52412
  /*               04/18/2018 - OImana
  /********************************************************************************/
  PROCEDURE create_vas_ild_trans (ip_brm_enrolled_flag   IN  VARCHAR2,
                                  ip_esn                 IN  VARCHAR2,
                                  ip_min                 IN  VARCHAR2,
                                  ip_site_part_objid     IN  NUMBER,
                                  ip_org_id              IN  VARCHAR2,
                                  ip_call_trans_objid    IN  NUMBER,
                                  ip_user_objid          IN  VARCHAR2,
                                  op_ild_trans_objid     OUT NUMBER,
                                  op_pgm_enroll_objid    OUT NUMBER,
                                  op_resp_code           OUT VARCHAR2,
                                  op_resp_msg            OUT VARCHAR2) IS

   -- CR52412 - Adding insert to ILD Trans for deactivation - 10 Dollar Auto-Refill ILD
   -- CR52412 - Ensure there is VAS add-on service enrolled for 10 Dollar Auto-Refill ILD.
   -- CR52412 - Insert for all brands except WFM and all deact reasons.
   -- CR52412 - If SOA ip_brm_enrolled_flag input parameter is Y then all branded ORG will be picked up including WFM.
   -- CR52412 - BRM checks enrollment for some brands therefore the ILD validation needs to be skipped for those.
   -- CR52412 - The CR calls for $10 ILD validation only along with brand flag brm_notification_flag.
   -- CR52412 - Process must exclude ESN with GO_SMART sub-brand.

    CURSOR vas_ild_cur (c_brm_enrolled_flag VARCHAR2,
                        c_esn               VARCHAR2,
                        c_site_part_objid   NUMBER,
                        c_org_id            VARCHAR2) IS
      SELECT 'BP'||ve.product_id product_id,
             ve.pgm_enroll_objid
        FROM sa.table_bus_org bo,
             (SELECT MAX(vp.vas_bus_org) vas_bus_org,
                     MAX(vp.product_id) product_id,
                     MAX(pe.objid) pgm_enroll_objid
                FROM sa.x_program_enrolled   pe,
                     sa.x_program_parameters pp,
                     sa.vas_programs_view    vp
               WHERE vp.vas_bus_org          = c_org_id
                 AND vp.vas_product_type     = 'APP'
                 AND vp.vas_category         = 'ILD_REUP'
                 AND vp.vas_group_name       = '$10 ILD'
                 AND pp.objid                = vp.program_parameters_objid
                 AND EXISTS (SELECT NULL
                               FROM sa.x_vas_subscriptions vs
                              WHERE vs.vas_esn = pe.x_esn
                                AND vs.vas_id  = vp.vas_service_id
                                AND vs.vas_is_active = 'T')
                 AND pp.x_prog_class         = 'LOWBALANCE'
                 AND pp.objid                = pe.pgm_enroll2pgm_parameter
                 AND pe.x_enrollment_status  = 'ENROLLED'
                 AND pe.pgm_enroll2site_part = c_site_part_objid
                 AND pe.x_esn                = c_esn
                 AND 'N'                     = c_brm_enrolled_flag) ve
       WHERE ve.vas_bus_org = bo.org_id
         AND NVL(bo.brm_notification_flag,'N') = 'N'
         AND bo.org_id = c_org_id
      UNION ALL
      SELECT 'BP'||TRIM(bo.loc_type)||'_ILD_10' product_id,
             NULL pgm_enroll_objid
        FROM sa.table_bus_org bo
       WHERE NVL(bo.brm_notification_flag,'N') = 'Y'
         AND c_brm_enrolled_flag               = 'Y' -- CR52412
         AND bo.org_id = c_org_id;

    l_brm_enrolled_flag  VARCHAR2(1);
    l_gs_count           NUMBER := 0;
    vas_ild_rec          vas_ild_cur%ROWTYPE;
    PRAGMA               AUTONOMOUS_TRANSACTION;

  BEGIN

   op_ild_trans_objid  := NULL;
   op_pgm_enroll_objid := NULL;
   op_resp_code        := '0';
   op_resp_msg         := 'SUCCESS';
   l_brm_enrolled_flag := NVL(TRIM(ip_brm_enrolled_flag),'N');

   OPEN vas_ild_cur (l_brm_enrolled_flag,
                     ip_esn,
                     ip_site_part_objid,
                     ip_org_id);
   FETCH vas_ild_cur INTO vas_ild_rec;

   IF vas_ild_cur%NOTFOUND THEN
     op_resp_code := '1';
     op_resp_msg  := 'No Brand information available for VAS $10 ILD enrollment for: '||ip_esn||' - '||ip_org_id||' - '||ip_brm_enrolled_flag;
     CLOSE vas_ild_cur;
     RETURN;
   END IF;

   CLOSE vas_ild_cur;

   -- CR52412 - Exclude Go_Smart
   BEGIN
     SELECT COUNT(1)
       INTO l_gs_count
       FROM table_part_inst pi,
            sa.table_mod_level ml,
            sa.table_part_num pn,
            sa.pcpv_mv pcpv
      WHERE pcpv.sub_brand = 'GO_SMART'
        AND pn.domain = 'PHONES'
        AND pcpv.pc_objid = pn.part_num2part_class
        AND pn.objid = ml.part_info2part_num
        AND ml.objid = pi.n_part_inst2part_mod
        AND pi.x_domain = 'PHONES'
        AND pi.part_serial_no = ip_esn;
   EXCEPTION
     WHEN OTHERS THEN
       l_gs_count := 0;
   END;

   IF ((ip_min IS NOT NULL) OR (ip_call_trans_objid IS NOT NULL) OR (ip_user_objid IS NOT NULL)) AND (l_gs_count = 0) THEN

     BEGIN

       SELECT sa.seq('x_ild_transaction')
         INTO op_ild_trans_objid
         FROM dual;

       INSERT INTO sa.table_x_ild_transaction (objid
                                              ,x_min
                                              ,x_esn
                                              ,x_transact_date
                                              ,x_last_update
                                              ,x_ild_trans_type
                                              ,x_ild_status
                                              ,x_ild_account
                                              ,ild_trans2site_part
                                              ,x_conv_rate
                                              ,x_product_id
                                              ,x_ild_trans2call_trans
                                              ,web_user_objid)
                                       VALUES (op_ild_trans_objid
                                              ,ip_min
                                              ,ip_esn
                                              ,sysdate
                                              ,sysdate
                                              ,'S'
                                              ,'PENDING'
                                              ,'1'
                                              ,ip_site_part_objid
                                              ,1
                                              ,vas_ild_rec.product_id
                                              ,ip_call_trans_objid
                                              ,ip_user_objid);

     EXCEPTION
       WHEN OTHERS THEN
         ROLLBACK;
         op_ild_trans_objid := NULL;
         op_resp_code := '2';
         op_resp_msg  := 'Error while inserting sa.table_x_ild_transaction for ESN: '||ip_esn||' - '||SUBSTR(SQLERRM,1,500);
         RETURN;
     END;

   ELSE

     op_resp_code := '3';
     op_resp_msg  := 'Input Values for MIN, call_trans_objid or user_id are missing for esn: '||ip_esn;
     RETURN;

   END IF;

   op_pgm_enroll_objid := vas_ild_rec.pgm_enroll_objid;

   COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      op_ild_trans_objid := NULL;
      op_resp_code := '4';
      op_resp_msg  := 'Error while executing create_vas_ild_trans: '||ip_esn||' - '||ip_brm_enrolled_flag||' - '||SUBSTR(SQLERRM,1,500);
  END create_vas_ild_trans;
--
--
  /********************************************************************************/
  /*
  /* Name:         create_call_trans
  /* Description:  Available in the specification part of package
  /*               insert code_number to x_sub_sourcesystem instead of code_name
  /*               07/05/2002 by SL, -- 07/07/2004 GP
  /********************************************************************************/
  PROCEDURE create_call_trans (ip_site_part   IN  NUMBER
                              ,ip_action      IN  NUMBER
                              ,ip_carrier     IN  NUMBER
                              ,ip_dealer      IN  NUMBER
                              ,ip_user        IN  NUMBER
                              ,ip_min         IN  VARCHAR2
                              ,ip_phone       IN  VARCHAR2
                              ,ip_source      IN  VARCHAR2
                              ,ip_transdate   IN  DATE
                              ,ip_units       IN  NUMBER
                              ,ip_action_text IN  VARCHAR2
                              ,ip_reason      IN  VARCHAR2
                              ,ip_result      IN  VARCHAR2
                              ,ip_iccid       IN  VARCHAR2
                              ,ip_brand_name  IN  VARCHAR2
                              ,op_calltranobj OUT NUMBER) IS

    v_ct_seq NUMBER;

  BEGIN

    SELECT sequ_x_call_trans.nextval
      INTO v_ct_seq
      FROM dual;   --CR12136

    op_calltranobj := v_ct_seq;

    INSERT INTO sa.table_x_call_trans (objid
                                      ,call_trans2site_part
                                      ,x_action_type
                                      ,x_call_trans2carrier
                                      ,x_call_trans2dealer
                                      ,x_call_trans2user
                                      ,x_min
                                      ,x_service_id
                                      ,x_sourcesystem
                                      ,x_transact_date
                                      ,x_total_units
                                      ,x_action_text
                                      ,x_reason
                                      ,x_result
                                      ,x_sub_sourcesystem
                                      ,x_iccid)
                               VALUES (v_ct_seq
                                      ,ip_site_part
                                      ,ip_action
                                      ,ip_carrier
                                      ,ip_dealer
                                      ,ip_user
                                      ,ip_min
                                      ,ip_phone
                                      ,ip_source
                                      ,ip_transdate
                                      ,ip_units
                                      ,ip_action_text
                                      ,ip_reason
                                      ,ip_result
                                      ,ip_brand_name
                                      ,ip_iccid);

  END create_call_trans;
--
--
  /***************************************************/
  /* Name: write_to_monitor
  /* Description : Writes into monitor table
  /*
  /****************************************************/
  PROCEDURE write_to_monitor
  (
    site_part_objid IN NUMBER
   ,cust_site_objid IN NUMBER
   ,x_carrier_id    IN NUMBER
   ,site_part_msid  IN VARCHAR2
  ) IS

    --retrieve the deactivated site part
    CURSOR c1 IS
      SELECT *
        FROM table_site_part
       WHERE objid = site_part_objid;
    c1_rec c1%ROWTYPE;
    CURSOR c2(cust_site_objid_ip IN NUMBER) IS
      SELECT site_id
        FROM table_site
       WHERE objid = cust_site_objid_ip
         AND ROWNUM = 1;
    c2_rec c2%ROWTYPE;
    --retrieve the dealer_id for the site part
    CURSOR c3(sp_esn IN VARCHAR2) IS
      SELECT s.site_id site_id
        FROM table_site       s
            ,table_inv_role   ir
            ,table_inv_locatn il
            ,table_inv_bin    ib
            ,table_part_inst  pi
       WHERE s.objid = ir.inv_role2site
         AND ir.inv_role2inv_locatn = il.objid
         AND il.objid = ib.inv_bin2inv_locatn
         AND ib.objid = pi.part_inst2inv_bin
         AND pi.x_domain = 'PHONES'
         AND pi.part_serial_no = sp_esn
         AND ROWNUM = 1;
    c3_rec c3%ROWTYPE;
    CURSOR c4(ml_objid IN NUMBER) IS
      SELECT pn.x_manufacturer x_manufacturer
        FROM table_part_num  pn
            ,table_mod_level ml
       WHERE pn.objid = ml.part_info2part_num
         AND ml.objid = ml_objid;
    c4_rec c4%ROWTYPE;
    CURSOR c5(site_objid IN NUMBER) IS
      SELECT c.last_name || ', ' || c.first_name NAME
        FROM table_contact      c
            ,table_contact_role cr
       WHERE c.objid = cr.contact_role2contact
         AND cr.contact_role2site = site_objid
         AND ROWNUM = 1;
    c5_rec                   c5%ROWTYPE;
    v_new_site_objid         NUMBER;
    v_new_site_id            NUMBER;
    v_new_address_objid      NUMBER;
    v_new_contact_objid      NUMBER;
    v_new_contact_role_objid NUMBER;
    v_cust_site_objid        NUMBER;
    --EME to remove table_num_scheme ref
    new_site_id_format VARCHAR2(100) := NULL;
    --End EME
  BEGIN
    v_cust_site_objid := cust_site_objid;
    OPEN c1;
    FETCH c1
      INTO c1_rec;
    CLOSE c1;
    OPEN c5(c1_rec.site_part2site);
    FETCH c5
      INTO c5_rec;
    IF c5%NOTFOUND THEN
      CLOSE c5;
      /** get all the sequences **/
      --Sp_Seq ('address', v_new_address_objid); -- 06/09/03
      SELECT sequ_address.nextval
        INTO v_new_address_objid
        FROM dual; -- cr12136
      -- Sp_Seq ('new_site', v_new_site_objid); -- 06/09/03
      SELECT sequ_site.nextval
        INTO v_new_site_objid
        FROM dual; -- cr12136

      SELECT next_value
        INTO v_new_site_id
        FROM table_num_scheme
       WHERE NAME = 'Individual ID';
      UPDATE table_num_scheme
         SET next_value = next_value + 1
       WHERE NAME = 'Individual ID';
      --Sp_Seq ('new_contact', v_new_contact_objid); -- 06/09/03
      SELECT sequ_contact.nextval
        INTO v_new_contact_objid
        FROM dual; -- CR12136
      --Sp_Seq ('new_contact_role', v_new_contact_role_objid); -- 06/09/03
      SELECT sequ_contact_role.nextval
        INTO v_new_contact_role_objid
        FROM dual; -- CR12136
      /** insert into the address table */
      INSERT INTO table_address
        (objid
        ,address
        ,s_address
        ,city
        ,s_city
        ,state
        ,s_state
        ,zipcode
        ,address_2
        ,dev
        ,address2time_zone
        ,address2country
        ,address2state_prov
        ,update_stamp)
      VALUES
        (v_new_address_objid
        ,'No Address Provided'
        ,'NO ADDRESS PROVIDED'
        ,'No City Provided'
        ,'NO CITY PROVIDED'
        ,'FL'
        ,'FL'
        ,'33122'
        ,NULL
        ,NULL
        ,268435561
        ,268435457
        ,268435466
        ,SYSDATE);
      /** create a table_site dummy record **/
      INSERT INTO table_site
        (objid
        ,site_id
        ,NAME
        ,s_name
        ,external_id
        ,TYPE
        ,logistics_type
        ,is_support
        ,region
        ,s_region
        ,district
        ,s_district
        ,depot
        ,contr_login
        ,contr_passwd
        ,is_default
        ,notes
        ,spec_consid
        ,mdbk
        ,state_code
        ,state_value
        ,industry_type
        ,appl_type
        ,cut_date
        ,site_type
        ,status
        ,arch_ind
        ,alert_ind
        ,phone
        ,fax
        ,dev
        ,child_site2site
        ,support_office2site
        ,cust_primaddr2address
        ,cust_billaddr2address
        ,cust_shipaddr2address
        ,site_support2employee
        ,site_altsupp2employee
        ,report_site2bug
        ,primary2bus_org
        ,site2exch_protocol
        ,dealer2x_promotion
        ,x_smp_optional
        ,update_stamp
        ,x_fin_cust_id)
      VALUES
        (v_new_site_objid
        ,'IND' || TO_CHAR(v_new_site_id)
        ,'No Address Provided'
        ,'NO ADDRESS PROVIDED'
        ,NULL
        ,4
        ,0
        ,0
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,0
        ,NULL
        ,0
        ,NULL
        ,0
        ,NULL
        ,NULL
        ,NULL
        ,TO_DATE('01-JAN-1753')
        ,'INDV'
        ,0
        ,0
        ,0
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,v_new_address_objid
        , --need to update
         NULL
        ,v_new_address_objid
        , --need to update
         NULL
        ,NULL
        ,NULL
        ,-2
        ,NULL
        ,NULL
        ,0
        ,SYSDATE
        ,NULL);
      /** create a table_contact_role record **/
      INSERT INTO table_contact_role
        (objid
        ,role_name
        ,s_role_name
        ,primary_site
        ,dev
        ,contact_role2site
        ,contact_role2contact
        ,contact_role2gbst_elm
        ,update_stamp)
      VALUES
        (v_new_contact_role_objid
        ,NULL
        ,NULL
        ,1
        ,NULL
        ,v_new_site_objid
        ,v_new_contact_objid
        ,NULL
        ,SYSDATE);
      /** create a table_contact record **/
      INSERT INTO table_contact
        (objid
        ,first_name
        ,s_first_name
        ,last_name
        ,s_last_name
        ,phone
        ,fax_number
        ,e_mail
        ,mail_stop
        ,expertise_lev
        ,title
        ,hours
        ,salutation
        ,mdbk
        ,state_code
        ,state_value
        ,address_1
        ,address_2
        ,city
        ,state
        ,zipcode
        ,country
        ,status
        ,arch_ind
        ,alert_ind
        ,dev
        ,caller2user
        ,contact2x_carrier
        ,x_cust_id
        ,x_dateofbirth
        ,x_gender
        ,x_middle_initial
        ,x_mobilenumber
        ,x_no_address_flag
        ,x_no_name_flag
        ,x_pagernumber
        ,x_ss_number
        ,x_no_phone_flag
        ,update_stamp
        ,x_new_esn
        ,x_email_status
        ,x_html_ok)
      VALUES
        (v_new_contact_objid
        ,v_new_site_id
        ,v_new_site_id
        ,v_new_site_id
        ,v_new_site_id
        ,v_new_site_id
        ,NULL
        ,NULL
        ,NULL
        ,0
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,0
        ,NULL
        ,'No Address Provided'
        ,NULL
        ,'No Address Provided'
        ,'FL'
        ,'33122'
        ,'USA'
        ,0
        ,0
        ,0
        ,NULL
        ,NULL
        ,NULL
        ,v_new_site_id
        ,TO_DATE('01-JAN-1753')
        ,NULL
        ,NULL
        ,NULL
        ,1
        ,1
        ,NULL
        ,NULL
        ,1
        ,SYSDATE
        ,NULL
        ,0
        ,0);
      --
      /** update table_site_part **/
      UPDATE table_site_part
         SET site_part2site     = v_new_site_objid
            ,all_site_part2site = v_new_site_objid
            ,dir_site_objid     = v_new_site_objid
            ,site_objid         = v_new_site_objid
       WHERE objid = site_part_objid;
      /** now reopen with updated data **/
      OPEN c1;
      FETCH c1
        INTO c1_rec;
      CLOSE c1;
      OPEN c5(c1_rec.site_part2site);
      FETCH c5
        INTO c5_rec;
      CLOSE c5;
      /** done reopnenning **/
      /** reassinging cust_site_objid **/
      v_cust_site_objid := v_new_site_objid;
    END IF;
    IF c5%ISOPEN THEN
      CLOSE c5;
    END IF;
    /** move this to avoid double openning of cursors **/
    OPEN c2(v_cust_site_objid);
    FETCH c2
      INTO c2_rec;
    CLOSE c2;
    OPEN c3(c1_rec.serial_no);
    FETCH c3
      INTO c3_rec;
    CLOSE c3;
    OPEN c4(c1_rec.site_part2part_info);
    FETCH c4
      INTO c4_rec;
    CLOSE c4;
    --cwl2.put_line('Adam','site_part_objid:'||to_char(site_part_objid));
    INSERT INTO x_monitor
      (x_monitor_id
      ,x_date_mvt
      ,x_phone
      ,x_esn
      ,x_cust_id
      ,x_carrier_id
      ,x_dealer_id
      ,x_action
      ,x_reason_code
      ,x_line_worked
      ,x_line_worked_by
      ,x_line_worked_date
      ,x_islocked
      ,x_locked_by
      ,x_action_type_id
      ,x_ig_status
      ,x_ig_error
      ,x_pin
      ,x_manufacturer
      ,x_initial_act_date
      ,x_end_user
      ,x_msid --Number Pooling 10/18/02
       )
    VALUES
      ((seq_x_monitor_id.nextval + (POWER(2
                                         ,28)))
      ,SYSDATE
      ,c1_rec.x_min
      ,c1_rec.serial_no
      ,c2_rec.site_id
      ,TO_CHAR(x_carrier_id)
      ,c3_rec.site_id
      ,DECODE(c1_rec.x_notify_carrier
             ,1
             ,'D'
             ,0
             ,'S')
      ,c1_rec.x_deact_reason
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,DECODE(c1_rec.x_notify_carrier
             ,1
             ,0
             ,0
             ,1)
      ,NULL
      ,NULL
      ,c1_rec.x_pin
      ,c4_rec.x_manufacturer
      ,c1_rec.install_date
      ,c5_rec.name
      ,site_part_msid --Number Pooling Changes 10/18/02
       );
    COMMIT;
  END write_to_monitor;
--
--
  /*******************************************************************************************/
  /* Name: sp_update_exp_date_prc
  /* Description: New Procedure added to extend the expire_dt - Modified by TCS offshore Team
  /*
  /*******************************************************************************************/
  PROCEDURE sp_update_exp_date_prc
  (
    p_esn        IN VARCHAR2
   ,p_grace_time IN DATE
   ,op_result    OUT NUMBER
   ,op_msg       OUT VARCHAR2
  ) IS
    v_partinstcount  NUMBER;
    v_procedure_name VARCHAR2(80) := v_package_name || '.SP_UPDATE_EXP_DATE_PRC()';
    CURSOR cur_ph_c(ip_esn VARCHAR2) IS
      SELECT *
        FROM table_part_inst
       WHERE x_part_inst_status = '52'
         AND part_serial_no = ip_esn
         AND x_domain = 'PHONES';
    rec_ph        cur_ph_c%ROWTYPE;
    v_pi_hist_seq NUMBER;

    -- 06/09/03
  BEGIN
    op_result := 0;
    op_msg    := 'Update Successful';
    --Begin Is Valid ESN
    SELECT COUNT(*)
      INTO v_partinstcount
      FROM table_part_inst
     WHERE part_serial_no = p_esn
       AND x_domain = 'PHONES';
    IF v_partinstcount = 0 THEN
      op_msg    := 'ERROR - Esn not found';
      op_result := 1;
      RETURN;
    END IF;
    --Begin Is Phone Active
    SELECT COUNT(*)
      INTO v_partinstcount
      FROM table_part_inst
     WHERE part_serial_no = p_esn
       AND x_domain = 'PHONES'
       AND x_part_inst_status = '52';
    IF v_partinstcount = 0 THEN
      op_msg    := 'ERROR - Active esn not found';
      op_result := 1;
      RETURN;
    END IF;
    --Begin Update
    BEGIN
      UPDATE table_site_part
         SET x_expire_dt = p_grace_time
       WHERE x_service_id = p_esn
         AND part_status || '' = 'Active';
    EXCEPTION
      WHEN others THEN
        op_result := 1;
        op_msg    := 'Error - E_UpdateFailed, RECORD UPDATE Failed.';
        toss_util_pkg.insert_error_tab_proc('Update Table_site_part'
                                           ,NVL(p_esn
                                               ,'N/A')
                                           ,v_procedure_name);
        RETURN;
    END;
    BEGIN
      OPEN cur_ph_c(p_esn);
      FETCH cur_ph_c
        INTO rec_ph;
      CLOSE cur_ph_c;
      UPDATE table_part_inst
         SET warr_end_date = p_grace_time
       WHERE part_serial_no = p_esn
         AND x_domain || '' = 'PHONES' -- CR12136
         AND x_part_inst_status || '' = '52'; -- CR12136
      --Sp_Seq ('x_pi_hist', v_pi_hist_seq);
      SELECT sequ_x_pi_hist.nextval
        INTO v_pi_hist_seq
        FROM dual; -- CR12136
      INSERT INTO table_x_pi_hist
        (objid
        ,status_hist2x_code_table
        ,x_change_date
        ,x_change_reason
        ,x_cool_end_date
        ,x_creation_date
        ,x_deactivation_flag
        ,x_domain
        ,x_ext
        ,x_insert_date
        ,x_npa
        ,x_nxx
        ,x_old_ext
        ,x_old_npa
        ,x_old_nxx
        ,x_part_bin
        ,x_part_inst_status
        ,x_part_mod
        ,x_part_serial_no
        ,x_part_status
        ,x_pi_hist2carrier_mkt
        ,x_pi_hist2inv_bin
        ,x_pi_hist2part_inst
        ,x_pi_hist2part_mod
        ,x_pi_hist2user
        ,x_pi_hist2x_new_pers
        ,x_pi_hist2x_pers
        ,x_po_num
        ,x_reactivation_flag
        ,x_red_code
        ,x_sequence
        ,x_warr_end_date
        ,dev
        ,fulfill_hist2demand_dtl
        ,part_to_esn_hist2part_inst
        ,x_bad_res_qty
        ,x_date_in_serv
        ,x_good_res_qty
        ,x_last_cycle_ct
        ,x_last_mod_time
        ,x_last_pi_date
        ,x_last_trans_time
        ,x_next_cycle_ct
        ,x_order_number
        ,x_part_bad_qty
        ,x_part_good_qty
        ,x_pi_tag_no
        ,x_pick_request
        ,x_repair_date
        ,x_transaction_id)
      VALUES
        (
         -- 04/10/03 seq_x_pi_hist.nextval + POWER (2, 28),
         -- seq('x_pi_hist'),
         v_pi_hist_seq
        ,rec_ph.status2x_code_table
        ,SYSDATE
        ,'PROTECTION PLAN BATCH'
        ,rec_ph.x_cool_end_date
        ,rec_ph.x_creation_date
        ,rec_ph.x_deactivation_flag
        ,rec_ph.x_domain
        ,rec_ph.x_ext
        ,rec_ph.x_insert_date
        ,rec_ph.x_npa
        ,rec_ph.x_nxx
        ,NULL
        ,NULL
        ,NULL
        ,rec_ph.part_bin
        ,'84'
        ,rec_ph.part_mod
        ,rec_ph.part_serial_no
        ,rec_ph.part_status
        ,rec_ph.part_inst2carrier_mkt
        ,rec_ph.part_inst2inv_bin
        ,rec_ph.objid
        ,rec_ph.n_part_inst2part_mod
        ,rec_ph.created_by2user
        ,rec_ph.part_inst2x_new_pers
        ,rec_ph.part_inst2x_pers
        ,rec_ph.x_po_num
        ,rec_ph.x_reactivation_flag
        ,rec_ph.x_red_code
        ,rec_ph.x_sequence
        ,rec_ph.warr_end_date
        ,rec_ph.dev
        ,rec_ph.fulfill2demand_dtl
        ,rec_ph.part_to_esn2part_inst
        ,rec_ph.bad_res_qty
        ,rec_ph.date_in_serv
        ,rec_ph.good_res_qty
        ,rec_ph.last_cycle_ct
        ,rec_ph.last_mod_time
        ,rec_ph.last_pi_date
        ,rec_ph.last_trans_time
        ,rec_ph.next_cycle_ct
        ,rec_ph.x_order_number
        ,rec_ph.part_bad_qty
        ,rec_ph.part_good_qty
        ,rec_ph.pi_tag_no
        ,rec_ph.pick_request
        ,rec_ph.repair_date
        ,rec_ph.transaction_id);
      -- Insert into table_pi_hist
    EXCEPTION
      WHEN others THEN
        op_result := 1;
        op_msg    := 'Error - E_UpdateFailed, RECORD UPDATE Failed.';
        toss_util_pkg.insert_error_tab_proc('UPDATE TABLE_PART_INST'
                                           ,NVL(p_esn
                                               ,'N/A')
                                           ,v_procedure_name);
        RETURN;
    END;
  END sp_update_exp_date_prc;
  /**********************************************************************************************/
  /* Name: check_dpp_registered_prc
  /* Description: New Procedure added to check whether the ESN is subscribed for Deactivation
  /* Protection Program - Modified by TCS offshore Team
  /*
  /**********************************************************************************************/
  PROCEDURE check_dpp_registered_prc
  (
    p_esn      IN VARCHAR2
   ,out_result OUT PLS_INTEGER
  ) IS
    --Get the record for the esn from table_x_autopay_details table
    CURSOR curgetdpp_c(ip_esn IN VARCHAR2) IS
      SELECT *
        FROM table_x_autopay_details
       WHERE x_end_date IS NULL
         AND x_esn = ip_esn
         AND x_program_type = 4
         AND x_status = 'A'
            --CR4077
            -- AND x_account_status = '3'
         AND x_account_status IN ('3'
                                 ,'5')
         AND (x_receive_status IS NULL OR x_receive_status = 'Y');
    curgetdpp_rec    curgetdpp_c%ROWTYPE;
    v_expire_dt      DATE;
    v_amount         NUMBER;
    op_result        NUMBER;
    op_msg           VARCHAR2(50);
    v_procedure_name VARCHAR2(80) := v_package_name || '.CHECK_DPP_REGISTERED_PRC()';
    dayval           VARCHAR2(30);
    ---for CR 1142
  BEGIN
    out_result := 0; -- default is false
    OPEN curgetdpp_c(p_esn);
    FETCH curgetdpp_c
      INTO curgetdpp_rec;
    IF curgetdpp_c%FOUND THEN

      -- extend the expire_dt and insert into send_ftp
      -- CR5168 03/31/06 Duggi/Icanavan
      -- An extra call to the database. Commented because of PEC check
      -- SELECT x_expire_dt
      -- INTO v_expire_dt
      -- FROM TABLE_SITE_PART
      -- WHERE x_service_id = p_esn AND part_status = 'Active';
      -- sp_update_exp_date_prc (p_esn, v_expire_dt + 10, op_result, op_msg);
      sp_update_exp_date_prc(p_esn
                            ,SYSDATE + 10
                            ,op_result
                            ,op_msg);
      IF op_result = 0 -- If the update_exp_date is O.K
       THEN
        v_amount := get_amount_fun(4);
        BEGIN

          --Insert into send_ftp_auto
          SELECT TRIM(TO_CHAR(SYSDATE
                             ,'DAY'))
            INTO dayval
            FROM dual; -- CR 1142
          INSERT INTO x_send_ftp_auto
            (send_seq_no
            ,file_type_ind
            ,esn
            ,debit_date
            ,program_type
            ,account_status
            ,amount_due)
          VALUES
            (seq_x_send_ftp_auto.nextval
            ,'D'
            ,p_esn
            ,DECODE(dayval
                   ,'FRIDAY'
                   ,SYSDATE + 3
                   ,'SATURDAY'
                   ,SYSDATE + 2
                   ,SYSDATE + 1)
            , -- CR 1142
             curgetdpp_rec.x_program_type
            ,'A'
            ,v_amount --from pricing table
             );
          out_result := 1;
        EXCEPTION
          WHEN others THEN
            toss_util_pkg.insert_error_tab_proc('INSERT INTO SEND_FTP_AUTO'
                                               ,NVL(p_esn
                                                   ,'N/A')
                                               ,v_procedure_name);
            out_result := 0;
            RETURN;
        END;
      END IF;
    ELSE

      --set the outparameter as false and return it
      out_result := 0;
    END IF;
    CLOSE curgetdpp_c;
  EXCEPTION
    WHEN others THEN
      out_result := 0;
      toss_util_pkg.insert_error_tab_proc('Error IN check_dpp_registered'
                                         ,NVL(p_esn
                                             ,'N/A')
                                         ,v_procedure_name);
      RETURN;
  END check_dpp_registered_prc;
  /*****************************************************************************/
  /* Name: get_amount_fun
  /* Description: New Procedure added to get the monthly fee for Deactivation
  /* Protection Program - Modified by TCS
  /*
  /******************************************************************************/
  FUNCTION get_amount_fun(p_prg_type NUMBER) RETURN NUMBER IS
    v_amount NUMBER := 7.99;
    err_no   NUMBER;
    v_function_name CONSTANT VARCHAR2(200) := v_package_name || '.get_amount()';
  BEGIN
    IF p_prg_type = 4 THEN
      SELECT x_retail_price
        INTO v_amount
        FROM table_x_pricing
       WHERE x_pricing2part_num = (SELECT objid
                                     FROM table_part_num
                                    WHERE part_number = 'APPDEACTMON');
    END IF;
    RETURN v_amount;
  EXCEPTION
    WHEN others THEN
      err_no := toss_util_pkg.insert_error_tab_fun('Failed retrieving Amount - Mnthly fee '
                                                  ,p_prg_type
                                                  ,v_function_name);
      RETURN v_amount;
  END get_amount_fun;
  /**********************************************************************************************/
  /* Name: remove_autopay_prc
  /* Description : New Procedure added to remove the ESN from Autopay promotions and
  /* unsubscribe from Autopay program - Modified by TCS offshore Team
  /*******************************************************************************************/
  -- BRAND_SEP
  PROCEDURE remove_autopay_prc
  (
    p_esn        IN VARCHAR2
   ,p_brand_name IN VARCHAR2
   ,out_success  OUT NUMBER
  ) IS
    v_prg_type       NUMBER;
    v_cycle_number   NUMBER;
    v_cust_name      VARCHAR2(45);
    v_procedure_name VARCHAR2(80) := v_package_name || '.REMOVE_AUTOPAY()';
    ------------------------------------------------------------
    CURSOR curautoinfo_c(c_esn VARCHAR2) IS
      SELECT *
        FROM table_x_autopay_details
       WHERE x_esn = c_esn
         AND x_status = 'A'
         AND (x_end_date IS NULL OR x_end_date = TO_DATE('01-jan-1753'
                                                        ,'dd-mon-yyyy'));
    curautoinfo_rec curautoinfo_c%ROWTYPE;
    ------------------------------------------------------------
    CURSOR part_inst_curs(c_esn IN VARCHAR2) IS
      SELECT x_part_inst_status
        FROM table_part_inst
       WHERE part_serial_no = c_esn
    AND   x_domain = 'PHONES';  -- CR55336
    part_inst_rec part_inst_curs%ROWTYPE;
    ------------------------------------------------------------
    CURSOR carrier_curs(c_min IN VARCHAR2) IS
      SELECT part_inst2carrier_mkt
        FROM table_part_inst
       WHERE part_serial_no = c_min
    AND   x_domain = 'LINES';  -- CR55336
    carrier_rec carrier_curs%ROWTYPE;
    ------------------------------------------------------------
    CURSOR site_part_curs(c_esn IN VARCHAR2) IS
      SELECT *
        FROM table_site_part
       WHERE x_service_id = c_esn
         AND part_status IN ('Active'
                            ,'Inactive')
       ORDER BY install_date DESC;
    site_part_rec site_part_curs%ROWTYPE;
    ------------------------------------------------------------
    CURSOR user_curs(c_login_name IN VARCHAR2) IS
      SELECT objid
        FROM table_user
       WHERE s_login_name = UPPER(c_login_name);
    user_rec         user_curs%ROWTYPE;
    v_call_trans_seq NUMBER;
    -- 06/09/03
    --------------------------------------------------
  BEGIN
    -- BRAND_SEP
    --Get the autopay promotions details for the ESN
    out_success := 0;
    OPEN curautoinfo_c(p_esn);
    FETCH curautoinfo_c
      INTO curautoinfo_rec;
    IF curautoinfo_c%FOUND THEN
      OPEN part_inst_curs(p_esn);
      FETCH part_inst_curs
        INTO part_inst_rec;
      CLOSE part_inst_curs;
      OPEN site_part_curs(p_esn);
      FETCH site_part_curs
        INTO site_part_rec;
      CLOSE site_part_curs;
      OPEN carrier_curs(site_part_rec.x_min);
      FETCH carrier_curs
        INTO carrier_rec;
      CLOSE carrier_curs;
      OPEN user_curs('SA');
      FETCH user_curs
        INTO user_rec;
      CLOSE user_curs;
      --update autopay_details
      UPDATE table_x_autopay_details
         SET x_status         = 'I'
            ,x_end_date       = SYSDATE
            ,x_account_status = 9
       WHERE objid = curautoinfo_rec.objid;
      --Sp_Seq ('x_call_trans', v_call_trans_seq); -- 06/09/03
      SELECT sequ_x_call_trans.nextval
        INTO v_call_trans_seq
        FROM dual; -- CR12136
      INSERT INTO table_x_call_trans
        (objid
        ,call_trans2site_part
        ,x_action_type
        ,x_call_trans2carrier
        ,x_call_trans2dealer
        ,x_call_trans2user
        ,x_line_status
        ,x_min
        ,x_service_id
        ,x_sourcesystem
        ,x_transact_date
        ,x_total_units
        ,x_action_text
        ,x_reason
        ,x_result
        ,x_sub_sourcesystem)
      VALUES
        (
         -- 04/10/03 (seq_x_call_trans.NEXTVAL + POWER (2, 28)),
         -- seq('x_call_trans'),
         v_call_trans_seq
        ,site_part_rec.objid
        ,'83'
        ,carrier_rec.part_inst2carrier_mkt
        ,site_part_rec.site_part2site
        ,user_rec.objid
        ,'13'
        ,site_part_rec.x_min
        ,site_part_rec.x_service_id
        ,'AUTOPAY_BATCH'
        ,SYSDATE
        ,0
        ,'STAYACT UNSUBSCRIBE'
        , --'Cancellation', --CR 1157
         'TOSS Deactivation'
        ,
         --'STAYACT UNSUBSCRIBE',
         'Completed'
        ,p_brand_name);
      -- if part_inst_rec.x_part_inst_status = '54' then
      -- Added more deactivation reason codes.
      -- CR7233 Added NONUSAGE deactivation reason
      IF site_part_rec.x_deact_reason IN ('NO NEED OF PHONE'
                                         ,'PAST DUE'
                                         ,'PASTDUE'
                                         ,'SALE OF CELL PHONE'
                                         ,'SELL PHONE'
                                         ,'STOLEN'
                                         ,'DEFECTIVE'
                                         ,'SEQUENCE MISMATCH'
                                         ,'RISK ASSESSMENT'
                                         ,'STOLEN CREDIT CARD'
                                         ,'UPGRADE'
                                         ,'REFURBISHED'
                                         ,'PORT OUT'
                                         ,'NON TOPP LINE'
                                         ,'CLONED'
                                         ,'OVERDUE EXCHANGE'
                                         ,'NONUSAGE') THEN

        --insert into send_ftp table
        INSERT INTO x_send_ftp_auto
          (send_seq_no
          ,file_type_ind
          ,esn
          ,program_type
          ,account_status
          ,amount_due)
        VALUES
          (seq_x_send_ftp_auto.nextval
          ,'D'
          ,p_esn
          ,curautoinfo_rec.x_program_type
          ,'D'
          ,0);
      ELSE
        INSERT INTO x_autopay_pending
          (objid
          ,x_creation_date
          ,x_esn
          ,x_program_type
          ,x_account_status
          ,x_status
          ,x_start_date
          ,x_end_date
          ,x_cycle_number
          ,x_program_name
          ,x_enroll_date
          ,x_first_name
          ,x_last_name
          ,x_receive_status
          ,x_autopay_details2site_part
          ,x_autopay_details2x_part_inst
          ,x_autopay_details2contact
          ,x_source_flag
          ,x_enroll_amount
          ,x_source
          ,x_language_flag
          ,x_payment_type)
        VALUES
          (curautoinfo_rec.objid
          ,curautoinfo_rec.x_creation_date
          ,curautoinfo_rec.x_esn
          ,curautoinfo_rec.x_program_type
          ,curautoinfo_rec.x_account_status
          ,curautoinfo_rec.x_status
          ,curautoinfo_rec.x_start_date
          ,SYSDATE
          ,curautoinfo_rec.x_cycle_number
          ,curautoinfo_rec.x_program_name
          ,curautoinfo_rec.x_enroll_date
          ,curautoinfo_rec.x_first_name
          ,curautoinfo_rec.x_last_name
          ,curautoinfo_rec.x_receive_status
          ,curautoinfo_rec.x_autopay_details2site_part
          ,curautoinfo_rec.x_autopay_details2x_part_inst
          ,curautoinfo_rec.x_autopay_details2contact
          ,'D'
          ,curautoinfo_rec.x_enroll_amount
          ,curautoinfo_rec.x_source
          ,curautoinfo_rec.x_language_flag
          ,curautoinfo_rec.x_payment_type);
      END IF;
      out_success := 1;
    END IF;
    CLOSE curautoinfo_c;
  EXCEPTION
    WHEN others THEN
      out_success := 0;
      toss_util_pkg.insert_error_tab_proc('Error IN remove_autopay'
                                         ,p_esn
                                         ,v_procedure_name);
  END remove_autopay_prc;
  /*****************************************************************************/
  /* */
  /* Name: deactivate_past_due */
  /* Description : Available in the specification part of package */
  /*****************************************************************************/
  PROCEDURE deactivate_past_due
  ( p_bus_org_id    IN VARCHAR2,
    v_esn    IN VARCHAR2
  ) IS
    --------------------------------------------------------------------
    v_user           table_user.objid%TYPE;
    v_returnflag     VARCHAR2(20);
    v_returnmsg      VARCHAR2(200);
    dpp_regflag      PLS_INTEGER;
    v_action         VARCHAR2(50) := 'x_service_id is null in Table_site_part';
    v_procedure_name VARCHAR2(50) := '.ST_SERVICE_DEACT_CATCHUP.DEACTIVATE_PAST_DUE';
    intcalltranobj   NUMBER := 0;
    blnotapending    BOOLEAN := FALSE;
    --------------------------------------------------------------------
    v_start       DATE;
    v_end         DATE;
    v_time_used   NUMBER(10
                        ,2);
    v_start_1     DATE;
    v_end_1       DATE;
    v_time_used_1 NUMBER(10
                        ,2);
    ctr           NUMBER := 0;
    --
    --CR21179 Start Kacosta 06/21/2012
    l_i_error_code    PLS_INTEGER := 0;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    --CR21179 End Kacosta 06/21/2012
    --
    --------------------------------------------------------------------
       CURSOR c1 IS
      SELECT
       sp.objid               site_part_objid
      ,sp.x_expire_dt
      ,sp.x_service_id        x_service_id
      ,sp.x_min               x_min
      ,sp.serial_no           x_esn
      ,sp.x_msid
      ,ca.objid               carrier_objid
      ,ir.inv_role2site       site_objid
      ,ca.x_carrier_id        x_carrier_id
      ,sp.site_objid          cust_site_objid
      ,sp.esnobjid            esnobjid
      ,sp.part_serial_no      part_serial_no
      ,sp.x_iccid
      ,sp.x_ota_allowed
      ,sp.org_id
      ,sp.site_part2part_info
      ,sp.esn2part_info
        FROM (SELECT
               sp.objid
              ,sp.x_service_id
              ,sp.x_min
              ,sp.x_msid
              ,sp.site_objid
              ,sp.serial_no
              ,sp.x_expire_dt
              ,tpi_esn.objid esnobjid
              ,tpi_esn.part_serial_no
              ,tpi_esn.x_iccid
              ,pn.x_ota_allowed
              ,bo.org_id
              ,tpi_esn.part_inst2inv_bin
              ,NVL(site_part2part_info
                  ,-1) site_part2part_info
              ,tpi_esn.n_part_inst2part_mod esn2part_info
                FROM table_site_part sp
                JOIN table_part_inst tpi_esn
                  ON sp.x_service_id = tpi_esn.part_serial_no
                JOIN table_mod_level ml
                  ON tpi_esn.n_part_inst2part_mod = ml.objid
                JOIN table_part_num pn
                  ON ml.part_info2part_num = pn.objid
                JOIN table_bus_org bo
                  ON pn.part_num2bus_org = bo.objid
                WHERE 1 = 1
                and sp.x_service_id=v_esn
                AND tpi_esn.x_domain = 'PHONES'
                AND bo.org_id || '' = p_bus_org_id
                AND NOT EXISTS (SELECT '1'
                        FROM table_part_inst pi3
                        WHERE pi3.part_to_esn2part_inst = tpi_esn.objid
                        AND pi3.x_domain = 'REDEMPTION CARDS'
                        AND pi3.x_part_inst_status = '400')
                        ---- CR27811 adasgupta start----
                AND NOT EXISTS (SELECT 'x'
                                 FROM sa.x_program_enrolled   a
                                     ,sa.x_program_parameters b
                                 WHERE 1=1
                                 AND a.x_enrollment_status IN
                                       ('ENROLLED','ENROLLMENTPENDING',
                                       'ENROLLMENTSCHEDULED','SUSPENDED'
                                       )
                                 AND a.x_wait_exp_date IS NULL
                                 AND a.x_is_grp_primary = 1
                                 AND b.objid = a.pgm_enroll2pgm_parameter
                                 AND a.pgm_enroll2site_part=sp.objid
                                 AND trunc(a.x_enrolled_date) = trunc(sysdate)-1
                                 AND trunc(a.x_next_charge_date) = trunc(sysdate)-1
                               )      --- CR27811 adasgupta end----
             ) sp
        LEFT OUTER JOIN table_inv_bin ib
          ON sp.part_inst2inv_bin = ib.objid
        LEFT OUTER JOIN table_inv_role ir
          ON ib.inv_bin2inv_locatn = ir.inv_role2inv_locatn
        LEFT OUTER JOIN table_part_inst pi2
          ON sp.x_min = pi2.part_serial_no
        LEFT OUTER JOIN table_x_carrier ca
          ON pi2.part_inst2carrier_mkt = ca.objid
       WHERE 1 = 1
         AND pi2.x_domain || '' = 'LINES';
    --
    c1_rec c1%ROWTYPE;
    --
    CURSOR call_trans_igt_info_curs(c_n_site_part_objid IN sa.table_x_call_trans.call_trans2site_part%TYPE) IS
      SELECT igt.carrier_id igt_carrier_id
            ,txc.objid      igt_carrier_objid
        FROM sa.table_x_call_trans xct
        JOIN sa.table_task tbt
          ON xct.objid = tbt.x_task2x_call_trans
        JOIN gw1.ig_transaction igt
          ON tbt.task_id = igt.action_item_id
        JOIN table_x_carrier txc
          ON igt.carrier_id = txc.x_carrier_id
       WHERE xct.call_trans2site_part = c_n_site_part_objid
         AND xct.x_action_type <> '2'
         AND xct.x_result = 'Completed'
         AND igt.status = 'S'
         AND igt.order_type NOT IN ('S'
                                   ,'D')
         AND igt.creation_date = (SELECT MAX(igt_max_xact.creation_date)
                                    FROM sa.table_x_call_trans xct_max_xact
                                    JOIN sa.table_task tbt_max_xact
                                      ON xct_max_xact.objid = tbt_max_xact.x_task2x_call_trans
                                    JOIN gw1.ig_transaction igt_max_xact
                                      ON tbt_max_xact.task_id = igt_max_xact.action_item_id
                                   WHERE xct_max_xact.call_trans2site_part = c_n_site_part_objid
                                     AND xct_max_xact.x_action_type <> '2'
                                     AND xct_max_xact.x_result = 'Completed'
                                     AND igt_max_xact.status = 'S'
                                     AND igt_max_xact.order_type NOT IN ('S'
                                                                        ,'D'));
    --
    call_trans_igt_info_rec call_trans_igt_info_curs%ROWTYPE;
    --
    CURSOR call_trans_igth_info_curs(c_n_site_part_objid IN sa.table_x_call_trans.call_trans2site_part%TYPE) IS
      SELECT igh.carrier_id igh_carrier_id
            ,txc.objid      igh_carrier_objid
        FROM sa.table_x_call_trans xct
        JOIN sa.table_task tbt
          ON xct.objid = tbt.x_task2x_call_trans
        JOIN gw1.ig_transaction_history igh
          ON tbt.task_id = igh.action_item_id
        JOIN table_x_carrier txc
          ON igh.carrier_id = txc.x_carrier_id
       WHERE xct.call_trans2site_part = c_n_site_part_objid
         AND xct.x_action_type <> '2'
         AND xct.x_result = 'Completed'
         AND igh.status = 'S'
         AND igh.order_type NOT IN ('S'
                                   ,'D')
         AND igh.creation_date = (SELECT MAX(igh_max_xact.creation_date)
                                    FROM sa.table_x_call_trans xct_max_xact
                                    JOIN sa.table_task tbt_max_xact
                                      ON xct_max_xact.objid = tbt_max_xact.x_task2x_call_trans
                                    JOIN gw1.ig_transaction_history igh_max_xact
                                      ON tbt_max_xact.task_id = igh_max_xact.action_item_id
                                   WHERE xct_max_xact.call_trans2site_part = c_n_site_part_objid
                                     AND xct_max_xact.x_action_type <> '2'
                                     AND xct_max_xact.x_result = 'Completed'
                                     AND igh_max_xact.status = 'S'
                                     AND igh_max_xact.order_type NOT IN ('S'
                                                                        ,'D'));
    --
    call_trans_igth_info_rec call_trans_igth_info_curs%ROWTYPE;
    --
    CURSOR excluded_pastduedeact_curs(c_n_carrier_id x_excluded_pastduedeact.x_carrier_id%TYPE) IS
      SELECT xep.x_carrier_id excluded_pastduedeact
        FROM x_excluded_pastduedeact xep
       WHERE xep.x_carrier_id = c_n_carrier_id;
    --
    excluded_pastduedeact_rec excluded_pastduedeact_curs%ROWTYPE;
    --
    --CR21179 End Kacosta 06/21/2012
    --
    CURSOR c_chkotapend(c_esn IN VARCHAR2) IS
      SELECT 'X'
        FROM table_x_call_trans
       WHERE objid = (SELECT MAX(objid)
                        FROM table_x_call_trans
                       WHERE x_service_id = c_esn)
         AND x_result = 'OTA PENDING'
         AND x_action_type = '6';
    r_chkotapend c_chkotapend%ROWTYPE;

    CURSOR check_active_min_curs(c_min IN VARCHAR2) IS
      SELECT 1
        FROM table_site_part sp2
       WHERE 1 = 1
         AND NVL(sp2.part_status
                ,'Obsolete') IN ('CarrierPending'
                                ,'Active')
         AND sp2.x_min = c_min
         AND NVL(sp2.x_expire_dt
                ,TO_DATE('1753-01-01 00:00:00'
                        ,'yyyy-mm-dd hh24:mi:ss')) > TRUNC(SYSDATE);
    check_active_min_rec check_active_min_curs%ROWTYPE;

    CURSOR past_due_batch_check_curs(c_sp_objid IN NUMBER) IS
      SELECT sp.objid
        FROM table_site_part sp
       WHERE 1 = 1
         AND sp.part_status = 'Active'
         AND NVL(sp.x_expire_dt
                ,TO_DATE('1753-01-01 00:00:00'
                        ,'yyyy-mm-dd hh24:mi:ss')) > TO_DATE('1753-02-01 00:00:00'
                                                            ,'yyyy-mm-dd hh24:mi:ss')
         AND NVL(sp.x_expire_dt
                ,TO_DATE('1753-01-01 00:00:00'
                        ,'yyyy-mm-dd hh24:mi:ss')) < TRUNC(SYSDATE)
         AND sp.objid = c_sp_objid;
    past_due_batch_check_rec past_due_batch_check_curs%ROWTYPE;
    ------------------------------------------------------------------------------------------------

  -- Get any queued pins (for the master of the account group) of any esn that belongs to the account group.
  CURSOR c_get_acct_grp_pins ( p_esn VARCHAR2) IS
    SELECT 1
    FROM   table_part_inst pi_pin,
           table_part_inst pi_esn,
           x_account_group_member agm
    WHERE  1 = 1
    AND    agm.account_group_id = ( SELECT account_group_id
                                    FROM   x_account_group_member
                                    WHERE  esn = p_esn
                                    AND    UPPER(status) <> 'EXPIRED'
                                    AND    ROWNUM = 1
                                  )
    AND    agm.master_flag = 'Y'                      -- search for the master only
    AND    UPPER(agm.status) <> 'EXPIRED'             -- active member
    AND    agm.esn = pi_esn.part_serial_no            -- get the master of the account group
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_esn.objid = pi_pin.part_to_esn2part_inst -- part inst objid of the master of the account group
    AND    pi_pin.x_domain = 'REDEMPTION CARDS'
    AND    pi_pin.x_part_inst_status = '400';

  acct_grp_pins_rec   c_get_acct_grp_pins%ROWTYPE;
  n_queued_card_count NUMBER := 0;

BEGIN
    --
    --CR21179 Start Kacosta 06/21/2012
   
    --CR21179 End Kacosta 06/21/2012
    --
    v_start_1 := SYSDATE;

    SELECT objid
      INTO v_user
      FROM table_user
     WHERE s_login_name = 'SA';

    FOR c1_rec IN c1 LOOP

      -- Added logic by Juda Pena to validate when there is a queued pin as the master of the account group (only for brand x)
      IF NVL(brand_x_pkg.get_shared_group_flag(ip_bus_org_id => p_bus_org_id),'N') = 'Y' THEN
        -- Get queued pins for the master of the account group
        OPEN c_get_acct_grp_pins (c1_rec.part_serial_no);
        FETCH c_get_acct_grp_pins INTO acct_grp_pins_rec;
        IF c_get_acct_grp_pins%FOUND THEN
          -- Close the opened cursor
          CLOSE c_get_acct_grp_pins;
          -- Exit current iteration of loop unconditionally and transfer control to the next iteration
          CONTINUE;
        END IF;
        -- Close the opened cursor
        CLOSE c_get_acct_grp_pins;
      END IF;
      --


      --
      --CR21179 Start Kacosta 06/21/2012
      IF (c1_rec.site_part2part_info <> c1_rec.esn2part_info) THEN
        --
        UPDATE table_site_part tsp
           SET tsp.site_part2part_info = c1_rec.esn2part_info
         WHERE tsp.objid = c1_rec.site_part_objid;
        --
        COMMIT;
        --
      END IF;
      --
      IF (c1_rec.carrier_objid IS NULL) THEN
        --
        IF call_trans_igt_info_curs%ISOPEN THEN
          --
          CLOSE call_trans_igt_info_curs;
          --
        END IF;
        --
        OPEN call_trans_igt_info_curs(c_n_site_part_objid => c1_rec.site_part_objid);
        FETCH call_trans_igt_info_curs
          INTO call_trans_igt_info_rec;
        CLOSE call_trans_igt_info_curs;
        --
        IF (call_trans_igt_info_rec.igt_carrier_objid IS NULL) THEN
          --
          IF call_trans_igth_info_curs%ISOPEN THEN
            --
            CLOSE call_trans_igth_info_curs;
            --
          END IF;
          --
          OPEN call_trans_igth_info_curs(c_n_site_part_objid => c1_rec.site_part_objid);
          FETCH call_trans_igth_info_curs
            INTO call_trans_igth_info_rec;
          CLOSE call_trans_igth_info_curs;
          --
          IF (call_trans_igth_info_rec.igh_carrier_objid IS NULL) THEN
            --
            toss_util_pkg.insert_error_tab_proc(ip_action       => 'Get IG_TRANSACTIONS carrier id'
                                               ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                               ,ip_program_name => 'SERVICE_DEACTIVATION_CODE_jt.DEACTIVATE_PAST_DUE'
                                               ,ip_error_text   => 'Unable to find IG_TRANSACTIONS carrier id');
            --
            GOTO skip_this_deactivation;
            --
          END IF;
          --
          call_trans_igt_info_rec.igt_carrier_id    := call_trans_igth_info_rec.igh_carrier_id;
          call_trans_igt_info_rec.igt_carrier_objid := call_trans_igth_info_rec.igh_carrier_objid;
          --
        END IF;
        --
        c1_rec.x_carrier_id  := call_trans_igt_info_rec.igt_carrier_id;
        c1_rec.carrier_objid := call_trans_igt_info_rec.igt_carrier_objid;
        --
        UPDATE table_part_inst
        SET   part_inst2carrier_mkt = c1_rec.carrier_objid
        WHERE part_serial_no = c1_rec.x_min
        AND   x_domain = 'LINES';   --CR55336
        --
        COMMIT;
        --
      END IF;
      --
      IF excluded_pastduedeact_curs%ISOPEN THEN
        --
        CLOSE excluded_pastduedeact_curs;
        --
      END IF;
      --
      OPEN excluded_pastduedeact_curs(c_n_carrier_id => c1_rec.x_carrier_id);
      FETCH excluded_pastduedeact_curs
        INTO excluded_pastduedeact_rec;
      CLOSE excluded_pastduedeact_curs;
      --
      IF (excluded_pastduedeact_rec.excluded_pastduedeact IS NOT NULL) THEN
        --
        BEGIN
          --
          toss_util_pkg.insert_error_tab_proc(ip_action       => 'Check if carrier is an excluded pastduedeact carrier'
                                             ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                             ,ip_program_name => 'SERVICE_DEACTIVATION_CODE_jt.DEACTIVATE_PAST_DUE'
                                             ,ip_error_text   => 'Carrier is an excluded pastduedeact carrier');
          --
        EXCEPTION
          WHEN others THEN
            --
            NULL;
            --
        END;
        --
        GOTO skip_this_deactivation;
        --
      END IF;
      --CR21179 End Kacosta 06/21/2012
      --
      dbms_output.put_line('c1_rec.x_service_id:' || c1_rec.x_service_id);
      OPEN past_due_batch_check_curs(c1_rec.site_part_objid);
      FETCH past_due_batch_check_curs
        INTO past_due_batch_check_rec;
      IF past_due_batch_check_curs%NOTFOUND THEN
        dbms_output.put_line('past_due_batch_check_curs%notfound');
        CLOSE past_due_batch_check_curs;
        COMMIT;
        --
        --CR21179 Start Kacosta 06/21/2012
        BEGIN
          --
          toss_util_pkg.insert_error_tab_proc(ip_action       => 'Check past due batch'
                                             ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                             ,ip_program_name => 'SERVICE_DEACTIVATION_CODE_jt.DEACTIVATE_PAST_DUE'
                                             ,ip_error_text   => 'Past due batch check not found');
          --
        EXCEPTION
          WHEN others THEN
            --
            NULL;
            --
        END;
        --CR21179 End Kacosta 06/21/2012
        --
        GOTO skip_this_deactivation;
      END IF;
      CLOSE past_due_batch_check_curs;

      OPEN check_active_min_curs(c1_rec.x_min);
      FETCH check_active_min_curs
        INTO check_active_min_rec;
      IF check_active_min_curs%FOUND THEN
        UPDATE table_site_part
           SET part_status = 'Inactive'
         WHERE objid = c1_rec.site_part_objid;
        dbms_output.put_line('check_active_min_curs%found');
        OPEN check_esn_curs(c1_rec.x_service_id);
        FETCH check_esn_curs
          INTO check_esn_rec;
        IF check_esn_curs%NOTFOUND THEN
          dbms_output.put_line('check_esn_curs%found');
          UPDATE table_part_inst
             SET x_part_inst_status  = '54'
                ,status2x_code_table = 990
          WHERE part_serial_no = c1_rec.x_service_id
          AND   x_domain = 'PHONES';   --CR55336
        END IF;
        CLOSE check_esn_curs;
        CLOSE check_active_min_curs;
        COMMIT;
        GOTO skip_this_deactivation;
      END IF;
      CLOSE check_active_min_curs;

      IF (c1_rec.x_service_id IS NULL) THEN
        UPDATE table_site_part
           SET x_service_id = NVL(c1_rec.x_esn
                                 ,c1_rec.part_serial_no)
         WHERE objid = c1_rec.site_part_objid;
        COMMIT;
      END IF;

      sa.SERVICE_DEACTIVATION_CODE_jt.check_dpp_registered_prc(c1_rec.x_service_id
                                                           ,dpp_regflag);
      IF dpp_regflag = 1 THEN
        --CR21179 Start Kacosta 06/21/2012
        BEGIN
          --
          toss_util_pkg.insert_error_tab_proc(ip_action       => 'Calling SERVICE_DEACTIVATION_CODE_jt.check_dpp_registered_prc'
                                             ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                             ,ip_program_name => 'SERVICE_DEACTIVATION_CODE_jt.DEACTIVATE_PAST_DUE'
                                             ,ip_error_text   => 'SERVICE_DEACTIVATION_CODE_jt.check_dpp_registered_prc prevents ESN to be deactivated');
          --
        EXCEPTION
          WHEN others THEN
            --
            NULL;
            --
        END;
        --CR21179 End Kacosta 06/21/2012
        --
        SERVICE_DEACTIVATION_CODE_jt.create_call_trans(c1_rec.site_part_objid
                                                   ,84
                                                   ,c1_rec.carrier_objid
                                                   ,c1_rec.site_objid
                                                   ,v_user
                                                   ,c1_rec.x_min
                                                   ,c1_rec.x_service_id
                                                   ,'PROTECTION PLAN BATCH'
                                                   ,SYSDATE
                                                   ,NULL
                                                   ,'Monthly Payments'
                                                   ,'PASTDUE'
                                                   ,'Pending'
                                                   ,c1_rec.x_iccid
                                                   ,c1_rec.org_id
                                                   ,intcalltranobj);
      ELSE
        IF (billing_deactprotect(c1_rec.x_service_id) = 1) THEN
          NULL;
          --CR21179 Start Kacosta 06/21/2012
          BEGIN
            --
            toss_util_pkg.insert_error_tab_proc(ip_action       => 'Calling billing_deactprotect'
                                               ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                               ,ip_program_name => 'SERVICE_DEACTIVATION_CODE_jt.DEACTIVATE_PAST_DUE'
                                               ,ip_error_text   => 'billing_deactprotect prevents ESN to be deactivated');
            --
          EXCEPTION
            WHEN others THEN
              --
              NULL;
              --
          END;
          --CR21179 End Kacosta 06/21/2012
          --
        ELSE

   -- double check to determine if the esn has a queued card
          BEGIN
            SELECT COUNT(DISTINCT objid)
            INTO   n_queued_card_count
            FROM   ( SELECT objid
                     FROM   table_part_inst
                     WHERE  part_to_esn2part_inst IN ( SELECT objid
                                                       FROM   table_part_inst
                                                       WHERE  part_serial_no = c1_rec.x_service_id
                                                       AND    x_domain = 'PHONES'   --CR55336
                                                     )
                     AND    x_domain = 'REDEMPTION CARDS'
                     AND    x_part_inst_status = '400'
                     UNION
                     SELECT objid
                     FROM   table_part_inst
                     WHERE  part_to_esn2part_inst = c1_rec.esnobjid
                     AND    x_domain = 'REDEMPTION CARDS'
                     AND    x_part_inst_status = '400'
                   );
           EXCEPTION
             WHEN others THEN
               n_queued_card_count := 0;
          END;
   -- if there is a queued card
   IF n_queued_card_count > 0 THEN
     -- skip current iteration
     CONTINUE;
   END IF;
   --

          deactservice('PAST_DUE_BATCH'
                      ,v_user
                      ,c1_rec.x_service_id
                      ,c1_rec.x_min
                      ,'PASTDUE'
                      ,0
                      ,NULL
                      ,'true'
                      ,v_returnflag
                      ,v_returnmsg);
        END IF;
      END IF;

      FOR c2_rec IN (SELECT ROWID
                       FROM table_x_group2esn
                      WHERE groupesn2part_inst = c1_rec.esnobjid
                        AND groupesn2x_promo_group IN (SELECT objid
                                                         FROM table_x_promotion_group
                                                        WHERE group_name IN ('90_DAY_SERVICE'
                                                                            ,'52020_GRP'))) LOOP
        UPDATE table_x_group2esn u
           SET x_end_date = SYSDATE
         WHERE u.rowid = c2_rec.rowid;
        COMMIT;
      END LOOP;
      <<skip_this_deactivation>>
      COMMIT;
    END LOOP;

    v_end_1       := SYSDATE;
    v_time_used_1 := (v_end_1 - v_start_1) * 24 * 60;
    dbms_output.put_line('END_PROCEDURE call Total time used for esn: ' || v_time_used_1);
  END deactivate_past_due;

  /*****************************************************************************/
  /* */
  /* Name: deactivate_airtouch */
  /* Description : Available in the specification part of package */
  /*****************************************************************************/
  PROCEDURE deactivate_airtouch IS
    v_user         table_user.objid%TYPE;
    v_count        NUMBER := 1;
    v_deact_count  NUMBER;
    intcalltranobj NUMBER := 0;
    v_deact_reason VARCHAR2(20); --CR7233
    v_returnflag   VARCHAR2(20);
    v_returnmsg    VARCHAR2(200);
    CURSOR c1 IS
      SELECT sp.objid         site_part_objid
            ,sp.x_service_id  x_service_id
            ,sp.x_min         x_min
            ,ca.objid         carrier_objid
            ,ir.inv_role2site site_objid
            ,ca.x_carrier_id  x_carrier_id
            ,sp.site_objid    cust_site_objid
            ,sp.x_msid
            ,pi.x_iccid
        FROM table_x_carrier ca
            ,table_part_inst pi2
            ,table_inv_role  ir
            ,table_inv_bin   ib
            ,table_part_inst pi
            ,table_site_part sp
       WHERE ca.x_carrier_id IN (100002
                                ,110002
                                ,120002)
         AND pi2.part_inst2carrier_mkt = ca.objid
         AND pi2.x_domain = 'LINES'
         AND sp.x_min = pi2.part_serial_no
         AND ib.inv_bin2inv_locatn = ir.inv_role2inv_locatn
         AND pi.part_inst2inv_bin = ib.objid
         AND sp.objid = pi.x_part_inst2site_part
         AND sp.x_expire_dt BETWEEN TO_DATE('02-JAN-1753'
                                           ,'dd-mon-yyyy') AND (SYSDATE - 1)
         AND sp.part_status = 'Active'
       ORDER BY sp.x_expire_dt;
    --- CR7233 New deactivation reason - NONUSAGE
    CURSOR check_deact_reason(p_esn VARCHAR2) IS
      SELECT nu.x_deact_flag
        FROM x_nonusage_esns nu
       WHERE nu.x_esn = p_esn
         AND nu.x_deact_flag = 1;
    check_deact_reason_rec check_deact_reason%ROWTYPE;

    --- CR7233
  BEGIN
    SELECT COUNT(*) - 10199
      INTO v_deact_count
      FROM table_site_part sp
          ,table_part_inst pi
          ,table_x_carrier ca
     WHERE ca.x_carrier_id IN (100002
                              ,110002
                              ,120002)
       AND pi.part_inst2carrier_mkt = ca.objid
       AND pi.x_domain || '' = 'LINES'
       AND sp.x_min = pi.part_serial_no
       AND sp.part_status || '' = 'Active';
    dbms_output.put_line('deact_count: ' || TO_CHAR(v_deact_count));
    IF v_deact_count > 0 THEN
      SELECT objid
        INTO v_user
        FROM table_user
      --WHERE UPPER (login_name) = 'SA';--POST 10G
       WHERE s_login_name = 'SA';
      FOR c1_rec IN c1 LOOP

        ---CR7233-------check_deact_reason----------
        OPEN check_deact_reason(c1_rec.x_service_id);
        FETCH check_deact_reason
          INTO check_deact_reason_rec;
        IF check_deact_reason%FOUND THEN
          v_deact_reason := 'NONUSAGE';
        ELSE
          v_deact_reason := 'PASTDUE';
        END IF;
        CLOSE check_deact_reason;
        ---CR7233---------------------------------
        --CR3153 T-Mobile changes
        --CR7233 Instead of passing deact reason 'PASTDUE', deact reason is passed from variable v_deact_reason.
        deactservice('PAST_DUE_BATCH'
                    ,v_user
                    ,c1_rec.x_service_id
                    ,c1_rec.x_min
                    ,v_deact_reason
                    ,0
                    ,NULL
                    ,'true'
                    ,v_returnflag
                    ,v_returnmsg);
        v_count := v_count + 1;
        IF v_count = v_deact_count THEN
          EXIT;
        END IF;
      END LOOP;
    END IF;
  END deactivate_airtouch;
  /*****************************************************************************/
  /* */
  /* Name: deact_road_past_due */
  /* Description : Available in the specification part of package */
  /*****************************************************************************/
  --VAdapa on 02/13/02 to deactivate expired ROADSIDE cards
  PROCEDURE deact_road_past_due IS
    CURSOR c_site_part IS
      SELECT sp.objid        site_part_objid
            ,sp.x_service_id x_service_id
            ,x_iccid
        FROM table_site_part sp
       WHERE sp.x_expire_dt BETWEEN TO_DATE('02-JAN-1753'
                                           ,'dd-mon-yyyy') AND (SYSDATE - 1)
         AND instance_name = 'ROADSIDE'
         AND sp.part_status || '' = 'Active'
         AND ROWNUM < 1001;
    CURSOR c_road_inst(c_ip_ser_id IN VARCHAR2) IS
      SELECT *
        FROM table_x_road_inst
       WHERE x_red_code = c_ip_ser_id;
    --- CR7233 New deactivation reason - NONUSAGE
    CURSOR check_deact_reason(p_esn VARCHAR2) IS
      SELECT nu.x_deact_flag
        FROM x_nonusage_esns nu
       WHERE nu.x_esn = p_esn
         AND nu.x_deact_flag = 1;
    --- CR7233
    check_deact_reason_rec check_deact_reason%ROWTYPE;
    r_road_inst            c_road_inst%ROWTYPE;
    v_user                 table_user.objid%TYPE;
    v_action               VARCHAR2(4000);
    v_service_id           VARCHAR2(20);
    v_road_hist_seq        NUMBER; -- 06/09/03
    intcalltranobj         NUMBER := 0;
    v_deact_reason         VARCHAR2(20);
    --CR7233
  BEGIN
    SELECT objid
      INTO v_user
      FROM table_user
    --WHERE UPPER (login_name) = 'SA';--POST 10G
     WHERE s_login_name = 'SA';
    FOR r_site_part IN c_site_part LOOP
      BEGIN

        ---CR7233-------check_deact_reason----------
        OPEN check_deact_reason(r_site_part.x_service_id);
        FETCH check_deact_reason
          INTO check_deact_reason_rec;
        IF check_deact_reason%FOUND THEN
          v_deact_reason := 'NONUSAGE';
        ELSE
          v_deact_reason := 'PASTDUE';
        END IF;
        CLOSE check_deact_reason;
        ---CR7233---------------------------------
        v_service_id := r_site_part.x_service_id;
        v_action     := 'UPDATE TABLE_X_ROAD_HIST';
        UPDATE table_x_road_inst
           SET x_part_inst_status     = '47'
              ,rd_status2x_code_table = 2144
              ,x_hist_update          = 1
         WHERE x_red_code = r_site_part.x_service_id;
        OPEN c_road_inst(r_site_part.x_service_id);
        FETCH c_road_inst
          INTO r_road_inst;
        CLOSE c_road_inst;
        v_action := 'INSERT INTO TABLE_X_ROAD_HIST';
        --Sp_Seq ('x_road_hist', v_road_hist_seq); -- 06/09/03
        SELECT sequ_x_road_hist.nextval
          INTO v_road_hist_seq
          FROM dual; -- CR12136
        INSERT INTO table_x_road_hist
          (objid
          ,x_part_serial_no
          ,x_part_mod
          ,x_part_bin
          ,x_warr_end_date
          ,x_part_status
          ,x_insert_date
          ,x_creation_date
          ,x_po_num
          ,x_domain
          ,x_part_inst_status
          ,x_change_date
          ,x_change_reason
          ,x_last_trans_time
          ,x_transaction_id
          ,x_repair_date
          ,x_pick_request
          ,x_order_number
          ,x_road_hist2inv_bin
          ,x_road_hist2part_mod
          ,x_road_hist2road_inst
          ,x_road_hist2user
          ,road_hist2x_code_table
          ,x_road_hist2site_part)
        VALUES
          (
           -- 04/10/03 seq_x_road_hist.nextval + POWER (2, 28),
           -- seq('x_road_hist'),
           v_road_hist_seq
          ,r_road_inst.part_serial_no
          ,r_road_inst.part_mod
          ,r_road_inst.part_bin
          ,r_road_inst.warr_end_date
          ,r_road_inst.part_status
          ,r_road_inst.x_insert_date
          ,r_road_inst.x_creation_date
          ,r_road_inst.x_po_num
          ,r_road_inst.x_domain
          ,'47'
          ,SYSDATE
          ,v_deact_reason
          , --CR7233:previously PASTDUE was inserted directly. Now, either of PASTDUE or NONUSAGE will be passesd into v_deact_reason
           SYSDATE
          ,r_road_inst.transaction_id
          ,r_road_inst.repair_date
          ,NULL
          ,r_road_inst.x_order_number
          ,r_road_inst.road_inst2inv_bin
          ,r_road_inst.n_road_inst2part_mod
          ,r_road_inst.objid
          ,r_road_inst.rd_create2user
          ,2144
          ,r_road_inst.x_road_inst2site_part);
        v_action := 'INSERT INTO TABLE_X_CALL_TRANS';
        --CR7233 Instead of passing deact reason 'PASTDUE', deact reason is passed from variable v_deact_reason.
        create_call_trans(r_site_part.site_part_objid
                         ,11
                         ,NULL
                         , -- carrier objid
                          NULL
                         , -- dealer objid
                          v_user
                         ,NULL
                         , -- MIN value
                          r_site_part.x_service_id
                         ,'ROAD_PASTDUE_BATCH'
                         ,SYSDATE
                         ,NULL
                         ,'Cancellation'
                         ,v_deact_reason
                         ,'Completed'
                         ,r_site_part.x_iccid
                         ,'GENERIC'
                         ,intcalltranobj);
        v_action := 'UPDATE TABLE_SITE_PART';

        UPDATE table_site_part
           SET part_status    = 'Inactive'
              ,service_end_dt = SYSDATE
              ,x_deact_reason = v_deact_reason
         WHERE objid = r_site_part.site_part_objid;

        COMMIT;
      EXCEPTION
        WHEN others THEN
          toss_util_pkg.insert_error_tab_proc('Inner BLOCK : ' || v_action
                                             ,v_service_id
                                             ,'ROAD_PASTDUE');
      END;
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN others THEN
      toss_util_pkg.insert_error_tab_proc(v_action
                                         ,NULL
                                         ,'ROAD_PASTDUE');
  END deact_road_past_due;
  /*****************************************************************************/
  /* */
  /* Name: deactivate_any */
  /* Description : Available in the specification part of package */
  /*****************************************************************************/
  PROCEDURE deactivate_any
  (
    ip_esn            IN VARCHAR2
   ,ip_reason         IN VARCHAR2
   ,ip_caller_program IN VARCHAR2
   ,ip_result         IN OUT PLS_INTEGER
  ) AS
    v_user           table_user.objid%TYPE;
    v_procedure_name VARCHAR2(80) := v_package_name || '.DEACTIVATE_ANY()';
    v_action         VARCHAR2(4000);
    v_service_id     VARCHAR2(20);
    intcalltranobj   NUMBER := 0;
    v_returnflag     VARCHAR2(20);
    v_returnmsg      VARCHAR2(200);
    --CR#4479 - Billing Platform change request ----start
    op_result NUMBER;
    op_msg    VARCHAR2(200);
    --CR#4479 - Billing Platform change request ----end
    CURSOR c1 IS
      SELECT sp.objid site_part_objid
            ,sp.x_service_id x_service_id
            ,sp.x_min x_min
            ,ca.objid carrier_objid
            ,ir.inv_role2site site_objid
            ,sp.serial_no x_esn
            ,ca.x_carrier_id x_carrier_id
            ,sp.site_objid cust_site_objid
            ,pi.objid esnobjid
            ,sp.x_msid
            ,NVL(pi2.x_port_in
                ,0) x_port_in
            , --CR12338
             pi.x_iccid
        FROM table_x_carrier ca
            ,table_part_inst pi2
            ,table_inv_role  ir
            ,table_inv_bin   ib
            ,table_part_inst pi
            ,table_site_part sp
       WHERE ca.objid = pi2.part_inst2carrier_mkt
         AND pi2.x_domain = 'LINES' -->CR3318 Removed initcap func
         AND pi2.part_serial_no = sp.x_min
         AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
         AND ib.objid = pi.part_inst2inv_bin
         AND pi.x_part_inst2site_part = sp.objid
         AND (sp.part_status) = 'Active'
         AND sp.x_service_id = ip_esn;
    -- BRAND_SEP
    CURSOR brand_name_cur(ip_esn IN VARCHAR2) IS
      SELECT org_id
        FROM table_part_inst pi
            ,table_mod_level ml
            ,table_part_num  pn
            ,table_bus_org   bo
       WHERE pi.part_serial_no = ip_esn
         AND pi.x_domain = 'PHONES'
         AND pi.n_part_inst2part_mod = ml.objid
         AND ml.part_info2part_num = pn.objid
         AND pn.part_num2bus_org = bo.objid;

    brand_name_rec brand_name_cur%ROWTYPE;

    v_brand_name VARCHAR2(30);
  BEGIN
    SELECT objid
      INTO v_user
      FROM table_user
    --WHERE UPPER (login_name) = 'SA';--POST 10G
     WHERE s_login_name = 'SA';
    BEGIN
      FOR c1_rec IN c1 LOOP
        -----------------------------------------------------------------------------------------
        --new code for refurb phone for ported phone numbers
        -----------------------------------------------------------------------------------------
        dbms_output.put_line('c1_rec.x_port_in:' || c1_rec.x_port_in);
        -- CR5353
        -- IF c1_rec.x_port_in = 1
        IF c1_rec.x_port_in = 1
          --CR18244 Start kacosta 10/06/2011
           AND ip_caller_program NOT LIKE '%POSA_PKG.MAKE_PHONE_RETURNED().RESET_ESN_FUN()%'
          --CR18244 End kacosta 10/06/2011
           AND ip_caller_program NOT LIKE '%MANUAL REFURB.RESET_ESN_FUN()%'
           AND ip_caller_program NOT LIKE '%SP_CLARIFY_REFURB_PRC()%' THEN
          OPEN brand_name_cur(c1_rec.x_service_id);
          FETCH brand_name_cur
            INTO brand_name_rec;
          IF brand_name_cur%FOUND THEN
            v_brand_name := brand_name_rec.org_id;
          ELSE
            v_brand_name := 'GENERIC';
          END IF;
          CLOSE brand_name_cur;
          dbms_output.put_line('inside c1_rec.x_port_in:start');
          create_call_trans(c1_rec.site_part_objid
                           ,20
                           ,c1_rec.carrier_objid
                           ,c1_rec.site_objid
                           ,v_user
                           ,c1_rec.x_min
                           ,c1_rec.x_service_id
                           ,ip_reason
                           ,SYSDATE
                           ,NULL
                           ,'PORTED DEACT PENDING'
                           ,ip_reason
                           ,'Completed'
                           ,c1_rec.x_iccid
                           ,v_brand_name
                           ,intcalltranobj);
          ip_result := 0;
          toss_util_pkg.insert_error_tab_proc('X_PORT_IN = 1'
                                             ,c1_rec.x_service_id
                                             ,v_procedure_name);
          dbms_output.put_line('inside c1_rec.x_port_in:exit');
          EXIT;
        END IF;
        -----------------------------------------------------------------------------------------
        v_service_id := c1_rec.x_service_id;
        v_action     := 'Deactivating service';

        dbms_output.put_line('calling deactservice');

        --CR3153 T-Mobile changes
        deactservice(UPPER(ip_reason)
                    ,v_user
                    ,c1_rec.x_service_id
                    ,c1_rec.x_min
                    ,UPPER(ip_reason)
                    ,0
                    ,NULL
                    ,'true'
                    ,v_returnflag
                    ,v_returnmsg);
        --------------------------------------------------------------------------------------------------
        --CR#4479 - Billing Platform change request ----start
        -- Billing rules engine call for any deactivation
        billing_deact_rule_engine(ip_esn
                                 ,ip_reason
                                 ,v_user
                                 ,op_result
                                 ,op_msg);
        --CR#4479 - Billing Platform change request ----end
        --------------------------------------------------------------------------------------------------
        ip_result := 1;
      END LOOP;
    EXCEPTION
      WHEN others THEN

        /** FAILURE POINT **/
        ip_result := 0;
        toss_util_pkg.insert_error_tab_proc('Inner BLOCK : ' || v_action
                                           ,v_service_id
                                           ,v_procedure_name);
    END; -- of inner block (for loop block)
  EXCEPTION
    WHEN others THEN

      /** FAILURE POINT **/
      ip_result := 0;
      toss_util_pkg.insert_error_tab_proc(v_action
                                         ,NVL(v_service_id
                                             ,'N/A')
                                         ,v_procedure_name);
  END deactivate_any;

  /***********************************************************************************
  -- CR38664
  -- Name: get_deact_line_status
  -- Description: Get the deactivation reason that applies to the line
  --              and returns empty string when MIN is not Valid'
  /***********************************************************************************/
function get_deact_line_status (ip_ph_tech varchar2, ip_min varchar2, ip_deactreason varchar2)
return varchar2 is
    deact_reason varchar2(100);
    rec_min cur_min%ROWTYPE;
begin
    deact_reason := '';
    OPEN cur_min(ip_min, ip_ph_tech, ip_deactreason);
      FETCH cur_min INTO rec_min;
      IF cur_min%NOTFOUND THEN
        CLOSE cur_min;
        RETURN deact_reason;
      END IF;
    CLOSE cur_min;

    IF (SUBSTR(rec_min.part_serial_no ,1 ,1) = 'T') THEN
      deact_reason  := 'DELETED';
    ELSIF (rec_min.x_part_inst_status = '34') THEN
      deact_reason := 'AC VOIDED';
    ELSE
      deact_reason :=   CASE WHEN UPPER(ip_deactreason) IN ('CANCELFROMSUSPEND'
                                                             ,'CLONED'
                                                             ,'CUSTOMER REQD'
                                                             ,'CUSTOMER REQUESTED'
                                                             ,'DEFECTIVE'
                                                             ,'NO NEED OF PHONE'
                                                             ,'NONUSAGE'
                                                             ,'ONE TIME DEACT'
                                                             ,'PASTDUE'
                                                             ,'REMOVED_FROM_GROUP'
                                                             ,'PORT IN TO NET10'
                                                             ,'PORT IN TO TRACFONE'
                                                             ,'RISK ASSESSMENT'
                                                             ,'SALE OF CELL PHONE'
                                                             ,'SELL PHONE'
                                                             ,'SEQUENCE MISMATCH'
                                                             ,'SIM CHANGE'
                                                             ,'SIM DAMAGE'
                                                             ,'SIM DAMAGED'
                                                             ,'SIM EXCHANGE'
                                                             ,'SL PHONE NEVER RCVD'
                                                             ,'STOLEN'
                                                             ,'STOLEN CREDIT CARD'
                                                             ,'UPGRADE'
                                                             ,'WAREHOUSE PHONE'
                                                             ,'UNITS TRANSFER') THEN 'RESERVED USED'
                               WHEN UPPER(ip_deactreason) IN ('ACTIVE UPGRADE'
                                                             ,'CHANGE OF ADDRESS'
                                                             ,'MINCHANGE'
                                                             ,'NTN'
                                                             ,'OVERDUE EXCHANGE'
                                                             ,'PORT CANCEL'
                                                             ,'PORTED NO A/I'
                                                             ,'SENDCARRDEACT'
                                                             ,'WN-SYSTEM ISSUED') THEN CASE WHEN rec_min.x_line_return_days = 0 THEN 'USED' ELSE 'RETURNED' END
                               WHEN UPPER(ip_deactreason) IN ('PORT OUT'
                                                             ,'ST SIM EXCHANGE') THEN 'RETURNED'
                               WHEN UPPER(ip_deactreason) IN ('NON TO PP LINE') THEN 'NTN'
                               --CR18244 Start kacosta 10/06/2011
                               WHEN UPPER(ip_deactreason) = 'REFURBISHED' THEN CASE WHEN rec_min.x_port_in IN (1 ,2 ,3) THEN
                                                                                      'RESERVED USED'
                                                                                    ELSE
                                                                                      CASE WHEN rec_min.x_line_return_days = 0 THEN
                                                                                             'USED'
                                                                                           ELSE
                                                                                             'RETURNED'
                                                                                           END
                                                                                     END
                               --CR18244 End kacosta 10/06/2011
                               ELSE 'RETURNED' END;
    END IF;
    return deact_reason;
end get_deact_line_status;
--
--
/***********************************************************************************/
/*
/* Name: deactService
/* Description: Ends carrier service for an ESN/MIN combination. Translated
/* from TFLinePart.java in the DeactivateService and
/* DeactivateGSMService method.
/***********************************************************************************/
PROCEDURE deactservice (ip_sourcesystem      IN  VARCHAR2  ,
                        ip_userobjid         IN  VARCHAR2  ,
                        ip_esn               IN  VARCHAR2  ,
                        ip_min               IN  VARCHAR2  ,
                        ip_deactreason       IN  VARCHAR2  ,
                        intbypassordertype   IN  NUMBER    ,
                        ip_newesn            IN  VARCHAR2  ,
                        ip_samemin           IN  VARCHAR2  ,
                        op_return            OUT VARCHAR2  ,
                        op_returnmsg         OUT VARCHAR2  ,
                        ip_brm_enrolled_flag IN  VARCHAR2 DEFAULT 'N') IS

    rec_min   cur_min%ROWTYPE;
    -------------------------------------------------------
    CURSOR cur_ph (c_esn IN VARCHAR2,
                   c_min IN VARCHAR2) IS
      SELECT a.*
            ,a.rowid esn_rowid
            ,(SELECT ct.x_iccid
                FROM sa.table_x_call_trans ct
               WHERE ct.call_trans2site_part = f.objid
                 AND ct.x_iccid IS NOT NULL
                 AND ROWNUM < 2) ct_iccid
            ,(SELECT cr.contact_role2contact
                FROM sa.table_site_part    sp
                    ,sa.table_site         s
                    ,sa.table_contact_role cr
               WHERE 1 = 1
                 AND sp.x_min = c_min
                 AND s.objid = sp.site_part2site
                 AND cr.contact_role2site = s.objid
                 AND cr.contact_role2contact IS NOT NULL
                 AND ROWNUM < 2) alt_contact
            ,c.x_technology
            ,NVL(c.x_restricted_use,0) x_restricted_use
            ,e.objid siteobjid
            ,f.x_iccid sp_iccid
            ,f.service_end_dt
            ,f.x_expire_dt
            ,f.x_deact_reason
            ,f.part_status f_part_status
            ,f.x_notify_carrier
            ,f.objid sitepartobjid
            ,f.x_service_id
            ,f.x_min
            ,f.install_date
            ,f.site_part2x_new_plan
            ,f.site_part2x_plan
            ,f.rowid site_part_rowid
            ,bo.org_id
            ,(SELECT COUNT(1)
                FROM sa.x_program_enrolled c
               WHERE 1 = 1
                 AND c.x_esn = c_esn
                 AND c.x_enrollment_status IN('ENROLLED'
                                             ,'SUSPENDED'
                                             ,'ENROLLMENTPENDING'
                                             ,'ENROLLMENTSCHEDULED')
                 AND ROWNUM < 2) billing_rule_status
        FROM sa.table_part_inst a,
             sa.table_mod_level b,
             sa.table_part_num  c,
             sa.table_bus_org   bo,
             sa.table_inv_bin   d,
             sa.table_site      e,
             sa.table_site_part f
       WHERE 1 = 1
         AND f.part_status != 'Obsolete'
         AND f.x_service_id = a.part_serial_no
         AND f.x_min = c_min
         AND d.bin_name = e.site_id
         AND a.part_inst2inv_bin = d.objid
         AND c.part_num2bus_org = bo.objid
         AND b.part_info2part_num = c.objid
         AND a.n_part_inst2part_mod = b.objid
         AND a.part_serial_no = c_esn
         AND a.x_domain = 'PHONES'
      ORDER BY f.install_date desc;

    rec_ph cur_ph%ROWTYPE;
    -------------------------------------------------------
    CURSOR cur_newesn IS
      SELECT objid
        FROM sa.table_part_inst
       WHERE part_serial_no = LTRIM(RTRIM(ip_newesn))
         AND x_domain = 'PHONES';           --CR48810

    rec_newesn cur_newesn%ROWTYPE;
    -------------------------------------------------------
    CURSOR curremovepromo (c_esnobjid IN NUMBER) IS
      SELECT /*+ INDEX(pg X_PROMOTION_GROUP_OBJINDEX) */
             g2e.*
        FROM sa.table_x_promotion_group pg,
             sa.table_x_group2esn       g2e
       WHERE 1 = 1
         AND pg.objid = g2e.groupesn2x_promo_group + 0
         AND pg.group_name IN('TFU','ANNUALPLAN')
         AND g2e.groupesn2part_inst = c_esnobjid;
    -------------------------------------------------------
    CURSOR currdeactcode (c_deactreason IN VARCHAR2,
                          c_deacttype   IN VARCHAR2) IS
      SELECT *
        FROM sa.table_x_code_table
       WHERE x_code_name = c_deactreason
         AND x_code_type = c_deacttype;
    -------------------------------------------------------
    CURSOR currstatcode (c_statcode IN VARCHAR2,
                         c_codetype IN VARCHAR2) IS
      SELECT *
        FROM sa.table_x_code_table
       WHERE x_code_number = c_statcode
         AND x_code_type = c_codetype;

    reclinestatcode currstatcode%ROWTYPE;
    -------------------------------------------------------
    CURSOR c_ota_features (c_ip_esn_objid IN NUMBER) IS
      SELECT 'X'
        FROM sa.table_x_ota_features
       WHERE x_ota_features2part_inst = c_ip_esn_objid
         AND x_ild_carr_status = 'Active'
         AND ROWNUM < 2;
    -------------------------------------------------------
    cursor check_active_part_to_esn_curs (c_esn_objid in number) IS
      SELECT pi.x_part_inst_status
        FROM sa.table_part_inst pi
       WHERE pi.part_to_esn2part_inst = c_esn_objid
         AND pi.x_part_inst_status = '13'
         AND EXISTS(SELECT 1
                      FROM table_site_part sp
                     WHERE sp.x_min= pi.part_serial_no
                       AND sp.x_service_id = ip_esn
                       AND NVL(sp.part_status,'Obsolete') IN('CarrierPending','Active'))
         AND pi.x_domain = 'LINES';  --CR48810;

    check_active_part_to_esn_rec check_active_part_to_esn_curs%rowtype;
    -------------------------------------------------------
    CURSOR cur_call_trans (in_call_tran_objid IN NUMBER) IS
      SELECT *
        FROM sa.table_x_call_trans
       WHERE objid = in_call_tran_objid;

    rec_call_trans cur_call_trans%rowtype;
    -------------------------------------------------------
    CURSOR cur_ig_trans (in_call_tran_objid IN NUMBER) IS
      SELECT ig.*
        FROM ig_transaction ig,
             sa.table_task t,
             sa.table_x_call_trans ct
       WHERE ct.objid              = in_call_tran_objid
         AND ig.action_item_id     = t.task_id
         AND t.x_task2x_call_trans = ct.objid;

    rec_ig_trans  cur_ig_trans%rowtype;
    -------------------------------------------------------
    c_deactreason       VARCHAR2(1000) := UPPER(ip_deactreason); -- CR54668 Added default value for deactivation reason.
    c_response          VARCHAR2(1000);                          -- CR47564 --WFM
    intcalltranobj      NUMBER := 0;
    intstatcode         NUMBER := 0;
    intactitemobj       NUMBER := 0;
    intordtypeobj       NUMBER := 0;
    intblackoutcode     NUMBER := 0;
    intdummy            NUMBER := 0;
    inttransmethod      NUMBER := 0;
    intgrphistseq       NUMBER := 0;
    strdeacttype        VARCHAR2(30)  := '';
    strrettemp          VARCHAR2(200) := '';
    strsqlerrm          VARCHAR2(200);
    v_action            VARCHAR2(4000);
    v_procedure_name    VARCHAR2(80) := v_package_name || '.DEACTSERVICE()';
    strilderrnum        VARCHAR2(20);
    strilderrstr        VARCHAR2(200);
    op_result           NUMBER;
    op_msg              VARCHAR2(200);
    l_step              NUMBER := 0;
    l_err_code          NUMBER;
    l_err_msg           VARCHAR2(1000);
    op_rim_msg          VARCHAR2(300) := '';    -- CR37046 Start
    op_rim_status       VARCHAR2(30)  := '';    -- CR37046 Start
    c_action_item_id    VARCHAR2(30);
    l_error_code        NUMBER;         -- Added the below variables for delete subscriber call by Arun on 04/10/2015
    l_error_msg         VARCHAR2(1000);
    c_error_code        VARCHAR2(100);
    op_ild_trans_objid  NUMBER;
    op_pgm_enroll_objid NUMBER;
    op_ild_msg          VARCHAR2(300) := '';    -- CR52412
    op_ild_status       VARCHAR2(30)  := '';    -- CR52412
    --CR57251
  IS_PROMO_MIN VARCHAR2(2);
  CTX_REASON VARCHAR2(20);
  --CR57251
    -------------------------------------------------------
    TYPE call_trans IS TABLE OF table_x_ota_transaction.x_ota_trans2x_call_trans%TYPE;
    v_call_trans      call_trans;

    tct_sim           code_table_type := code_table_type();
    tct_esn           code_table_type := code_table_type();
    tct_min           code_table_type := code_table_type();

    -- TW+ Variables
    rc                customer_type;
    c                 customer_type;
    --
    alt               alert_type := alert_type();
    a                 alert_type;

    e_deact_exception EXCEPTION;

    v_old_carrier_mkt table_x_call_trans.x_call_trans2carrier%TYPE; --CR57185
    v_expire_date DATE := NULL; --CR57185
    -------------------------------------------------------
    -- CR54668
    FUNCTION check_deact_reas_exists (lip_deactreason IN VARCHAR2)
    RETURN VARCHAR2 IS
       l_deact_reason VARCHAR2(200) := 'DEFAULT';
    BEGIN
       SELECT deact_reason
         INTO l_deact_reason
         FROM sa.x_deact_reason_config
        WHERE deact_reason = UPPER(TRIM(lip_deactreason));
       RETURN l_deact_reason;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('No Deact Configuration Found - treating as DEFAULT: '||lip_deactreason||' - '||l_deact_reason);
        RETURN l_deact_reason;
    END check_deact_reas_exists;
    -------------------------------------------------------
BEGIN

   c_deactreason := check_deact_reas_exists (ip_deactreason); -- CR54668

   dbms_output.put_line('c_deactreason : '||c_deactreason);

   IF LTRIM(ip_esn) IS NULL THEN

     op_return    := 'true';
     op_returnmsg := 'ESN is null';

     UPDATE sa.table_part_inst
        SET x_part_inst_status  = '17',
            status2x_code_table = (SELECT objid
                                     FROM sa.table_x_code_table
                                    WHERE x_code_number = '17')
      WHERE part_serial_no = ip_min
        AND x_domain = 'LINES';   --CR55336

     INSERT INTO error_table (error_text, error_date, action, key, program_name)
     VALUES (op_returnmsg,
             sysdate,
             'deactservice('|| ip_sourcesystem    ||','||
                               ip_userobjid       ||','||
                               ip_esn             ||','||
                               ip_min             ||','||
                               c_deactreason      ||','||
                               intbypassordertype ||','||
                               ip_newesn          ||','||
                               ip_samemin         ||','||
                               op_return          ||','||
                               op_returnmsg       ||')',
                               ip_min,'SERVICE_DEACTIVATION_CODE_jt.deactservice');

     COMMIT;

     RETURN;

   ELSE

     OPEN cur_ph (ip_esn, ip_min);
     FETCH cur_ph INTO rec_ph;
     IF cur_ph%NOTFOUND THEN
       CLOSE cur_ph;
       op_returnmsg := 'ESN/IMEI is not Valid';
       RAISE e_deact_exception;
     END IF;
     CLOSE cur_ph;

   END IF;

   OPEN cur_min (ip_min, rec_ph.x_technology, c_deactreason);
   FETCH cur_min INTO rec_min;
   IF cur_min%NOTFOUND THEN
     CLOSE cur_min;
     op_returnmsg := 'MIN is not Valid';
     RAISE e_deact_exception;
   END IF;
   CLOSE cur_min;

   IF LTRIM(ip_newesn) IS NOT NULL THEN
     OPEN cur_newesn;
     FETCH cur_newesn INTO rec_newesn;
     IF cur_newesn%FOUND THEN

       v_action := 'Clearing all the reserved lines except the one that is being deactivated';

       dbms_output.put_line('Clearing all the reserved lines except the one that is being deactivated');

       UPDATE sa.table_part_inst
          SET part_to_esn2part_inst = NULL
        WHERE part_to_esn2part_inst = rec_newesn.objid
          AND x_domain || '' = 'LINES'
          AND objid != rec_min.objid;

     END IF;
     CLOSE cur_newesn;
   END IF;

   -- get the table code record for the sim configuration
   tct_min := tct_min.get_min_code_table_config (i_min        => ip_min,
                                                 i_technology => rec_ph.x_technology,
                                                 i_code_name  => c_deactreason,
                                                 i_code_type  => 'LS');

   -- CR38664
   IF (rec_min.x_part_inst_status = '34') THEN

     v_action := 'Updating account_hist of current line';

     UPDATE sa.table_x_account_hist
        SET x_end_date = sysdate
      WHERE account_hist2part_inst = rec_min.objid
        AND (x_end_date IS NULL OR x_end_date = TRUNC(TO_DATE('01/01/1753','MM/DD/YYYY')));

   END IF;

   v_action := 'Updating part_inst of current line';

   UPDATE sa.table_part_inst
   SET    x_part_inst_status    = tct_min.code_number
         ,status2x_code_table   = tct_min.code_table_objid
         ,x_cool_end_date       = DECODE(rec_min.x_cooling_period
                                        ,0
                                        ,x_cool_end_date
                                        ,SYSDATE + rec_min.x_cooling_period)
         ,warr_end_date         = DECODE(rec_min.x_used_line_expire_days
                                        ,0
                                        ,TO_DATE('01/01/1753','mm/dd/yyyy')
                                        ,SYSDATE + rec_min.x_used_line_expire_days)
         ,last_trans_time       = SYSDATE
         ,repair_date           = DECODE((LTRIM(ip_newesn))
                                        ,NULL
                                        ,repair_date
                                        ,SYSDATE)
         ,part_inst2x_pers      = DECODE(part_inst2x_new_pers
                                        ,NULL
                                        ,part_inst2x_pers
                                        ,part_inst2x_new_pers)
         ,part_inst2x_new_pers  = NULL
         ,part_to_esn2part_inst = (CASE
                                     WHEN rec_newesn.objid IS NOT NULL THEN
                                      rec_newesn.objid
                                     WHEN tct_min.code_number = '39' THEN
                                      part_to_esn2part_inst
                                     ELSE
                                      NULL
                                   END)
         ,last_cycle_ct         = SYSDATE + rec_min.x_gsm_grace_period
         ,x_port_in             = DECODE(ip_samemin
                                        ,'true'
                                        ,rec_min.x_port_in
                                        ,(DECODE(rec_min.x_port_in
                                                ,2
                                                ,0
                                                ,rec_min.x_port_in)))
   WHERE ROWID = rec_min.min_rowid;

   dbms_output.put_line('write line hist');

   -- Added logic by Arun on 04/10/2015 to expire the subscriber.
   IF tct_min.expire_subscriber_flag = 'Y' THEN
       sa.SERVICE_PROFILE_PKG.delete_subscriber (i_min              => ip_min,
                                                 i_part_inst_status => tct_min.code_number,
                                                 i_src_program_name => 'SERVICE_DEACTIVATION_CODE_jt',
                                                 i_sourcesystem     => ip_sourcesystem,
                                                 o_err_code         => l_error_code,
                                                 o_err_msg          => l_error_msg);
   END IF;
   --
   IF sa.SERVICE_DEACTIVATION_CODE_jt.writepihistory (ip_userobjid
                                                  ,rec_min.min_rowid
                                                  ,NULL
                                                  ,NULL
                                                  ,NULL
                                                  ,'DEACTIVATE'
                                                  ,rec_ph.sp_iccid) = 1 THEN
     NULL;
   END IF;

   IF UPPER(c_deactreason) = 'SENDCARRDEACT'
      AND rec_ph.x_deact_reason = 'REFURBISHED'
      AND rec_min.x_port_in IN(1 ,2 ,3)
      AND rec_min.x_part_inst_status = '39'
      AND rec_min.part_to_esn2part_inst IS NULL THEN

     NULL;

   ELSE

     v_action := 'Updating active min site_part to inactive';

     dbms_output.put_line('Updating active min site_part to inactive');

     UPDATE sa.table_site_part
        SET service_end_dt       = SYSDATE
           ,x_expire_dt          = CASE
                                     WHEN UPPER(c_deactreason) IN('UPGRADE'
                                                                 ,'ACTIVE UPGRADE'
                                                                 ,'WAREHOUSE PHONE')
                                     THEN SYSDATE
                                     ELSE x_expire_dt
                                   END
           ,x_deact_reason       = c_deactreason
           ,x_notify_carrier     = CASE
                                     WHEN (rec_min.x_port_in IN(1 ,2) OR rec_min.x_line_return_days = 1) THEN
                                       1
                                     ELSE
                                       0
                                   END
           ,part_status          = 'Inactive'
           ,site_part2x_new_plan = NULL
      WHERE x_min = rec_min.part_serial_no
        AND part_status || '' IN('CarrierPending','Active');

   END IF;

   COMMIT;

   -- TW+ Start logic
   rc := customer_type (i_esn => ip_esn);
   c  := rc.retrieve;

   IF UPPER(c_deactreason) = 'RISK ASSESSMENT' AND c.brand_leasing_flag = 'Y' AND c.brand_shared_group_flag = 'Y' THEN

     -- instantiate the alert values
     alt := alert_type (i_esn_part_inst_objid => c.esn_part_inst_objid,
                        i_title               => 'Lease on Risk Assessment Alert');

     -- delete the previous alert row of the same ESN and TITLE
     a := alt.del;

     -- instantiate the alert values
     alt := alert_type (i_esn                 => c.esn,
                        i_type                => 'SQL',
                        i_alert_text          => 'Temporary text.',
                        i_start_date          => SYSDATE,
                        i_end_date            => TO_DATE('31-DEC-2055','DD-MON-YYYY'),
                        i_active              => 1,
                        i_title               => 'Lease on Risk Assessment Alert',
                        i_hotline             => 1,
                        i_user_objid          => ip_userobjid,
                        i_esn_part_inst_objid => c.esn_part_inst_objid,
                        i_modify_stmp         => SYSDATE,
                        i_ivr_script_id       => '8006',
                        i_web_text_english    => NULL,
                        i_web_text_spanish    => NULL,
                        i_tts_english         => '.',
                        i_tts_spanish         => '.',
                        i_cancel_sql          => 'SELECT COUNT(1) FROM sa.x_customer_lease WHERE x_esn = :esn AND lease_status <> ''1005'' ');

     -- call the insert method to insert the alert message
     a := alt.ins;

   END IF;

   -- TW+ End logic

   v_action := 'Creating a call trans record';

   dbms_output.put_line('Creating a call trans record');

   sa.SERVICE_DEACTIVATION_CODE_jt.create_call_trans (rec_ph.sitepartobjid
                                                  ,2
                                                  ,rec_min.part_inst2carrier_mkt
                                                  ,rec_ph.siteobjid
                                                  ,ip_userobjid
                                                  ,rec_ph.x_min
                                                  ,ip_esn
                                                  ,ip_sourcesystem
                                                  ,SYSDATE
                                                  ,NULL
                                                  ,'DEACTIVATION'
                                                  ,c_deactreason
                                                  ,'Completed'
                                                  ,rec_ph.sp_iccid
                                                  ,rec_ph.org_id
                                                  ,intcalltranobj);

   dbms_output.put_line('tct_min.code_name: '||tct_min.code_name);

   IF tct_min.code_name IN('RESERVED USED','USED') THEN
     strdeacttype := 'Suspend';
   ELSIF tct_min.code_name IN('RETURNED') THEN
     strdeacttype := 'Deactivation';
   ELSE
     strdeacttype := '';
   END IF;

   dbms_output.put_line('rec_min.block_deact_exists:'||rec_min.block_deact_exists||' tct_min.code_name:'||tct_min.code_name||' strdeacttype: '||strdeacttype);
   --
   IF rec_min.block_deact_exists = 0 AND tct_min.code_name IS NOT NULL AND strdeacttype IS NOT NULL THEN

     IF ip_sourcesystem = 'PAST_DUE_BATCH' AND UPPER(c_deactreason) = 'SENDCARRDEACT' AND NVL(rec_min.x_block_create_act_item,0) = 1 THEN

       NULL;

     ELSE

       IF (rec_ph.x_part_inst2contact IS NULL) AND (rec_ph.alt_contact IS NULL) THEN
         op_returnmsg := 'Contact Information Can Not be Found';
         RAISE e_deact_exception;
       END IF;

       v_action := 'Creating action_item';

       dbms_output.put_line('Creating action_item');

       igate.sp_create_action_item (NVL(rec_ph.x_part_inst2contact,rec_ph.alt_contact)
                                   ,intcalltranobj
                                   ,strdeacttype
                                   ,intbypassordertype
                                   ,0
                                   ,intstatcode
                                   ,intactitemobj);

       dbms_output.put_line('After Creating action_item:'||intstatcode||' intactitemobj:'||intactitemobj);

       IF (intstatcode = 2) THEN
         op_returnmsg := op_returnmsg || ' The Action Item Has Not Been Created. Please Contact The Line Management Data Adminstrator.';
       ELSIF (intstatcode = 4) THEN
         op_returnmsg := op_returnmsg || ' There is no transmission method set for this carrier.';
       END IF;
       --
       IF NVL(intactitemobj ,0) = 0 THEN

         INSERT INTO error_table (error_text, error_date, action, key, program_name)
         VALUES ('intactintemobj is null',
                 sysdate,
                 'igate.sp_create_action_item('||rec_ph.x_part_inst2contact||','||
                                               intcalltranobj              ||','||
                                               strdeacttype                ||','||
                                               intbypassordertype          ||','||
                                               '0'                         ||','||
                                               intstatcode                 ||','||
                                               intactitemobj               ||');',
                 ip_min,'SERVICE_DEACTIVATION_CODE_jt.deactservice');

         INSERT INTO error_table (error_text, error_date, action, key, program_name)
         VALUES ('intactintemobj is null',
                 sysdate,
                 'deactservice('||  ip_sourcesystem    ||','||
                                    ip_userobjid       ||','||
                                    ip_esn             ||','||
                                    ip_min             ||','||
                                    c_deactreason      ||','||
                                    intbypassordertype ||','||
                                    ip_newesn          ||','||
                                    ip_samemin         ||','||
                                    op_return          ||','||
                                    op_returnmsg       ||')',
                 ip_min,'SERVICE_DEACTIVATION_CODE_jt.deactservice');

         op_returnmsg := 'No Lines Were Deactivated';

       ELSE

         sa.IGATE.sp_determine_trans_method (intactitemobj
                                            ,strdeacttype
                                            ,NULL
                                            ,inttransmethod);

       END IF;
       --
       IF NVL(inttransmethod,0) = 0 THEN

         INSERT INTO error_table (error_text, error_date, action, key, program_name)
         VALUES ('intactintemobj is null',
                 sysdate,
                 'igate.sp_determine_trans_method('||intactitemobj  ||','||
                                                     strdeacttype   ||','||
                                                     'NULL'         ||','||
                                                     inttransmethod ||');',
                 ip_min,'SERVICE_DEACTIVATION_CODE_jt.deactservice');

         op_returnmsg := 'No Lines Were Deactivated';

         INSERT INTO error_table (error_text, error_date, action, key, program_name)
         VALUES ('intactintemobj is null',
                 sysdate,
                 'deactservice('||  ip_sourcesystem    ||','||
                                    ip_userobjid       ||','||
                                    ip_esn             ||','||
                                    ip_min             ||','||
                                    c_deactreason      ||','||
                                    intbypassordertype ||','||
                                    ip_newesn          ||','||
                                    ip_samemin         ||','||
                                    op_return          ||','||
                                    op_returnmsg       ||')',
                 ip_min,'SERVICE_DEACTIVATION_CODE_jt.deactservice');

       END IF;

     END IF;

     IF strdeacttype = 'Suspend' AND rec_min.x_cancel_suspend = 1 THEN
       INSERT INTO sa.x_canceltosuspend (objid
                                        ,x_status
                                        ,x_min
                                        ,x_cancelto_suspend_date
                                        ,x_site_part_objid
                                        ,x_call_trans_objid
                                        ,x_processed_date)
                                 VALUES (sequ_x_canceltosuspend.nextval
                                        ,'PENDING'
                                        ,ip_min
                                        ,SYSDATE + rec_min.x_cancel_suspend_days
                                        ,rec_ph.sitepartobjid
                                        ,intcalltranobj
                                        ,NULL);
     END IF;

   END IF;

   -- I think the following should not end the process just skip the current esn
   OPEN check_esn_curs (ip_esn);
   FETCH check_esn_curs INTO check_esn_rec;
   IF check_esn_curs%FOUND THEN

     CLOSE check_esn_curs;

     op_returnmsg := 'ESN active in site_part with exp date in future';

     INSERT INTO error_table (ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
     VALUES ('check_esn_curs%FOUND',
             sysdate,
             'deactservice('||    ip_sourcesystem    ||','||
                                  ip_userobjid       ||','||
                                  ip_esn             ||','||
                                  ip_min             ||','||
                                  c_deactreason      ||','||
                                  intbypassordertype ||','||
                                  ip_newesn          ||','||
                                  ip_samemin         ||','||
                                  op_return          ||','||
                                  op_returnmsg       ||')',
             ip_min,'SERVICE_DEACTIVATION_CODE_jt.deactservice');

     GOTO lookforotheresns;

   END IF;
   CLOSE check_esn_curs;

   OPEN check_active_part_to_esn_curs (rec_ph.objid);
   FETCH check_active_part_to_esn_curs INTO check_active_part_to_esn_rec;
   IF check_active_part_to_esn_curs%FOUND THEN

     CLOSE check_active_part_to_esn_curs;

     INSERT INTO error_table (error_text, error_date, action, key, program_name)
     VALUES ('check_active_part_to_esn_curs%found',
             sysdate,
             'deactservice('||    ip_sourcesystem    ||','||
                                  ip_userobjid       ||','||
                                  ip_esn             ||','||
                                  ip_min             ||','||
                                  c_deactreason      ||','||
                                  intbypassordertype ||','||
                                  ip_newesn          ||','||
                                  ip_samemin         ||','||
                                  op_return          ||','||
                                  op_returnmsg       ||')',
             ip_min,'SERVICE_DEACTIVATION_CODE_jt.deactservice');

     op_returnmsg := 'ESN active in site_part with exp date in future';

     GOTO lookforotheresns;

   END IF;
   CLOSE check_active_part_to_esn_curs;

   -- is this what we want to do for ild???????????????????
   FOR ota_features_rec IN c_ota_features (rec_ph.objid) LOOP
     sa.sp_ild_transaction (rec_min.part_serial_no
                           ,'ILD_DEACT'
                           ,''
                           ,strilderrnum
                           ,strilderrstr);
   END LOOP;
   --
   -- CR52412 - Adding insert to ILD Trans for deactivation - $10 Auto-Refill ILD
   create_vas_ild_trans (ip_brm_enrolled_flag   => ip_brm_enrolled_flag,
                         ip_esn                 => ip_esn,
                         ip_min                 => ip_min,
                         ip_site_part_objid     => rec_ph.sitepartobjid,
                         ip_org_id              => rec_ph.org_id,
                         ip_call_trans_objid    => intcalltranobj,
                         ip_user_objid          => ip_userobjid,
                         op_ild_trans_objid     => op_ild_trans_objid,
                         op_pgm_enroll_objid    => op_pgm_enroll_objid,
                         op_resp_code           => op_ild_status,
                         op_resp_msg            => op_ild_msg);

   dbms_output.put_line('create_vas_ild_trans.op_ild_trans_objid: ' || op_ild_trans_objid);
   dbms_output.put_line('create_vas_ild_trans.op_resp_msg:        ' || op_ild_msg);
   -- CR52412 - End
   --
   IF rec_ph.sp_iccid IS NOT NULL THEN

    --CR57185 --{
    --Get the carrier of deactivation line from CALL_TRANS (action_type = 1) and pass it to get_sim_code_table_config
    --rec_min.part_inst2carrier_mkt sometimes hold value of new carrier in case of UPGRADE which is incorrect and cant be used here.

    BEGIN --{
     SELECT NVL(x_call_trans2carrier, rec_min.part_inst2carrier_mkt)
     INTO   v_old_carrier_mkt
     FROM   table_x_call_trans ct_main
     WHERE  ct_main.x_service_id =    rec_ph.part_serial_no
     AND    ct_main.objid = ( SELECT MAX(ct_in.objid)
                              FROM   table_x_call_trans ct_in
                              WHERE  ct_in.x_service_id    = ct_main.x_service_id
                              AND    ct_in.x_action_type IN ('1', '3') --Activation or Reactivation
                            )
     AND    ROWNUM <= 1;
    EXCEPTION
    WHEN OTHERS THEN
     v_old_carrier_mkt := rec_min.part_inst2carrier_mkt;
    END; --}
    --CR57185 --}

     -- get the table code record for the sim configuration
     tct_sim := tct_sim.get_sim_code_table_config (i_part_serial_no => rec_ph.part_serial_no,
                                                   i_esn            => rec_ph.x_service_id,
                                                   i_technology     => rec_ph.x_technology,
                                                   i_code_name      => c_deactreason,
                                                   i_code_type      => 'SIM',
                                                   i_carrier_mkt    => v_old_carrier_mkt --CR57185
                                                     );
     --
     v_action := 'Updating SIM information';

     dbms_output.put_line('tct_sim.x_code_number: ' || tct_sim.code_number);

       IF tct_sim.code_number = '253' --NEW status only
       THEN --{ --CR57185

        v_expire_date := calc_sim_exp_date(v_old_carrier_mkt);

        BEGIN --{
         INSERT INTO x_reset_sim_inv
         (
          objid                       ,
          x_sim_serial_no             ,
          x_sim_status                ,
          calltrans_objid             ,
          carrier_objid               ,
          insert_timestamp            ,
          expire_date
         )
         VALUES
         (
          sa.seq_reset_sim_inv.NEXTVAL,
          rec_ph.sp_iccid             ,
          tct_sim.code_number         ,
          intcalltranobj              ,
          v_old_carrier_mkt           ,
          SYSDATE                     ,
          v_expire_date
         );
        EXCEPTION
        WHEN OTHERS THEN
         NULL;
        END; --}
       END IF; --} --CR57185

     UPDATE sa.table_x_sim_inv
     SET    x_sim_inv_status          = tct_sim.code_number,
            x_sim_status2x_code_table = tct_sim.code_table_objid,
            expiration_date           = CASE  --Overwrite expiration date based on parent config. if SIM status is set to reusable status
                                             WHEN tct_sim.code_number = '253'
                                             THEN v_expire_date
                                             ELSE expiration_date
                                        END
     WHERE  x_sim_serial_no = rec_ph.sp_iccid;

     v_action := 'Updating other SIM information';

     UPDATE sa.table_x_sim_inv xsi
     SET    x_sim_inv_status          = tct_sim.code_number,
            x_sim_status2x_code_table = tct_sim.code_table_objid
     WHERE  xsi.x_sim_inv_status = '254'
     AND    EXISTS (SELECT 1
                    FROM sa.table_site_part tsp
                    WHERE tsp.x_iccid = xsi.x_sim_serial_no
                    AND tsp.x_min = rec_min.part_serial_no
                    AND tsp.part_status = 'Inactive' )
     AND    NOT EXISTS (SELECT 1
                        FROM   sa.table_part_inst tpi_esn
                        JOIN   sa.table_site_part tsp
                        ON     tpi_esn.part_serial_no = tsp.x_service_id
                        WHERE  tpi_esn.x_iccid = xsi.x_sim_serial_no
                        AND    tpi_esn.x_domain = 'PHONES' -- CR55336
                        AND    tsp.x_iccid = xsi.x_sim_serial_no
                        AND    tsp.x_min <> rec_min.part_serial_no
                        AND    tsp.part_status IN ('CarrierPending' ,'Active'));

     COMMIT;

   END IF;

   IF c_deactreason = 'SENDCARRDEACT' AND
      rec_ph.x_deact_reason = 'REFURBISHED' AND
      rec_min.x_port_in IN (1 ,2 ,3) AND
      rec_min.x_part_inst_status = '39' AND
      rec_min.part_to_esn2part_inst IS NULL THEN

      INSERT INTO error_table (error_text, error_date, action, key, program_name)
      VALUES ('skip deact site_part',
              sysdate,
              'UPPER(c_deactreason) = SENDCARRDEACT'||
              ' AND rec_ph.x_deact_reason = REFURBISHED'||
              ' AND rec_min.x_port_in IN(1,2,3)'||
              ' AND rec_min.x_part_inst_status = 39'||
              ' AND rec_min.part_to_esn2part_inst IS NULL',
              ip_min,'SERVICE_DEACTIVATION_CODE_jt.deactservice');

      INSERT INTO error_table (error_text, error_date, action, key, program_name)
      VALUES ('skip deact site_part',sysdate,
              'deactservice('||    ip_sourcesystem    ||','||
                                   ip_userobjid       ||','||
                                   ip_esn             ||','||
                                   ip_min             ||','||
                                   c_deactreason      ||','||
                                   intbypassordertype ||','||
                                   ip_newesn          ||','||
                                   ip_samemin         ||','||
                                   op_return          ||','||
                                   op_returnmsg       ||')',
              ip_min,'SERVICE_DEACTIVATION_CODE_jt.deactservice');

      COMMIT;

      RETURN;

   END IF;

   UPDATE sa.table_x_psms_outbox
      SET x_status      = 'Cancelled',
          x_last_update = SYSDATE
    WHERE x_esn = rec_ph.part_serial_no
      AND x_status = 'Pending';

   UPDATE sa.table_x_ota_features
      SET x_ild_account     = NULL,
          x_ild_carr_status = 'Inactive',
          x_ild_prog_status = 'Pending'
    WHERE x_ota_features2part_inst = rec_ph.objid
      AND x_ild_prog_status = 'InQueue';

   IF (UPPER(c_deactreason) IN('UPGRADE','ACTIVE UPGRADE') OR UPPER(c_deactreason) LIKE '%PORTED%')
       AND sa.RIM_SERVICE_PKG.IF_BB_ESN(ip_esn) = 'TRUE' THEN               -- RIM ESN

     OPEN cur_ig_trans (intcalltranobj);
     FETCH cur_ig_trans INTO rec_ig_trans;

     IF cur_ig_trans%NOTFOUND THEN           -- to check that rim is not created during ig

       OPEN cur_call_trans (intcalltranobj);
       FETCH cur_call_trans INTO rec_call_trans;

       IF rec_call_trans.x_action_text = 'DEACTIVATION' THEN

         sa.RIM_SERVICE_PKG.sp_ins_rim_deact_for_upgrade (intcalltranobj,
                                                          ip_min,
                                                          ip_userobjid,
                                                          ip_esn,
                                                          ip_newesn,
                                                          op_rim_msg,
                                                          op_rim_status);

         IF op_rim_status = 'F' THEN
           op_rim_msg := 'Process Failed in sa.sp_insert_ig_transaction_rim inserting into ig_transaction_RIM port_pkg';
           DBMS_OUTPUT.PUT_LINE(op_rim_msg);
           sa.OTA_UTIL_PKG.err_log (P_ACTION       => 'Status F into RIM_SERVICE_PKG.SP_CREATE_ACTION_ITEM. Suspending RIM account for old ESN: '||ip_esn||' ; ip_str_new_esn:'||ip_newesn,
                                    P_ERROR_DATE   => SYSDATE,
                                    P_KEY          => ip_esn ,
                                    P_PROGRAM_NAME => 'VEFIFY_PHONE_UPGRADE_PKG.UPGRADE' ,
                                    P_ERROR_TEXT   => op_rim_msg);
         END IF;

       END IF;

       CLOSE cur_call_trans;

     END IF;

     CLOSE cur_ig_trans;  --CR48810

   END IF;

   -- CR37046
   COMMIT;

   IF rec_ph.billing_rule_status = 1 THEN
     sa.billing_deact_rule_engine (ip_esn
                                  ,c_deactreason
                                  ,ip_userobjid
                                  ,op_result
                                  ,op_msg);
   END IF;

   IF UPPER(c_deactreason) = 'NONUSAGE' THEN
     UPDATE sa.x_nonusage_esns
        SET x_deact_flag = 2,
            x_rundate    = SYSDATE
      WHERE x_esn = rec_ph.x_service_id;
     COMMIT;
   END IF;

   -- get the table code record for the esn configuration
   tct_esn := tct_esn.get_esn_code_table_config (i_code_name  => c_deactreason,
                                                 i_code_type  => 'PS');

   --
   v_action := 'Updating part_inst of ESN';

   UPDATE sa.table_part_inst
      SET x_part_inst_status   = tct_esn.code_number
         ,status2x_code_table  = tct_esn.code_table_objid
         ,last_trans_time      = SYSDATE
         ,x_reactivation_flag  = DECODE(tct_min.value, 2, 1, x_reactivation_flag)
         ,x_part_inst2contact  = DECODE(UPPER(c_deactreason) ,'SL PHONE NEVER RCVD' ,NULL ,x_part_inst2contact)
         ,part_inst2x_new_pers = NULL
    WHERE ROWID = rec_ph.esn_rowid;

   --CR34962 Removing bundle promo link
   sa.BILLING_BUNDLE_PKG.sp_deenroll_bundle_esn (ip_esn        => ip_esn,
                                                 OP_ERROR_CODE => l_err_code,
                                                 OP_ERROR_MSG  => l_err_msg);

   -- Added logic by Juda Pena on 01/13/2015 to expire the account group member when applicable
   IF tct_esn.expire_acct_group_member_flag = 'Y' THEN
     sa.BRAND_X_PKG.expire_account_group (ip_esn      => ip_esn     ,
                                          op_err_code => l_err_code ,
                                          op_err_msg  => l_err_msg  );
   END IF;
   --
   IF sa.SERVICE_DEACTIVATION_CODE_jt.writepihistory (ip_userobjid
                                                  ,rec_ph.esn_rowid
                                                  ,NULL
                                                  ,NULL
                                                  ,NULL
                                                  ,'DEACTIVATE'
                                                  ,rec_ph.sp_iccid) = 1 THEN
     NULL;
   END IF;

   IF UPPER(c_deactreason) = 'SL PHONE NEVER RCVD' THEN
     DELETE sa.table_x_contact_part_inst
      WHERE x_contact_part_inst2part_inst = rec_ph.objid;
   END IF;

   COMMIT;
   --
   v_action := 'Updating click plan hist';
   --
   UPDATE sa.table_x_click_plan_hist
      SET x_end_date = SYSDATE
    WHERE curr_hist2site_part = rec_ph.sitepartobjid
      AND (x_end_date IS NULL OR x_end_date = TRUNC(TO_DATE('01/01/1753' ,'MM/DD/YYYY')));
   --
   v_action := 'Updating Free voice mail';

   UPDATE sa.x_free_voice_mail
      SET x_fvm_status     = 1
         ,x_fvm_number     = NULL
         ,x_fvm_time_stamp = SYSDATE
    WHERE x_fvm_status = 2
      AND free_vm2part_inst = rec_ph.objid;

   v_action := 'Removing Group promos';

   FOR reccurremovepromo IN curremovepromo (rec_ph.objid) LOOP

     SELECT sequ_x_group_hist.nextval
       INTO intgrphistseq
       FROM dual;

     INSERT INTO sa.table_x_group_hist (objid
                                       ,x_start_date
                                       ,x_end_date
                                       ,x_action_date
                                       ,x_action_type
                                       ,x_annual_plan
                                       ,grouphist2part_inst
                                       ,grouphist2x_promo_group)
                                VALUES (intgrphistseq
                                       ,reccurremovepromo.x_start_date
                                       ,reccurremovepromo.x_end_date
                                       ,SYSDATE
                                       ,'REMOVE'
                                       ,reccurremovepromo.x_annual_plan
                                       ,reccurremovepromo.groupesn2part_inst
                                       ,reccurremovepromo.groupesn2x_promo_group);

     DELETE FROM sa.table_x_group2esn
      WHERE objid = reccurremovepromo.objid;

   END LOOP;

   v_action := 'Removing autopay_prc';

   sa.SERVICE_DEACTIVATION_CODE_jt.remove_autopay_prc (rec_ph.part_serial_no
                                                   ,rec_ph.org_id
                                                   ,strrettemp);

   UPDATE sa.table_x_ota_transaction a
      SET x_status = 'COMPLETED',
          x_reason = 'DEACT'
    WHERE x_status = 'OTA PENDING'
      AND x_esn = ip_esn
   RETURNING x_ota_trans2x_call_trans
        BULK COLLECT INTO v_call_trans;

   FOR i IN 1 .. v_call_trans.count LOOP

     UPDATE sa.table_x_call_trans
        SET x_result = 'Completed'
      WHERE objid = v_call_trans(i);

     UPDATE sa.table_x_code_hist
        SET x_code_accepted = 'YES'
      WHERE code_hist2call_trans = v_call_trans(i);

   END LOOP;

   --skip to here if esn is active with other min and continue processing orphan esns
   <<lookforotheresns>>

   v_action := 'Retrieving other active ESN information';

   FOR active_esn_part_inst_rec IN (SELECT tpi_esn.rowid esn_rowid
                                          ,tpi_esn.objid
                                          ,tsp.x_iccid   sp_iccid
                                          ,tpi_esn.part_serial_no esn
                                      FROM sa.table_site_part tsp
                                      JOIN sa.table_part_inst tpi_esn
                                        ON tsp.x_service_id = tpi_esn.part_serial_no
                                     WHERE tsp.x_min = rec_min.part_serial_no
                                       AND tsp.part_status = 'Inactive'
                                       AND tpi_esn.x_part_inst_status = '52'
                                       AND tpi_esn.x_domain = 'PHONES'
                                       AND NOT EXISTS (SELECT 1
                                                         FROM sa.table_site_part tsp_other
                                                        WHERE tsp_other.x_service_id = tpi_esn.part_serial_no
                                                          AND tsp_other.x_min <> rec_min.part_serial_no
                                                          AND tsp_other.part_status IN('CarrierPending','Active'))
                                       AND NOT EXISTS (SELECT 1
                                                         FROM sa.table_part_inst tpi_min
                                                        WHERE tpi_min.part_to_esn2part_inst = tpi_esn.objid
                                                          AND tpi_min.part_serial_no <> rec_min.part_serial_no
                                                          AND tpi_min.x_part_inst_status = '13'
                                                          AND tpi_min.x_domain = 'LINES')) LOOP
     --
     v_action := 'Updating other active ESN';
     --
     UPDATE sa.table_part_inst
        SET x_part_inst_status   = tct_esn.code_number
           ,status2x_code_table  = tct_esn.code_table_objid
           ,last_trans_time      = SYSDATE
           ,x_reactivation_flag  = DECODE(tct_min.value, 2, 1, x_reactivation_flag)
           ,x_part_inst2contact  = DECODE(UPPER(c_deactreason), 'SL PHONE NEVER RCVD', NULL, x_part_inst2contact)
           ,part_inst2x_new_pers = NULL
      WHERE ROWID = active_esn_part_inst_rec.esn_rowid;

     -- Added logic by Juda Pena on 01/13/2015 to expire the account group member when applicable
     IF tct_esn.expire_acct_group_member_flag = 'Y' THEN
       sa.BRAND_X_PKG.expire_account_group (ip_esn      => active_esn_part_inst_rec.esn ,
                                            op_err_code => l_err_code ,
                                            op_err_msg  => l_err_msg);
     END IF;
     --
     v_action := 'Writepihistory other active ESN';
     --
     IF sa.SERVICE_DEACTIVATION_CODE_jt.writepihistory (ip_userobjid
                                                    ,active_esn_part_inst_rec.esn_rowid
                                                    ,NULL
                                                    ,NULL
                                                    ,NULL
                                                    ,'DEACTIVATE'
                                                    ,active_esn_part_inst_rec.sp_iccid) = 1 THEN
       --
       NULL;
       --
     END IF;
     --
     IF UPPER(c_deactreason) = 'SL PHONE NEVER RCVD' THEN
       --
       v_action := 'Delete other active ESN contact';
       --
       DELETE sa.table_x_contact_part_inst
        WHERE x_contact_part_inst2part_inst = active_esn_part_inst_rec.objid;
       --
     END IF;
     --
     COMMIT;
     --
   END LOOP;

   -- CR21077 End Kacosta 07/10/2012 - END LOOP;
   -- CR49058 changes starts..
   -- call vas deenrollment to update the status for VAS

   sa.VAS_MANAGEMENT_PKG.p_deenroll_vas_program (i_esn              =>  ip_esn,
                                                 i_deenroll_reason  =>  c_deactreason,
                                                 o_error_code       =>  c_error_code,
                                                 o_error_msg        =>  l_error_msg);

   -- CR52412 - Update enrolled record to 'READYTOREENROLL' after ILD transaction insert.
   IF op_pgm_enroll_objid IS NOT NULL THEN
     BEGIN
       UPDATE sa.x_program_enrolled
          SET x_enrollment_status = 'READYTOREENROLL'
        WHERE x_enrollment_status = 'ENROLLED'
          AND x_esn = ip_esn
          AND objid = op_pgm_enroll_objid;
     EXCEPTION
       WHEN OTHERS THEN
         dbms_output.put_line('Error while updating table sa.x_program_enrolled with READYTOREENROLL status: ' || SUBSTR(SQLERRM,1,200));
     END;
   END IF;

   -- CR49058 changes ends.
   -- CR47564 --WFM --Start
   IF (ip_esn IS NOT NULL) AND (sa.CUSTOMER_INFO.get_brm_notification_flag (i_esn => ip_esn) = 'Y') THEN

     -- retrive action item id
     BEGIN
       SELECT task_id
         INTO c_action_item_id
         FROM sa.table_task
        WHERE objid = intactitemobj;
     EXCEPTION
       WHEN OTHERS THEN
         c_action_item_id := NULL;
     END;

     sa.ENQUEUE_TRANSACTIONS_PKG.enqueue_deactivation (i_esn               => ip_esn         ,
                                                       i_min               => ip_min         ,
                                                       i_deactreason       => c_deactreason  ,
                                                       i_sourcesystem      => ip_sourcesystem,
                                                       i_action_item_id    => c_action_item_id,
                                                       o_response          => c_response     );

   END IF;
   -- CR47564 --WFM --End
    -- CR57251    NT 35 40 PROMO + ILD benefits for EPIR
        -- To disable promo for the customers upon deactivation
         -- retrive action item id

        BEGIN
              SELECT 'Y' INTO IS_PROMO_MIN FROM sa.X_POLICY_RULE_SUBSCRIBER
              WHERE MIN = ip_min
              AND NVL(INACTIVE_FLAG,'N') = 'N'
              AND COS IN ( SELECT DISTINCT  prc.cos
                              FROM   sa.x_policy_rule_service_plan psp,
                                     sa.x_policy_rule_config prc
                              WHERE  psp.policy_rule_config_objid = prc.objid
                              and   (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y'));
                             -- and   SYSDATE > prc.end_date);
         EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

          BEGIN
                SELECT X_REASON INTO CTX_REASON FROM sa.TABLE_X_CALL_TRANS
                WHERE objid = intcalltranobj;

          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

          IF IS_PROMO_MIN = 'Y' AND ( UPPER(CTX_REASON) NOT IN ('UPGRADE'))  THEN
            BEGIN
              UPDATE sa.X_POLICY_RULE_SUBSCRIBER
              SET INACTIVE_FLAG = 'Y',
              UPDATE_TIMESTAMP = SYSDATE
              WHERE MIN = ip_min
              AND COS IN ( SELECT DISTINCT  prc.cos
                              FROM   sa.x_policy_rule_service_plan psp,
                                     sa.x_policy_rule_config prc
                              WHERE  psp.policy_rule_config_objid = prc.objid
                              and   (nt_35_promo_flag = 'Y' OR nt_40_promo_flag = 'Y'));
            EXCEPTION
              WHEN OTHERS THEN
              NULL;
            END;
          ENd IF;

    -- END CR57251


   op_return    := 'true';
   op_returnmsg := op_returnmsg || ' ' || strrettemp;

   COMMIT;

EXCEPTION
  WHEN e_deact_exception THEN
      IF cur_ph%ISOPEN THEN
        CLOSE cur_ph;
      END IF;
      IF cur_min%ISOPEN THEN
        CLOSE cur_min;
      END IF;
      ROLLBACK;
      op_return := 'false';
      toss_util_pkg.insert_error_tab_proc(v_action || op_returnmsg,ip_esn,v_procedure_name);
      INSERT INTO error_table (error_text, error_date, action, key, program_name)
      VALUES (op_returnmsg,
              sysdate,
              'deactservice('|| ip_sourcesystem    ||','||
                                ip_userobjid       ||','||
                                ip_esn             ||','||
                                ip_min             ||','||
                                c_deactreason      ||','||
                                intbypassordertype ||','||
                                ip_newesn          ||','||
                                ip_samemin         ||','||
                                op_return          ||','||
                                op_returnmsg       ||')',
                  ip_min,'SERVICE_DEACTIVATION_CODE_jt.deactservice');
  WHEN others THEN
      IF cur_ph%ISOPEN THEN
        CLOSE cur_ph;
      END IF;
      IF cur_min%ISOPEN THEN
        CLOSE cur_min;
      END IF;
      strsqlerrm   := SUBSTR(SQLERRM,1,200);
      op_return    := 'false';
      op_returnmsg := v_action||':'||op_returnmsg||':'||strsqlerrm;
      toss_util_pkg.insert_error_tab_proc(v_action,ip_esn,v_procedure_name);
      INSERT INTO error_table (error_text, error_date, action, key, program_name)
      VALUES (op_returnmsg,
              sysdate,
              'deactservice('|| ip_sourcesystem    ||','||
                                ip_userobjid       ||','||
                                ip_esn             ||','||
                                ip_min             ||','||
                                c_deactreason      ||','||
                                intbypassordertype ||','||
                                ip_newesn          ||','||
                                ip_samemin         ||','||
                                op_return          ||','||
                                op_returnmsg       ||')',
                  ip_min,'SERVICE_DEACTIVATION_CODE_jt.deactservice');
END deactservice;
--
--
  /*****************************************************************************/
  /*
  /* Name: WritePiHistory
  /* Description: Inserts new records into table_x_pi_hist
  /*****************************************************************************/
  FUNCTION writepihistory
  (
    ip_userobjid      IN VARCHAR2
   ,ip_part_serial_no IN VARCHAR2
   ,ip_oldnpa         IN VARCHAR2
   ,ip_oldnxx         IN VARCHAR2
   ,ip_oldext         IN VARCHAR2
   ,ip_action         IN VARCHAR2
   ,ip_iccid          IN VARCHAR2
  ) RETURN PLS_INTEGER IS
    v_function_name CONSTANT VARCHAR2(200) := v_package_name || '.insert_pi_hist_fun()';
    table_part_inst_rec table_part_inst%ROWTYPE;
    v_pi_hist_seq       NUMBER;
    -- 06/09/03
    CURSOR c1 IS
      SELECT *
        FROM table_part_inst
       WHERE ROWID = ip_part_serial_no;
  BEGIN
    --OPEN Toss_Cursor_Pkg.table_part_inst_cur (ip_part_serial_no);
    --FETCH Toss_Cursor_Pkg.table_part_inst_cur
    OPEN c1;
    FETCH c1
      INTO table_part_inst_rec;
    CLOSE c1;
    --CLOSE Toss_Cursor_Pkg.table_part_inst_cur;
    --Sp_Seq ('x_pi_hist', v_pi_hist_seq); -- 06/09/03
    SELECT sequ_x_pi_hist.nextval
      INTO v_pi_hist_seq
      FROM dual;
    INSERT INTO table_x_pi_hist
      (objid
      ,status_hist2x_code_table
      ,x_change_date
      ,x_change_reason
      ,x_cool_end_date
      ,x_creation_date
      ,x_deactivation_flag
      ,x_domain
      ,x_ext
      ,x_insert_date
      ,x_npa
      ,x_nxx
      ,x_old_ext
      ,x_old_npa
      ,x_old_nxx
      ,x_part_bin
      ,x_part_inst_status
      ,x_part_mod
      ,x_part_serial_no
      ,x_part_status
      ,x_pi_hist2carrier_mkt
      ,x_pi_hist2inv_bin
      ,x_pi_hist2part_inst
      ,x_pi_hist2part_mod
      ,x_pi_hist2user
      ,x_pi_hist2x_new_pers
      ,x_pi_hist2x_pers
      ,x_po_num
      ,x_reactivation_flag
      ,x_red_code
      ,x_sequence
      ,x_warr_end_date
      ,dev
      ,fulfill_hist2demand_dtl
      ,part_to_esn_hist2part_inst
      ,x_bad_res_qty
      ,x_date_in_serv
      ,x_good_res_qty
      ,x_last_cycle_ct
      ,x_last_mod_time
      ,x_last_pi_date
      ,x_last_trans_time
      ,x_next_cycle_ct
      ,x_order_number
      ,x_part_bad_qty
      ,x_part_good_qty
      ,x_pi_tag_no
      ,x_pick_request
      ,x_repair_date
      ,x_transaction_id
      ,x_msid
      ,x_iccid)
    VALUES
      (v_pi_hist_seq
      ,table_part_inst_rec.status2x_code_table
      ,SYSDATE
      ,ip_action
      ,table_part_inst_rec.x_cool_end_date
      ,table_part_inst_rec.x_creation_date
      ,table_part_inst_rec.x_deactivation_flag
      ,table_part_inst_rec.x_domain
      ,table_part_inst_rec.x_ext
      ,table_part_inst_rec.x_insert_date
      ,table_part_inst_rec.x_npa
      ,table_part_inst_rec.x_nxx
      ,ip_oldext
      ,ip_oldnpa
      ,ip_oldnxx
      ,table_part_inst_rec.part_bin
      ,table_part_inst_rec.x_part_inst_status
      ,table_part_inst_rec.part_mod
      ,table_part_inst_rec.part_serial_no
      ,table_part_inst_rec.part_status
      ,table_part_inst_rec.part_inst2carrier_mkt
      ,table_part_inst_rec.part_inst2inv_bin
      ,table_part_inst_rec.objid
      ,table_part_inst_rec.n_part_inst2part_mod
      ,ip_userobjid
      ,table_part_inst_rec.part_inst2x_new_pers
      ,table_part_inst_rec.part_inst2x_pers
      ,table_part_inst_rec.x_po_num
      ,table_part_inst_rec.x_reactivation_flag
      ,table_part_inst_rec.x_red_code
      ,table_part_inst_rec.x_sequence
      ,table_part_inst_rec.warr_end_date
      ,table_part_inst_rec.dev
      ,table_part_inst_rec.fulfill2demand_dtl
      ,table_part_inst_rec.part_to_esn2part_inst
      ,table_part_inst_rec.bad_res_qty
      ,table_part_inst_rec.date_in_serv
      ,table_part_inst_rec.good_res_qty
      ,table_part_inst_rec.last_cycle_ct
      ,table_part_inst_rec.last_mod_time
      ,table_part_inst_rec.last_pi_date
      ,table_part_inst_rec.last_trans_time
      ,table_part_inst_rec.next_cycle_ct
      ,table_part_inst_rec.x_order_number
      ,table_part_inst_rec.part_bad_qty
      ,table_part_inst_rec.part_good_qty
      ,table_part_inst_rec.pi_tag_no
      ,table_part_inst_rec.pick_request
      ,table_part_inst_rec.repair_date
      ,table_part_inst_rec.transaction_id
      ,table_part_inst_rec.x_msid
      ,ip_iccid);
    IF SQL%ROWCOUNT = 1 THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  EXCEPTION
    WHEN others THEN
      toss_util_pkg.insert_error_tab_proc('Failer inserting swipe'
                                         ,ip_part_serial_no
                                         ,'TOSS_UTIL_PKG.INSERT_PI_HIST_FUN');
      RETURN 0;
  END;
  --
 PROCEDURE sendcarrdeact (l_min in varchar2) IS
    --cwl 2/7/2011 new proc to do sendcarrdeact
    --------------------------------------------------------------------
    v_procedure_name VARCHAR2(50) := 'SERVICE_DEACTIVATION_CODE_JT.sendcarrdeact';
    --------------------------------------------------------------------
    CURSOR user_curs IS
      SELECT objid
        FROM table_user
       WHERE s_login_name = 'SA';
    user_rec user_curs%ROWTYPE;
    CURSOR c1 IS
      SELECT pi_min.rowid                 min_rowid
            ,pi_min.part_serial_no        MIN
            ,pi_min.part_inst2carrier_mkt
             --CR18244 Start kacosta 11/7/2011
            ,pi_min.x_part_inst_status
            ,pi_min.part_to_esn2part_inst
      --CR18244 End kacosta 11/7/2011
        FROM table_part_inst pi_min
       WHERE 1 = 1
         AND pi_min.x_part_inst_status IN ('37'
                                          ,'39')
         and pi_min.part_serial_no =l_min
         AND pi_min.last_cycle_ct < TRUNC(SYSDATE)
         AND pi_min.last_cycle_ct > TRUNC(SYSDATE) - 30;

    CURSOR sp_curs(c_min IN VARCHAR2) IS
      SELECT sp.*
        FROM table_site_part sp
       WHERE sp.objid = (SELECT MAX(sp2.objid) max_sp_objid
                           FROM table_site_part sp2
                          WHERE sp2.x_min = c_min
                            AND sp2.part_status = 'Inactive');
    sp_rec sp_curs%ROWTYPE;
    CURSOR sp_active_curs(c_min IN VARCHAR2) IS
      SELECT sp.*
        FROM table_site_part sp
       WHERE sp.x_min = c_min
         AND sp.part_status IN ('Carrier Pending'
                               ,'Active')
       ORDER BY sp.objid DESC;
    sp_active_rec sp_active_curs%ROWTYPE;
    CURSOR esn_curs(c_esn IN VARCHAR2) IS
      SELECT part_serial_no
            ,objid
             --CR18244 Start kacosta 11/7/2011
            ,x_part_inst_status
      --CR18244 End kacosta 11/7/2011
        FROM table_part_inst
       WHERE part_serial_no = c_esn
         AND x_domain = 'PHONES';
    esn_rec esn_curs%ROWTYPE;

    l_return_code VARCHAR2(200);
    l_return_msg  VARCHAR2(200);

  BEGIN
    OPEN user_curs;
    FETCH user_curs
      INTO user_rec;
    CLOSE user_curs;
    FOR c1_rec IN c1 LOOP
      dbms_output.put_line('sendcarrdeact:1:' || c1_rec.min);
      OPEN sp_active_curs(c1_rec.min);
      FETCH sp_active_curs
        INTO sp_active_rec;
      IF sp_active_curs%FOUND
         AND sp_active_rec.x_service_id IS NOT NULL THEN
        dbms_output.put_line('sendcarrdeact:2');
        OPEN esn_curs(sp_active_rec.x_service_id);
        FETCH esn_curs
          INTO esn_rec;
        IF esn_curs%FOUND THEN
          dbms_output.put_line('sendcarrdeact:3');
          UPDATE table_part_inst
             SET x_part_inst_status    = '13'
                ,status2x_code_table  =
                 (SELECT objid
                    FROM table_x_code_table
                   WHERE x_code_number = '13')
                ,part_to_esn2part_inst = esn_rec.objid
           WHERE ROWID = c1_rec.min_rowid;
          COMMIT;
          CLOSE esn_curs;
          CLOSE sp_active_curs;
          GOTO skipthisrecord;
        END IF;
        CLOSE esn_curs;
      END IF;
      CLOSE sp_active_curs;
      dbms_output.put_line('sendcarrdeact:4');
      OPEN sp_curs(c1_rec.min);
      FETCH sp_curs
        INTO sp_rec;
      IF sp_rec.x_service_id IS NULL
         OR sp_curs%NOTFOUND
         OR c1_rec.part_inst2carrier_mkt IS NULL THEN
        dbms_output.put_line('sendcarrdeact:5');
        UPDATE table_part_inst
           SET x_part_inst_status    = '17'
              ,status2x_code_table  =
               (SELECT objid
                  FROM table_x_code_table
                 WHERE x_code_number = '17')
              ,part_to_esn2part_inst = NULL
         WHERE ROWID = c1_rec.min_rowid;
        COMMIT;
      ELSE
        dbms_output.put_line('sendcarrdeact:6');
        OPEN esn_curs(sp_rec.x_service_id);
        FETCH esn_curs
          INTO esn_rec;
        IF esn_curs%NOTFOUND THEN
          dbms_output.put_line('sendcarrdeact:7');
          UPDATE table_part_inst
             SET x_part_inst_status    = '17'
                ,status2x_code_table  =
                 (SELECT objid
                    FROM table_x_code_table
                   WHERE x_code_number = '17')
                ,part_to_esn2part_inst = NULL
           WHERE ROWID = c1_rec.min_rowid;
          COMMIT;
        ELSE
          dbms_output.put_line('sendcarrdeact:8');
          sa.SERVICE_DEACTIVATION_CODE_jt.deactservice('PAST_DUE_BATCH'
                                                   ,user_rec.objid
                                                   ,sp_rec.x_service_id
                                                   ,sp_rec.x_min
                                                   ,'SENDCARRDEACT'
                                                   ,0
                                                   ,NULL
                                                   ,'RETURNMIN'
                                                   ,l_return_code
                                                   ,l_return_msg);
          COMMIT;
        END IF;
        CLOSE esn_curs;
      END IF;
      CLOSE sp_curs;
      dbms_output.put_line('l_return_code:' || l_return_code);
      dbms_output.put_line('l_return_msg:' || l_return_msg);
      IF l_return_code = 'false' THEN
        sa.toss_util_pkg.insert_error_tab_proc('failed to unreserve a reserved line'
                                              ,c1_rec.min
                                              ,v_procedure_name);
      END IF;
      <<skipthisrecord>>
      l_return_code := NULL;
      l_return_msg  := NULL;
    END LOOP;
  END SENDCARRDEACT;
/*
CR33199: Modified the code and checking expired cdma sims for Verizion only
*/
PROCEDURE expirecdmasims(
    op_result OUT NUMBER,
    op_msg OUT VARCHAR2 )
IS
  CURSOR cur_cdma_sims_to_expire IS
 SELECT
        /*+ ORDERED use_nl(si)*/
       sp.state_value,
       n.x_param_name,
       pn.x_technology,
       sp.x_iccid,
       pn.part_number,
         (select CARRIER_NAME
          from
               table_mod_level ml2,
               table_part_num pn2,
               carriersimpref csp
         where 1=1
           and ml2.objid = si.x_sim_inv2part_mod
           and pn2.objid = ml2.part_info2part_num
           and csp.sim_profile = pn2.part_number
           and rownum <2) carrier_name,
        trunc(sp.service_end_dt) service_end_dt
  FROM table_site_part sp ,
       table_x_sim_inv si ,
       table_mod_level ml,
       table_part_num pn,
       table_x_part_class_values v,
       table_x_part_class_params n
 WHERE 1                            =1
    AND NVL(sp.PART_STATUS,'Obsolete') = 'Inactive'
 AND sp.service_end_dt BETWEEN TRUNC(sysdate) - 370 AND trunc(sysdate) -365
   -- AND NVL(sp.X_EXPIRE_DT,TO_DATE('1753-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss')) BETWEEN TRUNC(sysdate) - 370 AND trunc(sysdate) -365
   AND sp.x_iccid                  IS NOT NULL
   AND NVL(sp.state_value,'BLANK') != 'GSM'
   AND si.x_sim_serial_no           = sp.x_iccid
   AND si.x_sim_inv_status||'' = '253'
   AND ml.objid            = sp.site_part2part_info
   AND pn.objid            = ml.part_info2part_num
   and pn.x_technology     = 'CDMA'
   AND v.value2part_class  = pn.part_num2part_class
   AND v.x_param_value     = 'REMOVABLE'
   AND n.objid             = v.value2class_param
   AND n.x_param_name      = 'CDMA LTE SIM'
   AND NOT EXISTS (SELECT 1
                     FROM table_part_inst pi,
                          table_site_part sp2
                    WHERE pi.x_iccid     = sp.x_iccid
                      AND pi.x_domain = 'PHONES'  -- CR55336
                      AND sp2.x_service_id = pi.part_serial_no||''
                      AND sp2.x_iccid||''      = pi.x_iccid||''
                      AND sp2.install_date > sp.install_date)
   and exists(select CARRIER_NAME
                from
                     table_mod_level ml2,
                     table_part_num pn2,
                     carriersimpref csp
               where 1=1
                 and ml2.objid = si.x_sim_inv2part_mod
                 and pn2.objid = ml2.part_info2part_num
                 and csp.sim_profile = pn2.part_number
                               and csp.carrier_name like 'VERIZON%'); --CR33199 for verizon sims only

   rec_cdma_sims_to_expire cur_cdma_sims_to_expire%rowtype;
  CURSOR cur_sim_expired_code
  IS
  SELECT x_code_number, objid
  FROM table_x_code_table
  WHERE x_code_name = 'SIM EXPIRED'
  AND x_code_type   = 'SIM';
  rec_sim_expired_code   cur_sim_expired_code%rowtype;
  l_error_msg VARCHAR2(1000);
  l_counter number;
BEGIN
  op_result := 0;
  op_msg    := 'Success. SIMs expired.';
  l_counter := 0;

  OPEN cur_sim_expired_code;
  FETCH cur_sim_expired_code INTO rec_sim_expired_code;
  CLOSE cur_sim_expired_code;
  FOR rec_cdma_sims_to_expire IN cur_cdma_sims_to_expire
  LOOP
    l_counter := l_counter + 1;
    UPDATE table_x_sim_inv
    SET x_sim_inv_status   = rec_sim_expired_code.x_code_number,
        x_last_update_date = SYSDATE,
        x_sim_status2x_code_table = rec_sim_expired_code.objid
    WHERE x_sim_serial_no = rec_cdma_sims_to_expire.x_iccid;
          IF l_counter = 1000 THEN
            COMMIT;
          END IF;
  END LOOP;
  COMMIT;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  op_result := 0;
  op_msg    := 'No CDMA LTE SIMs to expire.';
WHEN OTHERS THEN
  l_error_msg := SQLCODE || sqlerrm;
  INSERT
  INTO error_table
    (
      error_text,
      error_date,
      action,
      KEY,
      program_name
    )
    VALUES
    (
      l_error_msg,
      sysdate,
      NULL,
      NULL,
      'SERVICE_DEACTIVATION_CODE_jt.expirecdmasims'
    );
  COMMIT;
  op_result := 1;
  op_msg    := 'Failed. Check error_table.';
END expirecdmasims;
--
--
FUNCTION calc_sim_exp_date (carrier_objid NUMBER) --CR57185
RETURN DATE
IS
 v_exp_date DATE := NULL;
BEGIN --{
 BEGIN --{
  SELECT TRUNC(SYSDATE) + p.deact_sim_exp_days
  INTO   v_exp_date
  FROM   table_x_parent p,
         table_x_carrier_group cg,
         table_x_carrier c
  WHERE  1 = 1
  AND    p.objid  = cg.x_carrier_group2x_parent
  AND    cg.objid = c.carrier2carrier_group
  AND    c.objid  = carrier_objid
  AND    p.deact_sim_exp_days IS NOT NULL
  AND    ROWNUM   <= 1;
 EXCEPTION
  WHEN OTHERS THEN
   v_exp_date := NULL;
 END; --}

 RETURN v_exp_date;

EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END calc_sim_exp_date; --}


END SERVICE_DEACTIVATION_CODE_jt;
/