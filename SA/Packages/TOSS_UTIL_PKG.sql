CREATE OR REPLACE PACKAGE sa."TOSS_UTIL_PKG"
IS
/******************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         TOSS_UTIL_PKG(SPECIFICATION)                                 */
/* PURPOSE:      This package served  repository of commomly used functions   */
/*               and constants                                                */
/*               for TOSS batch processes and applications.                   */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/* REVISIONS:                                                                 */
/* VERSION  DATE     WHO         PURPOSE                                      */
/* ------  ----     ------       ---------------------------------------------*/
/* 1.0    12/18/01  Miguel Leon  Initial  Revision                            */
/*                                                                            */
/* 1.1    02/02/01  Miguel Leon   Added new functions and proc                */
/*                                                                            */
/* 1.2    03/17/02  Miguel Leon   Added function part_mod_exis fun. Also chan-*/
/*                                ged update_pricing_fun and insert_pricing_fu*/
/*                                to insert or update null table_x_pricing.   */
/*                                x_end_date to a date in the far future to   */
/*                                accomodate CLARIFY inabity to handle date   */
/*                                ranges with ending NULL dates.              */
/*                                                                            */
/* 1.3   04/18/02  Miguel Leon   Changed REDEMPTION CARD to REDEMPTION CARDS  */
/*                                (plural) within the insert_swp_posa  tab fun*/
/*                                ction. Modified set_pi_status_fun to use    */
/*                                newly added in param ip_domain.             */
/*                                                                            */
/* 1.4   07/15/02 Miguel Leon     Added new phone status codes 54(past_due)   */
/*                                and 51(phone used). site_part_active_fun    */
/*                                also added.                                 */
/*                                                                            */
/* 1.5  09/12/02  Miguel Leon    Added new function part_mod_exist_null_fun.  */
/*                               Modified function Modified update_mod_level  */
/*                               fun.                                         */
/* 1.6                                                                        */
/* 1.7  10/21/02 Vani Adapa      Modified to insert X_MSID value into         */
/*                               TABLE_X_PI_HIST in insert_pi_hist_fun        */
/* 1.8  01/02/03 D. Driscoll     Added new functions:  frequency_exist_fun,   */
/*                               insert_frequency_fun, update_frequency_fun,  */
/*                               insert_part_num2frequency_fun,               */
/*                               update_part_num2frequency_fun                */
/* 1.9  03/17/03 SL              Clarify Upgrade                              */
/*                               Removed all posa related function/store proc */
/*                               to posa package                              */
/*1.10 03/02/06    VAdapa      CR4981_4982 - Logic added to add information for DATA phones and CONVERSION rates
/*                             insert_part_num_fun and update_part_num_fun modified (PVCS Revision 1.8/1.9)
/*1.11 05/23/06    Gpintado    CR4981 - Added x_ild_type, x_ota_allowed, and x_extd_warranty (PVCS Revision 1.10)
/*1.1 12/20/08     Clinder      CR 8000
/*1.2 01/27/09     Clinder      CR 8000
/* 1.3 01/28/09    Clinder      CR 8000
/* 1.4 08/26/09    NGuada       BRAND_SEP - using table_bus_org to retrieve values instead of the pn record
/*1.5  09/02/09                        Latest
/******************************************************************************/

   /** CONSTANT DELARATION   **/
   phone_inactive   CONSTANT VARCHAR2 (3) := '59';
   phone_ready      CONSTANT VARCHAR2 (3) := '50';
   phone_active     CONSTANT VARCHAR2 (3) := '52';
   phone_past_due   CONSTANT VARCHAR2 (3) := '54';
   phone_used       CONSTANT VARCHAR2 (3) := '51';
   phone_returned   CONSTANT VARCHAR2 (3) := '64';
   card_inactive    CONSTANT VARCHAR2 (3) := '45';
   card_ready       CONSTANT VARCHAR2 (3) := '42';
   card_redeemed    CONSTANT VARCHAR2 (3) := '41';

/** PUBLIC FUNCTIONS AND PROCEDURES   **/

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
/* 03/17/03 Removed
   FUNCTION insert_posa_swp_tab_fun (
      ip_part_serial_no IN  VARCHAR2,
      ip_domain         IN  VARCHAR2,
      ip_action         IN  VARCHAR2,
      ip_store_detail   IN  VARCHAR2,
      ip_store_id       IN  VARCHAR2,
      ip_trans_id       IN  VARCHAR2,
      ip_sourcesystem   IN  VARCHAR2,
     ip_trans_date     IN  DATE,
     ip_prog_caller IN VARCHAR2
  )
      RETURN BOOLEAN;  */

   /*****************************************************************************/
/*                                                                           */
/* Name:    insert_phone_pi_fun                                              */
/* Objective  :   Insert a phone record into the table_part_inst.            */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* In Parameters :       ip_part_serial_no   part_serial_no (esn)            */
/*                       ip_upc_code         upc_code to connect to part_num */
/*                       ip_login_name       User name                       */
/*                       ip_bin_name         bin_name on the inv_bin         */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/* Returns:           TRUE if insertion take place sucessfully               */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION insert_phone_pi_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_upc_code         IN   VARCHAR2,
      ip_login_name       IN   VARCHAR2,
      ip_bin_name         IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:      insert_error_tab_proc                                          */
/* Objective  : Logged an oracle  error and related info into the error_table*/
/* In Parameters :                                                           */
/*             ip_action     action taking place while error occurred        */
/*             ip_key        unique identifier of troubled record            */
/*             ip_program_name program/script  where the error originated    */
/*             ip_error_text  oracle error text or user defined error text.  */
/*                           IF not explicitly passed default value is NULL  */
/*                           causing population ofthe generic sqlerr/sqlcode */
/*                           de into the error_table.ERROR_TEXT              */
/*                   ip_prog_caller    caller function or procedure          */
/* Returns:   Nothing                                                        */
/*                                                                           */
/*****************************************************************************/
   PROCEDURE insert_error_tab_proc (
      ip_action         IN   VARCHAR2,
      ip_key            IN   VARCHAR2,
      ip_program_name   IN   VARCHAR2,
      ip_error_text     IN   VARCHAR2 DEFAULT NULL
   );

