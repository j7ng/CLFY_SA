CREATE OR REPLACE PACKAGE sa."ACCOUNT_MAINTENANCE_PKG" as
/********************************************************************
* Package Name: Account_Maintenance_pkg
*
* Description: This package is called by clarify application
* form 1108 and 1412 (Carrier Profile),(Line Management)
/********************************************************************
*
* procedure: replace
* return: 1. p_status varchar2
* 'S' Sucessful
* 'F' Fail
* 2. p_msg varchar2
* message
* logic:
* 1. Old account is set to inactive
* 2. If lines exists under old account, for each line
* set x_account_hist.x_end_date to current date
* 3. Insert a new account and set it to active.
* 4. If lines exists under old account, set lines to
* point to new account and insert new x_account_hist
* record for each line.
* History:
*
* Version Date Author     Description
* -----------------------------------------------------------
* 1.0 10-AUG-00 SL Initial Version
*
/********************************************************************
* procedure: Update
* return: 1. p_status varchar2
* 'S' Sucessful
* 'F' Fail
* 2. p_msg varchar2
* message
* logic:
* 1. Update existing account to have an end_date of current date
* 2. Set lines to point to the account selected by inserting a
* new x_account_hist record for each line and setting the
* end_date to '01/01/1753'
* History:
*
* Version Date Author     Description
* -----------------------------------------------------------
* 1.0 28-AUG-00 GP Initial Version

*
********************************************************************/

procedure replace_account (p_old_acct_num varchar2,
 p_old_acct_objid number,
 p_replace_acct_num varchar2,
 p_carr_objid number,
 p_status out varchar2,
 p_msg out varchar2);
---------------------------------------------------------
Procedure update_account (p_tran_type number,
 p_pi_objid number,
 p_acct_objid number,
 p_acct_num varchar2,
 p_carr_id number,
 p_status out varchar2,
 p_msg out varchar2);
---------------------------------------------------------
PROCEDURE copy_contact_info ( i_old_contact_id  IN  table_contact.objid%type,
                              i_sourcesystem    IN  VARCHAR2,
                              o_new_contact_id  OUT table_contact.objid%type,
                              o_err_code        OUT NUMBER,
                              o_err_msg         OUT VARCHAR2);

-- Procedure used to add an esn to an existing web account
PROCEDURE add_esn_to_account ( i_web_user_objid     IN  sa.table_web_user.objid%type,
                               i_esn_nick_name      IN  sa.table_x_contact_part_inst.x_esn_nick_name%type,
                               i_esn                IN  sa.table_part_inst.part_serial_no%type,
                               i_transfer_esn_flag  IN  VARCHAR2 DEFAULT 'N',
                               i_user_login_name    IN  sa.table_user.s_login_name%TYPE,
                               i_sourcesystem       IN  VARCHAR2,
                               o_err_code           OUT NUMBER,
                               o_err_msg            OUT VARCHAR2 );

-- Overloaded procedure to use reference esn (instead of web user objid)
PROCEDURE add_esn_to_account ( i_reference_esn      IN  VARCHAR2,
                               i_esn_nick_name      IN  sa.table_x_contact_part_inst.x_esn_nick_name%type,
                               i_esn                IN  sa.table_part_inst.part_serial_no%type,
                               i_transfer_esn_flag  IN  VARCHAR2 DEFAULT 'N',
                               i_user_login_name    IN  sa.table_user.s_login_name%TYPE,
                               i_sourcesystem       IN  VARCHAR2,
                               o_err_code           OUT NUMBER,
                               o_err_msg            OUT VARCHAR2 );
-- CR43088 WARP 2.0
PROCEDURE  remove_esn_from_account (ip_web_user_objid     IN table_web_user.objid%TYPE,
                                    ip_esn                IN table_part_inst.part_serial_no%TYPE,
                                    op_err_code           OUT VARCHAR2,
                                    op_err_msg            OUT VARCHAR2,
                                    --CR48846
                                    i_dummy_account_flag  IN VARCHAR2 DEFAULT 'N') ;
-- CR43088 WARP 2.0

-- CR47564
PROCEDURE Validate_Login_Pin (i_login_name     IN  VARCHAR2,
                              i_esn            IN  VARCHAR2,
                              i_min            IN  VARCHAR2,
                              i_security_pin   IN  VARCHAR2,
                              i_bus_org_id     IN  VARCHAR2,
                              o_err_code       OUT NUMBER ,
                              o_err_msg        OUT VARCHAR2 );
--CR47564 - WFM Changes
FUNCTION get_account_status  (i_esn  in VARCHAR2) RETURN VARCHAR2 ;

-- CR47564  WFM Changes
PROCEDURE  remove_account      (i_login_name     IN  VARCHAR2,
                                i_brand          IN  VARCHAR2,
                                i_commit_flag    IN  VARCHAR2  DEFAULT 'Y',
                                i_web_user_objid IN  VARCHAR2,
                                o_err_code       OUT NUMBER ,
                                o_err_msg        OUT VARCHAR2 );
-- Overloaded procedure to use for WFM Brand
PROCEDURE add_esn_to_account ( i_web_user_objid     IN  sa.table_web_user.objid%type,
                               i_esn                IN  sa.table_part_inst.part_serial_no%type,
                               i_brand                IN  VARCHAR2,
                               i_pin                IN  VARCHAR2,
                               i_esn_nick_name      IN  sa.table_x_contact_part_inst.x_esn_nick_name%type,
                               i_language           IN  VARCHAR2,
                               i_sourcesystem       IN  VARCHAR2,
                               o_err_code           OUT NUMBER,
                               o_err_msg            OUT VARCHAR2 );
--Validate verification code with last 6 digits of the ESN
PROCEDURE validate_verification_code(
                               i_esn               IN VARCHAR2,
                               i_verification_code IN VARCHAR2,
                               o_error_code OUT VARCHAR2,
                               o_error_msg OUT VARCHAR2 )    ;

-- CR53621  -> The following function is to get the Dummy Account or Real Accont
 FUNCTION get_account_status(i_login_name         IN VARCHAR2,
                             i_bus_org_objid      IN NUMBER) RETURN VARCHAR2 ;

end Account_Maintenance_pkg;
/