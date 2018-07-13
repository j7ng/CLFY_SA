CREATE OR REPLACE PACKAGE BODY sa."BYOP_SERVICE_PKG"
AS
 --$RCSfile: BYOP_SERVICE_PKB.sql,v $
 --$Revision: 1.205 $
 --$Author: abustos $
 --$Date: 2018/05/02 19:27:03 $
 --$ $Log: BYOP_SERVICE_PKB.sql,v $
 --$ Revision 1.205  2018/05/02 19:27:03  abustos
 --$ CR57569 - Modify proc p_cdma_byop_check to return the ICCID when the carrier is SPRINT
 --$
 --$ Revision 1.204  2018/03/20 16:42:44  tbaney
 --$ Merged with production.
 --$
 --$ Revision 1.202  2018/03/08 16:06:07  abustos
 --$ Add new Default parameter to last_vd_ig_trans in order to check for status 'HW' in ig
 --$
 --$ Revision 1.200  2018/01/31 22:26:53  mshah
 --$ CR55283 - CRM : ST BYOP CDMA is creating -111 as contact objid
 --$
 --$ Revision 1.192 2017/12/07 13:40:57 skambhammettu
 --$ ADD TRIO in SA.BYOP_SERVICE_PKG. p_cdma_byop_registration procedure to handle registration for TRIO size SIMa??s
 --$
 --$ Revision 1.190  2017/11/27 15:15:25  jcheruvathoor
 --$ CR49064  CR49064 Net10 Business APIs BYOP CDMA
 --$
 --$ Revision 1.184  2017/10/03 19:02:46  oimana
 --$ CR51833 - Package Body merged with 1.177
 --$
 --$ Revision 1.177  2017/08/18 18:43:26  jcheruvathoor
 --$ CR48202  BYOP CDMA Activation Web Registration
 --$
 --$ Revision 1.172  2017/08/01 02:59:25  mdave
 --$ CR52545 BYOP registration changes for verizon HD VOLTE
 --$
 --$ Revision 1.169  2017/07/12 21:20:02  mshah
 --$ CR51418
 --$
 --$ Revision 1.168  2017/07/11 15:29:24  mshah
 --$ CR51418 - ALLOWING VZ DISCOUNT 1 for VZ
 --$
 --$ Revision 1.164  2017/06/01 14:43:02  nkandagatla
 --$ CR49186 - Verizon Validate Device Check
 --$
 --$ Revision 1.163  2017/05/25 16:46:04  nkandagatla
 --$ CR49186 - Verizon Validate Device Check
 --$
 --$ Revision 1.162 2017/03/14 15:21:01 sgangineni
 --$ CR47564 - WFM Changes
 --$
 --$ Revision 1.161 2017/03/09 20:02:57 sgangineni
 --$ CR47564 - Modified to fix defect#21444
 --$
 --$ Revision 1.160 2017/01/23 19:54:38 sraman
 --$ CR47731-Trio SIM BYOP
 --$
 --$ Revision 1.159 2017/01/23 15:34:30 sraman
 --$ CR47731-Trio SIM BYOP
 --$
 --$ Revision 1.158 2017/01/17 21:21:52 smeganathan
 --$ CR47023 code fix Tracfone phone upgrade
 --$
 --$ Revision 1.157 2017/01/10 00:09:05 smeganathan
 --$ CR45378 changes in check activation scenario
 --$
 --$ Revision 1.156 2016/12/09 21:19:55 smeganathan
 --$ CR45378 added service end date condition in p_check_activation_scenario
 --$
 --$ Revision 1.155 2016/12/08 20:58:14 smeganathan
 --$ CR45378 merged with 12/8 prod release
 --$
 --$ Revision 1.154 2016/12/07 23:16:43 smeganathan
 --$ CR45378 added service end date condition in p_check_activation_scenario
 --$
 --$ Revision 1.153 2016/12/07 23:11:54 smeganathan
 --$ CR45378 added service end date condition in p_check_activation_scenario
 --$
 --$ Revision 1.152 2016/12/07 23:07:11 smeganathan
 --$ CR45378 added service end date condition in p_check_activation_scenario
 --$
 --$ Revision 1.151 2016/12/06 16:43:33 smeganathan
 --$ CR45378 added brand condition in p_check_activation_scenario
 --$
 --$ Revision 1.150 2016/11/23 16:55:48 pamistry
 --$ -- CR46176 Modify p_cdma_byop_check procedure to move the validate device procedure call to return LTE flag value which is calculated inside the proc.
 --$
 --$ Revision 1.149 2016/11/17 23:10:43 smeganathan
 --$ CR45378 changes done to get buy_sim
 --$
 --$ Revision 1.148 2016/11/15 23:00:17 pamistry
 --$ CR46176 - Production merge and change the CR # with new CR #
 --$
 --$ Revision 1.147 2016/10/21 18:33:34 smeganathan
 --$ Merged with 10/20 prod release
 --$
 --$ Revision 1.146 2016/10/17 15:27:32 mgovindarajan
 --$ CR45464 - Updated -111 X_PART_INST2CONTACT to be updated as NULL, so CBO can populate it with appropriate value.
 --$
 --$ Revision 1.145 2016/10/07 22:13:48 mgovindarajan
 --$ CR44390 Add new parameter to handle BYOT
 --$
 --$ Revision 1.144 2016/10/03 15:35:33 vnainar
 --$ CR44390 i_red_code validation removed in p_cdma_byop_registration procedure
 --$
 --$ Revision 1.143 2016/09/21 22:58:23 pamistry
 --$ CR46176 Added appropriate comments to the changes
 --$
 --$ Revision 1.1 2016/09/21 14:22:50 pamistry
 --$ CR46176 - Go Solution - Modify p_cdma_byop_registration procedure to skip SIM Validateion, SIM Marriage with ESN, NAC Validation and NAC Burn if the SIM size is passed instead of actual SIM value.
 --$
 /***************************************************************************************************************
 * Package Name: SA.BYOP_SERVICE_PKG
 * Description: The package is called for
 * to validate and register BYOP transaction.
 *
 * Created by: CL
 * Date: 02/18/2013
 *
 * History
 * -------------------------------------------------------------------------------------------------------------------------------------
 * 02/18/2012 CL Initial Version CR19663
 * 03/21/2013 CL 1.8 CR19663
 * 05/16/2013 CL 1.12 CR24472
 *******************************************************************************************************************/
 FUNCTION valid_reg_pin(
 p_red_code IN VARCHAR2,
 p_org_id IN VARCHAR2,
 p_part_number OUT VARCHAR2)
 RETURN VARCHAR2
IS
 CURSOR brand_curs
 IS
 SELECT bo.objid,
 pn.part_number
 FROM table_part_inst pi,
 table_mod_level ml,
 table_part_num pn,
 table_bus_org bo
 WHERE pi.x_red_code = p_red_code
 AND ml.objid = pi.n_part_inst2part_mod
 AND pn.objid = ml.part_info2part_num
 AND bo.objid = pn.part_num2bus_org
 AND bo.org_id = p_org_id;
 brand_rec brand_curs%rowtype;
BEGIN
 OPEN brand_curs;
 FETCH brand_curs INTO brand_rec;
 IF brand_curs%found THEN
 CLOSE brand_curs;
 p_part_number := brand_rec.part_number;
 RETURN 'TRUE';
 END IF;
 CLOSE brand_curs;
 RETURN 'FALSE';
END;
PROCEDURE valid_carriers_by_brand(
 p_brand IN VARCHAR2,
 p_att OUT VARCHAR2,
 p_tmo OUT VARCHAR2,
 p_verizon OUT VARCHAR2,
 p_sprint OUT VARCHAR2)
IS
 CURSOR carr_curs(c_byop_type IN VARCHAR2)
 IS
 SELECT *
 FROM sa.x_byop_part_num
 WHERE x_org_id = p_brand
 AND x_byop_type = c_byop_type;
 carr_rec carr_curs%rowtype;
BEGIN
 OPEN carr_curs('Phone');
 FETCH carr_curs INTO carr_rec;
 IF carr_curs%found THEN
 p_verizon := 'YES';
 ELSE
 p_verizon := 'NO';
 END IF;
 CLOSE carr_curs;
 OPEN carr_curs('CRS');
 FETCH carr_curs INTO carr_rec;
 IF carr_curs%found THEN
 p_sprint := 'YES';
 ELSE
 p_sprint := 'NO';
 END IF;
 CLOSE carr_curs;
 OPEN carr_curs('TMO');
 FETCH carr_curs INTO carr_rec;
 IF carr_curs%found THEN
 p_tmo := 'YES';
 ELSE
 p_tmo := 'NO';
 END IF;
 CLOSE carr_curs;
 OPEN carr_curs('ATT');
 FETCH carr_curs INTO carr_rec;
 IF carr_curs%found THEN
 p_att := 'YES';
 ELSE
 p_att := 'NO';
 END IF;
 CLOSE carr_curs;
END;
FUNCTION zip_tech_carrier(
 p_zip IN VARCHAR2,
 p_tech IN VARCHAR2)
 RETURN parent_name_object
IS
 CURSOR c1
 IS
 SELECT pn.part_number
 FROM table_x_part_class_params n2 ,
 table_x_part_class_values v2 ,
 table_x_part_class_params n ,
 table_x_part_class_values v ,
 table_part_num pn
 WHERE 1 =1
 AND v2.x_param_value = p_tech
 AND n2.x_param_name = 'TECHNOLOGY'
 AND n2.objid = v2.value2class_param
 AND v2.value2part_class = pn.part_num2part_class
 AND v.x_param_value = 'BYOP'
 AND n.x_param_name = 'DEVICE_TYPE'
 AND n.objid = v.value2class_param
 AND v.value2part_class = pn.part_num2part_class;
 CURSOR act_parent_curs
 IS
 SELECT parent_name_type(x_parent_name,x_parent_id)
 FROM table_x_parent
 WHERE upper(x_status) = 'ACTIVE'
 ORDER BY x_parent_name;
 parent_tab parent_name_object := parent_name_object();
 parent_tab2 parent_name_object := parent_name_object();
 hold VARCHAR2(30);
 cnt NUMBER := 0;
 rec_found BOOLEAN;
BEGIN
 FOR c1_rec IN c1
 LOOP
 nap_service_pkg.get_list(p_zip, NULL, c1_rec.part_number, NULL, NULL, NULL);
 IF nap_service_pkg.big_tab.count >0 THEN
 FOR i IN nap_service_pkg.big_tab.first..nap_service_pkg.big_tab.last
 LOOP
 parent_tab.extend;
 parent_tab(parent_tab.last) := parent_name_type(nap_service_pkg.big_tab(i).carrier_info.x_parent_name, nap_service_pkg.big_tab(i).carrier_info.x_parent_id );
 END LOOP;
 END IF;
 END LOOP;
 FOR c1_rec IN
 ( SELECT DISTINCT * FROM TABLE(parent_tab)
 )
 LOOP
 parent_tab2.extend;
 parent_tab2(parent_tab2.count) := parent_name_type(c1_rec.x_parent_name,c1_rec.x_parent_id);
 END LOOP;
 RETURN parent_tab2;
END;
FUNCTION hex2dec18(
 p_esn IN VARCHAR2)
 RETURN VARCHAR2
IS
FUNCTION hex2dec(
 hexnum IN VARCHAR2)
 RETURN NUMBER
IS
 i NUMBER;
 digits NUMBER;
 result NUMBER := 0;
 current_digit CHAR(1);
 current_digit_dec NUMBER;
BEGIN
 digits := LENGTH(hexnum);
 FOR i IN 1..digits
 LOOP
 current_digit := SUBSTR(hexnum, i, 1);
 IF current_digit IN ('A','B','C','D','E','F') THEN
 current_digit_dec := ASCII(current_digit) - ASCII('A') + 10;
 ELSE
 current_digit_dec := TO_NUMBER(current_digit);
 END IF;
 result := (result * 16) + current_digit_dec;
 END LOOP;
 RETURN result;
END hex2dec;
BEGIN
 IF LENGTH(p_esn) = 18 THEN
 RETURN p_esn;
 ELSE
 dbms_output.put_line(hex2dec(SUBSTR(p_esn,1,8)));
 dbms_output.put_line(lpad(hex2dec(SUBSTR(p_esn,9)),8,'0'));
 RETURN hex2dec(SUBSTR(p_esn,1,8))||lpad(hex2dec(SUBSTR(p_esn,9)),8,'0');
 END IF;
END;
FUNCTION verify_carrier_zip(
 p_part_number IN VARCHAR2,
 p_zip IN VARCHAR2)
 RETURN VARCHAR2
IS
BEGIN
 nap_SERVICE_pkg.get_list( p_zip, NULL, p_part_number, NULL, NULL, NULL);
 dbms_output.put_line('nap_SERVICE_pkg.big_tab.count:'||nap_SERVICE_pkg.big_tab.count);
 IF nap_SERVICE_pkg.big_tab.count>0 THEN
 RETURN nap_SERVICE_pkg.big_tab(1).carrier_info.objid;
 ELSE
 RETURN NULL;
 END IF;
END;
FUNCTION verify_carrier_coverage(
 P_CARRIER IN VARCHAR2,
 p_org_id IN VARCHAR2,
 P_ZIP IN VARCHAR2)
 RETURN VARCHAR2
IS
 l_default_pn VARCHAR2(30);
 hold VARCHAR2(30);
 CURSOR part_num_curs
 IS
 SELECT x_part_number
 FROM x_byop_part_num bpn
 WHERE bpn.x_org_id = p_org_id
 AND bpn.x_byop_type = DECODE(p_carrier,'VERIZON','Phone'
 ,'SPRINT','CNL',
 'TMO','TMO',
 'ATT','ATT'
 );
 part_num_rec part_num_curs%rowtype;
BEGIN
 OPEN part_num_curs;
 FETCH part_num_curs INTO part_num_rec;
 IF part_num_curs%notfound THEN
 RETURN 'NO';
 END IF;
 CLOSE part_num_curs;
 IF verify_carrier_zip(part_num_rec.x_part_number,p_zip) IS NOT NULL THEN
 RETURN 'YES';
 ELSE
 RETURN 'NO';
 END IF;
END;
FUNCTION verify_esn(
 p_esn IN VARCHAR2)
 RETURN VARCHAR2
IS
 CURSOR esn_curs
 IS
 SELECT x_part_inst_status
 FROM table_part_inst
 WHERE part_serial_no = p_esn
 AND x_domain = 'PHONES';
 esn_rec esn_curs%rowtype;
BEGIN
 OPEN esn_curs;
 FETCH esn_curs INTO esn_rec;
 CLOSE esn_curs;
 RETURN esn_rec.x_part_inst_status;
END;
FUNCTION verify_byop_esn(
 P_ESN IN VARCHAR2)
 RETURN VARCHAR2
IS
 CURSOR esn_curs
 IS
 SELECT v.x_param_value
 FROM table_part_inst pi,
 table_mod_level ml,
 table_part_num pn,
 table_x_part_class_values v,
 table_x_part_class_params n
 WHERE 1 = 1
 AND pi.part_serial_no = p_esn
 AND pi.x_domain = 'PHONES'
 AND ml.objid = pi.n_part_inst2part_mod
 AND pn.objid = ml.part_info2part_num
 AND v.value2part_class = pn.part_num2part_class
 AND v.value2class_param = n.objid
 AND v.x_param_value = 'BYOP'
 AND n.x_param_name = 'DEVICE_TYPE';
 esn_rec esn_curs%rowtype;
BEGIN
 OPEN esn_curs;
 FETCH esn_curs INTO esn_rec;
 IF esn_curs%notfound THEN
 CLOSE esn_curs;
 RETURN 'FALSE';
 END IF;
 CLOSE esn_curs;
 RETURN 'TRUE';
EXCEPTION
WHEN OTHERS THEN
 RETURN 'FALSE';
END;
PROCEDURE update_esn_new(
 p_esn IN VARCHAR2,
 p_byop_status IN VARCHAR2,
 p_BYOP_INSERTION_TYPE IN VARCHAR2,
 p_error_num OUT NUMBER,
 p_error_code OUT VARCHAR2)
IS
 CURSOR check_esn_status_curs
 IS
 SELECT x_part_inst_status
 FROM table_part_inst
 WHERE part_serial_no = p_esn
 AND x_domain = 'PHONES';
 check_esn_status_rec check_esn_status_curs%rowtype;
 CURSOR ig_trans_curs
 IS
 SELECT
 /*+ USE_INVISIBLE_INDEXES */
 X_POOL_NAME x_msl_code,
 X_MPN x_make,
 X_MPN_CODE x_model
 FROM gw1.ig_transaction ig
 WHERE esn = p_esn
 AND order_type = 'VD'
 AND status IN ('SS','S','W')
 ORDER BY ig.transaction_id DESC;
 ig_trans_rec ig_trans_curs%rowtype;
 CURSOR reg_card_dealer_curs
 IS
 SELECT ib2.objid ib_objid,
 rc.X_RED_DATE,
 s2.objid s_objid,
 ct.objid ct_objid
 FROM table_x_call_trans ct,
 table_x_red_card rc,
 table_inv_bin ib2,
 table_site s2
 WHERE 1 = 1
 AND ct.x_service_id = p_esn
 AND ct.x_min = p_esn
 AND rc.RED_CARD2CALL_TRANS = ct.objid
 AND ib2.objid = rc.X_RED_CARD2INV_BIN
 AND s2.site_id = ib2.bin_name;
 reg_card_dealer_rec reg_card_dealer_curs%rowtype;
BEGIN
 IF p_byop_status NOT IN ('TRUE', 'FALSE') THEN
 p_error_num := 1;
 p_error_code := 'INVALID P_BYOP_STATUS';
 END IF;
 IF p_BYOP_INSERTION_TYPE NOT IN ('VRZ_UPG','VRZ_NEW') THEN
 p_error_num := 2;
 p_error_code := 'INVALID P_BYOP_INSERTION_TYPE';
 RETURN;
 END IF;
 IF p_byop_status = 'FALSE' THEN
 IF p_BYOP_INSERTION_TYPE = 'VRZ_UPG' THEN
 UPDATE sa.table_x_byop xb
 SET xb.x_cdma_port_counter = xb.x_cdma_port_counter+1
 WHERE xb.x_esn = p_esn;
 p_error_num := 0;
 RETURN;
 elsif p_BYOP_INSERTION_TYPE = 'VRZ_NEW' THEN
 DELETE FROM sa.table_x_byop WHERE x_esn = p_esn;
 p_error_num := 0;
 RETURN;
 END IF;
 END IF;
 OPEN check_esn_status_curs;
 FETCH check_esn_status_curs INTO check_esn_status_rec;
 IF check_esn_status_curs%notfound THEN
 CLOSE check_esn_status_curs;
 p_error_num := 3;
 p_error_code := 'P_ESN NOT FOUND IN SYSTEM';
 RETURN;
 elsif check_esn_status_rec.x_part_inst_status != '151' THEN
 CLOSE check_esn_status_curs;
 p_error_num := 4;
 p_error_code := 'P_ESN STATUS NOT BYOP_PENDING';
 RETURN;
 END IF;
 CLOSE check_esn_status_curs;
 OPEN reg_card_dealer_curs; --CR24770
 FETCH reg_card_dealer_curs INTO reg_card_dealer_rec;
 IF reg_card_dealer_curs%notfound THEN
 reg_card_dealer_rec.ib_objid := NULL;
 ELSE
 UPDATE table_x_call_trans
 SET x_call_trans2dealer = reg_card_dealer_rec.s_objid
 WHERE objid =reg_card_dealer_rec.ct_objid;
 END IF;
 CLOSE reg_card_dealer_curs;
 UPDATE table_part_inst
 SET x_part_inst_status = '50',
 STATUS2X_CODE_TABLE =
 (SELECT objid FROM table_x_code_table WHERE x_code_number = '50'
 ),
 part_inst2inv_bin = NVL(reg_card_dealer_rec.ib_objid, part_inst2inv_bin), --CR24770
 X_PART_INST2CONTACT  = DECODE(X_PART_INST2CONTACT, -111, NULL, X_PART_INST2CONTACT) --CR55283 changing -111 to NULL
 WHERE part_serial_no = p_esn
 AND x_domain = 'PHONES';
 OPEN ig_trans_curs;
 FETCH ig_trans_curs INTO ig_trans_rec;
 IF ig_trans_curs%found AND ig_trans_rec.x_msl_code IS NOT NULL THEN
 UPDATE table_x_byop
 SET X_BYOP_MANUFACTURER = ig_trans_rec.x_make,
 X_BYOP_MODEL = ig_trans_rec.x_model
 WHERE x_esn = p_esn;
 END IF;
 CLOSE ig_trans_curs;
 p_error_num := 0;
EXCEPTION
WHEN OTHERS THEN
 ROLLBACK;
 p_error_num := 99;
 p_error_code := SQLERRM;
END;
PROCEDURE last_vd_ig_trans ( p_esn IN VARCHAR2,
 p_bus_org IN VARCHAR2,
 p_phone_gen OUT VARCHAR2, ------> LTE, NON_LTE
 p_phone_model OUT VARCHAR2, ------> APPL
 p_technology OUT VARCHAR2, ------> CDMA
 p_sim_reqd OUT VARCHAR2, ------> YES,NO
 p_original_sim OUT VARCHAR2, ------> 1234567890756735
 p_carrier OUT VARCHAR2,
 p_error_num OUT NUMBER,
 p_error_code OUT VARCHAR2 ) IS
 CURSOR last_ig_curs IS
 SELECT /*+ USE_INVISIBLE_INDEXES */
 (CASE
 WHEN template = 'SPRINT' THEN iccid
 ELSE null
 END) S_iccid,
 (CASE
 WHEN template = 'SPRINT' AND (UPPER(status_message) LIKE '%APPLE%') AND (UPPER(STATUS_MESSAGE) NOT LIKE '%IPHONE 4%') THEN 'IPHONE'
 ELSE 'OTHER'
 END) s_phone_model,
 (CASE
 WHEN template = 'SPRINT' AND iccid IS NULL THEN 'NON_LTE'
 WHEN template = 'SPRINT' AND (UPPER(status_message) LIKE '%DEVICETYPE=E%' or UPPER(status_message) LIKE '%DEVICETYPE=U%') THEN 'LTE'
 END) s_phone_gen,
 (CASE
 WHEN template= 'SPRINT' AND (iccid IS NULL or UPPER(status_message) like '%DEVICETYPE=E%') THEN 'NO'
 WHEN template= 'SPRINT' AND (UPPER(status_message) LIKE '%DEVICETYPE=U%') THEN 'YES'
 END) s_sim_reqd,
 (CASE
 WHEN template = 'RSS' AND UPPER(ig.x_mpn) LIKE '%APL%' THEN 'IPHONE'
 ELSE 'OTHER'
 END) v_phone_model,
 (CASE
 WHEN template ='RSS' AND UPPER(ig.x_pool_name) LIKE '%4G%' THEN 'LTE'
 ELSE 'NON_LTE'
 END) v_phone_gen,
 (CASE
 WHEN template = 'RSS' AND UPPER(ig.x_pool_name) LIKE '%4G%' THEN 'YES'
 ELSE 'NO'
 END) v_sim_reqd,
 ig.*
 FROM gw1.ig_transaction ig
 WHERE esn = p_esn
 AND order_type = 'VD'
 ORDER BY ig.transaction_id DESC;
 last_ig_rec last_ig_curs%ROWTYPE;
