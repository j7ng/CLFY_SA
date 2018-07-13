CREATE OR REPLACE PACKAGE BODY sa."SERVICE_DEACTIVATION_AUX"
AS
/********************************************************************************/
   /*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved
   /*
   /********************************************************************************/
   v_package_name VARCHAR2 (80) := '.SERVICE_DEACTIVATION()';
   /********************************************************************************/
   /*
   /* NAME:         SERVICE_DEACTIVATION_PKG (BODY)
   /* PURPOSE:      This package deactivate services attached to tracfone product
   /* FREQUENCY:
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.
   /*
   /* REVISIONS:
   /* VERSION  DATE        WHO     PURPOSE
   /* -------  ---------- ----- ---------------------------------------------
   /*  1.0                      Initial  Revision
   /*  1.1    05/10/2002 Mleon  Added new carrier id on main cursor on deact-
   /*                           ivate_past_due.(changed was med by JR).
   /*                           Created a new procedure deactivate_any()
   /*                           Changed write_to_monitor to created contact info
   /*                           when there;s no info attahced to the esn that is
   /*                           beeb deactivated
   /*  1.1  08/09/02  GP        Added logic to Reserve numbers when
   /*                           DEACT_HOLD is set to 1
   /*  1.2  07/05/02  SL        Add X_SUB_SOURCESYSTEM field for call trans
   /*                           insert statement
   /*  1.3  08/16/02  SL        Promo Code Project
   /*                           Remove TFU group
   /*  1.3  03/06/02  TCS       Added a new procedure which will stop the ESN
   /*                           from deactivation, if that ESN is subscribed for
   /*                           deactivation protection program. It gets the
   /*                           ESN details from autopay_details table
   /*                           and insert it into x_send_ftp_auto table
   /*  1.4   10/18/02   VA      Number Pooling Changes
   /*  1.5   10/23/02   NS      Number Pooling Changes
   /*  1.6   04/10/03   SL      Clarify Upgrade - sequence
   /*  1.7   07/21/03   GP      Included CarrierID 101912 to(deactivate_past_due)
   /*  1.8   08/15/03   MN      Modified deactivate_past_due to use table for
   /*                                   carrier IDS to be excluded
   /*  1.9   11/07/03   GP      Return line if flagged for number portability
   /*  2.0   03/03/04   CWL     Changes for CR2564 (MT43886) in deactivate_any
   /*  2.1   04/27/04   MH      CR2740 Changes for CR2740  Remove_Autopay_prc
   /*  2.2   06/25/04   MN      Change past_due cursor clause pi2.x_port_in <> 1
   /*                           to pi2.x_port_in <> 1 or pi2.x_port_in is null
   /*  2.1   07/09/04   GP      Added new procedure(deactService) that deactivates
   /*                           service from TOSS(WEBCSR). Logic comes from a
   /*                           combination of both deactivateservice.java and
   /*                           deactivateGSMService.java.
   /*  1.5   08/31/2004 TCS     CR3200 Added new in parameter (ip_samemin)
   /*                           in procedure(deactService) this variable will
   /*                           be used to determine whether relate the line with
   /*                           new ESN in case of Upgrade phone process
   /*  2.3   09/07/2004 GP      CR3208 Old code was mistakenly put back in for
   /*                           procedure(deactService), fixed it by using variable
   /*                           "intNotifycarr"
   /*  2.4   09/14/2004 GP      CR3209 Bypass carrier rules when reserving MIN to
   /*                           new ESN for procedure(deactService)
   /*  2.5   09/17/2004 RG      CR3153 Modifications for T-Mobile. In deactService
   /*                           set status of temp line to Deleted.
   /*  2.6   10/04/2004 GP      CR3153 Modified deactivate_past_due to call
   /*                           deactService instead of deactivate_service.
   /*                           (deactivate_service has been removed)
   /*  2.7   10/12/2004 GP      CR2620 Modified deactService's main cursor (cur_ph)
   /*                           added decode statement in x_part_inst_status field
   /*                           in the where clause.
   /*  2.8   10/25/2004 GP      CR3318 Changed the order of param (strDeactType)
   /*                           from 3rd to 2nd param and added logic for
   /*                           NTN (Non Tracfone Number) deactivations. Also
   /*                           removed inticap function in order to conserve
   /*                           resources
   /*  2.9   11/02/2004 RG      CR3327 Return Internal Port In lines instead of
   /*                           reserving it
   /*  3.0   11/08/2004 GP      CR3353 Break Reserving GSM line in DeactService
   /*                           procedure
   /*  3.1   12/10/2004 GP      CR3190 Flag ESN to expire minutes for NET10 phones
   /*                           if deact_reason = PastDue or Stolen in DeactService
   /*                           procedure
   /*  3.2   02/16/2005 GP      CR3667 Void SIM if deactivation is GSM and
   /*                           deactivation code_type = 'DANEW'
   /*  3.3   02/03/2005 RG      CR3327-1 Reset the x_port_in flag to 0 when internal
   /*                           port in lines are returned
   /*  3.4   03/07/2005 GP      CR3728 removed greatest function from where clause
   /*                           in deactivate_past_due procedure
   /*  3.5   03/24/2005 RG	     CR3647 - Added new deact code MINCHANGE
   /*	                         This will not send an action item for deactivation
   /*	                         to the carrier - Will be used for T-Mobile Min change
   /*  PVCS Revision No.
   /*  1.27  04/11/2005 GP      CR3905 - Add ota_pending check in past_due proc.
   /*        04/12/05   VS      CR3865 - Add few more deactivation reason code to
   /*                           remove_autopay_prc to de-enroll from autopay
   /*                           after the deactivation
   /* 1.28   04/20/05   VS      Merged with existing code.
   /* 1.29   04/20/05   VS      Modified to remove the reason "WAREHOUSE" (CR3865)
   /* 1.32   04/27/05   GP      CR3971 - Set GSM line status to "Reserved Used" instead of
   /*                           "Reserved" in (deactService) procedure
   /* 1.33   05/20/2005 GP      CR3830 - Delete OTA Pending records in (deactService)
   /* 1.34   06/03/2005 Fl      CR4091 - Provide a mechanism or wrapper for Oracle package
   /*                           to enable modifications to be done within the package without
   /*                           affecting dependent modules.
   /* 1.35    07/01/05  VA      CR4077 -  AutoPay Bug Fix 2
   /* 1.36    07/08/05  OV      CR3718 - Added ESN status 54 for ACTIVE UPGRADE reason
   /* 1.37    07/15/05  SL      CR4102 - disable 90_DAY_SERVICE if esn past due
   /* 1.38    07/19/05  SL      CR3922 - disable 52020_GRP is esn past due
   /* 1.39    08/05/05  VA      EME_080505 - Modified to improve performance based on Curt's recommendations (PVCS Revision 1.7)
   /* 1.40    08/02/05  GP      CR4245 - ILD project added call to (sp_ild_transaction)   (PVCS Revision 1.8)
   /* 1.41    08/30/05  GP      CR4478 - Updates incomplete PSMS transactions and OTA feature entries
   /*                           also fixes warehouse exchanges to reserve line for 7 days.
   /* 1.42    08/30/05  GP      Correct Version Label - CR4384 (PVCS Revision 1.11)
   /* 1.43    10/07/05  GP      CR4579 - Return lines deactivated by ReleaseReservedMIN (PVCS Revision 1.12)
   /*                           also added CarrierRules by technology.
 /* ---------------------------------------------------------------------------------------------------
/*  new pvcs
/*   1.0      02/15/2010  CL CR12874                                                                                                        */
   /********************************************************************************/
   /********************************************************************************/
   /*
   /* Name:     create_call_trans
   /* Description : Available in the specification part of package
   /********************************************************************************/
   PROCEDURE create_call_trans(
      ip_site_part IN NUMBER,
      ip_action IN NUMBER,
      ip_carrier IN NUMBER,
      ip_dealer IN NUMBER,
      ip_user IN NUMBER,
      ip_min IN VARCHAR2,
      ip_phone IN VARCHAR2,
      ip_source IN VARCHAR2,
      ip_transdate IN DATE,
      ip_units IN NUMBER,
      ip_action_text IN VARCHAR2,
      ip_reason IN VARCHAR2,
      ip_result IN VARCHAR2,
      ip_iccid IN VARCHAR2,
      op_CallTranObj OUT NUMBER
   )
   IS
      v_ct_seq NUMBER;
-- 06/09/03
   BEGIN
      sp_seq('x_call_trans', v_ct_seq); -- 06/09/03
      op_CallTranObj := v_ct_seq;
      INSERT
      INTO table_x_call_trans(
         objid,
         call_trans2site_part,
         x_action_type,
         x_call_trans2carrier,
         x_call_trans2dealer,
         x_call_trans2user,
         x_min,
         x_service_id,
         x_sourcesystem,
         x_transact_date,
         x_total_units,
         x_action_text,
         x_reason,
         x_result,
         x_sub_sourcesystem,  -- 07/05/2002 by SL
         x_iccid -- 07/07/2004 GP
      )VALUES(
         -- call_trans_seq_rec.val,
         v_ct_seq,
         ip_site_part,
         ip_action,
         ip_carrier,
         ip_dealer,
         ip_user,
         ip_min,
         ip_phone,
         ip_source,
         ip_transdate,
         ip_units,
         ip_action_text,
         ip_reason,
         ip_result,
         --              'DBMS'   -- 07/05/2002 by SL
         '202',  -- insert the code_number to x_sub_sourcesystem field instead of code_name
         ip_iccid
      );
   END create_call_trans;
   /***************************************************/
   /* Name: write_to_monitor
   /* Description : Writes into monitor table
   /*
   /****************************************************/
   PROCEDURE write_to_monitor(
      site_part_objid IN NUMBER,
      cust_site_objid IN NUMBER,
      x_carrier_id IN NUMBER,
      site_part_msid IN VARCHAR2
   )
   IS

      --retrieve the deactivated site part
   CURSOR c1
   IS
   SELECT *
     FROM TABLE_SITE_PART
    WHERE objid = site_part_objid;
   c1_rec c1%ROWTYPE;

   CURSOR c2(cust_site_objid_ip IN NUMBER)
   IS
   SELECT site_id
     FROM TABLE_SITE
    WHERE objid = cust_site_objid_ip
      AND ROWNUM = 1;
   c2_rec c2%ROWTYPE;

   --retrieve the dealer_id for the site part
   CURSOR c3(sp_esn IN VARCHAR2)
   IS
   SELECT s.site_id site_id
     FROM TABLE_SITE s,
          TABLE_INV_ROLE ir,
          TABLE_INV_LOCATN il,
          TABLE_INV_BIN ib,
          TABLE_PART_INST pi
    WHERE s.objid = ir.inv_role2site
      AND ir.inv_role2inv_locatn = il.objid
      AND il.objid = ib.inv_bin2inv_locatn
      AND ib.objid = pi.part_inst2inv_bin
      AND pi.x_domain = 'PHONES'
      AND pi.part_serial_no = sp_esn
      AND ROWNUM = 1;
   c3_rec c3%ROWTYPE;

   CURSOR c4(ml_objid IN NUMBER)
   IS
   SELECT pn.x_manufacturer x_manufacturer
     FROM TABLE_PART_NUM pn,
          TABLE_MOD_LEVEL ml
    WHERE pn.objid = ml.part_info2part_num
      AND ml.objid = ml_objid;
   c4_rec c4%ROWTYPE;

   CURSOR c5(site_objid IN NUMBER)
   IS
   SELECT c.last_name || ', ' || c.first_name name
     FROM TABLE_CONTACT c,
          TABLE_CONTACT_ROLE cr
    WHERE c.objid = cr.contact_role2contact
      AND cr.contact_role2site = site_objid
      AND ROWNUM = 1;

   c5_rec c5%ROWTYPE;
   v_new_site_objid NUMBER;
   v_new_site_id NUMBER;
   v_new_address_objid NUMBER;
   v_new_contact_objid NUMBER;
   v_new_contact_role_objid NUMBER;
   v_cust_site_objid NUMBER;
   BEGIN
      v_cust_site_objid := cust_site_objid;
      OPEN c1;
      FETCH c1
      INTO c1_rec;
      CLOSE c1;
      OPEN c5 (c1_rec.site_part2site);
      FETCH c5
      INTO c5_rec;
      IF c5%NOTFOUND
      THEN
         CLOSE c5;
         /** get all the sequences **/
         Sp_seq('address', v_new_address_objid); -- 06/09/03
         Sp_seq('new_site', v_new_site_objid); -- 06/09/03
--cwl CR12874
         SELECT sa.sequ_individual_id.NEXTVAL --next_value
           INTO v_new_site_id
          from dual;
--           FROM TABLE_NUM_SCHEME
--          WHERE name = 'Individual ID';

