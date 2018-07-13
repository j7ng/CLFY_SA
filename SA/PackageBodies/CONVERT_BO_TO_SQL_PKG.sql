CREATE OR REPLACE PACKAGE BODY sa."CONVERT_BO_TO_SQL_PKG"
AS
 /*****************************************************************
 * Package Body Name: SA.convert_bo_to_sql_pkg
 * Purpose : To convert CBO methods to PLSQL procedures - Memory Leak Project
 *
 * Platform : Oracle 8.0.6 and newer versions.
 * Created by : Vani Adapa
 * Date : 10/21/2005
 *
 * Frequency : All weekdays
 * History
 * REVISIONS VERSION DATE WHO PURPOSE
 * -------------------------------------------------------------
 * 1.0 10/21/2005 VAdapa Initial Revision (CR4640)
 * 1.1 10/21/2005 GPintado Added extra parameter sp_create_call_trans
 * 1.2 10/29/2005 VAdapa Added header information
 * 1.3 11/04/2005 VAdapa Removed the line status update to '13' from OTACompleteTransaction
 * 1.4 11/07/2005 VAdapa Removed the line status update to '13' from OTACompleteTransaction
 * 1.5 11/07/05 VAdapa Checked in with the right revision
 * 1.6 11/21/2005 CL / VA Modified CREATESITEPART procedure
 * 1.7 11/30/2005 VAdapa Modified CLEARREDCARDS procedure to
 * delete from table_part_inst and red_card_temp tables (CR4811)
 * 1.8 11/30/2005 CL Modified sp_create_call_trans procedure
 * 1.9 11/30/2005 CL/VA Modified sp_create_call_trans procedure (added a new IN parameter)
 * 1.10 11/30/2005 VA Checked in with the correct code and revision
 * 1.11 12/01/2005 VA Created a replica of SP_CREATE_CALL_TRANS procedure with more parameters
 * 1.12 12/07/2005 CL Modifed the procedure UPDATEFLAGS
 * 1.13 12/07/2005 NG/VA Fix for 1.12
 * 1.13.1.0 02/17/2006 VA Fix TO REMOVE DUPLICATE PIN ENTRIES
 * 1.13.1.1 02/20/2006 VA Modified the header to note the right PVCS revision
 * 1.13.1.2 02/20/2006 CL Added code to clear the tables
 * 1.13.1.3 02/23/2006 NG Fix to prevent simultaneous redemption
 * 1.13.1.4 02/23/2006 VA/NG Fix to prevent blank cards during redemption
 * 1.13.1.5 02/27/2006 NG Fix to allow no cards during comp units redemption
 * 1.15 03/13/2006 CL CR4811 changes
 * 1.16 03/14/06 CL CR4811 changes
 * 1.17 03/16/06 CL CR4811 changes
 * 1.18/1.19 04/03/06 IC CR4981_4982 Modified procedure PreProcess_redem_cards to find max value of x_conversion
 * 1.20 05/17/06 VA Same version
 * 1.21 05/27/06 NG New Parameter for Create Clarify Case
 * 1.22 05/27/06 NG New Parameter for Create Clarify Case
 * 1.23 06/05/06 VA/NG Merge CR5298
 /* 1.17.1.1 06/08/06 va CR5349 - Fix for OPEN_CURSORS
 /* 1.26 06/15/06 VA CR5282 changes
 /* 1.27 /1.28 /1.29 09/11/06 VA CR5581/CR5582 -Bundle for Wal-mart / SAM's
 /* 1.30 10/05/06 CL CR5639 - OTA Selfhealing adjustments
 /* 1.31 10/06/06 CL CR5600 - Clicks Update issue with C139 Phones during Activations
 /* 1.32 10/16/06 VA CR5639-1 - OTA Selfhealing adjustments-part 2
 /* 1.33 10/20/06 VA Removed CR5600
 /* 1.34 10/20/06 VA Added CR5600
 /* 1.35 11/02/06 VA CR5694 - Reactivations with clear tank flag
 /* 1.36 11/15/06 IC CR5687 Modifications to update flags
 /* 1.36.1.0 01/22/07 TZ CR5854 Add condition to where clause when delete from the table_x_pending_redemption.
 Filter by site_part and call_trans.
 /* 1.36.1.1 02/23/07 VA CR5848 Return totoal access days (preprocess_redem_cards)
 /*1.36.1.2 03/05/07 VA CR5848 - changed the package spec
 /*1.40 04/11/07 TZ CR5150 - change the name field name.
 /* 1.41 05/15/07 VA CR6250 - Logic added to enroll the esn to DM program during card processing
 /* 1.41.1.0 06/13/07 CI CR6178 - logic for Wagner per Natalio, in two cursors, added 'Wagner valid' 280
 /* 1.44 06/13/07 CI CR6178 - added 280 status to cursors having 42, per Natalio, from clfydb1
 /* 1.45 06/13/07 IC CR5728 - added condition to table_x_part_request query
 /* 1.46 07/24/07 IC - merge
 /* 1.47 08/01/07 CL - fix to slow cursor
 /* 1.48 08/02/07 IC - review
 /* 1.49 08/29/07 IC - new ota features (CR6292)
 /* 1.50 09/10/07 VA - Fix for Cr6292
 /* 1.51 06/02/08 IC - PE203 Promo Engin Project Replace X_Promotion_Prefer_Site with Table_x_promotion_addl_info
 /* 1.52.1 10/15/08 IC - CR7984
 /* 1.52.2 10/27/08 YM - CR7984 added new procedure getdefaultpromo_new and merge with prod replace table_x_promotion_addl_info per
 /* x_promotion_addl_info into cursor promo_curs
 *
 1.2.1.0.1 11/13/08 VA - CR7814 change was not released in 2008 , the same fix was required for
 CR7899 (otacodeaccepted - added order by clause to the
 table_x_code_hist_temp cursor)
 1.2.1.0.1.1 03/18/09 VA CR8406 - corrected mis-spelled code type MO_Address
 1.2.1.0.1.2 03/30/09 sbabu CR8507 TF_REL_35. CompleteTranasaction cbo removal.
 1.8.1.0 09/15/09 NGuada CR11671 (Handsets changes to get_default_click_plan function)
 /* 1.9-1.10 08/27/09 NGuada BRAND_SEP Separate the Brand and Source System
 /* 1.11-.13 09/17/09 NGuada BRAND_SEP MERGE CR11671 and CR11677
 /* 1.14 11/23/09 NGuada CR11593
 /* CVS STRUCTURE
 /* --------------
 /* 1.2 04/26/10 NGuada CR10777 Zip code activation phase 1 TMO
 /* Modify cursor check_no_inv_carr_curs to use new table CARRIERSIMPREF
 /* 1.3-4 05/04/10 CLindner CR10777 remove table_x_account
 /* 1.5 07/29/2010 Ymillan CR13940 add input parameter for sp_create_call_trans_2
 /* 1.8 11/24/2010 KACOSTA CR14799 In sp_create_call_trans_2 procedure
 /* if the x_iccid from table_site_part is null
 /* then retrieve it from table_part_inst
 /* 1. 9 06/03/2011 ICanavan CR16344 / CR16379 MODIFY FUNCTION CHECKMEMBERESN added X3XMN_GRP
 /* 1.10-11 06/17/2011 ICanavan CR16344 separated triple and double minute promo inserts
 /* 1.20 04/04/13 CLindner CR22451 Simple Mobile System Integration - WEBCSR
 /* 1.96 02/10/2017 sgangineni CR47564 - WFM Changes - Modified the procedure preprocess_redem_cards to get
 /*                                                     service days from table_x_call_trans_ext for WFM esns
 /* *******************************************************************************/
 --
 --********************************************************************************
 --$RCSfile: CONVERT_BO_TO_SQL_PKG.sql,v $
 --$Revision: 1.114 $
 --$Author: hviswanathan $
 --$Date: 2017/11/30 16:16:36 $
  --$ $Log: CONVERT_BO_TO_SQL_PKG.sql,v $
  --$ Revision 1.114  2017/11/30 16:16:36  hviswanathan
  --$ Code changes for CR55074
  --$
  --$ Revision 1.113  2017/11/16 22:33:54  hviswanathan
  --$
  --$ New logic added for CR55074, to avoid WFM queue card delivery errors for service days not found
  --$
  --$ Revision 1.112  2017/11/16 18:57:47  hviswanathan
  --$ New logic added to skip deletion of lines when MIN and SMP matches
  --$
  --$ Revision 1.111  2017/10/18 16:13:06  sgangineni
  --$ CR54147 - Fix for defect 31828
  --$
  --$ Revision 1.110  2017/10/16 23:31:22  sgangineni
  --$ CR54147 - Modified call to sp_get_pin_service_plan_id
  --$
  --$ Revision 1.109  2017/10/16 22:40:49  sgangineni
  --$ CR54147 - Modified sp_set_call_trans_ext to calculate LIFELINE discount amount and
  --$  to populate in x_part_inst_ext table
  --$
  --$ Revision 1.108  2017/05/10 19:10:44  nmuthukkaruppan
  --$ CR49808 - Safelink Assist Changes
  --$
  --$ Revision 1.107  2017/05/10 15:40:25  nmuthukkaruppan
  --$ CR49808 - Saflink Assist Changes
  --$
  --$ Revision 1.106  2017/04/11 13:37:04  sgangineni
  --$ CR48944 - Modified the order of new input params in sp_set_call_trans_ext
  --$
  --$ Revision 1.105  2017/04/05 18:19:06  sgangineni
  --$ CR47564 - WFM code merge with Rel_854 changes
  --$
  --$ Revision 1.103  2017/03/23 15:51:25  sgangineni
  --$ CR47564 - Changes to store bucket id list in table_x_call_trans_ext
  --$
  --$ Revision 1.102  2017/03/17 18:47:29  sraman
  --$ CR47564- Bug Fix
  --$
  --$ Revision 1.100  2017/03/08 00:47:21  sgangineni
  --$ CR47564 - Changes to store discount code list in x_part_inst_ext table
  --$
  --$ Revision 1.99  2017/03/01 23:41:37  sgangineni
  --$ CR47564 -WFM Changes
  --$
  --$ Revision 1.98  2017/03/01 01:21:02  sgangineni
  --$ CR47564 - WFM Changes
  --$
  --$ Revision 1.97  2017/03/01 00:59:26  sgangineni
  --$ CR47564 - WFM Changes
  --$
  --$ Revision 1.96  2017/02/27 17:00:39  sgangineni
  --$ CR47564 - WFM Changes - Modified the code to get service days or pin redeem days using
  --$  customer info package functions
  --$
  --$ Revision 1.95  2017/01/11 21:58:29  vlaad
  --$ Updated INTL flag
  --$
  --$ Revision 1.92  2016/12/12 18:03:55  rpednekar
  --$ CR45740 - Success msg for data saver.
  --$
  --$ Revision 1.91  2016/12/08 15:02:09  rpednekar
  --$ CR45740
  --$
  --$ Revision 1.90  2016/12/07 22:17:50  rpednekar
  --$ CR45740
  --$
  --$ Revision 1.89  2016/12/01 17:19:29  rpednekar
  --$ CR45740 - New procedures
  --$
  --$ Revision 1.88  2016/05/17 10:39:51  sethiraj
  --$ CR37756 - Merged with production copy 05-13-2016
  --$
  --$ Revision 1.87  2016/05/05 16:04:27  vnainar
  --$ CR42560 pay_go_curs rec set to null for multiple cards
  --$
  --$ Revision 1.85  2016/03/14 18:49:17  smeganathan
  --$ CR31456 merged the code change
  --$
  --$ Revision 1.84  2016/03/08 16:45:32  vnainar
  --$ CR41433 brand added for safelink check in preprocess redem cards
  --$
  --$ Revision 1.83  2016/03/05 18:50:54  vnainar
  --$ CR41433 preprocess_redem_cards updated for SL redemption
  --$
  --$ Revision 1.82  2016/03/04 18:34:07  vnainar
  --$ CR41433 code fix done to handle multiple redemption cards for safelink
  --$
  --$ Revision 1.81  2016/03/04 13:19:44  snulu
  --$ Changes made as part of CR41433
  --$
  --$ Revision 1.78  2016/03/02 20:07:59  vyegnamurthy
  --$ CR41433 SL VZ upgrades
  --$
  --$ Revision 1.76  2015/12/14 18:29:25  vnainar
  --$ CR38927 merged with PROD version
  --$
  --$ Revision 1.65  2015/10/15 18:26:12  skota
  --$ modifyied prerprocess redeem cards to append the units
  --$
  --$ Revision 1.64  2015/10/14 22:11:19  skota
  --$ modified
  --$
  --$ Revision 1.63  2015/10/13 22:54:54  skota
  --$ added block for new paygo cards
  --$
  --$ Revision 1.62  2015/09/02 21:25:51  skota
  --$ modified
  --$
  --$ Revision 1.61  2015/09/02 21:09:15  skota
  --$ modified
  --$
  --$ Revision 1.60  2015/09/02 20:00:58  skota
  --$ modified
  --$
  --$ Revision 1.59  2015/08/27 15:48:22  ddevaraj
  --$ For CR37027
  --$
  --$ Revision 1.58  2015/08/19 21:36:28  ddevaraj
  --$ For CR37027
  --$
  --$ Revision 1.57 2015/04/23 18:42:35 jarza
  --$ Handling sms units if it is set to NA in service plan.
  --$
  --$ Revision 1.54 2015/04/16 12:57:41 vmadhawnadella
  --$ ADD LOGIC FOR $10.00 TEXT ONLY CARD.
  --$
  --$ Revision 1.52 2015/04/14 18:46:25 vmadhawnadella
  --$ ADD LOGIC FOR $10.00 TEXT ONLY CARD.
  --$
  --$ Revision 1.51 2015/02/13 17:38:02 jpena
  --$ Added logic by Juda Pena to Fix SP_SET_CALL_TRANS_EXT to update service plan from the site part table for the Brand X release.
  --$
  --$ Revision 1.48 2015/01/22 22:36:20 jpena
  --$ Changes for Brand X
  --$
  --$ Revision 1.45 2014/10/22 16:06:21 cpannala
  --$ Cr24865 changes for pragma
  --$
  --$ Revision 1.36 2014/07/16 20:26:56 clinder
  --$ CR27185
  --$
  --$ Revision 1.33 2014/07/07 16:13:09 clinder
  --$ CR27185
  --$
  --$ Revision 1.31 2014/03/18 21:57:57 mmunoz
  --$ Change in preprocess_redem_cards to fix defect : Wrong expiration date and null units for TF part number activations using workforce pins
  --$
  --$ Revision 1.30 2013/09/10 14:28:34 mvadlapally
  --$ CR23513 TF Surepay
  --$
  --$ Revision 1.29 2013/09/09 18:01:44 mvadlapally
  --$ CR23513 TF Surepay modified preprocess to give data units in Kb
  --$
  --$ Revision 1.28 2013/08/29 21:56:20 mvadlapally
  --$ CR23513 TF Surepay
  --$
  --$ Revision 1.27 2013/08/21 18:48:36 mvadlapally
  --$ CR23513 TF Surepay
  --$
  --$ Revision 1.20 2013/04/04 15:48:37 ymillan
  --$ CR22451 TAS simple mobile
  --$
  --$ Revision 1.19 2012/07/23 14:18:53 kacosta
  --$ CR20864 Add Column to Promo Hist Table
  --$
  --$ Revision 1.18  2012/06/25 17:46:15  kacosta
  --$ CR21051 Missing Part Number for LINES
  --$ CR21060 Update SIM status to Active.
  --$
  --$ Revision 1.17  2012/06/25 17:39:27  kacosta
  --$ CR20864 Add Column to Promo Hist Table
  --$
  --$ Revision 1.12  2012/04/03 14:31:30  kacosta
  --$ CR16379 Triple Minutes Cards
  --$
  --$
  --********************************************************************************
  --
FUNCTION checkmemberesn(
    p_esn IN VARCHAR2)
  RETURN VARCHAR2
IS
  CURSOR c_esn_grp
  IS
    SELECT pg.group_name ,
      gesn.x_start_date
    FROM table_x_promotion_group pg ,
      table_x_group2esn gesn ,
      table_part_inst pi
    WHERE gesn.groupesn2part_inst   = pi.objid
    AND gesn.groupesn2x_promo_group = pg.objid
    AND SYSDATE BETWEEN gesn.x_start_date AND gesn.x_end_date
    AND pg.group_name    IN ('ONEYRSRV_GRP' ,'RADIO365_GRP' ,'DBLMIN_GRP' ,'DBLMIN_ADVAN_GRP' ,'DBLMN_3390_GRP' ,'ANNUALPLAN' ,'X3XMN_GRP') -- CR16379 / CR16344
    AND pi.part_serial_no = p_esn
    AND pi.x_domain = 'PHONES' -- --CR55074: Code Changes;
    ORDER BY gesn.x_start_date DESC;
  CURSOR c_esn_trans
  IS
    SELECT ct.x_transact_date
    FROM sa.table_x_promotion pr ,
      table_x_promo_hist ph ,
      table_x_call_trans ct ,
      table_site_part sp
    WHERE sp.objid                = ct.call_trans2site_part
    AND ct.objid                  = ph.promo_hist2x_call_trans
    AND ph.promo_hist2x_promotion = pr.objid
    AND ct.x_transact_date       >= SYSDATE - 365
    AND pr.x_allow_stacking       = 1
    AND sp.part_status
      || ''            IN ('Active' ,'Inactive')
    AND sp.x_service_id = p_esn;
  r_esn_trans c_esn_trans%ROWTYPE;
  CURSOR c_ann_esn
  IS
    SELECT 1
    FROM table_x_red_card rc ,
      table_x_call_trans ct ,
      table_site_part sp
    WHERE 1                     = 1
    AND rc.x_access_days        = 365
    AND rc.x_result             = 'Completed'
    AND rc.red_card2call_trans  = ct.objid
    AND ct.call_trans2site_part = sp.objid
    AND ct.x_transact_date     >= (SYSDATE - 365)
    AND sp.part_status                    IN ('Active' ,'Inactive')
    AND sp.x_service_id         = p_esn;
  r_ann_esn c_ann_esn%ROWTYPE;
  l_promogrp_cnt        NUMBER       := 0;
  l_promo_cnt           NUMBER       := 0;
  l_esn_grp             VARCHAR2(10) := 'RG';
  l_grp_trans_date      DATE;
  l_calltrans_date      DATE;
  l_calltrans_promo_cnt NUMBER := 0;
BEGIN
  FOR r_esn_grp IN c_esn_grp
  LOOP
    l_esn_grp        := r_esn_grp.group_name;
    l_grp_trans_date := r_esn_grp.x_start_date;
    IF l_esn_grp IN ('DBLMIN_GRP' ,'DBLMIN_ADVAN_GRP' ,'DBLMN_3390_GRP') THEN
      l_esn_grp := 'DM';
      EXIT;
    ELSIF l_esn_grp IN ('X3XMN_GRP') THEN
      -- CR16379 / CR16344
      l_esn_grp := 'TM';
      EXIT;
    ELSIF l_esn_grp IN ('ANNUALPLAN') THEN
      l_esn_grp := 'AC';
      EXIT;
    ELSIF l_esn_grp IN ('ONEYRSRV_GRP' ,'RADIO365_GRP') THEN
      l_esn_grp := 'AE';
      EXIT;
    END IF;
  END LOOP;
  OPEN c_esn_trans;
  LOOP
    FETCH c_esn_trans INTO r_esn_trans;
    EXIT
  WHEN c_esn_trans%NOTFOUND;
    l_calltrans_date      := r_esn_trans.x_transact_date;
    l_calltrans_promo_cnt := l_calltrans_promo_cnt + 1;
  END LOOP;
  CLOSE c_esn_trans;
  IF l_grp_trans_date       IS NOT NULL THEN
    IF l_grp_trans_date      > l_calltrans_date AND LENGTH(l_esn_grp) > 0 THEN
      l_calltrans_promo_cnt := 0;
    END IF;
  END IF;
  IF l_calltrans_promo_cnt > 0 THEN
    l_esn_grp             := 'AE';
  END IF;
  IF l_esn_grp = 'RG' THEN
    OPEN c_ann_esn;
    FETCH c_ann_esn INTO r_ann_esn;
    IF c_ann_esn%FOUND THEN
      l_esn_grp := 'AC';
    END IF;
    CLOSE c_ann_esn;
  END IF;
  RETURN l_esn_grp;
EXCEPTION
WHEN OTHERS THEN
  l_esn_grp := 'RG';
  RETURN l_esn_grp;
END checkmemberesn;
--
PROCEDURE dynamicenrollment(
    p_esn           IN VARCHAR2 ,
    p_source_system IN VARCHAR2 )
IS
  op_result NUMBER;
  op_msg    VARCHAR2(1000);
  l_source  VARCHAR2(20) := p_source_system;
  CURSOR phone_curs
  IS
    SELECT pi.x_part_inst_status ,
      pi.x_creation_date ,
      pi.objid part_inst_objid ,
      pi.part_serial_no ,
      s.objid site_objid ,
      pn.*
    FROM table_part_num pn ,
      table_mod_level ml ,
      table_site s ,
      table_inv_bin ib ,
      table_part_inst pi
    WHERE 1               = 1
    AND pn.objid          = ml.part_info2part_num
    AND ml.objid          = pi.n_part_inst2part_mod
    AND s.site_id         = ib.bin_name
    AND ib.objid          = pi.part_inst2inv_bin
    AND pi.part_serial_no = p_esn
    AND pi.x_domain       = 'PHONES'; -- CR55074: Code Changes;
  phone_rec phone_curs%ROWTYPE;
  CURSOR phone_promo_curs ( c_part_num2promo IN NUMBER ,c_x_technology IN VARCHAR2 ,c_promo_type IN VARCHAR2 )
  IS
    SELECT *
    FROM table_x_promotion p
    WHERE 1                    = 1
    AND (p.x_promo_technology IS NULL
    OR p.x_promo_technology    = DECODE(c_x_technology ,'ANALOG' ,'ANALOG' ,'DIGITAL'))
    AND p.x_promo_type         = c_promo_type
    AND p.x_start_date        <= SYSDATE
    AND p.x_end_date          >= SYSDATE
    AND p.objid                = c_part_num2promo;
  phone_promo_rec phone_promo_curs%ROWTYPE;
  CURSOR promo_curs ( c_site_objid IN NUMBER ,c_x_technology IN VARCHAR2 )
  IS
    SELECT p.* ,
      pps.x_dll_allow
    FROM table_x_promotion p ,
      sa.x_promotion_addl_info pps
    WHERE 1                    = 1
    AND (p.x_promo_technology IS NULL
    OR p.x_promo_technology    = DECODE(c_x_technology ,'ANALOG' ,'ANALOG' ,'DIGITAL'))
    AND p.objid                = pps.x_promo_addl2x_promo
    AND p.x_promo_type         = 'Activation'
    AND p.x_start_date        <= SYSDATE
    AND p.x_end_date          >= SYSDATE
    AND pps.x_site_objid       = c_site_objid
    AND pps.x_active           = 'Y';
  CURSOR promo_exists_curs ( c_objid_part_inst IN NUMBER ,c_promo_code IN VARCHAR2 )
  IS
    SELECT 1
    FROM table_x_promotion p ,
      table_x_group2esn g2e
    WHERE 1 = 1
    AND p.x_promo_code
      || ''                    = c_promo_code
    AND p.objid                = g2e.groupesn2x_promotion
    AND g2e.groupesn2part_inst = c_objid_part_inst;
  promo_exists_rec promo_exists_curs%ROWTYPE;
  CURSOR promo_group_curs(c_objid IN NUMBER)
  IS
    SELECT pg.objid
    FROM table_x_promotion_group pg ,
      table_x_promotion_mtm pmtm
    WHERE 1                          = 1
    AND pg.objid                     = pmtm.x_promo_mtm2x_promo_group
    AND pmtm.x_promo_mtm2x_promotion = c_objid;
  promo_group_rec promo_group_curs%ROWTYPE;
  --CR5581/CR5582
  l_qual   NUMBER := 0;
  l_bigstr VARCHAR2(2000);
  l_smlstr VARCHAR2(2000);
  l_idxval NUMBER;
  l_cnt    NUMBER := 0;
TYPE dll_tab_type
IS
  TABLE OF table_part_num.x_dll%TYPE INDEX BY BINARY_INTEGER;
  l_dll_tab dll_tab_type;
  --CR5581/CR5582
