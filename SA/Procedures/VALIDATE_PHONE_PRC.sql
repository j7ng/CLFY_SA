CREATE OR REPLACE PROCEDURE sa."VALIDATE_PHONE_PRC" (
   p_esn IN VARCHAR2,
   p_source_system IN VARCHAR2,
   p_subsourcesystem IN VARCHAR2, --CR8663 SWITCH
   p_part_inst_objid OUT VARCHAR2,
   p_code_number OUT VARCHAR2,
   p_code_name OUT VARCHAR2,
   p_redemp_reqd_flg OUT NUMBER,
   p_warr_end_date OUT VARCHAR2,
   p_phone_model OUT VARCHAR2,
   p_phone_technology OUT VARCHAR2,
   p_phone_description OUT VARCHAR2,
   p_amigo_flg OUT NUMBER,
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
   /* for CR 2599 */
   p_contact_email OUT VARCHAR2,
   p_min OUT VARCHAR2,
   p_manufacturer OUT VARCHAR2, --CR3733
   p_seq OUT NUMBER, --CR4245
   p_iccid OUT VARCHAR2, --CR6731
   p_iccid_flag OUT VARCHAR2, --CR6731
   p_last_call_trans OUT VARCHAR2
)
AS
/*****************************************************************************************************
               *** NOTE TO DEVELOPER THAT IS MODIFYING THIS PROCEDURE:***
               -----------------------------------------------------------
               If any new cursor is added, close the cursor to the local procedure
                                        CLOSE_OPEN_CURSORS
   *****************************************************************************************************/
   /********************************************************************************************/
   /*  Copyright   2002 Tracfone  Wireless Inc. All rights reserved                           */
   /*                                                                                          */
   /* NAME     :       VALIDATE_PHONE_PRC                                                      */
   /* PURPOSE  :       This procedure is called from the method validatePhone                  */
   /*                  of TFPhonePart Java. CBO logic rewritten in PL/SQL for                  */
   /*                  Stabilization project                                                   */
   /* FREQUENCY:                                            */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                           */
   /*                                                                                          */
   /* REVISIONS:                                                                               */
   /* VERSION  DATE       WHO               PURPOSE                          */
   /* -------  ---------- -----             ---------------------------------------------      */
   /*  1.0     10/19/03   Suganthi Uthaman  Initial   Revision                  */
   /*  1.1     11/18/03   Natalio Guada     CR2196 (Allow redemption without a pin on WEB      */
   /*                      if there are pending redemption units)             */
   /*  1.2     12/09/03   Vanisri Adapa     CR2253 (SMS Project)                               */
   /*                                       Return the SMS flag for the ESN's MIN              */
   /*                                       Return the part class for the ESN's part number    */
   /*                                       Return Parent Id for the ESN's MIN                 */
   /* 1.3    01/07/04   Vanisri Adapa      Changes for MAX project (Time Tank Verification)   */
   /* 1.4    01/15/04   Ritu Gandhi        Changes for My Account project. Send if account    */
   /*                                       exists for the ESN. Returned in extra_info_3       */
   /* 1.5    02/03/04   Vanisri Adapa      CR2072 - Added "IVR" source system check to        */
   /*                                       return "110" error code                            */
   /* 1.6    03/04/04   Ritu Gandhi        CR2528-Check if the user has an Autopay Account    */
   /*                                       Returned in extra_info_6                           */
   /* 1.7    03/08/04   Gerald Pintado     CR2722 - EMERG 46020 - FOR MOTOROLA V120 THAT      */
   /*                                       WERE DISTRIBUTED W/OUT PREPAID MENU                */
   /* 1.8    05/04/04   Vanisri Adapa      CR2805 (MT47153) - Fix for POSA phones             */
   /*                                       If x_value in x_code_table is set to 1 for '59'    */
   /*                                       Make POSA phone active                             */
   /* 1.9    05/18/04   Vanisri Adapa      CR2818 (MT47381)-Allow transactions with pending   */
   /*                                       units that are type FREE / Promocode to go         */
   /*                                       through without pins                               */
   /*                                       CR2852 (MT47994) - Rewrite some of the existing    */
   /*                                       queries to improve performance based on Hanif's    */
   /*                                       recommendations                                    */
   /*                                       CR2860 (MT48169) - Fix to return the correct       */
   /*                                       extra_info value if x_pin exists for an esn that   */
   /*                                       has pending units                                  */
   /* 2.0    06/02/04   Ritu Gandhi   CR2732-Set extra_info_7 to 1. It will be set in    */
   /*                                       CBOFacade for IVR Surveys                          */
   /* 2.1    07/08/04   Vanisri Adapa      CR2912 - Check SID_TYPE based on the esn           */
   /*                                       technology instead of the type "MASTER"            */
   /* 2.2    8/27/04    Andrew Borja       CR3190 - set pamigo to 3 if x_grp_id  is 10cents   */
   /* 2.3    10/06/04   Ritu Gandhi        CR2620-Return if the line is flagged for MSID      */
   /*                                       update even for new phones                         */
   /* 2.3    12/15/04   Ashutosh           CR3190-Checks DIGITAL3 promotion and NET10 SOurce  */
   /*                                       System update even for new phones        */
   /* 2.4    11/15/04   Novak Lalovic      Modified the procedure to add OTA validation       */
   /*                                       rules and added 6 new elements/bits to the         */
   /*                                       p_extra_info OUT parameter:                        */
   /*                                       1) is ESN active                                   */
   /*                                       2) is OTA on ESN allowed                           */
   /*                                       3) is carriear OTA type                            */
   /*                                       4) is handset locked                               */
   /*                                       5) is redemption menu on the handset               */
   /*                                       6) is destination address on the handset           */
   /*                                       Also, created constant EXTRA_INFO_7                */
   /*                                       AND initialized it to  '1' and then appended       */
   /*                                       the variable name to the rest of the p_extra_info  */
   /*                                       string. Before, the literal '1' was appended to    */
   /*                                       the string in several different places in the code.*/
   /* 2.5    01/18/05   Mohan               Code for Error 173 and 174  moved above error 106  */
   /* 2.6    02/01/05   Novak Lalovic       Modified the code where the value of               */
   /*                                       p_source_system parameter is used in the IF        */
   /*                                       statements to handle                               */
   /*                                       the NETHANDSET source system                       */
   /* 2.7    03/03/05   VAdapa              EME CR3725 - Accurate metrics for compensation     */
   /*                                       and replacement units                              */
   /* 2.8    03/09/05   VAdapa              CR3477 - POSA Flag Alerts                          */
   /* 2.9    01/24/05   Ritu Gandhi         Case Mod on Web - Changed logic to get personality */
   /*                                       update status into p_pers_status                   */
   /* 1.25   04/04/05                       Changed the revision to match PVCS                 */
   /* 1.26   05/02/05   Vani Adapa          CR3979 - ADD NETCSR sourcesystem check for         */
   /*                                       "Prepaid Software Error"                           */
   /* 1.27   05/02/05   Vani Adapa          CR3979 - Changed "OR" to "AND"                     */
   /* 1.28   05/05/05   Ritu Gandhi         CR3824 - For past due phones return                */
   /*                                       p_redemp_reqd_flg as false                         */
   /*                                       if there are pending redemptions associated to it. */
   /* 1.29   05/13/05   Ritu Gandhi         CR3733 - Return manufacturer for the phone         */
   /* 1.30   06/03/05   Mchinta             CR3740 - Check for HDR_IND in part inst to set for */
   /*                                       UpdateTimetank                                     */
   /* 1.33   06/07/05   NLalovic            OTA3 - Removed the lines of code in the where      */
   /*                                       clauses of OTA validation cursors where the query  */
   /*                                       search was limited to GSM technology only.         */
   /*                                       Now we can validate the phones (for OTA) if they   */
   /*                                       belong to other technologies as well.              */
   /*                                       This line was removed from CURSOR                  */
   /*                                       cur_is_ota_activation and CURSOR cur_is_esn_active:*/
   /*                                       AND tpn.x_technology = 'GSM'                       */
   /* 1.34  08/02/05    VAdapa              CR4332 - 1
   /* 1.35  08/10/05    VAdapa              CR4395 - Proper validation of Tnumber for GSM customers with error -100
   /* 1.36  08/08/05    VAdapa              CR4245 - ILD
   /* 1.37 38.....
   /* 1.39  09/08/05    VAdapa              CR4473 - ILD Call Forwarding Release 2
   /* 1.40  09/13/05    VAdapa              CR4417 - Removed CR4473 logic and modifed cursor pers_lac_cur
   /*                                       to improve the performance
   /* 1.41  09/28/05    VAdapa              CR4382 - Net10 Case Mod
   /* 1.42  03/09/06    VAdapa            CR4981_4982 Changes for data phones (Get carrier features based on the data_capable)
   /* 1.43  05/24/06    VAdapa            Fix for SMS flag to return '1' for GSM phones
   /* 1.44  05/30/06    VAdapa            Return extra_info bit 14 for exchange parameter
                                 If the original act date is > 30 days, then return 1
                              If the original act date is < 30 days, then return 0
   /*1.45   05/31/06    VAdapa         Added NVL to data_capable
   /1.46    06/08/06    VAdapa         Fix OPEN_CURSORS isse - Create a local procedure CLOSE_OPEN_CURSORS to close all
                           cursors if they are open.
                           ***NOTE TO DEVELOPER THAT IS MODIFYING THIS PROCEDURE:***
                           ----------------------------------------------------------
                           If any new cursor is added, add the check to this local procedure
   /*1.47   06/09/06    VA/CL       Fixed the OPEN_CURSORS issue
   /*1.48/1.49   10/10/06    jizquierdo    CR5456 - To include internal port in (x_port_in=2)
   /* 1.50    11/02/06    VA     CR5694 - Reactivations with clear tank flag
   /* 1.51     09/03/07   RSI    CR4479 - Billing Platform Changes - Code added to perform source system condition checks  for 'NETBATCH' and TRACBATCH' also.
   /* 1.52    03/21/07    IC      CR5150 - The word Carrier was separating defect #124
   /* 1.53    03/21/07    IC      CR5150 - Moved if statment that was interferring with Technology display on case screen  #110
   /* 1.54    03/29/07    IC      Merge CR4479 into ver 1.53
   /* 1.55/1.56  06/08/07    IC      CR5728 stop giving 300 units to activations on defective phone replacements
   /* 1.57    07/30/07    IC      CR5728 merge with CR6293 OTA REACTIVATION GSM /
   /* 1.58    08/01/07    CL      fix to slow cursor
   /* 1.59    08/02/07    IC      CR5728-1 merge with CR6293 OTA REACTIVATION GSM /
   /* 1.60    08/07/07    RAMU    Execution of the cursor get_pending_repl_cur moved to the end for CR6403
   /********************************************************************************************/
   /********************************************************************************************/
   /* NEW PVCS STRUCTURE /NEW_PLSQL?CODE                                                              */
   /*1.2        09/11/07  GKharche CR6451 management of POSA flags.
   /*1.0.1.0 09/18/07  CLindner/VAdapa    CR6731 Eliminate SIM Entry
   /*1.0.1.110/10/07   MAbdul            CR6731 - Fix defect #51
                                    The flag for correct sourcesystem will be returned since this procedure is called
                                    only once before switching to the correct sourcesystem in the front end.
   /* 1.5.1 02/01/08 ic fixed problem with error num 750 CR6488

   /*1.6  01/20//08       IC OTA CDMA Activation Project
   /*                                 Created new table for error codes x_clarify_codes
   /*                                 Added 2 new error codes 116 and 117 and added more output values
   /*1.7-1.9 02/19/08  IC moved checking sequence to report more values
   /*1.10    02/27/08  IC merge
   /*1.11    03/04/08  IC standardize codes rename 606 to 118, 707 to 119, 750 to 120
   /*1.12    04/10/08  VA TMODATA - Cleanup T-Numbers
   /*1.13    04/16/08  VA Latest, changed the grants, removed the TMODATA label
   /*1.14    05/07/08  IC Review grants
   /*1.15    07/30/08  Nguada W377 Cursor fix, exclude 'Obsolete' in get_oldsitepart_cur
   /*1.16    08/26/08  CLindner CR7691 added company NET10 records to table_x_carrier_features
   /*1.17    09/11/08  Icanavan CR8010
   /*1.18    10/02/08  Nguada CR8013 corrections to cursor c_sms_parent
   /*1.19    10/02/08  Nguada CR8013 corrections to cursor c_sms_parent
   /*1.20    10/25/08  ICanavan CR7814 CDMA next available project
   /*1.21    12/11/08  YMillan CR7814 fix flag p_redemp_reqd_flg for error 116
   /*1.22    03/18/09 NGuada  CR8406 Comment the call to clean_tnumber_oprc
   /*1.23-24 03/26/09 ICanavan  CR8663 WALMART SWITCH BASE
   /****************************************************************************************************/
   CURSOR Carrier_Pending_Cur(
      p_esn IN VARCHAR2
   )
   IS
   SELECT pi.part_serial_no,
      pi.x_part_inst_status,
      pi.x_part_inst2contact,
      sp.part_status,
      sp.x_min,
      sp.x_zipcode,
      ct.objid ct_objid
   FROM TABLE_PART_INST pi, TABLE_SITE_PART sp, TABLE_X_CALL_TRANS ct
   WHERE ct.call_trans2site_part = sp.objid
   AND ct.x_action_type = '1'
   AND pi.part_serial_no = sp.x_service_id
   AND pi.x_domain = 'PHONES'
   AND pi.part_serial_no = p_esn
   AND pi.x_part_inst_status IN ('50', '150')
   AND sp.part_status||'' = 'CarrierPending'
   AND ct.x_transact_date IN (
   SELECT MAX(x_transact_date)
   FROM TABLE_X_CALL_TRANS
   WHERE x_action_type = '1'
   AND x_service_id = p_esn) ;
   Carrier_Pending_Rec Carrier_Pending_Cur%ROWTYPE;

   -- CR7814 CDMA next available looking for Reactivation records
   CURSOR Carrier_Pending_React_Cur(
      p_esn IN VARCHAR2
   )
   IS
   SELECT pi.part_serial_no,
      pi.x_part_inst_status,
      pi.x_part_inst2contact,
      sp.part_status,
      sp.x_min,
      sp.x_zipcode,
      ct.objid ct_objid
   FROM TABLE_PART_INST pi, TABLE_SITE_PART sp, TABLE_X_CALL_TRANS ct
   WHERE ct.call_trans2site_part = sp.objid
   AND ct.x_action_type = '3'
   AND pi.part_serial_no = sp.x_service_id
   AND pi.x_domain = 'PHONES'
   AND pi.part_serial_no = p_esn
   AND pi.x_part_inst_status IN ('51', '54')
   AND sp.part_status||'' = 'CarrierPending'
   AND ct.x_transact_date IN (
   SELECT MAX(x_transact_date)
   FROM TABLE_X_CALL_TRANS
   WHERE x_action_type = '3'
   AND x_service_id = p_esn) ;
   Carrier_Pending_React_Rec Carrier_Pending_React_Cur%ROWTYPE;
   --- end CR7814 CDMA NEXT AVAIL

   CURSOR Activation_Pending_Cur(
      p_esn IN VARCHAR2
   )
   IS
   SELECT pi.part_serial_no,
      pi.x_part_inst_status,
      pi.x_part_inst2contact,
      sp.part_status,
      sp.x_min,
      sp.x_zipcode,
      ct.objid ct_objid
   FROM TABLE_PART_INST pi, TABLE_SITE_PART sp, TABLE_X_CALL_TRANS ct
   WHERE ct.call_trans2site_part = sp.objid
   AND ct.x_action_type = '1'
   AND pi.part_serial_no = sp.x_service_id
   AND pi.x_domain = 'PHONES'
   AND pi.part_serial_no = p_esn
   AND pi.x_part_inst_status IN ('50', '150')
   AND sp.part_status = 'Active'
   AND ct.x_transact_date IN (
   SELECT MAX(x_transact_date)
   FROM TABLE_X_CALL_TRANS
   WHERE x_action_type = '1'
   AND x_service_id = p_esn) ;
   Activation_Pending_Rec Activation_Pending_Cur%ROWTYPE;
   CURSOR part_inst_cur(
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
   part_inst_rec part_inst_cur%ROWTYPE;

      CURSOR get_phone_info_cur(
      p_esn IN VARCHAR2
   )
   IS
   SELECT pn.part_number,
      pn.x_technology,
      pn.description,
      pn.x_restricted_use,
      pn.x_dll,
      pi.x_part_inst_status,
      --              NVL (pn.prog_type, 2) prog_type,            -- Changed for CR3190
      NVL (pn.prog_type, 0) prog_type,
      -- Changed the NVL value from 2 to 0 --CR5569
      pn.x_manufacturer,  --CR3733
      pn.x_data_capable --CR4981_4982
      FROM TABLE_PART_INST pi, TABLE_MOD_LEVEL ml, TABLE_PART_NUM pn
   WHERE pi.n_part_inst2part_mod = ml.objid
   AND ml.part_info2part_num = pn.objid
   AND pi.part_serial_no = p_esn
   AND pi.x_domain = 'PHONES';

   get_phone_info_rec get_phone_info_cur%ROWTYPE;
   --CR2912 Changes
   --  CURSOR pers_lac_cur (p_esn IN VARCHAR2)
   --  IS
   --    SELECT sid.*
   --      FROM table_part_inst pi,
   --      table_x_carr_personality cp,
   --      table_x_sids sid,
   --      table_x_lac l
   --     WHERE pi.part_inst2x_pers = cp.objid
   --       AND sid.sids2personality = cp.objid
   --       AND l.lac2personality = cp.objid
   --       AND pi.part_serial_no = p_esn
   --       AND sid.x_sid_type = 'MASTER';
   -- cwl 12/17/03 change to use index on TABLE_X_LAC
   --     SELECT sid.*
   --       FROM table_x_sids sid,
   --       table_x_lac l,
   --       table_x_carr_personality cp,
   --       table_part_inst pi
   --      WHERE sid.x_sid_type = 'MASTER'   --sid.x_sid_type || '' = 'MASTER'
   --        AND sid.sids2personality = cp.objid
   --        AND l.lac2personality = cp.objid
   --        AND l.x_local_area_code = pi.x_npa
   --        AND cp.objid = pi.part_inst2x_pers
   --        AND pi.part_serial_no = p_esn;
   CURSOR pers_lac_cur(
      p_esn IN VARCHAR2,
      p_tech IN VARCHAR2
   )
   IS
   SELECT SID.*
   FROM TABLE_X_SIDS SID, TABLE_X_LAC l, TABLE_X_CARR_PERSONALITY cp,
   TABLE_PART_INST pi
   WHERE SID.x_sid_type = p_tech
   --sid.x_sid_type = 'MASTER'   --sid.x_sid_type || '' = 'MASTER'
   AND SID.sids2personality = cp.objid
   AND l.lac2personality = cp.objid
   --CR4395 Starts
   --   AND l.x_local_area_code = pi.x_npa
   --CR4417 Starts
   --   AND TO_CHAR(l.x_local_area_code) = pi.x_npa
   --CR4395 ends
   AND l.x_local_area_code = TO_NUMBER (DECODE (INSTR (pi.x_npa, 'T'), 0, pi.x_npa
   , SUBSTR (pi.x_npa, 2) ) )
   --CR4417 Ends
   AND cp.objid = pi.part_inst2x_pers
   AND pi.part_serial_no = p_esn
   ORDER BY SID.x_index ASC; --Added for CMW Ritu
   --End CR2912 Changes
   pers_lac_rec pers_lac_cur%ROWTYPE;
   CURSOR product_part_cur(
      p_esn IN VARCHAR2
   )
   IS
   SELECT *
   FROM TABLE_SITE_PART
   WHERE x_service_id = p_esn
   AND part_status = 'Active';
   product_part_rec product_part_cur%ROWTYPE;
   CURSOR promo_cur(
      p_sp_objid IN NUMBER
   )
   IS
   SELECT p.x_promo_code,
      p.x_promo_type,
      p.x_units,
      p.x_access_days,
      p.x_english_short_text
   FROM TABLE_SITE_PART sp, TABLE_X_PROMOTION p, TABLE_X_PENDING_REDEMPTION pr
   WHERE pr.x_pend_red2site_part = sp.objid
   AND pr.pend_red2x_promotion = p.objid
   AND sp.objid = p_sp_objid;
   promo_rec promo_cur%ROWTYPE;
   CURSOR new_plan_cur(
      p_sp_objid IN NUMBER
   )
   IS
   SELECT cp.objid
   FROM TABLE_SITE_PART sp, TABLE_X_CLICK_PLAN cp
   WHERE sp.site_part2x_new_plan = cp.objid
   AND sp.objid = p_sp_objid;
   new_plan_rec new_plan_cur%ROWTYPE;
   CURSOR contact_pi_cur(
      p_esn IN VARCHAR2
   )
   IS
   SELECT c.*
   FROM TABLE_PART_INST pi, TABLE_CONTACT c
   WHERE pi.x_part_inst2contact = c.objid
   AND pi.part_serial_no = p_esn
   AND x_domain = 'PHONES';
   contact_pi_rec contact_pi_cur%ROWTYPE;
   CURSOR contact_sp_cur(
      p_sp_objid IN NUMBER
   )
   IS
   SELECT c.*
   FROM TABLE_CONTACT c, TABLE_CONTACT_ROLE cr, TABLE_SITE_PART sp, TABLE_SITE
   s
   WHERE cr.contact_role2contact = c.objid
   AND cr.contact_role2site = s.objid
   AND sp.site_part2site = s.objid
   AND sp.objid = p_sp_objid;
   contact_sp_rec contact_sp_cur%ROWTYPE;
   CURSOR cc_cur(
      p_contact_objid IN NUMBER
   )
   IS
   --CR2852 Changes
   --    SELECT cc.*
   SELECT COUNT (*) count_cc
   --End CR2852 Changes
   FROM TABLE_X_CREDIT_CARD cc, MTM_CONTACT46_X_CREDIT_CARD3 MTM
   WHERE MTM.mtm_contact2x_credit_card = p_contact_objid
   AND MTM.mtm_credit_card2contact = cc.objid
   AND cc.x_card_status = 'ACTIVE';
   cc_rec cc_cur%ROWTYPE;
   CURSOR pi_min_cur(
      p_min IN VARCHAR2
   )
   IS
   SELECT *
   FROM TABLE_PART_INST
   WHERE part_serial_no = p_min
   AND x_domain = 'LINES';
   pi_min_rec pi_min_cur%ROWTYPE;
   CURSOR new_pers_cur(
      pi_min_objid IN NUMBER
   )
   IS
   SELECT cp.*
   FROM TABLE_PART_INST pi, TABLE_X_CARR_PERSONALITY cp
   WHERE pi.part_inst2x_new_pers = cp.objid
   AND pi.objid = pi_min_objid;
   new_pers_rec new_pers_cur%ROWTYPE;
   CURSOR old_pers_cur(
      pi_min_objid IN NUMBER
   )
   IS
   SELECT cp.*
   FROM TABLE_PART_INST pi, TABLE_X_CARR_PERSONALITY cp
   WHERE pi.part_inst2x_pers = cp.objid
   AND pi.objid = pi_min_objid;
   old_pers_rec old_pers_cur%ROWTYPE;
   CURSOR getpers2sid_cur(
      p_pers_objid IN NUMBER,
      p_tech IN VARCHAR2
   )
   IS
   SELECT SID.*
   FROM TABLE_X_SIDS SID, TABLE_X_CARR_PERSONALITY cp
   WHERE SID.sids2personality = cp.objid
   AND cp.objid = p_pers_objid
   AND SID.x_sid_type = p_tech
   ORDER BY x_index ASC;
   getpers2sid_rec getpers2sid_cur%ROWTYPE;
   --CR2818 Changes
   --  CURSOR pend_redemp_cur (p_sp_objid IN NUMBER)
   --  IS
   --
   --     SELECT pr.*
   --       FROM table_x_pending_redemption pr, table_site_part sp
   --      WHERE pr.x_pend_red2site_part = sp.objid
   --        AND pr.x_pend_type = 'FREE'
   --        AND sp.objid = p_sp_objid;
   --
   --  pend_redemp_rec pend_redemp_cur%ROWTYPE;
   --End CR2818 Changes
   CURSOR get_oldsitepart_cur(
      p_pi_objid IN VARCHAR2
   )
   IS
   SELECT sp.*
   FROM TABLE_SITE_PART sp, TABLE_PART_INST pi
   WHERE sp.part_status <> 'Obsolete'
   AND pi.x_part_inst2site_part = sp.objid
   AND pi.objid = p_pi_objid
   ORDER BY service_end_dt DESC;
   get_oldsitepart_rec get_oldsitepart_cur%ROWTYPE;
   CURSOR site_cur(
      p_esn IN VARCHAR2
   )
   IS
   SELECT s.*
   FROM TABLE_SITE s, TABLE_INV_LOCATN il, TABLE_INV_BIN ib, TABLE_PART_INST pi
   WHERE il.inv_locatn2site = s.objid
   AND ib.inv_bin2inv_locatn = il.objid
   AND pi.part_inst2inv_bin = ib.objid
   AND pi.part_serial_no = p_esn;
   site_rec site_cur%ROWTYPE;
   CURSOR dealer_promo_cur(
      p_site_objid IN NUMBER
   )
   IS
   SELECT p.*
   FROM TABLE_X_PROMOTION p, TABLE_SITE s
   WHERE s.dealer2x_promotion = p.objid
   AND s.objid = p_site_objid
   AND p.x_start_date <= SYSDATE
   AND p.x_end_date >= SYSDATE;
   dealer_promo_rec dealer_promo_cur%ROWTYPE;
   CURSOR default_promo_cur(
      p_tech IN VARCHAR2
   )
   IS
   SELECT *
   FROM TABLE_X_PROMOTION
   WHERE x_is_default = 1
   AND x_default_type = p_tech
   AND x_start_date <= SYSDATE
   AND x_end_date >= SYSDATE;
   default_promo_rec default_promo_cur%ROWTYPE;
   -- CR5728
   CURSOR activation_promo_used_curs(
      p_esn IN VARCHAR2
   )
   IS
   SELECT 'X'
   FROM TABLE_X_PROMO_HIST PH, TABLE_X_PROMOTION p, TABLE_X_CALL_TRANS xct, (
      SELECT tc.x_esn
      FROM TABLE_CASE tc, TABLE_X_PART_REQUEST pr
      WHERE 1 = 1
      AND tc.title = 'Defective Phone'
      AND tc.objid = pr.request2case
      AND pr.x_part_num_domain = 'PHONES'
      AND pr.x_part_serial_no = p_esn) tab1
   WHERE 1 = 1
   AND p.x_is_default = 1
   --x_promo_code = 'DEFNET10_2'  --upper(p.x_promo_type)='ACTIVATION'        --
   AND p.objid = PH.promo_hist2x_promotion
   AND xct.objid = PH.promo_hist2x_call_trans
   AND x_service_id = tab1.x_esn;
   /*  old code
   SELECT 'X'
      FROM TABLE_X_PROMO_HIST ph , TABLE_X_PROMOTION p , TABLE_X_CALL_TRANS xct
   WHERE ph.promo_hist2x_promotion = p.objid
         AND  x_is_default=1               --x_promo_code = 'DEFNET10_2'  --upper(p.x_promo_type)='ACTIVATION'        --
         AND xct.objid  = ph.promo_hist2x_call_trans
         AND x_service_id = (SELECT tc.X_ESN
                    FROM TABLE_CASE tc, TABLE_X_PART_REQUEST pr
                 WHERE pr.request2case=tc.objid
                        AND pr.x_part_num_domain = 'PHONES'
                        AND title='Defective Phone'
                  AND pr.x_part_serial_no =  p_esn) ;
   */
   activation_promo_used_rec activation_promo_used_curs%ROWTYPE;
   CURSOR get_oldsitepart_cur2(
      p_esn IN VARCHAR2
   )
   IS
   SELECT *
   FROM TABLE_SITE_PART
   WHERE x_service_id = p_esn
   AND part_status <> 'Obsolete'
   ORDER BY service_end_dt DESC;
   get_oldsitepart_rec2 get_oldsitepart_cur2%ROWTYPE;
   --CR2196
   CURSOR get_pending_redemptions_cur(
      p_esn IN VARCHAR2
   )
   IS
   --CR2818 Changes
   --     SELECT (1)
   --       FROM table_site_part, table_x_pending_redemption
   --      WHERE x_service_id = p_esn
   --        AND part_status = 'Active'
   --        AND x_pend_red2site_part = table_site_part.objid;
   SELECT 'X'
   FROM TABLE_SITE_PART sp, TABLE_X_PENDING_REDEMPTION pend
   WHERE sp.x_service_id = p_esn
   AND sp.part_status = 'Active'
   AND pend.x_pend_red2site_part = sp.objid
   AND NOT EXISTS (
   SELECT 1
   FROM TABLE_X_PROMOTION pr
   WHERE pr.objid = pend.pend_red2x_promotion
   AND pr.x_promo_type = 'Runtime'
   AND x_revenue_type <> 'FREE');
   --End CR2818 Changes
   get_pending_redemptions_rec get_pending_redemptions_cur%ROWTYPE;
   --End CR2196
   --CR3725 Starts
   CURSOR get_pending_repl_cur(
      p_esn IN VARCHAR2
   )
   IS
   SELECT 'X'
   FROM TABLE_PART_INST pi, TABLE_X_PENDING_REDEMPTION pend
   WHERE pi.part_serial_no = p_esn
   AND pend.pend_redemption2esn = pi.objid
   AND pend.x_pend_type = 'REPL';
   get_pending_repl_rec get_pending_repl_cur%ROWTYPE;
   --CR3725 Ends
   --CR2253
   --CR4382 Start
   --    CURSOR c_sms_parent
   --    IS
   --    SELECT ca.x_sms,
   --       cp.x_parent_id
   --    FROM TABLE_X_PARENT cp, TABLE_X_CARRIER_GROUP cg, TABLE_X_CARRIER ca,
   --    TABLE_PART_INST pi, TABLE_SITE_PART sp
   --    WHERE sp.x_min = pi.part_serial_no
   --    AND pi.part_inst2carrier_mkt = ca.objid
   --    AND ca.carrier2carrier_group = cg.objid
   --    AND cg.x_carrier_group2x_parent = cp.objid
   --    AND sp.x_service_id = p_esn
   --    AND sp.part_status || '' = 'Active';
   CURSOR c_sms_parent(
      ip_tech IN VARCHAR2,
      ip_data IN NUMBER --CR4981_4982
   )
   IS
   SELECT cf.x_sms,
      cp.x_parent_id
   FROM TABLE_X_PARENT cp, TABLE_X_CARRIER_GROUP cg, TABLE_X_CARRIER ca,
   TABLE_X_CARRIER_FEATURES cf, TABLE_PART_INST pi, TABLE_SITE_PART sp
   WHERE sp.x_min = pi.part_serial_no
   AND pi.part_inst2carrier_mkt = ca.objid
   AND ca.carrier2carrier_group = cg.objid
   AND cg.x_carrier_group2x_parent = cp.objid
--cwl cr7691
   AND cf.x_restricted_use = (SELECT pn.x_restricted_use
                                FROM TABLE_PART_NUM pn,
                                     TABLE_MOD_LEVEL ml,
                                     table_part_inst pi_esn
                               WHERE pn.objid = ml.part_info2part_num
                                 AND ml.objid = pi_esn.n_part_inst2part_mod
                                 and pi_esn.part_serial_no = p_esn)
   AND cf.x_feature2x_carrier = ca.objid
   AND cf.x_technology = ip_tech
   AND cf.x_data = ip_data --CR4981_4982
   AND sp.x_service_id = p_esn
   AND sp.part_status || '' = 'Active';
   --CR4382 Ends
   r_sms_parent c_sms_parent%ROWTYPE;

   -- CR8663 SWITCH NO CHANGE BUT USE THIS
   CURSOR c_part_class
   IS
   SELECT pc.NAME
   FROM TABLE_PART_CLASS pc, TABLE_PART_NUM pn, TABLE_MOD_LEVEL ml,
   TABLE_PART_INST pi
   WHERE pi.n_part_inst2part_mod = ml.objid
   AND ml.part_info2part_num = pn.objid
   AND pn.part_num2part_class = pc.objid
   AND pi.part_serial_no = p_esn;
   r_part_class c_part_class%ROWTYPE;
   --End CR2253
   --Changes for MAX
   CURSOR c_orig_act_date(
      p_esn IN VARCHAR2
   )
   IS
   SELECT(
      DECODE (refurb_yes.is_refurb, 0, nonrefurb_act_date.init_act_date,
      refurb_act_date.init_act_date )
   ) orig_act_date
   FROM (
      SELECT COUNT (1) is_refurb
      FROM TABLE_SITE_PART sp_a
      WHERE sp_a.x_service_id = p_esn
      AND sp_a.x_refurb_flag = 1) refurb_yes, (
      SELECT MIN (install_date) init_act_date
      FROM TABLE_SITE_PART sp_b
      WHERE sp_b.x_service_id = p_esn
      AND sp_b.part_status || '' IN ('Active', 'Inactive')
      AND NVL (sp_b.x_refurb_flag, 0) <> 1) refurb_act_date, (
      SELECT MIN (install_date) init_act_date
      FROM TABLE_SITE_PART sp_c
      WHERE sp_c.x_service_id = p_esn
      AND sp_c.part_status || '' IN ('Active', 'Inactive')) nonrefurb_act_date;
   r_orig_act_date c_orig_act_date%ROWTYPE;
   CURSOR c_reading_date(
      p_esn IN VARCHAR2
   )
   IS
   SELECT MAX (x_req_date_time) x_req_date_time
   FROM TABLE_X_ZERO_OUT_MAX
   WHERE x_esn = p_esn
   AND x_transaction_type = 1;
   r_reading_date c_reading_date%ROWTYPE;
   --End Changes for MAX
   --Changes for My Account
   CURSOR c_account_exists(
      p_esn IN VARCHAR2
   )
   IS
   SELECT COUNT (*) cnt
   FROM TABLE_PART_INST pi, TABLE_X_CONTACT_PART_INST cp
   WHERE pi.part_serial_no = p_esn
   AND pi.objid = cp.x_contact_part_inst2part_inst;
   r_account_exists c_account_exists%ROWTYPE;
   --End Changes for My Account
   --Changes for Deactivation Protection EZ Web Enrollment
   CURSOR c_autopay_ac_exists(
      p_esn IN VARCHAR2
   )
   IS
   SELECT COUNT (*) cnt
   FROM TABLE_X_AUTOPAY_DETAILS
   WHERE x_esn = p_esn
   AND x_end_date
   IS
   NULL;
   r_autopay_ac_exists c_autopay_ac_exists%ROWTYPE;
   CURSOR c_enrollment_exists(
      p_esn IN VARCHAR2
   )
   IS
   SELECT COUNT (*) cnt
   FROM TABLE_X_EZ_ENROLLMENT
   WHERE x_esn = p_esn;
   r_enrollment_exists c_enrollment_exists%ROWTYPE;
   --End Changes for Deactivation Protection EZ Web Enrollment
   --CR2805 Changes
   CURSOR get_esn_new_status_cur(
      p_esn IN VARCHAR2
   )
   IS
   SELECT ct.x_code_number,
      ct.x_code_name
   FROM TABLE_PART_INST pi, TABLE_X_CODE_TABLE ct
   WHERE pi.part_serial_no = p_esn
   AND pi.x_domain = 'PHONES'
   AND pi.status2x_code_table = ct.objid;
   get_esn_new_status_rec get_esn_new_status_cur%ROWTYPE;
   --End CR2805 Changes
   --CR2620 - Starts
   CURSOR site_part_curs(
      p_esn VARCHAR2
   )
   IS
   SELECT sp.x_min
   FROM TABLE_SITE_PART sp, TABLE_PART_INST pi
   WHERE pi.x_part_inst2site_part = sp.objid
   AND pi.part_serial_no = p_esn;
   site_part_rec site_part_curs%ROWTYPE;
   --CR2620 Ends
   --
   -- OTA validation:
   --
   /* 1)is ESN active and is esn OTA allowed    |
   |  2) is carrier OTA enabled        |
   |  3)what features on the phone are enabled  |
   */
   -- 1) is ESN active
   CURSOR cur_is_esn_active
   IS
   SELECT tpn.x_ota_allowed,
      txct.x_code_name,
      tpiesn.part_inst2carrier_mkt,
      tpn.objid,
      tpiesn.x_part_inst_status
   FROM TABLE_MOD_LEVEL tml, TABLE_PART_NUM tpn, TABLE_X_CODE_TABLE txct,
   TABLE_PART_INST tpiesn
   WHERE tpn.objid = tml.part_info2part_num
   AND tml.objid = tpiesn.n_part_inst2part_mod
   AND tpiesn.x_part_inst_status = txct.x_code_number
   AND tpiesn.x_domain = 'PHONES'
   AND txct.x_code_number = Ota_Util_Pkg.esn_active
   AND tpiesn.part_serial_no = p_esn;
   -- 2) is carrier OTA enabled
   CURSOR cur_is_carrier_ota_type
   IS
   SELECT txp.x_ota_carrier
   FROM TABLE_PART_INST tpiesn, TABLE_PART_INST tpimin, TABLE_X_PARENT txp,
   TABLE_X_CARRIER_GROUP txcg, TABLE_X_CARRIER txc, TABLE_X_CODE_TABLE txct
   WHERE txc.objid = tpimin.part_inst2carrier_mkt
   AND txp.objid = txcg.x_carrier_group2x_parent
   AND txcg.objid = txc.carrier2carrier_group
   AND tpiesn.objid = tpimin.part_to_esn2part_inst
   AND tpimin.x_part_inst_status = txct.x_code_number
   AND tpiesn.x_domain = 'PHONES'
   AND tpimin.x_domain = 'LINES'
   AND txct.x_code_number IN (Ota_Util_Pkg.msid_update, Ota_Util_Pkg.line_active
   , Ota_Util_Pkg.pending_ac_change )
   AND tpiesn.part_serial_no = p_esn;
   -- 3) what features on the phone are enabled
   -- this is the assumption for now:
   -- if handset is unlocked we will proceed with sending the message to the phone
   CURSOR cur_get_ota_features
   IS
   SELECT tof.x_handset_lock,
      tof.x_redemption_menu,
      tof.x_psms_destination_addr
   FROM TABLE_X_OTA_FEATURES tof, TABLE_PART_INST tpi
   WHERE tpi.objid = tof.x_ota_features2part_inst
   AND tpi.part_serial_no = p_esn;
   -- For OTA activation only: is ESN OTA enabled
   b_ota_activation BOOLEAN := FALSE;
   CURSOR cur_is_ota_activation
   IS
   SELECT tpn.x_ota_allowed,
      tpiesn.x_part_inst_status
   FROM TABLE_MOD_LEVEL tml, TABLE_PART_NUM tpn, TABLE_PART_INST tpiesn
   WHERE tpn.objid = tml.part_info2part_num
   AND tml.objid = tpiesn.n_part_inst2part_mod
   AND tpiesn.x_domain = 'PHONES'
   AND x_part_inst_status IN (Ota_Util_Pkg.esn_new, Ota_Util_Pkg.esn_refurbished
   , Ota_Util_Pkg.esn_used, Ota_Util_Pkg.esn_pastdue ) --CR6293
   AND tpiesn.part_serial_no = p_esn;
   --CR6451 POSA flag management
   CURSOR posa_info_cur(
      p_site_id IN VARCHAR2
   )
   IS
   SELECT pfd.posa_phone
   FROM X_POSA_FLAG_DEALER pfd
   WHERE pfd.site_id = p_site_id;
   posa_info_rec posa_info_cur%ROWTYPE;
   --CR6731 1.0.1.1
   CURSOR cur_get_iccid_flag(
      ip_source_system IN VARCHAR2
   )
   IS
   SELECT x_sim_req
   FROM TABLE_X_OTA_PARAMS
   WHERE x_source_system = ip_source_system;
   get_iccid_flag_rec cur_get_iccid_flag%ROWTYPE;

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
   and pc.name  = v_part_class_name
   and pv.x_param_value= '1' ; -- p_subsourcesystem ;

   rec_subsourcesystem cur_subsourcesystem%ROWTYPE;
   -- CR8663 SWITCH END

   v_source VARCHAR2(20);
   --CR6731 1.0.1.1
   v_tech VARCHAR2 (50);
   v_temp_sp BOOLEAN;
   v_cc_count NUMBER;
   v_reading_found NUMBER := 0;
   v_extra_info_1 VARCHAR2 (20);
   v_extra_info_2 VARCHAR2 (20);
   v_extra_info_3 VARCHAR2 (20);
   v_extra_info_4 VARCHAR2 (20); --CR2490
   v_extra_info_5 VARCHAR2 (20); --CR2490
   v_extra_info_6 VARCHAR2 (20);
   extra_info_7 CONSTANT NUMBER (1) := 1;
   -- ota elements
   v_extra_info_8 NUMBER (1);
   v_extra_info_9 NUMBER (1);
   v_extra_info_10 NUMBER (1);
   v_extra_info_11 NUMBER (1);
   v_extra_info_12 NUMBER (1);
   v_extra_info_13 NUMBER (1);
   --exchange element (Rev. 1.44)
   v_extra_info_14 NUMBER (1);
   v_tag_no NUMBER := 0;
   v_code_value NUMBER := 0;
   v_result NUMBER := 0;
   v_repl_pend_flag NUMBER := 0;
   --CR3725
   v_hdr_ind NUMBER := 0;
   v_sp_objid NUMBER := 0;
   --CR5694
   --CR6451
   --v_posa_airtime                   VARCHAR(1);
   v_posa_phone VARCHAR(1);
   --CR3740
   --CR7152
   p_err NUMBER;
   p_msg VARCHAR2(50);
   v_part_class_name VARCHAR2(30) ; -- CR8663 SWITCHBASE
   v_non_ppe varchar2(1) := '0' ;
   --CR7152
   TYPE sid_tab
   IS
   TABLE OF TABLE_X_SIDS.x_sid%TYPE INDEX BY BINARY_INTEGER;
   v_old_sid sid_tab;
   v_new_sid sid_tab;
   old_counter INT := 1;
   new_counter INT := 1;
   --Fix OPEN_CURSORS
   PROCEDURE close_open_cursors
   IS
   BEGIN
      IF part_inst_cur%ISOPEN
      THEN
         CLOSE part_inst_cur;
      END IF;
      IF get_esn_new_status_cur%ISOPEN
      THEN
         CLOSE get_esn_new_status_cur;
      END IF;
      IF c_account_exists%ISOPEN
      THEN
         CLOSE c_account_exists;
      END IF;
      IF c_autopay_ac_exists%ISOPEN
      THEN
         CLOSE c_autopay_ac_exists;
      END IF;
      IF c_enrollment_exists%ISOPEN
      THEN
         CLOSE c_enrollment_exists;
      END IF;
      IF c_part_class%ISOPEN
      THEN
         CLOSE c_part_class;
      END IF;
      IF c_reading_date%ISOPEN
      THEN
         CLOSE c_reading_date;
      END IF;
      IF c_orig_act_date%ISOPEN
      THEN
         CLOSE c_orig_act_date;
      END IF;
      IF get_phone_info_cur%ISOPEN
      THEN
         CLOSE get_phone_info_cur;
      END IF;
      IF product_part_cur%ISOPEN
      THEN
         CLOSE product_part_cur;
      END IF;
      IF new_plan_cur%ISOPEN
      THEN
         CLOSE new_plan_cur;
      END IF;
      IF contact_pi_cur%ISOPEN
      THEN
         CLOSE contact_pi_cur;
      END IF;
      IF contact_sp_cur%ISOPEN
      THEN
         CLOSE contact_sp_cur;
      END IF;
      IF cc_cur%ISOPEN
      THEN
         CLOSE cc_cur;
      END IF;
      IF pi_min_cur%ISOPEN
      THEN
         CLOSE pi_min_cur;
      END IF;
      IF new_pers_cur%ISOPEN
      THEN
         CLOSE new_pers_cur;
      END IF;
      IF old_pers_cur%ISOPEN
      THEN
         CLOSE old_pers_cur;
      END IF;
      IF pers_lac_cur%ISOPEN
      THEN
         CLOSE pers_lac_cur;
      END IF;
      IF getpers2sid_cur%ISOPEN
      THEN
         CLOSE getpers2sid_cur;