--         UPDATE TABLE_NUM_SCHEME
--            SET next_value = next_value + 1
--          WHERE name = 'Individual ID';
--cwl CR12874
         Sp_seq('new_contact', v_new_contact_objid); -- 06/09/03
         Sp_seq('new_contact_role', v_new_contact_role_objid); -- 06/09/03

         /** insert into the address table */
         INSERT INTO TABLE_ADDRESS(
            objid,
            address,
            s_address,
            city,
            s_city,
            state,
            s_state,
            zipcode,
            address_2,
            dev,
            address2time_zone,
            address2country,
            address2state_prov,
            update_stamp
         )VALUES(
            v_new_address_objid,
            'No Address Provided',
            'NO ADDRESS PROVIDED',
            'No City Provided',
            'NO CITY PROVIDED',
            'FL',
            'FL',
            '33122',
            NULL,
            NULL,
            268435561,
            268435457,
            268435466,
            SYSDATE
         );

         /** create a table_site dummy record **/
         INSERT INTO TABLE_SITE(
            objid,
            site_id,
            name,
            s_name,
            external_id,
            TYPE,
            logistics_type,
            is_support,
            region,
            s_region,
            district,
            s_district,
            depot,
            contr_login,
            contr_passwd,
            is_default,
            notes,
            spec_consid,
            mdbk,
            state_code,
            state_value,
            industry_type,
            appl_type,
            cut_date,
            site_type,
            status,
            arch_ind,
            alert_ind,
            phone,
            fax,
            dev,
            child_site2site,
            support_office2site,
            cust_primaddr2address,
            cust_billaddr2address,
            cust_shipaddr2address,
            site_support2employee,
            site_altsupp2employee,
            report_site2bug,
            primary2bus_org,
            site2exch_protocol,
            dealer2x_promotion,
            x_smp_optional,
            update_stamp,
            x_fin_cust_id
         )VALUES(
            v_new_site_objid,
            'IND' || TO_CHAR (v_new_site_id),
            'No Address Provided',
            'NO ADDRESS PROVIDED',
            NULL,
            4,
            0,
            0,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            0,
            NULL,
            0,
            NULL,
            0,
            NULL,
            NULL,
            NULL,
            TO_DATE ('01-JAN-1753'),
            'INDV',
            0,
            0,
            0,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            v_new_address_objid,  --need to update
            NULL,
            v_new_address_objid,  --need to update
            NULL,
            NULL,
            NULL,
            - 2,
            NULL,
            NULL,
            0,
            SYSDATE,
            NULL
         );

         /** create a table_contact_role record **/
         INSERT
         INTO TABLE_CONTACT_ROLE(
            objid,
            role_name,
            s_role_name,
            primary_site,
            dev,
            contact_role2site,
            contact_role2contact,
            contact_role2gbst_elm,
            update_stamp
         )VALUES(
            v_new_contact_role_objid,
            NULL,
            NULL,
            1,
            NULL,
            v_new_site_objid,
            v_new_contact_objid,
            NULL,
            SYSDATE
         );
         /** create a table_contact record **/
         INSERT INTO TABLE_CONTACT(
            objid,
            first_name,
            s_first_name,
            last_name,
            s_last_name,
            phone,
            fax_number,
            e_mail,
            mail_stop,
            expertise_lev,
            title,
            hours,
            salutation,
            mdbk,
            state_code,
            state_value,
            address_1,
            address_2,
            city,
            state,
            zipcode,
            country,
            status,
            arch_ind,
            alert_ind,
            dev,
            caller2user,
            contact2x_carrier,
            x_cust_id,
            x_dateofbirth,
            x_gender,
            x_middle_initial,
            x_mobilenumber,
            x_no_address_flag,
            x_no_name_flag,
            x_pagernumber,
            x_ss_number,
            x_no_phone_flag,
            update_stamp,
            x_new_esn,
            x_email_status,
            x_html_ok
         )VALUES(
            v_new_contact_objid,
            v_new_site_id,
            v_new_site_id,
            v_new_site_id,
            v_new_site_id,
            v_new_site_id,
            NULL,
            NULL,
            NULL,
            0,
            NULL,
            NULL,
            NULL,
            NULL,
            0,
            NULL,
            'No Address Provided',
            NULL,
            'No Address Provided',
            'FL',
            '33122',
            'USA',
            0,
            0,
            0,
            NULL,
            NULL,
            NULL,
            v_new_site_id,
            TO_DATE ('01-JAN-1753'),
            NULL,
            NULL,
            NULL,
            1,
            1,
            NULL,
            NULL,
            1,
            SYSDATE,
            NULL,
            0,
            0
         );
         --
         /** update table_site_part  **/
         UPDATE TABLE_SITE_PART
            SET site_part2site = v_new_site_objid,
                all_site_part2site = v_new_site_objid,
                dir_site_objid = v_new_site_objid,
                site_objid = v_new_site_objid
          WHERE objid = site_part_objid;

         /** now reopen with updated data **/
         OPEN c1;
         FETCH c1
         INTO c1_rec;
         CLOSE c1;
         OPEN c5 (c1_rec.site_part2site);
         FETCH c5
         INTO c5_rec;
         CLOSE c5;
         /** done reopnenning **/
         /** reassinging cust_site_objid **/
         v_cust_site_objid := v_new_site_objid;
      END IF;
      IF c5%ISOPEN
      THEN
         CLOSE c5;
      END IF;
      /** move this to avoid double openning of cursors **/
      OPEN c2 (v_cust_site_objid);
      FETCH c2
      INTO c2_rec;
      CLOSE c2;
      OPEN c3 (c1_rec.serial_no);
      FETCH c3
      INTO c3_rec;
      CLOSE c3;
      OPEN c4 (c1_rec.site_part2part_info);
      FETCH c4
      INTO c4_rec;
      CLOSE c4;
      --cwl2.put_line('Adam','site_part_objid:'||to_char(site_part_objid));
      INSERT INTO X_MONITOR(
         x_monitor_id,
         x_date_mvt,
         x_phone,
         x_esn,
         x_cust_id,
         x_carrier_id,
         x_dealer_id,
         x_action,
         x_reason_code,
         x_line_worked,
         x_line_worked_by,
         x_line_worked_date,
         x_islocked,
         x_locked_by,
         x_action_type_id,
         x_ig_status,
         x_ig_error,
         x_pin,
         x_manufacturer,
         x_initial_act_date,
         x_end_user,
         x_msid --Number Pooling 10/18/02
      )VALUES(
         (seq_x_monitor_id.NEXTVAL + (POWER (2, 28))),
         SYSDATE,
         c1_rec.x_min,
         c1_rec.serial_no,
         c2_rec.site_id,
         TO_CHAR (x_carrier_id),
         c3_rec.site_id,
         DECODE (c1_rec.x_notify_carrier, 1, 'D', 0, 'S'),
         c1_rec.x_deact_reason,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         DECODE (c1_rec.x_notify_carrier, 1, 0, 0, 1),
         NULL,
         NULL,
         c1_rec.x_pin,
         c4_rec.x_manufacturer,
         c1_rec.install_date,
         c5_rec.name,
         site_part_msid --Number Pooling Changes 10/18/02
      );
      COMMIT;
   END write_to_monitor;
   /*******************************************************************************************/
   /* Name:   sp_update_exp_date_prc
   /* Description:  New Procedure added to extend the expire_dt - Modified by TCS offshore Team
   /*
   /*******************************************************************************************/
   PROCEDURE sp_update_exp_date_prc(
      p_esn IN VARCHAR2,
      p_grace_time IN DATE,
      op_result OUT NUMBER,
      op_msg OUT VARCHAR2
   )
   IS
   v_partinstcount NUMBER;
   v_procedure_name VARCHAR2 (80) := v_package_name ||
   '.SP_UPDATE_EXP_DATE_PRC()';
   CURSOR cur_ph_c(
      ip_esn VARCHAR2
   )
   IS
   SELECT *
   FROM TABLE_PART_INST
   WHERE x_part_inst_status = '52'
   AND part_serial_no = ip_esn
   AND x_domain = 'PHONES';
   rec_ph cur_ph_c%ROWTYPE;
   v_pi_hist_seq NUMBER;
   -- 06/09/03
   BEGIN
      op_result := 0;
      op_msg := 'Update Successful';
      --Begin Is Valid ESN
      SELECT COUNT (*)
      INTO v_partinstcount
      FROM TABLE_PART_INST
      WHERE part_serial_no = p_esn
      AND x_domain = 'PHONES';
      IF v_partinstcount = 0
      THEN
         op_msg := 'ERROR - Esn not found';
         op_result := 1;
         RETURN;
      END IF;

      --Begin Is Phone Active
      SELECT COUNT (*) INTO v_partinstcount
        FROM TABLE_PART_INST
       WHERE part_serial_no = p_esn
         AND x_domain = 'PHONES'
         AND x_part_inst_status = '52';

      IF v_partinstcount = 0
      THEN
         op_msg := 'ERROR - Active esn not found';
         op_result := 1;
         RETURN;
      END IF;
--Begin Update
      BEGIN
         UPDATE TABLE_SITE_PART
            SET x_expire_dt = p_grace_time
          WHERE x_service_id = p_esn
            AND part_status = 'Active';
         EXCEPTION
         WHEN OTHERS
         THEN
            op_result := 1;
            op_msg := 'Error - E_UpdateFailed, RECORD UPDATE Failed.';
            Toss_util_pkg.Insert_error_tab_proc ( 'Update Table_site_part', NVL
            (p_esn, 'N/A'), v_procedure_name );
            RETURN;
      END;
      BEGIN
         OPEN cur_ph_c (p_esn);
         FETCH cur_ph_c
         INTO rec_ph;
         CLOSE cur_ph_c;

         UPDATE TABLE_PART_INST
            SET warr_end_date = p_grace_time
          WHERE part_serial_no = p_esn
            AND x_domain = 'PHONES'
            AND x_part_inst_status = '52';
         Sp_seq('x_pi_hist', v_pi_hist_seq);

         INSERT INTO TABLE_X_PI_HIST(
            objid,
            status_hist2x_code_table,
            x_change_date,
            x_change_reason,
            x_cool_end_date,
            x_creation_date,
            x_deactivation_flag,
            x_domain,
            x_ext,
            x_insert_date,
            x_npa,
            x_nxx,
            x_old_ext,
            x_old_npa,
            x_old_nxx,
            x_part_bin,
            x_part_inst_status,
            x_part_mod,
            x_part_serial_no,
            x_part_status,
            x_pi_hist2carrier_mkt,
            x_pi_hist2inv_bin,
            x_pi_hist2part_inst,
            x_pi_hist2part_mod,
            x_pi_hist2user,
            x_pi_hist2x_new_pers,
            x_pi_hist2x_pers,
            x_po_num,
            x_reactivation_flag,
            x_red_code,
            x_sequence,
            x_warr_end_date,
            dev,
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
            x_transaction_id
         )VALUES(
            -- 04/10/03 seq_x_pi_hist.nextval + POWER (2, 28),
            -- seq('x_pi_hist'),
            v_pi_hist_seq,
            rec_ph.status2x_code_table,
            SYSDATE,
            'PROTECTION PLAN BATCH',
            rec_ph.x_cool_end_date,
            rec_ph.x_creation_date,
            rec_ph.x_deactivation_flag,
            rec_ph.x_domain,
            rec_ph.x_ext,
            rec_ph.x_insert_date,
            rec_ph.x_npa,
            rec_ph.x_nxx,
            NULL,
            NULL,
            NULL,
            rec_ph.part_bin,
            '84',
            rec_ph.part_mod,
            rec_ph.part_serial_no,
            rec_ph.part_status,
            rec_ph.part_inst2carrier_mkt,
            rec_ph.part_inst2inv_bin,
            rec_ph.objid,
            rec_ph.n_part_inst2part_mod,
            rec_ph.created_by2user,
            rec_ph.part_inst2x_new_pers,
            rec_ph.part_inst2x_pers,
            rec_ph.x_po_num,
            rec_ph.x_reactivation_flag,
            rec_ph.x_red_code,
            rec_ph.x_sequence,
            rec_ph.warr_end_date,
            rec_ph.dev,
            rec_ph.fulfill2demand_dtl,
            rec_ph.part_to_esn2part_inst,
            rec_ph.bad_res_qty,
            rec_ph.date_in_serv,
            rec_ph.good_res_qty,
            rec_ph.last_cycle_ct,
            rec_ph.last_mod_time,
            rec_ph.last_pi_date,
            rec_ph.last_trans_time,
            rec_ph.next_cycle_ct,
            rec_ph.x_order_number,
            rec_ph.part_bad_qty,
            rec_ph.part_good_qty,
            rec_ph.pi_tag_no,
            rec_ph.pick_request,
            rec_ph.repair_date,
            rec_ph.transaction_id
         );
         -- Insert into table_pi_hist
         EXCEPTION
         WHEN OTHERS
         THEN
            op_result := 1;
            op_msg := 'Error - E_UpdateFailed, RECORD UPDATE Failed.';
            Toss_util_pkg.Insert_error_tab_proc ( 'UPDATE TABLE_PART_INST', NVL
            (p_esn, 'N/A'), v_procedure_name );
            RETURN;
      END;
   END sp_update_exp_date_prc;
   /**********************************************************************************************/
   /*   Name:   check_dpp_registered_prc
   /*   Description:   New Procedure added to check whether the ESN is subscribed for Deactivation
   /*                  Protection Program - Modified by TCS offshore Team
   /*
   /**********************************************************************************************/
   PROCEDURE check_dpp_registered_prc(
      p_esn IN VARCHAR2,
      out_result OUT PLS_INTEGER
   )
   IS
