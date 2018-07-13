CREATE OR REPLACE PACKAGE BODY sa."MIGRA_INTELLITRACK" AS
 /*****************************************************************
 * Package Name: SA.migra_intellitrack (BODY)
 * Purpose : To manage the interface between Clarify and Intellitrack
 *
 * Platform : Oracle 8.0.6 and newer versions.
 * Created by : Fernando Lasa, DRITON
 * Date : 09/02/2005
 *
 * Frequency : All weekdays
 * History
 * REVISIONS VERSION DATE WHO PURPOSE
 * -------------------------------------------------------------
 * 1.0 Fernando Lasa Initial Revision
 * 1.13 09/02/05 Fernando Lasa CR 4260 - Fist release put in testing
 * 1.14 09/02/05 Fernando Lasa CR 4260 - To add the header comment
 * 1.15 09/02/05 Fernando Lasa CR 4260 - To add the functionality that
 * shoud check if the replace part number is null
 * and in that case update it.
 * 1.16 09/03/05 Fernando Lasa CR 4260 - To correct an error in Send_cases
 * 1.17 09/03/05 Fernando Lasa CR 4260 - To change from all 9 to --- for
 * SIM CARD EXCHANGE in Technology Exchange
 * cases and complete a message error.
 * 1.18 09/03/05 Fernando Lasa CR 4260 - To change the order of the procedures
 * 1.19 09/05/05 Fernando Lasa CR 4187 - To comment the line that call the procedure
 * CheckReplPartInNull in Send_Cases
 * 1.20 09/05/05 Fernando Lasa CR 4187 - To process only cases started by 9 in
 * phone_shipping process
 * 1.21 09/07/05 Fernando Lasa CR 4187 - To change DBlink to ofsprd
 * 1.22 09/09/05 Fernando Lasa CR 4187 - To fix a problem with phone_receive
 * 1.23 09/11/05 Fernando Lasa CR 4187 - To change the way the OFS records
 * are flaged as processed and to take the last
 * valid case of a ESN
 * 1.24 09/14/05 Fernando Lasa CR 4187 - To change the way NO CASE cases were saved
 * 1.25 09/27/05 Fernando Lasa CR 4187 - To manage received phones that had a non-pending case,
 * new message string 35 chars first part, 20 chars for status title in Phone_Receive
 * Change in Close_Case to fix a status bug
 * 1.26 09/29/05 Fernando Lasa CR 4187 - To fix a phone_shipping issue.
 * CR 4513 - To include procedure TransferPromotions
 * 1.27 10/11/05 VAdapa CR4541 - Advanced Exchange
 * 1.28 10/12/05 Vadapa Additions to CR4541
 * 1.29 10/13/05 VAdapa Fix for CR4541
 * 1.30 10/13/05 VAdapa Changed the database link from OFSDEV to ofsprd
 * 1.31 10/14/05 flasa CR 4691 - To change the cursor structure of OFS in Phone_receive
 * 1.32 10/20/05 flasa CR 4691 - To include an array in phone_receive
 * 1.33 12/29/05 flasa CR 4878 - Bad Address Shipments
 * 1.34 12/29/05 flasa CR 4878 - To fix a bug
 * 1.35 01/27/06 flasa CR 4881 - To fix remove promotion in Bad Address
 * 1.35.1 02/01/06 VAdapa Correct CR# in the comments
 * CR4878
 * 1.35.1.1 02/16/06 gcarena CR4878 - To prevent F flagged cases of being re-updated to 'Bad Adress' status
 * over and over again, and prevent promo removal and units removal
 * 1.35.1.2 02/17/06 gcarena CR4878 - To fix that F cases should continue to reprocess, but prevent case status
 * update, promo removal, units removal, until it succeeds and flagged as P
 * 1.35.1.3 02/22/06 gcarena CR5029 - To modify the revision label of revision 1.35.1.2 and add this comment
 * 1.35.1.4 02/28/06 gcarena CR5029 - To remove the package header, wrongfully included at top of package body
 * 1.35.1.5 03/07/06 flasa CR5029 - TO check new ESN for null values, and mark as 'P' in OFS anyway
 * 1.35.1.6 06/14/06 gpintado CR5336 - Sending FF, Carrier and Method to OFS table (tf_order_interface).
 * 1.36 09/08/06 Jasmine - Warehouse Integration change:
 * Add ship_to_address2;
 * Remove the hardcode of SHIPPING_METHOD;assign values from Table_X_Part_Request to SHIPPING_METHOD;
 * Replace parameter p_OldEsn with p_objid in Transferpromotions
 * Insert into table_x_case_promotions
 * 09/21/06 Jing Tong IN parameter for tf_doc_number while in the tf_receipt_headers,
 * 1.40 /1.41 11/01/06 gpintado PJ244 - Re-write of Bad Address procedure.
 * 1.42 01/20/07 Vadapa CR5569-7 - To fix not to update the duedate of the phone during transferpromotions
 * 1.43 01/25/07 gpintado CR5980 - Change send_case to use alt_phone instead of alt_phone_num
 * 1.44 02/16/07 VAdapa CR5848 - Tracfone and Net10 Airtime Price Change
 * 1.45 02/16/07 VAdapa Modified to fix a defect logged for CR5848 (defect #355)
 * 1.46 02/28/07 VAdapa Modified to fix a defect logged for CR5848 (defect #373)
 * 1.47 03/06/07 GPintado CR5848 - Changed to production DB Link
 * 1.48 04/12/07 VAdapa CR5150 - Modified to NOT to transfer DMPP progrma for more casetpes
 * 1.49 04/17/07 VAdapa CR5150 - Changed the database link from OFSDEV2 to ofsprd
 * 1.49.1.0 05/18/07 VAdapa CR6250 - Modified to pass the technology of the new esn
 * 1.49.1.1 05/18/07 VAdapa CR6250 - Reverted back the old way exception that corrected the type of the
 * "UNITS TRANSFER" title to "UNIT TRANSFER"
 * 1.50 05/20/07 ABarrera CR6254 - Meid support (length = 18 digits)
 ************************************************************************/ /****************************************************
* * NEW PVCS STRUCTURE /NEW_PLSQL?CODE
*1.0 04/23/08 VAdapa Initial version
*1.1 04/23/08 CLindner 10G Post-implementation fixes (comments : cwl 04/23)
*1.2 07/15/08 NGuada Life Line
*1.3 07/15/08 NGuada Life Line
*1.4 07/23/08 NGuada Life Line, Account Correction
*1.5 11/03/08 Ymillan CR 7986 - Add activation and ActivationCombo
* Condition into the cursor C_EsnPromotions
* Proc TransferPromotions
*1.7 03/02/09 YMillan CR8480 modified proc send_cases if address1 > 30, the status is ONHOLD
*1.8 03/06/09 ICanavan Merge CR8480 and CR7986
*1.10 03/27/09 YMillan CR8585 modified proc send_case insert LLID into OFS
*1.14 09/30/09 NGuada CR10141 change proc Phone_Shipping
*1.15 12/01/09 NGuada B2B + BRAND_SEP_IV
*1.4 08/24/10 NGuada CR13581 B2B
*1.5 06/03/11 ICanavan CR16344 / CR16379
*1.6 12/30/11 YMillan CR19376 Segregate SL and ST Orders for Warehouse Shipments
*1.10 03/21/2012 YMillan CR19467 Straight talk Promo Logic (Master)
*1.11 07/26/2012 ICanavan CR20854 TELCEL
*1.14 03/21/2012 YMillan CR19467 Straight talk 1 Promo Logic (Master)
*1.18 08/16/2012 ICanavan CR20854 TELCEL merge
*1.19 02/18/2013 YMILLAN CR22452 SIMPLE MOBILE *
**************************************************************************
 --
 ---------------------------------------------------------------------------------------------
 --$RCSfile: MIGRA_INTELLITRACK.sql,v $
 --$Revision: 1.77 $
 --$Author: mshah $
 --$Date: 2018/02/22 19:38:00 $
 --$ $Log: MIGRA_INTELLITRACK.sql,v $
 --$ Revision 1.77  2018/02/22 19:38:00  mshah
 --$ CR55718 - Revise Safelink exchange cases
 --$
 --$ Revision 1.76  2018/02/21 16:10:16  mshah
 --$ CR55718 - Revise Safelink exchange cases
 --$
 --$ Revision 1.75  2017/08/07 15:54:26  smacha
 --$ Merge CR52354 to the prod version.
 --$
 --$ Revision 1.74  2017/07/28 13:36:59  mshah
 --$ CR52229 - SafeLink Smartphone Exchanges
 --$
 --$ Revision 1.72  2017/06/15 14:58:20  nkandagatla
 --$ CR50138 - Safelink Non Advance Exchange Cases
 --$
 --$ Revision 1.70  2017/04/12 21:59:10  jcheruvathoor
 --$ Changes incorporated as part of CRs CR45831 , CR47935
 --$
 --$ Revision 1.69 2017/02/20 18:54:41 rpednekar
 --$ CR46157 - Update case status to in process when case sent to OFS.
 --$
 --$ Revision 1.68 2017/01/17 22:36:44 rpednekar
 --$ CR46164 - Increase length of variable l_grp_name
 --$
 --$ Revision 1.67 2016/12/22 17:22:24 rpednekar
 --$ CR46164 - Increase length of variable error_str
 --$
 --$ Revision 1.66 2016/09/07 20:43:33 skota
 --$ Modified send cases procedure
 --$
 --$ Revision 1.65 2016/08/26 13:42:44 skota
 --$ Added logic for address validation CR43598
 --$
 --$ Revision 1.63 2016/08/02 16:08:20 nguada
 --$ CR44551 Please update the logic in the Migra job logic to update the Customer number from MIGRATION EXCHANGE to MIE305. There are 6,097 exchange cases in error due to this issue.
 --$
 --$ Revision 1.62 2016/07/19 14:59:58 nguada
 --$ length change from 9 to 8 based on CR43880
 --$
 --$ Revision 1.61 2016/07/08 14:36:08 nguada
 --$ tuning changes removed production rollback
 --$
 --$ Revision 1.58 2016/02/08 22:58:05 vnainar
 --$ CR39517 code changes added for send_cases procedure
 --$
 --$ Revision 1.57 2016/02/05 13:34:22 snulu
 --$ For fix - CR39517
 --$
 --$ Revision 1.55 2014/10/23 21:55:20 akhan
 --$ Commented SME305
 --$
 --$ Revision 1.54 2014/10/23 21:31:40 akhan
 --$ SME305 not supported by order_interface
 --$
 --$ Revision 1.53 2014/07/14 21:43:34 oarbab
 --$ 23663_UpdateDealerNet10dataSIMswaps
 --$
 --$ Revision 1.52 2014/07/09 16:24:48 rramachandran
 --$ CR28855 - Defect 21 Requirement change (date process clause to be removed)
 --$
 --$ Revision 1.51 2014/06/17 19:24:39 rramachandran
 --$ CR28855 - Ignored records with x_part_num_domain values as NULL
 --$
 --$ Revision 1.50 2014/06/17 15:36:26 rramachandran
 --$ CR28855 - Added filter for x_date_process in cursor
 --$
 --$ Revision 1.49 2014/06/17 14:15:38 rramachandran
 --$ CR 28855 - Fix for duplicate parts in case of multiple replacements
 --$
 --$ Revision 1.48 2014/04/10 20:57:43 ymillan
 --$ CR22429
 --$
 --$ Revision 1.47 2014/03/28 19:05:26 ymillan
 --$ CR22429
 --$
 --$ Revision 1.46 2014/03/04 22:17:23 ymillan
 --$ CR22429
 --$
 --$ Revision 1.45 2014/03/04 22:01:17 ymillan
 --$ CR22429
 --$
 --$ Revision 1.44 2013/11/25 17:53:47 oarbab
 --$ -- CR22080 Email_Airbill: CHANGED c.alt_email from f.e_mail in CURSOR c_case_title
 --$
 --$ Revision 1.43 2013/08/28 18:01:52 icanavan
 --$ use the log_notes function in clarify_case
 --$
 --$ Revision 1.42 2013/08/16 20:11:01 icanavan
 --$ use a new feature to strip characters
 --$
 --$ Revision 1.41 2013/08/14 20:20:18 icanavan
 --$ added code to remove special characters in the compare for bad addresses
 --$
 --$ Revision 1.39 2013/07/01 21:59:43 icanavan
 --$ merge with production this 22149 with 22860
 --$
 --$ Revision 1.38 2013/06/26 15:22:04 ymillan
 --$ CR22860 merge with production
 --$
 --$ Revision 1.37 2013/06/26 14:39:13 ymillan
 --$ CR22860
 --$
 --$ Revision 1.36 2013/06/20 21:47:59 ymillan
 --$ CR22860
 --$
 --$ Revision 1.35 2013/06/20 20:33:13 lsatuluri
 --$ 22429
 --$
 --$ Revision 1.34 2013/06/19 18:28:55 lsatuluri
 --$ *** empty log message ***
 --$
 --$ Revision 1.33 2013/06/18 17:44:53 lsatuluri
 --$ *** empty log message ***
 --$
 --$ Revision 1.32 2013/06/11 20:09:30 ymillan
 --$ CR22860 + merge CR22429
 --$
 --$ Revision 1.31 2013/06/10 20:38:09 lsatuluri
 --$ CR22429
 --$
 --$ Revision 1.30 2013/06/10 19:34:32 lsatuluri
 --$ MERGED 22429 AND 22860
 --$
 --$ Revision 1.27 2013/06/04 19:23:12 ymillan
 --$ CR22860
 --$
 --$ Revision 1.26 2013/05/22 20:53:12 ymillan
 --$ CR22860
 --$
 --$ Revision 1.25 2013/05/22 19:41:03 ymillan
 --$ CR22860
 --$
 --$ Revision 1.22 2013/05/03 18:49:49 ymillan
 --$ CR23889
 --$
 --$ Revision 1.21 2013/05/01 19:14:42 ymillan
 --$ CR23889 CR23647
 --$
 --$ Revision 1.20 2013/04/29 12:46:33 ymillan
 --$ CR23889
 --$
 --$ Revision 1.19 2013/02/25 20:37:01 ymillan
 --$ CR22452 SIMPLE MOBILE
 --$
 --$ Revision 1.15 2012/06/05 15:23:07 ymillan
 --$ CR19467
 --$
 --$ Revision 1.13 2012/04/25 15:29:44 mmunoz
 --$ CR19390 CR16379 CR19663 Merged revision 1.11 and 1.12
 --$
 --$ Revision 1.11 2012/04/03 14:34:40 kacosta
 --$ CR16379 Triple Minutes Cards
 --$
 --$ Revision 1.9 2012/03/02 22:22:58 kacosta
 --$ CR19390 Stop Clarify Exchange and Safelink cases for MM_IO
 --$
 --$ Revision 1.8 2012/02/09 21:36:58 kacosta
 --$ CR19802 Modify Warehouse Migra Job
 --$
 --$
 ---------------------------------------------------------------------------------------------
 --
**************************************************************************
* Procedure: IS_NUMERIC
* Purpose : To check if string value is numeric
**************************************************************************/
 FUNCTION is_numeric(pnumber IN VARCHAR2) RETURN BOOLEAN IS
 v_number NUMBER(20);
 BEGIN
 v_number := TO_NUMBER(pnumber);
 RETURN TRUE;
 EXCEPTION
 WHEN others THEN
 RETURN FALSE;
 END;
