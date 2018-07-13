CREATE OR REPLACE PACKAGE BODY sa."PHONE_PKG" AS
/****************************************************************************************************/
/***************************************************************************************************/

PROCEDURE Validate_phone_prc(p_esn IN VARCHAR2,
p_source_system IN VARCHAR2,
-- CHANNEL (CHANNEL TABLE)
p_brand_name IN VARCHAR2,
--BRAND NAME (BUS ORG TABLE)
p_part_inst_objid OUT VARCHAR2 ,
p_code_number OUT VARCHAR2 ,
p_code_name OUT VARCHAR2 ,
p_redemp_reqd_flg OUT NUMBER ,
p_warr_end_date OUT VARCHAR2 ,
p_phone_model OUT VARCHAR2 ,
p_phone_technology OUT VARCHAR2 ,
p_phone_description OUT VARCHAR2 ,
p_esn_brand OUT VARCHAR2 ,
p_zipcode OUT VARCHAR2 ,
p_pending_red_status OUT VARCHAR2 ,
p_click_status OUT VARCHAR2 ,
p_promo_units OUT NUMBER ,
p_promo_access_days OUT NUMBER ,
p_num_of_cards OUT NUMBER ,
p_pers_status OUT VARCHAR2 ,
p_contact_id OUT VARCHAR2 ,
p_contact_phone OUT VARCHAR2 ,
p_errnum OUT VARCHAR2 ,
p_errstr OUT VARCHAR2 ,
p_sms_flag OUT NUMBER ,
p_part_class OUT VARCHAR2 ,
p_parent_id OUT VARCHAR2 ,
p_extra_info OUT VARCHAR2 ,
p_int_dll OUT NUMBER ,
p_contact_email OUT VARCHAR2 ,
p_min OUT VARCHAR2 ,
p_manufacturer OUT VARCHAR2 ,
p_seq OUT NUMBER ,
p_iccid OUT VARCHAR2 ,
p_iccid_flag OUT VARCHAR2 ,
p_last_call_trans OUT VARCHAR2 ,
p_safelink_esn OUT VARCHAR2 )
AS

tct code_table_type := code_table_type ();

CURSOR carrier_pending_cur(
p_esn IN VARCHAR2) IS
SELECT pi.part_serial_no ,
pi.x_part_inst_status ,
pi.x_part_inst2contact ,
sp.part_status ,
sp.x_min ,
sp.x_zipcode ,
ct.objid ct_objid
FROM table_part_inst pi ,
table_site_part sp ,
table_x_call_trans ct
WHERE ct.call_trans2site_part = sp.objid
AND ct.x_action_type = '1'
AND pi.part_serial_no = sp.x_service_id
AND pi.x_domain = 'PHONES'
AND pi.part_serial_no = p_esn
AND pi.x_part_inst_status IN ('50' ,'150')
AND sp.part_status
|| '' = 'CarrierPending'
AND ct.x_transact_date IN (SELECT Max(x_transact_date)
FROM table_x_call_trans
WHERE x_action_type = '1'
AND x_service_id = p_esn);
carrier_pending_rec carrier_pending_cur%ROWTYPE;
CURSOR carrier_pending_react_cur(
p_esn IN VARCHAR2) IS
SELECT pi.part_serial_no ,
pi.x_part_inst_status ,
pi.x_part_inst2contact ,
sp.part_status ,
sp.x_min ,
sp.x_zipcode ,
ct.objid ct_objid
FROM table_part_inst pi ,
table_site_part sp ,
table_x_call_trans ct
WHERE ct.call_trans2site_part = sp.objid
AND ct.x_action_type = '3'
AND pi.part_serial_no = sp.x_service_id
AND pi.x_domain = 'PHONES'
AND pi.part_serial_no = p_esn
AND pi.x_part_inst_status IN ('51' ,'54')
AND sp.part_status
|| '' = 'CarrierPending'
AND ct.x_transact_date IN (SELECT Max(x_transact_date)
FROM table_x_call_trans
WHERE x_action_type = '3'
AND x_service_id = p_esn);
carrier_pending_react_rec carrier_pending_react_cur%ROWTYPE;
CURSOR activation_pending_cur(
p_esn IN VARCHAR2) IS
SELECT pi.part_serial_no ,
pi.x_part_inst_status ,
pi.x_part_inst2contact ,
sp.part_status ,
sp.x_min ,
sp.x_zipcode ,
ct.objid ct_objid
FROM table_part_inst pi ,
table_site_part sp ,
table_x_call_trans ct
WHERE ct.call_trans2site_part = sp.objid
AND ct.x_action_type = '1'
AND pi.part_serial_no = sp.x_service_id
AND pi.x_domain = 'PHONES'
AND pi.part_serial_no = p_esn
AND pi.x_part_inst_status IN ('50' ,'150')
AND sp.part_status = 'Active'
AND ct.x_transact_date IN (SELECT Max(x_transact_date)
FROM table_x_call_trans
WHERE x_action_type = '1'
AND x_service_id = p_esn);
activation_pending_rec activation_pending_cur%ROWTYPE;
CURSOR part_inst_cur(
p_esn IN VARCHAR2) IS
SELECT pi.objid ,
pi.warr_end_date ,
pi.x_port_in ,
ct.x_code_number ,
ct.x_code_name ,
pi.pi_tag_no ,
ct.x_value ,
pi.hdr_ind ,
pi.x_sequence ,
pi.x_iccid ,
pi.x_hex_serial_no --ACMI ACME
,
(SELECT x_sim_req
FROM table_x_ota_params_2 ,
table_bus_org
WHERE x_source_system = p_source_system
AND ota_param2bus_org = table_bus_org.objid
AND org_id = p_brand_name) x_iccid_flag
FROM table_part_inst pi ,
table_x_code_table ct
WHERE pi.part_serial_no = p_esn
AND pi.x_domain = 'PHONES'
AND pi.status2x_code_table = ct.objid;
part_inst_rec part_inst_cur%ROWTYPE;
CURSOR get_phone_info_cur(
p_esn IN VARCHAR2) IS
SELECT pn.part_number ,
pn.x_technology ,
pn.description ,
bo.org_id ,
bo.loc_type ,
pn.x_dll ,
pi.x_part_inst_status ,
NVL(pn.prog_type ,0) prog_type ,
pn.x_manufacturer ,
pn.x_data_capable ,
sa.Get_param_by_name_fun(pc.name, 'NON_PPE') non_ppe_flag
-- CR17003 Net 10 Sprint
FROM table_part_inst pi ,
table_mod_level ml ,
table_part_num pn ,
table_bus_org bo ,
table_part_class pc -- CR17003 Net 10 Sprint
WHERE pi.n_part_inst2part_mod = ml.objid
AND ml.part_info2part_num = pn.objid
AND pi.part_serial_no = p_esn
AND pi.x_domain = 'PHONES'
AND bo.objid = pn.part_num2bus_org
AND pc.objid = pn.part_num2part_class;
get_phone_info_rec get_phone_info_cur%ROWTYPE;
CURSOR pers_lac_cur (
p_esn IN VARCHAR2,
p_tech IN VARCHAR2 ) IS
SELECT sid.*
FROM table_x_sids sid ,
table_x_lac l ,
table_x_carr_personality cp ,
table_part_inst pi
WHERE sid.x_sid_type = p_tech
AND sid.sids2personality = cp.objid
AND l.lac2personality = cp.objid
AND l.x_local_area_code = To_number(Decode(Instr(pi.x_npa, 'T'), 0
, pi.x_npa,
Substr(pi.x_npa, 2)
))
AND cp.objid = pi.part_inst2x_pers
AND pi.part_serial_no = p_esn
ORDER BY sid.x_index ASC;
pers_lac_rec pers_lac_cur%ROWTYPE;
CURSOR product_part_cur(
p_esn IN VARCHAR2) IS
SELECT *
FROM table_site_part
WHERE x_service_id = p_esn
AND part_status = 'Active';
product_part_rec product_part_cur%ROWTYPE;
/*CR33864 ATT Carrier switch cursor declaration start */
CURSOR product_part_cur_sw(
p_esn IN VARCHAR2 ) IS
SELECT *
FROM TABLE_SITE_PART
WHERE x_service_id = p_esn;
/*CR33864 ATT Carrier switch cursor declaration end */
CURSOR promo_cur(
p_sp_objid IN NUMBER) IS
SELECT p.x_promo_code ,
p.x_promo_type ,
p.x_units ,
p.x_access_days ,
p.x_english_short_text
FROM table_site_part sp ,
table_x_promotion p ,
table_x_pending_redemption pr
WHERE pr.x_pend_red2site_part = sp.objid
AND pr.pend_red2x_promotion = p.objid
AND sp.objid = p_sp_objid;
promo_rec promo_cur%ROWTYPE;
CURSOR new_plan_cur(
p_sp_objid IN NUMBER) IS
SELECT cp.objid
FROM table_site_part sp ,
table_x_click_plan cp
WHERE sp.site_part2x_new_plan = cp.objid
AND sp.objid = p_sp_objid;
new_plan_rec new_plan_cur%ROWTYPE;
CURSOR contact_pi_cur(
p_esn IN VARCHAR2) IS
SELECT c.*
FROM table_part_inst pi ,
table_contact c
WHERE pi.x_part_inst2contact = c.objid
AND pi.part_serial_no = p_esn
AND x_domain = 'PHONES';
contact_pi_rec contact_pi_cur%ROWTYPE;
CURSOR contact_sp_cur(
p_sp_objid IN NUMBER) IS
SELECT c.*
FROM table_contact c ,
table_contact_role cr ,
table_site_part sp ,
table_site s
WHERE cr.contact_role2contact = c.objid
AND cr.contact_role2site = s.objid
AND sp.site_part2site = s.objid
AND sp.objid = p_sp_objid;
contact_sp_rec contact_sp_cur%ROWTYPE;
CURSOR cc_cur(
p_contact_objid IN NUMBER) IS
SELECT COUNT(*) count_cc
FROM table_x_credit_card cc ,
mtm_contact46_x_credit_card3 mtm
WHERE mtm.mtm_contact2x_credit_card = p_contact_objid
AND mtm.mtm_credit_card2contact = cc.objid
AND cc.x_card_status = 'ACTIVE';
cc_rec cc_cur%ROWTYPE;
CURSOR pi_min_cur(
p_min IN VARCHAR2) IS
SELECT *
FROM table_part_inst
WHERE part_serial_no = p_min
AND x_domain = 'LINES';
pi_min_rec pi_min_cur%ROWTYPE;
CURSOR new_pers_cur(
pi_min_objid IN NUMBER) IS
SELECT cp.*
FROM table_part_inst pi ,
table_x_carr_personality cp
WHERE pi.part_inst2x_new_pers = cp.objid
AND pi.objid = pi_min_objid;
new_pers_rec new_pers_cur%ROWTYPE;
CURSOR old_pers_cur(
pi_min_objid IN NUMBER) IS
SELECT cp.*
FROM table_part_inst pi ,
table_x_carr_personality cp
WHERE pi.part_inst2x_pers = cp.objid
AND pi.objid = pi_min_objid;
old_pers_rec old_pers_cur%ROWTYPE;
CURSOR getpers2sid_cur (
p_pers_objid IN NUMBER,
p_tech IN VARCHAR2 ) IS
SELECT sid.*
FROM table_x_sids sid ,
table_x_carr_personality cp
WHERE sid.sids2personality = cp.objid
AND cp.objid = p_pers_objid
AND sid.x_sid_type = p_tech
ORDER BY x_index ASC;
getpers2sid_rec getpers2sid_cur%ROWTYPE;
CURSOR get_oldsitepart_cur(
p_pi_objid IN VARCHAR2) IS
SELECT sp.*
FROM table_site_part sp ,
table_part_inst pi
WHERE sp.part_status <> 'Obsolete'
AND pi.x_part_inst2site_part = sp.objid
AND pi.objid = p_pi_objid
ORDER BY service_end_dt DESC;
get_oldsitepart_rec get_oldsitepart_cur%ROWTYPE;
CURSOR site_cur(
p_esn IN VARCHAR2) IS
SELECT s.*
FROM table_site s ,
table_inv_locatn il ,
table_inv_bin ib ,
table_part_inst pi
WHERE il.inv_locatn2site = s.objid
AND ib.inv_bin2inv_locatn = il.objid
AND pi.part_inst2inv_bin = ib.objid
AND pi.part_serial_no = p_esn;
site_rec site_cur%ROWTYPE;
CURSOR dealer_promo_cur(
p_site_objid IN NUMBER) IS
SELECT p.*
FROM table_x_promotion p ,
table_site s
WHERE s.dealer2x_promotion = p.objid
AND s.objid = p_site_objid
AND p.x_start_date <= SYSDATE
AND p.x_end_date >= SYSDATE;
dealer_promo_rec dealer_promo_cur%ROWTYPE;
CURSOR default_promo_cur(
p_tech IN VARCHAR2) IS
SELECT *
FROM table_x_promotion
WHERE x_is_default = 1
AND x_default_type = p_tech
AND x_start_date <= SYSDATE
AND x_end_date >= SYSDATE;
default_promo_rec default_promo_cur%ROWTYPE;
CURSOR activation_promo_used_curs(
p_esn IN VARCHAR2) IS
SELECT 'X'
FROM table_x_promo_hist ph ,
table_x_promotion p ,
table_x_call_trans xct ,
(SELECT tc.x_esn
FROM table_case tc ,
table_x_part_request pr
WHERE 1 = 1
AND tc.title = 'Defective Phone'
AND tc.objid = pr.request2case
AND pr.x_part_num_domain = 'PHONES'
AND pr.x_part_serial_no = p_esn) tab1
WHERE 1 = 1
AND p.x_is_default = 1
AND p.objid = ph.promo_hist2x_promotion
AND xct.objid = ph.promo_hist2x_call_trans
AND x_service_id = tab1.x_esn;
activation_promo_used_rec activation_promo_used_curs%ROWTYPE;
CURSOR get_oldsitepart_cur2(
p_esn IN VARCHAR2) IS
SELECT *
FROM table_site_part
WHERE x_service_id = p_esn
AND part_status <> 'Obsolete'
ORDER BY service_end_dt DESC;
get_oldsitepart_rec2 get_oldsitepart_cur2%ROWTYPE;
CURSOR get_pending_redemptions_cur(
p_esn IN VARCHAR2) IS
SELECT 'X'
FROM table_site_part sp ,
table_x_pending_redemption pend
WHERE sp.x_service_id = p_esn
AND sp.part_status = 'Active'
AND pend.x_pend_red2site_part = sp.objid
AND NOT EXISTS (SELECT 1
FROM table_x_promotion pr
WHERE pr.objid = pend.pend_red2x_promotion
AND pr.x_promo_type = 'Runtime'
AND x_revenue_type <> 'FREE');
get_pending_redemptions_rec get_pending_redemptions_cur%ROWTYPE;
CURSOR get_pending_repl_cur(
p_esn IN VARCHAR2) IS
SELECT 'X'
FROM table_part_inst pi ,
table_x_pending_redemption pend
WHERE pi.part_serial_no = p_esn
AND pend.pend_redemption2esn = pi.objid
AND pend.x_pend_type = 'REPL';
get_pending_repl_rec get_pending_repl_cur%ROWTYPE;
CURSOR c_sms_parent (
ip_tech IN VARCHAR2,
ip_data IN NUMBER ) IS
SELECT cf.x_sms ,
cp.x_parent_id
FROM table_x_parent cp ,
table_x_carrier_group cg ,
table_x_carrier ca ,
table_x_carrier_features cf ,
table_part_inst pi ,
table_site_part sp
WHERE sp.x_min = pi.part_serial_no
AND pi.part_inst2carrier_mkt = ca.objid
AND ca.carrier2carrier_group = cg.objid
AND cg.x_carrier_group2x_parent = cp.objid
AND cf.x_features2bus_org = (SELECT pn.part_num2bus_org
FROM table_part_num pn ,
table_mod_level ml ,
table_part_inst pi_esn
WHERE pn.objid = ml.part_info2part_num
AND
ml.objid = pi_esn.n_part_inst2part_mod
AND pi_esn.part_serial_no = p_esn
)
AND cf.x_feature2x_carrier = ca.objid
AND cf.x_technology = ip_tech
AND cf.x_data = ip_data
AND sp.x_service_id = p_esn
AND sp.part_status
|| '' = 'Active';
r_sms_parent c_sms_parent%ROWTYPE;
CURSOR c_part_class IS
SELECT pc.name
FROM table_part_class pc ,
table_part_num pn ,
table_mod_level ml ,
table_part_inst pi
WHERE pi.n_part_inst2part_mod = ml.objid
AND ml.part_info2part_num = pn.objid
AND pn.part_num2part_class = pc.objid
AND pi.part_serial_no = p_esn;
r_part_class c_part_class%ROWTYPE;
CURSOR c_orig_act_date(
p_esn IN VARCHAR2) IS
SELECT ( Decode(refurb_yes.is_refurb, 0, nonrefurb_act_date.init_act_date,
refurb_act_date.init_act_date) )
orig_act_date
FROM (SELECT Count(1) is_refurb
FROM table_site_part sp_a
WHERE sp_a.x_service_id = p_esn
AND sp_a.x_refurb_flag = 1) refurb_yes,
(SELECT MIN(install_date) init_act_date
FROM table_site_part sp_b
WHERE sp_b.x_service_id = p_esn
AND sp_b.part_status
|| '' IN ('Active' ,'Inactive')
AND Nvl(sp_b.x_refurb_flag, 0) <> 1) refurb_act_date,
(SELECT MIN(install_date) init_act_date
FROM table_site_part sp_c
WHERE sp_c.x_service_id = p_esn
AND sp_c.part_status
|| '' IN ( 'Active', 'Inactive' )) nonrefurb_act_date;
r_orig_act_date c_orig_act_date%ROWTYPE;
CURSOR c_reading_date(
p_esn IN VARCHAR2) IS
SELECT MAX(x_req_date_time) x_req_date_time
FROM table_x_zero_out_max
WHERE x_esn = p_esn
AND x_transaction_type = 1;
r_reading_date c_reading_date%ROWTYPE;
CURSOR c_account_exists(
p_esn IN VARCHAR2) IS
SELECT COUNT(*) cnt
FROM table_part_inst pi ,
table_x_contact_part_inst cp
WHERE pi.part_serial_no = p_esn
AND pi.objid = cp.x_contact_part_inst2part_inst;
r_account_exists c_account_exists%ROWTYPE;
CURSOR c_autopay_ac_exists(
p_esn IN VARCHAR2) IS
SELECT COUNT(*) cnt
FROM table_x_autopay_details
WHERE x_esn = p_esn
AND x_end_date IS NULL;
r_autopay_ac_exists c_autopay_ac_exists%ROWTYPE;
CURSOR c_enrollment_exists(
p_esn IN VARCHAR2) IS
SELECT Count(*) cnt
FROM table_x_ez_enrollment
WHERE x_esn = p_esn;
r_enrollment_exists c_enrollment_exists%ROWTYPE;
CURSOR get_esn_new_status_cur(
p_esn IN VARCHAR2) IS
SELECT ct.x_code_number ,
ct.x_code_name
FROM table_part_inst pi ,
table_x_code_table ct
WHERE pi.part_serial_no = p_esn
AND pi.x_domain = 'PHONES'
AND pi.status2x_code_table = ct.objid;
get_esn_new_status_rec get_esn_new_status_cur%ROWTYPE;
CURSOR site_part_curs(
p_esn VARCHAR2) IS
SELECT sp.x_min
FROM table_site_part sp ,
table_part_inst pi
WHERE pi.x_part_inst2site_part = sp.objid
AND pi.part_serial_no = p_esn;
site_part_rec site_part_curs%ROWTYPE;
CURSOR cur_is_esn_active IS
SELECT tpn.x_ota_allowed ,
txct.x_code_name ,
tpiesn.part_inst2carrier_mkt ,
tpn.objid ,
tpiesn.x_part_inst_status
FROM table_mod_level tml ,
table_part_num tpn ,
table_x_code_table txct ,
table_part_inst tpiesn
WHERE tpn.objid = tml.part_info2part_num
AND tml.objid = tpiesn.n_part_inst2part_mod
AND tpiesn.x_part_inst_status = txct.x_code_number
AND tpiesn.x_domain = 'PHONES'
AND txct.x_code_number = ota_util_pkg.esn_active
AND tpiesn.part_serial_no = p_esn;
CURSOR cur_is_carrier_ota_type IS
SELECT txp.x_ota_carrier
FROM table_part_inst tpiesn ,
table_part_inst tpimin ,
table_x_parent txp ,
table_x_carrier_group txcg ,
table_x_carrier txc ,
table_x_code_table txct
WHERE txc.objid = tpimin.part_inst2carrier_mkt
AND txp.objid = txcg.x_carrier_group2x_parent
AND txcg.objid = txc.carrier2carrier_group
AND tpiesn.objid = tpimin.part_to_esn2part_inst
AND tpimin.x_part_inst_status = txct.x_code_number
AND tpiesn.x_domain = 'PHONES'
AND tpimin.x_domain = 'LINES'
AND txct.x_code_number IN ( ota_util_pkg.msid_update
, ota_util_pkg.line_active
,
ota_util_pkg.pending_ac_change )
AND tpiesn.part_serial_no = p_esn;
CURSOR cur_get_ota_features IS
SELECT tof.x_handset_lock ,
tof.x_redemption_menu ,
tof.x_psms_destination_addr
FROM table_x_ota_features tof ,
table_part_inst tpi
WHERE tpi.objid = tof.x_ota_features2part_inst
AND tpi.part_serial_no = p_esn;
b_ota_activation BOOLEAN := FALSE;
CURSOR cur_is_ota_activation IS
SELECT tpn.x_ota_allowed ,
tpiesn.x_part_inst_status
FROM table_mod_level tml ,
table_part_num tpn ,
table_part_inst tpiesn
WHERE tpn.objid = tml.part_info2part_num
AND tml.objid = tpiesn.n_part_inst2part_mod
AND tpiesn.x_domain = 'PHONES'
AND x_part_inst_status IN (
ota_util_pkg.esn_new, ota_util_pkg.esn_refurbished,
ota_util_pkg.esn_used,
ota_util_pkg.esn_pastdue )
AND tpiesn.part_serial_no = p_esn;
CURSOR posa_info_cur(
p_site_id IN VARCHAR2) IS
SELECT pfd.posa_phone
FROM x_posa_flag_dealer pfd
WHERE pfd.site_id = p_site_id;
posa_info_rec posa_info_cur%ROWTYPE;
CURSOR cur_get_iccid_flag(
ip_source_system IN VARCHAR2) IS
SELECT x_sim_req
FROM table_x_ota_params_2 ,
table_bus_org
WHERE x_source_system = ip_source_system
AND ota_param2bus_org = table_bus_org.objid
AND org_id = p_brand_name;
get_iccid_flag_rec cur_get_iccid_flag%ROWTYPE;
-- BRAND_SEPARATION START
/*
-- CR8663 SWITCH
CURSOR cur_subsourcesystem (v_part_class_name IN VARCHAR2)
-- ,p_subsourcesystem IN VARCHAR2)
IS
select x_param_value
from
table_part_class pc, table_x_part_class_values pv, table_x_part_class_params pp
where pv.value2part_class=pc.objid
and pv.value2class_param=pp.objid
and x_param_name='NON_PPE'
and pc.name = v_part_class_name
and pv.x_param_value= '1' ; -- p_subsourcesystem ;
rec_subsourcesystem cur_subsourcesystem%ROWTYPE;
-- CR8663 SWITCH END
*/
CURSOR cur_input_brand IS
SELECT *
FROM table_bus_org
WHERE org_id = Upper(p_brand_name);
rec_input_brand cur_input_brand%ROWTYPE;
CURSOR cur_input_channel IS
SELECT *
FROM table_channel
WHERE title = p_source_system;
rec_input_channel cur_input_channel%ROWTYPE;
-- SAFELINK RE-QUALIFICATIONS IC 8/24/11
CURSOR cur_safelink_esn(
p_esn IN VARCHAR2) IS
SELECT x_current_esn ,
x_current_active
FROM x_sl_currentvals
WHERE x_current_esn = p_esn;
rec_safelink_esn cur_safelink_esn%ROWTYPE;
--CR17820 Start kacosta 3/28/2012
CURSOR get_min_status_curs(
c_v_esn table_part_inst.part_serial_no%TYPE) IS
SELECT tpi_min.x_part_inst_status
FROM table_part_inst tpi_esn
JOIN table_part_inst tpi_min
ON tpi_esn.objid = tpi_min.part_to_esn2part_inst
WHERE tpi_esn.part_serial_no = c_v_esn
AND tpi_esn.x_domain = 'PHONES'
AND tpi_min.x_domain = 'LINES';
--
get_min_status_rec get_min_status_curs%ROWTYPE;
--CR17820 End kacosta 3/28/2012
-- ACMI ACME project 11/06/2012
CURSOR acme_cur_pn(
v_esn IN VARCHAR2) IS
SELECT pn.part_number,
(SELECT COUNT(*)
FROM table_x_part_class_values v,
table_x_part_class_params n
WHERE value2class_param = n.objid
AND v.value2part_class =pn.part_num2part_class
AND n.x_param_name = 'OPERATING_SYSTEM'
AND upper(v.x_param_value)='IOS'
AND ROWNUM < 2)l_hex2dec_flag
FROM table_part_inst pi ,
table_mod_level ml ,
table_part_num pn
WHERE pi.n_part_inst2part_mod = ml.objid
AND ml.part_info2part_num = pn.objid
AND pi.part_serial_no = v_esn
AND pi.x_domain = 'PHONES';
ACME_rec_pn ACME_cur_pn%rowtype;
v_esn table_part_inst.part_serial_no%TYPE;
--ACMI ACME project 11/06/2012
-- UBRAND
CURSOR universal_cur (
p_esn VARCHAR2) IS
SELECT PART_NUMBER
FROM table_part_class pc,
table_bus_org bo,
table_part_num pn,
pc_params_view vw,
table_part_inst pi,
table_mod_level ml
WHERE pn.part_num2bus_org =bo.objid
AND pn.pArt_num2part_class =pc.objid
AND pc.name =vw.part_class
AND bo.org_id ='GENERIC'
AND vw.param_name ='BUS_ORG'
AND vw.param_value ='GENERIC'
AND PC.NAME <> 'GPPHONE'
AND pi.n_part_inst2part_mod=ml.objid
AND ml.part_info2part_num =pn.objid
AND pi.part_serial_no = p_esn ; --'100000000013245842'
UNIVERSAL_rec UNIVERSAL_cur%rowtype ;

--CR44729 GoSmart Migration
CURSOR not_migrated_cur(p_esn IN VARCHAR2)
IS
SELECT pi.part_serial_no ,
pi.x_part_inst_status ,
pi.x_part_inst2contact ,
sp.part_status ,
sp.x_min ,
sp.x_zipcode
FROM table_part_inst pi ,
table_site_part sp
WHERE pi.part_serial_no = sp.x_service_id
AND pi.x_domain = 'PHONES'
AND pi.part_serial_no = p_esn
--AND pi.x_part_inst_status IN ('160')
AND tct.get_migration_flag ( i_code_number => pi.x_part_inst_status ) = 'Y'
AND sp.install_date IN
(SELECT MAX(install_date)
FROM table_site_part
WHERE x_service_id = p_esn
);
not_migrated_rec not_migrated_cur%rowtype ;
--CR44729 GoSmart Migration

--CR35310 - Remove default activation promotions for TF --Start
--Declaration of Local variables
l_def_act_promo VARCHAR2(1) ;
l_non_ppe_flag NUMBER ;
l_serv_due_dt DATE ;
l_warr_end_dt DATE ;
l_expire_dt DATE ;
l_ct_rec_count NUMBER ;
l_partnum2part_class NUMBER ;
l_part_inst_status VARCHAR2(20);
--CR35310 - Remove default activation promotions for TF --End

--CR22799 LTE 4G
OP_SIM_STATUS VARCHAR2(30);
OP_X_ICCID NUMBER;
OP_ESN_STATUS VARCHAR2(20);
OP_ERROR_CODE NUMBER;
p_phone_brand VARCHAR2(50);
-- BRAND SEPARATION END
v_tech VARCHAR2(50);
v_temp_sp BOOLEAN;
v_cc_count NUMBER;
v_reading_found NUMBER := 0;
v_extra_info_1 VARCHAR2(20);
v_extra_info_2 VARCHAR2(20);
v_extra_info_3 VARCHAR2(20);
v_extra_info_4 VARCHAR2(20);
v_extra_info_5 VARCHAR2(20);
v_extra_info_6 VARCHAR2(20);
extra_info_7 CONSTANT NUMBER(1) := 1;
-- ota elements
v_extra_info_8 NUMBER(1);
v_extra_info_9 NUMBER(1);
v_extra_info_10 NUMBER(1);
v_extra_info_11 NUMBER(1);
v_extra_info_12 NUMBER(1);
v_extra_info_13 NUMBER(1);
--exchange element (Rev. 1.44)
v_extra_info_14 NUMBER(1);
--CR17820 Start kacosta 3/28/2012
V_EXTRA_INFO_15 NUMBER(1);
v_extra_info_16 NUMBER(1);--cr25490 B2B
l_v_min_status table_part_inst.x_part_inst_status%TYPE;
--CR17820 End kacosta 3/28/2012
v_tag_no NUMBER := 0;
v_code_value NUMBER := 0;
v_result NUMBER := 0;
v_repl_pend_flag NUMBER := 0;
v_hdr_ind NUMBER := 0;
v_sp_objid NUMBER := 0;
v_posa_phone VARCHAR(1);
p_err NUMBER;
p_msg VARCHAR2(50);
v_part_class_name VARCHAR2(30); -- CR8663 SWITCHBASE
v_non_ppe VARCHAR2(1) := '0';
TYPE sid_tab
IS TABLE OF table_x_sids.x_sid%TYPE INDEX BY BINARY_INTEGER;
v_old_sid sid_tab;
v_new_sid sid_tab;
old_counter INT := 1;
new_counter INT := 1;
v_esn_brand2 VARCHAR2(30);
/* CR33864 ATT CARRIER SWITCH Variable declaration start*/
OP_LAST_RATE_PLAN_SENT VARCHAR2(60);
OP_IS_SWB_CARR VARCHAR2(200);
OP_ERROR_CODE1 NUMBER;
OP_ERROR_MESSAGE VARCHAR2(200);
/* CR33864 ATT CARRIER SWITCH Variable declaration End*/
PROCEDURE close_open_cursors
IS
BEGIN
IF part_inst_cur%ISOPEN THEN
CLOSE part_inst_cur;
END IF;
IF get_esn_new_status_cur%ISOPEN THEN
CLOSE get_esn_new_status_cur;
END IF;
IF c_account_exists%ISOPEN THEN
CLOSE c_account_exists;
END IF;
IF c_autopay_ac_exists%ISOPEN THEN
CLOSE c_autopay_ac_exists;
END IF;
IF c_enrollment_exists%ISOPEN THEN
CLOSE c_enrollment_exists;
END IF;
IF c_part_class%ISOPEN THEN
CLOSE c_part_class;
END IF;
IF c_reading_date%ISOPEN THEN
CLOSE c_reading_date;
END IF;
IF c_orig_act_date%ISOPEN THEN
CLOSE c_orig_act_date;
END IF;
IF get_phone_info_cur%ISOPEN THEN
CLOSE get_phone_info_cur;
END IF;
IF product_part_cur%ISOPEN THEN
CLOSE product_part_cur;
END IF;
IF new_plan_cur%ISOPEN THEN
CLOSE new_plan_cur;
END IF;
IF contact_pi_cur%ISOPEN THEN
CLOSE contact_pi_cur;
END IF;
IF contact_sp_cur%ISOPEN THEN
CLOSE contact_sp_cur;
END IF;
IF cc_cur%ISOPEN THEN
CLOSE cc_cur;
END IF;
IF pi_min_cur%ISOPEN THEN
CLOSE pi_min_cur;
END IF;
IF new_pers_cur%ISOPEN THEN
CLOSE new_pers_cur;
END IF;
IF old_pers_cur%ISOPEN THEN
CLOSE old_pers_cur;
END IF;
IF pers_lac_cur%ISOPEN THEN
CLOSE pers_lac_cur;
END IF;
IF getpers2sid_cur%ISOPEN THEN
CLOSE getpers2sid_cur;
END IF;
IF c_sms_parent%ISOPEN THEN
CLOSE c_sms_parent;
END IF;
IF get_pending_repl_cur%ISOPEN THEN
CLOSE get_pending_repl_cur;
END IF;
IF get_pending_redemptions_cur%ISOPEN THEN
CLOSE get_pending_redemptions_cur;
END IF;
IF get_phone_info_cur%ISOPEN THEN
CLOSE get_phone_info_cur;
END IF;
IF site_cur%ISOPEN THEN
CLOSE site_cur;
END IF;
IF default_promo_cur%ISOPEN THEN
CLOSE default_promo_cur;
END IF;
IF dealer_promo_cur%ISOPEN THEN
CLOSE dealer_promo_cur;
END IF;
IF get_oldsitepart_cur%ISOPEN THEN
CLOSE get_oldsitepart_cur;
END IF;
IF contact_pi_cur%ISOPEN THEN
CLOSE contact_pi_cur;
END IF;
IF site_part_curs%ISOPEN THEN
CLOSE site_part_curs;
END IF;
IF pi_min_cur%ISOPEN THEN
CLOSE pi_min_cur;
END IF;
IF get_pending_repl_cur%ISOPEN THEN
CLOSE get_pending_repl_cur;
END IF;
IF contact_pi_cur%ISOPEN THEN
CLOSE contact_pi_cur;
END IF;
IF contact_sp_cur%ISOPEN THEN
CLOSE contact_sp_cur;
END IF;
IF site_part_curs%ISOPEN THEN
CLOSE site_part_curs;
END IF;
IF posa_info_cur%ISOPEN THEN
CLOSE posa_info_cur;
END IF;
IF activation_promo_used_curs%ISOPEN THEN
CLOSE activation_promo_used_curs;
END IF;
IF cur_get_iccid_flag%ISOPEN THEN
CLOSE cur_get_iccid_flag;
END IF;
IF carrier_pending_cur%ISOPEN THEN
CLOSE carrier_pending_cur;
END IF;
IF carrier_pending_react_cur%ISOPEN THEN
CLOSE carrier_pending_react_cur;
END IF;
IF activation_pending_cur%ISOPEN THEN
CLOSE activation_pending_cur;
END IF;
-- SAFELINK RE-QUALIFICATIONS IC 8/24/11
IF cur_safelink_esn%ISOPEN THEN
CLOSE cur_safelink_esn;
END IF;
--- ACMI ACME PROJECT 11/06/2012
IF ACME_cur_pn%ISOPEN THEN
CLOSE ACME_cur_pn;
END IF;
-- ACMI ACME PROJECT 11/06/2012
-- UBRAND
IF UNIVERSAL_cur%ISOPEN THEN
CLOSE UNIVERSAL_cur;
END IF;

--CR44729 GoSmart Migration
IF not_migrated_cur%ISOPEN THEN
CLOSE not_migrated_cur;
END IF;
--CR44729 GoSmart Migration
--BRAND SEPARATION START
/* * -- CR8663 SWITCH BASE
IF Cur_Subsourcesystem%ISOPEN
THEN
CLOSE Cur_Subsourcesystem;
END IF;
*/
--BRAND SEPARATION END
END close_open_cursors;

--CR35310: New function added to retrieve the redemption flag by passing ESN.
FUNCTION get_redemption_flag(i_esn IN VARCHAR2 ,
i_brand_name IN VARCHAR2)
RETURN NUMBER
IS
--Declaration of Local variables
l_def_act_promo VARCHAR2(1) ;
l_non_ppe_flag NUMBER ;
l_serv_due_dt DATE ;
l_warr_end_dt DATE ;
l_expire_dt DATE ;
l_ct_rec_count NUMBER ;
l_partnum2part_class NUMBER ;
l_part_inst_status VARCHAR2(20);
l_redemp_reqd_flg NUMBER ;

BEGIN --Main Section
l_redemp_reqd_flg := 1;
IF i_brand_name IN ('TRACFONE','NET10')THEN
BEGIN
SELECT x_expire_dt
INTO l_expire_dt
FROM (SELECT x_expire_dt
FROM table_site_part
WHERE x_service_id = i_esn
AND To_char(x_expire_dt, 'MM/DD/YYYY') <>
'01/01/1753'
ORDER BY update_stamp DESC)
WHERE ROWNUM = 1;
EXCEPTION
WHEN OTHERS THEN
NULL;
END;

-- Retrieving the warranty date and part class for given ESN
BEGIN SELECT CASE WHEN (l_expire_dt IS NOT NULL AND pi.warr_end_date IS
NOT
NULL
) THEN Greatest(l_expire_dt, pi.warr_end_date) WHEN (l_expire_dt IS NOT
NULL
AND
pi.warr_end_date IS NULL ) THEN l_expire_dt WHEN (l_expire_dt IS NULL AND
pi.warr_end_date IS NOT NULL ) THEN pi.warr_end_date ELSE NULL END
serv_due_dt,
pn.part_num2part_class, pi.x_part_inst_status INTO l_serv_due_dt,
l_partnum2part_class,
l_part_inst_status FROM table_part_inst pi, table_part_num pn,
table_mod_level
ml WHERE 1 = 1 AND pi.part_serial_no = i_esn AND pi.x_domain = 'PHONES'
AND
pi.n_part_inst2part_mod = ml.objid AND
Nvl(To_char(pi.warr_end_date, 'MM/DD/YYYY'), '01/01/9999') <>
'01/01/1753' AND ml.part_info2part_num = pn.objid; EXCEPTION WHEN
no_data_found
THEN l_serv_due_dt := l_expire_dt; WHEN too_many_rows THEN p_errstr :=
'More than 1 record exists for the given ESN';
--RETURN;
WHEN OTHERS THEN l_serv_due_dt := l_expire_dt; END; IF

l_partnum2part_class
IS
NOT NULL THEN
-- Retrieving the non ppe and default activation promo flag for given ESN
BEGIN SELECT pcpv.non_ppe non_ppe_flag,
Nvl(pcpv.apply_def_activation_promo, 'Y') def_act_promo INTO
l_non_ppe_flag,
l_def_act_promo FROM sa.pcpv_mv pcpv WHERE pc_objid =
l_partnum2part_class; EXCEPTION WHEN OTHERS THEN
-- Set default value to Y
l_def_act_promo := 'Y'; END; ELSE
-- Set default value to Y
l_def_act_promo := 'Y'; END IF;

-- Checking the record count for card on reserve for the given ESN.
SELECT Count(1) INTO l_ct_rec_count FROM table_part_inst esn,
table_part_inst
cards, table_mod_level ml, table_part_num pn WHERE esn.part_serial_no =
i_esn
AND esn.x_domain = 'PHONES' AND esn.objid = cards.part_to_esn2part_inst
AND
cards.x_part_inst_status = '400' AND cards.x_domain = 'REDEMPTION CARDS'
AND
cards.n_part_inst2part_mod = ml.objid AND ml.part_info2part_num =
pn.objid;
-- Validate the given ESN for below conditions
IF l_part_inst_status <> 52 THEN --Condition added for Emergency CR36788
--
IF Nvl(l_def_act_promo, 'Y') = 'Y' AND l_part_inst_status IN (50, 150) AND
l_non_ppe_flag = 0 THEN l_redemp_reqd_flg := 0; ELSIF l_non_ppe_flag = 0
AND
l_serv_due_dt > SYSDATE THEN l_redemp_reqd_flg := 0; ELSIF l_non_ppe_flag
=
1
AND l_serv_due_dt > SYSDATE THEN l_redemp_reqd_flg := 0; ELSIF
l_ct_rec_count >
0 THEN l_redemp_reqd_flg := 0; ELSE p_promo_units := 0;
p_promo_access_days
:= 0
; l_redemp_reqd_flg := 1; END IF;
--
END IF;
--
END IF;
--
RETURN l_redemp_reqd_flg;
--
EXCEPTION
WHEN OTHERS THEN
RETURN(NULL);
--
END get_redemption_flag; --End of get_redemption_flag function for CR35310
--
BEGIN
v_non_ppe := '0'; -- CR8663 SWITCH BASE
v_part_class_name := ' '; -- DITTO
p_pending_red_status := 'FALSE';
p_click_status := 'FALSE';
v_temp_sp := FALSE;
p_part_inst_objid := 0;
p_redemp_reqd_flg := 0;
p_warr_end_date := '';
p_promo_units := 0;
p_promo_access_days := 0;
p_num_of_cards := 0;
P_ERRNUM := '0';
v_cc_count := 0;
v_extra_info_1 := 0;
v_extra_info_2 := 0;
v_extra_info_3 := 0;
v_extra_info_4 := 0;
v_extra_info_5 := 0;
v_extra_info_6 := 0;
v_extra_info_8 := 0; -- is esn active
v_extra_info_9 := 0; -- is esn ota allowed
v_extra_info_10 := 0; -- is carrier ota type
v_extra_info_11 := 1; -- is handset locked
v_extra_info_12 := 0; -- is redemption menu on the handset enabled
v_extra_info_13 := 0; -- is psms destination address on the phone
v_extra_info_14 := 0;
--CR17820 Start kacosta 3/28/2012
V_EXTRA_INFO_15 := 0; -- is line reserved
v_extra_info_16 := 0;---1 is B2b,0 is non b2b
--CR17820 End kacosta 3/28/2012
-- is original act date is > or < 30 days (Rev 1.44)
v_tag_no := 0;
p_last_call_trans := 0;
--CR22799 LTE 4G
OP_SIM_STATUS := ' '; --VARCHAR2(30)
OP_X_ICCID := 0; --NUMBER
OP_ESN_STATUS := ' '; --VARCHAR2(20)
OP_ERROR_CODE := 0; --number

--CR35310 -Remove default activation promotions
p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name);

-- CR24243 UBRAND
OPEN UNIVERSAL_cur(p_esn);
FETCH UNIVERSAL_cur INTO UNIVERSAL_rec;
IF UNIVERSAL_cur%FOUND THEN
--CR42141 :- Begin (If Universal Phone, do Branding instead of sending error code 111)
--p_errnum := '111';
--p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
-- CR56982 Added Source System to Capture Old Part and Branding Channel
Brand_esn (ip_esn => p_esn, ip_org_id => p_brand_name, ip_user => NULL,ip_Rebrand_Channel => p_source_system,
op_result => p_errnum, op_msg => p_errstr);

IF p_errnum <> '0' THEN
close_open_cursors;
RETURN;
END IF;
--CR42141 :- End
END IF ;
--CR17820 Start kacosta 03/28/2012
IF site_part_curs%ISOPEN THEN
--
CLOSE site_part_curs;
--
END IF;
--
OPEN site_part_curs(p_esn);
FETCH site_part_curs INTO site_part_rec;
CLOSE site_part_curs;
--
IF pi_min_cur%ISOPEN THEN
--
CLOSE pi_min_cur;
--
END IF;
--
OPEN pi_min_cur(site_part_rec.x_min);
FETCH pi_min_cur INTO pi_min_rec;
CLOSE pi_min_cur;
--
IF (pi_min_rec.x_part_inst_status IS NULL) THEN
--
IF get_min_status_curs%ISOPEN THEN
--
CLOSE get_min_status_curs;
--
END IF;
--
OPEN get_min_status_curs(c_v_esn => p_esn);
FETCH get_min_status_curs INTO get_min_status_rec;
CLOSE get_min_status_curs;
--
l_v_min_status := get_min_status_rec.x_part_inst_status;
--
ELSE
--
l_v_min_status := pi_min_rec.x_part_inst_status;
--
END IF;
--
IF (l_v_min_status IN ('37' ,'38' ,'39' ,'73')) THEN
--
v_extra_info_15 := '1';
--
END IF;
--
p_extra_info := v_extra_info_1
|| v_extra_info_2
|| v_extra_info_3
|| v_extra_info_4
|| v_extra_info_5
|| v_extra_info_6
|| extra_info_7
|| v_extra_info_8
|| v_extra_info_9
|| v_extra_info_10
|| v_extra_info_11
|| v_extra_info_12
|| v_extra_info_13
|| v_extra_info_14
|| v_extra_info_15
|| v_extra_info_16;
--CR17820 End kacosta 03/28/2012
--
OPEN part_inst_cur(p_esn);
FETCH part_inst_cur INTO part_inst_rec;
IF part_inst_cur%FOUND THEN
p_part_inst_objid := NVL(part_inst_rec.objid ,0);
p_code_number := NVL(part_inst_rec.x_code_number ,0);
p_code_name := NVL(part_inst_rec.x_code_name ,0);
p_warr_end_date := TO_CHAR(part_inst_rec.warr_end_date ,'MM/DD/YYYY');
v_tag_no := NVL(part_inst_rec.pi_tag_no ,0);
v_code_value := NVL(part_inst_rec.x_value ,0);
v_hdr_ind := NVL(part_inst_rec.hdr_ind ,0);
p_seq := NVL(part_inst_rec.x_sequence ,0);
p_iccid := part_inst_rec.x_iccid;
p_iccid_flag := part_inst_rec.x_iccid_flag;
OPEN site_cur(p_esn);
FETCH site_cur INTO site_rec;
CLOSE site_cur;
OPEN posa_info_cur(site_rec.site_id);
FETCH posa_info_cur INTO posa_info_rec;
IF posa_info_cur%FOUND THEN
v_posa_phone := posa_info_rec.posa_phone;
IF ( ( v_posa_phone = 'Y' )
AND ( p_code_number = '59' ) ) THEN
-- ACMI ACME project start 11/05/2012
OPEN ACME_cur_pn(p_esn);
FETCH ACME_cur_pn INTO ACME_rec_pn;
IF acme_cur_pn%FOUND
AND acme_rec_pn.l_hex2dec_flag > 0 THEN
v_esn := part_inst_rec.x_hex_serial_no;
ELSE
v_esn := p_esn;
END IF ;
CLOSE ACME_cur_pn;
--ACMI ACME Project 11/05/2012
sa.posa.make_phone_active( v_esn --ACMI ACME Project 11/05/2012
,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,v_result ,'POSA_FLAG_ON');
END IF;
END IF;
IF v_result = 0 THEN
OPEN get_esn_new_status_cur(p_esn);
FETCH get_esn_new_status_cur INTO get_esn_new_status_rec;
IF get_esn_new_status_cur%FOUND THEN
p_code_number := get_esn_new_status_rec.x_code_number;
p_code_name := get_esn_new_status_rec.x_code_name;
ELSE
p_errnum := '106';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
RETURN;
END IF;
CLOSE get_esn_new_status_cur;
ELSE
p_errnum := '106';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
RETURN;
END IF;
-- SAFELINK RE-QUALIFICATIONS IC 8/24/11
OPEN cur_safelink_esn(p_esn);
FETCH cur_safelink_esn INTO rec_safelink_esn;
IF cur_safelink_esn%FOUND THEN
p_safelink_esn := 'T';
END IF;
-- SAFELINK RE-QUALIFICATIONS IC 8/24/11 END
OPEN c_account_exists(p_esn);
FETCH c_account_exists INTO r_account_exists;
CLOSE c_account_exists;
v_extra_info_3 := r_account_exists.cnt;
IF v_extra_info_3 > 1 THEN
v_extra_info_3 := 1;
END IF;

p_extra_info := v_extra_info_1
|| v_extra_info_2
|| v_extra_info_3
|| v_extra_info_4
|| v_extra_info_5
|| v_extra_info_6
|| extra_info_7
||
-- ota elements:
v_extra_info_8
|| v_extra_info_9
|| v_extra_info_10
|| v_extra_info_11
|| v_extra_info_12
|| v_extra_info_13
--exch element
--CR17820 Start kacosta 03/28/2012
-- || v_extra_info_14;
|| v_extra_info_14
|| v_extra_info_15
|| v_extra_info_16;
--CR17820 End kacosta 03/28/2012
OPEN c_autopay_ac_exists(p_esn);
FETCH c_autopay_ac_exists INTO r_autopay_ac_exists;
CLOSE c_autopay_ac_exists;
v_extra_info_6 := r_autopay_ac_exists.cnt;
IF v_extra_info_6 > 1 THEN
v_extra_info_6 := 1;
END IF;
--If the customer is not enrolled check if we are trying to enroll him using EZ Web enrollment
IF v_extra_info_6 = 0 THEN
OPEN c_enrollment_exists(p_esn);
FETCH c_enrollment_exists INTO r_enrollment_exists;
CLOSE c_enrollment_exists;
v_extra_info_6 := r_enrollment_exists.cnt;
IF v_extra_info_6 > 1 THEN
v_extra_info_6 := 1;
END IF;
END IF;

p_extra_info := v_extra_info_1
|| v_extra_info_2
|| v_extra_info_3
|| v_extra_info_4
|| v_extra_info_5
|| v_extra_info_6
|| extra_info_7
||
-- ota elements:
v_extra_info_8
|| v_extra_info_9
|| v_extra_info_10
|| v_extra_info_11
|| v_extra_info_12
|| v_extra_info_13
--exch element
--CR17820 Start kacosta 03/28/2012
-- || v_extra_info_14;
|| v_extra_info_14
|| v_extra_info_15
|| v_extra_info_16;
--CR17820 End kacosta 03/28/2012
--CR2253
OPEN c_part_class;
FETCH c_part_class INTO r_part_class;
IF c_part_class%FOUND THEN
p_part_class := NVL(r_part_class.name ,'NA');
ELSE
p_part_class := 'NA';
END IF;
CLOSE c_part_class;
OPEN c_reading_date(p_esn);
FETCH c_reading_date INTO r_reading_date;
IF c_reading_date%FOUND
AND r_reading_date.x_req_date_time IS NOT NULL THEN
v_reading_found := 1;
ELSE
v_reading_found := 0;
END IF;
CLOSE c_reading_date;
OPEN c_orig_act_date(p_esn);
FETCH c_orig_act_date INTO r_orig_act_date;
IF c_orig_act_date%FOUND THEN
IF TRUNC(SYSDATE - r_orig_act_date.orig_act_date) > 90
--CR3740
AND v_reading_found = 0 THEN
v_extra_info_1 := 1;
ELSIF Trunc(SYSDATE - r_reading_date.x_req_date_time) > 90
AND v_reading_found = 1 THEN
v_extra_info_1 := 1;
ELSE
v_extra_info_1 := 0;
END IF;
IF TRUNC(SYSDATE - r_orig_act_date.orig_act_date) >= 30 THEN
v_extra_info_14 := 1;
ELSE
v_extra_info_14 := 0;
END IF;
ELSE
v_extra_info_1 := 0;
v_extra_info_14 := 0;
END IF;
CLOSE c_orig_act_date;
IF v_hdr_ind = 1 THEN
v_extra_info_1 := 1;
END IF;

p_extra_info := v_extra_info_1
|| v_extra_info_2
|| v_extra_info_3
|| v_extra_info_4
|| v_extra_info_5
|| v_extra_info_6
|| extra_info_7
||
-- ota elements:
v_extra_info_8
|| v_extra_info_9
|| v_extra_info_10
|| v_extra_info_11
|| v_extra_info_12
|| v_extra_info_13
--exch element
--CR17820 Start kacosta 03/28/2012
-- || v_extra_info_14;
|| v_extra_info_14
|| v_extra_info_15
|| v_extra_info_16;
--CR17820 End kacosta 03/28/2012
ELSE
p_errnum := '101';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
RETURN;
END IF;
CLOSE part_inst_cur;
OPEN get_phone_info_cur(p_esn);
FETCH get_phone_info_cur INTO get_phone_info_rec;
IF get_phone_info_cur%FOUND THEN
p_phone_brand := get_phone_info_rec.org_id;
p_phone_model := get_phone_info_rec.part_number;
p_phone_technology := get_phone_info_rec.x_technology;
p_int_dll := NVL(get_phone_info_rec.x_dll ,0);
p_phone_description := Nvl(Substr(get_phone_info_rec.description, 1, 30),
0);
--BRAND_SEP
--p_amigo_flg := get_phone_info_rec.x_restricted_use;
p_esn_brand := get_phone_info_rec.org_id;
v_esn_brand2 := get_phone_info_rec.loc_type;
-- Second Brand LifeLine
--BRAND_SEP
p_manufacturer := get_phone_info_rec.x_manufacturer; --CR3733
v_part_class_name := r_part_class.name; -- CR8663 SWITCH
-- BRAND_SEPARATION START
-- CR8663 SWITCH
/*OPEN Cur_Subsourcesystem (v_part_class_name) ;
, p_subsourcesystem);
FETCH Cur_Subsourcesystem
INTO Rec_Subsourcesystem ;
IF p_Subsourcesystem = 'STRAIGHT_TALK'
THEN
If Cur_subsourcesystem%NOTFOUND or
P_AMIGO_FLG <> 3 or p_source_system in
('WEBCSR','WEB','TRACBATCH','IVR')
Then
p_errnum := '121';
p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
close_open_cursors;
RETURN;
End If;
ELSE
If Cur_subsourcesystem%FOUND
Then
p_errnum := '122';
p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
close_open_cursors;
RETURN;
End If;
END IF ;
*/
OPEN cur_input_brand;
FETCH cur_input_brand INTO rec_input_brand;
IF cur_input_brand%NOTFOUND THEN
-- Not valid Brand
p_errnum := '126';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
CLOSE cur_input_brand;
RETURN;
END IF;
CLOSE cur_input_brand;
OPEN cur_input_channel;
FETCH cur_input_channel INTO rec_input_channel;
IF cur_input_channel%NOTFOUND THEN
-- Not Valid Channel
p_errnum := '127';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
CLOSE cur_input_channel;
RETURN;
END IF;
CLOSE cur_input_channel;
IF p_esn_brand <> Upper(Trim(p_brand_name))
AND v_esn_brand2 <> Upper(Trim(p_brand_name)) THEN
-- ESN does not belong to brand
p_errnum := '125';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
RETURN;
END IF;
-- BRAND SEPARATION END
IF ( p_code_number != '52'
AND part_inst_rec.x_port_in = 1 ) THEN
p_errnum := '120';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
RETURN;
END IF;
--BRAND_SEP
/*
IF (p_amigo_flg <> 1)
AND (p_amigo_flg <> 3)
THEN
p_amigo_flg := 0;
END IF;
IF ( p_source_system = 'NETCSR'
OR p_source_system = 'NETWEB'
OR p_source_system = 'NETHANDSET'
OR p_source_system = 'NETBATCH'
--- Billing Platform Changes - CR4479
OR p_source_system = 'NETIVR' )
AND (p_amigo_flg <> 3)
THEN
p_errnum := '174';
p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
-- p_errstr := 'ESN is not for NET-10';
--CR6731 1.0.1.1
IF p_source_system = 'NETCSR'
THEN
v_source := 'WEBCSR';
ELSIF p_source_system = 'NETWEB'
THEN
v_source := 'WEB';
ELSIF p_source_system = 'NETIVR'
THEN
v_source := 'IVR';
END IF;
OPEN cur_get_iccid_flag (v_source);
FETCH cur_get_iccid_flag
INTO get_iccid_flag_rec;
IF cur_get_iccid_flag%FOUND
THEN
p_iccid_flag := get_iccid_flag_rec.x_sim_req;
END IF;
CLOSE cur_get_iccid_flag;
--CR6731 1.0.1.1
close_open_cursors; --Fix OPEN_CURSORS
RETURN;
END IF;
IF ( p_source_system = 'WEB'
OR p_source_system = 'IVR'
OR p_source_system = 'WEBCSR'
OR p_source_system = 'TRACBATCH'
--- Billing Platform Changes - CR4479
OR p_source_system
IS
NULL
OR p_source_system = '' )
AND (p_amigo_flg = 3)
THEN
p_errnum := '173';
p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
-- p_errstr := 'ESN is marked for NET-10';
--CR6731 1.0.1.1
IF p_source_system = 'WEBCSR'
THEN
v_source := 'NETCSR';
ELSIF p_source_system = 'WEB'
THEN
v_source := 'NETWEB';
ELSIF p_source_system = 'IVR'
THEN
v_source := 'NETIVR';
END IF;
OPEN cur_get_iccid_flag (v_source);
FETCH cur_get_iccid_flag
INTO get_iccid_flag_rec;
IF cur_get_iccid_flag%FOUND
THEN
p_iccid_flag := get_iccid_flag_rec.x_sim_req;
END IF;
CLOSE cur_get_iccid_flag;
--CR6731 1.0.1.1
close_open_cursors; --Fix OPEN_CURSORS
RETURN;
END IF;
*/
--BRAND_SEP
OPEN cur_get_iccid_flag(p_source_system);
FETCH cur_get_iccid_flag INTO get_iccid_flag_rec;
IF cur_get_iccid_flag%FOUND THEN
p_iccid_flag := get_iccid_flag_rec.x_sim_req;
END IF;
CLOSE cur_get_iccid_flag;

IF ( ( Nvl(p_source_system, 'IVR') <> 'WEBCSR' )
AND ( Nvl(p_source_system, 'IVR') <> 'TAS' )
-- CR22454 CL SIMPLE MOBILE
AND (NVL(p_source_system ,'IVR') <> 'NETCSR')) --CR3979
AND ( v_tag_no = 1 )
AND ( p_code_number = '50' ) THEN
p_errnum := '103';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
RETURN;
END IF;
ELSE
p_errnum := '104';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
RETURN;
END IF;
IF ( Nvl(p_source_system, 'IVR') IN ( 'WEBCSR', 'NETCSR', 'TAS' )
-- CR22454 CL SIMPLE MOBILE
AND (v_tag_no = 2)) THEN
UPDATE table_part_inst
SET pi_tag_no = 0
WHERE part_serial_no = p_esn;
COMMIT;
ELSIF ( ( Nvl(p_source_system, 'IVR') <> 'WEBCSR' )
AND ( Nvl(p_source_system, 'IVR') <> 'TAS' )
-- CR22454 CL SIMPLE MOBILE
AND ( Nvl(p_source_system, 'IVR') <> 'NETCSR' ) )
AND ( v_tag_no = 2 ) THEN
p_errnum := '105';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
RETURN;
END IF;
CLOSE get_phone_info_cur;

--CR44729 GoSmart Migration

OPEN not_migrated_cur(p_esn);
FETCH not_migrated_cur INTO not_migrated_rec;

IF not_migrated_cur%FOUND THEN

p_min := NVL(not_migrated_rec.x_min ,'NA');

--close_open_cursors;

END IF;

IF not_migrated_cur%ISOPEN THEN
CLOSE not_migrated_cur;
END IF;
--CR44729 GoSmart Migration

IF p_code_number = '50' OR p_code_number = '150' THEN
-- CR17003 Start Net 10 Sprint
-- CR17413 (B) LG L95G (NT10 Unlimited GSM Postpaid)
IF p_code_number = '50'
AND get_phone_info_rec.x_dll <= 0
-- CR17413 removed this and added dll x_technology = 'CDMA'
--AND get_phone_info_rec.org_id = 'NET10' -- CR23513
AND get_phone_info_rec.non_ppe_flag = '1' THEN
--p_redemp_reqd_flg := 1;
p_redemp_reqd_flg := Get_redemption_flag(p_esn, p_brand_name);
--CR35310 - Remove default activation promotions.
ELSE
--p_redemp_reqd_flg := 0;
p_redemp_reqd_flg := Get_redemption_flag(p_esn, p_brand_name);
--CR35310 - Remove default activation promotions.
END IF;
-- CR17003 End Net 10 Sprint
ELSIF p_code_number = '52'
OR p_code_number = '54' THEN
--p_redemp_reqd_flg := 1;
p_redemp_reqd_flg := Get_redemption_flag(p_esn, p_brand_name);
--CR35310 - Remove default activation promotions.
ELSIF p_code_number = '51'
OR p_code_number = '53' THEN
IF part_inst_rec.warr_end_date > SYSDATE THEN
--p_redemp_reqd_flg := 0;
p_redemp_reqd_flg := Get_redemption_flag(p_esn, p_brand_name);
--CR35310 - Remove default activation promotions.
ELSE
--p_redemp_reqd_flg := 1;
p_redemp_reqd_flg := Get_redemption_flag(p_esn, p_brand_name);
--CR35310 - Remove default activation promotions.
END IF;
--ELSIF p_code_number ='160' THEN -- --CR44729 GoSmart Migration
ELSIF tct.get_migration_flag ( i_code_number => p_code_number ) = 'Y' THEN -- --CR44729 GoSmart Migration
p_redemp_reqd_flg := 0; --CR44729 GoSmart Migration
ELSE
p_errnum := '106';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
--CR35310 -Remove default activation promotions
p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name);
RETURN;
END IF;
--LTE 4G CR22799
IF sa.LTE_SERVICE_PKG.IS_LTE_4G_SIM_REM(p_esn) = 0 THEN
--DBMS_OUTPUT.PUT_LINE('IS LTE PHONE');
sa.LTE_SERVICE_PKG.IS_LTE_MARRIAGE(P_ESN,OP_SIM_STATUS,OP_X_ICCID,OP_ESN_STATUS,OP_ERROR_CODE);
--DBMS_OUTPUT.PUT_LINE('RETURN of IS_LTE_MARRIAGE:'||TO_CHAR(OP_ERROR_CODE));
--commenting out these 2 IFs for CR29812 - VZW LTE
/*
IF OP_ERROR_CODE > 0 THEN
P_ERRNUM := '140'; -- ESN doesn't have SIM into inventory
IF upper(p_source_system) = 'WEBCSR' then
P_ERRSTR := 'REP: This LTE Serial Number is not associated to any SIM Number. Please use TAS to marry the SIM to the phone.';
ELSE
P_ERRSTR := 'We cannot process your transaction at this time, please call our Customer Care Center at 1-877-430-2355.';
END IF;
RETURN;
END IF ;
*/
-- end of CR29812
END IF;

OPEN carrier_pending_cur(p_esn);
FETCH carrier_pending_cur INTO carrier_pending_rec;
IF carrier_pending_cur%FOUND THEN
p_last_call_trans := NVL(carrier_pending_rec.ct_objid ,0);
p_contact_id := TO_CHAR(carrier_pending_rec.x_part_inst2contact);
p_zipcode := NVL(carrier_pending_rec.x_zipcode ,'NA');
p_min := NVL(carrier_pending_rec.x_min ,'NA');
p_errnum := '116';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
IF p_code_number = '54' THEN
OPEN get_pending_repl_cur(p_esn);
FETCH get_pending_repl_cur INTO get_pending_repl_rec;
IF get_pending_repl_cur%FOUND THEN
IF ( p_source_system = 'WEBCSR'
OR p_source_system = 'NETCSR'
OR p_source_system = 'TAS' ) THEN -- CR22454 CL SIMPLE MOBILE
--p_redemp_reqd_flg := 0;
p_redemp_reqd_flg := Get_redemption_flag(p_esn, p_brand_name);
--CR35310 - Remove default activation promotions.
END IF;
END IF;
CLOSE get_pending_repl_cur;
IF part_inst_rec.warr_end_date > SYSDATE THEN
--p_redemp_reqd_flg := 0;
p_redemp_reqd_flg := Get_redemption_flag(p_esn, p_brand_name);
--CR35310 - Remove default activation promotions.
END IF;
END IF;
close_open_cursors;
--CR35310 -Remove default activation promotions
p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name);
RETURN;
END IF;
OPEN carrier_pending_react_cur(p_esn);
FETCH carrier_pending_react_cur INTO carrier_pending_react_rec;
IF carrier_pending_react_cur%FOUND THEN
p_last_call_trans := NVL(carrier_pending_react_rec.ct_objid ,0);
p_contact_id := TO_CHAR(carrier_pending_react_rec.x_part_inst2contact);
p_zipcode := NVL(carrier_pending_react_rec.x_zipcode ,'NA');
p_min := NVL(carrier_pending_react_rec.x_min ,'NA');
p_errnum := '116';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
IF p_code_number = '54' THEN
OPEN get_pending_repl_cur(p_esn);
FETCH get_pending_repl_cur INTO get_pending_repl_rec;
IF get_pending_repl_cur%FOUND THEN
IF ( p_source_system = 'WEBCSR'
OR p_source_system = 'NETCSR'
OR p_source_system = 'TAS' ) -- CR22454 CL SIMPLE MOBILE
THEN
--p_redemp_reqd_flg := 0;
p_redemp_reqd_flg := Get_redemption_flag(p_esn, p_brand_name);
--CR35310 - Remove default activation promotions.
END IF;
END IF;
CLOSE get_pending_repl_cur;
IF part_inst_rec.warr_end_date > SYSDATE THEN
--p_redemp_reqd_flg := 0;
p_redemp_reqd_flg := Get_redemption_flag(p_esn, p_brand_name);
--CR35310 - Remove default activation promotions.
END IF;
END IF;
close_open_cursors;
--CR35310 -Remove default activation promotions
p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name);
RETURN;
END IF;
OPEN activation_pending_cur(p_esn);
FETCH activation_pending_cur INTO activation_pending_rec;
IF activation_pending_cur%FOUND THEN
p_last_call_trans := NVL(activation_pending_rec.ct_objid ,0);
p_contact_id := TO_CHAR(activation_pending_rec.x_part_inst2contact);
p_zipcode := NVL(activation_pending_rec.x_zipcode ,'NA');
p_min := NVL(activation_pending_rec.x_min ,'NA');
p_errnum := '117';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
RETURN;
END IF;
IF (p_code_number = '52') THEN
OPEN product_part_cur(p_esn);
FETCH product_part_cur INTO product_part_rec;
--CR21077 Start Kacosta 06/15/2012
IF product_part_cur%NOTFOUND THEN
--
CLOSE product_part_cur;
--
bau_maintenance_pkg.Fix_site_part_for_esn(p_esn => p_esn,
p_error_code => p_errnum, p_error_message => p_errstr);
--
OPEN product_part_cur(p_esn);
FETCH product_part_cur INTO product_part_rec;
--
END IF;
--CR21077 End Kacosta 06/15/2012
IF product_part_cur%FOUND THEN
p_zipcode := product_part_rec.x_zipcode;
p_min := product_part_rec.x_min;
OPEN new_plan_cur(product_part_rec.objid);
FETCH new_plan_cur INTO new_plan_rec;
IF new_plan_cur%FOUND THEN
p_click_status := 'TRUE';
END IF;
CLOSE new_plan_cur;
OPEN contact_pi_cur(p_esn);
FETCH contact_pi_cur INTO contact_pi_rec;
IF contact_pi_cur%FOUND THEN
p_contact_id := TO_CHAR(contact_pi_rec.objid);
p_contact_phone := contact_pi_rec.phone;
p_contact_email := contact_pi_rec.e_mail;
IF To_char(contact_pi_rec.x_dateofbirth, 'mm/dd/yyyy') <> '01/01/1753'
AND contact_pi_rec.x_dateofbirth IS NOT NULL THEN
v_extra_info_5 := 1;
END IF;
IF contact_pi_rec.x_pin IS NOT NULL THEN
v_extra_info_4 := 1;
END IF;
ELSE
OPEN contact_sp_cur(product_part_rec.objid);
FETCH contact_sp_cur INTO contact_sp_rec;
p_contact_id := TO_CHAR(contact_sp_rec.objid);
p_contact_phone := contact_sp_rec.phone;
p_contact_email := contact_sp_rec.e_mail;
IF To_char(contact_sp_rec.x_dateofbirth, 'mm/dd/yyyy') <> '01/01/1753'
AND contact_sp_rec.x_dateofbirth IS NOT NULL THEN
v_extra_info_5 := 1;
END IF;
IF contact_sp_rec.x_pin IS NOT NULL THEN
v_extra_info_4 := 1;
END IF;
CLOSE contact_sp_cur;
END IF;
CLOSE contact_pi_cur;
OPEN cc_cur(p_contact_id);
FETCH cc_cur INTO cc_rec;
CLOSE cc_cur;
v_cc_count := cc_rec.count_cc;
p_num_of_cards := v_cc_count;
OPEN pi_min_cur(product_part_rec.x_min);
FETCH pi_min_cur INTO pi_min_rec;
CLOSE pi_min_cur;
IF ( ( pi_min_rec.x_port_in = 1 )
OR ( pi_min_rec.x_port_in = 2 ) ) THEN
v_extra_info_2 := 1;
ELSE
v_extra_info_2 := 0;
END IF;

p_extra_info := v_extra_info_1
|| v_extra_info_2
|| v_extra_info_3
|| v_extra_info_4
|| v_extra_info_5
|| v_extra_info_6
|| extra_info_7
||
-- ota elements:
v_extra_info_8
|| v_extra_info_9
|| v_extra_info_10
|| v_extra_info_11
|| v_extra_info_12
|| v_extra_info_13
--exch element
--CR17820 Start kacosta 03/28/2012
-- || v_extra_info_14;
|| v_extra_info_14
|| v_extra_info_15
|| v_extra_info_16;
--CR17820 End kacosta 03/28/2012
IF (pi_min_rec.x_part_inst_status = '34') THEN
IF ( p_source_system = 'WEB'
OR p_source_system = 'UDP'
-- CR28456 Added UDP Source System Changes on 09/26/2014
OR p_source_system = 'WAP' -- WAP Redemption 12/29/2010
OR p_source_system = 'APP' -- APP CR21961 IC.
OR p_source_system = 'TAS' -- CR22454 CL SIMPLE MOBILE
OR p_source_system = 'WEBCSR'
OR p_source_system = 'NETWEB'
OR p_source_system = 'NETHANDSET'
OR p_source_system = 'NETBATCH'
OR p_source_system = 'TRACBATCH'
OR p_source_system = 'NETCSR' -- CR11623 BRAND_SEP_IV
OR p_source_system = 'BATCH') THEN
p_errnum := '108';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
ELSE
p_errnum := '108';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
RETURN;
END IF;
ELSIF (pi_min_rec.x_part_inst_status = '110') THEN
IF ( p_source_system = 'WEBCSR'
OR p_source_system = 'NETHANDSET'
OR p_source_system = 'NETBATCH'
OR p_source_system = 'TRACBATCH'
OR p_source_system = 'NETCSR' -- CR11623 BRAND_SEP_IV
OR p_source_system = 'TAS' -- CR22454 CL SIMPLE MOBILE
OR p_source_system = 'BATCH') THEN
p_errnum := '109';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
ELSE
p_errnum := '109';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
END IF;
END IF;
OPEN new_pers_cur(pi_min_rec.objid);
FETCH new_pers_cur INTO new_pers_rec;
IF new_pers_cur%FOUND THEN
p_pers_status := 'FALSE';
OPEN old_pers_cur(pi_min_rec.objid);
FETCH old_pers_cur INTO old_pers_rec;
CLOSE old_pers_cur;
OPEN pers_lac_cur(pi_min_rec.part_serial_no ,p_phone_technology);
FETCH pers_lac_cur INTO pers_lac_rec;
IF pers_lac_cur%NOTFOUND THEN
CLOSE pers_lac_cur;
OPEN pers_lac_cur(pi_min_rec.part_serial_no ,'MASTER');
FETCH pers_lac_cur INTO pers_lac_rec;
END IF;
CLOSE pers_lac_cur;
OPEN getpers2sid_cur(new_pers_rec.objid ,p_phone_technology);
FETCH getpers2sid_cur INTO getpers2sid_rec;
IF getpers2sid_cur%NOTFOUND THEN
CLOSE getpers2sid_cur;
OPEN getpers2sid_cur(new_pers_rec.objid ,'MASTER');
FETCH getpers2sid_cur INTO getpers2sid_rec;
END IF;
CLOSE getpers2sid_cur;
IF (pers_lac_rec.x_sid <> getpers2sid_rec.x_sid) THEN
p_pers_status := 'TRUE';
END IF;
--Compare Local SIDs for non-GSM phones
IF p_phone_technology <> 'GSM'
AND p_pers_status <> 'TRUE' THEN
FOR pers_lac_rec IN pers_lac_cur(pi_min_rec.part_serial_no ,'LOCAL')
LOOP
v_old_sid(old_counter) := pers_lac_rec.x_sid;
old_counter := old_counter + 1;
END LOOP;
old_counter := old_counter - 1;
FOR getpers2sid_rec IN getpers2sid_cur(new_pers_rec.objid, 'LOCAL') LOOP
v_new_sid(new_counter) := getpers2sid_rec.x_sid;
new_counter := new_counter + 1;
END LOOP;
new_counter := new_counter - 1;
IF old_counter <> new_counter THEN
p_pers_status := 'TRUE';
ELSE
IF new_pers_rec.objid <> old_pers_rec.objid
AND new_counter > 0 THEN
p_pers_status := 'TRUE';
END IF;
FOR i IN 1 .. new_counter LOOP
IF v_new_sid(new_counter) <> v_old_sid(new_counter) THEN
p_pers_status := 'TRUE';
EXIT;
END IF;
END LOOP;
END IF;
END IF;
IF p_pers_status <> 'TRUE' THEN
IF old_pers_rec.x_restrict_ld <> new_pers_rec.x_restrict_ld
OR old_pers_rec.x_restrict_callop <> new_pers_rec.x_restrict_callop
OR old_pers_rec.x_restrict_intl <> new_pers_rec.x_restrict_intl
OR old_pers_rec.x_restrict_roam <> new_pers_rec.x_restrict_roam THEN
p_pers_status := 'TRUE';
END IF;

IF p_int_dll >= 10
AND ( old_pers_rec.x_restrict_inbound <>
new_pers_rec.x_restrict_inbound
OR old_pers_rec.x_restrict_outbound <>
new_pers_rec.x_restrict_outbound ) THEN
p_pers_status := 'TRUE';
END IF;

IF ( p_int_dll = 6
OR p_int_dll = 8 )
AND ( old_pers_rec.x_soc_id <> new_pers_rec.x_soc_id
OR old_pers_rec.x_partner <> new_pers_rec.x_partner
OR old_pers_rec.x_favored <> new_pers_rec.x_favored
OR old_pers_rec.x_neutral <> new_pers_rec.x_neutral ) THEN
p_pers_status := 'TRUE';
END IF;
END IF;
--If the ESN is not flagged for Personality Update, but old and new personality
--are different, reset the flag
IF p_pers_status <> 'TRUE'
AND new_pers_rec.objid <> old_pers_rec.objid THEN
UPDATE table_part_inst
SET part_inst2x_pers = new_pers_rec.objid ,
part_inst2x_new_pers = NULL
WHERE part_serial_no = pi_min_rec.part_serial_no;
UPDATE table_part_inst
SET part_inst2x_pers = new_pers_rec.objid
WHERE part_serial_no = p_esn;
COMMIT;
END IF;
ELSE
p_pers_status := 'FALSE';
END IF;
CLOSE new_pers_cur;
OPEN c_sms_parent(p_phone_technology, Nvl(get_phone_info_rec.x_data_capable,
0
));
FETCH c_sms_parent INTO r_sms_parent;
IF c_sms_parent%FOUND THEN
IF p_phone_technology = 'GSM' THEN
p_sms_flag := 1;
ELSE
p_sms_flag := NVL(r_sms_parent.x_sms ,0);
END IF;
p_parent_id := NVL(r_sms_parent.x_parent_id ,'NA');
ELSE
p_sms_flag := 0;
p_parent_id := 'NA';
END IF;
CLOSE c_sms_parent;
ELSE
p_errnum := '119';
/*CR33864 ATT Carrier switch */
 IF p_errnum ='119' THEN
sa.Sp_swb_carr_rate_plan(ip_esn => p_esn,
op_last_rate_plan_sent => op_last_rate_plan_sent,
op_is_swb_carr => op_is_swb_carr, op_error_code => op_error_code1,
op_error_message => op_error_message);
IF OP_IS_SWB_CARR = 'Switch Base' THEN
FOR product_part_cur_sw_rec IN product_part_cur_sw(p_esn) LOOP
IF product_part_cur_sw_rec.part_status = 'CarrierPending' THEN
 p_errnum := '618';
 p_errstr := 'Device Status is CarrierPending';
 END IF;
END LOOP;
 ELSE
 p_errnum :='119';
 p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
 END IF;
 END IF;
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
RETURN;
p_errnum := '106';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
END IF;
CLOSE product_part_cur;
ELSIF ( p_code_number = '50'
OR p_code_number = '150' ) THEN
OPEN get_phone_info_cur(p_esn);
FETCH get_phone_info_cur INTO get_phone_info_rec;
CLOSE get_phone_info_cur;
IF (get_phone_info_rec.x_technology <> 'ANALOG') THEN
v_tech := 'DIGITAL';
IF ( get_phone_info_rec.prog_type = '2'
AND get_phone_info_rec.x_part_inst_status = '50' ) THEN
v_tech := 'DIGITAL2';
END IF;
END IF;
IF (get_phone_info_rec.org_id = 'NET10') THEN
v_tech := 'DIGITAL3';
IF ( get_phone_info_rec.prog_type = '2'
AND get_phone_info_rec.x_part_inst_status = '150' ) THEN
v_tech := 'DIGITAL4';
END IF;
OPEN default_promo_cur(v_tech);
FETCH default_promo_cur INTO default_promo_rec;
OPEN activation_promo_used_curs(p_esn);
FETCH activation_promo_used_curs INTO activation_promo_used_rec;
IF default_promo_cur%FOUND
AND activation_promo_used_curs%NOTFOUND THEN
p_promo_units := default_promo_rec.x_units;
p_promo_access_days := default_promo_rec.x_access_days;
p_pending_red_status := 'TRUE';
END IF;
CLOSE default_promo_cur;
CLOSE activation_promo_used_curs;
ELSE
OPEN dealer_promo_cur(site_rec.objid);
FETCH dealer_promo_cur INTO dealer_promo_rec;
IF dealer_promo_cur%NOTFOUND THEN
OPEN default_promo_cur(v_tech);
FETCH default_promo_cur INTO default_promo_rec;
OPEN activation_promo_used_curs(p_esn);
FETCH activation_promo_used_curs INTO activation_promo_used_rec;
IF default_promo_cur%FOUND
AND activation_promo_used_curs%NOTFOUND THEN
p_promo_units := default_promo_rec.x_units;
p_promo_access_days := default_promo_rec.x_access_days;
p_pending_red_status := 'TRUE';
END IF;
CLOSE default_promo_cur;
CLOSE activation_promo_used_curs;
ELSE
p_promo_units := dealer_promo_rec.x_units;
p_promo_access_days := dealer_promo_rec.x_access_days;
p_pending_red_status := 'TRUE';
END IF;
CLOSE dealer_promo_cur;
END IF;
OPEN get_oldsitepart_cur(part_inst_rec.objid);
FETCH get_oldsitepart_cur INTO get_oldsitepart_rec;
IF get_oldsitepart_cur%FOUND THEN
p_promo_units := 0;
p_promo_access_days := 0;
END IF;
CLOSE get_oldsitepart_cur;
OPEN contact_pi_cur(p_esn);
FETCH contact_pi_cur INTO contact_pi_rec;
IF contact_pi_cur%FOUND THEN
p_contact_id := TO_CHAR(contact_pi_rec.objid);
p_contact_phone := contact_pi_rec.phone;
p_contact_email := contact_pi_rec.e_mail;
END IF;
CLOSE contact_pi_cur;
OPEN site_part_curs(p_esn);
FETCH site_part_curs INTO site_part_rec;
IF site_part_curs%FOUND THEN
OPEN pi_min_cur(site_part_rec.x_min);
FETCH pi_min_cur INTO pi_min_rec;
IF pi_min_rec.x_part_inst_status = '110' THEN
p_min := site_part_rec.x_min;
p_errnum := '109';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
END IF;
CLOSE pi_min_cur;
END IF;
CLOSE site_part_curs;
ELSE
IF p_code_number = '54' THEN
OPEN get_pending_repl_cur(p_esn);
FETCH get_pending_repl_cur INTO get_pending_repl_rec;
IF get_pending_repl_cur%FOUND THEN
IF ( p_source_system = 'WEBCSR'
OR p_source_system = 'NETCSR'
OR p_source_system = 'TAS' ) -- CR22454 CL SIMPLE MOBILE
THEN
--p_redemp_reqd_flg := 0;
p_redemp_reqd_flg := Get_redemption_flag(p_esn, p_brand_name);
--CR35310 - Remove default activation promotions.
END IF;
END IF;
CLOSE get_pending_repl_cur;
IF part_inst_rec.warr_end_date > SYSDATE THEN
--p_redemp_reqd_flg := 0;
p_redemp_reqd_flg := Get_redemption_flag(p_esn, p_brand_name);
--CR35310 - Remove default activation promotions.
END IF;
END IF;
FOR get_oldsitepart_rec2 IN get_oldsitepart_cur2(p_esn) LOOP
p_zipcode := get_oldsitepart_rec2.x_zipcode;
v_temp_sp := TRUE;
v_sp_objid := get_oldsitepart_rec2.objid;
EXIT;
END LOOP;
IF (v_temp_sp = FALSE) THEN
p_errnum := '118';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
RETURN;
END IF;
OPEN contact_pi_cur(p_esn);
FETCH contact_pi_cur INTO contact_pi_rec;
IF contact_pi_cur%FOUND THEN
p_contact_id := TO_CHAR(contact_pi_rec.objid);
p_contact_phone := contact_pi_rec.phone;
p_contact_email := contact_pi_rec.e_mail;
ELSE
OPEN contact_sp_cur(v_sp_objid);
FETCH contact_sp_cur INTO contact_sp_rec;
IF contact_sp_cur%FOUND THEN
p_contact_id := TO_CHAR(contact_sp_rec.objid);
p_contact_phone := contact_sp_rec.phone;
p_contact_email := contact_pi_rec.e_mail;
ELSE
p_errnum := '102';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
RETURN;
END IF;
CLOSE contact_sp_cur;
END IF;
CLOSE contact_pi_cur;
p_click_status := 'TRUE';
p_pers_status := 'TRUE';
OPEN site_part_curs(p_esn);
FETCH site_part_curs INTO site_part_rec;
IF site_part_curs%FOUND THEN
OPEN pi_min_cur(site_part_rec.x_min);
FETCH pi_min_cur INTO pi_min_rec;
IF pi_min_rec.x_part_inst_status = '110' THEN
p_min := site_part_rec.x_min;
p_errnum := '109';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
END IF;
CLOSE pi_min_cur;
END IF;
CLOSE site_part_curs;
END IF;
----- SAFELINK RE-QUALIFICATIONS 8/24/11
IF cur_safelink_esn%FOUND THEN
p_safelink_esn := 'T';
-- CR49877 Unblock Claro -- Commented the below which was blocking SL Claro
/*--CR46772EME CHANGE VISHNU START
 IF UPPER(p_brand_name) = 'TRACFONE'
 AND sa.Get_device_type(p_esn) = 'SMARTPHONE'
 AND p_safelink_esn = 'T'
 AND p_code_number = 52
 AND p_parent_id = 69
 AND upper(p_source_system) IN ('APP','IVR','UDP','WEB','HANDSET') THEN
 p_errnum := '991';
 p_errstr :=
 'Your transaction cannot be processed at this time. Please contact our Customer Care Center at 1-800-867-7183.'
 ;
 RETURN;
 END IF;
--CR46772 EME CHANGE VISHNU END */
IF p_code_number IN ( '53', '54' )
AND rec_safelink_esn.x_current_active IS NULL THEN
--p_redemp_reqd_flg := 0;
p_redemp_reqd_flg := Get_redemption_flag(p_esn, p_brand_name);
--CR35310 - Remove default activation promotions.
END IF;
----- SAFELINK RE-QUALIFICATIONS 8/24/11 END
END IF;
--
-- OTA validation:
--
/*****************************************************
| Is OTA Activation in process: |
| If YES - find out if ESN is OTA allowed |
| If NOT - evaluate the following: |
| 1)is ESN active and is esn OTA allowed |
| 2)is carrier OTA enabled |
| 3)what features on the pho
| 3)what features on the phone are enabled |
| NOTE: all output parameters for OTA |
| validation are initialized right at |
| the start of the procedure |
*****************************************************/
-- is OTA Activation in process?
FOR cur_is_ota_activation_rec IN cur_is_ota_activation LOOP
b_ota_activation := TRUE;
IF UPPER(NVL(cur_is_ota_activation_rec.x_ota_allowed ,'N')) = 'Y' THEN
v_extra_info_9 := 1;
END IF;
END LOOP;
IF NOT b_ota_activation THEN
-- 1) is ESN active
FOR cur_is_esn_active_rec IN cur_is_esn_active LOOP
v_extra_info_8 := 1;
IF UPPER(NVL(cur_is_esn_active_rec.x_ota_allowed ,'N')) = 'Y' THEN
v_extra_info_9 := 1;
END IF;
END LOOP;
-- 2) is carrier OTA enabled
FOR cur_is_carrier_ota_type_rec IN cur_is_carrier_ota_type LOOP
IF UPPER(NVL(cur_is_carrier_ota_type_rec.x_ota_carrier ,'N')) = 'Y' THEN
v_extra_info_10 := 1;
END IF;
END LOOP;
-- 3) what features on the phone are enabled
-- this is the assumption for now:
-- if handset is unlocked we will proceed with sending the PSMS message to the phone
FOR cur_get_ota_features_rec IN cur_get_ota_features LOOP
IF UPPER(NVL(cur_get_ota_features_rec.x_handset_lock ,'N')) = 'Y' THEN
v_extra_info_11 := 0;
END IF;
IF UPPER(NVL(cur_get_ota_features_rec.x_redemption_menu ,'N')) = 'Y' THEN
v_extra_info_12 := 1;
END IF;
IF cur_get_ota_features_rec.x_psms_destination_addr IS NOT NULL THEN
v_extra_info_13 := 1;
END IF;
END LOOP;
END IF;
-- NOT b_ota_activation
p_extra_info := v_extra_info_1
|| v_extra_info_2
|| v_extra_info_3
|| v_extra_info_4
|| v_extra_info_5
|| v_extra_info_6
|| extra_info_7
||
-- ota elements:
v_extra_info_8
|| v_extra_info_9
|| v_extra_info_10
|| v_extra_info_11
|| v_extra_info_12
|| v_extra_info_13
--exch element
--CR17820 Start kacosta 03/28/2012
-- || v_extra_info_14;
|| v_extra_info_14
|| v_extra_info_15
|| v_extra_info_16;
--CR17820 End kacosta 03/28/2012
OPEN get_pending_repl_cur(p_esn);
FETCH get_pending_repl_cur INTO get_pending_repl_rec;
IF get_pending_repl_cur%FOUND THEN
v_repl_pend_flag := 1;
ELSE
v_repl_pend_flag := 0;
END IF;
CLOSE get_pending_repl_cur;
OPEN get_pending_redemptions_cur(p_esn);
FETCH get_pending_redemptions_cur INTO get_pending_redemptions_rec;
IF get_pending_redemptions_cur%FOUND
OR v_repl_pend_flag = 1 THEN
IF ( p_source_system = 'WEBCSR'
OR p_source_system = 'NETCSR'
OR p_source_system = 'NETBATCH'
OR p_source_system = 'TRACBATCH'
OR p_source_system = 'WEB'
OR p_source_system = 'UDP'
-- CR28456 Added UDP Source System Changes on 09/26/2014
OR p_source_system = 'TAS' -- CR22454 CL SIMPLE MOBILE
OR p_source_system = 'NETWEB' -- CR22198
OR p_source_system = 'BATCH') -- CR11623 BRAND_SEP_IV
THEN
--p_redemp_reqd_flg := 0;
p_redemp_reqd_flg := Get_redemption_flag(p_esn, p_brand_name);
--CR35310 - Remove default activation promotions.
END IF;
IF p_source_system IN ('WAP', -- CR21961 IC
-- 'APP', -- CR 35913: APP value excluded from the list
--,'WEB' --CR22198
--,'NETWEB' --CR22198
'IVR', 'NETIVR', 'NETHANDSET' )
-- WAP Redemption 12/29/2010
THEN
p_errnum := '110';
p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
close_open_cursors;
--CR35310 -Remove default activation promotions
p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name);
RETURN;
END IF;
END IF;
CLOSE GET_PENDING_REDEMPTIONS_CUR;
--CR25490 B2B Changed by CPannala


v_extra_info_16 := b2b_pkg.Is_b2b(ip_type => 'ESN', ip_value => p_esn, ip_brand
=> p_brand_name,
--Only needed if ip_type = email
OP_ERR_NUM => P_ERRNUM, OP_ERR_MSG => P_ERRSTR);


p_extra_info := v_extra_info_1
|| v_extra_info_2
|| v_extra_info_3
|| v_extra_info_4
|| v_extra_info_5
|| v_extra_info_6
|| extra_info_7
|| v_extra_info_8
|| v_extra_info_9
|| v_extra_info_10
|| v_extra_info_11
|| v_extra_info_12
|| v_extra_info_13
|| v_extra_info_14
|| v_extra_info_15
|| v_extra_info_16;
END validate_phone_prc;
-- CR16987 Start KACOSTA 10/12/2011
PROCEDURE get_program_info(
p_esn IN VARCHAR2 ,
p_service_plan_objid OUT VARCHAR2 ,
p_service_type OUT VARCHAR2 ,
p_program_type OUT VARCHAR2 ,
p_next_charge_date OUT DATE ,
p_program_units OUT NUMBER ,
p_program_days OUT NUMBER ,
p_error_num OUT NUMBER )
AS
--
l_v_dummy_rate_plan table_x_carrier_features.x_rate_plan%TYPE;
--
BEGIN
--
get_program_info(p_esn => p_esn ,p_service_plan_objid => p_service_plan_objid ,p_service_type => p_service_type ,p_program_type => p_program_type ,p_next_charge_date => p_next_charge_date ,p_program_units => p_program_units ,p_program_days => p_program_days ,p_rate_plan => l_v_dummy_rate_plan ,p_error_num => p_error_num);
--
END get_program_info;
-- CR16987 End KACOSTA 10/12/2011
PROCEDURE get_program_info(
p_esn IN VARCHAR2 ,
p_service_plan_objid OUT VARCHAR2 , -- SKuthadi
p_service_type OUT VARCHAR2 ,
p_program_type OUT VARCHAR2 ,
p_next_charge_date OUT DATE ,
p_program_units OUT NUMBER ,
p_program_days OUT NUMBER ,
-- CR16987 Start KACOSTA 07/25/2011
p_rate_plan OUT VARCHAR2 ,
-- CR16987 End KACOSTA 07/25/2011
p_error_num OUT NUMBER )
AS
v_program_objid NUMBER := 0;
v_bus_org VARCHAR2(30) := '';
BEGIN
BEGIN
SELECT x_service_plan.webcsr_display_name ,
x_service_plan.objid
INTO p_service_type ,
p_service_plan_objid
FROM x_service_plan_site_part
INNER JOIN x_service_plan
ON x_service_plan_site_part.x_service_plan_id = x_service_plan.objid
WHERE table_site_part_id IN
(SELECT MAX(objid) FROM table_site_part WHERE x_service_id = p_esn and nvl(x_refurb_flag,0) = 0
);
EXCEPTION
WHEN no_data_found THEN
BEGIN
SELECT bo.s_org_id
INTO v_bus_org
FROM sa.table_part_num pn ,
sa.table_mod_level ml ,
sa.table_part_inst pi ,
sa.table_bus_org bo
WHERE pn.objid = ml.part_info2part_num
AND ml.objid = pi.n_part_inst2part_mod
AND pn.part_num2bus_org = bo.objid
AND pi.part_serial_no = p_esn;
EXCEPTION
WHEN no_data_found THEN
NULL;
END;
IF v_bus_org IN ('TRACFONE' ,'NET10') THEN
p_service_type := 'Paygo';
ELSE
p_service_type := ' ';
END IF;
END;
BEGIN
-- CR17276 Start KACOSTA 7/26/2011
--SELECT
-- pgmprm.objid,
-- pgmprm.x_program_name,
-- pgmenr.x_next_charge_date
--INTO v_program_objid,p_program_type,p_next_charge_date
--FROM
-- x_program_parameters pgmprm,
-- x_program_enrolled pgmenr
--WHERE 1=1
--AND pgmenr.x_enrollment_status = 'ENROLLED'
--AND pgmprm.x_is_recurring = 1
--AND pgmprm.objid = pgmenr.pgm_enroll2pgm_parameter +0
--AND nvl(pgmprm.x_prog_class,' ') <> 'ONDEMAND'
--AND pgmenr.x_esn = p_esn;
SELECT pgmprm.objid ,
pgmprm.x_program_name ,
pgmenr.x_next_charge_date
INTO v_program_objid ,
p_program_type ,
p_next_charge_date
FROM x_program_parameters pgmprm ,
x_program_enrolled pgmenr
WHERE 1 = 1
AND pgmenr.x_enrollment_status = 'ENROLLED'
AND pgmprm.x_is_recurring = 1
AND pgmprm.objid = pgmenr.pgm_enroll2pgm_parameter + 0
AND NVL(pgmprm.x_prog_class ,' ') <> 'ONDEMAND'
AND pgmenr.x_esn = p_esn
AND pgmenr.objid =
(SELECT MAX(pgmenr_max.objid)
FROM x_program_enrolled pgmenr_max
WHERE pgmenr_max.x_esn = pgmenr.x_esn
AND pgmenr_max.x_enrolled_date =
(SELECT MAX(pgmenr_max_date.x_enrolled_date)
FROM x_program_enrolled pgmenr_max_date,
x_program_parameters PP
WHERE pgmenr_max_date.x_esn = pgmenr_max.x_esn
AND pp.objid = pgmenr_max_date.pgm_enroll2pgm_parameter + 0 --CR22380 Handset protection excluded WARRANTY
AND NVL(PP.X_PROG_CLASS,' ') <> 'WARRANTY' --CR22380 Handset protection excluded WARRANTY
)
);
-- CR17276 End KACOSTA 7/26/2011
SELECT SUM(x_access_days) ,
SUM(x_units)
INTO p_program_days ,
p_program_units
FROM table_x_promotion
WHERE objid IN
(SELECT x_promo_incl_min_at
FROM x_program_parameters
WHERE objid = v_program_objid
UNION
SELECT x_incl_service_days
FROM x_program_parameters
WHERE objid = v_program_objid
);
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
-- CR16987 Start KACOSTA 07/25/2011
BEGIN
--
p_rate_plan := service_plan.f_get_esn_rate_plan_all_status(p_esn => p_esn);
--
EXCEPTION
WHEN OTHERS THEN
--
p_rate_plan := NULL;
--
END;
-- CR16987 End KACOSTA 07/25/2011
p_error_num := 0;
END get_program_info;



--CR32952

PROCEDURE get_program_info( p_esn IN VARCHAR2 ,
 p_service_plan_objid OUT VARCHAR2 , -- SKuthadi
 p_service_type OUT VARCHAR2 ,
 p_program_type OUT VARCHAR2 ,
 p_next_charge_date OUT DATE ,
 p_program_units OUT NUMBER ,
 p_program_days OUT NUMBER ,-- CR16987 Start KACOSTA 07/25/2011
 p_rate_plan OUT VARCHAR2 , -- CR16987 End KACOSTA 07/25/2011
 p_x_prg_script_id OUT VARCHAR2, --CR32952
 p_x_prg_desc_script_id OUT VARCHAR2, --CR32952
 p_error_num OUT NUMBER)
AS
 v_program_objid NUMBER := 0;
 v_bus_org VARCHAR2(30) := '';
BEGIN --{
 BEGIN --{
 SELECT x_service_plan.webcsr_display_name ,
 x_service_plan.objid
 INTO p_service_type ,
 p_service_plan_objid
 FROM x_service_plan_site_part
 INNER JOIN x_service_plan
 ON x_service_plan_site_part.x_service_plan_id = x_service_plan.objid
 WHERE table_site_part_id IN (SELECT MAX(objid)
 FROM table_site_part
 WHERE x_service_id = p_esn
 AND NVL(x_refurb_flag,0) = 0
 );
 EXCEPTION WHEN no_data_found
 THEN
 BEGIN --{
 SELECT bo.s_org_id
 INTO v_bus_org
 FROM sa.table_part_num pn ,
 sa.table_mod_level ml ,
 sa.table_part_inst pi ,
 sa.table_bus_org bo
 WHERE pn.objid = ml.part_info2part_num
 AND ml.objid = pi.n_part_inst2part_mod
 AND pn.part_num2bus_org = bo.objid
 AND pi.part_serial_no = p_esn;
 EXCEPTION WHEN no_data_found
 THEN
 NULL;
 END;--}
 IF v_bus_org IN ('TRACFONE' ,'NET10')
 THEN
 p_service_type := 'Paygo';
 ELSE
 p_service_type := ' ';
 END IF;

 WHEN too_many_rows
 THEN
 --
 -- Start CR39521 Blank scrren in TAS
 -- Added logic to filter only one record for a particular ESN and service plan
 --
 SELECT b.webcsr_display_name ,
 b.objid
 INTO p_service_type ,
 p_service_plan_objid
 FROM x_service_plan_site_part a
 INNER JOIN x_service_plan b
 ON a.x_service_plan_id = b.objid
 WHERE table_site_part_id IN (SELECT objid
 FROM table_site_part sp
 WHERE x_service_id = p_esn
 AND install_date = ( SELECT MAX(install_date)
 FROM table_site_part
 WHERE x_service_id = sp.x_service_id
 AND x_min = sp.x_min
 )
 )
 AND a.x_last_modified_date = (SELECT MAX(x_last_modified_date)
 FROM x_service_plan_site_part
 WHERE table_site_part_id = a.table_site_part_id
 AND x_service_plan_id = a.x_service_plan_id
 )
 AND ROWNUM = 1;
 --
 -- End CR39521 Blank scrren in TAS
 --
 WHEN OTHERS THEN
 NULL;
 END;--}

 BEGIN--{
 SELECT pgmprm.objid ,
 pgmprm.x_program_name ,
 pgmenr.x_next_charge_date,
 pgmprm.x_prg_script_id,
 pgmprm.x_prg_desc_script_id
 INTO v_program_objid ,
 p_program_type ,
 p_next_charge_date,
 p_x_prg_script_id,
 p_x_prg_desc_script_id
 FROM x_program_parameters pgmprm ,
 x_program_enrolled pgmenr
 WHERE 1 = 1
 AND pgmenr.x_enrollment_status = 'ENROLLED'
 AND pgmprm.x_is_recurring = 1
 AND pgmprm.objid = pgmenr.pgm_enroll2pgm_parameter + 0
 AND NVL(pgmprm.x_prog_class ,' ') <> 'ONDEMAND'
 AND pgmenr.x_esn = p_esn
 AND pgmenr.objid =(SELECT MAX(pgmenr_max.objid)
 FROM x_program_enrolled pgmenr_max
 WHERE pgmenr_max.x_esn = pgmenr.x_esn
 -- CR51040 Correct program script being chosen for B2B Data Club
 AND auto_refill_counter IS NULL
 AND pgmenr_max.x_enrolled_date =(SELECT MAX(pgmenr_max_date.x_enrolled_date)
 FROM x_program_enrolled pgmenr_max_date,
 x_program_parameters PP
 WHERE pgmenr_max_date.x_esn = pgmenr_max.x_esn
 AND pp.objid = pgmenr_max_date.pgm_enroll2pgm_parameter + 0 --CR22380 Handset protection excluded WARRANTY
 -- CR51040 Correct program script being chosen for B2B Data Club
 AND auto_refill_counter IS NULL
 --CR22380 Handset protection excluded WARRANTY
 AND NVL(PP.X_PROG_CLASS,' ') <> 'WARRANTY'
 )
 );
 -- CR17276 End KACOSTA 7/26/2011
 SELECT SUM(x_access_days) ,
 SUM(x_units)
 INTO p_program_days ,
 p_program_units
 FROM table_x_promotion
 WHERE objid IN (SELECT x_promo_incl_min_at
 FROM x_program_parameters
 WHERE objid = v_program_objid
 UNION
 SELECT x_incl_service_days
 FROM x_program_parameters
 WHERE objid = v_program_objid
 );
 EXCEPTION WHEN OTHERS
 THEN
 NULL;
 END;--}
-- CR16987 Start KACOSTA 07/25/2011
 BEGIN --{
--
 p_rate_plan := service_plan.f_get_esn_rate_plan_all_status(p_esn => p_esn);
--
 EXCEPTION WHEN OTHERS
 THEN
--
 p_rate_plan := NULL;
--
 END; --}
-- CR16987 End KACOSTA 07/25/2011
 p_error_num := 0;
END get_program_info; --}




FUNCTION sf_is_multitank_mode(
p_esn IN VARCHAR2)
RETURN NUMBER
AS
/* p_multi_tank NUMBER := 0;
BEGIN
BEGIN
SELECT 1
INTO p_multi_tank
FROM ( SELECT 1
FROM table_x_code_hist ch,table_x_call_trans ct
WHERE ct.objid = ch.code_hist2call_trans
AND x_service_id= p_esn
AND x_code_type = 'PROD_ST_MT'
AND x_code_accepted ='YES'
ORDER BY X_SEQUENCE DESC )
WHERE ROWNUM < 2;
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
RETURN p_multi_tank; */
-- CR20451 | CR20854: Add TELCEL Brand this is the original a
-- cursor c1 is
-- select bo.org_id
-- from table_part_inst pi,
-- table_mod_level ml,
-- table_part_num pn,
--table_bus_org bo
--WHERE 1=1
--AND pi.part_serial_no = p_esn
--AND ml.objid = pi.n_part_inst2part_mod
--and pn.objid = ml.part_info2part_num
--and bo.objid = pn.part_num2bus_org
--and bo.org_id||'' = 'STRAIGHT_TALK';
-- CR20451 | CR20854: Add TELCEL Brand this is the new, changed the org_id for the org_flow
CURSOR c1
IS
SELECT bo.org_flow,
bo.org_id
FROM table_part_inst pi,
table_mod_level ml,
table_part_num pn,
table_bus_org bo
WHERE 1 = 1
AND pi.part_serial_no = p_esn
AND ml.objid = pi.n_part_inst2part_mod
AND pn.objid = ml.part_info2part_num
AND bo.objid = pn.part_num2bus_org
AND bo.org_flow IN ('2','3') ;
-- and bo.org_id||'' = 'STRAIGHT_TALK';
c1_rec c1%ROWTYPE;
CURSOR c2
IS
SELECT x_code_type
FROM table_x_call_trans ct,
table_x_code_hist ch
WHERE 1 = 1
AND ct.x_service_id = p_esn
-- CR30008 ADDED NET10
AND ct.x_sub_sourcesystem IN ('STRAIGHT_TALK','NET10')
-- AND ct.x_sub_sourcesystem = 'STRAIGHT_TALK'
AND ch.code_hist2call_trans = ct.objid
AND ch.x_code_type IN ('PROD_ST_MT' ,'PROD_ST_UL')
AND ch.x_code_accepted = 'YES'
ORDER BY ch.x_sequence DESC;
c2_rec c2%ROWTYPE;
BEGIN
OPEN c1;
FETCH c1 INTO c1_rec;
IF c1%NOTFOUND THEN
CLOSE c1;
RETURN 0;
END IF;
CLOSE c1;
OPEN c2;
FETCH c2 INTO c2_rec;
--dbms_output.put_line('c2_rec.x_code_type:'||c2_rec.x_code_type);
IF c2%FOUND AND c2_rec.x_code_type = 'PROD_ST_MT' THEN
CLOSE c2;
RETURN 1;
END IF;
CLOSE c2;
RETURN 0;
EXCEPTION
WHEN OTHERS THEN
RETURN 0;
END sf_is_multitank_mode;
--
--
PROCEDURE validate_security_pin(
p_esn IN VARCHAR2 ,
p_pin IN VARCHAR2 ,
p_brand_name IN VARCHAR2 ,
p_is_valid OUT INTEGER ,
p_web_objid OUT VARCHAR2 ,
p_contact_objid OUT VARCHAR2 ,
p_error_code OUT NUMBER ,
p_error_msg OUT VARCHAR2 )
IS
/*****************************************************************
* Procedure Name: validate_security_pin
* Purpose : validate pin to serial number and brand name
*
* Input parameter: serial number, pin, brand name
* Output: to return 1 if it is valid and 0 otherwise
*
************************************************************************/
CURSOR get_info_esn(ip_esn VARCHAR2)
IS
SELECT pi.objid ,
pi.part_serial_no esn ,
pi.x_part_inst2site_part
FROM sa.table_part_inst pi
WHERE pi.x_domain = 'PHONES'
AND pi.part_serial_no = ip_esn;
CURSOR get_info_tracf_net(ip_objidesn NUMBER)
IS
SELECT xof.x_spp_pin_on security_pin ,
web.objid web_objid ,
contact.objid contact_objid
FROM sa.table_x_ota_features xof ,
sa.table_x_contact_part_inst cpi ,
sa.table_web_user web ,
sa.table_contact contact
WHERE cpi.x_contact_part_inst2part_inst = ip_objidesn
AND cpi.x_contact_part_inst2contact = web.web_user2contact
AND contact.objid = web.web_user2contact
AND xof.x_ota_features2part_inst = ip_objidesn
AND ROWNUM = 1;
/*
CURSOR get_zipcode(ip_x_part_inst2site_part NUMBER) IS
SELECT sp.x_zipcode
FROM table_site_part sp
WHERE sp.objid = ip_x_part_inst2site_part;
*/
--cwl 5/1/13 CR23816
CURSOR get_zipcode
IS
SELECT sp.x_zipcode
FROM sa.table_part_inst pi ,
sa.table_x_contact_part_inst cpi ,
sa.table_x_contact_part_inst cpi2 ,
sa.table_part_inst pi2 ,
table_site_part sp
WHERE 1 =1
AND pi.part_serial_no = p_esn
AND pi.x_domain = 'PHONES'
AND cpi.x_contact_part_inst2part_inst = pi.objid
AND cpi2.X_CONTACT_PART_INST2CONTACT = cpi.X_CONTACT_PART_INST2CONTACT
AND pi2.objid = cpi2.x_contact_part_inst2part_inst
AND sp.objid = pi2.x_part_inst2site_part
AND sp.x_zipcode = p_pin;
CURSOR get_info_straighttalk(ip_esn VARCHAR2)
IS
SELECT pi.part_serial_no esn ,
cai.x_pin security_pin ,
web.objid web_objid ,
contact.objid contact_objid ,
pi.x_part_inst2site_part
FROM sa.table_x_contact_add_info cai ,
sa.table_x_contact_part_inst cpi ,
sa.table_part_inst pi ,
sa.table_web_user web ,
sa.table_contact contact
WHERE cpi.x_contact_part_inst2contact = cai.add_info2contact
AND cpi.x_contact_part_inst2part_inst = pi.objid
AND cpi.x_contact_part_inst2contact = web.web_user2contact
AND contact.objid = web.web_user2contact
AND pi.x_domain = 'PHONES'
AND pi.part_serial_no = ip_esn;
get_zipcode_rec get_zipcode%ROWTYPE;
get_info_straighttalk_rec get_info_straighttalk%ROWTYPE;
get_info_tracf_net_rec get_info_tracf_net%ROWTYPE;
get_info_esn_rec get_info_esn%ROWTYPE;
exc_inv_esn EXCEPTION;
exc_inv_pin EXCEPTION;
p_org_flow VARCHAR2(1) :='0' ;
PROCEDURE close_cursors
IS
BEGIN
IF get_info_esn%ISOPEN THEN
CLOSE get_info_esn;
END IF;
IF get_info_straighttalk%ISOPEN THEN
CLOSE get_info_straighttalk;
END IF;
IF get_zipcode%ISOPEN THEN
CLOSE get_zipcode;
END IF;
IF get_info_tracf_net%ISOPEN THEN
CLOSE get_info_tracf_net;
END IF;
END;
BEGIN
close_cursors;
p_error_code := 0;
p_error_msg := 'Success';
p_is_valid := 0;
-- CR20451 | CR20854: Add TELCEL Brand start
SELECT org_flow
INTO p_org_flow
FROM table_bus_org
WHERE org_id= p_brand_name ;
-- CR20451 | CR20854: Add TELCEL Brand end
OPEN get_info_esn(p_esn);
FETCH get_info_esn INTO get_info_esn_rec;
IF get_info_esn%NOTFOUND THEN
RAISE exc_inv_esn;
ELSE
CASE
WHEN p_brand_name = 'TRACFONE' OR p_brand_name = 'NET10' THEN
BEGIN
OPEN get_info_tracf_net(get_info_esn_rec.objid);
FETCH get_info_tracf_net INTO get_info_tracf_net_rec;
IF get_info_tracf_net%FOUND THEN
p_web_objid := get_info_tracf_net_rec.web_objid;
p_contact_objid := get_info_tracf_net_rec.contact_objid;
IF get_info_tracf_net_rec.security_pin IS NOT NULL AND get_info_tracf_net_rec.security_pin = p_pin THEN
p_is_valid := 1;
ELSE
-- CR16317 validate with zipcode if sa.table_x_contact_add_info.x_pin is null
/*
OPEN get_zipcode(get_info_esn_rec.x_part_inst2site_part);
FETCH get_zipcode
INTO get_zipcode_rec;
IF get_zipcode%FOUND
AND get_zipcode_rec.x_zipcode = p_pin THEN
p_is_valid := 1;
ELSE
RAISE exc_inv_pin;
END IF;
*/
OPEN get_zipcode;
FETCH get_zipcode INTO get_zipcode_rec;
IF get_zipcode%FOUND THEN
p_is_valid := 1;
ELSE
CLOSE get_zipcode;
RAISE exc_inv_pin;
END IF;
CLOSE get_zipcode;
END IF;
ELSE
RAISE exc_inv_esn;
END IF;
END;
WHEN p_org_flow = '3' THEN
BEGIN
OPEN get_info_straighttalk(p_esn);
FETCH get_info_straighttalk INTO get_info_straighttalk_rec;
IF get_info_straighttalk%FOUND THEN
p_web_objid := get_info_straighttalk_rec.web_objid;
p_contact_objid := get_info_straighttalk_rec.contact_objid;
IF get_info_straighttalk_rec.security_pin IS NOT NULL AND get_info_straighttalk_rec.security_pin = p_pin THEN
p_is_valid := 1;
ELSE
-- CR16317 validate with zipcode if sa.table_x_contact_add_info.x_pin is null
/*
OPEN get_zipcode(get_info_straighttalk_rec.x_part_inst2site_part);
FETCH get_zipcode
INTO get_zipcode_rec;
IF get_zipcode%FOUND
AND get_zipcode_rec.x_zipcode = p_pin THEN
p_is_valid := 1;
ELSE
RAISE exc_inv_pin;
END IF;
*/
OPEN get_zipcode;
FETCH get_zipcode INTO get_zipcode_rec;
IF get_zipcode%FOUND THEN
p_is_valid := 1;
ELSE
CLOSE get_zipcode;
RAISE exc_inv_pin;
END IF;
CLOSE get_zipcode;
END IF;
ELSE
RAISE exc_inv_esn;
END IF;
END;
ELSE
-- if no conditions met, then the following
p_error_code := 449;
p_error_msg := sa.get_code_fun('VALIDATE_SECURITY_PIN_PRC' ,p_error_code ,'ENGLISH');
p_is_valid := 0;
END CASE;
END IF;
close_cursors;
EXCEPTION
WHEN exc_inv_pin THEN
p_error_code := 448; --Invalid security pin
p_error_msg := sa.get_code_fun('VALIDATE_SECURITY_PIN_PRC' ,p_error_code ,'ENGLISH');
p_is_valid := 0;
WHEN exc_inv_esn THEN
p_error_code := 510; --Invalid ESN
p_error_msg := sa.get_code_fun('VALIDATE_SECURITY_PIN_PRC' ,p_error_code ,'ENGLISH');
p_is_valid := 0;
END validate_security_pin;
--
--
-- CR19041 CR21967
PROCEDURE validate_vas_security_pin(
p_web_user_objid IN VARCHAR2 ,
p_pin IN VARCHAR2 ,
p_is_valid OUT INTEGER ,
p_web_objid OUT VARCHAR2 ,
p_contact_objid OUT VARCHAR2 ,
p_error_code OUT NUMBER ,
p_error_msg OUT VARCHAR2 )
IS
/*****************************************************************
* Procedure Name: validate_vas_security_pin
* Purpose : validate pin to serial number and brand name
*
* Input parameter: table_web_user.objid, pin
* Output: to return 1 if it is valid and 0 otherwise
*
* per jonatan if pin matches any esn pin under the webuser
* or pin matches any activation zip code let them go thru
************************************************************************/
CURSOR web_info_curs
IS
SELECT wu.web_user2contact contact_objid
FROM table_web_user wu,
sa.table_x_contact_part_inst cpi,
sa.table_x_contact_part_inst cpi2
WHERE 1 =1
AND wu.objid = p_web_user_objid
AND cpi.x_contact_part_inst2contact = wu.web_user2contact
AND cpi2.X_CONTACT_PART_INST2CONTACT = cpi.X_CONTACT_PART_INST2CONTACT
AND ( EXISTS
(SELECT 1
FROM sa.table_x_contact_add_info cai
WHERE cai.x_pin = p_pin
AND cai.add_info2contact = cpi2.x_contact_part_inst2contact
)
OR EXISTS
(SELECT 1
FROM table_part_inst pi2,
table_site_part sp
WHERE 1 =1
AND pi2.objid = cpi2.x_contact_part_inst2part_inst
AND sp.objid = pi2.x_part_inst2site_part
AND sp.x_zipcode = p_pin
));
web_info_rec web_info_curs%rowtype;
BEGIN
OPEN web_info_curs;
FETCH web_info_curs INTO web_info_rec;
IF web_info_curs%notfound THEN
p_error_code := 450;
p_error_msg := sa.get_code_fun('VALIDATE_VAS_SECURITY_PIN_PRC' ,p_error_code ,'ENGLISH');
p_is_valid := 0;
CLOSE web_info_curs;
RETURN;
END IF;
CLOSE web_info_curs;
p_is_valid := 1;
p_web_objid := p_web_user_objid;
p_contact_objid := web_info_rec.contact_objid;
p_error_code := 0;
p_error_msg := 'Success';
END validate_vas_security_pin;
--
PROCEDURE tech_x_zipcode(
p_zipcode IN VARCHAR2 ,
p_cursor OUT SYS_REFCURSOR ,
op_err_num OUT NUMBER ,
op_err_string OUT VARCHAR2 )
IS
/*****************************************************************
* Procedure Name: TECH_X_ZIPCODE
* Purpose : to return the technologies supported for the list of Zipcodes
*
* Input parameter: Comma separated String for Zipcode eg: 33178,33175,33021
* Output: Ref cursor containing 2 attributes, Zipcode and Technology
*
* Created by : Mary Munoz
* Date : 06/30/2011
* Assumption : p_zipcode is a list of zip codes values separated by comma and valids
************************************************************************/
var_string VARCHAR2(2000);
sql_stmt VARCHAR2(6000);
BEGIN
var_string := p_zipcode;
SELECT TRIM(''''
|| REPLACE(var_string ,',' ,''',''')
|| '''')
INTO var_string
FROM sys.dual;
--DBMS_OUTPUT.PUT_LINE('new parameter: '||var_string);
-- Define query
sql_stmt := '';
sql_stmt := sql_stmt || 'SELECT distinct a.zip,';
sql_stmt := sql_stmt || ' decode(b.cdma_tech,''CDMA'',''CDMA'',b.gsm_tech) tech';
sql_stmt := sql_stmt || ' FROM carrierpref cp,';
sql_stmt := sql_stmt || ' npanxx2carrierzones b,';
sql_stmt := sql_stmt || ' (SELECT DISTINCT ';
sql_stmt := sql_stmt || ' a.zip,';
sql_stmt := sql_stmt || ' a.ZONE,';
sql_stmt := sql_stmt || ' a.st,';
sql_stmt := sql_stmt || ' s.sim_profile,';
sql_stmt := sql_stmt || ' a.county';
sql_stmt := sql_stmt || ' FROM carrierzones a, ';
sql_stmt := sql_stmt || ' carriersimpref s';
sql_stmt := sql_stmt || ' WHERE a.zip IN (' || var_string || ') ';
sql_stmt := sql_stmt || ' and a.CARRIER_NAME=s.CARRIER_NAME) a ';
sql_stmt := sql_stmt || 'WHERE ';
sql_stmt := sql_stmt || ' cp.st = b.state';
sql_stmt := sql_stmt || ' and cp.carrier_id = b.carrier_ID';
sql_stmt := sql_stmt || ' and cp.county = a.county';
sql_stmt := sql_stmt || ' and ( b.cdma_tech = ''CDMA''';
sql_stmt := sql_stmt || ' OR b.gsm_tech = ''GSM'' )';
sql_stmt := sql_stmt || ' and a.sim_profile = case when b.cdma_tech=''CDMA'' then ''NA''';
sql_stmt := sql_stmt || ' when b.gsm_tech =''GSM'' then decode(a.sim_profile,''NA'',''NULL'',a.sim_profile)';
sql_stmt := sql_stmt || ' else ''NULL''';
sql_stmt := sql_stmt || ' end';
sql_stmt := sql_stmt || ' AND b.ZONE = a.ZONE';
sql_stmt := sql_stmt || ' AND b.state = a.st';
BEGIN
-- DBMS_OUTPUT.PUT_LINE('script: '||sql_stmt);
OPEN p_cursor FOR sql_stmt;
op_err_num := 0;
IF p_cursor%ISOPEN THEN
op_err_string := 'Success Cursor Open';
ELSE
op_err_string := 'Success Cursor NOT Open';
END IF;
EXCEPTION
WHEN OTHERS THEN
op_err_num := SQLCODE;
op_err_string := SUBSTR(SQLERRM ,1 ,100);
END; -- open cursor
END tech_x_zipcode;
PROCEDURE BRAND_ESN
 (
 ip_esn in varchar2,
 ip_org_id in varchar2, -- ip_brand_objid number,
 ip_user in varchar2,
 op_result out varchar2,
 op_msg out varchar2,
 ip_sl_flag IN VARCHAR2 DEFAULT 'N', --50666
 ip_zipcode IN VARCHAR2 DEFAULT NULL,-- CR52423
 ip_Rebrand_Channel IN VARCHAR2 DEFAULT NULL
 )
IS
CURSOR validate_brand (ip_org_id VARCHAR2)
IS
SELECT objid,
org_id ,
SUBSTR(loc_type,1,2) prefix_pn
FROM table_bus_org
WHERE org_id = ip_org_id ;
validate_brand_r validate_brand%rowtype ;
CURSOR unbranded_cur (ip_esn VARCHAR2)
IS
SELECT pi.objid esn_objid,
pi.x_iccid,
pi.part_serial_no,
ml.objid ml_objid,
pn.part_number,
pn.part_num2bus_org,
pn.part_num2part_class,
bo.org_id,
pi.x_part_inst_status esn_part_inst_status --CR44390 fetch part inst status
FROM table_part_inst pi,
table_mod_level ml,
table_part_num pn,
table_bus_org bo
WHERE pi.n_part_inst2part_mod=ml.objid
AND ml.part_info2part_num = pn.objid
AND pn.part_num2bus_org = bo.objid
--and pi.x_part_inst_status <> '52'
--as long as its not active
AND pi.x_part_inst_status || '' IN ('50','59','150','51','54') --CR44390 Included status 59 as part of Defect16779.
AND pi.part_serial_no = ip_esn ;-- 100000000013246182 --'100000000013245842' ;
unbranded_rec unbranded_cur%rowtype ;
CURSOR get_mod_level (l_new_part_num VARCHAR2)
IS
SELECT ml.objid, pn.part_num2part_class
FROM table_mod_level ml,
table_part_num pn,
table_bus_org bo
WHERE ml.part_info2part_num=pn.objid
AND pn.part_number = l_new_part_num
AND pn.part_num2bus_org = bo.objid
AND (bo.ORG_ID = 'TRACFONE' OR exists (select '1' from sa.adfcrm_serv_plan_class_matview where part_class_objid = pn.part_num2part_class and rownum < 2) );
get_mod_level_r get_mod_level%rowtype ;
CURSOR get_mod_level2 (old_part_number VARCHAR2,new_org_id VARCHAR2)
IS
SELECT ml.objid,
pn2.part_num2part_class
FROM sa.table_x_class_exch_options xo,
sa.table_part_class pc2,
sa.table_part_num pn2,
sa.table_mod_level ml,
sa.table_bus_org bo
WHERE xo.SOURCE2PART_CLASS = pc2.objid
AND pc2.name IN
(SELECT 'GP'
||SUBSTR(pc1.name,3)
FROM sa.table_part_class pc1,
sa.table_part_num pn1
WHERE pn1.part_number = old_part_number
AND pn1.part_num2part_class = pc1.objid
)
AND xo.x_new_part_num = pn2.part_number
AND xo.x_exch_type = 'REBRANDING'
AND pn2.part_num2bus_org = bo.objid
AND bo.org_id = new_org_id
AND ml.part_info2part_num = pn2.objid
AND (bo.ORG_ID = 'TRACFONE'
OR EXISTS
(SELECT '1'
FROM sa.adfcrm_serv_plan_class_matview
WHERE part_class_objid = pn2.part_num2part_class
AND rownum < 2
) );
l_new_mod_level NUMBER ;
l_new_part_num VARCHAR2(30) ;
l_old_part_num VARCHAR2(30) ;
l_action VARCHAR2(50) ;
l_user VARCHAR2(30) := NVL(lower(ip_user),'sa') ;

--Re-Branding
cursor cur_zip is
SELECT INSTALL_DATE,X_ZIPCODE
FROM sa.table_site_part
WHERE x_service_id = ip_esn
and part_status = 'Inactive'
order by INSTALL_DATE desc;

rec_zip cur_zip%rowtype;

l_ppe number:=0;
l_4x number:=0;
l_line varchar2(30);
l_curr_carr_objid varchar2(30);
l_line_sts varchar2(5);
l_new_carr_id varchar2(30);
l_sim_sn varchar2(30);
l_sim_sts varchar2(5);
l_user_objid varchar2(30);
l_result varchar2(200);
l_repl_part varchar2(30);
l_repl_tech varchar2(30);
l_sim_profile varchar2(30);
l_part_serial_no varchar2(30);
l_msg varchar2(200);
l_pref_parent varchar2(30);
l_pref_carrier_objid varchar2(30);
v_parent_count number;
l_err_code varchar2(30);
l_err_msg varchar2(200);
l_leased_count number;
l_enroll_count number;
c_ignore_esn_update_flag VARCHAR2(1) := 'N'; --CR44390 Flag to skip status update
v_is_lte VARCHAR2(20); --CR46193
v_technology VARCHAR2(20); --CR46193
v_rebrand VARCHAR2(20); --CR46193
v_new_sim_part_no VARCHAR2(30); -- CR52423
v_ml_objid NUMBER; -- CR52423
v_ip_zipcode sa.table_site_part.x_zipcode%TYPE := ip_zipcode; -- CR52423
v_sim_type VARCHAR2(50);
v_to_pn sa.table_part_num.part_number%TYPE;

BEGIN
op_result := '0';
op_msg := 'ESN Branded';
l_new_mod_level :=0 ;
l_new_part_num := NULL ;
l_old_part_num := NULL ;
l_action := 'Validating the Brand';
OPEN validate_brand (ip_org_id) ;
FETCH validate_brand INTO validate_brand_r ;
IF validate_brand%notfound THEN
op_result := '131';
op_msg := get_code_fun('SA.PHONE_PKG','131','ENGLISH');
sa.ota_util_pkg.err_log (p_action => get_code_fun('SA.PHONE_PKG','131','ENGLISH') ,p_error_date => SYSDATE,p_key => ip_org_id ,p_program_name => 'SA.PHONE_PKG.BRAND_ESN' ,p_error_text => op_msg);
CLOSE validate_brand ;
RETURN ;
END IF ;
CLOSE validate_brand ;
l_action := 'Obtaining the part number';
OPEN unbranded_cur (ip_esn) ;
FETCH unbranded_cur INTO unbranded_rec ;
IF unbranded_cur%notfound THEN
op_result := '132';
op_msg := get_code_fun('SA.PHONE_PKG','132','ENGLISH');
sa.ota_util_pkg.err_log (p_action => get_code_fun('SA.PHONE_PKG','132','ENGLISH') ,p_error_date => SYSDATE,p_key => ip_esn ,p_program_name => 'SA.PHONE_PKG.BRAND_ESN' ,p_error_text => op_msg);
CLOSE unbranded_cur ;
RETURN ;
END IF ;
l_action := 'Obtaining the Mod Level';
--l_new_part_num := replace(unbranded_rec.part_number, 'GP', validate_brand_r.prefix_pn) ;
--CR42141 commented below added 1 line below such that it replaces only the first occurance
--l_new_part_num := REPLACE(unbranded_rec.part_number,SUBSTR(unbranded_rec.part_number,1,2),validate_brand_r.prefix_pn) ;
--l_new_part_num := regexp_REPLACE(unbranded_rec.part_number,SUBSTR(unbranded_rec.part_number,1,2),validate_brand_r.prefix_pn,1,1) ;
--CR46193 Start
BEGIN --{
SELECT 'Y'
INTO v_is_lte --pn.PART_NUMBER
FROM table_part_class pc,
table_bus_org bo,
table_part_num pn,
pc_params_view vw,
table_part_inst pi,
table_mod_level ml
WHERE pn.part_num2bus_org = bo.objid
AND pn.pArt_num2part_class = pc.objid
AND PC.NAME = VW.PART_CLASS
AND VW.PARAM_NAME = 'CDMA LTE SIM' --'DLL' --YM 07/13/2013
AND VW.PARAM_VALUE = 'REMOVABLE' --'-8' --YM 07/13/2013
AND PI.N_PART_INST2PART_MOD= ML.OBJID
AND ML.PART_INFO2PART_NUM = PN.OBJID
AND pi.part_serial_no = ip_esn;
EXCEPTION
WHEN OTHERS THEN
v_is_lte := 'N';
END; --}

BEGIN --{
SELECT tpn.x_technology
INTO v_technology
FROM table_part_inst esn,
table_mod_level tml,
table_part_num tpn
WHERE esn.n_part_inst2part_mod = tml.objid
AND tml.part_info2part_num = tpn.objid
AND esn.part_serial_no = ip_esn
AND esn.x_domain = 'PHONES'
AND ROWNUM = 1;
EXCEPTION
WHEN OTHERS THEN
v_technology := '';
END; --}

IF ip_sl_flag = 'Y' --50666
THEN --{
 get_sl_equi_phone
 (
 ip_esn,
 ip_org_id,
 l_new_part_num,
 v_rebrand,
 op_result,
 op_msg
 );
ELSIF v_technology = 'CDMA'
THEN --}{
 get_cdma_rebrand_pn
 (
 ip_esn,
 v_is_lte,
 ip_org_id,
 l_new_part_num,
 v_rebrand,
 op_result,
 op_msg,
 ip_zipcode,
 v_new_sim_part_no
 );
ELSE --}{
 l_new_part_num := regexp_REPLACE(unbranded_rec.part_number,SUBSTR(unbranded_rec.part_number,1,2),validate_brand_r.prefix_pn,1,1) ;
END IF; --}
--CR46193 End

OPEN get_mod_level (l_new_part_num) ;
FETCH get_mod_level INTO get_mod_level_r ;
IF get_mod_level%notfound THEN
CLOSE get_mod_level ;
OPEN get_mod_level2 (unbranded_rec.part_number,ip_org_id) ;
FETCH get_mod_level2 INTO get_mod_level_r ;
IF get_mod_level2%notfound THEN
op_result := '133';
op_msg := get_code_fun('PHONE_PKG','133','ENGLISH');
sa.ota_util_pkg.err_log (p_action => get_code_fun('PHONE_PKG','133','ENGLISH') ,p_error_date => SYSDATE,p_key => l_new_part_num ,p_program_name => 'PHONE_PKG.BRAND_ESN' ,p_error_text => op_msg);
CLOSE get_mod_level2;
RETURN ;
ELSE
CLOSE get_mod_level2;
END IF ;
ELSE
CLOSE get_mod_level ;
END IF ;

--
-- BLOCK PPE START: Phones Previosu to Toolkit 4.X
select count(*) into l_4x
From Table_X_Part_Class_Values ,Table_X_Part_Class_Params
WHERE value2part_class = unbranded_rec.part_num2part_class
And Value2class_Param= Table_X_Part_Class_Params.Objid
and x_param_name in ( 'FIRMWARE' )
and x_param_value >= '4.X';

select count(*) into l_ppe
From Table_X_Part_Class_Values ,Table_X_Part_Class_Params
WHERE value2part_class = unbranded_rec.part_num2part_class
And Value2class_Param = Table_X_Part_Class_Params.Objid
and x_param_name in ( 'DEVICE_TYPE' )
and x_param_value ='FEATURE_PHONE';

if l_ppe>0 and l_4x=0 then --Block Old PPE Phones
op_result := '135';
op_msg := get_code_fun('PHONE_PKG','135','ENGLISH');
sa.ota_util_pkg.err_log (p_action => get_code_fun('PHONE_PKG','135','ENGLISH') ,p_error_date => SYSDATE,p_key => l_new_part_num ,p_program_name => 'PHONE_PKG.BRAND_ESN' ,p_error_text => op_msg);
RETURN;
end if;
--
-- CHECK FOR LEASED PHONES
--
select count('1') into l_leased_count
from sa.x_customer_lease cl ,
sa.x_lease_status ls
where cl.x_esn = ip_esn
and cl.lease_status = ls.lease_status
and unbranded_rec.org_id <> 'GENERIC';

if l_leased_count > 0 then
op_result := '137';
op_msg := get_code_fun('PHONE_PKG','137','ENGLISH');
RETURN;
end if;
--
-- CHECK FOR ACTIVE ENROLLMENTS
select count('1') into l_enroll_count
from x_program_enrolled,x_program_parameters
where x_esn = ip_esn
and pgm_enroll2pgm_parameter = x_program_parameters.objid
and x_enrollment_status = 'ENROLLED';

--CR46193
/*if l_enroll_count > 0 then
op_result := '138';
op_msg := get_code_fun('PHONE_PKG','138','ENGLISH');
RETURN;
end if;*/--CR46193
--
-- SAVE LINE / CARRIER INFO
begin
select pi.part_serial_no,pi.x_part_inst_status,table_x_carrier.objid
into l_line,l_line_sts,l_curr_carr_objid
from sa.table_part_inst pi, table_x_carrier
where pi.part_to_esn2part_inst = unbranded_rec.esn_objid
and pi.x_domain = 'LINES'
and substr(pi.part_serial_no,1,1) <> 'T'
and pi.part_inst2carrier_mkt = table_x_carrier.objid
and rownum <2;
exception
when others then
null;
end;
-- SAVE SIM INFO
begin
if unbranded_rec.x_iccid is not null then
select sim.x_sim_serial_no, sim.x_sim_inv_status
into l_sim_sn,l_sim_sts
from sa.table_x_sim_inv sim
where sim.x_sim_serial_no = unbranded_rec.x_iccid;
end if;
exception
when others then null;
end;

/*
l_action := 'updating table_part_inst';
UPDATE table_part_inst
SET n_part_inst2part_mod = get_mod_level_r.objid,
x_part_inst2contact = NULL
WHERE part_serial_no = ip_esn ;
DELETE
FROM TABLE_X_CONTACT_PART_INST
WHERE X_CONTACT_PART_INST2PART_INST IN
(SELECT OBJID FROM TABLE_PART_INST WHERE PART_SERIAL_NO = IP_ESN
) ;
COMMIT ;
*/
-- RE-BRAND USING REFURBISHING PROCESS
l_action := 'refurb - rebranding';
begin
    select objid
    into l_user_objid
    from sa.table_user
    where lower(login_name) = l_user;
exception
   when others then
    op_result := '136';
    op_msg := get_code_fun('PHONE_PKG','136','ENGLISH');
    RETURN;
end;

--CR44390 - Skip the Status update if the status is 59.
IF unbranded_rec.esn_part_inst_status = '59' THEN
   c_ignore_esn_update_flag := 'Y';
ELSE
   c_ignore_esn_update_flag := 'N';
END IF;

sp_clarify_refurb_prc( ip_esn => ip_esn,
                        ip_reset_date => sysdate,
                        ip_order_num => null,
                        ip_user_objid => l_user_objid,
                        ip_mod_objid => get_mod_level_r.objid,
                        ip_bin_objid => null,
                        ip_action_type => 'REFURBISHED',
                        ip_initial_pi_status => '50',
                        ip_caller_program => 'BRAND ESN',
                        ip_ship_date => null,
                        op_result => l_result,
                         i_ignore_esn_update_flag => c_ignore_esn_update_flag  );  --CR44390 flag to skip part inst status update to 50

if l_result='Success' then

--47491 start
IF ip_org_id = 'TRACFONE'
THEN --{
UPDATE table_site_part
SET    x_expire_dt = TRUNC(SYSDATE) - 1
WHERE  objid =
               (SELECT objid
                FROM (SELECT inn.objid
                     FROM   table_site_part inn
                     WHERE  inn.x_service_id = ip_esn
                     AND    TO_CHAR(inn.x_expire_dt, 'MM/DD/YYYY') <> '01/01/1753'
                     ORDER  BY inn.update_stamp DESC)
               WHERE ROWNUM = 1)
AND x_expire_dt > SYSDATE;
END IF; --}
--47491 end

   brand_x_pkg.expire_account_group ( ip_esn      => ip_esn ,
                                     op_err_code => l_err_code ,
                                     op_err_msg  => l_err_msg  );

  l_action := 'Creating the log';

   -- CR56982 Added TF_PART_NUM_OLD and  TF_BRANDING_CHANNEL Columns to Capture Old Part Number and  Branding Channel

  l_old_part_num := unbranded_rec.part_number;

  INSERT INTO X_BRANDED_TRANS ( objid,TF_PART_NUM_PARENT,TF_SERIAL_NUM,TF_EXTRACT_FLAG,TF_EXTRACT_DATE,LOG_DATE,TF_PART_NUM_OLD,TF_BRANDING_CHANNEL)
  VALUES (sequ_branded_TRANS.NEXTVAL,l_new_part_num,ip_esn,'N', NULL, SYSDATE,l_old_part_num,ip_Rebrand_Channel) ;

  COMMIT ;

  -- RE-ATTACH SIM, RESTORE STATUS
  if unbranded_rec.x_iccid is not null then

        -- CR52423 tas universal branding.
      -- Tim 8/30/2017
      -- If Nap returns null pref parent and CDMA and LTE then get the first sim for the BYOP partnumber found.
      --
      -- If CDMA and LTE
      IF v_technology = 'CDMA' and v_is_lte = 'Y'  and get_device_type(ip_esn) = 'BYOP'
      THEN --{

             -- Get the ml objid for update
             IF v_new_sim_part_no IS NOT NULL
             THEN --{
             SELECT ml.objid
               INTO v_ml_objid
               FROM table_part_num pn,
                    table_mod_level ml
              WHERE part_number = NVL(v_new_sim_part_no, part_number) --NEW SIM PART NO
                AND ml.part_info2part_num=pn.objid;

             -- Update the sim inv to use mod level for new sim part number.
             UPDATE table_x_sim_inv
                SET x_sim_inv2part_mod = v_ml_objid
              WHERE X_Sim_Serial_No  = unbranded_rec.x_iccid;
             END IF; --}


      END IF; --}  /* v_technology */ -- CR52423 END tas universal branding.

        -- Set the sim status.
        UPDATE table_x_sim_inv
           SET x_sim_inv_status =  DECODE(ip_org_id, 'TRACFONE', '253', l_sim_sts) --As part of TF rebranding CR47491
         WHERE x_sim_serial_no  =  l_sim_sn;

        -- Set the part inst to the new sim.
        UPDATE table_part_inst
           SET x_iccid = l_sim_sn
        WHERE part_serial_no = ip_esn;

        COMMIT;

  end if;  /* unbranded_rec.x_iccid */

  -- RESTORE RESERVED LINE
  if l_line is not null and l_line_sts in ('37','39') then
     update sa.table_part_inst
     set part_to_esn2part_inst = (select objid from sa.table_part_inst where part_serial_no = ip_esn and x_domain = 'PHONES'),
         x_part_inst_status = l_line_sts,
         status2x_code_table = (select objid from sa.table_x_code_table where x_code_number = l_line_sts)
     where part_serial_no = l_line
     and x_domain = 'LINES';

     commit;
    --Get Zip Code / NAP Check
    open cur_zip;
    fetch cur_zip into rec_zip;
    if cur_zip%found then
        close cur_zip;
        sa.  NAP_DIGITAL(
        P_ZIP => rec_zip.x_zipcode,
        P_ESN => ip_esn,
        P_COMMIT => 'N',
        P_LANGUAGE => 'English',
        P_SIM => l_sim_sn,
        P_SOURCE => 'TAS',
        P_UPG_FLAG => 'N',
        P_REPL_PART => l_repl_part,
        P_REPL_TECH => l_repl_tech,
        P_SIM_PROFILE => l_sim_profile,
        P_PART_SERIAL_NO => l_part_serial_no,
        P_MSG => l_msg,
        P_PREF_PARENT => l_pref_parent,
        P_PREF_CARRIER_OBJID => l_pref_carrier_objid
      );

      --Move Line if carrier not match but same parent
      if l_pref_carrier_objid<>l_curr_carr_objid  then

        select count(distinct pa.x_queue_name)
        into v_parent_count
        from sa.table_x_parent pa, sa.table_x_carrier_group grp,sa.table_x_carrier ca
        where ca.carrier2carrier_group = grp.objid
        and grp.x_carrier_group2x_parent = pa.objid
        and ca.objid in (l_pref_carrier_objid,l_curr_carr_objid);

        if v_parent_count = 1 then -- same parent, we can move line
           update sa.table_part_inst
           set part_inst2carrier_mkt = l_pref_carrier_objid
           where part_serial_no = l_line
           and x_domain = 'LINES';
           commit;
        end if;
      end if;
    else
       close cur_zip;
    end if;
  end if;
else
    op_result := '130';
    op_msg := get_code_fun('PHONE_PKG','130','ENGLISH');
    RETURN;
end if;

EXCEPTION
WHEN OTHERS THEN
IF unbranded_cur%isopen THEN
CLOSE unbranded_cur ;
END IF ;
IF validate_brand%isopen THEN
CLOSE validate_brand ;
END IF ;
IF get_mod_level%isopen THEN
CLOSE get_mod_level ;
END IF ;
op_result := '130';
op_msg := get_code_fun('PHONE_PKG','130','ENGLISH');
sa.ota_util_pkg.err_log (p_action => get_code_fun('PHONE_PKG','130','ENGLISH') ,p_error_date => SYSDATE,p_key => ip_esn ,p_program_name => 'PHONE_PKG.BRAND_ESN' ,p_error_text => op_msg);
END ;
----
PROCEDURE SETESNATTRIBUTES
(
IN_ESN IN VARCHAR2,
IO_KEY_TBL IN OUT KEYS_TBL
)
IS
CURSOR C1_Cur
IS
SELECT Cpi.Objid objid
FROM Table_X_Contact_Part_Inst Cpi,
Table_Part_Inst Pi
WHERE Pi.Objid = Cpi.X_Contact_Part_Inst2part_Inst
AND X_Domain = 'PHONES'
AND Part_Serial_No = In_Esn
AND rownum < 2 ;---'100000000013374843'
C1_Rec C1_Cur%Rowtype;
BEGIN
IF (in_esn IS NULL) OR (Io_Key_Tbl.Count = 0) THEN
io_KEY_TBL.extend;
io_KEY_TBL(io_KEY_TBL.first):= Keys_obj(NULL,-1,'Valid Inputs Required' );
RETURN;
END IF;
FOR I IN io_KEY_TBL.FIRST..io_KEY_TBL.LAST
LOOP
IF (Io_Key_Tbl.Count > 0) THEN
OPEN C1_Cur;
FETCH C1_CUR INTO C1_REC;
IF C1_CUR%NOTFOUND THEN
IO_KEY_TBL(i).key_VALUE := '-1';
IO_KEY_TBL(i).RESULT_VALUE := 'ESN Contact Nickname '||SUBSTR(SQLERRM, 1,100);
CLOSE C1_CUR;
RETURN;
END IF;
CLOSE C1_CUR;
END IF;
IF (Io_Key_Tbl(i).Key_Type NOT IN ('NICKNAME')) OR (Io_Key_Tbl(i).Key_Value IS NULL) THEN
IO_KEY_TBL(i).key_VALUE := '-1';
Io_Key_Tbl(I).RESULT_VALUE := 'Key Values Required';
END IF;
IF (Io_Key_Tbl(I).KEY_TYPE IN ('NICKNAME')) AND (Io_Key_Tbl(I).KEY_VALUE IS NOT NULL) THEN
UPDATE Table_X_Contact_Part_Inst Cpi
SET X_Esn_Nick_Name = Io_Key_Tbl(i).Key_Value
WHERE Objid = C1_Rec.Objid;
Io_Key_Tbl(I).RESULT_VALUE := 'success';
ELSE
Io_Key_Tbl(I).RESULT_VALUE := 'failed';
END IF;
END LOOP;
EXCEPTION
WHEN OTHERS THEN
--
ROLLBACK;
TOSS_UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => NULL, IP_KEY => SUBSTR(IN_ESN||';', 1, 50), IP_PROGRAM_NAME => 'PHONE_PKG.SETESNATTRIBUTES', iP_Error_Text => 'Key Values Required');
--
END SETESNATTRIBUTES;
--------------------------------------------------------------------------------------------------------
PROCEDURE Getesnattributes(
In_Esn IN Table_Part_Inst.Part_Serial_No%Type,
Io_Key_Tbl IN OUT Keys_Tbl)
IS
V_KEY_TBL KEYS_TBL := KEYS_TBL();
V_RETURN_UNLOCK_PROCESS VARCHAR2(100);
V_ERR_NUM INTEGER;
V_ERR_STRING VARCHAR2(300);
L_SERVICEPLANID NUMBER;
L_SERVICEPLANNAME sa.X_SERVICE_PLAN.DESCRIPTION%TYPE;
L_SERVICEPLANUNLIMITED NUMBER ; --1 if true and 0 if false
L_AUTOREFILL NUMBER ; --1 if true and 0 if false
L_SERVICE_END_DT DATE;
l_Forecast_date DATE;
L_CREDITCARDREG NUMBER; --1 if true and 0 if false
L_REDEMPCARDQUEUE NUMBER;
L_CREDITCARDSCH NUMBER ; --1 if true and 0 if false
L_STATUSID VARCHAR2(50);
L_STATUSDESC VARCHAR2(80);
L_EMAIL VARCHAR2(50);
L_PART_NUM VARCHAR2(40);
ESN_exist NUMBER;
l_service_part_num VARCHAR2(40);
l_carier VARCHAR2(40);
l_billing_part_num VARCHAR2(40);
l_enrl_status VARCHAR2(40);
L_ENROLLMENT_STATUS VARCHAR2(40);
L_SAFELINK_IN VARCHAR2(40);  --CR35801
v_throttle_status NUMBER;
L_TITLE         VARCHAR2(80);
L_CSR_TEXT      Varchar2(2000);
L_SPA_TEXT      VARCHAR2(2000);
L_IVR_SCRIPT_ID VARCHAR2(10);
L_TTS_SPANISH   VARCHAR2(2000);
L_TTS_ENGLISH   VARCHAR2(2000);
L_IS_FLASH_HOT  VARCHAR2(10);
L_FLASH_TEXT    VARCHAR2(2000);
v_sub_bnd       sa.pcpv_mv.sub_brand%type; -- CR50073 Added sub_brand field.
v_sub_brand     sa.pcpv_mv.sub_brand%type; -- CR50073 Added sub_brand field.
v_service_plan  sa.x_service_plan%rowtype; -- CR50073 Added to get customer price field.
v_retail_price  sa.table_x_pricing.x_retail_price%type; -- CR50073 Added to get customer price field.
v_is_safelink   VARCHAR2(20);
CURSOR get_esn_info_cur(In_Esn table_part_inst.part_serial_no%TYPE)
IS
SELECT esn.part_serial_no esn ,
esn.objid  partinst_objid,
esn.x_part_inst2site_part sitepart_objid ,
cpi.X_Esn_Nick_Name NICKNAME,
ESN.X_PART_INST_STATUS STATUS,
tpn.x_technology technology ,
TBO.ORG_ID BRAND ,
WU.LOGIN_NAME EMAIL,
ESN.X_ICCID SIM,
line.part_serial_no MIN,
CASE swa.objid
WHEN NULL
THEN 0
WHEN swa.objid
THEN 1
END b2b,
tpn.part_number part_num,
pc.name part_class,
tpn.x_sourcesystem,
--CR39303 - Added below two columns to incorporate DLL and Sequence
tpn.x_dll,
esn.x_sequence
FROM TABLE_PART_INST ESN,
table_part_inst line,
TABLE_MOD_LEVEL TML,
TABLE_PART_NUM TPN,
TABLE_PART_Class pc,
TABLE_BUS_ORG TBO,
TABLE_X_CONTACT_PART_INST CPI,
table_web_user wu,
x_site_web_accounts swa
WHERE 1 = 1
AND ESN.N_PART_INST2PART_MOD = TML.OBJID
AND TML.PART_INFO2PART_NUM = TPN.OBJID
AND TPN.PART_NUM2BUS_ORG = TBO.OBJID
AND tpn.part_num2part_class = pc.objid
AND ESN.OBJID = CPI.X_CONTACT_PART_INST2PART_INST(+)
AND CPI.X_CONTACT_PART_INST2CONTACT = wu.WEB_USER2CONTACT(+)
AND Wu.OBJID = SWA.SITE_WEB_ACCT2WEB_USER(+)
AND ESN.PART_SERIAL_NO = in_esn
AND ESN.X_DOMAIN = 'PHONES'
AND LINE.PART_TO_ESN2PART_INST(+) = ESN.OBJID
AND line.x_domain(+) = 'LINES';
GET_ESN_INFO_REC GET_ESN_INFO_CUR%ROWTYPE;

--
-- CR52025 Modified cursor to include active.
--

CURSOR esn_plan_cur (enrl_status VARCHAR2)
IS
SELECT autorefill,
       isunlimited,
       sp_name,
       sp_id,
       service_partnum,
       billing_partnum
FROM (
       SELECT r_num,
              autorefill,
              isunlimited,
              sp_name,
              sp_id,
              service_partnum,
              billing_partnum
        FROM (
              SELECT 1 r_num,
                     CASE
                     WHEN pp.x_charge_frq_code IS NOT NULL
                     THEN 1
                     ELSE 0
                      END autorefill,
                     CASE INSTR(upper(pp.x_program_name) ,'UNLIMITED' ,1 ,1)
                     WHEN 0
                     THEN 0
                     ELSE 1
                      END ISUNLIMITED,
                     sp.mkt_name sp_name,
                     sp.objid sp_id,
                     x_source_part_num service_partnum,
                     x_target_part_num1 billing_partnum
                FROM sa.x_program_parameters pp,
                     sa.x_program_enrolled pe,
                     x_service_plan sp,
                     mtm_sp_x_program_param mtm,
                     x_ff_part_num_mapping fm
               WHERE 1 = 1
                 AND pp.objid = pe.pgm_enroll2pgm_parameter
                 AND pgm_enroll2pgm_parameter = fm.x_ff_objid
                 AND mtm.x_sp2program_param = pp.objid
                 AND mtm.program_para2x_sp = sp.objid--find latest objid
                 AND x_esn = in_esn
                 AND pe.x_enrollment_status = NVL(enrl_status,pe.x_enrollment_status)
               UNION
              SELECT 2 r_num,
                    -- CASE
                    -- WHEN pp.x_charge_frq_code IS NOT NULL
                    -- THEN 1
                    -- ELSE 0
                     -- END autorefill, --This statement should return 0 for AR, CR53564
                     0 autorefill,
                    CASE INSTR(upper(pp.x_program_name) ,'UNLIMITED' ,1 ,1)
                    WHEN 0
                    THEN 0
                    ELSE 1
                     END ISUNLIMITED,
                    xsp.mkt_name sp_name,
                    xsp.objid sp_id,
                    x_source_part_num service_partnumber,
                    x_target_part_num1 billing_partnumber
               FROM x_ff_part_num_mapping fm,
                    adfcrm_serv_plan_feat_matview mat,
                    x_service_plan_site_part sp,
                    table_site_part tsp,
                    x_service_plan xsp,
                    table_part_num tpn,
                    x_program_parameters pp
              WHERE fm.x_source_part_num = mat.fea_value
                AND mat.sp_objid = sp.x_service_plan_id
                AND sp.table_site_part_id = tsp.objid
                AND xsp.objid = mat.sp_objid
                AND tsp.x_service_id = in_esn
                AND tsp.part_status = 'Active'
                AND fm.x_target_part_num1 = tpn.part_number
                AND pp.prog_param2prtnum_enrlfee = tpn.objid
                AND mat.fea_name = 'PLAN_PURCHASE_PART_NUMBER'
                 )
                 ORDER BY r_num)
        WHERE ROWNUM < 2;

CURSOR pcpv_cur(ip_class in varchar2) is
select * from sa.pcpv_mv pcpv where part_class=ip_class; --CR47564 WFM changed to use pcpv_mv from pcpv view to improve performance

pcpv_rec    pcpv%rowtype;
esn_plan_rec esn_plan_cur%rowtype;
-- CR39389 Changes starts.
-- instantiate initial values
rc     sa.customer_type  := customer_type ( i_esn => in_esn );
-- type to hold retrieved attributes
cst    sa.customer_type;
-- CR39389 Changes Ends.
  -- CR39592 Start PMistry Added New for FCC to get the DEVICE_UNLOCK_STATUS.
  cursor unlock_esn_status_cur is
      select unlock_status
      from  sa.unlock_esn_status uspc
      where uspc.esn = In_Esn;

  unlock_esn_status_rec   unlock_esn_status_cur%rowtype;
  -- CR39592 End

  --CR50154 ST LTO changes
  l_is_service_active   VARCHAR2(1);
  l_last_redm_plan_part_num  splan_feat_pivot.plan_purchase_part_number%type;
  l_last_redm_plan_pc        table_part_class.name%type;
  ret_code                  VARCHAR2(100);
  ret_msg                   VARCHAR2(500);
  l_forecast_enddate        DATE;
  l_queued_service_days     NUMBER;
  l_autorefill_flag         NUMBER;

BEGIN
SELECT COUNT(*)
INTO ESN_exist
FROM table_part_inst
WHERE part_serial_no = in_esn;
IF ESN_exist = 0 THEN
v_err_num := -1;
V_ERR_STRING := 'ESN doesnot exists'|| SUBSTR(SQLERRM, 1,200);
io_KEY_TBL(1).RESULT_VALUE := V_ERR_STRING;
RETURN;
END IF;
IF (Io_Key_Tbl.Count = 0) THEN
V_ERR_NUM := 134; ---Input Key Value List Required.
V_ERR_STRING := sa.GET_CODE_FUN('PHONE_PKG', V_ERR_NUM, 'ENGLISH');
io_KEY_TBL(1).RESULT_VALUE := V_ERR_STRING;
RETURN;
END IF;
IF (Io_Key_Tbl.Count > 0) THEN
V_Key_Tbl := IO_KEY_TBL;
END IF;
OPEN get_esn_info_cur(In_Esn);
FETCH get_esn_info_cur INTO get_esn_info_rec;
IF get_esn_info_cur%notfound THEN
CLOSE get_esn_info_cur;
ELSE
IF GET_ESN_INFO_REC.STATUS IN('52', '50') THEN
SERVICE_PLAN.GET_SERVICE_PLAN_PRC( IP_ESN => IN_ESN, OP_SERVICEPLANID => l_SERVICEPLANID, OP_SERVICEPLANNAME => l_SERVICEPLANNAME, OP_SERVICEPLANUNLIMITED => l_SERVICEPLANUNLIMITED, OP_AUTOREFILL => l_AUTOREFILL, OP_SERVICE_END_DT => l_SERVICE_END_DT, OP_FORECAST_DATE => L_FORECAST_DATE, OP_CREDITCARDREG =>l_CREDITCARDREG, OP_REDEMPCARDQUEUE => l_REDEMPCARDQUEUE, OP_CREDITCARDSCH => l_CREDITCARDSCH, OP_STATUSID => l_STATUSID, OP_STATUSDESC => l_STATUSDESC, OP_EMAIL => L_EMAIL, OP_PART_NUM => L_PART_NUM, OP_ERR_NUM => V_ERR_NUM, OP_ERR_STRING => v_ERR_STRING );
END IF;
--
-- CR39389 call the customer type retrieve method
cst := rc.retrieve;
--
OPEN pcpv_cur(get_esn_info_rec.part_class);
FETCH pcpv_cur  INTO pcpv_rec;
CLOSE pcpv_cur;

--CR50154 - ST LTO - Start
BEGIN
                SELECT --sp.x_zipcode zipcode,
       DECODE(part_status,'Active','Y','N')
                INTO -- l_zipcode,
                                   l_is_service_active
                FROM  table_site_part sp
                WHERE  1 = 1
                AND    sp.x_service_id = in_esn
                AND    sp.install_date = ( SELECT MAX(install_date)
                                                                                                                                FROM   table_site_part
                                                                                                                                WHERE  x_service_id = sp.x_service_id
                                                                                                                  )
                AND    ROWNUM = 1;
EXCEPTION
    WHEN OTHERS THEN
                    NULL;
END ;

BEGIN
  SELECT NVL(sa.util_pkg.get_queued_days (in_esn),0)
    INTO l_queued_service_days
   FROM DUAL ;
EXCEPTION
   WHEN OTHERS THEN
    l_queued_service_days := 0;
END ;

BEGIN
                SELECT 1
                INTO l_autorefill_flag
                FROM sa.x_program_parameters pp
                WHERE pp.objid =
                   (SELECT MAX(pe.pgm_enroll2pgm_parameter) --find latest objid
                   FROM sa.x_program_enrolled pe
                   WHERE 1 = 1
                   AND pe.pgm_enroll2site_part = get_esn_info_rec.sitepart_objid
                   AND pe.pgm_enroll2part_inst = get_esn_info_rec.partinst_objid
                   AND pe.x_enrollment_status = 'ENROLLED'
                   AND x_is_recurring  = 1
                   );
EXCEPTION
   WHEN NO_DATA_FOUND THEN
    l_autorefill_flag := 0;
END ;

DBMS_OUTPUT.PUT_LINE ('l_service_end_dt'||l_service_end_dt);
DBMS_OUTPUT.PUT_LINE ('l_queued_service_days'||l_queued_service_days);
DBMS_OUTPUT.PUT_LINE ('l_autorefill_flag'||l_autorefill_flag);

l_forecast_enddate := l_service_end_dt + l_queued_service_days;

DBMS_OUTPUT.PUT_LINE ('l_forecast_enddate'||l_forecast_enddate);

  get_last_red_details(in_esn,
                       l_last_redm_plan_part_num,
                       l_last_redm_plan_pc,
                       ret_code,
                       ret_msg );

IF l_last_redm_plan_part_num LIKE '%APPAR%' THEN
    BEGIN
      SELECT  plan_purchase_part_number
      INTO    l_last_redm_plan_part_num
      FROM    splan_feat_pivot pv
      WHERE   pv.plan_purchase_part_number = replace(l_last_redm_plan_part_num,'AR','')
      AND     ROWNUM < 2;
      --
      SELECT  pc.name
      INTO    l_last_redm_plan_pc
      FROM    table_part_class  pc,
              table_part_num    pn
      WHERE   pn.part_num2part_class      = pc.objid
      AND     pn.part_number              = l_last_redm_plan_part_num;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT  pc.name, pn.part_number
          INTO    l_last_redm_plan_pc, l_last_redm_plan_part_num
          FROM    table_part_num    pn,
                  table_part_num    pn2,
                  table_x_pricing   xp,
                  table_part_class  pc
          WHERE   pn2.part_number         =  l_last_redm_plan_part_num
          AND     pn.part_number          LIKE 'TSAPP%'
          AND     pn.part_number          NOT LIKE '%FREE'
          AND     pn.objid                = xp.X_PRICING2PART_NUM
          AND     xp.X_CHANNEL            = 'IVR'
          AND     SYSDATE BETWEEN xp.X_START_DATE and NVL(xp.x_end_date , sysdate)
          AND     pn.part_num2part_class  = pc.objid
      --    AND     pn2.x_redeem_days       = pn.x_redeem_days
          AND     pn2.x_redeem_units      = pn.x_redeem_units;
        EXCEPTION
          WHEN OTHERS THEN
          NULL;
        END;
      WHEN OTHERS THEN
        NULL;
    END;
    --
  END IF;
--CR50154 ST LTO - End
FOR i IN V_Key_Tbl.FIRST..V_Key_Tbl.LAST
LOOP
IF (V_Key_Tbl(i).Key_Type IN ('NICKNAME')) THEN
V_Key_tbl(i).key_Value := get_esn_info_rec.NICKNAME;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_Key_Tbl(i).Key_Type IN ('BRAND')) THEN
V_Key_tbl(i).key_Value := get_esn_info_rec.BRAND;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;

  IF (V_Key_Tbl(i).Key_Type IN ('OPERATING_SYSTEM')) THEN
V_Key_tbl(i).key_Value := pcpv_rec.OPERATING_SYSTEM;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;

IF (V_Key_Tbl(i).Key_Type IN ('DEVICE_TYPE')) THEN
V_Key_tbl(i).key_Value := pcpv_rec.DEVICE_TYPE;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;

IF (V_Key_Tbl(i).Key_Type IN ('X_SOURCESYSTEM')) THEN
V_Key_tbl(i).key_Value := get_esn_info_rec.X_SOURCESYSTEM;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;

IF (V_Key_Tbl(i).Key_Type IN ('SIM')) THEN
V_Key_tbl(i).key_Value := get_esn_info_rec.SIM;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_Key_Tbl(i).Key_Type IN ('EMAIL')) THEN
V_Key_tbl(i).key_Value := get_esn_info_rec.EMAIL;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_KEY_TBL(I).KEY_TYPE IN ('STATUS')) THEN
V_KEY_TBL(i).KEY_VALUE := GET_ESN_INFO_REC.STATUS;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_KEY_TBL(I).KEY_TYPE IN ('TECHNOLOGY')) THEN
V_KEY_TBL(i).KEY_VALUE := GET_ESN_INFO_REC.TECHNOLOGY;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;

IF (v_key_tbl(i).key_type IN ('IS_FLASH_HOT')) THEN -- CR47564 WFM IS_FLASH_HOT attribute

  sa.alert_pkg.get_alert ( esn         =>in_esn,
                           step        => 0,
                           channel     => 'WEB',
                           title       => l_title,
                           csr_text    => l_csr_text,
                           eng_text    => l_flash_text,
                           spa_text    => l_spa_text,
                           ivr_scr_id  => l_ivr_script_id,
                           tts_english => l_tts_english,
                           tts_spanish => l_tts_spanish,
                           hot         => l_is_flash_hot,
                           err         => v_err_num,
                           msg         => v_err_string);

  v_key_tbl(i).key_value := l_is_flash_hot;
  SELECT nvl2( v_key_tbl(i).key_value ,'success','Fail')
  INTO v_key_tbl(i).result_value
  FROM dual;
END IF;

  IF (v_key_tbl(i).key_type in ('WEB_USER_OBJID','ZIPCODE')) THEN
    cst   := rc.get_web_user_attributes;
    --CR54905: Begin Code Changes
	if (v_key_tbl(i).key_type='ZIPCODE')
	then
		v_key_tbl(i).key_value := to_char(cst.zipcode);
    elsif (v_key_tbl(i).key_type='WEB_USER_OBJID')
	then
		v_key_tbl(i).key_value := cst.web_user_objid;
	end if;
	--CR54905: End Code Changes

/*    v_key_tbl(i).key_value := case
                                when v_key_tbl(i).key_type='ZIPCODE' THEN cst.zipcode
                                ELSE cst.web_user_objid
                              END; */
    SELECT nvl2( v_key_tbl(i).key_value ,'success','Fail')
      INTO v_key_tbl(i).result_value
    FROM dual;
END IF;
IF (V_KEY_TBL(i).KEY_TYPE IN ('MIN')) THEN
V_Key_tbl(i).key_Value := GET_ESN_INFO_REC.MIN;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
--CR52828 start
IF (V_KEY_TBL(i).KEY_TYPE IN ('LINE_STATUS')) THEN --{
  BEGIN --{
    SELECT x_part_inst_status
    INTO v_key_tbl(i).key_value
    FROM sa.table_part_inst
    WHERE x_domain             = 'LINES'
    AND part_serial_no         = get_esn_info_rec.min;
    v_key_tbl(i).result_value := 'success';
  EXCEPTION
  WHEN OTHERS THEN
    v_key_tbl(i).result_value := 'Fail';
    v_key_tbl(i).key_value    := NULL;
  END;  --}
END IF; --}
--CR52828 end

IF (V_KEY_TBL(i).KEY_TYPE IN ('ISB2B')) THEN
V_KEY_TBL(i).KEY_VALUE := '1';
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_KEY_TBL(i).KEY_TYPE IN ('HASREGEDPAYMENTSOURCES')) THEN
V_KEY_TBL(i).KEY_VALUE := l_CREDITCARDREG;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_KEY_TBL(i).KEY_TYPE IN ('QUEUESIZE')) THEN
V_KEY_TBL(i).KEY_VALUE := l_REDEMPCARDQUEUE;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_KEY_TBL(i).KEY_TYPE IN ('ENDOFSERVICEDATE')) THEN
V_KEY_TBL(I).KEY_VALUE := L_SERVICE_END_DT;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_KEY_TBL(i).KEY_TYPE IN ('FORECASTDATE')) THEN
V_KEY_TBL(i).KEY_VALUE := l_FORECAST_DATE;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
--START OF CR32032
IF (V_KEY_TBL(i).KEY_TYPE IN ('ESN')) THEN
V_KEY_TBL(i).KEY_VALUE := in_esn;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_KEY_TBL(i).KEY_TYPE IN ('CURRENT_SERV_PLAN_ID')) THEN
--DBMS_OUTPUT.PUT_LINE('Inside CURRENT_SERV_PLAN_ID with l_SERVICEPLANID:'||l_SERVICEPLANID);
V_KEY_TBL(i).KEY_VALUE := l_SERVICEPLANID;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_KEY_TBL(i).KEY_TYPE IN ('CURRENT_SERV_PLAN_NAME')) THEN
--DBMS_OUTPUT.PUT_LINE('Inside CURRENT_SERV_PLAN_NAME with l_SERVICEPLANID:'||l_SERVICEPLANID||'; l_SERVICEPLANNAME:'||l_SERVICEPLANNAME);
V_KEY_TBL(i).KEY_VALUE := l_SERVICEPLANNAME;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_KEY_TBL(i).KEY_TYPE IN ('ISAUTOREFILL')) THEN
--DBMS_OUTPUT.PUT_LINE('Inside ISAUTOREFILL with l_AUTOREFILL:'||l_AUTOREFILL);
V_KEY_TBL(i).KEY_VALUE := l_AUTOREFILL;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
--END OF CR32032
IF (V_KEY_TBL(i).KEY_TYPE IN ('DEVICE_PARTNUMBER')) THEN
V_KEY_TBL(i).KEY_VALUE := GET_ESN_INFO_REC.part_num;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
          -- CR39592 Start PMistry 03/24/2016 Added DEVICE_UNLOCK_STATUS.
          IF (V_KEY_TBL(I).KEY_TYPE IN ('DEVICE_UNLOCK_STATUS')) THEN
            open unlock_esn_status_cur;
            fetch unlock_esn_status_cur into unlock_esn_status_rec;
            close unlock_esn_status_cur;

            V_KEY_TBL(i).KEY_VALUE := unlock_esn_status_rec.unlock_status;
            SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
            INTO V_KEY_TBL(i).RESULT_VALUE
            FROM dual;
          END IF;
          -- CR39592 End

--CR39303 :- UNLOCKING PARTCLASS, DLL and SEQUENCE are added
-- UNLOCKING PARTCLASS
IF (V_KEY_TBL(i).KEY_TYPE IN ('UNLOCKING_PROCESS')) THEN
V_RETURN_UNLOCK_PROCESS := GET_ESN_INFO_REC.part_class;


  V_KEY_TBL(i).KEY_VALUE := sa.GET_PARAM_BY_NAME_FUN(
    IP_PART_CLASS_NAME => V_RETURN_UNLOCK_PROCESS,
    IP_PARAMETER => 'UNLOCK_TYPE'
 );

SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;

-- UNLOCKING DLL
IF (V_KEY_TBL(i).KEY_TYPE IN ('DLL')) THEN
V_KEY_TBL(i).KEY_VALUE := GET_ESN_INFO_REC.x_dll;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;

-- UNLOCKING SEQUENCE
IF (V_KEY_TBL(i).KEY_TYPE IN ('SEQUENCE')) THEN
V_KEY_TBL(i).KEY_VALUE := GET_ESN_INFO_REC.x_sequence;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;


IF (V_KEY_TBL(i).KEY_TYPE IN ('DEVICE_PARTCLASS')) THEN
V_KEY_TBL(i).KEY_VALUE := GET_ESN_INFO_REC.part_class;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
-- CR39389 Changes Starts.
IF (V_KEY_TBL(i).KEY_TYPE IN ('WEB_CONTACT_OBJID')) THEN
   V_KEY_TBL(i).KEY_VALUE := cst.web_contact_objid;
   SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
   INTO V_KEY_TBL(i).RESULT_VALUE
   FROM dual;
END IF;
-- CR39389 Changes Ends.
-- CR35801 To identify the ESN is SAFELINK or not
IF (V_KEY_TBL(i).KEY_TYPE IN ('IS_SAFELINK')) THEN
  SELECT COUNT(*) INTO L_SAFELINK_IN
    FROM sa.X_SL_CURRENTVALS CUR,
      sa.TABLE_SITE_PART TSP,
      sa.X_PROGRAM_ENROLLED PE
    WHERE 1                    = 1
    AND TSP.X_SERVICE_ID       = PE.X_ESN
    AND TSP.X_SERVICE_ID       = CUR.X_CURRENT_ESN
    AND PE.X_ENROLLMENT_STATUS = 'ENROLLED'
    AND CUR.X_CURRENT_ESN      = IN_ESN
    AND UPPER(TSP.PART_STATUS) = 'ACTIVE'
    AND ROWNUM                 <2;
   SELECT DECODE (L_SAFELINK_IN, 1, 'TRUE','FALSE') INTO
          V_KEY_TBL(i).KEY_VALUE
     FROM DUAL;

   SELECT DECODE (V_KEY_TBL(i).KEY_VALUE,'TRUE','success', 'FALSE','Fail') INTO
          V_KEY_TBL(i).RESULT_VALUE
     FROM dual;
END IF;  --
IF (V_KEY_TBL(i).KEY_TYPE IN ('ENROLLMENT_STATUS')) THEN
BEGIN
SELECT X_ENROLLMENT_STATUS
INTO l_ENROLLMENT_STATUS
FROM x_program_enrolled
WHERE objid =
  (SELECT MAX(objid) FROM x_program_enrolled pe WHERE x_esn = IN_ESN
  -- CR43498 Added check to exclude Data Club Data plan always
        and pe.pgm_enroll2pgm_parameter not in
       (
         select pgm.objid from x_program_parameters pgm
         where pgm.x_program_name like       '%Data Club Plan%B2B'
         and pgm.X_CHARGE_FRQ_CODE  = 'LOWBALANCE'
       )
);
EXCEPTION
WHEN OTHERS THEN
V_Key_Tbl(i).Key_Type := 'ENROLLMENT_STATUS';
V_Key_tbl(i).key_Value := 0;
V_KEY_TBL(i).RESULT_VALUE := 'Fail';
END;
V_KEY_TBL(i).KEY_VALUE := l_ENROLLMENT_STATUS;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (GET_ESN_INFO_REC.STATUS = '52') THEN
l_enrl_status := 'ENROLLED';
ELSE
l_enrl_status := 'ENROLLMENTPENDING';
END IF ;

-- TO CHECK THE THROTTLE_STATUS
  IF (V_KEY_TBL(i).KEY_TYPE IN ('THROTTLE_STATUS')) THEN
    --
    SELECT COUNT(*)
    INTO   v_throttle_status
    FROM   w3ci.table_x_throttling_cache
    WHERE  x_status in ('A', 'P')
    AND    x_esn = in_esn
    AND    ROWNUM < 2;

    SELECT DECODE (v_throttle_status, 1, 'YES','NO')
    INTO   V_KEY_TBL(i).KEY_VALUE
    FROM   DUAL;

    SELECT DECODE (V_KEY_TBL(i).KEY_VALUE,'YES','success', 'NO','success', 'Fail')
    INTO   V_KEY_TBL(i).RESULT_VALUE
    FROM   DUAL;
    --
END IF;  --


IF (V_KEY_TBL(i).KEY_TYPE IN ('ISUNLIMITED')) OR (V_KEY_TBL(I).KEY_TYPE IN ('SERVICEPLANNAME')) OR (V_KEY_TBL(i).KEY_TYPE IN ('SERVICEPLANID')) OR (V_KEY_TBL(i).KEY_TYPE IN ('ISAUTOREFILL')) OR (V_KEY_TBL(i).KEY_TYPE IN ('SERVICE_PARTNUMBER')) OR (V_KEY_TBL(i).KEY_TYPE IN ('BILLING_PARTNUMBER')) THEN
OPEN esn_plan_cur(l_enrl_status) ;
FETCH esn_plan_cur INTO esn_plan_rec;
IF esn_plan_cur%notfound THEN
CLOSE esn_plan_cur;
ELSE
IF (V_KEY_TBL(i).KEY_TYPE IN ('ISUNLIMITED')) THEN
V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.ISUNLIMITED;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_KEY_TBL(I).KEY_TYPE IN ('SERVICEPLANNAME')) THEN
V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.sp_name;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_KEY_TBL(i).KEY_TYPE IN ('SERVICEPLANID')) THEN
V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.sp_id;
SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
INTO V_KEY_TBL(i).RESULT_VALUE
FROM dual;
END IF;
IF (V_KEY_TBL(i).KEY_TYPE IN ('ISAUTOREFILL')) THEN
            V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.AUTOREFILL;
            SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
            INTO V_KEY_TBL(i).RESULT_VALUE
            FROM dual;
          END IF;
          IF (V_KEY_TBL(i).KEY_TYPE IN ('SERVICE_PARTNUMBER')) THEN
            V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.service_partnum;
            SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
            INTO V_KEY_TBL(i).RESULT_VALUE
            FROM dual;
          END IF;
          IF (V_KEY_TBL(i).KEY_TYPE IN ('BILLING_PARTNUMBER')) THEN
            V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.billing_partnum;
            SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
            INTO V_KEY_TBL(i).RESULT_VALUE
            FROM dual;
          END IF;
          CLOSE esn_plan_cur;
        END IF;
      END IF;
      IF (GET_ESN_INFO_REC.STATUS = '52') THEN
        IF (V_KEY_TBL(i).KEY_TYPE IN ('CARRIER')) THEN
          BEGIN
            SELECT p.x_parent_name
            INTO l_carier
            FROM table_site_part sp,
              table_part_inst pi,
              table_x_carrier ca,
              table_x_carrier_group cg,
              table_x_parent p
            WHERE 1               =1
            AND sp.x_service_id   = in_esn
            AND pi.part_serial_no = sp.x_min
            AND pi.x_domain       = 'LINES'
            AND sp.part_status    = 'Active'
            AND ca.objid          = pi.part_inst2carrier_mkt
            AND cg.objid          = ca.CARRIER2CARRIER_GROUP
            AND p.objid           = cg.X_CARRIER_GROUP2X_PARENT;
          EXCEPTION
          WHEN OTHERS THEN
            V_Key_Tbl(i).Key_Type     := 'CARRIER';
            V_Key_tbl(i).key_Value    := 0;
            V_KEY_TBL(i).RESULT_VALUE := 'Fail';
          END;
          V_KEY_TBL(i).KEY_VALUE    := l_carier;
          V_KEY_TBL(i).RESULT_VALUE := 'success';
        END IF;
      END IF;
      -- CR50073 START
      IF (V_KEY_TBL(i).KEY_TYPE IN ('SUB_BRAND')) THEN
        BEGIN
          v_sub_bnd      := NULL;
          v_is_safelink  := NULL;
          v_sub_bnd      := rc.get_sub_brand;
          v_is_safelink  := sa.validate_red_card_pkg.is_safelink(in_esn,NULL);
          SELECT MAX(sub_brand) sub_brand
            INTO v_sub_brand
            FROM
                 (SELECT v_sub_bnd sub_brand
                    FROM dual
                   UNION
                  SELECT DECODE(v_is_safelink,'Y','SAFELINK',NULL)    sub_brand
                    FROM DUAL
                  );
        EXCEPTION
        WHEN OTHERS THEN
          V_Key_Tbl(i).Key_Type     := 'SUB_BRAND';
          V_Key_tbl(i).key_Value    := 0;
          V_KEY_TBL(i).RESULT_VALUE := 'Fail';
        END;
        V_KEY_TBL(i).KEY_VALUE    := v_sub_brand;
        V_KEY_TBL(i).RESULT_VALUE := 'success';
      END IF;
      IF (V_KEY_TBL(i).KEY_TYPE IN ('PLAN_DOLLAR_VALUE')) THEN
        BEGIN
          v_service_plan := sa.service_plan.get_service_plan_by_esn(in_esn);
           SELECT  CASE WHEN MAX(x_retail_price) <= 0 -- If price is zero or less don't display price.
                      THEN NULL
                      ELSE MAX(x_retail_price)
                       END x_retail_price
             INTO v_retail_price
             FROM(
                  SELECT 1 srt,
                         p.x_retail_price x_retail_price  -- Take for table_x_pricing first.
                   FROM table_part_num pn,
                        table_x_pricing P
                  WHERE p.x_pricing2part_num=pn.objid
                    AND pn.part_number IN (SELECT plan_purchase_part_number
                                             FROM service_plan_feat_pivot_mv
                                            WHERE service_plan_objid = v_service_plan.objid)
                    AND X_END_DATE > TRUNC(SYSDATE)
                    AND x_channel = 'WEB'
                  UNION
                 SELECT 2 srt,
                        xsp.customer_price  x_retail_price      -- Then from x_service_plan.
                   FROM x_service_plan xsp
                  WHERE xsp.objid = v_service_plan.objid
                )
            ORDER BY srt;
        EXCEPTION
        WHEN OTHERS THEN
          V_Key_Tbl(i).Key_Type     := 'PLAN_DOLLAR_VALUE';
          V_Key_tbl(i).key_Value    := 0;
          V_KEY_TBL(i).RESULT_VALUE := 'Fail';
        END;
        V_KEY_TBL(i).KEY_VALUE    := v_retail_price;
        V_KEY_TBL(i).RESULT_VALUE := 'success';
      END IF;

  -- CR50154 ST LTO Start
   IF (V_KEY_TBL(i).KEY_TYPE IN ('IS_SERVICE_ACTIVE')) THEN
   V_KEY_TBL(i).KEY_VALUE := l_is_service_active;
   SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
   INTO V_KEY_TBL(i).RESULT_VALUE
   FROM dual;
   END IF;
   IF (V_KEY_TBL(i).KEY_TYPE IN ('LAST_REDEEMED_PLAN_PART_NUMBER')) THEN
   V_KEY_TBL(i).KEY_VALUE := l_last_redm_plan_part_num;
   SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
   INTO V_KEY_TBL(i).RESULT_VALUE
   FROM dual;
   END IF;
   IF (V_KEY_TBL(i).KEY_TYPE IN ('LAST_REDEEMED_PLAN_PART_CLASS')) THEN
   V_KEY_TBL(i).KEY_VALUE := l_last_redm_plan_pc;
   SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
   INTO V_KEY_TBL(i).RESULT_VALUE
   FROM dual;
   END IF;

   IF (V_KEY_TBL(i).KEY_TYPE IN ('FORECAST_ENDOFSERVICEON')) THEN
   V_KEY_TBL(i).KEY_VALUE := l_forecast_enddate;
   SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
   INTO V_KEY_TBL(i).RESULT_VALUE
   FROM dual;
   END IF;
   IF (V_KEY_TBL(i).KEY_TYPE IN ('AUTOREFILL_FLAG')) THEN
   V_KEY_TBL(i).KEY_VALUE := l_AUTOREFILL_FLAG;
   SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
   INTO V_KEY_TBL(i).RESULT_VALUE
   FROM dual;
   END IF;


  --CR50154 ST LTO End

  --CR51453_api_to_support_incomm


     IF (V_KEY_TBL(i).KEY_TYPE IN ('DEALER_NAME')) THEN

        BEGIN
           SELECT ts.name
             INTO v_key_tbl(i).key_value
                     FROM table_part_inst   pi,
                                  table_inv_bin     tb,
                  table_site        ts
                    WHERE tb.location_name        = ts.site_id
                      AND pi.part_inst2inv_bin    = tb.objid
                      AND pi.x_domain             = 'PHONES'
                      AND pi.part_serial_no       = in_esn;

        v_key_tbl(i).result_value  := 'success';

        EXCEPTION WHEN OTHERS THEN
           v_key_tbl(i).result_value  := 'Fail';

        END;


     END IF;

     IF (V_KEY_TBL(i).KEY_TYPE IN ('ACTIVATION_DATE')) THEN

        BEGIN
           SELECT install_date
             INTO v_key_tbl(i).key_value
                     FROM table_site_part
                    WHERE x_service_id = in_esn
              AND part_status = 'Active';

        v_key_tbl(i).result_value  := 'success';

        EXCEPTION WHEN OTHERS THEN
           v_key_tbl(i).result_value  := 'Fail';

        END;


     END IF;

     IF (V_KEY_TBL(i).KEY_TYPE IN ('MODEL')) THEN

        BEGIN
           SELECT get_esn_info_rec.part_num model_type  --CR53624
             INTO v_key_tbl(i).key_value
                     FROM DUAL;

        v_key_tbl(i).result_value  := 'success';

        EXCEPTION WHEN OTHERS THEN
           v_key_tbl(i).result_value  := 'Fail';

        END;


     END IF;

     IF (V_KEY_TBL(i).KEY_TYPE IN ('ACTION_TYPE')) THEN

        BEGIN
           SELECT part_status
             INTO v_key_tbl(i).key_value
                     FROM table_site_part
                    WHERE x_service_id = in_esn
              AND part_status = 'Active';

        v_key_tbl(i).result_value  := 'success';

        EXCEPTION WHEN OTHERS THEN
           v_key_tbl(i).result_value  := 'Fail';

        END;


     END IF;

  --END CR51453_api_to_support_incomm

      IF v_key_tbl(i).key_type = 'PLAN_PURCHASE_PART_NUMBER'
      THEN
        BEGIN
          SELECT plan_purchase_part_number,
                 'success'
          INTO   v_key_tbl(i).key_value,
                 v_key_tbl(i).result_value
          FROM   sa.service_plan_feat_pivot_mv
          WHERE  service_plan_objid = sa.customer_info.get_service_plan_objid ( i_esn => in_esn );
        EXCEPTION
        WHEN OTHERS
        THEN
          v_key_tbl(i).key_value    := NULL;
          v_key_tbl(i).result_value := 'Fail';
        END;
      END IF;
      IF (V_KEY_TBL(i).KEY_TYPE IN ('SERVICE_PARTCLASS')) THEN
        V_KEY_TBL(i).KEY_VALUE := sa.CUSTOMER_INFO.get_service_plan_attributes ( i_esn => In_Esn,
                                                                                 I_value =>'PART_CLASS_NAME' );
        SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
        INTO V_KEY_TBL(i).RESULT_VALUE
        FROM dual;
      END IF;

    END LOOP;
  END IF;
  -- END IF;
  CLOSE get_esn_info_cur;
  Io_Key_Tbl := V_Key_Tbl;
EXCEPTION
WHEN OTHERS THEN
  --
  v_err_num    := SQLCODE;
  V_ERR_STRING := SUBSTR(SQLERRM,1, 300);
  UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => NULL, IP_KEY => SUBSTR(IN_ESN||';', 1, 50), IP_PROGRAM_NAME => 'PHONE_PKG.gETESNATTRIBUTES', iP_Error_Text => v_err_string);
  --
END Getesnattributes;
---
-- Overloading procedure CR27270 Car Connection
PROCEDURE validate_phone_prc(
    p_esn           IN VARCHAR2,
    p_source_system IN VARCHAR2,
    p_brand_name    IN VARCHAR2,
    p_part_inst_objid OUT VARCHAR2,
    p_code_number OUT VARCHAR2,
    p_code_name OUT VARCHAR2,
    p_redemp_reqd_flg OUT NUMBER,
    p_warr_end_date OUT VARCHAR2,
    p_phone_model OUT VARCHAR2,
    p_phone_technology OUT VARCHAR2,
    p_phone_description OUT VARCHAR2,
    p_esn_brand OUT VARCHAR2,
    p_zipcode OUT VARCHAR2,
    p_pending_red_status OUT VARCHAR2,
    p_click_status OUT VARCHAR2,
    p_promo_units OUT NUMBER,
    p_promo_access_days OUT NUMBER,
    p_num_of_cards OUT NUMBER,
    p_pers_status OUT VARCHAR2,
    p_contact_id OUT VARCHAR2,
    p_contact_phone OUT VARCHAR2,
    p_errnum OUT VARCHAR2,
    p_errstr OUT VARCHAR2,
    p_sms_flag OUT NUMBER,
    p_part_class OUT VARCHAR2,
    p_parent_id OUT VARCHAR2,
    p_extra_info OUT VARCHAR2,
    p_int_dll OUT NUMBER,
    p_contact_email OUT VARCHAR2,
    p_min OUT VARCHAR2,
    p_manufacturer OUT VARCHAR2,
    p_seq OUT NUMBER,
    p_iccid OUT VARCHAR2,
    p_iccid_flag OUT VARCHAR2,
    p_last_call_trans OUT VARCHAR2,
    p_safelink_esn OUT VARCHAR2,
    p_preactv_benefits OUT VARCHAR2 )
IS
  CURSOR c_queued_pin (c_esn VARCHAR2)
  IS
    SELECT pn.s_part_number pin_part_num,
      pn.part_type
    FROM table_part_inst esn,
      table_part_inst pin,
      table_mod_level ml,
      table_part_num pn,
      table_part_class pc
    WHERE pin.part_to_esn2part_inst = esn.objid
    AND pin.n_part_inst2part_mod    = ml.objid
    AND ml.part_info2part_num       = pn.objid
    AND pc.objid                    = pn.part_num2part_class
    AND pin.x_domain                = 'REDEMPTION CARDS'
    AND pin.x_ext                   = '1'
    AND esn.part_serial_no          = c_esn
    ORDER BY esn.part_serial_no,
      pin.x_ext;
  rec_queued_pin c_queued_pin%ROWTYPE;
  CURSOR get_phone_info_cur (c_esn IN VARCHAR2)
  IS
    SELECT pn.x_card_plan
    FROM table_part_inst pi,
      table_mod_level ml,
      table_part_num pn,
      table_bus_org bo,
      table_part_class pc
    WHERE pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num     = pn.objid
    AND pi.part_serial_no         = c_esn
    AND pi.x_domain               = 'PHONES'
    AND bo.objid                  = pn.part_num2bus_org
    AND pc.objid                  = pn.part_num2part_class;
  get_phone_info_rec get_phone_info_cur%ROWTYPE;

  c customer_Type := customer_Type (); --CR44729
BEGIN
  p_preactv_benefits := 'N';
  BEGIN
    phone_pkg.validate_phone_prc (p_esn => p_esn, p_source_system => p_source_system, p_brand_name => p_brand_name, p_part_inst_objid => p_part_inst_objid, p_code_number => p_code_number, p_code_name => p_code_name, p_redemp_reqd_flg => p_redemp_reqd_flg, p_warr_end_date => p_warr_end_date, p_phone_model => p_phone_model, p_phone_technology => p_phone_technology, p_phone_description => p_phone_description, p_esn_brand => p_esn_brand, p_zipcode => p_zipcode, p_pending_red_status => p_pending_red_status, p_click_status => p_click_status, p_promo_units => p_promo_units, p_promo_access_days => p_promo_access_days, p_num_of_cards => p_num_of_cards, p_pers_status => p_pers_status, p_contact_id => p_contact_id, p_contact_phone => p_contact_phone, p_errnum => p_errnum, p_errstr => p_errstr, p_sms_flag => p_sms_flag, p_part_class => p_part_class, p_parent_id => p_parent_id, p_extra_info => p_extra_info, p_int_dll => p_int_dll, p_contact_email => p_contact_email, p_min => p_min, p_manufacturer
    => p_manufacturer, p_seq => p_seq, p_iccid => p_iccid, p_iccid_flag => p_iccid_flag, p_last_call_trans => p_last_call_trans, p_safelink_esn => p_safelink_esn);
  EXCEPTION
  WHEN OTHERS THEN
    toss_util_pkg.insert_error_tab_proc (ip_action => p_esn||' ; '||p_source_system||' ; '||p_brand_name, ip_key => SUBSTR (p_esn || ';', 1, 50), ip_program_name => 'PHONE_PKG.VALIDATE_PHONE_PRC', ip_error_text => SUBSTR (SQLERRM, 1, 300));
  END;
  OPEN get_phone_info_cur (p_esn);
  FETCH get_phone_info_cur INTO get_phone_info_rec;
  IF get_phone_info_cur%FOUND THEN
    OPEN c_queued_pin (p_esn);
    FETCH c_queued_pin INTO rec_queued_pin;
    CLOSE c_queued_pin;
    IF rec_queued_pin.pin_part_num = NVL (get_phone_info_rec.x_card_plan, 'X') OR NVL (rec_queued_pin.part_type, 'X') = 'FREE' THEN
      p_preactv_benefits          := 'Y';
    END IF;
  END IF;
  CLOSE get_phone_info_cur;

EXCEPTION
WHEN OTHERS THEN
  toss_util_pkg.insert_error_tab_proc (ip_action => 'Overloading Proc '||p_esn||' ; '||p_source_system||' ; '||p_brand_name, ip_key => SUBSTR (p_esn || ';', 1, 50), ip_program_name => 'PHONE_PKG.VALIDATE_PHONE_PRC', ip_error_text => SUBSTR (SQLERRM, 1, 300));
END;

/*********************************************************************
procedure: validate_phone_prc
date     : 12/13/2016
description: This overload Procedure is created to fetch the phone
              details along with the subbrand.
**********************************************************************/
PROCEDURE validate_phone_prc(p_esn           IN VARCHAR2,
                            p_source_system IN VARCHAR2,
                            p_brand_name    IN VARCHAR2,
                            p_part_inst_objid OUT VARCHAR2,
                            p_code_number OUT VARCHAR2,
                            p_code_name OUT VARCHAR2,
                            p_redemp_reqd_flg OUT NUMBER,
                            p_warr_end_date OUT VARCHAR2,
                            p_phone_model OUT VARCHAR2,
                            p_phone_technology OUT VARCHAR2,
                            p_phone_description OUT VARCHAR2,
                            p_esn_brand OUT VARCHAR2,
                            p_zipcode OUT VARCHAR2,
                            p_pending_red_status OUT VARCHAR2,
                            p_click_status OUT VARCHAR2,
                            p_promo_units OUT NUMBER,
                            p_promo_access_days OUT NUMBER,
                            p_num_of_cards OUT NUMBER,
                            p_pers_status OUT VARCHAR2,
                            p_contact_id OUT VARCHAR2,
                            p_contact_phone OUT VARCHAR2,
                            p_errnum OUT VARCHAR2,
                            p_errstr OUT VARCHAR2,
                            p_sms_flag OUT NUMBER,
                            p_part_class OUT VARCHAR2,
                            p_parent_id OUT VARCHAR2,
                            p_extra_info OUT VARCHAR2,
                            p_int_dll OUT NUMBER,
                            p_contact_email OUT VARCHAR2,
                            p_min OUT VARCHAR2,
                            p_manufacturer OUT VARCHAR2,
                            p_seq OUT NUMBER,
                            p_iccid OUT VARCHAR2,
                            p_iccid_flag OUT VARCHAR2,
                            p_last_call_trans OUT VARCHAR2,
                            p_safelink_esn OUT VARCHAR2,
                            p_preactv_benefits OUT VARCHAR2,
                            p_sub_brand               OUT VARCHAR2)

IS

c customer_Type := customer_Type (); --CR44729

BEGIN

   validate_phone_prc(
    p_esn => p_esn  ,
    p_source_system => p_source_system,
    p_brand_name    => p_brand_name,
    p_part_inst_objid => p_part_inst_objid,
    p_code_number  => p_code_number,
    p_code_name  => p_code_name,
    p_redemp_reqd_flg => p_redemp_reqd_flg,
    p_warr_end_date => p_warr_end_date,
    p_phone_model => p_phone_model,
    p_phone_technology => p_phone_technology,
    p_phone_description => p_phone_description,
    p_esn_brand => p_esn_brand,
    p_zipcode => p_zipcode,
    p_pending_red_status => p_pending_red_status,
    p_click_status => p_click_status,
    p_promo_units => p_promo_units,
    p_promo_access_days => p_promo_access_days,
    p_num_of_cards => p_num_of_cards,
    p_pers_status => p_pers_status,
    p_contact_id => p_contact_id,
    p_contact_phone => p_contact_phone,
    p_errnum => p_errnum,
    p_errstr => p_errstr,
    p_sms_flag => p_sms_flag,
    p_part_class => p_part_class,
    p_parent_id => p_parent_id,
    p_extra_info => p_extra_info,
    p_int_dll => p_int_dll,
    p_contact_email => p_contact_email,
    p_min => p_min,
    p_manufacturer => p_manufacturer,
    p_seq => p_seq,
    p_iccid => p_iccid,
    p_iccid_flag => p_iccid_flag,
    p_last_call_trans => p_last_call_trans,
    p_safelink_esn => p_safelink_esn,
    p_preactv_benefits => p_preactv_benefits);

    --
    c := customer_type ( i_esn => p_esn);
    -- return output
    p_sub_brand := c.get_sub_brand;

END validate_phone_prc;
/*********************************************************************
procedure: p_get_latest_upgrade_esn
date     : 08/25/2015
description: Procedure developed as part of phone in a box project.
             Takes an input ESN looks for any upgrade cases on the
             ESN and return the lastest ESN.
**********************************************************************/
procedure p_get_latest_upgrade_esn     (in_esn          in    varchar2,
                                        out_esn         out    varchar2,
                                        out_case_date   out    date,
                                        out_error_code  out   number,
                                        out_error_msg   out   varchar2
                                        )

as
l_new_esn varchar2(40);
l_case_date date := NULL;
v_esn varchar2(40);

begin
     select nvl2 (v_esn, v_esn, in_esn)
       into v_esn
       from dual;

     --dbms_output.put_line ('v_esn:'||v_esn);

     while ((l_new_esn is not null) or (nvl(l_new_esn, '++') <> v_esn))
     loop
         begin
         SELECT DISTINCT cd.x_value, c.creation_time
                INTO   l_new_esn, l_case_date
                FROM   table_case c,
                       table_x_case_detail cd
                WHERE  c.x_esn = v_esn
                AND    c.s_title LIKE '%PHONE%UPGRADE%'
                AND   (c.creation_time > l_case_date OR l_case_date IS NULL)
                AND    c.objid = cd.detail2case
                AND    c.objid = (select max(c2.objid)
                                   from table_case c2
                                   where x_esn = v_esn
                                   and c2.s_title LIKE '%PHONE%UPGRADE%'
                                   and (c2.creation_time > l_case_date OR l_case_date IS NULL)
                                  )
                AND    cd.x_name = 'NEW_ESN';

          v_esn :=  l_new_esn;
          --dbms_output.put_line('block1 new esn :'|| l_new_esn);
          --dbms_output.put_line('block1 case date :'||l_case_date);
         exception
         when no_data_found
         then
             begin
                  SELECT DISTINCT cd.x_value, c.creation_time
                INTO   l_new_esn, l_case_date
                FROM   table_case c,
                       table_x_case_detail cd
                WHERE  c.x_esn = v_esn
                  and  c.s_title LIKE '%CROSS%COMPANY%'
                  and  c.x_case_type= 'Phone Upgrade'    -- Explicit filter on case type as same title can be used for upgrades and ports
                  AND  c.objid = cd.detail2case
                  and  (c.creation_time > l_case_date OR l_case_date IS NULL)
                  AND  c.objid = (select max(c2.objid)
                                   from table_case c2
                                   where x_esn = v_esn
                                   and   c2.s_title LIKE '%CROSS%COMPANY%'
                                   and   c2.x_case_type= 'Phone Upgrade'   -- Explicit filter on case type as same title can be used for upgrades and ports
                                   and   (c2.creation_time > l_case_date OR l_case_date IS NULL)
                                 )
                  AND    cd.x_name = 'NEW_ESN';

                 --dbms_output.put_line('eblock new esn :'|| l_new_esn);
                 --dbms_output.put_line('eblock case date :'||l_case_date);

                /*loop exit logic*/
                if l_new_esn is null
                 then
                     l_new_esn := v_esn;
                     exit;
                 elsif nvl(l_new_esn, '++') = nvl(v_esn, '++')
                 then
                    exit ;
                 else
                     v_esn := l_new_esn;  -- if this case is reached loop will continue to look for leatest esn
                 end if;

                 exception
                 when others then
                 l_new_esn := v_esn;
                 exit;
             end ;
        end ;
     end loop;

      --dbms_output.put_line('final new esn :'|| l_new_esn);
      --dbms_output.put_line('final case date :'||l_case_date);

        out_esn := l_new_esn;
        out_case_date := l_case_date;
        out_error_code := 0;
        out_error_msg := 'SUCCESS';


        exception
        when others
        then
        out_esn := null;
        out_case_date := null;
        out_error_code := -99;
        out_error_msg := SQLERRM;
end p_get_latest_upgrade_esn;

/*********************************************************************
procedure: p_get_latest_port_esn
date     : 08/25/2015
description: Procedure developed as part of phone in a box project.
             Takes an input ESN looks for any port cases on the
             ESN and return the lastest ESN.
**********************************************************************/
procedure p_get_latest_port_esn     (in_esn          in    varchar2,
                                        out_esn         out    varchar2,
                                        out_case_date   out    date,
                                        out_error_code  out   number,
                                        out_error_msg   out   varchar2
                                        )

as
l_new_esn varchar2(40);
l_case_date date := NULL;
v_esn varchar2(40);

begin
     select nvl2 (v_esn, v_esn, in_esn)
       into v_esn
       from dual;

     --dbms_output.put_line ('v_esn:'||v_esn);

     while ((l_new_esn is not null) or (nvl(l_new_esn, '++') <> v_esn))
     loop
         begin
                                --ECR43670 --Getting max objid to avoid duplicates
        SELECT x_esn , creation_time
        INTO l_new_esn, l_case_date
        FROM  (
          select c.x_esn , c.creation_time,c.objid
                 from table_case c ,
                      table_x_case_detail cd
                 where c.objid = cd.detail2case
                  and (c.creation_time > l_case_date OR l_case_date IS NULL)
                   and cd.detail2case = (select max(cd2.detail2case) from
                                         table_x_case_detail cd2 where
                                         cd2.x_name = 'CURRENT_ESN'
                                         and c.objid = cd2.detail2case
                                         and  cd2.x_value = v_esn)
                   and  c.s_title like '%AUTO%INTERNAL%'
                   and  cd.x_name = 'CURRENT_ESN'
                   and  cd.x_value = v_esn
                   ORDER BY c.objid desc
                 )
              WHERE rownum = 1;

          v_esn :=  l_new_esn;
          --dbms_output.put_line('block1 new esn :'|| l_new_esn);
          --dbms_output.put_line('block1 case date :'||l_case_date);
         exception
         when no_data_found
         then
          begin
                                   --ECR43670 --Getting max objid to avoid duplicates
           SELECT x_esn , creation_time
            INTO l_new_esn, l_case_date
            FROM  (
                select c.x_esn , c.creation_time
                  from table_case c ,
                      table_x_case_detail cd
                 where c.objid = cd.detail2case
                   and (c.creation_time > l_case_date OR l_case_date IS NULL)
                   and cd.detail2case = (select max(cd2.detail2case) from
                                         table_x_case_detail cd2
                                         where
                                         cd2.x_name = 'CURRENT_ESN'
                                         and c.objid = cd2.detail2case
                                         and  cd2.x_value = v_esn)
                   and c.s_title like '%CROSS%COMPANY%'
                   and c.x_case_type = 'Port In'  -- Explicit filter on case type as same title can be used for upgrades and ports
                   and cd.x_name = 'CURRENT_ESN'
                   and cd.x_value = v_esn
                    ORDER BY c.objid desc
                  )
              WHERE rownum = 1;
                 --dbms_output.put_line('eblock new esn :'|| l_new_esn);
                 --dbms_output.put_line('eblock case date :'||l_case_date);

                 /*loop exit logic*/
                if l_new_esn is null
                 then
                     l_new_esn := v_esn;
                     exit;
                 elsif nvl(l_new_esn, '++') = nvl(v_esn, '++')
                 then
                    exit ;
                 else
                     v_esn := l_new_esn;  -- if this case is reached loop will continue to look for leatest esn
                 end if;

                 exception
                 when others then
                   l_new_esn := v_esn;
                   exit;
             end ;
       end ;
     end loop;

      --dbms_output.put_line('final new esn :'|| l_new_esn);
      --dbms_output.put_line('final case date :'||l_case_date);

        out_esn := l_new_esn;
        out_case_date := l_case_date;
        out_error_code := 0;
        out_error_msg := 'SUCCESS';

        exception
        when others
        then
        out_esn := null;
        out_case_date := null;
        out_error_code := -99;
        out_error_msg := SQLERRM;
end p_get_latest_port_esn;

/*********************************************************************
procedure: p_get_latest_replacement_esn
date     : 08/25/2015
description: Procedure developed as part of phone in a box project.
             Takes an input ESN looks for any replacement cases on the
             ESN and return the lastest ESN.
**********************************************************************/
procedure p_get_latest_replacement_esn (in_esn          in    varchar2,
                                        out_esn         out    varchar2,
                                        out_case_date   out    date,
                                        out_error_code  out   number,
                                        out_error_msg   out   varchar2
                                        )

as
      v_esn varchar2(40);
      l_new_esn varchar2(40);
      lv_case_date date := null;

    begin
     select nvl2 (v_esn, v_esn, in_esn)
     into v_esn
     from dual;

     --dbms_output.put_line ('v_esn:'||v_esn);

     while ((l_new_esn is not null) or (nvl(l_new_esn, '++') <> v_esn))
     loop
         --dbms_output.put_line ('inside while loop');
         begin
              SELECT DISTINCT cd.x_value , c.creation_time
              into l_new_esn, lv_case_date
                        FROM   table_case c,
                               table_x_case_detail cd
                        WHERE   (c.s_title LIKE '%REPLACEMENT%'
                                or
                                c.s_title LIKE '%EXCHANGE%'
                                or
                                c.s_title LIKE '%DEFECTIVE%PHONE%'
                                 )
                        AND    c.objid = (select max(c2.objid) from table_case c2
                                          where c2.x_esn = v_esn
                                          and (c2.s_title LIKE '%REPLACEMENT%'
                                               or
                                               c2.s_title LIKE '%EXCHANGE%'
                                               or
                                               c.s_title LIKE '%DEFECTIVE%PHONE%'
                                              )
                                          )
                        AND    c.objid = cd.detail2case
                         and    c.x_esn = v_esn
                         and (c.creation_time > lv_case_date OR lv_case_date IS NULL)
                         and    cd.x_name = 'NEW_ESN'
                        ;
                v_esn :=  l_new_esn;
              exception
              when no_data_found then
                --dbms_output.put_line ('l_new_esn GW:'||l_new_esn);
                --dbms_output.put_line ('v_esn GW:'||v_esn);
                  begin
                                                                --ECR43670 --Getting max objid to avoid duplicates
                  SELECT x_esn , creation_time
                    INTO l_new_esn, lv_case_date
                    FROM (
                       SELECT  c.x_esn  , c.creation_time,c.objid
                                FROM   table_case c,
                                       table_x_case_detail cd
                                WHERE   c.s_title LIKE '%REPLACEMENT%UNITS%'
                                AND    c.objid = cd.detail2case
                                and (c.creation_time > lv_case_date OR lv_case_date IS NULL)
                                AND   cd.detail2case = (select max(cd2.detail2case) from
                                         table_x_case_detail cd2
                                         where
                                         cd2.x_name = 'REFERENCE_ESN'
                                         and c.objid = cd2.detail2case
                                         and  cd2.x_value = v_esn)
                                AND    cd.x_name = 'REFERENCE_ESN'
                                and   cd.x_value = v_esn
                                 ORDER BY c.objid desc
                    )
                    WHERE rownum = 1;

                             /*loop exit logic*/
                      if l_new_esn is null
                       then
                           l_new_esn := v_esn;
                           exit;
                       elsif nvl(l_new_esn, '++') = nvl(v_esn, '++')
                       then
                          exit ;
                       else
                           v_esn := l_new_esn; -- if this case is reached loop will continue to look for leatest esn
                       end if;

                       exception
                       when no_data_found
                           then
                           l_new_esn := v_esn;
                           exit;
                   end ;
          end ;
         v_esn := l_new_esn;
     end loop;

   out_esn := l_new_esn;
    out_case_date := lv_case_date;
    out_error_code := 0;
    out_error_msg := 'SUCCESS';

    exception
    when others
    then
    out_esn := null;
    out_case_date := null;
    out_error_code := -99;
    out_error_msg := SQLERRM;
end p_get_latest_replacement_esn;

/*********************************************************************
procedure  : p_get_latest_esn
date       : 08/25/2015
description: Procedure developed as part of phone in a box project.
             Takes an input ESN calls the p_get_latest_replacement_esn
             ,p_get_latest_port_esn, p_get_latest_upgrade_esn and returns
             latest ESN.
**********************************************************************/

procedure p_get_latest_esn   (  in_esn          in    varchar2,
                                out_esn         out    varchar2,
                                out_case_date   out    date,
                                out_esn_case    out    varchar2,
                                out_error_code  out   number,
                                out_error_msg   out   varchar2 ) as

  l_upgd_out_esn varchar2(40);
  l_upgd_case_date date;
  l_upgd_error_code number;
  l_upgd_error_msg varchar2(4000);

  l_port_out_esn varchar2(40);
  l_port_case_date date;
  l_port_error_code number;
  l_port_error_msg varchar2(4000);

  l_repl_out_esn varchar2(40);
  l_repl_case_date date;
  l_repl_error_code number;
  l_repl_error_msg varchar2(4000);

  v_esn varchar2(40);
  v_case_date date;
  v_case varchar2(40);

begin

  v_esn := in_esn;

  while (nvl(v_esn, '++') <> nvl( l_upgd_out_esn, '++'))
  loop
    --
    p_get_latest_upgrade_esn ( in_esn         => v_esn,
                               out_esn        => l_upgd_out_esn,
                               out_case_date  => l_upgd_case_date,
                               out_error_code => l_upgd_error_code,
                               out_error_msg  => l_upgd_error_msg );

    if l_upgd_error_code <> 0 then
      out_error_code := l_upgd_error_code;
      out_error_msg  := l_upgd_error_msg;
      exit;
    end if;

    if nvl(l_upgd_out_esn, '++') <> nvl(v_esn, '++')
    then
      v_case := 'UPGRADE';
      v_case_date := l_upgd_case_date;
    end if;

    p_get_latest_port_esn ( in_esn         => l_upgd_out_esn,
                            out_esn        => l_port_out_esn,
                            out_case_date  => l_port_case_date,
                            out_error_code => l_port_error_code,
                            out_error_msg  => l_port_error_msg );

    if (l_port_error_code <> 0 )
    then
      out_error_code := l_port_error_code;
      out_error_msg  := l_port_error_msg;
      exit;
    end if;

    if nvl(l_upgd_out_esn, '++') <> nvl(l_port_out_esn, '++')
    then
      v_case := 'UPGRADE';
      v_case_date := l_port_case_date;
    end if;

    p_get_latest_replacement_esn ( in_esn         => l_port_out_esn,
                                   out_esn        => l_repl_out_esn,
                                   out_case_date  => l_repl_case_date,
                                   out_error_code => l_repl_error_code,
                                   out_error_msg  => l_repl_error_msg );

    if (l_repl_error_code <> 0 )
    then
      out_error_code := l_repl_error_code;
      out_error_msg  := l_repl_error_msg;
      exit;
    end if;

    if nvl(l_repl_out_esn, '++') <> nvl(l_port_out_esn, '++')
    then
      v_case := 'EXCHANGE';
      v_case_date := l_repl_case_date;
    end if;


    v_esn :=   l_repl_out_esn;

  end loop;

  if nvl(out_error_code,0) = 0 then
    out_esn := v_esn;
    out_esn_case:= v_case;
    out_case_date := v_case_date;
    out_error_code := 0;
    out_error_msg := 'SUCCESS';
  end if ;

exception
   when others then
     out_error_code := -99;
     out_error_msg := SQLERRM;
end p_get_latest_esn;

/*********************************************************************
procedure  : p_get_updated_esn_attributes
date       : 08/25/2015
description: Procedure developed as part of phone in a box project.
             Takes input ESN and a key table containing attributes of
             the ESN that need to be looked up and returned. The
             procedure looks for the latest ESN if any based on upgrade
             and exchange cases and if found returns the attributes for
             the latest ESN.
**********************************************************************/

PROCEDURE p_get_updated_esn_attributes ( in_esn       IN     table_part_inst.part_serial_no%TYPE,
                                         io_key_tbl   IN OUT keys_tbl,
                                         out_err_code OUT    NUMBER,
                                         out_err_msg  OUT    VARCHAR2,
                                          ip_org_id   IN     VARCHAR2 DEFAULT NULL  )  -- ip_brand_objid number,)
                                          IS

  v_key_tbl              keys_tbl := keys_tbl();
  v_err_num              INTEGER;
  v_err_string           VARCHAR2(300);
  l_serviceplanid        NUMBER;
  l_serviceplanname      sa.X_SERVICE_PLAN.DESCRIPTION%TYPE;
  l_serviceplanunlimited NUMBER ; --1 if true and 0 if false
  l_autorefill           NUMBER ; --1 if true and 0 if false
  l_service_end_dt       DATE;
  l_forecast_date        DATE;
  l_creditcardreg        NUMBER; --1 if true and 0 if false
  l_redempcardqueue      NUMBER;
  l_creditcardsch        NUMBER ; --1 if true and 0 if false
  l_statusid             VARCHAR2(50);
  l_statusdesc           VARCHAR2(80);
  l_email                VARCHAR2(50);
  l_part_num             VARCHAR2(40);
  esn_exist              NUMBER;
  l_service_part_num     VARCHAR2(40);
  l_carier               VARCHAR2(40);
  l_billing_part_num     VARCHAR2(40);
  l_enrl_status          VARCHAR2(40);
  l_enrollment_status    VARCHAR2(40);
  l_safelink_in          VARCHAR2(40);  --CR35801
  l_lease_status         VARCHAR2(80);
  l_lease_to_own         VARCHAR2(80);   --CR46193
  v_ext_warranty         VARCHAR2(80);  --CR46193
  v_enrollment_status    VARCHAR2(80);  --CR46193
  v_zipcode              VARCHAR2(20);   --CR46193
  v_prefix_pn            VARCHAR2(20);   --CR46193
  l_new_part_num         VARCHAR2(20);   --CR46193
  v_rebrand              VARCHAR2(20);   --CR46193
  v_is_lte               VARCHAR2(20);   --CR46193
  REBRAND_CARRIER        VARCHAR2(50);   --CR46193
  c_min                  VARCHAR2(30);   --CR53407
  c_valid_esn            VARCHAR2(30);   --CR53407

  lv_latest_esn          VARCHAR2(40);
  lv_case_dt             DATE;
  lv_case                VARCHAR2(40);
  lv_err_code            NUMBER;
  lv_err_num             VARCHAR2(10); --CR46193
  lv_err_msg             VARCHAR2(4000);
  lv_Esn                 VARCHAR2(40);
  lv_case_type           VARCHAR2(40);

  --CR50154 ST LTO
  l_last_redm_plan_part_num  splan_feat_pivot.plan_purchase_part_number%type;
  l_last_redm_plan_pc        table_part_class.name%type;
  ret_code                  VARCHAR2(100);
  ret_msg                   VARCHAR2(500);

  CURSOR get_esn_info_cur(in_esn_c1 table_part_inst.part_serial_no%TYPE) IS
    SELECT esn.part_serial_no esn ,
           cpi.x_esn_nick_name nickname,
           esn.x_part_inst_status status,
           tpn.x_technology technology ,
           tbo.org_id brand ,
           wu.login_name email,
           esn.x_iccid sim,
           line.part_serial_no min,
           CASE swa.objid
             WHEN NULL      THEN 0
             WHEN swa.objid THEN 1
           END b2b,
           tpn.part_number part_num,
           pc.name part_class
    FROM   table_part_inst esn,
           table_part_inst line,
           table_mod_level tml,
           table_part_num tpn,
           table_part_class pc,
           table_bus_org tbo,
           table_x_contact_part_inst cpi,
           table_web_user wu,
           x_site_web_accounts swa
    WHERE  1 = 1
    AND    esn.n_part_inst2part_mod = tml.objid
    AND    tml.part_info2part_num = tpn.objid
    AND    tpn.part_num2bus_org = tbo.objid
    AND    tpn.part_num2part_class = pc.objid
    AND    esn.objid = cpi.x_contact_part_inst2part_inst(+)
    AND    cpi.x_contact_part_inst2contact = wu.web_user2contact(+)
    AND    wu.objid = swa.site_web_acct2web_user(+)
    AND    esn.part_serial_no = in_esn_c1
    AND    esn.x_domain = 'PHONES'
    AND    line.part_to_esn2part_inst(+) = esn.objid
    AND    line.x_domain(+) = 'LINES';

  get_esn_info_rec get_esn_info_cur%ROWTYPE;

  CURSOR esn_plan_cur ( in_esn_c2 table_part_inst.part_serial_no%TYPE,
                        enrl_status VARCHAR2) IS
    SELECT CASE
                         WHEN pp.x_charge_frq_code IS NOT NULL THEN 1
             ELSE 0
           END autorefill,
           CASE INSTR(upper(pp.x_program_name) ,'UNLIMITED' ,1 ,1)
             WHEN 0 THEN 0
             ELSE 1
           END isunlimited,
           sp.mkt_name sp_name,
           sp.objid sp_id,
           x_source_part_num service_partnum,
           x_target_part_num1 billing_partnum
    FROM   sa.x_program_parameters pp,
           sa.x_program_enrolled pe,
           x_service_plan sp,
           mtm_sp_x_program_param mtm,
           x_ff_part_num_mapping fm
    WHERE  1 = 1
    AND    pp.objid = pe.pgm_enroll2pgm_parameter
    AND    pgm_enroll2pgm_parameter = fm.x_ff_objid
    AND    mtm.x_sp2program_param = pp.objid
    AND    mtm.program_para2x_sp = sp.objid -- find latest objid
    AND    x_esn = in_esn_c2
    AND    pe.x_enrollment_status = NVL(enrl_status,pe.x_enrollment_status);

  esn_plan_rec esn_plan_cur%ROWTYPE;

  CURSOR get_mod_level (
      l_new_part_num VARCHAR2)
   IS
      SELECT ml.objid, pn.part_num2part_class
        FROM table_mod_level ml, table_part_num pn, table_bus_org bo
       WHERE     ml.part_info2part_num = pn.objid
             AND pn.part_number = l_new_part_num
             AND pn.part_num2bus_org = bo.objid
             AND (bo.ORG_ID = 'TRACFONE'
                  OR EXISTS
                        (SELECT '1'
                           FROM sa.adfcrm_serv_plan_class_matview
                          WHERE part_class_objid = pn.part_num2part_class
                                AND ROWNUM < 2));

   get_mod_level_r            get_mod_level%ROWTYPE;

  -- instantiate initial values
  rc     sa.customer_type;

  -- type to hold retrieved attributes
  cst    sa.customer_type;

  -- type to hold retrieved attributed CR46039
  ctp sa.case_type := sa.case_type();
  ct  sa.case_type;
  i_zip_code         VARCHAR2(50) := NULL;
  o_new_sim_part_num VARCHAR2(50) := NULL;

BEGIN

  SELECT COUNT(1)
  INTO   esn_exist
  FROM   table_part_inst
  WHERE  part_serial_no = in_esn;

  IF esn_exist = 0 THEN
    out_err_code := 101;
    out_err_msg := 'Serial Number not found';
    RETURN;
  END IF;

  IF (io_key_tbl.COUNT IS NULL) THEN
    out_err_code := 134; ---Input Key Value List Required.
    out_err_msg := 'Input Attribute list is Blank';
    RETURN;
  END IF;

  IF (io_key_tbl.COUNT = 0) THEN
    out_err_code := 134; ---Input Key Value List Required.
    out_err_msg := 'Input Attribute list is Empty';
    RETURN;
  END IF;

  --BEGIN: CODE CHANGES FOR CR53407
  BEGIN
    SELECT key_value
      INTO c_min
      FROM table(cast(io_key_tbl AS keys_tbl))
     WHERE key_type = 'MIN';
  EXCEPTION
  WHEN others
  THEN
    c_min := NULL;
  END;

  IF c_min IS NOT NULL
  THEN
    --function call to get the esn from the min
    c_valid_esn := customer_info.get_esn ( i_min => c_min );
  END IF;
  --
  p_get_latest_esn ( in_esn         => in_esn,
                     out_esn        => lv_latest_esn,
                     out_case_date  => lv_case_dt,
                     out_esn_case   => lv_case ,
                     out_error_code => lv_err_code,
                     out_error_msg  => lv_err_msg );

  lv_esn       :=  NVL(c_valid_esn,lv_latest_esn);
  lv_case_type :=  lv_case;

  IF lv_esn IS NULL
  THEN
    lv_esn := in_esn;
  END IF;
  --END: CODE CHANGES FOR CR53407

  --CR50154 ST LTO Start
  get_last_red_details(lv_esn,
                       l_last_redm_plan_part_num,
                       l_last_redm_plan_pc,
                       ret_code,
                       ret_msg );

IF l_last_redm_plan_part_num LIKE '%APPAR%' THEN
    BEGIN
      SELECT  plan_purchase_part_number
      INTO    l_last_redm_plan_part_num
      FROM    splan_feat_pivot pv
      WHERE   pv.plan_purchase_part_number = replace(l_last_redm_plan_part_num,'AR','')
      AND     ROWNUM < 2;
      --
      SELECT  pc.name
      INTO    l_last_redm_plan_pc
      FROM    table_part_class  pc,
              table_part_num    pn
      WHERE   pn.part_num2part_class      = pc.objid
      AND     pn.part_number              = l_last_redm_plan_part_num;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT  pc.name, pn.part_number
          INTO    l_last_redm_plan_pc, l_last_redm_plan_part_num
          FROM    table_part_num    pn,
                  table_part_num    pn2,
                  table_x_pricing   xp,
                  table_part_class  pc
          WHERE   pn2.part_number         =  l_last_redm_plan_part_num
          AND     pn.part_number          LIKE 'TSAPP%'
          AND     pn.part_number          NOT LIKE '%FREE'
          AND     pn.objid                = xp.X_PRICING2PART_NUM
          AND     xp.X_CHANNEL            = 'IVR'
          AND     SYSDATE BETWEEN xp.X_START_DATE and NVL(xp.x_end_date , sysdate)
          AND     pn.part_num2part_class  = pc.objid
      --    AND     pn2.x_redeem_days       = pn.x_redeem_days
          AND     pn2.x_redeem_units      = pn.x_redeem_units;
        EXCEPTION
          WHEN OTHERS THEN
          NULL;
        END;
      WHEN OTHERS THEN
        NULL;
    END;
    --
  END IF;
  --ST LTO End


  IF io_key_tbl.COUNT > 0 THEN
    v_key_tbl := io_key_tbl;
  END IF;

  OPEN get_esn_info_cur(lv_esn);
  FETCH get_esn_info_cur INTO get_esn_info_rec;

  IF get_esn_info_cur%notfound THEN
    CLOSE get_esn_info_cur;
  ELSE
    CLOSE get_esn_info_cur;
    --
    IF get_esn_info_rec.status IN ('52', '50') THEN
      service_plan.get_service_plan_prc ( ip_esn                  => lv_esn,
                                          op_serviceplanid        => l_serviceplanid,
                                          op_serviceplanname      => l_serviceplanname,
                                          op_serviceplanunlimited => l_serviceplanunlimited,
                                          op_autorefill           => l_autorefill,
                                          op_service_end_dt       => l_service_end_dt,
                                          op_forecast_date        => l_forecast_date,
                                          op_creditcardreg        => l_creditcardreg,
                                          op_redempcardqueue      => l_redempcardqueue,
                                          op_creditcardsch        => l_creditcardsch,
                                          op_statusid             => l_statusid,
                                          op_statusdesc           => l_statusdesc,
                                          op_email                => l_email,
                                          op_part_num             => l_part_num,
                                          op_err_num              => v_err_num,
                                          op_err_string           => v_err_string );
    END IF;

    FOR i IN v_key_tbl.FIRST..v_key_tbl.LAST LOOP

      IF (V_Key_Tbl(i).Key_Type IN ('NICKNAME')) THEN
        V_Key_tbl(i).key_Value := get_esn_info_rec.NICKNAME;
      END IF;

      IF (V_Key_Tbl(i).Key_Type IN ('BRAND')) THEN
        V_Key_tbl(i).key_Value := get_esn_info_rec.BRAND;
      END IF;

      IF (V_Key_Tbl(i).Key_Type IN ('SIM')) THEN
        V_Key_tbl(i).key_Value := get_esn_info_rec.SIM;
      END IF;

      IF (V_Key_Tbl(i).Key_Type IN ('EMAIL')) THEN
        V_Key_tbl(i).key_Value := get_esn_info_rec.EMAIL;
      END IF;

      IF (V_KEY_TBL(I).KEY_TYPE IN ('STATUS')) THEN
        V_KEY_TBL(i).KEY_VALUE := GET_ESN_INFO_REC.STATUS;
      END IF;

      IF (V_KEY_TBL(I).KEY_TYPE IN ('TECHNOLOGY')) THEN
        V_KEY_TBL(i).KEY_VALUE := GET_ESN_INFO_REC.TECHNOLOGY;
      END IF;

      IF (V_KEY_TBL(i).KEY_TYPE IN ('MIN')) THEN
        V_Key_tbl(i).key_Value := GET_ESN_INFO_REC.MIN;
      END IF;

      IF (V_KEY_TBL(i).KEY_TYPE IN ('ISB2B')) THEN
        V_KEY_TBL(i).KEY_VALUE := '1';
      END IF;

      IF (V_KEY_TBL(i).KEY_TYPE IN ('HASREGEDPAYMENTSOURCES')) THEN
        V_KEY_TBL(i).KEY_VALUE := l_CREDITCARDREG;
      END IF;

     IF (V_KEY_TBL(i).KEY_TYPE IN ('QUEUESIZE')) THEN
        V_KEY_TBL(i).KEY_VALUE := l_REDEMPCARDQUEUE;
      END IF;

      IF (V_KEY_TBL(i).KEY_TYPE IN ('ENDOFSERVICEDATE')) THEN
        V_KEY_TBL(I).KEY_VALUE := L_SERVICE_END_DT;
      END IF;

      IF (V_KEY_TBL(i).KEY_TYPE IN ('FORECASTDATE')) THEN
        V_KEY_TBL(i).KEY_VALUE := l_FORECAST_DATE;
      END IF;

      --START OF CR32032
      IF (V_KEY_TBL(i).KEY_TYPE IN ('ESN')) THEN
        V_KEY_TBL(i).KEY_VALUE := lv_esn;
      END IF;

      IF (V_KEY_TBL(i).KEY_TYPE IN ('CURRENT_SERV_PLAN_ID')) THEN
         V_KEY_TBL(i).KEY_VALUE := l_SERVICEPLANID;
      END IF;

      IF (V_KEY_TBL(i).KEY_TYPE IN ('CURRENT_SERV_PLAN_NAME')) THEN
         V_KEY_TBL(i).KEY_VALUE := l_SERVICEPLANNAME;
      END IF;

      IF (V_KEY_TBL(i).KEY_TYPE IN ('ISAUTOREFILL')) THEN
         V_KEY_TBL(i).KEY_VALUE := l_AUTOREFILL;
      END IF;

      --END OF CR32032
      IF (V_KEY_TBL(i).KEY_TYPE IN ('DEVICE_PARTNUMBER')) THEN
        V_KEY_TBL(i).KEY_VALUE := GET_ESN_INFO_REC.part_num;
      END IF;

      IF (v_key_tbl(i).key_type IN ('DEVICE_PARTCLASS')) THEN
        v_key_tbl(i).key_value := get_esn_info_rec.part_class;
      END IF;

      -- CR35801 To identify the ESN is SAFELINK or not
      IF v_key_tbl(i).key_type IN ('IS_SAFELINK') THEN
        SELECT COUNT(1)
        INTO   l_safelink_in
        FROM   sa.x_sl_currentvals cur,
               sa.table_site_part tsp,
               sa.x_program_enrolled pe
        WHERE  1 = 1
        AND    tsp.x_service_id = pe.x_esn
        AND    tsp.x_service_id = cur.x_current_esn
        AND    pe.x_enrollment_status = 'ENROLLED'
        AND    cur.x_current_esn = lv_esn
        AND    tsp.part_status = 'Active'
        AND    ROWNUM < 2;

        SELECT DECODE (l_safelink_in, 1, 'TRUE','FALSE')
        INTO   v_key_tbl(i).key_value
        FROM   DUAL;

        SELECT DECODE (V_KEY_TBL(i).KEY_VALUE,'TRUE','success', 'FALSE','Fail')
        INTO   v_key_tbl(i).result_value
        FROM   DUAL;

      END IF;

      IF v_key_tbl(i).key_type IN ('ENROLLMENT_STATUS') THEN
        BEGIN
          SELECT x_enrollment_status
          INTO   l_enrollment_status
          FROM   x_program_enrolled
          WHERE  objid = ( SELECT MAX(objid)
                           FROM   x_program_enrolled
                           WHERE  x_esn = lv_esn
                         );
         EXCEPTION
           WHEN OTHERS THEN
             v_key_tbl(i).key_type := 'ENROLLMENT_STATUS';
             v_key_tbl(i).key_value := 0;
             v_key_tbl(i).result_value := 'Fail';
        END;

        v_key_tbl(i).key_value := l_enrollment_status;

        SELECT NVL2( v_key_tbl(i).key_value ,'success','Fail')
        INTO   v_key_tbl(i).result_value
        FROM   DUAL;

      END IF;

      IF get_esn_info_rec.status = '52' THEN
        l_enrl_status := 'ENROLLED';
      ELSE
        l_enrl_status := 'ENROLLMENTPENDING';
      END IF ;

      IF v_key_tbl(i).key_type IN ('ISUNLIMITED')
             OR (V_KEY_TBL(I).KEY_TYPE IN ('SERVICEPLANNAME'))
             OR (V_KEY_TBL(i).KEY_TYPE IN ('SERVICEPLANID'))
             OR (V_KEY_TBL(i).KEY_TYPE IN ('ISAUTOREFILL'))
             OR (V_KEY_TBL(i).KEY_TYPE IN ('SERVICE_PARTNUMBER'))
             OR (V_KEY_TBL(i).KEY_TYPE IN ('BILLING_PARTNUMBER'))

      THEN
        OPEN esn_plan_cur( lv_esn, l_enrl_status) ;
        FETCH esn_plan_cur INTO esn_plan_rec;
        IF esn_plan_cur%notfound THEN
          CLOSE esn_plan_cur;
        ELSE
          --
          CLOSE esn_plan_cur;
          --
          IF v_key_tbl(i).key_type IN ('ISUNLIMITED') THEN
            v_key_tbl(i).key_value := esn_plan_rec.isunlimited;
          END IF;

          IF v_key_tbl(i).key_type IN ('SERVICEPLANNAME') THEN
            v_key_tbl(i).key_value := esn_plan_rec.sp_name;
          END IF;

          IF (V_KEY_TBL(i).KEY_TYPE IN ('SERVICEPLANID')) THEN
            V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.sp_id;
          END IF;

          IF (V_KEY_TBL(i).KEY_TYPE IN ('ISAUTOREFILL')) THEN
            V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.AUTOREFILL;
          END IF;
          IF (V_KEY_TBL(i).KEY_TYPE IN ('SERVICE_PARTNUMBER')) THEN
            V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.service_partnum;
          END IF;

          IF (V_KEY_TBL(i).KEY_TYPE IN ('BILLING_PARTNUMBER')) THEN
            V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.billing_partnum;
          END IF;
          --
        END IF; -- IF esn_plan_cur%notfound
      END IF; -- IF (V_KEY_TBL(i).KEY_TYPE IN ...

      IF ( get_esn_info_rec.status = '52' ) THEN
        IF (V_KEY_TBL(i).KEY_TYPE IN ( 'CARRIER' )) THEN
          BEGIN
            SELECT p.x_parent_name
            INTO   l_carier
            FROM   table_site_part sp,
                   table_part_inst pi,
                   table_x_carrier ca,
                   table_x_carrier_group cg,
                   table_x_parent p
            WHERE  1 = 1
            AND    sp.x_service_id   = lv_esn
            AND    pi.part_serial_no = sp.x_min
            AND    pi.x_domain       = 'LINES'
            AND    sp.part_status    = 'Active'
            AND    ca.objid          = pi.part_inst2carrier_mkt
            AND    cg.objid          = ca.CARRIER2CARRIER_GROUP
            AND    p.objid           = cg.X_CARRIER_GROUP2X_PARENT;

            V_KEY_TBL(i).KEY_VALUE    := l_carier;
            V_KEY_TBL(i).RESULT_VALUE := 'success';

           EXCEPTION
             WHEN OTHERS THEN
               --dbms_output.put_line ('exception for carrier');
               V_Key_Tbl(i).Key_Type     := 'CARRIER';
               V_Key_tbl(i).key_Value    := 0;
               V_KEY_TBL(i).RESULT_VALUE := 'Fail';
          END;
        END IF;
      ELSIF ((GET_ESN_INFO_REC.STATUS <> '52') AND (V_KEY_TBL(i).KEY_TYPE IN ('CARRIER')))
      THEN

        V_Key_Tbl(i).Key_Type     := 'CARRIER';
        V_Key_tbl(i).key_Value    := 0;
        V_KEY_TBL(i).RESULT_VALUE := 'Fail';
      END IF;

      IF (V_KEY_TBL(i).KEY_TYPE IN ('LEASESTATUS')) THEN
        BEGIN
          SELECT lease_status
          INTO   l_lease_status
          FROM   x_customer_lease
          WHERE  x_esn  = lv_esn;

          V_KEY_TBL(i).KEY_VALUE    := l_lease_status;
          V_KEY_TBL(i).RESULT_VALUE := 'success';

         EXCEPTION
           WHEN OTHERS THEN
             V_Key_Tbl(i).Key_Type     := 'LEASESTATUS';
             V_Key_tbl(i).key_Value    := '1000'; -- Set as the DEFAULT value for Non-Leased subscribers
             V_KEY_TBL(i).RESULT_VALUE := 'Fail';
        END;
      END IF;

                  IF (V_KEY_TBL(i).KEY_TYPE IN ('LEASETOOWN')) THEN   --BYOP Rebrand  CR46193 START
        BEGIN
                 SELECT DECODE (LEASE_STATUS_NAME,'Current','Y','Current-R','Y','Review','Y','N')
          INTO   l_lease_to_own
          FROM   x_customer_lease cl,X_LEASE_STATUS ls
          WHERE  x_esn           = lv_esn --'100000001924926'
          AND    cl.lease_status = ls.lease_status;

          V_KEY_TBL(i).KEY_VALUE    := l_lease_to_own;
          V_KEY_TBL(i).RESULT_VALUE := 'success';

         EXCEPTION
           WHEN OTHERS THEN
             V_Key_Tbl(i).Key_Type     := 'LEASETOOWN';
             V_Key_tbl(i).key_Value    := 'N'; -- Set as the DEFAULT value for Non-Leased subscribers
             V_KEY_TBL(i).RESULT_VALUE := 'Fail';
        END;
      END IF;

                  IF (V_KEY_TBL(i).KEY_TYPE IN ('ZIP')) THEN
      BEGIN
       --To fix too many rows issue

       SELECT x_zipcode
       INTO   v_zipcode
       FROM   table_site_part sp
       WHERE  1 = 1
       AND    sp.x_service_id = lv_esn
       AND    sp.install_date = (
                                 SELECT  MAX(install_date)
                                 FROM    table_site_part
                                 WHERE   x_service_id = sp.x_service_id
                                )
       AND    ROWNUM = 1;

        V_KEY_TBL(i).KEY_VALUE    := v_zipcode;
        V_KEY_TBL(i).RESULT_VALUE := 'success';

         EXCEPTION
           WHEN OTHERS THEN
             V_Key_Tbl(i).Key_Type     := 'ZIP';
             V_Key_tbl(i).key_Value    := ''; -- Set as the DEFAULT value for Non-Leased subscribers
             V_KEY_TBL(i).RESULT_VALUE := 'Fail';
        END;
      END IF;

                  IF (V_KEY_TBL(i).KEY_TYPE IN ( 'REBRAND_CARRIER' )) THEN
          BEGIN
            --To fix too many rows issue
            SELECT util_pkg.get_parent_name(lv_esn)
            INTO   rebrand_carrier
            FROM   dual;


            IF rebrand_carrier IS NOT NULL
            THEN --{
             V_KEY_TBL(i).KEY_VALUE    := rebrand_carrier;
             V_KEY_TBL(i).RESULT_VALUE := 'success';
            ELSE
             V_Key_Tbl(i).Key_Type     := 'REBRAND_CARRIER';
             V_Key_tbl(i).key_Value    := 0;
             V_KEY_TBL(i).RESULT_VALUE := 'Fail';
            END IF; --}

           EXCEPTION
             WHEN OTHERS THEN
               --dbms_output.put_line ('exception for carrier');
               V_Key_Tbl(i).Key_Type     := 'REBRAND_CARRIER';
               V_Key_tbl(i).key_Value    := 0;
               V_KEY_TBL(i).RESULT_VALUE := 'Fail';
          END;
        END IF;

                  IF (V_KEY_TBL(i).KEY_TYPE IN ('IS_LTE')) THEN
   BEGIN
        SELECT 'Y'
        INTO   v_is_lte --pn.PART_NUMBER
        FROM   table_part_class pc,
               table_bus_org bo,
               table_part_num pn,
               pc_params_view vw,
               table_part_inst pi,
               table_mod_level ml
        WHERE  pn.part_num2bus_org    = bo.objid
       AND    pn.pArt_num2part_class = pc.objid
        AND    PC.NAME                = VW.PART_CLASS
        AND    VW.PARAM_NAME          = 'CDMA LTE SIM' --'DLL'      --YM 07/13/2013
        AND    VW.PARAM_VALUE         = 'REMOVABLE'    --'-8'       --YM 07/13/2013
        AND    PI.N_PART_INST2PART_MOD= ML.OBJID
        AND    ML.PART_INFO2PART_NUM  = PN.OBJID
        AND    pi.part_serial_no      = lv_esn;

          V_KEY_TBL(i).KEY_VALUE    := v_is_lte;
          V_KEY_TBL(i).RESULT_VALUE := 'success';

   EXCEPTION
       WHEN OTHERS THEN
       V_Key_Tbl(i).Key_Type     := 'IS_LTE';
       V_Key_tbl(i).key_Value    := 'N'; -- Set as the DEFAULT value for Non-Leased subscribers
       V_KEY_TBL(i).RESULT_VALUE := 'Fail';
   END;
   END IF;

IF (V_KEY_TBL(i).KEY_TYPE IN ('REBRAND_EQUI_PHONE'))
THEN   --BYOP Rebrand  CR46193 START {

   --New logic as part of CR46195
   IF get_esn_info_rec.technology = 'CDMA'
   THEN --{
     get_cdma_rebrand_pn
                       (
                        lv_esn,
                        v_is_lte,
                        ip_org_id,
                        l_new_part_num,
                        v_rebrand,
                        lv_err_num,
                        lv_err_msg,
                        i_zip_code,
                        o_new_sim_part_num
                       );

      IF lv_err_num = '0'
      THEN --{
       V_KEY_TBL(i).KEY_VALUE    := v_rebrand;
       V_KEY_TBL(i).RESULT_VALUE := 'success';
      ELSE --}{
       V_Key_tbl(i).key_Value    := 'N';
       V_KEY_TBL(i).RESULT_VALUE := 'Fail';
      END IF; --}

   ELSE --}{
    V_Key_tbl(i).key_Value    := 'N';
    V_KEY_TBL(i).RESULT_VALUE := 'Fail';

   END IF; --}
END IF; --}

--50666
IF (V_KEY_TBL(i).KEY_TYPE IN ('SL_REBRAND_EQUI_PHONE'))
THEN --{
  get_sl_equi_phone
                  (
                   lv_esn,
                   ip_org_id,
                   l_new_part_num,
                   v_rebrand,
                   lv_err_num,
                   lv_err_msg
                  );

      IF lv_err_num = '0'
      THEN --{
       V_KEY_TBL(i).KEY_VALUE    := v_rebrand;
       V_KEY_TBL(i).RESULT_VALUE := 'success';
      ELSE --}{
       V_Key_tbl(i).key_Value    := 'N';
       V_KEY_TBL(i).RESULT_VALUE := 'Fail';
      END IF; --}
END IF; --}

    IF (V_KEY_TBL(i).KEY_TYPE IN ('WARRANTY')) THEN
    BEGIN
      SELECT /*+ ORDERED */
             'Y'--pp.x_program_name
      INTO   v_ext_warranty
      FROM   sa.x_program_enrolled   pe,
             sa.x_program_parameters pp,
             sa.table_part_num       pn
      WHERE  pe.x_esn = lv_esn
      AND    pe.x_enrollment_status not in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
      AND    pp.objid = pe.pgm_enroll2pgm_parameter
      AND    pp.x_prog_class = 'WARRANTY'
      AND    pn.objid = pp.prog_param2prtnum_monfee
      ORDER  BY x_insert_date DESC;

                                                V_KEY_TBL(i).KEY_VALUE    := v_ext_warranty;
                                                V_KEY_TBL(i).RESULT_VALUE := 'success';

         EXCEPTION
           WHEN OTHERS THEN
             V_Key_Tbl(i).Key_Type     := 'WARRANTY';
             V_Key_tbl(i).key_Value    := 'N'; -- Set as the DEFAULT value for Non-Leased subscribers
             V_KEY_TBL(i).RESULT_VALUE := 'Fail';
    END;
    END IF;

    IF (V_KEY_TBL(i).KEY_TYPE IN ('AUTOENROLLMENT')) THEN
    BEGIN
  --To fix too many rows issue

	  SELECT  x_enrollment_status
	  INTO    v_enrollment_status
	  FROM    x_program_parameters pgmprm,
			  x_program_enrolled pgmenr
	  WHERE   pgmprm.objid          = pgmenr.pgm_enroll2pgm_parameter
	  AND     pgmprm.x_is_recurring = 1
	  AND     NVL(pgmprm.x_prog_class, ' ') NOT IN ('HMO', 'ONDEMAND', 'WARRANTY', 'LOWBALANCE')
	  AND     pgmenr.x_esn          = lv_esn
	  AND     x_enrollment_status = 'ENROLLED'
	  AND     ROWNUM = 1;

	  IF v_enrollment_status != 'ENROLLED'
	  THEN --{
	   v_enrollment_status := 'DEENROLLED';
	  END IF; --}

      V_KEY_TBL(i).KEY_VALUE    := v_enrollment_status;
      V_KEY_TBL(i).RESULT_VALUE := 'success';

    EXCEPTION
    WHEN OTHERS THEN
		 V_Key_Tbl(i).Key_Type     := 'AUTOENROLLMENT';
		 V_Key_tbl(i).key_Value    := 'N'; -- Set as the DEFAULT value for Noenrollment
		 V_KEY_TBL(i).RESULT_VALUE := 'Fail';
    END;
    END IF;     --BYOP Rebrand  CR46193 END

      IF (V_KEY_TBL(i).KEY_TYPE IN ('OLD_ESN')) THEN
        -- ADD THE LOGIC TO PASS IP ESN IF NEW ESN ISFOUND
        --
        if lv_esn <> in_esn then
          V_KEY_TBL(i).KEY_VALUE    := in_esn;
          V_KEY_TBL(i).RESULT_VALUE := 'success';
        else
          V_KEY_TBL(i).KEY_VALUE    := NULL;
          V_KEY_TBL(i).RESULT_VALUE := 'Fail';
        end if;
      END IF;

      -- start TW+

      -- instantiate initial values
      rc := customer_type ( i_esn => lv_esn );

      -- call the retrieve method
      cst := rc.retrieve;

      -- Set account group id
      IF v_key_tbl(i).key_type = 'GROUPID' THEN
        v_key_tbl(i).key_value := cst.account_group_objid;
      END IF;

      -- Set group available capacity
      IF v_key_tbl(i).key_type = 'AVAILABLE_LINES' THEN
        v_key_tbl(i).key_value := cst.group_available_capacity;
      END IF;

      -- Set group allowed lines
      IF v_key_tbl(i).key_type = 'TOTAL_LINES' THEN
        v_key_tbl(i).key_value := cst.group_allowed_lines;
      END IF;

      -- Set group allowed lines
      IF v_key_tbl(i).key_type = 'PIN_PART_NUMBER' THEN
        v_key_tbl(i).key_value := NVL(cst.service_plan_part_number,cst.pin_part_number);
      END IF;

      -- Set the phone upgrade flag
      IF v_key_tbl(i).key_type = 'ESN_CHANGE_TYPE' THEN
        --CR46039 Begin Check if case type has already been captured
        IF lv_case_type IS NOT NULL THEN
          V_KEY_TBL(i).KEY_VALUE    := lv_case_type;
          V_KEY_TBL(i).RESULT_VALUE := 'success';
        ELSE
          -- call case type function to get the latest case data  UPGRADE CR46039 Begin
          ct := ctp.get ( i_esn        => lv_esn            ,
                          i_case_title => '%PHONE%UPGRADE' );
          --
          IF ct.case_objid IS NOT NULL THEN
            v_key_tbl(i).key_value :=  'UPGRADE';
          END IF;

          --
          IF v_key_tbl(i).key_value IS NULL THEN
            -- Get the exchange value
             ct := case_type ();
            -- call case type function to get the latest case data REPLACEMENT UNITS
            ct := ctp.get ( i_esn        => lv_esn            ,
                            i_case_title => '%REPLACEMENT%UNITS%' );
            --
            IF ct.case_objid IS NOT NULL THEN

              -- Verify it is truly an EXCHANGE
              BEGIN
                SELECT 'EXCHANGE'
                INTO   v_key_tbl(i).key_value
                FROM   DUAL
                WHERE  EXISTS ( SELECT 1
                                FROM   sa.table_x_call_trans
                                WHERE  x_service_id = lv_esn
                                AND    x_action_type = '6'
                                AND    x_reason like '%REPLACEMENT%'
                                AND    x_result = 'Completed'
                              );
                EXCEPTION
                  WHEN others THEN
                  v_key_tbl(i).key_value := NULL;
              END;
            END IF;
          END IF;
        END IF;
        --CR46039 END
      END IF;

      --Start CR41570 for Dollar General
                  -- Set Carrier Objid
                                  IF v_key_tbl(i).key_type = 'CARRIER_OBJID' THEN
                                                v_key_tbl(i).key_value := cst.carrier_objid;
                                  END IF;
                  --End CR41570

                   --CR50154 - ST LTO Changes - Start
                   IF (V_KEY_TBL(i).KEY_TYPE IN ('LAST_REDEEMED_PLAN_PART_NUMBER')) THEN
                   V_KEY_TBL(i).KEY_VALUE := l_last_redm_plan_part_num;
                   END IF;

                   IF (V_KEY_TBL(i).KEY_TYPE IN ('LAST_REDEEMED_PLAN_PART_CLASS')) THEN
                   V_KEY_TBL(i).KEY_VALUE := l_last_redm_plan_pc;
                   END IF;
                  --CR50154 - ST LTO Changes - End

      -- Set result with the response
      v_key_tbl(i).result_value := NULL;
      v_key_tbl(i).result_value := CASE WHEN v_key_tbl(i).key_value IS NULL THEN 'Fail' ELSE 'success' END;

      -- end TW+

    END LOOP;
  END IF;

  --
  io_key_tbl := v_key_tbl;

  out_err_code := 0;
  out_err_msg := 'SUCCESS';

EXCEPTION
   WHEN OTHERS THEN
     --
     OUT_ERR_CODE    := -99;
     OUT_ERR_MSG := SUBSTR(SQLERRM,1, 300);
     --
END p_get_updated_esn_attributes;
FUNCTION cancel_risk_alerts(
    ip_user_objid NUMBER,
    ip_esn_objid  NUMBER)
  RETURN VARCHAR2
AS
  v_title VARCHAR2(200):='Risk Assessment Alert';
BEGIN

  delete  sa.table_alert
  WHERE Alert2contract = ip_esn_objid
  AND title            = v_title;

  RETURN 'Alert removed';

END;

/*********************************************************************
procedure  : p_insert_pi_history
date       : 08/31/2015
description: Procedure developed as part of phone in a box project.
             This procedure is used to log the changes made to any
             record on table_part_inst.
**********************************************************************/
procedure      p_insert_pi_history (
   ip_user_objid   IN       NUMBER,
   ip_esn         IN       VARCHAR2,
   ip_old_npa      IN       VARCHAR2,
   ip_old_nxx      IN       VARCHAR2,
   ip_old_ext      IN       VARCHAR2,
   ip_reason       IN       VARCHAR2,
   ip_out_val      OUT      NUMBER
)
IS

   CURSOR get_line_info_cur
   IS
      SELECT *
        FROM table_part_inst
       WHERE part_serial_no = ip_esn;

   get_line_info_rec           get_line_info_cur%ROWTYPE;
   v_procedure_name   CONSTANT VARCHAR2 (200)         := 'insert_pi_hist_prc';
   v_pi_hist_seq               NUMBER;
   e_notfound                  EXCEPTION;
BEGIN
   OPEN get_line_info_cur;

   FETCH get_line_info_cur
    INTO get_line_info_rec;

   IF get_line_info_cur%NOTFOUND
   THEN
      RAISE e_notfound;

      CLOSE get_line_info_cur;
   ELSE
      sa.sp_seq ('x_pi_hist', v_pi_hist_seq);

      INSERT INTO table_x_pi_hist
                  (objid, status_hist2x_code_table,
                   x_change_date, x_change_reason, x_cool_end_date,
                   x_creation_date,
                   x_deactivation_flag,
                   x_domain, x_ext,
                   x_insert_date, x_npa,
                   x_nxx, x_old_ext, x_old_npa,
                   x_old_nxx, x_part_bin,
                   x_part_inst_status,
                   x_part_mod,
                   x_part_serial_no,
                   x_part_status,
                   x_pi_hist2carrier_mkt,
                   x_pi_hist2inv_bin,
                   x_pi_hist2part_inst,
                   x_pi_hist2part_mod, x_pi_hist2user,
                   x_pi_hist2x_new_pers,
                   x_pi_hist2x_pers,
                   x_po_num,
                   x_reactivation_flag,
                   x_red_code,
                   x_sequence,
                   x_warr_end_date, dev,
                   fulfill_hist2demand_dtl,
                   part_to_esn_hist2part_inst,
                   x_bad_res_qty,
                   x_date_in_serv,
                   x_good_res_qty,
                   x_last_cycle_ct,
                   x_last_mod_time,
                   x_last_pi_date,
                   x_last_trans_time,
                   x_next_cycle_ct,
                   x_order_number,
                   x_part_bad_qty,
                   x_part_good_qty,
                   x_pi_tag_no,
                   x_pick_request,
                   x_repair_date,
                   x_transaction_id, x_msid
                  )
           VALUES (v_pi_hist_seq, get_line_info_rec.status2x_code_table,
                   SYSDATE, ip_reason, get_line_info_rec.x_cool_end_date,
                   get_line_info_rec.x_creation_date,
                   get_line_info_rec.x_deactivation_flag,
                   get_line_info_rec.x_domain, get_line_info_rec.x_ext,
                   get_line_info_rec.x_insert_date, get_line_info_rec.x_npa,
                   get_line_info_rec.x_nxx, ip_old_ext, ip_old_npa,
                   ip_old_nxx, get_line_info_rec.part_bin,
                   get_line_info_rec.x_part_inst_status,
                   get_line_info_rec.part_mod,
                   get_line_info_rec.part_serial_no,
                   get_line_info_rec.part_status,
                   get_line_info_rec.part_inst2carrier_mkt,
                   get_line_info_rec.part_inst2inv_bin,
                   get_line_info_rec.objid,
                   get_line_info_rec.n_part_inst2part_mod, ip_user_objid,
                   get_line_info_rec.part_inst2x_new_pers,
                   get_line_info_rec.part_inst2x_pers,
                   get_line_info_rec.x_po_num,
                   get_line_info_rec.x_reactivation_flag,
                   get_line_info_rec.x_red_code,
                   get_line_info_rec.x_sequence,
                   get_line_info_rec.warr_end_date, get_line_info_rec.dev,
                   get_line_info_rec.fulfill2demand_dtl,
                   get_line_info_rec.part_to_esn2part_inst,
                   get_line_info_rec.bad_res_qty,
                   get_line_info_rec.date_in_serv,
                   get_line_info_rec.good_res_qty,
                   get_line_info_rec.last_cycle_ct,
                   get_line_info_rec.last_mod_time,
                   get_line_info_rec.last_pi_date,
                   get_line_info_rec.last_trans_time,
                   get_line_info_rec.next_cycle_ct,
                   get_line_info_rec.x_order_number,
                   get_line_info_rec.part_bad_qty,
                   get_line_info_rec.part_good_qty,
                   get_line_info_rec.pi_tag_no,
                   get_line_info_rec.pick_request,
                   get_line_info_rec.repair_date,
                   get_line_info_rec.transaction_id, get_line_info_rec.x_msid
                  );
   END IF;

   IF get_line_info_cur%ISOPEN
   THEN
      CLOSE get_line_info_cur;
   END IF;

    ip_out_val := 0;

EXCEPTION
   WHEN e_notfound
   THEN
      IF get_line_info_cur%ISOPEN
      THEN
         CLOSE get_line_info_cur;
      END IF;

   WHEN OTHERS
   THEN
      IF get_line_info_cur%ISOPEN
      THEN
         CLOSE get_line_info_cur;
      END IF;

END p_insert_pi_history;
/*********************************************************************
procedure  : p_set_esn_status_used
date       : 08/26/2015
description: Procedure developed as part of phone in a box project.
             This procedure is used to set the status of given ESN
             to USED status from RISK ASSESMENT status.
**********************************************************************/
PROCEDURE p_set_esn_status_used(
    ip_esn          VARCHAR2,
    ip_user_objid   VARCHAR2,
    ip_zero_out_max VARCHAR2,
    out_error_code  OUT number,
    out_message     OUT VARCHAR2)
IS

  lv_reason  VARCHAR2(30):='STATUS CHANGE';
  lv_output  VARCHAR2(200);
  lv_used_objid  VARCHAR2(20);
  lv_used_code   VARCHAR2(20);
  lv_used_desc   VARCHAR2(200);
  lv_return  VARCHAR2(30);
  esn_exist number;

  CURSOR cur_esn
  IS
    SELECT x_part_inst_status,
          objid
    FROM table_part_inst
    WHERE part_serial_no = ip_esn
    AND x_domain         = 'PHONES';
  rec_esn cur_esn%rowtype;

BEGIN

  if ip_esn  is null
    then
    out_error_code := -311;
    out_message  := 'Please provide a valid Serial Number(ESN)';
    return;
  end if;

/*check if ESN is available on table_part_inst*/
      SELECT COUNT(*)
       INTO esn_exist
       FROM table_part_inst
       WHERE part_serial_no = ip_esn;

       IF esn_exist = 0 THEN
         out_error_code := 101;
         out_message  := 'Serial Number not found';
         RETURN;
       END IF;

  SELECT objid,
    x_code_number,
    x_code_name
  INTO lv_used_objid,
    lv_used_code,
    lv_used_desc
  FROM table_x_code_table
  WHERE x_code_name = 'USED'
  AND x_code_type   = 'PS';

  OPEN cur_esn;
  FETCH cur_esn INTO rec_esn;

  IF cur_esn%found THEN

    IF rec_esn.x_part_inst_status NOT IN ('55','56') THEN
      CLOSE cur_esn;
       out_error_code := -312;
       out_message := 'This Phone Does not have a status that allows it to be Reset.';

      RETURN;
    END IF;

    UPDATE table_part_inst
    SET x_part_inst_status = lv_used_code,
      STATUS2X_CODE_TABLE  = lv_used_objid
    WHERE part_serial_no   = ip_esn
    AND x_domain           = 'PHONES';

        p_insert_pi_history( IP_USER_OBJID => ip_user_objid,
                           IP_ESN => ip_esn,
                           IP_OLD_NPA => '',
                           IP_OLD_NXX => '',
                           IP_OLD_EXT => '',
                           IP_REASON => lv_reason,
                           IP_OUT_VAL => lv_output
                          );

    out_error_code := 0;
    out_message := 'SUCCESS';

  END IF;

  CLOSE cur_esn;

  IF ip_zero_out_max='1' THEN
    INSERT
    INTO table_x_zero_out_max
      (
        objid,
        x_esn,
        x_req_date_time,
        x_sourcesystem,
        x_deposit,
        x_transaction_type,
        x_zero_out2user
      )
      VALUES
      (
        sa.seq('x_zero_out_max'),
        ip_esn,
        sysdate,
        'API',
        0,5,
        ip_user_objid
      );
  END IF;

  lv_return := cancel_risk_alerts(ip_user_objid,rec_esn.objid);

Exception
when others then
out_error_code := -99;
out_message := SQLERRM;

END p_set_esn_status_used;
--
-- CR43524 changes starts..
-- Refactored the existing IVR procedure for IVR TF
PROCEDURE Getesnattributes(io_esn                      IN OUT VARCHAR2,
                           io_min                      IN OUT VARCHAR2,
                           o_esn_brand                 OUT    VARCHAR2,
                           o_esn_status                OUT    VARCHAR2,
                           o_esn_sub_status            OUT    VARCHAR2,
                           o_esn_plan_grp              OUT    VARCHAR2,
                           o_my_acc_login              OUT    VARCHAR2,
                           o_web_user_objid            OUT    VARCHAR2,
                           o_part_class                OUT    VARCHAR2, --phone pc
                           o_part_num                  OUT    VARCHAR2, --phone_part_num
                           o_num_pin_queued            OUT    NUMBER  ,
                           o_last_redm_plan_part_num   OUT    VARCHAR2,
                           o_last_redm_plan_pc         OUT    VARCHAR2,
                           o_enrl_autref_flag          OUT    VARCHAR2,
                           o_enrl_objid                OUT    NUMBER,
                           o_enrl_dbl_min_promo_flag   OUT    VARCHAR2,
                           o_enrl_trpl_min_promo_flag  OUT    VARCHAR2,
                           o_enrl_hpp_flag             OUT    VARCHAR2,
                           o_is_hpp_eligible           OUT    VARCHAR2,
                           o_enrl_hpp_price            OUT    NUMBER  ,
                           o_enrl_ild_flag             OUT    VARCHAR2,
                           o_phone_technology          OUT    VARCHAR2,
                           o_sim_number                OUT    VARCHAR2,
                           o_zipcode                   OUT    VARCHAR2,
                           o_dev_type                  OUT    VARCHAR2,
                           o_flash_id                  OUT    VARCHAR2,
                           o_flash_txt                 OUT    VARCHAR2,
                           o_service_end_date          OUT    VARCHAR2,
                           o_forecast_end_date         OUT    VARCHAR2,
                           o_base_plan                 out    VARCHAR2,
                           o_curr_splanid              OUT    NUMBER,
                           o_splan_type                OUT    VARCHAR2,
                           o_curr_splan_name           OUT    VARCHAR2,
                           o_is_promo_eligible         OUT    VARCHAR2,
                           o_is_safelink               OUT    VARCHAR2,
                           o_contact_objid             OUT    NUMBER,
                           o_errnum                    OUT    VARCHAR2,
                           o_errstr                    OUT    VARCHAR2
                           ) is
  --
  CURSOR c_q_service_days (i_esn_objid   table_part_inst.objid%TYPE)
  IS
    SELECT *
    FROM (
          SELECT  pi.x_red_code,
                  pn.part_number,
                  TRIM(regexp_replace(NVL(spf.service_days,0),'[[:alpha:]]','') ) service_day,
                  ROW_NUMBER() OVER(PARTITION BY pi.x_red_code ORDER BY spf.SPLAN_OBJID) AS rn
          FROM    table_part_inst pi,
                  table_mod_level ml,
                  table_part_num  pn,
                  splan_feat_pivot spf
          WHERE   spf.plan_purchase_part_number = pn.part_number
          AND     ml.PART_INFO2PART_NUM         = pn.objid
          AND     pi.n_part_inst2part_mod       = ml.objid
          AND     pi.X_PART_INST_STATUS         = '400'
          AND     pi.x_domain                   = 'REDEMPTION CARDS'
          AND     pi.PART_TO_ESN2PART_INST      = i_esn_objid
          UNION
          SELECT  pi.x_red_code,
                  pn.part_number,
                  TRIM(regexp_replace(NVL(spf.service_days,0),'[[:alpha:]]','') ) service_day,
                  ROW_NUMBER() OVER(PARTITION BY pi.x_red_code ORDER BY spf.SPLAN_OBJID) AS rn
          FROM    adfcrm_serv_plan_class_matview spc,
                  splan_feat_pivot  spf,
                  table_part_inst   pi,
                  table_mod_level   ml,
                  table_part_num    pn
          WHERE   spc.SP_OBJID                =   spf.splan_objid
          AND     pn.part_num2part_class      =   spc.PART_CLASS_OBJID
          AND     ml.PART_INFO2PART_NUM       =   pn.objid
          AND     pi.n_part_inst2part_mod     =   ml.objid
          AND     pi.X_PART_INST_STATUS       =   '400'
          AND     pi.x_domain                 =   'REDEMPTION CARDS'
          AND     pi.PART_TO_ESN2PART_INST    =   i_esn_objid
          )  a
    WHERE a.rn  = 1;
  --
  s subscriber_type := subscriber_type();
  s2 subscriber_type;
  l_esn_objid number;
  l_web_user number;
  ret_code number;
  ret_msg  varchar2(300);
  l_part_inst2site_part   table_part_inst.x_part_inst2site_part%TYPE;
  l_queued_service_days   NUMBER  :=  0;
  --
  PROCEDURE get_last_red_details(ip_esn         IN  VARCHAR2,
                                 op_red_partno  OUT VARCHAR2,
                                 op_red_pc      OUT VARCHAR2,
                                 op_code        OUT NUMBER,
                                 op_msg         OUT VARCHAR2 )
  IS
  --
  BEGIN
    SELECT part_num,pc.name
    INTO op_red_partno,op_red_pc
    FROM (
        SELECT 1,x_service_id,x_transact_date,spsp.x_service_plan_id,mv.PLAN_PURCHASE_PART_NUMBER part_num,
               mv.SP_MKT_NAME
        FROM   table_x_call_trans ct,
               sa.X_SERVICE_PLAN_SITE_PART spsp,
               splan_feat_pivot mv
        WHERE  1 = 1
        AND    spsp.TABLE_SITE_PART_ID =  ct.CALL_TRANS2SITE_PART
        AND    ct.x_action_type+0      in ( 1, 3, 6)
        AND    splan_objid             =  spsp.X_SERVICE_PLAN_ID
        AND    service_plan_group      <> 'ADD_ON_DATA'
        AND    ct.X_SERVICE_ID         = ip_esn
        UNION
        SELECT 2,CT.X_SERVICE_ID, ct.x_transact_date,-1, part_number,'  '
        FROM  table_x_call_trans ct,
              table_x_red_card rc,
              table_mod_level ml,
              table_part_num pn
        WHERE ct.objid                =   rc.RED_CARD2CALL_TRANS
        AND   ct.x_action_type        in ( '1','3','6')
        AND   rc.X_RED_CARD2PART_MOD  =   ml.objid
        AND   ml.part_info2part_num   =   pn.objid
        AND   PN.X_REDEEM_UNITS > 0
        AND   pn.X_REDEEM_DAYS  >0
        AND   ct.X_SERVICE_ID         =   ip_esn
        UNION
        SELECT 3,CT.X_SERVICE_ID, CT.X_TRANSACT_DATE,-100, PN.PART_NUMBER,PP.X_PROGRAM_DESC
        FROM  TABLE_X_CALL_TRANS CT,
              x_program_gencode GC,
              sa.X_PROGRAM_PURCH_DTL DTL,
              sa.X_PROGRAM_ENROLLED PE,
              sa.X_PROGRAM_PARAMETERS PP,
              TABLE_PART_NUM PN
        WHERE CT.OBJID = GC.GENCODE2CALL_TRANS
        AND   GENCODE2PROG_PURCH_HDR          = DTL.PGM_PURCH_DTL2PROG_HDR
        AND   DTL.PGM_PURCH_DTL2PGM_ENROLLED  = pe.OBJID
        AND   PE.PGM_ENROLL2PGM_PARAMETER     = PP.OBJID
        AND   PN.OBJID IN ( PP.PROG_PARAM2APP_PRT_NUM, PP.PROG_PARAM2PRTNUM_MONFEE)
        AND   ct.X_SERVICE_ID                 = ip_esn
        ORDER BY X_TRANSACT_DATE DESC,1) main,
        table_part_num    pn,
        table_part_class  pc
    WHERE main.X_SERVICE_ID = ip_esn
    AND   main.part_num = pn.part_number
    AND   pn.part_num2part_class(+) = pc.objid
    AND   rownum < 2;
    --
    op_code := 0;
    op_msg  := 'SUCCESS';
    --
   EXCEPTION
       WHEN OTHERS THEN
          op_code := sqlcode;
          op_msg  := sqlerrm;
   END get_last_red_details;
   --
BEGIN  -- Main
  -- Validate Input parameters
  IF (io_esn||io_min IS NULL)
  THEN
    o_errnum := -1;
    o_errstr := 'Both ESN and MIN cannot be NULL';
    RETURN;
   END IF;
  -- Get ESN
 IF io_esn IS NULL
  THEN
    BEGIN
      SELECT  pi_esn.part_serial_no
      INTO    io_esn
      FROM    table_part_inst pi_min,
              table_part_inst pi_esn
      WHERE   pi_min.part_serial_no           =   io_min
      AND     pi_min.x_domain(+)              =   'LINES'
      AND     pi_min.part_to_esn2part_inst(+) =   pi_esn.objid
      AND     pi_esn.x_domain                 =   'PHONES';
    EXCEPTION
      WHEN OTHERS THEN
       o_errnum   :=  -1;
       o_errstr   :=  'Error occured while fetching ESN';
       RETURN;
    END;
  END IF;
  --Initialize esn
  s.pcrf_esn := io_esn;
  s2 := s.retrieve;
  --
  IF (s2.status like '%ESN NOT FOUND%') THEN
    dbms_output.put_line('Invalid Esn');
    o_errnum   :=  -1;
    o_errstr   :=  'Not a valid ESN';
    RETURN;
  END IF;
  --
  io_min               := s2.pcrf_min;
  o_esn_brand          := s2.brand;
  o_esn_sub_status     := s2.part_inst_status;
  o_web_user_objid     := s2.web_user_objid;
  o_part_class         := s2.phone_model;
  --o_zipcode            := s2.zipcode;
  o_dev_type           := s2.device_type;
  o_service_end_date   := TO_CHAR(s2.pcrf_base_ttl,'YYYYMMDD');
    -- o_base_plan  Not needed
  o_curr_splanid       := s2.service_plan_id;
  o_esn_plan_grp       := s2.service_plan_type;
  o_contact_objid      := s2.contact_objid;
  o_flash_id           := NULL;   -- assigning NULL as it is not in scope of for this release
  o_flash_txt          := NULL;   -- assigning NULL as it is not in scope of for this release
  --
  -- Get Zip code
  BEGIN
    SELECT x_zipcode
    INTO   o_zipcode
    FROM   table_site_part sp
    WHERE  1 = 1
    AND    sp.x_service_id = s.pcrf_esn
    AND    sp.install_date = ( SELECT MAX(install_date)
                              FROM   table_site_part
                              WHERE  x_service_id = sp.x_service_id
                            )
	AND ROWNUM = 1;	-- Fix to ensure single row incase more than one row exists with exactly same install_date (fixed during CR57251)
  EXCEPTION
    WHEN OTHERS THEN
      o_zipcode  :=  NULL;
  END;
  --
  IF o_curr_splanid IS NULL
  THEN
    BEGIN
      SELECT spsp.X_SERVICE_PLAN_ID
      INTO   o_curr_splanid
      FROM   table_part_inst pi_esn,
             table_site_part sp,
             x_service_plan_site_part spsp
      WHERE  pi_esn.part_serial_no        = s.pcrf_esn
      AND    pi_esn.x_domain              = 'PHONES'
      AND    pi_esn.x_part_inst2site_part = sp.objid
      AND    sp.objid                     = spsp.table_site_part_id
      AND    sp.install_date              = ( SELECT MAX(install_date)
                                              FROM   table_site_part
                                              WHERE  x_service_id = sp.x_service_id);
    EXCEPTION
      WHEN OTHERS THEN
        o_curr_splanid  := NULL;
    END;
  END IF;
  --
  BEGIN
    --CR55362 - EASY MINUTES and WEB EXCLUSIVE should be PAYGO in order for AR to work through IVR
    SELECT  sp_mkt_name,
            DECODE (plan_type,'MONTHLY PLANS', 'MONTHLY',
                              'EASY MINUTES' , 'PAYGO'  ,
                              'WEB EXCLUSIVE', 'PAYGO'  , plan_type)
    INTO    o_curr_splan_name,
            o_splan_type
    FROM    splan_feat_pivot
    WHERE   splan_objid = o_curr_splanid;
    --
  EXCEPTION
     WHEN OTHERS THEN
       NULL;
  END;
  --
  BEGIN
    SELECT  pi.objid,
            pi.x_part_inst_status,
            pi.x_iccid,
            pn.part_number,
            pn.x_technology ,
            pi.x_part_inst2site_part
    INTO    l_esn_objid,
            o_esn_status,
            o_sim_number,
            o_part_num,
            o_phone_technology,
            l_part_inst2site_part
    FROM    table_part_inst pi,
            table_part_num pn,
            table_mod_level ml
    WHERE   pi.part_serial_no       =   s.pcrf_esn
    AND     pi.x_domain             =   'PHONES'
    AND     pi.n_part_inst2part_mod =   ml.objid
    AND     ml.part_info2part_num   =   pn.objid;
  EXCEPTION
     WHEN OTHERS THEN
       NULL;
  END;
  --
  BEGIN
    SELECT  NVL(o_esn_sub_status, sp.part_status),
            TO_CHAR(sp.warranty_date,'YYYYMMDD')
    INTO    o_esn_sub_status,
            o_forecast_end_date
    FROM    table_site_part sp
    WHERE   1      = 1
    AND     sp.objid = l_part_inst2site_part;
  EXCEPTION
     WHEN OTHERS THEN
       NULL;
  END;
  --
  IF s2.web_user_objid IS NOT NULL
  THEN
    BEGIN
      SELECT  s_login_name
      INTO    o_my_acc_login
      FROM    table_web_user
      WHERE   objid   =   s2.web_user_objid;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
  ELSE
    -- Get the web user and contact
    BEGIN
      SELECT wu.objid ,
             wu.login_name ,
             wu.web_user2contact
      INTO   o_web_user_objid,
             o_my_acc_login,
             o_contact_objid
      FROM   table_x_contact_part_inst cpi,
             table_web_user wu
      WHERE  1 = 1
      AND    cpi.x_contact_part_inst2part_inst  = l_esn_objid
      AND    wu.web_user2contact                = cpi.x_contact_part_inst2contact;
     EXCEPTION
       WHEN too_many_rows THEN
         --
         BEGIN
           SELECT DISTINCT web_user_objid,
                           web_login_name,
                           web_user2contact
           INTO   o_web_user_objid,
                  o_my_acc_login,
                  o_contact_objid
           FROM   ( SELECT wu.objid       web_user_objid,
                           wu.login_name  web_login_name,
                           wu.web_user2contact
                    FROM   table_x_contact_part_inst cpi,
                           table_web_user wu,
                           table_bus_org  bo
                    WHERE  1 = 1
                    AND    cpi.x_contact_part_inst2part_inst  = l_esn_objid
                    AND    wu.web_user2contact                = cpi.x_contact_part_inst2contact
                    AND    wu.web_user2bus_org                = bo.objid
                    AND    bo.org_id                          = o_esn_brand
                  );
          EXCEPTION
            WHEN others THEN
              NULL;
         END;
       WHEN OTHERS THEN
         NULL;
    END;
  END IF;
  --get last red plan
  get_last_red_details(io_esn,
                      o_last_redm_plan_part_num,
                      o_last_redm_plan_pc,
                      ret_code,
                      ret_msg );
  --
  IF o_last_redm_plan_part_num LIKE '%APPAR%' THEN
    BEGIN
      SELECT  plan_purchase_part_number
      INTO    o_last_redm_plan_part_num
      FROM    splan_feat_pivot pv
      WHERE   pv.plan_purchase_part_number = replace(o_last_redm_plan_part_num,'AR','')
      AND     ROWNUM < 2;
      --
      SELECT  pc.name
      INTO    o_last_redm_plan_pc
      FROM    table_part_class  pc,
              table_part_num    pn
      WHERE   pn.part_num2part_class      = pc.objid
      AND     pn.part_number              = o_last_redm_plan_part_num;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT  pc.name, pn.part_number
          INTO    o_last_redm_plan_pc, o_last_redm_plan_part_num
          FROM    table_part_num    pn,
                  table_part_num    pn2,
                  table_x_pricing   xp,
                  table_part_class  pc
          WHERE   pn2.part_number         =  o_last_redm_plan_part_num
          AND     pn.part_number          LIKE 'TSAPP%'
          AND     pn.part_number          NOT LIKE '%FREE'
          AND     pn.objid                = xp.X_PRICING2PART_NUM
          AND     xp.X_CHANNEL            = 'IVR'
          AND     SYSDATE BETWEEN xp.X_START_DATE and NVL(xp.x_end_date , sysdate)
          AND     pn.part_num2part_class  = pc.objid
      --    AND     pn2.x_redeem_days       = pn.x_redeem_days
          AND     pn2.x_redeem_units      = pn.x_redeem_units;
        EXCEPTION
          WHEN OTHERS THEN
          NULL;
        END;
      WHEN OTHERS THEN
        NULL;
    END;
    --
  END IF;
  --
  IF o_last_redm_plan_pc IN ('TFRGCARD','TFAPCARD')
  THEN
    BEGIN
      --
      SELECT  pc.name, pn.part_number
      INTO    o_last_redm_plan_pc, o_last_redm_plan_part_num
      FROM    table_part_num    pn,
              table_part_num    pn2,
              table_part_class  pc
      WHERE   pn2.part_number         =  o_last_redm_plan_part_num
      AND     pn.part_number          LIKE 'TSAPP%'
      AND     pn.part_number          NOT LIKE '%FREE'
      AND     pn.part_num2part_class  = pc.objid
      AND     pn2.x_redeem_days       = pn.x_redeem_days
      AND     pn2.x_redeem_units      = pn.x_redeem_units;
      --
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF;
  --
  BEGIN
    SELECT  DECODE(COUNT(*),0,'N','Y'),
            DECODE(COUNT(*),0,NULL,MIN(x_retail_price))
    INTO    o_is_hpp_eligible,
            o_enrl_hpp_price
    FROM    TABLE(sa.VALUE_ADDEDPRG.GetEligibleWTYPrograms(s.pcrf_esn));
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
    --dbms_output.put_line('HPP Elig '||substr(sqlerrm,1,90));
  END;
  --
  IF o_is_hpp_eligible = 'N' THEN
    --check if enrolled in hpp program
    BEGIN
      SELECT decode(count(*),0,'N','Y')
      INTO   o_enrl_hpp_flag
      FROM   x_vas_subscriptions  vs,
             x_program_parameters pp,
             table_part_num       pn
      WHERE  1 = 1
      AND    vs.vas_esn                     =  io_esn
      AND    vs.vas_name                    LIKE '%HPP%'
      AND    vs.program_parameters_objid    = pp.objid(+)
      AND    pp.prog_param2prtnum_enrlfee   = pn.objid;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_enrl_hpp_flag := 'N';
         WHEN TOO_MANY_ROWS THEN
            o_enrl_hpp_flag := 'Y';
         WHEN OTHERS THEN
            o_errnum := -1;
            o_errstr := 'Error occured while fetching HPP Flag';
         RETURN;
    END;
  ELSE
    o_enrl_hpp_flag := 'N';
  END IF;
  --
  -- number of pins queued
  SELECT  count(*)
  INTO    o_num_pin_queued
  FROM    table_part_inst
  WHERE   part_to_esn2part_inst = l_esn_objid
  AND     x_domain              = 'REDEMPTION CARDS'
  AND     x_part_inst_status    = '400';
  --
  -- Get the no of service days from queued cards
  FOR i IN  c_q_service_days (l_esn_objid)
  LOOP
    l_queued_service_days :=  l_queued_service_days + NVL(i.service_day,0);
  END LOOP;
  --
  o_forecast_end_date := TO_CHAR((TO_DATE(o_forecast_end_date, 'YYYYMMDD') + NVL(l_queued_service_days,0)),'YYYYMMDD');
  --
  BEGIN
    SELECT  NVL(MAX(decode(instr(pg.group_name,'DBL'),0,'N','Y')),'N') ENR_DM,
            NVL(MAX(decode(instr(pg.group_name,'X3X'),0,'N','Y')),'N') ENR_TM
    INTO    o_enrl_dbl_min_promo_flag,
            o_enrl_trpl_min_promo_flag
    FROM    table_part_inst esn,
            table_x_group2esn xge,
            table_x_promotion_group pg
    WHERE   esn.part_serial_no          = io_esn
    AND     xge.groupesn2part_inst      = esn.objid
    AND     xge.groupesn2x_promo_group  = pg.objid
    AND     SYSDATE BETWEEN NVL(xge.x_start_date,SYSDATE)
                       AND NVL(xge.x_end_date,SYSDATE);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  --
  --checking for auto refill
  BEGIN
    SELECT pe.objid,pe.pgm_enroll2web_user
    INTO  o_enrl_objid,l_web_user
    FROM  sa.x_program_enrolled   pe,
          sa.x_program_parameters PP
    WHERE PE.X_ESN = io_ESN
    AND   PE.x_next_charge_date >= trunc(sysdate)
    AND   PE.x_is_grp_primary = 1
    AND   PE.x_enrollment_status not in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
    AND   pp.objid = pe.pgm_enroll2pgm_parameter
    AND   NVL(pp.x_prog_class,'X') not in ('ONDEMAND','WARRANTY');
    --
    IF l_web_user IS NULL THEN
     IF  o_my_acc_login IS NULL THEN
        o_enrl_autref_flag := 'N';
     ELSE
        o_enrl_autref_flag := 'Y';
     END IF;
    ELSE
       o_enrl_autref_flag := 'Y';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      o_enrl_autref_flag := 'N';
  END;
  --
  --Check for ILD enrollment
  SELECT  DECODE(COUNT(*),0,'N','Y')
  INTO    o_enrl_ild_flag
  FROM    x_program_enrolled pe,
          x_program_parameters xpp
  WHERE   pe.x_esn                    = io_esn
  AND     pe.x_enrollment_status      = 'ENROLLED'
  AND     pe.pgm_enroll2pgm_parameter = xpp.objid
  AND     xpp.x_prog_class            = 'LOWBALANCE'
  AND     xpp.x_program_desc          LIKE '%ILD%';
  --
  SELECT  DECODE(COUNT(*),0,'N','Y')
  INTO    o_is_safelink
  FROM    sa.x_sl_currentvals cur,
          sa.table_site_part tsp,
          sa.x_program_enrolled pe
  WHERE   tsp.x_service_id       = pe.x_esn
  AND     tsp.x_service_id       = cur.x_current_esn
  AND     pe.x_enrollment_status = 'ENROLLED'
  AND     cur.x_current_esn      = io_esn
  AND     upper(tsp.part_status) = 'ACTIVE'
  AND     ROWNUM                 =  1;
  --
  BEGIN
    SELECT  DECODE(COUNT(*),0,'N','Y')
    INTO    o_is_promo_eligible
    FROM    table_part_num    pn,
            table_mod_level   ml,
            table_part_inst   pi,
            sa.pcpv_mv pcpv --CR47564 WFM changed to use pcpv_mv from pcpv view to improve performance
    WHERE   pcpv.bus_org              =   'TRACFONE'
    AND     NVL(pcpv.device_type,'X') IN  ('FEATURE_PHONE','BYOP','SMARTPHONE')
    AND     pn.part_num2part_class    =   pcpv.pc_objid
    AND     ml.part_info2part_num     =   pn.objid
    AND     pi.n_part_inst2part_mod   =   ml.objid
    AND     pi.part_serial_no         =   io_esn ;
  EXCEPTION
    WHEN OTHERS THEN
      o_is_promo_eligible :=  'N';
  END;
  --
  o_errnum  :=  '0';
  o_errstr  :=  'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
     o_errnum := -1;
     o_errstr := 'Failed in when others of getesnattributes';
END Getesnattributes;
-- CR43524  changes ends
--
PROCEDURE get_cust_profile_data(i_esn                       IN   VARCHAR2,
                                i_min                       IN   VARCHAR2,
                                o_my_acc_login              OUT  VARCHAR2,
                                o_web_user_objid            OUT  VARCHAR2,
                                o_num_of_ccards             OUT  NUMBER  ,
                                o_list_of_ccards            OUT  typ_creditcard_tbl,
                                o_contact_objid             OUT  VARCHAR2,
                                o_errnum                    OUT  VARCHAR2,
                                o_errstr                    OUT  VARCHAR2
                                )
IS
  l_esn                VARCHAR2(200):= i_esn ;
  l_min                VARCHAR2(200):= i_min ;
  l_zip_code           VARCHAR2(20)          ;
  l_esn_count          NUMBER                ;
  l_min_count          NUMBER                ;
  cust                 sa.customer_type      ;
  cst                  sa.customer_type      ;
--
BEGIN --Main Section
  --
  --To validate ESN and MIN cannot be NULL.
  IF (l_esn IS NULL and l_min IS NULL) THEN
    o_errnum := -1;
    o_errstr := ('Both ESN and MIN cannot be NULL');
    RETURN;
  END IF;
  --
  --To check ESN and MIN exists.
  BEGIN
    SELECT COUNT(*)
    INTO  l_esn_count
    FROM  table_part_inst pi_esn
    WHERE pi_esn.part_serial_no =  l_esn
    AND   pi_esn.x_domain       = 'PHONES';
    --
    SELECT COUNT(*)
    INTO  l_min_count
    FROM  table_part_inst pi_min
    WHERE pi_min.part_serial_no  = l_min
    AND   pi_min.x_domain        = 'LINES';
  EXCEPTION
    WHEN OTHERS THEN
    o_errnum := -1;
    o_errstr := 'Get Customer Profile Data - ESN and MIN Validation: '||substr(sqlerrm,1,100);
  END;
  --
  --To check either ESN or MIN should be passed as input.
  IF (l_esn IS NULL and l_min IS NOT NULL)
  THEN
    --MIN Validation
    IF l_min_count = 0 THEN
      o_errnum := '924'                ;
      o_errstr := 'MIN cannot be found';
      RETURN;
    END IF;
    --
    --Get ESN based on input MIN
    BEGIN
       SELECT pi_esn.part_serial_no
       INTO l_esn
       FROM table_part_inst pi_min,
            table_part_inst pi_esn
       WHERE pi_min.part_serial_no         = l_min
       AND pi_min.x_domain(+)              = 'LINES'
       AND pi_min.part_to_esn2part_inst(+) = pi_esn.objid
       AND pi_esn.x_domain                 = 'PHONES';
    EXCEPTION
      WHEN OTHERS THEN
       o_errnum := -1;
       o_errstr := ( 'Error occured while fetching ESN');
       RETURN;
    END;
    --
  ELSIF  (l_esn IS NOT NULL and l_min IS NULL) THEN
    --ESN Validation
    IF l_esn_count = 0 THEN
      o_errnum := '922';
      o_errstr := 'ESN cannot be found';
      RETURN;
    END IF;
  ELSIF  (l_esn IS NOT NULL and l_min IS NOT NULL) THEN
    --To validate both ESN and MIN doesnt exists.
    IF l_esn_count = 0 AND l_min_count = 0 THEN
       o_errnum := '925';
       o_errstr := 'ESN and MIN not found';
       RETURN;
    END IF;
  --
  END IF;
  --
  --Instantiate Customer Type
  cust := customer_type ( i_esn => l_esn );
  -- Calling the customer type retrieve method
  cst := cust.retrieve;

  --Retrieve and assignment for web_login_name,web_user_objid and contact_objid.
  o_my_acc_login   := cst.web_login_name ;
  o_web_user_objid := cst.web_user_objid ;
  o_contact_objid  := cst.contact_objid  ;

     --Retrieve number of credit cards associated for given ESN.
     BEGIN
       SELECT COUNT(cc.x_customer_cc_number)
       INTO   o_num_of_ccards
       FROM   table_x_credit_card cc,
              x_payment_source    ps
       WHERE  x_card_status              = 'ACTIVE'
       AND    cc.objid                   = ps.pymt_src2x_credit_card
       AND    ps.pymt_src2web_user       = o_web_user_objid;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       o_errstr := 'No Credit Card available for the given ESN';
       WHEN OTHERS THEN
       o_errstr := 'Get Credit Card Info: '||substr(sqlerrm,1,100);

     END;

   --Credit card available then returning credit card information for given ESN.
   IF o_num_of_ccards > 0 THEN
     BEGIN
         SELECT typ_creditcard_info_ivr(cc.x_customer_cc_number, cc.x_cc_type, ( cc.x_customer_cc_expmo
                                    || '-'
                                    || cc.x_customer_cc_expyr
                                    )
                                    ,
                                    NULL,
                                    NULL,
                                    cc.X_CUST_CC_NUM_ENC ,
                                    cc.X_CUST_CC_NUM_KEY ,
                                    cert.X_CC_ALGO       ,
                                    cert.X_KEY_ALGO      ,
                                    cert.x_cert          ,
                                    ps.objid             ,
                                    addr.zipcode
                                    )
         BULK COLLECT INTO o_list_of_ccards
         FROM  table_x_credit_card cc  ,
               x_cert              cert,
               x_payment_source    ps  ,
               table_address       addr
         WHERE cc.creditcard2cert           = cert.objid (+)
         AND   x_card_status                = 'ACTIVE'
         AND   cc.objid                     = ps.pymt_src2x_credit_card
         AND   cc.x_credit_card2address     = addr.objid
         AND   ps.pymt_src2web_user         = o_web_user_objid;
     EXCEPTION
      WHEN OTHERS THEN
        o_errnum := -1;
        o_errstr := 'Unable to fetch the credit card details';
                                RETURN;
     END;
   END IF;

  o_errnum := 0        ;
  o_errstr := 'SUCCESS';

EXCEPTION
   WHEN OTHERS THEN
    o_errnum := -1;
    o_errstr := 'Get_Cust_Profile_Data:  '||substr(sqlerrm,1,100);
    util_pkg.insert_error_tab (i_action       => 'Get Customer Profile Data',
                               i_key          => i_esn                      ,
                               i_program_name => 'get_cust_profile_data'    ,
                               i_error_text   => o_errstr
                               );

END get_cust_profile_data;
--
-- CR43524 changes starts..
-- Refactored existing IVR Code for IVR Universal Purchase Tracfone
PROCEDURE   get_esn_eligible  (i_esn                       IN  VARCHAR2,
                               i_min                       IN  VARCHAR2,
                               o_esn_eligible              OUT VARCHAR2,
                               o_valid_result              OUT VARCHAR2,
                               o_esn_issue                 OUT VARCHAR2,
                               o_errnum                    OUT VARCHAR2,
                               o_errstr                    OUT VARCHAR2)
IS
--
  l_esn                       VARCHAR2(30)         ;
 l_min                       VARCHAR2(30)         ;
  l_esn_status                varchar2(4)          ;
  l_sim                       varchar2(30)         ;
  l_msid_flag                 VARCHAR2(1)          ;
  l_cp_sbtran_type            VARCHAR2(2)          ;
  l_ota_pending               VARCHAR2(1)          ;
  l_carrier_pending           VARCHAR2(1)          ;
  l_nap_digital_pass          VARCHAR2(1)          ;
  p_msg                       VARCHAR2(200)        ;
  p_repl_part                 VARCHAR2(200)        ;
  p_repl_tech                 VARCHAR2(200)        ;
  p_sim_profile               VARCHAR2(200)        ;
  p_part_serial_no            VARCHAR2(200)        ;
  p_pref_parent               VARCHAR2(200)        ;
  p_pref_carrier_objid        VARCHAR2(200)        ;
  l_esn_brand                 varchar2(40)         ;
  l_phone_tech                varchar2(10);
  l_device_type               varchar2(30);
  l_activation_zip            varchar2(20);
  --
  sqlstmt varchar2(2000) :=
        q'"SELECT pi_esn.part_serial_no,
               pi_min.part_serial_no,
               pi_esn.x_part_inst_status,
               pi_esn.x_iccid
        FROM table_part_inst pi_min,
             table_part_inst pi_esn
        WHERE 1=1
        AND pi_min.x_domain              = 'LINES'
        AND pi_min.part_to_esn2part_inst = pi_esn.objid
        AND pi_esn.x_domain                 = 'PHONES'"';
  --
  FUNCTION simXchangecase_exists
  RETURN  BOOLEAN
  IS
    simc_case_cnt number := 0;
  BEGIN
    SELECT count(*)
    INTO  simc_case_cnt
    FROM  table_case      tbc,
          table_condition tcd
    WHERE tbc.x_esn                = l_esn
    AND   tbc.case_state2condition = tcd.objid
    AND   tbc.x_case_type          = 'Technology Exchange'
    AND   tbc.title                = 'SIM Card Exchange'
    AND   tcd.s_title             LIKE '%OPEN%'
    AND   tbc.creation_time       >= (SELECT MAX(x_transact_date)
                                      FROM    table_x_call_trans
                                      WHERE   x_action_type in (1,3,85)
                                      AND     x_service_id = l_esn);
    IF simc_case_cnt > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
 --
BEGIN --Main/MAIN/main Section
  --O_ESN_ELIGIBLE='1' --> ELIGIBLE
  --O_ESN_ELIGIBLE='2' --> REQUIRED_TROUBLE_SHOOT
  --O_ESN_ELIGIBLE='0' --> NOT_ELIGIBLE
  --
  --To validate ESN and MIN cannot be NULL.
  IF (i_esn||i_min IS NULL) THEN
    o_errnum := -1;
    o_errstr := 'Both ESN and MIN cannot be NULL';
    RETURN;
  ELSE
    IF i_min IS NOT NULL THEN
       sqlstmt := sqlstmt||' AND pi_min.part_serial_no = :i_min';
    ELSE
       sqlstmt := sqlstmt||' AND :i_min is null';
    END IF;
    IF i_esn IS NOT NULL THEN
       sqlstmt := sqlstmt||' AND pi_esn.part_serial_no =:i_esn';
    ELSE
       sqlstmt := sqlstmt||' AND :i_esn is null';
    END IF;
    --
    BEGIN
      EXECUTE IMMEDIATE sqlstmt
      INTO    l_esn, l_min, l_esn_status,l_sim
      USING   i_min, i_esn;
    EXCEPTION
      WHEN OTHERS THEN
       o_errnum := -1;
       o_errstr := 'Error occured while fetching ESN';
       RETURN;
    END;
  END IF;
  --
  l_esn_brand :=  bau_util_pkg.get_esn_brand(l_esn);
  --
  IF l_esn_status not in ('51','52','54' ) THEN
    --Transfer to Agent
    o_esn_eligible := '0';
    o_esn_issue    := 'ESN not in ACTIVE/USED/PASTDUE status';
    o_errnum       := 0;
    o_errstr       := 'SUCCESS';
    RETURN;
  END IF;
  --
  -- Business / Gina confirmed to Return NOT ELIGIBLE for other brands
  IF l_esn_brand NOT IN ('TRACFONE','NET10')
  THEN
    o_esn_eligible := '0';
    o_esn_issue    := 'ESN is Not Eligible';
    o_errnum       := 0;
    o_errstr       := 'SUCCESS';
    RETURN;
  END IF;
  -- Get Activation Zip code
  BEGIN
    SELECT x_zipcode
    INTO   l_activation_zip
    FROM   table_site_part sp
    WHERE  1 = 1
    AND    sp.x_service_id = l_esn
    AND    sp.install_date = ( SELECT MAX(install_date)
                              FROM   table_site_part
                              WHERE  x_service_id = sp.x_service_id
                            )
	AND ROWNUM = 1;	-- Fix to ensure single row incase more than one row exists with exactly same install_date (fixed during CR57251)
  EXCEPTION
    WHEN OTHERS THEN
      l_activation_zip  :=  NULL;
  END;
  -- Get phone technology
  BEGIN
    SELECT  pn.x_technology
    INTO    l_phone_tech
    FROM    table_part_inst pi,
            table_part_num pn,
            table_mod_level ml
    WHERE   pi.part_serial_no       =   l_esn
    AND     pi.x_domain             =   'PHONES'
    AND     pi.n_part_inst2part_mod =   ml.objid
    AND     ml.part_info2part_num   =   pn.objid;
  EXCEPTION
    WHEN OTHERS THEN
      l_phone_tech  :=  NULL;
  END;
  --
  IF l_esn_status IN ('52')
  THEN
    --
    --Retrieve Carrier Pending flag.
    BEGIN
      SELECT DISTINCT
             'Y', x_type
      INTO   l_carrier_pending,
             l_cp_sbtran_type
      FROM   table_site_part           sp,
             table_x_call_trans        ct,
             x_switchbased_transaction sbt
      WHERE  ct.call_trans2site_part = sp.objid
      AND    ct.x_action_type        IN (1,3,6)
      AND    sp.x_service_id       = l_esn
      AND    sp.part_status||''      = 'CarrierPending'
      AND    ct.objid                = sbt.x_sb_trans2x_call_trans
      AND    ct.x_transact_date      =   (SELECT MAX(x_transact_date)
                                         FROM   table_x_call_trans
                                         WHERE  x_action_type IN (1,3,6)
                                         AND    x_service_id  = l_esn);
    EXCEPTION
      WHEN OTHERS THEN
         l_carrier_pending := 'N';
    END;
    --
    --Retrieve OTA Pending flag.
    SELECT  decode(count(*),0, 'N','Y')
    INTO    l_ota_pending
    FROM    table_x_ota_transaction      ot
    WHERE   1=1
    AND     ot.x_esn   = l_esn
    AND     ot.x_status = 'OTA PENDING'
    AND     ot.x_action_type  IN (1,3,6);
    --
    --To check given ESN in pending MSID update status.
    BEGIN
      SELECT NVL(xp.x_ota_carrier,'N')
      INTO   l_msid_flag
      FROM   table_part_inst       pi_esn ,
             table_part_inst       pi_min ,
             table_x_parent        xp     ,
             table_x_carrier_group cg     ,
             table_x_carrier       c
      WHERE  1 = 1
      AND    pi_esn.part_serial_no        = l_esn
      AND    pi_esn.x_domain              = 'PHONES'
      AND    pi_esn.objid                 = pi_min.part_to_esn2part_inst
      AND    pi_min.x_domain              = 'LINES'
      AND    pi_min.x_part_inst_status    = '110' --ct.x_code_number
      AND    pi_min.part_inst2carrier_mkt = c.objid
      AND    cg.objid                     = c.carrier2carrier_group
      AND    cg.x_carrier_group2x_parent  = xp.objid;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      l_msid_flag := 'N';
      WHEN TOO_MANY_ROWS THEN
      l_msid_flag := 'Y';
      WHEN OTHERS THEN
      o_errstr := 'Get_Esn_Eligible:  '||substr(sqlerrm,1,100);
    END;
    --
    --Business validation to ESN eligibility flag for carrier pending.
    IF l_carrier_pending = 'Y' THEN
      IF l_cp_sbtran_type NOT in ('A', 'CR') THEN
        o_esn_eligible := '1';
      ELSE
        o_esn_eligible := '0';
        o_esn_issue    := 'ESN is Carrier Pending due to Activation or Credit';
        --
        IF NVL(l_phone_tech,'X') = 'CDMA'
        THEN
          IF l_esn_brand NOT IN ('TRACFONE','NET10')
          THEN
            o_esn_eligible := '2';
          ELSE
            o_esn_eligible := '0';
            o_esn_issue    := 'ESN is Carrier Pending due to TF/NT CDMA activation';
          END IF;
        ELSE
          o_esn_eligible := '2';
        END IF;
      END IF;
    ELSE
      o_esn_eligible := '1';
    END IF;
    --
    --Business validation to ESN eligibility flag for OTA pending.
    IF l_ota_pending = 'Y' THEN
       IF l_esn_brand IN ('TRACFONE','NET10') -- AND NVL(l_phone_tech,'X') <> 'CDMA' Business confirmed to include CDMA too
       THEN
         o_esn_eligible := '2';
         o_esn_issue    := 'ESN is OTA Pending Status';
       ELSE
         o_esn_eligible := '0';
         o_esn_issue    := 'ESN is OTA Pending due to Activation';
       END IF;
    ELSIF l_msid_flag = 'Y' THEN
       o_esn_eligible := '0';
       o_esn_issue    := 'ESN is OTA Pending due to MSID update';
   ELSE
       o_esn_eligible := '1';
    END IF;
    --
  ELSIF l_esn_status IN ('51','54') THEN  --Used/Pastdue
    --if simc case exists then not eligible
    IF l_sim IS NOT NULL and NVL(l_phone_tech,'X') = 'GSM' THEN
       IF simXchangecase_exists THEN
            o_esn_eligible := '0';
            o_esn_issue    := 'SIM Change case exist';
            RETURN;
       END IF;
    END IF;
    --
    IF NVL(l_phone_tech,'X') in ('GSM','CDMA')  THEN
      --Call nap_digital procedure for NAP validation.
     nap_digital(p_zip                => l_activation_zip ,
                  p_esn                => l_esn            ,
                  p_commit             => 'NO'            ,
                  p_sim                => l_sim            ,
                  p_source             => null             ,
                  p_repl_part          => p_repl_part      ,
                  p_repl_tech          => p_repl_tech      ,
                  p_sim_profile        => p_sim_profile    ,
                  p_part_serial_no     => p_part_serial_no,
                  p_msg                => p_msg            ,
                  p_pref_parent        => p_pref_parent    ,
                  p_pref_carrier_objid => p_pref_carrier_objid
                  );
       BEGIN
         SELECT DISTINCT DECODE(error_no,0,'Y', 1, 'N')
         INTO   l_nap_digital_pass
         FROM   table_nap_msg_mapping
         WHERE  UPPER(nap_msg)                  =  UPPER(p_msg)
            OR  Instr(UPPER(p_msg),UPPER(nap_msg))  >  0;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
             o_errnum := -1;
             o_errstr := 'NAP message not found';
             RETURN;
       END;
       --
       IF l_nap_digital_pass = 'Y' THEN
          o_esn_eligible := '1';
          o_valid_result := p_msg;
       ELSE
          o_esn_eligible := '0';
          o_esn_issue    := 'NAP return failure';
          o_valid_result := p_msg;
       END IF;
    END IF;
   --
  END IF;
  --
  o_errnum := 0;
  o_errstr := 'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
    o_errnum := -1;
    o_errstr := 'Get_Esn_Eligible:  '||substr(sqlerrm,1,100);
    util_pkg.insert_error_tab ( i_action       => 'ESN Eligiblitiy Check',
                                i_key          => l_esn,
                                i_program_name => 'get_esn_eligible',
                                i_error_text   => o_errstr );
END get_esn_eligible;
-- CR43524 changes ends
--
PROCEDURE get_retention_decision(i_esn                       IN     VARCHAR2,
                                 i_brand                     IN     VARCHAR2,
                                 i_source_system             IN     VARCHAR2,
                                 i_flow                      IN     VARCHAR2,
                                 i_src_part_num              IN     VARCHAR2,
                                 i_dest_part_num             IN     VARCHAR2,
                                 i_esn_enrolled              IN     VARCHAR2,
                                 i_language                  IN     VARCHAR2,
                                 o_action                    OUT    VARCHAR2,
                                 o_warn_script_id            OUT    VARCHAR2,
                                 o_warn_script_txt           OUT    VARCHAR2,
                                 o_spl_script_id             OUT    VARCHAR2,
                                 o_spl_script_txt            OUT    VARCHAR2,
                                 o_errnum                    OUT    VARCHAR2,
                                 o_errstr                    OUT    VARCHAR2
                                 )
IS

  --Local variables declaration
   cust                     sa.customer_type       ;
   cst                      sa.customer_type       ;
   l_esn_count              NUMBER                 ;
   l_esn_status             VARCHAR2(15)           ;
   l_part_class             VARCHAR2(50)           ;
   l_script_id              VARCHAR2(15)  := NULL  ;
   l_splscript_id           VARCHAR2(15)  := NULL  ;
   l_action                 VARCHAR2(50)  := NULL  ;
   l_complete_script_id     VARCHAR2(15)  := NULL  ;
   l_complete_splscript_id  VARCHAR2(15)  := NULL  ;
   l_script_type            VARCHAR2(20)  := NULL  ;
   l_splscript_type         VARCHAR2(20)  := NULL  ;
   l_underscore_count       NUMBER        := 0     ;
   l_objid                  VARCHAR2(2000)         ;
   l_description            VARCHAR2(2000):= NULL  ;
   l_script_text            VARCHAR2(2000)         ;
   l_publish_by             VARCHAR2(2000)         ;
   l_publish_date           DATE                   ;
   l_sm_link                VARCHAR2(2000)         ;
   l_underscore_splcount    NUMBER        := 0     ;
   l_splobjid               VARCHAR2(2000)         ;
   l_spldescription         VARCHAR2(2000):= NULL  ;
   l_splscript_text         VARCHAR2(2000)         ;
   l_splpublish_by          VARCHAR2(2000)         ;
   l_splpublish_date        DATE                   ;
   l_splsm_link             VARCHAR2(2000)         ;
   l_action_cnt             NUMBER        := 0     ;
   l_action_dist_cnt        NUMBER        := 0     ;
   l_action_flag_addnow     CHAR(1)       := 'N'   ;
   l_action_flag_reserve    CHAR(1)       := 'N'   ;
   l_src_serv_plan_grp      VARCHAR2(100)          ;
   l_dest_serv_plan_grp     VARCHAR2(100)          ;
   l_act2ret_flw            NUMBER                 ;
   l_act2ret_scn            NUMBER                 ;
   l_brand_objid            NUMBER                 ;
   l_vas_group_name         VARCHAR2(50)           ;

BEGIN --Main Section

      --To validate ESN cannot be NULL.
     IF i_esn IS NULL THEN
        o_errnum := -1;
        o_errstr := ('ESN cannot be NULL');
        RETURN;
     END IF;

     --To check ESN exists.
     BEGIN
         SELECT COUNT(*)
         INTO   l_esn_count
         FROM   table_part_inst pi_esn
         WHERE  pi_esn.part_serial_no =  i_esn
         AND    pi_esn.x_domain       = 'PHONES';

         --ESN Validation
         IF l_esn_count = 0 THEN
            o_errnum    := '922';
            o_errstr    := 'ESN cannot be found';
            RETURN;
         END IF;

     EXCEPTION
         WHEN OTHERS THEN
         o_errnum := -1;
         o_errstr := 'Get Retention Decision- ESN Validation: '||substr(sqlerrm,1,100);
     END;

      --Instantiate Customer Type
      cust := customer_type ( i_esn => i_esn );
      -- Calling the customer type retrieve member function
      cst := cust.retrieve;

      l_esn_status  :=  cst.esn_part_inst_status ;
      l_brand_objid :=  cst.bus_org_objid        ;
      l_part_class  :=  cst.part_class_name      ;

      --CR43524 fetch l_src_serv_plan_grp and l_dest_serv_plan_grp for brands other than Tracfone
    IF sa.bau_util_pkg.get_esn_brand(i_esn) != 'TRACFONE' THEN

       --To retrieve source service plan group for given source plan part number
       IF i_src_part_num IS NOT NULL THEN
       --
           BEGIN
              SELECT DISTINCT service_plan_group
              INTO   l_src_serv_plan_grp
              FROM   service_plan_feat_pivot_mv sp
              WHERE  sp.plan_purchase_part_number = i_src_part_num;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                o_errnum := -1;
                o_errstr := 'No service plan group exists for the given source part number';
                RETURN;
              WHEN OTHERS THEN
                o_errnum := -1;
                o_errstr := 'Error while retrieve source service plan group: '||substr(sqlerrm,1,100);
                RETURN;
           END;
       ELSE
       --
          BEGIN
            SELECT spmv.service_plan_group
            INTO   l_src_serv_plan_grp
            FROM   x_service_plan_site_part   spsp,
                   x_service_plan             sp  ,
                   table_site_part            tsp ,
                   service_plan_feat_pivot_mv spmv
            WHERE  tsp.x_service_id   = i_esn
            AND    tsp.objid          = DECODE((SELECT COUNT(1)
                                                FROM   table_site_part sp_cnt
                                                WHERE  sp_cnt.x_service_id = i_esn
                                                AND    sp_cnt.part_status  = 'Active'
                                                ),
                                                1,
                                               (SELECT sp1.objid
                                                FROM   table_site_part sp1
                                                WHERE  sp1.x_service_id = i_esn
                                                AND    sp1.part_status  = 'Active'
                                               ),
                                               (SELECT MAX(sp_max.objid)
                                                FROM   table_site_part sp_max
                                                WHERE  sp_max.x_service_id = i_esn
                                                AND    sp_max.part_status  <> 'Obsolete'
                                                )
                                               )
            AND sp.objid                = spmv.service_plan_objid
            AND spmv.service_plan_objid = spsp.x_service_plan_id
            AND spsp.table_site_part_id = tsp.objid;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   o_errnum := -1;
                   o_errstr := 'No service plan group exists for the given source part number';
                   RETURN;
              WHEN OTHERS THEN
                   o_errnum := -1;
                   o_errstr := 'Error while retrieve source service plan group: '||substr(sqlerrm,1,100);
                   RETURN;
           END;
       END IF;

      --Validation to check $10 ILD and assign $10 ILD service plan group.
           IF i_dest_part_num LIKE '%10ILD%' THEN
               BEGIN
                 SELECT vpv.vas_group_name
                 INTO   l_vas_group_name
                 FROM   vas_programs_view vpv
                 WHERE  vpv.vas_app_card = i_dest_part_num
                 AND    vpv.vas_bus_org  = cst.bus_org_id;
                 --
                 l_dest_serv_plan_grp := l_vas_group_name;
               EXCEPTION
                  WHEN OTHERS THEN
                  o_errnum := -1;
                  o_errstr := 'Error while retrieve target service plan group for $10ILD part number: '||substr(sqlerrm,1,100);
                  RETURN;
               END;
           ELSE
              --To retrieve target service plan group for given target plan part number
              BEGIN
                SELECT DISTINCT service_plan_group
                INTO   l_dest_serv_plan_grp
                FROM   service_plan_feat_pivot_mv sp
                WHERE  sp.plan_purchase_part_number = i_dest_part_num;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  o_errnum := -1;
                  o_errstr := 'No service plan group exists for the given target part number';
                  RETURN;
                WHEN OTHERS THEN
                  o_errnum := -1;
                  o_errstr := 'Error while retrieve target service plan group: '||substr(sqlerrm,1,100);
                  RETURN;
              END;
                l_dest_serv_plan_grp := l_dest_serv_plan_grp;
           END IF;
    ELSE -- TRACFONE
       l_src_serv_plan_grp  := 'TF_DEFAULT';
       l_dest_serv_plan_grp := 'TF_DEFAULT';
    END IF;

    --Get Retention Flow Scenario
    BEGIN
        SELECT DISTINCT
               mtm.x_act2ret_flw,
               mtm.x_act2ret_scn
               INTO
               l_act2ret_flw,
               l_act2ret_scn
        FROM  x_retention_scenarios      rs,
              x_retention_flows          rf,
              x_mtm_ret_flow_scn_action mtm
        WHERE rf.x_flow_name             = i_flow
        AND   rf.objid                   = mtm.x_act2ret_flw
        AND   mtm.x_act2ret_scn          = rs.objid
        AND   rs.x_src_service_plan_grp  = l_src_serv_plan_grp
        AND   rs.x_dest_service_plan_grp = l_dest_serv_plan_grp
        AND   rs.x_ret_scn2bus_org       = l_brand_objid;
    EXCEPTION
          WHEN NO_DATA_FOUND THEN
            o_errnum := -1;
            o_errstr := 'No Retention flow or Scenario Exists';
            RETURN;
          WHEN OTHERS THEN
            o_errnum := -1;
            o_errstr := 'Get Retention Flow Scenario: '||substr(sqlerrm,1,100);
            RETURN;
    END;

    BEGIN
      SELECT COUNT( f.x_action)
      INTO   l_action_cnt
      FROM   x_mtm_ret_flow_scn_action f
      WHERE  x_act2ret_flw = l_act2ret_flw
      AND    x_act2ret_scn = l_act2ret_scn;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
          o_errnum := -1;
          o_errstr := 'No action exists1';
          RETURN;
        WHEN OTHERS THEN
          o_errnum := -1;
          o_errstr := 'Get Retention Action Count: '||substr(sqlerrm,1,100);
          RETURN;
      END;

    BEGIN
        SELECT COUNT( DISTINCT f.x_action)
        INTO   l_action_dist_cnt
        FROM   x_mtm_ret_flow_scn_action f
        WHERE  x_act2ret_flw = l_act2ret_flw
        AND    x_act2ret_scn = l_act2ret_scn;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
            o_errnum := -1;
            o_errstr := 'No action exists2';
            RETURN;
      WHEN OTHERS THEN
            o_errnum := -1;
            o_errstr := 'Get Distinct Action Count: '||substr(sqlerrm,1,100);
            RETURN;
      END;

   IF l_action_dist_cnt <> l_action_cnt THEN
        o_errnum := -1;
        o_errstr := 'Get Retention Decision: Duplicate action found for the same configuration ';
        RETURN;
   END IF;

  IF l_action_dist_cnt > 1 THEN
    BEGIN
      BEGIN
          SELECT 'Y'
          INTO  l_action_flag_addnow
          FROM  x_mtm_ret_flow_scn_action f
          WHERE x_act2ret_flw = l_act2ret_flw
          AND   x_act2ret_scn = l_act2ret_scn
          AND   x_action      = 'ADD_NOW';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          o_errnum := -1;
          o_errstr := 'Valid action not found - ADD_NOW';
        RETURN;
        WHEN OTHERS THEN
          o_errnum := -1;
          o_errstr := 'Get Retention Decision - ADD_NOW Action: '||substr(sqlerrm,1,100);
        RETURN;
      END;

      BEGIN
        SELECT 'Y'
          INTO l_action_flag_reserve
          FROM x_mtm_ret_flow_scn_action f
         WHERE x_act2ret_flw = l_act2ret_flw
           AND x_act2ret_scn = l_act2ret_scn
           AND x_action = 'ADD_TO_RESERVE';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          o_errnum := -1;
          o_errstr := 'Valid action not found - ADD_RESERVE';
          RETURN;
        WHEN OTHERS THEN
          o_errnum := -1;
          o_errstr := 'Get Retention Decision - ADD_TO_RESERVE Action: '||substr(sqlerrm,1,100);
        RETURN;
      END;

    IF l_action_flag_addnow = 'Y' AND l_action_flag_reserve = 'Y' THEN

       l_action := 'BOTH';

      BEGIN
          SELECT 'BOTH' AS action,
                 decode (NVL(i_esn_enrolled,'N'), 'Y' , w_enr_script_id,w_not_enr_script_id),
                 f.spl_script_id
          INTO   l_action,
                 l_complete_script_id,
                 l_complete_splscript_id
          FROM   x_mtm_ret_flow_scn_action f
          WHERE  x_act2ret_flw = l_act2ret_flw
          AND    x_act2ret_scn = l_act2ret_scn
          AND    ROWNUM = 1;
      EXCEPTION
        WHEN OTHERS THEN
        o_errnum := -1;
        o_errstr := 'Error in fetching the Flow Scenario for the given Source/Target plans '||substr(sqlerrm,1,100);
        RETURN;
      END;
    ELSE
        o_errnum := -1;
        o_errstr := 'Invalid action found for the given Source/Target plan configuration';
        RETURN;
    END IF;
   END;
  ELSE
    BEGIN
      SELECT f.x_action,
             decode (NVL(i_esn_enrolled,'N'), 'Y' , w_enr_script_id,w_not_enr_script_id) ,f.spl_script_id
        INTO l_action,
             l_complete_script_id,
             l_complete_splscript_id
        FROM x_mtm_ret_flow_scn_action f
       WHERE x_act2ret_flw = l_act2ret_flw
         AND x_act2ret_scn = l_act2ret_scn;
    EXCEPTION
      WHEN NO_DATA_FOUND
    THEN
      o_errnum := -1;
      o_errstr := 'Error in fetching the Flow Scenario for the given Source/Target plans';
      RETURN;
    END;
  END IF;

    --Assignment to out variable for action value.
    o_action := l_action;

    IF l_esn_status = '52' THEN
      --
      IF l_complete_script_id IS NOT NULL THEN

         SELECT INSTR(l_complete_script_id,'_',1)
         INTO   l_underscore_count
         FROM   DUAL;

         SELECT  SUBSTR(l_complete_script_id,1,(l_underscore_count-1)),
              SUBSTR(l_complete_script_id,(l_underscore_count+1))
         INTO  l_script_type,
              l_script_id
         FROM DUAL;

         sa.scripts_pkg.get_script_prc(ip_sourcesystem => i_source_system,
                                       ip_brand_name   => i_brand        ,
                                       ip_script_type  => l_script_type  ,
                                       ip_script_id    => l_script_id    ,
                                       ip_language     => i_language     ,
                                       ip_carrier_id   => cst.carrier_objid,
                                       ip_part_class   => l_part_class   ,
                                       op_objid        => l_objid        ,
                                       op_description  => l_description  ,
                                       op_script_text  => l_script_text  ,
                                       op_publish_by   => l_publish_by   ,
                                       op_publish_date => l_publish_date ,
                                       op_sm_link      => l_sm_link
                                       );

       o_warn_script_id           := l_complete_script_id;
       o_warn_script_txt          := l_script_text;

      END IF;
    --
    END IF;

     --To retrieve Special Script Text
    IF l_complete_splscript_id IS NOT NULL THEN

       SELECT  INSTR(l_complete_splscript_id,'_',1)
       INTO    l_underscore_splcount
       FROM    dual;

       SELECT  SUBSTR(l_complete_splscript_id,1,(l_underscore_splcount-1)),
               SUBSTR(l_complete_splscript_id,(l_underscore_splcount+1))
       INTO    l_splscript_type,
               l_splscript_id
       FROM    dual;

       sa.scripts_pkg.get_script_prc(ip_sourcesystem   => i_source_system,
                                     ip_brand_name     => i_brand,
                                     ip_script_type    => l_splscript_type,
                                     ip_script_id      => l_splscript_id,
                                     ip_language       => i_language,
                                     ip_carrier_id     => cst.carrier_objid,
                                     ip_part_class     => l_part_class,
                                     op_objid          => l_splobjid,
                                     op_description    => l_spldescription,
                                     op_script_text    => l_splscript_text,
                                     op_publish_by     => l_splpublish_by,
                                     op_publish_date   => l_splpublish_date,
                                     op_sm_link        => l_splsm_link
                                     );

           o_spl_script_id            := l_complete_splscript_id;
           o_spl_script_txt           := l_splscript_text;
    END IF;

  o_errnum := 0;
  o_errstr := 'SUCCESS';

EXCEPTION
   WHEN OTHERS THEN
    o_errnum := -1;
    o_errstr := 'Get_Retention_Decision:  '||substr(sqlerrm,1,100);
    util_pkg.insert_error_tab ( i_action       => 'Retention Decision',
                                i_key          => i_esn,
                                i_program_name => 'get_retention_decision',
                                i_error_text   => o_errstr );
END get_retention_decision;
--
FUNCTION simulate_posa_phone_swp(
      ip_part_serial_no   IN VARCHAR2,
      ip_domain           IN VARCHAR2,
      ip_action           IN VARCHAR2,
      ip_store_detail     IN VARCHAR2,
      ip_store_id         IN VARCHAR2,
      ip_trans_id         IN VARCHAR2,
      ip_sourcesystem     IN VARCHAR2,
      ip_trans_date       IN DATE,
      ip_prog_caller      IN VARCHAR2
      )
RETURN BOOLEAN
IS
--
  CURSOR table_part_num_cur(
    ip_part_serial_no VARCHAR2
  )
  RETURN table_part_num%ROWTYPE
  IS
  SELECT pn.*
  FROM table_part_num pn, sa.gtt_part_inst pi, table_mod_level ml
  WHERE pi.n_part_inst2part_mod = ml.objid
  AND ml.part_info2part_num = pn.objid
  AND pi.part_serial_no = ip_part_serial_no;
--
  CURSOR table_site_cur(
    ip_part_serial_no VARCHAR2,
    ip_domain VARCHAR2
  )
  RETURN table_site%ROWTYPE
  IS
  SELECT ts.*
  FROM table_site ts, table_inv_bin ib, sa.gtt_part_inst pi
  WHERE pi.part_serial_no = ip_part_serial_no
  AND pi.x_domain = ip_domain
  AND pi.part_inst2inv_bin = ib.objid
  AND ib.bin_name = ts.site_id;
--
  CURSOR table_part_inst_cur(
    ip_part_serial_no VARCHAR2
  )
  RETURN sa.gtt_part_inst%ROWTYPE
  IS
  SELECT
      OBJID,PART_GOOD_QTY,PART_BAD_QTY,PART_SERIAL_NO,PART_MOD,PART_BIN,LAST_PI_DATE,
      PI_TAG_NO,LAST_CYCLE_CT,NEXT_CYCLE_CT,LAST_MOD_TIME,LAST_TRANS_TIME,TRANSACTION_ID,DATE_IN_SERV,
      WARR_END_DATE,REPAIR_DATE,PART_STATUS,PICK_REQUEST,GOOD_RES_QTY,BAD_RES_QTY,DEV,X_INSERT_DATE,
      X_SEQUENCE,X_CREATION_DATE,X_PO_NUM,X_RED_CODE,X_DOMAIN,X_DEACTIVATION_FLAG,X_REACTIVATION_FLAG,X_COOL_END_DATE,
      DECODE(X_PART_INST_STATUS,'400','41','263','41',X_PART_INST_STATUS),
      X_NPA,X_NXX,X_EXT,X_ORDER_NUMBER,PART_INST2INV_BIN,N_PART_INST2PART_MOD,
      FULFILL2DEMAND_DTL,PART_INST2X_PERS,PART_INST2X_NEW_PERS,PART_INST2CARRIER_MKT,CREATED_BY2USER,
      STATUS2X_CODE_TABLE,PART_TO_ESN2PART_INST,X_PART_INST2SITE_PART,X_LD_PROCESSED,DTL2PART_INST,ECO_NEW2PART_INST,
      HDR_IND,X_MSID,X_PART_INST2CONTACT,X_ICCID,X_CLEAR_TANK,X_PORT_IN,X_HEX_SERIAL_NO ,x_parent_part_serial_no,X_WF_MAC_ID,CPO_MANUFACTURER
  FROM sa.gtt_part_inst
  WHERE part_serial_no = ip_part_serial_no;
--
  v_function_name CONSTANT VARCHAR2 (200) := 'PHONE_PKG' ||
  '.simulate_posa_swp_tab_fun()';
  table_part_rec        table_part_num%ROWTYPE;
  table_site_rec        table_site%ROWTYPE;
  table_part_inst_rec   sa.gtt_part_inst%ROWTYPE;
  -- CR22277 ACME Launch
  V_ESN_LENGTH NUMBER ;
  clarify_esn VARCHAR2(30) ;
BEGIN
  clarify_esn := ip_part_serial_no ;
  v_esn_length := length(trim(clarify_esn)) ;
  if v_esn_length = 14
  then
   clarify_esn := sa.hex2dec(ip_part_serial_no) ;
  end if ;
  -- OPEN table_part_num_cur (ip_part_serial_no); -- CR22277 ACME Launch
  OPEN table_part_num_cur (clarify_esn);
  FETCH table_part_num_cur
  INTO table_part_rec;
  CLOSE table_part_num_cur;
  -- OPEN table_site_cur (ip_part_serial_no, ip_domain); -- CR22277 ACME Launch
  OPEN table_site_cur (clarify_esn, ip_domain);
  FETCH table_site_cur
  INTO table_site_rec;
  CLOSE table_site_cur;
  --OPEN table_part_inst_cur (ip_part_serial_no); -- CR22277 ACME Launch
  OPEN table_part_inst_cur (clarify_esn);
  FETCH table_part_inst_cur
  INTO table_part_inst_rec;
  CLOSE table_part_inst_cur;
  --
  IF ip_domain = 'PHONES'
  THEN
     INSERT
     INTO sa.gtt_posa_phone(
        tf_part_num_parent,
        tf_serial_num,
        toss_att_customer,
        toss_att_location,
        toss_posa_code,
        toss_posa_date,
        tf_extract_flag,
        tf_extract_date,
        toss_site_id,
        toss_posa_action,
        --toss_att_id,
        objid,
        remote_trans_id,
        sourcesystem,
        toss_att_trans_date
     )VALUES(
        table_part_rec.part_number,
        ip_part_serial_no,
        ip_store_id,
        ip_store_detail,
        table_part_inst_rec.x_part_inst_status,
        SYSDATE,
        'N',
        NULL,
        table_site_rec.site_id,
        ip_action,
        seq_x_posa_phone.nextval,
        ip_trans_id,
        ip_sourcesystem,
        ip_trans_date
     );
  END IF;
  IF SQL%ROWCOUNT = 1
  THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS
  THEN
    RETURN FALSE;
END simulate_posa_phone_swp;
--
PROCEDURE simulate_phone_active(
      ip_esn_num        IN VARCHAR2,
      ip_upc_code       IN VARCHAR2,
      ip_date           IN VARCHAR2,
      ip_time           IN VARCHAR2,
      ip_trans_id       IN VARCHAR2,
      ip_trans_type     IN VARCHAR2,
      ip_merchant_id    IN VARCHAR2,
      ip_store_detail   IN VARCHAR2,
      op_error_code     OUT VARCHAR2,
      op_error_msg      OUT VARCHAR2,
      ip_sourcesystem   IN VARCHAR2 := 'POSA'
   )
IS
  --
  do_common_inserts         BOOLEAN := FALSE;
  v_orig_site_id            table_site.site_id%TYPE := NULL;
  v_current_site_id         table_site.site_id%TYPE := NULL;
  is_a_walmart              BOOLEAN := FALSE;
  v_procedure_name          CONSTANT VARCHAR2 (200) := 'PHONE_PKG' ||
  '.simulate_phone_active()';
  v_esn_status              VARCHAR2 (10);
  V_LOG_RESULT              NUMBER;
  -- CR22277 ACME Launch
  V_ESN_LENGTH              NUMBER ;
  clarify_esn               VARCHAR2(30) ;
  l_code_table_objid        table_x_code_table.objid%TYPE;
BEGIN
  clarify_esn   := ip_esn_num ;
  v_esn_length  := length(trim(clarify_esn)) ;
  if v_esn_length = 14
  then
    clarify_esn := sa.hex2dec(ip_esn_num) ;
  end if ;
  --
  DBMS_OUTPUT.put_line (' one ');
  --
  BEGIN
    SELECT  x_part_inst_status
    INTO    v_esn_status
    FROM    sa.gtt_part_inst
    WHERE   part_serial_no = clarify_esn;
  EXCEPTION
    WHEN OTHERS THEN
      op_error_code :=  '100';
      op_error_msg  :=  'Failed while retrieving the status of ESN';
      RETURN;
  END;
  --
  DBMS_OUTPUT.put_line (' two ');
  BEGIN
    SELECT  xc.objid
    INTO    l_code_table_objid
    FROM    table_x_code_table xc
    WHERE   x_code_number = '50';
  EXCEPTION
    WHEN OTHERS THEN
      op_error_code :=  '110';
      op_error_msg  :=  'Failed while retrieving the code_table_objid';
      RETURN;
  END;
  --
  IF v_esn_status = '59'
  THEN
    UPDATE  sa.gtt_part_inst
    SET     x_part_inst_status  = '50',
            status2x_code_table = l_code_table_objid
    WHERE   part_serial_no  = clarify_esn
    AND     x_domain        = 'PHONES';
    --
    IF simulate_posa_phone_swp ( ip_part_serial_no      =>  ip_esn_num,
                                ip_domain              =>  'PHONES',
                                 ip_action              =>  'SWIPE',
                                 ip_store_detail        =>  ip_store_detail,
                                 ip_store_id            =>  ip_merchant_id,
                                 ip_trans_id            =>  ip_trans_id,
                                 ip_sourcesystem        =>  ip_sourcesystem,
                                 ip_trans_date          =>  TO_DATE (ip_date || ip_time, 'MMDDYYYYHH24MISS'),
                                 ip_prog_caller         =>  v_procedure_name)
    THEN
      op_error_code :=  0;
      op_error_msg  :=  'SUCCESS';
      RETURN;
    ELSE
      op_error_code :=  '120';
      op_error_msg  :=  'Failed while simulating posa swipe';
      RETURN;
    END IF;
  ELSE
    op_error_code :=  '130';
    op_error_msg  :=  'Invalid Phone status';
    RETURN;
  END IF;
  --
EXCEPTION
WHEN OTHERS THEN
   op_error_code    :=  '150';
   op_error_msg     :=  'Failed in when others of simulate_phone_active' || SQLERRM;
END simulate_phone_active;
--
PROCEDURE validate_pre_posa_phone(
  p_esn IN VARCHAR2 ,
  p_source_system IN VARCHAR2 , -- CHANNEL (CHANNEL TABLE)
  p_brand_name IN VARCHAR2 , --BRAND NAME (BUS ORG TABLE)
  p_part_inst_objid OUT VARCHAR2 ,
  p_code_number OUT VARCHAR2 ,
  p_code_name OUT VARCHAR2 ,
  p_redemp_reqd_flg OUT NUMBER ,
  p_warr_end_date OUT VARCHAR2 ,
  p_phone_model OUT VARCHAR2 ,
  p_phone_technology OUT VARCHAR2 ,
  p_phone_description OUT VARCHAR2 ,
  p_esn_brand OUT VARCHAR2 ,
  p_zipcode OUT VARCHAR2 ,
  p_pending_red_status OUT VARCHAR2 ,
  p_click_status OUT VARCHAR2 ,
  p_promo_units OUT NUMBER ,
  p_promo_access_days OUT NUMBER ,
  p_num_of_cards OUT NUMBER ,
  p_pers_status OUT VARCHAR2 ,
  p_contact_id OUT VARCHAR2 ,
  p_contact_phone OUT VARCHAR2 ,
  p_errnum OUT VARCHAR2 ,
  p_errstr OUT VARCHAR2 ,
  p_sms_flag OUT NUMBER ,
  p_part_class OUT VARCHAR2 ,
  p_parent_id OUT VARCHAR2 ,
  p_extra_info OUT VARCHAR2 ,
  p_int_dll OUT NUMBER ,
  p_contact_email OUT VARCHAR2 ,
  p_min OUT VARCHAR2 ,
  p_manufacturer OUT VARCHAR2 ,
  p_seq OUT NUMBER ,
  p_iccid OUT VARCHAR2 ,
  p_iccid_flag OUT VARCHAR2 ,
  p_last_call_trans OUT VARCHAR2 ,
  p_safelink_esn OUT VARCHAR2,
  p_preactv_benefits OUT VARCHAR2)
AS
CURSOR carrier_pending_cur(p_esn IN VARCHAR2)
IS
   SELECT  pi.part_serial_no ,
           pi.x_part_inst_status ,
           pi.x_part_inst2contact ,
           sp.part_status ,
           sp.x_min ,
           sp.x_zipcode ,
           ct.objid ct_objid
   FROM  sa.gtt_part_inst pi ,
         table_site_part sp ,
         table_x_call_trans ct
   WHERE ct.call_trans2site_part = sp.objid
   AND ct.x_action_type = '1'
   AND pi.part_serial_no = sp.x_service_id
   AND pi.x_domain = 'PHONES'
   AND pi.part_serial_no = p_esn
   AND pi.x_part_inst_status IN ('50' ,'150')
   AND sp.part_status
   || '' = 'CarrierPending'
   AND ct.x_transact_date IN
   (SELECT MAX(x_transact_date)
   FROM table_x_call_trans
   WHERE x_action_type = '1'
   AND x_service_id = p_esn
   );
carrier_pending_rec carrier_pending_cur%ROWTYPE;
CURSOR carrier_pending_react_cur(p_esn IN VARCHAR2)
IS
   SELECT  pi.part_serial_no ,
           pi.x_part_inst_status ,
           pi.x_part_inst2contact ,
           sp.part_status ,
           sp.x_min ,
           sp.x_zipcode ,
           ct.objid ct_objid
   FROM  sa.gtt_part_inst pi ,
         table_site_part sp ,
         table_x_call_trans ct
   WHERE ct.call_trans2site_part = sp.objid
   AND ct.x_action_type = '3'
   AND pi.part_serial_no = sp.x_service_id
   AND pi.x_domain = 'PHONES'
   AND pi.part_serial_no = p_esn
   AND pi.x_part_inst_status IN ('51' ,'54')
   AND sp.part_status
   || '' = 'CarrierPending'
   AND ct.x_transact_date IN
   (SELECT MAX(x_transact_date)
   FROM table_x_call_trans
   WHERE x_action_type = '3'
   AND x_service_id = p_esn
   );
carrier_pending_react_rec carrier_pending_react_cur%ROWTYPE;
CURSOR activation_pending_cur(p_esn IN VARCHAR2)
IS
SELECT  pi.part_serial_no ,
         pi.x_part_inst_status ,
         pi.x_part_inst2contact ,
         sp.part_status ,
         sp.x_min ,
         sp.x_zipcode ,
         ct.objid ct_objid
FROM  sa.gtt_part_inst pi ,
       table_site_part sp ,
       table_x_call_trans ct
WHERE ct.call_trans2site_part = sp.objid
AND ct.x_action_type = '1'
AND pi.part_serial_no = sp.x_service_id
AND pi.x_domain = 'PHONES'
AND pi.part_serial_no = p_esn
AND pi.x_part_inst_status IN ('50' ,'150')
AND sp.part_status = 'Active'
AND ct.x_transact_date IN
(SELECT MAX(x_transact_date)
FROM table_x_call_trans
WHERE x_action_type = '1'
AND x_service_id = p_esn
);
activation_pending_rec activation_pending_cur%ROWTYPE;
--
CURSOR part_inst_temp_cur(
      p_esn IN VARCHAR2
   )
   IS
   SELECT pi.objid,
      pi.warr_end_date,
      pi.x_port_in,
      ct.x_code_number,
      ct.x_code_name,
      pi.pi_tag_no,
      ct.x_value,  --CR2805
      pi.hdr_ind,  --CR3740
      pi.x_sequence,  --CR4245
      pi.x_iccid,
      (
      SELECT x_sim_req
      FROM TABLE_X_OTA_PARAMS
      WHERE x_source_system = p_source_system) x_iccid_flag--CR6731
   FROM TABLE_PART_INST pi, TABLE_X_CODE_TABLE ct
   WHERE pi.part_serial_no = p_esn
   AND pi.x_domain = 'PHONES'
   AND pi.status2x_code_table = ct.objid;
   pi_rec part_inst_temp_cur%ROWTYPE;
--
CURSOR part_inst_cur(p_esn IN VARCHAR2)
IS
SELECT  pi.objid ,
         pi.warr_end_date ,
         pi.x_port_in ,
         ct.x_code_number ,
         ct.x_code_name ,
         pi.pi_tag_no ,
         ct.x_value ,
         pi.hdr_ind ,
         pi.x_sequence ,
         pi.x_iccid ,
         pi.x_hex_serial_no --ACMI ACME
         ,
         (SELECT x_sim_req
         FROM table_x_ota_params_2 ,
         table_bus_org
         WHERE x_source_system = p_source_system
         AND ota_param2bus_org = table_bus_org.objid
         AND org_id = p_brand_name
         ) x_iccid_flag
FROM sa.gtt_part_inst pi ,
      table_x_code_table ct
WHERE pi.part_serial_no = p_esn
AND pi.x_domain = 'PHONES'
AND pi.status2x_code_table = ct.objid;
part_inst_rec part_inst_cur%ROWTYPE;
CURSOR get_phone_info_cur(p_esn IN VARCHAR2)
IS
SELECT  pn.part_number ,
         pn.x_technology ,
         pn.description ,
         bo.org_id ,
         bo.loc_type ,
         pn.x_dll ,
         pi.x_part_inst_status ,
         NVL(pn.prog_type ,0) prog_type ,
         pn.x_manufacturer ,
         pn.x_data_capable ,
         sa.get_param_by_name_fun(pc.name ,'NON_PPE') non_ppe_flag -- CR17003 Net 10 Sprint
FROM  sa.gtt_part_inst pi ,
       table_mod_level ml ,
       table_part_num pn ,
       table_bus_org bo ,
       table_part_class pc -- CR17003 Net 10 Sprint
WHERE pi.n_part_inst2part_mod = ml.objid
AND ml.part_info2part_num = pn.objid
AND pi.part_serial_no = p_esn
AND pi.x_domain = 'PHONES'
AND bo.objid = pn.part_num2bus_org
AND pc.objid = pn.part_num2part_class;
get_phone_info_rec get_phone_info_cur%ROWTYPE;
CURSOR pers_lac_cur ( p_esn IN VARCHAR2 ,p_tech IN VARCHAR2 )
IS
SELECT sid.*
FROM  table_x_sids sid ,
       table_x_lac l ,
       table_x_carr_personality cp ,
       sa.gtt_part_inst pi
WHERE sid.x_sid_type = p_tech
AND sid.sids2personality = cp.objid
AND l.lac2personality = cp.objid
AND l.x_local_area_code = TO_NUMBER(DECODE(INSTR(pi.x_npa ,'T') ,0 ,pi.x_npa ,SUBSTR(pi.x_npa ,2)))
AND cp.objid = pi.part_inst2x_pers
AND pi.part_serial_no = p_esn
ORDER BY sid.x_index ASC;
pers_lac_rec pers_lac_cur%ROWTYPE;
CURSOR product_part_cur(p_esn IN VARCHAR2)
IS
SELECT *
FROM table_site_part
WHERE x_service_id = p_esn
AND part_status = 'Active';
product_part_rec product_part_cur%ROWTYPE;
/*CR33864 ATT Carrier switch cursor declaration start */
CURSOR product_part_cur_sw(
p_esn IN VARCHAR2
)
IS
SELECT *
FROM TABLE_SITE_PART
WHERE x_service_id = p_esn;
/*CR33864 ATT Carrier switch cursor declaration end */
CURSOR promo_cur(p_sp_objid IN NUMBER)
IS
SELECT  p.x_promo_code ,
         p.x_promo_type ,
         p.x_units ,
         p.x_access_days ,
         p.x_english_short_text
FROM  table_site_part sp ,
       table_x_promotion p ,
       table_x_pending_redemption pr
WHERE pr.x_pend_red2site_part = sp.objid
AND pr.pend_red2x_promotion = p.objid
AND sp.objid = p_sp_objid;
promo_rec promo_cur%ROWTYPE;
CURSOR new_plan_cur(p_sp_objid IN NUMBER)
IS
SELECT cp.objid
FROM table_site_part sp ,
      table_x_click_plan cp
WHERE sp.site_part2x_new_plan = cp.objid
AND sp.objid = p_sp_objid;
new_plan_rec new_plan_cur%ROWTYPE;
CURSOR contact_pi_cur(p_esn IN VARCHAR2)
IS
SELECT c.*
FROM sa.gtt_part_inst pi ,
      table_contact c
WHERE pi.x_part_inst2contact = c.objid
AND pi.part_serial_no = p_esn
AND x_domain = 'PHONES';
contact_pi_rec contact_pi_cur%ROWTYPE;
CURSOR contact_sp_cur(p_sp_objid IN NUMBER)
IS
SELECT c.*
FROM  table_contact c ,
       table_contact_role cr ,
       table_site_part sp ,
       table_site s
WHERE cr.contact_role2contact = c.objid
AND cr.contact_role2site = s.objid
AND sp.site_part2site = s.objid
AND sp.objid = p_sp_objid;
contact_sp_rec contact_sp_cur%ROWTYPE;
CURSOR cc_cur(p_contact_objid IN NUMBER)
IS
SELECT COUNT(*) count_cc
FROM table_x_credit_card cc ,
      mtm_contact46_x_credit_card3 mtm
WHERE mtm.mtm_contact2x_credit_card = p_contact_objid
AND mtm.mtm_credit_card2contact = cc.objid
AND cc.x_card_status = 'ACTIVE';
cc_rec cc_cur%ROWTYPE;
CURSOR pi_min_cur(p_min IN VARCHAR2)
IS
SELECT *
FROM table_part_inst
WHERE part_serial_no = p_min
AND x_domain = 'LINES';
pi_min_rec pi_min_cur%ROWTYPE;
CURSOR new_pers_cur(pi_min_objid IN NUMBER)
IS
SELECT cp.*
FROM table_part_inst pi ,
      table_x_carr_personality cp
WHERE pi.part_inst2x_new_pers = cp.objid
AND pi.objid = pi_min_objid;
new_pers_rec new_pers_cur%ROWTYPE;
CURSOR old_pers_cur(pi_min_objid IN NUMBER)
IS
SELECT cp.*
FROM table_part_inst pi ,
      table_x_carr_personality cp
WHERE pi.part_inst2x_pers = cp.objid
AND pi.objid = pi_min_objid;
old_pers_rec old_pers_cur%ROWTYPE;
CURSOR getpers2sid_cur ( p_pers_objid IN NUMBER ,p_tech IN VARCHAR2 )
IS
SELECT sid.*
FROM table_x_sids sid ,
      table_x_carr_personality cp
WHERE sid.sids2personality = cp.objid
AND cp.objid = p_pers_objid
AND sid.x_sid_type = p_tech
ORDER BY x_index ASC;
getpers2sid_rec getpers2sid_cur%ROWTYPE;
CURSOR get_oldsitepart_cur(p_pi_objid IN VARCHAR2)
IS
SELECT sp.*
FROM table_site_part sp ,
      sa.gtt_part_inst pi
WHERE sp.part_status <> 'Obsolete'
AND pi.x_part_inst2site_part = sp.objid
AND pi.objid = p_pi_objid
ORDER BY service_end_dt DESC;
get_oldsitepart_rec get_oldsitepart_cur%ROWTYPE;
CURSOR site_cur(p_esn IN VARCHAR2)
IS
SELECT s.*
FROM  table_site s ,
       table_inv_locatn il ,
       table_inv_bin ib ,
       sa.gtt_part_inst pi
WHERE il.inv_locatn2site = s.objid
AND ib.inv_bin2inv_locatn = il.objid
AND pi.part_inst2inv_bin = ib.objid
AND pi.part_serial_no = p_esn;
site_rec site_cur%ROWTYPE;
CURSOR dealer_promo_cur(p_site_objid IN NUMBER)
IS
SELECT p.*
FROM table_x_promotion p ,
      table_site s
WHERE s.dealer2x_promotion = p.objid
AND s.objid = p_site_objid
AND p.x_start_date <= SYSDATE
AND p.x_end_date >= SYSDATE;
dealer_promo_rec dealer_promo_cur%ROWTYPE;
CURSOR default_promo_cur(p_tech IN VARCHAR2)
IS
SELECT *
FROM table_x_promotion
WHERE x_is_default = 1
AND x_default_type = p_tech
AND x_start_date <= SYSDATE
AND x_end_date >= SYSDATE;
default_promo_rec default_promo_cur%ROWTYPE;
CURSOR activation_promo_used_curs(p_esn IN VARCHAR2)
IS
SELECT 'X'
FROM  table_x_promo_hist ph ,
       table_x_promotion p ,
       table_x_call_trans xct ,
       (SELECT tc.x_esn
       FROM table_case tc ,
       table_x_part_request pr
       WHERE 1 = 1
       AND tc.title = 'Defective Phone'
       AND tc.objid = pr.request2case
       AND pr.x_part_num_domain = 'PHONES'
       AND pr.x_part_serial_no = p_esn
       ) tab1
WHERE 1 = 1
AND p.x_is_default = 1
AND p.objid = ph.promo_hist2x_promotion
AND xct.objid = ph.promo_hist2x_call_trans
AND x_service_id = tab1.x_esn;
activation_promo_used_rec activation_promo_used_curs%ROWTYPE;
CURSOR get_oldsitepart_cur2(p_esn IN VARCHAR2)
IS
SELECT *
FROM table_site_part
WHERE x_service_id = p_esn
AND part_status <> 'Obsolete'
ORDER BY service_end_dt DESC;
get_oldsitepart_rec2 get_oldsitepart_cur2%ROWTYPE;
CURSOR get_pending_redemptions_cur(p_esn IN VARCHAR2)
IS
SELECT 'X'
FROM table_site_part sp ,
      table_x_pending_redemption pend
WHERE sp.x_service_id = p_esn
AND sp.part_status = 'Active'
AND pend.x_pend_red2site_part = sp.objid
AND NOT EXISTS
(SELECT 1
FROM table_x_promotion pr
WHERE pr.objid = pend.pend_red2x_promotion
AND pr.x_promo_type = 'Runtime'
AND x_revenue_type <> 'FREE'
);
get_pending_redemptions_rec get_pending_redemptions_cur%ROWTYPE;
CURSOR get_pending_repl_cur(p_esn IN VARCHAR2)
IS
SELECT 'X'
FROM sa.gtt_part_inst pi ,
      table_x_pending_redemption pend
WHERE pi.part_serial_no = p_esn
AND pend.pend_redemption2esn = pi.objid
AND pend.x_pend_type = 'REPL';
get_pending_repl_rec get_pending_repl_cur%ROWTYPE;
CURSOR c_sms_parent ( ip_tech IN VARCHAR2 ,ip_data IN NUMBER )
IS
SELECT cf.x_sms ,
cp.x_parent_id
FROM  table_x_parent cp ,
       table_x_carrier_group cg ,
       table_x_carrier ca ,
       table_x_carrier_features cf ,
       sa.gtt_part_inst pi ,
       table_site_part sp
WHERE sp.x_min = pi.part_serial_no
AND pi.part_inst2carrier_mkt = ca.objid
AND ca.carrier2carrier_group = cg.objid
AND cg.x_carrier_group2x_parent = cp.objid
AND cf.x_features2bus_org =
(SELECT pn.part_num2bus_org
FROM table_part_num pn ,
table_mod_level ml ,
sa.gtt_part_inst pi_esn
WHERE pn.objid = ml.part_info2part_num
AND ml.objid = pi_esn.n_part_inst2part_mod
AND pi_esn.part_serial_no = p_esn
)
AND cf.x_feature2x_carrier = ca.objid
AND cf.x_technology = ip_tech
AND cf.x_data = ip_data
AND sp.x_service_id = p_esn
AND sp.part_status
|| '' = 'Active';
r_sms_parent c_sms_parent%ROWTYPE;
CURSOR c_part_class
IS
SELECT pc.name
FROM  table_part_class pc ,
       table_part_num pn ,
       table_mod_level ml ,
       sa.gtt_part_inst pi
WHERE pi.n_part_inst2part_mod = ml.objid
AND ml.part_info2part_num = pn.objid
AND pn.part_num2part_class = pc.objid
AND pi.part_serial_no = p_esn;
r_part_class c_part_class%ROWTYPE;
CURSOR c_orig_act_date(p_esn IN VARCHAR2)
IS
SELECT (DECODE(refurb_yes.is_refurb ,0 ,nonrefurb_act_date.init_act_date ,refurb_act_date.init_act_date)) orig_act_date
FROM
(SELECT COUNT(1) is_refurb
FROM table_site_part sp_a
WHERE sp_a.x_service_id = p_esn
AND nvl(sp_a.x_refurb_flag,0) = 1
) refurb_yes ,
(SELECT MIN(install_date) init_act_date
FROM table_site_part sp_b
WHERE sp_b.x_service_id = p_esn
AND sp_b.part_status
|| '' IN ('Active' ,'Inactive')
AND NVL(sp_b.x_refurb_flag ,0) <> 1
) refurb_act_date ,
(SELECT MIN(install_date) init_act_date
FROM table_site_part sp_c
WHERE sp_c.x_service_id = p_esn
AND sp_c.part_status
|| '' IN ('Active' ,'Inactive')
) nonrefurb_act_date;
r_orig_act_date c_orig_act_date%ROWTYPE;
CURSOR c_reading_date(p_esn IN VARCHAR2)
IS
SELECT MAX(x_req_date_time) x_req_date_time
FROM table_x_zero_out_max
WHERE x_esn = p_esn
AND x_transaction_type = 1;
r_reading_date c_reading_date%ROWTYPE;
CURSOR c_account_exists(p_esn IN VARCHAR2)
IS
SELECT COUNT(*) cnt
FROM sa.gtt_part_inst pi ,
      table_x_contact_part_inst cp
WHERE pi.part_serial_no = p_esn
AND pi.objid = cp.x_contact_part_inst2part_inst;
r_account_exists c_account_exists%ROWTYPE;
CURSOR c_autopay_ac_exists(p_esn IN VARCHAR2)
IS
SELECT COUNT(*) cnt
FROM table_x_autopay_details
WHERE x_esn = p_esn
AND x_end_date IS NULL;
r_autopay_ac_exists c_autopay_ac_exists%ROWTYPE;
CURSOR c_enrollment_exists(p_esn IN VARCHAR2)
IS
SELECT COUNT(*) cnt FROM table_x_ez_enrollment WHERE x_esn = p_esn;
r_enrollment_exists c_enrollment_exists%ROWTYPE;
CURSOR get_esn_new_status_cur(p_esn IN VARCHAR2)
IS
SELECT ct.x_code_number ,
ct.x_code_name
FROM sa.gtt_part_inst pi ,
table_x_code_table ct
WHERE pi.part_serial_no = p_esn
AND pi.x_domain = 'PHONES'
AND pi.status2x_code_table = ct.objid;
get_esn_new_status_rec get_esn_new_status_cur%ROWTYPE;
CURSOR site_part_curs(p_esn VARCHAR2)
IS
SELECT sp.x_min
FROM table_site_part sp ,
sa.gtt_part_inst pi
WHERE pi.x_part_inst2site_part = sp.objid
AND pi.part_serial_no = p_esn;
site_part_rec site_part_curs%ROWTYPE;
CURSOR cur_is_esn_active
IS
SELECT tpn.x_ota_allowed ,
txct.x_code_name ,
tpiesn.part_inst2carrier_mkt ,
tpn.objid ,
tpiesn.x_part_inst_status
FROM table_mod_level tml ,
table_part_num tpn ,
table_x_code_table txct ,
sa.gtt_part_inst tpiesn
WHERE tpn.objid = tml.part_info2part_num
AND tml.objid = tpiesn.n_part_inst2part_mod
AND tpiesn.x_part_inst_status = txct.x_code_number
AND tpiesn.x_domain = 'PHONES'
AND txct.x_code_number = ota_util_pkg.esn_active
AND tpiesn.part_serial_no = p_esn;
CURSOR cur_is_carrier_ota_type
IS
SELECT txp.x_ota_carrier
FROM sa.gtt_part_inst tpiesn ,
table_part_inst tpimin ,
table_x_parent txp ,
table_x_carrier_group txcg ,
table_x_carrier txc ,
table_x_code_table txct
WHERE txc.objid = tpimin.part_inst2carrier_mkt
AND txp.objid = txcg.x_carrier_group2x_parent
AND txcg.objid = txc.carrier2carrier_group
AND tpiesn.objid = tpimin.part_to_esn2part_inst
AND tpimin.x_part_inst_status = txct.x_code_number
AND tpiesn.x_domain = 'PHONES'
AND tpimin.x_domain = 'LINES'
AND txct.x_code_number IN (ota_util_pkg.msid_update ,ota_util_pkg.line_active ,ota_util_pkg.pending_ac_change)
AND tpiesn.part_serial_no = p_esn;
CURSOR cur_get_ota_features
IS
SELECT tof.x_handset_lock ,
tof.x_redemption_menu ,
tof.x_psms_destination_addr
FROM table_x_ota_features tof ,
sa.gtt_part_inst tpi
WHERE tpi.objid = tof.x_ota_features2part_inst
AND tpi.part_serial_no = p_esn;
b_ota_activation BOOLEAN := FALSE;
CURSOR cur_is_ota_activation
IS
SELECT tpn.x_ota_allowed ,
tpiesn.x_part_inst_status
FROM table_mod_level tml ,
table_part_num tpn ,
sa.gtt_part_inst tpiesn
WHERE tpn.objid = tml.part_info2part_num
AND tml.objid = tpiesn.n_part_inst2part_mod
AND tpiesn.x_domain = 'PHONES'
AND x_part_inst_status IN (ota_util_pkg.esn_new ,ota_util_pkg.esn_refurbished ,ota_util_pkg.esn_used ,ota_util_pkg.esn_pastdue)
AND tpiesn.part_serial_no = p_esn;
CURSOR posa_info_cur(p_site_id IN VARCHAR2)
IS
SELECT pfd.posa_phone
FROM x_posa_flag_dealer pfd
WHERE pfd.site_id = p_site_id;
posa_info_rec posa_info_cur%ROWTYPE;
CURSOR cur_get_iccid_flag(ip_source_system IN VARCHAR2)
IS
SELECT x_sim_req
FROM table_x_ota_params_2 ,
table_bus_org
WHERE x_source_system = ip_source_system
AND ota_param2bus_org = table_bus_org.objid
AND org_id = p_brand_name;
get_iccid_flag_rec cur_get_iccid_flag%ROWTYPE;
--
CURSOR cur_input_brand
IS
SELECT * FROM table_bus_org WHERE org_id = UPPER(p_brand_name);
rec_input_brand cur_input_brand%ROWTYPE;
CURSOR cur_input_channel
IS
SELECT * FROM table_channel WHERE title = p_source_system;
rec_input_channel cur_input_channel%ROWTYPE;
-- SAFELINK RE-QUALIFICATIONS IC 8/24/11
CURSOR cur_safelink_esn(p_esn IN VARCHAR2)
IS
SELECT x_current_esn ,
x_current_active
FROM x_sl_currentvals
WHERE x_current_esn = p_esn;
rec_safelink_esn cur_safelink_esn%ROWTYPE;
--CR17820 Start kacosta 3/28/2012
CURSOR get_min_status_curs(c_v_esn sa.gtt_part_inst.part_serial_no%TYPE)
IS
SELECT tpi_min.x_part_inst_status
FROM sa.gtt_part_inst tpi_esn
JOIN table_part_inst tpi_min
ON tpi_esn.objid = tpi_min.part_to_esn2part_inst
WHERE tpi_esn.part_serial_no = c_v_esn
AND tpi_esn.x_domain = 'PHONES'
AND tpi_min.x_domain = 'LINES';
--
get_min_status_rec get_min_status_curs%ROWTYPE;
--CR17820 End kacosta 3/28/2012
-- ACMI ACME project 11/06/2012
CURSOR ACME_cur_pn(v_esn IN VARCHAR2)
IS
SELECT pn.part_number,
(SELECT COUNT(*)
FROM table_x_part_class_values v,
table_x_part_class_params n
WHERE value2class_param = n.objid
AND v.value2part_class =pn.part_num2part_class
AND n.x_param_name = 'OPERATING_SYSTEM'
AND upper(v.x_param_value)='IOS'
AND rownum <2
)l_hex2dec_flag
FROM sa.gtt_part_inst pi ,
table_mod_level ml ,
table_part_num pn
WHERE pi.n_part_inst2part_mod = ml.objid
AND ml.part_info2part_num = pn.objid
AND pi.part_serial_no = v_esn
AND pi.x_domain = 'PHONES';
ACME_rec_pn ACME_cur_pn%rowtype;
v_esn sa.gtt_part_inst.part_serial_no%TYPE;
--ACMI ACME project 11/06/2012
-- UBRAND
CURSOR UNIVERSAL_cur (p_esn VARCHAR2)
IS
SELECT PART_NUMBER
FROM table_part_class pc,
table_bus_org bo,
table_part_num pn,
pc_params_view vw,
sa.gtt_part_inst pi,
table_mod_level ml
WHERE pn.part_num2bus_org =bo.objid
AND pn.pArt_num2part_class =pc.objid
AND pc.name =vw.part_class
AND bo.org_id ='GENERIC'
AND vw.param_name ='BUS_ORG'
AND vw.param_value ='GENERIC'
AND PC.NAME <> 'GPPHONE'
AND pi.n_part_inst2part_mod=ml.objid
AND ml.part_info2part_num =pn.objid
AND pi.part_serial_no = p_esn ; --'100000000013245842'
UNIVERSAL_rec UNIVERSAL_cur%rowtype ;
  --
  CURSOR c_queued_pin (c_esn VARCHAR2)
  IS
    SELECT pn.s_part_number pin_part_num,
      pn.part_type
    FROM sa.gtt_part_inst esn,
      table_part_inst pin,
      table_mod_level ml,
      table_part_num pn,
      table_part_class pc
    WHERE pin.part_to_esn2part_inst = esn.objid
    AND pin.n_part_inst2part_mod    = ml.objid
    AND ml.part_info2part_num       = pn.objid
    AND pc.objid                    = pn.part_num2part_class
    AND pin.x_domain                = 'REDEMPTION CARDS'
    AND pin.x_ext                   = '1'
    AND esn.part_serial_no          = c_esn
    ORDER BY esn.part_serial_no,
      pin.x_ext;
  rec_queued_pin c_queued_pin%ROWTYPE;
  CURSOR get_phone_info_cur_new (c_esn IN VARCHAR2)
  IS
    SELECT pn.x_card_plan
    FROM sa.gtt_part_inst pi,
      table_mod_level ml,
      table_part_num pn,
      table_bus_org bo,
      table_part_class pc
    WHERE pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num     = pn.objid
    AND pi.part_serial_no         = c_esn
    AND pi.x_domain               = 'PHONES'
    AND bo.objid                  = pn.part_num2bus_org
    AND pc.objid                  = pn.part_num2part_class;
  get_phone_info_new_rec get_phone_info_cur_new%ROWTYPE;
  --
--CR35310 - Remove default activation promotions for TF --Start
--Declaration of Local variables
l_def_act_promo VARCHAR2(1) ;
l_non_ppe_flag NUMBER ;
l_serv_due_dt DATE ;
l_warr_end_dt DATE ;
l_expire_dt DATE ;
l_ct_rec_count NUMBER ;
l_partnum2part_class NUMBER ;
l_part_inst_status VARCHAR2(20);
--CR35310 - Remove default activation promotions for TF --End

--CR22799 LTE 4G
OP_SIM_STATUS VARCHAR2(30);
OP_X_ICCID NUMBER;
OP_ESN_STATUS VARCHAR2(20);
OP_ERROR_CODE NUMBER;
p_phone_brand VARCHAR2(50);
-- BRAND SEPARATION END
v_tech VARCHAR2(50);
v_temp_sp BOOLEAN;
v_cc_count NUMBER;
v_reading_found NUMBER := 0;
v_extra_info_1 VARCHAR2(20);
v_extra_info_2 VARCHAR2(20);
v_extra_info_3 VARCHAR2(20);
v_extra_info_4 VARCHAR2(20);
v_extra_info_5 VARCHAR2(20);
v_extra_info_6 VARCHAR2(20);
extra_info_7 CONSTANT NUMBER(1) := 1;
-- ota elements
v_extra_info_8 NUMBER(1);
v_extra_info_9 NUMBER(1);
v_extra_info_10 NUMBER(1);
v_extra_info_11 NUMBER(1);
v_extra_info_12 NUMBER(1);
v_extra_info_13 NUMBER(1);
--exchange element (Rev. 1.44)
v_extra_info_14 NUMBER(1);
--CR17820 Start kacosta 3/28/2012
V_EXTRA_INFO_15 NUMBER(1);
v_extra_info_16 NUMBER(1);--cr25490 B2B
l_v_min_status sa.gtt_part_inst.x_part_inst_status%TYPE;
--CR17820 End kacosta 3/28/2012
v_tag_no NUMBER := 0;
v_code_value NUMBER := 0;
v_result NUMBER := 0;
v_repl_pend_flag NUMBER := 0;
v_hdr_ind NUMBER := 0;
v_sp_objid NUMBER := 0;
v_posa_phone VARCHAR(1);
p_err NUMBER;
p_msg VARCHAR2(50);
v_part_class_name VARCHAR2(30); -- CR8663 SWITCHBASE
v_non_ppe VARCHAR2(1) := '0';
l_error_msg  VARCHAR2(1000);
TYPE sid_tab
IS
TABLE OF table_x_sids.x_sid%TYPE INDEX BY BINARY_INTEGER;
v_old_sid sid_tab;
v_new_sid sid_tab;
old_counter INT := 1;
new_counter INT := 1;
v_esn_brand2 VARCHAR2(30);
/* CR33864 ATT CARRIER SWITCH Variable declaration start*/
OP_LAST_RATE_PLAN_SENT VARCHAR2(60);
OP_IS_SWB_CARR VARCHAR2(200);
OP_ERROR_CODE1 NUMBER;
OP_ERROR_MESSAGE VARCHAR2(200);
/* CR33864 ATT CARRIER SWITCH Variable declaration End*/
PROCEDURE close_open_cursors
IS
BEGIN
IF part_inst_cur%ISOPEN THEN
CLOSE part_inst_cur;
END IF;
IF get_esn_new_status_cur%ISOPEN THEN
CLOSE get_esn_new_status_cur;
END IF;
IF c_account_exists%ISOPEN THEN
CLOSE c_account_exists;
END IF;
IF c_autopay_ac_exists%ISOPEN THEN
CLOSE c_autopay_ac_exists;
END IF;
IF c_enrollment_exists%ISOPEN THEN
CLOSE c_enrollment_exists;
END IF;
IF c_part_class%ISOPEN THEN
CLOSE c_part_class;
END IF;
IF c_reading_date%ISOPEN THEN
CLOSE c_reading_date;
END IF;
IF c_orig_act_date%ISOPEN THEN
CLOSE c_orig_act_date;
END IF;
IF get_phone_info_cur%ISOPEN THEN
CLOSE get_phone_info_cur;
END IF;
IF product_part_cur%ISOPEN THEN
CLOSE product_part_cur;
END IF;
IF new_plan_cur%ISOPEN THEN
CLOSE new_plan_cur;
END IF;
IF contact_pi_cur%ISOPEN THEN
CLOSE contact_pi_cur;
END IF;
IF contact_sp_cur%ISOPEN THEN
CLOSE contact_sp_cur;
END IF;
IF cc_cur%ISOPEN THEN
CLOSE cc_cur;
END IF;
IF pi_min_cur%ISOPEN THEN
CLOSE pi_min_cur;
END IF;
IF new_pers_cur%ISOPEN THEN
CLOSE new_pers_cur;
END IF;
IF old_pers_cur%ISOPEN THEN
CLOSE old_pers_cur;
END IF;
IF pers_lac_cur%ISOPEN THEN
CLOSE pers_lac_cur;
END IF;
IF getpers2sid_cur%ISOPEN THEN
CLOSE getpers2sid_cur;
END IF;
IF c_sms_parent%ISOPEN THEN
CLOSE c_sms_parent;
END IF;
IF get_pending_repl_cur%ISOPEN THEN
CLOSE get_pending_repl_cur;
END IF;
IF get_pending_redemptions_cur%ISOPEN THEN
CLOSE get_pending_redemptions_cur;
END IF;
IF get_phone_info_cur%ISOPEN THEN
CLOSE get_phone_info_cur;
END IF;
IF site_cur%ISOPEN THEN
CLOSE site_cur;
END IF;
IF default_promo_cur%ISOPEN THEN
CLOSE default_promo_cur;
END IF;
IF dealer_promo_cur%ISOPEN THEN
CLOSE dealer_promo_cur;
END IF;
IF get_oldsitepart_cur%ISOPEN THEN
CLOSE get_oldsitepart_cur;
END IF;
IF contact_pi_cur%ISOPEN THEN
CLOSE contact_pi_cur;
END IF;
IF site_part_curs%ISOPEN THEN
CLOSE site_part_curs;
END IF;
IF pi_min_cur%ISOPEN THEN
CLOSE pi_min_cur;
END IF;
IF get_pending_repl_cur%ISOPEN THEN
CLOSE get_pending_repl_cur;
END IF;
IF contact_pi_cur%ISOPEN THEN
CLOSE contact_pi_cur;
END IF;
IF contact_sp_cur%ISOPEN THEN
CLOSE contact_sp_cur;
END IF;
IF site_part_curs%ISOPEN THEN
CLOSE site_part_curs;
END IF;
IF posa_info_cur%ISOPEN THEN
CLOSE posa_info_cur;
END IF;
IF activation_promo_used_curs%ISOPEN THEN
CLOSE activation_promo_used_curs;
END IF;
IF cur_get_iccid_flag%ISOPEN THEN
CLOSE cur_get_iccid_flag;
END IF;
IF carrier_pending_cur%ISOPEN THEN
CLOSE carrier_pending_cur;
END IF;
IF carrier_pending_react_cur%ISOPEN THEN
CLOSE carrier_pending_react_cur;
END IF;
IF activation_pending_cur%ISOPEN THEN
CLOSE activation_pending_cur;
END IF;
-- SAFELINK RE-QUALIFICATIONS IC 8/24/11
IF cur_safelink_esn%ISOPEN THEN
CLOSE cur_safelink_esn;
END IF;
--- ACMI ACME PROJECT 11/06/2012
IF ACME_cur_pn%ISOPEN THEN
CLOSE ACME_cur_pn;
END IF;
-- ACMI ACME PROJECT 11/06/2012
-- UBRAND
IF UNIVERSAL_cur%ISOPEN THEN
CLOSE UNIVERSAL_cur;
END IF;

--BRAND SEPARATION START
/* * -- CR8663 SWITCH BASE
IF Cur_Subsourcesystem%ISOPEN
THEN
CLOSE Cur_Subsourcesystem;
END IF;
*/
--BRAND SEPARATION END
END close_open_cursors;

--CR35310: New function added to retrieve the redemption flag by passing ESN.
FUNCTION get_redemption_flag(i_esn IN VARCHAR2 ,
i_brand_name IN VARCHAR2)
RETURN NUMBER
IS
--Declaration of Local variables
l_def_act_promo VARCHAR2(1) ;
l_non_ppe_flag NUMBER ;
l_serv_due_dt DATE ;
l_warr_end_dt DATE ;
l_expire_dt DATE ;
l_ct_rec_count NUMBER ;
l_partnum2part_class NUMBER ;
l_part_inst_status VARCHAR2(20);
l_redemp_reqd_flg NUMBER ;

BEGIN --Main Section
l_redemp_reqd_flg := 1;
IF i_brand_name IN ('TRACFONE','NET10')THEN
BEGIN
SELECT x_expire_dt INTO l_expire_dt
FROM (SELECT x_expire_dt
FROM table_site_part
WHERE x_service_id = i_esn
AND TO_CHAR(x_expire_dt,'MM/DD/YYYY') <> '01/01/1753'
ORDER BY update_stamp DESC
)
WHERE ROWNUM = 1;
EXCEPTION
WHEN OTHERS THEN
NULL;
END;

-- Retrieving the warranty date and part class for given ESN
BEGIN
SELECT CASE WHEN (l_expire_dt IS NOT NULL AND pi.warr_end_date IS NOT NULL ) THEN GREATEST(l_expire_dt, pi.warr_end_date)
WHEN (l_expire_dt IS NOT NULL AND pi.warr_end_date IS NULL ) THEN l_expire_dt
WHEN (l_expire_dt IS NULL AND pi.warr_end_date IS NOT NULL ) THEN pi.warr_end_date
ELSE NULL
END serv_due_dt,
pn.part_num2part_class,
pi.x_part_inst_status
INTO l_serv_due_dt,
l_partnum2part_class,
l_part_inst_status
FROM sa.gtt_part_inst pi ,
table_part_num pn ,
table_mod_level ml
WHERE 1 = 1
AND pi.part_serial_no = i_esn
AND pi.x_domain = 'PHONES'
AND pi.n_part_inst2part_mod = ml.objid
AND NVL(TO_CHAR(pi.warr_end_date,'MM/DD/YYYY'),'01/01/9999') <> '01/01/1753'
AND ml.part_info2part_num = pn.objid;
EXCEPTION
WHEN NO_DATA_FOUND THEN
l_serv_due_dt := l_expire_dt;
WHEN TOO_MANY_ROWS THEN
p_errstr := 'More than 1 record exists for the given ESN';
--RETURN;
WHEN OTHERS THEN
l_serv_due_dt := l_expire_dt;
END;

IF l_partnum2part_class IS NOT NULL THEN
-- Retrieving the non ppe and default activation promo flag for given ESN
BEGIN
SELECT pcpv.non_ppe non_ppe_flag,
NVL(pcpv.apply_def_activation_promo,'Y') def_act_promo
INTO l_non_ppe_flag,
l_def_act_promo
FROM sa.pcpv_mv pcpv
WHERE pc_objid = l_partnum2part_class;
EXCEPTION
WHEN OTHERS THEN
-- Set default value to Y
l_def_act_promo := 'Y';
END;
ELSE
-- Set default value to Y
l_def_act_promo := 'Y';
END IF;

-- Checking the record count for card on reserve for the given ESN.
SELECT COUNT(1)
INTO l_ct_rec_count
FROM sa.gtt_part_inst esn ,
table_part_inst cards,
table_mod_level ml ,
table_part_num pn
WHERE esn.part_serial_no = i_esn
AND esn.x_domain = 'PHONES'
AND esn.objid = cards.part_to_esn2part_inst
AND cards.x_part_inst_status = '400'
AND cards.x_domain = 'REDEMPTION CARDS'
AND cards.n_part_inst2part_mod = ml.objid
AND ml.part_info2part_num = pn.objid;

-- Validate the given ESN for below conditions
IF l_part_inst_status <> 52 THEN --Condition added for Emergency CR36788
--
IF NVL(l_def_act_promo,'Y') = 'Y' AND l_part_inst_status IN (50, 150) AND l_non_ppe_flag = 0 THEN
l_redemp_reqd_flg := 0;
ELSIF l_non_ppe_flag = 0 and l_serv_due_dt > SYSDATE THEN
l_redemp_reqd_flg := 0;
ELSIF l_non_ppe_flag = 1 and l_serv_due_dt > SYSDATE THEN
l_redemp_reqd_flg := 0;
ELSIF l_ct_rec_count > 0 THEN
l_redemp_reqd_flg := 0;
ELSE
p_promo_units := 0;
p_promo_access_days := 0;
l_redemp_reqd_flg := 1;
END IF;
--
END IF;
--
END IF;
--
RETURN l_redemp_reqd_flg;
--
EXCEPTION
WHEN OTHERS THEN
RETURN(NULL);
--
END get_redemption_flag; --End of get_redemption_flag function for CR35310
--
BEGIN  -- validate pre posa phone
  p_preactv_benefits := 'N';
  v_non_ppe := '0'; -- CR8663 SWITCH BASE
  v_part_class_name := ' '; -- DITTO
  p_pending_red_status := 'FALSE';
  p_click_status := 'FALSE';
  v_temp_sp := FALSE;
  p_part_inst_objid := 0;
  p_redemp_reqd_flg := 0;
  p_warr_end_date := '';
  p_promo_units := 0;
  p_promo_access_days := 0;
  p_num_of_cards := 0;
  P_ERRNUM := '0';
  v_cc_count := 0;
  v_extra_info_1 := 0;
  v_extra_info_2 := 0;
  v_extra_info_3 := 0;
  v_extra_info_4 := 0;
  v_extra_info_5 := 0;
  v_extra_info_6 := 0;
  v_extra_info_8 := 0; -- is esn active
  v_extra_info_9 := 0; -- is esn ota allowed
  v_extra_info_10 := 0; -- is carrier ota type
  v_extra_info_11 := 1; -- is handset locked
  v_extra_info_12 := 0; -- is redemption menu on the handset enabled
  v_extra_info_13 := 0; -- is psms destination address on the phone
  v_extra_info_14 := 0;
  --CR17820 Start kacosta 3/28/2012
  V_EXTRA_INFO_15 := 0; -- is line reserved
  v_extra_info_16 := 0;---1 is B2b,0 is non b2b
  --CR17820 End kacosta 3/28/2012
  -- is original act date is > or < 30 days (Rev 1.44)
  v_tag_no := 0;
  p_last_call_trans := 0;
  --CR22799 LTE 4G
  OP_SIM_STATUS := ' '; --VARCHAR2(30)
  OP_X_ICCID := 0; --NUMBER
  OP_ESN_STATUS := ' '; --VARCHAR2(20)
  OP_ERROR_CODE := 0; --number
  --
  -- Load the data from part_inst to temp table
   OPEN part_inst_temp_cur (p_esn);
   FETCH part_inst_temp_cur
   INTO  pi_rec;
   IF part_inst_temp_cur%FOUND
   THEN
     BEGIN
       INSERT INTO sa.gtt_part_inst
       SELECT * FROM table_part_inst where objid = pi_rec.objid;
     EXCEPTION
       WHEN OTHERS THEN
         p_errnum :=  '999';
         p_errstr :=  'Failed while inserting into temp table';
         close_open_cursors; --Fix OPEN_CURSORS
         RETURN;
     END;
   END IF;
  --CR35310 -Remove default activation promotions
  p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name);

  -- CR24243 UBRAND
  OPEN UNIVERSAL_cur(p_esn);
  FETCH UNIVERSAL_cur INTO UNIVERSAL_rec;
  IF UNIVERSAL_cur%FOUND THEN
    p_errnum := '111';
    p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
    close_open_cursors;
    RETURN;
  END IF ;
  --CR17820 Start kacosta 03/28/2012
  IF site_part_curs%ISOPEN THEN
  --
  CLOSE site_part_curs;
  --
  END IF;
  --
  OPEN site_part_curs(p_esn);
  FETCH site_part_curs INTO site_part_rec;
  CLOSE site_part_curs;
  --
  IF pi_min_cur%ISOPEN THEN
  --
  CLOSE pi_min_cur;
  --
  END IF;
  --
  OPEN pi_min_cur(site_part_rec.x_min);
  FETCH pi_min_cur INTO pi_min_rec;
  CLOSE pi_min_cur;
  --
  IF (pi_min_rec.x_part_inst_status IS NULL) THEN
  --
  IF get_min_status_curs%ISOPEN THEN
  --
  CLOSE get_min_status_curs;
  --
  END IF;
  --
  OPEN get_min_status_curs(c_v_esn => p_esn);
  FETCH get_min_status_curs INTO get_min_status_rec;
  CLOSE get_min_status_curs;
  --
  l_v_min_status := get_min_status_rec.x_part_inst_status;
  --
  ELSE
  --
  l_v_min_status := pi_min_rec.x_part_inst_status;
  --
  END IF;
  --
  IF (l_v_min_status IN ('37' ,'38' ,'39' ,'73')) THEN
  --
  v_extra_info_15 := '1';
  --
  END IF;
  --
  p_extra_info := v_extra_info_1 || v_extra_info_2 || v_extra_info_3 || v_extra_info_4 || v_extra_info_5 || v_extra_info_6 || extra_info_7 || V_EXTRA_INFO_8 || V_EXTRA_INFO_9 || V_EXTRA_INFO_10 || V_EXTRA_INFO_11 || V_EXTRA_INFO_12 || V_EXTRA_INFO_13 || V_EXTRA_INFO_14 || v_extra_info_15|| V_EXTRA_INFO_16;
  --CR17820 End kacosta 03/28/2012
  --
  OPEN part_inst_cur(p_esn);
  FETCH part_inst_cur INTO part_inst_rec;
  IF part_inst_cur%FOUND THEN
    p_part_inst_objid := NVL(part_inst_rec.objid ,0);
    p_code_number := NVL(part_inst_rec.x_code_number ,0);
    p_code_name := NVL(part_inst_rec.x_code_name ,0);
    p_warr_end_date := TO_CHAR(part_inst_rec.warr_end_date ,'MM/DD/YYYY');
    v_tag_no := NVL(part_inst_rec.pi_tag_no ,0);
    v_code_value := NVL(part_inst_rec.x_value ,0);
    v_hdr_ind := NVL(part_inst_rec.hdr_ind ,0);
    p_seq := NVL(part_inst_rec.x_sequence ,0);
    p_iccid := part_inst_rec.x_iccid;
    p_iccid_flag := part_inst_rec.x_iccid_flag;
    OPEN site_cur(p_esn);
    FETCH site_cur INTO site_rec;
    CLOSE site_cur;
    OPEN posa_info_cur(site_rec.site_id);
    FETCH posa_info_cur INTO posa_info_rec;
    IF posa_info_cur%FOUND THEN
    v_posa_phone := posa_info_rec.posa_phone;
    IF ((v_posa_phone = 'Y') AND (p_code_number = '59')) THEN
    -- ACMI ACME project start 11/05/2012
    OPEN ACME_cur_pn(p_esn);
    FETCH ACME_cur_pn INTO ACME_rec_pn;
    IF ACME_cur_pn%FOUND AND ACME_rec_pn.l_hex2dec_flag >0 THEN
    v_esn := part_inst_rec.x_hex_serial_no;
    ELSE
    v_esn := p_esn;
    END IF ;
    CLOSE ACME_cur_pn;
    --ACMI ACME Project 11/05/2012
    simulate_phone_active(p_esn, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, v_result, l_error_msg, 'POSA_FLAG_ON' );
    END IF;
    END IF;
    IF v_result = 0 THEN
    OPEN get_esn_new_status_cur(p_esn);
    FETCH get_esn_new_status_cur INTO get_esn_new_status_rec;
    IF get_esn_new_status_cur%FOUND THEN
    p_code_number := get_esn_new_status_rec.x_code_number;
    p_code_name := get_esn_new_status_rec.x_code_name;
    ELSE
    p_errnum := '106';
    p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
    close_open_cursors;
    RETURN;
    END IF;
    CLOSE get_esn_new_status_cur;
    ELSE
    p_errnum := '106';
    p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
    close_open_cursors;
    RETURN;
    END IF;
    -- SAFELINK RE-QUALIFICATIONS IC 8/24/11
    OPEN cur_safelink_esn(p_esn);
    FETCH cur_safelink_esn INTO rec_safelink_esn;
    IF cur_safelink_esn%FOUND THEN
    p_safelink_esn := 'T';
    END IF;
    -- SAFELINK RE-QUALIFICATIONS IC 8/24/11 END
    OPEN c_account_exists(p_esn);
    FETCH c_account_exists INTO r_account_exists;
    CLOSE c_account_exists;
    v_extra_info_3 := r_account_exists.cnt;
    IF v_extra_info_3 > 1 THEN
    v_extra_info_3 := 1;
    END IF;
    p_extra_info := v_extra_info_1 || v_extra_info_2 || v_extra_info_3 || v_extra_info_4 || v_extra_info_5 || v_extra_info_6 || extra_info_7 ||
    -- ota elements:
    v_extra_info_8 || v_extra_info_9 || v_extra_info_10 || v_extra_info_11 || v_extra_info_12 || v_extra_info_13
    --exch element
    --CR17820 Start kacosta 03/28/2012
    -- || v_extra_info_14;
    || v_extra_info_14 || v_extra_info_15|| V_EXTRA_INFO_16;
    --CR17820 End kacosta 03/28/2012
    OPEN c_autopay_ac_exists(p_esn);
    FETCH c_autopay_ac_exists INTO r_autopay_ac_exists;
    CLOSE c_autopay_ac_exists;
    v_extra_info_6 := r_autopay_ac_exists.cnt;
    IF v_extra_info_6 > 1 THEN
    v_extra_info_6 := 1;
    END IF;
    --If the customer is not enrolled check if we are trying to enroll him using EZ Web enrollment
    IF v_extra_info_6 = 0 THEN
    OPEN c_enrollment_exists(p_esn);
    FETCH c_enrollment_exists INTO r_enrollment_exists;
    CLOSE c_enrollment_exists;
    v_extra_info_6 := r_enrollment_exists.cnt;
    IF v_extra_info_6 > 1 THEN
    v_extra_info_6 := 1;
    END IF;
    END IF;
    p_extra_info := v_extra_info_1 || v_extra_info_2 || v_extra_info_3 || v_extra_info_4 || v_extra_info_5 || v_extra_info_6 || extra_info_7 ||
    -- ota elements:
    v_extra_info_8 || v_extra_info_9 || v_extra_info_10 || v_extra_info_11 || v_extra_info_12 || v_extra_info_13
    --exch element
    --CR17820 Start kacosta 03/28/2012
    -- || v_extra_info_14;
    || v_extra_info_14 || v_extra_info_15|| V_EXTRA_INFO_16;
    --CR17820 End kacosta 03/28/2012
    --CR2253
    OPEN c_part_class;
    FETCH c_part_class INTO r_part_class;
    IF c_part_class%FOUND THEN
    p_part_class := NVL(r_part_class.name ,'NA');
    ELSE
    p_part_class := 'NA';
    END IF;
    CLOSE c_part_class;
    OPEN c_reading_date(p_esn);
    FETCH c_reading_date INTO r_reading_date;
    IF c_reading_date%FOUND AND r_reading_date.x_req_date_time IS NOT NULL THEN
    v_reading_found := 1;
    ELSE
    v_reading_found := 0;
    END IF;
    CLOSE c_reading_date;
    OPEN c_orig_act_date(p_esn);
    FETCH c_orig_act_date INTO r_orig_act_date;
    IF c_orig_act_date%FOUND THEN
    IF TRUNC(SYSDATE - r_orig_act_date.orig_act_date) > 90
    --CR3740
    AND v_reading_found = 0 THEN
    v_extra_info_1 := 1;
    ELSIF TRUNC(SYSDATE - r_reading_date.x_req_date_time) > 90 AND v_reading_found = 1 THEN
    v_extra_info_1 := 1;
    ELSE
    v_extra_info_1 := 0;
    END IF;
    IF TRUNC(SYSDATE - r_orig_act_date.orig_act_date) >= 30 THEN
    v_extra_info_14 := 1;
    ELSE
    v_extra_info_14 := 0;
    END IF;
    ELSE
    v_extra_info_1 := 0;
    v_extra_info_14 := 0;
    END IF;
    CLOSE c_orig_act_date;
    IF v_hdr_ind = 1 THEN
    v_extra_info_1 := 1;
    END IF;
    p_extra_info := v_extra_info_1 || v_extra_info_2 || v_extra_info_3 || v_extra_info_4 || v_extra_info_5 || v_extra_info_6 || extra_info_7 ||
    -- ota elements:
    v_extra_info_8 || v_extra_info_9 || v_extra_info_10 || v_extra_info_11 || v_extra_info_12 || v_extra_info_13
    --exch element
    --CR17820 Start kacosta 03/28/2012
    -- || v_extra_info_14;
    || v_extra_info_14 || v_extra_info_15|| V_EXTRA_INFO_16;
    --CR17820 End kacosta 03/28/2012
  ELSE
    p_errnum := '101';
    p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
    close_open_cursors;
    RETURN;
  END IF;
  CLOSE part_inst_cur;
  OPEN get_phone_info_cur(p_esn);
  FETCH get_phone_info_cur INTO get_phone_info_rec;
  IF get_phone_info_cur%FOUND THEN
    p_phone_brand := get_phone_info_rec.org_id;
    p_phone_model := get_phone_info_rec.part_number;
    p_phone_technology := get_phone_info_rec.x_technology;
    p_int_dll := NVL(get_phone_info_rec.x_dll ,0);
    p_phone_description := NVL(SUBSTR(get_phone_info_rec.description ,1 ,30) ,0);
    --BRAND_SEP
    --p_amigo_flg := get_phone_info_rec.x_restricted_use;
    p_esn_brand := get_phone_info_rec.org_id;
    v_esn_brand2 := get_phone_info_rec.loc_type;
    -- Second Brand LifeLine
    --BRAND_SEP
    p_manufacturer := get_phone_info_rec.x_manufacturer; --CR3733
    v_part_class_name := r_part_class.name; -- CR8663 SWITCH
     OPEN cur_input_brand;
    FETCH cur_input_brand INTO rec_input_brand;
    IF cur_input_brand%NOTFOUND THEN
      -- Not valid Brand
      p_errnum := '126';
      p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
      CLOSE cur_input_brand;
      RETURN;
    END IF;
    CLOSE cur_input_brand;
    OPEN cur_input_channel;
    FETCH cur_input_channel INTO rec_input_channel;
    IF cur_input_channel%NOTFOUND THEN
      -- Not Valid Channel
      p_errnum := '127';
      p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
      CLOSE cur_input_channel;
      RETURN;
    END IF;
    CLOSE cur_input_channel;
    IF p_esn_brand <> UPPER(TRIM(p_brand_name)) AND v_esn_brand2 <> UPPER(TRIM(p_brand_name)) THEN
      -- ESN does not belong to brand
      p_errnum := '125';
      p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
      RETURN;
    END IF;
    -- BRAND SEPARATION END
    IF (p_code_number != '52' AND part_inst_rec.x_port_in = 1) THEN
      p_errnum := '120';
      p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
      close_open_cursors;
      RETURN;
    END IF;
    OPEN cur_get_iccid_flag(p_source_system);
    FETCH cur_get_iccid_flag INTO get_iccid_flag_rec;
    IF cur_get_iccid_flag%FOUND THEN
      p_iccid_flag := get_iccid_flag_rec.x_sim_req;
    END IF;
    CLOSE cur_get_iccid_flag;
    IF ((NVL(p_source_system ,'IVR') <> 'WEBCSR') AND (NVL(p_source_system ,'IVR') <> 'TAS') -- CR22454 CL SIMPLE MOBILE
    AND (NVL(p_source_system ,'IVR') <> 'NETCSR')) --CR3979
    AND (v_tag_no = 1) AND (p_code_number = '50') THEN
      p_errnum := '103';
      p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
      close_open_cursors;
      RETURN;
    END IF;
  ELSE
    p_errnum := '104';
    p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
    close_open_cursors;
    RETURN;
  END IF;
  IF (NVL(p_source_system,'IVR') IN ('WEBCSR' ,'NETCSR','TAS') -- CR22454 CL SIMPLE MOBILE
  AND (v_tag_no = 2)) THEN
    UPDATE sa.gtt_part_inst SET pi_tag_no = 0 WHERE part_serial_no = p_esn;
  --COMMIT;
  ELSIF ((NVL(p_source_system ,'IVR') <> 'WEBCSR') AND (NVL(p_source_system ,'IVR') <> 'TAS') -- CR22454 CL SIMPLE MOBILE
  AND (NVL(p_source_system ,'IVR') <> 'NETCSR')) AND (v_tag_no = 2) THEN
    p_errnum := '105';
    p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
    close_open_cursors;
    RETURN;
  END IF;
  CLOSE get_phone_info_cur;
  IF p_code_number = '50' OR p_code_number = '150' THEN
  -- CR17003 Start Net 10 Sprint
  -- CR17413 (B) LG L95G (NT10 Unlimited GSM Postpaid)
    IF p_code_number = '50' AND get_phone_info_rec.x_dll <= 0 -- CR17413 removed this and added dll x_technology = 'CDMA'
    --AND get_phone_info_rec.org_id = 'NET10' -- CR23513
    AND get_phone_info_rec.non_ppe_flag = '1' THEN
    --p_redemp_reqd_flg := 1;
    p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name); --CR35310 - Remove default activation promotions.
    ELSE
    --p_redemp_reqd_flg := 0;
    p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name); --CR35310 - Remove default activation promotions.
    END IF;
  -- CR17003 End Net 10 Sprint
  ELSIF p_code_number = '52' OR p_code_number = '54' THEN
    --p_redemp_reqd_flg := 1;
    p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name); --CR35310 - Remove default activation promotions.
  ELSIF p_code_number = '51' OR p_code_number = '53' THEN
    IF part_inst_rec.warr_end_date > SYSDATE THEN
    --p_redemp_reqd_flg := 0;
    p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name); --CR35310 - Remove default activation promotions.
    ELSE
    --p_redemp_reqd_flg := 1;
    p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name); --CR35310 - Remove default activation promotions.
    END IF;
  ELSE
    p_errnum := '106';
    p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
    close_open_cursors;
    --CR35310 -Remove default activation promotions
    p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name);
    RETURN;
  END IF;
  --LTE 4G CR22799
  IF sa.LTE_SERVICE_PKG.IS_LTE_4G_SIM_REM(p_esn) = 0 THEN
  --DBMS_OUTPUT.PUT_LINE('IS LTE PHONE');
  sa.LTE_SERVICE_PKG.IS_LTE_MARRIAGE(P_ESN,OP_SIM_STATUS,OP_X_ICCID,OP_ESN_STATUS,OP_ERROR_CODE);
  -- end of CR29812
  END IF;

  OPEN carrier_pending_cur(p_esn);
  FETCH carrier_pending_cur INTO carrier_pending_rec;
  IF carrier_pending_cur%FOUND THEN
    p_last_call_trans := NVL(carrier_pending_rec.ct_objid ,0);
    p_contact_id := TO_CHAR(carrier_pending_rec.x_part_inst2contact);
    p_zipcode := NVL(carrier_pending_rec.x_zipcode ,'NA');
    p_min := NVL(carrier_pending_rec.x_min ,'NA');
    p_errnum := '116';
    p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
    IF p_code_number = '54' THEN
      OPEN get_pending_repl_cur(p_esn);
      FETCH get_pending_repl_cur INTO get_pending_repl_rec;
      IF get_pending_repl_cur%FOUND THEN
        IF (p_source_system = 'WEBCSR' OR p_source_system = 'NETCSR' OR p_source_system='TAS') THEN -- CR22454 CL SIMPLE MOBILE
        --p_redemp_reqd_flg := 0;
          p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name); --CR35310 - Remove default activation promotions.
        END IF;
      END IF;
      CLOSE get_pending_repl_cur;
      IF part_inst_rec.warr_end_date > SYSDATE THEN
        --p_redemp_reqd_flg := 0;
        p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name); --CR35310 - Remove default activation promotions.
      END IF;
    END IF;
    close_open_cursors;
    --CR35310 -Remove default activation promotions
    p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name);
    RETURN;
  END IF;
  OPEN carrier_pending_react_cur(p_esn);
  FETCH carrier_pending_react_cur INTO carrier_pending_react_rec;
  IF carrier_pending_react_cur%FOUND THEN
    p_last_call_trans := NVL(carrier_pending_react_rec.ct_objid ,0);
    p_contact_id := TO_CHAR(carrier_pending_react_rec.x_part_inst2contact);
    p_zipcode := NVL(carrier_pending_react_rec.x_zipcode ,'NA');
    p_min := NVL(carrier_pending_react_rec.x_min ,'NA');
    p_errnum := '116';
    p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
    IF p_code_number = '54' THEN
      OPEN get_pending_repl_cur(p_esn);
      FETCH get_pending_repl_cur INTO get_pending_repl_rec;
      IF get_pending_repl_cur%FOUND THEN
        IF (p_source_system = 'WEBCSR' OR p_source_system = 'NETCSR' OR p_source_system = 'TAS' ) -- CR22454 CL SIMPLE MOBILE
        THEN
        --p_redemp_reqd_flg := 0;
        p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name); --CR35310 - Remove default activation promotions.
        END IF;
      END IF;
      CLOSE get_pending_repl_cur;
      IF part_inst_rec.warr_end_date > SYSDATE THEN
      --p_redemp_reqd_flg := 0;
        p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name); --CR35310 - Remove default activation promotions.
      END IF;
    END IF;
    close_open_cursors;
    --CR35310 -Remove default activation promotions
    p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name);
    RETURN;
  END IF;
  OPEN activation_pending_cur(p_esn);
  FETCH activation_pending_cur INTO activation_pending_rec;
  IF activation_pending_cur%FOUND THEN
    p_last_call_trans := NVL(activation_pending_rec.ct_objid ,0);
    p_contact_id := TO_CHAR(activation_pending_rec.x_part_inst2contact);
    p_zipcode := NVL(activation_pending_rec.x_zipcode ,'NA');
    p_min := NVL(activation_pending_rec.x_min ,'NA');
    p_errnum := '117';
    p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
    close_open_cursors;
    RETURN;
  END IF;
  IF (p_code_number = '52') THEN
  OPEN product_part_cur(p_esn);
  FETCH product_part_cur INTO product_part_rec;
  --CR21077 Start Kacosta 06/15/2012
  IF product_part_cur%NOTFOUND THEN
  --
    CLOSE product_part_cur;
    --
    bau_maintenance_pkg.fix_site_part_for_esn(p_esn => p_esn ,p_error_code => p_errnum ,p_error_message => p_errstr);
    --
    OPEN product_part_cur(p_esn);
    FETCH product_part_cur INTO product_part_rec;
  --
  END IF;
  --CR21077 End Kacosta 06/15/2012
  IF product_part_cur%FOUND THEN
  p_zipcode := product_part_rec.x_zipcode;
  p_min := product_part_rec.x_min;
  OPEN new_plan_cur(product_part_rec.objid);
  FETCH new_plan_cur INTO new_plan_rec;
  IF new_plan_cur%FOUND THEN
  p_click_status := 'TRUE';
  END IF;
  CLOSE new_plan_cur;
  OPEN contact_pi_cur(p_esn);
  FETCH contact_pi_cur INTO contact_pi_rec;
  IF contact_pi_cur%FOUND THEN
  p_contact_id := TO_CHAR(contact_pi_rec.objid);
  p_contact_phone := contact_pi_rec.phone;
  p_contact_email := contact_pi_rec.e_mail;
  IF TO_CHAR(contact_pi_rec.x_dateofbirth ,'mm/dd/yyyy') <> '01/01/1753' AND contact_pi_rec.x_dateofbirth IS NOT NULL THEN
  v_extra_info_5 := 1;
  END IF;
  IF contact_pi_rec.x_pin IS NOT NULL THEN
  v_extra_info_4 := 1;
  END IF;
  ELSE
  OPEN contact_sp_cur(product_part_rec.objid);
  FETCH contact_sp_cur INTO contact_sp_rec;
  p_contact_id := TO_CHAR(contact_sp_rec.objid);
  p_contact_phone := contact_sp_rec.phone;
  p_contact_email := contact_sp_rec.e_mail;
  IF TO_CHAR(contact_sp_rec.x_dateofbirth ,'mm/dd/yyyy') <> '01/01/1753' AND contact_sp_rec.x_dateofbirth IS NOT NULL THEN
  v_extra_info_5 := 1;
  END IF;
  IF contact_sp_rec.x_pin IS NOT NULL THEN
  v_extra_info_4 := 1;
  END IF;
  CLOSE contact_sp_cur;
  END IF;
  CLOSE contact_pi_cur;
  OPEN cc_cur(p_contact_id);
  FETCH cc_cur INTO cc_rec;
  CLOSE cc_cur;
  v_cc_count := cc_rec.count_cc;
  p_num_of_cards := v_cc_count;
  OPEN pi_min_cur(product_part_rec.x_min);
  FETCH pi_min_cur INTO pi_min_rec;
  CLOSE pi_min_cur;
  IF ((pi_min_rec.x_port_in = 1) OR (pi_min_rec.x_port_in = 2)) THEN
  v_extra_info_2 := 1;
  ELSE
  v_extra_info_2 := 0;
  END IF;
  p_extra_info := v_extra_info_1 || v_extra_info_2 || v_extra_info_3 || v_extra_info_4 || v_extra_info_5 || v_extra_info_6 || extra_info_7 ||
  -- ota elements:
  v_extra_info_8 || v_extra_info_9 || v_extra_info_10 || v_extra_info_11 || v_extra_info_12 || v_extra_info_13
  --exch element
  --CR17820 Start kacosta 03/28/2012
  -- || v_extra_info_14;
  || v_extra_info_14 || v_extra_info_15|| V_EXTRA_INFO_16;
  --CR17820 End kacosta 03/28/2012
  IF (pi_min_rec.x_part_inst_status = '34') THEN
  IF (p_source_system = 'WEB' OR p_source_system = 'UDP' -- CR28456 Added UDP Source System Changes on 09/26/2014
  OR p_source_system = 'WAP' -- WAP Redemption 12/29/2010
  OR p_source_system = 'APP' -- APP CR21961 IC.
  OR p_source_system = 'TAS' -- CR22454 CL SIMPLE MOBILE
  OR p_source_system = 'WEBCSR' OR p_source_system = 'NETWEB' OR p_source_system = 'NETHANDSET' OR p_source_system = 'NETBATCH' OR p_source_system = 'TRACBATCH' OR p_source_system = 'NETCSR' -- CR11623 BRAND_SEP_IV
  OR p_source_system = 'BATCH') THEN
 p_errnum := '108';
  p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
  ELSE
  p_errnum := '108';
  p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
  close_open_cursors;
  RETURN;
  END IF;
  ELSIF (pi_min_rec.x_part_inst_status = '110') THEN
  IF (p_source_system = 'WEBCSR' OR p_source_system = 'NETHANDSET' OR p_source_system = 'NETBATCH' OR p_source_system = 'TRACBATCH' OR p_source_system = 'NETCSR' -- CR11623 BRAND_SEP_IV
  OR p_source_system = 'TAS' -- CR22454 CL SIMPLE MOBILE
  OR p_source_system = 'BATCH') THEN
  p_errnum := '109';
  p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
  ELSE
  p_errnum := '109';
  p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
  END IF;
  END IF;
  OPEN new_pers_cur(pi_min_rec.objid);
  FETCH new_pers_cur INTO new_pers_rec;
  IF new_pers_cur%FOUND THEN
  p_pers_status := 'FALSE';
  OPEN old_pers_cur(pi_min_rec.objid);
  FETCH old_pers_cur INTO old_pers_rec;
  CLOSE old_pers_cur;
  OPEN pers_lac_cur(pi_min_rec.part_serial_no ,p_phone_technology);
  FETCH pers_lac_cur INTO pers_lac_rec;
  IF pers_lac_cur%NOTFOUND THEN
  CLOSE pers_lac_cur;
  OPEN pers_lac_cur(pi_min_rec.part_serial_no ,'MASTER');
  FETCH pers_lac_cur INTO pers_lac_rec;
  END IF;
  CLOSE pers_lac_cur;
  OPEN getpers2sid_cur(new_pers_rec.objid ,p_phone_technology);
  FETCH getpers2sid_cur INTO getpers2sid_rec;
  IF getpers2sid_cur%NOTFOUND THEN
  CLOSE getpers2sid_cur;
  OPEN getpers2sid_cur(new_pers_rec.objid ,'MASTER');
  FETCH getpers2sid_cur INTO getpers2sid_rec;
  END IF;
  CLOSE getpers2sid_cur;
  IF (pers_lac_rec.x_sid <> getpers2sid_rec.x_sid) THEN
  p_pers_status := 'TRUE';
  END IF;
  --Compare Local SIDs for non-GSM phones
  IF p_phone_technology <> 'GSM' AND p_pers_status <> 'TRUE' THEN
  FOR pers_lac_rec IN pers_lac_cur(pi_min_rec.part_serial_no ,'LOCAL')
  LOOP
  v_old_sid(old_counter) := pers_lac_rec.x_sid;
  old_counter := old_counter + 1;
  END LOOP;
  old_counter := old_counter - 1;
  FOR getpers2sid_rec IN getpers2sid_cur(new_pers_rec.objid ,'LOCAL')
  LOOP
  v_new_sid(new_counter) := getpers2sid_rec.x_sid;
  new_counter := new_counter + 1;
  END LOOP;
  new_counter := new_counter - 1;
  IF old_counter <> new_counter THEN
  p_pers_status := 'TRUE';
  ELSE
  IF new_pers_rec.objid <> old_pers_rec.objid AND new_counter > 0 THEN
  p_pers_status := 'TRUE';
  END IF;
  FOR i IN 1 .. new_counter
  LOOP
  IF v_new_sid(new_counter) <> v_old_sid(new_counter) THEN
  p_pers_status := 'TRUE';
  EXIT;
  END IF;
  END LOOP;
  END IF;
  END IF;
  IF p_pers_status <> 'TRUE' THEN
  IF old_pers_rec.x_restrict_ld <> new_pers_rec.x_restrict_ld OR old_pers_rec.x_restrict_callop <> new_pers_rec.x_restrict_callop OR old_pers_rec.x_restrict_intl <> new_pers_rec.x_restrict_intl OR old_pers_rec.x_restrict_roam <> new_pers_rec.x_restrict_roam THEN
  p_pers_status := 'TRUE';
  END IF;
  IF p_int_dll >= 10 AND (old_pers_rec.x_restrict_inbound <> new_pers_rec.x_restrict_inbound OR old_pers_rec.x_restrict_outbound <> new_pers_rec.x_restrict_outbound) THEN
  p_pers_status := 'TRUE';
  END IF;
  IF (p_int_dll = 6 OR p_int_dll = 8) AND (old_pers_rec.x_soc_id <> new_pers_rec.x_soc_id OR old_pers_rec.x_partner <> new_pers_rec.x_partner OR old_pers_rec.x_favored <> new_pers_rec.x_favored OR old_pers_rec.x_neutral <> new_pers_rec.x_neutral) THEN
  p_pers_status := 'TRUE';
  END IF;
  END IF;
  --If the ESN is not flagged for Personality Update, but old and new personality
  --are different, reset the flag
  IF p_pers_status <> 'TRUE' AND new_pers_rec.objid <> old_pers_rec.objid THEN
  UPDATE sa.gtt_part_inst
  SET part_inst2x_pers = new_pers_rec.objid ,
  part_inst2x_new_pers = NULL
  WHERE part_serial_no = pi_min_rec.part_serial_no;
  UPDATE sa.gtt_part_inst
  SET part_inst2x_pers = new_pers_rec.objid
  WHERE part_serial_no = p_esn;
  --COMMIT;
  END IF;
  ELSE
  p_pers_status := 'FALSE';
  END IF;
  CLOSE new_pers_cur;
  OPEN c_sms_parent(p_phone_technology ,NVL(get_phone_info_rec.x_data_capable ,0));
  FETCH c_sms_parent INTO r_sms_parent;
  IF c_sms_parent%FOUND THEN
  IF p_phone_technology = 'GSM' THEN
  p_sms_flag := 1;
  ELSE
  p_sms_flag := NVL(r_sms_parent.x_sms ,0);
  END IF;
  p_parent_id := NVL(r_sms_parent.x_parent_id ,'NA');
  ELSE
  p_sms_flag := 0;
  p_parent_id := 'NA';
  END IF;
  CLOSE c_sms_parent;
  ELSE
  p_errnum := '119';
  /*CR33864 ATT Carrier switch */
     IF p_errnum ='119' THEN
     sa.SP_SWB_CARR_RATE_PLAN(IP_ESN => p_esn, OP_LAST_RATE_PLAN_SENT => OP_LAST_RATE_PLAN_SENT,OP_IS_SWB_CARR => OP_IS_SWB_CARR,OP_ERROR_CODE => OP_ERROR_CODE1,OP_ERROR_MESSAGE => OP_ERROR_MESSAGE);
  IF OP_IS_SWB_CARR = 'Switch Base' THEN
        FOR product_part_cur_sw_rec in product_part_cur_sw(p_esn)
        LOOP
         IF product_part_cur_sw_rec.part_status='CarrierPending'
         THEN
         p_errnum := '618';
         p_errstr := 'Device Status is CarrierPending';
         END IF;
  END LOOP;
      ELSE
      p_errnum :='119';
      p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
      END IF;
      END IF;
  p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
  close_open_cursors;
  RETURN;
  p_errnum := '106';
  p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
  END IF;
  CLOSE product_part_cur;
  ELSIF (p_code_number = '50' OR p_code_number = '150') THEN
  OPEN get_phone_info_cur(p_esn);
  FETCH get_phone_info_cur INTO get_phone_info_rec;
  CLOSE get_phone_info_cur;
  IF (get_phone_info_rec.x_technology <> 'ANALOG') THEN
  v_tech := 'DIGITAL';
  IF (get_phone_info_rec.prog_type = '2' AND get_phone_info_rec.x_part_inst_status = '50') THEN
  v_tech := 'DIGITAL2';
  END IF;
  END IF;
  IF (get_phone_info_rec.org_id = 'NET10') THEN
  v_tech := 'DIGITAL3';
  IF (get_phone_info_rec.prog_type = '2' AND get_phone_info_rec.x_part_inst_status = '150') THEN
  v_tech := 'DIGITAL4';
  END IF;
  OPEN default_promo_cur(v_tech);
  FETCH default_promo_cur INTO default_promo_rec;
  OPEN activation_promo_used_curs(p_esn);
  FETCH activation_promo_used_curs INTO activation_promo_used_rec;
  IF default_promo_cur%FOUND AND activation_promo_used_curs%NOTFOUND THEN
  p_promo_units := default_promo_rec.x_units;
  p_promo_access_days := default_promo_rec.x_access_days;
  p_pending_red_status := 'TRUE';
  END IF;
  CLOSE default_promo_cur;
  CLOSE activation_promo_used_curs;
  ELSE
  OPEN dealer_promo_cur(site_rec.objid);
  FETCH dealer_promo_cur INTO dealer_promo_rec;
  IF dealer_promo_cur%NOTFOUND THEN
  OPEN default_promo_cur(v_tech);
  FETCH default_promo_cur INTO default_promo_rec;
  OPEN activation_promo_used_curs(p_esn);
  FETCH activation_promo_used_curs INTO activation_promo_used_rec;
  IF default_promo_cur%FOUND AND activation_promo_used_curs%NOTFOUND THEN
  p_promo_units := default_promo_rec.x_units;
  p_promo_access_days := default_promo_rec.x_access_days;
  p_pending_red_status := 'TRUE';
  END IF;
  CLOSE default_promo_cur;
  CLOSE activation_promo_used_curs;
  ELSE
  p_promo_units := dealer_promo_rec.x_units;
  p_promo_access_days := dealer_promo_rec.x_access_days;
  p_pending_red_status := 'TRUE';
  END IF;
  CLOSE dealer_promo_cur;
  END IF;
  OPEN get_oldsitepart_cur(part_inst_rec.objid);
  FETCH get_oldsitepart_cur INTO get_oldsitepart_rec;
  IF get_oldsitepart_cur%FOUND THEN
  p_promo_units := 0;
  p_promo_access_days := 0;
  END IF;
  CLOSE get_oldsitepart_cur;
  OPEN contact_pi_cur(p_esn);
  FETCH contact_pi_cur INTO contact_pi_rec;
  IF contact_pi_cur%FOUND THEN
  p_contact_id := TO_CHAR(contact_pi_rec.objid);
  p_contact_phone := contact_pi_rec.phone;
  p_contact_email := contact_pi_rec.e_mail;
  END IF;
  CLOSE contact_pi_cur;
  OPEN site_part_curs(p_esn);
  FETCH site_part_curs INTO site_part_rec;
  IF site_part_curs%FOUND THEN
  OPEN pi_min_cur(site_part_rec.x_min);
  FETCH pi_min_cur INTO pi_min_rec;
  IF pi_min_rec.x_part_inst_status = '110' THEN
  p_min := site_part_rec.x_min;
  p_errnum := '109';
  p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
  END IF;
  CLOSE pi_min_cur;
  END IF;
  CLOSE site_part_curs;
  ELSE
  IF p_code_number = '54' THEN
  OPEN get_pending_repl_cur(p_esn);
  FETCH get_pending_repl_cur INTO get_pending_repl_rec;
  IF get_pending_repl_cur%FOUND THEN
  IF (p_source_system = 'WEBCSR' OR p_source_system = 'NETCSR' OR p_source_system = 'TAS' ) -- CR22454 CL SIMPLE MOBILE
  THEN
  --p_redemp_reqd_flg := 0;
  p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name); --CR35310 - Remove default activation promotions.
  END IF;
  END IF;
  CLOSE get_pending_repl_cur;
  IF part_inst_rec.warr_end_date > SYSDATE THEN
  --p_redemp_reqd_flg := 0;
  p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name); --CR35310 - Remove default activation promotions.
  END IF;
  END IF;
  FOR get_oldsitepart_rec2 IN get_oldsitepart_cur2(p_esn)
  LOOP
  p_zipcode := get_oldsitepart_rec2.x_zipcode;
  v_temp_sp := TRUE;
  v_sp_objid := get_oldsitepart_rec2.objid;
  EXIT;
  END LOOP;
  IF (v_temp_sp = FALSE) THEN
  p_errnum := '118';
  p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
  close_open_cursors;
  RETURN;
  END IF;
  OPEN contact_pi_cur(p_esn);
  FETCH contact_pi_cur INTO contact_pi_rec;
  IF contact_pi_cur%FOUND THEN
  p_contact_id := TO_CHAR(contact_pi_rec.objid);
  p_contact_phone := contact_pi_rec.phone;
  p_contact_email := contact_pi_rec.e_mail;
  ELSE
  OPEN contact_sp_cur(v_sp_objid);
  FETCH contact_sp_cur INTO contact_sp_rec;
  IF contact_sp_cur%FOUND THEN
  p_contact_id := TO_CHAR(contact_sp_rec.objid);
  p_contact_phone := contact_sp_rec.phone;
  p_contact_email := contact_pi_rec.e_mail;
  ELSE
  p_errnum := '102';
  p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
  close_open_cursors;
  RETURN;
  END IF;
  CLOSE contact_sp_cur;
  END IF;
  CLOSE contact_pi_cur;
  p_click_status := 'TRUE';
  p_pers_status := 'TRUE';
  OPEN site_part_curs(p_esn);
  FETCH site_part_curs INTO site_part_rec;
  IF site_part_curs%FOUND THEN
  OPEN pi_min_cur(site_part_rec.x_min);
  FETCH pi_min_cur INTO pi_min_rec;
  IF pi_min_rec.x_part_inst_status = '110' THEN
  p_min := site_part_rec.x_min;
  p_errnum := '109';
  p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
  END IF;
  CLOSE pi_min_cur;
  END IF;
  CLOSE site_part_curs;
  END IF;
  ----- SAFELINK RE-QUALIFICATIONS 8/24/11
  IF cur_safelink_esn%FOUND THEN
  p_safelink_esn := 'T';
  IF p_code_number IN ('53' ,'54') AND rec_safelink_esn.x_current_active IS NULL THEN
  --p_redemp_reqd_flg := 0;
  p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name); --CR35310 - Remove default activation promotions.
  END IF;
  ----- SAFELINK RE-QUALIFICATIONS 8/24/11 END
  END IF;
  --
  -- OTA validation:
  --
  /*****************************************************
  | Is OTA Activation in process: |
  | If YES - find out if ESN is OTA allowed |
  | If NOT - evaluate the following: |
  | 1)is ESN active and is esn OTA allowed |
  | 2)is carrier OTA enabled |
  | 3)what features on the pho
  | 3)what features on the phone are enabled |
  | NOTE: all output parameters for OTA |
  | validation are initialized right at |
  | the start of the procedure |
  *****************************************************/
  -- is OTA Activation in process?
  FOR cur_is_ota_activation_rec IN cur_is_ota_activation
  LOOP
  b_ota_activation := TRUE;
  IF UPPER(NVL(cur_is_ota_activation_rec.x_ota_allowed ,'N')) = 'Y' THEN
  v_extra_info_9 := 1;
  END IF;
  END LOOP;
  IF NOT b_ota_activation THEN
  -- 1) is ESN active
  FOR cur_is_esn_active_rec IN cur_is_esn_active
  LOOP
  v_extra_info_8 := 1;
  IF UPPER(NVL(cur_is_esn_active_rec.x_ota_allowed ,'N')) = 'Y' THEN
  v_extra_info_9 := 1;
  END IF;
  END LOOP;
  -- 2) is carrier OTA enabled
  FOR cur_is_carrier_ota_type_rec IN cur_is_carrier_ota_type
  LOOP
  IF UPPER(NVL(cur_is_carrier_ota_type_rec.x_ota_carrier ,'N')) = 'Y' THEN
  v_extra_info_10 := 1;
  END IF;
  END LOOP;
  -- 3) what features on the phone are enabled
  -- this is the assumption for now:
  -- if handset is unlocked we will proceed with sending the PSMS message to the phone
  FOR cur_get_ota_features_rec IN cur_get_ota_features
  LOOP
  IF UPPER(NVL(cur_get_ota_features_rec.x_handset_lock ,'N')) = 'Y' THEN
  v_extra_info_11 := 0;
  END IF;
  IF UPPER(NVL(cur_get_ota_features_rec.x_redemption_menu ,'N')) = 'Y' THEN
  v_extra_info_12 := 1;
  END IF;
  IF cur_get_ota_features_rec.x_psms_destination_addr IS NOT NULL THEN
  v_extra_info_13 := 1;
  END IF;
  END LOOP;
  END IF;
  -- NOT b_ota_activation
  p_extra_info := v_extra_info_1 || v_extra_info_2 || v_extra_info_3 || v_extra_info_4 || v_extra_info_5 || v_extra_info_6 || extra_info_7 ||
  -- ota elements:
  v_extra_info_8 || v_extra_info_9 || v_extra_info_10 || v_extra_info_11 || v_extra_info_12 || v_extra_info_13
  --exch element
  --CR17820 Start kacosta 03/28/2012
  -- || v_extra_info_14;
  || v_extra_info_14 || v_extra_info_15|| V_EXTRA_INFO_16;
  --CR17820 End kacosta 03/28/2012
  OPEN get_pending_repl_cur(p_esn);
  FETCH get_pending_repl_cur INTO get_pending_repl_rec;
  IF get_pending_repl_cur%FOUND THEN
  v_repl_pend_flag := 1;
  ELSE
  v_repl_pend_flag := 0;
  END IF;
  CLOSE get_pending_repl_cur;
  OPEN get_pending_redemptions_cur(p_esn);
  FETCH get_pending_redemptions_cur INTO get_pending_redemptions_rec;
  IF get_pending_redemptions_cur%FOUND OR v_repl_pend_flag = 1 THEN
  IF (p_source_system = 'WEBCSR' OR p_source_system = 'NETCSR' OR p_source_system = 'NETBATCH' OR p_source_system = 'TRACBATCH' OR p_source_system = 'WEB' OR p_source_system = 'UDP' -- CR28456 Added UDP Source System Changes on 09/26/2014
  OR p_source_system = 'TAS' -- CR22454 CL SIMPLE MOBILE
  OR p_source_system = 'NETWEB' -- CR22198
  OR p_source_system = 'BATCH') -- CR11623 BRAND_SEP_IV
  THEN
  --p_redemp_reqd_flg := 0;
  p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name); --CR35310 - Remove default activation promotions.
  END IF;
  IF p_source_system IN ('WAP', -- CR21961 IC
  -- 'APP', -- CR 35913: APP value excluded from the list
  --,'WEB' --CR22198
  --,'NETWEB' --CR22198
  'IVR', 'NETIVR', 'NETHANDSET') -- WAP Redemption 12/29/2010
  THEN
  p_errnum := '110';
  p_errstr := get_code_fun('VALIDATE_PHONE_PRC' ,p_errnum ,'ENGLISH');
  close_open_cursors;
  --CR35310 -Remove default activation promotions
  p_redemp_reqd_flg := get_redemption_flag(p_esn,p_brand_name);
  RETURN;
  END IF;
  END IF;
  CLOSE GET_PENDING_REDEMPTIONS_CUR;
  --CR25490 B2B Changed by CPannala

  V_EXTRA_INFO_16 := B2B_PKG.IS_B2B(IP_TYPE => 'ESN', IP_VALUE => P_ESN, IP_BRAND => P_BRAND_NAME,--Only needed if ip_type = email
  OP_ERR_NUM => P_ERRNUM, OP_ERR_MSG => P_ERRSTR);
  p_extra_info := v_extra_info_1 || v_extra_info_2 || v_extra_info_3 || v_extra_info_4 || v_extra_info_5 || v_extra_info_6 || extra_info_7 || V_EXTRA_INFO_8 || V_EXTRA_INFO_9 || V_EXTRA_INFO_10 || V_EXTRA_INFO_11 || V_EXTRA_INFO_12 || V_EXTRA_INFO_13 || v_extra_info_14 || v_extra_info_15|| V_EXTRA_INFO_16;
  --
  OPEN get_phone_info_cur_new (p_esn);
  FETCH get_phone_info_cur_new INTO get_phone_info_new_rec;
  IF get_phone_info_cur_new%FOUND THEN
    OPEN c_queued_pin (p_esn);
    FETCH c_queued_pin INTO rec_queued_pin;
    CLOSE c_queued_pin;
    IF rec_queued_pin.pin_part_num = NVL (get_phone_info_new_rec.x_card_plan, 'X') OR NVL (rec_queued_pin.part_type, 'X') = 'FREE' THEN
      p_preactv_benefits          := 'Y';
    END IF;
  END IF;
  CLOSE get_phone_info_cur_new;
--
END validate_pre_posa_phone;
--
-- CR43088 WARP 2.0
PROCEDURE unbrand_esn
(
ip_esn          IN  VARCHAR2,
ip_bus_org_id   IN  VARCHAR2,
ip_user         IN  VARCHAR2,
op_error_code   OUT VARCHAR2,
op_error_msg    OUT VARCHAR2
)
IS
CURSOR validate_brand (ip_org_id VARCHAR2)
IS
   SELECT objid,
          org_id ,
          SUBSTR(loc_type,1,2) prefix_pn
   FROM table_bus_org
   WHERE org_id = ip_org_id ;

  validate_brand_r validate_brand%rowtype ;

  CURSOR branded_cur (ip_esn VARCHAR2)
  IS
    SELECT pi.part_serial_no,
           ml.objid ml_objid,
           pn.part_number,
           pn.part_num2bus_org
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn
    WHERE pi.n_part_inst2part_mod = ml.objid
    AND   ml.part_info2part_num   = pn.objid
    AND   pi.x_part_inst_status|| '' IN ('50','59','150') --CR44390 Include status 59 to unbrand.
    AND   pi.part_serial_no       = ip_esn ;

  branded_rec branded_cur%rowtype ;

CURSOR get_mod_level (l_generic_part_num VARCHAR2)
IS
   SELECT ml.objid
   FROM table_mod_level ml,
        table_part_num pn
   WHERE ml.part_info2part_num = pn.objid
   AND pn.part_number          = l_generic_part_num
   AND pn.x_product_code='GP' ; --get generic part number

  get_mod_level_r get_mod_level%rowtype ;

  l_new_mod_level NUMBER ;
  l_generic_part_num  VARCHAR2(30) ;
  l_action        VARCHAR2(50) ;
  l_user          VARCHAR2(30) := NVL(lower(ip_user),'sa') ;
BEGIN
  op_error_code        := '0';
  op_error_msg         := 'ESN Brand Rollbacked';

  l_new_mod_level  :=  0 ;
  l_generic_part_num   := NULL ;
  l_action         := 'Validating the Brand';

  OPEN validate_brand (ip_bus_org_id);
  FETCH validate_brand INTO validate_brand_r;

  IF validate_brand%notfound THEN
    op_error_code := '131';
    op_error_msg  := 'Cant complete rollback branding , Check the Org ID';
    CLOSE validate_brand ;
    RETURN ;
  END IF ;

  CLOSE validate_brand ;

  l_action := 'Obtaining the part number';

  OPEN branded_cur (ip_esn) ;
  FETCH branded_cur INTO branded_rec ;

  IF branded_cur%notfound THEN
    op_error_code := '132';
    op_error_msg  := 'Cant complete rollback branding , Check the ESN';
    CLOSE branded_cur ;
    RETURN ;
  END IF ;

  l_action := 'Obtaining the Mod Level';

  --CR44390 Derive the correct Generic PArtnumber instead of branded part number.
  --Generic Part number should be derived for PRefix GP.  not for the prefix from Validate_brand, which is incorrect.
  -- using the validate_brand.prefix will always make the Get_mod_level to fail

  --l_generic_part_num := REPLACE(branded_rec.part_number,SUBSTR(branded_rec.part_number,1,2),validate_brand_r.prefix_pn) ;
  l_generic_part_num := REPLACE(branded_rec.part_number,SUBSTR(branded_rec.part_number,1,2),'GP') ;

  OPEN get_mod_level (l_generic_part_num);
  FETCH get_mod_level INTO get_mod_level_r;

  IF get_mod_level%notfound THEN
   op_error_code := '133';
   op_error_msg  := 'Cant complete rollback branding , Check the Part Number';
   CLOSE get_mod_level ;
   RETURN ;
  END IF ;

  CLOSE get_mod_level ;

  l_action := 'updating table_part_inst';

  UPDATE table_part_inst
  SET n_part_inst2part_mod = get_mod_level_r.objid,
      x_part_inst2contact  = NULL
  WHERE part_serial_no = ip_esn ;

  DELETE
  FROM table_x_contact_part_inst
  WHERE x_contact_part_inst2part_inst IN
  (SELECT objid FROM table_part_inst WHERE part_serial_no = ip_esn) ;

-- COMMIT ;
/*
  l_action := 'Creating the log';

  INSERT INTO x_branded_trans
  (
   objid,
   tf_part_num_parent,
   tf_serial_num,
   tf_extract_flag,
   tf_extract_date,
   log_date
  )
  VALUES
  (
   sequ_branded_trans.NEXTVAL,
   l_generic_part_num,
   ip_esn,
   'N',
   NULL,
   SYSDATE
  ) ;
  COMMIT ;*/

/* IF op_result = '1' THEN
     op_result :='0' ;
  END IF ;*/

EXCEPTION
WHEN OTHERS THEN
  IF branded_cur%isopen THEN
  CLOSE branded_cur ;
  END IF ;
  IF validate_brand%isopen THEN
  CLOSE validate_brand ;
  END IF ;
  IF get_mod_level%isopen THEN
  CLOSE get_mod_level ;
  END IF ;
  op_error_code := '130';
  op_error_msg  := 'Cant complete Rollback branding';
END unbrand_esn;
-- CR43088 WARP 2.0

--CR44729 GoSmart --Start
PROCEDURE get_sub_brand(i_esn       IN  VARCHAR2,
                        o_sub_brand OUT VARCHAR2,
                        o_errnum    OUT NUMBER  ,
                        o_errstr    OUT VARCHAR2
                                                                                                )
IS
c customer_Type := customer_Type ();

BEGIN -- Main Section
  c.esn       := i_esn;
  c.sub_brand := c.get_sub_brand;

  --Return output
  o_sub_brand := c.sub_brand;

EXCEPTION
  WHEN OTHERS THEN
                   o_errnum := -1;
                   o_errstr := 'Error while retrieve sub brand for given ESN: '||SUBSTR(SQLERRM,1,100);
                   RETURN;
END;

PROCEDURE get_sub_brand(i_contact_objid IN   NUMBER  ,
                        o_sub_brand     OUT  VARCHAR2,
                        o_errnum        OUT  NUMBER  ,
                        o_errstr        OUT  VARCHAR2
                                                                                                )
IS
c customer_Type := customer_Type ();
--l_esn VARCHAR2(30);

BEGIN -- Main Section

/*    SELECT pi.part_serial_no
                INTO   l_esn
    FROM   table_contact             tc,
                       table_x_contact_part_inst cpi,
           table_part_inst pi
    WHERE  1 = 1
    AND    tc.objid                          = i_contact_objid
                AND    tc.objid                          = cpi.x_contact_part_inst2contact
                AND    cpi.x_is_default                  = '1'
                AND    cpi.x_contact_part_inst2part_inst = pi.objid;

    c.esn       := l_esn;
    c.sub_brand := c.get_sub_brand;

                --Return output
    o_sub_brand := c.sub_brand;
*/
-- get ESN based on i_contact_objid
c           := c.get_contact_add_info ( i_contact_objid => i_contact_objid);
c.sub_brand := c.get_sub_brand;

  --Return output
  o_sub_brand := c.sub_brand;


EXCEPTION
   WHEN OTHERS THEN
                   o_errnum := -1;
                   o_errstr := 'Error while retrieve sub brand for given Contact OBJID: '||SUBSTR(SQLERRM,1,100);
                   RETURN;

END;

PROCEDURE get_sub_brand(i_login_name IN  VARCHAR2,
                        o_sub_brand  OUT VARCHAR2,
                        o_errnum     OUT NUMBER  ,
                        o_errstr     OUT VARCHAR2
                                                                                                )
IS
c customer_Type := customer_Type ();
l_esn VARCHAR2(30);

BEGIN -- Main Section

    SELECT pi.part_serial_no
                INTO   l_esn
    FROM   table_web_user            wu,
                       table_x_contact_part_inst cpi,
           table_part_inst pi
    WHERE  1 = 1
    AND    wu.login_name                     = i_login_name
                AND    wu.web_user2contact               = cpi.x_contact_part_inst2contact
                AND    cpi.x_is_default                  = '1'
                AND    cpi.x_contact_part_inst2part_inst = pi.objid;

    c.esn       := l_esn;
    c.sub_brand := c.get_sub_brand;

                --Return output
    o_sub_brand := c.sub_brand;

EXCEPTION
   WHEN OTHERS THEN
                   o_errnum := -1;
                   o_errstr := 'Error while retrieve sub brand for given Login name: '||SUBSTR(SQLERRM,1,100);
                   RETURN;

END;
--CR44729 GoSmart --End

--CR47564 WFM -- Start
PROCEDURE get_esn_plan_details( op_esn_plan_partnum_det_tab IN OUT ESN_PLAN_PARTNUM_DET_TAB,
                                o_err_code                  OUT VARCHAR2,
                                o_err_msg                   OUT VARCHAR2)
IS
  CURSOR c_part_num_det (c_part_num VARCHAR2,c_part_class VARCHAR2)
  IS
    SELECT service_plan_objid,
           mkt_name AS service_plan_name,
                                   mv.plan_purchase_part_number,
                                   pc.name part_class,
                                   mv.service_plan_group
    FROM   service_plan_feat_pivot_mv mv,
           table_part_num pn,
           table_part_class pc
    WHERE  (mv.plan_purchase_part_number=c_part_num OR pc.name = c_part_class)
       AND pn.part_number                 = mv.plan_purchase_part_number
       AND pc.objid                       = pn.part_num2part_class;

    CURSOR c_vas_part_det(c_plan_purchase_part_number  VARCHAR2, c_plan_part_class VARCHAR2  )
    IS
      SELECT vas_service_id,
             vas_name,
             vi.VAS_APP_CARD,
             vi.VAS_CARD_CLASS,
            'ADD_ON_ILD' service_plan_group
      FROM vas_programs_view vi
      WHERE ( vi.VAS_APP_CARD = c_plan_purchase_part_number
      OR vi.VAS_CARD_CLASS    = c_plan_part_class )
      AND SYSDATE BETWEEN vas_start_date AND vas_end_date;
c_part_num_det_rec c_part_num_det%ROWTYPE;
cst sa.customer_type := sa.customer_type();
 c_vas_part_det_rec c_vas_part_det%ROWTYPE;  -- Defined for --CR48260 update existing procedures  to return service plan group as ADD ON ILD for VAS pins/part number

BEGIN
  -- Input Validation

   IF  op_esn_plan_partnum_det_tab IS NULL THEN
    o_err_code := '101';
    o_err_msg := 'ESN Plan Part num details list not passed';
    RETURN;
  END IF;

  IF op_esn_plan_partnum_det_tab.count = 0  THEN
    o_err_code := '101';
    o_err_msg := 'ESN Plan Part num details list has no input value';
    RETURN;
  END IF;

  -- Update op_esn_plan_partnum_det_tab variables
  FOR i IN op_esn_plan_partnum_det_tab.first .. op_esn_plan_partnum_det_tab.last
  LOOP
    Op_esn_plan_partnum_det_tab(i).error_code    := '0';
    Op_esn_plan_partnum_det_tab(i).error_message := 'SUCCESS';

    --Get Plan details
    IF Op_esn_plan_partnum_det_tab(i).plan_purchase_part_number IS NOT NULL OR op_esn_plan_partnum_det_tab(i).plan_part_class  IS NOT NULL THEN
       OPEN c_part_num_det (Op_esn_plan_partnum_det_tab(i).plan_purchase_part_number,
                                        Op_esn_plan_partnum_det_tab(i).plan_part_class );
       FETCH c_part_num_det INTO  c_part_num_det_rec;

       IF c_part_num_det%FOUND THEN
         Op_esn_plan_partnum_det_tab(i).service_plan_objid         := c_part_num_det_rec.service_plan_objid;
         Op_esn_plan_partnum_det_tab(i).service_plan_name          := c_part_num_det_rec.service_plan_name;
                     Op_esn_plan_partnum_det_tab(i).plan_purchase_part_number  := c_part_num_det_rec.plan_purchase_part_number;
                     Op_esn_plan_partnum_det_tab(i).plan_part_class            := c_part_num_det_rec.part_class;
         Op_esn_plan_partnum_det_tab(i).service_plan_group         := c_part_num_det_rec.service_plan_group;
                   ELSE
         OPEN c_vas_part_det (Op_esn_plan_partnum_det_tab(i).plan_purchase_part_number,
                             Op_esn_plan_partnum_det_tab(i).plan_part_class );
         FETCH c_vas_part_det INTO c_vas_part_det_rec;
         IF c_vas_part_det%FOUND THEN
           Op_esn_plan_partnum_det_tab(i).service_plan_objid         := c_vas_part_det_rec.vas_service_id;
           Op_esn_plan_partnum_det_tab(i).service_plan_name          := c_vas_part_det_rec.vas_name;
           Op_esn_plan_partnum_det_tab(i).plan_purchase_part_number  := c_vas_part_det_rec.vas_app_card;
           Op_esn_plan_partnum_det_tab(i).plan_part_class            := c_vas_part_det_rec.vas_card_class;
           Op_esn_plan_partnum_det_tab(i).service_plan_group         := c_vas_part_det_rec.service_plan_group;
         ELSE
                     Op_esn_plan_partnum_det_tab(i).error_code    := '150';
         Op_esn_plan_partnum_det_tab(i).error_message := 'Plan Details not found';
         END IF;
       CLOSE c_vas_part_det;
       END IF;

       CLOSE c_part_num_det;
      END IF;

                  --Get ESN Part inst OBJID
                  IF Op_esn_plan_partnum_det_tab(i).esn IS NOT NULL THEN
                     Op_esn_plan_partnum_det_tab(i).esn_part_inst_objid := cst.get_esn_part_inst_objid (i_esn => Op_esn_plan_partnum_det_tab(i).esn );
                  END IF;

    dbms_output.Put_line('ESN                       : '    ||op_esn_plan_partnum_det_tab(i).esn);
    dbms_output.Put_line('Plan_purchase_part_number : '    ||op_esn_plan_partnum_det_tab(i).plan_purchase_part_number);
                dbms_output.Put_line('plan_part_class           : '    ||op_esn_plan_partnum_det_tab(i).plan_part_class);
    dbms_output.Put_line('Service_plan_objid        : '    ||op_esn_plan_partnum_det_tab(i).service_plan_objid );
    dbms_output.Put_line('Service_plan_name         : '    ||op_esn_plan_partnum_det_tab(i).service_plan_name );
    dbms_output.Put_line('Esn_part_inst_objid       : '    ||op_esn_plan_partnum_det_tab(i).esn_part_inst_objid );
    dbms_output.Put_line('service_plan_group        : '    ||op_esn_plan_partnum_det_tab(i).service_plan_group );
  END LOOP;
  o_err_code := '0';
  o_err_msg  := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
  o_err_code := '99';
  o_err_msg := 'Failed in when others'  || Substr(SQLERRM, 1,200);
END get_esn_plan_details;


PROCEDURE GET_ESN_PIN_DETAILS(
    op_esn_pin_smp_tab IN OUT ESN_PIN_SMP_DET_TAB,
    o_err_code OUT VARCHAR2,
    o_err_msg OUT VARCHAR2 )
IS
  -- initializing  customer type
  cst sa.customer_type := sa.customer_type();
  l_err_code VARCHAR2(50);
  l_err_msg  VARCHAR2(1000);
  CURSOR c_part_num_det (c_part_num VARCHAR2,c_part_class VARCHAR2)
  IS
    SELECT service_plan_objid,
           mkt_name AS service_plan_name,
                                   mv.plan_purchase_part_number,
                                   pc.name part_class,
                                   mv.service_plan_group
    FROM   service_plan_feat_pivot_mv mv,
           table_part_num pn,
           table_part_class pc
    WHERE  (mv.plan_purchase_part_number=c_part_num OR pc.name = c_part_class)
       AND pn.part_number                 = mv.plan_purchase_part_number
       AND pc.objid                       = pn.part_num2part_class;

c_part_num_det_rec c_part_num_det%ROWTYPE;
 CURSOR c_vas_details(c_pin VARCHAR2)
 IS
   SELECT vi.vas_service_id,
          vi.vas_name,
          vi.VAS_APP_CARD,
          vi.VAS_CARD_CLASS,
          'ADD_ON_ILD' service_plan_group
   FROM vas_programs_view vi
   WHERE vi.vas_card_class = bau_util_pkg.get_pin_part_class(c_pin)
   AND SYSDATE BETWEEN vas_start_date AND vas_end_date;
c_vas_details_rec	  c_vas_details%ROWTYPE;

CURSOR c_bus_org (c_part_num VARCHAR2)  IS
                SELECT part_num2bus_org,
                  org.org_id,
                  org.brm_notification_flag,
                  pc.name part_class
                FROM table_part_num pn,
                  table_bus_org org,
                  table_part_class pc
                WHERE pn.part_num2bus_org     = org.objid
                AND pc.objid                  = pn.part_num2part_class
                AND org.brm_notification_flag = 'Y'
                AND pn.s_part_number          = c_part_num;

c_bus_org_rec c_bus_org%ROWTYPE;

BEGIN

  -- Input Validation

  IF   op_esn_pin_smp_tab IS NULL THEN
    o_err_code               := '113';
    o_err_msg                := 'ESN PIN detail list not passed';
    RETURN;
  END IF;

  IF op_esn_pin_smp_tab.count = 0  THEN
    o_err_code               := '113';
    o_err_msg                := 'ESN PIN detail list has no input value';
    RETURN;
  END IF;
  -- Update op_esn_pin_smp_tab variables
  FOR i IN 1 .. op_esn_pin_smp_tab.count
  LOOP
    BEGIN
                  --Initialize
                  op_esn_pin_smp_tab(i).error_code := '0';
                  op_esn_pin_smp_tab(i).error_message := 'SUCCESS';
                  l_err_code :=NULL;
                  l_err_msg  :=NULL;

                  --Get ESN part inst objid
                  IF op_esn_pin_smp_tab(i).esn IS NOT NULL THEN
                     op_esn_pin_smp_tab(i).esn_objid := cst.get_esn_part_inst_objid (i_esn => op_esn_pin_smp_tab(i).esn );
                  END IF;

                  IF op_esn_pin_smp_tab(i).smp IS NOT NULL THEN
                     op_esn_pin_smp_tab(i).pin := cst.convert_smp_to_pin( i_smp => op_esn_pin_smp_tab(i).smp );
                  END IF;

                  IF op_esn_pin_smp_tab(i).pin IS NOT NULL THEN

                                -- convert the pin
                                IF op_esn_pin_smp_tab(i).smp IS NULL THEN
            op_esn_pin_smp_tab(i).smp := cst.convert_pin_to_smp( i_red_card_code => op_esn_pin_smp_tab(i).pin );
                                END IF;
         --Get plan part number based on PIN
         sp_mobile_account.get_partnumber_by_pin (i_pin         => op_esn_pin_smp_tab(i).pin,
                                                              o_part_number =>  op_esn_pin_smp_tab(i).service_plan_part_number,
                                                                                                                                                                                      o_err_num     => l_err_code,
                                                                                                                                                                                      o_err_msg     => l_err_msg);
        IF l_err_code <> '0' THEN --get_partnumber_by_pin failed
                          op_esn_pin_smp_tab(i).error_code    := l_err_code;
                                      op_esn_pin_smp_tab(i).error_message := l_err_msg;
        END IF;
                  END IF;

                  IF op_esn_pin_smp_tab(i).service_plan_part_class_name IS  NULL AND op_esn_pin_smp_tab(i).service_plan_part_number IS NOT NULL THEN
                     OPEN c_bus_org (op_esn_pin_smp_tab(i).service_plan_part_number);
                                FETCH  c_bus_org INTO c_bus_org_rec;
                                IF c_bus_org%FOUND THEN
                                    op_esn_pin_smp_tab(i).service_plan_part_class_name := c_bus_org_rec.part_class;
                                END IF;
         CLOSE          c_bus_org;
                  END IF;

                  --Get part class and SP details based on part number. Sometime input is only part class, then we need to send part num
      IF op_esn_pin_smp_tab(i).service_plan_part_number IS NOT NULL OR op_esn_pin_smp_tab(i).service_plan_part_class_name IS NOT NULL THEN
        OPEN c_part_num_det (op_esn_pin_smp_tab(i).service_plan_part_number,
                                          op_esn_pin_smp_tab(i).service_plan_part_class_name );
        FETCH c_part_num_det INTO  c_part_num_det_rec;

        IF c_part_num_det%FOUND THEN
          op_esn_pin_smp_tab(i).service_plan_name                   := c_part_num_det_rec.service_plan_name;
          --CR49087 - Fix for defect#24117 start
          --op_esn_pin_smp_tab(i).service_plan_part_number            := NVL(op_esn_pin_smp_tab(i).service_plan_part_number,c_part_num_det_rec.plan_purchase_part_number);
          op_esn_pin_smp_tab(i).service_plan_part_number            := c_part_num_det_rec.plan_purchase_part_number;
          --CR49087 - Fix for defect#24117 end
         op_esn_pin_smp_tab(i).service_plan_part_class_name        := NVL(op_esn_pin_smp_tab(i).service_plan_part_class_name,c_part_num_det_rec.part_class);
          op_esn_pin_smp_tab(i).service_plan_group                  := c_part_num_det_rec.service_plan_group;
        ELSE
	    OPEN c_vas_details(op_esn_pin_smp_tab(i).pin);
	    FETCH c_vas_details into c_vas_details_rec;
	      IF c_vas_details%FOUND THEN
          op_esn_pin_smp_tab(i).service_plan_group                  := c_vas_details_rec.service_plan_group;
          op_esn_pin_smp_tab(i).service_plan_name                   := c_vas_details_rec.vas_name;
          op_esn_pin_smp_tab(i).service_plan_part_class_name        := c_vas_details_rec.vas_card_class;
          op_esn_pin_smp_tab(i).service_plan_part_number            := c_vas_details_rec.vas_app_card;
        ELSE
                      op_esn_pin_smp_tab(i).error_code    := '102';
                                  op_esn_pin_smp_tab(i).error_message := 'Plan Details not found';
        END IF;--CR48260
	    CLOSE c_vas_details;
        END IF;

        CLOSE c_part_num_det;
                  END IF;

    --inside Loop
    EXCEPTION
      WHEN OTHERS THEN
            op_esn_pin_smp_tab(i).error_code := sqlcode;
                                                op_esn_pin_smp_tab(i).error_message := SUBSTR(SQLERRM, 1,200);
    END;
  END LOOP;
  o_err_code := '0';
  o_err_msg  := 'SUCCESS';

  --Exception Block
EXCEPTION
WHEN OTHERS THEN
  o_err_code := '99';
  o_err_msg  := 'Failed in when others' || SUBSTR(SQLERRM, 1,200);
END GET_ESN_PIN_DETAILS;

--CR47564 WFM -- END

   --CR47564 - New Overloading procedure Validate_phone_prc with security_pin as a new out param
   PROCEDURE Validate_phone_prc (p_esn IN VARCHAR2
                                ,p_source_system IN VARCHAR2
                                ,p_brand_name IN VARCHAR2
                                ,p_part_inst_objid OUT VARCHAR2
                                ,p_code_number OUT VARCHAR2
                                ,p_code_name OUT VARCHAR2
                                ,p_redemp_reqd_flg OUT NUMBER
                                ,p_warr_end_date OUT VARCHAR2
                                ,p_phone_model OUT VARCHAR2
                                ,p_phone_technology OUT VARCHAR2
                                ,p_phone_description OUT VARCHAR2
                                ,p_esn_brand OUT VARCHAR2
                                ,p_zipcode OUT VARCHAR2
                                ,p_pending_red_status OUT VARCHAR2
                                ,p_click_status OUT VARCHAR2
                                ,p_promo_units OUT NUMBER
                                ,p_promo_access_days OUT NUMBER
                                ,p_num_of_cards OUT NUMBER
                                ,p_pers_status OUT VARCHAR2
                                ,p_contact_id OUT VARCHAR2
                                ,p_contact_phone OUT VARCHAR2
                                ,p_errnum OUT VARCHAR2
                                ,p_errstr OUT VARCHAR2
                                ,p_sms_flag OUT NUMBER
                                ,p_part_class OUT VARCHAR2
                                ,p_parent_id OUT VARCHAR2
                                ,p_extra_info OUT VARCHAR2
                                ,p_int_dll OUT NUMBER
                                ,p_contact_email OUT VARCHAR2
                                ,p_min OUT VARCHAR2
                                ,p_manufacturer OUT VARCHAR2
                                ,p_seq OUT NUMBER
                                ,p_iccid OUT VARCHAR2
                                ,p_iccid_flag OUT VARCHAR2
                                ,p_last_call_trans OUT VARCHAR2
                                ,p_safelink_esn OUT VARCHAR2
                                ,p_preactv_benefits OUT VARCHAR2
                                ,p_sub_brand OUT VARCHAR2
                                ,p_security_pin OUT VARCHAR2
                                                                                                                                ,p_account_pin  OUT VARCHAR2
                                                                                                                                ,p_account_status OUT VARCHAR2           )
   AS
      lv_security_pin   table_x_contact_add_info.x_pin%TYPE;
                  lv_account_pin    table_x_contact_add_info.x_pin%TYPE;
                  lv_bus_org_id     table_bus_org.org_id%TYPE;
                  lv_login_name     table_web_user.s_login_name%TYPE;
   BEGIN
      --Execute the original procedure
      BEGIN
         phone_pkg.validate_phone_prc(p_esn                    => p_esn
                                     ,p_source_system          => p_source_system
                                     ,p_brand_name             => p_brand_name
                                     ,p_part_inst_objid        => p_part_inst_objid
                                     ,p_code_number            => p_code_number
                                     ,p_code_name              => p_code_name
                                     ,p_redemp_reqd_flg        => p_redemp_reqd_flg
                                     ,p_warr_end_date          => p_warr_end_date
                                     ,p_phone_model            => p_phone_model
                                     ,p_phone_technology       => p_phone_technology
                                     ,p_phone_description      => p_phone_description
                                     ,p_esn_brand              => p_esn_brand
                                     ,p_zipcode                => p_zipcode
                                     ,p_pending_red_status     => p_pending_red_status
                                     ,p_click_status           => p_click_status
                                     ,p_promo_units            => p_promo_units
                                     ,p_promo_access_days      => p_promo_access_days
                                     ,p_num_of_cards           => p_num_of_cards
                                     ,p_pers_status            => p_pers_status
                                     ,p_contact_id             => p_contact_id
                                     ,p_contact_phone          => p_contact_phone
                                     ,p_errnum                 => p_errnum
                                     ,p_errstr                 => p_errstr
                                     ,p_sms_flag               => p_sms_flag
                                     ,p_part_class             => p_part_class
                                     ,p_parent_id              => p_parent_id
                                     ,p_extra_info             => p_extra_info
                                     ,p_int_dll                => p_int_dll
                                     ,p_contact_email          => p_contact_email
                                     ,p_min                    => p_min
                                     ,p_manufacturer           => p_manufacturer
                                     ,p_seq                    => p_seq
                                     ,p_iccid                  => p_iccid
                                     ,p_iccid_flag             => p_iccid_flag
                                     ,p_last_call_trans        => p_last_call_trans
                                     ,p_safelink_esn           => p_safelink_esn
                                     ,p_preactv_benefits                                 => p_preactv_benefits
                                     ,p_sub_brand                                                                              => p_sub_brand);
      EXCEPTION
         WHEN OTHERS
         THEN
            toss_util_pkg.insert_error_tab_proc (ip_action => p_esn||' ; '||p_source_system||' ; '||p_brand_name
                                                ,ip_key => SUBSTR (p_esn || ';', 1, 50)
                                                ,ip_program_name => 'PHONE_PKG.VALIDATE_PHONE_PRC - WFM'
                                                ,ip_error_text => SUBSTR (SQLERRM, 1, 300));
      END;

      BEGIN
      --Getting Phone security PIN
      SELECT sa.customer_info.get_contact_add_info (i_esn=>p_esn,i_value => 'PIN')
        INTO lv_security_pin
       FROM dual;
      EXCEPTION
        WHEN OTHERS
        THEN
           lv_security_pin := NULL;
      END;

      p_security_pin := lv_security_pin;

      BEGIN
        --Getting Login Name
        SELECT sa.customer_info.get_web_user_attributes (i_esn=> p_esn, i_value => 'LOGIN_NAME')
        INTO lv_login_name
        FROM dual;

        --Getting Bus org
        SELECT sa.customer_info.get_bus_org_id (i_esn=> p_esn)
        INTO lv_bus_org_id
        FROM dual;

        --Getting ACCOUNT PIN
        SELECT sa.customer_info.retrieve_login (i_login_name=>lv_login_name,i_bus_org_id => lv_bus_org_id, i_value => 'ACCOUNT_PIN')
        INTO lv_account_pin
        FROM dual;
      EXCEPTION
        WHEN OTHERS
        THEN
          lv_account_pin := NULL;
      END;

       --IF sa.migration_pkg.get_legacy_flag(i_sim => p_iccid ) = 'Y' THEN
       --   ln_err_num := '200';
       --   lv_err_msg := 'SIM NOT MIGRATED';
       --END IF;

      p_account_pin := lv_account_pin;
      p_account_status := sa.Account_Maintenance_pkg.get_account_status( I_ESN => p_esn);

   END validate_phone_prc;

PROCEDURE GET_ESN_MIN_DETAILS(
    op_esn_min_status_det_tab IN OUT esn_min_status_det_tab,
    o_err_code OUT VARCHAR2,
    o_err_msg OUT VARCHAR2 )
IS
  -- initializing  customer type
  cst sa.customer_type := sa.customer_type();
  l_expiration_date DATE;

BEGIN
  -- Input Validation
  o_err_code := '0';
  o_err_msg  := 'SUCCESS';

    IF  op_esn_min_status_det_tab IS NULL THEN
    o_err_code               := '112';
    o_err_msg                := 'ESN MIN detail list not passed';
    RETURN;

  END IF;
  IF op_esn_min_status_det_tab.count = 0 THEN
    o_err_code               := '112';
    o_err_msg                := 'ESN MIN detail list has no input value';
    RETURN;
  END IF;
  -- Update op_esn_pin_smp_tab variables
  FOR i IN 1 .. op_esn_min_status_det_tab.count
  LOOP

     IF op_esn_min_status_det_tab(i).esn IS NULL AND op_esn_min_status_det_tab(i).min IS NULL THEN
                    o_err_code               := '103';
        o_err_msg                := 'ESN and MIN are mising';
                                op_esn_min_status_det_tab(i).response := o_err_msg;
                                continue;
                END IF;

     IF op_esn_min_status_det_tab(i).esn IS NULL THEN
        op_esn_min_status_det_tab(i).esn := cst.get_esn ( i_min => (op_esn_min_status_det_tab(i).min) );
                END IF;

     IF op_esn_min_status_det_tab(i).min IS NULL THEN
        op_esn_min_status_det_tab(i).min := cst.get_min ( i_esn => (op_esn_min_status_det_tab(i).esn) );
                END IF;

                op_esn_min_status_det_tab(i).esn_part_inst_status := cst.get_esn_part_inst_status (i_esn => op_esn_min_status_det_tab(i).esn);
                op_esn_min_status_det_tab(i).service_plan_objid   := cst.get_service_plan_objid (i_esn => op_esn_min_status_det_tab(i).esn);
                l_expiration_date                                 := cst.get_expiration_date (i_esn => op_esn_min_status_det_tab(i).esn);
                IF l_expiration_date IS NOT NULL THEN
         op_esn_min_status_det_tab(i).Service_End_Date:=  l_expiration_date;
                    op_esn_min_status_det_tab(i).remaining_service_days := TRUNC(l_expiration_date) - TRUNC(SYSDATE);
     END IF;

                op_esn_min_status_det_tab(i).transaction_pending := customer_info.get_transaction_status(i_esn => op_esn_min_status_det_tab(i).esn);

                IF op_esn_min_status_det_tab(i).esn IS NULL OR
                                op_esn_min_status_det_tab(i).esn_part_inst_status IS NULL THEN
                        op_esn_min_status_det_tab(i).response := 'Unable to retrieve ESN/PART INST STATUS';
                                    o_err_code               := '104';
            o_err_msg                := op_esn_min_status_det_tab(i).response;
                ELSE
                     op_esn_min_status_det_tab(i).response := 'SUCCESS';
                END IF;

  END LOOP;
  --Exception Block
EXCEPTION
WHEN OTHERS THEN
  o_err_code := '99';
  o_err_msg  := 'Failed in when others' || SUBSTR(SQLERRM, 1,200);
END GET_ESN_MIN_DETAILS;
   --CR47564 - End of Overloading procedure Validate_phone_prc with security_pin as a new out param


--CR46195
PROCEDURE get_cdma_rebrand_pn
                            (
                             i_esn       IN         VARCHAR2,
                             i_is_lte    IN         VARCHAR2,
                             i_org_id    IN         VARCHAR2,
                             o_to_pn            OUT VARCHAR2,
                             o_rebrand          OUT VARCHAR2,
                             o_errnum           OUT VARCHAR2,
                             o_errstr           OUT VARCHAR2,
                             i_zip_code  IN         VARCHAR2,
                             o_new_sim_part_num OUT VARCHAR2
                            )
IS
v_prefix_pn table_bus_org.loc_type%TYPE;
v_rebrand   VARCHAR2(5)  := 'N';
v_sim_type  VARCHAR2(10) := '';
v_to_pn     table_part_num.part_number%TYPE;
v_sim_pn    table_part_num.part_number%TYPE;

 l_repl_part varchar2(30);
l_repl_tech varchar2(30);
l_sim_profile varchar2(30);
l_part_serial_no varchar2(30);
l_msg varchar2(200);
l_pref_parent varchar2(30);
l_pref_carrier_objid varchar2(30);


CURSOR  get_esn_info_cur(in_esn_c1 table_part_inst.part_serial_no%TYPE) IS
SELECT  tpn.x_technology technology,
         part_number part_num,
         esn.x_iccid
FROM    TABLE_PART_INST ESN,
         TABLE_MOD_LEVEL TML,
         TABLE_PART_NUM TPN
WHERE   ESN.N_PART_INST2PART_MOD   = TML.OBJID
AND     TML.PART_INFO2PART_NUM     = TPN.OBJID
AND     ESN.PART_SERIAL_NO         = in_esn_c1
AND     ESN.x_domain = 'PHONES'
AND     ROWNUM = 1;

  get_esn_info_rec get_esn_info_cur%ROWTYPE;

 --Re-Branding
cursor cur_zip is
SELECT INSTALL_DATE,X_ZIPCODE
FROM sa.table_site_part
WHERE x_service_id = i_esn
order by INSTALL_DATE desc;

rec_zip      cur_zip%rowtype;
v_zipcode    VARCHAR2(20) := i_zip_code;
v_byop_lte_flag VARCHAR2(20) := 'N';
BEGIN --{
o_errnum  := '0';
o_errstr  := 'success';
o_rebrand := 'N';

  OPEN  get_esn_info_cur(i_esn);
  FETCH get_esn_info_cur INTO get_esn_info_rec;
  CLOSE get_esn_info_cur;

 -- If no zip code see if profile exists.
  IF v_zipcode IS NULL
  THEN --{
     -- See if the device is active.
     --
      BEGIN
       OPEN cur_zip;
       FETCH cur_zip INTO rec_zip;
       v_zipcode := rec_zip.x_zipcode;
       CLOSE cur_zip;

      EXCEPTION WHEN OTHERS THEN

          IF cur_zip%ISOPEN THEN
             CLOSE cur_zip;
          END IF; /* cur_zip%ISOPEN */

      END;

  END IF; --} /* ip_zipcode IS NULL */




  BEGIN --{
   SELECT SUBSTR (loc_type, 1, 2)
   INTO   v_prefix_pn
   FROM   table_bus_org
   WHERE  org_id = i_org_id;
  EXCEPTION
   WHEN OTHERS THEN
     v_prefix_pn :=NULL;
  END; --}

IF get_esn_info_rec.technology = 'CDMA'
THEN --{

DBMS_OUTPUT.PUT_LINE('Input ESN Part# = '||get_esn_info_rec.part_num);
o_to_pn := REGEXP_REPLACE (get_esn_info_rec.part_num,SUBSTR (get_esn_info_rec.part_num, 1, 2), v_prefix_pn,1,1);

BEGIN --{
  SELECT 'Y'
  INTO   v_rebrand
  FROM   table_mod_level ml,
         table_part_num pn,
         table_bus_org bo
  WHERE  ml.part_info2part_num = pn.objid
  AND    pn.part_number        = o_to_pn
  AND    pn.part_num2bus_org   = bo.objid
  AND   (bo.ORG_ID             = 'TRACFONE'
         OR   EXISTS
                 (
                  SELECT '1'
                  FROM   sa.adfcrm_serv_plan_class_matview
                  WHERE  part_class_objid = pn.part_num2part_class
                  AND ROWNUM < 2
                  )
        )
  AND   ROWNUM = 1;
EXCEPTION
WHEN OTHERS THEN
  v_rebrand := 'N';
END; --}

IF v_rebrand = 'Y' AND o_to_pn IS NOT NULL
THEN --{
  o_rebrand := v_rebrand;
  DBMS_OUTPUT.PUT_LINE('Matching Part# Found ~ '||o_to_pn||' Rebrand '||o_rebrand);
  RETURN;
ELSE --}{
  o_to_pn   := '';  --RESET
  o_rebrand := 'N'; --RESET

  IF NVL(i_is_lte, 'N') != 'Y'
  THEN --{

   BEGIN --{
    SELECT tpn.part_number
    INTO   v_to_pn
    FROM   x_byop_part_num xbpn,
           table_part_num  tpn,
           table_bus_org   tbo
    WHERE  xbpn.x_byop_type       = 'Phone'
    AND    xbpn.x_org_id          = i_org_id
    AND    xbpn.x_part_number     = tpn.part_number
    AND    tpn.part_num2bus_org   = tbo.objid
    AND   (
           tbo.ORG_ID             = 'TRACFONE'
           OR   EXISTS
                   (
                    SELECT '1'
                    FROM   sa.adfcrm_serv_plan_class_matview
                    WHERE  part_class_objid = tpn.part_num2part_class
                    )
          )
    AND    ROWNUM      = 1;

    o_to_pn   := v_to_pn;
    o_rebrand := 'Y';
    DBMS_OUTPUT.PUT_LINE('Non LTE Part# Found ~ '||o_to_pn||' Rebrand '||o_rebrand);
   EXCEPTION
   WHEN OTHERS THEN
    o_to_pn   := '';
    o_rebrand := 'N';
    o_errnum  := '-1';
    o_errstr  := 'Fail';
    DBMS_OUTPUT.PUT_LINE('Non LTE Part# Not Found ~ '||o_to_pn||' Rebrand '||o_rebrand);
    RETURN;
   END; --}

  ELSE --}{

   BEGIN --{
    SELECT pn.part_number
    INTO   v_sim_pn
    FROM   table_x_sim_inv sim,
           table_mod_level ml,
           table_part_num pn,
           table_part_class pc,
           table_part_inst tpi
    WHERE  1                      = 1
    AND    sim.x_sim_serial_no    = tpi.x_iccid
    AND    sim.x_sim_inv2part_mod = ml.objid
    AND    ml.part_info2part_num  = pn.objid
    AND    pn.part_num2part_class = pc.objid
    AND    tpi.part_serial_no     = i_esn
    AND    ROWNUM                 = 1;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN

     -- CR52423 Default to TRIO sim type
     v_sim_type := 'TRIO';

   WHEN OTHERS THEN
    v_sim_pn  := '';
    o_to_pn   := '';
    o_rebrand := 'N';
    o_errnum  := '-2';
    o_errstr  := 'Fail';
    DBMS_OUTPUT.PUT_LINE('Non LTE Part# Not Found ~ '||o_to_pn||' Rebrand '||o_rebrand);
    RETURN;
   END; --}

  DBMS_OUTPUT.PUT_LINE('SIM Part# '||v_sim_pn);

  IF v_sim_type IS NULL THEN

  SELECT sa.byop_service_pkg.get_byop_sim_type(v_sim_pn)
     INTO   v_sim_type
     FROM   DUAL;

     END IF;

  DBMS_OUTPUT.PUT_LINE('SIM Type ~ '||v_sim_type);

  IF v_sim_type = 'NANO' OR v_sim_type = 'DUAL' OR v_sim_type = 'TRIO'
  THEN --{

   BEGIN --{
    SELECT tpn.part_number
    INTO   v_to_pn
    FROM   x_byop_part_num xbpn,
           table_part_num  tpn,
           table_bus_org   tbo
    WHERE  xbpn.x_byop_type       LIKE '%VERIZON_OTHER_'||v_sim_type||'%'
    AND    xbpn.x_org_id          = i_org_id
    AND    xbpn.x_part_number     = tpn.part_number
    AND    tpn.part_num2bus_org   = tbo.objid
    AND   (
           tbo.ORG_ID             = 'TRACFONE'
           OR   EXISTS
                   (
                    SELECT '1'
                    FROM   sa.adfcrm_serv_plan_class_matview
                    WHERE  part_class_objid = tpn.part_num2part_class
                    )
          )
    AND    ROWNUM      = 1;

    o_to_pn   := v_to_pn;
    o_rebrand       := 'Y';
    v_byop_lte_flag := 'Y';
    DBMS_OUTPUT.PUT_LINE('LTE Part# Found ~ '||o_to_pn||' Rebrand '||o_rebrand);
   EXCEPTION
   WHEN OTHERS THEN
    o_to_pn   := '';
    o_rebrand := 'N';
    o_errnum  := '-3';
    o_errstr  := 'Fail';
    DBMS_OUTPUT.PUT_LINE('LTE Part# Not Found ~ '||o_to_pn||' Rebrand '||o_rebrand);
    RETURN;
   END; --}

  ELSE --}{
    o_to_pn   := '';
    o_rebrand := 'N';
    o_errnum  := '-4';
    o_errstr  := 'Fail';
    DBMS_OUTPUT.PUT_LINE('SIM Type Not Compatible ~ '||v_sim_type);
    RETURN;
  END IF; --}
END IF; --}
END IF; --}

 ----------------- new logic added by
IF o_to_pn IS NOT NULL AND i_is_lte = 'Y'
THEN --{
DBMS_OUTPUT.PUT_LINE('In SIM compatible check logic..');
o_rebrand := '';
o_new_sim_part_num := '';

  IF get_esn_info_rec.x_iccid IS NULL AND v_sim_type = 'TRIO'
  THEN --{
    DBMS_OUTPUT.PUT_LINE('get_esn_info_rec.x_iccid IS NULL AND v_sim_type = TRIO');
    o_rebrand := 'Y';
   RETURN;
  END IF; --}

  IF i_is_lte = 'Y' AND v_zipcode IS NULL
  THEN --{
  DBMS_OUTPUT.PUT_LINE('i_is_lte = Y AND v_zipcode IS NULL');
/*    o_to_pn   := '';
    o_new_sim_part_num := '';
    o_rebrand := 'N';
    o_errnum  := '-14';
    o_errstr  := 'Fail';*/
    o_rebrand := 'Y';
    RETURN;
  END IF; --}

  IF i_is_lte = 'Y' AND v_zipcode IS NOT NULL
  THEN --{
   nap_service_pkg.get_list(
                            p_zip             => v_zipcode,
                            p_esn             => NULL,
                            p_esn_part_number => o_to_pn, --Future ESN pn
                            p_sim             => get_esn_info_rec.x_iccid, --Current SIM
                            p_sim_part_number => NULL,
                            p_site_part_objid => NULL
                           );

  END IF; --}
  DBMS_OUTPUT.PUT_LINE('NAP_SERVICE_PKG passed: '||nap_service_pkg.big_tab.count);
  IF nap_service_pkg.big_tab.COUNT > 0 --NAP Success
  THEN --{
      o_rebrand := 'Y';
      RETURN;
  ELSE --}{ --NAP Failed
    -- Get the SIM for the new part number.
    BEGIN --{
    SELECT sim_profile
      INTO o_new_sim_part_num
      FROM (
            SELECT a.rank new_rank,
                   a.sim_profile
              FROM carrierpref cp,
                   npanxx2carrierzones b,
                   (SELECT DISTINCT a.ZONE,
                                   a.st,
                                   s.sim_profile,
                                   a.county,
                                   s.min_dll_exch,
                                   s.max_dll_exch,
                                   s.rank
                              FROM carrierzones a,
                                   carriersimpref s
                             WHERE a.zip       = v_zipcode  -- CR52423
                               AND a.carrier_name=S.carrier_name
                               AND (select x_dll from table_part_num where part_number = o_to_pn) BETWEEN s.min_dll_exch AND s.max_dll_exch
                             ORDER BY s.rank ASC
            ) a
      WHERE 1           =1
        AND cp.st         = b.state
        AND cp.carrier_id = b.carrier_ID
        AND cp.county     = a.county
        AND b.cdma_tech = 'CDMA' --technology
        AND b.ZONE        = a.ZONE
        AND b.state       = a.st
      ORDER BY a.rank ASC)
    WHERE ROWNUM < 2 ;

    EXCEPTION WHEN OTHERS THEN
          o_new_sim_part_num := NULL;
    END; --}

    IF o_new_sim_part_num IS NULL --SIM PN not found
    THEN --{
    DBMS_OUTPUT.PUT_LINE('SIM PN not found');
        o_to_pn   := '';
        o_new_sim_part_num := '';
        o_rebrand := 'N';
        o_errnum  := '-15';
        o_errstr  := 'Fail';
        RETURN;
    ELSE --}{ --SIM PN found
    DBMS_OUTPUT.PUT_LINE('SIM PN found');
    --GET sim type of the new SIM
    v_sim_type :=  sa.byop_service_pkg.get_byop_sim_type(o_new_sim_part_num);
    BEGIN --{
     SELECT tpn.part_number
     INTO   o_to_pn
     FROM   x_byop_part_num xbpn,
            table_part_num  tpn,
            table_bus_org   tbo
     WHERE  xbpn.x_byop_type       LIKE '%VERIZON_OTHER_'||v_sim_type||'%'
     AND    xbpn.x_org_id          = i_org_id
     AND    xbpn.x_part_number     = tpn.part_number
     AND    tpn.part_num2bus_org   = tbo.objid
     AND   (
            tbo.ORG_ID             = 'TRACFONE'
            OR   EXISTS
                    (
                     SELECT '1'
                     FROM   sa.adfcrm_serv_plan_class_matview
                     WHERE  part_class_objid = tpn.part_num2part_class
                     )
           )
     AND    v_byop_lte_flag = 'Y'
     AND    ROWNUM      = 1;
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Compatible Phone PN not found....');
        o_to_pn   := '';
        o_new_sim_part_num := '';
        o_rebrand := 'N';
        o_errnum  := '-16';
        o_errstr  := 'Fail';
        RETURN;
    END; --}

    IF o_to_pn IS NOT NULL AND o_new_sim_part_num IS NOT NULL
    THEN --{
     o_rebrand := 'Y';
     o_errnum  := '0';
     o_errstr  := 'Success';
    END IF; --}

    END IF; --}

  END IF; --}

END IF; --} --Main
 ----------------- new logic added by  ends

ELSE --}{
o_rebrand := 'N';
o_errnum  := '-5';
o_errstr  := 'Fail';
END IF; --}

EXCEPTION
WHEN OTHERS THEN
o_errnum := '-10';
o_errstr := 'Fail';
DBMS_OUTPUT.PUT_LINE('Failed in main exception '||sqlerrm);
END get_cdma_rebrand_pn; --}

FUNCTION eligible_ppe_pn(i_part_num IN VARCHAR2)
RETURN VARCHAR2
IS
l_4x  number:=0;
l_ppe number:=0;
BEGIN --{

SELECT COUNT(*)
INTO   l_4x
FROM   table_x_part_class_values,
        table_x_part_class_params
WHERE  value2part_class   =  (SELECT part_num2part_class FROM table_part_num WHERE part_number = i_part_num AND rownum = 1)
And    value2class_param  =  table_x_part_class_params.objid
AND    x_param_name       =  'FIRMWARE'
AND    x_param_value      >= '4.X';

SELECT COUNT(*)
INTO   l_ppe
FROM   table_x_part_class_values,
        table_x_part_class_params
WHERE  value2part_class   = (SELECT part_num2part_class FROM table_part_num WHERE part_number = i_part_num AND rownum = 1)
AND    value2class_param  = table_x_part_class_params.objid
AND    x_param_name       = 'DEVICE_TYPE'
AND    x_param_value      = 'FEATURE_PHONE';

IF l_ppe>0 AND l_4x=0 THEN --Block Old PPE Phones
  RETURN 'N';
ELSE
  RETURN 'Y';
END IF;

EXCEPTION
WHEN OTHERS THEN
RETURN 'Y';
END eligible_ppe_pn; --}

FUNCTION is_sim_compatible(p_esn IN VARCHAR2, p_part_num IN VARCHAR2)
RETURN VARCHAR2
IS
CURSOR  curr_tsp(p_esn VARCHAR2) IS
SELECT  *
FROM    sa.table_site_part outt
WHERE   outt.x_service_id = p_esn
AND     outt.objid = ( SELECT  MAX(inn.objid)
                       FROM    sa.table_site_part inn
                       WHERE   inn.x_service_id = outt.x_service_id);

rec_tsp curr_tsp%ROWTYPE;
v_carr_mkt_objid  VARCHAR2(100);
v_carr_parent_id  VARCHAR2(100);
v_carrier         VARCHAR2(200);
v_error_no        NUMBER;
v_error_str       VARCHAR2(200);

BEGIN --{
OPEN curr_tsp(p_esn);
FETCH curr_tsp INTO rec_tsp;

IF curr_tsp%NOTFOUND
THEN --{
CLOSE curr_tsp;
DBMS_OUTPUT.PUT_LINE('No TSP record found.');
RETURN 'N';
END IF; --}
CLOSE curr_tsp;


nap_service_pkg.get_list(
                         p_zip             => rec_tsp.x_zipcode,
                         p_esn             => NULL,
                         p_esn_part_number => p_part_num, --Future ESN pn
                         p_sim             => rec_tsp.x_iccid, --Current SIM
                         p_sim_part_number => NULL,
                         p_site_part_objid => rec_tsp.objid
                        );

DBMS_OUTPUT.PUT_LINE('Found Found: '||nap_service_pkg.big_tab.count);
IF nap_service_pkg.big_tab.count >0
THEN --{
RETURN 'Y';
ELSE
RETURN 'N';
END IF; --}

EXCEPTION
WHEN OTHERS THEN
RETURN 'N';
END is_sim_compatible; --}

--Moved the below procedure from private (getesnattributes) to public.
PROCEDURE get_last_red_details(ip_esn         IN  VARCHAR2,
                                 op_red_partno  OUT VARCHAR2,
                                 op_red_pc      OUT VARCHAR2,
                                op_code        OUT NUMBER,
                                 op_msg         OUT VARCHAR2 )
  IS
  --
  BEGIN
    SELECT part_num,pc.name
    INTO op_red_partno,op_red_pc
    FROM (
        SELECT 1,x_service_id,x_transact_date,spsp.x_service_plan_id,mv.PLAN_PURCHASE_PART_NUMBER part_num,
               mv.SP_MKT_NAME
        FROM   table_x_call_trans ct,
               sa.X_SERVICE_PLAN_SITE_PART spsp,
               splan_feat_pivot mv
        WHERE  1 = 1
        AND    spsp.TABLE_SITE_PART_ID =  ct.CALL_TRANS2SITE_PART
        AND    ct.x_action_type+0      in ( 1, 3, 6)
        AND    splan_objid             =  spsp.X_SERVICE_PLAN_ID
        AND    service_plan_group      <> 'ADD_ON_DATA'
        AND    ct.X_SERVICE_ID         = ip_esn
        UNION
        SELECT 2,CT.X_SERVICE_ID, ct.x_transact_date,-1, part_number,'  '
        FROM  table_x_call_trans ct,
              table_x_red_card rc,
              table_mod_level ml,
              table_part_num pn
        WHERE ct.objid                =   rc.RED_CARD2CALL_TRANS
        AND   ct.x_action_type        in ( '1','3','6')
        AND   rc.X_RED_CARD2PART_MOD  =   ml.objid
        AND   ml.part_info2part_num   =   pn.objid
        AND   PN.X_REDEEM_UNITS > 0
        AND   pn.X_REDEEM_DAYS  >0
        AND   ct.X_SERVICE_ID         =   ip_esn
        UNION
        SELECT 3,CT.X_SERVICE_ID, CT.X_TRANSACT_DATE,-100, PN.PART_NUMBER,PP.X_PROGRAM_DESC
        FROM  TABLE_X_CALL_TRANS CT,
              x_program_gencode GC,
              sa.X_PROGRAM_PURCH_DTL DTL,
              sa.X_PROGRAM_ENROLLED PE,
              sa.X_PROGRAM_PARAMETERS PP,
              TABLE_PART_NUM PN
        WHERE CT.OBJID = GC.GENCODE2CALL_TRANS
        AND   GENCODE2PROG_PURCH_HDR          = DTL.PGM_PURCH_DTL2PROG_HDR
        AND   DTL.PGM_PURCH_DTL2PGM_ENROLLED  = pe.OBJID
        AND   PE.PGM_ENROLL2PGM_PARAMETER     = PP.OBJID
        AND   PN.OBJID IN ( PP.PROG_PARAM2APP_PRT_NUM, PP.PROG_PARAM2PRTNUM_MONFEE)
        AND   ct.X_SERVICE_ID                 = ip_esn
        ORDER BY X_TRANSACT_DATE DESC,1) main,
        table_part_num    pn,
        table_part_class  pc
    WHERE main.X_SERVICE_ID = ip_esn
    AND   main.part_num = pn.part_number
    AND   pn.part_num2part_class(+) = pc.objid
    AND   rownum < 2;
    --
    op_code := 0;
    op_msg  := 'SUCCESS';
    --
   EXCEPTION
       WHEN OTHERS THEN
          op_code := sqlcode;
          op_msg  := sqlerrm;
END get_last_red_details;

--50666
PROCEDURE get_sl_equi_phone
                          (
                           i_esn       IN     VARCHAR2,
                           i_org_id    IN     VARCHAR2,
                           o_to_pn        OUT VARCHAR2,
                           o_rebrand      OUT VARCHAR2,
                           o_errnum       OUT VARCHAR2,
                           o_errstr       OUT VARCHAR2
                          )
IS

v_prefix_pn table_bus_org.loc_type%TYPE;
v_rebrand   VARCHAR2(5)  := 'N';

CURSOR  get_esn_info_cur(in_esn_c1 table_part_inst.part_serial_no%TYPE) IS
SELECT  tpn.x_technology technology,
         part_number part_num
FROM    table_part_inst esn,
         table_mod_level tml,
         table_part_num tpn
WHERE   esn.n_part_inst2part_mod   = tml.objid
AND     tml.part_info2part_num     = tpn.objid
AND     esn.part_serial_no         = in_esn_c1
AND     esn.x_domain = 'PHONES'
AND     ROWNUM = 1;

  get_esn_info_rec get_esn_info_cur%ROWTYPE;
BEGIN --{

o_errnum  := '0';
o_errstr  := 'success';
o_rebrand := 'N';

IF i_org_id IS NULL OR i_esn IS NULL
THEN --{
  o_errnum  := '-1';
  o_errstr  := 'ESN/Brand not passed.';
  o_rebrand := 'N';
  RETURN;
END IF; --}

OPEN  get_esn_info_cur(i_esn);
FETCH get_esn_info_cur INTO get_esn_info_rec;
CLOSE get_esn_info_cur;

BEGIN
  SELECT DECODE(i_org_id, 'TRACFONE', DEST_TF_PART, DEST_NT_PART), 'Y'
  INTO   o_to_pn, o_rebrand
  FROM   SL_REBRAND_CONFIG
  WHERE  SOURCE_PART = get_esn_info_rec.part_num
 AND    DECODE(i_org_id, 'TRACFONE', DEST_TF_PART, DEST_NT_PART) IS NOT NULL
  AND    ROWNUM = 1;
EXCEPTION
WHEN OTHERS THEN
  o_errnum := '-2';
  o_errstr := 'fail';
  DBMS_OUTPUT.PUT_LINE('Failed in main exception... '||sqlerrm);
  RETURN;
END;

DBMS_OUTPUT.PUT_LINE('SL o_to_pn = '||o_to_pn);
DBMS_OUTPUT.PUT_LINE('SL o_rebrand = '||o_rebrand);

EXCEPTION
WHEN OTHERS THEN
o_errnum := '-3';
o_errstr := 'Fai2l';
DBMS_OUTPUT.PUT_LINE('Failed in main exception '||sqlerrm);
RETURN;
END get_sl_equi_phone; --}

PROCEDURE get_multi_esn_attributes ( i_customer_tab   IN OUT sa.customer_tab,
                                     o_err_code       OUT   NUMBER,
                                     o_err_msg        OUT   VARCHAR2
                                   )
IS
BEGIN
  IF i_customer_tab IS NULL
  THEN
    o_err_code := 901;
    o_err_msg  := 'INPUT IS NULL';
    RETURN;
  ELSIF i_customer_tab.count = 0
  THEN
    o_err_code := 902;
    o_err_msg  := 'NO INPUT RECORDS PASSED';
    RETURN;
  END IF;
  FOR i IN 1..i_customer_tab.count
  LOOP
    IF    i_customer_tab(i).esn IS NULL
      AND i_customer_tab(i).min IS NULL
      AND i_customer_tab(i).esn_part_inst_objid IS NULL
    THEN
      o_err_code := 903;
      o_err_msg  := 'ESN, MIN, ESN_PART_INST_OBJID ALL ARE NULL IN THE RECORD '||i||' OF THE INPUT';
      RETURN;
    ELSIF i_customer_tab(i).esn IS NULL
      AND i_customer_tab(i).min IS NOT NULL
    THEN
      i_customer_tab(i).esn := sa.customer_info.get_esn (i_min => i_customer_tab(i).min);
    ELSIF i_customer_tab(i).min IS NULL
      AND i_customer_tab(i).esn IS NOT NULL
    THEN
      i_customer_tab(i).min := sa.customer_info.get_min (i_esn => i_customer_tab(i).esn);
    END IF;
    BEGIN
      SELECT x_iccid,
             objid,
             part_serial_no
      INTO   i_customer_tab(i).iccid,
             i_customer_tab(i).esn_part_inst_objid,
             i_customer_tab(i).esn
      FROM   table_part_inst
      WHERE  part_serial_no = i_customer_tab(i).esn OR objid = i_customer_tab(i).esn_part_inst_objid;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        i_customer_tab(i).iccid := NULL;
      WHEN OTHERS THEN
        o_err_code := 904;
        o_err_msg  := 'ERROR WHILE FETCHING SIM FOR ESN:'||i_customer_tab(i).esn||'. '||SQLERRM;
        RETURN;
    END;
  END LOOP;
  o_err_code := 0;
  o_err_msg  := 'SUCCESS';
EXCEPTION
  WHEN OTHERS THEN
    o_err_code := 902;
    o_err_msg  := 'NO INPUT RECORDS PASSED';
END get_multi_esn_attributes;
END PHONE_PKG;
/