/*****************************************************************************/
/*                                                                           */
/* Name:    insert_error_tab_fun                                             */
/* Objective  : Logged an oracle  error and related info into the error_table*/
/* In Parameters :                                                           */
/*             ip_action     action taking place while error occurred        */
/*             ip_key        unique identifier of troubled record            */
/*             ip_program_name program/script  where the error originated    */
/* Returns:    Oracle sql Code ( negative)                                   */
/*                                                                           */
/*****************************************************************************/
   FUNCTION insert_error_tab_fun (
      ip_action         IN   VARCHAR2,
      ip_key            IN   VARCHAR2,
      ip_program_name   IN   VARCHAR2
   )
      RETURN NUMBER;

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
   FUNCTION insert_pi_hist_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_domain           IN   VARCHAR2,
      ip_action           IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    insert_posa_exception                                            */
/* Objective  :  Insert a record into the  x_posa_esn_exception              */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* In Parameters :                                                           */
/*                                                                           */
/*              ip_esn    Given ESN (posa phone)                             */
/*             ip_orig_site_id   orignal vendor id attached to the phone    */
/*              ip_new_site_id   new vendor if associated with the phone     */
/*              ip_action        'VC' (vendor changed) 'IP' (inserted phone) */
/*              ip_created_by 'name of process that inserted record ('POSA') */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/* Returns:           TRUE if insertion take place sucessfully               */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
/* 03/17/03 Removed
   FUNCTION insert_posa_exception_fun (
     ip_esn IN VARCHAR2,
    ip_orig_site_id IN VARCHAR2,
    ip_new_site_id IN VARCHAR2,
    ip_action IN VARCHAR2,
    ip_created_by IN VARCHAR2,
    ip_prog_caller IN VARCHAR2)
   RETURN BOOLEAN;   */

   /*****************************************************************************/
/*                                                                           */
/* Name:    get_pi_status_fun                                                */
/* Objective  :  Given a part_serial_no gets the status of it                */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/* In Parameters :  ip_part_serial_no    part_serial_no (ESN, SMP)           */
/* Returns:    x_part_inst_status ( if part_serial_no is found)              */
/*             '0' if part_serial_no is not found in table_part_inst         */
/*                                                                           */
/*****************************************************************************/
   FUNCTION get_pi_status_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2;

/*****************************************************************************/
/*                                                                           */
/* Name:    get_ri_status_fun                                                */
/* Objective  :  Given a part_serial_no gets the status of it                */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* In Parameters :  ip_part_serial_no    part_serial_no (ESN, SMP)           */
/*                   ip_prog_caller    caller function or procedure          */
/* Returns:    x_part_inst_status ( if part_serial_no is found)              */
/*             '0' if part_serial_no is not found in table_x_road_inst       */
/*                                                                           */
/*****************************************************************************/
   FUNCTION get_ri_status_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2;

/*****************************************************************************/
/*                                                                           */
/* Name:    set_pi_status_fun                                                */
/* Objective  :  Update table_part_inst.x_part_inst_status and               */
/*               table_part_inst.STATUS2X_CODE_TABLE                         */
/* In Parameters :  ip_part_serial_no   given ESN or SMP                     */
/*                  ip_domain VARCHAR2  'PHONES' or 'REDEMPTION CARDS'       */
/*                  ip_status VARCHAR2                                       */
/*                   ip_prog_caller    caller function or procedure          */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* Returns:           TRUE if update takes place sucessfully                 */
/*                    FALSE if update    failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION set_pi_status_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_domain           IN   VARCHAR2,
      ip_status           IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    set_ri_status_fun                                                */
/* Objective  :  Update table_x_road_inst.x_part_inst_status and             */
/*               table_x_road_inst.RD_STATUS2X_CODE_TABLE                    */
/* In Parameters :  ip_part_serial_no   given ROAD SIDE card                 */
/*                  ip_status VARCHAR2,                                      */
/*                  ip_hist_trg_flag NUMBER (                                */
/*                   ip_prog_caller    caller function or procedure          */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* Returns:           TRUE if update takes place sucessfully                 */
/*                    FALSE if update    failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION set_ri_status_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_status           IN   VARCHAR2,
      ip_hist_trg_flag    IN   NUMBER,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    is_posa_vendor_fun                                               */
/* Objective  :   Given a site (vendor id) this function decides if a vendor */
/*                is posa enabled or not (for future use)                    */
/*                                                                           */
/* In Parameters :  ip_site_id   vendor id                                   */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/* Returns:         TRUE   if  site id is in table_x_posa                    */
/*                  FALSE if site Id is not in table_x_posa                  */
/*                                                                           */
/*****************************************************************************/
/* 03/17/03  Removed
  FUNCTION is_posa_vendor_fun (ip_site_id IN VARCHAR2,ip_prog_caller IN VARCHAR2) RETURN BOOLEAN;
  */

   /*****************************************************************************/
/*                                                                           */
/* Name:    is_in_part_inst_fun                                              */
/* Objective  :  Given a part serial_no this function decides wether this    */
/*               serial_no is in the table part_inst                         */
/*                                                                           */
/* In Parameters :   ip_part_serial_no   ESN or SMP                          */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/* Returns:           TRUE if part_serial_no exists in table_part_inst       */
/*                   FALSE if part_serial_no does not exists in table_part_in*/
/*                                                                           */
/*****************************************************************************/
   FUNCTION is_in_part_inst_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    set_vendor_fun                                                   */
/* Objective  :     Given a serial_no this function updates the part_inst2inv*/
/*                  bin (objid) based on the given site_id (vendor_id)       */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* In Parameters :     ip_part_serial_no (ESN)                               */
/*                     ip_vendor_id     site_id                              */
/*                   ip_prog_caller    caller function or procedure          */
/* Returns:           TRUE if update takes place sucessfully                 */
/*                    FALSE if update    failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION set_vendor_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_vendor           IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    get_vendor_fun                                                   */
/* Objective  :   Given a part_serial_no and domain (PHONES,REDEMPTION_CARDS)*/
/*                this function returns table_site.site_id associated with it*/
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* In Parameters : ip_part_serial_no   (ESN or SMP)                          */
/*                 ip_domain           ('PHONES','REDEMPTION CARDS')         */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/* Returns:    table_site.site_id  if available                              */
/*             NULL                if not available or ERROR                 */
/*                                                                           */
/*****************************************************************************/
   FUNCTION get_vendor_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_domain           IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2;

