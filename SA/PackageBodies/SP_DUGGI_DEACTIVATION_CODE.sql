CREATE OR REPLACE PACKAGE BODY sa."SP_DUGGI_DEACTIVATION_CODE"
AS
 /********************************************************************************/
  /* Copyright ) 2001 Tracfone Wireless Inc. All rights reserved
  /*
  /********************************************************************************/
  v_package_name VARCHAR2(80) := '.SERVICE_DEACTIVATION()';
  /********************************************************************************/
  /*
  /* NAME: SERVICE_DEACTIVATION_PKG (BODY)
  /* PURPOSE: This package deactivate services attached to tracfone product
  /* FREQUENCY:
  /* PLATFORMS: Oracle 8.0.6 AND newer versions.
  /*
  /* REVISIONS:
  /* VERSION DATE WHO PURPOSE
  /* ------- ---------- ----- ---------------------------------------------
  /* 1.0 Initial Revision
  /* 1.1 05/10/2002 Mleon Added new carrier id on main cursor on deact-
  /* ivate_past_due.(changed was med by JR).
  /* Created a new procedure deactivate_any()
  /* Changed write_to_monitor to created contact info
  /* when there;s no info attahced to the esn that is
  /* beeb deactivated
  /* 1.1 08/09/02 GP Added logic to Reserve numbers when
  /* DEACT_HOLD is set to 1
  /* 1.2 07/05/02 SL Add X_SUB_SOURCESYSTEM field for call trans
  /* insert statement
  /* 1.3 08/16/02 SL Promo Code Project
  /* Remove TFU group
  /* 1.3 03/06/02 TCS Added a new procedure which will stop the ESN
  /* from deactivation, if that ESN is subscribed for
  /* deactivation protection program. It gets the
  /* ESN details from autopay_details table
  /* and insert it into x_send_ftp_auto table
  /* 1.4 10/18/02 VA Number Pooling Changes
  /* 1.5 10/23/02 NS Number Pooling Changes
  /* 1.6 04/10/03 SL Clarify Upgrade - sequence
  /* 1.7 07/21/03 GP Included CarrierID 101912 to(deactivate_past_due)
  /* 1.8 08/15/03 MN Modified deactivate_past_due to use table for
  /* carrier IDS to be excluded
  /* 1.9 11/07/03 GP Return line if flagged for number portability
  /* 2.0 03/03/04 CWL Changes for CR2564 (MT43886) in deactivate_any
  /* 2.1 04/27/04 MH CR2740 Changes for CR2740 Remove_Autopay_prc
  /* 2.2 06/25/04 MN Change past_due cursor clause pi2.x_port_in <> 1
  /* to pi2.x_port_in <> 1 or pi2.x_port_in is null
  /* 2.1 07/09/04 GP Added new procedure(deactService) that deactivates
  /* service from TOSS(WEBCSR). Logic comes from a
  /* combination of both deactivateservice.java and
  /* deactivateGSMService.java.
  /* 1.5 08/31/2004 TCS CR3200 Added new in parameter (ip_samemin)
  /* in procedure(deactService) this variable will
  /* be used to determine whether relate the line with
  /* new ESN in case of Upgrade phone process
  /* 2.3 09/07/2004 GP CR3208 Old code was mistakenly put back in for
  /* procedure(deactService), fixed it by using variable
  /* "intNotifycarr"
  /* 2.4 09/14/2004 GP CR3209 Bypass carrier rules when reserving MIN to
  /* new ESN for procedure(deactService)
  /* 2.5 09/17/2004 RG CR3153 Modifications for T-Mobile. In deactService
  /* set status of temp line to Deleted.
  /* 2.6 10/04/2004 GP CR3153 Modified deactivate_past_due to call
  /* deactService instead of deactivate_service.
  /* (deactivate_service has been removed)
  /* 2.7 10/12/2004 GP CR2620 Modified deactService's main cursor (cur_ph)
  /* added decode statement in x_part_inst_status field
  /* in the where clause.
  /* 2.8 10/25/2004 GP CR3318 Changed the order of param (strDeactType)
  /* from 3rd to 2nd param and added logic for
  /* NTN (Non Tracfone Number) deactivations. Also
  /* removed inticap function in order to conserve
  /* resources
  /* 2.9 11/02/2004 RG CR3327 Return Internal Port In lines instead of
  /* reserving it
  /* 3.0 11/08/2004 GP CR3353 Break Reserving GSM line in DeactService
  /* procedure
  /* 3.1 12/10/2004 GP CR3190 Flag ESN to expire minutes for NET10 phones
  /* if deact_reason = PastDue or Stolen in DeactService
  /* procedure
  /* 3.2 02/16/2005 GP CR3667 Void SIM if deactivation is GSM and
  /* deactivation code_type = 'DANEW'
  /* 3.3 02/03/2005 RG CR3327-1 Reset the x_port_in flag to 0 when internal
  /* port in lines are returned
  /* 3.4 03/07/2005 GP CR3728 removed greatest function from where clause
  /* in deactivate_past_due procedure
  /* 3.5 03/24/2005 RG CR3647 - Added new deact code MINCHANGE
  /* This will not send an action item for deactivation
  /* to the carrier - Will be used for T-Mobile Min change
  /* PVCS Revision No.
  /* 1.27 04/11/2005 GP CR3905 - Add ota_pending check in past_due proc.
  /* 04/12/05 VS CR3865 - Add few more deactivation reason code to
  /* remove_autopay_prc to de-enroll from autopay
  /* after the deactivation
  /* 1.28 04/20/05 VS Merged with existing code.
  /* 1.29 04/20/05 VS Modified to remove the reason "WAREHOUSE" (CR3865)
  /* 1.32 04/27/05 GP CR3971 - Set GSM line status to "Reserved Used" instead of
  /* "Reserved" in (deactService) procedure
  /* 1.33 05/20/2005 GP CR3830 - Delete OTA Pending records in (deactService)
  /* 1.34 06/03/2005 Fl CR4091 - Provide a mechanism or wrapper for Oracle package
  /* to enable modifications to be done within the package without
  /* affecting dependent modules.
  /* 1.35 07/01/05 VA CR4077 - AutoPay Bug Fix 2
  /* 1.36 07/08/05 OV CR3718 - Added ESN status 54 for ACTIVE UPGRADE reason
  /* 1.37 07/15/05 SL CR4102 - disable 90_DAY_SERVICE if esn past due
  /* 1.38 07/19/05 SL CR3922 - disable 52020_GRP is esn past due
  /* 1.39 08/05/05 VA EME_080505 - Modified to improve performance based on Curt's recommendations (PVCS Revision 1.7)
  /* 1.40 08/02/05 GP CR4245 - ILD project added call to (sp_ild_transaction) (PVCS Revision 1.8)
  /* 1.41 08/30/05 GP CR4478 - Updates incomplete PSMS transactions and OTA feature entries
  /* also fixes warehouse exchanges to reserve line for 7 days.
  /* 1.42 08/30/05 GP Correct Version Label - CR4384 (PVCS Revision 1.11)
  /* 1.43 10/07/05 GP CR4579 - Return lines deactivated by ReleaseReservedMIN (PVCS Revision 1.13)
  /* also added CarrierRules by technology.
  /* 1.43/1.14 03/06/06 NG CR5086 HOLD deactivation or suspension action item on an upgrade for Verizon
  /* 1.44/1.15 03/09/06 NG CR5056 + Minute Expiration Fix added
  /* 1.45/1.16 03/09/06 VA CR5086 - Changed the header to correct label and CR #
  /* 1.44/1.17 03/22/06 VA CR5124 - Inventory rules
  /* 1.45/1.18 03/31/06 IC CR5168 - Cleanup pending Past Due ESN's
  /* 1.46/1.19 04/11/06 VA CR4287 - NET10 EXPIRATION IN TOSS ( 2nd item)
  /* 1.47/1.22 05/04/06 GP CR5124-1 - Inventory rules Logic Fix
  /* 1.23 05/05/06 VA CR5202
  /* 1.24 05/08/06 VA Only CR4287 changes
  /* 1.25 05/09/06 VA Merged all the pending CRs (CR5168,CR5124-1) with the RLS 16 changes (CR4287 )
  /* 1.25.1.1 08/28/06 VA CR5566 (New label changed from CR5552 to CR5566)
  /* 1.26 05/11/06 VA CR5168 re-opened moved commit
  /* 1.27 06/06/06 IC CR4902 GSM enhancement project added 2 port reasons
  /* 1.28 07/27/06 IC CR5353 Need to be able to deactivate a ported phone when refurbishing
  /* Ignore the port-in flag that stops deactivation when the
  /* clarify refurbish process needs to deactivate a phone
  /* 1.29/1.30 08/28/06 VA CR5353 Merged with CR5566
  /* 1.31/1.32 09/06/06 IC CR5353 Include batch processing
  /* 1.33 09/29/06 CR5538 (New logic to release A/T/C lines, add CarrierRules by A/T/C technology)
  /* 1.34 10/12/06 Fix defect for CR5538
  /* 1.35/1.36 10/16/06 Fix defect for CR5538
  /* 1.36.1.0 01/24/07 CR5569-9 EME to remove table_num_scheme ref
  /* 1.37 03/09/07 RSI CR4479 Billing Platform Chagnes - Added Deactivation Protection Check for the new programs.
  1.38 06/20/07 CI CR6151 for Exchanges/Upgrades, set x_expire_dt same as service_end_date
  /********************************************************************************/
  /* New PVCS Structure /NEW_PVCS
  /* 1.5 04/24/08 CLindner POST 10G fixes
  /* 1.3/1.4 09/13/07 GK CR6459 Changes made for using the new schema.

  /* 1.1.1.1 09/27/07 NG CR6697 TDMA CASE CONTROL
  /* 1.1.1.2/3 09/27/07 VA CR6697 TDMA CASE CONTROL - Added the changes to the latest production version
  /* 1.1.1.4/5 02/19/08 VA CR6488 - Fix for defect #225
  ----
  /* 1.6 05/05/08 VA Unmerge CR6974 from CR7500
  /* 1.7 05/29/08 SK Modified deactivate_past_due as per CR 7596 to change the rownum from 1500 to 2500
  /* 1.8-1.10 09/10/08 CL CR6362 Past due port customers rule change
  /* 1.11 09/15/08 CL CR6362_PII Past due port customers additional rule change
  /* 1.12-13 10/08/2008 RB CR7233 Modified deactivate_past_due,Deactservice,
  remove_autopay_prc, deactivate_airtouch and
  deact_road_past_due for NONUSAGE reason
  /* 1.14-16 12/10/08 IC JS CR7233 add condition for NONUSAGE reason
  /* 1.17-20 12/17/08 IC JS CR7233 remove flash and set deact flag to 0 f customer redeems before deact job
  /* 1.21-22 12/18/08 IC JS CR7233 added Active site part record to cursor
  /* 1.23-1.24-1.25 12/24/08 AK CR7233 Removed flash, removed hard coded esn and added a slash at the end;
  /* 1.26 06/25/09 CL CR11083
  /* 1.27 07/14/09 CR11177 Phase III of CR8442 SEPARATED NONUSAGE FROM PASTDUE
  /* 1.28 07/28/09 CR11177 Phase III NONUSAGE CODE IS SAME OF PASTDUE 54
  /* 1.28.1.0/1 11/02/2009 CL CR12136
  /* 1.28.1.2/3/4 11/11/2009 CL CR12136 (to fix the AC Voided reason)
  /* 1.28.1.5 11/18/2009 VA -Fix for deact reasons for SIM
  /* 1.28.1.6 11/20/2009 VA -Fix for x_port_in flag
  /* 1.28.1.7 11/30/2009 NG exclude ST Defective Phone cases from closing during pass due job
  /* 1.28.1.8 11/30/2009 CL CR12245
  /* 1.28.1.9 12/01/2009 NG CR12245
  /* 1.33 12/01/2009 NG BRAND_SEP_IV
  /* 1.34 03/15/2010 VA CR13035 NTUL
  /* 1.35 03/22/2010 YM CR12898 New sdeact reason for LIFELINE SL PHONE NEVER RCVD
  /********************************************************************************/
  /* NEW CVS FILE STRUCTURE REVISIONS:
  /* VERSION DATE WHO PURPOSE
  /* ------- ---------- ----- ---------------------------------------------
  /* 1.5-7 06/11/2010 CWL CR13741 ESN line status mismatch
  /* 1.8 06/22/2010 Skuthadi new reason for PORT CANCEL for STCC, WSRD(website redesign) */
  /* 1.9 06/28/2010 PM CR12722 Sending Suspend 'S' instead of Deacts 'D' for the lines with x_post_in=2 in table_part_inst.
  /* 1.10 08/10/2010 PM CR12989 Excluding ESNs from Past Due deactivation, those have Reserved Queue Card attached to it.
  /* 1.11 08/26/2010 CL CR13337 To avoid Deactivating who added airtime on due date
  past due batch job would check each ESN right before deactivating */
  /* see past_due_batch_check_curs cursor*/
  /* 1.12 10/16/2010 SK CR14598 To check for RESERVED QUEUE cards just before Deactivting for Past Due */
  /* 1.12 02/16/2011 CL CR15335 */
  /* 1.16-19 06/29/2011 CL CR15146 CR15144 CR15317 */
  /* 1.21 07/12/2011 CL CR15146 CR15144 CR15317 correct upper case deact reasons */
  /* 1.21 07/12/2011 CL use site part iccid and update part2esn2part_inst to null when not reserved used */
  /* 1.22-23 09/27/2011 CL Fix ST deact job to work faster deactivate past due */
  /********************************************************************************/
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: SERVICE_DEACTIVATION_CODE.sql,v $
  --$Revision: 1.37 $
  --$Author: kacosta $
  --$Date: 2012/07/26 15:39:32 $
  --$ $Log: SERVICE_DEACTIVATION_CODE.sql,v $
  --$ Revision 1.37  2012/07/26 15:39:32  kacosta
  --$ CR21620 Update Query for Service_Deactivation
  --$
  --$ Revision 1.36  2012/07/20 17:51:46  kacosta
  --$ CR21077 Error 119 Active Service Not Found/CR21179 Deactivation Issue
  --$
  --$ Revision 1.35  2012/07/20 17:35:10  kacosta
  --$ CR21179 Deactivation Issue
  --$
  --$ Revision 1.34  2012/07/18 19:27:57  kacosta
  --$ CR21179 Deactivation Issue
  --$
  --$ Revision 1.33  2012/07/11 13:18:11  kacosta
  --$ CR21077 Error 119 Active Service Not Found
  --$
  --$ Revision 1.32  2012/07/11 13:00:04  kacosta
  --$ CR21077 Error 119 Active Service Not Found
  --$
  --$ Revision 1.31  2012/06/25 14:27:13  kacosta
  --$ CR21179 Deactivation Issue
  --$
  --$ Revision 1.30  2011/11/30 12:47:03  kacosta
  --$ CR18244 Refurbished Deactivation Reason Changes
  --$
  --$ Revision 1.29  2011/11/28 18:22:11  kacosta
  --$ CR18244 Refurbished Deactivation Reason Changes
  --$
  --$ Revision 1.28  2011/11/28 16:05:03  kacosta
  --$ CR18244 Refurbished Deactivation Reason Changes
  --$
  --$ Revision 1.27  2011/11/25 15:12:08  kacosta
  --$ CR18244 Refurbished Deactivation Reason Changes
  --$
  --$ Revision 1.26  2011/11/21 20:58:33  kacosta
  --$ CR18244 Refurbished Deactivation Reason Changes
  --$
  --$ Revision 1.25  2011/11/07 18:17:56  kacosta
  --$ CR18244 Refurbished Deactivation Reason Changes
  --$
  --$ Revision 1.24  2011/10/31 18:46:17  kacosta
  --$ CR18244 Refurbished Deactivation Reason Changes
  --$
  --$ Revision 1.23  2011/10/20 21:27:12  kacosta
  --$ CR18244 Refurbished Deactivation Reason Changes
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  CURSOR check_esn_curs(c_esn IN VARCHAR2) IS
    SELECT 1
      FROM table_site_part sp2
     WHERE 1 = 1
       AND NVL(sp2.part_status
              ,'Obsolete') IN ('CarrierPending'
                              ,'Active')
       AND sp2.x_service_id = c_esn
       AND NVL(sp2.x_expire_dt
              ,TO_DATE('1753-01-01 00:00:00'
                      ,'yyyy-mm-dd hh24:mi:ss')) > TRUNC(SYSDATE);
  check_esn_rec check_esn_curs%ROWTYPE;
  -------------------------------------------------------

  /********************************************************************************/
  /*
  /* Name: create_call_trans
  /* Description : Available in the specification part of package
  /********************************************************************************/
  PROCEDURE create_call_trans
  (
    ip_site_part   IN NUMBER
   ,ip_action      IN NUMBER
   ,ip_carrier     IN NUMBER
   ,ip_dealer      IN NUMBER
   ,ip_user        IN NUMBER
   ,ip_min         IN VARCHAR2
   ,ip_phone       IN VARCHAR2
   ,ip_source      IN VARCHAR2
   ,ip_transdate   IN DATE
   ,ip_units       IN NUMBER
   ,ip_action_text IN VARCHAR2
   ,ip_reason      IN VARCHAR2
   ,ip_result      IN VARCHAR2
   ,ip_iccid       IN VARCHAR2
   ,ip_brand_name  IN VARCHAR2
   ,op_calltranobj OUT NUMBER
  ) IS
    v_ct_seq NUMBER;
    -- 06/09/03
  BEGIN
    --Sp_Seq ('x_call_trans', v_ct_seq); -- 06/09/03
    SELECT sequ_x_call_trans.nextval
      INTO v_ct_seq
      FROM dual; --CR12136
    op_calltranobj := v_ct_seq;
    INSERT INTO table_x_call_trans
      (objid
      ,call_trans2site_part
      ,x_action_type
      ,x_call_trans2carrier
      ,x_call_trans2dealer
      ,x_call_trans2user
      ,x_min
      ,x_service_id
      ,x_sourcesystem
      ,x_transact_date
      ,x_total_units
      ,x_action_text
      ,x_reason
      ,x_result
      ,x_sub_sourcesystem
      , -- 07/05/2002 by SL
       x_iccid -- 07/07/2004 GP
       )
    VALUES
      (
       -- call_trans_seq_rec.val,
       v_ct_seq
      ,ip_site_part
      ,ip_action
      ,ip_carrier
      ,ip_dealer
      ,ip_user
      ,ip_min
      ,ip_phone
      ,ip_source
      ,ip_transdate
      ,ip_units
      ,ip_action_text
      ,ip_reason
      ,ip_result
      ,
       -- 'DBMS' -- 07/05/2002 by SL
       ip_brand_name
      ,
       -- insert the code_number to x_sub_sourcesystem field instead of code_name
       ip_iccid);

  END create_call_trans;
  /***************************************************/
  /* Name: write_to_monitor
  /* Description : Writes into monitor table
  /*
  /****************************************************/
  PROCEDURE write_to_monitor
  (
    site_part_objid IN NUMBER
   ,cust_site_objid IN NUMBER
   ,x_carrier_id    IN NUMBER
   ,site_part_msid  IN VARCHAR2
  ) IS

    --retrieve the deactivated site part
    CURSOR c1 IS
      SELECT *
        FROM table_site_part
       WHERE objid = site_part_objid;
    c1_rec c1%ROWTYPE;
    CURSOR c2(cust_site_objid_ip IN NUMBER) IS
      SELECT site_id
        FROM table_site
       WHERE objid = cust_site_objid_ip
         AND ROWNUM = 1;
    c2_rec c2%ROWTYPE;
    --retrieve the dealer_id for the site part
    CURSOR c3(sp_esn IN VARCHAR2) IS
      SELECT s.site_id site_id
        FROM table_site       s
            ,table_inv_role   ir
            ,table_inv_locatn il
            ,table_inv_bin    ib
            ,table_part_inst  pi
       WHERE s.objid = ir.inv_role2site
         AND ir.inv_role2inv_locatn = il.objid
         AND il.objid = ib.inv_bin2inv_locatn
         AND ib.objid = pi.part_inst2inv_bin
         AND pi.x_domain = 'PHONES'
         AND pi.part_serial_no = sp_esn
         AND ROWNUM = 1;
    c3_rec c3%ROWTYPE;
    CURSOR c4(ml_objid IN NUMBER) IS
      SELECT pn.x_manufacturer x_manufacturer
        FROM table_part_num  pn
            ,table_mod_level ml
       WHERE pn.objid = ml.part_info2part_num
         AND ml.objid = ml_objid;
    c4_rec c4%ROWTYPE;
    CURSOR c5(site_objid IN NUMBER) IS
      SELECT c.last_name || ', ' || c.first_name NAME
        FROM table_contact      c
            ,table_contact_role cr
       WHERE c.objid = cr.contact_role2contact
         AND cr.contact_role2site = site_objid
         AND ROWNUM = 1;
    c5_rec                   c5%ROWTYPE;
    v_new_site_objid         NUMBER;
    v_new_site_id            NUMBER;
    v_new_address_objid      NUMBER;
    v_new_contact_objid      NUMBER;
    v_new_contact_role_objid NUMBER;
    v_cust_site_objid        NUMBER;
    --EME to remove table_num_scheme ref
    new_site_id_format VARCHAR2(100) := NULL;
    --End EME
  BEGIN
    v_cust_site_objid := cust_site_objid;
    OPEN c1;
    FETCH c1
      INTO c1_rec;
    CLOSE c1;
    OPEN c5(c1_rec.site_part2site);
    FETCH c5
      INTO c5_rec;
    IF c5%NOTFOUND THEN
      CLOSE c5;
      /** get all the sequences **/
      --Sp_Seq ('address', v_new_address_objid); -- 06/09/03
      SELECT sequ_address.nextval
        INTO v_new_address_objid
        FROM dual; -- cr12136
      -- Sp_Seq ('new_site', v_new_site_objid); -- 06/09/03
      SELECT sequ_site.nextval
        INTO v_new_site_objid
        FROM dual; -- cr12136

      SELECT next_value
        INTO v_new_site_id
        FROM table_num_scheme
       WHERE NAME = 'Individual ID';
      UPDATE table_num_scheme
         SET next_value = next_value + 1
       WHERE NAME = 'Individual ID';
      --Sp_Seq ('new_contact', v_new_contact_objid); -- 06/09/03
      SELECT sequ_contact.nextval
        INTO v_new_contact_objid
        FROM dual; -- CR12136
      --Sp_Seq ('new_contact_role', v_new_contact_role_objid); -- 06/09/03
      SELECT sequ_contact_role.nextval
        INTO v_new_contact_role_objid
        FROM dual; -- CR12136
      /** insert into the address table */
      INSERT INTO table_address
        (objid
        ,address
        ,s_address
        ,city
        ,s_city
        ,state
        ,s_state
        ,zipcode
        ,address_2
        ,dev
        ,address2time_zone
        ,address2country
        ,address2state_prov
        ,update_stamp)
      VALUES
        (v_new_address_objid
        ,'No Address Provided'
        ,'NO ADDRESS PROVIDED'
        ,'No City Provided'
        ,'NO CITY PROVIDED'
        ,'FL'
        ,'FL'
        ,'33122'
        ,NULL
        ,NULL
        ,268435561
        ,268435457
        ,268435466
        ,SYSDATE);
      /** create a table_site dummy record **/
      INSERT INTO table_site
        (objid
        ,site_id
        ,NAME
        ,s_name
        ,external_id
        ,TYPE
        ,logistics_type
        ,is_support
        ,region
        ,s_region
        ,district
        ,s_district
        ,depot
        ,contr_login
        ,contr_passwd
        ,is_default
        ,notes
        ,spec_consid
        ,mdbk
        ,state_code
        ,state_value
        ,industry_type
        ,appl_type
        ,cut_date
        ,site_type
        ,status
        ,arch_ind
        ,alert_ind
        ,phone
        ,fax
        ,dev
        ,child_site2site
        ,support_office2site
        ,cust_primaddr2address
        ,cust_billaddr2address
        ,cust_shipaddr2address
        ,site_support2employee
        ,site_altsupp2employee
        ,report_site2bug
        ,primary2bus_org
        ,site2exch_protocol
        ,dealer2x_promotion
        ,x_smp_optional
        ,update_stamp
        ,x_fin_cust_id)
      VALUES
        (v_new_site_objid
        ,'IND' || TO_CHAR(v_new_site_id)
        ,'No Address Provided'
        ,'NO ADDRESS PROVIDED'
        ,NULL
        ,4
        ,0
        ,0
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,0
        ,NULL
        ,0
        ,NULL
        ,0
        ,NULL
        ,NULL
        ,NULL
        ,TO_DATE('01-JAN-1753')
        ,'INDV'
        ,0
        ,0
        ,0
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,v_new_address_objid
        , --need to update
         NULL
        ,v_new_address_objid
        , --need to update
         NULL
        ,NULL
        ,NULL
        ,-2
        ,NULL
        ,NULL
        ,0
        ,SYSDATE
        ,NULL);
      /** create a table_contact_role record **/
      INSERT INTO table_contact_role
        (objid
        ,role_name
        ,s_role_name
        ,primary_site
        ,dev
        ,contact_role2site
        ,contact_role2contact
        ,contact_role2gbst_elm
        ,update_stamp)
      VALUES
        (v_new_contact_role_objid
        ,NULL
        ,NULL
        ,1
        ,NULL
        ,v_new_site_objid
        ,v_new_contact_objid
        ,NULL
        ,SYSDATE);
      /** create a table_contact record **/
      INSERT INTO table_contact
        (objid
        ,first_name
        ,s_first_name
        ,last_name
        ,s_last_name
        ,phone
        ,fax_number
        ,e_mail
        ,mail_stop
        ,expertise_lev
        ,title
        ,hours
        ,salutation
        ,mdbk
        ,state_code
        ,state_value
        ,address_1
        ,address_2
        ,city
        ,state
        ,zipcode
        ,country
        ,status
        ,arch_ind
        ,alert_ind
        ,dev
        ,caller2user
        ,contact2x_carrier
        ,x_cust_id
        ,x_dateofbirth
        ,x_gender
        ,x_middle_initial
        ,x_mobilenumber
        ,x_no_address_flag
        ,x_no_name_flag
        ,x_pagernumber
        ,x_ss_number
        ,x_no_phone_flag
        ,update_stamp
        ,x_new_esn
        ,x_email_status
        ,x_html_ok)
      VALUES
        (v_new_contact_objid
        ,v_new_site_id
        ,v_new_site_id
        ,v_new_site_id
        ,v_new_site_id
        ,v_new_site_id
        ,NULL
        ,NULL
        ,NULL
        ,0
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,0
        ,NULL
        ,'No Address Provided'
        ,NULL
        ,'No Address Provided'
        ,'FL'
        ,'33122'
        ,'USA'
        ,0
        ,0
        ,0
        ,NULL
        ,NULL
        ,NULL
        ,v_new_site_id
        ,TO_DATE('01-JAN-1753')
        ,NULL
        ,NULL
        ,NULL
        ,1
        ,1
        ,NULL
        ,NULL
        ,1
        ,SYSDATE
        ,NULL
        ,0
        ,0);
      --
      /** update table_site_part **/
      UPDATE table_site_part
         SET site_part2site     = v_new_site_objid
            ,all_site_part2site = v_new_site_objid
            ,dir_site_objid     = v_new_site_objid
            ,site_objid         = v_new_site_objid
       WHERE objid = site_part_objid;
      /** now reopen with updated data **/
      OPEN c1;
      FETCH c1
        INTO c1_rec;
      CLOSE c1;
      OPEN c5(c1_rec.site_part2site);
      FETCH c5
        INTO c5_rec;
      CLOSE c5;
      /** done reopnenning **/
      /** reassinging cust_site_objid **/
      v_cust_site_objid := v_new_site_objid;
    END IF;
    IF c5%ISOPEN THEN
      CLOSE c5;
    END IF;
    /** move this to avoid double openning of cursors **/
    OPEN c2(v_cust_site_objid);
    FETCH c2
      INTO c2_rec;
    CLOSE c2;
    OPEN c3(c1_rec.serial_no);
    FETCH c3
      INTO c3_rec;
    CLOSE c3;
    OPEN c4(c1_rec.site_part2part_info);
    FETCH c4
      INTO c4_rec;
    CLOSE c4;
    --cwl2.put_line('Adam','site_part_objid:'||to_char(site_part_objid));
    INSERT INTO x_monitor
      (x_monitor_id
      ,x_date_mvt
      ,x_phone
      ,x_esn
      ,x_cust_id
      ,x_carrier_id
      ,x_dealer_id
      ,x_action
      ,x_reason_code
      ,x_line_worked
      ,x_line_worked_by
      ,x_line_worked_date
      ,x_islocked
      ,x_locked_by
      ,x_action_type_id
      ,x_ig_status
      ,x_ig_error
      ,x_pin
      ,x_manufacturer
      ,x_initial_act_date
      ,x_end_user
      ,x_msid --Number Pooling 10/18/02
       )
    VALUES
      ((seq_x_monitor_id.nextval + (POWER(2
                                         ,28)))
      ,SYSDATE
      ,c1_rec.x_min
      ,c1_rec.serial_no
      ,c2_rec.site_id
      ,TO_CHAR(x_carrier_id)
      ,c3_rec.site_id
      ,DECODE(c1_rec.x_notify_carrier
             ,1
             ,'D'
             ,0
             ,'S')
      ,c1_rec.x_deact_reason
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,DECODE(c1_rec.x_notify_carrier
             ,1
             ,0
             ,0
             ,1)
      ,NULL
      ,NULL
      ,c1_rec.x_pin
      ,c4_rec.x_manufacturer
      ,c1_rec.install_date
      ,c5_rec.name
      ,site_part_msid --Number Pooling Changes 10/18/02
       );
    COMMIT;
  END write_to_monitor;
  /*******************************************************************************************/
  /* Name: sp_update_exp_date_prc
  /* Description: New Procedure added to extend the expire_dt - Modified by TCS offshore Team
  /*
  /*******************************************************************************************/
  PROCEDURE sp_update_exp_date_prc
  (
    p_esn        IN VARCHAR2
   ,p_grace_time IN DATE
   ,op_result    OUT NUMBER
   ,op_msg       OUT VARCHAR2
  ) IS
    v_partinstcount  NUMBER;
    v_procedure_name VARCHAR2(80) := v_package_name || '.SP_UPDATE_EXP_DATE_PRC()';
    CURSOR cur_ph_c(ip_esn VARCHAR2) IS
      SELECT *
        FROM table_part_inst
       WHERE x_part_inst_status = '52'
         AND part_serial_no = ip_esn
         AND x_domain = 'PHONES';
    rec_ph        cur_ph_c%ROWTYPE;
    v_pi_hist_seq NUMBER;

    -- 06/09/03
  BEGIN
    op_result := 0;
    op_msg    := 'Update Successful';
    --Begin Is Valid ESN
    SELECT COUNT(*)
      INTO v_partinstcount
      FROM table_part_inst
     WHERE part_serial_no = p_esn
       AND x_domain = 'PHONES';
    IF v_partinstcount = 0 THEN
      op_msg    := 'ERROR - Esn not found';
      op_result := 1;
      RETURN;
    END IF;
    --Begin Is Phone Active
    SELECT COUNT(*)
      INTO v_partinstcount
      FROM table_part_inst
     WHERE part_serial_no = p_esn
       AND x_domain = 'PHONES'
       AND x_part_inst_status = '52';
    IF v_partinstcount = 0 THEN
      op_msg    := 'ERROR - Active esn not found';
      op_result := 1;
      RETURN;
    END IF;
    --Begin Update
    BEGIN
      UPDATE table_site_part
         SET x_expire_dt = p_grace_time
       WHERE x_service_id = p_esn
         AND part_status || '' = 'Active';
    EXCEPTION
      WHEN others THEN
        op_result := 1;
        op_msg    := 'Error - E_UpdateFailed, RECORD UPDATE Failed.';
        toss_util_pkg.insert_error_tab_proc('Update Table_site_part'
                                           ,NVL(p_esn
                                               ,'N/A')
                                           ,v_procedure_name);
        RETURN;
    END;
    BEGIN
      OPEN cur_ph_c(p_esn);
      FETCH cur_ph_c
        INTO rec_ph;
      CLOSE cur_ph_c;
      UPDATE table_part_inst
         SET warr_end_date = p_grace_time
       WHERE part_serial_no = p_esn
         AND x_domain || '' = 'PHONES' -- CR12136
         AND x_part_inst_status || '' = '52'; -- CR12136
      --Sp_Seq ('x_pi_hist', v_pi_hist_seq);
      SELECT sequ_x_pi_hist.nextval
        INTO v_pi_hist_seq
        FROM dual; -- CR12136
      INSERT INTO table_x_pi_hist
        (objid
        ,status_hist2x_code_table
        ,x_change_date
        ,x_change_reason
        ,x_cool_end_date
        ,x_creation_date
        ,x_deactivation_flag
        ,x_domain
        ,x_ext
        ,x_insert_date
        ,x_npa
        ,x_nxx
        ,x_old_ext
        ,x_old_npa
        ,x_old_nxx
        ,x_part_bin
        ,x_part_inst_status
        ,x_part_mod
        ,x_part_serial_no
        ,x_part_status
        ,x_pi_hist2carrier_mkt
        ,x_pi_hist2inv_bin
        ,x_pi_hist2part_inst
        ,x_pi_hist2part_mod
        ,x_pi_hist2user
        ,x_pi_hist2x_new_pers
        ,x_pi_hist2x_pers
        ,x_po_num
        ,x_reactivation_flag
        ,x_red_code
        ,x_sequence
        ,x_warr_end_date
        ,dev
        ,fulfill_hist2demand_dtl
        ,part_to_esn_hist2part_inst
        ,x_bad_res_qty
        ,x_date_in_serv
        ,x_good_res_qty
        ,x_last_cycle_ct
        ,x_last_mod_time
        ,x_last_pi_date
        ,x_last_trans_time
        ,x_next_cycle_ct
        ,x_order_number
        ,x_part_bad_qty
        ,x_part_good_qty
        ,x_pi_tag_no
        ,x_pick_request
        ,x_repair_date
        ,x_transaction_id)
      VALUES
        (
         -- 04/10/03 seq_x_pi_hist.nextval + POWER (2, 28),
         -- seq('x_pi_hist'),
         v_pi_hist_seq
        ,rec_ph.status2x_code_table
        ,SYSDATE
        ,'PROTECTION PLAN BATCH'
        ,rec_ph.x_cool_end_date
        ,rec_ph.x_creation_date
        ,rec_ph.x_deactivation_flag
        ,rec_ph.x_domain
        ,rec_ph.x_ext
        ,rec_ph.x_insert_date
        ,rec_ph.x_npa
        ,rec_ph.x_nxx
        ,NULL
        ,NULL
        ,NULL
        ,rec_ph.part_bin
        ,'84'
        ,rec_ph.part_mod
        ,rec_ph.part_serial_no
        ,rec_ph.part_status
        ,rec_ph.part_inst2carrier_mkt
        ,rec_ph.part_inst2inv_bin
        ,rec_ph.objid
        ,rec_ph.n_part_inst2part_mod
        ,rec_ph.created_by2user
        ,rec_ph.part_inst2x_new_pers
        ,rec_ph.part_inst2x_pers
        ,rec_ph.x_po_num
        ,rec_ph.x_reactivation_flag
        ,rec_ph.x_red_code
        ,rec_ph.x_sequence
        ,rec_ph.warr_end_date
        ,rec_ph.dev
        ,rec_ph.fulfill2demand_dtl
        ,rec_ph.part_to_esn2part_inst
        ,rec_ph.bad_res_qty
        ,rec_ph.date_in_serv
        ,rec_ph.good_res_qty
        ,rec_ph.last_cycle_ct
        ,rec_ph.last_mod_time
        ,rec_ph.last_pi_date
        ,rec_ph.last_trans_time
        ,rec_ph.next_cycle_ct
        ,rec_ph.x_order_number
        ,rec_ph.part_bad_qty
        ,rec_ph.part_good_qty
        ,rec_ph.pi_tag_no
        ,rec_ph.pick_request
        ,rec_ph.repair_date
        ,rec_ph.transaction_id);
      -- Insert into table_pi_hist
    EXCEPTION
      WHEN others THEN
        op_result := 1;
        op_msg    := 'Error - E_UpdateFailed, RECORD UPDATE Failed.';
        toss_util_pkg.insert_error_tab_proc('UPDATE TABLE_PART_INST'
                                           ,NVL(p_esn
                                               ,'N/A')
                                           ,v_procedure_name);
        RETURN;
    END;
  END sp_update_exp_date_prc;
  /**********************************************************************************************/
  /* Name: check_dpp_registered_prc
  /* Description: New Procedure added to check whether the ESN is subscribed for Deactivation
  /* Protection Program - Modified by TCS offshore Team
  /*
  /**********************************************************************************************/
  PROCEDURE check_dpp_registered_prc
  (
    p_esn      IN VARCHAR2
   ,out_result OUT PLS_INTEGER
  ) IS
    --Get the record for the esn from table_x_autopay_details table
    CURSOR curgetdpp_c(ip_esn IN VARCHAR2) IS
      SELECT *
        FROM table_x_autopay_details
       WHERE x_end_date IS NULL
         AND x_esn = ip_esn
         AND x_program_type = 4
         AND x_status = 'A'
            --CR4077
            -- AND x_account_status = '3'
         AND x_account_status IN ('3'
                                 ,'5')
         AND (x_receive_status IS NULL OR x_receive_status = 'Y');
    curgetdpp_rec    curgetdpp_c%ROWTYPE;
    v_expire_dt      DATE;
    v_amount         NUMBER;
    op_result        NUMBER;
    op_msg           VARCHAR2(50);
    v_procedure_name VARCHAR2(80) := v_package_name || '.CHECK_DPP_REGISTERED_PRC()';
    dayval           VARCHAR2(30);
    ---for CR 1142
  BEGIN
    out_result := 0; -- default is false
    OPEN curgetdpp_c(p_esn);
    FETCH curgetdpp_c
      INTO curgetdpp_rec;
    IF curgetdpp_c%FOUND THEN

      -- extend the expire_dt and insert into send_ftp
      -- CR5168 03/31/06 Duggi/Icanavan
      -- An extra call to the database. Commented because of PEC check
      -- SELECT x_expire_dt
      -- INTO v_expire_dt
      -- FROM TABLE_SITE_PART
      -- WHERE x_service_id = p_esn AND part_status = 'Active';
      -- sp_update_exp_date_prc (p_esn, v_expire_dt + 10, op_result, op_msg);
      sp_update_exp_date_prc(p_esn
                            ,SYSDATE + 10
                            ,op_result
                            ,op_msg);
      IF op_result = 0 -- If the update_exp_date is O.K
       THEN
        v_amount := get_amount_fun(4);
        BEGIN

          --Insert into send_ftp_auto
          SELECT TRIM(TO_CHAR(SYSDATE
                             ,'DAY'))
            INTO dayval
            FROM dual; -- CR 1142
          INSERT INTO x_send_ftp_auto
            (send_seq_no
            ,file_type_ind
            ,esn
            ,debit_date
            ,program_type
            ,account_status
            ,amount_due)
          VALUES
            (seq_x_send_ftp_auto.nextval
            ,'D'
            ,p_esn
            ,DECODE(dayval
                   ,'FRIDAY'
                   ,SYSDATE + 3
                   ,'SATURDAY'
                   ,SYSDATE + 2
                   ,SYSDATE + 1)
            , -- CR 1142
             curgetdpp_rec.x_program_type
            ,'A'
            ,v_amount --from pricing table
             );
          out_result := 1;
        EXCEPTION
          WHEN others THEN
            toss_util_pkg.insert_error_tab_proc('INSERT INTO SEND_FTP_AUTO'
                                               ,NVL(p_esn
                                                   ,'N/A')
                                               ,v_procedure_name);
            out_result := 0;
            RETURN;
        END;
      END IF;
    ELSE

      --set the outparameter as false and return it
      out_result := 0;
    END IF;
    CLOSE curgetdpp_c;
  EXCEPTION
    WHEN others THEN
      out_result := 0;
      toss_util_pkg.insert_error_tab_proc('Error IN check_dpp_registered'
                                         ,NVL(p_esn
                                             ,'N/A')
                                         ,v_procedure_name);
      RETURN;
  END check_dpp_registered_prc;
  /*****************************************************************************/
  /* Name: get_amount_fun
  /* Description: New Procedure added to get the monthly fee for Deactivation
  /* Protection Program - Modified by TCS
  /*
  /******************************************************************************/
  FUNCTION get_amount_fun(p_prg_type NUMBER) RETURN NUMBER IS
    v_amount NUMBER := 7.99;
    err_no   NUMBER;
    v_function_name CONSTANT VARCHAR2(200) := v_package_name || '.get_amount()';
  BEGIN
    IF p_prg_type = 4 THEN
      SELECT x_retail_price
        INTO v_amount
        FROM table_x_pricing
       WHERE x_pricing2part_num = (SELECT objid
                                     FROM table_part_num
                                    WHERE part_number = 'APPDEACTMON');
    END IF;
    RETURN v_amount;
  EXCEPTION
    WHEN others THEN
      err_no := toss_util_pkg.insert_error_tab_fun('Failed retrieving Amount - Mnthly fee '
                                                  ,p_prg_type
                                                  ,v_function_name);
      RETURN v_amount;
  END get_amount_fun;
  /**********************************************************************************************/
  /* Name: remove_autopay_prc
  /* Description : New Procedure added to remove the ESN from Autopay promotions and
  /* unsubscribe from Autopay program - Modified by TCS offshore Team
  /*******************************************************************************************/
  -- BRAND_SEP
  PROCEDURE remove_autopay_prc
  (
    p_esn        IN VARCHAR2
   ,p_brand_name IN VARCHAR2
   ,out_success  OUT NUMBER
  ) IS
    v_prg_type       NUMBER;
    v_cycle_number   NUMBER;
    v_cust_name      VARCHAR2(45);
    v_procedure_name VARCHAR2(80) := v_package_name || '.REMOVE_AUTOPAY()';
    ------------------------------------------------------------
    CURSOR curautoinfo_c(c_esn VARCHAR2) IS
      SELECT *
        FROM table_x_autopay_details
       WHERE x_esn = c_esn
         AND x_status = 'A'
         AND (x_end_date IS NULL OR x_end_date = TO_DATE('01-jan-1753'
                                                        ,'dd-mon-yyyy'));
    curautoinfo_rec curautoinfo_c%ROWTYPE;
    ------------------------------------------------------------
    CURSOR part_inst_curs(c_esn IN VARCHAR2) IS
      SELECT x_part_inst_status
        FROM table_part_inst
       WHERE part_serial_no = c_esn;
    part_inst_rec part_inst_curs%ROWTYPE;
    ------------------------------------------------------------
    CURSOR carrier_curs(c_min IN VARCHAR2) IS
      SELECT part_inst2carrier_mkt
        FROM table_part_inst
       WHERE part_serial_no = c_min;
    carrier_rec carrier_curs%ROWTYPE;
    ------------------------------------------------------------
    CURSOR site_part_curs(c_esn IN VARCHAR2) IS
      SELECT *
        FROM table_site_part
       WHERE x_service_id = c_esn
         AND part_status IN ('Active'
                            ,'Inactive')
       ORDER BY install_date DESC;
    site_part_rec site_part_curs%ROWTYPE;
    ------------------------------------------------------------
    CURSOR user_curs(c_login_name IN VARCHAR2) IS
      SELECT objid
        FROM table_user
       WHERE s_login_name = UPPER(c_login_name);
    user_rec         user_curs%ROWTYPE;
    v_call_trans_seq NUMBER;
    -- 06/09/03
    --------------------------------------------------
  BEGIN
    -- BRAND_SEP
    --Get the autopay promotions details for the ESN
    out_success := 0;
    OPEN curautoinfo_c(p_esn);
    FETCH curautoinfo_c
      INTO curautoinfo_rec;
    IF curautoinfo_c%FOUND THEN
      OPEN part_inst_curs(p_esn);
      FETCH part_inst_curs
        INTO part_inst_rec;
      CLOSE part_inst_curs;
      OPEN site_part_curs(p_esn);
      FETCH site_part_curs
        INTO site_part_rec;
      CLOSE site_part_curs;
      OPEN carrier_curs(site_part_rec.x_min);
      FETCH carrier_curs
        INTO carrier_rec;
      CLOSE carrier_curs;
      OPEN user_curs('SA');
      FETCH user_curs
        INTO user_rec;
      CLOSE user_curs;
      --update autopay_details
      UPDATE table_x_autopay_details
         SET x_status         = 'I'
            ,x_end_date       = SYSDATE
            ,x_account_status = 9
       WHERE objid = curautoinfo_rec.objid;
      --Sp_Seq ('x_call_trans', v_call_trans_seq); -- 06/09/03
      SELECT sequ_x_call_trans.nextval
        INTO v_call_trans_seq
        FROM dual; -- CR12136
      INSERT INTO table_x_call_trans
        (objid
        ,call_trans2site_part
        ,x_action_type
        ,x_call_trans2carrier
        ,x_call_trans2dealer
        ,x_call_trans2user
        ,x_line_status
        ,x_min
        ,x_service_id
        ,x_sourcesystem
        ,x_transact_date
        ,x_total_units
        ,x_action_text
        ,x_reason
        ,x_result
        ,x_sub_sourcesystem)
      VALUES
        (
         -- 04/10/03 (seq_x_call_trans.NEXTVAL + POWER (2, 28)),
         -- seq('x_call_trans'),
         v_call_trans_seq
        ,site_part_rec.objid
        ,'83'
        ,carrier_rec.part_inst2carrier_mkt
        ,site_part_rec.site_part2site
        ,user_rec.objid
        ,'13'
        ,site_part_rec.x_min
        ,site_part_rec.x_service_id
        ,'AUTOPAY_BATCH'
        ,SYSDATE
        ,0
        ,'STAYACT UNSUBSCRIBE'
        , --'Cancellation', --CR 1157
         'TOSS Deactivation'
        ,
         --'STAYACT UNSUBSCRIBE',
         'Completed'
        ,p_brand_name);
      -- if part_inst_rec.x_part_inst_status = '54' then
      -- Added more deactivation reason codes.
      -- CR7233 Added NONUSAGE deactivation reason
      IF site_part_rec.x_deact_reason IN ('NO NEED OF PHONE'
                                         ,'PAST DUE'
                                         ,'PASTDUE'
                                         ,'SALE OF CELL PHONE'
                                         ,'SELL PHONE'
                                         ,'STOLEN'
                                         ,'DEFECTIVE'
                                         ,'SEQUENCE MISMATCH'
                                         ,'RISK ASSESSMENT'
                                         ,'STOLEN CREDIT CARD'
                                         ,'UPGRADE'
                                         ,'REFURBISHED'
                                         ,'PORT OUT'
                                         ,'NON TOPP LINE'
                                         ,'CLONED'
                                         ,'OVERDUE EXCHANGE'
                                         ,'NONUSAGE') THEN

        --insert into send_ftp table
        INSERT INTO x_send_ftp_auto
          (send_seq_no
          ,file_type_ind
          ,esn
          ,program_type
          ,account_status
          ,amount_due)
        VALUES
          (seq_x_send_ftp_auto.nextval
          ,'D'
          ,p_esn
          ,curautoinfo_rec.x_program_type
          ,'D'
          ,0);
      ELSE
        INSERT INTO x_autopay_pending
          (objid
          ,x_creation_date
          ,x_esn
          ,x_program_type
          ,x_account_status
          ,x_status
          ,x_start_date
          ,x_end_date
          ,x_cycle_number
          ,x_program_name
          ,x_enroll_date
          ,x_first_name
          ,x_last_name
          ,x_receive_status
          ,x_autopay_details2site_part
          ,x_autopay_details2x_part_inst
          ,x_autopay_details2contact
          ,x_source_flag
          ,x_enroll_amount
          ,x_source
          ,x_language_flag
          ,x_payment_type)
        VALUES
          (curautoinfo_rec.objid
          ,curautoinfo_rec.x_creation_date
          ,curautoinfo_rec.x_esn
          ,curautoinfo_rec.x_program_type
          ,curautoinfo_rec.x_account_status
          ,curautoinfo_rec.x_status
          ,curautoinfo_rec.x_start_date
          ,SYSDATE
          ,curautoinfo_rec.x_cycle_number
          ,curautoinfo_rec.x_program_name
          ,curautoinfo_rec.x_enroll_date
          ,curautoinfo_rec.x_first_name
          ,curautoinfo_rec.x_last_name
          ,curautoinfo_rec.x_receive_status
          ,curautoinfo_rec.x_autopay_details2site_part
          ,curautoinfo_rec.x_autopay_details2x_part_inst
          ,curautoinfo_rec.x_autopay_details2contact
          ,'D'
          ,curautoinfo_rec.x_enroll_amount
          ,curautoinfo_rec.x_source
          ,curautoinfo_rec.x_language_flag
          ,curautoinfo_rec.x_payment_type);
      END IF;
      out_success := 1;
    END IF;
    CLOSE curautoinfo_c;
  EXCEPTION
    WHEN others THEN
      out_success := 0;
      toss_util_pkg.insert_error_tab_proc('Error IN remove_autopay'
                                         ,p_esn
                                         ,v_procedure_name);
  END remove_autopay_prc;
  /*****************************************************************************/
  /* */
  /* Name: deactivate_past_due */
  /* Description : Available in the specification part of package */
  /*****************************************************************************/
  PROCEDURE deactivate_past_due
  (
    p_bus_org_id    IN VARCHAR2
   ,p_mod_divisor   IN NUMBER DEFAULT 1
   ,p_mod_remainder IN NUMBER DEFAULT 0
  ) IS
    --------------------------------------------------------------------
    v_user           table_user.objid%TYPE;
    v_returnflag     VARCHAR2(20);
    v_returnmsg      VARCHAR2(200);
    dpp_regflag      PLS_INTEGER;
    v_action         VARCHAR2(50) := 'x_service_id is null in Table_site_part';
    v_procedure_name VARCHAR2(50) := '.ST_SERVICE_DEACT_CATCHUP.DEACTIVATE_PAST_DUE';
    intcalltranobj   NUMBER := 0;
    blnotapending    BOOLEAN := FALSE;
    --------------------------------------------------------------------
    v_start       DATE;
    v_end         DATE;
    v_time_used   NUMBER(10
                        ,2);
    v_start_1     DATE;
    v_end_1       DATE;
    v_time_used_1 NUMBER(10
                        ,2);
    ctr           NUMBER := 0;
    --
    --CR21179 Start Kacosta 06/21/2012
    l_i_error_code    PLS_INTEGER := 0;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    --CR21179 End Kacosta 06/21/2012
    --
    --------------------------------------------------------------------
    --CR21179 Start Kacosta 06/21/2012
    --CURSOR c1 IS
    --  SELECT /*+ ORDERED use_nl(pi2) use_nl(ca) use_nl(pi) use_nl(ib) use_nl(ir) use_nl(ml) use_nl(pn) */
    --   sp.objid          site_part_objid
    --  ,sp.x_expire_dt
    --  ,sp.x_service_id   x_service_id
    --  ,sp.x_min          x_min
    --  ,sp.serial_no      x_esn
    --  ,sp.x_msid
    --  ,ca.objid          carrier_objid
    --  ,ir.inv_role2site  site_objid
    --  ,ca.x_carrier_id   x_carrier_id
    --  ,sp.site_objid     cust_site_objid
    --  ,pi.objid          esnobjid
    --  ,pi.part_serial_no part_serial_no
    --  ,pi.x_iccid
    --  ,pn.x_ota_allowed
    --  ,bo.org_id
    --    FROM (SELECT /*+ ORDERED INDEX(sp SP_STATUS_EXP_DT_IDX)*/
    --           sp.objid
    --          ,sp.x_service_id
    --          ,sp.x_min
    --          ,sp.x_msid
    --          ,sp.site_objid
    --          ,sp.serial_no
    --          ,sp.x_expire_dt
    --            FROM table_site_part sp
    --                ,table_mod_level ml
    --                ,table_part_num  pn
    --                ,table_bus_org   bo
    --           WHERE 1 = 1
    --             AND NVL(sp.part_status
    --                    ,'Obsolete') = 'Active'
    --             AND NVL(sp.x_expire_dt
    --                    ,TO_DATE('1753-01-01 00:00:00'
    --                            ,'yyyy-mm-dd hh24:mi:ss')) > TO_DATE('1753-02-01 00:00:00'
    --                                                                ,'yyyy-mm-dd hh24:mi:ss')
    --             AND NVL(sp.x_expire_dt
    --                    ,TO_DATE('1753-01-01 00:00:00'
    --                            ,'yyyy-mm-dd hh24:mi:ss')) < TRUNC(SYSDATE)
    --             AND MOD(sp.objid
    --                    ,p_mod_divisor) = p_mod_remainder
    --             AND ml.objid = sp.site_part2part_info
    --             AND pn.objid = ml.part_info2part_num
    --             AND bo.objid = pn.part_num2bus_org
    --             AND bo.org_id || '' = p_bus_org_id) sp
    --        ,table_part_inst pi2
    --        ,table_x_carrier ca
    --        ,table_part_inst pi
    --        ,table_inv_bin ib
    --        ,table_inv_role ir
    --        ,table_mod_level ml
    --        ,table_part_num pn
    --        ,table_bus_org bo
    --   WHERE 1 = 1
    --     AND pi2.x_domain || '' = 'LINES'
    --     AND pi2.part_serial_no = NVL(sp.x_min
    --                                 ,'NONE')
    --     AND ca.objid = pi2.part_inst2carrier_mkt
    --     AND NOT EXISTS (SELECT e.x_carrier_id
    --            FROM x_excluded_pastduedeact e
    --           WHERE ca.x_carrier_id = e.x_carrier_id)
    --     AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
    --     AND ib.objid = pi.part_inst2inv_bin
    --     AND ml.part_info2part_num = pn.objid
    --     AND pn.part_num2bus_org = bo.objid
    --     AND pi.n_part_inst2part_mod = ml.objid
    --     AND pi.x_domain = 'PHONES'
    --     AND pi.part_serial_no = NVL(sp.x_service_id
    --                                ,'NONE')
    --     AND NOT EXISTS (SELECT '1'
    --            FROM table_part_inst pi3
    --           WHERE pi3.part_to_esn2part_inst = pi.objid
    --             AND pi3.x_domain = 'REDEMPTION CARDS'
    --             AND pi3.x_part_inst_status = '400');
    -- AND ROWNUM <10001;
    CURSOR c1 IS
      SELECT /*+ ORDERED use_nl(pi2) use_nl(ca) use_nl(ib) use_nl(ir) */
       sp.objid               site_part_objid
      ,sp.x_expire_dt
      ,sp.x_service_id        x_service_id
      ,sp.x_min               x_min
      ,sp.serial_no           x_esn
      ,sp.x_msid
      ,ca.objid               carrier_objid
      ,ir.inv_role2site       site_objid
      ,ca.x_carrier_id        x_carrier_id
      ,sp.site_objid          cust_site_objid
      ,sp.esnobjid            esnobjid
      ,sp.part_serial_no      part_serial_no
      ,sp.x_iccid
      ,sp.x_ota_allowed
      ,sp.org_id
      ,sp.site_part2part_info
      ,sp.esn2part_info
        FROM (SELECT /*+ ORDERED INDEX(sp sp_status_exp_dt_idx)*/
               sp.objid
              ,sp.x_service_id
              ,sp.x_min
              ,sp.x_msid
              ,sp.site_objid
              ,sp.serial_no
              ,sp.x_expire_dt
              ,tpi_esn.objid esnobjid
              ,tpi_esn.part_serial_no
              ,tpi_esn.x_iccid
              ,pn.x_ota_allowed
              ,bo.org_id
              ,tpi_esn.part_inst2inv_bin
              ,NVL(site_part2part_info
                  ,-1) site_part2part_info
              ,tpi_esn.n_part_inst2part_mod esn2part_info
                FROM table_site_part sp
                JOIN table_part_inst tpi_esn
                  ON sp.x_service_id = tpi_esn.part_serial_no
                JOIN table_mod_level ml
                  ON tpi_esn.n_part_inst2part_mod = ml.objid
                JOIN table_part_num pn
                  ON ml.part_info2part_num = pn.objid
                JOIN table_bus_org bo
                  ON pn.part_num2bus_org = bo.objid
               WHERE 1 = 1
                 AND NVL(sp.part_status
                        ,'Obsolete') = 'Active'
                        AND sp.x_service_id = '256691486903305571'
                 AND NVL(sp.x_expire_dt
                        ,TO_DATE('1753-01-01 00:00:00'
                                ,'yyyy-mm-dd hh24:mi:ss')) > TO_DATE('1753-02-01 00:00:00'
                                                                    ,'yyyy-mm-dd hh24:mi:ss')
                 AND NVL(sp.x_expire_dt
                        ,TO_DATE('1753-01-01 00:00:00'
                                ,'yyyy-mm-dd hh24:mi:ss')) < TRUNC(SYSDATE)
                 AND MOD(sp.objid
                        ,p_mod_divisor) = p_mod_remainder
                 AND tpi_esn.x_domain = 'PHONES'
                 AND bo.org_id || '' = p_bus_org_id
                 AND NOT EXISTS (SELECT '1'
                        FROM table_part_inst pi3
                       WHERE pi3.part_to_esn2part_inst = tpi_esn.objid

                         AND pi3.x_domain = 'REDEMPTION CARDS'
                         AND pi3.x_part_inst_status = '400')) sp
        LEFT OUTER JOIN table_inv_bin ib
          ON sp.part_inst2inv_bin = ib.objid
        LEFT OUTER JOIN table_inv_role ir
          ON ib.inv_bin2inv_locatn = ir.inv_role2inv_locatn
        LEFT OUTER JOIN table_part_inst pi2
          ON sp.x_min = pi2.part_serial_no
        LEFT OUTER JOIN table_x_carrier ca
          ON pi2.part_inst2carrier_mkt = ca.objid
       WHERE 1 = 1
         AND pi2.x_domain || '' = 'LINES';
    --
    c1_rec c1%ROWTYPE;
    --
    CURSOR call_trans_igt_info_curs(c_n_site_part_objid IN sa.table_x_call_trans.call_trans2site_part%TYPE) IS
      SELECT igt.carrier_id igt_carrier_id
            ,txc.objid      igt_carrier_objid
        FROM sa.table_x_call_trans xct
        JOIN sa.table_task tbt
          ON xct.objid = tbt.x_task2x_call_trans
        JOIN gw1.ig_transaction igt
          ON tbt.task_id = igt.action_item_id
        JOIN table_x_carrier txc
          ON igt.carrier_id = txc.x_carrier_id
       WHERE xct.call_trans2site_part = c_n_site_part_objid
         AND xct.x_action_type <> '2'
         AND xct.x_result = 'Completed'
         AND igt.status = 'S'
         AND igt.order_type NOT IN ('S'
                                   ,'D')
         AND igt.creation_date = (SELECT MAX(igt_max_xact.creation_date)
                                    FROM sa.table_x_call_trans xct_max_xact
                                    JOIN sa.table_task tbt_max_xact
                                      ON xct_max_xact.objid = tbt_max_xact.x_task2x_call_trans
                                    JOIN gw1.ig_transaction igt_max_xact
                                      ON tbt_max_xact.task_id = igt_max_xact.action_item_id
                                   WHERE xct_max_xact.call_trans2site_part = c_n_site_part_objid
                                     AND xct_max_xact.x_action_type <> '2'
                                     AND xct_max_xact.x_result = 'Completed'
                                     AND igt_max_xact.status = 'S'
                                     AND igt_max_xact.order_type NOT IN ('S'
                                                                        ,'D'));
    --
    call_trans_igt_info_rec call_trans_igt_info_curs%ROWTYPE;
    --
    CURSOR call_trans_igth_info_curs(c_n_site_part_objid IN sa.table_x_call_trans.call_trans2site_part%TYPE) IS
      SELECT igh.carrier_id igh_carrier_id
            ,txc.objid      igh_carrier_objid
        FROM sa.table_x_call_trans xct
        JOIN sa.table_task tbt
          ON xct.objid = tbt.x_task2x_call_trans
        JOIN gw1.ig_transaction_history igh
          ON tbt.task_id = igh.action_item_id
        JOIN table_x_carrier txc
          ON igh.carrier_id = txc.x_carrier_id
       WHERE xct.call_trans2site_part = c_n_site_part_objid
         AND xct.x_action_type <> '2'
         AND xct.x_result = 'Completed'
         AND igh.status = 'S'
         AND igh.order_type NOT IN ('S'
                                   ,'D')
         AND igh.creation_date = (SELECT MAX(igh_max_xact.creation_date)
                                    FROM sa.table_x_call_trans xct_max_xact
                                    JOIN sa.table_task tbt_max_xact
                                      ON xct_max_xact.objid = tbt_max_xact.x_task2x_call_trans
                                    JOIN gw1.ig_transaction_history igh_max_xact
                                      ON tbt_max_xact.task_id = igh_max_xact.action_item_id
                                   WHERE xct_max_xact.call_trans2site_part = c_n_site_part_objid
                                     AND xct_max_xact.x_action_type <> '2'
                                     AND xct_max_xact.x_result = 'Completed'
                                     AND igh_max_xact.status = 'S'
                                     AND igh_max_xact.order_type NOT IN ('S'
                                                                        ,'D'));
    --
    call_trans_igth_info_rec call_trans_igth_info_curs%ROWTYPE;
    --
    CURSOR excluded_pastduedeact_curs(c_n_carrier_id x_excluded_pastduedeact.x_carrier_id%TYPE) IS
      SELECT xep.x_carrier_id excluded_pastduedeact
        FROM x_excluded_pastduedeact xep
       WHERE xep.x_carrier_id = c_n_carrier_id;
    --
    excluded_pastduedeact_rec excluded_pastduedeact_curs%ROWTYPE;
    --
    --CR21179 End Kacosta 06/21/2012
    --
    CURSOR c_chkotapend(c_esn IN VARCHAR2) IS
      SELECT 'X'
        FROM table_x_call_trans
       WHERE objid = (SELECT MAX(objid)
                        FROM table_x_call_trans
                       WHERE x_service_id = c_esn)
         AND x_result = 'OTA PENDING'
         AND x_action_type = '6';
    r_chkotapend c_chkotapend%ROWTYPE;

    CURSOR check_active_min_curs(c_min IN VARCHAR2) IS
      SELECT 1
        FROM table_site_part sp2
       WHERE 1 = 1
         AND NVL(sp2.part_status
                ,'Obsolete') IN ('CarrierPending'
                                ,'Active')
         AND sp2.x_min = c_min
         AND NVL(sp2.x_expire_dt
                ,TO_DATE('1753-01-01 00:00:00'
                        ,'yyyy-mm-dd hh24:mi:ss')) > TRUNC(SYSDATE);
    check_active_min_rec check_active_min_curs%ROWTYPE;

    CURSOR past_due_batch_check_curs(c_sp_objid IN NUMBER) IS
      SELECT sp.objid
        FROM table_site_part sp
       WHERE 1 = 1
         AND sp.part_status = 'Active'
         AND NVL(sp.x_expire_dt
                ,TO_DATE('1753-01-01 00:00:00'
                        ,'yyyy-mm-dd hh24:mi:ss')) > TO_DATE('1753-02-01 00:00:00'
                                                            ,'yyyy-mm-dd hh24:mi:ss')
         AND NVL(sp.x_expire_dt
                ,TO_DATE('1753-01-01 00:00:00'
                        ,'yyyy-mm-dd hh24:mi:ss')) < TRUNC(SYSDATE)
         AND sp.objid = c_sp_objid;
    past_due_batch_check_rec past_due_batch_check_curs%ROWTYPE;
    ------------------------------------------------------------------------------------------------
  BEGIN
    --
    --CR21179 Start Kacosta 06/21/2012
    BEGIN
      --
      bau_maintenance_pkg.fix_1753_due_dates(p_bus_org_id    => p_bus_org_id
                                            ,p_mod_divisor   => p_mod_divisor
                                            ,p_mod_remainder => p_mod_remainder
                                            ,p_error_code    => l_i_error_code
                                            ,p_error_message => l_v_error_message);
      --
    EXCEPTION
      WHEN others THEN
        --
        NULL;
        --
    END;
    --CR21179 End Kacosta 06/21/2012
    --
    v_start_1 := SYSDATE;

    SELECT objid
      INTO v_user
      FROM table_user
     WHERE s_login_name = 'SA';

    FOR c1_rec IN c1 LOOP
      --
      --CR21179 Start Kacosta 06/21/2012
      IF (c1_rec.site_part2part_info <> c1_rec.esn2part_info) THEN
        --
        UPDATE table_site_part tsp
           SET tsp.site_part2part_info = c1_rec.esn2part_info
         WHERE tsp.objid = c1_rec.site_part_objid;
        --
        COMMIT;
        --
      END IF;
      --
      IF (c1_rec.carrier_objid IS NULL) THEN
        --
        IF call_trans_igt_info_curs%ISOPEN THEN
          --
          CLOSE call_trans_igt_info_curs;
          --
        END IF;
        --
        OPEN call_trans_igt_info_curs(c_n_site_part_objid => c1_rec.site_part_objid);
        FETCH call_trans_igt_info_curs
          INTO call_trans_igt_info_rec;
        CLOSE call_trans_igt_info_curs;
        --
        IF (call_trans_igt_info_rec.igt_carrier_objid IS NULL) THEN
          --
          IF call_trans_igth_info_curs%ISOPEN THEN
            --
            CLOSE call_trans_igth_info_curs;
            --
          END IF;
          --
          OPEN call_trans_igth_info_curs(c_n_site_part_objid => c1_rec.site_part_objid);
          FETCH call_trans_igth_info_curs
            INTO call_trans_igth_info_rec;
          CLOSE call_trans_igth_info_curs;
          --
          IF (call_trans_igth_info_rec.igh_carrier_objid IS NULL) THEN
            --
            toss_util_pkg.insert_error_tab_proc(ip_action       => 'Get IG_TRANSACTIONS carrier id'
                                               ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                               ,ip_program_name => 'SERVICE_DEACTIVATION_CODE.DEACTIVATE_PAST_DUE'
                                               ,ip_error_text   => 'Unable to find IG_TRANSACTIONS carrier id');
            --
            GOTO skip_this_deactivation;
            --
          END IF;
          --
          call_trans_igt_info_rec.igt_carrier_id    := call_trans_igth_info_rec.igh_carrier_id;
          call_trans_igt_info_rec.igt_carrier_objid := call_trans_igth_info_rec.igh_carrier_objid;
          --
        END IF;
        --
        c1_rec.x_carrier_id  := call_trans_igt_info_rec.igt_carrier_id;
        c1_rec.carrier_objid := call_trans_igt_info_rec.igt_carrier_objid;
        --
        UPDATE table_part_inst
           SET part_inst2carrier_mkt = c1_rec.carrier_objid
         WHERE part_serial_no = c1_rec.x_min;
        --
        COMMIT;
        --
      END IF;
      --
      IF excluded_pastduedeact_curs%ISOPEN THEN
        --
        CLOSE excluded_pastduedeact_curs;
        --
      END IF;
      --
      OPEN excluded_pastduedeact_curs(c_n_carrier_id => c1_rec.x_carrier_id);
      FETCH excluded_pastduedeact_curs
        INTO excluded_pastduedeact_rec;
      CLOSE excluded_pastduedeact_curs;
      --
      IF (excluded_pastduedeact_rec.excluded_pastduedeact IS NOT NULL) THEN
        --
        BEGIN
          --
          toss_util_pkg.insert_error_tab_proc(ip_action       => 'Check if carrier is an excluded pastduedeact carrier'
                                             ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                             ,ip_program_name => 'SERVICE_DEACTIVATION_CODE.DEACTIVATE_PAST_DUE'
                                             ,ip_error_text   => 'Carrier is an excluded pastduedeact carrier');
          --
        EXCEPTION
          WHEN others THEN
            --
            NULL;
            --
        END;
        --
        GOTO skip_this_deactivation;
        --
      END IF;
      --CR21179 End Kacosta 06/21/2012
      --
      dbms_output.put_line('c1_rec.x_service_id:' || c1_rec.x_service_id);
      OPEN past_due_batch_check_curs(c1_rec.site_part_objid);
      FETCH past_due_batch_check_curs
        INTO past_due_batch_check_rec;
      IF past_due_batch_check_curs%NOTFOUND THEN
        dbms_output.put_line('past_due_batch_check_curs%notfound');
        CLOSE past_due_batch_check_curs;
        COMMIT;
        --
        --CR21179 Start Kacosta 06/21/2012
        BEGIN
          --
          toss_util_pkg.insert_error_tab_proc(ip_action       => 'Check past due batch'
                                             ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                             ,ip_program_name => 'SERVICE_DEACTIVATION_CODE.DEACTIVATE_PAST_DUE'
                                             ,ip_error_text   => 'Past due batch check not found');
          --
        EXCEPTION
          WHEN others THEN
            --
            NULL;
            --
        END;
        --CR21179 End Kacosta 06/21/2012
        --
        GOTO skip_this_deactivation;
      END IF;
      CLOSE past_due_batch_check_curs;

      OPEN check_active_min_curs(c1_rec.x_min);
      FETCH check_active_min_curs
        INTO check_active_min_rec;
      IF check_active_min_curs%FOUND THEN
        UPDATE table_site_part
           SET part_status = 'Inactive'
         WHERE objid = c1_rec.site_part_objid;
        dbms_output.put_line('check_active_min_curs%found');
        OPEN check_esn_curs(c1_rec.x_service_id);
        FETCH check_esn_curs
          INTO check_esn_rec;
        IF check_esn_curs%NOTFOUND THEN
          dbms_output.put_line('check_esn_curs%found');
          UPDATE table_part_inst
             SET x_part_inst_status  = '54'
                ,status2x_code_table = 990
           WHERE part_serial_no = c1_rec.x_service_id;
        END IF;
        CLOSE check_esn_curs;
        CLOSE check_active_min_curs;
        COMMIT;
        GOTO skip_this_deactivation;
      END IF;
      CLOSE check_active_min_curs;

      IF (c1_rec.x_service_id IS NULL) THEN
        UPDATE table_site_part
           SET x_service_id = NVL(c1_rec.x_esn
                                 ,c1_rec.part_serial_no)
         WHERE objid = c1_rec.site_part_objid;
        COMMIT;
      END IF;

      sa.service_deactivation_code.check_dpp_registered_prc(c1_rec.x_service_id
                                                           ,dpp_regflag);
      IF dpp_regflag = 1 THEN
        --CR21179 Start Kacosta 06/21/2012
        BEGIN
          --
          toss_util_pkg.insert_error_tab_proc(ip_action       => 'Calling service_deactivation_code.check_dpp_registered_prc'
                                             ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                             ,ip_program_name => 'SERVICE_DEACTIVATION_CODE.DEACTIVATE_PAST_DUE'
                                             ,ip_error_text   => 'service_deactivation_code.check_dpp_registered_prc prevents ESN to be deactivated');
          --
        EXCEPTION
          WHEN others THEN
            --
            NULL;
            --
        END;
        --CR21179 End Kacosta 06/21/2012
        --
        service_deactivation_code.create_call_trans(c1_rec.site_part_objid
                                                   ,84
                                                   ,c1_rec.carrier_objid
                                                   ,c1_rec.site_objid
                                                   ,v_user
                                                   ,c1_rec.x_min
                                                   ,c1_rec.x_service_id
                                                   ,'PROTECTION PLAN BATCH'
                                                   ,SYSDATE
                                                   ,NULL
                                                   ,'Monthly Payments'
                                                   ,'PASTDUE'
                                                   ,'Pending'
                                                   ,c1_rec.x_iccid
                                                   ,c1_rec.org_id
                                                   ,intcalltranobj);
      ELSE
        IF (billing_deactprotect(c1_rec.x_service_id) = 1) THEN
          NULL;
          --CR21179 Start Kacosta 06/21/2012
          BEGIN
            --
            toss_util_pkg.insert_error_tab_proc(ip_action       => 'Calling billing_deactprotect'
                                               ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                               ,ip_program_name => 'SERVICE_DEACTIVATION_CODE.DEACTIVATE_PAST_DUE'
                                               ,ip_error_text   => 'billing_deactprotect prevents ESN to be deactivated');
            --
          EXCEPTION
            WHEN others THEN
              --
              NULL;
              --
          END;
          --CR21179 End Kacosta 06/21/2012
          --
        ELSE
          deactservice('PAST_DUE_BATCH'
                      ,v_user
                      ,c1_rec.x_service_id
                      ,c1_rec.x_min
                      ,'PASTDUE'
                      ,0
                      ,NULL
                      ,'true'
                      ,v_returnflag
                      ,v_returnmsg);
        END IF;
      END IF;

      FOR c2_rec IN (SELECT ROWID
                       FROM table_x_group2esn
                      WHERE groupesn2part_inst = c1_rec.esnobjid
                        AND groupesn2x_promo_group IN (SELECT objid
                                                         FROM table_x_promotion_group
                                                        WHERE group_name IN ('90_DAY_SERVICE'
                                                                            ,'52020_GRP'))) LOOP
        UPDATE table_x_group2esn u
           SET x_end_date = SYSDATE
         WHERE u.rowid = c2_rec.rowid;
        COMMIT;
      END LOOP;
      <<skip_this_deactivation>>
      COMMIT;
    END LOOP;

    v_end_1       := SYSDATE;
    v_time_used_1 := (v_end_1 - v_start_1) * 24 * 60;
    dbms_output.put_line('END_PROCEDURE call Total time used for esn: ' || v_time_used_1);
  END deactivate_past_due;

  /*****************************************************************************/
  /* */
  /* Name: deactivate_airtouch */
  /* Description : Available in the specification part of package */
  /*****************************************************************************/
  PROCEDURE deactivate_airtouch IS
    v_user         table_user.objid%TYPE;
    v_count        NUMBER := 1;
    v_deact_count  NUMBER;
    intcalltranobj NUMBER := 0;
    v_deact_reason VARCHAR2(20); --CR7233
    v_returnflag   VARCHAR2(20);
    v_returnmsg    VARCHAR2(200);
    CURSOR c1 IS
      SELECT sp.objid         site_part_objid
            ,sp.x_service_id  x_service_id
            ,sp.x_min         x_min
            ,ca.objid         carrier_objid
            ,ir.inv_role2site site_objid
            ,ca.x_carrier_id  x_carrier_id
            ,sp.site_objid    cust_site_objid
            ,sp.x_msid
            ,pi.x_iccid
        FROM table_x_carrier ca
            ,table_part_inst pi2
            ,table_inv_role  ir
            ,table_inv_bin   ib
            ,table_part_inst pi
            ,table_site_part sp
       WHERE ca.x_carrier_id IN (100002
                                ,110002
                                ,120002)
         AND pi2.part_inst2carrier_mkt = ca.objid
         AND pi2.x_domain = 'LINES'
         AND sp.x_min = pi2.part_serial_no
         AND ib.inv_bin2inv_locatn = ir.inv_role2inv_locatn
         AND pi.part_inst2inv_bin = ib.objid
         AND sp.objid = pi.x_part_inst2site_part
         AND sp.x_expire_dt BETWEEN TO_DATE('02-JAN-1753'
                                           ,'dd-mon-yyyy') AND (SYSDATE - 1)
         AND sp.part_status = 'Active'
       ORDER BY sp.x_expire_dt;
    --- CR7233 New deactivation reason - NONUSAGE
    CURSOR check_deact_reason(p_esn VARCHAR2) IS
      SELECT nu.x_deact_flag
        FROM x_nonusage_esns nu
       WHERE nu.x_esn = p_esn
         AND nu.x_deact_flag = 1;
    check_deact_reason_rec check_deact_reason%ROWTYPE;

    --- CR7233
  BEGIN
    SELECT COUNT(*) - 10199
      INTO v_deact_count
      FROM table_site_part sp
          ,table_part_inst pi
          ,table_x_carrier ca
     WHERE ca.x_carrier_id IN (100002
                              ,110002
                              ,120002)
       AND pi.part_inst2carrier_mkt = ca.objid
       AND pi.x_domain || '' = 'LINES'
       AND sp.x_min = pi.part_serial_no
       AND sp.part_status || '' = 'Active';
    dbms_output.put_line('deact_count: ' || TO_CHAR(v_deact_count));
    IF v_deact_count > 0 THEN
      SELECT objid
        INTO v_user
        FROM table_user
      --WHERE UPPER (login_name) = 'SA';--POST 10G
       WHERE s_login_name = 'SA';
      FOR c1_rec IN c1 LOOP

        ---CR7233-------check_deact_reason----------
        OPEN check_deact_reason(c1_rec.x_service_id);
        FETCH check_deact_reason
          INTO check_deact_reason_rec;
        IF check_deact_reason%FOUND THEN
          v_deact_reason := 'NONUSAGE';
        ELSE
          v_deact_reason := 'PASTDUE';
        END IF;
        CLOSE check_deact_reason;
        ---CR7233---------------------------------
        --CR3153 T-Mobile changes
        --CR7233 Instead of passing deact reason 'PASTDUE', deact reason is passed from variable v_deact_reason.
        deactservice('PAST_DUE_BATCH'
                    ,v_user
                    ,c1_rec.x_service_id
                    ,c1_rec.x_min
                    ,v_deact_reason
                    ,0
                    ,NULL
                    ,'true'
                    ,v_returnflag
                    ,v_returnmsg);
        v_count := v_count + 1;
        IF v_count = v_deact_count THEN
          EXIT;
        END IF;
      END LOOP;
    END IF;
  END deactivate_airtouch;
  /*****************************************************************************/
  /* */
  /* Name: deact_road_past_due */
  /* Description : Available in the specification part of package */
  /*****************************************************************************/
  --VAdapa on 02/13/02 to deactivate expired ROADSIDE cards
  PROCEDURE deact_road_past_due IS
    CURSOR c_site_part IS
      SELECT sp.objid        site_part_objid
            ,sp.x_service_id x_service_id
            ,x_iccid
        FROM table_site_part sp
       WHERE sp.x_expire_dt BETWEEN TO_DATE('02-JAN-1753'
                                           ,'dd-mon-yyyy') AND (SYSDATE - 1)
         AND instance_name = 'ROADSIDE'
         AND sp.part_status || '' = 'Active'
         AND ROWNUM < 1001;
    CURSOR c_road_inst(c_ip_ser_id IN VARCHAR2) IS
      SELECT *
        FROM table_x_road_inst
       WHERE x_red_code = c_ip_ser_id;
    --- CR7233 New deactivation reason - NONUSAGE
    CURSOR check_deact_reason(p_esn VARCHAR2) IS
      SELECT nu.x_deact_flag
        FROM x_nonusage_esns nu
       WHERE nu.x_esn = p_esn
         AND nu.x_deact_flag = 1;
    --- CR7233
    check_deact_reason_rec check_deact_reason%ROWTYPE;
    r_road_inst            c_road_inst%ROWTYPE;
    v_user                 table_user.objid%TYPE;
    v_action               VARCHAR2(4000);
    v_service_id           VARCHAR2(20);
    v_road_hist_seq        NUMBER; -- 06/09/03
    intcalltranobj         NUMBER := 0;
    v_deact_reason         VARCHAR2(20);
    --CR7233
  BEGIN
    SELECT objid
      INTO v_user
      FROM table_user
    --WHERE UPPER (login_name) = 'SA';--POST 10G
     WHERE s_login_name = 'SA';
    FOR r_site_part IN c_site_part LOOP
      BEGIN

        ---CR7233-------check_deact_reason----------
        OPEN check_deact_reason(r_site_part.x_service_id);
        FETCH check_deact_reason
          INTO check_deact_reason_rec;
        IF check_deact_reason%FOUND THEN
          v_deact_reason := 'NONUSAGE';
        ELSE
          v_deact_reason := 'PASTDUE';
        END IF;
        CLOSE check_deact_reason;
        ---CR7233---------------------------------
        v_service_id := r_site_part.x_service_id;
        v_action     := 'UPDATE TABLE_X_ROAD_HIST';
        UPDATE table_x_road_inst
           SET x_part_inst_status     = '47'
              ,rd_status2x_code_table = 2144
              ,x_hist_update          = 1
         WHERE x_red_code = r_site_part.x_service_id;
        OPEN c_road_inst(r_site_part.x_service_id);
        FETCH c_road_inst
          INTO r_road_inst;
        CLOSE c_road_inst;
        v_action := 'INSERT INTO TABLE_X_ROAD_HIST';
        --Sp_Seq ('x_road_hist', v_road_hist_seq); -- 06/09/03
        SELECT sequ_x_road_hist.nextval
          INTO v_road_hist_seq
          FROM dual; -- CR12136
        INSERT INTO table_x_road_hist
          (objid
          ,x_part_serial_no
          ,x_part_mod
          ,x_part_bin
          ,x_warr_end_date
          ,x_part_status
          ,x_insert_date
          ,x_creation_date
          ,x_po_num
          ,x_domain
          ,x_part_inst_status
          ,x_change_date
          ,x_change_reason
          ,x_last_trans_time
          ,x_transaction_id
          ,x_repair_date
          ,x_pick_request
          ,x_order_number
          ,x_road_hist2inv_bin
          ,x_road_hist2part_mod
          ,x_road_hist2road_inst
          ,x_road_hist2user
          ,road_hist2x_code_table
          ,x_road_hist2site_part)
        VALUES
          (
           -- 04/10/03 seq_x_road_hist.nextval + POWER (2, 28),
           -- seq('x_road_hist'),
           v_road_hist_seq
          ,r_road_inst.part_serial_no
          ,r_road_inst.part_mod
          ,r_road_inst.part_bin
          ,r_road_inst.warr_end_date
          ,r_road_inst.part_status
          ,r_road_inst.x_insert_date
          ,r_road_inst.x_creation_date
          ,r_road_inst.x_po_num
          ,r_road_inst.x_domain
          ,'47'
          ,SYSDATE
          ,v_deact_reason
          , --CR7233:previously PASTDUE was inserted directly. Now, either of PASTDUE or NONUSAGE will be passesd into v_deact_reason
           SYSDATE
          ,r_road_inst.transaction_id
          ,r_road_inst.repair_date
          ,NULL
          ,r_road_inst.x_order_number
          ,r_road_inst.road_inst2inv_bin
          ,r_road_inst.n_road_inst2part_mod
          ,r_road_inst.objid
          ,r_road_inst.rd_create2user
          ,2144
          ,r_road_inst.x_road_inst2site_part);
        v_action := 'INSERT INTO TABLE_X_CALL_TRANS';
        --CR7233 Instead of passing deact reason 'PASTDUE', deact reason is passed from variable v_deact_reason.
        create_call_trans(r_site_part.site_part_objid
                         ,11
                         ,NULL
                         , -- carrier objid
                          NULL
                         , -- dealer objid
                          v_user
                         ,NULL
                         , -- MIN value
                          r_site_part.x_service_id
                         ,'ROAD_PASTDUE_BATCH'
                         ,SYSDATE
                         ,NULL
                         ,'Cancellation'
                         ,v_deact_reason
                         ,'Completed'
                         ,r_site_part.x_iccid
                         ,'GENERIC'
                         ,intcalltranobj);
        v_action := 'UPDATE TABLE_SITE_PART';

        UPDATE table_site_part
           SET part_status    = 'Inactive'
              ,service_end_dt = SYSDATE
              ,x_deact_reason = v_deact_reason
         WHERE objid = r_site_part.site_part_objid;

        COMMIT;
      EXCEPTION
        WHEN others THEN
          toss_util_pkg.insert_error_tab_proc('Inner BLOCK : ' || v_action
                                             ,v_service_id
                                             ,'ROAD_PASTDUE');
      END;
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN others THEN
      toss_util_pkg.insert_error_tab_proc(v_action
                                         ,NULL
                                         ,'ROAD_PASTDUE');
  END deact_road_past_due;
  /*****************************************************************************/
  /* */
  /* Name: deactivate_any */
  /* Description : Available in the specification part of package */
  /*****************************************************************************/
  PROCEDURE deactivate_any
  (
    ip_esn            IN VARCHAR2
   ,ip_reason         IN VARCHAR2
   ,ip_caller_program IN VARCHAR2
   ,ip_result         IN OUT PLS_INTEGER
  ) AS
    v_user           table_user.objid%TYPE;
    v_procedure_name VARCHAR2(80) := v_package_name || '.DEACTIVATE_ANY()';
    v_action         VARCHAR2(4000);
    v_service_id     VARCHAR2(20);
    intcalltranobj   NUMBER := 0;
    v_returnflag     VARCHAR2(20);
    v_returnmsg      VARCHAR2(200);
    --CR#4479 - Billing Platform change request ----start
    op_result NUMBER;
    op_msg    VARCHAR2(200);
    --CR#4479 - Billing Platform change request ----end
    CURSOR c1 IS
      SELECT sp.objid site_part_objid
            ,sp.x_service_id x_service_id
            ,sp.x_min x_min
            ,ca.objid carrier_objid
            ,ir.inv_role2site site_objid
            ,sp.serial_no x_esn
            ,ca.x_carrier_id x_carrier_id
            ,sp.site_objid cust_site_objid
            ,pi.objid esnobjid
            ,sp.x_msid
            ,NVL(pi2.x_port_in
                ,0) x_port_in
            , --CR12338
             pi.x_iccid
        FROM table_x_carrier ca
            ,table_part_inst pi2
            ,table_inv_role  ir
            ,table_inv_bin   ib
            ,table_part_inst pi
            ,table_site_part sp
       WHERE ca.objid = pi2.part_inst2carrier_mkt
         AND pi2.x_domain = 'LINES' -->CR3318 Removed initcap func
         AND pi2.part_serial_no = sp.x_min
         AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
         AND ib.objid = pi.part_inst2inv_bin
         AND pi.x_part_inst2site_part = sp.objid
         AND (sp.part_status) = 'Active'
         AND sp.x_service_id = ip_esn;
    -- BRAND_SEP
    CURSOR brand_name_cur(ip_esn IN VARCHAR2) IS
      SELECT org_id
        FROM table_part_inst pi
            ,table_mod_level ml
            ,table_part_num  pn
            ,table_bus_org   bo
       WHERE pi.part_serial_no = ip_esn
         AND pi.x_domain = 'PHONES'
         AND pi.n_part_inst2part_mod = ml.objid
         AND ml.part_info2part_num = pn.objid
         AND pn.part_num2bus_org = bo.objid;

    brand_name_rec brand_name_cur%ROWTYPE;

    v_brand_name VARCHAR2(30);
  BEGIN
    SELECT objid
      INTO v_user
      FROM table_user
    --WHERE UPPER (login_name) = 'SA';--POST 10G
     WHERE s_login_name = 'SA';
    BEGIN
      FOR c1_rec IN c1 LOOP
        -----------------------------------------------------------------------------------------
        --new code for refurb phone for ported phone numbers
        -----------------------------------------------------------------------------------------
        dbms_output.put_line('c1_rec.x_port_in:' || c1_rec.x_port_in);
        -- CR5353
        -- IF c1_rec.x_port_in = 1
        IF c1_rec.x_port_in = 1
          --CR18244 Start kacosta 10/06/2011
           AND ip_caller_program NOT LIKE '%POSA_PKG.MAKE_PHONE_RETURNED().RESET_ESN_FUN()%'
          --CR18244 End kacosta 10/06/2011
           AND ip_caller_program NOT LIKE '%MANUAL REFURB.RESET_ESN_FUN()%'
           AND ip_caller_program NOT LIKE '%SP_CLARIFY_REFURB_PRC()%' THEN
          OPEN brand_name_cur(c1_rec.x_service_id);
          FETCH brand_name_cur
            INTO brand_name_rec;
          IF brand_name_cur%FOUND THEN
            v_brand_name := brand_name_rec.org_id;
          ELSE
            v_brand_name := 'GENERIC';
          END IF;
          CLOSE brand_name_cur;
          dbms_output.put_line('inside c1_rec.x_port_in:start');
          create_call_trans(c1_rec.site_part_objid
                           ,20
                           ,c1_rec.carrier_objid
                           ,c1_rec.site_objid
                           ,v_user
                           ,c1_rec.x_min
                           ,c1_rec.x_service_id
                           ,ip_reason
                           ,SYSDATE
                           ,NULL
                           ,'PORTED DEACT PENDING'
                           ,ip_reason
                           ,'Completed'
                           ,c1_rec.x_iccid
                           ,v_brand_name
                           ,intcalltranobj);
          ip_result := 0;
          toss_util_pkg.insert_error_tab_proc('X_PORT_IN = 1'
                                             ,c1_rec.x_service_id
                                             ,v_procedure_name);
          dbms_output.put_line('inside c1_rec.x_port_in:exit');
          EXIT;
        END IF;
        -----------------------------------------------------------------------------------------
        v_service_id := c1_rec.x_service_id;
        v_action     := 'Deactivating service';
        --CR3153 T-Mobile changes
        deactservice(UPPER(ip_reason)
                    ,v_user
                    ,c1_rec.x_service_id
                    ,c1_rec.x_min
                    ,UPPER(ip_reason)
                    ,0
                    ,NULL
                    ,'true'
                    ,v_returnflag
                    ,v_returnmsg);
        --------------------------------------------------------------------------------------------------
        --CR#4479 - Billing Platform change request ----start
        -- Billing rules engine call for any deactivation
        billing_deact_rule_engine(ip_esn
                                 ,ip_reason
                                 ,v_user
                                 ,op_result
                                 ,op_msg);
        --CR#4479 - Billing Platform change request ----end
        --------------------------------------------------------------------------------------------------
        ip_result := 1;
      END LOOP;
    EXCEPTION
      WHEN others THEN

        /** FAILURE POINT **/
        ip_result := 0;
        toss_util_pkg.insert_error_tab_proc('Inner BLOCK : ' || v_action
                                           ,v_service_id
                                           ,v_procedure_name);
    END; -- of inner block (for loop block)
  EXCEPTION
    WHEN others THEN

      /** FAILURE POINT **/
      ip_result := 0;
      toss_util_pkg.insert_error_tab_proc(v_action
                                         ,NVL(v_service_id
                                             ,'N/A')
                                         ,v_procedure_name);
  END deactivate_any;
  /***********************************************************************************/
  /*
  /* Name: deactService
  /* Description: Ends carrier service for an ESN/MIN combination. Translated
  /* from TFLinePart.java in the DeactivateService and
  /* DeactivateGSMService method.
  /***********************************************************************************/
  -- BRAND_SEP
  PROCEDURE deactservice
  (
    ip_sourcesystem    IN VARCHAR2
   ,ip_userobjid       IN VARCHAR2
   ,ip_esn             IN VARCHAR2
   ,ip_min             IN VARCHAR2
   ,ip_deactreason     IN VARCHAR2
   ,intbypassordertype IN NUMBER
   ,ip_newesn          IN VARCHAR2
   ,ip_samemin         IN VARCHAR2
   ,op_return          OUT VARCHAR2
   ,op_returnmsg       OUT VARCHAR2
  ) IS
    CURSOR cur_ph IS
      SELECT a.*
            ,a.rowid esn_rowid
            ,(SELECT ct.x_iccid
                FROM table_x_call_trans ct
               WHERE ct.call_trans2site_part = f.objid
                 AND ct.x_iccid IS NOT NULL
                 AND ROWNUM < 2) ct_iccid
            ,(SELECT cr.contact_role2contact
                FROM table_site_part    sp
                    ,table_site         s
                    ,table_contact_role cr
               WHERE 1 = 1
                 AND sp.x_min = ip_min
                 AND s.objid = sp.site_part2site
                 AND cr.contact_role2site = s.objid
                 AND cr.contact_role2contact IS NOT NULL
                 AND ROWNUM < 2) alt_contact
            ,c.x_technology
            ,NVL(c.x_restricted_use
                ,0) x_restricted_use
            ,e.objid siteobjid
            ,f.x_iccid sp_iccid
            ,f.service_end_dt
            ,f.x_expire_dt
            ,f.x_deact_reason
            ,f.part_status f_part_status
            ,f.x_notify_carrier
            ,f.objid sitepartobjid
            ,f.x_service_id
            ,f.x_min
            ,f.install_date
            ,f.site_part2x_new_plan
            ,f.site_part2x_plan
            ,f.rowid site_part_rowid
            ,bo.org_id
            ,(SELECT COUNT(*)
                FROM x_program_enrolled c
               WHERE 1 = 1
                 AND c.x_esn = ip_esn
                 AND c.x_enrollment_status IN ('ENROLLED'
                                              ,'SUSPENDED'
                                              ,'ENROLLMENTPENDING'
                                              ,'ENROLLMENTSCHEDULED')
                 AND ROWNUM < 2) billing_rule_status
        FROM table_part_inst a
            ,table_mod_level b
            ,table_part_num  c
            ,table_bus_org   bo
            ,table_inv_bin   d
            ,table_site      e
            ,table_site_part f
       WHERE 1 = 1
         AND f.objid = (SELECT MAX(sp.objid)
                          FROM table_site_part sp
                         WHERE sp.part_status != 'Obsolete'
                           AND sp.x_service_id = a.part_serial_no
                           AND sp.x_min = ip_min)
         AND d.bin_name = e.site_id
         AND a.part_inst2inv_bin = d.objid
         AND c.part_num2bus_org = bo.objid
         AND b.part_info2part_num = c.objid
         AND a.n_part_inst2part_mod = b.objid
         AND a.part_serial_no = ip_esn
         AND a.x_domain = 'PHONES';
    rec_ph cur_ph%ROWTYPE;
    -------------------------------------------------------
    CURSOR cur_newesn IS
      SELECT objid
        FROM table_part_inst
       WHERE part_serial_no = LTRIM(RTRIM(ip_newesn));
    rec_newesn cur_newesn%ROWTYPE;
    -------------------------------------------------------
    CURSOR cur_min
    (
      ip_min IN VARCHAR2
     ,c_tech IN VARCHAR2
    ) IS
      SELECT pi.objid
            ,pi.part_serial_no
            ,pi.part_inst2carrier_mkt
            ,NVL(pi.x_port_in
                ,0) x_port_in
            ,pi.x_part_inst_status
            ,pi.x_npa
            ,pi.x_nxx
            ,pi.x_ext
            ,pi.rowid min_rowid
            ,pi.status2x_code_table
            ,pi.x_cool_end_date
            ,pi.warr_end_date
            ,pi.last_trans_time
            ,pi.repair_date
            ,pi.part_inst2x_pers
            ,pi.part_inst2x_new_pers
            ,pi.part_to_esn2part_inst
            ,pi.last_cycle_ct
            ,p.x_parent_id
            ,cr.x_line_return_days
            ,cr.x_cooling_period
            ,cr.x_used_line_expire_days
            ,cr.x_gsm_grace_period
            ,cr.x_reserve_on_suspend
            ,cr.x_reserve_period
            ,cr.x_deac_after_grace
            ,
             --cwl 2/10/2011 CR15335
             cr.x_cancel_suspend_days
            ,cr.x_cancel_suspend
            ,
             --cwl 2/10/2011 CR15335
             (SELECT COUNT(*)
                FROM table_x_block_deact
               WHERE x_block_active = 1
                 AND x_parent_id = p.x_parent_id
                 AND UPPER(x_code_name) = UPPER(ip_deactreason)
                 AND ROWNUM < 2) block_deact_exists
        FROM table_x_parent        p
            ,table_x_carrier_group cg
            ,table_x_carrier_rules cr
            ,table_x_carrier       c
            ,table_part_inst       pi
       WHERE 1 = 1
         AND p.objid = cg.x_carrier_group2x_parent
         AND cg.objid = c.carrier2carrier_group
         AND cr.objid = DECODE(c_tech
                              ,'GSM'
                              ,c.carrier2rules_gsm
                              ,'CDMA'
                              ,c.carrier2rules_cdma
                              ,c.carrier2rules)
         AND c.objid = pi.part_inst2carrier_mkt
         AND pi.part_serial_no = ip_min
         AND pi.x_domain = 'LINES';
    rec_min cur_min%ROWTYPE;
    -------------------------------------------------------
    CURSOR curremovepromo(c_esnobjid IN NUMBER) IS
      SELECT /*+ INDEX(pg X_PROMOTION_GROUP_OBJINDEX) */
       g2e.*
        FROM table_x_promotion_group pg
            ,table_x_group2esn       g2e
       WHERE 1 = 1
         AND pg.objid = g2e.groupesn2x_promo_group + 0
         AND pg.group_name IN ('TFU'
                              ,'ANNUALPLAN')
         AND g2e.groupesn2part_inst = c_esnobjid;
    -------------------------------------------------------
    CURSOR currdeactcode
    (
      c_deactreason IN VARCHAR2
     ,c_deacttype   IN VARCHAR2
    ) IS
      SELECT *
        FROM table_x_code_table
       WHERE x_code_name = c_deactreason
         AND x_code_type = c_deacttype;
    recdeactcode currdeactcode%ROWTYPE;
    recdeactsim  currdeactcode%ROWTYPE;
    -------------------------------------------------------
    CURSOR currstatcode
    (
      c_statcode IN VARCHAR2
     ,c_codetype IN VARCHAR2
    ) IS
      SELECT *
        FROM table_x_code_table
       WHERE x_code_number = c_statcode
         AND x_code_type = c_codetype;
    recphstatcode   currstatcode%ROWTYPE;
    reclinestatcode currstatcode%ROWTYPE;
    -------------------------------------------------------

    CURSOR c_ota_features(c_ip_esn_objid IN NUMBER) IS
      SELECT 'X'
        FROM table_x_ota_features
       WHERE x_ota_features2part_inst = c_ip_esn_objid
         AND x_ild_carr_status = 'Active'
         AND ROWNUM < 2;
    -------------------------------------------------------
    intcalltranobj  NUMBER := 0;
    intstatcode     NUMBER := 0;
    intactitemobj   NUMBER := 0;
    intordtypeobj   NUMBER := 0;
    intblackoutcode NUMBER := 0;
    intdummy        NUMBER := 0;
    inttransmethod  NUMBER := 0;
    intgrphistseq   NUMBER := 0;
    strdeacttype    VARCHAR2(30) := '';
    strrettemp      VARCHAR2(200) := '';
    strsqlerrm      VARCHAR2(200);
    v_action        VARCHAR2(4000);
    e_deact_exception EXCEPTION;
    v_procedure_name VARCHAR2(80) := v_package_name || '.DEACTSERVICE()';

    TYPE ac_change IS TABLE OF table_part_inst.objid%TYPE;
    TYPE ac_change_rowid IS TABLE OF VARCHAR2(200);
    v_ac_change       ac_change;
    v_ac_change_rowid ac_change_rowid;
    TYPE call_trans IS TABLE OF table_x_ota_transaction.x_ota_trans2x_call_trans%TYPE;
    v_call_trans call_trans;

    strilderrnum VARCHAR2(20);
    strilderrstr VARCHAR2(200);

    op_result NUMBER;
    op_msg    VARCHAR2(200);

    l_step NUMBER := 0;
  BEGIN
    IF LTRIM(ip_esn) IS NULL THEN
      op_return    := 'true';
      op_returnmsg := 'ESN is null';
      UPDATE table_part_inst
         SET x_part_inst_status  = '17'
            ,status2x_code_table =
             (SELECT objid
                FROM table_x_code_table
               WHERE x_code_number = '17')
       WHERE part_serial_no = ip_min;
      COMMIT;
      RETURN;
    ELSE
      OPEN cur_ph;
      FETCH cur_ph
        INTO rec_ph;
      IF cur_ph%NOTFOUND THEN
        CLOSE cur_ph;
        op_returnmsg := 'ESN/IMEI is not Valid';
        RAISE e_deact_exception;
      END IF;
      CLOSE cur_ph;
    END IF;

    OPEN cur_min(ip_min
                ,rec_ph.x_technology);
    FETCH cur_min
      INTO rec_min;
    IF cur_min%NOTFOUND THEN
      CLOSE cur_min;
      op_returnmsg := 'MIN is not Valid';
      RAISE e_deact_exception;
    END IF;
    CLOSE cur_min;
    IF LTRIM(ip_newesn) IS NOT NULL THEN
      OPEN cur_newesn;
      FETCH cur_newesn
        INTO rec_newesn;

      IF cur_newesn%FOUND THEN
        v_action := 'Clearing all the reserved lines except the one that is being deactivated';
        dbms_output.put_line('Clearing all the reserved lines except the one that is being deactivated');
        UPDATE table_part_inst
           SET part_to_esn2part_inst = NULL
         WHERE part_to_esn2part_inst = rec_newesn.objid
           AND x_domain || '' = 'LINES'
              --cwl 3/2/2011 what about line status '73'
              --and x_part_inst_status != '73'
           AND objid != rec_min.objid;
      END IF;
      CLOSE cur_newesn;
    END IF;

    IF (SUBSTR(rec_min.part_serial_no
              ,1
              ,1) = 'T') THEN
      OPEN currdeactcode('DELETED'
                        ,'LS');
    ELSIF (rec_min.x_part_inst_status = '34') THEN

      v_action := 'Updating account_hist of current line';
      UPDATE table_x_account_hist
         SET x_end_date = SYSDATE
       WHERE account_hist2part_inst = rec_min.objid
         AND (x_end_date IS NULL OR x_end_date = TRUNC(TO_DATE('01/01/1753'
                                                              ,'MM/DD/YYYY')));
      OPEN currdeactcode('AC VOIDED'
                        ,'LS');
      --CR18244 Start Kacosta 11/28/2011
    ELSIF UPPER(ip_deactreason) = 'SENDCARRDEACT'
          AND rec_ph.x_deact_reason = 'REFURBISHED'
          AND rec_min.x_port_in IN (1
                                   ,2
                                   ,3)
          AND rec_min.x_part_inst_status = '39'
          AND rec_min.part_to_esn2part_inst IS NULL THEN
      OPEN currdeactcode('RETURNED'
                        ,'LS');
      --CR18244 End Kacosta 11/28/2011
    ELSE
      OPEN currdeactcode((CASE WHEN UPPER(ip_deactreason) IN ('CANCELFROMSUSPEND'
                                                             ,'CLONED'
                                                             ,'CUSTOMER REQD'
                                                             ,'CUSTOMER REQUESTED'
                                                             ,'DEFECTIVE'
                                                             ,'NO NEED OF PHONE'
                                                             ,'NONUSAGE'
                                                             ,'ONE TIME DEACT'
                                                             ,'PASTDUE'
                                                             ,'PORT IN TO NET10'
                                                             ,'PORT IN TO TRACFONE'
                                                             ,'RISK ASSESSMENT'
                                                             ,'SALE OF CELL PHONE'
                                                             ,'SELL PHONE'
                                                             ,'SEQUENCE MISMATCH'
                                                             ,'SIM CHANGE'
                                                             ,'SIM DAMAGE'
                                                             ,'SIM DAMAGED'
                                                             ,'SIM EXCHANGE'
                                                             ,'SL PHONE NEVER RCVD'
                                                             ,'STOLEN'
                                                             ,'STOLEN CREDIT CARD'
                                                             ,'UNITS TRANSFER'
                                                             ,'UPGRADE'
                                                             ,'WAREHOUSE PHONE'
                                                             ,'UNITS TRANSFER') THEN 'RESERVED USED' WHEN UPPER(ip_deactreason) IN ('ACTIVE UPGRADE'
                                                                                                                                   ,'CHANGE OF ADDRESS'
                                                                                                                                   ,'MINCHANGE'
                                                                                                                                   ,'NTN'
                                                                                                                                   ,'OVERDUE EXCHANGE'
                                                                                                                                   ,'PORT CANCEL'
                                                                                                                                   ,'PORTED NO A/I'
                                                                                                                                    --CR18244 Start kacosta 10/06/2011
                                                                                                                                    --,'REFURBISHED'
                                                                                                                                    --CR18244 End kacosta 10/06/2011
                                                                                                                                   ,'SENDCARRDEACT'
                                                                                                                                   ,'WN-SYSTEM ISSUED') THEN CASE WHEN rec_min.x_line_return_days = 0 THEN 'USED' ELSE 'RETURNED' END WHEN UPPER(ip_deactreason) IN ('PORT OUT'
                                                                                                                                                                                                                                                                    ,'ST SIM EXCHANGE') THEN 'RETURNED' WHEN UPPER(ip_deactreason) IN ('NON TO PP LINE') THEN 'NTN'
                         --CR18244 Start kacosta 10/06/2011
                          WHEN UPPER(ip_deactreason) = 'REFURBISHED' THEN CASE WHEN rec_min.x_port_in IN (1
                                                                                                         ,2
                                                                                                         ,3) THEN 'RESERVED USED' ELSE CASE WHEN rec_min.x_line_return_days = 0 THEN 'USED' ELSE 'RETURNED' END END
                         --CR18244 End kacosta 10/06/2011
                          ELSE 'RETURNED' END)
                        ,'LS');
    END IF;
    FETCH currdeactcode
      INTO recdeactcode;
    CLOSE currdeactcode;

    dbms_output.put_line('recdeactcode.x_code_number:' || recdeactcode.x_code_number);

    v_action := 'Updating part_inst of current line';
    dbms_output.put_line('Updating part_inst of current line');

    UPDATE table_part_inst
       SET x_part_inst_status    = recdeactcode.x_code_number
          ,status2x_code_table   = recdeactcode.objid
          ,x_cool_end_date       = DECODE(rec_min.x_cooling_period
                                         ,0
                                         ,x_cool_end_date
                                         ,SYSDATE + rec_min.x_cooling_period)
          ,warr_end_date         = DECODE(rec_min.x_used_line_expire_days
                                         ,0
                                         ,TO_DATE('01/01/1753'
                                                 ,'mm/dd/yyyy')
                                         ,SYSDATE + rec_min.x_used_line_expire_days)
          ,last_trans_time       = SYSDATE
          ,repair_date           = DECODE((LTRIM(ip_newesn))
                                         ,NULL
                                         ,repair_date
                                         ,SYSDATE)
          ,part_inst2x_pers      = DECODE(part_inst2x_new_pers
                                         ,NULL
                                         ,part_inst2x_pers
                                         ,part_inst2x_new_pers)
          ,part_inst2x_new_pers  = NULL
          ,part_to_esn2part_inst = (CASE
                                     WHEN rec_newesn.objid IS NOT NULL THEN
                                      rec_newesn.objid
                                     WHEN recdeactcode.x_code_number = '39' THEN
                                      part_to_esn2part_inst
                                     ELSE
                                      NULL
                                   END)
           --DECODE((LTRIM(ip_newesn))
           -- ,NULL
           -- ,part_to_esn2part_inst
           -- ,rec_newesn.objid)
          ,last_cycle_ct = SYSDATE + rec_min.x_gsm_grace_period
          ,x_port_in     = DECODE(ip_samemin
                                 ,'true'
                                 ,rec_min.x_port_in
                                 ,(DECODE(rec_min.x_port_in
                                         ,2
                                         ,0
                                         ,rec_min.x_port_in)))
     WHERE ROWID = rec_min.min_rowid;
    dbms_output.put_line('write line hist');
    IF sa.service_deactivation_code.writepihistory(ip_userobjid
                                                  ,rec_min.min_rowid
                                                  ,NULL
                                                  ,NULL
                                                  ,NULL
                                                  ,'DEACTIVATE'
                                                  ,rec_ph.sp_iccid) = 1 THEN
      --,rec_ph.x_iccid) = 1 THEN
      NULL;
    END IF;

    --CR18244 Start Kacosta 11/28/2011
    IF UPPER(ip_deactreason) = 'SENDCARRDEACT'
       AND rec_ph.x_deact_reason = 'REFURBISHED'
       AND rec_min.x_port_in IN (1
                                ,2
                                ,3)
       AND rec_min.x_part_inst_status = '39'
       AND rec_min.part_to_esn2part_inst IS NULL THEN
      NULL;
    ELSE
      --CR18244 End Kacosta 11/28/2011
      v_action := 'Updating active min site_part to inactive';
      dbms_output.put_line('Updating active min site_part to inactive');
      UPDATE table_site_part
         SET service_end_dt       = SYSDATE
            ,x_expire_dt = CASE
                             WHEN UPPER(ip_deactreason) IN ('UPGRADE'
                                                           ,'ACTIVE UPGRADE'
                                                           ,'WAREHOUSE PHONE') THEN
                              SYSDATE
                             ELSE
                              x_expire_dt
                           END
            ,x_deact_reason       = ip_deactreason
            ,x_notify_carrier = CASE
                                  WHEN (rec_min.x_port_in IN (1
                                                             ,2) OR rec_min.x_line_return_days = 1) THEN
                                   1
                                  ELSE
                                   0
                                END
            ,part_status          = 'Inactive'
            ,site_part2x_new_plan = NULL
       WHERE x_min = rec_min.part_serial_no
         AND part_status || '' IN ('CarrierPending'
                                  ,'Active');
      --CR18244 Start Kacosta 11/28/2011
    END IF;
    --CR18244 End Kacosta 11/28/2011
    COMMIT;

    v_action := 'Creating a call trans record';
    dbms_output.put_line('Creating a call trans record');
    service_deactivation_code.create_call_trans(rec_ph.sitepartobjid
                                               ,2
                                               ,rec_min.part_inst2carrier_mkt
                                               ,rec_ph.siteobjid
                                               ,ip_userobjid
                                               ,rec_ph.x_min
                                               ,ip_esn
                                               ,ip_sourcesystem
                                               ,SYSDATE
                                               ,NULL
                                               ,'DEACTIVATION'
                                               ,ip_deactreason
                                               ,'Completed'
                                                --,rec_ph.x_iccid
                                               ,rec_ph.sp_iccid
                                               ,rec_ph.org_id
                                               ,intcalltranobj);

    IF recdeactcode.x_code_name IN ('RESERVED USED'
                                   ,'USED') THEN
      strdeacttype := 'Suspend';
    ELSIF recdeactcode.x_code_name IN ('RETURNED') THEN
      strdeacttype := 'Deactivation';
    ELSE
      strdeacttype := '';
    END IF;

    dbms_output.put_line('strdeacttype:' || strdeacttype);
    dbms_output.put_line('rec_min.block_deact_exists:' || rec_min.block_deact_exists);
    dbms_output.put_line('recdeactcode.x_code_name:' || recdeactcode.x_code_name);
    dbms_output.put_line('rec_min.LAST_CYCLE_CT:' || rec_min.last_cycle_ct);
    IF (rec_min.block_deact_exists = 0 AND recdeactcode.x_code_name IS NOT NULL
       --and rec_min.LAST_CYCLE_CT > trunc(sysdate) -30
       ) THEN
      v_action := 'Creating action_item';
      dbms_output.put_line('Creating action_item');
      --
      IF (rec_ph.x_part_inst2contact IS NULL)
         AND rec_ph.alt_contact IS NULL THEN
        op_returnmsg := 'Contact Information Can Not be Found';
        RAISE e_deact_exception;
      ELSIF (rec_ph.x_part_inst2contact IS NULL)
            AND rec_ph.alt_contact IS NOT NULL THEN
        rec_ph.x_part_inst2contact := rec_ph.alt_contact;
      END IF;
      --
      igate.sp_create_action_item(rec_ph.x_part_inst2contact
                                 ,intcalltranobj
                                 ,strdeacttype
                                 ,intbypassordertype
                                 ,0
                                 ,intstatcode
                                 ,intactitemobj);