-- fix 06/09/06 pers_lac_cur;
      END IF;
      IF c_sms_parent%ISOPEN
      THEN
         CLOSE c_sms_parent;
      END IF;
      IF get_pending_repl_cur%ISOPEN
      THEN
         CLOSE get_pending_repl_cur;
-- fix 06/09/06 c_sms_parent;
      -- CLOSE c_sms_parent;
      END IF;
      IF get_pending_redemptions_cur%ISOPEN
      THEN
         CLOSE get_pending_redemptions_cur;
      END IF;
      IF get_phone_info_cur%ISOPEN
      THEN
         CLOSE get_phone_info_cur;
      END IF;
      IF site_cur%ISOPEN
      THEN
         CLOSE site_cur;
      END IF;
      IF default_promo_cur%ISOPEN
      THEN
         CLOSE default_promo_cur;
      END IF;
      IF dealer_promo_cur%ISOPEN
      THEN
         CLOSE dealer_promo_cur;
      END IF;
      IF get_oldsitepart_cur%ISOPEN
      THEN
         CLOSE get_oldsitepart_cur;
      END IF;
      IF contact_pi_cur%ISOPEN
      THEN
         CLOSE contact_pi_cur;
      END IF;
      IF site_part_curs%ISOPEN
      THEN
         CLOSE site_part_curs;
      END IF;
      IF pi_min_cur%ISOPEN
      THEN
         CLOSE pi_min_cur;
      END IF;
      IF get_pending_repl_cur%ISOPEN
      THEN
         CLOSE get_pending_repl_cur;
      END IF;
      IF contact_pi_cur%ISOPEN
      THEN
         CLOSE contact_pi_cur;
      END IF;
      IF contact_sp_cur%ISOPEN
      THEN
         CLOSE contact_sp_cur;
      END IF;
      IF site_part_curs%ISOPEN
      THEN
         CLOSE site_part_curs;
      END IF;
      IF posa_info_cur%ISOPEN
      THEN
         CLOSE posa_info_cur;
      END IF;
      IF activation_promo_used_curs%ISOPEN
      THEN
         CLOSE activation_promo_used_curs;
      END IF;
      --CR6731 1.0.1.1
      IF cur_get_iccid_flag%ISOPEN
      THEN
         CLOSE cur_get_iccid_flag;
      END IF;
      --CR6731 1.0.1.1
      IF Carrier_Pending_Cur%ISOPEN
      THEN
         CLOSE Carrier_Pending_Cur;
      END IF;
      -- CDMA next avail project
      IF Carrier_Pending_React_Cur%ISOPEN
      THEN
         CLOSE Carrier_Pending_React_Cur;
      END IF;
      IF Activation_Pending_Cur%ISOPEN
      THEN
         CLOSE Activation_Pending_Cur;
      END IF;
      -- CR8663 SWITCH BASE
      IF Cur_Subsourcesystem%ISOPEN
      THEN
         CLOSE Cur_Subsourcesystem;
      END IF;

   END close_open_cursors;
