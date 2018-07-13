CREATE OR REPLACE PACKAGE BODY sa."VALIDATE_RED_CARD_PKG" AS
 /******************************************************************************/
 /* Copyright 2002 Tracfone Wireless Inc. All rights reserved */
 /* */
 /* NAME: sa.VALIDATE_RED_CARD_PKG */
 /* PURPOSE: To validate a redemption card */
 /* FREQUENCY: */
 /* PLATFORMS: Oracle 9.2.0.7 AND newer versions. */
 /* */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- ----- --------------------------------------------- */
 /* 1.0/1.10 09/12/2007 GKharche Initial Revision */
 /* Defect # 1351 - Adding a new cursor,variable and IF condition to handle Status 40 card */
 /* 1.11 11/15/07 VAdapa CR6962 - Redemption Failures (CBO)
 /* 1.11.1.0 05/13/07 VAdapa CR7236
 /* 1.17 05/30/07 VAdapa Latest with CR7259
 /* 1.19 06/03/08 SKantipudi Changed the error return codes as below for the existing combination
 (40 and 402) is changed to (40 and 430(New code)),
 (40 and 405) is changed to (40 and 431(new code)),
 and (45 and 403) to (45 and 432(New code))
 1.20 08/26/08 lsatuluri added changes for CR7572
 1.21 09/04/08 lsatuluri added Fix for CR7572
 1.22/1.23 10/23/08 VAdapa CR8013
 1.24-25 04/01/09 ICanavan CR8663 SWITCH (per 365) WALMART
 1.26-27 06/15/09 ICanavan CR8470 CMS_SPLIT
 1.28 08/26/09 NGuada BRAND_SEP references to x_restricted_use
 and amigo are updated with table_bus_org values
 1.29 09/28/09 ICanavan BRAND_SEP_III
 /* 1.30 05/10/10 Skuthadi ST GSM modified straight_talk_esn_cur cur*/
 /* 1.3 08/10/10 PM CR12989 ST Retention */
 /* 1.5 10/08/2010 NGuada CR13085 */
 /* 1.9 06/03/11 ICanavan CR16344 / CR16379 triple minute promo */
 /* 1.11 10/11/11 PMistry CR17003 NET10 Sprint */
 /* 1.14 12/27/11 Clindner CR19461 TF WEBCSR 11 Digit ESN Redemption Problem */
 /* 1.15 02/08/12 ICanavan CR17413 Change rst_use cursor and logic for the LGL95 */
 /* 1.19-20 07/01/12 ICanavan CR20451 | CR20854: Add TELCEL Brand */
 /* 1.22 04/04/13 Clindner CR22451 Simple Mobile System Integration - WEBCSR */
 /*********************************************************************************/
 --
 ---------------------------------------------------------------------------------------------
 --$RCSfile: VALIDATE_RED_CARD_PKG.sql,v $
 --$Revision: 1.112 $
 --$Author: spagidala $
 --$Date: 2018/05/10 19:39:32 $
 --$ $Log: VALIDATE_RED_CARD_PKG.sql,v $
 --$ Revision 1.112  2018/05/10 19:39:32  spagidala
 --$ CR57903 - Added validation
 --$
 --$ Revision 1.111  2018/05/09 17:58:23  spagidala
 --$ CR57903 - Added validation with error no 1654 - To sync the logic with brand_x pkg
 --$
 --$ Revision 1.110  2018/03/19 21:59:19  abustos
 --$ CR52873 Modify addon_exclusion function to check based on device_type for TF
 --$
 --$ Revision 1.109  2018/02/07 23:14:59  mdave
 --$ CR55066 Added SM for add on exclusion function
 --$
 --$ Revision 1.107  2017/12/29 22:13:25  abustos
 --$ CR55070 - Added NT brand to addon_exclusion check
 --$
 --$ Revision 1.106  2017/09/06 21:03:45  abustos
 --$ CR51712 - Modify is_safelink function to allow reactivation of SL customer regardless of the part_status in table_site_part
 --$
 --$ Revision 1.105  2017/08/07 14:49:02  vlaad
 --$ Added new function to block multidenomination shell part number redemption for TF
 --$
 --$ Revision 1.103  2017/05/23 15:45:24  abustos
 --$ Modify Main Proc for ST AddOn
 --$
 --$ Revision 1.102  2017/05/16 19:37:51  nmuthukkaruppan
 --$ CR49808 - Skip promo check for SafelinkAssist ESNs.
 --$
 --$ Revision 1.101  2017/04/05 18:19:06  sgangineni
 --$ CR47564 - WFM code merge with Rel_854 changes
 --$
 --$ Revision 1.100  2017/03/27 17:07:32  sraman
 --$ CR47564 WFM starts here - If WFM get the service days from x_part_inst_ext
 --$
 --$ Revision 1.99  2017/03/27 16:14:51  sraman
 --$ CR47564 WFM starts here - If WFM get the service days from x_part_inst_ext
 --$
 --$ Revision 1.95  2017/02/10 22:40:57  smeganathan
 --$ CR47265 changes in validate_pre_posa to fix infinite looping resulting in high cpu utilization when bad data is passed
 --$
 --$ Revision 1.94  2017/01/04 14:42:31  tbaney
 --$ Changed message.  CR47024
 --$
 --$ Revision 1.93  2017/01/03 23:10:18  tbaney
 --$ Logic in two places.  CR47024
 --$
 --$ Revision 1.92  2017/01/03 23:01:01  tbaney
 --$ Added nvl to ppe check.  CR47024.
 --$
 --$ Revision 1.91  2016/12/20 22:45:29  tbaney
 --$ Changes to block SL customers.  CR47024.
 --$
 --$ Revision 1.90  2016/12/12 22:18:21  tbaney
 --$ Changed both checks.  CR42459.
 --$
 --$ Revision 1.88  2016/12/09 16:12:49  tbaney
 --$ Added missing /
 --$
 --$ Revision 1.87  2016/12/09 16:00:38  tbaney
 --$ Removed Active check.
 --$
 --$ Revision 1.86  2016/12/08 23:56:34  tbaney
 --$ Removed check for SL active enrollment. CR42459
 --$
 --$ Revision 1.85  2016/12/02 22:01:21  tbaney
 --$ Added logic for CR42459 to handle PPE devices.
 --$
 --$ Revision 1.84  2016/09/12 23:04:25  vnainar
 --$ CR43498 new function is_dataclub_card added to ignore 420 error code
 --$
 --$ Revision 1.83  2016/07/01 15:30:50  tbaney
 --$ Removed check per Elizabeth.
 --$
 --$ Revision 1.82  2016/06/24 16:28:58  tbaney
 --$ Changes for CR43582 to add batch processing.
 --$
 --$ Revision 1.81  2016/06/07 19:31:45  abustos
 --$ Merged 1.78 and 1.80
 --$
 --$ Revision 1.78  2016/05/13 22:02:10  skota
 --$ Modified is data card function for CR41823
 --$
 --$ Revision 1.77  2016/03/11 19:54:39  jpena
 --$ Fix posa red card validation for WARP
 --$
 --$ Revision 1.73  2015/11/04 14:58:56  skota
 --$ for CR37012 laoding unnecessary logs into error table
 --$
 --$ Revision 1.72  2015/10/24 18:52:19  rpednekar
 --$ CR37485- Validation added for Tracfone safelink 350 min card.
 --$
 --$ Revision 1.71  2015/10/20 23:27:53  skota
 --$ FOR CR38145 PAYGO CARDS
 --$
 --$ Revision 1.68  2015/08/17 13:51:14  ddevaraj
 --$ FOR CR35141
 --$
 --$ Revision 1.67  2015/06/10 20:31:11  ddevaraj
 --$ FOR CR34567
 --$
 --$ Revision 1.58  2015/02/03 01:20:26  arijal
 --$ CR32539 net10 redeem card
 --$
 --$ Revision 1.57  2015/02/02 20:12:11  arijal
 --$ CR32539 net10 redeem card
 --$
 --$ Revision 1.56  2015/02/02 18:26:08  arijal
 --$ CR32539 net10 redeem card
 --$
 --$ Revision 1.55  2015/01/22 22:55:07  jpena
 --$ Changes for Brand X
 --$
 --$ Revision 1.52  2014/05/16 20:28:16  sreddy
 --$ CR 28465 Modified the signature of the Main method to return Refcursor
 --$
 --$ Revision 1.51  2014/05/12 15:31:56  sreddy
 --$ $10 ILD card redemption for SIMPLE_MOBILE through IVR
 --$
 --$ Revision 1.50  2014/05/05 18:28:04  icanavan
 --$ ADD IS_TABLET
 --$
 --$ Revision 1.49  2014/04/22 21:29:00  icanavan
 --$ MERGE with production HOME alert
 --$
 --$ Revision 1.48  2014/04/11 15:50:08  icanavan
 --$ added nvl to check if there is a promo
 --$
 --$ Revision 1.47  2014/04/04 15:15:25  icanavan
 --$ Remove reference of HOME ALERT to a DATA CARD
 --$
 --$ Revision 1.46  2014/04/03 21:27:01  ymillan
 --$ CR27269
 --$
 --$ Revision 1.45  2014/04/02 00:19:06  vtummalpally
 --$ Added condition for Home Alert
 --$
 --$ Revision 1.44  2014/04/01 22:07:00  vtummalpally
 --$ Add condition for exclude error 420 when is device home alert
 --$
 --$ Revision 1.41  2013/10/30 22:09:34  icanavan
 --$ cr24661 added back in
 --$
 --$ Revision 1.40 2013/10/07 19:49:14 ymillan
 --$ CR25435
 --$
 --$ Revision 1.39 2013/10/07 14:55:47 ymillan
 --$ CR25435
 --$
 --$ Revision 1.38 2013/09/25 15:43:10 icanavan
 --$ validate home phone plans with home phone handsets
 --$
 --$ Revision 1.37 2013/09/09 17:58:19 icanavan
 --$ CHANGE ERROR FOR IVR
 --$
 --$ Revision 1.36 2013/08/31 19:41:40 mvadlapally
 --$ CR23513 TF Surepay includes 1.35 change
 --$
 --$ Revision 1.35 2013/08/29 18:16:26 icanavan
 --$ to make sure you cant use a homephone pin with a handset
 --$
 --$ Revision 1.34 2013/08/27 22:17:06 icanavan
 --$ change vas cursor to include only TELCEL
 --$
 --$ Revision 1.32 2013/08/09 20:56:45 icanavan
 --$ moved error number 436 to check for the brand
 --$
 --$ Revision 1.29 2013/08/01 21:44:54 icanavan
 --$ cr24661 optimized isvas ('2','3') CR24661
 --$
 --$ Revision 1.26 2013/06/20 19:33:07 icanavan
 --$ Move the 420 and 421
 --$
 --$ Revision 1.23 2013/04/29 21:20:28 icanavan
 --$ exclude VAS SERVICES FROM ERROR 420
 --$
 --$ Revision 1.22 2013/04/04 19:01:58 ymillan
 --$ CR22451
 --$
 --$ Revision 1.20 2012/08/23 18:44:32 icanavan
 --$ TELCEL ADDED /
 --$
 --$ Revision 1.19 2012/07/26 15:46:18 icanavan
 --$ TELCEL DEV1 7/26
 --$
 --$ Revision 1.17 2012/04/17 15:25:13 kacosta
 --$ CR16379 Triple Minutes Cards
 --$
 --$
 ---------------------------------------------------------------------------------------------
 --
 /* Defect # 1351 - Adding a new cursor,variable and IF condition to handle Status 40 card */
 /* Defect # 1359 - Fix for Non Active POSA PIN */
 strstatus VARCHAR2(10);
 strreserveesnid VARCHAR2(20);
 --if in case redemption card is reserved for any ESN
 strredpiobjid VARCHAR2(20);
 --objid of redemption card part inst record
 strmsgnum VARCHAR2(20) := '0';
 strmsgstr VARCHAR2(40) := ' ';
 strsql VARCHAR2(40);
 strselid VARCHAR2(20);
 strreason VARCHAR2(30);
 strcardtype VARCHAR2(20);
 strsmpnumber VARCHAR2(20);
 strptsrno VARCHAR2(20);
 strtemp VARCHAR2(20);
 intesnresuse INTEGER := 0;
 stresnbrand VARCHAR2(30);
 stresnflow VARCHAR2(1); -- CR20451 | CR20854: Add TELCEL Brand
 intunits INTEGER := 0;
 intdays INTEGER := 0;

 --intAmigo INTEGER := 0;
 -- CR8470 function checks if the ESN is enrolled in DM program
 FUNCTION esn_is_enrolled_in_dblmin_fun(p_esn VARCHAR2) RETURN NUMBER IS
 l_count NUMBER := 0;
 BEGIN
 -- If ESN is Null Return 0
 IF p_esn IS NULL THEN
 RETURN l_count; -- ESN Not Found
 END IF;

 -- CR16344 / CR16379

 IF get_restricted_use(p_esn) = 0 THEN
 SELECT COUNT(1)
 INTO l_count
 FROM table_site_part sp
 ,(SELECT pi2.part_serial_no
 FROM table_x_promotion_group pg
 ,table_part_inst pi2
 ,table_x_group2esn ge
 WHERE 1 = 1
 -- CR16379 Start kacosta 03/19/2012
 --AND (pg.group_name = 'DBLMIN_GRP' OR pg.group_name = 'X3XMN_GRP')
 AND pg.group_name = 'DBLMIN_GRP'
 -- CR16379 End kacosta 03/19/2012
 AND ge.groupesn2x_promo_group = pg.objid + 0
 AND ge.groupesn2part_inst = pi2.objid + 0
 AND pi2.part_serial_no = p_esn
 AND SYSDATE BETWEEN ge.x_start_date AND ge.x_end_date
 AND pi2.x_domain || '' = 'PHONES') tab1
 WHERE 1 = 1
 AND tab1.part_serial_no = sp.x_service_id
 AND sp.part_status || '' IN ('Active'
 ,'Obsolete');
 ELSE
 RETURN l_count;
 END IF;

 RETURN l_count;
 EXCEPTION
 WHEN others THEN
 RETURN 0; -- Returns FALSE
 END;
 --
 -- CR16379 Start kacosta 03/19/2012
 FUNCTION esn_is_enrolled_in_x3xmin_fun(p_esn VARCHAR2) RETURN NUMBER IS
 l_count NUMBER := 0;
 BEGIN
 -- If ESN is Null Return 0
 IF p_esn IS NULL THEN
 RETURN l_count; -- ESN Not Found
 END IF;

 IF get_restricted_use(p_esn) = 0 THEN
 SELECT COUNT(1)
 INTO l_count
 FROM table_site_part sp
 ,(SELECT pi2.part_serial_no
 FROM table_x_promotion_group pg
 ,table_part_inst pi2
 ,table_x_group2esn ge
 WHERE 1 = 1
 AND pg.group_name = 'X3XMN_GRP'
 AND ge.groupesn2x_promo_group = pg.objid + 0
 AND ge.groupesn2part_inst = pi2.objid + 0
 AND pi2.part_serial_no = p_esn
 AND SYSDATE BETWEEN ge.x_start_date AND ge.x_end_date
 AND pi2.x_domain || '' = 'PHONES') tab1
 WHERE 1 = 1
 AND tab1.part_serial_no = sp.x_service_id
 AND sp.part_status || '' IN ('Active'
 ,'Obsolete');
 ELSE
 RETURN l_count;
 END IF;

 RETURN l_count;
 EXCEPTION
 WHEN others THEN
 RETURN 0; -- Returns FALSE
 END;
 -- CR16379 End kacosta 03/19/2012
 --
 -- CR8470 CMS_SPLIT END
 PROCEDURE getpartinstredcard
 (
 strredcard IN VARCHAR2
 ,strsmpnumber IN VARCHAR2
 ,p_rc_pric IN OUT rc_out
 ) IS
 BEGIN
 IF (LENGTH(strsmpnumber) > 0) THEN
 OPEN p_rc_pric FOR
 SELECT objid
 ,part_serial_no
 ,x_red_code
 ,x_part_inst_status
 ,part_to_esn2part_inst
 FROM sa.table_part_inst
 WHERE x_domain = 'REDEMPTION CARDS'
 AND x_red_code || '' = RTRIM(strredcard)
 AND part_serial_no = strsmpnumber;
 ELSE
 OPEN p_rc_pric FOR
 SELECT objid
 ,part_serial_no
 ,x_red_code
 ,x_part_inst_status
 ,part_to_esn2part_inst
 FROM sa.table_part_inst
 WHERE x_domain || '' = 'REDEMPTION CARDS'
 AND x_red_code = RTRIM(strredcard);
 END IF;
 EXCEPTION
 WHEN others THEN
 raise_application_error(-20000
 ,SQLCODE || SQLERRM || ' getPartInstRedCard');
 END getpartinstredcard;

 PROCEDURE getredcard
 (
 strredcard IN VARCHAR2
 ,strsmpnumber IN VARCHAR2
 ,rc_rc IN OUT rc_out
 ) IS
 BEGIN
 IF (LENGTH(strsmpnumber) > 0) THEN
 OPEN rc_rc FOR
 SELECT red_card2call_trans
 ,x_red_units
 FROM sa.table_x_red_card
 WHERE x_red_code = RTRIM(strredcard)
 AND x_smp = strsmpnumber
 AND x_result || '' = 'Completed';
 ELSE
 OPEN rc_rc FOR
 SELECT red_card2call_trans
 ,x_red_units
 FROM sa.table_x_red_card
 WHERE x_red_code = RTRIM(strredcard)
 AND x_result || '' = 'Completed';
 END IF;
 EXCEPTION
 WHEN others THEN
 raise_application_error(-20000
 ,SQLCODE || SQLERRM || ' getRedCard');
 END getredcard;

 PROCEDURE inlasttransaction
 (
 stresn IN VARCHAR2
 ,strredcard IN VARCHAR2
 ,p_blnreturn OUT BOOLEAN
 ) IS
 v_blnreturn BOOLEAN := FALSE;
 v_count NUMBER;

 CURSOR count_cur
 (
 strredcard IN VARCHAR2
 ,stresn IN VARCHAR2
 ) IS
 SELECT 1
 FROM sa.table_site_part sp
 ,sa.table_x_call_trans trans
 ,sa.table_x_red_card code
 WHERE 1 = 1
 AND sp.part_status || '' = 'Active'
 AND sp.x_service_id || '' = stresn
 AND sp.objid = trans.call_trans2site_part
 AND trans.x_action_type || '' = '6'
 AND trans.objid = code.red_card2call_trans
 AND code.x_red_code = strredcard;

 count_rec count_cur%ROWTYPE;
 BEGIN
 OPEN count_cur(strredcard
 ,stresn);

 FETCH count_cur
 INTO count_rec;

 IF count_cur%FOUND THEN
 v_blnreturn := TRUE;
 END IF;

 p_blnreturn := v_blnreturn;
 EXCEPTION
 WHEN others THEN
 raise_application_error(-20000
 ,SQLCODE || SQLERRM || ' InLastTransaction');
 END inlasttransaction;

 PROCEDURE getpartinstredcard2part
 (
 strredcard IN VARCHAR2
 ,rc_pric2 IN OUT rc_out
 ) IS
 ref_out rc_out;
 BEGIN
 OPEN ref_out FOR
 SELECT pn.x_redeem_units
 ,pn.x_redeem_days
 ,pn.x_card_type
 ,bo.org_id
 --pn.x_restricted_use,
 FROM sa.table_part_num pn
 ,sa.table_mod_level ml
 ,sa.table_part_inst pi
 ,sa.table_bus_org bo
 WHERE pn.objid = ml.part_info2part_num
 AND ml.objid = pi.n_part_inst2part_mod
 AND pi.x_red_code = strredcard
 AND pn.part_num2bus_org = bo.objid;
 EXCEPTION
 WHEN others THEN
 raise_application_error(-20000
 ,SQLCODE || SQLERRM || ' getPartInstRedCard2Part');
 END getpartinstredcard2part;

 PROCEDURE getposacardinvredcard
 (
 strredcard IN VARCHAR2
 ,p_intreturn OUT INTEGER
 ) IS
 v_intreturn INTEGER := 0;
 v_strpartserialno VARCHAR2(30);
 v_x_value NUMBER;

 CURSOR c_prt_serial IS
 SELECT x_part_serial_no
 FROM sa.table_x_posa_card_inv
 WHERE x_red_code = strredcard
 AND ROWNUM < 2;

 --fix_defect
 CURSOR cur_posa_info(strsmpnumber VARCHAR2) IS
 SELECT pfd.posa_airtime
 ,pfd.posa_phone
 FROM sa.x_posa_flag_dealer pfd
 WHERE pfd.site_id = (SELECT ts.site_id
 FROM table_x_posa_card_inv xpc
 ,table_inv_bin ib
 ,table_site ts
 WHERE ts.site_id = ib.bin_name
 AND ib.objid = xpc.x_posa_inv2inv_bin
 AND xpc.x_part_serial_no = strsmpnumber);

 posa_info_rec cur_posa_info%ROWTYPE;
 v_posa_airtime VARCHAR(1);
 --fix_defect
 -- CURSOR c_x_value
 -- IS
 -- SELECT x_value
 -- FROM sa.table_x_code_table
 -- WHERE x_code_number = '45';
 BEGIN
 OPEN c_prt_serial;

 FETCH c_prt_serial
 INTO v_strpartserialno;

 p_intreturn := v_intreturn + 1;

 IF (LENGTH(v_strpartserialno) > 0) THEN
 --fix_defect
 OPEN cur_posa_info(v_strpartserialno);

 FETCH cur_posa_info
 INTO posa_info_rec;

 IF cur_posa_info%FOUND THEN
 v_posa_airtime := posa_info_rec.posa_airtime;
 END IF;

 CLOSE cur_posa_info;

 /*OPEN c_x_value;
 FETCH c_x_value
 INTO v_x_value;*/
 IF (p_intreturn IS NOT NULL) THEN
 IF (v_posa_airtime = 'Y') THEN
 resetposacard(v_strpartserialno
 ,'POSA_FLAG_ON');
 p_intreturn := '0';
 END IF;
 END IF;
 --CLOSE c_x_value;
 END IF;

 CLOSE c_prt_serial;
 EXCEPTION
 WHEN others THEN
 raise_application_error(-20000
 ,SQLCODE || SQLERRM || ' getPosaCardInvRedCard');
 END getposacardinvredcard;

 PROCEDURE resetposacard
 (
 strselid IN VARCHAR2
 ,strreason IN VARCHAR2
 ) IS
 p_out INTEGER := 0;
 strerrornum VARCHAR2(10) := '0';
 strerrortext VARCHAR2(40); --= "";
 -- String strSQL = "";
 struserobj VARCHAR2(30);
 v_posa_airtime VARCHAR(1);
 --:= (String) m_clfySession.getItem("user.login_name");
 BEGIN
 IF (UPPER(strreason) = 'POSA_FLAG_ON') THEN
 sa.posa.make_card_redeemable(strselid
 ,''
 ,''
 ,''
 ,''
 ,''
 ,''
 ,p_out
 ,p_out
 ,'POSA_FLAG_ON');
 END IF;

 --IF (p_out != NULL) --CR6962
 IF (p_out IS NOT NULL) THEN
 strerrornum := p_out;
 END IF;

 IF (strerrornum = '-100') THEN
 dbms_output.put_line('TFEsnHistory ResetPosaCard: exception ex :ESN:');
 END IF;
 EXCEPTION
 WHEN others THEN
 raise_application_error(-20000
 ,SQLCODE || SQLERRM || ' ResetPosaCard');
 END resetposacard;

 PROCEDURE getredcard2calltrans
 (
 strcalltransid IN NUMBER
 ,rc2ct_rc IN OUT rc_out
 ) IS
 BEGIN
 OPEN rc2ct_rc FOR
 SELECT x_service_id
 FROM sa.table_x_call_trans
 WHERE objid = strcalltransid;
 EXCEPTION
 WHEN others THEN
 raise_application_error(-20000
 ,SQLCODE || SQLERRM || ' getRedCard2CallTrans');
 END getredcard2calltrans;

 PROCEDURE getpartclass
 (
 strredcard IN VARCHAR2
 ,pc_rc IN OUT rc_out
 ) IS
 BEGIN
 OPEN pc_rc FOR
 SELECT pc.name NAME
 FROM sa.table_part_class pc
 ,sa.table_part_num pn
 ,sa.table_mod_level ml
 ,sa.table_part_inst pi
 WHERE pc.objid = pn.part_num2part_class
 AND pn.objid = ml.part_info2part_num
 AND ml.objid = pi.n_part_inst2part_mod
 AND pi.x_red_code = strredcard;
 EXCEPTION
 WHEN others THEN
 raise_application_error(-20000
 ,SQLCODE || SQLERRM || ' getPartClass');
 END getpartclass;

 --------------------------------------
 -- PROCEDURE OVERLOADED NOT NOT MODIFY
 --------------------------------------
 PROCEDURE main
 (
 strredcard IN VARCHAR2
 ,strsmpnumber IN VARCHAR2
 ,strsourcesys IN VARCHAR2
 ,stresn IN VARCHAR2
 ,strsubsourcesystem IN VARCHAR2 DEFAULT NULL
 ,
 -- CR8663 WALMART SWITCH BASE
 strstatus OUT VARCHAR2
 ,intunits OUT INTEGER
 ,intdays OUT INTEGER
 ,intamigo OUT INTEGER
 ,strmsgnum OUT VARCHAR2
 ,strmsgstr OUT VARCHAR2
 ,strerrorpin OUT VARCHAR2
 ) IS
 v_rc_pirc rc_out;
 v_rc_rc rc_out;
 v_rc_pirc2 rc_out;
 v_ref_out rc_out;
 v_prtsn_rc rc_out;
 v_pc_rc rc_out;
 v_strstatus VARCHAR2(10);
 v_strreserveesnid VARCHAR2(20);
 v_strredpiobjid VARCHAR2(20);
 v_strmsgnum VARCHAR2(20);
 v_strmsgstr VARCHAR2(40);
 v_strsql VARCHAR2(40);
 v_strsmpnumber VARCHAR2(20);
 v_strcardtype VARCHAR2(20);
 v_strptsrno VARCHAR2(20);
 v_strtemp VARCHAR2(20);
 v_prtsn VARCHAR2(40);
 v_status VARCHAR2(10);
 v_pc VARCHAR2(40);
 v_name VARCHAR2(40);
 v_objtemp NUMBER;
 v_strredesn VARCHAR2(40);
 v_stresn VARCHAR2(40);
 v_strredcard VARCHAR2(40);
 v_x_part_inst_status VARCHAR2(30);
 v_dllid INTEGER;
 p_intreturn INTEGER;
 v_getposa INTEGER;
 objtemp NUMBER;
 strred_card VARCHAR2(40);
 strredesn VARCHAR2(40);
 v_strexpires DATE;
 v_strcurrent DATE := SYSDATE;
 v_intesnresuse INTEGER := 0;
 v_intunits INTEGER := 0;
 v_intdays INTEGER := 0;
 v_intamigo INTEGER := 0;
 v_parttype VARCHAR2(30); ---- added for LLcards
 v_part_number VARCHAR2(30); ---- CR47988
 v_esntemp VARCHAR2(20);
 v_bln BOOLEAN;
 v_esnll VARCHAR2(30); ----added for LL
 v_offer NUMBER := 0; -- CR8470
 v_service_plan_group  sa.service_plan_feat_pivot_mv.service_plan_group%type; -- CR42459  CR47024
 v_flag                VARCHAR2(25);  -- CR47024
 v_paygo_flag          VARCHAR2(25);  -- CR47024
 v_splan_group_esn     x_serviceplanfeaturevalue_def.value_name%type;
 v_brm_service_days  INTEGER := 0;
 -- CR8470
 CURSOR x_offer_cur IS
 SELECT *
 FROM x_dblmn_offer;

 x_offer_rec x_offer_cur%ROWTYPE;

 -- CR8663 WALMART SWITCH BASE PER (365) WALMART STRAIGHT_TALK
 CURSOR straight_talk_esn_cur(v_stresn IN VARCHAR2) IS
 SELECT x_param_value
 FROM table_part_class pc
 ,table_x_part_class_values pv
 ,table_x_part_class_params pp
 WHERE pv.value2part_class = pc.objid
 AND pv.value2class_param = pp.objid
 AND x_param_name = 'NON_PPE'
 AND pv.x_param_value IN ('1'
 ,'0') -- '0' ST_GSM CR11971
 AND pc.name IN (SELECT pc.name
 FROM sa.table_part_num pn
 ,sa.table_mod_level ml
 ,sa.table_part_inst pi
 ,sa.table_part_class pc
 ,sa.table_bus_org bo
 WHERE pi.n_part_inst2part_mod = ml.objid
 AND pn.part_num2bus_org = bo.objid
 AND bo.org_id = 'STRAIGHT_TALK' -- ST_GSM CR11971
 AND ml.part_info2part_num = pn.objid
 AND pn.part_num2part_class = pc.objid
 AND pi.part_serial_no = v_stresn);

 straight_talk_esn_rec straight_talk_esn_cur%ROWTYPE;

 -- CR8663 WALMART SWITCH BASE END
 CURSOR isllesn( --------CURSOR FOR LLESN
 v_stresn IN VARCHAR2) IS
 SELECT pe.x_esn
 FROM x_program_enrolled pe
 WHERE pe.x_esn = v_stresn
 AND pe.x_enrollment_status = 'ENROLLED'
 AND pe.x_sourcesystem = 'VMBC';

 CURSOR c_rst_use(v_stresn IN VARCHAR2) IS
 SELECT x_restricted_use
 FROM sa.table_part_num pn
 ,sa.table_mod_level ml
 ,sa.table_part_inst pi
 WHERE pn.objid = ml.part_info2part_num
 AND ml.objid = pi.n_part_inst2part_mod
 AND pi.part_serial_no = v_stresn;

 CURSOR c_redcard2part(strredcard IN VARCHAR2) IS
 SELECT pn.x_redeem_units
 ,pn.x_redeem_days
 ,pn.x_restricted_use
 ,pn.x_card_type
 ,pi.part_to_esn2part_inst
 ,pi.x_part_inst_status
 ,pn.part_type ---added forll
 ,pn.part_number  --CR47988
 FROM sa.table_part_num pn
 ,sa.table_mod_level ml
 ,sa.table_part_inst pi
 WHERE pn.objid = ml.part_info2part_num
 AND ml.objid = pi.n_part_inst2part_mod
 AND pi.x_red_code = strredcard;

 CURSOR c_phonebyesn(v_stresn IN VARCHAR2) IS
 SELECT sa.table_part_num.x_dll
 FROM sa.table_part_inst
 ,sa.table_mod_level
 ,sa.table_part_num
 WHERE sa.table_part_inst.part_serial_no = stresn
 AND sa.table_mod_level.objid = sa.table_part_inst.n_part_inst2part_mod
 AND sa.table_part_num.objid = sa.table_mod_level.part_info2part_num
 AND sa.table_part_inst.x_domain = 'PHONES';

 CURSOR c_status(strredcard IN VARCHAR2) IS
 SELECT 'X'
 FROM sa.table_x_posa_card_inv
 WHERE x_red_code = strredcard;

 CURSOR c_part_serial_no_new(v_temp VARCHAR2) -- Defect_fix for 1351
 IS
 SELECT part_serial_no
 FROM sa.table_part_inst
 WHERE objid = v_objtemp;
 BEGIN
 --no PIN given
 IF (LENGTH(TRIM(strredcard)) = 0) THEN
 strerrorpin := 'Error: Pin' || strredcard || 'not valid. Please verify and retry';
 dbms_output.put_line(strerrorpin);
 strmsgnum := '401';
 strmsgstr := sa.get_code_fun('SA.VALIDATE_RED_CARD_PKG'
 ,strmsgnum
 ,'ENGLISH');
 --strMsgStr := 'Card Not Found';
 GOTO package_end;
 END IF;
 dbms_output.put_line('1');
 --a POS card?
 --IF (strSourceSys != NULL --CR6962
 IF (strsourcesys IS NOT NULL AND (strsourcesys = 'IVR' OR strsourcesys = 'NETIVR')) THEN
 getpartclass(strredcard
 ,v_pc_rc);

 FETCH v_pc_rc
 INTO v_pc;

 v_name := v_pc;
 END IF;

 OPEN c_status(strredcard);

 FETCH c_status
 INTO v_status;

 IF (v_status IS NOT NULL) THEN
 getposacardinvredcard(strredcard
 ,p_intreturn);
 dbms_output.put_line('p_intreturn:' || p_intreturn);
 IF (P_INTRETURN > 0) THEN
 IF (strsourcesys in ('TAS', 'WEBCSR', 'NETCSR')) THEN --CR22451
 strmsgnum := '404';
 strmsgstr := sa.get_code_fun('SA.VALIDATE_RED_CARD_PKG'
 ,strmsgnum
 ,'ENGLISH');
 --strMsgStr := 'POSA card is not Active.';
 GOTO package_end;
 ELSE
 strerrorpin := 'Error: Pin not activated. Please retry in 30 minutes';
 dbms_output.put_line(strerrorpin);
 strmsgnum := '410';
 strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
 ,strmsgnum
 ,'ENGLISH');
 --strMsgStr := 'POSA Card not valid for redemption.';
 GOTO package_end;
 END IF;
 END IF;
 END IF;

 -- IF get the card from inventory

 getpartinstredcard(strredcard
 ,strsmpnumber
 ,v_rc_pirc);
 dbms_output.put_line('strredcard:' || strredcard);
 dbms_output.put_line('strsmpnumber:' || strsmpnumber);

 FETCH v_rc_pirc
 INTO v_strredpiobjid
 ,v_strsmpnumber
 ,v_strredcard
 ,v_strstatus
 ,v_objtemp;

 IF v_rc_pirc%FOUND THEN
 strred_card := v_strredcard;
 strstatus := v_strstatus;
 objtemp := v_objtemp;

 OPEN c_part_serial_no_new(v_objtemp); -- Defect_fix for 1351

 FETCH c_part_serial_no_new
 INTO v_esntemp;
 dbms_output.put_line('v_esntemp:' || v_esntemp);

 IF c_part_serial_no_new%FOUND THEN
 --IF (objTemp != NULL) --CR6962
 IF (objtemp IS NOT NULL) THEN
 dbms_output.put_line('objtemp:' || objtemp);
 strredpiobjid := v_strredpiobjid;
 strreserveesnid := v_esntemp;
 END IF;
 END IF;
 ELSE
 --ELSE not in inventory
 --check if has been redeemed
 getredcard(strredcard
 ,strsmpnumber
 ,v_rc_rc);

 FETCH v_rc_rc
 INTO v_strtemp
 ,v_intunits;
 dbms_output.put_line(v_strtemp);
 dbms_output.put_line(v_intunits);
 dbms_output.put_line(strsourcesys);

 IF V_RC_RC%FOUND THEN
 IF (strsourcesys in ('TAS', 'WEBCSR', 'NETCSR')) --CR22451
 OR (strsourcesys = 'HANDSET' OR strsourcesys = 'NETHANDSET') THEN
 strerrorpin := 'Error: Pin ' || strredcard || ' already used';
 dbms_output.put_line(strerrorpin);
 strmsgnum := '402';
 strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
 ,strmsgnum
 ,'ENGLISH');
 --strMsgStr := 'This Card has already been redeemed.';
 GOTO package_end;
 END IF;

 strtemp := v_strtemp;

 --IF (strTemp != NULL--CR6962
 IF (strtemp IS NOT NULL AND LENGTH(strtemp) > 0) THEN
 getredcard2calltrans(strtemp
 ,v_ref_out);

 FETCH v_ref_out
 INTO v_strredesn;

 IF v_ref_out%FOUND THEN
 strredesn := v_strredesn;
 END IF;
 END IF;

 IF (LENGTH(strredesn) = 0) THEN
 strerrorpin := 'Error: Pin ' || strredcard || ' is reserved for an Invalid ESN';
 dbms_output.put_line(strerrorpin);
 strmsgnum := '405';
 strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
 ,strmsgnum
 ,'ENGLISH');
 --strMsgStr := 'Card is reserved for an Invalid ESN.';
 GOTO package_end;
 --ELSIF ( NOT (strRedEsn = (strESN)))
 ELSIF (NOT (strredesn = (stresn)) OR (strredesn = stresn))
 --CR7236
 THEN
 strerrorpin := 'Error: Pin ' || strredcard || ' already used on another phone';
 dbms_output.put_line(strerrorpin);
 strmsgnum := '402';
 strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
 ,strmsgnum
 ,'ENGLISH');
 --strMsgStr := 'This Card has already been redeemed.';
 GOTO package_end;
 ELSE
 -- InLastTransaction(strRedCard,strEsn, v_bln);
 inlasttransaction(stresn
 ,strredcard
 ,v_bln); --CR7236

 IF NOT (v_bln) THEN
 strerrorpin := 'Error: Pin ' || strredcard || 'not valid. Please verify and retry';
 strmsgnum := '403';
 strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
 ,strmsgnum
 ,'ENGLISH');
 dbms_output.put_line(strredcard);
 dbms_output.put_line(stresn);
 --strMsgStr := 'Card not valid for redemption.Already redemed';
 strstatus := '41'; -- has been redeemed
 intunits := v_intunits;
 GOTO package_end;
 END IF;
 END IF;
 ELSE
 --not inventory, not redeemed, just a bad pin
 strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
 dbms_output.put_line(strerrorpin);
 strmsgnum := '413';
 strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
 ,strmsgnum
 ,'ENGLISH');
 --strMsgStr := 'Invalid PIN.';
 GOTO package_end;
 END IF;
 END IF;

 --thru here if in inventory
 --convert reserved objid to reserved ESN (ugh!)
 dbms_output.put_line('strreserveesnid:' || strreserveesnid);
 IF (LENGTH(strreserveesnid)) > 0 THEN
 FOR rec1 IN (SELECT part_serial_no
 FROM sa.table_part_inst
 --WHERE objid = strreserveesnid) CR19461
 WHERE part_serial_no = strreserveesnid) LOOP
 strreserveesnid := rec1.part_serial_no;
 dbms_output.put_line('2:' || rec1.part_serial_no);
 END LOOP;
 END IF;

 --IF reserved
 --IF (TRIM (strstatus) = '40')
 IF (TRIM(strstatus) IN ('40'
 ,'400')) -- CR12989 ST Retention PM.
 THEN
 -- bad ESN
 IF (LENGTH(strreserveesnid) = 0) THEN
 strerrorpin := 'Error: Pin ' || strredcard || ' is reserved for an Invalid ESN';
 dbms_output.put_line(strerrorpin);
 --strMsgNum := '405';
        strmsgnum := '431'; -- Changed to 431 from 405 CR7259 SK
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'Card is reserved for an invalid ESN.';
        GOTO package_end;
        -- not my ESN
      ELSIF (NOT (strreserveesnid = stresn)) THEN
        dbms_output.put_line('strreserveesnid:' || strreserveesnid);
        dbms_output.put_line('stresn:' || stresn);
        strerrorpin := 'Error: Pin ' || strredcard || ' already used on another phone';
        dbms_output.put_line(strerrorpin);
        --strMsgNum := '402';
        strmsgnum := '430'; -- Changed to 430 from 402 CR7259 SK
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'Card is reserved for a different phone.';
        GOTO package_end;
      END IF;
    ELSIF (TRIM(strstatus) = '263') THEN
      -- bad ESN
      IF (LENGTH(strreserveesnid) = 0) THEN
        strerrorpin := 'Error: Pin ' || strredcard || ' is reserved for an Invalid ESN';
        dbms_output.put_line(strerrorpin);
        strmsgnum := '414';
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'Card invalid.';
        GOTO package_end;
        -- not my ESN
      ELSIF (NOT (strreserveesnid = stresn)) THEN
        strerrorpin := 'Error: Pin ' || strredcard || ' already used on another phone';
        dbms_output.put_line(strerrorpin);
        strmsgnum := '427';
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'reserved for a different phone';
        GOTO package_end;
      ELSE
        IF (strreserveesnid = stresn) THEN
          strerrorpin := 'Error: Pin ' || strredcard || ' already reserved for another phone';
          dbms_output.put_line(strerrorpin);
          strmsgnum := '428';
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                      ,strmsgnum
                                      ,'ENGLISH');
          --strMsgStr := 'Card pending redemption';
          GOTO package_end;
        END IF;
      END IF;
      -- else not reserved
    ELSIF ((TRIM(strstatus) = '43'))
    --OR (TRIM(strStatus) = '263'))
     THEN
      --CR3972 // if pending (regular or OTA)
      --bad ESN or not me
      IF ((LENGTH(strreserveesnid) = 0) OR (NOT (NVL(strreserveesnid
                                                    ,'0') = stresn))) THEN
        strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
        dbms_output.put_line(strerrorpin);
        strmsgnum := '403';
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'Card not valid for Redemption.';
        GOTO package_end;
      ELSE
        -- it's mine pending
        strstatus := '40'; --make reserved

        UPDATE table_part_inst
           SET x_part_inst_status  = '40'
              ,status2x_code_table =
               (SELECT objid
                  FROM sa.table_x_code_table
                 WHERE x_code_number = '40')
         WHERE objid = strredpiobjid;
      END IF;
      -- else if redeemed
    ELSIF (TRIM(strstatus) = '41') THEN
      --reserved for bad or wrong phone
      IF (LENGTH(strreserveesnid) = 0) THEN
        strerrorpin := 'Error: Pin ' || strredcard || ' already reserved for another phone';
        dbms_output.put_line(strerrorpin);
        strmsgnum := '405';
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'Card is reserved for an invalid ESN.';
        GOTO package_end;
      ELSE
        IF (NOT (strreserveesnid) = (stresn)) THEN
          strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
          dbms_output.put_line(strerrorpin);
          strmsgnum := '403';
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                      ,strmsgnum
                                      ,'ENGLISH');
          --strMsgStr := 'Card not valid for redemption.';
          GOTO package_end;
        ELSE
          --InLastTransaction(strRedCard, strEsn, v_bln);
          inlasttransaction(stresn
                           ,strredcard
                           ,v_bln); --CR7236

          IF NOT (v_bln) THEN
            strerrorpin := 'Error: Pin ' || strredcard || ' already reserved for another phone';
            dbms_output.put_line(strerrorpin);
            strmsgnum := '402';
            strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                        ,strmsgnum
                                        ,'ENGLISH');
            --strMsgStr := 'Card is reserved for a different phone.';
            GOTO package_end;
          END IF;
        END IF;
      END IF;
    ELSIF (TRIM(strstatus) = '44') THEN
      --OR (TRIM(strStatus) = '45')) - Changed to 432 for status 45 from 403
      strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '403';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'Card not valid for Redemption';
      GOTO package_end;
    ELSIF --((TRIM(strStatus) = '44')
     (TRIM(strstatus) = '45') THEN
      strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '432'; -- Changed to 432 for status 45 from 403
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'Card not valid for Redemption';
      GOTO package_end;
    ELSIF (TRIM(strstatus) = '75') THEN
      strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '407';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'Card is obselete, return it to retailer.';
      GOTO package_end;
  -- CR25668
    ELSIF (TRIM(strstatus) = '47') THEN
      strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '403';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'Card not valid for Redemption';
      GOTO package_end;
    END IF;
dbms_output.put_line('strredcard:'|| strredcard);
    --get this card
    --getPartInstRedCard2Part(strRedCard, v_rc_pirc2);
    OPEN c_redcard2part(strredcard);

    --CR8013
    --       FETCH c_RedCard2Part
    --       INTO v_intUnits, v_intDays, v_intAmigo, v_objTemp,
    --       v_x_part_inst_status,v_parttype;     -----ADDED FOR LIFE LINE
    FETCH c_redcard2part
      INTO v_intunits
          ,v_intdays
          ,v_intamigo
          ,v_strcardtype
          ,v_objtemp
          ,v_x_part_inst_status
          ,v_parttype -----ADDED FOR LIFE LINE
          ,v_part_number; --CR47988

    --CR47564 WFM starts here - If WFM get the service days from x_part_inst_ext
    IF sa.customer_info.get_brm_notification_flag ( i_esn => stresn) = 'Y' THEN
      v_brm_service_days := sa.customer_info.get_esn_pin_redeem_days (i_esn => stresn , i_pin => strredcard);
	  v_intdays := CASE v_brm_service_days WHEN 0 THEN v_intdays ELSE v_brm_service_days END;
    END IF;
    --CR47564 WFM ends here

    --CR8013
    IF c_redcard2part%FOUND THEN
      --IF ((v_x_part_inst_status = '40') AND (strreserveesnid != stresn))
      IF ((v_x_part_inst_status IN ('40'
                                   ,'400')) AND (strreserveesnid != stresn)) --CR12989 ST Retention PM
       THEN
        -- Defect_fix for 1351
        strerrorpin := 'Error: Pin ' || strredcard || ' already used on another phone';
        dbms_output.put_line(strerrorpin);
        --strMsgNum := '402';
        strmsgnum := '430'; -- Changed to 430 from 402 Per CR7259 SK
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'Card is reserved for a different phone.';
      ELSE
        intunits := v_intunits;
        intdays  := v_intdays;
        intamigo := v_intamigo;
        objtemp  := v_objtemp;
        -- CMC_SPLIT START
        v_offer := esn_is_enrolled_in_dblmin_fun(stresn);

        IF v_offer > 0 THEN
          --open x_offer_cur ;
          --fetch x_offer_cur into x_offer_rec ;
          FOR x_offer_rec IN x_offer_cur LOOP
            IF intunits = x_offer_rec.at_units
               AND intdays = x_offer_rec.at_days THEN
              intunits  := x_offer_rec.offered_units;
              intdays   := x_offer_rec.offered_days;
              strmsgnum := '425'; -- CMC_SPLIT
              strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                          ,strmsgnum
                                          ,'ENGLISH');
            END IF;
          END LOOP;
        END IF;
      END IF;

      -- END IF;
      --IF(objTemp != NULL) --CR6962
      IF (objtemp IS NOT NULL) THEN
        --   strCardType := objTemp;
        strcardtype := v_strcardtype; --CR8013
      END IF;
    ELSE
      strmsgnum := '406';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      -- strMsgStr := 'No Part/mod Level record found';
      GOTO package_end;
    END IF;

    CLOSE c_redcard2part;

    --what about restricted use
    OPEN c_rst_use(stresn);

    FETCH c_rst_use
      INTO v_intesnresuse;

    IF c_rst_use%FOUND THEN
      intesnresuse := v_intesnresuse;
    ELSE
      strmsgnum := '411';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'ESN not valid.';
      GOTO package_end;
    END IF;

    CLOSE c_rst_use;

    --dont allow it if it's restricted for various reasons (wrong product, etc.)
    IF (NOT (intesnresuse = 1) AND (intamigo = 1)) THEN
      strerrorpin := 'Error: Amigo Pin entered on TracFone';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '409';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'TracFone ESN not compatible with Amigo redemption card.';
      GOTO package_end;
    ELSIF ((intesnresuse = 1) AND (intamigo = 2)) THEN
      strerrorpin := 'Error: non-Amigo Pin entered on Amigo';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '408';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr :=
      --'Amigo ESN not compatible with non-Amigo redemption card.';
      GOTO package_end;
    ELSIF ((intesnresuse = 1) AND (intamigo = 3)) THEN
      strerrorpin := 'Error: Net10 Pin entered on TracFone.';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '416';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'TracFone ESN not compatible with NET10 redemption card.';
      GOTO package_end;
    ELSIF ((intesnresuse = 3) AND (intamigo != 3)) THEN
      strerrorpin := 'Error: TracFone Pin entered on NET10 Phone.';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '415';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr :=
      -- 'NET10 ESN should only be used with NET10 Redemption card.';
      GOTO package_end;
    ELSIF ((intesnresuse != 3) AND (intamigo = 3)) THEN
      strerrorpin := 'Error: NET10 Pin entered on TracFone.';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '415';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr :=
      -- 'NET10 Redemption Cards should only be used with NET10 ESN.';
      GOTO package_end;
    END IF;



   -- CR42459 Safelink Unlimited.   -- CR47024 start.
   BEGIN
      SELECT mv.service_plan_group
        INTO v_service_plan_group
        FROM sa.table_part_class pc ,
             sa.table_part_num pn ,
             sa.table_mod_level ml ,
             sa.table_part_inst pi ,
             sa.mtm_partclass_x_spf_value_def mtmspfv ,
             sa.x_serviceplanfeature_value spfv ,
             sa.x_service_plan_feature spf ,
             sa.x_service_plan sp,
             sa.service_plan_feat_pivot_mv mv
       WHERE pc.objid = pn.part_num2part_class
         AND pn.objid = ml.part_info2part_num
         AND ml.objid = pi.n_part_inst2part_mod
         AND pi.x_red_code = strredcard
         AND mtmspfv.part_class_id = pc.objid
         AND mtmspfv.spfeaturevalue_def_id = spfv.value_ref
         AND spfv.spf_value2spf = spf.objid
         AND spf.sp_feature2service_plan = sp.objid
         AND sp.objid = mv.service_plan_objid
         AND ROWNUM = 1;

   EXCEPTION WHEN OTHERS THEN
      v_service_plan_group := NULL;

   END;

   IF get_device_type(stresn) = 'FEATURE_PHONE'
      AND
      NVL(GET_DATA_MTG_SOURCE (stresn),'PPE') = 'PPE' THEN
      IF f_product_allowed_sl_ppe(stresn) = 0
         AND
         v_service_plan_group  = 'TFSL_UNLIMITED' THEN
            dbms_output.put_line(stresn);
            strmsgnum := '442';
            strmsgstr := 'This device does not support unlimited plans: ';
            GOTO package_end;
      END IF;
   END IF;

     BEGIN
     v_flag := 'N';

        SELECT DISTINCT flg
          INTO v_flag
          FROM (SELECT 'Y' flg
                  FROM x_program_enrolled pe,
                       x_program_parameters pgm,
                       x_sl_currentvals slcur,
                       table_bus_org borg,
                       table_x_promotion tp
                 WHERE 1                       = 1
                   AND pgm.objid               = pe.pgm_enroll2pgm_parameter
                   AND slcur.x_current_esn     = pe.x_esn
                   AND sysdate BETWEEN pgm.x_start_date AND pgm.x_end_date
                   AND pgm.x_prog_class        = 'LIFELINE'
                   AND pe.x_esn                = stresn
                   AND borg.objid              = pgm.PROG_PARAM2BUS_ORG
                   AND org_id                  = 'TRACFONE'
                   AND pgm.x_promo_incl_min_at = tp.objid
                   AND rownum                  = 1);


     EXCEPTION WHEN OTHERS THEN
        v_flag := 'N';
     END;

     -- CR47024  Block if non sl customer tries to redeem sl card.

     IF v_flag = 'N'  -- Is not safelink customer
        AND
        v_service_plan_group  = 'TFSL_UNLIMITED'  -- Buying Safelink service plan
        THEN
           dbms_output.put_line(stresn);
           strmsgnum := '443';
           strmsgstr := 'This is not a SL customer and card is SL only '||stresn;
           GOTO package_end;
      END IF;

      --Below edit added for CR47988
      IF NVL(is_safelink(stresn, NULL), 'Y') = 'N' AND NVL(is_sl_red_pn(v_part_number), 'N') = 'Y'
      THEN --{
       dbms_output.put_line(stresn);
       strmsgnum := '443';
       strmsgstr := 'This is not a SL customer and card is SL only. '||stresn;
       GOTO package_end;
      END IF; --}
          -- CR47024
          v_splan_group_esn := NULL;
          BEGIN
          SELECT sa.get_serv_plan_value(sa.UTIL_PKG.get_service_plan_id(stresn),
                                                                        'SERVICE_PLAN_GROUP') service_plan_group
            INTO v_splan_group_esn
            FROM DUAL;

          EXCEPTION WHEN OTHERS THEN
             v_splan_group_esn := NULL;

          END;


          v_paygo_flag := 'N';
          BEGIN

             SELECT 'Y'
               INTO v_paygo_flag
               FROM x_serviceplanfeaturevalue_def spfvdef,
                    x_serviceplanfeature_value spfv,
                    x_service_plan_feature spf,
                    x_serviceplanfeaturevalue_def spfvdef2,
                    x_service_plan sp
              WHERE 1 =1
                AND spf.sp_feature2service_plan = sp.objid
                AND sp.objid IN (SELECT sp_objid
                                   FROM sa.table_part_num pn,
                                        sa.table_mod_level ml,
                                        sa.table_part_inst pi,
                                        sa.table_part_class pc,
                                        sa.adfcrm_serv_plan_class_matview
                                  WHERE 1 = 1
                                    AND pn.objid = ml.part_info2part_num
                                    AND ml.objid = pi.n_part_inst2part_mod
                                    and pn.part_num2part_class  = pc.objid
                                    and pi.x_red_code = strredcard
                                    and part_class_name = pc.name)
                AND spf.sp_feature2rest_value_def = spfvdef.objid
                AND spf.objid = spfv.spf_value2spf
                AND spfvdef2.objid = spfv.value_ref
                AND spfvdef2.value_name = 'PAY_GO';

          EXCEPTION WHEN OTHERS THEN
             v_paygo_flag := 'N';

          END;



   IF v_splan_group_esn = 'TFSL_UNLIMITED' -- Customer is on unlimited plan.
      AND
      v_paygo_flag = 'Y' THEN  -- They are buying paygo card.
         dbms_output.put_line(stresn);
         strmsgnum := '444';
         strmsgstr := 'This SL customer on unlimited plan unable to buy Paygo card: '||stresn;
         GOTO package_end;
   END IF;


         -- CR47024 end

    OPEN c_phonebyesn(stresn);

    FETCH c_phonebyesn
      INTO v_dllid;

    IF ((strstatus = '280') AND (strsourcesys = 'HANDSET')) THEN
      IF c_phonebyesn%FOUND THEN
        IF (v_dllid < 22) THEN
          strerrorpin := 'Please visit our website at tracfone.com or contact Customer Care to add this PIN';
          dbms_output.put_line(strerrorpin);
        ELSE
          strerrorpin := 'Visit our website at tracfone.com or call Customer Care to add this PIN';
          dbms_output.put_line(strerrorpin);
        END IF;
      END IF;

      strmsgnum := '417';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := strErrorPin;
      GOTO package_end;
    END IF;

    -- XXX:CR6178
    -- (tp #2328)
    -- expired wagner
    IF (strstatus = '281') THEN
      strerrorpin := 'Error: Expired Settlement Benefit PIN';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '419';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'Expired Settlement Benefit PIN.';
      GOTO package_end;
    END IF;

    -- if it is autopay, identify as such
    IF (UPPER(TRIM(strcardtype)) = 'AUTOPAY') THEN
      strmsgnum := '412';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'AutoPay Redemption Card';
      GOTO package_end;
    END IF;

    -- XXX:CR6178
    -- (tp #2328)
    -- if it is wagner, identify as such
    ---Check for lifeline cards
    ----LIFE LINE ESN CURSOR TO CHECK FOR LIFELINE ESN
    -- OPEN ISLLESN(strEsn);
    --FETCH ISLLESN INTO V_ESNll;
    IF (v_parttype = 'LLPAID') THEN
      ------ADDED FOR LL
      OPEN isllesn(stresn);

      FETCH isllesn
        INTO v_esnll;

      IF isllesn%NOTFOUND THEN
        strerrorpin := 'Error: This is a life line pin';
        dbms_output.put_line(strerrorpin);
        strmsgnum := 433; ----NEW ERROR CODE FOR LIFELINE CARDS
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
      ELSE
        GOTO package_end;
      END IF;

      CLOSE isllesn;
    END IF;

    -- CR8663 WALMART SWITCH BASE
    IF strsubsourcesystem = 'STRAIGHT_TALK' THEN
      OPEN straight_talk_esn_cur(stresn);

      FETCH straight_talk_esn_cur
        INTO straight_talk_esn_rec;

      IF (v_parttype <> 'MPPAID')
         OR straight_talk_esn_cur%NOTFOUND
         OR strsourcesys NOT LIKE 'NET%' THEN
        strerrorpin := 'Error: Straight Talk Switch Error';
        dbms_output.put_line(strerrorpin);
        strmsgnum := 434;
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        GOTO package_end;
      END IF;
    ELSE
      OPEN straight_talk_esn_cur(stresn);

      FETCH straight_talk_esn_cur
        INTO straight_talk_esn_rec;

      IF (v_parttype = 'MPPAID')
         OR straight_talk_esn_cur%FOUND THEN
        strerrorpin := 'Error: Cant use Straight Talk phone or pin';
        dbms_output.put_line(strerrorpin);
        strmsgnum := 435;
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        GOTO package_end;
      END IF;
    END IF;

    -- CR8663 WALMART SWITCH BASE END
    IF (strstatus = '280') THEN
      strmsgnum := '418';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'Valid Wagner Card';
      GOTO package_end;
    END IF;

    <<package_end>>
  ----------- Close Open Cursors
    IF straight_talk_esn_cur%ISOPEN THEN
      CLOSE straight_talk_esn_cur;
    END IF;

    -----------
    IF (intunits IS NULL) THEN
      intunits := 0;
    END IF;

    IF (intdays IS NULL) THEN
      intdays := 0;
    END IF;

    IF (intamigo IS NULL) THEN
      intamigo := 0;
    END IF;

    IF (strmsgnum IS NULL) THEN
      strmsgnum := '0';
    END IF;

    IF (strmsgstr IS NULL) THEN
      strmsgstr := ' ';
    END IF;

    IF (strerrorpin IS NULL) THEN
      strerrorpin := ' ';
    END IF;

    dbms_output.put_line('strStatus = ' || strstatus);
    dbms_output.put_line('intUnits = ' || intunits);
    dbms_output.put_line('intDays = ' || intdays);
    dbms_output.put_line('intAmigo = ' || intamigo);
    dbms_output.put_line('strRedCard = ' || strredcard);
    dbms_output.put_line('strMsgNum = ' || strmsgnum);
    dbms_output.put_line('strMsgStr = ' || strmsgstr);
  EXCEPTION
    WHEN others THEN
      raise_application_error(-20000
                             ,SQLCODE || SQLERRM || ' Main');
  END main;

    -- CR27269 MODIFIED THIS CURSOR TO EXCLUDE SIMPLE MOBILE
    /*
    --CR41823
    --The below query is modified for not allowing the data cards and smart phone cards for PPE for TF
    */
    FUNCTION is_data_card (in_part_num IN table_part_num.part_number%TYPE)
        RETURN BOOLEAN
    IS
        CURSOR dc_cur
        IS
            SELECT COUNT (1) cnt
              FROM table_part_num n
             WHERE ((n.x_card_type = 'DATA CARD')
	             OR (n.x_sourcesystem IN  ('DATA CARD','SMARTPHONE RED CARD')
		         AND part_num2bus_org IN ( select objid from table_bus_org where org_id= 'TRACFONE'))
		   )
             AND part_num2bus_org NOT IN (
             SELECT OBJID FROM TABLE_BUS_ORG WHERE ORG_ID='SIMPLE_MOBILE')
             AND part_number = in_part_num;

        dc_rec   dc_cur%ROWTYPE;
    BEGIN
        IF (in_part_num IS NOT NULL)
        THEN
            OPEN dc_cur;
            FETCH dc_cur INTO dc_rec;
            CLOSE dc_cur;
        END IF;

        RETURN (dc_rec.cnt != 0);
    END is_data_card;
    -----------------------------------------------------FOR CR35141------------------------------
      FUNCTION is_TEXT_card (in_part_num IN table_part_num.part_number%TYPE)
        RETURN BOOLEAN
    IS
        CURSOR dc_cur
        IS
            SELECT COUNT (1) cnt
              FROM table_part_num n
             WHERE n.x_card_type = 'TEXT ONLY'
             AND PART_NUM2BUS_ORG NOT IN (
             SELECT OBJID FROM TABLE_BUS_ORG WHERE ORG_ID='SIMPLE_MOBILE')
             AND part_number = in_part_num;

        dc_rec   dc_cur%ROWTYPE;
    BEGIN
        IF (in_part_num IS NOT NULL)
        THEN
            OPEN dc_cur;
            FETCH dc_cur INTO dc_rec;
            CLOSE dc_cur;
        END IF;

        RETURN (dc_rec.cnt != 0);
    END is_TEXT_card;
    --------------------------------------END CR35141------------------------------------------

	 -----------------------------------------------------FOR CR38145------------------------------
      FUNCTION is_smartphone_red_card (in_part_num IN table_part_num.part_number%TYPE)
        RETURN BOOLEAN
        IS
        CURSOR sph_redcard_cur
        IS
            SELECT COUNT (1) cnt
              FROM table_part_num n
             WHERE X_SOURCESYSTEM = 'SMARTPHONE RED CARD'
             AND PART_NUM2BUS_ORG IN (
             SELECT OBJID FROM TABLE_BUS_ORG WHERE ORG_ID='TRACFONE')
             AND part_number = in_part_num;

        sph_redcard_rec   sph_redcard_cur%ROWTYPE;
    BEGIN
        IF (in_part_num IS NOT NULL)
        THEN
            OPEN sph_redcard_cur;
            FETCH sph_redcard_cur INTO sph_redcard_rec;
            CLOSE sph_redcard_cur;
        END IF;

        RETURN (sph_redcard_rec.cnt != 0);
    END is_smartphone_red_card;
    --------------------------------------END CR38145------------------------------------------
    -- CR32539 New function to exclude 420 code when checking the pin pard compatibility for APP SL cards. --AR
    FUNCTION is_sl_red_card_compatible ( in_red_code IN VARCHAR2) RETURN boolean IS
     --
      CURSOR cur_sl_red_card_comp IS
         SELECT
           count (1) cnt
     FROM
     table_part_class pc,
     table_part_inst pi ,
     table_mod_level ml ,
     table_part_num pn,
     adfcrm_serv_plan_class_matview spcmv,
     mtm_program_safelink mtm
     WHERE
     pc.objid = pn.part_num2part_class
     AND ml.objid = pi.n_part_inst2part_mod
     AND pn.objid = ml.part_info2part_num
     AND pn.domain = 'REDEMPTION CARDS'
     AND spcmv.part_class_objid = pn.part_num2part_class
     AND mtm.is_sl_red_card_compatible = 'Y'
     AND pi.x_part_inst_status = '42'
     AND pi.x_red_code = in_red_code
     AND ROWNUM < 2;
      rec_sl_red_card_comp   cur_sl_red_card_comp%rowtype;
    BEGIN
      --
      IF  (in_red_code IS NOT NULL)
       THEN
                OPEN cur_sl_red_card_comp;
                fetch cur_sl_red_card_comp INTO rec_sl_red_card_comp;
                CLOSE cur_sl_red_card_comp;
            END IF;

            RETURN (rec_sl_red_card_comp.cnt != 0);

   END is_sl_red_card_compatible;
   -- New function to exclude 420 code when checking the pin pard compatibility for Connnected products dataclub cards
   --------------------------------------START CR43498----------------------------------------
    FUNCTION is_dataclub_card (in_red_code IN VARCHAR2)
        RETURN BOOLEAN
    IS
      CURSOR cur_cp_red_card_comp IS
         SELECT
           count (1) cnt
         FROM
         table_part_class pc,
         table_part_inst pi ,
         table_mod_level ml ,
         table_part_num pn,
	 adfcrm_serv_plan_class_matview spcm,
         service_plan_feat_pivot_mv spv
         WHERE
         pc.objid = pn.part_num2part_class
         AND ml.objid = pi.n_part_inst2part_mod
         AND pn.objid = ml.part_info2part_num
         AND pn.domain = 'REDEMPTION CARDS'
         AND spcm.part_class_objid = pn.part_num2part_class
         AND spcm.sp_objid= spv.service_plan_objid
         AND pi.x_part_inst_status = '42'
         AND pi.x_red_code = in_red_code
	 AND spv.supported_part_class like '%CONNECTED PRODUCTS%'
         AND ROWNUM < 2;

      rec_cp_red_card_comp   cur_cp_red_card_comp%rowtype;

    BEGIN
        IF (in_red_code IS NOT NULL)
        THEN
            OPEN cur_cp_red_card_comp;
            FETCH cur_cp_red_card_comp INTO rec_cp_red_card_comp;
            CLOSE cur_cp_red_card_comp;
        END IF;

        RETURN (rec_cp_red_card_comp.cnt != 0);
    END is_dataclub_card;
    --------------------------------------END  CR43498----------------------------------------

    --CR52417 Multidenom
    FUNCTION is_multidenom_shell_card  ( in_part_num IN VARCHAR2)
    RETURN boolean IS
       CURSOR multidenom_part_curs
        IS
            SELECT COUNT (1) cnt
              FROM table_part_num n
             WHERE part_number = in_part_num
             AND   s_description LIKE '%(BHN - BARCODE ONLY)' ;

        multidenom_part_rec   multidenom_part_curs%ROWTYPE;
    BEGIN
        IF (in_part_num IS NOT NULL)
        THEN
            OPEN multidenom_part_curs;
            FETCH multidenom_part_curs INTO multidenom_part_rec;
            CLOSE multidenom_part_curs;
        END IF;

        RETURN (multidenom_part_rec.cnt != 0);
    END is_multidenom_shell_card;

  -- BRAND_SEP_III
PROCEDURE main
  (
    strredcard            IN  VARCHAR2
   ,strsmpnumber    IN  VARCHAR2
   ,strsourcesys        IN  VARCHAR2
   ,stresn                   IN  VARCHAR2
   ,po_refcursor     OUT SYS_REFCURSOR
  /*
     ,strstatus          OUT VARCHAR2
  ,intunits           OUT INTEGER
     ,intdays           OUT INTEGER
   --intAmigo     OUT INTEGER,
  ,strcardbrand  OUT VARCHAR2
  ,strmsgnum    OUT VARCHAR2
  ,strmsgstr       OUT VARCHAR2
  ,strerrorpin     OUT VARCHAR2
  */ -- CR 28465 WEBCSR Migration - Net10 + TracFone (All the Out parameters are commented to return one single cursor)
  ) IS
    v_rc_pirc            rc_out;
    v_rc_rc              rc_out;
    v_rc_pirc2           rc_out;
    v_ref_out            rc_out;
    v_prtsn_rc           rc_out;
    v_pc_rc              rc_out;
    v_strstatus          VARCHAR2(10);
    v_strreserveesnid    VARCHAR2(20);
    v_strredpiobjid      VARCHAR2(20);
    v_strmsgnum          VARCHAR2(20);
    v_strmsgstr          VARCHAR2(40);
    v_strsql             VARCHAR2(40);
    v_strsmpnumber       VARCHAR2(20);
    v_strcardtype        VARCHAR2(20);
    v_strptsrno          VARCHAR2(20);
    v_strtemp            VARCHAR2(20);
    v_prtsn              VARCHAR2(40);
    v_status             VARCHAR2(10);
    v_pc                 VARCHAR2(40);
    v_name               VARCHAR2(40);
    v_objtemp            NUMBER;
    v_strredesn          VARCHAR2(40);
    v_stresn             VARCHAR2(40);
    v_strredcard         VARCHAR2(40);
    v_x_part_inst_status VARCHAR2(30);
    v_dllid              INTEGER;
    p_intreturn          INTEGER;
    v_getposa            INTEGER;
    objtemp              NUMBER;
    strred_card          VARCHAR2(40);
    strredesn            VARCHAR2(40);
    v_strexpires         DATE;
    v_strcurrent         DATE := SYSDATE;
    --v_intEsnResUse INTEGER := 0;
    v_stresnbrand        VARCHAR2(30);
    v_stresnflow         VARCHAR2(1) ;  -- CR20451 | CR20854: Add TELCEL Brand
    v_intunits           INTEGER := 0;
    v_intdays            INTEGER := 0;
    --v_intAmigo INTEGER := 0;
    v_strcardbrand     VARCHAR2(30);
    v_parttype         VARCHAR2(30); ---- added for LLcards
    v_esntemp          VARCHAR2(20);
    v_bln              BOOLEAN;
    v_esnll            VARCHAR2(30); ----added for LL
    v_offer            NUMBER := 0; -- CR8470
    v_card_class_objid NUMBER := 0; ----CR13085
    v_esn_class_objid  NUMBER := 0; ----CR13085
    v_partnumber       VARCHAR2(30);                                                         ---------------- CR23513 added for surepay
    v_promo_objid      VARCHAR2(30);                                                         ---------------- CR23513 added for surepay
	v_PARAM_NAME   	   VARCHAR2(30); --CR42611
    v_PARAM_VALUE 	   VARCHAR2(30); --CR42611


    -- CR 28465 WEBCSR Migration - Net10 + TracFone
    v_x_web_card_desc                table_part_num.x_web_card_desc%TYPE;
    v_x_sp_web_card_desc          table_part_num.x_sp_web_card_desc%TYPE;
    v_description                           table_part_num.description%TYPE;
    v_x_ild_type                            table_part_num.x_ild_type%TYPE;

    strstatus                                     VARCHAR2(1000);
    strmsgnum                                VARCHAR2(1000);
    strmsgstr                                   VARCHAR2(1000);
    strerrorpin                                 VARCHAR2(1000);
    intunits                                      table_part_num.x_redeem_units%TYPE;
    intdays                                      table_part_num.x_redeem_days%TYPE;
    strcardbrand                             table_part_num.x_card_type%TYPE;
    x_web_card_desc                    table_part_num.x_web_card_desc%TYPE;
    x_sp_web_card_desc              table_part_num.x_sp_web_card_desc%TYPE;
    description                                table_part_num.description%TYPE;
    x_ild_type                                table_part_num.x_ild_type%TYPE;
    partnumber                               table_part_num.part_number%TYPE;
    cardtype                                    table_part_num.x_card_type%TYPE;
    parttype                                    table_part_num.part_type%TYPE;

    op_err_num   VARCHAR2(1000);
    op_err_string VARCHAR2(1000);
    v_service_plan_group  sa.service_plan_feat_pivot_mv.service_plan_group%type; -- CR42459
    v_brm_service_days  INTEGER := 0;
 -- CR8470
  CURSOR x_offer_cur IS
  SELECT *
    FROM x_dblmn_offer;

     x_offer_rec x_offer_cur%ROWTYPE;

   --CR16379 Start kacostav_ 03/19/2012
        CURSOR x_offer_x3x_cur IS
           SELECT *
           FROM sa.x_x3xmn_offer;

    x_offer_x3x_rec x_offer_x3x_cur%ROWTYPE;
    -- CR16379 End kacosta 03/19/2012

    -- CR8663 WALMART SWITCH BASE PER (365) WALMART STRAIGHT_TALK
    /*      CURSOR STRAIGHT_TALK_ESN_cur (v_strEsn in VARCHAR2)
          IS
          select x_param_value
          from
             table_part_class pc, table_x_part_class_values pv, table_x_part_class_params pp
          where pv.value2part_class=pc.objid
          and pv.value2class_param=pp.objid
          and x_param_name='NON_PPE'
          and pv.x_param_value= '1'
          and pc.name  in
          (select pc.name
             from sa.table_part_num pn,
                  sa.table_mod_level ml,
                  sa.table_part_inst pi,
                  sa.table_part_class pc
          where pi.n_part_inst2part_mod=ml.objid
          and ml.part_info2part_num=pn.objid
          and pn.part_num2part_class=pc.objid
          and pi.part_serial_no = v_strEsn ) ;
          -- test esn '268435456313347575'

          STRAIGHT_TALK_ESN_rec STRAIGHT_TALK_ESN_cur%ROWTYPE;
          -- CR8663 WALMART SWITCH BASE END
    */
    CURSOR isllesn( --------CURSOR FOR LLESN
                   v_stresn IN VARCHAR2) IS
      SELECT pe.x_esn
        FROM x_program_enrolled pe
       WHERE pe.x_esn = v_stresn
         AND pe.x_enrollment_status = 'ENROLLED'
         AND pe.x_sourcesystem = 'VMBC';

    CURSOR c_rst_use(v_stresn IN VARCHAR2) IS
      SELECT bo.org_id, --x_restricted_use
             pn.part_num2part_class, ------CR13085
             pn.x_technology, -- CR17003 NET10 Sprint
             pn.x_dll, ---cr17413 NET10 GSM LGL95
             sa.get_param_by_name_fun(pc.name,'NON_PPE') non_ppe_flag,  -- CR17003 NET10 Sprint
             bo.org_flow,  -- CR20451 | CR20854: Add TELCEL Brand
             pi.x_part_inst_status -- CR24661  10 ILD Redemption flow for TELCEL AMERICA
        FROM sa.table_part_num   pn
            ,sa.table_mod_level  ml
            ,sa.table_part_inst  pi
            ,table_bus_org       bo
            ,sa.table_part_class pc
       WHERE pn.objid = ml.part_info2part_num
         AND ml.objid = pi.n_part_inst2part_mod
         AND pi.part_serial_no = v_stresn
         AND pn.part_num2bus_org = bo.objid
         AND pc.objid = pn.part_num2part_class;

    r_rst_use c_rst_use%ROWTYPE;

    CURSOR c_redcard2part(strredcard IN VARCHAR2) IS
      SELECT pn.x_redeem_units
            ,pn.x_redeem_days
            ,bo.org_id
            ,pn.part_number                                                                     ---------------------  CR23513 added for surepay
             --pn.x_restricted_use,
            ,pn.x_card_type
            ,pi.part_to_esn2part_inst
            ,pi.x_part_inst_status
            ,pn.part_type
            ,
             ---added forll
             pc.objid pc_objid -----CR13085
             -- CR16379 Start kacosta 03/19/2012
            ,txp.x_promo_code
            ,pn.part_num2x_promotion                                                           ---------------------  CR23513 added for surepay
      -- CR16379 End kacosta 03/19/2012
            ,pn.x_web_card_desc
            ,pn.x_sp_web_card_desc
            ,pn.description
            ,pn.x_ild_type
            ---- CR 28465 WEBCSR Migration - Net10 + TracFone
			,pn.objid part_num_objid	--CR37485
     FROM sa.table_part_num   pn
            ,sa.table_mod_level  ml
            ,sa.table_part_inst  pi
            ,sa.table_bus_org    bo
            ,sa.table_part_class pc ------CR13085
             -- CR16379 Start kacosta 03/19/2012
            ,sa.table_x_promotion txp
      -- CR16379 End kacosta 03/19/2012
       WHERE pn.objid = ml.part_info2part_num
         AND ml.objid = pi.n_part_inst2part_mod
         AND pi.x_red_code = strredcard
         AND pn.part_num2bus_org = bo.objid
            -- CR16379 Start kacosta 03/19/2012
         AND pn.part_num2x_promotion = txp.objid(+)
            -- CR16379 End kacosta 03/19/2012
         AND pn.part_num2part_class = pc.objid; ----CR13085

    CURSOR c_phonebyesn(v_stresn IN VARCHAR2) IS
      SELECT sa.table_part_num.x_dll
        FROM sa.table_part_inst
            ,sa.table_mod_level
            ,sa.table_part_num
       WHERE sa.table_part_inst.part_serial_no = stresn
         AND sa.table_mod_level.objid = sa.table_part_inst.n_part_inst2part_mod
         AND sa.table_part_num.objid = sa.table_mod_level.part_info2part_num
         AND sa.table_part_inst.x_domain = 'PHONES';

    CURSOR c_status(strredcard IN VARCHAR2) IS
      SELECT 'X'
        FROM sa.table_x_posa_card_inv
       WHERE x_red_code = strredcard;

    CURSOR c_part_serial_no_new(v_temp VARCHAR2) -- Defect_fix for 1351
    IS
      SELECT part_serial_no
        FROM sa.table_part_inst
       WHERE objid = v_objtemp;
    ---CR13085
    CURSOR c_valid_model_for_plan
    (
      card_class_objid  NUMBER
     ,phone_class_objid NUMBER
    ) IS
      SELECT a.value_name
        FROM x_serviceplanfeaturevalue_def a
            ,mtm_partclass_x_spf_value_def b
            ,x_serviceplanfeaturevalue_def c
            ,mtm_partclass_x_spf_value_def d
       WHERE a.objid = b.spfeaturevalue_def_id
         AND b.part_class_id = card_class_objid --part_class_objid
         AND c.objid = d.spfeaturevalue_def_id
         AND d.part_class_id = phone_class_objid --phone class objid
         AND a.value_name = c.value_name;

    r_valid_model_for_plan c_valid_model_for_plan%ROWTYPE;
    ---CR13085

    -- CR21443 VAS
      CURSOR isVAS( v_REDCARD_PC IN NUMBER) IS
      SELECT PC.NAME
        FROM table_part_class pc, vas_programs_view pv
       WHERE pc.name=pv.vas_card_class
         AND pc.objid = v_REDCARD_PC ;

      isVAS_r isVAS%ROWTYPE ;

	  --CR37485
  CURSOR is_sl_part_number(i_part_num_objid IN NUMBER) is
  SELECT DISTINCT program_provision_flag
  FROM mtm_program_safelink
  WHERE part_num_objid = i_part_num_objid
  ;

  is_sl_part_number_rec	is_sl_part_number%ROWTYPE;

	  cursor cu_enroll_sl (in_esn in x_program_enrolled.x_esn%type , i_part_num_objid IN NUMBER)
	 is
	 select distinct
	 pgm.objid prog_param_objid,
	 slsub.zip enroll_zip,
	 slsub.lid as lid,
	 slsub.state as enroll_state, --CR35974 Ashish e911 Indiana
	 pe.pgm_enroll2web_user web_user_id,
	 ps.reserve_card_limit,
	 ps.web_display,
	 ps.csr_display,
	 ps.ivr_display,
	 ps.program_provision_flag, -- CR31545 SAFELINK CA HOME PHONE AR
	 pn.part_number mtm_part_num --CR35974 Ashish e911 Indiana
	 ,ps.priority priority
	 from
	 x_program_enrolled pe,
	 x_program_parameters pgm,
	 x_sl_currentvals slcur,
	 x_sl_subs slsub,
	 sa.mtm_program_safelink ps,
	 table_part_num pn
	 where 1 = 1
	 and pgm.objid = pe.pgm_enroll2pgm_parameter
	 and slcur.x_current_esn = pe.x_esn
	 and slcur.lid = slsub.lid
	 and ps.program_param_objid = pgm.objid
	 and sysdate BETWEEN ps.start_date AND ps.end_date
	 and sysdate BETWEEN pgm.x_start_date AND pgm.x_end_date
	 and pgm.x_prog_class = 'LIFELINE'
	 and pe.x_sourcesystem in ('VMBC', 'WEB')
	 and pgm.x_is_recurring = 1
	 and pe.x_esn = in_esn
	 -- CR42459 Removed this check   and pe.x_enrollment_status = 'ENROLLED'
	 and ps.part_num_objid = pn.objid
	 and pn.objid	=	i_part_num_objid
	 UNION
	 select distinct
	 pgm.objid prog_param_objid,
	 slsub.zip enroll_zip,
	 slsub.lid as lid,
	 slsub.state as enroll_state, --CR35974 Ashish e911 Indiana
	 pe.pgm_enroll2web_user web_user_id,
	 ps.reserve_card_limit,
	 ps.web_display,
	 ps.csr_display,
	 ps.ivr_display,
	 ps.program_provision_flag, -- CR31545 SAFELINK CA HOME PHONE AR
	 pn.part_number mtm_part_num --CR35974 Ashish e911 Indiana
	 ,ps.priority priority
	 from
	 x_program_enrolled pe,
	 x_program_parameters pgm,
	 x_sl_currentvals slcur,
	 x_sl_subs slsub,
	 sa.mtm_program_safelink ps,
	 table_part_num pn
	 where 1 = 1
	 and pgm.objid = pe.pgm_enroll2pgm_parameter
	 and slcur.x_current_esn = pe.x_esn
	 and slcur.lid = slsub.lid
	 and ps.program_param_objid = pgm.objid
	 --and sysdate BETWEEN ps.start_date AND ps.end_date
	 --and sysdate BETWEEN pgm.x_start_date AND pgm.x_end_date
	 and pgm.x_prog_class = 'LIFELINE'
	 and pe.x_sourcesystem in ('VMBC', 'WEB')
	 and pgm.x_is_recurring = 1
	 and pe.x_esn = in_esn
	 -- CR42459 Removed this check   and pe.x_enrollment_status <> 'ENROLLED'
	 and pe.x_enrolled_date = (SELECT MAX(i_pe.x_enrolled_date) FROM x_program_enrolled i_pe,x_program_parameters i_pgm
								WHERE i_pe.X_ESN = pe.x_esn
								AND i_pgm.objid = i_pe.pgm_enroll2pgm_parameter
								AND i_pgm.x_prog_class = 'LIFELINE'
								AND i_pgm.x_is_recurring = 1
								)
	 and not exists (SELECT 1 FROM x_program_enrolled i_pe,x_program_parameters i_pgm
								WHERE i_pe.X_ESN = pe.x_esn
								AND i_pgm.objid = i_pe.pgm_enroll2pgm_parameter
								AND i_pgm.x_prog_class = 'LIFELINE'
								AND i_pgm.x_is_recurring = 1
								AND i_pe.x_enrollment_status = 'ENROLLED' )
	 and ps.allow_non_sl_customer	= 'Y'
	 and ps.part_num_objid = pn.objid
	 and pn.objid	=	i_part_num_objid
	 ORDER BY priority
	 ;
	 rec_enroll_sl cu_enroll_sl%rowtype;

  --CR37485


    -- CR16379 Start kacosta 03/19/2012
    v_offer_x3x       NUMBER := 0;
    v_card_promo_code table_x_promotion.x_promo_code%TYPE;
    -- CR16379 End kacosta 03/19/2012

	--	CR37485
  OP_ACTIONTYPE VARCHAR2(200);
  OP_ENROLL_ZIP VARCHAR2(200);
  OP_WEB_USER_ID NUMBER;
  OP_LID NUMBER;
  OP_ESN VARCHAR2(200);
  OP_CONTACT_OBJID NUMBER;
  OP_SL_REFCURSOR sys_refcursor;
  OP_SL_ERR_NUM NUMBER;
  OP_SL_ERR_STRING VARCHAR2(200);
  lv_refcur_rec SL_REFCUR_REC;
  --lv_refcur_rec		sl_refcur_rectype;
  sl_valid_pin_flag		VARCHAR2(2)	:= 'N';
  v_part_num_objid		table_part_num.objid%type;
  --	CR37485
  v_flag                VARCHAR2(25);  -- CR47024
  v_paygo_flag          VARCHAR2(25);  -- CR47024
  v_splan_group_esn     x_serviceplanfeaturevalue_def.value_name%type;

BEGIN

  open OP_SL_REFCURSOR for select null part_number,
	null pn_desc,
	null x_retail_price,
	null sp_objid,
	null mkt_name,
	null sp_desc,
	null customer_price,
	null ivr_plan_id,
	null webcsr_display_name,
	null x_sp2program_param,
	null x_program_name,
	null cycle_start_date,
	null cycle_end_date,
	null quantity,
	null coverage_script,
	null short_script,
	null trans_script,
	null script_type,
	null as sl_program_flag,
	null as enroll_state_full_name  --CR35974 Ashish e911 Indiana
	from dual;

    /* CR37012 -- unnecessary data into error_table
	--no PIN given

                               op_err_string := 'strredcard: '||strredcard ||' strsmpnumber: '||strsmpnumber ||
                               ' strsourcesys: '||strsourcesys ||' stresn: '||stresn;

   ota_util_pkg.err_log(p_action => 'validate_red_card_pkg', p_error_date => SYSDATE, p_key => ('testing--step 1'), p_program_name =>
    'validate_red_card_pkg.main', p_error_text => op_err_string);
    --ar change for testing start  end
     */
    IF (LENGTH(TRIM(strredcard)) = 0) THEN
      strerrorpin := 'Error: Pin' || strredcard || 'not valid. Please verify and retry';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '401';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'Card Not Found';
      GOTO package_end;
    END IF;

    --a POS card?
    --IF (strSourceSys != NULL --CR6962
    IF strsourcesys IS NOT NULL
       AND strsourcesys = 'IVR' THEN
      getpartclass(strredcard
                  ,v_pc_rc);

      FETCH v_pc_rc
        INTO v_pc;

      v_name := v_pc;
    END IF;

    OPEN c_status(strredcard);

    FETCH c_status
      INTO v_status;

    IF (v_status IS NOT NULL) THEN
      getposacardinvredcard(strredcard
                           ,p_intreturn);

      IF (P_INTRETURN > 0) THEN
        IF strsourcesys in ('TAS', 'WEBCSR') THEN  --CR22451
          strmsgnum := '404';
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                      ,strmsgnum
                                      ,'ENGLISH');
          --strMsgStr := 'POSA card is not Active.';
          GOTO package_end;
        ELSE
          strerrorpin := 'Error: Pin not activated. Please retry in 30 minutes';
          dbms_output.put_line(strerrorpin);
          strmsgnum := '410';
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                      ,strmsgnum
                                      ,'ENGLISH');
          --strMsgStr := 'POSA Card not valid for redemption.';
          GOTO package_end;
        END IF;
      END IF;
    END IF;

    -- IF get the card from inventory
    getpartinstredcard(strredcard
                      ,strsmpnumber
                      ,v_rc_pirc);

    FETCH v_rc_pirc
      INTO v_strredpiobjid
          ,v_strsmpnumber
          ,v_strredcard
          ,v_strstatus
          ,v_objtemp;

    IF v_rc_pirc%FOUND THEN
      strred_card := v_strredcard;
      strstatus   := v_strstatus;
      objtemp     := v_objtemp;

      OPEN c_part_serial_no_new(v_objtemp); -- Defect_fix for 1351

      FETCH c_part_serial_no_new
        INTO v_esntemp;

      IF c_part_serial_no_new%FOUND THEN
        --IF (objTemp != NULL) --CR6962
        IF (objtemp IS NOT NULL) THEN
          strredpiobjid   := v_strredpiobjid;
          strreserveesnid := v_esntemp;
        END IF;
      END IF;

    ELSE
      --ELSE not in inventory
      --check if has been redeemed
      getredcard(strredcard
                ,strsmpnumber
                ,v_rc_rc);

      FETCH v_rc_rc
        INTO v_strtemp
            ,v_intunits;

      IF V_RC_RC%FOUND THEN
        IF (strsourcesys in ('TAS', 'WEBCSR' , 'HANDSET')) THEN   --CR22451
          strerrorpin := 'Error: Pin ' || strredcard || ' already used';
          dbms_output.put_line(strerrorpin);
          strmsgnum := '402';
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                      ,strmsgnum
                                      ,'ENGLISH');
          --strMsgStr := 'This Card has already been redeemed.';
          GOTO package_end;
        END IF;

        strtemp := v_strtemp;

        --IF (strTemp != NULL--CR6962
        IF (strtemp IS NOT NULL AND LENGTH(strtemp) > 0) THEN
          getredcard2calltrans(strtemp
                              ,v_ref_out);

          FETCH v_ref_out
            INTO v_strredesn;

          IF v_ref_out%FOUND THEN
            strredesn := v_strredesn;
          END IF;
        END IF;

        IF (LENGTH(strredesn) = 0) THEN
          strerrorpin := 'Error: Pin ' || strredcard || ' is reserved for an Invalid ESN';
          dbms_output.put_line(strerrorpin);
          strmsgnum := '405';
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                      ,strmsgnum
                                      ,'ENGLISH');
          --strMsgStr := 'Card is reserved for an Invalid ESN.';
          GOTO package_end;
          --ELSIF ( NOT (strRedEsn = (strESN)))
        ELSIF (NOT (strredesn = (stresn)) OR (strredesn = stresn))
        --CR7236
         THEN
          strerrorpin := 'Error: Pin ' || strredcard || ' already used on another phone';
          dbms_output.put_line(strerrorpin);
          strmsgnum := '402';
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                      ,strmsgnum
                                      ,'ENGLISH');
          --strMsgStr := 'This Card has already been redeemed.';
          GOTO package_end;
        ELSE
          -- InLastTransaction(strRedCard,strEsn, v_bln);
          inlasttransaction(stresn
                           ,strredcard
                           ,v_bln); --CR7236

          IF NOT (v_bln) THEN
            strerrorpin := 'Error: Pin ' || strredcard || 'not valid. Please verify and retry';
            strmsgnum   := '403';
            strmsgstr   := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                          ,strmsgnum
                                          ,'ENGLISH');
            dbms_output.put_line(strredcard);
            dbms_output.put_line(stresn);
            --strMsgStr := 'Card not valid for redemption.Already redemed';
            strstatus := '41'; -- has been redeemed
            intunits  := v_intunits;
            GOTO package_end;
          END IF;
        END IF;
      ELSE
        --not inventory, not redeemed, just a bad pin
        strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
        dbms_output.put_line(strerrorpin);
        strmsgnum := '413';
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'Invalid PIN.';
        GOTO package_end;
      END IF;
    END IF;

    --thru here if in inventory
    --convert reserved objid to reserved ESN (ugh!)
    IF (LENGTH(strreserveesnid)) > 0 THEN
      FOR rec1 IN (SELECT part_serial_no
                     FROM sa.table_part_inst
                   --WHERE objid = strreserveesnid)  CR19461
                    WHERE part_serial_no = strreserveesnid) LOOP
        strreserveesnid := rec1.part_serial_no;
        dbms_output.put_line(rec1.part_serial_no);
      END LOOP;
    END IF;

    --IF reserved
    --IF (TRIM (strstatus) = '40')
    IF (TRIM(strstatus) IN ('40'
                           ,'400')) -- CR12989 ST Retention PM.
     THEN
      -- bad ESN
      IF (LENGTH(strreserveesnid) = 0) THEN
        strerrorpin := 'Error: Pin ' || strredcard || ' is reserved for an Invalid ESN';
        dbms_output.put_line(strerrorpin);
        --strMsgNum := '405';
        strmsgnum := '431'; -- Changed to 431 from 405 CR7259 SK
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'Card is reserved for an invalid ESN.';
        GOTO package_end;
        -- not my ESN
      ELSIF (NOT (strreserveesnid = stresn)) THEN
        strerrorpin := 'Error: Pin ' || strredcard || ' already used on another phone';
        dbms_output.put_line(strerrorpin);
        --strMsgNum := '402';
        strmsgnum := '430'; -- Changed to 430 from 402 CR7259 SK
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'Card is reserved for a different phone.';
        GOTO package_end;
      END IF;
    ELSIF (TRIM(strstatus) = '263') THEN
      -- bad ESN
      IF (LENGTH(strreserveesnid) = 0) THEN
        strerrorpin := 'Error: Pin ' || strredcard || ' is reserved for an Invalid ESN';
        dbms_output.put_line(strerrorpin);
        strmsgnum := '414';
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'Card invalid.';
        GOTO package_end;
        -- not my ESN
      ELSIF (NOT (strreserveesnid = stresn)) THEN
        strerrorpin := 'Error: Pin ' || strredcard || ' already used on another phone';
        dbms_output.put_line(strerrorpin);
        strmsgnum := '427';
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'reserved for a different phone';
        GOTO package_end;
      ELSE
        IF (strreserveesnid = stresn) THEN
          strerrorpin := 'Error: Pin ' || strredcard || ' already reserved for another phone';
          dbms_output.put_line(strerrorpin);
          strmsgnum := '428';
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                      ,strmsgnum
                                      ,'ENGLISH');
          --strMsgStr := 'Card pending redemption';
          GOTO package_end;
        END IF;
      END IF;
      -- else not reserved
    ELSIF ((TRIM(strstatus) = '43'))
    --OR (TRIM(strStatus) = '263'))
     THEN
      --CR3972 // if pending (regular or OTA)
      --bad ESN or not me
      IF ((LENGTH(strreserveesnid) = 0) OR (NOT (NVL(strreserveesnid
                                                    ,'0') = stresn))) THEN
        strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
        dbms_output.put_line(strerrorpin);
        strmsgnum := '403';
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'Card not valid for Redemption.';
        GOTO package_end;
      ELSE
        -- it's mine pending
        strstatus := '40'; --make reserved

        UPDATE table_part_inst
           SET x_part_inst_status  = '40'
              ,status2x_code_table =
               (SELECT objid
                  FROM sa.table_x_code_table
                 WHERE x_code_number = '40')
         WHERE objid = strredpiobjid;
      END IF;
      -- else if redeemed
    ELSIF (TRIM(strstatus) = '41') THEN
      --reserved for bad or wrong phone
      IF (LENGTH(strreserveesnid) = 0) THEN
        strerrorpin := 'Error: Pin ' || strredcard || ' already reserved for another phone';
        dbms_output.put_line(strerrorpin);
        strmsgnum := '405';
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'Card is reserved for an invalid ESN.';
        GOTO package_end;
      ELSE
        IF (NOT (strreserveesnid) = (stresn)) THEN
          strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
          dbms_output.put_line(strerrorpin);
          strmsgnum := '403';
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                      ,strmsgnum
                                      ,'ENGLISH');
          --strMsgStr := 'Card not valid for redemption.';
          GOTO package_end;
        ELSE
          --InLastTransaction(strRedCard, strEsn, v_bln);
          inlasttransaction(stresn
                           ,strredcard
                           ,v_bln); --CR7236

          IF NOT (v_bln) THEN
            strerrorpin := 'Error: Pin ' || strredcard || ' already reserved for another phone';
            dbms_output.put_line(strerrorpin);
            strmsgnum := '402';
            strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                        ,strmsgnum
                                        ,'ENGLISH');
            --strMsgStr := 'Card is reserved for a different phone.';
            GOTO package_end;
          END IF;
        END IF;
      END IF;
    ELSIF (TRIM(strstatus) = '44') THEN
      --OR (TRIM(strStatus) = '45')) - Changed to 432 for status 45 from 403
      strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '403';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'Card not valid for Redemption';
      GOTO package_end;
    ELSIF --((TRIM(strStatus) = '44')
     (TRIM(strstatus) = '45') THEN
      strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '432'; -- Changed to 432 for status 45 from 403
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'Card not valid for Redemption';
      GOTO package_end;
    ELSIF (TRIM(strstatus) = '75') THEN
      strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '407';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'Card is obselete, return it to retailer.';
      GOTO package_end;
    -- CR25668
    ELSIF (TRIM(strstatus) = '47') THEN
      strerrorpin := 'Error: Pin ' || strredcard || ' not valid. Please verify and retry';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '403';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      GOTO package_end;
    END IF;

    --get this card
    --getPartInstRedCard2Part(strRedCard, v_rc_pirc2);

    OPEN c_redcard2part(strredcard);

    --CR8013
    --       FETCH c_RedCard2Part
    --       INTO v_intUnits, v_intDays, v_intAmigo, v_objTemp,
    --       v_x_part_inst_status,v_parttype;     -----ADDED FOR LIFE LINE
    FETCH c_redcard2part
      INTO v_intunits
          ,v_intdays
          ,v_strcardbrand
          ,v_partnumber
             --v_intAmigo,
          ,v_strcardtype
          ,v_objtemp
          ,v_x_part_inst_status
          ,v_parttype
           -- CR16379 Start kacosta 03/19/2012
           --,v_card_class_objid; ---CR13085
          ,v_card_class_objid
          ,v_card_promo_code
          ,v_promo_objid
    -- CR16379 End kacosta 03/19/2012
    -----ADDED FOR LIFE LINE
    --CR8013
          ,v_x_web_card_desc
          ,v_x_sp_web_card_desc
          ,v_description
          ,v_x_ild_type
          --CR 28465  WEBCSR Migration - Net10 + TracFone
		  ,v_part_num_objid
		  ;

    --CR47564 WFM starts here - If WFM get the service days from x_part_inst_ext
    IF sa.customer_info.get_brm_notification_flag ( i_esn => stresn) = 'Y' THEN
	  v_brm_service_days := sa.customer_info.get_esn_pin_redeem_days (i_esn => stresn , i_pin => strredcard);
	  v_intdays := CASE v_brm_service_days WHEN 0 THEN v_intdays ELSE v_brm_service_days END;
    END IF;
    --CR47564 WFM ends here

    IF c_redcard2part%FOUND THEN
      --IF ((v_x_part_inst_status = '40') AND (strreserveesnid != stresn))

      --CR 28465 WEBCSR Migration - Net10 + TracFone

        x_web_card_desc          := v_x_web_card_desc;
        x_sp_web_card_desc    := v_x_sp_web_card_desc;
        description                      := v_description;
        x_ild_type                       := v_x_ild_type;
        partnumber                      := v_partnumber;
        cardtype                           := v_strcardtype;
        parttype                            := v_parttype;

      IF ((v_x_part_inst_status IN ('40'
                                   ,'400')) AND (strreserveesnid != stresn)) --CR12989 ST Retention PM
       THEN
        -- Defect_fix for 1351
        strerrorpin := 'Error: Pin ' || strredcard || ' already used on another phone';
        dbms_output.put_line(strerrorpin);
        --strMsgNum := '402';
        strmsgnum := '430'; -- Changed to 430 from 402 Per CR7259 SK
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
        --strMsgStr := 'Card is reserved for a different phone.';
      ELSE
        intunits := v_intunits;
        intdays  := v_intdays;
        --intAmigo := v_intAmigo;
        strcardbrand := v_strcardbrand;
        objtemp      := v_objtemp;


        -- CMC_SPLIT START
        v_offer := esn_is_enrolled_in_dblmin_fun(stresn);
        -- CR16379 Start kacosta 03/19/2012
        --IF v_offer > 0 THEN
        --  --open x_offer_cur ;
        --  --fetch x_offer_cur into x_offer_rec ;
        --  FOR x_offer_rec IN x_offer_cur LOOP
        --    IF intunits = x_offer_rec.at_units
        --       AND intdays = x_offer_rec.at_days THEN
        --      intunits  := x_offer_rec.offered_units;
        --      intdays   := x_offer_rec.offered_days;
        --      strmsgnum := '425'; -- CMC_SPLIT
        --      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
        --                                  ,strmsgnum
        --                                  ,'ENGLISH');
        --    END IF;
        --  END LOOP;
        --END IF;
        v_offer_x3x := esn_is_enrolled_in_x3xmin_fun(stresn);
        IF (v_offer > 0 OR v_offer_x3x > 0)
           AND v_card_promo_code = 'RTDBL000' THEN
          FOR x_offer_rec IN x_offer_cur LOOP
            IF intunits = x_offer_rec.at_units
               AND intdays = x_offer_rec.at_days THEN
              intunits := x_offer_rec.offered_units;
              intdays  := x_offer_rec.offered_days;
            END IF;
          END LOOP;
          strmsgnum := '425'; -- CMC_SPLIT
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                      ,strmsgnum
                                      ,'ENGLISH');
        ELSIF v_offer_x3x > 0
              AND v_card_promo_code = 'RTX3X000' THEN
          --
          FOR x_offer_x3x_rec IN x_offer_x3x_cur LOOP
            --
            IF intunits = x_offer_x3x_rec.at_units
               AND intdays = x_offer_x3x_rec.at_days THEN
              --
              intunits := x_offer_x3x_rec.offered_units;
              intdays  := x_offer_x3x_rec.offered_days;
              --
            END IF;
            --
          END LOOP;
          strmsgnum := '425';
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                      ,strmsgnum
                                      ,'ENGLISH');
        END IF;
        -- CR16379 End kacosta 03/19/2012
      END IF;

      -- END IF;
      --IF(objTemp != NULL) --CR6962
      IF (objtemp IS NOT NULL) THEN
        --   strCardType := objTemp;
        strcardtype := v_strcardtype; --CR8013
      END IF;

	  dbms_output.put_line('Rahul inside c_redcard2part%FOUND');

	  --CR42611 Vishnu start
	 IF v_strcardbrand = 'STRAIGHT_TALK' THEN
			BEGIN
				SELECT PARAM_NAME, PARAM_VALUE
				  INTO v_PARAM_NAME, v_PARAM_VALUE
				  FROM PC_PARAMS_VIEW
				 where PC_OBJID=v_card_class_objid;
				EXCEPTION
				WHEN OTHERS THEN NULL;
			END ;
                               --
                               -- Tim 6/24/2016 CR43582 Added BATCH to strsourcesys check.
                               -- Tim 7/1/2016  CR43582 We are removing this check entirely.
                               --
                               /*
			       IF strsourcesys NOT IN ('TAS','BATCH') AND v_PARAM_NAME = 'CHANNEL_ALLOWED_ONLY' AND v_PARAM_VALUE='TAS'
				 THEN
					 strerrorpin := 'Error: Pin ' || strredcard || 'not valid for redemption';
					 strmsgnum   := '1653';
                     strmsgstr   := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                          ,strmsgnum
                                          ,'ENGLISH');
					 dbms_output.put_line(strredcard);
					 dbms_output.put_line(stresn);
					--strMsgStr := 'Card not valid for redemption.Already redemed';
					strstatus := '41'; -- has been redeemed
					intunits  := v_intunits;
					GOTO package_end;--call error
				 END IF;
				*/  --  Tim 7/1/2016  CR43582

	 END IF;

	  ---CR37485
	  IF v_strcardbrand = 'TRACFONE'
	  THEN

		dbms_output.put_line('Rahul before is_sl_part_number cursor '||v_part_num_objid);
		OPEN is_sl_part_number(v_part_num_objid);
		FETCH is_sl_part_number INTO is_sl_part_number_rec;

		IF is_sl_part_number%FOUND THEN
		dbms_output.put_line('Rahul in is_sl_part_number cursor found');

			OPEN cu_enroll_sl(stresn,v_part_num_objid);
			FETCH cu_enroll_sl	INTO rec_enroll_sl;


			IF cu_enroll_sl%NOTFOUND
			THEN




				strmsgnum := '1647';
				strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
				,strmsgnum
				,'ENGLISH');
				GOTO package_end;


			END IF;


		END IF;
		CLOSE is_sl_part_number;

		END IF;
	  --CR37485

    ELSE
      strmsgnum := '406';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      -- strMsgStr := 'No Part/mod Level record found';
      GOTO package_end;
    END IF;

    CLOSE c_redcard2part;

    -- Start CR17003 NET10 Sprint
    --what about restricted use
    OPEN c_rst_use(stresn);

    FETCH c_rst_use
      INTO r_rst_use;
    --INTO v_stresnbrand, v_esn_class_objid;  -----CR13085

    --INTO v_intEsnResUse;
    IF c_rst_use%FOUND THEN
      --intEsnResUse := v_intEsnResUse;
      stresnbrand := r_rst_use.org_id;
      -- End CR17003 NET10 Sprint
      stresnFLOW := r_rst_use.org_flow; -- CR20451 | CR20854: Add TELCEL Brand
    ELSE
      strmsgnum := '411';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'ESN not valid.';
      GOTO package_end;
    END IF;

    CLOSE c_rst_use;

    -- CR24661 moveD HERE
    --BRAND SEPARATION
    IF strcardbrand <> stresnbrand THEN
      strmsgnum := '436';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      GOTO package_end;
    END IF;
    --CR13085
    --ST Card not compatible with Phone Model / Nokia Models cannot use All You Need Cards
    -- CR20451 | CR20854: Add TELCEL Brand
    -- IF stresnbrand = 'STRAIGHT_TALK' THEN
    -- CR21443
    -- CR13085
    -- CR24661

    -- CR23513 2 different error codes one for all except IVR the other for IVR only
    IF sa.device_util_pkg.get_smartphone_fun(stresn)= 0
	 AND sa.get_safelinkassist_flag(stresn) = 'N'   --CR49808 - SafelinkAssist
     AND nvl(v_promo_objid , 0 ) > 0  -- CR27269 AND v_promo_objid IS NOT NULL
      AND strsourcesys <> 'IVR'
      THEN
          strmsgnum := '422';
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,strmsgnum ,'ENGLISH');
    END IF;

    IF sa.device_util_pkg.get_smartphone_fun(stresn)= 0
    AND nvl(v_promo_objid , 0 ) > 0  -- CR27269 AND v_promo_objid IS NOT NULL
      AND strsourcesys = 'IVR'
    THEN
          strmsgnum := '420';
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,strmsgnum ,'ENGLISH');
    END IF;
    -- CR23513 2 different error codes one for all except IVR the other for IVR only

 /* -- op_err_num    := SQLCODE;   --CR37012 -- unnecessary data into error_table
  --ar change for testing start
    op_err_string := 'v_strstatus: '||v_strstatus ||' strmsgnum: '||strmsgnum||' strmsgstr: '||strmsgstr
    ||' get_smartphone_fun(stresn):' ||device_util_pkg.get_smartphone_fun(stresn)
    ||' IS_HOTSPOTS(STRESN): '||DEVICE_UTIL_PKG.IS_HOTSPOTS(STRESN)
    ||' IS_TABLET(STRESN): '||DEVICE_UTIL_PKG.IS_TABLET(STRESN)
    ||' brand x flag: '||NVL(brand_x_pkg.get_shared_group_flag ( ip_bus_org_id => r_rst_use.org_id),'N');

   ota_util_pkg.err_log(p_action => 'validate_red_card_pkg', p_error_date => SYSDATE, p_key => ('testing--step 5'), p_program_name =>
    'validate_red_card_pkg.main', p_error_text => op_err_string);
   --ar change for testing end
   */
    IF (v_strstatus = '42' AND  is_data_card (v_partnumber)) THEN
     IF sa.device_util_pkg.get_smartphone_fun(stresn)<> 0
           and sa.DEVICE_UTIL_PKG.IS_HOTSPOTS(STRESN)<> 0  ---CR25435
           and sa.DEVICE_UTIL_PKG.IS_TABLET(STRESN)<> 0  ---CR27538
           -- Added by Juda Pena for Brand X project to bypass this error for account group brands
           and NVL(sa.brand_x_pkg.get_shared_group_flag ( ip_bus_org_id => r_rst_use.org_id),'N') = 'N'
           -- CR32539 To exclude SL data cards AR
           and NOT IS_SL_RED_CARD_COMPATIBLE(strredcard)
	   and NOT is_dataclub_card(strredcard) -- CR43498 added to allow dataclub datacards to pass through
           THEN


          strmsgnum := '420';
          strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,strmsgnum ,'ENGLISH');
		  /* CR37012 -- unnecessary data into error_table
          --ar change for testing start
                      op_err_string := 'strredcard: '||strredcard ||' strsmpnumber: '||strsmpnumber ||
                               ' strsourcesys: '||strsourcesys ||' stresn: '||stresn||' strmsgnum: '||strmsgnum||' strmsgstr: '||strmsgstr;

   ota_util_pkg.err_log(p_action => 'validate_red_card_pkg', p_error_date => SYSDATE, p_key => ('testing--step 6'), p_program_name =>
    'validate_red_card_pkg.main', p_error_text => op_err_string);
    --ar change for testing end
	*/
     END IF;
    END IF;

    OPEN isVAS (v_card_class_objid) ;

    FETCH isVAS INTO isVAS_R ;
    -- this is an issue that needs to only be returned for TELCEL until a permanent fix is found
    --  /*
    -- PUT IT BACK FOR CR24661 -- remove this failing for CR25456 BEGIN
    IF isVAS%FOUND and r_rst_use.X_PART_INST_STATUS != '52' and stresnbrand IN ('TELCEL','SIMPLE_MOBILE')
    then
      CLOSE isVAS;
      strmsgnum := '420';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,strmsgnum ,'ENGLISH');
	  /* CR37012 -- unnecessary data into error_table
      --ar change for testing start
                           op_err_string := 'v_strstatus: '||v_strstatus ||' strmsgnum: '||strmsgnum||' strmsgstr: '||strmsgstr;

   ota_util_pkg.err_log(p_action => 'validate_red_card_pkg', p_error_date => SYSDATE, p_key => ('testing--step 7'), p_program_name =>
    'validate_red_card_pkg.main', p_error_text => op_err_string);
    --ar change for testing start  end
	*/
      GOTO package_end;
    END IF;
    -- PUT IT BACK FOR CR24661 -- remove this failing for CR25456 END
    --*/
    -- this is an issue that needs to only be returned for TELCEL until a permanent fix is found
    -- /*
    -- PUT IT BACK FOR CR24661 -- remove this failing for CR25456 BEGIN
    IF isVas%FOUND and r_rst_use.X_PART_INST_STATUS = '52' and stresnbrand IN ('TELCEL','SIMPLE_MOBILE')
    then
      CLOSE isVAS;
      strmsgnum := '421';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,strmsgnum ,'ENGLISH');
      GOTO package_end;
    END IF;
    -- PUT IT BACK FOR CR24661-- remove this failing for CR25456 END
    -- */
    -- CR24661 production defect
    -- I am going to try to use the non_ppe flag here because we have tracfone androids now
    -- IF stresnflow in ('3','2')  and isVAS%NOTFOUND
    if isVAS%notfound and strsourcesys <> 'IVR' and stresnflow in ('3','2')
    THEN
          OPEN c_valid_model_for_plan(r_rst_use.part_num2part_class,v_card_class_objid);
          FETCH c_valid_model_for_plan
           INTO r_valid_model_for_plan;
             IF c_valid_model_for_plan%NOTFOUND THEN
               CLOSE c_valid_model_for_plan;
               strmsgnum := '420';
               strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,strmsgnum ,'ENGLISH');
               --strMsgStr := 'Invalid PIN.';
               GOTO package_end;
            END IF;
            CLOSE c_valid_model_for_plan;
               -- Start CR17003 NET10 Sprint
               -- Only for IVR we need to check Plan Compatibility for WEB and WEBCSR we have that validation in Java.
               -- Because For TF/NT in WEB and WEBCSR customer can pass more than 1 redemption cards at a time not for IVR.
               -- changed logic to substitute dll for technology to include new GSM phone LGL95
               -- CR20451 | CR20854: Add TELCEL Brand
               -- ELSIF stresnbrand <> 'STRAIGHT_TALK'

        -- CR24661 this is old, need to remove the stresnflow
        -- ELSIF stresnflow <> '3' AND strsourcesys = 'IVR'
          ELSIF strsourcesys = 'IVR' and isVAS%notfound and stresnflow in ('2','3')
          --  AND r_rst_use.x_dll <= 0 --CR17413 NTLGL95 r_rst_use.x_technology = 'CDMA'
          --AND r_rst_use.non_ppe_flag = '1'
          THEN
               OPEN c_valid_model_for_plan(r_rst_use.part_num2part_class
                                 ,v_card_class_objid);
               FETCH c_valid_model_for_plan
                INTO r_valid_model_for_plan;
               IF c_valid_model_for_plan%NOTFOUND THEN
                     CLOSE c_valid_model_for_plan;
                     strmsgnum := '403';
                     strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',strmsgnum,'ENGLISH');
                     --strMsgStr := 'Invalid PIN.';
                     GOTO package_end;
              END IF;
      CLOSE c_valid_model_for_plan;
      -- End CR17003 NET10 Sprint
        ---------for tracfone datacard beging used on TF PPE devices CR34567
   ELSIF isVAS%notfound  and stresnflow in ('1')and  is_data_card (v_partnumber)
          --  AND r_rst_use.x_dll <= 0 --CR17413 NTLGL95 r_rst_use.x_technology = 'CDMA'
          AND r_rst_use.non_ppe_flag = '0'
          THEN
               OPEN c_valid_model_for_plan(r_rst_use.part_num2part_class
                                 ,v_card_class_objid);
               FETCH c_valid_model_for_plan
                INTO r_valid_model_for_plan;
               IF c_valid_model_for_plan%NOTFOUND THEN
                     CLOSE c_valid_model_for_plan;
                                        strmsgnum := '403';
                     strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',strmsgnum,'ENGLISH');
                     --strMsgStr := 'Invalid PIN.';
                     GOTO package_end;
              END IF;
      CLOSE c_valid_model_for_plan;
      ------------------------for CR35141

      ELSIF isVAS%notfound  and stresnflow in ('1')and  is_TEXT_card (v_partnumber)
          --  AND r_rst_use.x_dll <= 0 --CR17413 NTLGL95 r_rst_use.x_technology = 'CDMA'
          AND r_rst_use.non_ppe_flag = '0'
          THEN
               OPEN c_valid_model_for_plan(r_rst_use.part_num2part_class
                                 ,v_card_class_objid);
               FETCH c_valid_model_for_plan
                INTO r_valid_model_for_plan;
               IF c_valid_model_for_plan%NOTFOUND THEN
                     CLOSE c_valid_model_for_plan;
                                        strmsgnum := '403';
                     strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',strmsgnum,'ENGLISH');
                     --strMsgStr := 'Invalid PIN.';
                     GOTO package_end;
              END IF;
      CLOSE c_valid_model_for_plan;
      ------------------------for CR38145
	   ELSIF isVAS%notfound  and stresnflow in ('1') AND is_smartphone_red_card (v_partnumber) AND
	        r_rst_use.non_ppe_flag = '0'
            THEN
                     strmsgnum := '403';
                     strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',strmsgnum,'ENGLISH');
                     --strMsgStr := 'Invalid PIN.';
                     GOTO package_end;
    -- End ST Card not compatible with Phone Model
    -- CR52417 Multidenom
    -- Adding check to return error in case its a multidenom card for TF
    -- For rest, it will already fail with status 420
	   ELSIF isVAS%notfound  and stresnflow in ('1') AND is_multidenom_shell_card (v_partnumber)
            THEN
                     strmsgnum := '403';
                     strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',strmsgnum,'ENGLISH');
                     --strMsgStr := 'Invalid PIN.';
                     GOTO package_end;
        END IF;
    -- End ST Card not compatible with Phone Model

    CLOSE isVAS;

    -- CR24661 moving this
    -- BRAND SEPARATION
    -- IF strcardbrand <> stresnbrand THEN
    --    strmsgnum := '436';
    --    strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',strmsgnum,'ENGLISH');
    --    GOTO package_end;
    -- END IF;

    --dont allow it if it's restricted for various reasons (wrong product, etc.)

    /*      IF ( NOT (intEsnResUse = 1)
          AND (intAmigo = 1))
          THEN
             strErrorPin := 'Error: Amigo Pin entered on TracFone';
             DBMS_OUTPUT.put_line(strErrorPin);
             strMsgNum := '409';
             strMsgStr := sa.Get_Code_Fun('VALIDATE_RED_CARD_PKG',strMsgNum,'ENGLISH') ;
             --strMsgStr := 'TracFone ESN not compatible with Amigo redemption card.';
             GOTO package_end;
          ELSIF ((intEsnResUse = 1)
          AND (intAmigo = 2))
          THEN
             strErrorPin := 'Error: non-Amigo Pin entered on Amigo';
             DBMS_OUTPUT.put_line(strErrorPin);
             strMsgNum := '408';
             strMsgStr := sa.Get_Code_Fun('VALIDATE_RED_CARD_PKG',strMsgNum,'ENGLISH') ;
             --strMsgStr :=
             --'Amigo ESN not compatible with non-Amigo redemption card.';
             GOTO package_end;
          ELSIF ((intEsnResUse = 1)
          AND (intAmigo = 3))
          THEN
             strErrorPin := 'Error: Net10 Pin entered on TracFone.';
             DBMS_OUTPUT.put_line(strErrorPin);
             strMsgNum := '416';
             strMsgStr := sa.Get_Code_Fun('VALIDATE_RED_CARD_PKG',strMsgNum,'ENGLISH') ;
             --strMsgStr := 'TracFone ESN not compatible with NET10 redemption card.';
             GOTO package_end;
          ELSIF ((intEsnResUse = 3)
          AND (intAmigo != 3))
          THEN
             strErrorPin := 'Error: TracFone Pin entered on NET10 Phone.';
             DBMS_OUTPUT.put_line(strErrorPin);
             strMsgNum := '415';
             strMsgStr := sa.Get_Code_Fun('VALIDATE_RED_CARD_PKG',strMsgNum,'ENGLISH') ;
             --strMsgStr :=
            -- 'NET10 ESN should only be used with NET10 Redemption card.';
             GOTO package_end;
          ELSIF ((intEsnResUse != 3)
          AND (intAmigo = 3))
          THEN
             strErrorPin := 'Error: NET10 Pin entered on TracFone.';
             DBMS_OUTPUT.put_line(strErrorPin);
             strMsgNum := '415';
             strMsgStr := sa.Get_Code_Fun('VALIDATE_RED_CARD_PKG',strMsgNum,'ENGLISH') ;
             --strMsgStr :=
            -- 'NET10 Redemption Cards should only be used with NET10 ESN.';
             GOTO package_end;
          END IF;
    */
    OPEN c_phonebyesn(stresn);

    FETCH c_phonebyesn
      INTO v_dllid;

    IF ((strstatus = '280') AND (strsourcesys = 'HANDSET')) THEN
      IF c_phonebyesn%FOUND THEN
        IF (v_dllid < 22) THEN
          strerrorpin := 'Please visit our website at tracfone.com or contact Customer Care to add this PIN';
          dbms_output.put_line(strerrorpin);
        ELSE
          strerrorpin := 'Visit our website at tracfone.com or call Customer Care to add this PIN';
          dbms_output.put_line(strerrorpin);
        END IF;
      END IF;

      strmsgnum := '417';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := strErrorPin;
      GOTO package_end;
    END IF;

    -- XXX:CR6178
    -- (tp #2328)
    -- expired wagner
    IF (strstatus = '281') THEN
      strerrorpin := 'Error: Expired Settlement Benefit PIN';
      dbms_output.put_line(strerrorpin);
      strmsgnum := '419';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'Expired Settlement Benefit PIN.';
      GOTO package_end;
    END IF;

    -- if it is autopay, identify as such
    IF (UPPER(TRIM(strcardtype)) = 'AUTOPAY') THEN
      strmsgnum := '412';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                  ,strmsgnum
                                  ,'ENGLISH');
      --strMsgStr := 'AutoPay Redemption Card';
      GOTO package_end;
    END IF;

    -- XXX:CR6178
    -- (tp #2328)
    -- if it is wagner, identify as such
    ---Check for lifeline cards
    ----LIFE LINE ESN CURSOR TO CHECK FOR LIFELINE ESN
    -- OPEN ISLLESN(strEsn);
    --FETCH ISLLESN INTO V_ESNll;
    IF (v_parttype = 'LLPAID') THEN
      ------ADDED FOR LL
      OPEN isllesn(stresn);

      FETCH isllesn
        INTO v_esnll;

      IF isllesn%NOTFOUND THEN
        strerrorpin := 'Error: This is a life line pin';
        dbms_output.put_line(strerrorpin);
        strmsgnum := 433; ----NEW ERROR CODE FOR LIFELINE CARDS
        strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'
                                    ,strmsgnum
                                    ,'ENGLISH');
      ELSE
        GOTO package_end;
      END IF;

      CLOSE isllesn;
    END IF;

   -- CR42459 Safelink Unlimited.   -- CR47024 start.
   BEGIN
      SELECT mv.service_plan_group
        INTO v_service_plan_group
        FROM sa.table_part_class pc ,
             sa.table_part_num pn ,
             sa.table_mod_level ml ,
             sa.table_part_inst pi ,
             sa.mtm_partclass_x_spf_value_def mtmspfv ,
             sa.x_serviceplanfeature_value spfv ,
             sa.x_service_plan_feature spf ,
             sa.x_service_plan sp,
             sa.service_plan_feat_pivot_mv mv
       WHERE pc.objid = pn.part_num2part_class
         AND pn.objid = ml.part_info2part_num
         AND ml.objid = pi.n_part_inst2part_mod
         AND pi.x_red_code = strredcard
         AND mtmspfv.part_class_id = pc.objid
         AND mtmspfv.spfeaturevalue_def_id = spfv.value_ref
         AND spfv.spf_value2spf = spf.objid
         AND spf.sp_feature2service_plan = sp.objid
         AND sp.objid = mv.service_plan_objid
         AND ROWNUM = 1;

   EXCEPTION WHEN OTHERS THEN
      v_service_plan_group := NULL;

   END;

   IF get_device_type(stresn) = 'FEATURE_PHONE'
      AND
      NVL(GET_DATA_MTG_SOURCE (stresn),'PPE') = 'PPE' THEN
      IF f_product_allowed_sl_ppe(stresn) = 0
         AND
         v_service_plan_group  = 'TFSL_UNLIMITED' THEN
            dbms_output.put_line(stresn);
            strmsgnum := '442';
            strmsgstr := 'This device does not support unlimited plans';
            GOTO package_end;
      END IF;
   END IF;

     BEGIN
     v_flag := 'N';

        SELECT DISTINCT flg
          INTO v_flag
          FROM (SELECT 'Y' flg
                  FROM x_program_enrolled pe,
                       x_program_parameters pgm,
                       x_sl_currentvals slcur,
                       table_bus_org borg,
                       table_x_promotion tp
                 WHERE 1                       = 1
                   AND pgm.objid               = pe.pgm_enroll2pgm_parameter
                   AND slcur.x_current_esn     = pe.x_esn
                   AND sysdate BETWEEN pgm.x_start_date AND pgm.x_end_date
                   AND pgm.x_prog_class        = 'LIFELINE'
                   AND pe.x_esn                = stresn
                   AND borg.objid              = pgm.PROG_PARAM2BUS_ORG
                   AND org_id                  = 'TRACFONE'
                   AND pgm.x_promo_incl_min_at = tp.objid
                   AND rownum                  = 1);


     EXCEPTION WHEN OTHERS THEN
        v_flag := 'N';
     END;

     -- CR47024  Block if non sl customer tries to redeem sl card.

     IF v_flag = 'N'  -- Is not safelink customer
        AND
        v_service_plan_group  = 'TFSL_UNLIMITED'  -- Buying Safelink service plan
        THEN
           dbms_output.put_line(stresn);
           strmsgnum := '443';
           strmsgstr := 'This is not a SL customer and card is SL only '||stresn;
           GOTO package_end;
      END IF;

      --Below edit added for CR47988
      IF NVL(is_safelink(stresn, NULL), 'Y') = 'N' AND NVL(is_sl_red_pn(v_partnumber), 'N') = 'Y'
      THEN --{
       dbms_output.put_line(stresn);
       strmsgnum := '443';
       strmsgstr := 'This is not a SL customer and card is SL only. '||stresn;
       GOTO package_end;
      END IF; --}
          -- CR47024
          v_splan_group_esn := NULL;
          BEGIN
          SELECT sa.get_serv_plan_value(sa.UTIL_PKG.get_service_plan_id(stresn),
                                                                        'SERVICE_PLAN_GROUP') service_plan_group
            INTO v_splan_group_esn
            FROM DUAL;

          EXCEPTION WHEN OTHERS THEN
             v_splan_group_esn := NULL;

          END;


          v_paygo_flag := 'N';
          BEGIN

             SELECT 'Y'
               INTO v_paygo_flag
               FROM x_serviceplanfeaturevalue_def spfvdef,
                    x_serviceplanfeature_value spfv,
                    x_service_plan_feature spf,
                    x_serviceplanfeaturevalue_def spfvdef2,
                    x_service_plan sp
              WHERE 1 =1
                AND spf.sp_feature2service_plan = sp.objid
                AND sp.objid IN (SELECT sp_objid
                                   FROM sa.table_part_num pn,
                                        sa.table_mod_level ml,
                                        sa.table_part_inst pi,
                                        sa.table_part_class pc,
                                        sa.adfcrm_serv_plan_class_matview
                                  WHERE 1 = 1
                                    AND pn.objid = ml.part_info2part_num
                                    AND ml.objid = pi.n_part_inst2part_mod
                                    and pn.part_num2part_class  = pc.objid
                                    and pi.x_red_code = strredcard
                                    and part_class_name = pc.name)
                AND spf.sp_feature2rest_value_def = spfvdef.objid
                AND spf.objid = spfv.spf_value2spf
                AND spfvdef2.objid = spfv.value_ref
                AND spfvdef2.value_name = 'PAY_GO';

          EXCEPTION WHEN OTHERS THEN
             v_paygo_flag := 'N';

          END;



   IF v_splan_group_esn = 'TFSL_UNLIMITED' -- Customer is on unlimited plan.
      AND
      v_paygo_flag = 'Y' THEN  -- They are buying paygo card.
         dbms_output.put_line(stresn);
         strmsgnum := '444';
         strmsgstr := 'This SL customer on unlimited plan unable to buy Paygo card: '||stresn;
         GOTO package_end;
   END IF;


         -- CR47024 end

  --CR49890 Determine Add On Compatibility for Straigh Talk, CR55070 Added Net10
  IF v_strcardbrand IN ('STRAIGHT_TALK','NET10','SIMPLE_MOBILE') THEN
    IF is_addon_exclusion(stresn) = 'Y' AND v_service_plan_group = 'ADD_ON_DATA' THEN
      dbms_output.put_line('ERROR: ESN ' ||stresn|| ' not compatible with ADD ON DATA plans');
      strmsgnum := '1591';
      strmsgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',strmsgnum,'ENGLISH');
      GOTO package_end;
    END IF;
  END IF;

    /*
      -- CR8663 WALMART SWITCH BASE
      IF strSubsourcesystem = 'STRAIGHT_TALK'
      THEN
     OPEN STRAIGHT_TALK_ESN_cur(strEsn);
      FETCH STRAIGHT_TALK_ESN_cur INTO STRAIGHT_TALK_ESN_rec;
          IF (v_parttype <>'MPPAID')
             or STRAIGHT_TALK_ESN_cur%NOTFOUND
                or strSourceSys not like 'NET%'
          THEN
              strErrorPin := 'Error: Straight Talk Switch Error';
              DBMS_OUTPUT.put_line(strErrorPin);
              strMsgNum := 434;
              strMsgStr := sa.Get_Code_Fun('VALIDATE_RED_CARD_PKG',strMsgNum,'ENGLISH');
              GOTO package_end;
          END IF;
      ELSE
    OPEN STRAIGHT_TALK_ESN_cur(strEsn);
      FETCH STRAIGHT_TALK_ESN_cur INTO STRAIGHT_TALK_ESN_rec;
          IF (v_parttype ='MPPAID') or STRAIGHT_TALK_ESN_cur%FOUND THEN
              strErrorPin := 'Error: Cant use Straight Talk phone or pin';
              DBMS_OUTPUT.put_line(strErrorPin);
              strMsgNum := 435;
              strMsgStr := sa.Get_Code_Fun('VALIDATE_RED_CARD_PKG',strMsgNum,'ENGLISH');
              GOTO package_end;
          END IF;
      END IF ;
      -- CR8663 WALMART SWITCH BASE END
          IF (strStatus = '280')
          THEN
             strMsgNum := '418';
             strMsgStr := sa.Get_Code_Fun('VALIDATE_RED_CARD_PKG',strMsgNum,'ENGLISH') ;
             --strMsgStr := 'Valid Wagner Card';
             GOTO package_end;
          END IF;
    */
    <<package_end>>
  ----------- Close Open Cursors

    --      IF straight_talk_esn_cur%ISOPEN THEN
    --       CLOSE straight_talk_esn_cur;
    --     END IF;

    -----------
    IF (intunits IS NULL) THEN
      intunits := 0;
    END IF;

    IF (intdays IS NULL) THEN
      intdays := 0;
    END IF;

    /*      IF (intAmigo
          IS
          NULL)
          THEN
             intAmigo := 0;

          END IF;
    */
    IF (strmsgnum IS NULL) THEN
      strmsgnum := '0';
    END IF;

    IF (strmsgstr IS NULL) THEN
      strmsgstr := ' ';
    END IF;

    IF (strerrorpin IS NULL) THEN
      strerrorpin := ' ';
    END IF;

    dbms_output.put_line('strStatus = ' || strstatus);
    dbms_output.put_line('intUnits = ' || intunits);
    dbms_output.put_line('intDays = ' || intdays);
    --    DBMS_OUTPUT.put_line('intAmigo = '||intAmigo);
    dbms_output.put_line('strRedCard = ' || strredcard);
    dbms_output.put_line('strMsgNum = ' || strmsgnum);
    dbms_output.put_line('strMsgStr = ' || strmsgstr);


     -- CR 28465 WEBCSR Migration - Net10 + TracFone
    dbms_output.put_line('description = ' || description);
    dbms_output.put_line('partnumber = ' || partnumber);
    dbms_output.put_line('cardtype = ' || cardtype);
    dbms_output.put_line('parttype = ' || parttype);
    dbms_output.put_line('x_web_card_desc = ' || x_web_card_desc);
    dbms_output.put_line('x_sp_web_card_desc = ' || x_sp_web_card_desc);
    dbms_output.put_line('x_ild_type = ' || x_ild_type);

         /*   --ar change for testing start CR37012 -- unnecessary data into error_table
                      op_err_string := 'strredcard: '||strredcard ||' strsmpnumber: '||strsmpnumber ||
                               ' strsourcesys: '||strsourcesys ||' stresn: '||stresn||' strmsgnum: '||strmsgnum||' strmsgstr: '||strmsgstr;

   ota_util_pkg.err_log(p_action => 'validate_red_card_pkg', p_error_date => SYSDATE, p_key => ('testing--step 8'), p_program_name =>
    'validate_red_card_pkg.main', p_error_text => op_err_string);
    --ar change for testing end
      */
    OPEN po_refcursor
        FOR
            SELECT strstatus                          AS  strstatus,
                            intunits                           AS intunits,
                            intdays                           AS intdays,
                            strcardbrand                  AS strcardbrand,
                            strmsgnum                    AS strmsgnum,
                            strmsgstr                       AS strmsgstr,
                            strerrorpin                     AS strerrorpin,
                           description                     AS description,
                           partnumber                    AS partnumber,
                           cardtype                         AS cardtype,
                           parttype                          AS parttype,
                           x_web_card_desc          AS x_web_card_desc,
                           x_sp_web_card_desc    AS x_sp_web_card_desc,
                           x_ild_type                      AS x_ild_type
                   FROM DUAL;

   EXCEPTION
    WHEN others THEN

            --ar change for testing start
                      op_err_string := 'strredcard: '||strredcard ||' strsmpnumber: '||strsmpnumber ||
                               ' strsourcesys: '||strsourcesys ||' stresn: '||stresn||' strmsgnum: '||strmsgnum||' strmsgstr: '||strmsgstr;

   ota_util_pkg.err_log(p_action => 'validate_red_card_pkg', p_error_date => SYSDATE, p_key => ('testing--step 9 exception'), p_program_name =>
    'validate_red_card_pkg.main', p_error_text => op_err_string);
    --ar change for testing end

      raise_application_error(-20000
                             ,SQLCODE || SQLERRM || ' Main');