BEGIN
  OPEN phone_curs;
  FETCH phone_curs INTO phone_rec;
  IF phone_curs%FOUND THEN
    --DEALER PROMO PART
    FOR promo_rec IN promo_curs(phone_rec.site_objid ,phone_rec.x_technology)
    LOOP
      --CR5581/CR5582
      l_qual := 0;
      --          l_bigstr := promo_rec.dll_allow;  230 Promo Engin
      l_bigstr                                                                                                                                 := promo_rec.x_dll_allow;
      IF (l_bigstr                                                                                                                             IS NULL OR l_bigstr = 'ALL') THEN
        IF phone_rec.x_creation_date BETWEEN promo_rec.x_ship_start_date AND promo_rec.x_ship_end_date AND NOT (promo_rec.x_refurbished_allowed = 0 AND phone_rec.x_part_inst_status = '150') THEN
          l_qual                                                                                                                               := 1;
        END IF;
      ELSE
        LOOP
          l_idxval   := INSTR(l_bigstr ,',');
          IF l_idxval = 0 THEN
            l_smlstr := l_bigstr;
          ELSE
            l_smlstr := SUBSTR(l_bigstr ,1 ,l_idxval - 1);
            l_bigstr := SUBSTR(l_bigstr ,l_idxval    + 1);
          END IF;
          l_dll_tab(l_cnt) := l_smlstr;
          l_cnt            := l_cnt + 1;
          EXIT
        WHEN l_idxval = 0;
        END LOOP;
        FOR i IN l_dll_tab.first .. l_dll_tab.last
        LOOP
          IF l_dll_tab(i) = phone_rec.x_dll AND phone_rec.x_part_inst_status = '50' THEN
            l_qual       := l_qual + 1;
          END IF;
        END LOOP;
      END IF;
      IF l_qual > 0 THEN
        --CR5581/CR5582
        dbms_output.put_line('tech and other conditions meet');
        OPEN promo_exists_curs(phone_rec.part_inst_objid ,promo_rec.x_promo_code);
        FETCH promo_exists_curs INTO promo_exists_rec;
        IF promo_exists_curs%NOTFOUND THEN
          dbms_output.put_line('promo_exists_curs%notfound');
          OPEN promo_group_curs(promo_rec.objid);
          FETCH promo_group_curs INTO promo_group_rec;
          IF promo_group_curs%FOUND THEN
            dbms_output.put_line('promo_group_curs%found');
            INSERT
            INTO table_x_group2esn
              (
                x_annual_plan ,
                x_start_date ,
                x_end_date ,
                groupesn2x_promotion ,
                groupesn2part_inst ,
                objid ,
                groupesn2x_promo_group
              )
              VALUES
              (
                0 ,
                SYSDATE ,
                SYSDATE + 365 ,
                promo_rec.objid ,
                phone_rec.part_inst_objid ,
                sa.seq('x_group2esn') ,
                promo_group_rec.objid
              );
          END IF;
          CLOSE promo_group_curs;
        ELSE
          dbms_output.put_line('promo_exists_curs%found');
        END IF;
        CLOSE promo_exists_curs;
      END IF;
    END LOOP;
    --PHONE PROMO PART
    OPEN phone_promo_curs(phone_rec.part_num2x_promotion ,phone_rec.x_technology ,'Activation');
    FETCH phone_promo_curs INTO phone_promo_rec;
    IF phone_promo_curs%FOUND THEN
      dbms_output.put_line('phone_promo_rec.x_promo_code:' || phone_promo_rec.x_promo_code);
      IF NOT (phone_promo_rec.x_refurbished_allowed = 0 AND phone_rec.x_part_inst_status = '150') THEN
        dbms_output.put_line('combo tech and other conditions meet');
        OPEN promo_exists_curs(phone_rec.part_inst_objid ,phone_promo_rec.x_promo_code);
        FETCH promo_exists_curs INTO promo_exists_rec;
        IF promo_exists_curs%NOTFOUND THEN
          dbms_output.put_line('promo_exists_curs%notfound');
          OPEN promo_group_curs(phone_promo_rec.objid);
          FETCH promo_group_curs INTO promo_group_rec;
          IF promo_group_curs%FOUND THEN
            dbms_output.put_line('promo_group_curs%found');
            INSERT
            INTO table_x_group2esn
              (
                x_annual_plan ,
                x_start_date ,
                x_end_date ,
                groupesn2x_promotion ,
                groupesn2part_inst ,
                objid ,
                groupesn2x_promo_group
              )
              VALUES
              (
                0 ,
                SYSDATE ,
                SYSDATE + 365 ,
                phone_promo_rec.objid ,
                phone_rec.part_inst_objid ,
                sa.seq('x_group2esn') ,
                promo_group_rec.objid
              );
          END IF;
          CLOSE promo_group_curs;
        ELSE
          dbms_output.put_line('promo_exists_curs%found');
        END IF;
        CLOSE promo_exists_curs;
      END IF;
    ELSE
      dbms_output.put_line('phone_promo_curs not found');
    END IF;
    CLOSE phone_promo_curs;
    --COMBO PART
    OPEN phone_promo_curs(phone_rec.part_num2x_promotion ,phone_rec.x_technology ,'ActivationCombo');
    FETCH phone_promo_curs INTO phone_promo_rec;
    IF phone_promo_curs%FOUND THEN
      dbms_output.put_line('phone_promo_rec.x_promo_code:' || phone_promo_rec.x_promo_code);
      IF NOT (phone_promo_rec.x_refurbished_allowed = 0 AND phone_rec.x_part_inst_status = '150') AND phone_promo_rec.x_default_type = 'COMBO' THEN
        dbms_output.put_line('tech and other conditions meet');
        OPEN promo_exists_curs(phone_rec.part_inst_objid ,phone_promo_rec.x_promo_code);
        FETCH promo_exists_curs INTO promo_exists_rec;
        IF promo_exists_curs%NOTFOUND THEN
          dbms_output.put_line('promo_exists_curs%notfound');
          OPEN promo_group_curs(phone_promo_rec.objid);
          FETCH promo_group_curs INTO promo_group_rec;
          IF promo_group_curs%FOUND THEN
            dbms_output.put_line('promo_group_curs%found');
            INSERT
            INTO table_x_group2esn
              (
                x_annual_plan ,
                x_start_date ,
                x_end_date ,
                groupesn2x_promotion ,
                groupesn2part_inst ,
                objid ,
                groupesn2x_promo_group
              )
              VALUES
              (
                0 ,
                SYSDATE ,
                SYSDATE + 365 ,
                phone_promo_rec.objid ,
                phone_rec.part_inst_objid ,
                sa.seq('x_group2esn') ,
                promo_group_rec.objid
              );
          END IF;
          CLOSE promo_group_curs;
        ELSE
          dbms_output.put_line('promo_exists_curs%found');
        END IF;
        CLOSE promo_exists_curs;
        IF LENGTH(LTRIM(RTRIM(phone_promo_rec.x_sql_statement))) > 4 AND LENGTH(LTRIM(RTRIM(phone_promo_rec.x_sql_statement))) < 11 THEN
          OPEN promo_exists_curs(phone_rec.part_inst_objid ,phone_promo_rec.x_sql_statement);
          FETCH promo_exists_curs INTO promo_exists_rec;
          IF promo_exists_curs%NOTFOUND THEN
            dbms_output.put_line('promo_exists_curs%notfound');
            OPEN promo_group_curs(phone_promo_rec.objid);
            FETCH promo_group_curs INTO promo_group_rec;
            IF promo_group_curs%FOUND THEN
              dbms_output.put_line('promo_group_curs%found');
              sa.sp_insert_group2esn(phone_rec.part_serial_no ,LTRIM(RTRIM(phone_promo_rec.x_sql_statement)) ,l_source ,op_result ,op_msg);
            END IF;
            CLOSE promo_group_curs;
          ELSE
            dbms_output.put_line('promo_exists_curs%found');
          END IF;
          CLOSE promo_exists_curs;
        END IF;
      END IF;
    ELSE
      dbms_output.put_line('phone_promo_curs not found');
    END IF;
    CLOSE phone_promo_curs;
  END IF;
  CLOSE phone_curs;
  --
  -- CR16379 Start kacosta 03/09/2012
  DECLARE
    --
    l_i_error_code    INTEGER         := 0;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    --
  BEGIN
    --
    promotion_pkg.expire_double_if_esn_is_triple(p_esn => p_esn ,p_error_code => l_i_error_code ,p_error_message => l_v_error_message);
    --
    IF (l_i_error_code <> 0) THEN
      --
      dbms_output.put_line('Failure calling promotion_pkg.expire_double_if_esn_is_triple with error: ' || l_v_error_message);
      --
    END IF;
    --
  EXCEPTION
  WHEN OTHERS THEN
    --
    dbms_output.put_line('Failure calling promotion_pkg.expire_double_if_esn_is_triple with Oracle error: ' || SQLCODE);
    --
  END;
  -- CR16379 End kacosta 03/09/2012
  --
END dynamicenrollment;
PROCEDURE createsitepart(
    p_min        IN VARCHAR2 ,
    p_esn        IN VARCHAR2 ,
    p_site_objid IN NUMBER ,
    p_expdate    IN DATE ,
    p_pin        IN VARCHAR2 ,
    p_zipcode    IN VARCHAR2 ,
    p_site_part_objid OUT NUMBER ,
    p_errorcode OUT VARCHAR2 ,
    p_errormessage OUT VARCHAR2 )
IS
  CURSOR min_curs(c_min IN VARCHAR2)
  IS
    SELECT *
	  FROM table_part_inst
	 WHERE part_serial_no = c_min
	   and x_domain = 'LINES';  --CR55074: Code Changes;
  min_rec min_curs%ROWTYPE;
  CURSOR esn_curs(c_esn IN VARCHAR2)
  IS
    SELECT pi.* ,
      pn.x_technology
    FROM table_part_num pn ,
      table_mod_level ml ,
      table_part_inst pi
    WHERE 1               = 1
    AND pn.objid          = ml.part_info2part_num
    AND ml.objid          = pi.n_part_inst2part_mod
    AND pi.part_serial_no = c_esn
    AND pi.x_domain       = 'PHONES'; -- CR55074: Code Changes;

  esn_rec esn_curs%ROWTYPE;
  l_sitepart_objid NUMBER;
BEGIN
  OPEN min_curs(p_min);
  FETCH min_curs INTO min_rec;
  CLOSE min_curs;
  OPEN esn_curs(p_esn);
  FETCH esn_curs INTO esn_rec;
  CLOSE esn_curs;
  l_sitepart_objid := seq('site_part');
  INSERT
  INTO table_site_part
    (
      objid ,
      x_min ,
      serial_no ,
      x_service_id ,
      part_status ,
      install_date ,
      site_objid ,
      dir_site_objid ,
      warranty_date ,
      x_pin ,
      x_zipcode ,
      state_value ,
      instance_name ,
      x_msid ,
      site_part2site ,
      all_site_part2site ,
      site_part2part_info ,
      x_iccid
    )
    VALUES
    (
      l_sitepart_objid ,
      min_rec.part_serial_no ,
      esn_rec.part_serial_no ,
      esn_rec.part_serial_no ,
      'Obsolete' ,
      SYSDATE ,
      p_site_objid ,
      p_site_objid ,
      p_expdate ,
      p_pin ,
      p_zipcode ,
      esn_rec.x_technology ,
      'Wireless' ,
      min_rec.x_msid ,
      p_site_objid ,
      p_site_objid ,
      esn_rec.n_part_inst2part_mod ,
      esn_rec.x_iccid
    );
  UPDATE table_part_inst
  SET x_part_inst2site_part = l_sitepart_objid
  WHERE part_serial_no      = p_esn
  AND   x_domain = 'PHONES'; -- CR55074: Code Changes;
  -- Commit only when the global variable is set to TRUE (default is TRUE)
  IF sa.globals_pkg.g_perform_commit THEN
    COMMIT;
  END IF;
  p_site_part_objid := l_sitepart_objid;
EXCEPTION
WHEN OTHERS THEN
  p_errorcode    := SQLCODE;
  p_errormessage := SQLERRM;
END createsitepart;
--

--Andrew/Ingrid 03/31/06 CR4981_4982 added p_conversion rate variable
PROCEDURE preprocess_redem_cards(
    p_esn   IN VARCHAR2 ,
    p_cards IN VARCHAR2 ,
    p_isota IN VARCHAR2 ,
    p_annual_plan OUT NUMBER ,
    p_total_units OUT NUMBER ,
    p_redeem_days OUT NUMBER ,
    p_errorcode OUT VARCHAR2 ,
    p_errormessage OUT VARCHAR2 ,
    p_conversion_rate OUT NUMBER --CR4981_4982
  )
IS
  --
  l_cards VARCHAR2(1000) := p_cards;
  i PLS_INTEGER          := 1;
  l PLS_INTEGER          := 1;
TYPE card_tab_type
IS
  TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  card_tab_original card_tab_type;
  card_tab card_tab_type;
  -- cwl add to make sure pl/sql table is null before we start 2/20/06
  clear_card_tab card_tab_type;
  --
  CURSOR esn_curs(c_esn IN VARCHAR2)
  IS
    SELECT objid ,
      DECODE(warr_end_date ,
      --TO_DATE ('01-jan-1753', 'dd-mon-yyyy'), SYSDATE,
      TO_DATE('01-01-1753' ,'dd-MM-yyyy') ,SYSDATE ,NULL ,SYSDATE ,warr_end_date) warr_end_date
    FROM table_part_inst
    WHERE part_serial_no = c_esn
    AND   x_domain = 'PHONES'; -- CR55074: Code Changes;
  esn_rec esn_curs%ROWTYPE;
  CURSOR card_curs ( c_red_code IN VARCHAR2 ,c_esn_objid IN VARCHAR2 )
  IS
    SELECT pi.objid part_inst_objid ,
      pi.part_serial_no ,
      pi.x_red_code ,
      sa.customer_info.get_esn_pin_redeem_days (i_esn => p_esn, i_pin => c_red_code) x_redeem_days , --CR47564
      NVL(pn.x_redeem_units ,0) x_redeem_units ,
      NVL(pn.x_conversion ,0) x_conversion ,
      pr.x_promo_code
    FROM table_x_promotion pr ,
      table_part_num pn ,
      table_mod_level ml ,
      table_part_inst pi
    WHERE 1                     = 1
    AND pn.objid                = ml.part_info2part_num
    AND ml.objid                = pi.n_part_inst2part_mod
    AND pi.x_red_code           = c_red_code
    AND pi.x_domain             = 'REDEMPTION CARDS' -- CR55074: Code Changes;
    AND (pi.x_part_inst_status IN ('42' ,'280') --CR6178
    OR (pi.x_part_inst_status  IN ('40' ,'43')
    AND c_esn_objid             = pi.part_to_esn2part_inst)
      -- CR12989 ST Retention Start PM
    OR (pi.x_part_inst_status IN ('400')
    AND c_esn_objid            = pi.part_to_esn2part_inst)
      -- CR12989 ST Retention End PM
      )
    AND pn.part_num2x_promotion = pr.objid(+);
  --CR6250
  card_rec card_curs%ROWTYPE;
  --
  l_found   NUMBER := 0;
  l_no_wait VARCHAR2(1000);
  --CR6250
  l_result VARCHAR2(20);
  l_msg    VARCHAR2(200);
  --CR6250
BEGIN
  -- initialize to blank cwl 2/20/06
  card_tab             := clear_card_tab;
  card_tab_original    := clear_card_tab;
  WHILE LENGTH(l_cards) > 0
  LOOP
    IF INSTR(l_cards ,',')  = 0 THEN
      card_tab_original(i) := LTRIM(RTRIM(l_cards));
      EXIT;
    ELSE
      card_tab_original(i) := LTRIM(RTRIM(SUBSTR(l_cards ,1 ,INSTR(l_cards ,',') - 1)));
      l_cards              := LTRIM(RTRIM(SUBSTR(l_cards ,INSTR(l_cards ,',')    + 1)));
      i                    := i                                                  + 1;
    END IF;
  END LOOP;
  --REMOVE DUPLICATES IN AN ARRAY 5033
  FOR i IN card_tab_original.first .. card_tab_original.last
  LOOP
    l_found := 0;
    FOR j IN i + 1 .. card_tab_original.last
    LOOP
      IF card_tab_original(j) = card_tab_original(i) THEN
        l_found              := 1;
        EXIT;
      END IF;
    END LOOP;
    --Revision 1.13.1.4
    IF (LENGTH(LTRIM(RTRIM(card_tab_original(i)))) IS NULL OR LENGTH(LTRIM(RTRIM(card_tab_original(i)))) = 0) THEN
      l_found                                      := 1;
    END IF;
    --Revision 1.13.1.4
    IF l_found     = 0 THEN
      card_tab(l) := card_tab_original(i);
      l           := l + 1;
    END IF;
  END LOOP;
  p_annual_plan     := 0;
  p_total_units     := 0;
  p_redeem_days     := 0;
  p_errorcode       := SQLCODE;
  p_errormessage    := SQLERRM;
  p_conversion_rate := 0;
  --initialize p_conversion_rate to 0 to protect from null values CR4981_4982 Andres/icanavan
  --
  OPEN esn_curs(p_esn);
  FETCH esn_curs INTO esn_rec;
  CLOSE esn_curs;
  IF card_tab.last > 0 THEN
    FOR i IN card_tab.first .. card_tab.last
    LOOP
      OPEN card_curs(card_tab(i) ,esn_rec.objid);
      FETCH card_curs INTO card_rec;
      IF card_curs%FOUND THEN
        BEGIN
          SELECT x_part_inst_status
          INTO l_no_wait
          FROM table_part_inst pi
          WHERE objid              = card_rec.part_inst_objid
          AND (x_part_inst_status IN ('42' ,'280') --CR6178
          OR (x_part_inst_status  IN ('40' ,'43')
          AND esn_rec.objid        = part_to_esn2part_inst)
            -- CR12989 ST Retention Start PM
          OR (pi.x_part_inst_status IN ('400')
          AND esn_rec.objid          = pi.part_to_esn2part_inst)
            -- CR12989 ST Retention End PM
            ) FOR UPDATE NOWAIT;
          UPDATE table_part_inst
          SET x_part_inst_status  = DECODE(p_isota ,'Y' ,'263' ,'43') ,
            status2x_code_table   = DECODE(p_isota ,'Y' ,536887189 ,985) ,
            last_trans_time       = SYSDATE ,
            part_to_esn2part_inst = esn_rec.objid
          WHERE objid             = card_rec.part_inst_objid;
          --CR6250
          IF NVL(card_rec.x_promo_code ,'ZZZ')                   = 'RTDBL000' THEN
            IF get_dblmin_usage_fun(p_esn ,'RTDBL000' ,0 ,'YES') = 0 THEN
              sp_insert_group2esn(p_esn ,'RTDBL000' ,'ZZZ' ,l_result ,l_msg);
            END IF;
          END IF;
          -- CR16379 / CR16344
          IF NVL(card_rec.x_promo_code ,'ZZZ')                   = 'RTX3X000' THEN
            IF get_dblmin_usage_fun(p_esn ,'RTX3X000' ,0 ,'YES') = 0 THEN
              sp_insert_group2esn(p_esn ,'RTX3X000' ,'ZZZ' ,l_result ,l_msg);
            END IF;
          END IF;
          --CR6250
        EXCEPTION
        WHEN OTHERS THEN
          p_errorcode    := SQLCODE;
          p_errormessage := SQLERRM;
        END;
        IF card_rec.x_redeem_days = 365 THEN
          p_annual_plan          := 1;
        END IF;
        p_total_units := p_total_units + card_rec.x_redeem_units;
        --CR5848 Start
        p_redeem_days := p_redeem_days + card_rec.x_redeem_days;
        --                IF p_redeem_days < card_rec.x_redeem_days
        --                THEN
        --                   p_redeem_days := card_rec.x_redeem_days;
        --                END IF;
        --CR5848 End
        DELETE
        FROM table_x_red_card_temp
        WHERE x_red_code = card_rec.x_red_code;
        INSERT
        INTO table_x_red_card_temp
          (
            objid ,
            x_red_date ,
            x_red_code ,
            x_redeem_days ,
            x_red_units ,
            x_status ,
            x_result ,
            temp_red_card2x_call_trans
          )
          VALUES
          (
            sa.seq('x_red_card_temp') ,
            SYSDATE ,
            card_rec.x_red_code ,
            card_rec.x_redeem_days ,
            card_rec.x_redeem_units ,
            NULL ,
            NULL ,
            NULL
          );
        --CR4981_4982
        IF p_conversion_rate < NVL(card_rec.x_conversion ,0) THEN
          p_conversion_rate := (card_rec.x_conversion);
        END IF;
        --CR4981_4982
      ELSE
        p_errorcode    := -1;
        p_errormessage := 'CARD NOT FOUND';
      END IF;
      CLOSE card_curs;
    END LOOP;
  END IF;
  -- Commit only when the global variable is set to TRUE (default is TRUE)
  IF sa.globals_pkg.g_perform_commit THEN
    COMMIT;
  END IF;

  dbms_output.put_line('p_annual_plan ' || p_annual_plan);
  dbms_output.put_line('p_total_units   ' || p_total_units);
  dbms_output.put_line('p_redeem_days  ' || p_redeem_days);
  dbms_output.put_line('p_errorcode ' || p_errorcode);
  dbms_output.put_line('p_errormessage   ' || p_errormessage);
EXCEPTION
WHEN OTHERS THEN
  p_errorcode    := SQLCODE;
  p_errormessage := SQLERRM;
END;
--
FUNCTION minacchange
  (
    p_site_part_objid NUMBER ,
    p_sourcesystem    VARCHAR2 ,
    p_brand_name      VARCHAR2 --CR11245 BRAND SEPARATION BRAND_SEP
  )
  RETURN BOOLEAN
IS
  CURSOR site_part_curs
  IS
    SELECT sp.*
    FROM table_site_part sp
    WHERE 1      = 1
    AND sp.objid = p_site_part_objid;
  site_part_rec site_part_curs%ROWTYPE;
  CURSOR esn_curs(c_esn IN VARCHAR2)
  IS
    SELECT pi.* ,
      s.objid dealer_objid
    FROM table_site s ,
      table_inv_bin ib ,
      table_part_inst pi
    WHERE 1               = 1
    AND   s.site_id         = ib.bin_name
    AND   ib.objid          = part_inst2inv_bin
    AND   pi.part_serial_no = c_esn
    AND   pi.x_domain       = 'PHONES'; -- CR55074: Code Changes;
  esn_rec esn_curs%ROWTYPE;
  CURSOR min_pending_curs(c_esn_objid IN NUMBER)
  IS
    SELECT pi.objid part_inst_objid ,
      --           pi.part_serial_no,
      --           pi.x_msid,
      pi.* ,
      c.objid carrier_objid ,
      cp.objid carr_pers_objid
    FROM table_x_carr_personality cp ,
      table_x_carrier c ,
      table_part_inst pi
    WHERE 1                      = 1
    AND   cp.objid                 = c.carrier2personality
    AND   c.objid                  = pi.part_inst2carrier_mkt
    AND   pi.part_to_esn2part_inst = c_esn_objid
    AND   pi.x_part_inst_status||'' = '38'
    AND   pi.x_domain||'' = 'LINES'
    ORDER BY pi.objid ASC;
  min_pending_rec min_pending_curs%ROWTYPE;
  CURSOR min_curr_curs(c_min IN VARCHAR2)
  IS
    SELECT pi.objid part_inst_objid ,
      --           pi.part_serial_no,
      --           pi.x_msid,
      pi.* ,
      c.objid carrier_objid ,
      cp.objid carr_pers_objid
    FROM table_x_carr_personality cp ,
      table_x_carrier c ,
      table_part_inst pi
    WHERE 1            = 1
    AND cp.objid       = c.carrier2personality
    AND c.objid        = pi.part_inst2carrier_mkt
    AND pi.part_serial_no = c_min
	and pi.x_domain = 'LINES';  --CR55074: Code Changes;
  min_curr_rec min_curr_curs%ROWTYPE;
  CURSOR user_curs
  IS
    SELECT objid FROM table_user WHERE s_login_name = UPPER(USER);
  user_rec user_curs%ROWTYPE;
  CURSOR acc_hist_curs(c_min_objid IN NUMBER)
  IS
    SELECT *
    FROM table_x_account_hist
    WHERE account_hist2part_inst = c_min_objid
    ORDER BY objid ASC;
  acc_hist_rec acc_hist_curs%ROWTYPE;
  l_new_site_part_objid NUMBER := sa.seq('site_part');
BEGIN
  OPEN min_pending_curs(esn_rec.objid);
  FETCH min_pending_curs INTO min_pending_rec;
  IF min_pending_curs%NOTFOUND THEN
    CLOSE min_pending_curs; --Fix OPEN_CURSORS
    RETURN FALSE;
  END IF;
  CLOSE min_pending_curs;
  OPEN min_curr_curs(site_part_rec.x_min);
  FETCH min_curr_curs INTO min_curr_rec;
  CLOSE min_curr_curs;
  OPEN user_curs;
  FETCH user_curs INTO user_rec;
  IF user_curs%NOTFOUND THEN
    user_rec.objid := 268435556;
  END IF;
  CLOSE user_curs;
  OPEN site_part_curs;
  FETCH site_part_curs INTO site_part_rec;
  CLOSE site_part_curs;
  OPEN esn_curs(site_part_rec.x_service_id);
  FETCH esn_curs INTO esn_rec;
  CLOSE esn_curs;
  OPEN acc_hist_curs(min_curr_rec.part_inst_objid);
  FETCH acc_hist_curs INTO acc_hist_rec;
  CLOSE acc_hist_curs;
  INSERT
  INTO table_site_part
    (
      objid ,
      instance_name ,
      serial_no ,
      s_serial_no ,
      invoice_no ,
      ship_date ,
      install_date ,
      warranty_date ,
      quantity ,
      mdbk ,
      state_code ,
      state_value ,
      modified ,
      level_to_part ,
      selected_prd ,
      part_status ,
      comments ,
      level_to_bin ,
      bin_objid ,
      site_objid ,
      inst_objid ,
      dir_site_objid ,
      machine_id ,
      service_end_dt ,
      dev ,
      x_service_id ,
      x_min ,
      x_pin ,
      x_deact_reason ,
      x_min_change_flag ,
      x_notify_carrier ,
      x_expire_dt ,
      x_zipcode ,
      site_part2productbin ,
      site_part2site ,
      site_part2site_part ,
      site_part2part_info ,
      site_part2primary ,
      site_part2backup ,
      all_site_part2site ,
      site_part2part_detail ,
      site_part2x_new_plan ,
      site_part2x_plan ,
      x_msid ,
      x_refurb_flag ,
      cmmtmnt_end_dt ,
      instance_id ,
      site_part_ind ,
      status_dt ,
      x_iccid
    )
    VALUES
    (
      l_new_site_part_objid ,
      site_part_rec.instance_name ,
      site_part_rec.serial_no ,
      site_part_rec.s_serial_no ,
      site_part_rec.invoice_no ,
      site_part_rec.ship_date ,
      SYSDATE ,
      site_part_rec.warranty_date ,
      site_part_rec.quantity ,
      site_part_rec.mdbk ,
      site_part_rec.state_code ,
      site_part_rec.state_value ,
      site_part_rec.modified ,
      site_part_rec.level_to_part ,
      site_part_rec.selected_prd ,
      'Active' ,
      site_part_rec.comments ,
      site_part_rec.level_to_bin ,
      site_part_rec.bin_objid ,
      site_part_rec.site_objid ,
      site_part_rec.inst_objid ,
      site_part_rec.dir_site_objid ,
      site_part_rec.machine_id ,
      site_part_rec.service_end_dt ,
      site_part_rec.dev ,
      site_part_rec.x_service_id ,
      min_pending_rec.part_serial_no ,
      site_part_rec.x_pin ,
      site_part_rec.x_deact_reason ,
      site_part_rec.x_min_change_flag ,
      site_part_rec.x_notify_carrier ,
      site_part_rec.x_expire_dt ,
      site_part_rec.x_zipcode ,
      site_part_rec.site_part2productbin ,
      site_part_rec.site_part2site ,
      site_part_rec.site_part2site_part ,
      site_part_rec.site_part2part_info ,
      site_part_rec.site_part2primary ,
      site_part_rec.site_part2backup ,
      site_part_rec.all_site_part2site ,
      site_part_rec.site_part2part_detail ,
      site_part_rec.site_part2x_new_plan ,
      site_part_rec.site_part2x_plan ,
      min_pending_rec.x_msid ,
      site_part_rec.x_refurb_flag ,
      site_part_rec.cmmtmnt_end_dt ,
      site_part_rec.instance_id ,
      site_part_rec.site_part_ind ,
      site_part_rec.status_dt ,
      site_part_rec.x_iccid
    );
  UPDATE table_part_inst
  SET part_inst2x_new_pers = min_pending_rec.carr_pers_objid ,
    x_part_inst_status     = '13' ,
    status2x_code_table    = 960
    --CR21051 Start Kacosta 05/31/2012
    ,
    n_part_inst2part_mod =
    CASE
      WHEN NVL(n_part_inst2part_mod ,0) <> 23070541
      THEN 23070541
      ELSE n_part_inst2part_mod
    END
    --CR21051 End Kacosta 05/31/2012
  WHERE objid = min_pending_rec.part_inst_objid;
  UPDATE table_part_inst
  SET part_inst2x_new_pers = min_curr_rec.carr_pers_objid ,
    x_part_inst_status     = '35' ,
    status2x_code_table    = 967
    --CR21051 Start Kacosta 05/31/2012
    ,
    n_part_inst2part_mod =
    CASE
      WHEN NVL(n_part_inst2part_mod ,0) <> 23070541
      THEN 23070541
      ELSE n_part_inst2part_mod
    END
    --CR21051 End Kacosta 05/31/2012
  WHERE objid = min_curr_rec.part_inst_objid;
  UPDATE table_site_part
  SET part_status    = 'Inactive' ,
    service_end_dt   = SYSDATE ,
    x_notify_carrier = 0 ,
    x_deact_reason   = 'AC CHANGE'
  WHERE objid        = site_part_rec.objid;
  -- BRAND_SEP
  INSERT
  INTO table_x_call_trans
    (
      objid ,
      call_trans2site_part ,
      x_action_type ,
      x_call_trans2carrier ,
      x_call_trans2dealer ,
      x_call_trans2user ,
      x_line_status ,
      x_min ,
      x_service_id ,
      x_sourcesystem ,
      x_transact_date ,
      x_total_units ,
      x_action_text ,
      x_reason ,
      x_result ,
      x_sub_sourcesystem ,
      x_iccid ,
      x_ota_req_type ,
      x_ota_type ,
      x_call_trans2x_ota_code_hist
    )
    VALUES
    (
      sa.seq('x_call_trans') ,
      site_part_rec.objid ,
      '9' ,
      min_curr_rec.carrier_objid ,
      esn_rec.dealer_objid ,
      user_rec.objid ,
      NULL ,
      site_part_rec.x_min ,
      site_part_rec.x_service_id ,
      'WEB' ,
      SYSDATE ,
      0 ,
      NULL ,
      'AC CHANGE' ,
      'Completed' ,
      DECODE(UPPER(p_brand_name) ,'ENGLISH' ,'200' ,'SPANISH' ,'201' ,p_brand_name) ,
      NULL ,
      NULL ,
      NULL ,
      NULL
    );
  -- BRAND_SEP
  INSERT
  INTO table_x_call_trans
    (
      objid ,
      call_trans2site_part ,
      x_action_type ,
      x_call_trans2carrier ,
      x_call_trans2dealer ,
      x_call_trans2user ,
      x_line_status ,
      x_min ,
      x_service_id ,
      x_sourcesystem ,
      x_transact_date ,
      x_total_units ,
      x_action_text ,
      x_reason ,
      x_result ,
      x_sub_sourcesystem ,
      x_iccid ,
      x_ota_req_type ,
      x_ota_type ,
      x_call_trans2x_ota_code_hist
    )
    VALUES
    (
      sa.seq('x_call_trans') ,
      l_new_site_part_objid ,
      '10' ,
      min_pending_rec.carrier_objid ,
      esn_rec.dealer_objid ,
      user_rec.objid ,
      NULL ,
      min_pending_rec.part_serial_no ,
      site_part_rec.x_service_id ,
      'WEB' ,
      SYSDATE ,
      0 ,
      NULL ,
      NULL ,
      'Completed' ,
      DECODE(UPPER(p_brand_name) ,'ENGLISH' ,'200' ,'SPANISH' ,'201' ,p_brand_name) ,
      NULL ,
      NULL ,
      NULL ,
      NULL
    );
  UPDATE table_x_account_hist
  SET x_end_date = SYSDATE
  WHERE objid    = acc_hist_rec.objid;
  INSERT
  INTO table_x_click_plan_hist
    (
      objid ,
      curr_hist2site_part ,
      plan_hist2site_part ,
      x_end_date ,
      x_start_date ,
      plan_hist2click_plan
    )
    VALUES
    (
      sa.seq('x_click_plan_hist') ,
      min_pending_rec.part_inst_objid ,
      NULL ,
      NULL ,
      SYSDATE ,
      site_part_rec.site_part2x_plan
    );
  UPDATE table_x_autopay_details
  SET x_autopay_details2site_part   = l_new_site_part_objid
  WHERE x_autopay_details2site_part = site_part_rec.objid;
  INSERT
  INTO table_x_pi_hist VALUES
    (
      sa.seq('x_pi_hist') ,
      967 ,
      SYSDATE ,
      'DEACTIVATE' ,
      min_curr_rec.x_cool_end_date ,
      min_curr_rec.x_creation_date ,
      min_curr_rec.x_deactivation_flag ,
      min_curr_rec.x_domain ,
      min_curr_rec.x_ext ,
      min_curr_rec.x_insert_date ,
      min_curr_rec.x_npa ,
      min_curr_rec.x_nxx ,
      NULL ,
      NULL ,
      NULL ,
      min_curr_rec.part_bin ,
      '35' ,
      min_curr_rec.part_mod ,
      min_curr_rec.part_serial_no ,
      min_curr_rec.part_status ,
      min_curr_rec.part_inst2carrier_mkt ,
      min_curr_rec.part_inst2inv_bin ,
      min_curr_rec.part_inst_objid ,
      min_curr_rec.n_part_inst2part_mod ,
      user_rec.objid ,
      min_curr_rec.part_inst2x_new_pers ,
      min_curr_rec.part_inst2x_pers ,
      min_curr_rec.x_po_num ,
      min_curr_rec.x_reactivation_flag ,
      min_curr_rec.x_red_code ,
      min_curr_rec.x_sequence ,
      min_curr_rec.warr_end_date ,
      min_curr_rec.dev ,
      NULL ,
      min_curr_rec.part_to_esn2part_inst ,
      min_curr_rec.bad_res_qty ,
      min_curr_rec.date_in_serv ,
      min_curr_rec.good_res_qty ,
      min_curr_rec.last_cycle_ct ,
      min_curr_rec.last_mod_time ,
      min_curr_rec.last_pi_date ,
      min_curr_rec.last_trans_time ,
      min_curr_rec.next_cycle_ct ,
      min_curr_rec.x_order_number ,
      min_curr_rec.part_bad_qty ,
      min_curr_rec.part_good_qty ,
      min_curr_rec.pi_tag_no ,
      min_curr_rec.pick_request ,
      min_curr_rec.repair_date ,
      min_curr_rec.transaction_id ,
      min_curr_rec.x_part_inst2site_part ,
      min_curr_rec.x_msid ,
      min_curr_rec.x_part_inst2contact ,
      min_curr_rec.x_iccid
    );
  INSERT
  INTO table_x_pi_hist VALUES
    (
      sa.seq('x_pi_hist') ,
      960 ,
      SYSDATE ,
      'ACTIVATE' ,
      min_pending_rec.x_cool_end_date ,
      min_pending_rec.x_creation_date ,
      min_pending_rec.x_deactivation_flag ,
      min_pending_rec.x_domain ,
      min_pending_rec.x_ext ,
      min_pending_rec.x_insert_date ,
      min_pending_rec.x_npa ,
      min_pending_rec.x_nxx ,
      NULL ,
      NULL ,
      NULL ,
      min_pending_rec.part_bin ,
      '13' ,
      min_pending_rec.part_mod ,
      min_pending_rec.part_serial_no ,
      min_pending_rec.part_status ,
      min_pending_rec.part_inst2carrier_mkt ,
      min_pending_rec.part_inst2inv_bin ,
      min_pending_rec.part_inst_objid ,
      min_pending_rec.n_part_inst2part_mod ,
      user_rec.objid ,
      min_pending_rec.part_inst2x_new_pers ,
      min_pending_rec.part_inst2x_pers ,
      min_pending_rec.x_po_num ,
      min_pending_rec.x_reactivation_flag ,
      min_pending_rec.x_red_code ,
      min_pending_rec.x_sequence ,
      min_pending_rec.warr_end_date ,
      min_pending_rec.dev ,
      NULL ,
      min_pending_rec.part_to_esn2part_inst ,
      min_pending_rec.bad_res_qty ,
      min_pending_rec.date_in_serv ,
      min_pending_rec.good_res_qty ,
      min_pending_rec.last_cycle_ct ,
      min_pending_rec.last_mod_time ,
      min_pending_rec.last_pi_date ,
      min_pending_rec.last_trans_time ,
      min_pending_rec.next_cycle_ct ,
      min_pending_rec.x_order_number ,
      min_pending_rec.part_bad_qty ,
      min_pending_rec.part_good_qty ,
      min_pending_rec.pi_tag_no ,
      min_pending_rec.pick_request ,
      min_pending_rec.repair_date ,
      min_pending_rec.transaction_id ,
      min_pending_rec.x_part_inst2site_part ,
      min_pending_rec.x_msid ,
      min_pending_rec.x_part_inst2contact ,
      min_pending_rec.x_iccid
    );
  RETURN TRUE;
