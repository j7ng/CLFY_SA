CREATE OR REPLACE PACKAGE sa."POSA_LITE"
AS
/******************************************************************************/
   /*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
   /*                                                                            */
   /* NAME:         posa2.sql                                                    */
   /* PURPOSE:                                                                   */
   /* FREQUENCY:                                                                 */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
   /* REVISIONS:                                                                 */
   /* VERSION  DATE        WHO               PURPOSE                             */
   /* -------  ----------  -------------  -------------------------------------- */
   /* 1.0                                    Initial Revision                    */
   /* 1.1      7/16/2001   Vani Shimoga      IP_STORE_DETAIL is added.           */
   /*                                                                            */
   /* 1.2      7/27/2001   Vani Shimoga   Toppoci.topp_oci_redeem_interface      */
   /*                                     table is not valid anymore. Instead    */
   /*                                     Phoenix project is using sa.posa_swp_  */
   /*                                     loc_act_card table                     */
   /*                                                                            */
   /* 1.3      8/15/2001   Vani Shimoga   GET_CARD_STATUS has been modified to ge*/
   /*                                     the UPC code from table_part_numinstead*/
   /*                                     of mtl_system_items. Procedure assumes */
   /*                                     that it gets the part_num exists in TOS*/
   /*                                     Insertintopartinst procedure is not    */
   /*                                     required any more, because all the part*/
   /*                                     exists in        TOSS.                 */
   /*                                                                            */
   /* 1.4   09/15/2001     Miguel Leon       Inserted debug statements and       */
   /*                                     commented out some useless logic       */
   /*                                     related to inserting into part_inst    */
   /*                                                                            */
   /*1.5  10/11/2001      Miguel Leon     Accomodated suggested changes recommnended  */
   /*                                                      by Lee Manuel.Also    */
   /*                                                      changed when others re*/
   /*                                                      urn code to be sqlerro*/
   /*                                                      and include insertion */
   /*                                                      into the error_table  */
   /*                                                                            */
   /*              1.6  12/18/01      Miguel Leon          Modified all the code */
   /*                                                      to use toss_util_pkg  */
   /*                                                      Also Added new POSA   */
   /*                                                      phones functionalities*/
   /*                                                      (get_phone_status. mak*/
   /*                                                      phone_active/inactive/*/
   /*                                                      returned).This new por*/
   /*                                                      currently will only   */
   /*                                                      work with walmart posa*/
   /*                                                      phones as agreed.     */
   /*                                                                            */
   /*             1.7  01/18/02     Miguel Leon           Added insertion into   */
   /*                                                     x_posa_esn_exception   */
   /*                                                     when make_phone_returne*/
   /*                                                                            */
   /*             1.8  01/23/02    Miguel Leon            Removed logic to check */
   /*                                                     if Vendor is RSEL and  */
   /*                                                     also removed insertion */
   /*                                                     on exception esn table */
   /*                                                     when activating phone  */
   /*                                                     linked to a Distributor*/
   /*                                                                            */
   /*            1.9 02/01/02     Miguel Leon             Added new posa Roadside*/
   /*                                                     cards procedures:      */
   /*                                                     GET_RS_CARD_STATUS()   */
   /*                                                     MAKE_RS_REDEEMABLE()   */
   /*                                                     MAKE_RS_UNREDEEMABLE() */
   /*                                                                            */
   /*            1.10 04/18/02     Miguel Leon       Changed REDEMPTION CARD to  */
   /*                                                REDEMPTION CARDS (plural)   */
   /*                                                within the MAKE_CARD_REDEEM */
   /*                                                ABLE AND MAKE_CARD_UNREDEEM */
   /*                                                ABLE procs                  */
   /*                                                Added IN Parameter SOURCESYS*/
   /*                                                with default value 'POSA' on*/
   /*                                                all the make procs          */
   /*                                                                            */
   /* 1.11  07/27/02   Miguel Leon   Modified MAKE_PHONE_RETURNED to allowed     */
   /*                                PAST_DUE(54), USED(51) and in the event that*/
   /*                                the esn is active, the phone is deactivated */
   /*                                and RESET/REFURB to '59'" ( posa inactive). */
   /*                                MAKE_PHONE_RETUNED will always NOW set the  */
   /*                                status to INACTIVE POSA PHONE (59) upon     */
   /*                                successful completion.                      */
   /*                                Also "hard wired" GET_PHONE_STATUS procedure*/
   /*                                to return '52' (PHONE_ACTIVE) when a phone  */
   /*                                is found with a status of '54' (past_due) or*/
   /*                                '51'(USED). This temporary fix was applied  */
   /*                                to avoid any changes/additions of any return*/
   /*                                codes to the C++ aspects of the posa system.*/
   /*                                Also clean out old commented out coding     */
   /*                                                                            */
   /* 1.12 08/09/02  Miguel Leon    Added detail error logging capabilities to   */