END main;
  ----------------------------------------------------------------------------------------
  FUNCTION get_coll RETURN out_tab_ty
    PIPELINED
  ----------------------------------------------------------------------------------------
   IS
  BEGIN
    FOR i IN 1 .. out_tab.count LOOP
      PIPE ROW(out_tab(i));
    END LOOP;
    RETURN;
  END;

  ----------------------------------------------------------------------------------------
  PROCEDURE process_batch(
                          ----------------------------------------------------------------------------------------
                          ip_strredcardlist IN VARCHAR2
                         ,ip_strsmpnumber   IN VARCHAR2
                         ,ip_strsourcesys   IN VARCHAR2
                         ,ip_stresn         IN VARCHAR2
                         ,op_result_set     OUT SYS_REFCURSOR) IS

    l_redcard_list VARCHAR2(4000);
    ctr                 NUMBER;
    v_refcursor    SYS_REFCURSOR;

  BEGIN
    l_redcard_list := ip_strredcardlist || ',';
     out_tab.delete;
    ctr := 1;
    WHILE (INSTR(l_redcard_list
                ,',') <> 0) LOOP
        out_tab.extend;
        out_tab(ctr).strredcard  := (SUBSTR(l_redcard_list
                                        ,1
                                        ,INSTR(l_redcard_list
                                              ,',') - 1));
      l_redcard_list := SUBSTR(l_redcard_list
                              ,INSTR(l_redcard_list
                                    ,',') + 1);
      main(out_tab(ctr).strredcard
          ,ip_strsmpnumber
          ,ip_strsourcesys
          ,ip_stresn
          ,v_refcursor);

          FETCH v_refcursor
             INTO  out_tab(ctr).strstatus
                 ,out_tab(ctr).intunits
                ,out_tab(ctr).intdays
                ,out_tab(ctr).strcardbrand
                ,out_tab(ctr).strmsgnum
                ,out_tab(ctr).strmsgstr
                ,out_tab(ctr).strerrorpin
                ,out_tab(ctr).description
                ,out_tab(ctr).partnumber
                ,out_tab(ctr).cardtype
                ,out_tab(ctr).parttype
                ,out_tab(ctr).x_web_card_desc
                ,out_tab(ctr).x_sp_web_card_desc
                ,out_tab(ctr).x_ild_type;

           CLOSE   v_refcursor;

      ctr := ctr + 1;

    END LOOP;
    OPEN op_result_set FOR
      SELECT *
        FROM TABLE(get_coll);
  END;