/*****************************************************************************/
/*                                                                           */
/* Name:    get_upc_code                                                     */
/* Objective  :   Given a part_serial_no this function returns the upc code  */
/*                associated with the corresponding part number              */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* In Parameters : ip_part_serial_no (ESN or SMP )                           */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/* Returns:        table_part_num.x_upc code if available                    */
/*                 NULL                      if not available or ERROR       */
/*                                                                           */
/*****************************************************************************/
   FUNCTION get_upc_code (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2;

/*****************************************************************************/
/*                                                                           */
/* Name:    get_rs_upc_code                                                  */
/* Objective  :   Given a part_serial_no this function returns the upc code  */
/*                associated with the corresponding part number              */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* In Parameters : ip_part_serial_no  (Roadside SMP )                        */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/* Returns:        table_part_num.x_upc code if available                    */
/*                 NULL                      if not available or ERROR       */
/*                                                                           */
/*****************************************************************************/
   FUNCTION get_rs_upc_code (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2;

/*****************************************************************************/
/*                                                                           */
/* Name:  set_upc_code_fun                                                   */
/* Objective  :  Given an upc code updates the n_part_inst2part_mod with the */
/*               corresponding mod_level.objid for a given part_serial_no.   */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* In Parameters :  ip_part_serial_no (ESN or SMP)                           */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/* Returns:           TRUE if update takes place sucessfully                 */
/*                    FALSE if update    failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION set_upc_code_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_upc_code         IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    get_redeem_units                                                 */
/* Objective  :  Given a part_serial_no (SMP) this function returns the numbe*/
/*               er of units (part_num.x_redeem_units)                       */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* In Parameters :   ip_part_serial_no  (SMP)                                */
/*                   ip_prog_caller    caller function or procedure          */
/* Returns:          part_number.x_redeem_units if available                 */
/*                   NULL         if not available                           */
/*****************************************************************************/
   FUNCTION get_redeem_units (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN NUMBER;

/*****************************************************************************/
/*                                                                           */
/* Name:    get_part_number                                                  */
/* Objective  :  Given a part_serial_no(SMP or ESN) this function returns the*/
/*               part_number associated with it                              */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* In Parameters :   ip_part_serial_no (ESN OR SMP)                          */
/*                   ip_prog_caller    caller function or procedure          */
/* Returns:                                                                  */
/*                   part_number.part_num if available                       */
/*                   NULL if  not available                                  */
/*                                                                           */
/*****************************************************************************/
   FUNCTION get_part_number (
      ip_part_serial_no   IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2;

/*****************************************************************************/
/*                                                                           */
/* Name:    get_x_code_objid                                                 */
/* Objective  : Given a  code number (status/code) this function returns the */
/*              table_x_code_table.objid                                     */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* In Parameters :  ip_code_number (status/code)                             */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/* Returns:    table_x_code_table.objid if available                         */
/*             NULL if not available or error                                */
/*                                                                           */
/*****************************************************************************/
   FUNCTION get_x_code_objid (
      ip_code_number   IN   VARCHAR2,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN NUMBER;

/*****************************************************************************/
/*                                                                           */
/* Name:    get_site_type_fun                                                */
/* Objective  :  Given a part_serial_no and domain (PHONE, REDEMPTION CARDS) */
/*               return the table_site.site_type ('DIST','MANF', 'RSEL',etc) */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/*                                                                           */
/* In Parameters :   ip_part_serial_no (SMP OR ESN)                          */
/*                   ip_domain  ("PHONES", REDEMPTION CARDS, ETC )           */
/*                   ip_prog_caller    caller function or procedure          */
/* Returns:                                                                  */
/*                  table_site.site_type  if available                       */
/*                  NULL                  if not available or ERROR          */
/*                                                                           */
/*****************************************************************************/
   FUNCTION get_site_type_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_domain           IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN VARCHAR2;

/*****************************************************************************/
/*                                                                           */
/* Name:    insert_ri_hist_fun                                               */
/* Objective  :  Insert a record into the x_ri_hist_table for a given        */
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
   FUNCTION insert_ri_hist_fun (
      ip_part_serial_no   IN   VARCHAR2,
      ip_domain           IN   VARCHAR2,
      ip_action           IN   VARCHAR2,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    part_num_exist_fun                                               */
/* Objective  :  Checks if the part number exists in the table_part_num      */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/*                   ip_part_number    part_number                           */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if record exists                                  */
/*                    FALSE if does not exits                                */
/*                                                                           */
/*****************************************************************************/
   FUNCTION part_num_exist_fun (
      ip_part_number   IN   VARCHAR2,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    part_mod_exist_fun                                               */
/* Objective  :  Checks if the mod_level exists in the table_mod_level       */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/*                   ip_ml_level         mod_level                           */
/*                   ip_ml_pi2pn         part_info2part_num (objid)          */
/*                   ip_active           table_mod_level.active              */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if record exists                                  */
/*                    FALSE if does not exits                                */
/*                                                                           */
/*****************************************************************************/
   FUNCTION part_mod_exist_fun (
      ip_ml_level      IN   VARCHAR2,
      ip_ml_pi2pn      IN   NUMBER,
      ip_active        IN   VARCHAR2,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    part_mod_exist_null_fun                                          */
/* Objective  :  Checks if the NULL mod_level exists in the table_mod_level  */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/*                   ip_ml_pi2pn         part_info2part_num (objid)          */
/*                   ip_active           table_mod_level.active              */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if record exists                                  */
/*                    FALSE if does not exits                                */
/*                                                                           */
/*****************************************************************************/
   FUNCTION part_mod_exist_null_fun (
      ip_ml_pi2pn      IN   NUMBER,
      ip_active        IN   VARCHAR2,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    x_price_exist_fun                                                */
/* Objective  :  Checks if the record in table_x_princing exists for a given */
/*               part_number.objid and priceline_id                          */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/*                   ip_part_num_objid  table_part_num.objid                 */
/*                   ip_priceline_id    table_x_pricing.xX_FIN_PRICELINE_ID  */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if record exists                                  */
/*                    FALSE if does not exits                                */
/*                                                                           */
/*****************************************************************************/
   FUNCTION x_price_exist_fun (
      ip_part_num_objid   IN   NUMBER,
      ip_priceline_id     IN   NUMBER,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    frequency_exist_fun                                              */
/* Objective  :  Checks if the frequency exists in table_x_frequency         */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/*                   ip_frequency      frequency                             */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if record exists                                  */
/*                    FALSE if does not exits                                */
/*                                                                           */
/*****************************************************************************/
   FUNCTION frequency_exist_fun (
      ip_frequency     IN   NUMBER,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    insert_part_num_fun                                              */
/* Objective  :   Inserts part num record                                    */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/* DESCRIPTION_in              SA.TABLE_PART_NUM.DESCRIPTION%TYPE,           */
/*  S_DESCRIPTION_in           SA.TABLE_PART_NUM.S_DESCRIPTION%TYPE,         */
/* DOMAIN_in                  SA.TABLE_PART_NUM.DOMAIN%TYPE,                 */
/* S_DOMAIN_in                SA.TABLE_PART_NUM.S_DOMAIN%TYPE,               */
/* PART_NUMBER_in             SA.TABLE_PART_NUM.PART_NUMBER%TYPE,            */
/* S_PART_NUMBER_in            SA.TABLE_PART_NUM.S_PART_NUMBER%TYPE,         */
/* ACTIVE_in                   SA.TABLE_PART_NUM.ACTIVE%TYPE,                */
/* PART_TYPE_in                SA.TABLE_PART_NUM.PART_TYPE%TYPE,             */
/* PART_NUM2DOMAIN_in          SA.TABLE_PART_NUM.PART_NUM2DOMAIN%TYPE,       */
/* X_DLL_in                    SA.TABLE_PART_NUM.X_DLL%TYPE,                 */
/* X_MANUFACTURER_in           SA.TABLE_PART_NUM.X_MANUFACTURER%TYPE,        */
/* X_REDEEM_DAYS_in            SA.TABLE_PART_NUM.X_REDEEM_DAYS%TYPE,         */
/* X_REDEEM_UNITS_in           SA.TABLE_PART_NUM.X_REDEEM_UNITS%TYPE,        */
/* X_PROGRAMMABLE_FLAG_in      SA.TABLE_PART_NUM.X_PROGRAMMABLE_FLAG%TYPE,   */
/* X_TECHNOLOGY_in             SA.TABLE_PART_NUM.X_TECHNOLOGY%TYPE,          */
/* X_UPC_in                    SA.TABLE_PART_NUM.X_UPC%TYPE,                 */
/* PART_NUM2DEFAULT_PRELOAD    SA.TABLE_PART_NUM.PART_NUM2DEFAULT_PRELOAD,   */
/* X_PRODUCT_CODE_in           SA.TABLE_PART_NUM.X_PRODUCT_CODE%TYPE,        */
/* X_SOURCE_SYSTEM_IN          SA.TABLE_PART_NUM.X_SOURCESYSTEM%TYPE,        */
/* X_RESTRICTED_USE_in         SA.TABLE_PART_NUM.X_RESTRICTED_USE%TYPE,      */
/* X_PART_NUM2X_PROMOTION_IN   SA.TABLE_PART_NUM.PART_NUM2X_PROMOTION%TYPE,  */
/* X_PART_NUM2PART_CLASS_IN    SA.TABLE_PART_NUM.PART_NUM2PART_CLASS%TYPE,   */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if insertion take place sucessfully               */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION insert_part_num_fun (
      description_in                IN   sa.table_part_num.description%TYPE,
      s_description_in              IN   sa.table_part_num.s_description%TYPE,
      domain_in                     IN   sa.table_part_num.domain%TYPE,
      s_domain_in                   IN   sa.table_part_num.s_domain%TYPE,
      part_number_in                IN   sa.table_part_num.part_number%TYPE,
      s_part_number_in              IN   sa.table_part_num.s_part_number%TYPE,
      active_in                     IN   sa.table_part_num.active%TYPE,
      part_type_in                  IN   sa.table_part_num.part_type%TYPE,
      part_num2domain_in            IN   sa.table_part_num.part_num2domain%TYPE,
      x_dll_in                      IN   sa.table_part_num.x_dll%TYPE,
      x_manufacturer_in             IN   sa.table_part_num.x_manufacturer%TYPE,
      x_redeem_days_in              IN   sa.table_part_num.x_redeem_days%TYPE,
      x_redeem_units_in             IN   sa.table_part_num.x_redeem_units%TYPE,
      x_programmable_flag_in        IN   sa.table_part_num.x_programmable_flag%TYPE,
      x_technology_in               IN   sa.table_part_num.x_technology%TYPE,
      x_upc_in                      IN   sa.table_part_num.x_upc%TYPE,
      part_num2default_preload_in   IN   sa.table_part_num.part_num2default_preload%TYPE,
      x_product_code_in             IN   sa.table_part_num.x_product_code%TYPE,
      x_sourcesystem_in             IN   sa.table_part_num.x_sourcesystem%TYPE,
      x_part_num2x_promotion_in     IN   sa.table_part_num.part_num2x_promotion%TYPE,
      x_part_num2part_class_in      IN   sa.table_part_num.part_num2part_class%TYPE,
      x_cardless_bundle_in          IN   sa.table_part_num.x_cardless_bundle%TYPE,
      x_data_capable_in             IN   sa.table_part_num.x_data_capable%TYPE, --CR4981_4982
      x_conversion_in               IN   sa.table_part_num.x_conversion%TYPE,   --CR4981_4982
      x_ild_type_in                 IN   sa.table_part_num.x_ild_type%TYPE,     --CR4981_4982
      x_ota_allowed_in              IN   sa.table_part_num.x_ota_allowed%TYPE,  --CR4981_4982
      extd_warranty_in              IN   sa.table_part_num.x_extd_warranty%TYPE,--CR4981_4982
      ip_prog_caller                IN   VARCHAR2,
      unit_measure_in               IN   sa.table_part_num.unit_measure%TYPE,
      x_card_type_in                IN   sa.table_part_num.x_card_type%type, --CR26500
      device_lock_state_in             IN   sa.table_part_num.device_lock_state%TYPE,   ---CR33844
      rcs_capable_in                IN   sa.table_part_num.rcs_capable%TYPE DEFAULT NULL -- CR53920_RCS_Flag_clfy_DDL
   )
      RETURN BOOLEAN;

   FUNCTION insert_part_num_fun_ph (
      description_in                IN   sa.table_part_num.description%TYPE,
      s_description_in              IN   sa.table_part_num.s_description%TYPE,
      domain_in                     IN   sa.table_part_num.domain%TYPE,
      s_domain_in                   IN   sa.table_part_num.s_domain%TYPE,
      part_number_in                IN   sa.table_part_num.part_number%TYPE,
      s_part_number_in              IN   sa.table_part_num.s_part_number%TYPE,
      active_in                     IN   sa.table_part_num.active%TYPE,
      part_type_in                  IN   sa.table_part_num.part_type%TYPE,
      part_num2domain_in            IN   sa.table_part_num.part_num2domain%TYPE,
      x_redeem_days_in              IN   sa.table_part_num.x_redeem_days%TYPE,
      x_redeem_units_in             IN   sa.table_part_num.x_redeem_units%TYPE,
      x_programmable_flag_in        IN   sa.table_part_num.x_programmable_flag%TYPE,
      x_upc_in                      IN   sa.table_part_num.x_upc%TYPE,
      x_product_code_in             IN   sa.table_part_num.x_product_code%TYPE,
      x_sourcesystem_in             IN   sa.table_part_num.x_sourcesystem%TYPE,
      x_part_num2x_promotion_in     IN   sa.table_part_num.part_num2x_promotion%TYPE,
      x_part_num2part_class_in      IN   sa.table_part_num.part_num2part_class%TYPE,
      x_cardless_bundle_in          IN   sa.table_part_num.x_cardless_bundle%TYPE,
      ip_prog_caller                IN   VARCHAR2,
      x_card_plan_in                IN   sa.table_part_num.x_card_plan%TYPE ,      -- CR27270
      device_lock_state_in          IN   sa.table_part_num.device_lock_state%TYPE,   ---CR33844
      rcs_capable_in                IN   sa.table_part_num.rcs_capable%TYPE DEFAULT NULL -- CR53920_RCS_Flag_clfy_DDL
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    update_part_num_fun                                              */
/* Objective  :  Updates table_part_num records  for a given part_number     */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/* DOMAIN_in             SA.TABLE_PART_NUM.DOMAIN%TYPE,                      */
/* PART_NUMBER_in         SA.TABLE_PART_NUM.PART_NUMBER%TYPE,                */
/* S_DOMAIN_in            SA.TABLE_PART_NUM.S_DOMAIN%TYPE,                   */
/* PART_TYPE_in          SA.TABLE_PART_NUM.PART_TYPE%TYPE,                   */
/* X_MANUFACTURER_in      SA.TABLE_PART_NUM.X_MANUFACTURER%TYPE,             */
/* PART_NUM2DOMAIN_in          IN   SA.TABLE_PART_NUM.PART_NUM2DOMAIN%TYPE   */
/* X_TECHNOLOGY_in        SA.TABLE_PART_NUM.X_TECHNOLOGY%TYPE,               */
/* X_UPC_in               SA.TABLE_PART_NUM.X_UPC%TYPE,                      */
/*    X_PRODUCT_CODE_in        IN   SA.TABLE_PART_NUM.X_PRODUCT_CODE%TYPE,   */
/*      X_SOURCESYSTEM_in     IN SA.TABLE_PART_NUM.X_SOURCESYSTEM%TYPE,     */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if insertion take place sucessfully               */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION update_part_num_fun (
      domain_in                   IN   sa.table_part_num.domain%TYPE,
      part_number_in              IN   sa.table_part_num.part_number%TYPE,
      s_domain_in                 IN   sa.table_part_num.s_domain%TYPE,
      part_type_in                IN   sa.table_part_num.part_type%TYPE,
      part_num2domain_in          IN   sa.table_part_num.part_num2domain%TYPE,
      x_manufacturer_in           IN   sa.table_part_num.x_manufacturer%TYPE,
      x_technology_in             IN   sa.table_part_num.x_technology%TYPE,
      x_upc_in                    IN   sa.table_part_num.x_upc%TYPE,
      x_product_code_in           IN   sa.table_part_num.x_product_code%TYPE,
      x_sourcesystem_in           IN   sa.table_part_num.x_sourcesystem%TYPE,
      x_part_num2x_promotion_in   IN   sa.table_part_num.part_num2x_promotion%TYPE,
      x_cardless_bundle_in        IN   sa.table_part_num.x_cardless_bundle%TYPE,
      x_data_capable_in           IN   sa.table_part_num.x_data_capable%TYPE, --CR4981_4982
      x_conversion_in             IN   sa.table_part_num.x_conversion%TYPE,   --CR4981_4982
      x_ild_type_in               IN   sa.table_part_num.x_ild_type%TYPE,     --CR4981_4982
      x_ota_allowed_in            IN   sa.table_part_num.x_ota_allowed%TYPE,  --CR4981_4982
      x_extd_warranty_in          IN   sa.table_part_num.x_extd_warranty%TYPE,--CR4981_4982
      ip_prog_caller              IN   VARCHAR2,
      x_part_num2part_class_in    in   number,
      unit_measure_in             IN   sa.table_part_num.unit_measure%TYPE,
      x_card_type_in              IN   sa.table_part_num.x_card_type%TYPE,  --CR26500
      x_card_plan_in              IN   sa.table_part_num.x_card_plan%TYPE,       -- CR27270
      description_in              IN   sa.table_part_num.description%TYPE,       -- CR30292
      s_description_in            IN   sa.table_part_num.s_description%TYPE,       -- CR30292
      x_redeem_days_in            IN   sa.table_part_num.x_redeem_days%TYPE,       -- CR30292
      x_redeem_units_in           IN   sa.table_part_num.x_redeem_units%TYPE,       -- CR30292
      x_programmable_flag_in      IN   sa.table_part_num.x_programmable_flag%TYPE,       -- CR30292
      device_lock_state_in           IN   sa.table_part_num.device_lock_state%TYPE,    ---CR33844
      rcs_capable_in              IN   sa.table_part_num.rcs_capable%TYPE DEFAULT NULL -- CR53920_RCS_Flag_clfy_DDL
   )
      RETURN BOOLEAN;
/*****************************************************************************/
   FUNCTION update_part_num_fun (
      domain_in                   IN   sa.table_part_num.domain%TYPE,
      part_number_in              IN   sa.table_part_num.part_number%TYPE,
      s_domain_in                 IN   sa.table_part_num.s_domain%TYPE,
      part_type_in                IN   sa.table_part_num.part_type%TYPE,
      part_num2domain_in          IN   sa.table_part_num.part_num2domain%TYPE,
      x_manufacturer_in           IN   sa.table_part_num.x_manufacturer%TYPE,
      x_technology_in             IN   sa.table_part_num.x_technology%TYPE,
      x_upc_in                    IN   sa.table_part_num.x_upc%TYPE,
      x_product_code_in           IN   sa.table_part_num.x_product_code%TYPE,
      x_sourcesystem_in           IN   sa.table_part_num.x_sourcesystem%TYPE,
      x_part_num2x_promotion_in   IN   sa.table_part_num.part_num2x_promotion%TYPE,
      x_cardless_bundle_in        IN   sa.table_part_num.x_cardless_bundle%TYPE,
      x_data_capable_in           IN   sa.table_part_num.x_data_capable%TYPE, --CR4981_4982
      x_conversion_in             IN   sa.table_part_num.x_conversion%TYPE,   --CR4981_4982
      x_ild_type_in               IN   sa.table_part_num.x_ild_type%TYPE,     --CR4981_4982
      x_ota_allowed_in            IN   sa.table_part_num.x_ota_allowed%TYPE,  --CR4981_4982
      x_extd_warranty_in          IN   sa.table_part_num.x_extd_warranty%TYPE,--CR4981_4982
      ip_prog_caller              IN   VARCHAR2,
      x_part_num2part_class_in    in   number,
      unit_measure_in             IN   sa.table_part_num.unit_measure%TYPE,
      x_card_type_in              IN   sa.table_part_num.x_card_type%TYPE,  --CR26500
      x_card_plan_in              IN   sa.table_part_num.x_card_plan%TYPE,       -- CR27270
      device_lock_state_in        IN   sa.table_part_num.device_lock_state%TYPE,    ---CR33844
      rcs_capable_in              IN   sa.table_part_num.rcs_capable%TYPE DEFAULT NULL -- CR53920_RCS_Flag_clfy_DDL
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    insert_mod_level_fun                                             */
/* Objective  :  Inserts a record into the table_mod_level                   */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/* MOD_LEVEL_in               SA.TABLE_MOD_LEVEL.MOD_LEVEL%TYPE,             */
/* S_MOD_LEVEL_in             SA.TABLE_MOD_LEVEL.S_MOD_LEVEL%TYPE,           */
/* ACTIVE_in                  SA.TABLE_MOD_LEVEL.ACTIVE%TYPE,                */
/* EFF_DATE_in                SA.TABLE_MOD_LEVEL.EFF_DATE%TYPE,              */
/* PART_INFO2PART_NUM_in      SA.TABLE_MOD_LEVEL.PART_INFO2PART_NUM%TYPE,    */
/* X_TIMETANK_in              SA.TABLE_MOD_LEVEL.X_TIMETANK%TYPE,            */
/*    ip_prog_caller              IN   VARCHAR2                              */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if insertion take place sucessfully               */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION insert_mod_level_fun (
      mod_level_in            IN   sa.table_mod_level.mod_level%TYPE,
      s_mod_level_in          IN   sa.table_mod_level.s_mod_level%TYPE,
      active_in               IN   sa.table_mod_level.active%TYPE,
      eff_date_in             IN   sa.table_mod_level.eff_date%TYPE,
      part_info2part_num_in   IN   sa.table_mod_level.part_info2part_num%TYPE,
      x_timetank_in           IN   sa.table_mod_level.x_timetank%TYPE,
      ip_prog_caller          IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    update_mod_level_fun                                             */
/* Objective  :  Update a record into the table_mod_level for a given        */
/*               mod_level(revision).If the mod level being passed is a NULL */
/*               then updates takes place using mod_level.objid in the where */
/*               clause. Otherwise, it will use mod_level, part_info2part_num*/
/*               and active parameters to update.                            */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/*   UPDATE_FOR_NULL_in         BOOLEAN to use where cluse update with null  */
/*   MOD_LEVEL_in              SA.TABLE_MOD_LEVEL.MOD_LEVEL%TYPE,            */
/*  S_MOD_LEVEL_in             SA.TABLE_MOD_LEVEL.S_MOD_LEVEL%TYPE,          */
/* ACTIVE_in                  SA.TABLE_MOD_LEVEL.ACTIVE%TYPE,                */
/* EFF_DATE_in                SA.TABLE_MOD_LEVEL.EFF_DATE%TYPE,              */
/* PART_INFO2PART_NUM_in      SA.TABLE_MOD_LEVEL.PART_INFO2PART_NUM%TYPE,    */
/* X_TIMETANK_in              SA.TABLE_MOD_LEVEL.X_TIMETANK%TYPE,            */
/* ip_prog_caller              IN   VARCHAR2                                 */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if insertion take place sucessfully               */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION update_mod_level_fun (
      update_for_null_in      IN   BOOLEAN,
      mod_level_in            IN   sa.table_mod_level.mod_level%TYPE,
      s_mod_level_in          IN   sa.table_mod_level.s_mod_level%TYPE,
      active_in               IN   sa.table_mod_level.active%TYPE,
      eff_date_in             IN   sa.table_mod_level.eff_date%TYPE,
      part_info2part_num_in   IN   sa.table_mod_level.part_info2part_num%TYPE,
      x_timetank_in           IN   sa.table_mod_level.x_timetank%TYPE,
      ip_prog_caller          IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    insert_interface_jobs_fun                                        */
/* Objective  :  Insert a record into the x_toss_interface_jobs              */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/*  PROGRAM_NAME_in       SA.X_TOSS_INTERFACE_JOBS.PROGRAM_NAME%TYPE,        */
/* START_DATE_in         SA.X_TOSS_INTERFACE_JOBS.START_DATE%TYPE,           */
/* END_DATE_in           SA.X_TOSS_INTERFACE_JOBS.END_DATE%TYPE,             */
/* ROWS_PROCESSED_in     SA.X_TOSS_INTERFACE_JOBS.ROWS_PROCESSED%TYPE,       */
/* STATUS_in              SA.X_TOSS_INTERFACE_JOBS.STATUS%TYPE,              */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if insertion take place sucessfully               */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION insert_interface_jobs_fun (
      program_name_in     IN   sa.x_toss_interface_jobs.program_name%TYPE,
      start_date_in       IN   sa.x_toss_interface_jobs.start_date%TYPE,
      end_date_in         IN   sa.x_toss_interface_jobs.end_date%TYPE,
      rows_processed_in   IN   sa.x_toss_interface_jobs.rows_processed%TYPE,
      status_in           IN   sa.x_toss_interface_jobs.status%TYPE,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    update_interface_jobs_fun                                        */
/* Objective  :  Updates a x_toss_interface_table for a given program_name   */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/*  PROGRAM_NAME_in       SA.X_TOSS_INTERFACE_JOBS.PROGRAM_NAME%TYPE,        */
/* START_DATE_in         SA.X_TOSS_INTERFACE_JOBS.START_DATE%TYPE,           */
/* END_DATE_in           SA.X_TOSS_INTERFACE_JOBS.END_DATE%TYPE,             */
/* ROWS_PROCESSED_in     SA.X_TOSS_INTERFACE_JOBS.ROWS_PROCESSED%TYPE,       */
/* STATUS_in              SA.X_TOSS_INTERFACE_JOBS.STATUS%TYPE,              */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if insertion take place sucessfully               */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION update_interface_jobs_fun (
      program_name_in     IN   sa.x_toss_interface_jobs.program_name%TYPE,
      start_date_in       IN   sa.x_toss_interface_jobs.start_date%TYPE,
      end_date_in         IN   sa.x_toss_interface_jobs.end_date%TYPE,
      rows_processed_in   IN   sa.x_toss_interface_jobs.rows_processed%TYPE,
      status_in           IN   sa.x_toss_interface_jobs.status%TYPE,
      ip_prog_caller      IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:   insert_pricing_fun                                                */
/* Objective  :  Insert a record into the table_x_pricing table              */
/*                                                                           */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/* X_START_DATE_in            SA.TABLE_X_PRICING.X_START_DATE%TYPE,          */
/* X_END_DATE_in              SA.TABLE_X_PRICING.X_END_DATE%TYPE,            */
/* X_WEB_LINK_in              SA.TABLE_X_PRICING.X_WEB_LINK%TYPE,            */
/* X_WEB_DESCRIPTION_in       SA.TABLE_X_PRICING.X_WEB_DESCRIPTION%TYPE,     */
/* X_RETAIL_PRICE_in          SA.TABLE_X_PRICING.X_RETAIL_PRICE%TYPE,        */
/* X_TYPE_in                  SA.TABLE_X_PRICING.X_TYPE%TYPE,                */
/* X_PRICING2PART_NUM_in      SA.TABLE_X_PRICING.X_PRICING2PART_NUM%TYPE,    */
/* X_FIN_PRICELINE_ID_in      SA.TABLE_X_PRICING.X_FIN_PRICELINE_ID%TYPE,    */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if insertion take place sucessfully               */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION insert_pricing_fun (
      x_start_date_in         IN   sa.table_x_pricing.x_start_date%TYPE,
      x_end_date_in           IN   sa.table_x_pricing.x_end_date%TYPE,
      x_web_link_in           IN   sa.table_x_pricing.x_web_link%TYPE,
      x_web_description_in    IN   sa.table_x_pricing.x_web_description%TYPE,
      x_retail_price_in       IN   sa.table_x_pricing.x_retail_price%TYPE,
      x_channel_in            IN   sa.table_x_pricing.x_channel%TYPE, --BRAND_SEP
      x_pricing2part_num_in   IN   sa.table_x_pricing.x_pricing2part_num%TYPE,
      x_fin_priceline_id_in   IN   sa.table_x_pricing.x_fin_priceline_id%TYPE,
      ip_prog_caller          IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    update_pricing_fun                                               */
/* Objective  :  Update a record in the table_x_pricing   for a given        */
/*               x_pricing2part_num (part_num.objid) and x_fin_priceline_id  */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/* X_START_DATE_in            SA.TABLE_X_PRICING.X_START_DATE%TYPE,          */
/* X_END_DATE_in              SA.TABLE_X_PRICING.X_END_DATE%TYPE,            */
/* X_WEB_LINK_in              SA.TABLE_X_PRICING.X_WEB_LINK%TYPE,            */
/* X_WEB_DESCRIPTION_in       SA.TABLE_X_PRICING.X_WEB_DESCRIPTION%TYPE,     */
/* X_RETAIL_PRICE_in          SA.TABLE_X_PRICING.X_RETAIL_PRICE%TYPE,        */
/* X_TYPE_in                  SA.TABLE_X_PRICING.X_TYPE%TYPE,                */
/* X_PRICING2PART_NUM_in      SA.TABLE_X_PRICING.X_PRICING2PART_NUM%TYPE,    */
/* X_FIN_PRICELINE_ID_in      SA.TABLE_X_PRICING.X_FIN_PRICELINE_ID%TYPE,    */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if insertion take place sucessfully               */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION update_pricing_fun (
      x_start_date_in         IN   sa.table_x_pricing.x_start_date%TYPE,
      x_end_date_in           IN   sa.table_x_pricing.x_end_date%TYPE,
      x_web_link_in           IN   sa.table_x_pricing.x_web_link%TYPE,
      x_web_description_in    IN   sa.table_x_pricing.x_web_description%TYPE,
      x_retail_price_in       IN   sa.table_x_pricing.x_retail_price%TYPE,
      x_channel_in            IN   sa.table_x_pricing.x_channel%TYPE, --BRAND_SEP
      x_pricing2part_num_in   IN   sa.table_x_pricing.x_pricing2part_num%TYPE,
      x_fin_priceline_id_in   IN   sa.table_x_pricing.x_fin_priceline_id%TYPE,
      ip_prog_caller          IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    insert_frequency_fun                                             */
/* Objective  :   Inserts frequency record                                   */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/*               X_FREQUENCY_in    SA.TABLE_X_FREQUENCY.X_FREQUENCY          */
/*               ip_prog_caller    caller function or procedure              */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if insertion take place successfully              */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsibility to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION insert_frequency_fun (
      x_frequency_in   IN   sa.table_x_frequency.x_frequency%TYPE,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    update_frequency_fun                                             */
/* Objective  :  Updates table_x_frequency records                           */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/* X_FREQUENCY_in         SA.TABLE_X_FREQUENCY.X_FREQUENCY%TYPE,             */
/* ip_prog_caller         caller function or procedure                       */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if insertion take place successfully              */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsibility to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION update_frequency_fun (
      x_frequency_in   IN   sa.table_x_frequency.x_frequency%TYPE,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    insert_part_num2frequency_fun                                    */
/* Objective  :   Inserts mtm_part_num14_x_frequency0 record                 */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/*          PART_NUM2X_FREQUENCY_in                                          */
/*                  SA.MTM_PART_NUM14_X_FREQUENCY0.PART_NUM2X_FREQUENCY%TYPE */
/*          X_FREQUENCY2PART_NUM_in                                          */
/*                  SA.MTM_PART_NUM14_X_FREQUENCY0.X_FREQUENCY2PART_NUM%TYPE */
/*               ip_prog_caller        caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if insertion take place successfully              */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsibility to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION insert_part_num2frequency_fun (
      part_num2x_frequency_in   IN   sa.mtm_part_num14_x_frequency0.part_num2x_frequency%TYPE,
      x_frequency2part_num_in   IN   sa.mtm_part_num14_x_frequency0.x_frequency2part_num%TYPE,
      ip_prog_caller            IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    update_part_num2frequency_fun                                    */
/* Objective  :   Updates mtm_part_num14_x_frequency0 record                 */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/*          PART_NUM2X_FREQUENCY_in                                          */
/*                  SA.MTM_PART_NUM14_X_FREQUENCY0.PART_NUM2X_FREQUENCY%TYPE */
/*          X_FREQUENCY2PART_NUM_in                                          */
/*                  SA.MTM_PART_NUM14_X_FREQUENCY0.X_FREQUENCY2PART_NUM%TYPE */
/*               ip_prog_caller        caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if insertion take place successfully              */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsibility to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION update_part_num2frequency_fun (
      part_num2x_frequency_in   IN   sa.mtm_part_num14_x_frequency0.part_num2x_frequency%TYPE,
      x_frequency2part_num_in   IN   sa.mtm_part_num14_x_frequency0.x_frequency2part_num%TYPE,
      ip_prog_caller            IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    get_prt_dom_objid_fun                                            */
/* Objective  :  Gets the table_prt_domain.objid for a given domanin_name    */
/*                In the event                                               */
/*                of an error , ora error is                                 */
/*               logged into the error_table.                                */
/* In Parameters :                                                           */
/*                   ip_domain         domain name                           */
/*                   ip_prog_caller    caller function or procedure          */
/*                                                                           */
/*                                                                           */
/* Returns:           table_prt_domain.objid if exists                       */
/*                    NULL if it does not exists                             */
/*                                                                           */
/*****************************************************************************/
   FUNCTION get_prt_dom_objid_fun (
      ip_domain        IN   VARCHAR2,
      ip_prog_caller   IN   VARCHAR2
   )
      RETURN NUMBER;

/*****************************************************************************/
  /*                                                                           */
  /* Name:            site_part_active_fun                                     */
  /* Objective:       This function checks if site part rec for a givem esn /  */
  /*                   service_id has a status of 'Active' in table_site_part. */
  /*                  part_status . In the event of an error, ora error is     */
  /*                  logged into the error table                              */
  /* In Parameters :                                                           */
  /*                  ip_x_service_id    esn/x_service_id                      */
  /*                                                                           */
  /*  Returns:        TRUE if the esn is active                                */
  /*                  FALSE if the esn is inactive                             */
/*****************************************************************************/
   FUNCTION active_site_part_fun (
      ip_x_service_id   IN   VARCHAR2,
      ip_prog_caller    IN   VARCHAR2
   )
      RETURN BOOLEAN;

/*****************************************************************************/
/*                                                                           */
/* Name:    insert_part_script_fun                                           */
/* Objective  :  Insert records into the table_x_part_script for a given ESN */
/*               from the source part number                                 */
/*               In the event of an error, ora error is logged into the      */
/*               error_table.                                                */
/* In Parameters :                                                           */
/*                 ip_partnum_objid    objid of the source part number      */
/*                 ip_prog_caller       caller function or procedure         */
/*                                                                           */
/*                                                                           */
/* Returns:           TRUE if insertion take place sucessfully               */
/*                    FALSE if insertion failed                              */
/*                                                                           */
/* Assumption:        It is the function caller's responsability to commit   */
/*                    upon validation of function outcome (true, false)      */
/*****************************************************************************/
   FUNCTION insert_part_script_fun (
      ip_part_number         IN   VARCHAR2,
      ip_source_part_objid   IN   NUMBER,
      ip_target_part_objid   IN   NUMBER,
      ip_prog_caller         IN   VARCHAR2
   )
      RETURN BOOLEAN;

   function delete_pending_red_fun (
      ip_esn in varchar2,
      ip_user in varchar2
   )
   return string;

   function time_tank_verify_fun (ip_esn in varchar2,
                                  ip_code in number,
                                  ip_seq in number)
   return string;

   function plus3_transfer_fun (ip_old_esn in varchar2,
                                ip_new_esn in varchar2,
                                ip_reason in varchar2,
                                ip_user in varchar2)
   return string;

   function reset_posa_phone_fun (ip_esn in varchar2,
                                  ip_reason in varchar2,
                                  ip_user in varchar2)
   return string;

   function update_expiration_date_fun (ip_esn in varchar2,
                                        ip_user in varchar2,
                                        ip_reason in varchar2,
                                        ip_exp_date in varchar2)
   return string;

   function click_plan_update_fun (ip_esn in varchar2,
                                   ip_click_plan in varchar2,
                                   ip_reason in varchar2,
                                   ip_user in varchar2)
   return string;
--------------------------------------

END toss_util_pkg;
/