CREATE OR REPLACE PACKAGE BODY sa."VERIFY_PHONE_UPGRADE_PKG" AS
 /*****************************************************************************************************/
 /* NAME: SA.verify_phone_upgrade_pkg */
 /* PURPOSE: */
 /* REVISIONS: */
 /* Ver Date Author Description */
 /* --------- ---------- -------- --------------------------------- */
 /* 1.09 11/20/2006 IC ZH Initial revision */
 /* From Class: com.tracfone.clarify.cbo.TFLinePart.java */
 /* Methods: verifyPhoneUpgrade() and verifyPortin() */
 /* 1.10 02/16/07 IC Fix problems related to the technology exchange */
 /* 1.11 03/6/07 IC Fix problems related to sims */
 /* 1.12 03/9/07 IC v_pi_objid variable changed to number
 /* 1.13 03/22/07 IC Change INT_PORT_IN to AUTO_PORT_IN as per Oleg */
 /* 1.14 04/07/07 IC needed to check for bad sims before checking compatibility */
 /* 1.15 04/09/07 IC close new cursor */
 /* 1.16 04/10/07 IC Change AUTO_PORT_IN back to INT_PORT_IN as per Oleg */
 /* 1.16 04/10/07 IC moved no carrier to v_carrier_id when a carrier was found before other error detected */
 /* 1.17 04/11/07 IC mod 1.14 changed error number to 9991 */
 /* 1.18 04/12/07 IC check sim compatibility after carrirer and zon are verified */
 /* 1.19 04/12/07 IC if parent carriers are same use x_change_reason 'ESN EXCHANGE' */
 /* 1.20 04/13/07 IC mod 1.17 changed error number back to 9990 */
 /* 1.21 04/13/07 IC mod 1.19 changed query to carrier level from parent level */
 /* 1.22 04/14/07 VA/IC fix to defect 293 wrong carrirer was being checked for exchange type logging
 /* 1.23 04/25/07 NG Unreserved other lines linked to target ESN
 /* 1.24 04/25/07 IC CR6125 DOBSON added check for x_auto_port_out=x_auto_port_in
 /* 1.25-1.31 04/27/07 NG Bug Fix CR6125 Dobson
 /* 1.32/1.33/1.34 08/28/07 CL Fix for CR6623
 /* 1.35 08/28/07 CL Fix for personality (CR6623)
 ------------New_PLSQL PVCS structure
 /* 1.2 01/23/08 CL CR6578
 /* 1.3 02/16/08 VA CR6488 - fix defect #209 opened against requirement #6
 /* 1.4 04/18/08 VA TMODATA- Latest code merged with TMODATA
 /* 1.8 10/22/08 NG TMOPORT - Flag MIN and x_port_in = 3 for CROSS COMPANY
 /* 1.9 08/26/09 NG BRAND_SEP - modify CUR_CONTACT_ID from using x_restricted_use to table_bus_org value
 /* -----------New CVS structure
 /* 1.2 04/30/10 NG CR10777 zip code activation-phase 1
 /* 1.4 05/02/11 CL CR16197
 /* 1.7 07/14/11 CL CR17118 Minor Adjustment - Verify Package */
 /* 1.8 08/04/11 PM CR13249 ST GSM Upgrade
 /* 1.10 07/04/12 IC CR20451 | CR20854: Add TELCEL Brand
 /**************************************************************************************************************/
--
--
 --CR38885
 CURSOR safelink_curs (c_old_esn IN VARCHAR2,
                       c_new_esn IN VARCHAR2)
 IS
 SELECT /*+ ORDERED */
        CAST('FOUND' AS VARCHAR2(100)) x_safelink
   FROM sa.table_part_inst pi_old,
        sa.table_mod_level ml_old,
        sa.table_part_num pn_old,
        sa.table_part_inst pi_new,
        sa.table_mod_level ml_new,
        sa.table_part_num pn_new,
        sa.x_sl_currentvals cv,
        sa.x_program_enrolled pe,
        sa.x_program_parameters pr
  WHERE 1=1
    AND pi_old.part_serial_no = c_old_esn
    AND pi_old.x_domain = 'PHONES'
    AND ml_old.objid = pi_old.n_part_inst2part_mod
    AND pn_old.objid = ml_old.part_info2part_num
    AND pi_new.part_serial_no = c_new_esn
    AND pi_new.x_domain = 'PHONES'
    AND ml_new.objid = pi_new.n_part_inst2part_mod
    AND pn_new.objid = ml_new.part_info2part_num
    AND pn_new.part_num2bus_org = pn_old.part_num2bus_org
    AND cv.x_current_esn = pi_old.part_serial_no
    AND cv.x_current_esn = pe.x_esn
    AND pe.x_enrollment_status ='ENROLLED'
    AND pe.pgm_enroll2pgm_parameter = pr.objid
    AND pr.x_prog_class = 'LIFELINE';

 --CR41433
 safelink_rec safelink_curs%ROWTYPE;