--Get the record for the esn from table_x_autopay_details table
   CURSOR curgetdpp_c(
      ip_esn IN VARCHAR2
   )
   IS
   SELECT *
     FROM TABLE_X_AUTOPAY_DETAILS
    WHERE x_end_date IS NULL
      AND x_esn = ip_esn
      AND x_program_type = 4
      AND x_status = 'A'
   --CR4077
   --            AND x_account_status = '3'
     AND x_account_status IN ( '3', '5')
     AND ( x_receive_status IS NULL
      OR x_receive_status = 'Y');
   curgetdpp_rec curgetdpp_c%ROWTYPE;

   v_expire_dt DATE;
   v_amount NUMBER;
   op_result NUMBER;
   op_msg VARCHAR2 (50);
   v_procedure_name VARCHAR2 (80) := v_package_name ||'.CHECK_DPP_REGISTERED_PRC()';
   dayVal VARCHAR2(30);
---for CR 1142
   BEGIN
      out_result := 0; -- default is false
      OPEN curgetdpp_c (p_esn);
      FETCH curgetdpp_c
      INTO curgetdpp_rec;
      IF curgetdpp_c%FOUND
      THEN

         -- extend the expire_dt and insert into send_ftp
         SELECT x_expire_dt
           INTO v_expire_dt
           FROM TABLE_SITE_PART
          WHERE x_service_id = p_esn
            AND part_status = 'Active';

         sp_update_exp_date_prc (p_esn, v_expire_dt + 10, op_result, op_msg);

         IF op_result = 0 -- If the update_exp_date is O.K
         THEN
            v_amount := get_amount_fun (4);
            BEGIN

               --Insert into send_ftp_auto
               SELECT TRIM(TO_CHAR(SYSDATE, 'DAY'))
                 INTO dayVal
                 FROM dual; -- CR 1142

               INSERT INTO X_SEND_FTP_AUTO(
                  send_seq_no,
                  file_type_ind,
                  esn,
                  debit_date,
                  program_type,
                  account_status,
                  amount_due
               )VALUES(
                  seq_x_send_ftp_auto.NEXTVAL,
                  'D',
                  p_esn,
                  DECODE(dayVal, 'FRIDAY', SYSDATE + 3, 'SATURDAY', SYSDATE + 2
                  , SYSDATE + 1),  -- CR 1142
                  curgetdpp_rec.x_program_type,
                  'A',
                  v_amount --from pricing table
               );
               out_result := 1;
               EXCEPTION
               WHEN OTHERS
               THEN
                  Toss_util_pkg.Insert_error_tab_proc (
                  'INSERT INTO SEND_FTP_AUTO', NVL (p_esn, 'N/A'),
                  v_procedure_name );
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
      WHEN OTHERS
      THEN
         out_result := 0;
         Toss_util_pkg.Insert_error_tab_proc ( 'Error IN check_dpp_registered',
         NVL (p_esn, 'N/A'), v_procedure_name );
         RETURN;
   END check_dpp_registered_prc;
   /*****************************************************************************/
   /*   Name:    get_amount_fun
   /*   Description: New Procedure added to get the monthly fee for  Deactivation
   /*                Protection Program - Modified by TCS
   /*
   /******************************************************************************/
   FUNCTION get_amount_fun(
      p_prg_type NUMBER
   )
   RETURN NUMBER
   IS
      v_amount NUMBER := 7.99;
      err_no NUMBER;
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.get_amount()';
   BEGIN
      IF p_prg_type = 4
      THEN
         SELECT x_retail_price
           INTO v_amount
           FROM TABLE_X_PRICING
          WHERE x_pricing2part_num = (SELECT objid
                                        FROM TABLE_PART_NUM
                                       WHERE part_number = 'APPDEACTMON'
                                      );
      END IF;
      RETURN v_amount;
      EXCEPTION
      WHEN OTHERS
      THEN
         err_no := Toss_util_pkg.insert_error_tab_fun (
         'Failed retrieving Amount - Mnthly fee ', p_prg_type, v_function_name
         );
         RETURN v_amount;
   END get_amount_fun;
   /**********************************************************************************************/
   /*  Name:        remove_autopay_prc
   /*  Description : New Procedure added to remove the ESN from Autopay promotions and
   /*                unsubscribe from Autopay program - Modified by TCS offshore Team
   /*******************************************************************************************/
   PROCEDURE remove_autopay_prc(
      p_esn IN VARCHAR2,
      out_success OUT NUMBER
   )
   IS
   v_prg_type NUMBER;
   v_cycle_number NUMBER;
   v_cust_name VARCHAR2 (45);
   v_procedure_name VARCHAR2 (80) := v_package_name || '.REMOVE_AUTOPAY()';
   ------------------------------------------------------------
   CURSOR curautoinfo_c(
      c_esn VARCHAR2
   )
   IS
   SELECT *
     FROM TABLE_X_AUTOPAY_DETAILS
    WHERE x_esn = c_esn
      AND x_status = 'A'
      AND (x_end_date IS NULL
       OR x_end_date = TO_DATE('01-jan-1753', 'dd-mon-yyyy'));
   curautoinfo_rec curautoinfo_c%ROWTYPE;
   ------------------------------------------------------------
   CURSOR part_inst_curs(
      c_esn IN VARCHAR2
   )
   IS
   SELECT x_part_inst_status
     FROM TABLE_PART_INST
    WHERE part_serial_no = c_esn;
   part_inst_rec part_inst_curs%ROWTYPE;
   ------------------------------------------------------------
   CURSOR carrier_curs(
      c_min IN VARCHAR2
   )
   IS
   SELECT part_inst2carrier_mkt
     FROM TABLE_PART_INST
    WHERE part_serial_no = c_min;
   carrier_rec carrier_curs%ROWTYPE;
   ------------------------------------------------------------
   CURSOR site_part_curs(
      c_esn IN VARCHAR2
   )
   IS
   SELECT *
   FROM TABLE_SITE_PART
   WHERE x_service_id = c_esn
   AND part_status IN ('Active', 'Inactive')
   ORDER BY install_date DESC;
   site_part_rec site_part_curs%ROWTYPE;
   ------------------------------------------------------------
   CURSOR user_curs(
      c_login_name IN VARCHAR2
   )
   IS
   SELECT objid
   FROM TABLE_USER
   WHERE s_login_name = UPPER(c_login_name);
   user_rec user_curs%ROWTYPE;
   v_call_trans_seq NUMBER;

   -- 06/09/03
   --------------------------------------------------
   BEGIN

      --Get the autopay promotions details for the ESN
      out_success := 0;
      OPEN curautoinfo_c (p_esn);
      FETCH curautoinfo_c
      INTO curautoinfo_rec;
      IF curautoinfo_c%FOUND
      THEN
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
         UPDATE TABLE_X_AUTOPAY_DETAILS
            SET x_status = 'I',
                x_end_date = SYSDATE,
                x_account_status = 9
          WHERE objid = curautoinfo_rec.objid;
         Sp_seq('x_call_trans', v_call_trans_seq); -- 06/09/03

         INSERT INTO TABLE_X_CALL_TRANS(
            objid,
            call_trans2site_part,
            x_action_type,
            x_call_trans2carrier,
            x_call_trans2dealer,
            x_call_trans2user,
            x_line_status,
            x_min,
            x_service_id,
            x_sourcesystem,
            x_transact_date,
            x_total_units,
            x_action_text,
            x_reason,
            x_result,
            x_sub_sourcesystem
         )VALUES(
            -- 04/10/03 (seq_x_call_trans.NEXTVAL + POWER (2, 28)),
            -- seq('x_call_trans'),
            v_call_trans_seq,
            site_part_rec.objid,
            '83',
            carrier_rec.part_inst2carrier_mkt,
            site_part_rec.SITE_PART2SITE,
            user_rec.objid,
            '13',
            site_part_rec.x_min,
            site_part_rec.x_service_id,
            'AUTOPAY_BATCH',
            SYSDATE,
            0,
            'STAYACT UNSUBSCRIBE',  --'Cancellation',    --CR 1157
            'TOSS Deactivation',  --'STAYACT UNSUBSCRIBE',
            'Completed',
            '202'
         );
         --          if part_inst_rec.x_part_inst_status = '54' then
         --          Added more deactivation reason codes.
         IF site_part_rec.X_DEACT_REASON IN ('NO NEED OF PHONE', 'PAST DUE',
         'PASTDUE', 'SALE OF CELL PHONE', 'SELL PHONE', 'STOLEN', 'DEFECTIVE',
         'SEQUENCE MISMATCH', 'RISK ASSESSMENT', 'STOLEN CREDIT CARD',
         'UPGRADE', 'REFURBISHED', 'PORT OUT', 'NON TOPP LINE', 'CLONED',
         'OVERDUE EXCHANGE')
         THEN
            --insert into send_ftp table
            INSERT
            INTO X_SEND_FTP_AUTO(
               send_seq_no,
               file_type_ind,
               esn,
               program_type,
               account_status,
               amount_due
            )VALUES(
               seq_x_send_ftp_auto.NEXTVAL,
               'D',
               p_esn,
               curautoinfo_rec.x_program_type,
               'D',
               0
            );
         ELSE
            INSERT
            INTO X_AUTOPAY_PENDING(
               OBJID,
               X_CREATION_DATE,
               X_ESN,
               X_PROGRAM_TYPE,
               X_ACCOUNT_STATUS,
               X_STATUS,
               X_START_DATE,
               X_END_DATE,
               X_CYCLE_NUMBER,
               X_PROGRAM_NAME,
               X_ENROLL_DATE,
               X_FIRST_NAME,
               X_LAST_NAME,
               X_RECEIVE_STATUS,
               X_AUTOPAY_DETAILS2SITE_PART,
               X_AUTOPAY_DETAILS2X_PART_INST,
               X_AUTOPAY_DETAILS2CONTACT,
               X_SOURCE_FLAG,
               X_ENROLL_AMOUNT,
               X_SOURCE,
               X_LANGUAGE_FLAG,
               X_PAYMENT_TYPE
            )VALUES(
               curautoinfo_rec.OBJID,
               curautoinfo_rec.X_CREATION_DATE,
               curautoinfo_rec.X_ESN,
               curautoinfo_rec.X_PROGRAM_TYPE,
               curautoinfo_rec.X_ACCOUNT_STATUS,
               curautoinfo_rec.X_STATUS,
               curautoinfo_rec.X_START_DATE,
               SYSDATE,
               curautoinfo_rec.X_CYCLE_NUMBER,
               curautoinfo_rec.X_PROGRAM_NAME,
               curautoinfo_rec.X_ENROLL_DATE,
               curautoinfo_rec.X_FIRST_NAME,
               curautoinfo_rec.X_LAST_NAME,
               curautoinfo_rec.X_RECEIVE_STATUS,
               curautoinfo_rec.X_AUTOPAY_DETAILS2SITE_PART,
               curautoinfo_rec.X_AUTOPAY_DETAILS2X_PART_INST,
               curautoinfo_rec.X_AUTOPAY_DETAILS2CONTACT,
               'D',
               curautoinfo_rec.X_ENROLL_AMOUNT,
               curautoinfo_rec.X_SOURCE,
               curautoinfo_rec.X_LANGUAGE_FLAG,
               curautoinfo_rec.X_PAYMENT_TYPE
            );
         END IF;
         out_success := 1;
      END IF;
      CLOSE curautoinfo_c;
      EXCEPTION
      WHEN OTHERS
      THEN
         out_success := 0;
         Toss_util_pkg.Insert_error_tab_proc ( 'Error IN remove_autopay', p_esn
         , v_procedure_name );
   END remove_autopay_prc;


   /*****************************************************************************/
   /*                                                                           */
   /* Name:     deactivate_past_due                                             */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   --EME_080505 Starts
   PROCEDURE deactivate_past_due
   IS
      v_user TABLE_USER.objid%TYPE;
      v_returnflag VARCHAR2(20);
      v_returnMsg VARCHAR2(200);
      dpp_regflag PLS_INTEGER;
      v_action VARCHAR2(50) := 'x_service_id is null in Table_site_part';
      v_procedure_name VARCHAR2(50) :=
      '.SERVICE_DEACTIVATION.DEACTIVATE_PAST_DUE';
      intCallTranObj NUMBER := 0;
      blnOTAPending BOOLEAN := FALSE;
      CURSOR c1
      IS
      SELECT sp.objid site_part_objid,
             sp.x_service_id x_service_id,
             sp.x_min x_min,
             ca.objid carrier_objid,
             ir.inv_role2site site_objid,
             sp.serial_no x_esn,
             ca.x_carrier_id x_carrier_id,
             sp.site_objid cust_site_objid,
             pi.objid esnobjid,
             sp.x_msid,
             pi.part_serial_no part_serial_no,
             pi.x_iccid,
             pn.X_OTA_ALLOWED
        FROM TABLE_X_CARRIER ca,
             TABLE_PART_INST pi2,
             TABLE_INV_ROLE ir,
             TABLE_INV_BIN ib,
             TABLE_PART_INST pi,
             TABLE_SITE_PART sp,
             TABLE_MOD_LEVEL ml,
             TABLE_PART_NUM pn,
             x_pending_deact pd
      WHERE ca.x_carrier_id NOT IN (SELECT e.x_carrier_id
                                      FROM X_EXCLUDED_PASTDUEDEACT e)
        AND ca.objid = pi2.part_inst2carrier_mkt
        AND pi2.x_domain = 'LINES' -->CR3318  Removed initcap func
        AND pi2.part_serial_no = sp.x_min
        AND (pi2.x_port_in <> 1 OR pi2.x_port_in IS NULL)
        AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
        AND ib.objid = pi.part_inst2inv_bin
        AND ml.part_info2part_num = pn.objid
        AND pi.n_part_inst2part_mod = ml.objid
        AND pi.x_part_inst2site_part = sp.objid
        --CR3728
        AND sp.x_expire_dt BETWEEN TO_DATE ('02-JAN-1753', 'dd-mon-yyyy') AND (SYSDATE - 1)
        AND sp.part_status||'' = 'Active'
        AND sp.objid = pd.objid
        AND pd.x_expire_dt BETWEEN TO_DATE ('02-JAN-1753', 'dd-mon-yyyy') AND (SYSDATE - 1)
        AND ROWNUM < 1500;

      /** CR3905 - Added OTAPending cursor **/
      CURSOR c_chkOTAPend(
         c_esn IN VARCHAR2
      )
      IS
      SELECT 'X'
        FROM TABLE_X_CALL_TRANS
       WHERE OBJID = (SELECT MAX(OBJID)
                        FROM TABLE_X_CALL_TRANS
                       WHERE x_service_id = c_esn
                      )
         AND x_result = 'OTA PENDING'
         AND x_action_type = '6';

      r_chkOTAPend c_chkOTAPend%ROWTYPE;
      ----------------------------------------------------------------------------------------------
      -- call procedure to see if possible deactivation list created
      -- jr 8/505
      PROCEDURE check_x_deact_table
      IS
         hold1 NUMBER := 0;
         sql1 VARCHAR2(5000) :=
         'select 1 from dual
                                where exists( select 1
                                              from x_pending_deact
                                             where x_expire_dt > trunc(sysdate)-1)';
         sql2 VARCHAR2(5000) := 'truncate table x_pending_deact';
         sql3 VARCHAR2(5000) :=
         'insert into x_pending_deact
                               select /*+ FULL(sp) PARALLEL(sp,10) */
                                      sp.objid,sp.x_expire_dt
                                 from table_site_part sp
                                where sp.x_expire_dt BETWEEN TO_DATE (''02-JAN-1753'', ''dd-mon-yyyy'') AND trunc(SYSDATE)
                                  AND sp.part_status||'''' = ''Active''';
      BEGIN
         BEGIN
            EXECUTE IMMEDIATE sql1
            INTO hold1;
            EXCEPTION
            WHEN OTHERS
            THEN
               hold1 := 0;
         END;
         IF hold1 = 1
         THEN
            DBMS_OUTPUT.put_line('found');
         ELSE
            DBMS_OUTPUT.put_line('found date out of bounds');
            EXECUTE IMMEDIATE sql2;
            EXECUTE IMMEDIATE sql3;
            COMMIT;
         END IF;
      END;