END minacchange;
--
PROCEDURE acceptruntimepromo
  (
    p_part_inst_objid NUMBER
  )
IS
  CURSOR group2esn_curs
  IS
    SELECT * FROM table_x_group2esn WHERE groupesn2part_inst = p_part_inst_objid;
BEGIN
  FOR group2esn_rec IN group2esn_curs
  LOOP
    IF group2esn_rec.x_annual_plan > 1 THEN
      UPDATE table_x_group2esn
      SET x_annual_plan = 1
      WHERE objid       = group2esn_rec.objid;
    END IF;
  END LOOP;
END acceptruntimepromo;
--
PROCEDURE failruntimepromo(
    p_site_part_objid NUMBER ,
    p_part_inst_objid NUMBER )
IS
  CURSOR pending_redemption_curs
  IS
    SELECT pr.x_pend_type ,
      pr.objid
    FROM table_x_promotion p ,
      table_x_pending_redemption pr
    WHERE p.objid               = pr.pend_red2x_promotion
    AND pr.x_pend_red2site_part = p_site_part_objid;
  CURSOR group2esn_curs
  IS
    SELECT * FROM table_x_group2esn WHERE groupesn2part_inst = p_part_inst_objid;
  CURSOR group_hist_curs
  IS
    SELECT *
    FROM table_x_group_hist
    WHERE grouphist2part_inst = p_part_inst_objid
    AND UPPER(x_action_type) IN ('ACTIVATION' ,'RENEWAL')
    ORDER BY x_action_date DESC;
  group_hist_rec group_hist_curs%ROWTYPE;
BEGIN
  FOR pending_redemption_rec IN pending_redemption_curs
  LOOP
    IF UPPER(pending_redemption_rec.x_pend_type) IN ('RUNTIME' ,'PROMOCODE') THEN
      DELETE
      FROM table_x_pending_redemption
      WHERE objid = pending_redemption_rec.objid;
    END IF;
  END LOOP;
  FOR group2esn_rec IN group2esn_curs
  LOOP
    IF group2esn_rec.x_annual_plan = 3 THEN
      DELETE FROM table_x_group2esn WHERE objid = group2esn_rec.objid;
      OPEN group_hist_curs;
      FETCH group_hist_curs INTO group_hist_rec;
      IF group_hist_curs%FOUND THEN
        DELETE FROM table_x_group_hist WHERE objid = group_hist_rec.objid;
      END IF;
      CLOSE group_hist_curs;
    ELSIF group2esn_rec.x_annual_plan = 2 THEN
      UPDATE table_x_group2esn
      SET x_annual_plan = 1
      WHERE objid       = group2esn_rec.objid;
      OPEN group_hist_curs;
      FETCH group_hist_curs INTO group_hist_rec;
      IF group_hist_curs%FOUND THEN
        DELETE FROM table_x_group_hist WHERE objid = group_hist_rec.objid;
      END IF;
      CLOSE group_hist_curs;
      OPEN group_hist_curs;
      FETCH group_hist_curs INTO group_hist_rec;
      IF group_hist_curs%FOUND THEN
        UPDATE table_x_group2esn
        SET x_start_date = group_hist_rec.x_start_date ,
          x_end_date     = group_hist_rec.x_end_date
        WHERE objid      = group2esn_rec.objid;
      END IF;
      CLOSE group_hist_curs;
    END IF;
  END LOOP;
END failruntimepromo;
-- BRAND_SEP
--
PROCEDURE otacompletetransaction(
    p_esn                VARCHAR2 ,
    p_call_trans_objid   NUMBER ,
    p_min                VARCHAR2 ,
    p_num_codes_accepted NUMBER ,
    p_brand_name         VARCHAR2 ,
    p_errorcode OUT VARCHAR2 ,
    p_errormessage OUT VARCHAR2 )
IS
  CURSOR part_inst_min_curs
  IS
    SELECT pi.x_part_inst_status ,
      p.x_no_msid ,
      p.x_no_inventory ,
      pi.part_inst2carrier_mkt ,
      pi.x_port_in
    FROM table_x_parent p ,
      table_x_carrier_group cg ,
      table_x_carrier c ,
      table_part_inst pi
    WHERE 1               = 1
    AND p.objid           = cg.x_carrier_group2x_parent
    AND cg.objid          = c.carrier2carrier_group
    AND c.objid           = pi.part_inst2carrier_mkt
    AND pi.part_serial_no = p_min
	and pi.x_domain = 'LINES';  --CR55074: Code Changes;
  part_inst_min_rec part_inst_min_curs%ROWTYPE;
  CURSOR part_inst_curs
  IS
    SELECT *
    FROM   table_part_inst
    WHERE  part_serial_no = p_esn
    AND    x_domain = 'PHONES'; -- CR55074: Code Changes;;
  part_inst_rec part_inst_curs%ROWTYPE;
  esn_curr_rec part_inst_curs%ROWTYPE;
  CURSOR min_curr_curs
  IS
    SELECT *
    FROM   table_part_inst
    WHERE  part_serial_no = p_min
    and    x_domain = 'LINES';  --CR55074: Code Changes;
  min_curr_rec min_curr_curs%ROWTYPE;
  CURSOR contact_curs
  IS
    SELECT sp.x_iccid ,
      ct.x_action_type ,
      ct.x_min call_trans_x_min ,
      ct.call_trans2site_part ,
      ct.x_sourcesystem ,
      ct.x_ota_type ,
      sp.x_min site_part_x_min ,
      sp.objid site_part_objid ,
      sp.warranty_date ,
      c.objid contact_objid
    FROM table_user u ,
      table_contact c ,
      table_contact_role cr ,
      table_site_part sp ,
      table_x_call_trans ct
    WHERE 1                  = 1
    AND u.objid              = ct.x_call_trans2user
    AND c.objid              = cr.contact_role2contact
    AND cr.contact_role2site = sp.site_part2site
    AND sp.objid             = ct.call_trans2site_part
    AND ct.objid             = p_call_trans_objid;
  contact_rec contact_curs%ROWTYPE;
  CURSOR carr_rules_curs
  IS
    SELECT cr.x_esn_change_flag
    FROM table_x_carrier_rules cr ,
      table_x_carrier ca ,
      table_x_call_trans ct
    WHERE 1      = 1
    AND cr.objid = ca.carrier2rules
    AND ca.objid = ct.x_call_trans2carrier
    AND ct.objid = p_call_trans_objid;
  carr_rules_rec carr_rules_curs%ROWTYPE;
  CURSOR min_pending_curs(c_esn_objid IN NUMBER)
  IS
    SELECT *
    FROM table_part_inst
    WHERE part_to_esn2part_inst = c_esn_objid
    AND x_part_inst_status|| '' = '38'
    AND x_domain|| '' = 'LINES'
    ORDER BY objid ASC;
  CURSOR code_hist_curs
  IS
    SELECT COUNT(*) cnt
    FROM table_x_code_hist
    WHERE code_hist2call_trans = p_call_trans_objid
    AND x_code_type            = 'Master_SID';
  code_hist_rec code_hist_curs%ROWTYPE;
  CURSOR port_in_curs ( c_part_inst2carrier_mkt IN NUMBER ,c_esn_objid IN NUMBER )
  IS
    SELECT *
    FROM table_x_pi_hist
    WHERE x_part_serial_no = p_min
    AND x_change_reason
      || ''                       != 'INT_PORT_IN'
    AND x_pi_hist2carrier_mkt + 0 != c_part_inst2carrier_mkt
    AND x_creation_date            >
      (SELECT MAX(x_creation_date)
      FROM table_x_pi_hist
      WHERE x_part_serial_no             = p_min
      AND part_to_esn_hist2part_inst + 0 = c_esn_objid
      AND x_change_reason
        || '' = 'INT_PORT_IN'
      )
  ORDER BY x_change_date;
  port_in_rec port_in_curs%ROWTYPE;
  CURSOR carrier_curs(c_objid IN NUMBER)
  IS
    SELECT x_carrier_id FROM table_x_carrier WHERE objid = c_objid;
  carrier_curr_rec carrier_curs%ROWTYPE;
  carrier_old_rec carrier_curs%ROWTYPE;
  CURSOR user_curs
  IS
    SELECT objid FROM table_user WHERE s_login_name = USER;
  user_rec user_curs%ROWTYPE;
  min_pending_rec min_pending_curs%ROWTYPE;
  acchange      BOOLEAN      := FALSE;
  blnsuccess    BOOLEAN      := TRUE;
  blnmsidupdate BOOLEAN      := FALSE;
  oldsitepart   NUMBER       := NULL;
  l_case_id     VARCHAR2(30) := NULL;
BEGIN
  OPEN user_curs;
  FETCH user_curs INTO user_rec;
  CLOSE user_curs;
  OPEN min_curr_curs;
  FETCH min_curr_curs INTO min_curr_rec;
  CLOSE min_curr_curs;
  OPEN part_inst_curs;
  FETCH part_inst_curs INTO part_inst_rec;
  CLOSE part_inst_curs;
  OPEN contact_curs;
  FETCH contact_curs INTO contact_rec;
  IF contact_curs%NOTFOUND THEN
    p_errorcode    := '807';
    p_errormessage := 'CONTACT info not found';
    blnsuccess     := FALSE;
  END IF;
  CLOSE contact_curs;
  OPEN carr_rules_curs;
  FETCH carr_rules_curs INTO carr_rules_rec;
  IF carr_rules_curs%NOTFOUND OR carr_rules_rec.x_esn_change_flag IS NULL THEN
    carr_rules_rec.x_esn_change_flag                              := 0;
  END IF;
  CLOSE carr_rules_curs;
  OPEN part_inst_min_curs;
  FETCH part_inst_min_curs INTO part_inst_min_rec;
  CLOSE part_inst_min_curs;
  IF contact_rec.x_action_type NOT IN ('6' ,'7') AND contact_rec.call_trans_x_min != contact_rec.site_part_x_min THEN
    p_errorcode                                                                   := '803';
    p_errormessage                                                                := 'MIN iinformation_required';
    blnsuccess                                                                    := FALSE;
  END IF;
  IF blnsuccess THEN
    acceptruntimepromo(part_inst_rec.objid);
    IF contact_rec.x_action_type = '6' THEN
      UPDATE table_site_part
      SET x_expire_dt = contact_rec.warranty_date
      WHERE objid     = contact_rec.site_part_objid;
      UPDATE table_part_inst
      SET warr_end_date     = contact_rec.warranty_date ,
        status2x_code_table = 988 ,
        x_part_inst_status  = '52'
      WHERE objid           = part_inst_rec.objid;
      UPDATE table_x_call_trans
      SET x_result = 'Completed'
      WHERE objid  = p_call_trans_objid;
      --
      --CR21060 Start Kacosta 06/05/2012
      IF (part_inst_rec.x_iccid IS NOT NULL) THEN
        --
        UPDATE table_x_sim_inv
        SET x_last_update_date      = SYSDATE ,
          x_sim_inv_status          = '254' ,
          x_sim_status2x_code_table = 268438607
        WHERE x_sim_serial_no       = part_inst_rec.x_iccid
        AND x_sim_inv_status       IN ('251' ,'253');
        --
      END IF;
      --CR21060 End Kacosta 06/05/2012
      --
      -- BRAND_SEP
      acchange := minacchange(contact_rec.call_trans2site_part ,contact_rec.x_sourcesystem ,p_brand_name);
      RETURN;
    END IF;
    UPDATE table_site_part
    SET x_expire_dt = contact_rec.warranty_date ,
      part_status   = 'Active'
    WHERE objid     = contact_rec.call_trans2site_part;
    ---CR14491
    UPDATE table_site_part
    SET site_part2x_new_plan = NULL
    WHERE objid              = contact_rec.call_trans2site_part
    AND site_part2x_new_plan = site_part2x_plan;
    UPDATE table_part_inst
    SET warr_end_date               = contact_rec.warranty_date ,
      x_part_inst_status            = '52' ,
      status2x_code_table           = 988 ,
      part_status                   = 'Active' ,
      last_trans_time               = SYSDATE
    WHERE objid                     = part_inst_rec.objid;
    IF (part_inst_min_rec.x_no_msid = 1 OR contact_rec.x_ota_type = '264') AND part_inst_min_rec.x_part_inst_status = '110' THEN
      OPEN code_hist_curs;
      FETCH code_hist_curs INTO code_hist_rec;
      IF (code_hist_rec.cnt = 0 AND part_inst_min_rec.x_no_inventory = 1) OR (code_hist_rec.cnt < 2 AND part_inst_min_rec.x_no_inventory = 0) THEN
        blnmsidupdate      := TRUE;
      END IF;
      CLOSE code_hist_curs;
    END IF;
    IF p_min = contact_rec.call_trans_x_min AND NOT blnmsidupdate THEN
      UPDATE table_part_inst
      SET x_part_inst_status = '13' ,
        part_status          = 'Active' ,
        status2x_code_table  = 960
        --CR21051 Start Kacosta 05/31/2012
        ,
        n_part_inst2part_mod =
        CASE
          WHEN NVL(n_part_inst2part_mod ,0) <> 23070541
          THEN 23070541
          ELSE n_part_inst2part_mod
        END
        --CR21051 End Kacosta 05/31/2012
      WHERE part_serial_no = p_min
	  and   x_domain = 'LINES';  --CR55074: Code Changes;
    END IF;
    UPDATE table_x_sim_inv
    SET x_last_update_date      = SYSDATE ,
      x_sim_inv_status          = '254' ,
      x_sim_status2x_code_table = 268438607
    WHERE x_sim_serial_no       = part_inst_rec.x_iccid;
    UPDATE table_x_call_trans
    SET x_result = 'Completed'
    WHERE objid  = p_call_trans_objid;
    OPEN min_curr_curs;
    FETCH min_curr_curs INTO min_curr_rec;
    CLOSE min_curr_curs;
    INSERT
    INTO table_x_pi_hist VALUES
      (
        sa.seq('x_pi_hist') ,
        min_curr_rec.status2x_code_table ,
        SYSDATE ,
        'ACTIVATE' ,
        min_curr_rec.x_cool_end_date ,
        min_curr_rec.x_creation_date ,
        min_curr_rec.x_deactivation_flag ,
        min_curr_rec.x_domain ,
        min_curr_rec.x_ext ,
        min_curr_rec.x_insert_date ,
        min_curr_rec.x_npa ,
        min_curr_rec.x_nxx ,
        NULL ,
        NULL ,
        NULL ,
        min_curr_rec.part_bin ,
        min_curr_rec.x_part_inst_status ,
        min_curr_rec.part_mod ,
        min_curr_rec.part_serial_no ,
        min_curr_rec.part_status ,
        min_curr_rec.part_inst2carrier_mkt ,
        min_curr_rec.part_inst2inv_bin ,
        min_curr_rec.part_to_esn2part_inst ,
        min_curr_rec.n_part_inst2part_mod ,
        user_rec.objid ,
        min_curr_rec.part_inst2x_new_pers ,
        min_curr_rec.part_inst2x_pers ,
        min_curr_rec.x_po_num ,
        min_curr_rec.x_reactivation_flag ,
        min_curr_rec.x_red_code ,
        min_curr_rec.x_sequence ,
        min_curr_rec.warr_end_date ,
        min_curr_rec.dev ,
        NULL ,
        min_curr_rec.part_to_esn2part_inst ,
        min_curr_rec.bad_res_qty ,
        min_curr_rec.date_in_serv ,
        min_curr_rec.good_res_qty ,
        min_curr_rec.last_cycle_ct ,
        min_curr_rec.last_mod_time ,
        min_curr_rec.last_pi_date ,
        min_curr_rec.last_trans_time ,
        min_curr_rec.next_cycle_ct ,
        min_curr_rec.x_order_number ,
        min_curr_rec.part_bad_qty ,
        min_curr_rec.part_good_qty ,
        min_curr_rec.pi_tag_no ,
        min_curr_rec.pick_request ,
        min_curr_rec.repair_date ,
        min_curr_rec.transaction_id ,
        min_curr_rec.x_part_inst2site_part ,
        min_curr_rec.x_msid ,
        min_curr_rec.x_part_inst2contact ,
        min_curr_rec.x_iccid
      );
    OPEN part_inst_curs;
    FETCH part_inst_curs INTO esn_curr_rec;
    CLOSE part_inst_curs;
    INSERT
    INTO table_x_pi_hist VALUES
      (
        sa.seq('x_pi_hist') ,
        esn_curr_rec.status2x_code_table ,
        SYSDATE ,
        DECODE(part_inst_rec.x_part_inst_status ,'50' ,'ACTIVATE' ,'REACTIVATE') ,
        esn_curr_rec.x_cool_end_date ,
        esn_curr_rec.x_creation_date ,
        esn_curr_rec.x_deactivation_flag ,
        esn_curr_rec.x_domain ,
        esn_curr_rec.x_ext ,
        esn_curr_rec.x_insert_date ,
        esn_curr_rec.x_npa ,
        esn_curr_rec.x_nxx ,
        NULL ,
        NULL ,
        NULL ,
        esn_curr_rec.part_bin ,
        esn_curr_rec.x_part_inst_status ,
        esn_curr_rec.part_mod ,
        esn_curr_rec.part_serial_no ,
        esn_curr_rec.part_status ,
        esn_curr_rec.part_inst2carrier_mkt ,
        esn_curr_rec.part_inst2inv_bin ,
        esn_curr_rec.part_to_esn2part_inst ,
        esn_curr_rec.n_part_inst2part_mod ,
        user_rec.objid ,
        esn_curr_rec.part_inst2x_new_pers ,
        esn_curr_rec.part_inst2x_pers ,
        esn_curr_rec.x_po_num ,
        esn_curr_rec.x_reactivation_flag ,
        esn_curr_rec.x_red_code ,
        esn_curr_rec.x_sequence ,
        esn_curr_rec.warr_end_date ,
        esn_curr_rec.dev ,
        NULL ,
        esn_curr_rec.part_to_esn2part_inst ,
        esn_curr_rec.bad_res_qty ,
        esn_curr_rec.date_in_serv ,
        esn_curr_rec.good_res_qty ,
        esn_curr_rec.last_cycle_ct ,
        esn_curr_rec.last_mod_time ,
        esn_curr_rec.last_pi_date ,
        esn_curr_rec.last_trans_time ,
        esn_curr_rec.next_cycle_ct ,
        esn_curr_rec.x_order_number ,
        esn_curr_rec.part_bad_qty ,
        esn_curr_rec.part_good_qty ,
        esn_curr_rec.pi_tag_no ,
        esn_curr_rec.pick_request ,
        esn_curr_rec.repair_date ,
        esn_curr_rec.transaction_id ,
        esn_curr_rec.x_part_inst2site_part ,
        esn_curr_rec.x_msid ,
        esn_curr_rec.x_part_inst2contact ,
        esn_curr_rec.x_iccid
      );
    OPEN port_in_curs(part_inst_min_rec.part_inst2carrier_mkt ,part_inst_rec.objid);
    FETCH port_in_curs INTO port_in_rec;
    IF port_in_curs%FOUND AND part_inst_min_rec.x_port_in != 1 THEN
      OPEN carrier_curs(port_in_rec.x_pi_hist2carrier_mkt);
      FETCH carrier_curs INTO carrier_old_rec;
      CLOSE carrier_curs;
      OPEN carrier_curs(part_inst_min_rec.part_inst2carrier_mkt);
      FETCH carrier_curs INTO carrier_curr_rec;
      CLOSE carrier_curs;
      sa.create_case_clarify_pkg.sp_create_case(p_esn ,contact_rec.contact_objid ,'Internal Port In' ,'Port In' ,'Internal' ,'Line transferred from carrier: ' || carrier_old_rec.x_carrier_id || ' to ' || carrier_curr_rec.x_carrier_id ,'Pending' ,
      -- Starting Status of the Case: Pending, BadAddress
      NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,
      -- Equivalent To Source System (IVR,WEBCSR,ETC)
      NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL ,l_case_id);
    END IF;
    CLOSE port_in_curs;
  ELSE
    IF contact_rec.x_action_type = '6' THEN
      failruntimepromo(contact_rec.site_part_objid ,part_inst_rec.objid);
      UPDATE table_x_call_trans
      SET x_result = 'Failed'
      WHERE objid  = p_call_trans_objid;
      UPDATE table_x_code_hist
      SET x_code_accepted        = 'Failed'
      WHERE code_hist2call_trans = p_call_trans_objid;
      clearredcards(p_call_trans_objid ,part_inst_rec.objid ,FALSE);
      DELETE
      FROM table_x_pending_redemption
      WHERE x_granted_from2x_call_trans = p_call_trans_objid
      AND UPPER(x_pend_type)           IN ('RUNTIME' ,'PROMOCODE');
      RETURN;
    ELSIF contact_rec.x_action_type = '3' THEN
      clearredcards(p_call_trans_objid ,part_inst_rec.objid ,FALSE);
      oldsitepart    := getoldsitepart(p_esn ,'Inactive' ,1);
      IF oldsitepart IS NOT NULL THEN
        UPDATE table_x_call_trans
        SET x_total_units = 0
        WHERE objid       = p_call_trans_objid;
        UPDATE table_part_inst
        SET    x_part_inst2site_part = oldsitepart
        WHERE  objid               = part_inst_rec.objid;
      END IF;
    END IF;
  END IF;