--CR38885
 CURSOR cur_contact_id (ip_str_old_esn IN VARCHAR2)
 IS
 SELECT objid
   FROM sa.table_contact
  WHERE objid IN (SELECT x_part_inst2contact
                    FROM sa.table_part_inst
                   WHERE part_serial_no = ip_str_old_esn);

 -- get New ESN details
 CURSOR cur_esn_details (ip_str_new_esn IN VARCHAR2)
 IS
 SELECT pi.x_part_inst_status,
        pn.x_technology,
        pi.objid,
        bo.org_id,
        pi.x_iccid,
        NVL((SELECT v.x_param_value
               FROM sa.table_x_part_class_values v,
                    sa.table_x_part_class_params n
              WHERE 1=1
                AND v.value2part_class = pn.part_num2part_class
                AND v.value2class_param = n.objid
                AND n.x_param_name = 'CDMA LTE SIM'
                AND ROWNUM < 2),
            'NON REMOVABLE') cdma_sim_type
   FROM sa.table_part_num pn,
        sa.table_mod_level ml,
        sa.table_part_inst pi,
        sa.table_bus_org bo
  WHERE pn.objid = ml.part_info2part_num
    AND pi.n_part_inst2part_mod = ml.objid
    AND pi.x_domain = 'PHONES'
    AND pi.part_serial_no = ip_str_new_esn
    AND pn.part_num2bus_org = bo.objid;

 CURSOR new_esn_tech_curs (c_esn IN VARCHAR2)
 IS
 SELECT prt_num.x_technology,
        NVL((SELECT v.x_param_value
               FROM sa.table_x_part_class_values v,
                    sa.table_x_part_class_params n
              WHERE 1 = 1
                AND v.value2part_class = prt_num.part_num2part_class
                AND v.value2class_param = n.objid
                AND n.x_param_name = 'CDMA LTE SIM'
                AND ROWNUM <2), 'NON REMOVABLE') cdma_sim_type,
        (CASE
         WHEN EXISTS (SELECT 1
                        FROM sa.table_x_frequency f,
                             sa.mtm_part_num14_x_frequency0 pf
                       WHERE 1 = 1
                         AND pf.x_frequency2part_num = f.objid
                         AND pf.x_frequency2part_num = f.objid
                         AND f.x_frequency = 800)
         THEN 800
         ELSE 0
         END) x_frequency1,
        (CASE
         WHEN EXISTS (SELECT 1
                        FROM table_x_frequency f,
                             sa.mtm_part_num14_x_frequency0 pf
                       WHERE 1 = 1
                         AND pf.x_frequency2part_num = f.objid
                         AND prt_num.objid = pf.part_num2x_frequency
                         AND f.x_frequency = 1900)
         THEN 1900
         ELSE 0
         END) x_frequency2,
        NVL(prt_num.x_meid_phone, 0) x_meid_phone,
        (SELECT COUNT(1) sr
           FROM sa.table_x_part_class_values v,
                sa.table_x_part_class_params n
          WHERE 1 = 1
            AND v.value2part_class = prt_num.part_num2part_class
            AND v.value2class_param = n.objid
            AND n.x_param_name = 'NON_PPE'
            AND v.x_param_value IN ('0', '1') --CR17118
            AND ROWNUM < 2) non_ppe,
        prt_num.x_dll,
        NVL((SELECT V.x_param_value
               FROM sa.table_x_part_class_values V,
                    sa.table_x_part_class_params N
              WHERE 1 = 1
                AND V.value2part_class = prt_num.part_num2part_class
                AND V.value2class_param = N.objid
                AND N.x_param_name = 'DATA_SPEED'
                AND ROWNUM < 2), NVL(prt_num.x_data_capable, 0)) data_speed,
        (SELECT bo.objid         -- cwl 5/1/2011 ---CR16197
           FROM sa.table_bus_org bo
          WHERE bo.objid = prt_num.part_num2bus_org) bus_org_objid
   FROM sa.table_part_num prt_num,    --CR17118
        sa.table_mod_level ml,
        sa.table_part_inst pi
  WHERE prt_num.objid = ml.part_info2part_num
    AND pi.n_part_inst2part_mod = ml.objid
    AND pi.x_domain = 'PHONES'
    AND pi.part_serial_no = c_esn;

 new_esn_tech_rec new_esn_tech_curs%ROWTYPE;

 -- Verify SIM combination GSM Enhancements
 -- the sim status is it attached to the phone?
 CURSOR cur_new_profile (ip_str_iccid IN VARCHAR2)
 IS
 SELECT substr (part_number, 1, LENGTH(part_number) - 1) str_new_profile
   FROM sa.table_x_sim_inv,
        sa.table_part_num,
        sa.table_mod_level
  WHERE x_sim_serial_no = ip_str_iccid
    AND x_sim_inv_status = '253'
    AND part_info2part_num = table_part_num.objid
    AND x_sim_inv2part_mod = table_mod_level.objid;

 -- Start CR13249 PM ST GSM Upgrade 07/26/2011
 -- Verify SIM is valid CR5150 4/7/07 needed to check the status of the sim
 -- Added status check condition in code body.
 CURSOR cur_checksim (ip_str_iccid IN VARCHAR2)
 IS
 SELECT pn.s_part_number,
        si.x_sim_inv_status
   FROM sa.table_part_num pn,
        sa.table_mod_level ml,
        sa.table_x_sim_inv si
  WHERE pn.objid = ml.part_info2part_num
    AND ml.objid = si.x_sim_inv2part_mod
    AND si.x_sim_serial_no = ip_str_iccid;

 -- Verify new and old SIM have the same profile
 -- Check if the zone is being changed.
 CURSOR cur_smart_ph_check (c_esn VARCHAR2)
 IS
 SELECT pi.part_serial_no,
        bo.org_id,
        pn.x_technology,
        pc.name,
        sa.get_param_by_name_fun (pc.name ,'NON_PPE') non_ppe_flag,
        pi.x_iccid,
        bo.org_flow         -- CR20451 | CR20854: Add TELCEL Brand
   FROM sa.table_part_inst pi,
        sa.table_mod_level ml,
        sa.table_part_num pn,
        sa.table_part_class pc,
        sa.table_bus_org bo
  WHERE ml.objid = pi.n_part_inst2part_mod
    AND pn.objid = ml.part_info2part_num
    AND pc.objid = pn.part_num2part_class
    AND bo.objid = pn.part_num2bus_org
    AND pi.part_serial_no = c_esn;

 -- End CR13249 PM ST GSM Upgrade 07/26/2011
 CURSOR cur_zipcode (ip_str_old_esn IN VARCHAR2)
 IS
 SELECT x_zipcode
   FROM sa.table_site_part
  WHERE x_service_id = ip_str_old_esn
    AND part_status = 'Active';

 -- Get the carrier id and personality
 CURSOR cur_carrier (c_old_esn IN VARCHAR2)
 IS
 SELECT sp.x_zipcode,
        p.x_parent_name,
        carr.x_carrier_id,
        carr.objid,
        carr.carrier2personality,
        line.objid min_objid,
        sp.x_min,
        NVL (p.x_auto_port_out, 0) x_auto_port_out,
        NVL (cg.x_no_auto_port, 0) x_no_auto_port,
        NVL (P.x_block_port_in, 0) x_block_port_in
   FROM sa.table_x_parent p,
        sa.table_x_carrier_group cg,
        sa.table_x_carrier carr,
        sa.table_part_inst line,
        sa.table_site_part sp
  WHERE p.objid = cg.x_carrier_group2x_parent
    AND cg.objid = carr.carrier2carrier_group
    AND carr.objid = line.part_inst2carrier_mkt
    AND line.part_serial_no = sp.x_min
    AND sp.x_service_id = c_old_esn
    AND sp.part_status||'' = 'Active';

 -- Check if the current carrier allows port out x_no_auto_port added
 -- CR10777
 CURSOR cur_possible_carriers (c_new_zip             IN VARCHAR2,
                               c_old_zip             IN VARCHAR2,
                               c_parent_name         IN VARCHAR2,
                               c_tech                IN VARCHAR2,
                               c_phone_freq1         IN NUMBER,
                               c_phone_freq2         IN NUMBER,
                               c_carrier_mkt_objid   IN NUMBER,
                               c_auto_port_out       IN NUMBER,
                               c_sim_profile         IN VARCHAR2,
                               c_meid_phone          IN NUMBER,
                               c_phone               IN VARCHAR2,
                               c_non_ppe             IN NUMBER,
                               c_dll                 IN NUMBER, --CR17118
                               c_bus_org_objid       IN NUMBER,
                               c_data_speed          IN NUMBER,
                               c_safelink            IN VARCHAR2,
                               c_cdma_sim_type       IN VARCHAR2)
 IS
      SELECT DISTINCT cd.x_dealer_id,
             ca.objid carrier_objid,
             ca.x_carrier_id,
             ca.carrier2personality,
             P.x_auto_port_in,
             cg.x_no_auto_port,
             P.x_block_port_in,
             P.x_parent_name,
             tab2.carrier_id pref_carr_id,
             tab2.new_rank,
             tab2.sim_profile,
             tab2.sim_profile pref_sim_profile,
             (SELECT (CASE
                        WHEN cf.x_switch_base_rate IS NOT NULL THEN 1
                        ELSE 0
                      END) sr
                FROM table_x_carrier_features cf
               WHERE cf.x_feature2x_carrier = ca.objid
                 AND ROWNUM < 2) non_ppe,
             (CASE
                WHEN P.x_parent_name=c_parent_name THEN 1
                ELSE 0
              END) same_parent,
             (CASE
               WHEN P.x_parent_name='CINGULAR'
               AND c_parent_name='CINGULAR'
               THEN (SELECT COUNT(*)
                       FROM (SELECT mkt,
                                    rc_number
                               FROM sa.x_cingular_mrkt_info
                              WHERE zip  =c_old_zip
                             INTERSECT SELECT mkt,
                                              rc_number
                                         FROM sa.x_cingular_mrkt_info
                        WHERE zip  =c_new_zip
                     )
                  WHERE ROWNUM<2
               )
               WHEN P.x_parent_name LIKE '%SPRINT%'
               AND
                  c_parent_name LIKE '%SPRINT%'
               THEN 1
               WHEN P.x_parent_name LIKE '%VERIZON%'
               AND
                  c_parent_name LIKE '%VERIZON%'
               THEN 1
               WHEN P.x_parent_name LIKE 'T-MO%'
               AND
                  c_parent_name LIKE 'T-MO%'
               THEN 1
               WHEN P.x_parent_name=c_parent_name
               AND
                  EXISTS (
                     SELECT b.STATE,
                            b.ZONE
                     FROM npanxx2carrierzones b,
                          carrierzones A
                     WHERE 1=1
                        AND
                           b.carrier_id  =(
                              SELECT c2.x_carrier_id
                              FROM table_x_carrier c2
                              WHERE c2.objid  =c_carrier_mkt_objid
                           )
                        AND
                           b.STATE       =A.st
                        AND
                           b.ZONE        =A.ZONE
                        AND
                           A.zip         =c_old_zip
                     INTERSECT SELECT b.STATE,
                            b.ZONE
                     FROM npanxx2carrierzones b,
                          carrierzones A
                     WHERE 1=1
                        AND
                           b.carrier_id  =ca.x_carrier_id
                        AND
                           b.STATE       =A.st
                        AND
                           b.ZONE        =A.ZONE
                        AND
                           A.zip         =c_new_zip
                  )
               THEN 1
               ELSE 0
            END
         ) same_zone,
             (
            CASE
               WHEN P.x_block_port_in=0
               AND
                  c_auto_port_out=0
               AND
                  P.x_auto_port_in IN (
                     0, 1, 2
                  )
               THEN 1
               WHEN P.x_block_port_in=0
               AND
                  c_auto_port_out=1
               AND
                  P.x_auto_port_in IN (
                     0, 2
                  )
               THEN 1
               WHEN P.x_block_port_in=0
               AND
                  c_auto_port_out=2
               AND
                  P.x_auto_port_in IN (
                     0, 1
                  )
               THEN 1
               ELSE 0
            END
         ) manual_port
      FROM table_x_parent P,
           table_x_carrier_group cg,
           table_x_carrier ca,
           table_x_carrierdealer cd,
           (
            SELECT NVL(
                  (
                     SELECT V.x_param_value
                     FROM table_mod_level ml,
                          table_part_num pn,
                          table_x_part_class_values V,
                          table_x_part_class_params N
                     WHERE 1=1
                        AND
                           ml.objid             =pi.n_part_inst2part_mod
                        AND
                           pn.objid             =ml.part_info2part_num
                        AND
                           V.value2part_class   =pn.part_num2part_class
                        AND
                           V.value2class_param  =N.objid
                        AND
                           N.x_param_name       ='PHONE_GEN'
                        AND
                           ROWNUM<2
                  ),
                  '2G'
               ) phone_gen,
                   pi.x_part_inst_status
            FROM table_part_inst pi
            WHERE 1=1
               AND
                  pi.part_serial_no  =c_phone
               AND
                  pi.x_domain        ='PHONES'
         ) pi_tab,
           (
            SELECT MIN(to_number(cp.new_rank) ) new_rank,
                   b.carrier_id,
                   A.sim_profile,
                   A.min_dll_exch,
                   A.max_dll_exch
            FROM carrierpref cp,
                 npanxx2carrierzones b,
                 (
                  SELECT DISTINCT A.ZONE,
                         A.st,
                         S.sim_profile,
                         A.county,
                         S.min_dll_exch,
                         S.max_dll_exch,
                         S.RANK
                  FROM carrierzones A,
                       carriersimpref S
                  WHERE A.zip           =c_new_zip
                     AND
                        A.carrier_name  =S.carrier_name
                     AND
                        c_dll BETWEEN S.min_dll_exch AND S.max_dll_exch
                  ORDER BY S.RANK ASC
               ) A
            WHERE 1=1
               AND
                  cp.st          =b.STATE
               AND
                  cp.carrier_id  =b.carrier_id
               AND
                  cp.county      =A.county
               AND ( b.cdma_tech    =c_tech
                  OR
                     b.gsm_tech     =c_tech
               ) AND
                  A.sim_profile  =decode(
                     c_sim_profile,
                     NULL,
                     A.sim_profile,
                     c_sim_profile
                  )
               AND
                  b.ZONE         =A.ZONE
               AND
                  b.STATE        =A.st
            GROUP BY
               b.carrier_id,
               A.sim_profile,
               A.min_dll_exch,
               A.max_dll_exch
         ) tab2
      WHERE 1=1
         AND
            ca.x_carrier_id               =tab2.carrier_id
         AND
            ca.x_status||''='ACTIVE'
         AND
            cg.objid                      =ca.carrier2carrier_group
         AND
            cg.x_status                   ='ACTIVE'
         AND
            P.objid                       =cg.x_carrier_group2x_parent
         AND
            UPPER(P.x_status)='ACTIVE'
         AND NOT EXISTS (
               SELECT 1
               FROM table_x_not_certify_models cm,
                    table_part_num pn,
                    table_mod_level ml,
                    table_part_inst pi
               WHERE 1=1
                  AND
                     cm.x_part_class_objid  =pn.part_num2part_class
                  AND
                     cm.x_parent_id         =P.x_parent_id
                  AND
                     pn.objid               =ml.part_info2part_num
                  AND
                     ml.objid               =pi.n_part_inst2part_mod
                  AND
                     pi.part_serial_no      =c_phone
            )
         AND
            EXISTS (
               SELECT 1
               FROM table_x_frequency F,
                    mtm_x_frequency2_x_pref_tech1 f2pt,
                    table_x_pref_tech pt
               WHERE F.objid                       =f2pt.x_frequency2x_pref_tech
                  AND
                     F.x_frequency+0 IN (
                        c_phone_freq1, c_phone_freq2
                     )
                  AND
                     f2pt.x_pref_tech2x_frequency  =pt.objid
                  AND
                     pt.x_pref_tech2x_carrier      =ca.objid
            )
         AND
            1=(
               CASE
                  WHEN c_tech                        ='CDMA'
                  AND
                     c_meid_phone                  =1
                  AND
                     NVL(
                        P.x_meid_carrier,
                        0
                     )=0
                  THEN 0
                  WHEN c_tech                        ='CDMA'
                  AND
                     c_meid_phone                  =0
                  THEN 1
                  ELSE 1
               END
            )
 --CR38885
         AND
            tab2.sim_profile              =(
               CASE
                  WHEN c_tech                        ='GSM'
                  OR
                     c_cdma_sim_type               ='REMOVABLE'
                  THEN c_sim_profile
                  ELSE 'NA'
               END
            )
-- DECODE(DECODE(c_tech,'GSM',c_sim_profile,NULL), NULL, 'NULL', c_sim_profile) IN
-- (DECODE(DECODE(c_tech,'GSM',c_sim_profile,NULL), NULL, 'NULL', NVL(tab2.sim_profile, 'NULLPROFILE')))
 --CR38885
         AND
            1=(
               CASE
                  WHEN ca.objid                      =c_carrier_mkt_objid
                  AND
                     ca.x_status                   ='ACTIVE'
                  THEN 1
                  WHEN P.x_block_port_in             =0 THEN 1
                  WHEN c_auto_port_out               =1
                  AND
                     P.x_block_port_in             =1
                  AND
                     P.x_auto_port_in              =1
                  THEN 1
                  WHEN c_auto_port_out               =2
                  AND
                     P.x_block_port_in             =1
                  AND
                     P.x_auto_port_in              =2
                  THEN 1
                  ELSE 0
               END
            )
         AND
            EXISTS (
               SELECT cf.x_features2bus_org
               FROM table_x_carrier_features cf
               WHERE cf.x_feature2x_carrier  =ca.objid
                  AND
                     cf.x_technology         =c_tech
                  AND
                     cf.x_features2bus_org   =c_bus_org_objid
                  AND
                     cf.x_data               =c_data_speed
                  AND
                     decode(
                        cf.x_switch_base_rate,
                        NULL,
                        c_non_ppe,
                        1
                     )=c_non_ppe
               UNION
               SELECT cf.x_features2bus_org
               FROM table_x_carrier_features cf
               WHERE cf.x_feature2x_carrier IN (
                        SELECT c2.objid
                        FROM table_x_carrier_group cg2,
                             table_x_carrier c2
                        WHERE cg2.x_carrier_group2x_parent  =P.objid
                           AND
                              c2.carrier2carrier_group      =cg2.objid
                     )
                  AND
                     cf.x_technology               =c_tech
                  AND
                     cf.x_features2bus_org         =(
                        SELECT bo.objid
                        FROM table_bus_org bo
                        WHERE bo.org_id  ='NET10'
                           AND
                              bo.objid   =c_bus_org_objid
                     )
                  AND
                     cf.x_data                     =c_data_speed
                  AND
                     decode(
                        cf.x_switch_base_rate,
                        NULL,
                        c_non_ppe,
                        1
                     )=c_non_ppe
            )
--CR38885
         AND
            cd.x_carrier_id               =ca.x_carrier_id
         AND
            cd.x_dealer_id                 =
               CASE
                  WHEN c_safelink                    ='FOUND' THEN '24920'
                  ELSE decode(
                     cd.x_dealer_id,
                     '24920',
                     'XXXXXXX',
                     cd.x_dealer_id
                  )
               END
--CR38885
         AND
            1 =
               CASE
                  WHEN pi_tab.phone_gen              ='2G' THEN (
                     SELECT COUNT(*)
                     FROM table_x_carrier_rules cr
                     WHERE ( ( cr.objid             =decode(
                                    c_tech,
                                    'CDMA',
                                    NVL(
                                       ca.carrier2rules_cdma,
                                       ca.carrier2rules
                                    ),
                                    'GSM',
                                    NVL(
                                       ca.carrier2rules_gsm,
                                       ca.carrier2rules
                                    ),
                                    ca.carrier2rules
                                 )
                              AND
                                 cr.x_allow_2g_react  ='2G'
                              AND
                                 pi_tab.x_part_inst_status NOT IN (
                                    '50', '150'
                                 )
                           ) OR ( cr.objid             =decode(
                                    c_tech,
                                    'CDMA',
                                    NVL(
                                       ca.carrier2rules_cdma,
                                       ca.carrier2rules
                                    ),
                                    'GSM',
                                    NVL(
                                       ca.carrier2rules_gsm,
                                       ca.carrier2rules
                                    ),
                                    ca.carrier2rules
                                 )
                              AND
                                 cr.x_allow_2g_act    ='2G'
                              AND
                                 pi_tab.x_part_inst_status IN (
                                    '50', '150'
                                 )
                           )
                        ) AND
                           ROWNUM<2
                  )
                  ELSE 1
               END;

 CURSOR cur_pi (v_pi_objid IN VARCHAR2)
 IS
 SELECT *
   FROM sa.table_part_inst
  WHERE objid = v_pi_objid;