------------------------------------------------------------------------------------------------
   BEGIN
      DBMS_TRANSACTION.use_rollback_segment ('R08_BIG');
      -- call procedure to see if possible deactivation list created
      -- jr 8/505
      check_x_deact_table;
      -------
      SELECT objid
      INTO v_user
      FROM TABLE_USER
      WHERE UPPER (login_name) = 'SA';
      FOR c1_rec IN c1
      LOOP
         blnOTAPending := FALSE;
         -- CR3905 - Change boolean value if OTA found
         IF (c1_rec.X_OTA_ALLOWED = 'Y')
         THEN
            OPEN c_chkOTAPend(c1_rec.part_serial_no);
            FETCH c_chkOTAPend
            INTO r_chkOTAPend;
            IF c_chkOTAPend%FOUND
            THEN
               blnOTAPending := TRUE;
            END IF;
            CLOSE c_chkOTAPend;
         END IF;

         -- Check whether x_service_id is not null -- 10/13/03
         IF (c1_rec.x_service_id IS NULL)
         THEN
            UPDATE TABLE_SITE_PART
               SET x_service_id = NVL(c1_rec.x_esn, c1_rec.part_serial_no)
             WHERE objid = c1_rec.site_part_objid;
            COMMIT;
         END IF;

         --Autopay Program - Change made By TCS offshore Starts Here
         check_dpp_registered_prc (c1_rec.x_service_id, dpp_regflag);
         IF dpp_regflag = 1
         THEN
            --Insert into x_call_trans
            create_call_trans (c1_rec.site_part_objid, 84, c1_rec.carrier_objid,
                               c1_rec.site_objid, v_user, c1_rec.x_min, c1_rec.x_service_id,
                               'PROTECTION PLAN BATCH', SYSDATE, NULL, 'Monthly Payments',
                               'PASTDUE', 'Pending', c1_rec.x_iccid,intCallTranObj );
         ELSE
            IF NOT blnOTAPending
            THEN
               --CR3153 T-Mobile changes
               deactService('PAST_DUE_BATCH', v_user, c1_rec.x_service_id,
                            c1_rec.x_min, 'PASTDUE', 0, NULL, 'true', v_returnflag,v_returnMsg);
            END IF;
         END IF;
         -- DISABLE promotion group from group2esn
         -- CR4102 , CR3922
         FOR c2_rec IN (SELECT ROWID
                          FROM table_x_group2esn
                         WHERE groupesn2part_inst = c1_rec.esnobjid
                           AND groupesn2x_promo_group IN (SELECT objid
                                                            FROM table_x_promotion_group
                                                           WHERE group_name IN ('90_DAY_SERVICE', '52020_GRP')))
         LOOP
            UPDATE table_x_group2esn u SET x_end_date = SYSDATE
            WHERE u.rowid = c2_rec.rowid;
            COMMIT;
         END LOOP;
         -- end CR4102
         COMMIT;
      END LOOP;
   END deactivate_past_due;
   --    PROCEDURE deactivate_past_due
   --    IS
   --       v_user                    TABLE_USER.objid%TYPE;
   --       v_returnflag              VARCHAR2(20);
   --       v_returnMsg               VARCHAR2(200);
   --       dpp_regflag               PLS_INTEGER;
   --       v_action                  VARCHAR2(50):= 'x_service_id is null in Table_site_part';
   --       v_procedure_name          VARCHAR2(50):= '.SERVICE_DEACTIVATION.DEACTIVATE_PAST_DUE';
   --       intCallTranObj            NUMBER := 0;
   --       blnOTAPending             BOOLEAN := FALSE;
   --
   --       CURSOR c1
   --       IS
   --          SELECT sp.objid site_part_objid, sp.x_service_id x_service_id,
   --                 sp.x_min x_min, ca.objid carrier_objid,
   --                 ir.inv_role2site site_objid, sp.serial_no x_esn,
   --                 ca.x_carrier_id x_carrier_id,
   --                 sp.site_objid cust_site_objid, pi.objid esnobjid,
   --                 sp.x_msid, pi.part_serial_no part_serial_no,pi.x_iccid,
   --                 pn.X_OTA_ALLOWED
   --            FROM TABLE_X_CARRIER ca,
   --                 TABLE_PART_INST pi2,
   --                 TABLE_INV_ROLE ir,
   --                 TABLE_INV_BIN ib,
   --                 TABLE_PART_INST pi,
   --                 TABLE_SITE_PART sp,
   --                 TABLE_MOD_LEVEL ml,
   --                 TABLE_PART_NUM pn
   --           WHERE ca.x_carrier_id NOT IN (SELECT e.x_carrier_id FROM X_EXCLUDED_PASTDUEDEACT e)
   --             AND ca.objid = pi2.part_inst2carrier_mkt
   --             AND pi2.x_domain = 'LINES'  -->CR3318  Removed initcap func
   --             AND pi2.part_serial_no = sp.x_min
   --             AND (pi2.x_port_in <> 1 or pi2.x_port_in is null)
   --             AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
   --             AND ib.objid = pi.part_inst2inv_bin
   --             AND ml.part_info2part_num = pn.objid
   --             AND pi.n_part_inst2part_mod = ml.objid
   --             AND pi.x_part_inst2site_part = sp.objid
   --             --CR3728
   --             AND sp.x_expire_dt BETWEEN TO_DATE ('02-JAN-1753', 'dd-mon-yyyy') AND (SYSDATE - 1)
   --             AND (sp.part_status) = 'Active'
   --             AND ROWNUM < 1500;
   --
   --      /** CR3905 - Added OTAPending cursor **/
   --      CURSOR c_chkOTAPend(c_esn in VARCHAR2)
   --      IS
   --       SELECT 'X' FROM TABLE_X_CALL_TRANS
   --       WHERE OBJID = (SELECT MAX(OBJID)
   --                        FROM TABLE_X_CALL_TRANS
   --                       WHERE x_service_id = c_esn)
   --         AND x_result = 'OTA PENDING'
   --         AND x_action_type = '6';
   --
   --      r_chkOTAPend c_chkOTAPend%ROWTYPE;
   --
   --    BEGIN
   --     DBMS_TRANSACTION.use_rollback_segment ('R08_BIG');
   --
   --     SELECT objid
   --     INTO v_user
   --     FROM TABLE_USER
   --     WHERE UPPER (login_name) = 'SA';
   --
   --     FOR c1_rec IN c1
   --     LOOP
   --
   --        blnOTAPending := FALSE;
   --
   --        /** CR3905 - Change boolean value if OTA found **/
   --        IF (c1_rec.X_OTA_ALLOWED = 'Y') THEN
   --            OPEN c_chkOTAPend(c1_rec.part_serial_no);
   --            FETCH c_chkOTAPend INTO r_chkOTAPend;
   --
   --            IF c_chkOTAPend%FOUND THEN
   --               blnOTAPending := TRUE;
   --            END IF;
   --
   --            CLOSE c_chkOTAPend;
   --        END IF;
   --
   --
   --        -- Check whether x_service_id is not null -- 10/13/03
   --
   --        IF (c1_rec.x_service_id IS NULL) THEN
   --
   --           UPDATE TABLE_SITE_PART
   --           SET    x_service_id = NVL(c1_rec.x_esn, c1_rec.part_serial_no)
   --           WHERE  objid = c1_rec.site_part_objid;
   --
   --           COMMIT;
   --        END IF;
   --
   --          --Autopay Program - Change made By TCS offshore Starts Here
   --          check_dpp_registered_prc (c1_rec.x_service_id, dpp_regflag);
   --
   --        IF dpp_regflag = 1
   --        THEN
   --
   --           --Insert into x_call_trans
   --           create_call_trans (
   --                c1_rec.site_part_objid,
   --                84,   --
   --                c1_rec.carrier_objid,
   --                c1_rec.site_objid,
   --                v_user,
   --                c1_rec.x_min,
   --                c1_rec.x_service_id,
   --                'PROTECTION PLAN BATCH',
   --                SYSDATE,
   --                NULL,
   --                'Monthly Payments',
   --                'PASTDUE',
   --                'Pending',
   --                c1_rec.x_iccid,
   --                intCallTranObj
   --             );
   --        ELSE
   --          IF NOT blnOTAPending THEN
   --             --CR3153 T-Mobile changes
   --             deactService(
   --               'PAST_DUE_BATCH',
   --               v_user,
   --               c1_rec.x_service_id,
   --               c1_rec.x_min,
   --               'PASTDUE',
   --               0,
   --               null,
   --               'true',
   --               v_returnflag,
   --               v_returnMsg);
   --          END IF;
   --        END IF;
   --
   --        -- DISABLE promotion group from group2esn
   --        -- CR4102 , CR3922
   --        FOR c2_rec in (select rowid from table_x_group2esn
   --                       where groupesn2part_inst = c1_rec.esnobjid
   --                       AND groupesn2x_promo_group in
   --                       (SELECT objid FROM table_x_promotion_group
   --                       WHERE group_name in ('90_DAY_SERVICE','52020_GRP')))
   --        LOOP
   --           UPDATE table_x_group2esn u
   --           set x_end_date = sysdate
   --           where u.rowid = c2_rec.rowid;
   --           COMMIT;
   --        END LOOP;
   --        -- end CR4102
   --
   --     END LOOP;
   --    END deactivate_past_due;
   --EME_080505 Ends
   /*****************************************************************************/
   /*                                                                           */
   /* Name:     deactivate_airtouch                                             */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   PROCEDURE deactivate_airtouch
   IS
   v_user TABLE_USER.objid%TYPE;
   v_count NUMBER := 1;
   v_deact_count NUMBER;
   intCallTranObj NUMBER := 0;
   v_returnflag VARCHAR2(20);
   v_returnMsg VARCHAR2(200);
   CURSOR c1
   IS
   SELECT sp.objid site_part_objid,
          sp.x_service_id x_service_id,
          sp.x_min x_min,
          ca.objid carrier_objid,
          ir.inv_role2site site_objid,
          ca.x_carrier_id x_carrier_id,
          sp.site_objid cust_site_objid,
          sp.x_msid,
          pi.x_iccid
     FROM TABLE_X_CARRIER ca,
          TABLE_PART_INST pi2,
          TABLE_INV_ROLE ir,
          TABLE_INV_BIN ib,
          TABLE_PART_INST pi,
          TABLE_SITE_PART sp
    WHERE ca.x_carrier_id IN (100002, 110002, 120002)
      AND pi2.part_inst2carrier_mkt = ca.objid
      AND pi2.x_domain = 'LINES'
      AND sp.x_min = pi2.part_serial_no
      AND ib.inv_bin2inv_locatn = ir.inv_role2inv_locatn
      AND pi.part_inst2inv_bin = ib.objid
      AND sp.objid = pi.x_part_inst2site_part
      AND sp.x_expire_dt BETWEEN TO_DATE ('02-JAN-1753', 'dd-mon-yyyy')
      AND (SYSDATE - 1)
      AND sp.part_status = 'Active'
      ORDER BY sp.x_expire_dt;
   BEGIN
      SELECT COUNT (*) - 10199
      INTO v_deact_count
      FROM TABLE_SITE_PART sp,
           TABLE_PART_INST pi,
           TABLE_X_CARRIER ca
     WHERE ca.x_carrier_id IN (100002, 110002, 120002)
       AND pi.part_inst2carrier_mkt = ca.objid
       AND pi.x_domain || '' = 'LINES'
       AND sp.x_min = pi.part_serial_no
       AND sp.part_status || '' = 'Active';
      DBMS_OUTPUT.put_line ('deact_count: ' || TO_CHAR (v_deact_count));

      IF v_deact_count > 0
      THEN
         SELECT objid
         INTO v_user
         FROM TABLE_USER
         WHERE UPPER (login_name) = 'SA';
         FOR c1_rec IN c1
         LOOP
            --CR3153 T-Mobile changes
            deactService('PAST_DUE_BATCH', v_user, c1_rec.x_service_id, c1_rec.x_min,
                         'PASTDUE', 0, NULL, 'true', v_returnflag, v_returnMsg);
            v_count := v_count + 1;
            IF v_count = v_deact_count
            THEN
               EXIT;
            END IF;
         END LOOP;
      END IF;
   END deactivate_airtouch;

   /*****************************************************************************/
   /*                                                                           */
   /* Name:     deact_road_past_due                                             */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   --VAdapa on 02/13/02 to deactivate expired ROADSIDE cards
   PROCEDURE deact_road_past_due
   IS
      CURSOR c_site_part
      IS
      SELECT sp.objid site_part_objid,
         sp.x_service_id x_service_id,
         x_iccid
      FROM TABLE_SITE_PART sp
      WHERE sp.x_expire_dt BETWEEN TO_DATE ('02-JAN-1753', 'dd-mon-yyyy')
      AND (SYSDATE - 1)
      AND instance_name = 'ROADSIDE'
      AND sp.part_status || '' = 'Active'
      AND ROWNUM < 1001;
      CURSOR c_road_inst(
         c_ip_ser_id IN VARCHAR2
      )
      IS
      SELECT *
      FROM TABLE_X_ROAD_INST
      WHERE x_red_code = c_ip_ser_id;
      r_road_inst c_road_inst%ROWTYPE;
      v_user TABLE_USER.objid%TYPE;
      v_action VARCHAR2 (4000);
      v_service_id VARCHAR2 (20);
      v_road_hist_seq NUMBER; -- 06/09/03
      intCallTranObj NUMBER := 0;
   BEGIN
      SELECT objid
      INTO v_user
      FROM TABLE_USER
      WHERE UPPER (login_name) = 'SA';
      FOR r_site_part IN c_site_part
      LOOP
         BEGIN
            v_service_id := r_site_part.x_service_id;
            v_action := 'UPDATE TABLE_X_ROAD_HIST';
            UPDATE TABLE_X_ROAD_INST SET x_part_inst_status = '47',
            rd_status2x_code_table = 2144, x_hist_update = 1
            WHERE x_red_code = r_site_part.x_service_id;
            OPEN c_road_inst (r_site_part.x_service_id);
            FETCH c_road_inst
            INTO r_road_inst;
            CLOSE c_road_inst;
            v_action := 'INSERT INTO TABLE_X_ROAD_HIST';
            Sp_seq('x_road_hist', v_road_hist_seq); -- 06/09/03
            INSERT
            INTO TABLE_X_ROAD_HIST(
               objid,
               x_part_serial_no,
               x_part_mod,
               x_part_bin,
               x_warr_end_date,
               x_part_status,
               x_insert_date,
               x_creation_date,
               x_po_num,
               x_domain,
               x_part_inst_status,
               x_change_date,
               x_change_reason,
               x_last_trans_time,
               x_transaction_id,
               x_repair_date,
               x_pick_request,
               x_order_number,
               x_road_hist2inv_bin,
               x_road_hist2part_mod,
               x_road_hist2road_inst,
               x_road_hist2user,
               road_hist2x_code_table,
               x_road_hist2site_part
            )VALUES(
               -- 04/10/03 seq_x_road_hist.nextval + POWER (2, 28),
               -- seq('x_road_hist'),
               v_road_hist_seq,
               r_road_inst.part_serial_no,
               r_road_inst.part_mod,
               r_road_inst.part_bin,
               r_road_inst.warr_end_date,
               r_road_inst.part_status,
               r_road_inst.x_insert_date,
               r_road_inst.x_creation_date,
               r_road_inst.x_po_num,
               r_road_inst.x_domain,
               '47',
               SYSDATE,
               'PASTDUE',
               SYSDATE,
               r_road_inst.transaction_id,
               r_road_inst.repair_date,
               NULL,
               r_road_inst.x_order_number,
               r_road_inst.road_inst2inv_bin,
               r_road_inst.n_road_inst2part_mod,
               r_road_inst.objid,
               r_road_inst.rd_create2user,
               2144,
               r_road_inst.x_road_inst2site_part
            );
            v_action := 'INSERT INTO TABLE_X_CALL_TRANS';
            create_call_trans ( r_site_part.site_part_objid, 11, NULL, -- carrier objid
            NULL, -- dealer objid
            v_user, NULL, -- MIN value
            r_site_part.x_service_id, 'ROAD_PASTDUE_BATCH', SYSDATE, NULL,
            'Cancellation', 'PASTDUE', 'Completed', r_site_part.x_iccid,
            intCallTranObj );
            v_action := 'UPDATE TABLE_SITE_PART';
            UPDATE TABLE_SITE_PART SET part_status = 'Inactive', service_end_dt
            = SYSDATE, x_deact_reason = 'PASTDUE'
            WHERE objid = r_site_part.site_part_objid;
            COMMIT;
            EXCEPTION
            WHEN OTHERS
            THEN
               Toss_util_pkg.Insert_error_tab_proc ( 'Inner BLOCK : ' ||
               v_action, v_service_id, 'ROAD_PASTDUE' );
         END;
      END LOOP;
      COMMIT;
      EXCEPTION
      WHEN OTHERS
      THEN
         Toss_util_pkg.Insert_error_tab_proc (v_action, NULL, 'ROAD_PASTDUE');
   END deact_road_past_due;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:     deactivate_any                                                  */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
   PROCEDURE deactivate_any(
      ip_esn IN VARCHAR2,
      ip_reason IN VARCHAR2,
      ip_caller_program IN VARCHAR2,
      ip_result IN OUT PLS_INTEGER
   )
   AS
      v_user TABLE_USER.objid%TYPE;
      v_procedure_name VARCHAR2 (80) := v_package_name || '.DEACTIVATE_ANY()';
      v_action VARCHAR2 (4000);
      v_service_id VARCHAR2 (20);
      intCallTranObj NUMBER := 0;
      v_returnflag VARCHAR2(20);
      v_returnMsg VARCHAR2(200);
      CURSOR c1
      IS
      SELECT sp.objid site_part_objid,
             sp.x_service_id x_service_id,
             sp.x_min x_min,
             ca.objid carrier_objid,
             ir.inv_role2site site_objid,
             sp.serial_no x_esn,
             ca.x_carrier_id x_carrier_id,
             sp.site_objid cust_site_objid,
             pi.objid esnobjid,
             sp.x_msid,
             pi2.x_port_in,
             pi.x_iccid
        FROM TABLE_X_CARRIER ca,
             TABLE_PART_INST pi2,
             TABLE_INV_ROLE ir,
             TABLE_INV_BIN ib,
             TABLE_PART_INST pi,
             TABLE_SITE_PART sp
       WHERE ca.objid = pi2.part_inst2carrier_mkt
         AND pi2.x_domain = 'LINES' -->CR3318  Removed initcap func
         AND pi2.part_serial_no = sp.x_min
         AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
         AND ib.objid = pi.part_inst2inv_bin
         AND pi.x_part_inst2site_part = sp.objid
         AND (sp.part_status) = 'Active'
         AND sp.x_service_id = ip_esn;
   BEGIN
      SELECT objid
      INTO v_user
      FROM TABLE_USER
      WHERE UPPER (login_name) = 'SA';
      BEGIN
         FOR c1_rec IN c1
         LOOP