dbms_output.put_line('intstatcode:'||intstatcode);

      IF (intstatcode = 2) THEN
        op_returnmsg := op_returnmsg || ' The Action Item Has Not Been Created. Please Contact The Line Management Data Adminstrator.';
      ELSIF (intstatcode = 4) THEN
        op_returnmsg := op_returnmsg || ' There is no transmission method set for this carrier.';
      END IF;

      IF (intactitemobj = 0) THEN
        op_returnmsg := 'No Lines Were Deactivated';
        RAISE e_deact_exception;
      END IF;

      igate.sp_get_ordertype(rec_min.part_serial_no
                            ,strdeacttype
                            ,rec_min.part_inst2carrier_mkt
                            ,rec_ph.x_technology
                            ,intordtypeobj);
      --cwl 2/10/2011 CR15335
      -- if suspend and x_cancel_suspend = 1 then insert into x_suspendtocancel table
      IF strdeacttype = 'Suspend'
         AND rec_min.x_cancel_suspend = 1 THEN
        INSERT INTO x_canceltosuspend
          (objid
          ,x_status
          ,x_min
          ,x_cancelto_suspend_date
          ,x_site_part_objid
          ,x_call_trans_objid
          ,x_processed_date)
        VALUES
          (sequ_x_canceltosuspend.nextval
          ,'PENDING'
          ,ip_min
          ,SYSDATE + rec_min.x_cancel_suspend_days
          ,rec_ph.sitepartobjid
          ,intcalltranobj
          ,NULL);
      END IF;
      --cwl 2/10/2011 CR15335
      igate.sp_check_blackout(intactitemobj
                             ,intordtypeobj
                             ,intblackoutcode);