--
--
PROCEDURE close_cursors AS
/***************************************************************/
/* NAME: close_cursors                                         */
/* PURPOSE: close all open cursors                             */
/* REVISIONS:                                                  */
/* Ver       Date       Author   Description                   */
/* --------- ---------- -------- -----------------------       */
/* 1.0       11/01/2006 IC ZH    Initial revision              */
/***************************************************************/
BEGIN

 IF cur_contact_id%isopen THEN
   CLOSE cur_contact_id;
 END IF;

 IF cur_esn_details%isopen THEN
   CLOSE cur_esn_details;
 END IF;

 IF cur_zipcode%isopen THEN
   CLOSE cur_zipcode;
 END IF;

 IF cur_new_profile%isopen THEN
   CLOSE cur_new_profile;
 END IF;

 IF cur_carrier%isopen THEN
   CLOSE cur_carrier;
 END IF;

 IF cur_pi%isopen THEN
   CLOSE cur_pi;
 END IF;

 IF cur_checksim%isopen THEN
   CLOSE cur_checksim;
 END IF;

 IF cur_smart_ph_check%isopen THEN
   CLOSE cur_smart_ph_check;
 END IF;

END close_cursors;
--
--
PROCEDURE verify (ip_str_old_esn   IN    VARCHAR2,
                  ip_str_new_esn   IN    VARCHAR2,
                  ip_str_zip       IN    VARCHAR2,
                  ip_str_iccid     IN    VARCHAR2,
                  op_carrier_id    OUT   VARCHAR2,
                  op_error_text    OUT   VARCHAR2,
                  op_error_num     OUT   VARCHAR2)
IS
/*************************************************************************/
/* Copyright . 2006 Tracfone Wireless Inc. All rights reserved           */
/*                                                                       */
/* Name : Upgrade                                                        */
/* Purpose : checks for validity                                         */
/*                                                                       */
/* Version Date     Who            Purpose                               */
/* ------- -------- -------------- ---------------------------           */
/* 1.9     11/20/06 IC             Initial revision                      */
/*************************************************************************/
 -- variables
 str_new_profile         VARCHAR2 (30) := '';
 v_pi_objid              NUMBER;
 v_reason                VARCHAR2 (15) := '';
 v_carrier2personality   VARCHAR2 (9) := '';

 l_str_iccid             VARCHAR2(30) := NULL;
 rec_contact_id          cur_contact_id%ROWTYPE;
 rec_esn_details         cur_esn_details%ROWTYPE;
 rec_zipcode             cur_zipcode%ROWTYPE;
 rec_carrier             cur_carrier%ROWTYPE;
 rec_pi                  cur_pi%ROWTYPE;
 rec_checksim            cur_checksim%ROWTYPE;
 rec_smart_ph_check_old  cur_smart_ph_check%ROWTYPE;
 rec_smart_ph_check_new  cur_smart_ph_check%ROWTYPE;
 bln_same_zone           BOOLEAN := FALSE;
 blncarrfound            BOOLEAN := FALSE;
 bln_same_carr           BOOLEAN := FALSE;
 same_zone_objid         NUMBER := NULL;
 same_zone_id            NUMBER := NULL;
 same_zone_pers          NUMBER := NULL;
 same_zone_man           NUMBER := NULL;
 same_parent_objid       NUMBER := NULL;
 same_parent_id          NUMBER := NULL;
 same_parent_pers        NUMBER := NULL;
 same_parent_man         NUMBER := NULL;
 best_choice_objid       NUMBER := NULL;
 best_choice_id          NUMBER := NULL;
 best_choice_pers        NUMBER := NULL;
 best_choice_man         NUMBER := NULL;
 top_carrier_objid       NUMBER := NULL;
 top_carrier_pers        NUMBER := NULL;
 op_last_rate_plan_sent  VARCHAR2(60);
 op_is_swb_carr          VARCHAR2(200);
 op_error_code           NUMBER;
 op_error_message        VARCHAR2(200);
 l_old_esn_leased        VARCHAR2(10);
 l_new_esn_leased        VARCHAR2(10);
 l_error_text            VARCHAR2(4000);
 l_error_num             VARCHAR2(100);

 -- type to hold retrieved attributes
 cst_old_esn             sa.customer_type := customer_type();
 cst_new_esn             sa.customer_type := customer_type();
 rc                      sa.customer_type := customer_type();

BEGIN

 OPEN safelink_curs (ip_str_old_esn, ip_str_new_esn);
 FETCH safelink_curs INTO safelink_rec;
   IF safelink_curs%NOTFOUND THEN
     safelink_rec.x_safelink := 'NOT FOUND';
   END IF;
 CLOSE safelink_curs;

 dbms_output.put_line('safelink_rec.x_safelink: '||safelink_rec.x_safelink);

 close_cursors;

 OPEN cur_contact_id (ip_str_old_esn);
 FETCH cur_contact_id INTO rec_contact_id;
 CLOSE cur_contact_id;

 OPEN cur_esn_details (ip_str_new_esn);
 FETCH cur_esn_details INTO rec_esn_details;

   IF rec_esn_details.x_part_inst_status IN('55','56') THEN
     op_carrier_id := 'not found';
     op_error_text := 'This ESN does not have a valid status for the upgrade.';
     op_error_num  := '9993';
     close_cursors;
     RETURN;
   ELSIF rec_esn_details.x_part_inst_status IN('57') THEN
     op_carrier_id := 'not found';
     op_error_text := 'This ESN is already reserved for an upgrade or exchange.';
     op_error_num  := '9994';
     close_cursors;
     RETURN;
   ELSIF cur_esn_details%NOTFOUND THEN
     op_carrier_id := 'not found';
     op_error_text := 'The ESN entered does not exist in inventory.';
     op_error_num  := '9995';
     close_cursors;
     RETURN;
   END IF;

   IF rec_esn_details.x_technology = 'ANALOG' THEN
     op_carrier_id := 'not found';
     op_error_text := 'The current phone number can not be transfered to an analog ESN.';
     op_error_num  := '9996';
     close_cursors;
     RETURN;
   ELSIF rec_esn_details.x_technology IS NULL THEN
     op_carrier_id := 'not found';
     op_error_text := 'The ESN Specified Returned Invalid Data. Please Contact A System Administrator.' ;
     op_error_num  := '9997';
     close_cursors;
     RETURN;
   END IF;

   IF ip_str_iccid IS NULL AND (rec_esn_details.x_technology = 'GSM' OR rec_esn_details.cdma_sim_type = 'REMOVABLE') THEN
     l_str_iccid := rec_esn_details.x_iccid;
   ELSE
     l_str_iccid := ip_str_iccid;
   END IF;

 CLOSE cur_esn_details;

 -- sim exchange is not required anymore just be sure to have a sim with a GSM phone 3/6/07
 -- but the new esn should have a sim
 -- CR5150 check the status of the sim before checking if the sim is compatible or not
 -- changed status to 9991 from 9990
 -- Start CR13249 PM ST GSM Upgrade 07/26/2011

 IF LENGTH(l_str_iccid) > 0 THEN

   dbms_output.put_line('l_str_iccid: '||l_str_iccid);

   OPEN cur_checksim (l_str_iccid);
   FETCH cur_checksim INTO rec_checksim;

     dbms_output.put_line('rec_checksim.x_sim_inv_status:'||rec_checksim.x_sim_inv_status);
     dbms_output.put_line('rec_esn_details.x_technology:'||rec_esn_details.x_technology);

     IF cur_checksim%FOUND THEN
       dbms_output.put_line('cur_checksim%FOUND');
     END IF;

     IF cur_checksim%found AND (rec_checksim.x_sim_inv_status IN('253','254') OR
                               (rec_checksim.x_sim_inv_status IN('251') AND rec_esn_details.x_technology = 'CDMA')) THEN

       OPEN cur_smart_ph_check (ip_str_old_esn);
       FETCH cur_smart_ph_check INTO rec_smart_ph_check_old;
       CLOSE cur_smart_ph_check;

       OPEN cur_smart_ph_check (ip_str_new_esn);
       FETCH cur_smart_ph_check INTO rec_smart_ph_check_new;
       CLOSE cur_smart_ph_check;

       -- CR20451 | CR20854: Add TELCEL Brand
       -- IF REC_CHECKSIM.X_SIM_INV_STATUS = '254' AND rec_smart_ph_check_old.x_iccid = ip_str_iccid
       -- and rec_smart_ph_check_old.non_ppe_flag = '1' and rec_smart_ph_check_old.x_technology = 'GSM'
       -- and rec_smart_ph_check_old.org_id = 'STRAIGHT_TALK' and rec_smart_ph_check_new.non_ppe_flag = '1'
       -- and rec_smart_ph_check_new.x_technology = 'GSM' and rec_smart_ph_check_new.org_id = 'STRAIGHT_TALK' then null;
       -- CR29583 ATT Carrier Switch (Ericsson to PPE (Active to Active) ) START
       -- New logic added by Arun to restrict verifications for SIMs that are not new and "GSM" technology
       -- CR29583 - ATT Carrier Switch (Ericsson to PPE (Active to Active))

       sa.sp_swb_carr_rate_plan (ip_esn                 => ip_str_old_esn,
                                 op_last_rate_plan_sent => op_last_rate_plan_sent,
                                 op_is_swb_carr         => op_is_swb_carr,
                                 op_error_code          => op_error_code,
                                 op_error_message       => op_error_message);

       IF op_is_swb_carr = 'Switch Base' THEN

         IF rec_checksim.x_sim_inv_status = '254' AND
            rec_smart_ph_check_old.x_iccid = l_str_iccid AND
            rec_smart_ph_check_old.non_ppe_flag = '1' AND
            rec_smart_ph_check_old.org_flow IN('1','2','3') AND
            rec_smart_ph_check_old.x_technology = 'GSM' AND
            rec_smart_ph_check_new.non_ppe_flag IN('0','1') AND
            rec_smart_ph_check_new.x_technology = 'GSM' AND
            rec_smart_ph_check_old.org_id = rec_smart_ph_check_new.org_id AND
            rec_smart_ph_check_new.org_flow IN('1','2','3') THEN

           NULL;

         ELSIF rec_checksim.x_sim_inv_status <> '253' AND rec_esn_details.x_technology = 'GSM' THEN

           op_carrier_id := 'not found';
           op_error_text := 'SIM status invalid. Manual exchange required';
           op_error_num  := '9991';
           close_cursors;
           RETURN;

         END IF;

       ELSE

         IF rec_checksim.x_sim_inv_status = '254' AND
            rec_smart_ph_check_old.x_iccid = l_str_iccid AND
            rec_smart_ph_check_old.non_ppe_flag = '1' AND
            rec_smart_ph_check_old.org_flow IN('1','2','3') AND
            rec_smart_ph_check_old.x_technology = 'GSM' AND
            rec_smart_ph_check_new.non_ppe_flag = '1' AND
            rec_smart_ph_check_new.x_technology = 'GSM' AND
            rec_smart_ph_check_old.org_id = rec_smart_ph_check_new.org_id AND
            rec_smart_ph_check_new.org_flow IN('1','2','3') THEN

           NULL;

         ELSIF rec_checksim.x_sim_inv_status <> '253' AND rec_esn_details.x_technology = 'GSM' THEN

           op_carrier_id := 'not found';
           op_error_text := 'SIM status invalid. Manual exchange required';
           op_error_num  := '9991';
           close_cursors;
           RETURN;

         END IF;

       END IF;

     ELSE

       op_carrier_id := 'not found';
       op_error_text := 'SIM status invalid. Manual exchange required';
       op_error_num  := '9991';
       close_cursors;
       RETURN;

     END IF;

     dbms_output.put_line('sim_profile:'||rec_checksim.s_part_number);

   CLOSE cur_checksim;

 END IF;

 OPEN cur_carrier (ip_str_old_esn);
 FETCH cur_carrier INTO rec_carrier;

   IF cur_carrier%NOTFOUND THEN
     dbms_output.put_line('cur_carrier%NOTFOUND');
     op_error_text := 'No Carrier Found';
     op_error_num  := '9990';
     close_cursors;
     RETURN;
   ELSE
     dbms_output.put_line('cur_carrier%FOUND');
   END IF;

 CLOSE cur_carrier;

 ---------------------------------------------------------------------------------------------------------------------
 --new code 8/23/07
 ---------------------------------------------------------------------------------------------------------------------
 OPEN new_esn_tech_curs (ip_str_new_esn);
 FETCH new_esn_tech_curs INTO new_esn_tech_rec;
 CLOSE new_esn_tech_curs;

 dbms_output.put_line('rec_carrier:'||rec_carrier.x_zipcode);
 dbms_output.put_line('ip_str_zip:'||ip_str_zip);
 dbms_output.put_line('new_esn_tech_rec.cdma_sim_type:'||new_esn_tech_rec.cdma_sim_type);
 dbms_output.put_line('new_esn_tech_rec.x_technology:'||new_esn_tech_rec.x_technology);
 dbms_output.put_line('new_esn_tech_rec.x_frequency1:'||new_esn_tech_rec.x_frequency1);
 dbms_output.put_line('new_esn_tech_rec.x_frequency2:'||new_esn_tech_rec.x_frequency2);
 dbms_output.put_line('rec_carrier.x_parent_name:'||rec_carrier.x_parent_name);
 dbms_output.put_line('rec_carrier.objid:'||rec_carrier.objid);
 dbms_output.put_line('rec_carrier.x_auto_port_out:'||rec_carrier.x_auto_port_out);
 dbms_output.put_line('rec_carrier.x_no_auto_port :'||rec_carrier.x_no_auto_port);
 dbms_output.put_line('rec_carrier.x_block_port_in:'||rec_carrier.x_block_port_in);
 dbms_output.put_line(ip_str_zip);
 dbms_output.put_line(rec_carrier.x_zipcode);
 dbms_output.put_line('rec_carrier.x_parent_name:'||rec_carrier.x_parent_name);
 dbms_output.put_line(new_esn_tech_rec.x_technology);
 dbms_output.put_line(new_esn_tech_rec.x_frequency1);
 dbms_output.put_line(new_esn_tech_rec.x_frequency2);
 dbms_output.put_line(rec_carrier.objid);
 dbms_output.put_line(rec_carrier.x_auto_port_out);
 dbms_output.put_line('rec_checksim.s_part_number'||rec_checksim.s_part_number);
 dbms_output.put_line(new_esn_tech_rec.x_meid_phone);
 dbms_output.put_line( new_esn_tech_rec.non_ppe);
 dbms_output.put_line(ip_str_new_esn);
 dbms_output.put_line('new_esn_tech_rec.cdma_sim_type:'||new_esn_tech_rec.cdma_sim_type);

 same_zone_objid   := NULL;
 same_parent_objid := NULL;
 best_choice_objid := NULL;

 FOR rec_possible_carriers IN cur_possible_carriers (ip_str_zip,
                                                     rec_carrier.x_zipcode,
                                                     rec_carrier.x_parent_name,
                                                     new_esn_tech_rec.x_technology,
                                                     new_esn_tech_rec.x_frequency1,
                                                     new_esn_tech_rec.x_frequency2,
                                                     rec_carrier.objid,
                                                     rec_carrier.x_auto_port_out,
                                                     rec_checksim.s_part_number,
                                                     new_esn_tech_rec.x_meid_phone,
                                                     ip_str_new_esn,
                                                     new_esn_tech_rec.non_ppe,
                                                     new_esn_tech_rec.x_dll,
                                                     new_esn_tech_rec.bus_org_objid,
                                                     new_esn_tech_rec.data_speed,
                                                     safelink_rec.x_safelink,
                                                     new_esn_tech_rec.cdma_sim_type) LOOP

   dbms_output.put_line('dealer_id:'||rec_possible_carriers.x_dealer_id);
   dbms_output.put_line('parent:'||rec_possible_carriers.x_parent_name);
   dbms_output.put_line('rec_possible_carriers.same_zone:'||rec_possible_carriers.same_zone);

   IF rec_possible_carriers.same_zone > 0 AND same_zone_objid IS NULL THEN
     same_zone_objid := rec_possible_carriers.carrier_objid;
     same_zone_pers := rec_possible_carriers.carrier2personality;
     same_zone_id := rec_possible_carriers.x_carrier_id;
     same_zone_man := rec_possible_carriers.manual_port;
     dbms_output.put_line('same_zone_man:'||rec_possible_carriers.manual_port);
   ELSIF rec_possible_carriers.same_parent > 0 AND same_parent_objid IS NULL THEN
     same_parent_objid := rec_possible_carriers.carrier_objid;
     same_parent_pers := rec_possible_carriers.carrier2personality;
     same_parent_id := rec_possible_carriers.x_carrier_id;
     same_parent_man := rec_possible_carriers.manual_port;
   ELSIF best_choice_objid IS NULL THEN
     dbms_output.put_line('best choice parent:'||rec_possible_carriers.x_parent_name);
     best_choice_objid := rec_possible_carriers.carrier_objid;
     best_choice_pers := rec_possible_carriers.carrier2personality;
     best_choice_id := rec_possible_carriers.x_carrier_id;
     best_choice_man := rec_possible_carriers.manual_port;
   END IF;

   dbms_output.put_line('rec_possible_carriers.x_block_port_in: '|| rec_possible_carriers.x_block_port_in);

 END LOOP; -- cur_possible_carriers;

 dbms_output.put_line(' top_carrier_objid '|| top_carrier_objid);
 dbms_output.put_line(' op_carrier_id '|| op_carrier_id);
 dbms_output.put_line('same_zone_objid '|| same_zone_objid);

 IF (same_zone_objid IS NULL AND same_parent_objid IS NULL AND best_choice_objid IS NULL) THEN

   op_error_text := 'No Carrier Found';
   op_error_num := '9990';
   close_cursors;
   dbms_output.put_line('cur_possible_carriers%NOTFOUND ');
   RETURN;

 ELSIF same_zone_objid IS NOT NULL THEN

   top_carrier_objid := same_zone_objid;
   top_carrier_pers := same_zone_pers;
   op_carrier_id := same_zone_id;
   op_error_text := 'ESN EXCHANGE';
   op_error_num := '0';
   dbms_output.put_line('same zone');

 ELSIF same_parent_objid IS NOT NULL THEN

   top_carrier_objid := same_parent_objid;
   top_carrier_pers := same_parent_pers;
   op_carrier_id := same_parent_id;

   IF same_parent_man = 1 THEN
     op_error_text := 'MANUAL PORT';
   ELSE
     op_error_text := 'AUTO PORT';
   END IF;

   op_error_num := '0';
   dbms_output.put_line('same parent');

 ELSIF best_choice_objid IS NOT NULL THEN

   top_carrier_objid := best_choice_objid;
   top_carrier_pers := best_choice_pers;
   op_carrier_id := best_choice_id;

   IF best_choice_man = 1 THEN
     op_error_text := 'MANUAL PORT';
   ELSE
     op_error_text := 'AUTO PORT';
   END IF;

   op_error_num := '0';
   dbms_output.put_line('best choice');

 END IF;

 -- CR39389 Changes for TW+ Starts
 -- Retrieve customer type for ESN
 -- CR37756 Added same account check

 cst_old_esn := rc.retrieve (i_esn => ip_str_old_esn );
 cst_new_esn := rc.retrieve (i_esn => ip_str_new_esn );

 IF cst_old_esn.bus_org_id = cst_new_esn.bus_org_id AND
    cst_old_esn.web_user_objid <> cst_new_esn.web_user_objid AND
    check_x_parameter ('SAME_ACCOUNT_CHECK', cst_new_esn.bus_org_id) THEN

   op_error_text := 'Phones are not in same account';
   op_error_num := '9990';
   RETURN;

 END IF;

 -- get leased flag for old esn
 customer_lease_scoring_pkg.get_esn_leased_flag (i_esn         => ip_str_old_esn,
                                                 o_leased_flag => l_old_esn_leased);

 -- get leased flag for new esn
 customer_lease_scoring_pkg.get_esn_leased_flag (i_esn         => ip_str_new_esn,
                                                 o_leased_flag => l_new_esn_leased);

 -- Check whether any one of the ESN old/new is Leased
 -- And check whether both ESNs belong to Total wireless

 IF (l_new_esn_leased = 'Y') AND (cst_old_esn.brand_shared_group_flag = 'Y' AND cst_new_esn.brand_shared_group_flag = 'Y') THEN

   customer_lease_scoring_pkg.validate_upgrade (i_from_esn => ip_str_old_esn,
                                                i_to_esn   => ip_str_new_esn,
                                                o_err_code => l_error_num,
                                                o_err_msg  => l_error_text);

   IF l_error_num <> '0' THEN
     op_error_num  := l_error_num;
     op_error_text := l_error_text;
   END IF;

 END IF;

 ---------------------------------------------------------------------------------------------------------------------
 -- CR39389 Changes for TW+ Ends.
 -- new code 8/23/07
 -- Unreserve any other line linked to the target ESN
 ---------------------------------------------------------------------------------------------------------------------

 dbms_output.put_line('update part_inst(top_carrier_objid): '|| top_carrier_objid);
 dbms_output.put_line('update part_inst(top_carrier_pers): '|| top_carrier_pers);
 dbms_output.put_line('update part_inst(op_carrier_id): '||op_carrier_id);

 close_cursors;