END otacompletetransaction;
--1.9
PROCEDURE sp_create_call_trans(
    ip_esn          IN VARCHAR2 ,
    ip_action_type  IN VARCHAR2 ,
    ip_sourcesystem IN VARCHAR2 ,
    ip_brand_name   IN VARCHAR2 ,
    ip_reason       IN VARCHAR2 ,
    ip_result       IN VARCHAR2 ,
    ip_ota_req_type IN VARCHAR2 ,
    ip_ota_type     IN VARCHAR2 ,
    ip_total_units  IN NUMBER ,
    op_calltranobj OUT NUMBER ,
    op_err_code OUT VARCHAR2 ,
    op_err_msg OUT VARCHAR2 )
IS
  p_esn table_part_inst.part_serial_no%TYPE           := TRIM(ip_esn);
  p_action_type table_x_call_trans.x_action_type%TYPE := TRIM(ip_action_type);
  -- BRAND_SEP
  p_brand_name table_x_call_trans.x_sub_sourcesystem%TYPE := TRIM(ip_brand_name);
  p_sp_objid NUMBER;
  -- get the esn part inst -- CR55074: Code Changes;
  CURSOR c_pi_phones ( p_part_serial_no VARCHAR2)
  IS
    SELECT *
    FROM   table_part_inst
    WHERE  part_serial_no = p_part_serial_no
    AND    x_domain = 'PHONES';
  c_pi_esn_rec c_pi_phones%ROWTYPE;
  -- get the min part inst -- CR55074: Code Changes;
  CURSOR c_pi_lines ( p_part_serial_no VARCHAR2)
  IS
    SELECT *
    FROM   table_part_inst
    WHERE  part_serial_no = p_part_serial_no
    AND    x_domain = 'LINES';
  c_pi_min_rec c_pi_lines%ROWTYPE;
  CURSOR c_sp(cp_objid NUMBER)
  IS
    SELECT * FROM table_site_part WHERE objid = cp_objid;
  c_sp_rec c_sp%ROWTYPE;
  CURSOR c_code(cc_code_num VARCHAR2)
  IS
    SELECT * FROM table_x_code_table WHERE x_code_number = TRIM(cc_code_num);
  c_code_rec c_code%ROWTYPE;
  CURSOR c_user
  IS
    SELECT * FROM table_user WHERE s_login_name = USER;
  c_user_rec c_user%ROWTYPE;
  CURSOR c_dealer
  IS
    SELECT s.*
    FROM table_site s ,
      table_inv_bin ib ,
      table_part_inst pi
    WHERE 1                  = 1
    AND ib.bin_name          = s.site_id
    AND pi.part_inst2inv_bin = ib.objid
    AND pi.part_serial_no    = p_esn;
  c_dealer_rec c_dealer%ROWTYPE;
BEGIN
  --Verify inputs
  OPEN c_pi_phones(p_esn);
  FETCH c_pi_phones INTO c_pi_esn_rec;
  CLOSE c_pi_phones;
  IF c_pi_esn_rec.objid IS NULL THEN
    op_err_code         := '1';
    op_err_msg          := 'Invalid input: ESN not found.';
    RETURN;
  END IF;
  OPEN c_code(p_action_type);
  FETCH c_code INTO c_code_rec;
  CLOSE c_code;
  IF c_code_rec.objid IS NULL THEN
    op_err_code       := '2';
    op_err_msg        := 'Invalid input: action type ' || p_action_type || ' not found.';
    RETURN;
  END IF;
  OPEN c_sp(c_pi_esn_rec.x_part_inst2site_part);
  FETCH c_sp INTO c_sp_rec;
  CLOSE c_sp;
  IF c_sp_rec.objid IS NULL THEN
    op_err_code     := '3';
    op_err_msg      := 'Invalid site part for ESN ' || p_esn;
    RETURN;
  END IF;
  OPEN c_pi_lines(c_sp_rec.x_min);
  FETCH c_pi_lines INTO c_pi_min_rec;
  CLOSE c_pi_lines;
  IF c_pi_min_rec.objid IS NULL THEN
    op_err_code         := '4';
    op_err_msg          := 'Invalid MIN ' || c_sp_rec.x_min;
    RETURN;
  END IF;
  c_code_rec := NULL;
  OPEN c_code(p_action_type);
  FETCH c_code INTO c_code_rec;
  CLOSE c_code;
  IF c_code_rec.objid IS NULL THEN
    op_err_code       := '5';
    op_err_msg        := 'Invalid input: Action Type ' || NVL(p_action_type ,'') || ' not found.';
    RETURN;
  END IF;
  OPEN c_user;
  FETCH c_user INTO c_user_rec;
  CLOSE c_user;
  OPEN c_dealer;
  FETCH c_dealer INTO c_dealer_rec;
  CLOSE c_dealer;
  sp_seq('x_call_trans' ,op_calltranobj);
  -- BRAND_SEP
  FOR i IN 0..10
  LOOP
    IF i < 10 THEN
      BEGIN
        INSERT
        INTO table_x_call_trans
          (
            objid ,
            call_trans2site_part ,
            x_action_type ,
            x_call_trans2carrier ,
            x_call_trans2dealer ,
            x_call_trans2user ,
            x_min ,
            x_service_id ,
            x_sourcesystem ,
            x_transact_date ,
            x_total_units ,
            x_action_text ,
            x_reason ,
            x_result ,
            x_sub_sourcesystem ,
            x_iccid , -- 07/07/2004 GP
            x_ota_req_type ,
            x_ota_type
          )
          VALUES
          (
            op_calltranobj ,
            c_pi_esn_rec.x_part_inst2site_part ,
            p_action_type ,
            c_pi_min_rec.part_inst2carrier_mkt ,
            c_dealer_rec.objid ,
            c_user_rec.objid ,
            c_sp_rec.x_min ,
            p_esn ,
            ip_sourcesystem ,
            SYSDATE+(i/(24*60*60)) ,
            ip_total_units ,
            c_code_rec.x_code_name ,
            ip_reason ,
            ip_result ,
            DECODE(UPPER(p_brand_name) ,'ENGLISH' ,'200' ,'SPANISH' ,'201' ,p_brand_name) ,
            c_sp_rec.x_iccid --c_pi_esn_rec.x_iccid, (Revision 1.8)
            ,
            ip_ota_req_type ,
            ip_ota_type);
        EXIT;
      EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
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
            'DUP_VAL_ON_INDEX',
            sysdate,
            'DUP_VAL_ON_INDEX:'
            ||i ,
            ip_esn,
            'conver_bo_to_sql_pkg.sp_create_call_trans'
          );
      END;
    ELSE
      INSERT
      INTO table_x_call_trans
        (
          objid ,
          call_trans2site_part ,
          x_action_type ,
          x_call_trans2carrier ,
          x_call_trans2dealer ,
          x_call_trans2user ,
          x_min ,
          x_service_id ,
          x_sourcesystem ,
          x_transact_date ,
          x_total_units ,
          x_action_text ,
          x_reason ,
          x_result ,
          x_sub_sourcesystem ,
          x_iccid ,
          x_ota_req_type ,
          x_ota_type
        )
        VALUES
        (
          op_calltranobj ,
          c_pi_esn_rec.x_part_inst2site_part ,
          p_action_type ,
          c_pi_min_rec.part_inst2carrier_mkt ,
          c_dealer_rec.objid ,
          c_user_rec.objid ,
          c_sp_rec.x_min ,
          p_esn ,
          ip_sourcesystem ,
          SYSDATE ,
          ip_total_units ,
          c_code_rec.x_code_name ,
          ip_reason ,
          ip_result ,
          DECODE(UPPER(p_brand_name) ,'ENGLISH' ,'200' ,'SPANISH' ,'201' ,p_brand_name) ,
          c_sp_rec.x_iccid --c_pi_esn_rec.x_iccid, (Revision 1.8)
          ,
          ip_ota_req_type ,
          ip_ota_type
        );
    END IF;
  END LOOP;
  -- Commit only when the global variable is set to TRUE (default is TRUE)
  IF sa.globals_pkg.g_perform_commit THEN
    COMMIT;
  END IF;
  op_err_code := '0';
  op_err_msg  := 'Successful';
EXCEPTION
WHEN OTHERS THEN
  op_err_code := '99';
  op_err_msg  := 'Unexpected error: ' || SQLERRM;
END sp_create_call_trans;
--
-- BRAND_SEP
PROCEDURE sp_create_call_trans_2
  (
    ip_esn              IN VARCHAR2 ,
    ip_action_type      IN VARCHAR2 ,
    ip_sourcesystem     IN VARCHAR2 ,
    ip_brand_name       IN VARCHAR2 ,
    ip_reason           IN VARCHAR2 ,
    ip_result           IN VARCHAR2 ,
    ip_ota_req_type     IN VARCHAR2 ,
    ip_ota_type         IN VARCHAR2 ,
    ip_total_units      IN NUMBER ,
    ip_orig_login_objid IN NUMBER ,
    ip_action_text      IN VARCHAR2 , --CR13940
    op_calltranobj OUT NUMBER ,
    op_err_code OUT VARCHAR2 ,
    op_err_msg OUT VARCHAR2
  )
IS
  p_esn table_part_inst.part_serial_no%TYPE           := TRIM(ip_esn);
  p_action_type table_x_call_trans.x_action_type%TYPE := TRIM(ip_action_type);
  -- BRAND_SEP
  p_brand_name table_x_call_trans.x_sub_sourcesystem%TYPE := TRIM(ip_brand_name);
  p_sp_objid NUMBER;

  -- get the esn part inst -- CR55074: Code Changes;
  CURSOR c_pi_phones ( p_part_serial_no VARCHAR2)
  IS
    SELECT *
    FROM   table_part_inst
    WHERE  part_serial_no = p_part_serial_no
    AND    x_domain = 'PHONES';
  c_pi_esn_rec c_pi_phones%ROWTYPE;
  -- get the min part inst -- CR55074: Code Changes;
  CURSOR c_pi_lines ( p_part_serial_no VARCHAR2)
  IS
    SELECT *
    FROM   table_part_inst
    WHERE  part_serial_no = p_part_serial_no
    AND    x_domain = 'LINES';
  c_pi_min_rec c_pi_lines%ROWTYPE;

  --CURSOR c_pi(cp_part_serial_num VARCHAR2)
  --IS
  --  SELECT * FROM table_part_inst
  --  WHERE part_serial_no = cp_part_serial_num;

  CURSOR c_sp(cp_objid NUMBER)
  IS
    SELECT * FROM table_site_part WHERE objid = cp_objid;
  c_sp_rec c_sp%ROWTYPE;
  CURSOR c_code(cc_code_num VARCHAR2)
  IS
    SELECT * FROM table_x_code_table WHERE x_code_number = TRIM(cc_code_num);
  c_code_rec c_code%ROWTYPE;
  CURSOR c_user
  IS
    SELECT * FROM table_user WHERE s_login_name = USER;
  CURSOR c_dealer
  IS
    SELECT s.*
    FROM table_site s ,
      table_inv_bin ib ,
      table_part_inst pi
    WHERE 1                  = 1
    AND ib.bin_name          = s.site_id
    AND pi.part_inst2inv_bin = ib.objid
    AND pi.part_serial_no    = p_esn;
  c_dealer_rec c_dealer%ROWTYPE;
  --1.9
  CURSOR c_user2
  IS
    SELECT * FROM table_user WHERE objid = ip_orig_login_objid;
  c_user_rec c_user%ROWTYPE;
  --1.9
BEGIN
  --Verify inputs
  OPEN c_pi_phones(p_esn);
  FETCH c_pi_phones INTO c_pi_esn_rec;
  CLOSE c_pi_phones;
  IF c_pi_esn_rec.objid IS NULL THEN
    op_err_code         := '1';
    op_err_msg          := 'Invalid input: ESN not found.';
    RETURN;
  END IF;
  OPEN c_code(p_action_type);
  FETCH c_code INTO c_code_rec;
  CLOSE c_code;
  IF c_code_rec.objid IS NULL THEN
    op_err_code       := '2';
    op_err_msg        := 'Invalid input: action type ' || p_action_type || ' not found.';
    RETURN;
  END IF;
  OPEN c_sp(c_pi_esn_rec.x_part_inst2site_part);
  FETCH c_sp INTO c_sp_rec;
  CLOSE c_sp;
  IF c_sp_rec.objid IS NULL THEN
    op_err_code     := '3';
    op_err_msg      := 'Invalid site part for ESN ' || p_esn;
    RETURN;
  END IF;
  OPEN c_pi_lines(c_sp_rec.x_min);
  FETCH c_pi_lines INTO c_pi_min_rec;
  CLOSE c_pi_lines;
  IF c_pi_min_rec.objid IS NULL THEN
    op_err_code         := '4';
    op_err_msg          := 'Invalid MIN ' || c_sp_rec.x_min;
    RETURN;
  END IF;
  IF ip_orig_login_objid IS NULL THEN
    OPEN c_user;
    FETCH c_user INTO c_user_rec;
    CLOSE c_user;
  ELSE
    OPEN c_user2;
    FETCH c_user2 INTO c_user_rec;
    CLOSE c_user2;
  END IF;
  --1.9
  OPEN c_dealer;
  FETCH c_dealer INTO c_dealer_rec;
  CLOSE c_dealer;
  sp_seq('x_call_trans' ,op_calltranobj);
  -- BRAND_SEP
  INSERT
  INTO table_x_call_trans
    (
      objid ,
      call_trans2site_part ,
      x_action_type ,
      x_call_trans2carrier ,
      x_call_trans2dealer ,
      x_call_trans2user ,
      x_min ,
      x_service_id ,
      x_sourcesystem ,
      x_transact_date ,
      x_total_units ,
      x_action_text ,
      x_reason ,
      x_result ,
      x_sub_sourcesystem ,
      x_iccid , -- 07/07/2004 GP
      x_ota_req_type ,
      x_ota_type
    )
    VALUES
    (
      op_calltranobj ,
      c_pi_esn_rec.x_part_inst2site_part ,
      p_action_type ,
      c_pi_min_rec.part_inst2carrier_mkt ,
      c_dealer_rec.objid ,
      c_user_rec.objid ,
      c_sp_rec.x_min ,
      p_esn ,
      ip_sourcesystem ,
      SYSDATE ,
      ip_total_units ,
      DECODE(ip_action_text ,NULL ,c_code_rec.x_code_name ,ip_action_text) ,
      ip_reason , -- CR13940
      --ip_total_units, c_code_rec.x_code_name, ip_reason,
      ip_result ,
      DECODE(UPPER(p_brand_name) ,'ENGLISH' ,'200' ,'SPANISH' ,'201' ,p_brand_name)
      --
      -- CR14799 Start kacosta 11/24/2010
      --,c_sp_rec.x_iccid
      ,
      NVL(TRIM(c_sp_rec.x_iccid) ,c_pi_esn_rec.x_iccid)
      -- CR14799 End kacosta 11/24/2010
      --
      ,
      --c_pi_esn_rec.x_iccid, (Revision 1.8)
      ip_ota_req_type ,
      ip_ota_type
    );
  -- Commit only when the global variable is set to TRUE (default is TRUE)
  IF sa.globals_pkg.g_perform_commit THEN
    COMMIT;
  END IF;
  op_err_code := '0';
  op_err_msg  := 'Successful';
EXCEPTION
WHEN OTHERS THEN
  op_err_code := '99';
  op_err_msg  := 'Unexpected error: ' || SQLERRM;
END sp_create_call_trans_2;
--DO NOT MODIFY - OVERLOADED
FUNCTION get_default_click_plan
  (
    p_dll            IN NUMBER ,
    p_restricted_use IN VARCHAR2
  )
  RETURN NUMBER
IS
  CURSOR click_plan_curs(c_click_type IN VARCHAR2)
  IS
    SELECT objid
    FROM table_x_click_plan
    WHERE x_click_type = c_click_type
    AND ROWNUM         < 2;
  click_plan_rec click_plan_curs%ROWTYPE;
  l_click_type VARCHAR2(30);
BEGIN
  IF p_restricted_use    != 'NET10RESTICT' AND p_dll IN ('10') THEN
    l_click_type         := 'R2';
  ELSIF p_restricted_use != 'NET10RESTICT' AND p_dll IN ('12' ,'13' ,'17') THEN
    l_click_type         := 'R3';
  ELSIF p_restricted_use != 'NET10RESTICT' AND p_dll IN ('11' ,'14' ,'15' ,'16') THEN
    l_click_type         := 'R4';
  ELSIF p_restricted_use != 'NET10RESTICT' AND p_dll IN ('41' ,'42') THEN
    l_click_type         := 'CSTM-TF-CDMA-DATA';
  ELSIF p_restricted_use  = 'NET10RESTICT' AND p_dll IN ('41' ,'42') THEN
    l_click_type         := 'NT-DEFAULT-CDMA';
  ELSIF p_restricted_use  = 'NET10RESTICT' AND p_dll IN ('43') THEN
    l_click_type         := 'NT-DEFAULT-GSM';
  ELSIF p_restricted_use  = 'NET10RESTICT' THEN
    --CR11593
    --l_click_type := 'R5';
    l_click_type := 'NT-DEFAULT-GSM';
  ELSE
    --CR11593
    --RETURN NULL;
    l_click_type := 'CSTM-TF-GSM-0.3';
  END IF;
  --
  OPEN click_plan_curs(l_click_type);
  FETCH click_plan_curs INTO click_plan_rec;
  IF click_plan_curs%FOUND THEN
    CLOSE click_plan_curs;
    RETURN click_plan_rec.objid;
  ELSE
    CLOSE click_plan_curs;
    RETURN NULL;
  END IF;
  CLOSE click_plan_curs;
END get_default_click_plan; --OLD OVERLOADED
FUNCTION get_default_click_plan(
    p_esn_objid IN NUMBER)
  RETURN NUMBER --objid click plan
IS
  -- Part number based click plan
  CURSOR c1
  IS
    SELECT cp.objid
    FROM table_x_click_plan cp ,
      table_part_inst pi ,
      table_mod_level ml
    WHERE pi.objid              = p_esn_objid
    AND pi.n_part_inst2part_mod = ml.objid
    AND cp.click_plan2part_num  = ml.part_info2part_num
    AND ROWNUM                  < 2;
  part_num_click_rec c1%ROWTYPE;
  -- Brand / TEchnology based click plan
  CURSOR c2
  IS
    SELECT cp.objid
    FROM table_x_click_plan cp ,
      table_bus_org bo ,
      table_part_num pn ,
      table_part_inst pi ,
      table_mod_level ml
    WHERE pi.objid              = p_esn_objid
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND bo.objid                = pn.part_num2bus_org
    AND cp.x_technology         = pn.x_technology
    AND bo.org_id               = UPPER(cp.x_bus_org)
    AND ROWNUM                  < 2;
  default_click_rec c2%ROWTYPE;
BEGIN
  OPEN c1;
  FETCH c1 INTO part_num_click_rec;
  IF c1%FOUND THEN
    CLOSE c1;
    RETURN part_num_click_rec.objid;
  ELSE
    CLOSE c1;
    OPEN c2;
    FETCH c2 INTO default_click_rec;
    IF c2%FOUND THEN
      CLOSE c2;
      RETURN default_click_rec.objid;
    ELSE
      CLOSE c2;
      RETURN 0;
      -- no click found
    END IF;
  END IF;
END get_default_click_plan;
--
FUNCTION get_dealer_click_plan(
    p_esn_objid IN NUMBER)
  RETURN NUMBER
IS
  CURSOR dealer_click_plan_curs
  IS
    SELECT cp.objid
    FROM table_x_click_plan cp ,
      table_site s ,
      table_inv_bin ib ,
      table_part_inst pi
    WHERE cp.click_plan2dealer = s.objid
    AND s.site_id              = ib.bin_name
    AND ib.objid               = pi.part_inst2inv_bin
    AND pi.objid               = p_esn_objid;
  dealer_click_plan_rec dealer_click_plan_curs%ROWTYPE;
BEGIN
  OPEN dealer_click_plan_curs;
  FETCH dealer_click_plan_curs INTO dealer_click_plan_rec;
  IF dealer_click_plan_curs%FOUND THEN
    CLOSE dealer_click_plan_curs;
    RETURN dealer_click_plan_rec.objid;
  ELSE
    CLOSE dealer_click_plan_curs; --Fix OPEN_CURSORS
    RETURN NULL;
  END IF;
  CLOSE dealer_click_plan_curs;
END get_dealer_click_plan;
--
PROCEDURE update_click(
    p_esn_objid            IN NUMBER ,
    p_call_trans_objid     IN NUMBER ,
    p_new_click_plan_objid IN NUMBER ,
    p_site_part_objid      IN NUMBER )
IS
  CURSOR carr_click_plan_curs
  IS
    SELECT cp.objid
    FROM table_x_click_plan cp ,
      table_x_call_trans ct
    WHERE 1                   = 1
    AND cp.x_status           = 1
    AND cp.click_plan2carrier = ct.x_call_trans2carrier
    AND ct.objid              = p_call_trans_objid;
  carr_click_plan_rec carr_click_plan_curs%ROWTYPE;
  use_this_click_plan NUMBER;
  CURSOR check_dealer_click_curs(c_click_plan_objid IN NUMBER)
  IS
    SELECT 1
    FROM table_x_click_plan
    WHERE objid  = c_click_plan_objid
    AND x_status = 1;
  check_dealer_click_rec check_dealer_click_curs%ROWTYPE;
BEGIN
  IF p_new_click_plan_objid IS NOT NULL THEN
    use_this_click_plan     := p_new_click_plan_objid;
  ELSE
    OPEN carr_click_plan_curs;
    FETCH carr_click_plan_curs INTO carr_click_plan_rec;
    IF carr_click_plan_curs%FOUND THEN
      CLOSE carr_click_plan_curs;
      use_this_click_plan := carr_click_plan_rec.objid;
    ELSE
      CLOSE carr_click_plan_curs;
      use_this_click_plan    := get_dealer_click_plan(p_esn_objid);
      IF use_this_click_plan IS NULL THEN
        use_this_click_plan  := get_default_click_plan(p_esn_objid);
      END IF;
    END IF;
  END IF;
  UPDATE table_x_click_plan_hist
  SET plan_hist2site_part   = curr_hist2site_part ,
    curr_hist2site_part     = NULL
  WHERE curr_hist2site_part = p_site_part_objid;
  UPDATE table_x_click_plan_hist
  SET x_end_date            = SYSDATE
  WHERE plan_hist2site_part = p_site_part_objid
  AND x_end_date            > TO_DATE('01-jan-1753' ,'dd-mon-yyyy');
  INSERT
  INTO table_x_click_plan_hist
    (
      objid ,
      curr_hist2site_part ,
      plan_hist2site_part ,
      x_end_date ,
      x_start_date ,
      plan_hist2click_plan
    )
    VALUES
    (
      sa.seq('x_click_plan_hist') ,
      p_site_part_objid ,
      NULL ,
      TO_DATE('01-jan-1753' ,'dd-mon-yyyy') ,
      SYSDATE ,
      use_this_click_plan
    );
END update_click;
--
FUNCTION getvoicemailnum
  (
    p_esn_objid IN NUMBER
  )
  RETURN VARCHAR2
IS
  CURSOR voicemail_num_curs
  IS
    SELECT p.x_vm_access_num
    FROM table_x_parent p ,
      table_x_carrier_group cg ,
      table_x_carrier c ,
      table_part_inst pi
    WHERE p.objid                = cg.x_carrier_group2x_parent
    AND cg.objid                 = c.carrier2carrier_group
    AND c.objid                  = pi.part_inst2carrier_mkt
    AND pi.part_to_esn2part_inst = p_esn_objid;
  voicemail_num_rec voicemail_num_curs%ROWTYPE;
BEGIN
  OPEN voicemail_num_curs;
  FETCH voicemail_num_curs INTO voicemail_num_rec;
  IF voicemail_num_curs%FOUND THEN
    CLOSE voicemail_num_curs;
    RETURN voicemail_num_rec.x_vm_access_num;
  ELSE
    CLOSE voicemail_num_curs;
    RETURN NULL;
  END IF;
  CLOSE voicemail_num_curs;
END getvoicemailnum;
--
PROCEDURE updatefreevoicemail(
    p_esn_objid  IN NUMBER ,
    p_fvm_status IN NUMBER ,
    p_fvm_number IN VARCHAR2 )
IS
BEGIN
  UPDATE sa.x_free_voice_mail
  SET x_fvm_status        = p_fvm_status ,
    x_fvm_number          = p_fvm_number ,
    x_fvm_time_stamp      = SYSDATE
  WHERE free_vm2part_inst = p_esn_objid;
END updatefreevoicemail;
--
FUNCTION getfreevoicemailstatus(
    p_esn_objid IN NUMBER)
  RETURN VARCHAR2
IS
  --
  CURSOR voicemail_status_curs
  IS
    SELECT x_fvm_status free_voice_sts
    FROM sa.x_free_voice_mail fvm
    WHERE fvm.free_vm2part_inst = p_esn_objid;
  voicemail_status_rec voicemail_status_curs%ROWTYPE;
BEGIN
  OPEN voicemail_status_curs;
  FETCH voicemail_status_curs INTO voicemail_status_rec;
  IF voicemail_status_curs%NOTFOUND THEN
    CLOSE voicemail_status_curs;
    RETURN NULL;
  ELSE
    CLOSE voicemail_status_curs;
    RETURN voicemail_status_rec.free_voice_sts;
  END IF;
  CLOSE voicemail_status_curs;
END getfreevoicemailstatus;
-- BRAND_SEP
--
PROCEDURE updateflags(
    p_esn_objid            IN NUMBER ,
    p_call_trans_objid     IN NUMBER ,
    p_new_click_plan_objid IN NUMBER ,
    p_site_part_objid      IN NUMBER ,
    p_code_type            IN VARCHAR2 ,
    p_x_type               IN VARCHAR2 )
IS
  CURSOR call_trans_curs
  IS
    SELECT x_total_units ,
      x_service_id ,
      x_sourcesystem
    FROM table_x_call_trans
    WHERE objid = p_call_trans_objid;
  call_trans_rec call_trans_curs%ROWTYPE;
  CURSOR carr_pers_curs
  IS
    SELECT cp.objid carr_pers_objid ,
      ct.x_min ,
      ct.x_service_id ,
      ct.x_total_units
    FROM table_x_carr_personality cp ,
      table_x_carrier c ,
      table_x_call_trans ct
    WHERE 1      = 1
    AND cp.objid = c.carrier2personality
    AND c.objid  = ct.x_call_trans2carrier
    AND ct.objid = p_call_trans_objid;
  carr_pers_rec carr_pers_curs%ROWTYPE;
  CURSOR esn_curs
  IS
    SELECT x_clear_tank FROM table_part_inst WHERE objid = p_esn_objid;
  esn_rec esn_curs%ROWTYPE;
  CURSOR user_curs
  IS
    SELECT objid FROM table_user WHERE s_login_name = UPPER(USER);
  user_rec user_curs%ROWTYPE;
  --------------------------------------------------------------------------------------------------------------------
  CURSOR extra_code_temp_curs
  IS
    SELECT COUNT(*) cnt
    FROM table_x_code_hist_temp
    WHERE x_code_temp2x_call_trans = p_call_trans_objid
    AND UPPER(x_type)             IN ('GRACE' ,'CLICKS' ,'RESOLUTION');
  extra_code_temp_rec extra_code_temp_curs%ROWTYPE;
  CURSOR extra_code_temp_curs_2
  IS
    SELECT COUNT(*) cnt
    FROM table_x_code_hist_temp
    WHERE x_code_temp2x_call_trans = p_call_trans_objid
    AND UPPER(x_type)             IN ('RESTRICTION' ,'PERSONALITY' ,'LOCAL_SID' ,'AREA_CODES' ,'MASTER_SID');
  extra_code_temp_rec_2 extra_code_temp_curs_2%ROWTYPE;
  --CR5600 Start
  CURSOR site_part_curs(c_site_part_objid IN NUMBER)
  IS
    SELECT * FROM table_site_part WHERE objid = c_site_part_objid;
  site_part_rec site_part_curs%ROWTYPE;
  --CR5600 End
  --------------------------------------------------------------------------------------------------------------------
  blnupdateclick  BOOLEAN := FALSE;
  blnupdatepers   BOOLEAN := FALSE;
  strvoicemailnum VARCHAR2(30);
  strfreevmsts    VARCHAR2(30);