dbms_output.put_line('intblackoutcode:'||intblackoutcode);
      IF (intblackoutcode = 0) THEN

        igate.sp_determine_trans_method(intactitemobj
                                       ,strdeacttype
                                       ,NULL
                                       ,inttransmethod);
dbms_output.put_line('inttransmethod:'||inttransmethod);
        IF (inttransmethod = 2) THEN
          op_returnmsg := op_returnmsg || ' The Action Item Has Not Been Created. Please Contact The Line Management Data Adminstrator. ';
        ELSIF (inttransmethod = 4) THEN
          op_returnmsg := op_returnmsg || ' There is no transmission method set for this carrier.';
        END IF;
      ELSIF (intblackoutcode = 1) THEN
        op_returnmsg := op_returnmsg || ' Currently in blackout.';
        igate.sp_dispatch_task(intactitemobj
                              ,'BlackOut'
                              ,intdummy);
      ELSIF (intblackoutcode = 2) THEN
        op_returnmsg := op_returnmsg || ' No task record found.';
      ELSIF (intblackoutcode = 3) THEN
        op_returnmsg := op_returnmsg || ' No x_call_trans record found.';
      ELSIF (intblackoutcode = 4) THEN
        op_returnmsg := op_returnmsg || ' No x_carrier record found.';
      ELSIF (intblackoutcode IN (5
                                ,6)) THEN
        igate.sp_dispatch_task(intactitemobj
                              ,'BlackOut'
                              ,intdummy);
      ELSIF (intblackoutcode = 7) THEN
        op_returnmsg := op_returnmsg || ' Unspecified error.';
      END IF;
    END IF;
