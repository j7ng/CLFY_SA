CREATE OR REPLACE PACKAGE BODY sa."CUSTOMER_INFO"
AS

-- convert the given pin to smp
FUNCTION convert_pin_to_smp ( i_red_card_code IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 --
 IF i_red_card_code IS NULL THEN
 RETURN NULL;
 END IF;

 RETURN (c.convert_pin_to_smp ( i_red_card_code => i_red_card_code ));
END convert_pin_to_smp;

-- convert the given smp to pin
FUNCTION convert_smp_to_pin ( i_smp IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN

 IF i_smp IS NULL THEN
 RETURN NULL;
 END IF;

 RETURN (c.convert_smp_to_pin ( i_smp => i_smp ));

END convert_smp_to_pin;


FUNCTION get_leasing_flag ( i_bus_org_objid IN NUMBER) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 --
 IF i_bus_org_objid IS NULL THEN
 RETURN NULL;
 END IF;

 RETURN (c.get_leasing_flag ( i_bus_org_objid => i_bus_org_objid ));

END get_leasing_flag;

FUNCTION get_bus_org_id ( i_esn IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS

 c sa.customer_type := sa.customer_type();
BEGIN

 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;

 RETURN (c.get_bus_org_id ( i_esn => i_esn ));
END get_bus_org_id;


FUNCTION get_bus_org_objid ( i_esn IN VARCHAR2 ) RETURN NUMBER DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;
 --
 RETURN (c.get_bus_org_objid ( i_esn => i_esn ));
END get_bus_org_objid;

--
FUNCTION get_bus_org_objid ( i_bus_org_id IN VARCHAR2 ) RETURN NUMBER DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_bus_org_id IS NULL THEN
 RETURN NULL;
 END IF;
 c.bus_org_id := i_bus_org_id;
 RETURN c.get_bus_org_objid;
END get_bus_org_objid;

FUNCTION get_min ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS

 c sa.customer_type := sa.customer_type();

BEGIN

 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;

 RETURN c.get_min ( i_esn => i_esn );

END get_min;

FUNCTION get_esn ( i_min IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS

 c sa.customer_type := sa.customer_type();

BEGIN

 IF(i_min IS NULL) THEN
 RETURN NULL;
 END IF;

 RETURN c.get_esn (i_min => i_min );

END get_esn;

FUNCTION get_brm_applicable_flag ( i_bus_org_objid IN NUMBER ,
 i_program_parameter_objid IN NUMBER ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_bus_org_objid IS NULL OR
 i_program_parameter_objid IS NULL
 THEN
 RETURN 'N';
 END IF;

 RETURN c.get_brm_applicable_flag ( i_bus_org_objid => i_bus_org_objid ,
 i_program_parameter_objid => i_program_parameter_objid );
END get_brm_applicable_flag;

FUNCTION get_brm_applicable_flag ( i_bus_org_id IN VARCHAR2 ,
 i_program_parameter_objid IN NUMBER ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_bus_org_id IS NULL OR
 i_program_parameter_objid IS NULL
 THEN
 RETURN 'N';
 END IF;
 RETURN c.get_brm_applicable_flag ( i_bus_org_id => i_bus_org_id ,
 i_program_parameter_objid => i_program_parameter_objid );
END get_brm_applicable_flag;

FUNCTION get_brm_applicable_flag ( i_busorg_objid IN NUMBER) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF(i_busorg_objid IS NULL) THEN
 RETURN NULL;
 END IF;
 RETURN c.get_brm_applicable_flag (i_busorg_objid => i_busorg_objid);
END get_brm_applicable_flag;

FUNCTION get_brm_applicable_flag ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC
IS
 c sa.customer_type := sa.customer_type();
BEGIN
 c.brm_applicable_flag := c.get_brm_applicable_flag (i_esn => i_esn);
 RETURN c.brm_applicable_flag;
END;

FUNCTION get_brm_notification_flag ( i_bus_org_objid IN NUMBER ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF(i_bus_org_objid IS NULL) THEN
 RETURN NULL;
 END IF;
 RETURN c.get_brm_notification_flag (i_bus_org_objid => i_bus_org_objid);
END get_brm_notification_flag;

FUNCTION get_brm_notification_flag ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF(i_esn IS NULL) THEN
 RETURN NULL;
 END IF;
 RETURN c.get_brm_notification_flag (i_esn => i_esn);
END get_brm_notification_flag;

FUNCTION get_expiration_date ( i_esn IN VARCHAR2 ) RETURN DATE DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF(i_esn IS NULL) THEN
 RETURN NULL;
 END IF;
 RETURN c.get_expiration_date (i_esn => i_esn );
END get_expiration_date;

FUNCTION get_last_redemption_date ( i_esn IN VARCHAR2 ,
 i_exclude_esn IN VARCHAR2 DEFAULT NULL ) RETURN DATE DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF (i_esn IS NULL) THEN
 RETURN NULL;
 END IF;
 RETURN c.get_last_redemption_date (i_esn => i_esn,
 i_exclude_esn => i_exclude_esn );
END get_last_redemption_date;

FUNCTION get_contact_info ( i_esn IN VARCHAR2, i_value IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
 cst sa.customer_type ;
BEGIN
 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;

 IF i_value IS NULL THEN
 RETURN 'i_value cannot be NULL';
 END IF;

 cst := c.get_contact_info (i_esn => i_esn );
 IF i_value = 'FIRST_NAME' THEN
 RETURN cst.first_name;
 ELSIF i_value = 'LAST_NAME' THEN
 RETURN cst.last_name;
 ELSIF i_value = 'CUSTOMER_ID' THEN
 RETURN cst.CUSTOMER_ID;
 END IF;
END get_contact_info;

FUNCTION get_contact_add_info ( i_esn IN VARCHAR2, i_value IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
 cst sa.customer_type ;
BEGIN
 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;

 IF i_value IS NULL THEN
 RETURN 'i_value cannot be NULL';
 END IF;

 cst := c.get_contact_add_info (i_esn => i_esn );

 IF i_value = 'CONTACT_OBJID' THEN
 RETURN cst.contact_objid;
 ELSIF i_value = 'DO_NOT_EMAIL' THEN
 RETURN cst.do_not_email;
 ELSIF i_value = 'DO_NOT_PHONE' THEN
 RETURN cst.do_not_phone;
 ELSIF i_value = 'DO_NOT_SMS' THEN
 RETURN cst.do_not_phone;
 ELSIF i_value = 'DO_NOT_MAIL' THEN
 RETURN cst.do_not_phone;
 ELSIF i_value = 'PIN' THEN
 RETURN cst.contact_security_pin;
 END IF;
END get_contact_add_info;

FUNCTION get_part_class_attributes ( i_esn IN VARCHAR2 ,
 i_value IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
 cst sa.customer_type ;
BEGIN

 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;

 IF i_value IS NULL THEN
 RETURN 'i_value cannot be NULL';
 END IF;

 cst := c.get_part_class_attributes ( i_esn => i_esn );

 IF i_value = 'PART_NUMBER' THEN
 RETURN cst.esn_part_number;
 ELSIF i_value = 'DEVICE_MODEL' THEN
 RETURN cst.model_type;
 ELSIF i_value = 'MANUFACTURER' THEN
 RETURN cst.phone_manufacturer;
 ELSIF i_value = 'DEVICE_TYPE' THEN
 RETURN cst.device_type;
 END IF;
END get_part_class_attributes;

FUNCTION get_ota_conversion_rate ( i_esn_part_inst_objid IN NUMBER ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_esn_part_inst_objid IS NULL THEN
 RETURN NULL;
 END IF;
 RETURN c.get_ota_conversion_rate ( i_esn_part_inst_objid => i_esn_part_inst_objid );
END get_ota_conversion_rate;

FUNCTION get_propagate_flag ( i_rate_plan IN VARCHAR2 ) RETURN NUMBER DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_rate_plan IS NULL THEN
 RETURN NULL;
 END IF;
 RETURN c.get_propagate_flag ( i_rate_plan => i_rate_plan );
END get_propagate_flag;

FUNCTION get_rate_plan ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
	c sa.customer_type := sa.customer_type();
BEGIN
 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;
 RETURN c.get_rate_plan ( i_esn => i_esn );
END get_rate_plan;

FUNCTION get_shared_group_flag ( i_bus_org_id IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_bus_org_id IS NULL THEN
 RETURN NULL;
 END IF;
 RETURN c.get_shared_group_flag ( i_bus_org_id => i_bus_org_id );
END get_shared_group_flag;

FUNCTION get_shared_group_flag ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;
 RETURN c.get_shared_group_flag ( i_esn => i_esn );
END get_shared_group_flag;

FUNCTION get_short_parent_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;
 RETURN c.get_short_parent_name ( i_esn => i_esn );
END get_short_parent_name;

FUNCTION get_short_parent_name ( i_parent_name IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_parent_name IS NULL THEN
 RETURN NULL;
 END IF;
 RETURN c.get_short_parent_name ( i_parent_name => i_parent_name );
END get_short_parent_name;

FUNCTION get_service_plan_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;
 RETURN c.get_service_plan_name (i_esn => i_esn);
END get_service_plan_name;

FUNCTION get_service_plan_objid ( i_esn IN VARCHAR2 ) RETURN NUMBER DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;
 RETURN c.get_service_plan_objid (i_esn => i_esn);
END get_service_plan_objid;

FUNCTION get_sub_brand ( i_min IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_min IS NULL THEN
 RETURN NULL;
 END IF;
 c.min := i_min;
 RETURN (c.get_sub_brand) ;
END get_sub_brand;

FUNCTION get_web_user_id ( i_hash_webuserid IN VARCHAR2 ) RETURN NUMBER DETERMINISTIC IS

 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_hash_webuserid IS NULL THEN
 RETURN NULL;
 END IF;
 RETURN (c.get_web_user_id (i_hash_webuserid => i_hash_webuserid));
END get_web_user_id;


FUNCTION get_web_user_attributes ( i_esn IN VARCHAR2 ,
 i_value IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
 cst sa.customer_type;
BEGIN

 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;

 IF i_value IS NULL THEN
 RETURN 'i_value cannot be NULL';
 END IF;

 c.esn := i_esn;
 cst := c.get_web_user_attributes;

 IF i_value = 'LOGIN_NAME' THEN
	 RETURN cst.web_login_name;
 --CR49875 start
 ELSIF i_value = 'WEB_USER_ID' THEN
	 RETURN cst.web_user_objid;
 --CR49875 end
 END IF;

END get_web_user_attributes;

FUNCTION retrieve_login ( i_login_name IN VARCHAR2 ,
 i_bus_org_id IN VARCHAR2,
 i_value IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
 c sa.customer_type := sa.customer_type();
 cst sa.customer_type;
BEGIN

 IF(i_login_name IS NULL OR i_bus_org_id IS NULL) THEN
 RETURN NULL;
 END IF;

 IF i_value IS NULL THEN
 RETURN 'i_value cannot be NULL';
 END IF;

 cst := c.retrieve_login ( i_login_name => i_login_name ,
 i_bus_org_id => i_bus_org_id );

 IF i_value = 'ACCOUNT_PIN' THEN
	 RETURN cst.security_pin;
 END IF;
END retrieve_login;

FUNCTION get_esn_part_inst_objid ( i_esn IN VARCHAR2 ) RETURN NUMBER DETERMINISTIC IS

 c sa.customer_type := sa.customer_type();

BEGIN

 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;

 RETURN c.get_esn_part_inst_objid ( i_esn => i_esn );

END get_esn_part_inst_objid;

FUNCTION get_service_plan_attributes ( i_esn IN VARCHAR2 ,
 i_value IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS

 c sa.customer_type := sa.customer_type ( i_esn => i_esn );
 cst sa.customer_type;
BEGIN

 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;

 IF i_value IS NULL THEN
 RETURN 'i_value cannot be NULL';
 END IF;

 cst := c.get_service_plan_attributes;

 IF i_value = 'PART_NUMBER' THEN
	 RETURN cst.service_plan_part_number;
 ELSIF i_value = 'PART_CLASS_NAME' THEN
	 RETURN cst.service_plan_part_class_name;
 END IF;

END get_service_plan_attributes;

FUNCTION get_esn_queued_cards (i_esn IN VARCHAR2) RETURN customer_queued_card_tab DETERMINISTIC
IS
 c sa.customer_type := sa.customer_type();
BEGIN
 c.queued_cards := c.get_esn_queued_cards (i_esn => i_esn);
 RETURN c.queued_cards;
END get_esn_queued_cards;

FUNCTION get_esn_pin_redeem_days (i_esn IN VARCHAR2, i_pin IN VARCHAR2) RETURN NUMBER DETERMINISTIC
IS
 c sa.customer_type := sa.customer_type();
BEGIN
 c.queued_days := c.get_esn_pin_redeem_days (i_esn => i_esn,
 i_pin => i_pin);
 RETURN c.queued_days;
END get_esn_pin_redeem_days;

FUNCTION get_service_plan_days ( i_esn IN VARCHAR2,
 i_pin IN VARCHAR2,
 i_service_plan_objid NUMBER DEFAULT NULL) RETURN VARCHAR2 DETERMINISTIC
IS
 c sa.customer_type := sa.customer_type();
BEGIN
 c.service_plan_days := c.get_service_plan_days (i_esn => i_esn,
 i_pin => i_pin,
 i_service_plan_objid => i_service_plan_objid);
 RETURN c.service_plan_days;
END get_service_plan_days;

FUNCTION get_service_plan_days_name ( i_esn IN VARCHAR2,
 i_pin IN VARCHAR2,
 i_service_plan_objid NUMBER DEFAULT NULL) RETURN VARCHAR2 DETERMINISTIC
IS
 c sa.customer_type := sa.customer_type();
BEGIN
 c.service_plan_days := c.get_service_plan_days_name (i_esn => i_esn,
 i_pin => i_pin,
 i_service_plan_objid => i_service_plan_objid);
 RETURN c.service_plan_days;
END get_service_plan_days_name;


FUNCTION get_transaction_status(i_esn IN VARCHAR2)
RETURN VARCHAR2 DETERMINISTIC
IS
 c_ota_pending VARCHAR2(1);
 c_carrier_pending VARCHAR2(1);
 c_port_in_progress VARCHAR2(1);
 c_ig_order_type VARCHAR2(1);
 --
 CURSOR ig_order_type_cur(i_esn IN VARCHAR2)
 IS
 SELECT CASE order_type
 WHEN 'E' THEN 'UPGRADE IN PROGRESS'
 WHEN 'SIMC' THEN 'SIM CHANGE IN PROGRESS'
 WHEN 'MINC' THEN 'MIN CHANGE IN PROGRESS'
			 WHEN 'A' THEN 'REACTIVATION IN PROGRESS'
 END upgrade_in_progress
 FROM gw1.ig_transaction
 WHERE esn = i_esn
 AND transaction_id = (SELECT /*+ use_invisible_indexes */ MAX(transaction_id)
 FROM gw1.ig_transaction
 WHERE esn = i_esn
 AND order_type <> 'APN'
 );
 ig_order_type_cur_rec ig_order_type_cur%ROWTYPE;

BEGIN --Main section

 BEGIN
 SELECT 'Y'
 INTO c_ota_pending
 FROM table_part_inst pi
 WHERE 1 = 1
 AND pi.part_serial_no = i_esn
 AND pi.x_domain = 'PHONES'
 AND EXISTS
 (SELECT 1
 FROM table_x_ota_transaction ot,
 table_x_call_trans ct
 WHERE pi.part_serial_no = ot.x_esn
 AND ot.x_ota_trans2x_call_trans = ct.objid
 AND ot.x_status = 'OTA PENDING'
 AND ot.x_action_type IN (1,3,6,7) --CR55236 TW web common standards,added x_action_type 7
 );
 EXCEPTION
 WHEN OTHERS THEN
 c_ota_pending := 'N';
 END;

BEGIN
 SELECT DISTINCT 'Y'
 INTO c_carrier_pending
 FROM
 (SELECT 'Y'
 FROM table_part_inst pi,
 table_site_part sp,
 table_x_call_trans ct,
 x_switchbased_transaction sbt
 WHERE ct.call_trans2site_part = sp.objid
 AND ct.x_action_type IN (1,3,6)
 AND pi.part_serial_no = sp.x_service_id
 AND pi.x_domain = 'PHONES'
 AND pi.part_serial_no = i_esn
 AND sp.part_status||'' = 'CarrierPending'
 AND ct.objid = sbt.x_sb_trans2x_call_trans
 AND ct.x_transact_date = (SELECT MAX(x_transact_date)
 FROM table_x_call_trans
 WHERE x_action_type IN (1,3,6)
 AND x_service_id = i_esn
 )
 UNION
 SELECT 'Y'
 FROM table_x_call_trans ct,
 x_switchbased_transaction sbt
 WHERE ct.objid = sbt.x_sb_trans2x_call_trans
 AND sbt.status = 'CarrierPending'
 AND ct.x_action_type IN (1,3,6)
 AND ct.x_service_id = i_esn
 AND ct.x_transact_date =(SELECT MAX(x_transact_date)
 FROM table_x_call_trans
 WHERE x_action_type IN (1,3,6)
 AND x_service_id = i_esn
 )
 );
EXCEPTION
 WHEN OTHERS THEN
 c_carrier_pending := 'N';
END;

 BEGIN
 SELECT DECODE(x_port_in,1,'Y','N')
 INTO c_port_in_progress
 FROM table_part_inst
 WHERE part_serial_no = i_esn
 AND x_domain ='PHONES';
 EXCEPTION
 WHEN OTHERS THEN
 NULL;
 END;

 IF c_port_in_progress = 'Y' THEN
 RETURN 'PORT IN PROGRESS';
 ELSIF sa.util_pkg.get_min_by_esn ( i_esn => i_esn ) like 'T%' THEN
 RETURN 'ACTIVATION IN PROGRESS';
 ELSIF c_carrier_pending = 'Y' THEN
	 OPEN ig_order_type_cur(i_esn);
 FETCH ig_order_type_cur INTO ig_order_type_cur_rec;
 CLOSE ig_order_type_cur;
	 --
	 IF ig_order_type_cur_rec.upgrade_in_progress IS NOT NULL THEN
	 RETURN ig_order_type_cur_rec.upgrade_in_progress;
	 END IF;

 RETURN 'CARRIERPENDING';
 --
 ELSIF c_ota_pending = 'Y' THEN
 RETURN 'OTAPENDING';
 ELSE
 RETURN NULL;
 END IF;
--
END get_transaction_status;
--

FUNCTION get_carrier_name ( i_sim_serial IN VARCHAR2 DEFAULT NULL,
 i_esn IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 DETERMINISTIC
IS
 lv_sim_serial VARCHAR2(30);
 lv_sim_part_num VARCHAR2(30);
 lv_phone_carrier VARCHAR2(300);
BEGIN
 IF i_sim_serial IS NULL AND i_esn IS NULL
 THEN
 RETURN 'Both SIM serial and ESN can not be null. Pass ESN or SIM serial.';
 END IF;

 IF i_sim_serial IS NOT NULL
 THEN
 lv_sim_serial := i_sim_serial;
 ELSE
 BEGIN
 --Get SIM serial no from ESN
 SELECT x_iccid
 INTO lv_sim_serial
 FROM table_part_inst
 WHERE part_serial_no = i_esn
 AND x_domain = 'PHONES';
 EXCEPTION
 WHEN OTHERS
 THEN
 RETURN 'Given ESN could not be found';
 END;
 END IF;

 --Get SIM part number
 SELECT pn.part_number
 INTO lv_sim_part_num
 FROM table_x_sim_inv sim,
 table_mod_level ml,
 table_part_num pn
 WHERE 1 = 1
 AND ml.part_info2part_num = pn.objid
 AND sim.x_sim_inv2part_mod = ml.objid
 AND sim.x_sim_serial_no = lv_sim_serial;

 SELECT sa.util_pkg.get_short_parent_name(carrier_name)
 INTO lv_phone_carrier
 FROM (SELECT *
 FROM carriersimpref
 WHERE sim_profile = lv_sim_part_num
 ORDER BY rank ASC)
 WHERE rownum = 1;

 RETURN lv_phone_carrier;
EXCEPTION
 WHEN OTHERS
 THEN
 RETURN SUBSTR(SQLERRM, 1, 2000);
END get_carrier_name;


FUNCTION get_sim_status ( i_sim_serial IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC
IS
 lv_sim_status VARCHAR2(30);
BEGIN
 IF i_sim_serial IS NULL
 THEN
 RETURN 'SIM serial is not passed';
 END IF;

 --Get SIM status
 SELECT ct.x_code_name
 INTO lv_sim_status
 FROM table_x_sim_inv si,
 table_x_code_table ct
 WHERE si.x_sim_inv_status = ct.x_code_number
 AND ct.x_code_type = 'SIM'
 AND si.x_sim_serial_no = i_sim_serial;

 RETURN lv_sim_status;
EXCEPTION
 WHEN OTHERS
 THEN
 RETURN SUBSTR(SQLERRM, 1, 2000);
END get_sim_status;

FUNCTION get_sim_legacy_flag (i_sim IN VARCHAR2)RETURN VARCHAR2 DETERMINISTIC
IS
--
 c_sim_legacy_flag VARCHAR2(1);
BEGIN
 --
 SELECT wssm.legacy_flag
 INTO c_sim_legacy_flag
 FROM table_part_num pn,
 table_mod_level ml,
 table_x_sim_inv si,
 wfmmig.x_wfm_sim_sku_mapping wssm
 WHERE 1 = 1
 AND pn.objid = ml.part_info2part_num
 AND ml.objid = si.x_sim_inv2part_mod
 AND si.x_sim_serial_no = i_sim
 AND wssm.tf_partnum = pn.s_part_number
 AND rownum =1;
 --
 RETURN NVL(c_sim_legacy_flag,'N');
 --
EXCEPTION
 WHEN OTHERS THEN
 c_sim_legacy_flag := 'N';
 RETURN c_sim_legacy_flag;
END get_sim_legacy_flag;

FUNCTION get_service_forecast_due_date (i_esn IN VARCHAR2) RETURN DATE DETERMINISTIC
IS
 c sa.customer_type := sa.customer_type( );
 queued_cards customer_queued_card_tab := customer_queued_card_tab( );
 l_expire_dt DATE;
 ln_queued_service_days NUMBER;
BEGIN

 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;

 l_expire_dt := c.Get_expiration_date ( i_esn => i_esn );
 queued_cards := sa.customer_info.Get_esn_queued_cards ( i_esn => i_esn );

 SELECT NVL(SUM(queued_days),0)
 INTO ln_queued_service_days
 FROM TABLE(Cast( queued_cards AS CUSTOMER_QUEUED_CARD_TAB ));

 l_expire_dt := l_expire_dt + ln_queued_service_days;

 RETURN l_expire_dt;

END get_service_forecast_due_date;

--CR49696 start
FUNCTION is_valid_zip_code (i_zip_code IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC
IS
 c_valid_zip_code VARCHAR2(1);
BEGIN
 BEGIN
 SELECT 'Y'
 INTO c_valid_zip_code
 FROM table_x_zip_code
 WHERE x_zip = i_zip_code
 AND rownum = 1;
 EXCEPTION
 WHEN OTHERS THEN
 c_valid_zip_code := 'N';
 END;

 RETURN NVL(c_valid_zip_code, 'N');
EXCEPTION
 WHEN OTHERS THEN
 RETURN 'N';
END is_valid_zip_code;
--CR49696 end

-- CR49721 WFM Changes Added new function to get redemption date.
FUNCTION get_last_addon_redemption_date ( i_esn IN VARCHAR2 ) RETURN DATE DETERMINISTIC IS

-- cst customer_type := SELF;
-- c customer_type := customer_type();
 c_device_type VARCHAR2(100);
 l_last_redemption_date DATE;
 c_min VARCHAR2(50);
 l_install_date DATE;

BEGIN
 BEGIN
 SELECT NVL(vw.device_type,'FEATURE_PHONE')
 INTO c_device_type
 FROM table_part_inst pi,
 table_mod_level ml,
 table_part_num pn,
 table_part_class pc,
 sa.pcpv_mv vw
 WHERE pi.part_serial_no = i_esn
 AND pi.n_part_inst2part_mod= ml.objid
 AND ml.part_info2part_num = pn.objid
 AND pn.part_num2part_class = pc.objid
 AND pc.name = vw.part_class;
 EXCEPTION
 WHEN OTHERS THEN
 c_device_type := 'FEATURE_PHONE';
 END;

 IF c_device_type IN ('WIRELESS_HOME_PHONE', 'FEATURE_PHONE') THEN
 BEGIN
 SELECT MAX(ct.x_transact_date)
 INTO l_last_redemption_date
 FROM table_x_call_trans ct
 WHERE x_service_id = i_esn
 AND x_action_type+0 in ( 1, 3, 6)
 AND x_result = 'Completed';
 --
 RETURN l_last_redemption_date;
 EXCEPTION
 WHEN OTHERS THEN
 RETURN NULL;
 END;
 END IF;

 -- Get the min and install date
 BEGIN
 SELECT min,
 install_date
 INTO c_min,
 l_install_date
 FROM ( SELECT x_min min,
 install_date
 FROM table_site_part
 WHERE x_service_id = i_esn
 ORDER BY install_date DESC
 )
 WHERE ROWNUM = 1;
 EXCEPTION
 WHEN OTHERS THEN
 RETURN NULL;
 END;

 FOR all_esns IN ( SELECT x_service_id, install_date, part_status
 FROM table_site_part tsp
 WHERE x_min = c_min
 -- AND NOT EXISTS ( SELECT 1
 -- FROM table_site_part
 -- WHERE x_min = tsp.x_min
 -- AND x_service_id = tsp.x_service_id
 -- AND x_service_id = i_exclude_esn
 -- )
 ORDER BY install_date DESC
 )
 LOOP
 SELECT MAX(x_transact_date)
 INTO l_last_redemption_date
 FROM ( WITH esns AS ( SELECT esn
 FROM x_account_group_member
 WHERE account_group_id in ( SELECT account_group_id
 FROM x_account_group_member
 WHERE UPPER(status) <> 'EXPIRED'
 AND esn = all_esns.x_service_id
 )
 UNION
 SELECT part_serial_no
 FROM table_part_inst
 WHERE part_serial_no = all_esns.x_service_id
 ) ,
 pph AS ( SELECT /*+ ORDERED */
 ppd.x_esn esn,hdr.x_rqst_date -- ppd.*, ppd.x_esn,tsp.x_min,sp.objid
 FROM x_program_purch_dtl ppd,
 x_program_purch_hdr hdr,
 x_program_enrolled pe,
 x_service_plan_site_part spsp,
 table_site_part tsp,
 x_program_parameters pp,
 mtm_sp_x_program_param mtm,
 x_service_plan sp
 WHERE 1 = 1
 AND hdr.x_ics_rflag in ('ACCEPT', 'SOK')
 AND NVL(hdr.x_ics_rcode,'0') IN ('1','100')
 AND ( hdr.x_merchant_id IS NOT NULL OR hdr.x_payment_type = 'LL_RECURRING' ) -- Exclude BML
 AND hdr.x_payment_type NOT IN ('REFUND', 'OTAPURCH') -- Exclude Refunds and mobile billing
 AND ppd.pgm_purch_dtl2prog_hdr = hdr.objid
 AND pe.objid = ppd.pgm_purch_dtl2pgm_enrolled
 AND spsp.table_site_part_id = pe.pgm_enroll2site_part
 AND tsp.objid = spsp.table_site_part_id
 AND pp.objid = pe.pgm_enroll2pgm_parameter
 AND mtm.x_sp2program_param = pp.objid
 AND mtm.program_para2x_sp = spsp.x_service_plan_id
 AND sp.objid = mtm.program_para2x_sp
 ) ,
 ct AS ( SELECT ct.x_service_id esn,
 ct.x_transact_date
 FROM table_x_call_trans ct
 WHERE ct.x_action_type+0 in ( 1, 3, 6)
 AND EXISTS ( SELECT 1
 FROM x_serviceplanfeaturevalue_def a,
 sa.mtm_partclass_x_spf_value_def b,
 sa.x_serviceplanfeaturevalue_def c,
 sa.mtm_partclass_x_spf_value_def d,
 x_serviceplanfeature_value spfv,
 x_service_plan_feature spf,
 x_service_plan sp
 WHERE a.objid = b.spfeaturevalue_def_id
 AND b.part_class_id in ( SELECT pn.part_num2part_class
 FROM table_x_red_card rc,
 -- validate there is a base service plan redemption from red card
 table_mod_level ml,
 table_part_num pn
 WHERE 1 = 1
 AND rc.red_card2call_trans = ct.objid
 AND ml.objid = rc.x_red_card2part_mod
 AND pn.objid = ml.part_info2part_num
 AND pn.domain = 'REDEMPTION CARDS'
 )
 -- Include the add on redemption
 --AND NOT EXISTS ( SELECT 1
 -- FROM sa.service_plan_feat_pivot_mv
 -- WHERE service_plan_objid = sp.objid
 -- AND service_plan_group = 'ADD_ON_DATA'
 -- )
 AND c.objid = d.spfeaturevalue_def_id
 AND d.part_class_id = ( SELECT pn.part_num2part_class
 FROM table_part_inst pi,
 table_mod_level ml,
 table_part_num pn
 WHERE 1 = 1
 AND pi.part_serial_no = ct.x_service_id
 AND pi.x_domain = 'PHONES'
 AND ml.objid = pi.n_part_inst2part_mod
 AND pn.objid = ml.PART_INFO2PART_NUM
 AND pn.domain = 'PHONES'
 )
 AND a.value_name = c.value_name
 AND spfv.value_ref = c.objid
 AND spf.objid = spfv.spf_value2spf
 AND sp.objid = spf.sp_feature2service_plan
 )
 )
 SELECT ct.*
 FROM ct,
 esns
 WHERE ct.esn = esns.esn
 UNION
 SELECT pph.*
 FROM esns,
 pph
 WHERE pph.esn = esns.esn
 );

 EXIT WHEN l_last_redemption_date IS NOT NULL;

 END LOOP;

 IF l_last_redemption_date IS NULL THEN
 SELECT MAX(x_transact_date)
 INTO l_last_redemption_date
 FROM table_x_call_trans ct
 WHERE x_action_type IN ( 1, 3, 6)
 AND x_service_id = i_esn;
 END IF;

 IF l_last_redemption_date IS NULL THEN
 SELECT MAX(install_date)
 INTO l_last_redemption_date
 FROM table_site_part sp
 WHERE x_service_id = i_esn;
 END IF;

 RETURN (l_last_redemption_date);

EXCEPTION
 WHEN others THEN
 RETURN NULL;
END get_last_addon_redemption_date;

FUNCTION get_esn_queue_card_days ( i_esn IN VARCHAR2 ) RETURN NUMBER DETERMINISTIC
IS
 queued_cards sa.customer_queued_card_tab := sa.customer_queued_card_tab();
 ln_queued_service_days NUMBER;
BEGIN
 queued_cards := sa.customer_info.get_esn_queued_cards (i_esn => i_esn);

 SELECT NVL(SUM(queued_days),0)
 INTO ln_queued_service_days
 FROM TABLE(CAST(queued_cards AS customer_queued_card_tab));

 RETURN NVL(ln_queued_service_days,0);
EXCEPTION
 WHEN others THEN
 RETURN NULL;
END get_esn_queue_card_days;

--CR51037 -WFM -Start
FUNCTION get_service_plan_group(i_plan_part_number IN VARCHAR2)
RETURN VARCHAR2 DETERMINISTIC
IS
c_service_plan_group VARCHAR2(30);
BEGIN

 SELECT spf.service_plan_group
 INTO   c_service_plan_group
 FROM   table_part_num                   pn   ,
        table_part_class                 pc   ,
        table_mod_level                  ml   ,
        service_plan_feat_pivot_mv       spf  ,
	sa.mtm_partclass_x_spf_value_def mtm  ,
	sa.x_serviceplanfeaturevalue_def spfvd,
	x_service_plan_feature           xspf ,
        x_service_plan                   sp   ,
	x_serviceplanfeature_value       spfv
 WHERE  pn.part_number            = i_plan_part_number
 AND    pn.part_num2part_class    = pc.objid
 AND    pc.objid                  = mtm.part_class_id
 AND    mtm.spfeaturevalue_def_id = spfvd.objid
 AND    spfv.value_ref            = spfvd.objid
 AND    xspf.objid                = spfv.spf_value2spf
 AND    sp.objid                  = xspf.sp_feature2service_plan
 AND    spf.service_plan_objid    = sp.objid
 AND    pn.objid                  = ml.part_info2part_num
 AND    pn.domain                 = 'REDEMPTION CARDS';

 RETURN c_service_plan_group;

EXCEPTION
  WHEN OTHERS THEN
       RETURN NULL;
END get_service_plan_group;

FUNCTION get_esn_pin_redeem_details(i_esn IN VARCHAR2 DEFAULT NULL,
                                    i_min IN VARCHAR2 DEFAULT NULL)
RETURN redeem_pin_details_tab DETERMINISTIC
IS
cst sa.customer_type  := sa.customer_type();
queued_cards          sa.customer_queued_card_tab := sa.customer_queued_card_tab();
redeem_pin_details    sa.redeem_pin_details_tab   := sa.redeem_pin_details_tab();
c_esn                 VARCHAR2(30);

BEGIN

 IF i_esn IS NULL AND i_min IS NULL THEN
    RETURN redeem_pin_details;
 ELSIF i_esn IS NULL AND i_min IS NOT NULL THEN
    c_esn := sa.customer_info.get_esn(i_min=> i_min);
 ELSE
    c_esn := i_esn;
 END IF;

 --Retrieve queued cards for given ESN
 queued_cards := cst.get_esn_queued_cards (i_esn => c_esn);

 SELECT  redeem_pin_details_type(pin             ,
                                 pin_part_number ,
				 pin_part_class  ,
				 pin_plan_type   ,
				 pin_service_days,
				 pin_status
				 )
 BULK COLLECT INTO redeem_pin_details
 FROM (SELECT
      sa.customer_info.convert_smp_to_pin(i_smp =>smp)                            pin            ,
      qc.part_number                                                              pin_part_number,
      (SELECT pc.name
       FROM  table_part_class pc,
	     table_part_num   pn
       WHERE pn.part_number         = qc.part_number
       AND   pn.part_num2part_class = pc.objid
       )                                                                          pin_part_class  ,
       sa.customer_info.get_service_plan_group(i_plan_part_number => part_number) pin_plan_type   ,
       NVL(queued_days,0)                                                         pin_service_days,
       'QUEUED'                                                                   pin_status
 FROM   TABLE(CAST(queued_cards AS customer_queued_card_tab)) qc
 UNION
  SELECT rc.x_red_code                                                                 pin             ,
         pn.part_number                                                                pin_part_number ,
         pc.name                                                                       pin_part_class  ,
         sa.customer_info.get_service_plan_group(i_plan_part_number => pn.part_number) pin_plan_type   ,
         ext.x_total_days                                                              pin_service_days,
	 'REDEEMED'                                                                    pin_status
 FROM   table_x_call_trans               ct ,
        table_x_call_trans_ext           ext,
        table_x_red_card                 rc ,
        table_part_num                   pn ,
        table_part_class                 pc ,
        table_mod_level                  ml
 WHERE  rc.red_card2call_trans    = ct.objid
 AND    pn.part_num2part_class    = pc.objid
 AND    ml.objid                  = rc.x_red_card2part_mod
 AND    pn.objid                  = ml.part_info2part_num
 AND    pn.domain                 = 'REDEMPTION CARDS'
 AND    ct.objid                  = ext.call_trans_ext2call_trans
 AND    ct.objid = ( SELECT MAX(objid)
                     FROM   table_x_call_trans xct
                     WHERE  x_action_type IN ( '1', '3', '6')
                     AND    x_service_id = c_esn
                     AND EXISTS ( SELECT 1
                                  FROM   x_serviceplanfeaturevalue_def       a,
                                         sa.mtm_partclass_x_spf_value_def    b,
                                         sa.x_serviceplanfeaturevalue_def    c,
                                         sa.mtm_partclass_x_spf_value_def    d,
                                         x_serviceplanfeature_value       spfv,
                                         x_service_plan_feature           spf ,
                                         x_service_plan                   sp
                                  WHERE  a.objid = b.spfeaturevalue_def_id
                                  AND    b.part_class_id in ( SELECT pn.part_num2part_class
                                                              FROM   table_x_red_card rc,
                                                              -- validate there is a base service plan redemption from red card
                                                                     table_mod_level ml,
                                                                     table_part_num  pn
                                                              WHERE  1 = 1
                                                              AND    rc.red_card2call_trans = xct.objid
                                                              AND    ml.objid               = rc.x_red_card2part_mod
                                                              AND    pn.objid               = ml.part_info2part_num
                                                              AND    pn.domain              = 'REDEMPTION CARDS'
                                                            )
                                  AND    c.objid = d.spfeaturevalue_def_id
                                  AND    d.part_class_id = ( SELECT pn.part_num2part_class
                                                             FROM   table_part_inst pi,
                                                                    table_mod_level ml,
                                                                    table_part_num  pn
                                                             WHERE  1 = 1
                                                             AND    pi.part_serial_no   = xct.x_service_id
                                                             AND    pi.x_domain         = 'PHONES'
                                                             AND    ml.objid            = pi.n_part_inst2part_mod
                                                             AND    pn.objid            = ml.part_info2part_num
                                                             AND    pn.domain           = 'PHONES'
                                                           )
                                  AND    a.value_name   = c.value_name
                                  AND    spfv.value_ref = c.objid
                                  AND    spf.objid      = spfv.spf_value2spf
                                  AND    sp.objid       = spf.sp_feature2service_plan
                                )
                   )
       );
 --
 RETURN redeem_pin_details;

EXCEPTION
  WHEN OTHERS THEN
       RETURN NULL;

END get_esn_pin_redeem_details;
--CR51037 -WFM -End

FUNCTION get_sub_brand_by_esn (i_esn IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC is
 c sa.customer_type := sa.customer_type();
BEGIN
 IF i_esn IS NULL THEN
 RETURN NULL;
 END IF;
 c.esn := i_esn;
 RETURN (c.get_sub_brand) ;
END get_sub_brand_by_esn;
FUNCTION get_next_charge_date (i_esn IN VARCHAR2) RETURN DATE
IS
o_next_refill_date DATE;
BEGIN

SELECT
              x_next_charge_date  into  o_next_refill_date
      FROM   ( SELECT
                      enr.x_next_charge_date
               FROM   x_program_enrolled enr
               WHERE  enr.x_esn = i_esn
               AND    x_enrollment_status IN ('ENROLLED','ENROLLMENTSCHEDULED')
           AND    x_next_charge_date > SYSDATE
               UNION ALL
               SELECT
                      enr.x_next_charge_date
               FROM   x_program_enrolled enr,
                      x_program_parameters pp
               WHERE  enr.x_esn =i_esn
               AND    x_enrollment_status = 'ENROLLED_NO_ACCOUNT'
             AND    x_next_charge_date > SYSDATE
               AND    enr.pgm_enroll2pgm_parameter = pp.objid
               AND    pp.x_prog_class||'' = 'WARRANTY'
              )
      WHERE  ROWNUM = 1;
          RETURN o_next_refill_date;
 EXCEPTION
WHEN others THEN
  RETURN NULL;
END get_next_charge_date;


--SM MLD changes Starts
FUNCTION get_shared_group_flag ( i_brand                IN VARCHAR2             ,
                                 i_esn                  IN VARCHAR2 DEFAULT NULL,
                                 i_min                  IN VARCHAR2 DEFAULT NULL,
                                 i_pin                  IN VARCHAR2 DEFAULT NULL,
                                 i_sim                  IN VARCHAR2 DEFAULT NULL,
                                 i_sp_objid             IN NUMBER   DEFAULT NULL,
                                 i_plan_part_number     IN VARCHAR2 DEFAULT NULL
                               ) RETURN VARCHAR2 DETERMINISTIC IS

  c sa.customer_type := sa.customer_type();

  CURSOR c_sp
  IS
    SELECT mv.sub_brand
    FROM   service_plan_feat_pivot_mv mv
    WHERE  (mv.service_plan_objid = i_sp_objid OR mv.plan_purchase_part_number = i_plan_part_number)
    AND    ROWNUM = 1;
  c_sp_rec c_sp%ROWTYPE;

  CURSOR c_pi
  IS
    SELECT pi.part_serial_no esn
    FROM   table_part_inst pi
    WHERE  pi.x_iccid = i_sim
    AND    ROWNUM = 1;
  c_pi_rec c_pi%ROWTYPE;

  CURSOR c_pin
  IS
    SELECT b.sub_brand
    FROM   adfcrm_serv_plan_class_matview a,
           service_plan_feat_pivot_mv b
    WHERE  a.sp_objid        = b.service_plan_objid
    AND    a.part_class_name = sa.bau_util_pkg.get_pin_part_class (i_pin)
    AND    ROWNUM = 1;
  c_pin_rec c_pin%ROWTYPE;

BEGIN
  CASE
      WHEN i_esn IS NOT NULL OR i_min IS NOT NULL THEN
         c.esn               := i_esn;
         c.min               := i_min;
         c.brand_shared_group_flag := get_shared_group_flag ( i_bus_org_id => NVL(c.get_sub_brand,i_brand)  ) ;
      WHEN i_sp_objid IS NOT NULL OR i_plan_part_number IS NOT NULL THEN
         OPEN c_sp;
         FETCH c_sp INTO  c_sp_rec;
         CLOSE c_sp;
         c.brand_shared_group_flag := get_shared_group_flag ( i_bus_org_id => NVL(c_sp_rec.sub_brand,i_brand)  );
      WHEN i_sim IS NOT NULL THEN
         OPEN c_pi;
         FETCH c_pi INTO  c_pi_rec;
         CLOSE c_pi;
         c.esn               :=  c_pi_rec.esn;
         c.brand_shared_group_flag :=  get_shared_group_flag ( i_bus_org_id => NVL(c.get_sub_brand,i_brand)  );
      WHEN i_pin IS NOT NULL THEN
         OPEN c_pin;
         FETCH c_pin INTO  c_pin_rec;
         CLOSE c_pin;
         c.brand_shared_group_flag := get_shared_group_flag ( i_bus_org_id => NVL(c_pin_rec.sub_brand,i_brand) );
      ELSE
         c.brand_shared_group_flag :=  get_shared_group_flag ( i_bus_org_id => i_brand  );
  END CASE;

  RETURN NVL(c.brand_shared_group_flag,'N');
END;

FUNCTION get_part_class ( i_part_num IN VARCHAR2 ) RETURN VARCHAR2
IS
  cst sa.customer_type  := sa.customer_type();
BEGIN
  -- return "Y" for WARP otherwise "N"
  cst.part_class_name := cst.get_part_class (i_part_num => i_part_num);
  RETURN cst.part_class_name;
END get_part_class;

--SM MLD changes Ends

-- CR54110 (defect# 31410)
-- function to get the program enrolled record for a given ESN
-- function created to return the sourcesystem of the program enrolled table
FUNCTION get_program_enrollment ( i_esn IN VARCHAR2 ) RETURN program_enrolled_type
IS
  -- call constructor to return the data
  pet  program_enrolled_type := program_enrolled_type ( i_esn => i_esn );
BEGIN
  -- return the program enrolled row type
  RETURN pet;
END get_program_enrollment;

-- function to return the sourcesystem of program enrollment for a given ESN
-- CR54110 (defect# 31410)
FUNCTION is_warp_sourcesystem ( i_esn IN VARCHAR2 ) RETURN VARCHAR2
IS
  pe program_enrolled_type := program_enrolled_type ( i_esn => i_esn );
BEGIN
  -- return "Y" for WARP otherwise "N"
  RETURN ( CASE pe.sourcesystem WHEN 'WARP' THEN 'Y' ELSE 'N' END );
END is_warp_sourcesystem;
-- New function used to get the autorefill status
FUNCTION isautorefill ( i_esn IN VARCHAR2 ) RETURN NUMBER
IS
  --
  CURSOR get_autorefill ( ip_site_part_objid IN NUMBER ,
                          ip_part_inst_objid IN NUMBER )
  IS
    SELECT pp.x_charge_frq_code autorefill
    FROM   sa.x_program_parameters pp
    WHERE  pp.objid = ( SELECT MAX(pe.pgm_enroll2pgm_parameter) -- find latest objid
                        FROM   sa.x_program_enrolled pe
                        WHERE  1 = 1
                        AND    pe.pgm_enroll2site_part = ip_site_part_objid
                        AND    pe.pgm_enroll2part_inst = ip_part_inst_objid
                        AND    pe.x_enrollment_status = 'ENROLLED'
  	                    AND    NOT EXISTS ( SELECT NULL
				 	                                  FROM   sa.x_program_parameters PP_2
                                            WHERE  1 = 1
                                            AND    PP_2.OBJID = pe.pgm_enroll2pgm_parameter
                                            AND    ( PP_2.x_charge_frq_code = 'LOWBALANCE'
                                                     OR
                                                     pp_2.x_prog_class IN ( SELECT x_param_value
                                                                            FROM   sa.table_x_parameters
                                                                            WHERE  x_param_name = 'NON_BASE_PROGRAM_CLASS'
                                                                          )
                                                   )
                                          )
                      );

  get_autorefill_rec get_autorefill%ROWTYPE;
  c                  sa.customer_type := sa.customer_type ( i_esn => i_esn );
  cst                sa.customer_type;
  n_autorefill       NUMBER;
BEGIN
  -- get the site part and esn part inst objid
  cst := c.get_service_plan_attributes;
  --
  OPEN get_autorefill(cst.site_part_objid, cst.esn_part_inst_objid);
  FETCH get_autorefill INTO get_autorefill_rec;
  IF get_autorefill%FOUND AND
     NVL(get_autorefill_rec.autorefill ,' ') != ' '
  THEN
    n_autorefill := 1;
  ELSE
    n_autorefill := 0;
  END IF;
  CLOSE get_autorefill;

  RETURN n_autorefill;

 EXCEPTION
 WHEN OTHERS
 THEN
   n_autorefill := 0;
END isautorefill;

-- CR55836 Begin
FUNCTION get_pin_redeem_days (i_pin IN VARCHAR2) RETURN NUMBER IS
  c sa.customer_type := sa.customer_type();
BEGIN

  IF i_pin IS NULL
  THEN
    RETURN NULL;
  END IF;

 RETURN c.get_pin_redeem_days ( i_pin => i_pin);

END get_pin_redeem_days;
-- CR55836 End

END CUSTOMER_INFO;
/