-----------------------------------------------------------------------------------------
            --new code for refurb phone for ported phone numbers
            -----------------------------------------------------------------------------------------
            DBMS_OUTPUT.put_line('c1_rec.x_port_in:'||c1_rec.x_port_in);
            IF c1_rec.x_port_in = 1
            THEN
               DBMS_OUTPUT.put_line('inside c1_rec.x_port_in:start');
               create_call_trans (c1_rec.site_part_objid, 20, c1_rec.carrier_objid,
                                  c1_rec.site_objid, v_user, c1_rec.x_min, c1_rec.x_service_id,
                                  ip_reason, SYSDATE, NULL, 'PORTED DEACT PENDING', ip_reason,
                                  'Completed', c1_rec.x_iccid, intCallTranObj );
               ip_result := 0;
               Toss_util_pkg.Insert_error_tab_proc ( 'X_PORT_IN = 1', c1_rec.x_service_id, v_procedure_name );
               DBMS_OUTPUT.put_line('inside c1_rec.x_port_in:exit');
               EXIT;
            END IF;
            -----------------------------------------------------------------------------------------
            v_service_id := c1_rec.x_service_id;
            v_action := 'Deactivating service';
            --CR3153 T-Mobile changes
            deactService(UPPER(ip_reason), v_user, c1_rec.x_service_id, c1_rec.x_min,
                         UPPER(ip_reason), 0, NULL, 'true', v_returnflag, v_returnMsg);
            ip_result := 1;
         END LOOP;
         EXCEPTION
         WHEN OTHERS
         THEN

            /** FAILURE POINT **/
            ip_result := 0;
            Toss_util_pkg.Insert_error_tab_proc ( 'Inner BLOCK : ' || v_action,v_service_id, v_procedure_name );
      END; -- of inner block (for loop block)
      EXCEPTION
      WHEN OTHERS
      THEN
         /** FAILURE POINT **/
         ip_result := 0;
         Toss_util_pkg.Insert_error_tab_proc ( v_action, NVL (v_service_id,'N/A'), v_procedure_name );
   END deactivate_any;


   /***********************************************************************************/
   /*
   /* Name: deactService
   /* Description: Ends carrier service for an ESN/MIN combination. Translated
   /*              from TFLinePart.java in the DeactivateService and
   /*              DeactivateGSMService method.
   /***********************************************************************************/
   PROCEDURE deactService(
      ip_sourcesystem IN VARCHAR2,
      ip_userObjId    IN VARCHAR2,
      ip_esn          IN VARCHAR2,
      ip_min          IN VARCHAR2,
      ip_DeactReason  IN VARCHAR2,
      intByPassOrderType IN NUMBER,
      ip_newESN       IN VARCHAR2,
      ip_samemin      IN VARCHAR2,
      op_return      OUT VARCHAR2,
      op_returnMsg   OUT VARCHAR2
   )
   IS
   CURSOR cur_ph
   IS
   SELECT a.*,
          c.x_technology,
          NVL(c.x_restricted_use, 0) x_restricted_use,
          e.objid siteObjid,
          f.x_notify_carrier,
          f.objid SitePartObjid,
          f.x_service_id,
          f.x_min,
          f.install_date,
          f.site_part2x_new_plan,
          f.site_part2x_plan
     FROM table_part_inst a,
          table_mod_level b,
          table_part_num c,
          table_inv_bin d,
          table_site e,
          table_site_part f
    WHERE a.x_part_inst2site_part = f.objid
      AND d.bin_name = e.site_id
      AND a.part_inst2inv_bin = d.objid
      AND b.part_info2part_num = c.objid
      AND a.n_part_inst2part_mod = b.objid
      AND a.x_part_inst_status = DECODE(ip_DeactReason, 'SENDCARRDEACT', a.x_part_inst_status, '52')
      AND a.part_serial_no = ip_esn
      AND a.x_domain = 'PHONES';
   rec_ph cur_ph%ROWTYPE;
   -------------------------------------------------------
   CURSOR cur_newESN(c_newESN IN VARCHAR2)
   IS
   SELECT objid
     FROM table_part_inst
    WHERE part_serial_no = LTRIM(RTRIM(c_newESN));
   rec_newESN cur_newESN%ROWTYPE;
   -------------------------------------------------------
   CURSOR cur_min(c_min IN VARCHAR2)
   IS
   SELECT objid,
          part_serial_no,
          part_inst2carrier_mkt,
          x_port_in,
          x_part_inst_status,
          x_npa,
          x_nxx,
          x_ext
     FROM table_part_inst
    WHERE part_serial_no = c_min
      AND x_domain = 'LINES';
   rec_min cur_min%ROWTYPE;
   -------------------------------------------------------
   CURSOR curremovePromo(c_esnobjid IN NUMBER)
   IS
   SELECT * FROM table_x_group2esn
    WHERE groupesn2x_promo_group IN (SELECT objid
                                       FROM table_x_promotion_group
                                      WHERE group_name IN ('TFU', 'ANNUALPLAN')
                                     )
      AND groupesn2part_inst = c_esnobjid;
   -------------------------------------------------------
   CURSOR currCarrierRules(c_carrierObjid IN NUMBER, c_tech in varchar2)
   IS
   SELECT b.*
     FROM table_x_carrier a, table_x_carrier_rules b
    WHERE DECODE(c_tech,'GSM',a.carrier2rules_GSM, -- CR4579
                        'TDMA',a.carrier2rules_TDMA,
                        'CDMA',a.carrier2rules_CDMA,
                               a.carrier2rules) = b.objid
      AND a.objid = c_carrierObjid;

   recCarrierRules currCarrierRules%ROWTYPE;
   -------------------------------------------------------
   CURSOR currDeactCode(c_DeactReason IN VARCHAR2,
                        c_DeactType IN VARCHAR2)
   IS
   SELECT *
     FROM table_x_code_table
    WHERE x_code_name = c_DeactReason
      AND x_code_type = c_DeactType;
   recDeactCode currDeactCode%ROWTYPE;
   -------------------------------------------------------
   CURSOR currStatCode(c_statCode IN VARCHAR2,
                       c_codeType IN VARCHAR2)
   IS
   SELECT *
     FROM table_x_code_table
    WHERE x_code_number = c_statCode
      AND x_code_type = c_codeType;

   recPhStatCode currStatCode%ROWTYPE;
   recLineStatCode currStatCode%ROWTYPE;
   -------------------------------------------------------
   CURSOR CurrReservedMIN(c_esnObjid IN NUMBER)
   IS
   SELECT *
     FROM TABLE_PART_INST
    WHERE X_DOMAIN = 'LINES'
      AND PART_STATUS = 'Active'
      AND PART_TO_ESN2PART_INST = c_esnObjid
      AND x_part_inst_status = '38'; -- Reserved AC
   -------------------------------------------------------
   CURSOR c_max_esn_exists(c_ip_esn IN VARCHAR2)
   IS
   SELECT 'X'
     FROM table_x_zero_out_max
    WHERE x_esn = c_ip_esn
      AND x_reac_date_time IS NULL;
   r_max_esn_exists c_max_esn_exists%ROWTYPE;
   -------------------------------------------------------
   /***** CR4245 - ILD *********/
   CURSOR c_ota_features(c_ip_esn IN VARCHAR2)
   IS
   SELECT 'X'
     FROM table_x_ota_features
    WHERE x_ota_features2part_inst =
          (SELECT objid
             FROM table_part_inst
            WHERE part_serial_no = c_ip_esn)
      AND x_ild_carr_status = 'Active';

   /***** CR4245 - ILD *********/

   blnStart         BOOLEAN := FALSE;
   blnOld           BOOLEAN := FALSE;
   blnFound         BOOLEAN := TRUE;
   blnGSM           BOOLEAN := FALSE;
   blnWritePiHist   BOOLEAN;
   intReactflag     NUMBER := 0;
   intPortIn        NUMBER := 0;
   intDeactCode     NUMBER := 0;
   intCallTranObj   NUMBER := 0;
   intStatCode      NUMBER := 0;
   intActItemObj    NUMBER := 0;
   intOrdTypeObj    NUMBER := 0;
   intBlackOutCode  NUMBER := 0;
   intDummy         NUMBER := 0;
   intLnRetDays     NUMBER := 0;
   intCoolingPeriod NUMBER := 0;
   intUsedLnExDays  NUMBER := 0;
   intMinAge        NUMBER := 0;
   intBlackOut      NUMBER := 0;
   intTransMethod   NUMBER := 0;
   intGrpHistSeq    NUMBER := 0;
   intNotifycarr    NUMBER := 0;
   intNewESN        NUMBER := 0;
   intGSMGracePeriod NUMBER := 0;
   strESNCode       VARCHAR2(30) := '';
   strDeactType     VARCHAR2(30) := '';
   strRetTemp       VARCHAR2(200):= '';
   strSQLErrm       VARCHAR2(100);
   v_DeactReason    VARCHAR2(30);
   v_action         VARCHAR2(4000);
   v_DeactType      VARCHAR2(10) := ' ';
   v_simStat table_x_code_table.x_code_number%TYPE;
   v_simStatObjid table_x_code_table.objid%TYPE;
   e_deact_exception EXCEPTION;
   v_expireMinutes NUMBER := 0;
   v_procedure_name VARCHAR2 (80) := v_package_name || '.DEACTSERVICE()';

   TYPE Call_Trans IS
   TABLE OF table_x_ota_transaction.x_ota_trans2x_call_trans%TYPE;

   v_Call_Trans Call_Trans;

   --CR4245 Starts
   strILDerrNum VARCHAR2(20);
   strILDerrStr VARCHAR2(200);
   --CR4245 Ends
   BEGIN
      v_DeactReason := ip_DeactReason;
      v_action := 'Getting phone info';

      OPEN cur_ph;
      FETCH cur_ph
      INTO rec_ph;

      IF cur_ph%NOTFOUND
      THEN
         CLOSE cur_ph;
         op_returnMsg := 'ESN/IMEI is not Valid';
         RAISE e_deact_exception;
      ELSE
         CLOSE cur_ph;
      END IF;

      IF(rec_ph.x_part_inst2contact IS NULL)
      THEN
         op_returnMsg := 'Contact Information Can Not be Found';
         RAISE e_deact_exception;
      END IF;

      IF(rec_ph.siteobjid IS NULL)
      THEN
         op_returnMsg :=
         'Dealer not found for the Phone.  Line not Deactivated.';
         RAISE e_deact_exception;
      END IF;

      IF(rec_ph.SitePartObjid IS NULL)
      THEN
         op_returnMsg := 'Site_Part info not found';
         RAISE e_deact_exception;
      END IF;

      /* Initializing GSM boolean flag */
      IF(rec_ph.x_technology = 'GSM')
      THEN
         blnGSM := TRUE;
      ELSE
         blnGSM := FALSE;
      END IF;
      IF (blnGSM)
      THEN
         IF(rec_ph.x_iccid
         IS
         NULL)
         THEN
            op_returnMsg := 'SIM Record Can Not Be Located';
            RAISE e_deact_exception;
         END IF;
      END IF;
      v_action := 'Getting line info';
      OPEN cur_min(ip_min);
      FETCH cur_min
      INTO rec_min;
      IF cur_min%NOTFOUND
      THEN
         CLOSE cur_min;
         op_returnMsg := 'MIN is not Valid';
         RAISE e_deact_exception;
      ELSE
         CLOSE cur_min;
      END IF;

      /***** CR4245 - ILD *********/
      FOR ota_features_rec IN c_ota_features(rec_ph.part_serial_no)
      LOOP
         sa.sp_ild_transaction(rec_min.part_serial_no, 'ILD_DEACT', '',
         strILDerrNum, strILDerrStr);
      END LOOP;
      /***** End of CR4245  ********/


      /****** CR4478 - ILD *********/
      FOR c2_rec IN (SELECT a.rowid
                       FROM sa.table_x_psms_outbox a
                      WHERE x_esn = rec_ph.part_serial_no
                        AND x_status = 'Pending')
      LOOP
         UPDATE sa.table_x_psms_outbox
            SET x_status = 'Cancelled',
                x_last_update = SYSDATE
          WHERE ROWID = c2_rec.rowid;
         COMMIT;
      END LOOP;

      FOR c3_rec in (SELECT b.rowid
                       FROM sa.table_x_ota_features b
                      WHERE x_ota_features2part_inst = rec_ph.objid
                        AND x_ild_prog_status = 'InQueue')
      LOOP
         UPDATE sa.table_x_ota_features
            SET x_ild_account = null,
                x_ild_carr_status = 'Inactive',
                x_ild_prog_status = 'Pending'
          WHERE x_ota_features2part_inst = rec_ph.objid
            AND ROWID = c3_rec.rowid;
      END LOOP;
      /****** End of CR4478 *********/


      IF (SUBSTR(v_DeactReason, 1, 3) = 'SIM')
      THEN
         blnStart := TRUE;
         v_DeactReason := 'SIM DAMAGE';
      END IF;

      v_action := 'Getting carrier rule info';
      OPEN currCarrierRules(rec_min.part_inst2carrier_mkt, rec_ph.x_technology); -- CR4579
      FETCH currCarrierRules
      INTO recCarrierRules;

      /* Initializing carrier rule variables */
      IF currCarrierRules%Found
      THEN
         intLnRetDays := recCarrierRules.x_line_return_days;
         intCoolingPeriod := recCarrierRules.x_cooling_period;
         intUsedLnExDays := recCarrierRules.x_used_line_expire_days;
         intGSMGracePeriod := recCarrierRules.x_gsm_grace_period;
      ELSE
         blnFound := FALSE;
      END IF;
      CLOSE currCarrierRules;

      /*  Get GSM SIM Deactivation Type if reason applies */
      OPEN currDeactCode(v_DeactReason, 'DANEW');
      FETCH currDeactCode
      INTO recDeactCode;

      IF currDeactCode%found
      THEN
         v_DeactType := recDeactCode.x_code_type;
      END IF;
      CLOSE currDeactCode;

      /* Checking if GSM */
      IF (blnGSM)
      THEN
         IF(v_DeactReason = 'SIM DAMAGE')
         THEN
            OPEN currDeactCode('SIM EXPIRED', 'SIM');
            FETCH currDeactCode
            INTO recDeactCode;
            CLOSE currDeactCode;

         -- CR3318 Sets SIM back to NEW if deact=NON TOPP LINE
         ELSIF (v_DeactReason = 'NON TOPP LINE')
         THEN
            OPEN currDeactCode('SIM NEW', 'SIM');
            FETCH currDeactCode
            INTO recDeactCode;
            CLOSE currDeactCode;
         ELSIF (v_DeactType = 'DANEW')
         THEN