--
BEGIN
   v_non_ppe := '0' ; -- CR8663 SWITCH BASE
   v_part_class_name :=' ' ; -- DITTO
   p_pending_red_status := 'FALSE';
   p_click_status := 'FALSE';
   v_temp_sp := FALSE;
   p_part_inst_objid := 0;
   p_redemp_reqd_flg := 0;
   p_warr_end_date := '';
   p_amigo_flg := 0;
   p_promo_units := 0;
   p_promo_access_days := 0;
   p_num_of_cards := 0;
   p_errnum := '0';
   v_cc_count := 0;
   v_extra_info_1 := 0;
   v_extra_info_2 := 0;
   v_extra_info_3 := 0;
   v_extra_info_4 := 0;
   v_extra_info_5 := 0;
   v_extra_info_6 := 0;
   -- element 7 is constant, see variable EXTRA_INFO_7
   -- OTA extra info elements:
   v_extra_info_8 := 0; -- is esn active
   v_extra_info_9 := 0; -- is esn ota allowed
   v_extra_info_10 := 0; -- is carrier ota type
   v_extra_info_11 := 1; -- is handset locked
   v_extra_info_12 := 0; -- is redemption menu on the handset enabled
   v_extra_info_13 := 0; -- is psms destination address on the phone
   v_extra_info_14 := 0; -- is original act date is > or < 30 days (Rev 1.44)
   v_tag_no := 0;
   p_last_call_trans := 0 ;
   OPEN part_inst_cur (p_esn);
   FETCH part_inst_cur
   INTO part_inst_rec;
   IF part_inst_cur%FOUND
   THEN
      p_part_inst_objid := NVL (part_inst_rec.objid, 0);
      p_code_number := NVL (part_inst_rec.x_code_number, 0);
      p_code_name := NVL (part_inst_rec.x_code_name, 0);
      p_warr_end_date := TO_CHAR (part_inst_rec.warr_end_date, 'MM/DD/YYYY');
      v_tag_no := NVL (part_inst_rec.pi_tag_no, 0);
      v_code_value := NVL (part_inst_rec.x_value, 0);
      v_hdr_ind := NVL (part_inst_rec.hdr_ind, 0); --CR3740 Changes
      --CR2805 Changes
      p_seq := NVL (part_inst_rec.x_sequence, 0); --CR4245
      p_iccid := part_inst_rec.x_iccid; --CR6731
      p_iccid_flag := part_inst_rec.x_iccid_flag; --CR6731
      --CR7152
      --SA.Clean_Tnumber_Prc(p_esn, p_err, p_msg); --CR8406
      OPEN site_cur (p_esn);
      FETCH site_cur
      INTO site_rec;
      CLOSE site_cur;
      --CR6451
      OPEN posa_info_cur(site_rec.site_id);
      FETCH posa_info_cur
      INTO posa_info_rec;
      IF posa_info_cur%FOUND
      THEN

         --v_posa_airtime := posa_info_rec.posa_airtime;
         v_posa_phone := posa_info_rec.posa_phone;
         IF ((v_posa_phone = 'Y')
         AND (p_code_number = '59'))
         THEN

            --CR3477 Start
            --     sa.Posa.make_phone_active ( p_esn, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            -- v_result, 'ORACLE' );
            sa.Posa.make_phone_active (p_esn, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, v_result, 'POSA_FLAG_ON' );
         END IF;
      END IF;
      --CR3477 End
      IF v_result = 0
      THEN
         OPEN get_esn_new_status_cur (p_esn);
         FETCH get_esn_new_status_cur
         INTO get_esn_new_status_rec;
         IF get_esn_new_status_cur%FOUND
         THEN
            p_code_number := get_esn_new_status_rec.x_code_number;
            p_code_name := get_esn_new_status_rec.x_code_name;
         ELSE
            p_errnum := '106';
            p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH')
            ;
            --             p_errstr := 'Serial Number Status Incorrect';
            close_open_cursors; --Fix OPEN_CURSORS
            RETURN;
         END IF;
         CLOSE get_esn_new_status_cur;
      ELSE
         p_errnum := '106';
         p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
         --   p_errstr := 'Serial Number Status Incorrect';
         close_open_cursors; --Fix OPEN_CURSORS
         RETURN;
      END IF;
      --End CR2805 Changes
      /*CR2722 : Shows error when tagged and not WEBCSR */
      --IF (NVL (p_source_system,'IVR') <> 'WEBCSR') AND (v_tag_no = 1) AND (p_code_number = '50')  THEN
      --   p_errnum := '105';
      --   p_errstr := 'Error: Prepaid Software Inactive';
      --   RETURN;
      --END IF;
      --Changes for My Account
      OPEN c_account_exists (p_esn);
      FETCH c_account_exists
      INTO r_account_exists;
      CLOSE c_account_exists;
      v_extra_info_3 := r_account_exists.cnt;
      IF v_extra_info_3 > 1
      THEN
         v_extra_info_3 := 1;
      END IF;
      p_extra_info := v_extra_info_1 || v_extra_info_2 || v_extra_info_3 ||
      v_extra_info_4 || v_extra_info_5 || v_extra_info_6 || extra_info_7 ||
      -- ota elements:
      v_extra_info_8 || v_extra_info_9 || v_extra_info_10 || v_extra_info_11 ||
      v_extra_info_12 || v_extra_info_13
      --exch element
      || v_extra_info_14;
      --dbms_output.put_line('Value of v_extra_info_3 is: ' || v_extra_info_3);
      --End Changes for My Account
      --Changes for Deactivation Protection EZ Web Enrollment
      OPEN c_autopay_ac_exists (p_esn);
      FETCH c_autopay_ac_exists
      INTO r_autopay_ac_exists;
      CLOSE c_autopay_ac_exists;
      v_extra_info_6 := r_autopay_ac_exists.cnt;
      IF v_extra_info_6 > 1
      THEN
         v_extra_info_6 := 1;
      END IF;
      --If the customer is not enrolled check if we are trying to enroll him using EZ Web enrollment
      IF v_extra_info_6 = 0
      THEN
         OPEN c_enrollment_exists (p_esn);
         FETCH c_enrollment_exists
         INTO r_enrollment_exists;
         CLOSE c_enrollment_exists;
         v_extra_info_6 := r_enrollment_exists.cnt;
         IF v_extra_info_6 > 1
         THEN
            v_extra_info_6 := 1;
         END IF;
      END IF;
      p_extra_info := v_extra_info_1 || v_extra_info_2 || v_extra_info_3 ||
      v_extra_info_4 || v_extra_info_5 || v_extra_info_6 || extra_info_7 ||
      -- ota elements:
      v_extra_info_8 || v_extra_info_9 || v_extra_info_10 || v_extra_info_11 ||
      v_extra_info_12 || v_extra_info_13
      --exch element
      || v_extra_info_14;
      --End Changes for Deactivation Protection EZ Web Enrollment
      --CR2253
      OPEN c_part_class;
      FETCH c_part_class
      INTO r_part_class;
      IF c_part_class%FOUND
      THEN
         p_part_class := NVL (r_part_class.NAME, 'NA');
      ELSE
         p_part_class := 'NA';
      END IF;
      CLOSE c_part_class;
      --End CR2253;
      --Changes for MAX
      OPEN c_reading_date (p_esn);
      FETCH c_reading_date
      INTO r_reading_date;
      IF c_reading_date%FOUND
      AND r_reading_date.x_req_date_time
      IS
      NOT NULL
      THEN
         v_reading_found := 1;
      ELSE
         v_reading_found := 0;
      END IF;
      CLOSE c_reading_date;
      OPEN c_orig_act_date (p_esn);
      FETCH c_orig_act_date
      INTO r_orig_act_date;
      IF c_orig_act_date%FOUND
      THEN

         --IF TRUNC (SYSDATE - r_orig_act_date.orig_act_date) > 365        CR3740
         IF TRUNC (SYSDATE - r_orig_act_date.orig_act_date) > 90 --CR3740
         AND v_reading_found = 0
         THEN
            v_extra_info_1 := 1;

         --ELSIF TRUNC (SYSDATE - r_reading_date.x_req_date_time) > 365    CR3740
         ELSIF TRUNC (SYSDATE - r_reading_date.x_req_date_time) > 90
         --CR3740
         AND v_reading_found = 1
         THEN
            v_extra_info_1 := 1;
         ELSE
            v_extra_info_1 := 0;
         END IF;
         --Rev 1.44 start
         IF TRUNC (SYSDATE - r_orig_act_date.orig_act_date) >= 30
         THEN
            v_extra_info_14 := 1;
         ELSE
            v_extra_info_14 := 0;
         END IF;

      --Rev 1.44 end
      ELSE
         v_extra_info_1 := 0;
         v_extra_info_14 := 0;