-- stored procedure used to simulate a posa card swipe
PROCEDURE simulate_redeemable_card ( i_part_serial_no      IN  VARCHAR2,
                                     i_date                IN  VARCHAR2,
                                     i_time                IN  VARCHAR2,
                                     i_trans_id            IN  VARCHAR2,
                                     i_trans_type          IN  VARCHAR2,
                                     i_merchant_id         IN  VARCHAR2,
                                     i_store_detail        IN  VARCHAR2,
                                     o_card_units          OUT NUMBER,
                                     o_result              OUT VARCHAR2,
									 o_gtt_part_inst_objid OUT NUMBER,
                                     o_gtt_posa_card_objid OUT NUMBER,
                                     i_sourcesystem        IN  VARCHAR2 := 'POSA' ) IS

  c_card_status            VARCHAR2(3);
  pci_rec                  table_x_posa_card_inv%ROWTYPE;
  c_card_inactive          CONSTANT VARCHAR2(3) := '45';
  c_card_ready             CONSTANT VARCHAR2(3) := '42';
  c_site_id                table_site.site_id%TYPE;
  c_part_number            table_part_num.part_number%TYPE;
  pi_rec                   table_part_inst%ROWTYPE;
  c_mod_level_objid        table_mod_level.objid%TYPE;
  pn_rec                   table_part_num%ROWTYPE;
  rc_rec                   table_x_red_card%ROWTYPE;
  c_part_number_promo_code table_x_promotion.x_promo_code%TYPE;
  rct                      sa.red_card_type := sa.red_card_type();
  r                        sa.red_card_type := sa.red_card_type();