-- Added for CR3667
            OPEN currDeactCode('SIM VOID', 'SIM');
            FETCH currDeactCode
            INTO recDeactCode;
            CLOSE currDeactCode;
         ELSE
            OPEN currDeactCode('SIM RESERVED', 'SIM');
            FETCH currDeactCode
            INTO recDeactCode;
            CLOSE currDeactCode;
         END IF;
         v_simStat := recDeactCode.x_code_number;
         v_simStatObjid := recDeactCode.objid;
      ELSE
         -- CR4478 - Reserves line for 7 days
      	 IF (intByPassOrderType = 2) and (ip_samemin = 'true') THEN
           intGSMGracePeriod := 7;
         ELSE
           intGSMGracePeriod := 0;
         END IF;
      END IF;

      /* Gets the age of the line difference of sysdate and activationDate */
      SELECT SYSDATE - rec_ph.install_date
      INTO intMinAge
      FROM dual;

      /* Setting flag to determine if line is old */
      IF(blnFound)
      THEN
         blnOld := FALSE;
         IF(intLnRetDays = 0)
         THEN
            blnOld := FALSE;
         ELSIF(intLnRetDays = 1)
         THEN
            blnOld := TRUE;
         ELSIF (intMinAge > intLnRetDays)
         THEN
            blnOld := TRUE;
         END IF;
      END IF;

      IF(rec_min.x_port_in IS NOT NULL)
      THEN
         intPortIn := rec_min.x_port_in;
      END IF;

      --Modified for CR3327 - Add x_port_in = 2 -These lines should also be returned.
      IF(intPortIn = 1
      OR intPortIn = 2)
      THEN
         blnOld := TRUE;
      END IF;


      /**** Start of Logic that sets the status to the Current Line and Reserved Line ****/
      IF(blnOld)
      THEN
         IF(rec_min.x_part_inst_status = '34')
         THEN

            /* Updates the line that is under Reserved AC status */
            v_action := 'Getting reserved line info';
            FOR recReservedMin IN CurrReservedMIN(rec_ph.objid)
            LOOP
               OPEN currDeactCode('AC VOIDED', 'LS');
               FETCH currDeactCode
               INTO recDeactCode;
               CLOSE currDeactCode;

               v_action := 'Updating status of reserved line';
               UPDATE table_part_inst
                  SET x_part_inst_status = recDeactCode.x_code_number,
                      status2x_code_table = recDeactCode.objid
                WHERE objid = recReservedMin.objid;

               v_action := 'Updating account_hist of reserved line';
               UPDATE table_x_account_hist
                  SET x_end_date = SYSDATE
                WHERE account_hist2part_inst = recReservedMin.OBJID
                  AND (x_end_date IS NULL
                   OR x_end_date = TRUNC(TO_DATE('01/01/1753', 'MM/DD/YYYY')));
               COMMIT;

               IF WritePIHistory(ip_userObjId, recReservedMin.part_serial_no,
                                 rec_min.x_npa, rec_min.x_nxx, rec_min.x_ext,
                                 'DEACTIVATE',rec_ph.x_iccid) = 1
               THEN
                  blnWritePiHist := TRUE;

               ELSE
                  blnWritePiHist := FALSE;

               END IF;

            END LOOP;
         END IF;

         /*Intializing recDeactCode with 'Returned' stat */
         OPEN currDeactCode('RETURNED', 'LS');
         FETCH currDeactCode
         INTO recDeactCode;
         CLOSE currDeactCode;
         /*** Check if GSM ***/
         /*** CR3353 Added v_DeactType to check reason type passed in ***/
         /*** CR3647 - Added MINCHANGE reason. Line should be returned for MIN Change **/
         /*** CR4579 - Added RETURNMIN to return GSM lines deactivated by ReleasedReservedMIN pro **/
         IF (blnGSM)
          AND (v_DeactType <> 'DANEW')
          AND (v_DeactReason <> 'MINCHANGE')
          AND (ip_samemin <> 'RETURNMIN')
         THEN

            --CR3327 - Return Internal Port In lines
            IF NOT (blnStart)
            AND intPortIn != 2
            THEN
               OPEN currDeactCode('RESERVED USED', 'LS'); --CR3971
               FETCH currDeactCode
               INTO recDeactCode;
               CLOSE currDeactCode;
            END IF;
         END IF;
         IF recDeactCode.x_code_name = 'RETURNED'
         THEN

            /*** End Account to line that is under (Pending AC change) status  ***/
            v_action := 'Updating account_hist of current line';

            UPDATE table_x_account_hist
               SET x_end_date = SYSDATE
             WHERE account_hist2part_inst = rec_min.objid
               AND (x_end_date IS NULL
                OR  x_end_date = TRUNC(TO_DATE('01/01/1753', 'MM/DD/YYYY')));
            COMMIT;
         END IF;

         /** CR3318 Final Check for OLD Line ***/
         /** If Reason = Non Tracfone Line Then update line status to=NTN ***/
         IF v_DeactReason = 'NON TOPP LINE'
         THEN

            /*Intializing recDeactCode with 'NTN' stat */
            OPEN currDeactCode('NTN', 'LS');
            FETCH currDeactCode
            INTO recDeactCode;
            CLOSE currDeactCode;
         END IF;
      ELSE /* If not old */
         IF (rec_min.x_part_inst_status = '34')
         THEN
            FOR recReservedMin IN CurrReservedMIN(rec_ph.objid)
            LOOP

               /* Sets recDeactCode to status of used */
               OPEN currDeactCode('USED', 'LS');
               FETCH currDeactCode
               INTO recDeactCode;
               CLOSE currDeactCode;

               v_action := 'Updating status of reserved line';
               UPDATE table_part_inst
                  SET x_part_inst_status = recDeactCode.x_code_number,
                      status2x_code_table = recDeactCode.objid,
                      x_cool_end_date = DECODE(intCoolingPeriod, 0, x_cool_end_date, SYSDATE +intCoolingPeriod)
                WHERE objid = recReservedMin.objid;
               COMMIT;

               IF WritePIHistory(ip_userObjId, recReservedMin.part_serial_no,
                                 rec_min.x_npa, rec_min.x_nxx, rec_min.x_ext,
                                 'DEACTIVATE',rec_ph.x_iccid) = 1
               THEN
                  blnWritePiHist := TRUE;

               ELSE
                  blnWritePiHist := FALSE;

               END IF;
            END LOOP;
            /*Intializing recDeactCode with 'AC returned' stat */
            OPEN currDeactCode('AC RETURNED', 'LS');
            FETCH currDeactCode
            INTO recDeactCode;
            CLOSE currDeactCode;
         ELSE

            /** CR3318 Set status for Non Tracfone Number ***/
            IF v_DeactReason = 'NON TOPP LINE'
            THEN

               /*Intializing recDeactCode with 'NTN' stat */
               OPEN currDeactCode('NTN', 'LS');
               FETCH currDeactCode
               INTO recDeactCode;
               CLOSE currDeactCode;

            /*CR3647 - Starts Return line for a MIN change*/
            ELSIF v_DeactReason = 'MINCHANGE'
            THEN

               /*Intializing recDeactCode with 'NTN' stat */
               OPEN currDeactCode('RETURNED', 'LS');
               FETCH currDeactCode
               INTO recDeactCode;
               CLOSE currDeactCode;

            /*CR3647 - Ends*/
            ELSE

               /*Intializing recDeactCode with 'USED' stat */
               OPEN currDeactCode('USED', 'LS');
               FETCH currDeactCode
               INTO recDeactCode;
               CLOSE currDeactCode;
            END IF;
         END IF;
         --CR3353 Added v_DeactType to check reason type passed in
         --CR3647 - Leave status Returned for MINCHANGE
         IF (blnGSM
            AND v_DeactReason <> 'ACTIVE UPGRADE'
            AND v_DeactReason <> 'NON TOPP LINE'
            AND v_DeactType <> 'DANEW'
            AND v_DeactReason <> 'MINCHANGE')
         THEN
            IF (blnStart) or (ip_samemin = 'RETURNMIN') -- CR4579
            THEN

               /*Intializing recDeactCode with 'RETURNED' stat */
               OPEN currDeactCode('RETURNED', 'LS');
               FETCH currDeactCode
               INTO recDeactCode;
               CLOSE currDeactCode;
            ELSE
               OPEN currDeactCode('RESERVED USED', 'LS'); --CR3971
               FETCH currDeactCode
               INTO recDeactCode;
               CLOSE currDeactCode;
            END IF;
         END IF;
      END IF;
      /**** END of Logic that sets the status to the Current Line and Reserved Line ****/



      --CR3153 - T-Mobile Changes
      IF (SUBSTR(rec_ph.x_min, 1, 1) = 'T')
      THEN
         OPEN currDeactCode('DELETED', 'LS');
         FETCH currDeactCode
         INTO recDeactCode;
         CLOSE currDeactCode;
      END IF;
      --CR3153 - End T-Mobile Changes
      /***Checks if a new ESN is passed in ****/
      IF (LENGTH(ip_newESN) >= 11
        AND ip_samemin = 'true')
      THEN
      --CR3200
         /* If new line status is not "AC RETURNED" OR "RETURNED" */
         -- CR3209 Commented Out IF (recDeactCode.x_code_number not in ('35','17')) THEN
         OPEN cur_newESN(ip_newESN);
         FETCH cur_newESN
         INTO rec_newESN;
         IF cur_newESN%FOUND
         THEN
            OPEN currDeactCode('RESERVED USED', 'LS');
            FETCH currDeactCode
            INTO recDeactCode;
            CLOSE currDeactCode;
            intNewESN := 1;
         END IF;
         CLOSE cur_newESN;

      -- END IF;
      END IF;

      /*** Updates line that is getting deactivated  ***/
      v_action := 'Updating part_inst of current line';
      UPDATE table_part_inst
         SET x_part_inst_status   = recDeactCode.x_code_number,
             status2x_code_table  = recDeactCode.objid,
             x_cool_end_date      = DECODE(intCoolingPeriod, 0, x_cool_end_date, SYSDATE + intCoolingPeriod),
             warr_end_date        = DECODE(intUsedLnExDays, 0, TO_DATE('01/01/1753','mm/dd/yyyy'), SYSDATE + intUsedLnExDays),
             last_trans_time      = SYSDATE,
             repair_date          = DECODE(intNewESN, 1, SYSDATE, repair_date),
             part_inst2x_pers     = DECODE(part_inst2x_new_pers, NULL, part_inst2x_pers, part_inst2x_new_pers),
             part_inst2x_new_pers = NULL,
             part_to_esn2part_inst= DECODE(intNewESN, 1, rec_newESN.objid, part_to_esn2part_inst),
             last_cycle_ct        = SYSDATE + intGSMGracePeriod,
             x_port_in            = DECODE(ip_samemin, 'true', intPortIn, (DECODE(intPortIn, 2, 0, intPortIn))) --CR3327-1
       WHERE objid = rec_min.objid;
      COMMIT;

      /*** Updates current active site_part record **/
      IF blnOld
      THEN
         intNotifycarr := 1;
      ELSE
         intNotifycarr := 0;
      END IF;

      v_action := 'Updating active site_part to inactive';

      UPDATE table_site_part
         SET service_end_dt = SYSDATE,
             x_deact_reason = v_DeactReason,
             x_notify_carrier = intNotifycarr,
             part_status = DECODE(ip_DeactReason, 'SENDCARRDEACT', part_status,'Inactive'),
             site_part2x_new_plan = NULL
       WHERE objid = rec_ph.SitePartobjid;

      /*** Create call_trans record ***/
      v_action := 'Creating a call trans record';
      CREATE_CALL_TRANS( rec_ph.SitePartObjid, 2, rec_min.part_inst2carrier_mkt,
                         rec_ph.siteObjid, ip_userObjId, rec_ph.x_min,
                         rec_ph.x_service_id, ip_sourcesystem, -- should come in as "WEBCSR" if called from "WEBCSR"
                         SYSDATE, NULL, NULL, v_DeactReason, 'Completed',
                         rec_ph.x_iccid,intCallTranObj );

      /* If GSM update sim inventory table */
      IF (blnGSM)
      THEN

         -- Updating table_x_sim_inv
         v_action := 'Updating SIM information';
         UPDATE table_x_sim_inv
            SET x_sim_inv_status = v_simStat,
                X_SIM_STATUS2X_CODE_TABLE = v_simStatObjid
          WHERE X_SIM_SERIAL_NO = rec_ph.x_iccid;
         COMMIT;
      END IF;
      /* Get deactivation reason code */
      OPEN currDeactCode(v_DeactReason, 'DA');
      FETCH currDeactCode
      INTO recDeactCode;
      CLOSE currDeactCode;
      IF recDeactCode.x_value = 2
      THEN
         intReactflag := 1;
      ELSE
         intReactflag := 0;
      END IF;

      intDeactCode := recDeactCode.x_code_number;
      /* CR3190 initialize v_expireMinute by certain DeactCodes */
      IF intDeactCode = 21
      THEN
         strESNCode := '53';
         v_expireMinutes := 1;
      ELSIF intDeactCode = 22
      THEN
         strESNCode := '54';
         v_expireMinutes := 1;
      ELSIF intDeactCode = 31
      THEN
         strESNCode := '55';
      ELSIF intDeactCode = 32
      THEN
         strESNCode := '56';
      ELSIF intDeactCode = 61
      THEN
         strESNCode := '56';
         v_expireMinutes := 1;
      ELSIF intDeactCode = 63
      THEN
         strESNCode := '58';
      ELSIF intDeactCode = 250
      THEN
         strESNCode := '54';

      /*CR3327-1 - Starts - Set phone to Past due for Upgrade*/
      ELSIF v_DeactReason = 'UPGRADE'
      THEN
         strESNCode := '54';

      /*CR3718 - Active upgrade with transferring old MIN*/
      ELSIF v_DeactReason = 'ACTIVE UPGRADE'
      THEN
         strESNCode := '54';

      /*CR3327-1 - Ends */
      ELSE
         strESNCode := '51';
      END IF;
      /* CR3190 Re-initialize if not NET10 phone */
      IF rec_ph.x_restricted_use <> 3
      THEN
         v_expireMinutes := 0;
      END IF;

      /* Get phone status code */
      OPEN currStatCode(strESNCode, 'PS');
      FETCH currStatCode
      INTO recPhStatCode;
      CLOSE currStatCode;

      /*** Updating ESN record that is being deactivated ***/
      v_action := 'Updating part_inst of ESN';
      UPDATE table_part_inst
         SET x_part_inst_status   = recPhStatCode.x_code_number,
             status2x_code_table  = recPhStatCode.objid,
             last_trans_time      = SYSDATE,
             x_reactivation_flag  = DECODE(recDeactCode.x_value, 2, 1,x_reactivation_flag),
             part_inst2x_new_pers = NULL,
             x_clear_tank         = DECODE(v_expireMinutes, 1, v_expireMinutes, x_clear_tank)
       WHERE x_part_inst_status = '52'
         AND objid = rec_ph.objid;

      /**** Update ClickPlan history endingDate=sysdate *****/
      v_action := 'Updating click plan hist';
      UPDATE table_x_click_plan_hist
         SET x_end_date = SYSDATE
       WHERE curr_hist2site_part = rec_ph.sitePartObjid
         AND (x_end_date IS NULL
          OR x_end_date = TRUNC(TO_DATE('01/01/1753', 'MM/DD/YYYY')));

      /**** CR3190 Insert into Expire Minute zero_out_max table *******/
      IF v_expireMinutes = 1
      THEN
         v_action := 'Checking max_esn_exists';
         OPEN c_max_esn_exists (rec_ph.part_serial_no);
         FETCH c_max_esn_exists
         INTO r_max_esn_exists;
         IF c_max_esn_exists%NOTFOUND
         THEN
            v_action := 'Inserting into table_x_zero_out_max';
            INSERT
            INTO table_x_zero_out_max(
               objid,
               x_esn,
               x_req_date_time,
               x_transaction_type
            )VALUES(
               seq ('x_zero_out_max'),
               rec_ph.part_serial_no,
               SYSDATE,
               2
            );
         END IF;
         CLOSE c_max_esn_exists;
      END IF;

      /*** Write ESN to pi_hist ***/
      IF WritePIHistory(ip_userObjId, rec_ph.part_serial_no, NULL, NULL, NULL,'DEACTIVATE', rec_ph.x_iccid) = 1
      THEN
	      blnWritePiHist := TRUE;
      ELSE
	      blnWritePiHist := FALSE;
      END IF;

      /*** Write Line to pi_hist ***/
      IF WritePIHistory(ip_userObjId, rec_min.part_serial_no, NULL, NULL, NULL,'DEACTIVATE', rec_ph.x_iccid) = 1
      THEN
	      blnWritePiHist := TRUE;
      ELSE
	      blnWritePiHist := FALSE;
      END IF;

      /** Determine deactivation type **/
      IF (blnGSM)
      THEN
         IF(intPortIn = 1) or (blnStart) or (ip_samemin = 'RETURNMIN')-- CR4579
         THEN
            strDeactType := 'Deactivation';
         ELSE
            strDeactType := 'Suspend';
         END IF;
      ELSE
         IF (intPortIn = 1)
         THEN
            strDeactType := 'Deactivation';
         ELSIF(intNotifycarr = 0)
         THEN
            strDeactType := 'Suspend';
         ELSE
            strDeactType := 'Deactivation';
         END IF;
      END IF;


      IF(intByPassOrderType <> 2)
      THEN
         /*** CR3647 - Do not send an action item for MIN Change*/
         IF ((v_DeactReason <> 'UPGRADE'
          AND v_DeactReason <> 'MINCHANGE')
          OR ( v_DeactReason = 'UPGRADE'
          AND strDeactType <> 'Deactivation'))
         THEN
            v_action := 'Creating action_item';
            IGATE.SP_CREATE_ACTION_ITEM(rec_ph.x_part_inst2contact,intCallTranObj, strDeactType,
                                        intByPassOrderType, 0, intStatCode,intActItemObj);
            IF (intStatCode = 2)
            THEN
               op_returnMsg := op_returnMsg ||
               ' The Action Item Has Not Been Created.  Please Contact The Line Management Data Adminstrator.';
            ELSIF (intStatCode = 4)
            THEN
               op_returnMsg := op_returnMsg ||
               ' There is no transmission method set for this carrier.';
            END IF;

            /* Determines whether an action item was created and exits if not */
            IF (intActItemObj = 0)
            THEN
               op_returnMsg := 'No Lines Were Deactivated';
               RAISE e_deact_exception;
            END IF;

            /*** Check blackout ***/
            IGATE.SP_GET_ORDERTYPE(rec_min.part_serial_no, strDeactType,rec_min.part_inst2carrier_mkt, rec_ph.x_technology, intOrdTypeObj);
            IGATE.SP_CHECK_BLACKOUT(intActItemObj, intOrdTypeObj,intBlackOutCode);

            IF (intBlackOutCode = 0)
            THEN
               --CR3318
               IGATE.SP_DETERMINE_TRANS_METHOD(intActItemObj, strDeactType,NULL, intTransMethod);

               IF (intTransMethod = 2)
               THEN
                  op_returnMsg := op_returnMsg ||
                  ' The Action Item Has Not Been Created.  Please Contact The Line Management Data Adminstrator. ';
               ELSIF (intTransMethod = 4)
               THEN
                  op_returnMsg := op_returnMsg ||
                  ' There is no transmission method set for this carrier.';
               END IF;
            ELSIF (intBlackOutCode = 1)
            THEN
               op_returnMsg := op_returnMsg || ' Currently in blackout.';
               IGATE.SP_DISPATCH_TASK(intActItemObj, 'BlackOut', intDummy);
            ELSIF (intBlackOutCode = 2)
            THEN
               op_returnMsg := op_returnMsg || ' No task record found.';
            ELSIF (intBlackOutCode = 3)
            THEN
               op_returnMsg := op_returnMsg || ' No x_call_trans record found.';
            ELSIF (intBlackOutCode = 4)
            THEN
               op_returnMsg := op_returnMsg || ' No x_carrier record found.';
            ELSIF (intBlackOutCode IN (5, 6))
            THEN
               IGATE.SP_DISPATCH_TASK(intActItemObj, 'BlackOut', intDummy);
            ELSIF (intBlackOutCode = 7)
            THEN
               op_returnMsg := op_returnMsg || ' Unspecified error.';
            END IF;
         END IF; /* End of upgrade and deact check */

         /** Free Voicemail Update 06/09/04 **/
         v_action := 'Updating Free voice mail';
         UPDATE sa.x_free_voice_mail
            SET x_fvm_status = 1,
                x_fvm_number = NULL,
                x_fvm_time_stamp = SYSDATE
          WHERE x_fvm_status = 2
            AND free_vm2part_inst = rec_ph.objid;
         COMMIT;

         /** Deletes Annual Plan and TFU promotions when ESN is deactivated
            insert into group history table
            version 1.3  08/16/2002 **/
         v_action := 'Removing Group promos';
         FOR recCurremovePromo IN curremovePromo(rec_ph.objid)
         LOOP
            sa.sp_seq('x_group_hist', intGrpHistSeq); -- 06/09/03
            INSERT INTO table_x_group_hist(
               objid,
               x_start_date,
               x_end_date,
               x_action_date,
               x_action_type,
               x_annual_plan,
               grouphist2part_inst,
               grouphist2x_promo_group
            )VALUES(
               intGrpHistSeq,
               recCurremovePromo.x_start_date,
               recCurremovePromo.x_end_date,
               SYSDATE,
               'REMOVE',
               recCurremovePromo.x_annual_plan,
               recCurremovePromo.groupesn2part_inst,
               recCurremovePromo.groupesn2x_promo_group
            );

            /* Deleting AnnualPlan and TFU promotions */
            DELETE FROM table_x_group2esn
             WHERE objid = recCurremovePromo.objid;
         END LOOP;
         v_action := 'Removing autopay_prc';
         remove_autopay_prc(rec_ph.part_serial_no, strRetTemp);

         /*** CR3830 - Remove OTA Pending Records and Update Assoc. Records******/
         UPDATE table_x_ota_transaction a
            SET x_status = 'COMPLETED',
                x_reason = 'DEACT'
          WHERE x_status = 'OTA PENDING'
            AND x_esn = ip_esn
            RETURNING x_ota_trans2x_call_trans BULK COLLECT INTO v_call_trans;

            FOR i IN 1..v_Call_Trans.COUNT
            LOOP
			         UPDATE table_x_call_trans
			            SET x_result = 'Completed'
                WHERE objid = v_call_trans(i);

               UPDATE table_x_code_hist
                  SET x_code_accepted = 'YES'
                WHERE code_hist2Call_trans = v_call_trans(i);
            END LOOP;
         /***** End of CR3830 *********/
      END IF;
      /*** End of intByPassOrderType ***/


      op_return := 'true';
      op_returnMsg := op_returnMsg ||' '|| strRetTemp;
      COMMIT;
      EXCEPTION
      WHEN e_deact_exception
      THEN
         ROLLBACK;
         op_return := 'false';
         Toss_util_pkg.Insert_error_tab_proc ( v_action, ip_esn,
         v_procedure_name);
      WHEN OTHERS
      THEN
         strSQLErrm := SUBSTR(SQLERRM, 1, 200);
         op_return := 'false';
         op_returnMsg := strSQLErrm;
         Toss_util_pkg.Insert_error_tab_proc ( v_action, ip_esn,
         v_procedure_name);
   END deactService;


   /*****************************************************************************/
   /*
   /* Name: WritePiHistory
   /* Description: Inserts new records into table_x_pi_hist
   /*****************************************************************************/
   FUNCTION WritePIHistory(
      ip_userObjid IN VARCHAR2,
      ip_part_serial_no IN VARCHAR2,
      ip_oldNPA IN VARCHAR2,
      ip_oldNXX IN VARCHAR2,
      ip_oldEXT IN VARCHAR2,
      ip_action IN VARCHAR2,
      ip_iccid IN VARCHAR2
   )
   RETURN PLS_INTEGER
   IS
      v_function_name CONSTANT VARCHAR2 (200) := v_package_name ||
      '.insert_pi_hist_fun()';
      table_part_inst_rec table_part_inst%ROWTYPE;
      v_pi_hist_seq NUMBER;