/**************************************************************************
* Function getCustomerAccount
* Return customer account based on case characteristics
/**************************************************************************/
 function getCustomerAccount (p_case_type IN VARCHAR2,
 p_title IN VARCHAR2,
 p_case_lvl2 IN VARCHAR2,
 p_esn IN VARCHAR2) return varchar2 is

 cursor c1 is
 select x_part_inst_status
 from sa.table_part_inst
 where part_serial_no = p_esn
 and x_domain = 'PHONES';
 r1 c1%rowtype;
 v_status varchar2(30):='NA';

 begin

 open c1;
 fetch c1 into r1;
 if c1%found then
 v_status := r1.x_part_inst_status;
 end if;
 close c1;


 if p_case_type = 'Warehouse' and p_title = '2G Migration' and v_status in ('50','51','54','150') then
 --return 'MIGRATION EXCHANGE'; --CR43690
		return 'MIE305'; --CR44551
 end if;

 if p_case_type = 'Handset Program' then
 return 'CWG212';
 end if;

 if p_case_lvl2 = 'TRACFONE' then
 return 'TW640';
 end if;

 if p_case_lvl2 = 'NET10' then
 return 'NW640';
 end if;

 if p_case_lvl2 = 'LIFELINE' then
 return 'USACSL';
 end if;

 if p_case_lvl2 = 'B2B-DIRECT' then
 return 'B2BDIR';
 end if;

 if p_case_lvl2 = 'B2B-SERVICES' then
 return 'B2BSER';
 end if;

 if p_case_lvl2 = 'SAFELINK' then
 return 'SLE305';
 end if;

 if p_case_lvl2 = 'STRAIGHT_TALK' then
 return 'STE305';
 end if;

 if p_case_lvl2 = 'TELCEL' then
 return 'TE305';
 end if;

 if p_case_lvl2 = 'SL-BROADBAND' then
 return 'MGPS303';
 end if;

 return 'TW640';

 end;
 /*************************************************************************
 * Procedure: Update_log
 * Purpose : To Update the status of the log
 **************************************************************************/
 PROCEDURE insert_log
 (
 esn IN VARCHAR2
 ,receipt_number IN NUMBER
 ,my_text IN VARCHAR2
 ,flag_type IN VARCHAR2
 ) AS
 --Proc varchar2(1);
 BEGIN
 /* IF my_text is NULL THEN
 Proc := 'P';
 ELSE
 Proc := 'F';
 END IF; */
 INSERT INTO migr_case_log@ofsprd
 (esn
 ,receipt_number
 ,process_date
 ,error_message
 ,process_flag)
 VALUES
 (esn
 ,receipt_number
 ,SYSDATE
 ,my_text
 ,flag_type);
 END;

 --#############################################################################################
 --#############################################################################################
 FUNCTION getsimreplacement(strgsmzipcode IN VARCHAR2) RETURN VARCHAR2 AS
 strreplpartnum VARCHAR2(100) := NULL;
 strcolumn1 sa.carrierzones.sim_profile%TYPE;
 strcolumn2 sa.carrierzones.sim_profile_2%TYPE;
 strcarrierid npanxx2carrierzones.carrier_id%TYPE := NULL;
 BEGIN
 BEGIN
 SELECT carrier_id
 INTO strcarrierid
 FROM (SELECT tab2.carrier_id
 FROM carrierpref cp
 ,table_x_carrier ca
 ,(SELECT DISTINCT b.state
 ,b.county
 ,b.carrier_id
 ,b.gsm_tech
 FROM npanxx2carrierzones b
 ,(SELECT DISTINCT a.zone
 ,a.st
 ,a.sim_profile
 ,a.sim_profile_2
 FROM carrierzones a
 WHERE a.zip = strgsmzipcode) tab1
 WHERE b.zone = tab1.zone
 AND b.state = tab1.st) tab2
 WHERE cp.new_rank = (SELECT MIN(cp.new_rank)
 FROM carrierpref cp
 ,table_x_carrier ca
 ,(SELECT DISTINCT b.state
 ,b.county
 ,b.carrier_id
 ,b.cdma_tech
 ,b.tdma_tech
 ,b.gsm_tech
 FROM npanxx2carrierzones b
 ,(SELECT DISTINCT a.zone
 ,a.st
 ,a.sim_profile
 ,a.sim_profile_2
 FROM carrierzones a
 WHERE a.zip = strgsmzipcode) tab1
 WHERE b.zone = tab1.zone
 AND b.state = tab1.st
 AND b.gsm_tech = 'GSM') tab2
 WHERE cp.county = tab2.county
 AND cp.st = tab2.state
 AND cp.carrier_id = tab2.carrier_id
 AND ca.x_carrier_id = tab2.carrier_id
 AND ca.x_status = 'ACTIVE')
 AND cp.county = tab2.county
 AND cp.st = tab2.state
 AND cp.carrier_id = tab2.carrier_id
 AND tab2.carrier_id = ca.x_carrier_id
 AND ca.x_status = 'ACTIVE'
 AND tab2.gsm_tech = 'GSM')
 WHERE ROWNUM = 1;
 EXCEPTION
 WHEN others THEN
 strcarrierid := NULL;
 END;

 BEGIN
 SELECT sim_profile
 ,sim_profile_2
 INTO strcolumn1
 ,strcolumn2
 FROM (SELECT a.sim_profile
 ,a.sim_profile_2
 FROM sa.carrierzones a
 ,(SELECT DISTINCT b.bta_mkt_number
 ,b.state
 ,b.zone
 FROM sa.npanxx2carrierzones b
 WHERE b.gsm_tech = 'GSM'
 AND b.carrier_id = strcarrierid) b
 WHERE (a.sim_profile IS NOT NULL OR a.sim_profile_2 IS NOT NULL)
 AND a.zip = strgsmzipcode
 AND a.zone = b.zone
 AND a.st = b.state)
 WHERE ROWNUM = 1;

 IF (strcolumn1 IS NOT NULL AND TRIM(strcolumn1) <> '' AND TRIM(UPPER(strcolumn1)) <> 'NULL' AND strcolumn2 IS NOT NULL AND TRIM(strcolumn2) <> '' AND TRIM(UPPER(strcolumn2)) <> 'NULL') THEN
 --that means CINGULAR
 strreplpartnum := strcolumn2;
 ELSE
 strreplpartnum := strcolumn1;
 END IF;
 EXCEPTION
 WHEN others THEN
 strreplpartnum := 'No SIM Part Found';
 END;

 RETURN strreplpartnum;
 END;

 --#############################################################################################
 --#############################################################################################
 PROCEDURE getreplacementpartnum
 (
 stresn IN VARCHAR2
 ,strzipcode IN VARCHAR2
 ,strtype IN VARCHAR2
 ,strnewesn OUT VARCHAR2
 ,strreplpartnum OUT VARCHAR2
 ,strerror OUT VARCHAR2
 ) AS
 strreplacementpartnum VARCHAR2(100) := 'No Part Found For the Given Technology';
 strnewesntech npanxx2carrierzones.cdma_tech%TYPE := NULL;
 stroldesntech table_part_num.x_technology%TYPE := NULL;
 strzippreftech npanxx2carrierzones.cdma_tech%TYPE := NULL;
 blngsmzip BOOLEAN := FALSE;
 -- blnDefault Boolean := false; -- this is for 5180/5125
 strgsmprofile VARCHAR2(100) := NULL;
 stroldpartnumobjid table_part_num.objid%TYPE := NULL;
 strnewpartnumtech VARCHAR2(100) := NULL;
 strtempgsm npanxx2carrierzones.gsm_tech%TYPE;
 my_errm VARCHAR2(32000);

 CURSOR c_carriers IS
 SELECT tab2.cdma_tech
 ,tab2.tdma_tech
 ,tab2.gsm_tech
 ,cp.new_rank
 FROM carrierpref cp
 ,table_x_carrier ca
 ,(SELECT DISTINCT b.state
 ,b.county
 ,b.carrier_id
 ,b.cdma_tech
 ,b.tdma_tech
 ,b.gsm_tech
 FROM npanxx2carrierzones b
 ,(SELECT DISTINCT a.zone
 ,a.st
 ,a.sim_profile
 FROM carrierzones a
 WHERE a.zip = strzipcode) tab1
 WHERE b.zone = tab1.zone
 AND b.state = tab1.st) tab2
 WHERE cp.county = tab2.county
 AND cp.st = tab2.state
 AND cp.carrier_id = tab2.carrier_id
 AND ca.x_carrier_id = tab2.carrier_id
 AND ca.x_status = 'ACTIVE'
 ORDER BY new_rank;
 BEGIN
 --Get the ESN technology and part num objid
 IF LENGTH(stresn) > 0 THEN
 BEGIN
 SELECT parttech
 ,objid
 INTO stroldesntech
 ,stroldpartnumobjid
 -- With this I am sure that I will receive only ONE record.
 FROM (SELECT TRIM(pn.x_technology) parttech
 ,pn.objid
 FROM table_part_inst pi
 ,table_part_num pn
 ,table_mod_level ml
 WHERE pi.part_serial_no = stresn
 AND pi.x_domain = 'PHONES'
 AND pi.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid)
 WHERE ROWNUM = 1;
 EXCEPTION
 WHEN others THEN
 NULL;
 END;
 END IF; -- End of strESN Length

 --Get all the technologies supported by active carriers in the zipcode in order of their preference
 FOR r_carriers IN c_carriers LOOP
 BEGIN
 strzippreftech := r_carriers.cdma_tech;

 IF strzippreftech IS NULL
 OR LENGTH(strzippreftech) < 3 THEN
 strzippreftech := r_carriers.tdma_tech;
 --Get CDMA/TDMA
 END IF;

 strnewesntech := strzippreftech;
 strtempgsm := r_carriers.gsm_tech;

 IF strtempgsm IS NOT NULL
 AND UPPER(strtempgsm) = 'GSM' THEN
 blngsmzip := TRUE;
 strnewesntech := strtempgsm;
 END IF;

 IF ((stroldesntech = 'TDMA' OR stroldesntech = 'CDMA') AND (UPPER(stroldesntech) = UPPER(strzippreftech)))
 OR (stroldesntech = 'GSM' AND blngsmzip) THEN
 strnewpartnumtech := stroldesntech;
 --Try to assign the same technology phone
 ELSE
 strnewpartnumtech := strzippreftech;
 END IF;

 --Find the replacement part
 BEGIN
 SELECT part_number
 INTO strreplacementpartnum
 FROM (SELECT pn.part_number
 FROM table_x_exch_options exch
 ,table_part_num pn
 WHERE exch.exch_source2part_num = stroldpartnumobjid
 AND exch_target2part_num = pn.objid
 AND pn.x_technology = strnewpartnumtech
 AND exch.x_exch_type = strtype
 ORDER BY exch.x_priority ASC)
 WHERE ROWNUM = 1;
 EXCEPTION
 WHEN others THEN
 strreplacementpartnum := NULL;
 END;

 IF strreplacementpartnum IS NULL THEN
 BEGIN
 IF stroldesntech = 'GSM'
 AND blngsmzip THEN
 --If GSM replacement not found for GSM phone, get CDMA/TDMA replacement
 blngsmzip := FALSE;

 BEGIN
 SELECT part_number
 INTO strreplacementpartnum
 FROM (SELECT pn.part_number
 FROM table_x_exch_options exch
 ,table_part_num pn
 WHERE exch.exch_source2part_num = stroldpartnumobjid
 AND exch_target2part_num = pn.objid
 AND pn.x_technology = strzippreftech
 AND exch.x_exch_type = strtype
 ORDER BY exch.x_priority ASC)
 WHERE ROWNUM = 1;
 EXCEPTION
 WHEN others THEN
 NULL;
 END;
 END IF;
 END;
 END IF;

 IF blngsmzip
 AND stroldesntech = 'GSM' THEN
 --For GSM phones get the SIM profile as well
 strgsmprofile := getsimreplacement(strzipcode);

 IF LENGTH(strgsmprofile) > 0 THEN
 strgsmprofile := SUBSTR(strgsmprofile
 ,LENGTH(strgsmprofile) - 1);
 END IF;

 strreplacementpartnum := strreplacementpartnum || strgsmprofile;
 END IF;

 IF strreplacementpartnum <> 'No Part Found For the Given Technology' THEN
 EXIT;
 END IF;
 END;
 END LOOP;

 strnewesn := strnewesntech;
 strreplpartnum := strreplacementpartnum;
 EXCEPTION
 WHEN others THEN
 my_errm := SQLERRM;
 strnewesn := NULL;
 strreplpartnum := NULL;
 my_errm := 'ZipCode:' || strzipcode || ', ESN: ' || stresn || ', ' || my_errm;
 strerror := my_errm;
 END;

 --#############################################################################################
 --#############################################################################################
 -- PROCEDURE CheckReplPartInNull
 -- AS
 -- strError VARCHAR2(100);
 -- newEsn table_case.x_esn%TYPE;
 -- newReplPartNum table_case.x_repl_part_num%TYPE;
 -- CURSOR c_Cases
 -- IS
 -- SELECT c.objid,
 -- c.x_esn,
 -- c.alt_zipcode,
 -- c.x_case_type,
 -- c.rowid MyRowid
 -- FROM table_x_part_requesto a, table_case c
 -- WHERE a.x_flag_migration = 'Y'
 -- AND a.x_Migra2x_Case = c.objid
 -- AND c.X_REPL_PART_NUM
 -- IS
 -- NULL;
 -- BEGIN
 -- FOR r_Cases IN c_Cases
 -- LOOP
 -- getReplacementPartNum(r_Cases.x_Esn, r_Cases.Alt_Zipcode, UPPER(
 -- r_Cases.x_Case_Type), newEsn, newReplPartNum, strError);
 -- IF newReplPartNum
 -- IS
 -- NOT NULL
 -- THEN
 -- UPDATE table_Case SET x_repl_part_num = newReplPartNum
 -- WHERE ROWID = r_Cases.MyRowid;
 -- END IF;
 -- END LOOP;
 -- NULL;
 -- END;
 --#############################################################################################
 --#############################################################################################
 PROCEDURE exchangeesn
 (
 r_case IN table_case%ROWTYPE
 ,esn IN VARCHAR2
 ,tracking IN VARCHAR2
 ,gbstobjid IN NUMBER
 ,userid IN NUMBER
 ,RESULT OUT VARCHAR2
 ) AS
 l_alt_status table_x_alt_esn.x_status%TYPE;
 l_alt_replace table_x_alt_esn.x_replacement_esn%TYPE;
 l_void VARCHAR2(1000);
 l_cond VARCHAR2(100);
 l_lst_objid table_gbst_lst.objid%TYPE;
 l_result VARCHAR2(1000) DEFAULT '';
