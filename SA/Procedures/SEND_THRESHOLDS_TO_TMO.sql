CREATE OR REPLACE PROCEDURE sa."SEND_THRESHOLDS_TO_TMO" ( i_transaction_id IN NUMBER ,
 i_call_trans_objid IN NUMBER ,
 o_errorcode OUT NUMBER ,
 o_errormsg OUT VARCHAR2 )
 IS
 --
 cst customer_type := customer_type ();
 --
 ct sa.call_trans_type := call_trans_type ();
 c sa.call_trans_type := call_trans_type ();
 --
 tt sa.task_type := sa.task_type();
 t sa.task_type := sa.task_type();
 --
 it sa.ig_transaction_type := ig_transaction_type ();
 ig sa.ig_transaction_type := ig_transaction_type ();
 igt sa.ig_transaction_type;
 --
 igb_list ig_transaction_buckets_tab;
 --
 l_transaction_id NUMBER;
 l_threshold NUMBER;
 l_bucket_id VARCHAR2(30) := NULL;
 l_benefit_type VARCHAR2(30) := NULL;
 l_cos VARCHAR2(10) := NULL;
 l_rate_plan_flag VARCHAR2(1);
 --
 CURSOR benefit_curs(c_site_part_objid IN NUMBER,
 c_parent_name IN VARCHAR2,
 c_non_ppe IN NUMBER,
 c_rate_plan IN VARCHAR2)

 IS
 select 1
	 from x_service_plan_site_part spsp,
 x_service_plan sp,
 x_service_plan_feature spf,
 x_serviceplanfeaturevalue_def def,
 x_serviceplanfeature_value value,
 x_serviceplanfeaturevalue_def def2
 where 1 =1
 and spsp.table_site_part_id = c_site_part_objid
 and sp.objid = spsp.x_service_plan_id
 and spf.sp_feature2service_plan = sp.objid
 and def.objid = spf.sp_feature2rest_value_def
 and def.display_name like 'CARRIER_BUCKET%'
 and value.spf_value2spf = spf.objid
 and def2.objid = value.value_ref
 and exists(select 1
 from gw1.ig_buckets ib
 where ib.bucket_id = regexp_substr(def2.value_name, '[^ ]+', 1, 3)
 and ib.rate_plan = c_rate_plan)
 and (case when c_parent_name like '%VERIZON%' then 'VER'
 when c_parent_name like 'AT%' then 'ATT'
 when c_parent_name like '%CINGULAR%'then 'ATT'
 when c_parent_name like '%SPRINT%' then 'SPR'
 when c_parent_name like 'T_MOB%' then 'TMO'
 else 'XXX'
 end )= substr(def2.value_name,1,3)
 and c_non_ppe = 1;

 benefit_rec benefit_curs%rowtype;

