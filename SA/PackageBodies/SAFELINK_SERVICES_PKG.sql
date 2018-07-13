CREATE OR REPLACE PACKAGE BODY sa."SAFELINK_SERVICES_PKG" AS
 /*
 CR# 31300
 Created Date: 01/08/2015
 */
 g_err_msg VARCHAR2 (2000);
 g_request VARCHAR2 (2000);
 g_requestid xsu_vmbc_request.requestid%TYPE := '-1'; -- CR28799
 g_job_run_objid x_job_run_details.objid%TYPE;
 --------------------------------------------------------------------------------
 -- INTERNAL TO PACKAGE - PROCEDURE TO INSERT JOB ERRORS

--------------------------------------------------------------------------------

--CR44963 Starts
PROCEDURE p_upd_service_plan (
i_esn IN VARCHAR2,
i_pgm_enroll2pgm_parameter IN NUMBER,
i_site_part_id IN VARCHAR2 DEFAULT NULL,
o_err_no OUT NUMBER,
o_err_msg OUT VARCHAR2)
AS
 l_device table_x_part_class_values.x_param_value%TYPE;
 v_service_plan_id NUMBER;
 v_x_program_name x_program_parameters.x_program_name%TYPE;
 v_x_switch_base_rate x_service_plan_site_part.x_switch_base_rate%TYPE;
 v_units table_x_promotion.x_units%TYPE;
BEGIN
 l_device := get_device_type(i_esn);
 IF l_device IN ( 'BYOP', 'SMARTPHONE' ) THEN
 BEGIN
			v_x_switch_base_rate := 0;
 SELECT x_program_name,
 X.program_para2x_sp
 INTO v_x_program_name, v_service_plan_id
 FROM x_program_parameters pp,
 mtm_sp_x_program_param x
 WHERE pp.objid = i_pgm_enroll2pgm_parameter
 AND X.x_sp2program_param(+) = pp.objid;
 IF v_service_plan_id IS NULL THEN
 v_x_switch_base_rate := .01;
			v_service_plan_id:=(CASE WHEN v_x_program_name LIKE '%3' THEN 425
									 WHEN v_x_program_name LIKE '%4' THEN 426
								END );
 END IF;
 EXCEPTION
 WHEN OTHERS THEN
 v_x_program_name := NULL;
			v_service_plan_id := NULL;
			RETURN;
 END;
	merge INTO sa.x_service_plan_site_part
	USING dual
	ON ( table_site_part_id = i_site_part_id)
	WHEN matched THEN
	UPDATE SET x_service_plan_id = v_service_plan_id
	WHERE table_site_part_id = i_site_part_id
	WHEN NOT matched THEN
	 INSERT (table_site_part_id,
			 x_service_plan_id,
			 x_switch_base_rate,
			 x_new_service_plan_id,
			 x_last_modified_date)
	 VALUES (i_site_part_id,
			 v_service_plan_id,
			 v_x_switch_base_rate,
			 NULL,
			 SYSDATE);
	COMMIT;
 END IF;
END p_upd_service_plan;
PROCEDURE create_job_instance(
 ip_job_name IN x_job_master.x_job_name%type,
 ip_status IN x_job_run_details.x_status%type,
 ip_job_run_mode IN x_job_run_details.x_job_run_mode%type DEFAULT NULL,
 ip_seq_name IN VARCHAR2,
 ip_owner_name IN x_job_run_details.owner_name%type DEFAULT NULL,
 ip_reason IN x_job_run_details.x_reason%type DEFAULT NULL,
 ip_status_code IN x_job_run_details.x_status_code%type DEFAULT NULL,
 ip_sub_sourcesystem IN x_job_run_details.x_sub_sourcesystem%type DEFAULT NULL,
 op_job_run_objid OUT x_job_run_details.objid%type )
IS
 pragma autonomous_transaction;
 v_job_run_objid x_job_run_details.objid%type;
 v_job_master_id x_job_master.objid%type;
BEGIN
 BEGIN
 SELECT MAX (objid)
 INTO v_job_master_id
 FROM x_job_master
 WHERE 1 = 1
 AND x_job_name = ip_job_name;
 v_job_run_objid := billing_seq (ip_seq_name);
 op_job_run_objid := v_job_run_objid;
 INSERT
 INTO x_job_run_details
 (
 objid,
 x_scheduled_run_date,
 x_actual_run_date,
 x_insert_date,
 x_status,
 x_job_run_mode,
 x_start_time,
 run_details2job_master,
 owner_name,
 x_reason,
 x_status_code,
 x_sub_sourcesystem
 )
 VALUES
 (
 v_job_run_objid,
 sysdate,
 sysdate,
 sysdate,
 ip_status,
 ip_job_run_mode,
 sysdate,
 v_job_master_id,
 ip_owner_name,
 ip_reason,
 ip_status_code,
 ip_sub_sourcesystem
 );
 COMMIT;
 EXCEPTION
 WHEN OTHERS THEN
 ROLLBACK;
 raise_application_error (-20001, 'Failed to insert record into x_job_run_details: '||sqlerrm);
 END;
END create_job_instance;
PROCEDURE update_job_instance
 (
 ip_job_run_objid IN x_job_run_details.objid%type,
 ip_owner_name IN x_job_run_details.owner_name%type DEFAULT NULL,
 ip_reason IN x_job_run_details.x_reason%type DEFAULT NULL,
 ip_status IN x_job_run_details.x_status%type,
 ip_status_code IN x_job_run_details.x_status_code%type DEFAULT NULL,
 ip_sub_sourcesystem IN x_job_run_details.x_sub_sourcesystem%type DEFAULT NULL
 )
IS
 pragma autonomous_transaction;
BEGIN
 UPDATE x_job_run_details
 SET x_end_time = sysdate,
 x_status = ip_status,
 x_status_code = ip_status_code,
 x_reason = ip_reason,
 owner_name = ip_owner_name,
 x_sub_sourcesystem = ip_sub_sourcesystem
 WHERE objid = ip_job_run_objid;
 COMMIT;
EXCEPTION
WHEN OTHERS THEN
 ROLLBACK;
 raise_application_error (-20002, 'Failed to update record into x_job_run_details: '||sqlerrm);
END update_job_instance;
PROCEDURE ins_job_err(
 ipv_job_data_id IN VARCHAR2,
 ipv_req_type IN VARCHAR2,
 ipv_req IN VARCHAR2,
 pv_err_msg IN OUT VARCHAR2)
AS
 pragma autonomous_transaction;
BEGIN
 INSERT
 INTO x_job_errors
 (
 objid,
 x_source_job_id,
 x_request_type,
 x_request,
 ordinal,
 x_status_code,
 x_reject,
 x_insert_date,
 x_update_date,
 x_resent,
 x_error_msg
 )
 VALUES
 (
 sa.seq_x_job_errors.nextval,
 ipv_job_data_id,
 ipv_req_type,
 ipv_req,
 0,
 -200,
 0,
 sysdate,
 sysdate,
 0,
 pv_err_msg
 );
 pv_err_msg := NULL;
 COMMIT;
END ins_job_err;
PROCEDURE ins_program_error_log
 (
 ipv_source IN VARCHAR2,
 ipv_description IN VARCHAR2,
 ipv_severity IN VARCHAR2,
 pv_err_code IN OUT VARCHAR2,
 pv_err_msg IN OUT VARCHAR2
 )
AS
 pragma autonomous_transaction;
BEGIN
 INSERT
 INTO X_PROGRAM_ERROR_LOG
 (
 X_SOURCE,
 X_ERROR_CODE,
 X_ERROR_MSG,
 X_DATE,
 X_DESCRIPTION,
 X_SEVERITY
 )
 VALUES
 (
 ipv_source,
 pv_err_code,
 pv_err_msg,
 sysdate,
 ipv_description,
 ipv_severity
 );
 pv_err_code := NULL;
 pv_err_msg := NULL;
 COMMIT;
END ins_program_error_log;
PROCEDURE get_first_last_name
 (
 ip_lid IN NUMBER,
 ip_Full_Name IN VARCHAR2,
 op_first_name OUT VARCHAR2,
 op_last_name OUT VARCHAR2
 )
IS
 v_spaces NUMBER;
 v_Full_Name sa.x_sl_subs.full_name%type;
BEGIN
 /*Get First and Last Names*/
 v_Full_Name := ip_Full_Name;
 IF NVL(trim(v_Full_Name),' ') != ' ' AND instr(v_Full_Name,' ',1,1) > 0 THEN
 WHILE instr(v_Full_Name,'  ',1,1) > 0 -- Make sure 2 spaces present here
 LOOP
 v_Full_Name := REPLACE(v_Full_Name,'  ',' '); -- Make sure 2 spaces present here
 END LOOP;
 v_spaces := 0;
 WHILE instr(v_Full_Name,' ',1,v_spaces+1) > 0
 LOOP
 v_spaces := v_spaces + 1; -- count how many spaces
 END LOOP;
 op_first_name := SUBSTR( v_Full_Name, 1, instr(v_Full_Name,' ',1,ROUND(v_spaces/2))-1);
 op_last_name := SUBSTR( v_Full_Name, instr(v_Full_Name,' ',1,ROUND(v_spaces /2))+1, (LENGTH(v_Full_Name)-instr(v_Full_Name,' ',1,ROUND(v_spaces/2))));
 /*End First and Last Names*/
 ELSE
 op_first_name := v_Full_Name;
 op_last_name := '';
 END IF;
EXCEPTION
WHEN OTHERS THEN
 raise_application_error(-20101, 'ERROR: get_first_last_name'||chr(10)|| 'Lifeline => '||TO_CHAR(ip_lid)||' Full_Name => '||ip_Full_Name||chr(10) ||SQLERRM);
END get_first_last_name;
PROCEDURE p_process_contactedit_job
 (
 ip_process_days IN NUMBER DEFAULT 3,
 op_err_num OUT NUMBER,
 op_err_string OUT VARCHAR2
 )
IS
 /*
 This is the new procedure created to process ContactEdit requests
 read the request records from xsu_vmbc_request and update corresponding
 data in following tables
 x_sl_subs
 table_contact
 table_site
 table_address
 x_sl_hist
 trigger on x_sl_subs = TRIG_X_SL_SUBS is modified
 and it will now only consider the delete action
 All the update actions will be carried out by this proc only.
 */
 v_job_data_id VARCHAR2(50);
 get_curr_esn VARCHAR2(30);
 v_address_1 xsu_vmbc_request.address%type;
 v_address_2 xsu_vmbc_request.address2%type;
 v_sl_subs2table_contact x_sl_subs.sl_subs2table_contact%type;
 v_first_name table_contact.first_name%type;
 v_last_name table_contact.last_name%type;
 v_job_run_objid x_job_run_details.objid%type;
 l_add_objid table_site.objid%type;
 lv_records_processed pls_integer := 0;
 lv_records_not_processed pls_integer := 0;
 record_not_processed EXCEPTION;
 lv_record_not_processed_reason VARCHAR2(1000);
 CURSOR cur_contactedit_request
 IS
 SELECT
 /*+ INDEX(XSU IND_XSUVMBC_REQ_BATCH_DT) */
 xsu.rowid AS current_record_rowid ,
 xsu.*
 FROM xsu_vmbc_request xsu
 WHERE 1 = 1
 AND xsu.batchdate > TRUNC(sysdate) - ip_process_days
 AND xsu.requesttype = 'ContactEdit'
 --ensure this contactedit request is not processed
 AND xsu.requestid IS NULL ;
 CURSOR get_address_id (ip_objid IN NUMBER)
 IS
 SELECT ts.objid,
 ts.cust_primaddr2address,
 ts.cust_billaddr2address,
 ts.cust_shipaddr2address
 FROM table_contact c,
 sa.table_contact_role cr,
 sa.table_site ts
 WHERE c.objid = ip_objid
 AND cr.contact_role2contact = c.objid
 AND ts.objid = cr.contact_role2site;
 get_address_id_rec get_address_id%rowtype;
 CURSOR timezone_curs
 IS
 SELECT objid FROM table_time_zone WHERE name = 'EST';
 timezone_rec timezone_curs%rowtype;
 CURSOR country_curs
 IS
 SELECT objid FROM table_country WHERE name = 'USA';
 country_rec country_curs%rowtype;
 CURSOR state_curs ( c_st IN VARCHAR2 ,c_country_objid IN NUMBER )
 IS
 SELECT objid
 FROM table_state_prov
 WHERE s_name = upper(c_st)
 AND state_prov2country = c_country_objid;
 state_rec state_curs%rowtype;
BEGIN
 dbms_output.put_line('********** START OF PROCEDURE SA.safelink_services_pkg.p_process_contactedit_job **********');
 op_err_num := 0;
 op_err_string := 'SUCCESS';
 create_job_instance ( ip_job_name => 'SAFELINK_CONTACT_EDIT', ip_status => 'RUNNING', ip_job_run_mode => '0', ip_seq_name => 'X_JOB_RUN_DETAILS', ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status_code => NULL, ip_sub_sourcesystem => 'SAFELINK', op_job_run_objid => v_job_run_objid );
 OPEN timezone_curs;
 FETCH timezone_curs INTO timezone_rec;
 CLOSE timezone_curs;
 OPEN country_curs;
 FETCH country_curs INTO country_rec;
 CLOSE country_curs;
 FOR rec_contactedit_request IN cur_contactedit_request
 LOOP
 BEGIN
 v_address_1 := regexp_replace (rec_contactedit_request.address, 'box', 'B0X', 1, 0, 'i');
 v_address_2 := NVL (rec_contactedit_request.address2, '');
 v_sl_subs2table_contact := NULL;
 UPDATE x_sl_subs
 SET full_name = rec_contactedit_request.name,
 address_1 = v_address_1,
 address_2 = v_address_2,
 city = rec_contactedit_request.city,
 state = rec_contactedit_request.state,
 zip = rec_contactedit_request.zip,
 zip2 = rec_contactedit_request.zip2,
 country = rec_contactedit_request.country,
 e_mail = NVL (rec_contactedit_request.email, ''),
 x_homenumber = NVL (rec_contactedit_request.homenumber, ''),
 x_external_account = rec_contactedit_request.external_account,
 x_shp_address = regexp_replace (rec_contactedit_request .x_shp_address, 'box', 'B0X', 1, 0, 'i') ,
 x_shp_address2 = NVL (rec_contactedit_request.x_shp_address2, ' ' ),
 x_shp_city = rec_contactedit_request.x_shp_city,
 x_shp_state = rec_contactedit_request.x_shp_state,
 x_shp_zip = rec_contactedit_request.x_shp_zip
 WHERE lid = rec_contactedit_request.lid returning sl_subs2table_contact
 INTO v_sl_subs2table_contact;
 IF sql%rowcount = 0 OR v_sl_subs2table_contact IS NULL THEN
 g_requestid := '-50'; -- Business exception. Check the data to correct.
 lv_record_not_processed_reason := 'LID=' || rec_contactedit_request.lid || ' not found in X_SL_SUBS or SL_SUBS2TABLE_CONTACT is null';
 raise record_not_processed;
 END IF;
 UPDATE x_sl_subs_dtl
 SET x_addressiscommercial = rec_contactedit_request.addressiscommercial,
 x_addressisduplicated = rec_contactedit_request.addressisduplicated,
 x_addressisinvalid = rec_contactedit_request.addressisinvalid,
 x_addressistemporary = rec_contactedit_request.addressistemporary,
 x_stateidname = rec_contactedit_request.stateidname,
 x_stateidvalue = rec_contactedit_request.stateidvalue,
 x_adl = rec_contactedit_request.adl,
 x_usacform = rec_contactedit_request.usacform,
 x_hmodisclaimer = rec_contactedit_request.hmodisclaimer,
 x_ipaddress = rec_contactedit_request.ipaddress,
 x_shippingaddresshash = rec_contactedit_request.shippingaddresshash,
 x_status = rec_contactedit_request.status,
 x_lastmodified = rec_contactedit_request.lastmodified,
 x_disablemanualverification = rec_contactedit_request.disablemanualverification,
 x_language = rec_contactedit_request.registrationlanguage
 WHERE lid = rec_contactedit_request.lid;
 IF sql%rowcount = 0 THEN
 g_requestid := '-51'; -- Business exception. Check the data to correct.
 lv_record_not_processed_reason := 'LID=' || rec_contactedit_request.lid || ' not found in X_SL_SUBS_DTL';
 raise record_not_processed;
 END IF;
 INSERT
 INTO sa.x_sl_hist
 (
 objid,
 lid,
 x_esn,
 x_event_dt,
 x_insert_dt,
 x_event_value,
 x_event_code,
 x_event_data,
 x_min,
 username,
 x_sourcesystem,
 x_code_number,
 x_src_table,
 x_src_objid,
 x_program_enrolled_id
 )
 VALUES
 (
 sa.seq_x_sl_hist.nextval,
 rec_contactedit_request.lid,
 NULL, ---rec_contactedit_request.x_current_esn,
 sysdate,
 sysdate,
 NULL,
 608,
 NULL ---rec_contactedit_request.x_current_esn
 ||','
 ||v_address_1
 ||','
 ||rec_contactedit_request.city
 ||','
 ||rec_contactedit_request.state
 ||','
 ||rec_contactedit_request.zip
 ||','
 ||rec_contactedit_request.country
 ||','
 ||rec_contactedit_request.homenumber
 ||','
 ||rec_contactedit_request.email ,
 NULL,
 'SYSTEM',
 'VMBC',
 0,
 'X_SL_SUBS',
 rec_contactedit_request.lid,
 NULL---rec_contactedit_request.x_current_pe_id
 );
 /*
 select sl_subs2table_contact
 into v_sl_subs2table_contact
 from x_sl_subs
 where
 lid = rec_contactedit_request.lid;
 */
 IF NVL(v_sl_subs2table_contact,-1) <> -1 THEN
 get_first_last_name(rec_contactedit_request.lid, rec_contactedit_request.name,v_first_name,v_last_name);
 UPDATE table_contact
 SET address_1 = v_address_1,
 address_2 = v_address_2,
 city = rec_contactedit_request.city,
 state = rec_contactedit_request.state,
 zipcode = rec_contactedit_request.zip,
 country = rec_contactedit_request.country,
 phone = rec_contactedit_request.homenumber,
 x_no_phone_flag = DECODE(rec_contactedit_request.homenumber, NULL,1,0),
 e_mail = rec_contactedit_request.email,
 first_name = v_first_name,
 s_first_name = upper(v_first_name),
 last_name = v_last_name,
 s_last_name = upper(v_last_name)
 WHERE objid = v_sl_subs2table_contact;
 --- updating address in table_address
 OPEN get_address_id(v_sl_subs2table_contact);
 LOOP
 FETCH get_address_id INTO get_address_id_rec;
 EXIT
 WHEN get_address_id%notfound;
 IF NVL(get_address_id_rec.cust_primaddr2address,-1) <> -1 THEN
 UPDATE table_address a
 SET a.address = v_address_1,
 a.s_address = upper(v_address_1),
 a.address_2 = v_address_2,
 a.city = rec_contactedit_request.city,
 a.s_city = upper(rec_contactedit_request.city),
 a.state = rec_contactedit_request.state,
 a.s_state = upper(rec_contactedit_request.state),
 a.zipcode = rec_contactedit_request.zip
 WHERE a.objid = get_address_id_rec.cust_primaddr2address; --Primary
 -- address
 END IF;
 IF NVL(get_address_id_rec.cust_billaddr2address,-1) <> -1 AND NVL( get_address_id_rec.cust_billaddr2address, -1) <> get_address_id_rec.cust_primaddr2address THEN
 UPDATE table_address a
 SET a.address = v_address_1,
 a.s_address = upper(v_address_1),
 a.address_2 = v_address_2,
 a.city = rec_contactedit_request.city,
 a.s_city = upper(rec_contactedit_request.city),
 a.state = rec_contactedit_request.state,
 a.s_state = upper(rec_contactedit_request.state),
 a.zipcode = rec_contactedit_request.zip
 WHERE a.objid = get_address_id_rec.cust_billaddr2address; --Billing
 -- address
 END IF;
 IF NVL(get_address_id_rec.cust_shipaddr2address,-1) <> -1 AND NVL( get_address_id_rec.cust_shipaddr2address, -1) <> get_address_id_rec.cust_primaddr2address THEN
 IF NVL(rec_contactedit_request.x_shp_address, 'X') <> 'X' THEN
 UPDATE table_address a
 SET a.address = rec_contactedit_request.x_shp_address,
 a.s_address = upper (rec_contactedit_request .x_shp_address),
 a.address_2 = rec_contactedit_request.x_shp_address2,
 a.city = rec_contactedit_request.x_shp_city,
 a.s_city = upper (rec_contactedit_request.x_shp_city ) ,
 a.state = rec_contactedit_request.x_shp_state,
 a.s_state = upper (rec_contactedit_request.x_shp_state) ,
 a.zipcode = rec_contactedit_request.x_shp_zip
 WHERE a.objid = get_address_id_rec.cust_shipaddr2address; --Shipping
 -- address
 ELSE
 UPDATE table_site
 SET cust_shipaddr2address = get_address_id_rec.cust_primaddr2address
 WHERE objid = get_address_id_rec.objid;
 END IF ;
 elsif NVL(get_address_id_rec.cust_shipaddr2address,-1) = get_address_id_rec.cust_primaddr2address AND NVL( rec_contactedit_request.x_shp_address, 'X') <> 'X' THEN
 OPEN state_curs(rec_contactedit_request.x_shp_state, country_rec.objid);
 FETCH state_curs INTO state_rec;
 CLOSE state_curs;
 l_add_objid := sa.seq('address');
 INSERT
 INTO table_address
 (
 objid ,
 address ,
 s_address ,
 city ,
 s_city ,
 state ,
 s_state ,
 zipcode ,
 address_2 ,
 dev ,
 address2time_zone ,
 address2country ,
 address2state_prov ,
 update_stamp
 )
 VALUES
 (
 l_add_objid ,
 rec_contactedit_request.x_shp_address ,
 upper(rec_contactedit_request.x_shp_address) ,
 rec_contactedit_request.x_shp_city ,
 upper(rec_contactedit_request.x_shp_city) ,
 rec_contactedit_request.x_shp_state ,
 upper(rec_contactedit_request.x_shp_state) ,
 rec_contactedit_request.x_shp_zip ,
 rec_contactedit_request.x_shp_address2 ,
 NULL ,
 timezone_rec.objid ,
 country_rec.objid ,
 state_rec.objid ,
 sysdate
 );
 UPDATE table_site
 SET cust_shipaddr2address = l_add_objid
 WHERE objid = get_address_id_rec.objid;
 END IF;
 END LOOP;
 CLOSE get_address_id;
 END IF;
 UPDATE xsu_vmbc_request xsu
 SET requestid = v_job_run_objid
 WHERE rowid = rec_contactedit_request.current_record_rowid;
 lv_records_processed := lv_records_processed + 1;
 COMMIT;
 EXCEPTION
 WHEN record_not_processed THEN
 lv_records_not_processed := lv_records_not_processed + 1;
 g_request := 'LID='||rec_contactedit_request.lid;
 g_err_msg := lv_record_not_processed_reason || '. Current LID processing failed.' ||' sqlerrm: '|| SUBSTR(dbms_utility.format_error_backtrace,1, 500);
 ins_job_err (TO_CHAR(v_job_run_objid), 'ContactEdit', g_request, g_err_msg);
 UPDATE xsu_vmbc_request xsu
 SET requestid = g_requestid
 ||'|'
 ||v_job_run_objid
 WHERE rowid = rec_contactedit_request.current_record_rowid;
 WHEN OTHERS THEN
 ROLLBACK;
 lv_records_not_processed := lv_records_not_processed + 1;
 ---log the current LID processing failed
 g_request := 'LID='||rec_contactedit_request.lid;
 g_err_msg := 'Current LID processing failed.. sqlcode : '||SQLCODE ||' sqlerrm: '||sqlerrm;
 ins_job_err (TO_CHAR(v_job_run_objid), 'ContactEdit', g_request, g_err_msg);
 UPDATE xsu_vmbc_request xsu
 SET requestid = g_requestid
 ||'|'
 ||v_job_run_objid
 WHERE rowid = rec_contactedit_request.current_record_rowid;
 END;
 END LOOP; --main cursor end loop
 dbms_output.put_line('No. of rows processed: '||lv_records_processed);
 dbms_output.put_line('No. of rows failed: '||lv_records_not_processed);
 update_job_instance ( ip_job_run_objid => v_job_run_objid, ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status => 'SUCCESS', ip_status_code => '0', ip_sub_sourcesystem => 'SAFELINK' );
 dbms_output.put_line('********** END OF PROCEDURE p_process_contactedit_job **********');
