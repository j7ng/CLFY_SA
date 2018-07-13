CREATE OR REPLACE PACKAGE BODY sa."SERVICE_PLAN"
AS
 --
 ---------------------------------------------------------------------------------------------
 --$RCSfile: SERVICE_PLAN_PKB.sql,v $
 --$Revision: 1.148 $
 --$Author: skambhammettu $
 --$Date: 2018/03/10 20:15:39 $
 --$ $Log: SERVICE_PLAN_PKB.sql,v $
 --$ Revision 1.148  2018/03/10 20:15:39  skambhammettu
 --$ Prod sync
 --$
 --$ Revision 1.147  2018/03/08 19:21:31  skambhammettu
 --$ change to not display warning message in retention_action_script for ADD_NOW_AR
 --$
 --$ Revision 1.137  2018/01/30 21:56:41  skambhammettu
 --$ New function get_vas_group_name
 --$
 --$ Revision 1.132  2018/01/16 20:44:00  abustos
 --$ CR55070 - Remove warning Flag for AddOn Plans, merge with prod
 --$
 --$ Revision 1.131  2018/01/10 00:08:13  sgangineni
 --$ CR52120 - New error code -205 in get_billing_part_num procedure
 --$
 --$ Revision 1.130  2018/01/09 21:03:14  sgangineni
 --$ CR48260 - Merged with latest PROD version
 --$
 --$ Revision 1.124  2017/12/22 14:57:58  skambhammettu
 --$ cust_profile_script in service_plan_info
 --$
 --$ Revision 1.123  2017/12/20 20:43:40  skambhammettu
 --$ CR54358
 --$
 --$ Revision 1.121  2017/12/06 21:41:06  skambhammettu
 --$ CR53217--change in retention_action_script
 --$
 --$ Revision 1.118  2017/11/13 19:33:36  sinturi
 --$ Added condition
 --$
 --$ Revision 1.96  2017/10/02 16:02:43  mshah
 --$ CR53297 -  WEB TF showing wrong amount of benefits in airtime summary page.
 --$
 --$ Revision 1.86  2017/08/28 19:14:08  tpathare
 --$ Pricing issue fix.
 --$
 --$ Revision 1.85  2017/08/21 22:35:13  sraman
 --$ overloaded the proc SP_GET_PARTNUM_SERVICE_PLAN
 --$
 --$ Revision 1.84  2017/08/08 21:50:18  vlaad
 --$ Added comments
 --$
 --$ Revision 1.74  2017/04/18 16:18:02  smeganathan
 --$ Merged with WFM production release
 --$
 --$ Revision 1.37 2015/09/02 15:57:00 sethiraj
 --$ CR35913: Changes to Get_Sp_Retention_Action_Script to add out parameter out_ret_warning_flag.
 --$
 --$ Revision 1.36 2015/08/31 19:07:00 sethiraj
 --$ CR35913: Changes to Get_Sp_Retention_Action_Script to add logic for PastDue ESN status for some more flows.
 --$
 --$ Revision 1.35 2015/08/27 16:32:00 sethiraj
 --$ CR35913: Changes to Get_Sp_Retention_Action_Script to add logic for PastDue ESN status
 --$
 --$ Revision 1.34 2015/07/10 10:00:00 sethiraj
 --$ CR35913: New PROCEDURE Get_Sp_Retention_Action_Script
 --$
 --$ Revision 1.33 2014/04/28 09:15:00 adasgupta
 --$ CR26479 Cursor get_last_task_curs in sp_get_carrier_features
 --$ enhanced to avoid duplicates .
 --$ Revision 1.32 2013/09/05 23:32:51 akuthadi
 --$ TF to send the plan id as the o/p
 --$
 --$ Revision 1.31 2013/08/30 20:36:51 akuthadi
 --$ Accomodate TF scenarios in get_sp_retention_action
 --$
 --$ Revision 1.30 2013/08/22 16:54:09 akuthadi
 --$ CR12995, ST RT3 included VAS logic
 --$
 --$ Revision 1.29 2013/08/16 15:48:50 akuthadi
 --$ New error validations
 --$
 --$ Revision 1.28 2013/07/31 14:00:56 akuthadi
 --$ 1. New FUNCTION get_service_plan_by_esn
 --$ 2. New PROCEDURE get_sp_retention_action
 --$
 --$ Revision 1.27 2012/07/30 19:57:45 icanavan
 --$ TELCEL modified cursors and logic to use org_flow from table_bus_org
 --$
 --$ Revision 1.26 2012/04/13 20:35:21 mmunoz
 --$ CR15547 Changes in GET_SERVICE_PLAN_PRC to improve the response when some data is missing and to return as much data as possible.
 --$
 --$ Revision 1.25 2011/12/09 21:23:54 mmunoz
 --$ Added output parameter: part_number in procedure GET_SERVICE_PLAN_PRC
 --$
 --$ Revision 1.24 2011/12/05 15:05:49 mmunoz
 --$ GET_SERVICE_PLAN_PRC modified to add in the Forecast Date the days associated with the pin card in queue and take out this days to Service End Date
 --$
 --$ Revision 1.23 2011/11/30 16:12:53 mmunoz
 --$ Modified GET_SERVICE_PLAN_PRC to add in the Service End Date the days associated with the pin card in queue
 --$
 --$ Revision 1.22 2011/11/29 20:03:00 kacosta
 --$ CR18794 Core Rate Plan Engine Enhancement
 --$
 --$ Revision 1.20 2011/11/15 15:16:13 kacosta
 --$ CR18794 Core Rate Plan Engine Enhancement
 --$
 --$ Revision 1.19 2011/11/03 21:24:00 mmunoz
 --$ GET_SERVICE_PLAN_PRC modified to check payment status ACTIVE when return op_CreditCardReg
 --$
 --$ Revision 1.18 2011/10/27 16:05:29 mmunoz
 --$ Merge changes related with CR16317 with the last code release.
 --$
 --$ Revision 1.17 2011/10/20 17:10:51 kacosta
 --$ CR16987 Add Rate Plan to Port In Cases
 --$
 --$ Revision 1.16 2011/10/17 18:55:41 kacosta
 --$ CR16987 Add Rate Plan to Port In Cases
 --$
 --$ Revision 1.10 2011/09/12 18:17:04 kacosta
 --$ CR14427 exception table for Net10
 --$
 --$ Revision 1.9 2011/08/29 19:41:23 mmunoz
 --$ CR17202 Merge with lastest release (08/29/2011)
 --$
 --$ Revision 1.5 2011/07/14 18:50:23 kacosta
 --$ 16920 T-Mo Port Admin Tool Null Exception error
 --$ Removed SP_GET_ESN_RATE_PLAN procedure by mistake. Added procedure back
 --$
 --$ Revision 1.4 2011/07/05 20:36:18 kacosta
 --$ CR16470 - Create get_rate_plan Function
 --$ Made sure a NULL is not passed as p_template when calling igate.sf_get_carr_feat
 --$
 --$ Revision 1.3 2011/06/30 14:26:59 kacosta
 --$ CR16470 - Create get_rate_plan Function
 --$ Added functions to retreive the switch base rate
 --$
 --$ Revision 1.2 2011/06/07 14:41:23 kacosta
 --$ CR16470 - Create get_rate_plan Function
 --$
 --$
 ---------------------------------------------------------------------------------------------
 --
 -- Private Package Variables
 --
 TYPE get_carrier_features_curs_type