BEGIN
 --
 IF i_transaction_id IS NULL AND i_call_trans_objid IS NULL THEN
 o_errorcode := -1;
 o_errormsg := 'MISSING TRANSACTION_ID/CALL_TRANS OBJID';
 RETURN;
 END IF;

 l_transaction_id := i_transaction_id;

 IF i_call_trans_objid IS NOT NULL THEN
 l_transaction_id := ig.get_ig_transaction_id (i_call_trans_objid);
 END IF;

 -- ig
 ig := sa.ig_transaction_type (i_transaction_id => l_transaction_id );

 -- by rate plan
 BEGIN
 select nvl(thresholds_to_tmo,'Y')
 into l_rate_plan_flag
 from sa.x_rate_plan
 where x_rate_plan = ig.rate_plan;
 EXCEPTION
 WHEN OTHERS THEN
 l_rate_plan_flag := 'Y';
 END;

 --
 IF l_rate_plan_flag = 'N' THEN
 o_errorcode := -3;
 o_errormsg := 'RATE PLAN EXCLUDED';
 RETURN;
 END IF;

 -- addon's info
 BEGIN
 select sp.cos
 into l_cos
 from sa.x_account_group_benefit agb,
 service_plan_feat_pivot_mv sp
 where 1 = 1
 and agb.service_plan_id = sp.service_plan_objid
 and call_trans_id = ig.call_trans_objid;
 EXCEPTION
 when others then
 l_cos := null;
 END;

 cst.short_parent_name := sa.customer_info.get_short_parent_name (i_esn => ig.esn);

 cst.bus_org_id := sa.customer_info.get_bus_org_id (i_esn => ig.esn);

 IF NOT (cst.short_parent_name = 'TMO' and cst.bus_org_id in ('STRAIGHT_TALK', 'NET10') ) THEN
 o_errorcode := -3;
 o_errormsg := 'BRAND/CARRIER NOT APPLICABLE';
 RETURN;
 END IF;

 IF l_cos IS NULL THEN
 l_cos := sa.get_cos(i_esn => ig.esn);
 END IF;

 -- cos config
 BEGIN
 select threshold
 into l_threshold
 from sa.x_policy_mapping_config
 where usage_tier_id = 2
 and cos = l_cos
 and parent_name = cst.short_parent_name
 and tmo_threshold_flag = 'Y'
 and rownum < 2;
 EXCEPTION
 WHEN OTHERS THEN
 o_errorcode := -3;
 o_errormsg := 'MISSING POLICY/CARRIER CONFIG';
 RETURN;
 END;

 -- ig order config
 BEGIN
 SELECT x_bucket_id,
 x_benefit_type
 INTO l_bucket_id,
 l_benefit_type
 FROM tmo_thresholds_order_config
 WHERE ig_order_type = ig.order_type
 and active_flag = 'Y';
 EXCEPTION
 WHEN OTHERS THEN
 o_errorcode := -4;
 o_errormsg := 'NO IG ORDER CONFIG';
 RETURN;
 END;

 -- subcriber info
 cst := customer_type(i_esn => ig.esn);
 cst := cst.retrieve;

 -- Get the correct action type
 c.action_type := ct.get_action_type ( i_code_type => 'NOTIFY' ,
 i_code_name => 'PLAN_INFO' );

 -- instantiate call trans values
 ct := call_trans_type ( i_esn => ig.esn ,
 i_action_type => c.action_type ,
 i_sourcesystem => 'BATCH' , -- CR57227
 i_sub_sourcesystem => cst.bus_org_id ,
 i_reason => 'PLAN INFO' ,
 i_result => 'Completed' ,
 i_ota_req_type => NULL ,
 i_ota_type => NULL ,
 i_total_units => NULL ,
 i_total_days => NULL ,
 i_total_sms_units => NULL ,
 i_total_data_units => NULL );

 -- call the insert method
 ct := ct.ins;

 --
 IF ct.response <> 'SUCCESS' THEN
 o_errorcode := -3;
 o_errormsg := 'CALL TRANS '|| ct.response;
 RETURN;
 END IF;

 --
 IF ct.call_trans_objid IS NULL THEN
 o_errorcode := -3;
 o_errormsg := 'CALL TRANS NOT CREATED';
 RETURN;
 END IF;

 -- task
 ig.order_type := 'PLAN_INFO';

 tt := task_type ( i_call_trans_objid => ct.call_trans_objid ,
 i_contact_objid => cst.contact_objid ,
 i_order_type => ig.order_type ,
 i_bypass_order_type => 0 ,
 i_case_code => 0 );

 --
 t := tt.ins;

 IF t.response <> 'SUCCESS' THEN
 o_errorcode := -4;
 o_errormsg := 'TABLE TASK '|| t.response ;
 RETURN;

 ELSIF t.task_objid IS NULL THEN
 o_errorcode := -4;
 o_errormsg := 'TASK OBJID IS NULL';
 RETURN;
 END IF;

 -- ig attributes
 ig.status_message := NULL;
 ig.creation_date := SYSDATE;
 ig.update_date := SYSDATE;
 ig.blackout_wait := SYSDATE;
 ig.min := ig.msid;
 ig.new_msid_flag := NULL;
 ig.action_item_id := t.task_id;
 ig.order_type := 'PLAN_INFO';
 ig.status := 'Q';
 ig.transaction_id := gw1.trans_id_seq.NEXTVAL + ( POWER(2,28));


 it := ig_transaction_type ( i_action_item_id => ig.action_item_id ,
 i_carrier_id => ig.carrier_id ,
 i_order_type => ig.order_type ,
 i_min => ig.min ,
 i_esn => ig.esn ,
 i_esn_hex => ig.esn_hex ,
 i_old_esn => ig.old_esn ,
 i_old_esn_hex => ig.old_esn_hex ,
 i_pin => ig.pin ,
 i_phone_manf => ig.phone_manf ,
 i_end_user => ig.end_user ,
 i_account_num => ig.account_num ,
 i_market_code => ig.market_code ,
 i_rate_plan => ig.rate_plan ,
 i_ld_provider => ig.ld_provider ,
 i_sequence_num => ig.sequence_num ,
 i_dealer_code => ig.dealer_code ,
 i_transmission_method => ig.transmission_method ,
 i_fax_num => ig.fax_num ,
 i_online_num => ig.online_num ,
 i_email => ig.email ,
 i_network_login => ig.network_login ,
 i_network_password => ig.network_password ,
 i_system_login => ig.system_login ,
 i_system_password => ig.system_password ,
 i_template => ig.template ,
 i_exe_name => ig.exe_name ,
 i_com_port => ig.com_port ,
 i_status => ig.status ,
 i_status_message => ig.status_message ,
 i_fax_batch_size => ig.fax_batch_size ,
 i_fax_batch_q_time => ig.fax_batch_q_time ,
 i_expidite => ig.expidite ,
 i_trans_prof_key => ig.trans_prof_key ,
 i_q_transaction => ig.q_transaction ,
 i_online_num2 => ig.online_num2 ,
 i_fax_num2 => ig.fax_num2 ,
 i_creation_date => ig.creation_date ,
 i_update_date => ig.update_date ,
 i_blackout_wait => ig.blackout_wait ,
 i_tux_iti_server => ig.tux_iti_server ,
 i_transaction_id => ig.transaction_id ,
 i_technology_flag => ig.technology_flag ,
 i_voice_mail => ig.voice_mail ,
 i_voice_mail_package => ig.voice_mail_package ,
 i_caller_id => ig.caller_id ,
 i_caller_id_package => ig.caller_id_package ,
 i_call_waiting => ig.call_waiting ,
 i_call_waiting_package => ig.call_waiting_package ,
 i_rtp_server => ig.rtp_server ,
 i_digital_feature_code => ig.digital_feature_code ,
 i_state_field => ig.state_field ,
 i_zip_code => ig.zip_code ,
 i_msid => ig.msid ,
 i_new_msid_flag => ig.new_msid_flag ,
 i_sms => ig.sms ,
 i_sms_package => ig.sms_package ,
 i_iccid => ig.iccid ,
 i_old_min => ig.old_min ,
 i_digital_feature => ig.digital_feature ,
 i_ota_type => ig.ota_type ,
 i_rate_center_no => ig.rate_center_no ,
 i_application_system => ig.application_system ,
 i_subscriber_update => ig.subscriber_update ,
 i_download_date => ig.download_date ,
 i_prl_number => ig.prl_number ,
 i_amount => ig.amount ,
 i_balance => ig.balance ,
 i_language => ig.language ,
 i_exp_date => ig.exp_date ,
 i_x_mpn => ig.x_mpn ,
 i_x_mpn_code => ig.x_mpn_code ,
 i_x_pool_name => ig.x_pool_name ,
 i_imsi => ig.imsi ,
 i_new_imsi_flag => ig.new_imsi_flag );

 -- insert ig
 igt := it.ins;

 BEGIN
 select carrier_feature_objid,
 cf_profile_id,
 rp_ext_objid
 into ig.carrier_feature_objid,
 ig.cf_profile_id,
 ig.rp_ext_objid
 from gw1.ig_transaction
 where transaction_id = l_transaction_id;
 EXCEPTION
 WHEN OTHERS THEN
 NULL;
 END;

 update gw1.ig_transaction
 set carrier_feature_objid = ig.carrier_feature_objid,
 cf_profile_id = ig.cf_profile_id,
 rp_ext_objid = ig.rp_ext_objid
 where transaction_id = igt.transaction_id;


 -- if ig was not created successfully
 IF igt.response <> 'SUCCESS' THEN
 o_errorcode := -5;
 o_errormsg := 'IG '|| igt.response;
 RETURN;
 END IF;

 -- ig buckets
 OPEN benefit_curs (cst.site_part_objid ,
 cst.parent_name ,
 cst.non_ppe_flag ,
 ig.rate_plan );

 FETCH benefit_curs INTO benefit_rec;

 IF benefit_curs%FOUND THEN
 CLOSE benefit_curs;

 SELECT ig_transaction_buckets_type ( transaction_id => b.transaction_id,
 bucket_id => b.bucket_id,
 recharge_date => b.recharge_date,
 bucket_balance => b.bucket_balance,
 bucket_value => b.bucket_balance,
 expiration_date => b.expiration_date,
 direction => b.direction,
 benefit_type => b.benefit_type,
 bucket_type => b.bucket_type )
 BULK COLLECT
 INTO igb_list
 FROM ( SELECT /*+ use_invisible_indexes*/ igbt.*
 FROM ig_transaction_buckets igbt,
 ig_transaction igt
 WHERE 1 =1
 AND igbt.transaction_id = igt.transaction_id
 AND igt.status IN ('S', 'W')
 AND igt.transaction_id = l_transaction_id
 AND igbt.direction = 'OUTBOUND'
 AND igbt.bucket_type = 'DATA_UNITS'
 ) b
 WHERE ROWNUM < 2 ;

 IF igb_list.COUNT > 0 THEN
 --
 FOR bucket_info IN igb_list.FIRST..igb_list.LAST LOOP
 -- ig transaction buckets
 INSERT INTO gw1.ig_transaction_buckets
 ( transaction_id,
 bucket_id,
 recharge_date,
 bucket_balance,
 bucket_value,
 expiration_date,
 direction,
 benefit_type,
 bucket_type)
 VALUES
 ( ig.transaction_id,
 l_bucket_id,
 igb_list(bucket_info).recharge_date,
 l_threshold,
 l_threshold,
 igb_list(bucket_info).expiration_date,
 'OUTBOUND',
 l_benefit_type,
 igb_list(bucket_info).bucket_type);

 END LOOP;
 END IF; -- ig buckets
 ELSE -- not found
 CLOSE benefit_curs;
 END IF; --benefit curs

 o_errorcode := 0;
 o_errormsg := 'SUCCESS' ;
EXCEPTION
 WHEN OTHERS THEN
 o_errorcode := -6;
 o_errormsg := 'FAILURE '|| dbms_utility.format_error_backtrace()|| sqlerrm ;
END send_thresholds_to_tmo;
/