/*                               the following procedures:        end;GET_CARD_STATUS()  */
   /*                               GET_PHONES_STATUS() and GET_RS_STATUS().     */
   /*                                                                            */
   /* 1.13 10/10/09 Miguel Leon     Modified MAKE_CARD_REDEEMABLE, MAKE_CARD_UNRE*/
   /*                               EEMABLE, MAKE_PHONE_ACTIVE, MAKE_PHONE_INACTI*/
   /*                               VE, MAKE_PHONE_RETURNED, MAKE_RS_REDEEMABLE, */
   /*                               MAKE_RS_UNREDEEMABLE to convert the varchar  */
   /*                               ip_time and ip_date to a date and insert it  */
   /*                              into the table x_posa_card, x_posa_phone or   */
   /*                              x_posa_road on a newly added field call toss_ */
   /*                              att_trans_date. Ip_date and ip_time is the    */
   /*                              actual transaction date sent to Tracfone by   */
   /*                              Air Time.                                     */
   /* 1.14 03/17/03 SL             Clarify Upgrade                               */
   /* 1.15 04/10/03 SL             Clarify Upgrade - sequence                    */
   /*                                                                            */
   /* 1.16 02/05/04 GP             IVR/WEBCSR POSA                               */
   /*                                                                            */
   /* 1.17 09/14/04 VA             CR3176 - Added PHONE_SEQ_MISMATCH constant for*/
   /*                                       '55' esn status                      */
   /* 1.18 10/18/04 VA             CR2970 - Insert queued-in transaction data    */
   /*                              in X_POSA_LOG table                           */
   /*----------------------------------------------------------------------------*/
   /* 1.3   02/13/2012    CLindner  CR15722 Blackhawk Network (BHN) (Master)     */
   /*                               new procedure posa_transaction_controller    */
   /******************************************************************************/
   /*****************  Get Card Status (Proc 1)  *****************/
   /*                                                            */
   /* Objective  : To obtain the status of a card based on SMP   */
   /*                                                            */
   /* Returns:                                                   */
   /*              OP_STATUS =  0  if card not found             */
   /*                          40  if card is Reserved           */
   /*                          41  if card is Redeemed           */
   /*                          42  if card is Active/redeemable  */
   /*                          43  if card is Void               */
   /*                          44  if card is Suspended          */
   /*                          45  if card is Inactive           */
   /*                                                            */
   /*              OP_NUM_UNITS = # units associated w/card      */
   /*                             0  if OP_STATUS = 0            */
   /*                                                            */
   /*              OP_UPC_CODE = the UPC code associated w/card  */
   /*                           10 units = 7633 4611 3918        */
   /*                           30 units = 7633 4611 3925        */
   /*                          120 units = 7633 4611 3932        */
   /*                          300 units = 7633 4611 3946        */
   /*                                                            */
   /**************************************************************/
   /**** EXCEPTIONS *****/
   invalid_upc_code EXCEPTION