EXCEPTION
WHEN OTHERS THEN
 ROLLBACK;
 op_err_num := SQLCODE;
 op_err_string := 'FAILED';
 g_err_msg := '' || ', No. of rows processed: '|| NVL(lv_records_processed,0) || ', No. of rows failed: '|| NVL(lv_records_not_processed,0) ||', p_process_contactedit_job Failed..ERR='|| SUBSTR(sqlerrm,1,500) ;
 ---log job error
 ins_job_err (TO_CHAR(v_job_run_objid), 'ContactEdit', 'sqlcode: '||SQLCODE, g_err_msg);
 update_job_instance ( ip_job_run_objid => v_job_run_objid, ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status => 'FAILED', ip_status_code => '505', ip_sub_sourcesystem => 'SAFELINK' );
 dbms_output.put_line('********** EXCEPTION WHILE RUNNING PROCEDURE p_process_contactedit_job ********** ' || 'op_err_num='||op_err_num ||' g_err_msg: '||g_err_msg );
END p_process_contactedit_job;
PROCEDURE p_load_e911_tax_recon_data(
 in_rundays IN NUMBER DEFAULT 1,
 op_err_num OUT NUMBER,
 op_err_string OUT VARCHAR2 )
IS
 /* CR30286 - Safelink e911
 procedure created to copy data from OFS to CLFY
 OFS stores the check payments data received from banks everyday
 table = TF.XXTF_E911_TAX_RECON_TBL@OFSDEV
 These check payments are Safelink e911 payments
 there is no other data in this table.
 Input parameter
 in_rundays = number of days in past to consider for data copy
 Output parameters
 op_err_num = 0 if success - copied all records from OFS to CLFY from days specified
 = -1 if there is no data found in OFS to copy in CLFY from days specified
 = -2 if partial data loaded and partial data failed
 op_err_string = SUCCESS or some error text
 */
 CURSOR cur_source_data (in_date IN DATE)
 IS
 SELECT *
 FROM tf.xxtf_e911_tax_recon_tbl @ofsprd
 WHERE last_update_date >= in_date ;
type typ_source_data
IS
 TABLE OF cur_source_data%rowtype INDEX BY pls_integer;
 tab_source_data typ_source_data;
 bulk_errors EXCEPTION;
 pragma exception_init (bulk_errors, -24381);
 lv_rundate DATE;
 lv_records_loaded NUMBER;
 lv_records_failed NUMBER;
 lv_error_text VARCHAR2(200);
BEGIN
 --dbms_output.put_line('*** rundate ='|| trunc(sysdate-in_rundays) );
 BEGIN
 lv_records_loaded := 0;
 lv_records_failed := 0;
 lv_rundate := TRUNC(sysdate-NVL(in_rundays,1));
 OPEN cur_source_data (lv_rundate);
 LOOP
 FETCH cur_source_data bulk collect INTO tab_source_data limit 500;
 EXIT
 WHEN tab_source_data.count = 0;
 --dbms_output.put_line('recs loaded in memory = '|| tab_source_data.count );
 lv_records_loaded := lv_records_loaded + tab_source_data.count;
 BEGIN
 forall irec IN 1..tab_source_data.count SAVE exceptions
 INSERT
 INTO sa.xxtf_e911_tax_recon_tbl
 (
 CASH_RECEIPT_ID,
 OFS_CHECK_NO,
 RECEIPT_DATE,
 CUSTOMER_CHECK_NO,
 CHECK_BANK,
 CHECK_ACCOUNT,
 CHECK_AMOUNT,
 FISRT_NAME,
 LAST_NAME,
 ADDRESS1,
 ADDRESS2,
 CITY,
 STATE,
 ZIP,
 PHONE_NUMBER,
 LLID,
 ESN,
 PAYMENT_TYPE,
 RETURNED,
 TAX_STATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN,
 CREATED_BY,
 CREATION_DATE
 )
 VALUES
 (
 tab_source_data(irec).CASH_RECEIPT_ID,
 tab_source_data(irec).OFS_CHECK_NO,
 tab_source_data(irec).RECEIPT_DATE,
 tab_source_data(irec).CUSTOMER_CHECK_NO,
 tab_source_data(irec).CHECK_BANK,
 tab_source_data(irec).CHECK_ACCOUNT,
 tab_source_data(irec).CHECK_AMOUNT,
 tab_source_data(irec).FISRT_NAME,
 tab_source_data(irec).LAST_NAME,
 tab_source_data(irec).ADDRESS1,
 tab_source_data(irec).ADDRESS2,
 tab_source_data(irec).CITY,
 tab_source_data(irec).STATE,
 tab_source_data(irec).ZIP,
 tab_source_data(irec).PHONE_NUMBER,
 tab_source_data(irec).LLID,
 tab_source_data(irec).ESN,
 tab_source_data(irec).PAYMENT_TYPE,
 tab_source_data(irec).RETURNED,
 tab_source_data(irec).TAX_STATE,
 tab_source_data(irec).LAST_UPDATED_BY,
 tab_source_data(irec).LAST_UPDATE_DATE,
 tab_source_data(irec).LAST_UPDATE_LOGIN,
 tab_source_data(irec).CREATED_BY,
 tab_source_data(irec).CREATION_DATE
 );
 EXCEPTION
 WHEN bulk_errors THEN
 lv_records_failed := lv_records_failed + sql%bulk_exceptions.count;
 END;
 COMMIT;
 END LOOP;
 CLOSE cur_source_data;
 IF (lv_records_loaded > 0 AND lv_records_failed = 0) THEN
 op_err_num := 0;
 op_err_string := 'SUCCESS';
 lv_error_text := '' || 'No. of records copied = ' || TO_CHAR(lv_records_loaded);
 elsif lv_records_loaded = 0 THEN
 op_err_num := -1;
 op_err_string := 'SUCCESS with Errors.';
 lv_error_text := 'No data found in OFS to load in CLFY.' || 'Date run = ' || TO_CHAR(lv_rundate,'dd-mon-rrrr hh24:mi:ss');
 elsif lv_records_failed > 0 THEN
 op_err_num := -2;
 op_err_string := 'SUCCESS with Errors.';
 lv_error_text := '' || 'No. of records copied = ' || TO_CHAR(lv_records_loaded - lv_records_failed ) || ', No. of records failed to copy = ' || TO_CHAR(lv_records_failed) || '. Date run = ' || TO_CHAR(lv_rundate,'dd-mon-rrrr hh24:mi:ss') ;
 END IF;
 sa.ota_util_pkg.err_log ( p_action => 'Load e911 check payments from OFS to CLFY', p_error_date => sysdate, p_key => 'p_load_e911_tax_recon_data', p_program_name => 'p_load_e911_tax_recon_data', p_error_text => op_err_string || ' ' || lv_error_text );
 EXCEPTION
 WHEN OTHERS THEN
 ROLLBACK;
 op_err_num := SQLCODE;
 op_err_string := 'FAILURE..ERR=' || SUBSTR(dbms_utility.format_error_backtrace,1,100);
 sa.ota_util_pkg.err_log ( p_action => 'Load e911 check payments from OFS to CLFY', p_error_date => sysdate, p_key => 'p_load_e911_tax_recon_data', p_program_name => 'p_load_e911_tax_recon_data', p_error_text => SUBSTR('SQLERRM='|| sqlerrm, 1, 1000) );
 END;
END p_load_e911_tax_recon_data;
-- This will be obsolote
PROCEDURE p_deneroll_job
 (
 ip_esn IN VARCHAR2,
 ip_lid IN NUMBER,
 ip_reason IN VARCHAR2,
 ip_phone_part_num IN VARCHAR2,
 ip_enroll_objid IN NUMBER,
 op_err_no OUT NUMBER,
 op_err_msg OUT VARCHAR2
 )
IS
 /*
 This proc is to modify the De-Enrollment process to
 add an extra check to see if the same ESN also enrolled in any HMO programs.
 If so, deenroll from that plan also.
 CR31989 02/21/2015
 */
BEGIN
 UPDATE x_program_enrolled
 SET x_enrollment_status = 'READYTOREENROLL',
 X_NEXT_DELIVERY_DATE = NULL
 WHERE objid = ip_enroll_objid;
 IF SQL%ROWCOUNT =1 THEN
 NULL ;
 ELSE
 op_err_no :=1;
 op_err_msg :='Record is not updated in the x_program_enrolled';
 RETURN;
 END IF;
 DBMS_OUTPUT.PUT_LINE('READY TO DEENROLL');
 INSERT
 INTO x_program_trans
 (
 objid,
 x_enrollment_status,
 x_enroll_status_reason,
 x_trans_date,
 x_action_text,
 x_action_type,
 x_reason,
 x_sourcesystem,
 x_esn,
 x_update_user,
 pgm_tran2pgm_entrolled,
 pgm_trans2web_user,
 pgm_trans2site_part
 )
 VALUES
 (
 BILLING_SEQ ('x_program_trans'),
 'READYTOREENROLL',
 'DeEnrollment Scheduled',
 SYSDATE,
 'Voluntary DeEnrollment',
 'DE_ENROLL',
 'Safelink Wireless Customer Voluntary DeEnrollment',
 'System',
 ip_esn ,
 'operations',
 ip_enroll_objid,
 (SELECT pgm_enroll2web_user
 FROM x_program_enrolled
 WHERE objid = ip_enroll_objid
 ),
 (SELECT objid
 FROM table_site_part
 WHERE x_service_id = ip_esn
 AND part_status
 || '' = 'Active'
 )
 );
 IF SQL%ROWCOUNT =1 THEN
 NULL ;
 ELSE
 op_err_no :=2;
 op_err_msg :='Record is not created in the x_program_trans';
 RETURN;
 END IF;
 DBMS_OUTPUT.PUT_LINE('DEENROLLMENT SCHEDULED');
 UPDATE table_x_ota_features xof
 SET xof.x_ild_prog_status= 'Completed',
 xof.x_ild_carr_status ='Active'
 WHERE 1 =1
 AND EXISTS
 (SELECT 1
 FROM table_part_inst pi
 WHERE pi.objid =xof.x_ota_features2part_inst
 AND pi.part_serial_no = ip_esn
 );
 IF SQL%ROWCOUNT =1 THEN
 NULL ;
 ELSE
 ROLLBACK;
 op_err_no :=3;
 op_err_msg:='Record is not updated in the table_x_ota_features';
 RETURN;
 END IF;
 UPDATE table_site_part
 SET SITE_PART2X_PLAN = sa.PRELOADED_CLICK(ip_phone_part_num)
 WHERE x_service_id =ip_esn
 AND part_status = 'Active';
 IF SQL%ROWCOUNT =1 THEN
 NULL ;
 ELSE
 ROLLBACK;
 op_err_no :=4;
 op_err_msg:='Record is not updated in the table_site_part';
 RETURN;
 END IF;
 UPDATE X_SL_CURRENTVALS
 SET X_DEENROLL_REASON = IP_REASON,
 X_CURRENT_ACTIVE = 'N' ,
 X_CURRENT_ENROLLED = 'N'
 WHERE LID = ip_lid
 AND X_CURRENT_ESN = IP_ESN;
 IF SQL%ROWCOUNT =1 THEN
 NULL ;
 ELSE
 ROLLBACK;
 op_err_no :=5;
 op_err_msg:='Record is not updated in the table_site_part';
 RETURN;
 END IF;
 COMMIT;
 DBMS_OUTPUT.PUT_LINE('DEENROLLMENT COMPLETED');
 op_err_no :=0;
 op_err_msg:='Success';
EXCEPTION
WHEN OTHERS THEN
 ROLLBACK;
 OP_ERR_NO := SQLCODE;
 op_err_msg:= SQLCODE || SUBSTR (SQLERRM, 1, 100);
 INSERT
 INTO X_PROGRAM_ERROR_LOG
 (
 X_SOURCE ,
 X_ERROR_MSG ,
 X_DATE,
 X_DESCRIPTION ,
 X_SEVERITY
 )
 VALUES
 (
 'SA.safelink_services_pkg.p_deneroll_job',
 op_err_msg,
 SYSDATE,
 'SA.safelink_services_pkg.p_deneroll_job',
 1
 );
 COMMIT;
END p_deneroll_job;
-- Modified procedure in SL Imp
PROCEDURE p_deenroll_job
 (
 ip_esn IN VARCHAR2,
 ip_source_system IN VARCHAR2,
 ip_deenroll_reason IN VARCHAR2,
 op_err_no OUT NUMBER,
 op_err_msg OUT VARCHAR2
 )
IS
 lv_deenroll_reason x_sl_currentvals.x_deenroll_reason%TYPE;
 lv_err_no VARCHAR2(500);
 lv_err_msg VARCHAR2(5000);
 exception_record_not_processed EXCEPTION;
 exception_record_not_required EXCEPTION;
 CURSOR cur_prog_enrolled(in_esn IN VARCHAR)
 IS
 SELECT pe.objid prog_enrolled_objid,
 pe.pgm_enroll2web_user pgm_enroll2web_user,
 pe.x_language x_language,
 pe.pgm_enroll2pgm_parameter pgm_enroll2pgm_parameter,
 pe.pgm_enroll2contact pgm_enroll2contact,
 tsp.objid table_site_part_objid ,
 pp_out.x_program_name x_program_name,
 pp_out.x_program_desc x_program_desc,
 pp_out.x_prog_class x_prog_class,
 slcur.lid lid
 FROM x_program_enrolled pe,
 x_program_parameters pp_out,
 x_sl_currentvals slcur,
 table_site_part tsp
 WHERE 1 =1
 AND pe.x_esn = in_esn
 AND pe.x_enrollment_status = 'ENROLLED'
 AND pp_out.objid = pe.pgm_enroll2pgm_parameter
 AND slcur.x_current_esn = pe.x_esn
 AND tsp.x_service_id = slcur.x_current_esn
 AND part_status
 || '' = 'Active'
 AND EXISTS
 (SELECT 1
 FROM x_program_parameters pp
 WHERE 1 =1
 AND pp.objid = pe.pgm_enroll2pgm_parameter
 AND pp.x_prog_class IN ('LIFELINE', 'HMO')
 ) ;
 rec_prog_enrolled cur_prog_enrolled%rowtype;
 CURSOR cur_esn_dtl(in_esn IN VARCHAR)
 IS
 SELECT pn.part_number part_number,
 pi.objid pi_objid,bo.org_id
 FROM table_part_inst pi ,
 sa.table_mod_level ml ,
 sa.table_part_num pn ,
 sa.table_bus_org bo ,
 sa.table_part_class pc
 WHERE 1 = 1
 AND pi.x_domain = 'PHONES'
 AND pi.x_part_inst_status = '52'
 AND ml.objid = pi.n_part_inst2part_mod
 AND pn.objid = ml.part_info2part_num
 AND bo.objid = pn.part_num2bus_org
 AND pc.objid = pn.part_num2part_class
 AND pi.part_serial_no = in_esn;
 rec_esn_dtl cur_esn_dtl%rowtype;
 CURSOR cur_deenroll_flag(in_deenroll_reason IN VARCHAR)
 IS
 SELECT SUBSTR(in_deenroll_reason, 1,300) X_DEENROLL_REASON
 FROM sa.x_sl_deenroll_flag df
 WHERE 1 = 1
 AND in_deenroll_reason LIKE (trim(df.x_bill_flag)
 ||trim(TO_CHAR(df.x_deenroll_flag,'00')))
 ||'%';
 rec_deenroll_flag cur_deenroll_flag%rowtype;

 --CR30860 SL SMARTPHONE UPGRADE
 CURSOR cur_ild_deenroll(in_esn IN VARCHAR)
 IS
 SELECT * FROM table_x_ild_transaction WHERE x_esn= in_esn
 AND X_ILD_TRANS_TYPE = 'A' AND X_ILD_STATUS = 'COMPLETED' AND X_PRODUCT_ID = 'SL_TFILD_P';
 lv_debug INTEGER := 0;
 lv_parameter_value sa.table_x_part_class_values.x_param_value%TYPE;
 lv_error_code INTEGER;
 lv_error_message VARCHAR2(4000);