BEGIN

  -- insert the temporary gtt inventory row
  BEGIN
    INSERT
    INTO   sa.gtt_posa_card_inv
    SELECT *
    FROM   table_x_posa_card_inv
    WHERE  x_part_serial_no = i_part_serial_no;
   EXCEPTION
     WHEN others THEN
       DBMS_OUTPUT.PUT_LINE('STEP 0 IN SIMULATE_REDEEMABLE_CARD: TABLE_X_POSA_CARD_INV NOT FOUND');
       NULL;
  END;

  -- get card status
  BEGIN
    SELECT *
    INTO   pi_rec
    FROM   table_part_inst
    WHERE  part_serial_no = i_part_serial_no
    AND    x_domain = 'REDEMPTION CARDS';
   EXCEPTION
     WHEN no_data_found THEN
       BEGIN
         SELECT *
         INTO   pci_rec
         FROM   table_x_posa_card_inv
         WHERE  x_part_serial_no = i_part_serial_no;
        EXCEPTION
          WHEN no_data_found THEN
            BEGIN
              SELECT *
              INTO   rc_rec
              FROM   table_x_red_card
              WHERE  x_smp = i_part_serial_no
              AND    x_result ||'' = 'Completed';
             EXCEPTION
               WHEN others THEN
                 o_result := 'CARD NOT FOUND';
                 RETURN;
            END;
          WHEN others THEN
            o_result := 'INVENTORY POSA CARD NOT FOUND';
            RETURN;
       END;
     WHEN others THEN
       o_result := 'INVENTORY POSA CARD NOT FOUND';
       RETURN;
  END;

  IF rc_rec.objid IS NOT NULL THEN
    c_mod_level_objid := rc_rec.x_red_card2part_mod;
    c_card_status := '41';
  END IF;

  IF pci_rec.objid IS NOT NULL THEN
    c_mod_level_objid := pci_rec.x_posa_inv2part_mod;
    c_card_status := pci_rec.x_posa_inv_status;
  END IF;

  IF pi_rec.objid IS NOT NULL THEN
    c_mod_level_objid := pi_rec.n_part_inst2part_mod;
    c_card_status := pi_rec.x_part_inst_status;
  END IF;

  BEGIN
    SELECT pn.*
    INTO   pn_rec
    FROM   table_part_num pn,
           table_mod_level ml
    WHERE  ml.objid = c_mod_level_objid
    AND    ml.part_info2part_num = pn.objid;
   EXCEPTION
     WHEN others THEN
       DBMS_OUTPUT.PUT_LINE('STEP 1 IN SIMULATE_REDEEMABLE_CARD: CARD PART NUMBER NOT FOUND');
       o_result := 'CARD PART NUMBER NOT FOUND';
       RETURN;
  END;

  IF pn_rec.part_number = 'DB0104' THEN
    o_card_units := 100;
  ELSIF pn_rec.part_number = 'DB0260' THEN
    o_card_units := 260;
  ELSE
    o_card_units := pn_rec.x_redeem_units;
  END IF;

  IF pn_rec.part_num2x_promotion IS NOT NULL THEN
    BEGIN
      SELECT x_promo_code
      INTO   c_part_number_promo_code
      FROM   table_x_promotion
      WHERE  objid = pn_rec.part_num2x_promotion
      AND    SYSDATE BETWEEN x_start_date AND x_end_date;
    EXCEPTION
     WHEN others THEN
       NULL;
    END;

  END IF;

  -- end get card status

  -- If the card status is inactive
  IF c_card_status = c_card_inactive THEN -- 45

    IF i_sourcesystem = 'POSA_FLAG_ON' AND
       ( o_card_units >= 400
         --
         OR c_part_number_promo_code = 'RTX3X000'
         --
         OR c_part_number_promo_code = 'RTDBL000'
       )
    THEN
      o_result := 'INVALID UNITS WHEN POSA FLAG ON';
      RETURN;
    ELSE
	  -- reset table rowtype variable
	  pci_rec := NULL;
	  --
      BEGIN
        SELECT *
        INTO   pci_rec
        FROM   table_x_posa_card_inv
        WHERE  x_part_serial_no = i_part_serial_no;
       EXCEPTION
         WHEN others THEN
           o_result := 'INVENTORY POSA CARD NOT FOUND';
           RETURN;
      END;

      -- instantiate gtt part inst values
      rct := sa.red_card_type ( i_part_serial_no          => pci_rec.x_part_serial_no,
                                i_domain                  => pci_rec.x_domain,
                                i_red_code                => pci_rec.x_red_code,
                                i_part_inst_status        => c_card_ready,
                                i_insert_date             => pci_rec.x_inv_insert_date,
                                i_creation_date           => pci_rec.x_last_ship_date,
                                i_po_num                  => pci_rec.x_tf_po_number,
                                i_order_number            => pci_rec.x_tf_order_number,
                                i_created_by2user         => pci_rec.x_created_by2user,
                                i_status2x_code_table     => 984,
                                i_n_part_inst2part_mod    => pci_rec.x_posa_inv2part_mod,
                                i_part_inst2inv_bin       => pci_rec.x_posa_inv2inv_bin,
                                i_last_trans_time         => SYSDATE,
                                i_parent_part_serial_no   => pci_rec.x_part_serial_no);

      -- insert gtt part inst row
      r.response := rct.save_gtt_part_inst ( io_gpi => rct );

	  IF r.response != 'SUCCESS' THEN
        o_result := 'POSA CARD INSERT FAILED: ' || r.response;
        RETURN;
	  END IF;

	  -- set the objid of the gtt row
	  o_gtt_part_inst_objid := rct.gtt_part_inst_objid;

      -- This is not necessary since the inventory table is not used after this step: JUDA
      DELETE
      FROM   sa.gtt_posa_card_inv
      WHERE  x_part_serial_no = i_part_serial_no
      AND    x_domain = 'REDEMPTION CARDS';
      --
      BEGIN
        UPDATE sa.gtt_part_inst
        SET    x_part_inst_status = '42'
        WHERE  part_serial_no = i_part_serial_no
        AND    x_parent_part_serial_no = pci_rec.x_part_serial_no
        AND    x_domain = 'REDEMPTION CARDS';
       EXCEPTION
         WHEN OTHERS THEN
           o_result := 'TEMPORARY POSA CARD STATUS CHANGE FAILED';
           RETURN;
      END;
      --

      -- get site id
      BEGIN
        SELECT ts.site_id
        INTO   c_site_id
        FROM   table_site ts,
               table_inv_bin ib,
               table_part_inst pi
        WHERE  pi.part_serial_no = i_part_serial_no
        AND    pi.x_domain = 'REDEMPTION CARDS'
        AND    pi.part_inst2inv_bin = ib.objid
        AND    ib.bin_name = ts.site_id;
       EXCEPTION
         WHEN OTHERS THEN
           NULL;
      END;

      -- get part number
      BEGIN
        SELECT pn.part_number
		INTO   c_part_number
        FROM   table_part_num pn,
               table_part_inst pi,
               table_mod_level ml
        WHERE  1 = 1
        AND    pi.part_serial_no = i_part_serial_no
        AND    pi.x_domain = 'REDEMPTION CARDS'
        AND    pi.n_part_inst2part_mod = ml.objid
        AND    ml.part_info2part_num = pn.objid;
       EXCEPTION
         WHEN OTHERS THEN
           DBMS_OUTPUT.PUT_LINE('PART NUMBER NOT FOUND FOR PART_SERIAL_NO => ' || i_part_serial_no);
           o_result := 'PART NUMBER NOT FOUND';
           RETURN;
      END;

      -- instantiate gtt posa card values
      rct := sa.red_card_type ( i_part_number         => c_part_number,
	                        i_part_serial_no      => i_part_serial_no,
	                        i_toss_att_customer   => i_merchant_id,
	                        i_toss_att_location   => i_store_detail,
	                        i_toss_posa_code      => c_card_ready,
	                        i_toss_posa_date      => SYSDATE,
	                        i_tf_extract_flag     => 'N',
	                        i_tf_extract_date     => NULL,
	                        i_toss_site_id        => c_site_id,
	                        i_toss_posa_action    => 'SWIPE',
	                        i_remote_trans_id     => i_trans_id,
	                        i_sourcesystem        => i_sourcesystem,
	                        i_toss_att_trans_date => TO_DATE (i_date || i_time, 'MMDDYYYYHH24MISS') );

      -- insert gtt posa card row
      r.response := rct.save_gtt_posa_card ( io_gpc => rct );

	  IF r.response != 'SUCCESS' THEN
        o_result := 'TEMPORARY SWIPED POSA CARD INSERT FAILED: ' || r.response;
        RETURN;
	  END IF;

	  -- set the objid of the gtt posa card row
	  o_gtt_posa_card_objid := rct.gtt_posa_card_objid;


    END IF; -- IF i_sourcesystem = 'POSA_FLAG_ON'

  ELSE -- IF v_card_status = '45' THEN
    o_result := 'INVALID CARD STATUS';
    RETURN;
  END IF;

  o_result := 'SUCCESS';

 EXCEPTION
   WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE('LAST STEP IN SIMULATE_REDEEMABLE_CARD: ' || SQLERRM);
     --
     o_result := 'Failed making card reedemable: ' || SQLERRM;
     RETURN;