-- 06/09/03
   BEGIN
      OPEN toss_cursor_pkg.table_part_inst_cur (ip_part_serial_no);
      FETCH toss_cursor_pkg.table_part_inst_cur
      INTO table_part_inst_rec;
      CLOSE toss_cursor_pkg.table_part_inst_cur;
      sp_seq ('x_pi_hist', v_pi_hist_seq); -- 06/09/03
      INSERT
      INTO table_x_pi_hist(
         objid,
         status_hist2x_code_table,
         x_change_date,
         x_change_reason,
         x_cool_end_date,
         x_creation_date,
         x_deactivation_flag,
         x_domain,
         x_ext,
         x_insert_date,
         x_npa,
         x_nxx,
         x_old_ext,
         x_old_npa,
         x_old_nxx,
         x_part_bin,
         x_part_inst_status,
         x_part_mod,
         x_part_serial_no,
         x_part_status,
         x_pi_hist2carrier_mkt,
         x_pi_hist2inv_bin,
         x_pi_hist2part_inst,
         x_pi_hist2part_mod,
         x_pi_hist2user,
         x_pi_hist2x_new_pers,
         x_pi_hist2x_pers,
         x_po_num,
         x_reactivation_flag,
         x_red_code,
         x_sequence,
         x_warr_end_date,
         dev,
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
         x_transaction_id,
         x_msid,
         x_iccid
      )VALUES(
         v_pi_hist_seq,
         table_part_inst_rec.status2x_code_table,
         SYSDATE,
         ip_action,
         table_part_inst_rec.x_cool_end_date,
         table_part_inst_rec.x_creation_date,
         table_part_inst_rec.x_deactivation_flag,
         table_part_inst_rec.x_domain,
         table_part_inst_rec.x_ext,
         table_part_inst_rec.x_insert_date,
         table_part_inst_rec.x_npa,
         table_part_inst_rec.x_nxx,
         ip_oldEXT,
         ip_oldNPA,
         ip_oldNXX,
         table_part_inst_rec.part_bin,
         table_part_inst_rec.x_part_inst_status,
         table_part_inst_rec.part_mod,
         table_part_inst_rec.part_serial_no,
         table_part_inst_rec.part_status,
         table_part_inst_rec.part_inst2carrier_mkt,
         table_part_inst_rec.part_inst2inv_bin,
         table_part_inst_rec.objid,
         table_part_inst_rec.n_part_inst2part_mod,
         ip_userObjid,
         table_part_inst_rec.part_inst2x_new_pers,
         table_part_inst_rec.part_inst2x_pers,
         table_part_inst_rec.x_po_num,
         table_part_inst_rec.x_reactivation_flag,
         table_part_inst_rec.x_red_code,
         table_part_inst_rec.x_sequence,
         table_part_inst_rec.warr_end_date,
         table_part_inst_rec.dev,
         table_part_inst_rec.fulfill2demand_dtl,
         table_part_inst_rec.part_to_esn2part_inst,
         table_part_inst_rec.bad_res_qty,
         table_part_inst_rec.date_in_serv,
         table_part_inst_rec.good_res_qty,
         table_part_inst_rec.last_cycle_ct,
         table_part_inst_rec.last_mod_time,
         table_part_inst_rec.last_pi_date,
         table_part_inst_rec.last_trans_time,
         table_part_inst_rec.next_cycle_ct,
         table_part_inst_rec.x_order_number,
         table_part_inst_rec.part_bad_qty,
         table_part_inst_rec.part_good_qty,
         table_part_inst_rec.pi_tag_no,
         table_part_inst_rec.pick_request,
         table_part_inst_rec.repair_date,
         table_part_inst_rec.transaction_id,
         table_part_inst_rec.x_msid,
         ip_iccid
      );
      IF SQL%ROWCOUNT = 1
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
      EXCEPTION
      WHEN OTHERS
      THEN
         Toss_util_pkg.insert_error_tab_proc ( 'Failer inserting swipe',
         ip_part_serial_no, 'TOSS_UTIL_PKG.INSERT_PI_HIST_FUN' );
         RETURN 0;
   END ;
END Service_Deactivation_aux;
/