CREATE OR REPLACE PACKAGE BODY sa."PORT_PKG" IS
 ---------------------------------------------------------------------------------------------
 --$RCSfile: PORT_PKG.sql,v $
 --$Revision: 1.28 $
 --$Author: skota $
 --$Date: 2017/09/20 17:36:01 $
 --$ $Log: PORT_PKG.sql,v $
 --$ Revision 1.28  2017/09/20 17:36:01  skota
 --$ Merged with PROD copy
 --$
 --$ Revision 1.23  2016/06/02 14:53:29  aganesan
 --$ CR39428 Condition modified to handle only for GSM
 --$
 --$ Revision 1.22  2016/06/01 21:29:50  aganesan
 --$ CR39428 Modified condition before close_case procedure call in ivr_port_close_tkt_prc procedure
 --$
 --$ Revision 1.21  2016/05/06 17:46:43  aganesan
 --$ CR39428 Removed condition to check table part inst for given SIM
 --$
 --$ Revision 1.20  2016/05/04 22:08:53  aganesan
 --$ CR39428
 --$
 --$ Revision 1.19  2016/05/04 19:43:11  aganesan
 --$ CR39428 user objid variable changed.
 --$
 --$ Revision 1.18  2016/04/08 19:09:21  aganesan
 --$ New stored procedure added to close transaction ticket
 --$
 --$ Revision 1.17  2016/02/29 19:53:03  aganesan
 --$ IVR External ports new procedure name modified
 --$
 --$ Revision 1.16  2016/02/18 20:23:29  aganesan
 --$ New stored procedure get_port_coverage body added to for IVR external ports
 --$
 --$ Revision 1.6  2015/03/25 15:43:19  jpena
 --$ CR30440
 --$
 --$ Revision 1.5  2015/03/20 14:21:45  jpena
 --$ Changes for mformation
 --$
 --$ Revision 1.61 2014/09/26 15:08:24 jpena
 --$ Modify update of TABLE_X_CALL_TRANS to include new UDP source system entry in COMPLETE_PORT Stored Procedure.
 --$
 --$ Revision 1.59 2014/08/28 19:32:30 ahabeeb
 --$ changes for vzw lte
 --$
 --$ Revision 1.58 2014/05/09 21:56:32 sreddy
 --$ CR 26861 : Number port from Simple Mobile to NET10 - Port
 --$ updated the orphan_min_curs cursor in complete_port procedure to pick only lines
 --$
 --$ Revision 1.57 2014/05/02 15:10:51 jchacon
 --$ Remove DBEMS_OUTPUT.PUT_LINE for every error and uncommented the call tosa.toss_util_pkg.insert_error_tab_proc() in the complete_port proc.
 --$
 --$ Revision 1.56 2014/04/15 18:35:07 jchacon
 --$ Close any open cursor if an error from complete port proc is raised and the proc is instructed to return
 --$
 --$ Revision 1.51 2013/09/26 18:23:25 clinder
 --$ CR26076
 --$
 --$ Revision 1.50 2013/06/13 19:38:27 ymillan
 --$ CR22799
 --$
 --$ Revision 1.48 2013/03/14 13:25:19 ymillan
 --$ CR23775 merge with CR15434
 --$
 --$ Revision 1.47 2013/03/08 15:20:31 ymillan
 --$ CR15434 + merge c29916
 --$
 --$ Revision 1.46 2013/03/07 16:47:47 ymillan
 --$ CR15434
 --$
 --$ Revision 1.45 2013/02/22 19:39:12 icanavan
 --$ aded new service getportcarriertype_prc
 --$
 --$ Revision 1.44 2013/02/06 16:15:27 ymillan
 --$ CR23362 Port IN BB phone
 --$
 --$ Revision 1.43 2012/11/16 16:11:39 kacosta
 --$ CR22660 Port Package
 --$
 --$ Revision 1.40 2012/10/22 19:45:30 kacosta
 --$ CR22152 ST Promo Logic Enrollment Issue
 --$
 --$ Revision 1.39 2012/10/19 21:47:18 kacosta
 --$ CR22152 ST Promo Logic Enrollment Issue
 --$
 --$ Revision 1.38 2012/10/18 12:36:30 kacosta
 --$ CR22152 ST Promo Logic Enrollment Issue
 --$
 --$ Revision 1.37 2012/10/12 22:20:44 hcampano
 --$ CR22014 - ADFCRM Phase 2 (File check in)
 --$
 --$ Revision 1.36 2012/10/01 20:51:46 icanavan
 --$ Move commit
 --$
 --$ Revision 1.35 2012/09/26 20:10:24 akhan
 --$ added create or replace
 --$
 --$ Revision 1.34 2012/09/24 20:13:13 icanavan
 --$ fix locking issue CWL
 --$
 --$ Revision 1.33 2012/08/16 20:34:05 icanavan
 --$ merge TELCEL with production rollout
 --$
 --$ Revision 1.32 2012/08/02 19:24:42 kacosta
 --$ CR20558 Internal Ports - Avoid Granting Extra Service Days
 --$
 --$ Revision 1.31 2012/06/27 17:22:09 kacosta
 --$ CR20558 Internal Ports - Avoid Granting Extra Service Days
 --$
 --$ Revision 1.30 2012/06/08 14:09:08 kacosta
 --$ CR21060 Update SIM status to Active.
 --$
 --$ Revision 1.29 2012/06/04 21:34:42 kacosta
 --$ CR20161 Missing Part Number for LINES
 --$
 --$ Revision 1.28 2012/02/07 16:12:44 kacosta
 --$ CR18856 GSM upgrade defect-extra days
 --$
 --$ Revision 1.26 2012/01/19 16:02:58 icanavan
 --$ change cursor to use pc tables and not the view CR19552
 --$
 --$ Revision 1.24 2012/01/17 20:00:00 icanavan
 --$ Merge L95 with BYOP
 --$
 --$ Revision 1.23 2012/01/13 16:21:29 icanavan
 --$ Mods for NT L95
 --$
 --$ Revision 1.22 2011/11/18 23:00:18 pmistry
 --$ To get only last Activation / ReActivation call trans to modify data (min, result and carrier for NT/TF)
 --$
 ---------------------------------------------------------------------------------------------
 /********************************************************************************/
 /* Copyright ) 2009 Tracfone Wireless Inc. All rights reserved */
 /* */
 /* NAME: SA.port_pkg(PACKAGE BODY) */
 /* PURPOSE: CR12795 */
 /* FREQUENCY: */
 /* PLATFORMS: Oracle 8.0.6 AND newer versions. */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------ ---- ------ -------------------------------------------- */
 /* 1.0 04/07/10 pmistry Initial Revision */
 /* 1.1 06/10/10 Skuthadi Skip Upd of Swb Tx For ST GSM */
 /* 1.2 06/22/10 Skuthadi To perform NAP Validations for non ST */
 /* 1.3 07/16/10 Skuthadi to Check for active and deactivate old and new */
 /* esn before reserving the min with new esn */
 /* 1.4 07/19/10 Skuthadi the un-reserve of the old line done after SDC */
 /* 1.5 07/23/10 Skuthadi Reserve MIN and Perform NAP validations for ST */
 /* 1.6 09/10/10 Skuthadi NET10MC Cancel port Update call trans */
 /* 1.7 09/13/10 Pmistry Multiple Reserved line fix */
 /* 1.8 09/30/10 Pmistry CR14484 AWOP Change */
 /* 1.9-1.11 10/10/10 Skuthadi CR14491 Additional Validations if the min already */
 /* exists in Clarify */
 /* 1.12 11/24/2010 kacosta CR14799 In complete_port procedure
 /* if the x_iccid from table_x_call_trans is null
 /* and the x_result is 'Pending'
 /* and the action_text is 'ACTIVATION'
 /* and there is another completed activation
 /* then set the x_result to 'Failure'
 /* 1.12 11/30/2010 kacosta CR14826 In complete_port procedure
 /* Replicated CR14491 changes for Straight Talk to
 /* TracFone and Net10
 /* 1.19 08/17/2011 pmistry CR13249 ST GSM Upgrade */
 /* 1.20 10/24/2011 pmistry CR17793 ST GSM Upgrade Fix (modify last trans time for ESN to sysdate) */
 /* 1.22 11/14/2011 PMistry CR14033 To get only last Activation / ReActivation call trans to modify data
 /* (min, result and carrier for NT/TF) Stoping complete port to update
 /* call trans for Failed in case off all cases, Instead of that in
 /* certain cases only it will do Failed.
 /* 1.23 02/12/2011 PMistry CR18776 Sprint NT10 - UPGRADES.
 /* 1.24 01/12/2012 ICanavan CR17413 LG L95G (NT10 Unlimited GSM Postpaid)
 /* 1.x 07/12/2012 ICanavan CR20451 | CR20854: Add TELCEL Brand
 /* 1.33 08/16/2012 ICanavan CR20854 Telcel merge with production rollout
 /* 1.44 02/6/2013 YMillan CR23362 Port IN BB phone */
 /* 1.45 02/22/2013 ICanavan CR15434 Port Automation Enhancement Project */
 /* 1.46 03/06/2013 Clindner CR15434 ADDED sa. to from sa.X_PORT_CARRIERS
 /* 1.47 03/08/2013 Ymillan C29916 + CR15434 add sa. */
 /********************************************************************************/
 /********************************************************************************/
 -- CR20451 | CR20854: Add TELCEL Brand
 -- this cursor is used to see if it is a SWITCHBASED TRANSACTION, NEW COMPANIES SHOULD BE
 -- following the SWITCHBASED TRANSACTION LOGIC SO WE WILL USE IT AS ORG_FLOW 3
 CURSOR chk_st_gsm_cur(c_esn IN VARCHAR2) IS
 SELECT pcv.x_param_value
 ,bo.org_flow -- added org_flow for TELCEL
 FROM table_x_part_class_params pcp
 ,table_x_part_class_values pcv
 ,table_part_num pn
 ,table_part_inst pi
 ,table_mod_level ml
 ,table_bus_org bo
 WHERE 1 = 1
 AND pcp.x_param_name = 'NON_PPE' -- 0:ST GSM, 1:ST CDMA
 AND pi.part_serial_no = c_esn
 AND pn.part_num2bus_org = bo.objid
 --AND bo.org_id = 'STRAIGHT_TALK'
 AND bo.org_flow = '3'
 AND pcv.value2class_param = pcp.objid
 AND pcv.value2part_class = pn.part_num2part_class
 AND ml.part_info2part_num = pn.objid
 AND pi.n_part_inst2part_mod = ml.objid;
 rec_chk_st_gsm chk_st_gsm_cur%ROWTYPE;
 v_returnflag VARCHAR2(20); -- used in both complete and cancel for o/p of SDC
 v_returnmsg VARCHAR2(200); -- used in both complete and cancel for o/p of SDC
 ----------
 PROCEDURE complete_port
 (
 p_min IN VARCHAR2
 ,p_esn IN VARCHAR2
 ,p_msid IN VARCHAR2
 ,p_sim IN VARCHAR2
 , -- Skuthadi
 p_carrier_id IN NUMBER
 , -- Added for TF/TN on 05/21/10 by pmistry.
 p_case_id IN VARCHAR2
 , -- Added for TF/TN on 05/21/10 by pmistry.
 p_sourcesystem IN VARCHAR2
 , -- Added for TF/TN on 05/21/10 by pmistry.
 p_brand IN VARCHAR2
 , -- Added for TF/TN on 05/21/10 by pmistry.
 p_port_type IN VARCHAR2
 , -- Skuthadi 'Internal or External'
 p_err_num OUT NUMBER
 ,p_err_string OUT VARCHAR2
 ,p_due_date OUT DATE
 ) IS
 CURSOR c_call_tx IS
 SELECT ctx.objid
 ,ctx.call_trans2site_part
 FROM table_x_call_trans ctx
 WHERE x_service_id = p_esn
 --AND X_action_type in = '1'
 AND x_action_type IN ('1'
 ,'3') --CR11526
 AND x_result = 'Completed'
 ORDER BY ctx.x_transact_date DESC;
 r_call_tx c_call_tx%ROWTYPE;
 -- CR13531 STCC PM start on 09/10/2010.
 -- As per the PDD for STCC-4 in CR13127 we need to Unreserved all unwanted line.
 CURSOR c_part_inst IS
 SELECT pi_esn.objid
 ,
 /*
 ( SELECT COUNT(*) cnt
 FROM TABLE_PART_INST PI_PHONE
 WHERE pi_phone.part_to_esn2part_inst = pi_esn.objid
 AND X_DOMAIN = 'LINES') NUMOFLINES, */pi_line.x_msid
 ,pi_line.part_serial_no line_part_serial_no
 ,pi_line.objid line_objid
 FROM table_part_inst pi_esn
 ,table_part_inst pi_line
 WHERE pi_esn.part_serial_no = p_esn
 AND pi_esn.x_domain = 'PHONES'
 AND pi_line.part_to_esn2part_inst = pi_esn.objid
 AND pi_line.x_domain = 'LINES'; --CR11061
 -- CR13531 STCC PM end on 09/10/2010.
 r_part_inst c_part_inst%ROWTYPE;
 CURSOR value_def_curs(c_site_part_objid IN NUMBER) IS
 SELECT spfvd2.value_name servicenumber
 FROM x_serviceplanfeaturevalue_def spfvd2
 ,x_serviceplanfeature_value spfv
 ,x_service_plan_feature spf
 ,x_serviceplanfeaturevalue_def spfvd
 ,x_service_plan_site_part spsp
 WHERE 1 = 1
 AND spfvd2.objid = spfv.value_ref
 AND spfv.spf_value2spf = spf.objid
 AND spf.sp_feature2rest_value_def = spfvd.objid
 AND spf.sp_feature2service_plan = spsp.x_service_plan_id
 AND spfvd.value_name = 'SERVICE DAYS'
 AND spsp.table_site_part_id = c_site_part_objid;
 value_def_rec value_def_curs%ROWTYPE;
 /* Start on 05/21/2010 by pmistry New Declaration added for Combining code for TF/TN with ST */
 -- CR20451 | CR20854: Add TELCEL Brand changed cursor to cur_get_brand_flow
 --CURSOR cur_get_brand IS
 CURSOR cur_get_brand_flow IS
 SELECT org.org_flow -- org.org_id
 FROM table_part_num pn
 ,table_mod_level ml
 ,table_part_inst pi
 ,table_bus_org org
 WHERE pn.objid = ml.part_info2part_num
 AND ml.objid = pi.n_part_inst2part_mod
 AND pn.part_num2bus_org = org.objid
 AND pi.x_domain = 'PHONES'
 AND pi.part_serial_no = p_esn;
 CURSOR orphan_min_curs(c_esn_objid IN NUMBER) IS
 SELECT *
 FROM table_part_inst pi
 WHERE pi.part_to_esn2part_inst = c_esn_objid
 AND pi.objid NOT IN (SELECT objid /*-- !=*/
 FROM table_part_inst
 WHERE part_serial_no = p_min)
 AND pi.x_domain = 'LINES';

 CURSOR other_site_part_curs
 (
 c_esn IN VARCHAR2
 ,c_min IN VARCHAR2
 ) IS
 SELECT *
 FROM table_site_part
 WHERE x_service_id != p_esn
 AND x_min = p_min
 AND part_status = 'Active';
 other_site_part_rec other_site_part_curs%ROWTYPE;
 CURSOR other_esn_curs(c_esn IN VARCHAR2) IS
 SELECT *
 FROM table_part_inst
 WHERE part_serial_no = c_esn
 AND x_domain = 'PHONES';
 other_esn_rec other_esn_curs%ROWTYPE;
 CURSOR case_curs IS
 SELECT *
 FROM table_case
 WHERE id_number = p_case_id;
 case_rec case_curs%ROWTYPE;
 CURSOR old_site_part_curs IS
 SELECT *
 FROM table_site_part
 WHERE x_service_id = p_esn
 AND part_status = 'Active';
 CURSOR old_min_new_esn_curs -- this would be used after SDC so won't be active
 IS
 SELECT *
 FROM table_site_part
 WHERE x_service_id = p_esn;
 CURSOR old_min_curs(c_min IN VARCHAR2) IS
 SELECT pi.*
 ,(SELECT NVL(cr.x_line_return_days
 ,0) x_line_return_days
 FROM table_x_carrier_rules cr
 ,table_x_carrier c
 WHERE cr.objid = c.carrier2rules
 AND c.objid = pi.part_inst2carrier_mkt) x_line_return_days
 FROM table_part_inst pi
 WHERE pi.part_serial_no = c_min
 AND pi.x_domain = 'LINES';
 old_min_rec old_min_curs%ROWTYPE;
 CURSOR min_curs IS
 SELECT pi.*
 FROM table_part_inst pi
 WHERE pi.part_serial_no = p_min
 AND pi.x_domain = 'LINES';
 min_rec min_curs%ROWTYPE;
 -- CR17413 Start ICanavan NT10 L95
 -- CR13249 Start PM 08/16/2011 ST GSM Upgrade.
 --CURSOR esn_curs IS
 -- select pi.*
 -- , pn.x_technology
 -- ,(SELECT s.objid
 -- FROM table_site s
 -- ,table_inv_bin ib
 -- WHERE s.site_id = ib.bin_name
 -- and ib.objid = pi.part_inst2inv_bin) dealer_objid
 -- FROM table_part_inst pi, table_mod_level ml, table_part_num pn
 -- where pi.part_serial_no = p_esn
 -- and ml.objid = pi.n_part_inst2part_mod
 -- and pn.objid = ml.part_info2part_num
 -- AND pi.x_domain = 'PHONES';
 CURSOR esn_curs IS
 SELECT pi.*
 ,pn.x_technology
 ,(SELECT s.objid
 FROM table_site s
 ,table_inv_bin ib
 WHERE s.site_id = ib.bin_name
 AND ib.objid = pi.part_inst2inv_bin) dealer_objid
 ,(SELECT x_param_value
 FROM table_x_part_class_params p
 ,table_x_part_class_values v
 WHERE v.value2class_param = p.objid
 AND v.value2part_class = pc.objid
 AND x_param_name = 'DLL') dll
 ,(SELECT x_param_value
 FROM table_x_part_class_params p
 ,table_x_part_class_values v
 WHERE v.value2class_param = p.objid
 AND v.value2part_class = pc.objid
 AND x_param_name = 'NON_PPE') non_ppe
 ,(SELECT x_param_value
 FROM table_x_part_class_params p
 ,table_x_part_class_values v
 WHERE v.value2class_param = p.objid
 AND v.value2part_class = pc.objid
 AND x_param_name = 'BUS_ORG') bus
 FROM table_part_class pc
 ,table_part_num pn
 ,table_mod_level ml
 ,table_part_inst pi
 WHERE pc.objid = pn.part_num2part_class
 AND ml.part_info2part_num = pn.objid
 AND pi.n_part_inst2part_mod = ml.objid
 AND pi.part_serial_no IN (p_esn)
 AND pi.x_domain = 'PHONES';
 esn_rec esn_curs%ROWTYPE;
 -- CR13249 End PM 08/16/2011 ST GSM Upgrade.
 -- CR17413 End ICanavan NT10 L95
 CURSOR site_part_curs IS
 SELECT *
 FROM table_site_part
 WHERE x_min = p_min
 AND x_service_id = p_esn
 AND part_status = 'Active';
 site_part_rec site_part_curs%ROWTYPE;
 -- CR14491 STARTS
 /*
 CURSOR user_curs
 IS
 SELECT objid
 FROM table_user
 WHERE s_login_name = 'SA';
 user_rec user_curs%rowtype;
 */
 CURSOR user_curs IS
 SELECT case_owner2user
 FROM table_case
 WHERE id_number = p_case_id;
 user_rec user_curs%ROWTYPE;
 CURSOR get_asgnd_carrid_curs IS
 SELECT cd.x_name
 ,cd.x_value
 FROM table_case c
 ,table_x_case_detail cd
 WHERE id_number = p_case_id
 AND c.x_esn = p_esn
 AND cd.x_name || '' = 'ASSIGNED_CARRIER_ID'
 AND cd.detail2case = c.objid + 0
 ORDER BY c.creation_time DESC;
 get_asgnd_carrid_rec get_asgnd_carrid_curs%ROWTYPE;
 -- CR14491 ENDS
 CURSOR carrier_curs IS
 SELECT *
 FROM table_x_carrier
 WHERE x_carrier_id = DECODE(p_carrier_id
 ,get_asgnd_carrid_rec.x_value
 ,p_carrier_id
 ,get_asgnd_carrid_rec.x_value); -- CR14491
 carrier_rec carrier_curs%ROWTYPE;
 CURSOR case_detail_cur
 (
 case_objid NUMBER
 ,ip_name VARCHAR2
 ) IS
 SELECT *
 FROM table_x_case_detail
 WHERE detail2case = case_objid
 AND x_name = ip_name;
 case_detail_rec case_detail_cur%ROWTYPE;
 -- CR14033 Start PM 11/18/2011 to get only last Activation / ReActivation call trans to modify data (min, result and carrier for NT/TF) .
 CURSOR call_tx_curs IS
 SELECT *
 FROM (SELECT ctx.objid
 ,ctx.call_trans2site_part
 ,ctx.x_transact_date
 FROM table_x_call_trans ctx
 WHERE x_service_id = p_esn
 AND x_action_type IN ('1'
 ,'3')
 AND x_result IN ('Completed'
 ,'Pending')
 ORDER BY ctx.x_transact_date DESC)
 WHERE ROWNUM < 2;
 -- CR14033 End PM 11/18/2011
 call_tx_rec call_tx_curs%ROWTYPE;
 /*
 CURSOR phn_rc_sd_curs
 IS
 SELECT pi.part_serial_no,sp.x_service_id,sp.part_status,sp.x_expire_dt,sp.x_deact_reason,pi.x_part_inst_status,pi.x_msid,
 pi.x_domain,pi.warr_end_date
 FROM table_part_inst pi,table_site_part sp
 WHERE part_serial_no = p_esn
 AND pi.x_part_inst2site_part = sp.objid
 AND EXISTS (SELECT 1
 FROM table_part_inst pi2
 WHERE pi2.x_domain = 'REDEMPTION CARDS'
 AND pi2.x_part_inst_status = '40'
 AND pi2.part_to_esn2part_inst = pi.objid
 AND trunc(pi2.warr_end_date) > trunc (SYSDATE)); -- to see the service days on the card
 --AND trunc(sp.x_expire_dt) > trunc(SYSDATE);
 phn_rc_sd_rec phn_rc_sd_curs%ROWTYPE;
 CURSOR phn_rc_sd_curs
 IS
 SELECT pi.part_serial_no,pn.part_number,pn.x_redeem_units,pn.x_redeem_days,pi.x_part_inst_status,pi.x_msid, pi.x_domain,pi.warr_end_date
 FROM table_part_inst pi,table_mod_level ml,table_part_num pn
 WHERE part_serial_no = p_esn
 AND EXISTS (SELECT 1
 FROM table_part_inst pi2
 WHERE pi2.x_domain = 'REDEMPTION CARDS'
 AND pi2.x_part_inst_status = '40'
 AND pi2.part_to_esn2part_inst = pi.objid)
 AND pi.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid;
 phn_rc_sd_rec phn_rc_sd_curs%ROWTYPE;
 */
 CURSOR phn_rc_sd_curs IS
 SELECT pi.part_serial_no
 ,pn.part_number
 ,pn.x_redeem_units
 ,pn.x_redeem_days
 ,pi.x_part_inst_status
 ,pi.x_msid
 ,pi.x_domain
 ,pi.warr_end_date
 FROM table_part_inst pi
 ,table_mod_level ml
 ,table_part_num pn
 WHERE 1 = 1
 AND pi.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid
 AND part_serial_no IN (SELECT part_serial_no
 FROM table_part_inst pi2
 WHERE pi2.x_domain = 'REDEMPTION CARDS'
 AND pi2.x_part_inst_status IN ('40'
 ,'263')
 AND pi2.part_to_esn2part_inst IN (SELECT objid
 FROM table_part_inst
 WHERE part_serial_no = p_esn));
 phn_rc_sd_rec phn_rc_sd_curs%ROWTYPE;
 CURSOR get_nap_zip_cur IS
 SELECT cd.x_value
 FROM table_case c
 ,table_x_case_detail cd
 WHERE id_number = p_case_id
 AND c.x_esn = p_esn
 AND cd.x_name || '' = 'ACTIVATION_ZIP_CODE'
 AND cd.detail2case = c.objid + 0
 ORDER BY c.creation_time DESC;
 get_nap_zip_rec get_nap_zip_cur%ROWTYPE;
 CURSOR is_meid_carr_cur IS
 SELECT p.x_meid_carrier
 ,cg.x_carrier_name
 ,ca.x_mkt_submkt_name
 ,p.x_parent_name
 FROM table_x_carrier ca
 ,table_x_carrier_group cg
 ,table_x_parent p
 WHERE ca.x_carrier_id = DECODE(p_carrier_id
 ,get_asgnd_carrid_rec.x_value
 ,p_carrier_id
 ,get_asgnd_carrid_rec.x_value) -- CR14491
 AND ca.carrier2carrier_group = cg.objid
 AND cg.x_carrier_group2x_parent = p.objid;
 is_meid_carr_rec is_meid_carr_cur%ROWTYPE;
 CURSOR is_meid_phone_cur IS
 SELECT pcp.x_param_name
 ,pcv.x_param_value
 FROM table_x_part_class_params pcp
 ,table_x_part_class_values pcv
 ,table_part_num pn
 ,table_part_inst pi
 ,table_mod_level ml
 WHERE 1 = 1
 AND pcp.x_param_name = 'MEID_PHONE'
 AND pi.part_serial_no = p_esn
 AND pcv.value2class_param = pcp.objid
 AND pcv.value2part_class = pn.part_num2part_class
 AND ml.part_info2part_num = pn.objid
 AND pi.n_part_inst2part_mod = ml.objid;
 is_meid_phone_rec is_meid_phone_cur%ROWTYPE;
 CURSOR part_num_esn_cur IS
 SELECT pn.part_number
 FROM table_part_num pn
 ,table_part_inst pi
 ,table_mod_level ml
 WHERE 1 = 1
 AND pi.part_serial_no = p_esn
 AND ml.part_info2part_num = pn.objid
 AND pi.n_part_inst2part_mod = ml.objid;
 part_num_esn_rec part_num_esn_cur%ROWTYPE;
 CURSOR not_certify_cur
 (
 carrier_objid NUMBER
 ,repl_part_num VARCHAR2
 ) IS
 SELECT cm.*
 FROM table_x_not_certify_models cm
 ,table_part_num pn
 ,table_x_parent p
 ,table_x_carrier_group cg
 ,table_x_carrier c
 WHERE 1 = 1
 AND cm.x_part_class_objid = pn.part_num2part_class
 AND cm.x_parent_id = p.x_parent_id
 AND p.objid = cg.x_carrier_group2x_parent
 AND cg.objid = c.carrier2carrier_group
 AND c.objid = carrier_objid
 AND pn.part_number = repl_part_num;
 not_certify_rec not_certify_cur%ROWTYPE;
 CURSOR get_curr_esn_cur --- Old/Exisitng ESN
 IS
 SELECT cd.x_name
 ,cd.x_value
 FROM table_case c
 ,table_x_case_detail cd
 WHERE id_number = p_case_id
 AND c.x_esn = p_esn
 AND cd.x_name || '' = 'CURRENT_ESN'
 AND cd.detail2case = c.objid + 0
 ORDER BY c.creation_time DESC;
 get_curr_esn_rec get_curr_esn_cur%ROWTYPE;
 CURSOR get_curr_min_cur IS
 SELECT cd.x_name
 ,cd.x_value
 FROM table_case c
 ,table_x_case_detail cd
 WHERE id_number = p_case_id
 AND c.x_esn = p_esn
 AND cd.x_name || '' = 'CURRENT_MIN'
 AND cd.detail2case = c.objid + 0
 ORDER BY c.creation_time DESC;
 get_curr_min_rec get_curr_min_cur%ROWTYPE;
 CURSOR get_old_details_cur IS
 SELECT *
 FROM table_part_inst pi
 WHERE part_to_esn2part_inst IN (SELECT objid
 FROM table_part_inst
 WHERE part_serial_no = p_esn)
 AND x_domain = 'LINES'; -- CR14491
 get_old_details_rec get_old_details_cur%ROWTYPE;
 -- CR14484 PM AWOP Change Start
 CURSOR cur_pb_case_dtl IS
 --CR18856 Start KACOSTA 01/12/2012
 --SELECT cd.*
 -- FROM table_case c
 -- ,table_x_case_detail cd
 -- WHERE cd.detail2case = c.objid
 -- AND c.id_number IN (SELECT cd.x_value
 -- FROM table_case c
 -- ,table_x_case_detail cd
 -- WHERE cd.detail2case = c.objid
 -- AND id_number = p_case_id
 -- AND cd.x_name = 'UNITS_REPL_CASE_ID')
 -- AND x_name = 'SERVICE_DAYS';
 SELECT CASE
 WHEN xcd_service_days_units_repl_cs.x_name = 'SERVICE_DAYS' THEN
 NVL(TRIM(xcd_service_days_units_repl_cs.x_value)
 ,'0')
 WHEN xcd_service_days.x_name = 'SERVICE_DAYS' THEN
 NVL(TRIM(xcd_service_days.x_value)
 ,'0')
 ELSE
 NULL
 END x_value
 FROM table_case tbc
 LEFT OUTER JOIN table_x_case_detail xcd_service_days
 ON tbc.objid = xcd_service_days.detail2case
 AND xcd_service_days.x_name = 'SERVICE_DAYS'
 LEFT OUTER JOIN table_x_case_detail xcd_units_repl_case
 ON tbc.objid = xcd_units_repl_case.detail2case
 AND xcd_units_repl_case.x_name = 'UNITS_REPL_CASE_ID'
 LEFT OUTER JOIN table_case tbc_units_repl_case
 ON xcd_units_repl_case.x_value = tbc_units_repl_case.id_number
 LEFT OUTER JOIN table_x_case_detail xcd_service_days_units_repl_cs
 ON tbc_units_repl_case.objid = xcd_service_days_units_repl_cs.detail2case
 AND xcd_service_days_units_repl_cs.x_name = 'SERVICE_DAYS'
 WHERE tbc.id_number = p_case_id;
 --CR18856 End KACOSTA 01/12/2012
 rec_pb_case_dtl cur_pb_case_dtl%ROWTYPE;
 -- CR14484 PM AWOP Change End
 -- CR14491 STARTS
 CURSOR get_sim_id_curs IS
 SELECT cd.x_value
 FROM table_case c
 ,table_x_case_detail cd
 WHERE id_number = p_case_id
 AND c.x_esn = p_esn
 AND cd.x_name || '' = 'SIM_ID'
 AND cd.detail2case = c.objid + 0
 AND TRIM(cd.x_value) IS NOT NULL -- CR14826 Start kacosta 01/07/2010
 ORDER BY c.creation_time DESC;
 get_sim_id_rec get_sim_id_curs%ROWTYPE;
 -- CR14491 ENDS
 --
 -- CR14826 Start kacosta 01/07/2010
 CURSOR get_case_det_repl_sim_id_curs IS
 SELECT xcd.x_value
 FROM table_x_case_detail xcd
 ,table_case tbc
 WHERE tbc.id_number = p_case_id
 AND tbc.x_esn = p_esn
 AND tbc.objid = xcd.detail2case
 AND xcd.x_name = 'REPL_SIM_ID'
 AND TRIM(xcd.x_value) IS NOT NULL
 ORDER BY tbc.creation_time DESC;
 get_case_det_repl_sim_id_rec get_case_det_repl_sim_id_curs%ROWTYPE;
 --
 CURSOR get_case_det_iccid_curs IS
 SELECT xcd.x_value
 FROM table_x_case_detail xcd
 ,table_case tbc
 WHERE tbc.id_number = p_case_id
 AND tbc.x_esn = p_esn
 AND tbc.objid = xcd.detail2case
 AND xcd.x_name = 'ICCID'
 AND TRIM(xcd.x_value) IS NOT NULL
 ORDER BY tbc.creation_time DESC;
 get_case_det_iccid_rec get_case_det_iccid_curs%ROWTYPE;
 -- CR14826 End kacosta 01/07/2010
 --
 -- CR23362 complete ig_rim_transaction for BB ESN
 CURSOR ig_trans_rim_curs IS
 SELECT /*+ use_invisible_indexes */ *
 FROM IG_TRANSACTION A,
 (SELECT MAX(ACTION_ITEM_ID) MAX_ACTION_ITEM_ID
 FROM IG_TRANSACTION
 WHERE ORDER_TYPE in ('PIR','EPIR')
 --CR22452 AND PHONE_MANF = 'RIM' CR23775
 AND ESN = P_ESN ) B
 WHERE A.ACTION_ITEM_ID = B.MAX_ACTION_ITEM_ID
 and sa.rim_service_pkg.IF_BB_ESN(P_ESN) = 'TRUE'; --CR22452 Cr23775
 IG_TRANS_RIM_REC IG_TRANS_RIM_CURS%ROWTYPE;
 OP_MSG VARCHAR2(300):=' ';
 Op_Status Varchar2(30):= ' ';

 -- CR23362
 --

 stmt VARCHAR2(1000); -- Statement been executed
 too_many_lines EXCEPTION;
 value_def_not_found EXCEPTION;
 is_esn_pd_used NUMBER := 0;
 nap_zip VARCHAR2(20); -- to get zip as i/p for Nap from case attributes
 nap_repl_part VARCHAR2(30);
 nap_repl_tech VARCHAR2(30);
 nap_sim_profile VARCHAR2(30);
 nap_part_serial_no VARCHAR2(30);
 nap_message VARCHAR2(200);
 nap_pref_parent VARCHAR2(30);
 nap_pref_carrid VARCHAR2(30);
 nap_sim VARCHAR2(30); -- CR14491
 -- l_zip_valid NUMBER;
 l_days NUMBER := 0;
 l_brand table_bus_org.org_id%TYPE;
 --CR20451 | CR20854: Add TELCEL Brand
 l_brand_flow table_bus_org.org_flow%TYPE; -- try to use this to group logic flow for ST and TC
 l_step VARCHAR2(30) := 0;
 l_error_no VARCHAR2(30);
 l_error_str VARCHAR2(200);
 -- l_def_days NUMBER; -- to detemine the default service days based on brand name
 is_line_resrvd NUMBER := 0;
 is_old_phn_active NUMBER := 0;
 is_new_phn_active NUMBER := 0;
 --cwl 10/8/12
 case_is_locked NUMBER;
 --cwl 10/8/12
 --
 --CR22152 Start Kacosta 10/15/2012
 CURSOR get_case_old_esn_curs
 (
 c_n_case_objid table_case.objid%TYPE
 ,c_v_new_esn table_case.x_esn%TYPE
 ) IS
 SELECT xcd.x_value old_esn
 FROM table_case tbc
 JOIN table_x_case_detail xcd
 ON tbc.objid = xcd.detail2case
 WHERE tbc.objid = c_n_case_objid
 AND tbc.x_esn = c_v_new_esn
 AND xcd.x_name = 'CURRENT_ESN';
 --
 get_case_old_esn_rec get_case_old_esn_curs%ROWTYPE;
 --
 l_v_old_esn table_part_inst.part_serial_no%TYPE;
 l_n_error_code NUMBER := 0;
 l_n_promo_objid table_x_promotion.objid%TYPE;
 l_v_script_id x_enroll_promo_rule.x_script_id%TYPE;
 l_v_promo_code table_x_promotion.x_promo_code%TYPE;
 l_v_error_message VARCHAR2(32767) := 'Success';
 l_exc_transfer_promo_enrollmnt EXCEPTION;
 --CR22152 End Kacosta 10/15/2012
 --
 BEGIN
 -- Case Check.
 OPEN case_curs;
 FETCH case_curs
 INTO case_rec;
 IF case_curs%NOTFOUND THEN
 p_err_num := -101;
 p_err_string := 'CASE NOT FOUND';
 --CR25641 jchacon
 sa.toss_util_pkg.insert_error_tab_proc (
											 ip_action => 'Open case_curs',
											 ip_key => p_esn,
											 ip_program_name => 'SA.port_pkg.complete_port',
											 ip_error_text => to_char(p_err_num)||' '||p_err_string);
 CLOSE case_curs;
 --CR25641 jchacon end
 RETURN;
 END IF;
 CLOSE case_curs;
 -- CR14491 STARTS
 -- To get ASSIGNED_CARRIER_ID
 OPEN get_asgnd_carrid_curs;
 FETCH get_asgnd_carrid_curs
 INTO get_asgnd_carrid_rec;
 CLOSE get_asgnd_carrid_curs;
 -- CR14491 ENDS

 -- ESN Check.
 OPEN esn_curs;
 FETCH esn_curs INTO esn_rec;
 IF esn_curs%NOTFOUND THEN
 p_err_num := -104;
 p_err_string := 'ESN NOT FOUND';
 --CR25641 jchacon
 sa.toss_util_pkg.insert_error_tab_proc ( ip_action => 'Open esn_curs',
 ip_key => p_case_id,
 ip_program_name => 'port_pkg.complete_port',
 ip_error_text => TO_CHAR(p_err_num)||' '||p_err_string);
 CLOSE esn_curs;
 --CR25641 jchacon end
 RETURN;
 END IF;
 --CR25641 jchacon added validation
 IF (esn_rec.x_technology = 'GSM' AND p_sim IS NULL)
 OR
 (esn_rec.x_technology = 'CDMA' AND sa.Lte_service_pkg.IS_ESN_LTE_CDMA(p_esn) = 1 AND p_sim IS NULL)
 THEN
 p_err_num := -641;
 p_err_string := 'SIM MUST BE ENTERED FOR THE GIVEN GSM ESN';
 sa.toss_util_pkg.insert_error_tab_proc ( ip_action => 'Open esn_curs',
 ip_key => p_case_id,
 ip_program_name => 'port_pkg.complete_port',
 ip_error_text => TO_CHAR(p_err_num)||' '||p_err_string);
 CLOSE esn_curs;
 RETURN;
 END IF;
 IF esn_rec.x_technology = 'CDMA' AND p_msid IS NULL THEN
 p_err_num := -642;
 p_err_string := 'MSID MUST BE ENTERED FOR THE GIVEN CDMA ESN';
 sa.toss_util_pkg.insert_error_tab_proc ( ip_action => 'Open esn_curs',
 ip_key => p_case_id,
 ip_program_name => 'port_pkg.complete_port',
 ip_error_text => TO_CHAR(p_err_num)||' '||p_err_string);
 CLOSE esn_curs;
 RETURN;
 END IF;
 --CR25641 jchacon end
 CLOSE esn_curs;
 -- Carrier Check
 OPEN carrier_curs;
 FETCH carrier_curs
 INTO carrier_rec;
 --CR25641 jchacon added validation
 IF p_carrier_id IS NULL THEN
 p_err_num := -643;
 p_err_string := 'CARRIER ID IS EMPTY';
 sa.toss_util_pkg.insert_error_tab_proc(
											 ip_action => 'Open carrier_curs',
											 ip_key => p_case_id,
											 ip_program_name => 'port_pkg.complete_port',
											 ip_error_text => to_char(p_err_num)||' '||p_err_string);
 CLOSE carrier_curs;
 RETURN;
 END IF;
 --CR25641 jchacon end
 IF carrier_curs%NOTFOUND THEN
 p_err_num := -102;
 p_err_string := 'CARRIER NOT FOUND';
	 --CR25641 jchacon
 sa.toss_util_pkg.insert_error_tab_proc (
											 ip_action => 'Open carrier_curs',
											 ip_key => p_case_id,
											 ip_program_name => 'port_pkg.complete_port',
											 ip_error_text => to_char(p_err_num)||' '||p_err_string);
 CLOSE carrier_curs;
 --CR25641 jchacon end
 RETURN;
 END IF;
 CLOSE carrier_curs;
 -- User Check.
 OPEN user_curs;
 FETCH user_curs
 INTO user_rec;
 IF user_curs%NOTFOUND THEN
 p_err_num := -103;
 p_err_string := 'USER NOT FOUND';
	 --CR25641 jchacon
 sa.toss_util_pkg.insert_error_tab_proc (
											 ip_action => 'Open user_curs',
											 ip_key => p_case_id,
											 ip_program_name => 'port_pkg.complete_port',
											 ip_error_text => to_char(p_err_num)||' '||p_err_string);
 --CR25641 jchacon end
 CLOSE user_curs;
 RETURN;
 END IF;
 CLOSE user_curs;
 -- CR20451 | CR20854: Add TELCEL Brand changed all the cur_get_brand to cur_get_brand_flow
 /* Start on 05/21/2010 by pmistry
 For Combining code for TF/TN with ST. to find the brand for the ESN passed into the procedure. */
 --OPEN cur_get_brand;
 --FETCH cur_get_brand
 --INTO l_brand;
 --CLOSE cur_get_brand;
 /* End on 05/21/2010 by pmistry */
 OPEN cur_get_brand_flow;
 FETCH cur_get_brand_flow
 INTO l_brand_flow;
 CLOSE cur_get_brand_flow;
 -- to get zip code to pass to NAP
 OPEN get_nap_zip_cur;
 FETCH get_nap_zip_cur INTO get_nap_zip_rec;
 IF get_nap_zip_cur%FOUND THEN
 nap_zip := get_nap_zip_rec.x_value;
 --CR25641 jchacon added validation
 ELSE
 p_err_num := -644;
 p_err_string := 'ACTIVATION ZIP CODE WAS NOT FOUND';
 sa.toss_util_pkg.insert_error_tab_proc (
 ip_action => 'Open get_nap_zip_cur',
 ip_key => p_case_id,
 ip_program_name => 'port_pkg.complete_port',
 ip_error_text => TO_CHAR(p_err_num)||' '||p_err_string);
 CLOSE get_nap_zip_cur;
 RETURN;
 --CR25641 jchacon end
 END IF;
 CLOSE get_nap_zip_cur;
 -- CR14484 PM AWOP Change Start
 OPEN cur_pb_case_dtl;
 FETCH cur_pb_case_dtl
 INTO rec_pb_case_dtl;
 CLOSE cur_pb_case_dtl;
 -- CR14484 PM AWOP Change End
 --
 -- CR14826 Start kacosta 01/07/2010
 ---- CR14491 STARTS
 ---- TO get SIM_ID
 --OPEN get_sim_id_curs;
 --FETCH get_sim_id_curs
 -- INTO get_sim_id_rec;
 --
 --IF get_sim_id_curs%FOUND THEN
 -- SELECT DECODE(p_sim
 -- ,get_sim_id_rec.x_value
 -- ,p_sim
 -- ,get_sim_id_rec.x_value)
 -- INTO nap_sim
 -- FROM dual;
 --ELSE
 -- nap_sim := p_sim;
 --END IF;
 --
 --CLOSE get_sim_id_curs;
 --
 ---- CR14491 ENDS
 --
 IF get_case_det_repl_sim_id_curs%ISOPEN THEN
 --
 CLOSE get_case_det_repl_sim_id_curs;
 --
 END IF;
 --
 OPEN get_case_det_repl_sim_id_curs;
 FETCH get_case_det_repl_sim_id_curs
 INTO get_case_det_repl_sim_id_rec;
 --
 IF get_case_det_repl_sim_id_curs%FOUND THEN
 --
 nap_sim := get_case_det_repl_sim_id_rec.x_value;
 --
 ELSE
 --
 IF get_sim_id_curs%ISOPEN THEN
 --
 CLOSE get_sim_id_curs;
 --
 END IF;
 --
 OPEN get_sim_id_curs;
 FETCH get_sim_id_curs
 INTO get_sim_id_rec;
 --
 IF get_sim_id_curs%FOUND THEN
 --
 nap_sim := get_sim_id_rec.x_value;
 --
 ELSE
 --
 IF get_case_det_iccid_curs%ISOPEN THEN
 --
 CLOSE get_case_det_iccid_curs;
 --
 END IF;
 --
 OPEN get_case_det_iccid_curs;
 FETCH get_case_det_iccid_curs
 INTO get_case_det_iccid_rec;
 --
 IF get_case_det_iccid_curs%FOUND THEN
 --
 nap_sim := get_case_det_iccid_rec.x_value;
 --
 ELSE
 --
 nap_sim := p_sim;
 --
 END IF;
 --
 IF get_case_det_iccid_curs%ISOPEN THEN
 --
 CLOSE get_case_det_iccid_curs;
 --
 END IF;
 --
 END IF;
 --
 IF get_sim_id_curs%ISOPEN THEN
 --
 CLOSE get_sim_id_curs;
 --
 END IF;
 --
 END IF;
 --
 IF get_case_det_repl_sim_id_curs%ISOPEN THEN
 --
 CLOSE get_case_det_repl_sim_id_curs;
 --
 END IF;
 -- CR14826 End kacosta 01/07/2010
 -- Added on 05/21/2010 by pmistry to check brand.
 -- IF l_brand = 'STRAIGHT_TALK'
 -- CR20451 | CR20854: Add TELCEL Brand
 IF l_brand_flow = '3' THEN
      BEGIN
        OPEN c_call_tx;
        FETCH c_call_tx
          INTO r_call_tx;
        IF c_call_tx%FOUND THEN
          stmt := 'select a.VALUE_NAME INTO servicenumber';
          OPEN value_def_curs(r_call_tx.call_trans2site_part);
          FETCH value_def_curs
            INTO value_def_rec;
          IF value_def_curs%NOTFOUND THEN
            CLOSE c_call_tx;
            CLOSE value_def_curs;
            RAISE value_def_not_found;
          END IF;
          CLOSE value_def_curs;
          ---------------------------------------------------------------------------------------
          --------------------------------------------------------------------------------------------------------------------
          -- checks if LINE exists is yes then reserves it for port in
          -- if no then creates the LINE and reserves it
         --------------------------------------------------------------------------------------------------------------------
          OPEN min_curs; -- check if the LINE p_min exists in yes: reserve NO: insert and reserve with new esn p_esn
          FETCH min_curs
            INTO min_rec;
          IF min_curs%FOUND THEN
            -- If the requested line is already active to another ESN,
            -- deactivate OLD ESN using a reason that will NOT send an action item (Ported No A/I).
            -- CR14491 STARTS
            OPEN other_site_part_curs(p_esn
                                     ,p_min);
            FETCH other_site_part_curs
              INTO other_site_part_rec;
            IF other_site_part_curs%FOUND THEN
              OPEN other_esn_curs(other_site_part_rec.x_service_id); -- if 3 is true then check phones in pi
              FETCH other_esn_curs
                INTO other_esn_rec;
              IF other_esn_curs%FOUND THEN
                -- call deact Service
                sa.service_deactivation.deactservice(p_sourcesystem
                                                    ,user_rec.case_owner2user
                                                    , -- CR14491
                                                     other_esn_rec.part_serial_no
                                                    ,other_site_part_rec.x_min
                                                    , -- same as p_min
                                                     'PORTED NO A/I'
                                                    ,2
                                                    ,p_esn
                                                    ,'true'
                                                    ,v_returnflag
                                                    ,v_returnmsg);
                IF v_returnflag = 'true' THEN
                  dbms_output.put_line('THE OLD ESN/PHONE IS DEACTIVATED.');
                END IF;
              END IF;
              CLOSE other_esn_curs;
            END IF;
            CLOSE other_site_part_curs;
            -- b) If ESN to receive the line (NEW ESN) is already active,
            --    deactivate it using a reason that will NOT send an action item and unreserved the line
            SELECT COUNT(1)
              INTO is_new_phn_active
              FROM table_part_inst pi
                  ,table_site_part sp
             WHERE pi.part_serial_no = p_esn -- Check if NEW ESN is active
               AND pi.x_part_inst2site_part = sp.objid
               AND UPPER(sp.part_status) = 'ACTIVE'
               AND pi.x_part_inst_status = '52';
            IF is_new_phn_active = 1 THEN
              OPEN get_old_details_cur;
              FETCH get_old_details_cur
                INTO get_old_details_rec;
              OPEN esn_curs;
              FETCH esn_curs
                INTO esn_rec;
              -- call deact Service
              -- 'Deactivating this NEW ALREADY ACTIVE ESN';
              sa.service_deactivation.deactservice(p_sourcesystem
                                                  ,user_rec.case_owner2user
                                                  , -- CR14491
                                                   p_esn
                                                  ,get_old_details_rec.part_serial_no
                                                  ,'PORTED NO A/I'
                                                  ,0
                                                  ,NULL
                                                  ,'false'
                                                  ,v_returnflag
                                                  ,v_returnmsg);
              IF v_returnflag = 'true' THEN
                dbms_output.put_line('THE NEW ESN/PHONE IS DEACTIVATED.');
                -- unreserved the line
                -- 'Clearing all the reserved lines for this NEW ALREADY ACTIVE ESN';
                UPDATE table_part_inst
                   SET part_to_esn2part_inst = NULL
                 WHERE part_to_esn2part_inst = esn_rec.objid
                   AND (x_port_in IS NULL OR x_port_in = 0);
              END IF;
              CLOSE esn_curs;
              CLOSE get_old_details_cur;
            END IF;
            -- CR14491 ENDS
            IF sa.toss_util_pkg.insert_pi_hist_fun(min_rec.part_serial_no
                                                  ,'LINES'
                                                  ,'PORTED NO A/I'
                                                  ,NULL) THEN
              NULL;
            END IF;
            UPDATE table_part_inst
               SET part_inst2carrier_mkt = carrier_rec.objid
                  ,x_part_inst_status    = '73'
                  ,part_inst2x_pers      = carrier_rec.carrier2personality
                  ,status2x_code_table   = 268441728
                  ,part_to_esn2part_inst = esn_rec.objid
                  ,x_msid                = p_msid -- CR14491
                   --CR21051 Start Kacosta 05/31/2012
                  ,n_part_inst2part_mod = CASE
                                            WHEN NVL(n_part_inst2part_mod
                                                    ,0) <> 23070541 THEN
                                             23070541
                                            ELSE
                                             n_part_inst2part_mod
                                          END
            --CR21051 End Kacosta 05/31/2012
             WHERE objid = min_rec.objid;
            is_line_resrvd := is_line_resrvd + SQL%ROWCOUNT;
            -- DBMS_OUTPUT.PUT_LINE ('The LINE already exists - The LINE/MIN is Reserved');
          ELSE
            INSERT INTO table_part_inst
              (objid
              ,part_serial_no
              ,x_msid
              ,part_to_esn2part_inst
              ,part_inst2carrier_mkt
              ,part_inst2x_pers
              ,x_part_inst_status
              ,status2x_code_table
              ,x_port_in
              ,x_npa
              ,x_nxx
              ,x_ext
              ,part_status
              ,x_domain
              ,x_insert_date
              ,x_creation_date
              ,part_good_qty
              ,x_cool_end_date
               --CR21051 Start Kacosta 05/31/2012
              ,n_part_inst2part_mod
               --CR21051 End Kacosta 05/31/2012
              ,warr_end_date)
            VALUES
              (sequ_part_inst.nextval
              ,p_min
              ,p_msid
              ,esn_rec.objid
              ,carrier_rec.objid
              ,carrier_rec.carrier2personality
              ,'73'
              ,268441728
              ,1
              ,SUBSTR(p_min
                     ,1
                     ,3)
              ,SUBSTR(p_min
                     ,4
                     ,3)
              ,SUBSTR(p_min
                     ,7
                     ,4)
              ,'Active'
              ,'LINES'
              ,SYSDATE
              ,SYSDATE
              ,1
              ,TO_DATE('1-jan-1753')
               --CR21051 Start Kacosta 05/31/2012
              ,23070541
               --CR21051 End Kacosta 05/31/2012
              ,'');
            is_line_resrvd := is_line_resrvd + SQL%ROWCOUNT;
            --DBMS_OUTPUT.PUT_LINE ('The LINE is Created  - The LINE/MIN is reserved');
          END IF;
          CLOSE min_curs;
          IF is_line_resrvd = 0 THEN
            p_err_num    := -112;
            p_err_string := 'THE LINE IS NOT RESERVED.PLEASE REVIEW';
			--CR25641 jchacon
            sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'IF is_line_resrvd = 0',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
            --CR25641 jchacon end
            RETURN;
          END IF;
          dbms_output.put_line('The LINE IS RESERVED');
          ---------------------------------------------------------------------------------
          -- CR13249 Start PM 08/16/2011 ST GSM Upgrade.
          IF ESN_REC.X_TECHNOLOGY = 'CDMA' AND  sa.Lte_service_pkg.IS_ESN_LTE_CDMA(p_esn) = 0  THEN  --CR22799
            nap_sim := NULL;
          END IF;
          -- CR13249 End PM 08/16/2011 ST GSM Upgrade.
          -- Perform NAP validations and proceed only if MIN is already attached
          sa.nap_digital(nap_zip
                        ,p_esn
                        ,'NO'
                        ,'English'
                        ,nap_sim
                        ,p_sourcesystem
                        ,'N'
                        ,nap_repl_part
                        ,nap_repl_tech
                        ,nap_sim_profile
                        ,nap_part_serial_no
                        ,nap_message
                        ,nap_pref_parent
                        ,nap_pref_carrid);
          -- SIM PROFILE
          IF nap_message = 'SIM Exchange' THEN
            -- p_due_date := (sysdate + value_def_rec.servicenumber);
            p_err_num    := -109;
            p_err_string := 'SIM PROFILE NOT MATCHING THE ASSIGNED CARRIER';
            --CR25641 jchacon
            sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'IF is_line_resrvd = 0',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
            --CR25641 jchacon end
            RETURN;
          ELSIF nap_message = 'No carrier found for technology.' THEN
            p_err_num    := -110;
            p_err_string := 'PHONE TECHNOLOGY NOT MATCHING THE ASSIGNED CARRIER';
			--CR25641 jchacon
            sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'IF nap_message = No carrier found for technology.',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
            --CR25641 jchacon end
            RETURN;
          ELSIF nap_message = 'F Choice: MIN already attached to ESN.  Please verify.' THEN
            ---------------------------------------------------------------------------------
            -- Passive activation starts
            -- Complete the TX
            stmt := 'update table_x_call_trans';
            UPDATE table_x_call_trans
               SET x_result             = 'Completed'
                  ,x_min                = p_min
                  ,x_iccid              = nap_sim
                  , -- CR14491
                   x_call_trans2carrier = carrier_rec.objid
                   --CR20558 Start kacosta 06/27/2012
                   --, -- CR14491
                   -- x_new_due_date      =
                   -- (SYSDATE + NVL(rec_pb_case_dtl.x_value
                   --               ,value_def_rec.servicenumber)) -- CR14484 PM AWOP Change
                  ,x_new_due_date = (CASE
                                      WHEN UPPER(TRIM(p_port_type)) = 'EXTERNAL' THEN
                                       TRUNC(SYSDATE + NVL(rec_pb_case_dtl.x_value
                                                          ,value_def_rec.servicenumber))
                                      ELSE
                                       CASE
                                         WHEN TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                                ,value_def_rec.servicenumber)) < TRUNC(SYSDATE) THEN
                                          TRUNC(SYSDATE)
                                         ELSE
                                          TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                            ,value_def_rec.servicenumber))
                                       END
                                    END)
            --CR20558 End kacosta 06/27/2012
             WHERE objid = r_call_tx.objid;
            OPEN chk_st_gsm_cur(p_esn);
            FETCH chk_st_gsm_cur
              INTO rec_chk_st_gsm;
            IF chk_st_gsm_cur%FOUND THEN
              IF rec_chk_st_gsm.x_param_value != 0 THEN
                -- 0 ST GSM Skip Update SwB Tx
                -- Complete SwB Tx
                stmt := 'x_switchbased_transaction';
                UPDATE x_switchbased_transaction
                   SET status = 'Completed'
                       --CR20558 Start kacosta 06/27/2012
                       --,exp_date =
                       -- (SYSDATE + NVL(rec_pb_case_dtl.x_value
                       --               ,value_def_rec.servicenumber)) -- CR14484 PM AWOP Change
                      ,exp_date = (CASE
                                    WHEN UPPER(TRIM(p_port_type)) = 'EXTERNAL' THEN
                                     TRUNC(SYSDATE + NVL(rec_pb_case_dtl.x_value
                                                        ,value_def_rec.servicenumber))
                                    ELSE
                                     CASE
                                       WHEN TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                              ,value_def_rec.servicenumber)) < TRUNC(SYSDATE) THEN
                                        TRUNC(SYSDATE)
                                       ELSE
                                        TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                          ,value_def_rec.servicenumber))
                                     END
                                  END)
                --CR20558 End kacosta 06/27/2012
                 WHERE x_sb_trans2x_call_trans = r_call_tx.objid;
              END IF;
            END IF;
            CLOSE chk_st_gsm_cur;
            -- CR13531 STCC PM start on 09/10/2010.
            FOR r_part_inst IN c_part_inst LOOP
              --IF c_part_inst%found
              --THEN
              stmt := 'delete from  table_part_inst';
              DELETE FROM table_part_inst
               WHERE part_serial_no LIKE 'T%'
                 AND part_to_esn2part_inst = r_part_inst.objid
                 AND x_domain = 'LINES';
              stmt := 'update table_part_inst';
              -- UPDATE LINE in PART INST
              IF p_min = r_part_inst.line_part_serial_no THEN
                -- Line Updation.
                UPDATE table_part_inst
                   SET x_part_inst_status  = '13'
                      , -- ACTIVE
                       status2x_code_table = 960
                       --CR20558 Start kacosta 06/27/2012
                       --,warr_end_date      =
                       -- (SYSDATE + NVL(rec_pb_case_dtl.x_value
                       --               ,value_def_rec.servicenumber))
                      ,warr_end_date = (CASE
                                         WHEN UPPER(TRIM(p_port_type)) = 'EXTERNAL' THEN
                                          TRUNC(SYSDATE + NVL(rec_pb_case_dtl.x_value
                                                             ,value_def_rec.servicenumber))
                                         ELSE
                                          CASE
                                            WHEN TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                                   ,value_def_rec.servicenumber)) < TRUNC(SYSDATE) THEN
                                             TRUNC(SYSDATE)
                                            ELSE
                                             TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                               ,value_def_rec.servicenumber))
                                          END
                                       END)
                       --CR20558 End kacosta 06/27/2012
                      , -- CR14484 PM AWOP Change
                       part_serial_no = p_min
                      , --x_msid = p_min, --CR11061
                       x_msid         = NVL(p_msid
                                           ,x_msid)
                      , --ST_BUNDLE_II--x_msid = p_min, --CR11061
                       x_port_in      = DECODE(UPPER(TRIM(p_port_type))
                                              ,'EXTERNAL'
                                              ,1
                                              ,'INTERNAL'
                                              ,2)
                       --CR21051 Start Kacosta 05/31/2012
                      ,n_part_inst2part_mod = CASE
                                                WHEN NVL(n_part_inst2part_mod
                                                        ,0) <> 23070541 THEN
                                                 23070541
                                                ELSE
                                                 n_part_inst2part_mod
                                              END
                --CR21051 End Kacosta 05/31/2012
                 WHERE objid = r_part_inst.line_objid
                   AND part_to_esn2part_inst = r_part_inst.objid
                   AND x_domain = 'LINES';
                -- ESN Updation
                UPDATE table_part_inst
                --CR20558 Start kacosta 06/27/2012
                --SET warr_end_date     =
                --    (SYSDATE + NVL(rec_pb_case_dtl.x_value
                --                  ,value_def_rec.servicenumber))
                   SET warr_end_date = (CASE
                                         WHEN UPPER(TRIM(p_port_type)) = 'EXTERNAL' THEN
                                          TRUNC(SYSDATE + NVL(rec_pb_case_dtl.x_value
                                                             ,value_def_rec.servicenumber))
                                         ELSE
                                          CASE
                                            WHEN TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                                   ,value_def_rec.servicenumber)) < TRUNC(SYSDATE) THEN
                                             TRUNC(SYSDATE)
                                            ELSE
                                             TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                               ,value_def_rec.servicenumber))
                                          END
                                       END)
                       --CR20558 End kacosta 06/27/2012
                      , -- CR14484 PM AWOP Change
                       x_part_inst_status = '52'
                      ,last_trans_time    = SYSDATE -- CR17793
                       --(SYSDATE + NVL(rec_pb_case_dtl.x_value
                       --              ,value_def_rec.servicenumber))
                      , -- CR14484 PM AWOP Change
                       status2x_code_table = 988
                      ,x_iccid             = nap_sim
                      , -- CR14491
                       x_port_in           = 0 --2 STUL
                 WHERE part_serial_no = p_esn
                   AND x_domain = 'PHONES';
                --CR11061
                -- SITE PART
                stmt := 'update table_site_part';
                --ST_BUNDLE_II
                UPDATE table_site_part
                   SET part_status = 'Active'
                      ,x_min       = p_min
                      ,x_msid      = NVL(p_msid
                                        ,r_part_inst.x_msid)
                      ,x_iccid     = nap_sim
                      , -- CR14491
                       x_zipcode   = nap_zip
                       --CR20558 Start kacosta 06/27/2012
                       --, -- CR14491
                       -- x_expire_dt =
                       -- (SYSDATE + NVL(rec_pb_case_dtl.x_value
                       --               ,value_def_rec.servicenumber)) -- CR14484 PM AWOP Change
                      ,x_expire_dt = (CASE
                                       WHEN UPPER(TRIM(p_port_type)) = 'EXTERNAL' THEN
                                        TRUNC(SYSDATE + NVL(rec_pb_case_dtl.x_value
                                                           ,value_def_rec.servicenumber))
                                       ELSE
                                        CASE
                                          WHEN TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                                 ,value_def_rec.servicenumber)) < TRUNC(SYSDATE) THEN
                                           TRUNC(SYSDATE)
                                          ELSE
                                           TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                             ,value_def_rec.servicenumber))
                                        END
                                     END)
                      ,warranty_date = (CASE
                                         WHEN UPPER(TRIM(p_port_type)) = 'EXTERNAL' THEN
                                          TRUNC(SYSDATE + NVL(rec_pb_case_dtl.x_value
                                                             ,value_def_rec.servicenumber))
                                         ELSE
                                          CASE
                                            WHEN TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                                   ,value_def_rec.servicenumber)) < TRUNC(SYSDATE) THEN
                                             TRUNC(SYSDATE)
                                            ELSE
                                             TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                               ,value_def_rec.servicenumber))
                                          END
                                       END)
                --CR20558 End kacosta 06/27/2012
                 WHERE objid = r_call_tx.call_trans2site_part;
                --ST_BUNDLE_II CR11061
                --
                --CR21060 Start kacosta 06/05/2012
                IF (nap_sim IS NOT NULL) THEN
                  --
                  UPDATE table_x_sim_inv xsi
                     SET x_last_update_date        = SYSDATE
                        ,x_sim_inv_status          = '254'
                        ,x_sim_status2x_code_table = 268438607
                   WHERE xsi.x_sim_serial_no = nap_sim
                     AND xsi.x_sim_inv_status IN ('251'
                                                 ,'253')
                     AND EXISTS (SELECT 1
                            FROM table_part_inst tpi
                            JOIN table_site_part tsp
                              ON tpi.part_serial_no = tsp.x_service_id
                           WHERE tpi.x_iccid = xsi.x_sim_serial_no
                             AND tpi.part_serial_no = p_esn
                             AND tpi.x_domain = 'PHONES'
                             AND tpi.x_part_inst_status = '52'
                             AND tsp.objid = r_call_tx.call_trans2site_part
                             AND tsp.part_status = 'Active'
                             AND tsp.x_iccid = xsi.x_sim_serial_no);
                  --
                END IF;
                --CR21060 End kacosta 06/05/2012
                --
              ELSE
                UPDATE table_part_inst
                   SET x_part_inst_status  = '17'
                      , -- RETURNED
                       status2x_code_table = 963
                       --WARR_END_DATE = (SYSDATE + value_def_rec.servicenumber ),
                       --part_serial_no = p_min,
                       --X_MSID = nvl(P_MSID, x_msid), --ST_BUNDLE_II--x_msid = p_min, --CR11061
                       --x_port_in = DECODE(UPPER(TRIM(p_port_type)),'EXTERNAL',1,'INTERNAL',2)
                       --CR21051 Start Kacosta 05/31/2012
                      ,n_part_inst2part_mod = CASE
                                                WHEN NVL(n_part_inst2part_mod
                                                        ,0) <> 23070541 THEN
                                                 23070541
                                                ELSE
                                                 n_part_inst2part_mod
                                              END
                --CR21051 End Kacosta 05/31/2012
                 WHERE objid = r_part_inst.line_objid
                   AND part_to_esn2part_inst = r_part_inst.objid
                   AND x_domain = 'LINES';
              END IF;
            END LOOP;
            -- CR13531 STCC PM end on 09/10/2010.
            --
            --CR22152 Start Kacosta 10/15/2012
            BEGIN
              --
              IF get_case_old_esn_curs%ISOPEN THEN
                --
                CLOSE get_case_old_esn_curs;
                --
              END IF;
              --
              OPEN get_case_old_esn_curs(c_n_case_objid => case_rec.objid
                                        ,c_v_new_esn    => p_esn);
              FETCH get_case_old_esn_curs
                INTO get_case_old_esn_rec;
              CLOSE get_case_old_esn_curs;
              --
              IF (get_case_old_esn_rec.old_esn IS NOT NULL) THEN
                --
                l_v_old_esn := get_case_old_esn_rec.old_esn;
                --
              ELSE
                --
                l_v_old_esn := case_rec.x_esn;
                --
              END IF;
              --
              --CR22660 Start kacosta 11/16/2012
              --enroll_promo_pkg.sp_get_eligible_promo_esn2(p_esn         => l_v_old_esn
              enroll_promo_pkg.sp_get_eligible_promo_esn(p_esn => l_v_old_esn
                                                         --CR22660 End kacosta 11/16/2012
                                                         ,p_promo_objid => l_n_promo_objid
                                                         ,p_promo_code  => l_v_promo_code
                                                         ,p_script_id   => l_v_script_id
                                                         ,p_error_code  => l_n_error_code
                                                         ,p_error_msg   => l_v_error_message);
              --
              --CR22660 Start kacosta 11/16/2012
              --IF (l_n_error_code <> 0) THEN
              IF (l_n_error_code NOT IN (0
                                        ,306)) THEN
                --CR22660 End kacosta 11/16/2012
                --
                l_v_error_message := 'Calling enroll_promo_pkg.sp_get_eligible_promo_esn error message: ' || l_v_error_message;
                --
                RAISE l_exc_transfer_promo_enrollmnt;
                --
              END IF;
              --
              IF (l_n_promo_objid IS NOT NULL) THEN
                --
                enroll_promo_pkg.sp_transfer_promo_enrollment(p_case_objid => case_rec.objid
                                                             ,p_new_esn    => p_esn
                                                             ,p_error_code => l_n_error_code
                                                             ,p_error_msg  => l_v_error_message);
                --
                IF (l_n_error_code <> 0) THEN
                  --
                  l_v_error_message := 'Calling enroll_promo_pkg.sp_transfer_promo_enrollment error message: ' || l_v_error_message;
                  --
                  RAISE l_exc_transfer_promo_enrollmnt;
                  --
                END IF;
                --
              END IF;
              --
            EXCEPTION
              WHEN l_exc_transfer_promo_enrollmnt THEN
                --
                ota_util_pkg.err_log(p_action       => 'Calling enroll_promo_pkg for case objid: ' || TO_CHAR(case_rec.objid) || ' new esn: ' || p_esn
                                    ,p_error_date   => SYSDATE
                                    ,p_key          => p_esn
                                    ,p_program_name => 'SA.port_pkg.complete_port'  -- C29916
                                    ,p_error_text   => 'Error code: ' || TO_CHAR(l_n_error_code) || ' Error message: ' || l_v_error_message);
                --
              WHEN others THEN
                --
                ota_util_pkg.err_log(p_action       => 'Determining to transfer promo enrollment for case objid: ' || TO_CHAR(case_rec.objid) || ' new esn: ' || p_esn
                                    ,p_error_date   => SYSDATE
                                    ,p_key          => p_esn
                                    ,p_program_name => 'port_pkg.complete_port'
                                    ,p_error_text   => 'Error code: ' || TO_CHAR(SQLCODE) || ' Error message: ' || SQLERRM);
                --
            END;
            --CR22152 End Kacosta 10/15/2012
            --
            COMMIT;
            -- Passive activation Ends
            ------------------------------------------------------------------------------------
            -- close the case
            --cwl 10/8/12
            BEGIN
              SELECT 1
                INTO case_is_locked
                FROM table_case
               WHERE id_number = p_case_id
                 FOR UPDATE NOWAIT;
              UPDATE table_case
                 SET oper_system      = 'Port Successful'
                    ,x_iccid          = nap_sim
                    , -- CR14491
                     x_activation_zip = nap_zip -- CR14491
               WHERE id_number = p_case_id;
              COMMIT;
            EXCEPTION
              WHEN others THEN
                ROLLBACK;
                p_err_num    := -501;
                p_err_string := 'Case is locked by other user';
				--CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'SELECT 1 INTO case_is_locked',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
                --CR25641 jchacon end
                RETURN;
            END;
            --cwl 10/8/12
            -- close the case
            sa.clarify_case_pkg.close_case(case_rec.objid
                                          ,user_rec.case_owner2user
                                          , -- CR14491
                                           p_sourcesystem
                                          ,NULL
                                          ,NULL
                                          ,l_error_no
                                          ,l_error_str);
            COMMIT; --CR22113 Fix Locking Issue on Table Case
            IF l_error_no != '0' THEN
              p_err_num    := l_error_no;
              p_err_string := l_error_str;
			--CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'If clarify_case_pkg.close_case != 0 (not successful).',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
            --CR25641 jchacon end
              RETURN;
            END IF;
            --CR20558 Start kacosta 06/27/2012
            --p_due_date   := (SYSDATE + NVL(rec_pb_case_dtl.x_value
            --                              ,value_def_rec.servicenumber)); -- CR14484 PM AWOP Change
            p_due_date := (CASE
                            WHEN UPPER(TRIM(p_port_type)) = 'EXTERNAL' THEN
                             TRUNC(SYSDATE + NVL(rec_pb_case_dtl.x_value
                                                ,value_def_rec.servicenumber))
                            ELSE
                             CASE
                               WHEN TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                      ,value_def_rec.servicenumber)) < TRUNC(SYSDATE) THEN
                                TRUNC(SYSDATE)
                               ELSE
                                TRUNC(case_rec.creation_time + NVL(rec_pb_case_dtl.x_value
                                                                  ,value_def_rec.servicenumber))
                             END
                          END);
            --CR20558 End kacosta 06/27/2012
            p_err_num    := 0;
            p_err_string := 'Success';
          ELSE
            -- any other NAP message
            p_err_num    := -113;
            p_err_string := nap_message;
            dbms_output.put_line('COMPLETE PORT PROCEDURE FAILED FOR THIS VALIDATION - ' || nap_message);
			--CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'IF nap_message != SIM Exchange',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
            --CR25641 jchacon end
            RETURN;
          END IF;
          CLOSE c_call_tx;
        END IF;
        ----------------------------
      EXCEPTION
        WHEN too_many_lines THEN
          p_err_num    := -111;
          p_err_string := 'More than two lines found.';
		  --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'EXCEPTION WHEN too_many_lines',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
            --CR25641 jchacon end
         ROLLBACK;
        WHEN value_def_not_found THEN
          p_err_num    := -111;
          p_err_string := 'No value def found.';
		  --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'EXCEPTION WHEN value_def_not_found',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
            --CR25641 jchacon end
          ROLLBACK;
        WHEN others THEN
          ROLLBACK;
          p_due_date   := NULL;
          p_err_num    := SQLCODE;
          p_err_string := SQLERRM || ':::Location:' || stmt;
		  --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'EXCEPTION WHEN others',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
          --CR25641 jchacon end
      END;
    ELSIF
    --For Combining code for TF/TN with ST. For TF/TN.
    --CR20451 | CR20854: Add TELCEL Brand
    --l_brand NOT IN ('STRAIGHT_TALK') THEN
     l_brand_flow <> '3' THEN
      BEGIN
        --------------------------------------------------------------------------------------------------------------------
        l_step := '1'; -- checks ESN is active with receiving line or with different,
        -- line already reserved? then un-reserves
        -- deactivates the Phone
        --------------------------------------------------------------------------------------------------------------------
        FOR old_site_part_rec IN old_site_part_curs LOOP
          -- 1 to check active for p_esn
          OPEN old_min_curs(old_site_part_rec.x_min); -- 2 to check line from active esn in sp mostly line is 13, active in pi
          FETCH old_min_curs
            INTO old_min_rec;
          IF old_min_curs%FOUND THEN
            OPEN other_site_part_curs(p_esn
                                     ,old_site_part_rec.x_min); -- 3 checking if this min is active with any other esns in SP
            FETCH other_site_part_curs
              INTO other_site_part_rec;
            IF other_site_part_curs%FOUND THEN
              OPEN other_esn_curs(other_site_part_rec.x_service_id); -- if 3 is true then check phones in pi
              FETCH other_esn_curs
                INTO other_esn_rec;
              IF other_esn_curs%FOUND THEN
                UPDATE table_part_inst --assign the other esn to the right min from 3
                   SET part_to_esn2part_inst = other_esn_rec.objid
                       --CR21051 Start Kacosta 05/31/2012
                      ,n_part_inst2part_mod = CASE
                                                WHEN NVL(n_part_inst2part_mod
                                                        ,0) <> 23070541 THEN
                                                 23070541
                                                ELSE
                                                 n_part_inst2part_mod
                                              END
                --CR21051 End Kacosta 05/31/2012
                 WHERE objid = old_min_rec.objid;
              END IF;
              CLOSE other_esn_curs;
            ELSE
              IF old_min_rec.part_serial_no LIKE 'T%' THEN
                --
                DELETE FROM table_part_inst
                 WHERE objid = old_min_rec.objid;
              ELSE
                IF sa.toss_util_pkg.insert_pi_hist_fun(old_min_rec.part_serial_no
                                                      ,'LINES'
                                                      ,'PORTED NO A/I'
                                                      ,NULL) THEN
                  NULL;
                END IF;
                /*  update table_part_inst                       -- 12 - USED 17 - RETURNED
                set part_to_esn2part_inst = null
                where   1 =1
                and objid = old_min_rec.objid;
                */
                NULL;
              END IF;
            END IF;
            CLOSE other_site_part_curs;
          END IF;
          CLOSE old_min_curs;
          /* will be deactivating using SDC
          update table_site_part
          set part_status = 'Inactive'
          where objid = old_site_part_rec.objid;                  -- from comment 1
          INSERT INTO table_x_call_trans
          (objid, call_trans2site_part,
          x_action_type, x_call_trans2carrier,
          x_call_trans2dealer, x_call_trans2user, x_min,
          x_service_id, x_sourcesystem, x_transact_date,
          x_total_units, x_action_text, x_reason,
          x_result, x_sub_sourcesystem, x_iccid,     -- 07/07/2004 GP
          x_ota_req_type, x_ota_type
          )
          VALUES (SEQU_X_CALL_TRANS.nextval, old_site_part_rec.objid,
          '2', old_min_rec.part_inst2carrier_mkt,
          esn_rec.dealer_objid, user_rec.objid, old_site_part_rec.x_min,
          p_esn, p_sourcesystem, SYSDATE,
          null, 'DEACTIVATION', 'PORTED NO A/I',
          'Completed', null, esn_rec.x_iccid,
          null, null
          );
          */
        END LOOP;
        --------------------------------------------------------------------------------------------------------------------
        l_step := '2';
        --------------------------------------------------------------------------------------------------------------------
        FOR orphan_min_rec IN orphan_min_curs(esn_rec.objid) LOOP
          -- p_esn PHONES in Pi and != p_min
          -- ex: esn was used status so it will will have lines(it may also be t-num)
          OPEN other_site_part_curs(p_esn
                                   ,orphan_min_rec.part_serial_no);
          FETCH other_site_part_curs
            INTO other_site_part_rec;
          IF other_site_part_curs%FOUND THEN
            -- those lines may not be in sp
            OPEN other_esn_curs(other_site_part_rec.x_service_id);
            FETCH other_esn_curs
              INTO other_esn_rec;
            IF other_esn_curs%FOUND THEN
              UPDATE table_part_inst
                 SET part_to_esn2part_inst = other_esn_rec.objid
                     --CR21051 Start Kacosta 05/31/2012
                    ,n_part_inst2part_mod = CASE
                                              WHEN NVL(n_part_inst2part_mod
                                                      ,0) <> 23070541 THEN
                                               23070541
                                              ELSE
                                               n_part_inst2part_mod
                                            END
              --CR21051 End Kacosta 05/31/2012
               WHERE objid = orphan_min_rec.objid;
            END IF;
            CLOSE other_esn_curs;
          ELSE
            IF old_min_rec.part_serial_no LIKE 'T%'
               AND orphan_min_rec.x_domain = 'LINES' THEN
              DELETE FROM table_part_inst
               WHERE objid = orphan_min_rec.objid;
            ELSE
              IF sa.toss_util_pkg.insert_pi_hist_fun(orphan_min_rec.part_serial_no
                                                    ,'LINES'
                                                    ,'PORTED NO A/I'
                                                    ,NULL) THEN
                NULL;
              END IF;
              /*
             open old_min_curs(orphan_min_rec.part_serial_no);
              fetch old_min_curs into old_min_rec;
              if old_min_curs%found then
              update table_part_inst
              set part_to_esn2part_inst = null
              where 1=1
              and objid = orphan_min_rec.objid;
              NULL;
              end if;
              close old_min_curs;
              */
            END IF;
          END IF;
          CLOSE other_site_part_curs;
        END LOOP;
        --------------------------------------------------------------------------------------------------------------------
        l_step := '3'; -- CHECK to see if OLD, NEW ESNS are active if ye sdeactivate both of them
        -- And the min is reserved for the new esn later on in the same proc itself
        --------------------------------------------------------------------------------------------------------------------
        -- get old min from pi for the current esn
        OPEN get_old_details_cur;
        FETCH get_old_details_cur
          INTO get_old_details_rec;
        dbms_output.put_line('MIN - ' || get_old_details_rec.part_serial_no);
        OPEN get_curr_esn_cur; -- get old/existing ESN/PHONE
        FETCH get_curr_esn_cur
          INTO get_curr_esn_rec;
        OPEN get_curr_min_cur; -- get old/existing MIN/LINE
        FETCH get_curr_min_cur
          INTO get_curr_min_rec;
        SELECT COUNT(1)
          INTO is_old_phn_active
          FROM table_part_inst pi
              ,table_site_part sp
         WHERE pi.part_serial_no = get_curr_esn_rec.x_value -- Check if old ESN is active
           AND pi.x_part_inst2site_part = sp.objid
           AND UPPER(sp.part_status) = 'ACTIVE'
           AND pi.x_part_inst_status = '52';
        IF is_old_phn_active = 1 THEN
          -- call deact Service
          sa.service_deactivation.deactservice(p_sourcesystem
                                              ,user_rec.case_owner2user
                                              , -- CR14491
                                               get_curr_esn_rec.x_value
                                              ,get_curr_min_rec.x_value
                                              ,'PORTED NO A/I'
                                              ,2
                                              ,p_esn
                                              ,'true'
                                              ,v_returnflag
                                              ,v_returnmsg);
          IF v_returnflag = 'true' THEN
            dbms_output.put_line('THE OLD ESN/PHONE IS DEACTIVATED.');
          END IF;
        END IF;
        -- New ESN
        SELECT COUNT(1)
          INTO is_new_phn_active
          FROM table_part_inst pi
              ,table_site_part sp
         WHERE pi.part_serial_no = p_esn -- Check if NEW ESN is active
           AND pi.x_part_inst2site_part = sp.objid
           AND UPPER(sp.part_status) = 'ACTIVE'
           AND pi.x_part_inst_status = '52';
        IF is_new_phn_active = 1 THEN
          -- call deact Service
          sa.service_deactivation.deactservice(p_sourcesystem
                                              ,user_rec.case_owner2user
                                              , -- CR14491
                                               p_esn
                                              ,get_old_details_rec.part_serial_no
                                              ,'ACTIVE UPGRADE'
                                              ,0
                                              ,NULL
                                              ,'false'
                                              ,v_returnflag
                                              ,v_returnmsg);
          IF v_returnflag = 'true' THEN
            dbms_output.put_line('THE NEW ESN/PHONE IS DEACTIVATED.');
          END IF;
        END IF;
        CLOSE get_curr_min_cur;
        CLOSE get_curr_esn_cur;
        CLOSE get_old_details_cur;
        --------------------------------------------------------------------------------------------------------------------
        l_step := '4'; -- changing the status of old line to USED, RETURNED
        -- need to do this after SDC not before
        --------------------------------------------------------------------------------------------------------------------
        FOR old_min_new_esn_rec IN old_min_new_esn_curs LOOP
          OPEN old_min_curs(old_min_new_esn_rec.x_min);
          FETCH old_min_curs
            INTO old_min_rec;
          IF old_min_curs%FOUND THEN
            UPDATE table_part_inst -- 12 - USED 17 - RETURNED
               SET part_to_esn2part_inst = NULL
                  ,x_part_inst_status = (CASE
                                          WHEN old_min_rec.x_line_return_days < 1 THEN
                                           '12'
                                          ELSE
                                           '17'
                                        END)
                   --CR21051 Start Kacosta 05/31/2012
                  ,n_part_inst2part_mod = CASE
                                            WHEN NVL(n_part_inst2part_mod
                                                    ,0) <> 23070541 THEN
                                             23070541
                                            ELSE
                                             n_part_inst2part_mod
                                          END
            --CR21051 End Kacosta 05/31/2012
             WHERE 1 = 1
               AND objid = old_min_rec.objid;
          END IF;
          CLOSE old_min_curs;
        END LOOP;
        FOR orphan_min_rec IN orphan_min_curs(esn_rec.objid) LOOP
          OPEN old_min_curs(orphan_min_rec.part_serial_no);
          FETCH old_min_curs
            INTO old_min_rec;
          IF old_min_curs%FOUND THEN
            UPDATE table_part_inst
               SET part_to_esn2part_inst = NULL
                  , -- 12 - USED  17 - RETURNED
                   x_part_inst_status = (CASE
                                          WHEN old_min_rec.x_line_return_days < 1 THEN
                                           '12'
                                          ELSE
                                           '17'
                                        END)
                   --CR21051 Start Kacosta 05/31/2012
                  ,n_part_inst2part_mod = CASE
                                            WHEN NVL(n_part_inst2part_mod
                                                    ,0) <> 23070541 THEN
                                             23070541
                                            ELSE
                                             n_part_inst2part_mod
                                          END
            --CR21051 End Kacosta 05/31/2012
             WHERE 1 = 1
               AND objid = orphan_min_rec.objid;
          END IF;
          CLOSE old_min_curs;
        END LOOP;
        --------------------------------------------------------------------------------------------------------------------
        l_step := '5'; -- checks if LINE exists is yes then reserves it for port in
        -- if no then creates the LINE and reserves it
        --------------------------------------------------------------------------------------------------------------------
        OPEN min_curs; -- check if the LINE p_min exists in yes: reserve NO: insert and reserve with new esn p_esn
        FETCH min_curs
          INTO min_rec;
        IF min_curs%FOUND THEN
          --
          -- CR14826 Start kacosta 11/30/2010
          IF other_site_part_curs%ISOPEN THEN
            --
            CLOSE other_site_part_curs;
            --
          END IF;
          --
          OPEN other_site_part_curs(p_esn
                                   ,p_min);
          FETCH other_site_part_curs
            INTO other_site_part_rec;
          --
          IF other_site_part_curs%FOUND THEN
            --
            IF other_esn_curs%ISOPEN THEN
              --
              CLOSE other_esn_curs;
              --
            END IF;
            --
            OPEN other_esn_curs(other_site_part_rec.x_service_id);
            FETCH other_esn_curs
              INTO other_esn_rec;
            --
            IF other_esn_curs%FOUND THEN
              --
              --cwl 11/2/12 remove linefeed from following call
              service_deactivation.deactservice(ip_sourcesystem    => p_sourcesystem
                                               ,ip_userobjid       => user_rec.case_owner2user
                                               ,ip_esn             => other_esn_rec.part_serial_no
                                               ,ip_min             => other_site_part_rec.x_min
                                               ,ip_deactreason     => 'PORTED NO A/I'
                                               , --CR# is 22510
                                                intbypassordertype => 2
                                               ,ip_newesn          => p_esn
                                               ,ip_samemin         => 'true'
                                               ,op_return          => v_returnflag
                                               ,op_returnmsg       => v_returnmsg);

            END IF;
            --
            CLOSE other_esn_curs;
            --
          END IF;
          --
          CLOSE other_site_part_curs;
          --
          FOR rec_is_new_phn_active IN (SELECT 1
                                          FROM dual
                                         WHERE 'X' IN (SELECT 'X'
                                                         FROM table_site_part tsp
                                                             ,table_part_inst tpi
                                                        WHERE tpi.part_serial_no = p_esn
                                                          AND tpi.x_part_inst_status = '52'
                                                          AND tpi.x_part_inst2site_part = tsp.objid
                                                          AND UPPER(tsp.part_status) = 'ACTIVE')) LOOP
            --
            IF get_old_details_cur%ISOPEN THEN
              --
              CLOSE get_old_details_cur;
              --
            END IF;
            --
            OPEN get_old_details_cur;
            FETCH get_old_details_cur
              INTO get_old_details_rec;
            --
            IF esn_curs%ISOPEN THEN
              --
              CLOSE esn_curs;
              --
            END IF;
            --
            OPEN esn_curs;
            FETCH esn_curs
              INTO esn_rec;
            --
            service_deactivation.deactservice(ip_sourcesystem    => p_sourcesystem
                                             ,ip_userobjid       => user_rec.case_owner2user
                                             ,ip_esn             => p_esn
                                             ,ip_min             => get_old_details_rec.part_serial_no
                                             ,ip_deactreason     => 'PORTED NO A/I'
                                             ,intbypassordertype => 0
                                             ,ip_newesn          => NULL
                                             ,ip_samemin         => 'false'
                                             ,op_return          => v_returnflag
                                             ,op_returnmsg       => v_returnmsg);

            --
            IF v_returnflag = 'true' THEN
              --
              UPDATE table_part_inst
                 SET part_to_esn2part_inst = NULL
               WHERE part_to_esn2part_inst = esn_rec.objid
                 AND (x_port_in IS NULL OR x_port_in = 0);
              --
            END IF;
            --
            CLOSE esn_curs;
            CLOSE get_old_details_cur;
            --
          END LOOP;
          -- CR14826 End kacosta 11/30/2010
          --
          IF sa.toss_util_pkg.insert_pi_hist_fun(min_rec.part_serial_no
                                                ,'LINES'
                                                ,'PORTED NO A/I'
                                                ,NULL) THEN
            NULL;
          END IF;
          UPDATE table_part_inst
             SET part_inst2carrier_mkt = carrier_rec.objid
                ,x_part_inst_status    = '73'
                ,part_inst2x_pers      = carrier_rec.carrier2personality
                ,status2x_code_table   = 268441728
                ,part_to_esn2part_inst = esn_rec.objid
                 -- CR14826 Start kacosta 11/30/2010
                ,x_msid = p_msid
                 -- CR14826 End kacosta 11/30/2010
                 --CR21051 Start Kacosta 05/31/2012
                ,n_part_inst2part_mod = CASE
                                          WHEN NVL(n_part_inst2part_mod
                                                  ,0) <> 23070541 THEN
                                           23070541
                                          ELSE
                                           n_part_inst2part_mod
                                        END
          --CR21051 End Kacosta 05/31/2012
           WHERE objid = min_rec.objid;
          is_line_resrvd := is_line_resrvd + SQL%ROWCOUNT;
          -- DBMS_OUTPUT.PUT_LINE ('The LINE already exists - The LINE/MIN is Reserved');
        ELSE
          INSERT INTO table_part_inst
            (objid
            ,part_serial_no
            ,x_msid
            ,part_to_esn2part_inst
            ,part_inst2carrier_mkt
            ,part_inst2x_pers
            ,x_part_inst_status
            ,status2x_code_table
            ,x_port_in
           ,x_npa
            ,x_nxx
            ,x_ext
            ,part_status
            ,x_domain
            ,x_insert_date
            ,x_creation_date
            ,part_good_qty
            ,x_cool_end_date
             --CR21051 Start Kacosta 05/31/2012
            ,n_part_inst2part_mod
             --CR21051 End Kacosta 05/31/2012
            ,warr_end_date)
          VALUES
            (sequ_part_inst.nextval
            ,p_min
            ,p_msid
            ,esn_rec.objid
            ,carrier_rec.objid
            ,carrier_rec.carrier2personality
            ,'73'
            ,268441728
            ,1
            ,SUBSTR(p_min
                   ,1
                   ,3)
            ,SUBSTR(p_min
                   ,4
                   ,3)
            ,SUBSTR(p_min
                   ,7
                   ,4)
            ,'Active'
            ,'LINES'
            ,SYSDATE
            ,SYSDATE
            ,1
            ,TO_DATE('1-jan-1753')
             --CR21051 Start Kacosta 05/31/2012
            ,23070541
             --CR21051 End Kacosta 05/31/2012
            ,'');
          is_line_resrvd := is_line_resrvd + SQL%ROWCOUNT;
          --DBMS_OUTPUT.PUT_LINE ('The LINE is Created  - The LINE/MIN is reserved');
        END IF;
        CLOSE min_curs;
        COMMIT; --CR22113 Fix Locking Issue on Table Case
        IF is_line_resrvd = 0 THEN
          p_err_num    := -112;
          p_err_string := 'THE LINE IS NOT RESERVED.PLEASE REVIEW';
		   --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'INSERT INTO table_part_inst',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
          --CR25641 jchacon end
          RETURN;
        END IF;
        dbms_output.put_line('The LINE IS RESERVED');
        --------------------------------------------------------------------------------------------------------------------
        l_step := '6';
        --------------------------------------------------------------------------------------------------------------------
        -- Updates X_PORT_IN flags of LINES and Clear it for PHONES
        --p_port_type := l_port_type;
        IF UPPER(TRIM(p_port_type)) = 'INTERNAL' THEN
          UPDATE table_part_inst
             SET x_port_in = 2
                 --CR21051 Start Kacosta 05/31/2012
                ,n_part_inst2part_mod = CASE
                                          WHEN NVL(n_part_inst2part_mod
                                                  ,0) <> 23070541 THEN
                                           23070541
                                          ELSE
                                           n_part_inst2part_mod
                                        END
          --CR21051 End Kacosta 05/31/2012
           WHERE part_to_esn2part_inst = esn_rec.objid
             AND x_domain = 'LINES';
        ELSIF UPPER(TRIM(p_port_type)) = 'EXTERNAL' THEN
          UPDATE table_part_inst
             SET x_port_in = 1
                 --CR21051 Start Kacosta 05/31/2012
                ,n_part_inst2part_mod = CASE
                                          WHEN NVL(n_part_inst2part_mod
                                                  ,0) <> 23070541 THEN
                                           23070541
                                          ELSE
                                           n_part_inst2part_mod
                                        END
          --CR21051 End Kacosta 05/31/2012
           WHERE part_to_esn2part_inst = esn_rec.objid
             AND x_domain = 'LINES';
        END IF;
        -- For PHONES x_port_in flag = 0 -- UPDATE PHONE in PART INST
        UPDATE table_part_inst
           SET x_port_in = 0
         WHERE part_serial_no = p_esn
           AND x_domain = 'PHONES';
        --------------------------------------------------------------------------------------------------------------------
        l_step := '7'; -- NAP validations
        --------------------------------------------------------------------------------------------------------------------
        -- CR13249 Start PM 08/16/2011 ST GSM Upgrade.
        IF esn_rec.x_technology = 'CDMA' AND  sa.Lte_service_pkg.IS_ESN_LTE_CDMA(p_esn) = 0 THEN
          nap_sim := NULL;
        END IF;
        -- CR13249 End PM 08/16/2011 ST GSM Upgrade.
        -- Calling NAP
        sa.nap_digital(nap_zip
                      ,p_esn
                      ,'NO'
                      ,'English'
                      ,nap_sim
                      ,p_sourcesystem
                      ,'N'
                      ,nap_repl_part
                      ,nap_repl_tech
                      ,nap_sim_profile
                      ,nap_part_serial_no
                      ,nap_message
                      ,nap_pref_parent
                      ,nap_pref_carrid);
        -- SIM PROFILE
        IF nap_message = 'SIM Exchange' THEN
          p_err_num    := -109;
          p_err_string := 'SIM PROFILE NOT MATCHING THE ASSIGNED CARRIER';
		  --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'IF nap_message = SIM Exchange',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
          --CR25641 jchacon end
          RETURN;
        ELSIF nap_message = 'No carrier found for technology.' THEN
          p_err_num    := -110;
          p_err_string := 'PHONE TECHNOLOGY NOT MATCHING THE ASSIGNED CARRIER';
		  --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'IF nap_message = No carrier found for technology.',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
          --CR25641 jchacon end
          RETURN;
        ELSIF nap_message = 'F Choice: MIN already attached to ESN.  Please verify.' THEN
          -- Validations start
          -- NON-MEID Carrier With MEID Phone
          OPEN is_meid_carr_cur;
          FETCH is_meid_carr_cur
            INTO is_meid_carr_rec;
          IF is_meid_carr_rec.x_meid_carrier != 1 THEN
            -- NON-MEID carrier
            OPEN is_meid_phone_cur;
            FETCH is_meid_phone_cur
              INTO is_meid_phone_rec;
            IF is_meid_phone_rec.x_param_value = '1' THEN
              -- MEID Phone
              p_err_num    := -106;
              p_err_string := 'NON-MEID Carrier With MEID Phone Validation Failed';
		  --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'IF is_meid_phone_rec.x_param_value = 1',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
          --CR25641 jchacon end
              RETURN;
            END IF;
            CLOSE is_meid_phone_cur;
          END IF;
          CLOSE is_meid_carr_cur;
          --  Phone not certified for assigned carrier
          OPEN part_num_esn_cur;
          FETCH part_num_esn_cur
            INTO part_num_esn_rec;
          OPEN not_certify_cur(carrier_rec.objid
                              ,part_num_esn_rec.part_number);
          FETCH not_certify_cur
            INTO not_certify_rec;
          IF not_certify_cur%FOUND THEN
            p_err_num    := -107;
            p_err_string := 'PHONE NOT CERTIFIED FOR THE ASSIGNED CARRIER';
		   --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'IF not_certify_cur%FOUND',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
          CLOSE not_certify_cur;
          CLOSE part_num_esn_cur;
          --CR25641 jchacon end
            RETURN;
          END IF;
          CLOSE not_certify_cur;
          CLOSE part_num_esn_cur;
          /*  --  NAP will perform this check
          -- Wrong Zipcode (Carrier Not available or wrong area)
          SELECT COUNT(1)
          INTO l_zip_valid
          FROM carrierzones
          WHERE zip = get_nap_zip_rec.x_value;
          IF l_zip_valid = 0 THEN -- not valid or carrier not available
          p_err_num := - 108;
          p_err_string := 'CARRIER NOT AVAILABLE IN THIS ZIPCODE OR WRONG ZIP CODE USED';
          RETURN;
          END IF;
          */
          -- SIM PROFILE
          --------------------------------------------------------------------------------------------------------------------
          l_step := '8';
          --------------------------------------------------------------------------------------------------------------------
          -- to check for 51 or 54
          /*
          SELECT COUNT(1)
          INTO is_esn_pd_used
          FROM table_part_inst pi, table_site_part sp
          WHERE sp.x_service_id = p_esn
          AND  pi.x_part_inst2site_part = sp.objid
          AND ( pi.x_part_inst_status = '54'
          OR ( pi.x_part_inst_status = '51'
          AND trunc(sp.x_expire_dt) < trunc(SYSDATE)));
          */
          SELECT COUNT(1)
            INTO is_esn_pd_used
            FROM table_part_inst pi
           WHERE pi.part_serial_no = p_esn
             AND pi.x_part_inst_status IN ('54'
                                          ,'51')
             AND TRUNC(pi.warr_end_date) < TRUNC(SYSDATE);
          IF is_esn_pd_used != 0 THEN
            --the phone is past due or used status with due date in the past
            OPEN phn_rc_sd_curs;
            FETCH phn_rc_sd_curs
              INTO phn_rc_sd_rec; -- reserve cards
            --  IF phn_rc_sd_curs%NOTFOUND THEN
            IF phn_rc_sd_rec.x_redeem_days = 0
               OR phn_rc_sd_rec.x_redeem_days IS NULL THEN
              --cwl 10/8/12
              BEGIN
                SELECT 1
                  INTO case_is_locked
                  FROM table_case
                 WHERE id_number = p_case_id
                   FOR UPDATE NOWAIT;
                UPDATE table_case
                   SET oper_system = 'Port Successful'
                 WHERE id_number = p_case_id;
                COMMIT;
              EXCEPTION
                WHEN others THEN
                  ROLLBACK;
                  p_err_num    := -502;
                  p_err_string := 'Case is locked by other user';
				--CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'SELECT 1 INTO case_is_locked...EXCEPTION WHEN others',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
				--CR25641 jchacon end
                  RETURN;
              END;
              --cwl 10/8/12
              --              UPDATE table_case
              --              SET oper_system = 'Port Successful'
              --              WHERE id_number = p_case_id;
              -- close the case
              sa.clarify_case_pkg.close_case(case_rec.objid
                                            ,user_rec.case_owner2user
                                            , -- CR14491
                                             p_sourcesystem
                                            ,NULL
                                            ,NULL
                                            ,l_error_no
                                            ,l_error_str);
              COMMIT; --CR22113 Fix Locking Issue on Table Case
              IF l_error_no != '0' THEN
                p_err_num    := l_error_no;
                p_err_string := l_error_str;
		       --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'If clarify_case_pkg.close_case != 0 (not successful).',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
				--CR25641 jchacon end
                RETURN;
              END IF;
              p_err_num    := -105;
              p_err_string := 'THE PHONE HAS RESERVED CARD BUT SERVICE DAYS NOT AVAILABLE.NEED TO USE AT CARD';
			  --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'IF l_error_no = 0',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
			  --CR25641 jchacon end
              RETURN;
            ELSE
              -- we have service days left hence we will give the same number of days left while activating it
              --l_date := phn_rc_sd_rec.x_expire_dt ;
              l_days := phn_rc_sd_rec.x_redeem_days; -- for future use... can me assign to p_due_date but is assigned in GENCODES
            END IF;
            CLOSE phn_rc_sd_curs;
          END IF;
          ---------------------------------------------------------
          -- service days and statuses are not updated here... to see if gencodes does it
          -- CLFY UPDATES (Passive activation)
          -- to detemine default days given based on brand
          /*
          IF l_brand = 'TRACFONE' THEN
          l_def_days := 30;
          ELSIF l_brand = 'NET10' THEN
          l_def_days := 60;
          END IF;
          */
          FOR call_tx_rec IN call_tx_curs LOOP
            --
            -- CR14799 Start kacosta 11/24/2010
            --UPDATE table_x_call_trans
            --   SET x_min = p_min
            ----x_iccid = nap_sim  -- CR14491_LATER
            -- WHERE objid = call_tx_rec.objid;
            --
            UPDATE table_x_call_trans xct
               SET xct.x_min = p_min
                   --
                   -- CR14826 Start kacosta 11/30/2010
                  ,x_iccid              = nap_sim
                  ,x_call_trans2carrier = carrier_rec.objid
                   -- CR14826 End kacosta 11/30/2010
                   --
                   -- CR28456 Added UDP value by JPena on 09/26/2014
                  ,xct.x_result = CASE
                                    WHEN (xct.x_iccid IS NULL AND xct.x_sourcesystem IN ('WEB','UDP') AND xct.x_action_type = '1' AND xct.x_action_text = 'ACTIVATION' AND xct.x_result = 'Pending' AND xct.x_reason = 'Activation' AND EXISTS (SELECT 1
                                                                                                                                                                                                                                         FROM table_x_call_trans xct_complete
                                                                                                                                                                                                                                        WHERE xct_complete.x_service_id = xct.x_service_id
                                                                                                                                                                                                                                          AND xct_complete.x_iccid IS NOT NULL
                                                                                                                                                                                                                                          AND xct_complete.x_action_type = '1'
                                                                                                                                                                                                                                          AND xct_complete.x_result = 'Completed')) THEN
                                     'Failed'
                                    ELSE
                                     xct.x_result -- CR14033 Net10 Megacard Phase IV
                                  --'Failed' -- CR14826 kacosta 01/12/2011 Workaround patch to resolve the issue of 2 complete call trans record being created
                                  -- The creation of the 2nd call trans record issue will be addressed in future CR
                                  END
             WHERE xct.objid = call_tx_rec.objid;
            -- CR14799 End kacosta 11/24/2010
            --
            OPEN esn_curs;
            FETCH esn_curs
              INTO esn_rec;
            UPDATE table_site_part
               SET x_min  = p_min
                  ,x_msid = DECODE(p_msid
                                  ,NULL
                                  ,esn_rec.x_msid
                                  ,p_msid)
                   --
                   -- CR14826 Start kacosta 11/30/2010
                  ,x_iccid   = nap_sim
                  ,x_zipcode = nap_zip
                   -- CR14826 End kacosta 11/30/2010
                   --
                   -- CR17413 (B) Start ICanavan NT10 L95
                   -- ,PART_STATUS = DECODE(CARRIER_REC.X_MKT_SUBMKT_NAME,'SPRINT_NET10', 'Active', PART_STATUS)  -- PM 02/12/2011 CR18776 Sprint NT10 - UPGRADES,
                   -- For Sprint phones we are not making site part Active from java (Gencode). This phones are NON PPE Phones.
                  ,part_status = (CASE
                                   WHEN esn_rec.bus = 'NET10'
                                        AND esn_rec.dll <= 0
                                        AND esn_rec.non_ppe = '1' THEN
                                    'Active'
                                   ELSE
                                    part_status
                                 END)
             WHERE objid = call_tx_rec.call_trans2site_part;
            -- CR17413 End ICanavan NT10 L95
            CLOSE esn_curs;
          END LOOP;
          /*
          -- service days and statuses are not updated here... to see if gencodes does it
          FOR call_tx_rec IN call_tx_curs LOOP
          -- UPDATE TABLE CALL TRANS
          UPDATE table_x_call_trans
          SET x_result = 'Completed',
          x_min = p_min
          --x_new_due_date = DECODE (l_days, 0,SYSDATE + l_def_days, x_new_due_date + l_days)
          WHERE objid = call_tx_rec.objid;
          OPEN esn_curs;
          FETCH esn_curs INTO esn_rec;
          -- UPDATE LINE in PART INST
          UPDATE table_part_inst
          SET part_serial_no = p_min,
          x_msid = DECODE(p_msid,NULL,x_msid,p_msid)  -- if p_msid is null then dont do anything else update x_msid with p_msid
          --status2x_code_table = 960,
          --x_port_in = 0   -- will do in a Separate statment based on internal or external
          --x_part_inst_status = '13'
          --warr_end_date = DECODE (l_days, 0, SYSDATE + l_def_days, warr_end_date + l_days ),
          WHERE part_to_esn2part_inst = esn_rec.objid
          AND x_domain = 'LINES';
          CLOSE esn_curs;
          -- UPDATE LINE in SITE PART
          UPDATE table_site_part
          SET x_min = p_min,
          x_msid = DECODE(p_msid,NULL,esn_rec.x_msid,p_msid)
          -- part_status = 'Active',
          -- x_expire_dt = DECODE (l_days, 0, SYSDATE + l_def_days ,x_expire_dt + l_days)
          WHERE objid = call_tx_rec.call_trans2site_part; --Ask
          -- UPDATE PHONE in PART INST
          UPDATE table_part_inst
          SET x_port_in = 0
          -- x_part_inst_status = '52',
          -- status2x_code_table = 988,
          -- warr_end_date   = DECODE (l_days, 0, SYSDATE + l_def_days, warr_end_date + l_days),
          -- last_trans_time = DECODE (l_days, 0, SYSDATE + l_def_days, last_trans_time + l_days),
          WHERE part_serial_no = p_esn
          AND x_domain = 'PHONES';
          END LOOP;
          */
          ----------------------------------------------------------
          -- Start PMistry 12/14/2011 CR18776 Sprint NT10 - UPGRADES.
          -- For Sprint phones we are not making Line Active from java (Gencode). This phones are NON PPE Phones.
          -- CR17413 (B) Start ICanavan NT10 L95
          -- if carrier_rec.x_mkt_submkt_name = 'SPRINT_NET10' then
          IF esn_rec.bus = 'NET10'
             AND esn_rec.dll <= 0
             AND esn_rec.non_ppe = '1' THEN
            -- CR17413 End ICanavan NT10 L95
            FOR r_part_inst IN c_part_inst LOOP
              stmt := 'delete from  table_part_inst';
              DELETE FROM table_part_inst
               WHERE part_serial_no LIKE 'T%'
                 AND part_to_esn2part_inst = r_part_inst.objid
                 AND x_domain = 'LINES';
              stmt := 'update table_part_inst';
              -- UPDATE LINE in PART INST
              IF p_min = r_part_inst.line_part_serial_no THEN
                -- Line Updation.
                UPDATE table_part_inst
                   SET x_part_inst_status  = '13'
                      , -- ACTIVE
                       status2x_code_table =
                       (SELECT objid
                          FROM table_x_code_table
                         WHERE x_code_number = '13')
                       --CR21051 Start Kacosta 05/31/2012
                      ,n_part_inst2part_mod = CASE
                                                WHEN NVL(n_part_inst2part_mod
                                                        ,0) <> 23070541 THEN
                                                 23070541
                                                ELSE
                                                 n_part_inst2part_mod
                                              END
                --CR21051 End Kacosta 05/31/2012
                 WHERE objid = r_part_inst.line_objid
                   AND part_to_esn2part_inst = r_part_inst.objid
                   AND x_domain = 'LINES';
              ELSE
                UPDATE table_part_inst
                   SET x_part_inst_status  = '17'
                      , -- RETURNED
                       status2x_code_table =
                       (SELECT objid
                          FROM table_x_code_table
                         WHERE x_code_number = '17')
                       --CR21051 Start Kacosta 05/31/2012
                      ,n_part_inst2part_mod = CASE
                                                WHEN NVL(n_part_inst2part_mod
                                                        ,0) <> 23070541 THEN
                                                 23070541
                                                ELSE
                                                 n_part_inst2part_mod
                                              END
                --CR21051 End Kacosta 05/31/2012
                 WHERE objid = r_part_inst.line_objid
                   AND part_to_esn2part_inst = r_part_inst.objid
                   AND x_domain = 'LINES';
              END IF;
            END LOOP;
          END IF;
          -- End PMistry 12/14/2011 CR18776 Sprint NT10 - UPGRADES.
          -- marry the SIM to phone
          UPDATE table_part_inst
             SET x_iccid = nap_sim
           WHERE part_serial_no = p_esn
             AND x_iccid <> nap_sim;
          UPDATE table_site_part
             SET x_iccid = nap_sim
           WHERE x_service_id = p_esn
             AND x_iccid <> nap_sim;
         --
          --CR21060 Start kacosta 06/05/2012
          IF (nap_sim IS NOT NULL) THEN
            --
            UPDATE table_x_sim_inv xsi
               SET xsi.x_last_update_date        = SYSDATE
                  ,xsi.x_sim_inv_status          = '254'
                  ,xsi.x_sim_status2x_code_table = 268438607
             WHERE xsi.x_sim_serial_no = nap_sim
               AND xsi.x_sim_inv_status IN ('251'
                                           ,'253')
               AND EXISTS (SELECT 1
                      FROM table_part_inst tpi
                      JOIN table_site_part tsp
                        ON tpi.part_serial_no = tsp.x_service_id
                     WHERE tpi.x_iccid = xsi.x_sim_serial_no
                       AND tpi.part_serial_no = p_esn
                       AND tpi.x_domain = 'PHONES'
                       AND tpi.x_part_inst_status = '52'
                       AND tsp.part_status = 'Active'
                       AND tsp.x_iccid = xsi.x_sim_serial_no);
            --
          END IF;
          --CR21060 End kacosta 06/05/2012
          --
          --
          -- CR14826 Start kacosta 11/30/2010
          --cwl 10/8/12
          BEGIN
            SELECT 1
              INTO case_is_locked
              FROM table_case
             WHERE id_number = p_case_id
               FOR UPDATE NOWAIT;
            UPDATE table_case
               SET x_activation_zip = nap_zip
                  ,x_iccid          = NULL
             WHERE id_number = p_case_id;
            COMMIT;
          EXCEPTION
            WHEN others THEN
              ROLLBACK;
              p_err_num    := -503;
              p_err_string := 'Case is locked by other user';
			  --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'SELECT 1 INTO case_is_locked... EXCEPTION WHEN others',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
			  --CR25641 jchacon end
              RETURN;
          END;
          --cwl 10/8/12
          --UPDATE table_case
          --SET x_activation_zip = nap_zip ,
          --  x_iccid            = NULL
          --WHERE id_number      = p_case_id;
          -- COMMIT; --CR22113 Fix Locking Issue on Table Case
          --
          IF (nap_sim IS NOT NULL) THEN
            --
            UPDATE table_x_case_detail xcd
               SET xcd.x_value = nap_sim
             WHERE EXISTS (SELECT 1
                      FROM table_case tbc
                     WHERE tbc.id_number = p_case_id
                       AND tbc.x_esn = p_esn
                       AND tbc.objid = xcd.detail2case)
               AND xcd.x_name = 'SIM_ID';
            --
            IF (SQL%ROWCOUNT = 0) THEN
              --
              INSERT INTO table_x_case_detail
                (objid
                ,dev
                ,x_name
                ,x_value
                ,detail2case)
              VALUES
                (seq('x_case_detail')
                ,NULL
                ,'SIM_ID'
                ,nap_sim
                ,(SELECT tbc.objid
                   FROM table_case tbc
                  WHERE tbc.id_number = p_case_id
                    AND tbc.x_esn = p_esn));
              --
            END IF;
            --
          END IF;
          --
          -- Per defect #4 (Releases_2011) ICCID value must be NULL
          --
          UPDATE table_x_case_detail xcd
             SET xcd.x_value = NULL
           WHERE EXISTS (SELECT 1
                    FROM table_case tbc
                   WHERE tbc.id_number = p_case_id
                     AND tbc.x_esn = p_esn
                     AND tbc.objid = xcd.detail2case)
             AND xcd.x_name = 'ICCID'
             AND xcd.x_value IS NOT NULL;
          --
          UPDATE table_x_call_trans xct
             SET x_result = 'Failed'
           WHERE xct.x_service_id = p_esn