END verify;
--
--
PROCEDURE upgrade (ip_str_old_esn   IN     VARCHAR2,
                   ip_str_new_esn   IN     VARCHAR2,
                   ip_str_zip       IN     VARCHAR2,
                   ip_str_iccid     IN     VARCHAR2,
                   op_carrier_id    OUT    VARCHAR2,
                   op_error_text    OUT    VARCHAR2,
                   op_error_num     OUT    VARCHAR2)
IS
--
/*************************************************************************/
/* Copyright . 2006 Tracfone Wireless Inc. All rights reserved           */
/*                                                                       */
/* Name: Upgrade                                                         */
/* Purpose: checks for validity                                          */
/*                                                                       */
/* Version Date     Who        Purpose                                   */
/* ------- -------- ---------- ------------------------------------------*/
/* 1.9     11/20/06 IC         Initial revision                          */
/*************************************************************************/

 rec_contact_id          cur_contact_id%ROWTYPE;
 rec_esn_details         cur_esn_details%ROWTYPE;
 rec_zipcode             cur_zipcode%ROWTYPE;
 rec_carrier             cur_carrier%ROWTYPE;
 rec_pi                  cur_pi%ROWTYPE;
 rec_checksim            cur_checksim%ROWTYPE;
 rec_smart_ph_check_old  cur_smart_ph_check%ROWTYPE;
 rec_smart_ph_check_new  cur_smart_ph_check%ROWTYPE;
 rec_old_esn_details     cur_esn_details%ROWTYPE;
 bln_same_zone           BOOLEAN := FALSE;
 blncarrfound            BOOLEAN := FALSE;
 bln_same_carr           BOOLEAN := FALSE;
 l_str_iccid             VARCHAR2(30);
 str_new_profile         VARCHAR2(30);
 v_reason                VARCHAR2(15);
 v_carrier2personality   VARCHAR2(9);
 v_pi_objid              NUMBER;
 same_zone_objid         NUMBER := NULL;
 same_zone_id            NUMBER := NULL;
 same_zone_pers          NUMBER := NULL;
 same_parent_objid       NUMBER := NULL;
 same_parent_id          NUMBER := NULL;
 same_parent_pers        NUMBER := NULL;
 best_choice_objid       NUMBER := NULL;
 best_choice_id          NUMBER := NULL;
 best_choice_pers        NUMBER := NULL;
 top_carrier_objid       NUMBER := NULL;
 top_carrier_pers        NUMBER := NULL;
 op_error_code           NUMBER := 0;
 op_error_msg            VARCHAR2(200);