BEGIN
 op_err_no := 0;
 op_err_msg := 'SUCCESS';
 --check if esn is valid
 OPEN cur_esn_dtl(ip_esn);
 FETCH cur_esn_dtl INTO rec_esn_dtl;
 IF cur_esn_dtl%rowcount = 0 THEN
 CLOSE cur_esn_dtl;
 op_err_no := -20;
 op_err_msg :='Phone is not active. x_esn: '||ip_esn;
 raise exception_record_not_processed;
 END IF;
 CLOSE cur_esn_dtl;
 IF ip_deenroll_reason IS NULL THEN
 lv_deenroll_reason := 'D03 - DEENROLL VOLUNTARY EXIT';
 ELSE
 OPEN cur_deenroll_flag(ip_deenroll_reason);
 FETCH cur_deenroll_flag INTO rec_deenroll_flag;
 lv_deenroll_reason := rec_deenroll_flag.x_deenroll_reason;
 IF cur_deenroll_flag%rowcount = 0 THEN
 CLOSE cur_deenroll_flag;
 op_err_no := -21;
 op_err_msg :='Deenroll reason is not valid: '||ip_deenroll_reason|| ' ip_source_system: '||ip_source_system||' x_esn: '||ip_esn;
 raise exception_record_not_processed;
 END IF;
 CLOSE cur_deenroll_flag;
 END IF;
 OPEN cur_prog_enrolled(ip_esn);
 LOOP
 FETCH cur_prog_enrolled INTO rec_prog_enrolled;
 IF cur_prog_enrolled%notfound THEN
 UPDATE x_sl_currentvals
 SET x_deenroll_reason = lv_deenroll_reason,
 x_current_enrolled = 'N'
 WHERE lid = rec_prog_enrolled.lid;
 op_err_no := 0;
 op_err_msg := 'Success. ESN is already deenrolled or not active ...x_esn: '|| ip_esn;
 CLOSE cur_prog_enrolled;
 raise exception_record_not_required;
 ELSE ---if cur_prog_enrolled%notfound then
 /* make the ESN as ready to reenroll for both programs = safleink and hmo */
 UPDATE x_program_enrolled pe
 SET x_enrollment_status = 'READYTOREENROLL',
 x_next_delivery_date = NULL,
 x_update_stamp = SYSDATE
 WHERE 1 =1
 AND objid = rec_prog_enrolled.prog_enrolled_objid;
 IF SQL%rowcount <= 1 THEN --- deenroll 2 programs - safelink and hmo
 NULL ;
 ELSE
 op_err_no := -22;
 op_err_msg := 'Record is not updated in the x_program_enrolled for objid = '|| rec_prog_enrolled.prog_enrolled_objid||' and x_prog_class = '|| rec_prog_enrolled.x_prog_class||' x_esn: '||ip_esn;
 raise exception_record_not_processed;
 END IF;

 --CR30860 SL SMARTPHONE UPGRADE
 IF rec_prog_enrolled.x_prog_class = 'LIFELINE' THEN
 FOR rec_ild_deenroll IN cur_ild_deenroll(ip_esn)
 LOOP
 INSERT
 INTO x_program_gencode
 (
 objid,
 x_esn,
 x_insert_date,
 x_status,
 GENCODE2PROG_PURCH_HDR,
 x_ota_trans_id,
 SW_FLAG --CR38927
 )
 VALUES
 (
 (
 sa.SEQ_X_PROGRAM_GENCODE.NEXTVAL
 )
 ,
 ip_esn,
 LAST_DAY(SYSDATE)+1 , --MONTH END SYSDATE
 'SW_INSERTED', --VYCHECK CALL VASU
 NULL, --VYCHECK CALL VASU
 256, -- CALL VASU 256
 'SW_ILD_D' --SW ILD DE ENROLL
 );
 END LOOP;
 END IF;


 ---------------
 --Entry to gencodes if deenroll ESN is NON PPE (CR38927 SL UPGRADE START)

 --sa.sp_get_esn_parameter_value(IP_ESN, 'DEVICE_TYPE', lv_debug, lv_parameter_value, lv_error_code, lv_error_message);
	 lv_parameter_value:=get_device_type(IP_ESN);
 IF  rec_prog_enrolled.x_prog_class = 'LIFELINE'
 AND rec_esn_dtl.org_id = 'TRACFONE'
 THEN --{
  IF lv_parameter_value in ('BYOP','SMARTPHONE' )
  THEN --{
   INSERT
   INTO x_program_gencode
   (
   objid,
   x_esn,
   x_insert_date,
   x_status,
   GENCODE2PROG_PURCH_HDR,
   x_ota_trans_id,
   SW_FLAG --CR29935
   )
   VALUES
   (
   (
   sa.SEQ_X_PROGRAM_GENCODE.NEXTVAL
   )
   ,
   ip_esn,
   LAST_DAY(SYSDATE)+1 , --MONTH END SYSDATE
   'SW_INSERTED', --VYCHECK CALL VASU
   NULL, --VYCHECK CALL VASU
   256, -- CALL VASU 256
   'SW_RP' --SW ILD DE ENROLL
   );
 IF SQL%rowcount <> 1 THEN
  ROLLBACK;
  op_err_no := -26;
  op_err_msg:='Record is not updated in the x_service_plan_site_part'||' x_esn: '||ip_esn;
  raise exception_record_not_processed;
 END IF;

 END IF; --}

 ------------------
 IF lv_parameter_value in ('FEATURE_PHONE' )
 THEN --{

  IF sa.get_sw_cr_flag(ip_esn) = 'SW_CR'
  THEN --{
   INSERT
   INTO x_program_gencode
   (
   objid,
   x_esn,
   x_insert_date,
   x_status,
   GENCODE2PROG_PURCH_HDR,
   x_ota_trans_id,
   SW_FLAG --CR29935
   )
   VALUES
   (
   (
   sa.SEQ_X_PROGRAM_GENCODE.NEXTVAL
   )
   ,
   ip_esn,
   LAST_DAY(SYSDATE)+1 , --MONTH END SYSDATE
   'SW_INSERTED', --VYCHECK CALL VASU
   NULL, --VYCHECK CALL VASU
   256, -- CALL VASU 256
   'SW_RP' --SW ILD DE ENROLL
   );
   IF SQL%rowcount <> 1 THEN
    ROLLBACK;
    op_err_no := -27;
    op_err_msg:='Record is not updated in the x_service_plan_site_part'||' x_esn: '||ip_esn;
    raise exception_record_not_processed;
   END IF;
  ELSE --}{
   INSERT
   INTO x_program_gencode
   (
   objid,
   x_esn,
   x_insert_date,
   x_status,
   GENCODE2PROG_PURCH_HDR,
   x_ota_trans_id,
   SW_FLAG --CR29935
   )
   VALUES
   (
   (
   sa.SEQ_X_PROGRAM_GENCODE.NEXTVAL
   )
   ,
   ip_esn,
   LAST_DAY(SYSDATE)+1 , --MONTH END SYSDATE
   'SW_INSERTED', --VYCHECK CALL VASU
   NULL, --VYCHECK CALL VASU
   256, -- CALL VASU 256
   'PPE_RP' --SW ILD DE ENROLL
   );
   IF SQL%rowcount <> 1 THEN
    ROLLBACK;
    op_err_no := -28;
    op_err_msg:='Record is not updated in the x_service_plan_site_part'||' x_esn: '||ip_esn;
    raise exception_record_not_processed;
   END IF;
  END IF; --}
 END IF; --}
 END IF; --}

 --(CR38927 SL UPGRADE END )
 INSERT
 INTO x_program_trans
 (
 objid,
 x_enrollment_status,
 x_enroll_status_reason,
 x_trans_date,
 x_action_text,
 x_action_type,
 x_reason,
 x_sourcesystem,
 x_esn,
 x_update_user,
 pgm_tran2pgm_entrolled,
 pgm_trans2web_user,
 pgm_trans2site_part
 )
 VALUES
 (
 billing_seq ('x_program_trans'),
 'READYTOREENROLL',
 'DeEnrollment Scheduled',
 SYSDATE,
 'Voluntary DeEnrollment',
 'DE_ENROLL',
 'Safelink Wireless Customer Voluntary DeEnrollment',
 ip_source_system,
 ip_esn,
 USER,
 rec_prog_enrolled.prog_enrolled_objid,
 rec_prog_enrolled.pgm_enroll2web_user,
 rec_prog_enrolled.table_site_part_objid
 );
 INSERT
 INTO x_billing_log
 (
 objid,
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
 billing_log2web_user
 )
 VALUES
 (
 billing_seq ('X_BILLING_LOG'),
 'Program',
 'Program De-enrolled',
 SYSDATE,
 'Customer DeEnrollment',
 NULL,
 rec_prog_enrolled.x_program_name,
 billing_getnickname (ip_esn),
 ip_esn,
 NULL,
 NULL,
 ip_source_system,
 rec_prog_enrolled.pgm_enroll2web_user
 );
 IF rec_prog_enrolled.x_prog_class = 'LIFELINE' THEN

 IF (rec_esn_dtl.org_id <> 'TRACFONE' OR (rec_esn_dtl.org_id = 'TRACFONE' AND lv_parameter_value ='FEATURE_PHONE')) THEN --CR38927 Safelink upgrades
 UPDATE table_x_ota_features xof
 SET xof.x_ild_prog_status = 'Completed',
 xof.x_ild_carr_status ='Active'
 WHERE 1 =1
 AND xof.x_ota_features2part_inst = rec_esn_dtl.pi_objid;
 IF SQL%rowcount <> 1 THEN
 ROLLBACK;
 op_err_no := -23;
 op_err_msg:='Record is not updated in the table_x_ota_features' ||' x_esn: '||ip_esn;
 raise exception_record_not_processed;
 END IF;
 END IF;--CR38927 Safelink upgrades

 /*UPDATE table_site_part
 SET site_part2x_plan = sa.preloaded_click(rec_esn_dtl.part_number)
 WHERE objid = rec_prog_enrolled.table_site_part_objid;
 IF SQL%rowcount <> 1 THEN
 ROLLBACK;
 op_err_no := -24;
 op_err_msg:='Record is not updated in the table_site_part'||' x_esn: '||ip_esn;
 raise exception_record_not_processed;
 END IF;*/
 UPDATE x_sl_currentvals
 SET x_deenroll_reason = lv_deenroll_reason,
 x_current_enrolled = 'N'
 WHERE lid = rec_prog_enrolled.lid;
 IF SQL%rowcount <> 1 THEN
 ROLLBACK;
 op_err_no := -25;
 op_err_msg:='Record is not updated in the x_sl_currentvals'|| ' x_esn: '||ip_esn;
 raise exception_record_not_processed;
 END IF;
 END IF; --IF rec_prog_enrolled.x_prog_class = 'LIFELINE'
 END IF; ---if cur_prog_enrolled%notfound then
 END LOOP;
 CLOSE cur_prog_enrolled;
 dbms_output.put_line('DEENROLLMENT COMPLETED');
EXCEPTION
WHEN exception_record_not_required THEN
 NULL;
 COMMIT;
WHEN exception_record_not_processed THEN
 ROLLBACK;
 IF ip_source_system = 'TAS' THEN
 lv_err_no := op_err_no;
 lv_err_msg := op_err_msg;
 ins_program_error_log ('sa.safelink_services_pkg.p_deneroll_job', 'Deenroll not processed.'||lv_err_msg, 1, lv_err_no, lv_err_msg);
 END IF;
WHEN OTHERS THEN
 ROLLBACK;
 op_err_no := SQLCODE;
 op_err_msg := SQLCODE || SUBSTR (sqlerrm, 1, 100);
 IF ip_source_system = 'TAS' THEN
 lv_err_no := op_err_no;
 lv_err_msg := op_err_msg;
 ins_program_error_log ('sa.safelink_services_pkg.p_deneroll_job', 'Deenroll not processed.'||lv_err_msg, 1, lv_err_no, lv_err_msg);
 END IF;
END p_deenroll_job;
-- FOR 31989 VMN
-- Modified procedure in SL Imp
PROCEDURE p_process_deenroll_job(
 ip_process_days IN NUMBER DEFAULT 3,
 op_err_no OUT NUMBER,
 op_err_msg OUT VARCHAR2 )
AS
 /*************************************************************************/
 /* Copyright 2015 Tracfone Wireless Inc. All rights reserved */
 /* NAME: p_process_annual_verify_job */
 /* PURPOSE: To update the records in Clarity */
 /* related to recordtype 'Verify' from VMBC */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- ----- ------------------------------------------*/
 /* 1.0 12/09/14 ASHISH RIJAL Initial Revision */
 /* */
 /************************************************************************/
   lv_records_processed             pls_integer := 0;
   lv_records_not_processed         pls_integer := 0;
   lv_record_not_processed_reason   VARCHAR2(1000);
   v_job_run_objid                  x_job_run_details.objid%TYPE;
   v_soft_pin                       table_x_cc_red_inv.x_red_card_number%TYPE;  -- CR50086 Tim 5/22/2018
   v_smp_number                     table_x_cc_red_inv.x_smp%TYPE;              -- CR50086
   v_call_trans_objid               table_x_call_trans.objid%type;              -- CR50086
   v_is_deenroll_ca                 VARCHAR2(1);                                -- CR50086
   c_org_id                         table_bus_org.org_id%TYPE;                  -- CR54533
   n_inv_bin_objid                  table_inv_bin.objid%TYPE;                   -- CR54533
   exception_record_not_processed   EXCEPTION;

   CURSOR cur_deenroll_request
   IS
     SELECT  /*+ INDEX(XSU IND_XSUVMBC_REQ_BATCH_DT) */
             xsu.ROWID AS current_record_rowid,
             xsu.*
     FROM  xsu_vmbc_request xsu
     WHERE 1 = 1
     AND   xsu.requesttype = 'Deenroll'
     AND   xsu.requestid IS NULL
     AND   xsu.batchdate > TRUNC(SYSDATE) - ip_process_days ;

   CURSOR cur_get_esn (cu_lid xsu_vmbc_request.lid%type)
   IS
     SELECT curvals.x_current_esn x_current_esn
     FROM   x_sl_currentvals curvals
     WHERE  1 = 1
     AND    curvals.lid = cu_lid ;
   rec_get_esn cur_get_esn%rowtype;

BEGIN
   dbms_output.put_line('********** START OF PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_DEENROLL_JOB **********');
   op_err_no := 0;
   op_err_msg := 'SUCCESS';
   -- Create new job id
   create_job_instance ( ip_job_name => 'SAFELINK_DEENROLL', ip_status => 'RUNNING', ip_job_run_mode => '0', ip_seq_name => 'X_JOB_RUN_DETAILS', ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status_code => NULL, ip_sub_sourcesystem => 'SAFELINK', op_job_run_objid => v_job_run_objid );
   -- Get records from vmbc table with record type as 'Deenroll'
   FOR rec_deenroll_request IN cur_deenroll_request
   LOOP
      BEGIN
        --- get the esn from for given lid
        OPEN cur_get_esn(rec_deenroll_request.lid);
        FETCH cur_get_esn INTO rec_get_esn;
        IF cur_get_esn%rowcount = 0 THEN
           CLOSE cur_get_esn;
           op_err_no := -28;
           op_err_msg :='ESN is not found in x_sl_currentvals for the lid: '||rec_deenroll_request.lid||' in xsu_vmbc_request.';
           g_requestid := op_err_no;
           raise exception_record_not_processed;
        END IF;
        CLOSE cur_get_esn;
        p_deenroll_job(rec_get_esn.x_current_esn, 'BATCH', rec_deenroll_request.unqualifycode, op_err_no, op_err_msg);
        IF op_err_no = 0 THEN
           UPDATE xsu_vmbc_request xsu
           SET requestid = v_job_run_objid
           WHERE rowid = rec_deenroll_request.current_record_rowid;
           lv_records_processed := lv_records_processed + 1;

           --
           -- CR50086 Tim 5/22/2018
           -- Based on the unqualifycode add a card to the queue.
           --

           v_is_deenroll_ca := 'N';

           BEGIN

              SELECT 'Y'
                INTO v_is_deenroll_ca
                FROM sa.xerox_response_log xrl,
                     sa.xerox_status_code_desc xsc
               WHERE xrl.ults_denial_code = xsc.code
                 AND xsc.courtesy_pin = 'Y'
                 AND TRUNC(xrl.processing_date) > TRUNC(SYSDATE) - 30
                 AND xrl.subscriber_account_number = rec_deenroll_request.lid
                 AND 0 = (SELECT queued_card  -- See if any cards are in queue.  If so skip free card.
                            FROM (
                                  SELECT tsp.objid objid,
                                         (SELECT COUNT(*) -- See esn has card in the queue.
                                            FROM table_part_inst esn,
                                                 table_part_inst lin
                                          WHERE 1 = 1
                                            AND lin.part_to_esn2part_inst = esn.objid
                                            AND lin.X_PART_INST_STATUS = '400'
                                            AND lin.X_DOMAIN = 'REDEMPTION CARDS'
                                            AND esn.part_serial_no = tsp.x_service_id) queued_card,
                                          tsp.x_service_id x_esn,
                                          tsp.x_min x_min
                                     FROM table_site_part tsp
                                    WHERE 1 = 1
                                      AND tsp.x_service_id = rec_get_esn.x_current_esn
                                      AND tsp.part_status = 'Active'
                                   )
                             )
                  AND ROWNUM < 2;

           EXCEPTION WHEN OTHERS THEN
              v_is_deenroll_ca := 'N';

           END;

           IF v_is_deenroll_ca = 'Y' -- Check for flag
              AND
              op_err_msg LIKE 'Success. ESN%' -- Regular de-enrollment.
              THEN

                  --CR54533 Get dealer info
                  BEGIN
                    SELECT objid
                      INTO n_inv_bin_objid
                      FROM table_inv_bin
                     WHERE bin_name = (SELECT x_param_value
                                         FROM table_x_parameters
                                        WHERE x_param_name = 'SAFELINK_COURTESY_DEALER_ID');
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  benefits_pkg.sp_preactive_reserve_pin(
                                                         in_esn           => rec_get_esn.x_current_esn,
                                                         in_pin_part_num  => 'NTAPP6U001SL',
                                                         in_inv_bin_objid => n_inv_bin_objid, --CR54533
                                                         in_consumer      => 'SLCOURTESY',    --CR54533
                                                         out_soft_pin     => v_soft_pin,
                                                         out_smp_number   => v_smp_number,
                                                         out_err_num      => op_err_no,
                                                         out_err_msg      => op_err_msg --g_err_msg CR54533
                                                       );

               IF op_err_no IS NOT NULL THEN
                   /*CR54533 - Commented
                   g_request := 'LID='||rec_deenroll_request.lid;
                   g_err_msg := 'Current LID processing failed.. sqlcode : RP'||SQLCODE ||' sqlerrm: '||SUBSTR(sqlerrm,1, 250)||' op_err_no: '|| op_err_no ||' op_err_msg: '|| SUBSTR(op_err_msg,1, 250);
                   ins_job_err (TO_CHAR(v_job_run_objid), 'SAFELINK_DEENROLL', g_request, g_err_msg);*/
                   g_requestid := op_err_no;
                   raise exception_record_not_processed;
               END IF;

               --CR54533 - Start

               --Get brand for ESN
               c_org_id := sa.util_pkg.get_bus_org_id(rec_get_esn.x_current_esn);

               --Write a call trans record
               sa.convert_bo_to_sql_pkg.sp_create_call_trans( ip_esn          => rec_get_esn.x_current_esn,
                                                              ip_action_type  => '401',
                                                              ip_sourcesystem => 'BATCH',
                                                              ip_brand_name   => c_org_id,
                                                              ip_reason       => v_soft_pin,
                                                              ip_result       => 'Completed',
                                                              ip_ota_req_type => NULL,
                                                              ip_ota_type     => '402',
                                                              ip_total_units  => 0,
                                                              op_calltranobj  => v_call_trans_objid,
                                                              op_err_code     => op_err_no,
                                                              op_err_msg      => op_err_msg
                                                            );
               IF op_err_no != 0 THEN
                  g_requestid := op_err_no;
                  raise exception_record_not_processed;
               END IF;

               --CR54533 - End

               --
               -- Write the courtesy pin to history.
               --
               INSERT INTO sa.x_sl_hist
                                         (
                                          objid,
                                          lid,
                                          x_esn,
                                          x_event_dt,
                                          x_insert_dt,
                                          x_event_value,
                                          x_event_code,
                                          x_event_data,
                                          x_min,
                                          username,
                                          x_sourcesystem,
                                          x_code_number,
                                          x_src_table,
                                          x_src_objid,
                                          x_program_enrolled_id
                                         )
                                         VALUES
                                         (
                                          sa.seq_x_sl_hist.nextval,            --objid
                                          rec_deenroll_request.lid,            --lid
                                          rec_get_esn.x_current_esn,           --esn
                                          sysdate,                             --x_event_dt
                                          sysdate,                             --x_insert_dt
                                          v_smp_number,                        --x_event_value
                                          626,                                 --x_event_code
                                          NULL,                                --x_event_data
                                          NULL,                                --x_min
                                          'SYSTEM',                            --username
                                          rec_deenroll_request.data_source,    --x_sourcesystem
                                          0,                                   --x_code_number
                                          'XEROX_RESPONSE_LOG',                --x_src_table
                                          NULL,                                --x_src_objid
                                          NULL                                 --x_program_enrolled_id
                                         );

           END IF; -- End CR50086 Tim 5/22/2018

        ELSE
           g_requestid := op_err_no;
           raise exception_record_not_processed;
        END IF;
        COMMIT;
        EXCEPTION
           WHEN exception_record_not_processed THEN
              ROLLBACK;
              lv_records_not_processed := lv_records_not_processed + 1;
              g_request := 'LID='||rec_deenroll_request.lid;
              g_err_msg := lv_record_not_processed_reason || '. Current LID processing not completed.' ||' op_err_num: '|| op_err_no ||' op_err_string: '|| SUBSTR(op_err_msg,1, 500);
              ins_job_err (TO_CHAR(v_job_run_objid), 'SAFELINK_DEENROLL', g_request, g_err_msg);
              UPDATE xsu_vmbc_request xsu
              SET requestid = g_requestid
              ||'|'
              ||v_job_run_objid
              WHERE rowid = rec_deenroll_request.current_record_rowid;
              COMMIT;
           WHEN OTHERS THEN
              ROLLBACK;
              lv_records_not_processed := lv_records_not_processed + 1;
              ---log the current LID processing failed
              g_request := 'LID='||rec_deenroll_request.lid;
              g_err_msg := 'Current LID processing failed.. sqlcode : '||SQLCODE ||' sqlerrm: '||SUBSTR(sqlerrm,1, 250)||' op_err_no: '|| op_err_no ||' op_err_msg: '|| SUBSTR(op_err_msg,1, 250);
              ins_job_err (TO_CHAR(v_job_run_objid), 'SAFELINK_DEENROLL', g_request, g_err_msg);
              UPDATE xsu_vmbc_request xsu
              SET requestid = g_requestid
              ||'|'
              ||v_job_run_objid -- other error error = -1
              WHERE rowid = rec_deenroll_request.current_record_rowid;
             COMMIT;
      END; -- cur_deenroll_request
   END LOOP; --main cursor for loop cur_deenroll_request
   dbms_output.put_line('No. of rows processed: '||lv_records_processed);
   dbms_output.put_line('No. of rows failed to be processed: '||lv_records_not_processed);
   update_job_instance ( ip_job_run_objid => v_job_run_objid, ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status => 'SUCCESS', ip_status_code => '0', ip_sub_sourcesystem => 'SAFELINK' );
   dbms_output.put_line('********** END OF PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_DEENROLL_JOB **********');
   op_err_no := 0;
   op_err_msg := 'SUCCESS';