BEGIN
  OPEN extra_code_temp_curs;
  FETCH extra_code_temp_curs INTO extra_code_temp_rec;
  CLOSE extra_code_temp_curs;
  OPEN extra_code_temp_curs_2;
  FETCH extra_code_temp_curs_2 INTO extra_code_temp_rec_2;
  CLOSE extra_code_temp_curs_2;
  --CR5600 Start
  OPEN site_part_curs(p_site_part_objid);
  FETCH site_part_curs INTO site_part_rec;
  CLOSE site_part_curs;
  --CR5600 End
  IF UPPER(p_code_type) IN ('GRACE' ,'CLICKS' ,'RESOLUTION' ) AND extra_code_temp_rec.cnt = 1 THEN
    --CR5600 Start
    IF site_part_rec.site_part2x_new_plan IS NOT NULL THEN
      UPDATE table_site_part
      SET site_part2x_plan   = site_part2x_new_plan ,
        site_part2x_new_plan = NULL
      WHERE objid            = p_site_part_objid;
    END IF;
    --CR5600 End
    -- BRAND_SEP
    blnupdateclick := TRUE;
    update_click(p_esn_objid ,p_call_trans_objid ,p_new_click_plan_objid ,p_site_part_objid);
  END IF;
  IF UPPER(p_code_type) IN ('RESTRICTION' ,'PERSONALITY' ,'LOCAL_SID' ,'AREA_CODES' ,'MASTER_SID') AND extra_code_temp_rec_2.cnt = 1 THEN
    blnupdatepers                                                                                                               := TRUE;
    OPEN carr_pers_curs;
    FETCH carr_pers_curs INTO carr_pers_rec;
    IF carr_pers_curs%FOUND THEN
      UPDATE table_part_inst
      SET part_inst2x_pers = carr_pers_rec.carr_pers_objid
      WHERE part_serial_no = carr_pers_rec.x_service_id;
      UPDATE table_part_inst
      SET part_inst2x_pers   = carr_pers_rec.carr_pers_objid ,
        part_inst2x_new_pers = NULL
        --CR21051 Start Kacosta 05/31/2012
        ,
        n_part_inst2part_mod =
        CASE
          WHEN NVL(n_part_inst2part_mod ,0) <> 23070541
          THEN 23070541
          ELSE n_part_inst2part_mod
        END
        --CR21051 End Kacosta 05/31/2012
      WHERE part_serial_no = carr_pers_rec.x_min
	  and x_domain = 'LINES';  --CR55074: Code Changes;
    END IF;
    CLOSE carr_pers_curs;
  END IF;
  IF UPPER(p_code_type) IN ('FREEVM' ,'CLEARFVM') THEN
    strvoicemailnum := getvoicemailnum(p_esn_objid);
    strfreevmsts    := getfreevoicemailstatus(p_esn_objid);
    IF strfreevmsts  = '1'
      --AND TO_NUMBER (p_dll) >= 10
      AND UPPER(p_code_type) = 'FREEVM' THEN
      updatefreevoicemail(p_esn_objid ,2 ,strvoicemailnum);
    ELSIF strfreevmsts = '3'
      --AND TO_NUMBER (p_dll) >= 10
      AND UPPER(p_code_type) = 'CLEARFVM' THEN
      updatefreevoicemail(p_esn_objid ,0 ,NULL);
    END IF;
  END IF;
  OPEN esn_curs;
  FETCH esn_curs INTO esn_rec;
  CLOSE esn_curs;
  IF UPPER(p_code_type) = 'TIME_CODE' AND esn_rec.x_clear_tank = '1' --CR5694 Added UPPER clause
    THEN
    UPDATE table_part_inst SET x_clear_tank = 0 WHERE objid = p_esn_objid;
    OPEN call_trans_curs;
    FETCH call_trans_curs INTO call_trans_rec;
    CLOSE call_trans_curs;
    OPEN user_curs;
    FETCH user_curs INTO user_rec;
    CLOSE user_curs;
    UPDATE table_x_zero_out_max
    SET x_reac_date_time = SYSDATE ,
      x_deposit          = call_trans_rec.x_total_units ,
      x_sourcesystem     = call_trans_rec.x_sourcesystem ,
      x_zero_out2user    = user_rec.objid
    WHERE x_esn          = call_trans_rec.x_service_id
    AND objid            =
      (SELECT MAX(objid)
      FROM table_x_zero_out_max
      WHERE x_esn             = call_trans_rec.x_service_id
      AND x_transaction_type IN (2 ,5)
      AND (x_reac_date_time  IS NULL
      OR x_reac_date_time     = TO_DATE('01-jan-1753' ,'dd-mon-yyyy'))
      );
  END IF;
END updateflags;
--
FUNCTION getpromodetails(
    p_esn            IN VARCHAR2 ,
    p_red_card_objid IN VARCHAR2 )
  RETURN VARCHAR2
IS
  CURSOR red_card_status_curs
  IS
    SELECT x_part_inst_status FROM table_part_inst WHERE objid = p_red_card_objid;
  red_card_status_rec red_card_status_curs%ROWTYPE;
  CURSOR red_card_curs
  IS
    SELECT p.x_program_type
    FROM table_x_promotion p ,
      table_part_num pn ,
      table_mod_level ml ,
      table_part_inst pi
    WHERE 1     = 1
    AND p.objid = pn.part_num2x_promotion
    AND pn.x_card_type
      || ''      = 'AUTOPAY'
    AND pn.objid = ml.part_info2part_num
    AND ml.objid = pi.n_part_inst2part_mod
    AND pi.objid = p_red_card_objid;
  red_card_rec red_card_curs%ROWTYPE;
  CURSOR auto_pay_curs
  IS
    SELECT *
    FROM table_x_autopay_details
    WHERE x_esn   = p_esn
    AND x_status IN ('A' ,'E');
  auto_pay_rec auto_pay_curs%ROWTYPE;
BEGIN
  OPEN red_card_status_curs;
  FETCH red_card_status_curs INTO red_card_status_rec;
  CLOSE red_card_status_curs;
  OPEN red_card_curs;
  FETCH red_card_curs INTO red_card_rec;
  IF red_card_curs%NOTFOUND THEN
    CLOSE red_card_curs;
    RETURN NULL;
  ELSE
    OPEN auto_pay_curs;
    FETCH auto_pay_curs INTO auto_pay_rec;
    IF auto_pay_curs%NOTFOUND THEN
      CLOSE red_card_curs;
      CLOSE auto_pay_curs;
      RETURN 'New';
    ELSIF auto_pay_rec.x_program_type = red_card_rec.x_program_type AND auto_pay_rec.x_receive_status IS NULL THEN
      CLOSE red_card_curs;
      CLOSE auto_pay_curs;
      IF red_card_status_rec.x_part_inst_status = '42' THEN
        RETURN NULL;
      ELSE
        RETURN 'Pending';
      END IF;
    ELSIF auto_pay_rec.x_program_type = red_card_rec.x_program_type AND auto_pay_rec.x_receive_status IS NOT NULL THEN
      CLOSE red_card_curs;
      CLOSE auto_pay_curs;
      IF red_card_status_rec.x_part_inst_status = '42' THEN
        RETURN NULL;
      ELSE
        RETURN 'Complete';
      END IF;
    END IF;
    CLOSE auto_pay_curs;
  END IF;
  CLOSE red_card_curs;
  RETURN NULL;
END getpromodetails;
--
PROCEDURE clearredcards(
    p_call_trans_objid IN NUMBER ,
    p_esn_objid        IN NUMBER ,
    p_blnboolstatus    IN BOOLEAN DEFAULT TRUE )
IS
  CURSOR user_curs
  IS
    SELECT objid FROM table_user WHERE s_login_name = UPPER(USER);
  user_rec user_curs%ROWTYPE;
  CURSOR part_inst_curs
  IS
    SELECT * FROM table_part_inst pi WHERE objid = p_esn_objid;
  part_inst_rec part_inst_curs%ROWTYPE;
  CURSOR call_trans_curs
  IS
    SELECT * FROM table_x_call_trans WHERE objid = p_call_trans_objid;
  call_trans_rec call_trans_curs%ROWTYPE;
  CURSOR contact_curs(c_site_part_objid IN NUMBER)
  IS
    SELECT c.*
    FROM table_contact c ,
      table_contact_role cr ,
      table_site_part sp
    WHERE c.objid            = cr.contact_role2contact
    AND cr.contact_role2site = sp.site_part2site
    AND sp.objid             = c_site_part_objid;
  contact_rec contact_curs%ROWTYPE;
  CURSOR red_card_temp_curs
  IS
    SELECT rct.temp_red_card2x_call_trans red_card2call_trans ,
      pi.objid red_smp2inv_smp ,
      NULL red_smp2x_pi_hist ,
      rct.x_redeem_days x_access_days ,
      rct.x_red_code x_red_code ,
      SYSDATE x_red_date ,
      rct.x_red_units x_red_units ,
      pi.part_serial_no x_smp ,
      rct.x_status x_status ,
      rct.x_result x_result ,
      ct.x_call_trans2user x_created_by2user ,
      pi.x_insert_date x_inv_insert_date ,
      pi.x_creation_date x_last_ship_date ,
      pi.x_order_number x_order_number ,
      pi.x_po_num x_po_num ,
      pi.part_inst2inv_bin x_red_card2inv_bin ,
      pi.n_part_inst2part_mod x_red_card2part_mod
    FROM table_x_call_trans ct ,
      table_part_inst pi ,
      table_x_red_card_temp rct
    WHERE 1                            = 1
    AND ct.objid                       = rct.temp_red_card2x_call_trans
    AND pi.x_red_code                  = rct.x_red_code
	and pi.x_domain                    = 'REDEMPTION CARDS'  --CR55074: Code Changes
    AND rct.temp_red_card2x_call_trans = p_call_trans_objid;

  l_blnboolstatus VARCHAR2(30);
BEGIN
  IF p_blnboolstatus THEN
    l_blnboolstatus := 'TRUE';
  ELSE
    l_blnboolstatus := 'FALSE';
  END IF;
  FOR red_card_temp_rec IN red_card_temp_curs
  LOOP
    INSERT
    INTO table_x_red_card
      (
        objid ,
        red_card2call_trans ,
        red_smp2inv_smp ,
        red_smp2x_pi_hist ,
        x_access_days ,
        x_red_code ,
        x_red_date ,
        x_red_units ,
        x_smp ,
        x_status ,
        x_result ,
        x_created_by2user ,
        x_inv_insert_date ,
        x_last_ship_date ,
        x_order_number ,
        x_po_num ,
        x_red_card2inv_bin ,
        x_red_card2part_mod
      )
      VALUES
      (
        sa.seq('x_red_card') ,
        red_card_temp_rec.red_card2call_trans ,
        DECODE(l_blnboolstatus ,'FALSE' ,red_card_temp_rec.red_smp2inv_smp ,NULL) ,
        NULL ,
        red_card_temp_rec.x_access_days ,
        red_card_temp_rec.x_red_code ,
        red_card_temp_rec.x_red_date ,
        red_card_temp_rec.x_red_units ,
        red_card_temp_rec.x_smp ,
        DECODE(l_blnboolstatus ,'FALSE' ,'Failed' ,'NOT PROCESSED') ,
        DECODE(l_blnboolstatus ,'FALSE' ,'Failed' ,'Completed') ,
        red_card_temp_rec.x_created_by2user ,
        red_card_temp_rec.x_inv_insert_date ,
        red_card_temp_rec.x_last_ship_date ,
        red_card_temp_rec.x_order_number ,
        red_card_temp_rec.x_po_num ,
        red_card_temp_rec.x_red_card2inv_bin ,
        red_card_temp_rec.x_red_card2part_mod
      );
    IF p_blnboolstatus = FALSE THEN
      UPDATE table_part_inst
      SET x_part_inst_status  = '40' ,
        status2x_code_table   = 982 ,
        part_to_esn2part_inst = p_esn_objid
      WHERE objid             = red_card_temp_rec.red_smp2inv_smp;

    ELSE
      UPDATE table_part_inst
      SET x_part_inst_status  = '41' ,
        status2x_code_table   = 983 ,
        part_to_esn2part_inst = p_esn_objid
      WHERE objid             = red_card_temp_rec.red_smp2inv_smp;
      IF getpromodetails(part_inst_rec.part_serial_no ,red_card_temp_rec.red_smp2inv_smp) = 'New'
      THEN
        ------------------------------------------------------------------------------------------------
        OPEN user_curs;
        FETCH user_curs INTO user_rec;
        IF user_curs%NOTFOUND THEN
          user_rec.objid := 268435556;
        END IF;
        CLOSE user_curs;
        OPEN part_inst_curs;
        FETCH part_inst_curs INTO part_inst_rec;
        CLOSE part_inst_curs;
        OPEN call_trans_curs;
        FETCH call_trans_curs INTO call_trans_rec;
        CLOSE call_trans_curs;
        OPEN contact_curs(call_trans_rec.call_trans2site_part);
        FETCH contact_curs INTO contact_rec;
        CLOSE contact_curs;
        INSERT
        INTO table_x_autopay_details
          (
            objid ,
            x_creation_date ,
            x_esn ,
            x_program_type ,
            x_account_status ,
            x_status ,
            x_start_date ,
            x_program_name ,
            x_enroll_date ,
            x_first_name ,
            x_last_name ,
            x_autopay_details2site_part ,
            x_autopay_details2x_part_inst ,
            x_autopay_details2contact
          )
          VALUES
          (
            sa.seq('x_autopay_details') ,
            SYSDATE ,
            part_inst_rec.part_serial_no ,
            'New' ,
            3 ,
            'A' ,
            SYSDATE ,
            'Bonus Plan' ,
            SYSDATE ,
            contact_rec.first_name ,
            contact_rec.last_name ,
            call_trans_rec.call_trans2site_part ,
            p_esn_objid ,
            contact_rec.objid
          );
        INSERT
        INTO table_x_call_trans
          (
            objid ,
            x_action_type ,
            x_min ,
            x_service_id ,
            x_line_status ,
            x_sourcesystem ,
            x_transact_date ,
            x_action_text ,
            x_reason ,
            x_result ,
            x_sub_sourcesystem ,
            call_trans2site_part ,
            x_call_trans2carrier ,
            x_call_trans2dealer ,
            x_call_trans2user
          )
          VALUES
          (
            sa.seq('x_call_trans') ,
            '82' ,
            call_trans_rec.x_min ,
            call_trans_rec.x_service_id ,
            call_trans_rec.x_line_status ,
            call_trans_rec.x_sourcesystem ,
            SYSDATE ,
            'STAYACT SUBSCRIBE' ,
            'STAYACT SUBSCRIBE' ,
            'Completed' ,
            call_trans_rec.x_sub_sourcesystem ,
            call_trans_rec.call_trans2site_part ,
            call_trans_rec.x_call_trans2carrier ,
            call_trans_rec.x_call_trans2dealer ,
            user_rec.objid
          );
        ------------------------------------------------------------------------------------------------
      END IF;
      --CR4811 Starts
      DELETE
      FROM  table_part_inst
      WHERE part_serial_no = red_card_temp_rec.x_smp
	  and   x_domain = 'REDEMPTION CARDS';  --CR55034: Code Changes

      DELETE
      FROM table_x_red_card_temp
      WHERE x_red_code = red_card_temp_rec.x_red_code;
      --CR4811 Ends
    END IF;
  END LOOP;
END clearredcards;
--
FUNCTION checknoinvcarrier(
    p_iccid IN VARCHAR2 ,
    p_zip   IN VARCHAR2 )
  RETURN NUMBER
IS
  CURSOR iccid_part_num_curs
  IS
    SELECT pn.part_number
    FROM table_part_num pn ,
      table_mod_level ml ,
      table_x_sim_inv si
    WHERE pn.objid         = ml.part_info2part_num
    AND ml.objid           = si.x_sim_inv2part_mod
    AND si.x_sim_serial_no = p_iccid;
  iccid_part_num_rec iccid_part_num_curs%ROWTYPE;
  -- CR10777 added carriersimpref table to cursor
  -- CR10777 remove table_x_account
  CURSOR check_no_inv_carr_curs(c_part_number IN VARCHAR2)
  IS
    SELECT DISTINCT c.x_carrier_id ,
      e.x_no_inventory ,
      e.x_parent_id
    FROM sa.carrierzones a ,
      sa.npanxx2carrierzones b ,
      sa.table_x_carrier c ,
      sa.table_x_carrier_group d ,
      table_x_parent e ,
      -- table_x_account f,
      carriersimpref s
    WHERE 1 = 1
      --AND a.sim_profile IS NOT NULL
    AND b.gsm_tech     = 'GSM'
    AND a.st           = b.state
    AND a.zone         = b.zone
    AND a.zip          = p_zip
    AND a.carrier_name = s.carrier_name
    AND s.sim_profile  = c_part_number
      --AND (   a.sim_profile = c_part_number
      --     OR a.sim_profile_2 = c_part_number
      --    )
    AND b.carrier_id               = c.x_carrier_id
    AND c.x_status                 = 'ACTIVE'
    AND c.carrier2carrier_group    = d.objid
    AND d.x_carrier_group2x_parent = e.objid;
  --          AND f.account2x_carrier = c.objid
  --          AND f.x_status = 'Active';
  check_no_inv_carr_rec check_no_inv_carr_curs%ROWTYPE;
  outvar NUMBER;
BEGIN
  OPEN iccid_part_num_curs;
  FETCH iccid_part_num_curs INTO iccid_part_num_rec;
  OPEN check_no_inv_carr_curs(iccid_part_num_rec.part_number);
  FETCH check_no_inv_carr_curs INTO check_no_inv_carr_rec;
  IF check_no_inv_carr_curs%FOUND THEN
    outvar := check_no_inv_carr_rec.x_no_inventory;
  ELSE
    outvar := NULL;
  END IF;
  CLOSE check_no_inv_carr_curs;
  CLOSE iccid_part_num_curs;
  RETURN outvar;
END checknoinvcarrier;
--
FUNCTION updatecodehistory(
    p_call_trans_objid IN NUMBER)
  RETURN BOOLEAN
IS
  CURSOR code_hist_curs
  IS
    SELECT *
    FROM table_x_code_hist
    WHERE code_hist2call_trans = p_call_trans_objid
    AND x_code_accepted        = 'NO';
  code_hist_rec code_hist_curs%ROWTYPE;
BEGIN
  UPDATE table_x_code_hist
  SET x_code_accepted        = 'YES'
  WHERE code_hist2call_trans = p_call_trans_objid
  AND x_code_accepted        = 'NO';
  OPEN code_hist_curs;
  FETCH code_hist_curs INTO code_hist_rec;
  IF code_hist_curs%FOUND AND code_hist_rec.x_seq_update = 1 THEN
    CLOSE code_hist_curs;
    RETURN TRUE;
  ELSE
    CLOSE code_hist_curs;
    RETURN FALSE;
  END IF;
  CLOSE code_hist_curs;
END updatecodehistory;
--
FUNCTION getdefaultpromocode(
    p_restricted_use IN NUMBER ,
    p_program_type   IN NUMBER ,
    p_esn_status     IN VARCHAR2 )
  RETURN VARCHAR2
IS
  -- CR7984
BEGIN
  IF p_restricted_use = 3 AND p_program_type = 2 AND p_esn_status = '50' THEN
    RETURN 'DIGITAL4';
  ELSIF p_program_type = 2 AND p_esn_status = '50' THEN
    RETURN 'DIGITAL2';
  END IF;
END getdefaultpromocode;
-- BEGIN CR5728
FUNCTION activationpromoused(
    p_esn IN VARCHAR2)
  RETURN VARCHAR2
IS
  CURSOR activation_promo_used_curs
  IS
    SELECT 'X'
    FROM table_x_promotion p ,
      table_x_promo_hist ph ,
      table_x_call_trans xct ,
      (SELECT tc.x_esn
      FROM table_case tc ,
        table_x_part_request pr
      WHERE 1                  = 1
      AND UPPER(tc.title)      = 'DEFECTIVE PHONE'
      AND tc.objid             = pr.request2case
      AND pr.x_part_num_domain = 'PHONES'
      AND pr.x_part_serial_no  = p_esn
      ) tab1
  WHERE 1                   = 1
  AND UPPER(p.x_promo_type) = 'ACTIVATION'
    --     AND x_promo_code = 'DEFNET10_2'
  AND p.objid                    = ph.promo_hist2x_promotion
  AND ph.promo_hist2x_call_trans = xct.objid
  AND xct.x_service_id           = tab1.x_esn;
  activation_promo_used_rec activation_promo_used_curs%ROWTYPE;
BEGIN
  OPEN activation_promo_used_curs;
  FETCH activation_promo_used_curs INTO activation_promo_used_rec;
  IF activation_promo_used_curs%FOUND THEN
    RETURN 'X';
  ELSE
    RETURN NULL;
  END IF;
  CLOSE activation_promo_used_curs;
END activationpromoused;
-- END CR5728
FUNCTION getdefaultpromo(
    p_tech             IN VARCHAR2 ,
    p_call_trans_objid IN NUMBER )
  RETURN NUMBER
IS
  CURSOR default_promo_curs
  IS
    SELECT x_units ,
      objid promotion_objid
    FROM table_x_promotion
    WHERE x_start_date <= SYSDATE
    AND x_end_date     >= SYSDATE
    AND x_is_default    = 1
    AND x_default_type  = DECODE(p_tech ,'TDMA' ,'DIGITAL' ,'CDMA' ,'DIGITAL' ,'GSM' ,'DIGITAL' ,p_tech);
  default_promo_rec default_promo_curs%ROWTYPE;
BEGIN
  OPEN default_promo_curs;
  FETCH default_promo_curs INTO default_promo_rec;
  IF default_promo_curs%FOUND THEN
    INSERT
    INTO table_x_promo_hist
      --CR20864 Start Kacosta 06/15/2012
      (
        objid ,
        promo_hist2x_call_trans ,
        promo_hist2x_promotion ,
        granted_from2x_call_trans
      )
      --CR20864 End Kacosta 06/15/2012
      VALUES
      (
        seq('x_promo_hist') ,
        p_call_trans_objid ,
        default_promo_rec.promotion_objid ,
        NULL
      );
    CLOSE default_promo_curs;
    RETURN default_promo_rec.x_units;
  ELSE
    CLOSE default_promo_curs;
    RETURN NULL;
  END IF;
  CLOSE default_promo_curs;
END getdefaultpromo;
-- CR7984 new getdefaultpromo
PROCEDURE getdefaultpromo_new
  (
    p_call_trans_objid IN NUMBER ,
    p_objid_pm         IN NUMBER
  )
IS
BEGIN
  INSERT
  INTO sa.table_x_promo_hist
    --CR20864 Start Kacosta 06/15/2012
    (
      objid ,
      promo_hist2x_call_trans ,
      promo_hist2x_promotion ,
      granted_from2x_call_trans
    )
    --CR20864 End Kacosta 06/15/2012
    VALUES
    (
      seq('x_promo_hist') ,
      p_call_trans_objid ,
      p_objid_pm ,
      NULL
    );
END getdefaultpromo_new;
--
FUNCTION getdealerpromo
  (
    p_site_objid       IN NUMBER ,
    p_call_trans_objid IN NUMBER
  )
  RETURN NUMBER
IS
  CURSOR dealer_promo_curs
  IS
    SELECT p.x_units ,
      p.objid promotion_objid
    FROM table_x_promotion p ,
      table_site s
    WHERE p.objid = s.dealer2x_promotion
    AND s.objid   = p_site_objid;
  dealer_promo_rec dealer_promo_curs%ROWTYPE;
BEGIN
  OPEN dealer_promo_curs;
  FETCH dealer_promo_curs INTO dealer_promo_rec;
  IF dealer_promo_curs%FOUND THEN
    INSERT
    INTO table_x_promo_hist
      --CR20864 Start Kacosta 06/15/2012
      (
        objid ,
        promo_hist2x_call_trans ,
        promo_hist2x_promotion ,
        granted_from2x_call_trans
      )
      --CR20864 End Kacosta 06/15/2012
      VALUES
      (
        seq('x_promo_hist') ,
        p_call_trans_objid ,
        dealer_promo_rec.promotion_objid ,
        NULL
      );
    CLOSE dealer_promo_curs;
    RETURN dealer_promo_rec.x_units;
  ELSE
    CLOSE dealer_promo_curs;
    RETURN NULL;
  END IF;
  CLOSE dealer_promo_curs;
END getdealerpromo;
--
FUNCTION getoldsitepart
  (
    p_esn         IN VARCHAR2 ,
    p_part_status IN VARCHAR2 ,
    p_status      IN NUMBER
  )
  RETURN NUMBER
IS
  CURSOR old_site_part_curs
  IS
    SELECT objid
    FROM table_site_part
    WHERE x_service_id         = p_esn
    AND part_status            = p_part_status
    AND NVL(x_refurb_flag ,0) <> 1 --CR5282
    ORDER BY service_end_dt DESC;
  CURSOR old_site_part_curs2
  IS
    SELECT objid
    FROM table_site_part
    WHERE x_service_id = p_esn
    AND part_status   != p_part_status
    ORDER BY service_end_dt DESC;
  old_site_part_rec old_site_part_curs%ROWTYPE;
BEGIN
  IF p_status = 1 THEN
    OPEN old_site_part_curs;
    FETCH old_site_part_curs INTO old_site_part_rec;
    IF old_site_part_curs%FOUND THEN
      CLOSE old_site_part_curs;
      RETURN old_site_part_rec.objid;
    ELSE
      CLOSE old_site_part_curs;
      RETURN NULL;
    END IF;
    CLOSE old_site_part_curs;
  ELSE
    OPEN old_site_part_curs;
    FETCH old_site_part_curs2 INTO old_site_part_rec;
    IF old_site_part_curs2%FOUND THEN
      CLOSE old_site_part_curs2;
      RETURN old_site_part_rec.objid;
    ELSE
      CLOSE old_site_part_curs2;
      RETURN NULL;
    END IF;
    CLOSE old_site_part_curs2;
  END IF;
END getoldsitepart;
--
FUNCTION getwebpromo(
    p_call_trans_objid IN NUMBER)
  RETURN NUMBER
IS
  CURSOR web_promo_curs
  IS
    SELECT NVL(x_units ,0) x_units ,
      objid promotion_objid
    FROM table_x_promotion
    WHERE x_promo_code = 'WEB001'
    AND x_start_date  <= SYSDATE
    AND x_end_date    >= SYSDATE;
  web_promo_rec web_promo_curs%ROWTYPE;
BEGIN
  OPEN web_promo_curs;
  FETCH web_promo_curs INTO web_promo_rec;
  IF web_promo_curs%FOUND THEN
    INSERT
    INTO table_x_promo_hist
      --CR20864 Start Kacosta 06/15/2012
      (
        objid ,
        promo_hist2x_call_trans ,
        promo_hist2x_promotion ,
        granted_from2x_call_trans
      )
      --CR20864 End Kacosta 06/15/2012
      VALUES
      (
        seq('x_promo_hist') ,
        p_call_trans_objid ,
        web_promo_rec.promotion_objid ,
        NULL
      );
    CLOSE web_promo_curs;
    RETURN web_promo_rec.x_units;
  ELSE
    CLOSE web_promo_curs;
    RETURN NULL;
  END IF;
  CLOSE web_promo_curs;
END getwebpromo;
--
-- look4me
PROCEDURE codeaccepted
  (
    p_call_trans_objid IN NUMBER
  )