--Rev 1.44
      END IF;
      CLOSE c_orig_act_date;
      --End Changes for MAX
      -- Start CR3740
      IF v_hdr_ind = 1
      THEN
         v_extra_info_1 := 1;
      END IF;
      --End CR3740
      --CR2860 Changes
      p_extra_info := v_extra_info_1 || v_extra_info_2 || v_extra_info_3 ||
      v_extra_info_4 || v_extra_info_5 || v_extra_info_6 || extra_info_7 ||
      -- ota elements:
      v_extra_info_8 || v_extra_info_9 || v_extra_info_10 || v_extra_info_11 ||
      v_extra_info_12 || v_extra_info_13
      --exch element
      || v_extra_info_14;

   --End CR2860 Changes
   -- CR5150 did not remove this just moved it def 110
   --       IF (p_code_number != '52' AND part_inst_rec.x_port_in = 1)
   --       THEN
   --      -- CR5150
   --          p_errnum := '750';
   --          p_errstr :=
   --             'Your transaction can not be completed at this time.  Your telephone number is in the process of being switched between carriers. Please call 1-800- 867-7183 to check on the status of this case.';
   --          close_open_cursors;                               --Fix OPEN_CURSORS
   --          RETURN;
   --       END IF;
   ELSE
      p_errnum := '101';
      p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
      --    p_errstr     := 'Serial Number not found';
      close_open_cursors; --Fix OPEN_CURSORS
      RETURN;
   END IF;
   CLOSE part_inst_cur;
   OPEN get_phone_info_cur (p_esn);
   FETCH get_phone_info_cur
   INTO get_phone_info_rec;
   IF get_phone_info_cur%FOUND
   THEN
      p_phone_model := get_phone_info_rec.part_number;
      p_phone_technology := get_phone_info_rec.x_technology;
      p_int_dll := NVL (get_phone_info_rec.x_dll, 0);
      p_phone_description := NVL (SUBSTR (get_phone_info_rec.description, 1, 30
      ), 0);
      p_amigo_flg := get_phone_info_rec.x_restricted_use;
      p_manufacturer := get_phone_info_rec.x_manufacturer; --CR3733

      v_part_class_name := r_part_class.name; -- CR8663 SWITCH

      -- CR8663 SWITCH
      OPEN Cur_Subsourcesystem (v_part_class_name) ;
      --, p_subsourcesystem);
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

      /* CR3190 Start
             WILL REPLACE WITH NEW LOGIC FOR 10_CENTS
             IF p_amigo_flg > 1
      THEN
          p_amigo_flg := 0;
      END IF;
             /* logic for 10_CENTS*/
      --
      -- CR5150 did not remove this just moved it def 110 new area begin
      -- CR6488 fixed problem with the error string 750
      IF (p_code_number != '52'
      AND part_inst_rec.x_port_in = 1)
      THEN