END simulate_redeemable_card;

-- Validate pre posa card for WARP
PROCEDURE validate_pre_posa ( i_red_card           IN      VARCHAR2       ,
                              i_smp_number         IN      VARCHAR2       ,
                              i_sourcesystem       IN      VARCHAR2       ,
                              io_esn               IN OUT  VARCHAR2       ,
                              i_bus_org_id         IN      VARCHAR2       ,
                              i_client_id          IN      VARCHAR2       ,
                              o_refcursor          OUT     SYS_REFCURSOR  ,
                              o_available_capacity OUT     NUMBER         ,
                              o_err_code           OUT     NUMBER         ,
                              o_err_msg            OUT     VARCHAR2       ) IS

  c_posa_card_flag               VARCHAR2(1) := 'N';
  c_msgnum                       VARCHAR2(1000);
  c_msgstr                       VARCHAR2(1000);
  c_error_pin                    VARCHAR2(1000);
  c_error_str                    VARCHAR2(1000);
  c_posa_airtime                 VARCHAR2(1);
  c_inactive_posa_flag           VARCHAR2(1);
  c_part_serial_no               VARCHAR2(40);
  c_posa_result                  VARCHAR2(1000);
  c_card_units                   NUMBER;
  cst                            sa.customer_type := sa.customer_type();
  c                              sa.customer_type := sa.customer_type();
  ct                             sa.customer_type := sa.customer_type();
  cstg                           sa.customer_type := sa.customer_type();
  rct                            sa.red_card_type := sa.red_card_type();
  rc                             sa.red_card_type := sa.red_card_type();
  rc_temp                        sa.red_card_type;
  pn                             sa.red_card_type;
  est                            sa.red_card_type := sa.red_card_type();
  rsp                            sa.red_card_type := sa.red_card_type();

  n_rc_part_inst_objid           NUMBER;
  c_smpnumber                    VARCHAR2(20);
  c_part_inst_status             VARCHAR2(10);
  n_esn_part_inst_objid          NUMBER;
  c_red_card                     VARCHAR2(40);
  n_offer                        NUMBER := 0;
  n_offer_x3x                    NUMBER := 0;
  n_units                        sa.table_part_num.x_redeem_units%TYPE;
  n_days                         sa.table_part_num.x_redeem_days%TYPE;
  n_gtt_part_inst_objid          NUMBER;
  n_gtt_posa_card_objid          NUMBER;
  c_dummy_esn_flag               VARCHAR2(1) := 'N';
  n_payment_pending_group_objid  NUMBER;
  v_brm_service_days             NUMBER := 0;