IS
 REF
 CURSOR
 RETURN table_x_carrier_features%ROWTYPE;
 --
 l_cv_package_name CONSTANT VARCHAR2(30) := 'SA.service_plan';
 --
 -- Private Procedures
 --
 --********************************************************************************
 -- Procedure to retreive the carrier features objid
 -- Created for CR16470
 -- Re-written for CR18794
 --********************************************************************************
 --
 PROCEDURE sp_get_carrier_features(
 p_esn IN table_part_inst.part_serial_no%TYPE ,
 p_site_part_objid IN table_site_part.objid%TYPE ,
 p_get_carrier_features_curs OUT get_carrier_features_curs_type ,
 p_error_code OUT INTEGER ,
 p_error_message OUT VARCHAR2 )
 AS
 --
 -- Cursors
 --
 CURSOR get_template_curs(c_i_trans_profile_objid table_x_trans_profile.objid%TYPE)
 IS
 SELECT x_d_trans_template template
 FROM table_x_trans_profile
 WHERE objid = c_i_trans_profile_objid;
 --
 CURSOR get_order_type_trans_prfl_curs(c_i_order_type_objid table_x_order_type.objid%TYPE)
 IS
 SELECT x_order_type2x_trans_profile trans_profile_objid
 FROM table_x_order_type
 WHERE objid = c_i_order_type_objid;
 --
 CURSOR get_last_task_curs(c_site_part_objid table_x_call_trans.call_trans2site_part%TYPE)
 IS
 --- CR26479 adasgupta-- cursor changed as per suggestion from Curt
 --- get latest rate plan
 SELECT t.objid task_objid,
 ct.x_transact_date,
 t.start_date
 FROM table_x_call_trans ct,
 table_task t,
 gw1.ig_transaction ig
 WHERE 1 =1
 AND ct.call_trans2site_part = c_site_part_objid
 AND t.x_task2x_call_trans = ct.objid
 AND ig.action_item_id = t.task_id
 AND ig.order_type IN
 (SELECT txp.x_param_value
 FROM table_x_parameters txp
 WHERE txp.x_param_name = 'RATE_PLAN_HISTORY'
 AND txp.x_param_value NOT IN ('S','D')
 )
 ORDER BY ct.x_transact_date DESC,
 t.start_date DESC ;
 --- CR26479 -- adasgupta end
 --
 CURSOR get_part_class_data_speed_curs(c_esn table_part_inst.part_serial_no%TYPE)
 IS
 SELECT TO_NUMBER(param_value) data_speed
 FROM table_part_inst tpi
 JOIN table_mod_level tml
 ON tpi.n_part_inst2part_mod = tml.objid
 JOIN table_part_num tpn
 ON tml.part_info2part_num = tpn.objid
 JOIN table_part_class tpc
 ON tpn.part_num2part_class = tpc.objid
 JOIN pc_params_view ppv
 ON tpc.name = ppv.part_class
 WHERE tpi.part_serial_no = c_esn
 AND ppv.param_name = 'DATA_SPEED';
 --
 CURSOR get_default_carrier_fetrs_curs ( c_carrier_objid table_x_carrier_features.x_feature2x_carrier%TYPE ,c_technology table_x_carrier_features.x_technology%TYPE ,c_data_capable table_x_carrier_features.x_data%TYPE ,c_bus_org_objid table_x_carrier_features.x_features2bus_org%TYPE )
 IS
 SELECT xcf.objid carrier_features_objid
 FROM table_x_carrier_features xcf
 WHERE xcf.x_feature2x_carrier = c_carrier_objid
 AND xcf.x_technology = c_technology
 AND xcf.x_data = c_data_capable
 AND NVL(xcf.x_features2bus_org ,-1) = NVL(c_bus_org_objid ,-1);
 --
 CURSOR get_esn_info_primary_curs(c_v_esn table_part_inst.part_serial_no%TYPE)
 IS
 SELECT DISTINCT tpi_esn.part_serial_no esn ,
 tpn.x_technology technology ,
 tpn.x_data_capable data_capable ,
 tbo.org_id brand ,
 tbo.objid bus_org_objid
 --CR20451 | CR20854: Add TELCEL Brand
 ,
 tbo.org_flow org_flow ,
 tpi_esn.x_part_inst2site_part site_part_objid ,
 tpi_min.part_inst2carrier_mkt carrier_objid ,
 tpi_min.part_serial_no MIN
 FROM table_part_inst tpi_esn
 JOIN table_mod_level tml
 ON tpi_esn.n_part_inst2part_mod = tml.objid
 JOIN table_part_num tpn
 ON tml.part_info2part_num = tpn.objid
 JOIN table_bus_org tbo
 ON tpn.part_num2bus_org = tbo.objid
 JOIN table_site_part tsp
 ON tpi_esn.part_serial_no = tsp.x_service_id
 JOIN table_part_inst tpi_min
 ON tsp.x_min = tpi_min.part_serial_no
 WHERE tpi_esn.part_serial_no = c_v_esn
 AND tpi_esn.x_domain = 'PHONES'
 AND tsp.part_status IN ('Active' ,'CarrierPending')
 AND tpi_min.x_domain = 'LINES';
 --
 CURSOR get_esn_info_secondary_curs(c_v_esn table_part_inst.part_serial_no%TYPE)
 IS
 SELECT DISTINCT tpi_esn.part_serial_no esn ,
 tpn.x_technology technology ,
 tpn.x_data_capable data_capable ,
 tbo.org_id brand ,
 tbo.objid bus_org_objid
 --CR20451 | CR20854: Add TELCEL Brand
 ,
 tbo.org_flow org_flow ,
 tpi_esn.x_part_inst2site_part site_part_objid ,
 tpi_min.part_inst2carrier_mkt carrier_objid ,
 tpi_min.part_serial_no MIN
 FROM table_part_inst tpi_esn
 JOIN table_mod_level tml
 ON tpi_esn.n_part_inst2part_mod = tml.objid
 JOIN table_part_num tpn
 ON tml.part_info2part_num = tpn.objid
 JOIN table_bus_org tbo
 ON tpn.part_num2bus_org = tbo.objid
 JOIN table_site_part tsp
 ON tpi_esn.x_part_inst2site_part = tsp.objid
 JOIN table_part_inst tpi_min
 ON tsp.x_min = tpi_min.part_serial_no
 WHERE tpi_esn.part_serial_no = c_v_esn
 AND tpi_esn.x_domain = 'PHONES'
 AND tpi_min.x_domain = 'LINES';
 --
 CURSOR get_esn_info_thirdly_curs(c_v_esn table_part_inst.part_serial_no%TYPE)
 IS
 SELECT DISTINCT tpi_esn.part_serial_no esn ,
 tpn.x_technology technology ,
 tpn.x_data_capable data_capable ,
 tbo.org_id brand ,
 tbo.objid bus_org_objid
 --CR20451 | CR20854: Add TELCEL Brand
 ,
 tbo.org_flow org_flow ,
 tsp.objid site_part_objid ,
 tpi_min.part_inst2carrier_mkt carrier_objid ,
 tpi_min.part_serial_no MIN
 FROM table_part_inst tpi_esn
 JOIN table_mod_level tml
 ON tpi_esn.n_part_inst2part_mod = tml.objid
 JOIN table_part_num tpn
 ON tml.part_info2part_num = tpn.objid
 JOIN table_bus_org tbo
 ON tpn.part_num2bus_org = tbo.objid
 JOIN table_site_part tsp
 ON tpi_esn.part_serial_no = tsp.x_service_id
 JOIN table_part_inst tpi_min
 ON tsp.x_min = tpi_min.part_serial_no
 WHERE tpi_esn.part_serial_no = c_v_esn
 AND tpi_esn.x_domain = 'PHONES'
 AND tsp.install_date =
 (SELECT MAX(tsp_max.install_date)
 FROM table_site_part tsp_max
 WHERE tsp_max.x_service_id = tpi_esn.part_serial_no
 )
 AND tpi_min.x_domain = 'LINES';
 --
 CURSOR get_site_part_esn_info_curs(c_i_site_part_objid table_site_part.objid%TYPE)
 IS
 SELECT DISTINCT tpi_esn.part_serial_no esn ,
 tpn.x_technology technology ,
 tpn.x_data_capable data_capable ,
 tbo.org_id brand ,
 tbo.objid bus_org_objid
 --CR20451 | CR20854: Add TELCEL Brand
 ,
 tbo.org_flow org_flow ,
 tsp.objid site_part_objid ,
 tpi_min.part_inst2carrier_mkt carrier_objid ,
 tpi_min.part_serial_no MIN
 FROM table_site_part tsp
 JOIN table_part_inst tpi_esn
 ON tsp.x_service_id = tpi_esn.part_serial_no
 JOIN table_mod_level tml
 ON tpi_esn.n_part_inst2part_mod = tml.objid
 JOIN table_part_num tpn
 ON tml.part_info2part_num = tpn.objid
 JOIN table_bus_org tbo
 ON tpn.part_num2bus_org = tbo.objid
 JOIN table_part_inst tpi_min
 ON tsp.x_min = tpi_min.part_serial_no
 WHERE tsp.objid = c_i_site_part_objid
 AND tpi_esn.x_domain = 'PHONES'
 AND tpi_min.x_domain = 'LINES';
 --
 -- Variables
 --
 l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.sp_get_carrier_features';
 l_ex_business_error EXCEPTION;
 get_carrier_features_curs get_carrier_features_curs_type;
 l_i_error_code INTEGER := 0;
 l_i_order_type_objid table_x_order_type.objid%TYPE;
 l_n_carrier_features_objid table_x_carrier_features.objid%TYPE;
 get_esn_info_rec get_esn_info_primary_curs%ROWTYPE;
 get_template_rec get_template_curs%ROWTYPE;
 get_default_carrier_featrs_rec get_default_carrier_fetrs_curs%ROWTYPE;
 get_last_task_rec get_last_task_curs%ROWTYPE;
 get_part_class_data_speed_rec get_part_class_data_speed_curs%ROWTYPE;
 get_order_type_trans_prfl_rec get_order_type_trans_prfl_curs%ROWTYPE;
 --CR20451 | CR20854: Add TELCEL Brand
 -- l_v_is_straight_talk VARCHAR2(1) := '0';
 l_v_bus_org_flow_3 VARCHAR2(1) := '0';
 l_v_order_type gw1.ig_transaction.order_type%TYPE;
 l_v_error_message VARCHAR2(32767) := 'SUCCESS';
 l_v_position VARCHAR2(32767) := l_cv_subprogram_name || '.1';
 l_v_note VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
 --
 BEGIN
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_esn : ' || NVL(p_esn ,'Value is null'));
 dbms_output.put_line('p_site_part_objid: ' || NVL(TO_CHAR(p_site_part_objid) ,'Value is null'));
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.2';
 l_v_note := 'Validating input parameter values';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF (p_esn IS NULL AND p_site_part_objid IS NULL) THEN
 --
 l_i_error_code := -20020;
 l_v_error_message := 'Both input parameter value is null';
 --
 RAISE l_ex_business_error;
 --
 END IF;
 --
 IF (p_esn IS NOT NULL AND p_site_part_objid IS NOT NULL) THEN
 --
 l_i_error_code := -20021;
 l_v_error_message := 'One of the input parameter value must be null';
 --
 RAISE l_ex_business_error;
 --
 END IF;
 --
 IF (p_esn IS NOT NULL) THEN
 --
 l_v_position := l_cv_subprogram_name || '.3';
 l_v_note := 'Retrieve ESN information; get_esn_info_primary_curs cursor';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF get_esn_info_primary_curs%ISOPEN THEN
 --
 CLOSE get_esn_info_primary_curs;
 --
 END IF;
 --
 OPEN get_esn_info_primary_curs(c_v_esn => p_esn);
 FETCH get_esn_info_primary_curs INTO get_esn_info_rec;
 --
 IF get_esn_info_primary_curs%NOTFOUND THEN
 --
 l_v_position := l_cv_subprogram_name || '.4';
 l_v_note := 'Retrieve ESN information; get_esn_info_secondary_curs cursor';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF get_esn_info_secondary_curs%ISOPEN THEN
 --
 CLOSE get_esn_info_secondary_curs;
 --
 END IF;
 --
 OPEN get_esn_info_secondary_curs(c_v_esn => p_esn);
 FETCH get_esn_info_secondary_curs INTO get_esn_info_rec;
 --
 IF get_esn_info_secondary_curs%NOTFOUND THEN
 --
 CLOSE get_esn_info_secondary_curs;
 --
 l_v_position := l_cv_subprogram_name || '.5';
 l_v_note := 'Retrieve ESN information again; get_esn_info_thirdly_curs cursor';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF get_esn_info_thirdly_curs%ISOPEN THEN
 --
 CLOSE get_esn_info_thirdly_curs;
 --
 END IF;
 --
 OPEN get_esn_info_thirdly_curs(c_v_esn => p_esn);
 FETCH get_esn_info_thirdly_curs INTO get_esn_info_rec;
 --
 IF get_esn_info_thirdly_curs%NOTFOUND THEN
 --
 CLOSE get_esn_info_thirdly_curs;
 --
 l_v_error_message := 'No ESN information found for the ESN: ' || p_esn;
 --
 RAISE l_ex_business_error;
 --
 ELSE
 --
 CLOSE get_esn_info_thirdly_curs;
 --
 END IF;
 --
 ELSE
 --
 CLOSE get_esn_info_secondary_curs;
 --
 END IF;
 --
 ELSE
 --
 CLOSE get_esn_info_primary_curs;
 --
 END IF;
 --
 ELSE
 --
 l_v_position := l_cv_subprogram_name || '.6';
 l_v_note := 'Retrieve site part ESN information; get_site_part_esn_info_curs cursor';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF get_site_part_esn_info_curs%ISOPEN THEN
 --
 CLOSE get_site_part_esn_info_curs;
 --
 END IF;
 --
 OPEN get_site_part_esn_info_curs(c_i_site_part_objid => p_site_part_objid);
 FETCH get_site_part_esn_info_curs INTO get_esn_info_rec;
 --
 IF get_site_part_esn_info_curs%NOTFOUND THEN
 --
 CLOSE get_site_part_esn_info_curs;
 --
 l_v_error_message := 'No ESN information found for the site part: ' || TO_CHAR(p_site_part_objid);
 --
 RAISE l_ex_business_error;
 --
 ELSE
 --
 CLOSE get_site_part_esn_info_curs;
 --
 END IF;
 --
 END IF;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line('ESN information');
 dbms_output.put_line('esn : ' || NVL(get_esn_info_rec.esn ,'Value is null'));
 dbms_output.put_line('technology : ' || NVL(get_esn_info_rec.technology ,'Value is null'));
 dbms_output.put_line('data_capable : ' || NVL(TO_CHAR(get_esn_info_rec.data_capable) ,'Value is null'));
 dbms_output.put_line('brand : ' || NVL(get_esn_info_rec.brand ,'Value is null'));
 dbms_output.put_line('bus_org_objid : ' || NVL(TO_CHAR(get_esn_info_rec.bus_org_objid) ,'Value is null'));
 dbms_output.put_line('site_part_objid: ' || NVL(TO_CHAR(get_esn_info_rec.site_part_objid) ,'Value is null'));
 dbms_output.put_line('carrier_objid : ' || NVL(TO_CHAR(get_esn_info_rec.carrier_objid) ,'Value is null'));
 dbms_output.put_line('min : ' || NVL(get_esn_info_rec.min ,'Value is null'));
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.7';
 l_v_note := 'Get last task objid for site part objid';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF get_last_task_curs%ISOPEN THEN
 --
 CLOSE get_last_task_curs;
 --
 END IF;
 --
 OPEN get_last_task_curs(c_site_part_objid => get_esn_info_rec.site_part_objid);
 FETCH get_last_task_curs INTO get_last_task_rec;
 CLOSE get_last_task_curs;
 --
 l_v_position := l_cv_subprogram_name || '.8';
 l_v_note := 'Check if last task objid for site part objid was found';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF (get_last_task_rec.task_objid IS NOT NULL) THEN
 --
 l_v_position := l_cv_subprogram_name || '.10';
 l_v_note := 'Yes, last task objid for site part objid was found; Get last task order type';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 l_v_order_type := sf_get_ig_order_type(p_programme_name => 'SP_INSERT_IG_TRANSACTION' ,p_action_item_objid => get_last_task_rec.task_objid ,p_order_type => NULL);
 --
 ELSE
 --
 l_v_position := l_cv_subprogram_name || '.11';
 l_v_note := 'No, last task objid for site part objid was found; set order type to R (rate plan change)';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 l_v_order_type := 'R';
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.12';
 l_v_note := 'Get remaing values to call igate.sf_get_carr_feat';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 --CR20451 | CR20854: Add TELCEL Brand
 --IF (get_esn_info_rec.brand = 'STRAIGHT_TALK') THEN
 --
 -- l_v_is_straight_talk := '1';
 IF (get_esn_info_rec.org_flow = '3') THEN
 l_v_bus_org_flow_3 := '1';
 END IF;
 --
 --CR20451 | CR20854: Add TELCEL Brand
 --IF (get_esn_info_rec.brand = 'STRAIGHT_TALK' AND get_esn_info_rec.technology = 'CDMA') THEN
 --
 IF (get_esn_info_rec.org_flow = '3' AND get_esn_info_rec.technology = 'CDMA') THEN
 l_v_position := l_cv_subprogram_name || '.13';
 l_v_note := 'Get order type objid';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 igate.sp_get_ordertype(p_min => get_esn_info_rec.min ,p_order_type => l_v_order_type ,p_carrier_objid => get_esn_info_rec.carrier_objid ,p_technology => get_esn_info_rec.technology ,p_order_type_objid => l_i_order_type_objid);
 --
 IF get_order_type_trans_prfl_curs%ISOPEN THEN
 --
 CLOSE get_order_type_trans_prfl_curs;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.14';
 l_v_note := 'Get order type trans profile objid';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 OPEN get_order_type_trans_prfl_curs(c_i_order_type_objid => l_i_order_type_objid);
 FETCH get_order_type_trans_prfl_curs INTO get_order_type_trans_prfl_rec;
 --
 l_v_position := l_cv_subprogram_name || '.15';
 l_v_note := 'Get template';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF get_template_curs%ISOPEN THEN
 --
 CLOSE get_template_curs;
 --
 END IF;
 --
 OPEN get_template_curs(c_i_trans_profile_objid => get_order_type_trans_prfl_rec.trans_profile_objid);
 FETCH get_template_curs INTO get_template_rec;
 CLOSE get_template_curs;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.16';
 l_v_note := 'Calling igate.sf_get_carr_feat';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 l_n_carrier_features_objid := igate.sf_get_carr_feat(p_order_type => l_v_order_type
 -- CR20451 | CR20854: Add TELCEL Brand
 --,p_st_esn_flag => l_v_is_straight_talk
 ,p_st_esn_flag => l_v_bus_org_flow_3 ,p_site_part_objid => get_esn_info_rec.site_part_objid ,p_esn => get_esn_info_rec.esn ,p_carrier_objid => get_esn_info_rec.carrier_objid ,p_carr_feature_objid => NULL ,p_data_capable => TO_CHAR(get_esn_info_rec.data_capable) ,p_template => NVL(get_template_rec.template ,'NOT SUREPAY'));
 --
 l_v_position := l_cv_subprogram_name || '.17';
 l_v_note := 'Check if carrier features objid was found on based igate.sf_get_carr_feat function';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF (l_n_carrier_features_objid IS NULL) THEN
 --
 l_v_position := l_cv_subprogram_name || '.18';
 l_v_note := 'No, carrier features objid was not found';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.19';
 l_v_note := 'Determine ESN part class data speed';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF get_part_class_data_speed_curs%ISOPEN THEN
 --
 CLOSE get_part_class_data_speed_curs;
 --
 END IF;
 --
 OPEN get_part_class_data_speed_curs(c_esn => get_esn_info_rec.esn);
 FETCH get_part_class_data_speed_curs INTO get_part_class_data_speed_rec;
 CLOSE get_part_class_data_speed_curs;
 --
 IF (get_part_class_data_speed_rec.data_speed IS NOT NULL) THEN
 --
 l_v_position := l_cv_subprogram_name || '.20';
 l_v_note := 'Get default carrier features objid based carrier, technology, data speed and business org objid';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF get_default_carrier_fetrs_curs%ISOPEN THEN
 --
 CLOSE get_default_carrier_fetrs_curs;
 --
 END IF;
 --
 OPEN get_default_carrier_fetrs_curs(c_carrier_objid => get_esn_info_rec.carrier_objid ,c_technology => get_esn_info_rec.technology ,c_data_capable => get_part_class_data_speed_rec.data_speed ,c_bus_org_objid => get_esn_info_rec.bus_org_objid);
 FETCH get_default_carrier_fetrs_curs INTO get_default_carrier_featrs_rec;
 CLOSE get_default_carrier_fetrs_curs;
 --
 l_n_carrier_features_objid := get_default_carrier_featrs_rec.carrier_features_objid;
 --
 END IF;
 --
 IF (l_n_carrier_features_objid IS NULL) THEN
 --
 l_v_position := l_cv_subprogram_name || '.21';
 l_v_note := 'No, default carrier features objid based carrier, technology, data speed and business org objid';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.22';
 l_v_note := 'Get default carrier features objid based carrier, technology, data capable and business org objid';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF get_default_carrier_fetrs_curs%ISOPEN THEN
 --
 CLOSE get_default_carrier_fetrs_curs;
 --
 END IF;
 --
 OPEN get_default_carrier_fetrs_curs(c_carrier_objid => get_esn_info_rec.carrier_objid ,c_technology => get_esn_info_rec.technology ,c_data_capable => get_esn_info_rec.data_capable ,c_bus_org_objid => get_esn_info_rec.bus_org_objid);
 FETCH get_default_carrier_fetrs_curs INTO get_default_carrier_featrs_rec;
 CLOSE get_default_carrier_fetrs_curs;
 --
 l_n_carrier_features_objid := get_default_carrier_featrs_rec.carrier_features_objid;
 --
 END IF;
 --
 END IF;
 --
 OPEN get_carrier_features_curs FOR SELECT xcf.* FROM table_x_carrier_features xcf WHERE xcf.objid = l_n_carrier_features_objid;
 --
 l_v_position := l_cv_subprogram_name || '.23';
 l_v_note := 'End executing ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 IF (l_n_carrier_features_objid IS NOT NULL) THEN
 --
 dbms_output.put_line('p_get_carrier_features_curs: ' || 'Carrier Features found');
 --
 ELSE
 --
 dbms_output.put_line('p_get_carrier_features_curs: ' || 'Carrier Features not found');
 --
 END IF;
 --
 dbms_output.put_line('p_error_code : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
 dbms_output.put_line('p_error_message : ' || NVL(l_v_error_message ,'Value is null'));
 --
 END IF;
 --
 p_get_carrier_features_curs := get_carrier_features_curs;
 p_error_code := l_i_error_code;
 p_error_message := l_v_error_message;
 --
 EXCEPTION
 WHEN l_ex_business_error THEN
 --
 p_get_carrier_features_curs := NULL;
 p_error_code := l_i_error_code;
 p_error_message := l_v_error_message;
 --
 l_v_position := l_cv_subprogram_name || '.24';
 l_v_note := 'End executing with Oracle error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_get_carrier_features_curs: ' || 'Carrier features not found');
 dbms_output.put_line('p_error_code : ' || NVL(TO_CHAR(p_error_code) ,'Value is null'));
 dbms_output.put_line('p_error_message : ' || NVL(p_error_message ,'Value is null'));
 --
 END IF;
 --
 IF get_last_task_curs%ISOPEN THEN
 --
 CLOSE get_last_task_curs;
 --
 END IF;
 --
 IF get_template_curs%ISOPEN THEN
 --
 CLOSE get_template_curs;
 --
 END IF;
 --
 IF get_last_task_curs%ISOPEN THEN
 --
 CLOSE get_last_task_curs;
 --
 END IF;
 --
 IF get_part_class_data_speed_curs%ISOPEN THEN
 --
 CLOSE get_part_class_data_speed_curs;
 --
 END IF;
 --
 IF get_default_carrier_fetrs_curs%ISOPEN THEN
 --
 CLOSE get_default_carrier_fetrs_curs;
 --
 END IF;
 --
 IF get_esn_info_primary_curs%ISOPEN THEN
 --
 CLOSE get_esn_info_primary_curs;
 --
 END IF;
 --
 IF get_esn_info_secondary_curs%ISOPEN THEN
 --
 CLOSE get_esn_info_secondary_curs;
 --
 END IF;
 --
 IF get_esn_info_thirdly_curs%ISOPEN THEN
 --
 CLOSE get_esn_info_thirdly_curs;
 --
 END IF;
 --
 IF get_site_part_esn_info_curs%ISOPEN THEN
 --
 CLOSE get_site_part_esn_info_curs;
 --
 END IF;
 --
 IF get_order_type_trans_prfl_curs%ISOPEN THEN
 --
 CLOSE get_order_type_trans_prfl_curs;
 --
 END IF;
 --
 IF get_template_curs%ISOPEN THEN
 --
 CLOSE get_template_curs;
 --
 END IF;
 --
 WHEN OTHERS THEN
 --
 p_get_carrier_features_curs := NULL;
 p_error_code := SQLCODE;
 p_error_message := SQLERRM;
 --
 l_v_position := l_cv_subprogram_name || '.25';
 l_v_note := 'End executing with Oracle error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_get_carrier_features_curs: ' || 'Carrier features not found');
 dbms_output.put_line('p_error_code : ' || NVL(TO_CHAR(p_error_code) ,'Value is null'));
 dbms_output.put_line('p_error_message : ' || NVL(p_error_message ,'Value is null'));
 --
 END IF;
 --
 ota_util_pkg.err_log(p_action => l_v_note ,p_error_date => SYSDATE ,p_key => p_esn ,p_program_name => l_v_position ,p_error_text => p_error_message);
 --
 IF get_last_task_curs%ISOPEN THEN
 --
 CLOSE get_last_task_curs;
 --
 END IF;
 --
 IF get_template_curs%ISOPEN THEN
 --
 CLOSE get_template_curs;
 --
 END IF;
 --
 IF get_last_task_curs%ISOPEN THEN
 --
 CLOSE get_last_task_curs;
 --
 END IF;
 --
 IF get_part_class_data_speed_curs%ISOPEN THEN
 --
 CLOSE get_part_class_data_speed_curs;
 --
 END IF;
 --
 IF get_default_carrier_fetrs_curs%ISOPEN THEN
 --
 CLOSE get_default_carrier_fetrs_curs;
 --
 END IF;
 --
 IF get_esn_info_primary_curs%ISOPEN THEN
 --
 CLOSE get_esn_info_primary_curs;
 --
 END IF;
 --
 IF get_esn_info_secondary_curs%ISOPEN THEN
 --
 CLOSE get_esn_info_secondary_curs;
 --
 END IF;
 --
 IF get_esn_info_thirdly_curs%ISOPEN THEN
 --
 CLOSE get_esn_info_thirdly_curs;
 --
 END IF;
 --
 IF get_site_part_esn_info_curs%ISOPEN THEN
 --
 CLOSE get_site_part_esn_info_curs;
 --
 END IF;
 --
 IF get_order_type_trans_prfl_curs%ISOPEN THEN
 --
 CLOSE get_order_type_trans_prfl_curs;
 --
 END IF;
 --
 IF get_template_curs%ISOPEN THEN
 --
 CLOSE get_template_curs;
 --
 END IF;
 --
 END sp_get_carrier_features;
 --
 -- Public Functions
 --
 --********************************************************************************
 -- Function will retrieve the rate plan for an ESN irrespective of status of ESN/MIN
 -- Written for CR16987
 -- Re-written for CR18794
 --********************************************************************************
 --
 FUNCTION f_get_esn_rate_plan_all_status(
 p_esn IN table_part_inst.part_serial_no%TYPE)
 RETURN table_x_carrier_features.x_rate_plan%TYPE
 AS
 --
 -- Function Variables
 --
 l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.f_get_esn_rate_plan_all_status';
 l_ex_business_error EXCEPTION;
 get_carrier_features_curs get_carrier_features_curs_type;
 l_i_error_code INTEGER := 0;
 get_carrier_features_rec get_carrier_features_curs%ROWTYPE;
 l_v_error_message VARCHAR2(32767) := 'SUCCESS';
 l_v_position VARCHAR2(32767) := l_cv_subprogram_name || '.1';
 l_v_note VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
 l_v_rate_plan table_x_carrier_features.x_rate_plan%TYPE;
 --
 BEGIN
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_esn: ' || NVL(p_esn ,'Value is null'));
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.2';
 l_v_note := 'Validating input parameter values';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF (p_esn IS NULL) THEN
 --
 l_i_error_code := -20009;
 l_v_error_message := 'ESN input parameter value must not be null';
 --
 RAISE l_ex_business_error;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.3';
 l_v_note := 'Calling sp_get_carrier_features procedure to retrieve the carrier features objid for the ESN';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 sp_get_carrier_features(p_esn => p_esn ,p_site_part_objid => NULL ,p_get_carrier_features_curs => get_carrier_features_curs ,p_error_code => l_i_error_code ,p_error_message => l_v_error_message);
 --
 IF (l_i_error_code <> 0) THEN
 --
 RAISE l_ex_business_error;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.4';
 l_v_note := 'Get rate plan based on carrier features objid for the ESN';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF get_carrier_features_curs%ISOPEN THEN
 --
 FETCH get_carrier_features_curs INTO get_carrier_features_rec;
 CLOSE get_carrier_features_curs;
 --
 l_v_rate_plan := get_carrier_features_rec.x_rate_plan;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.5';
 l_v_note := 'End executing ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_v_rate_plan: ' || NVL(l_v_rate_plan ,'Value is null'));
 --
 END IF;
 --
 RETURN l_v_rate_plan;
 --
 EXCEPTION
 WHEN l_ex_business_error THEN
 --
 l_v_position := l_cv_subprogram_name || '.6';
 l_v_note := 'End executing with business error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_i_error_code : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
 dbms_output.put_line('l_v_error_message: ' || NVL(l_v_error_message ,'Value is null'));
 --
 END IF;
 --
 IF get_carrier_features_curs%ISOPEN THEN
 --
 CLOSE get_carrier_features_curs;
 --
 END IF;
 --
 RETURN NULL;
 --
 WHEN OTHERS THEN
 --
 l_i_error_code := SQLCODE;
 l_v_error_message := SQLERRM;
 --
 l_v_position := l_cv_subprogram_name || '.7';
 l_v_note := 'End executing with Oracle error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_i_error_code : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
 dbms_output.put_line('l_v_error_message: ' || NVL(l_v_error_message ,'Value is null'));
 --
 END IF;
 --
 ota_util_pkg.err_log(p_action => l_v_note ,p_error_date => SYSDATE ,p_key => p_esn ,p_program_name => l_v_position ,p_error_text => l_v_error_message);
 --
 IF get_carrier_features_curs%ISOPEN THEN
 --
 CLOSE get_carrier_features_curs;
 --
 END IF;
 --
 RAISE;
 --
 END f_get_esn_rate_plan_all_status;
 --
 --********************************************************************************
 -- Function will retrieve the rate plan for an ESN
 -- Rewritten for CR16470
 -- Re-written for CR18794
 --********************************************************************************
 --
FUNCTION f_get_esn_rate_plan(
 p_esn IN table_part_inst.part_serial_no%TYPE)
 RETURN table_x_carrier_features.x_rate_plan%TYPE