--cwl 4/10/12 CR19663
 cursor check_esn_curs(c_esn in varchar2) is
 select part_serial_no
 from table_part_inst
 where part_serial_no = c_esn
 and x_domain = 'PHONES';
 check_esn_rec check_esn_curs%rowtype;
--cwl 4/10/12 CR19663
 BEGIN
 RESULT := '';

 BEGIN
 SELECT 'x'
 INTO l_void
 FROM table_contact
 WHERE objid = r_case.case_reporter2contact;
 EXCEPTION
 WHEN no_data_found THEN
 RESULT := 'Contact not found';
 END;

 BEGIN
 SELECT e.x_status
 ,e.x_replacement_esn
 INTO l_alt_status
 ,l_alt_replace
 FROM table_x_alt_esn e
 WHERE e.x_alt_esn2case = r_case.objid;
 EXCEPTION
 WHEN no_data_found THEN
 RESULT := 'Alt ESN record not found';
 END;

 IF l_alt_status = 'CLOSED' THEN
 RESULT := 'Case already processed';
 END IF;

 IF l_alt_replace IS NOT NULL THEN
 RESULT := 'New ESN already linked to case';
 END IF;

 BEGIN
 IF r_case.x_require_return <> 1 THEN
 l_cond := 'Closed';
 ELSE
 l_cond := 'Open';
 END IF;

 SELECT objid
 INTO l_lst_objid
 FROM table_gbst_lst
 WHERE title = l_cond;
 EXCEPTION
 WHEN others THEN
 l_lst_objid := NULL;
 END;

 BEGIN
 IF r_case.x_require_return <> 2 THEN
 l_cond := 'Shipped';
 ELSE
 l_cond := 'Received';
 END IF;

 SELECT 'x'
 INTO l_void
 FROM table_gbst_elm e
 WHERE title = l_cond
 AND e.gbst_elm2gbst_lst = l_lst_objid;
 EXCEPTION
 WHEN others THEN
 RESULT := 'Error In The Application Status Codes';
 END;

 BEGIN
 SELECT 'x'
 INTO l_void
 FROM table_x_code_table
 WHERE x_code_name = 'EXCHANGE PARTNER';
 EXCEPTION
 WHEN others THEN
 RESULT := 'Default Warehouse Dealer Not Found';
 END;

--cwl 4/10/12 CR19663
 open check_esn_curs(r_case.x_esn);
 fetch check_esn_curs into check_esn_rec;
 if check_esn_curs%notfound then
 RESULT := 'Original ESN Missing from Case';
 end if;
 close check_esn_curs;
--cwl 4/10/12 CR19663
/* CR19663
 IF LENGTH(TRIM(r_case.x_esn)) <> 11
 AND LENGTH(TRIM(r_case.x_esn)) <> 15
 AND LENGTH(TRIM(r_case.x_esn)) <> 18 -- CR6254 Meid numbers
 THEN
 RESULT := 'Original ESN Missing from Case';
 END IF;
*/

 update_exch_case_batch_prc(r_case.objid
 ,esn
 ,tracking
 ,userid
 ,gbstobjid
 ,l_result);

 IF NVL(TRIM(l_result)
 ,' ') <> ' ' THEN
 RESULT := l_result;
 END IF;
 END exchangeesn;

 --#############################################################################################
 --#############################################################################################
 /*************************************************************************
 * Procedure: Send_Cases
 * Purpose : To send to OFS those cases that should be process by Intellitrak
 **************************************************************************/

 PROCEDURE send_cases AS
 -- CR22149 Shipping Address Hot List Implementation new cursor
 CURSOR c_Hot_List (ip_address varchar2, ip_city varchar2, ip_state varchar2, ip_zipcode varchar2)
 is
 select * from address_hot_list
 where REPLACE (REPLACE (x_address,'|',''),' ','') = REPLACE (REPLACE (ip_address,'|',''),' ','')
 and UPPER(x_city) = UPPER(ip_city)
 and UPPER(x_state) = UPPER(ip_state)
 and UPPER(x_zipcode) = UPPER(ip_zipcode) ;
 r_Hot_List c_Hot_List%rowtype ;

 --CR28855 - Multiple Replacements for same class(for accessories same part). Only last replacement part will be sent
 CURSOR c_cases_dup_rep
 IS
 SELECT pr.OBJID,
 DECODE(pr.x_part_num_domain,'ACC',pn.description,pr.x_part_num_domain) domainorpart,
 pr.x_date_process,
 pr.x_repl_part_num
 FROM table_x_part_request pr,
 table_part_num pn
 WHERE pr.x_repl_part_num = pn.part_number
 AND pr.X_STATUS = 'PENDING'
-- AND pr.x_date_process IS NOT NULL (Requirement change as per Defect 21 of CR28855)
 AND pr.x_part_num_domain IS NOT NULL
 AND PR.objid not in (SELECT MAX(PR1.objid)
 FROM table_x_part_request PR1,
 table_part_num PN1
 WHERE PR1.X_REPL_PART_NUM = PN1.PART_NUMBER
 AND PR1.X_STATUS = 'PENDING'
 -- AND PR1.X_DATE_PROCESS IS NOT NULL (Requirement change as per Defect 21 of CR28855)
 AND NVL(PR1.X_DATE_PROCESS,SYSDATE) = NVL(PR.X_DATE_PROCESS,SYSDATE)
 AND PR1.X_PART_NUM_DOMAIN IS NOT NULL
 AND DECODE(PR1.X_PART_NUM_DOMAIN,'ACC',PN1.DESCRIPTION,PR1.X_PART_NUM_DOMAIN) = DECODE(PR.X_PART_NUM_DOMAIN,'ACC',PN.DESCRIPTION,PR.X_PART_NUM_DOMAIN)
 GROUP BY request2casE
 );

 TYPE r_cases_dup_rep_type IS TABLE OF c_cases_dup_rep%ROWTYPE;
 r_cases_dup_rep r_cases_dup_rep_type;

 CURSOR c_cases IS
 SELECT a.rowid row_id
 ,a.*
 FROM table_x_part_request a
 WHERE a.x_status = 'PENDING'
 AND a.x_repl_part_num IS NOT NULL
 --CR19390 Start kacosta 03/02/2012
 AND NVL(a.x_ff_center
 ,'-1') <> 'MM_IO';
 --CR19390 End kacosta 03/02/2012
 --cwl 4/23 FOR UPDATE OF x_flag_migration;
 CURSOR c_cases_hold IS
 SELECT *
 FROM table_x_part_request a
 WHERE 1 = 2;
 r_cases_hold c_cases_hold%ROWTYPE;

 /*** CR8585 added cursor to get values from table_x_case_detail **/
 CURSOR c_case_detail(c_objid IN NUMBER) IS
 SELECT cd.x_value
 FROM table_x_case_detail cd
 WHERE c_objid = cd.detail2case
 AND cd.x_name || '' = 'LIFELINEID';
 r_case_detail c_case_detail%ROWTYPE;

 /**** CR5336: Added cursor to include case data *****/
 CURSOR c_case_title(c_objid IN NUMBER) IS
 SELECT c.*
 ,g.title g_status
 ,c.alt_e_mail as e_mail -- CR22080 CHANGED from f.e_mail
 FROM table_gbst_elm g
 ,table_case c
 ,table_contact f
 WHERE c.casests2gbst_elm = g.objid(+)
 AND c.case_reporter2contact = f.objid(+)
 AND c.objid = c_objid;
 --CR39517
 CURSOR c_cases_onhold
 IS
 SELECT pr.OBJID,
 pr.x_date_process,
 pr.x_repl_part_num,
 tc.case_type_lvl2 case_type_lvl2
 FROM table_x_part_request pr,
 table_case tc
 WHERE pr.X_STATUS = 'PENDING'
 AND pr.x_part_num_domain <> 'ACC'
 AND pr.request2case = tc.objid
 AND tc.title not in ('Lifeline Shipment','Business Sales Service Shipment','Business Sales Direct Shipment','SafeLink BroadBand Shipment')
 AND EXISTS
 (SELECT 1
 FROM table_x_part_request pr1,
 table_case tc2
 WHERE PR1.X_STATUS = 'PENDING'
 --AND trunc(pr1.x_date_process) = trunc(pr.x_date_process)
 AND pr1.X_FF_CENTER <> pr.X_FF_CENTER
 AND pr1.x_repl_part_num <> pr.x_repl_part_num
 AND pr1.x_part_num_domain = 'ACC'
 AND pr1.request2case = pr.request2case
 AND pr1.request2case = tc2.objid
 --AND tc2.title not in ('Lifeline Shipment','Business Sales Service Shipment','Business Sales Direct Shipment','SafeLink BroadBand Shipment')
 ) ;

 TYPE r_cases_onhold_type IS TABLE OF c_cases_onhold%ROWTYPE;
 r_cases_onhold r_cases_onhold_type;
 --CR39517

  --CR50138
/*
CURSOR c_cases_safelink_exchange
IS
  SELECT   a.id_number,COUNT(p.objid)
  FROM     table_case a,
           table_x_part_request p
  WHERE    p.x_insert_date >= TRUNC(SYSDATE-1)  --CR52354
  AND      a.objid         = p.request2case
  AND      case_type_lvl2  ='SAFELINK'
  AND      p.x_part_num_domain in ('PHONES','ACC')
  AND      p.x_status = 'PENDING' --55718 Revise Safelink exchange cases M.
  GROUP BY a.id_number
  HAVING COUNT(p.objid) > 1;
*/

--55718 Revise Safelink exchange cases M.  start
CURSOR c_cases_safelink_exchange
IS
  SELECT   a.id_number, a.objid
  FROM     table_case a,
           table_x_part_request p
  WHERE    p.x_insert_date     >= TRUNC(SYSDATE-1)  --CR52354
  AND      a.objid             =  p.request2case
  AND      case_type_lvl2      =  'SAFELINK'
  AND      p.x_part_num_domain =  'ACC'
  AND      p.x_status          =  'PENDING'
  AND      EXISTS (
                    SELECT 1
                    FROM   table_x_part_request phn
                    WHERE  phn.x_part_num_domain =  'PHONES'
                    AND    a.objid               =  phn.request2case
                  );