--      -- CR5150
         p_errnum := '120';
         p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
         --    p_errstr := 'Your transaction can not be completed at this time.
         --    Your telephone number is in the process of being switched between carriers.
         --    Please call 1-800- 867-7183 to check on the status of this case.';
         close_open_cursors; --Fix OPEN_CURSORS
         RETURN;
      END IF;
      -- CR5150 did not remove this just moved it def 110 new area end
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
         --       p_errstr    := 'ESN is not for NET-10';
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
         --   p_errstr     := 'ESN is marked for NET-10';
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
      --CR3190 End
      /*CR2722 : Shows error when tagged and not WEBCSR or NETCSR */
      IF ( (NVL (p_source_system, 'IVR') <> 'WEBCSR')
      AND (NVL (p_source_system, 'IVR') <> 'NETCSR') ) --CR3979
      AND (v_tag_no = 1)
      AND (p_code_number = '50')
      THEN
         p_errnum := '103';
         p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
         --    p_errstr    := 'Error: Prepaid Software Inactive';
         close_open_cursors; --Fix OPEN_CURSORS
         RETURN;
      END IF;
   ELSE
      p_errnum := '104';
      p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
      --  p_errstr := 'No mod level record found';
      close_open_cursors; --Fix OPEN_CURSORS
      RETURN;
   END IF;
   --CR4332-1 Starts
   IF (NVL (p_source_system, 'IVR') IN ('WEBCSR', 'NETCSR')
   AND (v_tag_no = 2) )
   THEN
      UPDATE TABLE_PART_INST SET pi_tag_no = 0
      WHERE part_serial_no = p_esn;
      COMMIT;
   ELSIF ( (NVL (p_source_system, 'IVR') <> 'WEBCSR')
   AND (NVL (p_source_system, 'IVR') <> 'NETCSR') ) --CR3979
   AND (v_tag_no = 2)
   THEN
      p_errnum := '105';
      p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
      --    p_errstr := 'Error: Carrier Technology Problem';
      close_open_cursors; --Fix OPEN_CURSORS
      RETURN;
   END IF;
   --CR4332-1 Ends
   CLOSE get_phone_info_cur;
   IF p_code_number = '50'
   OR p_code_number = '150'
   THEN
      p_redemp_reqd_flg := 0;
   ELSIF p_code_number = '52'
   OR p_code_number = '54'
   THEN
      p_redemp_reqd_flg := 1;
   ELSIF p_code_number = '51'
   OR p_code_number = '53'
   THEN
      IF part_inst_rec.warr_end_date > SYSDATE
      THEN
         p_redemp_reqd_flg := 0;
      ELSE
         p_redemp_reqd_flg := 1;
      END IF;
   ELSE
      p_errnum := '106';
      p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
      --      p_errstr := 'Serial Number Status incorrect';
      close_open_cursors; --Fix OPEN_CURSORS
      RETURN;
   END IF;
   -- OTA CDMA Activation project
   OPEN Carrier_Pending_Cur(p_esn) ;
   FETCH Carrier_Pending_Cur
   INTO Carrier_Pending_Rec ;
   IF Carrier_Pending_Cur%FOUND
   THEN
      p_last_call_trans := NVL (carrier_pending_rec.ct_objid, 0);
      p_contact_id := TO_CHAR (carrier_pending_rec.x_part_inst2contact);
      p_zipcode := NVL (carrier_pending_rec.x_zipcode, 'NA');
      p_min := NVL (carrier_pending_rec.x_min, 'NA');
      p_errnum := '116';
      p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
      --CR7814
      IF p_code_number = '54'
      THEN
         OPEN get_pending_repl_cur (p_esn);
         FETCH get_pending_repl_cur
         INTO get_pending_repl_rec;
         IF get_pending_repl_cur%FOUND
         THEN
            IF (p_source_system = 'WEBCSR'
            OR p_source_system = 'NETCSR')
            THEN
               p_redemp_reqd_flg := 0;
            END IF;
         END IF;
         CLOSE get_pending_repl_cur;
         IF part_inst_rec.warr_end_date > SYSDATE
         THEN
            p_redemp_reqd_flg := 0;
         END IF;
      END IF;
      close_open_cursors;
      RETURN;
   END IF;

   ---
   -- CDMA Activation project for reactivations
   OPEN Carrier_Pending_React_Cur(p_esn) ;
   FETCH Carrier_Pending_React_Cur
   INTO Carrier_Pending_React_Rec ;
   IF Carrier_Pending_React_Cur%FOUND
   THEN
      p_last_call_trans := NVL (carrier_pending_React_rec.ct_objid, 0);
      p_contact_id := TO_CHAR (carrier_pending_react_rec.x_part_inst2contact);
      p_zipcode := NVL (carrier_pending_react_rec.x_zipcode, 'NA');
      p_min := NVL (carrier_pending_react_rec.x_min, 'NA');
      p_errnum := '116';
      p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
      --CR7814
      IF p_code_number = '54'
      THEN
         OPEN get_pending_repl_cur (p_esn);
         FETCH get_pending_repl_cur
         INTO get_pending_repl_rec;
         IF get_pending_repl_cur%FOUND
         THEN
            IF (p_source_system = 'WEBCSR'
            OR p_source_system = 'NETCSR')
            THEN
               p_redemp_reqd_flg := 0;
            END IF;
         END IF;
         CLOSE get_pending_repl_cur;
         IF part_inst_rec.warr_end_date > SYSDATE
         THEN
            p_redemp_reqd_flg := 0;
         END IF;
      END IF;
      close_open_cursors;
      RETURN;
   END IF;
   -- CDMA Activation project for reactivations
   OPEN Activation_Pending_Cur(p_esn) ;
   FETCH Activation_Pending_Cur
   INTO Activation_Pending_Rec ;
   IF Activation_Pending_Cur%FOUND
   THEN
      p_last_call_trans := NVL (activation_pending_rec.ct_objid, 0);
      p_contact_id := TO_CHAR (activation_pending_rec.x_part_inst2contact);
      p_zipcode := NVL (activation_pending_rec.x_zipcode, 'NA');
      p_min := NVL (activation_pending_rec.x_min, 'NA');
      p_errnum := '117';
      p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
      close_open_cursors;
      RETURN;
   END IF;
   -- OTA CDMA Activation project END
   IF (p_code_number = '52')
   THEN