EXCEPTION
WHEN OTHERS THEN
   ROLLBACK;
   op_err_no := SQLCODE;
   op_err_msg := 'FAILED';
   g_err_msg := '' || ', No. of rows processed: '|| NVL(lv_records_processed ,0) || ', No. of rows failed: '|| NVL(lv_records_not_processed,0) ||', p_process_annual_verify_job Failed..ERR='|| SUBSTR(sqlerrm,1,500) ;
   ---log job error
   ins_job_err (TO_CHAR(v_job_run_objid), 'SAFELINK_DEENROLL', 'sqlcode: '||SQLCODE, g_err_msg);
   update_job_instance ( ip_job_run_objid => v_job_run_objid, ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status => 'FAILED', ip_status_code => '505', ip_sub_sourcesystem => 'SAFELINK' );
   dbms_output.put_line('********** EXCEPTION WHILE RUNNING PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_DEENROLL_JOB ********** ' || 'op_err_num='||op_err_no ||' g_err_msg: '||g_err_msg );
END p_process_deenroll_job;
PROCEDURE p_process_annual_verify_job(
 ip_process_days IN NUMBER DEFAULT 0,
 op_err_num OUT NUMBER,
 op_err_string OUT VARCHAR2 )
AS
 /*************************************************************************/
 /* Copyright 2015 Tracfone Wireless Inc. All rights reserved */
 /* NAME: p_process_annual_verify_job */
 /* PURPOSE: To update the records in Clarity */
 /* related to recordtype 'Verify' from VMBC */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- ----- ------------------------------------------*/
 /* 1.0 12/09/14 ASHISH RIJAL Initial Revision */
 /* */
 /************************************************************************/
 ld_next_exp_date DATE ;
 ln_duration NUMBER;
 lv_new_promo_code table_x_promotion.x_promo_code%TYPE;
 lv_records_processed pls_integer := 0;
 lv_records_not_processed pls_integer := 0;
 lv_record_not_processed_reason VARCHAR2(1000);
 v_job_run_objid x_job_run_details.objid%TYPE;
 ld_next_av_due_date DATE;--for CR35618
 exception_record_not_processed EXCEPTION;
 CURSOR cur_annualverify_request
 IS
 SELECT
 /*+ INDEX(XSU IND_XSUVMBC_REQ_BATCH_DT) */
 xsu.ROWID AS current_record_rowid ,
 xsu.*
 FROM xsu_vmbc_request xsu
 WHERE 1 = 1
 AND xsu.requesttype = 'Verify'
 AND xsu.requestid IS NULL
 AND xsu.batchdate > TRUNC(SYSDATE) - ip_process_days ;
 CURSOR cur_is_valid_lid (cu_lid xsu_vmbc_request.lid%TYPE)
 IS
 SELECT COUNT(1) cnt_valid_lid
 FROM x_sl_subs slsub,
 x_sl_currentvals slcur
 WHERE 1 = 1
 AND slsub.lid = cu_lid
 AND slsub.lid = slcur.lid;
 rec_is_valid_lid cur_is_valid_lid%rowtype;
 CURSOR cur_is_enrolled (cu_lid xsu_vmbc_request.lid%TYPE)
 IS
 SELECT tsp.objid table_site_part_objid,
 tsp.x_service_id x_esn,
 tsp.x_expire_dt x_expire_dt,
 pe.objid prg_enrol_objid,
 pe.pgm_enroll2web_user web_user_objid,
 pp.x_program_name x_program_name
 FROM x_sl_currentvals slcur,
 x_program_enrolled pe,
 table_site_part tsp,
 x_program_parameters pp
 WHERE 1 = 1
 AND slcur.lid = cu_lid
 AND pe.x_esn = slcur.x_current_esn
 AND tsp.x_service_id = slcur.x_current_esn
 AND pp.objid = pe.pgm_enroll2pgm_parameter
 AND pp.x_prog_class = 'LIFELINE'
 AND pe.x_enrollment_status = 'ENROLLED'
 AND tsp.part_status = 'Active';
 rec_is_enrolled cur_is_enrolled%rowtype;
 CURSOR cur_promo_code (cu_new_promo_code table_x_promotion.x_promo_code%TYPE)
 IS
 SELECT objid promo_code_objid
 FROM table_x_promotion
 WHERE 1 = 1
 AND x_promo_code = cu_new_promo_code;
 rec_promo_code cur_promo_code%rowtype;
BEGIN
 op_err_num := 0;
 op_err_string := 'SUCCESS';
 dbms_output.put_line('********** START OF PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_ANNUAL_VERIFY_JOB **********');
 -- Create new job id
 create_job_instance ( ip_job_name => 'SAFELINK_ANNUAL_VERIFY', ip_status => 'RUNNING', ip_job_run_mode => '0', ip_seq_name => 'X_JOB_RUN_DETAILS', ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status_code => NULL, ip_sub_sourcesystem => 'SAFELINK', op_job_run_objid => v_job_run_objid );
 --Get the next expiry date as next year + 1 month (grace period)
 ld_next_exp_date := last_day(add_months(TRUNC(SYSDATE - ip_process_days,'RRRR'),24));
 ld_next_av_due_date := last_day(add_months(TRUNC(SYSDATE - ip_process_days,'RRRR'),23));--for CR35618
 -- Get records from vmbc table with record type as 'Verify'
 FOR rec_annualverify_request IN cur_annualverify_request
 LOOP
 BEGIN
 -- Check if LID is valid or not
 OPEN cur_is_valid_lid(rec_annualverify_request.lid);
 FETCH cur_is_valid_lid INTO rec_is_valid_lid;
 -- If not a valid LID, skip the regular process and log the error
 IF NVL(rec_is_valid_lid.cnt_valid_lid, -1) <> 1 THEN
 CLOSE cur_is_valid_lid;
 g_requestid := '-2'; -- Business exception. Check the data to correct.
 lv_record_not_processed_reason := 'Error.... lid= '||rec_annualverify_request.lid|| ' is not a valid Lifeline';
 raise exception_record_not_processed;
 END IF;
 CLOSE cur_is_valid_lid;
 -- Check if ESN is enrolled or active and fetch the data
 OPEN cur_is_enrolled(rec_annualverify_request.lid);
 FETCH cur_is_enrolled INTO rec_is_enrolled;
 -- If ESN is not enrolled or not Active, skip the regular process and log the error
 IF cur_is_enrolled%notfound THEN
 CLOSE cur_is_enrolled;
 g_requestid := '-3'; -- Business exception. Check the data to correct.
 lv_record_not_processed_reason := 'Error.... lid= '||rec_annualverify_request.lid|| ' is not Enrolled in a program or not Active ESN';
 raise exception_record_not_processed;
 END IF;
 CLOSE cur_is_enrolled;
 -- If x_expire_dt is NULL for this ESN, skip the regular process and log the error
 IF rec_is_enrolled.x_expire_dt IS NULL THEN
 g_requestid := '-4'; -- Business exception. Check the data to correct.
 lv_record_not_processed_reason := 'Error.... Current Expire date is NULL for lid= '||rec_annualverify_request.lid||'. ';
 raise exception_record_not_processed;
 END IF;
 ln_duration:= ld_next_exp_date - TRUNC(rec_is_enrolled.x_expire_dt) ;
 -- If x_expire_dt is more than the next target date for this ESN, skip the regular process and log the info
 IF ln_duration < 0 THEN
 g_requestid := '-5'; -- Business exception. No need to proceed further.
 lv_record_not_processed_reason := 'Do not need to process further.... Current Expire date '||rec_is_enrolled.x_expire_dt||' is more than the targeted next expiry date '||ld_next_exp_date||' for lid= '||rec_annualverify_request.lid||'. ';
 raise exception_record_not_processed;
 -- If x_expire_dt is same as the next target date for this ESN, skip the regular process and log the info
 elsif ln_duration = 0 THEN
 g_requestid := '-6'; -- Business exception. No need to proceed further.
 lv_record_not_processed_reason := 'Do not need to process further.... Current Expire date '||rec_is_enrolled.x_expire_dt||' is equal to the targeted next expiry date '||ld_next_exp_date||' for lid= '||rec_annualverify_request.lid||' . ';
 raise exception_record_not_processed;
 elsif ln_duration <= 365 THEN
 lv_new_promo_code := 'SLRVFY'||ln_duration||'D';
 ELSE
 lv_new_promo_code := 'SLRVFY365D';
 END IF;
 --Get the promocode objid from master promo table
 OPEN cur_promo_code (lv_new_promo_code);
 FETCH cur_promo_code INTO rec_promo_code ;
 -- If promo code not found, skip the regular process and log the info
 IF cur_promo_code%rowcount = 0 THEN
 CLOSE cur_promo_code;
 g_requestid := '-7'; -- Business exception. Check data.
 lv_record_not_processed_reason := 'Error.... Too many records or no record found for X_promo_code=' || lv_new_promo_code ||'in TABLE_X_PROMO_CODE for lid= '||rec_annualverify_request.lid;
 raise exception_record_not_processed;
 END IF;
 CLOSE cur_promo_code;
 UPDATE table_part_inst
 SET warr_end_date = ld_next_exp_date
 WHERE part_serial_no = rec_is_enrolled.x_esn
 AND x_part_inst_status = '52';
 -- If record not found in table_part_inst for this ESN, skip the regular process and log the info
 IF SQL%rowcount = 0 THEN
 g_requestid := '-8'; -- Business exception. Check the data to correct.
 lv_record_not_processed_reason := 'Error.... Record is not found in table_part_inst table with x_esn = '||rec_is_enrolled.x_esn||' and Active for the lid: ' || rec_annualverify_request.lid|| ' in xsu_vmbc_request table.';
 raise exception_record_not_processed;
 END IF;
 UPDATE table_site_part
 SET x_expire_dt = ld_next_exp_date,
 warranty_date = ld_next_exp_date
 WHERE objid = rec_is_enrolled.table_site_part_objid;
 UPDATE x_sl_subs
 SET x_last_av_date = rec_annualverify_request.qualifydate,
 x_av_due_date = ld_next_av_due_date,---ld_next_exp_date, for CR35618
 x_av_verified_channel = rec_annualverify_request.channeltype
 WHERE lid = rec_annualverify_request.lid;
 UPDATE x_sl_subs_dtl
 SET x_hmodisclaimer = rec_annualverify_request.hmodisclaimer,
 x_ipaddress = rec_annualverify_request.ipaddress,
 x_status = rec_annualverify_request.status,
 x_lastmodified = rec_annualverify_request.lastmodified,
 x_disablemanualverification = rec_annualverify_request.disablemanualverification,
 x_channel_type = rec_annualverify_request.channeltype
 WHERE lid = rec_annualverify_request.lid;
 -- If record not found in x_sl_subs_dtl for this ESN, skip the regular process and log the info
 IF SQL%rowcount = 0 THEN
 g_requestid := '-9'; -- Business exception. Check the data to correct.
 lv_record_not_processed_reason := 'Error.... Record is not found in x_sl_subs_dtl table for the lid: ' || rec_annualverify_request.lid|| ' in xsu_vmbc_request table.';
 raise exception_record_not_processed;
 END IF;
 INSERT
 INTO sa.x_sl_hist
 (
 objid,
 lid,
 x_esn,
 x_event_dt,
 x_insert_dt,
 x_event_value,
 x_event_code,
 x_event_data,
 x_min,
 username,
 x_sourcesystem,
 x_code_number,
 x_src_table,
 x_src_objid,
 x_program_enrolled_id
 )
 VALUES
 (
 sa.seq_x_sl_hist.nextval,
 rec_annualverify_request.lid,
 rec_is_enrolled.x_esn,
 sysdate,
 sysdate,
 'Verification',
 623,
 NULL,
 NULL,
 USER,
 'BATCH',
 0,
 'table_site_part',
 rec_is_enrolled.table_site_part_objid,
 NULL
 );
 INSERT
 INTO x_program_trans
 (
 objid,
 x_enrollment_status,
 x_enroll_status_reason,
 x_trans_date,
 x_action_text,
 x_action_type,
 x_reason,
 x_sourcesystem,
 x_esn,
 x_update_user,
 pgm_tran2pgm_entrolled,
 pgm_trans2web_user,
 pgm_trans2site_part
 )
 VALUES
 (
 billing_seq ('X_PROGRAM_TRANS'),
 'ENROLLED',
 'Annual Verify completed successfully',
 SYSDATE,
 'Annual Verify',
 'ANNUAL_VERIFY',
 rec_is_enrolled.x_program_name,
 'BATCH',
 rec_is_enrolled.x_esn,
 USER,
 rec_is_enrolled.prg_enrol_objid,
 rec_is_enrolled.web_user_objid,
 rec_is_enrolled.table_site_part_objid
 );
 INSERT
 INTO table_x_pending_redemption
 (
 objid,
 pend_red2x_promotion,
 x_pend_red2site_part,
 x_pend_type,
 pend_redemption2esn,
 x_case_id,
 x_granted_from2x_call_trans,
 pend_red2prog_purch_hdr
 )
 VALUES
 (
 sa.seq ('x_pending_redemption'),
 rec_promo_code.promo_code_objid,
 rec_is_enrolled.table_site_part_objid,
 'FREE',
 rec_is_enrolled.x_esn,
 NULL,
 NULL,
 NULL
 );
 UPDATE xsu_vmbc_request xsu
 SET requestid = v_job_run_objid
 WHERE rowid = rec_annualverify_request.current_record_rowid;
 COMMIT;
 lv_records_processed := lv_records_processed + 1;
 EXCEPTION
 WHEN exception_record_not_processed THEN
 ROLLBACK;
 lv_records_not_processed := lv_records_not_processed + 1;
 g_request := 'LID='||rec_annualverify_request.lid;
 g_err_msg := lv_record_not_processed_reason || '. Current LID processing not completed.' ||' sqlerrm: '|| SUBSTR(dbms_utility.format_error_backtrace,1, 500);
 ins_job_err (TO_CHAR(v_job_run_objid), 'SAFELINK_ANNUAL_VERIFY', g_request, g_err_msg);
 UPDATE xsu_vmbc_request xsu
 SET requestid = g_requestid
 ||'|'
 ||v_job_run_objid
 WHERE rowid = rec_annualverify_request.current_record_rowid;
 COMMIT;
 WHEN OTHERS THEN
 ROLLBACK;
 lv_records_not_processed := lv_records_not_processed + 1;
 ---log the current LID processing failed
 g_request := 'LID='||rec_annualverify_request.lid;
 g_err_msg := 'Current LID processing failed.. sqlcode : '||SQLCODE ||' sqlerrm: '||sqlerrm;
 ins_job_err (TO_CHAR(v_job_run_objid), 'SAFELINK_ANNUAL_VERIFY', g_request, g_err_msg);
 UPDATE xsu_vmbc_request xsu
 SET requestid = g_requestid
 ||'|'
 ||v_job_run_objid -- other error error = -1
 WHERE rowid = rec_annualverify_request.current_record_rowid;
 COMMIT;
 END; -- cur_annualverify_request
 END LOOP; --main cursor FOR LOOP cur_annualverify_request
 dbms_output.put_line('No. of rows processed: '||lv_records_processed);
 dbms_output.put_line('No. of rows failed to be processed: '||lv_records_not_processed);
 update_job_instance ( ip_job_run_objid => v_job_run_objid, ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status => 'SUCCESS', ip_status_code => '0', ip_sub_sourcesystem => 'SAFELINK' );
 dbms_output.put_line('********** END OF PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_ANNUAL_VERIFY_JOB **********');
EXCEPTION
WHEN OTHERS THEN
 ROLLBACK;
 op_err_num := SQLCODE;
 op_err_string := 'FAILED';
 g_err_msg := '' || ', No. of rows processed: '|| NVL(lv_records_processed ,0) || ', No. of rows failed: '|| NVL(lv_records_not_processed,0) ||', p_process_annual_verify_job Failed..ERR='|| SUBSTR(sqlerrm,1,500) ;
 ---log job error
 ins_job_err (TO_CHAR(v_job_run_objid), 'SAFELINK_ANNUAL_VERIFY', 'sqlcode: '||SQLCODE, g_err_msg);
 update_job_instance ( ip_job_run_objid => v_job_run_objid, ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status => 'FAILED', ip_status_code => '505', ip_sub_sourcesystem => 'SAFELINK' );
 dbms_output.put_line('********** EXCEPTION WHILE RUNNING PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_ANNUAL_VERIFY_JOB ********** ' || 'op_err_num='||op_err_num ||' g_err_msg: '||g_err_msg );
END p_process_annual_verify_job;
PROCEDURE p_process_program_change_job(
 ip_process_days IN NUMBER DEFAULT 0,
 op_err_num OUT NUMBER,
 op_err_string OUT VARCHAR2 )
AS
 /************************************************************************/
 /* Copyright 2015 Tracfone Wireless Inc. All rights reserved */
 /* NAME: p_process_program_change_job */
 /* PURPOSE: To update the records in Clarity */
 /* related to recordtype 'ProgramChange' from VMBC */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- ----- ------------------------------------------*/
 /* 1.0 12/09/14 ASHISH RIJAL Initial Revision */
 /* */
 /************************************************************************/
 lv_records_processed pls_integer := 0;
 lv_records_not_processed pls_integer := 0;
 lv_record_not_processed_reason VARCHAR2(1000);
 v_job_run_objid x_job_run_details.objid%TYPE;
 exception_record_not_processed EXCEPTION;
 v_additional_days NUMBER;

 CURSOR cur_programchange_reqst
 IS
 SELECT xsu.ROWID AS current_record_rowid ,
 xsu.lid vmbc_lid ,
 'Lifeline - '
 ||XSU.state
 ||' - '
 ||NVL(XSU.PLAN, 1) vmbc_program_name ,
 xsu.haspromotionalplan haspromotionalplan ,
 xsu.ipaddress ipaddress ,
 xsu.status status ,
 xsu.lastmodified lastmodified,
 xsu.state
 FROM xsu_vmbc_request xsu
 WHERE 1 = 1
 AND xsu.requesttype = 'ProgramChange'
 AND xsu.batchdate > TRUNC(SYSDATE) - ip_process_days
 AND xsu.requestid IS NULL ;
 CURSOR cur_is_valid_lid (cu_lid xsu_vmbc_request.lid%TYPE)
 IS
 SELECT slcur.x_current_esn x_current_esn ,
 slsub.x_requested_plan subs_plan ,
 slsub.objid subs_objid
 --count(1) cnt_valid_lid
 FROM x_sl_subs slsub,
 x_sl_currentvals slcur
 WHERE 1 = 1
 AND slsub.lid = cu_lid
 AND slsub.lid = slcur.lid;
 rec_is_valid_lid cur_is_valid_lid%rowtype;
 CURSOR cur_get_program_dtl_vmbc (in_vmbc_program_name IN x_program_parameters.x_program_name%TYPE)
 IS
 SELECT *
 FROM x_program_parameters pp
 WHERE pp.x_program_name = in_vmbc_program_name
 AND x_prog_class = 'LIFELINE';
 rec_get_program_dtl_vmbc cur_get_program_dtl_vmbc%rowtype;


 CURSOR cur_old_new_plan(cu_lid xsu_vmbc_request.lid%TYPE)
 IS
 SELECT subs.x_requested_plan AS x_requested_plan,
 oldpp.objid AS old_pp_objid,
 oldpp.x_program_name AS old_x_program_name,
 newpp.objid AS new_pp_objid,
 newpp.x_program_name AS new_x_program_name,
 pe.objid AS pe_objid,
 newpp.x_promo_incl_min_at AS new_pp_units_promo,
 pe.pgm_enroll2site_part AS sp_objid,
 pe.pgm_enroll2part_inst AS pi_objid,
 subs.lid,
 pe.x_esn
 FROM x_sl_subs subs,
 x_program_parameters oldpp,
 x_program_parameters newpp,
 x_sl_currentvals val ,
 x_program_enrolled pe
 WHERE 1 = 1
 AND subs.lid = cu_lid
 AND oldpp.x_program_name = subs.x_requested_plan
 AND oldpp.x_prog_class = 'LIFELINE'
 AND newpp.x_prog_class = 'LIFELINE'
 AND newpp.x_program_name = rec_get_program_dtl_vmbc.x_program_name
 AND val.lid=subs.lid
 AND pe.x_enrollment_status = 'ENROLLED'
 AND pe.x_sourcesystem = 'VMBC'
 AND val.x_current_esn = pe.x_esn;
 rec_old_new_plan cur_old_new_plan%rowtype;