BEGIN

 --CR38885
 OPEN safelink_curs (ip_str_old_esn, ip_str_new_esn);
 FETCH safelink_curs INTO safelink_rec;
   IF safelink_curs%NOTFOUND THEN
     safelink_rec.x_safelink := 'NOT FOUND';
   END IF;
 CLOSE safelink_curs;

 close_cursors;

 OPEN cur_contact_id (ip_str_old_esn);
 FETCH cur_contact_id INTO rec_contact_id;
 CLOSE cur_contact_id;

 OPEN cur_esn_details (ip_str_old_esn);
 FETCH cur_esn_details INTO rec_old_esn_details;
 CLOSE cur_esn_details;

 OPEN cur_esn_details (ip_str_new_esn);
 FETCH cur_esn_details INTO rec_esn_details;

   IF rec_esn_details.x_part_inst_status IN('55','56') THEN
     op_carrier_id := 'not found';
     op_error_text := 'This ESN does not have a valid status for the upgrade.';
     op_error_num := '9993';
     close_cursors;
     RETURN;
   ELSIF rec_esn_details.x_part_inst_status IN('57') THEN
     op_carrier_id := 'not found';
     op_error_text := 'This ESN is already reserved for an upgrade or exchange.';
     op_error_num := '9994';
     close_cursors;
     RETURN;
   ELSIF cur_esn_details%NOTFOUND THEN
     op_carrier_id := 'not found';
     op_error_text := 'The ESN entered does not exist in inventory.';
     op_error_num := '9995';
     close_cursors;
     RETURN;
   END IF;

   IF rec_esn_details.x_technology = 'ANALOG' THEN
     op_carrier_id := 'not found';
     op_error_text := 'The current phone number can not be transfered to an analog ESN.';
     op_error_num := '9996';
     close_cursors;
     RETURN;
   ELSIF rec_esn_details.x_technology = NULL THEN
     op_carrier_id := 'not found';
     op_error_text := 'The ESN Specified Returned Invalid Data. Please Contact A System Administrator.' ;
     op_error_num := '9997';
     close_cursors;
     RETURN;
   END IF;

   sa.UPGRADE_PROMO_PKG.transfer_3x_promo (ip_str_old_esn, ip_str_new_esn, op_error_code, op_error_msg);

   IF ip_str_iccid IS NULL AND (rec_esn_details.x_technology = 'GSM' OR rec_esn_details.cdma_sim_type = 'REMOVABLE') THEN
     l_str_iccid := rec_esn_details.x_iccid;
   ELSE
     l_str_iccid := ip_str_iccid;
   END IF;

 CLOSE cur_esn_details;

 -- sim exchange is not required anymore just be sure to have a sim with a GSM phone 3/6/07
 -- but the new esn should have a sim
 -- CR5150 check the status of the sim before checking if the sim is compatible or not
 -- changed status to 9991 from 9990

 IF LENGTH(l_str_iccid) > 0 THEN

   OPEN cur_checksim (l_str_iccid);
   FETCH cur_checksim INTO rec_checksim;
     -- CR13249
     IF cur_checksim%FOUND AND (rec_checksim.x_sim_inv_status IN('253','254') OR
                               (rec_checksim.x_sim_inv_status IN('251') AND rec_esn_details.x_technology = 'CDMA')) THEN

       OPEN cur_smart_ph_check (ip_str_old_esn);
       FETCH cur_smart_ph_check INTO rec_smart_ph_check_old;
       CLOSE cur_smart_ph_check;

       OPEN cur_smart_ph_check (ip_str_new_esn);
       FETCH cur_smart_ph_check INTO rec_smart_ph_check_new;
       CLOSE cur_smart_ph_check;

       IF rec_checksim.x_sim_inv_status = '254' AND
          rec_smart_ph_check_old.x_iccid = l_str_iccid AND
          rec_smart_ph_check_old.non_ppe_flag = '1' AND
          rec_smart_ph_check_old.x_technology = 'GSM' AND
          rec_smart_ph_check_old.org_flow IN('1','2','3') AND
          rec_smart_ph_check_new.non_ppe_flag = '1' AND
          rec_smart_ph_check_new.x_technology = 'GSM' AND
          rec_smart_ph_check_new.org_flow IN('1','2','3') AND
          rec_smart_ph_check_old.org_id = rec_smart_ph_check_new.org_id THEN
         NULL;
       ELSIF rec_checksim.x_sim_inv_status <> '253' AND rec_esn_details.x_technology = 'GSM' THEN
         op_carrier_id := 'not found';
         op_error_text := 'SIM status invalid. Manual exchange required';
         op_error_num  := '9991';
         close_cursors;
         RETURN;
       END IF;

     ELSE

       op_carrier_id := 'not found';
       op_error_text := 'SIM status invalid. Manual exchange required';
       op_error_num  := '9991';
       close_cursors;
       RETURN;

     END IF;

     dbms_output.put_line('sim_profile: '||rec_checksim.s_part_number);

   CLOSE cur_checksim;

 END IF;

 OPEN cur_carrier (ip_str_old_esn);
 FETCH cur_carrier INTO rec_carrier;

   IF cur_carrier%NOTFOUND THEN
     dbms_output.put_line('cur_carrier%NOTFOUND ');
     op_error_text := 'No Carrier Found';
     op_error_num  := '9990';
     close_cursors;
     RETURN;
   ELSE
     dbms_output.put_line('cur_carrier%FOUND: '||rec_carrier.x_carrier_id);
   END IF;

 CLOSE cur_carrier;

 OPEN new_esn_tech_curs (ip_str_new_esn);
 FETCH new_esn_tech_curs INTO new_esn_tech_rec;
 CLOSE new_esn_tech_curs;

 dbms_output.put_line('rec_carrier: '||rec_carrier.x_zipcode);
 dbms_output.put_line('ip_str_zip: '||ip_str_zip);
 dbms_output.put_line('new_esn_tech_rec.cdma_sim_type: '||new_esn_tech_rec.cdma_sim_type);
 dbms_output.put_line('new_esn_tech_rec.x_technology: '||new_esn_tech_rec.x_technology);
 dbms_output.put_line('new_esn_tech_rec.x_frequency1: '||new_esn_tech_rec.x_frequency1);
 dbms_output.put_line('new_esn_tech_rec.x_frequency2: '||new_esn_tech_rec.x_frequency2);
 dbms_output.put_line('rec_carrier.x_parent_name: '||rec_carrier.x_parent_name);
 dbms_output.put_line('rec_carrier.objid: '||rec_carrier.objid);
 dbms_output.put_line('rec_carrier.x_auto_port_out: '||rec_carrier.x_auto_port_out);
 dbms_output.put_line('rec_carrier.x_no_auto_port: '||rec_carrier.x_no_auto_port);
 dbms_output.put_line('rec_carrier.x_block_port_in: '||rec_carrier.x_block_port_in);
 dbms_output.put_line('rec_carrier.x_zipcode: '||rec_carrier.x_zipcode);
 dbms_output.put_line('rec_carrier.x_parent_name: '||rec_carrier.x_parent_name);
 dbms_output.put_line('rec_checksim.s_part_number: '||rec_checksim.s_part_number);
 dbms_output.put_line('new_esn_tech_rec.x_meid_phone: '||new_esn_tech_rec.x_meid_phone);
 dbms_output.put_line('ip_str_new_esn: '||ip_str_new_esn);

 same_zone_objid   := NULL;
 same_parent_objid := NULL;
 best_choice_objid := NULL;

 FOR rec_possible_carriers IN cur_possible_carriers (ip_str_zip,
                                                     rec_carrier.x_zipcode,
                                                     rec_carrier.x_parent_name,
                                                     new_esn_tech_rec.x_technology,
                                                     new_esn_tech_rec.x_frequency1,
                                                     new_esn_tech_rec.x_frequency2,
                                                     rec_carrier.objid,
                                                     rec_carrier.x_auto_port_out,
                                                     rec_checksim.s_part_number,
                                                     new_esn_tech_rec.x_meid_phone,
                                                     ip_str_new_esn,
                                                     new_esn_tech_rec.non_ppe,
                                                     new_esn_tech_rec.x_dll,
                                                     new_esn_tech_rec.bus_org_objid,
                                                     new_esn_tech_rec.data_speed,
                                                     safelink_rec.x_safelink,
                                                     new_esn_tech_rec.cdma_sim_type) LOOP

   dbms_output.put_line('parent: '||rec_possible_carriers.x_parent_name);
   dbms_output.put_line('best choice parent: '||rec_possible_carriers.x_parent_name);
   dbms_output.put_line('rec_possible_carriers.x_block_port_in: '||rec_possible_carriers.x_block_port_in);

   IF rec_possible_carriers.same_zone > 0 AND same_zone_objid IS NULL THEN
     same_zone_objid   := rec_possible_carriers.carrier_objid;
     same_zone_pers    := rec_possible_carriers.carrier2personality;
     same_zone_id      := rec_possible_carriers.x_carrier_id;
   ELSIF rec_possible_carriers.same_parent > 0 AND same_parent_objid IS NULL THEN
     same_parent_objid := rec_possible_carriers.carrier_objid;
     same_parent_pers  := rec_possible_carriers.carrier2personality;
     same_parent_id    := rec_possible_carriers.x_carrier_id;
   ELSIF best_choice_objid IS NULL THEN
     best_choice_objid := rec_possible_carriers.carrier_objid;
     best_choice_pers  := rec_possible_carriers.carrier2personality;
     best_choice_id    := rec_possible_carriers.x_carrier_id;
   END IF;

 END LOOP; -- cur_possible_carriers;

 IF (same_zone_objid IS NULL AND same_parent_objid IS NULL AND best_choice_objid IS NULL) THEN
   op_error_text := 'No Carrier Found';
   op_error_num := '9990';
   close_cursors;
   dbms_output.put_line('cur_possible_carriers%NOTFOUND');
   RETURN;
 ELSIF same_zone_objid IS NOT NULL THEN
   op_carrier_id := same_zone_id;
   top_carrier_objid := same_zone_objid;
   top_carrier_pers := same_zone_pers;
   v_reason := 'ESN EXCHANGE';
   dbms_output.put_line('same zone');
 ELSIF same_parent_objid IS NOT NULL THEN
   op_carrier_id := same_parent_id;
   top_carrier_objid := same_parent_objid;
   top_carrier_pers := same_parent_pers;
   v_reason := 'INT_PORT_IN';
   dbms_output.put_line('same parent');
 ELSIF best_choice_objid IS NOT NULL THEN
   op_carrier_id := best_choice_id;
   top_carrier_objid := best_choice_objid;
   top_carrier_pers := best_choice_pers;
   v_reason := 'INT_PORT_IN';
   dbms_output.put_line('best choice');
 END IF;

 ---------------------------------------------------------------------------------------------------------------------
 --new code 8/23/07
 --Unreserve any other line linke to the target ESN
 ---------------------------------------------------------------------------------------------------------------------

 dbms_output.put_line('update part_inst(top_carrier_objid): '||top_carrier_objid);
 dbms_output.put_line('update part_inst(top_carrier_pers): '||top_carrier_pers);
 dbms_output.put_line('update part_inst(op_carrier_id): '||op_carrier_id);

 close_cursors;

 -- CR52938 - Update new ESN contact opt-in/out flags with old ESN flags.
 update_contact_optout (ip_old_esn     => ip_str_old_esn,
                        ip_new_esn     => ip_str_new_esn,
                        ip_channel     => NULL,
                        ip_org_id      => rec_old_esn_details.org_id,
                        ip_off_flag    => 'N',
                        op_error_text  => op_error_text,
                        op_error_num   => op_error_num);

 IF (NVL(op_error_num,'0') <> '0') OR (NVL(op_error_text,'SUCCESS') <> 'SUCCESS') THEN

   -- CR52938 - Upgrade process should complete as usual regardless of the contact optout execution results.
   dbms_output.put_line('update_contact_optout.op_error_text: '||op_error_text);
   dbms_output.put_line('update_contact_optout.op_error_num: '||op_error_num);
   op_error_text := NULL;
   op_error_num  := NULL;

 END IF;

END upgrade;
--
--
PROCEDURE validate_swap_sim_prc (p_from_esn         IN    VARCHAR2,
                                 p_to_esn           IN    VARCHAR2,
                                 p_zip              IN    VARCHAR2,
                                 p_org_id           IN    table_bus_org.org_id%TYPE,
                                 p_source_system    IN    VARCHAR2,
                                 op_swap_sim_flag   OUT   NUMBER, -- 1 or 0
                                 op_er_cd           OUT   NUMBER,
                                 op_msg             OUT   VARCHAR2)
IS
 /*--------------------------------------------------------------------------*/
 /* */
 /* Name : VALIDATE_SWAP_SIM_PRC */
 /* */
 /* Purpose : This procedure checks if old and new esn are non ppe */
 /* non byop and GSM devices and from sim is comaptible */
 /* with new esn and if swap sim scenario */
 /* is possible */
 /* Author : Adasgupta */
 /* */
 /* Date : 05-21-2014 */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- -------- ------------------------------------- */
 /* 1.0 05-21-2014 Adasgupta Initial Version */
 /*--------------------------------------------------------------------------*/
 CURSOR esn_curs (c_esn IN VARCHAR2)
 IS
 SELECT pi.part_serial_no,
 pi.x_part_inst_status,
 pi.x_iccid,
 pi.x_part_inst2site_part,
 pn.x_technology ,
 decode(sa.get_param_by_name_fun(pc.NAME,'NON_PPE'),'NOT FOUND','PPE','0','PPE','NON_PPE') ppe_flag,
 NVL(sa.get_param_by_name_fun(pc.NAME,'MODEL_TYPE'),'UNKNOWN') model_type ,
 NVL((SELECT V.x_param_value
 FROM table_x_part_class_values V,
 table_x_part_class_params N
 WHERE 1 =1
 AND V.value2part_class = pn.part_num2part_class
 AND V.value2class_param = N.objid
 AND N.x_param_name = 'DEVICE_TYPE'
 ),'UNKNOWN') device_type,
 NVL((SELECT x_sim_inv_status
 FROM table_x_sim_inv
 WHERE x_sim_serial_no = pi.x_iccid
 ),'0') sim_status
 FROM table_part_inst pi ,
 table_mod_level ml,
 table_part_num pn,
 table_part_class pc
 WHERE 1 =1
 AND pc.objid = pn.part_num2part_class
 AND pi.part_serial_no = c_esn
 AND pi.x_domain ='PHONES'
 AND ml.objid = pi.n_part_inst2part_mod
 AND pn.objid = ml.part_info2part_num;

 esn_from_rec esn_curs%ROWTYPE;

 esn_to_rec esn_curs%ROWTYPE;