IS
  --
  --CR5639 Start
  CURSOR psms_address_curs(c_min IN VARCHAR2)
  IS
    SELECT txp.x_ota_psms_address
    FROM sa.table_x_parent txp ,
      sa.table_x_carrier_group tcg ,
      sa.table_x_carrier tc ,
      sa.table_part_inst tpi
    WHERE txp.objid = tcg.x_carrier_group2x_parent + 0
    AND tcg.objid   = tc.carrier2carrier_group     + 0
    AND tc.objid    = tpi.part_inst2carrier_mkt    + 0
    AND tpi.x_domain|| '' = 'LINES'
    AND tpi.part_serial_no = c_min;

  psms_address_rec psms_address_curs%ROWTYPE;
  --
  CURSOR ota_features_curs(c_objid IN NUMBER)
  IS
    SELECT * FROM table_x_ota_features WHERE x_ota_features2part_inst = c_objid;
  ota_features_rec ota_features_curs%ROWTYPE;
  --
  l_x_type VARCHAR2(100) := NULL;
  --CR5639 End
  CURSOR code_temp_curs
  IS
    SELECT *
    FROM table_x_code_hist_temp
    WHERE x_code_temp2x_call_trans = p_call_trans_objid
    ORDER BY objid ASC;
  code_temp_rec code_temp_curs%ROWTYPE;
  --
  CURSOR call_trans_curs
  IS
    SELECT * FROM table_x_call_trans WHERE objid = p_call_trans_objid;
  call_trans_rec call_trans_curs%ROWTYPE;
  --
  CURSOR site_part_curs(c_site_part_objid IN NUMBER)
  IS
    SELECT * FROM table_site_part WHERE objid = c_site_part_objid;
  site_part_rec site_part_curs%ROWTYPE;
  --
  --  cursor new_click_plan_curs(c_new_plan_objid in number) is
  --    select objid
  --     from table_x_click_plan
  --    where objid = c_new_plna_objid;
  --  new_click_plan_rec new_click_plan_curs%rowtype;
  --
  CURSOR part_inst_curs(c_esn IN VARCHAR2)
  IS
    SELECT pn.* ,
      pi.x_sequence ,
      pi.objid esn_objid ,
      pi.x_part_inst_status ,
      NVL(pi.x_reactivation_flag ,0) x_reactivation_flag ,
      s.objid site_objid ,
      bo.org_id
    FROM table_site s ,
      table_inv_bin ib ,
      table_part_num pn ,
      table_mod_level ml ,
      table_part_inst pi ,
      table_bus_org bo
    WHERE 1                 = 1
    AND s.site_id           = ib.bin_name
    AND ib.objid            = pi.part_inst2inv_bin
    AND pn.objid            = ml.part_info2part_num
    AND ml.objid            = pi.n_part_inst2part_mod
    AND pi.part_serial_no   = c_esn
    AND pi.x_domain         = 'PHONES' -- CR55074: Code Changes;
    AND pn.part_num2bus_org = bo.objid;
  part_inst_rec part_inst_curs%ROWTYPE;
  blnsplitcode      BOOLEAN      := FALSE;
  blnnoinvcarrier   BOOLEAN      := FALSE;
  blnsequpdate      BOOLEAN      := FALSE;
  defaultpromocode  VARCHAR2(30) := NULL;
  defaultpromoobjid NUMBER       := NULL;
  dealerpromoobjid  NUMBER       := NULL;
  oldsitepart       NUMBER       := NULL;
  webpromounits     NUMBER       := NULL;
  promounits        NUMBER       := 0;
  -- new variables for ota features *#pin
  v_x_buy_airtime_menu VARCHAR2(30) := NULL;
  v_x_spp_promo_code   VARCHAR2(30) := NULL;
  v_x_spp_pin_on       VARCHAR2(30) := NULL;
  CURSOR pending_redemption_curs ( c_site_part_objid IN NUMBER ,c_esn_objid IN NUMBER )
    --CR5298
  IS
    SELECT NVL(p.x_units ,0) x_units ,
      pr.pend_red2x_promotion ,
      pr.x_granted_from2x_call_trans ,
      pr.objid
    FROM table_x_promotion p ,
      table_x_pending_redemption pr
    WHERE p.objid                = pr.pend_red2x_promotion
    AND (pr.x_pend_red2site_part = c_site_part_objid
    OR (pr.x_pend_type           = 'REPL'
    AND pr.pend_redemption2esn   = c_esn_objid));
  pending_redemption_tot    NUMBER := 0;
  pending_replace_units_tot NUMBER := 0;
  CURSOR republik_promo_curs ( c_esn_objid IN NUMBER ,c_both IN VARCHAR2 )
  IS
    SELECT NVL(p.x_units ,0) x_units ,
      p.objid promotion_objid
    FROM table_x_promotion p ,
      table_x_group2esn g2e
    WHERE p.objid              = g2e.groupesn2x_promotion
    AND p.x_start_date        <= SYSDATE
    AND p.x_end_date          >= SYSDATE
    AND p.x_promo_type        IN ('Activation' ,'ActivationCombo' ,DECODE(c_both ,'TRUE' ,'Runtime' ,'NA'))
    AND g2e.groupesn2part_inst = c_esn_objid;
  republikpromounits NUMBER   := 0;
BEGIN
  --
  OPEN call_trans_curs;
  FETCH call_trans_curs INTO call_trans_rec;
  CLOSE call_trans_curs;
  --
  OPEN part_inst_curs(call_trans_rec.x_service_id);
  FETCH part_inst_curs INTO part_inst_rec;
  CLOSE part_inst_curs;
  --
  OPEN site_part_curs(call_trans_rec.call_trans2site_part);
  FETCH site_part_curs INTO site_part_rec;
  CLOSE site_part_curs;
  IF UPPER(call_trans_rec.x_sourcesystem) NOT IN ('WEBCSR','NETCSR','TAS') --CR22451
    AND updatecodehistory(p_call_trans_objid) THEN
    UPDATE table_part_inst
    SET x_sequence = x_sequence + 1
    WHERE objid    = part_inst_rec.esn_objid;
  END IF;
  OPEN code_temp_curs;
  FETCH code_temp_curs INTO code_temp_rec;
  IF code_temp_curs%FOUND THEN
    l_x_type := code_temp_rec.x_type; --CR5639
    updateflags(part_inst_rec.esn_objid ,p_call_trans_objid ,site_part_rec.site_part2x_new_plan ,site_part_rec.objid ,code_temp_rec.x_type ,code_temp_rec.x_type);
  END IF;
  IF LOWER(code_temp_rec.x_type) = 'time_code' THEN
    clearredcards(p_call_trans_objid ,part_inst_rec.esn_objid ,TRUE);
    IF part_inst_rec.x_part_inst_status = '54' THEN
      UPDATE table_part_inst
      SET x_part_inst_status = '51' ,
        status2x_code_table  = 987
      WHERE objid            = part_inst_rec.esn_objid;
    END IF;
    UPDATE table_part_inst
    SET warr_end_date = site_part_rec.warranty_date
    WHERE objid       = part_inst_rec.esn_objid;
    --Uncommented for CR5282
    IF call_trans_rec.x_action_type = '1' AND part_inst_rec.x_reactivation_flag = 0 THEN
      FOR republik_promo_rec IN republik_promo_curs(part_inst_rec.esn_objid ,'FALSE')
      LOOP
        republikpromounits := republikpromounits + republik_promo_rec.x_units;
        INSERT
        INTO table_x_promo_hist
          --CR20864 Start Kacosta 06/15/2012
          (
            objid ,
            promo_hist2x_call_trans ,
            promo_hist2x_promotion ,
            granted_from2x_call_trans
          )
          --CR20864 End Kacosta 06/15/2012
          VALUES
          (
            seq('x_promo_hist') ,
            p_call_trans_objid ,
            republik_promo_rec.promotion_objid ,
            NULL
          );
      END LOOP;
      IF republikpromounits > 0 THEN
        promounits         := promounits + republikpromounits;
      END IF;
    END IF;
    --Uncommented for CR5282
    FOR pending_redemption_rec IN pending_redemption_curs
    (
      site_part_rec.objid ,part_inst_rec.esn_objid
    ) --CR5298
    LOOP
      pending_redemption_tot := pending_redemption_tot + pending_redemption_rec.x_units;
      INSERT
      INTO table_x_promo_hist
        (
          objid ,
          promo_hist2x_call_trans ,
          promo_hist2x_promotion ,
          granted_from2x_call_trans
        )
        VALUES
        (
          sa.seq('x_promo_hist') ,
          p_call_trans_objid ,
          pending_redemption_rec.pend_red2x_promotion ,
          pending_redemption_rec.x_granted_from2x_call_trans
        );
      /*DELETE FROM TABLE_X_PENDING_REDEMPTION
      WHERE objid = pending_redemption_rec.objid;*/
      --CR5854
      DELETE
      FROM table_x_pending_redemption
      WHERE objid = pending_redemption_rec.objid
        --AND x_granted_from2x_call_trans = p_call_trans_objid;
      AND redeem_in2call_trans = p_call_trans_objid;
      --CR5150 change the field name from CR5854
    END LOOP;
    IF pending_redemption_tot IS NOT NULL AND call_trans_rec.x_action_type = '1' AND part_inst_rec.x_reactivation_flag = 0 THEN
      promounits              := promounits + pending_redemption_tot;
    END IF;
    --
    IF promounits IS NOT NULL THEN
      UPDATE table_part_inst
      SET x_reactivation_flag = promounits
      WHERE objid             = part_inst_rec.esn_objid;
    END IF;
    WHILE code_temp_curs%FOUND
    LOOP
      INSERT
      INTO table_x_code_hist
        (
          objid ,
          x_gen_code ,
          x_sequence ,
          code_hist2call_trans ,
          x_code_accepted ,
          x_code_type ,
          x_seq_update
        )
        VALUES
        (
          sa.seq('x_code_hist') ,
          code_temp_rec.x_code ,
          part_inst_rec.x_sequence ,
          code_temp_rec.x_code_temp2x_call_trans ,
          'YES' ,
          code_temp_rec.x_type ,
          code_temp_rec.x_seq_update
        );
      DELETE FROM table_x_code_hist_temp WHERE objid = code_temp_rec.objid;
      IF code_temp_rec.x_seq_update = 1 THEN
        UPDATE table_part_inst
        SET x_sequence = x_sequence + 1
        WHERE objid    = part_inst_rec.esn_objid;
      END IF;
      FETCH code_temp_curs INTO code_temp_rec;
      IF code_temp_curs%NOTFOUND OR LOWER(code_temp_rec.x_type) != 'time_code' THEN
        EXIT;
      END IF;
    END LOOP;
  ELSIF code_temp_curs%FOUND AND LOWER(code_temp_rec.x_type) != 'time_code' THEN
    INSERT
    INTO table_x_code_hist
      (
        objid ,
        x_gen_code ,
        x_sequence ,
        code_hist2call_trans ,
        x_code_accepted ,
        x_code_type ,
        x_seq_update
      )
      VALUES
      (
        sa.seq('x_code_hist') ,
        code_temp_rec.x_code ,
        part_inst_rec.x_sequence ,
        code_temp_rec.x_code_temp2x_call_trans ,
        'YES' ,
        code_temp_rec.x_type ,
        code_temp_rec.x_seq_update
      );
    DELETE FROM table_x_code_hist_temp WHERE objid = code_temp_rec.objid;
    IF code_temp_rec.x_seq_update = 1 THEN
      UPDATE table_part_inst
      SET x_sequence = x_sequence + 1
      WHERE objid    = part_inst_rec.esn_objid;
    END IF;
  END IF;
  CLOSE code_temp_curs;
  --CR5639 Start
  IF l_x_type = 'MO_Address' THEN
    OPEN psms_address_curs(call_trans_rec.x_min);
    FETCH psms_address_curs INTO psms_address_rec;
    CLOSE psms_address_curs;
  END IF;
  --      OPEN ota_features_curs (part_inst_rec.objid);
  OPEN ota_features_curs(part_inst_rec.esn_objid); --CR5639-1
  FETCH ota_features_curs INTO ota_features_rec;
  -- NEW OTA FEATURES *#PIN
  IF ota_features_curs%FOUND THEN
    IF SUBSTR(l_x_type ,1 ,8)    = 'BUY_MENU' THEN
      IF SUBSTR(l_x_type ,11 ,1) = 'N' THEN
        v_x_buy_airtime_menu    := 'Y';
      ELSE
        v_x_buy_airtime_menu := 'N';
      END IF;
      --Select DECODE(substr(l_x_type,11,1),'N','Y','N') FROM Dual INTO v_x_buy_airtime_menu;
      IF SUBSTR(l_x_type ,LENGTH(TRIM(l_x_type)) ,1) = 'N' THEN
        v_x_spp_promo_code                          := 'Y';
      ELSE
        v_x_spp_promo_code := 'N';
      END IF;
      --Select DECODE(substr(l_x_type,LENGTH(TRIM(l_x_type)),1),'N','Y','N') FROM dual into v_x_spp_promo_code;
      v_x_spp_pin_on := SUBSTR(ota_features_rec.x_spp_pin_on ,1 ,4);
    ELSE
      v_x_buy_airtime_menu := NULL;
      v_x_spp_promo_code   := NULL;
      v_x_spp_pin_on       := NULL;
    END IF;
    UPDATE sa.table_x_ota_features
    SET x_psms_destination_addr =
      --CR8406
      --                    DECODE (l_x_type,
      --                            'MO_Adress', psms_address_rec.x_ota_psms_address,
      --                            x_psms_destination_addr
      --                           ),
      DECODE(l_x_type ,'MO_Address' ,psms_address_rec.x_ota_psms_address ,x_psms_destination_addr) ,
      --CR8406
      x_ild_prog_status            = DECODE(l_x_type ,'ILD01' ,'Inqueue' ,x_ild_prog_status) ,
      x_buy_airtime_menu           = NVL(v_x_buy_airtime_menu ,x_buy_airtime_menu) ,
      x_spp_promo_code             = NVL(v_x_spp_promo_code ,x_spp_promo_code) ,
      x_spp_pin_on                 = NVL(v_x_spp_pin_on ,x_spp_pin_on)
    WHERE x_ota_features2part_inst = part_inst_rec.esn_objid;
    --          WHERE x_ota_features2part_inst = part_inst_rec.objid; --CR5639-1
  ELSE
    INSERT
    INTO sa.table_x_ota_features
      (
        objid ,
        x_ild_prog_status ,
        x_ild_carr_status ,
        x_redemption_menu ,
        x_handset_lock ,
        x_psms_destination_addr ,
        x_ota_features2part_inst
      )
      VALUES
      (
        sa.seq('x_ota_features') ,
        DECODE(l_x_type ,'ILD01' ,'Inqueue' ,'Pending') ,
        'Inactive' ,
        DECODE(l_x_type ,'RED_MENU_OFF' ,'N' ,'RED_MENU_ON' ,'Y' ,NULL) ,
        DECODE(l_x_type ,'RED_MENU_OFF' ,'N' ,'RED_MENU_ON' ,'Y' ,NULL) ,
        DECODE(l_x_type ,'MO_Address' ,psms_address_rec.x_ota_psms_address ,NULL) ,
        --CR8406
        --part_inst_rec.objid
        part_inst_rec.esn_objid --CR5639-1
      );
  END IF;
  CLOSE ota_features_curs;
  --CR5639 End
END codeaccepted;
--
PROCEDURE otacodeacceptedupdate
  (
    p_call_trans_objid IN NUMBER ,
    p_time_code OUT VARCHAR2 ,
    p_ild OUT VARCHAR2 ,
    p_error_number OUT VARCHAR2 ,
    p_error_code OUT VARCHAR2
  )
IS
  --
  CURSOR code_pend_curs
  IS
    SELECT *
    FROM table_x_code_hist
    WHERE code_hist2call_trans = p_call_trans_objid
    AND UPPER(x_code_accepted) = 'OTAPENDING'
    ORDER BY objid ASC;
  code_pend_rec code_pend_curs%ROWTYPE;
  --
  CURSOR call_trans_curs
  IS
    SELECT * FROM table_x_call_trans WHERE objid = p_call_trans_objid;
  call_trans_rec call_trans_curs%ROWTYPE;
  --
  CURSOR site_part_curs(c_site_part_objid IN NUMBER)
  IS
    SELECT * FROM table_site_part WHERE objid = c_site_part_objid;
  site_part_rec site_part_curs%ROWTYPE;
  --
  --  cursor new_click_plan_curs(c_new_plan_objid in number) is
  --    select objid
  --     from table_x_click_plan
  --    where objid = c_new_plna_objid;
  --  new_click_plan_rec new_click_plan_curs%rowtype;
  --
  CURSOR part_inst_curs(c_esn IN VARCHAR2)
  IS
    SELECT pn.* ,
      pi.x_sequence ,
      pi.objid esn_objid ,
      pi.x_part_inst_status ,
      NVL(pi.x_reactivation_flag ,0) x_reactivation_flag ,
      s.objid site_objid ,
      org_id
    FROM table_site s ,
      table_inv_bin ib ,
      table_part_num pn ,
      table_mod_level ml ,
      table_part_inst pi ,
      table_bus_org bo
    WHERE 1                 = 1
    AND s.site_id           = ib.bin_name
    AND ib.objid            = pi.part_inst2inv_bin
    AND pn.objid            = ml.part_info2part_num
    AND ml.objid            = pi.n_part_inst2part_mod
    AND pi.part_serial_no   = c_esn
    AND pi.x_domain         = 'PHONES' -- CR55074: Code Changes;
    AND pn.part_num2bus_org = bo.objid;
  part_inst_rec part_inst_curs%ROWTYPE;
  blnsplitcode      BOOLEAN      := FALSE;
  blnnoinvcarrier   BOOLEAN      := FALSE;
  blnsequpdate      BOOLEAN      := FALSE;
  defaultpromocode  VARCHAR2(30) := NULL;
  defaultpromoobjid NUMBER       := NULL;
  dealerpromoobjid  NUMBER       := NULL;
  oldsitepart       NUMBER       := NULL;
  webpromounits     NUMBER       := NULL;
  promounits        NUMBER       := 0;
  CURSOR pending_redemption_curs ( c_site_part_objid IN NUMBER ,c_esn_objid IN NUMBER )
    --CR5298
  IS
    SELECT NVL(p.x_units ,0) x_units ,
      pr.pend_red2x_promotion ,
      pr.x_granted_from2x_call_trans ,
      pr.objid
    FROM table_x_promotion p ,
      table_x_pending_redemption pr
    WHERE p.objid                = pr.pend_red2x_promotion
    AND (pr.x_pend_red2site_part = c_site_part_objid
    OR (pr.x_pend_type           = 'REPL'
    AND pr.pend_redemption2esn   = c_esn_objid));
  pending_redemption_tot    NUMBER := 0;
  pending_replace_units_tot NUMBER := 0;
  CURSOR republik_promo_curs ( c_esn_objid IN NUMBER ,c_both IN VARCHAR2 )
  IS
    SELECT NVL(p.x_units ,0) x_units ,
      p.objid promotion_objid
    FROM table_x_promotion p ,
      table_x_group2esn g2e
    WHERE p.objid              = g2e.groupesn2x_promotion
    AND p.x_start_date        <= SYSDATE
    AND p.x_end_date          >= SYSDATE
    AND UPPER(p.x_promo_type) IN ('ACTIVATION' ,'ACTIVATIONCOMBO' ,DECODE(c_both ,'TRUE' ,'Runtime' ,'NA'))
    AND g2e.groupesn2part_inst = c_esn_objid;
  republikpromounits NUMBER   := 0;
BEGIN
  p_ild       := 'FALSE';
  p_time_code := 'FALSE';
  --
  OPEN call_trans_curs;
  FETCH call_trans_curs INTO call_trans_rec;
  CLOSE call_trans_curs;
  --
  OPEN part_inst_curs(call_trans_rec.x_service_id);
  FETCH part_inst_curs INTO part_inst_rec;
  CLOSE part_inst_curs;
  --
  OPEN site_part_curs(call_trans_rec.call_trans2site_part);
  FETCH site_part_curs INTO site_part_rec;
  CLOSE site_part_curs;
  --
  OPEN code_pend_curs;
  FETCH code_pend_curs INTO code_pend_rec;
  IF code_pend_curs%FOUND THEN
    updateflags(part_inst_rec.esn_objid ,p_call_trans_objid ,site_part_rec.site_part2x_new_plan ,site_part_rec.objid ,code_pend_rec.x_code_type ,code_pend_rec.x_code_type);
  END IF;
  IF LOWER(code_pend_rec.x_code_type) = 'time_code' THEN
    p_time_code                      := 'TRUE';
    --
    clearredcards(p_call_trans_objid ,part_inst_rec.esn_objid ,TRUE);
    --
    IF part_inst_rec.x_part_inst_status = '54' THEN
      UPDATE table_part_inst
      SET x_part_inst_status = '51' ,
        status2x_code_table  = 987
      WHERE objid            = part_inst_rec.esn_objid;
    END IF;
    --
    UPDATE table_part_inst
    SET warr_end_date = site_part_rec.warranty_date
    WHERE objid       = part_inst_rec.esn_objid;
    -- CR4811
    IF call_trans_rec.x_action_type = '1' AND part_inst_rec.x_reactivation_flag = 0 THEN
      FOR republik_promo_rec IN republik_promo_curs(part_inst_rec.esn_objid ,'FALSE')
      LOOP
        republikpromounits := republikpromounits + republik_promo_rec.x_units;
        INSERT
        INTO table_x_promo_hist
          --CR20864 Start Kacosta 06/15/2012
          (
            objid ,
            promo_hist2x_call_trans ,
            promo_hist2x_promotion ,
            granted_from2x_call_trans
          )
          --CR20864 End Kacosta 06/15/2012
          VALUES
          (
            seq('x_promo_hist') ,
            p_call_trans_objid ,
            republik_promo_rec.promotion_objid ,
            NULL
          );
      END LOOP;
      IF republikpromounits > 0 THEN
        promounits         := promounits + republikpromounits;
      END IF;
    END IF;
    -- end CR4811
    FOR pending_redemption_rec IN pending_redemption_curs
    (
      site_part_rec.objid ,part_inst_rec.esn_objid
    ) --5298
    LOOP
      pending_redemption_tot := pending_redemption_tot + pending_redemption_rec.x_units;
      INSERT
      INTO table_x_promo_hist
        (
          objid ,
          promo_hist2x_call_trans ,
          promo_hist2x_promotion ,
          granted_from2x_call_trans
        )
        VALUES
        (
          sa.seq('x_promo_hist') ,
          p_call_trans_objid ,
          pending_redemption_rec.pend_red2x_promotion ,
          pending_redemption_rec.x_granted_from2x_call_trans
        );
      /*DELETE FROM TABLE_X_PENDING_REDEMPTION
      WHERE objid = pending_redemption_rec.objid;*/
      --CR5854
      DELETE
      FROM table_x_pending_redemption
      WHERE objid = pending_redemption_rec.objid
        --AND x_granted_from2x_call_trans = p_call_trans_objid;
      AND redeem_in2call_trans = p_call_trans_objid;
      --CR5150 change the field name from CR5854
    END LOOP;
    IF pending_redemption_tot IS NOT NULL AND call_trans_rec.x_action_type = '1' AND part_inst_rec.x_reactivation_flag = 0 THEN
      promounits              := promounits + pending_redemption_tot;
    END IF;
    --
    IF promounits IS NOT NULL THEN
      UPDATE table_part_inst
      SET x_reactivation_flag = promounits
      WHERE objid             = part_inst_rec.esn_objid;
    END IF;
    --
    WHILE code_pend_curs%FOUND
    LOOP
      UPDATE table_x_code_hist
      SET x_code_accepted = 'YES'
      WHERE objid         = code_pend_rec.objid;
      FETCH code_pend_curs INTO code_pend_rec;
      IF code_pend_curs%NOTFOUND OR LOWER(code_pend_rec.x_code_type) != 'time_code' THEN
        EXIT;
      END IF;
    END LOOP;
  ELSIF code_pend_curs%FOUND AND LOWER(code_pend_rec.x_code_type) != 'time_code' THEN
    IF LOWER(code_pend_rec.x_code_type) LIKE 'ild%' THEN
      p_ild := 'TRUE';
    END IF;
    UPDATE table_x_code_hist
    SET x_code_accepted = 'YES'
    WHERE objid         = code_pend_rec.objid;
  END IF;
  CLOSE code_pend_curs;
EXCEPTION
WHEN OTHERS THEN
  p_error_number := SQLCODE;
  p_error_code   := SQLERRM;
END otacodeacceptedupdate;
--
PROCEDURE otacodeaccepted(
    p_call_trans_objid IN NUMBER)
IS
  CURSOR code_temp_curs
  IS
    SELECT *
    FROM table_x_code_hist_temp
    WHERE x_code_temp2x_call_trans = p_call_trans_objid
    ORDER BY objid ASC; --CR7814, same fix added for CR7899
  CURSOR part_inst_curs
  IS
    SELECT pi.objid esn_objid ,
      pi.x_sequence
    FROM table_part_inst pi ,
          table_x_call_trans ct
    WHERE 1 = 1
    AND   ct.objid = p_call_trans_objid
	AND   pi.part_serial_no = ct.x_service_id
	AND   pi.x_domain = 'PHONES'; -- CR55074: Code Changes;
  part_inst_rec part_inst_curs%ROWTYPE;
  CURSOR site_part_curs
  IS
    SELECT sp.state_code
    FROM table_site_part sp ,
      table_x_call_trans ct
    WHERE sp.objid = ct.call_trans2site_part
    AND ct.objid   = p_call_trans_objid;
  site_part_rec site_part_curs%ROWTYPE;
BEGIN
  OPEN part_inst_curs;
  FETCH part_inst_curs INTO part_inst_rec;
  CLOSE part_inst_curs;
  OPEN site_part_curs;
  FETCH site_part_curs INTO site_part_rec;
  CLOSE site_part_curs;
  FOR code_temp_rec IN code_temp_curs
  LOOP
    INSERT
    INTO table_x_code_hist
      (
        objid ,
        x_gen_code ,
        x_sequence ,
        code_hist2call_trans ,
        x_code_accepted ,
        x_code_type ,
        x_seq_update
      )
      VALUES
      (
        sa.seq('x_code_hist') ,
        code_temp_rec.x_code ,
        part_inst_rec.x_sequence ,
        code_temp_rec.x_code_temp2x_call_trans ,
        'OTAPENDING' ,
        code_temp_rec.x_type ,
        code_temp_rec.x_seq_update
      );
    IF code_temp_rec.x_seq_update = 1 THEN
      UPDATE table_part_inst
      SET x_sequence            = NVL(x_sequence ,0) + 1
      WHERE objid               = part_inst_rec.esn_objid;
      part_inst_rec.x_sequence := NVL(part_inst_rec.x_sequence ,0) + 1;
    END IF;
    DELETE FROM table_x_code_hist_temp WHERE objid = code_temp_rec.objid;
    IF LOWER(code_temp_rec.x_type) = 'time_code' THEN
      UPDATE table_x_call_trans
      SET x_total_units = site_part_rec.state_code
      WHERE objid       = p_call_trans_objid;
    END IF;
  END LOOP;
END otacodeaccepted;
--
PROCEDURE enroll_for_tech_exch(
    p_esn IN VARCHAR2 ,
    p_replacement_units OUT NUMBER ,
    p_process_flag IN NUMBER DEFAULT 0 )