--status code111
      OPEN product_part_cur (p_esn);
      FETCH product_part_cur
      INTO product_part_rec;
      IF product_part_cur%FOUND
      THEN
         p_zipcode := product_part_rec.x_zipcode;
         p_min := product_part_rec.x_min;
         --CR2599
         /*
             OPEN  promo_cur(product_part_rec.objid);
             FETCH promo_cur into promo_rec;
             IF promo_cur%found THEN
             p_pending_red_status := 'TRUE';
             END IF;
             p_promo_units := promo_rec.x_units;
             CLOSE promo_cur;
             */
         OPEN new_plan_cur (product_part_rec.objid);
         FETCH new_plan_cur
         INTO new_plan_rec;
         IF new_plan_cur%FOUND
         THEN
            p_click_status := 'TRUE';
         END IF;
         CLOSE new_plan_cur;
         OPEN contact_pi_cur (p_esn);
         FETCH contact_pi_cur
         INTO contact_pi_rec;
         IF contact_pi_cur%FOUND
         THEN
            p_contact_id := TO_CHAR (contact_pi_rec.objid);
            p_contact_phone := contact_pi_rec.phone;
            --CR2490
            p_contact_email := contact_pi_rec.e_mail;
            --CR2599
            IF TO_CHAR (contact_pi_rec.x_dateofbirth, 'mm/dd/yyyy') <>
            '01/01/1753'
            AND contact_pi_rec.x_dateofbirth
            IS
            NOT NULL
            THEN
               v_extra_info_5 := 1;
            END IF;
            IF contact_pi_rec.x_pin
            IS
            NOT NULL
            THEN
               v_extra_info_4 := 1;
            END IF;
         ELSE
            OPEN contact_sp_cur (product_part_rec.objid);
            FETCH contact_sp_cur
            INTO contact_sp_rec;
            p_contact_id := TO_CHAR (contact_sp_rec.objid);
            p_contact_phone := contact_sp_rec.phone;
            p_contact_email := contact_sp_rec.e_mail;
            --CR2599
            IF TO_CHAR (contact_sp_rec.x_dateofbirth, 'mm/dd/yyyy') <>
            '01/01/1753'
            AND contact_sp_rec.x_dateofbirth
            IS
            NOT NULL
            THEN
               v_extra_info_5 := 1;
            END IF;
            IF contact_sp_rec.x_pin
            IS
            NOT NULL
            THEN
               v_extra_info_4 := 1;
            END IF;
            CLOSE contact_sp_cur;
         END IF;
         CLOSE contact_pi_cur;
         --CR2852 Changes
         --      FOR cc_rec IN cc_cur (p_contact_id)
         --      LOOP
         --    v_cc_count := v_cc_count + 1;
         --      END LOOP;
         OPEN cc_cur (p_contact_id);
         FETCH cc_cur
         INTO cc_rec;
         CLOSE cc_cur;
         v_cc_count := cc_rec.count_cc;
         --End CR2852 Changes
         p_num_of_cards := v_cc_count;
         OPEN pi_min_cur (product_part_rec.x_min);
         FETCH pi_min_cur
         INTO pi_min_rec;
         CLOSE pi_min_cur;
         --Changes for MAX
         IF ((pi_min_rec.x_port_in = 1)
         OR (pi_min_rec.x_port_in = 2) ) --CR5456
         THEN
            v_extra_info_2 := 1;
         ELSE
            v_extra_info_2 := 0;
         END IF;
         --End Changes for MAX
         --CR2860 Changes
         p_extra_info := v_extra_info_1 || v_extra_info_2 || v_extra_info_3 ||
         v_extra_info_4 || v_extra_info_5 || v_extra_info_6 || extra_info_7 ||
         -- ota elements:
         v_extra_info_8 || v_extra_info_9 || v_extra_info_10 || v_extra_info_11
         || v_extra_info_12 || v_extra_info_13
         --exch element
         || v_extra_info_14;
         --End CR2860 Changes
         IF (pi_min_rec.x_part_inst_status = '34')
         THEN
            IF ( p_source_system = 'WEB'
            OR p_source_system = 'WEBCSR'
            OR p_source_system = 'NETWEB'
            OR p_source_system = 'NETHANDSET'
            OR p_source_system = 'NETBATCH'
            --- Billing Platform Changes - CR4479
            OR p_source_system = 'TRACBATCH'
            --- Billing Platform Changes - CR4479
            OR p_source_system = 'NETCSR' ) --CR3190
            THEN
               p_errnum := '108';
               p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum,
               'ENGLISH') ;

            --   p_errstr := 'Area Code Change Required';
            ELSE
               p_errnum := '108';
               p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum,
               'ENGLISH') ;
               --       p_errstr    := 'Area Code Change Required';
               close_open_cursors; --Fix OPEN_CURSORS
               RETURN;
            END IF;
         ELSIF (pi_min_rec.x_part_inst_status = '110')
         THEN
            IF ( p_source_system = 'WEBCSR'
            OR p_source_system = 'NETHANDSET'
            OR p_source_system = 'NETBATCH'
            --- Billing Platform Changes - CR4479
            OR p_source_system = 'TRACBATCH'
            --- Billing Platform Changes - CR4479
            OR p_source_system = 'NETCSR' ) --CR3190
            THEN
               p_errnum := '109';
               p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum,
               'ENGLISH') ;

            --      p_errstr := 'MSID Code Change Required';
            ELSE
               p_errnum := '109';
               p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum,
               'ENGLISH') ;

            --      p_errstr := 'MSID Code Change Required';
            --               close_open_cursors;                         --Fix OPEN_CURSORS
            --               RETURN; --CR4473
            END IF;
         END IF;
         OPEN new_pers_cur (pi_min_rec.objid);
         FETCH new_pers_cur
         INTO new_pers_rec;
         IF new_pers_cur%FOUND
         THEN

            --Set Intial value to false
            p_pers_status := 'FALSE';
            OPEN old_pers_cur (pi_min_rec.objid);
            FETCH old_pers_cur
            INTO old_pers_rec;
            CLOSE old_pers_cur;
            --CR2912 Changes
            --      OPEN pers_lac_cur (p_esn);
            OPEN pers_lac_cur (pi_min_rec.part_serial_no, p_phone_technology);
            --End CR2912 Changes
            FETCH pers_lac_cur
            INTO pers_lac_rec;
            IF pers_lac_cur%NOTFOUND
            THEN
               CLOSE pers_lac_cur;
               OPEN pers_lac_cur (pi_min_rec.part_serial_no, 'MASTER');
               FETCH pers_lac_cur
               INTO pers_lac_rec;
            END IF;
            CLOSE pers_lac_cur;
            --DBMS_OUTPUT.put_line('new pers ' || pers_lac_rec.x_sid);
            OPEN getpers2sid_cur (new_pers_rec.objid, p_phone_technology);
            FETCH getpers2sid_cur
            INTO getpers2sid_rec;
            IF getpers2sid_cur%NOTFOUND
            THEN
               CLOSE getpers2sid_cur;
               OPEN getpers2sid_cur (new_pers_rec.objid, 'MASTER');
               FETCH getpers2sid_cur
               INTO getpers2sid_rec;
            END IF;
            CLOSE getpers2sid_cur;
            --DBMS_OUTPUT.put_line('old pers ' || getpers2sid_rec.x_sid);
            --If Master or Technology SID don't match then flagged for Personality Update
            IF (pers_lac_rec.x_sid <> getpers2sid_rec.x_sid)
            THEN
               p_pers_status := 'TRUE';
            END IF;
            /*FOR getpers2sid_rec IN getpers2sid_cur (new_pers_rec.objid)
            LOOP
               IF (pers_lac_rec.x_sid = getpers2sid_rec.x_sid)
               THEN
                  p_pers_status := 'TRUE';
               ELSE
                  p_pers_status := 'FALSE';
               END IF;

               EXIT;
            END LOOP;
            */
            --Compare Local SIDs for non-GSM phones
            IF p_phone_technology <> 'GSM'
            AND p_pers_status <> 'TRUE'
            THEN
               FOR pers_lac_rec IN pers_lac_cur (pi_min_rec.part_serial_no,
               'LOCAL' )
               LOOP
                  v_old_sid (old_counter) := pers_lac_rec.x_sid;
                  old_counter := old_counter + 1;
               END LOOP;
               old_counter := old_counter - 1;
               FOR getpers2sid_rec IN getpers2sid_cur (new_pers_rec.objid,
               'LOCAL' )
               LOOP
                  v_new_sid (new_counter) := getpers2sid_rec.x_sid;
                  new_counter := new_counter + 1;
               END LOOP;
               new_counter := new_counter - 1;
               --If number of local sids is different, flag for personality update
               IF old_counter <> new_counter
               THEN
                  p_pers_status := 'TRUE';
               ELSE

                  --If there are local sids in the new personality, flag for a personality update
                  IF new_pers_rec.objid <> old_pers_rec.objid
                  AND new_counter > 0
                  THEN
                     p_pers_status := 'TRUE';
                  END IF;
                  /*FOR i IN 1.. new_counter
                   LOOP
                       IF v_new_sid(i) <> v_old_sid(i) THEN
                          p_pers_status := 'TRUE';
                          EXIT;
                       END IF;
                   END LOOP;*/
                  FOR i IN 1 .. new_counter
                  LOOP
                     IF v_new_sid (new_counter) <> v_old_sid (new_counter)
                     THEN
                        p_pers_status := 'TRUE';
                        EXIT;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
            --Compare the old and new carr_personality to see if any of the values have changed
            IF p_pers_status <> 'TRUE'
            THEN
               IF old_pers_rec.x_restrict_ld <> new_pers_rec.x_restrict_ld
               OR old_pers_rec.x_restrict_callop <> new_pers_rec.x_restrict_callop
               OR old_pers_rec.x_restrict_intl <> new_pers_rec.x_restrict_intl
               OR old_pers_rec.x_restrict_roam <> new_pers_rec.x_restrict_roam
               THEN
                  p_pers_status := 'TRUE';
               END IF;
               IF p_int_dll >= 10
               AND ( old_pers_rec.x_restrict_inbound <> new_pers_rec.x_restrict_inbound
               OR old_pers_rec.x_restrict_outbound <> new_pers_rec.x_restrict_outbound
               )
               THEN
                  p_pers_status := 'TRUE';
               END IF;
               IF (p_int_dll = 6
               OR p_int_dll = 8)
               AND ( old_pers_rec.x_soc_id <> new_pers_rec.x_soc_id
               OR old_pers_rec.x_partner <> new_pers_rec.x_partner
               OR old_pers_rec.x_favored <> new_pers_rec.x_favored
               OR old_pers_rec.x_neutral <> new_pers_rec.x_neutral )
               THEN
                  p_pers_status := 'TRUE';
               END IF;
            END IF;
            --If the ESN is not flagged for Personality Update, but old and new personality
            --are different, reset the flag
            IF p_pers_status <> 'TRUE'
            AND new_pers_rec.objid <> old_pers_rec.objid
            THEN
               UPDATE TABLE_PART_INST SET part_inst2x_pers = new_pers_rec.objid
               , part_inst2x_new_pers = NULL
               WHERE part_serial_no = pi_min_rec.part_serial_no;
               UPDATE TABLE_PART_INST SET part_inst2x_pers = new_pers_rec.objid
               WHERE part_serial_no = p_esn;
               COMMIT;
            END IF;
         ELSE
            p_pers_status := 'FALSE';
         END IF;
         CLOSE new_pers_cur;
         --CR2253
         --CR4382 Starts
         --         OPEN c_sms_parent;
         --CR4981_4982 Start
         --OPEN c_sms_parent(p_phone_technology);
         OPEN c_sms_parent (p_phone_technology, NVL (get_phone_info_rec.x_data_capable
         , 0) );
         --CR4981_4982 End
         --CR4382 Ends
         FETCH c_sms_parent
         INTO r_sms_parent;
         IF c_sms_parent%FOUND
         THEN
            IF p_phone_technology = 'GSM'
            THEN
               p_sms_flag := 1;
            ELSE
               p_sms_flag := NVL (r_sms_parent.x_sms, 0);
            END IF;
            p_parent_id := NVL (r_sms_parent.x_parent_id, 'NA');
         ELSE
            p_sms_flag := 0;
            p_parent_id := 'NA';
         END IF;
         CLOSE c_sms_parent;

      --CR2818 Changes
      -- --End CR2253
      --      IF (p_source_system = 'WEBCSR')
      --      THEN
      --    OPEN pend_redemp_cur (product_part_rec.objid);
      --    FETCH pend_redemp_cur INTO pend_redemp_rec;
      --
      --    IF pend_redemp_cur%FOUND
      --    THEN
      --       p_redemp_reqd_flg := 0;
      --    END IF;
      --
      --    CLOSE pend_redemp_cur;
      --      END IF;
      -- --CR2196
      -- --CR2072
      --     IF (p_source_system = 'WEB')
      --      IF p_source_system IN ('WEB',  'IVR')
      -- --End CR2072
      --
      --      THEN
      --    OPEN get_pending_redemptions_cur (p_esn);
      --    FETCH get_pending_redemptions_cur INTO get_pending_redemptions_rec;
      --
      --
      --    IF get_pending_redemptions_cur%FOUND
      --    THEN
      --       p_errnum := '110';
      --       p_errstr := 'This ESN is Active and has pending redemptions';
      --       RETURN;
      --    END IF;
      --      END IF;
      -- --End CR2196
      --CR3725 Starts
      -- Executing the Cursor 'get_pending_repl_cur' moved to end of the code CR6403 .. Ramu --
      --End CR2818 Changes
      ELSE
         p_errnum := '119';
         p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
         --       p_errstr := 'Active Service Not Found';
         close_open_cursors; --Fix OPEN_CURSORS
         RETURN;
         p_errnum := '106';
         p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;

      --   p_errstr := 'Serial Number Status Incorrect';
      END IF;
      CLOSE product_part_cur;
   ELSIF (p_code_number = '50'
   OR p_code_number = '150')
   THEN