BEGIN

 OPEN esn_curs (p_from_esn);
 FETCH esn_curs INTO esn_from_rec;

 IF esn_curs%NOTFOUND THEN
 op_swap_sim_flag := 0 ;
 op_er_cd := 1;
 op_msg :='from esn not found';
 dbms_output.put_line(op_msg);
 ELSIF esn_from_rec.ppe_flag = 'PPE' THEN
 op_swap_sim_flag := 0 ;
 op_er_cd := 1;
 op_msg :='from esn not NON_PPE' ;
 dbms_output.put_line(op_msg);
 ELSIF esn_from_rec.device_type IN ('BYOP','BYOT') THEN
 op_swap_sim_flag := 0 ;
 op_er_cd := 1;
 op_msg :='from esn is BYOP or BYOT' ;
 dbms_output.put_line(op_msg);
 ELSIF esn_from_rec.model_type IN ('CAR CONNECT') THEN
 op_swap_sim_flag := 0 ;
 op_er_cd := 1;
 op_msg :='from esn is CAR CONNECT' ;
 dbms_output.put_line(op_msg);
 ELSIF esn_from_rec.x_technology != 'GSM' THEN
 op_swap_sim_flag := 0 ;
 op_er_cd := 1;
 op_msg :='from esn is not GSM' ;
 dbms_output.put_line(op_msg);
 ELSIF esn_from_rec.x_part_inst_status IN ('151','59') THEN
 op_swap_sim_flag := 0 ;
 op_er_cd := 1;
 op_msg :='from esn invalid status' ;
 dbms_output.put_line(op_msg);
 ELSIF esn_from_rec.sim_status NOT IN ('251','253','254') THEN
 op_swap_sim_flag := 0 ;
 op_er_cd := 1;
 op_msg :='from esn sim invalid status' ;
 dbms_output.put_line(op_msg);
 END IF;

 CLOSE esn_curs;

 IF op_er_cd = 1 THEN
 sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action => 'Validate ESN',
                                         ip_key => p_from_esn,
                                         ip_program_name => 'verify_phone_upgrade_pkg.VALIDATE_SWAP_SIM_PRC',
                                         ip_error_text => to_char(op_er_cd)||' '||op_msg);
 RETURN;
 END IF;

 OPEN esn_curs (p_to_esn);
 FETCH esn_curs INTO esn_to_rec;

 IF esn_curs%NOTFOUND THEN
 op_swap_sim_flag := 0 ;
 op_er_cd := 2;
 op_msg :='to esn not found' ;
 dbms_output.put_line(op_msg);
 ELSIF esn_to_rec.ppe_flag = 'PPE' THEN
 op_swap_sim_flag := 0 ;
 op_er_cd := 2;
 op_msg :='to esn not NON_PPE' ;
 dbms_output.put_line(op_msg);
 ELSIF esn_to_rec.device_type IN ('BYOP','BYOT') THEN
 op_swap_sim_flag := 0 ;
 op_er_cd := 2;
 op_msg :='to esn is BYOP or BYOT' ;
 dbms_output.put_line(op_msg);
 ELSIF esn_to_rec.model_type IN ('CAR CONNECT') THEN
 op_swap_sim_flag := 0 ;
 op_er_cd := 2;
 op_msg :='to esn is CAR CONNECT' ;
 dbms_output.put_line(op_msg);
 ELSIF esn_to_rec.x_technology != 'GSM' THEN
 op_swap_sim_flag := 0 ;
 op_er_cd := 2;
 op_msg :='to esn is not GSM' ;
 dbms_output.put_line(op_msg);
 ELSIF esn_to_rec.x_part_inst_status IN ('151','59') THEN
 op_swap_sim_flag := 0 ;
 op_er_cd := 2;
 op_msg :='to esn invalid status' ;
 dbms_output.put_line(op_msg);
 END IF;

 CLOSE esn_curs;

 IF op_er_cd = 2 THEN
 sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action => 'Validate ESN',
                                         ip_key => p_to_esn,
                                         ip_program_name => 'verify_phone_upgrade_pkg.VALIDATE_SWAP_SIM_PRC',
                                         ip_error_text => to_char(op_er_cd)||' '||op_msg);
 RETURN;
 END IF;

 nap_service_pkg.get_list (p_zip, p_to_esn, NULL, esn_from_rec.x_iccid, NULL, NULL);

 IF sa.nap_service_pkg.big_tab.COUNT > 0 THEN
 op_swap_sim_flag := 1;
 op_er_cd := 0;
 op_msg :='Success';
 ELSE
 op_swap_sim_flag := 0 ;
 op_er_cd := 3;
 op_msg :='from SIM will not work in to esn';
 sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action => 'Validate nap_SERVICE_pkg.get_list(',
                                         ip_key => p_to_esn,
                                         ip_program_name => 'verify_phone_upgrade_pkg.VALIDATE_SWAP_SIM_PRC',
                                         ip_error_text => to_char(op_er_cd)||' '||op_msg);
 END IF;

 dbms_output.put_line('op_swap_sim_flag:'||op_swap_sim_flag);
 dbms_output.put_line('op_er_cd:'||op_er_cd);
 dbms_output.put_line('op_msg:'||op_msg);

END validate_swap_sim_prc;
--
--
PROCEDURE verify_wrapper (ip_str_old_esn   IN    VARCHAR2,
                          ip_str_new_esn   IN    VARCHAR2,
                          ip_str_zip       IN    VARCHAR2,
                          ip_str_iccid     IN    VARCHAR2,
                          ip_channel       IN    VARCHAR2,
                          op_carrier_id    OUT   VARCHAR2,
                          op_error_text    OUT   VARCHAR2,
                          op_error_num     OUT   VARCHAR2,
                          op_warning_code  OUT   VARCHAR2)
AS
 CURSOR new_esn_tech_curs( c_esn IN VARCHAR2 )
 IS
 SELECT prt_num.x_technology,
 NVL( (SELECT V.x_param_value
 FROM table_x_part_class_values V,
 table_x_part_class_params N
 WHERE 1=1
 AND V.value2part_class = prt_num.part_num2part_class
 AND V.value2class_param = N.objid
 AND N.x_param_name = 'CDMA LTE SIM'
 AND ROWNUM <2), 'NON REMOVABLE') cdma_sim_type,
 (
 CASE
 WHEN EXISTS
 (SELECT 1
 FROM table_x_frequency F,
 sa.mtm_part_num14_x_frequency0 pf
 WHERE 1 =1
 AND pf.x_frequency2part_num = F.objid
 AND pf.x_frequency2part_num = F.objid
 AND F.x_frequency = 800
 )
 THEN 800
 ELSE 0
 END) x_frequency1,
 (
 CASE
 WHEN EXISTS
 (SELECT 1
 FROM table_x_frequency F,
 sa.mtm_part_num14_x_frequency0 pf
 WHERE 1 =1
 AND pf.x_frequency2part_num = F.objid
 AND prt_num.objid = pf.part_num2x_frequency
 AND F.x_frequency = 1900
 )
 THEN 1900
 ELSE 0
 END) x_frequency2,
 NVL(prt_num.x_meid_phone, 0) x_meid_phone,
 (SELECT COUNT(*) sr
 FROM table_x_part_class_values V,
 table_x_part_class_params N
 WHERE 1 =1
 AND V.value2part_class = prt_num.part_num2part_class
 AND V.value2class_param = N.objid
 AND N.x_param_name = 'NON_PPE'
 AND V.x_param_value IN ('0', '1') --CR17118
 AND ROWNUM <2
 ) non_ppe,
 prt_num.x_dll,
 NVL(
 (SELECT V.x_param_value
 FROM table_x_part_class_values V,
 table_x_part_class_params N
 WHERE 1 =1
 AND V.value2part_class = prt_num.part_num2part_class
 AND V.value2class_param = N.objid
 AND N.x_param_name = 'DATA_SPEED'
 AND ROWNUM <2
 ),NVL(prt_num.x_data_capable, 0)) data_speed,
 (SELECT bo.objid
 FROM table_bus_org bo
 WHERE bo.objid = prt_num.part_num2bus_org
 ) bus_org_objid
 FROM table_part_num prt_num,
 table_mod_level ml,
 table_part_inst pi
 WHERE 1 =1
 AND prt_num.objid = ml.part_info2part_num
 AND pi.n_part_inst2part_mod = ml.objid
 AND pi.x_domain = 'PHONES'
 AND pi.part_serial_no = ip_str_new_esn;

 new_esn_tech_rec new_esn_tech_curs%ROWTYPE;

 l_from_brand VARCHAR2(50);
 l_to_brand VARCHAR2(50);
 l_from_device_type VARCHAR2(50);
 l_to_device_type VARCHAR2(50);
 l_to_phone_short_parent VARCHAR2(50);
 l_flag VARCHAR2(50);
 l_units VARCHAR2(50);
 l_error_text VARCHAR2(1000);
 l_error_num VARCHAR2(50);
 l_carrier_id VARCHAR2(50);
 l_to_part_number VARCHAR2(50);
 l_block_flag VARCHAR2(50);
 l_to_phone_device_type VARCHAR2(50);
 l_s_error_code VARCHAR2(50);
 l_s_error_message VARCHAR2(1000);
 l_tech VARCHAR2(100);
 l_sim_profile VARCHAR2(100);
 l_tmp_carrier_id VARCHAR2(100);

 from_cst sa.customer_type := sa.customer_type(ip_str_old_esn);
 from_cst_ret sa.customer_type := sa.customer_type;
 to_cst sa.customer_type := sa.customer_type(ip_str_new_esn);
 to_cst_ret sa.customer_type := sa.customer_type;
 v_service_plan_group sa.service_plan_feat_pivot_mv.service_plan_group%TYPE; -- CR42459
 x_service_plan_rec sa.x_service_plan%ROWTYPE;

BEGIN

 from_cst_ret := from_cst.retrieve;
 to_cst_ret := to_cst.retrieve;
 l_from_brand := from_cst_ret.bus_org_id;

 l_from_device_type := CASE
                       WHEN from_cst_ret.device_type='BYOP'
                       THEN 'SMARTPHONE'
                       ELSE from_cst_ret.device_type
                       END;

 l_to_brand := to_cst_ret.bus_org_id;
 l_to_phone_device_type := to_cst_ret.device_type;
 l_to_part_number := to_cst_ret.esn_part_number;
 l_tech := to_cst_ret.technology;

 BEGIN
  SELECT pn.s_part_number
  INTO   l_sim_profile
  FROM   table_part_num pn,
         table_mod_level ml,
         table_x_sim_inv si
  WHERE  1 = 1
  AND    pn.objid = ml.part_info2part_num
  AND    ml.objid = si.x_sim_inv2part_mod
  AND    si.x_sim_serial_no = ip_str_iccid;
 EXCEPTION
   WHEN OTHERS THEN
     l_sim_profile := NULL;
 END;

 sa.verify_phone_upgrade_pkg.VERIFY (ip_str_old_esn => ip_str_old_esn,
                                     ip_str_new_esn => ip_str_new_esn,
                                     ip_str_zip => ip_str_zip,
                                     ip_str_iccid => ip_str_iccid,
                                     op_carrier_id => l_carrier_id,
                                     op_error_text => l_error_text,
                                     op_error_num => l_error_num);

 op_carrier_id := l_carrier_id;
 op_error_text := l_error_text;
 op_error_num := l_error_num;

 IF (l_carrier_id IS NULL ) THEN

 OPEN new_esn_tech_curs (ip_str_new_esn);
   FETCH new_esn_tech_curs INTO new_esn_tech_rec;
 CLOSE new_esn_tech_curs;

 BEGIN

SELECT
  x_carrier_id INTO l_tmp_carrier_id