BEGIN
 OPEN last_ig_curs;
 FETCH last_ig_curs INTO last_ig_rec;
 IF last_ig_curs%notfound THEN
 CLOSE last_ig_curs;
 p_error_num := 1;
 p_error_code := 'NO TRANSACTION FOUND';
 RETURN;
 END IF;
 CLOSE last_ig_curs;
 --
 IF last_ig_rec.status IN ('CP','L', 'Q') THEN
 p_error_num := 4;
 p_error_code := 'PENDING';
 RETURN;
 elsif last_ig_rec.status IN ('FF','F','E') THEN --CR 24472
 IF upper(last_ig_rec.status_message) LIKE '%DISCOUNT_1%' -- CR 37906
 AND p_bus_org in ('TOTAL_WIRELESS', 'STRAIGHT_TALK')   -- CR40663 --CR42933 Added 'STRAIGHT_TALK'
 THEN
 p_error_code := 'ESN UNDER CONTRACT';
 p_error_num := 6;
 RETURN;
 END IF;
 p_error_num := 3;
 p_error_code := 'NOT ELIGIBLE';
 RETURN;
 elsif last_ig_rec.status IN ('SS','S','W') and last_ig_rec.template = 'SPRINT' THEN
 p_error_num := 2;
 if upper(last_ig_rec.status_message) LIKE '%ESN_IN_USE%' then
 p_error_code := 'ELIGIBLE ACTIVE';
 else
 p_error_code := 'ELIGIBLE INACTIVE';
 end if;
 p_carrier := 'SPRINT';
 p_technology := 'CDMA';
 p_phone_model := last_ig_rec.s_phone_model;
 p_phone_gen := last_ig_rec.s_phone_gen;
 p_sim_reqd := last_ig_rec.s_sim_reqd;
 p_original_sim := last_ig_rec.s_iccid;
 RETURN;
 -- Added logic by Juda Pena to block 4G LTE BYOP for Total Wireless (CR39921)
 /*ELSIF last_ig_rec.status IN ('SS','S','W') AND
 p_bus_org = 'TOTAL_WIRELESS' AND
 UPPER(last_ig_rec.x_pool_name) LIKE '%4G%'
 THEN
 p_error_num := 3;
 p_error_code := 'NOT ELIGIBLE';
 p_carrier := 'VERIZON';
 p_technology := 'CDMA';
 p_phone_model := last_ig_rec.v_phone_model;
 p_phone_gen := last_ig_rec.v_phone_gen;
 p_sim_reqd := last_ig_rec.v_sim_reqd;
 RETURN;*/
 -- End logic by Juda Pena to block 4G LTE BYOP for Total Wireless (CR39921)
 ELSIF last_ig_rec.status IN ('SS','S','W') THEN
 p_error_num := 2;
 p_error_code := 'ELIGIBLE';
 p_carrier := 'VERIZON';
 p_technology := 'CDMA';
 p_phone_model := last_ig_rec.v_phone_model;
 p_phone_gen := last_ig_rec.v_phone_gen;
  --CR52545 Modify BYOP registration Service to assign HD part class for Verizon VOLTE, mdave, 07/26/2017
  IF last_ig_rec.v_phone_gen = 'LTE' THEN
    IF UPPER(last_ig_rec.status_message) LIKE UPPER('%HDVoice=Y%') THEN
        p_phone_gen := 'LTE_HD';
      ELSE
        p_phone_gen := 'LTE';
      END IF;
  END IF;
  --END CR52545 Modify BYOP registration Service to assign HD part class for Verizon VOLTE, mdave, 07/26/2017
 p_sim_reqd := last_ig_rec.v_sim_reqd;
 RETURN;
 ELSE
 p_error_num := 5;
 p_error_code := 'INVALID STATUS';
 RETURN;
 END IF;
 EXCEPTION
 WHEN OTHERS THEN
 p_error_num := 99;
 p_error_code := SQLERRM;
END last_vd_ig_trans;

PROCEDURE st_last_vd_ig_trans(
 P_ESN IN VARCHAR2,
 p_carrier OUT VARCHAR2,
 p_error_num OUT NUMBER,
 p_error_code OUT VARCHAR2)
IS
 CURSOR last_ig_curs(c_template IN VARCHAR2)
 IS
 SELECT
 /*+ USE_INVISIBLE_INDEXES */
 ig.status,
 ig.x_pool_name,
 (SELECT bo.org_id
 FROM table_part_inst pi,
 table_mod_level ml,
 table_part_num pn,
 table_bus_org bo
 WHERE 1 =1
 AND pi.part_serial_no = ig.esn
 AND ml.objid = pi.n_part_inst2part_mod
 AND pn.objid = ml.part_info2part_num
 AND bo.objid = pn.part_num2bus_org
 ) org_id
 FROM gw1.ig_transaction ig
 WHERE ig.esn = p_esn
 AND ig.order_type = 'VD'
 AND ig.template = c_template
 ORDER BY ig.transaction_id DESC;
 last_ig_rec last_ig_curs%rowtype;
 last_ig_rec2 last_ig_curs%rowtype;
 /*
 -- instantiate initial values
 rc sa.customer_type := customer_type ( i_esn => p_esn );

 -- type to hold retrieved attributes
 cst sa.customer_type;
 */
BEGIN
 OPEN last_ig_curs('RSS');
 FETCH last_ig_curs INTO last_ig_rec;
 IF last_ig_curs%notfound THEN
 CLOSE last_ig_curs;
 p_error_num := 1;
 p_error_code := 'NO TRANSACTION FOUND';
 RETURN;
 END IF;
 CLOSE last_ig_curs;

 -- Added logic by Juda Pena to block 4G LTE BYOP for Total Wireless
 /*
 IF last_ig_rec.org_id = 'TOTAL_WIRELESS' AND
 last_ig_rec.status IN ('SS','S','W') AND
 last_ig_rec.x_pool_name = '4G'
 THEN
 --
 p_error_num := 3;
 p_error_code := 'NOT ELIGIBLE';
 --
 RETURN;

 -- End logic by Juda Pena to block 4G LTE BYOP for Total Wireless

 ELSIF last_ig_rec.org_id = 'TOTAL_WIRELESS' AND last_ig_rec.status IN ('SS','S','W') AND last_ig_rec.x_pool_name = '4G' THEN */
 IF last_ig_rec.org_id = 'TOTAL_WIRELESS' AND last_ig_rec.status IN ('SS','S','W') AND last_ig_rec.x_pool_name = '4G' THEN
 --- Error code changed to Eligible as part of Verizon 4g LTE handsets project CR 37906, changed the error code to 2 from 3.
 p_error_num := 2;
 p_error_code := 'ELIGIBLE';
 -- Added this line as part of returning carrier for the 4G lte TW/VZ project
 p_carrier := 'VERIZON';
 RETURN;
 elsif last_ig_rec.status IN ('SS','S','W') THEN
 p_error_num := 2;
 p_error_code := 'ELIGIBLE';
 p_carrier := 'VERIZON';
 RETURN;
 elsif last_ig_rec.status IN ('FF','F','E') THEN --CR 24472
 p_error_num := 3;
 p_error_code := 'NOT ELIGIBLE';

 RETURN;
 elsif last_ig_rec.status IN ('CP','L', 'Q') THEN
 p_error_num := 4;
 p_error_code := 'PENDING';
 RETURN;
 ELSE
 p_error_num := 5;
 p_error_code := 'INVALID STATUS';
 RETURN;
 END IF;
 p_error_num := 0;
EXCEPTION
WHEN OTHERS THEN
 p_error_num := 99;
 p_error_code := SQLERRM;
END;

PROCEDURE insert_vd_ig_trans( -- SPRINT
 p_esn IN VARCHAR2,
 p_error_num OUT NUMBER,
 p_error_code OUT VARCHAR2)
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
 -- removing the VD entry for Verizon CR28514 + BYOP finder project
 -- INSERT
 -- INTO gw1.ig_transaction
 -- (
 -- action_item_id,
 -- esn,
 -- esn_hex,
 -- order_type,
 -- template,
 -- account_num,
 -- status,
 -- TRANSACTION_ID
 -- )
 -- VALUES
 -- (
 -- sa.sequ_action_item_id.NEXTVAL,
 -- p_esn,
 -- SA.MEIDDECTOHEX(p_esn),
 -- 'VD',
 -- 'RSS',
 -- '1161',
 -- 'Q',
 -- (gw1.trans_id_seq.nextval + (POWER(2 ,28)))
 -- );
 INSERT
 INTO gw1.ig_transaction
 (
 action_item_id,
 esn,
 esn_hex,
 order_type,
 template,
 account_num,
 status,
 TRANSACTION_ID
 )
 VALUES
 (
 sa.sequ_action_item_id.NEXTVAL,
 p_esn,
 sa.MEIDDECTOHEX(p_esn),
 'VD',
 'SPRINT',
 '1161',
 'Q',
 (gw1.trans_id_seq.nextval + (POWER(2 ,28)))
 );
 COMMIT;
 p_error_num := 0;
EXCEPTION
WHEN OTHERS THEN
 ROLLBACK;
 p_error_num := 99;
 p_error_code := SQLERRM;
END;
PROCEDURE st_insert_vd_ig_trans -- RSS
 (
 p_esn IN VARCHAR2,
 p_error_num OUT NUMBER,
 p_error_code OUT VARCHAR2
 )
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
 INSERT
 INTO gw1.ig_transaction
 (
 action_item_id,
 esn,
 esn_hex,
 order_type,
 template,
 account_num,
 status,
 TRANSACTION_ID
 )
 VALUES
 (
 sa.sequ_action_item_id.NEXTVAL,
 p_esn,
 sa.MEIDDECTOHEX(p_esn),
 'VD',
 'RSS',
 '1161',
 'Q',
 (gw1.trans_id_seq.nextval + (POWER(2 ,28)))
 );
 COMMIT;
 p_error_num := 0;
EXCEPTION
WHEN OTHERS THEN
 ROLLBACK;
 p_error_num := 99;
 p_error_code := SQLERRM;
END;
PROCEDURE insert_byop_tracking
 (
 p_esn IN VARCHAR2,
 p_byop_type IN VARCHAR2,
 p_byop_manufacturer IN VARCHAR2,
 p_byop_model IN VARCHAR2,
 p_error_num OUT NUMBER,
 p_error_code OUT VARCHAR2
 )
IS
BEGIN
 INSERT
 INTO sa.table_x_byop
 (
 OBJID,
 X_ESN,
 X_BYOP_TYPE,
 X_BYOP_MANUFACTURER,
 X_BYOP_MODEL,
 X_CDMA_PORT_COUNTER
 )
 VALUES
 (
 sa.sequ_x_byop.nextval,
 p_esn,
 p_byop_type,
 p_byop_manufacturer,
 p_byop_model,
 1
 );
EXCEPTION
WHEN OTHERS THEN
 ROLLBACK;
 p_error_num := 99;
 p_error_code := SQLERRM;
END;

PROCEDURE INSERT_ESN_PRENEW
 (
 p_esn IN VARCHAR2,
 p_old_esn IN VARCHAR2,
 p_org_id IN VARCHAR2,
 p_byop_type IN VARCHAR2,
 p_BYOP_MANUFACTURER IN VARCHAR2,
 p_BYOP_MODEL IN VARCHAR2,
 p_BYOP_INSERTION_TYPE IN VARCHAR2,
 p_error_num OUT NUMBER,
 p_error_code OUT VARCHAR2,
 p_sim IN VARCHAR2,
 p_zip IN VARCHAR2 -- CR28514
 -- CR41804
 ,ip_NAC_offer_flag IN VARCHAR2   DEFAULT NULL
 ,ip_SP_offer_flag  IN VARCHAR2   DEFAULT NULL
 ,ip_carrier_name IN VARCHAR2 DEFAULT NULL
 -- CR41804
 ,p_part_num OUT VARCHAR2  -- CR48202
 )
IS
--Commenting as part of CR28514
 --CURSOR ig_trans_curs
 --IS
 -- SELECT
 -- /*+ USE_INVISIBLE_INDEXES */
 -- X_POOL_NAME x_msl_code,
 -- X_MPN x_make,
 -- X_MPN_CODE x_model
 -- FROM gw1.ig_transaction ig
 -- WHERE esn = p_esn
 -- AND order_type = 'VD'
 -- AND status IN ('SS','S','W')
 -- AND template = 'RSS' --CR28183
 -- AND X_MPN = 'APL'; --CR28183
 --ig_trans_rec ig_trans_curs%rowtype;
 CURSOR reg_card_dealer_curs
 IS
 SELECT ib2.objid ib_objid,
 rc.X_RED_DATE
 FROM table_x_call_trans ct,
 table_x_red_card rc,
 table_inv_bin ib2,
 table_site s2
 WHERE 1 = 1
 AND ct.x_service_id = p_esn
 AND ct.x_min = p_esn
 AND rc.RED_CARD2CALL_TRANS = ct.objid
 AND ib2.objid = rc.X_RED_CARD2INV_BIN
 AND s2.site_id = ib2.bin_name
 UNION
 SELECT ib2.objid ib_objid,
 rc.X_RED_DATE
 FROM table_x_call_trans ct,
 table_x_red_card rc,
 table_inv_bin ib2,
 table_site s2
 WHERE 1 = 1
 AND ct.x_service_id = p_old_esn
 AND ct.x_min = p_old_esn
 AND rc.RED_CARD2CALL_TRANS = ct.objid
 AND ib2.objid = rc.X_RED_CARD2INV_BIN
 AND s2.site_id = ib2.bin_name
 ORDER BY X_RED_DATE DESC;
 --
 reg_card_dealer_rec reg_card_dealer_curs%rowtype;
 --
 CURSOR part_num_curs(c_byop_type IN VARCHAR2)
 IS
 SELECT pn.part_number,
 pn.part_num2part_class pclass_objid,
 NVL(
 (SELECT 1
 FROM table_x_part_class_values v,
 table_x_part_class_params n
 WHERE 1 = 1
 AND v.value2part_class = pn.part_num2part_class
 AND v.value2class_param = n.objid
 AND n.x_param_name = 'CDMA LTE SIM'
 AND v.x_param_value = 'REMOVABLE'
 ),0) is_lte_cdma,
 ml.objid mod_level_objid
 FROM table_mod_level ml,
 table_part_num pn,
 x_byop_part_num bpn
 WHERE 1 = 1
 AND bpn.x_org_id = p_org_id
 AND UPPER(bpn.x_byop_type) = UPPER(c_byop_type)
 AND pn.part_number = bpn.x_part_number
 AND ml.part_info2part_num = pn.objid ;
 --
 part_num_rec part_num_curs%rowtype;
 --
 CURSOR sim_part_num_curs (p_sim IN VARCHAR2)
 IS
 SELECT pn.part_number
 FROM table_x_sim_inv sim ,
 table_mod_level ml ,
 table_part_num pn ,
 table_part_class pc
 WHERE 1 =1
 AND sim.x_sim_serial_no = p_sim
 AND sim.X_SIM_INV2PART_MOD = ml.objid
 AND ml.PART_INFO2PART_NUM = pn.objid
 AND pn.part_num2part_class = pc.objid ;
 --
 sim_part_num_rec sim_part_num_curs%rowtype;
 --
 CURSOR sim_status_curs (p_sim IN VARCHAR2)
 IS
 SELECT
 /*+ USE_INVISIBLE_INDEXES */
 x_sim_serial_no
 FROM table_x_sim_inv sim
 WHERE 1 =1
 AND sim.x_sim_serial_no = p_sim
 AND sim.x_sim_inv_status IN ('251','253','254');
 --
 sim_status_rec sim_status_curs%rowtype;
 --
 CURSOR sprint_sim_mod_curs (in_sim_pnum IN VARCHAR2)
 IS
 SELECT ml.objid
 FROM table_mod_level ml,
 table_part_num pn
 WHERE ml.PART_INFO2PART_NUM=pn.objid--added for CR37156
 and pn.part_number = in_sim_pnum;
 --
 sprint_sim_mod_rec sprint_sim_mod_curs%rowtype;
 --
 CURSOR user_curs
 IS
 SELECT objid FROM table_user WHERE s_login_name = 'SA';
 --
 user_rec user_curs%rowtype;
 --
 CURSOR old_esn_curs
 IS
 SELECT * FROM table_x_byop WHERE x_esn = p_old_esn;
 --
 old_esn_rec old_esn_curs%rowtype;
 --
 CURSOR esn_curs
 IS
 SELECT * FROM table_part_inst WHERE part_serial_no = p_esn;
 --
 esn_rec esn_curs%rowtype;
 --CR35712
 CURSOR branded_esn_curs is
 SELECT esn.part_serial_no esn ,
 ESN.OBJID,
 ESN.X_PART_INST_STATUS STATUS,
 tpn.x_technology technology ,
 TBO.ORG_ID BRAND ,
 ESN.X_ICCID SIM,
 line.part_serial_no MIN,
 tpn.part_number part_num,
 pc.name part_class
 FROM TABLE_PART_INST ESN,
 table_part_inst line,
 TABLE_MOD_LEVEL TML,
 TABLE_PART_NUM TPN,
 TABLE_PART_Class pc,
 TABLE_BUS_ORG TBO
 WHERE 1 = 1
 AND ESN.N_PART_INST2PART_MOD = TML.OBJID
 AND TML.PART_INFO2PART_NUM = TPN.OBJID
 AND TPN.PART_NUM2BUS_ORG = TBO.OBJID
 AND tpn.part_num2part_class = pc.objid
 AND ESN.PART_SERIAL_NO = p_old_esn
 AND ESN.X_DOMAIN = 'PHONES'
 AND LINE.PART_TO_ESN2PART_INST(+) = ESN.OBJID
 AND line.x_domain(+) = 'LINES'
 AND TBO.ORG_ID = 'TOTAL_WIRELESS'
 AND NOT EXISTS (SELECT X_ESN from sa.TABLE_X_NAC_TRANS
 WHERE X_ESN = p_old_esn);
 --
 branded_esn_rec branded_esn_curs%rowtype;
 --end CR35712
 default_date DATE := to_date('01-JAN-1753','DD-MON-YYYY'); --CR26363
 l_carrier VARCHAR2(100);
 l_error_num NUMBER;
 l_error_code VARCHAR2(100);
 l_phone_gen VARCHAR2(100);
 l_phone_model VARCHAR2(100);
 l_technology VARCHAR2(100);
 l_sim_reqd VARCHAR2(100);
 l_original_sim VARCHAR2(100);
 l_esn_hex VARCHAR2(100);
 L_ACTION VARCHAR2(4000); -- to write to error_table
 L_INPUTS VARCHAR2(4000); -- to write to error_table
 V_COUNT NUMBER := 0;
 ---  CR41804
  lv_byop_inv_bin_objid table_inv_bin.objid%type;
  out_free_soft_pin table_part_inst.x_red_code%type;
  out_smp_number    table_part_inst.part_serial_no%type;

CURSOR cur_get_byop_offers is
SELECT pin_part_number
FROM table_x_byop_offers
WHERE bus_org_id  =   p_org_id
AND carrier     = ip_carrier_name
AND offer_key   = 'SP'
AND active_flag   = 'Y'
AND ROWNUM    = 1
;

rec_byop_offers cur_get_byop_offers%rowtype;
 ---  CR41804


 -- CR31456 Changes Starts.
 PROCEDURE p_validate_load_sim (p_sim IN VARCHAR2)
 IS
 BEGIN
 OPEN sim_part_num_curs (p_sim);
 FETCH sim_part_num_curs INTO sim_part_num_rec;
 IF sim_part_num_curs%notfound AND l_carrier = 'VERIZON' THEN
 CLOSE sim_part_num_curs;
 L_ACTION := 'L_ACTION :=' || 'sim_part_num_curs (' || p_sim || ')';
 INSERT
 INTO error_table
 (
 ERROR_TEXT,
 ERROR_DATE,
 ACTION,
 KEY,
 PROGRAM_NAME
 )
 VALUES
 (
 'sim_part_num_curs%notfound AND l_carrier = VERIZON',
 sysdate,
 L_INPUTS,
 p_esn,
 'SA.BYOP_SERVICE_PKG.INSERT_ESN_PRENEW'
 );
 INSERT
 INTO error_table
 (
 ERROR_TEXT,
 ERROR_DATE,
 ACTION,
 KEY,
 PROGRAM_NAME
 )
 VALUES
 (
 'sim_part_num_curs%notfound AND l_carrier = VERIZON',
 sysdate,
 L_ACTION,
 p_esn,
 'SA.BYOP_SERVICE_PKG.INSERT_ESN_PRENEW'
 );
 p_error_num := 6;
 p_error_code := 'SIM PART NUMBER NOT FOUND';
 RETURN;
 ELSIF sim_part_num_curs%notfound AND l_carrier = 'SPRINT' AND l_phone_model IN('IPHONE','OTHER') THEN
 CLOSE sim_part_num_curs;
 IF p_zip IS NULL THEN
 L_ACTION := 'L_ACTION :=' || 'p_zip IS NULL - therefore cannot obtain compatible sim part num';
 INSERT
 INTO error_table
 (
 ERROR_TEXT,
 ERROR_DATE,
 ACTION,
 KEY,
 PROGRAM_NAME
 )
 VALUES
 (
 'sim_part_num_curs%notfound AND l_carrier = SPRINT AND l_phone_model = IPHONE',
 sysdate,
 L_INPUTS,
 p_esn,
 'SA.BYOP_SERVICE_PKG.INSERT_ESN_PRENEW'
 );
 INSERT
 INTO error_table
 (
 ERROR_TEXT,
 ERROR_DATE,
 ACTION,
 KEY,
 PROGRAM_NAME
 )
 VALUES
 (
 'sim_part_num_curs%notfound AND l_carrier = SPRINT AND l_phone_model = IPHONE',
 sysdate,
 L_ACTION,
 p_esn,
 'SA.BYOP_SERVICE_PKG.INSERT_ESN_PRENEW'
 );
 ELSE
 sa.nap_service_pkg.get_list(p_zip,NULL,part_num_rec.part_number,NULL,NULL,NULL);
 IF sa.nap_SERVICE_pkg.big_tab.count>0 THEN
 OPEN sprint_sim_mod_curs (sa.nap_SERVICE_pkg.big_tab(1).carrier_info.sim_profile);
 FETCH sprint_sim_mod_curs INTO sprint_sim_mod_rec;
 CLOSE sprint_sim_mod_curs;
 --- CR28514 (insert the Sprint LTE sim in inventory if its not already there)
 INSERT
 INTO sa.TABLE_X_SIM_INV
 (
 OBJID,
 X_SIM_SERIAL_NO,
 X_SIM_INV_STATUS,
 X_INV_INSERT_DATE,
 X_LAST_UPDATE_DATE,
 X_SIM_INV2PART_MOD,
 X_CREATED_BY2USER,
 X_SIM_STATUS2X_CODE_TABLE
 )
 VALUES
 (
 sa.sequ_x_sim_inv.NEXTVAL, -- OBJID,
 p_sim, -- X_SIM_SERIAL_NO,
 '253', -- X_SIM_INV_STATUS,
 sysdate, -- X_INV_INSERT_DATE,
 sysdate, -- X_LAST_UPDATE_DATE,
 sprint_sim_mod_rec.objid, -- X_SIM_INV2PART_MOD,
 user_rec.objid, -- X_CREATED_BY2USER,
 (SELECT objid
 FROM table_x_code_table
 WHERE X_CODE_NAME = 'SIM NEW'
 AND X_CODE_TYPE = 'SIM'
 ) -- X_SIM_STATUS2X_CODE_TABLE
 );
 ELSE
 L_ACTION := 'L_ACTION :=' || 'sa.nap_service_pkg.get_list(' || p_zip || ',' || p_esn || ',' || part_num_rec.part_number || ',' || 'null,null,null)';
 INSERT
 INTO error_table
 (
 ERROR_TEXT,
 ERROR_DATE,
 ACTION,
 KEY,
 PROGRAM_NAME
 )
 VALUES
 (
 'sa.nap_SERVICE_pkg.big_tab.count = 0 - no compatible SPRINT LTE sim pnum found',
 sysdate,
 L_INPUTS,
 p_esn,
 'BYOP_SERVICE_PKG.INSERT_ESN_PRENEW'
 );
 INSERT
 INTO error_table
 (
 ERROR_TEXT,
 ERROR_DATE,
 ACTION,
 KEY,
 PROGRAM_NAME
 )
 VALUES
 (
 'sa.nap_SERVICE_pkg.big_tab.count = 0 - no compatible SPRINT LTE sim pnum found',
 sysdate,
 L_ACTION,
 p_esn,
 'SA.BYOP_SERVICE_PKG.INSERT_ESN_PRENEW'
 );
 p_error_num := 6;
 p_error_code := 'SIM PART NUMBER NOT FOUND';
 RETURN;
 END IF;
 END IF;
 ELSIF sim_part_num_curs%found AND l_carrier IN ('VERIZON','SPRINT') THEN
 CLOSE sim_part_num_curs;
 OPEN sim_status_curs(p_sim);
 FETCH sim_status_curs INTO sim_status_rec;
 IF sim_status_curs%FOUND THEN
 CLOSE sim_status_curs;
 UPDATE table_part_inst SET x_iccid = p_sim WHERE PART_SERIAL_NO = p_esn;
 ELSE
 CLOSE sim_status_curs;
 L_ACTION := 'L_ACTION :=' || 'sim_status_curs (' || p_sim || ')';
 INSERT
 INTO error_table
 (
 ERROR_TEXT,
 ERROR_DATE,
              ACTION,
              KEY,
              PROGRAM_NAME
            )
            VALUES
            (
              'sim_status_curs%notfound',
              sysdate,
              L_INPUTS,
              p_esn,
              'BYOP_SERVICE_PKG.INSERT_ESN_PRENEW'
            );
          INSERT
          INTO error_table
            (
              ERROR_TEXT,
              ERROR_DATE,
              ACTION,
              KEY,
              PROGRAM_NAME
            )
            VALUES
            (
              'sim_status_curs%notfound',
              sysdate,
              L_ACTION,
              p_esn,
              'BYOP_SERVICE_PKG.INSERT_ESN_PRENEW'
            );
          p_error_num  := 7;
          p_error_code := 'SIM STATUS NOT VALID';
          RETURN;
       END IF;
   END IF;
  END p_validate_load_sim;
 -- CR31456 Changes Ends.