IS
  op_result NUMBER;
  op_msg    VARCHAR2(1000);
  CURSOR phone_curs
  IS
    SELECT pi.x_part_inst_status ,
      pi.x_creation_date ,
      pi.objid part_inst_objid ,
      pi.part_serial_no ,
      s.objid site_objid ,
      pn.*
    FROM table_part_num pn ,
      table_mod_level ml ,
      table_site s ,
      table_inv_bin ib ,
      table_part_inst pi
    WHERE 1               = 1
    AND pn.objid          = ml.part_info2part_num
    AND ml.objid          = pi.n_part_inst2part_mod
    AND s.site_id         = ib.bin_name
    AND ib.objid          = pi.part_inst2inv_bin
    AND pi.x_domain       = 'PHONES'
    AND pi.part_serial_no = p_esn;
  phone_rec phone_curs%ROWTYPE;
  CURSOR promo_curs ( c_site_objid IN NUMBER ,c_x_technology IN VARCHAR2 )
  IS
    SELECT p.* ,
      pps.x_dll_allow
    FROM table_x_promotion p ,
      sa.x_promotion_addl_info pps
    WHERE 1                    = 1
    AND (p.x_promo_technology IS NULL
    OR p.x_promo_technology    = DECODE(c_x_technology ,'ANALOG' ,'ANALOG' ,'DIGITAL'))
    AND p.objid                = pps.x_promo_addl2x_promo
    AND p.x_promo_type         = 'Activation'
    AND p.x_start_date        <= SYSDATE
    AND p.x_end_date          >= SYSDATE
    AND pps.x_site_objid       = c_site_objid
    AND pps.x_active           = 'Y';
  CURSOR promo_group_curs(c_objid IN NUMBER)
  IS
    SELECT pg.objid
    FROM table_x_promotion_group pg ,
      table_x_promotion_mtm pmtm
    WHERE 1                          = 1
    AND pg.objid                     = pmtm.x_promo_mtm2x_promo_group
    AND pmtm.x_promo_mtm2x_promotion = c_objid;
  promo_group_rec promo_group_curs%ROWTYPE;
  --CR5581/CR5582
  l_qual   NUMBER := 0;
  l_bigstr VARCHAR2(2000);
  l_smlstr VARCHAR2(2000);
  l_idxval NUMBER;
  l_cnt    NUMBER := 0;
TYPE dll_tab_type
IS
  TABLE OF table_part_num.x_dll%TYPE INDEX BY BINARY_INTEGER;
  l_dll_tab dll_tab_type;
  v_site_objid NUMBER;
  --CR5581/CR5582
BEGIN
  OPEN phone_curs;
  FETCH phone_curs INTO phone_rec;
  IF phone_curs%FOUND THEN
    IF p_process_flag = 0 OR p_process_flag = 1 THEN
      v_site_objid   := phone_rec.site_objid;
    ELSE
      v_site_objid := p_process_flag;
    END IF;
    FOR promo_rec IN promo_curs(v_site_objid ,phone_rec.x_technology)
    LOOP
      l_qual                                                                                                                                   := 0;
      l_bigstr                                                                                                                                 := promo_rec.x_dll_allow;
      IF (l_bigstr                                                                                                                             IS NULL OR l_bigstr = 'ALL') THEN
        IF phone_rec.x_creation_date BETWEEN promo_rec.x_ship_start_date AND promo_rec.x_ship_end_date AND NOT (promo_rec.x_refurbished_allowed = 0 AND phone_rec.x_part_inst_status = '150') THEN
          l_qual                                                                                                                               := 1;
        END IF;
      ELSE
        LOOP
          l_idxval   := INSTR(l_bigstr ,',');
          IF l_idxval = 0 THEN
            l_smlstr := l_bigstr;
          ELSE
            l_smlstr := SUBSTR(l_bigstr ,1 ,l_idxval - 1);
            l_bigstr := SUBSTR(l_bigstr ,l_idxval    + 1);
          END IF;
          l_dll_tab(l_cnt) := l_smlstr;
          l_cnt            := l_cnt + 1;
          EXIT
        WHEN l_idxval = 0;
        END LOOP;
        FOR i IN l_dll_tab.first .. l_dll_tab.last
        LOOP
          IF l_dll_tab(i) = phone_rec.x_dll AND phone_rec.x_part_inst_status = '50' THEN
            l_qual       := l_qual + 1;
          END IF;
        END LOOP;
      END IF;
      IF l_qual                > 0 THEN
        IF p_process_flag      = 1 THEN
          p_replacement_units := 0.5;
        ELSE
          p_replacement_units := NVL(p_replacement_units ,0) + promo_rec.x_units;
        END IF;
      END IF;
    END LOOP;
  END IF;
  CLOSE phone_curs;
END enroll_for_tech_exch;
--
---CR8507
-- sbabu   TF_REL_35. CompleteTranasaction cbo removal.
-- Added wrapper SP clearredcards_sql, minacchange_sql
-- BRAND_SEP
FUNCTION minacchange_sql(
    p_site_part_objid IN NUMBER ,
    p_sourcesystem    IN VARCHAR2 ,
    p_brand_name      IN VARCHAR2 )
  RETURN NUMBER
IS
  acchange BOOLEAN := FALSE;
BEGIN
  -- BRAND_SEP
  acchange   := minacchange(p_site_part_objid ,p_sourcesystem ,p_brand_name);
  IF acchange = TRUE THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
END minacchange_sql;
--
-- sbabu   TF_REL_35. CompleteTranasaction cbo removal.
-- Added wrapper SP clearredcards_sql, minacchange_sql
PROCEDURE clearredcards_sql(
    p_call_trans_objid IN NUMBER ,
    p_esn_objid        IN NUMBER ,
    p_blnboolstatus    IN NUMBER )
IS
BEGIN
  IF p_blnboolstatus = 0 THEN
    clearredcards(p_call_trans_objid ,p_esn_objid ,FALSE);
  ELSE
    clearredcards(p_call_trans_objid ,p_esn_objid ,TRUE);
  END IF;
END clearredcards_sql;
---CR8507
-- CR23513 TF surepay by Mvadlapally
PROCEDURE preprocess_redem_cards(
    p_esn   IN VARCHAR2 ,
    p_cards IN VARCHAR2 ,
    p_isota IN VARCHAR2 ,
    p_annual_plan OUT NUMBER ,
    p_voice_units OUT NUMBER ,
    p_redeem_days OUT NUMBER ,
    p_errorcode OUT VARCHAR2 ,
    p_errormessage OUT VARCHAR2 ,
    p_conversion_rate OUT NUMBER --CR4981_4982
    ,
    p_redeem_text OUT NUMBER ,
    p_redeem_data OUT NUMBER )
IS
  --
  l_cards VARCHAR2(1000) := p_cards;
  i PLS_INTEGER          := 1;
  l PLS_INTEGER          := 1;
  --CR38927 Safelink Smartphone upgrades
  l_sl_flag VARCHAR2(1) := 'N';
  lv_product_id sa.x_surepay_conv.product_id%TYPE;
  v_esn_sp_rec sa.x_service_plan%rowtype;
  out_units        NUMBER;
  op_error_code    NUMBER;
  op_error_message VARCHAR2(200);
  --CR38927 Safelink Smartphone upgrades
  -- CR48383 Changes to block triple benefits for TF smartphones released after 4/4/17.
  -- mdave 03/13/2017
  l_block_triple_benefits_flag VARCHAR2(1);
   -- End CR48383 Changes to block triple benefits for TF smartphones released after 4/4/17.
  -- mdave 03/13/2017
TYPE card_tab_type
IS
  TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  card_tab_original card_tab_type;
  card_tab card_tab_type;
  -- cwl add to make sure pl/sql table is null before we start 2/20/06
  clear_card_tab card_tab_type;
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
    SELECT objid ,
      DECODE(warr_end_date ,
      --TO_DATE ('01-jan-1753', 'dd-mon-yyyy'), SYSDATE,
      TO_DATE('01-01-1753' ,'dd-MM-yyyy') ,SYSDATE ,NULL ,SYSDATE ,warr_end_date) warr_end_date
    FROM table_part_inst
    WHERE part_serial_no = c_esn
    AND   x_domain = 'PHONES';
  esn_rec esn_curs%ROWTYPE;
  ------------------------------------------------------------------------
  CURSOR card_curs ( c_red_code IN VARCHAR2 ,c_esn_objid IN VARCHAR2 )
  IS
    SELECT pi.objid part_inst_objid,
      pi.part_serial_no,
      pi.x_red_code,
      pn.x_redeem_days,
      NVL (pn.x_redeem_units, 0) x_redeem_units,
      NVL (pn.x_conversion, 0) x_conversion,
      pr.x_promo_code,
      PN.PART_NUMBER,--CR37027
      --NVL (pn.x_card_type, 'A') x_card_type                                    ------ added for 23513 Surepay
      DECODE(pn.x_card_type,'WORKFORCE','A',NVL(pn.x_card_type, 'A')) x_card_type --CR26925 TF part number using workforce pins should have the same behavior as x_card_type null
    FROM table_x_promotion pr,
      table_part_num pn,
      table_mod_level ml,
      table_part_inst pi
    WHERE 1                     = 1
    AND pn.objid                = ml.part_info2part_num
    AND ml.objid                = pi.n_part_inst2part_mod
    AND pi.x_red_code           = c_red_code
    AND (pi.x_part_inst_status IN ('42','280')
    OR (pi.x_part_inst_status  IN ('40','43')
    AND c_esn_objid             = pi.part_to_esn2part_inst)
    OR (pi.x_part_inst_status  IN ('400')
    AND c_esn_objid             = pi.part_to_esn2part_inst) )
    AND pn.part_num2x_promotion = pr.objid(+);
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
    SELECT Sp.OBJID,
      Sp.MKT_NAME,
      Sp.DESCRIPTION,
      Sp.CUSTOMER_PRICE,
      Sp.IVR_PLAN_ID,
      Sp.WEBCSR_DISPLAY_NAME
    FROM sa.x_service_plan sp;
  v_pin_sp_rec c1%ROWTYPE;
  --   v_pin_sp_rec    x_service_plan%ROWTYPE;
  v_err_num    INTEGER;
  v_err_string VARCHAR2 (100);
  l_at_days table_part_num.x_redeem_days%TYPE   := 0;
  l_at_voice table_part_num.x_redeem_units%TYPE := 0;
  l_at_text NUMBER                              := 0;
  l_at_data NUMBER                              := 0;
  l_dc_days table_part_num.x_redeem_days%TYPE   := 0;
  l_dc_voice table_part_num.x_redeem_units%TYPE := 0;
  l_dc_text      NUMBER                              := 0;
  l_dc_data      NUMBER                              := 0;
  lv_sms_units   VARCHAR2(100);
  lv_sms_units_1 NUMBER(10);
  v_count        NUMBER;-----for CR37027
BEGIN
  dbms_output.put_line('inside the package');
  -- initialize to blank cwl 2/20/06
  card_tab             := clear_card_tab;
  card_tab_original    := clear_card_tab;
  WHILE LENGTH(l_cards) > 0
  LOOP
    IF INSTR(l_cards,',')   = 0 THEN
      card_tab_original(i) := LTRIM(RTRIM(l_cards));
      EXIT;
    ELSE
      card_tab_original(i) := LTRIM(RTRIM(SUBSTR(l_cards ,1 ,INSTR(l_cards ,',') - 1)));
      l_cards              := LTRIM(RTRIM(SUBSTR(l_cards ,INSTR(l_cards ,',')    + 1)));
      i                    := i                                                  + 1;
    END IF;
  END LOOP;
  dbms_output.put_line('outside the first loop');
  --REMOVE DUPLICATES IN AN ARRAY 5033
  FOR i IN card_tab_original.first .. card_tab_original.last
  LOOP
    l_found := 0;
    FOR j IN i + 1 .. card_tab_original.last
    LOOP
      IF card_tab_original(j) = card_tab_original(i) THEN
        l_found              := 1;
        EXIT;
      END IF;
    END LOOP;
    --Revision 1.13.1.4
    IF (LENGTH(LTRIM(RTRIM(card_tab_original(i)))) IS NULL OR LENGTH(LTRIM(RTRIM(card_tab_original(i)))) = 0) THEN
      l_found                                      := 1;
    END IF;
    --Revision 1.13.1.4
    IF l_found     = 0 THEN
      card_tab(l) := card_tab_original(i);
      l           := l+ 1;
    END IF;
  END LOOP;
  /*  p_annual_plan     := 0;
  p_voice_units     := 0;
  p_redeem_days     := 0;
  p_redeem_text     := 0;
  p_redeem_data     := 0;*/
  p_errorcode    := SQLCODE;
  p_errormessage := SQLERRM;
  --p_conversion_rate := 0;
  --initialize p_conversion_rate to 0 to protect from null values CR4981_4982 Andres/icanavan
  --
  OPEN esn_curs(p_esn);
  FETCH esn_curs INTO esn_rec;
  CLOSE esn_curs;
  ---- CR 23513 TF SUREPAY
  IF device_util_pkg.get_smartphone_fun(p_esn) = 0 THEN -------------- TF SUREPAY PHONE CHK
    dbms_output.put_line('o1');
    --CR39338 SL SMARTPHONE ATT upgrades
    BEGIN
      SELECT 'Y'
      INTO l_sl_flag
      FROM x_sl_currentvals cv ,
           table_bus_org bo ,
           table_part_num pn ,
      table_part_inst pi ,
      table_mod_level ml
      WHERE x_current_esn         = p_esn
      AND pi.part_serial_no       = cv.x_current_esn
      AND pi.x_domain             = 'PHONES' -- CR55074: Code Changes;
      AND pi.n_part_inst2part_mod = ml.objid
      AND ml.part_info2part_num   = pn.objid
      AND bo.objid                = pn.part_num2bus_org
      AND bo.org_id               = 'TRACFONE'
      AND ROWNUM                  =1;
    EXCEPTION
    WHEN OTHERS THEN
      l_sl_flag := 'N';
    END;
    IF card_tab.last > 0 THEN
      FOR i IN card_tab.first .. card_tab.last
      LOOP
        OPEN card_curs(card_tab(i),esn_rec.objid);
        FETCH card_curs INTO card_rec;
        IF card_curs%FOUND THEN
          dbms_output.put_line('2');
          BEGIN
            SELECT x_part_inst_status
            INTO l_no_wait
            FROM table_part_inst pi
            WHERE objid              = card_rec.part_inst_objid
            AND (x_part_inst_status IN ('42','280') --CR6178
            OR (x_part_inst_status  IN ('40','43')
            AND esn_rec.objid        = part_to_esn2part_inst)
              -- CR12989 ST Retention Start PM
            OR (pi.x_part_inst_status IN ('400')
            AND esn_rec.objid          = pi.part_to_esn2part_inst)
              -- CR12989 ST Retention End PM
              ) FOR UPDATE NOWAIT;
            UPDATE table_part_inst
            SET x_part_inst_status  = DECODE(p_isota,'Y','263','43') ,
              status2x_code_table   = DECODE(p_isota,'Y',536887189,985) ,
              last_trans_time       = SYSDATE ,
              part_to_esn2part_inst = esn_rec.objid
            WHERE objid             = card_rec.part_inst_objid;
          EXCEPTION
          WHEN OTHERS THEN
            p_errorcode    := SQLCODE;
            p_errormessage := SQLERRM;
          END;
          service_plan.sp_get_pin_service_plan (card_tab(i), v_sp_rfc, v_err_num, v_err_string);
          LOOP
            FETCH v_sp_rfc INTO v_pin_sp_rec;
            EXIT
          WHEN v_sp_rfc%NOTFOUND;
            ------FOR CR37042
            dbms_output.put_line('3');
            BEGIN
              SELECT COUNT(1)
              INTO v_count
              FROM TABLE_X_PARAMETERS
              WHERE X_PARAM_NAME = 'REPLACEMENT_PARTNUMBERS'
              AND x_param_value  =card_rec.PART_NUMBER;
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
                  -- CR48383 Changes to block triple benefits for TF smartphones released after 4/4/17.
                   -- mdave 03/13/2017
                  l_block_triple_benefits_flag := NULL;
                  l_block_triple_benefits_flag := sa.BLOCK_TRIPLE_BENEFITS(p_esn);
                    DBMS_OUTPUT.PUT_LINE('ESN - '||p_esn );
                    DBMS_OUTPUT.PUT_LINE('block_flag - '||l_block_triple_benefits_flag );

                    IF NVL(l_block_triple_benefits_flag, 'N') = 'Y' THEN
                         l_at_voice := l_at_voice +  card_rec.x_redeem_units;
                         l_at_days  := l_at_days  +  card_rec.x_redeem_days;
                         l_at_text  := l_at_text  +  card_rec.x_redeem_units;
                         l_at_data  := l_at_data  +  card_rec.x_redeem_units;

                    ELSIF NVL(l_block_triple_benefits_flag, 'N') = 'N' THEN
                        l_at_voice := l_at_voice + conv_rec.trans_voice* card_rec.x_redeem_units;
                         l_at_days  := l_at_days  + conv_rec.trans_days* card_rec.x_redeem_days;
                         l_at_text  := l_at_text  + conv_rec.trans_text* card_rec.x_redeem_units;
                         l_at_data  := l_at_data  + conv_rec.trans_data* card_rec.x_redeem_units;
                     END IF;
                    -- End CR48383 Changes to block triple benefits for TF smartphones released after 4/4/17.
                END IF; --for non safelink
              END IF;
              --CR39338 SL SMARTPHONE UPGRADE  ATT
             /* IF l_sl_flag  = 'Y' AND pay_go_rec.safelink_flag='Y' THEN
                l_at_voice := l_at_voice + pay_go_rec.unit_voice;
                l_at_days  := l_at_days  + card_rec.x_redeem_days;
                l_at_text  := l_at_text  + pay_go_rec.unit_text;
                l_at_data  := l_at_data  + pay_go_rec.unit_data;
              END IF;*/
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
          IF l_sl_flag  = 'Y' AND conv_sl_rec.safelink_flag='Y' THEN --CR41433 SL Smartphone upgrade  VZN
            dbms_output.put_line('in safelink 350');
              l_at_voice := l_at_voice + conv_sl_rec.unit_voice;
              l_at_days  := l_at_days  + card_rec.x_redeem_days;
              l_at_text  := l_at_text  + conv_sl_rec.unit_text;
              l_at_data  := l_at_data  + conv_sl_rec.unit_data;
          END IF; --CR41433 SL Smartphone upgrade  VZN

          DELETE FROM table_x_red_card_temp WHERE x_red_code = card_rec.x_red_code;
          INSERT
          INTO table_x_red_card_temp
            (
              objid ,
              x_red_date ,
              x_red_code ,
              x_redeem_days ,
              x_red_units ,
              x_status ,
              x_result ,
              temp_red_card2x_call_trans
            )
            VALUES
            (
              sa.seq('x_red_card_temp') ,
              SYSDATE ,
              card_rec.x_red_code ,
              card_rec.x_redeem_days ,
              card_rec.x_redeem_units ,
              NULL ,
              NULL ,
              NULL
            );
          --CR4981_4982
          IF p_conversion_rate < NVL(card_rec.x_conversion ,0) THEN
            p_conversion_rate := (card_rec.x_conversion);
          END IF;
          --CR4981_4982
        ELSE --------------------- Cursor not found
          p_errorcode    := -1;
          p_errormessage := 'CARD NOT FOUND';
        END IF;
        CLOSE card_curs;
      END LOOP;
    END IF;
    p_redeem_days := l_at_days  + l_dc_days;
    p_redeem_data := l_at_data  + l_dc_data;
    p_voice_units := l_at_voice + l_dc_voice ;
    p_redeem_text := l_at_text  + l_dc_text;
    dbms_output.put_line('p_redeem_days'||p_redeem_days);
    dbms_output.put_line('p_redeem_data'||p_redeem_data);
    dbms_output.put_line('p_voice_units'||p_voice_units);
    dbms_output.put_line('p_redeem_text'||p_redeem_text);
  ELSIF device_util_pkg.get_smartphone_fun(p_esn) = 1 THEN -------------- NON TF SUREPAY PHONE
    BEGIN
      convert_bo_to_sql_pkg.preprocess_redem_cards(P_ESN, P_CARDS, P_ISOTA, P_ANNUAL_PLAN, p_voice_units, P_REDEEM_DAYS, P_ERRORCODE, P_ERRORMESSAGE, P_CONVERSION_RATE);
    END ;
    p_annual_plan     := p_annual_plan;
    p_voice_units     := p_voice_units;
    p_redeem_days     := p_redeem_days;
    p_redeem_data     := 0;
    p_redeem_text     := 0;
    p_errorcode       := p_errorcode;
    p_errormessage    := p_errormessage;
    p_conversion_rate := p_conversion_rate;
  END IF ; -------------- END TF SUREPAY PHONE CHK

  -- Commit only when the global variable is set to TRUE (default is TRUE)
  IF sa.globals_pkg.g_perform_commit THEN
    COMMIT;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  p_errorcode    := SQLCODE;
  p_errormessage := SQLERRM;
END;
--
PROCEDURE sp_set_call_trans_ext
  (
    in_calltranobj          IN   table_x_call_trans.objid%TYPE,
    in_total_days           IN   table_x_call_trans_ext.x_total_days%TYPE,
    in_total_text           IN   table_x_call_trans_ext.x_total_sms_units%TYPE,
    in_total_data           IN   table_x_call_trans_ext.x_total_data_units%TYPE,
    out_err_code            OUT  VARCHAR2,
    out_err_msg             OUT  VARCHAR2,
    --CR46581 GO SMART
    -- ADDED OPTIONAL PARAMETER FOR ILD BUCKET
    i_ild_bucket_sent_flag  IN   VARCHAR2 DEFAULT NULL,
    i_intl_bucket_sent_flag IN   VARCHAR2 DEFAULT NULL,
    in_red_code             IN   VARCHAR2 DEFAULT NULL, --CR47564 added by Sagar
    in_discount_code_list   IN   discount_code_tab DEFAULT NULL, --CR47564 added by Sagar
    i_bucket_id_list        IN   ig_transaction_bucket_tab DEFAULT NULL --CR47564 added by Sagar
  )
IS
  l_account_group_id NUMBER(22);
  l_master_flag      VARCHAR2(1);
  l_service_plan_id  NUMBER(22);
  l_part_inst_objid  NUMBER;
  l_smp              VARCHAR2(30);

   --CR49808 - Safelink Assist Changes
  l_esn             table_part_inst.part_serial_no%type;
  l_dealer_name     table_site.name%type;
  l_result          NUMBER;
  l_msg             VARCHAR2(30);

  --CR54147 changes start
  c_min                   VARCHAR2(200);
  n_service_plan_id       NUMBER;
  c_discount_code         VARCHAR2(200);
  c_lifeline_disc_amount  VARCHAR2(200) := NULL;
  is_lifeline_discount_applied  VARCHAR2(1) := 'N';
  c_ll_brm_disc_code      VARCHAR2(30) := NULL;
  c_error_num             VARCHAR2(200);
  c_error_msg             VARCHAR2(200);
  --CR54147 changes end
BEGIN
  IF (in_calltranobj IS NULL) THEN
    out_err_code     := '700';
    out_err_msg      := Get_Code_Fun('CONVERT_BO_TO_SQL_PKG',out_err_code,'ENGLISH') ;
    RETURN;
  END IF;

  --CR47564 start
  --Convert given pin to smp
  l_smp := sa.customer_info.convert_pin_to_smp ( i_red_card_code => in_red_code);
  --CR47564 end

  -- Added by Juda Pena on 12/1/2014 to get the account_group_id and master_flag when an esn is applicable to account groups functionality.
  brand_x_pkg.get_account_group_id ( ip_call_trans_id => in_calltranobj, op_account_group_id => l_account_group_id , op_master_flag => l_master_flag, op_service_plan_id => l_service_plan_id );
  BEGIN
    --
    INSERT
    INTO table_x_call_trans_ext
      (
        objid,
        call_trans_ext2call_trans,
        x_total_days,
        x_total_sms_units,
        x_total_data_units,
        insert_date,
        account_group_id,
        master_flag,
        service_plan_id,
        --CR46581 ADDED FOR ILD FLAG
        ild_bucket_sent_flag,
        intl_bucket_sent_flag,
        smp, ----CR47564 added by Sagar
        bucket_id_list --CR47564 added by Sagar
      )
      VALUES
      (
        sequ_table_x_call_trans_ext.NEXTVAL,
        in_calltranobj,
        in_total_days,
        in_total_text,
        in_total_data,
        SYSDATE,
        l_account_group_id,
        l_master_flag,
        -- Added logic by Juda Pena on 2/4/2015 to update service plan from the service plan site part relationship
        (
        SELECT spsp.x_service_plan_id
        FROM x_service_plan_site_part spsp
        WHERE spsp.table_site_part_id IN
          (SELECT call_trans2site_part
          FROM table_x_call_trans
          WHERE objid = in_calltranobj
          )
        AND rownum = 1
        ),
        --CR46581 ADDED FOR ILD FLAG
        i_ild_bucket_sent_flag,
        i_intl_bucket_sent_flag,
        l_smp, ----CR47564 added by Sagar
        i_bucket_id_list --CR47564 added by Sagar
      );
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    UPDATE table_x_call_trans_ext
    --CR47564 Changes Start
    SET x_total_sms_units = NVL(in_total_text, x_total_sms_units ),
      x_total_days        = NVL(in_total_days, x_total_days),
      x_total_data_units  = NVL(in_total_data, x_total_data_units),
    /*x_total_sms_units = NVL2(in_total_text, in_total_text, x_total_sms_units ),
      x_total_days        = NVL2(in_total_days, in_total_days, x_total_days),
      x_total_data_units  = NVL2(in_total_data, in_total_data, x_total_data_units),*/
    ----CR47564 Changes end
      update_date         = SYSDATE,
      account_group_id    = l_account_group_id,
      master_flag         = l_master_flag,
      -- Added logic by Juda Pena on 2/4/2015 to update service plan from the service plan site part relationship
      service_plan_id =
                       ( SELECT spsp.x_service_plan_id
                         FROM   x_service_plan_site_part spsp
                         WHERE  spsp.table_site_part_id IN
                                ( SELECT call_trans2site_part
                                  FROM table_x_call_trans
                                  WHERE objid = in_calltranobj
                                 )
                         AND ROWNUM = 1),
        --CR46581 ADDED FOR ILD FLAG
      ild_bucket_sent_flag = i_ild_bucket_sent_flag,
      intl_bucket_sent_flag = i_intl_bucket_sent_flag,
      smp = l_smp, --CR47564 Added by Sagar
      bucket_id_list = i_bucket_id_list --CR47564 Added by Sagar
    WHERE call_trans_ext2call_trans = in_calltranobj;
  END;

  --CR47564 Changes start
  --Get the part inst objid for the input card pin
  BEGIN
    SELECT objid
    INTO   l_part_inst_objid
    FROM   table_part_inst
    WHERE  part_serial_no = l_smp
    AND    x_domain = 'REDEMPTION CARDS';  --CR55034: Code Changes
  EXCEPTION
    WHEN OTHERS
    THEN
      l_part_inst_objid := NULL;
  END;

  --CR54147 changes start
  --Get the ESN and MIN from the call trans
  BEGIN
    --Get the min and esn
    SELECT x_min, x_service_id
    INTO   c_min, l_esn
    FROM   table_x_call_trans
    WHERE  objid = in_calltranobj;
  EXCEPTION
    WHEN OTHERS THEN
      c_min := NULL;
      l_esn := NULL;
  END;

  IF in_discount_code_list IS NOT NULL
  THEN
    --Check if LIFELINE code exists in the input discount code list
    BEGIN
      SELECT 'Y',
             dl.discount_code
      INTO   is_lifeline_discount_applied,
             c_ll_brm_disc_code
      FROM   TABLE (in_discount_code_list) dl,
             sa.ll_plans lp
      WHERE  dl.discount_code = lp.discount_code;
    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        is_lifeline_discount_applied := 'Y';
      WHEN OTHERS THEN
        is_lifeline_discount_applied := 'N';
    END;
  END IF;

  IF is_lifeline_discount_applied = 'Y'
  THEN
    --Get service plan id of the PIN
    n_service_plan_id := sa.service_plan.sp_get_pin_service_plan_id (in_pin => in_red_code);

    --Calculate the LIFELINE discount amount
    sa.LL_SUBSCRIBER_PKG.CALCULATE_LL_DISCOUNT( I_MIN                   => c_min,
                                                I_SERVICE_PLAN_ID       => n_service_plan_id,
                                                I_APP_PART_NUMBER       => NULL,
                                                I_APP_PART_CLASS        => NULL,
                                                I_SERVICE_DAYS          => in_total_days,
                                                O_DISCOUNT_DESCRIPTION  => c_discount_code,
                                                O_DISCOUNT_AMOUNT       => c_lifeline_disc_amount,
                                                O_ERROR_NUM             => c_error_num,
                                                O_ERROR_MSG             => c_error_msg
                                              );

    c_ll_brm_disc_code := NVL (c_ll_brm_disc_code, c_discount_code);

    IF c_lifeline_disc_amount IS NULL
    THEN
      c_lifeline_disc_amount := '0';
    END IF;
  END IF;
  --CR54147 changes end

  --Populate x_part_inst_ext table with BRM service days
  IF l_part_inst_objid IS NOT NULL
  THEN
    MERGE INTO sa.x_part_inst_ext ctext
    USING (select l_part_inst_objid part_inst_objid, l_smp smp, in_total_days service_days, in_discount_code_list discount_code_list, c_ll_brm_disc_code lifeline_discount_code, c_lifeline_disc_amount lifeline_disc_amount from dual) ctext1
    ON (ctext.part_inst_objid = ctext1.part_inst_objid)
    WHEN MATCHED THEN
      UPDATE SET smp = ctext1.smp, brm_service_days = ctext1.service_days, lifeline_discount_code = ctext1.lifeline_discount_code, lifeline_discount_amount = ctext1.lifeline_disc_amount, update_timestamp = SYSDATE
    WHEN NOT MATCHED
      THEN INSERT (part_inst_objid, smp, brm_service_days, insert_timestamp, update_timestamp, discount_code_list, lifeline_discount_code, lifeline_discount_amount)
    VALUES (ctext1.part_inst_objid, ctext1.smp, ctext1.service_days, SYSDATE, SYSDATE, ctext1.discount_code_list, ctext1.lifeline_discount_code, ctext1.lifeline_disc_amount);
  END IF;
  --CR47564 Changes end

 --CR49808 - Safelink Assist Changes
   BEGIN
    --CR54147 changes - commented the below query
	  /*select x_service_id
	  into  l_esn
	  from table_x_call_trans
	  where objid = in_calltranobj;*/

    SELECT  ts.name
		INTO    l_dealer_name
		FROM    table_part_inst   pi,
				TABLE_INV_bin     tb,
				table_site        ts
		WHERE   tb.location_name        =   ts.site_id
		AND     pi.PART_INST2INV_BIN    =   tb.objid
		AND     pi.x_domain             =   'PHONES'
		AND     pi.part_serial_no      = l_esn;

	   IF l_dealer_name =  'SAFELINK-ASSIST WEB ORDERS'  THEN
		  sa.sp_insert_group2esn ( l_esn , 'RTSLA500', 'WEB' , l_result, l_msg);
	   END IF;
   EXCEPTION
      WHEN OTHERS THEN
	       UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Exception occured ', IP_KEY => 'in_calltranobj: '||in_calltranobj , IP_PROGRAM_NAME => 'sp_set_call_trans_ext', ip_error_text => 'l_esn: '||l_esn||'l_dealer_name: '||l_dealer_name||'l_result: '||l_result||' '||SUBSTR(SQLERRM, 1, 200));
   END;
  -- Set return message to success
  out_err_code := '0';