BEGIN

  IF (LENGTH(TRIM(i_red_card)) = 0) THEN
    c_error_pin := 'ERROR: PIN' || i_red_card || 'NOT VALID. PLEASE VERIFY AND RETRY';
    c_msgnum := '401';
    c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
    GOTO package_end;
  END IF;

  DBMS_OUTPUT.PUT_LINE('ENTERED VALIDATE_PRE_POSA');
  --
  BEGIN
    SELECT 'Y'
    INTO   c_posa_card_flag
    FROM   sa.table_x_posa_card_inv
    WHERE  x_red_code = i_red_card;
   EXCEPTION
     WHEN too_many_rows THEN
       c_msgnum := '999'; -- TO BE REPLACED: JUDA
       c_msgstr := 'DUPLICATE CARD IN POSA INVENTORY';
       DBMS_OUTPUT.PUT_LINE('FAILED IN STEP 1');
       GOTO package_end;
     WHEN others THEN
       c_posa_card_flag := 'N';
       DBMS_OUTPUT.PUT_LINE('FAILED GETTING CARD IN TABLE_X_POSA_CARD_INV');
  END;

  -- if the card is posa
  IF (c_posa_card_flag = 'Y') THEN

    --
    BEGIN
      SELECT x_part_serial_no
      INTO   c_part_serial_no
      FROM   sa.table_x_posa_card_inv
      WHERE  x_red_code = i_red_card
      AND    ROWNUM = 1;
     EXCEPTION
       WHEN others THEN
         NULL;
         DBMS_OUTPUT.PUT_LINE('FAILED GETTING PART_SERIAL_NO (SMP) FROM TABLE_X_POSA_CARD_INV');
    END;

    c_inactive_posa_flag := 'Y';

    IF (c_part_serial_no IS NOT NULL) THEN

      BEGIN
        SELECT pfd.posa_airtime
        INTO   c_posa_airtime
        FROM   sa.x_posa_flag_dealer pfd
        WHERE  pfd.site_id = ( SELECT ib.bin_name
                               FROM   table_x_posa_card_inv xpc,
                                      table_inv_bin ib,
                                      table_site ts
                               WHERE  ts.site_id(+) = ib.bin_name
                               AND    ib.objid = xpc.x_posa_inv2inv_bin
                               AND    xpc.x_part_serial_no = c_part_serial_no
                             );
       EXCEPTION
         WHEN others THEN
           DBMS_OUTPUT.PUT_LINE('FAILED IN STEP 4');
           NULL;
      END;

      --
      DBMS_OUTPUT.PUT_LINE('STEP 4: c_part_serial_no => ' ||c_part_serial_no);
      DBMS_OUTPUT.PUT_LINE('STEP 4: c_posa_airtime => ' ||c_posa_airtime);
      --

      IF (c_part_serial_no IS NOT NULL) THEN
        IF (c_posa_airtime = 'Y') THEN
          --
          simulate_redeemable_card ( i_part_serial_no      => c_part_serial_no,
                                     i_date                => '',
                                     i_time                => '',
                                     i_trans_id            => '',
                                     i_trans_type          => '',
                                     i_merchant_id         => '',
                                     i_store_detail        => '',
                                     o_card_units          => c_card_units,
                                     o_result              => c_posa_result,
                                     o_gtt_part_inst_objid => n_gtt_part_inst_objid,
                                     o_gtt_posa_card_objid => n_gtt_posa_card_objid,
                                     i_sourcesystem        => 'POSA_FLAG_ON');

          DBMS_OUTPUT.PUT_LINE('result from posa: ' || c_posa_result); -- TO BE REMOVED: JUDA
          --
          c_inactive_posa_flag := 'N';
          --
        END IF;
      END IF;
    END IF;

    DBMS_OUTPUT.PUT_LINE('STEP 6: c_inactive_posa_flag => ' || c_inactive_posa_flag);

    --
    IF (c_inactive_posa_flag = 'Y') THEN
      IF i_sourcesystem in ('TAS', 'WEBCSR') THEN
        c_msgnum := '404';
        c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,c_msgnum,'ENGLISH');
        GOTO package_end;
      ELSE
        c_error_pin := 'ERROR: PIN NOT ACTIVATED. PLEASE RETRY IN 30 MINUTES';
        c_msgnum := '410';
        c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
        GOTO package_end;
      END IF;
    END IF;
  END IF; -- IF (c_posa_card_flag = 'Y') THEN

  DBMS_OUTPUT.PUT_LINE('GETTING CARD FROM INVENTORY');

  -- get the card from inventory
  BEGIN
    SELECT objid,
           part_serial_no,
           x_red_code,
           x_part_inst_status,
           part_to_esn2part_inst
    INTO   n_rc_part_inst_objid,
           c_smpnumber,
           c_red_card,
           c_part_inst_status,
           n_esn_part_inst_objid
    FROM   sa.table_part_inst
    WHERE  1 = 1
    AND    part_serial_no = NVL(i_smp_number,part_serial_no)
    AND    x_red_code = i_red_card
    AND    x_domain = 'REDEMPTION CARDS';
   EXCEPTION
     WHEN no_data_found THEN
       --
       DBMS_OUTPUT.PUT_LINE('SMP AND PIN NOT FOUND IN TABLE_PART_INST');
       --
       -- Get the card from the GTT table
       BEGIN
         SELECT objid,
                part_serial_no,
                x_red_code,
                x_part_inst_status,
                part_to_esn2part_inst
         INTO   n_rc_part_inst_objid,
                c_smpnumber,
                c_red_card,
                c_part_inst_status,
                n_esn_part_inst_objid
         FROM   sa.gtt_part_inst
         WHERE  1 = 1
         AND    part_serial_no = NVL(i_smp_number,part_serial_no)
         AND    x_red_code = i_red_card
         AND    x_domain = 'REDEMPTION CARDS';
        EXCEPTION
          WHEN others THEN
            DBMS_OUTPUT.PUT_LINE('GTT PART INST NOT FOUND');
            GOTO package_end; -- CR47265
       END;
     WHEN others THEN
       DBMS_OUTPUT.PUT_LINE('PART INST NOT FOUND');
         GOTO package_end; -- CR47265
  END;

  -- if the card was found in the inventory
  IF n_rc_part_inst_objid IS NOT NULL THEN

    -- Reset red card type
    rc_temp := sa.red_card_type ();

    IF n_esn_part_inst_objid IS NOT NULL THEN
      -- call the member function to get the ens based on the part inst objid (n_esn_part_inst_objid)
      rc_temp := rct.get_esn ( i_part_inst_objid => n_esn_part_inst_objid );
      --
    END IF;

  ELSE

    -- call the member function to get the call trans objid related to a red card in table_x_red_card
    rc := rct.retrieve_red_card ( i_red_card   => i_red_card ,
                                  i_smp_number => i_smp_number );

    IF rc.call_trans_objid IS NOT NULL THEN

      IF (i_sourcesystem in ('TAS', 'WEBCSR' , 'HANDSET')) THEN
        c_error_pin := 'Error: Pin ' || i_red_card || ' already used';
        c_msgnum := '402';
        c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
        GOTO package_end;
      END IF;

      IF (rc.call_trans_objid IS NOT NULL AND LENGTH(rc.call_trans_objid) > 0) THEN

        -- Call member function to get the esn for a given call trans
        rc := rc.get_esn ( i_call_trans_objid => rc.call_trans_objid );

      END IF;

      IF (LENGTH(rc.esn) = 0) THEN
        c_error_pin := 'Error: Pin ' || i_red_card || ' is reserved for an Invalid ESN';
        c_msgnum := '405';
        c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
        GOTO package_end;
      ELSIF (NOT (rc.esn = (io_esn)) OR (rc.esn = io_esn))
      THEN
        c_error_pin := 'Error: Pin ' || i_red_card || ' already used on another phone';
        c_msgnum := '402';
        c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
        --
        GOTO package_end;
      ELSE
        --
        rc := rc.is_card_redeemed ( i_esn      => io_esn,
                                    i_red_card => i_red_card );

        IF rc.is_card_redeemed_flag = 'Y' THEN -- TO BE VALIDATED (COULD BE 'N'): JUDA
          c_error_pin := 'Error: Pin ' || i_red_card || 'not valid. Please verify and retry';
          c_msgnum   := '403';
          c_msgstr   := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
          c_part_inst_status := '41'; -- has been redeemed
          n_units  := rc.units;
          GOTO package_end;
        END IF;
      END IF; -- IF (LENGTH(rc.esn) = 0)
    ELSE
      -- not inventory, not redeemed, just a bad pin
      c_error_pin := 'Error: Pin ' || i_red_card || ' not valid. Please verify and retry';
      c_msgnum := '413';
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
      GOTO package_end;
    END IF; -- IF rc.call_trans_objid IS NOT NULL
  END IF; -- IF n_rc_part_inst_objid IS NOT NULL

  -- Through here if an inventory reserved objid to reserved ESN (ugh!)
  IF (rc_temp.esn IS NOT NULL) THEN
    FOR i IN ( SELECT part_serial_no
               FROM   sa.table_part_inst
               WHERE  part_serial_no = rc_temp.esn )
    LOOP
      rc_temp.esn := i.part_serial_no;
    END LOOP;
  END IF;

  -- IF reserved
  IF (TRIM(c_part_inst_status) IN ('40','400')) -- ST Retention PM.
  THEN
    -- bad ESN
    IF (LENGTH(rc_temp.esn) = 0) THEN
      c_error_pin := 'Error: Pin ' || i_red_card || ' is reserved for an Invalid ESN';
      c_msgnum := '431'; -- Changed to 431 from 405 CR7259 SK
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
      GOTO package_end;
    -- not my ESN
    ELSIF (NOT (rc_temp.esn = io_esn)) THEN
      c_error_pin := 'Error: Pin ' || i_red_card || ' already used on another phone';
      c_msgnum := '430'; -- Changed to 430 from 402 CR7259 SK
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
      GOTO package_end;
    END IF;
  ELSIF (TRIM(c_part_inst_status) = '263') THEN
    -- bad ESN
    IF (LENGTH(rc_temp.esn) = 0) THEN
      c_error_pin := 'Error: Pin ' || i_red_card || ' is reserved for an Invalid ESN';
      c_msgnum := '414';
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
      GOTO package_end;
      -- not my ESN
    ELSIF (NOT (rc_temp.esn = io_esn)) THEN
      c_error_pin := 'Error: Pin ' || i_red_card || ' already used on another phone';
      c_msgnum := '427';
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
      GOTO package_end;
    ELSE
      IF (rc_temp.esn = io_esn) THEN
        c_error_pin := 'Error: Pin ' || i_red_card || ' already reserved for another phone';
        c_msgnum := '428';
        c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
        GOTO package_end;
      END IF;
    END IF;
  -- else not reserved
  ELSIF ((TRIM(c_part_inst_status) = '43'))
  THEN
    -- bad ESN
    IF ((LENGTH(rc_temp.esn) = 0) OR (NOT (NVL(rc_temp.esn,'0') = io_esn)))
    THEN
      c_error_pin := 'Error: Pin ' || i_red_card || ' not valid. Please verify and retry';
      c_msgnum := '403';
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
      GOTO package_end;
    ELSE
      -- it's mine pending
      c_part_inst_status := '40'; --make reserved

      -- Set the card as RESERVED in GTT
      UPDATE sa.gtt_part_inst
      SET    x_part_inst_status  = '40',
             status2x_code_table = ( SELECT objid
                                     FROM   sa.table_x_code_table
                                     WHERE  x_code_number = '40'
                                   )
       WHERE objid = n_rc_part_inst_objid;
    END IF;
  -- else if redeemed
  ELSIF (TRIM(c_part_inst_status) = '41') THEN
      -- reserved for bad or wrong phone
      IF (LENGTH(rc_temp.esn) = 0) THEN
        c_error_pin := 'Error: Pin ' || i_red_card || ' already reserved for another phone';
        c_msgnum := '405';
        c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
        GOTO package_end;
      ELSE
        IF (NOT (rc_temp.esn) = (io_esn)) THEN
          c_error_pin := 'Error: Pin ' || i_red_card || ' not valid. Please verify and retry';
          c_msgnum := '403';
          c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,c_msgnum ,'ENGLISH');
          GOTO package_end;
        ELSE
          -- call the member function to determine if the card is redeemed
          rc := rc.is_card_redeemed ( i_esn      => io_esn,
                                       i_red_card => i_red_card );

          IF rc.is_card_redeemed_flag = 'Y' THEN -- TO BE VALIDATED (COULD BE 'N'): JUDA
            c_error_pin := 'Error: Pin ' || i_red_card || ' already reserved for another phone';
            c_msgnum := '402';
            c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,c_msgnum,'ENGLISH');
            GOTO package_end;
          END IF;
        END IF;
      END IF;
  ELSIF (TRIM(c_part_inst_status) = '44') THEN
      c_error_pin := 'Error: Pin ' || i_red_card || ' not valid. Please verify and retry';
      c_msgnum := '403';
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
      GOTO package_end;
  ELSIF (TRIM(c_part_inst_status) = '45') THEN
      c_error_pin := 'Error: Pin ' || i_red_card || ' not valid. Please verify and retry';
      c_msgnum := '432'; -- Changed to 432 for status 45 from 403
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
      GOTO package_end;
  ELSIF (TRIM(c_part_inst_status) = '75') THEN
      c_error_pin := 'Error: Pin ' || i_red_card || ' not valid. Please verify and retry';
      c_msgnum := '407';
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
      GOTO package_end;
  --
  ELSIF (TRIM(c_part_inst_status) = '47') THEN
      c_error_pin := 'Error: Pin ' || i_red_card || ' not valid. Please verify and retry';
      c_msgnum := '403';
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
      GOTO package_end;
  END IF;

  -- call the member function to get the card part number attributes
  pn := rct.get_gtt_part_number_attributes ( i_red_card => i_red_card );

  IF pn.response LIKE '%SUCCESS%' THEN

    IF ((pn.card_part_inst_status IN ('40','400')) AND
       (rc_temp.esn != io_esn))
    THEN
      --
      c_error_pin := 'Error: Pin ' || i_red_card || ' already used on another phone';
      c_msgnum := '430';
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
    ELSE
      n_units := pn.redeem_units;
      n_days  := pn.redeem_days;

    --CR47564 WFM starts here - If WFM get the service days from x_part_inst_ext
    IF sa.customer_info.get_brm_notification_flag ( i_esn => io_esn ) = 'Y' THEN
      v_brm_service_days  := sa.customer_info.get_esn_pin_redeem_days (i_esn => io_esn , i_pin => i_red_card );
	  n_days := CASE v_brm_service_days WHEN 0 THEN n_days ELSE v_brm_service_days END;
    END IF;
    --CR47564 WFM ends here

      -- CMC_SPLIT START
      n_offer := esn_is_enrolled_in_dblmin_fun(io_esn);
      n_offer_x3x := esn_is_enrolled_in_x3xmin_fun(io_esn);
      IF (n_offer > 0 OR n_offer_x3x > 0) AND
         pn.promo_code = 'RTDBL000'
      THEN
        FOR x_offer_rec IN ( SELECT *
                             FROM   x_dblmn_offer
                           )
        LOOP
          IF n_units = x_offer_rec.at_units AND
             n_days = x_offer_rec.at_days
          THEN
            n_units := x_offer_rec.offered_units;
            n_days  := x_offer_rec.offered_days;
          END IF;
        END LOOP;

        c_msgnum := '425'; -- CMC_SPLIT
        c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');

      ELSIF n_offer_x3x > 0 AND
            pn.promo_code = 'RTX3X000'
      THEN
        --
        FOR x_offer_x3x_rec IN ( SELECT *
                                 FROM   sa.x_x3xmn_offer
                               )
        LOOP
          --
          IF n_units = x_offer_x3x_rec.at_units AND
             n_days = x_offer_x3x_rec.at_days
          THEN
            --
            n_units := x_offer_x3x_rec.offered_units;
            n_days  := x_offer_x3x_rec.offered_days;
            --
          END IF;
          --
        END LOOP;
        c_msgnum := '425';
        c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum ,'ENGLISH');
      END IF;
    --
    END IF; -- IF ((pn.card_part_inst_status IN ('40','400')) AND (rc_temp.esn != io_esn))

    ---
    IF pn.card_brand = 'TRACFONE' THEN
      BEGIN
        SELECT DISTINCT program_provision_flag
        INTO   est.sl_program_provision_flag
        FROM   mtm_program_safelink
        WHERE  part_num_objid = pn.card_part_number_objid
        AND    ROWNUM = 1;
       EXCEPTION
         WHEN others THEN
           est.sl_program_provision_flag := NULL;
      END;

      --
      IF est.sl_program_provision_flag IS NOT NULL THEN
        -- Call the member function to determine if esn is enrolled in safelink
        est := est.get_safelink_flag ( i_esn                   => io_esn,
                                       i_esn_part_number_objid => pn.card_part_number_objid);

        --
        IF est.safelink_flag = 'N' THEN
          c_msgnum := '1647';
          c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
          GOTO package_end;
        END IF;

      END IF; -- IF est.sl_program_provision_flag IS NOT NULL

    END IF; -- IF pn.card_brand = 'TRACFONE'

  ELSE
    c_msgnum := '406';
    c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'   ,c_msgnum        ,'ENGLISH');
    GOTO package_end;
  END IF; -- IF pn.response LIKE '%SUCCESS%' THEN

  -- Get the attributes of the esn
  est := est.get_gtt_esn_attributes ( i_esn => io_esn );

  DBMS_OUTPUT.PUT_LINE('est.bus_org_flow                => ' || est.bus_org_flow );
  DBMS_OUTPUT.PUT_LINE('est.bus_org_id                  => ' || est.bus_org_id );

  IF est.response NOT LIKE '%SUCCESS%' THEN
    c_msgnum := '411';
    c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
    GOTO package_end;
  END IF;

  -- If the brand of the card
  IF pn.bus_org_id <> est.bus_org_id THEN
    c_msgnum := '436';
    c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum ,'ENGLISH');
    GOTO package_end;
  END IF;

  --
  IF rsp.get_smartphone ( i_esn => io_esn) = 0 AND
     NVL(pn.promo_objid , 0 ) > 0 AND
     i_sourcesystem <> 'IVR'
  THEN
    c_msgnum := '422';
    c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,c_msgnum ,'ENGLISH');
  END IF;


  DBMS_OUTPUT.PUT_LINE('get_smartphone for IVR          => ' || rsp.get_smartphone ( i_esn => io_esn) );

  IF rsp.get_smartphone ( i_esn => io_esn) = 0
     AND nvl(pn.promo_objid , 0 ) > 0
     AND i_sourcesystem = 'IVR'
  THEN
    c_msgnum := '420';
    c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,c_msgnum ,'ENGLISH');
    GOTO package_end;
  END IF;
  --

  DBMS_OUTPUT.PUT_LINE('get_smartphone part inst 42     => ' || rsp.get_smartphone ( i_esn => io_esn) );
  DBMS_OUTPUT.PUT_LINE('pn.card_part_number             => ' || pn.card_part_number );
  DBMS_OUTPUT.PUT_LINE('est.esn_part_inst_status        => ' || est.esn_part_inst_status );
  DBMS_OUTPUT.PUT_LINE('c_part_inst_status              => ' || c_part_inst_status );

  --
  IF (c_part_inst_status = '42' AND is_data_card (pn.card_part_number))
  THEN
    IF rsp.get_smartphone ( i_esn => io_esn) <> 0
       AND sa.device_util_pkg.is_hotspots(io_esn) <> 0
       AND sa.device_util_pkg.is_tablet(io_esn) <> 0
       -- Added by Juda Pena for Brand X project to bypass this error for account group brands
       AND NVL(sa.brand_x_pkg.get_shared_group_flag ( ip_bus_org_id => est.bus_org_id),'N') = 'N'
       -- CR32539 To exclude SL data cards AR
       AND NOT rsp.is_sl_red_card_compatible ( i_red_code => i_red_card )
    THEN
      --
      c_msgnum := '420';
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,c_msgnum ,'ENGLISH');
      GOTO package_end;
    END IF;
  END IF;

  -- Call the member function to get the card part class vas name
  est := est.get_vas_part_class_name ( i_part_class_objid => pn.part_class_objid );

  DBMS_OUTPUT.PUT_LINE('est.vas_part_class_name         => ' || est.vas_part_class_name );
  DBMS_OUTPUT.PUT_LINE('est.esn_part_inst_status        => ' || est.esn_part_inst_status );
  DBMS_OUTPUT.PUT_LINE('est.bus_org_id                  => ' || est.bus_org_id );

  IF est.vas_part_class_name IS NOT NULL AND
     est.esn_part_inst_status != '52' AND
     est.bus_org_id IN ('TELCEL','SIMPLE_MOBILE')
  THEN
    c_msgnum := '420';
    c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,c_msgnum ,'ENGLISH');
    GOTO package_end;
  END IF;

  IF est.vas_part_class_name IS NOT NULL AND
     est.esn_part_inst_status = '52' AND
     est.bus_org_id IN ('TELCEL','SIMPLE_MOBILE')
  THEN
    c_msgnum := '421';
    c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,c_msgnum ,'ENGLISH');
    GOTO package_end;
  END IF;

  -- Call member function to determine if the card is compatible with the phone
  est := est.is_card_compatible_with_esn ( i_esn_part_class_objid  => est.part_class_objid,
                                           i_card_part_class_objid => pn.part_class_objid );

  DBMS_OUTPUT.PUT_LINE('est.vas_part_class_name         => ' || est.vas_part_class_name );
  DBMS_OUTPUT.PUT_LINE('est.bus_org_flow                => ' || est.bus_org_flow );
  DBMS_OUTPUT.PUT_LINE('est.card_esn_compatibility_flag => ' || est.card_esn_compatibility_flag );

  IF est.vas_part_class_name IS NULL AND
     i_sourcesystem <> 'IVR' AND
     est.bus_org_flow in ('3','2')
  THEN
    IF est.card_esn_compatibility_flag = 'N' THEN
      c_msgnum := '420';
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG' ,c_msgnum ,'ENGLISH');
      GOTO package_end;
    END IF;
  ELSIF i_sourcesystem = 'IVR' and est.vas_part_class_name IS NULL and est.bus_org_flow in ('2','3')
  THEN
    IF est.card_esn_compatibility_flag = 'N' THEN
      c_msgnum := '403';
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
      GOTO package_end;
    END IF;
  -- for tracfone datacard beging used on TF PPE devices CR34567
  ELSIF est.vas_part_class_name IS NULL  and est.bus_org_flow in ('1')and  is_data_card (pn.card_part_number) AND
        est.non_ppe_flag = '0'
  THEN
    IF est.card_esn_compatibility_flag = 'N' THEN
      c_msgnum := '403';
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
      GOTO package_end;
    END IF;

  ELSIF est.vas_part_class_name IS NULL AND
        est.bus_org_flow in ('1') AND
        is_text_card (pn.card_part_number) AND
        est.non_ppe_flag = '0'
  THEN
    IF est.card_esn_compatibility_flag = 'N' THEN
      c_msgnum := '403';
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
      GOTO package_end;
    END IF;
  --
  ELSIF est.vas_part_class_name IS NULL and est.bus_org_flow in ('1') AND
        is_smartphone_red_card ( pn.card_part_number ) AND
        est.non_ppe_flag = '0'
  THEN
    c_msgnum := '403';
    c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
    GOTO package_end;
  END IF;

  IF ((c_part_inst_status = '280') AND (i_sourcesystem = 'HANDSET')) THEN
    IF est.response LIKE '%SUCCESS%' THEN
      IF (est.dll < 22) THEN
        c_error_pin := 'Please visit our website at tracfone.com or contact Customer Care to add this PIN';
      ELSE
        c_error_pin := 'Visit our website at tracfone.com or call Customer Care to add this PIN';
      END IF;
    END IF;

    c_msgnum := '417';
    c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum ,'ENGLISH');
    GOTO package_end;
  END IF;

  IF (c_part_inst_status = '281') THEN
    c_error_pin := 'ERROR: EXPIRED SETTLEMENT BENEFIT PIN';
    c_msgnum := '419';
    c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'    ,c_msgnum  ,'ENGLISH');
    GOTO package_end;
  END IF;

  -- If it is autopay, identify as such
  IF (UPPER(TRIM(pn.card_type)) = 'AUTOPAY') THEN
    c_msgnum := '412';
    c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG'   ,c_msgnum ,'ENGLISH');
    GOTO package_end;
  END IF;

  IF (pn.part_type = 'LLPAID') THEN
    BEGIN
      SELECT COUNT(1)
      INTO   pn.is_esn_enrolled_flag
      FROM   x_program_enrolled pe
      WHERE  pe.x_esn = io_esn
      AND    pe.x_enrollment_status = 'ENROLLED'
      AND    pe.x_sourcesystem = 'VMBC';
     EXCEPTION
       WHEN others THEN
         pn.is_esn_enrolled_flag := 0;
    END;

    IF pn.is_esn_enrolled_flag > 0 THEN
      c_error_pin := 'ERROR: THIS IS A LIFE LINE PIN';
      c_msgnum := 433;
      c_msgstr := sa.get_code_fun('VALIDATE_RED_CARD_PKG',c_msgnum,'ENGLISH');
    ELSE
      GOTO package_end;
    END IF;

  END IF;

  --
  <<package_end>>
  --

  -- set the units and days
  n_units := NVL(n_units,0);
  n_days := NVL(n_days,0);

  -- set the message numeric value
  c_msgnum := NVL(c_msgnum,'0');

  -- Did we insert a GTT PART INST (dummy) record?
  IF n_gtt_part_inst_objid IS NOT NULL THEN
    -- Remove the GTT PART INST record
    est.response := est.del_gtt_part_inst ( i_gtt_part_inst_objid => n_gtt_part_inst_objid );
    --
  END IF;

  -- Did we insert a GTT POSA CARD (dummy) record?
  IF n_gtt_posa_card_objid IS NOT NULL THEN
    -- Remove the GTT PART INST record
    est.response := est.del_gtt_posa_card ( i_gtt_posa_card_objid => n_gtt_posa_card_objid );
    --
  END IF;

  -- shared group validations

  -- get the attributes related to the red card
  rc := rc.retrieve_gtt_pin ( i_red_card => i_red_card );

  IF rc.response NOT LIKE '%SUCCESS%' THEN
    -- get the attributes related to the red card
    rc := sa.red_card_type ();
    rc := rc.retrieve_pin ( i_red_card => i_red_card );
  END IF;

  DBMS_OUTPUT.PUT_LINE('rc.group_available_capacity     => ' || rc.group_available_capacity);

  o_available_capacity := NVL(o_available_capacity,rc.group_available_capacity);

  cst.brand_shared_group_flag := cst.get_shared_group_flag ( i_bus_org_id => i_bus_org_id );

  -- validations for shared group plans
  IF cst.brand_shared_group_flag = 'Y' THEN

    IF i_red_card IS NOT NULL THEN
      -- validate the red card
      IF rc.response NOT LIKE '%SUCCESS%' THEN
        --
        c_msgnum := '1648';
        c_msgstr := 'PIN IS NOT FOUND';
      --  GOTO package_end; -- CR47265 commented
      --
      END IF;
      -- validate the brand of the card
      IF rc.bus_org_id <> i_bus_org_id THEN
        c_msgnum := '1647';
        c_msgstr := rc.bus_org_id || ' PIN IS NOT COMPATIBLE WITH THE PROVIDED BRAND (' || i_bus_org_id || ') ';
        -- exit the program
        --GOTO package_end; -- CR47265 commented
      END IF;
    --
    END IF; -- IF i_red_card IS NOT NULL

    -- if ESN is not passed
    IF io_esn IS NULL THEN
      -- Pick a random dummy ESN and SERVICE_PLAN_ID
      rc.esn := rct.choose_random_esn ( i_red_card => i_red_card);
      -- Set a flag to Y when a dummy ESN was randomly picked
      c_dummy_esn_flag := 'Y';
      -- set esn
      io_esn := rc.esn;
    END IF;

    -- if the ESN was passed as an input parameter (not a chosen dummy ESN)
    IF ( c_dummy_esn_flag = 'N' ) THEN

      -- Validation: For all ESNs part of the group. If any ESN fails the compatibility the complete validation fails
      -- Get all the active members of a group
      FOR i IN ( SELECT *
                 FROM   x_account_group_member
                 WHERE  account_group_id IN ( SELECT account_group_id
                                              FROM   sa.x_account_group_member
                                              WHERE  esn = io_esn
                                              AND    UPPER(status) <> 'EXPIRED'
                                            )
                 AND    UPPER(status) <> 'EXPIRED'
               )
      LOOP
        -- Get the group service plan and esn compatibility
        rc.esn_grp_compatibility_flag := rct.is_esn_compatible_with_group ( i_account_group_objid => i.account_group_id,
                                                                            i_esn                 => i.esn);
        -- Validate group service plan and esn compatibility
        IF rc.esn_grp_compatibility_flag = 'N' THEN
          -- Overwrite message with service plan incompatibility
          c_msgnum := '1591';
          c_msgstr := 'ESN IS NOT COMPATIBLE WITH THE SERVICE PLAN';
          -- exit the program
          --GOTO package_end; -- CR47265 commented
        END IF;
      END LOOP;

      -- The total count of active ESNs in the group cannot be greater than the number of lines allowed by the provided PIN's service plan/number of lines.
      IF sa.brand_x_pkg.valid_number_of_lines ( ip_esn                => io_esn,
                                             ip_red_card_code      => i_red_card,
                                             op_available_capacity => o_available_capacity ) = 'N' AND
        -- Validation should occur only for NON Add-On Data Dards (since Add-Ons are a real service plan)
        ( rc.service_plan_group <> 'ADD_ON_DATA' OR rc.service_plan_group IS NULL)
      THEN
        -- Overwrite message with service plan incompatibility
        c_msgnum := '1592';
        c_msgstr := 'NUMBER OF ACTIVE ESNS IN THE GROUP IS GREATER THAN THE NUMBER OF LINES ALLOWED FOR THE PIN';
        -- exit the program
        -- GOTO package_end;-- CR47265 commented
      END IF;
      --
      -- If any of the active members of a group has a card in queue and the queued pin service plan/number of lines does not match the passed red card service plan/number of lines
      IF sa.brand_x_pkg.valid_queued_red_cards ( ip_esn           => io_esn,
                                                 ip_red_card_code => i_red_card ) = 'N' AND
         -- Validation should occur only for NON Add-On Data Dards (since Add-Ons are a real service plan)
        ( rc.service_plan_group <> 'ADD_ON_DATA' OR rc.service_plan_group IS NULL)
      THEN
        -- Overwrite message with service plan incompatibility
        c_msgnum := '1593';
        c_msgstr := 'QUEUED PIN SERVICE PLAN/NUMBER OF LINES DOES NOT MATCH THE PROVIDED PIN SERVICE PLAN/NUMBER OF LINES';
        -- exit the program
        -- GOTO package_end; -- CR47265 commented
      END IF;
    END IF;

    -- instantiate esn value in customer type
    ct := sa.customer_type ( i_esn => io_esn );

    -- retrieve the esn information
    cst := ct.retrieve;

    -- reset ct customer type
    ct := sa.customer_type ();

    -- call the retrieve method to get group details
    cstg := ct.retrieve_group (i_account_group_objid => cst.account_group_objid);

    -- Leased ESNs are not allowed to redeem a pin with a different service plan
    IF i_client_id IS NOT NULL THEN
      IF cst.service_plan_objid           != rc.service_plan_objid AND
         UPPER(i_client_id)               != 'SMARTPAYLEASE'       AND
         cstg.group_leased_flag           != 'N'                   AND
         NVL(rc.service_plan_group,'ANY') != 'ADD_ON_DATA'
      THEN
        --
        c_msgnum := '1652';
        c_msgstr := 'SERVICE PLAN CANNOT BE CHANGED FOR LEASED ESNS';
        --
      END IF;
    END IF;
    --

    -- Get the payment pending group objid in stage table
    n_payment_pending_group_objid := sa.brand_x_pkg.get_pmt_pending_acc_grp_id ( ip_red_card_code => i_red_card );

  END IF; -- IF cst.brand_shared_group_flag = 'Y'


  -- CR57903 Change starts :  This is to sync logic with brand_x_pkg

  IF NVL(get_serv_plan_value (ip_plan_objid    => rc.service_plan_objid,
                              ip_property_name => 'NUMBER_OF_LINES'   ),   1) = 0
     AND
     NVL(get_serv_plan_value (ip_plan_objid    => rc.service_plan_objid,
                              ip_property_name => 'SERVICE_PLAN_GROUP'),'**')
                              IN( 'ADD_ON_ILD','ADD_ON_DATA')
     AND cst.get_esn_part_inst_status (i_esn   =>  io_esn) <> '52'
  THEN
      c_msgnum := '1654';
      c_msgstr := 'PIN IS NOT COMPATIBLE FOR ACTIVATIONS';
  END IF;

  -- CR57903 Change ends


  --
  IF o_available_capacity IS NULL THEN
    o_available_capacity := cstg.group_available_capacity;
  END IF;

  -- end shared group validations

  -- return the results in ref cursor
  OPEN o_refcursor
  FOR
  SELECT c_part_inst_status              AS strstatus,
         n_units                         AS intunits,
         n_days                          AS intdays,
         pn.card_brand                   AS strcardbrand,
         c_msgnum                        AS strmsgnum,
         c_msgstr                        AS strmsgstr,
         c_error_pin                     AS strerrorpin,
         pn.part_number_description      AS description,
         pn.card_part_number             AS partnumber,
         pn.card_type                    AS cardtype,
         pn.part_type                    AS parttype,
         pn.web_card_desc                AS x_web_card_desc,
         pn.sp_web_card_desc             AS x_sp_web_card_desc,
         pn.ild_type                     AS x_ild_type,
         pn.group_allowed_lines          AS number_of_lines,
         rc.service_plan_objid           AS service_plan_id,
         n_payment_pending_group_objid   AS payment_pending_group_id,
         cstg.group_program_enrolled_id  AS program_enrolled_id ,
         rc.application_req_num          AS application_req_num
  FROM   DUAL;

  --
  o_err_code := 0;
  o_err_msg  := 'Success';

  DBMS_OUTPUT.PUT_LINE('ENDED THE VALIDATE PRE POSA');

 EXCEPTION
   WHEN others THEN
     DBMS_OUTPUT.PUT_LINE('ERROR IN VALIDATE PRE POSA: ' || SQLERRM);

     --
     c_error_str := 'i_red_card: '||i_red_card ||' i_smp_number: ' || i_smp_number || ' i_sourcesystem: ' || i_sourcesystem ||' io_esn: ' || io_esn ||' c_msgnum: ' || c_msgnum || ' c_msgstr: ' || c_msgstr;
     --
     ota_util_pkg.err_log ( p_action       => 'validate_red_card_pkg',
                            p_error_date   => SYSDATE,
                            p_key          => i_red_card,
                            p_program_name => 'validate_red_card_pkg.validate_pre_posa',
                            p_error_text   => c_error_str );

     RAISE_APPLICATION_ERROR ( -20000, SQLCODE || SQLERRM || ' VALIDATE_PRE_POSA');