AS
 --
 -- Function Variables
 --
 l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.f_get_esn_rate_plan';
 l_ex_business_error EXCEPTION;
 l_i_error_code INTEGER := 0;
 l_v_error_message VARCHAR2(32767) := 'SUCCESS';
 l_v_position VARCHAR2(32767) := l_cv_subprogram_name || '.1';
 l_v_note VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
 l_v_rate_plan table_x_carrier_features.x_rate_plan%TYPE;
 --
BEGIN
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_esn: ' || NVL(p_esn ,'Value is null'));
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.2';
 l_v_note := 'Validating input parameter values';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF (p_esn IS NULL) THEN
 --
 l_i_error_code := -20009;
 l_v_error_message := 'ESN input parameter value must not be null';
 --
 RAISE l_ex_business_error;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.3';
 l_v_note := 'Calling f_get_esn_rate_plan_all_status function';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 l_v_rate_plan := f_get_esn_rate_plan_all_status(p_esn => p_esn);
 --
 l_v_position := l_cv_subprogram_name || '.4';
 l_v_note := 'End executing ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_v_rate_plan: ' || NVL(l_v_rate_plan ,'Value is null'));
 --
 END IF;
 --
 RETURN l_v_rate_plan;
 --
EXCEPTION
WHEN l_ex_business_error THEN
 --
 l_v_position := l_cv_subprogram_name || '.5';
 l_v_note := 'End executing with business error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_i_error_code : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
 dbms_output.put_line('l_v_error_message: ' || NVL(l_v_error_message ,'Value is null'));
 --
 END IF;
 --
 RETURN NULL;
 --
WHEN OTHERS THEN
 --
 l_i_error_code := SQLCODE;
 l_v_error_message := SQLERRM;
 --
 l_v_position := l_cv_subprogram_name || '.6';
 l_v_note := 'End executing with Oracle error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_i_error_code : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
 dbms_output.put_line('l_v_error_message: ' || NVL(l_v_error_message ,'Value is null'));
 --
 END IF;
 --
 ota_util_pkg.err_log(p_action => l_v_note ,p_error_date => SYSDATE ,p_key => p_esn ,p_program_name => l_v_position ,p_error_text => l_v_error_message);
 --
 RAISE;
 --
END f_get_esn_rate_plan;
--
--********************************************************************************
-- Function will retrieve the switch base rate for an ESN
-- Created for CR16470
-- Re-written for CR18794
--********************************************************************************
--
FUNCTION f_get_esn_switch_base_rate(
 p_esn IN table_part_inst.part_serial_no%TYPE)
 RETURN table_x_carrier_features.x_switch_base_rate%TYPE
AS
 --
 -- Function Variables
 --
 l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.f_get_esn_switch_base_rate';
 l_ex_business_error EXCEPTION;
 get_carrier_features_curs get_carrier_features_curs_type;
 l_i_error_code INTEGER := 0;
 get_carrier_features_rec get_carrier_features_curs%ROWTYPE;
 l_v_error_message VARCHAR2(32767) := 'SUCCESS';
 l_v_position VARCHAR2(32767) := l_cv_subprogram_name || '.1';
 l_v_note VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
 l_v_switch_base_rate table_x_carrier_features.x_switch_base_rate%TYPE;
 --
BEGIN
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_esn: ' || NVL(p_esn ,'Value is null'));
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.2';
 l_v_note := 'Validating input parameter values';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF (p_esn IS NULL) THEN
 --
 l_i_error_code := -20009;
 l_v_error_message := 'ESN input parameter value must not be null';
 --
 RAISE l_ex_business_error;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.3';
 l_v_note := 'Calling sp_get_carrier_features procedure to retrieve the carrier features objid for the ESN';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 sp_get_carrier_features(p_esn => p_esn ,p_site_part_objid => NULL ,p_get_carrier_features_curs => get_carrier_features_curs ,p_error_code => l_i_error_code ,p_error_message => l_v_error_message);
 --
 IF (l_i_error_code <> 0) THEN
 --
 RAISE l_ex_business_error;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.4';
 l_v_note := 'Get switch base rate based on carrier features objid for the ESN';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF get_carrier_features_curs%ISOPEN THEN
 --
 FETCH get_carrier_features_curs INTO get_carrier_features_rec;
 CLOSE get_carrier_features_curs;
 --
 l_v_switch_base_rate := get_carrier_features_rec.x_switch_base_rate;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.5';
 l_v_note := 'End executing ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_v_switch_base_rate: ' || NVL(l_v_switch_base_rate ,'Value is null'));
 --
 END IF;
 --
 RETURN l_v_switch_base_rate;
 --
EXCEPTION
WHEN l_ex_business_error THEN
 --
 l_v_position := l_cv_subprogram_name || '.6';
 l_v_note := 'End executing with business error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_i_error_code : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
 dbms_output.put_line('l_v_error_message: ' || NVL(l_v_error_message ,'Value is null'));
 --
 END IF;
 --
 IF get_carrier_features_curs%ISOPEN THEN
 --
 CLOSE get_carrier_features_curs;
 --
 END IF;
 --
 RETURN NULL;
 --
WHEN OTHERS THEN
 --
 l_i_error_code := SQLCODE;
 l_v_error_message := SQLERRM;
 --
 l_v_position := l_cv_subprogram_name || '.7';
 l_v_note := 'End executing with Oracle error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_i_error_code : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
 dbms_output.put_line('l_v_error_message: ' || NVL(l_v_error_message ,'Value is null'));
 --
 END IF;
 --
 ota_util_pkg.err_log(p_action => l_v_note ,p_error_date => SYSDATE ,p_key => p_esn ,p_program_name => l_v_position ,p_error_text => l_v_error_message);
 --
 IF get_carrier_features_curs%ISOPEN THEN
 --
 CLOSE get_carrier_features_curs;
 --
 END IF;
 --
 RAISE;
 --
END f_get_esn_switch_base_rate;
--
--********************************************************************************
-- Function will retrieve the rate plan for a site part
-- Created for CR16470
-- Re-written for CR18794
--********************************************************************************
--
FUNCTION f_get_site_part_rate_plan(
 p_site_part_objid IN table_site_part.objid%TYPE)
 RETURN table_x_carrier_features.x_rate_plan%TYPE
AS
 --
 -- Function Variables
 --
 l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.f_get_site_part_rate_plan';
 l_ex_business_error EXCEPTION;
 get_carrier_features_curs get_carrier_features_curs_type;
 l_i_error_code INTEGER := 0;
 get_carrier_features_rec get_carrier_features_curs%ROWTYPE;
 l_v_error_message VARCHAR2(32767) := 'SUCCESS';
 l_v_position VARCHAR2(32767) := l_cv_subprogram_name || '.1';
 l_v_note VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
 l_v_rate_plan table_x_carrier_features.x_rate_plan%TYPE;
 --
BEGIN
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_site_part_objid: ' || NVL(TO_CHAR(p_site_part_objid) ,'Value is null'));
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.2';
 l_v_note := 'Validating input parameter values';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF (p_site_part_objid IS NULL) THEN
 --
 l_i_error_code := -20012;
 l_v_error_message := 'Site part OBJID input parameter value must not be null';
 --
 RAISE l_ex_business_error;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.3';
 l_v_note := 'Calling sp_get_carrier_features procedure to retrieve the carrier features objid for the ESN';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 sp_get_carrier_features(p_esn => NULL ,p_site_part_objid => p_site_part_objid ,p_get_carrier_features_curs => get_carrier_features_curs ,p_error_code => l_i_error_code ,p_error_message => l_v_error_message);
 --
 IF (l_i_error_code <> 0) THEN
 --
 RAISE l_ex_business_error;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.4';
 l_v_note := 'Get rate plan based on carrier features objid for the ESN';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF get_carrier_features_curs%ISOPEN THEN
 --
 FETCH get_carrier_features_curs INTO get_carrier_features_rec;
 CLOSE get_carrier_features_curs;
 --
 l_v_rate_plan := get_carrier_features_rec.x_rate_plan;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.5';
 l_v_note := 'End executing ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_v_rate_plan: ' || NVL(l_v_rate_plan ,'Value is null'));
 --
 END IF;
 --
 RETURN l_v_rate_plan;
 --
EXCEPTION
WHEN l_ex_business_error THEN
 --
 l_v_position := l_cv_subprogram_name || '.6';
 l_v_note := 'End executing with business error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_i_error_code : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
 dbms_output.put_line('l_v_error_message: ' || NVL(l_v_error_message ,'Value is null'));
 --
 END IF;
 --
 IF get_carrier_features_curs%ISOPEN THEN
 --
 CLOSE get_carrier_features_curs;
 --
 END IF;
 --
 RETURN NULL;
 --
WHEN OTHERS THEN
 --
 l_i_error_code := SQLCODE;
 l_v_error_message := SQLERRM;
 --
 l_v_position := l_cv_subprogram_name || '.7';
 l_v_note := 'End executing with Oracle error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_i_error_code : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
 dbms_output.put_line('l_v_error_message: ' || NVL(l_v_error_message ,'Value is null'));
 --
 END IF;
 --
 ota_util_pkg.err_log(p_action => l_v_note ,p_error_date => SYSDATE ,p_key => TO_CHAR(p_site_part_objid) ,p_program_name => l_v_position ,p_error_text => l_v_error_message);
 --
 IF get_carrier_features_curs%ISOPEN THEN
 --
 CLOSE get_carrier_features_curs;
 --
 END IF;
 --
 RAISE;
 --
END f_get_site_part_rate_plan;
--
--********************************************************************************
-- Function will retrieve the rate plan for a site part
-- Created for CR16470
-- Re-written for CR18794
--********************************************************************************
--
FUNCTION f_get_site_part_switch_base_rt(
 p_site_part_objid IN table_site_part.objid%TYPE)
 RETURN table_x_carrier_features.x_switch_base_rate%TYPE
AS
 --
 -- Function Variables
 --
 l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.f_get_site_part_switch_base_rt';
 l_ex_business_error EXCEPTION;
 get_carrier_features_curs get_carrier_features_curs_type;
 l_i_error_code INTEGER := 0;
 get_carrier_features_rec get_carrier_features_curs%ROWTYPE;
 l_v_error_message VARCHAR2(32767) := 'SUCCESS';
 l_v_position VARCHAR2(32767) := l_cv_subprogram_name || '.1';
 l_v_note VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
 l_v_switch_base_rate table_x_carrier_features.x_switch_base_rate%TYPE;
 --
BEGIN
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_site_part_objid: ' || NVL(TO_CHAR(p_site_part_objid) ,'Value is null'));
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.2';
 l_v_note := 'Validating input parameter values';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF (p_site_part_objid IS NULL) THEN
 --
 l_i_error_code := -20012;
 l_v_error_message := 'Site part OBJID input parameter value must not be null';
 --
 RAISE l_ex_business_error;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.3';
 l_v_note := 'Calling sp_get_carrier_features procedure to retrieve the carrier features objid for the ESN';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 sp_get_carrier_features(p_esn => NULL ,p_site_part_objid => p_site_part_objid ,p_get_carrier_features_curs => get_carrier_features_curs ,p_error_code => l_i_error_code ,p_error_message => l_v_error_message);
 --
 IF (l_i_error_code <> 0) THEN
 --
 RAISE l_ex_business_error;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.4';
 l_v_note := 'Get rate plan based on carrier features objid for the ESN';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 IF get_carrier_features_curs%ISOPEN THEN
 --
 FETCH get_carrier_features_curs INTO get_carrier_features_rec;
 CLOSE get_carrier_features_curs;
 --
 l_v_switch_base_rate := get_carrier_features_rec.x_switch_base_rate;
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.5';
 l_v_note := 'End executing ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_v_switch_base_rate: ' || NVL(l_v_switch_base_rate ,'Value is null'));
 --
 END IF;
 --
 RETURN l_v_switch_base_rate;
 --
EXCEPTION
WHEN l_ex_business_error THEN
 --
 l_v_position := l_cv_subprogram_name || '.6';
 l_v_note := 'End executing with business error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_i_error_code : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
 dbms_output.put_line('l_v_error_message: ' || NVL(l_v_error_message ,'Value is null'));
 --
 END IF;
 --
 IF get_carrier_features_curs%ISOPEN THEN
 --
 CLOSE get_carrier_features_curs;
 --
 END IF;
 --
 RETURN NULL;
 --
WHEN OTHERS THEN
 --
 l_i_error_code := SQLCODE;
 l_v_error_message := SQLERRM;
 --
 l_v_position := l_cv_subprogram_name || '.7';
 l_v_note := 'End executing with Oracle error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('l_i_error_code : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
 dbms_output.put_line('l_v_error_message: ' || NVL(l_v_error_message ,'Value is null'));
 --
 END IF;
 --
 ota_util_pkg.err_log(p_action => l_v_note ,p_error_date => SYSDATE ,p_key => TO_CHAR(p_site_part_objid) ,p_program_name => l_v_position ,p_error_text => l_v_error_message);
 --
 IF get_carrier_features_curs%ISOPEN THEN
 --
 CLOSE get_carrier_features_curs;
 --
 END IF;
 --
 RAISE;
 --
END f_get_site_part_switch_base_rt;
--
-- Public Procedures
--
--********************************************************************************
-- Wrapper procedure will retrieve the rate plan for an ESN
--********************************************************************************
--
PROCEDURE sp_get_esn_rate_plan(
 p_esn IN table_part_inst.part_serial_no%TYPE ,
 p_rate_plan OUT table_x_carrier_features.x_rate_plan%TYPE ,
 p_error_code OUT INTEGER ,
 p_error_message OUT VARCHAR2 )
IS
 --
 l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.sp_get_esn_rate_plan';
 l_i_error_code INTEGER := 0;
 l_v_error_message VARCHAR2(32767) := 'SUCCESS';
 l_v_position VARCHAR2(32767) := l_cv_subprogram_name || '.1';
 l_v_note VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
 l_v_rate_plan table_x_carrier_features.x_rate_plan%TYPE;
 --
BEGIN
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_esn: ' || NVL(p_esn ,'Value is null'));
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.2';
 l_v_note := 'Calling f_get_esn_rate_plan function to retrieve the rate plan for the ESN';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 l_v_rate_plan := f_get_esn_rate_plan(p_esn => p_esn);
 --
 l_v_position := l_cv_subprogram_name || '.3';
 l_v_note := 'End executing ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_rate_plan : ' || NVL(l_v_rate_plan ,'Value is null'));
 dbms_output.put_line('p_error_code : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
 dbms_output.put_line('p_error_message: ' || NVL(l_v_error_message ,'Value is null'));
 --
 END IF;
 --
 p_rate_plan := l_v_rate_plan;
 p_error_code := l_i_error_code;
 p_error_message := l_v_error_message;
 --
EXCEPTION
WHEN OTHERS THEN
 --
 p_rate_plan := NULL;
 p_error_code := SQLCODE;
 p_error_message := SQLERRM;
 --
 l_v_position := l_cv_subprogram_name || '.4';
 l_v_note := 'End executing with Oracle error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_rate_plan : ' || NVL(p_rate_plan ,'Value is null'));
 dbms_output.put_line('p_error_code : ' || NVL(TO_CHAR(p_error_code) ,'Value is null'));
 dbms_output.put_line('p_error_message: ' || NVL(p_error_message ,'Value is null'));
 --
 END IF;
 --
 ota_util_pkg.err_log(p_action => l_v_note ,p_error_date => SYSDATE ,p_key => p_esn ,p_program_name => l_v_position ,p_error_text => p_error_message);
 --
END sp_get_esn_rate_plan;
--
--********************************************************************************
-- Wrapper procedure will retrieve the rate plan for an ESN
--********************************************************************************
--
PROCEDURE sp_get_esn_rate_plan_allstatus(
 p_esn IN table_part_inst.part_serial_no%TYPE ,
 p_rate_plan OUT table_x_carrier_features.x_rate_plan%TYPE ,
 p_error_code OUT INTEGER ,
 p_error_message OUT VARCHAR2 )
IS
 --
 l_cv_subprogram_name CONSTANT VARCHAR2(61) := l_cv_package_name || '.sp_get_esn_rate_plan_allstatus';
 l_i_error_code INTEGER := 0;
 l_v_error_message VARCHAR2(32767) := 'SUCCESS';
 l_v_position VARCHAR2(32767) := l_cv_subprogram_name || '.1';
 l_v_note VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
 l_v_rate_plan table_x_carrier_features.x_rate_plan%TYPE;
 --
BEGIN
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_esn: ' || NVL(p_esn ,'Value is null'));
 --
 END IF;
 --
 l_v_position := l_cv_subprogram_name || '.2';
 l_v_note := 'Calling f_get_esn_rate_plan function to retrieve the rate plan for the ESN';
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 --
 END IF;
 --
 l_v_rate_plan := f_get_esn_rate_plan_all_status(p_esn => p_esn);
 --
 l_v_position := l_cv_subprogram_name || '.3';
 l_v_note := 'End executing ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_rate_plan : ' || NVL(l_v_rate_plan ,'Value is null'));
 dbms_output.put_line('p_error_code : ' || NVL(TO_CHAR(l_i_error_code) ,'Value is null'));
 dbms_output.put_line('p_error_message: ' || NVL(l_v_error_message ,'Value is null'));
 --
 END IF;
 --
 p_rate_plan := l_v_rate_plan;
 p_error_code := l_i_error_code;
 p_error_message := l_v_error_message;
 --
EXCEPTION
WHEN OTHERS THEN
 --
 p_rate_plan := NULL;
 p_error_code := SQLCODE;
 p_error_message := SQLERRM;
 --
 l_v_position := l_cv_subprogram_name || '.4';
 l_v_note := 'End executing with Oracle error ' || l_cv_subprogram_name;
 --
 IF l_b_debug THEN
 --
 dbms_output.put_line(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE ,' MM/DD/YYYY HH:MI:SS AM'));
 dbms_output.put_line('p_rate_plan : ' || NVL(p_rate_plan ,'Value is null'));
 dbms_output.put_line('p_error_code : ' || NVL(TO_CHAR(p_error_code) ,'Value is null'));
 dbms_output.put_line('p_error_message: ' || NVL(p_error_message ,'Value is null'));
 --
 END IF;
 --
 ota_util_pkg.err_log(p_action => l_v_note ,p_error_date => SYSDATE ,p_key => p_esn ,p_program_name => l_v_position ,p_error_text => p_error_message);
 --
END sp_get_esn_rate_plan_allstatus;
--
--********************************************************************************
-- Wrapper procedure will retrieve the service plan for a PIN
-- Author: RMercado CR17202 Best Buy Integration project
--********************************************************************************
--
PROCEDURE sp_get_pin_service_plan(
 ip_pin IN table_part_inst.x_red_code%TYPE ,
 op_result_set OUT SYS_REFCURSOR ,
 op_err_num OUT INTEGER ,
 op_err_string OUT VARCHAR2 )
IS
BEGIN
 OPEN op_result_set FOR SELECT Sp.* FROM table_part_class pc ,
 table_part_num pn ,
 table_mod_level ml ,
 table_part_inst pi ,
 mtm_partclass_x_spf_value_def mtmspfv ,
 x_serviceplanfeature_value spfv ,
 x_service_plan_feature spf ,
 x_service_plan sp WHERE pc.objid = pn.part_num2part_class AND pn.objid = ml.part_info2part_num AND ml.objid = pi.n_part_inst2part_mod AND pi.x_red_code = ip_pin AND mtmspfv.part_class_id = pc.objid AND mtmspfv.spfeaturevalue_def_id = spfv.value_ref AND spfv.spf_value2spf = spf.objid AND spf.sp_feature2service_plan = sp.objid AND ROWNUM = 1;
 op_err_num := 0;
 op_err_string := 'Success';