BEGIN -- insert_esn_prenew
  L_INPUTS := 'L_INPUTS := ' || 'insert_esn_prenew(' ||p_esn ||',' ||p_old_esn ||',' ||p_org_id ||',' ||p_byop_type ||',' || p_byop_manufacturer ||',' ||p_byop_model ||',' ||p_byop_insertion_type ||',' ||p_error_num ||',' ||p_error_code ||',' ||p_sim||','||p_zip||','||ip_NAC_offer_flag||','||ip_SP_offer_flag||','||ip_carrier_name ||')';
  OPEN esn_curs;
  FETCH esn_curs INTO esn_rec;
  IF esn_curs%found AND esn_rec.x_part_inst_status != '151' THEN
    CLOSE esn_curs;
    p_error_num := 6;
    p_error_code := 'ESN HAS INVALID PART STATUS';
    RETURN;
  END IF;
  CLOSE esn_curs;
  IF p_BYOP_INSERTION_TYPE = 'VRZ_UPG' AND p_old_esn IS NULL THEN
    p_error_num := 1;
    p_error_code := 'UPGRADE MISSING OLD ESN';
    RETURN;
  elsif p_BYOP_INSERTION_TYPE = 'VRZ_UPG' AND p_old_esn IS NOT NULL THEN
    OPEN old_esn_curs;
    FETCH old_esn_curs INTO old_esn_rec;
    OPEN branded_esn_curs; --CR35712
    FETCH branded_esn_curs INTO branded_esn_rec;
    SELECT COUNT(1) INTO V_COUNT FROM sa.TABLE_X_NAC_TRANS WHERE X_ESN = p_old_esn;
    IF old_esn_curs%notfound and branded_esn_curs%NOTFOUND THEN
      IF V_COUNT > 0 THEN
        p_error_num := 8;
        p_error_code := 'FREE NAC USED ALREADY';
      ELSE
        p_error_num := 2;
        p_error_code := 'OLD ESN NOT FOUND';
      END IF;
      CLOSE old_esn_curs;
      CLOSE branded_esn_curs;
      RETURN;
    ELSIF old_esn_rec.x_cdma_port_counter =0 THEN
      IF V_COUNT > 0 THEN
        p_error_num := 8;
        p_error_code := 'FREE NAC USED ALREADY';
      ELSE
        p_error_num := 3;
        p_error_code := 'OLD ESN PORT COUNTER 0';
      END IF;
      CLOSE old_esn_curs;
      CLOSE branded_esn_curs;
      RETURN;
    END IF;
    CLOSE old_esn_curs;
    CLOSE branded_esn_curs;
    --
    IF P_ORG_ID = 'TOTAL_WIRELESS' THEN
      DBMS_OUTPUT.PUT_LINE('Insert into TABLE_X_NAC_TRANS');
      INSERT INTO sa.TABLE_X_NAC_TRANS
      (
      OBJID,
      X_ESN,
      X_BRAND,
      X_NAC_FLAG,
      NAC2PARTINST)
      VALUES
      (
      sa.SEQU_NAC_TRANS.NEXTVAL,
      p_old_esn,
      P_ORG_ID,
      'Y',
      NULL
      );
      UPDATE sa.table_x_byop
      SET x_cdma_port_counter = old_esn_rec.x_cdma_port_counter -1
      WHERE x_esn = p_old_esn;
      INSERT INTO sa.table_x_byop
      ( OBJID,
      X_ESN,
      X_BYOP_TYPE,
      X_BYOP_MANUFACTURER,
      X_BYOP_MODEL,
      X_CDMA_PORT_COUNTER
      )
      VALUES
      ( sa.sequ_x_byop.nextval,
      p_esn,
      p_byop_type,
      NULL, --CR28514 --ig_trans_rec.x_make,
      NULL, --CR28514 --ig_trans_rec.x_model,
      1 --CR35712 --(old_esn_rec.x_cdma_port_counter -1)
      ); --END CR35712
    ELSE
      UPDATE sa.table_x_byop
      SET x_cdma_port_counter = old_esn_rec.x_cdma_port_counter -1
      WHERE x_esn = p_old_esn;
      --Commenting as part of CR28514
      --OPEN ig_trans_curs;
      --FETCH ig_trans_curs INTO ig_trans_rec;
      --CLOSE ig_trans_curs;
      INSERT
      INTO sa.table_x_byop
      (
      OBJID,
      X_ESN,
      X_BYOP_TYPE,
      X_BYOP_MANUFACTURER,
      X_BYOP_MODEL,
      X_CDMA_PORT_COUNTER
      )
      VALUES
      (
      sa.sequ_x_byop.nextval,
      p_esn,
      p_byop_type,
      NULL, --CR28514 --ig_trans_rec.x_make,
      NULL, --CR28514 --ig_trans_rec.x_model,
      (old_esn_rec.x_cdma_port_counter -1)
      );
    END IF;
  elsif p_BYOP_INSERTION_TYPE IN ('VRZ_NEW','WARP_NEW') THEN -- CR31456 added string WARP_NEW
    DELETE FROM sa.table_x_byop WHERE x_esn = p_esn;
    INSERT
    INTO sa.table_x_byop
    (
    OBJID,
    X_ESN,
    X_BYOP_TYPE,
    X_BYOP_MANUFACTURER,
    X_BYOP_MODEL,
    X_CDMA_PORT_COUNTER
    )
    VALUES
    (
    sa.sequ_x_byop.nextval,
    p_esn,
    p_byop_type,
    NULL, --CR28514 --ig_trans_rec.x_make,
    NULL, --CR28514 --ig_trans_rec.x_model,
    1
    );
  ELSE
    p_error_num := 4;
    p_error_code := 'INVALID P_BYOP_INSERTION_TYPE';
    RETURN;
  END IF;
  OPEN esn_curs;
  FETCH esn_curs INTO esn_rec;
  IF esn_curs%found AND esn_rec.x_part_inst_status = '151' THEN
    CLOSE esn_curs;
    p_error_num := 0;
    RETURN;
  elsif esn_curs%found AND esn_rec.x_part_inst_status != '151' THEN
    CLOSE esn_curs;
    p_error_num := 6;
    p_error_code := 'ESN HAS INVALID PART STATUS';
    RETURN;
  END IF;
  CLOSE esn_curs;
  LAST_VD_IG_TRANS(P_ESN, p_org_id, l_phone_gen,l_phone_model,l_technology,l_sim_reqd,l_original_sim,l_carrier,l_error_num,l_error_code);
  L_ACTION := 'L_ACTION := ' || 'LAST_VD_IG_TRANS(' || ',' || P_ESN || ',' || p_org_id || ',' || l_phone_gen || ',' || l_phone_model || ',' || l_technology || ',' || l_sim_reqd || ',' || l_original_sim || ',' || l_carrier || ',' || l_error_num || ',' || l_error_code || ',' || ');';
  IF l_error_num NOT IN (0,2) THEN
    INSERT
    INTO error_table
    (
    ERROR_TEXT,
    ERROR_DATE,
    ACTION,
    KEY,
    PROGRAM_NAME
    )
    VALUES
    (
    'l_error_num NOT IN (0,2)',
    sysdate,
    L_INPUTS,
    p_esn,
    'BYOP_SERVICE_PKG.INSERT_ESN_PRENEW'
    );
    INSERT
    INTO error_table
    (
    ERROR_TEXT,
    ERROR_DATE,
    ACTION,
    KEY,
    PROGRAM_NAME
    )
    VALUES
    (
    'l_error_num NOT IN (0,2)',
    sysdate,
    L_ACTION,
    p_esn,
    'SA.BYOP_SERVICE_PKG.INSERT_ESN_PRENEW'
    );
    p_error_num := 5;
    p_error_code := 'PART NUMBER NOT FOUND';
    RETURN;
  END IF;
  OPEN part_num_curs(p_byop_type);
  FETCH part_num_curs INTO part_num_rec;
  p_part_num := part_num_rec.part_number; --CR48202
  IF part_num_curs%notfound THEN
    CLOSE part_num_curs;
    L_ACTION := 'L_ACTION := ' || 'part_num_curs(' || p_byop_type || ')';
    INSERT
    INTO error_table
    (
    ERROR_TEXT,
    ERROR_DATE,
    ACTION,
    KEY,
    PROGRAM_NAME
    )
    VALUES
    (
    'part_num_curs%notfound',
    sysdate,
    L_INPUTS,
    p_esn,
    'BYOP_SERVICE_PKG.INSERT_ESN_PRENEW'
    );
    INSERT
    INTO error_table
    (
    ERROR_TEXT,
    ERROR_DATE,
    ACTION,
    KEY,
    PROGRAM_NAME
    )
    VALUES
    (
    'part_num_curs%notfound',
    sysdate,
    L_ACTION,
    p_esn,
    'BYOP_SERVICE_PKG.INSERT_ESN_PRENEW'
    );
    p_error_num := 5;
    p_error_code := 'PART NUMBER NOT FOUND';
    RETURN;
  END IF;
  CLOSE part_num_curs;
  OPEN user_curs;
  FETCH user_curs INTO user_rec;
  CLOSE user_curs;
  OPEN reg_card_dealer_curs;
  FETCH reg_card_dealer_curs INTO reg_card_dealer_rec;
  CLOSE reg_card_dealer_curs;
  IF part_num_rec.is_lte_cdma = '1' AND LENGTH (p_esn) = 15 THEN
    l_esn_hex := p_esn;
  ELSE
    l_esn_hex := sa.MEIDDECTOHEX(p_esn);
  END IF;
  IF p_sim IS NOT NULL THEN
  -- CR31456 - Moving the code logic that were here to a new private procedure p_validate_load_sim
   p_validate_load_sim (p_sim);  -- CR31456
   -- CR31456 added below eslif part
  ELSIF p_sim IS NULL AND l_carrier = 'SPRINT' AND p_BYOP_INSERTION_TYPE =  'WARP_NEW'
  THEN
   p_validate_load_sim (l_original_sim);  -- For Sprint pass the sim returned by IG VD
  END IF;
  --


  INSERT
  INTO sa.table_part_inst
  (
    OBJID,
    PART_SERIAL_NO,
    LAST_PI_DATE,
    LAST_CYCLE_CT,
    NEXT_CYCLE_CT,
    LAST_MOD_TIME,
    LAST_TRANS_TIME,
    DATE_IN_SERV,
    WARR_END_DATE,
    REPAIR_DATE,
    PART_STATUS,
    X_INSERT_DATE,
    X_SEQUENCE,
    X_CREATION_DATE,
    X_DOMAIN,
    X_REACTIVATION_FLAG,
    X_PART_INST_STATUS,
    PART_INST2INV_BIN,
    N_PART_INST2PART_MOD,
    PART_INST2X_PERS,
    CREATED_BY2USER,
    STATUS2X_CODE_TABLE,
    X_PART_INST2CONTACT,
    X_CLEAR_TANK,
    X_HEX_SERIAL_NO,
    X_ICCID
  )
  VALUES
  (
    sa.seq('part_inst'), --OBJID,
    p_esn,               --PART_SERIAL_NO,
    default_date,        --LAST_PI_DATE,
    default_date,        --LAST_CYCLE_CT,
    default_date,        --NEXT_CYCLE_CT,
    default_date,        --LAST_MOD_TIME,
    default_date,        --LAST_TRANS_TIME,
    default_date,        --DATE_IN_SERV,
    NULL,          --WARR_END_DATE, CR42934 set value to NULL
    default_date,        --REPAIR_DATE,
    'Active',            --PART_STATUS,
    sysdate,             --X_INSERT_DATE,
    0,                   --X_SEQUENCE,
    sysdate,             --X_CREATION_DATE,
    'PHONES',            --X_DOMAIN,
    0,                   --X_REACTIVATION_FLAG,
    '151',               --X_PART_INST_STATUS,
    (NVL(reg_card_dealer_rec.ib_objid,
    (SELECT ib.objid
    FROM table_site s,
      table_inv_bin ib
    WHERE s.s_name  = 'BYOP'
    AND ib.bin_name = s.site_id
    AND rownum      <2
    ))) ,                         --PART_INST2INV_BIN,   --CR24770
    part_num_rec.mod_level_objid, --N_PART_INST2PART_MOD,
    0,                            --p_pers_objid,                                            --PART_INST2X_PERS,
    user_rec.objid,               --CREATED_BY2USER,
    (SELECT objid FROM table_x_code_table WHERE x_code_number = '151'
    ),         --STATUS2X_CODE_TABLE,
    -111,      --X_PART_INST2CONTACT,
    0,         --X_CLEAR_TANK,
    l_esn_hex, --X_HEX_SERIAL_NO,
    p_sim      --X_ICCID
  );
  -----------------------------------------------------------------------------------
  --CR41804
  IF NVL(ip_SP_offer_flag,'N') = 'Y'
  THEN

  OPEN cur_get_byop_offers;
  FETCH cur_get_byop_offers INTO rec_byop_offers;
  CLOSE cur_get_byop_offers;

  OPEN reg_card_dealer_curs;
  FETCH reg_card_dealer_curs INTO reg_card_dealer_rec;
  CLOSE reg_card_dealer_curs;

  SELECT NVL(reg_card_dealer_rec.ib_objid,
  (SELECT ib.objid
  FROM table_site s,
  table_inv_bin ib
  WHERE s.site_id ='7882'--CR42461 Adding the new site id
  AND ib.bin_name = s.site_id
  AND rownum      <2
  ))
  INTO
  lv_byop_inv_bin_objid
  FROM DUAL;


  sa.byop_service_pkg.generate_attach_free_pin (p_esn             ,
            rec_byop_offers.pin_part_number ,
            lv_byop_inv_bin_objid   ,
                                                NULL,
            out_free_soft_pin       ,
            out_smp_number      ,
            p_error_num         ,
            p_error_code);

  END IF;
  --CR41804

  p_error_num := 0;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_error_num  := 99;
    p_error_code := SQLCODE || ': ' || SQLERRM;
    INSERT
    INTO error_table
      (
        ERROR_TEXT,
        ERROR_DATE,
        ACTION,
        KEY,
        PROGRAM_NAME
      )
      VALUES
      (
        p_error_code,
        sysdate,
        L_INPUTS,
        p_esn,
        'BYOP_SERVICE_PKG.INSERT_ESN_PRENEW'
      );
END insert_esn_prenew;
PROCEDURE process_pin
  (
    p_esn        IN VARCHAR2,
    p_red_code   IN VARCHAR2,
    p_source_sys IN VARCHAR2,
    p_error_num OUT NUMBER,
    p_error_code OUT VARCHAR2
  )
IS
  CURSOR red_code_curs
  IS
    SELECT part_serial_no FROM table_part_inst WHERE x_red_code = p_red_code;
  red_code_rec red_code_curs%rowtype;
  --
  STRSTATUS    VARCHAR2(200);
  INTUNITS     NUMBER;
  INTDAYS      NUMBER;
  STRCARDBRAND VARCHAR2(200);
  STRMSGNUM    VARCHAR2(200);
  STRMSGSTR    VARCHAR2(200);
  STRERRORPIN  VARCHAR2(200);
  --
  P_CALL_TRANS_OBJID NUMBER;
  P_ERR_NUM          NUMBER;
  P_ERR_STRING       VARCHAR2(200);
  -- CR 28465 WEBCSR Migration - Net10 + TracFone
  --START Since it is calling Main procedure ..
  v_refcursor SYS_REFCURSOR;
  x_web_card_desc table_part_num.x_web_card_desc%TYPE;
  x_sp_web_card_desc table_part_num.x_sp_web_card_desc%TYPE;
  description table_part_num.description%TYPE;
  x_ild_type table_part_num.x_ild_type%TYPE;
  partnumber table_part_num.part_number%TYPE;
  cardtype table_part_num.x_card_type%TYPE;
  parttype table_part_num.part_type%TYPE;
  --END
BEGIN
  OPEN red_code_curs;
  FETCH red_code_curs INTO red_code_rec;
  IF red_code_Curs%notfound THEN
    p_error_num  := 101;
    p_error_code := 'x_red_code not found in table_part_inst';
    CLOSE red_code_curs;
    RETURN;
  END IF;
  CLOSE red_code_curs;
  --
  VALIDATE_RED_CARD_PKG.MAIN( p_red_code , red_code_rec.part_serial_no, p_source_sys, p_esn, v_refcursor -- CR 28465 WEBCSR Migration - Net10 + TracFone
  );
  -- CR 28465 WEBCSR Migration - Net10 + TracFone
  FETCH v_refcursor
  INTO STRSTATUS,
    INTUNITS,
    INTDAYS,
    STRCARDBRAND,
    STRMSGNUM,
    STRMSGSTR,
    STRERRORPIN,
    description,
    partnumber,
    cardtype,
    parttype,
    x_web_card_desc,
    x_sp_web_card_desc,
    x_ild_type;
  CLOSE v_refcursor;
  -- CR 28465 WEBCSR Migration - Net10 + TracFone
  DBMS_OUTPUT.PUT_LINE('STRSTATUS = ' || STRSTATUS);
  DBMS_OUTPUT.PUT_LINE('INTUNITS = ' || INTUNITS);
  DBMS_OUTPUT.PUT_LINE('INTDAYS = ' || INTDAYS);
  DBMS_OUTPUT.PUT_LINE('STRCARDBRAND = ' || STRCARDBRAND);
  DBMS_OUTPUT.PUT_LINE('STRMSGNUM = ' || STRMSGNUM);
  DBMS_OUTPUT.PUT_LINE('STRMSGSTR = ' || STRMSGSTR);
  DBMS_OUTPUT.PUT_LINE('STRERRORPIN = ' || STRERRORPIN);
  --
  IF STRMSGNUM   != 0 THEN
    p_error_num  := STRMSGNUM;
    p_error_code := STRMSGSTR;
    RETURN;
  END IF;
  --
  QUEUE_CARD_PKG.SP_REDEEM_CARD( P_ESN, P_RED_code, P_SOURCE_SYS, P_CALL_TRANS_OBJID, P_ERR_NUM, P_ERR_STRING );
  DBMS_OUTPUT.PUT_LINE('P_CALL_TRANS_OBJID = ' || P_CALL_TRANS_OBJID);
  DBMS_OUTPUT.PUT_LINE('P_ERR_NUM = ' || P_ERR_NUM);
  DBMS_OUTPUT.PUT_LINE('P_ERR_STRING = ' || P_ERR_STRING);
  --
  IF STRMSGNUM   != 0 THEN
    p_error_num  := p_err_NUM;
    p_error_code := p_err_string;
    RETURN;
  END IF;
  --
  p_error_code := 0;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  p_error_num  := 99;
  p_error_code := SQLERRM;
END;
PROCEDURE getcasedetails(
    p_id_number IN VARCHAR2,
    p_ACCOUNT OUT VARCHAR2,
    p_PIN OUT VARCHAR2,
    p_NAME OUT VARCHAR2,
    p_LAST_NAME OUT VARCHAR2,
    p_HOME_PHONE OUT VARCHAR2,
    p_ADDRESS_1 OUT VARCHAR2,
    p_ADDRESS_2 OUT VARCHAR2,
    p_CITY OUT VARCHAR2,
    p_STATE OUT VARCHAR2,
    p_ZIP_CODE OUT VARCHAR2,
    p_EMAIL OUT VARCHAR2,
    p_SS_LAST_4_DIGITS OUT VARCHAR2)
IS
  CURSOR case_dtl_curs
  IS
    SELECT cd.x_name,
      cd.x_value
    FROM sa.table_x_case_detail cd,
      sa.table_case c
    WHERE cd.x_name IN( 'ACCOUNT', --"CURRENT_PROVIDER_ACCOUNT"
      'PIN',                       --"CURRENT_PROVIDER_PASSWORD"
      'NAME',                      --"FIRST_NAME"
      'LAST_NAME',                 --"LAST_NAME"
      'HOME_PHONE',                --"HOME_PHONE_NUMBER"
      'ADDRESS_1',                 --"ADDRESS1"
      'ADDRESS_2',                 --"ADDRESS2"
      'CITY',                      --"CITY"
      'STATE',                     --"STATE"
      'ZIP_CODE',                  --"ZIP"
      'EMAIL',                     --"EMAIL"
      'SOCIAL_SECURITY_LAST_4_DIGITS')
    AND cd.detail2case = c.objid
    AND c.id_number    = p_id_number;--"SSN"
BEGIN
  p_ACCOUNT          := NULL;
  p_PIN              := NULL;
  p_NAME             := NULL;
  p_LAST_NAME        := NULL;
  p_HOME_PHONE       := NULL;
  p_ADDRESS_1        := NULL;
  p_ADDRESS_2        := NULL;
  p_CITY             := NULL;
  p_STATE            := NULL;
  p_ZIP_CODE         := NULL;
  p_EMAIL            := NULL;
  p_SS_LAST_4_DIGITS := NULL;
  FOR case_dtl_rec IN case_dtl_curs
  LOOP
    IF case_dtl_rec.x_name    = 'ACCOUNT' THEN
      p_ACCOUNT              := case_dtl_rec.x_value ;
    elsif case_dtl_rec.x_name = 'PIN' THEN
      p_PIN                  := case_dtl_rec.x_value ;
    elsif case_dtl_rec.x_name = 'NAME' THEN
      p_NAME                 := case_dtl_rec.x_value ;
    elsif case_dtl_rec.x_name = 'LAST_NAME' THEN
      p_LAST_NAME            := case_dtl_rec.x_value ;
    elsif case_dtl_rec.x_name = 'HOME_PHONE' THEN
      p_HOME_PHONE           := case_dtl_rec.x_value ;
    elsif case_dtl_rec.x_name = 'ADDRESS_1' THEN
      p_ADDRESS_1            := case_dtl_rec.x_value ;
    elsif case_dtl_rec.x_name = 'ADDRESS_2' THEN
      p_ADDRESS_2            := case_dtl_rec.x_value ;
    elsif case_dtl_rec.x_name = 'CITY' THEN
      p_CITY                 := case_dtl_rec.x_value ;
    elsif case_dtl_rec.x_name = 'STATE' THEN
      p_STATE                := case_dtl_rec.x_value ;
    elsif case_dtl_rec.x_name = 'ZIP_CODE' THEN
      p_ZIP_CODE             := case_dtl_rec.x_value ;
    elsif case_dtl_rec.x_name = 'EMAIL' THEN
      p_EMAIL                := case_dtl_rec.x_value ;
    elsif case_dtl_rec.x_name = 'SOCIAL_SECURITY_LAST_4_DIGITS' THEN
      p_SS_LAST_4_DIGITS     := case_dtl_rec.x_value ;
    END IF;
  END LOOP;
END;
PROCEDURE updatecasedetails(
    p_id_number        IN VARCHAR2,
    p_ACCOUNT          IN VARCHAR2,
    p_PIN              IN VARCHAR2,
    p_NAME             IN VARCHAR2,
    p_LAST_NAME        IN VARCHAR2,
    p_HOME_PHONE       IN VARCHAR2,
    p_ADDRESS_1        IN VARCHAR2,
    p_ADDRESS_2        IN VARCHAR2,
    p_CITY             IN VARCHAR2,
    p_STATE            IN VARCHAR2,
    p_ZIP_CODE         IN VARCHAR2,
    p_EMAIL            IN VARCHAR2,
    p_SS_LAST_4_DIGITS IN VARCHAR2)
IS
PROCEDURE update_case_detail(
    p_name  IN VARCHAR2,
    p_value IN VARCHAR2)
IS
  CURSOR c1
  IS
    SELECT cd.*,
      c.objid case_objid
    FROM sa.table_x_case_detail cd,
      sa.table_case c
    WHERE c.id_number  = p_id_number
    AND cd.detail2case = c.objid
    AND cd.x_name      = p_name;
  c1_rec c1%rowtype;
BEGIN
  OPEN c1;
  FETCH c1 INTO c1_rec;
  IF c1%found THEN
    UPDATE sa.table_x_case_detail cd
    SET cd.x_value = p_value
    WHERE cd.objid = c1_rec.objid;
  ELSE
    INSERT
    INTO sa.table_x_case_detail
      (
        OBJID,
        DEV,
        X_NAME,
        X_VALUE,
        DETAIL2CASE
      )
      VALUES
      (
        (
          seq('x_case_detail')
        )
        ,
        NULL,
        p_name,
        p_value,
        (SELECT objid FROM table_case WHERE id_number = p_id_number
        )
      );
  END IF;
  CLOSE c1;
END;
BEGIN
  IF p_ACCOUNT IS NOT NULL THEN
    update_case_detail('ACCOUNT',p_ACCOUNT);
  END IF;
  IF p_PIN IS NOT NULL THEN
    update_case_detail('PIN',p_pin);
  END IF;
  IF p_NAME IS NOT NULL THEN
    update_case_detail('NAME',P_NAME);
  END IF;
  IF p_LAST_NAME IS NOT NULL THEN
    update_case_detail('LAST_NAME',p_last_name);
  END IF;
  IF p_HOME_PHONE IS NOT NULL THEN
    update_case_detail('HOME_PHONE',p_home_phone);
  END IF;
  IF p_ADDRESS_1 IS NOT NULL THEN
    update_case_detail('ADDRESS_1',p_ADDRESS_1);
  END IF;
  IF p_ADDRESS_2 IS NOT NULL THEN
    update_case_detail('ADDRESS_2',p_ADDRESS_2);
  END IF;
  IF p_CITY IS NOT NULL THEN
    update_case_detail('CITY',p_CITY);
  END IF;
  IF p_STATE IS NOT NULL THEN
    update_case_detail('STATE',p_STATE);
  END IF;
  IF p_ZIP_CODE IS NOT NULL THEN
    update_case_detail('ZIP_CODE',p_ZIP_CODE);
  END IF;
  IF p_EMAIL IS NOT NULL THEN
    update_case_detail('EMAIL',p_EMAIL);
  END IF;
  IF p_SS_LAST_4_DIGITS IS NOT NULL THEN
    update_case_detail('SOCIAL_SECURITY_LAST_4_DIGITS',p_SS_LAST_4_DIGITS);
  END IF;