dbms_output.put_line('op_returnmsg:'||op_returnmsg);
dbms_output.put_line('op_returnmsg:'||op_returnmsg);
    OPEN check_esn_curs(ip_esn);
    FETCH check_esn_curs
      INTO check_esn_rec;
    IF check_esn_curs%FOUND THEN
      CLOSE check_esn_curs;
      op_returnmsg := 'ESN active in site_part with exp date in future';
      RAISE e_deact_exception;
    END IF;
    CLOSE check_esn_curs;

    FOR ota_features_rec IN c_ota_features(rec_ph.objid) LOOP
      sa.sp_ild_transaction(rec_min.part_serial_no
                           ,'ILD_DEACT'
                           ,''
                           ,strilderrnum
                           ,strilderrstr);
    END LOOP;
    --CR18244 Start Kacosta 11/28/2011
    --UPDATE sa.table_x_psms_outbox
    --SET x_status = 'Cancelled'
    --,x_last_update = SYSDATE
    --WHERE x_esn = rec_ph.part_serial_no
    --AND x_status = 'Pending';
    --
    --UPDATE sa.table_x_ota_features
    --SET x_ild_account = NULL
    --,x_ild_carr_status = 'Inactive'
    --,x_ild_prog_status = 'Pending'
    --WHERE x_ota_features2part_inst = rec_ph.objid
    --AND x_ild_prog_status = 'InQueue';
    --
    --COMMIT;
    --
    --IF rec_ph.billing_rule_status = 1 THEN
    --billing_deact_rule_engine(ip_esn
    --,ip_deactreason
    --,ip_userobjid
    --,op_result
    --,op_msg);
    --END IF;
    --CR18244 End Kacosta 11/28/2011

    IF (rec_ph.x_technology = 'GSM')
      --AND (rec_ph.x_iccid IS NOT NULL) THEN
       AND (rec_ph.sp_iccid IS NOT NULL) THEN
      OPEN currdeactcode((CASE WHEN UPPER(ip_deactreason) IN ('PORT OUT'
                                                             ,'SIM DAMAGE'
                                                             ,'SIM DAMAGED'
                                                             ,'WAREHOUSE PHONE'
                                                             ,'ACTIVE UPGRADE'
                                                             ,'PORTED NO A/I'
                                                             ,'REFURBISHED'
                                                             ,'WN-SYSTEM ISSUED'
                                                             ,'PORT IN TO NET10'
                                                             ,'PORT IN TO TRACFONE'
                                                             ,'UPGRADE'
                                                             ,'SENDCARRDEACT'
                                                             ,'OVERDUE EXCHANGE') THEN 'SIM EXPIRED' WHEN UPPER(ip_deactreason) IN ('PORT CANCEL'
                                                                                                                                   ,'NTN'
                                                                                                                                   ,'NON TOPP LINE') THEN 'SIM NEW' WHEN UPPER(ip_deactreason) IN ('SIM CHANGE'
                                                                                                                                                                                                  ,'SIM EXCHANGE'
                                                                                                                                                                                                  ,'ST SIM EXCHANGE'
                                                                                                                                                                                                  ,'CHANGE OF ADDRESS') THEN 'SIM VOID' WHEN UPPER(ip_deactreason) IN ('CANCELFROMSUSPEND'
                                                                                                                                                                                                                                                                      ,'CLONED'
                                                                                                                                                                                                                                                                      ,'CUSTOMER REQD'
                                                                                                                                                                                                                                                                      ,'CUSTOMER REQUESTED'
                                                                                                                                                                                                                                                                      ,'DEFECTIVE'
                                                                                                                                                                                                                                                                      ,'NO NEED OF PHONE'
                                                                                                                                                                                                                                                                      ,'ONE TIME DEACT'
                                                                                                                                                                                                                                                                      ,'SALE OF CELL PHONE'
                                                                                                                                                                                                                                                                      ,'SELL PHONE'
                                                                                                                                                                                                                                                                      ,'MINCHANGE'
                                                                                                                                                                                                                                                                      ,'STOLEN'
                                                                                                                                                                                                                                                                      ,'NONUSAGE'
                                                                                                                                                                                                                                                                      ,'PASTDUE'
                                                                                                                                                                                                                                                                      ,'SL PHONE NEVER RCVD'
                                                                                                                                                                                                                                                                      ,'UNITS TRANSFER'
                                                                                                                                                                                                                                                                      ,'SEQUENCE MISMATCH'
                                                                                                                                                                                                                                                                      ,'RISK ASSESSMENT'
                                                                                                                                                                                                                                                                      ,'UNITS TRANSFER'
                                                                                                                                                                                                                                                                      ,'STOLEN CREDIT CARD') THEN 'SIM RESERVED' ELSE 'SIM RESERVED' END)
                        ,'SIM');
      FETCH currdeactcode
        INTO recdeactsim;
      CLOSE currdeactcode;
      v_action := 'Updating SIM information';
      dbms_output.put_line('recdeactsim.x_code_number:' || recdeactsim.x_code_number);
      UPDATE table_x_sim_inv
         SET x_sim_inv_status          = recdeactsim.x_code_number
            ,x_sim_status2x_code_table = recdeactsim.objid
      --WHERE x_sim_serial_no = rec_ph.x_iccid;
       WHERE x_sim_serial_no = rec_ph.sp_iccid;
      --CR21077 START kacosta 07/10/2012
      v_action := 'Updating other SIM information';
      UPDATE table_x_sim_inv xsi
         SET x_sim_inv_status          = recdeactsim.x_code_number
            ,x_sim_status2x_code_table = recdeactsim.objid
       WHERE xsi.x_sim_inv_status = '254'
         AND EXISTS (SELECT 1
                FROM table_site_part tsp
               WHERE tsp.x_iccid = xsi.x_sim_serial_no
                 AND tsp.x_min = rec_min.part_serial_no
                 AND tsp.part_status = 'Inactive')
            --CR21620 Start Kacosta 07/26/2012
            --AND NOT EXISTS (SELECT 1
            --       FROM table_site_part tsp
            --      WHERE tsp.x_iccid = xsi.x_sim_serial_no
            --        AND tsp.x_min <> rec_min.part_serial_no
            --        AND tsp.part_status IN ('CarrierPending'
            --                               ,'Active'));
         AND NOT EXISTS (SELECT 1
                FROM table_part_inst tpi_esn
                JOIN table_site_part tsp
                  ON tpi_esn.part_serial_no = tsp.x_service_id
               WHERE tpi_esn.x_iccid = xsi.x_sim_serial_no
                 AND tsp.x_iccid = xsi.x_sim_serial_no
                 AND tsp.x_min <> rec_min.part_serial_no
                 AND tsp.part_status IN ('CarrierPending'
                                        ,'Active'));
      --CR21620 End Kacosta 07/26/2012
      --CR21077 End Kacosta 07/10/2012
      COMMIT;
    END IF;

    --CR18244 Start Kacosta 11/28/2011
    IF UPPER(ip_deactreason) = 'SENDCARRDEACT'
       AND rec_ph.x_deact_reason = 'REFURBISHED'
       AND rec_min.x_port_in IN (1
                                ,2
                                ,3)
       AND rec_min.x_part_inst_status = '39'
       AND rec_min.part_to_esn2part_inst IS NULL THEN
      COMMIT;
      RETURN;
    END IF;

    UPDATE sa.table_x_psms_outbox
       SET x_status      = 'Cancelled'
          ,x_last_update = SYSDATE
     WHERE x_esn = rec_ph.part_serial_no
       AND x_status = 'Pending';

    UPDATE sa.table_x_ota_features
       SET x_ild_account     = NULL
          ,x_ild_carr_status = 'Inactive'
          ,x_ild_prog_status = 'Pending'
     WHERE x_ota_features2part_inst = rec_ph.objid
       AND x_ild_prog_status = 'InQueue';

    COMMIT;

    IF rec_ph.billing_rule_status = 1 THEN
      billing_deact_rule_engine(ip_esn
                               ,ip_deactreason
                               ,ip_userobjid
                               ,op_result
                               ,op_msg);
    END IF;
    --CR18244 End Kacosta 11/28/2011

    IF UPPER(ip_deactreason) = 'NONUSAGE' THEN
      UPDATE x_nonusage_esns
         SET x_deact_flag = 2
            ,x_rundate    = SYSDATE
       WHERE x_esn = rec_ph.x_service_id;
      COMMIT;
    END IF;
    OPEN currstatcode((CASE WHEN UPPER(ip_deactreason) = 'STOLEN' THEN '53' WHEN UPPER(ip_deactreason) IN ('NONUSAGE'
                                                                                                          ,'PASTDUE'
                                                                                                          ,'PORT IN TO NET10'
                                                                                                          ,'PORT IN TO TRACFONE'
                                                                                                          ,'SL PHONE NEVER RCVD'
                                                                                                          ,'UNITS TRANSFER'
                                                                                                          ,'UPGRADE'
                                                                                                          ,'PORT CANCEL'
                                                                                                          ,'UNITS TRANSFER'
                                                                                                          ,'SENDCARRDEACT') THEN '54' WHEN UPPER(ip_deactreason) IN ('SEQUENCE MISMATCH') THEN '55' WHEN UPPER(ip_deactreason) IN ('RISK ASSESSMENT'
                                                                                                                                                                                                                                  ,'STOLEN CREDIT CARD') THEN '56' WHEN UPPER(ip_deactreason) IN ('OVERDUE EXCHANGE') THEN '58' WHEN UPPER(ip_deactreason) IN ('PORT OUT'
                                                                                                                                                                                                                                                                                                                                                              ,'CANCELFROMSUSPEND'
                                                                                                                                                                                                                                                                                                                                                              ,'CLONED'
                                                                                                                                                                                                                                                                                                                                                              ,'CUSTOMER REQD'
                                                                                                                                                                                                                                                                                                                                                              ,'CUSTOMER REQUESTED'
                                                                                                                                                                                                                                                                                                                                                              ,'DEFECTIVE'
                                                                                                                                                                                                                                                                                                                                                              ,'NO NEED OF PHONE'
                                                                                                                                                                                                                                                                                                                                                              ,'ONE TIME DEACT'
                                                                                                                                                                                                                                                                                                                                                              ,'SALE OF CELL PHONE'
                                                                                                                                                                                                                                                                                                                                                              ,'SELL PHONE'
                                                                                                                                                                                                                                                                                                                                                              ,'SIM CHANGE'
                                                                                                                                                                                                                                                                                                                                                              ,'SIM DAMAGE'
                                                                                                                                                                                                                                                                                                                                                              ,'SIM DAMAGED'
                                                                                                                                                                                                                                                                                                                                                              ,'SIM EXCHANGE'
                                                                                                                                                                                                                                                                                                                                                              ,'WAREHOUSE PHONE'
                                                                                                                                                                                                                                                                                                                                                              ,'NON TOPP LINE'
                                                                                                                                                                                                                                                                                                                                                              ,'ACTIVE UPGRADE'
                                                                                                                                                                                                                                                                                                                                                              ,'CHANGE OF ADDRESS'
                                                                                                                                                                                                                                                                                                                                                              ,'MINCHANGE'
                                                                                                                                                                                                                                                                                                                                                              ,'NTN'
                                                                                                                                                                                                                                                                                                                                                              ,'PORTED NO A/I'
                                                                                                                                                                                                                                                                                                                                                              ,'REFURBISHED'
                                                                                                                                                                                                                                                                                                                                                              ,'ST SIM EXCHANGE'
                                                                                                                                                                                                                                                                                                                                                              ,'WN-SYSTEM ISSUED') THEN '51' ELSE '51' END)
                     ,'PS');
    FETCH currstatcode
      INTO recphstatcode;
    CLOSE currstatcode;
    v_action := 'Updating part_inst of ESN';
    dbms_output.put_line('recphstatcode.x_code_number:' || recphstatcode.x_code_number);
    UPDATE table_part_inst
       SET x_part_inst_status   = recphstatcode.x_code_number
          ,status2x_code_table  = recphstatcode.objid
          ,last_trans_time      = SYSDATE
          ,x_reactivation_flag  = DECODE(recdeactcode.x_value
                                        ,2
                                        ,1
                                        ,x_reactivation_flag)
          ,x_part_inst2contact  = DECODE(UPPER(ip_deactreason)
                                        ,'SL PHONE NEVER RCVD'
                                        ,NULL
                                        ,x_part_inst2contact)
          ,part_inst2x_new_pers = NULL
     WHERE ROWID = rec_ph.esn_rowid;

    IF service_deactivation_code.writepihistory(ip_userobjid
                                               ,rec_ph.esn_rowid
                                               ,NULL
                                               ,NULL
                                               ,NULL
                                               ,'DEACTIVATE'
                                                --,rec_ph.x_iccid) = 1 THEN
                                               ,rec_ph.sp_iccid) = 1 THEN
      NULL;
    END IF;

    IF UPPER(ip_deactreason) = 'SL PHONE NEVER RCVD' THEN
      DELETE table_x_contact_part_inst
       WHERE x_contact_part_inst2part_inst = rec_ph.objid;
    END IF;
    COMMIT;
    --
    --CR21077 START kacosta 07/10/2012
    --
    v_action := 'Retrieving other active ESN information';
    --
    FOR active_esn_part_inst_rec IN (SELECT tpi_esn.rowid esn_rowid
                                           ,tpi_esn.objid
                                           ,tsp.x_iccid   sp_iccid
                                       FROM table_site_part tsp
                                       JOIN table_part_inst tpi_esn
                                         ON tsp.x_service_id = tpi_esn.part_serial_no
                                      WHERE tsp.x_min = rec_min.part_serial_no
                                        AND tsp.part_status = 'Inactive'
                                        AND tpi_esn.x_part_inst_status = '52'
                                        AND tpi_esn.x_domain = 'PHONES'
                                        AND NOT EXISTS (SELECT 1
                                               FROM table_site_part tsp_other
                                              WHERE tsp_other.x_service_id = tpi_esn.part_serial_no
                                                AND tsp_other.x_min <> rec_min.part_serial_no
                                                AND tsp_other.part_status IN ('CarrierPending'
                                                                             ,'Active'))
                                        AND NOT EXISTS (SELECT 1
                                               FROM table_part_inst tpi_min
                                              WHERE tpi_min.part_to_esn2part_inst = tpi_esn.objid
                                                AND tpi_min.part_serial_no <> rec_min.part_serial_no
                                                AND tpi_min.x_part_inst_status = '13'
                                                AND tpi_min.x_domain = 'LINES')) LOOP
      --
      v_action := 'Updating other active ESN';
      --
      UPDATE table_part_inst
         SET x_part_inst_status   = recphstatcode.x_code_number
            ,status2x_code_table  = recphstatcode.objid
            ,last_trans_time      = SYSDATE
            ,x_reactivation_flag  = DECODE(recdeactcode.x_value
                                          ,2
                                          ,1
                                          ,x_reactivation_flag)
            ,x_part_inst2contact  = DECODE(UPPER(ip_deactreason)
                                          ,'SL PHONE NEVER RCVD'
                                          ,NULL
                                          ,x_part_inst2contact)
            ,part_inst2x_new_pers = NULL
       WHERE ROWID = active_esn_part_inst_rec.esn_rowid;
      --
      v_action := 'Writepihistory other active ESN';
      --
      IF service_deactivation_code.writepihistory(ip_userobjid
                                                 ,active_esn_part_inst_rec.esn_rowid
                                                 ,NULL
                                                 ,NULL
                                                 ,NULL
                                                 ,'DEACTIVATE'
                                                 ,active_esn_part_inst_rec.sp_iccid) = 1 THEN
        --
        NULL;
        --
      END IF;
      --
      IF UPPER(ip_deactreason) = 'SL PHONE NEVER RCVD' THEN
        --
        v_action := 'Delete other active ESN contact';
        --
        DELETE table_x_contact_part_inst
         WHERE x_contact_part_inst2part_inst = active_esn_part_inst_rec.objid;
        --
      END IF;
      --
      COMMIT;
      --
    END LOOP;
    --CR21077 End Kacosta 07/10/2012
    --
    v_action := 'Updating click plan hist';
    UPDATE table_x_click_plan_hist
       SET x_end_date = SYSDATE
     WHERE curr_hist2site_part = rec_ph.sitepartobjid
       AND (x_end_date IS NULL OR x_end_date = TRUNC(TO_DATE('01/01/1753'
                                                            ,'MM/DD/YYYY')));

    v_action := 'Updating Free voice mail';
    UPDATE sa.x_free_voice_mail
       SET x_fvm_status     = 1
          ,x_fvm_number     = NULL
          ,x_fvm_time_stamp = SYSDATE
     WHERE x_fvm_status = 2
       AND free_vm2part_inst = rec_ph.objid;

    v_action := 'Removing Group promos';
    FOR reccurremovepromo IN curremovepromo(rec_ph.objid) LOOP

      SELECT sequ_x_group_hist.nextval
        INTO intgrphistseq
        FROM dual;
      INSERT INTO table_x_group_hist
        (objid
        ,x_start_date
        ,x_end_date
        ,x_action_date
        ,x_action_type
        ,x_annual_plan
        ,grouphist2part_inst
        ,grouphist2x_promo_group)
      VALUES
        (intgrphistseq
        ,reccurremovepromo.x_start_date
        ,reccurremovepromo.x_end_date
        ,SYSDATE
        ,'REMOVE'
        ,reccurremovepromo.x_annual_plan
        ,reccurremovepromo.groupesn2part_inst
        ,reccurremovepromo.groupesn2x_promo_group);

      DELETE FROM table_x_group2esn
       WHERE objid = reccurremovepromo.objid;
    END LOOP;
    v_action := 'Removing autopay_prc';
    service_deactivation_code.remove_autopay_prc(rec_ph.part_serial_no
                                                ,rec_ph.org_id
                                                ,strrettemp);

    UPDATE table_x_ota_transaction a
       SET x_status = 'COMPLETED'
          ,x_reason = 'DEACT'
     WHERE x_status = 'OTA PENDING'
       AND x_esn = ip_esn
    RETURNING x_ota_trans2x_call_trans BULK COLLECT INTO v_call_trans;
    FOR i IN 1 .. v_call_trans.count LOOP
      UPDATE table_x_call_trans
         SET x_result = 'Completed'
       WHERE objid = v_call_trans(i);
      UPDATE table_x_code_hist
         SET x_code_accepted = 'YES'
       WHERE code_hist2call_trans = v_call_trans(i);
    END LOOP;

    op_return    := 'true';
    op_returnmsg := op_returnmsg || ' ' || strrettemp;
    COMMIT;
  EXCEPTION
    WHEN e_deact_exception THEN
      IF cur_ph%ISOPEN THEN
        CLOSE cur_ph;
      END IF;
      IF cur_min%ISOPEN THEN
        CLOSE cur_min;
      END IF;
      ROLLBACK;
      op_return := 'false';
      toss_util_pkg.insert_error_tab_proc(v_action || op_returnmsg
                                         ,ip_esn
                                         ,v_procedure_name);
    WHEN others THEN
      IF cur_ph%ISOPEN THEN
        CLOSE cur_ph;
      END IF;
      IF cur_min%ISOPEN THEN
        CLOSE cur_min;
      END IF;
      strsqlerrm   := SUBSTR(SQLERRM
                            ,1
                            ,200);
      op_return    := 'false';
      op_returnmsg := strsqlerrm;
      toss_util_pkg.insert_error_tab_proc(v_action
                                         ,ip_esn
                                         ,v_procedure_name);
  END deactservice;
  /*****************************************************************************/
  /*
  /* Name: WritePiHistory
  /* Description: Inserts new records into table_x_pi_hist
  /*****************************************************************************/
  FUNCTION writepihistory
  (
    ip_userobjid      IN VARCHAR2
   ,ip_part_serial_no IN VARCHAR2
   ,ip_oldnpa         IN VARCHAR2
   ,ip_oldnxx         IN VARCHAR2
   ,ip_oldext         IN VARCHAR2
   ,ip_action         IN VARCHAR2
   ,ip_iccid          IN VARCHAR2
  ) RETURN PLS_INTEGER IS
    v_function_name CONSTANT VARCHAR2(200) := v_package_name || '.insert_pi_hist_fun()';
    table_part_inst_rec table_part_inst%ROWTYPE;
    v_pi_hist_seq       NUMBER;
    -- 06/09/03
    CURSOR c1 IS
      SELECT *
        FROM table_part_inst
       WHERE ROWID = ip_part_serial_no;
  BEGIN
    --OPEN Toss_Cursor_Pkg.table_part_inst_cur (ip_part_serial_no);
    --FETCH Toss_Cursor_Pkg.table_part_inst_cur
    OPEN c1;
    FETCH c1
      INTO table_part_inst_rec;
    CLOSE c1;
    --CLOSE Toss_Cursor_Pkg.table_part_inst_cur;
    --Sp_Seq ('x_pi_hist', v_pi_hist_seq); -- 06/09/03
    SELECT sequ_x_pi_hist.nextval
      INTO v_pi_hist_seq
      FROM dual;
    INSERT INTO table_x_pi_hist
      (objid
      ,status_hist2x_code_table
      ,x_change_date
      ,x_change_reason
      ,x_cool_end_date
      ,x_creation_date
      ,x_deactivation_flag
      ,x_domain
      ,x_ext
      ,x_insert_date
      ,x_npa
      ,x_nxx
      ,x_old_ext
      ,x_old_npa
      ,x_old_nxx
      ,x_part_bin
      ,x_part_inst_status
      ,x_part_mod
      ,x_part_serial_no
      ,x_part_status
      ,x_pi_hist2carrier_mkt
      ,x_pi_hist2inv_bin
      ,x_pi_hist2part_inst
      ,x_pi_hist2part_mod
      ,x_pi_hist2user
      ,x_pi_hist2x_new_pers
      ,x_pi_hist2x_pers
      ,x_po_num
      ,x_reactivation_flag
      ,x_red_code
      ,x_sequence
      ,x_warr_end_date
      ,dev
      ,fulfill_hist2demand_dtl
      ,part_to_esn_hist2part_inst
      ,x_bad_res_qty
      ,x_date_in_serv
      ,x_good_res_qty
      ,x_last_cycle_ct
      ,x_last_mod_time
      ,x_last_pi_date
      ,x_last_trans_time
      ,x_next_cycle_ct
      ,x_order_number
      ,x_part_bad_qty
      ,x_part_good_qty
      ,x_pi_tag_no
      ,x_pick_request
      ,x_repair_date
      ,x_transaction_id
      ,x_msid
      ,x_iccid)
    VALUES
      (v_pi_hist_seq
      ,table_part_inst_rec.status2x_code_table
      ,SYSDATE
      ,ip_action
      ,table_part_inst_rec.x_cool_end_date
      ,table_part_inst_rec.x_creation_date
      ,table_part_inst_rec.x_deactivation_flag
      ,table_part_inst_rec.x_domain
      ,table_part_inst_rec.x_ext
      ,table_part_inst_rec.x_insert_date
      ,table_part_inst_rec.x_npa
      ,table_part_inst_rec.x_nxx
      ,ip_oldext
      ,ip_oldnpa
      ,ip_oldnxx
      ,table_part_inst_rec.part_bin
      ,table_part_inst_rec.x_part_inst_status
      ,table_part_inst_rec.part_mod
      ,table_part_inst_rec.part_serial_no
      ,table_part_inst_rec.part_status
      ,table_part_inst_rec.part_inst2carrier_mkt
      ,table_part_inst_rec.part_inst2inv_bin
      ,table_part_inst_rec.objid
      ,table_part_inst_rec.n_part_inst2part_mod
      ,ip_userobjid
      ,table_part_inst_rec.part_inst2x_new_pers
      ,table_part_inst_rec.part_inst2x_pers
      ,table_part_inst_rec.x_po_num
      ,table_part_inst_rec.x_reactivation_flag
      ,table_part_inst_rec.x_red_code
      ,table_part_inst_rec.x_sequence
      ,table_part_inst_rec.warr_end_date
      ,table_part_inst_rec.dev
      ,table_part_inst_rec.fulfill2demand_dtl
      ,table_part_inst_rec.part_to_esn2part_inst
      ,table_part_inst_rec.bad_res_qty
      ,table_part_inst_rec.date_in_serv
      ,table_part_inst_rec.good_res_qty
      ,table_part_inst_rec.last_cycle_ct
      ,table_part_inst_rec.last_mod_time
      ,table_part_inst_rec.last_pi_date
      ,table_part_inst_rec.last_trans_time
      ,table_part_inst_rec.next_cycle_ct
      ,table_part_inst_rec.x_order_number
      ,table_part_inst_rec.part_bad_qty
      ,table_part_inst_rec.part_good_qty
      ,table_part_inst_rec.pi_tag_no
      ,table_part_inst_rec.pick_request
      ,table_part_inst_rec.repair_date
      ,table_part_inst_rec.transaction_id
      ,table_part_inst_rec.x_msid
      ,ip_iccid);
    IF SQL%ROWCOUNT = 1 THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  EXCEPTION
    WHEN others THEN
      toss_util_pkg.insert_error_tab_proc('Failer inserting swipe'
                                         ,ip_part_serial_no
                                         ,'TOSS_UTIL_PKG.INSERT_PI_HIST_FUN');
      RETURN 0;
  END;
  --
  PROCEDURE sendcarrdeact IS
    --cwl 2/7/2011 new proc to do sendcarrdeact
    --------------------------------------------------------------------
    v_procedure_name VARCHAR2(50) := 'Service_deactivation_Code.sendcarrdeact';
    --------------------------------------------------------------------
    CURSOR user_curs IS
      SELECT objid
        FROM table_user
       WHERE s_login_name = 'SA';
    user_rec user_curs%ROWTYPE;
    CURSOR c1 IS
      SELECT pi_min.rowid                 min_rowid
            ,pi_min.part_serial_no        MIN
            ,pi_min.part_inst2carrier_mkt
             --CR18244 Start kacosta 11/7/2011
            ,pi_min.x_part_inst_status
            ,pi_min.part_to_esn2part_inst
      --CR18244 End kacosta 11/7/2011
        FROM table_part_inst pi_min
       WHERE 1 = 1
         AND pi_min.x_part_inst_status IN ('37'
                                          ,'39')
            --and pi_min.part_serial_no not like 'T%'
         AND pi_min.last_cycle_ct < TRUNC(SYSDATE)
         AND pi_min.last_cycle_ct > TRUNC(SYSDATE) - 30;
    CURSOR sp_curs(c_min IN VARCHAR2) IS
      SELECT sp.*
        FROM table_site_part sp
       WHERE sp.objid = (SELECT MAX(sp2.objid) max_sp_objid
                           FROM table_site_part sp2
                          WHERE sp2.x_min = c_min
                            AND sp2.part_status = 'Inactive');
    sp_rec sp_curs%ROWTYPE;
    CURSOR sp_active_curs(c_min IN VARCHAR2) IS
      SELECT sp.*
        FROM table_site_part sp
       WHERE sp.x_min = c_min
         AND sp.part_status IN ('Carrier Pending'
                               ,'Active')
       ORDER BY sp.objid DESC;
    sp_active_rec sp_active_curs%ROWTYPE;
    CURSOR esn_curs(c_esn IN VARCHAR2) IS
      SELECT part_serial_no
            ,objid
             --CR18244 Start kacosta 11/7/2011
            ,x_part_inst_status
      --CR18244 End kacosta 11/7/2011
        FROM table_part_inst
       WHERE part_serial_no = c_esn
         AND x_domain = 'PHONES';
    esn_rec esn_curs%ROWTYPE;

    l_return_code VARCHAR2(200);
    l_return_msg  VARCHAR2(200);

  BEGIN
    OPEN user_curs;
    FETCH user_curs
      INTO user_rec;
    CLOSE user_curs;
    FOR c1_rec IN c1 LOOP
      dbms_output.put_line('sendcarrdeact:1:' || c1_rec.min);
      OPEN sp_active_curs(c1_rec.min);
      FETCH sp_active_curs
        INTO sp_active_rec;
      IF sp_active_curs%FOUND
         AND sp_active_rec.x_service_id IS NOT NULL THEN
        dbms_output.put_line('sendcarrdeact:2');
        OPEN esn_curs(sp_active_rec.x_service_id);
        FETCH esn_curs
          INTO esn_rec;
        IF esn_curs%FOUND THEN
          dbms_output.put_line('sendcarrdeact:3');
          UPDATE table_part_inst
             SET x_part_inst_status    = '13'
                ,status2x_code_table  =
                 (SELECT objid
                    FROM table_x_code_table
                   WHERE x_code_number = '13')
                ,part_to_esn2part_inst = esn_rec.objid
           WHERE ROWID = c1_rec.min_rowid;
          COMMIT;
          CLOSE esn_curs;
          CLOSE sp_active_curs;
          GOTO skipthisrecord;
        END IF;
        CLOSE esn_curs;
      END IF;
      CLOSE sp_active_curs;
      dbms_output.put_line('sendcarrdeact:4');
      OPEN sp_curs(c1_rec.min);
      FETCH sp_curs
        INTO sp_rec;
      IF sp_rec.x_service_id IS NULL
         OR sp_curs%NOTFOUND
         OR c1_rec.part_inst2carrier_mkt IS NULL THEN
        dbms_output.put_line('sendcarrdeact:5');
        UPDATE table_part_inst
           SET x_part_inst_status    = '17'
              ,status2x_code_table  =
               (SELECT objid
                  FROM table_x_code_table
                 WHERE x_code_number = '17')
              ,part_to_esn2part_inst = NULL
         WHERE ROWID = c1_rec.min_rowid;
        COMMIT;
      ELSE
        dbms_output.put_line('sendcarrdeact:6');
        OPEN esn_curs(sp_rec.x_service_id);
        FETCH esn_curs
          INTO esn_rec;
        IF esn_curs%NOTFOUND THEN
          dbms_output.put_line('sendcarrdeact:7');
          UPDATE table_part_inst
             SET x_part_inst_status    = '17'
                ,status2x_code_table  =
                 (SELECT objid
                    FROM table_x_code_table
                   WHERE x_code_number = '17')
                ,part_to_esn2part_inst = NULL
           WHERE ROWID = c1_rec.min_rowid;
          COMMIT;
        ELSE
          dbms_output.put_line('sendcarrdeact:8');
          sa.service_deactivation_code.deactservice('PAST_DUE_BATCH'
                                                   ,user_rec.objid
                                                   ,sp_rec.x_service_id
                                                   ,sp_rec.x_min
                                                   ,'SENDCARRDEACT'
                                                   ,0
                                                   ,NULL
                                                   ,'RETURNMIN'
                                                   ,l_return_code
                                                   ,l_return_msg);
          COMMIT;
        END IF;
        CLOSE esn_curs;
      END IF;
      CLOSE sp_curs;
      dbms_output.put_line('l_return_code:' || l_return_code);
      dbms_output.put_line('l_return_msg:' || l_return_msg);
      IF l_return_code = 'false' THEN
        sa.toss_util_pkg.insert_error_tab_proc('failed to unreserve a reserved line'
                                              ,c1_rec.min
                                              ,v_procedure_name);
      END IF;
      <<skipthisrecord>>
      l_return_code := NULL;
      l_return_msg  := NULL;
    END LOOP;
  END sendcarrdeact;
END SP_DUGGI_DEACTIVATION_CODE;
/