BEGIN
 dbms_output.put_line('********** START OF PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_PROGRAM_CHANGE_JOB **********');
 op_err_num := 0;
 op_err_string := 'SUCCESS';
 -- Create new job id
 create_job_instance ( ip_job_name => 'SAFELINK_PROGRAM_CHANGE', ip_status => 'RUNNING', ip_job_run_mode => '0', ip_seq_name => 'X_JOB_RUN_DETAILS', ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status_code => NULL, ip_sub_sourcesystem => 'SAFELINK', op_job_run_objid => v_job_run_objid );
 -- Get all the lid for request type 'ProgramChange'
 FOR rec_programchange_reqst IN cur_programchange_reqst
 LOOP
 BEGIN
 OPEN cur_is_valid_lid(rec_programchange_reqst.vmbc_lid);
 FETCH cur_is_valid_lid INTO rec_is_valid_lid;
 IF cur_is_valid_lid%NOTFOUND THEN
 CLOSE cur_is_valid_lid;
 g_requestid := '-10'; -- Business exception. Check the data to correct.
 lv_record_not_processed_reason := 'Error.... lid= '||rec_programchange_reqst.vmbc_lid|| ' is not a valid Lifeline';
 raise exception_record_not_processed;
 END IF;
 CLOSE cur_is_valid_lid;
 OPEN cur_get_program_dtl_vmbc(rec_programchange_reqst.vmbc_program_name);
 FETCH cur_get_program_dtl_vmbc INTO rec_get_program_dtl_vmbc;
 IF cur_get_program_dtl_vmbc%ROWCOUNT <> 1 THEN
 CLOSE cur_get_program_dtl_vmbc;
 g_requestid := '-11'; -- Business exception. Check the data to correct.
 lv_record_not_processed_reason := 'Error.... Too many records or no record found for the Program: '||rec_programchange_reqst.vmbc_program_name||' in x_program_parameter table for the lid:' || rec_programchange_reqst.vmbc_lid||'.';
 raise exception_record_not_processed;
 END IF;
 CLOSE cur_get_program_dtl_vmbc;

 --
 -- CR39910 State specific change logic.
 --
 BEGIN
 SELECT additional_days
 INTO v_additional_days
 FROM sa.SL_PLANCHANGE_CONFIG
 WHERE state_cd = rec_programchange_reqst.state
 AND old_plan = rec_is_valid_lid.subs_plan
 AND new_plan = rec_get_program_dtl_vmbc.x_program_name;

 EXCEPTION WHEN OTHERS THEN
 v_additional_days := 0;

 END;

 --
 -- CR39910 This logic needs to be executed only when
 -- From plan, to PLAN and state are matching as per the new configuration table (SL_PLANCHANGE_CONFIG)
 --

 IF v_additional_days > 0 THEN

 FOR rec_plan IN cur_old_new_plan(rec_programchange_reqst.vmbc_lid)
 LOOP

 UPDATE sa.x_program_enrolled
 SET pgm_enroll2pgm_parameter = rec_plan.new_pp_objid,
 x_update_stamp = SYSDATE,
 x_exp_date = NULL,
 x_wait_exp_date = NULL,
 x_next_delivery_date = LAST_DAY(TRUNC(SYSDATE)) + 1 -- first of next month.
 WHERE objid = rec_plan.pe_objid;

 INSERT INTO sa.x_sl_hist
 (
 objid,
 lid,
 x_esn,
 x_event_dt,
 x_insert_dt,
 x_event_value,
 x_event_code,
 x_event_data,
 x_min,
 username,
 x_sourcesystem,
 x_code_number,
 x_src_table,
 x_src_objid,
 x_program_enrolled_id
 )
 VALUES
 (
 sa.seq_x_sl_hist.nextval,
 rec_plan.lid,
 rec_plan.x_esn,
 sysdate,
 sysdate,
 rec_plan.NEW_x_program_NAME,
 805,
 NULL,
 NULL,
 'SA',
 'BATCH',
 0,
 'X_PROGRAM_ENROLLED',
 rec_plan.PE_OBJID,
 NULL
 );

 UPDATE sa.table_site_part
 SET x_expire_dt = CASE WHEN x_expire_dt > TRUNC(sysdate) + v_additional_days
 THEN x_expire_dt
 ELSE x_expire_dt + v_additional_days
 END,
 warranty_date = CASE WHEN warranty_date > TRUNC(sysdate) + v_additional_days
 THEN warranty_date
 ELSE warranty_date + v_additional_days
 END
 WHERE objid = rec_plan.sp_objid
 AND part_status = 'Active';

 UPDATE sa.table_part_inst
 SET warr_end_date = CASE WHEN warr_end_date > TRUNC(sysdate) + v_additional_days
 THEN warr_end_date
 ELSE warr_end_date + v_additional_days
 END
 WHERE part_serial_no = rec_is_valid_lid.x_current_esn
 AND x_part_inst_status = '52';


 -- Insert units into Pending redemption based on new plan
 IF (rec_plan.new_pp_units_promo is not null) then
 INSERT INTO sa.table_x_pending_redemption
 (objid,
 pend_red2x_promotion,
 x_pend_red2site_part,
 x_pend_type)
 VALUES (sa.seq('x_pending_redemption'),
 rec_plan.new_pp_units_promo,
 rec_plan.sp_objid,
 'BPDelivery');


 INSERT INTO x_program_gencode
 (objid,
 x_esn,
 x_insert_date,
 x_status)
 VALUES
 (sa.billing_seq('X_PROGRAM_GENCODE'),
 rec_plan.x_esn,
 SYSDATE,
 'INSERTED');

 END IF;

 END LOOP;



 END IF;
 --
 -- End CR39910 State specific change logic.
 --



 UPDATE x_sl_subs
 SET x_requested_plan = rec_get_program_dtl_vmbc.x_program_name
 WHERE lid = rec_programchange_reqst.vmbc_lid;
 UPDATE x_sl_subs_dtl
 SET x_haspromotionalplan = rec_programchange_reqst.haspromotionalplan,
 x_ipaddress = rec_programchange_reqst.ipaddress,
 x_status = rec_programchange_reqst.status,
 x_lastmodified = rec_programchange_reqst.lastmodified
 WHERE lid = rec_programchange_reqst.vmbc_lid;
 IF SQL%ROWCOUNT = 0 THEN
 g_requestid := '-12'; -- Business exception. Check the data to correct.
 lv_record_not_processed_reason := 'Error.... Record is not found in x_sl_subs_dtl table for the lid: ' || rec_programchange_reqst.vmbc_lid|| ' in xsu_vmbc_request table.';
 raise exception_record_not_processed;
 END IF;
 INSERT
 INTO sa.x_sl_hist
 (
 objid,
 lid,
 x_esn,
 x_event_dt,
 x_insert_dt,
 x_event_value,
 x_event_code,
 x_event_data,
 x_min,
 username,
 x_sourcesystem,
 x_code_number,
 x_src_table,
 x_src_objid,
 x_program_enrolled_id
 )
 VALUES
 (
 sa.seq_x_sl_hist.nextval,
 rec_programchange_reqst.vmbc_lid,
 rec_is_valid_lid.x_current_esn,
 sysdate,
 sysdate,
 rec_get_program_dtl_vmbc.x_program_name,
 619,
 NULL,
 NULL,
 USER,
 'BATCH',
 0,
 'x_sl_subs',
 rec_is_valid_lid.subs_objid,
 NULL
 );
 UPDATE xsu_vmbc_request xsu
 SET xsu.requestid = v_job_run_objid
 WHERE xsu.rowid = rec_programchange_reqst.current_record_rowid;
 COMMIT;
 lv_records_processed := lv_records_processed + 1;
 EXCEPTION
 WHEN exception_record_not_processed THEN
 ROLLBACK;
 lv_records_not_processed := lv_records_not_processed + 1;
 g_request := 'LID='||rec_programchange_reqst.vmbc_lid;
 g_err_msg := lv_record_not_processed_reason || '. Current LID processing failed.' ||' sqlerrm: '|| SUBSTR(dbms_utility.format_error_backtrace,1, 500);
 ins_job_err (TO_CHAR(v_job_run_objid), 'SAFELINK_PROGRAM_CHANGE', g_request, g_err_msg);
 UPDATE xsu_vmbc_request xsu
 SET xsu.requestid = g_requestid
 ||'|'
 ||v_job_run_objid
 WHERE xsu.rowid = rec_programchange_reqst.current_record_rowid;
 COMMIT;
 WHEN OTHERS THEN
 ROLLBACK;
 lv_records_not_processed := lv_records_not_processed + 1;
 ---log the current LID processing failed
 g_request := 'LID='||rec_programchange_reqst.vmbc_lid;
 g_err_msg := 'Current LID processing failed.. sqlcode : '||SQLCODE ||' sqlerrm: '||sqlerrm;
 ins_job_err (TO_CHAR(v_job_run_objid), 'SAFELINK_PROGRAM_CHANGE', g_request, g_err_msg);
 UPDATE xsu_vmbc_request xsu
 SET xsu.requestid = g_requestid
 ||'|'
 ||v_job_run_objid -- other error error = -1
 WHERE xsu.rowid = rec_programchange_reqst.current_record_rowid;
 COMMIT;
 END; -- cur_programchange_reqst
 END LOOP; --main for loop cursor cur_programchange_reqst
 dbms_output.put_line('No. of rows processed: '||lv_records_processed);
 dbms_output.put_line('No. of rows failed to be processed: '||lv_records_not_processed);
 update_job_instance ( ip_job_run_objid => v_job_run_objid, ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status => 'SUCCESS', ip_status_code => '0', ip_sub_sourcesystem => 'SAFELINK' );
 dbms_output.put_line('********** END OF PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_PROGRAM_CHANGE_JOB **********');
EXCEPTION
WHEN OTHERS THEN
 ROLLBACK;
 op_err_num := SQLCODE;
 op_err_string := 'FAILED';
 g_err_msg := '' || ', No. of rows processed: '|| NVL(lv_records_processed ,0) || ', No. of rows failed: '|| NVL(lv_records_not_processed,0) ||', p_process_plan_change_request Failed..ERR='|| SUBSTR(sqlerrm,1,500) ;
 ---log job error
 ins_job_err (TO_CHAR(v_job_run_objid), 'SAFELINK_PROGRAM_CHANGE', 'sqlcode: '||SQLCODE, g_err_msg);
 update_job_instance ( ip_job_run_objid => v_job_run_objid, ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status => 'FAILED', ip_status_code => '505', ip_sub_sourcesystem => 'SAFELINK' );
 dbms_output.put_line('********** EXCEPTION WHILE RUNNING PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_PROGRAM_CHANGE_JOB ********** ' || 'op_err_num='||op_err_num ||' g_err_msg: '||g_err_msg );
END p_process_program_change_job;
PROCEDURE p_process_plan_transfer_job(
 ip_process_days IN NUMBER DEFAULT 0,
 op_err_num OUT NUMBER,
 op_err_string OUT VARCHAR2 )
AS
 /************************************************************************/
 /* Copyright 2015 Tracfone Wireless Inc. All rights reserved */
 /* NAME: p_process_plan_transfer_job */
 /* PURPOSE: To update the records in x_program-enrolled */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- ----- ------------------------------------------*/
 /* 1.0 12/09/14 ASHISH RIJAL Initial Revision */
 /* */
 /************************************************************************/
 lv_records_processed pls_integer := 0;
 lv_records_not_processed pls_integer := 0;
 lv_record_not_processed_reason VARCHAR2(1000);
 v_job_run_objid x_job_run_details.objid%TYPE;
 ld_process_date DATE;
 l_device TABLE_X_PART_CLASS_VALUES.X_PARAM_VALUE%TYPE;
 l_error_number NUMBER;
 l_error_message VARCHAR2(300);
 l_sp_objid NUMBER;
 l_brand VARCHAR2(100);
 v_ser_site_flg varchar2(10);



 exception_record_not_processed EXCEPTION;
 CURSOR cur_plantransfer_reqst(cu_process_date DATE)
 IS
 SELECT xsu.ROWID AS current_record_rowid ,
 xsu.lid AS lid ,
 subs.x_requested_plan AS x_requested_plan ,
 pp.objid AS pp_objid ,
 pp.x_program_desc AS x_program_desc,
 xsu.batchdate AS batchdate,
 (SELECT x_units FROM table_x_promotion prom where prom.objid = pp.x_promo_incl_min_at) AS reqst_units
 FROM xsu_vmbc_request xsu,
 x_sl_subs subs,
 x_program_parameters pp
 WHERE 1 = 1
 AND xsu.requesttype = 'ProgramChange'
 AND xsu.batchdate > cu_process_date
 AND xsu.lid = subs.lid
 AND subs.x_requested_plan = 'Lifeline - '
 ||xsu.state
 ||' - '
 ||NVL(xsu.PLAN, 1)
 AND pp.x_program_name = subs.x_requested_plan
 AND pp.x_prog_class = 'LIFELINE'
 AND xsu.batchdate =
 (SELECT MAX(xsuin.batchdate)
 FROM xsu_vmbc_request xsuin
 WHERE 1 =1
 AND xsuin.lid = xsu.lid
 AND xsuin.requesttype = xsu.requesttype
 AND xsuin.batchdate >= xsu.batchdate
 AND xsuin.requestid = xsu.requestid
 AND (xsuin.requestid IS NOT NULL
 OR xsuin.requestid NOT LIKE '-%|%')
 );
 CURSOR cur_get_program_enroll_details (in_lid IN x_sl_subs.lid%TYPE, in_X_REQUESTED_PLAN x_sl_subs.X_REQUESTED_PLAN%TYPE )
 IS
 SELECT pe.ROWID AS current_record_rowid ,
 pe.objid AS current_pe_objid ,
 pe.x_esn AS x_esn ,
 pe.pgm_enroll2web_user AS web_user_objid ,
 pp.x_program_name AS prog_enroll_program_name ,
 pp.objid AS prog_enroll_program_objid ,
 tsp.objid AS site_part_objid,
 pp.prog_param2bus_org AS bus_org_objid,
 (SELECT x_units FROM table_x_promotion prom where prom.objid = pp.x_promo_incl_min_at) AS enrolled_units
 FROM x_sl_currentvals val ,
 x_program_enrolled pe ,
 x_program_parameters pp ,
 table_site_part tsp
 WHERE 1 =1
 AND val.lid = in_lid
 AND val.x_current_esn = pe.x_esn
 AND pp.objid = pe.pgm_enroll2pgm_parameter
 AND pp.x_prog_class = 'LIFELINE'
 AND pe.x_enrollment_status = 'ENROLLED'
 AND pp.x_program_name <> in_X_REQUESTED_PLAN
 AND tsp.x_service_id = pe.x_esn
 AND tsp.part_status = 'Active' ;
 rec_get_program_enroll_details cur_get_program_enroll_details%rowtype;
BEGIN
 dbms_output.put_line('********** START OF PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_PLAN_TRANSFER_JOB **********');
 op_err_num := 0;
 op_err_string := 'SUCCESS';
 -- Create new job id
 create_job_instance ( ip_job_name => 'SAFELINK_PLAN_TRANSFER', ip_status => 'RUNNING', ip_job_run_mode => '0', ip_seq_name => 'X_JOB_RUN_DETAILS', ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status_code => NULL, ip_sub_sourcesystem => 'SAFELINK', op_job_run_objid => v_job_run_objid );
 IF NVL(ip_process_days,0) <= 0 THEN
 ld_process_date := TRUNC(TRUNC(SYSDATE, 'MM') - 1, 'MM') + 24;
 ELSE
 ld_process_date := TRUNC(TRUNC(SYSDATE - ip_process_days, 'MM') - 1, 'MM') + 24;
 END IF;
 FOR rec_plantransfer_reqst IN cur_plantransfer_reqst(ld_process_date)
 LOOP
 BEGIN
 OPEN cur_get_program_enroll_details(rec_plantransfer_reqst.lid, rec_plantransfer_reqst.X_REQUESTED_PLAN);
 FETCH cur_get_program_enroll_details INTO rec_get_program_enroll_details;
 IF cur_get_program_enroll_details%found THEN
 INSERT
 INTO x_program_trans
 (
 objid,
 x_enrollment_status,
 x_enroll_status_reason,
 x_trans_date,
 x_action_text,
 x_action_type,
 x_reason,
 x_sourcesystem,
 x_esn,
 x_update_user,
 pgm_tran2pgm_entrolled,
 pgm_trans2web_user,
 pgm_trans2site_part
 )
 VALUES
 (
 billing_seq ('X_PROGRAM_TRANS'),
 'READYTOREENROLL',
 'SL Plan Transfer',
 SYSDATE-0.005/24,
 'DeEnrollment for PlanTransfer',
 'DE_ENROLL',
 'Due to SL Plan Transfer Request from '
 ||rec_get_program_enroll_details.prog_enroll_program_name
 ||' to '
 ||rec_plantransfer_reqst.X_REQUESTED_PLAN
 ||'. SL De-enrollment for Plan Transfer Request is done successfully.',
 'BATCH',
 rec_get_program_enroll_details.x_esn,
 USER,
 rec_get_program_enroll_details.current_pe_objid,
 rec_get_program_enroll_details.web_user_objid,
 rec_get_program_enroll_details.site_part_objid
 );
 UPDATE x_program_enrolled
 SET pgm_enroll2pgm_parameter = rec_plantransfer_reqst.pp_objid,
 x_update_stamp = SYSDATE
 WHERE objid = rec_get_program_enroll_details.current_pe_objid;

 --CR38927 SL SMARTPHONE UPGRADE
 BEGIN
 --sa.sp_get_esn_parameter_value(rec_get_program_enroll_details.x_esn, 'DEVICE_TYPE', 0, l_device, l_error_number, l_error_message);
 l_device:=get_device_type(rec_get_program_enroll_details.x_esn);
 BEGIN
 SELECT org_id
 INTO l_brand
 FROM table_bus_org
 WHERE objid = rec_get_program_enroll_details.bus_org_objid;
 EXCEPTION
 WHEN OTHERS THEN
 l_brand :=NULL;
 END;

 --CR47024 Start changed from units to service plan.
 v_ser_site_flg := 'N';

 BEGIN
 SELECT DISTINCT 'Y'
 INTO v_ser_site_flg
 FROM x_service_plan_site_part spsp
 WHERE spsp.table_site_part_id = rec_get_program_enroll_details.site_part_objid;
 EXCEPTION WHEN OTHERS THEN
 v_ser_site_flg := 'N';
 END;

 IF (l_device IN ('BYOP','SMARTPHONE') AND l_brand = 'TRACFONE')
 OR
 (l_device = 'FEATURE_PHONE' and v_ser_site_flg = 'Y') THEN

 BEGIN
 SELECT program_para2x_sp
 INTO l_sp_objid
 FROM mtm_sp_x_program_param
 WHERE x_sp2program_param = rec_plantransfer_reqst.pp_objid;

 EXCEPTION
 WHEN OTHERS THEN
 l_sp_objid := NULL;
 END;