END;
PROCEDURE currentcachepolicy
  (
    p_esn IN VARCHAR2,
    p_status OUT VARCHAR2,
    p_policy_name OUT VARCHAR2,
    p_policy_description OUT VARCHAR2
  )
IS
  CURSOR c1
  IS
    SELECT tp.*
    FROM W3CI.table_x_throttling_cache tc,
      W3CI.table_x_throttling_policy tp
    WHERE tp.objid  = tc.x_policy_id
    AND tc.x_status = 'A'
    AND tc.x_esn    = p_esn;
  c1_rec c1%rowtype;
BEGIN
  OPEN c1;
  FETCH c1 INTO c1_rec;
  IF c1%found THEN
    p_status             := 'ACTIVE';
    p_policy_name        := c1_rec.x_policy_name;
    p_policy_description := c1_rec.x_policy_description;
  ELSE
    p_status             := 'INACTIVE';
    p_policy_name        := NULL;
    p_policy_description := NULL;
  END IF;
  CLOSE c1;
END;
PROCEDURE card_status(
    p_red_code IN VARCHAR2,
    p_status OUT VARCHAR2,
    p_units OUT VARCHAR2,
    p_days OUT VARCHAR2,
    p_brand OUT VARCHAR2,
    p_part_type OUT VARCHAR2,
    p_card_type OUT VARCHAR2,
    p_out_code OUT NUMBER,
    p_out_desc OUT VARCHAR2 )
IS
  CURSOR card_curs
  IS
    SELECT rc.x_smp smp,
      rc.x_red_code red_code,
      rc.x_red_card2part_mod mod_level_objid,
      'REDEEMED' card_status
    FROM sa.table_x_red_card rc
    WHERE rc.x_red_code = p_red_code
  UNION
  SELECT pi.part_serial_no smp,
    pi.x_red_code red_code,
    pi.n_part_inst2part_mod mod_level_objid,
    (SELECT ct.x_code_name
    FROM table_x_code_table ct
    WHERE ct.x_code_number = pi.x_part_inst_status
    ) card_status
  FROM sa.table_part_inst pi
  WHERE pi.x_red_code = p_red_code
  UNION
  SELECT pci.x_part_serial_no smp,
    pci.x_red_code red_code,
    pci.x_posa_inv2part_mod mod_level_objid,
    (SELECT ct.x_code_name
    FROM table_x_code_table ct
    WHERE ct.x_code_number = pci.x_posa_inv_status
    ) card_status
  FROM sa.table_x_posa_card_inv pci
  WHERE pci.x_red_code = p_red_code;
  card_rec card_curs%rowtype;
  CURSOR part_num_curs(c_mod_level_objid IN NUMBER)
  IS
    SELECT pn.x_redeem_units ,
      pn.x_redeem_days ,
      pn.x_restricted_use ,
      pn.x_card_type ,
      pn.part_type ,
      bo.org_id
    FROM sa.table_bus_org bo ,
      sa.table_part_num pn ,
      sa.table_mod_level ml
    WHERE 1      =1
    AND bo.objid = pn.part_num2bus_org
    AND pn.objid = ml.part_info2part_num
    AND ml.objid = c_mod_level_objid;
  part_num_rec part_num_curs%rowtype;
BEGIN
  OPEN card_curs;
  FETCH card_curs INTO card_rec;
  IF card_curs%notfound THEN
    p_out_code := 200;
    p_out_desc := 'CARD NOT FOUND';
    CLOSE card_curs;
    RETURN;
  ELSE
    OPEN part_num_curs(card_rec.mod_level_objid);
    FETCH part_num_curs INTO part_num_rec;
    IF part_num_curs%notfound THEN
      p_out_code := 300;
      p_out_desc := 'PART NOT FOUND';
      CLOSE part_num_curs;
      CLOSE card_curs;
      RETURN;
    END IF;
    CLOSE part_num_curs;
  END IF;
  CLOSE card_curs;
  p_status    := card_rec.card_status;
  p_units     := part_num_rec.x_redeem_units;
  p_days      := part_num_rec.x_redeem_days;
  p_brand     := part_num_rec.org_id;
  p_part_type := part_num_rec.part_type;
  p_card_type := part_num_rec.x_card_type;
  p_out_code  := 0;
  p_out_desc  := NULL;
END;
PROCEDURE reg_card_usable(
    p_red_code IN VARCHAR2,
    p_out_code OUT NUMBER,
    p_out_desc OUT VARCHAR2)
IS
  CURSOR card_curs
  IS
    SELECT 1
    FROM
      (SELECT rc.x_smp smp,
        rc.x_red_code red_code,
        rc.x_red_card2part_mod mod_level_objid,
        rc.x_status card_status
      FROM sa.table_x_red_card rc
      WHERE rc.x_red_code = p_red_code
    UNION
    SELECT pi.part_serial_no smp,
      pi.x_red_code red_code,
      pi.n_part_inst2part_mod mod_level_objid,
      pi.x_part_inst_status card_status
    FROM sa.table_part_inst pi
    WHERE pi.x_red_code = p_red_code
    UNION
    SELECT pci.x_part_serial_no smp,
      pci.x_red_code red_code,
      pci.x_posa_inv2part_mod mod_level_objid,
      pci.x_posa_inv_status card_status
    FROM sa.table_x_posa_card_inv pci
    WHERE pci.x_red_code = p_red_code
      ) tab1 ,
      sa.table_part_num pn ,
      sa.table_mod_level ml
    WHERE 1              =1
    AND tab1.card_status = '42'
    AND ml.objid         = tab1.mod_level_objid
    AND pn.objid         = ml.part_info2part_num
    AND pn.part_type     = 'PAIDACT';
    card_rec card_curs%rowtype;
  BEGIN
    OPEN card_curs;
    FETCH card_curs INTO card_rec;
    IF card_curs%notfound THEN
      p_out_code := 100;
      p_out_desc := 'CARD NOT USABLE';
      CLOSE card_curs;
      RETURN;
    END IF;
    CLOSE card_curs;
    p_out_code := 0;
    p_out_desc := 'CARD USABLE';
  END;
PROCEDURE validate_byop_sim(
    ip_esn         IN VARCHAR2,
    ip_sim         IN VARCHAR2,
    ip_zip         IN VARCHAR2,
    ip_carrier     IN VARCHAR2,
    ip_bus_org     IN VARCHAR2,
    ip_phone_model IN VARCHAR2,
    ip_byop_type   IN VARCHAR2,
    out_sim_profile OUT VARCHAR2,
    out_sim_compatible OUT VARCHAR2,
    out_sim_type OUT VARCHAR2,
    out_err_num OUT VARCHAR2,
    out_err_msg OUT VARCHAR2 )
AS
  CURSOR cur_sim_status (ip_sim VARCHAR2)
  IS
    SELECT x_sim_inv_status
    FROM table_x_sim_inv
    WHERE x_sim_serial_no = ip_sim
    AND x_sim_inv_status IN ('251','253','254');
  rec_sim_status cur_sim_status%rowtype;
  CURSOR cur_sim_married (ip_sim VARCHAR2)
  IS
    SELECT
      /*+ USE_INVISIBLE_INDEXES */
      part_serial_no
    FROM table_part_inst
    WHERE x_iccid = ip_sim;
  rec_sim_married cur_sim_married%rowtype;
  CURSOR cur_byop_pnum(ip_byop_type VARCHAR2, ip_bus_org VARCHAR2)
  IS
    SELECT bpn.x_part_number
    FROM table_mod_level ml,
      table_part_num pn,
      x_byop_part_num bpn
    WHERE 1                   = 1
    AND bpn.x_org_id          = ip_bus_org
    AND bpn.x_byop_type       = ip_byop_type
    AND pn.part_number        = bpn.x_part_number
    AND ml.part_info2part_num = pn.objid;
  rec_byop_pnum cur_byop_pnum%rowtype;
  rec_byop_pnum2 cur_byop_pnum%rowtype;
  -- big_tab          big_type  := big_type();
BEGIN
  out_err_num   := 0;
  out_err_msg   := 'Success';
  IF ip_sim     IS NULL OR ip_zip IS NULL OR ip_byop_type IS NULL OR ip_bus_org IS NULL OR ip_esn IS NULL THEN
    out_err_num := 1;
    out_err_msg := 'All required inputs not provided';
    RETURN;
  END IF;
  OPEN cur_sim_status (ip_sim);
  FETCH cur_sim_status INTO rec_sim_status;
  IF cur_sim_status%notfound THEN
    out_err_num := 2;
    out_err_msg := 'sim does not exist, or sim status is not valid';
    CLOSE cur_sim_status;
    RETURN;
  END IF;
  OPEN cur_sim_married(ip_sim);
  FETCH cur_sim_married INTO rec_sim_married;
  IF cur_sim_married%FOUND AND rec_sim_married.part_serial_no != ip_esn THEN
    out_err_num                                               := 3;
    out_err_msg                                               := 'sim married to a different ESN';
    CLOSE cur_sim_married;
    RETURN;
  END IF;
  OPEN cur_byop_pnum(ip_byop_type,ip_bus_org);
  FETCH cur_byop_pnum INTO rec_byop_pnum;
  IF cur_byop_pnum%NOTFOUND THEN
    out_err_num := 4;
    out_err_msg := 'BYOP ESN partnumber not found';
    RETURN;
  END IF;
  CLOSE cur_byop_pnum;
  FOR rec_byop_pnum2 IN cur_byop_pnum(ip_byop_type,ip_bus_org)
  LOOP
    BEGIN
      --sa.nap_service_pkg.get_list(ip_zip,ip_esn,ip_esn_part_number,ip_simip_sim_part_number,ip_site_part_objid);
      sa.nap_service_pkg.get_list(ip_zip,NULL,rec_byop_pnum2.x_part_number,ip_sim,NULL,NULL);
      IF sa.nap_service_pkg.big_tab.count>0 THEN
        out_sim_compatible              := 'YES';
        out_sim_profile                 := sa.nap_service_pkg.big_tab(1).carrier_info.sim_profile;
        out_err_num                     := 0;
        out_err_msg                     := 'Success';
        EXIT;
      ELSE
        out_sim_compatible := 'NO';
        out_err_num        := 5;
        out_err_msg        := 'No coverage';
        --RETURN;
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      out_sim_compatible := 'NO';
      out_err_num        := 5;
      out_err_msg        := 'No coverage';
      --RETURN;
    END;
  END LOOP;
  IF out_sim_compatible = 'YES' THEN
    out_sim_type       := get_byop_sim_type(sa.nap_service_pkg.big_tab(1).carrier_info.sim_profile);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  out_err_num := SQLCODE;
  out_err_msg := SQLCODE || ': ' || SQLERRM || '.';
  sa.ota_util_pkg.err_log( p_action => 'when others' ,p_error_date => SYSDATE ,P_KEY => 'SIM: ' || ip_sim || '.' ,P_PROGRAM_NAME => 'BYOP_SERVICES_PKG.VALIDATE_BYOP_SIM' ,P_ERROR_TEXT => out_err_msg );
  RETURN;
END;
FUNCTION get_byop_sim_type(
    p_sim_partnum IN VARCHAR2)
  RETURN VARCHAR2
AS
  -- return:
  -- 'NANO' for Nano
  -- 'DUAL' for Dual
  L_SIM_TYPE VARCHAR2(30);
  ERROR_MSG  VARCHAR2(4000);
  CURSOR cur_sim_pnum (p_sim_partnum VARCHAR2)
  IS
    SELECT *
    FROM TABLE_PART_NUM
    WHERE PART_NUMBER = TRIM(p_sim_partnum)
    AND domain        = 'SIM CARDS';
  rec_sim_pnum cur_sim_pnum%ROWTYPE;
BEGIN
  IF p_sim_partnum IS NULL THEN
    RETURN NULL;
  END IF;
  OPEN cur_sim_pnum(p_sim_partnum);
  FETCH cur_sim_pnum INTO rec_sim_pnum;
  IF cur_sim_pnum%NOTFOUND THEN
    CLOSE cur_sim_pnum;
    RETURN NULL;
  ELSE
    CLOSE cur_sim_pnum;

    IF rec_sim_pnum.s_description LIKE '%TRI-PUNCH%' OR rec_sim_pnum.s_description LIKE '%2FF/3FF/4FF%' THEN --CR47731-Trio SIM BYOP
      RETURN 'TRIO';
    ELSIF rec_sim_pnum.s_description LIKE '%NANO%' OR rec_sim_pnum.s_description LIKE '%4FF%' THEN
      RETURN 'NANO';
    ELSIF rec_sim_pnum.s_description LIKE '%DUAL%' OR rec_sim_pnum.s_description LIKE '%2FF/3FF%' THEN
      RETURN 'DUAL';
    ELSIF rec_sim_pnum.s_description LIKE '%REGULAR%' OR rec_sim_pnum.s_description LIKE '%2FF%' THEN
      RETURN 'STANDARD';
    ELSIF rec_sim_pnum.s_description LIKE '%MICRO%' OR rec_sim_pnum.s_description LIKE '%3FF%' THEN
      RETURN 'MICRO';
    ELSE
      ERROR_MSG := 'SIM size not identified';
      sa.ota_util_pkg.err_log( p_action => 'BYOP_SERVICES_PKG.GET_BYOP_SIM_TYPE' ,p_error_date => SYSDATE ,P_KEY => P_SIM_PARTNUM ,P_PROGRAM_NAME => 'BYOP_SERVICES_PKG.GET_BYOP_SIM_TYPE' ,P_ERROR_TEXT => ERROR_MSG );
      RETURN NULL;
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ERROR_MSG := SQLCODE || ': ' || SQLERRM || '.';
  sa.ota_util_pkg.err_log( p_action => 'when others' ,p_error_date => SYSDATE ,P_KEY => P_SIM_PARTNUM ,P_PROGRAM_NAME => 'BYOP_SERVICES_PKG.GET_BYOP_SIM_TYPE' ,P_ERROR_TEXT => ERROR_MSG );
  RETURN NULL;
END get_byop_sim_type;
FUNCTION get_byop_type(
    ip_carrier     IN VARCHAR2,
    ip_phone_model IN VARCHAR2,
    ip_sim_type    IN VARCHAR2,
    ip_phone_gen   IN VARCHAR2,
    ip_technology  IN VARCHAR2,
    ip_brand       IN VARCHAR2,
    ip_byop_type   IN VARCHAR2  DEFAULT NULL) -- CR44390 - added new parameter to handle BYOTs
  RETURN VARCHAR2
AS
  ret_byop_type VARCHAR2(1000);
BEGIN
  IF ip_carrier   IS NOT NULL THEN
    ret_byop_type := ip_carrier;
  ELSE
    RETURN 'CARRIER_MISSING';
  END IF;
  IF ip_phone_model IS NOT NULL THEN
    IF ip_byop_type = 'BYOT' THEN -- CR44390 -Add new overloaded function for handling BYOTs
      ret_byop_type   := ret_byop_type ||'_TABLET_'||ip_phone_model;
    ELSE
      ret_byop_type   := ret_byop_type ||'_'||ip_phone_model;
    END IF;
  END IF;
  IF ip_sim_type  IS NOT NULL THEN
    ret_byop_type := ret_byop_type ||'_'||ip_sim_type;
  END IF;
  IF ip_phone_gen IS NOT NULL THEN
    ret_byop_type := ret_byop_type ||'_'||ip_phone_gen;
  END IF;
  IF ip_technology IS NOT NULL THEN
    ret_byop_type  := ret_byop_type ||'_'||ip_technology;
  ELSE
    RETURN 'TECHNOLOGY_MISSING';
  END IF;
  IF ip_brand     IS NOT NULL THEN
    ret_byop_type := ret_byop_type ||'_'||ip_brand;
  ELSE
    RETURN 'BRAND_MISSING';
  END IF;
  dbms_Output.Put_Line( ret_byop_type );
  RETURN ret_byop_type;
END get_byop_type;
------------------------------------Start of CR28514 to remove insert_esn_prenew_tas_remove procedure after TAS start using insert_esn_prenew ---------------------------
PROCEDURE insert_esn_prenew_tas_remove
  (
    p_esn                 IN VARCHAR2,
    p_old_esn             IN VARCHAR2,
    p_org_id              IN VARCHAR2,
    p_byop_type           IN VARCHAR2,
    p_BYOP_MANUFACTURER   IN VARCHAR2,
    p_BYOP_MODEL          IN VARCHAR2,
    p_BYOP_INSERTION_TYPE IN VARCHAR2,
    p_error_num OUT NUMBER,
    p_error_code OUT VARCHAR2,
    p_sim IN VARCHAR2
  )
IS
  CURSOR reg_card_dealer_curs
  IS
    SELECT ib2.objid ib_objid,
      rc.X_RED_DATE
    FROM table_x_call_trans ct,
      table_x_red_card rc,
      table_inv_bin ib2,
      table_site s2
    WHERE 1                    = 1
    AND ct.x_service_id        = p_esn
    AND ct.x_min               = p_esn
    AND rc.RED_CARD2CALL_TRANS = ct.objid
    AND ib2.objid              = rc.X_RED_CARD2INV_BIN
    AND s2.site_id             = ib2.bin_name
  UNION
  SELECT ib2.objid ib_objid,
    rc.X_RED_DATE
  FROM table_x_call_trans ct,
    table_x_red_card rc,
    table_inv_bin ib2,
    table_site s2
  WHERE 1                    = 1
  AND ct.x_service_id        = p_old_esn
  AND ct.x_min               = p_old_esn
  AND rc.RED_CARD2CALL_TRANS = ct.objid
  AND ib2.objid              = rc.X_RED_CARD2INV_BIN
  AND s2.site_id             = ib2.bin_name
  ORDER BY X_RED_DATE DESC;
  reg_card_dealer_rec reg_card_dealer_curs%rowtype;
  CURSOR part_num_curs(c_byop_type IN VARCHAR2)
  IS
    SELECT ml.objid mod_level_objid,
      pn.part_num2part_class pclass_objid
    FROM table_mod_level ml,
      table_part_num pn,
      x_byop_part_num bpn
    WHERE 1                   = 1
    AND bpn.x_org_id          = p_org_id
    AND bpn.x_byop_type       = c_byop_type
    AND pn.part_number        = bpn.x_part_number
    AND ml.part_info2part_num = pn.objid;
  part_num_rec part_num_curs%rowtype;
  CURSOR sim_part_num_curs (p_sim IN VARCHAR2)
  IS
    SELECT pn.part_number
    FROM table_x_sim_inv sim ,
      table_mod_level ml ,
      table_part_num pn ,
      table_part_class pc
    WHERE 1                    =1
    AND sim.x_sim_serial_no    = p_sim
    AND sim.X_SIM_INV2PART_MOD = ml.objid
    AND ml.PART_INFO2PART_NUM  = pn.objid
    AND pn.part_num2part_class = pc.objid ;
  sim_part_num_rec sim_part_num_curs%rowtype;
  CURSOR sim_status_curs (p_sim IN VARCHAR2)
  IS
    SELECT
      /*+ USE_INVISIBLE_INDEXES */
      x_sim_serial_no
    FROM table_x_sim_inv sim
    WHERE 1                   =1
    AND sim.x_sim_serial_no   = p_sim
    AND sim.x_sim_inv_status IN ('251','253','254');
  sim_status_rec sim_status_curs%rowtype;
  CURSOR user_curs
  IS
    SELECT objid FROM table_user WHERE s_login_name = 'SA';
  user_rec user_curs%rowtype;
  CURSOR old_esn_curs
  IS
    SELECT * FROM table_x_byop WHERE x_esn = p_old_esn;
  old_esn_rec old_esn_curs%rowtype;
  CURSOR esn_curs
  IS
    SELECT * FROM table_part_inst WHERE part_serial_no = p_esn;
  esn_rec esn_curs%rowtype;
  CURSOR ig_trans_curs
  IS
    SELECT
      /*+ USE_INVISIBLE_INDEXES */
      X_POOL_NAME x_msl_code,
      X_MPN x_make,
      X_MPN_CODE x_model
    FROM gw1.ig_transaction ig
    WHERE esn      = p_esn
    AND order_type = 'VD'
    AND status    IN ('SS','S','W')
    AND template   = 'RSS'  --CR28183
    AND X_MPN      = 'APL'; --CR28183
  ig_trans_rec ig_trans_curs%rowtype;
  CURSOR is_lte_cdma_curs (pc_objid IN NUMBER)
  IS
    SELECT pc.objid,
      pc.name,
      x_param_name,
      x_param_value
    FROM sa.table_x_part_class_values v,
      sa.table_x_part_class_params n,
      sa.table_part_class pc
    WHERE value2class_param = n.objid
    AND v.value2part_class  = pc.objid
    AND X_PARAM_NAME        = 'CDMA LTE SIM'
    AND x_param_value       = 'REMOVABLE'
    AND pc.objid            = pc_objid;
  is_lte_cdma_rec is_lte_cdma_curs%rowtype;
  default_date   DATE := to_date('01-JAN-1753','DD-MON-YYYY'); --CR26363
  l_carrier      VARCHAR2(100);
  l_error_num    NUMBER;
  l_error_code   VARCHAR2(100);
  l_phone_gen    VARCHAR2(100);
  l_phone_model  VARCHAR2(100);
  l_technology   VARCHAR2(100);
  l_sim_reqd     VARCHAR2(100);
  l_original_sim VARCHAR2(100);
  l_esn_hex      VARCHAR2(100);