EXCEPTION
WHEN OTHERS THEN
 op_err_num := 443;
 op_err_string := SUBSTR(SQLERRM ,1 ,100);
 --
END sp_get_pin_service_plan;
PROCEDURE get_service_plan_prc(
 ip_esn IN VARCHAR2 ,
 op_serviceplanid OUT NUMBER ,
 op_serviceplanname OUT VARCHAR2 ,
 op_serviceplanunlimited OUT NUMBER --1 if true and 0 if false
 ,
 op_autorefill OUT NUMBER --1 if true and 0 if false
 ,
 op_service_end_dt OUT DATE ,
 op_forecast_date OUT DATE ,
 op_creditcardreg OUT NUMBER --1 if true and 0 if false
 ,
 op_redempcardqueue OUT NUMBER ,
 op_creditcardsch OUT NUMBER --1 if true and 0 if false
 ,
 op_statusid OUT VARCHAR2 ,
 op_statusdesc OUT VARCHAR2 ,
 op_email OUT VARCHAR2 ,
 op_part_num OUT VARCHAR2 ,
 op_err_num OUT NUMBER ,
 op_err_string OUT VARCHAR2 )
 /********************************************************************************/
 /* */
 /* NAME : GET_SERVICE_PLAN_PRC */
 /* PURPOSE : Procedure has been developed to return information about */
 /* service plan, redemption cards, credit card info related an ESN */
 /* Input parameter: ESN */
 /* Output parameters: */
 /* ? ServicePlanInfo: (eg: 45| 21) */
 /* ? isServicePlanUnlimited (eg: true |false) */
 /* ? Enrolled in autorefill? (eg: true |false) */
 /* ? End of service date: (eg: 2011-05-31) */
 /* ? Forecast date: (eg: 2011-08-30) */
 /* ? Has credit card (registered) ? (eg: true |false) */
 /* ? Redemption card queue size (eg: 2) */
 /* ? Has credit card in schedule? (eg: true |false) */
 /* ? Handset status (code and string values) */
 /* */
 /* 09/13/11 mmunoz CR16317: Antenna project. Initial Revision */
 /********************************************************************************/
IS
 CURSOR get_esn_info(ip_esn IN table_part_inst.part_serial_no%TYPE)
 IS
 SELECT esn.objid esnobjid ,
 esn.x_part_inst_status handset_status ,
 esn.x_part_inst2site_part ,
 pn.PART_NUMBER ,
 ct.x_code_name handset_descstatus
 FROM table_part_inst esn ,
 sa.table_x_code_table ct ,
 sa.table_mod_level ml ,
 sa.table_part_num pn
 WHERE 1 = 1
 AND esn.x_domain = 'PHONES'
 AND esn.part_serial_no = ip_esn
 AND ct.x_code_number = esn.x_part_inst_status
 AND ml.objid = esn.n_part_inst2part_mod
 AND pn.objid = ml.part_info2part_num;
 CURSOR get_site_part_info(ip_x_part_inst2site_part IN table_part_inst.x_part_inst2site_part%TYPE)
 IS
 SELECT sp.x_expire_dt service_end_dt ,
 sp.warranty_date forecast_date ,
 sp.objid sitepartobjid
 FROM table_site_part sp
 WHERE 1 = 1
 AND sp.objid = ip_x_part_inst2site_part;
 CURSOR get_service_info(ip_objid IN table_site_part.objid%TYPE)
 IS
 SELECT xspsp.x_service_plan_id serviceplanid ,
 CASE INSTR(UPPER(xsp.webcsr_display_name) ,'UNLIMITED' ,1 ,1)
 WHEN 0
 THEN 0
 ELSE 1
 END isserviceplanunlimited ,
 xsp.description serviceplanname ,
 xspsp.x_new_service_plan_id
 FROM sa.x_service_plan xsp ,
 sa.x_service_plan_site_part xspsp
 WHERE 1 = 1
 AND xspsp.table_site_part_id = ip_objid
 AND xsp.objid = xspsp.x_service_plan_id;
 CURSOR get_autorefill ( ip_site_part_objid IN NUMBER ,ip_part_inst_objid IN NUMBER )
 IS
   SELECT pp.x_charge_frq_code autorefill
   FROM sa.x_program_parameters pp
   WHERE pp.objid = ( SELECT MAX(pe.pgm_enroll2pgm_parameter) --find latest objid
                      FROM   sa.x_program_enrolled pe
                      WHERE  1 = 1
                      AND    pe.pgm_enroll2site_part = ip_site_part_objid
                      AND    pe.pgm_enroll2part_inst = ip_part_inst_objid
                      AND    pe.x_enrollment_status = 'ENROLLED'
  	                  AND NOT EXISTS ( SELECT NULL
					                   FROM sa.x_program_parameters PP_2
                                       WHERE 1=1
                                       AND PP_2.OBJID = pe.pgm_enroll2pgm_parameter
                                       AND ( PP_2.x_charge_frq_code = 'LOWBALANCE' OR
                                             pp_2.x_prog_class IN ( SELECT x_param_value
                                                                    FROM sa.table_x_parameters
                                                                    WHERE x_param_name = 'NON_BASE_PROGRAM_CLASS'
                                                                  )
                                            )
                                       )
                      );
 CURSOR get_card_queue_size(ip_part_inst_objid IN NUMBER)
 IS
 SELECT COUNT(rc.part_serial_no) card_queue_size,
 NVL(SUM(NVL(pn.x_redeem_days,0)),0) days_card_queue
 FROM table_part_inst rc,
 table_mod_level ml,
 table_part_num pn
 WHERE 1 = 1
 AND rc.part_to_esn2part_inst = ip_part_inst_objid
 AND rc.x_domain = 'REDEMPTION CARDS'
 AND rc.x_part_inst_status = '400'
 AND ml.objid = rc.n_part_inst2part_mod
 AND pn.objid = ml.part_info2part_num;
 CURSOR get_credit_card_reg(ip_part_inst_objid IN NUMBER)
 IS
 SELECT
 /*+ ORDERED */
 COUNT(*) count_cc --Has credit card (registered)
 FROM table_x_contact_part_inst conpi ,
 mtm_contact46_x_credit_card3 mtm ,
 table_x_credit_card cc ,
 x_payment_source pymt
 WHERE 1 = 1
 AND conpi.x_contact_part_inst2part_inst = ip_part_inst_objid
 AND mtm.mtm_contact2x_credit_card = conpi.x_contact_part_inst2contact
 AND cc.objid = mtm.mtm_credit_card2contact
 AND cc.x_card_status = 'ACTIVE'
 AND pymt.pymt_src2x_credit_card = cc.objid
 AND pymt.x_status = 'ACTIVE'
 AND pymt.x_pymt_type = 'CREDITCARD';
 CURSOR get_login_name ( ip_part_inst_objid IN NUMBER )
 IS
 SELECT web.login_name
 FROM table_x_contact_part_inst conpi ,
 table_web_user web
 WHERE conpi.x_contact_part_inst2part_inst = ip_part_inst_objid
 AND web.web_user2contact = conpi.x_contact_part_inst2contact;
 /***** Variables *****/
 get_esn_info_rec get_esn_info%rowtype;
 get_site_part_info_rec get_site_part_info%ROWTYPE;
 get_service_info_rec get_service_info%ROWTYPE;
 get_autorefill_rec get_autorefill%ROWTYPE;
 get_card_queue_size_rec get_card_queue_size%ROWTYPE;
 get_credit_card_reg_rec get_credit_card_reg%ROWTYPE;
 get_login_name_rec get_login_name%ROWTYPE;
BEGIN
 /**** Setting default values to output parameters ****/
 OP_SERVICEPLANID := 0;
 op_serviceplanname := '';
 OP_SERVICEPLANUNLIMITED := 0;
 op_autorefill := 0;
 OP_SERVICE_END_DT := NULL;
 op_forecast_date := NULL;
 OP_CREDITCARDREG := 0;
 OP_REDEMPCARDQUEUE := 0;
 OP_CREDITCARDSCH := 0;
 OP_STATUSID := '';
 op_statusdesc := '';
 op_email := '';
 op_part_num := '';
 op_err_num := 0;
 op_err_string := 'Success';
 IF INSTR(NVL(ip_esn,' '),' ') > 0 --invalid ESN
 THEN
 op_err_num := 500;
 op_err_string := sa.get_code_fun('SERVICE_PLAN' ,op_err_num ,'ENGLISH');
 END IF; --invalid ESN
 -- ESN Information
 IF op_err_num = 0 THEN
 OPEN get_esn_info(ip_esn);
 FETCH get_esn_info INTO GET_ESN_INFO_REC;
 IF get_esn_info%NOTFOUND THEN
 op_err_num := 501;
 op_err_string := sa.get_code_fun('SERVICE_PLAN' ,op_err_num ,'ENGLISH');
 ELSE
 op_statusid := get_esn_info_rec.handset_status;
 op_statusdesc := get_esn_info_rec.handset_descstatus;
 OP_PART_NUM := GET_ESN_INFO_REC.PART_NUMBER;
 END IF;
 END IF;
 -- Instance Information
 IF op_err_num = 0 THEN
 OPEN get_site_part_info(get_esn_info_rec.x_part_inst2site_part);
 FETCH get_site_part_info INTO get_site_part_info_rec;
 IF get_site_part_info%NOTFOUND THEN
 op_err_num := 503;
 op_err_string := sa.get_code_fun('SERVICE_PLAN' ,op_err_num ,'ENGLISH');
 ELSE
 op_service_end_dt := get_site_part_info_rec.service_end_dt;
 op_forecast_date := get_site_part_info_rec.forecast_date;
 END IF;
 END IF;
 -- Service Plan Information
 IF op_err_num = 0 THEN
 OPEN get_service_info(get_site_part_info_rec.sitepartobjid);
 FETCH get_service_info INTO get_service_info_rec;
 IF get_service_info%NOTFOUND THEN
 op_err_num := 502;
 op_err_string := sa.get_code_fun('SERVICE_PLAN' ,op_err_num ,'ENGLISH');
 ELSE
 op_serviceplanid := get_service_info_rec.serviceplanid;
 op_serviceplanname := get_service_info_rec.serviceplanname;
 IF NVL(get_service_info_rec.isserviceplanunlimited ,0) != 0 THEN
 op_serviceplanunlimited := 1;
 ELSE
 op_serviceplanunlimited := 0;
 END IF;
 IF NVL(get_service_info_rec.x_new_service_plan_id ,0) != 0 THEN
 op_creditcardsch := 1;
 ELSE
 op_creditcardsch := 0;
 END IF;
 END IF;
 END IF;
 -- Program Information
 IF op_err_num NOT IN (501,503) THEN
 OPEN get_autorefill(get_site_part_info_rec.sitepartobjid ,get_esn_info_rec.esnobjid);
 FETCH get_autorefill INTO get_autorefill_rec;
 IF get_autorefill%FOUND AND NVL(get_autorefill_rec.autorefill ,' ') != ' ' THEN
 op_autorefill := 1;
 ELSE
 op_autorefill := 0;
 END IF;
 END IF;
 -- Card queue Information
 IF op_err_num <> 501 THEN
 OPEN get_card_queue_size(get_esn_info_rec.esnobjid);
 FETCH get_card_queue_size INTO get_card_queue_size_rec;
 IF get_card_queue_size%found THEN
 op_redempcardqueue := get_card_queue_size_rec.card_queue_size;
 op_forecast_date := get_site_part_info_rec.forecast_date + get_card_queue_size_rec.days_card_queue;
 END IF;
 END IF;
 -- Credit Card and login Information
 IF op_err_num <> 501 THEN
 OPEN get_credit_card_reg(get_esn_info_rec.esnobjid);
 FETCH get_credit_card_reg INTO get_credit_card_reg_rec;
 IF get_credit_card_reg%FOUND AND get_credit_card_reg_rec.count_cc > 0 THEN
 op_creditcardreg := 1;
 ELSE
 op_creditcardreg := 0;
 END IF;
 OPEN get_login_name(get_esn_info_rec.esnobjid);
 FETCH get_login_name INTO get_login_name_rec;
 IF get_login_name%FOUND THEN
 op_email := get_login_name_rec.login_name;
 END IF;
 END IF;
 IF get_esn_info%ISOPEN THEN
 CLOSE get_esn_info;
 END IF;
 IF get_site_part_info%ISOPEN THEN
 CLOSE get_site_part_info;
 END IF;
 IF get_service_info%ISOPEN THEN
 CLOSE get_service_info;
 END IF;
 IF get_autorefill%ISOPEN THEN
 CLOSE get_autorefill;
 END IF;
 IF get_card_queue_size%ISOPEN THEN
 CLOSE get_card_queue_size;
 END IF;
 IF get_credit_card_reg%ISOPEN THEN
 CLOSE get_credit_card_reg;
 END IF;
 IF get_login_name%ISOPEN THEN
 CLOSE get_login_name;
 END IF;
EXCEPTION
WHEN OTHERS THEN
 op_err_num := SQLCODE;
 op_err_string := SUBSTR(SQLERRM ,1 ,100);
END get_service_plan_prc;
FUNCTION get_service_plan_by_esn(
 in_esn IN table_part_inst.part_serial_no%TYPE)
 RETURN x_service_plan%rowtype
IS
 CURSOR esn_sp_cur
 IS
 SELECT sp.*
 FROM x_service_plan_site_part spsp,
 x_service_plan sp,
 table_site_part tsp
 WHERE tsp.x_service_id = in_esn
 AND tsp.objid = DECODE(
 (SELECT COUNT(1) FROM table_site_part WHERE x_service_id = in_esn
 AND part_status = 'Active'
 ), 1,
 (SELECT objid
 FROM table_site_part
 WHERE x_service_id = in_esn
 AND part_status = 'Active'
 ),
 (SELECT MAX(objid)
 FROM table_site_part
 WHERE x_service_id = in_esn
 AND part_status <> 'Obsolete'
 ) )
 AND sp.objid = spsp.x_service_plan_id
 AND spsp.table_site_part_id = tsp.objid;
 esn_sp_rec esn_sp_cur%rowtype;
 BEGIN
 --
 IF (in_esn IS NOT NULL) THEN
 OPEN esn_sp_cur;
 FETCH esn_sp_cur INTO esn_sp_rec;
 CLOSE ESN_SP_CUR;
 END IF;
 --
 RETURN (esn_sp_rec);
 END get_service_plan_by_esn;
FUNCTION sp_get_pin_service_plan_id(
 in_pin IN table_part_inst.x_red_code%TYPE)
 RETURN x_service_plan.objid%TYPE
IS
 v_sp_rfc SYS_REFCURSOR;
 v_pin_sp_rec x_service_plan%ROWTYPE;
 v_err_num INTEGER;
 v_err_string VARCHAR2(250);
 v_pin_sp_id x_service_plan.objid%TYPE;
BEGIN
 --
 IF (in_pin IS NOT NULL) THEN
 --
 sp_get_pin_service_plan(ip_pin => in_pin, op_result_set => v_sp_rfc, -- returns only one row
 op_err_num => v_err_num, op_err_string => v_err_string);
 LOOP
 FETCH v_sp_rfc
 INTO v_pin_sp_rec;
 EXIT
 WHEN v_sp_rfc%NOTFOUND;
 v_pin_sp_id := v_pin_sp_rec.objid;
 END LOOP;
 --
 END IF;
 --
 RETURN (v_pin_sp_id);
END sp_get_pin_service_plan_id;
--Added for CR55236 TW web common standards,to get the group name based on vas plan id and the brand
FUNCTION get_vas_group_name (
        i_vas_service_id   IN vas_programs_view.vas_service_id%TYPE,
        i_vas_bus_org      IN vas_programs_view.vas_bus_org%TYPE
    ) RETURN vas_programs_view.vas_group_name%TYPE IS
        o_vas_group_name   vas_programs_view.vas_group_name%TYPE;
    BEGIN
        SELECT
            vas_group_name
        INTO
            o_vas_group_name
        FROM
            vas_programs_view
        WHERE
            vas_service_id = i_vas_service_id
            AND   vas_bus_org = i_vas_bus_org;

        RETURN o_vas_group_name;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END;

-- Author : ASKuthadi on 07/11/13
-- Purpose: To give allowed retention actions based on the rules set up in underlying tables.
-- Brand + Flow (REDEMPTION, SWITCH PLAN, etc.,) + Scenario (Unlimted to Unlimtied ILD) = Retention Actions
--
PROCEDURE get_sp_retention_action(
 in_esn IN table_part_inst.part_serial_no%TYPE,
 in_flow_name IN VARCHAR2,
 io_dest_plan_act_tbl IN OUT retention_action_typ_tbl, -- will get either plan ids or pins but not both, for TF, plan id is billing program id
 out_err_num OUT INTEGER,
 out_err_string OUT VARCHAR2)
IS
 --
 v_pln_pin_rec retention_action_typ_obj := retention_action_typ_obj.initialize();
 v_pln_pin_tbl retention_action_typ_tbl := retention_action_typ_tbl();
 v_pin_sp_id x_service_plan.objid%TYPE;
 v_pin_vas_pgm_id x_vas_programs.objid%TYPE;
 v_esn_sp_rec x_service_plan%rowtype;
 v_src_sp_grp x_serviceplanfeaturevalue_def.value_name%TYPE;
 v_dest_sp_grp x_retention_scenarios.x_dest_service_plan_grp%TYPE;
 v_pins_rcvd BOOLEAN := FALSE;
 v_pln_pin_action_rec retention_action_typ_obj := retention_action_typ_obj.initialize();
 v_pln_pin_action_tbl retention_action_typ_tbl := retention_action_typ_tbl();
 v_location VARCHAR2(1000);
 v_business_error_excp EXCEPTION;
 v_err_num INTEGER;
 v_err_string VARCHAR2(1000);
 v_brand_objid table_bus_org.objid%TYPE;

 c customer_type := customer_type (); --CR44729
 --