FROM
  (
    SELECT
      *
    FROM (
          SELECT DISTINCT
          cd.x_dealer_id,
          ca.objid carrier_objid,
          ca.x_carrier_id,
          ca.carrier2personality,
          p.x_auto_port_in,
          cg.x_no_auto_port,
          p.x_block_port_in,
          p.x_parent_name,
          tab2.carrier_id pref_carr_id,
          tab2.new_rank,
          tab2.sim_profile,
          tab2.sim_profile pref_sim_profile
          FROM
          table_x_parent p,
          table_x_carrier_group cg,
          table_x_carrier ca,
          table_x_carrierdealer cd,
          (
            SELECT
              NVL( (
              SELECT
                v.x_param_value
              FROM
                table_mod_level ml, table_part_num pn, table_x_part_class_values v, table_x_part_class_params n
              WHERE
                1 = 1
                AND ml.objid = pi.n_part_inst2part_mod
                AND pn.objid = ml.part_info2part_num
                AND v.value2part_class = pn.part_num2part_class
                AND v.value2class_param = n.objid
                AND n.x_param_name = 'PHONE_GEN'
                AND ROWNUM < 2 ), '2G' ) phone_gen,
                pi.x_part_inst_status
              FROM
                table_part_inst pi
              WHERE
                1 = 1
                AND pi.part_serial_no = ip_str_new_esn
                AND pi.x_domain = 'PHONES'
          )
          pi_tab,
          (
            SELECT
              MIN(to_number(cp.new_rank) ) new_rank,
              b.carrier_id,
              a.sim_profile,
              a.min_dll_exch,
              a.max_dll_exch
            FROM
              carrierpref cp,
              npanxx2carrierzones b,
              (
                SELECT DISTINCT
                  a.zone,
                  a.st,
                  s.sim_profile,
                  a.county,
                  s.min_dll_exch,
                  s.max_dll_exch,
                  s.rank
                FROM
                  carrierzones a,
                  carriersimpref s
                WHERE
                  a.zip = ip_str_zip
                  AND a.carrier_name = s.carrier_name
                  AND new_esn_tech_rec.x_dll BETWEEN s.min_dll_exch AND s.max_dll_exch
                ORDER BY
                  s.rank ASC
              )
              a
            WHERE
              1 = 1
              AND cp.st = b.state
              AND cp.carrier_id = b.carrier_id
              AND cp.county = a.county
              AND
              (
                b.cdma_tech = new_esn_tech_rec.x_technology
                OR b.gsm_tech = new_esn_tech_rec.x_technology
              )
              AND a.sim_profile = DECODE( l_sim_profile, NULL, a.sim_profile, l_sim_profile )
              AND b.zone = a.zone
              AND b.state = a.st
            GROUP BY
              b.carrier_id,
              a.sim_profile,
              a.min_dll_exch,
              a.max_dll_exch
          )
          tab2
        WHERE 1 = 1
          AND ca.x_carrier_id = tab2.carrier_id
          AND ca.x_status || '' = 'ACTIVE'
          AND cg.objid = ca.carrier2carrier_group
          AND cg.x_status = 'ACTIVE'
          AND p.objid = cg.x_carrier_group2x_parent
          AND upper(p.x_status) = 'ACTIVE'
          AND EXISTS
          (
            SELECT 1
            FROM   table_x_frequency f,
                   mtm_x_frequency2_x_pref_tech1 f2pt,
                   table_x_pref_tech pt
            WHERE  f.objid = f2pt.x_frequency2x_pref_tech
              AND  f.x_frequency + 0 IN (
                new_esn_tech_rec.x_frequency1,
                new_esn_tech_rec.x_frequency1
              )
              AND f2pt.x_pref_tech2x_frequency = pt.objid
              AND pt.x_pref_tech2x_carrier = ca.objid
          )
          AND 1 =
          (
            CASE
              WHEN
                new_esn_tech_rec.x_technology = 'CDMA'
                AND new_esn_tech_rec.x_meid_phone = 1
                AND NVL( p.x_meid_carrier, 0 ) = 0
              THEN
                0
              WHEN
                new_esn_tech_rec.x_technology = 'CDMA'
                AND new_esn_tech_rec.x_meid_phone = 0
              THEN
                1
              ELSE
                1
            END
          )
          --CR38885
          AND tab2.sim_profile =
          (
            CASE
              WHEN
                new_esn_tech_rec.x_technology = 'GSM'
                OR new_esn_tech_rec.cdma_sim_type = 'REMOVABLE'
              THEN
                l_sim_profile
              ELSE
                'NA'
            END
          )
          -- DECODE(DECODE(new_esn_tech_rec.x_technology,'GSM',c_sim_profile,NULL), NULL, 'NULL', c_sim_profile) IN
          -- (DECODE(DECODE(new_esn_tech_rec.x_technology,'GSM',c_sim_profile,NULL), NULL, 'NULL', NVL(tab2.sim_profile, 'NULLPROFILE')))
          --CR38885
          AND EXISTS
          (
            SELECT cf.x_features2bus_org
            FROM table_x_carrier_features cf
            WHERE
              cf.x_feature2x_carrier = ca.objid
              AND cf.x_technology = new_esn_tech_rec.x_technology
              AND cf.x_features2bus_org = new_esn_tech_rec.bus_org_objid
              AND cf.x_data = new_esn_tech_rec.data_speed
              AND DECODE( cf.x_switch_base_rate, NULL, new_esn_tech_rec.non_ppe, 1 ) = new_esn_tech_rec.non_ppe
            UNION
            SELECT cf.x_features2bus_org
            FROM table_x_carrier_features cf
            WHERE cf.x_feature2x_carrier IN
              (
                SELECT
                  c2.objid
                FROM
                  table_x_carrier_group cg2,
                  table_x_carrier c2
                WHERE
                  cg2.x_carrier_group2x_parent = p.objid
                  AND c2.carrier2carrier_group = cg2.objid
              )
              AND cf.x_technology = new_esn_tech_rec.x_technology
              AND cf.x_features2bus_org =
              (
                SELECT
                  bo.objid
                FROM
                  table_bus_org bo
                WHERE
                  bo.org_id = 'NET10'
                  AND bo.objid = new_esn_tech_rec.bus_org_objid
              )
              AND cf.x_data = new_esn_tech_rec.data_speed
              AND DECODE( cf.x_switch_base_rate, NULL, new_esn_tech_rec.non_ppe, 1 ) = new_esn_tech_rec.non_ppe
          )
          -- CR38885
          AND cd.x_carrier_id = ca.x_carrier_id 					--no dealer condition is required since we need to check just carrier like TMO,ATT,VZW
          /* AND cd.x_dealer_id=case when c_safelink='FOUND' then
 '24920'
 else
 decode(cd.x_dealer_id,'24920','XXXXXXX',cd.x_dealer_id)
 end*/
          -- CR38885
          AND 1 =
          CASE
            WHEN
              pi_tab.phone_gen = '2G'
            THEN
(
              SELECT
                COUNT(*)
              FROM
                table_x_carrier_rules cr
              WHERE
                (
( cr.objid = DECODE( new_esn_tech_rec.x_technology, 'CDMA', NVL( ca.carrier2rules_cdma, ca.carrier2rules ), 'GSM', NVL( ca.carrier2rules_gsm, ca.carrier2rules ), ca.carrier2rules )
                  AND cr.x_allow_2g_react = '2G'
                  AND pi_tab.x_part_inst_status NOT IN
                  (
                    '50',
                    '150'
                  )
)
                  OR
                  (
                    cr.objid = DECODE( new_esn_tech_rec.x_technology, 'CDMA', NVL( ca.carrier2rules_cdma, ca.carrier2rules ), 'GSM', NVL( ca.carrier2rules_gsm, ca.carrier2rules ), ca.carrier2rules )
                    AND cr.x_allow_2g_act = '2G'
                    AND pi_tab.x_part_inst_status IN
                    (
                      '50',
                      '150'
                    )
                  )
                )
                AND ROWNUM < 2 )
              ELSE
                1
          END
      )
    ORDER BY
      new_rank
  )
WHERE
  ROWNUM = 1;

 EXCEPTION
   WHEN OTHERS THEN
     l_tmp_carrier_id := NULL;
 END;

 END IF;

 sa.safelink_sw_pkg.sp_is_safelink (ip_esn => ip_str_old_esn,
                                    out_flag => l_flag,
                                    out_units => l_units,
                                    op_error_code => l_s_error_code,
                                    op_error_message => l_s_error_message );

 IF l_flag = 'Y' THEN
   l_from_brand :='SAFELINK';
 END IF;

 BEGIN
   SELECT sa.util_pkg.get_short_parent_name (x_parent_name)
   INTO   l_to_phone_short_parent
   FROM   table_x_parent p,
          table_x_carrier_group cg,
          table_x_carrier carr
   WHERE  p.objid = cg.x_carrier_group2x_parent
   AND    cg.objid = carr.carrier2carrier_group
   AND    carr.x_carrier_id = NVL(l_carrier_id,l_tmp_carrier_id);
 EXCEPTION
   WHEN OTHERS THEN
     op_error_text := 'Not able to find to phone carrier'||SQLCODE;
     op_error_num  := '3001';
 END;

 IF (l_from_device_type ='SMARTPHONE' AND l_to_phone_device_type IN ('BYOP','SMARTPHONE') AND to_cst_ret.esn_part_inst_status='52') THEN--active smartphone
   l_to_phone_device_type := 'ACTIVE_SMARTPHONE';
   l_to_phone_short_parent := 'ANY';
 END IF;

 IF (l_from_device_type ='SMARTPHONE' AND l_to_phone_device_type='FEATURE_PHONE') THEN
   l_to_phone_short_parent:='ANY';
 END IF;

 IF (l_from_brand IS NULL OR l_from_device_type IS NULL OR l_to_phone_device_type IS NULL) THEN
   op_error_text := 'Not able to retrieve from and to phone details';
   op_error_num  := '3001';
   RETURN;
 END IF;

 -- CR42459 Safelink Unlimited.

 x_service_plan_rec := sa.service_plan.get_service_plan_by_esn (ip_str_new_esn);

 BEGIN
   SELECT sa.get_serv_plan_value (x_service_plan_rec.objid, 'PLAN TYPE')
     INTO v_service_plan_group
     FROM dual;
 EXCEPTION
   WHEN OTHERS THEN
     v_service_plan_group := NULL;
 END;

 IF get_device_type(ip_str_new_esn) = 'FEATURE_PHONE' AND get_data_mtg_source (ip_str_new_esn) = 'PPE' THEN

   IF sa.f_product_allowed_sl_ppe(ip_str_new_esn) = 0 AND v_service_plan_group = 'SL_UNL_PLANS' THEN

     dbms_output.put_line(ip_str_new_esn);
     op_carrier_id := l_carrier_id;
     op_error_text := 'Upgrade not permited for this device and service plan group';
     op_error_num  := '3004';
     RETURN;

   END IF;

 END IF;

 BEGIN
   SELECT block_flag,
          warning_code,
          NVL(error_code,l_error_num),
          NVL(error_message,l_error_text)
   INTO   l_block_flag,
          op_warning_code,
          op_error_num,
          op_error_text
   FROM   phone_upgrade_scenarios
   WHERE  brand = l_from_brand
   AND    from_phone_device_type = l_from_device_type
   AND    (NVL(billing_plan,'X') = NVL(l_units,'X') OR billing_plan IS NULL)
   AND    to_phone_short_parent = l_to_phone_short_parent
   AND    to_phone_device_type = l_to_phone_device_type
   AND    channel = ip_channel;

   IF (l_block_flag = 'Y') THEN
     op_carrier_id := NULL;
   END IF;

 EXCEPTION
   WHEN no_data_found THEN
     op_carrier_id := l_carrier_id;
     op_error_text := l_error_text;
     op_error_num := l_error_num;
     RETURN;
   WHEN OTHERS THEN
     op_carrier_id := l_carrier_id;
     op_error_text := 'Error in searching block scenarios'||SQLCODE;
     op_error_num  := '3001';
     RETURN;
 END;

 dbms_output.put_line ('from Brand '||l_from_brand);
 dbms_output.put_line ('from phone device type '||l_from_device_type);
 dbms_output.put_line ('to phone Device type'||l_to_phone_device_type);
 dbms_output.put_line ('to short_parent_name '||l_to_phone_short_parent);
 dbms_output.put_line ('units '||l_units);
 dbms_output.put_line ('op_carrier_id '||op_carrier_id);
 dbms_output.put_line ('op_error_text '||op_error_text);
 dbms_output.put_line ('op_error_num '||op_error_num);
 dbms_output.put_line ('op_warning_code '||op_warning_code);

EXCEPTION
  WHEN OTHERS THEN
    op_error_text := substr(sqlerrm,1,100);
    op_error_num := SQLCODE;
END verify_wrapper;
--
--
PROCEDURE update_contact_optout (ip_old_esn      IN    VARCHAR2,
                                 ip_new_esn      IN    VARCHAR2,
                                 ip_channel      IN    VARCHAR2 DEFAULT NULL,
                                 ip_org_id       IN    table_bus_org.org_id%TYPE DEFAULT 'WFM',
                                 ip_off_flag     IN    VARCHAR2 DEFAULT 'N',
                                 op_error_text   OUT   VARCHAR2,
                                 op_error_num    OUT   VARCHAR2)
IS
-- CR52938 - Ensure the ESN level contact preference opt-in/out flags are copied to new ESN contact preferences when an UPGRADE is performed.
-- CR52938 - Change is focused for WFM and TAS and other brands and channels.  The WEB (account) level contact preferences are not to be affected.
-- CR52938 - Upgrade to be performed in the same WEB account.
-- CR52938 - New requirement added - All the data from the old phone must be moved to new phone and delete everything on old phone.
-- CR52938 - Do not remove the phone from MyAccount. Removing table sa.table_web_user twu from main query.
-- CR52938 - Change the Upgrade Flow: Add a Nick name attribute and transfer it from old phone to new phone.
-- CR52938 - Flag meaning: 1 = Yes, do not send communications -- 0 = No, send communications.
--

CURSOR get_cont_cur (c_esn     VARCHAR2,
                     c_org_id  VARCHAR2) IS
  SELECT pi.objid pi_objid,
         pi.part_serial_no,
         tbo.org_id,
         tbo.objid org_objid,
         cpi.objid cpi_objid,
         TRIM(cpi.x_esn_nick_name) x_esn_nick_name,
         pi.x_part_inst2contact tas_contact_objid,
         tcw.objid web_contact_objid,
         tcw.x_cust_id web_x_cust_id
    FROM sa.table_part_inst pi,
         sa.table_mod_level ml,
         sa.table_part_num pn,
         sa.table_part_class pc,
         sa.table_bus_org tbo,
         sa.table_x_contact_part_inst cpi,
         sa.table_contact tcw
   WHERE tcw.objid(+) = cpi.x_contact_part_inst2contact
     AND cpi.x_contact_part_inst2part_inst(+) = pi.objid
     AND tbo.org_id = c_org_id
     AND tbo.objid = pn.part_num2bus_org
     AND pc.objid = pn.part_num2part_class
     AND pn.objid = ml.part_info2part_num
     AND ml.objid = pi.n_part_inst2part_mod
     AND pi.x_domain = 'PHONES'
     AND pi.part_serial_no = c_esn;