BEGIN
  OPEN esn_curs;
  FETCH esn_curs INTO esn_rec;
  IF esn_curs%found AND esn_rec.x_part_inst_status != '151' THEN
    CLOSE esn_curs;
    p_error_num  := 6;
    p_error_code := 'ESN HAS INVALID PART STATUS';
    RETURN;
  END IF;
  CLOSE esn_curs;
  IF p_BYOP_INSERTION_TYPE = 'VRZ_UPG' AND p_old_esn IS NULL THEN
    p_error_num           := 1;
    p_error_code          := 'UPGRADE MISSING OLD ESN';
    RETURN;
  elsif p_BYOP_INSERTION_TYPE = 'VRZ_UPG' AND p_old_esn IS NOT NULL THEN
    OPEN old_esn_curs;
    FETCH old_esn_curs INTO old_esn_rec;
    IF old_esn_curs%notfound THEN
      p_error_num  := 2;
      p_error_code := 'OLD ESN NOT FOUND';
      CLOSE old_esn_curs;
      RETURN;
    elsif old_esn_rec.x_cdma_port_counter =0 THEN
      p_error_num                        := 3;
      p_error_code                       := 'OLD ESN PORT COUNTER 0';
      CLOSE old_esn_curs;
      RETURN;
    END IF;
    CLOSE old_esn_curs;
    UPDATE sa.table_x_byop
    SET x_cdma_port_counter = old_esn_rec.x_cdma_port_counter -1
    WHERE x_esn             = p_old_esn;
    INSERT
    INTO sa.table_x_byop
      (
        OBJID,
        X_ESN,
        X_BYOP_TYPE,
        X_BYOP_MANUFACTURER,
        X_BYOP_MODEL,
        X_CDMA_PORT_COUNTER
      )
      VALUES
      (
        sa.sequ_x_byop.nextval,
        p_esn,
        p_byop_type,
        ig_trans_rec.x_make,
        ig_trans_rec.x_model,
        (old_esn_rec.x_cdma_port_counter -1)
      );
  elsif p_BYOP_INSERTION_TYPE = 'VRZ_NEW' THEN
    DELETE FROM sa.table_x_byop WHERE x_esn = p_esn;
    INSERT
    INTO sa.table_x_byop
      (
        OBJID,
        X_ESN,
        X_BYOP_TYPE,
        X_BYOP_MANUFACTURER,
        X_BYOP_MODEL,
        X_CDMA_PORT_COUNTER
      )
      VALUES
      (
        sa.sequ_x_byop.nextval,
        p_esn,
        p_byop_type,
        ig_trans_rec.x_make,
        ig_trans_rec.x_model,
        1
      );
  ELSE
    p_error_num  := 4;
    p_error_code := 'INVALID P_BYOP_INSERTION_TYPE';
    RETURN;
  END IF;
  OPEN esn_curs;
  FETCH esn_curs INTO esn_rec;
  IF esn_curs%found AND esn_rec.x_part_inst_status = '151' THEN
    CLOSE esn_curs;
    p_error_num := 0;
    RETURN;
  elsif esn_curs%found AND esn_rec.x_part_inst_status != '151' THEN
    CLOSE esn_curs;
    p_error_num  := 6;
    p_error_code := 'ESN HAS INVALID PART STATUS';
    RETURN;
  END IF;
  CLOSE esn_curs;
  --  IF p_org_id IN('TELCEL', 'TRACFONE') THEN
  --  IF p_org_id = 'TELCEL' THEN
  --    st_LAST_VD_IG_TRANS(P_ESN , l_carrier , l_error_num, l_error_code);
  --  ELSE
  /*
  dbms_output.put_line('--------------- LAST_VD_IG_TRANS  ----------------------');
  dbms_output.put_line('P_ESN: ' || P_ESN);
  dbms_output.put_line('p_org_id: ' || p_org_id);
  dbms_output.put_line('l_phone_gen: ' || l_phone_gen);
  dbms_output.put_line('l_phone_model: ' || l_phone_model);
  dbms_output.put_line('l_technology: ' || l_technology);
  dbms_output.put_line('l_sim_reqd: ' || l_sim_reqd);
  dbms_output.put_line('l_original_sim: ' || l_original_sim);
  dbms_output.put_line('l_carrier: ' || l_carrier);
  */
  last_vd_ig_trans_tas_remove(P_ESN, p_org_id, l_phone_gen,l_phone_model,l_technology,l_sim_reqd,l_original_sim,l_carrier,l_error_num,l_error_code);
  /*
  dbms_output.put_line('l_error_num: ' || l_error_num);
  dbms_output.put_line('l_error_code: ' || l_error_code);
  dbms_output.put_line('--------------- LAST_VD_IG_TRANS  ----------------------');
  */
  --  END IF;
  IF l_error_num NOT IN (0,2) THEN
    INSERT
    INTO error_table
      (
        ERROR_TEXT,
        ERROR_DATE,
        ACTION,
        KEY,
        PROGRAM_NAME
      )
      VALUES
      (
        'l_error_num NOT IN (0,2) '
        ||p_org_id,
        sysdate,
        'st_LAST_VD_IG_TRANS('
        ||P_ESN
        ||','
        ||l_carrier
        ||','
        ||l_error_num
        ||','
        ||l_error_code
        ||')' ,
        p_esn,
        'rtr_service_pkg.insert_esn_prenew'
      );
    INSERT
    INTO error_table
      (
        ERROR_TEXT,
        ERROR_DATE,
        ACTION,
        KEY,
        PROGRAM_NAME
      )
      VALUES
      (
        'l_error_num NOT IN (0,2) '
        ||p_org_id,
        sysdate,
        'insert_esn_prenew('
        ||p_esn
        ||','
        ||p_old_esn
        ||','
        ||p_org_id
        ||','
        ||p_byop_type
        ||','
        || p_BYOP_MANUFACTURER
        ||','
        ||p_BYOP_MODEL
        ||','
        ||p_BYOP_INSERTION_TYPE
        ||','
        ||p_error_num
        ||','
        ||p_error_code
        ||','
        ||p_sim
        ||')',
        p_esn,
        'rtr_service_pkg.insert_esn_prenew'
      );
    p_error_num  := 5;
    p_error_code := 'PART NUMBER NOT FOUND';
    RETURN;
  END IF;
  -----------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------
  IF l_carrier = 'VERIZON' THEN
    OPEN ig_trans_curs;
    FETCH ig_trans_curs INTO ig_trans_rec;
    -----------------------------------------------------------------------------------
    IF ig_trans_curs%found THEN
      OPEN part_num_curs(p_byop_type);
      FETCH part_num_curs INTO part_num_rec;
      IF part_num_curs%notfound THEN
        CLOSE part_num_curs;
        CLOSE ig_trans_curs;
        INSERT
        INTO error_table
          (
            ERROR_TEXT,
            ERROR_DATE,
            ACTION,
            KEY,
            PROGRAM_NAME
          )
          VALUES
          (
            'part_num_curs('
            || p_byop_type
            || ')',
            sysdate,
            'part_num_curs('
            || p_byop_type
            || ')' ,
            p_esn,
            'rtr_service_pkg.insert_esn_prenew'
          );
        INSERT
        INTO error_table
          (
            ERROR_TEXT,
            ERROR_DATE,
            ACTION,
            KEY,
            PROGRAM_NAME
          )
          VALUES
          (
            'part_num_curs('
            || p_byop_type
            || ')',
            sysdate,
            'insert_esn_prenew('
            ||p_esn
            ||','
            ||p_old_esn
            ||','
            ||p_org_id
            ||','
            ||p_byop_type
            ||','
            || p_BYOP_MANUFACTURER
            ||','
            ||p_BYOP_MODEL
            ||','
            ||p_BYOP_INSERTION_TYPE
            ||','
            ||p_error_num
            ||','
            ||p_error_code
            ||','
            ||p_sim
            ||')',
            p_esn,
            'rtr_service_pkg.insert_esn_prenew'
          );
        p_error_num  := 5;
        p_error_code := 'PART NUMBER NOT FOUND';
        RETURN;
      END IF;
      CLOSE part_num_curs;
    ELSE
      OPEN part_num_curs(p_byop_type);
      FETCH part_num_curs INTO part_num_rec;
      IF part_num_curs%notfound THEN
        CLOSE part_num_curs;
        CLOSE ig_trans_curs;
        INSERT
        INTO error_table
          (
            ERROR_TEXT,
            ERROR_DATE,
            ACTION,
            KEY,
            PROGRAM_NAME
          )
          VALUES
          (
            'part_num_curs('
            || p_byop_type
            || ')',
            sysdate,
            'part_num_curs('
            || p_byop_type
            || ')',
            p_esn,
            'rtr_service_pkg.insert_esn_prenew'
          );
        INSERT
        INTO error_table
          (
            ERROR_TEXT,
            ERROR_DATE,
            ACTION,
            KEY,
            PROGRAM_NAME
          )
          VALUES
          (
            'part_num_curs('
            || p_byop_type
            || ')',
            sysdate,
            'insert_esn_prenew('
            ||p_esn
            ||','
            ||p_old_esn
            ||','
            ||p_org_id
            ||','
            ||p_byop_type
            ||','
            || p_BYOP_MANUFACTURER
            ||','
            ||p_BYOP_MODEL
            ||','
            ||p_BYOP_INSERTION_TYPE
            ||','
            ||p_error_num
            ||','
            ||p_error_code
            ||','
            ||p_sim
            ||')',
            p_esn,
            'rtr_service_pkg.insert_esn_prenew'
          );
        p_error_num  := 5;
        p_error_code := 'PART NUMBER NOT FOUND';
        RETURN;
      END IF;
      CLOSE part_num_curs;
    END IF;
    -----------------------------------------------------------------------------------
    CLOSE ig_trans_curs;
  elsif p_byop_type LIKE '%VERIZON%' THEN
    INSERT
    INTO error_table
      (
        ERROR_TEXT,
        ERROR_DATE,
        ACTION,
        KEY,
        PROGRAM_NAME
      )
      VALUES
      (
        'p_byop_type LIKE %VERIZON%',
        sysdate,
        'p_byop_type LIKE %VERIZON%' ,
        p_esn,
        'rtr_service_pkg.insert_esn_prenew'
      );
    INSERT
    INTO error_table
      (
        ERROR_TEXT,
        ERROR_DATE,
        ACTION,
        KEY,
        PROGRAM_NAME
      )
      VALUES
      (
        'p_byop_type LIKE %VERIZON%',
        sysdate,
        'insert_esn_prenew('
        ||p_esn
        ||','
        ||p_old_esn
        ||','
        ||p_org_id
        ||','
        ||p_byop_type
        ||','
        || p_BYOP_MANUFACTURER
        ||','
        ||p_BYOP_MODEL
        ||','
        ||p_BYOP_INSERTION_TYPE
        ||','
        ||p_error_num
        ||','
        ||p_error_code
        ||','
        ||p_sim
        ||')',
        p_esn,
        'rtr_service_pkg.insert_esn_prenew'
      );
    p_error_num  := 5;
    p_error_code := 'PART NUMBER NOT FOUND';
    RETURN;
  ELSE
    OPEN part_num_curs(p_BYOP_type);
    FETCH part_num_curs INTO part_num_rec;
    IF part_num_curs%notfound THEN
      CLOSE part_num_curs;
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'p_byop_type NOT LIKE %VERIZON% but carrier = VERIZON',
          sysdate,
          'part_num_curs('
          ||p_BYOP_type
          ||')',
          p_esn,
          'rtr_service_pkg.insert_esn_prenew'
        );
      INSERT
      INTO error_table
        (
          ERROR_TEXT,
          ERROR_DATE,
          ACTION,
          KEY,
          PROGRAM_NAME
        )
        VALUES
        (
          'p_byop_type NOT LIKE %VERIZON% but carrier = VERIZON',
          sysdate,
          'insert_esn_prenew('
          ||p_esn
          ||','
          ||p_old_esn
          ||','
          ||p_org_id
          ||','
          ||p_byop_type
          ||','
          || p_BYOP_MANUFACTURER
          ||','
          ||p_BYOP_MODEL
          ||','
          ||p_BYOP_INSERTION_TYPE
          ||','
          ||p_error_num
          ||','
          ||p_error_code
          ||','
          ||p_sim
          ||')',
          p_esn,
          'rtr_service_pkg.insert_esn_prenew'
        );
      p_error_num  := 5;
      p_error_code := 'PART NUMBER NOT FOUND';
      RETURN;
    END IF;
    CLOSE part_num_curs;
  END IF;
  OPEN user_curs;
  FETCH user_curs INTO user_rec;
  CLOSE user_curs;
  OPEN reg_card_dealer_curs;
  FETCH reg_card_dealer_curs INTO reg_card_dealer_rec;
  CLOSE reg_card_dealer_curs;
  OPEN is_lte_cdma_curs(part_num_rec.pclass_objid);
  FETCH is_lte_cdma_curs INTO is_lte_cdma_rec;
  IF is_lte_cdma_curs%found AND LENGTH (p_esn) = 15 THEN
    l_esn_hex                                 := p_esn;
  ELSE
    l_esn_hex := sa.MEIDDECTOHEX(p_esn);
  END IF;
  CLOSE is_lte_cdma_curs;
  IF p_sim IS NOT NULL AND l_carrier = 'VERIZON' THEN
    OPEN sim_part_num_curs (p_sim);
    FETCH sim_part_num_curs INTO sim_part_num_rec;
    IF sim_part_num_curs%notfound THEN
      CLOSE sim_part_num_curs;
      p_error_num  := 6;
      p_error_code := 'SIM PART NUMBER NOT FOUND';
      RETURN;
    END IF;
    CLOSE sim_part_num_curs;
    OPEN sim_status_curs(p_sim);
    FETCH sim_status_curs INTO sim_status_rec;
    IF sim_status_curs%FOUND THEN
      UPDATE table_part_inst SET x_iccid = p_sim WHERE PART_SERIAL_NO = p_esn;
    ELSE
      p_error_num  := 7;
      p_error_code := 'SIM STATUS NOT VALID';
      RETURN;
    END IF;
  END IF;
  INSERT
  INTO table_part_inst
    (
      OBJID,
      PART_SERIAL_NO,
      LAST_PI_DATE,
      LAST_CYCLE_CT,
      NEXT_CYCLE_CT,
      LAST_MOD_TIME,
      LAST_TRANS_TIME,
      DATE_IN_SERV,
      WARR_END_DATE,
      REPAIR_DATE,
      PART_STATUS,
      X_INSERT_DATE,
      X_SEQUENCE,
      X_CREATION_DATE,
      X_DOMAIN,
      X_REACTIVATION_FLAG,
      X_PART_INST_STATUS,
      PART_INST2INV_BIN,
      N_PART_INST2PART_MOD,
      PART_INST2X_PERS,
      CREATED_BY2USER,
      STATUS2X_CODE_TABLE,
      X_PART_INST2CONTACT,
      X_CLEAR_TANK,
      X_HEX_SERIAL_NO,
      x_iccid
    )
    VALUES
    (
      sa.seq('part_inst'), --OBJID,
      p_esn,               --PART_SERIAL_NO,
      default_date,        --LAST_PI_DATE,
      default_date,        --LAST_CYCLE_CT,
      default_date,        --NEXT_CYCLE_CT,
      default_date,        --LAST_MOD_TIME,
      default_date,        --LAST_TRANS_TIME,
      default_date,        --DATE_IN_SERV,
      NULL,                --WARR_END_DATE, CR42934 set value to NULL
      default_date,        --REPAIR_DATE,
      'Active',            --PART_STATUS,
      sysdate,             --X_INSERT_DATE,
      0,                   --X_SEQUENCE,
      sysdate,             --X_CREATION_DATE,
      'PHONES',            --X_DOMAIN,
      0,                   --X_REACTIVATION_FLAG,
      '151',               --X_PART_INST_STATUS,
      (NVL(reg_card_dealer_rec.ib_objid,
      (SELECT ib.objid
      FROM table_site s,
        table_inv_bin ib
      WHERE s.s_name  = 'BYOP'
      AND ib.bin_name = s.site_id
      AND rownum      <2
      ))) ,                         --PART_INST2INV_BIN,   --CR24770
      part_num_rec.mod_level_objid, --N_PART_INST2PART_MOD,
      0,                            --p_pers_objid,                                            --PART_INST2X_PERS,
      user_rec.objid,               --CREATED_BY2USER,
      (SELECT objid FROM table_x_code_table WHERE x_code_number = '151'
      ),    --STATUS2X_CODE_TABLE,
      -111, --X_PART_INST2CONTACT,
      0,    --X_CLEAR_TANK,
      l_esn_hex,
      p_sim
    ); --X_HEX_SERIAL_NO,
  -----------------------------------------------------------------------------------
  p_error_num := 0;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  p_error_num  := 99;
  p_error_code := SQLERRM;
END insert_esn_prenew_tas_remove;
------------------------------------Start of CR28514 to remove last_vd_ig_trans_tas_remove procedure after TAS start using last_vd_ig_trans ---------------------------
PROCEDURE last_vd_ig_trans_tas_remove(
    p_esn     IN VARCHAR2,
    p_bus_org IN VARCHAR2,
    p_phone_gen OUT VARCHAR2,
    p_phone_model OUT VARCHAR2,
    p_technology OUT VARCHAR2,
    p_sim_reqd OUT VARCHAR2,
    p_original_sim OUT VARCHAR2,
    p_carrier OUT VARCHAR2,
    p_error_num OUT NUMBER,
    p_error_code OUT VARCHAR2)
IS
  CURSOR last_ig_curs(c_template IN VARCHAR2)
  IS
    SELECT
      /*+ USE_INVISIBLE_INDEXES */
      --      status,
      --      status_message
      *
    FROM gw1.ig_transaction ig
    WHERE esn      = p_esn
    AND order_type = 'VD'
    AND template   = c_template
    ORDER BY ig.transaction_id DESC;
  last_ig_rec last_ig_curs%rowtype;
  last_ig_rec2 last_ig_curs%rowtype;
BEGIN
  IF p_bus_org != 'TRACFONE' THEN
    OPEN last_ig_curs('RSS');
    FETCH last_ig_curs INTO last_ig_rec;
    IF last_ig_curs%notfound THEN
      CLOSE last_ig_curs;
      p_error_num  := 1;
      p_error_code := 'NO TRANSACTION FOUND';
      RETURN;
    END IF;
    CLOSE last_ig_curs;
    OPEN last_ig_curs('SPRINT');
    FETCH last_ig_curs INTO last_ig_rec2;
    IF last_ig_curs%notfound THEN
      CLOSE last_ig_curs;
      p_error_num  := 2;
      p_error_code := 'NO TRANSACTION FOUND';
      RETURN;
    END IF;
    CLOSE last_ig_curs;
    IF last_ig_rec.status IN ('CP','L', 'Q') OR last_ig_rec2.status IN ('CP','L', 'Q') THEN
      p_error_num  := 4;
      p_error_code := 'PENDING';
      RETURN;
    elsif last_ig_rec.status IN ('FF','F','E') AND last_ig_rec2.status IN ('FF','F','E') THEN --CR 24472
      p_error_num  := 3;
      p_error_code := 'NOT ELIGIBLE';
      RETURN;
    elsif last_ig_rec2.status IN ('SS','S','W') AND upper(last_ig_rec2.status_message) LIKE '%ESN_IN_USE%' THEN
      p_error_num  := 2;
      p_error_code := 'ELIGIBLE ACTIVE';
      p_carrier    := 'SPRINT';
      p_technology := 'CDMA';
      RETURN;
    elsif last_ig_rec.status IN ('SS','S','W') THEN
      p_error_num  := 2;
      p_error_code := 'ELIGIBLE';
      p_carrier    := 'VERIZON';
      p_technology := 'CDMA';
      --RETURN;
    elsif last_ig_rec2.status IN ('SS','S','W') AND upper(last_ig_rec2.status_message) NOT LIKE '%ESN_IN_USE%' THEN
      p_error_num  := 2;
      p_error_code := 'ELIGIBLE INACTIVE';
      p_carrier    := 'SPRINT';
      p_technology := 'CDMA';
      RETURN;
    ELSE
      p_error_num  := 5;
      p_error_code := 'INVALID STATUS';
      RETURN;
    END IF;
  ELSIF p_bus_org = 'TRACFONE' THEN
    OPEN last_ig_curs('RSS');
    FETCH last_ig_curs INTO last_ig_rec;
    IF last_ig_curs%notfound THEN
      CLOSE last_ig_curs;
      p_error_num  := 1;
      p_error_code := 'NO TRANSACTION FOUND';
      RETURN;
    END IF;
    CLOSE last_ig_curs;
    IF last_ig_rec.status IN ('SS','S','W') THEN
      p_error_num  := 2;
      p_error_code := 'ELIGIBLE';
      p_carrier    := 'VERIZON';
      p_technology := 'CDMA';
      --RETURN;
    elsif last_ig_rec.status IN ('FF','F','E') THEN --CR 24472
      p_error_num  := 3;
      p_error_code := 'NOT ELIGIBLE';
      RETURN;
    elsif last_ig_rec.status IN ('CP','L', 'Q') THEN
      p_error_num  := 4;
      p_error_code := 'PENDING';
      RETURN;
    ELSE
      p_error_num  := 5;
      p_error_code := 'INVALID STATUS';
      RETURN;
    END IF;
    p_error_num := 0;
  ELSE
    NULL;
  END IF;
  ----
  IF p_carrier = 'VERIZON' THEN
    IF upper(last_ig_rec.x_mpn) LIKE '%APL%' THEN
      p_phone_model := 'IPHONE';
    ELSE
      p_phone_model := 'OTHER';
    END IF;
    ----
    IF upper(last_ig_rec.x_pool_name) LIKE '%4G%' THEN
    p_phone_gen := 'LTE';
   --CR52545 Modify BYOP registration Service to assign HD part class for Verizon VOLTE, mdave, 07/26/2017
    IF UPPER(last_ig_rec.status_message) LIKE UPPER('%HDVoice=Y%') THEN
      p_phone_gen := 'LTE_HD';
    END IF;
   --END CR52545 Modify BYOP registration Service to assign HD part class for Verizon VOLTE, mdave, 07/26/2017
      p_sim_reqd  := 'YES';
    ELSE
      p_phone_gen := 'NON_LTE';
      p_sim_reqd  := 'NO';
    END IF;
  END IF;
  ----
  --p_error_num := 0;
EXCEPTION
WHEN OTHERS THEN
  p_error_num  := 99;
  p_error_code := SQLERRM;
END last_vd_ig_trans_tas_remove;
---------------------------------------End of CR28514 remove this procedure -------------------------
-- CR31456 Changes Starts.
-- This function will verify the carrier coverage for the brand, zip and device type
--
FUNCTION fn_verify_carrier_dev_type( i_carrier        IN    VARCHAR2,
                                     i_brand          IN    VARCHAR2,
                                     i_zip            IN    VARCHAR2,
                                     i_device_type    IN    VARCHAR2
                                   )
RETURN VARCHAR2
IS
--
CURSOR part_num_curs
IS
  SELECT bp.x_part_number
    FROM pcpv v,
         table_part_class pc,
         table_part_num  pn,
         x_byop_part_num bp
   WHERE v.manufacturer  IS NOT NULL
     AND v.device_type   = NVL(i_device_type, v.device_type)--CR42257 added NVL
     AND v.part_class    = pc.name
     AND pc.objid        = pn.part_num2part_class
     AND pn.part_number  = bp.x_part_number
     AND bp.x_org_id     = i_brand
     AND bp.x_byop_type  = DECODE(i_carrier,'VERIZON',DECODE(i_device_type, 'BYOT','Tablet','Phone') , -- CR45378 added Tablet
                                            'SPRINT','CNL', 'TMO','TMO', 'ATT','ATT' );
  --
  part_num_rec part_num_curs%rowtype;
--
BEGIN
  --
  OPEN part_num_curs;
  FETCH part_num_curs INTO part_num_rec;
  IF part_num_curs%notfound THEN
    RETURN 'NO';
  END IF;
  CLOSE part_num_curs;
  --
  IF byop_service_pkg.verify_carrier_zip(part_num_rec.x_part_number,i_zip) IS NOT NULL
  THEN
    RETURN 'YES';
  ELSE
    RETURN 'NO';
  END IF;
  --
EXCEPTION
WHEN OTHERS   THEN
  ROLLBACK;
  RETURN 'NO';
END fn_verify_carrier_dev_type;
--
-- This procedure will get the available carrier list for the zip, brand and device type
--
PROCEDURE p_carrierlist_byop_brand_zip ( i_zip             IN   VARCHAR2,
                                         i_brand           IN   VARCHAR2,
                                         i_device_type     IN   VARCHAR2,
                                         i_technology      IN   VARCHAR2 default NULL,      --CR42933 - ST Refresh changes to include technology input
                                         o_avlbl_carrier   OUT  VARCHAR2,
                                         o_result_code     OUT  VARCHAR2,
                                         o_result_msg      OUT  VARCHAR2
                                       )
IS
--
  CURSOR part_num_curs
  IS
    SELECT bp.x_part_number,x_byop_type,nvl((select nvl(p.new_rank,99) from carrierpref p, carrierzones z  --Added for CR42933 to get the ordered carrier based on the rank.
                                        where 1=1
                                        and p.CARRIER_NAME=z.CARRIER_NAME
                                        and p.st=z.st
                                        and p.carrier_id=z.carrier_id
                                        and p.county=z.county
                                        and z.zip=i_zip
                                        and CASE
                      WHEN p.carrier_name LIKE 'Phone'     THEN   'VERIZON'
                      WHEN p.carrier_name LIKE '%VERIZON%' THEN   'VERIZON'
                      WHEN p.carrier_name LIKE 'CNL'       THEN   'SPRINT'
                      WHEN p.carrier_name LIKE 'SPRINT%'   THEN   'SPRINT'
                      WHEN p.carrier_name LIKE 'T-MO%'     THEN   'T-MOBILE'
                      WHEN p.carrier_name LIKE 'TMO%'      THEN   'T-MOBILE'
                      WHEN p.carrier_name LIKE 'AT%T%'     THEN  'AT'||'&'||'T'
                      ELSE p.carrier_name
                      END  = CASE
                      WHEN x_byop_type LIKE 'Phone'     THEN   'VERIZON'
                      WHEN x_byop_type LIKE 'Tablet'    THEN   'VERIZON' -- CR45378
                      WHEN x_byop_type LIKE '%VERIZON%' THEN   'VERIZON'
                      WHEN x_byop_type LIKE 'CNL'       THEN   'SPRINT'
                      WHEN x_byop_type LIKE 'SPRINT%'   THEN   'SPRINT'
                      WHEN x_byop_type LIKE 'T-MO%'     THEN   'T-MOBILE'
                      WHEN x_byop_type LIKE 'TMO%'      THEN   'T-MOBILE'
                      WHEN x_byop_type LIKE 'AT%T%'     THEN  'AT'||'&'||'T'
                      ELSE x_byop_type
                      END
                                        and rownum<2),99) new_rank
      FROM pcpv v,
           table_part_class pc,
           table_part_num  pn,
           x_byop_part_num bp
     WHERE v.manufacturer  IS NOT NULL
       AND v.device_type   = NVL(i_device_type, v.device_type)--CR42257 added NVL
       AND v.part_class    = pc.name
       AND pc.objid        = pn.part_num2part_class
       AND pn.part_number  = bp.x_part_number
       AND bp.x_org_id     = i_brand
       AND v.technology    = NVL(i_technology,v.technology)  --CR42933 - ST Refresh changes
      order by new_rank;
--
  part_num_rec part_num_curs%rowtype;
  l_carrier   VARCHAR2(1000);