--status code111
      OPEN get_phone_info_cur (p_esn);
      FETCH get_phone_info_cur
      INTO get_phone_info_rec;
      CLOSE get_phone_info_cur;
      IF (get_phone_info_rec.x_technology <> 'ANALOG')
      THEN
         v_tech := 'DIGITAL';
         IF ( get_phone_info_rec.prog_type = '2'
         AND get_phone_info_rec.x_part_inst_status = '50' ) -- CR3190
         THEN
            v_tech := 'DIGITAL2';
         END IF;
      END IF;
      /*   OPEN site_cur (p_esn);

      FETCH site_cur
       INTO site_rec;

      CLOSE site_cur;*/
      --CR3190 STARTS
      IF (get_phone_info_rec.x_restricted_use = 3)
      THEN
         v_tech := 'DIGITAL3';
         IF ( get_phone_info_rec.prog_type = '2'
         AND get_phone_info_rec.x_part_inst_status = '150' ) -- CR3190
         THEN
            v_tech := 'DIGITAL4';
         END IF;
         OPEN default_promo_cur (v_tech);
         FETCH default_promo_cur
         INTO default_promo_rec;
         -- CR5728
         OPEN activation_promo_used_curs (p_esn);
         FETCH activation_promo_used_curs
         INTO activation_promo_used_rec;
         -- CR5728
         IF default_promo_cur%FOUND
         AND activation_promo_used_curs%NOTFOUND
         THEN
            p_promo_units := default_promo_rec.x_units;
            p_promo_access_days := default_promo_rec.x_access_days;
            p_pending_red_status := 'TRUE';
         END IF;
         CLOSE default_promo_cur;
         CLOSE activation_promo_used_curs;
      ELSE

         --CR3190 END
         OPEN dealer_promo_cur (site_rec.objid);
         FETCH dealer_promo_cur
         INTO dealer_promo_rec;
         IF dealer_promo_cur%NOTFOUND
         THEN
            OPEN default_promo_cur (v_tech);
            FETCH default_promo_cur
            INTO default_promo_rec;
            -- CR5728
            OPEN activation_promo_used_curs (p_esn);
            FETCH activation_promo_used_curs
            INTO activation_promo_used_rec;
            -- CR5728
            IF default_promo_cur%FOUND
            AND activation_promo_used_curs%NOTFOUND
            THEN
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
      OPEN get_oldsitepart_cur (part_inst_rec.objid);
      FETCH get_oldsitepart_cur
      INTO get_oldsitepart_rec;
      IF get_oldsitepart_cur%FOUND
      THEN
         p_promo_units := 0;
         p_promo_access_days := 0;
      END IF;
      CLOSE get_oldsitepart_cur;
      OPEN contact_pi_cur (p_esn);
      FETCH contact_pi_cur
      INTO contact_pi_rec;
      IF contact_pi_cur%FOUND
      THEN
         p_contact_id := TO_CHAR (contact_pi_rec.objid);
         p_contact_phone := contact_pi_rec.phone;
         p_contact_email := contact_pi_rec.e_mail;