CURSOR get_flag_cur (c_cont_objid  NUMBER,
                     c_org_objid   NUMBER) IS
  SELECT tct.objid tas_contact_objid,
         tct.x_cust_id tas_x_cust_id,
         tca.objid adds_objid,
         tca.add_info2web_user,
         tca.add_info2bus_org,
         tca.source_system,
         tca.x_do_not_mobile_ads,
         tca.x_prerecorded_consent,
         tca.x_do_not_email,
         tca.x_do_not_phone,
         tca.x_do_not_sms,
         tca.x_do_not_mail,
         tca.x_do_not_loyalty_email,
         tca.x_do_not_loyalty_sms
    FROM sa.table_contact tct,
         sa.table_x_contact_add_info tca
   WHERE tca.add_info2bus_org = c_org_objid
     AND tca.add_info2contact = tct.objid
     AND tct.objid = c_cont_objid;

get_old_cont_rec    get_cont_cur%ROWTYPE;
get_new_cont_rec    get_cont_cur%ROWTYPE;
get_old_flag_rec    get_flag_cur%ROWTYPE;
get_new_flag_rec    get_flag_cur%ROWTYPE;

l_action            VARCHAR2(240);
l_key               VARCHAR2(240);
l_program_name      VARCHAR2(240);

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  op_error_text  := NULL;
  op_error_num   := NULL;

  DBMS_OUTPUT.PUT_LINE ('Old ESN: '||ip_old_esn||' - New ESN: '||ip_new_esn||' - Org: '||ip_org_id||' - Channel: '||ip_channel);

  l_action       := 'UpdateCustContactOptOut';
  l_key          := '<'||ip_old_esn||'><'||ip_new_esn||'><'||ip_org_id||'><'||ip_off_flag||'>';
  l_program_name := 'VERIFY_PHONE_UPGRADE_PKG.update_contact_optout';

  IF (ip_old_esn IS NULL) OR (ip_new_esn IS NULL) THEN
    op_error_text := 'ERROR - Invalid or Missing Input ESN Values: <'||ip_old_esn||'><'||ip_new_esn||'>';
    op_error_num  := '0';
    DBMS_OUTPUT.PUT_LINE (op_error_text);
    sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action       => l_action,
                                            ip_key          => l_key,
                                            ip_program_name => l_program_name,
                                            ip_error_text   => op_error_text);
    RETURN;
  END IF;

  OPEN get_cont_cur (ip_old_esn, ip_org_id);
  FETCH get_cont_cur INTO get_old_cont_rec;

    IF get_cont_cur%NOTFOUND THEN
      CLOSE get_cont_cur;
      op_error_text := 'No data found for ESN(1): '||ip_old_esn||' - ORG: '||ip_org_id;
      op_error_num  := '1';
      DBMS_OUTPUT.PUT_LINE (op_error_text);
      sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action       => l_action,
                                              ip_key          => l_key,
                                              ip_program_name => l_program_name,
                                              ip_error_text   => op_error_text);
      RETURN;
    END IF;

  CLOSE get_cont_cur;

  OPEN get_cont_cur (ip_new_esn, ip_org_id);
  FETCH get_cont_cur INTO get_new_cont_rec;

    IF get_cont_cur%NOTFOUND THEN
      CLOSE get_cont_cur;
      op_error_text := 'No data found for ESN(2): '||ip_old_esn||' - ORG: '||ip_org_id;
      op_error_num  := '2';
      DBMS_OUTPUT.PUT_LINE (op_error_text);
      sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action       => l_action,
                                              ip_key          => l_key,
                                              ip_program_name => l_program_name,
                                              ip_error_text   => op_error_text);
      RETURN;
    END IF;

  CLOSE get_cont_cur;

  IF (get_old_cont_rec.tas_contact_objid IS NULL) OR
     (get_old_cont_rec.web_contact_objid IS NULL) THEN

    op_error_text := 'Missing Contact for old ESN(1) <'||ip_old_esn||'><'||get_old_cont_rec.tas_contact_objid||'><'||get_old_cont_rec.web_contact_objid||'>';
    op_error_num  := '3';
    DBMS_OUTPUT.PUT_LINE (op_error_text);
    sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action       => l_action,
                                            ip_key          => l_key,
                                            ip_program_name => l_program_name,
                                            ip_error_text   => op_error_text);
    RETURN;

  ELSIF (get_new_cont_rec.tas_contact_objid IS NULL) OR
        (get_new_cont_rec.web_contact_objid IS NULL) THEN

    op_error_text := 'Missing Contact for new ESN(2) <'||ip_new_esn||'><'||get_new_cont_rec.tas_contact_objid||'><'||get_new_cont_rec.web_contact_objid||'>';
    op_error_num  := '4';
    DBMS_OUTPUT.PUT_LINE (op_error_text);
    sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action       => l_action,
                                            ip_key          => l_key,
                                            ip_program_name => l_program_name,
                                            ip_error_text   => op_error_text);
    RETURN;

  END IF;

  OPEN get_flag_cur (get_old_cont_rec.tas_contact_objid, get_old_cont_rec.org_objid);
  FETCH get_flag_cur INTO get_old_flag_rec;

    IF get_flag_cur%NOTFOUND THEN
      CLOSE get_flag_cur;
      op_error_text := 'No data found for old contact OBJID(1): '||get_old_cont_rec.tas_contact_objid||' - '||get_old_cont_rec.web_contact_objid;
      op_error_num  := '5';
      DBMS_OUTPUT.PUT_LINE (op_error_text);
      sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action       => l_action,
                                              ip_key          => l_key,
                                              ip_program_name => l_program_name,
                                              ip_error_text   => op_error_text);
      RETURN;
    END IF;

  CLOSE get_flag_cur;

  OPEN get_flag_cur (get_new_cont_rec.tas_contact_objid, get_new_cont_rec.org_objid);
  FETCH get_flag_cur INTO get_new_flag_rec;

    IF get_flag_cur%NOTFOUND THEN
      CLOSE get_flag_cur;
      op_error_text := 'No data found for new contact OBJID(2): '||get_new_cont_rec.tas_contact_objid||' - '||get_new_cont_rec.web_contact_objid;
      op_error_num  := '6';
      DBMS_OUTPUT.PUT_LINE (op_error_text);
      sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action       => l_action,
                                              ip_key          => l_key,
                                              ip_program_name => l_program_name,
                                              ip_error_text   => op_error_text);
      RETURN;
    END IF;

  CLOSE get_flag_cur;

  DBMS_OUTPUT.PUT_LINE ('Original Contact ID: '||get_old_cont_rec.web_contact_objid||' - New Contact ID: '||get_new_cont_rec.web_contact_objid);

  IF (get_old_cont_rec.web_contact_objid = get_new_cont_rec.web_contact_objid) THEN

    BEGIN
      UPDATE sa.table_x_contact_add_info tca
         SET tca.x_do_not_mobile_ads    = get_old_flag_rec.x_do_not_mobile_ads,
             tca.x_prerecorded_consent  = get_old_flag_rec.x_prerecorded_consent,
             tca.x_do_not_email         = get_old_flag_rec.x_do_not_email,
             tca.x_do_not_phone         = get_old_flag_rec.x_do_not_phone,
             tca.x_do_not_sms           = get_old_flag_rec.x_do_not_sms,
             tca.x_do_not_mail          = get_old_flag_rec.x_do_not_mail,
             tca.x_do_not_loyalty_email = get_old_flag_rec.x_do_not_loyalty_email,
             tca.x_do_not_loyalty_sms   = get_old_flag_rec.x_do_not_loyalty_sms,
             tca.x_last_update_date     = sysdate
       WHERE tca.objid            = get_new_flag_rec.adds_objid
         AND tca.add_info2contact = get_new_flag_rec.tas_contact_objid
         AND tca.add_info2bus_org = get_new_cont_rec.org_objid;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        op_error_text := 'ERROR - While Updating New ESN Contact Opt-In Setup - '||SUBSTR(SQLERRM,1,100);
        op_error_num  := '7';
        DBMS_OUTPUT.PUT_LINE (op_error_text);
        sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action       => l_action,
                                                ip_key          => l_key,
                                                ip_program_name => l_program_name,
                                                ip_error_text   => op_error_text);
        RETURN;
    END;

    BEGIN
      UPDATE sa.table_x_contact_part_inst
         SET x_esn_nick_name = get_old_cont_rec.x_esn_nick_name||'_Old',
             x_is_default = 0
       WHERE TRIM(x_esn_nick_name) IS NOT NULL
         AND SUBSTR(x_esn_nick_name, LENGTH(x_esn_nick_name)-3) <> '_Old'
         AND objid = get_old_cont_rec.cpi_objid;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        op_error_text := 'ERROR - While Updating Old ESN Nickname Setup - '||SUBSTR(SQLERRM,1,100);
        op_error_num  := '8';
        DBMS_OUTPUT.PUT_LINE (op_error_text);
        sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action       => l_action,
                                                ip_key          => l_key,
                                                ip_program_name => l_program_name,
                                                ip_error_text   => op_error_text);
        RETURN;
    END;

    BEGIN
      UPDATE sa.table_x_contact_part_inst
         SET x_esn_nick_name = get_old_cont_rec.x_esn_nick_name,
             x_is_default = 1
       WHERE objid = get_new_cont_rec.cpi_objid
         AND SUBSTR(get_old_cont_rec.x_esn_nick_name, LENGTH(get_old_cont_rec.x_esn_nick_name)-3) <> '_Old';
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        op_error_text := 'ERROR - While Updating New ESN Nickname Setup - '||SUBSTR(SQLERRM,1,100);
        op_error_num  := '9';
        DBMS_OUTPUT.PUT_LINE (op_error_text);
        sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action       => l_action,
                                                ip_key          => l_key,
                                                ip_program_name => l_program_name,
                                                ip_error_text   => op_error_text);
        RETURN;
    END;

    -- CR52938 - Setting old ESN flags to default values when upgrade only when requested (Y).
    IF NVL(ip_off_flag,'N') = 'Y' THEN

      BEGIN
        UPDATE sa.table_x_contact_add_info tca
           SET tca.x_do_not_mobile_ads    = 0,
               tca.x_prerecorded_consent  = 0,
               tca.x_do_not_email         = 1,
               tca.x_do_not_phone         = 1,
               tca.x_do_not_sms           = 1,
               tca.x_do_not_mail          = 1,
               tca.x_do_not_loyalty_email = 0,
               tca.x_do_not_loyalty_sms   = 0,
               tca.x_last_update_date     = sysdate
         WHERE tca.objid             = get_old_flag_rec.adds_objid
           AND tca.add_info2contact  = get_old_flag_rec.tas_contact_objid
           AND tca.add_info2contact <> get_new_flag_rec.tas_contact_objid
           AND tca.add_info2bus_org  = get_old_cont_rec.org_objid;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          op_error_text := 'ERROR - While Updating Old ESN Contact Opt-In Setup - '||SUBSTR(SQLERRM,1,100);
          op_error_num  := '10';
          DBMS_OUTPUT.PUT_LINE (op_error_text);
          sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action       => l_action,
                                                  ip_key          => l_key,
                                                  ip_program_name => l_program_name,
                                                  ip_error_text   => op_error_text);
          RETURN;
      END;

    END IF;

    COMMIT;

  ELSE

    op_error_text := 'ERROR - New ESN not included in the original account: <'||get_old_cont_rec.web_contact_objid||'><'||get_new_cont_rec.web_contact_objid||'>';
    op_error_num  := '11';
    DBMS_OUTPUT.PUT_LINE (op_error_text);
    sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action       => l_action,
                                            ip_key          => l_key,
                                            ip_program_name => l_program_name,
                                            ip_error_text   => op_error_text);
    RETURN;

  END IF;

  DBMS_OUTPUT.PUT_LINE ('Completed Customer Contact Opt-In Flags and Nickname Update: '||NVL(op_error_text,'SUCCESS'));

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    op_error_text := 'ERROR - Main update_contact_optout process failed - '||SUBSTR(SQLERRM,1,100);
    op_error_num := '12';
    DBMS_OUTPUT.PUT_LINE (op_error_text);
    sa.TOSS_UTIL_PKG.insert_error_tab_proc (ip_action       => l_action,
                                            ip_key          => l_key,
                                            ip_program_name => l_program_name,
                                            ip_error_text   => op_error_text);
END update_contact_optout;
--
--
END verify_phone_upgrade_pkg;
/