--
BEGIN
--
  FOR part_num_rec IN part_num_curs
  LOOP
    IF byop_service_pkg.verify_carrier_zip(part_num_rec.x_part_number,i_zip) IS NOT NULL
    THEN
      l_carrier  :=   CASE
                      WHEN part_num_rec.x_byop_type LIKE 'Phone'     THEN   'VERIZON'
                      WHEN part_num_rec.x_byop_type LIKE 'Tablet'    THEN   'VERIZON' -- CR45378
                      WHEN part_num_rec.x_byop_type LIKE '%VERIZON%' THEN   'VERIZON'
                      WHEN part_num_rec.x_byop_type LIKE 'CNL'       THEN   'SPRINT'
                      WHEN part_num_rec.x_byop_type LIKE 'SPRINT%'   THEN   'SPRINT'
                      WHEN part_num_rec.x_byop_type LIKE 'T-MO%'     THEN   'T-MOBILE'
                      WHEN part_num_rec.x_byop_type LIKE 'TMO%'      THEN   'T-MOBILE'
                      WHEN part_num_rec.x_byop_type LIKE 'AT%T%'     THEN  'AT'||'&'||'T'
                      ELSE NULL
                      END;
    END IF;
    --
    IF l_carrier IS NOT NULL AND INSTR(NVL(o_avlbl_carrier,'X'), NVL(l_carrier,'NNN')) < 1
    THEN
      o_avlbl_carrier :=  o_avlbl_carrier || ',' || l_carrier;
    END IF;
    --
  END LOOP;
  o_avlbl_carrier := ltrim(o_avlbl_carrier,' ,');
  IF o_avlbl_carrier IS NOT NULL
  THEN
    o_result_code :=  '0';
    o_result_msg  :=  'SUCCESS';
  ELSE
    o_result_code :=  '100';
    o_result_msg  :=  'NO COVERAGE';
  END IF;
  --
  DBMS_OUTPUT.put_line ('Carrier List'|| o_avlbl_carrier);
--
EXCEPTION
WHEN OTHERS   THEN
  ROLLBACK;
  o_result_code  := 99;
  o_result_msg   := SQLERRM;
--
END p_carrierlist_byop_brand_zip;
--
-- This procedure will be called from the service Coverage check - BYOP
-- This procedure will verify the carrier has coverage based on the carrier, brand, zip and device type
-- If the carrier is not passed, it will list the available carriers for based on the Input zip, brand, device type
--
PROCEDURE p_byop_coverage_check_wrp  ( i_zip             IN   VARCHAR2,
                                       i_brand           IN   VARCHAR2,
                                       i_device_type     IN   VARCHAR2,
                                       i_carrier         IN   VARCHAR2,
                                       i_technology      IN   VARCHAR2 default NULL,  --CR42933 - ST Refresh changes
                                       o_avlbl_carrier   OUT  VARCHAR2,
                                       o_result_code     OUT  VARCHAR2,
                                       o_result_msg      OUT  VARCHAR2
                                      )
IS
--
  l_avlbl_carrier VARCHAR2(4000);
  l_result_code   NUMBER;
  l_result_msg    VARCHAR2(1000);
--
BEGIN
--
  IF i_carrier IS NOT NULL
  THEN
    IF byop_service_pkg.fn_verify_carrier_dev_type (i_carrier, i_brand, i_zip, i_device_type ) = 'YES'
    THEN
      o_result_code   := '0';
      o_result_msg    := 'SUCCESS';
      RETURN;
    ELSE
      o_result_code   := '1';
      o_result_msg    := 'ERROR : Not Eligible';
      RETURN;
    END IF;
    --
  ELSE
    byop_service_pkg.p_carrierlist_byop_brand_zip (i_zip, i_brand, i_device_type,i_technology, l_avlbl_carrier, l_result_code, l_result_msg );  --CR42933 - ST Refresh changes to add technology input.
    --
    o_avlbl_carrier :=  l_avlbl_carrier;
    o_result_code   :=  l_result_code;
    o_result_msg    :=  l_result_msg;
    --
  END IF;
  --
  DBMS_OUTPUT.put_line ('Carrier List'|| o_avlbl_carrier);
  --
EXCEPTION
WHEN OTHERS   THEN
  ROLLBACK;
  o_result_code   := 99;
  o_result_msg    := SQLERRM;
--
END p_byop_coverage_check_wrp;
--
-- Generic procedure to initiate a VD
--
PROCEDURE p_create_vd_ig_trans(i_esn          IN    VARCHAR2,
                               i_esn_hex      IN    VARCHAR2,
                               i_order_type   IN    VARCHAR2,
                               i_template     IN    VARCHAR2,
                               i_account_num  IN    VARCHAR2,
                               i_status       IN    VARCHAR2,
                               o_result_code  OUT   VARCHAR2,
                               o_result_msg   OUT   VARCHAR2)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  --
  INSERT
  INTO gw1.ig_transaction
    (
      action_item_id,
      esn,
      esn_hex,
      order_type,
      template,
      account_num,
      status,
      TRANSACTION_ID
    )
    VALUES
    (
      sa.sequ_action_item_id.NEXTVAL,
      i_esn,
      i_esn_hex,
      i_order_type,
      i_template,
      i_account_num,
      i_status,
      (gw1.trans_id_seq.nextval + (POWER(2 ,28)))
    );
  COMMIT;
  o_result_code :=  0;
  o_result_msg  :=  'SUCCESS';
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  o_result_code   := 99;
  o_result_msg    := SQLERRM;
END p_create_vd_ig_trans;
--
-- This procedure is called from the service CDMA BYOP Eligibility and Coverage Check
/* This procedure will verify whether the carrier has the coverage based on the input parameters
   like Carrier, Brand, Zip and Device type. Checks whether VD order type has been sent if not, creates a new VD order
   and sends the result back to the service as Output. */
--
PROCEDURE p_cdma_byop_check  ( i_esn          IN    VARCHAR2,
                               i_zip          IN    VARCHAR2,
                               i_carrier      IN    VARCHAR2,
                               i_brand        IN    VARCHAR2,
                               o_buy_sim      OUT   VARCHAR2, -- CR45378
                               o_active       OUT   VARCHAR2,
                               o_lte          OUT   VARCHAR2,
                               o_result_code  OUT   VARCHAR2,
                               o_result_msg   OUT   VARCHAR2,
                               o_original_sim OUT   VARCHAR2  -- CR57569
                              )
IS
--
  l_esn                       table_part_inst.part_serial_no%TYPE;
  --
  CURSOR c_byop_part_num
  IS
    SELECT bpn2.x_org_id       new_bus_org_id,
           bpn2.x_part_number  new_part_number,
           bpn.x_org_id        old_bus_org_id,
           bpn.x_part_number   old_part_number
    FROM   table_part_inst  pi,
           table_mod_level  ml,
           table_part_num   pn,
           x_byop_part_num  bpn,
           table_x_byop     byop,
           x_byop_part_num  bpn2
    WHERE pi.part_serial_no = l_esn
    AND   pi.x_domain       = 'PHONES'
    AND   ml.objid          = pi.n_part_inst2part_mod
    AND   pn.objid          = ml.part_info2part_num
    AND   bpn.x_part_number = pn.s_part_number
    AND   bpn.x_org_id      = i_brand
    AND   byop.x_esn        = pi.part_serial_no
    AND   byop.x_byop_type  = bpn.x_byop_type
    AND   bpn2.x_byop_type LIKE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(bpn.x_byop_type,'TRACFONE','%'),
                                                                                        'STRAIGHT_TALK','%'),
                                                                                        'STRAIGHT_TALK_RS','%\_RS'),
                                                                                        'STRAIGHT_TALK_NRS','%\NRS'),
                                                                                        'NET10','%'),
                                                                                        'NET10_RS','%\_RS'),
                                                                                        'NET10_NRS','%\_NRS'),
                                                                                        'TELCEL','%'),
                                                                                        'TOTAL_WIRELESS','%') ESCAPE '\';
  --
  CURSOR c_part_num (i_part_num IN VARCHAR2)
  IS
    SELECT ml.objid mod_level_objid
    FROM   table_mod_level   ml,
           table_part_num    pn,
           table_part_class  pc
    WHERE pn.part_number            = i_part_num
    AND   ml.part_info2part_num     = pn.objid
    AND   pn.part_num2part_class    = pc.objid;
  --
  c_part_num_rec c_part_num%rowtype;
  --
  l_phone_gen                 VARCHAR2 (100);     ------> LTE, NON_LTE
  l_phone_model               VARCHAR2 (100);     ------> APPL
  l_technology                VARCHAR2 (100);     ------> CDMA
  l_sim_reqd                  VARCHAR2 (100);     ------> YES,NO
  l_original_sim              VARCHAR2 (100);     ------> 1234567890756735
  l_carrier                   VARCHAR2 (100);
  l_error_num                 NUMBER;
  l_error_code                VARCHAR2 (100);
  l_err_no                    NUMBER;
  l_err_str                   VARCHAR2 (100);
  l_esn_hex                   ig_transaction.esn_hex%TYPE;
  l_previous_brand            VARCHAR2(100);
  l_phone_status              table_part_inst.part_status%TYPE;
  l_web_user_objid            table_web_user.objid%TYPE;
  v_returncode_count          NUMBER := 0; --CR51418 - ALLOWING VZ DISCOUNT 1 for VZ
  --
  PROCEDURE p_validate_device
  IS
  --
  BEGIN
  --
    DBMS_OUTPUT.PUT_LINE('inside p_validate_device ');
    byop_service_pkg.last_vd_ig_trans   (p_esn          =>  l_esn,
                                         p_bus_org      =>  i_brand,
                                         p_phone_gen    =>  l_phone_gen,
                                         p_phone_model  =>  l_phone_model,
                                         p_technology   =>  l_technology,
                                         p_sim_reqd     =>  l_sim_reqd,
                                         p_original_sim =>  l_original_sim,
                                         p_carrier      =>  l_carrier,
                                         p_error_num    =>  l_error_num,
                                         p_error_code   =>  l_error_code );
    --
    IF l_error_num = 1 AND i_carrier IN  ('VERIZON','SPRINT')
    THEN
      --
      byop_service_pkg.p_create_vd_ig_trans(i_esn         =>  l_esn,
                                            i_esn_hex     =>  l_esn_hex,
                                            i_order_type  =>  'VD',
                                            i_template    =>  (CASE
                                                               WHEN  i_carrier ='VERIZON'
                                                               THEN  'RSS'
                                                               ELSE  i_carrier
                                                               END),
                                            i_account_num =>  '1161',
                                            i_status      =>  'Q',
                                            o_result_code =>  l_error_num,
                                            o_result_msg  =>  l_error_code);
      o_result_code   :=  '110';
      o_result_msg    := 'PROCESSING';
      DBMS_OUTPUT.PUT_LINE('inside pcreate vd');
      RETURN;
      --
    ELSIF l_error_num = 4 AND l_error_code = 'PENDING'
    THEN
      o_result_code   :=  '110';
      o_result_msg    := 'PROCESSING';
      DBMS_OUTPUT.PUT_LINE('returned by existing proc ');
      RETURN;
    --
    ELSIF l_error_num = 2 AND l_error_code LIKE 'ELIGIBLE%' AND i_carrier = 'SPRINT'
    THEN
      --
      IF l_error_code LIKE 'ELIGIBLE ACTIVE%'
      THEN
        o_active  := 'YES';
      ELSE
        o_active  := 'NO';
      END IF;
      --
       --CR52545 Modify BYOP registration Service to assign HD part class for Verizon VOLTE, mdave, 07/26/2017
      --IF l_phone_gen = 'LTE'
      IF l_phone_gen = 'LTE' OR  l_phone_gen = 'LTE_HD'
    -- END  CR52545 Modify BYOP registration Service to assign HD part class for Verizon VOLTE, mdave, 07/26/2017
      THEN
        o_lte := 'YES';
      ELSE
        o_lte := 'NO';
      END IF;
      --
      o_result_code   :=  '0';
      o_result_msg    :=  'Eligible';
      RETURN;
      --
    ELSIF l_error_num = 2 AND l_error_code LIKE 'ELIGIBLE%' AND i_carrier = 'VERIZON' and UPPER(l_error_code)  LIKE '%DISCOUNT 1%'
    THEN
      o_result_code   :=  '130';
      o_result_msg   :=  'ERROR: Not Eligible Under Contract';
      RETURN;
    --
    ELSIF l_error_num = 2 AND l_error_code LIKE 'ELIGIBLE%' AND i_carrier = 'VERIZON'
    THEN
      --CR52545 Modify BYOP registration Service to assign HD part class for Verizon VOLTE, mdave, 07/26/2017
    -- IF l_phone_gen ='LTE'
    IF l_phone_gen ='LTE' OR l_phone_gen ='LTE_HD'
    -- END  CR52545 Modify BYOP registration Service to assign HD part class for Verizon VOLTE, mdave, 07/26/2017
      THEN
        o_lte := 'YES';
      ELSE
        o_lte := 'NO';
      END IF;
      --
      IF UPPER(l_error_code) LIKE '%DISCOUNT 2%'
      THEN
        o_active := 'YES';
      ELSE
        o_active := 'NO';
      END IF;
      --
      o_result_code   :=  '0';
      o_result_msg    :=  'Eligible';
      RETURN;
      --
    ELSIF l_error_num = 3 AND l_error_code ='NOT ELIGIBLE'
    THEN
      o_result_code   :=  '150';
      o_result_msg   :=  'ERROR: Not Eligible as per Carrier';
      RETURN;
    END IF;
  --
  END p_validate_device;
  --
BEGIN -- p_cdma_byop_check MAIN
--
  -- Validate input values
  IF i_esn  IS NULL OR i_zip IS NULL OR i_carrier IS NULL OR i_brand IS NULL
  THEN
    o_result_code   :=  '115';
    o_result_msg    :=  'Input values cannot be null';
    RETURN;
  END IF;

  --Start CR51418
  BEGIN --{
    SELECT /*+ USE_INVISIBLE_INDEXES */ COUNT(*)
      INTO v_returncode_count
    FROM   gw1.ig_transaction ig
    WHERE  esn                 = i_esn
      AND  order_type          = 'VD'
      AND  template            = 'RSS'
      AND  LTRIM(SUBSTR(SUBSTR(status_message,INSTR(status_message, 'returnCode')),1, INSTR(SUBSTR(status_message,INSTR(status_message, 'returnCode')),',')-1), 'returnCode=') = 'S0049'
      AND  i_brand NOT IN ('STRAIGHT_TALK','NET10')
      AND  ROWNUM = 1;
  EXCEPTION
  WHEN OTHERS THEN
    v_returncode_count := 0;
  END; --}

  IF v_returncode_count > 0
  THEN --{
    o_result_code   :=  '150';
    o_result_msg    :=  'ERROR: Not Eligible as per Carrier';
    RETURN;
  END IF; --}
  --End  CR51418

  -- CR45378 changes starts..
  BEGIN
    SELECT DECODE(COUNT(*),0,'Y','N')
      INTO o_buy_sim
    FROM   table_x_byop_offers
    WHERE  bus_org_id    =   i_brand
      AND  carrier       =   i_carrier
      AND  offer_key     =   'BUY_SIM'
      AND  active_flag   =   'N';
  EXCEPTION
  WHEN OTHERS THEN
    o_buy_sim :=  'Y';
  END;
  -- CR45378 changes ends.
  -- Convert esn to decimal / hexadecimal based on the carrier and length of digits
  util_pkg.p_convert_esn (i_serial_no   =>  i_esn,
                          i_carrier     =>  i_carrier,
                          i_err_no      =>  l_err_no,
                          i_err_str     =>  l_err_str,
                          i_esn         =>  l_esn,
                          i_esn_hex     =>  l_esn_hex);
  --
  IF l_err_no <> 0
  THEN
    o_result_code   :=  l_err_no;
    o_result_msg    :=  'Convert ESN failed - ' || l_err_str;
    RETURN;
  END IF;
  --
  IF byop_service_pkg.verify_esn (l_esn ) IS NOT NULL -- ESN is in Database
  THEN
    -- Get the Brand name passing esn
    l_previous_brand  :=  util_pkg.get_bus_org_id(l_esn);
    --
    -- Get the Phone status passing esn
    l_phone_status  :=  toss_util_pkg.get_pi_status_fun(l_esn, 'BYOP_SERVICE_PKG');
    p_validate_device ;           -- CR46176  PMistry 11/23/2016 Go Solution move the validate device procedure call to return LTE flag value which is calculated inside the proc.
    --
    IF l_previous_brand  = i_brand   -- Current brand and selected brand are same
    THEN
      --
      IF l_phone_status IN ('50','51','150','54')
      THEN
        o_result_code   :=  '160';
        o_result_msg    :=  'ERROR: Phone Registered already, needs to Activate';
        RETURN;
      ELSIF l_phone_status IN ('52')
      THEN
        o_result_code   :=  '170';
        o_result_msg    :=  'ERROR: Phone Already Active';
        RETURN;
      ELSIF l_phone_status IN ('151')
      THEN
          --p_validate_device ;       -- CR46176  PMistry 11/23/2016 Go Solution move the validate device procedure call to return LTE flag value which is calculated inside the proc.
        NULL;
      ELSE
        o_result_code   :=  '180';
        o_result_msg    :=  'ERROR: Invalid Phone Status';
        RETURN;
      END IF;
    ELSE -- Current brand and selected brand are different
      --
      IF byop_service_pkg.verify_carrier_coverage (i_carrier, i_brand, i_zip ) = 'YES'
      THEN
        IF l_phone_status IN ('151')
        THEN
          -- Remove ESN from account
          UPDATE table_part_inst
            SET  x_part_inst2contact = NULL
          WHERE  part_serial_no      = l_esn
            AND  x_domain            = 'PHONES';
          --
          DELETE table_x_contact_part_inst
          WHERE  x_contact_part_inst2part_inst = (SELECT objid
                                                  FROM   table_part_inst
                                                  WHERE  part_serial_no      = l_esn
                                                    AND  x_domain            = 'PHONES');
          --  change the part class to the given brand equivalent part class
          FOR part_num_rec IN c_byop_part_num
          LOOP
            IF byop_service_pkg.verify_carrier_zip(part_num_rec.new_part_number,i_zip) IS NOT NULL
            THEN
              OPEN c_part_num(part_num_rec.new_part_number);
              FETCH c_part_num INTO c_part_num_rec;
              IF c_part_num%notfound
              THEN
                CLOSE c_part_num;
                o_result_code:= '190';
                o_result_msg :='ERROR: Equivalent Part Number for the new Brand not found';
                RETURN;
              ELSE
                CLOSE c_part_num;
              END IF;
              --
              UPDATE table_part_inst
                 SET n_part_inst2part_mod   = c_part_num_rec.mod_level_objid
              WHERE  part_serial_no         = l_esn
                AND  x_domain               = 'PHONES';
              EXIT;
            END IF;
          END LOOP;
          --
            --p_validate_device ;  -- CR46176  PMistry 11/23/2016 Go Solution move the validate device procedure call to return LTE flag value which is calculated inside the proc.
          RETURN;
        ELSE  -- Phone status is other than 151- BYOP PENDING
          o_result_code   :=  '200';
          o_result_msg    :=  'ERROR: Not Eligible';
          RETURN;
        END IF;
      ELSE
        o_result_code   :=  '210';
        o_result_msg    := 'ERROR: Not Eligible for Brand';
      END IF;
      --
    END IF;
  ELSE    -- ESN is not in Database
    --
    p_validate_device;
    --CR57569 Return the ICCID if the carrier is SPRINT
    IF (l_original_sim IS NOT NULL AND i_carrier = 'SPRINT')
    THEN
      o_original_sim := l_original_sim;
    END IF;
    --CR57569 End
    RETURN;
  --
  END IF;
--
EXCEPTION
  WHEN OTHERS THEN
  o_result_code  :=   '99';
  o_result_msg   :=   SQLERRM;
END p_cdma_byop_check;
--
-- CR31456 Changes
-- This procedure is called from service CDMA BYOP Registration
/* It calls the existing procedure byop_service_pkg.insert_esn_prenew
   to register the SIM and esn. And also calls byop_service_pkg.process_pin
   to validate and redeem the network access code/ redemption code.
*/
--'
PROCEDURE p_cdma_byop_registration (i_esn         IN    VARCHAR2, -- IMEI / MEID
                                    i_carrier     IN    VARCHAR2,
                                    i_zip         IN    VARCHAR2,
                                    i_sim         IN    VARCHAR2,
                                    i_red_code    IN    VARCHAR2, -- Network Access Code
                                    i_brand       IN    VARCHAR2,
                                    i_byop_type   IN    VARCHAR2, -- Device Type
                                    i_source      IN    VARCHAR2,
                                    o_result_code OUT   VARCHAR2,
                                    o_result_msg  OUT   VARCHAR2
                                    )
IS
--
  CURSOR c_sim_status
  IS
  SELECT /*+ USE_INVISIBLE_INDEXES */
         x_sim_serial_no,
         x_sim_inv_status,
         pn.part_number
  FROM   sa.table_x_sim_inv si,
         sa.table_mod_level ml,
         sa.table_part_num pn
  WHERE  si.x_sim_serial_no     = i_sim
  AND    si.X_SIM_INV2PART_MOD  = ml.objid
  AND    ml.part_info2part_num  = pn.objid;
  --
  sim_status_rec          c_sim_status%rowtype;
  k_byop_insertion_type   CONSTANT VARCHAR2(10) := 'WARP_NEW';
  l_part_number           table_part_num.part_number%TYPE;
  l_part_num              table_part_num.part_number%TYPE; -- CR48202
  l_call_trans_objid      table_x_call_trans.objid%TYPE;
  l_error_code            VARCHAR2(1000);
  l_error_num             NUMBER;
  l_err_num               VARCHAR2(1000);
  l_err_string            VARCHAR2(1000);
  l_byop_type             VARCHAR2(200);
  l_def_byop_type         VARCHAR2(200);
  l_phone_gen             VARCHAR2 (100);     ------> LTE, NON_LTE
  l_phone_model           VARCHAR2 (100);     ------> APPL
  l_technology            VARCHAR2 (100);     ------> CDMA
  l_sim_reqd              VARCHAR2 (100);     ------> YES,NO
  l_original_sim          VARCHAR2 (100);     ------> 1234567890756735
  l_carrier               VARCHAR2 (100);
  l_sim_profile           VARCHAR2(100);
  l_sim_compatible        VARCHAR2(100);
  l_sim_type              VARCHAR2(200);
  l_is_sim_removable      NUMBER;
  l_sim_size              VARCHAR2(10);      -- CR46176 For Go Solution