--55718 Revise Safelink exchange cases M.  end

 TYPE r_cases_safelink_exchange_type IS TABLE OF c_cases_safelink_exchange%ROWTYPE;
 r_cases_safelink_exchange r_cases_safelink_exchange_type;
 --CR50138

 CURSOR c_sales_order(p_case_id VARCHAR2) IS
 SELECT *
 FROM x_sales_orders
 WHERE NVL(case_id_items
 ,'0') = p_case_id
 OR NVL(case_id_services
 ,'0') = p_case_id;

 r_sales_order c_sales_order%ROWTYPE;

 --*****************Begin comment out by Jasmine on 09/08/2006***********************--
 /**** CR5336: Cursor to get Fulfillment center name ***/
 /*
 CURSOR c_getFF(c_part_num in varchar2)
 IS
 SELECT d.domain,c.x_ff_name,c.x_ff_code
 FROM table_part_class a,
 mtm_part_class7_x_ff_center1 b,
 table_x_ff_center c,
 table_part_num d
 WHERE 1=1
 AND d.part_number = c_part_num
 AND a.objid = d.PART_NUM2PART_CLASS
 AND a.objid = b.part_class2ff_center
 AND b.FF_CENTER2PART_CLASS = c.objid;
 */
 --*****************End comment out by Jasmine on 09/08/2006***********************--
 my_code NUMBER;
 my_errm VARCHAR2(32000);
 /*** CR5336: FF variables ***/
 --v_ff_name varchar2(80);
 v_ff_code VARCHAR2(80);
 v_carrier VARCHAR2(80);
 v_method VARCHAR2(80);
 v_ship_to_address1 VARCHAR2(240); --Add by Jasmine on 09/08/2006
 v_ship_to_address2 VARCHAR2(240); --Add by Jasmine on 09/08/2006
 v_llid table_x_case_detail.x_value%TYPE; --CR8585
 V_ACCOUNT_ID VARCHAR2(30);
 v_case_history VARCHAR2(32000) ; -- CR22149 Shipping Address Hot List Implementation
 error_no NUMBER ; -- CR22149 Shipping Address Hot List Implementation
 error_str VARCHAR2(500) ; -- CR22149 Shipping Address Hot List Implementation -- CR46164 - Increase length from 30 to 500
 -- CR22860
 V_WTYCWGTAX NUMBER;
 v_ret_price number;

 LV_STATUS_UPDATE_FLAG	VARCHAR2(2);	--	CR46157

 BEGIN
 --CR28855 - Cancelling duplicate requests
 OPEN c_cases_dup_rep;
 FETCH c_cases_dup_rep BULK COLLECT INTO r_cases_dup_rep;
 FORALL i IN r_cases_dup_rep.FIRST..r_cases_dup_rep.LAST
 UPDATE table_x_part_request
 SET x_date_process = NULL, -- Changes made as part of CR45831 03/23/2017
 x_status = 'CANCEL_REQUEST',
 x_problem = 'Multiple Replacements for same case. Only the last replacement part will be processed'
 WHERE objid = r_cases_dup_rep(i).objid;
 FORALL i IN r_cases_dup_rep.FIRST..r_cases_dup_rep.LAST
 UPDATE table_case
 SET case_history = '***NOTES*** from source SEND_CASES - CR 28855 - Multiple replacements for same case. Only the last replacement part will be processed.'
 WHERE objid in (SELECT request2case FROM table_x_part_request WHERE objid = r_cases_dup_rep(i).objid);
 CLOSE c_cases_dup_rep;
 -- CheckReplPartInNull;

 --CR39517
 OPEN c_cases_onhold;
 FETCH c_cases_onhold BULK COLLECT INTO r_cases_onhold ;
 FORALL i IN r_cases_onhold.FIRST..r_cases_onhold.LAST
  UPDATE table_x_part_request
  SET    x_date_process = NULL, -- Changes made as part of CR45831 03/23/2017
         x_status ='ONHOLDST'
  WHERE  objid = r_cases_onhold(i).objid
  AND    NVL(r_cases_onhold(i).case_type_lvl2, 'X') != 'SAFELINK'; --EME 52229
 CLOSE c_cases_onhold;
 --CR39517

 /*
 --CR50138
OPEN c_cases_safelink_exchange;
FETCH c_cases_safelink_exchange BULK COLLECT INTO r_cases_safelink_exchange;
FORALL i IN r_cases_safelink_exchange.first..r_cases_safelink_exchange.last
 UPDATE table_x_part_request p
 SET p.x_status = 'CANCEL_REQUEST'
 WHERE p.request2case IN (select a.objid from table_case a, table_x_part_request p
where a.id_number = r_cases_safelink_exchange(i).id_number
and a.creation_time >= trunc(sysdate-1)
and a.objid = p.request2case
and case_type_lvl2='SAFELINK'
and p.x_part_num_domain in ('ACC')
and p.x_status = 'PENDING'
and p.x_repl_part_num in ('TF-EX-AIRBILL','NT-EX-AIRBILL'))
and p.x_part_num_domain in ('ACC')
and p.x_status = 'PENDING';
CLOSE c_cases_safelink_exchange;
 --CR50138
*/

--55718 Revise Safelink exchange cases M.  start
OPEN c_cases_safelink_exchange;

FETCH c_cases_safelink_exchange BULK COLLECT INTO r_cases_safelink_exchange;

FORALL i IN r_cases_safelink_exchange.FIRST..r_cases_safelink_exchange.LAST
 UPDATE  table_x_part_request p
 SET     p.x_status          = 'CANCEL_REQUEST'
 WHERE   p.request2case      = r_cases_safelink_exchange(i).objid
 AND     p.x_part_num_domain = 'ACC'
 AND     p.x_status          = 'PENDING';