BEGIN
 --
 v_location := 'Validate input parameters.';
 IF (in_esn IS NULL) THEN
 v_err_num := 504; -- Input ESN is null.
 v_err_string := sa.get_code_fun('SERVICE_PLAN', v_err_num, 'ENGLISH');
 RAISE v_business_error_excp;
 END IF;
 IF (in_flow_name IS NULL) THEN
 v_err_num := 505; -- Input flow name is null.
 v_err_string := sa.get_code_fun('SERVICE_PLAN', v_err_num, 'ENGLISH');
 RAISE v_business_error_excp;
 END IF;
  --IF (io_dest_plan_act_tbl.count = 0) THEN --CR47564 Changed by Sagar
 IF io_dest_plan_act_tbl IS NULL THEN
 v_err_num := 506; -- Input list of both service plans id's and pins are empty.
 v_err_string := sa.get_code_fun('SERVICE_PLAN', v_err_num, 'ENGLISH');
 RAISE v_business_error_excp;
 END IF;
 -- TF is not service plan based as of 08/30/13.
 -- These retention actions are Service Plan/ VAS program specific
 -- For TF a dummy source and destination group have been created so that the retentions will be some what table driven.
 -- Once we have TF service plans the TF code here can be removed with necessary data configuration the DB service will work as expected for TF too.
 IF bau_util_pkg.get_esn_brand(in_esn) != 'TRACFONE' THEN
 -- get service plan ESN
 v_location := 'Get service plan information for the input ESN - ' || in_esn;
 v_esn_sp_rec := get_service_plan_by_esn(in_esn);
 IF (v_esn_sp_rec.objid IS NULL) THEN
 v_err_num := 509; -- 'Cannot determine service plan of the input ESN'
 v_err_string := sa.get_code_fun('SERVICE_PLAN', v_err_num, 'ENGLISH') ||' - '|| in_esn;
 RAISE v_business_error_excp;
 END IF;
 --
 v_location := 'Get service plan group for the service plan - ' || v_esn_sp_rec.objid;
 v_src_sp_grp := get_serv_plan_value(v_esn_sp_rec.objid, 'SERVICE_PLAN_GROUP');
 --
 v_location := 'Determine if received input is list of pins or service plan ID''s.';
 -- determine service plans/vas program id for each pin in the list
 -- if atleast for one pin we cannot find above then we fail the whole(list) transaction.
 FOR i IN io_dest_plan_act_tbl.FIRST..io_dest_plan_act_tbl.LAST
 LOOP
 IF (io_dest_plan_act_tbl(i).dest_red_card_pin IS NOT NULL) AND (io_dest_plan_act_tbl(i).dest_plan_id IS NULL) THEN
 --
 v_pins_rcvd := TRUE;
 v_pin_sp_id := sp_get_pin_service_plan_id(in_pin => io_dest_plan_act_tbl(i).dest_red_card_pin);
 --
 IF (v_pin_sp_id IS NULL) THEN
 --
 v_pin_vas_pgm_id := vas_management_pkg.get_vas_service_id_by_pin(in_pin => io_dest_plan_act_tbl(i).dest_red_card_pin);
 --
 IF (v_pin_vas_pgm_id IS NULL) THEN
 v_err_num := 508; -- 'Cannot determine Service Plan/VAS program of the input PIN'
 v_err_string := sa.get_code_fun('SERVICE_PLAN', v_err_num, 'ENGLISH') ||' - '|| io_dest_plan_act_tbl(i).dest_red_card_pin;
 RAISE v_business_error_excp;
 END IF;
 --
 v_pln_pin_rec.dest_plan_id := NULL; -- the objid seq of service plan and vas program are in same range, to differentiate putting null.
 ELSE
 v_pln_pin_rec.dest_plan_id := v_pin_sp_id; -- service plan objid
        END IF;
        --
        -- v_pln_pin_rec.dest_plan_id will have only service plan id's and NOT VAS program id's.
        v_pln_pin_rec.dest_red_card_pin := io_dest_plan_act_tbl(i).dest_red_card_pin;
        v_pln_pin_tbl.EXTEND;
        v_pln_pin_tbl(v_pln_pin_tbl.LAST) := v_pln_pin_rec;
        --
      ELSIF (io_dest_plan_act_tbl(i).dest_red_card_pin IS NOT NULL) AND (io_dest_plan_act_tbl(i).dest_plan_id IS NOT NULL) THEN
        v_err_num                                      := 507; -- Input list of either service plans id's or pins are allowed, but not both.
        v_err_string                                   := sa.get_code_fun('SERVICE_PLAN', v_err_num, 'ENGLISH');
        RAISE v_business_error_excp;
      END IF;
    END LOOP;
    -- received service plans itself
    IF (NOT v_pins_rcvd) THEN
      v_pln_pin_tbl := io_dest_plan_act_tbl;
    END IF;
    -- get ESN's bus org
    v_location    := 'Get ESN''s bus org objid.';
    v_brand_objid := bau_util_pkg.get_esn_brand_objid(in_esn);

    --CR44729
    c.esn       := in_esn;
    c.sub_brand := c.get_sub_brand;

    IF c.sub_brand ='GO_SMART' THEN

        BEGIN
	  SELECT objid INTO v_brand_objid
	  FROM table_bus_org WHERE org_id ='GO_SMART';
	EXCEPTION
          WHEN OTHERS THEN
             NULL;
        END;

    END IF;
    --CR44729

    v_location    := 'Get retention actions for given service plan/red card.';

    -- At this point, v_pln_pin_tbl structure is as below
    -- if service plan id's are passed as input, v_pln_pin_tbl will have only plan id's
    -- if pins are passed as input, v_pln_pin_tbl will have only pins + respective service plan id's
    FOR idx IN v_pln_pin_tbl.FIRST..v_pln_pin_tbl.LAST
    LOOP
      FOR rec_retention IN
      (SELECT mtm.x_action
      FROM x_retention_flows rf,
        x_retention_scenarios rs,
        x_mtm_ret_flow_scn_action mtm
      WHERE rf.x_flow_name           = in_flow_name
      AND rs.x_ret_scn2bus_org       = v_brand_objid
      AND rs.x_src_service_plan_grp  = v_src_sp_grp
      --AND rs.x_dest_service_plan_grp = DECODE(v_pln_pin_tbl(idx).dest_plan_id, NULL, -- Its VAS PGM PIN
       --vas_management_pkg.get_vas_service_param_val(vas_management_pkg.get_vas_service_id_by_pin(v_pln_pin_rec.dest_red_card_pin),'VAS_GROUP_NAME'),
      --nvl(get_serv_plan_value(v_pln_pin_tbl(idx).dest_plan_id, 'SERVICE_PLAN_GROUP'), SA.vas_management_pkg.get_vas_service_param_val(v_pln_pin_tbl(idx).dest_plan_id,'VAS_GROUP_NAME')))
		AND rs.x_dest_service_plan_grp = DECODE(v_pln_pin_tbl(idx).dest_plan_id, NULL, -- Its VAS PGM PIN
       get_vas_group_name(sa.vas_management_pkg.get_vas_service_id_by_pin(v_pln_pin_rec.dest_red_card_pin),bau_util_pkg.get_esn_brand(in_esn)),
      nvl(get_vas_group_name(v_pln_pin_tbl(idx).dest_plan_id,bau_util_pkg.get_esn_brand(in_esn)),get_serv_plan_value(v_pln_pin_tbl(idx).dest_plan_id, 'SERVICE_PLAN_GROUP')))
      --Added for CR55236 TW web common standards,to get the group name based on vas plan id and the brand
      AND mtm.x_act2ret_scn = rs.objid
      AND mtm.x_act2ret_flw = rf.objid
      )
      LOOP
        --
        IF (NOT v_pins_rcvd) THEN -- send back plan id's only if they are passed as input
          v_pln_pin_action_rec.dest_plan_id := v_pln_pin_tbl(idx).dest_plan_id;
        END IF;
        v_pln_pin_action_rec.dest_red_card_pin := v_pln_pin_tbl(idx).dest_red_card_pin; -- will be null if plan id's are passed as input
        v_pln_pin_action_rec.ret_action        := rec_retention.x_action;
        v_pln_pin_action_tbl.EXTEND;
        v_pln_pin_action_tbl(v_pln_pin_action_tbl.LAST) := v_pln_pin_action_rec;
        --
      END LOOP;
    END LOOP;
    --
  ELSE -- TRACFONE
    -- CR42459 - Starts
  /*  v_pln_pin_tbl := io_dest_plan_act_tbl;
    v_src_sp_grp  := 'TF_DEFAULT';
    v_dest_sp_grp := 'TF_DEFAULT';
    v_brand_objid := bau_util_pkg.get_esn_brand_objid(in_esn);
    --
    FOR idx IN v_pln_pin_tbl.FIRST..v_pln_pin_tbl.LAST
    LOOP
      --
      FOR rec_retention IN
      (SELECT mtm.x_action
      FROM x_retention_flows rf,
        x_retention_scenarios rs,
        x_mtm_ret_flow_scn_action mtm
      WHERE rf.x_flow_name           = in_flow_name
      AND rs.x_ret_scn2bus_org       = v_brand_objid
      AND rs.x_src_service_plan_grp  = v_src_sp_grp
      AND rs.x_dest_service_plan_grp = v_dest_sp_grp
      AND mtm.x_act2ret_scn          = rs.objid
      AND mtm.x_act2ret_flw          = rf.objid
      )
      LOOP
        v_pln_pin_action_rec.dest_plan_id      := v_pln_pin_tbl(idx).dest_plan_id;
        v_pln_pin_action_rec.dest_red_card_pin := v_pln_pin_tbl(idx).dest_red_card_pin;
        v_pln_pin_action_rec.ret_action        := rec_retention.x_action;
        v_pln_pin_action_tbl.EXTEND;
        v_pln_pin_action_tbl(v_pln_pin_action_tbl.LAST) := v_pln_pin_action_rec;
        --
      END LOOP;
      --
    END LOOP;  */
    --
	v_src_sp_grp  := 'TF_DEFAULT';
    v_dest_sp_grp := 'TF_DEFAULT';
    v_brand_objid := bau_util_pkg.get_esn_brand_objid(in_esn);
    --
	dbms_output.put_line('v_brand_objid: ' || v_brand_objid);
	v_esn_sp_rec := get_service_plan_by_esn(in_esn);
	dbms_output.put_line('service_plan_id ' || v_esn_sp_rec.objid);
	IF (v_esn_sp_rec.objid IS NULL OR v_esn_sp_rec.objid = 252) THEN
	   v_src_sp_grp  := 'TF_DEFAULT';
    ELSE
	   v_src_sp_grp := get_serv_plan_value(v_esn_sp_rec.objid, 'SERVICE_PLAN_GROUP');
	END IF;
	dbms_output.put_line('v_src_sp_grp: ' || v_src_sp_grp);
	FOR i IN io_dest_plan_act_tbl.FIRST..io_dest_plan_act_tbl.LAST
    LOOP
      IF (io_dest_plan_act_tbl(i).dest_red_card_pin IS NOT NULL) AND (io_dest_plan_act_tbl(i).dest_plan_id IS NULL) THEN
        --
		dbms_output.put_line('Inside PIN received');
        v_pins_rcvd := TRUE;
        v_pin_sp_id := sp_get_pin_service_plan_id(in_pin => io_dest_plan_act_tbl(i).dest_red_card_pin);
        --
		dbms_output.put_line('v_pin_sp_id'||v_pin_sp_id);
        IF (v_pin_sp_id IS NULL) THEN
          v_pln_pin_rec.dest_plan_id := NULL;  --TRACFONE PAYGO PPE Plans
        ELSE
          v_pln_pin_rec.dest_plan_id := v_pin_sp_id; -- service plan objid
        END IF;
        --
		dbms_output.put_line('v_pln_pin_rec.dest_plan_id'||v_pln_pin_rec.dest_plan_id);
        v_pln_pin_rec.dest_red_card_pin := io_dest_plan_act_tbl(i).dest_red_card_pin;
        v_pln_pin_tbl.EXTEND;
        v_pln_pin_tbl(v_pln_pin_tbl.LAST) := v_pln_pin_rec;
        --
      ELSIF (io_dest_plan_act_tbl(i).dest_red_card_pin IS NOT NULL) AND (io_dest_plan_act_tbl(i).dest_plan_id IS NOT NULL) THEN
        v_err_num                                      := 507; -- Input list of either service plans id's or pins are allowed, but not both.
        v_err_string                                   := sa.get_code_fun('SERVICE_PLAN', v_err_num, 'ENGLISH');
        RAISE v_business_error_excp;
      END IF;
    END LOOP;
	-- received service plans itself
    IF (NOT v_pins_rcvd) THEN
      v_pln_pin_tbl := io_dest_plan_act_tbl;
    END IF;
	FOR idx IN v_pln_pin_tbl.FIRST..v_pln_pin_tbl.LAST
    LOOP
      FOR rec_retention IN
      (SELECT mtm.x_action,mtm.warning_id
      FROM x_retention_flows rf,
        x_retention_scenarios rs,
        x_mtm_ret_flow_scn_action mtm
      WHERE rf.x_flow_name           = in_flow_name
      AND rs.x_ret_scn2bus_org       = v_brand_objid
      AND rs.x_src_service_plan_grp  = v_src_sp_grp
      AND rs.x_dest_service_plan_grp = DECODE(v_pln_pin_tbl(idx).dest_plan_id, NULL,
        'TF_DEFAULT',252,'TF_DEFAULT',nvl(get_serv_plan_value(v_pln_pin_tbl(idx).dest_plan_id, 'SERVICE_PLAN_GROUP'),'TF_DEFAULT'))
      AND mtm.x_act2ret_scn = rs.objid
      AND mtm.x_act2ret_flw = rf.objid
      )
      LOOP
    --
        IF (NOT v_pins_rcvd) THEN -- send back plan id's only if they are passed as input
          v_pln_pin_action_rec.dest_plan_id := v_pln_pin_tbl(idx).dest_plan_id;
        END IF;
        v_pln_pin_action_rec.dest_red_card_pin := v_pln_pin_tbl(idx).dest_red_card_pin; -- will be null if plan id's are passed as input
        v_pln_pin_action_rec.ret_action        := rec_retention.x_action;
		v_pln_pin_action_rec.warning_id        := rec_retention.warning_id;
        v_pln_pin_action_tbl.EXTEND;
        v_pln_pin_action_tbl(v_pln_pin_action_tbl.LAST) := v_pln_pin_action_rec;
        --
		dbms_output.put_line('v_pln_pin_action_rec.ret_action: ' || v_pln_pin_action_rec.ret_action);
		dbms_output.put_line('v_pln_pin_action_rec.warning_id: ' || v_pln_pin_action_rec.warning_id);
      END LOOP;
    END LOOP;
     -- CR42459 - Ends
  END IF;
  --
  v_location                    := 'Propagate retention actions to the output PLSQL table.';
  IF (v_pln_pin_action_tbl.COUNT > 0) THEN
    io_dest_plan_act_tbl.DELETE;
    io_dest_plan_act_tbl := v_pln_pin_action_tbl;
  END IF;
  --
  out_err_num    := 0;
  out_err_string := 'SUCCESS';
  --
EXCEPTION
WHEN v_business_error_excp THEN
  --
  out_err_num    := v_err_num;
  out_err_string := v_err_string;
  --
WHEN OTHERS THEN
  --
  out_err_num    := SQLCODE;
  out_err_string := sqlerrm;
  ota_util_pkg.err_log(p_action => v_location, p_error_date => SYSDATE, p_key => SUBSTR(in_esn||';'||in_flow_name, 1, 50), p_program_name => 'SERVICE_PLAN.GET_SP_RETENTION_ACTION', p_error_text => out_err_string);
  --
END get_sp_retention_action;
-- Author : sethiraj on 07/10/15
-- Purpose: To get retention actions list and return the Script Text based on the retention actions.
--
PROCEDURE get_sp_retention_action_script(
    in_esn                IN table_part_inst.part_serial_no%TYPE,
    in_flow_name          IN VARCHAR2,
    p_brand_name          IN VARCHAR2 ,
    in_language           IN VARCHAR2 DEFAULT 'ENGLISH',
    in_source_system      IN VARCHAR2 DEFAULT 'APP',
    io_dest_plan_act_tbl  IN out retention_action_typ_tbl,
    ret_script_text       OUT table_x_scripts.x_script_text%TYPE,
    out_ret_warning_flag  OUT VARCHAR2,
    out_err_num           OUT INTEGER,
    out_err_string        OUT VARCHAR2)
IS
  l_add_now               boolean  := FALSE;
  l_add_to_reserve        boolean  := FALSE;
  l_enroll_now            boolean  := FALSE;
  l_enroll_later          boolean  := FALSE;
  l_apply_now             boolean  := FALSE;
  l_ret_action            VARCHAR2(30);
  l_script_id             table_x_scripts.x_script_id%TYPE;
  l_script_type           table_x_scripts.x_script_type%TYPE;
  v_location              VARCHAR2(1000);
  l_part_inst_status      table_part_inst.x_part_inst_status%TYPE;
  l_dest_plan_act_rec     retention_action_typ_obj := retention_action_typ_obj.initialize();
  l_dest_plan_act_tbl     retention_action_typ_tbl := retention_action_typ_tbl();
  l_enroll_ar             VARCHAR2(2); --CR43248 added
  l_min_part_inst_status  table_part_inst.x_part_inst_status%TYPE; --CR48846
   v_esn_sp_rec x_service_plan%rowtype;
  v_src_sp_grp x_serviceplanfeaturevalue_def.value_name%TYPE;
  v_dest_sp_grp x_retention_scenarios.x_dest_service_plan_grp%TYPE;
  v_pin_sp_id x_service_plan.objid%TYPE;
  --
  CURSOR retention_script_cur ( ip_ret_action IN table_x_retention_script.ret_action%TYPE ) IS
  SELECT x_script_id
  FROM   table_x_retention_script ,
         table_bus_org
  WHERE  retention_script2bus_org = table_bus_org.objid
  AND    org_id                   = p_brand_name
  AND    ret_action               = ip_ret_action
  AND    x_flow_name              = in_flow_name;
  retention_script_rec retention_script_cur%rowtype;
  --
  CURSOR x_scripts_cur (ip_brand_name VARCHAR2,  ip_script_type  IN table_x_scripts.x_script_type%TYPE,  ip_script_id IN table_x_scripts.x_script_id%TYPE ) IS
  SELECT xs.x_script_text
    FROM sa.table_x_scripts xs,
         sa.table_bus_org bo
    WHERE xs.x_script_type = ip_script_type
    AND xs.x_script_id     = ip_script_id
    AND xs.x_language      = in_language
    AND xs.script2bus_org  = bo.objid
    AND bo.NAME            = ip_brand_name
    AND xs.x_sourcesystem = in_source_system
    AND ROWNUM <= 1;
  --
  CURSOR esn_status_cur
  IS
  SELECT x_part_inst_status
  FROM   table_part_inst
  WHERE  part_serial_no = in_esn;

  --CR48846 to get MIN status
  CURSOR min_status_cur
  IS
   SELECT  pi_min.x_part_inst_status
    FROM   table_part_inst pi_esn,
           table_part_inst pi_min
    WHERE  pi_esn.part_serial_no = in_esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_min.part_to_esn2part_inst = pi_esn.objid
    AND    pi_min.x_domain = 'LINES';
  --