--cr26076 9/26/2013 fix dup row error
--             AND xct.objid < (SELECT xct.objid
             AND xct.objid < (SELECT max(xct_complete.objid)
                                FROM table_x_call_trans xct_complete
                               WHERE xct_complete.x_service_id = xct.x_service_id
                                 AND xct_complete.x_action_type = '1'
                                 AND xct_complete.x_result = 'Completed')
             AND xct.x_result = 'Pending'
             AND xct.x_action_type = '1';
          --
          -- CR14826 End kacosta 11/30/2010
          --
          ----------------------------------------------------------
          -- close the case after the gencodes
          /*
          UPDATE table_case
          SET    OPER_SYSTEM = 'Port Successful'
          WHERE  ID_NUMBER =  p_case_id;
          -- close the case
          SA.CLARIFY_CASE_PKG.CLOSE_CASE( CASE_rec.OBJID,
          USER_rec.OBJID,
          p_sourcesystem,
          null,
          null,
          l_ERROR_NO,
          l_ERROR_STR);
          IF l_error_no != '0' THEN
          p_err_num := l_error_no;
          p_err_string := l_error_str;
          RETURN;
          END IF;
          --p_err_string := l_error_str;
          */
          --
          --CR22152 Start Kacosta 10/15/2012
          BEGIN
            --
            IF get_case_old_esn_curs%ISOPEN THEN
              --
              CLOSE get_case_old_esn_curs;
              --
            END IF;
            --
            OPEN get_case_old_esn_curs(c_n_case_objid => case_rec.objid
                                      ,c_v_new_esn    => p_esn);
            FETCH get_case_old_esn_curs
              INTO get_case_old_esn_rec;
            CLOSE get_case_old_esn_curs;
            --
            IF (get_case_old_esn_rec.old_esn IS NOT NULL) THEN
              --
              l_v_old_esn := get_case_old_esn_rec.old_esn;
              --
            ELSE
              --
              l_v_old_esn := case_rec.x_esn;
              --
            END IF;
            --
            --CR22660 Start kacosta 11/16/2012
            --enroll_promo_pkg.sp_get_eligible_promo_esn2(p_esn         => l_v_old_esn
            enroll_promo_pkg.sp_get_eligible_promo_esn(p_esn => l_v_old_esn
                                                       --CR22660 End kacosta 11/16/2012
                                                       ,p_promo_objid => l_n_promo_objid
                                                       ,p_promo_code  => l_v_promo_code
                                                       ,p_script_id   => l_v_script_id
                                                       ,p_error_code  => l_n_error_code
                                                       ,p_error_msg   => l_v_error_message);
            --
            --CR22660 Start kacosta 11/16/2012
            --IF (l_n_error_code <> 0) THEN
            IF (l_n_error_code NOT IN (0
                                      ,306)) THEN
              --CR22660 End kacosta 11/16/2012
              --
              l_v_error_message := 'Calling enroll_promo_pkg.sp_get_eligible_promo_esn2 error message: ' || l_v_error_message;
              --
              RAISE l_exc_transfer_promo_enrollmnt;
              --
            END IF;
            --
            IF (l_n_promo_objid IS NOT NULL) THEN
              --
              enroll_promo_pkg.sp_transfer_promo_enrollment(p_case_objid => case_rec.objid
                                                           ,p_new_esn    => p_esn
                                                           ,p_error_code => l_n_error_code
                                                           ,p_error_msg  => l_v_error_message);
              --
              IF (l_n_error_code <> 0) THEN
                --
                RAISE l_exc_transfer_promo_enrollmnt;
                --
              END IF;
              --
            END IF;
            --
          EXCEPTION
            WHEN l_exc_transfer_promo_enrollmnt THEN
              --
              ota_util_pkg.err_log(p_action       => 'Calling enroll_promo_pkg for case objid: ' || TO_CHAR(case_rec.objid) || ' new esn: ' || p_esn
                                  ,p_error_date   => SYSDATE
                                  ,p_key          => p_esn
                                  ,p_program_name => 'port_pkg.complete_port'
                                  ,p_error_text   => 'Error code: ' || TO_CHAR(l_n_error_code) || ' Error message: ' || l_v_error_message);
              --
            WHEN others THEN
              --
              ota_util_pkg.err_log(p_action       => 'Determining to transfer promo enrollment for case objid: ' || TO_CHAR(case_rec.objid) || ' new esn: ' || p_esn
                                  ,p_error_date   => SYSDATE
                                  ,p_key          => p_esn
                                  ,p_program_name => 'port_pkg.complete_port'
                                  ,p_error_text   => 'Error code: ' || TO_CHAR(SQLCODE) || ' Error message: ' || SQLERRM);
              --
          END;
          --CR22152 End Kacosta 10/15/2012
          --
          p_err_num    := '0';
          p_err_string := 'Success';
          COMMIT;


          -- Added logic by Juda Pena on 3/15/2015 for CR30440
          --mformation_pkg.clone_port_ig_trans_wrapper ( i_esn => p_esn);
          --COMMIT;

        ELSE
          p_err_num    := -113;
          p_err_string := nap_message;
          dbms_output.put_line('COMPLETE PORT PROCEDURE FAILED FOR THIS VALIDATION - ' || nap_message);
			  --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'IF nap_message != SIM Exchange',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
			  --CR25641 jchacon end
          -- p_err_string := nap_message; --'MIN IS NOT ATTACHED.PLEASE VERIFY';
          -- p_err_string := 'COMPLETE PORT PROCEDURE FAILED FOR THIS VALIDATION - '||nap_message;
          RETURN;
        END IF;
      EXCEPTION
        WHEN others THEN
          ROLLBACK;
          p_err_num    := -111;
          p_err_string := 'step ' || l_step || ':' || SQLCODE || ':' || SQLERRM;
			  --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'IF nap_message = SIM Exchange THEN...EXCEPTION
                                                          WHEN others THEN',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
			  --CR25641 jchacon end
      END;
    END IF;

    -- Added logic by Juda Pena on 3/15/2015 for CR30440
    mformation_pkg.clone_port_ig_trans_wrapper ( i_esn => p_esn);
    COMMIT;

    ----------------------------------------------------
    -- CR23362 complete port in RIM phone
    --------------------------------------------------------
    if p_err_string = 'Success' and p_err_num = '0' then


         OPEN IG_TRANS_RIM_CURS;
           FETCH IG_TRANS_RIM_curs
           INTO IG_TRANS_RIM_REC;
           IF IG_TRANS_RIM_curs%FOUND THEN

               DBMS_OUTPUT.PUT_LINE('ESN is BB, begin insert into ig_transaction_RIM Port_pkg action_item_id '||IG_TRANS_RIM_REC.Action_Item_Id);

                sa.Rim_Service_Pkg.Sp_Create_Rim_Action_Item(IG_TRANS_RIM_REC.Action_Item_Id,
                                                             Op_Msg,
                                                             op_status); --action_item_id (gw1.ig_transaction)
            IF op_status = 'S' then
              DBMS_OUTPUT.PUT_LINE('Inserted ig_transaction_RIM succesful');

              IF  IG_TRANS_RIM_REC.order_type in ('PIR','EPIR') and  IG_TRANS_RIM_REC.status = 'F'  THEN  --- AGENT complete PORT IN manually
                -----------------------------------------------------------
                -- Upadate ig_transaction_RIM PENDING
                ----------------------------------------------------------
                UPDATE GW1.TABLE_X_RIM_TRANSACTION
                   SET X_RIM_STATUS = DECODE(IG_TRANS_RIM_REC.ORDER_TYPE,'PIR','PENDING','EPIR','PENDING',X_RIM_STATUS)   --CR23362
                WHERE X_TRANSACTION_ID = IG_TRANS_RIM_REC.TRANSACTION_ID;
                commit;
                ----------------------------------------------------------
                -- Update successful IG_transaction by action_item_id
                ----------------------------------------------------------
                UPDATE GW1.IG_TRANSACTION
                  SET STATUS = 'W',
                      UPDATE_DATE = SYSDATE
                WHERE TRANSACTION_ID = IG_TRANS_RIM_REC.TRANSACTION_ID;
                commit;

              END IF;
            ELSE
               DBMS_OUTPUT.PUT_LINE('Process Fail sa.sp_insert_ig_transaction_rim inserting into ig_transaction_RIM port_pkg');
               OP_MSG := 'Process Fail sa.sp_insert_ig_transaction_rim inserting into ig_transaction_RIM port_pkg';

                   sa.ota_util_pkg.err_log(p_action       => 'Status F into RIM_SERVICE_PKG.SP_CREATE_ACTION_ITEM'
                          ,P_ERROR_DATE   => SYSDATE
                          ,P_KEY          =>  p_esn
                          ,P_PROGRAM_NAME => 'PORT_PKG.COMPLETE_PORT'
                          ,P_ERROR_TEXT   => OP_MSG);


            END IF;
          end if;
        close IG_TRANS_RIM_curs;
      COMMIT;
      --------------------------------------
      -- CR23362 complete port in RIM phone
      --------------------------------------
    end if ;
  EXCEPTION
    WHEN others THEN
      ROLLBACK;
      p_due_date   := NULL;
      p_err_num    := SQLCODE;
      p_err_string := SUBSTR(SQLERRM
                            ,1
                            ,200);

			  --CR25641 jchacon
				sa.toss_util_pkg.insert_error_tab_proc (
											  ip_action         =>  'PROCEDURE complete_port...EXCEPTION
                                                          WHEN others THEN',
											  ip_key            =>  p_case_id,
											  ip_program_name   => 'port_pkg.complete_port',
											  ip_error_text     => to_char(p_err_num)||' '||p_err_string);
			  --CR25641 jchacon end
  END complete_port;
  /* This procedure is created by Sushanth and added in to Port_pkg by Pmistry on 05/26/2010 */
  PROCEDURE cancel_port_prc
  (
    p_srcesystem IN VARCHAR2
   ,p_usrobjid   IN VARCHAR2
   ,p_esn        IN VARCHAR2
   ,p_min        IN VARCHAR2
   ,op_return    OUT VARCHAR2
   ,op_returnmsg OUT VARCHAR2
  ) AS
    ------
    CURSOR chk_part_inst_cur --(c_esn IN VARCHAR2)
    IS
      SELECT x_part_inst_status
        FROM table_part_inst
       WHERE part_serial_no = p_esn;
    part_inst_rec chk_part_inst_cur%ROWTYPE;
    ------
    CURSOR chk_site_part_cur --(c_esn IN VARCHAR2)
    IS
      SELECT *
        FROM table_site_part
       WHERE x_service_id = p_esn;
    site_part_rec chk_site_part_cur%ROWTYPE;
    ------
    --- NET10MC Starts
    CURSOR ig_call_tx_cur IS
      SELECT action_item_id
            ,x_task2x_call_trans
            ,RANK
        FROM (SELECT /*+ USE_INVISIBLE_INDEXES index(a ig_transaction_esn) */ a.action_item_id
                    ,RANK() over(PARTITION BY esn ORDER BY creation_date DESC) "RANK"
                     ,a.creation_date
                     ,a.esn
                     ,t.x_task2x_call_trans
                FROM table_task         t
                    ,gw1.ig_transaction a
               WHERE a.status NOT IN ('W'
                                     ,'S')
                 AND a.order_type IN ('PIR'
                                     ,'EPIR')
                 AND a.esn = p_esn
                 AND t.task_id = a.action_item_id)
       WHERE RANK = 1;
    ig_call_tx_rec ig_call_tx_cur%ROWTYPE;
    --- NET10MC Ends
    ------
    CURSOR cp_min_curs --(c_min in varchar2)
    IS
      SELECT pi.*
            ,(SELECT NVL(cr.x_line_return_days
                        ,0) x_line_return_days
                FROM table_x_carrier_rules cr
                    ,table_x_carrier       c
               WHERE cr.objid = c.carrier2rules
                 AND c.objid = pi.part_inst2carrier_mkt) x_line_return_days
        FROM table_part_inst pi
       WHERE pi.part_serial_no = p_min
         AND pi.x_domain = 'LINES';
    cp_min_rec cp_min_curs%ROWTYPE;
    --------------------
    --------------------
    -- variables declaration
    pi_rec_exception EXCEPTION;
    sp_rec_exception EXCEPTION;
    v_action         VARCHAR2(4000);
    v_procedure_name VARCHAR2(30) := ' CANCEL_PORT()';
    strsqlerrm       VARCHAR2(200);
    -----
    -- v_min                VARCHAR2 (30) := NULL;
    -- v_deactreason        VARCHAR2(30)
    v_intbypassordertype NUMBER := 0;
    p_newesn             VARCHAR2(30) := NULL;
    v_samemin            VARCHAR2(30) := 'false';
  BEGIN
    OPEN chk_part_inst_cur;
    FETCH chk_part_inst_cur
      INTO part_inst_rec;
    IF chk_part_inst_cur%NOTFOUND THEN
      CLOSE chk_part_inst_cur;
      op_returnmsg := 'ESN IS NOT VALID';
      RAISE pi_rec_exception;
    ELSE
      CLOSE chk_part_inst_cur;
    END IF;
    OPEN chk_site_part_cur;
    FETCH chk_site_part_cur
      INTO site_part_rec;
    IF chk_site_part_cur%NOTFOUND THEN
      CLOSE chk_site_part_cur;
      op_returnmsg := 'NO RECORD IN SITE PART';
      RAISE sp_rec_exception;
    ELSE
      CLOSE chk_site_part_cur;
    END IF;
    v_action := ' CALL TO DEACTSERVICE ';
    -- Call DeactService
    sa.service_deactivation.deactservice(p_srcesystem
                                        ,p_usrobjid
                                        ,p_esn
                                        ,p_min
                                        ,'PORT CANCEL'
                                        ,0
                                        ,p_newesn
                                        ,v_samemin
                                        ,v_returnflag
                                        ,v_returnmsg);
    dbms_output.put_line('ServiceDeactivation:' || v_returnflag || ': ' || v_returnmsg);
    IF v_returnflag = 'true'
       OR part_inst_rec.x_part_inst_status <> '52' THEN
      -- DeactService is succesful
      v_action := ' UPDATING TABLE_PART_INST ';
      UPDATE table_part_inst
         SET x_port_in           = 0
            ,x_part_inst2contact = NULL
       WHERE part_serial_no = p_esn;
      COMMIT;
      dbms_output.put_line('UPDATING TABLE_PART_INST FINISH');
      v_action := ' UPDATING TABLE_SITE_PART ';
      UPDATE table_site_part
         SET part_status = 'Obsolete'
            ,state_code  = 0
       WHERE x_service_id = p_esn
         AND part_status = 'CarrierPending';
      COMMIT;
      dbms_output.put_line('UPDATING TABLE_SITE_PART FINISH');
      /*    CR14484 PM 09/30/2010 commenting as we do not need to remove
      V_ACTION := ' DELETING CONTACT INFORMATION ';
      DELETE table_x_contact_part_inst
      WHERE x_contact_part_inst2part_inst IN (SELECT objid
      FROM table_part_inst
      WHERE part_serial_no = p_esn);
      DBMS_OUTPUT.PUT_LINE('DELETING CONTACT INFORMATION FINISHED');
      */
      v_action := ' UPDATING TABLE CALL TRANS STATUS TO FAILED ';
      --- NET10MC Starts
      OPEN ig_call_tx_cur;
      FETCH ig_call_tx_cur
        INTO ig_call_tx_rec;
      IF ig_call_tx_cur%FOUND THEN
        UPDATE table_x_call_trans
           SET x_result = 'Failed'
         WHERE objid = ig_call_tx_rec.x_task2x_call_trans;
        dbms_output.put_line(' UPDATING TABLE CALL TRANS STATUS TO FAILED FINISHED');
      END IF;
      CLOSE ig_call_tx_cur;
      --- NET10MC Ends
      v_action := ' UN-RESERVE THE MIN ';
      OPEN cp_min_curs;
      FETCH cp_min_curs
        INTO cp_min_rec;
      IF cp_min_rec.part_serial_no LIKE 'T%' THEN
        --
        DELETE FROM table_part_inst
         WHERE objid = cp_min_rec.objid;
      ELSE
        IF sa.toss_util_pkg.insert_pi_hist_fun(cp_min_rec.part_serial_no
                                              ,'LINES'
                                              ,'PORT CANCEL'
                                              ,NULL) THEN
          NULL;
        END IF;
        UPDATE table_part_inst -- 12 - USED 17 - RETURNED
           SET part_to_esn2part_inst = NULL
              ,x_part_inst_status = (CASE
                                      WHEN cp_min_rec.x_line_return_days < 1 THEN
                                       '12'
                                      ELSE
                                       '17'
                                    END)
               --CR21051 Start Kacosta 05/31/2012
              ,n_part_inst2part_mod = CASE
                                        WHEN NVL(n_part_inst2part_mod
                                                ,0) <> 23070541 THEN
                                         23070541
                                        ELSE
                                         n_part_inst2part_mod
                                      END
        --CR21051 End Kacosta 05/31/2012
         WHERE 1 = 1
           AND objid = cp_min_rec.objid;
      END IF;
      CLOSE cp_min_curs;
      v_action := ' UPDATING X_SWITCHBASED_TRANSACTION ';
      OPEN chk_st_gsm_cur(p_esn);
      FETCH chk_st_gsm_cur
        INTO rec_chk_st_gsm;
      IF chk_st_gsm_cur%FOUND THEN
        IF rec_chk_st_gsm.x_param_value != 0 THEN
          -- 0 ST GSM Skip Update SwB Tx
          UPDATE x_switchbased_transaction stx
             SET status = 'Completed'
           WHERE status = 'CarrierPending'
             AND stx.x_sb_trans2x_call_trans IN (SELECT objid
                                                   FROM table_x_call_trans
                                                  WHERE x_service_id = p_esn);
        END IF;
      END IF;
      CLOSE chk_st_gsm_cur;
      op_return    := '0';
      op_returnmsg := 'SUCCESS';
      COMMIT;
    ELSE
      v_action     := ' SERVICE_DEACTIVATION.DEACTSERVICE RETURN ';
      op_return    := '-1';
      op_returnmsg := 'FAIL';
      toss_util_pkg.insert_error_tab_proc(v_action || op_returnmsg
                                         ,p_esn
                                         ,v_procedure_name);
    END IF;
  EXCEPTION
    WHEN pi_rec_exception THEN
      IF chk_part_inst_cur%ISOPEN THEN
        CLOSE chk_part_inst_cur;
      END IF;
      op_return    := '-1';
      op_returnmsg := 'FAIL';
      toss_util_pkg.insert_error_tab_proc(v_action || op_returnmsg
                                         ,p_esn
                                         ,v_procedure_name);
    WHEN sp_rec_exception THEN
      IF chk_site_part_cur%ISOPEN THEN
        CLOSE chk_site_part_cur;
      END IF;
      op_return    := '-1';
      op_returnmsg := 'FAIL';
      toss_util_pkg.insert_error_tab_proc(v_action || op_returnmsg
                                         ,p_esn
                                         ,v_procedure_name);
    WHEN others THEN
      strsqlerrm   := SUBSTR(SQLERRM
                            ,1
                            ,200);
      op_return    := '-1';
      op_returnmsg := 'FAIL';
      op_return    := strsqlerrm;
      toss_util_pkg.insert_error_tab_proc(v_action || op_returnmsg
                                         ,p_esn
                                         ,v_procedure_name);
  END CANCEL_PORT_PRC;

/* -- CR15434 Port Automation Enhancement Project  */
PROCEDURE getPortCarrierType_prc (
-- *********************************************************
-- Service  getPortCarrierType_Prc
-- Object type:  Procedure
-- Desc: Return all values of the input parameter
--       phone type from table X_PORT_CARRIERS
-- Input parameter:
-- Name IP_PHONE_TYPE Varchar2(30) Values (STREET_TYPE/DIRECTION)
-- Output:
-- Name  OP_CLARIFY_FORMATS SYS_REFCURSOR Components Value
-- How to call:   Getformats_prc ( ip_format_type )
-- *********************************************************
IP_PHONE_TYPE      in varchar2, -- Wireless or Landline
OP_PORT_CARRIERS   out sys_refcursor, -- Carrier Name + External or Internal
op_result          out number,
op_msg             out varchar2 )
as

begin
  op_result := '0';
  op_msg := NULL;

  open OP_PORT_CARRIERS
  for select Carrier_name, Port_type
  from sa.X_PORT_CARRIERS
  where PHONE_TYPE = IP_PHONE_TYPE
  order by Carrier_name ;

  if OP_PORT_CARRIERS%NOTFOUND
  then
  op_result := '640';
  op_msg := get_code_fun('PORT_PKG','640','ENGLISH');
  sa.ota_util_pkg.err_log(p_action        => get_code_fun('PORT_PKG','640','ENGLISH')
                          ,p_error_date   => SYSDATE
                          ,p_key          =>  ip_PHONE_type
                          ,p_program_name => 'PORT_PKG.getPortCarrierType_prc'
                          ,p_error_text   => op_msg);
  -- close Services ; we dont close the cursor JAVA team closes the cursor
  return ;
  end if ;
end getPortCarrierType_prc;

--New stored procedure for CR39428 IVR External ports.
PROCEDURE check_port_coverage(i_esn                  IN  VARCHAR2 ,
                            i_sim                  IN  VARCHAR2 ,
                            i_brand                IN  VARCHAR2 ,
                            i_zip_code             IN  VARCHAR2 ,
                            i_source               IN  VARCHAR2 ,
                            o_assign_carr_prnt_id  OUT VARCHAR2 ,
                            o_assign_carr_objid    OUT NUMBER   ,
                            o_assign_carr_id       OUT VARCHAR2 ,
                            o_assign_carr_name     OUT VARCHAR2 ,
                            o_contact_objid        OUT NUMBER   ,
                            o_eligible_flag        OUT VARCHAR2 ,
                            o_elig_failure_reason  OUT VARCHAR2 ,
                            o_err_code             OUT NUMBER   ,
                            o_err_msg              OUT VARCHAR2
                            )
AS

  --Variables declaration for customer type
  cust                  sa.customer_type ;
  cst                   sa.customer_type ;
  --Local variables
  l_assign_carr_objid   NUMBER      ;
  l_assign_carr_prnt_id VARCHAR2(30);
  l_assign_carr_id      NUMBER      ;
  l_assign_carr_name    VARCHAR2(30);
  l_sim_status          VARCHAR2(30);
  l_port_status         VARCHAR2(30);
  l_nap_digital_pass    VARCHAR2(1) := 'Y';
  l_esn_count           NUMBER      ;
  l_sim_status_flag     VARCHAR2(1) := 'Y';
  l_auto_port_flag      VARCHAR2(1) := 'Y';
  --
  o_repl_part           VARCHAR2(30);
  o_repl_tech           VARCHAR2(30);
  o_sim_profile         VARCHAR2(30);
  o_part_serial_no      VARCHAR2(30);
  o_msg                 VARCHAR2(200);
  o_pref_parent         VARCHAR2(30);
  o_pref_carrier_objid  VARCHAR2(30);

BEGIN --Main Section

     --To validate ESN cannot be NULL.
     IF i_esn IS NULL THEN
        o_err_code := -1;
        o_err_msg := 'ESN cannot be NULL';
        RETURN;
     END IF;

     --To check whether the given ESN exists.
     BEGIN
         SELECT COUNT(*)
         INTO  l_esn_count
         FROM  table_part_inst pi_esn
         WHERE pi_esn.part_serial_no =  i_esn
         AND   pi_esn.x_domain       = 'PHONES';
     EXCEPTION
         WHEN OTHERS THEN
         o_err_code := -1;
         o_err_msg := 'Check Port Coverage - ESN Validation: '||substr(sqlerrm,1,100);
     END;

  --Instantiate Customer Type
  cust := sa.customer_type ( i_esn => i_esn );

  -- Calling the customer type retrieve method
  cst := cust.retrieve;

  --CALL NAP_DIGITAL STORED PROCEDURE
      sa.NAP_DIGITAL( p_zip                => i_zip_code          ,
                      p_esn                => i_esn               ,
                      p_commit             => NULL                ,
                      p_language           => NULL                ,
                      p_sim                => i_sim               ,
                      p_source             => i_source            ,
                      p_upg_flag           => NULL                ,
                      p_repl_part          => o_repl_part         ,
                      p_repl_tech          => o_repl_tech         ,
                      p_sim_profile        => o_sim_profile       ,
                      p_part_serial_no     => o_part_serial_no    ,
                      p_msg                => o_msg               ,
                      p_pref_parent        => o_pref_parent       ,
                      p_pref_carrier_objid => o_pref_carrier_objid
                      );

        --Check the validation required on table_nap_msg_mapping table.
         BEGIN
           SELECT DISTINCT DECODE(error_no,0,'Y', 1, 'N')
           INTO   l_nap_digital_pass
           FROM   table_nap_msg_mapping
           WHERE  nap_msg = o_msg;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
             o_err_code := -1;
             o_err_msg  := 'Check Port Coverage - NAP Validation : '||'NAP message not found';
             RETURN;

            WHEN TOO_MANY_ROWS THEN
            o_err_code := -1;
            o_err_msg  := 'Check Port Coverage - NAP Validation : '||substr(sqlerrm,1,100);
            RETURN;

            WHEN OTHERS THEN
            o_err_code := -1;
            o_err_msg  := 'Check Port Coverage - NAP Validation : '||substr(sqlerrm,1,100);
            RETURN;
         END;
         --
         IF l_nap_digital_pass    <> 'Y' THEN
            o_err_code            := -1            ;
            o_eligible_flag       := 'N'           ;
            o_elig_failure_reason := 'Invalid NAP' ;
            RETURN;
         END IF;

      BEGIN
        --Retrieve the auto port in status
        SELECT x_auto_port_in
        INTO   l_port_status
        FROM   table_x_parent
        WHERE  x_parent_id =  o_pref_parent;

        IF l_port_status <> '1' THEN
          o_err_code            := -1                     ;
          l_auto_port_flag      := 'N'                    ;
          o_eligible_flag       := 'N'                    ;
          o_elig_failure_reason := 'No Auto Port Carrier' ;
          RETURN;
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('155....');
        o_err_code := -1;
        o_err_msg  := 'Check Port Coverage - Auto Port In Status : '||substr(sqlerrm,1,100);
        RETURN;

        WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('161....');
        o_err_code := -1;
        o_err_msg  := 'Check Port Coverage -  Auto Port In Status : '||substr(sqlerrm,1,100);
        RETURN;

        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('167....');
        o_err_code := -1;
        o_err_msg  := 'Check Port Coverage -  Auto Port In Status : '||substr(sqlerrm,1,100);
        RETURN;

      END;

	IF i_sim IS NOT NULL THEN
      --GET SIM STATUS
      BEGIN
          SELECT sim.x_sim_inv_status
                 INTO
                 l_sim_status
          FROM   table_x_sim_inv sim
          WHERE  sim.x_sim_serial_no = i_sim;

      EXCEPTION
          WHEN NO_DATA_FOUND THEN
          o_err_code := -1;
          o_err_msg  := 'Check Port Coverage - SIM Status : '||'No Record Exists for given SIM';
          RETURN;

          WHEN TOO_MANY_ROWS THEN
          o_err_code := -1;
          o_err_msg  := 'Check Port Coverage - SIM Status : '||'More than 1 Record Exists for given SIM';
          RETURN;

          WHEN OTHERS THEN
          o_err_code := -1;
          o_err_msg  := 'Check Port Coverage - SIM Status : '||substr(sqlerrm,1,100);
          RETURN;
      END;
      --
      IF l_sim_status <> '253' THEN

         o_err_code            := -1                     ;
         l_sim_status_flag     := 'N'                    ;
         o_eligible_flag       := 'N'                    ;
         o_elig_failure_reason := 'SIM STATUS IS NOT NEW';
         RETURN;

      END IF;

   END IF;
      --To retrieve the parent carrier information
      BEGIN
          SELECT cr.objid              ,
                 cr.x_carrier_id       ,
                 pr.x_parent_id        ,
                 cr.x_mkt_submkt_name
          INTO   l_assign_carr_objid   ,
                 l_assign_carr_id      ,
                 l_assign_carr_prnt_id ,
                 l_assign_carr_name
          FROM   sa.table_x_carrier       cr ,
                 sa.table_x_carrier_group cg ,
                 sa.table_x_parent        pr
          WHERE  cr.objid                    = o_pref_carrier_objid
          AND    cr.carrier2carrier_group    = cg.objid
          AND    cg.x_carrier_group2x_parent = pr.objid;
      --
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
           o_err_code := -1;
           o_err_msg  := 'Check Port Coverage - Parent Carrier Information : '||'No Record Exists for given ESN';
           RETURN;
          --
          WHEN TOO_MANY_ROWS THEN
          o_err_code := -1;
          o_err_msg  := 'Check Port Coverage - Parent Carrier Information : '||'More than 1 Record Exists for given ESN';
          RETURN;
          --
          WHEN OTHERS THEN
          o_err_code := -1;
          o_err_msg  := 'Check Port Coverage - Parent Carrier Information : '||substr(sqlerrm,1,100);
          RETURN;
      --
      END;

    --Eligibility Flag Validation
    IF l_nap_digital_pass = 'Y' AND l_auto_port_flag = 'Y' AND l_sim_status_flag = 'Y' THEN
       o_eligible_flag       := 'Y';
    ELSE
       o_eligible_flag       := 'N';
    END IF;
    --
    o_assign_carr_prnt_id := l_assign_carr_prnt_id ;
    o_assign_carr_id      := l_assign_carr_id      ;
    o_assign_carr_name    := l_assign_carr_name    ;
    o_assign_carr_objid   := l_assign_carr_objid   ;
    o_contact_objid       := cst.contact_objid     ;
    --
    o_err_code := 0        ;
    o_err_msg  := 'SUCCESS';
    --
    --Exception Handling for Main Section
    EXCEPTION
    WHEN OTHERS THEN
         o_err_code := -1;
         o_err_msg  := 'Get_Port_Coverage:  '||substr(sqlerrm,1,100);
         sa.util_pkg.insert_error_tab (i_action       => 'Check Port Coverage',
                                       i_key          => i_esn                ,
                                       i_program_name => 'check_port_coverage'  ,
                                       i_error_text   => o_err_msg
                                       );

END check_port_coverage;
PROCEDURE  ivr_port_close_tkt_prc(i_esn             IN  VARCHAR2,
                                  o_trans_tkt_num   OUT VARCHAR2,
                                  o_err_code        OUT NUMBER  ,
                                  o_err_msg         OUT VARCHAR2
                                  )
AS
  --Local variables declaration
  l_esn_count           NUMBER;
  l_case_objid          NUMBER;
  l_port_in_cnt         NUMBER;
  l_user_objid          NUMBER;

BEGIN --Main Section

  --To validate ESN cannot be NULL.
     IF i_esn IS NULL THEN
        o_err_code := -1;
        o_err_msg  := 'ESN cannot be NULL';
        RETURN;
     END IF;

     --To check whether the given ESN exists.
     BEGIN
         SELECT COUNT(*)
         INTO  l_esn_count
         FROM  table_part_inst pi_esn
         WHERE pi_esn.part_serial_no =  i_esn
         AND   pi_esn.x_domain       = 'PHONES';

		 --ESN Validation
         IF l_esn_count = 0 THEN
            o_err_code    := -1;
            o_err_msg     := 'ESN cannot be found';
            RETURN;
         END IF;

     EXCEPTION
	     WHEN OTHERS THEN
         o_err_code := -1;
         o_err_msg := 'Port Ticket Close - ESN Validation: '||substr(sqlerrm,1,100);
		 RETURN;
     END;

    --Find the open transaction ticket for given ESN
    BEGIN
        SELECT tc.objid      ,
               tc.id_number
        INTO
               l_case_objid,
               o_trans_tkt_num
        FROM   table_case          tc,
               table_condition     tcon
        WHERE  tc.x_esn                =  i_esn
        AND    tcon.s_title            <> 'CLOSED'
        AND    tc.x_case_type          =  'Transaction'
        AND    (tc.creation_time       <= SYSDATE OR tc.hangup_time <= SYSDATE)
        AND    tc.case_state2condition = tcon.objid
        ORDER BY tc.creation_time DESC,
                 tc.hangup_time   DESC;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_err_code := -1;
         o_err_msg  := 'IVR_PORT_CLOSE_TKT_PRC: No open Transaction Tickets for given ESN';
         RETURN;

      WHEN OTHERS THEN
         o_err_code := -1;
         o_err_msg  := 'IVR_PORT_CLOSE_TKT_PRC:  '||substr(sqlerrm,1,100);
         RETURN;
    END;

	o_err_code := 0;
    o_err_msg  := 'Success';

    --Retrieve the user objid
    SELECT objid INTO l_user_objid FROM table_user WHERE login_name  = 'sa';

    IF l_case_objid IS NOT NULL THEN

    --Close ticket procedure call
     clarify_case_pkg.close_case(p_case_objid  =>  l_case_objid       ,
                                 p_user_objid  =>  l_user_objid       ,
                                 p_source      =>  NULL               ,
                                 p_resolution  =>  NULL               ,
                                 p_status      =>  NULL               ,
                                 p_error_no    =>  o_err_code         ,
                                 p_error_str   =>  o_err_msg
                                 );

    END IF;

   --Exception Handling for Main Section
   EXCEPTION
   WHEN OTHERS THEN
         o_err_code := -1;
         o_err_msg  := 'IVR_PORT_CLOSE_TKT_PRC:  '||substr(sqlerrm,1,100);
         sa.util_pkg.insert_error_tab (i_action       => 'Port Close Ticket'       ,
                                       i_key          => i_esn                     ,
                                       i_program_name => 'ivr_port_close_tkt_prc'  ,
                                       i_error_text   => o_err_msg
                                       );

END ivr_port_close_tkt_prc;

-- page plus port in case creation
PROCEDURE pageplus_port_in_case (i_esn                  in  VARCHAR2 ,
                                 i_min                  in  VARCHAR2 ,
                                 i_iccid                in  VARCHAR2 ,
                                 i_port_in_date         in  DATE     ,
                                 i_port_in_carrier_from in  VARCHAR2 ,
                                 i_rate_plan            in  VARCHAR2 ,
                                 o_error_code           out NUMBER   ,
                                 o_error_message        out VARCHAR2
                                   )
IS
  --
  l_new_case_objid         NUMBER         := 0;
  l_new_condition_objid    NUMBER         := 0;
  l_new_act_entry_objid    NUMBER         := 0;
  l_new_case_id            NUMBER         := NULL;
  l_new_case_id_format     VARCHAR2( 20 ) := NULL;
  l_carrier                VARCHAR2(200)  ;

BEGIN
  --
  IF i_esn IS NULL  and i_min IS NULL THEN
    o_error_code    := 1;
    o_error_message := 'ESN AND MIN ARE MANDATORY';
    RETURN;
  END IF;

  -- case id sequence
  sa.next_id( 'Case ID', l_new_case_id, l_new_case_id_format );

  l_new_case_objid         := seq('case' );
  l_new_condition_objid    := seq('condition' );
  l_new_act_entry_objid    := seq('act_entry' );

  -- table_condition
  INSERT INTO sa.table_condition( objid,
                                  condition,
                                  title,
                                  s_title,
                                  wipbin_time,
                                  sequence_num )
       VALUES  ( l_new_condition_objid,
                 4,
                 'Closed',
                 'CLOSED',
                 i_port_in_date,
                 0 );

   -- table_act_entry
  INSERT INTO sa.table_act_entry( objid,
                                  act_code,
                                  entry_time,
                                  addnl_info,
                                  act_entry2case,
                                  act_entry2user,
                                  entry_name2gbst_elm )
      VALUES  ( l_new_act_entry_objid,
                200,
                i_port_in_date,
                'Status = Closed, Resolution Code =Not Available, State = Open.',
                l_new_case_objid,
                268435556,
                268435623 );

     -- table_case

  INSERT INTO table_case( objid,
                          title,
                          s_title,
                          id_number,
                          x_case_type,
                          casests2gbst_elm,
                          case_type_lvl2,
                          case_type_lvl3,
                          customer_code,
                          creation_time,
                          case_owner2user,
                          case_originator2user,
                          x_esn,
                          x_min,
                          x_msid,
                          x_iccid,
                          x_carrier_name,
                          case_state2condition,
                          oper_system
                        )
      VALUES
               ( l_new_case_objid,                --objid,
                 'External',                      --title,
                 'EXTERNAL',                      --s_title,
                 l_new_case_id,                     --id_number,
                 'Port In',                       --x_case_type,
                 268435578,                       --casests2gbst_elm,
                 'PAGEPLUS',                      --case_type_lvl2,
                 'Port Successful',               --case_type_lvl3,
                 'PAGE_BATCH',                    --customer_code,
                 i_port_in_date,                  --creation_time,
                 268435556,                       --case_owner2user,
                 268435556,                       --case_originator2user,
                 i_esn                ,           --x_esn,
                 i_min,                           --x_min,
                 i_min,                           --x_msid,
                 NVL( i_iccid, null ),            --x_iccid,
                 'VERIZON PAGE',                  --x_carrier_name,
                 l_new_condition_objid,           --case_state2condition,
                 'Port Successful'                --oper_system
                 );

  -- table_x_case_detail for port in carrier
  INSERT INTO
         table_x_case_detail( objid,
                              x_name,
                              x_value,
                              detail2case )
  VALUES
         ( sa.seq( 'x_case_detail' ),
           'CURRENT_CARRIER',
           i_port_in_carrier_from,
           l_new_case_objid );

  INSERT INTO
         table_x_case_detail( objid,
                              x_name,
                              x_value,
                              detail2case )
  VALUES
         ( sa.seq( 'x_case_detail' ),
           'ASSIGNED_CARRIER',
           'VERIZON PAGE',
           l_new_case_objid );

  INSERT INTO
         table_x_case_detail( objid,
                              x_name,
                              x_value,
                              detail2case )
  VALUES
         ( sa.seq( 'x_case_detail' ),
           'RATE_PLAN',
           i_rate_plan,
           l_new_case_objid );


  o_error_code    := 0;
  o_error_message := 'SUCCESS';
  Commit;
EXCEPTION
  WHEN OTHERS THEN
  o_error_code    := 1;
  o_error_message := SQLERRM;

END pageplus_port_in_case;


END PORT_PKG;
/