;
   invalid_status EXCEPTION
;
   failed_updating_status EXCEPTION
;
   failed_inserting_swip_rec EXCEPTION
;
   failed_inserting_pi_hist EXCEPTION
;
   failed_updating_vendor EXCEPTION
;
   failed_insert_posa_excp EXCEPTION
;
   invalid_vendor EXCEPTION
;
   /* not in use at this moment */
   failed_insert_phone_pi EXCEPTION
;
   failer_insert_pi_excp EXCEPTION
;
   failed_insert_ri_excp EXCEPTION
;
--CR53057
   unswipe_upc_mismatch EXCEPTION;

   invalid_md_upc EXCEPTION;

   /***RESULT VALUES ***/
   sucess CONSTANT NUMBER := 0;
   inv_status CONSTANT NUMBER := 1;
   status_change_failed CONSTANT NUMBER := 2;
   swipe_rec_failed CONSTANT NUMBER := 3;
   pi_hist_rec_failed CONSTANT NUMBER := 4;
   vendor_change_failed CONSTANT NUMBER := 5;
   posa_excp_rec_failed CONSTANT NUMBER := 6;
   inv_vendor CONSTANT NUMBER := 7;
   ri_hist_rec_failed CONSTANT NUMBER := 8;
   upc_code_invalid CONSTANT NUMBER := 9;
   --CR53057
   unswipe_upc_mismatch_err CONSTANT NUMBER := 13;
   md_upc_look_up_failed CONSTANT NUMBER := 12; -- Edward confirmed

   /** 1.14 CONSTANT DELARATION   **/
   phone_inactive CONSTANT VARCHAR2 (3) := '59';
   phone_ready CONSTANT VARCHAR2 (3) := '50';
   phone_active CONSTANT VARCHAR2 (3) := '52';
   phone_past_due CONSTANT VARCHAR2 (3) := '54';
   phone_used CONSTANT VARCHAR2 (3) := '51';
   phone_returned CONSTANT VARCHAR2 (3) := '64';
   phone_seq_mismatch CONSTANT VARCHAR2(3) := '55'; --CR3176
   card_inactive CONSTANT VARCHAR2 (3) := '45';
   card_ready CONSTANT VARCHAR2 (3) := '42';
   card_redeemed CONSTANT VARCHAR2 (3) := '41';

   g_controller_response VARCHAR2(1000) := NULL;
   g_incident_id         VARCHAR2(15)   := NULL;  -- added for CR52985

   /****pulic procedures and functions ****/
   PROCEDURE get_card_status(
      ip_smp_num IN VARCHAR2,
      op_status OUT NUMBER,
      op_num_units OUT NUMBER,
      op_upc_code OUT VARCHAR2
   );
   /***************  Make Card Redeemable (Proc 2)  ******************/
   /*                                                                */
   /* Objective  : To change the status of an Inactive (45) card     */
   /*               to Active/redeemable (42)                        */
   /* Returns:                                                       */
   /*              OP_RESULT = 0  successful                         */
   /*                          1  if card status <> 45 (Inactive)    */
   /*                          2  if TABLE_PART_INST update failed   */
   /*                          3  if X_POSA_card insert failed       */
   /*                          4  if Insert into the PI_HIST failed  */
   /*          Oracle Error Code  if OTHER                           */
   /*                                                                */
   /*              OP_NUM_UNITS = # units associated with card, if   */
   /*                                      OP_STATUS = 0             */
   /*                             undefined, if OP_RESULT <> 0       */
   /*                                                                */
   /******************************************************************/
   PROCEDURE make_card_redeemable(
      ip_smp_num IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_num_units OUT NUMBER,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL,
      ip_upc IN VARCHAR2 := NULL
   );
   /**************  Make Card UnRedeemable (Proc 3)  *****************/
   /*                                                                */
   /* Objective  : To change the status of an active/redeemable (42) */
   /*              card to Inactive (45)                             */
   /* Returns:                                                       */
   /*              OP_RESULT = 0  successful                         */
   /*                          1  if card status <> 42 (Active)      */
   /*                          2  if TABLE_PART_INST update failed   */
   /*                          3  if X_POSA_card insert failed       */
   /*                          4  if Insert into the PI_HIST failed  */
   /*          Oracle Error Code  if OTHER                           */
   /*                                                                */
   /*              OP_NUM_UNITS = # units associated with card, if   */
   /*                                      OP_STATUS = 0             */
   /*                             undefined, if OP_RESULT <> 0       */
   /*                                                                */
   /******************************************************************/
   PROCEDURE make_card_unredeemable(
      ip_smp_num IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_num_units OUT NUMBER,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL,
      ip_upc IN VARCHAR2 := NULL
   );
   /**********************  Get Phone Status   ********************/
   /*                                                             */
   /* Objective  : To obtain the phone status based on ESN        */
   /*                                                             */
   /* Returns:                                                    */
   /*              OP_STATUS =  0  if phone not found             */
   /*                          59  if phone is Inactive           */
   /*                          52  if phone is Actived/USED       */
   /*                                   /PAST_DUE                 */
   /*                          50  if phone is Ready (New)        */
   /*                                                         */
   /*              OP_MERCHANT_ID = Dealer Id, if OP_STATUS <> 0  */
   /*                               Undefined, if OP_STATUS == 0  */
   /*                                                             */
   /***************************************************************/
   PROCEDURE get_phone_status(
      ip_smp_num IN VARCHAR2,
      op_upc_code OUT VARCHAR2,
      op_merchant_id OUT VARCHAR2,
      op_status OUT NUMBER
   );
   /*************************  Make Phone Active  ************************/
   /*                                                                    */
   /* Objective  : To change the status of an Inactive (59) phone        */
   /*               to Active (50)                                       */
   /* Returns:                                                           */
   /*              OP_RESULT = -1...-99999 0RA sql error code            */
   /*                                                               */
   /*                           0  successful                            */
   /*                           1  phone not Inactive (status <> 59)     */
   /*                           2  update TABLE_PART_INST failed         */
   /*                           3  insert posa_swp_loc_act_card failed   */
   /*                           4  insert into PI hist table failed      */
   /*                           5  update vendor change failed           */
   /*                           6  insert into the posa_exception fail   */
   /*                              ed                                    */
   /**********************************************************************/
   PROCEDURE make_phone_active(
      ip_esn_num IN VARCHAR2,
      ip_upc_code IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL
   );
   /************************  Make Phone Inactive  ***********************/
   /*                                                                    */
   /* Objective  : To change the status of an Ready  (50) phone          */
   /*               to Inactive (59) (at regiter VOID)                   */
   /* Returns:                                                           */
   /*              OP_RESULT = -1...-99999 0RA sql error code            */
   /*                                                               */
   /*                           0  successful                            */
   /*                                                                    */
   /*                           1  phone not Active (status <> 50)       */
   /*                           2  update TABLE_PART_INST failed         */
   /*                           3  insert x_posa_phone failed            */
   /*                           4  insert into PI hist table failed      */
   /*                           7  Invalid Vendor (non walmart)          */
   /*                                                                    */
   /**********************************************************************/
   PROCEDURE make_phone_inactive(
      ip_esn_num IN VARCHAR2,
      ip_upc_code IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL
   );
   /*************************  Make Phone Returned  **********************/
   /*                                                                    */
   /* Objective  : To change the status of an Active (59) or Ready (50)  */
   /*              or inactive (59) -very rare case-                     */
   /*               phone to Returned (64)                               */
   /* Returns:                                                           */
   /*              OP_RESULT = -1...-99999 0RA sql error code            */
   /*                                                               */
   /*                           0  successful                            */
   /*                                                                    */
   /*                           1  phone Inactive (status <> 52 or 50 or */
   /*                              59 (rare case) )                      */
   /*                           2  update TABLE_PART_INST failed         */
   /*                           3  insert x_posa_phone failed            */
   /*                           4  insert into PI hist table failed      */
   /*                           7  Invalid Vendor (non walmart)          */
   /*                                                                    */
   /**********************************************************************/
   PROCEDURE make_phone_returned(
      ip_esn_num IN VARCHAR2,
      ip_upc_code IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL
   );
   /*****************  Get RoadSide Card Status  *****************/
   /*                                                            */
   /* Objective  : To obtain the status of a card based on SMP   */
   /*                                                            */
   /* Returns:                                                   */
   /*              OP_STATUS =  0  if card not found             */
   /*                          40  if card is Reserved           */
   /*                          41  if card is Redeemed           */
   /*                          42  if card is Active/redeemable  */
   /*                          43  if card is Void               */
   /*                          44  if card is Suspended          */
   /*                          45  if card is Inactive           */
   /*                                                            */
   /*                             0  if OP_STATUS = 0 or 45      */
   /*                                                            */
   /*              OP_UPC_CODE = the UPC code associated w/card  */
   /*                                                            */
   /**************************************************************/
   PROCEDURE get_rs_card_status(
      ip_smp_num IN VARCHAR2,
      op_status OUT NUMBER,
      op_upc_code OUT VARCHAR2
   );
   /***************  Make Card RS Redeemable        ******************/
   /*                                                                */
   /* Objective  : To change the status of an Inactive (45) card     */
   /*               to Active/redeemable (42)                        */
   /* Returns:                                                       */
   /*              OP_RESULT = 0  successful                         */
   /*                          1  if card status <> 45 (Inactive)    */
   /*                          2  if TABLE_X_ROAD_INST update failed */
   /*                          3  if X_POSA_card insert failed       */
   /*                          8 if Insert into the RI_HIST failed  */
   /*          Oracle Error Code  if OTHER                           */
   /*                                                                */
   /*                             undefined, if OP_RESULT <> 0       */
   /*                                                                */
   /******************************************************************/
   PROCEDURE make_rs_redeemable(
      ip_smp_num IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL,
      ip_upc IN VARCHAR2 := NULL
   );
   /**************  Make RS Card UnRedeemable        *****************/
   /*                                                                */
   /* Objective  : To change the status of an active/redeemable (42) */
   /*              card to Inactive (45)                             */
   /* Returns:                                                       */
   /*              OP_RESULT = 0  successful                         */
   /*                          1  if card status <> 42 (Active)      */
   /*                          2  if TABLE_PART_INST update failed   */
   /*                          3  if X_POSA_ROADSIDE insert failed   */
   /*                          8  if Insert into the RI_HIST failed  */
   /*          Oracle Error Code  if OTHER                           */
   /*                                                                */
   /*                                      OP_STATUS = 0             */
   /*                             undefined, if OP_RESULT <> 0       */
   /*                                                                */
   /******************************************************************/
   PROCEDURE make_rs_unredeemable(
      ip_smp_num IN VARCHAR2,
      ip_date IN VARCHAR2,
      ip_time IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_trans_type IN VARCHAR2,
      ip_merchant_id IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      op_result OUT NUMBER,
      ip_sourcesystem IN VARCHAR2 := 'POSA',
      ip_access_code IN VARCHAR2 := NULL,
      ip_auth_code IN VARCHAR2 := NULL,
      ip_reg_no IN VARCHAR2 := NULL,
      ip_upc IN VARCHAR2 := NULL
   );
   /*****************************************************************************/
   /*                                                                           */
   /* Name:    insert_posa_swp_tab_fun                                          */
   /* Objective  :  Insert record into the x_posa_card, x_posa_phone,           */
   /*               and x_posa_road (depending on the domain been passed) when a*/
   /*               swipe takes place. In the event of an error , ora error is  */
   /*               logged into the error_table.                                */
   /*                                                                           */
   /* In Parameters :          ip_part_serial_no   part_serial_no (ens, smp)    */
   /*                          ip_domain           'PHONES','REDEMPTION CARDS'  */
   /*                                              'ROADSIDE''                  */
   /*                          ip_action           'SWIPE','UNSWIPE'            */
   /*                          ip_store_detail     store deatail id             */
   /*                          ip_store_id         vendor id                    */
   /*                          ip_trans_id         ATT transaction id           */
   /*                          ip_sourcesystem     'IVR','CLARIFY. 'POSA'       */
   /*                                                                           */
   /* Returns:           TRUE if insertion take place sucessfully               */
   /*                    FALSE if insertion failed                              */
   /*                                                                           */
   /* Assumption:        It is the function caller's responsability to commit   */
   /*                    upon validation of function outcome (true, false)      */
   /*****************************************************************************/
   FUNCTION insert_posa_swp_tab_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_domain IN VARCHAR2,
      ip_action IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      ip_store_id IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_sourcesystem IN VARCHAR2,
      ip_trans_date IN DATE,
      ip_prog_caller IN VARCHAR2,
      ip_access_code IN VARCHAR2,
      ip_auth_code IN VARCHAR2,
      ip_reg_no IN VARCHAR2,
      ip_upc IN VARCHAR2
   )
   RETURN BOOLEAN;
   /*****************************************************************************/
   /*                                                                           */
   /* Name:    insert_pi_hist_fun                                               */
   /* Objective  :  Insert a record into the x_pi_hist_table for a given ESN or */
   /*               smp                                                         */
   /*                In the event                                               */
   /*                of an error , ora error is                                 */
   /*               logged into the error_table.                                */
   /* In Parameters :                                                           */
   /*                 ip_part_serial_no    part_serial_no of the ESN or smp     */
   /*                 ip_domain            'PHONES'' and 'REDEMPTION CARDS'     */
   /*                 ip_action             action taken on the ESN or smp      */
   /*                                       'POSA CARD ACTIVATED' ,'POSA PHONE  */
   /*                                        ACTIVATED', etc.                   */
   /*                   ip_prog_caller    caller function or procedure          */
   /*                                                                           */
   /*                                                                           */
   /* Returns:           TRUE if insertion take place sucessfully               */
   /*                    FALSE if insertion failed                              */
   /*                                                                           */
   /* Assumption:        It is the function caller's responsability to commit   */
   /*                    upon validation of function outcome (true, false)      */
   /*****************************************************************************/
   FUNCTION insert_pi_hist_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_domain IN VARCHAR2,
      ip_action IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN BOOLEAN;
   FUNCTION get_part_number(
      ip_part_serial_no IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN VARCHAR2;
   FUNCTION insert_error_tab_fun(
      ip_action IN VARCHAR2,
      ip_key IN VARCHAR2,
      ip_program_name IN VARCHAR2
   )
   RETURN NUMBER;
   FUNCTION get_pi_status_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_prog_caller IN VARCHAR2,
      op_upc_code OUT VARCHAR2
   )
   RETURN VARCHAR2;
   FUNCTION set_ri_status_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_status IN VARCHAR2,
      ip_hist_trg_flag IN NUMBER,
      ip_prog_caller IN VARCHAR2
   )
   RETURN BOOLEAN;
   FUNCTION set_pi_status_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_domain IN VARCHAR2,
      ip_status IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN BOOLEAN;
   FUNCTION get_ri_status_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN VARCHAR2;
   FUNCTION insert_ri_hist_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_domain IN VARCHAR2,
      ip_action IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN BOOLEAN;
   FUNCTION get_rs_upc_code(
      ip_part_serial_no IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN VARCHAR2;
   FUNCTION get_vendor_fun(
      ip_part_serial_no IN VARCHAR2,
      ip_domain IN VARCHAR2,
      ip_prog_caller IN VARCHAR2
   )
   RETURN VARCHAR2;
   --CR2970 Changes
   PROCEDURE insert_posa_log_prc(
      ip_serno IN VARCHAR2,
      ip_domain IN VARCHAR2,
      ip_status IN VARCHAR2,
      ip_store_detail IN VARCHAR2,
      ip_store_id IN VARCHAR2,
      ip_trans_id IN VARCHAR2,
      ip_sourcesystem IN VARCHAR2,
      ip_trans_date IN VARCHAR2,
      ip_trans_time IN VARCHAR2,
      ip_posa_action IN VARCHAR2,
      ip_reason IN VARCHAR2,
      ip_prog_caller IN VARCHAR2,
      op_result OUT NUMBER,
      ip_upc in varchar2 --CR15722
   );
--End CR2970 Changes
-- CR15722
  procedure posa_transaction_controller( ip_sourcesystem in  varchar2,
                                         ip_action_type  in  varchar2 default 'A',
                                         ip_serial_no    in  varchar2,
                                         ip_date         in  varchar2,
                                         ip_time         in  varchar2,
                                         ip_trans_id     IN  VARCHAR2,
                                         ip_trans_type   IN  VARCHAR2,
                                         ip_merchant_id  IN  VARCHAR2,
                                         ip_store_detail IN  VARCHAR2,
                                         ip_access_code  IN  VARCHAR2, -- we pass null
                                         ip_auth_code    IN  VARCHAR2, -- we pass null
                                         ip_reg_no       IN  VARCHAR2, -- terminal id (Comes from BHN)
                                         ip_upc          in  varchar2,
                                         op_out_units    out number,
                                         op_out_code     out varchar2,
                                         op_bhn_code     out varchar2);

  -- overloaded procedure to accommodate the response and incident id
  PROCEDURE posa_transaction_controller ( ip_sourcesystem IN  VARCHAR2,
                                          ip_action_type  IN  VARCHAR2 DEFAULT 'A',
                                          ip_serial_no    IN  VARCHAR2,
                                          ip_date         IN  VARCHAR2,
                                          ip_time         IN  VARCHAR2,
                                          ip_trans_id     IN  VARCHAR2,
                                          ip_trans_type   IN  VARCHAR2,
                                          ip_merchant_id  IN  VARCHAR2,
                                          ip_store_detail IN  VARCHAR2,
                                          ip_access_code  IN  VARCHAR2,
                                          ip_auth_code    IN  VARCHAR2,
                                          ip_reg_no       IN  VARCHAR2,
                                          ip_upc          IN  VARCHAR2,
                                          op_out_units    OUT NUMBER  ,
                                          op_out_code     OUT VARCHAR2,
                                          op_bhn_code     OUT VARCHAR2,
                                          i_incident_id   IN  VARCHAR2 DEFAULT NULL,
                                          o_response      OUT VARCHAR2);

   --CR53057 multidenom changes
   FUNCTION get_mod_level_md( i_curr_mod_level  IN NUMBER,
                              i_pn_upc          IN VARCHAR2,
                              i_action          IN VARCHAR2,
                              i_smp             IN  VARCHAR2 )
    RETURN NUMBER;

    -- CR54843_Enhance_BHN_MultiDenom_Agent_TAS_Tool_to_Support_LookUp

    TYPE smp_row IS RECORD (shell_part_num_objid   number,
                            child_part_num_objid   number,
                            denom_description      varchar2(100),
                            vendor_upc             varchar2(30),
                            tf_filler              varchar2(1),
                            tf_id                  varchar2(4),
                            airtime_denomination   varchar2(4),
                            encode                 varchar2(4000),
                            card_status            number,
                            smp                    varchar2(30),
                            x_retail_price           number
                           );



   TYPE smp_tab IS TABLE OF smp_row;



    FUNCTION get_smp_details_tab (i_smp             IN       VARCHAR2)
                                  RETURN smp_tab PIPELINED;



END posa_lite;
/