BEGIN
  --
  out_ret_warning_flag := 'FALSE';
  --
  -- Get the ESN status; if the status = 54 (PastDue) chck for the different flows and set the retention action accordingly
  OPEN esn_status_cur;
  FETCH esn_status_cur INTO l_part_inst_status;
  CLOSE esn_status_cur;
  --

  --CR48846
  OPEN min_status_cur;
  FETCH min_status_cur INTO l_min_part_inst_status;
  CLOSE min_status_cur;

  IF in_flow_name  IN ('APPLY_NOW','MANAGE_RESERVE')
  THEN
    IF in_flow_name  IN ('APPLY_NOW') THEN
        l_ret_action := 'APPLY_NOW';
    ELSIF in_flow_name IN ('MANAGE_RESERVE') THEN
        l_ret_action := 'ADD_NOW';
    END IF;
    FOR idx IN io_dest_plan_act_tbl.FIRST..io_dest_plan_act_tbl.LAST
    LOOP
      l_dest_plan_act_rec.dest_plan_id       := io_dest_plan_act_tbl(idx).dest_plan_id;
      l_dest_plan_act_rec.dest_red_card_pin  := io_dest_plan_act_tbl(idx).dest_red_card_pin;
      l_dest_plan_act_rec.ret_action         := l_ret_action; --io_dest_plan_act_tbl.ret_action;
      l_dest_plan_act_tbl.EXTEND;
      l_dest_plan_act_tbl(l_dest_plan_act_tbl.LAST) := l_dest_plan_act_rec;
    END LOOP;
    IF (l_dest_plan_act_tbl.COUNT > 0)
    THEN
      io_dest_plan_act_tbl.DELETE;
      io_dest_plan_act_tbl := l_dest_plan_act_tbl;
    END IF;
  ELSIF  l_part_inst_status = '54' AND in_flow_name IN ('ENROLL_IN_AUTO_REFILL','SWITCH_PLAN','PURCHASE', 'REDEMPTION','VALUE_PLAN_ENROLLMENT','CHANGE_VALUE_PLAN')
   THEN
    -- Set the retention action for different flows
    IF in_flow_name IN ('ENROLL_IN_AUTO_REFILL','SWITCH_PLAN') THEN
      l_ret_action := 'ENROLL_NOW';
    ELSIF in_flow_name IN ('PURCHASE', 'REDEMPTION','VALUE_PLAN_ENROLLMENT','CHANGE_VALUE_PLAN') THEN
      l_ret_action := 'ADD_NOW';
    END IF;
    FOR idx IN io_dest_plan_act_tbl.FIRST..io_dest_plan_act_tbl.LAST
    LOOP
      l_dest_plan_act_rec.dest_plan_id       := io_dest_plan_act_tbl(idx).dest_plan_id;
      l_dest_plan_act_rec.dest_red_card_pin  := io_dest_plan_act_tbl(idx).dest_red_card_pin;
      l_dest_plan_act_rec.ret_action         := l_ret_action; --io_dest_plan_act_tbl.ret_action;
      l_dest_plan_act_tbl.EXTEND;
      l_dest_plan_act_tbl(l_dest_plan_act_tbl.LAST) := l_dest_plan_act_rec;
    END LOOP;
    IF (l_dest_plan_act_tbl.COUNT > 0)
    THEN
      io_dest_plan_act_tbl.DELETE;
      io_dest_plan_act_tbl := l_dest_plan_act_tbl;
    END IF;
  --CR48846 added USED status and MIN RESERVED check
  ELSIF l_part_inst_status = '51' AND NVL(l_min_part_inst_status,'0') IN ('37','38','39','73')
  THEN
    l_ret_action := 'ADD_NOW';
    FOR idx IN io_dest_plan_act_tbl.FIRST..io_dest_plan_act_tbl.LAST
    LOOP
      l_dest_plan_act_rec.dest_plan_id       := io_dest_plan_act_tbl(idx).dest_plan_id;
      l_dest_plan_act_rec.dest_red_card_pin  := io_dest_plan_act_tbl(idx).dest_red_card_pin;
      l_dest_plan_act_rec.ret_action         := l_ret_action; --io_dest_plan_act_tbl.ret_action;
      l_dest_plan_act_tbl.EXTEND;
      l_dest_plan_act_tbl(l_dest_plan_act_tbl.LAST) := l_dest_plan_act_rec;
    END LOOP;
    IF (l_dest_plan_act_tbl.COUNT > 0)
    THEN
      io_dest_plan_act_tbl.DELETE;
      io_dest_plan_act_tbl := l_dest_plan_act_tbl;
    END IF;
  -- END CR48846
  ELSE
    service_plan.get_sp_retention_action ( in_esn,
                                           in_flow_name,
                                           io_dest_plan_act_tbl,
                                           out_err_num,
                                           out_err_string);
    --
    FOR cnt IN io_dest_plan_act_tbl.FIRST..io_dest_plan_act_tbl.LAST
    LOOP
      l_ret_action := io_dest_plan_act_tbl(cnt).ret_action;
      IF io_dest_plan_act_tbl(cnt).ret_action = 'ADD_NOW' THEN
            l_add_now := TRUE;
      ELSIF io_dest_plan_act_tbl(cnt).ret_action = 'ADD_TO_RESERVE' THEN
            l_add_to_reserve := TRUE;
      ELSIF io_dest_plan_act_tbl(cnt).ret_action = 'ENROLL_NOW' THEN
            l_enroll_now := TRUE;
      ELSIF io_dest_plan_act_tbl(cnt).ret_action = 'ENROLL_ON_DUE_DATE' THEN
            l_enroll_later := TRUE;
      ELSIF io_dest_plan_act_tbl(cnt).ret_action = 'APPLY_NOW' THEN
            l_apply_now := TRUE;
      END IF;
    END LOOP;
    --
    IF (l_add_now) THEN
        l_ret_action := 'ADD_NOW';
    END IF;
    IF (l_add_to_reserve) THEN
        l_ret_action := 'ADD_TO_RESERVE';
    END IF;
    IF (l_add_now  AND l_add_to_reserve) THEN
         l_ret_action := 'ADD_NOW_OR_LATER';
    END IF;
    IF (l_enroll_now ) THEN
         l_ret_action := 'ENROLL_NOW';
    END IF;
    IF (l_enroll_later) THEN
         l_ret_action := 'ENROLL_ON_DUE_DATE';
    END IF;
    IF (l_enroll_now  AND  l_enroll_later) THEN
         l_ret_action := 'ENROLL_NOW_OR_LATER';
    END IF;
    IF (l_apply_now ) THEN
         l_ret_action := 'APPLY_NOW';
    END IF;
    --
  END IF;
  --
  -- CR43248 Changes Starts..
  SELECT DECODE (COUNT(*),0,'N','Y')
  INTO   l_enroll_ar
  FROM   x_program_parameters pp,
         x_program_enrolled ee,
         table_bus_org bo
  WHERE  bo.objid                     = pp.prog_param2bus_org
  AND    ee.pgm_enroll2pgm_parameter  = pp.objid
  AND    ee.pgm_enroll2web_user       IS NOT NULL
  AND    ee.x_enrollment_status       = 'ENROLLED'
  AND    pp.x_prog_class              = 'SWITCHBASE'
  AND    ee.x_next_charge_date        IS NOT NULL
  AND    ee.x_esn                     =  in_esn;
  --
  IF l_enroll_ar = 'Y' AND UPPER(p_brand_name) = 'TOTAL_WIRELESS' AND UPPER(in_flow_name) IN ('PURCHASE','REDEMPTION')
  THEN
    IF l_ret_action = 'ADD_NOW'
    THEN
      l_ret_action := 'ADD_NOW_AR';
    ELSIF l_ret_action = 'ADD_NOW_OR_LATER'
    THEN
      l_ret_action := 'ADD_NOW_OR_LATER_AR';
    END IF;
  END IF;
  -- CR43248 changes ends
  --
  --CR48846 ADDED USED STATUS FOR DEFECT 27340
  IF l_ret_action IS NOT NULL AND l_part_inst_status NOT IN ('54','51')
  THEN
     OPEN retention_script_cur(l_ret_action);
     FETCH retention_script_cur INTO retention_script_rec;
     IF retention_script_cur%found AND retention_script_rec.x_script_id IS NOT NULL THEN
       -- If Scipt id is found, then set the warning flag to True
       out_ret_warning_flag := 'TRUE';
       --
       SELECT substr(retention_script_rec.x_script_id, 1, instr( retention_script_rec.x_script_id,'_')-1) INTO l_script_type  FROM dual;
       SELECT substr(retention_script_rec.x_script_id, instr( retention_script_rec.x_script_id,'_') +1, 100) INTO l_script_id FROM dual;
       -- Get the script text for the given brand name
       OPEN x_scripts_cur(p_brand_name,l_script_type,l_script_id);
       FETCH x_scripts_cur INTO ret_script_text;
       CLOSE x_scripts_cur;
       -- If the script_text is not found, get it for the GENERIC brand
       IF ret_script_text IS NULL THEN
         OPEN x_scripts_cur('GENERIC',l_script_type,l_script_id);
         FETCH x_scripts_cur INTO ret_script_text;
         CLOSE x_scripts_cur;
       END IF;
     END IF;
     CLOSE retention_script_cur;
  END IF;
   --CR53217
  v_esn_sp_rec           := get_service_plan_by_esn(in_esn);

  IF (v_esn_sp_rec.objid IS NULL OR v_esn_sp_rec.objid = 252) THEN
    v_src_sp_grp         := 'TF_DEFAULT';
   ELSE
    v_src_sp_grp := get_serv_plan_value(v_esn_sp_rec.objid, 'SERVICE_PLAN_GROUP');

  END IF;

  FOR i IN io_dest_plan_act_tbl.FIRST..io_dest_plan_act_tbl.LAST
  LOOP

    IF (io_dest_plan_act_tbl(i).dest_red_card_pin IS NOT NULL) AND (io_dest_plan_act_tbl(i).dest_plan_id IS NULL) THEN
      v_pin_sp_id   := sp_get_pin_service_plan_id(in_pin => io_dest_plan_act_tbl(i).dest_red_card_pin);
      v_dest_sp_grp := get_serv_plan_value(v_pin_sp_id, 'SERVICE_PLAN_GROUP');

      IF (v_pin_sp_id IS NULL) THEN
        v_dest_sp_grp := get_vas_group_name(vas_management_pkg.get_vas_service_id_by_pin(io_dest_plan_act_tbl(i).dest_red_card_pin),p_brand_name);
      END IF;

    ELSE
      v_pin_sp_id   := io_dest_plan_act_tbl(i).dest_plan_id;
      v_dest_sp_grp := NVL(get_vas_group_name(io_dest_plan_act_tbl(i).dest_plan_id,p_brand_name),get_serv_plan_value(io_dest_plan_act_tbl(i).dest_plan_id, 'SERVICE_PLAN_GROUP'));
    END IF;

    /*IF source service plan group and destination service plan group is 'PAY_GO' and retention  action is ADD_NOW Then RETURN warning FALSE*/
    IF v_src_sp_grp = 'PAY_GO' AND v_dest_sp_grp = 'PAY_GO' AND l_ret_action = 'ADD_NOW'
    THEN
      out_ret_warning_flag := 'FALSE';
      ret_script_text      := NULL;
    --Data AddOn Plans are STACK and therefore shouldnt return any warning flag, CR55070
    ELSIF ((v_dest_sp_grp = '$10 ILD') OR (v_dest_sp_grp = 'ADD_ON_DATA' AND NVL(get_serv_plan_value(v_pin_sp_id,'BENEFIT_TYPE'),'X') = 'STACK'))
        AND l_ret_action in ('ADD_NOW','ADD_NOW_AR') --CR55236 TW Web common standards Added ADD_NOW_AR
    THEN
      out_ret_warning_flag := 'FALSE';
      ret_script_text      := NULL;
    END IF;
  END LOOP;
  --CR53217
  out_err_num    := 0;
  out_err_string := 'SUCCESS';
  --
EXCEPTION
WHEN OTHERS THEN
  v_location := 'Exception when others at: service_plan.get_sp_retention_action_script';
  out_err_num := sqlcode;
  out_err_string := sqlerrm;
  ota_util_pkg.err_log(p_action => v_location, p_error_date => SYSDATE, p_key => substr(in_esn||';'||in_flow_name, 1, 50||';'||p_brand_name), p_program_name => 'service_plan.get_sp_retention_action_script', p_error_text => out_err_string);
END get_sp_retention_action_script;
--

PROCEDURE get_carrier_features (ip_esn					VARCHAR2
				,ip_service_plan_id			VARCHAR2
				,ip_carrier_objid			VARCHAR2
				,op_switch_base_rate		OUT	VARCHAR2
				,op_error_code			OUT	VARCHAR2
				,op_error_msg			OUT	VARCHAR2
				)

is


	CURSOR get_esn_details_curs(c_esn IN table_part_inst.part_serial_no%TYPE)
	IS
	SELECT
		NVL(
		(SELECT to_number(v.x_param_value)
		FROM table_x_part_class_values v,
		table_x_part_class_params n
		WHERE 1                 =1
		AND v.value2part_class  = pn.part_num2part_class
		AND v.value2class_param = n.objid
		AND n.x_param_name      = 'DATA_SPEED'
		AND rownum              <2
		),NVL(x_data_capable,0)) data_speed

	FROM table_part_num pn,
	table_part_inst pi,
	table_mod_level ml,
	table_bus_org bo,
	table_site_part sp
	WHERE 1                      =1
	AND pi.n_part_inst2part_mod  = ml.objid
	AND ml.part_info2part_num    = pn.objid
	AND pi.part_serial_no        = c_esn
	AND pn.part_num2bus_org      = bo.objid
	AND pi.x_part_inst2site_part = sp.objid;

	get_esn_details_rec get_esn_details_curs%rowtype;



	cursor multi_rate_plan_curs(	c_esn in varchar2,
					c_service_plan_id in number) is
	SELECT x_priority
	FROM x_multi_rate_plan_esns
	WHERE x_esn             = c_esn
	AND x_service_plan_id = c_service_plan_id;

	multi_rate_plan_rec multi_rate_plan_curs%rowtype;

	-- Below query is copied from igate per Curt advise.
	cursor rate_plan_curs(c_service_plan_id in number,
	c_data_speed      in number,
	c_priority        in number,
	c_parent_name     in varchar2) is
	select /* ORDERED */
		xcf.objid cf_objid
		,xcf.x_rate_plan
		,mtm.priority
		,xcf.x_switch_base_rate
	from  table_x_parent pa
	,table_x_carrier_group cg2
	,table_x_carrier ca2
	,table_x_carrier_features xcf
	,mtm_sp_carrierfeatures mtm
	where 1=1
	and pa.x_parent_name              = c_parent_name
	and cg2.x_carrier_group2x_parent  = pa.objid
	AND ca2.carrier2carrier_group     = cg2.objid
	and ca2.objid != 268467960
	AND xcf.x_feature2x_carrier       = ca2.objid
	AND xcf.x_data                    = c_data_speed
	AND mtm.x_carrier_features_id     = xcf.objid
	AND mtm.x_service_plan_id         = c_service_plan_id
	AND mtm.priority                  in(1, c_priority)
	union
	select /* ORDERED */
		xcf.objid cf_objid
		,xcf.x_rate_plan
		,mtm.priority
		,xcf.x_switch_base_rate
	from  table_x_parent pa
	,table_x_carrier_group cg2
	,table_x_carrier ca2
	,table_x_carrier_features xcf
	,mtm_sp_carrierfeatures_dflt mtm
	where 1=1
	and pa.x_parent_name              = c_parent_name
	and cg2.x_carrier_group2x_parent  = pa.objid
	AND ca2.carrier2carrier_group     = cg2.objid
	and ca2.objid != 268467960
	AND xcf.x_feature2x_carrier       = ca2.objid
	AND xcf.x_data                    = c_data_speed
	AND mtm.x_carrier_features_id     = xcf.objid
	AND mtm.x_service_plan_id         = c_service_plan_id
	AND mtm.priority                  in(1, c_priority)
	order by priority desc;
	-- query is copied from igate per Curt advise.

	rate_plan_rec		rate_plan_curs%rowtype;

	lv_parent_name			table_x_parent.x_parent_name%TYPE;

begin

	op_error_code	:=	'0';
	dbms_output.put_line(' get_carrier_features Begin ip_esn '||ip_esn||' ip_service_plan_id '||ip_service_plan_id||' ip_carrier_objid '||ip_carrier_objid);

	BEGIN

		SELECT  pa.x_parent_name
		INTO lv_parent_name
		FROM table_x_parent pa
		,table_x_carrier_group cg2
		,table_x_carrier ca2
		WHERE 1 = 1
		AND ca2.objid                      = ip_carrier_objid
		and cg2.x_carrier_group2x_parent  = pa.objid
		AND ca2.carrier2carrier_group     = cg2.objid
		;

	EXCEPTION WHEN OTHERS
	THEN
		lv_parent_name	:=	NULL;
		op_error_code	:=	'9';
		op_error_msg	:=	'Parent not found';
		RETURN;

	END;

	OPEN get_esn_details_curs(ip_esn);
	FETCH get_esn_details_curs INTO get_esn_details_rec;

	IF get_esn_details_curs%NOTFOUND
	THEN
	CLOSE get_esn_details_curs;

	op_error_code	:=	'9';
	op_error_msg	:=	'ESN details not found';
	RETURN;

	END IF;

	CLOSE get_esn_details_curs;



	OPEN multi_rate_plan_curs(ip_esn,ip_service_plan_id);
	FETCH multi_rate_plan_curs INTO multi_rate_plan_rec;

	IF multi_rate_plan_curs%notfound
	THEN

		multi_rate_plan_rec.x_priority := 1;

	END IF;

	CLOSE multi_rate_plan_curs;



	OPEN rate_plan_curs(ip_service_plan_id,get_esn_details_rec.data_speed,multi_rate_plan_rec.x_priority,lv_parent_name);
	FETCH rate_plan_curs INTO rate_plan_rec;

	IF rate_plan_curs%NOTFOUND
	THEN
	CLOSE rate_plan_curs;

	op_error_code	:=	'9';
	op_error_msg	:=	'Carrier features not found';
	RETURN;

	END IF;

	CLOSE rate_plan_curs;

	op_switch_base_rate	:=	rate_plan_rec.x_switch_base_rate;

EXCEPTION WHEN OTHERS
THEN
	op_error_code	:=	'9';
	op_error_msg	:=	'service_plan.get_carrier_features main expn '||sqlerrm;
	dbms_output.put_line(' main exception '||op_error_msg);


END;
--
PROCEDURE GET_PART_CLASS_NAME ( i_service_plan_id   IN  NUMBER,
                                o_part_class_name   OUT VARCHAR2,
                                o_err_code          OUT VARCHAR2,
                                o_err_msg           OUT VARCHAR2)
IS
  c_service_plan_part_class_name  VARCHAR2(40):=NULL;
BEGIN
  IF i_service_plan_id IS NULL
  THEN
    o_part_class_name := NULL;
    o_err_code := '-1';
    o_err_msg := 'Service plan id is not passed';
    RETURN;
  END IF;

  BEGIN
    SELECT pc.name
    INTO   c_service_plan_part_class_name
    FROM   table_part_class pc,
           table_part_num pn,
           service_plan_feat_pivot_mv spf
    WHERE  spf.service_plan_objid      = i_service_plan_id
    AND    spf.plan_purchase_part_number = pn.part_number
    AND    pn.part_num2part_class        = pc.objid;
  EXCEPTION
    WHEN OTHERS
    THEN
      o_part_class_name := NULL;
      o_err_code        := SQLCODE;
      o_err_msg         := SUBSTR(SQLERRM, 1, 2000);
  END;

  o_part_class_name := c_service_plan_part_class_name;
  o_err_code        := '0';
  o_err_msg         := 'Success';
EXCEPTION
  WHEN OTHERS
  THEN
    o_part_class_name := NULL;
    o_err_code        := SQLCODE;
    o_err_msg         := SUBSTR(SQLERRM, 1, 2000);
END GET_PART_CLASS_NAME;
--
-- CR48846 changes starts..
-- Procedure to get service plan details based on the part number
PROCEDURE sp_get_partnum_service_plan(  ip_part_number  IN  table_part_num.part_number%TYPE ,
                                        op_result_set   OUT SYS_REFCURSOR ,
                                        op_err_num      OUT INTEGER ,
                                        op_err_string   OUT VARCHAR2 )
IS
BEGIN
  --
  OPEN op_result_set
  FOR   SELECT Sp.*
        FROM    table_part_class pc ,
                table_part_num pn ,
                mtm_partclass_x_spf_value_def mtmspfv ,
                x_serviceplanfeature_value spfv ,
                x_service_plan_feature spf ,
                x_service_plan sp
        WHERE   pc.objid                      = pn.part_num2part_class
        AND     pn.part_number                = ip_part_number
        AND     mtmspfv.part_class_id         = pc.objid
        AND     mtmspfv.spfeaturevalue_def_id = spfv.value_ref
        AND     spfv.spf_value2spf            = spf.objid
        AND     spf.sp_feature2service_plan   = sp.objid
        AND ROWNUM = 1;
  --
  op_err_num                      := 0;
  op_err_string                   := 'Success';