--CR47024 End changed from units to service plan.

 IF l_sp_objid IS NOT NULL THEN
 UPDATE x_service_plan_site_part
 SET x_service_plan_id=l_sp_objid
 WHERE table_site_part_id=rec_get_program_enroll_details.site_part_objid;
 END IF;
 END IF;
 EXCEPTION
 WHEN OTHERS THEN
 sa.ota_util_pkg.err_log ( p_action => 'update x_service_plan_site_part Safelink program change',
 p_error_date => sysdate,
 p_key => rec_get_program_enroll_details.x_esn,
 p_program_name => 'p_process_plan_transfer_job',
 p_error_text => 'Error : '|| sqlcode||' Error Msg :'||substr(sqlerrm,1,500));
 END;
 --CR38927 SL SMARTPHONE UPGRADE

 IF rec_get_program_enroll_details.enrolled_units IN (68) AND rec_plantransfer_reqst.reqst_units IN (125, 350, 500) THEN
 --- DEACTIVATE ILD
 INSERT
 INTO x_program_gencode
 (
 objid,
 x_esn,
 x_insert_date,
 x_status,
 GENCODE2PROG_PURCH_HDR,
 x_ota_trans_id,
 SW_FLAG --CR29935
 )
 VALUES
 (
 (
 sa.SEQ_X_PROGRAM_GENCODE.NEXTVAL
 )
 ,
 rec_get_program_enroll_details.x_esn,
 LAST_DAY(SYSDATE)+1 , --MONTH END SYSDATE
 'SW_INSERTED', --VYCHECK CALL VASU
 sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL, --VYCHECK CALL VASU
 256, -- CALL VASU 256
 'SW_ILD_D' --SW ILD DE ENROLL
 );

 ELSIF rec_get_program_enroll_details.enrolled_units IN (125, 350, 500) AND rec_plantransfer_reqst.reqst_units IN (68) THEN
 --- ACTIVATE ILD
 INSERT
 INTO x_program_gencode
 (
 objid,
 x_esn,
 x_insert_date,
 x_status,
 GENCODE2PROG_PURCH_HDR,
 x_ota_trans_id,
 SW_FLAG --CR29935
 )
 VALUES
 (
 (
 sa.SEQ_X_PROGRAM_GENCODE.NEXTVAL
 )
 ,
 rec_get_program_enroll_details.x_esn,
 LAST_DAY(SYSDATE)+1 , --MONTH END SYSDATE
 'SW_INSERTED', --VYCHECK CALL VASU
 sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL, --VYCHECK CALL VASU
 256, -- CALL VASU 256
 'SW_ILD_A' --SW ILD DE ENROLL
 );

 END IF;

 --CR38927 SL SMARTPHONE UPGRADE
 INSERT
 INTO x_program_trans
 (
 objid,
 x_enrollment_status,
 x_enroll_status_reason,
 x_trans_date,
 x_action_text,
 x_action_type,
 x_reason,
 x_sourcesystem,
 x_esn,
 x_update_user,
 pgm_tran2pgm_entrolled,
 pgm_trans2web_user,
 pgm_trans2site_part
 )
 VALUES
 (
 billing_seq ('X_PROGRAM_TRANS'),
 'ENROLLED',
 'SL Plan Transfer',
 SYSDATE,
 'SL Plan Transfer',
 'TRANSFER',
 'Due to SL Program Change Request from '
 ||rec_get_program_enroll_details.prog_enroll_program_name
 ||' to '
 ||rec_plantransfer_reqst.X_REQUESTED_PLAN
 ||'. SL Program Change Requested is transferred successfully.',
 'BATCH',
 rec_get_program_enroll_details.x_esn,
 USER,
 rec_get_program_enroll_details.current_pe_objid,
 rec_get_program_enroll_details.web_user_objid,
 rec_get_program_enroll_details.site_part_objid
 );
 INSERT
 INTO x_billing_log
 (
 objid,
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
 billing_log2web_user
 )
 VALUES
 (
 billing_seq ('X_BILLING_LOG'),
 'Program',
 'Program Enrolled',
 SYSDATE,
 'Successfully enrolled in '
 || rec_plantransfer_reqst.X_REQUESTED_PLAN,
 rec_plantransfer_reqst.X_PROGRAM_DESC,
 rec_plantransfer_reqst.X_REQUESTED_PLAN,
 billing_getnickname (rec_get_program_enroll_details.x_esn),
 rec_get_program_enroll_details.x_esn,
 NULL,
 NULL,
 'BATCH',
 rec_get_program_enroll_details.web_user_objid
 );
 INSERT
 INTO sa.x_sl_hist
 (
 objid,
 lid,
 x_esn,
 x_event_dt,
 x_insert_dt,
 x_event_value,
 x_event_code,
 x_event_data,
 x_min,
 username,
 x_sourcesystem,
 x_code_number,
 x_src_table,
 x_src_objid,
 x_program_enrolled_id
 )
 VALUES
 (
 sa.seq_x_sl_hist.nextval,
 rec_plantransfer_reqst.lid,
 rec_get_program_enroll_details.x_esn,
 sysdate,
 sysdate,
 rec_plantransfer_reqst.X_REQUESTED_PLAN,
 805,
 NULL,
 NULL,
 USER,
 'BATCH',
 0,
 'x_program_enrolled',
 rec_get_program_enroll_details.current_pe_objid,
 NULL
 );
 lv_records_processed := lv_records_processed + 1;
 END IF; --if cur_get_program_enroll_details%found then
 CLOSE cur_get_program_enroll_details;
 COMMIT;
 EXCEPTION
 WHEN OTHERS THEN
 ROLLBACK;
 CLOSE cur_get_program_enroll_details;
 lv_records_not_processed := lv_records_not_processed + 1;
 ---log the current LID processing failed
 g_request := 'LID='||rec_plantransfer_reqst.lid;
 g_err_msg := 'Current LID processing failed.. sqlcode : '||SQLCODE ||' sqlerrm: '||sqlerrm;
 ins_job_err (TO_CHAR(v_job_run_objid), 'SAFELINK_PLAN_TRANSFER', g_request, g_err_msg);
 END; -- cur_plantransfer_reqst
 END LOOP; --main cursor cur_plantransfer_reqst
 dbms_output.put_line('No. of rows processed: '||lv_records_processed);
 dbms_output.put_line('No. of rows failed to be processed: '||lv_records_not_processed);
 update_job_instance ( ip_job_run_objid => v_job_run_objid, ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status => 'SUCCESS', ip_status_code => '0', ip_sub_sourcesystem => 'SAFELINK' );
 dbms_output.put_line('********** END OF PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_PLAN_TRANSFER_JOB **********');
EXCEPTION
WHEN OTHERS THEN
 ROLLBACK;
 op_err_num := SQLCODE;
 op_err_string := 'FAILED';
 g_err_msg := '' || ', No. of rows processed: '|| NVL(lv_records_processed ,0) || ', No. of rows failed: '|| NVL(lv_records_not_processed,0) ||', p_process_plan_change_request Failed..ERR='|| SUBSTR(sqlerrm,1,500) ;
 ---log job error
 ins_job_err (TO_CHAR(v_job_run_objid), 'SAFELINK_PLAN_TRANSFER', 'sqlcode: '||SQLCODE, g_err_msg);
 update_job_instance ( ip_job_run_objid => v_job_run_objid, ip_owner_name => 'BATCH_PROC', ip_reason => 'Autosys', ip_status => 'FAILED', ip_status_code => '505', ip_sub_sourcesystem => 'SAFELINK' );
 dbms_output.put_line('********** EXCEPTION WHILE RUNNING PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_PLAN_TRANSFER_JOB ********** ' || 'op_err_num='||op_err_num ||' g_err_msg: '||g_err_msg );
END p_process_plan_transfer_job;
PROCEDURE p_program_transfer
 (
 p_web_objid IN table_web_user.objid%TYPE, -- WebUser ObjID
 p_s_esn IN x_program_enrolled.x_esn%TYPE, -- ESN from which programs need to be transferred.
 p_t_esn IN x_program_enrolled.x_esn%TYPE, -- ESN to which the programs need to be transferred to.
 p_pe_objid IN x_program_enrolled.objid%TYPE,
 p_lid IN x_sl_subs.lid%TYPE,
 p_from_pgm_objid IN x_program_parameters.objid%TYPE,
 op_result out NUMBER
 ,op_msg out VARCHAR2
 )
IS

 l_device_from table_x_part_class_values.x_param_value%TYPE;
 l_device_to table_x_part_class_values.x_param_value%TYPE;
 l_sl_subs_objid x_sl_subs.objid%TYPE;

 /*CURSOR org_id_curs
 IS
 SELECT
 bo.org_id
 FROM table_part_num prt_num,
 table_mod_level ml,
 table_part_inst pi,
 table_bus_org bo
 WHERE 1 =1
 AND prt_num.objid = ml.part_info2part_num
 AND pi.n_part_inst2part_mod = ml.objid
 AND pi.x_domain = 'PHONES'
 AND prt_num.part_num2bus_org =bo.objid
 AND pi.part_serial_no = p_s_esn;
 org_id_rec org_id_curs%ROWTYPE;*/

CURSOR get_min
 IS
 SELECT x_min,objid
 FROM table_site_part
 WHERE x_service_id =p_t_esn
 AND part_status ='Active';
 rec_get_min get_min%ROWTYPE;

 CURSOR pgm_transfer(c_from_pgm_objid number)
 IS
 select upc.to_pgm_objid pgm_change_objid, from_pp.x_program_name current_pgm_name, to_pp.x_program_name pgm_change_name,from_pp.prog_param2bus_org
 from x_sl_upgrade_program_config upc, x_program_parameters from_pp, x_program_parameters to_pp
 where upc.from_pgm_objid = c_from_pgm_objid
 AND upc.from_pgm_objid <> upc.to_pgm_objid
 and from_pp.objid = upc.from_pgm_objid
 and to_pp.objid = upc.to_pgm_objid;

BEGIN

 --sa.sp_get_esn_parameter_value(p_s_esn, 'DEVICE_TYPE', 0, l_device_from, op_result, op_msg);
 --sa.sp_get_esn_parameter_value(p_t_esn, 'DEVICE_TYPE', 0, l_device_to, op_result, op_msg);
		--CR38927 SL UPGRADE
		l_device_from:=get_device_type(p_s_esn);
		l_device_to:=get_device_type(p_t_esn);
 /*OPEN org_id_curs ;
 FETCH org_id_curs INTO org_id_rec;

 IF org_id_curs%FOUND THEN
 CLOSE org_id_curs;*/

 IF (l_device_from ='FEATURE_PHONE' AND l_device_to IN ('BYOP','SMARTPHONE')) THEN
 OPEN get_min;
 FETCH get_min INTO rec_get_min;
 CLOSE get_min;

 FOR xrec IN pgm_transfer (p_from_pgm_objid)
 LOOP
 IF xrec.prog_param2bus_org = 268438257 THEN --for tracfone brand
 INSERT
 INTO x_program_trans
 (
 objid,
 x_enrollment_status,
 x_enroll_status_reason,
 x_trans_date,
 x_action_text,
 x_action_type,
 x_reason,
 x_sourcesystem,
 x_esn,
 x_update_user,
 pgm_tran2pgm_entrolled,
 pgm_trans2web_user,
 pgm_trans2site_part
 )
 VALUES
 (
 billing_seq ('X_PROGRAM_TRANS'),
 'READYTOREENROLL',
 'SL Plan Transfer',
 SYSDATE,
 'DeEnrollment for PlanTransfer',
 'DE_ENROLL',
 'Due to SL BYOP/SMARTPHONE Upgrade'
 ||xrec.current_pgm_name
 ||' to '
 ||xrec.pgm_change_name
 ||'. SL De-enrollment for Plan Transfer Request is done successfully.',
 'BATCH',
 p_t_esn,
 USER,
 p_pe_objid,
 p_web_objid,
 rec_get_min.objid
 );

 UPDATE x_program_enrolled
 SET pgm_enroll2pgm_parameter = xrec.pgm_change_objid,
 x_update_stamp = SYSDATE
 WHERE objid = p_pe_objid;

 INSERT
 INTO x_program_trans
 (
 objid,
 x_enrollment_status,
 x_enroll_status_reason,
 x_trans_date,
 x_action_text,
 x_action_type,
 x_reason,
 x_sourcesystem,
 x_esn,
 x_update_user,
 pgm_tran2pgm_entrolled,
 pgm_trans2web_user,
 pgm_trans2site_part
 )
 VALUES
 (
 billing_seq ('X_PROGRAM_TRANS'),
 'ENROLLED',
 'SL Plan Transfer',
 SYSDATE,
 'SL Plan Transfer',
 'TRANSFER',
 'Due to SL Program Change from BYOP/SMARTPHONE upgrade '
 ||xrec.current_pgm_name
 ||' to '
 ||xrec.pgm_change_name
 ||'. SL Upgrade Program Change Requested is transferred successfully.',
 'BATCH',
 p_t_esn,
 USER,
 p_pe_objid,
 p_web_objid,
 rec_get_min.objid
 );



 INSERT
 INTO sa.x_sl_hist
 (
 objid,
 lid,
 x_esn,
 x_event_dt,
 x_insert_dt,
 x_event_value,
 x_event_code,
 x_event_data,
 x_min,
 username,
 x_sourcesystem,
 x_code_number,
 x_src_table,
 x_src_objid,
 x_program_enrolled_id
 )
 VALUES
 (
 sa.seq_x_sl_hist.nextval,
 p_lid,
 p_t_esn,
 sysdate,
 sysdate,
 xrec.pgm_change_name,
 805,
 NULL,
 NULL,
 USER,
 'BATCH',
 0,
 'x_program_enrolled',
 p_pe_objid,
 NULL
 );

 UPDATE x_sl_subs
 SET x_requested_plan = xrec.pgm_change_name
 WHERE lid = p_lid
 RETURNING objid INTO l_sl_subs_objid;

 INSERT
 INTO sa.x_sl_hist
 (
 objid,
 lid,
 x_esn,
 x_event_dt,
 x_insert_dt,
 x_event_value,
 x_event_code,
 x_event_data,
 x_min,
 username,
 x_sourcesystem,
 x_code_number,
 x_src_table,
 x_src_objid,
 x_program_enrolled_id
 )
 VALUES
 (
 sa.seq_x_sl_hist.nextval,
 p_lid,
 p_t_esn,
 sysdate,
 sysdate,
 xrec.pgm_change_name,
 619,
 NULL,
 NULL,
 USER,
 'BATCH',
 0,
 'x_sl_subs',
 l_sl_subs_objid,
 NULL
 );

 END IF;
 END LOOP;
 -- CLOSE get_min;
 END IF;

 --END IF; --IF org_id_curs%FOUND THEN
 --close org_id_curs;
END p_program_transfer;
--
-- CR43878 changes starts..
PROCEDURE p_x_sl_subs_import
 ( ip_process_days IN VARCHAR2,
 o_err_no OUT NUMBER,
 o_err_msg OUT VARCHAR2 )
AS
 --
 CURSOR c1
 IS
 SELECT /*+ INDEX(XSU IND_XSUVMBC_REQ_BATCH_DT) */
 XSU.*
 FROM xsu_vmbc_request xsu
 WHERE 1 = 1
 AND xsu.batchdate > TRUNC(SYSDATE) - ip_process_days
 AND xsu.requesttype = 'Enroll'
 AND XSU.ENROLLREQUEST = 'X'
 AND NOT EXISTS
 (SELECT 1
 FROM x_sl_subs sl
 WHERE sl.lid = xsu.lid)
 AND NOT EXISTS
 (SELECT 1
 FROM x_sl_currentvals sl
 WHERE sl.lid = xsu.lid
 AND sl.x_current_esn = xsu.esn);
 /*AND NOT EXISTS
 (SELECT 1
 FROM x_sl_currentvals sl
 WHERE sl.x_current_esn = xsu.esn);*/
 --
 counter NUMBER := 0;
 DDATE DATE;
 lv_records_not_processed NUMBER := 0;
 lv_record_not_processed_reason VARCHAR2(1000);
 --