--CR2599
      END IF;
      CLOSE contact_pi_cur;
      --CR2620 - Check if the line is flagged for an MSID update
      OPEN site_part_curs (p_esn);
      FETCH site_part_curs
      INTO site_part_rec;
      IF site_part_curs%FOUND
      THEN
         OPEN pi_min_cur (site_part_rec.x_min);
         FETCH pi_min_cur
         INTO pi_min_rec;
         IF pi_min_rec.x_part_inst_status = '110'
         THEN
            p_min := site_part_rec.x_min;
            p_errnum := '109';
            p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH')
            ;

         --      p_errstr := 'MSID Code Change Required';
         END IF;
         CLOSE pi_min_cur;
      END IF;
      CLOSE site_part_curs;
--CR2620 Ends
   ELSE

      --CR3824 - Make this check for Past due phones
      IF p_code_number = '54'
      THEN
         OPEN get_pending_repl_cur (p_esn);
         FETCH get_pending_repl_cur
         INTO get_pending_repl_rec;
         IF get_pending_repl_cur%FOUND
         THEN
            IF (p_source_system = 'WEBCSR'
            OR p_source_system = 'NETCSR')
            THEN
               p_redemp_reqd_flg := 0;
            END IF;
         END IF;
         CLOSE get_pending_repl_cur;
         IF part_inst_rec.warr_end_date > SYSDATE
         THEN
            p_redemp_reqd_flg := 0;
         END IF;
      END IF;
      --CR3824 - Ends
      --status code111
      FOR get_oldsitepart_rec2 IN get_oldsitepart_cur2 (p_esn)
      LOOP
         p_zipcode := get_oldsitepart_rec2.x_zipcode;
         v_temp_sp := TRUE;
         v_sp_objid := get_oldsitepart_rec2.objid; --CR5694
         EXIT;
      END LOOP;
      IF (v_temp_sp = FALSE)
      THEN
         p_errnum := '118';
         p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
         --      p_errstr := 'Site Part Record Not Found';
         close_open_cursors; --Fix OPEN_CURSORS
         RETURN;
      END IF;
      OPEN contact_pi_cur (p_esn);
      FETCH contact_pi_cur
      INTO contact_pi_rec;
      IF contact_pi_cur%FOUND
      THEN
         p_contact_id := TO_CHAR (contact_pi_rec.objid);
         p_contact_phone := contact_pi_rec.phone;
         p_contact_email := contact_pi_rec.e_mail;
--CR2599
      ELSE

         --CR5694
         --         OPEN contact_sp_cur(p_esn);
         OPEN contact_sp_cur (v_sp_objid);
         --CR5694
         FETCH contact_sp_cur
         INTO contact_sp_rec;
         IF contact_sp_cur%FOUND
         THEN
            p_contact_id := TO_CHAR (contact_sp_rec.objid);
            p_contact_phone := contact_sp_rec.phone;
            p_contact_email := contact_pi_rec.e_mail;
--CR2599
         ELSE
            p_errnum := '102';
            p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH')
            ;
            --      p_errstr := 'ESN is Active, but no Contact found';
            close_open_cursors; --Fix OPEN_CURSORS
            RETURN;
         END IF;
         CLOSE contact_sp_cur;
      END IF;
      CLOSE contact_pi_cur;
      p_click_status := 'TRUE';
      p_pers_status := 'TRUE';
      --CR2620 - Check if the line is flagged for an MSID update
      OPEN site_part_curs (p_esn);
      FETCH site_part_curs
      INTO site_part_rec;
      IF site_part_curs%FOUND
      THEN
         OPEN pi_min_cur (site_part_rec.x_min);
         FETCH pi_min_cur
         INTO pi_min_rec;
         IF pi_min_rec.x_part_inst_status = '110'
         THEN
            p_min := site_part_rec.x_min;
            p_errnum := '109';
            p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH')
            ;

         --      p_errstr := 'MSID Code Change Required';
         END IF;
         CLOSE pi_min_cur;
      END IF;
      CLOSE site_part_curs;
--CR2620 Ends
   END IF;
   --
   -- OTA validation:
   --
   /*****************************************************
   |  Is OTA Activation in process:       |
   |  If YES - find out if ESN is OTA allowed      |
   |  If NOT - evaluate the following:       |
   |     1)is ESN active and is esn OTA allowed    |
   |     2)is carrier OTA enabled         |
   |     3)what features on the phone are enabled  |
   |  NOTE: all output parameters for OTA       |
   |  validation are initialized right at       |
   |  the start of the procedure       |
   *****************************************************/
   -- is OTA Activation in process?
   FOR cur_is_ota_activation_rec IN cur_is_ota_activation
   LOOP
      b_ota_activation := TRUE;
      IF UPPER (NVL (cur_is_ota_activation_rec.x_ota_allowed, 'N')) = 'Y'
      THEN
         v_extra_info_9 := 1;
      END IF;
   END LOOP;
   IF NOT b_ota_activation
   THEN

      -- 1) is ESN active
      FOR cur_is_esn_active_rec IN cur_is_esn_active
      LOOP
         v_extra_info_8 := 1;
         IF UPPER (NVL (cur_is_esn_active_rec.x_ota_allowed, 'N')) = 'Y'
         THEN
            v_extra_info_9 := 1;
         END IF;
      END LOOP;
      -- 2) is carrier OTA enabled
      FOR cur_is_carrier_ota_type_rec IN cur_is_carrier_ota_type
      LOOP
         IF UPPER (NVL (cur_is_carrier_ota_type_rec.x_ota_carrier, 'N')) = 'Y'
         THEN
            v_extra_info_10 := 1;
         END IF;
      END LOOP;
      -- 3) what features on the phone are enabled
      -- this is the assumption for now:
      -- if handset is unlocked we will proceed with sending the PSMS message to the phone
      FOR cur_get_ota_features_rec IN cur_get_ota_features
      LOOP
         IF UPPER (NVL (cur_get_ota_features_rec.x_handset_lock, 'N')) = 'Y'
         THEN
            v_extra_info_11 := 0;
         END IF;
         IF UPPER (NVL (cur_get_ota_features_rec.x_redemption_menu, 'N')) = 'Y'
         THEN
            v_extra_info_12 := 1;
         END IF;
         -- IF UPPER(NVL(cur_get_ota_features_rec.X_PSMS_DESTINATION_ADDR,'N')) = 'Y'
         IF cur_get_ota_features_rec.x_psms_destination_addr
         IS
         NOT NULL
         THEN
            v_extra_info_13 := 1;
         END IF;
      END LOOP;
   END IF;
   -- NOT b_ota_activation
   p_extra_info := v_extra_info_1 || v_extra_info_2 || v_extra_info_3 ||
   v_extra_info_4 || v_extra_info_5 || v_extra_info_6 || extra_info_7 ||
   -- ota elements:
   v_extra_info_8 || v_extra_info_9 || v_extra_info_10 || v_extra_info_11 ||
   v_extra_info_12 || v_extra_info_13
   --exch element
   || v_extra_info_14;
   -- Moved Cursor execution to here
   -- Start of CR6403 Change -- Ramu
   OPEN get_pending_repl_cur (p_esn);
   FETCH get_pending_repl_cur
   INTO get_pending_repl_rec;
   IF get_pending_repl_cur%FOUND
   THEN
      v_repl_pend_flag := 1;
   ELSE
      v_repl_pend_flag := 0;
   END IF;
   CLOSE get_pending_repl_cur;
   --CR3725 Ends
   OPEN get_pending_redemptions_cur (p_esn);
   FETCH get_pending_redemptions_cur
   INTO get_pending_redemptions_rec;
   IF get_pending_redemptions_cur%FOUND
   OR v_repl_pend_flag = 1 --CR3725
   THEN
      IF ( p_source_system = 'WEBCSR'
      OR p_source_system = 'NETCSR'
      OR p_source_system = 'NETBATCH'
      --- Billing Platform Changes - CR4479
      OR p_source_system = 'TRACBATCH'
      --- Billing Platform Changes - CR4479
      ) --CR3190
      THEN
         p_redemp_reqd_flg := 0;
      END IF;
      IF p_source_system IN ('WEB', 'IVR', 'NETIVR', 'NETWEB', 'NETHANDSET') --CR3190
      THEN
         p_errnum := '110';
         p_errstr := Get_Code_Fun('VALIDATE_PHONE_PRC', p_errnum, 'ENGLISH') ;
         --      p_errstr := 'This ESN is Active and has pending redemptions';
         close_open_cursors; --Fix OPEN_CURSORS
         RETURN;
      END IF;
   END IF;
   CLOSE get_pending_redemptions_cur;
-- End of CR6403 Change
END VALIDATE_PHONE_PRC;
/