CLOSE c_cases_safelink_exchange;
--55718 Revise Safelink exchange cases M.  end

 FOR r_cases IN c_cases LOOP
 --cwl 4/23
 SELECT *
 INTO r_cases_hold
 FROM table_x_part_request a
 WHERE ROWID = r_cases.row_id
 FOR UPDATE NOWAIT;
 --cwl 4/23

 v_ff_code := r_cases.x_ff_center;
 v_carrier := r_cases.x_courier;
 v_method := r_cases.x_shipping_method;

 FOR r_case_title IN c_case_title(r_cases.request2case) LOOP
 IF r_case_title.case_type_lvl2 LIKE 'B2B%' THEN
 OPEN c_sales_order(r_case_title.id_number);
 FETCH c_sales_order
 INTO r_sales_order;
 IF c_sales_order%FOUND THEN
 v_account_id := r_sales_order.account_id;
 ELSE
 v_account_id := 'Not Found';
 END IF;
 CLOSE c_sales_order;
 END IF;
 IF INSTR(NVL(r_case_title.alt_address
 ,'')
 ,'|') = 0 THEN
 v_ship_to_address1 := r_case_title.alt_address;
 v_ship_to_address2 := NULL;
 ELSE
 v_ship_to_address1 := SUBSTR(r_case_title.alt_address
 ,1
 ,INSTR(r_case_title.alt_address
 ,'|') - 1);
 v_ship_to_address2 := SUBSTR(r_case_title.alt_address
 ,INSTR(r_case_title.alt_address
 ,'|'
 ,-1) + 1);
 END IF;

 --CR8585
 v_llid := ' ';
 dbms_output.put_line('r_case_title.objid ' || r_case_title.objid);

 OPEN c_case_detail(r_case_title.objid);
 FETCH c_case_detail
 INTO r_case_detail;

 IF c_case_detail%NOTFOUND THEN
 v_llid := ' ';
 ELSE
 v_llid := r_case_detail.x_value;
 END IF;

 CLOSE c_case_detail;
 --CR8585

 -- CR22149 Shipping Address Hot List Implementation
 OPEN c_Hot_List (R_CASE_TITLE.ALT_address,R_CASE_TITLE.ALT_city,R_CASE_TITLE.ALT_state,R_CASE_TITLE.ALT_zipcode);
 FETCH c_Hot_List
 INTO r_Hot_List ;
 IF c_Hot_List%FOUND THEN
 UPDATE table_x_part_request
 SET x_flag_migration = 'E'
 ,x_date_process = NULL -- Changes made as part of CR45831 03/23/2017
 ,x_problem = 'There is a problem with the shipping address for this case. Please contact LPD at ext. 3001'
 ,x_status = 'CANCEL_REQUEST'
 WHERE ROWID = r_cases.row_id;
 COMMIT ;
 clarify_case_pkg.close_case ( r_case_title.objid,268435556,null,null,'Closed',error_no,error_str) ;
 select case_history into v_case_history from table_case where objid = r_case_title.objid ;
 v_case_history := v_case_history || CHR(10) || CHR(13) || '*** NOTES *** From source Send_Cases '|| sysdate || CHR(10) || CHR(13) || 'There is a problem with the shipping address for this case. Please contact LPD at ext. 3001' ;
 update table_case
 set case_history = v_case_history
 where objid = r_case_title.objid ;
 commit ;
 CLOSE c_Hot_List ;
 clarify_case_pkg.log_notes
 ( r_case_title.objid,
 268435556,
 '*** There is a problem with the shipping address for this case. Please contact LPD at ext. 3001',
 'Fraud Case',
 error_no,
 error_str) ;
 update table_notes_log
 set commitment='FRAUD CASE' where case_notes2case=r_case_title.objid ;
 commit ;

 -- CR22149 Shipping Address Hot List Implementation END
 --*****************End added by Jasmine on 09/08/2006***********************--

		-- length change from 9 to 8 based on CR43880
		-- length change from 8 to 5 as part of CR47935
 elsIF (LENGTH(v_ship_to_address1) < 5 OR v_ship_to_address1 IN ('No Address Provided'
 ,'No Info Available') OR LTRIM(RTRIM(r_case_title.alt_first_name)) IS NULL) --CR5980
 THEN

 UPDATE table_x_part_request
 SET x_flag_migration = 'E'
 ,x_date_process = NULL -- Changes made as part of CR45831 03/23/2017
 ,x_problem = 'Invalid Address: Address is too short'
 ,x_status = 'PENDING'
 WHERE ROWID = r_cases.row_id;
 --cwl 4/23 WHERE CURRENT OF c_cases;
 --Begin CR8480
 ELSIF LENGTH(v_ship_to_address1) > 30 THEN
 UPDATE table_x_part_request
 SET x_flag_migration = 'E'
 ,x_date_process = NULL -- Changes made as part of CR45831 03/23/2017
 ,x_problem = ' Address 1 > 30'
 ,x_status = 'ONHOLD'
 WHERE ROWID = r_cases.row_id;
 --End CR8480
 ELSIF r_cases.x_ff_center IS NULL THEN
 UPDATE table_x_part_request
 SET x_flag_migration = 'E'
 ,x_date_process = NULL -- Changes made as part of CR45831 03/23/2017
 ,x_problem = 'Invalid FF Center: FF Center is null'
 ,x_status = 'PENDING'
 WHERE ROWID = r_cases.row_id;

 --CR43598 Address validation
 ELSIF r_case_title.alt_address is null or r_case_title.alt_city is null or r_case_title.alt_state is null or r_case_title.alt_zipcode is null then

 UPDATE table_x_part_request
 SET x_flag_migration = 'E'
 ,x_date_process = NULL -- Changes made as part of CR45831 03/23/2017
 ,x_problem = 'Invalid Address: '|| Case when r_case_title.alt_address is null then 'Address info missing'
 when r_case_title.alt_city is null then 'City info missing'
 when r_case_title.alt_state is null then 'State info missing'
 when r_case_title.alt_zipcode is null then 'ZIPCODE not found'
 end

 ,x_status = 'ONHOLD'
 WHERE ROWID = r_cases.row_id;

 --to update the casests2gbst_elm to bad address
 sa.clarify_case_pkg.update_status ( p_case_objid => r_case_title.objid,
 p_user_objid => 268435556, --sa
 p_new_status => 'BadAddress',
 p_status_notes => 'SA.Migra_Intellitrack',
 p_error_no => error_no,
 p_error_str => error_str);
 --CR43598 End Address validation

 --cwl 4/23 WHERE CURRENT OF c_cases;
 ELSE
 BEGIN
 --CR22860 check case for handset protection
 V_WTYCWGTAX := 0;
 v_ret_price := 0;
 IF R_CASE_TITLE.X_CASE_TYPE = 'Handset Program' AND R_CASE_TITLE.TITLE = 'Handset Protection' THEN
 V_RET_PRICE := sa.SP_METADATA.GETPRICE(R_CASES.X_REPL_PART_NUM,'SERVICE NET');
 V_WTYCWGTAX := NVL(sa.SP_TAXES.GET_COMBSTAX(R_CASE_TITLE.ALT_ZIPCODE),0) * ROUND(V_RET_PRICE * NVL(sa.SP_TAXES.COMPUTECWGTAX(R_CASE_TITLE.ALT_ZIPCODE),0),2); -- CR22860 06/25/2013
 -- v_WtyCWGTax := sa.sp_taxes.computeCWGtax(R_CASE_TITLE.alt_zipcode) * sa.sp_taxes.get_combstax(R_CASE_TITLE.alt_zipcode); -- CR22860 06/25/2013
 END IF;
 --CR22860 end
 --CR19566 Start Kacosta 01/27/2012
 --INSERT INTO tf.tf_order_interface@ofsprd --for unit test @ofsprod
 INSERT INTO sa.temp_tf_order_interface
 --CR19566 End Kacosta 01/27/2012
 (title
 ,status
 ,tf_part_number
 ,po_number
 ,ship_to_name
 ,ship_to_address
 ,ship_to_address2
 ,
 --Add by Jasmine on 09/08/2006
 ship_to_city
 ,ship_to_state
 ,ship_to_zip
 ,ship_to_phone
 ,quantity
 ,ship_to_email
 ,customer_number
 ,store_number
 ,SOURCE
 ,creation_date
 ,delivery_date
 ,ff_name
 ,carrier
 ,method
 ,LLID --CR8585
 ,AMOUNT --CR22860
 ,TAX_AMOUNT --CR22860
 ,OLD_ESN --CR22860
 )
 VALUES
 (r_case_title.title
 ,r_case_title.g_status
 ,r_cases.x_repl_part_num
 ,r_case_title.id_number
 ,r_case_title.alt_first_name || ' ' || r_case_title.alt_last_name
 ,
 --r_case_title.ALT_ADDRESS,--Comment out by Jasmine on 09/08/2006
 v_ship_to_address1
 ,
 --Add by Jasmine on 09/08/2006
 v_ship_to_address2
 ,
 --Add by Jasmine on 09/08/2006
 r_case_title.alt_city
 ,r_case_title.alt_state
 ,r_case_title.alt_zipcode
 ,r_case_title.alt_phone
 , --CR5980
 NVL(r_cases.x_quantity
 ,1)
 , -- nguada 4/16/09 B2B
 r_case_title.e_mail
 ,
 getCustomerAccount( R_CASE_TITLE.X_CASE_TYPE,R_CASE_TITLE.TITLE,R_CASE_TITLE.CASE_TYPE_LVL2,R_CASE_TITLE.X_ESN) --CR43690
 , --Added by Jasmine on 09/13/2006
 '0616960000013'
 ,DECODE(r_case_title.case_type_lvl2
 ,'LIFELINE'
 ,'LIFELINE'
 ,'B2B-DIRECT'
 ,'B2B'
 ,'B2B-SERVICES'
 ,'B2B'
 ,'SL-BROADBAND'
 ,'LIFELINE'
 ,'CLARIFY') -- CR22860 :: Include HPP Case name
 ,TO_CHAR(TRUNC(SYSDATE))
 ,TO_CHAR(TRUNC(SYSDATE) + 3)
 ,v_ff_code
 ,v_carrier
 ,v_method
 ,DECODE(r_case_title.case_type_lvl2
 ,'B2B-DIRECT'
 ,v_account_id
 ,'B2B-SERVICES'
 ,V_ACCOUNT_ID
 ,V_LLID)
 ,V_RET_PRICE -- AMOUNT CR22860
 ,V_WTYCWGTAX -- tax_amount CR22860
 ,R_CASE_TITLE.x_esn -- OLD_ESN CR22860
 );

 ---------- *************** CR22860 : New Insert statement begin ******************** -------------

 -- CR22860 :: Insert into HPP_CLAIMS table
 -- SN_CLAIMS_HISTORY (should be clone of temp_tf_order_interface for now)


 INSERT INTO sa.SN_CLAIMS_HISTORY
 (title
 ,status
 ,tf_part_number
 ,po_number
 ,ship_to_name
 ,ship_to_address
 ,ship_to_address2
 ,ship_to_city
 ,ship_to_state
 ,ship_to_zip
 ,ship_to_phone
 ,quantity
 ,ship_to_email
 ,customer_number
 ,store_number
 ,SOURCE
 ,creation_date
 ,delivery_date
 ,ff_name
 ,carrier
 ,method
 ,LLID
 ,AMOUNT -- CR22860
 ,TAX_AMOUNT --CR22860
 ,OLD_ESN -- CR22860
 )
 VALUES
 (r_case_title.title
 ,r_case_title.g_status
 ,r_cases.x_repl_part_num
 ,r_case_title.id_number
 ,r_case_title.alt_first_name || ' ' || r_case_title.alt_last_name
 ,v_ship_to_address1
 ,v_ship_to_address2
 ,r_case_title.alt_city
 ,r_case_title.alt_state
 ,r_case_title.alt_zipcode
 ,r_case_title.alt_phone
 ,NVL(r_cases.x_quantity,1)
 ,r_case_title.e_mail
 , DECODE ( R_CASE_TITLE.X_CASE_TYPE , 'Handset Program','CWG212', --CR22860 customer number
 DECODE(R_CASE_TITLE.CASE_TYPE_LVL2 -- Customer Number
 ,'TRACFONE'
 ,'TW640'
 ,'NET10'
 ,'NW640'
 ,'LIFELINE'
 ,'USACSL'
 ,'B2B-DIRECT'
 ,'B2BDIR'
 ,'B2B-SERVICES'
 ,'B2BSER'
 ,'SAFELINK'
 ,'SLE305'
 , --CR19376
 'STRAIGHT_TALK'
 ,'STE305'
 ,'TELCEL' -- CR20854 TELCEL
 ,'TE305' --,'T305' --CR23647
 -- ,'SIMPLE_MOBILE' --CR22452 SIMPLE MOBILE --CR29673 Simple mobile does not SME305
 -- ,'SME305'
 ,'SL-BROADBAND'
 ,'MGPS303' --CR23889
 , --CR19376
 'TW640'))
 , --Added by Jasmine on 09/13/2006
 '0616960000013'
 ,DECODE(r_case_title.case_type_lvl2
 ,'LIFELINE'
 ,'LIFELINE'
 ,'B2B-DIRECT'
 ,'B2B'
 ,'B2B-SERVICES'
 ,'B2B'
 ,'SL-BROADBAND'
 ,'LIFELINE'
 ,'CLARIFY')
 ,TO_CHAR(TRUNC(SYSDATE))
 ,TO_CHAR(TRUNC(SYSDATE) + 3)
 ,v_ff_code
 ,v_carrier
 ,v_method
 ,DECODE(r_case_title.case_type_lvl2
 ,'B2B-DIRECT'
 ,v_account_id
 ,'B2B-SERVICES'
 ,V_ACCOUNT_ID
 ,V_LLID)
 , V_RET_PRICE --AMOUNT CR22860
 , V_WTYCWGTAX --tax_amount CR22860
 ,R_CASE_TITLE.x_esn -- OLD_ESN CR22860
 );

 ---------- *************** CR22860 : New Insert statement End ******************** -------------

 UPDATE table_x_part_request
 SET x_flag_migration = 'S'
 ,x_date_process = SYSDATE
 ,x_problem = NULL
 ,x_status = 'PROCESSED'
 WHERE ROWID = r_cases.row_id;
 --cwl 4/23 WHERE CURRENT OF c_cases;

	--CR46157

	BEGIN
		SELECT X_PARAM_VALUE
		INTO LV_STATUS_UPDATE_FLAG
		FROM TABLE_X_PARAMETERS
		WHERE X_PARAM_NAME = 'ENABLE_MIGRA_SEND_CASE_STATUS_INPROCESS'
		;

	EXCEPTION WHEN OTHERS
	THEN

		LV_STATUS_UPDATE_FLAG	:=	'N';

	END;

	IF LV_STATUS_UPDATE_FLAG	= 'Y'
	THEN


		sa.clarify_case_pkg.update_status ( p_case_objid => r_case_title.objid,
							p_user_objid => 268435556, --sa
							p_new_status => 'In Process',
							p_status_notes => 'Migra_Intellitrack',
							p_error_no => error_no,
							p_error_str => error_str);
	END IF;
	--CR46157

 EXCEPTION
 WHEN others THEN
 my_code := SQLCODE;
 my_errm := SQLERRM;
 UPDATE table_x_part_request
 SET x_flag_migration = 'E'
 ,x_date_process = NULL -- Changes made as part of CR45831 03/23/2017
 ,x_problem = 'Oracle error occurred (error code) : ' || my_code
 , --CR19376
 x_status = 'ONHOLD'
 WHERE ROWID = r_cases.row_id;
 --cwl 4/23 WHERE CURRENT OF c_cases;
 END;
 END IF;
 --CR19566 Start kacosta 01/31/2012
 --COMMIT;
 --CR19566 End kacosta 01/31/2012
 if c_Hot_List%isopen
 then
 close c_Hot_List ;
 end if ;
 END LOOP;
 --CR19566 Start kacosta 01/31/2012
  -- CR45831 changes starts 03/14/2017
 UPDATE sa.table_x_part_request
  SET x_date_process      =  NULL
 WHERE NVL(x_status,'XXX') <> 'PROCESSED'
  AND ROWID               =  r_cases.row_id ;
 -- CR45831 changes ends 03/14/2017
 COMMIT;
 --CR19566 End kacosta 01/31/2012
 END LOOP;
 END send_cases;

 --#############################################################################################
 --#############################################################################################
 /*************************************************************************
 * Procedure: Bad_Address
 * Purpose : To process those cases that were not posible to be committed
 * because a bad address.
 **************************************************************************/
 PROCEDURE bad_address
 (
 ip_case_number IN VARCHAR2
 ,ip_order_number IN NUMBER
 ) AS
 l_status_id table_gbst_elm.objid%TYPE;
 p_error_number NUMBER;
 p_error_message VARCHAR2(1000);
 l_sa table_user.objid%TYPE;
 my_code NUMBER;
 my_errm VARCHAR2(32000);
 /*
 TYPE c_Bad IS RECORD (
 tf_receipt_type tf_receipt_headers.tf_receipt_type@ofsprd%TYPE,
 tf_receipt_number tf_receipt_headers.tf_receipt_number@ofsprd%TYPE,
 tf_part_number tf_receipt_headers.tf_part_number@ofsprd%TYPE,
 t_case_number tf_receipt_headers.attribute6@ofsprd%TYPE);

 r_Bad c_Bad;

 TYPE Bad_tab_type IS TABLE OF c_Bad index by binary_integer;

 Bad_tab Bad_tab_type;

 cursor c1 is
 select * from TF.TF_MWH_BAD_ADDRESS@ofsprd;

 cursor c2(c_tf_doc_number in varchar2) is
 select
 rh.tf_receipt_type,
 rh.tf_receipt_number,
 rh.tf_part_number,
 rh.attribute6 t_case_number
 from
 tf.tf_receipt_lines@ofsprd rl,
 tf.tf_receipt_headers@ofsprd rh
 where 1=1
 AND rl.tf_part_number = rh.tf_part_number
 AND rl.tf_receipt_number = rh.tf_receipt_number
 AND rl.tf_receipt_type = rh.tf_receipt_type
 and rl.TF_RECEIVED_LOC = rh.TF_RECEIVED_LOC
 --
 AND rh.ATTRIBUTE7 = 'BAD_ADD'
 and rh.TF_RECEIPT_TYPE = 'R2'
 and rh.TF_RECEIVED_LOC = 'MM_IO'
 AND rh.tf_doc_number = c_tf_doc_number;

 cursor c3(c_tf_serial_num in varchar2, c_tf_receipt_number in number) is
 SELECT 'x' col1
 FROM tf.migr_case_log@ofsprd
 WHERE process_flag = 'P'
 AND esn = c_tf_serial_num
 AND receipt_number = c_tf_receipt_number;

 c3_rec c3%rowtype;

 -- CR 4691 End
 cnt number := 0;
 l_esn table_case.x_esn%Type;
 l_objid table_case.objid%type;
 */
 l_error BOOLEAN;
 BEGIN
 SELECT objid
 INTO l_status_id
 FROM table_gbst_elm
 WHERE title = 'Modify';

 SELECT objid
 INTO l_sa
 FROM table_user t
 WHERE login_name = 'sa';

    /*
    FOR c1_rec IN c1 LOOP
    FOR c2_rec IN c2(c1_rec.tf_doc_number) LOOP
    open c3(c2_rec.t_case_number,c2_rec.tf_receipt_number);
    FETCH c3 INTO c3_rec;
    IF c3%notfound THEN
    cnt := cnt + 1;
    Bad_tab(cnt).tf_receipt_type := c2_rec.tf_receipt_type;
    Bad_tab(cnt).tf_receipt_number := c2_rec.tf_receipt_number;
    Bad_tab(cnt).tf_part_number := c2_rec.tf_part_number;
    Bad_tab(cnt).t_case_number := c2_rec.t_case_number;
    END IF;
    close c3;
    END loop;
    END loop;
    */

    /*
    IF cnt > 0 THEN
    FOR j IN Bad_tab.FIRST..Bad_tab.LAST loop
    COMMIT;
    r_Bad.tf_receipt_type := Bad_tab(j).tf_receipt_type;
    r_Bad.tf_receipt_number := Bad_tab(j).tf_receipt_number;
    r_Bad.tf_part_number := Bad_tab(j).tf_part_number;
    r_Bad.t_case_number := Bad_tab(j).t_case_number;

    p_error_message := '';
    l_error := false;
    */ /*IF p_error_message IS NULL THEN*/ --CR4878
    IF ip_order_number > 0 THEN
      BEGIN
        p_error_number  := 0;
        p_error_message := NULL;
        l_error         := FALSE;
        -- Even if ESN couldn't be retrieved, update case status and remove units
        --UPDATE_REOPEN_WHCASE_PRC(r_Bad.t_case_number, l_sa, l_status_id, p_error_message);
        update_reopen_whcase_prc(ip_case_number
                                ,l_sa
                                ,l_status_id
                                ,p_error_message);

        IF p_error_number <> 0 THEN
          p_error_number := 4;
          l_error        := TRUE;
        END IF;

        -- Flag the case number as 'P' (processed)
        IF p_error_number = 0 THEN
          --Insert_log(r_Bad.t_case_number, r_Bad.tf_receipt_number, null, 'P');
          insert_log(ip_case_number
                    ,ip_order_number
                    ,NULL
                    ,'P');
        ELSIF p_error_number IN (1
                                ,2
                                ,3) THEN
          --Insert_log(r_Bad.t_case_number, r_Bad.tf_receipt_number, p_error_message, 'P');
          insert_log(ip_case_number
                    ,ip_order_number
                    ,p_error_message
                    ,'P');
        END IF;
      EXCEPTION
        WHEN others THEN
          my_code         := SQLCODE;
          my_errm         := SQLERRM;
          l_error         := TRUE;
          p_error_message := my_code || ': ' || my_errm;
      END;

      IF l_error THEN
        ROLLBACK;

        INSERT INTO sa.x_migr_extra_info
          (x_flag_migration
          ,x_date_process
          ,x_problem)
        VALUES
          ('E_BA'
          ,SYSDATE
          ,'Case number ' || ip_case_number || '. ' || p_error_message);

        --Insert_log(r_Bad.t_case_number, r_Bad.tf_receipt_number, p_error_message, 'F');
        insert_log(ip_case_number
                  ,ip_order_number
                  ,p_error_message
                  ,'F');
      END IF;

      COMMIT;
      --END LOOP;
      --END IF;
    END IF;
  END bad_address;

  --#############################################################################################
  --#############################################################################################
  /*************************************************************************
  * Procedure: Phone_Shipping
  * Purpose : To process those cases that were shipped
  **************************************************************************/

  PROCEDURE phone_shipping AS

    CURSOR c1 IS
      SELECT i.rowid
            ,i.po_number
            ,i.serial_number
            ,i.tracking_number
            ,c.objid
            ,c.x_esn -- CR23663
            ,c.x_Case_Type -- CR23663
            ,c.title        -- CR23663
        FROM tf_sl_interface@ofsprd i
            ,table_case             c
       WHERE extract_flag = 'N'
         AND id_number = po_number;

    strcaseobjid VARCHAR2(200);
    strnewesn    VARCHAR2(200);
    stroldesn    VARCHAR2(200); -- CR23663
    is_byop_esn  number := 0;  --1 byop 0 not byop -- CR23663
    strtracking  VARCHAR2(200);
    struserobjid VARCHAR2(200);
    p_error_no   VARCHAR2(200);
    p_error_str  VARCHAR2(200);

  BEGIN

    FOR r1 IN c1 LOOP

      strcaseobjid := r1.objid;
      strnewesn    := r1.serial_number;
      strtracking  := r1.tracking_number;
      stroldesn    := r1.x_esn; -- CR23663
      struserobjid := '268435556'; -- sa objid

      clarify_case_pkg.part_request_ship(strcaseobjid => strcaseobjid
                                        ,strnewesn    => strnewesn
                                        ,strtracking  => strtracking
                                        ,struserobjid => struserobjid
                                        ,p_error_no   => p_error_no
                                        ,p_error_str  => p_error_str);

      IF p_error_no <> '0' THEN

 -- CR20727 Start kacosta 05/03/2012
        --UPDATE tf_sl_interface@ofsprd
        --   SET extract_flag = 'Y'
        --      ,extract_date = SYSDATE
        -- WHERE ROWID = r1.rowid;
   -- CR20727 End kacosta 05/03/2012
        INSERT INTO x_tf_sl_interface_log
          (id_number
          ,insert_date
          ,serial_number
          ,exception_desc
          ,tracking__number)
        VALUES
          (r1.po_number
          ,SYSDATE
          ,r1.serial_number
          ,p_error_str
          ,strtracking);

        COMMIT;

      END IF;
 -- CR20727 Start kacosta 05/03/2012

 -- CR23663  Start
      IF  r1.X_CASE_TYPE = 'Technology Exchange' AND   r1.TITLE = 'SIM Card Exchange' THEN

      begin
    	  select case when part_serial_no = substr(x_iccid,5) then 1
	     		 else 0
		    	 end case
     	  into is_byop_esn
	      from table_part_inst
	      where part_serial_no = stroldesn;
	  exception
	     when others then
		  is_byop_esn := 0;
	  end;

	    if is_byop_esn = 1 then
			 update table_part_inst
			 set part_inst2inv_bin = (select pi.PART_INST2INV_BIN
                                      from table_part_inst pi,
                                           table_inv_bin ib,
                                           table_site s
                                      where pi.PART_INST2INV_BIN = ib.objid
                                      and ib.bin_name = s.site_id
                                      and pi.part_serial_no =  stroldesn) --OLD PSUDO ESN
			 where part_serial_no = strnewesn ;--NEW PSUDO ESN
		end if;
      END IF;
 -- CR23633 end

 UPDATE tf_sl_interface@ofsprd
         SET extract_flag = 'Y'
            ,extract_date = SYSDATE
       WHERE ROWID = r1.rowid;
      COMMIT;
 -- CR20727 End kacosta 05/03/2012
    END LOOP;

  END phone_shipping;
  --#############################################################################################
  --#############################################################################################
  /*************************************************************************
  * Procedure: Phone_Receive
  * Purpose : To process those cases where the phones were receive in the
  * Warehouse. New requirements for non pending cases
  **************************************************************************/
  PROCEDURE phone_receive AS
    l_sa         table_user.objid%TYPE;
    r_table_case table_case%ROWTYPE;
    l_title      table_gbst_elm.title%TYPE;
    l_v          NUMBER(2); --number of valid cases
    l_np         NUMBER(2); --GC number of non-pending cases
    l_np_status  table_gbst_elm.title%TYPE;
    --GC description of the non-pending case
    -- l_nv number(2); --number of not valid cases
    -- dummy varchar2(1);
    l_elm_objid    table_gbst_elm.objid%TYPE;
    l_error        VARCHAR2(200);
    l_case_objid   table_case.objid%TYPE;
    l_case_id      table_case.id_number%TYPE;
    l_case_id_new  table_case.id_number%TYPE;
    l_case_history VARCHAR2(32700);
    my_code        NUMBER;
    my_errm        VARCHAR2(32000);

    -- CR 4691 Starts
    TYPE c_receive IS RECORD(
       tf_receipt_type   tf_receipt_headers.tf_receipt_type@ofsprd%TYPE
      ,tf_receipt_number tf_receipt_headers.tf_receipt_number@ofsprd%TYPE
      ,tf_part_number    tf_receipt_headers.tf_part_number@ofsprd%TYPE
      ,t_esn             tf_receipt_lines.tf_serial_num@ofsprd%TYPE
      ,tf_reason_code    tf_receipt_lines.tf_reason_code@ofsprd%TYPE);

    r_receive c_receive;

    TYPE receive_tab_type IS TABLE OF c_receive INDEX BY BINARY_INTEGER;

    receive_tab receive_tab_type;

    /* CURSOR c_Receive
    IS
    SELECT DISTINCT rh.tf_receipt_type,
    rh.tf_receipt_number,
    rh.tf_part_number,
    rl.tf_serial_num t_esn,
    rl.tf_reason_code
    FROM ont.oe_order_lines_all@ofsprd l, ont.oe_order_headers_all@ofsprd h,
    tf.tf_receipt_headers@ofsprd rh, tf.tf_receipt_lines@ofsprd rl, tf.tf_of_item_v@ofsprd itm
    WHERE h.header_id = l.header_id
    AND TO_CHAR(h.order_number) = rh.tf_doc_number
    AND rh.tf_receipt_type = rl.tf_receipt_type
    AND rh.tf_receipt_number = rl.tf_receipt_number
    AND rh.tf_part_number = rl.tf_part_number
    AND itm.item_id = l.inventory_item_id
    AND itm.part_number = rh.tf_part_number
    AND rh.ATTRIBUTE7 = 'PHONE_REC'
    AND l.RETURN_REASON_CODE = 'PHONE_REC'
    AND NOT EXISTS (
    SELECT 'x'
    FROM migr_case_log@ofsprd
    WHERE process_flag = 'P'
    AND esn = rl.tf_serial_num
    AND receipt_number = rh.tf_receipt_number);*/
    -- CR 4691 Ends
    CURSOR c_case
    (
      pc_esn IN VARCHAR2
     ,cond   IN VARCHAR2
    ) IS
      SELECT objid
            ,title
            ,x_case_type
            ,gbst_elm_status
            ,id_number
        FROM (SELECT c.objid
                    ,c.title
                    ,c.x_case_type
                    ,s.title gbst_elm_status
                    ,c.id_number
                FROM sa.table_case     c
                    ,sa.table_gbst_elm s
               WHERE c.casests2gbst_elm = s.objid
                 AND c.x_esn = pc_esn
                 AND (c.s_title, UPPER(c.x_case_type), c.casests2gbst_elm) IN (SELECT m.title
                                                                                     ,m.type
                                                                                     ,gg.objid
                                                                                 FROM sa.x_migr_conf    m
                                                                                     ,sa.table_gbst_elm gg
                                                                                WHERE m.status = gg.s_title
                                                                                  AND m.active = 'Y'
                                                                                  AND ((gg.s_title <> 'PENDING' AND 1 = DECODE(cond
                                                                                                                              ,'<>'
                                                                                                                              ,1
                                                                                                                              ,0)) OR (gg.s_title = 'PENDING' AND 1 = DECODE(cond
                                                                                                                                                                             ,'='
                                                                                                                                                                             ,1
                                                                                                                                                                             ,0))))
               ORDER BY c.objid DESC)
       WHERE ROWNUM = 1;

    -- CR 4691 Starts
    CURSOR c1 IS
      SELECT *
        FROM tf_mwh_phone_receive1@ofsprd;

    /*
    select tab1.tf_doc_number
    from
    (SELECT + LEADING(rh)
    distinct rh.tf_doc_number
    from
    tf.tf_receipt_lines@ofsprd rl,
    tf.tf_receipt_headers@ofsprd rh
    where 1=1
    AND rl.tf_part_number = rh.tf_part_number
    AND rl.tf_receipt_number = rh.tf_receipt_number
    AND rl.tf_receipt_type = rh.tf_receipt_type
    and rl.TF_RECEIVED_LOC = rh.TF_RECEIVED_LOC
    --
    AND rh.ATTRIBUTE7 = 'PHONE_REC'
    and rh.TF_RECEIPT_TYPE = 'R2'
    and rh.TF_RECEIVED_LOC = 'MM_IO') tab1
    where 1=1
    and exists (select + leading( h) use_nl(l) index(h OE_ORDER_HEADERS_U2) 1
    from ont.oe_order_lines_all@ofsprd l,
    ont.oe_order_headers_all@ofsprd h
    where 1=1
    AND l.RETURN_REASON_CODE||'' = 'PHONE_REC'
    and l.header_id = h.header_id
    AND h.order_number = tab1.tf_doc_number);*/
    CURSOR c2(c_tf_doc_number IN VARCHAR2) IS
      SELECT rh.tf_receipt_type
            ,rh.tf_receipt_number
            ,rh.tf_part_number
            ,rl.tf_serial_num t_esn
            ,rl.tf_reason_code
        FROM tf.tf_receipt_lines@ofsprd   rl
            ,tf.tf_receipt_headers@ofsprd rh
       WHERE 1 = 1
         AND rl.tf_part_number = rh.tf_part_number
         AND rl.tf_receipt_number = rh.tf_receipt_number
         AND rl.tf_receipt_type = rh.tf_receipt_type
         AND rl.tf_received_loc = rh.tf_received_loc
            --
         AND rh.attribute7 = 'PHONE_REC'
         AND rh.tf_receipt_type = 'R2'
         AND rh.tf_received_loc = 'MM_IO'
         AND rh.tf_doc_number = c_tf_doc_number;

    CURSOR c3
    (
      c_tf_serial_num     IN VARCHAR2
     ,c_tf_receipt_number IN NUMBER
    ) IS
      SELECT 'x' col1
        FROM tf.migr_case_log@ofsprd
       WHERE process_flag = 'P'
         AND esn = c_tf_serial_num
         AND receipt_number = c_tf_receipt_number;

    c3_rec c3%ROWTYPE;

    -- CR 4691 End
    --CR4541 Starts
    CURSOR c_esn_shipped(c_case_objid IN NUMBER) IS
      SELECT *
        FROM table_act_entry
       WHERE act_entry2case = c_case_objid
         AND act_code = 1500;

    --ESN Shipped

    --1.29 revision start
    CURSOR get_site_part_count_c(p_esn VARCHAR2) IS
      SELECT COUNT(*) cnt
        FROM table_site_part
       WHERE x_service_id = p_esn
         AND LOWER(part_status) <> 'obsolete';

    l_intcount INTEGER;

    CURSOR get_code_table_c(p_code_no VARCHAR2) IS
      SELECT *
        FROM table_x_code_table
       WHERE x_code_number = p_code_no;

    rec_code_table_c get_code_table_c%ROWTYPE;
    --1.29 revision end
    r_esn_shipped  c_esn_shipped%ROWTYPE;
    is_esn_shipped NUMBER;
    v_status       VARCHAR2(20);
    v_message      VARCHAR2(1000);
    cnt            NUMBER := 0;
    --CR4541 Ends
  BEGIN
    SELECT objid
      INTO l_sa
      FROM table_user t
     WHERE login_name = 'sa';

    BEGIN
      SELECT objid
        INTO l_elm_objid
        FROM table_gbst_elm g
       WHERE g.gbst_elm2gbst_lst = (SELECT objid
                                      FROM table_gbst_lst
                                     WHERE title = 'Open')
         AND g.title = 'Received';
    EXCEPTION
      WHEN others THEN
        l_elm_objid := NULL;
    END;

    FOR c1_rec IN c1 LOOP
      FOR c2_rec IN c2(c1_rec.tf_doc_number) LOOP
        OPEN c3(c2_rec.t_esn
               ,c2_rec.tf_receipt_number);

        FETCH c3
          INTO c3_rec;

        IF c3%NOTFOUND THEN
          cnt := cnt + 1;
          receive_tab(cnt).tf_receipt_type := c2_rec.tf_receipt_type;
          receive_tab(cnt).tf_receipt_number := c2_rec.tf_receipt_number;
          receive_tab(cnt).tf_part_number := c2_rec.tf_part_number;
          receive_tab(cnt).t_esn := c2_rec.t_esn;
          receive_tab(cnt).tf_reason_code := c2_rec.tf_reason_code;
        END IF;

        CLOSE c3;
      END LOOP;
    END LOOP;

    IF cnt > 0 THEN
      FOR j IN receive_tab.first .. receive_tab.last LOOP
        COMMIT;
        r_receive.tf_receipt_type   := receive_tab(j).tf_receipt_type;
        r_receive.tf_receipt_number := receive_tab(j).tf_receipt_number;
        r_receive.tf_part_number    := receive_tab(j).tf_part_number;
        r_receive.t_esn             := receive_tab(j).t_esn;
        r_receive.tf_reason_code    := receive_tab(j).tf_reason_code;
        l_error                     := NULL;
        l_case_id                   := NULL;

        IF r_receive.t_esn IS NULL THEN
          l_error := 'The receipt ESN cannot be null.';

          INSERT INTO sa.x_migr_extra_info
            (x_flag_migration
            ,x_date_process
            ,x_problem)
          VALUES
            ('E_PR'
            ,SYSDATE
            ,l_error);

          insert_log(r_receive.t_esn
                    ,r_receive.tf_receipt_number
                    ,l_error
                    ,'F');
        ELSE
          -- IF r_Receive.t_esn IS NOT NULL THEN
          l_v  := 0;
          l_np := 0; --GC

          FOR r_case IN c_case(r_receive.t_esn
                              ,'=') LOOP
            --Check for PENDING cases
            BEGIN
              l_case_id := r_case.id_number;
              l_v       := l_v + 1;
            END;
          END LOOP;

          IF l_v = 0 THEN
            BEGIN
              -- There are no valid PENDING cases, let's check 4 cases <> Pending
              FOR r_case IN c_case(r_receive.t_esn
                                  ,'<>') LOOP
                BEGIN
                  l_case_id   := r_case.id_number;
                  l_np_status := r_case.gbst_elm_status;
                  --GC to include the status in the log message in OFS
                  l_np := l_np + 1;
                END;
              END LOOP;

              IF l_np = 0 THEN
                --If there are no non-pending cases...
                --There are no valid PENDING or NON-PENDING cases, therefore, we create a NO_CASE case
                BEGIN
                  sa.migra_create_case_pkg.sp_create_case(r_receive.t_esn
                                                         ,'NO CASE'
                                                         ,'Warehouse'
                                                         ,'No Case'
                                                         ,NULL
                                                         ,NULL
                                                         ,NULL
                                                         ,NULL
                                                         ,NULL
                                                         ,NULL
                                                         ,NULL
                                                         ,l_case_objid
                                                         ,l_case_id_new);
                  l_error := 'The receipt ESN ' || r_receive.t_esn || ' has not valid cases. The NO_CASE case ' || l_case_id_new || ' was created';

                  INSERT INTO sa.x_migr_extra_info
                    (x_flag_migration
                    ,x_date_process
                    ,x_problem)
                  VALUES
                    ('E_PR'
                    ,SYSDATE
                    ,l_error);

                  insert_log(r_receive.t_esn
                            ,r_receive.tf_receipt_number
                            ,l_error
                            ,'P');
                END;
                --end of NO_CASE case creation
              END IF;
            END;
          END IF;
        END IF;

        IF l_case_id IS NOT NULL
           AND l_v > 0
           AND l_np = 0 THEN
          --GC: if there's a valid and pending case
          BEGIN
            BEGIN
              SELECT *
                INTO r_table_case
                FROM sa.table_case c
               WHERE c.id_number = l_case_id;
            EXCEPTION
              WHEN others THEN
                l_error := 'This should not happen. Case: ' || l_case_id;
            END;

            IF l_error IS NOT NULL THEN
              INSERT INTO sa.x_migr_extra_info
                (x_flag_migration
                ,x_date_process
                ,x_problem)
              VALUES
                ('E_PR'
                ,SYSDATE
                ,l_error);

              insert_log(r_receive.t_esn
                        ,r_receive.tf_receipt_number
                        ,l_error
                        ,'F');
            ELSE
              BEGIN
                SELECT title
                  INTO l_title
                  FROM sa.table_gbst_elm
                 WHERE objid = r_table_case.casests2gbst_elm;
              EXCEPTION
                WHEN others THEN
                  l_title := NULL;
              END;

              IF l_title = 'Closed'
                 AND l_title IS NOT NULL THEN
                l_error := 'The case ' || l_case_id || ' is Closed, You can not update the notes.';

                INSERT INTO sa.x_migr_extra_info
                  (x_flag_migration
                  ,x_date_process
                  ,x_problem)
                VALUES
                  ('E_PR'
                  ,SYSDATE
                  ,l_error);

                insert_log(r_receive.t_esn
                          ,r_receive.tf_receipt_number
                          ,l_error
                          ,'F');
              ELSE
                BEGIN
                  SAVEPOINT my_insert;

                  INSERT INTO sa.table_act_entry
                    (objid
                    ,act_code
                    ,entry_time
                    ,addnl_info
                    ,act_entry2user
                    ,act_entry2case
                    ,entry_name2gbst_elm)
                  VALUES
                    (sa.seq('act_entry')
                    ,2000
                    ,SYSDATE
                    ,'ESN Received'
                    ,l_sa
                    ,r_table_case.objid
                    ,l_elm_objid);
                EXCEPTION
                  WHEN others THEN
                    my_code := SQLCODE;
                    my_errm := SQLERRM;
                    l_error := 'The insertion in table_act_entry for case ' || r_table_case.id_number || ' had the following error: ' || my_code || ': ' || my_errm;
                END;

                IF l_error IS NULL THEN
                  BEGIN
                    l_case_history := r_table_case.case_history;

                    UPDATE sa.table_case c
                       SET case_history     = TRIM(l_case_history) || CHR(10) || CHR(13) || '*** Logged by Integration *** ' || CHR(10) || 'ESN Received on ' || SYSDATE
                          ,site_time        = SYSDATE
                          ,casests2gbst_elm = DECODE(l_elm_objid
                                                    ,NULL
                                                    ,casests2gbst_elm
                                                    ,l_elm_objid)
                     WHERE objid = r_table_case.objid;

                    --CR4541 Starts
                    OPEN c_esn_shipped(r_table_case.objid);

                    FETCH c_esn_shipped
                      INTO r_esn_shipped;

                    IF c_esn_shipped%NOTFOUND THEN
                      is_esn_shipped := 0;
                    ELSE
                      is_esn_shipped := 1;
                    END IF;

                    CLOSE c_esn_shipped;

                    IF is_esn_shipped = 1 THEN
                      --CR19802 Start KACOSTA 02/09/2012
                      --igate.sp_close_case(l_case_id
                      --                   ,'sa'
                      --                   ,'CLARIFY'
                      --                   ,'Cust Exchanged Phone'
                      --                   ,v_status
                      --                   ,v_message);
                      --IF v_status <> 'S' THEN
                      --  l_error := ' The case number ' || l_case_id || ' was not closed.';
                      --  insert_log(r_receive.t_esn
                      --            ,r_receive.tf_receipt_number
                      --            ,l_error
                      --            ,'F');
                      --END IF;
                      clarify_case_pkg.close_case(p_case_objid => r_table_case.objid
                                                 ,p_user_objid => l_sa
                                                 ,p_source     => 'CLARIFY'
                                                 ,p_resolution => 'Cust Exchanged Phone'
                                                 ,p_status     => NULL
                                                 ,p_error_no   => v_status
                                                 ,p_error_str  => v_message);
                      IF v_status <> '0' THEN
                        l_error := ' The case number ' || l_case_id || ' was not closed.';
                        insert_log(r_receive.t_esn
                                  ,r_receive.tf_receipt_number
                                  ,l_error
                                  ,'F');
                      END IF;
                      --CR19802 End KACOSTA 02/09/2012
                      --1.29 revision start
                      OPEN get_site_part_count_c(r_receive.t_esn);

                      FETCH get_site_part_count_c
                        INTO l_intcount;

                      CLOSE get_site_part_count_c;

                      IF l_intcount > 0 THEN
                        OPEN get_code_table_c('51');

                        FETCH get_code_table_c
                          INTO rec_code_table_c;

                        CLOSE get_code_table_c;

                        UPDATE sa.table_part_inst
                           SET x_part_inst_status  = '51'
                              ,status2x_code_table = rec_code_table_c.objid
                         WHERE part_serial_no = r_receive.t_esn;
                      ELSE
                        OPEN get_code_table_c('50');

                        FETCH get_code_table_c
                          INTO rec_code_table_c;

                        CLOSE get_code_table_c;

                        UPDATE sa.table_part_inst
                           SET x_part_inst_status  = '50'
                              ,status2x_code_table = rec_code_table_c.objid
                         WHERE part_serial_no = r_receive.t_esn;
                      END IF;
                      --1.29 revision end
                    END IF;
                    --CR4541 Ends
                  EXCEPTION
                    WHEN others THEN
                      ROLLBACK TO SAVEPOINT my_insert;
                      my_code := SQLCODE;
                      my_errm := SQLERRM;
                      l_error := 'The actualization of table_case for case ' || r_table_case.id_number || ' had the following error: ' || my_code || ': ' || my_errm;
                  END;
                END IF;

                IF l_error IS NULL THEN
                  insert_log(r_receive.t_esn
                            ,r_receive.tf_receipt_number
                            ,NULL
                            ,'P');
                ELSE
                  INSERT INTO sa.x_migr_extra_info
                    (x_flag_migration
                    ,x_date_process
                    ,x_problem)
                  VALUES
                    ('E_PR'
                    ,SYSDATE
                    ,l_error);

                  insert_log(r_receive.t_esn
                            ,r_receive.tf_receipt_number
                            ,l_error
                            ,'F');
                END IF;
              END IF;
            END IF;
          EXCEPTION
            WHEN others THEN
              my_code := SQLCODE;
              my_errm := SQLERRM;
              l_error := 'Unexpected error in Case: ' || l_case_id || ': ' || my_code || ': ' || my_errm;

              INSERT INTO sa.x_migr_extra_info
                (x_flag_migration
                ,x_date_process
                ,x_problem)
              VALUES
                ('E_PR'
                ,SYSDATE
                ,l_error);

              insert_log(r_receive.t_esn
                        ,r_receive.tf_receipt_number
                        ,l_error
                        ,'F');
          END;
        ELSIF l_case_id IS NOT NULL
              AND l_v = 0
              AND l_np > 0 THEN
          --There's a non-pending case, update OFS but don't touch Clarify
          BEGIN
            IF LENGTH(l_np_status) > 20 THEN
              l_np_status := SUBSTR(l_np_status
                                   ,1
                                   ,20);
              --in case the title is bigger than 20 chars
            ELSE
              l_np_status := RPAD(l_np_status
                                 ,20
                                 ,' ');
              --if it's smaller, I fill with spaces, up to 20
            END IF;

            --build message string 35 chars 4 first part
            l_error := 'The status is ' || l_np_status || '. The case number ' || l_case_id || ' was not updated.';
            --l_error := 'The status of this ESN is not pending. Case: ' || l_case_id; --obsolete message
            insert_log(r_receive.t_esn
                      ,r_receive.tf_receipt_number
                      ,l_error
                      ,'P'); --in this case the flag is P
          EXCEPTION
            WHEN others THEN
              my_code := SQLCODE;
              my_errm := SQLERRM;
              l_error := 'Unexpected error in Case: ' || l_case_id || ': ' || my_code || ': ' || my_errm;
              insert_log(r_receive.t_esn
                        ,r_receive.tf_receipt_number
                        ,l_error
                        ,'F');
          END;
          --End of new section
        END IF;

        COMMIT;
      END LOOP;
    END IF;
  END phone_receive;

  /*************************************************************************
  * Procedure: TransferPromotions
  * Purpose : To transfer all promotions from a given ESN to another
  * This procedure hasn't a commit sentences therefore a commit
  * sentence should be included after the execution of it.
  * Only active promotions will be moved.
  **************************************************************************/
  PROCEDURE transferpromotions(
                               --p_OldEsn IN VARCHAR2, --commented out by Jasmine on 09/08/2006
                               p_objid         IN NUMBER
                              , -- Added by Jasmine on 09/08/2006
                               p_newesn        IN VARCHAR2
                              ,p_error_number  OUT NUMBER
                              ,p_error_message OUT VARCHAR2) IS
    v_oldesn_id table_part_inst.objid%TYPE;
    v_newesn_id table_part_inst.objid%TYPE;
    v_objid     table_x_group2esn.objid%TYPE;
    v_oldesn    table_part_inst.part_serial_no%TYPE;
    --Add by Jasmine
    r_esnpromotions table_x_group2esn%ROWTYPE;
    my_code         NUMBER;
    my_errm         VARCHAR2(32000);
    error_esn_not_found EXCEPTION;
    error_transfering   EXCEPTION;
    error_historical    EXCEPTION;
    error_updating      EXCEPTION;
    PRAGMA EXCEPTION_INIT(error_esn_not_found
                         ,-20000);
    PRAGMA EXCEPTION_INIT(error_transfering
                         ,-20001);
    PRAGMA EXCEPTION_INIT(error_historical
                         ,-20002);
    PRAGMA EXCEPTION_INIT(error_updating
                         ,-20003);

    --************Begin modified by Jasmine on 09/08/2006***************
    /*CURSOR c_EsnPromotions(cp_objid IN NUMBER ) IS
    SELECT *
    FROM table_x_group2esn
    WHERE groupesn2part_inst = cp_objid
    AND ( x_end_date IS NULL
    OR x_end_date > SYSDATE)
    FOR UPDATE OF x_end_date;*/
    /* CURSOR c_esnpromotions (cp_objid IN NUMBER)
    IS
    SELECT objid, x_annual_plan x_annual_plan,
    case_promo2case groupesn2part_inst,
    case_promo2promo_grp groupesn2x_promo_group,
    x_end_date x_end_date, x_start_date x_start_date,
    case_promo2promotion groupesn2x_promotion
    FROM table_x_case_promotions
    WHERE case_promo2case = cp_objid
    AND NVL (x_end_date, SYSDATE) >= SYSDATE;*/
    ---************* CR7986 ******************************************
    CURSOR c_esnpromotions(cp_objid IN NUMBER) IS
      SELECT objid
            ,x_annual_plan        x_annual_plan
            ,case_promo2case      groupesn2part_inst
            ,case_promo2promo_grp groupesn2x_promo_group
            ,x_end_date           x_end_date
            ,x_start_date         x_start_date
            ,case_promo2promotion groupesn2x_promotion
        FROM table_x_case_promotions
       WHERE case_promo2case = cp_objid
         AND NVL(x_end_date,SYSDATE) >= SYSDATE
         AND(case_promo2promotion IN (SELECT objid
                                        FROM table_x_promotion
                                       WHERE x_promo_type NOT IN ('Activation'
                                                                 ,'ActivationCombo'))
              OR case_promo2promotion IN (SELECT objid                             ---CR22429
                                          FROM table_x_mtm_promotion));

    --************End modified by Jasmine on 09/08/2006***************
    --CR5848 Start
    CURSOR c_case(cp_objid IN NUMBER) IS
      SELECT s_title
            ,x_model
            ,x_case_type --CR5848, CR5150 Added x_case_type
        FROM table_case
       WHERE objid = cp_objid;

    r_case c_case%ROWTYPE;

    CURSOR c_promogrp(pg_objid IN NUMBER) IS
      SELECT group_name
        FROM table_x_promotion_group
       WHERE objid = pg_objid
         AND SYSDATE BETWEEN x_start_date AND x_end_date;

    CURSOR c_get_tech(ip_model IN VARCHAR2) IS
      SELECT x_technology
        FROM table_part_num
       WHERE part_number = ip_model;
    --CR22429
    CURSOR c_esn_in_promo_code(p_newesn IN VARCHAR2) is
     SELECT pn.part_number,pi.PART_SERIAL_NO,x_promo_code,p.objid
       FROM TABLE_PART_NUM PN,TABLE_PART_INST PI,TABLE_MOD_LEVEL ML,table_x_promotion p, table_x_mtm_promotion mtmp
        where pi.N_PART_INST2PART_MOD = ml.OBJID
         and ml.PART_INFO2PART_NUM = PN.OBJID
         and pi.PART_SERIAL_NO = p_newesn
         and part_num2x_promotion = p.objid
         and p.objid = mtmp.objid;
    --End CR22429
    r_esn_in_promo_code     c_esn_in_promo_code%rowtype; --CR22429
    r_get_tech         c_get_tech%ROWTYPE;
    r_promogrp         c_promogrp%ROWTYPE;
    l_no_dmpp_transfer CHAR(1) := 'F';
    l_upg_case         CHAR(1) := 'F';
    --l_grp_name         VARCHAR2(20);					--Commented for CR46164
    l_grp_name         table_x_promotion_group.group_name%type;		--CR46164
    l_tech             VARCHAR2(200);
    --CR5848 End

	--CR22429
    v_old_days    NUMBER;
    v_new_days    NUMBER;
    new_exp_date  DATE;
    v_sp_objid    NUMBER;

  BEGIN
    p_error_number  := 0;
    p_error_message := NULL;

    -- Get objid of old ESN
    BEGIN
      --************Begin modified by Jasmine on 09/08/2006***************
      /*
      SELECT objid
      INTO v_OldEsn_id
      FROM table_part_inst
      WHERE part_serial_no = TRIM(p_OldEsn);
      */
      SELECT x_esn
        INTO v_oldesn
        FROM table_case
       WHERE objid = p_objid;

      SELECT objid
        INTO v_oldesn_id
        FROM table_part_inst
       WHERE part_serial_no = TRIM(v_oldesn);
      --************End modified by Jasmine on 09/08/2006***************
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20000
                               ,'The old ESN given (' || v_oldesn || ') is not valid.');
    END;

    -- Get objid of new ESN
    BEGIN
      SELECT objid
        INTO v_newesn_id
        FROM table_part_inst
       WHERE part_serial_no = TRIM(p_newesn);
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20000
                               ,'The new ESN given (' || p_newesn || ') is not valid.');
    END;

    --CR5848 Start
    OPEN c_case(p_objid);

    FETCH c_case
      INTO r_case;

    --CR5150
    -- IF c_case%FOUND AND r_case.s_title LIKE '%UPGRADE%'
    IF c_case%FOUND
       AND ((r_case.x_case_type = 'Port In' AND r_case.s_title = 'INTERNAL') OR (r_case.x_case_type = 'Phone Upgrade' AND r_case.s_title = 'PHONE UPGRADE') OR (r_case.x_case_type = 'Port In' AND r_case.s_title = 'INTERNA
L SIM EXCHANGE') OR (r_case.x_case_type = 'Port In' AND r_case.s_title = 'INTERNAL TECH EXCHANGE') OR (r_case.x_case_type = 'Units' AND r_case.s_title = 'UNIT TRANSFER' --CR6250

       ))
    --CR5150
     THEN
      l_upg_case := 'T';

	 --Start CR22429
      OPEN c_esn_in_promo_code(p_newesn);
        FETCH c_esn_in_promo_code INTO r_esn_in_promo_code;
      IF c_esn_in_promo_code%FOUND THEN
      DBMS_OUTPUT.PUT_LINE('The new ESN is part of the expiration rollover promotions.');

      --get service days
        SELECT  MAX(trunc(x_new_due_date)) - MAX(decode(x_action_text,'DEACTIVATION',trunc(x_transact_date),''))
        INTO v_old_days
        FROM table_x_call_trans
        WHERE x_service_id = v_oldesn;
        dbms_output.put_line('old_days'||v_old_days);

        select  max(trunc(x_new_due_date))- max(decode(x_action_text,'ACTIVATION',trunc(x_transact_date),''))
        into v_new_days
        from table_x_call_trans ct
        where x_service_id = p_newesn;
         dbms_output.put_line('new_days'||v_new_days);

         update table_site_part
             set x_expire_dt = x_expire_dt+v_old_days
             where x_service_id = p_newesn
             and part_status='Active'
             returning x_expire_dt,objid  into new_exp_date,v_sp_objid;

      dbms_output.put_line('Updated site_part : ');

      update table_part_inst
             set warr_end_date = new_exp_date
             where part_serial_no = p_newesn;
     dbms_output.put_line('Updated part_inst : ');
     dbms_output.put_line('Adding '||v_old_days||' days to ESN:'
                                   ||p_newesn||' New Exp Date='
                                   || to_char(new_exp_date,'MM/DD/YYYY'));

      END IF;
      CLOSE c_esn_in_promo_code;
    --End CR22429
      OPEN c_get_tech(r_case.x_model);

      FETCH c_get_tech
        INTO r_get_tech;

      IF c_get_tech%FOUND THEN
        l_tech := r_get_tech.x_technology;
      ELSE
        l_tech := NULL;
      END IF;

      CLOSE c_get_tech;
    ELSE
      l_upg_case := 'F';
    END IF;

    CLOSE c_case;

    --CR5848 End
    -- Create new esn promotions
    FOR r_esnpromotions IN c_esnpromotions(p_objid) LOOP
      --CR5848 Start
      l_no_dmpp_transfer := 'F';
      l_grp_name         := NULL;

      OPEN c_promogrp(r_esnpromotions.groupesn2x_promo_group);

      FETCH c_promogrp
        INTO r_promogrp;

      IF c_promogrp%FOUND THEN
        l_grp_name := r_promogrp.group_name;
      ELSE
        l_grp_name := NULL;
      END IF;

      CLOSE c_promogrp;

      -- CR16344 / CR16379

      IF NVL(l_upg_case
            ,'F') = 'T'
        -- AND NVL (l_grp_name, 'ZZZ') LIKE 'DBL%GRP'
         AND (NVL(l_grp_name
                 ,'ZZZ') LIKE 'DBL%GRP' OR NVL(l_grp_name
                                              ,'ZZZ') LIKE 'X3X%GRP')
         AND NVL(l_tech
                ,'ZZZ') <> 'TDMA' THEN
        l_no_dmpp_transfer := 'T';
      ELSE
        l_no_dmpp_transfer := 'F';
      END IF;

      IF l_no_dmpp_transfer = 'F' THEN
        --CR5848 End
        BEGIN
          BEGIN
            v_objid := sa.seq('x_group2esn');

            -- Create new esn promotions records
            INSERT INTO table_x_group2esn
              (objid
              ,x_annual_plan
              ,groupesn2part_inst
              ,groupesn2x_promo_group
              ,x_end_date
              ,x_start_date
              ,groupesn2x_promotion)
            VALUES
              (v_objid
              ,r_esnpromotions.x_annual_plan
              ,v_newesn_id
              , -- Assigned 2 the new esn...
               r_esnpromotions.groupesn2x_promo_group
              ,r_esnpromotions.x_end_date
              ,r_esnpromotions.x_start_date
              ,r_esnpromotions.groupesn2x_promotion);
          EXCEPTION
            WHEN others THEN
              raise_application_error(-20001
                                     ,'Error tranfering promotions to ESN ' || p_newesn);
          END;

          -- Create historical records in table_x_group_hist
          BEGIN
            v_objid := sa.seq('x_group_hist');

            INSERT INTO table_x_group_hist
              (objid
              ,x_annual_plan
              ,grouphist2part_inst
              ,grouphist2x_promo_group
              ,x_end_date
              ,x_start_date
              ,x_action_date
              ,x_action_type
              ,x_old_esn)
            VALUES
              (v_objid
              ,r_esnpromotions.x_annual_plan
              ,v_newesn_id
              ,r_esnpromotions.groupesn2x_promo_group
              ,r_esnpromotions.x_end_date
              ,r_esnpromotions.x_start_date
              ,SYSDATE
              ,'Handset transfer'
              ,v_oldesn);
          EXCEPTION
            WHEN others THEN
              raise_application_error(-20002
                                     ,'Error creating historical records of ESN ' || p_newesn);
          END;
          --*****************Begin commented out by Jasmine on 09/08/2006***********************--
          /*BEGIN

          -- Update x_end_date field of old esn records

          UPDATE table_x_group2esn SET x_end_date = SYSDATE
          WHERE CURRENT OF c_EsnPromotions;

          EXCEPTION
          WHEN OTHERS
          THEN
          Raise_application_error( - 20003,
          'Error updating x_end_date of ESN ' || v_OldEsn );
          END;*/
          --*****************End commented out by Jasmine on 09/08/2006***********************--
        END;
      END IF; --CR5848 End
    END LOOP;

    --*****************Begin added by Jasmine on 09/08/2006***********************--
    BEGIN
      -- Update x_end_date field of old esn records
      UPDATE table_x_group2esn
         SET x_end_date = SYSDATE
       WHERE NVL(x_end_date
                ,SYSDATE) >= SYSDATE
         AND groupesn2part_inst = v_oldesn_id;
      --CR5569-7
      -- -- Update the Due Date of the new phone
      -- UPDATE table_part_inst
      -- SET warr_end_date = (SELECT site_time
      -- FROM table_case
      -- WHERE objid = p_objid
      -- )
      -- WHERE part_serial_no = p_NewEsn;
      --CR5569-7
    EXCEPTION
      WHEN others THEN
        raise_application_error(-20003
                               ,'Error updating Due Date of ESN ' || p_newesn);
    END;
    --*****************End added by Jasmine on 09/08/2006***********************--
    -- CR19467 ST Promotion ym Start.
      sa.enroll_promo_pkg.sp_transfer_promo_enrollment(p_objid --  P_CASE_OBJID
                                                    ,p_newesn --  P_NEW_ESN

                                                    ,p_error_number --P_ERROR_CODE
                                                    ,p_error_message --p_error_msg
                                                     );

    -- CR19467 ST Promotion ym End.

    --
    -- CR16379 Start kacosta 03/09/2012
    DECLARE
      --
      l_i_error_code    INTEGER := 0;
      l_v_error_message VARCHAR2(32767) := 'SUCCESS';
      --
    BEGIN
      --
      promotion_pkg.expire_double_if_esn_is_triple(p_esn           => p_newesn
                                                  ,p_error_code    => l_i_error_code
                                                  ,p_error_message => l_v_error_message);
      --
      IF (l_i_error_code <> 0) THEN
        --
        dbms_output.put_line('Failure calling promotion_pkg.expire_double_if_esn_is_triple with error: ' || l_v_error_message);
        --
      END IF;
      --
    EXCEPTION
      WHEN others THEN
        --
        dbms_output.put_line('Failure calling promotion_pkg.expire_double_if_esn_is_triple with Oracle error: ' || SQLCODE);
        --
    END;
    -- CR16379 End kacosta 03/09/2012
    --
  EXCEPTION
    WHEN others THEN
      my_code         := SQLCODE;
      my_errm         := SQLERRM;
      p_error_number  := my_code;
      p_error_message := my_errm;
  END transferpromotions;

  /*************************************************************************
  * Procedure: RemovePromotions
  * Purpose : To remove all promotions of given ESN
  * This procedure hasn't a commit sentences therefore a commit
  * sentence should be included after the execution of it.
  * Only active promotions will be removed.
  **************************************************************************/
  PROCEDURE removepromotions
  (
    p_esn           IN VARCHAR2
   ,p_error_number  OUT NUMBER
   ,p_error_message OUT VARCHAR2
  ) IS
    v_esn_id        table_part_inst.objid%TYPE;
    v_objid         table_x_group2esn.objid%TYPE;
    r_esnpromotions table_x_group2esn%ROWTYPE;
    my_code         NUMBER;
    my_errm         VARCHAR2(32000);
    error_esn_not_found EXCEPTION;
    error_transfering   EXCEPTION;
    error_historical    EXCEPTION;
    error_updating      EXCEPTION;
    PRAGMA EXCEPTION_INIT(error_esn_not_found
                         ,-20000);
    PRAGMA EXCEPTION_INIT(error_transfering
                         ,-20001);
    PRAGMA EXCEPTION_INIT(error_historical
                         ,-20002);
    PRAGMA EXCEPTION_INIT(error_updating
                         ,-20003);

    CURSOR c_esnpromotions(p_objid IN NUMBER) IS
      SELECT *
        FROM table_x_group2esn
       WHERE groupesn2part_inst = p_objid
         AND (x_end_date IS NULL OR x_end_date > SYSDATE)
         FOR UPDATE OF x_end_date;

    CURSOR c_esnpartinst(p_esn VARCHAR2) IS
      SELECT objid
        FROM table_part_inst
       WHERE part_serial_no = TRIM(p_esn)
         AND x_part_inst_status || '' <> '52';

    recesnpartinst c_esnpartinst%ROWTYPE;
  BEGIN
    p_error_number  := 0;
    p_error_message := NULL;

    -- Get objid of ESN
    OPEN c_esnpartinst(p_esn);

    FETCH c_esnpartinst
      INTO recesnpartinst;

    IF c_esnpartinst%NOTFOUND THEN
      CLOSE c_esnpartinst;

      raise_application_error(-20000
                             ,'The ESN given (' || p_esn || ') is not valid.');
    END IF;

    CLOSE c_esnpartinst;

    v_esn_id := recesnpartinst.objid;

    -- Remove promotions
    FOR r_esnpromotions IN c_esnpromotions(v_esn_id) LOOP
      dbms_output.put_line('inside loop 1');

      -- Create historical records in table_x_group_hist
      BEGIN
        v_objid := sa.seq('x_group_hist');

        INSERT INTO table_x_group_hist
          (objid
          ,x_annual_plan
          ,grouphist2part_inst
          ,grouphist2x_promo_group
          ,x_end_date
          ,x_start_date
          ,x_action_date
          ,x_action_type
          ,x_old_esn)
        VALUES
          (v_objid
          ,r_esnpromotions.x_annual_plan
          ,v_esn_id
          ,r_esnpromotions.groupesn2x_promo_group
          ,r_esnpromotions.x_end_date
          ,r_esnpromotions.x_start_date
          ,SYSDATE
          ,'Remove'
          ,NULL);
      EXCEPTION
        WHEN others THEN
          raise_application_error(-20002
                                 ,'Error creating historical records of ESN ' || p_esn);
      END;

      BEGIN
        dbms_output.put_line('inside loop 2');

        -- Update x_end_date field of old esn records
        UPDATE table_x_group2esn
           SET x_end_date = SYSDATE
         WHERE CURRENT OF c_esnpromotions; --objid= r_EsnPromotions.objid;
      EXCEPTION
        WHEN others THEN
          raise_application_error(-20003
                                 ,'Error updating x_end_date of ESN ' || p_esn);
      END;

      dbms_output.put_line('update done');
    END LOOP;

    dbms_output.put_line('outside loop 1');

    -- Remove pending units
    DELETE table_x_pending_redemption
     WHERE objid IN (SELECT pend.objid
                       FROM table_site_part            sp
                           ,table_x_pending_redemption pend
                           ,table_x_promotion          pr
                      WHERE sp.x_service_id = p_esn
                        AND pend.x_pend_red2site_part = sp.objid
                        AND pr.objid = pend.pend_red2x_promotion
                     UNION
                     SELECT pend.objid
                       FROM table_part_inst            pi
                           ,table_x_pending_redemption pend
                           ,table_x_promotion          pr
                      WHERE pi.part_serial_no = p_esn
                        AND pend.pend_redemption2esn = pi.objid
                        AND pr.objid = pend.pend_red2x_promotion
                        AND pend.x_pend_type = 'REPL');

    UPDATE table_x_group2esn
       SET x_end_date = SYSDATE
     WHERE (x_end_date IS NULL OR x_end_date > SYSDATE)
       AND objid IN (SELECT g.objid
                       FROM table_x_group2esn g
                           ,table_part_inst   pi
                      WHERE pi.part_serial_no = p_esn
                        AND g.groupesn2part_inst = pi.objid);

    --*****************Begin add by Jasmine on 09/08/2006***********************--
    BEGIN
      -- null out: WARR_END_DATE from Part Inst
      UPDATE table_part_inst
         SET warr_end_date = NULL
       WHERE part_serial_no = p_esn;
    EXCEPTION
      WHEN others THEN
        raise_application_error(-20003
                               ,'Error updating warranty end data of ESN ' || p_esn);
    END;
    --*****************End add by Jasmine on 09/08/2006***********************--
  EXCEPTION
    WHEN others THEN
      my_code         := SQLCODE;
      my_errm         := SQLERRM;
      p_error_number  := my_code;
      p_error_message := my_errm;
  END REMOVEPROMOTIONS;
END MIGRA_INTELLITRACK;
/