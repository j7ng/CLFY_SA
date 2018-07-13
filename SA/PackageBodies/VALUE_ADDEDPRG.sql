CREATE OR REPLACE PACKAGE BODY sa."VALUE_ADDEDPRG"
AS
 --------------------------------------------------------------------------------------------
 --$RCSfile: VALUE_ADDEDPRG_PKB.sql,v $
 --$ Revision: 1.105 2016/09/22 16:36:45 vboddeda
 --$ Added VAS case type
 --$ Revision: 1.104 2016/08/29 19:21:45 skota
 --$ $Log: VALUE_ADDEDPRG_PKB.sql,v $
 --$ Revision 1.117  2017/12/21 18:34:19  sinturi
 --$ Asurion fixes
 --$
 --$ Revision 1.116  2017/12/06 19:50:54  sinturi
 --$ changes added
 --$
 --$ Revision 1.115  2017/12/06 19:45:52  sinturi
 --$ Removed null condition
 --$
 --$ Revision 1.113  2017/09/28 21:38:50  smeganathan
 --$ added condition to restrict the old code for legacy Warranty programs
 --$
 --$ Revision 1.112 2017/02/17 20:48:17 rpednekar
 --$ CR47723
 --$
 --$ Revision 1.111 2016/10/17 18:52:09 tbaney
 --$ Corrected logic for CR44428.
 --$
 --$ Revision 1.110 2016/10/13 19:16:14 tbaney
 --$ changed from s_title to title.
 --$
 --$ Revision 1.109 2016/10/12 15:18:24 tbaney
 --$ Modified logic for BYOP cursor.
 --$
 --$ Revision 1.108 2016/10/12 15:04:39 tbaney
 --$ Changed Case for BYOP.
 --$
 --$ Revision 1.107 2016/10/12 14:27:35 tbaney
 --$ Added check for byop handset protection.
 --$
 --$ Revision 1.106 2016/09/23 18:32:26 vboddeda
 --$ 44428 - HPP Case Updates fixes
 --$
 --$ Revision 1.103 2016/08/29 19:21:45 skota
 --$ Modified the ZIPCODE
 --$
 --$ Revision 1.101 2016/08/15 15:46:14 skota
 --$ Tune the queries CR43802
 --$
 --$ Revision 1.100 2016/07/20 16:13:55 skota
 --$ modified
 --$
 --$ Revision 1.99 2016/07/19 18:37:43 skota
 --$ Modified
 --$
 --$ Revision 1.98 2016/07/18 14:40:59 skota
 --$ modified
 --$
 --$ Revision 1.97 2016/07/15 20:59:22 skota
 --$ modified
 --$
 --$ Revision 1.96 2016/07/01 20:14:09 skota
 --$ modified for HPP process changes
 --$
 --$ Revision 1.95 2016/06/28 21:31:58 skota
 --$ modified the hpp process changes
 --$
 --$ Revision 1.92 2016/03/09 15:17:49 rpednekar
 --$ CR39651- New column x_email_id of table sa.x_program_claims is used.
 --$
 --$ Revision 1.82 2015/08/26 20:39:44 smeganathan
 --$ Changes for 35913 i??i??i??i??i??i??i??i???? My accounts - changed the comments
 --$
 --$ Revision 1.81 2015/08/11 19:31:26 smeganathan
 --$ Changes for 35913 My accounts
 --$
 --$ Revision 1.80 2015/07/29 20:39:50 aganesan
 --$ CR35913 - My account changes.
 --$
 --$ Revision 1.80 2015/07/13 10:00:00 sethiraj
 --$ CR35913 - New Function Geteligiblewtyprogramsv2
 --$ Modified exisiting Procedure getCurrentWarrantyProgram
 --$
 --$ Revision 1.79 2015/07/02 16:09:20 icanavan
 --$ 35801 UPDATED JOB
 --$
 --$ Revision 1.78 2015/04/10 21:51:36 ddevaraj
 --$ FOR CR31715
 --$
 --$ Revision 1.75 2015/04/10 15:52:27 ddevaraj
 --$ FOR CR31715
 --$
 --$ Revision 1.74 2015/04/10 15:09:52 ddevaraj
 --$ FOR CR31715
 --$
 --$ Revision 1.67 2015/02/23 15:15:09 vkashmire
 --$ CR32396 - remove byop-esn and use pseudo-esn
 --$
 --$ Revision 1.66 2015/02/04 23:00:43 oarbab
 --$ CR31712 NA should not be sent for the manu_code for BYOP
 --$
 --$ Revision 1.65 2014/11/10 19:16:37 oarbab
 --$ *** empty log message ***
 --$
 --$ Revision 1.62 2014/10/02 19:29:38 vkashmire
 --$ CR29079 byop case update proc separated from original case update proc
 --$
 --$ Revision 1.61 2014/09/25 20:49:24 vkashmire
 --$ CR29079 - 035 action code added
 --$
 --$ Revision 1.60 2014/09/19 23:36:44 oarbab
 --$ Defect 131 fix
 --$
 --$ Revision 1.59 2014/09/18 22:12:38 oarbab
 --$ updated date range to include sysdate in the fetch range for CR27087
 --$
 --$ Revision 1.58 2014/09/17 19:33:52 vkashmire
 --$ CR29489 - case update function modified
 --$
 --$ Changes by OArbab for CR30004
 --$ changes related to CR30004 removed
 --$ package formatting and indentation
 --$
 --$ Revision 1.56 2014/09/11 19:41:36 vkashmire
 --$ CR29638-Annual renewal sales file
 --$
 --$ Revision 1.55 2014/09/11 16:29:20 vkashmire
 --$ CR29489
 --$
 --$ Revision 1.54 2014/09/08 16:30:30 vkashmire
 --$ CR29489 - defect #36 - show amount deductible
 --$
 --$ Revision 1.53 2014/09/04 20:55:20 oarbab
 --$ CR30004_HPP_Only1Renew4Annual
 --$
 --$ Revision 1.52 2014/09/03 21:28:11 vkashmire
 --$ CR29489
 --$
 --$ Revision 1.51 2014/09/03 19:15:08 vkashmire
 --$ CR29489
 --$
 --$ Revision 1.50 2014/08/29 21:33:06 vkashmire
 --$ CR29489
 --$
 --$ Revision 1.49 2014/08/29 15:30:21 vkashmire
 --$ CR29489 - pricing issue fixed
 --$
 --$ Revision 1.48 2014/08/28 20:22:54 vkashmire
 --$ CR29489
 --$
 --$ Revision 1.47 2014/08/28 15:19:36 vkashmire
 --$ CR29489 code improvements
 --$
 --$ Revision 1.46 2014/08/27 15:45:24 vkashmire
 --$ CR29489 byop change
 --$
 --$ Revision 1.45 2014/08/26 16:07:15 oarbab
 --$ CR29638 code was missin
 --$
 --$ Revision 1.44 2014/08/25 20:55:16 vkashmire
 --$ CR29489
 --$
 --$ Revision 1.43 2014/08/25 16:51:36 vkashmire
 --$ CR29489
 --$
 --$ Revision 1.42 2014/08/22 20:57:13 vkashmire
 --$ CR22313 HPP Phase 2
 --$ CR29489 HPP BYOP
 --$ CR27087
 --$ CR29638
 --$
 --$ Revision 1.41 2014/08/22 16:12:30 oarbab
 --$ CR27087 to create annual renewals Function
 --$ CR29638 to send billing part numbers inding in M for recurring and ending in E for first enrollment
 --$
 --$ Revision 1.40 2014/07/18 20:08:29 mvadlapally
 --$ CR29595 Car Connection - change in condition for table_x_case_conf_hdr
 --$
 --$ Revision 1.38 2014/06/11 23:56:46 mvadlapally
 --$ CR28538 Car Connection Post Rollout
 --$
 --$ Revision 1.37 2014/05/30 17:45:50 mvadlapally
 --$ CR28538 - Car Connection Post Rollout - merged with Prod
 --$
 --$ Revision 1.36 2014/04/11 16:20:10 ymillan
 --$ CR26941
 --$
 --$ Revision 1.35 2014/04/11 15:56:47 ymillan
 --$ CR26941
 --$
 --$ Revision 1.33 2014/03/13 19:07:29 oarbab
 --$ CR26009: Modify CONTRACT_PURCHASE_DATE as X_ENROLLED_DATE instead of X_INSERT_DATE in sales file.
 --$
 --$ Revision 1.32 2014/03/12 20:47:33 oarbab
 --$ CR27143: Suspension Process Fixes; Send DEENROLLED, SUSPENDED, READYTOREENROLL if not already sent to SN as SUSPENDED contracts.
 --$
 --$ Revision 1.28 2013/11/11 20:55:30 ymillan
 --$ CR23111
 --$
 --$ Revision 1.27 2013/11/06 17:12:21 ymillan
 --$ CR23111
 --$
 --$ Revision 1.26 2013/11/05 22:00:32 ymillan
 --$ CR23111
 --$
 --$ Revision 1.25 2013/10/18 19:44:38 ymillan
 --$ CR23111
 --$
 --$ Revision 1.23 2013/10/03 21:49:32 oarbab
 --$ added notes for CR24219: ignore ESN status
 --$
 --$ Revision 1.22 2013/09/20 16:01:07 ymillan
 --$ CR23485
 --$
 --$ Revision 1.21 2013/09/10 20:58:19 oarbab
 --$ CR23882: Get customer's first activation date on the ESN. OARBAB
 --$ CR24219: Ignore ESN status. OARBAB
 --$
 --$ Revision 1.18 2013/07/19 20:37:54 oarbab
 --$ CR24444 -- Allowing for multiple brands
 --$
 --$
 --$ Revision 1.11 2013/02/08 14:43:53 ymillan
 --$ CR23065
 --$
 --$ Revision 1.10 2013/01/15 15:45:18 ymillan
 --$ CR22404
 --$
 --$ Revision 1.9 2013/01/11 16:57:13 icanavan
 --$ Added check on x_charge_frq_code
 --$
 --$ Revision 1.8 2012/12/14 23:50:44 mmunoz
 --$ CR22380 : Handset Protection (Master CR18994)
 --$
 --$ Revision 1.7 2012/12/13 16:12:50 mmunoz
 --$ CR22380 : Handset Protection (Master CR18994)
 --$
 --$ Revision 1.6 2012/12/06 18:45:51 mmunoz
 --$ CR22380 : Handset Protection
 --$
 --$ Revision 1.5 2012/12/05 00:05:17 mmunoz
 --$ CR22380 Handset Protection
 --$
 --$ Revision 1.4 2012/11/20 14:18:21 mmunoz
 --$ CR22380 : Added insert to billing_log
 --$
 --$ Revision 1.3 2012/11/02 19:17:48 mmunoz
 --$ CR22380 : Updated cursor get_site_part to consider cases when igate/ota is down
 --$
 --$ Revision 1.2 2012/10/29 14:48:52 mmunoz
 --$ CR22380 : Updated to manage the phone age to be elegible using parameters
 --$
 --$ Revision 1.1 2012/10/26 21:31:35 mmunoz
 --$ CR22380 Handset Protection Program - Phase I
 --$
 /***************************************
 CR22313 HPP Phase 2 section 19
 21-Aug-2014 CR22313 HPP Phase2 vkashmire
 If Service net sends ESNs which has been requested to cancel the enrollment
 and if the ESN is enrolled to Monthly HPP then set them as DEENROLL_SCHEDULED and x_exp_date = x_next_charge_date
 if the ESN is enrolled to Annual then let them updated as per previous existing logic
 DEENROLL_SCHEDULED means that those ESN's will get de-enrolled at next charge date
 but till that time they can fully avail the enrolled program

 21-Aug-2014 CR29489 HPP BYOP vkashmire
 Below procs/Functions modified for CR29489
 getEligibleWtyPrograms
 Claim_Creation
 Process_Ack
 getcaseupdates_hppbyop
 *****************************************/
 --------------------------------------------------------------------------------------------
 CURSOR get_zipCode_cur ( ip_esn IN VARCHAR2)
 IS
 SELECT cd.x_value
 FROM table_case c ,
 table_x_case_detail cd
 WHERE c.x_esn = ip_esn
 AND cd.x_name
 || '' = 'ACTIVATION_ZIP_CODE'
 AND cd.detail2case = c.objid + 0
 and c.X_CASE_TYPE ='Port In'
 and c.CREATION_TIME >= trunc(sysdate)
 ORDER BY c.creation_time DESC;

 CURSOR get_site_part (
 ip_objid IN NUMBER)
 IS
 --If for any reasons igate/ota is down the part_status is CarrierPending and Handset Protection Program should be offered
 SELECT sp.objid,
 sp.part_status,
 sp.x_service_id,
 --phone age is based on the initial activation date or the first activation after the phone was refurbished
 (SELECT TRUNC (SYSDATE - MIN (init_act.install_date)) phone_age
 FROM table_site_part init_act
 WHERE init_act.x_service_id = sp.x_service_id --
 AND NVL (x_refurb_flag, 0) <> 1)
 phone_age,
 sp.x_zipcode
 FROM sa.TABLE_SITE_PART sp
 WHERE sp.objid = ip_objid;

 CURSOR get_part_inst (
 ip_esn IN VARCHAR2)
 IS
 SELECT pi.objid,
 pi.part_serial_no,
 pi.x_part_inst_status,
 sa.SP_METADATA.GETPRICE (PN.PART_NUMBER, 'TIER SERVICE NET')
 X_RETAIL_PRICE, --CR23111
 pn.part_num2part_class,
 pi.x_part_inst2site_part,
 pn.part_num2bus_org -- CR24444
 FROM sa.TABLE_PART_INST pi,
 sa.TABLE_MOD_LEVEL ml,
 sa.TABLE_PART_NUM pn
 WHERE pi.part_serial_no = ip_esn
 AND pi.x_domain = 'PHONES'
 AND ml.objid = pi.n_part_inst2part_mod
 AND pn.objid = ml.part_info2part_num;

 get_site_part_rec get_site_part%ROWTYPE;
 get_part_inst_rec get_part_inst%ROWTYPE;
 get_zipCode_REC get_zipCode_cur%ROWTYPE;

 FUNCTION SEQ (ip_TABLE IN VARCHAR2)
 RETURN NUMBER
 IS
 OBJID NUMBER;
 BEGIN
 SELECT CASE ip_TABLE
 WHEN 'X_PROGRAM_CLAIMS'
 THEN
 sa.SEQ_X_PROGRAM_CLAIMS.NEXTVAL
 WHEN 'X_CONTRACT_RESPONSES'
 THEN
 sa.SEQ_X_CONTRACT_RESPONSES.NEXTVAL
 ELSE
 NULL
 END
 INTO OBJID
 FROM DUAL;

 RETURN OBJID;
 END SEQ;

 FUNCTION get_param_value (ip_param_name IN VARCHAR2)
 RETURN TABLE_X_PARAMETERS.X_PARAM_VALUE%TYPE
 IS
 CURSOR GET_PARAMETERS (IP_PARAM_NAME IN VARCHAR2)
 IS
 SELECT X_PARAM_VALUE
 FROM TABLE_X_PARAMETERS
 WHERE X_PARAM_NAME = IP_PARAM_NAME;

 param_rec get_parameters%ROWTYPE;
 BEGIN
 OPEN GET_PARAMETERS (IP_PARAM_NAME);

 FETCH get_parameters INTO param_rec;

 CLOSE GET_PARAMETERS;

 RETURN param_rec.X_PARAM_VALUE;
 END get_param_value;

 --To get the equipement purchase date CR41167
 function get_equipment_purchase_date (ip_esn IN VARCHAR2) return date
 is
 l_equipment_purchase_date date := NULL;
 BEGIN
 select max(install_date)
 into l_equipment_purchase_date
 from (select trunc (min (init_act.install_date)) install_date
 from table_site_part init_act
 where init_act.x_service_id = ip_esn
 and nvl (x_refurb_flag, 0) <> 1
 and 1<>(select count (*) from table_site_part sp where sp.x_service_id = init_act.x_service_id)
 union
 select trunc(install_date)
 from table_site_part m
 where m.x_service_id = ip_esn
 and 1=(select count (*) from table_site_part sp where sp.x_service_id = m.x_service_id)
 );

 return l_equipment_purchase_date;
 EXCEPTION
 WHEN OTHERS THEN
 return l_equipment_purchase_date;
 END;

 --to get the retial price of the first time enrolement CR42425
 function get_equipment_retail_price (ip_esn IN VARCHAR2) return varchar2
 is
 l_old_equipment_retail varchar2(30) := NULL;
 BEGIN
 SELECT equipment_retail
 INTO l_old_equipment_retail
 FROM (SELECT equipment_retail
 FROM sa.sn_pending_warrany_sales
 WHERE serial_number = ip_esn
 AND update_action_code = '001'
 ORDER BY load_date)
 WHERE ROWNUM < 2;

 return l_old_equipment_retail;
 EXCEPTION
 WHEN OTHERS THEN
 return l_old_equipment_retail;
 END;




 PROCEDURE gethandsetinf (ip_esn IN VARCHAR2,
 op_error_code IN OUT VARCHAR2,
 op_error_text IN OUT VARCHAR2)
 IS
 BEGIN
 IF ip_esn IS NOT NULL
 THEN
 OPEN get_part_inst (ip_esn);

 FETCH get_part_inst INTO get_part_inst_rec;

 IF get_part_inst%NOTFOUND
 THEN
 CLOSE get_part_inst;

 op_error_code := '2';
 op_error_text := 'ESN not found';
 RETURN;
 END IF;

 CLOSE get_part_inst;

 OPEN get_site_part (get_part_inst_rec.x_part_inst2site_part);

 FETCH get_site_part INTO get_site_part_rec;

 IF get_site_part%NOTFOUND
 THEN
 CLOSE get_site_part;

 op_error_code := '1';
 op_error_text := 'MIN not found';
 RETURN;
 END IF;

 CLOSE get_site_part;
 ELSE
 op_error_code := '3';
 op_error_text := 'ESN must be entered';
 END IF;
 END getHandsetInf;

 FUNCTION is_restricted_handset (PP_OBJID IN NUMBER, pc_objid IN NUMBER)
 RETURN BOOLEAN
 IS
 v_restricted BOOLEAN;
 v_cnt NUMBER;
 BEGIN
 v_restricted := FALSE;

 SELECT COUNT (*)
 INTO v_cnt
 FROM X_MTM_PROGRAM_HANDSET xph
 WHERE PROGRAM_PARAM_OBJID = pp_objid AND PART_CLASS_OBJID = pc_objid;

 IF v_cnt > 0
 THEN
 v_restricted := TRUE;
 END IF;

 RETURN v_restricted;
 END is_restricted_handset;

 FUNCTION is_restricted_state (pp_objid IN NUMBER, ip_zipcode IN VARCHAR2)
 RETURN BOOLEAN
 IS
 v_restricted BOOLEAN;
 v_cnt NUMBER;
 BEGIN
 v_restricted := FALSE;

 SELECT COUNT (*)
 INTO v_cnt
 FROM TABLE_X_ZIP_CODE tzc, sa.X_MTM_PGM_RESTRICT_STATE xprs
 WHERE tzc.X_ZIP = ip_zipcode
 AND xprs.program_param_objid = pp_objid
 AND xprs.x_state = tzc.x_state;

 IF v_cnt > 0
 THEN
 v_restricted := TRUE;
 END IF;

 RETURN v_restricted;
 END is_restricted_state;

 FUNCTION is_valid_status (PP_OBJID IN NUMBER, ip_status IN VARCHAR2)
 RETURN BOOLEAN
 IS
 v_status BOOLEAN;
 v_cnt NUMBER;
 BEGIN
 v_status := FALSE;

 SELECT COUNT (*)
 INTO v_cnt
 FROM sa.X_MTM_PERMITTED_ESNSTATUS xpe, sa.TABLE_X_CODE_TABLE tct
 WHERE xpe.PROGRAM_PARAM_OBJID = pp_objid
 AND tct.objid = xpe.ESN_STATUS_OBJID
 AND TCT.X_CODE_TYPE = 'PS'
 AND tct.X_CODE_NUMBER = ip_status;

 IF V_CNT > 0
 THEN
 v_status := TRUE;
 END IF;

 RETURN v_status;
 END is_valid_status;

 PROCEDURE getCurrentWarrantyProgram (ip_esn IN VARCHAR2,
 op_result_set OUT SYS_REFCURSOR,
 op_error_code OUT VARCHAR2,
 op_error_text OUT VARCHAR2)
 IS
 /*
 CR29489 25-Aug-2014 Vkashmire
 Add a column to output refcursor - X_EXP_DATE
 Since HPP BYOP is One time only; there is no X_NEXT_CHARGE_DATE ;
 So program expiration date will be X_EXP_DATE
 */
 BEGIN
 op_error_code := '0';
 op_error_text := 'Success';
 ------------CR31715
 OPEN get_zipCode_cur(IP_ESN);
 FETCH get_zipCode_cur
 INTO get_zipCode_REC;
 IF get_zipCode_cur%NOTFOUND THEN
 getHandsetInf (ip_esn, op_error_code, op_error_text);
END IF;
CLOSE get_zipCode_cur;


OPEN get_part_inst (ip_esn);
 FETCH get_part_inst INTO get_part_inst_rec;
 CLOSE get_part_inst;
