CREATE OR REPLACE PACKAGE BODY sa."CLARIFY_CASE_PKG"
AS
 ---------------------------------------------------------------------------------------------
-- CR39592 Start PMistry 03/31/2016
 procedure copy_contact_info (
 op_old_contact_id in table_contact.objid%type,
 op_new_contact_id out table_contact.objid%type,
 op_err_code out varchar2,
 op_err_msg out varchar2) is

 cursor get_current_acctinfo (op_old_contact_id in table_contact.objid%type) is
 SELECT
 c.objid contact_objid,
 decode(c.first_name,c.x_cust_id,null,c.first_name) first_name,
 decode(c.last_name,c.x_cust_id,null,c.last_name) last_name,
 c.x_middle_initial,
 c.fax_number,
 decode(c.phone,c.x_cust_id,null,c.phone) phone,
 c.e_mail,
 decode(a.address,c.x_cust_id,null,a.address) address,
 decode(a.address_2,c.x_cust_id,null,a.address_2) address_2,
 a.city,
 a.state,
 a.zipcode,
 cai.x_dateofbirth,
 bo.org_id,
 nvl(c.dev,0) copy_counter
 from table_contact c,
 table_x_contact_add_info cai,
 table_contact_role cr,
 table_address a,
 table_site s,
 table_bus_org bo
 where 1=1
 and c.objid = op_old_contact_id
 and c.objid = cr.contact_role2contact
 And S.Objid = Cr.Contact_Role2site
 and cr.primary_site = 1
 and a.objid = s.cust_primaddr2address
 and c.objid = cai.add_info2contact (+)
 and cai.add_info2bus_org = bo.objid (+);

 get_current_acctinfo_rec get_current_acctinfo%rowtype;
 esn_count number;
 begin
 op_err_code := 0;
 op_err_msg := 'Contact duplicated, Successfully';
 /*---------------------------------------------------------------------*/
 /* get Contact info for the given ESN */
 /*---------------------------------------------------------------------*/
 open get_current_acctinfo(op_old_contact_id);
 fetch get_current_acctinfo into get_current_acctinfo_rec;
 if get_current_acctinfo%notfound
 then
 op_err_code := '-201';
 op_err_msg := 'ERROR-00201 SA.CLARIFY_CASE_PKG.COPY_CONTACT_INFO : Contact not found';
 close get_current_acctinfo;
 return; --Procedure stops here
 end if;
 close get_current_acctinfo;


 if get_current_acctinfo_rec.copy_counter>0 then
 contact_pkg.createcontact_prc(p_esn => null,
 p_first_name => get_current_acctinfo_rec.first_name ||' copy_'||to_char(get_current_acctinfo_rec.copy_counter+1),
 p_last_name => get_current_acctinfo_rec.last_name,
 p_middle_name => get_current_acctinfo_rec.x_middle_initial,
 p_phone => get_current_acctinfo_rec.phone,
 p_add1 => get_current_acctinfo_rec.address,
 p_add2 => get_current_acctinfo_rec.address_2,
 p_fax => get_current_acctinfo_rec.fax_number,
 p_city => get_current_acctinfo_rec.city,
 p_st => get_current_acctinfo_rec.state,
 p_zip => get_current_acctinfo_rec.zipcode,
 p_email => get_current_acctinfo_rec.e_mail,
 p_email_status => 0,
 p_roadside_status => 0,
 p_no_name_flag => null,
 p_no_phone_flag => null,
 p_no_address_flag => null,
 p_sourcesystem => 'TAS',
 p_brand_name => get_current_acctinfo_rec.org_id,
 p_do_not_email => 1,
 p_do_not_phone => 1,
 p_do_not_mail => 1,
 p_do_not_sms => 1,
 p_ssn => null,
 p_dob => get_current_acctinfo_rec.x_dateofbirth,
 p_do_not_mobile_ads => 1,
 p_contact_objid => op_new_contact_id,
 p_err_code => op_err_code,
 p_err_msg => op_err_msg);

 else
 -- Reuse Account Contact if it is the first ESN in the account
 op_new_contact_id:=get_current_acctinfo_rec.contact_objid;
 end if;

 update table_contact
 set dev = nvl(get_current_acctinfo_rec.copy_counter,0)+1
 where objid = get_current_acctinfo_rec.contact_objid;

 commit;

 -- DO NOT CALL UPDATE CR27859, AFTER THE CONTACT IS CREATED
 -- UPDATE MIRROR THE ADD INFO TABLE
 for i in (select *
 from table_x_contact_add_info
 where add_info2contact = op_old_contact_id)
 loop
 update table_x_contact_add_info
 set x_do_not_email = i.x_do_not_email,
 x_do_not_phone = i.x_do_not_phone,
 x_do_not_sms = i.x_do_not_sms,
 x_do_not_mail = i.x_do_not_mail
 where add_info2contact = op_new_contact_id;
 end loop;
 commit;

 EXCEPTION
 WHEN OTHERS THEN
 ROLLBACK;
 op_err_code := SQLCODE;
 op_err_msg := TRIM(SUBSTR('ERROR COPY_CONTACT_INFO : '||SQLERRM ||CHR(10) ||
 DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
 ,1,4000));
 RETURN;
 end copy_contact_info;
-- CR39592 End.

PROCEDURE create_case(
 p_title IN VARCHAR2 ,
 p_case_type IN VARCHAR2 ,
 p_status IN VARCHAR2 ,
 p_priority IN VARCHAR2 ,
 p_issue IN VARCHAR2 ,
 p_source IN VARCHAR2 ,
 p_point_contact IN VARCHAR2 ,
 p_creation_time IN DATE ,
 p_task_objid IN NUMBER ,
 p_contact_objid IN NUMBER ,
 p_user_objid IN NUMBER ,
 p_esn IN VARCHAR2 ,
 p_phone_num IN VARCHAR2 ,
 p_first_name IN VARCHAR2 ,
 p_last_name IN VARCHAR2 ,
 p_e_mail IN VARCHAR2 ,
 p_delivery_type IN VARCHAR2 ,
 p_address IN VARCHAR2 ,
 p_city IN VARCHAR2 ,
 p_state IN VARCHAR2 ,
 p_zipcode IN VARCHAR2 ,
 p_repl_units IN NUMBER ,
 p_fraud_objid IN NUMBER ,
 p_case_detail IN VARCHAR2 ,
 p_part_request IN VARCHAR2 ,
 p_id_number OUT VARCHAR2 ,
 p_case_objid OUT NUMBER ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2 )
IS
 CURSOR line_reserved_cur(esn VARCHAR2)
 IS
 SELECT *
 FROM table_part_inst
 WHERE part_to_esn2part_inst IN
 (SELECT objid
 FROM table_part_inst
 WHERE part_serial_no = esn
 AND x_domain = 'PHONES'
 )
 AND x_domain = 'LINES'
 AND x_part_inst_status IN ('37' ,'39');
 line_reserved_rec line_reserved_cur%ROWTYPE;
 CURSOR sim_inv_cur(iccid VARCHAR2)
 IS
 SELECT x_sim_inv_status FROM table_x_sim_inv WHERE x_sim_serial_no = iccid;
 sim_inv_rec sim_inv_cur%ROWTYPE;
 CURSOR carrier_cur(ip_id VARCHAR2)
 IS
 SELECT x_mkt_submkt_name FROM table_x_carrier WHERE x_carrier_id = ip_id;
 carrier_rec carrier_cur%ROWTYPE;
 CURSOR instruc_curs ( esn VARCHAR2 ,code VARCHAR2 )
 IS
 SELECT *
 FROM x_special_instructions_list
 WHERE x_esn = esn
 AND x_instruc_code = code
 AND x_process_date IS NULL;
 instruc_rec instruc_curs%ROWTYPE;
 CURSOR domain_curs(part_num VARCHAR2)
 IS
 SELECT domain FROM table_part_num WHERE part_number = part_num;
 domain_rec domain_curs%ROWTYPE;
 CURSOR ff_center_curs(case_status VARCHAR2)
 IS
 SELECT x_ff_code
 FROM table_x_ff_center
 WHERE x_status_exception = case_status
 ORDER BY x_ranking ASC;
 ff_center_rec ff_center_curs%ROWTYPE;
 CURSOR address_curs
 IS
 SELECT cust_primaddr2address address_objid ,
 table_site.objid site_objid
 FROM table_site ,
 table_contact_role
 WHERE contact_role2site = table_site.objid
 AND contact_role2contact = p_contact_objid
 AND primary_site = 1;
 address_rec address_curs%ROWTYPE;
 CURSOR priority_curs
 IS
 SELECT elm.objid
 FROM table_gbst_elm elm ,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Response Priority Code'
 AND elm.title = p_priority;
 priority_rec priority_curs%ROWTYPE;
 CURSOR priority_curs2
 IS
 SELECT elm.objid
 FROM table_gbst_elm elm ,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Response Priority Code'
 AND elm.state = 2;
 CURSOR severity_curs
 IS
 SELECT elm.objid
 FROM table_gbst_elm elm ,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Problem Severity Level'
 AND elm.state = 2;
 severity_rec severity_curs%ROWTYPE;
 CURSOR call_type_curs
 IS
 SELECT elm.objid
 FROM table_gbst_elm elm ,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Case Type'
 AND elm.state = 2;
 call_type_rec call_type_curs%ROWTYPE;
 priority_rec2 priority_curs2%ROWTYPE;
 CURSOR status_curs
 IS
 SELECT elm.objid ,
 elm.title
 FROM table_gbst_elm elm ,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Open'
 AND elm.title = p_status;
 status_rec status_curs%ROWTYPE;
 CURSOR status_curs2
 IS
 SELECT elm.objid ,
 elm.title
 FROM table_gbst_elm elm ,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Open'
 AND elm.state = 2;
 status_rec2 status_curs2%ROWTYPE;
 CURSOR act_entry_gbst_curs
 IS
 SELECT elm.objid ,
 lst.title
 FROM table_gbst_elm elm ,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Activity Name'
 AND elm.title LIKE 'Create';
 act_entry_gbst_rec act_entry_gbst_curs%ROWTYPE;
 CURSOR wipbin_curs
 IS
 SELECT objid FROM sa.table_wipbin WHERE wipbin_owner2user = p_user_objid;
 wipbin_rec wipbin_curs%ROWTYPE;
 -- BRAND_SEP
 CURSOR active_esn_curs
 IS
 SELECT sp.objid ,
 sp.x_service_id x_esn ,
 sp.x_min ,
 sp.x_msid ,
 sp.x_iccid ,
 car.x_carrier_id ,
 car.x_mkt_submkt_name ,
 pn.part_number ,
 pn.description ,
 bo.org_id ,
 s.name ,
 sp.x_zipcode ,
 pi_esn.warr_end_date
 FROM table_site s ,
 table_inv_bin ib ,
 table_part_num pn ,
 table_mod_level ml ,
 table_part_inst pi_esn ,
 table_x_carrier car ,
 table_part_inst pi_min ,
 table_site_part sp ,
 table_bus_org bo
 WHERE 1 = 1
 AND s.site_id = ib.bin_name
 AND ib.objid = pi_esn.part_inst2inv_bin
 AND pn.objid = ml.part_info2part_num
 AND ml.objid = pi_esn.n_part_inst2part_mod
 AND pi_esn.part_serial_no = p_esn
 AND car.objid = pi_min.part_inst2carrier_mkt
 AND pi_min.part_serial_no = sp.x_min
 AND sp.x_service_id = p_esn
 AND sp.part_status IN ('Active' ,'CarrierPending')
 AND bo.objid = pn.part_num2bus_org;
 active_esn_rec active_esn_curs%ROWTYPE;
 -- BRAND_SEP
 --CR45525 start neg 1/19/2017
 cursor inactive_esn_cur is
 select x_service_id x_esn, x_min, x_zipcode,x_iccid
 from table_site_part
 where x_service_id = p_esn
 and part_status in ('Inactive','Obsolete')
 order by install_date desc;

inactive_esn_rec inactive_esn_cur%rowtype;
 --CR45525 end
 --
 CURSOR model_curs
 IS
 SELECT pi_esn.part_serial_no x_esn ,
 pn.part_number ,
 pn.description ,
 s.name ,
 pi_esn.x_part_inst2contact ,
 pi_esn.x_hex_serial_no ,
 bo.org_id -- CR19490 Start kacosta 04/30/2012
 ,
 NVL(pi_esn.part_bad_qty ,0) + 1 exchange_counter -- CR19490 End kacosta 04/30/2012
 ,
 bo.org_flow -- CR20451 | CR20854: Add TELCEL Brand
 FROM table_site s ,
 table_inv_bin ib ,
 table_part_num pn ,
 table_mod_level ml ,
 table_part_inst pi_esn ,
 table_bus_org bo
 WHERE 1 = 1
 AND s.site_id = ib.bin_name
 AND ib.objid = pi_esn.part_inst2inv_bin
 AND pn.objid = ml.part_info2part_num
 AND ml.objid = pi_esn.n_part_inst2part_mod
 AND pi_esn.part_serial_no = p_esn
 AND bo.objid = pn.part_num2bus_org;
 model_rec model_curs%ROWTYPE;
 CURSOR warehouse_curs ( case_type VARCHAR2 ,case_title VARCHAR2 )
 IS
 SELECT x_warehouse ,
 x_instruct_type ,
 x_instruct_code
 -- CR19490 Start kacosta 04/30/2012
 ,
 NVL(x_required_return ,0) x_required_return
 -- CR19490 End kacosta 04/30/2012
 , x_repl_logic -- CR39592 PMistry 03/24/2016
 FROM table_x_case_conf_hdr
 WHERE table_x_case_conf_hdr.x_case_type = case_type
 AND table_x_case_conf_hdr.x_title = case_title
 AND x_warehouse = 1;
 warehouse_rec warehouse_curs%ROWTYPE;
 CURSOR group2esn_curs
 IS
 SELECT grp.*
 FROM table_x_group2esn grp ,
 table_part_inst pi
 WHERE grp.groupesn2part_inst = pi.objid
 -- CR16379 Start kacosta 03/12/2012
 AND SYSDATE BETWEEN NVL(grp.x_start_date ,SYSDATE) AND NVL(grp.x_end_date ,SYSDATE)
 -- CR16379 End kacosta 03/12/2012
 AND pi.part_serial_no = p_esn;
 -- BRAND_SEP
 CURSOR ship_curs ( repl_part_num VARCHAR2 ,case_type VARCHAR2 ,case_title VARCHAR2 ,zip_code VARCHAR2 )
 IS
 SELECT x_shipping_cost ,
 x_ff_code ,
 x_shipping_method ,
 x_service_level ,
 x_courier_id ,
 domain ,
 x_ranking ,
 x_technology
 FROM table_x_shipping_method ,
 table_x_courier ,
 table_x_shipping_master ,
 table_x_case_conf_hdr ,
 table_x_mtm_ffc2conf_hdr ,
 table_x_ff_center ,
 mtm_part_num22_x_ff_center2 ,
 table_part_num
 WHERE 1 = 1
 AND table_x_shipping_method.objid = table_x_shipping_master.master2method + 0
 AND table_x_courier.objid = table_x_shipping_master.master2courier + 0
 AND table_x_shipping_master.x_service_level <=
 (SELECT DISTINCT x_param_value
 FROM table_x_parameters
 WHERE x_param_name = 'SERVICE LEVEL'
 AND ROWNUM < 3000000000
 )
 AND table_x_shipping_master.x_weight = table_x_case_conf_hdr.x_weight
 AND table_x_shipping_master.x_zip_code = '99999' --zip_code
 AND table_x_shipping_master.master2ff_center = table_x_ff_center.objid
 AND table_x_case_conf_hdr.x_case_type
 || '' = case_type
 AND table_x_case_conf_hdr.x_title
 || '' = case_title
 AND table_x_case_conf_hdr.objid = table_x_mtm_ffc2conf_hdr.mtm_ffc2conf_hdr
 AND table_x_mtm_ffc2conf_hdr.mtm_ffc2ff_center = table_x_ff_center.objid
 AND table_x_ff_center.objid = mtm_part_num22_x_ff_center2.ff_center2part_num
 AND mtm_part_num22_x_ff_center2.part_num2ff_center = table_part_num.objid
 AND table_part_num.part_number = repl_part_num
 ORDER BY x_shipping_cost ,
 x_ranking ASC;
 ship_rec ship_curs%ROWTYPE;
 -- CR15363 Start KACOSTA 04/22/2011
 CURSOR get_x_case_conf_hdr_curs ( c_x_case_type table_x_case_conf_hdr.x_case_type%TYPE ,c_x_title table_x_case_conf_hdr.x_title%TYPE )
 IS
 SELECT cch.*
 FROM table_x_case_conf_hdr cch
 WHERE cch.x_case_type = c_x_case_type
 AND cch.x_title = c_x_title;
 --
 get_x_case_conf_hdr_rec get_x_case_conf_hdr_curs%ROWTYPE;
 -- CR19376
 CURSOR saf_esn_curs(c_esn table_site_part.x_service_id%TYPE)
 IS
 /*SELECT COUNT(*) exist
 FROM x_sl_currentvals
 WHERE x_current_esn = c_esn
 AND x_current_active = 'Y';*/
 --added for CR31107
 SELECT COUNT(*) exist
 FROM x_sl_HIST
 WHERE x_ESN = c_esn
 AND X_EVENT_DT >= TRUNC(SYSDATE)-90;
 ----END FOR CR31107
 saf_esn_rec saf_esn_curs%ROWTYPE;
 v_saf_esn NUMBER := 0; --CR19376
 -- CR15363 End KACOSTA 04/22/2011
 -- CR21111 Start NGUADA 09/18/2012
 CURSOR airbill_cur(old_esn_part_number VARCHAR2,
 c_action varchar2) -- CR39592 PMistry 03/24/2016 Added new cursor parameter.
 IS
 SELECT x_airbil_part_number
 FROM sa.table_x_class_exch_options ,
 sa.table_part_num
 WHERE part_num2part_class = source2part_class
 AND part_number = old_esn_part_number
 AND x_airbil_part_number IS NOT NULL
 AND (x_exch_type = DECODE(c_action, 'DEFECTIVE_PHONE', 'WAREHOUSE','GOODWILL', 'GOODWILL','UNLOCK','UNLOCK', 'TECHNOLOGY')
 OR x_exch_type = 'RETAILER' ) -- CR39592 03/08/2016 PMistry Added exchange type Unlock
 AND ROWNUM < 2;
 airbill_rec airbill_cur%ROWTYPE;
 -- CR21111 End NGUADA 09/18/2012
 new_case_objid NUMBER := seq('case');
 new_condition_objid NUMBER := seq('condition');
 new_act_entry_objid NUMBER := seq('act_entry');
 --
 l_case_detail VARCHAR2(5000) := p_case_detail;
 i PLS_INTEGER := 1;
TYPE case_detail_tab_type
IS
 TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
 case_detail_tab case_detail_tab_type;
 case_detail_tab2 case_detail_tab_type;
 clear_case_detail_tab case_detail_tab_type;
 --
 l_part_request VARCHAR2(5000) := p_part_request;
 i2 PLS_INTEGER := 1;
TYPE part_request_tab_type
IS
 TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
 part_request_tab part_request_tab_type;
 clear_part_request_tab part_request_tab_type;
 new_case_id NUMBER := NULL;
 new_case_id_format VARCHAR2(100) := NULL;
 ship_overwrite NUMBER := 0;
 warehouse_case BOOLEAN := FALSE;
 instruc_code VARCHAR2(5) := '';
 instruc_type NUMBER := 0;
 instruc_ffc VARCHAR2(30);
 instruc_cid VARCHAR2(10);
 instruc_sm VARCHAR2(30);
 nap_repl_part VARCHAR2(30);
 nap_repl_tech VARCHAR2(30);
 nap_sim_profile VARCHAR2(30);
 nap_part_serial_no VARCHAR2(30);
 nap_message VARCHAR2(200);
 nap_pref_parent VARCHAR2(30);
 nap_pref_carrid VARCHAR2(30);
 tmp_case_details VARCHAR2(1000);
 tmp_error_no VARCHAR2(100);
 tmp_error_str VARCHAR2(100);
 v_current_carrier_id VARCHAR2(20);
 v_assigned_carrier_id VARCHAR2(20);
 v_pr_status VARCHAR2(30);
 v_reserved_min VARCHAR2(30);
 --CR21111 Start NGUADA
 v_airbill_added BOOLEAN := FALSE;
 v_airbill_needed BOOLEAN := FALSE;
 v_airbill_part_num VARCHAR2(30);
 v_part_number VARCHAR2(50);
 case_detail_act_zipcode varchar2(10);

 --CR21111 End NGUADA
 --CDMA NAVAIL
 v_inv_result VARCHAR2(100);
 v_iccid varchar2(30); -- --CR45525 NEG 1/19/17
 v_subBrand VARCHAR2(30); -- CR 48664 - Go-Smart TAS cases misclassified as Simple Mobile
 v_errNo Number;
 v_errMsg VARCHAR2(100);
 v_special_promo NUMBER := 0; --NET10

BEGIN
 p_error_no := '0';
 P_ERROR_STR := 'SUCCESS';
 IF p_title = 'Lifeline Shipment' OR p_title = 'SafeLink BroadBand Shipment' --CR23889
 AND p_case_type = 'Warehouse' AND l_part_request IS NULL THEN
 sa.nap_digital(p_zipcode ,p_esn ,'N' ,'English' ,NULL ,'WEBCSR' ,'N' ,nap_repl_part ,nap_repl_tech ,nap_sim_profile ,nap_part_serial_no ,nap_message ,nap_pref_parent ,nap_pref_carrid); --CDMA NAVAIL
 IF nap_message = 'Replacement Part Found' THEN
 l_part_request := nap_repl_part;
 --Nap SIM Profile Ignored until other carriers enabled
 /*if nap_repl_tech='GSM' then
 -- l_part_request:=l_part_request||substr(nap_sim_profile,-1);
 end if;
 */
 END IF;
 END IF;
 OPEN address_curs;
 FETCH address_curs INTO address_rec;
 IF p_priority IS NOT NULL THEN
 OPEN priority_curs;
 FETCH priority_curs INTO priority_rec;
 IF priority_curs%NOTFOUND THEN
 OPEN priority_curs2;
 FETCH priority_curs2 INTO priority_rec;
 CLOSE priority_curs2;
 END IF;
 CLOSE priority_curs;
 ELSE
 OPEN priority_curs2;
 FETCH priority_curs2 INTO priority_rec;
 CLOSE priority_curs2;
 END IF;
 OPEN severity_curs;
 FETCH severity_curs INTO severity_rec;
 CLOSE severity_curs;
 OPEN call_type_curs;
 FETCH call_type_curs INTO call_type_rec;
 CLOSE call_type_curs;
 IF p_status IS NOT NULL THEN
 OPEN status_curs;
 FETCH status_curs INTO status_rec;
 IF status_curs%NOTFOUND THEN
 OPEN status_curs2;
 FETCH status_curs2 INTO status_rec;
 CLOSE status_curs2;
 END IF;
 CLOSE status_curs;
 ELSE
 OPEN status_curs2;
 FETCH status_curs2 INTO status_rec;
 CLOSE status_curs2;
 END IF;
 OPEN active_esn_curs;
 FETCH active_esn_curs INTO active_esn_rec;
 CLOSE active_esn_curs;

 --CR45525 start neg 1/19/2017
 OPEN inactive_esn_cur;
 FETCH inactive_esn_cur INTO inactive_esn_rec;
 CLOSE inactive_esn_cur;
 --CR45525 end neg 1/19/2017

 OPEN model_curs;
 FETCH model_curs INTO model_rec;
 IF model_curs%FOUND THEN
 IF model_rec.x_part_inst2contact IS NULL THEN
 UPDATE table_part_inst
 SET x_part_inst2contact = p_contact_objid
 WHERE part_serial_no = model_rec.x_esn;
 COMMIT;
 END IF;
 END IF;
 CLOSE model_curs;
 OPEN act_entry_gbst_curs;
 FETCH act_entry_gbst_curs INTO act_entry_gbst_rec;
 CLOSE act_entry_gbst_curs;
 OPEN wipbin_curs;
 FETCH wipbin_curs INTO wipbin_rec;
 CLOSE wipbin_curs;
 next_id('Case ID' ,new_case_id ,new_case_id_format);
 dbms_output.put_line('case id:' || new_case_id);
 p_id_number := new_case_id;
 dbms_output.put_line('P_ID_NUMBER:' || p_id_number);
 INSERT
 INTO sa.table_condition
 (
 objid ,
 condition ,
 title ,
 s_title ,
 wipbin_time ,
 sequence_num
 )
 VALUES
 (
 new_condition_objid ,
 2 ,
 'Open' ,
 'OPEN' ,
 SYSDATE ,
 0
 );
 INSERT
 INTO sa.table_act_entry
 (
 objid ,
 act_code ,
 entry_time ,
 addnl_info ,
 act_entry2case ,
 act_entry2user ,
 entry_name2gbst_elm
 )
 VALUES
 (
 new_act_entry_objid ,
 600 ,
 SYSDATE ,
 ' Contact = '
 || p_first_name
 || ' '
 || p_last_name ,
 new_case_objid ,
 p_user_objid ,
 act_entry_gbst_rec.objid
 );
 -- try to find reserved min if any for ST Defective Phone
 IF active_esn_rec.x_min IS NULL AND p_title = 'ST Defective Phone' THEN
 OPEN line_reserved_cur(model_rec.x_esn);
 FETCH line_reserved_cur INTO line_reserved_rec;
 CLOSE line_reserved_cur;
 v_reserved_min := line_reserved_rec.part_serial_no;
 END IF;
 -- CR19376
 OPEN saf_esn_curs(p_esn);
 FETCH saf_esn_curs INTO saf_esn_rec;
 CLOSE saf_esn_curs;
 v_saf_esn := saf_esn_rec.exist;

 --CR48530 Updating code to populate sub brand

 IF model_rec.org_id is not null and model_rec.org_id = 'SIMPLE_MOBILE' THEN
 PHONE_PKG.GET_SUB_BRAND(i_esn => model_rec.x_esn,o_sub_brand => v_subBrand,o_errnum =>v_errNo ,o_errstr => v_errMsg);
 IF v_subBrand IS NULL THEN
 v_subBrand := model_rec.org_id;
 END IF;
 ELSE
 -- following decode statement from query changed to case to populate sub brand.
-- DECODE(p_title ,'Lifeline Shipment' ,'LIFELINE' ,'Business Sales Direct Shipment' ,'B2B-DIRECT' ,'Business Sales Service Shipment' ,'B2B-SERVICES' ,'SafeLink BroadBand Shipment' --CR23889
-- ,'SL-BROADBAND' --CR23889
-- ,DECODE(v_saf_esn ,0 ,model_rec.org_id ,'SAFELINK')) , --CR19376
 CASE p_title
 WHEN 'Lifeline Shipment' THEN
 v_subBrand := 'LIFELINE';
 WHEN 'Business Sales Direct Shipment' THEN
 v_subBrand := 'B2B-DIRECT';
 WHEN 'Business Sales Service Shipment' THEN
 v_subBrand := 'B2B-SERVICES';
 WHEN 'SafeLink BroadBand Shipment' THEN
 v_subBrand := 'SL-BROADBAND';
 ELSE
 IF v_saf_esn = 0 THEN
 v_subBrand := model_rec.org_id;
 ELSE
 v_subBrand := 'SAFELINK';
 END IF;
 END CASE;
 END IF;


 -- inserting rec to table_case
INSERT
INTO table_case
 (
 objid ,
 title ,
 s_title ,
 id_number ,
 x_case_type ,
 respprty2gbst_elm ,
 casests2gbst_elm ,
 case_type_lvl1 ,
 case_type_lvl2 ,
 case_type_lvl3 ,
 customer_code ,
 creation_time ,
 x_case2task ,
 case_reporter2contact ,
 case_owner2user ,
 case_originator2user ,
 x_esn ,
 x_min ,
 x_msid ,
 x_iccid ,
 x_carrier_id ,
 x_text_car_id ,
 x_carrier_name ,
 x_model ,
 x_phone_model ,
 x_retailer_name ,
 x_activation_zip ,
 alt_phone ,
 alt_first_name ,
 alt_last_name ,
 alt_e_mail ,
 alt_site_name ,
 alt_address ,
 alt_city ,
 alt_state ,
 alt_zipcode ,
 x_replacement_units ,
 case_state2condition ,
 case_wip2wipbin ,
 respsvrty2gbst_elm ,
 cure_code ,
 calltype2gbst_elm ,
 case2address ,
 case_reporter2site ,
 is_supercase
 )
 VALUES
 (
 new_case_objid ,
 SUBSTR(p_title ,1 ,80) ,
 SUBSTR(UPPER(p_title) ,1 ,80) ,
 new_case_id ,
 SUBSTR(p_case_type ,1 ,30) ,
 priority_rec.objid ,
 status_rec.objid ,
 SUBSTR(p_issue ,1 ,255), --CR22404
 v_subBrand,--CR48530
 SUBSTR(p_source ,1 ,30) ,
 SUBSTR(p_point_contact ,1 ,20) ,
 SYSDATE ,
 p_task_objid ,
 p_contact_objid ,
 p_user_objid ,
 p_user_objid ,
 DECODE(model_rec.x_esn ,'TFSHIPLL_DUMMY_ESN' ,'TFSHIPLL_'
 || new_case_id ,model_rec.x_esn) ,
 NVL(active_esn_rec.x_min ,v_reserved_min) ,
 active_esn_rec.x_msid ,
 active_esn_rec.x_iccid ,
 active_esn_rec.x_carrier_id ,
 TO_CHAR(active_esn_rec.x_carrier_id) ,
 SUBSTR(active_esn_rec.x_mkt_submkt_name ,1 ,30) ,
 SUBSTR(model_rec.part_number ,1 ,20) ,
 SUBSTR(model_rec.description ,1 ,30) ,
 SUBSTR(model_rec.name ,1 ,80) ,
 active_esn_rec.x_zipcode ,
 p_phone_num ,
 p_first_name ,
 p_last_name ,
 p_e_mail ,
 p_delivery_type ,
 p_address ,
 p_city ,
 p_state ,
 p_zipcode ,
 p_repl_units ,
 new_condition_objid ,
 wipbin_rec.objid ,
 severity_rec.objid ,
 null, --asim active_esn_rec.warr_end_date ,
 call_type_rec.objid ,
 NVL(address_rec.address_objid ,0) ,
 NVL(address_rec.site_objid ,0) ,
 DECODE(NVL(p_fraud_objid ,0) ,0 ,0 ,1)
 );

--NET10 prmotion start
IF SUBSTR(p_case_type ,1 ,30) = 'Special Programs'
THEN --{
BEGIN --{
 WITH PARAM AS
 (
 SELECT X_PARAM_VALUE str
 FROM table_x_parameters
 WHERE X_PARAM_NAME ='SPECIAL_PROGRAMS'
 )
 SELECT COUNT(1)
 INTO v_special_promo
 FROM table_case,
 (
 SELECT trim(regexp_substr(str, '[^,]+', 1, LEVEL)) str
 FROM PARAM
 CONNECT BY regexp_substr(str , '[^,]+', 1, LEVEL) IS NOT NULL
 )
 WHERE x_esn = model_rec.x_esn
 AND x_case_type = 'Special Programs'
 AND title = 'Enrollments'
 AND UPPER(case_type_lvl1)= str
 AND ROWNUM <= 1
 AND NOT EXISTS (
 SELECT 1
 FROM x_policy_rule_subscriber
 WHERE esn = model_rec.x_esn
 );
EXCEPTION
WHEN OTHERS THEN
 v_special_promo := 0;
END; --}

IF v_special_promo = 1
THEN --{

BEGIN --{
 INSERT INTO x_policy_rule_subscriber
 (
 OBJID,
 MIN,
 ESN,
 COS,
 START_DATE,
 END_DATE,
 INSERT_TIMESTAMP,
 UPDATE_TIMESTAMP,
 INACTIVE_FLAG
 )
 VALUES
 (
 sequ_policy_rule_subscriber.NEXTVAL,
 NVL(active_esn_rec.x_min ,v_reserved_min),
 model_rec.x_esn,
 NULL,
 TRUNC(SYSDATE),
 '31-DEC-2055',
 SYSDATE,
 SYSDATE,
 'N'
 );
EXCEPTION
WHEN OTHERS THEN
 NULL;
END; --}

END IF; --}
END IF; --}
--NET10 prmotion end

 -- Case Promotions
 FOR group2esn_rec IN group2esn_curs
 LOOP
 INSERT
 INTO table_x_case_promotions
 (
 objid ,
 x_start_date ,
 x_end_date ,
 x_annual_plan ,
 case_promo2promotion ,
 case_promo2promo_grp ,
 case_promo2case
 )
 VALUES
 (
 sa.seq('x_case_promotions') ,
 group2esn_rec.x_start_date ,
 group2esn_rec.x_end_date ,
 group2esn_rec.x_annual_plan ,
 group2esn_rec.groupesn2x_promotion ,
 group2esn_rec.groupesn2x_promo_group ,
 new_case_objid
 );
 END LOOP;
 -- START ST BUNDLE 3
 -- CR15570 Start KACOSTA 05/12/2011
 --if active_esn_rec.objid is not null and p_title = 'ST Defective Phone' then
 -- if l_case_detail is not null and substr(l_case_detail,-2) <> '||' then
 -- l_case_detail:=l_case_detail||'||';
 -- end if;
 -- l_case_detail:=l_case_detail||'ACTIVE_SITE_PART||'||active_esn_rec.objid||'||ACTIVE_ESN||'||active_esn_rec.x_esn||'||DUE_DATE||'||to_char(active_esn_rec.warr_end_date,'mm/dd/yyyy');
 --end if;
 IF active_esn_rec.objid IS NOT NULL
 -- CR20451 | CR20854: Add TELCEL Brand
 -- AND model_rec.org_id = 'STRAIGHT_TALK'
 AND model_rec.org_flow = '3' AND p_case_type = 'Warranty' THEN
 --
 IF l_case_detail IS NOT NULL THEN
 --
 l_case_detail := 'ACTIVE_SITE_PART||' || active_esn_rec.objid || '||ACTIVE_ESN||' || active_esn_rec.x_esn || '||DUE_DATE||' || TO_CHAR(active_esn_rec.warr_end_date ,'MM/DD/YYYY') || '||' || l_case_detail;
 --
 ELSE
 --
 l_case_detail := 'ACTIVE_SITE_PART||' || active_esn_rec.objid || '||ACTIVE_ESN||' || active_esn_rec.x_esn || '||DUE_DATE||' || TO_CHAR(active_esn_rec.warr_end_date ,'MM/DD/YYYY');
 --
 END IF;
 --
 END IF;
 -- CR15570 END KACOSTA 05/12/2011
 -- END ST BUNDLE 3
 --relation with Fraud Case
 IF NVL(p_fraud_objid ,0) > 0 THEN
 UPDATE table_case
 SET case_victim2case = new_case_objid
 WHERE objid = p_fraud_objid;
 COMMIT;
 END IF;
 p_case_objid := new_case_objid;
 IF l_case_detail IS NOT NULL THEN
 case_detail_tab := clear_case_detail_tab;
 case_detail_tab2 := clear_case_detail_tab;
 WHILE LENGTH(l_case_detail) > 0
 LOOP
 dbms_output.put_line('l_case_detail 1:' || l_case_detail);
 IF INSTR(l_case_detail ,'||') = 0 THEN
 case_detail_tab(i) := LTRIM(RTRIM(l_case_detail));
 case_detail_tab2(i) := LTRIM(RTRIM(l_case_detail));
 EXIT;
 ELSE
 case_detail_tab(i) := LTRIM(RTRIM(SUBSTR(l_case_detail ,1 ,INSTR(l_case_detail ,'||') - 1)));
 dbms_output.put_line('1:' || case_detail_tab(i));
 l_case_detail := LTRIM(RTRIM(SUBSTR(l_case_detail ,INSTR(l_case_detail ,'||') + 2)));
 --
 IF INSTR(l_case_detail ,'||') = 0 THEN
 case_detail_tab2(i) := LTRIM(RTRIM(l_case_detail));
 ELSE
 case_detail_tab2(i) := LTRIM(RTRIM(SUBSTR(l_case_detail ,1 ,INSTR(l_case_detail ,'||') - 1)));
 dbms_output.put_line('0:' || case_detail_tab(i));
 l_case_detail := LTRIM(RTRIM(SUBSTR(l_case_detail ,INSTR(l_case_detail ,'||') + 2)));
 END IF;
 i := i + 1;
 dbms_output.put_line('l_case_detail 2:' || l_case_detail);
 END IF;
 END LOOP;
 dbms_output.put_line('fin:' || i);
 FOR j IN 1 .. i - 1
 LOOP
 dbms_output.put_line('fin(' || j || '):' || case_detail_tab(j));
 dbms_output.put_line('fin2(' || j || '):' || case_detail_tab2(j));
 END LOOP;
 FOR j IN 1 .. i - 1
 LOOP
 IF case_detail_tab(j) LIKE '%CURRENT_CARRIER_ID%' THEN
 v_current_carrier_id := case_detail_tab2(j);
 END IF;
 IF case_detail_tab(j) LIKE '%ASSIGNED_CARRIER_ID%' THEN
 v_assigned_carrier_id := case_detail_tab2(j);
 END IF;
 if case_detail_tab(j) = 'ACTIVATION_ZIP_CODE' and case_detail_tab2(j) is not null then
 case_detail_act_zipcode := case_detail_tab2(j);
 end if;
 INSERT
 INTO table_x_case_detail
 (
 objid ,
 x_name ,
 x_value ,
 detail2case
 )
 VALUES
 (
 seq('x_case_detail') ,
 case_detail_tab(j) ,
 case_detail_tab2(j) ,
 new_case_objid
 );
 END LOOP;
 END IF;
 --start CR6254 Adding the MEID hex number as a case detail
 IF model_rec.x_hex_serial_no IS NOT NULL THEN
 INSERT
 INTO table_x_case_detail
 (
 objid ,
 x_name ,
 x_value ,
 detail2case
 )
 VALUES
 (
 seq('x_case_detail') ,
 'HEX' ,
 model_rec.x_hex_serial_no ,
 new_case_objid
 );
 END IF;
 --TMODATA start
 IF v_current_carrier_id IS NOT NULL THEN
 OPEN carrier_cur(TO_NUMBER(v_current_carrier_id));
 FETCH carrier_cur INTO carrier_rec;
 CLOSE carrier_cur;
 tmp_case_details := 'CURRENT_CARRIER||' || carrier_rec.x_mkt_submkt_name;
 update_case_dtl(new_case_objid ,p_user_objid ,tmp_case_details ,tmp_error_no ,tmp_error_str);
 END IF;
 IF v_assigned_carrier_id IS NOT NULL THEN
 OPEN carrier_cur(TO_NUMBER(v_assigned_carrier_id));
 FETCH carrier_cur INTO carrier_rec;
 CLOSE carrier_cur;
 tmp_case_details := 'ASSIGNED_CARRIER||' || carrier_rec.x_mkt_submkt_name;
 update_case_dtl(new_case_objid ,p_user_objid ,tmp_case_details ,tmp_error_no ,tmp_error_str);
 END IF;
 tmp_case_details := 'LINE_STATUS||' || status_desc_func(status_part_inst(nvl(active_esn_rec.x_min,inactive_esn_rec.x_min) ,'LINES'));
 tmp_case_details := tmp_case_details || '||PHONE_STATUS||' || status_desc_func(status_part_inst(nvl(active_esn_rec.x_esn,inactive_esn_rec.x_esn),'PHONES'));
 if case_detail_act_zipcode is null then
 tmp_case_details := tmp_case_details || '||ACTIVATION_ZIP_CODE||'||nvl(active_esn_rec.x_zipcode,inactive_esn_rec.x_zipcode);
 end if;
 update_case_dtl(new_case_objid ,p_user_objid ,tmp_case_details ,tmp_error_no ,tmp_error_str);

 IF active_esn_rec.x_iccid IS NOT NULL or inactive_esn_rec.x_iccid is not null THEN
 OPEN sim_inv_cur(nvl(active_esn_rec.x_iccid,inactive_esn_rec.x_iccid));
 FETCH sim_inv_cur INTO sim_inv_rec;
 IF sim_inv_cur%FOUND THEN
 tmp_case_details := 'SIM_ID||' || nvl(active_esn_rec.x_iccid,inactive_esn_rec.x_iccid) || '||SIM_STATUS||' || status_desc_func(sim_inv_rec.x_sim_inv_status) || '||REPL_SIM_ID||';
 update_case_dtl(new_case_objid ,p_user_objid ,tmp_case_details ,tmp_error_no ,tmp_error_str);
 END IF;
 CLOSE sim_inv_cur;
 END IF;
 --TMODATA end
 --end CR6254
 OPEN ff_center_curs(status_rec.title);
 FETCH ff_center_curs INTO ff_center_rec;
 IF ff_center_curs%FOUND THEN
 ship_overwrite := 1;
 END IF;
 OPEN warehouse_curs(p_case_type ,p_title);
 FETCH warehouse_curs INTO warehouse_rec;
 IF warehouse_curs%FOUND THEN
 --CR46924 March-2017 begin
 if p_case_type in ('Warranty', 'Warehouse') then
 tmp_case_details := 'WARRANTY_DAYS_LEFT||' || get_warranty_days_left(p_esn);
 update_case_dtl(p_case_objid => new_case_objid ,p_user_objid => p_user_objid ,p_case_detail => tmp_case_details ,p_error_no => tmp_error_no ,p_error_str => tmp_error_str);
 end if;
 --CR46924 March-2017 End
 --
 -- CR19490 Start kacosta 04/30/2012
 IF (warehouse_rec.x_required_return = 1) THEN
 --
 tmp_case_details := 'EXCHANGE_COUNTER||' || TO_CHAR(model_rec.exchange_counter);
 --
 update_case_dtl(p_case_objid => new_case_objid ,p_user_objid => p_user_objid ,p_case_detail => tmp_case_details ,p_error_no => tmp_error_no ,p_error_str => tmp_error_str);
 --
 --Return required check if airbill is requried also
 OPEN airbill_cur(model_rec.part_number,
 warehouse_rec.x_repl_logic); -- CR39592 PMistry 03/24/2016 added replacement logic.
 FETCH airbill_cur INTO airbill_rec;
 IF airbill_cur%FOUND THEN
 v_airbill_needed := TRUE;
 v_airbill_part_num := airbill_rec.x_airbil_part_number;
 END IF;
 CLOSE airbill_cur;
 END IF;
 -- CR19490 End kacosta 04/30/2012
 --
 warehouse_case := TRUE;
 IF NVL(warehouse_rec.x_instruct_type ,0) = 1 THEN
 instruc_code := warehouse_rec.x_instruct_code;
 instruc_type := 1;
 ELSE
 IF NVL(warehouse_rec.x_instruct_type ,0) = 2 THEN
 OPEN instruc_curs(p_esn ,warehouse_rec.x_instruct_code);
 FETCH instruc_curs INTO instruc_rec;
 IF instruc_curs%FOUND THEN
 instruc_code := warehouse_rec.x_instruct_code;
 instruc_type := 2;
 END IF;
 CLOSE instruc_curs;
 END IF;
 END IF;
 END IF;
 CLOSE warehouse_curs;
 IF l_part_request IS NOT NULL AND warehouse_case THEN
 part_request_tab := clear_part_request_tab;
 WHILE LENGTH(l_part_request) > 0
 LOOP
 IF INSTR(l_part_request ,'||') = 0 THEN
 part_request_tab(i2) := LTRIM(RTRIM(l_part_request));
 EXIT;
 ELSE
 part_request_tab(i2) := LTRIM(RTRIM(SUBSTR(l_part_request ,1 ,INSTR(l_part_request ,'||') - 1)));
 --CR6073
 -- l_part_request := LTRIM (RTRIM (SUBSTR (l_part_request, INSTR (l_part_request, '||') + 1)));
 l_part_request := LTRIM(RTRIM(SUBSTR(l_part_request ,INSTR(l_part_request ,'||') + 2)));
 --CR6073
 i2 := i2 + 1;
 END IF;
 END LOOP;
 FOR j IN 1 .. i2
 LOOP
 --CR18850 Start Kacosta 02/23/2012
 ship_rec := NULL;
 --CR18850 End Kacosta 02/23/2012
 OPEN ship_curs(part_request_tab(j) ,p_case_type ,p_title ,p_zipcode);
 FETCH ship_curs INTO ship_rec;
 CLOSE ship_curs;
 IF ship_rec.domain IS NULL THEN
 OPEN domain_curs(part_request_tab(j));
 FETCH domain_curs INTO domain_rec;
 CLOSE domain_curs;
 END IF;
 IF ship_overwrite = 0 THEN
 v_pr_status := 'PENDING';
 ELSE
 v_pr_status := 'INCOMPLETE';
 END IF;
 dbms_output.put_line('domain:' || NVL(ship_rec.domain ,domain_rec.domain));
 dbms_output.put_line('title:' || p_title);
 -- CR21111 Start NGUADA
 --CR15363 Start KACOSTA 04/22/2011
 --IF NVL(ship_rec.domain, domain_rec.domain) = 'PHONES' and MODEL_REC.ORG_ID = 'STRAIGHT_TALK'
 -- and ( p_title = 'ST Defective Phone' or p_title = 'Goodwill Replacement' ) then ----CR13085
 -- v_pr_status := 'ONHOLDST'; -- Exchange for ST
 --end if;
 --OPEN get_x_case_conf_hdr_curs(c_x_case_type => p_case_type
 -- ,c_x_title => p_title);
 --FETCH get_x_case_conf_hdr_curs
 -- INTO get_x_case_conf_hdr_rec;
 --CLOSE get_x_case_conf_hdr_curs;
 IF NVL(ship_rec.domain ,domain_rec.domain) = 'PHONES' AND warehouse_rec.x_required_return = 1 AND v_airbill_needed = TRUE
 AND NVL(v_subBrand,'X') != 'SAFELINK' --EME 52229
 THEN
 -- Warehouse Case requires handset returned
 v_pr_status := 'ONHOLDST';
 END IF;
 IF part_request_tab(j) LIKE '%AIRBILL%' THEN
 v_airbill_added := TRUE; --Airbill added
 END IF;
 -- CR21111 End NGUADA
 /* CR21111 Start NGUADA
 IF NVL(ship_rec.domain
 ,domain_rec.domain) = 'PHONES'
 -- CR20451 | CR20854: Add TELCEL Brand
 -- AND model_rec.org_id = 'STRAIGHT_TALK'
 AND model_rec.org_flow = '3'
 AND p_case_type = 'Warranty'
 AND get_x_case_conf_hdr_rec.x_warehouse = 1 THEN
 --
 v_pr_status := 'ONHOLDST';
 --
 --CR18850 Start Kacosta 02/23/2012
 ELSIF NVL(ship_rec.domain
 ,domain_rec.domain) = 'PHONES'
 AND p_part_request LIKE '%NT-EX-AIRBILL%' THEN
 --
 --CR20410 Start Kacosta 03/30/2012
 --v_pr_status := 'ONHOLD';
 v_pr_status := 'ONHOLDST';
 --CR20410 End Kacosta 03/30/2012
 --
 --CR18850 End Kacosta 02/23/2012
 END IF;
 --CR15363 End KACOSTA 04/22/2011
 */
 --CR21111 End NGUADA
 dbms_output.put_line('pr status:' || v_pr_status);
 INSERT
 INTO table_x_part_request
 (
 objid ,
 x_action ,
 x_repl_part_num ,
 x_part_serial_no ,
 x_ff_center ,
 x_ship_date ,
 x_est_arrival_date ,
 x_received_date ,
 x_courier ,
 x_shipping_method ,
 x_tracking_no ,
 x_status ,
 request2case ,
 x_insert_date ,
 x_part_num_domain ,
 x_service_level ,
 x_quantity
 )
 VALUES
 (
 seq('x_part_request') ,
 'SHIP' ,
 part_request_tab(j) ,
 NULL ,
 DECODE(ship_overwrite ,0 ,ship_rec.x_ff_code ,ff_center_rec.x_ff_code) ,
 NULL ,
 NULL ,
 NULL ,
 DECODE(ship_overwrite ,0 ,ship_rec.x_courier_id ,NULL) ,
 DECODE(ship_overwrite ,0 ,ship_rec.x_shipping_method ,NULL) ,
 NULL ,
 v_pr_status ,
 new_case_objid ,
 SYSDATE ,
 NVL(ship_rec.domain ,domain_rec.domain) ,
 ship_rec.x_service_level ,
 1
 );
 SELECT DECODE(ship_overwrite ,0 ,ship_rec.x_ff_code ,ff_center_rec.x_ff_code)
 INTO instruc_ffc
 FROM dual;
 SELECT DECODE(ship_overwrite ,0 ,ship_rec.x_courier_id ,NULL)
 INTO instruc_cid
 FROM dual;
 SELECT DECODE(ship_overwrite ,0 ,ship_rec.x_shipping_method ,NULL)
 INTO instruc_sm
 FROM dual;
 END LOOP;
 --Add Airbill to part request if required yet missing
 --CR21111 Start NGUADA
 IF v_airbill_needed = TRUE AND v_airbill_added = FALSE THEN
 part_request_add(strcaseobjid => new_case_objid ,strpartnumber => v_airbill_part_num ,p_quantity => 1 ,p_user_objid => p_user_objid ,p_shipping => NULL ,p_error_no => tmp_error_no ,p_error_str => tmp_error_str);
 END IF;
 --CR21111 End NGUADA
 --special instructions
 IF NVL(instruc_code ,'0') <> '0' THEN
 INSERT
 INTO table_x_part_request
 (
 objid ,
 x_action ,
 x_repl_part_num ,
 x_part_serial_no ,
 x_ff_center ,
 x_ship_date ,
 x_est_arrival_date ,
 x_received_date ,
 x_courier ,
 x_shipping_method ,
 x_tracking_no ,
 x_status ,
 request2case ,
 x_insert_date ,
 x_part_num_domain ,
 x_service_level ,
 x_quantity
 )
 VALUES
 (
 seq('x_part_request') ,
 'SHIP' ,
 instruc_code ,
 NULL ,
 instruc_ffc ,
 NULL ,
 NULL ,
 NULL ,
 instruc_cid ,
 instruc_sm ,
 NULL ,
 'PENDING' ,
 new_case_objid ,
 SYSDATE ,
 'INSTRUCTION' ,
 NULL ,
 1
 );
 UPDATE x_special_instructions_list
 SET x_process_date = SYSDATE
 WHERE x_esn = p_esn
 AND x_instruc_code = instruc_code
 AND x_process_date IS NULL;
 COMMIT;
 END IF;
 END IF;
 --Part Request Needed, Inserted Dummy One
 IF p_part_request IS NULL AND WAREHOUSE_CASE AND P_TITLE <> 'Lifeline Shipment' AND p_title <> 'SafeLink BroadBand Shipment' THEN -- Ramu: Modify here to add new Safelink broadband case title CR23889
 /*vyegnamurthy CR33271 START*/

BEGIN
 SELECT DISTINCT part_number INTO v_part_number
 FROM TABLE(sa.adfcrm_case.avail_repl_part_num(ip_case_type => p_case_type, ip_case_title => p_title, ip_esn => p_esn));
 EXCEPTION
WHEN OTHERS THEN
 v_part_number :=null;
END;
 /*vyegnamurthy CR33271 END*/
 INSERT
 INTO table_x_part_request
 (
 objid ,
 x_action ,
 x_repl_part_num ,
 x_part_serial_no ,
 x_ff_center ,
 x_ship_date ,
 x_est_arrival_date ,
 x_received_date ,
 x_courier ,
 x_shipping_method ,
 x_tracking_no ,
 x_status ,
 request2case ,
 x_insert_date ,
 x_part_num_domain ,
 x_service_level ,
 x_quantity
 )
 VALUES
 (
 seq('x_part_request') ,
 'SHIP' ,
 v_part_number ,
 NULL ,
 'MM_IO' ,
 NULL ,
 NULL ,
 NULL ,
 NULL ,
 NULL ,
 NULL ,
 'INCOMPLETE' ,
 new_case_objid ,
 SYSDATE ,
 NULL ,
 NULL ,
 1
 );
 END IF;
 --START B2B case Port In Case Notification
 IF p_title = 'Port In' AND p_case_type = 'Port In' THEN
 DECLARE
 CURSOR emails_cur
 IS
 SELECT *
 FROM table_x_parameters
 WHERE x_param_name = 'B2B_PORT_CREATED_NOTIFICATION';
 emails_rec emails_cur%ROWTYPE;
 email_dtl VARCHAR2(200) := 'B2B Port: ' || new_case_id || ' Created ' || TO_CHAR(SYSDATE ,'mm/dd/yyyy hh:mi AM');
 RESULT VARCHAR2(500);
 BEGIN
 FOR emails_rec IN emails_cur
 LOOP
 send_mail(subject_txt => 'B2B Port: ' || new_case_id || ' Created' ,msg_from => 'noreply@tracfone.com' ,send_to => emails_rec.x_param_value ,message_txt => email_dtl ,RESULT => RESULT);
 END LOOP;
 EXCEPTION
 WHEN OTHERS THEN
 NULL;
 END;
 END IF;
 -- END B2B case Port In Case Notification
 COMMIT;

EXCEPTION
WHEN OTHERS THEN
 p_error_no := SQLCODE;
 p_error_str := SQLERRM;
END;
--
PROCEDURE dispatch_case(
 p_case_objid IN NUMBER ,
 p_user_objid IN NUMBER ,
 p_queue_name IN VARCHAR2 ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2 )
IS
 l_act_entry_objid NUMBER := seq('act_entry');
 CURSOR queue_curs(c_title IN VARCHAR2)
 IS
 SELECT *
 FROM table_queue
 WHERE title = c_title;
 queue_rec queue_curs%ROWTYPE;

 CURSOR queue2_curs(c_queue_objid IN NUMBER)
 IS
 SELECT *
 FROM table_queue
 WHERE objid = c_queue_objid;
 -- CR20451 | CR20854: Add TELCEL Brand
 -- CURSOR case_curs(c_objid IN NUMBER) IS
 -- SELECT *
 -- FROM table_case
 -- WHERE objid = c_objid;
 CURSOR case_curs(c_objid IN NUMBER)
 IS
 SELECT
 tc.*
 FROM
 table_case tc
 WHERE
 tc.objid = c_objid;
 case_rec case_curs%ROWTYPE;
 CURSOR condition_curs(c_objid IN NUMBER)
 IS
 SELECT *
 FROM table_condition
 WHERE
 objid = c_objid;
 condition_rec condition_curs%ROWTYPE;
 CURSOR employee_curs(c_objid IN NUMBER)
 IS
 SELECT *
 FROM table_employee
 WHERE employee2user = c_objid;
 employee_rec employee_curs%ROWTYPE;
 CURSOR gbst_lst_curs(c_title IN VARCHAR2)
 IS
 SELECT *
 FROM table_gbst_lst
 WHERE title LIKE c_title;
 gbst_lst_rec gbst_lst_curs%ROWTYPE;
 CURSOR gbst_elm_curs ( c_objid IN NUMBER ,c_title IN VARCHAR2 )
 IS
 SELECT *
 FROM table_gbst_elm
 WHERE gbst_elm2gbst_lst = c_objid
 AND title LIKE c_title;
 gbst_elm_rec gbst_elm_curs%ROWTYPE;

 CURSOR dispatch_conf_queue_curs ( c_case_type IN VARCHAR2 ,c_case_title IN
 VARCHAR2 ,c_casests2gbst_elm
 IN NUMBER ,c_respprty2gbst_elm
 IN NUMBER )
 IS
 SELECT
 dispatch2queue queue_objid ,
 x_warehouse
 FROM
 table_x_case_dispatch_conf ,
 table_x_case_conf_hdr
 WHERE 1=1
 AND status2gbst_elm in (c_casests2gbst_elm,-1)
 AND priority2gbst_elm in (c_respprty2gbst_elm,-1)
 AND dispatch2conf_hdr = table_x_case_conf_hdr.objid
 AND table_x_case_conf_hdr.x_case_type = c_case_type -- x_case_type
 AND table_x_case_conf_hdr.x_title = c_case_title --title
 ORDER BY priority2gbst_elm,priority2gbst_elm desc;

 dispatch_conf_queue_rec dispatch_conf_queue_curs%ROWTYPE;


 --CR44898 cursor to verify if exists the configuration in table_x_case_conf_time_queue
 CURSOR conf_time_queue_def (c_case_type IN VARCHAR2,
 c_case_title IN VARCHAR2) is
 select tq.time_queue2queue
 from sa.table_x_case_conf_hdr conf,
 sa.table_x_case_conf_time_queue tq
 where conf.x_title = c_case_title
 and conf.x_case_type = c_case_type
 and tq.time_queue2conf_hdr = conf.objid;
 conf_time_queue_def_rec conf_time_queue_def%rowtype;

 --CR44898 new queues based on time
 CURSOR conf_time_queue_curs (c_case_type IN VARCHAR2,
 c_case_title IN VARCHAR2,
 c_case_creation_time IN DATE) is
 select tq.time_queue2queue
 from sa.table_x_case_conf_hdr conf,
 sa.table_x_case_conf_time_queue tq
 where conf.x_title = c_case_title
 and conf.x_case_type = c_case_type
 and tq.time_queue2conf_hdr = conf.objid
 and tq.hours_open <= ((sysdate-c_case_creation_time)*24)
 order by tq.hours_open desc; --only grab the first queue found based on this order

 conf_time_queue_rec conf_time_queue_curs%rowtype;

 CURSOR user_curs
 IS
 SELECT login_name
 FROM table_user
 WHERE 1 = 1
 AND objid = p_user_objid;
 user_rec user_curs%ROWTYPE;
 warehouse_case NUMBER := 0;
 cnt_entry NUMBER := 0;
 v_queue_name varchar2(50);
 v_queue_objid number;

BEGIN
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 OPEN case_curs(p_case_objid);
 FETCH case_curs INTO case_rec;
 IF case_curs%NOTFOUND THEN
 CLOSE case_curs;
 p_error_no := '1';
 p_error_str := 'Case not found';
 RETURN;
 END IF;
 CLOSE case_curs;
 --
 OPEN condition_curs(case_rec.case_state2condition);
 FETCH condition_curs INTO condition_rec;
 IF condition_curs%NOTFOUND THEN
 CLOSE condition_curs; --Fix OPEN_CURSORS
 RETURN;
 END IF;
 CLOSE condition_curs;
 -- Request received from Natalio on 05/17/2016
 IF condition_rec.title = 'Closed' THEN
 p_error_no := '5';
 p_error_str := 'Case Closed';
 RETURN;
 END IF;

 --Time Based Dispatch
OPEN conf_time_queue_def(case_rec.x_case_type,case_rec.title);
FETCH conf_time_queue_def INTO conf_time_queue_rec;
IF conf_time_queue_def%FOUND THEN
 CLOSE conf_time_queue_def;
 OPEN conf_time_queue_curs(case_rec.x_case_type,case_rec.title,case_rec.creation_time);
 FETCH conf_time_queue_curs INTO conf_time_queue_rec;
 IF conf_time_queue_curs%FOUND THEN
 OPEN queue2_curs(conf_time_queue_rec.time_queue2queue);
 FETCH queue2_curs INTO queue_rec;
 IF queue2_curs%FOUND THEN
 v_queue_name := queue_rec.title;
 v_queue_objid:= queue_rec.objid;
 END IF;
 CLOSE conf_time_queue_curs;
 CLOSE queue2_curs;
 END IF;
ELSE
 CLOSE conf_time_queue_def;
END IF;

--Conf Base Dispatch
if v_queue_name is null then
 OPEN dispatch_conf_queue_curs(case_rec.x_case_type ,case_rec.title ,
 case_rec.casests2gbst_elm ,case_rec.respprty2gbst_elm);
 FETCH dispatch_conf_queue_curs INTO dispatch_conf_queue_rec;
 IF dispatch_conf_queue_curs%FOUND THEN
 OPEN queue2_curs(dispatch_conf_queue_rec.queue_objid);
 FETCH queue2_curs INTO queue_rec;
 IF queue2_curs%FOUND THEN
 v_queue_name := queue_rec.title;
 v_queue_objid:= queue_rec.objid;
 END IF;
 CLOSE queue2_curs;
 END IF;
 CLOSE dispatch_conf_queue_curs;
end if;

--Default Conf Base Dispatch (-1 -1)
if v_queue_name is null then
 OPEN dispatch_conf_queue_curs(case_rec.x_case_type ,case_rec.title ,
 -1 ,-1);
 FETCH dispatch_conf_queue_curs INTO dispatch_conf_queue_rec;
 IF dispatch_conf_queue_curs%FOUND THEN
 OPEN queue2_curs(dispatch_conf_queue_rec.queue_objid);
 FETCH queue2_curs INTO queue_rec;
 IF queue2_curs%FOUND THEN
 v_queue_name := queue_rec.title;
 v_queue_objid:= queue_rec.objid;
 END IF;
 CLOSE queue2_curs;
 END IF;
 CLOSE dispatch_conf_queue_curs;
end if;

-- If all fails dispatch to the queue requested.
if v_queue_name is null and p_queue_name is not null then
 OPEN queue_curs(p_queue_name);
 FETCH queue_curs INTO queue_rec;
 IF queue_curs%FOUND THEN
 v_queue_name := queue_rec.title;
 v_queue_objid:= queue_rec.objid;
 END IF;
 CLOSE queue_curs;
end if;

--CR45747 START NGUADA 9/29/2016
--Avoid returning errors for unnecessary dispatch requests or missing configurations.

--IF v_queue_name is null then
-- p_error_no := '25';
-- p_error_str := 'Queue not found';
-- RETURN;
--END IF;
IF v_queue_objid = nvl(case_rec.case_currq2queue,-1) or v_queue_name is null then
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 RETURN;
END IF;
--CR45747 END

 OPEN user_curs;
 FETCH user_curs INTO user_rec;
 IF user_curs%NOTFOUND THEN
 CLOSE user_curs;
 p_error_no := '4';
 p_error_str := 'User not found';
 RETURN;
 END IF;
 CLOSE user_curs;

 OPEN gbst_lst_curs('Activity Name');
 FETCH gbst_lst_curs INTO gbst_lst_rec;
 IF gbst_lst_curs%NOTFOUND THEN
 CLOSE gbst_lst_curs; --Fix OPEN_CURSORS
 RETURN;
 END IF;
 CLOSE gbst_lst_curs;
 --
 OPEN gbst_elm_curs(gbst_lst_rec.objid ,'Dispatch');
 FETCH gbst_elm_curs INTO gbst_elm_rec;
 IF gbst_elm_curs%NOTFOUND THEN
 CLOSE gbst_elm_curs; --Fix OPEN_CURSORS
 RETURN;
 END IF;
 CLOSE gbst_elm_curs;
 --Updates the Condition Record
 UPDATE table_condition
 SET condition = 10 ,
 queue_time = SYSDATE ,
 title = 'Open-Dispatch' ,
 s_title = 'OPEN-DISPATCH'
 WHERE objid = condition_rec.objid;

 UPDATE table_case
 SET case_currq2queue = v_queue_objid
 WHERE objid = p_case_objid;

 --Build the Activity Entry
 INSERT
 INTO
 table_act_entry
 (
 objid ,
 act_code ,
 entry_time ,
 addnl_info ,
 proxy ,
 removed ,
 act_entry2case ,
 act_entry2user ,
 entry_name2gbst_elm
 )
 VALUES
 (
 l_act_entry_objid ,
 900 ,
 SYSDATE ,
 ' Dispatched to Queue '
 || v_queue_name ,
 NULL ,
 0 ,
 p_case_objid ,
 p_user_objid ,
 gbst_elm_rec.objid
 );

 COMMIT;
EXCEPTION
WHEN OTHERS THEN
 p_error_no := SQLCODE;
 p_error_str := SQLERRM;
END dispatch_case;

--
PROCEDURE log_notes
 (
 p_case_objid IN NUMBER ,
 p_user_objid IN NUMBER ,
 p_notes IN VARCHAR2 ,
 p_action_type IN VARCHAR2 ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2
 )
IS
 new_notes_log_objid NUMBER := sa.seq('notes_log');
 CURSOR case_curs
 IS
 SELECT case_history ,
 casests2gbst_elm
 FROM table_case
 WHERE objid = p_case_objid;
 case_rec case_curs%ROWTYPE;
 --l_case_hold_long varchar2(32000);
BEGIN
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 OPEN case_curs;
 FETCH case_curs INTO case_rec;
 IF case_curs%NOTFOUND THEN
 case_rec.case_history := NULL;
 END IF;
 CLOSE case_curs;
 INSERT
 INTO table_notes_log
 (
 objid ,
 creation_time ,
 description ,
 internal ,
 commitment ,
 due_date ,
 action_type ,
 notes_owner2user ,
 old_notes_stat2gbst_elm ,
 new_notes_stat2gbst_elm ,
 case_notes2case
 )
 VALUES
 (
 new_notes_log_objid ,
 SYSDATE ,
 ADFCRM_RECTIFY_NON_ASCII (p_notes),
 --REGEXP_REPLACE(p_notes, '[^[:print:]]'),
 NULL ,
 'Call back required' ,
 TO_DATE('01/01/1753' ,'MM/DD/YYYY') ,
 p_action_type ,
 p_user_objid ,
 case_rec.casests2gbst_elm , --:B23,
 case_rec.casests2gbst_elm , --:B24,
 p_case_objid
 );
 INSERT
 INTO table_act_entry
 (
 objid ,
 act_code ,
 entry_time ,
 addnl_info ,
 proxy ,
 removed ,
 focus_type ,
 focus_lowid ,
 entry_name2gbst_elm ,
 act_entry2case ,
 act_entry2user ,
 act_entry2notes_log
 )
 VALUES
 (
 sa.seq('act_entry') ,
 1700 ,
 SYSDATE ,
 SUBSTR(p_notes ,1 ,255) ,
 NULL ,
 0 ,
 0 ,
 0 ,
 268435639 ,
 p_case_objid ,
 p_user_objid ,
 new_notes_log_objid
 );
 --l_case_hold_long := substr(case_rec.case_history ||CHR(10)||'*** NOTES '||TO_CHAR( sysdate , 'MM/DD/YYYY HH24:MI:SS')||
 -- ' Action Type: '||P_ACTION_TYPE||CHR(10)||P_NOTES,32000);
 UPDATE table_case
 SET modify_stmp = SYSDATE
 WHERE objid = p_case_objid;
 COMMIT;
 --update table_case
 --set case_history = l_case_hold_long ,
 --modify_stmp = sysdate
 --where objid = p_CASE_OBJID;
 -- update table_case
 -- set case_history = case_rec.case_history ||CHR(10)||'*** NOTES '||TO_CHAR( sysdate , 'MM/DD/YYYY HH24:MI:SS')||
 -- ' Action Type: '||P_ACTION_TYPE||CHR(10)||P_NOTES,
 -- modify_stmp = sysdate
 -- where objid = P_CASE_OBJID;
EXCEPTION
WHEN OTHERS THEN
 p_error_no := SQLCODE;
 p_error_str := SQLERRM;
END;
PROCEDURE update_status(
 p_case_objid IN NUMBER ,
 p_user_objid IN NUMBER ,
 p_new_status IN VARCHAR2 ,
 p_status_notes IN VARCHAR2 ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2 )
IS
 new_act_entry_objid NUMBER := sa.seq('act_entry');
 CURSOR case_curs
 IS
 SELECT c.objid ,
 c.case_history ,
 c.case_owner2user ,
 c.creation_time,
 ge.title cond_title ,
 gb.title sts_title,
 (select count('1') from table_x_case_conf_hdr where x_case_type = c.x_case_type and x_title = c.title and x_warehouse = 1) is_warehouse
 FROM table_condition ge ,
 table_case c ,
 table_gbst_elm gb
 WHERE 1 = 1
 AND ge.objid = c.case_state2condition
 AND c.objid = p_case_objid
 AND gb.objid = c.casests2gbst_elm;
 case_rec case_curs%ROWTYPE;
 CURSOR new_status_curs
 IS
 SELECT ge.objid
 FROM table_gbst_elm ge ,
 table_gbst_lst gl
 WHERE 1 = 1
 AND ge.title
 || '' = p_new_status
 AND gbst_elm2gbst_lst = gl.objid
 AND gl.title = 'Open';
 new_status_rec new_status_curs%ROWTYPE;
 CURSOR user_curs
 IS
 SELECT login_name FROM table_user WHERE 1 = 1 AND objid = p_user_objid;
 user_rec user_curs%ROWTYPE;
 --l_case_hold_long varchar2(32000);
BEGIN
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 OPEN case_curs;
 FETCH case_curs INTO case_rec;
 IF case_curs%NOTFOUND THEN
 case_rec.case_owner2user := NULL;
 case_rec.sts_title := NULL;
 case_rec.cond_title := NULL;
 case_rec.case_history := NULL;
 p_error_no := '1';
 p_error_str := 'Case not found';
 CLOSE case_curs;
 RETURN;
 END IF;
 CLOSE case_curs;
 IF case_rec.cond_title = 'Closed' THEN
 p_error_no := '2';
 p_error_str := 'Case needs to be Open to change status';
 RETURN;
 END IF;


 IF case_rec.sts_title = 'Back Order' and p_status_notes ='Case Creation' then
 p_error_no := '7';
 p_error_str := 'Keeping Back Order Status during Case Creation';
 RETURN;
END IF;

 --if case_rec.CASE_OWNER2USER<> p_USER_OBJID then
 -- p_ERROR_NO := '3';
 -- p_ERROR_STR := 'Only owner can change case status';
 -- return;
 --end if;
 OPEN user_curs;
 FETCH user_curs INTO user_rec;
 IF user_curs%NOTFOUND THEN
 p_error_no := '4';
 p_error_str := 'User not found';
 CLOSE user_curs;
 RETURN;
 END IF;
 CLOSE user_curs;
 OPEN new_status_curs;
 FETCH new_status_curs INTO new_status_rec;
 IF new_status_curs%NOTFOUND THEN
 new_status_rec.objid := NULL;
 p_error_no := '5';
 p_error_str := 'New status is not valid';
 CLOSE new_status_curs;
 RETURN;
 END IF;
 CLOSE new_status_curs;

 IF UPPER(p_new_status) = 'BACK ORDER' and case_rec.is_warehouse = 0 then
 p_error_no := '6';
 p_error_str := 'Back Order is only allowed for Warehouse related cases.';
 RETURN;
 END IF;

 -- l_case_hold_long := substr(case_rec.case_history ||CHR(10)||CHR(10)|| '*** STATUS CHANGE '||
 -- TO_CHAR( sysdate ,'MM/DD/YYYY HH24:MI:SS')|| ' '||user_rec.login_name||CHR(10)||
 -- p_STATUS_NOTES,32000);
 UPDATE table_case
 SET casests2gbst_elm = new_status_rec.objid ,
 case_sup_type = decode(p_new_status,'BadAddress','N',null), --CR38782
 modify_stmp = SYSDATE
 WHERE objid = p_case_objid;
 COMMIT;
 --update table_case
 -- set casests2gbst_elm = new_status_rec.objid,
 -- case_history = l_case_hold_long,
 -- modify_stmp = sysdate
 -- where objid = p_CASE_OBJID;
 -- update table_case
 -- set casests2gbst_elm = new_status_rec.objid,
 -- case_history = case_rec.case_history ||CHR(10)||CHR(10)|| '*** STATUS CHANGE '||TO_CHAR( sysdate ,'MM/DD/YYYY HH24:MI:SS')|| ' '||user_rec.login_name||CHR(10)||p_STATUS_NOTES, modify_stmp = sysdate
 -- where objid = p_CASE_OBJID;
 INSERT
 INTO table_act_entry
 (
 objid ,
 act_code ,
 entry_time ,
 addnl_info ,
 proxy ,
 removed ,
 focus_type ,
 focus_lowid ,
 entry_name2gbst_elm ,
 act_entry2case ,
 act_entry2user
 )
 VALUES
 (
 new_act_entry_objid ,
 300 ,
 SYSDATE ,
 'from status '
 || case_rec.sts_title
 || ' to status '
 || p_new_status ,
 NULL ,
 0 ,
 0 ,
 0 ,
 268435626 ,
 p_case_objid ,
 p_user_objid
 );
 INSERT
 INTO table_status_chg
 (
 objid ,
 creation_time ,
 notes ,
 status_chger2user ,
 c_status_chg2gbst_elm ,
 p_status_chg2gbst_elm ,
 case_status_chg2case ,
 status_chg2act_entry
 )
 VALUES
 (
 sa.seq('status_chg') ,
 SYSDATE ,
 p_status_notes ,
 p_user_objid ,
 new_status_rec.objid ,
 case_rec.objid ,
 p_case_objid ,
 new_act_entry_objid
 );
 COMMIT;
EXCEPTION
WHEN OTHERS THEN
 p_error_no := SQLCODE;
 p_error_str := SQLERRM;
END;
PROCEDURE update_case_hdr
 (
 p_case_objid IN NUMBER ,
 p_user_objid IN NUMBER ,
 p_title IN VARCHAR2 ,
 p_case_type IN VARCHAR2 ,
 p_issue IN VARCHAR2 ,
 p_source IN VARCHAR2 ,
 p_point_contact IN VARCHAR2 ,
 p_task_objid IN NUMBER ,
 p_contact_objid IN NUMBER ,
 p_phone_num IN VARCHAR2 ,
 p_first_name IN VARCHAR2 ,
 p_last_name IN VARCHAR2 ,
 p_e_mail IN VARCHAR2 ,
 p_delivery_type IN VARCHAR2 ,
 p_address IN VARCHAR2 ,
 p_city IN VARCHAR2 ,
 p_state IN VARCHAR2 ,
 p_zipcode IN VARCHAR2 ,
 p_repl_units IN NUMBER ,
 p_fraud_objid IN NUMBER ,
 p_esn IN VARCHAR2 ,
 p_priority IN VARCHAR2 ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2
 )
IS
 CURSOR check_case_curs
 IS
 SELECT c.case_owner2user ,
 ge.s_title ,
 x_esn
 FROM table_condition ge ,
 table_case c
 WHERE 1 = 1
 AND ge.objid = c.case_state2condition
 AND c.objid = p_case_objid
 AND c.s_title !='SL_FIELD_ACTIVATION';--CR42560 field activation does not require dispatch
 check_case_rec check_case_curs%ROWTYPE;
 CURSOR priority_curs
 IS
 SELECT elm.objid
 FROM table_gbst_elm elm ,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Response Priority Code'
 AND elm.title = p_priority;
 priority_rec priority_curs%ROWTYPE;
 CURSOR active_esn_curs
 IS
 SELECT sp.x_service_id x_esn ,
 sp.x_min ,
 sp.x_msid ,
 sp.x_iccid ,
 car.x_carrier_id ,
 car.x_mkt_submkt_name ,
 pn.part_number ,
 pn.description ,
 s.name ,
 sp.x_zipcode
 FROM table_site s ,
 table_inv_bin ib ,
 table_part_num pn ,
 table_mod_level ml ,
 table_part_inst pi_esn ,
 table_x_carrier car ,
 table_part_inst pi_min ,
 table_site_part sp
 WHERE 1 = 1
 AND s.site_id = ib.bin_name
 AND ib.objid = pi_esn.part_inst2inv_bin
 AND pn.objid = ml.part_info2part_num
 AND ml.objid = pi_esn.n_part_inst2part_mod
 AND pi_esn.part_serial_no = p_esn
 AND car.objid = pi_min.part_inst2carrier_mkt
 AND pi_min.part_serial_no = sp.x_min
 AND sp.x_service_id = p_esn
 AND sp.part_status IN ('Active' ,'CarrierPending');
 active_esn_rec active_esn_curs%ROWTYPE;
 found_priority NUMBER := 0;
 dispatch_required BOOLEAN;
BEGIN
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 dispatch_required := FALSE;
 OPEN check_case_curs;
 FETCH check_case_curs INTO check_case_rec;
 --if check_case_rec.s_title not in ('OPEN', 'OPEN-DISPATCH','OPEN-REJECT') then
 -- close check_case_curs;
 -- p_error_no := '1';
 -- p_error_str := 'current condition is '||check_case_rec.s_title||' case needs to be OPEN, OPEN-DISPATCH or OPEN-REJECT otherwise return an error.' ;
 -- return;
 --end if;
 IF check_case_rec.x_esn IS NOT NULL AND p_esn IS NOT NULL AND check_case_rec.x_esn <> p_esn THEN
 CLOSE check_case_curs;
 p_error_no := '30';
 p_error_str := 'ESN can not be updated for this case';
 RETURN;
 END IF;
 IF p_esn IS NOT NULL THEN
 OPEN active_esn_curs;
 FETCH active_esn_curs INTO active_esn_rec;
 CLOSE active_esn_curs;
 END IF;
 IF check_case_rec.case_owner2user != p_user_objid AND check_case_rec.s_title IN ('OPEN' ,'OPEN-DISPATCH' ,'OPEN-REJECT') THEN
 accept_case(p_case_objid ,p_user_objid ,p_error_no ,p_error_str);
 IF p_error_no = '0' THEN
 dispatch_required := TRUE;
 END IF;
 END IF;
 CLOSE check_case_curs;
 IF p_priority IS NOT NULL THEN
 OPEN priority_curs;
 FETCH priority_curs INTO priority_rec;
 IF priority_curs%FOUND THEN
 found_priority := 1;
 END IF;
 CLOSE priority_curs;
 END IF;
 UPDATE table_case
 SET title = NVL(SUBSTR(p_title ,1 ,80) ,title) ,
 s_title = UPPER(NVL(SUBSTR(p_title ,1 ,80) ,s_title)) ,
 x_case_type = NVL(SUBSTR(p_case_type ,1 ,30) ,x_case_type) ,
 case_type_lvl1 = NVL(SUBSTR(p_issue ,1 ,255) --CR22404
 ,case_type_lvl1) ,
 case_type_lvl3 = NVL(SUBSTR(p_source ,1 ,30) ,case_type_lvl3) ,
 customer_code = NVL(SUBSTR(p_point_contact ,1 ,20) ,customer_code) ,
 x_case2task = NVL(p_task_objid ,x_case2task) ,
 case_reporter2contact = NVL(p_contact_objid ,case_reporter2contact) ,
 alt_phone = NVL(p_phone_num ,alt_phone) ,
 alt_first_name = NVL(p_first_name ,alt_first_name) ,
 alt_last_name = NVL(p_last_name ,alt_last_name) ,
 alt_e_mail = NVL(p_e_mail ,alt_e_mail) ,
 alt_site_name = NVL(p_delivery_type ,alt_site_name) ,
 alt_address = NVL(p_address ,alt_address) ,
 alt_city = NVL(p_city ,alt_city) ,
 alt_state = NVL(p_state ,alt_state) ,
 alt_zipcode = NVL(p_zipcode ,alt_zipcode) ,
 x_replacement_units = NVL(p_repl_units ,x_replacement_units) ,
 x_esn = NVL(active_esn_rec.x_esn ,x_esn) ,
 x_min = NVL(active_esn_rec.x_min ,x_min) ,
 x_msid = NVL(active_esn_rec.x_msid ,x_msid) ,
 x_iccid = NVL(active_esn_rec.x_iccid ,x_iccid) ,
 x_carrier_id = NVL(active_esn_rec.x_carrier_id ,x_carrier_id) ,
 x_text_car_id = TO_CHAR(NVL(active_esn_rec.x_carrier_id ,x_text_car_id)) ,
 x_carrier_name = NVL(SUBSTR(active_esn_rec.x_mkt_submkt_name ,1 ,30) ,x_carrier_name) ,
 x_model = NVL(SUBSTR(active_esn_rec.part_number ,1 ,30) ,x_model) ,
 x_phone_model = NVL(SUBSTR(active_esn_rec.description ,1 ,30) ,x_phone_model) ,
 x_retailer_name = NVL(SUBSTR(active_esn_rec.name ,1 ,80) ,x_retailer_name) ,
 x_activation_zip = NVL(active_esn_rec.x_zipcode ,x_activation_zip) ,
 respprty2gbst_elm = DECODE(found_priority ,1 ,priority_rec.objid ,respprty2gbst_elm)
 WHERE objid = p_case_objid;
 COMMIT;
 --relation with Fraud Case
 IF p_fraud_objid IS NOT NULL THEN
 UPDATE table_case
 SET case_victim2case = p_case_objid
 WHERE objid = p_fraud_objid;
 COMMIT;
 END IF;
 INSERT
 INTO table_act_entry
 (
 objid ,
 act_code ,
 entry_time ,
 addnl_info ,
 proxy ,
 removed ,
 focus_type ,
 focus_lowid ,
 entry_name2gbst_elm ,
 act_entry2case ,
 act_entry2user
 )
 VALUES
 (
 sa.seq('act_entry') ,
 1500 ,
 SYSDATE ,
 'Case Header Updated' ,
 NULL ,
 0 ,
 0 ,
 0 ,
 268435637 ,
 p_case_objid ,
 p_user_objid
 );
 COMMIT;
 IF dispatch_required THEN
 dispatch_case(p_case_objid ,p_user_objid ,NULL ,p_error_no ,p_error_str);
 END IF;
EXCEPTION
WHEN OTHERS THEN
 p_error_no := SQLCODE;
 p_error_str := SQLERRM;
END;
PROCEDURE accept_case
 (
 p_case_objid IN NUMBER ,
 p_user_objid IN NUMBER ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2
 )
IS
 CURSOR case_curs
 IS
 SELECT * FROM table_case WHERE objid = p_case_objid;
 case_rec case_curs%ROWTYPE;
 CURSOR wipbin_curs
 IS
 SELECT objid default_wipbin
 FROM table_wipbin
 WHERE wipbin_owner2user = p_user_objid
 AND title = 'default';
 wipbin_rec wipbin_curs%ROWTYPE;
 CURSOR queue_curs(c_objid IN NUMBER)
 IS
 SELECT * FROM table_queue WHERE objid = c_objid;
 queue_rec queue_curs%ROWTYPE;
BEGIN
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 OPEN case_curs;
 FETCH case_curs INTO case_rec;
 CLOSE case_curs;
 OPEN wipbin_curs;
 FETCH wipbin_curs INTO wipbin_rec;
 CLOSE wipbin_curs;
 OPEN queue_curs(case_rec.case_currq2queue);
 FETCH queue_curs INTO queue_rec;
 CLOSE queue_curs;
 UPDATE table_condition
 SET condition = 2 ,
 wipbin_time = SYSDATE ,
 title = 'Open' ,
 s_title = 'OPEN'
 WHERE objid = case_rec.case_state2condition;
 COMMIT;
 INSERT
 INTO table_act_entry
 (
 objid ,
 act_code ,
 entry_time ,
 addnl_info ,
 proxy ,
 removed ,
 focus_type ,
 focus_lowid ,
 entry_name2gbst_elm ,
 act_entry2case ,
 act_entry2user
 )
 VALUES
 (
 sa.seq('act_entry') ,
 100 ,
 SYSDATE ,
 'from Queue '
 || queue_rec.title
 || ' to WIP default.' ,
 NULL ,
 0 ,
 0 ,
 0 ,
 268435622 ,
 p_case_objid ,
 p_user_objid
 );
 COMMIT;
 UPDATE table_case
 SET case_currq2queue = NULL ,
 case_wip2wipbin = wipbin_rec.default_wipbin ,
 case_owner2user = p_user_objid
 WHERE objid = p_case_objid;
 COMMIT;
EXCEPTION
WHEN OTHERS THEN
 p_error_no := SQLCODE;
 p_error_str := SQLERRM;
END;
PROCEDURE update_case_dtl(
 p_case_objid IN NUMBER ,
 p_user_objid IN NUMBER ,
 p_case_detail IN VARCHAR2 ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2 )
IS
 --
 l_case_detail VARCHAR2(5000) := p_case_detail;
 i PLS_INTEGER := 1;
TYPE case_detail_tab_type
IS
 TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
 case_detail_tab case_detail_tab_type;
 case_detail_tab2 case_detail_tab_type;
 clear_case_detail_tab case_detail_tab_type;
 CURSOR check_case_dtl_curs ( c_case_objid IN NUMBER ,c_name IN VARCHAR2 )
 IS
 SELECT objid
 FROM table_x_case_detail
 WHERE detail2case = c_case_objid
 AND x_name = c_name;
 check_case_dtl_rec check_case_dtl_curs%ROWTYPE;
BEGIN
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 IF l_case_detail IS NOT NULL THEN
 case_detail_tab := clear_case_detail_tab;
 case_detail_tab2 := clear_case_detail_tab;
 WHILE LENGTH(l_case_detail) > 0
 LOOP
 dbms_output.put_line('l_case_detail 1:' || l_case_detail);
 IF INSTR(l_case_detail ,'||') = 0 THEN
 case_detail_tab(i) := LTRIM(RTRIM(l_case_detail));
 case_detail_tab2(i) := LTRIM(RTRIM(l_case_detail));
 EXIT;
 ELSE
 case_detail_tab(i) := LTRIM(RTRIM(SUBSTR(l_case_detail ,1 ,INSTR(l_case_detail ,'||') - 1)));
 dbms_output.put_line('1:' || case_detail_tab(i));
 l_case_detail := LTRIM(RTRIM(SUBSTR(l_case_detail ,INSTR(l_case_detail ,'||') + 2)));
 --
 IF INSTR(l_case_detail ,'||') = 0 THEN
 case_detail_tab2(i) := LTRIM(RTRIM(l_case_detail));
 ELSE
 case_detail_tab2(i) := LTRIM(RTRIM(SUBSTR(l_case_detail ,1 ,INSTR(l_case_detail ,'||') - 1)));
 dbms_output.put_line('0:' || case_detail_tab(i));
 l_case_detail := LTRIM(RTRIM(SUBSTR(l_case_detail ,INSTR(l_case_detail ,'||') + 2)));
 END IF;
 i := i + 1;
 dbms_output.put_line('l_case_detail 2:' || l_case_detail);
 END IF;
 END LOOP;
 dbms_output.put_line('fin:' || i);
 FOR j IN 1 .. i - 1
 LOOP
 dbms_output.put_line('fin(' || j || '):' || case_detail_tab(j));
 dbms_output.put_line('fin2(' || j || '):' || case_detail_tab2(j));
 END LOOP;
 FOR j IN 1 .. i - 1
 LOOP
 OPEN check_case_dtl_curs(p_case_objid ,case_detail_tab(j));
 FETCH check_case_dtl_curs INTO check_case_dtl_rec;
 IF check_case_dtl_curs%FOUND THEN
 UPDATE table_x_case_detail
 SET x_value = case_detail_tab2(j)
 WHERE detail2case = p_case_objid
 AND x_name = case_detail_tab(j);
 COMMIT;
 ELSE
 INSERT
 INTO table_x_case_detail
 (
 objid ,
 x_name ,
 x_value ,
 detail2case
 )
 VALUES
 (
 seq('x_case_detail') ,
 case_detail_tab(j) ,
 case_detail_tab2(j) ,
 p_case_objid
 );
 COMMIT;
 END IF;
 CLOSE check_case_dtl_curs;
 END LOOP;
 END IF;
 COMMIT;
EXCEPTION
WHEN OTHERS THEN
 p_error_no := SQLCODE;
 p_error_str := SQLERRM;
END;
PROCEDURE reopen_case
 (
 p_case_objid IN NUMBER ,
 p_user_objid IN NUMBER ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2
 )
IS
 CURSOR wipbin_curs
 IS
 SELECT objid default_wipbin
 FROM table_wipbin
 WHERE wipbin_owner2user = p_user_objid
 AND title = 'default';
 wipbin_rec wipbin_curs%ROWTYPE;

  v_case_title VARCHAR2(80);
  v_case_type  VARCHAR2(30);
  v_case_creation_time date;

   CURSOR Cur_OldCase
  IS
    SELECT TableCase.S_TITLE,
      TableCase.X_CASE_TYPE,
      TableCase.CREATION_TIME
    FROM TABLE_CASE TableCase
    WHERE TableCase.OBJID = p_case_objid
    order by TableCase.creation_time desc;

   rec_OldCase Cur_OldCase%rowtype;

    CURSOR Cur_CaseConfHdr
  IS
    SELECT confHdr.objid,
      confHdr.x_case_type,
      confHdr.s_x_case_type,
      confHdr.x_title,
      confHdr.s_x_title,
      confHdr.X_BLOCK_REOPEN,
      confHdr.X_REOPEN_DAYS_CHECK
    FROM sa.TABLE_X_CASE_CONF_HDR confHdr
    WHERE confHdr.S_X_CASE_TYPE=upper(v_case_type)
    AND confHdr.S_X_TITLE    =upper(v_case_title);

  rec_CaseConfHdr Cur_CaseConfHdr%rowtype;

BEGIN
 p_error_no := '0';
 p_error_str := 'SUCCESS';

 --CR57442 Update Cases Not to Reopen
 --Verify if case can be reopened based on X_block_reopen and x_reopen_days_check flags from case hdr details
 BEGIN
 OPEN Cur_OldCase;
 FETCH Cur_OldCase into rec_OldCase;
   IF Cur_OldCase%notfound THEN -- no existing case with caseobjid found. cannot reopen.
    p_error_no := '-1';
    p_error_str := 'Existing case is not found.';
      RETURN;
  ELSE
          v_case_title       := rec_OldCase.S_TITLE;
          v_case_type        := rec_OldCase.X_CASE_TYPE;
          v_case_creation_time := rec_OldCase.CREATION_TIME;
  END IF;
  CLOSE Cur_OldCase;

  OPEN Cur_CaseConfHdr;
  FETCH Cur_CaseConfHdr INTO rec_CaseConfHdr;
  IF Cur_CaseConfHdr%found THEN
    if rec_CaseConfHdr.X_BLOCK_REOPEN = 1 then -- case cannot be reopened.
          p_error_no := '-1';
          p_error_str := 'Existing case cannot be reopened.';
        return;
    else
        --v_case_creation_time+rec_CaseConfHdr.X_REOPEN_DAYS_CHECK is limit date when the case can be reopened
        if(trunc(v_case_creation_time+rec_CaseConfHdr.X_REOPEN_DAYS_CHECK) < trunc(sysdate)) then
            p_error_no := '-1';
            p_error_str := 'Existing case cannot be reopened.';
            return;
        end if;
    end if;
  end if;
  close Cur_CaseConfHdr;
 EXCEPTION
    WHEN OTHERS THEN NULL; --Any exception will not stop the current functionality
 END;

 OPEN wipbin_curs;
 FETCH wipbin_curs INTO wipbin_rec;
 CLOSE wipbin_curs;
 UPDATE table_condition
 SET condition = 2 ,
 wipbin_time = SYSDATE ,
 title = 'Open' ,
 s_title = 'OPEN'
 WHERE objid =
 (SELECT case_state2condition FROM table_case WHERE objid = p_case_objid
 );
 COMMIT;
 UPDATE table_case
 SET case_owner2user = p_user_objid ,
 case_wip2wipbin = wipbin_rec.default_wipbin ,
 casests2gbst_elm = 268436056
 WHERE objid = p_case_objid;
 COMMIT;
 INSERT
 INTO table_act_entry
 (
 objid ,
 act_code ,
 entry_time ,
 addnl_info ,
 proxy ,
 removed ,
 focus_type ,
 focus_lowid ,
 entry_name2gbst_elm ,
 act_entry2case ,
 act_entry2user
 )
 VALUES
 (
 sa.seq('act_entry') ,
 2400 ,
 SYSDATE ,
 'with Condition of Open and Status of Pending.' ,
 NULL ,
 0 ,
 0 ,
 0 ,
 268435643 ,
 p_case_objid ,
 p_user_objid
 );
 COMMIT;
EXCEPTION
WHEN OTHERS THEN
 p_error_no := SQLCODE;
 p_error_str := SQLERRM;
END;
--*************************************************************
PROCEDURE close_case
 (
 p_case_objid NUMBER ,
 p_user_objid NUMBER ,
 p_source VARCHAR2 , --Optional
 p_resolution VARCHAR2 , --Optional
 p_status VARCHAR2 , --Optional
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2
 )
IS
 PRAGMA AUTONOMOUS_TRANSACTION; --added for CR45262
 v_current_date DATE := SYSDATE;
 v_case_id table_case.id_number%TYPE;
 CURSOR c_case
 IS
 SELECT c.* FROM table_case c WHERE objid = p_case_objid;
 rec_case c_case%ROWTYPE;
 CURSOR c_condition(c_condition_objid NUMBER)
 IS
 SELECT * FROM table_condition WHERE objid = c_condition_objid;
 rec_condition c_condition%ROWTYPE;
 CURSOR c_subcase
 IS
 SELECT *
 FROM table_case2sub_cls
 WHERE (case_id = v_case_id)
 ORDER BY close_date DESC;
 CURSOR c_gbst_elm ( c_gbst_lst_title VARCHAR2 ,c_gbst_elm_title VARCHAR2 )
 IS
 SELECT ge.title elm_title ,
 ge.objid elm_objid ,
 ge.rank ,
 gl.title lst_title ,
 gl.objid lst_objid
 FROM table_gbst_elm ge ,
 table_gbst_lst gl
 WHERE 1 = 1
 AND ge.title = c_gbst_elm_title
 AND gl.objid = ge.gbst_elm2gbst_lst
 AND gl.title = c_gbst_lst_title;
 CURSOR c_gbst_elm_default(c_gbst_lst_title VARCHAR2)
 IS
 SELECT ge.title elm_title ,
 ge.objid elm_objid ,
 ge.rank ,
 gl.title lst_title ,
 gl.objid lst_objid
 FROM table_gbst_elm ge ,
 table_gbst_lst gl
 WHERE 1 = 1
 AND ge.state = 2
 AND gl.objid = ge.gbst_elm2gbst_lst
 AND gl.title = c_gbst_lst_title;
 CURSOR c_task ( c_esn VARCHAR2 ,c_min VARCHAR2 )
 IS
 SELECT t.*
 FROM table_condition c ,
 table_task t ,
 table_x_call_trans ct
 WHERE c.s_title
 || '' <> 'CLOSED ACTION ITEM'
 AND t.task_state2condition = c.objid
 AND ct.objid = t.x_task2x_call_trans
 AND ct.x_action_type
 || '' IN ('1' ,'2' ,'3' ,'5')
 AND ct.x_min = c_min
 AND ct.x_service_id = c_esn;
 CURSOR c_cust_resolution ( c_type VARCHAR2 ,c_title VARCHAR2 ,c_resolution VARCHAR2 )
 IS
 SELECT table_x_case_resolutions.objid,
 table_x_case_resolutions.x_resolution,
 table_x_case_resolutions.x_agent_resolution
 FROM table_x_case_resolutions ,
 table_x_case_conf_hdr hdr
 WHERE resol2conf_hdr = hdr.objid
 AND s_x_case_type = UPPER(c_type)
 AND s_x_title = UPPER(c_title)
 AND x_condition = 'CLOSED'
 AND x_resolution = c_resolution;
 CURSOR user_curs
 IS
 SELECT login_name FROM table_user WHERE 1 = 1 AND objid = p_user_objid;
 user_rec user_curs%ROWTYPE;
 v_seq_close_case NUMBER;
 v_seq_act_entry NUMBER;
 v_seq_time_bomb NUMBER;
 v_resolution_gbst VARCHAR2(255) := 'Resolution Code';
 v_resolution_code VARCHAR2(255);
 v_addl_info VARCHAR2(255);
 v_actl_phone_time NUMBER := 0;
 v_sub_actl_phone_time NUMBER := 0;
 v_sub_calc_phone_time NUMBER := 0;
 v_calc_phone_time NUMBER := 0;
 v_tot_actl_phone_time NUMBER := 0;
 v_user_login_name VARCHAR2(30);
 v_case_history VARCHAR2(32000);
 rec_case_sts_closed c_gbst_elm%ROWTYPE;
 rec_act_caseclose c_gbst_elm%ROWTYPE;
 rec_act_accept c_gbst_elm%ROWTYPE;
 rec_resolution_code c_gbst_elm%ROWTYPE;
 rec_cust_resolution c_cust_resolution%ROWTYPE;
 v_agent_resolution VARCHAR2(2000);
 v_status VARCHAR2(30);
 hold NUMBER;
 v_case_resol_objid NUMBER;
BEGIN
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 /*v_resolution_code := SUBSTR(p_resolution
 ,1
 ,255);
 v_resolution_code := RTRIM(LTRIM(NVL(v_resolution_code
 ,' ')));
 */
 v_status := p_status;
 v_status := RTRIM(LTRIM(NVL(v_status ,' ')));
 OPEN c_case;
 FETCH c_case INTO rec_case;
 IF c_case%NOTFOUND THEN
 p_error_no := '1';
 p_error_str := 'Case not found';
 CLOSE c_case;
 RETURN;
 END IF;
 CLOSE c_case;
 --CR25000
 UPDATE sa.x_esn_ber_place_holder
 SET x_reserved_flag = NULL,
 x_last_reserved_date = NULL
 WHERE x_reserved_flag =rec_case.x_esn;
 --CR25000
 OPEN c_gbst_elm('Closed' ,v_status);
 FETCH c_gbst_elm INTO rec_case_sts_closed;
 IF c_gbst_elm%NOTFOUND THEN
 CLOSE c_gbst_elm;
 OPEN c_gbst_elm_default('Closed');
 FETCH c_gbst_elm_default INTO rec_case_sts_closed;
 IF c_gbst_elm_default%NOTFOUND THEN
 CLOSE c_gbst_elm_default;
 p_error_no := '5';
 p_error_str := 'New status is not valid';
 RETURN;
 END IF;
 CLOSE c_gbst_elm_default;
 ELSE
 CLOSE c_gbst_elm;
 END IF;
 v_status := rec_case_sts_closed.elm_title;
 OPEN c_cust_resolution(rec_case.x_case_type ,rec_case.title ,p_resolution);
 FETCH c_cust_resolution INTO rec_cust_resolution;
 IF c_cust_resolution%FOUND THEN
 v_agent_resolution := rec_cust_resolution.x_agent_resolution;
 v_case_resol_objid := rec_cust_resolution.objid;
 v_resolution_code := rec_cust_resolution.x_resolution;
 ELSE
 v_agent_resolution := 'Agent Resolution Not Available';
 v_resolution_code := 'Not Available';
 v_case_resol_objid := NULL;
 END IF;
 CLOSE c_cust_resolution;
 OPEN user_curs;
 FETCH user_curs INTO user_rec;
 IF user_curs%NOTFOUND THEN
 CLOSE user_curs;
 p_error_no := '4';
 p_error_str := 'User not found';
 RETURN;
 END IF;
 CLOSE user_curs;
 v_user_login_name := user_rec.login_name;
 /*OPEN c_gbst_elm(v_resolution_gbst
 ,v_resolution_code);
 FETCH c_gbst_elm
 INTO rec_resolution_code;
 IF c_gbst_elm%NOTFOUND THEN
 OPEN c_gbst_elm_default(v_resolution_gbst);
 FETCH c_gbst_elm_default
 INTO rec_resolution_code;
 IF c_gbst_elm_default%NOTFOUND THEN
 p_error_no := '20';
 p_error_str := 'Resolution code ' || v_resolution_code || ' is not valid';
 CLOSE c_gbst_elm;
 CLOSE c_gbst_elm_default;
 RETURN;
 END IF;
 CLOSE c_gbst_elm_default;
 END IF;
 CLOSE c_gbst_elm;
 dbms_output.put_line('Resolution code: ' || v_resolution_code);
 */
 OPEN c_condition(NVL(rec_case.case_state2condition ,0));
 FETCH c_condition INTO rec_condition;
 IF c_condition%NOTFOUND THEN
 p_error_no := '21';
 p_error_str := 'CONDITION FOR CASE ' || v_case_id || ' not found.';
 CLOSE c_condition;
 RETURN;
 END IF;
 CLOSE c_condition;
 IF rec_condition.s_title LIKE 'CLOSED%' THEN
 p_error_no := '22';
 p_error_str := 'Case ' || v_case_id || ' is already closed.';
 RETURN;
 END IF;
 OPEN c_gbst_elm('Activity Name' ,'Case Close');
 FETCH c_gbst_elm INTO rec_act_caseclose;
 IF c_gbst_elm%NOTFOUND THEN
 p_error_no := '24';
 p_error_str := 'Activity code for closed case not found';
 CLOSE c_gbst_elm;
 RETURN;
 END IF;
 CLOSE c_gbst_elm;
 OPEN c_gbst_elm('Activity Name' ,'Accept');
 FETCH c_gbst_elm INTO rec_act_accept;
 IF c_gbst_elm%NOTFOUND THEN
 p_error_no := '25';
 p_error_str := 'Activity code for accepting case not found';
 CLOSE c_gbst_elm;
 RETURN;
 END IF;
 CLOSE c_gbst_elm;
 IF rec_case.hangup_time IS NOT NULL THEN
 v_actl_phone_time := (rec_case.hangup_time - rec_case.creation_time) * 24 * 60 * 60;
 IF v_actl_phone_time IS NULL OR v_actl_phone_time < 0 THEN
 v_actl_phone_time := 0;
 END IF;
 ELSE
 v_actl_phone_time := 0;
 END IF;
 FOR c_subcase_rec IN c_subcase
 LOOP
 v_sub_actl_phone_time := v_sub_actl_phone_time + NVL(c_subcase_rec.actl_phone_time ,0);
 v_sub_calc_phone_time := v_sub_calc_phone_time + NVL(c_subcase_rec.calc_phone_time ,0);
 END LOOP;
 v_actl_phone_time := ROUND(v_actl_phone_time + v_sub_actl_phone_time);
 v_calc_phone_time := ROUND(v_actl_phone_time + v_sub_calc_phone_time);
 v_tot_actl_phone_time := ROUND(v_actl_phone_time);

 UPDATE table_condition
 SET condition = 4 ,
 title = 'Closed' ,
 s_title = 'CLOSED'
 WHERE objid = rec_condition.objid;

 -- if v_agent_resolution is not null then
 --
 -- LOG_NOTES(p_case_objid,
 -- p_user_objid,
 -- v_agent_resolution,
 -- 'Resolution',
 -- P_ERROR_NO,
 -- P_ERROR_STR);
 --
 -- End If;
 -- v_case_history := rec_case.case_history;
 -- v_case_history :=
 -- v_case_history
 -- || CHR (10)
 -- || '*** CASE CLOSE '
 -- || TO_CHAR (v_current_date, 'MM/DD/YYYY HH:MI:SS AM ')
 -- || v_user_login_name
 -- || ' FROM source "'
 -- || p_source
 -- || '"'
 -- || CHR (10)
 -- || '*** AGENT RESOLUTION *** '
 -- || CHR (10)
 -- || v_agent_resolution;

 UPDATE table_case
 SET case_currq2queue = NULL ,
 case_wip2wipbin = NULL ,
 case_owner2user = p_user_objid ,
 casests2gbst_elm = rec_case_sts_closed.elm_objid
 WHERE objid = rec_case.objid;

 UPDATE table_x_part_request
 --CR19655 Start KACOSTA 02/1/2012
 --SET x_status = DECODE(x_status, 'PENDING', 'CANCELLED', 'PROCESSED', 'CANCEL_REQUEST', 'ONHOLD', 'CANCELLED', x_status),
 SET x_status =
 CASE
 WHEN x_status = 'SHIPPED'
 THEN 'SHIPPED'
 WHEN x_status IN ('CANCEL_REQUEST' ,'PROCESSED')
 THEN 'CANCEL_REQUEST'
 ELSE 'CANCELLED'
 END ,
 --CR19655 End KACOSTA 02/1/2012
 x_last_update_stamp = SYSDATE
 WHERE request2case = rec_case.objid;

 dbms_output.put_line('Case record updated.');
 SELECT sa.seq('act_entry') INTO v_seq_act_entry FROM dual;
 v_addl_info := 'Status = Closed, Resolution Code =' || v_resolution_code || ', State = Open.';

 INSERT
 INTO table_act_entry
 (
 objid ,
 act_code ,
 entry_time ,
 addnl_info ,
 proxy ,
 removed ,
 focus_type ,
 focus_lowid ,
 entry_name2gbst_elm ,
 act_entry2case ,
 act_entry2user
 )
 VALUES
 (
 v_seq_act_entry ,
 rec_act_caseclose.rank ,
 v_current_date ,
 v_addl_info ,
 v_user_login_name ,
 0 ,
 0 ,
 0 ,
 rec_act_caseclose.elm_objid ,
 rec_case.objid ,
 p_user_objid
 );
 -- 04/10/03 SELECT SEQ_close_case.nextval + power(2,28) INTO v_seq_close_case FROM dual;
 SELECT sa.seq('close_case')
 INTO v_seq_close_case
 FROM dual;

 --disconnecting any previous records
 UPDATE table_close_case
 SET last_close2case = NULL
 WHERE last_close2case = p_case_objid;

 INSERT
 INTO table_close_case
 (
 objid ,
 close_date ,
 actl_phone_time ,
 calc_phone_time ,
 actl_rsrch_time ,
 calc_rsrch_time ,
 used_unit ,
 summary ,
 tot_actl_phone_time ,
 tot_actl_rsrch_time ,
 actl_bill_exp ,
 actl_nonbill ,
 calc_bill_exp ,
 calc_nonbill ,
 tot_actl_bill ,
 tot_actl_nonb ,
 bill_time ,
 nonbill_time ,
 previous_closed ,
 cls_old_stat2gbst_elm ,
 cls_new_stat2gbst_elm ,
 close_rsolut2gbst_elm --Obsolete: replaced by CLOSE_CASE2CASE_RESOL
 ,
 last_close2case ,
 closer2employee ,
 close_case2act_entry ,
 CLOSE_CASE2CASE_RESOL
 )
 VALUES
 (
 v_seq_close_case ,
 v_current_date ,
 v_actl_phone_time ,
 v_calc_phone_time ,
 0 ,
 0 ,
 0.000000 ,
 '' ,
 v_tot_actl_phone_time ,
 0 ,
 0.0 ,
 0.0 ,
 0.0 ,
 0.0 ,
 0.0 ,
 0.0 ,
 0 ,
 0 ,
 TO_DATE('01/01/1753 00:00:00' ,'MM/DD/YYYY HH24:MI:SS') ,
 rec_case.casests2gbst_elm ,
 rec_case_sts_closed.elm_objid ,
 NULL -- rec_resolution_code.elm_objid
 ,
 rec_case.objid ,
 p_user_objid ,
 v_seq_act_entry ,
 v_case_resol_objid
 );
COMMIT;
EXCEPTION
WHEN OTHERS THEN
 ROLLBACK;
 p_error_no := SQLCODE;
 p_error_str := SQLERRM;
END close_case;
--*************************************************************
PROCEDURE escalate
 (
 p_case_objid IN NUMBER ,
 p_user_objid IN NUMBER ,
 p_priority IN VARCHAR2 ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2
 )
IS
 new_notes_log_objid NUMBER := sa.seq('notes_log');
 CURSOR case_curs
 IS
 SELECT case_history ,
 casests2gbst_elm
 FROM table_case
 WHERE objid = p_case_objid;
 case_rec case_curs%ROWTYPE;
 CURSOR case_priority
 IS
 SELECT elm.objid
 FROM table_gbst_elm elm ,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Response Priority Code'
 AND elm.s_title = UPPER(p_priority);
 priority_rec case_priority%ROWTYPE;
 casehist VARCHAR2(5000);
BEGIN
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 OPEN case_curs;
 FETCH case_curs INTO case_rec;
 IF case_curs%NOTFOUND THEN
 case_rec.case_history := NULL;
 p_error_no := '1';
 p_error_str := 'Case not found';
 CLOSE case_curs;
 RETURN;
 END IF;
 CLOSE case_curs;
 OPEN case_priority;
 FETCH case_priority INTO priority_rec;
 IF case_priority%NOTFOUND THEN
 p_error_no := '17';
 p_error_str := 'Priority not found';
 CLOSE case_priority;
 RETURN;
 END IF;
 CLOSE case_priority;
 INSERT
 INTO table_act_entry
 (
 objid ,
 act_code ,
 entry_time ,
 addnl_info ,
 proxy ,
 removed ,
 focus_type ,
 focus_lowid ,
 entry_name2gbst_elm ,
 act_entry2case ,
 act_entry2user ,
 act_entry2notes_log
 )
 VALUES
 (
 sa.seq('act_entry') ,
 1700 ,
 SYSDATE ,
 'New Priority: '
 || p_priority ,
 NULL ,
 0 ,
 0 ,
 0 ,
 268435639 ,
 p_case_objid ,
 p_user_objid ,
 new_notes_log_objid
 );
 --casehist := case_rec.case_history ||CHR(10)||'*** ESCALATED '||TO_CHAR( sysdate , 'MM/DD/YYYY HH24:MI:SS')||' New Priority: '||P_PRIORITY;
 UPDATE table_case
 SET modify_stmp = SYSDATE ,
 respprty2gbst_elm = priority_rec.objid
 WHERE objid = p_case_objid;
 COMMIT;
EXCEPTION
WHEN OTHERS THEN
 p_error_no := SQLCODE;
 p_error_str := SQLERRM;
END;
PROCEDURE b2b_part_request_ship(
 ip_case_objid IN NUMBER ,
 ip_req_objid IN NUMBER ,
 ip_new_esn IN VARCHAR2 ,
 ip_tracking IN VARCHAR2 ,
 ip_user_objid IN NUMBER ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2 )
IS
 CURSOR login_c(userobjid IN VARCHAR)
 IS
 SELECT login_name FROM table_user WHERE objid = userobjid;
 rec_login login_c%ROWTYPE;
 CURSOR case_curs(c_objid IN NUMBER)
 IS
 SELECT * FROM table_case WHERE objid = c_objid;
 rec_case_c case_curs%ROWTYPE;
 CURSOR part_num_curs(newesn VARCHAR2)
 IS
 SELECT pi.objid ,
 pn.part_number ,
 pn.part_num2part_class class_objid ,
 pi.x_iccid ,
 pn.domain ,
 pn.x_technology
 FROM table_part_num pn ,
 table_mod_level ml ,
 table_part_inst pi
 WHERE pn.objid = part_info2part_num
 AND ml.objid = pi.n_part_inst2part_mod
 AND pi.n_part_inst2part_mod = ml.objid
 AND pi.part_serial_no = newesn;
 part_num_rec part_num_curs%ROWTYPE;
 --------CR13581
 CURSOR sales_order_curs(caseid VARCHAR2)
 IS
 SELECT so.* ,
 ba.bus_primary2contact ,
 wu.login_name
 FROM x_sales_orders so ,
 x_business_accounts ba ,
 table_web_user wu
 WHERE case_id_services = caseid
 AND ba.account_id = so.account_id
 AND wu.web_user2contact = ba.bus_primary2contact;
 sales_order_rec sales_order_curs%ROWTYPE;
 ---CR13581
 CURSOR sales_order_curs2(caseid VARCHAR2)
 IS
 SELECT so.* ,
 ba.bus_primary2contact ,
 wu.login_name
 FROM x_sales_orders so ,
 x_business_accounts ba ,
 table_web_user wu
 WHERE case_id_items = caseid
 AND ba.account_id = so.account_id
 AND wu.web_user2contact = ba.bus_primary2contact;
 sales_order_rec2 sales_order_curs2%ROWTYPE;
 CURSOR sales_order_serv_cur ( ip_order NUMBER ,ip_part VARCHAR2 )
 IS
 SELECT x_sales_order_services.rowid ,
 x_sales_order_services.*
 FROM x_sales_order_services
 WHERE order_id = ip_order
 AND part_serial_no IS NULL
 AND (part_number = ip_part
 OR part_number IN
 (SELECT msc.segment1
 FROM apps.bom_bill_of_materials_v@ofsprd bbm ,
 apps.bom_inventory_components_v@ofsprd bic ,
 apps.mtl_system_items_b@ofsprd msi ,
 apps.mtl_system_items_b@ofsprd msc ,
 apps.hr_all_organization_units@ofsprd hr
 WHERE bbm.common_bill_sequence_id = bic.bill_sequence_id
 AND disable_date IS NULL
 AND bbm.organization_id = msi.organization_id
 AND msi.inventory_item_id = bbm.assembly_item_id
 AND msc.inventory_item_id = bic.component_item_id
 AND msc.organization_id = 3
 AND hr.organization_id = bbm.organization_id
 AND hr.name = 'BP_IO'
 AND msi.segment1 = ip_part
 ));
 sales_order_serv_rec sales_order_serv_cur%ROWTYPE;
 -----CR13581
 CURSOR part_request_curs(req_objid NUMBER)
 IS
 SELECT * FROM table_x_part_request WHERE objid = req_objid;
 part_request_rec part_request_curs%ROWTYPE;
 CURSOR order_hdr_curs(caseid VARCHAR2)
 IS
 SELECT so.account_id ,
 so.order_id ,
 so.order_date ,
 ba.name ,
 ad.address ,
 ad.address_2 ,
 ad.city ,
 ad.state ,
 ad.zipcode ,
 co.phone
 FROM x_sales_orders so ,
 x_business_accounts ba ,
 table_contact co ,
 table_contact_role cr ,
 table_site si ,
 table_address ad
 WHERE (case_id_items = caseid
 OR case_id_services = caseid)
 AND ba.account_id = so.account_id
 AND ba.bus_primary2contact = co.objid
 AND cr.contact_role2contact = co.objid
 AND cr.contact_role2site = si.objid
 AND si.cust_primaddr2address = ad.objid; ---------CR13581 CURSOR CHANGED
 order_hdr_rec order_hdr_curs%ROWTYPE;
 ----------CR13581
 CURSOR order_items_cur(orderid NUMBER)
 IS
 SELECT line_type ,
 part_number ,
 quantity ,
 x_program_name
 FROM x_sales_order_items ,
 x_program_parameters
 WHERE order_id = orderid
 AND airtime_plan = objid(+);
 order_items_rec order_items_cur%ROWTYPE; -----CR13581
 strusername VARCHAR2(30);
 found_rec NUMBER := 0;
 shipped_qty NUMBER := 0;
 v_domain VARCHAR2(30);
 message_txt VARCHAR2(4000); ------------------------CR13581
 RESULT VARCHAR2(200);
 op_objid VARCHAR2(200);
 op_description VARCHAR2(200);
 op_script_text VARCHAR2(4000);
 op_publish_by VARCHAR2(200);
 op_publish_date DATE;
 op_sm_link VARCHAR2(200);
 order_dtl VARCHAR2(4000);
 to_email VARCHAR2(200); ---------------------------CR13581
 BEGIN
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 -- Validate User
 OPEN login_c(ip_user_objid);
 FETCH login_c INTO rec_login;
 IF login_c%NOTFOUND THEN
 CLOSE login_c; -----CR13581
 p_error_no := '4';
 p_error_str := 'User not found';
 CLOSE login_c;
 RETURN;
 ELSE
 -----CR13581
 CLOSE login_c;
 END IF; -----CR13581
 strusername := rec_login.login_name;
 -- Get Case Header
 OPEN case_curs(ip_case_objid);
 FETCH case_curs INTO rec_case_c;
 IF case_curs%NOTFOUND THEN
 p_error_no := '1';
 p_error_str := 'Case not found';
 CLOSE case_curs; --Fix OPEN_CURSORS
 RETURN;
 ELSE
 CLOSE case_curs;
 END IF;
 OPEN part_num_curs(ip_new_esn);
 FETCH part_num_curs INTO part_num_rec;
 IF part_num_curs%FOUND THEN
 CLOSE part_num_curs;
 ELSE
 CLOSE part_num_curs;
 p_error_no := '12';
 p_error_str := 'New ESN not found';
 RETURN;
 END IF;
 OPEN part_request_curs(ip_req_objid);
 FETCH part_request_curs INTO part_request_rec;
 CLOSE part_request_curs;
 v_domain := NVL(part_request_rec.x_part_num_domain ,'ACC'); -----CR13581
 OPEN sales_order_curs(rec_case_c.id_number); -----CR13581
 FETCH sales_order_curs INTO sales_order_rec;
 IF sales_order_curs%FOUND THEN
 CLOSE sales_order_curs;
 -----CR13581
 to_email := sales_order_rec.login_name;
 OPEN sales_order_serv_cur(sales_order_rec.order_id ,part_num_rec.part_number);
 FETCH sales_order_serv_cur INTO sales_order_serv_rec;
 IF sales_order_serv_cur%FOUND THEN
 -----CR13581
 UPDATE x_sales_order_services
 SET part_serial_no = ip_new_esn ,
 sim_serial_no = part_num_rec.x_iccid
 WHERE ROWID = sales_order_serv_rec.rowid; -----CR13581
 END IF;
 CLOSE sales_order_serv_cur; -----CR13581
 SELECT COUNT(*)
 INTO found_rec
 FROM x_bus_acc_esn
 WHERE account_id = sales_order_rec.account_id
 AND esn = ip_new_esn;
 IF found_rec = 0 THEN
 INSERT
 INTO x_bus_acc_esn
 (
 account_id ,
 order_id ,
 case_id ,
 esn ,
 returned ,
 refunded ,
 part_number ,
 domain
 )
 VALUES
 (
 sales_order_rec.account_id ,
 sales_order_rec.order_id ,
 rec_case_c.id_number ,
 ip_new_esn ,
 0 ,
 0 ,
 part_num_rec.part_number ,
 part_num_rec.domain
 );
 END IF;
 ---------CR13581
 ELSE
 CLOSE sales_order_curs;
 OPEN sales_order_curs2(rec_case_c.id_number);
 FETCH sales_order_curs2 INTO sales_order_rec2;
 IF sales_order_curs2%FOUND THEN
 to_email := sales_order_rec2.login_name;
 CLOSE sales_order_curs2;
 SELECT COUNT(*)
 INTO found_rec
 FROM x_bus_acc_esn
 WHERE account_id = sales_order_rec2.account_id
 AND esn = ip_new_esn;
 IF found_rec = 0 THEN
 INSERT
 INTO x_bus_acc_esn
 (
 account_id ,
 order_id ,
 case_id ,
 esn ,
 returned ,
 refunded ,
 part_number ,
 domain
 )
 VALUES
 (
 sales_order_rec2.account_id ,
 sales_order_rec2.order_id ,
 rec_case_c.id_number ,
 ip_new_esn ,
 0 ,
 0 ,
 part_num_rec.part_number ,
 part_num_rec.domain
 );
 BEGIN
 SELECT COUNT(*)
 INTO found_rec
 FROM table_x_contact_part_inst
 WHERE x_contact_part_inst2part_inst = part_num_rec.objid;
 IF found_rec = 0 THEN
 INSERT
 INTO table_x_contact_part_inst
 (
 objid ,
 x_contact_part_inst2contact ,
 x_contact_part_inst2part_inst ,
 x_esn_nick_name ,
 x_is_default ,
 x_transfer_flag ,
 x_verified
 )
 VALUES
 (
 sa.seq('x_contact_part_inst') ,
 sales_order_rec2.bus_primary2contact ,
 part_num_rec.objid ,
 NULL ,
 0 ,
 0 ,
 'Y'
 );
 END IF;
 EXCEPTION
 WHEN OTHERS THEN
 NULL;
 END;
 END IF;
 ELSE
 CLOSE sales_order_curs2; -----CR13581
 END IF;
 END IF;
 OPEN order_hdr_curs(rec_case_c.id_number);
 FETCH order_hdr_curs INTO order_hdr_rec;
 IF order_hdr_curs%FOUND THEN
 CLOSE order_hdr_curs;
 /* -----CR13581
 select count(*) -- No Pending Shipments for the Order
 into found_rec
 from table_x_part_request, table_case, x_sales_orders
 where request2case = table_case.objid
 and (id_number = nvl(case_id_items,'NA') or id_number = nvl(case_id_services,'NA'))
 and x_status in ('PROCESSED','PENDING')
 and order_id = order_hdr_rec.order_id
 and order_status = 'Pending Shipment';
 if found_rec=0 then -- No Pending Shipments for the Order
 update x_sales_orders
 set order_status = 'Completed',
 last_updated_by = 'B2B_PART_REQUEST_SHIP',
 last_update_date = sysdate
 where order_id = order_hdr_rec.order_id;
 end if;
 */
 -----CR13581
 SELECT COUNT(*) --Search for Tracking Number
 INTO found_rec
 FROM x_shipping_info
 WHERE order_id = order_hdr_rec.order_id
 AND tracking_no = ip_tracking;
 IF found_rec = 0 THEN
 --Insert Tracking Number and Notify Customer
 INSERT
 INTO x_shipping_info
 (
 order_id ,
 sender ,
 recipient ,
 status ,
 tracking_no
 )
 VALUES
 (
 order_hdr_rec.order_id ,
 part_request_rec.x_ff_center ,
 rec_case_c.alt_first_name
 || ' '
 || rec_case_c.alt_last_name ,
 'SHIPPED' ,
 ip_tracking
 );
 --------CR13581
 scripts_pkg.get_script_prc(ip_sourcesystem => 'WEBCSR' ,ip_brand_name => 'NET10' ,ip_script_type => 'BTBAC' ,ip_script_id => '7304' ,ip_language => 'ENGLISH' ,ip_carrier_id => NULL ,ip_part_class => NULL ,op_objid => op_objid ,op_description => op_description ,op_script_text => op_script_text ,op_publish_by => op_publish_by ,op_publish_date => op_publish_date ,op_sm_link => op_sm_link);
 message_txt := op_script_text;
 message_txt := REPLACE(message_txt ,'[first_name]' ,rec_case_c.alt_first_name);
 message_txt := REPLACE(message_txt ,'[last_name]' ,rec_case_c.alt_last_name);
 message_txt := REPLACE(message_txt ,'[order_id]' ,TO_CHAR(order_hdr_rec.order_id));
 message_txt := REPLACE(message_txt ,'[order_date]' ,TO_CHAR(order_hdr_rec.order_date ,'mm/dd/yyyy'));
 message_txt := REPLACE(message_txt ,'[tracking_no]' ,TO_CHAR(ip_tracking));
 message_txt := REPLACE(message_txt ,'[business_name]' ,order_hdr_rec.name);
 message_txt := REPLACE(message_txt ,'[business_address]' ,order_hdr_rec.address || ' ' || order_hdr_rec.address_2);
 message_txt := REPLACE(message_txt ,'[business_address2]' ,order_hdr_rec.city || ', ' || order_hdr_rec.state || ' ' || order_hdr_rec.zipcode);
 message_txt := REPLACE(message_txt ,'[business_phone]' ,order_hdr_rec.phone);
 message_txt := REPLACE(message_txt ,'[sysdate]' ,TO_CHAR(SYSDATE ,'mm/dd/yyyy'));
 order_dtl := '<table width="75%" border="1" cellspacing="0" cellpadding="0"><tr><td>Type</td><td>Part Number</td><td>Plan</td><td>Qty</td></tr>';
 FOR order_items_rec IN order_items_cur
 (
 order_hdr_rec.order_id
 )
 LOOP
 order_dtl := order_dtl || '<tr>';
 order_dtl := order_dtl || '<td>';
 order_dtl := order_dtl || TRIM(order_items_rec.line_type);
 order_dtl := order_dtl || '</td>';
 order_dtl := order_dtl || '<td>';
 order_dtl := order_dtl || TRIM(order_items_rec.part_number);
 order_dtl := order_dtl || '</td>';
 order_dtl := order_dtl || '<td>';
 order_dtl := order_dtl || TRIM(order_items_rec.x_program_name);
 order_dtl := order_dtl || '</td>';
 order_dtl := order_dtl || '<td>';
 order_dtl := order_dtl || TRIM(TO_CHAR(order_items_rec.quantity));
 order_dtl := order_dtl || '</td>';
 order_dtl := order_dtl || '</tr>';
 END LOOP;
 order_dtl := order_dtl || '</table>';
 message_txt := REPLACE(message_txt ,'[order_detail]' ,TRIM(order_dtl));
 send_mail(subject_txt => 'Order ' || TO_CHAR(order_hdr_rec.order_id) ,msg_from => 'noreply@tracfone.com' ,send_to => to_email ,message_txt => message_txt ,RESULT => RESULT);
 -----CR13581
 END IF;
 ELSE
 CLOSE order_hdr_curs;
 END IF;
 COMMIT;
 END;
PROCEDURE part_request_ship
 (
 strcaseobjid IN VARCHAR2 ,
 strnewesn IN VARCHAR2 ,
 strtracking IN VARCHAR2 ,
 struserobjid IN VARCHAR2 ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2
 )
AS
 --ST Bundles 3 Start
 CURSOR line_reserved_cur
 (
 esn VARCHAR2
 )
 IS
 SELECT *
 FROM table_part_inst
 WHERE part_to_esn2part_inst IN
 (SELECT objid
 FROM table_part_inst
 WHERE part_serial_no = esn
 AND x_domain = 'PHONES'
 )
 AND x_domain = 'LINES'
 AND x_part_inst_status IN ('37' ,'39');
 line_reserved_rec line_reserved_cur%ROWTYPE;
 CURSOR active_site_part_cur(esn VARCHAR2)
 IS
 SELECT *
 FROM table_site_part
 WHERE x_service_id = esn
 AND part_status IN ('Active' ,'CarrierPending');
 active_site_part_rec active_site_part_cur%ROWTYPE;
 -- ST Bundles 3 End
 CURSOR login_c(userobjid IN VARCHAR)
 IS
 SELECT login_name FROM table_user WHERE objid = userobjid;
 rec_login login_c%ROWTYPE;
 -- CR20451 | CR20854: Add TELCEL Brand
 --CURSOR case_curs(c_objid IN NUMBER) IS
 --SELECT *
 --FROM table_case
 --WHERE objid = c_objid;
 CURSOR case_curs(c_objid IN NUMBER)
 IS
 SELECT tc.* ,
 bo.org_id ,
 bo.org_flow
 FROM table_case tc ,
 table_bus_org bo
 WHERE UPPER(tc.case_type_lvl2) = bo.org_id(+)
 AND tc.objid = c_objid;
 rec_case_c case_curs%ROWTYPE;
 rec_fraud_case_c case_curs%ROWTYPE;
 CURSOR check_case_curs
 IS
 SELECT c.case_owner2user ,
 ge.s_title, c.x_case_type, c.title , c.x_esn -- CR39592 PMistry 03/24/2016 Added case type and title.
 FROM table_condition ge ,
 table_case c
 WHERE 1 = 1
 AND ge.objid = c.case_state2condition
 AND c.objid = strcaseobjid;
 check_case_rec check_case_curs%ROWTYPE;
 CURSOR exch_units_c ( new_part IN VARCHAR2 ,old_part IN VARCHAR2 )
 IS
 SELECT x_bonus_units ,
 x_bonus_days
 FROM table_x_class_exch_options
 WHERE (x_new_part_num = new_part
 OR x_used_part_num = new_part)
 AND source2part_class IN
 (SELECT part_num2part_class FROM table_part_num WHERE part_number = old_part
 )
 AND ROWNUM < 2;
 rec_exch_units exch_units_c%ROWTYPE;
 --Get case details
 CURSOR shipped_c
 IS
 SELECT objid
 FROM table_gbst_elm e
 WHERE title = 'Shipped'
 AND e.gbst_elm2gbst_lst =
 (SELECT objid FROM table_gbst_lst WHERE title = 'Open'
 );
 rec_shipped_c shipped_c%ROWTYPE;
 --Get ship Activity
 CURSOR ship_activity_c
 IS
 SELECT objid
 FROM table_gbst_elm e
 WHERE title = 'Ship'
 AND e.gbst_elm2gbst_lst =
 (SELECT objid FROM table_gbst_lst WHERE title = 'Activity Name'
 );
 rec_ship_activity_c ship_activity_c%ROWTYPE;
 --Get part request from the case
 --CR21208 Start Kacosta 06/28/2012
 --CURSOR part_request_c(case_objid VARCHAR2) IS
 -- SELECT *
 -- FROM table_x_part_request
 -- WHERE request2case = case_objid
 -- AND x_status IN ('PENDING'
 -- ,'PROCESSED');
 --
 -- Including CANCELLED and CANCEL_REQUEST part request
 -- Sort by insert date; process older part request first
 CURSOR part_request_c(case_objid VARCHAR2)
 IS
 SELECT NVL(NVL(xpr.x_part_num_domain ,tpn.domain) ,'ACC') x_part_num_domain ,
 xpr.x_part_serial_no ,
 xpr.objid ,
 xpr.x_repl_part_num ,
 xpr.x_quantity ,
 xpr.x_status ,
 xpr.request2case ,
 xpr.x_service_level ,
 xpr.x_problem ,
 xpr.x_date_process ,
 xpr.x_flag_migration ,
 xpr.x_insert_date ,
 xpr.x_shipping_method ,
 xpr.x_courier ,
 xpr.x_received_date ,
 xpr.x_ff_center ,
 xpr.x_action ,
 xpr.dev
 FROM table_x_part_request xpr
 LEFT OUTER JOIN table_part_num tpn
 ON TRIM(xpr.x_repl_part_num) = tpn.part_number
 WHERE xpr.request2case = case_objid
 AND xpr.x_status IN ('PENDING' ,'PROCESSED' ,'CANCELLED' ,'CANCEL_REQUEST')
 ORDER BY xpr.x_insert_date;
 --CR21208 End Kacosta 06/28/2012
 rec_part_request part_request_c%ROWTYPE;
 --Get the old esn
 CURSOR old_part_inst_c(p_esn VARCHAR2)
 IS
 SELECT * FROM table_part_inst
 WHERE part_serial_no = decode(substr(p_esn,-1),'R',substr(p_esn,1,length(p_esn)-1), p_esn)
 and x_domain = 'PHONES';
 rec_old_part_inst_c old_part_inst_c%ROWTYPE;
 --Get dealer for old esn
 CURSOR old_dealer_c(p_esn VARCHAR2)
 IS
 SELECT i.*
 FROM table_inv_bin i ,
 table_part_inst pi
 WHERE pi.part_serial_no = p_esn
 AND pi.part_inst2inv_bin = i.objid;
 rec_old_dealer old_dealer_c%ROWTYPE;
 --Get the new esn
 CURSOR new_part_inst_c(p_esn VARCHAR2)
 IS
 SELECT pi.* ,
 pn.x_technology,
 sa.GET_PARAM_BY_NAME_FUN(
 IP_PART_CLASS_NAME => pc.name,
 IP_PARAMETER => 'DEVICE LOCK STATE') as Device_Lock_State -- CR39592 PMistry 04/05/2016 Added part class in joing to get device lock state.
 FROM table_part_inst pi ,
 table_mod_level ml,
 table_part_num pn,
 table_part_class pc -- CR39592 PMistry 04/05/2016 Added part class in joing to get device lock state.
 WHERE pi.part_serial_no = p_esn
 AND pi.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid
 and pc.objid = pn.part_num2part_class;
 --AND x_DOMAIN = 'PHONES';
 rec_new_part_inst_c new_part_inst_c%ROWTYPE;
 --Get new esn part_num record
 CURSOR new_part_num_c(p_esn VARCHAR2)
 IS
 SELECT pn.* ,
 pc.name
 FROM table_mod_level m ,
 table_part_num pn ,
 table_part_inst pi ,
 table_part_class pc
 WHERE pi.part_serial_no = p_esn
 AND pi.n_part_inst2part_mod = m.objid
 AND m.part_info2part_num = pn.objid
 AND pn.part_num2part_class = pc.objid;
 rec_new_part_num_c new_part_num_c%ROWTYPE;
 --Get dealer for new esn
 CURSOR new_dealer_c(p_esn VARCHAR2)
 IS
 SELECT i.*
 FROM table_inv_bin i ,
 table_part_inst pi
 WHERE pi.part_serial_no = p_esn
 AND pi.part_inst2inv_bin = i.objid;
 rec_new_dealer new_dealer_c%ROWTYPE;
 --Get default dealer
 CURSOR default_dealer_c
 IS
 SELECT i.*
 FROM table_inv_bin i ,
 table_x_code_table c
 WHERE c.x_code_name = 'EXCHANGE_PARTNER'
 AND c.x_value = i.bin_name;
 rec_default_dealer default_dealer_c%ROWTYPE;
 strzip table_case.x_activation_zip%TYPE;
 --Validate that the new ESN matches the technology available in the zip code
 -- CWL CR10729 MERGED WITH PRODUCTION FOR BRAND_SEP
 --CURSOR part_num_c
 --IS
 --SELECT pn.part_number
 --FROM mtm_part_num14_x_frequency0 mtm, table_x_frequency fr,
 --table_part_num pn
 --WHERE pn.objid = mtm.part_num2x_frequency
 --AND fr.objid = x_frequency2part_num
 --AND (pn.x_technology, fr.x_frequency) IN (
 --SELECT DISTINCT DECODE (tab2.cdma_tech, NULL, DECODE (tab2.tdma_tech,
 --NULL, DECODE (tab2.gsm_tech, NULL, 'na', tab2.gsm_tech ), tdma_tech ),
 --tab2.cdma_tech ) technology,
 -- DECODE (tab2.frequency1, 0, DECODE (tab2.frequency2, 0, 'na', tab2.frequency2
 -- ), tab2.frequency1 ) frequency
 --FROM carrierpref cp, (
 -- SELECT DISTINCT b.state,
 -- b.county,
 -- b.carrier_id,
 -- b.SID,
 -- b.cdma_tech,
 -- b.tdma_tech,
 -- b.gsm_tech,
 -- b.frequency1,
 -- b.frequency2
 -- FROM npanxx2carrierzones b, (
 -- SELECT DISTINCT a.ZONE,
 -- a.st
 -- FROM carrierzones a
 -- WHERE a.zip = strzip) tab1
 -- WHERE b.ZONE = tab1.ZONE
 -- AND b.state = tab1.st) tab2
 --WHERE cp.county = tab2.county
 --AND cp.st = tab2.state
 --AND cp.carrier_id = tab2.carrier_id);
 -- CWL CR17029
 CURSOR part_num_c(c_part_number IN VARCHAR2)
 IS
 --cwl 5/22/09 --CR10729
 SELECT DISTINCT tab1.part_number
 FROM
 (SELECT DISTINCT pn.part_number ,
 pn.x_technology ,
 fr.x_frequency
 FROM table_x_frequency fr ,
 mtm_part_num14_x_frequency0 mtm ,
 table_part_num pn
 WHERE 1 = 1
 AND fr.objid = mtm.x_frequency2part_num
 AND mtm.part_num2x_frequency = pn.objid
 AND pn.part_number = c_part_number
 AND ROWNUM < 1000000
 ) tab1 ,
 (SELECT DISTINCT (
 CASE
 WHEN b.cdma_tech IS NOT NULL
 THEN 'CDMA'
 WHEN b.tdma_tech IS NOT NULL
 THEN 'TDMA'
 WHEN b.gsm_tech IS NOT NULL
 THEN 'GSM'
 ELSE 'na'
 END) technology ,
 (
 CASE
 WHEN NVL(b.frequency1 ,0) != 0
 THEN b.frequency1
 WHEN NVL(b.frequency2 ,0) != 0
 THEN b.frequency2
 ELSE 0
 END) frequency
 FROM npanxx2carrierzones b ,
 carrierzones a
 WHERE 1 = 1
 AND b.zone = a.zone
 AND b.state = a.st
 AND a.zip = strzip
 AND ROWNUM < 1000000
 ) tab2
 WHERE tab1.x_technology = tab2.technology
 AND tab1.x_frequency = tab2.frequency;
 --cwl 5/22/09
 rec_part_num_c part_num_c%ROWTYPE;
 --Check if ESN was previously activated
 CURSOR get_site_part_count_c(p_esn VARCHAR2)
 IS
 SELECT COUNT(*) cnt
 FROM table_site_part
 WHERE x_service_id = p_esn
 AND LOWER(part_status) <> 'obsolete';
 intcount INTEGER;
 --Get record from table_x_code_table for code type
 CURSOR get_code_table_c(p_code_no VARCHAR2)
 IS
 SELECT * FROM table_x_code_table WHERE x_code_number = p_code_no;
 rec_code_table_c get_code_table_c%ROWTYPE;
 CURSOR getactivesite(p_esn IN VARCHAR2)
 IS
 SELECT objid ,
 x_min
 FROM table_site_part
 WHERE part_status IN ('Active' ,'CarrierPending')
 AND x_service_id = p_esn;
 CURSOR checkmin
 IS
 SELECT COUNT(*)
 FROM npanxx2carrierzones nc ,
 (SELECT x_carrier_id
 FROM table_x_carrier carr ,
 table_part_inst line ,
 (SELECT x_min
 FROM table_site_part
 WHERE x_service_id = rec_case_c.x_esn
 AND part_status IN ('Active' ,'CarrierPending')
 ) tab5
 WHERE line.part_inst2carrier_mkt = carr.objid
 AND line.part_serial_no = tab5.x_min
 ) tab1 ,
 (SELECT prt_num.x_technology ,
 MAX(DECODE(f.x_frequency ,800 ,800 ,NULL)) x_frequency1 ,
 MAX(DECODE(f.x_frequency ,1900 ,1900 ,NULL)) x_frequency2
 FROM table_x_frequency f ,
 mtm_part_num14_x_frequency0 pf ,
 table_part_num prt_num ,
 table_mod_level ml ,
 table_part_inst pi
 WHERE pf.x_frequency2part_num = f.objid
 AND prt_num.objid = pf.part_num2x_frequency
 AND prt_num.objid = ml.part_info2part_num
 AND pi.n_part_inst2part_mod = ml.objid
 AND pi.part_serial_no = strnewesn
 GROUP BY prt_num.x_technology
 ) tab4
 WHERE tab1.x_carrier_id = nc.carrier_id
 AND tab4.x_technology IN (nc.tdma_tech ,nc.cdma_tech ,nc.gsm_tech)
 AND (nc.frequency1 IN (tab4.x_frequency1 ,tab4.x_frequency2)
 OR nc.frequency2 IN (tab4.x_frequency1 ,tab4.x_frequency2));
 rec_activesite getactivesite%ROWTYPE;
 --CR3373 - Starts
 CURSOR csrclosecase(c_objid NUMBER)
 IS
 SELECT *
 FROM table_close_case
 WHERE last_close2case = c_objid
 ORDER BY close_date DESC;
 recclosecase csrclosecase%ROWTYPE;
 CURSOR csrwebresol ( c_case_type VARCHAR2 ,c_case_title VARCHAR2 ,c_resolution VARCHAR2 )
 IS
 SELECT *
 FROM table_x_web_case_resolution
 WHERE x_case_type = c_case_type
 AND x_case_title = c_case_title
 AND x_case_status = 'Closed'
 AND x_resolution = c_resolution;
 CURSOR case_detail_c ( c_objid NUMBER ,param_name VARCHAR2 )
 IS
 SELECT x_value ,
 objid ,
 x_name
 FROM table_x_case_detail
 WHERE detail2case = c_objid
 AND x_name = param_name;
 CURSOR st_program(esn VARCHAR2)
 IS
 SELECT pe.*
 FROM x_program_enrolled pe ,
 x_program_parameters
 WHERE x_esn = esn
 AND pe.pgm_enroll2pgm_parameter = x_program_parameters.objid
 AND pe.x_enrollment_status = 'ENROLLED'
 AND x_is_recurring = 1;
 st_program_rec st_program%ROWTYPE;
 -----CR13581
 CURSOR bus_acc_esn_cur(esn VARCHAR2)
 IS
 SELECT table_x_contact_part_inst.*
 FROM table_x_contact_part_inst ,
 x_business_accounts ,
 table_part_inst
 WHERE x_contact_part_inst2contact = bus_primary2contact
 AND table_part_inst.objid = x_contact_part_inst2part_inst
 AND part_serial_no = esn;
 -----CR13581
 -- CR15363 Start KACOSTA 04/22/2011
 CURSOR get_x_case_conf_hdr_curs ( c_x_case_type table_x_case_conf_hdr.x_case_type%TYPE ,c_x_title table_x_case_conf_hdr.x_title%TYPE )
 IS
 SELECT cch.*
 FROM table_x_case_conf_hdr cch
 WHERE cch.x_case_type = c_x_case_type
 AND cch.x_title = c_x_title;
 --
 get_x_case_conf_hdr_rec get_x_case_conf_hdr_curs%ROWTYPE;
 --
 CURSOR get_old_part_num_curs(c_esn table_part_inst.part_serial_no%TYPE)
 IS
 SELECT tpn.x_technology ,
 tpc.name
 FROM table_part_class tpc ,
 table_part_num tpn ,
 table_mod_level tml ,
 table_part_inst tpi
 WHERE tpi.part_serial_no = c_esn
 AND tpi.n_part_inst2part_mod = tml.objid
 AND tml.part_info2part_num = tpn.objid
 AND tpn.part_num2part_class = tpc.objid;
 --
 get_old_part_num_rec get_old_part_num_curs%ROWTYPE;
 -- CR15363 End KACOSTA 04/22/2011
 bus_acc_esn_old_rec bus_acc_esn_cur%ROWTYPE;
 rec_case_detail case_detail_c%ROWTYPE;
 recwebresol csrwebresol%ROWTYPE;
 -- Start CR14033 PM Net10 Megacard phase 4
 CURSOR cur_old_esn_dtl(c_esn VARCHAR2)
 IS
 SELECT pi.part_serial_no ,
 bo.org_id ,
 pi.x_part_inst_status ,
 pn.part_number ,
 pn.x_technology ,
 pn.x_dll
 FROM table_part_inst pi ,
 table_mod_level ml ,
 table_part_num pn ,
 table_bus_org bo ,
 table_part_class pc
 WHERE 1 = 1
 AND ml.objid = pi.n_part_inst2part_mod
 AND pn.objid = ml.part_info2part_num
 AND bo.objid = pn.part_num2bus_org
 AND pc.objid = pn.part_num2part_class
 AND pi.part_serial_no = c_esn;
 rec_old_esn_dtl cur_old_esn_dtl%ROWTYPE;
 CURSOR cur_get_sp_detail(c_esn VARCHAR2)
 IS
 SELECT tsp.x_service_id ,
 tsp.x_expire_dt ,
 sp.*
 FROM x_service_plan_hist sph ,
 table_site_part tsp ,
 x_service_plan sp
 WHERE 1 = 1
 AND sph.plan_hist2site_part = tsp.objid
 AND sp.objid = sph.plan_hist2service_plan
 AND tsp.x_service_id = c_esn
 ORDER BY sph.x_start_date DESC;
 rec_get_sp_detail cur_get_sp_detail%ROWTYPE;
 -- End CR14033 PM Net10 Megacard phase 4
 --CR3373 - Ends
 --
 --CR20773 Start Kacosta 09/20/2012
 CURSOR check_if_has_airbilled_curs ( c_v_old_esn table_part_inst.part_serial_no%TYPE ,c_n_case_objid table_x_part_request.request2case%TYPE )
 IS
 SELECT ceo.x_airbil_part_number airbill_part_number
 FROM table_part_inst tpi
 JOIN table_mod_level tml
 ON tpi.n_part_inst2part_mod = tml.objid
 JOIN table_part_num tpn
 ON tml.part_info2part_num = tpn.objid
 JOIN table_x_class_exch_options ceo
 ON tpn.part_num2part_class = ceo.source2part_class
 WHERE tpi.part_serial_no = c_v_old_esn
 AND EXISTS
 (SELECT 1
 FROM table_x_part_request xpr
 WHERE xpr.request2case = c_n_case_objid
 AND xpr.x_repl_part_num = ceo.x_airbil_part_number
 );
 --
 check_if_has_airbilled_rec check_if_has_airbilled_curs%ROWTYPE;
 --CR20773 End Kacosta 09/20/2012
 --

 -- CR39592 Start PMistry 02/04/2016 Added 2 cursor to look for specific case.
 cursor case_conf_cur (c_param_name sa.table_x_parameters.x_param_name%TYPE) is
 select *
 from sa.table_x_case_conf_hdr
 where objid in (select x_param_value
 from sa.table_x_parameters
 where x_param_name = c_param_name ); --'ADFCRM_UNLOCK_BUYBACK_CASE_CONF');
 case_conf_rec case_conf_cur%rowtype;





 v_case_type varchar2(30);
 v_title varchar2(80);

 l_part_serial_domain varchar2(60);
 l_prog_class varchar2(30) := 'LIFELINE';
 l_enrollment varchar2(30) := 'ENROLLED';
 l_part_status varchar2(30) := 'Active';
 l_date DATE := to_date('11-FEB-2014' ,'DD-MON-YYYY');
 l_case_type varchar2(90);
 l_case_title varchar2(90);
 -- To check whether the esn is Safe link or not.
 cursor sl_enroll_cur (c_esn varchar2) is
 select 1
 from x_program_enrolled pe, x_program_parameters pgm, x_sl_currentvals slcur, table_site_part tsp
 where 1 = 1
 and pgm.objid = pe.pgm_enroll2pgm_parameter
 and slcur.x_current_esn = pe.x_esn
 and sysdate BETWEEN pgm.x_start_date AND pgm.x_end_date
 and pgm.x_prog_class = l_prog_class
 and pe.x_esn = c_esn
 and pe.x_enrollment_status = l_enrollment
 and tsp.x_service_id = pe.x_esn
 and tsp.part_status||'' = l_part_status
 and tsp.install_date > l_date;

 sl_enroll_rec sl_enroll_cur%rowtype;

 --Part Inst Cursor
 cursor part_inst_cur (v_esn varchar2) is
 select pi.x_part_inst2contact, bo.COLLECTN_STS gl_account, pi.objid pi_objid
 from sa.table_part_inst pi,
 sa.table_mod_level ml,
 sa.table_part_num pn,
 sa.table_bus_org bo
 where pi.part_serial_no = v_esn
 and pi.x_domain = 'PHONES'
 and PI.N_PART_INST2PART_MOD = ml.objid
 and ML.PART_INFO2PART_NUM = pn.objid
 and PN.PART_NUM2BUS_ORG = bo.objid;

 part_inst_rec part_inst_cur%rowtype;
 pi_copy_contact_rec part_inst_cur%rowtype;

 l_new_contact_id table_contact.objid%type;


 -- CR39592 End PMistry 02/04/2016


 icheckmin INT;
 bvalue VARCHAR2(10);
 bvalid BOOLEAN;
 bchangemodlevel BOOLEAN;
 boldpromofound BOOLEAN;
 bnewpromofound BOOLEAN;
 bdefaultdealerfound BOOLEAN;
 strhistory VARCHAR2(500);
 v_status VARCHAR2(1);
 v_message VARCHAR2(250);
 strstatus VARCHAR2(5);
 binserted BOOLEAN;
 strusername table_user.login_name%TYPE;
 v_return VARCHAR2(20);
 v_returnmsg VARCHAR2(300);
 actualunits NUMBER;
 temptitle VARCHAR2(20);
 tempesn VARCHAR2(20);
 tempobjid VARCHAR2(20);
 cnt NUMBER;
 intbypass NUMBER := 0;
 err_num NUMBER;
 err_desc VARCHAR2(1000);
 v_status_objid NUMBER;
 num_pend_req NUMBER := 0;
 fraud_units NUMBER := 0;
 v_phone_request BOOLEAN;
 v_old_site_part_objid NUMBER;
 v_active_esn VARCHAR2(30);
 v_active_min VARCHAR2(30);
 v_new_site_part_objid NUMBER;
 v_due_date DATE;
 v_case_dtl VARCHAR2(200);
 v_notes VARCHAR2(200);
 v_onholdcount NUMBER;
 v_st_program_objid NUMBER;
 v_pn_match NUMBER := 0; -- Part Number Match for Business Sales -----CR13581
 found_rec NUMBER;
 v_b2b_esn BOOLEAN;
 v_product_selection VARCHAR2(30);
 -- CR15363 Start KACOSTA 04/22/2011
 v_old_esn_product_selection table_x_part_class_values.x_param_value%TYPE;
 -- CR15363 End KACOSTA 04/22/2011
 v_st_exchange_failed BOOLEAN := TRUE;
 --CR21208 Start Kacosta 06/28/2012
 -- New flags to handle what how to update the case
 l_b_part_request_processed BOOLEAN := FALSE;
 l_b_has_part_request BOOLEAN := FALSE;
 l_v_procedure_step VARCHAR2(32767);
 --CR21208 End Kacosta 06/28/2012
 --CR21208 Start Kacosta 09/25/2012
 V_PRE_ACT_REPL_COUNT PLS_INTEGER := 0; ---ADDED FOR CR31107
 V_NO_SERVICE_TRANSFER PLS_INTEGER := 0; ---ADDED FOR PROJECT ARMOR
 v_max_objid NUMBER ; --CR38186
 uc_error_no number; -- CR41687
 uc_error_str varchar2(1000); -- CR41687
 v_case_min varchar2(30);
 v_case_zip varchar2(30);
 c_domain VARCHAR2(50);

 FUNCTION get_domain(
 p_serial_num IN VARCHAR2)
 RETURN table_part_num.domain%TYPE
 IS
 --
 l_v_domain table_part_num.domain%TYPE;
 --
 l_b_debug BOOLEAN := true;
 BEGIN

 l_v_procedure_step := 'Return ACC domain for dummy serial number';
 --
 if p_serial_num = '999999999' then
 return 'ACC';
 end if;

 l_v_procedure_step := 'Get domain for serial number';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --
 BEGIN
 --
 l_v_procedure_step := 'Checking if it is PHONES domain';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --
 SELECT DISTINCT 'PHONES'
 INTO l_v_domain
 FROM table_part_inst tpi
 WHERE tpi.part_serial_no = p_serial_num
 AND tpi.x_domain = 'PHONES';
 --
 EXCEPTION
 WHEN no_data_found THEN
 --
 NULL;
 --
 WHEN OTHERS THEN
 --
 RAISE;
 --
 END;
 --
 IF (l_v_domain IS NULL) THEN
 --
 BEGIN
 --
 l_v_procedure_step := 'Checking if it is SIM CARDS domain';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --
 SELECT DISTINCT 'SIM CARDS'
 INTO l_v_domain
 FROM table_x_sim_inv xsi
 WHERE xsi.x_sim_serial_no = p_serial_num;
 --
 EXCEPTION
 WHEN no_data_found THEN
 --
 NULL;
 --
 WHEN OTHERS THEN
 --
 RAISE;
 --
 END;
 --
 END IF;
 --
 IF (l_v_domain IS NULL) THEN
 --
 l_v_procedure_step := 'Assuming it is ACC domain';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --
 l_v_domain := 'ACC';
 --
 END IF;
 --
 RETURN l_v_domain;
 --
 END get_domain;
 --CR21208 Start Kacosta 09/25/2012
 BEGIN
 --CR21208 Start Kacosta 06/28/2012
 l_b_debug := TRUE;
 l_v_procedure_step := 'Start ship confirm process';
 l_part_serial_domain := get_domain(strnewesn);
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 dbms_output.put_line('strcaseobjid: ' || strcaseobjid);
 dbms_output.put_line('strnewesn : ' || strnewesn);
 dbms_output.put_line('strtracking : ' || strtracking);
 dbms_output.put_line('struserobjid: ' || struserobjid);
 END IF;
 --CR21208 End Kacosta 06/28/2012
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 v_phone_request := FALSE;
 -- Validate User
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get user information';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN login_c(struserobjid);
 FETCH login_c INTO rec_login;
 IF login_c%NOTFOUND THEN
 p_error_no := '4';
 p_error_str := 'User not found';
 CLOSE login_c;
 --CR21208 Start Kacosta 06/28/2012
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --CR21208 End Kacosta 06/28/2012
 RETURN;
 END IF;
 CLOSE login_c;
 strusername := rec_login.login_name;
 -- Find the Shipped status from GBST_ELM
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get "SHIPPED" status objid';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN shipped_c;
 FETCH shipped_c INTO rec_shipped_c;
 IF shipped_c%NOTFOUND THEN
 p_error_no := '10';
 p_error_str := 'gbst_elm record not found';
 CLOSE shipped_c;
 --CR21208 Start Kacosta 06/28/2012
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --CR21208 End Kacosta 06/28/2012
 RETURN;
 END IF;
 -- Find the Shipped Action from GBST_ELM
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get "SHIP" act entry objid';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN ship_activity_c;
 FETCH ship_activity_c INTO rec_ship_activity_c;
 IF ship_activity_c%NOTFOUND THEN
 p_error_no := '10';
 p_error_str := 'gbst_elm record not found';
 CLOSE ship_activity_c;
 --CR21208 Start Kacosta 06/28/2012
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --CR21208 End Kacosta 06/28/2012
 RETURN;
 END IF;
 CLOSE shipped_c;
 -- Get Case Header
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get case information';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN case_curs(strcaseobjid);
 FETCH case_curs INTO rec_case_c;
 v_case_min := rec_case_c.x_min;
 v_case_zip := rec_case_c.x_activation_zip;

 IF case_curs%NOTFOUND THEN
 p_error_no := '1';
 p_error_str := 'Case not found';
 CLOSE case_curs; --Fix OPEN_CURSORS
 --CR21208 Start Kacosta 06/28/2012
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --CR21208 End Kacosta 06/28/2012
 RETURN;
 END IF;
 --ADDED FOR CR31107 Start
 l_v_procedure_step := 'Get SL replacement phone information - Check if we have done pre-activation';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 SELECT COUNT(1)
 INTO V_PRE_ACT_REPL_COUNT
 FROM TABLE_X_CALL_TRANS CT
 WHERE X_SERVICE_ID = strnewesn
 AND upper(X_ACTION_TEXT) in('ACTIVATION','ACTSWEEPALL')-- for CR39868
 AND X_ACTION_TYPE = '1'
 AND X_TRANSACT_DATE > SYSDATE-30
 AND upper(X_SOURCESYSTEM) = 'BATCH'
 AND upper(X_REASON) = 'B_PREACTIVATION' ;
 --CR31107 End

 --ARMOR START Nguada 4/30/2015
 SELECT COUNT('1')
 INTO V_NO_SERVICE_TRANSFER
 FROM sa.TABLE_X_CASE_DETAIL
 WHERE DETAIL2CASE = strcaseobjid
 AND X_NAME = 'NO_SERVICE_TRANSFER';

 -- NOTES REGARDING THIS FUNCTION WITHIN THE FUNCTION ITSELF
 -- THE CODE case_dtl_nst_from_tech REMOVED FROM THIS PROCEDURE WAS REPLACED BY nap_check_passed
 --CR51022 WFM Exchange preactivation ,Insert NO_SERVICE_TRANSFER to block deactivation
 if not sa.clarify_case_pkg.nap_check_passed(ip_zip =>v_case_zip, ip_esn =>strnewesn, ip_min =>v_case_min) OR (l_part_serial_domain ='PHONES' AND NVL(rec_case_c.org_id,'X') = 'WFM') then

 merge into sa.table_x_case_detail
 using (select 1 from dual)
 on (detail2case = strcaseobjid
 and x_name = 'NO_SERVICE_TRANSFER')
 when not matched then
 insert (objid,x_name,x_value,detail2case)
 values (sa.seq('x_case_detail'),'NO_SERVICE_TRANSFER','',strcaseobjid);

 V_NO_SERVICE_TRANSFER := V_NO_SERVICE_TRANSFER+1;
 end if;

 V_PRE_ACT_REPL_COUNT:= V_PRE_ACT_REPL_COUNT+ V_NO_SERVICE_TRANSFER;
 --ARMOR END

 --CR20740 Start kacosta 05/04/2012
 -- Process refurbish ESNs
 ------------ADDED FOR CR31107----------
 IF V_PRE_ACT_REPL_COUNT = 0 THEN
 IF (UPPER(rec_case_c.x_esn) LIKE '%R') THEN
 --
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Processing a refurbished ESN';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 rec_case_c.x_esn := SUBSTR(rec_case_c.x_esn ,1 ,LENGTH(rec_case_c.x_esn) - 1);
 --
 END IF;
 END IF;-------------------ADDED FOR CR31107-------------
 --CR20740 End kacosta 05/04/2012
 CLOSE case_curs;
 --
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get case condition';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN check_case_curs;
 FETCH check_case_curs INTO check_case_rec;
 IF check_case_rec.s_title NOT IN ('OPEN' ,'OPEN-DISPATCH' ,'OPEN-REJECT' ,'OPEN-FORWARD') THEN
 --CR20740 Start kacosta 05/04/2012
 -- Process close ESNs
 -- CLOSE check_case_curs;
 -- p_error_no := '2';
 -- p_error_str := 'Case is not open';
 -- RETURN;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Reopening case; calling reopen_case';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 reopen_case(p_case_objid => strcaseobjid ,p_user_objid => struserobjid ,p_error_no => p_error_no ,p_error_str => p_error_str);
 --
 IF (p_error_no <> '0') THEN
 --
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 ROLLBACK;
 --CR20740 End kacosta 05/04/2012
 --CR21208 Start Kacosta 06/28/2012
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --CR21208 End Kacosta 06/28/2012
 RETURN;
 --
 END IF;
 --CR20740 End kacosta 05/04/2012
 END IF;
 CLOSE check_case_curs;
 --Get the old ESN record
 IF REC_CASE_C.TITLE <> 'Lifeline Shipment' -- Ramu : Pending to include Broadband title here
 AND rec_case_c.title <> 'SafeLink BroadBand Shipment' --CR23889 050313
 AND rec_case_c.title <> 'Business Sales Direct Shipment' AND rec_case_c.title <> 'Business Sales Service Shipment' THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get case ESN';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN old_part_inst_c(rec_case_c.x_esn);
 FETCH old_part_inst_c INTO rec_old_part_inst_c;
 IF old_part_inst_c%NOTFOUND THEN
 p_error_no := '11';
 p_error_str := 'Old ESN not found';
 CLOSE old_part_inst_c;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 ROLLBACK;
 --CR20740 End kacosta 05/04/2012
 --CR21208 Start Kacosta 06/28/2012
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --CR21208 End Kacosta 06/28/2012
 RETURN;
 END IF;
 CLOSE old_part_inst_c;
 END IF;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Set zip code variable';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 IF (rec_case_c.x_activation_zip IS NULL OR (LENGTH(rec_case_c.x_activation_zip) = 0)) THEN
 strzip := rec_case_c.alt_zipcode;
 ELSE
 strzip := rec_case_c.x_activation_zip;
 END IF;
 --PART REQUEST LOOP
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Executing part request loop';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 FOR rec_part_request IN part_request_c(strcaseobjid)
 LOOP
 --CR21208 Start Kacosta 09/25/2012
 v_max_objid :=NULL; --CR38186

 -- CR44850: added logic to fix ACC issues
 -- set the domain as null
 c_domain := NULL;
 -- get the domain of the new esn
 BEGIN
 SELECT 'PHONES'
 INTO c_domain
 FROM table_part_inst tpi
 WHERE tpi.part_serial_no = strnewesn
 and tpi.part_serial_no NOT IN ('99999999999')
 AND tpi.x_domain = 'PHONES';
 EXCEPTION
 WHEN no_data_found THEN
 BEGIN
 SELECT DISTINCT 'SIM CARDS'
 INTO c_domain
 FROM table_x_sim_inv
 WHERE x_sim_serial_no = strnewesn;
 EXCEPTION
 WHEN others THEN
 c_domain := 'ACC';
 END;
 WHEN others THEN
 c_domain := 'ACC';
 END;

 IF ( ( rec_part_request.x_part_num_domain IN ('PHONES','SIM CARDS') AND
 get_domain ( p_serial_num => strnewesn ) = rec_part_request.x_part_num_domain
 )
 OR
 ( rec_part_request.x_part_num_domain NOT IN ('PHONES','SIM CARDS') AND
 get_domain ( p_serial_num => strnewesn ) NOT IN ('PHONES','SIM CARDS')
 )
 -- CR44850: added logic to fix ACC issues
 OR ( rec_part_request.x_part_num_domain NOT IN ('PHONES', 'SIM CARDS') AND
 c_domain NOT IN ('PHONES', 'SIM CARDS')
 )
 )
 THEN
 --CR21208 End Kacosta 09/25/2012
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Case has part request; see if the part request should be processed';

 --CR38186
 begin
 select max(objid) into v_max_objid
 from table_x_part_request where request2case =rec_part_request.request2case AND x_part_num_domain=rec_part_request.x_part_num_domain
 and x_status IN ('PENDING' ,'PROCESSED');
 exception
 when others then
 v_max_objid :=null;
 end;

 --CR38186
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 -- Setting flag to handle the updating of case
 l_b_has_part_request := TRUE;
 --
 -- Business Sales Direct/Service Shipment cases functionality is not modified for CR21208
 -- Non Business Sales Direct/Service Shipment cases part request should only be processed
 -- if the X_PART_SERIAL_NO value is null
 IF (rec_case_c.title = 'Business Sales Direct Shipment' OR rec_case_c.title = 'Business Sales Service Shipment' OR rec_part_request.x_part_serial_no IS NULL) THEN
 l_v_procedure_step := 'Processing part request';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 num_pend_req := num_pend_req + 1;
 --PHONE REQUEST IF
 --VERIFY NEW ESN EXIST
 IF (rec_case_c.title = 'Business Sales Direct Shipment' OR rec_case_c.title = 'Business Sales Service Shipment') AND rec_part_request.x_part_num_domain IN ('PHONES' ,'REDEMPTION CARDS') THEN
 -----CR13581
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Processing Business Sales Direct/Service Shipment case part request; calling b2b_part_request_ship';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 b2b_part_request_ship(ip_case_objid => rec_case_c.objid ,ip_req_objid => rec_part_request.objid ,ip_new_esn => strnewesn ,ip_tracking => strtracking ,ip_user_objid => struserobjid ,p_error_no => p_error_no ,p_error_str => p_error_str);
 dbms_output.put_line(p_error_no); -----CR13581
 dbms_output.put_line(p_error_str); -----CR13581
 --CR21208 Start Kacosta 06/28/2012
 IF (p_error_no <> '0') THEN
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 END IF;
 --CR21208 End Kacosta 06/28/2012
 END IF;
 IF rec_part_request.x_part_num_domain IN ('PHONES' ,'REDEMPTION CARDS') THEN
 -----CR13581
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Processing phones or redemption cards part request';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 IF rec_part_request.x_part_num_domain = 'PHONES' THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Processing phones part request';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 v_phone_request := TRUE;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get shipped ESN information';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN new_part_inst_c(strnewesn);
 FETCH new_part_inst_c INTO rec_new_part_inst_c;
 IF new_part_inst_c%NOTFOUND THEN
 p_error_no := '12';
 p_error_str := 'New ESN not found';
 CLOSE new_part_inst_c;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 ROLLBACK;
 --CR20740 End kacosta 05/04/2012
 --CR21208 Start Kacosta 06/28/2012
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --CR21208 End Kacosta 06/28/2012
 RETURN;
 END IF;
 CLOSE new_part_inst_c;
 --
 -- CR19490 Start kacosta 05/01/2012
 IF get_x_case_conf_hdr_curs%ISOPEN THEN
 --
 CLOSE get_x_case_conf_hdr_curs;
 --
 END IF;
 --
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get case configuration information';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN get_x_case_conf_hdr_curs(c_x_case_type => rec_case_c.x_case_type ,c_x_title => rec_case_c.title);
 FETCH get_x_case_conf_hdr_curs INTO get_x_case_conf_hdr_rec;
 CLOSE get_x_case_conf_hdr_curs;
 --
 IF (get_x_case_conf_hdr_rec.x_warehouse = 1) THEN
 --
 IF case_detail_c%ISOPEN THEN
 --
 CLOSE case_detail_c;
 --
 END IF;
 --
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Case is warehouse case; get case EXCHANGE_COUNTER parameter values';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN case_detail_c(c_objid => rec_case_c.objid ,param_name => 'EXCHANGE_COUNTER');
 FETCH case_detail_c INTO rec_case_detail;
 CLOSE case_detail_c;
 --
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update shipped ESN exchange counter';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_part_inst
 SET part_bad_qty = NVL(TO_NUMBER(rec_case_detail.x_value) ,0)
 WHERE part_serial_no = rec_new_part_inst_c.part_serial_no;
 --
 END IF;
 -- CR19490 End kacosta 05/01/2012
 --
 END IF; -----CR13581
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get shipped part information';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN new_part_num_c(strnewesn);
 FETCH new_part_num_c INTO rec_new_part_num_c;
 --CR20740 Start kacosta 05/04/2012
 -- Check if new ESN part was found
 IF new_part_num_c%NOTFOUND THEN
 p_error_no := '12';
 p_error_str := 'New ESN not found';
 CLOSE new_part_num_c;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 ROLLBACK;
 --CR20740 End kacosta 05/04/2012
 --CR21208 Start Kacosta 06/28/2012
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --CR21208 End Kacosta 06/28/2012
 RETURN;
 END IF;
 --CR20740 End kacosta 05/04/2012
 CLOSE new_part_num_c; -----CR13581
 /*-- VERIFY TECHNOLOGY VS ZIP CODE
 Bvalid := False;
 close new_part_num_c;
 OPEN part_num_c(rec_new_part_num_c.part_number );
 FETCH part_num_c
 INTO rec_part_num_c;
 IF part_num_c%found
 Then
 bvalid := TRUE;
 END IF;
 CLOSE part_num_c;
 --cwl 5/22/09 CR10729
 /*
 FOR rec_part_num_c IN part_num_c
 LOOP
 IF rec_new_part_num_c.part_number = rec_part_num_c.part_number
 THEN
 bvalid := TRUE;
 END IF;
 END LOOP;
 --cwl 5/22/09 CR10729
 IF NOT bvalid
 THEN
 LOG_NOTES(strcaseobjid, struserobjid,
 'New ESN does not match Technology available at ZipCode',
 'Wrong Tech Shipped', P_ERROR_NO, P_ERROR_STR);
 --p_ERROR_NO := '13';
 --p_ERROR_STR := 'New ESN does not match Technology available at ZipCode';
 --RETURN;
 END IF;
 */
 --Get the old Dealer record -- If not Lifeline
 IF REC_CASE_C.TITLE <> 'Lifeline Shipment' AND rec_case_c.title <> 'SafeLink BroadBand Shipment' -- CR23889
 AND LENGTH(rec_case_c.x_esn) > 0 AND rec_part_request.x_part_num_domain = 'PHONES' ------ -----CR13581
 THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get case ESN inventory bin';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN old_dealer_c(rec_case_c.x_esn);
 FETCH old_dealer_c INTO REC_OLD_DEALER;
 -- IF old_dealer_c%NOTFOUND THEN
 -- CLOSE old_dealer_c;
 --ELSE
 IF old_dealer_c%FOUND THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update shipped ESN inventory bin';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_part_inst
 SET part_inst2inv_bin = rec_old_dealer.objid
 WHERE objid = rec_new_part_inst_c.objid;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 END IF;
 CLOSE old_dealer_c;
 --Get dealer for new ESN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get shipped ESN inventory bin';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN new_dealer_c(strnewesn);
 FETCH new_dealer_c INTO rec_new_dealer;
 IF new_dealer_c%NOTFOUND THEN
 CLOSE new_dealer_c;
 ELSE
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update case ESN inventory bin';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_part_inst
 SET part_inst2inv_bin = rec_new_dealer.objid
 WHERE objid = rec_old_part_inst_c.objid;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 END IF;
 CLOSE new_dealer_c;
 --CR20740 Start kacosta 05/04/2012
 -- Process for all replacement ESN statuses
 ----Check if the new ESN is valid for Exchange
 --IF rec_new_part_inst_c.x_part_inst_status NOT IN ('50'
 -- ,'150') THEN
 -- p_error_no := '14';
 -- p_error_str := 'This ESN is not valid for exchange, wrong ststus';
 -- RETURN;
 --END IF;
 --CR20740 End kacosta 05/04/2012
 END IF;
 -- End Lifeline exception
 END IF;
 -- ESN PHONE REQUEST PART
 IF rec_case_c.title = 'Business Sales Direct Shipment' OR -----CR13581
 rec_case_c.title = 'Business Sales Service Shipment' THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Updating part request for Business Sales Direct/Service Shipment';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 IF rec_part_request.x_repl_part_num = rec_new_part_num_c.part_number OR (rec_part_request.x_part_num_domain = 'SIM CARDS' AND strnewesn LIKE '9999%') THEN
 -- Part Numbers Match
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Part numbers match; check if need to create more part request';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 v_pn_match := 1; -----CR13581
 IF NVL(rec_part_request.x_quantity ,1) > 1 THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Quantity is more than one;create part request with status of SHIPPED';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 INSERT
 INTO table_x_part_request
 (
 objid ,
 dev ,
 x_action ,
 x_repl_part_num ,
 x_part_serial_no ,
 x_ff_center ,
 x_ship_date ,
 x_est_arrival_date ,
 x_received_date ,
 x_courier ,
 x_shipping_method ,
 x_tracking_no ,
 x_status ,
 x_part_num_domain ,
 x_insert_date ,
 x_last_update_stamp ,
 x_service_level ,
 x_flag_migration ,
 x_date_process ,
 x_problem ,
 request2case ,
 x_quantity
 )
 VALUES
 (
 sa.seq('x_part_request') ,
 rec_part_request.dev ,
 rec_part_request.x_action ,
 rec_part_request.x_repl_part_num ,
 strnewesn ,
 rec_part_request.x_ff_center ,
 SYSDATE ,
 arrival_date(NVL(rec_part_request.x_service_level ,10)) ,
 rec_part_request.x_received_date ,
--rec_part_request.x_courier , CR55591
 decode(sign(length(strtracking)-22),null,rec_part_request.x_courier,-1,'FEDEX','USPS'), --CR55591
 rec_part_request.x_shipping_method ,
 strtracking ,
 'SHIPPED' ,
 rec_part_request.x_part_num_domain ,
 rec_part_request.x_insert_date ,
 SYSDATE ,
 rec_part_request.x_service_level ,
 rec_part_request.x_flag_migration ,
 rec_part_request.x_date_process ,
 rec_part_request.x_problem ,
 rec_part_request.request2case ,
 1
 );
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update original part request quantity; decrease by one';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_x_part_request
 SET x_quantity = x_quantity - 1 ,
 x_tracking_no = NULL ,
 x_part_serial_no = NULL
 WHERE objid = rec_part_request.objid;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 ELSE
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update part request to SHIPPED Business Sales Direct/Service Shipment case';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_x_part_request
 SET x_part_serial_no = strnewesn , -----CR13581
 x_ship_date = SYSDATE ,
 x_est_arrival_date = arrival_date(NVL(rec_part_request.x_service_level ,10)) ,
 x_tracking_no = strtracking ,
 x_status = 'SHIPPED' ,
 x_last_update_stamp = SYSDATE,
 x_courier = decode(sign(length(strtracking)-22),null,x_courier,-1,'FEDEX','USPS') --CR55591
 WHERE objid = rec_part_request.objid;

 END IF;
 END IF;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Retrieve the number of part request for sales order';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 SELECT COUNT(*) -- No Pending Shipments for the Order
 INTO found_rec
 FROM table_x_part_request ,
 table_case ,
 x_sales_orders
 WHERE request2case = table_case.objid
 --and (id_number = nvl(case_id_items,'0') or id_number = nvl(case_id_services,'0'))
 AND id_number = NVL(case_id_items ,0)
 AND case_id_services IS NULL --No services
 AND x_status IN ('PROCESSED' ,'PENDING')
 AND order_id IN
 (SELECT order_id
 FROM table_x_case_detail ,
 x_sales_orders
 WHERE detail2case = rec_case_c.objid
 AND x_name = 'SALES_ORDER_ID'
 AND order_id = TO_NUMBER(NVL(x_value ,0))
 );
 IF found_rec = 0 AND rec_case_c.title = 'Business Sales Direct Shipment' THEN
 -- No Pending Shipments for the Order
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'No Pending Shipments for the Order; update sales order status to complete';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE x_sales_orders
 SET order_status = 'Completed' ,
 last_updated_by = 'B2B_PART_REQUEST_SHIP' ,
 last_update_date = SYSDATE
 WHERE NVL(case_id_items ,'0') = rec_case_c.id_number
 OR NVL(case_id_services ,'0') = rec_case_c.id_number;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 END IF;
 ELSE
 --UPDATE table_x_part_request SET x_part_serial_no = DECODE(rec_part_request.x_part_num_domain, 'PHONES', strnewesn, 'NA'), -----CR13581
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update non Business Sales Direct/Service Shipment case part request';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_x_part_request
 SET x_part_serial_no = strnewesn ,
 x_ship_date = SYSDATE ,
 x_est_arrival_date = arrival_date(NVL(rec_part_request.x_service_level ,10)) ,
 x_courier = decode(sign(length(strtracking)-22),null,x_courier,-1,'FEDEX','USPS'), --CR55591
 x_tracking_no = strtracking
 --CR21208 Start Kacosta 06/28/2012
 --,x_status = 'SHIPPED'
 -- if the status is not PENDING or PROCESSED
 -- then do not change the part request status
 ,
 x_status =
 CASE
 WHEN rec_part_request.x_status IN ('PENDING' ,'PROCESSED')
 THEN 'SHIPPED'
 ELSE x_status
 END
 --CR21208 End Kacosta 06/28/2012
 ,
 x_last_update_stamp = SYSDATE
 WHERE objid = rec_part_request.objid;
 --CR38186
 IF (v_max_objid IS NOT NULL AND rec_part_request.objid <> v_max_objid) THEN
 UPDATE table_x_part_request
 SET x_part_serial_no = strnewesn ,
 x_ship_date = SYSDATE ,
 x_est_arrival_date = arrival_date(NVL(rec_part_request.x_service_level ,10)) ,
 x_courier = decode(sign(length(strtracking)-22),null,x_courier,-1,'FEDEX','USPS'), --CR55591
 x_tracking_no = strtracking,
 x_status = 'SHIPPED',
 x_last_update_stamp = SYSDATE
 WHERE objid = v_max_objid;
 END IF;
 --CR38186

 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 --CR21208 Start Kacosta 06/28/2012
 -- Need to keep track once the part request has been processed
 -- for Non Business Sales Direct/Service Shipment cases only process one and only one part request
 l_b_part_request_processed := TRUE;
 --CR21208 End Kacosta 06/28/2012
 END IF;
 --CR21217 Start kacosta 08/31/2012
 IF (rec_part_request.x_part_num_domain = 'SIM CARDS') THEN
 --
 l_v_procedure_step := 'Update REPL_SIM_ID case parameter value';
 --
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --
 update_case_dtl(strcaseobjid ,struserobjid ,'REPL_SIM_ID||' || strnewesn ,p_error_no ,p_error_str);
 --
 IF (p_error_no <> '0') THEN
 --
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --
 END IF;
 --
 -- CR30026, CR30822 (Marry SIM to ESN)
 v_active_esn := NVL( get_case_detail(strcaseobjid,'ACTIVE_ESN'), rec_case_c.x_esn );
 BEGIN
 l_v_procedure_step := 'A SIM card is being shipped, marrying ACTIVE_ESN to SIM';
 --
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 UPDATE table_part_inst
 SET x_iccid = strnewesn --rec_part_request.x_part_serial_no
 WHERE part_serial_no = v_active_esn
 AND NOT EXISTS
 (SELECT 1
 FROM table_site_part sp
 WHERE sp.x_service_id = v_active_esn
 AND sp.part_status
 ||'' IN ('Active','CarrierPending')
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
 'sim married to esn b4 shipment',
 sysdate,
 'UPDATE table_part_inst SET x_iccid = '
 || rec_part_request.x_part_serial_no
 || 'WHERE part_serial_no = '
 || v_active_esn
 || ';',
 v_active_esn,
 'SA.clarify_case_pkg.part_request_ship'
 );
 EXCEPTION
 WHEN OTHERS THEN
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
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
 'sim marriage exception - ship confirm',
 sysdate,
 'UPDATE table_part_inst SET x_iccid = '
 || rec_part_request.x_part_serial_no
 || 'WHERE part_serial_no = '
 || v_active_esn
 || ';',
 v_active_esn,
 'SA.clarify_case_pkg.part_request_ship'
 );
 END;
 -- End of CR30026, CR30822 (Marry SIM to ESN)
 END IF;
 --CR21217 End kacosta 08/31/2012
 IF rec_case_c.title = 'Lifeline Shipment' AND rec_part_request.x_part_num_domain = 'PHONES' THEN ---CR23889 not inlcuded because we don't want overwrite ESN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update Lifeline Shipment case if part request is for a phone';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_case
 SET x_esn = strnewesn ,
 x_model = SUBSTR(rec_new_part_num_c.part_number ,1 ,20) ,
 x_phone_model = SUBSTR(rec_new_part_num_c.description ,1 ,30)
 WHERE objid = strcaseobjid;
 END IF;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 --CR21208 Start Kacosta 06/28/2012
 -- For Non Business Sales Direct/Service Shipment cases only process one and only one part request
 -- Exiting loop
 IF l_b_part_request_processed THEN
 --
 EXIT;
 --
 END IF;
 END IF;
 --CR21208 End Kacosta 06/28/2012
 --CR21208 Start Kacosta 09/25/2012
 END IF;
 --CR21208 End Kacosta 09/25/2012
 --
 END LOOP;
 -----CR13581
 IF (rec_case_c.title = 'Business Sales Direct Shipment' OR rec_case_c.title = 'Business Sales Service Shipment') AND v_pn_match = 0 THEN
 -- Part Number Missmatch, Business Sales
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Business Sales Direct/Service Shipment case part number mismatch; create new part request';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 INSERT
 INTO table_x_part_request
 (
 objid ,
 dev ,
 x_action ,
 x_repl_part_num ,
 x_part_serial_no ,
 x_ff_center ,
 x_ship_date ,
 x_est_arrival_date ,
 x_received_date ,
 x_courier ,
 x_shipping_method ,
 x_tracking_no ,
 x_status ,
 x_part_num_domain ,
 x_insert_date ,
 x_last_update_stamp ,
 x_service_level ,
 x_flag_migration ,
 x_date_process ,
 x_problem ,
 request2case ,
 x_quantity
 )
 VALUES
 (
 sa.seq('x_part_request') ,
 0 ,
 'SHIP' ,
 rec_new_part_num_c.part_number ,
 strnewesn ,
 NULL ,
 SYSDATE ,
 NULL ,
 NULL ,
 NULL ,
 NULL ,
 strtracking ,
 'SHIPPED' ,
 rec_new_part_num_c.domain ,
 SYSDATE ,
 SYSDATE ,
 NULL ,
 NULL ,
 NULL ,
 'MISSMATCH PART NUMBER' ,
 strcaseobjid ,
 1
 );
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 END IF; -----CR13581
 -- END PART REQUEST LOOP
 -- Add New ESN to Business Account if Applicable -----CR13581
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get business account contact information';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN bus_acc_esn_cur(rec_case_c.x_esn);
 FETCH bus_acc_esn_cur INTO bus_acc_esn_old_rec;
 IF bus_acc_esn_cur%FOUND THEN
 BEGIN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Business account contact found; associate new ESN with business account contact';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 INSERT
 INTO table_x_contact_part_inst
 (
 objid ,
 x_contact_part_inst2contact ,
 x_contact_part_inst2part_inst ,
 x_esn_nick_name ,
 x_is_default ,
 x_transfer_flag ,
 x_verified
 )
 VALUES
 (
 sa.seq('x_contact_part_inst') ,
 bus_acc_esn_old_rec.x_contact_part_inst2contact ,
 rec_new_part_inst_c.objid ,
 NULL ,
 0 ,
 0 ,
 'Y'
 );
 EXCEPTION
 WHEN OTHERS THEN
 NULL;
 END;
 END IF;
 CLOSE bus_acc_esn_cur; -----CR13581
 dbms_output.put_line('num_pend_req= ' || num_pend_req);
 --
 --CR21208 Start Kacosta 06/29/2012
 -- Business Sales Direct/Service Shipment cases functionality will not change for CR21208
 IF (rec_case_c.title = 'Business Sales Direct Shipment' OR rec_case_c.title = 'Business Sales Service Shipment') THEN
 l_v_procedure_step := 'Business Sales Direct/Service Shipment case; start update case functionality';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/29/2012
 --
 IF num_pend_req > 0 THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Business Sales Direct/Service Shipment case part request processed; insert record into act entry';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 INSERT
 INTO table_act_entry
 (
 objid ,
 act_code ,
 entry_time ,
 addnl_info ,
 act_entry2case ,
 act_entry2user ,
 entry_name2gbst_elm
 )
 VALUES
 (
 seq('act_entry') ,
 '1500' ,
 SYSDATE ,
 'Part Request process - New Parts Linked and Shipped' ,
 strcaseobjid ,
 struserobjid ,
 rec_ship_activity_c.objid
 );
 strhistory := ' Part Request Shipped / ESN: ' || NVL(strnewesn ,'NA') || ' / Tracking Number : ' || strtracking;
 dbms_output.put_line('Before update status ');
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Business Sales Direct/Service Shipment update case to Shipped; calling SA.clarify_case_pkg.update_status';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 sa.clarify_case_pkg.update_status(strcaseobjid ,struserobjid ,'Shipped' ,strhistory ,p_error_no ,p_error_str);
 IF p_error_no <> '0' THEN
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 ROLLBACK;
 --CR20740 End kacosta 05/04/2012
 --CR21208 Start Kacosta 06/28/2012
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --CR21208 End Kacosta 06/28/2012
 RETURN;
 END IF;
 dbms_output.put_line('After update status ');
 ELSE
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Business Sales Direct/Service Shipment case part request was not processed; raise error';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 p_error_no := '15';
 --CR20740 Start kacosta 05/04/2012
 -- New error description
 --p_error_str := 'Case has no pending part request or already processed';
 p_error_str := 'X Case has no pending part request';
 --CR20740 End kacosta 05/04/2012
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 ROLLBACK;
 --CR20740 End kacosta 05/04/2012
 --CR21208 Start Kacosta 06/28/2012
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --CR21208 End Kacosta 06/28/2012
 RETURN;
 END IF;
 --CR21208 Start Kacosta 06/29/2012
 --New update case funtionaliy for non Business Sales Direct/Service Shipment cases
 ELSE
 --
 l_v_procedure_step := 'Non Business Sales Direct/Service Shipment case; start update case functionality';
 --
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --
 IF l_b_has_part_request THEN
 --
 IF l_b_part_request_processed THEN
 --
 l_v_procedure_step := 'Non Business Sales Direct/Service Shipment case had part request and processed';
 --
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --
 strhistory := ' Part Request Shipped / ESN: ' || NVL(strnewesn ,'NA') || ' / Tracking Number : ' || strtracking;
 --
 ELSE
 --
 l_v_procedure_step := 'Non Business Sales Direct/Service Shipment case had part request and NOT processed';
 --
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --
 strhistory := ' Part Request Shipped / ESN: / Tracking Number : ';
 --
 END IF;
 --
 l_v_procedure_step := 'Calling SA.clarify_case_pkg.update_status to update case status to Shipped';
 --
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --
 sa.clarify_case_pkg.update_status(strcaseobjid ,struserobjid ,'Shipped' ,strhistory ,p_error_no ,p_error_str);
 --
 IF p_error_no <> '0' THEN
 --
 ROLLBACK;
 --
 dbms_output.put_line('Failure step : ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --
 RETURN;
 --
 END IF;
 --
 IF l_b_part_request_processed THEN
 --
 l_v_procedure_step := 'Non Business Sales Direct/Service Shipment case part request processed; insert act entry record';
 --
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --
 INSERT
 INTO table_act_entry
 (
 objid ,
 act_code ,
 entry_time ,
 addnl_info ,
 act_entry2case ,
 act_entry2user ,
 entry_name2gbst_elm
 )
 VALUES
 (
 seq('act_entry') ,
 '1500' ,
 SYSDATE ,
 'Part Request process - New Parts Linked and Shipped' ,
 strcaseobjid ,
 struserobjid ,
 rec_ship_activity_c.objid
 );
 --
 ELSE
 --
 l_v_procedure_step := 'Non Business Sales Direct/Service Shipment case part request was not processed although case was set to shipped; return error';
 --
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --
 p_error_no := '15';
 p_error_str := 'Y Case has no pending part request';
 --
 ROLLBACK;
 --
 dbms_output.put_line('Failure step : ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --
 RETURN;
 --
 END IF;
 --
 ELSE
 --
 l_v_procedure_step := 'Non Business Sales Direct/Service Shipment case does not have any pending part request; return error';
 --
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --
 p_error_no := '15';
 p_error_str := 'Z Case has no pending part request';
 --
 ROLLBACK;
 --
 dbms_output.put_line('Failure step : ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 --
 RETURN;
 --
 END IF;
 --
 END IF;
 --CR21208 End Kacosta 06/29/2012
 --If we are shipping a new phone
 IF v_phone_request THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get ACTIVE_ESN case parameter value';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 v_active_esn := get_case_detail(strcaseobjid ,'ACTIVE_ESN');
 IF v_active_esn IS NULL THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update ACTIVE_ESN case parameter value';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 update_case_dtl(strcaseobjid ,struserobjid ,'ACTIVE_ESN||' || rec_case_c.x_esn ,p_error_no ,p_error_str);
 --CR21208 Start Kacosta 06/28/2012
 IF (p_error_no <> '0') THEN
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 END IF;
 --CR21208 End Kacosta 06/28/2012
 v_active_esn := rec_case_c.x_esn;
 END IF;
 IF rec_case_c.title <> 'Lifeline Shipment' AND rec_case_c.title <> 'SafeLink BroadBand Shipment' --CR23889
 AND rec_case_c.title <> 'Business Sales Direct Shipment' AND rec_case_c.title <> 'Business Sales Service Shipment' THEN
 --CR21208 Start Kacosta 06/28/2012
 IF V_PRE_ACT_REPL_COUNT = 0 THEN--------------Added For CR31107
 l_v_procedure_step := 'Update shipped ESN warranty end date';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_part_inst
 SET warr_end_date =
 (SELECT warr_end_date
 FROM table_part_inst
 WHERE part_serial_no = v_active_esn
 )
 WHERE objid = rec_new_part_inst_c.objid;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update case ESN warranty end date';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_part_inst
 SET warr_end_date = SYSDATE
 WHERE part_serial_no = v_active_esn;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 end if;----added for cr31107
 END IF;
 -- CR20451 | CR20854: Add TELCEL Brand
 -- IF NVL(rec_case_c.case_type_lvl2,'NULL') = 'STRAIGHT_TALK' THEN
 --CR20773 Start Kacosta 09/20/2012
 --IF NVL(rec_case_c.org_flow
 -- ,'NULL') = '3' THEN
 IF check_if_has_airbilled_curs%ISOPEN THEN
 --
 CLOSE check_if_has_airbilled_curs;
 --
 END IF;
 --
 OPEN check_if_has_airbilled_curs(c_v_old_esn => v_active_esn ,c_n_case_objid => rec_case_c.objid);
 FETCH check_if_has_airbilled_curs INTO check_if_has_airbilled_rec;
 CLOSE check_if_has_airbilled_curs;
 --
 IF (
 NVL(rec_case_c.org_flow,'NULL') = '3'
 OR (NVL(rec_case_c.org_flow,'NULL') = '2'
 AND check_if_has_airbilled_rec.airbill_part_number IS NOT NULL
 )
 OR (NVL(rec_case_c.org_flow ,'NULL') = '1'
 AND device_util_pkg.get_smartphone_fun(rec_new_part_inst_c.part_serial_no)>= 0 -- CR30301 Any TF with Airbill is considered eligible for preactivation
 AND check_if_has_airbilled_rec.airbill_part_number IS NOT NULL
 )-- CR25986 Post imp TF Surepay
 ) THEN
 --CR20773 End Kacosta 09/20/2012
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Shipped ESN is a Straight Talk ESN; calling st_exchange';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --- begin CR22320
 OPEN cur_get_sp_detail(rec_old_part_inst_c.part_serial_no);
 FETCH cur_get_sp_detail INTO rec_get_sp_detail;
 CLOSE cur_get_sp_detail;
 OPEN case_detail_c(rec_case_c.objid,'SERVICE_DAYS');
 FETCH case_detail_c INTO rec_case_detail;
 IF case_detail_c%FOUND THEN
 l_v_procedure_step := 'Update service days case parameter value based on the service plan';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 UPDATE table_x_case_detail
 SET x_value = TRUNC(rec_get_sp_detail.x_expire_dt) - TRUNC(SYSDATE)
 WHERE objid = rec_case_detail.objid;
 ELSE
 l_v_procedure_step := 'Insert service days case parameter value based on the service plan';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 INSERT
 INTO table_x_case_detail
 (
 objid ,
 x_name ,
 x_value ,
 detail2case
 )
 VALUES
 (
 sa.seq('x_case_detail') ,
 'SERVICE_DAYS' ,
 TRUNC(rec_get_sp_detail.x_expire_dt) - TRUNC(SYSDATE) ,
 rec_case_c.objid
 );
 END IF;
 CLOSE case_detail_c;
 --END IF;
 l_v_procedure_step := 'Calling service_deactivation.deactservice to deactivate case ESN';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 -- End CR22320
 --CR21208 End Kacosta 06/28/2012
 IF V_PRE_ACT_REPL_COUNT = 0 THEN ---ADDED FOR CR31107
 l_v_procedure_step := 'Calling St_exchange for the case'; --22621
 IF l_b_debug THEN --22621
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM')); ---22621
 END IF; ---ADDED FOR CR31107
 END IF; --22621
 st_exchange(rec_case_c.objid ,v_active_esn ,rec_new_part_inst_c.part_serial_no ,rec_new_part_inst_c.x_technology ,rec_new_part_inst_c.x_iccid ,strzip ,struserobjid ,p_error_no ,p_error_str);
 dbms_output.put_line('Return values from st-exchange : ' || p_error_no ||p_error_str);
 IF p_error_no = '0' THEN
 v_st_exchange_failed := FALSE;
 ELSE
 --CR21208 Start Kacosta 06/28/2012
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 l_v_procedure_step := 'Calling log_notes to log ST_EXCHANGE error';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 log_notes(strcaseobjid ,struserobjid ,p_error_no || ' ' || p_error_str ,'st_exchange result' ,p_error_no ,p_error_str);
 --CR21208 Start Kacosta 06/28/2012
 IF (p_error_no <> '0') THEN
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 END IF;
 --CR21208 End Kacosta 06/28/2012
 v_st_exchange_failed := TRUE;
 END IF;

 --CR51022 Skip contact and card transfer for new esn to enable upgrade for WFM
 IF NVL(rec_case_c.org_id,'X') <> 'WFM' THEN
 -- Replace old ESN by new ESN in the account.
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Delete all shipped ESN contact association from many to many table (KACOSTA: I do not understand)';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 DELETE
 FROM table_x_contact_part_inst
 WHERE x_contact_part_inst2part_inst = rec_new_part_inst_c.objid;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Associate shipped ESN with case ESN contact in many to many table';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_x_contact_part_inst
 SET x_contact_part_inst2part_inst = rec_new_part_inst_c.objid ,
 x_esn_nick_name = rec_new_part_num_c.part_number
 WHERE x_contact_part_inst2part_inst IN
 (SELECT objid
 FROM table_part_inst
 WHERE part_serial_no = v_active_esn
 AND x_domain = 'PHONES'
 );
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Associate case ESN redemption cards with shipped ESN';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_part_inst
 SET part_to_esn2part_inst = rec_new_part_inst_c.objid
 WHERE part_to_esn2part_inst =
 (SELECT objid
 FROM table_part_inst
 WHERE part_serial_no = v_active_esn
 AND x_domain = 'PHONES'
 )
 AND x_domain = 'REDEMPTION CARDS'
 AND x_part_inst_status = '400';
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 END IF; -- CR51022 skip contact and cards transfer
 END IF;
 -- CR20451 | CR20854: Add TELCEL Brand
 -- IF NVL(rec_case_c.case_type_lvl2,'NULL') <> 'STRAIGHT_TALK'
 IF NVL(rec_case_c.org_flow ,'NULL') <> '3' OR v_st_exchange_failed THEN
 -- CASE ESN IS ACTIVE
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'If shipped ESN is not Staight Talk or Straight Talk exchang failed get case ESN active site part information';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN getactivesite(NVL(get_case_detail(strcaseobjid ,'ACTIVE_ESN') ,rec_old_part_inst_c.part_serial_no));
 FETCH getactivesite INTO rec_activesite;
 IF getactivesite%FOUND THEN
 CLOSE getactivesite;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Executing checkmin cursor';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN checkmin;
 FETCH checkmin INTO icheckmin;
 CLOSE checkmin;
 IF icheckmin > 0 THEN
 bvalue := 'true';
 intbypass := 2;
 ELSE
 bvalue := 'false';
 intbypass := 0;
 END IF;
 -- Start CR14033 PM Net10 Megacard phase 4
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get case ESN part information';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN cur_old_esn_dtl(rec_old_part_inst_c.part_serial_no);
 FETCH cur_old_esn_dtl INTO rec_old_esn_dtl;
 CLOSE cur_old_esn_dtl;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get service plan information';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN cur_get_sp_detail(rec_old_part_inst_c.part_serial_no);
 FETCH cur_get_sp_detail INTO rec_get_sp_detail;
 IF rec_old_esn_dtl.x_part_inst_status NOT IN ('54' ,'51') AND cur_get_sp_detail%FOUND AND rec_get_sp_detail.mkt_name IN ('Net10 Mega Card' ,'Net10 Unlimited ILD' -- CR23110 pguthikonda 01/15/2012
 ,'Net10 Mega Card 750 Minutes') THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get service plan case parameter value';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN case_detail_c(rec_case_c.objid ,'SERVICE_PLAN');
 FETCH case_detail_c INTO rec_case_detail;
 IF case_detail_c%FOUND THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update service plan case parameter value with service plan objid';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_x_case_detail
 SET x_value = rec_get_sp_detail.objid
 WHERE objid = rec_case_detail.objid;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 ELSE
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Insert service plan case parameter value with service plan objid';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 INSERT
 INTO table_x_case_detail
 (
 objid ,
 x_name ,
 x_value ,
 detail2case
 )
 VALUES
 (
 sa.seq('x_case_detail') ,
 'SERVICE_PLAN' ,
 rec_get_sp_detail.mkt_name ,
 rec_case_c.objid
 );
 END IF;
 CLOSE case_detail_c;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get service plan id case parameter value';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN case_detail_c(rec_case_c.objid ,'SERVICE_PLAN_ID');
 FETCH case_detail_c INTO rec_case_detail;
 IF case_detail_c%FOUND THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update service plan id case parameter value with service plan objid';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_x_case_detail
 SET x_value = rec_get_sp_detail.objid
 WHERE objid = rec_case_detail.objid;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 ELSE
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Insert service plan id case parameter value with service plan objid';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 INSERT
 INTO table_x_case_detail
 (
 objid ,
 x_name ,
 x_value ,
 detail2case
 )
 VALUES
 (
 sa.seq('x_case_detail') ,
 'SERVICE_PLAN_ID' ,
 rec_get_sp_detail.objid ,
 rec_case_c.objid
 );
 END IF;
 CLOSE case_detail_c;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get service days case parameter value';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN case_detail_c(rec_case_c.objid ,'SERVICE_DAYS');
 FETCH case_detail_c INTO rec_case_detail;
 IF case_detail_c%FOUND THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update service days case parameter value based on the service plan';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_x_case_detail
 SET x_value = TRUNC(rec_get_sp_detail.x_expire_dt) - TRUNC(SYSDATE)
 WHERE objid = rec_case_detail.objid;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 ELSE
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Insert service days case parameter value based on the service plan';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 INSERT
 INTO table_x_case_detail
 (
 objid ,
 x_name ,
 x_value ,
 detail2case
 )
 VALUES
 (
 sa.seq('x_case_detail') ,
 'SERVICE_DAYS' ,
 TRUNC(rec_get_sp_detail.x_expire_dt) - TRUNC(SYSDATE) ,
 rec_case_c.objid
 );
 END IF;
 CLOSE case_detail_c;
 -- CR22198 BEGIN pguthikonda 01/16/2013
 ELSIF NVL(rec_case_c.org_id,'NULL') = 'NET10' AND rec_old_esn_dtl.x_part_inst_status NOT IN ('54','51') AND cur_get_sp_detail%FOUND THEN
 l_v_procedure_step := 'Get service days case parameter value';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 OPEN case_detail_c(rec_case_c.objid,'SERVICE_DAYS');
 FETCH case_detail_c INTO rec_case_detail;
 IF case_detail_c%FOUND THEN
 l_v_procedure_step := 'Update service days case parameter value based on the service plan';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 UPDATE table_x_case_detail
 SET x_value = TRUNC(rec_get_sp_detail.x_expire_dt) - TRUNC(SYSDATE)
 WHERE objid = rec_case_detail.objid;
 ELSE
 l_v_procedure_step := 'Insert service days case parameter value based on the service plan';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 INSERT
 INTO table_x_case_detail
 (
 objid ,
 x_name ,
 x_value ,
 detail2case
 )
 VALUES
 (
 sa.seq('x_case_detail') ,
 'SERVICE_DAYS' ,
 TRUNC(rec_get_sp_detail.x_expire_dt) - TRUNC(SYSDATE) ,
 rec_case_c.objid
 );
 END IF;
 CLOSE case_detail_c;
 -- CR22198 END
 END IF;
 --CR23889
 IF V_PRE_ACT_REPL_COUNT=0 THEN -----added for CR31107
 IF REC_CASE_C.TITLE <> 'SafeLink BroadBand Shipment' THEN
 -- End CR14033 PM Net10 Megacard phase 4
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Calling service_deactivation.deactservice to deactivate case ESN';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;

 --CR21208 End Kacosta 06/28/2012
 sa.service_deactivation.deactservice('Clarify' ,struserobjid ,rec_old_part_inst_c.part_serial_no ,rec_activesite.x_min ,'WAREHOUSE PHONE' ,intbypass ,rec_new_part_inst_c.part_serial_no ,bvalue ,v_return ,v_returnmsg);
 --CR21208 Start Kacosta 06/28/2012

 dbms_output.put_line('v_return : ' || v_return);
 dbms_output.put_line('v_returnmsg: ' || v_returnmsg);
 --CR21208 End Kacosta 06/28/2012
 ELSE
 L_V_PROCEDURE_STEP := 'skip service_deactivation.deactservice to deactivate case ESN case SafeLink BroadBand Shipment ';
 IF L_B_DEBUG THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 END IF;
 --CR23889
 END IF;---------ADDED FOR CR31107
 ELSE
 CLOSE getactivesite;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get case ESN reserved line';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN line_reserved_cur(rec_old_part_inst_c.part_serial_no);
 FETCH line_reserved_cur INTO line_reserved_rec;
 IF line_reserved_cur%FOUND THEN
 CLOSE line_reserved_cur;
 --CR21208 Start Kacosta 06/28/2012
 ------------------------added FOR Cr31107
 IF V_PRE_ACT_REPL_COUNT = 0 THEN
 l_v_procedure_step := 'Associate shipped ESN with reserved line';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_part_inst
 SET part_to_esn2part_inst = rec_new_part_inst_c.objid
 WHERE objid = line_reserved_rec.objid;
 END IF;----FOR CR31107
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 ELSE
 CLOSE line_reserved_cur;
 END IF;
 END IF;
 END IF;
 -- To move the promotions from the Old ESN to the new ESN
 --CR6366 START nguada 06/05/07 Skip for TDMA Migration
 IF rec_case_c.title <> 'TDMA and Analog Active Customer Upgrade' AND REC_CASE_C.TITLE <> 'Lifeline Shipment' AND rec_case_c.title <> 'SafeLink BroadBand Shipment' -- ramu: CR23889
 AND rec_case_c.title <> 'Business Sales Direct Shipment' AND rec_case_c.title <> 'Business Sales Service Shipment' THEN
 dbms_output.put_line('Before MIgra ');
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Calling migra_intellitrack.transferpromotions to transfer promotions';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 IF V_PRE_ACT_REPL_COUNT = 0 THEN---31107
 sa.migra_intellitrack.transferpromotions(rec_case_c.objid ,strnewesn ,err_num ,err_desc);
 end if;---31107
 --CR21208 Start Kacosta 06/28/2012
 IF (err_num <> 0) THEN
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('err_num : ' || TO_CHAR(err_num));
 dbms_output.put_line('err_desc : ' || err_desc);
 END IF;
 --CR21208 End Kacosta 06/28/2012
 dbms_output.put_line('After Migra ');
 ELSE
 dbms_output.put_line('Skip Migra');
 END IF;
 --CR6366 END
 -- Issue Replacement Units on customer's new ESN
 -- Get Objid of Fraud case
 --CR6366 START
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get NEW_ESN case detail parameter value';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN case_detail_c(rec_case_c.objid ,'NEW_ESN');
 FETCH case_detail_c INTO rec_case_detail;
 IF case_detail_c%FOUND THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update NEW_ESN case detail parameter with shipped ESN';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_x_case_detail
 SET x_value = rec_new_part_inst_c.part_serial_no
 WHERE objid = rec_case_detail.objid;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 ELSE
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Insert NEW_ESN case detail parameter with shipped ESN';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 INSERT
 INTO table_x_case_detail
 (
 objid ,
 x_name ,
 x_value ,
 detail2case
 )
 VALUES
 (
 sa.seq('x_case_detail') ,
 'NEW_ESN' ,
 rec_new_part_inst_c.part_serial_no ,
 rec_case_c.objid
 );
 END IF;
 CLOSE case_detail_c;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get FRAUD_UNITS case detail parameter';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 IF V_PRE_ACT_REPL_COUNT = 0 THEN---ADDED FOR CR31107
 --CR21208 End Kacosta 06/28/2012
 OPEN case_detail_c(rec_case_c.objid ,'FRAUD_UNITS');
 FETCH case_detail_c INTO rec_case_detail;
 IF case_detail_c%FOUND THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'FRAUD_UNITS case detail parameter exists set actual units to case replacement units plus FRAUD_UNITS parameter value';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 actualunits := NVL(rec_case_c.x_replacement_units ,0) + TO_NUMBER(NVL(rec_case_detail.x_value ,0));
 ELSE
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'FRAUD_UNITS case detail parameter does not exists set actual units to case replacement units';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 actualunits := NVL(rec_case_c.x_replacement_units ,0);
 END IF;
 END IF;------------ADDED FOR CR31107
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get shipped part exchange units';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN exch_units_c(rec_new_part_num_c.part_number ,rec_case_c.x_model);
 FETCH exch_units_c INTO rec_exch_units;
 IF exch_units_c%FOUND THEN
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Add exchange units to actual units';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 actualunits := actualunits + NVL(rec_exch_units.x_bonus_units ,0);
 END IF;
 CLOSE exch_units_c;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Is actual units greater than 9';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 IF (actualunits > 9) THEN
 -- CR14033 Start PM If the old ESN is Past Due or Used and have megacard then do not transfer benefit.
 -- With reference to Defect # 207 in CR14033.
 IF cur_old_esn_dtl%ISOPEN THEN
 CLOSE cur_old_esn_dtl;
 END IF;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Yes, actual units greater than 9; get old ESN information';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN cur_old_esn_dtl(rec_old_part_inst_c.part_serial_no);
 FETCH cur_old_esn_dtl INTO rec_old_esn_dtl;
 CLOSE cur_old_esn_dtl;
 IF cur_get_sp_detail%ISOPEN THEN
 CLOSE cur_get_sp_detail;
 END IF;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Get old ESN service plan information';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN cur_get_sp_detail(rec_old_part_inst_c.part_serial_no);
 FETCH cur_get_sp_detail INTO rec_get_sp_detail;
 CLOSE cur_get_sp_detail;
 IF rec_old_esn_dtl.x_part_inst_status IN ('54' ,'51') AND rec_get_sp_detail.mkt_name IN ('Net10 Mega Card') THEN --CR22198
 --AND rec_get_sp_detail.mkt_name IN ('Net10 Mega Card','Net10 Mega Card 750 Minutes') THEN -- CR22198
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Old ESN is status 54 or 51 and Mega Card service plan; do nothing';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 ELSE
 dbms_output.put_line('Before Units');
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Either old ESN is not in status (54, 51) or not Mega Card service plan; do nothing; call sp_issue_compunits';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 IF V_PRE_ACT_REPL_COUNT = 0 THEN--------ADDED FOR CR31107
 sa.sp_issue_compunits(rec_new_part_inst_c.objid ,actualunits ,rec_case_c.id_number ,v_return ,v_returnmsg);
 END IF;----------ADDED FOR CR31107
 --CR21208 Start Kacosta 06/28/2012
 IF (UPPER(v_return) <> 'TRUE') THEN
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('v_return : ' || v_return);
 dbms_output.put_line('v_returnmsg : ' || v_returnmsg);
 END IF;
 --CR21208 End Kacosta 06/28/2012
 dbms_output.put_line('After Units ');
 END IF;
 -- CR14033 Start PM If the old ESN is past due and have megacard then do not transfer benefit.
 END IF;
 dbms_output.put_line('Before PI ');
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Insert into PART INST for ship part; calling toss_util_pkg.insert_pi_hist_fun';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 binserted := toss_util_pkg.insert_pi_hist_fun(rec_new_part_inst_c.part_serial_no ,rec_new_part_inst_c.x_domain ,strstatus ,'PART REQUEST SHIP');
 --CR21208 Start Kacosta 06/28/2012
 IF (NOT binserted) THEN
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 END IF;
 --CR21208 End Kacosta 06/28/2012
 dbms_output.put_line('After PI ');
 ELSE
 -- Do no close case if ONHOLD request are still in the case
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Count remaining ONHOLD, PENDING or PROCESSED part request for the case';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 SELECT COUNT(*)
 INTO v_onholdcount
 FROM table_x_part_request
 WHERE request2case = rec_case_c.objid
 AND (x_status LIKE 'ONHOLD%'
 OR x_status LIKE 'PENDING%'
 OR x_status LIKE 'PROCESSED%'); -----CR13581
 IF v_onholdcount = 0 AND rec_case_c.x_case_type <> 'Port In' THEN
 --Not Close Port In ones.
 dbms_output.put_line('Before Close ');
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'No remaining ONHOLD, PENDING or PROCESSED part request for the case and the case is not a PORT IN;calling SA.clarify_case_pkg.close_case to close case ';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 sa.clarify_case_pkg.close_case(rec_case_c.objid ,struserobjid ,'CLARIFY' ,'Part Request Shipped' ,'' ,p_error_no ,p_error_str);
 --CR21208 Start Kacosta 06/28/2012
 IF (p_error_no <> '0') THEN
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 END IF;
 --CR21208 End Kacosta 06/28/2012
 dbms_output.put_line('After Close ');
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Retrieve close case record from table close case ';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN csrclosecase(rec_case_c.objid);
 FETCH csrclosecase INTO recclosecase;
 CLOSE csrclosecase;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Retrieve web case resolution ';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 OPEN csrwebresol(rec_case_c.x_case_type ,rec_case_c.title ,'Shipped');
 FETCH csrwebresol INTO recwebresol;
 CLOSE csrwebresol;
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Update close case record';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 UPDATE table_close_case
 SET close_case2case_resol = recwebresol.objid
 WHERE objid = recclosecase.objid;
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 --COMMIT;
 --CR20740 End kacosta 05/04/2012
 END IF;
 END IF;
 --CR16577 Start kacosta 10/05/2011
 --CR21208 Start Kacosta 06/28/2012
 l_v_procedure_step := 'Calling send_tracking_email';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 send_tracking_email(case_objid => strcaseobjid);
 --CR16577 End kacosta 10/05/2011

 --CR21208 Start Kacosta 06/28/2012
 -------------------------------------------------------------------------------------------------
 -- IF (rec_part_request.x_part_num_domain = 'SIM CARDS') THEN
 IF get_domain(p_serial_num => strnewesn) = 'SIM CARDS' THEN
 l_v_procedure_step := 'Marrying SIM to ACTIVE_ESN';
 v_active_esn := NVL( get_case_detail(strcaseobjid,'ACTIVE_ESN'), rec_case_c.x_esn );
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 UPDATE table_part_inst
 SET x_iccid = strnewesn -- rec_part_request.x_part_serial_no
 WHERE part_serial_no = v_active_esn
 AND NOT EXISTS
 (SELECT 1
 FROM table_site_part sp
 WHERE sp.x_service_id = v_active_esn
 AND sp.part_status
 ||'' IN ('Active','CarrierPending')
 );
 END IF;
 -------------------------------------------------------------------------------------------------
 l_v_procedure_step := 'End ship confirm process';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str: ' || p_error_str);
 END IF;
 --CR21208 End Kacosta 06/28/2012
 -- CR39592 Start PMistry 02/04/2016 Insert UNLOCK_SPC_ENCRYPT if shipped "Warehouse/Unlock Exchange" case found.
 l_v_procedure_step := 'Get case config for Unlock Exchange.';
 open case_conf_cur('ADFCRM_UNLOCK_CASE_CONF');
 fetch case_conf_cur into case_conf_rec;

 v_case_type := NULL;
 v_title := NULL;

 if case_conf_cur%found then
 v_case_type := case_conf_rec.x_case_type;
 v_title := case_conf_rec.x_title;
 end if;
 close case_conf_cur;

-- open case_search_cur(strnewesn,v_case_type,v_title);
-- fetch case_search_cur into case_search_rec;
 l_v_procedure_step := 'Make ESN UNLOCK-READY and flash alert.';
 begin
 select x_case_type, title
 into l_case_type, l_case_title
 from table_case
 where objid = strcaseobjid;
 exception when others then
 null;
 end;
 if v_case_type = l_case_type and
 v_title = l_case_title and
 strnewesn is not null and
 l_part_serial_domain = 'PHONES' and
 rec_new_part_inst_c.device_lock_state = 'UNLOCKABLE'
 then
-- close case_search_cur;
 l_v_procedure_step := 'Make ESN UNLOCK-READY.';
 merge into sa.unlock_spc_encrypt uspc
 using (select strnewesn as strnewesn from dual) n
 on (uspc.esn = n.strnewesn)
 when matched then
 update set unlock_status = 'UNLOCK-READY';

 -- CR42871 - Added new table update / insert for Unlock Ready Status.
 merge into sa.unlock_esn_status uspc
 using (select strnewesn as strnewesn from dual) n
 on (uspc.esn = n.strnewesn)
 when matched then
 update set unlock_status = 'UNLOCK-READY'
 when not matched then
 insert ( ESN, unlock_status )
 values ( n.strnewesn,
 'UNLOCK-READY' );



 -- To flash alert.
 l_v_procedure_step := 'Open part_inst_cur.';
 open part_inst_cur(strnewesn);
 fetch part_inst_cur into part_inst_rec;
 close part_inst_cur;

 open part_inst_cur(check_case_rec.x_esn);
 fetch part_inst_cur into pi_copy_contact_rec;
 close part_inst_cur;

 l_v_procedure_step := 'Copy Contact.';
 copy_contact_info ( op_old_contact_id => pi_copy_contact_rec.x_part_inst2contact, --case.x_esn.x_part_inst2contact
 op_new_contact_id => l_new_contact_id,
 op_err_code => p_error_no,
 op_err_msg => p_error_no) ;

 UPDATE table_part_inst
 SET x_part_inst2contact = l_new_contact_id
 WHERE objid = part_inst_rec.pi_objid;

 l_v_procedure_step := 'Flash Alert.';
 insert into sa.table_alert
 (objid,
 type,
 alert_text,
 start_date,
 end_date,
 active,
 title,
 hot,
 last_update2user,
 alert2contract,
 modify_stmp,
 x_web_text_english,
 x_web_text_spanish)
 values
 (sa.seq('alert'),
 'GENERIC',
 'REP: This handset is a replacement provided as part of an Unlocking Exchange for a SL Customer.
IMPORTANT: Do not activate the phone as it needs to be unlocked first. If you are not a Loss Prevention agent, please transfer to the Unlocking Department at 1061.
', -- alert_text
 sysdate, -- Start Date
 sysdate + 365, -- End Date
 1, -- Active
 'SL Unlockable Phone Exchange', -- Title
 1, -- HOt
 struserobjid, -- last_update2user
 part_inst_rec.pi_objid, -- alert2contract
 sysdate, -- modify_stmp
 'Our records indicate that this phone was provided as replacement for an Unlock Exchange. In order to proceed with the unlocking, please call our Unlocking Department at 1-888-442-5102.',
 'Nuestros registros indican que este tele??no es el reemplazo que se ofrece como parte del Programa de Cambio de Tele??no Desbloqueado. Para proceder con el desbloqueo, por favor llame a nuestro Departamento de Desbloqueos al 1-888-442-5102.'
 );

 --else
 -- close case_search_cur;
 end if;
 -- CR39592 End PMistry 02/04/2016.
 COMMIT;
 EXCEPTION
 WHEN OTHERS THEN
 --CR20740 Start kacosta 05/04/2012
 -- Prevent data corruption
 ROLLBACK;
 --CR20740 End kacosta 05/04/2012
 p_error_no := SQLCODE;
 p_error_str := SQLERRM;
 --CR21208 Start Kacosta 06/28/2012
 dbms_output.put_line('Failure step: ' || l_v_procedure_step);
 dbms_output.put_line('p_error_no : ' || p_error_no);
 dbms_output.put_line('p_error_str : ' || p_error_str);
 l_v_procedure_step := 'End ship confirm process with Oracle error';
 IF l_b_debug THEN
 dbms_output.put_line(l_v_procedure_step || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
 END IF;
 --CR21208 End Kacosta 06/28/2012
 RETURN;
 END part_request_ship;
FUNCTION arrival_date(
 service_level IN NUMBER)
 RETURN DATE
AS
 n NUMBER := 0;
 strday VARCHAR(10) := '';
 service NUMBER;
BEGIN
 service := service_level;
 WHILE n <= service_level
 LOOP
 SELECT TO_CHAR(SYSDATE + n ,'DAY') INTO strday FROM dual;
 IF TRIM(strday) = 'SATURDAY' THEN
 service := service + 2;
 END IF;
 n := n + 1;
 END LOOP;
 RETURN SYSDATE + service;
END arrival_date;
PROCEDURE revalidate_shipping(
 requestobjid IN VARCHAR2 ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2 )
AS
 CURSOR case_curs(request_objid NUMBER)
 IS
 SELECT alt_zipcode ,
 x_case_type ,
 title ,
 table_case.objid ,
 casests2gbst_elm ,
 pr.x_repl_part_num ,
 pr.x_ff_center ,
 pr.x_status
 FROM table_case ,
 table_x_part_request pr
 WHERE table_case.objid = pr.request2case
 AND x_part_num_domain <> 'INSTRUCTION'
 AND pr.objid = requestobjid;
 case_rec case_curs%ROWTYPE;
 CURSOR ship_curs ( repl_part_num VARCHAR2 ,case_type VARCHAR2 ,case_title VARCHAR2 ,zip_code VARCHAR2 )
 IS
 SELECT x_shipping_cost ,
 x_ff_code ,
 x_shipping_method ,
 x_service_level ,
 x_courier_id ,
 domain ,
 x_ranking
 FROM table_x_shipping_method ,
 table_x_courier ,
 table_x_shipping_master ,
 table_x_case_conf_hdr ,
 table_x_mtm_ffc2conf_hdr ,
 table_x_ff_center ,
 mtm_part_num22_x_ff_center2 ,
 table_part_num
 WHERE 1 = 1
 AND table_x_shipping_method.objid = table_x_shipping_master.master2method + 0
 AND table_x_courier.objid = table_x_shipping_master.master2courier + 0
 AND table_x_shipping_master.x_service_level <=
 (SELECT DISTINCT x_param_value
 FROM table_x_parameters
 WHERE x_param_name = 'SERVICE LEVEL'
 AND ROWNUM < 3000000000
 )
 AND table_x_shipping_master.x_weight = table_x_case_conf_hdr.x_weight
 AND table_x_shipping_master.x_zip_code = '99999' --zip_code
 AND table_x_shipping_master.master2ff_center = table_x_ff_center.objid
 AND table_x_case_conf_hdr.x_case_type
 || '' = case_type
 AND table_x_case_conf_hdr.x_title
 || '' = case_title
 AND table_x_case_conf_hdr.objid = table_x_mtm_ffc2conf_hdr.mtm_ffc2conf_hdr
 AND table_x_mtm_ffc2conf_hdr.mtm_ffc2ff_center = table_x_ff_center.objid
 AND table_x_ff_center.objid = mtm_part_num22_x_ff_center2.ff_center2part_num
 AND mtm_part_num22_x_ff_center2.part_num2ff_center = table_part_num.objid
 AND table_part_num.part_number = repl_part_num
 ORDER BY x_shipping_cost ,
 x_ranking ASC;
 ship_rec ship_curs%ROWTYPE;
 CURSOR ff_center_curs ( status_objid NUMBER ,ff_code VARCHAR2 )
 IS
 SELECT x_ff_code
 FROM table_x_ff_center ,
 table_gbst_elm
 WHERE x_status_exception = table_gbst_elm.title
 AND x_ff_code <> ff_code
 AND table_gbst_elm.objid = status_objid
 ORDER BY x_ranking ASC;
 ff_center_rec ff_center_curs%ROWTYPE;
 overwrite NUMBER := 0;
 ff_code VARCHAR2(80);
BEGIN
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 OPEN case_curs(requestobjid);
 FETCH case_curs INTO case_rec;
 IF case_curs%FOUND THEN
 CLOSE case_curs;
 IF case_rec.x_status IN ('PENDING' ,'ONHOLD' ,'INCOMPLETE') AND case_rec.alt_zipcode IS NOT NULL THEN
 OPEN ff_center_curs(case_rec.casests2gbst_elm ,case_rec.x_ff_center);
 FETCH ff_center_curs INTO ff_center_rec;
 IF ff_center_curs%FOUND THEN
 overwrite := 1;
 ff_code := ff_center_rec.x_ff_code;
 END IF;
 CLOSE ff_center_curs;
 OPEN ship_curs(case_rec.x_repl_part_num ,case_rec.x_case_type ,case_rec.title ,case_rec.alt_zipcode);
 FETCH ship_curs INTO ship_rec;
 IF ship_curs%FOUND THEN
 CLOSE ship_curs;
 UPDATE table_x_part_request
 SET x_last_update_stamp = SYSDATE ,
 x_ff_center = DECODE(overwrite ,0 ,ship_rec.x_ff_code ,ff_code) ,
 x_shipping_method = ship_rec.x_shipping_method ,
 x_courier = ship_rec.x_courier_id
 WHERE objid = requestobjid;
 UPDATE table_x_part_request
 SET x_last_update_stamp = SYSDATE ,
 x_ff_center = DECODE(overwrite ,0 ,ship_rec.x_ff_code ,ff_code) ,
 x_shipping_method = ship_rec.x_shipping_method ,
 x_courier = ship_rec.x_courier_id
 WHERE request2case = case_rec.objid
 AND x_part_num_domain = 'INSTRUCTION';
 COMMIT;
 ELSE
 CLOSE ship_curs;
 UPDATE table_x_part_request
 SET x_last_update_stamp = SYSDATE ,
 x_status = 'INCOMPLETE'
 WHERE objid = requestobjid;
 UPDATE table_x_part_request
 SET x_last_update_stamp = SYSDATE ,
 x_status = 'INCOMPLETE'
 WHERE request2case = case_rec.objid
 AND x_part_num_domain = 'INSTRUCTION';
 COMMIT;
 END IF;
 ELSE
 p_error_no := '30';
 p_error_str := 'Part request status does no allow update';
 END IF;
 ELSE
 CLOSE case_curs;
 p_error_no := '31';
 p_error_str := 'Part request not found';
 END IF;
 COMMIT;
EXCEPTION
WHEN OTHERS THEN
 p_error_no := SQLCODE;
 p_error_str := SQLERRM;
 RETURN;
END;
-- START TMODATA
FUNCTION status_desc_func(
 ip_status_code IN VARCHAR2)
 RETURN VARCHAR2
AS
 l_return_text VARCHAR2(300);
BEGIN
 l_return_text := 'Description Not Available';
 SELECT x_code_name
 INTO l_return_text
 FROM table_x_code_table
 WHERE x_code_number = ip_status_code;
 RETURN l_return_text;
EXCEPTION
WHEN OTHERS THEN
 l_return_text := ip_status_code || ' Description Not Available';
 RETURN l_return_text;
END;
FUNCTION status_part_inst(
 ip_serial_no IN VARCHAR2 ,
 ip_domain IN VARCHAR2 )
 RETURN VARCHAR2
AS
 l_return_status VARCHAR2(300);
BEGIN
 l_return_status := 'Not Available';
 SELECT x_part_inst_status
 INTO l_return_status
 FROM table_part_inst
 WHERE part_serial_no = ip_serial_no
 AND x_domain = ip_domain;
 RETURN l_return_status;
EXCEPTION
WHEN OTHERS THEN
 l_return_status := 'Not Available';
 RETURN l_return_status;
END;
--END TMODATA
---------------------------------
---------------------------------
---------------------------------
PROCEDURE advance_exchange(
 strcaseobjid IN VARCHAR2 ,
 stroldesn IN VARCHAR2 ,
 struserobjid IN VARCHAR2 ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2 )
AS
 CURSOR login_c(userobjid IN VARCHAR)
 IS
 SELECT login_name FROM table_user WHERE objid = userobjid;
 rec_login login_c%ROWTYPE;
 CURSOR case_curs(c_objid IN NUMBER)
 IS
 SELECT * FROM table_case WHERE objid = c_objid;
 rec_case_c case_curs%ROWTYPE;
 CURSOR case_esn_curs ( c_objid IN NUMBER ,c_esn IN VARCHAR2 )
 IS
 SELECT * FROM table_case WHERE objid = c_objid AND x_esn = c_esn;
 case_esn_rec case_esn_curs%ROWTYPE;
 CURSOR check_case_curs
 IS
 SELECT c.case_owner2user ,
 ge.s_title
 FROM table_condition ge ,
 table_case c
 WHERE 1 = 1
 AND ge.objid = c.case_state2condition
 AND c.objid = strcaseobjid;
 check_case_rec check_case_curs%ROWTYPE;
 CURSOR part_request_c(case_objid VARCHAR2)
 IS
 SELECT *
 FROM table_x_part_request
 WHERE request2case = case_objid
 AND x_status IN ('ONHOLDST');
 rec_part_request part_request_c%ROWTYPE;
 --Get the old esn
 v_phone_request BOOLEAN;
 strusername VARCHAR2(50);
 strhistory VARCHAR2(200);
BEGIN
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 v_phone_request := FALSE;
 -- Validate User
 OPEN login_c(struserobjid);
 FETCH login_c INTO rec_login;
 IF login_c%NOTFOUND THEN
 p_error_no := '4';
 p_error_str := 'User not found';
 CLOSE login_c;
 RETURN;
 END IF;
 CLOSE login_c;
 strusername := rec_login.login_name;
 -- Get Case Header
 OPEN case_curs(strcaseobjid);
 FETCH case_curs INTO rec_case_c;
 IF case_curs%NOTFOUND THEN
 p_error_no := '1';
 p_error_str := 'Case not found';
 CLOSE case_curs; --Fix OPEN_CURSORS
 RETURN;
 END IF;
 CLOSE case_curs;
 --Get Case ESN
 OPEN case_esn_curs(strcaseobjid ,stroldesn);
 FETCH case_esn_curs INTO case_esn_rec;
 IF case_esn_curs%NOTFOUND THEN
 p_error_no := '30';
 p_error_str := 'ESN does not belong to case';
 CLOSE case_esn_curs; --Fix OPEN_CURSORS
 RETURN;
 END IF;
 CLOSE case_esn_curs;
 OPEN check_case_curs;
 FETCH check_case_curs INTO check_case_rec;
 IF check_case_rec.s_title NOT IN ('OPEN' ,'OPEN-DISPATCH' ,'OPEN-REJECT') THEN
 CLOSE check_case_curs;
 p_error_no := '2';
 p_error_str := 'Case is not open';
 RETURN;
 END IF;
 CLOSE check_case_curs;
 strhistory := 'Old ESN received - Ready to ship replacement';
 update_status(strcaseobjid ,struserobjid ,'ESN Received' ,strhistory ,p_error_no ,p_error_str);
 strhistory := 'Exception released';
 --UPDATE_STATUS (strcaseobjid, struserobjid,
 --'Pending', strhistory, p_ERROR_NO, p_ERROR_STR);
 RETURN;
 COMMIT;
EXCEPTION
WHEN OTHERS THEN
 p_error_no := SQLCODE;
 p_error_str := SQLERRM;
 RETURN;
END advance_exchange;
FUNCTION get_case_detail(
 strcaseobjid IN VARCHAR2 ,
 strparameter IN VARCHAR2 )
 RETURN VARCHAR2
AS
 l_return_text VARCHAR2(300);
BEGIN
 SELECT x_value
 INTO l_return_text
 FROM table_x_case_detail
 WHERE detail2case = NVL(strcaseobjid ,'')
 AND x_name = NVL(strparameter ,'');
 RETURN TRIM(NVL(l_return_text ,''));
EXCEPTION
WHEN OTHERS THEN
 l_return_text := NULL;
 RETURN l_return_text;
END;
PROCEDURE part_request_add(
 strcaseobjid IN VARCHAR2 ,
 strpartnumber IN VARCHAR2 ,
 p_quantity IN NUMBER ,
 p_user_objid IN VARCHAR2 ,
 p_shipping IN VARCHAR2 , ----CR13085
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2 )
AS
 CURSOR domain_curs(part_num VARCHAR2)
 IS
 SELECT domain FROM table_part_num WHERE part_number = part_num;
 domain_rec domain_curs%ROWTYPE;
 CURSOR case_curs(case_objid VARCHAR2) -----CR13581
 IS
 SELECT c.objid ,
 c.x_case_type ,
 c.title ,
 c.alt_zipcode ,
 c.case_history ,
 c.case_owner2user ,
 c.id_number,
 ge.title cond_title ,
 gb.title sts_title
 FROM table_condition ge ,
 table_case c ,
 table_gbst_elm gb
 WHERE 1 = 1
 AND ge.objid = c.case_state2condition
 AND c.objid = TO_NUMBER(case_objid) -----CR13581
 AND gb.objid = c.casests2gbst_elm;
 case_rec case_curs%ROWTYPE;
 CURSOR user_curs
 IS
 SELECT login_name FROM table_user WHERE 1 = 1 AND objid = p_user_objid;
 user_rec user_curs%ROWTYPE;
 CURSOR part_req_curs ( case_objid NUMBER ,part_number VARCHAR2 )
 IS
 SELECT *
 FROM table_x_part_request
 WHERE request2case = case_objid
 AND x_repl_part_num = part_number
 AND x_status NOT IN ('SHIPPED' ,'PROCESSED' ,'CANCELLED' ,'CANCEL_REQUEST');
 part_req_rec part_req_curs%ROWTYPE;
 -----CR13581
 ff_code VARCHAR2(20) := 'BP_IO';
 ff_courier_id VARCHAR2(20) := 'FEDEX';
 --ff_method VARCHAR2(30) := 'GROUND';
 ff_method VARCHAR2(30) := '2nd DAY';
 n NUMBER := 0;
 v_request_status VARCHAR2(30) := 'PENDING';
 param_count NUMBER;
 CURSOR shipping_option_cur
 IS
 SELECT x_shipping_method
 FROM table_x_shipping_method ,
 table_x_courier
 WHERE x_courier_name = ff_courier_id -----CR13085
 AND method2courier = table_x_courier.objid
 AND x_alt_name = p_shipping; -----CR13085
 shipping_option_rec shipping_option_cur%ROWTYPE; -----CR13581

 v_inv_result varchar2(100);

BEGIN
 p_error_no := '0';
 p_error_str := 'SUCCESS';
 -----CR13581
 OPEN shipping_option_cur;
 FETCH shipping_option_cur INTO shipping_option_rec;
 IF shipping_option_cur%FOUND THEN
 ff_method := shipping_option_rec.x_shipping_method;
 END IF;
 CLOSE shipping_option_cur; -----CR13581
 IF NVL(p_quantity ,0) = 0 THEN
 p_error_no := '30';
 p_error_str := 'Quantity needs to be greater than 0';
 RETURN;
 END IF;
 DELETE
 FROM table_x_part_request
 WHERE request2case = TO_NUMBER(strcaseobjid)
 AND x_status = 'INCOMPLETE'
 AND x_repl_part_num IS NULL;
 OPEN case_curs(strcaseobjid); -----CR13581
 FETCH case_curs INTO case_rec;
 IF case_curs%NOTFOUND THEN
 p_error_no := '1';
 p_error_str := 'Case not found';
 CLOSE case_curs;
 RETURN;
 END IF;
 CLOSE case_curs;
 IF case_rec.cond_title = 'Closed' THEN
 p_error_no := '2';
 p_error_str := 'Case needs to be Open to change status';
 RETURN;
 END IF;
 OPEN user_curs;
 FETCH user_curs INTO user_rec;
 IF user_curs%NOTFOUND THEN
 p_error_no := '4';
 p_error_str := 'User not found';
 CLOSE user_curs;
 RETURN;
 END IF;
 OPEN part_req_curs(strcaseobjid ,strpartnumber);
 FETCH part_req_curs INTO part_req_rec;
 IF part_req_curs%FOUND THEN
 UPDATE table_x_part_request
 SET x_quantity = x_quantity + NVL(p_quantity ,0) ,
 x_courier = ff_courier_id , -----CR13581
 x_ff_center = ff_code ,
 x_shipping_method = ff_method
 WHERE objid = part_req_rec.objid;
 CLOSE part_req_curs;
 ELSE
 CLOSE part_req_curs;
 OPEN domain_curs(strpartnumber); -----CR13581
 FETCH domain_curs INTO domain_rec;
 CLOSE DOMAIN_CURS;
 INSERT
 INTO table_x_part_request
 (
 objid ,
 x_action ,
 x_repl_part_num ,
 x_part_serial_no ,
 x_ff_center ,
 x_ship_date ,
 x_est_arrival_date ,
 x_received_date ,
 x_courier ,
 x_shipping_method ,
 x_tracking_no ,
 x_status ,
 request2case ,
 x_insert_date ,
 x_part_num_domain ,
 x_service_level ,
 x_quantity
 )
 VALUES
 (
 seq('x_part_request') ,
 'SHIP' ,
 strpartnumber ,
 NULL ,
 ff_code ,
 NULL ,
 NULL ,
 NULL ,
 ff_courier_id ,
 ff_method ,
 NULL ,
 'PENDING' ,
 case_rec.objid ,
 SYSDATE ,
 domain_rec.domain ,
 NULL ,
 NVL(p_quantity ,0)
 );
 END IF;
 COMMIT;

END;
PROCEDURE st_exchange
 (
 caseobjid IN NUMBER ,
 current_esn IN VARCHAR2 ,
 new_esn IN VARCHAR2 ,
 new_technology IN VARCHAR2 ,
 new_iccid IN VARCHAR2 ,
 new_zipcode IN VARCHAR2 ,
 user_objid IN NUMBER ,
 p_error_no OUT VARCHAR2 ,
 p_error_str OUT VARCHAR2
 )
IS
 is_esn_lte_cdma BOOLEAN := FALSE;
 CURSOR line_reserved_cur(esn VARCHAR2)
 IS
 SELECT *
 FROM table_part_inst
 WHERE part_to_esn2part_inst IN
 (SELECT objid
 FROM table_part_inst
 WHERE part_serial_no = esn
 AND x_domain = 'PHONES'
 )
 AND x_domain = 'LINES'
 AND x_part_inst_status IN ('37' ,'39');
 line_reserved_rec line_reserved_cur%ROWTYPE;
 CURSOR active_site_part_cur(esn VARCHAR2)
 IS
 SELECT *
 FROM table_site_part
 WHERE x_service_id = esn
 AND part_status
 || '' IN ('Active' ,'CarrierPending')
 AND warranty_date > SYSDATE;
 active_site_part_rec active_site_part_cur%ROWTYPE;
 CURSOR sim_inv_cur(iccid VARCHAR2)
 IS
 SELECT x_sim_inv_status
 FROM table_x_sim_inv
 WHERE x_sim_serial_no = iccid
 AND x_sim_inv_status = '253';
 sim_inv_rec sim_inv_cur%ROWTYPE;
 CURSOR st_program(esn VARCHAR2)
 IS
 --CR20773 Start Kacosta 10/25/2012
 --SELECT x_service_plan.objid
 -- ,table_site_part.install_date
 -- ,mtm_sp_x_program_param.x_sp2program_param
 -- ,table_x_contact_part_inst.x_contact_part_inst2contact
 -- ,table_web_user.objid web_user_objid
 -- FROM x_service_plan
 -- ,x_service_plan_site_part
 -- ,mtm_sp_x_program_param
 -- ,table_site_part
 -- ,table_part_inst
 -- ,table_x_contact_part_inst
 -- ,table_web_user
 -- WHERE x_service_plan.objid = x_service_plan_site_part.x_service_plan_id
 -- AND x_service_plan.objid = mtm_sp_x_program_param.program_para2x_sp
 -- AND x_service_plan_site_part.table_site_part_id = table_site_part.objid
 -- AND table_site_part.x_service_id = esn
 -- AND table_site_part.part_status <> 'Obsolete'
 -- AND table_part_inst.part_serial_no = table_site_part.x_service_id
 -- AND table_part_inst.x_domain = 'PHONES'
 -- AND table_x_contact_part_inst.x_contact_part_inst2part_inst = table_part_inst.objid
 -- AND table_web_user.web_user2contact = table_x_contact_part_inst.x_contact_part_inst2contact
 -- ORDER BY table_site_part.install_date DESC;
 SELECT x_service_plan.objid ,
 table_site_part.install_date ,
 mtm_sp_x_program_param.x_sp2program_param ,
 NVL(NVL(table_x_contact_part_inst.x_contact_part_inst2contact ,table_part_inst.x_part_inst2contact) ,table_contact_role.contact_role2contact) x_contact_part_inst2contact ,
 table_web_user.objid web_user_objid
 FROM table_site_part
 JOIN table_part_inst
 ON table_part_inst.part_serial_no = table_site_part.x_service_id
 LEFT OUTER JOIN table_contact_role
 ON table_site_part.site_part2site = table_contact_role.contact_role2site
 LEFT OUTER JOIN table_x_contact_part_inst
 ON table_x_contact_part_inst.x_contact_part_inst2part_inst = table_part_inst.objid
 LEFT OUTER JOIN table_web_user
 ON table_web_user.web_user2contact = table_x_contact_part_inst.x_contact_part_inst2contact
 LEFT OUTER JOIN x_service_plan_site_part
 ON x_service_plan_site_part.table_site_part_id = table_site_part.objid
 LEFT OUTER JOIN x_service_plan
 ON x_service_plan.objid = x_service_plan_site_part.x_service_plan_id
 LEFT OUTER JOIN mtm_sp_x_program_param
 ON x_service_plan.objid = mtm_sp_x_program_param.program_para2x_sp
 WHERE table_site_part.x_service_id = esn
 AND table_site_part.part_status <> 'Obsolete'
 AND table_part_inst.x_domain = 'PHONES'
 ORDER BY table_site_part.install_date DESC;
 --CR20773 End Kacosta 10/25/2012
 st_program_rec st_program%ROWTYPE;
 CURSOR married_cur(sim VARCHAR2)
 IS
 SELECT part_serial_no FROM table_part_inst WHERE x_iccid = sim;
 --
 --CR20773 Start kacosta 10/22/2012
 CURSOR get_case_brand_curs(c_n_case_objid IN table_case.objid%TYPE)
 IS
 SELECT tbo.org_flow brand_org_flow,tbo.org_id --CR51022 added org_id
 FROM table_case tbc
 JOIN table_bus_org tbo
 ON UPPER(tbc.case_type_lvl2) = tbo.org_id
 WHERE tbc.objid = c_n_case_objid;
 --
 get_case_brand_rec get_case_brand_curs%ROWTYPE;
 --
 --CR20773 End kacosta 10/22/2012
 --
 -- Added by Juda Pena on 01/08/2015 to get the case shared group flag from the brand
 CURSOR c_get_case_shared_group_flag (p_case_objid IN NUMBER) IS
 SELECT NVL( brand_x_pkg.get_shared_group_flag (UPPER(case_type_lvl2)),'N') shared_group_flag, UPPER(case_type_lvl2) bus_org_id, TO_NUMBER(id_number) case_id_number
 FROM table_case
 WHERE objid = p_case_objid;
 --
 shared_group_flag_rec c_get_case_shared_group_flag%ROWTYPE;

 --
 l_err_code NUMBER;
 l_err_msg VARCHAR2(1000);
 acct_grp_mbr_rec x_account_group_member%ROWTYPE;
 acct_grp_rec x_account_group%ROWTYPE;
 l_svc_order_stage_id NUMBER;
 married_rec married_cur%ROWTYPE;
 v_carrier_id NUMBER;
 v_error_no VARCHAR2(30);
 v_error_str VARCHAR2(30);
 v_action VARCHAR2(30) := 'ACTIVATION';
 v_job_objid NUMBER;
 v_min VARCHAR2(30);
 v_program_objid NUMBER;
 v_web_user_objid NUMBER;
 v_contact_objid NUMBER;
 v_return VARCHAR2(20);
 v_returnmsg VARCHAR2(300);
 v_status VARCHAR2(10);
 v_repl_sim VARCHAR2(30);
 v_used_married_sim BOOLEAN := FALSE;
 v_not_valid_sim BOOLEAN;
 v_result NUMBER;
 --CR20740 Start kacosta 06/11/2012
 --v_msg VARCHAR2(100);
 v_msg VARCHAR2(32767);
 --CR20740 End kacosta 06/11/2012
 V_NO_SERVICE_TRANSFER number;
 -- Declaration of type variables for Super Carrier
 l_error_code NUMBER;
 l_pe_objid x_program_enrolled.objid%TYPE;
 l_from_pgm_objid x_program_parameters.objid%TYPE;
BEGIN
 p_error_no := '0';
 p_error_str := '';
 --CR29812
 IF sa.LTE_SERVICE_PKG.IS_ESN_LTE_CDMA(new_esn) = 1 THEN
 is_esn_lte_cdma := TRUE;
 ELSE
 is_esn_lte_cdma := FALSE;
 END IF;
 --
 --CR20773 Start kacosta 10/22/2012
 IF get_case_brand_curs%ISOPEN THEN
 --
 CLOSE get_case_brand_curs;
 --
 END IF;
 --
 OPEN get_case_brand_curs(c_n_case_objid => caseobjid);
 FETCH get_case_brand_curs INTO get_case_brand_rec;
 CLOSE get_case_brand_curs;
 --CR20773 End kacosta 10/22/2012
 --
 --IF Service Active or Line Reserved?
 OPEN active_site_part_cur(current_esn);
 FETCH active_site_part_cur INTO active_site_part_rec;
 IF active_site_part_cur%NOTFOUND THEN
 CLOSE active_site_part_cur;
 p_error_no := 'ST_EXCHANGE:001';
 p_error_str := 'Service not Active';
 dbms_output.put_line('P_ERROR_NO = ' || p_error_no);
 dbms_output.put_line('P_Error_Str = ' || p_error_str);
 RETURN ;
 OPEN line_reserved_cur(current_esn);
 FETCH line_reserved_cur INTO line_reserved_rec;
 IF line_reserved_cur%NOTFOUND THEN
 CLOSE line_reserved_cur;
 p_error_no := 'ST_EXCHANGE:001';
 p_error_str := 'Line Not Reserved';
 dbms_output.put_line('P_ERROR_NO = ' || p_error_no);
 dbms_output.put_line('P_Error_Str = ' || p_error_str);
 RETURN;
 ELSE
 v_status := 'Reserved';
 CLOSE line_reserved_cur;
 END IF;
 v_min := line_reserved_rec.part_serial_no;
 v_status := 'Active';
 ELSE
 CLOSE active_site_part_cur;
 v_status := 'Active';
 v_min := active_site_part_rec.x_min;
 END IF;
 -- Check is old ESN has AutoRefill
 OPEN st_program(current_esn);
 FETCH st_program INTO st_program_rec;
 IF st_program%NOTFOUND
 --CR20773 Start kacosta 10/22/2012
 AND NVL(get_case_brand_rec.brand_org_flow ,'-1') <> '2'
 --CR20773 End kacosta 10/22/2012
 THEN
 CLOSE st_program;
 p_error_no := 'ST_EXCHANGE:002';
 p_error_str := 'No Service Plan Found';
 dbms_output.put_line('P_ERROR_NO = ' || p_error_no);
 dbms_output.put_line('P_Error_Str = ' || p_error_str);
 RETURN;
 ELSE
 CLOSE st_program;
 END IF;
 v_program_objid := st_program_rec.x_sp2program_param;
 v_web_user_objid := st_program_rec.web_user_objid;
 v_contact_objid := st_program_rec.x_contact_part_inst2contact;
 --Is SIM Needed?
 IF (new_technology = 'GSM' OR (new_technology = 'CDMA' AND is_esn_lte_cdma = TRUE )) THEN
 v_repl_sim := get_case_detail(caseobjid ,'REPL_SIM_ID');
 IF v_repl_sim IS NOT NULL AND v_repl_sim <> 'TBD' THEN
 OPEN sim_inv_cur(v_repl_sim);
 FETCH sim_inv_cur INTO sim_inv_rec;
 IF sim_inv_cur%FOUND THEN
 -- REPL SIM IS NEW
 CLOSE sim_inv_cur;
 OPEN married_cur(v_repl_sim);
 FETCH married_cur INTO married_rec;
 IF married_cur%FOUND AND married_rec.part_serial_no <> new_esn THEN
 CLOSE married_cur;
 v_used_married_sim := TRUE;
 ELSE
 CLOSE married_cur;
 END IF;
 ELSE
 CLOSE sim_inv_cur;
 v_used_married_sim := TRUE;
 END IF;
 ELSE
 v_used_married_sim := TRUE;
 END IF;
 IF v_used_married_sim THEN
 v_repl_sim := new_iccid;
 IF v_repl_sim IS NOT NULL THEN
 OPEN sim_inv_cur(v_repl_sim);
 FETCH sim_inv_cur INTO sim_inv_rec;
 IF sim_inv_cur%FOUND THEN
 -- REPL SIM IS NEW
 CLOSE sim_inv_cur;
 OPEN married_cur(v_repl_sim);
 FETCH married_cur INTO married_rec;
 IF married_cur%FOUND AND married_rec.part_serial_no <> new_esn THEN
 CLOSE married_cur;
 v_not_valid_sim := TRUE;
 ELSE
 CLOSE married_cur;
 END IF;
 ELSE
 CLOSE sim_inv_cur;
 v_not_valid_sim := TRUE;
 END IF;
 ----update replacement sim--22621
 update_case_dtl(caseobjid ,user_objid ,'REPL_SIM_ID||' || v_repl_sim ,p_error_no ,p_error_str); ---22621
 ELSE
 ---if new_iccid is null --22621
 dbms_output.put_line('No sim in case or new iccid ');
 --- v_not_valid_sim := TRUE; --22621
 v_error_str := 'Needs Sim ';
 update_case_dtl(caseobjid ,user_objid ,'REPL_SIM_ID||' || v_error_str ,p_error_no ,p_error_str);
 p_error_no := 'ST_EXCHANGE:006';
 p_error_str := 'ESN NEEDS SIM TO ACTIVATE';
 dbms_output.put_line('P_ERROR_NO = ' || p_error_no);
 dbms_output.put_line('P_Error_Str = ' || p_error_str);
 RETURN ; ---22621
 END IF;
 END IF;
 IF v_not_valid_sim THEN
 p_error_no := 'ST_EXCHANGE:004';
 p_error_str := 'Invalid SIM';
 dbms_output.put_line('P_ERROR_NO = ' || p_error_no);
 dbms_output.put_line('P_Error_Str = ' || p_error_str);
 RETURN;
 END IF;
 END IF;
 --Port or Upgrade?
 /*
 sa.VERIFY_PHONE_UPGRADE_PKG.VERIFY( ip_str_old_esn => current_esn, ip_str_new_esn => new_esn, IP_STR_ZIP => new_zipcode, IP_STR_ICCID => new_iccid, op_carrier_id => v_carrier_id, OP_ERROR_TEXT => v_error_str, Op_Error_Num => V_Error_No);
 Dbms_Output.Put_Line('current_esn = ' || current_esn);
 Dbms_Output.Put_Line(' new_esn = ' || new_esn);
 Dbms_Output.Put_Line('new_zipcode = ' || new_zipcode);
 Dbms_Output.Put_Line('new_iccid = ' || new_iccid);
 Dbms_Output.Put_Line('v_carrier_id = ' || v_carrier_id);
 Dbms_Output.Put_Line('v_error_str = ' || v_error_str);
 Dbms_Output.Put_Line('v_error_nor = ' || V_Error_No);
 IF v_error_no <> '0' THEN
 p_error_no := 'ST_EXCHANGE:005';
 P_Error_Str := V_Error_Str;
 Dbms_Output.Put_Line('P_ERROR_NO = ' || P_Error_No);
 DBMS_OUTPUT.PUT_LINE('P_Error_Str = ' || P_Error_Str);
 RETURN;
 END IF;
 If V_Error_Str = 'ESN EXCHANGE' Or V_Error_Str = 'AUTO PORT' Or V_Error_Str = 'MANUAL PORT' Then
 V_Action := 'ACTIVATION';
 Sa.Service_Deactivation.Deactservice ('Clarify', User_Objid, Current_Esn, V_Min, 'WAREHOUSE PHONE', 2, New_Esn, 'true', V_Return, V_Returnmsg );
 Dbms_Output.Put_Line('Deact Return = ' || V_Return);
 Dbms_Output.Put_Line('Deact Message = ' || V_Returnmsg);
 ELSE
 p_error_no := 'ST_EXCHANGE:006';
 p_error_str := v_error_str;
 Dbms_Output.Put_Line('P_ERROR_NO = ' || P_Error_No);
 Dbms_Output.Put_Line('P_Error_Str = ' || P_Error_Str);
 RETURN;
 End If;
 end if;
 */
 IF v_status = 'Reserved' THEN
 UPDATE table_part_inst
 SET part_to_esn2part_inst =
 (SELECT objid
 FROM table_part_inst
 WHERE part_serial_no = new_esn
 AND x_domain = 'PHONES'
 )
 WHERE part_serial_no = v_min
 AND x_domain = 'LINES';
 END IF;

 SELECT COUNT('1')
 INTO v_no_service_transfer
 FROM sa.TABLE_X_CASE_DETAIL
 WHERE DETAIL2CASE = caseobjid
 AND X_NAME = 'NO_SERVICE_TRANSFER';

 IF v_status = 'Active' and v_no_service_transfer=0 THEN

 sa.billing_webcsr_pkg.transfer_esn_prog_to_diff_esn(p_web_objid => v_web_user_objid ,p_s_esn => current_esn ,p_t_esn => new_esn ,p_user => 'SA' ,p_pe_objid => l_pe_objid , p_from_pgm_objid => l_from_pgm_objid,op_result => v_result ,op_msg => v_msg);
 sa.service_deactivation.deactservice('Clarify' ,user_objid ,current_esn ,v_min ,'WAREHOUSE PHONE' ,2 ,new_esn ,'true' ,v_return ,v_returnmsg);
 dbms_output.put_line('Deact Return = ' || v_return);
 dbms_output.put_line('Deact Message = ' || v_returnmsg);
 UPDATE table_site_part
 SET warranty_date = SYSDATE
 WHERE x_service_id = current_esn
 AND x_min = v_min
 AND part_status = 'Inactive'
 AND warranty_date > SYSDATE;

 -- Commented out by Juda Pena on 01/08/2015 to replace with code for Brand X Project
 /*sa.clarify_job_pkg.create_job(v_action ,caseobjid ,user_objid ,current_esn ,new_esn ,v_min ,v_program_objid ,v_web_user_objid ,v_contact_objid ,new_zipcode ,v_repl_sim ,v_job_objid ,v_error_no ,v_error_str);
 IF v_error_no <> '0' THEN
 p_error_no := 'ST_EXCHANGE:007';
 p_error_str := v_error_str;
 dbms_output.put_line('P_ERROR_NO = ' || p_error_no);
 dbms_output.put_line('P_Error_Str = ' || p_error_str);
 RETURN;
 ELSE
 update_case_dtl(caseobjid ,user_objid ,'ACTIVE_ESN||' || new_esn ,p_error_no ,p_error_str);
 --Start 22621
 update_case_dtl(caseobjid ,user_objid ,'REPL_SIM_ID||' || v_repl_sim ,p_error_no ,p_error_str);
 ---end 22621
 END IF;
 */

 -- Added logic by Juda Pena on 01/08/2015 to replace old code with Brand X logic
 OPEN c_get_case_shared_group_flag (caseobjid);
 FETCH c_get_case_shared_group_flag INTO shared_group_flag_rec;
 CLOSE c_get_case_shared_group_flag;

 -- If the case is for a Brand X group then create a stage record
 IF NVL(shared_group_flag_rec.shared_group_flag,'N') = 'Y' THEN
 -- Get the old member row
 acct_grp_mbr_rec := brand_x_pkg.get_member_rec (ip_esn => current_esn);

 -- Duplicate the old member row with the new esn information
 brand_x_pkg.insert_member ( ip_account_group_id => acct_grp_mbr_rec.account_group_id,
 ip_esn => new_esn,
 ip_promotion_id => acct_grp_mbr_rec.promotion_id,
 ip_status => 'PENDING_ENROLLMENT',
 ip_member_order => acct_grp_mbr_rec.member_order,
 ip_subscriber_uid => acct_grp_mbr_rec.subscriber_uid,
 ip_master_flag => 'N',
 ip_site_part_id => acct_grp_mbr_rec.site_part_id,
 ip_program_param_id => acct_grp_mbr_rec.program_param_id,
 op_account_group_member_id => acct_grp_mbr_rec.objid, -- output
 op_err_code => l_err_code, -- output
 op_err_msg => l_err_msg); -- output
 -- When an error occurs
 IF l_err_code <> 0 THEN
 p_error_no := 'ST_EXCHANGE:007';
 p_error_str := l_err_msg;
 -- Exit the routine process
 RETURN;
 END IF;
 -- Get the old member account group row
 acct_grp_rec := brand_x_pkg.get_group_rec (ip_esn => current_esn);

 -- Create the service order stage row
 brand_x_pkg.create_service_order_stage_we ( ip_account_group_member_id => acct_grp_mbr_rec.objid,
 ip_esn => new_esn,
 ip_sim => v_repl_sim,
 ip_zipcode => new_zipcode,
 ip_pin => NULL,
 ip_service_plan_id => acct_grp_rec.service_plan_id,
 ip_case_id => shared_group_flag_rec.case_id_number ,
 ip_status => 'QUEUED' ,
 ip_type => 'EXCHANGE' ,
 ip_program_param_id => NULL,
 ip_pmt_source_id => NULL,
 ip_web_objid => v_web_user_objid,
 ip_sourcesystem => 'BATCH',
 ip_bus_org_id => shared_group_flag_rec.bus_org_id,
 op_service_order_stage_id => l_svc_order_stage_id,
 op_err_code => l_err_code,
 op_err_msg => l_err_msg);

 -- When an error occurs
 IF l_err_code <> 0 THEN
 p_error_no := 'ST_EXCHANGE:007';
 p_error_str := l_err_msg;
 -- Exit the routine process
 RETURN;
 END IF;
 --

 -- Otherwise follow the regular BAU process
 --CR51022 commented below code and added new if block to make it single call inclusive of WFM
 /*ELSE
 --
 sa.clarify_job_pkg.create_job(v_action, caseobjid ,user_objid, current_esn, new_esn, v_min, v_program_objid, v_web_user_objid, v_contact_objid, new_zipcode, v_repl_sim, v_job_objid, v_error_no, v_error_str);
 --
 IF v_error_no <> '0' THEN
 p_error_no := 'ST_EXCHANGE:007';
 p_error_str := v_error_str;
 dbms_output.put_line('P_ERROR_NO = ' || p_error_no);
 dbms_output.put_line('P_Error_Str = ' || p_error_str);
 -- Exit the routine process
 RETURN;
 END IF;*/

 /*-- Added logic by Juda Pena to replace a Super Carrier subscriber (CR35396, CR29586)
 replace_subscriber_spr ( i_old_esn => current_esn,
 i_new_esn => new_esn,
 i_src_program_name => 'SA.CLARIFY_CASE_PKG',
 o_error_code => l_error_code,
 o_error_msg => p_error_str );
 -- If there is an error
 IF l_error_code <> 0 THEN
 p_error_no := 'ST_EXCHANGE:008';
 RETURN;
 END IF;*/
 -- Added logic by Juda Pena to replace a Super Carrier subscriber (CR35396, CR29586)

 END IF;

 update_case_dtl(caseobjid ,user_objid ,'ACTIVE_ESN||' || new_esn ,p_error_no ,p_error_str);
 --Start 22621
 update_case_dtl(caseobjid ,user_objid ,'REPL_SIM_ID||' || v_repl_sim ,p_error_no ,p_error_str);
 ---end
 END IF;

 --CR51022 WFM Exchange preactivation changes start
 -- Moved the sa.clarify_job_pkg.create_job call from previous if to below and make it a single call inclusive of WFM

 IF (( v_status = 'Active' and v_no_service_transfer=0) AND (NVL(shared_group_flag_rec.shared_group_flag,'N') = 'N' ))
 OR get_case_brand_rec.org_id ='WFM' THEN

 sa.clarify_job_pkg.create_job(ip_title => v_action,
 ip_case_objid => caseobjid,
 ip_user_objid => user_objid,
 ip_old_esn => current_esn,
 ip_esn => new_esn,
 ip_min => v_min,
 ip_program_objid => v_program_objid,
 ip_web_user_objid => v_web_user_objid,
 ip_contact_objid => v_contact_objid,
 ip_zip => new_zipcode,
 ip_iccid => v_repl_sim,
 op_job_objid => v_job_objid,
 op_error_no => v_error_no,
 op_error_str => v_error_str);

 IF v_error_no <> '0' THEN

 p_error_no := 'ST_EXCHANGE:007';
 p_error_str := v_error_str;

 dbms_output.put_line('P_ERROR_NO = ' || p_error_no);
 dbms_output.put_line('P_Error_Str = ' || p_error_str);

 RETURN;
 END IF;

 update_case_dtl(caseobjid ,user_objid ,'ACTIVE_ESN||' || new_esn ,p_error_no ,p_error_str);
 update_case_dtl(caseobjid ,user_objid ,'REPL_SIM_ID||' || v_repl_sim ,p_error_no ,p_error_str);

 END IF;
 --CR51022 changes end

END st_exchange;

PROCEDURE P_CREATE_CASE_BYOP(
 in_title IN VARCHAR2,
 in_case_type IN VARCHAR2,
 in_status IN VARCHAR2,
 in_priority IN VARCHAR2,
 in_issue IN VARCHAR2,
 in_source IN VARCHAR2,
 in_point_contact IN VARCHAR2,
 in_creation_time IN DATE,
 in_task_objid IN NUMBER,
 in_contact_objid IN NUMBER,
 in_user_objid IN NUMBER,
 in_esn IN VARCHAR2,
 in_phone_num IN VARCHAR2,
 in_first_name IN VARCHAR2,
 in_last_name IN VARCHAR2,
 in_e_mail IN VARCHAR2,
 in_delivery_type IN VARCHAR2,
 in_address IN VARCHAR2,
 in_city IN VARCHAR2,
 in_state IN VARCHAR2,
 in_zipcode IN VARCHAR2,
 in_repl_units IN NUMBER,
 in_fraud_objid IN NUMBER,
 in_case_detail IN VARCHAR2,
 in_part_request IN VARCHAR2,
 out_id_number OUT VARCHAR2,
 out_case_objid OUT NUMBER,
 out_error_no OUT VARCHAR2,
 out_error_str OUT VARCHAR2 )
IS
 /*
 CR29489 HPP BYOP 22-Aug-2014 vkashmire
 New procedure: P_CREATE_CASE_BYOP manages HPP BYOP case creation
 This procedure is copied from PROCEDURE CREATE_CASE
 */
 CURSOR line_reserved_cur (esn VARCHAR2)
 IS
 SELECT *
 FROM table_part_inst
 WHERE part_to_esn2part_inst IN
 (SELECT objid
 FROM table_part_inst
 WHERE part_serial_no = esn
 AND x_domain = 'PHONES'
 )
 AND x_domain = 'LINES'
 AND x_part_inst_status IN ('37', '39');
 line_reserved_rec line_reserved_cur%ROWTYPE;
 CURSOR sim_inv_cur (iccid VARCHAR2)
 IS
 SELECT x_sim_inv_status FROM table_x_sim_inv WHERE x_sim_serial_no = iccid;
 sim_inv_rec sim_inv_cur%ROWTYPE;
 CURSOR carrier_cur (ip_id VARCHAR2)
 IS
 SELECT x_mkt_submkt_name FROM table_x_carrier WHERE x_carrier_id = ip_id;
 carrier_rec carrier_cur%ROWTYPE;
 CURSOR instruc_curs (esn VARCHAR2, code VARCHAR2)
 IS
 SELECT *
 FROM x_special_instructions_list
 WHERE x_esn = esn
 AND x_instruc_code = code
 AND x_process_date IS NULL;
 instruc_rec instruc_curs%ROWTYPE;
 CURSOR domain_curs (part_num VARCHAR2)
 IS
 SELECT domain FROM table_part_num WHERE part_number = part_num;
 domain_rec domain_curs%ROWTYPE;
 CURSOR ff_center_curs (case_status VARCHAR2)
 IS
 SELECT x_ff_code
 FROM table_x_ff_center
 WHERE x_status_exception = case_status
 ORDER BY x_ranking ASC;
 ff_center_rec ff_center_curs%ROWTYPE;
 CURSOR address_curs
 IS
 SELECT cust_primaddr2address address_objid,
 table_site.objid site_objid
 FROM table_site,
 table_contact_role
 WHERE contact_role2site = table_site.objid
 AND contact_role2contact = in_contact_objid
 AND primary_site = 1;
 address_rec address_curs%ROWTYPE;
 CURSOR priority_curs
 IS
 SELECT elm.objid
 FROM table_gbst_elm elm,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Response Priority Code'
 AND elm.title = in_priority;
 priority_rec priority_curs%ROWTYPE;
 CURSOR priority_curs2
 IS
 SELECT elm.objid
 FROM table_gbst_elm elm,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Response Priority Code'
 AND elm.state = 2;
 CURSOR severity_curs
 IS
 SELECT elm.objid
 FROM table_gbst_elm elm,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Problem Severity Level'
 AND elm.state = 2;
 severity_rec severity_curs%ROWTYPE;
 CURSOR call_type_curs
 IS
 SELECT elm.objid
 FROM table_gbst_elm elm,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Case Type'
 AND elm.state = 2;
 call_type_rec call_type_curs%ROWTYPE;
 priority_rec2 priority_curs2%ROWTYPE;
 CURSOR status_curs
 IS
 SELECT elm.objid,
 elm.title
 FROM table_gbst_elm elm,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Open'
 AND elm.title = in_status;
 status_rec status_curs%ROWTYPE;
 CURSOR status_curs2
 IS
 SELECT elm.objid,
 elm.title
 FROM table_gbst_elm elm,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Open'
 AND elm.state = 2;
 status_rec2 status_curs2%ROWTYPE;
 CURSOR act_entry_gbst_curs
 IS
 SELECT elm.objid,
 lst.title
 FROM table_gbst_elm elm,
 table_gbst_lst lst
 WHERE gbst_elm2gbst_lst = lst.objid
 AND lst.title = 'Activity Name'
 AND elm.title LIKE 'Create';
 act_entry_gbst_rec act_entry_gbst_curs%ROWTYPE;
 CURSOR wipbin_curs
 IS
 SELECT objid FROM sa.table_wipbin WHERE wipbin_owner2user = in_user_objid;
 wipbin_rec wipbin_curs%ROWTYPE;
 -- BRAND_SEP
 CURSOR active_esn_curs
 IS
 SELECT sp.objid,
 sp.x_service_id x_esn,
 sp.x_min,
 sp.x_msid,
 sp.x_iccid,
 car.x_carrier_id,
 car.x_mkt_submkt_name,
 pn.part_number,
 pn.description,
 bo.org_id,
 s.name,
 sp.x_zipcode,
 pi_esn.warr_end_date
 FROM table_site s,
 table_inv_bin ib,
 table_part_num pn,
 table_mod_level ml,
 table_part_inst pi_esn,
 table_x_carrier car,
 table_part_inst pi_min,
 table_site_part sp,
 table_bus_org bo
 WHERE 1 = 1
 AND s.site_id = ib.bin_name
 AND ib.objid = pi_esn.part_inst2inv_bin
 AND pn.objid = ml.part_info2part_num
 AND ml.objid = pi_esn.n_part_inst2part_mod
 AND pi_esn.part_serial_no = in_esn
 AND car.objid = pi_min.part_inst2carrier_mkt
 AND pi_min.part_serial_no = sp.x_min
 AND sp.x_service_id = in_esn
 AND sp.part_status IN ('Active', 'CarrierPending')
 AND bo.objid = pn.part_num2bus_org;
 active_esn_rec active_esn_curs%ROWTYPE;
 -- BRAND_SEP
 CURSOR model_curs
 IS
 SELECT pi_esn.part_serial_no AS x_esn,
 pn.part_number,
 pn.description,
 s.name,
 pi_esn.x_part_inst2contact,
 pi_esn.x_hex_serial_no,
 bo.org_id, -- CR19490 Start kacosta 04/30/2012
 NVL (pi_esn.part_bad_qty, 0) + 1 AS exchange_counter, -- CR19490 End kacosta 04/30/2012
 bo.org_flow -- CR20451 | CR20854: Add TELCEL Brand
 FROM table_site s,
 table_inv_bin ib,
 table_part_num pn,
 table_mod_level ml,
 table_part_inst pi_esn,
 table_bus_org bo
 WHERE 1 = 1
 AND s.site_id = ib.bin_name
 AND ib.objid = pi_esn.part_inst2inv_bin
 AND pn.objid = ml.part_info2part_num
 AND ml.objid = pi_esn.n_part_inst2part_mod
 AND pi_esn.part_serial_no = in_esn
 AND bo.objid = pn.part_num2bus_org;
 model_rec model_curs%ROWTYPE;
 CURSOR warehouse_curs ( case_type VARCHAR2, case_title VARCHAR2)
 IS
 SELECT x_warehouse,
 x_instruct_type,
 x_instruct_code-- CR19490 Start kacosta 04/30/2012
 ,
 NVL (x_required_return, 0) x_required_return
 -- CR19490 End kacosta 04/30/2012
 FROM table_x_case_conf_hdr
 WHERE table_x_case_conf_hdr.x_case_type = case_type
 AND table_x_case_conf_hdr.x_title = case_title
 AND x_warehouse = 1;
 warehouse_rec warehouse_curs%ROWTYPE;
 CURSOR group2esn_curs
 IS
 SELECT grp.*
 FROM table_x_group2esn grp,
 table_part_inst pi
 WHERE grp.groupesn2part_inst = pi.objid
 -- CR16379 Start kacosta 03/12/2012
 AND SYSDATE BETWEEN NVL (grp.x_start_date, SYSDATE) AND NVL (grp.x_end_date, SYSDATE)
 -- CR16379 End kacosta 03/12/2012
 AND pi.part_serial_no = in_esn;
 -- BRAND_SEP
 CURSOR ship_curs ( repl_part_num VARCHAR2, case_type VARCHAR2, case_title VARCHAR2, zip_code VARCHAR2)
 IS
 SELECT x_shipping_cost,
 x_ff_code,
 x_shipping_method,
 x_service_level,
 x_courier_id,
 domain,
 x_ranking,
 x_technology
 FROM table_x_shipping_method,
 table_x_courier,
 table_x_shipping_master,
 table_x_case_conf_hdr,
 table_x_mtm_ffc2conf_hdr,
 table_x_ff_center,
 mtm_part_num22_x_ff_center2,
 table_part_num
 WHERE 1 = 1
 AND table_x_shipping_method.objid = table_x_shipping_master.master2method + 0
 AND table_x_courier.objid = table_x_shipping_master.master2courier + 0
 AND table_x_shipping_master.x_service_level <=
 (SELECT DISTINCT x_param_value
 FROM table_x_parameters
 WHERE x_param_name = 'SERVICE LEVEL'
 AND ROWNUM < 3000000000
 )
 AND table_x_shipping_master.x_weight = table_x_case_conf_hdr.x_weight
 AND table_x_shipping_master.x_zip_code = '99999' --zip_code
 AND table_x_shipping_master.master2ff_center = table_x_ff_center.objid
 AND table_x_case_conf_hdr.x_case_type
 || '' = case_type
 AND table_x_case_conf_hdr.x_title
 || '' = case_title
 AND table_x_case_conf_hdr.objid = table_x_mtm_ffc2conf_hdr.mtm_ffc2conf_hdr
 AND table_x_mtm_ffc2conf_hdr.mtm_ffc2ff_center = table_x_ff_center.objid
 AND table_x_ff_center.objid = mtm_part_num22_x_ff_center2.ff_center2part_num
 AND mtm_part_num22_x_ff_center2.part_num2ff_center = table_part_num.objid
 AND table_part_num.part_number = repl_part_num
 ORDER BY x_shipping_cost,
 x_ranking ASC;
 ship_rec ship_curs%ROWTYPE;
 /* CR29489 ; get the airbill part number for hpp byop */
 CURSOR AIRBILL_CUR
 IS
 SELECT PART_NUMBER AS X_AIRBIL_PART_NUMBER
 FROM TABLE_PART_NUM
 WHERE PART_NUMBER = 'HPP-BYOP-AIRBILL'
 AND DOMAIN = 'ACC';
 airbill_rec airbill_cur%ROWTYPE;
 new_case_objid NUMBER := seq ('case');
 new_condition_objid NUMBER := seq ('condition');
 new_act_entry_objid NUMBER := seq ('act_entry');
 --
 l_case_detail VARCHAR2 (5000) := in_case_detail;
 i PLS_INTEGER := 1;
TYPE case_detail_tab_type
IS
 TABLE OF VARCHAR2 (500) INDEX BY BINARY_INTEGER;
 case_detail_tab case_detail_tab_type;
 case_detail_tab2 case_detail_tab_type;
 clear_case_detail_tab case_detail_tab_type;
 /* --* HPP BYOP -- commented since will not be used
 l_part_request VARCHAR2 (5000) := p_part_request;
 i2 PLS_INTEGER := 1;
 */
TYPE part_request_tab_type
IS
 TABLE OF VARCHAR2 (500) INDEX BY BINARY_INTEGER;
 part_request_tab part_request_tab_type;
 clear_part_request_tab part_request_tab_type;
 new_case_id NUMBER := NULL;
 new_case_id_format VARCHAR2 (100) := NULL;
 ship_overwrite NUMBER := 0;
 warehouse_case BOOLEAN := FALSE;
 instruc_code VARCHAR2 (5) := '';
 instruc_type NUMBER := 0;
 instruc_ffc VARCHAR2 (30);
 instruc_cid VARCHAR2 (10);
 instruc_sm VARCHAR2 (30);
 nap_repl_part VARCHAR2 (30);
 nap_repl_tech VARCHAR2 (30);
 nap_sim_profile VARCHAR2 (30);
 nap_part_serial_no VARCHAR2 (30);
 nap_message VARCHAR2 (200);
 nap_pref_parent VARCHAR2 (30);
 nap_pref_carrid VARCHAR2 (30);
 tmp_case_details VARCHAR2 (1000);
 tmp_error_no VARCHAR2 (100);
 tmp_error_str VARCHAR2 (100);
 v_current_carrier_id VARCHAR2 (20);
 v_assigned_carrier_id VARCHAR2 (20);
 v_pr_status VARCHAR2 (30);
 v_reserved_min VARCHAR2 (30);
 --CR21111 Start NGUADA
 /* v_airbill_added boolean := false; */
 -- HPP BYOP commented since not required
 /* v_airbill_needed boolean := false; */
 -- HPP BYOP commented since not required
 v_airbill_part_num VARCHAR2 (30);
 --CR21111 End NGUADA
 --CDMA NAVAIL
BEGIN
 dbms_output.enable;
 out_error_no := '0';
 out_error_str := 'SUCCESS';
 dbms_output.put_line ('*** sa.clarify_case_pkg.p_create_case_byop started *** ');
 dbms_output.put_line ('in_title = ' || in_title ||', in_part_request = '|| in_part_request || ', l_case_detail='|| l_case_detail );
 OPEN address_curs;
 FETCH address_curs INTO address_rec;
 IF in_priority IS NOT NULL THEN
 OPEN priority_curs;
 FETCH priority_curs INTO priority_rec;
 IF priority_curs%NOTFOUND THEN
 OPEN priority_curs2;
 FETCH priority_curs2 INTO priority_rec;
 CLOSE priority_curs2;
 END IF;
 CLOSE priority_curs;
 ELSE
 OPEN priority_curs2;
 FETCH priority_curs2 INTO priority_rec;
 CLOSE priority_curs2;
 END IF;
 OPEN severity_curs;
 FETCH severity_curs INTO severity_rec;
 CLOSE severity_curs;
 OPEN call_type_curs;
 FETCH call_type_curs INTO call_type_rec;
 CLOSE call_type_curs;
 IF in_status IS NOT NULL THEN
 OPEN status_curs;
 FETCH status_curs INTO status_rec;
 IF status_curs%NOTFOUND THEN
 OPEN status_curs2;
 FETCH status_curs2 INTO status_rec;
 CLOSE status_curs2;
 END IF;
 CLOSE status_curs;
 ELSE
 OPEN status_curs2;
 FETCH status_curs2 INTO status_rec;
 CLOSE status_curs2;
 END IF;
 OPEN active_esn_curs;
 FETCH active_esn_curs INTO active_esn_rec;
 CLOSE active_esn_curs;
 OPEN model_curs;
 FETCH model_curs INTO model_rec;
 IF model_curs%FOUND THEN
 IF model_rec.x_part_inst2contact IS NULL THEN
 UPDATE table_part_inst
 SET x_part_inst2contact = in_contact_objid
 WHERE part_serial_no = model_rec.x_esn;
 COMMIT;
 END IF;
 END IF;
 CLOSE model_curs;
 OPEN act_entry_gbst_curs;
 FETCH act_entry_gbst_curs INTO act_entry_gbst_rec;
 CLOSE act_entry_gbst_curs;
 OPEN wipbin_curs;
 FETCH wipbin_curs INTO wipbin_rec;
 CLOSE wipbin_curs;
 next_id ('Case ID', new_case_id, new_case_id_format);
 DBMS_OUTPUT.put_line ('New case id generated :' || new_case_id);
 out_id_number := new_case_id;
 DBMS_OUTPUT.put_line ('out_ID_NUMBER:' || out_id_number);
 INSERT
 INTO sa.table_condition
 (
 objid,
 condition,
 title,
 s_title,
 wipbin_time,
 sequence_num
 )
 VALUES
 (
 new_condition_objid,
 2,
 'Open',
 'OPEN',
 SYSDATE,
 0
 );
 INSERT
 INTO sa.table_act_entry
 (
 objid,
 act_code,
 entry_time,
 addnl_info,
 act_entry2case,
 act_entry2user,
 entry_name2gbst_elm
 )
 VALUES
 (
 new_act_entry_objid,
 600,
 SYSDATE,
 ' Contact = '
 || in_first_name
 || ' '
 || in_last_name,
 new_case_objid,
 in_user_objid,
 act_entry_gbst_rec.objid
 );
 --*** Next 7 lines are not required for HPP BYOP . Pls remove
 -- try to find reserved min if any for ST Defective Phone
 /* --* HPP BYOP -- commented since will not be used
 IF active_esn_rec.x_min IS NULL AND in_title = 'ST Defective Phone'
 THEN
 OPEN line_reserved_cur (model_rec.x_esn);
 FETCH line_reserved_cur INTO line_reserved_rec;
 CLOSE line_reserved_cur;
 v_reserved_min := line_reserved_rec.part_serial_no;
 END IF;
 */
 DBMS_OUTPUT.put_line ( '>>>>>>>>>>>>>>>>>>>>>>>>>>>>active_esn_rec.warr_end_date ' || active_esn_rec.warr_end_date);
 INSERT
 INTO table_case
 (
 objid,
 title,
 s_title,
 id_number,
 x_case_type,
 respprty2gbst_elm,
 casests2gbst_elm,
 case_type_lvl1,
 case_type_lvl2,
 case_type_lvl3,
 customer_code,
 creation_time,
 x_case2task,
 case_reporter2contact,
 case_owner2user,
 case_originator2user,
 x_esn,
 x_min,
 x_msid,
 x_iccid,
 x_carrier_id,
 x_text_car_id,
 x_carrier_name,
 x_model,
 x_phone_model,
 x_retailer_name,
 x_activation_zip,
 alt_phone,
 alt_first_name,
 alt_last_name,
 alt_e_mail,
 alt_site_name,
 alt_address,
 alt_city,
 alt_state,
 alt_zipcode,
 x_replacement_units,
 case_state2condition,
 case_wip2wipbin,
 respsvrty2gbst_elm,
 cure_code,
 calltype2gbst_elm,
 case2address,
 case_reporter2site,
 is_supercase
 )
 VALUES
 (
 new_case_objid,
 SUBSTR (in_title, 1, 80),
 SUBSTR (UPPER (in_title), 1, 80),
 new_case_id,
 SUBSTR (in_case_type, 1, 30),
 priority_rec.objid,
 status_rec.objid,
 SUBSTR (IN_ISSUE, 1, 255), --CR22404
 /* --* HPP BYOP -- decode NOT REQUIRED since in_title will have only one value for hpp byop
 DECODE (in_title,
 'Lifeline Shipment', 'LIFELINE',
 'Business Sales Direct Shipment', 'B2B-DIRECT',
 'Business Sales Service Shipment', 'B2B-SERVICES',
 'SafeLink BroadBand Shipment' --CR23889
 , 'SL-BROADBAND' --CR23889
 ,
 DECODE (v_saf_esn, 0, model_rec.org_id, 'SAFELINK')), --CR19376 */
 model_rec.org_id,
 /* HPP BYOP ; no decode req'd for column - CASE_TYPE_LVL2 - directly use Org id */
 SUBSTR (in_source, 1, 30),
 SUBSTR (in_point_contact, 1, 20),
 SYSDATE,
 in_task_objid,
 in_contact_objid,
 in_user_objid,
 in_user_objid,
 DECODE (model_rec.x_esn, 'TFSHIPLL_DUMMY_ESN', 'TFSHIPLL_'
 || new_case_id, model_rec.x_esn),
 NVL (active_esn_rec.x_min, v_reserved_min),
 active_esn_rec.x_msid,
 active_esn_rec.x_iccid,
 active_esn_rec.x_carrier_id,
 TO_CHAR (active_esn_rec.x_carrier_id),
 SUBSTR (active_esn_rec.x_mkt_submkt_name, 1, 30),
 SUBSTR (model_rec.part_number, 1, 20),
 SUBSTR (model_rec.description, 1, 30),
 SUBSTR (model_rec.name, 1, 80),
 active_esn_rec.x_zipcode,
 in_phone_num,
 in_first_name,
 in_last_name,
 in_e_mail,
 in_delivery_type,
 in_address,
 in_city,
 in_state,
 in_zipcode,
 in_repl_units,
 new_condition_objid,
 wipbin_rec.objid,
 severity_rec.objid,
 active_esn_rec.warr_end_date,
 call_type_rec.objid,
 NVL (address_rec.address_objid, 0),
 NVL (address_rec.site_objid, 0),
 DECODE (NVL (in_fraud_objid, 0), 0, 0, 1)
 );
 -- Case Promotions
 FOR group2esn_rec IN group2esn_curs
 LOOP
 INSERT
 INTO table_x_case_promotions
 (
 objid,
 x_start_date,
 x_end_date,
 x_annual_plan,
 case_promo2promotion,
 case_promo2promo_grp,
 case_promo2case
 )
 VALUES
 (
 sa.seq ('x_case_promotions'),
 group2esn_rec.x_start_date,
 group2esn_rec.x_end_date,
 group2esn_rec.x_annual_plan,
 group2esn_rec.groupesn2x_promotion,
 group2esn_rec.groupesn2x_promo_group,
 new_case_objid
 );
 dbms_output.put_line ('inserted a record in table_x_case_promotions...new_case_objid='||new_case_objid);
 END LOOP;
 -- START ST BUNDLE 3
 -- CR15570 Start KACOSTA 05/12/2011
 --if active_esn_rec.objid is not null and p_title = 'ST Defective Phone' then
 -- if l_case_detail is not null and substr(l_case_detail,-2) <> '||' then
 -- l_case_detail:=l_case_detail||'||';
 -- end if;
 -- l_case_detail:=l_case_detail||'ACTIVE_SITE_PART||'||active_esn_rec.objid||'||ACTIVE_ESN||'||active_esn_rec.x_esn||'||DUE_DATE||'||to_char(active_esn_rec.warr_end_date,'mm/dd/yyyy');
 --end if;
 IF active_esn_rec.objid IS NOT NULL -- CR20451 | CR20854: Add TELCEL Brand
 -- AND model_rec.org_id = 'STRAIGHT_TALK'
 AND model_rec.org_flow = '3' AND in_case_type = 'Warranty' THEN
 --
 IF l_case_detail IS NOT NULL THEN
 --
 l_case_detail := 'ACTIVE_SITE_PART||' || active_esn_rec.objid || '||ACTIVE_ESN||' || active_esn_rec.x_esn || '||DUE_DATE||' || TO_CHAR (active_esn_rec.warr_end_date , 'MM/DD/YYYY') || '||' || l_case_detail;
 --
 ELSE
 --
 l_case_detail := 'ACTIVE_SITE_PART||' || active_esn_rec.objid || '||ACTIVE_ESN||' || active_esn_rec.x_esn || '||DUE_DATE||' || TO_CHAR (active_esn_rec.warr_end_date , 'MM/DD/YYYY');
 --
 END IF;
 --
 END IF;
 -- CR15570 END KACOSTA 05/12/2011
 -- END ST BUNDLE 3
 --relation with Fraud Case
 IF NVL (in_fraud_objid, 0) > 0 THEN
 UPDATE table_case
 SET case_victim2case = new_case_objid
 WHERE objid = in_fraud_objid;
 COMMIT;
 END IF;
 out_case_objid := new_case_objid;
 IF l_case_detail IS NOT NULL THEN
 case_detail_tab := clear_case_detail_tab;
 case_detail_tab2 := clear_case_detail_tab;
 WHILE LENGTH (l_case_detail) > 0
 LOOP
 DBMS_OUTPUT.put_line ('l_case_detail 1:' || l_case_detail);
 IF INSTR (l_case_detail, '||') = 0 THEN
 case_detail_tab (i) := LTRIM (RTRIM (l_case_detail));
 case_detail_tab2 (i) := LTRIM (RTRIM (l_case_detail));
 EXIT;
 ELSE
 case_detail_tab (i) := LTRIM (RTRIM (SUBSTR (l_case_detail, 1, INSTR (l_case_detail, '||') - 1)));
 DBMS_OUTPUT.put_line ('1:' || case_detail_tab (i));
 l_case_detail := LTRIM (RTRIM (SUBSTR (l_case_detail, INSTR (l_case_detail, '||') + 2)));
 --
 IF INSTR (l_case_detail, '||') = 0 THEN
 case_detail_tab2 (i) := LTRIM (RTRIM (l_case_detail));
 ELSE
 case_detail_tab2 (i) := LTRIM ( RTRIM (SUBSTR (l_case_detail, 1, INSTR (l_case_detail, '||') - 1)));
 DBMS_OUTPUT.put_line ('0:' || case_detail_tab (i));
 l_case_detail := LTRIM (RTRIM (SUBSTR (l_case_detail, INSTR (l_case_detail, '||') + 2)));
 END IF;
 i := i + 1;
 DBMS_OUTPUT.put_line ('l_case_detail 2:' || l_case_detail);
 END IF;
 END LOOP;
 DBMS_OUTPUT.put_line ('fin:' || i);
 FOR j IN 1 .. i - 1
 LOOP
 DBMS_OUTPUT.put_line ('fin(' || j || '):' || case_detail_tab (j));
 DBMS_OUTPUT.put_line ('fin2(' || j || '):' || case_detail_tab2 (j));
 END LOOP;
 FOR j IN 1 .. i - 1
 LOOP
 IF case_detail_tab (j) LIKE '%CURRENT_CARRIER_ID%' THEN
 v_current_carrier_id := case_detail_tab2 (j);
 END IF;
 IF case_detail_tab (j) LIKE '%ASSIGNED_CARRIER_ID%' THEN
 v_assigned_carrier_id := case_detail_tab2 (j);
 END IF;
 INSERT
 INTO table_x_case_detail
 (
 objid,
 x_name,
 x_value,
 detail2case
 )
 VALUES
 (
 seq ('x_case_detail'),
 case_detail_tab (j),
 case_detail_tab2 (j),
 new_case_objid
 );
 END LOOP;
 END IF;
 --start CR6254 Adding the MEID hex number as a case detail
 IF model_rec.x_hex_serial_no IS NOT NULL THEN
 INSERT
 INTO table_x_case_detail
 (
 objid,
 x_name,
 x_value,
 detail2case
 )
 VALUES
 (
 seq ('x_case_detail'),
 'HEX',
 model_rec.x_hex_serial_no,
 new_case_objid
 );
 END IF;
 --TMODATA start
 IF v_current_carrier_id IS NOT NULL THEN
 OPEN carrier_cur (TO_NUMBER (v_current_carrier_id));
 FETCH carrier_cur INTO carrier_rec;
 CLOSE carrier_cur;
 tmp_case_details := 'CURRENT_CARRIER||' || carrier_rec.x_mkt_submkt_name;
 update_case_dtl (new_case_objid, in_user_objid, tmp_case_details, tmp_error_no, tmp_error_str);
 END IF;
 IF v_assigned_carrier_id IS NOT NULL THEN
 OPEN carrier_cur (TO_NUMBER (v_assigned_carrier_id));
 FETCH carrier_cur INTO carrier_rec;
 CLOSE carrier_cur;
 tmp_case_details := 'ASSIGNED_CARRIER||' || carrier_rec.x_mkt_submkt_name;
 update_case_dtl (new_case_objid, in_user_objid, tmp_case_details, tmp_error_no, tmp_error_str);
 END IF;
 tmp_case_details := 'LINE_STATUS||' || status_desc_func (status_part_inst (active_esn_rec.x_min, 'LINES'));
 tmp_case_details := tmp_case_details || '||PHONE_STATUS||' || status_desc_func ( status_part_inst (active_esn_rec.x_min, 'LINES'));
 update_case_dtl (new_case_objid, in_user_objid, tmp_case_details, tmp_error_no, tmp_error_str);
 IF active_esn_rec.x_iccid IS NOT NULL THEN
 OPEN sim_inv_cur (active_esn_rec.x_iccid);
 FETCH sim_inv_cur INTO sim_inv_rec;
 IF sim_inv_cur%FOUND THEN
 tmp_case_details := 'SIM_ID||' || active_esn_rec.x_iccid || '||SIM_STATUS||' || status_desc_func ( sim_inv_rec.x_sim_inv_status) || '||REPL_SIM_ID||';
 update_case_dtl (new_case_objid, in_user_objid, tmp_case_details, tmp_error_no, tmp_error_str);
 END IF;
 CLOSE sim_inv_cur;
 END IF;
 --TMODATA end
 --end CR6254
 OPEN ff_center_curs (status_rec.title);
 FETCH ff_center_curs INTO ff_center_rec;
 IF ff_center_curs%FOUND THEN
 ship_overwrite := 1;
 END IF;
 OPEN warehouse_curs (in_case_type, in_title);
 FETCH warehouse_curs INTO warehouse_rec;
 IF warehouse_curs%FOUND THEN
 --
 -- CR19490 Start kacosta 04/30/2012
 IF (warehouse_rec.x_required_return = 1) THEN
 --
 tmp_case_details := 'EXCHANGE_COUNTER||' || TO_CHAR (model_rec.exchange_counter);
 --
 update_case_dtl (p_case_objid => new_case_objid, p_user_objid => in_user_objid, p_case_detail => tmp_case_details, p_error_no => tmp_error_no, p_error_str => tmp_error_str);
 --
 --Return required check if airbill is requried also
 OPEN airbill_cur ;
 FETCH AIRBILL_CUR INTO AIRBILL_REC;
 IF AIRBILL_CUR%FOUND THEN
 v_airbill_part_num := airbill_rec.x_airbil_part_number;
 DBMS_OUTPUT.PUT_LINE(' airbill needed = true ....model_rec.part_number= '||MODEL_REC.PART_NUMBER );
 ELSE
 DBMS_OUTPUT.PUT_LINE('airbill_cur not found ');
 END IF;
 CLOSE airbill_cur;
 END IF;
 -- CR19490 End kacosta 04/30/2012
 --
 warehouse_case := TRUE;
 IF NVL (warehouse_rec.x_instruct_type, 0) = 1 THEN
 instruc_code := warehouse_rec.x_instruct_code;
 instruc_type := 1;
 ELSE
 IF NVL (warehouse_rec.x_instruct_type, 0) = 2 THEN
 OPEN instruc_curs (in_esn, warehouse_rec.x_instruct_code);
 FETCH instruc_curs INTO instruc_rec;
 IF instruc_curs%FOUND THEN
 instruc_code := warehouse_rec.x_instruct_code;
 instruc_type := 2;
 END IF;
 CLOSE instruc_curs;
 END IF;
 END IF;
 END IF;
 CLOSE warehouse_curs;
 /* IF l_part_request IS NOT NULL AND warehouse_case
 THEN
 */
 IF warehouse_case THEN
 dbms_output.put_line ('inside "if warehouse_case then" ...');
 /* --* HPP BYOP commented since will not be used
 part_request_tab := clear_part_request_tab;
 WHILE LENGTH (l_part_request) > 0
 LOOP
 IF INSTR (l_part_request, '||') = 0
 THEN
 part_request_tab (i2) := LTRIM (RTRIM (l_part_request));
 dbms_output.put_line ('part_request_tab ('||i2||') = '|| part_request_tab (i2) );
 EXIT;
 ELSE
 part_request_tab (i2) :=
 LTRIM (
 RTRIM (SUBSTR (l_part_request, 1, INSTR (l_part_request, '||') - 1)));
 --CR6073
 -- l_part_request := LTRIM (RTRIM (SUBSTR (l_part_request, INSTR (l_part_request, '||') + 1)));
 l_part_request :=
 LTRIM (RTRIM (SUBSTR (l_part_request, INSTR (l_part_request, '||') + 2)));
 --CR6073
 dbms_output.put_line ('part_request_tab ('||i2||') = '|| part_request_tab (i2) );
 i2 := i2 + 1;
 END IF;
 END LOOP;
 */
 /* --* HPP BYOP commented since will not be used
 FOR j IN 1 .. i2
 LOOP
 --CR18850 Start Kacosta 02/23/2012
 ship_rec := NULL;
 --CR18850 End Kacosta 02/23/2012
 OPEN ship_curs (part_request_tab (j),
 p_case_type,
 p_title,
 p_zipcode);
 FETCH ship_curs INTO ship_rec;
 CLOSE ship_curs;
 IF ship_rec.domain IS NULL
 THEN
 OPEN domain_curs (part_request_tab (j));
 FETCH domain_curs INTO domain_rec;
 CLOSE domain_curs;
 END IF;
 IF ship_overwrite = 0
 THEN
 v_pr_status := 'PENDING';
 ELSE
 v_pr_status := 'INCOMPLETE';
 END IF;
 DBMS_OUTPUT.put_line ('domain:' || NVL (ship_rec.domain, domain_rec.domain));
 DBMS_OUTPUT.put_line ('title:' || p_title);
 IF NVL (ship_rec.domain, domain_rec.domain) = 'PHONES'
 AND warehouse_rec.x_required_return = 1
 AND v_airbill_needed = TRUE
 THEN
 -- Warehouse Case requires handset returned
 v_pr_status := 'ONHOLDST';
 END IF;
 IF part_request_tab (j) LIKE '%AIRBILL%'
 THEN
 v_airbill_added := TRUE; --Airbill added
 END IF;
 DBMS_OUTPUT.put_line ('pr status:' || v_pr_status);
 dbms_output.put_line ('inserting in table_x_part_request ... part_request_tab (j) = ' || part_request_tab (j) );
 INSERT INTO table_x_part_request (objid,
 x_action,
 x_repl_part_num,
 x_part_serial_no,
 x_ff_center,
 x_ship_date,
 x_est_arrival_date,
 x_received_date,
 x_courier,
 x_shipping_method,
 x_tracking_no,
 x_status,
 request2case,
 x_insert_date,
 x_part_num_domain,
 x_service_level,
 x_quantity)
 VALUES (
 seq ('x_part_request'),
 'SHIP',
 part_request_tab (j),
 NULL,
 DECODE (ship_overwrite,
 0, ship_rec.x_ff_code,
 ff_center_rec.x_ff_code),
 NULL,
 NULL,
 NULL,
 DECODE (ship_overwrite, 0, ship_rec.x_courier_id, NULL),
 DECODE (ship_overwrite, 0, ship_rec.x_shipping_method, NULL),
 NULL,
 v_pr_status,
 new_case_objid,
 SYSDATE,
 NVL (ship_rec.domain, domain_rec.domain),
 ship_rec.x_service_level,
 1);
 SELECT DECODE (ship_overwrite, 0, ship_rec.x_ff_code, ff_center_rec.x_ff_code)
 INTO instruc_ffc
 FROM DUAL;
 SELECT DECODE (ship_overwrite, 0, ship_rec.x_courier_id, NULL)
 INTO instruc_cid
 FROM DUAL;
 SELECT DECODE (ship_overwrite, 0, ship_rec.x_shipping_method, NULL)
 INTO instruc_sm
 FROM DUAL;
 END LOOP;
 */
 IF v_airbill_part_num IS NOT NULL THEN
 dbms_output.put_line ('v_airbill_part_num='||v_airbill_part_num);
 part_request_add (strcaseobjid => new_case_objid, strpartnumber => v_airbill_part_num, p_quantity => 1, p_user_objid => in_user_objid, P_SHIPPING => NULL, p_error_no => tmp_error_no, P_ERROR_STR => TMP_ERROR_STR);
 ELSE
 dbms_output.put_line ('HPP BYOP AIRBILL part number not found');
 out_error_no := -100;
 out_error_str := 'HPP BYOP AIRBILL part number not found';
 END IF;
 --CR21111 End NGUADA
 --special instructions
 IF NVL (instruc_code, '0') <> '0' THEN
 dbms_output.put_line ('instruc_code= ' || instruc_code || ', inserting in table_x_part_request');
 INSERT
 INTO table_x_part_request
 (
 objid,
 x_action,
 x_repl_part_num,
 x_part_serial_no,
 x_ff_center,
 x_ship_date,
 x_est_arrival_date,
 x_received_date,
 x_courier,
 x_shipping_method,
 x_tracking_no,
 x_status,
 request2case,
 x_insert_date,
 x_part_num_domain,
 x_service_level,
 x_quantity
 )
 VALUES
 (
 seq ('x_part_request'),
 'SHIP',
 instruc_code,
 NULL,
 instruc_ffc,
 NULL,
 NULL,
 NULL,
 instruc_cid,
 instruc_sm,
 NULL,
 'PENDING',
 new_case_objid,
 SYSDATE,
 'INSTRUCTION',
 NULL,
 1
 );
 UPDATE x_special_instructions_list
 SET x_process_date = sysdate
 WHERE x_esn = in_esn
 AND x_instruc_code = instruc_code
 AND x_process_date IS NULL;
 COMMIT;
 END IF;
 END IF;
 --Part Request Needed, Inserted Dummy One
 /*
 IF p_part_request IS NULL
 AND warehouse_case
 AND p_title <> 'Lifeline Shipment'
 AND p_title <> 'SafeLink BroadBand Shipment'
 THEN -- Ramu: Modify here to add new Safelink broadband case title CR23889
 INSERT INTO table_x_part_request (objid,
 x_action,
 x_repl_part_num,
 x_part_serial_no,
 x_ff_center,
 x_ship_date,
 x_est_arrival_date,
 x_received_date,
 x_courier,
 x_shipping_method,
 x_tracking_no,
 x_status,
 request2case,
 x_insert_date,
 x_part_num_domain,
 x_service_level,
 x_quantity)
 VALUES (seq ('x_part_request'),
 'SHIP',
 NULL,
 NULL,
 'MM_IO',
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 'INCOMPLETE',
 new_case_objid,
 SYSDATE,
 NULL,
 NULL,
 1);
 END IF;
 */
 --START B2B case Port In Case Notification
 /* --** CR29489 commenting
 IF p_title = 'Port In' AND p_case_type = 'Port In'
 THEN
 DECLARE
 CURSOR emails_cur
 IS
 SELECT *
 FROM table_x_parameters
 WHERE x_param_name = 'B2B_PORT_CREATED_NOTIFICATION';
 emails_rec emails_cur%ROWTYPE;
 email_dtl VARCHAR2 (200)
 := 'B2B Port: ' || new_case_id || ' Created ' || TO_CHAR (SYSDATE,
 'mm/dd/yyyy hh:mi AM');
 result VARCHAR2 (500);
 BEGIN
 FOR emails_rec IN emails_cur
 LOOP
 send_mail (subject_txt => 'B2B Port: ' || new_case_id || ' Created',
 msg_from => 'noreply@tracfone.com',
 send_to => emails_rec.x_param_value,
 message_txt => email_dtl,
 result => result);
 END LOOP;
 EXCEPTION
 WHEN OTHERS
 THEN
 NULL;
 END;
 END IF;
 -- END B2B case Port In Case Notification
 COMMIT;
 */
EXCEPTION
WHEN OTHERS THEN
 out_error_no := SQLCODE;
 out_error_str := SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,500) ;
END P_CREATE_CASE_BYOP;


    procedure express_activation (ip_debugger_switch varchar2,
                                  ip_short_esn varchar2, -- last 4 digit esn
                                  ip_min varchar2,
                                  ip_client_id varchar2,
                                  ip_transaction_id varchar2,
                                  ip_org_id varchar2,
                                  ip_source_system varchar2,
                                  ip_language varchar2,
                                  ip_login varchar2,
                                  ip_case_id varchar2,
                                  ip_units varchar2,
                                  op_code out varchar2,
                                  op_message out varchar2,
                                  op_action out varchar2,
                                  op_service_plan out varchar2,
                                  op_service_plan_desc out varchar2,
                                  op_units out varchar2,
                                  op_sms out varchar2,
                                  op_data out varchar2,
                                  op_esn out varchar2,
                                  op_min out varchar2,
                                  op_zip out varchar2,
                                  op_new_esn out varchar2,
                                  op_new_sim out varchar2,
                                  op_new_esn_pc out varchar2,
                                  op_new_esn_pn out varchar2,
                                  op_service_end_date out varchar2,
                                  op_ticket_number out varchar2,
                                  op_contact_objid out varchar2
)
    is
      v_display_info clob;
      pi_objid                      table_part_inst.objid%type;
      case_esn_last_four            varchar2(4);
      line_status                   table_part_inst.x_part_inst_status%type;
      reserved_min_esn              table_part_inst.part_serial_no%type;
      case_esn                      table_part_inst.part_serial_no%type;
      part_req_esn                  table_part_inst.part_serial_no%type;
      ship_status                   table_x_part_request.x_status%type;
      case_objid                    table_case.objid%type;
      v_projected_end_date          date;
      v_replacement_units           table_case.x_replacement_units%type;
      v_units_to_transfer           table_x_case_detail.x_value%type;
      v_max_units_to_transfer       table_x_case_detail.x_value%type;
      v_service_days                table_x_case_detail.x_value%type;
      port_in_progress              varchar2(3);
      old_esn_proj_end_date         date;
      new_esn_proj_end_date         date;
      old_esn_zip                   sa.table_site_part.x_zipcode%type;
      new_esn_zip                   sa.table_site_part.x_zipcode%type;
      old_esn_contact_objid         number;
      new_esn_contact_objid         number;
      web_user_objid                number;
      job_objid                     number;
      create_job_err_str            varchar2(2000);
      user_objid                    number;
      old_esn_pc                    varchar2(30);
      old_esn_ppe_val               varchar2(30);
      new_esn_ppe_val               varchar2(30);
      p_service_type                varchar2(200);
      p_program_type                varchar2(200);
      p_next_charge_date            date;
      p_program_units               number;
      p_program_days                number;
      p_rate_plan                   varchar2(200);
      p_x_prg_script_id             varchar2(200);
      p_x_prg_desc_script_id        varchar2(200);
      p_error_num                   number;
      no_service_transfer           boolean := false;

      reserved_min_status           sa.table_part_inst.x_part_inst_status%type;

      new_esn_status sa.table_part_inst.x_part_inst_status%type;
      old_esn_status sa.table_part_inst.x_part_inst_status%type;

      op_3ci_err_no                 number;

      sp_part_status                varchar2(30);
      sp_esn                        varchar2(30);
      v_dummy_val                   varchar2(2000); -- USED FOR GET_PROGRAM_INFO, AS OF 4/11/2016 WE ONLY NEED TO EXTRACT THE SERVICE PLAN ID AND DESCRIPTION

      CURSOR cur_get_sp_detail(c_esn VARCHAR2)
      IS
        SELECT tsp.x_service_id ,
          tsp.x_expire_dt ,
          sp.*
        FROM x_service_plan_hist sph ,
          table_site_part tsp ,
          x_service_plan sp
        WHERE 1                     = 1
        AND sph.plan_hist2site_part = tsp.objid
        AND sp.objid                = sph.plan_hist2service_plan
        and tsp.x_service_id        = c_esn
        ORDER BY sph.x_start_date DESC;
      cur_get_sp_detail_rec cur_get_sp_detail%rowtype;

      ----------------------------------------------------------------------------
      procedure d_rslt(debugger_switch varchar2, info clob)
      is
      begin
        if debugger_switch = 'Y' then
          if info is not null then
            dbms_output.put_line(info);
          else
          dbms_output.put_line(v_display_info||chr(10));
          end if;
        end if;
      end d_rslt;
      ----------------------------------------------------------------------------
      function ret_c_objid (part_inst_objid varchar2, old_esn varchar2)
      return varchar2
      is
        c_objid number;
      begin
          for i in (select x_contact_part_inst2contact
                    from table_x_contact_part_inst
                    where x_contact_part_inst2part_inst = part_inst_objid)
          loop
            c_objid := i.x_contact_part_inst2contact;
          end loop;
          -- IF CONTACT OBJID IS NULL PULL IT FROM THE CASE ESN
          if c_objid is null then
            for i in (select pn.part_number,pc.name,pi.x_iccid,pi.x_part_inst2contact,pi.objid
                      from   table_mod_level m ,
                             table_part_num pn ,
                             table_part_inst pi ,
                             table_part_class pc
                      where pi.part_serial_no     = old_esn
                      and pi.n_part_inst2part_mod = m.objid
                      and m.part_info2part_num    = pn.objid
                      and pn.part_num2part_class  = pc.objid
                      )
            loop
              c_objid := i.x_part_inst2contact;
            end loop;
          end if;
          return c_objid;
      exception
        when others then
          return null;
      end ret_c_objid;
      ----------------------------------------------------------------------------
  begin
    -- 3 SCENARIOS
    -- 1 MIN ONLY
    -- 2 MIN AND LAST FOUR OF ESN
    -- 3 MIN AND CASE ID

    op_code := '0';
    op_message := 'SUCCESS';
    op_min := ip_min;
    v_display_info := '1. OBTAIN THE ESN THAT THE MIN IS ATTACHED TO';
    ----------------------------------------------------------------------------
    -- VALIDATIONS FOR ONLY MIN PROVIDED ---------------------------------------
    ----------------------------------------------------------------------------
     begin
      -- SITE PART SEARCH -- THIS IS THE ASSUMED OLD ESN
      for i in (
                select part_status, a.x_service_id, a.x_zipcode
                from sa.table_site_part a
                where 1=1
                and a.x_min = ip_min
                and a.install_date = (select max(install_date)
                                      from   sa.table_site_part
                                      where 1=1
                                      and x_min = ip_min)
                )
      loop
        if sp_part_status is null then
          sp_part_status := i.part_status;
          sp_esn := i.x_service_id;
          new_esn_zip := trim(i.x_zipcode);
        end if;
      end loop;
     exception
      when others then
        null;
     end;

    begin
      -- RESERVED MIN SEARCH
      select p.part_serial_no, l.x_part_inst_status, decode(p.x_port_in,1,'Yes','No'),p.x_part_inst_status
      into   reserved_min_esn, line_status, port_in_progress,reserved_min_status
      from   table_part_inst p,
             table_part_inst l
      where  1=1
      and    p.x_domain = 'PHONES'
      and    l.x_domain = 'LINES'
      and    p.objid = l.part_to_esn2part_inst
      and    l.part_serial_no = ip_min
      and rownum <2;
    exception
      when others then
        if instr(sqlerrm,'01403') >0 then
          op_code := '1';
          op_message := 'UNABLE TO FIND MIN';
        else
          op_code := '-1';
          op_message := 'ERROR - '||SQLERRM;
        end if;
        return;
    end;

    v_display_info := v_display_info||' ('||reserved_min_esn||')'||chr(10);
    v_display_info := v_display_info||'1.5. SITE PART SEARCH OF ESN ('||sp_esn||')'||chr(10);

    if sp_esn != reserved_min_esn then -- SITE PART ESN AND RESERVED ESN ARE DIFFERENT
      if lower(sp_part_status) = lower('Inactive') and line_status = '39' then -- SITE PART ESN IS INACTIVE AND MIN IS RESERVED TO A DIFFERENT LINE
        -- GRAB THE CASE INFO NOW


        -- COLLECT CASE PART REQUEST INFO
        for i in (
                  select c.objid,c.id_number,c.x_case_type,c.title,c.x_iccid,c.x_esn,c.x_msid,p.x_action,p.x_repl_part_num,p.x_part_serial_no,p.x_ship_date,p.x_est_arrival_date,p.x_tracking_no,p.x_status,p.x_part_num_domain,p.x_insert_date,p.x_last_update_stamp,p.x_quantity
                  from table_x_part_request p, table_case c
                  where c.objid = p.request2case
                  and (c.x_esn = sp_esn -- OLD ESN
                  and x_part_serial_no = reserved_min_esn) -- NEW ESN
                  and x_status = 'SHIPPED'
                  -- WE NEED NOT WORRY ABOUT THE DATE OR SHIP CONFIRMED BECAUSE THIS MEANS THE SHIP CONFIRMED WAS ALREADY DONE
                )
        loop
          case_objid := i.objid;
          op_ticket_number  := i.id_number;
          op_esn := i.x_esn;
          op_new_esn := i.x_part_serial_no;
          ship_status := i.x_status;
        end loop;
      end if;
    end if;

    if sp_esn = reserved_min_esn then
      -- CHECK A CASE EXISTS.
      for i in (
                select c.objid,c.id_number,c.x_case_type,c.title,c.x_iccid,c.x_esn,c.x_msid,p.x_action,p.x_repl_part_num,p.x_part_serial_no,p.x_ship_date,p.x_est_arrival_date,p.x_tracking_no,p.x_status,p.x_part_num_domain,p.x_insert_date,p.x_last_update_stamp,p.x_quantity
                from table_x_part_request p, table_case c
                where c.objid = p.request2case
                and (c.x_esn = sp_esn) -- OLD ESN
                and x_status not in ('CANCELLED','CANCELLED_REQUEST')
              )
      loop
        case_objid := i.objid;
        op_ticket_number  := i.id_number;
        op_esn := i.x_esn;
        op_new_esn := i.x_part_serial_no;
        ship_status := i.x_status;
      end loop;
    end if;

    v_display_info := v_display_info||'2. OBTAIN THE CASEID ('||op_ticket_number||') BY SEARCHING THE X_ESN ('||op_esn||') AND X_PART_SERIAL_NO ('||op_new_esn||') COLS IN IN TABLE_CASE AND X_PART_REQUEST TABLES AND SHIPPING ('||ship_status||') STATUS'||chr(10);

    if ip_case_id is not null then
      if ip_case_id != op_ticket_number then
        op_code := '4';
        op_message := 'NO_ASSOCIATED_CASE_FOUND';
        return;
      end if;
    end if;

    if case_objid is null then
      op_code := '7';
      op_message := 'NO_CASE_EXISTS';
      return;
    end if;

    if ship_status = 'PENDING' and op_new_esn is null then
      op_code := '2';
      op_message := 'NO_PHONE_SHIPPED';
      return;
    end if;

    if ip_short_esn is not null then
      case_esn_last_four := substr(op_esn,length(op_esn)-3);
      if case_esn_last_four = ip_short_esn then
        v_display_info := v_display_info||'3. (OPTIONAL VALIDATION) IF THE LAST 4 DIGITS OF THE ESN ('||ip_short_esn||')IS PROVIDED, VALIDATE IT AGAINST THE X_ESN ('||case_esn_last_four||') COL OF TABLE_CASE'||chr(10);
      else
        op_code := '3';
        op_message := 'LAST_FOUR_NO_MATCH';
        d_rslt(debugger_switch => ip_debugger_switch, info => v_display_info||op_message);
        return;
      end if;
    end if;

    -- COLLECT NEW ESN INFO AND CONTACT OBJID
    for i in (select pi.part_serial_no, pn.part_number,pc.name,pi.x_iccid,pi.x_part_inst2contact,pi.objid,pi.x_part_inst_status
                    ,pi.warr_end_date projected_end_date -- REMOVED THE RESERVED PINS FROM THIS QUERY AFTER DISCUSSING W/NATALIO. BENEFITS WILL BE ADDED LATER IN THE ACTIVATION 3.21.16
                    ,                      (select  x_zipcode
                                            from    table_site_part
                                            where   objid = pi.x_part_inst2site_part) zip
              from   table_mod_level m ,
                     table_part_num pn ,
                     table_part_inst pi ,
                     table_part_class pc
              where pi.part_serial_no     in (op_esn,op_new_esn)
              and pi.n_part_inst2part_mod = m.objid
              and m.part_info2part_num    = pn.objid
              and pn.part_num2part_class  = pc.objid
              )
    loop
      if i.part_serial_no = op_new_esn then
        op_new_esn_pn := i.part_number;
        op_new_esn_pc := i.name;
        op_new_sim := i.x_iccid;
        pi_objid := i.objid;
        new_esn_contact_objid := i.x_part_inst2contact;
        new_esn_status := i.x_part_inst_status;
        new_esn_proj_end_date := i.projected_end_date;
      else
          old_esn_pc := i.name;
        old_esn_contact_objid := i.x_part_inst2contact;
        old_esn_status := i.x_part_inst_status;
        old_esn_proj_end_date := i.projected_end_date;
        old_esn_zip := i.zip;
      end if;
    end loop;

    v_display_info := v_display_info||'4. MIN IS CURRENTLY ('||line_status||') - IF THE MIN IS ACTIVE (13) WITH THE CASE ESN ('||op_esn||'), REDIRECT TO UPGRADE'||chr(10);

    -- COLLECT ZIPCODE
    if new_esn_zip is not null then
      op_zip := new_esn_zip;
    else
      op_zip := old_esn_zip;
    end if;

    -- COLLECT CONTACT OBJID
    if new_esn_contact_objid is not null then
      op_contact_objid := new_esn_contact_objid;
    elsif old_esn_contact_objid is not null then
      op_contact_objid := old_esn_contact_objid;
    else
      op_contact_objid := ret_c_objid (part_inst_objid => pi_objid, old_esn => op_esn);
    end if;

    -- COLLECT WEB USER OBJID
    begin
      select objid
      into web_user_objid
      from table_web_user
      where web_user2contact = op_contact_objid;
    exception
    when others then
      null;
    end;

    v_display_info := v_display_info||'5. CONFIRM BENEFITS';

    for i in (select  c.x_replacement_units,d.x_name,d.x_value
              from    table_case c,
                      table_x_case_detail d
              where   1=1
              and     c.objid = d.detail2case
              and     c.id_number = op_ticket_number
              and     d.x_name in ('UNITS_TO_TRANSFER','MAX_UNITS_TO_TRANSFER','SERVICE_DAYS','NO_SERVICE_TRANSFER','SERVICE_PLAN','SERVICE_PLAN_ID')
              )
    loop
      if v_replacement_units is null and i.x_replacement_units > 0 then
        v_replacement_units := i.x_replacement_units;
        v_display_info := v_display_info||chr(10)||'   X_REPLACEMENT_UNITS  '||v_replacement_units;
      end if;
      if v_units_to_transfer is null and i.x_name = 'UNITS_TO_TRANSFER' then
        v_units_to_transfer := i.x_value;
      end if;
      if v_max_units_to_transfer is null and i.x_name = 'MAX_UNITS_TO_TRANSFER' then
        v_max_units_to_transfer := i.x_value;
      end if;
      if v_service_days is null and i.x_name = 'SERVICE_DAYS' then
        v_service_days := i.x_value;
      end if;
      if i.x_name = 'SERVICE_PLAN_ID' then
        op_service_plan := i.x_value;
      end if;
      if i.x_name = 'SERVICE_PLAN' then
        op_service_plan_desc := i.x_value;
      end if;
      if i.x_name = 'NO_SERVICE_TRANSFER' then
        no_service_transfer := true;
      end if;
        v_display_info := v_display_info||chr(10)||'   '||i.x_name||' '||i.x_value;
    end loop;

    if ip_units is not null and ip_units != 0 then
      v_replacement_units := ip_units;
      v_units_to_transfer := ip_units;
      v_max_units_to_transfer := ip_units;
      no_service_transfer := false;

      merge into sa.table_x_case_detail
      using (select 1 from dual)
      on   (detail2case = case_objid
      and   x_name = 'UNITS_TO_TRANSFER')
      when matched then
      update set x_value = ip_units
      when not matched then
      insert (objid,x_name,x_value,detail2case)
      values (sa.seq('x_case_detail'),'UNITS_TO_TRANSFER',ip_units,case_objid);

      merge into sa.table_x_case_detail
      using (select 1 from dual)
      on   (detail2case = case_objid
      and   x_name = 'MAX_UNITS_TO_TRANSFER')
      when matched then
      update set x_value = ip_units
      when not matched then
      insert (objid,x_name,x_value,detail2case)
      values (sa.seq('x_case_detail'),'MAX_UNITS_TO_TRANSFER',ip_units,case_objid);

      merge into sa.table_x_case_detail
      using (select 1 from dual)
      on   (detail2case = case_objid
      and   x_name = 'TT_UNITS')
      when matched then
      update set x_value = ip_units
      when not matched then
      insert (objid,x_name,x_value,detail2case)
      values (sa.seq('x_case_detail'),'TT_UNITS',ip_units,case_objid);
    end if;

    if op_service_plan is null then
      begin

        PHONE_PKG.GET_PROGRAM_INFO(
          p_esn => op_esn,
          P_SERVICE_PLAN_OBJID => op_service_plan,
          p_service_type => op_service_plan_desc,
          P_PROGRAM_TYPE => v_dummy_val,
          P_NEXT_CHARGE_DATE => v_dummy_val,
          P_PROGRAM_UNITS => v_dummy_val,
          P_PROGRAM_DAYS => v_dummy_val,
          P_RATE_PLAN => v_dummy_val,
          P_X_PRG_SCRIPT_ID => v_dummy_val,
          P_X_PRG_DESC_SCRIPT_ID => v_dummy_val,
          P_ERROR_NUM => v_dummy_val
        );

        merge into sa.table_x_case_detail
        using (select 1 from dual)
        on   (detail2case = case_objid
        and   x_name = 'SERVICE_PLAN_ID')
        when not matched then
        insert (objid,x_name,x_value,detail2case)
        values (sa.seq('x_case_detail'),'SERVICE_PLAN_ID',op_service_plan,case_objid);

        merge into sa.table_x_case_detail
        using (select 1 from dual)
        on   (detail2case = case_objid
        and   x_name = 'SERVICE_PLAN')
        when not matched then
        insert (objid,x_name,x_value,detail2case)
        values (sa.seq('x_case_detail'),'SERVICE_PLAN',op_service_plan_desc,case_objid);

      exception when others then
        null;
      end;
    end if;

    if op_service_plan is null and v_units_to_transfer is null then
      no_service_transfer := true;
      v_display_info := v_display_info||chr(10)||'   NO BENEFITS FOUND IN DETAILS ';
    end if;

    if new_esn_proj_end_date is not null then
      v_display_info := v_display_info||chr(10)||'   PROJECTED END DATE FOUND NEW ESN '||new_esn_proj_end_date;
      op_service_end_date := new_esn_proj_end_date;
    else
      v_display_info := v_display_info||chr(10)||'   PROJECTED END DATE FOUND OLD ESN '||old_esn_proj_end_date;
      op_service_end_date := old_esn_proj_end_date;
    end if;

    merge into sa.table_x_case_detail
    using (select 1 from dual)
    on   (detail2case = case_objid
    and   x_name = 'SERVICE_DAYS')
    when not matched then
    insert (objid,x_name,x_value,detail2case)
    values (sa.seq('x_case_detail'),'SERVICE_DAYS',round(TO_DATE(op_service_end_date)-sysdate,0),case_objid)
    when matched then
    update set x_value = round(TO_DATE(op_service_end_date)-sysdate,0);

    if v_units_to_transfer is not null then
      merge into sa.table_x_case_detail
      using (select 1 from dual)
      on   (detail2case = case_objid
      and   x_name = 'TT_UNITS')
      when not matched then
      insert (objid,x_name,x_value,detail2case)
      values (sa.seq('x_case_detail'),'TT_UNITS',v_units_to_transfer,case_objid)
      when matched then
      update set x_value = v_units_to_transfer;
    elsif v_max_units_to_transfer is not null then
      merge into sa.table_x_case_detail
      using (select 1 from dual)
      on   (detail2case = case_objid
      and   x_name = 'TT_UNITS')
      when not matched then
      insert (objid,x_name,x_value,detail2case)
      values (sa.seq('x_case_detail'),'TT_UNITS',v_max_units_to_transfer,case_objid)
      when matched then
      update set x_value = v_max_units_to_transfer;
    end if;


    commit;

    v_display_info := v_display_info||chr(10)||'6. DETERMINE STATUS'||chr(10)||'   OLD ESN '||old_esn_status;
    v_display_info := v_display_info||chr(10)||'   NEW ESN '||new_esn_status;

    select decode(sa.get_param_by_name_fun(ip_part_class_name => old_esn_pc, ip_parameter => 'NON_PPE'),'0','IS_NOT_ANDROID','1','IS_ANDROID','NOT_FOUND') ppe_val
    into old_esn_ppe_val
    from dual;
    select decode(sa.get_param_by_name_fun(ip_part_class_name => op_new_esn_pc, ip_parameter => 'NON_PPE'),'0','IS_NOT_ANDROID','1','IS_ANDROID','NOT_FOUND') ppe_val
    into new_esn_ppe_val
    from dual;

    v_display_info := v_display_info||chr(10)||'7. DETERMINE PPE VS NON_PPE'||chr(10)||'   OLD ESN '||old_esn_ppe_val;
    v_display_info := v_display_info||chr(10)||'   NEW ESN '||new_esn_ppe_val;

    if new_esn_ppe_val = 'IS_ANDROID' then
      op_units := v_units_to_transfer;
      op_sms := v_units_to_transfer;
      op_data := v_units_to_transfer;
    else
      op_units := v_units_to_transfer;
    end if;

    if old_esn_status in ('52') and new_esn_status in ('50','150') then
--        dbms_output.put_line('UPGRADE FLOW');
      op_action := 'UPGRADE';
    end if;
    if old_esn_status in ('51','54') and new_esn_status in ('50','150') and op_service_end_date > sysdate then
--        dbms_output.put_line('EXPRESS ACTIVATION');
      op_action := 'EXPRESS_ACTIVATION';
    end if;
    if old_esn_status in ('51','54') and new_esn_status in ('50','150') and op_service_end_date < sysdate then
--        dbms_output.put_line('ACTIVATION');
      op_action := 'ACTIVATION';
    end if;
    if old_esn_status in ('50','51','54') and new_esn_status in ('52') /*and new_esn_proj_end_date is null */ then
--        dbms_output.put_line('ERROR PHONE ALREADY ACTIVE');
      op_code := '5';
      op_action := 'ERROR_PHONE_ALREADY_ACTIVE';
      op_message := 'ERROR_PHONE_ALREADY_ACTIVE';
    end if;
    if old_esn_status not in ('50','51','54','52') and new_esn_status not in ('50','150','52') then
--        dbms_output.put_line('ERROR INVALID ESN STATUSES');
      op_code := '6';
      op_action := 'ERROR_INVALID_ESN_STATUSES';
      op_message := 'ERROR_INVALID_ESN_STATUSES';
    end if;

    if op_action = 'EXPRESS_ACTIVATION' and op_code = '0' then
      begin
         select objid
         into user_objid
         from table_user
         where s_login_name = 'SA';

        sa.clarify_job_pkg.create_job(ip_title          => 'Express Activation',
                                      ip_case_objid     => case_objid,
                                      ip_user_objid     => user_objid,
                                      ip_old_esn        => op_esn,
                                      ip_esn            => op_new_esn,
                                      ip_min            => op_min,
                                      ip_program_objid  => null, -- leaving null for now. discussed w/Natalio. I do not know where to pull this info from.
                                      ip_web_user_objid => web_user_objid,
                                      ip_contact_objid  => op_contact_objid,
                                      ip_zip            => op_zip,
                                      ip_iccid          => op_new_sim,
                                      op_job_objid      => job_objid,
                                      op_error_no       => op_code,
                                      op_error_str      => create_job_err_str);
        if op_code = '0' then
          v_display_info := v_display_info||chr(10)||'6. CREATE THE JOB '||chr(10)||'   JOB ID '||job_objid;
        else
          op_message := op_code||' - '||create_job_err_str;
          op_code := replace(op_code,'JOB:',null);
          v_display_info := v_display_info||chr(10)||'6. CREATE THE JOB FAILED'||chr(10);
          op_action := 'ERROR_INVALID_DATA';
        end if;
      exception
        when others then
          return;
      end;
    end if;

    --CLOSE THE CASE
    if op_code = '0' and case_objid is not null then
      begin
        close_case (p_case_objid => case_objid,
                    p_user_objid => user_objid,
                    p_source => ip_source_system,
                    p_resolution => 'Job Created '||create_job_err_str, --Optional
                    p_status => 'Closed', --Optional
                    p_error_no => p_error_num,
                    p_error_str => create_job_err_str);
      exception
        when others then
          null;
      end;
    end if;

    v_display_info := v_display_info||chr(10)||'0. EXPRESS_ACTIVATION - PROCESS COMPLETE';
    d_rslt(debugger_switch => ip_debugger_switch, info => null);

    ----------------------------------------------------------------------------
    -- IF YOU MADE IT HERE, CASE IDENTIFIED, PART REQUEST IS SHIPPED AND
    -- YOU KNOW WHERE THE MIN IS RESERVED
    -- START COLLECTING INFO TO DISPLAY
    ----------------------------------------------------------------------------
  end express_activation;
--------------------------------------------------------------------------------
  procedure express_activation (ip_short_esn varchar2, -- last 4 digit esn
                                ip_min varchar2,
                                ip_client_id varchar2,
                                ip_transaction_id varchar2,
                                ip_org_id varchar2,
                                ip_source_system varchar2,
                                ip_language varchar2,
                                ip_login varchar2,
                                ip_case_id varchar2,
                                ip_units varchar2,
                                op_code out varchar2,
                                op_message out varchar2,
                                op_action out varchar2,
                                op_service_plan out varchar2,
                                op_service_plan_desc out varchar2,
                                op_units out varchar2,
                                op_sms out varchar2,
                                op_data out varchar2,
                                op_esn out varchar2,
                                op_min out varchar2,
                                op_zip out varchar2,
                                op_new_esn out varchar2,
                                op_new_sim out varchar2,
                                op_new_esn_pc out varchar2,
                                op_new_esn_pn out varchar2,
                                op_service_end_date out varchar2,
                                op_ticket_number out varchar2,
                                op_contact_objid out varchar2)
  is
  begin
  express_activation (ip_debugger_switch => 'N', -- last 4 digit esn
                      ip_short_esn => ip_short_esn, -- last 4 digit esn
                      ip_min => ip_min,
                      ip_client_id => ip_client_id,
                      ip_transaction_id => ip_transaction_id,
                      ip_org_id => ip_org_id,
                      ip_source_system => ip_source_system,
                      ip_language => ip_language,
                      ip_login => ip_login,
                      ip_case_id => ip_case_id,
                      ip_units => ip_units,
                      op_code => op_code,
                      op_message => op_message,
                      op_action => op_action,
                      op_service_plan => op_service_plan,
                      op_service_plan_desc => op_service_plan_desc,
                      op_units => op_units,
                      op_sms => op_sms,
                      op_data => op_data,
                      op_esn => op_esn,
                      op_min => op_min,
                      op_zip => op_zip,
                      op_new_esn => op_new_esn,
                      op_new_sim => op_new_sim,
                      op_new_esn_pc => op_new_esn_pc,
                      op_new_esn_pn => op_new_esn_pn,
                      op_service_end_date => op_service_end_date,
                      op_ticket_number => op_ticket_number,
                      op_contact_objid => op_contact_objid);

  end express_activation;

  function nap_check_passed (ip_zip varchar2, ip_esn varchar2, ip_min varchar2)
  return boolean
  is
    p_sim                varchar2(30);
    p_repl_part          varchar2(30);
    p_repl_tech          varchar2(30);
    p_sim_profile        varchar2(30);
    p_part_serial_no     varchar2(30);
    p_msg                varchar2(200);
    p_pref_parent        varchar2(200);
    p_pref_carrier_objid varchar2(30);
    nap_verify_result    number;
  begin
    -- MIRRORED THIS FUNCTION TO SERVE AS THE EXACT SAME VALIDATION PERFORMED
    -- IN THE CLARIFY_JOB_PKG. WE ARE CURRENTLY USING THIS FOR THE 2G MIGRATION
    -- PROJECT, HOWEVER, IT'S NOT LIMITED TO JUST THAT. THE PRIMARY FUNCTION
    -- IS TO DECLARE A NO_SERVICE_TRANSFER INTO THE CASE DETAILS IF THE NAP
    -- VALIDAITON REQUIRING SOME SORT OF PAYMENT IN ORDER TO PROCEED W/THE LINE
    -- TRANSFER. BEFORE THIS CHECK, THE SHIP CONFIRM WOULD COMPLETE
    -- WITHOUT CHECKING IF THE CURRENT CARRIER WAS COMPATIBLE W/THE NEW DEVICE.
    -- AT WHICH POINT IF THE EXPRESS ACTIVATION IS CALLED, IT WOULD FAIL
    -- BECAUSE CLARIFY_JOB_PKG HAS THIS CHECK. THE FAILURE WAS ORIGINALLY
    -- HAPPENING IF THE ORIGINAL DEVICE HAD AN ATT LINE AND THE NEW DEVICE WAS
    -- NOT COMPATIBLE W/THE SAME CARRIER.

    dbms_output.put_line('nap_check_passed ip_zip =>'||ip_zip);
    dbms_output.put_line('nap_check_passed ip_esn =>'||ip_esn);
    dbms_output.put_line('nap_check_passed ip_min =>'||ip_min);

    for i in (select x_iccid from table_part_inst where part_serial_no = ip_esn)
    loop
      p_sim := i.x_iccid;
    end loop;

    sa.nap_digital(
      p_zip => ip_zip,
      p_esn => ip_esn,
      p_commit => 'N',
      p_language => 'English',
      p_sim => p_sim,
      p_source => 'WEBCSR',
      p_upg_flag => 'N',
      p_repl_part => p_repl_part,
      p_repl_tech => p_repl_tech,
      p_sim_profile => p_sim_profile,
      p_part_serial_no => p_part_serial_no,
      p_msg => p_msg,
      p_pref_parent => p_pref_parent,
      p_pref_carrier_objid => p_pref_carrier_objid
    );

    dbms_output.put_line('P_PREF_CARRIER_OBJID = ' || p_pref_carrier_objid);

    select count(*)
    into nap_verify_result
    from table_part_inst
    where part_serial_no      = ip_min
    and x_domain              = 'LINES'
    and part_inst2carrier_mkt = to_number(p_pref_carrier_objid);

    if nap_verify_result >0 then
      return true;
    else
      return false;
    end if;
  exception
    when others then
      return false;
  end nap_check_passed;

--------------------------------------------------------------------------------

  -- CR39592 Start PMistry 03/16/2016 Added new procedure.
  procedure get_part_reqst_dtl_by_caseid ( i_case_objid       IN     number,
                                            i_domain          IN     varchar2 DEFAULT 'PHONES',
                                            out_refcursor      OUT    SYS_REFCURSOR ,
                                            out_error_no       OUT    varchar2,
                                            out_error_str      OUT    varchar2) IS

  begin
    out_error_no := '0';
    out_error_str := 'SUCCESS';

    open out_refcursor for
        SELECT pr.DEV,
               pr.OBJID,
               pr.REQUEST2CASE,
               pr.X_ACTION,
               pr.X_COURIER,
               pr.X_DATE_PROCESS,
               pr.X_EST_ARRIVAL_DATE,
               pr.X_FF_CENTER,
               pr.X_FLAG_MIGRATION,
               pr.X_INSERT_DATE,
               pr.X_LAST_UPDATE_STAMP,
               pr.X_PART_NUM_DOMAIN,
               pr.X_PART_SERIAL_NO,
               pr.X_PROBLEM,
               pr.X_QUANTITY,
               pr.X_RECEIVED_DATE,
               pr.X_REPL_PART_NUM,
               pr.X_SERVICE_LEVEL,
               pr.X_SHIP_DATE,
               pr.X_SHIPPING_METHOD,
               pr.X_STATUS,
               pr.X_TRACKING_NO,
               c.ID_NUMBER
        FROM sa.TABLE_X_PART_REQUEST pr, sa.TABLE_CASE c, sa.table_part_inst pi
        WHERE c.objid=pr.request2case
        and   c.objid = i_case_objid
        and   pi.part_serial_no = pr.x_part_serial_no
        and   pi.x_domain = i_domain;

  EXCEPTION
  WHEN OTHERS THEN
      out_error_no := '-1';
      out_error_str := sqlerrm;
  end get_part_reqst_dtl_by_caseid;

  -- CR39592 End

  --CR42968 Start
  procedure get_repl_part_number
  (ip_esn            VARCHAR2
  ,ip_zipcode            VARCHAR2
  ,ip_case_type            VARCHAR2
  ,ip_case_title        VARCHAR2
  ,op_repl_part_number  OUT    VARCHAR2
  ,op_error_code    OUT    VARCHAR2
  ,op_error_msg        OUT    VARCHAR2
  )
  IS

    v_case_hdr_domain sa.table_x_case_conf_hdr.pn_domain_type%type := 'unknown';
    v_case_hdr_logic  sa.table_x_case_conf_hdr.x_repl_logic%type := 'unknown';

  BEGIN

    op_error_code    := '0';
    op_error_msg    := '';

    BEGIN

        /*
        SELECT    listagg  (part_number, '||') WITHIN GROUP  (ORDER BY part_number)
        INTO    op_repl_part_number
        FROM (
        */

        SELECT DISTINCT part_number
        INTO op_repl_part_number
        FROM TABLE(sa.adfcrm_case.avail_repl_part_num(ip_case_type => ip_case_type, ip_case_title => ip_case_title, ip_esn => ip_esn))
        --)
        ;
    EXCEPTION WHEN OTHERS
    THEN

        op_repl_part_number    := NULL;

    END;


        --- We can have below logic as well if not to use TAS logic --
    IF     op_repl_part_number IS NULL
    THEN

    BEGIN
        select nvl(pn_domain_type,'unknown'), nvl(x_repl_logic,'unknown')
        INTO v_case_hdr_domain, v_case_hdr_logic
        from   sa.table_x_case_conf_hdr chdr
        where s_x_title = upper(ip_case_title)
        and    s_x_case_type = upper(ip_case_type)
        ;
    EXCEPTION WHEN OTHERS
    THEN

        v_case_hdr_domain  := 'unknown';
        v_case_hdr_logic   := 'unknown';
        op_error_code    :=     '99';
        op_error_msg    :=    'Case conf hdr not found '||upper(ip_case_title)||' '||upper(ip_case_type);
        RETURN;

    END;

    IF     NVL(v_case_hdr_domain,'unknown') <> 'unknown'
    THEN

        NAP_SERVICE_PKG.GET_LIST(
        P_ZIP => ip_zipcode,
        P_ESN => ip_esn,
        P_ESN_PART_NUMBER => NULL,
        P_SIM => NULL,
        P_SIM_PART_NUMBER => NULL,
        P_SITE_PART_OBJID => NULL
        );

        for i in sa.nap_service_pkg.big_tab.first .. sa.nap_service_pkg.big_tab.last loop
        if sa.nap_service_pkg.big_tab(i).carrier_info.shippable = 'Y' then
        dbms_output.put_line(sa.nap_service_pkg.big_tab(i).carrier_info.sim_profile);

        IF v_case_hdr_domain = 'SIM CARDS'
        THEN
            op_repl_part_number    := sa.nap_service_pkg.big_tab(i).carrier_info.sim_profile;
        END IF;
        exit;
        end if;
        end loop;

        sa.nap_service_pkg.big_tab := sa.nap_service_pkg.big_tab_clear;

    END IF;

    END IF;

    op_error_code    := '0';
    op_error_msg    := 'SUCCESS';

  EXCEPTION WHEN OTHERS
  THEN
    op_error_code    :=     '99';
    op_error_msg    := 'clarify_case_pkg.get_repl_part_number Main exception '||DBMS_UTILITY.FORMAT_ERROR_STACK
                ||' '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                ||' esn '||ip_esn;

    ota_util_pkg.err_log(p_action => 'clarify_case_pkg.get_repl_part_number', p_error_date => SYSDATE, p_key => ip_esn, p_program_name =>
    'clarify_case_pkg.get_repl_part_number', p_error_text => op_error_msg);

  END;
  --CR42968 End

--CR42899

PROCEDURE CREATE_PORT_CASE_DETAIL_HIST
				( IP_TICKET_ID  		VARCHAR2
				, OP_ERROR_CODE		OUT	VARCHAR2
				, OP_ERROR_MSG		OUT	VARCHAR2
				)
IS

	CURSOR cur_failed_attributes IS
	SELECT TCD.ROWID ROW_ID,TC.objid CASE_OBJID
	, regexp_replace(
	  X_NAME,               -- source string
	  'FAILED_',            -- pattern
	  '',                   -- leave separators in place
	  1,                    -- start from beginning
	  1,                    -- replace all occurences
	  'i'                   -- case-insensitive and multiline
	) FAILED_ATTRIBUTE
	FROM TABLE_CASE TC, TABLE_X_CASE_DETAIL TCD
	WHERE TC.objid 		= 	TCD.detail2case
	AND TC.id_number	=	IP_TICKET_ID
	AND TCD.X_NAME		LIKE 	'FAILED_%'
	;

	CURSOR CUR_PORT_CASE_DETAILS(I_CASE_OBJID VARCHAR2, I_NAME VARCHAR2) IS
	SELECT DEV,X_NAME,X_VALUE, DETAIL2CASE
	FROM TABLE_X_CASE_DETAIL TCD
	WHERE TCD.detail2case	=	I_CASE_OBJID
	AND TCD.X_NAME		=	I_NAME
	;

	REC_PORT_CASE_DETAILS	CUR_PORT_CASE_DETAILS%ROWTYPE;

	LV_NEW_REV_NO		NUMBER;

BEGIN

	FOR rec_failed_attributes IN cur_failed_attributes
	LOOP

		OPEN CUR_PORT_CASE_DETAILS(rec_failed_attributes.CASE_OBJID,rec_failed_attributes.FAILED_ATTRIBUTE);

		FETCH CUR_PORT_CASE_DETAILS INTO REC_PORT_CASE_DETAILS;

		IF CUR_PORT_CASE_DETAILS%FOUND
		THEN

			SELECT NVL(MAX(REVISION_ID),0) + 1
			INTO LV_NEW_REV_NO
			FROM TABLE_X_CASE_DETAIL_HIST
			WHERE DETAIL2CASE	=	rec_failed_attributes.CASE_OBJID
			;

			INSERT INTO sa.TABLE_X_CASE_DETAIL_HIST	(
			OBJID
			, REVISION_ID
			, DEV
			, X_NAME
			, X_VALUE
			, DETAIL2CASE
			, CREATION_DATE
			)
			VALUES (
			SEQ_X_CASE_DETAIL_HIST.NEXTVAL
			,LV_NEW_REV_NO
			, REC_PORT_CASE_DETAILS.DEV
			, REC_PORT_CASE_DETAILS.X_NAME
			, REC_PORT_CASE_DETAILS.X_VALUE
			, REC_PORT_CASE_DETAILS.DETAIL2CASE
			, SYSDATE
			);

			DELETE FROM TABLE_X_CASE_DETAIL
			WHERE ROWID 	=	rec_failed_attributes.ROW_ID
			;


		END IF;

		CLOSE CUR_PORT_CASE_DETAILS;




	END LOOP;

	COMMIT;

END CREATE_PORT_CASE_DETAIL_HIST;
--CR42899

-------------------------------------------------------------------------------------------------------
function get_warranty_days_left(p_esn in varchar2)
 --CR46924 March-2017
return number as
    cursor get_parameters is
        select
            (select x_param_value
            from sa.table_x_parameters
            where x_param_name = 'ADFCRM_FREE_EXCH_AGE_NEW_STOCK') new_stock_max_age,
            (select x_param_value
            from sa.table_x_parameters
            where x_param_name = 'ADFCRM_FREE_EXCH_AGE_REFURB_STOCK') refurb_stock_max_age,
            x_param_value sl_max_age
        from sa.table_x_parameters
        WHERE x_param_name = 'ADFCRM_FREE_EXCH_AGE_SAFELINK';
    get_parameters_rec get_parameters%rowtype;

    cursor esn_activation (p_esn varchar2, p_date date) is
        select  sp.x_service_id esn, max(nvl(sp.x_refurb_flag,0)) is_refurb,
             case
               when max(nvl(sp.x_refurb_flag,0)) = 0 then
                    (select min (sp_c.install_date) nonrefurb_act_date
                     from table_site_part sp_c
                     where sp_c.x_service_id = sp.x_service_id
                     and sp_c.part_status || '' in ('Active', 'Inactive')
                     and sp_c.install_date <= p_date
                    )
               else (select min (sp_b.install_date) refurb_act_date
                     from table_site_part sp_b
                     where sp_b.x_service_id = sp.x_service_id
                     and sp_b.part_status || '' in ('Active', 'Inactive')
                     and nvl (sp_b.x_refurb_flag, 0) <> 1
                     and sp_b.install_date <= p_date
                    )
               end activation_date
        from table_site_part sp
        where sp.x_service_id = p_esn
        and sp.install_date <= p_date
        group by sp.x_service_id
        ;
    esn_activation_rec esn_activation%ROWTYPE;
    main_activation_rec esn_activation%ROWTYPE;

    cursor get_existing_warranty (p_esn varchar2) is
        select max(a.x_insert_date) warranty_case_date,
               b.x_esn existing_esn,
               max(b.objid) case_objid
        from table_x_part_request a, table_case b,
             (select nvl(x_warehouse,0), x_case_type, x_title, x_repl_logic
              from sa.table_x_case_conf_hdr
              where x_case_type in ('Warranty', 'Warehouse')
              and nvl(x_warehouse,0) = 1) c
        where a.x_status = 'SHIPPED'
        and a.x_part_num_domain = 'PHONES'
        and a.x_part_serial_no = p_esn
        and b.objid = a.request2case
        and b.title = c.x_title
        and b.x_case_type = c.x_case_type
        group by b.x_esn
        ;
    get_existing_warranty_rec get_existing_warranty%rowtype;

    days_left_from_case number := -1;
    warranty_days_left number := 0;
begin
    open get_parameters;
    fetch get_parameters into get_parameters_rec;
    close get_parameters;

    open esn_activation(p_esn,trunc(sysdate));
    fetch esn_activation into main_activation_rec;
    close esn_activation;

    warranty_days_left := get_parameters_rec.new_stock_max_age; --Phone New, no records in site_part
    if sa.adfcrm_cust_service.is_phone_safelink(ip_esn => main_activation_rec.esn)=1 then
        warranty_days_left := get_parameters_rec.sl_max_age;
    elsif main_activation_rec.is_refurb = 1 then
        warranty_days_left := get_parameters_rec.refurb_stock_max_age; --It was activated from status Refurbished, within the last 90 days
    end if;

    --DBMS_OUTPUT.PUT_LINE('ESN:'||p_esn||' activation:'||to_char(main_activation_rec.activation_date,'yyyy/mm/dd')||' max_age:'||warranty_days_left);
    --Identify if a phone was shipped as a replacement for an earlier warranty or warehouse process.
    open get_existing_warranty(p_esn);
    fetch get_existing_warranty into get_existing_warranty_rec;
    close get_existing_warranty;

    if get_existing_warranty_rec.case_objid is not null
    then
        begin
             select to_number(trim(x_value)) warranty_days_left
             into days_left_from_case
             from table_x_case_detail
             where detail2case = get_existing_warranty_rec.case_objid
             and x_name = 'WARRANTY_DAYS_LEFT';
        exception
             when others then null;
        end;

        if nvl(days_left_from_case,-1) >= 0 then
            warranty_days_left := days_left_from_case;
            --DBMS_OUTPUT.PUT_LINE('Existing Case Objid:'||get_existing_warranty_rec.case_objid||' warranty_days_left:'||warranty_days_left);
        elsif get_existing_warranty_rec.existing_esn is not null then
            open esn_activation(get_existing_warranty_rec.existing_esn,get_existing_warranty_rec.warranty_case_date);
            fetch esn_activation into esn_activation_rec;
            close esn_activation;

            warranty_days_left := get_parameters_rec.new_stock_max_age; --Phone New, no records in site_part
            if sa.adfcrm_cust_service.is_phone_safelink(ip_esn => esn_activation_rec.esn)=1 then
              warranty_days_left := get_parameters_rec.sl_max_age;
              --DBMS_OUTPUT.PUT_LINE('Existing Case for SAFELINK ESN:'||esn_activation_rec.esn||' max_age:'||warranty_days_left);
            elsif esn_activation_rec.is_refurb = 1 then
              warranty_days_left := get_parameters_rec.refurb_stock_max_age; --It was activated from status Refurbished, within the last 90 days
            end if;
            --DBMS_OUTPUT.PUT_LINE('Existing Case for ESN:'||esn_activation_rec.esn||'  activation:'||to_char(esn_activation_rec.activation_date,'yyyy/mm/dd')||' max_age:'||warranty_days_left
            --||' warranty_case_date:'||to_char(get_existing_warranty_rec.warranty_case_date,'yyyy/mm/dd'));
            --Value of Warranty Days Left from existing case
            --DBMS_OUTPUT.PUT_LINE('Existing Case days:'||round(get_existing_warranty_rec.warranty_case_date - nvl(esn_activation_rec.activation_date,get_existing_warranty_rec.warranty_case_date)));
            warranty_days_left := greatest( warranty_days_left - round(get_existing_warranty_rec.warranty_case_date - nvl(esn_activation_rec.activation_date,get_existing_warranty_rec.warranty_case_date)) , 0);
            --DBMS_OUTPUT.PUT_LINE('Existing Case warranty_days_left:'||warranty_days_left);
        end if;
    end if;

    warranty_days_left := greatest( warranty_days_left - greatest(round(sysdate - nvl(main_activation_rec.activation_date,sysdate)),0) ,0);
  return warranty_days_left;
end get_warranty_days_left;
-- Added batch process to compare invoice data and update case status.
PROCEDURE upd_refund_status ( i_check_date IN  DATE,
                              o_response   OUT VARCHAR2 ) IS

  TYPE invoice_details_rec IS RECORD
  ( invoice_num 	VARCHAR2(50),
  	invoice_amount	NUMBER,
  	amount_paid		NUMBER,
  	check_number	NUMBER,
  	check_amount	NUMBER,
  	invoice_id		NUMBER,
  	check_date		DATE,
    case_objid      NUMBER
  );
  TYPE tab_invoice_details IS TABLE OF invoice_details_rec;
  t_invoice_details 	tab_invoice_details;
  n_vas_subscription_id x_vas_subscriptions.vas_subscription_id%TYPE;
  c_case_detail     	VARCHAR2(5000);
  c_case_note           VARCHAR2(5000);
  n_error_num       	VARCHAR2(50);
BEGIN
  -- Fetching the Invoice info from tf_ref_pay_dtls view
  SELECT invoice_num,
         invoice_amount,
  	     amount_paid,
  	     check_number,
  	     check_amount,
  	     invoice_id,
  	     check_date,
         objid
  BULK COLLECT INTO t_invoice_details
  FROM   apps.tf_ref_pay_dtls@OFSPRD vw
  INNER JOIN table_case tc ON vw.invoice_num= tc.id_number
  WHERE  TRUNC(vw.check_date) = i_check_date
  ORDER BY vw.check_date;

  IF t_invoice_details.COUNT > 1
  THEN
    FOR rec IN
      t_invoice_details.FIRST .. t_invoice_details.LAST
    LOOP

	  o_response := NULL;
      c_case_detail := 'INVOICE_NUM||'||t_invoice_details(rec).invoice_num||
                       '||INVOICE_AMOUNT||'||t_invoice_details(rec).invoice_amount||
                       '||AMOUNT_PAID||'||t_invoice_details(rec).amount_paid||
                       '||CHECK_NUMBER||'||t_invoice_details(rec).check_number||
                       '||CHECK_AMOUNT||'||t_invoice_details(rec).check_amount||
					   '||INVOICE_ID||'||t_invoice_details(rec).invoice_id||
					   '||CHECK_DATE||'||t_invoice_details(rec).check_date;

      -- Inserting/updating the Case details in table_x_case_detail table
      clarify_case_pkg.update_case_dtl(p_case_objid  => t_invoice_details(rec).case_objid,
                                       p_user_objid  => NULL,
                                       p_case_detail => c_case_detail,
                                       p_error_no    => n_error_num,
                                       p_error_str   => o_response);
	  IF o_response NOT LIKE '%SUCCESS%'
	  THEN
		o_response := n_error_num||' - '||o_response;
	    RETURN;
	  END IF;
      -- Inserting the Log in table_notes_log table
      c_case_note   := 'INVOICE_NUM ='||t_invoice_details(rec).invoice_num||
                       ' INVOICE_AMOUNT='||t_invoice_details(rec).invoice_amount||
                       ' AMOUNT_PAID='||t_invoice_details(rec).amount_paid||
                       ' CHECK_NUMBER='||t_invoice_details(rec).check_number||
                       ' CHECK_AMOUNT='||t_invoice_details(rec).check_amount||
					   ' INVOICE_ID='||t_invoice_details(rec).invoice_id||
					   ' CHECK_DATE='||t_invoice_details(rec).check_date;
      clarify_case_pkg.log_notes( p_case_objid  => t_invoice_details(rec).case_objid,
                                  p_user_objid  => NULL,
                                  p_notes       => c_case_note,
                                  p_action_type => 'REFUND STATUS UPDATE',
                                  p_error_no    => n_error_num,
                                  p_error_str   => o_response );

      IF o_response NOT LIKE '%SUCCESS%'
	  THEN
		o_response := n_error_num||' - '||o_response;
	    RETURN;
	  END IF;
	  -- Fetching vas_subscription_id to update the subscription
      BEGIN
        SELECT vas_subscription_id
        INTO   n_vas_subscription_id
        FROM   x_vas_subscriptions
        WHERE  case_id_number = t_invoice_details(rec).case_objid ;
      EXCEPTION
      WHEN OTHERS
      THEN
        n_vas_subscription_id := NULL;
      END;
	  -- -- Passing vas_subscription_id to p_update_vas_subscription for update the subscription
      IF n_vas_subscription_id IS NOT NULL
      THEN
        vas_management_pkg.p_update_vas_subscription( i_vas_subscription_id  => n_vas_subscription_id,
                                                       o_error_code           => n_error_num,
                                                       o_error_msg            => o_response);
        IF o_response NOT LIKE '%SUCCESS%'
        THEN
		  o_response := n_error_num||' - '||o_response;
	      RETURN;
	    END IF;
      END IF;
    END LOOP;
  END IF;
END upd_refund_status;


--CR55956 Procedure added to retrieve case id based on detail
PROCEDURE get_case_id_by_detail ( in_detail_name  IN  VARCHAR2,
                                  in_detail_value IN  VARCHAR2,
                                  in_case_type    IN  VARCHAR2,
                                  in_case_title   IN  VARCHAR2,
                                  out_id_number   OUT VARCHAR2,
                                  out_error_code  OUT VARCHAR2,
                                  out_error_msg   OUT VARCHAR2 )
IS
BEGIN

   IF in_detail_name = 'ESN' THEN

     SELECT id_number
     INTO   out_id_number
     FROM   ( SELECT tc.id_number,
                     MAX(tc.creation_time) over () max_create_time,
                     tc.creation_time
              FROM table_case tc,
                   table_x_case_conf_hdr tcch
              WHERE tc.x_esn           = in_detail_value
                AND tc.title           = tcch.x_title
                AND tc.x_case_type     = tcch.x_case_type
                AND tcch.s_x_case_type = UPPER(in_case_type)
                AND tcch.s_x_title  like '%' || UPPER(in_case_title) || '%'
            )
     WHERE max_create_time = creation_time;

   ELSE

     SELECT id_number
     INTO   out_id_number
     FROM   ( SELECT tc.id_number,
                    MAX(tc.creation_time) over () max_create_time,
                    tc.creation_time
              FROM table_x_case_detail tcd,
                   table_case tc,
                   table_x_case_conf_hdr tcch,
                   table_x_case_conf_dtl tccd
              WHERE tc.objid           = tcd.detail2case
                AND tcd.x_name         = tccd.x_field_name
                AND tc.title           = tcch.x_title
                AND tc.x_case_type     = tcch.x_case_type
                AND tcch.s_x_case_type = UPPER(in_case_type)
                AND tcd.x_name         = UPPER(in_detail_name)
                AND tcd.x_value        = UPPER(in_detail_value)
                AND tcch.s_x_title  like '%' || UPPER(in_case_title) || '%'
            )
     WHERE max_create_time = creation_time;

   END IF;

   out_error_code := '0';
   out_error_msg  := 'SUCCESS';

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     out_error_code := '-1';
     out_error_msg  := 'CASE NOT FOUND FOR ' || in_detail_name || ' = ' || in_detail_value;
   WHEN OTHERS THEN
     out_error_code := SQLCODE;
     out_error_msg  := SQLERRM;
END get_case_id_by_detail;

PROCEDURE update_expedite_shipping
                                   (
                                    i_case_id_number      IN  VARCHAR2,
                                    i_biz_hdr_objid       IN  NUMBER,
                                    i_shipping_method     IN  VARCHAR2,
                                    i_courier_id          IN  VARCHAR2,
                                    o_error_code          OUT NUMBER,
                                    o_error_msg           OUT VARCHAR2
                                   )
IS
 v_case_objid          NUMBER;
 v_owner2user      	   NUMBER;
 v_bill_trans_ref_no  	x_biz_purch_hdr.x_bill_trans_ref_no%TYPE;
 v_request_id      	   x_biz_purch_hdr.x_request_id%TYPE;

BEGIN --{
 o_error_code := 0;
 o_error_msg  := 'SUCCESS';

 BEGIN --{
  SELECT objid,        case_owner2user
  INTO   v_case_objid, v_owner2user
  FROM   table_case
  WHERE  id_number = i_case_id_number;
 EXCEPTION
  WHEN OTHERS THEN
   o_error_code := 4;
   o_error_msg  := 'Invalid Case';
  RETURN;
 END; --}

 BEGIN --{

  UPDATE table_x_part_request
  SET    x_shipping_method = i_shipping_method,
         x_courier         = i_courier_id,
         X_SERVICE_LEVEL   = 1
  WHERE  request2case      = v_case_objid;

 EXCEPTION
 WHEN OTHERS THEN
  o_error_code := 1;
  o_error_msg  := 'Error while updating Shipping method due to '||SQLERRM;
  RETURN;
 END; --}

 IF SQL%ROWCOUNT > 0
 THEN --{
  log_notes(v_case_objid ,NULL ,'Shipping Method Upd','Shipping Method Upd' ,o_error_code ,o_error_msg);
 END IF; --}

 BEGIN --{
  UPDATE x_biz_purch_hdr
  SET    groupidentifier   = v_case_objid,
         agent_id          = (SELECT login_name FROM table_user u WHERE u.objid = v_owner2user AND ROWNUM = 1)
  WHERE  objid             = i_biz_hdr_objid;

 EXCEPTION
 WHEN OTHERS THEN
  o_error_code := 2;
  o_error_msg  := 'Error while updating x_biz_purch_hdr due to '||SQLERRM;
  RETURN;
 END; --}

 BEGIN --{

  SELECT x_bill_trans_ref_no, x_request_id
  INTO   v_bill_trans_ref_no, v_request_id
  FROM   x_biz_purch_hdr
  WHERE  objid = i_biz_hdr_objid;

  update_case_dtl(v_case_objid ,NULL ,'BILL_TRANS_REF_NUMBER||' || v_bill_trans_ref_no ,o_error_code ,o_error_msg);
  update_case_dtl(v_case_objid ,NULL ,'REQUEST_ID||' || v_request_id ,o_error_code ,o_error_msg);

 EXCEPTION
 WHEN OTHERS THEN
  o_error_code := 4;
  o_error_msg  := 'Error while logging payment ref number '||SQLERRM;
  RETURN;
 END; --}


EXCEPTION
   WHEN OTHERS THEN
     o_error_code := 3;
     o_error_msg  := 'Error in update_expedite_shipping due to '||SQLERRM;
END update_expedite_shipping; --}

FUNCTION ship_refund_eligible
                           (
                             i_case_objid      IN  NUMBER,
                             o_error_code      OUT NUMBER,
                             o_error_msg       OUT VARCHAR2
                           )
RETURN VARCHAR2
IS

 v_ship_date         DATE;
 v_est_delivery_date DATE;
 v_max_delivery_days NUMBER      := 0;
 v_eligible_flag     VARCHAR2(5) := 'N';
BEGIN --{

 BEGIN --{
  SELECT  'Y'
  INTO    v_eligible_flag
  FROM    table_gbst_elm         e,
          table_case             tc,
          table_x_part_request   txpr
  WHERE   tc.casests2gbst_elm =  e.objid
  AND     tc.objid            =  i_case_objid
  AND     tc.objid            =  txpr.request2case
  AND     e.s_title           =  'CLOSED'
  AND     txpr.x_ship_date    IS NULL
  AND     ROWNUM              <= 1;
 EXCEPTION
 WHEN OTHERS THEN
  NULL;
 END; --}

 IF v_eligible_flag = 'Y'
 THEN --{
  DBMS_OUTPUT.PUT_LINE('Case closed but not shipped.');
  RETURN v_eligible_flag;
 END IF; --}

 BEGIN --{
  SELECT x_max_delivery_days, x_ship_date
  INTO   v_max_delivery_days, v_ship_date
  FROM   table_x_exch_shipping_dtl txesd,
         table_x_part_request pr
  WHERE  txesd.x_shipping_method    = pr.x_shipping_method
  AND    pr.request2case            = i_case_objid
  AND    pr.x_ship_date             IS NOT NULL
  and    pr.x_part_num_domain       = txesd.x_domain_type
  AND    ROWNUM                     <=1;
 EXCEPTION
  WHEN OTHERS THEN
   o_error_code := 2;
   o_error_msg  := 'Error while fetching case part request '||SQLERRM;
   DBMS_OUTPUT.PUT_LINE(o_error_msg);
   RETURN 'N';
 END; --}

 BEGIN --{
  SELECT TRUNC( v_ship_date + MAX(rnum) )
  INTO   v_est_delivery_date
  FROM   (  SELECT LEVEL rnum
            FROM   dual
            CONNECT BY LEVEL <= 365 ORDER BY 1
         )
  WHERE ROWNUM <= v_max_delivery_days --Expedite shipping
  AND   TO_CHAR(v_ship_date+rnum, 'dy') NOT IN ('sat','sun');
 EXCEPTION
  WHEN OTHERS THEN
   o_error_code := 3;
   o_error_msg  := 'Error while fetching est delivery date '||SQLERRM;
   DBMS_OUTPUT.PUT_LINE(o_error_msg);
   RETURN 'N';
 END; --}

 IF TRUNC(v_est_delivery_date) < TRUNC(SYSDATE)
 THEN --{
  DBMS_OUTPUT.PUT_LINE('........... Y');
  RETURN 'Y';
 ELSE
  DBMS_OUTPUT.PUT_LINE('........... N');
  RETURN 'N';
 END IF; --}

EXCEPTION
   WHEN OTHERS THEN
     o_error_code := 1;
     o_error_msg  := 'Error in ship_refund_eligible due to '||SQLERRM;
     DBMS_OUTPUT.PUT_LINE(o_error_msg);
     RETURN 'N';
END; --}


FUNCTION get_shipping_method
                           (
                             i_case_objid      IN  NUMBER,
                             part_request_id   IN  NUMBER
                           )
RETURN VARCHAR2
IS
v_shipping_method   VARCHAR2(20);
v_shipping_category VARCHAR2(20);

BEGIN --{

 BEGIN --{
  SELECT txpr.x_shipping_method
  INTO   v_shipping_method
  FROM   table_x_part_request txpr
  WHERE  txpr.request2case  = i_case_objid
  --AND    txpr.x_shipping_method IS NOT NULL
  AND    objid = part_request_id
  AND    ROWNUM <= 1;
 EXCEPTION
  WHEN OTHERS THEN
   RETURN NULL;
 END; --}

 IF v_shipping_method IS NULL
 THEN --{
  RETURN NULL;
 END IF; --}

 BEGIN --{
  SELECT x_shipping_category
  INTO   v_shipping_category
  FROM   table_x_exch_shipping_dtl txesd
  WHERE  txesd.x_shipping_method = v_shipping_method
  AND    ROWNUM <= 1;
 EXCEPTION
  WHEN OTHERS THEN
   RETURN 'FREE';
 END; --}

 RETURN v_shipping_category;

EXCEPTION
WHEN OTHERS THEN
 RETURN 'FREE';
END get_shipping_method; --}

END clarify_case_pkg;
/