EXCEPTION
WHEN OTHERS THEN
  out_err_code := SQLCODE;
  out_err_msg  := SUBSTR(SQLERRM, 1, 200);
END sp_set_call_trans_ext;

PROCEDURE sp_create_call_trans_soa(
    ip_esn          IN VARCHAR2,
    ip_action_type  IN VARCHAR2,
    ip_sourcesystem IN VARCHAR2,
    ip_brand_name   IN VARCHAR2,
    ip_reason       IN VARCHAR2,
    ip_result       IN VARCHAR2,
    ip_ota_req_type IN VARCHAR2,
    ip_ota_type     IN VARCHAR2,
    ip_total_units  IN NUMBER,
    op_calltranobj OUT NUMBER,
    op_err_code OUT VARCHAR2,
    op_err_msg OUT VARCHAR2 )
IS
  pragma autonomous_transaction;
BEGIN
  CONVERT_BO_TO_SQL_PKG.sp_create_call_trans ( ip_esn, ip_action_type , ip_sourcesystem , ip_brand_name , ip_reason , ip_result , ip_ota_req_type , ip_ota_type , ip_total_units , op_calltranobj, op_err_code , op_err_msg );
  COMMIT;
END sp_create_call_trans_soa;

  PROCEDURE update_call_trans_extension(  in_call_trans_id    IN  NUMBER ,
                                          o_response          OUT VARCHAR2 ) IS
  BEGIN
    -- perform update to make sure the call trans extension is updated
    UPDATE table_x_call_trans
    SET x_result = x_result
    WHERE objid  = in_call_trans_id;
    o_response  := 'SUCCESS';
  exception
    when others then
      o_response  := 'Update error';
      null;
  END update_call_trans_extension;

FUNCTION CHECK_DATA_SAVER
(IP_ESN			IN 	VARCHAR2
)
RETURN 	VARCHAR2
IS




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
		,X_PART_INST_STATUS
	FROM table_part_num pn,
	table_part_inst pi,
	table_mod_level ml,
	table_site_part sp,
	table_bus_org bo
	WHERE 1                      =1
	AND pi.n_part_inst2part_mod  = ml.objid
	AND ml.part_info2part_num    = pn.objid
	AND pi.part_serial_no        = c_esn
    AND pi.x_domain              = 'PHONES' -- CR55074: Code Changes;
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
		xcf.data_saver
		,xcf.data_saver_code
		,mtm.priority
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
		xcf.data_saver
		,xcf.data_saver_code
		,mtm.priority
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
	lv_service_plan_objid		NUMBER;
	lv_non_data_saver_cnt		NUMBER;
	op_error_code	VARCHAR2(5)	:=	'0';
	op_error_msg	VARCHAR2(500)	:=	'Success';
	lv_data_saver_flag	VARCHAR2(10);
	lv_carrier_objid	table_x_call_trans.x_call_trans2carrier%TYPE;

begin

	op_error_code		:=	'0';
	op_error_msg		:=	'Success';
	lv_data_saver_flag	:=	'NA';
	dbms_output.put_line('CHECK_DATA_SAVER Begin ip_esn '||ip_esn);



	OPEN get_esn_details_curs(ip_esn);
	FETCH get_esn_details_curs INTO get_esn_details_rec;

	IF get_esn_details_curs%NOTFOUND
	THEN
	CLOSE get_esn_details_curs;

	op_error_code	:=	'9';
	op_error_msg	:=	'ESN details not found';
	dbms_output.put_line(' FUNCTION CHECK_DATA_SAVER '||op_error_msg);
	RETURN lv_data_saver_flag;

	END IF;

	CLOSE get_esn_details_curs;


	IF get_esn_details_rec.x_part_inst_status <> '52'
	THEN

		op_error_code	:=	'9';
		op_error_msg	:=	'ESN Is Not Active';
		dbms_output.put_line(' FUNCTION CHECK_DATA_SAVER '||op_error_msg);
		RETURN lv_data_saver_flag;
	END IF;


	BEGIN

		SELECT x_call_trans2carrier
		INTO lv_carrier_objid
		FROM table_x_call_trans CT
		WHERE x_service_id = ip_esn
		AND OBJID = (SELECT MAX(OBJID)
				FROM table_x_call_trans IN_CT
				WHERE IN_CT.x_service_id	=	CT.x_service_id
				AND IN_CT.x_call_trans2carrier	IS NOT NULL
				AND IN_CT.x_action_type	IN ('1','3','6')
				)
		;


	EXCEPTION WHEN OTHERS
	THEN

		lv_carrier_objid	:=	NULL;

	END;

	IF lv_carrier_objid IS NULL
	THEN

		op_error_code	:=	'9';
		op_error_msg	:=	'Carrier Not Found';
		dbms_output.put_line(' FUNCTION CHECK_DATA_SAVER '||op_error_msg);
		RETURN lv_data_saver_flag;
	END IF;


	BEGIN

		SELECT  pa.x_parent_name
		INTO lv_parent_name
		FROM table_x_parent pa
		,table_x_carrier_group cg2
		,table_x_carrier ca2
		WHERE 1 = 1
		AND ca2.objid                      = lv_carrier_objid
		and cg2.x_carrier_group2x_parent  = pa.objid
		AND ca2.carrier2carrier_group     = cg2.objid
		;

	EXCEPTION WHEN OTHERS
	THEN
		lv_parent_name	:=	NULL;
		op_error_code	:=	'9';
		op_error_msg	:=	'Parent not found';
		dbms_output.put_line(' FUNCTION CHECK_DATA_SAVER '||op_error_msg);
		RETURN lv_data_saver_flag;

	END;

	BEGIN

	SELECT svp.objid
	INTO	lv_service_plan_objid
	FROM table_part_inst pi
	,table_site_part sp
	,x_service_plan_site_part spsp
	,x_service_plan svp
	WHERE     1	=	1
	AND pi.part_serial_no	=	IP_ESN
	AND pi.x_domain = 'PHONES' -- CR55074: Code Changes;
	AND pi.x_part_inst2site_part = sp.objid
	AND spsp.x_service_plan_id = svp.objid
	and spsp.table_site_part_id = sp.objid
	AND ROWNUM = 1
	;

	EXCEPTION WHEN OTHERS
	THEN

		lv_service_plan_objid	:=	NULL;
		op_error_msg	:=	'Service Plan Not Found.';
		dbms_output.put_line(' FUNCTION CHECK_DATA_SAVER '||op_error_msg);
		RETURN lv_data_saver_flag;
	END;





	OPEN multi_rate_plan_curs(ip_esn,lv_service_plan_objid);
	FETCH multi_rate_plan_curs INTO multi_rate_plan_rec;

	IF multi_rate_plan_curs%notfound
	THEN

		multi_rate_plan_rec.x_priority := 1;

	END IF;

	CLOSE multi_rate_plan_curs;



	OPEN rate_plan_curs(lv_service_plan_objid,get_esn_details_rec.data_speed,multi_rate_plan_rec.x_priority,lv_parent_name);
	FETCH rate_plan_curs INTO rate_plan_rec;

	IF rate_plan_curs%NOTFOUND
	THEN
	CLOSE rate_plan_curs;

	op_error_code	:=	'9';
	op_error_msg	:=	'Carrier features not found';
	dbms_output.put_line(' FUNCTION CHECK_DATA_SAVER '||op_error_msg);
	RETURN lv_data_saver_flag;

	END IF;

	CLOSE rate_plan_curs;

	IF rate_plan_rec.data_saver = '1'
	THEN

		BEGIN

			SELECT COUNT(1)
			INTO LV_NON_DATA_SAVER_CNT
			FROM X_ESN_PROMO_HIST PROMO_HIST
			WHERE PROMO_HIST.ESN = IP_ESN
			AND PROMO_HIST.PROMO_HIST2X_PROMOTION  = (SELECT OBJID	FROM TABLE_X_PROMOTION
									WHERE 1 = 1
									AND X_PROMO_CODE = 'RDS')
			AND NVL(PROMO_HIST.EXPIRATION_DATE,SYSDATE + 1)		>	SYSDATE
			;


		EXCEPTION WHEN OTHERS
		THEN

			LV_NON_DATA_SAVER_CNT	:=	0;

		END;


		IF lv_non_data_saver_cnt = 0
		THEN

			lv_data_saver_flag	:=	'Y';

		ELSE
			lv_data_saver_flag	:=	'N';

		END IF;

	ELSE

		lv_data_saver_flag	:=	'NA';

	END IF;

	RETURN lv_data_saver_flag;

EXCEPTION WHEN OTHERS
THEN
	op_error_code	:=	'9';
	op_error_msg	:=	'CONVERT_BO_TO_SQL_PKG.check_data_saver main expn '||sqlerrm;
	dbms_output.put_line(' main exception '||op_error_msg);
	RETURN lv_data_saver_flag;

END CHECK_DATA_SAVER;


PROCEDURE CREATE_ACTION_ORDER_TYPE	(	ip_esn 					VARCHAR2
						,ip_action_type_name			VARCHAR2
						,ip_user				VARCHAR2
						,ip_source_system			VARCHAR2
						,ip_ct_reason				VARCHAR2
						,ip_transmission_method			VARCHAR2
						,op_call_trans_objid		OUT	NUMBER
						,op_ig_transaction_id		OUT	VARCHAR2
						,op_error_code			OUT	VARCHAR2
						,op_error_msg			OUT	VARCHAR2
						)
IS
-- customer type
 rs sa.customer_type;
 s sa.customer_type;

 -- call trans type
 ct sa.call_trans_type := call_trans_type ();
 c sa.call_trans_type := call_trans_type ();

 -- task type
 tt sa.task_type := task_type ();
 t sa.task_type := task_type ();

 -- ig transaction type
 it sa.ig_transaction_type := ig_transaction_type ();
 i sa.ig_transaction_type := ig_transaction_type ();

BEGIN

	op_error_code  := 0;
	op_error_msg  := 'success';

 -- Make sure the request type is passed
 IF ip_action_type_name IS NULL THEN
 op_error_code := 1;
 op_error_msg := 'RqstType cannot be NULL';
 RETURN;
 END IF;

 -- Make sure the ESN is passed
 IF ip_esn IS NULL THEN
 op_error_code := 1;
 op_error_msg := 'ESN/RqstType cannot be NULL';
 RETURN;
 END IF;

 -- instantiate the customer_type with the esn
 rs := customer_type ( i_esn => ip_esn);

 -- calling the customer type retrieve method
 s := rs.retrieve;

 IF s.response NOT LIKE '%SUCCESS%' THEN
 op_error_code := 1;
 op_error_msg := s.response;
 sa.util_pkg.insert_error_tab ( i_action => 'GETTING ESN',
 i_key => ip_esn,
 i_program_name => 'SA.SA.CONVERT_BO_TO_SQL_PKG.CREATE_ACTION_ORDER_TYPE' ,
 i_error_text => op_error_msg );
 RETURN;
 END IF;

 -- Make sure the ESN is active
 IF s.esn_part_inst_status <> '52' THEN
 op_error_code := 1;
 op_error_msg := 'ESN IS NOT IN ACTIVE';
 sa.util_pkg.insert_error_tab ( i_action => 'CHECKING ESN STATUS',
 i_key => ip_esn,
 i_program_name => 'SA.CONVERT_BO_TO_SQL_PKG.CREATE_ACTION_ORDER_TYPE' ,
                                   i_error_text     =>  op_error_msg );
    RETURN;

  END IF;

  -- Make sure the ESN is active
  IF s.site_part_status <> 'Active' THEN
    op_error_code  := 1;
    op_error_msg  := 'SITE PART IS NOT ACTIVE';
    sa.util_pkg.insert_error_tab ( i_action         => 'CHECKING SITE PART STATUS',
                                   i_key            =>  ip_esn,
                                   i_program_name   => 'SA.CONVERT_BO_TO_SQL_PKG.CREATE_ACTION_ORDER_TYPE' ,
                                   i_error_text     =>  op_error_msg );
    RETURN;

  END IF;

  -- START CREATE CALL TRANS

  -- Get the correct action type
  c.action_type := ct.get_action_type ( i_code_type => 'AT' ,
                                        i_code_name => ip_action_type_name );
  -- Get the user objid based on the login name
  BEGIN
    SELECT objid
    INTO   c.user_objid
    FROM   table_user
    WHERE  s_login_name = ip_user
	AND    ROWNUM = 1;
  EXCEPTION
      WHEN OTHERS THEN

	BEGIN

		SELECT objid
		INTO   c.user_objid
		FROM   table_user
		WHERE  s_login_name = 'SA'
		AND    ROWNUM = 1;

	EXCEPTION WHEN OTHERS
	THEN

		op_error_code  := 1;
		op_error_msg  := 'SA USER NOT FOUND IN TABLE USER';
		sa.util_pkg.insert_error_tab ( i_action         => 'CHECKING ACCESS FOR SA USER',
					       i_key            =>  ip_esn,
					       i_program_name   => 'SA.CONVERT_BO_TO_SQL_PKG.CREATE_ACTION_ORDER_TYPE' ,
					       i_error_text     =>  op_error_msg );
		RETURN;

	END;
  END;
  --

  -- instantiate call trans values
  ct  := sa.call_trans_type ( i_esn               => ip_esn            ,
                              i_action_type       => c.action_type     ,
                              i_sourcesystem      => ip_source_system  ,
                              i_sub_sourcesystem  => s.bus_org_id      ,
                              i_reason            => ip_ct_reason      ,
                              i_result            => 'Completed'       ,
                              i_ota_req_type      => NULL              ,
                              i_ota_type          => NULL              ,
                              i_total_units       => NULL              ,
                              i_total_days        => NULL              ,
                              i_total_sms_units   => NULL              ,
                              i_total_data_units  => NULL              ,
                              i_user_objid        => c.user_objid      ,
                              i_action_text       => ip_action_type_name       ,
                              i_new_due_date      => NULL              ,
                              i_call_trans_objid  => NULL              );

  -- call the call trans insert method
  c := ct.ins;

  DBMS_OUTPUT.PUT_lINE('C.RESPONSE : ' || c.response);

  -- if call_trans was not created successfully
  IF c.response NOT LIKE '%SUCCESS%' THEN

    op_error_code := 4;
    op_error_msg := 'Error while insert call_trans: ' || c.response;
    sa.util_pkg.insert_error_tab ( i_action         => 'CALL_TRANS INSERT FAILED',
                                   i_key            =>  ip_esn,
                                   i_program_name   => 'SA.CONVERT_BO_TO_SQL_PKG.CREATE_ACTION_ORDER_TYPE' ,
                                   i_error_text     =>  op_error_msg );
    RETURN;
  END IF;

  -- END CREATE CALL TRANS


  -- START CREATE TASK

  -- Make sure the contact is available
  IF s.contact_objid IS NULL THEN
    op_error_code   := 4;
    op_error_msg   := 'CONTACT INFO NOT FOUND';
    sa.util_pkg.insert_error_tab ( i_action         => 'CONTACT INFO NOT FOUND',
                                   i_key            =>  ip_esn,
                                   i_program_name   => 'SA.CONVERT_BO_TO_SQL_PKG.CREATE_ACTION_ORDER_TYPE' ,
                                   i_error_text     =>  op_error_msg );
    RETURN;
  END IF;

  -- Get order type
  t.order_type := it.get_ig_order_type ( i_actual_order_type => ip_action_type_name );

  -- Make sure the order type is valid
  IF t.order_type IS NULL THEN
    op_error_code   := 4;
    op_error_msg   := 'ORDER TYPE NOT CONFIGURED';
    sa.util_pkg.insert_error_tab ( i_action         => 'ORDER TYPE NOT CONFIGURED',
                                   i_key            =>  ip_esn,
                                   i_program_name   => 'SA.CONVERT_BO_TO_SQL_PKG.CREATE_ACTION_ORDER_TYPE' ,
                                   i_error_text     =>  op_error_msg );
    RETURN;
  END IF;

  -- instantiate task attributes
  tt := task_type ( i_call_trans_objid  => c.call_trans_objid ,
                    i_contact_objid     => s.contact_objid    ,
                    i_order_type        => t.order_type       ,
                    i_bypass_order_type => 0                  ,
                    i_case_code         => 0                  );



  -- call the insert method
  t := tt.ins;

  IF t.response <> 'SUCCESS' OR t.task_objid IS NULL OR t.task_id IS NULL THEN
    op_error_code := 5;
    op_error_msg := 'ERROR INSERTING TABLE_TASK: ' || t.response;
    sa.util_pkg.insert_error_tab ( i_action         => 'ERROR INSERTING TABLE_TASK',
                                   i_key            =>  ip_esn,
                                   i_program_name   => 'SA.CONVERT_BO_TO_SQL_PKG.CREATE_ACTION_ORDER_TYPE' ,
                                   i_error_text     =>  op_error_msg );
    RETURN;
  END IF;

  -- END CREATE TASK


  -- START CREATE IG TRANSACTION

  -- Set the account number when carrier parent is Verizon
  IF    s.short_parent_name = 'VZW' THEN
        i.account_num := '1161';
		--
  ELSIF s.short_parent_name = 'ATT' THEN
    -- getting account number for att
	  BEGIN
	    SELECT account_num
	    INTO   i.account_num
      FROM   sa.x_cingular_mrkt_info
	    WHERE  zip = s.zipcode
	    AND    rownum = 1;
	  EXCEPTION
	    WHEN OTHERS THEN
	  	  i.account_num := NULL;
	  END;
    --
  ELSE
     i.account_num := NULL; -- need to check
  END IF;

  -- Get the template value
  i.template := it.get_template ( i_technology          => t.technology,
                                  i_trans_profile_objid => t.trans_profile_objid );

  -- Validate template is valid
  IF i.template IS NULL THEN
    op_error_code := 5;
    op_error_msg := 'TEMPLATE NOT FOUND';
    sa.util_pkg.insert_error_tab ( i_action         => 'ERROR TEMPLATE NOT FOUND',
                                   i_key            =>  ip_esn,
                                   i_program_name   => 'SA.CONVERT_BO_TO_SQL_PKG.CREATE_ACTION_ORDER_TYPE' ,
                                   i_error_text     =>  op_error_msg );
    RETURN;
  END IF;

  -- Set the network login and password
  IF i.template IN ('TMOBILE', 'TMOSM', 'TMOUN') THEN
    i.network_login    := 'tracfone';
    i.network_password := 'Tr@cfon3';
  ELSE
    i.network_login    :=  NULL;
    i.network_password :=  NULL;
  END IF;

  -- set ig order type the same value as the task order type
  i.order_type := t.order_type;

  -- instantiate ig attributes
  it := ig_transaction_type ( i_esn                 =>  ip_esn                     ,
                              i_action_item_id      =>  t.task_id                  ,
                              i_msid                =>  s.min                      ,
                              i_min                 =>  s.min                      ,
                              i_technology_flag     =>  SUBSTR(s.technology,1,1)   ,
                              i_order_type          =>  i.order_type               ,
                              i_template            =>  i.template                 ,
                              i_rate_plan           =>  s.rate_plan                ,
                              i_zip_code            =>  s.zipcode                  ,
                              i_transaction_id      =>  gw1.trans_id_seq.NEXTVAL + ( POWER(2,28)),
                              i_phone_manf          =>  s.phone_manufacturer       ,
                              i_carrier_id          =>  s.carrier_objid            ,
                              i_iccid	            =>  s.iccid                    ,
                              i_network_login       =>  i.network_login            ,
                              i_network_password    =>  i.network_password         ,
                              i_account_num	    =>  i.account_num          	   ,
                              i_transmission_method =>  ip_transmission_method     ,
                              i_status              =>  'Q'                        ,
                              i_application_system  =>  'IG'                       ,
                              i_skip_ig_validation  =>  'Y'                        );

  -- insert ig row
  i := it.ins;

  IF i.response <> 'SUCCESS' THEN
    op_error_code  := 7;
    op_error_msg  := 'ERROR INSERTING IG_TRANSACTION: ' || i.response;
    sa.util_pkg.insert_error_tab ( i_action         => 'FAILED INSERT IG_TRANSACTION',
                                   i_key            =>  ip_esn,
                                   i_program_name   => 'SA.CONVERT_BO_TO_SQL_PKG.CREATE_ACTION_ORDER_TYPE' ,
                                   i_error_text     =>  op_error_msg );
    RETURN;
  END IF;

  -- END CREATE IG TRANSACTION
  op_call_trans_objid	:=	c.call_trans_objid;
  op_ig_transaction_id	:=	i.transaction_id;
  op_error_code  := 0;
  op_error_msg  := 'success';

EXCEPTION
   WHEN OTHERS THEN
     op_error_code  := 1;
     op_error_msg  := 'UNHANDLED EXCEPTION: ' || SQLERRM;
     sa.util_pkg.insert_error_tab ( i_action         => 'CREATING HOTLINE REQUEST',
                                    i_key            =>  NULL,
                                    i_program_name   => 'SA.CONVERT_BO_TO_SQL_PKG.CREATE_ACTION_ORDER_TYPE' ,
                                    i_error_text     =>  op_error_msg );
END create_action_order_type;

PROCEDURE update_data_saver
						(IP_ESN 				VARCHAR2
						,IP_ACTION_TYPE_NAME			VARCHAR2
						,IP_USER				VARCHAR2
						,IP_SOURCESYSTEM			VARCHAR2
						,OP_ERROR_CODE			OUT	VARCHAR2
						,OP_ERROR_MSG			OUT	VARCHAR2
						)
IS

lv_ct_reason			table_x_call_trans.x_reason%type;
lv_call_trans_objid		table_x_call_trans.objid%type;
lv_ig_transaction_id		gw1.ig_transaction.transaction_id%type;
lv_promo_objid			table_x_promotion.objid%type;

BEGIN

OP_ERROR_CODE	:=	'0';
OP_ERROR_MSG	:=	'success';



	IF IP_ACTION_TYPE_NAME	= 'RDS'
	THEN

		BEGIN

			SELECT OBJID
			INTO LV_PROMO_OBJID
			FROM TABLE_X_PROMOTION
			WHERE X_PROMO_CODE = IP_ACTION_TYPE_NAME
			;

		EXCEPTION WHEN OTHERS
		THEN
			OP_ERROR_CODE	:=	'99';
			OP_ERROR_MSG	:=	'Promo code '||IP_ACTION_TYPE_NAME||' not found.';

			RETURN;
		END;

	END IF;

	IF IP_ACTION_TYPE_NAME = 'ADS'
	THEN

		lv_ct_reason	:=	'Add Data Saver';

	ELSIF IP_ACTION_TYPE_NAME = 'RDS'
	THEN
		lv_ct_reason	:=	'Remove Data Saver';

	END IF;


sa.convert_bo_to_sql_pkg.create_action_order_type (ip_esn
						   ,ip_action_type_name
						   ,ip_user
						   ,ip_sourcesystem
						   ,lv_ct_reason
						   ,''
						   ,lv_call_trans_objid
						   ,lv_ig_transaction_id
						   ,op_error_code
						   ,op_error_msg
						   );






IF OP_ERROR_CODE	<> '0'
THEN
	dbms_output.put_line('After sa.SA.CONVERT_BO_TO_SQL_PKG.CREATE_ACTION_ORDER_TYPE '||OP_ERROR_CODE||' '||OP_ERROR_MSG);

	OP_ERROR_MSG	:=	'SA.CONVERT_BO_TO_SQL_PKG.CREATE_ACTION_ORDER_TYPE failed '||OP_ERROR_MSG;

	RETURN;
END IF;

	IF IP_ACTION_TYPE_NAME	=	'RDS'
	THEN

	sa.promotion_pkg.sp_ins_esn_promo_hist(	ip_esn
						,lv_call_trans_objid		--ip_calltrans_id
						,lv_promo_objid			--ip_promo_objid
						,''				--ip_expiration_date
						,''				--ip_bucket_id
						,op_error_code			--op_error_code
						,op_error_msg			--op_error_msg
						);

	ELSIF 	IP_ACTION_TYPE_NAME	=	'ADS'
	THEN

		UPDATE X_ESN_PROMO_HIST
		SET EXPIRATION_DATE = SYSDATE
		WHERE ESN = IP_ESN
		AND PROMO_HIST2X_PROMOTION	=	(SELECT OBJID
							FROM TABLE_X_PROMOTION
							WHERE X_PROMO_CODE = 'RDS');



	END IF;

OP_ERROR_CODE	:=	'0';
OP_ERROR_MSG	:=	'success';


EXCEPTION WHEN OTHERS
THEN

	op_error_code	:=	'99';
	op_error_msg	:=	'Main Exception CONVERT_BO_TO_SQL_PKG.UPDATE_DATA_SAVER '||SQLERRM;

END update_data_saver;




END CONVERT_BO_TO_SQL_PKG;
/