------------CR31715
 --if op_error_code = 0
 --then
 BEGIN
 OPEN op_result_set FOR
 SELECT /*+ ORDERED */
 pe.objid PROG_ID,
 pp.x_program_name,
 pp.x_program_desc,
 tr.price_deductible AS x_retail_price, -- CR29489
 pe.x_enrollment_status status,
 PN.PART_NUMBER,
 pe.x_next_charge_date expirationDate,
 pp.x_charge_FRQ_code, -- CR23058 MONTHLY or 365
 pe.x_exp_date, -- CR29489 - column added - pe.x_exp_date
 Pe.X_Enrolled_Date,
 mi.mobile_name_script_id AS mobile_name,
 mi.mobile_desc_script_id AS mobile_description,
 mi.mobile_info_script_id AS mobile_more_info,
 mi.mobile_terms_condition_link AS terms_condition_link
 FROM sa.X_PROGRAM_ENROLLED PE,
 sa.X_PROGRAM_PARAMETERS PP,
 sa.table_part_num pn,
 sa.table_handset_msrp_tiers tr,
 sa.x_mtm_program_msrp protr,
 sa.table_x_mobile_info mi
 WHERE PE.X_ESN = get_part_inst_rec.part_serial_no
 AND PE.X_ENROLLMENT_STATUS NOT IN
 ('DEENROLLED',
 'ENROLLMENTFAILED',
 'READYTOREENROLL')
 AND pp.objid NOT IN  (SELECT program_parameters_objid
                       FROM   vas_programs_mv
                       WHERE  vas_product_type      = 'HANDSET PROTECTION'
                       UNION
                       SELECT auto_pay_program_objid
                       FROM   vas_programs_mv
                       WHERE  auto_pay_program_objid IS NOT NULL
                       AND    vas_product_type      = 'HANDSET PROTECTION'
                      ) -- CR49058 to restrict new warranty programs
 AND PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
 AND PP.X_PROG_CLASS = 'WARRANTY'
 AND pn.objid = pp.prog_param2prtnum_monfee
 AND tr.objid = protr.pgm_msrp2handset_msrp_tier
 AND protr.pgm_msrp2pgm_parameter = pp.objid
 AND mi.pgm_enroll2mobile_info(+) = pe.pgm_enroll2pgm_parameter
 ORDER BY x_insert_date DESC;
 EXCEPTION
 WHEN OTHERS
 THEN
 op_error_code := SQLCODE;
 op_error_text := 'getCurrentWarrantyProgram ' || SQLERRM;
 END;
 --end if;
 END getCurrentWarrantyProgram;

/*
-- This function will return the following values: mobile_name_script_id, mobile_desc_script_id,
-- mobile_info_script_id, mobile_terms_condition_link based on the program id returned by
-- SA.VALUE_ADDEDPRG.getCurrentWarrantyProgram procedure
*/
 FUNCTION geteligiblewtyprogramsv2 (ip_esn IN VARCHAR2)
 RETURN eligiblewtyprogramsv2_tab
 pipelined
 IS
 op_error_code VARCHAR2 (200);
 op_error_text VARCHAR2 (200);
 CURSOR mobile_info_cur ( ip_objid IN sa.x_program_parameters.objid%TYPE) IS
 SELECT mi.* FROM table_x_mobile_info mi
 WHERE pgm_enroll2mobile_info=ip_objid ;
 mobile_info_rec mobile_info_cur%rowtype;
 BEGIN
 FOR pgmrst IN (SELECT * FROM TABLE(geteligiblewtyprograms(ip_esn)))
 loop
 eligiblewtyprogramsv2_rslt.status := pgmrst.status;
 eligiblewtyprogramsv2_rslt.prog_id := pgmrst.prog_id;
 eligiblewtyprogramsv2_rslt.x_program_name := pgmrst.x_program_name;
 eligiblewtyprogramsv2_rslt.x_program_desc := pgmrst.x_program_desc;
 eligiblewtyprogramsv2_rslt.x_retail_price := pgmrst.x_retail_price;
 eligiblewtyprogramsv2_rslt.part_number := pgmrst.part_number;
 OPEN mobile_info_cur(pgmrst.prog_id);
 fetch mobile_info_cur INTO mobile_info_rec;
 IF mobile_info_cur%found THEN
 eligiblewtyprogramsv2_rslt.mobile_name := mobile_info_rec.mobile_name_script_id;
 eligiblewtyprogramsv2_rslt.mobile_description := mobile_info_rec.mobile_desc_script_id;
 eligiblewtyprogramsv2_rslt.mobile_more_info := mobile_info_rec.mobile_info_script_id;
 eligiblewtyprogramsv2_rslt.terms_condition_link := mobile_info_rec.mobile_terms_condition_link;
 ELSE
 eligiblewtyprogramsv2_rslt.mobile_name := NULL;
 eligiblewtyprogramsv2_rslt.mobile_description := NULL;
 eligiblewtyprogramsv2_rslt.mobile_more_info := NULL;
 eligiblewtyprogramsv2_rslt.terms_condition_link := NULL;
 END IF;
 CLOSE mobile_info_cur;
 pipe ROW (eligiblewtyprogramsv2_rslt);
 END loop;
 RETURN;
 END geteligiblewtyprogramsv2;

 FUNCTION getEligibleWtyPrograms (ip_esn IN VARCHAR2)
 RETURN EligibleWtyPrograms_tab
 PIPELINED
 /* CR29489 HPP BYOP 22-Aug-2014 vkashmire
 Function: getEligibleWtyPrograms - modified to show HPP BYOP programs which are eligible for BYOP handsets
 input parameter : ip_esn = pseudo esn of byop handset
 */
 IS
 OP_ERROR_CODE VARCHAR2 (200);
 OP_ERROR_TEXT VARCHAR2 (200);
 OP_REFCURSOR SYS_REFCURSOR;
 CURRENTWTYPROGRAMS_rec sa.VALUE_ADDEDPRG.CURRENTWTYPROGRAMS_record;
 sn_fulfillment NUMBER;
 lv_byop_esn sa.table_part_inst.part_serial_no%TYPE; -- CR29489
 lv_input_esn_byop VARCHAR2 (5) := 'FALSE'; -- CR29489
 lv_count INTEGER; -- CR29489
 v_port_case number := 0;------------CR31715
 V_ZIP_CODE varchar2(100);------------CR31715
 BEGIN
 dbms_output.put_line('inside');
 op_error_code := '0';
 op_error_text := 'Success';

 getCurrentWarrantyProgram (IP_ESN,
 OP_REFCURSOR,
 OP_ERROR_CODE,
 OP_ERROR_TEXT);
dbms_output.put_line('OP_ERROR_CODE'||OP_ERROR_CODE);
dbms_output.put_line('OP_ERROR_TEXT'||OP_ERROR_TEXT);

 FETCH OP_REFCURSOR INTO CURRENTWTYPROGRAMS_rec;

 IF OP_REFCURSOR%FOUND
 THEN
 op_error_code := '-1';
 op_error_text := 'ESN already enrolled';
 END IF;

 CLOSE OP_REFCURSOR;

 lv_input_esn_byop := sa.byop_service_pkg.verify_byop_esn (ip_esn); -- CR29489

 dbms_output.put_line('lv_input_esn_byop'||lv_input_esn_byop);

 IF lv_input_esn_byop = 'TRUE' AND op_error_code = '0'
 THEN
 --get the real-esn for input pseudo-esn and check whether claims Or cancellations is in process
 lv_byop_esn :=
 sa.device_util_pkg.f_get_real_esn_for_pseudo_esn (ip_esn);
 lv_count := 0;

 SELECT COUNT (1)
 INTO lv_count
 FROM sa.sn_program_claims
 WHERE (x_type = 'B')
 AND (x_esn = lv_byop_esn) /* service net will send the BYOP-ESN */
                AND (X_STATUS_DATE BETWEEN ADD_MONTHS (SYSDATE, -12)
                                       AND SYSDATE);

         IF NVL (lv_count, 0) > 0
         THEN
            op_error_code := '-2';
            op_error_text :=
                  'Not Eligible now since A BYOP Claim is in process for the input BYOP-ESN: '
               || lv_byop_esn;
         ELSE
            lv_count := 0;

            SELECT COUNT (1)
              INTO lv_count
              FROM sa.x_contract_responses xcr
             WHERE     xcr.x_sourcesystem = 'ServiceNet'
                   AND (xcr.x_action_code = '010') /* 010 = cancellation request */
                   AND (xcr.x_esn = lv_byop_esn) /* service net will send the BYOP-ESN */
                   AND (NVL (xcr.x_refund, 0) <> 0) /*  refund amount <> 0 means customer has got some refund amount which indicates customer has cancelled the enrollment and got the refund */
                   AND (xcr.x_status_date BETWEEN ADD_MONTHS (SYSDATE, -12)
                                              AND SYSDATE);

            IF NVL (lv_count, 0) > 0
            THEN
               OP_ERROR_CODE := '-3';
               op_error_text :=
                     'Not Eligible now since A Cancellation request is already in process for the input ESN: '
                  || ip_esn;
            END IF;
         END IF;
      END IF;


dbms_output.put_line('OP_ERROR_CODE 1='||OP_ERROR_CODE);
dbms_output.put_line('op_error_text 1='||op_error_text);
      /* CR29489 HPP BYOP changes ends ; validations for enrollment */
------------CR31715------------CR31715
  OPEN get_zipCode_cur(IP_ESN);
  FETCH get_zipCode_cur
  INTO get_zipCode_REC;
  IF get_zipCode_cur%FOUND THEN
  dbms_output.put_line('get_zipCode_cur FOUND');
  v_port_case := 1;
    V_ZIP_CODE := get_zipCode_REC.X_VALUE;
  ELSE
  v_port_case := 0;
    V_ZIP_CODE := GET_SITE_PART_REC.X_ZIPCODE;
  END IF;
  CLOSE get_zipCode_cur;

dbms_output.put_line('V_ZIP_CODE 1='||V_ZIP_CODE);
------------CR31715
      IF op_error_code = '0'
      THEN
         sn_fulfillment :=
            NVL (TO_NUMBER (get_param_value ('SN FULFILLMENT')), 0);

         FOR PROG
            IN (SELECT /*+ ORDERED */
                      PN.PART_NUMBER,
                       PP.OBJID,
                       PP.X_HANDSET_VALUE,
                       PP.X_PROGRAM_NAME,
                       PP.X_PROGRAM_DESC,
                       sa.sp_metadata.getprice (pn.part_number, 'BILLING')
                          x_retail_price
                  FROM sa.TABLE_HANDSET_MSRP_TIERS msrp,
                       sa.X_MTM_PROGRAM_MSRP xpmsrp,
                       sa.X_PROGRAM_PARAMETERS PP,
                       sa.table_part_num pn
                 WHERE     (get_part_inst_rec.x_retail_price) BETWEEN msrp.tier_price_low
                                                                  AND msrp.tier_price_high --CR23111 remove sn_fulfillment
                       AND pp.objid NOT IN  (SELECT program_parameters_objid
                                             FROM   vas_programs_mv
                                             WHERE  vas_product_type      = 'HANDSET PROTECTION'
                                             UNION
                                             SELECT auto_pay_program_objid
                                             FROM   vas_programs_mv
                                             WHERE  auto_pay_program_objid IS NOT NULL
                                             AND    vas_product_type      = 'HANDSET PROTECTION'
                                            ) -- CR49058 to restrict new warranty programs
                       AND xpmsrp.pgm_msrp2handset_msrp_tier = msrp.objid
                       AND pp.objid = xpmsrp.pgm_msrp2pgm_parameter
                       AND pp.x_prog_class = 'WARRANTY'
                       AND SYSDATE BETWEEN PP.X_START_DATE AND PP.X_END_DATE
                       /*  CR29489 Changes starts --  For BYOP show the enrolment price and for non-BYOP show monthly price */
                       --and   pn.objid = pp.prog_param2prtnum_monfee
                       AND pn.objid =
                              DECODE (PP.X_IS_RECURRING,
                                      0,           ----v.x_param_value,'BYOP',
                                        pp.prog_param2prtnum_enrlfee,
                                      pp.prog_param2prtnum_monfee)
                       /*  CR29489 Changes ends */
                       AND pp.prog_param2bus_org =
                              get_part_inst_rec.part_num2bus_org    -- CR24444
                       /* CR29489 hpp byop changes starts ; added below conditions to consider device type */
                       AND (DECODE (lv_input_esn_byop,
                                    'TRUE', 'BYOP',
                                    'PHONE') =
                               NVL (msrp.product_type, 'PHONE'))) /*  for smartphone, feature_phone ,wireless phone ,mobile broadband - the msrp.product_type should be PHONE or null */
         /* CR29489 hpp byop changes ends */
         LOOP
            /* CR 29489 HPP-BYOP changes starts */

     dbms_output.put_line('v_port_case'||v_port_case);

 dbms_output.put_line('lv_input_esn_byop'||lv_input_esn_byop);
 ------------CR31715
       if v_port_case = 0 then

            IF lv_input_esn_byop = 'TRUE'
            THEN

dbms_output.put_line('inside');

               /*  For BYOP , check only 2 conditions
                   1)handset should be in active status
                   2)activation zipcode should not be from FL or CA
               */
               eligiblewtyprograms_rslt.status :=
                  CASE
                     WHEN NOT (IS_VALID_STATUS (
                                  PROG.OBJID,
                                  GET_PART_INST_REC.X_PART_INST_STATUS))
                     THEN
                        'NON_ELIGIBLE'
                     WHEN IS_RESTRICTED_STATE (PROG.OBJID,V_ZIP_CODE)------cr31715
                                             --  GET_SITE_PART_REC.X_ZIPCODE)
                     THEN
                        'NON_ELIGIBLE'
                     ELSE
                        'ELIGIBLE'
                  END;
            ELSE
               /* CR29489 HPP-BYOP changes ends */
               ELIGIBLEWTYPROGRAMS_RSLT.STATUS :=
                  CASE
                     WHEN NOT (IS_VALID_STATUS (
                                  PROG.OBJID,
                                  GET_PART_INST_REC.X_PART_INST_STATUS))
                     THEN
                        'NON_ELIGIBLE'
                     WHEN     PROG.X_HANDSET_VALUE = 'RESTRICTED'
                          AND IS_RESTRICTED_HANDSET (
                                 PROG.OBJID,
                                 GET_PART_INST_REC.PART_NUM2PART_CLASS)
                     THEN
                        'NON_ELIGIBLE'
                     WHEN IS_RESTRICTED_STATE (PROG.OBJID,V_ZIP_CODE)--cr31715
                                             --  GET_SITE_PART_REC.X_ZIPCODE)
                     THEN
                        'NON_ELIGIBLE'
                   WHEN GET_SITE_PART_REC.PHONE_AGE >=
                             NVL (
                                TO_NUMBER (
                                   get_param_value (
                                      'PHONE AGE ' || prog.x_program_name)),
                                0)
                     THEN
                        'NON_ELIGIBLE'
                     ELSE
                        'ELIGIBLE'
                  END;
            END IF;
            end if;
------------CR31715
             if v_port_case = 1 then
               IF lv_input_esn_byop = 'TRUE'
            THEN

dbms_output.put_line('inside');

                eligiblewtyprograms_rslt.status :=
                  CASE
                     WHEN IS_RESTRICTED_STATE (PROG.OBJID,V_ZIP_CODE)------cr31715
                      THEN
                        'NON_ELIGIBLE'
                     ELSE
                        'ELIGIBLE'
                  END;

else
               ELIGIBLEWTYPROGRAMS_RSLT.STATUS :=
                case
                WHEN     PROG.X_HANDSET_VALUE = 'RESTRICTED'
                          AND IS_RESTRICTED_HANDSET (
                                 PROG.OBJID,
                                 GET_PART_INST_REC.PART_NUM2PART_CLASS)
                     THEN
                        'NON_ELIGIBLE'
                     WHEN IS_RESTRICTED_STATE (PROG.OBJID,V_ZIP_CODE)--cr31715
                                             --  GET_SITE_PART_REC.X_ZIPCODE)
                     THEN
                        'NON_ELIGIBLE'
                        ELSE
                        'ELIGIBLE'
                  END;
            END IF;
            end if;
          --cr31715