--
BEGIN
--
--i_red_code is made optional CR44390
  IF i_esn IS NULL OR  i_carrier IS NULL OR i_zip IS NULL /*OR i_red_code IS NULL */OR i_brand IS NULL OR i_byop_type IS NULL OR  i_source IS NULL
  THEN
    o_result_code   :=  '380';
    o_result_msg    :=  'ERROR: Invalid Input Parameters';
    RETURN;
  END IF;
  --
  -- CR46176 For Go Solution
  IF i_sim IN ('NANO','DUAL','REGULAR','MICRO','STANDARD','TRIO') then --CR53217,ADDED 'TRIO'
    l_sim_size  := i_sim;
  END IF;
  --
  byop_service_pkg.last_vd_ig_trans (p_esn          =>  i_esn,
                                     p_bus_org      =>  i_brand,
                                     p_phone_gen    =>  l_phone_gen,
                                     p_phone_model  =>  l_phone_model,
                                     p_technology   =>  l_technology,
                                     p_sim_reqd     =>  l_sim_reqd,
                                     p_original_sim =>  l_original_sim,
                                     p_carrier      =>  l_carrier,
                                     p_error_num    =>  l_error_num,
                                     p_error_code   =>  l_error_code );
  --
  IF l_sim_size IS NULL THEN      -- CR46176 Added to skip SIM validation if the SIM size is passed.
    IF l_sim_reqd    = 'YES' AND i_sim IS NULL AND i_carrier <> 'SPRINT'
    THEN
      o_result_code := '300';
      o_result_msg  := 'ERROR: SIM Required';
      RETURN;
    ELSIF l_sim_reqd = 'YES' AND i_sim IS NOT NULL
    THEN
      OPEN c_sim_status;
      FETCH c_sim_status INTO sim_status_rec;
      IF c_sim_status%found AND sim_status_rec.x_sim_inv_status <> '253'
      THEN
        CLOSE c_sim_status;
        o_result_code := '310';
        o_result_msg  := 'ERROR: SIM already in use';
        RETURN;
      ELSIF c_sim_status%notfound
      THEN
        o_result_code := '350';
        o_result_msg  := 'ERROR: SIM not found in Inventory';
        CLOSE c_sim_status;
        RETURN;
      ELSE
        CLOSE c_sim_status;
      END IF;
      --
    END IF;
  END IF;
  --
  IF i_byop_type  = 'BYOP'
  THEN
    l_def_byop_type  := 'Phone';
  ELSIF i_byop_type  = 'BYOT'
  THEN
    l_def_byop_type  := 'Tablet';
  ELSE
    l_def_byop_type  :=  i_byop_type;
  END IF;
  --
  -- CR46176 PMistry Added to pass the sim type if sim size is passed in input parameter.
  IF i_sim     IS NOT NULL AND l_sim_size IS NULL
  THEN
    l_sim_type    :=  byop_service_pkg.get_byop_sim_type  (p_sim_partnum => sim_status_rec.part_number);
  ELSIF  i_sim  IS NOT NULL AND l_sim_size IS NOT NULL
  THEN
    l_sim_type := l_sim_size;
  END IF;
  --
  l_byop_type :=  byop_service_pkg.get_byop_type (ip_carrier     =>   i_carrier,
                                                  ip_phone_model =>   l_phone_model,
                                                  ip_sim_type    =>   l_sim_type,
                                                  ip_phone_gen   =>   l_phone_gen,
                                                  ip_technology  =>   l_technology,
                                                  ip_brand       =>   i_brand,
                                                  ip_byop_type   =>   i_byop_type); -- CR44390 - Add Byop type for handling BYOT
  --
  IF i_carrier = 'SPRINT' AND l_phone_model ='OTHER' AND l_phone_gen = 'LTE' AND l_technology = 'CDMA'  --  SPRINT_OTHER_LTE_CDMA_STRAIGHT_TALK_NRS
  THEN
    l_is_sim_removable  :=  lte_service_pkg.is_lte_4g_sim_rem (p_esn  => i_esn);
    IF  l_is_sim_removable <> 0
    THEN
      l_byop_type :=  l_byop_type || '_NRS';
    ELSE
      l_byop_type :=  l_byop_type || '_RS';
    END IF;
  END IF;
  --
  /*IF i_sim IS NOT NULL
  THEN
    byop_service_pkg.validate_byop_sim (ip_esn              =>   i_esn,
                                        ip_sim              =>   i_sim,
                                        ip_zip              =>   i_zip,
                                        ip_carrier          =>   i_carrier,
                                        ip_bus_org          =>   i_brand,
                                        ip_phone_model      =>   l_phone_model,
                                        ip_byop_type        =>   NVL(l_byop_type,l_def_byop_type),
                                        out_sim_profile     =>   l_sim_profile,
                                        out_sim_compatible  =>   l_sim_compatible,
                                        out_sim_type        =>   l_sim_type,
                                        out_err_num         =>   l_error_num,
                                        out_err_msg         =>   l_error_code);
    --
    IF l_error_num  <> 0
    THEN
      o_result_code :=  '360';
      o_result_msg  :=  l_error_code;
      RETURN;
    END IF;
  END IF;     */
  --'
  byop_service_pkg.insert_esn_prenew (p_esn                 =>    i_esn,
                                      p_old_esn             =>    NULL,
                                      p_org_id              =>    i_brand,
                                      p_byop_type           =>    l_byop_type,
                                      p_BYOP_MANUFACTURER   =>    NULL,
                                      p_BYOP_MODEL          =>    NULL,
                                      p_BYOP_INSERTION_TYPE =>    k_byop_insertion_type,
                                      p_error_num           =>    l_error_num,
                                      p_error_code          =>    l_error_code,
                                      p_sim                 =>    case
                                                                  when l_sim_size is null then
                                                                    i_sim
                                                                  else
                                                                    null
                                                                  end ,               -- CR46176 For Go Solution Don't pass the SIM value to avoid SIM marry if SIM size is passed
                                      p_zip                 =>    i_zip,
                    p_part_num            =>    l_part_num --CR48202
                    );
  --
  IF l_error_num = 0 THEN
    IF l_sim_size IS NULL THEN        -- CR46176 Skip the NAC Validation and NAC Burn if SIM Size is passed
    --  Validate NAC
    --
      IF i_red_code IS NOT NULL--do NAC validation only if NAC code is Not null CR44390
      THEN
          IF byop_service_pkg.valid_reg_pin (p_red_code    => i_red_code,
                                             p_org_id      => i_brand,
                                             p_part_number => l_part_number)  <> 'TRUE'
          THEN
            o_result_code :=  '330';
            o_result_msg  :=  'NAC for Incorrect brand';
            RETURN;
          END IF;
          --
          --  Validate NAC
          byop_service_pkg.reg_card_usable (p_red_code => i_red_code,
                                            p_out_code => l_err_num,
                                            p_out_desc => l_error_code);
          --
          IF l_err_string <> 'CARD USABLE'
          THEN
            o_result_code :=  '340';
            o_result_msg  :=  'Invalid NAC';
            RETURN;
          END IF;
          --
          -- Set commit global variable to FALSE
          globals_pkg.g_perform_commit := FALSE;
          --  Burn NAC
          QUEUE_CARD_PKG.SP_REDEEM_CARD( p_esn                =>  i_esn,
                                         p_red_card           =>  i_red_code,
                                         p_source_system      =>  i_source,
                                         p_call_trans_objid   =>  l_call_trans_objid,
                                         p_err_num            =>  l_error_num,
                                         p_err_string         =>  l_error_code);
          -- Set commit global variable to TRUE
          globals_pkg.g_perform_commit := TRUE;


      END IF;--NAC Validation Block
    END IF;
        --Moving the below block outside NAC validation block since NAC code is optional CR44390
  /*      IF l_error_num = 0
        THEN
          -- Set phone status to NEW
          UPDATE table_part_inst
          SET    x_part_inst_status   = '50',
                 status2x_code_table  = (SELECT objid FROM table_x_code_table WHERE x_code_number = '50')
          WHERE  part_serial_no = i_esn
          AND    x_domain       = 'PHONES';
          --
          o_result_code :=  '0';
          o_result_msg  :=  'SUCCESS';
        ELSE
          o_result_code     :=  '320';
          o_result_msg      :=  l_error_code;
          RETURN;
        END IF;*/
  ELSE
    o_result_code := l_error_code;      -- CR46176  PMistry 11/23/2016 Go Solution Corrected the error code and message
    o_result_msg  := 'FAIL';
    RETURN;
  END IF;

  IF l_error_num = 0
    THEN
      -- Set phone status to NEW
      UPDATE table_part_inst
      SET    x_part_inst_status   = '50',
             status2x_code_table  = (SELECT objid FROM table_x_code_table WHERE x_code_number = '50'),
             X_PART_INST2CONTACT  = decode (X_PART_INST2CONTACT, -111, NULL, X_PART_INST2CONTACT)  --CR44390 Update -111 to null so contact will be loaded by CBO.
      WHERE  part_serial_no = i_esn
      AND    x_domain       = 'PHONES';
      --
      o_result_code :=  '0';
      o_result_msg  :=  'SUCCESS';
  ELSE
      o_result_code     :=  '320';
      o_result_msg      :=  l_error_code;
      RETURN;
  END IF;
--
EXCEPTION
  WHEN OTHERS THEN
  o_result_code   := 99;
  o_result_msg    := SQLERRM;
  --