EXCEPTION
WHEN OTHERS THEN
  op_err_num    := 443;
  op_err_string := SUBSTR(SQLERRM ,1 ,100);
  --
END sp_get_partnum_service_plan;
--
--
PROCEDURE sp_get_partnum_service_plan(  ip_part_number  IN  table_part_num.part_number%TYPE ,
                                        ip_esn          IN  VARCHAR2 ,
                                        op_sp_objid     OUT NUMBER ,
                                        op_err_num      OUT INTEGER ,
                                        op_err_string   OUT VARCHAR2 )
IS
BEGIN
  --
  SELECT plan.sp_objid INTO op_sp_objid
   FROM table_part_num pn,
     ADFCRM_SERV_PLAN_CLASS_MATVIEW plan,
     ADFCRM_SERV_PLAN_CLASS_MATVIEW ph,
     table_part_num ph_pn,
     table_mod_level ml,
     table_part_inst pi
   WHERE pn.PART_NUM2PART_CLASS = plan.PART_CLASS_OBJID
   AND pn.part_number           = ip_part_number
   AND ph.sp_objid              = plan.sp_objid
   AND ph_pn.part_num2part_class= ph.PART_CLASS_OBJID
   AND ml.part_info2part_num    = ph_pn.objid
   AND pi.n_part_inst2part_mod  = ml.objid
   AND pi.part_serial_no        = ip_esn
   AND ROWNUM = 1;
  --
  op_err_num                      := 0;
  op_err_string                   := 'Success';
EXCEPTION
WHEN OTHERS THEN
  op_err_num    := 443;
  op_err_string := SUBSTR(SQLERRM ,1 ,100);
  --
END sp_get_partnum_service_plan;
--

--  Procedure to get conversion details based on the card part num and ESN
PROCEDURE get_conversion_details  ( i_esn              IN    VARCHAR2,
                                    i_card_part_num    IN    VARCHAR2,
                                    o_annual_plan      OUT   NUMBER  ,
                                    o_voice_units      OUT   NUMBER  ,
                                    o_redeem_days      OUT   NUMBER  ,
                                    o_errorcode        OUT   VARCHAR2,
                                    o_errormessage     OUT   VARCHAR2,
                                    o_voice_conversion OUT   NUMBER  ,
                                    o_redeem_text      OUT   NUMBER  ,
                                    o_redeem_data      OUT   NUMBER  ,
                                    o_service_plan_id  OUT   NUMBER  ) --CR48846
IS
  --CR38927 Safelink Smartphone upgrades
  l_sl_flag VARCHAR2(1) := 'N';
  l_block_triple_benefits_flag VARCHAR2(1); --53297
  ------------------------------------------------------------------------
  CURSOR conversion_sl_curs(c_part_num IN VARCHAR2)
  IS
    SELECT unit_voice,
      unit_days,
      unit_data,
      unit_text,
      x_part_number,
      safelink_flag
    FROM sa.x_surepay_conv
    WHERE x_part_number = c_part_num
    AND product_id      ='SL_TF_PLANS'
    AND active_flag     = 'Y';
  conv_sl_rec conversion_sl_curs%ROWTYPE;
  --CR39338 Safelink ATT upgrades
  CURSOR esn_curs(c_esn IN VARCHAR2)
  IS
    SELECT  objid ,
            DECODE(warr_end_date ,
            --TO_DATE ('01-jan-1753', 'dd-mon-yyyy'), SYSDATE,
            TO_DATE('01-01-1753' ,'dd-MM-yyyy') ,SYSDATE ,NULL ,SYSDATE ,warr_end_date) warr_end_date
    FROM    table_part_inst
    WHERE   part_serial_no = c_esn;
  esn_rec esn_curs%ROWTYPE;
  ------------------------------------------------------------------------
  CURSOR card_curs ( c_part_number IN VARCHAR2)
  IS
    SELECT  pn.x_redeem_days,
            NVL (pn.x_redeem_units, 0) x_redeem_units,
            NVL (pn.x_conversion, 0) x_conversion,
            pr.x_promo_code,
            PN.PART_NUMBER,--CR37027
            --NVL (pn.x_card_type, 'A') x_card_type                                    ------ added for 23513 Surepay
            DECODE(pn.x_card_type,'WORKFORCE','A',NVL(pn.x_card_type, 'A')) x_card_type --CR26925 TF part number using workforce pins should have the same behavior as x_card_type null
    FROM    table_x_promotion pr,
            table_part_num pn
    WHERE   pn.part_num2x_promotion =   pr.objid(+)
    AND     pn.domain               =   'REDEMPTION CARDS'
    AND     pn.part_number          =   c_part_number;
  card_rec card_curs%ROWTYPE;
  ------------------------------------------------------------------------
  CURSOR conversion_curs (v_sp x_service_plan.objid%TYPE)
  IS
    SELECT c.trans_voice,
      c.trans_text,
      c.trans_data,
      c.trans_days
    FROM x_surepay_conv c,
      sp_mtm_surepay mtm
    WHERE c.objid          = mtm.surepay_conv_objid
    AND service_plan_objid = v_sp;
  conv_rec conversion_curs%ROWTYPE;
  ------------------------------------------------------------------------
  --CR38145 NEW_PAYGO CARDS for AIRTIME
  CURSOR pay_go_curs (c_part_num IN VARCHAR2)
  IS
    SELECT unit_voice,
      unit_days,
      unit_data,
      unit_text,
      x_part_number,
      safelink_flag
    FROM sa.x_surepay_conv
    WHERE x_part_number = c_part_num
    AND active_flag     = 'Y';
  pay_go_rec pay_go_curs%ROWTYPE; --END CR38145
  ------------------------------------------------------------------------
  l_found   NUMBER := 0;
  l_no_wait VARCHAR2(1000);
  l_result  VARCHAR2(20);
  l_msg     VARCHAR2(200);
  --  TF SUREPAY
  v_sp_rfc SYS_REFCURSOR;
  CURSOR c1
  IS
    SELECT  Sp.OBJID,
            Sp.MKT_NAME,
            Sp.DESCRIPTION,
            Sp.CUSTOMER_PRICE,
            Sp.IVR_PLAN_ID,
            Sp.WEBCSR_DISPLAY_NAME
    FROM sa.x_service_plan sp;
  --
  v_pin_sp_rec c1%ROWTYPE;
  --
  --   v_pin_sp_rec    x_service_plan%ROWTYPE;
  v_err_num           INTEGER;
  v_err_string        VARCHAR2 (100);
  l_at_days           table_part_num.x_redeem_days%TYPE   := 0;
  l_at_voice          table_part_num.x_redeem_units%TYPE  := 0;
  l_at_text           NUMBER                              := 0;
  l_at_data           NUMBER                              := 0;
  l_dc_days           table_part_num.x_redeem_days%TYPE   := 0;
  l_dc_voice          table_part_num.x_redeem_units%TYPE  := 0;
  l_dc_text           NUMBER                              := 0;
  l_dc_data           NUMBER                              := 0;
  lv_sms_units        VARCHAR2(100);
  lv_sms_units_1      NUMBER(10);
  v_count             NUMBER;-----for CR37027
BEGIN
  dbms_output.put_line('inside the package');
  -- initialize to blank cwl 2/20/06
  --
  dbms_output.put_line('outside the first loop');
  --
  OPEN esn_curs(i_esn);
  FETCH esn_curs INTO esn_rec;
  CLOSE esn_curs;
  --
  --
  sp_get_partnum_service_plan ( ip_part_number    =>    i_card_part_num,
                                op_result_set     =>    v_sp_rfc,
                                op_err_num        =>    v_err_num,
                                op_err_string     =>    v_err_string);
  --
  ---- CR 23513 TF SUREPAY
  IF device_util_pkg.get_smartphone_fun(i_esn) = 0 THEN -------------- TF SUREPAY PHONE CHK
    dbms_output.put_line('o1');
    --CR39338 SL SMARTPHONE ATT upgrades
    BEGIN
      SELECT  'Y'
      INTO    l_sl_flag
      FROM    x_sl_currentvals cv ,
              table_bus_org bo ,
              table_part_num pn ,
              table_part_inst pi ,
              table_mod_level ml
      WHERE   x_current_esn           =   i_esn
      AND     pi.part_serial_no       =   cv.x_current_esn
      AND     pi.n_part_inst2part_mod =   ml.objid
      AND     ml.part_info2part_num   =   pn.objid
      AND     bo.objid                =   pn.part_num2bus_org
      AND     bo.org_id               =   'TRACFONE'
      AND     ROWNUM                  =   1;
    EXCEPTION
    WHEN OTHERS THEN
      l_sl_flag := 'N';
    END;
    --
    OPEN card_curs(i_card_part_num);
    FETCH card_curs INTO card_rec;
    IF card_curs%FOUND
    THEN
      --
      LOOP
        FETCH v_sp_rfc
        INTO  v_pin_sp_rec;
        EXIT  WHEN v_sp_rfc%NOTFOUND;
        ------FOR CR37042
        dbms_output.put_line('3');

        o_service_plan_id := v_pin_sp_rec.objid; --CR48846

        BEGIN
          SELECT  COUNT(1)
          INTO    v_count
          FROM    TABLE_X_PARAMETERS
          WHERE   X_PARAM_NAME = 'REPLACEMENT_PARTNUMBERS'
          AND     x_param_value  =card_rec.PART_NUMBER;
        EXCEPTION
        WHEN OTHERS THEN
          -- dbms_output.put_line('exception'||sqlerrm);
          v_count := 1;
        END;
        ----END CR37042
        dbms_output.put_line('v_count'||v_count);
        dbms_output.put_line('card_rec.x_card_type'||card_rec.x_card_type);
        dbms_output.put_line('card_rec.PART_NUMBER'||card_rec.PART_NUMBER);
        IF card_rec.x_card_type IN ('DATA CARD','TEXT ONLY') THEN ----- Chk for data cards and text only cards --CR32572 AND CR32572
          dbms_output.put_line('1');
          lv_sms_units   := 0 ;
          lv_sms_units_1 := 0;
          lv_sms_units   := get_serv_plan_value (v_pin_sp_rec.objid, 'SMS');
          BEGIN
            SELECT NVL(DECODE(lv_sms_units,'NA', 0, TO_NUMBER(lv_sms_units)),0)
            INTO lv_sms_units_1
            FROM DUAL;
          EXCEPTION
          WHEN OTHERS THEN
            RAISE;
          END;
          l_dc_data               := l_dc_data + get_serv_plan_value (v_pin_sp_rec.objid, 'DATA');
          l_dc_days               := l_dc_days + get_serv_plan_value (v_pin_sp_rec.objid, 'SERVICE DAYS');
          l_dc_text               := l_dc_text + lv_sms_units_1; ---CR32572
        ELSIF card_rec.x_card_type = 'A' AND v_count=0 THEN      ---FOR CR37027                                 ----- Chk for airtime cards
          dbms_output.put_line('2');
          OPEN conversion_curs(v_pin_sp_rec.objid);
          FETCH conversion_curs INTO conv_rec;
          CLOSE conversion_curs;
          --CR38145 NEW_PAYGO_CARDS
          pay_go_rec := NULL; --CR42560 pay_go_curs rec set to null for multiple cards
          OPEN pay_go_curs (card_rec.part_number);
          FETCH pay_go_curs INTO pay_go_rec;
          /*these paygo cards has no service plans, so these cards added in x_surepay_conv  by part number
          to get the data, voice and text units  --added by Srini*/
          IF pay_go_curs%FOUND AND NVL(pay_go_rec.safelink_flag,'N') ='N' THEN --CR41433 SL Smartphone upgrade  VZN
            l_at_voice := l_at_voice + card_rec.x_redeem_units;
            l_at_days  := l_at_days  + card_rec.x_redeem_days;
            l_at_text  := l_at_text  + pay_go_rec.unit_text;
            l_at_data  := l_at_data  + pay_go_rec.unit_data;
            CLOSE pay_go_curs;
          ELSE --END CR38145
            CLOSE pay_go_curs;
            IF l_sl_flag='Y'  AND  NVL(pay_go_rec.safelink_flag,'N')='Y' THEN  --for  safelink --CR41433 SL Smartphone upgrade  VZN
               l_at_voice := l_at_voice + pay_go_rec.unit_voice;
               l_at_days  := l_at_days  + card_rec.x_redeem_days;
               l_at_text  := l_at_text  + pay_go_rec.unit_text;
               l_at_data  := l_at_data  + pay_go_rec.unit_data;
            ELSE ---not safelink BAU
            --53297 Start --{
               l_block_triple_benefits_flag := NULL;
               l_block_triple_benefits_flag := sa.BLOCK_TRIPLE_BENEFITS(i_esn);
               DBMS_OUTPUT.PUT_LINE('ESN - '||i_esn );
               DBMS_OUTPUT.PUT_LINE('block_flag - '||l_block_triple_benefits_flag );
               IF NVL(l_block_triple_benefits_flag, 'N') = 'Y'
               THEN --{
                l_at_voice := l_at_voice + card_rec.x_redeem_units;
                l_at_days  := l_at_days  + card_rec.x_redeem_days;
                l_at_text  := l_at_text  + card_rec.x_redeem_units;
                l_at_data  := l_at_data  + card_rec.x_redeem_units;
                o_voice_conversion :=  1;
               ELSE --}{
                l_at_voice := l_at_voice + conv_rec.trans_voice * card_rec.x_redeem_units;
                l_at_days  := l_at_days  + conv_rec.trans_days  * card_rec.x_redeem_days;
                l_at_text  := l_at_text  + conv_rec.trans_text  * card_rec.x_redeem_units;
                l_at_data  := l_at_data  + conv_rec.trans_data  * card_rec.x_redeem_units;
                o_voice_conversion :=  conv_rec.trans_voice;
               END IF; --}
             --53297 End --}               --
            END IF; --for non safelink
          END IF;
        ELSIF card_rec.x_card_type = 'A' AND v_count=1 THEN ---FOR CR37027                                 ----- Chk for airtime cards
          dbms_output.put_line('2.1');
          OPEN conversion_curs(v_pin_sp_rec.objid);
          FETCH conversion_curs INTO conv_rec;
          CLOSE conversion_curs;
          l_at_voice := 0;
          l_at_days  := l_at_days + conv_rec.trans_days* card_rec.x_redeem_days;
          l_at_text  := 0;
          l_at_data  := (l_at_data + conv_rec.trans_data* card_rec.x_redeem_units)/3;
        END IF;
      END LOOP;
      dbms_output.put_line('3');
      OPEN conversion_sl_curs (card_rec.part_number);
      FETCH conversion_sl_curs INTO conv_sl_rec;
      CLOSE conversion_sl_curs;
      --
      IF l_sl_flag  = 'Y' AND conv_sl_rec.safelink_flag='Y' THEN --CR41433 SL Smartphone upgrade  VZN
        dbms_output.put_line('in safelink 350');
        l_at_voice := l_at_voice + conv_sl_rec.unit_voice;
        l_at_days  := l_at_days  + card_rec.x_redeem_days;
        l_at_text  := l_at_text  + conv_sl_rec.unit_text;
        l_at_data  := l_at_data  + conv_sl_rec.unit_data;
      END IF; --CR41433 SL Smartphone upgrade  VZN
      --
      --CR4981_4982
      IF o_voice_conversion IS NULL
      THEN
        o_voice_conversion := (card_rec.x_conversion);
      END IF;
      --CR4981_4982
    ELSE --------------------- Cursor not found
      o_errorcode    := -1;
      o_errormessage := 'CARD NOT FOUND';
    END IF;
    CLOSE card_curs;
    --
    o_redeem_days := l_at_days  + l_dc_days;
    o_redeem_data := l_at_data  + l_dc_data;
    o_voice_units := l_at_voice + l_dc_voice ;
    o_redeem_text := l_at_text  + l_dc_text;
    dbms_output.put_line('o_redeem_days'||o_redeem_days);
    dbms_output.put_line('o_redeem_data'||o_redeem_data);
    dbms_output.put_line('o_voice_units'||o_voice_units);
    dbms_output.put_line('o_redeem_text'||o_redeem_text);
  ELSIF device_util_pkg.get_smartphone_fun(i_esn) = 1 THEN -------------- NON TF SUREPAY PHONE
    --
    OPEN card_curs(i_card_part_num);
    FETCH card_curs INTO card_rec;
    IF card_curs%FOUND
    THEN
      IF card_rec.x_redeem_days = 365 THEN
        o_annual_plan          := 1;
      END IF;
      o_voice_units := nvl(o_voice_units,0) + nvl(card_rec.x_redeem_units,0); --CR48846
      --CR5848 Start
      o_redeem_days := nvl(o_redeem_days,0) + nvl(card_rec.x_redeem_days,0); --CR48846
      --CR5848 End
      --CR4981_4982
      IF o_voice_conversion IS NULL
      THEN
        o_voice_conversion := (card_rec.x_conversion);
      END IF;
      --CR4981_4982
      IF o_service_plan_id IS NULL
      THEN
        FETCH v_sp_rfc
        INTO  v_pin_sp_rec;

        o_service_plan_id := v_pin_sp_rec.objid;
      END IF;
    ELSE
      o_errorcode    := -1;
      o_errormessage := 'CARD NOT FOUND';
    END IF;
    CLOSE card_curs;
    --
    o_annual_plan     := o_annual_plan;
    o_voice_units     := o_voice_units;
    o_redeem_days     := o_redeem_days;
    o_redeem_data     := 0;
    o_redeem_text     := 0;
    o_errorcode       := o_errorcode;
    o_errormessage    := o_errormessage;
    o_voice_conversion := o_voice_conversion;
  END IF ; -------------- END TF SUREPAY PHONE CHK

  IF v_sp_rfc%ISOPEN
  THEN
    close v_sp_rfc;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  o_errorcode    := SQLCODE;
  o_errormessage := SQLERRM;
END get_conversion_details;
--
-- Procedure to get service plan info details
PROCEDURE  get_service_plan_info  ( i_brand             IN    VARCHAR2,
                                    i_esn               IN    VARCHAR2,
                                    i_card_part_num     IN    VARCHAR2,
                                    i_source_system     IN    VARCHAR2,
                                    i_channel           IN    VARCHAR2,
                                    i_language          IN    VARCHAR2,
                                    i_call_trans_objid  IN    NUMBER, --CR48846
                                    o_plan_info_rc      OUT   SYS_REFCURSOR,
                                    o_error_code        OUT   VARCHAR2,
                                    o_error_msg         OUT   VARCHAR2)
IS
--
  l_annual_plan            NUMBER;
  l_voice_units            NUMBER;
  l_redeem_days            NUMBER;
  l_voice_conversion       NUMBER;
  l_redeem_text            NUMBER;
  l_redeem_data            NUMBER;
  l_promo_code             table_x_promotion.x_promo_code%type;
  l_promo_tab              sa.promo_info_tab;
  l_service_plan_id        NUMBER;
  l_plan_type              VARCHAR2(50);
  l_mobile_plan_category   VARCHAR2(50);
  l_service_plan_group     VARCHAR2(50);