END validate_pre_posa;

--New function added for CR47988 IS_SL_RED_PN
FUNCTION IS_SL_RED_PN
                    (
                     p_part_num table_part_num.part_number%TYPE
                    )
RETURN VARCHAR2
IS
 v_count_pn NUMBER := 0;
BEGIN --{
-- Part class starts with SL%
 SELECT COUNT(1)
 INTO   v_count_pn
 FROM
     (
      SELECT 1 --DISTINCT pn.part_number, pc.name, pn.description
      FROM   table_part_num pn, table_parT_class pc
      WHERE  pc.name             like 'SL%'
      AND    part_num2part_class = pc.objid
      AND    pn.domain           = 'REDEMPTION CARDS'
      AND    pn.part_number      = p_part_num
      UNION
      -- Service plan is SAFELINK
      SELECT 1 --DISTINCT PN.PART_NUMBER, pc.name, pn.description
      FROM   x_serviceplanfeaturevalue_def spfvdef,
             x_serviceplanfeature_value spfv,
             x_service_plan_feature spf,
             x_serviceplanfeaturevalue_def spfvdef2,
             x_service_plan sp,
             mtm_partclass_x_spf_value_def mtm,
             table_part_class pc ,
             table_part_num pn,
             table_bus_org bo
      WHERE  1=1
      AND    spfvdef.value_name            = 'SUPPORTED PART CLASS'
      AND    spf.sp_feature2service_plan   = sp.objid
      AND    mtm.spfeaturevalue_def_id     = spfvdef2.objid
      AND    spf.sp_feature2rest_value_def = spfvdef.objid
      AND    mtm.part_class_id             = pc.objid
      AND    spf.objid                     = spfv.spf_value2spf
      AND    pc.objid                      = pn.part_num2part_class
      AND    spfvdef2.objid                = spfv.value_ref
      AND    pn.domain                     = 'REDEMPTION CARDS'
      AND    part_num2bus_org              = bo.objid
      AND    UPPER(mkt_name)               LIKE '%SAFELINK%'
      AND    pn.part_number                = p_part_num
     );

   IF v_count_pn > 0
   THEN --{
    RETURN 'Y';
   ELSE
    RETURN 'N';
   END IF; --}

EXCEPTION
WHEN OTHERS THEN
 RETURN 'N';
END IS_SL_RED_PN; --}