dbms_output.put_line(' ELIGIBLEWTYPROGRAMS_RSLT.STATUS'|| ELIGIBLEWTYPROGRAMS_RSLT.STATUS);




            EligibleWtyPrograms_rslt.prog_id := prog.objid;
            EligibleWtyPrograms_rslt.x_program_name := prog.x_program_name;
            EligibleWtyPrograms_rslt.x_program_desc := prog.x_program_desc;
            EligibleWtyPrograms_rslt.x_retail_price := prog.x_retail_price;
            EligibleWtyPrograms_rslt.part_number := prog.PART_NUMBER;

            IF ELIGIBLEWTYPROGRAMS_RSLT.STATUS = 'ELIGIBLE'
            THEN
               PIPE ROW (EligibleWtyPrograms_rslt);
            END IF;
         END LOOP;
      END IF;

      RETURN;
   END getEligibleWtyPrograms;


   /*  CR29489 changes starts ; 28-Aug-2014 */
   FUNCTION getEligibleWtyPrgForActivation (ip_esn IN VARCHAR2)
      RETURN ELIGIBLEWTYPROGRAMS_TAB
      PIPELINED
   IS
      /*
      CR29489     28-Aug-2014     vkashmire
      function getEligibleWtyPrgForActivation created to support TAS functionality
      ip_esn = esn of handset (pseudo esn in case of hpp byop)
      */
      OP_ERROR_CODE       VARCHAR2 (200);
      OP_ERROR_TEXT       VARCHAR2 (200);

      lv_input_esn_byop   VARCHAR2 (5) := 'FALSE';
      lv_count            INTEGER := 0;
   BEGIN
      op_error_code := '0';
      op_error_text := 'Success';

      /*  PLEASE DO NOT USE getCurrentWarrantyProgram here in this function */
      OPEN get_part_inst (ip_esn);

      FETCH get_part_inst INTO get_part_inst_rec;

      CLOSE get_part_inst;

      IF get_part_inst_rec.part_serial_no IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO lv_count
           FROM sa.x_program_enrolled pe, sa.x_program_parameters pp
          WHERE     pe.x_esn = ip_esn
                AND pe.x_enrollment_status NOT IN
                       ('DEENROLLED', 'ENROLLMENTFAILED', 'READYTOREENROLL')
                AND pp.objid = pe.pgm_enroll2pgm_parameter
                AND pp.x_prog_class = 'WARRANTY';
      END IF;


      IF lv_count > 0
      THEN
         op_error_code := '-1';
         op_error_text := 'ESN already enrolled';
      ELSE
         lv_input_esn_byop := sa.byop_service_pkg.verify_byop_esn (ip_esn);
      END IF;

      IF op_error_code = '0'
      THEN
         FOR PROG
            IN (SELECT /*+ ORDERED */
                      PN.PART_NUMBER,
                       PP.OBJID,
                       PP.X_HANDSET_VALUE,
                       PP.X_PROGRAM_NAME,
                       PP.X_PROGRAM_DESC,
                       sa.sp_metadata.getprice (pn.part_number, 'BILLING')
                          x_retail_price
                  FROM sa.TABLE_HANDSET_MSRP_TIERS msrp,
                       sa.X_MTM_PROGRAM_MSRP xpmsrp,
                       sa.X_PROGRAM_PARAMETERS PP,
                       sa.table_part_num pn
                 WHERE     (get_part_inst_rec.x_retail_price) BETWEEN msrp.tier_price_low
                                                                  AND msrp.tier_price_high --CR23111 remove sn_fulfillment
                       AND pp.objid NOT IN  (SELECT program_parameters_objid
                                             FROM   vas_programs_mv
                                             WHERE  vas_product_type      = 'HANDSET PROTECTION'
                                             UNION
                                             SELECT auto_pay_program_objid
                                             FROM   vas_programs_mv
                                             WHERE  auto_pay_program_objid IS NOT NULL
                                             AND    vas_product_type      = 'HANDSET PROTECTION'
                                            ) -- CR49058 to restrict new warranty programs
                       AND xpmsrp.pgm_msrp2handset_msrp_tier = msrp.objid
                       AND pp.objid = xpmsrp.pgm_msrp2pgm_parameter
                       AND pp.x_prog_class = 'WARRANTY'
                       AND SYSDATE BETWEEN PP.X_START_DATE AND PP.X_END_DATE
                       AND pn.objid =
                              DECODE (PP.X_IS_RECURRING,
                                      0,           ----v.x_param_value,'BYOP',
                                        pp.prog_param2prtnum_enrlfee,
                                      pp.prog_param2prtnum_monfee)
                       AND pp.prog_param2bus_org =
                              get_part_inst_rec.part_num2bus_org
                       AND (DECODE (lv_input_esn_byop,
                                    'TRUE', 'BYOP',
                                    'PHONE') =
                               NVL (msrp.product_type, 'PHONE'))) /*  for smartphone, feature_phone ,wireless phone ,mobile broadband - the msrp.product_type should be PHONE  */
         LOOP
            ELIGIBLEWTYPROGRAMS_RSLT.STATUS :=
               CASE
                  WHEN     PROG.X_HANDSET_VALUE = 'RESTRICTED'
                       AND IS_RESTRICTED_HANDSET (
                              PROG.OBJID,
                              GET_PART_INST_REC.PART_NUM2PART_CLASS)
                  THEN
                     'NON_ELIGIBLE'
                  ELSE
                     'ELIGIBLE'
               END;

            IF eligiblewtyprograms_rslt.status = 'ELIGIBLE'
            THEN
               eligiblewtyprograms_rslt.prog_id := prog.objid;
               eligiblewtyprograms_rslt.x_program_name := prog.x_program_name;
               eligiblewtyprograms_rslt.x_program_desc := prog.x_program_desc;
               eligiblewtyprograms_rslt.x_retail_price := prog.x_retail_price;
               eligiblewtyprograms_rslt.part_number := prog.part_number;
               PIPE ROW (eligiblewtyprograms_rslt);
            END IF;
         END LOOP;
      END IF;

      RETURN;
   END getEligibleWtyPrgForActivation;

   /* CR29489 HPP BYOP changes ends */


   FUNCTION getSalesAccountUpdates (ip_date IN DATE)
      RETURN account_file_TAB
      PIPELINED
   IS
      /* CR29489 HPP BYOP 21-Aug-2014 Vkashmire
      For BYOP customers, show data as follows include the real ESN in Sales file and
        instead of ESN = show real ESN provided by customer
        instead of manufacturer = show 03836   - its tracfone id
        instead of model = show BYOP
        instead of email = show email provided by customer

        CR29079
        Send all enrollments with code 035 which were SUSPENDED and now in ENROLLED status
      */
      CURSOR getPendingSales (
         ip_date IN DATE)
      IS
         SELECT /*+ ORDERED */
               TS.SITE_ID CONSUMER_ID_NUMBER,
                C.TITLE CONSUMER_TITLE,
                C.FIRST_NAME FIRST_NAME,
                c.last_name last_name,
                (select X.X_CITY from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_CITY, -- CR29718 --ECR31564
                (select X.X_STATE from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_STATE, -- CR29718 --ECR31564
                TSP.X_ZIPCODE SERVICE_ZIP,    -- CR29718
                TSP.X_MIN PHONE,
                DECODE (xvs.vas_name, 'HPP BYOP', xvs.x_email, C.E_MAIL)
                   AS E_MAIL_ADDRESS,    -- CR29489
                C.X_MIDDLE_INITIAL MIDDLE_INITIAL,
                pe.x_esn
                   AS CONTRACT_NUMBER,    -- CR29489
                pe.X_ENROLLED_DATE CONTRACT_PURCHASE_DATE, -- CR26009: changed date from X_INSERT_DATE
                --CR23882 initial activation date or the first activation after the phone was refurbished
                (SELECT trunc(MIN (install_date))
                         FROM table_site_part m
                        WHERE     m.x_service_id = TSP.x_service_id
                          and 1=(case when 1 = (SELECT COUNT (*) FROM table_site_part sp WHERE sp.x_service_id = m.x_service_id) then 1
                           else NVL (x_refurb_flag, 1) end)) EQUIPMENT_PURCHASE_DATE, --CR33533
                DECODE (xvs.vas_name, 'HPP BYOP', 'BYOP', pc.name)
                   AS MODEL_NUMBER,   -- CR29489
                PI.PART_SERIAL_NO
                   AS SERIAL_NUMBER,   -- CR29489
                DECODE (xvs.vas_name, 'HPP BYOP', '03836', 'BYOP', '03836', decode(LTRIM(RTRIM(PN.X_MANUFACTURER)),'ALCATEL','03531',
                                  'HUAWEI' ,'03736',
                                  'KYOCERA' , '00355',
                                  'LG INC', 'LG' ,
                                  'MOTOROLA INC' , 'MOT',
                                  'NOKIA INC' ,'NKA',
                                  'SAMSUNG INC' , 'SMG',
                                  'TRACFONE' ,'03836',
                                  'UNIMAX' ,'03837',
                                  'ZTE' , '03838',
                                  'APPLE' , 'APP',
                                  'RIM' , 'RIM', decode(LTRIM(RTRIM(PN.X_MANUFACTURER)),'BYOP', '03836',PN.X_MANUFACTURER)))  MANUF_CODE, -- CR33533 CR29489 CR31712
                (SELECT PART_NUMBER
                   FROM sa.TABLE_PART_NUM
                  WHERE OBJID = PP.PROG_PARAM2PRTNUM_ENRLFEE)
                   SKU_NUMBER,       -- CR29638
                DECODE (PP.X_IS_RECURRING,
                        0, PE.X_ENROLL_AMOUNT,
                        PE.X_AMOUNT)
                   CONTRACT_RETAIL,   -- CR29489
                sa.SP_METADATA.GETPRICE (pn.part_number, 'TIER SERVICE NET')
                   equipment_retail,     --CR23111
                '001' UPDATE_ACTION_CODE,
                '' CANCEL_REQUEST_DATE
           FROM sa.X_PROGRAM_ENROLLED PE,
                sa.X_PROGRAM_PARAMETERS PP,
                sa.TABLE_PART_INST PI,
                sa.TABLE_MOD_LEVEL ML,
                sa.TABLE_PART_NUM PN,
                sa.TABLE_PART_CLASS PC,
                sa.TABLE_CONTACT C,
                sa.TABLE_CONTACT_ROLE CR,
                sa.TABLE_SITE TS,
                sa.TABLE_SITE_PART TSP,
                sa.x_vas_subscriptions xvs    -- CR29489--ECR31564
                -- --ECR31564 SA.TABLE_X_SALES_TAX XST -- CR29718
          WHERE     1 = 1
                AND pe.X_ENROLLED_DATE >= ip_date --CR33533 changed from X_INSERT_DATE
                AND PE.X_ENROLLMENT_STATUS || '' = 'ENROLLMENTPENDING'
                AND PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
                AND PP.X_PROG_CLASS = 'WARRANTY'
                AND PI.OBJID = PE.PGM_ENROLL2PART_INST
                AND ML.OBJID = PI.N_PART_INST2PART_MOD
                AND PN.OBJID = ML.PART_INFO2PART_NUM
                AND PC.OBJID = PN.PART_NUM2PART_CLASS
                AND C.OBJID = PE.PGM_ENROLL2CONTACT
                AND CR.CONTACT_ROLE2CONTACT = C.OBJID
                AND TS.OBJID = CR.CONTACT_ROLE2SITE
                AND CR.PRIMARY_SITE = 1       --CR23065
                AND TSP.OBJID = PI.X_PART_INST2SITE_PART
                AND pe.x_esn = xvs.vas_esn(+)                       -- CR29489
                AND 'HPP BYOP' = xvs.vas_name(+)        -- CR29489
        --        AND TSP.X_ZIPCODE = XST.X_ZIPCODE -- CR29718 --ECR31564
                AND EXISTS -- Start of CR30365
		             (SELECT 1 FROM sa.x_program_purch_hdr ph, sa.x_program_purch_dtl pd
                      WHERE 1=1
                      AND ph.objid=pd.pgm_purch_dtl2prog_hdr
                      AND pd.pgm_purch_dtl2pgm_enrolled=PE.objid
                      AND ph.x_process_date >=ip_date --CR33533 changed x_rqst_date to x_process_date
                      AND ph.x_ics_rcode IN ('1','100')
                      AND ph.x_payment_type='ENROLLMENT'
					)-- end of  CR30365
                -- CR55614 Begin : Restrict new warranty programs
                AND pp.objid NOT IN  ( SELECT program_parameters_objid
                                       FROM   vas_programs_mv
                                       WHERE  vas_product_type      = 'HANDSET PROTECTION'
                                       UNION
                                       SELECT auto_pay_program_objid
                                       FROM   vas_programs_mv
                                       WHERE  auto_pay_program_objid IS NOT NULL
                                       AND    vas_product_type      = 'HANDSET PROTECTION'
                                     )
                 -- CR55614 End
                 ;


      CURSOR getAccountUpdates (
         ip_date IN DATE)
      IS
         -- Extract Contact Updates
         -- CR43802 --tune the below query

         select * from (
            with program_enrolled as
                   (select pe.*,c.objid contact_objid,  c.title consumer_title, c.first_name first_name,  c.last_name last_name, c.e_mail,  c.x_middle_initial as middle_initial, pp.prog_param2prtnum_monfee,pp.x_is_recurring, pi.n_part_inst2part_mod, pi.x_part_inst2site_part, pi.part_serial_no
                      from sa.table_contact c,
                           sa.x_program_enrolled pe,
                           sa.x_program_parameters pp,
                           table_part_inst pi
                     where 1 =1
                       and c.update_stamp >= ip_date--sysdate -1
                       and c.objid = pe.pgm_enroll2contact
                       and pe.x_enrollment_status = 'ENROLLED'
                       --and pi.x_part_inst2contact = c.objid
                       and pi.part_serial_no = pe.x_esn
                       and pe.pgm_enroll2pgm_parameter = pp.objid
                       and pi.objid = pe.pgm_enroll2part_inst
                       and pp.x_prog_class = 'WARRANTY'
                       -- CR55614 Begin : Restrict new warranty programs
                       AND pp.objid NOT IN  ( SELECT program_parameters_objid
                                              FROM   vas_programs_mv
                                              WHERE  vas_product_type      = 'HANDSET PROTECTION'
                                              UNION
                                              SELECT auto_pay_program_objid
                                              FROM   vas_programs_mv
                                              WHERE  auto_pay_program_objid IS NOT NULL
                                              AND    vas_product_type      = 'HANDSET PROTECTION'
                                            )
                        -- CR55614 End
                         )
            select ts.site_id consumer_id_number,
                   pe.consumer_title  consumer_title,
                   pe.first_name first_name,
                   pe.last_name last_name,
                   (select x.x_city from sa.table_x_zip_code x where tsp.x_zipcode = x.x_zip and rownum <2) service_city,
                   (select x.x_state from sa.table_x_zip_code x where tsp.x_zipcode = x.x_zip and rownum <2) service_state,
                   tsp.x_zipcode service_zip,
                   tsp.x_min phone,
                   decode (xvs.vas_name, 'HPP BYOP', xvs.x_email, pe.e_mail)  as e_mail_address,
                   pe.middle_initial middle_initial,
                   pe.x_esn as contract_number,
                   pe.x_enrolled_date contract_purchase_date,(select trunc(min (install_date))from table_site_part m  where m.x_service_id = tsp.x_service_id and 1=(case when 1 = (select count (*) from table_site_part sp where sp.x_service_id = m.x_service_id) then 1 else nvl (x_refurb_flag, 1) end)) equipment_purchase_date, --CR33533
                   decode (xvs.vas_name, 'HPP BYOP', 'BYOP', pc.name) as model_number,   -- CR29489
                   pe.part_serial_no as serial_number,  -- CR29489
                   decode (xvs.vas_name, 'HPP BYOP', '03836', 'BYOP', '03836', decode(ltrim(rtrim(pn.x_manufacturer)),'ALCATEL','03531', 'HUAWEI' ,'03736','KYOCERA' , '00355', 'LG INC', 'LG' ,'MOTOROLA INC' , 'MOT','NOKIA INC' ,'NKA','SAMSUNG INC' , 'SMG', 'TRACFONE' ,'03836','UNIMAX' ,'03837', 'ZTE' , '03838','APPLE' , 'APP', 'RIM' , 'RIM', decode(ltrim(rtrim(pn.x_manufacturer)),'BYOP', '03836',pn.x_manufacturer)))  manuf_code, -- CR33533 CR29489 CR31712
                   (select part_number from sa.table_part_num where objid = pe.prog_param2prtnum_monfee) sku_number,
                   decode (pe.x_is_recurring, 0, pe.x_enroll_amount, pe.x_amount) contract_retail,
                   sa.sp_metadata.getprice (pn.part_number, 'TIER SERVICE NET') equipment_retail,
                   '100' update_action_code,
                   '' cancel_request_date
              from  program_enrolled pe,
                    sa.table_mod_level ml,
                    sa.table_part_num pn,
                    sa.table_part_class pc,
                    sa.table_contact_role cr,
                    sa.table_site ts,
                    sa.table_site_part tsp,
                    sa.x_vas_subscriptions xvs
              where 1 = 1
                and ml.objid = pe.n_part_inst2part_mod
                and pn.objid = ml.part_info2part_num
                and pc.objid = pn.part_num2part_class
                and cr.contact_role2contact = pe.contact_objid
                and cr.primary_site = 1
                and ts.objid = cr.contact_role2site
                and tsp.objid = pe.x_part_inst2site_part
                and pe.x_esn = xvs.vas_esn(+)
                and 'HPP BYOP' = xvs.vas_name(+))
         UNION
         -- Extract program ENROLLED Updates
         -- grab rows where  PE.X_ENROLLMENT_STATUS change from DEENROLLED, SUSPENDED  to ENROLLED
         SELECT /*+ ORDERED */
               TS.SITE_ID CONSUMER_ID_NUMBER,
                C.TITLE CONSUMER_TITLE,
                C.FIRST_NAME FIRST_NAME,
                c.last_name last_name,
                (select X.X_CITY from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_CITY, -- CR29718 --ECR31564
                (select X.X_STATE from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_STATE, -- CR29718 --ECR31564TSP.X_ZIPCODE SERVICE_ZIP,                          -- CR29718
                TSP.X_ZIPCODE SERVICE_ZIP, -- CR29718
				TSP.X_MIN PHONE,
                DECODE (xvs.vas_name, 'HPP BYOP', xvs.x_email, C.E_MAIL)
                   AS E_MAIL_ADDRESS,  -- CR29489
                C.X_MIDDLE_INITIAL MIDDLE_INITIAL,
                pe.x_esn
                   AS CONTRACT_NUMBER,      -- CR29489
                pe.X_ENROLLED_DATE CONTRACT_PURCHASE_DATE, -- CR26009: changed date from X_INSERT_DATE
                (SELECT trunc(MIN (install_date))
                         FROM table_site_part m
                        WHERE     m.x_service_id = TSP.x_service_id
                          and 1=(case when 1 = (SELECT COUNT (*) FROM table_site_part sp WHERE sp.x_service_id = m.x_service_id) then 1
                           else NVL (x_refurb_flag, 1) end)) EQUIPMENT_PURCHASE_DATE, --CR33533
                DECODE (xvs.vas_name, 'HPP BYOP', 'BYOP', pc.name)
                   AS MODEL_NUMBER,   -- CR29489
                PI.PART_SERIAL_NO
                   AS SERIAL_NUMBER,  -- CR29489
                DECODE (xvs.vas_name, 'HPP BYOP', '03836', 'BYOP', '03836', decode(LTRIM(RTRIM(PN.X_MANUFACTURER)),'ALCATEL','03531',
                                  'HUAWEI' ,'03736',
                                  'KYOCERA' , '00355',
                                  'LG INC', 'LG' ,
                                  'MOTOROLA INC' , 'MOT',
                                  'NOKIA INC' ,'NKA',
                                  'SAMSUNG INC' , 'SMG',
                                  'TRACFONE' ,'03836',
                                  'UNIMAX' ,'03837',
                                  'ZTE' , '03838',
                                  'APPLE' , 'APP',
                                  'RIM' , 'RIM', decode(LTRIM(RTRIM(PN.X_MANUFACTURER)),'BYOP', '03836',PN.X_MANUFACTURER)))  MANUF_CODE, -- CR33533 CR29489 CR31712
                (SELECT PART_NUMBER
                   FROM sa.TABLE_PART_NUM
                  WHERE OBJID = pp.prog_param2prtnum_monfee)
                   SKU_NUMBER,
                DECODE (PP.X_IS_RECURRING,
                        0, PE.X_ENROLL_AMOUNT,
                        PE.X_AMOUNT)
                   CONTRACT_RETAIL, -- CR29489
                sa.SP_METADATA.GETPRICE (pn.part_number, 'TIER SERVICE NET')
                   equipment_retail, --CR23111
                '100' UPDATE_ACTION_CODE,
                '' CANCEL_REQUEST_DATE
           FROM sa.X_PROGRAM_ENROLLED PE,
                sa.X_PROGRAM_PARAMETERS PP,
                sa.TABLE_PART_INST PI,
                sa.TABLE_MOD_LEVEL ML,
                sa.TABLE_PART_NUM PN,
                sa.TABLE_PART_CLASS PC,
                sa.TABLE_CONTACT C,
                sa.TABLE_CONTACT_ROLE CR,
                sa.TABLE_SITE TS,
                sa.TABLE_SITE_PART TSP,
                sa.x_vas_subscriptions xvs-- CR29489 --ECR31564
        -- ECR31564  SA.TABLE_X_SALES_TAX XST    -- CR29718
          WHERE     1 = 1
                AND pe.x_update_stamp >= ip_date
                AND PE.X_UPDATE_STAMP = PE.X_ENROLLED_DATE --ESN 'ENROLLED' again
                AND pe.X_CHARGE_DATE = PE.X_ENROLLED_DATE --ESN 'ENROLLED' again
                AND PE.X_ENROLLED_DATE > PE.X_INSERT_DATE + 2 --Exclude First Time Enrollment
                AND PE.X_ENROLLMENT_STATUS || '' = 'ENROLLED'
                AND PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
                AND PP.X_PROG_CLASS = 'WARRANTY'
                AND PI.OBJID = PE.PGM_ENROLL2PART_INST
                AND ML.OBJID = PI.N_PART_INST2PART_MOD
                AND PN.OBJID = ML.PART_INFO2PART_NUM
                AND PC.OBJID = PN.PART_NUM2PART_CLASS
                AND CR.PRIMARY_SITE = 1  --CR23065
                AND C.OBJID = PE.PGM_ENROLL2CONTACT
                AND CR.CONTACT_ROLE2CONTACT = C.OBJID
                AND TS.OBJID = CR.CONTACT_ROLE2SITE
                AND TSP.OBJID = PI.X_PART_INST2SITE_PART
                AND pe.x_esn = xvs.vas_esn(+)    -- CR29489
                AND 'HPP BYOP' = xvs.vas_name(+)    -- CR29489
         -- ECR31564  AND TSP.X_ZIPCODE = XST.X_ZIPCODE  -- CR29718
                -- CR55614 Begin : Restrict new warranty programs
                AND pp.objid NOT IN  ( SELECT program_parameters_objid
                                       FROM   vas_programs_mv
                                       WHERE  vas_product_type      = 'HANDSET PROTECTION'
                                       UNION
                                       SELECT auto_pay_program_objid
                                       FROM   vas_programs_mv
                                       WHERE  auto_pay_program_objid IS NOT NULL
                                       AND    vas_product_type      = 'HANDSET PROTECTION'
                                     )
                 -- CR55614 End
         UNION
         --      CURSOR getMIN_Updates (ip_date in date) is
         -- grab rows where  MIN changed
         SELECT /*+ ORDERED */
               TS.SITE_ID CONSUMER_ID_NUMBER,
                C.TITLE CONSUMER_TITLE,
                C.FIRST_NAME FIRST_NAME,
                c.last_name last_name,
                (select X.X_CITY from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_CITY, -- CR29718 --ECR31564
                (select X.X_STATE from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_STATE, -- CR29718 --ECR31564TSP.X_ZIPCODE SERVICE_ZIP,                          -- CR29718
                TSP.X_ZIPCODE SERVICE_ZIP, -- CR29718
				        TSP.X_MIN PHONE,
                DECODE (xvs.vas_name, 'HPP BYOP', xvs.x_email, C.E_MAIL)
                   AS E_MAIL_ADDRESS,  -- CR29489
                C.X_MIDDLE_INITIAL MIDDLE_INITIAL,   -- CR29489
                pe.x_esn
                   AS CONTRACT_NUMBER,   -- CR29489
                pe.X_ENROLLED_DATE CONTRACT_PURCHASE_DATE, -- CR26009: changed date from X_INSERT_DATE
               (SELECT trunc(MIN (install_date))
                         FROM table_site_part m
                        WHERE     m.x_service_id = TSP.x_service_id
                          and 1=(case when 1 = (SELECT COUNT (*) FROM table_site_part sp WHERE sp.x_service_id = m.x_service_id) then 1
                           else NVL (x_refurb_flag, 1) end)) EQUIPMENT_PURCHASE_DATE, --CR33533
                DECODE (xvs.vas_name, 'HPP BYOP', 'BYOP', pc.name)
                   AS MODEL_NUMBER,  -- CR29489
                PI.PART_SERIAL_NO
                   AS SERIAL_NUMBER,  -- CR29489
                DECODE (xvs.vas_name, 'HPP BYOP', '03836', 'BYOP', '03836', decode(LTRIM(RTRIM(PN.X_MANUFACTURER)),'ALCATEL','03531',
                                  'HUAWEI' ,'03736',
                                  'KYOCERA' , '00355',
                                  'LG INC', 'LG' ,
                                  'MOTOROLA INC' , 'MOT',
                                  'NOKIA INC' ,'NKA',
                                  'SAMSUNG INC' , 'SMG',
                                  'TRACFONE' ,'03836',
                                  'UNIMAX' ,'03837',
                                  'ZTE' , '03838',
                                  'APPLE' , 'APP',
                                  'RIM' , 'RIM', decode(LTRIM(RTRIM(PN.X_MANUFACTURER)),'BYOP', '03836',PN.X_MANUFACTURER)))  MANUF_CODE, -- CR33533   CR29489 CR31712
                (SELECT PART_NUMBER
                   FROM sa.TABLE_PART_NUM
                  WHERE OBJID = pe.prog_param2prtnum_monfee)
                   SKU_NUMBER,
                DECODE (PE.X_IS_RECURRING,
                        0, PE.X_ENROLL_AMOUNT,
                        PE.X_AMOUNT)
                   CONTRACT_RETAIL,   -- CR29489
                sa.SP_METADATA.GETPRICE (pn.part_number, 'TIER SERVICE NET')
                   equipment_retail,   --CR23111
                '100' UPDATE_ACTION_CODE,
                '' CANCEL_REQUEST_DATE
           FROM (SELECT PE.*, pp.prog_param2prtnum_monfee, pp.x_is_recurring
                   FROM sa.TABLE_X_CALL_TRANS CT,
                        sa.X_PROGRAM_ENROLLED PE,
                        sa.X_PROGRAM_PARAMETERS PP
                  WHERE     1 = 1
                        AND CT.X_TRANSACT_DATE >= ip_date
                        AND CT.X_RESULT = 'Completed'
                        AND CT.X_ACTION_TYPE = '3'
                        AND CT.X_REASON = 'MINCHANGE'
                        AND PE.X_ESN = CT.X_SERVICE_ID
                        AND PE.PGM_ENROLL2SITE_PART = CT.CALL_TRANS2SITE_PART
                        AND PE.X_ENROLLMENT_STATUS || '' = 'ENROLLED'
                        AND PP.X_PROG_CLASS = 'WARRANTY'
                        AND PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
                        -- CR55614 Begin : Restrict new warranty programs
                        AND pp.objid NOT IN  ( SELECT program_parameters_objid
                                               FROM   vas_programs_mv
                                               WHERE  vas_product_type      = 'HANDSET PROTECTION'
                                               UNION
                                               SELECT auto_pay_program_objid
                                               FROM   vas_programs_mv
                                               WHERE  auto_pay_program_objid IS NOT NULL
                                               AND    vas_product_type      = 'HANDSET PROTECTION'
                                              )
                       -- CR55614 End
                 ) PE,
                sa.TABLE_PART_INST PI,
                sa.TABLE_MOD_LEVEL ML,
                sa.TABLE_PART_NUM PN,
                sa.TABLE_PART_CLASS PC,
                sa.TABLE_CONTACT C,
                sa.TABLE_CONTACT_ROLE CR,
                sa.TABLE_SITE TS,
                sa.TABLE_SITE_PART TSP,
                sa.x_vas_subscriptions xvs -- CR29489 -- ECR31564
       -- ECR31564 SA.TABLE_X_SALES_TAX XST  -- CR29718
          WHERE     1 = 1
                AND PI.OBJID = PE.PGM_ENROLL2PART_INST
                AND ML.OBJID = PI.N_PART_INST2PART_MOD
                AND PN.OBJID = ML.PART_INFO2PART_NUM
                AND PC.OBJID = PN.PART_NUM2PART_CLASS
                AND C.OBJID = PE.PGM_ENROLL2CONTACT
                AND CR.CONTACT_ROLE2CONTACT = C.OBJID
                AND CR.PRIMARY_SITE = 1                              --CR23065
                AND TS.OBJID = CR.CONTACT_ROLE2SITE
                AND TSP.OBJID = PI.X_PART_INST2SITE_PART
                AND pe.x_esn = xvs.vas_esn(+)                       -- CR29489
                AND 'HPP BYOP' = xvs.vas_name(+)                    -- CR29489
			-- ECR31564	AND TSP.X_ZIPCODE = XST.X_ZIPCODE  -- CR29718
        /* CR29079 changes starts - send enrollments with code 035 */
        UNION
          SELECT
                TS.SITE_ID    CONSUMER_ID_NUMBER,
                C.TITLE       CONSUMER_TITLE,
                C.FIRST_NAME  FIRST_NAME,
                c.last_name   last_name,
                (select X.X_CITY from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_CITY, -- CR29718 --ECR31564
                (select X.X_STATE from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_STATE, -- CR29718 --ECR31564
				TSP.X_ZIPCODE SERVICE_ZIP, -- CR29718
                TSP.X_MIN     PHONE,
                DECODE (xvs.vas_name, 'HPP BYOP', xvs.x_email, C.E_MAIL) AS E_MAIL_ADDRESS,
                C.X_MIDDLE_INITIAL as MIDDLE_INITIAL,
                pe.x_esn AS CONTRACT_NUMBER,
                pe.X_ENROLLED_DATE as CONTRACT_PURCHASE_DATE,
               (SELECT trunc(MIN (install_date))
                         FROM table_site_part m
                        WHERE     m.x_service_id = TSP.x_service_id
                          and 1=(case when 1 = (SELECT COUNT (*) FROM table_site_part sp WHERE sp.x_service_id = m.x_service_id) then 1
                           else NVL (x_refurb_flag, 1) end)) EQUIPMENT_PURCHASE_DATE, --CR33533
                DECODE (xvs.vas_name, 'HPP BYOP', 'BYOP', pc.name) AS MODEL_NUMBER,
                PI.PART_SERIAL_NO AS SERIAL_NUMBER,
                DECODE (xvs.vas_name, 'HPP BYOP', '03836', 'BYOP', '03836', decode(LTRIM(RTRIM(PN.X_MANUFACTURER)),'ALCATEL','03531',
                                  'HUAWEI' ,'03736',
                                  'KYOCERA' , '00355',
                                  'LG INC', 'LG' ,
                                  'MOTOROLA INC' , 'MOT',
                                  'NOKIA INC' ,'NKA',
                                  'SAMSUNG INC' , 'SMG',
                                  'TRACFONE' ,'03836',
                                  'UNIMAX' ,'03837',
                                  'ZTE' , '03838',
                                  'APPLE' , 'APP',
                                  'RIM' , 'RIM', decode(LTRIM(RTRIM(PN.X_MANUFACTURER)),'BYOP', '03836',PN.X_MANUFACTURER)))  MANUF_CODE, -- CR33533 CR31712
                (SELECT PART_NUMBER
                   FROM sa.TABLE_PART_NUM
                  WHERE OBJID = pp.prog_param2prtnum_monfee) as SKU_NUMBER,
                DECODE (PP.X_IS_RECURRING, 0, PE.X_ENROLL_AMOUNT, PE.X_AMOUNT) as CONTRACT_RETAIL,
                sa.SP_METADATA.GETPRICE (pn.part_number, 'TIER SERVICE NET') as equipment_retail,
                '035' as UPDATE_ACTION_CODE,
                ''    as CANCEL_REQUEST_DATE
          FROM sa.X_PROGRAM_ENROLLED PE,
                sa.X_PROGRAM_PARAMETERS PP,
                sa.TABLE_PART_INST PI,
                sa.TABLE_MOD_LEVEL ML,
                sa.TABLE_PART_NUM PN,
                sa.TABLE_PART_CLASS PC,
                sa.TABLE_CONTACT C,
                sa.TABLE_CONTACT_ROLE CR,
                sa.TABLE_SITE TS,
                sa.TABLE_SITE_PART TSP,
                sa.x_vas_subscriptions xvs -- CR24989 -- ECR31564
	-- ECR31564    SA.TABLE_X_SALES_TAX XST  -- CR29718
          WHERE     1 = 1
                AND pe.x_update_stamp >= ip_date
                AND PE.X_CHARGE_DATE > PE.X_ENROLLED_DATE
                AND PE.X_ENROLLMENT_STATUS || '' = 'ENROLLED'
                AND PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
                AND PP.X_PROG_CLASS = 'WARRANTY'
                AND PI.OBJID = PE.PGM_ENROLL2PART_INST
                AND ML.OBJID = PI.N_PART_INST2PART_MOD
                AND PN.OBJID = ML.PART_INFO2PART_NUM
                AND PC.OBJID = PN.PART_NUM2PART_CLASS
                AND CR.PRIMARY_SITE = 1
                AND C.OBJID = PE.PGM_ENROLL2CONTACT
                AND CR.CONTACT_ROLE2CONTACT = C.OBJID
                AND TS.OBJID = CR.CONTACT_ROLE2SITE
                AND TSP.OBJID = PI.X_PART_INST2SITE_PART
                AND pe.x_esn = xvs.vas_esn(+)
                AND 'HPP BYOP' = xvs.vas_name(+)
      -- ECR31564  AND TSP.X_ZIPCODE = XST.X_ZIPCODE  -- CR29718
                and exists (  select 1 from x_program_trans xpt
                              where  xpt.X_ACTION_TYPE = 'RE_ENROLL'
                              and xpt.x_esn = pe.x_esn
                              and xpt.x_trans_date = PE.X_CHARGE_DATE
                              )
                 -- CR55614 Begin : Restrict new warranty programs
                AND pp.objid NOT IN  ( SELECT program_parameters_objid
                                       FROM   vas_programs_mv
                                       WHERE  vas_product_type      = 'HANDSET PROTECTION'
                                       UNION
                                       SELECT auto_pay_program_objid
                                       FROM   vas_programs_mv
                                       WHERE  auto_pay_program_objid IS NOT NULL
                                       AND    vas_product_type      = 'HANDSET PROTECTION'
                                     )
                -- CR55614 End
        /* CR29079 changes ends */
            ;

      CURSOR getProgStatusChange (
         ip_date IN DATE)
      IS
         select pe.x_esn
                   AS CONTRACT_NUMBER,    -- CR29489
                pe.X_ENROLLED_DATE CONTRACT_PURCHASE_DATE, -- CR26009: changed date from X_INSERT_DATE
                DECODE (PP.X_IS_RECURRING,
                        0, PE.X_ENROLL_AMOUNT,
                        PE.X_AMOUNT)
                   CONTRACT_RETAIL,    -- CR29489
                CASE PE.X_ENROLLMENT_STATUS
                   WHEN 'DEENROLLED'        -- CR27143
                                    THEN '030'    --CR27143
                   WHEN 'SUSPENDED' THEN '030'
                   ELSE '100'
                END
                   UPDATE_ACTION_CODE,
                CASE PE.X_ENROLLMENT_STATUS
                   WHEN 'DEENROLLED'   --CR27143
                   THEN
                      TO_CHAR (PE.X_NEXT_CHARGE_DATE, 'RRRRMMDD')    --CR27143
                   WHEN 'SUSPENDED'
                   THEN
                      TO_CHAR (PE.X_NEXT_CHARGE_DATE, 'RRRRMMDD')
                   ELSE
                      ''
                END
                   CANCEL_REQUEST_DATE,
                PI.PART_SERIAL_NO
                   AS SERIAL_NUMBER,  -- CR29489
                DECODE (xvs.vas_name, 'HPP BYOP', '03836', 'BYOP', '03836', decode(LTRIM(RTRIM(PN.X_MANUFACTURER)),'ALCATEL','03531',
                                  'HUAWEI' ,'03736',
                                  'KYOCERA' , '00355',
                                  'LG INC', 'LG' ,
                                  'MOTOROLA INC' , 'MOT',
                                  'NOKIA INC' ,'NKA',
                                  'SAMSUNG INC' , 'SMG',
                                  'TRACFONE' ,'03836',
                                  'UNIMAX' ,'03837',
                                  'ZTE' , '03838',
                                  'APPLE' , 'APP',
                                  'RIM' , 'RIM', decode(LTRIM(RTRIM(PN.X_MANUFACTURER)),'BYOP', '03836',PN.X_MANUFACTURER)))  MANUF_CODE, -- CR33533, -- CR29489 -- CR31712
                (SELECT PART_NUMBER
                   FROM sa.TABLE_PART_NUM
                  WHERE OBJID = pp.prog_param2prtnum_monfee)
                   SKU_NUMBER,
                sa.SP_METADATA.GETPRICE (pn.part_number, 'TIER SERVICE NET')
                   equipment_retail, --CR2311
                DECODE (xvs.vas_name, 'HPP BYOP', 'BYOP', pc.name)
                   AS MODEL_NUMBER,-- CR29489
                C.TITLE CONSUMER_TITLE,
                C.FIRST_NAME FIRST_NAME,
                c.last_name last_name,
                DECODE (xvs.vas_name, 'HPP BYOP', xvs.x_email, C.E_MAIL)
                   AS E_MAIL_ADDRESS, -- CR29489
                C.X_MIDDLE_INITIAL MIDDLE_INITIAL,
                TS.SITE_ID CONSUMER_ID_NUMBER,
                (select X.X_CITY from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_CITY, -- CR29718 --ECR31564
                (select X.X_STATE from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_STATE, -- CR29718 --ECR31564
				TSP.X_ZIPCODE SERVICE_ZIP,  -- CR29718
                TSP.X_MIN PHONE,
                (SELECT trunc(MIN (install_date))
                         FROM table_site_part m
                        WHERE     m.x_service_id = TSP.x_service_id
                          and 1=(case when 1 = (SELECT COUNT (*) FROM table_site_part sp WHERE sp.x_service_id = m.x_service_id) then 1
                           else NVL (x_refurb_flag, 1) end)) EQUIPMENT_PURCHASE_DATE --CR33533
           FROM sa.X_PROGRAM_PARAMETERS PP,
                sa.X_PROGRAM_ENROLLED PE,
                sa.TABLE_PART_INST PI,
                sa.TABLE_MOD_LEVEL ML,
                sa.TABLE_PART_NUM PN,
                sa.TABLE_PART_CLASS PC,
                sa.TABLE_CONTACT C,
                sa.TABLE_CONTACT_ROLE CR,
                sa.TABLE_SITE TS,
                sa.TABLE_SITE_PART TSP,
                sa.x_vas_subscriptions xvs -- ECR31564,  -- CR29489
          -- ECR31564      SA.TABLE_X_SALES_TAX XST  -- CR29718
          WHERE     1 = 1
                AND PP.X_PROG_CLASS = 'WARRANTY'
                AND PE.PGM_ENROLL2PGM_PARAMETER = PP.OBJID
                AND PE.X_ENROLLMENT_STATUS IN ('DEENROLLED', 'SUSPENDED') -- CR27143
                AND pe.x_esn NOT IN
     				(SELECT a.x_esn FROM sa.sn_Acknowledgement a WHERE a.x_action_code = '030'  AND a.x_esn =
                        pe.x_esn  -- CR29489
                    )  -- CR27143
                AND pe.x_update_stamp >= ip_date
                AND PI.OBJID = PE.PGM_ENROLL2PART_INST
                AND ML.OBJID = PI.N_PART_INST2PART_MOD
                AND PN.OBJID = ML.PART_INFO2PART_NUM
                AND PC.OBJID = PN.PART_NUM2PART_CLASS
                AND C.OBJID = PE.PGM_ENROLL2CONTACT
                AND CR.CONTACT_ROLE2CONTACT = C.OBJID
                AND CR.PRIMARY_SITE = 1      --CR23065
                AND TS.OBJID = CR.CONTACT_ROLE2SITE
                AND TSP.OBJID = PI.X_PART_INST2SITE_PART
                AND pe.x_esn = xvs.vas_esn(+)    -- CR29489
                AND 'HPP BYOP' = xvs.vas_name(+)   -- CR29489
                        --  ECR31564 AND TSP.X_ZIPCODE = XST.X_ZIPCODE    -- CR29718
                -- CR55614 Begin : Restrict new warranty programs
                AND pp.objid NOT IN  ( SELECT program_parameters_objid
                                       FROM   vas_programs_mv
                                       WHERE  vas_product_type      = 'HANDSET PROTECTION'
                                       UNION
                                       SELECT auto_pay_program_objid
                                       FROM   vas_programs_mv
                                       WHERE  auto_pay_program_objid IS NOT NULL
                                       AND    vas_product_type      = 'HANDSET PROTECTION'
                                     )
                -- CR55614 End
                UNION

                 -- suspension request for enrolled esns for refurbished cr41167
                 -- CR43802 --tune the below query

	                 select  pe.x_esn           as contract_number,
                           pe.x_enrolled_date contract_purchase_date,
                           decode (pe.x_is_recurring,0, pe.x_enroll_amount,pe.x_amount) contract_retail,
                           case pe.x_enrollment_status when 'DEENROLLED' then '030' when 'SUSPENDED' then '030' else '100' end update_action_code,
                           case pe.x_enrollment_status when 'DEENROLLED' then to_char (pe.x_next_charge_date, 'RRRRMMDD') WHEN 'SUSPENDED'  THEN TO_CHAR (PE.X_NEXT_CHARGE_DATE, 'RRRRMMDD') else '' end cancel_request_date,
                           pi.part_serial_no  as serial_number,
                           decode (xvs.vas_name, 'HPP BYOP'     , '03836', 'BYOP', '03836', decode(ltrim(rtrim(pn.x_manufacturer)),'ALCATEL','03531','HUAWEI','03736','KYOCERA','00355','LG INC', 'LG','MOTOROLA INC','MOT','NOKIA INC' ,'NKA','SAMSUNG INC', 'SMG', 'TRACFONE' ,'03836','UNIMAX','03837','ZTE' , '03838', 'APPLE' , 'APP','RIM' , 'RIM', decode(ltrim(rtrim(pn.x_manufacturer)),'BYOP', '03836',pn.x_manufacturer)))  manuf_code, -- CR33533, -- CR29489 -- CR31712
                           (select part_number from sa.table_part_num where objid = pe.prog_param2prtnum_monfee) sku_number,
                           sa.sp_metadata.getprice (pn.part_number, 'TIER SERVICE NET') equipment_retail,
                           decode (xvs.vas_name, 'HPP BYOP', 'BYOP', pc.name) as model_number,
                           c.title consumer_title,
                           c.first_name first_name,
                           c.last_name last_name,
                           decode (xvs.vas_name, 'HPP BYOP', xvs.x_email, c.e_mail) as e_mail_address,
                           c.x_middle_initial middle_initial,
                           ts.site_id consumer_id_number,
                           (select x.x_city from sa.table_x_zip_code x where tsp.x_zipcode = x.x_zip and rownum <2) service_city,
                           (select x.x_state from sa.table_x_zip_code x where tsp.x_zipcode = x.x_zip and rownum <2) service_state,
                           tsp.x_zipcode service_zip,
                           tsp.x_min phone,
                           (select trunc(min (install_date)) from table_site_part m where  m.x_service_id = tsp.x_service_id and 1=(case when 1 = (select count (*) from table_site_part sp where sp.x_service_id = m.x_service_id) then 1 else nvl (x_refurb_flag, 1) end)) equipment_purchase_date
                     from  (select pe.*, pp.prog_param2prtnum_monfee, pp.x_is_recurring,call_trans2site_part
                              from sa.table_x_call_trans ct,
                                   sa.x_program_enrolled pe,
                                   sa.x_program_parameters pp
                             where 1 = 1
                               and ct.x_transact_date >= ip_date
                               and ct.x_sourcesystem in ('Clarify', 'REFURBISHED')
                               and ct.x_action_type = '2'
                               and pe.x_esn = ct.x_service_id
                               -- and pe.pgm_enroll2site_part = ct.call_trans2site_part
                               and pp.x_prog_class = 'WARRANTY'
                               and pp.objid = pe.pgm_enroll2pgm_parameter
							   -- CR55614 Begin : Restrict new warranty programs
                               AND pp.objid NOT IN  ( SELECT program_parameters_objid
                                                      FROM   vas_programs_mv
                                                      WHERE  vas_product_type      = 'HANDSET PROTECTION'
                                                      UNION
                                                      SELECT auto_pay_program_objid
                                                      FROM   vas_programs_mv
                                                      WHERE  auto_pay_program_objid IS NOT NULL
                                                      AND    vas_product_type      = 'HANDSET PROTECTION'
                                                    )
							   -- CR55614 End
                           ) pe ,
                          table_part_inst pi,
                          sa.table_mod_level ml,
                          sa.table_part_num pn,
                          sa.table_part_class pc,
                          sa.table_contact c,
                          sa.table_contact_role cr,
                          sa.table_site ts,
                          sa.table_site_part tsp,
                          sa.x_vas_subscriptions xvs
                   where  1 = 1
                     and  pi.objid = pe.pgm_enroll2part_inst
                     and  ml.objid = pi.n_part_inst2part_mod
                     and  pn.objid = ml.part_info2part_num
                     and  pc.objid = pn.part_num2part_class
                     and  c.objid = pe.pgm_enroll2contact
                     and  cr.contact_role2contact = c.objid
                     and  ts.objid = cr.contact_role2site
                     and  tsp.x_service_id = pi.part_serial_no
                     and  tsp.objid = pe.call_trans2site_part
                     and  pe.x_esn not in (select a.x_esn from sa.sn_acknowledgement a where a.x_action_code = '030'  and a.x_esn = pe.x_esn )
                     and  cr.primary_site = 1
                     and  pe.x_esn = xvs.vas_esn(+)
                     and  'HPP BYOP' = xvs.vas_name(+);

      CURSOR getRemoveESN (
         ip_date IN DATE)
      IS
         SELECT pe.x_esn
                   AS CONTRACT_NUMBER,   -- CR29489
                pe.X_ENROLLED_DATE CONTRACT_PURCHASE_DATE, -- CR26009: changed date from X_INSERT_DATE
                DECODE (PE.X_IS_RECURRING,
                        0, PE.X_ENROLL_AMOUNT,
                        PE.X_AMOUNT)
                   CONTRACT_RETAIL,   -- CR29489
                CASE PE.X_ENROLLMENT_STATUS
                   WHEN 'READYTOREENROLL' THEN '030'
                   ELSE '100'
                END
                   UPDATE_ACTION_CODE,
                CASE PE.X_ENROLLMENT_STATUS
                   WHEN 'READYTOREENROLL'
                   THEN
                      TO_CHAR (PE.X_LOG_DATE, 'RRRRMMDD')
                   ELSE
                      ''
                END
                   CANCEL_REQUEST_DATE,
                PI.PART_SERIAL_NO
                   AS SERIAL_NUMBER,  -- CR29489
                DECODE (xvs.vas_name, 'HPP BYOP', '03836', 'BYOP', '03836', decode(LTRIM(RTRIM(PN.X_MANUFACTURER)),'ALCATEL','03531',
                                  'HUAWEI' ,'03736',
                                  'KYOCERA' , '00355',
                                  'LG INC', 'LG' ,
                                  'MOTOROLA INC' , 'MOT',
                                  'NOKIA INC' ,'NKA',
                                  'SAMSUNG INC' , 'SMG',
                                  'TRACFONE' ,'03836',
                                  'UNIMAX' ,'03837',
                                  'ZTE' , '03838',
                                  'APPLE' , 'APP',
                                  'RIM' , 'RIM', decode(LTRIM(RTRIM(PN.X_MANUFACTURER)),'BYOP', '03836',PN.X_MANUFACTURER)))  MANUF_CODE, -- CR33533  -- CR29489 CR31712
                (SELECT PART_NUMBER
                   FROM sa.TABLE_PART_NUM
                  WHERE OBJID = pe.prog_param2prtnum_monfee)
                   SKU_NUMBER,
                sa.SP_METADATA.GETPRICE (pn.part_number, 'TIER SERVICE NET')
                   equipment_retail,  -- CR23111
                DECODE (xvs.vas_name, 'HPP BYOP', 'BYOP', pc.name)
                   AS MODEL_NUMBER, -- CR29489
                C.TITLE CONSUMER_TITLE,
                C.FIRST_NAME FIRST_NAME,
                c.last_name last_name,
                DECODE (xvs.vas_name, 'HPP BYOP', xvs.x_email, C.E_MAIL)
                   AS E_MAIL_ADDRESS,    -- CR29489
                C.X_MIDDLE_INITIAL MIDDLE_INITIAL,
                TS.SITE_ID CONSUMER_ID_NUMBER,
                (select X.X_CITY from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_CITY, -- CR29718 --ECR31564
                (select X.X_STATE from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_STATE, -- CR29718 --ECR31564
				TSP.X_ZIPCODE SERVICE_ZIP,     -- CR29718
                TSP.X_MIN PHONE,
                (SELECT trunc(MIN (install_date))
                         FROM table_site_part m
                        WHERE     m.x_service_id = TSP.x_service_id
                          and 1=(case when 1 = (SELECT COUNT (*) FROM table_site_part sp WHERE sp.x_service_id = m.x_service_id) then 1
                           else NVL (x_refurb_flag, 1) end)) EQUIPMENT_PURCHASE_DATE --CR33533
           FROM (SELECT /*+ ORDERED */
                       BL.X_LOG_DATE,
                        pp.prog_param2prtnum_monfee,
                        pp.x_is_recurring,
                        PE.*
                   FROM x_billing_log BL,
                        x_program_enrolled pe,
                        x_program_parameters pp
                  WHERE     BL.x_log_date >= ip_date
                        AND BL.X_LOG_CATEGORY = 'ESN'
                        AND BL.X_LOG_TITLE = 'REMOVE_ESN'
                        AND PE.X_ESN = BL.X_ESN
                        AND PE.PGM_ENROLL2WEB_USER = BL.billing_log2web_user
                        AND pe.x_update_stamp >= ip_date
                        AND pe.x_enrollment_status || '' = 'READYTOREENROLL'
                        AND PP.OBJID = pe.pgm_enroll2pgm_parameter
                        AND pp.x_prog_class = 'WARRANTY'
                        -- CR55614 Begin : Restrict new warranty programs
                        AND pp.objid NOT IN  ( SELECT program_parameters_objid
                                               FROM   vas_programs_mv
                                               WHERE  vas_product_type      = 'HANDSET PROTECTION'
                                               UNION
                                               SELECT auto_pay_program_objid
                                               FROM   vas_programs_mv
                                               WHERE  auto_pay_program_objid IS NOT NULL
                                               AND    vas_product_type      = 'HANDSET PROTECTION'
                                             )
                        -- CR55614 End
                ) PE,
                sa.TABLE_PART_INST PI,
                sa.TABLE_MOD_LEVEL ML,
                sa.TABLE_PART_NUM PN,
                sa.TABLE_PART_CLASS PC,
                sa.TABLE_CONTACT C,
                sa.TABLE_CONTACT_ROLE CR,
                sa.TABLE_SITE TS,
                sa.TABLE_SITE_PART TSP,
                sa.x_vas_subscriptions xvs  -- CR29489  -- ECR31564
       -- ECR31564 SA.TABLE_X_SALES_TAX XST  -- CR29718
          WHERE     1 = 1
                AND PI.OBJID = PE.PGM_ENROLL2PART_INST
                AND ML.OBJID = PI.N_PART_INST2PART_MOD
                AND PN.OBJID = ML.PART_INFO2PART_NUM
                AND PC.OBJID = PN.PART_NUM2PART_CLASS
                AND C.OBJID = PE.PGM_ENROLL2CONTACT
                AND CR.CONTACT_ROLE2CONTACT = C.OBJID
                AND CR.PRIMARY_SITE = 1                              --CR23065
                AND TS.OBJID = CR.CONTACT_ROLE2SITE
                AND TSP.OBJID = PI.X_PART_INST2SITE_PART
                AND pe.x_esn NOT IN
                       (SELECT a.x_esn
                         FROM sa.sn_Acknowledgement a
                         WHERE a.x_action_code = '030'
                         AND a.x_esn = pe.x_esn
                        ) -- CR27143
                AND pe.x_esn = xvs.vas_esn(+)       -- CR29489
                AND 'HPP BYOP' = xvs.vas_name(+)    -- CR29489
         --ECR31564       AND TSP.X_ZIPCODE = XST.X_ZIPCODE   -- CR29718
              ;

      file_line        account_file_rec;
      cnt              NUMBER;
      sn_fulfillment   NUMBER;
      l_equipment_purchase_date date;
   BEGIN
      sn_fulfillment :=
         NVL (TO_NUMBER (get_param_value ('SN FULFILLMENT')), 0);
      file_line.DP_STREAM_NO := '11000010';
      file_line.RECORD_TYPE := 'L';
      file_line.PHONE_TYPE1 := 'M';
      file_line.LANGUAGE_CODE := 'ENG';
      file_line.DEALERID := '0079210';
      file_line.line_item := '1';
      file_line.QUANTITY_SOLD := '1';
      file_line.LABOR_WARR := '12';
      file_line.PARTS_WARR := '12';
      file_line.PRODUCT_CODE := '44';

      cnt := 0;

      FOR cursor_rec IN getPendingSales (ip_date)
      LOOP

         cnt := cnt + 1;
         file_line.CONSUMER_ID_NUMBER 		 := cursor_rec.CONSUMER_ID_NUMBER;
         file_line.CONSUMER_TITLE 			   := cursor_rec.CONSUMER_TITLE;
         file_line.FIRST_NAME 				     := cursor_rec.FIRST_NAME;
         file_line.last_name 				       := cursor_rec.last_name;
         file_line.service_address1 		   := 'Address not Provided';-- CR29718
         file_line.SERVICE_ADDRESS2 		   := 'Address not Provided';-- CR29718
         file_line.SERVICE_CITY 			     := cursor_rec.SERVICE_CITY;
         file_line.SERVICE_STATE 			     := cursor_rec.SERVICE_STATE;
         file_line.SERVICE_ZIP 				     := cursor_rec.SERVICE_ZIP;
         file_line.SERVICE_COUNTRY_CODE 	 := 'USA';-- CR29718
         file_line.PHONE 					         := cursor_rec.PHONE;
         file_line.E_MAIL_ADDRESS 			   := cursor_rec.E_MAIL_ADDRESS;
         file_line.MIDDLE_INITIAL 			   := cursor_rec.MIDDLE_INITIAL;
         file_line.CONTRACT_NUMBER 			   := cursor_rec.CONTRACT_NUMBER;
         file_line.CONTRACT_PURCHASE_DATE  := cursor_rec.CONTRACT_PURCHASE_DATE;
         file_line.equipment_purchase_date := NVL(get_equipment_purchase_date(cursor_rec.SERIAL_NUMBER),cursor_rec.EQUIPMENT_PURCHASE_DATE);
         file_line.PACKAGE_SEQUENCE_NUMBER := cnt;
         file_line.MODEL_NUMBER 			     := cursor_rec.MODEL_NUMBER;
         file_line.SERIAL_NUMBER 			     := cursor_rec.SERIAL_NUMBER;
         file_line.MANUF_CODE 				     := cursor_rec.MANUF_CODE;
         file_line.SKU_NUMBER 				     := cursor_rec.SKU_NUMBER;
         file_line.CONTRACT_RETAIL 			   := cursor_rec.CONTRACT_RETAIL;
         file_line.equipment_retail 		   := cursor_rec.equipment_retail;
         file_line.UPDATE_ACTION_CODE 		 := cursor_rec.UPDATE_ACTION_CODE;
         file_line.CANCEL_REQUEST_DATE 		 := cursor_rec.CANCEL_REQUEST_DATE;
         PIPE ROW (file_line);
      END LOOP;

      FOR cursor_rec IN getAccountUpdates (ip_date)
      LOOP



         cnt := cnt + 1;
         file_line.CONSUMER_ID_NUMBER 		  := cursor_rec.CONSUMER_ID_NUMBER;
         file_line.CONSUMER_TITLE 			    := cursor_rec.CONSUMER_TITLE;
         file_line.FIRST_NAME 				      := cursor_rec.FIRST_NAME;
         file_line.last_name 				        := cursor_rec.last_name;
         file_line.service_address1 		    := 'Address not Provided';-- CR29718
         file_line.SERVICE_ADDRESS2 		    := 'Address not Provided';-- CR29718
         file_line.SERVICE_CITY 			      := cursor_rec.SERVICE_CITY;
         file_line.SERVICE_STATE 			      := cursor_rec.SERVICE_STATE;
         file_line.SERVICE_ZIP 				      := cursor_rec.SERVICE_ZIP;
         file_line.SERVICE_COUNTRY_CODE 	  := 'USA';-- CR29718
         file_line.PHONE 					          := cursor_rec.PHONE;
         file_line.E_MAIL_ADDRESS 			    := cursor_rec.E_MAIL_ADDRESS;
         file_line.MIDDLE_INITIAL 			    := cursor_rec.MIDDLE_INITIAL;
         file_line.CONTRACT_NUMBER 			    := cursor_rec.CONTRACT_NUMBER;
         file_line.CONTRACT_PURCHASE_DATE 	:= cursor_rec.CONTRACT_PURCHASE_DATE;
         file_line.EQUIPMENT_PURCHASE_DATE 	:= NVL(get_equipment_purchase_date(cursor_rec.SERIAL_NUMBER),cursor_rec.EQUIPMENT_PURCHASE_DATE);
         file_line.PACKAGE_SEQUENCE_NUMBER 	:= cnt;
         file_line.MODEL_NUMBER 			      := cursor_rec.MODEL_NUMBER;
         file_line.SERIAL_NUMBER 			      := cursor_rec.SERIAL_NUMBER;
         file_line.MANUF_CODE 				      := cursor_rec.MANUF_CODE;
         file_line.SKU_NUMBER 				      := cursor_rec.SKU_NUMBER;
         file_line.CONTRACT_RETAIL 			    := cursor_rec.CONTRACT_RETAIL;
         FILE_LINE.EQUIPMENT_RETAIL 		    := NVL(get_equipment_retail_price(cursor_rec.SERIAL_NUMBER),cursor_rec.equipment_retail); --CR23111 remove SN_FULFILLMENT     sn_fulfillment
		     file_line.UPDATE_ACTION_CODE 		  := cursor_rec.UPDATE_ACTION_CODE;
         file_line.CANCEL_REQUEST_DATE 		  := cursor_rec.CANCEL_REQUEST_DATE;
         PIPE ROW (file_line);
      END LOOP;

      FOR cursor_rec IN getProgStatusChange (ip_date)
      LOOP

         cnt := cnt + 1;
         file_line.CONSUMER_ID_NUMBER 		  := cursor_rec.CONSUMER_ID_NUMBER;
         file_line.CONSUMER_TITLE 			    := cursor_rec.CONSUMER_TITLE;
         file_line.FIRST_NAME 				      := cursor_rec.FIRST_NAME;
         file_line.last_name 				        := cursor_rec.last_name;
         file_line.service_address1 		    := 'Address not Provided';-- CR29718
         file_line.SERVICE_ADDRESS2 		    := 'Address not Provided';-- CR29718
         file_line.SERVICE_CITY 			      := cursor_rec.SERVICE_CITY;
         file_line.SERVICE_STATE 			      := cursor_rec.SERVICE_STATE;
         file_line.SERVICE_ZIP 				      := cursor_rec.SERVICE_ZIP;
         file_line.SERVICE_COUNTRY_CODE 	  := 'USA';-- CR29718
         file_line.PHONE 					          := cursor_rec.PHONE;
         file_line.E_MAIL_ADDRESS 			    := cursor_rec.E_MAIL_ADDRESS;
         file_line.MIDDLE_INITIAL 			    := cursor_rec.MIDDLE_INITIAL;
         file_line.CONTRACT_NUMBER 			    := cursor_rec.CONTRACT_NUMBER;
         file_line.CONTRACT_PURCHASE_DATE 	:= cursor_rec.CONTRACT_PURCHASE_DATE;
         file_line.EQUIPMENT_PURCHASE_DATE 	:= NVL(get_equipment_purchase_date(cursor_rec.SERIAL_NUMBER),cursor_rec.EQUIPMENT_PURCHASE_DATE);
         file_line.PACKAGE_SEQUENCE_NUMBER 	:= cnt;
         file_line.MODEL_NUMBER 			      := cursor_rec.MODEL_NUMBER;
         file_line.SERIAL_NUMBER 			      := cursor_rec.SERIAL_NUMBER;
         file_line.MANUF_CODE 				      := cursor_rec.MANUF_CODE;
         file_line.SKU_NUMBER 				      := cursor_rec.SKU_NUMBER;
         file_line.CONTRACT_RETAIL 			    := cursor_rec.CONTRACT_RETAIL;
         file_line.equipment_retail 		    := cursor_rec.equipment_retail;
         file_line.UPDATE_ACTION_CODE 		  := cursor_rec.UPDATE_ACTION_CODE;
         file_line.CANCEL_REQUEST_DATE 		  := cursor_rec.CANCEL_REQUEST_DATE;
         PIPE ROW (file_line);
      END LOOP;

      FOR cursor_rec IN getRemoveESN (ip_date)
      LOOP

         cnt := cnt + 1;
         file_line.CONSUMER_ID_NUMBER 		 := cursor_rec.CONSUMER_ID_NUMBER;
         file_line.CONSUMER_TITLE 			   := cursor_rec.CONSUMER_TITLE;
         file_line.FIRST_NAME 				     := cursor_rec.FIRST_NAME;
         file_line.last_name 				       := cursor_rec.last_name;
         file_line.service_address1 		   := 'Address not Provided';-- CR29718
         file_line.SERVICE_ADDRESS2 		   := 'Address not Provided';-- CR29718
         file_line.SERVICE_CITY 			     := cursor_rec.SERVICE_CITY;
         file_line.SERVICE_STATE 			     := cursor_rec.SERVICE_STATE;
         file_line.SERVICE_ZIP 				     := cursor_rec.SERVICE_ZIP;
         file_line.SERVICE_COUNTRY_CODE 	 := 'USA';-- CR29718
         file_line.PHONE 					         := cursor_rec.PHONE;
         file_line.E_MAIL_ADDRESS 			   := cursor_rec.E_MAIL_ADDRESS;
         file_line.MIDDLE_INITIAL 			   := cursor_rec.MIDDLE_INITIAL;
         file_line.CONTRACT_NUMBER 			   := cursor_rec.CONTRACT_NUMBER;
         file_line.CONTRACT_PURCHASE_DATE  := cursor_rec.CONTRACT_PURCHASE_DATE;
         file_line.EQUIPMENT_PURCHASE_DATE := NVL(get_equipment_purchase_date(cursor_rec.SERIAL_NUMBER),cursor_rec.EQUIPMENT_PURCHASE_DATE);
         file_line.PACKAGE_SEQUENCE_NUMBER := cnt;
         file_line.MODEL_NUMBER 			     := cursor_rec.MODEL_NUMBER;
         file_line.SERIAL_NUMBER 			     := cursor_rec.SERIAL_NUMBER;
         file_line.MANUF_CODE 				     := cursor_rec.MANUF_CODE;
         file_line.SKU_NUMBER 				     := cursor_rec.SKU_NUMBER;
         file_line.CONTRACT_RETAIL 			   := cursor_rec.CONTRACT_RETAIL;
         file_line.equipment_retail			   := cursor_rec.equipment_retail;
         file_line.UPDATE_ACTION_CODE 		 := cursor_rec.UPDATE_ACTION_CODE;
         file_line.CANCEL_REQUEST_DATE 		 := cursor_rec.CANCEL_REQUEST_DATE;
         PIPE ROW (file_line);
      END LOOP;
   END getSalesAccountUpdates;

   -- Start of CR27087 and CR29638
   FUNCTION getAnnualRenewals (ip_date IN DATE)
      RETURN annualRenew_file_TAB
      PIPELINED
   IS
      CURSOR getPendingRenewals (
         ip_date IN DATE)
      IS
         SELECT TS.SITE_ID CONSUMER_ID_NUMBER,
                C.TITLE CONSUMER_TITLE,
                C.FIRST_NAME FIRST_NAME,
                c.last_name last_name,
                (select X.X_CITY from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_CITY, -- CR29718 --ECR31564
                (select X.X_STATE from sa.table_x_zip_code X where TSP.X_ZIPCODE = x.x_zip and rownum <2) SERVICE_STATE, -- CR29718 --ECR31564
                TSP.x_ZIPCODE SERVICE_ZIP, -- CR29718
                TSP.X_MIN PHONE,
                C.E_MAIL E_MAIL_ADDRESS,
                C.X_MIDDLE_INITIAL MIDDLE_INITIAL,
                pe.x_esn CONTRACT_NUMBER,
                --pe.X_ENROLLED_DATE CONTRACT_PURCHASE_DATE,	Commented and modified for CR47723
                ph.X_RQST_DATE CONTRACT_PURCHASE_DATE,		--Modified for CR47723
                ph.X_RQST_DATE CONTRACT_RENEWAL_DATE,
                (SELECT TRUNC (MIN (init_act.install_date))
                   FROM table_site_part init_act
                   WHERE init_act.x_service_id = TSP.x_service_id
                   AND NVL (x_refurb_flag, 0) <> 1)
                   EQUIPMENT_PURCHASE_DATE,
                PC.name MODEL_NUMBER,
                PI.PART_SERIAL_NO SERIAL_NUMBER,
                PN.X_MANUFACTURER   MANUF_CODE,
                (SELECT PART_NUMBER
                   FROM sa.TABLE_PART_NUM
                   WHERE OBJID = pp.prog_param2prtnum_monfee)  -- CR29638
                   SKU_NUMBER_RECURRING,
                pe.X_amount CONTRACT_RETAIL,
                sa.SP_METADATA.GETPRICE (pn.part_number, 'TIER SERVICE NET')
                 equipment_retail,  --CR23111
                '001' UPDATE_ACTION_CODE,
                '' CANCEL_REQUEST_DATE
           FROM sa.X_PROGRAM_ENROLLED PE,
                sa.X_PROGRAM_PURCH_HDR PH,
                sa.X_PROGRAM_PURCH_DTL PD,
                sa.X_PROGRAM_PARAMETERS PP,
                TABLE_PART_INST PI,
                TABLE_MOD_LEVEL ML,
                TABLE_PART_NUM PN,
                sa.TABLE_PART_CLASS PC,
                TABLE_CONTACT C,
                TABLE_CONTACT_ROLE CR,
                TABLE_SITE TS,
                sa.TABLE_SITE_PART TSP -- ECR31564
       -- ECR31564 SA.TABLE_X_SALES_TAX XST    -- CR29718
          WHERE     1 = 1
                AND PI.part_serial_no = pe.x_esn
                AND PI.N_PART_INST2PART_MOD = ml.objid
                AND ML.PART_INFO2PART_NUM = PN.OBJID
                AND PC.OBJID = PN.PART_NUM2PART_CLASS
                AND PE.PGM_ENROLL2CONTACT = C.OBJID
                AND CR.CONTACT_ROLE2CONTACT = C.OBJID
                AND CR.CONTACT_ROLE2SITE = TS.OBJID
                AND PE.PGM_ENROLL2SITE_PART = TSP.OBJID
                AND ph.x_ics_rcode IN ('1', '100')
                AND PP.X_PROG_CLASS || '' = 'WARRANTY'
                AND pp.x_charge_frq_code || '' = '365'
                AND pe.objid = PD.PGM_PURCH_DTL2PGM_ENROLLED
                AND PD.PGM_PURCH_DTL2PROG_HDR = ph.objid
                AND PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
                AND Ph.X_PAYMENT_TYPE || '' IN ('RECURRING', 'PAYNOW')
                --AND (TRUNC (ph.x_rqst_date) between TRUNC (ip_date)-1 AND TRUNC (ip_date))	Commented and modified for CR47723
                AND ph.x_rqst_date > TRUNC (ip_date)			--Modified for CR47723
                AND CR.PRIMARY_SITE = 1					--Added for CR47723
                -- ECR31564  AND TSP.X_ZIPCODE = XST.X_ZIPCODE                   -- CR29718
                -- CR55614 Begin : Restrict new warranty programs
                AND pp.objid NOT IN  ( SELECT program_parameters_objid
                                       FROM   vas_programs_mv
                                       WHERE  vas_product_type      = 'HANDSET PROTECTION'
                                       UNION
                                       SELECT auto_pay_program_objid
                                       FROM   vas_programs_mv
                                       WHERE  auto_pay_program_objid IS NOT NULL
                                       AND    vas_product_type      = 'HANDSET PROTECTION'
                                     )
                -- CR55614 End
             ;

      file_line   account_file_rec;
      cnt         NUMBER := 0;
      l_old_equipment_retail varchar2(30);
      l_equipment_purchase_date date;

   BEGIN
      file_line.DP_STREAM_NO 	:= '11000010';
      file_line.RECORD_TYPE 	:= 'L';
      file_line.PHONE_TYPE1 	:= 'M';
      file_line.LANGUAGE_CODE := 'ENG';
      file_line.DEALERID 		  := '0079210';
      file_line.line_item 		:= '1';
      file_line.QUANTITY_SOLD := '1';
      file_line.LABOR_WARR 		:= '12';
      file_line.PARTS_WARR 		:= '12';
      file_line.PRODUCT_CODE 	:= '44';

      FOR cursor_rec IN getPendingRenewals (ip_date)
      LOOP
         cnt := cnt + 1;
         file_line.CONSUMER_ID_NUMBER 		  := cursor_rec.CONSUMER_ID_NUMBER;
         file_line.CONSUMER_TITLE 			    := cursor_rec.CONSUMER_TITLE;
         file_line.FIRST_NAME 				      := cursor_rec.FIRST_NAME;
         file_line.last_name 				        := cursor_rec.last_name;
         file_line.service_address1 		    := 'Address not Provided';-- CR29718
         file_line.SERVICE_ADDRESS2 		    := 'Address not Provided';-- CR29718
         file_line.SERVICE_CITY 			      := cursor_rec.SERVICE_CITY;
         file_line.SERVICE_STATE 			      := cursor_rec.SERVICE_STATE;
         file_line.SERVICE_ZIP 				      := cursor_rec.SERVICE_ZIP;
         file_line.SERVICE_COUNTRY_CODE 	  := 'USA';-- CR29718
         file_line.PHONE 					          := cursor_rec.PHONE;
         file_line.E_MAIL_ADDRESS 			    := cursor_rec.E_MAIL_ADDRESS;
         file_line.MIDDLE_INITIAL 			    := cursor_rec.MIDDLE_INITIAL;
         file_line.CONTRACT_NUMBER 			    := cursor_rec.CONTRACT_NUMBER;
         file_line.CONTRACT_PURCHASE_DATE 	:= cursor_rec.CONTRACT_PURCHASE_DATE;
         file_line.EQUIPMENT_PURCHASE_DATE 	:= NVL(get_equipment_purchase_date(cursor_rec.SERIAL_NUMBER),cursor_rec.EQUIPMENT_PURCHASE_DATE);
         file_line.PACKAGE_SEQUENCE_NUMBER 	:= cnt;
         file_line.MODEL_NUMBER 			      := cursor_rec.MODEL_NUMBER;
         file_line.SERIAL_NUMBER 			      := cursor_rec.SERIAL_NUMBER;
         file_line.MANUF_CODE 				      := cursor_rec.MANUF_CODE;
         file_line.SKU_NUMBER 				      := cursor_rec.SKU_NUMBER_RECURRING;
         file_line.CONTRACT_RETAIL 			    := cursor_rec.CONTRACT_RETAIL;
         file_line.equipment_retail 		    := NVL(get_equipment_retail_price(cursor_rec.SERIAL_NUMBER),cursor_rec.equipment_retail);
         file_line.UPDATE_ACTION_CODE 		  := cursor_rec.UPDATE_ACTION_CODE;
         file_line.CANCEL_REQUEST_DATE 		  := cursor_rec.CANCEL_REQUEST_DATE;
         PIPE ROW (file_line);
      END LOOP;
   END getAnnualRenewals;

   -- End of CR27087 and CR29638

  function getCaseUpdates (
  	  ip_date in date
	) return case_updates_file_TAB PIPELINED
  IS
    CURSOR getHPcaseUpdates (ip_date in date) is
          	SELECT 'U' "type",
          	       xpr.x_ship_date "date",
          	       tbc.x_esn "esn",
          	       xpr.x_part_serial_no "newesn",
          	       xpr.x_tracking_no "tracking_number"
          	from table_case tbc,
          	     TABLE_X_PART_REQUEST XPR
          	where TBC.X_CASE_TYPE IN ('Handset Program','VAS') -- CR44428 included VAS
          	and   tbc.title IN ( 'Handset Protection')
          	and   xpr.request2case = tbc.objid
          	and   xpr.x_ship_date >= ip_date
          	and   xpr.x_part_num_domain = 'PHONES'
          	and   xpr.x_tracking_no IS NOT NULL
          	and   xpr.x_part_serial_no IS NOT NULL;
  begin
    for cursor_rec in getHPcaseUpdates(ip_date)
    loop
        pipe row (cursor_rec);
    end loop;
  end getCaseUpdates;

  function getCaseUpdates_byop (
  	  ip_date in date
	) return case_updates_file_TAB PIPELINED
  is
    CURSOR cur_getcaseUpdates (ip_date in date) is
       SELECT 'B' "type",
              xpr.x_ship_date "date",
              xvs.vas_esn "esn",
              NULL "newesn",
              xpr.x_part_serial_no "tracking_number" /*for byop = service net need return tracking number */
         FROM sa.table_case tbc,
              sa.table_x_part_request xpr,
              sa.x_vas_subscriptions xvs,
              sa.ff_daily_tracking dt
        WHERE     1 = 1
        AND tbc.x_case_type IN ('BYOP Handset Protection','VAS') -- CR44428 Added VAS
        AND tbc.title IN ( 'BYOP Handset Protection Program')
        AND xpr.request2case = tbc.objid
        AND xpr.x_ship_date >= ip_date
        AND XPR.X_PART_NUM_DOMAIN = 'ACC'
        AND xvs.vas_esn = tbc.x_esn
        AND xvs.vas_name = 'HPP BYOP'
        AND xpr.x_tracking_no IS NOT NULL
        AND xpr.x_part_serial_no IS NOT NULL
        AND dt.return_tracking_number = xpr.x_part_serial_no
        AND tbc.creation_time >= TRUNC (ip_date - 180) ---Tracking Numbers are reused after time
                                                              /* CR29489 changes ends */
          ;
  begin
    for cursor_rec in cur_getcaseUpdates(ip_date)
    loop
        pipe row (cursor_rec);
    end loop;
  end getcaseupdates_byop;

   PROCEDURE verify_enroll (xcr_rec IN OUT sa.X_CONTRACT_RESPONSES%ROWTYPE)
   IS
      --- Validations
      --      ESN has a record for Handset Protection in x_program_enrolled with status ENROLLMENTPENDING.
      ---   ESN does not have a record for Handset Protection in x_program_enrolled with status ENROLLED
      ---   ESN / MIN  is Active
      OP_RESULT_SET            SYS_REFCURSOR;
      CURRENTWTYPROGRAMS_rec   sa.VALUE_ADDEDPRG.CURRENTWTYPROGRAMS_record;
   BEGIN
      gethandsetinf (xcr_rec.x_esn,
                     xcr_rec.x_error_code,
                     xcr_rec.x_error_desc);

      IF xcr_rec.x_error_code <> 0
      THEN
         xcr_rec.x_status := 'Failed';
         XCR_REC.X_RESULT := SUBSTR (xcr_rec.x_error_desc, 1, 1000);
         RETURN;
      END IF;

      /*** Since this program is not deactivated when ESN/MIN is deactivated the status <> 'Active' is a valid status
      if nvl(get_site_part_rec.part_status,'###') <> 'Active' or
         nvl(get_part_inst_rec.x_part_inst_status,'###') != '52'
      then
         xcr_rec.x_status := 'Failed';
         XCR_REC.X_RESULT := 'ESN / MIN  is NOT Active';
         return;
      end if;
      ***/

      sa.VALUE_ADDEDPRG.getCurrentWarrantyProgram (xcr_rec.x_esn,
                                                   op_result_set,
                                                   xcr_rec.x_error_code,
                                                   xcr_rec.x_error_desc);

      IF xcr_rec.x_error_code <> 0 OR NOT (op_result_set%ISOPEN)
      THEN
         XCR_REC.X_STATUS := 'Failed';
         XCR_REC.X_RESULT := SUBSTR (xcr_rec.x_error_desc, 1, 1000);
         RETURN;
      END IF;

      FETCH op_result_set INTO CURRENTWTYPROGRAMS_rec;

      IF op_result_set%NOTFOUND
      THEN
         xcr_rec.x_status := 'Failed';
         XCR_REC.X_RESULT :=
            'Not found Record in x_program_enrolled ESN=' || xcr_rec.x_esn;

         CLOSE OP_RESULT_SET;

         RETURN;
      END IF;

      CLOSE OP_RESULT_SET;

      XCR_REC.X_CUSTOMER_ID := CURRENTWTYPROGRAMS_rec.prog_id;
      XCR_REC.X_CONTRACT_NO := CURRENTWTYPROGRAMS_rec.status;

      IF CURRENTWTYPROGRAMS_rec.status <> 'ENROLLMENTPENDING'
      THEN
         xcr_rec.x_status := 'Failed';
         xcr_rec.x_result :=
               'Status is not ENROLLMENTPENDING'
            || ' x_program_enrolled.objid: '
            || CURRENTWTYPROGRAMS_rec.prog_id
            || ' x_program_enrolled.x_enrollment_status: '
            || CURRENTWTYPROGRAMS_rec.status;
      ELSE
         XCR_REC.X_STATUS := 'Processed';
      END IF;
   END verify_enroll;

   PROCEDURE insert_pgm_log (
      ip_source        IN sa.x_program_error_log.x_source%TYPE,
      ip_error_code    IN sa.x_program_error_log.x_error_code%TYPE,
      ip_error_desc    IN sa.x_program_error_log.x_error_msg%TYPE,
      ip_description   IN sa.x_program_error_log.x_description%TYPE)
   IS
   BEGIN
      INSERT INTO sa.x_program_error_log (x_source,
                                          x_error_code,
                                          x_error_msg,
                                          x_date,
                                          x_description,
                                          x_severity)
           VALUES (ip_source,
                   ip_error_code,
                   ip_error_desc,
                   SYSDATE,
                   ip_description,
                   2);
   END insert_pgm_log;

   PROCEDURE insert_billing_log (
      ip_pe_id          IN sa.X_PROGRAM_ENROLLED.objid%TYPE,
      ip_log_title      IN sa.x_billing_log.x_log_title%TYPE,
      ip_details        IN sa.x_billing_log.x_details%TYPE,
      ip_add_details    IN sa.x_billing_log.x_additional_details%TYPE,
      ip_sourcesystem   IN sa.x_billing_log.x_sourcesystem%TYPE)
   IS
      CURSOR get_prog_enrolled (
         ip_pe_id IN sa.X_PROGRAM_ENROLLED.objid%TYPE)
      IS
         SELECT pe.*, pp.x_program_name, pp.x_program_desc
           FROM x_program_enrolled pe, x_program_parameters pp
          WHERE     pe.objid = ip_pe_id
                AND pp.objid = pe.pgm_enroll2pgm_parameter;

      pe_rec   get_prog_enrolled%ROWTYPE;
   BEGIN
      OPEN get_prog_enrolled (ip_pe_id);

      FETCH get_prog_enrolled INTO pe_rec;

      CLOSE get_prog_enrolled;

      INSERT INTO x_billing_log (objid,
                                 x_log_category,
                                 x_log_title,
                                 x_log_date,
                                 x_details,
                                 x_additional_details,
                                 x_program_name,
                                 x_nickname,
                                 x_esn,
                                 x_originator,
                                 x_agent_name,
                                 x_sourcesystem,
                                 billing_log2web_user)
           VALUES (billing_seq ('X_BILLING_LOG'),
                   'Program',
                   ip_log_title,
                   SYSDATE,
                   ip_details || pe_rec.x_program_name,
                   NVL (ip_add_details, pe_rec.x_program_desc),
                   pe_rec.x_program_name,
                   billing_getnickname (pe_rec.x_esn),
                   pe_rec.x_esn,
                   'System',
                   'System',
                   ip_sourcesystem,
                   pe_rec.pgm_enroll2web_user);
   EXCEPTION
      WHEN OTHERS
      THEN
         insert_pgm_log ('SA.VALUE_ADDEDPRG.insert_billing_log',
                         SQLCODE,
                         SUBSTR (SQLERRM, 1, 1000),
                         'Enrollment ID: ' || ip_pe_id);
   END insert_billing_log;

   FUNCTION update_enroll (
      ip_new_status       IN sa.X_PROGRAM_ENROLLED.x_enrollment_status%TYPE,
      ip_pe_id            IN sa.X_PROGRAM_ENROLLED.objid%TYPE,
      ip_current_status   IN sa.X_PROGRAM_ENROLLED.x_enrollment_status%TYPE,
      ip_sourcesystem     IN sa.x_contract_responses.x_sourcesystem%TYPE)
      RETURN BOOLEAN
   IS
      v_status   BOOLEAN;
   BEGIN
      v_status := TRUE;

      IF ip_current_status = 'ENROLLMENTPENDING'
      THEN
         BEGIN
            UPDATE sa.X_PROGRAM_ENROLLED PE
               SET PE.x_enrollment_status = ip_new_status,
                   PE.X_ENROLLED_DATE = SYSDATE,
                   PE.X_UPDATE_STAMP = SYSDATE
             WHERE PE.objid = ip_pe_id;

            UPDATE sa.X_PROGRAM_TRANS PT
               SET PT.x_enrollment_status = ip_new_status,
                   PT.X_TRANS_DATE = SYSDATE
             WHERE PT.PGM_TRAN2PGM_ENTROLLED = ip_pe_id;

            UPDATE sa.X_PROGRAM_PURCH_HDR purch
               -- This is needed since BI is pulling the enrollment details based on this date
               SET purch.x_rqst_date = SYSDATE
             WHERE PURCH.OBJID IN
                      (SELECT PGM_PURCH_DTL2PROG_HDR
                         FROM sa.X_PROGRAM_PURCH_DTL purchdtl
                        WHERE purchdtl.PGM_PURCH_DTL2PGM_ENROLLED = ip_pe_id);

            IF ip_new_status = 'ENROLLED'
            THEN
               -- Begining of CR27365_HPP_Annual_Erroneous_Charges
               UPDATE sa.X_PROGRAM_ENROLLED PE
                  SET X_NEXT_CHARGE_DATE =
                         DECODE (
                            (SELECT pp.x_program_name
                               FROM sa.X_PROGRAM_ENROLLED PE,
                                    X_PROGRAM_PARAMETERS pp
                              WHERE     pp.objid =
                                           PE.pgm_enroll2pgm_parameter
                                    AND pe.objid = ip_pe_id
                                    /* CR29489 changes starts ; exclude one time warranty programs  */
                                    AND pp.x_is_recurring = 1 /* CR29489 changes ends  */
                                                             ),
                            'Exchange Annual', (SELECT TRUNC (
                                                            MIN (
                                                               tsp.install_date)
                                                          + 730)
                                                  FROM table_site_part tsp,
                                                       x_program_enrolled pe
                                                 WHERE     PE.objid =
                                                              ip_pe_id
                                                       AND tsp.objid =
                                                              PE.PGM_ENROLL2SITE_PART
                                                       AND NVL (
                                                              x_refurb_flag,
                                                              0) <> 1),
                            pe.x_next_charge_date)
                WHERE     PE.objid = ip_pe_id
                      AND x_enrollment_status = 'ENROLLED';

               --End of CR27365_HPP_Annual_Erroneous_Charges
               insert_billing_log (ip_pe_id,
                                   'Program Enrolled',
                                   'Successfully Enrolled in ',
                                   NULL,
                                   ip_sourcesystem);
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               insert_pgm_log (
                  'SA.VALUE_ADDEDPRG.update_enroll',
                  SQLCODE,
                  SUBSTR (SQLERRM, 1, 1000),
                  'ENROLLMENT FAILED, Enrollment ID: ' || ip_pe_id);
               v_status := FALSE;
               RETURN v_status;
         END;
      END IF;

      RETURN v_status;
   END update_enroll;

   PROCEDURE Process_ACK (ip_date         IN     DATE,
                          op_error_code      OUT VARCHAR2,
                          op_error_text      OUT VARCHAR2)
   IS
      /***
      CR22313 HPP Phase 2 section 19
      21-Aug-2014  CR22313    vkashmire
      If Service net sends ESNs which has been requested to cancel the enrollment
      and if the ESN is enrolled to Monthly HPP then set them as DEENROLL_SCHEDULED and x_exp_date = x_next_charge_date
      if the ESN is enrolled to Annual then let them updated as per previous existing logic
      DEENROLL_SCHEDULED means that those ESN's will get de-enrolled at next charge date
      but till that time they can fully avail the enrolled program

      21-Aug-2014     HPP BYOP CR29489      vkashmire
      In case of BYOP handsets which are enrolled to HPP-BYOP, service sends us the BYOP-ESN
      so need to find the pseudo ESN for the BYOP-ESN; our system internally uses the pseudo-ESN for any activity
      ***/
      XCR_REC            sa.X_CONTRACT_RESPONSES%ROWTYPE;
      cnt                NUMBER := 0;
      OP_REFCURSOR       SYS_REFCURSOR;
      current_prog_rec   sa.VALUE_ADDEDPRG.CURRENTWTYPROGRAMS_record;
      /* hpp byop  cr29489 change starts  */
      lv_system_esn      table_part_inst.part_serial_no%TYPE;
      l_replacement_esn  varchar2(50);
   /* hpp byop  cr29489 change ends */

   BEGIN
      DBMS_OUTPUT.disable;
      -- Process Process_ACK begins

      -- New Sales
      cnt := 0;

      FOR SALES
         IN (SELECT xcr.*
               FROM sa.X_CONTRACT_RESPONSES xcr
              WHERE     xcr.x_status = 'New'
                    AND xcr.X_SOURCESYSTEM = 'ServiceNet'
                    AND xcr.X_STATUS_DATE >= ip_date
                    AND xcr.X_ACTION_CODE = '001')
      LOOP
         cnt := cnt + 1;
         XCR_REC := NULL;
         XCR_REC.objid := sales.objid;
         /* hpp byop CR29489 changes starts; serviceNet will send byopESN in case of HPP-BYOP and tracfone needs the pseudo-ESN for processing  */
         /*  XCR_REC.X_ESN := SALES.X_ESN;  commented and used below IF clause */
         XCR_REC.X_ESN :=
            sa.device_util_pkg.f_get_pseudo_esn_for_real_esn (SALES.X_ESN);

         IF XCR_REC.X_ESN IS NULL
         THEN
            XCR_REC.X_ESN := SALES.X_ESN;
         END IF;

         /* hpp byop CR29489 changes ends */
         VERIFY_ENROLL (XCR_REC);

         IF TRIM (sales.X_ERROR_CODE) IN ('0', '00', '000')
         -- the contract was successfully uploaded by third party SN
         THEN
            IF XCR_REC.X_STATUS = 'Processed'
            THEN
               IF update_enroll ('ENROLLED',
                                 XCR_REC.X_CUSTOMER_ID,
                                 XCR_REC.X_CONTRACT_NO,
                                 sales.X_SOURCESYSTEM)
               --XCR_REC.X_CUSTOMER_ID is CURRENTWTYPROGRAMS_rec.prog_id
               --XCR_REC.X_CONTRACT_NO is CURRENTWTYPROGRAMS_rec.status;
               THEN
                  NULL;
               ELSE
                  xcr_rec.x_status := 'Failed';
                  XCR_REC.X_RESULT := SUBSTR (SQLERRM, 1, 1000);
               END IF;
            ELSE
               IF UPDATE_ENROLL ('ENROLLMENTFAILED',
                                 XCR_REC.X_CUSTOMER_ID,
                                 XCR_REC.X_CONTRACT_NO,
                                 sales.X_SOURCESYSTEM)
               THEN
                  insert_pgm_log (
                     'SA.VALUE_ADDEDPRG.Process_ACK',
                     5,
                     xcr_rec.x_result,
                        'ENROLLMENT FAILED, Enrollment ID: '
                     || XCR_REC.X_CUSTOMER_ID
                     || ' CONTRACT NO = '
                     || sales.X_CONTRACT_NO);
               ELSE
                  xcr_rec.x_status := 'Failed';
                  XCR_REC.X_RESULT := SUBSTR (SQLERRM, 1, 1000);
               END IF;
            END IF;
         ELSE
            IF NVL (TRIM (SALES.X_ERROR_CODE), '###') <> '###'
            THEN
               xcr_rec.x_result := 'ENROLLMENTFAILED No action applied';

               IF update_enroll ('ENROLLMENTFAILED',
                                 XCR_REC.X_CUSTOMER_ID,
                                 XCR_REC.X_CONTRACT_NO,
                                 sales.X_SOURCESYSTEM)
               THEN
                  insert_pgm_log (
                     'SA.VALUE_ADDEDPRG.Process_ACK',
                     sales.x_error_code,
                     sales.x_error_desc,
                        'ENROLLMENT FAILED, ESN: '
                     || SALES.X_ESN
                     || ' CONTRACT NO = '
                     || sales.X_CONTRACT_NO);
               ELSE
                  xcr_rec.x_status := 'Failed';
                  XCR_REC.X_RESULT := SUBSTR (SQLERRM, 1, 1000);
               END IF;
            END IF;
         END IF;

         UPDATE sa.X_CONTRACT_RESPONSES a
            SET a.X_STATUS = XCR_REC.X_STATUS,
                a.X_RESULT = NVL (XCR_REC.X_RESULT, 'Completed Successfully'),
                a.x_status_date = SYSDATE
          WHERE a.objid = sales.objid;

         IF cnt >= 1000
         THEN
            COMMIT;                                       --EVERY 1000 RECORDS
            cnt := 0;
         END IF;
      END LOOP;

      COMMIT;

      cnt := 0;

      -- Cancel a contract
      FOR Cancel
         IN (SELECT xcr.*
               FROM sa.X_CONTRACT_RESPONSES xcr
              WHERE     xcr.x_status = 'New'
                    AND xcr.X_SOURCESYSTEM = 'ServiceNet'
                    AND xcr.X_STATUS_DATE >= ip_date
                    AND xcr.X_ACTION_CODE = '010')
      LOOP
         l_replacement_esn := NULL;
         /* CR29489 changes starts  */
         lv_system_esn :=
            NVL(sa.device_util_pkg.f_get_pseudo_esn_for_real_esn (cancel.x_esn), cancel.x_esn);

     --    IF lv_system_esn IS NULL then
          --THEN
          --lv_system_esn := cancel.X_ESN;
          --END IF;
	   /*
	    CR42481
	    Finding the replacement esn for the cancellation request if the old esn has been upgraded and not found in
	    the x_program_enrolled
	   */
       IF lv_system_esn IS NOT NULL then
	        BEGIN
              select   x_replacement_esn
                into   l_replacement_esn
                from   sa.x_program_upgrade
               where   1=1
                -- and x_type = 'HPP Transfer'
                 and   x_status = 'SUCCESS'
                 and   x_esn = cancel.x_esn
                 and   x_replacement_esn = cancel.x_contract_no
                 and   NOT EXISTS (select 1
                                     from sa.x_program_enrolled pe,
                                          sa.x_program_parameters pp
                                    where x_esn in ( cancel.x_esn, lv_system_esn)
                                      and pe.PGM_ENROLL2PGM_PARAMETER = pp.objid
                                      and pp.x_prog_class='WARRANTY')
                 and   EXISTS (select 1
                                 from sa.x_program_enrolled pe, sa.x_program_parameters pp
                                where x_esn = x_replacement_esn
                                  and pe.PGM_ENROLL2PGM_PARAMETER = pp.objid
                                  and pp.x_prog_class='WARRANTY'
                            );


                if l_replacement_esn is NOT NULL then
                   lv_system_esn := l_replacement_esn;
                end if;

            EXCEPTION
             when others then
               lv_system_esn := cancel.X_ESN;
            END;
          END IF;



         --SA.VALUE_ADDEDPRG.getCurrentWarrantyProgram(cancel.X_ESN,OP_REFCURSOR,op_error_code,op_error_text);
         sa.VALUE_ADDEDPRG.getCurrentWarrantyProgram (lv_system_esn,
                                                      OP_REFCURSOR,
                                                      op_error_code,
                                                      op_error_text);

         /* CR29489 changes starts  */

         IF OP_REFCURSOR%ISOPEN
         THEN
            FETCH OP_REFCURSOR INTO current_prog_rec;

            IF OP_REFCURSOR%FOUND
            THEN
               -- CR23058 MONTHLY or 365
               UPDATE sa.X_PROGRAM_ENROLLED PE
                  SET PE.x_wait_exp_date =
                         DECODE (current_prog_rec.x_charge_FRQ_code,
                                 'MONTHLY', pe.x_next_charge_date,
                                 SYSDATE),
                      /* ----- CR22313 CHANGES STARTS  ------- */
                      --PE.X_ENROLLMENT_STATUS = DECODE(PE.X_ENROLLMENT_STATUS,'ENROLLMENTPENDING','SUSPENDED',PE.X_ENROLLMENT_STATUS)
                      PE.X_ENROLLMENT_STATUS =
                         DECODE (
                            CURRENT_PROG_REC.X_CHARGE_FRQ_CODE,
                            'MONTHLY', 'DEENROLL_SCHEDULED',
                            DECODE (PE.X_ENROLLMENT_STATUS,
                                    'ENROLLMENTPENDING', 'SUSPENDED',
                                    PE.X_ENROLLMENT_STATUS)),
                      PE.X_EXP_DATE =
                         DECODE (CURRENT_PROG_REC.X_CHARGE_FRQ_CODE,
                                 'MONTHLY', PE.X_NEXT_CHARGE_DATE,
                                 SYSDATE)
                /* ----- CR22313 CHANGES ENDS  ------- */
                WHERE PE.objid = current_prog_rec.PROG_ID;
            END IF;

            CLOSE OP_REFCURSOR;
         END IF;

         IF cnt >= 1000
         THEN
            COMMIT;                                       --EVERY 1000 RECORDS
            cnt := 0;
         END IF;
      END LOOP;

      COMMIT;

      op_error_code := 0;
      op_error_text := 'Success';
      DBMS_OUTPUT.enable (1000000);
   END Process_ACK;


   PROCEDURE update_x_pgm_claim (
      p_claim_id        sa.X_PROGRAM_CLAIMS.OBJID%TYPE,
      P_CLAIM_STATUS    sa.X_PROGRAM_CLAIMS.X_STATUS%TYPE,
      p_enroll_id       sa.X_PROGRAM_CLAIMS.CLAIM2PGM_ENROLLED%TYPE,
      p_case_id         sa.X_PROGRAM_CLAIMS.CLAIM2CASE%TYPE)
   IS
   BEGIN
      UPDATE sa.X_PROGRAM_CLAIMS
         SET X_STATUS = p_claim_status,
             X_STATUS_DATE = SYSDATE,
             CLAIM2PGM_ENROLLED = p_enroll_id,
             CLAIM2CASE = p_case_id
       WHERE objid = p_claim_id;
   END update_x_pgm_claim;

   PROCEDURE update_x_device_claim (
      p_claim_id        sa.x_device_claims.objid%TYPE,
      p_claim_status    sa.x_device_claims.x_status%TYPE,
      p_enroll_id       sa.x_device_claims.claim2pgm_enrolled%TYPE,
      p_case_id         sa.x_device_claims.claim2case%TYPE)
   IS
   BEGIN
      UPDATE sa.x_device_claims
         SET x_status = p_claim_status,
             x_status_date = SYSDATE,
             claim2pgm_enrolled = p_enroll_id,
             claim2case = p_case_id
       WHERE objid = p_claim_id;
   END update_x_device_claim;

   FUNCTION get_replacement_part (IP_ESN       IN VARCHAR2,
                                  IP_ZIPCODE   IN VARCHAR2,
                                  IP_ACTION    IN VARCHAR2)
      RETURN VARCHAR2
   IS
      OP_CURR_TECH         VARCHAR2 (200);
      OP_STATUS            VARCHAR2 (200);
      OP_MODEL             VARCHAR2 (200);
      OP_CURR_SIM_PROF     VARCHAR2 (200);
      OP_CURR_MIN          VARCHAR2 (200);
      OP_CURR_CARRIER_ID   NUMBER;
      OP_CURR_PARENT_ID    NUMBER;
      OP_CURR_ZIP_CODE     VARCHAR2 (200);
      OP1_PORT             VARCHAR2 (200);
      OP1_CARR_ID          NUMBER;
      OP1_PARENT_ID        NUMBER;
      OP1_CASE_CONF        NUMBER;
      OP1_REPL_PART        VARCHAR2 (200);
      OP1_REPL_SIM_PROF    VARCHAR2 (200);
      OP1_REPL_UNITS       NUMBER;
      OP1_REPL_DAYS        NUMBER;
      OP1_ISSUE            VARCHAR2 (200);
      OP2_PORT             VARCHAR2 (200);
      OP2_CARR_ID          NUMBER;
      OP2_PARENT_ID        NUMBER;
      OP2_CASE_CONF        NUMBER;
      OP2_REPL_PART        VARCHAR2 (200);
      OP2_REPL_SIM_PROF    VARCHAR2 (200);
      OP2_REPL_UNITS       NUMBER;
      OP2_REPL_DAYS        NUMBER;
      OP2_ISSUE            VARCHAR2 (200);
      OP2_BRIBE_UNITS      NUMBER;
      OP_ERROR_NUM         VARCHAR2 (4000);
      OP_ERROR_MSG         VARCHAR2 (4000);
   BEGIN
      sa.DEFECTIVE_PHONE_SIM_PRC (IP_ESN               => IP_ESN,
                                  IP_ZIPCODE           => IP_ZIPCODE,
                                  IP_ACTION            => IP_ACTION,
                                  OP_CURR_TECH         => OP_CURR_TECH,
                                  OP_STATUS            => OP_STATUS,
                                  OP_MODEL             => OP_MODEL,
                                  OP_CURR_SIM_PROF     => OP_CURR_SIM_PROF,
                                  OP_CURR_MIN          => OP_CURR_MIN,
                                  OP_CURR_CARRIER_ID   => OP_CURR_CARRIER_ID,
                                  OP_CURR_PARENT_ID    => OP_CURR_PARENT_ID,
                                  OP_CURR_ZIP_CODE     => OP_CURR_ZIP_CODE,
                                  OP1_PORT             => OP1_PORT,
                                  OP1_CARR_ID          => OP1_CARR_ID,
                                  OP1_PARENT_ID        => OP1_PARENT_ID,
                                  OP1_CASE_CONF        => OP1_CASE_CONF,
                                  OP1_REPL_PART        => OP1_REPL_PART,
                                  OP1_REPL_SIM_PROF    => OP1_REPL_SIM_PROF,
                                  OP1_REPL_UNITS       => OP1_REPL_UNITS,
                                  OP1_REPL_DAYS        => OP1_REPL_DAYS,
                                  OP1_ISSUE            => OP1_ISSUE,
                                  OP2_PORT             => OP2_PORT,
                                  OP2_CARR_ID          => OP2_CARR_ID,
                                  OP2_PARENT_ID        => OP2_PARENT_ID,
                                  OP2_CASE_CONF        => OP2_CASE_CONF,
                                  OP2_REPL_PART        => OP2_REPL_PART,
                                  OP2_REPL_SIM_PROF    => OP2_REPL_SIM_PROF,
                                  OP2_REPL_UNITS       => OP2_REPL_UNITS,
                                  OP2_REPL_DAYS        => OP2_REPL_DAYS,
                                  OP2_ISSUE            => OP2_ISSUE,
                                  OP2_BRIBE_UNITS      => OP2_BRIBE_UNITS,
                                  OP_ERROR_NUM         => OP_ERROR_NUM,
                                  OP_ERROR_MSG         => OP_ERROR_MSG);
      DBMS_OUTPUT.PUT_LINE (CHR (10) || 'OP1_REPL_PART ' || OP1_REPL_PART);

      IF OP_ERROR_NUM = 0
      THEN
         RETURN OP1_REPL_PART;
      ELSE
         RETURN NULL;
      END IF;
   END get_replacement_part;

   PROCEDURE case_detail (
      ip_objid    IN     sa.TABLE_SITE_PART.objid%TYPE,
      ip_esn      IN     sa.table_part_inst.PART_SERIAL_NO%TYPE,
      op_detail      OUT VARCHAR2)
   IS
      CURSOR get_service_info (
         ip_objid IN table_site_part.objid%TYPE)
      IS
         SELECT xsp.webcsr_display_name
           FROM sa.x_service_plan xsp, sa.x_service_plan_site_part xspsp
          WHERE     1 = 1
                AND xspsp.table_site_part_id = ip_objid
                AND xsp.objid = xspsp.x_service_plan_id;

      get_service_info_rec   get_service_info%ROWTYPE;

      v_rate_plan            table_x_carrier_features.x_rate_plan%TYPE;
   BEGIN
      v_rate_plan := SERVICE_PLAN.F_GET_ESN_RATE_PLAN_ALL_STATUS (ip_esn);

      OPEN get_service_info (ip_objid);

      FETCH get_service_info INTO get_service_info_rec;

      IF get_service_info%NOTFOUND
      THEN
         get_service_info_rec.webcsr_display_name := 'Not Available';
      END IF;

      CLOSE get_service_info;

      op_detail :=
            'SERVICE_PLAN||'
         || get_service_info_rec.webcsr_display_name
         || '||'
         || 'RATE_PLAN||'
         || NVL (v_rate_plan, 'Not Available');
   END case_detail;

   PROCEDURE Claim_Creation (ip_date         IN     DATE,
                             op_error_code      OUT VARCHAR2,
                             op_error_text      OUT VARCHAR2)
   IS
      /*
      CR29489   HPP BYOP    21-Aug-2014    vkashmire
      procedure Claim_Creation : Modified to handle BYOP claims (x_type = B)
      */

      CURSOR get_case_header
      IS
         SELECT CH.X_TITLE,
                CH.X_CASE_TYPE,
                'Handset Replacement for Handset Protection Program' reason,
                'Service NET' point_contact,
                'ETL' source
           FROM sa.TABLE_X_CASE_CONF_HDR CH
          WHERE     CH.S_X_TITLE = 'HANDSET PROTECTION'
                AND CH.S_X_CASE_TYPE IN ('HANDSET PROGRAM','VAS'); --CR44428 Added VAS

      GET_CASE_HEADER_REC   GET_CASE_HEADER%ROWTYPE;

      /* hpp byop cr29489 changes starts */
      CURSOR cur_byop_case_header
      IS
         SELECT ch.x_title,
                CH.X_CASE_TYPE,
                'Handset Replacement for BYOP Handset Protection Program'
                   reason,
                'Service NET' point_contact,
                'ETL' source
           FROM sa.table_x_case_conf_hdr ch
          WHERE     ch.s_x_title = 'BYOP HANDSET PROTECTION PROGRAM'
                AND ch.s_x_case_type IN ('BYOP HANDSET PROTECTION','VAS'); --CR44428 Added VAS

      byop_case_header      cur_byop_case_header%ROWTYPE;

      /*  hpp byop cr29489 changes ends */

      --CR23111
      CURSOR IS_IPHONE_CUR (
         IP_SERIAL_NO IN sa.table_part_inst.PART_SERIAL_NO%TYPE)
      IS
         SELECT PN.PART_NUMBER, EXCH.X_NEW_PART_NUM EXCH_PART_NUMBER
           FROM TABLE_PART_CLASS PC,
                TABLE_BUS_ORG BO,
                TABLE_PART_NUM PN,
                table_x_class_exch_options exch,
                PC_PARAMS_VIEW VW,
                TABLE_PART_INST PI,
                TABLE_MOD_LEVEL ML
          WHERE     PN.PART_NUM2BUS_ORG = BO.OBJID
                AND PN.PART_NUM2PART_CLASS = PC.OBJID
                AND PC.NAME = VW.PART_CLASS
                AND VW.PARAM_NAME = 'OPERATING_SYSTEM'
                AND VW.PARAM_VALUE = 'IOS'
                AND PI.N_PART_INST2PART_MOD = ML.OBJID
                AND ML.PART_INFO2PART_NUM = PN.OBJID
                AND exch.source2part_class = pc.objid
                AND pi.part_serial_no = IP_SERIAL_NO;

      IS_IPHONE_REC         IS_IPHONE_CUR%ROWTYPE;

      --CR23111
      CURSOR GET_ENROLL (
         IP_SERIAL_NO IN sa.table_part_inst.PART_SERIAL_NO%TYPE)
      IS
           SELECT PE.OBJID,
                  PP.X_PROGRAM_NAME,
                  PE.X_ESN,
                  PE.PGM_ENROLL2CONTACT,
                  (SELECT OBJID
                     FROM TABLE_USER
                    WHERE S_LOGIN_NAME = 'SA' AND ROWNUM < 2)
                     SA_USER,
                  sp.x_zipcode,
                  sp.objid sp_objid
             FROM sa.X_PROGRAM_ENROLLED PE,
                  sa.X_PROGRAM_PARAMETERS PP,
                  sa.table_part_inst PI,
                  sa.TABLE_SITE_PART SP
            WHERE     1 = 1
                  -- CR23485     AND    PE.x_enrollment_status = 'ENROLLED'
                  AND PE.x_esn = IP_SERIAL_NO
                  AND pp.objid = pe.pgm_enroll2pgm_parameter
                  AND PP.X_PROG_CLASS = 'WARRANTY'
                  AND PI.PART_SERIAL_NO = PE.X_ESN
                  AND PI.X_DOMAIN = 'PHONES'
                  AND SP.OBJID = PI.X_PART_INST2SITE_PART
         ORDER BY PE.X_INSERT_DATE DESC;

      get_enroll_rec        get_enroll%ROWTYPE;

      CURSOR get_esnclaim (
         ip_serial_no IN sa.table_part_inst.PART_SERIAL_NO%TYPE)
      IS
         SELECT xpc.*
           FROM sa.X_PROGRAM_CLAIMS xpc
          WHERE xpc.X_ESN = ip_serial_no AND xpc.X_STATUS = 'Approved';

      get_esnclaim_rec      get_esnclaim%ROWTYPE;

      CURSOR get_esncase (
         ip_serial_no   IN sa.table_part_inst.PART_SERIAL_NO%TYPE,
         ip_case_type   IN sa.TABLE_CASE.X_CASE_TYPE%TYPE,
         ip_title       IN sa.TABLE_CASE.TITLE%TYPE,
         ip_issue       IN sa.TABLE_CASE.TITLE%TYPE)
      IS
         SELECT c.*
           FROM TABLE_CASE C
          WHERE     C.X_ESN = ip_serial_no
                AND C.X_CASE_TYPE || '' = ip_case_type
                AND C.TITLE || '' = ip_title
                AND SUBSTR (c.case_type_lvl1, 1, 30) || '' =
                       SUBSTR (ip_issue, 1, 30)                      --CR22404
                                               ;

      get_esncase_rec       get_esncase%ROWTYPE;

      claim_status          sa.x_program_claims.x_status%TYPE;
      P_ID_NUMBER           VARCHAR2 (255);
      P_CASE_OBJID          NUMBER;
      P_ERROR_NO            VARCHAR2 (4000);
      P_ERROR_STR           VARCHAR2 (4000);
      p_REPL_PART           VARCHAR2 (200);
      cnt                   NUMBER;
      v_case_detail         VARCHAR2 (5000);
      /* hpp byop  cr29489 change starts  */
      lv_system_esn         table_part_inst.part_serial_no%TYPE;
   /* hpp byop  cr29489 change ends */
   BEGIN
      DBMS_OUTPUT.disable;

      op_error_code := '0';
      op_error_text := 'Success';
      cnt := 0;

      OPEN get_case_header;

      FETCH GET_CASE_HEADER INTO GET_CASE_HEADER_REC;

      IF get_case_header%NOTFOUND
      THEN
         op_error_code := '6';
         op_error_text := 'ERROR: Case Header No found';

         CLOSE get_case_header;

         RETURN;
      END IF;

      CLOSE get_case_header;

      /* hpp byop  cr29489 change starts  */
      OPEN cur_byop_case_header;

      FETCH cur_byop_case_header INTO byop_case_header;

      CLOSE cur_byop_case_header;

      DBMS_OUTPUT.put_line ('BYOP case title = ' || byop_case_header.x_title);

      IF byop_case_header.x_title IS NULL
      THEN
         op_error_code := '-1';
         op_error_text := 'BYOP HPP case header not found';
         DBMS_OUTPUT.put_line (
               'P_BYOP_CLAIM_CREATION...op_error_code = '
            || op_error_code
            || '  ; so returning now');
         RETURN;
      END IF;

      /* hpp byop  cr29489 change ends  */
      FOR claim
         IN (SELECT xpc.*
               FROM sa.X_PROGRAM_CLAIMS xpc
              WHERE xpc.X_STATUS_DATE >= ip_date /* hpp byop  cr29489 change starts */
                                                    /*and   xpc.X_TYPE = 'C'*/
                     AND xpc.X_TYPE IN ('C', 'B') /* hpp byop  cr29489 change ends  */
                                                 AND xpc.X_STATUS = 'New')
      LOOP
         cnt := cnt + 1;
         claim_status := 'Approved';

         /* hpp byop  cr29489 change starts */
         IF claim.x_type = 'B'
         THEN
            --get the pseudo esn for byop esn
            lv_system_esn :=
               sa.device_util_pkg.f_get_pseudo_esn_for_real_esn (claim.x_esn);
         ELSIF claim.x_type = 'C'
         THEN
            lv_system_esn := claim.x_esn;
         END IF;

         --open get_enroll(claim.x_esn);
         OPEN get_enroll (lv_system_esn);

         /* hpp byop  cr29489 change ends  */

         FETCH get_enroll INTO get_enroll_rec;

         IF get_enroll%NOTFOUND
         THEN
            claim_status := 'Rejected';
            update_x_pgm_claim (claim.objid,
                                claim_status,
                                NULL,
                                NULL);
         END IF;

         CLOSE get_enroll;

         IF claim_status = 'Approved'
         THEN
            /* hpp byop  cr29489 change starts */
            --open get_esnclaim(claim.x_esn);
            OPEN get_esnclaim (lv_system_esn);

            /* hpp byop  cr29489 change ends  */
            FETCH get_esnclaim INTO get_esnclaim_rec;

            IF get_esnclaim%FOUND
            THEN
               claim_status := 'Rejected';
               update_x_pgm_claim (claim.objid,
                                   claim_status,
                                   NULL,
                                   NULL);
            END IF;

            CLOSE get_esnclaim;
         END IF;

         IF claim.x_type = 'C'
         THEN /* hpp byop  cr29489 - IF clause added to separatly process type B and type C */
            IF claim_status = 'Approved'
            THEN
               /* hpp byop  cr29489 change starts */
               --open get_esncase(claim.x_esn,get_case_header_rec.x_case_type,get_case_header_rec.x_title,get_enroll_rec.x_program_name);
               OPEN get_esncase (lv_system_esn,
                                 get_case_header_rec.x_case_type,
                                 get_case_header_rec.x_title,
                                 get_enroll_rec.x_program_name);

               /* hpp byop  cr29489 change starts */
               FETCH get_esncase INTO get_esncase_rec;

               IF get_esncase%FOUND
               THEN
                  claim_status := 'Rejected';
                  update_x_pgm_claim (claim.objid,
                                      claim_status,
                                      NULL,
                                      NULL);
               END IF;

               CLOSE get_esncase;
            END IF;

            p_REPL_PART :=
               get_replacement_part (get_enroll_rec.X_ESN,
                                     get_enroll_rec.x_zipcode,
                                     'DEFECTIVE_PHONE');

            --CR23111
            IF P_REPL_PART IS NULL
            THEN
               OPEN IS_IPHONE_CUR (GET_ENROLL_REC.X_ESN);

               FETCH IS_IPHONE_CUR INTO IS_IPHONE_rec;

               IF IS_IPHONE_CUR%FOUND
               THEN
                  P_REPL_PART := IS_IPHONE_REC.EXCH_PART_NUMBER;
               END IF;

               CLOSE IS_IPHONE_CUR;
            END IF;

            --CR23111

            IF claim_status = 'Approved' AND p_REPL_PART IS NOT NULL
            THEN
               case_detail (get_enroll_rec.sp_objid,
                            get_enroll_rec.X_ESN,
                            v_case_detail);

               DBMS_OUTPUT.put_line (
                     'Calling SA.CLARIFY_CASE_PKG.CREATE_CASE Replacement Part is '
                  || p_REPL_PART);

               sa.CLARIFY_CASE_PKG.CREATE_CASE (
                  P_TITLE           => get_case_header_rec.X_TITLE,
                  P_CASE_TYPE       => get_case_header_rec.X_CASE_TYPE,
                  P_STATUS          => 'Pending',
                  P_PRIORITY        => NULL,
                  P_ISSUE           => get_enroll_rec.X_PROGRAM_NAME,
                  P_SOURCE          => get_case_header_rec.source,
                  P_POINT_CONTACT   => get_case_header_rec.point_contact,
                  P_CREATION_TIME   => SYSDATE,
                  P_TASK_OBJID      => NULL,
                  P_CONTACT_OBJID   => get_enroll_rec.PGM_ENROLL2CONTACT,
                  P_USER_OBJID      => get_enroll_rec.SA_USER,
                  P_ESN             => get_enroll_rec.X_ESN,
                  P_PHONE_NUM       => NULL,
                  P_FIRST_NAME      => claim.X_FIRSTNAME,
                  P_LAST_NAME       => claim.X_LASTNAME,
                  --P_E_MAIL          => NULL,  Commented and modified for CR39651
                  P_E_MAIL          => claim.x_email_id,	--Modified for CR39651
                  P_DELIVERY_TYPE   => NULL,
                  P_ADDRESS         => SUBSTR (
                                            TRIM (claim.X_ADDRESS_1)
                                         || ' '
                                         || TRIM (claim.X_ADDRESS_2),
                                         1,
                                         200),
                  P_CITY            => CLAIM.X_CITY,
                  P_STATE           => SUBSTR (claim.X_STATE, 1, 30),
                  P_ZIPCODE         => claim.X_ZIPCODE,
                  P_REPL_UNITS      => NULL,
                  P_FRAUD_OBJID     => NULL,
                  P_CASE_DETAIL     => v_case_detail,
                  P_PART_REQUEST    => p_REPL_PART,
                  P_ID_NUMBER       => P_ID_NUMBER,
                  P_CASE_OBJID      => P_CASE_OBJID,
                  P_ERROR_NO        => P_ERROR_NO,
                  P_ERROR_STR       => P_ERROR_STR);

               IF P_ERROR_NO = 0
               THEN
                  update_x_pgm_claim (claim.objid,
                                      'Approved',
                                      get_enroll_rec.objid,
                                      P_CASE_OBJID);
               ELSE
                  DBMS_OUTPUT.put_line (
                        'ERROR SA.CLARIFY_CASE_PKG.CREATE_CASE '
                     || P_ERROR_NO
                     || ' '
                     || P_ERROR_STR
                     || ' '
                     || P_CASE_OBJID);
                  update_x_pgm_claim (claim.objid,
                                      'Rejected',
                                      get_enroll_rec.objid,
                                      P_CASE_OBJID);

                  sa.OTA_UTIL_PKG.ERR_LOG (
                     'CLAIM',
                     SYSDATE,
                     'C',
                     'CLAIM_CREATION',
                     SUBSTR (
                           'GET_ENROLL_REC.X_ESN='
                        || GET_ENROLL_REC.X_ESN
                        || ', P_REPL_PART='
                        || P_REPL_PART
                        || ', p_id_number='
                        || p_id_number
                        || ', P_ERROR_NO='
                        || P_ERROR_NO
                        || ', P_ERROR_STR='
                        || P_ERROR_STR,
                        1,
                        4000));
               END IF;
            ELSE
               sa.OTA_UTIL_PKG.ERR_LOG (
                  'CLAIM',
                  SYSDATE,
                  'C',
                  'CLAIM_CREATION',
                     'ip_esn='
                  || GET_ENROLL_REC.X_ESN
                  || ', P_REPL_PART='
                  || P_REPL_PART);
            END IF;
         ELSIF claim.x_type = 'B'
         THEN
            /* process BYOP claims */
            IF claim_status = 'Approved'
            THEN
               --verify whether a case has already been created for current ESN
               OPEN get_esncase (lv_system_esn,
                                 byop_case_header.X_CASE_TYPE,
                                 byop_case_header.X_TITLE,
                                 get_enroll_rec.X_PROGRAM_NAME);

               FETCH get_esncase INTO get_esncase_rec;

               IF get_esncase%FOUND
               THEN
                  DBMS_OUTPUT.put_line (
                     'get_esncase%found...claim rejected ');
                  claim_status := 'Rejected';
                  update_x_pgm_claim (claim.objid,
                                      claim_status,
                                      NULL,
                                      NULL);
               END IF;

               CLOSE get_esncase;
            END IF;

            /* ***
              IMPORTANT - for BYOP claim there is no part request;
              for BYOP, generate only Airbill request
              The replacement handset is NOT provided by tracfone ; third party agency ships the new handset to customer
            */
            IF claim_status = 'Approved'
            THEN
               case_detail (get_enroll_rec.sp_objid,
                            get_enroll_rec.X_ESN,
                            v_case_detail);

               sa.clarify_case_pkg.p_create_case_byop (
                  in_title           => byop_case_header.x_title,
                  in_case_type       => byop_case_header.x_case_type,
                  in_status          => 'Pending',
                  in_priority        => NULL,
                  in_issue           => get_enroll_rec.x_program_name,
                  in_source          => byop_case_header.source,
                  in_point_contact   => byop_case_header.point_contact,
                  in_creation_time   => SYSDATE,
                  in_task_objid      => NULL,
                  in_contact_objid   => get_enroll_rec.pgm_enroll2contact,
                  in_user_objid      => get_enroll_rec.sa_user,
                  in_esn             => get_enroll_rec.x_esn,
                  in_phone_num       => NULL,
                  in_first_name      => claim.x_firstname,
                  in_last_name       => claim.x_lastname,
                  --in_e_mail          => NULL,  Commented and modified for CR39651
                  in_e_mail          => claim.x_email_id,	--Modified for CR39651
                  in_delivery_type   => NULL,
                  in_address         => SUBSTR (
                                             TRIM (claim.x_address_1)
                                          || ' '
                                          || TRIM (claim.x_address_2),
                                          1,
                                          200),
                  in_city            => claim.x_city,
                  in_state           => SUBSTR (claim.x_state, 1, 30),
                  in_zipcode         => claim.x_zipcode,
                  in_repl_units      => NULL,
                  in_fraud_objid     => NULL,
                  in_case_detail     => v_case_detail,
                  in_part_request    => 'AIRBILL', /* *** IMPORTANT - for BYOP claim there is no part request; */
                  out_id_number      => p_id_number, /* ** for BYOP generate only Airbill request */
                  out_case_objid     => p_case_objid,
                  out_error_no       => p_error_no,
                  out_error_str      => p_error_str);
               DBMS_OUTPUT.put_line (
                     'out_id_number         => '
                  || p_id_number
                  || ', out_case_objid      => '
                  || p_case_objid
                  || ', out_error_no        => '
                  || p_error_no
                  || ', out_error_str       => '
                  || p_error_str);

               IF p_error_no = 0
               THEN
                  update_x_pgm_claim (claim.objid,
                                      'Approved',
                                      get_enroll_rec.objid,
                                      P_CASE_OBJID);
               ELSE
                  DBMS_OUTPUT.put_line (
                        'ERROR SA.CLARIFY_CASE_PKG.p_create_case_byop '
                     || p_error_no
                     || ' '
                     || p_error_str
                     || ' '
                     || p_case_objid);
                  update_x_pgm_claim (claim.objid,
                                      'Rejected',
                                      get_enroll_rec.objid,
                                      p_case_objid);
                  sa.OTA_UTIL_PKG.ERR_LOG (
                     'BYOP CLAIM',
                     SYSDATE,
                     'B',
                     'CLAIM_CREATION',
                     SUBSTR (
                           'GET_ENROLL_REC.X_ESN='
                        || GET_ENROLL_REC.X_ESN
                        || ', P_REPL_PART='
                        || P_REPL_PART
                        || ', p_id_number='
                        || p_id_number
                        || ', P_ERROR_NO='
                        || P_ERROR_NO
                        || ', P_ERROR_STR='
                        || P_ERROR_STR,
                        1,
                        4000));
               END IF;
            END IF;
         END IF;

         IF cnt >= 1000
         THEN
            COMMIT;                                       --EVERY 1000 RECORDS
            cnt := 0;
         END IF;
      END LOOP;

      COMMIT;
      DBMS_OUTPUT.enable (1000000);
   END Claim_Creation;

   PROCEDURE device_claim_creation (ip_date         IN     DATE,
                                    op_error_code      OUT VARCHAR2,
                                    op_error_text      OUT VARCHAR2)
   IS
      CURSOR get_case_header
      IS
         SELECT ch.x_title,
                ch.x_case_type,
                'Device Replacement for Car Connection Warrantee Exchange'
                   reason,
                'Audiovox' point_contact,
                'ETL' source
           FROM sa.table_x_case_conf_hdr ch
          WHERE     ch.s_x_title = 'DEVICE EXCHANGE'
                AND ch.s_x_case_type = 'WARRANTY';

      get_case_header_rec   get_case_header%ROWTYPE;

      --CR23111
      CURSOR is_cc_cur (
         ip_serial_no IN sa.table_part_inst.part_serial_no%TYPE)
      IS
         SELECT pn.part_number, exch.x_new_part_num exch_part_number
           FROM table_part_class pc,
                table_bus_org bo,
                table_part_num pn,
                table_x_class_exch_options exch,
                pc_params_view vw,
                table_part_inst pi,
                table_mod_level ml
          WHERE     pn.part_num2bus_org = bo.objid
                AND pn.part_num2part_class = pc.objid
                AND pc.name = vw.part_class
                AND vw.param_name = 'MODEL TYPE'
                AND vw.param_value = 'CAR CONNECT'
                AND pi.n_part_inst2part_mod = ml.objid
                AND ml.part_info2part_num = pn.objid
                AND exch.source2part_class = pc.objid
                AND pi.part_serial_no = ip_serial_no;

      is_cc_rec             is_cc_cur%ROWTYPE;

      --CR23111
      CURSOR get_enroll (
         ip_serial_no IN sa.table_part_inst.part_serial_no%TYPE)
      IS
         SELECT pi.part_serial_no x_esn,
                pi.x_part_inst2contact,
                (SELECT objid
                   FROM table_user
                  WHERE s_login_name = 'SA' AND ROWNUM < 2)
                   sa_user,
                sp.x_zipcode,
                sp.objid sp_objid
           FROM sa.table_part_inst pi, sa.table_site_part sp
          WHERE     1 = 1
                AND pi.part_serial_no = ip_serial_no
                AND pi.x_domain = 'PHONES'
                AND sp.objid = pi.x_part_inst2site_part;

      get_enroll_rec        get_enroll%ROWTYPE;

      CURSOR get_esnclaim (
         ip_serial_no IN sa.table_part_inst.part_serial_no%TYPE)
      IS
         SELECT xpc.*
           FROM sa.x_program_claims xpc
          WHERE xpc.x_esn = ip_serial_no AND xpc.x_status = 'Approved';

      get_esnclaim_rec      get_esnclaim%ROWTYPE;

      CURSOR get_esncase (
         ip_serial_no   IN sa.table_part_inst.part_serial_no%TYPE,
         ip_case_type   IN sa.table_case.x_case_type%TYPE,
         ip_title       IN sa.table_case.title%TYPE,
         ip_issue       IN sa.table_case.title%TYPE)
      IS
         SELECT c.*
           FROM table_case c
          WHERE     c.x_esn = ip_serial_no
                AND c.x_case_type || '' = ip_case_type
                AND c.title || '' = ip_title
                AND SUBSTR (c.case_type_lvl1, 1, 30) || '' =
                       SUBSTR (ip_issue, 1, 30);

      get_esncase_rec       get_esncase%ROWTYPE;

      claim_status          sa.x_program_claims.x_status%TYPE;
      p_id_number           VARCHAR2 (255);
      p_case_objid          NUMBER;
      p_error_no            VARCHAR2 (4000);
      p_error_str           VARCHAR2 (4000);
      p_repl_part           VARCHAR2 (200);
      cnt                   NUMBER;
      v_case_detail         VARCHAR2 (5000);
   BEGIN
      --DBMS_OUTPUT.disable;

      op_error_code := '0';
      op_error_text := 'Success';
      cnt := 0;

      OPEN get_case_header;

      FETCH get_case_header INTO get_case_header_rec;

      IF get_case_header%NOTFOUND
      THEN
         op_error_code := '6';
         op_error_text := 'ERROR: Case Header No found';

         CLOSE get_case_header;

         RETURN;
      END IF;

      CLOSE get_case_header;

      FOR claim
         IN (SELECT xpc.*
               FROM sa.x_device_claims xpc
              WHERE     xpc.x_status_date >= ip_date
                    AND xpc.x_type = 'C'
                    AND xpc.x_status = 'New')
      LOOP
         cnt := cnt + 1;
         claim_status := 'Approved';

         OPEN get_enroll (claim.x_esn);

         FETCH get_enroll INTO get_enroll_rec;

         IF get_enroll%NOTFOUND
         THEN
            claim_status := 'Rejected';
            update_x_device_claim (claim.objid,
                                   claim_status,
                                   NULL,
                                   NULL);
         END IF;

         CLOSE get_enroll;

         IF claim_status = 'Approved'
         THEN
            OPEN get_esnclaim (claim.x_esn);

            FETCH get_esnclaim INTO get_esnclaim_rec;

            IF get_esnclaim%FOUND
            THEN
               claim_status := 'Rejected';
               update_x_device_claim (claim.objid,
                                      claim_status,
                                      NULL,
                                      NULL);
            END IF;

            CLOSE get_esnclaim;
         END IF;

         IF claim_status = 'Approved'
         THEN
            OPEN get_esncase (claim.x_esn,
                              get_case_header_rec.x_case_type,
                              get_case_header_rec.x_title,
                              get_case_header_rec.reason); --get_enroll_rec.x_program_name);

            FETCH get_esncase INTO get_esncase_rec;

            IF get_esncase%FOUND
            THEN
               claim_status := 'Rejected';
               update_x_device_claim (claim.objid,
                                      claim_status,
                                      NULL,
                                      NULL);
            END IF;

            CLOSE get_esncase;
         END IF;

         p_repl_part :=
            get_replacement_part (get_enroll_rec.x_esn,
                                  get_enroll_rec.x_zipcode,
                                  'DEFECTIVE_PHONE');

         --CR23111
         IF p_repl_part IS NULL
         THEN
            OPEN is_cc_cur (get_enroll_rec.x_esn);

            FETCH is_cc_cur INTO is_cc_rec;

            IF is_cc_cur%FOUND
            THEN
               p_repl_part := is_cc_rec.exch_part_number;
            END IF;

            CLOSE is_cc_cur;
         END IF;

         --CR23111

         IF claim_status = 'Approved' AND p_repl_part IS NOT NULL
         THEN
            case_detail (get_enroll_rec.sp_objid,
                         get_enroll_rec.x_esn,
                         v_case_detail);

            DBMS_OUTPUT.put_line (
                  'Calling SA.CLARIFY_CASE_PKG.CREATE_CASE Replacement Part is '
               || p_repl_part);
            sa.clarify_case_pkg.create_case (
               p_title           => get_case_header_rec.x_title,
               p_case_type       => get_case_header_rec.x_case_type,
               p_status          => 'Pending',
               p_priority        => NULL,
               p_issue           => get_case_header_rec.reason, --get_enroll_rec.x_program_name,
               p_source          => get_case_header_rec.source,
               p_point_contact   => get_case_header_rec.point_contact,
               p_creation_time   => SYSDATE,
               p_task_objid      => NULL,
               p_contact_objid   => get_enroll_rec.x_part_inst2contact,
               p_user_objid      => get_enroll_rec.sa_user,
               p_esn             => get_enroll_rec.x_esn,
               p_phone_num       => NULL,
               p_first_name      => claim.x_firstname,
               p_last_name       => claim.x_lastname,
               p_e_mail          => NULL,
               p_delivery_type   => NULL,
               p_address         => SUBSTR (
                                         TRIM (claim.x_address_1)
                                      || ' '
                                      || TRIM (claim.x_address_2),
                                      1,
                                      200),
               p_city            => claim.x_city,
               p_state           => SUBSTR (claim.x_state, 1, 30),
               p_zipcode         => claim.x_zipcode,
               p_repl_units      => NULL,
               p_fraud_objid     => NULL,
               p_case_detail     => v_case_detail,
               p_part_request    => p_repl_part,
               p_id_number       => p_id_number,
               p_case_objid      => p_case_objid,
               p_error_no        => p_error_no,
               p_error_str       => p_error_str);

            IF p_error_no = 0
            THEN
               update_x_device_claim (claim.objid,
                                      'Approved',
                                      NULL, --  No program enrollment for Car Connection devices
                                      p_case_objid);
            ELSE
               DBMS_OUTPUT.put_line (
                     'ERROR SA.CLARIFY_CASE_PKG.CREATE_CASE '
                  || p_error_no
                  || ' '
                  || p_error_str
                  || ' '
                  || p_case_objid);
               update_x_device_claim (claim.objid,
                                      'Rejected',
                                      NULL, --  No program enrollment for Car Connection devices
                                      p_case_objid);
            END IF;
         END IF;

         IF cnt >= 1000
         THEN
            COMMIT;                                       --EVERY 1000 RECORDS
            cnt := 0;
         END IF;
      END LOOP;

      COMMIT;
      DBMS_OUTPUT.enable (1000000);
   END;
END VALUE_ADDEDPRG;
/