BEGIN
 DBMS_OUTPUT.PUT_LINE ('Begin of p_x_manual_sl_subs_import .. '|| TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS'));
 --
 FOR r1 IN c1
 LOOP
 SELECT TRUNC (SYSDATE) + 30 INTO DDATE FROM DUAL;
 --
 BEGIN
 INSERT INTO X_SL_SUBS (OBJID,
 LID,
 FULL_NAME,
 ADDRESS_1,
 ADDRESS_2,
 CITY,
 STATE,
 ZIP,
 ZIP2,
 COUNTRY,
 E_MAIL,
 X_HOMENUMBER,
 X_ALLOW_PRERECORDED,
 X_EMAIL_PREF,
 SL_SUBS2TABLE_CONTACT,
 SL_SUBS2WEB_USER,
 X_REQUESTED_PLAN,
 X_SHP_ADDRESS,
 X_SHP_ADDRESS2,
 X_SHP_CITY,
 X_SHP_STATE,
 X_SHP_ZIP,
 X_QUALIFY_DATE,
 X_DEVICE_TYPE,
 X_DATA_SOURCE,
 X_PROMOTION,
 X_PROMOCODE,
 X_CAMPAIGN,
 X_EXTERNAL_ACCOUNT)
 VALUES (sa.SEQ_X_SL_SUBS.NEXTVAL,
 r1.lid,
 r1.name,
 r1.address,
 r1.address2,
 r1.city,
 r1.state,
 r1.zip,
 r1.zip2,
 r1.country,
 r1.email,
 r1.homenumber,
 r1.allowprerecorded,
 r1.emailpref,
 NULL,
 NULL,
 'Lifeline - ' || r1.state || ' - ' || r1.plan,
 r1.x_shp_address,
 r1.x_shp_address2,
 r1.x_shp_city,
 r1.x_shp_state,
 r1.x_shp_zip,
 TO_DATE (r1.qualifydate, 'YYYY-MM-DD'),
 r1.DEVICE_TYPE,
 r1.data_source,
 R1.X_PROMOTION,
 R1.X_PROMOCODE,
 R1.X_CAMPAIGN,
 R1.EXTERNAL_ACCOUNT);
 --
 INSERT INTO X_SL_SUBS_DTL (LID,
 X_ADDRESSISCOMMERCIAL,
 X_ADDRESSISDUPLICATED,
 X_ADDRESSISINVALID,
 X_ADDRESSISTEMPORARY,
 X_ADL,
 X_USACFORM,
 X_PERSONID,
 X_LASTMODIFIED,
 X_QUALIFY_TYPE,
 X_QUALIFY_PROGRAMS,
 X_CHANNEL_TYPE,
 X_LANGUAGE)
 VALUES (r1.lid,
 r1.addressiscommercial,
 r1.addressisduplicated,
 r1.addressisinvalid,
 r1.addressistemporary,
 r1.adl,
 r1.usacform,
 r1.personid,
 r1.lastmodified,
 r1.qualifytype,
 r1.qualifyprograms,
 r1.CHANNELTYPE,
 r1.registrationlanguage);
 --
 UPDATE X_SL_CURRENTVALS
 SET x_current_esn = NVL (r1.esn, '-1'),
 X_CURRENT_ACTIVE = 'Y',
 X_CURRENT_ENROLLED = 'Y',
 X_CURRENT_ACTIVE_DATE =
 (SELECT MAX (SP.install_date)
 FROM table_site_part sp
 WHERE sp.x_service_id = r1.esn),
 X_CURRENT_ENROLLED_DATE =
 (SELECT MAX (SP.install_date)
 FROM table_site_part sp
 WHERE sp.x_service_id = r1.esn),
 X_CURRENT_SHIPPED = 'Y',
 X_CURRENT_PGM_START_DATE = TO_DATE (r1.qualifydate, 'YYYY-MM-DD'),
 X_DEENROLL_REASON = 'ESN already enrolled.'
 WHERE lid = r1.lid;
 --
 /*
 INSERT INTO X_SL_CURRENTVALS (OBJID,
 LID,
 X_CURRENT_ESN,
 X_CURRENT_ACTIVE,
 X_CURRENT_ENROLLED,
 X_CURRENT_ACTIVE_DATE,
 X_CURRENT_ENROLLED_DATE,
 X_CURRENT_SHIPPED,
 X_CURRENT_PGM_START_DATE,
 X_CURRENT_PE_ID,
 X_DEENROLL_REASON)
 VALUES (SA.SEQ_X_SL_CURRENTVALS.NEXTVAL,
 r1.lid,
 r1.esn,
 'Y',
 'Y',
 (SELECT MAX (SP.install_date)
 FROM table_site_part sp
 WHERE sp.x_service_id = r1.esn),
 (SELECT MAX (SP.install_date)
 FROM table_site_part sp
 WHERE sp.x_service_id = r1.esn),
 'Y',
 TO_DATE (r1.qualifydate, 'YYYY-MM-DD'),
 (SELECT MAX (pe.objid)
 FROM x_program_enrolled pe
 WHERE pe.x_esn = r1.esn),
 'ESN already enrolled.');

 COMMIT;
 */
 --
 INSERT INTO X_SL_HIST (OBJID,
 LID,
 X_ESN,
 X_EVENT_DT,
 X_INSERT_DT,
 X_EVENT_VALUE,
 X_EVENT_CODE,
 X_EVENT_DATA,
 USERNAME,
 X_SOURCESYSTEM,
 X_CODE_NUMBER)
 VALUES (sa.SEQ_X_SL_HIST.NEXTVAL,
 r1.lid,
 r1.esn,
 SYSDATE,
 SYSDATE,
 'Activation Attempt',
 '602',
 NULL,
 'sa',
 'WEB',
 '0');
 --
 INSERT INTO X_SL_HIST (OBJID,
 LID,
 X_ESN,
 X_EVENT_DT,
 X_INSERT_DT,
 X_EVENT_VALUE,
 X_EVENT_CODE,
 X_EVENT_DATA,
 USERNAME,
 X_SOURCESYSTEM,
 X_CODE_NUMBER)
 VALUES (sa.SEQ_X_SL_HIST.NEXTVAL,
 r1.lid,
 r1.esn,
 SYSDATE,
 SYSDATE,
 NULL,
 '615',
 NULL,
 'VMBC',
 'VMBC',
 '0');
 --
 INSERT INTO X_SL_HIST (OBJID,
 LID,
 X_ESN,
 X_EVENT_DT,
 X_INSERT_DT,
 X_EVENT_VALUE,
 X_EVENT_CODE,
 X_EVENT_DATA,
 USERNAME,
 X_SOURCESYSTEM,
 X_CODE_NUMBER)
 VALUES (sa.SEQ_X_SL_HIST.NEXTVAL,
 r1.lid,
 r1.esn,
 SYSDATE,
 SYSDATE,
 'Enrollment of Handset',
 '700',
 'ESN already enrolled.',
 'sa',
 'WEB',
 '0');
 --
 UPDATE TABLE_SITE_PART
 SET X_EXPIRE_DT = DDATE, WARRANTY_DATE = DDATE
 WHERE X_SERVICE_ID = R1.ESN AND PART_STATUS = 'Active';
 --
 UPDATE TABLE_PART_INST
 SET WARR_END_dATE = DDATE
 WHERE PART_SERIAL_NO = R1.ESN AND X_DOMAIN = 'PHONES';
 --
 counter := counter + 1;
 -- DBMS_OUTPUT.PUT_LINE (counter || '. lid .. ' || r1.lid);
 COMMIT;
 --
 EXCEPTION
 WHEN OTHERS THEN
 ROLLBACK;
 o_err_no := SQLCODE;
 o_err_msg := 'FAILED';
 lv_records_not_processed := lv_records_not_processed + 1;
 g_request := 'LID='||r1.lid;
 g_err_msg := lv_record_not_processed_reason || '. Current LID not loaded into x_sl_sub' ||' op_err_num: '|| o_err_no ||' op_err_string: '|| SUBSTR(o_err_msg,1, 500);
 --
 ins_job_err (TO_CHAR(g_job_run_objid), 'SL_BG_ENROLL_X_SL_SUB', g_request, g_err_msg);
 END;
 END LOOP;
 --
 o_err_no := 0;
 o_err_msg := 'SUCCESS';
 --
 DBMS_OUTPUT.PUT_LINE ('counter .. ' || counter);
 DBMS_OUTPUT.PUT_LINE ('End of p_x_manual_sl_subs_import insert .. '|| TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS'));
 --
END p_x_sl_subs_import;
--
PROCEDURE p_enroll_transfer_job( i_esn IN VARCHAR2 ,
 i_lid IN VARCHAR2 ,
 i_state IN VARCHAR2 DEFAULT NULL,
 i_enroll_pgm_name IN VARCHAR2 ,
 o_err_no OUT NUMBER ,
 o_err_msg OUT VARCHAR2 ) AS
 CURSOR c2 IS
 SELECT pe.objid,
 pe.pgm_enroll2web_user,
 pe.pgm_enroll2site_part,
 pe.x_next_delivery_date,
 pe.pgm_enroll2pgm_parameter
 FROM x_program_enrolled pe
 WHERE pe.x_sourcesystem = 'BUDGET'
 AND x_enrollment_status = 'ENROLLED'
 AND pe.x_esn = i_esn;
 r2 c2%ROWTYPE;
 --
 CURSOR c3 IS
 SELECT *
 FROM x_program_parameters
 WHERE x_program_name = i_enroll_pgm_name;
 r3 c3%ROWTYPE;
 --
 l_enroll_seq NUMBER;
 l_purch_hdr_seq NUMBER;
 l_purch_hdr_dtl_seq NUMBER;
 l_program_trans_seq NUMBER;
 l_web_user_id NUMBER;
 l_contact_id NUMBER;
 l_pi_id NUMBER;
 l_sp_id NUMBER;
 counter NUMBER:=0;
 en_counter NUMBER:=0;
 deen_counter NUMBER:=0;
 lv_records_not_processed NUMBER := 0;
 lv_record_not_processed_reason VARCHAR2(1000);
 --
 c customer_type := customer_type();
 n_monfee_part_num NUMBER;
 c_program_param_name VARCHAR2(40);
 n_promo_incl_min_at NUMBER;
 n_retail_price NUMBER;
 n_units NUMBER;
 c_charge_frq_code VARCHAR2(15);
 d_next_delivery_date DATE;
 --
BEGIN
 --
 DBMS_OUTPUT.PUT_LINE ('Begin of p_enroll_transfer_job ... ' || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
 --
 l_web_user_id := sa.seq ('web_user');
 l_enroll_seq := sa.billing_seq ('X_PROGRAM_ENROLLED');
 l_purch_hdr_seq := sa.billing_seq ('X_PROGRAM_PURCH_HDR');
 l_purch_hdr_dtl_seq := sa.billing_seq ('X_PROGRAM_PURCH_DTL');
 l_program_trans_seq := sa.billing_seq ('X_PROGRAM_TRANS');

 --
 BEGIN
 SELECT objid,
 x_part_inst2contact,
 x_part_inst2site_part
 INTO l_pi_id, l_contact_id, l_sp_id
 FROM table_part_inst
 WHERE part_serial_no = i_esn
 AND x_part_inst_status = '52';
 EXCEPTION
 WHEN no_data_found THEN
 NULL;
 WHEN others THEN
 NULL;
 END;
 --

 -- get the brand objid
 c.bus_org_objid := c.get_bus_org_objid ( i_esn => i_esn );

 OPEN c2;
 FETCH c2 INTO r2;
 IF c2%FOUND THEN
 UPDATE X_PROGRAM_ENROLLED
 SET X_ENROLLMENT_STATUS = 'READYTOREENROLL',
 X_NEXT_DELIVERY_DATE = NULL,
 X_UPDATE_STAMP = SYSDATE
 WHERE OBJID = r2.OBJID;
 --
 deen_counter := deen_counter + SQL%ROWCOUNT;

 --
 -- get attributes from program parameters
 IF r2.pgm_enroll2pgm_parameter IS NOT NULL THEN
 BEGIN
 SELECT prog_param2prtnum_monfee,
 x_program_name,
 x_promo_incl_min_at,
 NVL(x_charge_frq_code,'0')
 INTO n_monfee_part_num,
 c_program_param_name,
 n_promo_incl_min_at,
 c_charge_frq_code
 FROM x_program_parameters
 WHERE objid = r2.pgm_enroll2pgm_parameter;
 EXCEPTION
 WHEN others THEN
 NULL;
 END;
 END IF;

 -- get the units from promotion
 IF n_promo_incl_min_at IS NOT NULL THEN
 BEGIN
 SELECT NVL(x_units,0)
 INTO n_units
 FROM table_x_promotion
 where objid = n_promo_incl_min_at; -- x_program_parameters.x_promo_incl_min_at
 EXCEPTION
 WHEN others THEN
 NULL;
 END;
 END IF;

 --
 INSERT INTO x_program_trans (objid,
 x_enrollment_status,
 x_enroll_status_reason,
 x_trans_date,
 x_action_text,
 x_action_type,
 x_reason,
 x_sourcesystem,
 x_esn,
 x_update_user,
 pgm_tran2pgm_entrolled,
 pgm_trans2web_user,
 pgm_trans2site_part)
 VALUES (l_program_trans_seq,
 'DEENROLLED',
 'web2',
 SYSDATE,
 'Voluntary DeEnrollment',
 'DE_ENROLL',
 c_program_param_name || ' READY TO REENROLL', -- CR43878: 'Lifeline - BG - UNL1 READY TO REENROLL',
 'BUDGET',
 i_esn,
 'web2',
 r2.objid,
 r2.pgm_enroll2web_user,
 r2.pgm_enroll2site_part);
 --
 END IF;
 close c2;
 --
 OPEN c3;
 FETCH c3 INTO r3;
 IF c3%FOUND
 THEN
 -- get attributes from program parameters
 IF r3.prog_param2prtnum_monfee IS NOT NULL THEN
 BEGIN
 SELECT MAX(price.x_retail_price)
 INTO n_retail_price
 FROM table_x_pricing price,
 table_part_num pn
 WHERE 1 = 1
 AND pn.objid = r3.prog_param2prtnum_monfee -- x_program_parameters.prog_param2prtnum_monfee
 AND pn.objid = price.x_pricing2part_num
 AND price.x_end_date > TRUNC(SYSDATE)
 AND price.x_start_date <= TRUNC(SYSDATE);
 EXCEPTION
 WHEN others THEN
 NULL;
 END;
 END IF;
 --
 INSERT INTO table_web_user( OBJID,
 LOGIN_NAME,
 S_LOGIN_NAME,
 PASSWORD,
 USER_KEY,
 STATUS,
 PASSWD_CHG,
 DEV,
 SHIP_VIA,
 X_SECRET_QUESTN,
 S_X_SECRET_QUESTN,
 X_SECRET_ANS,
 S_X_SECRET_ANS,
 WEB_USER2USER,
 WEB_USER2CONTACT,
 WEB_USER2LEAD,
 WEB_USER2BUS_ORG,
 X_LAST_UPDATE_DATE,
 X_VALIDATED,
 X_VALIDATED_COUNTER
 )
 VALUES (
 l_web_user_id,
 'slbg' || i_lid
 || SUBSTR (i_esn, LENGTH (i_esn) - 3, 4)
 || '@tracmail.com',
 'SLBG' || i_lid
 || SUBSTR (i_esn, LENGTH (i_esn) - 3, 4)
 || '@TRACMAIL.COM',
 '38773853382938213877385338933821',
 NULL,
 1,
 NULL,
 NULL,
 NULL,
 'Please enter the word lifeline as the answer',
 NULL,
 'lifeline',
 NULL,
 NULL,
 l_contact_id,
 NULL,
 c.bus_org_objid, -- CR43878: 268438258 (use from ESN)
 SYSDATE,
 NULL,
 NULL);

 --
 IF r2.x_next_delivery_date IS NULL THEN
 -- for CA
 IF UPPER(i_state) = 'CA' THEN
 -- use expiration date from site part
 d_next_delivery_date := c.get_expiration_date( i_esn => i_esn);
 -- for non CA
 ELSE
 -- use 1st day of the upcoming month
 d_next_delivery_date := TRUNC(ADD_MONTHS(SYSDATE,1),'MONTH');
 END IF;
 ELSE
 -- use the previous value as next delivery date
 d_next_delivery_date := r2.x_next_delivery_date;
 END IF;
 --
 INSERT INTO x_program_enrolled (objid,
 x_esn,
 x_amount,
 x_type,
 x_sourcesystem,
 x_insert_date,
 x_charge_date,
 x_enrolled_date,
 x_start_date,
 x_reason,
 x_delivery_cycle_number,
 x_enroll_amount,
 x_language,
 x_enrollment_status,
 x_is_grp_primary,
 x_next_delivery_date,
 x_update_stamp,
 x_update_user,
 pgm_enroll2pgm_parameter,
 pgm_enroll2site_part,
 pgm_enroll2part_inst,
 pgm_enroll2contact,
 pgm_enroll2web_user,
 x_termscond_accepted)
 VALUES (l_enroll_seq,
 i_esn,
 n_retail_price, -- CR43878: 22.4,
 'INDIVIDUAL',
 'VMBC',
 SYSDATE,
 SYSDATE,
 SYSDATE,
 SYSDATE,
 'First Time Enrollment',
 1,
 0,
 'ENGLISH',
 'ENROLLED',
 1,
 d_next_delivery_date,
 SYSDATE,
 'VMBC',
 r3.objid, -- CR43878: 5802432 replaced by Juda
 l_sp_id,
 l_pi_id,
 l_contact_id,
 l_web_user_id,
 1);
 --
 en_counter := en_counter + 1;
 --
 INSERT INTO x_program_purch_hdr (objid,
 x_rqst_source,
 x_rqst_type,
 x_rqst_date,
 x_merchant_ref_number,
 x_ignore_avs,
 x_ics_rcode,
 x_ics_rflag,
 x_ics_rmsg,
 x_auth_rcode,
 x_auth_rflag,
 x_auth_rmsg,
 x_bill_rcode,
 x_bill_rflag,
 x_bill_rmsg,
 x_customer_email,
 x_status,
 x_bill_country,
 x_amount,
 x_tax_amount,
 x_e911_tax_amount,
 x_user,
 prog_hdr2web_user,
 x_payment_type)
 VALUES (l_purch_hdr_seq,
 'VMBC',
 'LIFELINE_PURCH',
 SYSDATE,
 sa.merchant_ref_number,
 'YES',
 '1',
 'SOK',
 'Request was processed successfully.',
 '1',
 'SOK',
 'Request was processed successfully.',
 '1',
 'SOK',
 'Request was processed successfully.',
 'NULL@CYBERSOURCE.COM',
 'LIFELINEPROCESSED',
 'USA',
 n_retail_price, -- CR43878: 22.4,
 0,
 0,
 'OPERATIONS',
 l_web_user_id,
 'LL_ENROLL');
 --
 INSERT INTO x_program_purch_dtl (objid,
 x_esn,
 x_amount,
 x_tax_amount,
 x_e911_tax_amount,
 x_charge_desc,
 x_cycle_start_date,
 x_cycle_end_date,
 pgm_purch_dtl2pgm_enrolled,
 pgm_purch_dtl2prog_hdr)
 VALUES (l_purch_hdr_dtl_seq,
 i_esn,
 n_retail_price, -- CR43878: 22.4,
 0,
 0,
 'First Time Enrollment Charges',
 TRUNC (SYSDATE),
 TRUNC (SYSDATE) + 30,
 l_enroll_seq,
 l_purch_hdr_seq);
 --
 l_program_trans_seq := sa.billing_seq ('X_PROGRAM_TRANS');
 --
 INSERT INTO x_program_trans (objid,
 x_enrollment_status,
 x_enroll_status_reason,
 x_trans_date,
 x_action_text,
 x_action_type,
 x_reason,
 x_sourcesystem,
 x_esn,
 x_update_user,
 pgm_tran2pgm_entrolled,
 pgm_trans2web_user,
 pgm_trans2site_part)
 VALUES (l_program_trans_seq,
 'ENROLLED',
 'First Time Enrollment',
 SYSDATE,
 'Enrollment Attempt',
 'ENROLLMENT',
 i_enroll_pgm_name || ' $' || NVL(n_retail_price,0) || ' ' || NVL(r3.x_charge_frq_code,'30') || ' days ' || NVL(n_units,0) ||' units' , -- CR43878: 'Lifeline - CA - UNL1 $22.40 30 days 0 units',
 'VMBC',
 i_esn,
 'VMBC',
 l_enroll_seq,
 l_web_user_id,
 l_sp_id);
 --
 p_upd_service_plan ( i_esn => i_esn ,
 i_pgm_enroll2pgm_parameter => r3.objid ,
 i_site_part_id => l_sp_id ,
 o_err_no => o_err_no ,
 o_err_msg => o_err_msg
 );
 UPDATE sa.X_SL_CURRENTVALS
 SET X_CURRENT_PE_ID = l_enroll_seq
 WHERE LID=i_lid;
 --
 UPDATE sa.X_SL_SUBS
 SET SL_SUBS2WEB_USER = l_web_user_id,
 SL_SUBS2TABLE_CONTACT= L_CONTACT_ID
 WHERE LID=i_lid;
 --
 END IF;
 CLOSE c3;
 counter := counter + 1;
 DBMS_OUTPUT.PUT_LINE ('deen_counter ... ' || deen_counter);
 DBMS_OUTPUT.PUT_LINE ('en_counter ... ' || en_counter);
 DBMS_OUTPUT.PUT_LINE ('counter ... ' || counter);
 DBMS_OUTPUT.PUT_LINE ('End of p_enroll_transfer_job ... ' || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
 --
 o_err_no := 0;
 o_err_msg := 'SUCCESS';
 --
 COMMIT;
EXCEPTION
 WHEN OTHERS THEN
 ROLLBACK;
 o_err_no := SQLCODE;
 o_err_msg := 'FAILED';
 lv_records_not_processed := lv_records_not_processed + 1;
 g_request := 'LID='||i_lid;
 g_err_msg := lv_record_not_processed_reason || '. Current LID not processed in enroll_transfer_job' ||' op_err_num: '|| o_err_no ||' op_err_string: '|| SUBSTR(o_err_msg,1, 500);
 --
 ins_job_err (TO_CHAR(g_job_run_objid), 'SL_BG_ENROLL_TRANSFER_JOB', g_request, g_err_msg);
END p_enroll_transfer_job;
--
PROCEDURE p_process_enroll_transfer_job(
 ip_process_days IN NUMBER,
 op_err_no OUT NUMBER,
 op_err_msg OUT VARCHAR2 )
AS
 /*************************************************************************/
 /* Copyright 2016 Tracfone Wireless Inc. All rights reserved */
 /* NAME: p_process_enroll_transfer_job */
 /* PURPOSE: To update the records in Clarify */
 /* related to recordtype 'Verify' from VMBC */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- ----- ------------------------------------------*/
 /* 1.0 07/07/16 Initial Revision */
 /* */
 /************************************************************************/
 lv_records_processed NUMBER := 0;
 lv_records_not_processed NUMBER := 0;
 lv_record_not_processed_reason VARCHAR2(1000);
 exception_record_not_processed EXCEPTION;
 lv_first_name table_contact.first_name%TYPE;
 lv_last_name table_contact.last_name%TYPE;
 lv_address1 table_contact.address_1%TYPE;
 lv_address2 table_contact.address_2%TYPE;
 l_pi_ct_id NUMBER;
 --
 CURSOR cur_deenroll_request
 IS
 SELECT /*+ INDEX(XSU IND_XSUVMBC_REQ_BATCH_DT) */
 xsu.ROWID AS current_record_rowid,
 xsu.*
 FROM xsu_vmbc_request xsu
 WHERE 1 = 1
 AND xsu.requesttype = 'Enroll'
 AND xsu.enrollrequest = 'X'
 AND xsu.requestid IS NULL
 AND xsu.batchdate > TRUNC(SYSDATE) - ip_process_days ;
 --
 CURSOR cur_get_esn (cu_lid xsu_vmbc_request.lid%type)
 IS
 SELECT curvals.x_current_esn x_current_esn
 FROM x_sl_currentvals curvals
 WHERE 1 = 1
 AND curvals.lid = cu_lid ;
 rec_get_esn cur_get_esn%rowtype;
 --
 CURSOR get_address_id (ip_objid IN NUMBER)
 IS
 SELECT ts.objid,
 ts.cust_primaddr2address,
 ts.cust_billaddr2address,
 ts.cust_shipaddr2address
 FROM table_contact c,
 table_contact_role cr,
 table_site ts
 WHERE c.objid = ip_objid
 AND cr.contact_role2contact = c.objid
 AND ts.objid = cr.contact_role2site;
 --
 get_address_id_rec get_address_id%ROWTYPE;
 --
BEGIN
 dbms_output.put_line('********** START OF PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_ENROLL_TRANSFER_JOB **********');
 op_err_no := 0;
 op_err_msg := 'SUCCESS';
 -- Create new job id
 create_job_instance ( ip_job_name => 'SAFELINK_BG_ENROLL',
 ip_status => 'RUNNING',
 ip_job_run_mode => '0',
 ip_seq_name => 'X_JOB_RUN_DETAILS',
 ip_owner_name => 'BATCH_PROC',
 ip_reason => 'Autosys',
 ip_status_code => NULL,
 ip_sub_sourcesystem => 'SAFELINK',
 op_job_run_objid => g_job_run_objid );
 -- Load x_sl_subs
 p_x_sl_subs_import ( ip_process_days => ip_process_days,
 o_err_no => op_err_no,
 o_err_msg => op_err_msg);
 -- Get records from vmbc table with record type as 'Deenroll'
 FOR rec_deenroll_request IN cur_deenroll_request
 LOOP
 --
 BEGIN
 --
 OPEN cur_get_esn (rec_deenroll_request.lid);
 FETCH cur_get_esn INTO rec_get_esn;
 IF cur_get_esn%NOTFOUND
 THEN
 op_err_no := 100;
 op_err_msg := 'Couldnt get ESN';
 CLOSE cur_get_esn;
 raise exception_record_not_processed;
 END IF;
 CLOSE cur_get_esn;
 --
 BEGIN
 SELECT x_part_inst2contact
 INTO l_pi_ct_id
 FROM table_part_inst
 WHERE part_serial_no = rec_get_esn.x_current_esn
 AND x_part_inst_status = '52';
 EXCEPTION
 WHEN no_data_found THEN
 NULL;
 WHEN others THEN
 NULL;
 END;
 --
 -- Get first name and Last name
 sa.safelink_services_pkg.get_first_last_name ( ip_lid => rec_deenroll_request.lid,
 ip_Full_Name => rec_deenroll_request.name,
 op_first_name => lv_first_name,
 op_last_name => lv_last_name);
 --
 lv_address1 := REGEXP_REPLACE (rec_deenroll_request.address,'box','BOX', 1, 0, 'i');
 lv_address2 := rec_deenroll_request.address2;
 --
 OPEN get_address_id (l_pi_ct_id);
 FETCH get_address_id INTO get_address_id_rec;
 IF get_address_id%FOUND
 THEN
 -- Update Site
 UPDATE table_site
 SET name = lv_first_name||' '||lv_last_name,
 s_name = UPPER(lv_first_name)||' '||UPPER(lv_last_name),
 phone = rec_deenroll_request.homenumber
 WHERE objid = get_address_id_rec.objid;
 -- Update contact
 UPDATE table_contact
 SET address_1 = lv_address1,
 address_2 = lv_address2,
 city = rec_deenroll_request.city,
 state = rec_deenroll_request.state,
 zipcode = rec_deenroll_request.zip,
 country = rec_deenroll_request.country,
 phone = rec_deenroll_request.homenumber,
 x_no_phone_flag = DECODE (rec_deenroll_request.homenumber, NULL, 1, 0),
 e_mail = rec_deenroll_request.email,
 first_name = lv_first_name,
 s_first_name = UPPER (lv_first_name),
 last_name = lv_last_name,
 s_last_name = UPPER (lv_last_name)
 WHERE objid = l_pi_ct_id;
 --
 -- Update primary address
 IF NVL(get_address_id_rec.cust_primaddr2address,-1) <> -1
 THEN
 UPDATE table_address a
 SET a.address = lv_address1,
 a.s_address = UPPER (lv_address1),
 a.address_2 = lv_address2,
 a.city = rec_deenroll_request.city,
 a.s_city = UPPER (rec_deenroll_request.city),
 a.state = rec_deenroll_request.state,
 a.s_state = UPPER (rec_deenroll_request.state),
 a.zipcode = rec_deenroll_request.zip
 WHERE a.objid = get_address_id_rec.cust_primaddr2address;
 END IF;
 --
 -- Update Billing address
 IF NVL(get_address_id_rec.cust_billaddr2address,-1) <> -1
 THEN
 UPDATE table_address a
 SET a.address = lv_address1,
 a.s_address = UPPER (lv_address1),
 a.address_2 = lv_address2,
 a.city = rec_deenroll_request.city,
 a.s_city = UPPER (rec_deenroll_request.city),
 a.state = rec_deenroll_request.state,
 a.s_state = UPPER (rec_deenroll_request.state),
 a.zipcode = rec_deenroll_request.zip
 WHERE a.objid = get_address_id_rec.cust_billaddr2address;
 END IF;
 --
 -- Update Shipping address
 IF NVL(get_address_id_rec.cust_shipaddr2address,-1) <> -1 AND
 NVL(rec_deenroll_request.x_shp_address, 'X') <> 'X'
 THEN
 UPDATE table_address a
 SET a.address = rec_deenroll_request.x_shp_address,
 a.s_address = UPPER (rec_deenroll_request.x_shp_address),
 a.address_2 = rec_deenroll_request.x_shp_address2,
 a.city = rec_deenroll_request.x_shp_city,
 a.s_city = UPPER (rec_deenroll_request.x_shp_city),
 a.state = rec_deenroll_request.x_shp_state,
 a.s_state = UPPER (rec_deenroll_request.x_shp_state),
 a.zipcode = rec_deenroll_request.x_shp_zip
 WHERE a.objid = get_address_id_rec.cust_shipaddr2address;
 END IF;
 END IF;
 CLOSE get_address_id;
 --
 p_enroll_transfer_job ( i_esn => rec_get_esn.x_current_esn ,
 i_lid => rec_deenroll_request.lid ,
 i_state => rec_deenroll_request.state ,
 i_enroll_pgm_name => 'Lifeline' || ' - ' || TRIM(rec_deenroll_request.state) ||' - ' || TRIM(rec_deenroll_request.plan) ,
 o_err_no => op_err_no ,
 o_err_msg => op_err_msg
 );
 --
 IF op_err_no = 0
 THEN
 UPDATE xsu_vmbc_request xsu
 SET requestid = g_job_run_objid
 WHERE rowid = rec_deenroll_request.current_record_rowid;
 lv_records_processed := lv_records_processed + 1;
 ELSE
 g_requestid := op_err_no;
 raise exception_record_not_processed;
 END IF;
 --
 EXCEPTION
 WHEN exception_record_not_processed THEN
 lv_records_not_processed := lv_records_not_processed + 1;
 g_request := 'LID='||rec_deenroll_request.lid;
 g_err_msg := lv_record_not_processed_reason || '. Current LID processing not completed.' ||' op_err_num: '|| op_err_no ||' op_err_string: '|| SUBSTR(op_err_msg,1, 500);
 --
 ins_job_err (TO_CHAR(g_job_run_objid), 'SAFELINK_BG_ENROLL', g_request, g_err_msg);
 --
 UPDATE xsu_vmbc_request xsu
 SET requestid = g_requestid
 ||'|'
 ||g_job_run_objid
 WHERE rowid = rec_deenroll_request.current_record_rowid;
 --
 WHEN OTHERS THEN
 lv_records_not_processed := lv_records_not_processed + 1;
 -- log the current LID processing failed
 g_request := 'LID='||rec_deenroll_request.lid;
 g_err_msg := 'Current LID processing failed.. sqlcode : '||SQLCODE ||' sqlerrm: '||SUBSTR(sqlerrm,1, 250)||' op_err_no: '|| op_err_no ||' op_err_msg: '|| SUBSTR(op_err_msg,1, 250);
 ins_job_err (TO_CHAR(g_job_run_objid), 'SAFELINK_BG_ENROLL', g_request, g_err_msg);
 --
 UPDATE xsu_vmbc_request xsu
 SET requestid = g_requestid
 ||'|'
 ||g_job_run_objid -- other error error = -1
 WHERE rowid = rec_deenroll_request.current_record_rowid;
 END; -- cur_deenroll_request
 END LOOP; --main cursor for loop cur_deenroll_request
 dbms_output.put_line('No. of rows processed: '||lv_records_processed);
 dbms_output.put_line('No. of rows failed to be processed: '||lv_records_not_processed);
 update_job_instance ( ip_job_run_objid => g_job_run_objid,
 ip_owner_name => 'BATCH_PROC',
 ip_reason => 'Autosys',
 ip_status => 'SUCCESS',
 ip_status_code => '0',
 ip_sub_sourcesystem => 'SAFELINK' );
 dbms_output.put_line('********** END OF PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_ENROLL_TRANSFER_JOB **********');
 --
 op_err_no := 0;
 op_err_msg := 'SUCCESS';
 COMMIT;
 --
EXCEPTION
WHEN OTHERS THEN
 op_err_no := SQLCODE;
 op_err_msg := 'FAILED';
 g_err_msg := '' || ', No. of rows processed: '|| NVL(lv_records_processed ,0) || ', No. of rows failed: '|| NVL(lv_records_not_processed,0) ||', p_process_annual_verify_job Failed..ERR='|| SUBSTR(sqlerrm,1,500) ;
 ---log job error
 ins_job_err (TO_CHAR(g_job_run_objid), 'SAFELINK_ENROLL_TRANSFER', 'sqlcode: '||SQLCODE, g_err_msg);
 update_job_instance ( ip_job_run_objid => g_job_run_objid,
 ip_owner_name => 'BATCH_PROC',
 ip_reason => 'Autosys',
 ip_status => 'FAILED',
 ip_status_code => '505',
 ip_sub_sourcesystem => 'SAFELINK' );
 --
 dbms_output.put_line('********** EXCEPTION WHILE RUNNING PROCEDURE SA.SAFELINK_SERVICES_PKG.P_PROCESS_ENROLL_TRANSFER_JOB ********** ' || 'op_err_num='||op_err_no ||' g_err_msg: '||g_err_msg );
END p_process_enroll_transfer_job;
-- CR43878 changes ends.

-- CR43143 Changes start
procedure update_last_av_date
 (
 o_err_msg OUT VARCHAR2
 )
 is
 cursor vmbc_req_cur is
 select lid, qualifydate
 from xsu_vmbc_request x
 where x.batchdate >= trunc (sysdate) - 1
 and x.requesttype = 'Verify'
 and exists
 ( select 1
 from x_sl_subs y
 where x.lid = y.lid
 and ( y.x_last_av_date is null
 or y.x_last_av_date <> qualifydate ) );
 lid_tab dbms_sql.varchar2_table;
 qualifydate_tab dbms_sql.varchar2_table;

 begin
 open vmbc_req_cur;
 loop
 fetch vmbc_req_cur bulk collect into lid_tab,qualifydate_tab limit 1000;
 dbms_output.put_line(lid_tab.count);
 exit when lid_tab.count = 0;
 forall i in lid_tab.first..lid_tab.last
 update x_sl_subs sls
 set sls.x_last_av_date = qualifydate_tab(i)
 where sls.lid = lid_tab(i);
 end loop;
 close vmbc_req_cur;
 o_err_msg := 'SUCCESS';
 exception
 when others then
 o_err_msg := substr(dbms_utility.format_error_backtrace(),1,4000);
 close vmbc_req_cur;
 end;
 --
 --CR44770
 --
	PROCEDURE p_deenroll_bkp_job(
		i_max_rows_limit IN NUMBER DEFAULT 100000 ,
		i_commit_every_rows IN NUMBER DEFAULT 5000 ,
		i_bulk_collection_limit IN NUMBER DEFAULT 200 )
	IS
	 --
	 n_count_rows NUMBER := 0;
	 --
	 CURSOR deenroll_bkp_job_cur
	 IS
		SELECT *
		 FROM
			(
			WITH tab AS
				(
				 SELECT DISTINCT df.expired_group,
					 SUBSTR (xsc.x_deenroll_reason, 0, 3)
					 xsc_x_deenroll_reason_short3 ,
					 SUBSTR (xsc.x_deenroll_reason, 0, 1)
					 xsc_x_deenroll_reason_short1 ,
					 xsc.ROWID xsc_rowid,
					 xsc.x_deenroll_reason xsc_x_deenroll_reason,
					 xsc.x_current_enrolled_date,
					 xsc.lid,
					 xsc.x_current_esn
					FROM sa.x_sl_deenroll_flag df,
					 sa.x_sl_currentvals xsc
					WHERE xsc.original_deenroll_reason IS NULL
					 AND df.expired_group IS NOT NULL
					 AND xsc.x_deenroll_reason IS NOT NULL
					 AND SUBSTR (xsc.x_deenroll_reason, 0, 1) = df.x_bill_flag
					 AND xsc.x_current_enrolled_date < TRUNC (SYSDATE) -
					 90
					 AND NOT EXISTS
					 (
						SELECT 1
						 FROM x_program_enrolled pe
						 WHERE pe.x_esn = xsc.x_current_esn
							AND pe.x_sourcesystem = 'VMBC'
							AND pe.x_enrollment_status = 'ENROLLED'
					 )
					AND ROWNUM <= i_max_rows_limit
				)
			 SELECT tab.xsc_rowid,
				 tab.lid,
				 tab.x_current_enrolled_date,
				 tab.xsc_x_deenroll_reason,
				 (
				 CASE
					WHEN ( tab.xsc_x_deenroll_reason_short3 = 'U13'
					 OR tab.xsc_x_deenroll_reason_short3 = 'U10'
					 OR tab.xsc_x_deenroll_reason_short1 = 'N'
					 OR tab.xsc_x_deenroll_reason_short1 = 'D'
					 OR tab.xsc_x_deenroll_reason_short1 = 'H'
					 OR tab.xsc_x_deenroll_reason_short1 = 'P')
					THEN tab.expired_group
					ELSE NULL
				 END) AS new_deenroll_reason
				FROM tab
			);
	 TYPE tab_deenroll_bkp_job_cur
	IS
	 TABLE OF deenroll_bkp_job_cur%rowtype INDEX BY pls_integer;
	 rec_deenroll_bkp_job_cur tab_deenroll_bkp_job_cur;
	 counter NUMBER := 0;
	 cmt_counter NUMBER := 0;
	BEGIN
	 dbms_output.put_line ( 'Begin of SL CV data update .. ' || TO_CHAR (SYSDATE,
	 'MM/DD/YYYY HH:MI:SS'));
	 OPEN deenroll_bkp_job_cur;
	 LOOP
		FETCH deenroll_bkp_job_cur BULK COLLECT
		 INTO rec_deenroll_bkp_job_cur LIMIT i_bulk_collection_limit;
		EXIT
	 WHEN rec_deenroll_bkp_job_cur.COUNT = 0;
		FORALL i IN 1..rec_deenroll_bkp_job_cur.COUNT
		UPDATE x_sl_currentvals
		 SET original_deenroll_reason = rec_deenroll_bkp_job_cur(i)
			.xsc_x_deenroll_reason,
			x_deenroll_reason = rec_deenroll_bkp_job_cur(i).new_deenroll_reason
		 WHERE ROWID = rec_deenroll_bkp_job_cur(i).xsc_rowid;
		--
		-- increase row count
		--
		n_count_rows := n_count_rows + 1;
		IF ( MOD(n_count_rows, i_commit_every_rows) = 0 ) THEN
		 -- Save changes
		 COMMIT;
		 NULL;
		END IF;
	 END LOOP;
	 --
	 CLOSE deenroll_bkp_job_cur;
	 COMMIT;
	 dbms_output.put_line ('counter .. ' || counter);
	 dbms_output.put_line ( 'End of SL CV data update .. ' || TO_CHAR (SYSDATE,
	 'MM/DD/YYYY HH:MI:SS'));
	END p_deenroll_bkp_job;

 -- CR42459
 PROCEDURE ld_sl_cbo_queue_job (o_op_error_code OUT varchar2,
 o_op_error_msg OUT varchar2)
 AS
 --
 -- This procedure loads into the table_queued_cbo_service for safelink customers.
 --
 v_x_service_id sa.table_site_part.x_service_id%type;
 v_x_min sa.table_site_part.x_min%type;
 v_x_service_plan_rec sa.x_service_plan%rowtype;
 v_bus_org sa.table_bus_org.org_id%type;
 v_queue_cbo_limit NUMBER;
 insert_failed EXCEPTION;
 PRAGMA EXCEPTION_INIT(insert_failed, -20101);



 /* CR42459 Tim 12/6/2016
 1. Pick safelink esns where tsp.cmmtmnt_end_dt <= SYSDATE.
 and don't have a card in the queue.
 2. Insert a payload for springfarm table_queued_cbo_service
 3. Update table_site_part so the record will not be reprocessed.
 */



 BEGIN
 o_op_error_code := 0;
 o_op_error_msg := 'Success';

 BEGIN
 -- Find the queue_cbo limit from table.
 SELECT TO_NUMBER(X_PARAM_VALUE) queue_cbo_limit
 INTO v_queue_cbo_limit
 FROM table_x_parameters
 WHERE x_param_name = 'QUEUED_CBO_THRESHOLD';

 EXCEPTION WHEN OTHERS THEN
 v_queue_cbo_limit := 1000;
 END;
 --
 -- CR48195_Safelink_Unlimited_project_post_rollout
 -- Tim 2/14/2017 Modified check to handle customers with multiple cards in the queue.
 --
 FOR tsp_rec IN (SELECT objid objid,
 x_esn,
 x_min
 FROM (
 SELECT tsp.objid objid,
 (SELECT COUNT(*) -- See esn has card in the queue.
 FROM table_part_inst esn,
 table_part_inst lin
 WHERE 1 = 1
 AND lin.part_to_esn2part_inst = esn.objid
 AND lin.X_PART_INST_STATUS = '400'
 AND lin.X_DOMAIN = 'REDEMPTION CARDS'
 AND esn.part_serial_no = tsp.x_service_id) queued_card,
 tsp.x_service_id x_esn,
 tsp.x_min x_min
 FROM table_site_part tsp
 WHERE tsp.cmmtmnt_end_dt <= SYSDATE
 AND ROWNUM <= v_queue_cbo_limit -- We need to limit the records processed.
 ORDER BY tsp.cmmtmnt_end_dt)
 WHERE queued_card = 0) LOOP

 -- Add max records to table x params.

 -- Now check the service plan.
 v_x_service_plan_rec := sa.service_plan.get_service_plan_by_esn(tsp_rec.x_esn);
 v_x_service_plan_rec.objid := NVL(v_x_service_plan_rec.objid,252);

 v_x_service_id := tsp_rec.x_esn;
 v_x_min := tsp_rec.x_min;

 BEGIN
 SELECT bo.org_id
 INTO v_bus_org
 FROM table_part_num pn,
 table_mod_level ml,
 table_site s,
 table_inv_role ir,
 table_inv_bin ib,
 table_part_inst pi,
 table_bus_org bo
 WHERE pn.objid = ml.part_info2part_num
 AND ml.objid = pi.n_part_inst2part_mod
 AND s.objid = ir.inv_role2site
 AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
 AND ib.objid = pi.part_inst2inv_bin
 AND pi.x_domain = 'PHONES'
 AND pi.part_serial_no = tsp_rec.x_esn
 AND pn.PART_NUM2BUS_ORG = bo.objid
 AND ROWNUM = 1;


 EXCEPTION WHEN OTHERS THEN

 v_bus_org := NULL;

 END;

 -- Start
 FOR REC IN (SELECT 'BenefitsDeliveryService' ip_cbo_task_name,
 'Q' ip_status,
 SYSDATE ip_creation_date,
 1 ip_delay_in_seconds,
 TO_CLOB('<ben:benefitsDeliveryRequest xmlns:ben="http://www.tracfone.com/BenefitsDeliveryServices" xmlns:com="http://www.tracfone.com/CommonTypes" xmlns:phon="http://www.tracfone.com/PhoneCommonTypes" xmlns:ben1="http://www.tracfone.com/BenefitsDeliveryAndProvisioningCommonTypes">'||
 '<com:requestToken>'||
 '<com:clientTransactionId xmlns:ben="http://b2b.tracfone.com/BenefitsDeliveryServices">CORE</com:clientTransactionId>'||
 '<com:clientId xmlns:ben="http://b2b.tracfone.com/BenefitsDeliveryServices">CBO</com:clientId>'||
 '</com:requestToken>'||
 '<com:brandName>'||v_bus_org||'</com:brandName>'||
 '<com:sourceSystem>BATCH</com:sourceSystem>'||
 '<com:language>ENG</com:language>'||
 '<ben:deviceId>'||
 '<phon:esn>'||tsp_rec.x_esn||'</phon:esn>'||
 '</ben:deviceId>'||
 '<ben:benefitsDeliveryContextType>BALANCE_REPLAY</ben:benefitsDeliveryContextType>'||
 '<ben:optionalBenefitsDeliveryData/>'||
 '<ben:redemptionObjectList>'||
 '<ben1:redemptionObjects>'||
 '<n1:servicePlan xmlns:n1="http://www.tracfone.com/BenefitsDeliveryAndProvisioningCommonTypes" xmlns:ben="http://b2b.tracfone.com/BenefitsDeliveryServices">'||
 '<n1:servicePlanid>'||v_x_service_plan_rec.objid||'</n1:servicePlanid>'||
 '</n1:servicePlan>'||
 '</ben1:redemptionObjects>'||
 '</ben:redemptionObjectList>'||
 '<ben:processOption>REFILL_NOW</ben:processOption>'||
 '</ben:benefitsDeliveryRequest>') ip_request,
 '/IOSB/SpringfarmServices/BenefitsDeliveryServices' ip_soa_service_url,
 tsp_rec.x_esn ip_esn,
 NULL ip_upgrade_to_esn,
 'BATCH' ip_source_system,
 tsp_rec.x_min x_min
 FROM DUAL) LOOP


 sa.util_pkg.p_insert_queued_cbo_service
 (rec.ip_cbo_task_name,
 rec.ip_status,
 rec.ip_creation_date,
 rec.ip_delay_in_seconds,
 rec.ip_request,
 rec.ip_soa_service_url,
 rec.ip_esn,
 rec.ip_upgrade_to_esn,
 rec.ip_source_system,
 o_op_error_code,
 o_op_error_msg);



 IF o_op_error_code IS NOT NULL THEN

 dbms_output.put_line('tsp_rec.x_esn :'||tsp_rec.x_esn);
 dbms_output.put_line('tsp_rec.x_min :'||tsp_rec.x_min);
 dbms_output.put_line('v_op_error_code :'||o_op_error_code);
 dbms_output.put_line('v_op_error_msg :'||o_op_error_msg);
 RAISE insert_failed;

 END IF;

 UPDATE table_site_part tsp
 SET tsp.cmmtmnt_end_dt = NULL
 WHERE objid = tsp_rec.objid;

 END LOOP;

 END LOOP;


 COMMIT;

 EXCEPTION
 WHEN insert_failed THEN
 ROLLBACK;
 WHEN OTHERS THEN
 dbms_output.put_line('v_x_service_id :'||v_x_service_id);
 dbms_output.put_line('v_x_min :'||v_x_min);
 dbms_output.put_line('v_op_error_code :'||o_op_error_code);
 dbms_output.put_line('v_op_error_msg :'||o_op_error_msg);
 dbms_output.put_line('sqlcode :'||sqlcode);
 dbms_output.put_line('sqlerrm :'||sqlerrm);
 ROLLBACK;


 END ld_sl_cbo_queue_job;

PROCEDURE update_sp_plan(i_esn        IN  VARCHAR,
                         i_tsp_objid  IN  NUMBER,
                         o_err_code   OUT NUMBER,
                         o_err_msg    OUT VARCHAR2)
AS
 CURSOR cur_esn_dtl(i_esn IN VARCHAR)
 IS
 SELECT pn.part_number part_number,
 pi.objid pi_objid,bo.org_id
 FROM table_part_inst pi ,
 sa.table_mod_level ml ,
 sa.table_part_num pn ,
 sa.table_bus_org bo ,
 sa.table_part_class pc
 WHERE 1 = 1
 AND pi.x_domain = 'PHONES'
 AND pi.x_part_inst_status = '52'
 AND ml.objid = pi.n_part_inst2part_mod
 AND pn.objid = ml.part_info2part_num
 AND bo.objid = pn.part_num2bus_org
 AND pc.objid = pn.part_num2part_class
 AND pi.part_serial_no = i_esn;
 rec_esn_dtl cur_esn_dtl%rowtype;
BEGIN
o_err_code := 0;
o_err_msg := 'Success';

 OPEN cur_esn_dtl(i_esn);
 FETCH cur_esn_dtl INTO rec_esn_dtl;
 IF cur_esn_dtl%rowcount = 0 THEN
 CLOSE cur_esn_dtl;
 o_err_code := -1;
 o_err_msg :='Phone is not active. x_esn: '||i_esn;
 END IF;
 CLOSE cur_esn_dtl;

 UPDATE  table_site_part
 SET     site_part2x_new_plan = sa.preloaded_click(rec_esn_dtl.part_number)
 WHERE   objid                = i_tsp_objid;

 IF SQL%rowcount <> 1 THEN
 ROLLBACK;
  o_err_code := -2;
  o_err_msg  := 'Record is not updated in the table_site_part';
 END IF;
  o_err_code := 0;
  o_err_msg  := 'Success';
EXCEPTION
WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE('In main exception '||sqlerrm);
  o_err_code := -3;
  o_err_msg  := 'in exception update_sp_plan due to '||sqlerrm;
END update_sp_plan;


END safelink_services_pkg;
/