--New function added for CR47988 is_safelink
FUNCTION is_safelink(p_esn IN VARCHAR2,
                     p_min IN VARCHAR2)
RETURN VARCHAR2
IS
 l_is_safelink VARCHAR2(2) := 'N'; --CR47757
BEGIN --{
 SELECT  DECODE(COUNT(*),0,'N','Y')
 INTO    l_is_safelink
 FROM    sa.x_sl_currentvals   cur,
         sa.table_site_part    tsp,
         sa.x_program_enrolled pe,
         sa.x_program_parameters xpp,
         sa.table_bus_org tbo
 WHERE   tsp.x_service_id         = pe.x_esn
 AND     tsp.x_service_id         = cur.x_current_esn
 --AND     pe.x_enrollment_status   = 'ENROLLED'
 AND     (
         cur.x_current_esn       = p_esn
         OR
         tsp.x_min               = p_min
        )
 AND     (
           (pe.x_enrollment_status = 'ENROLLED')
           OR
           (tbo.org_id = 'NET10' AND pe.x_enrollment_status   IN ('READYTOREENROLL', 'DEENROLLED') AND SYSDATE  - (X_UPDATE_STAMP) < 31)
           OR
           (tbo.org_id = 'TRACFONE' AND pe.x_enrollment_status   IN ('READYTOREENROLL', 'DEENROLLED'))
         )
 -- AND     UPPER(tsp.part_status)   = 'ACTIVE'  -- CR51712 Defect.30683, part_status non-important if ESN in currentvals
 AND     xpp.x_prog_class         = 'LIFELINE'
 AND     pgm_enroll2pgm_parameter = xpp.objid
 AND     tbo.objid                = xpp.prog_param2bus_org
 AND     ROWNUM = 1;

 RETURN l_is_safelink;

EXCEPTION
WHEN OTHERS THEN
 l_is_safelink := 'N';
 RETURN l_is_safelink;
END is_safelink; --}


--to check the addon is applicable to the given esn or not if yes it returns N else Y
FUNCTION is_addon_exclusion (i_esn IN VARCHAR2) RETURN VARCHAR2
is
  addon_exclusion_flag varchar2(1) := 'Y';
BEGIN
  --CR52873 TracFone check should only be done by device_type
  IF sa.customer_info.get_bus_org_id(i_esn => i_esn) = 'TRACFONE'
  THEN
    IF sa.get_device_type(p_esn => i_esn) IN ('SMARTPHONE','BYOP')
    THEN
      addon_exclusion_flag := 'N';
    END IF;
  ELSE
    SELECT 'N'
      INTO addon_exclusion_flag
    FROM   dual
    WHERE  EXISTS (SELECT 1
                   FROM   sa.table_site_part tsp,
                          sa.x_service_plan_site_part spsp,
                          service_plan_feat_pivot_mv spmv
                   WHERE  tsp.objid                      = spsp.table_site_part_id
                     AND  spmv.service_plan_objid        = spsp.x_service_plan_id
                     AND  tsp.x_service_id               = i_esn
                     AND  NVL(addon_compatible_flag,'N') = 'Y'
                     AND  tsp.part_status                = 'Active');
  END IF;

  RETURN addon_exclusion_flag;

EXCEPTION
WHEN OTHERS THEN
  RETURN addon_exclusion_flag;
END is_addon_exclusion;

END;
/