--
BEGIN
--
  -- Input validation
  IF i_brand  IS NULL OR i_esn  IS NULL OR  i_channel  IS NULL
  THEN
    o_error_code   :=  '100';
    o_error_msg    :=  'Brand / ESN / Channel  cannot be null';
    RETURN;
  END IF;
  --
  IF i_card_part_num  IS NULL
  THEN
    get_activation_promo_info ( i_esn              => i_esn,
                                i_call_trans_objid => i_call_trans_objid,
                                o_promo_info_tab   => l_promo_tab,
                                o_error_code       => o_error_code,
                                o_error_msg        => o_error_msg);
    IF o_error_code IS NOT NULL THEN
        o_error_msg    :=  'Error getting promotion information '||o_error_msg;
        RETURN;
    END IF;

    OPEN  o_plan_info_rc
       FOR   SELECT
               i_source_system      "X_SOURCESYSTEM",
               NULL                 "SERVICEPLAN_ID",
               NULL                 "SERVICEPLAN_NAME",
               NVL(voice_units,0)   "REDEEM_UNITS",
               NVL(service_days,0)  "SERVICE_DAYS",
               NULL                 "SERVICEPLAN_DESCRIPTION",
               NULL                 "SERVICEPLAN_DESCRIPTION2",
               NULL                 "CUST_PROFILE_DESCRIPTION",
               NULL                 "PARTNUMBER_WEB_DESCRIPTION",
               NULL                 "PARTNUMBER_SP_WEB_DESCRIPTION",
               NULL                 "WEB_LINK",
               NULL                 "RETAIL_PRICE",
               NULL                 "PARTNUMBER_DESCRIPTION",
               NULL                 "PRICE_CARD_TYPE",
               NULL                 "X_SPECIAL_TYPE",
               NULL                 "PARTNUMBER_CARD_TYPE",
               NULL                 "SOURCE_SYSTEM",
               NVL(voice_units,0)   "VOICE_UNITS",
               NULL                 "SMS_UNITS",
               NULL                 "DATA_UNITS",
               NULL                 "VOICE_CONVERSION_FACTOR",
               promo_code           "X_PROMO_CODE"

             FROM  TABLE(l_promo_tab)  ;
      RETURN;
  END IF; --IF i_card_part_num  IS NULL


  get_conversion_details  ( i_esn               =>   i_esn              ,
                            i_card_part_num     =>   i_card_part_num    ,
                            o_annual_plan       =>   l_annual_plan      ,
                            o_voice_units       =>   l_voice_units      ,
                            o_redeem_days       =>   l_redeem_days      ,
                            o_errorcode         =>   o_error_code       ,
                            o_errormessage      =>   o_error_msg        ,
                            o_voice_conversion  =>   l_voice_conversion ,
                            o_redeem_text       =>   l_redeem_text      ,
                            o_redeem_data       =>   l_redeem_data      ,
                            o_service_plan_id   =>   l_service_plan_id);
  IF l_service_plan_id IS NOT NULL
  THEN
    l_plan_type := sa.util_pkg.get_sp_feature_value( i_service_plan_plan_objid => l_service_plan_id,
                                                     i_value_name => 'PLAN TYPE' );
    l_mobile_plan_category := sa.util_pkg.get_sp_feature_value( i_service_plan_plan_objid => l_service_plan_id,
                                                                i_value_name => 'MOBILE_PLAN_CATEGORY' );
    l_service_plan_group := sa.util_pkg.get_sp_feature_value( i_service_plan_plan_objid => l_service_plan_id,
                                                              i_value_name => 'SERVICE_PLAN_GROUP' );
  END IF;


  --
  OPEN  o_plan_info_rc
  FOR   SELECT
              pn.x_sourcesystem,
              NVL(l_service_plan_id, pn.objid)                   "SERVICEPLAN_ID", -- CR54358 added
              pn.part_number              "SERVICEPLAN_NAME",
              NVL(pn.x_redeem_units,0)    "REDEEM_UNITS",
              NVL(pn.x_redeem_days,0)     "SERVICE_DAYS",
              NVL((SELECT (transaction_history_pkg.fn_get_script_text_by_scriptid(  ip_sourcesystem   =>  i_source_system,
                                                                                    ip_brand_name     =>  i_brand,
                                                                                    ip_language       =>  i_language,
                                                                                    ip_script_id      =>  price.x_web_description))
                   FROM DUAL),price.x_web_description)  "SERVICEPLAN_DESCRIPTION",
              NVL((SELECT (transaction_history_pkg.fn_get_script_text_by_scriptid(  ip_sourcesystem   =>  i_source_system,
                                                                                    ip_brand_name     =>  i_brand,
                                                                                    ip_language       =>  i_language,
                                                                                    ip_script_id      =>  price.x_sp_web_description))
                   FROM DUAL),price.x_sp_web_description) "SERVICEPLAN_DESCRIPTION2",
                   (sa.QUEUE_CARD_PKG.FN_GET_SCRIPT_TEXT_BY_SP_DESC(l_service_plan_id,'CUST_PROFILE_SCRIPT', i_brand ) )  CUST_PROFILE_DESCRIPTION,
              pn.x_web_card_desc          "PARTNUMBER_WEB_DESCRIPTION",
              pn.x_sp_web_card_desc       "PARTNUMBER_SP_WEB_DESCRIPTION",
              price.x_web_link            "WEB_LINK",
              price.x_retail_price        "RETAIL_PRICE",
              --price.objid,
              pn.description              "PARTNUMBER_DESCRIPTION",
              price.x_card_type           "PRICE_CARD_TYPE",
              price.x_special_type        "X_SPECIAL_TYPE",
              pn.x_card_type              "PARTNUMBER_CARD_TYPE",
              pn.x_sourcesystem           "SOURCE_SYSTEM",
              l_voice_units               "VOICE_UNITS",
              l_redeem_text               "SMS_UNITS",
              l_redeem_data               "DATA_UNITS",
              l_voice_conversion          "VOICE_CONVERSION_FACTOR",
              NULL                        "X_PROMO_CODE",
              l_plan_type                 "PLAN_TYPE",
              NVL(transaction_history_pkg.fn_get_script_text_by_scriptid ( ip_sourcesystem   =>  i_source_system,
                                                                           ip_brand_name     =>  i_brand,
                                                                           ip_language       =>  i_language,
                                                                           ip_script_id      =>  l_mobile_plan_category), l_mobile_plan_category) "MOBILE_PLAN_CATEGORY",
              l_service_plan_group        "SERVICE_PLAN_GROUP",
               1                           RN,
              pn.x_display_seq		      x_display_seq
  FROM  sa.table_part_num pn,
        sa.table_x_pricing price,
        table_bus_org bus
  WHERE 1=1
  AND   pn.part_num2bus_org       = bus.objid
  AND   price.x_start_date        <= SYSDATE
  AND   price.x_end_date          >= SYSDATE
  AND   price.x_brand_name        = i_brand
  AND   price.x_channel           = i_channel
  AND   price.x_pricing2part_num  = pn.objid
  AND   pn.domain                 = 'REDEMPTION CARDS'
  AND   pn.part_number            = i_card_part_num
  AND   price.objid               = (SELECT MAX(pc.objid)                    --Pricing issue fix for defects 30330 and 30333
                                     FROM  sa.table_x_pricing pc
                                     WHERE pc.x_pricing2part_num = pn.objid
                                     AND   pc.x_start_date      <= SYSDATE
                                     AND   pc.x_end_date        >= SYSDATE
                                     AND   pc.x_brand_name       = i_brand
                                     AND   pc.x_channel          = i_channel)
  ----CR54358 Start - Added below union query to get the service plan details for replacement part numbers without checking for the pricing

UNION
SELECT
              pn.x_sourcesystem,
              NVL(l_service_plan_id, pn.objid)   "SERVICEPLAN_ID",
              pn.part_number                     "SERVICEPLAN_NAME",
              NVL(pn.x_redeem_units,0)           "REDEEM_UNITS",
              NVL(pn.x_redeem_days,0)            "SERVICE_DAYS",
              NULL                               "SERVICEPLAN_DESCRIPTION",
              NULL                               "SERVICEPLAN_DESCRIPTION2",
            (sa.QUEUE_CARD_PKG.FN_GET_SCRIPT_TEXT_BY_SP_DESC(l_service_plan_id,'CUST_PROFILE_SCRIPT', i_brand ) )  CUST_PROFILE_DESCRIPTION,
              pn.x_web_card_desc                 "PARTNUMBER_WEB_DESCRIPTION",
              pn.x_sp_web_card_desc              "PARTNUMBER_SP_WEB_DESCRIPTION",
              NULL                               "WEB_LINK",
              NULL                               "RETAIL_PRICE",
              pn.description                     "PARTNUMBER_DESCRIPTION",
              NULL                               "PRICE_CARD_TYPE",
              NULL                               "X_SPECIAL_TYPE",
              pn.x_card_type                     "PARTNUMBER_CARD_TYPE",
              pn.x_sourcesystem                  "SOURCE_SYSTEM",
              l_voice_units                      "VOICE_UNITS",
              l_redeem_text                      "SMS_UNITS",
              l_redeem_data                      "DATA_UNITS",
              l_voice_conversion                 "VOICE_CONVERSION_FACTOR",
              NULL                               "X_PROMO_CODE",
              l_plan_type                        "PLAN_TYPE",
              NVL(transaction_history_pkg.fn_get_script_text_by_scriptid ( ip_sourcesystem   =>  i_source_system,
                                                                           ip_brand_name     =>  i_brand,
                                                                           ip_language       =>  i_language,
                                                                           ip_script_id      =>  l_mobile_plan_category), l_mobile_plan_category) "MOBILE_PLAN_CATEGORY",
              l_service_plan_group        "SERVICE_PLAN_GROUP",
			  2                           RN,
              pn.x_display_seq		      x_display_seq
    FROM  sa.table_part_num pn,
        table_bus_org bus
  WHERE 1=1
  AND   pn.part_num2bus_org       = bus.objid
  AND   pn.domain                 = 'REDEMPTION CARDS'
  AND   pn.part_number            = i_card_part_num
  AND   NOT EXISTS ( SELECT 1 FROM  sa.table_x_pricing price
                       WHERE    1=1
                          AND   price.x_start_date        <= SYSDATE
                          AND   price.x_end_date          >= SYSDATE
                          AND   price.x_brand_name        = i_brand
                          AND   price.x_channel           = i_channel
                          AND   price.x_pricing2part_num  = pn.objid
				    )
  ORDER BY RN,x_display_seq ASC;

  --CR54358 end
  --
  o_error_code   :=  '0';
  o_error_msg    :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '101';
    o_error_msg   :=  'ERROR IN GET_SERVICE_PLAN_INFO :  '||substr(sqlerrm,1,100);
END  get_service_plan_info;
--
  -- CR48846 changes ends.

PROCEDURE  get_activation_promo_info  ( i_esn               IN  VARCHAR2,
                                        i_call_trans_objid  IN  NUMBER,
                                        o_promo_info_tab    OUT promo_info_tab,
                                        o_error_code        OUT VARCHAR2,
                                        o_error_msg         OUT VARCHAR2 )
IS
  BEGIN
    SELECT sa.promo_info_type( promo_code   => pr.x_promo_code,
                               voice_units  => pr.x_units,
                               data_units   => NULL,
                               sms_units    => NULL,
                               service_days => pr.x_access_days)
    BULK COLLECT
    INTO   o_promo_info_tab
    FROM   table_x_call_trans ct,
           table_x_promo_hist ph,
           table_x_promotion pr
    WHERE  ct.x_service_id = i_esn
    AND    ct.x_action_type = '1'
    AND    ct.x_reason = 'Activation'
   -- AND    ct.x_result =  'Completed'
    AND    ct.objid    = NVL(i_call_trans_objid, ct.objid)
    AND    ph.promo_hist2x_call_trans = ct.objid
    AND    pr.objid = ph.promo_hist2x_promotion;

  EXCEPTION
    WHEN OTHERS THEN
      o_error_code   :=  '101';
      o_error_msg    :=  'Activation Promo not found '||dbms_utility.format_error_backtrace();
      RETURN;
END get_activation_promo_info;


--CR48260 Changes start
PROCEDURE  get_billing_part_num
  (
  io_part_num_list    IN OUT part_num_mapping_tab,
  o_error_code        OUT    VARCHAR2,
  o_error_message     OUT    VARCHAR2
  )
  AS
    v_prog_name varchar2(50):= 'service_plan.get_billing_part_num';
    v_pc varchar2(50);
    v_pn varchar2(50);
    my_part_class varchar2(50);
    v_err_msg varchar2(400);
  BEGIN

   o_error_code     := '0';
   o_error_message  := sa.get_code_fun('SERVICE_PLAN' ,o_error_code ,'ENGLISH');

   IF io_part_num_list IS NULL THEN
     o_error_code     := '-100';
     o_error_message  := sa.get_code_fun('SERVICE_PLAN' ,o_error_code ,'ENGLISH');
     RETURN;
   END IF;

   IF  io_part_num_list.COUNT=0 THEN
    o_error_code     := '-111';
    o_error_message  := sa.get_code_fun('SERVICE_PLAN' ,o_error_code ,'ENGLISH');
    RETURN;
   END IF;


   FOR  i in 1..io_part_num_list.COUNT LOOP

    IF  io_part_num_list(i).app_part_number  IS NULL  AND   io_part_num_list(i).part_class_name IS NULL THEN
       o_error_code     := '-200';
       o_error_message  := sa.get_code_fun('SERVICE_PLAN' ,o_error_code ,'ENGLISH');
       RETURN;
    ELSIF io_part_num_list(i).app_part_number  IS NOT NULL  AND   io_part_num_list(i).part_class_name IS NOT NULL
    THEN
      --Fetch the part class of given part number and match it with input part class
      my_part_class := NVL(sa.CUSTOMER_INFO.get_part_class ( i_part_num => io_part_num_list(i).app_part_number), 'X');
      IF io_part_num_list(i).part_class_name <> my_part_class
      THEN
        o_error_code     := '-205'; --GIVEN PART NUMBER DOES NOT BELONG TO THE GIVEN PART CLASS
        o_error_message  := sa.get_code_fun('SERVICE_PLAN' ,o_error_code ,'ENGLISH');
        RETURN;
      END IF;
    ELSIF  io_part_num_list(i).part_class_name is null then
      my_part_class := NVL(sa.CUSTOMER_INFO.get_part_class ( i_part_num => io_part_num_list(i).app_part_number), 'X');
    ELSE
      my_part_class := io_part_num_list(i).part_class_name;
    END IF;
    BEGIN
          select  tpc.name,
                  PVT.PLAN_PURCHASE_PART_NUMBER
          INTO v_pc, v_pn
          from  table_part_class tpc
          join table_part_num pn on tpc.objid  = pn.part_num2part_class
          join MTM_PARTCLASS_X_SPF_VALUE_DEF mtmspfv on tpc.objid = mtmspfv.part_class_id
          join X_SERVICEPLANFEATURE_VALUE spfv on  mtmspfv.spfeaturevalue_def_id = spfv.value_ref
          join X_SERVICE_PLAN_FEATURE spf on spfv.spf_value2spf = spf.objid
          join x_service_plan sp on spf.sp_feature2service_plan = sp.objid
          join sa.SPLAN_FEAT_PIVOT pvt on sp.objid = pvt.splan_objid
          where  TPC.name =  my_part_class
          and rownum =1 ;

          io_part_num_list(i).part_class_name := v_pc;
          io_part_num_list(i).app_part_number := v_pn;
     EXCEPTION
       WHEN OTHERS THEN
          v_err_msg := sqlerrm;
          UTIL_PKG.insert_error_tab ('retreiving APP part number',
                                     'PC='||io_part_num_list(i).part_class_name||' PN='||io_part_num_list(i).app_part_number,
                                     v_prog_name,
                                     v_err_msg);
          RETURN ;
     END;
     BEGIN
         select brm_pc,
                rtr_part_number
          into v_pc,
               v_pn
         from brm_catalog_mapping
         where clfy_pc = io_part_num_list(i).part_class_name;

         io_part_num_list(i).part_class_name := v_pc;
         if v_pn is not null then
             io_part_num_list(i).app_ar_part_number := v_pn;
         end if;


     EXCEPTION
       WHEN OTHERS THEN
         v_err_msg := sqlerrm;
          UTIL_PKG.insert_error_tab ('Querying CLARIFY TO BRM mapping',
                                     io_part_num_list(i).part_class_name,
                                     v_prog_name,
                                     v_err_msg);
          RETURN ;
     END;

  END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
     o_error_code     := '99';
     o_error_message  := sa.get_code_fun('SERVICE_PLAN' ,o_error_code ,'ENGLISH') || SUBSTR(sqlerrm,1,200);

END get_billing_part_num;

PROCEDURE  get_app_part_num
(
io_part_num_list    IN OUT part_num_mapping_tab,
o_error_code        OUT    VARCHAR2,
o_error_message     OUT    VARCHAR2
)
AS

BEGIN
  o_error_code     := '0';
  o_error_message  := sa.get_code_fun('SERVICE_PLAN' ,o_error_code ,'ENGLISH');


 IF io_part_num_list IS NULL THEN
   o_error_code     := '-100';
   o_error_message  := sa.get_code_fun('SERVICE_PLAN' ,o_error_code ,'ENGLISH');
   RETURN;
 END IF;

 IF  io_part_num_list.COUNT=0 THEN
   o_error_code     := '-111';
   o_error_message  := sa.get_code_fun('SERVICE_PLAN' ,o_error_code ,'ENGLISH');
   RETURN;
 END IF;

 FOR  i in 1..io_part_num_list.COUNT LOOP


  IF io_part_num_list(i).app_part_number  IS NULL THEN

       o_error_code     := '-203';
       o_error_message  := sa.get_code_fun('SERVICE_PLAN' ,o_error_code ,'ENGLISH');
       RETURN;

  END IF;


   BEGIN
     SELECT  oi.part_number,  -- AR part number
             pc.name
     INTO io_part_num_list(i).app_part_number,
          io_part_num_list(i).part_class_name
     FROM
     sa.x_offer_info oi,
     table_part_num pn ,
     table_part_num pn_ar,
     table_part_class pc
     WHERE oi.offerinfo2pnum        = pn.objid
     AND  pn.part_number            = io_part_num_list(i).app_part_number -- if input is non AR part number
     AND   oi.part_number           = pn_ar.part_number
     AND  pn_ar.part_num2part_class = pc.objid;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT  pn.part_number,   -- non AR part number
                  pc.name
          INTO io_part_num_list(i).app_part_number,
               io_part_num_list(i).part_class_name
          FROM
          sa.x_offer_info oi,
          table_part_num pn,
          table_part_class pc
          WHERE oi.offerinfo2pnum     = pn.objid
          AND  oi.part_number         = io_part_num_list(i).app_part_number  -- if input is  AR part number
          AND  pn.part_num2part_class = pc.objid;

        EXCEPTION
          WHEN OTHERS THEN
           o_error_code     := '-204';
           o_error_message  := 'Line '||i||sa.get_code_fun('SERVICE_PLAN' ,o_error_code ,'ENGLISH')||io_part_num_list(i).app_part_number||','||SUBSTR(sqlerrm,1,500);
           RETURN;
        END;

     WHEN OTHERS THEN
         o_error_code     := '-204';
         o_error_message  := 'Line '||i||sa.get_code_fun('SERVICE_PLAN' ,o_error_code ,'ENGLISH')||io_part_num_list(i).app_part_number||','||SUBSTR(sqlerrm,1,500);
	 RETURN;
    END;

 END LOOP;


EXCEPTION
  WHEN OTHERS THEN
   o_error_code     := '99';
   o_error_message  := sa.get_code_fun('SERVICE_PLAN' ,o_error_code ,'ENGLISH') ||SUBSTR(sqlerrm,1,500);
END get_app_part_num;
--CR48260 Changes end


BEGIN
  --
  NULL;
  --
END service_plan;
/