END p_cdma_byop_registration;
--
-- CR31456 Changes
-- This procedure will be called from service `Check Activation Scenario service?
/* This procedure will accept flow condition, from phone platform, to phone platform
   and return whether PIN is required / Optional / Not required. */
--
PROCEDURE p_check_activation_scenario (i_flow_scenario          IN  VARCHAR2,
                                       i_from_phone_scenario    IN  VARCHAR2,
                                       i_to_phone_scenario      IN  VARCHAR2,
                                       i_from_esn               IN  VARCHAR2,
                                       i_to_esn                 IN  VARCHAR2,
                                       i_pin_reqd               OUT VARCHAR2)
IS
  --
  CURSOR c_esn_bal_meter (c_to_propagate_flag  IN VARCHAR2)
  IS
  SELECT DECODE (uh.short_name, 'VZW', 'SUREPAY',
                                'ATT', 'ERICSSON',uh.short_name ) AS "balance_metering"
  FROM   x_usage_host     uh
  WHERE  uh.propagate_flag_value  = c_to_propagate_flag;
  --
  CURSOR c_get_pin_reqd (c_from_phone_scenario  IN  VARCHAR2,
                         c_to_phone_scenario    IN  VARCHAR2)
  IS
  SELECT pin_reqd
  FROM   table_pin_options
  WHERE  flow_scenario            = i_flow_scenario
  AND    to_phone_scenario        = c_to_phone_scenario
  AND    from_phone_scenario      = c_from_phone_scenario;
  --
  l_plan_compatibility      VARCHAR2(1) := 'N';
  l_from_phone_scenario     VARCHAR2(20);
  l_to_phone_scenario       VARCHAR2(20);
  l_from_bal_meter          VARCHAR2(20);
  l_to_bal_meter            VARCHAR2(20);
  l_to_propagate_flag       x_usage_host.propagate_flag_value %TYPE;
  l_to_rate_plan            VARCHAR2(50);
  l_from_esn_sp             VARCHAR2(50);
  l_err_msg                 VARCHAR2(200);
  l_from_ivr_plan_id        x_service_plan.ivr_plan_id%TYPE;
  -- CR45378 changes starts..
  l_group_rec               x_account_group%ROWTYPE;
  l_brand_rec               table_bus_org%ROWTYPE;
  c                         customer_type :=  customer_type();
  l_service_end_date        DATE;
  -- CR45378 changes ends
  --
BEGIN
  -- Input Validation
  /**/
  --
  -- CR45378 changes starts..
  -- i_from_esn validation will be done only phone upgrade scenario
  /* to_esn value will be used for rest of scenarios, as SOA service is designed to
     send value to to_esn */
  --
  l_group_rec         :=  brand_x_pkg.get_group_rec (ip_esn => i_to_esn);
  --
  l_brand_rec         :=  util_pkg.get_bus_org_rec ( i_esn => i_to_esn);
  l_service_end_date  :=  TRUNC(c.get_expiration_date (i_esn => i_to_esn ));
  --
  IF  l_group_rec.objid                      IS NOT NULL          AND
      NVL(l_brand_rec.shared_group_flag,'N') =   'Y'              AND
      l_brand_rec.org_id                     =   'TOTAL_WIRELESS' AND
      sa.brand_x_pkg.is_master_esn_active(i_esn=>i_to_esn)   ='Y' AND --Added for  CR55236 TW Web common standards
      i_flow_scenario                        <>  'REACTIVATION'
  THEN
    -- IF ESN belongs to a group and scenario is other than Activation, PIN is not required
    i_pin_reqd  :=  'NO';
    --
  ELSIF i_flow_scenario       =   'REACTIVATION'  AND
        (l_service_end_date    IS NOT NULL        AND
        l_service_end_date    >   TRUNC(SYSDATE)) AND
        NVL(l_brand_rec.PIN_REQUIRED_REACTIVATION_FLAG, 'Y') = 'N' --CR47564
  THEN
    -- If the service end date is in future, reactivation without PIN should be allowed for TF and NT brands only
    i_pin_reqd  :=  'NO';
    RETURN;
  -- CR45378 changes ends.
  ELSIF i_flow_scenario ='PHONE_UPGRADE'  -- Phone Upgrade
  THEN
    l_from_esn_sp       :=  util_pkg.get_service_plan_id (i_esn => i_from_esn );
    --
    IF l_from_esn_sp  IS NULL AND l_brand_rec.org_id  =   'TRACFONE'
    THEN
      l_from_esn_sp     :=  252;
    END IF;
    -- get IVR plan ID of from phone's sp
    BEGIN
      SELECT  ivr_plan_id
      INTO    l_from_ivr_plan_id
      FROM    x_service_plan
      WHERE   objid = l_from_esn_sp;
    EXCEPTION
    WHEN OTHERS THEN
      l_from_ivr_plan_id  :=   NULL;
    END;
    -- Look for directly compatibility of sp
    BEGIN
      SELECT 'Y'
      INTO   l_plan_compatibility
      FROM   ADFCRM_SERV_PLAN_CLASS_MATVIEW  spc ,
             table_mod_level                 ml,
             table_part_num                  pn,
             table_part_class                pc,
             table_part_inst                 pi
      WHERE  spc.PART_CLASS_OBJID   = pc.objid
      AND    spc.SP_OBJID           = l_from_esn_sp
      AND    pc.objid               = pn.part_num2part_class
      AND    pn.objid               = ml.part_info2part_num
      AND    ml.objid               = pi.n_part_inst2part_mod
      AND    pi.x_domain            = 'PHONES'
      AND    pi.part_serial_no      = i_to_esn;
    EXCEPTION
      WHEN no_data_found THEN
        BEGIN  -- look for compatibility through ivr plan id
          SELECT 'Y'
          INTO   l_plan_compatibility
          FROM   ADFCRM_SERV_PLAN_CLASS_MATVIEW  spc ,
                 table_mod_level                 ml,
                 table_part_num                  pn,
                 table_part_class                pc,
                 table_part_inst                 pi,
                 x_service_plan                  sp
          WHERE  spc.PART_CLASS_OBJID   = pc.objid
          AND    spc.sp_objid           = sp.objid
          AND    sp.ivr_plan_id         = l_from_ivr_plan_id
          AND    pc.objid               = pn.part_num2part_class
          AND    pn.objid               = ml.part_info2part_num
          AND    ml.objid               = pi.n_part_inst2part_mod
          AND    pi.x_domain            = 'PHONES'
          AND    pi.part_serial_no      = i_to_esn
           AND ROWNUM=1;
        EXCEPTION
          WHEN OTHERS THEN
            l_plan_compatibility  :=  'N';
        END;
      WHEN OTHERS THEN
        l_plan_compatibility  :=  'N';
    END;
    -- Current phone's plan is LIMITED and compatible with new phone
    IF l_plan_compatibility  = 'Y' AND i_from_phone_scenario = 'LIMITED'
    THEN
      --
      l_from_phone_scenario   :=  i_from_phone_scenario;
      l_to_phone_scenario     :=  'ALL';
    --
    ELSIF l_brand_rec.org_id  =   'TRACFONE' AND i_from_phone_scenario = 'UNLIMITED'
    THEN
      l_from_phone_scenario   :=  i_from_phone_scenario;
      l_to_phone_scenario     :=  'ALL';
      -- Current phone's plan is UNLIMITED and compatible with new phone
    ELSIF  l_plan_compatibility  = 'Y' AND i_from_phone_scenario = 'UNLIMITED'
    THEN
      l_from_phone_scenario   :=  i_from_phone_scenario;
      l_to_phone_scenario     :=  'ALL';
    ELSE
      l_from_phone_scenario   :=  'PLAN NOT COMPATIBLE';
      l_to_phone_scenario     :=  'PLAN NOT COMPATIBLE';
    END IF;
  ELSE  -- NON phone upgrade scenarios like New Line Activation / Cross company port / External port
    l_from_phone_scenario  :=  NVL(i_from_phone_scenario,'ALL');
    l_to_phone_scenario    :=  i_to_phone_scenario;
  END IF;
  --
  BEGIN
    SELECT pin_reqd
    INTO   i_pin_reqd
    FROM   table_pin_options
    WHERE  flow_scenario            = i_flow_scenario
    AND    from_phone_scenario      = l_from_phone_scenario
    AND    to_phone_scenario        = l_to_phone_scenario;
  EXCEPTION
  WHEN OTHERS THEN
    l_err_msg   :=  'Failed in when others while fetching the pin option';
  END;
--
END p_check_activation_scenario;
-- CR31456 changes ends

/******************CR39192 overloaded procedures added ***************************************/
PROCEDURE last_vd_ig_trans ( p_esn                 IN  VARCHAR2,
                             p_bus_org             IN  VARCHAR2,
                             p_zipcode             IN  VARCHAR2,
                             p_phone_gen           OUT VARCHAR2, ------> LTE, NON_LTE
                             p_phone_model         OUT VARCHAR2, ------> APPL
                             p_technology          OUT VARCHAR2, ------> CDMA
                             p_sim_reqd            OUT VARCHAR2, ------> YES,NO
                             p_original_sim        OUT VARCHAR2, ------> 1234567890756735
                             p_carrier             IN OUT VARCHAR2,
                             p_islostorstolen      OUT VARCHAR2,
                             p_recordcode          OUT VARCHAR2, --CR51418 ALLOWING VZ DISCOUNT 1 for VZ
                             p_error_num           OUT NUMBER,
                             p_error_code          OUT VARCHAR2 ,
                             p_retmsg_lang         IN  VARCHAR2 DEFAULT 'ENG', --CR49064
                             p_retmsg              OUT VARCHAR2 ,              --CR49064
                             p_timediff            OUT NUMBER,                 --CR53201
                             p_islostorstolen_flag IN  VARCHAR2 DEFAULT 'N')   --CR54759
IS
  CURSOR last_ig_curs
  IS
    SELECT /*+ USE_INVISIBLE_INDEXES */
          (CASE WHEN template = 'SPRINT' THEN iccid
                ELSE null
           END) S_iccid,
          (CASE WHEN template = 'SPRINT' AND (UPPER(status_message) LIKE '%APPLE%') AND (UPPER(STATUS_MESSAGE) NOT LIKE '%IPHONE 4%') THEN 'IPHONE'
                ELSE 'OTHER'
           END) s_phone_model,
          (CASE WHEN template = 'SPRINT' AND iccid IS NULL THEN 'NON_LTE'
                WHEN template = 'SPRINT' AND (UPPER(status_message) LIKE '%DEVICETYPE=E%' or UPPER(status_message) LIKE '%DEVICETYPE=U%') THEN 'LTE'
           END) s_phone_gen,
          (CASE WHEN template= 'SPRINT' AND (iccid IS NULL or UPPER(status_message) like '%DEVICETYPE=E%') THEN 'NO'
                WHEN template= 'SPRINT' AND (UPPER(status_message) LIKE '%DEVICETYPE=U%') THEN 'YES'
           END) s_sim_reqd,
          (CASE WHEN template = 'RSS' AND UPPER(ig.x_mpn) LIKE '%APL%' THEN 'IPHONE'
                ELSE 'OTHER'
           END) v_phone_model,
          (CASE WHEN template ='RSS' AND UPPER(ig.x_pool_name) LIKE '%4G%' THEN 'LTE'
                ELSE 'NON_LTE'
           END) v_phone_gen,
          (CASE WHEN template = 'RSS' AND UPPER(ig.x_pool_name) LIKE '%4G%' THEN 'YES'
                ELSE 'NO'
           END) v_sim_reqd,
          (CASE WHEN template = 'RSS' THEN
                LTRIM(SUBSTR(SUBSTR(status_message,INSTR(status_message, 'returnCode')),1, INSTR(SUBSTR(status_message,INSTR(status_message, 'returnCode')),',')-1), 'returnCode=')
                ELSE ''
           END) returnCode,
          ig.*,
          ROUND((SYSDATE-ig.creation_date)*24*60) timediff --CR53201
    FROM gw1.ig_transaction ig
    WHERE esn                  = p_esn
      AND order_type           = 'VD'
      AND NVL(ig.zip_code,'X') = NVL(p_zipcode,'X')--CR39192
      AND template             = DECODE(p_carrier,'VERIZON','RSS',null,template,p_carrier) --CR39192
    ORDER BY ig.transaction_id DESC;
  last_ig_rec last_ig_curs%ROWTYPE;

BEGIN
  OPEN last_ig_curs;
  FETCH last_ig_curs INTO last_ig_rec;
  IF last_ig_curs%notfound THEN
    CLOSE last_ig_curs;
    p_error_num := 1;
    p_error_code := 'NO TRANSACTION FOUND';
    RETURN;
  END IF;
  CLOSE last_ig_curs;
  --
  p_recordcode := last_ig_rec.returnCode;
  p_timediff   := last_ig_rec.timediff; --CR53201
  get_ret_msg(p_esn,p_carrier, p_retmsg_lang, p_retmsg); --CR49064
  IF (last_ig_rec.status_message LIKE '%isLostorStolen=Y%') THEN
    p_islostorstolen := 'Y';
  ELSIF (last_ig_rec.status_message LIKE '%isLostorStolen=N%') THEN
    p_islostorstolen := 'N';
  ELSE
    p_islostorstolen := NULL;
  END IF;
  DBMS_OUTPUT.put_line ('islostorstolen flag:' || p_islostorstolen);
  IF last_ig_rec.status IN ('CP','L', 'Q') THEN
    p_error_num  := 4;
    p_error_code := 'PENDING';
    RETURN;
  ELSIF last_ig_rec.status IN ('FF','F','E') THEN --CR 24472
    IF upper(last_ig_rec.status_message) LIKE '%DISCOUNT_1%'  -- CR 37906
         AND p_bus_org = 'TOTAL_WIRELESS' -- CR40663
    THEN
      p_error_code := 'ESN UNDER CONTRACT';
      p_error_num  := 6;
      RETURN;
    END IF;
    p_error_num  := 3;
    p_error_code := 'NOT ELIGIBLE';
    RETURN;
  ELSIF last_ig_rec.status IN ('SS','S','W') and last_ig_rec.template = 'SPRINT' THEN
    p_error_num := 2;
    IF UPPER(last_ig_rec.status_message) LIKE '%ESN_IN_USE%' THEN
      p_error_code := 'ELIGIBLE ACTIVE';
    ELSE
      p_error_code := 'ELIGIBLE INACTIVE';
    END IF;
    p_carrier      := 'SPRINT';
    p_technology   := 'CDMA';
    p_phone_model  := last_ig_rec.s_phone_model;
    p_phone_gen    := last_ig_rec.s_phone_gen;
    p_sim_reqd     := last_ig_rec.s_sim_reqd;
    p_original_sim := last_ig_rec.s_iccid;
    RETURN;
  -- Added logic by Juda Pena to block 4G LTE BYOP for Total Wireless (CR39921)
  /*ELSIF last_ig_rec.status IN ('SS','S','W') AND
    p_bus_org = 'TOTAL_WIRELESS' AND
    UPPER(last_ig_rec.x_pool_name) LIKE '%4G%'
    THEN
    p_error_num := 3;
    p_error_code := 'NOT ELIGIBLE';
    p_carrier := 'VERIZON';
    p_technology := 'CDMA';
    p_phone_model := last_ig_rec.v_phone_model;
    p_phone_gen := last_ig_rec.v_phone_gen;
    p_sim_reqd := last_ig_rec.v_sim_reqd;
    RETURN;*/   -- Suresh commented the above block TW Plus
  -- End logic by Juda Pena to block 4G LTE BYOP for Total Wireless (CR39921)
  ELSIF last_ig_rec.status IN ('SS','S','W') THEN
    p_error_num   := 2;
    p_error_code  := 'ELIGIBLE';
    p_carrier     := 'VERIZON';
    p_technology  := 'CDMA';
    p_phone_model := last_ig_rec.v_phone_model;
    p_phone_gen   := last_ig_rec.v_phone_gen;
  --CR52545 Modify BYOP registration Service to assign HD part class for Verizon VOLTE, mdave, 07/26/2017
  IF last_ig_rec.v_phone_gen = 'LTE' THEN
    IF UPPER(last_ig_rec.status_message) LIKE UPPER('%HDVoice=Y%') THEN
      p_phone_gen := 'LTE_HD';
    ELSE
      p_phone_gen := 'LTE';
    END IF;

  END IF;
  --END CR52545 Modify BYOP registration Service to assign HD part class for Verizon VOLTE, mdave, 07/26/2017
    p_sim_reqd := last_ig_rec.v_sim_reqd;
    RETURN;
  --
  ELSIF p_islostorstolen_flag = 'Y' AND last_ig_rec.status IN ('HW') AND p_carrier = 'VERIZON' THEN
    p_error_num  := 3;
    p_error_code := 'NOT ELIGIBLE';
    RETURN;
  ELSE
    p_error_num := 5;
    p_error_code := 'INVALID STATUS';
    RETURN;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  p_error_num  := 99;
  p_error_code := SQLERRM;
END last_vd_ig_trans;
PROCEDURE st_last_vd_ig_trans(p_esn        IN     VARCHAR2,
                              p_carrier    IN OUT VARCHAR2,
                              p_zipcode    IN     VARCHAR2,
                              p_error_num  OUT    NUMBER,
                              p_error_code OUT    VARCHAR2)
IS
 CURSOR last_ig_curs(c_template IN VARCHAR2)
 IS
   SELECT
   /*+ USE_INVISIBLE_INDEXES */
   ig.status,
   ig.x_pool_name,
   ig.zip_code,
   (SELECT bo.org_id
   FROM table_part_inst pi,
   table_mod_level ml,
   table_part_num pn,
   table_bus_org bo
   WHERE 1 =1
   AND pi.part_serial_no = ig.esn
   AND ml.objid          = pi.n_part_inst2part_mod
   AND pn.objid          = ml.part_info2part_num
   AND bo.objid          = pn.part_num2bus_org
   ) org_id
   FROM gw1.ig_transaction ig
   WHERE ig.esn        = p_esn
   AND ig.order_type   = 'VD'
   AND ig.template =   c_template
   AND NVL(ig.zip_code,'X')=NVL(p_zipcode,'X')
   AND ig.template =DECODE(p_carrier,'VERIZON','RSS',null,ig.template,p_carrier)
   ORDER BY ig.transaction_id DESC;

 last_ig_rec last_ig_curs%rowtype;
 last_ig_rec2 last_ig_curs%rowtype;

 -- instantiate initial values
 rc sa.customer_type := customer_type ( i_esn => p_esn );

 -- type to hold retrieved attributes
 cst sa.customer_type;

BEGIN
 OPEN last_ig_curs('RSS');
 FETCH last_ig_curs INTO last_ig_rec;
 IF last_ig_curs%notfound THEN
  CLOSE last_ig_curs;
  p_error_num := 1;
  p_error_code := 'NO TRANSACTION FOUND';
  RETURN;
 END IF;
 CLOSE last_ig_curs;

 -- Added logic by Juda Pena to block 4G LTE BYOP for Total Wireless

 IF last_ig_rec.org_id = 'TOTAL_WIRELESS' AND
 last_ig_rec.status IN ('SS','S','W') AND
 last_ig_rec.x_pool_name = '4G'
 THEN
 --
  p_error_num := 3;
  p_error_code := 'NOT ELIGIBLE';
  --
  RETURN;

 -- End logic by Juda Pena to block 4G LTE BYOP for Total Wireless

 ELSIF last_ig_rec.org_id = 'TOTAL_WIRELESS' AND last_ig_rec.status IN ('SS','S','W') AND last_ig_rec.x_pool_name = '4G' THEN
 --- Error code changed to Eligible as part of Verizon 4g LTE handsets project CR 37906, changed the error code to 2 from 3.
  p_error_num  := 2;
  p_error_code := 'ELIGIBLE';
  -- Added this line as part of returning carrier for the 4G lte TW/VZ project
  p_carrier    := 'VERIZON';

  RETURN;
 ELSIF last_ig_rec.status IN ('SS','S','W') THEN
  p_error_num   := 2;
  p_error_code  := 'ELIGIBLE';
  p_carrier     := 'VERIZON';

  RETURN;
 ELSIF last_ig_rec.status IN ('FF','F','E') THEN --CR 24472
  p_error_num := 3;
  p_error_code := 'NOT ELIGIBLE';

  RETURN;
 ELSIF last_ig_rec.status IN ('CP','L', 'Q') THEN
  p_error_num := 4;
  p_error_code := 'PENDING';
 RETURN;
 ELSE
  p_error_num := 5;
  p_error_code := 'INVALID STATUS';
  RETURN;
 END IF;
 p_error_num := 0;
EXCEPTION
 WHEN OTHERS THEN
  p_error_num := 99;
  p_error_code := SQLERRM;
END st_last_vd_ig_trans;
PROCEDURE insert_vd_ig_trans(p_esn        IN  VARCHAR2,
                             p_carrier    IN  VARCHAR2,
                             p_zipcode    IN  VARCHAR2,
                             p_error_num  OUT NUMBER,
                             p_error_code OUT VARCHAR2)
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

 INSERT
 INTO gw1.ig_transaction
 (
  action_item_id,
  esn,
  esn_hex,
  order_type,
  template,
  account_num,
  status,
  TRANSACTION_ID,
-- carrier_id,
  zip_code
 )
 VALUES
 (
  sa.sequ_action_item_id.NEXTVAL,
  p_esn,
  sa.MEIDDECTOHEX(p_esn),
  'VD',
  'SPRINT',
  '1161',
  'Q',
  (gw1.trans_id_seq.nextval + (POWER(2 ,28))),
-- p_carrier,
  p_zipcode
 );
 COMMIT;
 p_error_num := 0;
EXCEPTION
WHEN OTHERS THEN
 ROLLBACK;
  p_error_num := 99;
  p_error_code := SQLERRM;
END insert_vd_ig_trans;
PROCEDURE st_insert_vd_ig_trans(p_esn        IN  VARCHAR2,
                                p_carrier    IN  VARCHAR2, --new parameter
                                p_zipcode    IN  VARCHAR2,--new parameter but not used
                                p_error_num  OUT NUMBER,
                                p_error_code OUT VARCHAR2)
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT
  INTO gw1.ig_transaction
  (
  action_item_id,
  esn,
  esn_hex,
  order_type,
  template,
  account_num,
  status,
  TRANSACTION_ID,
  --carrier_id,
  zip_code
  )
  VALUES
  (
  sa.sequ_action_item_id.NEXTVAL,
  p_esn,
  sa.MEIDDECTOHEX(p_esn),
  'VD',
  'RSS',
  '1161',
  'Q',
  (gw1.trans_id_seq.nextval + (POWER(2 ,28))),
  --p_carrier,
  p_zipcode
  );
  COMMIT;
 p_error_num := 0;
EXCEPTION
 WHEN OTHERS THEN
 ROLLBACK;
 p_error_num := 99;
 p_error_code := SQLERRM;
END st_insert_vd_ig_trans;
PROCEDURE last_vd_ig_trans_tas_remove( p_esn           IN  VARCHAR2,
                                       p_bus_org       IN  VARCHAR2,
                                       p_zipcode       IN  VARCHAR2,     --new parameter added
                                       p_phone_gen     OUT VARCHAR2,
                                       p_phone_model   OUT VARCHAR2,
                                       p_technology    OUT VARCHAR2,
                                       p_sim_reqd      OUT VARCHAR2,
                                       p_original_sim  OUT VARCHAR2,
                                       p_carrier       IN OUT VARCHAR2, --p_carrier modified as IN OUT
                                       p_islostorstolen OUT VARCHAR2,
                                       p_error_num     OUT NUMBER,
                                       p_error_code    OUT VARCHAR2)
IS
  CURSOR last_ig_curs(c_template IN VARCHAR2)
  IS
    SELECT
      /*+ USE_INVISIBLE_INDEXES */
      --      status,
      --      status_message
      *
    FROM gw1.ig_transaction ig
    WHERE esn      = p_esn
    AND order_type = 'VD'
    AND NVL(ig.zip_code,'X')=NVL(p_zipcode,'X')  --CR39192
    AND template = DECODE(p_carrier,'VERIZON','RSS',null,template,p_carrier) --CR39192
   -- AND template   = c_template
    ORDER BY ig.transaction_id DESC;
  last_ig_rec last_ig_curs%rowtype;
  last_ig_rec2 last_ig_curs%rowtype;
BEGIN
  IF p_bus_org != 'TRACFONE' THEN
   IF p_carrier ='VERIZON' THEN--carrier validation

     OPEN last_ig_curs('RSS');
     FETCH last_ig_curs INTO last_ig_rec;
     IF last_ig_curs%notfound THEN
       CLOSE last_ig_curs;
       p_error_num  := 1;
       p_error_code := 'NO TRANSACTION FOUND';
       RETURN;
     END IF  ;
     CLOSE last_ig_curs;
   ElSIF p_carrier ='SPRINT' THEN  --carrier validation
     OPEN last_ig_curs('SPRINT');
     FETCH last_ig_curs INTO last_ig_rec2;
     IF last_ig_curs%notfound THEN
       CLOSE last_ig_curs;
       p_error_num  := 2;
       p_error_code := 'NO TRANSACTION FOUND';
       RETURN;
     END IF;
     CLOSE last_ig_curs;
   ELSE
   --normal BAU flow
     OPEN last_ig_curs('RSS');
     FETCH last_ig_curs INTO last_ig_rec;
     IF last_ig_curs%notfound THEN
       CLOSE last_ig_curs;
       p_error_num  := 1;
       p_error_code := 'NO TRANSACTION FOUND';
       RETURN;
     END IF ;
     CLOSE last_ig_curs;
     OPEN last_ig_curs('SPRINT');
     FETCH last_ig_curs INTO last_ig_rec2;
     IF last_ig_curs%notfound THEN
       CLOSE last_ig_curs;
       p_error_num  := 2;
       p_error_code := 'NO TRANSACTION FOUND';
       RETURN;
     END IF;
     CLOSE last_ig_curs;
    --normal BAU flow
   END IF;
   if (last_ig_rec.status_message like '%isLostorStolen=Y%' or last_ig_rec2.status_message like '%isLostorStolen=Y%') then
      p_islostorstolen := 'Y';
      elsif (last_ig_rec.status_message like '%isLostorStolen=N%' or last_ig_rec2.status_message like '%isLostorStolen=N%') then
      p_islostorstolen := 'N';
      else
      p_islostorstolen := null;
      end if;
    DBMS_OUTPUT.put_line ('Islostorstolen Flag:' || p_islostorstolen);
    IF last_ig_rec.status IN ('CP','L', 'Q') OR last_ig_rec2.status IN ('CP','L', 'Q') THEN
      p_error_num  := 4;
      p_error_code := 'PENDING';
      RETURN;
    ELSIF last_ig_rec.status IN ('FF','F','E') AND last_ig_rec2.status IN ('FF','F','E') THEN --CR 24472
      p_error_num  := 3;
      p_error_code := 'NOT ELIGIBLE';
      RETURN;
    ELSIF last_ig_rec2.status IN ('SS','S','W') AND upper(last_ig_rec2.status_message) LIKE '%ESN_IN_USE%' THEN
      p_error_num  := 2;
      p_error_code := 'ELIGIBLE ACTIVE';
      p_carrier    := 'SPRINT';
      p_technology := 'CDMA';
      RETURN;
    ELSIF last_ig_rec.status IN ('SS','S','W') THEN
      p_error_num  := 2;
      p_error_code := 'ELIGIBLE';
      p_carrier    := 'VERIZON';
      p_technology := 'CDMA';
      --RETURN;
    ELSIF last_ig_rec2.status IN ('SS','S','W') AND upper(last_ig_rec2.status_message) NOT LIKE '%ESN_IN_USE%' THEN
      p_error_num  := 2;
      p_error_code := 'ELIGIBLE INACTIVE';
      p_carrier    := 'SPRINT';
      p_technology := 'CDMA';
      RETURN;
    ELSE
      p_error_num  := 5;
      p_error_code := 'INVALID STATUS';
      RETURN;
    END IF;
  ELSIF p_bus_org = 'TRACFONE' THEN
    OPEN last_ig_curs('RSS');
    FETCH last_ig_curs INTO last_ig_rec;
    IF last_ig_curs%notfound THEN
      CLOSE last_ig_curs;
      p_error_num  := 1;
      p_error_code := 'NO TRANSACTION FOUND';
      RETURN;
    END IF;
    CLOSE last_ig_curs;

   if (last_ig_rec.status_message like '%isLostorStolen=Y%') then
      p_islostorstolen := 'Y';
      elsif (last_ig_rec.status_message like '%isLostorStolen=N%') then
      p_islostorstolen := 'N';
      else
      p_islostorstolen := null;
      end if;
    DBMS_OUTPUT.put_line ('Islostorstolen Flag for bus_org tracfone:' || p_islostorstolen);

    IF last_ig_rec.status IN ('SS','S','W') THEN
      p_error_num  := 2;
      p_error_code := 'ELIGIBLE';
      p_carrier    := 'VERIZON';
      p_technology := 'CDMA';
      --RETURN;
    ELSIF last_ig_rec.status IN ('FF','F','E') THEN --CR 24472
      p_error_num  := 3;
      p_error_code := 'NOT ELIGIBLE';
      RETURN;
    ELSIF last_ig_rec.status IN ('CP','L', 'Q') THEN
      p_error_num  := 4;
      p_error_code := 'PENDING';
      RETURN;
    ELSE
      p_error_num  := 5;
      p_error_code := 'INVALID STATUS';
      RETURN;
    END IF;
    p_error_num := 0;
  ELSE
    NULL;
  END IF;
  ----
  IF p_carrier = 'VERIZON' THEN
    IF upper(last_ig_rec.x_mpn) LIKE '%APL%' THEN
      p_phone_model := 'IPHONE';
    ELSE
      p_phone_model := 'OTHER';
    END IF;
    ----
    IF upper(last_ig_rec.x_pool_name) LIKE '%4G%' THEN
       p_phone_gen := 'LTE';
     --CR52545 Modify BYOP registration Service to assign HD part class for Verizon VOLTE, mdave, 07/26/2017
      IF UPPER(last_ig_rec.status_message) LIKE UPPER('%HDVoice=Y%') THEN
        p_phone_gen := 'LTE_HD';
      END IF;
  -- END CR52545 Modify BYOP registration Service to assign HD part class for Verizon VOLTE, mdave, 07/26/2017
      p_sim_reqd  := 'YES';
    ELSE
      p_phone_gen := 'NON_LTE';
      p_sim_reqd  := 'NO';
    END IF;
  END IF;
  ----
  --p_error_num := 0;
EXCEPTION
WHEN OTHERS THEN
  p_error_num  := 99;
  p_error_code := SQLERRM;
END last_vd_ig_trans_tas_remove;
/******************CR39192 overloaded procedures added ***************************************/

PROCEDURE generate_attach_free_pin (in_esn               IN   table_part_inst.part_serial_no%TYPE,
                                    in_pin_part_num      IN   table_part_inst.part_serial_no%TYPE,
                                    in_inv_bin_objid     IN   table_inv_bin.objid%TYPE,
                                    in_reserve_status    IN   table_part_inst.x_part_inst_status%TYPE DEFAULT '400',
                                    out_soft_pin         OUT  table_x_cc_red_inv.x_red_card_number%TYPE,
                                    out_smp_number       OUT  table_x_cc_red_inv.x_smp%TYPE,
                                    out_err_num          OUT  NUMBER,
                                    out_err_msg          OUT  VARCHAR2)
IS

        o_next_value       NUMBER;
        o_format           VARCHAR2 (200);
        p_status           VARCHAR2 (200);
        p_msg              VARCHAR2 (200);
        v_proc_name        VARCHAR2 (80) := 'BYOP_SERVICE_PKG.GENERATE_ATTACH_FREE_PIN';
        c_inst_status      VARCHAR2 (200);  --CR51833 --new param in_reserve_status set to 400 as default//OImana

        CURSOR c_pin_part_num (p_pin_part_num   IN VARCHAR2)
        IS
            SELECT m.objid mod_level_objid,
                   bo.org_id,
                   pn.x_upc,
                   pn.part_number
              FROM table_part_num pn,
                   table_mod_level m,
                   table_bus_org bo
             WHERE 1 = 1
               AND pn.part_number = p_pin_part_num
               AND m.part_info2part_num = pn.objid
               AND bo.objid = pn.part_num2bus_org;

        pin_part_num_rec   c_pin_part_num%ROWTYPE;

        CURSOR c_get_esn
        IS
            SELECT pi_esn.part_serial_no esn,
                   pi_esn.objid pi_esn_objid,
                   pi_esn.part_inst2inv_bin,
                   ib.bin_name site_id
              FROM table_part_inst pi_esn, table_inv_bin ib
             WHERE 1 = 1 AND pi_esn.part_serial_no = in_esn AND ib.objid = pi_esn.part_inst2inv_bin;

        get_esn_rec        c_get_esn%ROWTYPE;

        CURSOR c_get_pin (p_next_value IN NUMBER)
        IS
            SELECT x_red_card_number, x_smp
              FROM table_x_cc_red_inv
             WHERE x_reserved_id = p_next_value;

        get_pin_rec        c_get_pin%ROWTYPE;

        CURSOR c_get_user
        IS
            SELECT objid
              FROM table_user
             WHERE s_login_name = USER;

        get_user_rec       c_get_user%ROWTYPE;


  PROCEDURE sp_reserve_app_card_byop (
     p_reserve_id         NUMBER,
     p_total              PLS_INTEGER,
     p_domain             VARCHAR2,
     p_status       OUT   VARCHAR2,
     p_msg          OUT   VARCHAR2
  )
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;
     CURSOR cards_curs
     IS
        SELECT /*+ INDEX_DESC( ccri X_CC_RED_INV_RSVD_FLAGINDX ) */
         ROWID, x_red_card_number
    FROM table_x_cc_red_inv ccri
         WHERE x_reserved_flag = 0
     AND x_domain = NVL (p_domain, 'REDEMPTION CARDS')
     AND ROWNUM < 201;

     hold_card_rec   cards_curs%ROWTYPE;
     cards_found     NUMBER               := 0;
     cards_missed    NUMBER               := 0;
     l_step          VARCHAR2 (20);
  BEGIN
     IF p_total <= 0 OR p_total IS NULL
     THEN
        DBMS_OUTPUT.put_line ('error p_total out of range:' || p_total);
        p_msg := 'No reserve card in the invertory.';
        p_status := 'N';
        RETURN;
     END IF;

     l_step := 'Step 1';

     FOR cards_rec IN cards_curs
     LOOP
        BEGIN
  ----------------------------------------------------------------------
     l_step := 'Step 2';

     SELECT     ROWID, x_red_card_number
           INTO hold_card_rec.ROWID, hold_card_rec.x_red_card_number
           FROM table_x_cc_red_inv
          WHERE x_reserved_flag = 0
      AND x_domain = NVL (p_domain, 'REDEMPTION CARDS')
      AND ROWID = cards_rec.ROWID
     FOR UPDATE NOWAIT;

     l_step := 'Step 3';

  ----------------------------------------------------------------------
     UPDATE table_x_cc_red_inv
        SET x_reserved_flag = 1,
      x_reserved_stmp = SYSDATE,
      x_reserved_id = p_reserve_id
      WHERE ROWID = cards_rec.ROWID;

     DBMS_OUTPUT.put_line (   'X_RED_CARD_NUMBER:'
               || cards_rec.x_red_card_number
              );
  ----------------------------------------------------------------------
     COMMIT;
  ----------------------------------------------------------------------
     cards_found := cards_found + 1;
     DBMS_OUTPUT.put_line ('cards_found:' || cards_found);
     l_step := 'Step 4';

     IF cards_found >= p_total
     THEN
        l_step := 'Step 5';
        p_msg := 'Completed';
        p_status := 'Y';
        RETURN;
     END IF;
        EXCEPTION
     WHEN OTHERS
     THEN
        cards_missed := cards_missed + 1;
        DBMS_OUTPUT.put_line ('skip and go to next card:' || cards_missed);
        toss_util_pkg.insert_error_tab_proc
                (   'Inner Loop exception failed at  '
                 || l_step,
                 p_reserve_id,
                 'SP_RESERVE_APP_CARD_BYOP'
                );
        COMMIT;
        END;
     END LOOP;

     UPDATE table_x_cc_red_inv
        SET x_reserved_flag = 0,
      x_reserved_stmp = NULL
      WHERE x_reserved_id = p_reserve_id;

     COMMIT;
     toss_util_pkg.insert_error_tab_proc
           ('No card could be reserved after 200 tries',
            p_reserve_id,
            'SP_RESERVE_APP_CARD_BYOP'
           );
     COMMIT;
     DBMS_OUTPUT.put_line (   'loop count:'
         || (cards_missed + cards_found)
         || ' without reserving all cards'
        );
     p_msg := 'No reserve card in the invertory.';
     p_status := 'N';
  END sp_reserve_app_card_byop;


    BEGIN

            OPEN c_get_user;
            FETCH c_get_user INTO get_user_rec;
            CLOSE c_get_user;

            OPEN c_get_esn;
            FETCH c_get_esn INTO get_esn_rec;

            IF c_get_esn%FOUND
            THEN
                OPEN c_pin_part_num (in_pin_part_num);
                FETCH c_pin_part_num INTO pin_part_num_rec;

                IF c_pin_part_num%FOUND
                THEN
                    next_id ('X_MERCH_REF_ID', o_next_value, o_format);
                    sp_reserve_app_card_byop (o_next_value,
                                         1,
                                         'REDEMPTION CARDS',
                                         p_status,
                                         p_msg);
                    IF p_msg = 'Completed'
                    THEN
                        OPEN c_get_pin (o_next_value);
                        FETCH c_get_pin INTO get_pin_rec;

                        IF c_get_pin%FOUND THEN

                            IF in_reserve_status IS NULL THEN
                              c_inst_status := '400';               --CR51833 - Value set to original '400' if param is null//OImana/100317
                            ELSE
                              c_inst_status := in_reserve_status;   --CR51833 - Value set from new param in_reserve_status//OImana/100317
                            END IF;

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
                                     VALUES (
                                                (seq ('part_inst')),
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                SYSDATE,
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                NULL,                         --WARR_END_DATE, CR42934 set value to NULL
                                                TO_DATE ('01/01/1753 00:00:00','mm/dd/yyyy hh24:mi:ss'),
                                                'Active',
                                                0,
                                                0,
                                                SYSDATE,
                                                SYSDATE,
                                                'REDEMPTION CARDS',
                                                0,
                                                0,
                                                get_pin_rec.x_red_card_number,
                                                get_pin_rec.x_smp,
                                                c_inst_status,                           --CR51833 - from new param in_reserve_status
                                                in_inv_bin_objid,
                                                get_user_rec.objid,
                                                (SELECT objid
                                                   FROM table_x_code_table
                                                  WHERE x_code_number = c_inst_status),  --CR51833 - from new param in_reserve_status
                                                pin_part_num_rec.mod_level_objid,
                                                get_esn_rec.pi_esn_objid,
                                                NVL (
                                                    (SELECT MAX (TO_NUMBER (x_ext) + 1)
                                                       FROM table_part_inst
                                                      WHERE part_to_esn2part_inst = get_esn_rec.pi_esn_objid
                                                        AND x_domain = 'REDEMPTION CARDS'),
                                                    1));

                            out_soft_pin     := get_pin_rec.x_red_card_number;
                            out_smp_number   := get_pin_rec.x_smp;

                            --COMMIT;
                        ELSE
                            CLOSE c_get_pin;

                            out_err_num      := 800;
                            out_err_msg      :='C_GET_PIN '||sa.get_code_fun ('WALMART_MONTHLY_PLANS_PKG',out_err_num,'ENGLISH');
                        END IF;

                        CLOSE c_get_pin;
                    ELSE
                        out_err_num      := 4;
                        out_err_msg      := v_proc_name||':'||p_status||':'||p_msg;
                    END IF;
                ELSE
                    out_err_num      := 800;
                    out_err_msg      :='C_PIN_PART_NUM '||sa.get_code_fun ('WALMART_MONTHLY_PLANS_PKG',out_err_num,'ENGLISH');

                    CLOSE c_pin_part_num;
                END IF;

                CLOSE c_pin_part_num;
            ELSE
                out_err_num      := 800;
                out_err_msg      :='C_GET_ESN '||sa.get_code_fun ('WALMART_MONTHLY_PLANS_PKG',out_err_num,'ENGLISH');

                CLOSE c_get_esn;
            END IF;

            CLOSE c_get_esn;
    EXCEPTION
        WHEN OTHERS
        THEN
            out_err_num      := SQLCODE;
            out_err_msg      := SUBSTR (SQLERRM, 1, 200);
            ota_util_pkg.err_log(p_action=> 'Main Excep: '||v_proc_name,
                                 p_error_date=> SYSDATE,
                                 p_key=> 'ESN: '||in_esn||' PIN_PART_NUM: '||in_pin_part_num,
                                 p_program_name=> v_proc_name,
                                 p_error_text=> SQLCODE||': '||SUBSTR (SQLERRM, 1, 200));
    END generate_attach_free_pin;
--
--CR51418 ALLOWING VZ DISCOUNT 1 for VZ
--To avoid impact of adding new OUT parameter
PROCEDURE last_vd_ig_trans ( p_esn IN VARCHAR2,
                             p_bus_org      IN  VARCHAR2,
                             p_zipcode      IN  VARCHAR2,
                             p_phone_gen    OUT VARCHAR2, ------> LTE, NON_LTE
                             p_phone_model  OUT VARCHAR2, ------> APPL
                             p_technology   OUT VARCHAR2, ------> CDMA
                             p_sim_reqd     OUT VARCHAR2, ------> YES,NO
                             p_original_sim OUT VARCHAR2, ------> 1234567890756735
                             p_carrier      IN OUT VARCHAR2,
                             p_islostorstolen OUT VARCHAR2,
                             p_error_num    OUT NUMBER,
                             p_error_code   OUT  VARCHAR2)
IS
v_recordcode VARCHAR2(500) := '';
v_retmsg_lang  VARCHAR2(3) DEFAULT 'ENG'; --CR49064
v_retmsg       VARCHAR2(2000);  --CR49064
v_timediff     NUMBER; --CR53201
BEGIN
last_vd_ig_trans ( p_esn           ,
                   p_bus_org       ,
                   p_zipcode       ,
                   p_phone_gen     ,
                   p_phone_model   ,
                   p_technology    ,
                   p_sim_reqd      ,
                   p_original_sim  ,
                   p_carrier       ,
                   p_islostorstolen,
                   v_recordcode    ,
                   p_error_num     ,
           p_error_code    ,
           v_retmsg_lang   , --CR49064
           v_retmsg        , --CR49064
           v_timediff        --CR53201
           );
EXCEPTION
WHEN OTHERS THEN
    p_error_num  := 99;
    p_error_code := SQLERRM;
END last_vd_ig_trans;
-- Added as part of CR49064
PROCEDURE get_ret_msg ( p_esn          IN  VARCHAR2,
                        p_carrier      IN  VARCHAR2,
                        p_retmsg_lang  IN  VARCHAR2 DEFAULT 'ENG',
                        p_retmsg       OUT VARCHAR2
                      )
IS
BEGIN
  IF p_esn IS NOT NULL AND p_carrier IN ('VERIZON','SPRINT') THEN
    SELECT /*+ use_invisible_indexes */
       CASE p_retmsg_lang
            when  'ENG' then extractvalue(igr.xml_response, '/TRANSACTION/IG_RETMSG_ENG')
            when  'SPA' then extractvalue(igr.xml_response, '/TRANSACTION/IG_RETMSG_SPA')
            end
     INTO p_retmsg
     FROM gw1.ig_transaction ig ,
        gw1.ig_trans_carrier_response igr
     WHERE ig.esn            = p_esn
     AND ig.transaction_id = igr.transaction_id
     AND ig.order_type     = 'VD'
     AND ig.template       = DECODE(p_carrier,'VERIZON','RSS','SPRINT','SPRINT')
     AND ig.transaction_id = (SELECT MAX(ig1.transaction_id)
                                FROM gw1.ig_transaction ig1
                   WHERE ig1.ESN        = ig.esn
                   AND ig1.order_type = ig.order_type
                                     AND ig1.template   = ig.template
                  );
  END IF;
EXCEPTION WHEN OTHERS THEN
  p_retmsg := '';
END;
END BYOP_SERVICE_PKG;
/