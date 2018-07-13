CREATE OR REPLACE PACKAGE sa."ADFCRM_ESN_ACCOUNT" IS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_ESN_ACCOUNT_PKG.sql,v $
--$Revision: 1.18 $
--$Author: syenduri $
--$Date: 2017/07/10 19:08:12 $
--$ $Log: ADFCRM_ESN_ACCOUNT_PKG.sql,v $
--$ Revision 1.18  2017/07/10 19:08:12  syenduri
--$ Added return to function get_esn_by_contact
--$
--$ Revision 1.17  2017/07/10 16:40:35  syenduri
--$ Added get_esn_by_contact function - CR51441 -- Track Name and Address history (Function been written by Mary)
--$
--$ Revision 1.16  2017/03/15 16:50:38  mmunoz
--$ CR46822 : New procedure update_dummy_account
--$
--$ Revision 1.15  2016/10/19 16:02:05  mmunoz
--$ CR44361 New procedure link_esn_to_account
--$
--$ Revision 1.14  2016/09/14 20:44:02  mmunoz
--$ CR43005 : Procedure  REMOVE_ESN_FROM_ACCOUNT updated
--$
--$ Revision 1.13  2015/01/22 19:15:50  nguada
--$ TAS_2015_03
--$
--$ Revision 1.12  2014/09/30 19:46:59  hcampano
--$ FIX ISSUE WHEN ENTERING CONTACT DETAILS FLOW
--$ PROBLEM: CHECKBOXES AND UPDATE PROCEDURES BREAK BECAUSE OF MISSING
--$ BUS ORG IN THE ADD INFO TABLE
--$
--$ Revision 1.11  2014/09/18 20:38:23  mmunoz
--$ Added changes for HPP phase II
--$
--$ Revision 1.10  2014/07/22 15:36:28  hcampano
--$ Do Not Call backend release CR29834
--$
--------------------------------------------------------------------------------------------
function is_enrolled_no_account(ip_ESN in sa.table_part_inst.part_serial_no%type)
return varchar2;

procedure add_esn_to_account_pymt (
    ip_web_user_objid  in sa.table_web_user.objid%type,
    ip_esn_nick_name   in sa.table_x_contact_part_inst.x_esn_nick_name%type,
    ip_ESN             in sa.table_part_inst.part_serial_no%type,
    ip_overwrite_esn   in number,  -- 1: Allow movement of an active esn between accounts, 0: Not allow movement of an active esn
    ip_user            in sa.table_user.s_login_name%type,
	ip_pymt_src        in sa.x_payment_source.objid%type,
    op_err_code        out varchar2,
    op_err_msg         out varchar2
);

procedure ADD_ESN_TO_ACCOUNT (
   /*--------------------------------------------------------------------------------------*/
   /*---  Remove from Existing Account (if linked / Del from: Table_X_Contact_Part_Inst) --*/
   /*---  Create Target Account Contact Copy   / contact,role,site,address)              --*/
   /*---  Link ESN to New Contact Copy (table_part_inst.part_inst2contact)               --*/
   /*---  Link ESN to Target Account (Table_X_Contact_Part_Inst)                         --*/
   /*--------------------------------------------------------------------------------------*/
    ip_web_user_objid  in sa.table_web_user.objid%type,
    ip_esn_nick_name   in sa.table_x_contact_part_inst.x_esn_nick_name%type,
    ip_ESN             in sa.table_part_inst.part_serial_no%type,
    ip_overwrite_esn   in number,  -- 1: Allow movement of an active esn between accounts, 0: Not allow movement of an active esn
    ip_user            in sa.table_user.s_login_name%type,
    op_err_code        out varchar2,
    op_err_msg         out varchar2
);

procedure REMOVE_ESN_FROM_ACCOUNT (
   /*--------------------------------------------------------------------------------------*/
   /*  If contact is linked to ESN (table_part_inst.x_part_inst2contact)                   */
   /*  then Copy contact information from table_part_inst.x_part_inst2contact and          */
   /*       link ESN to new contact copied                                                 */
   /*  Remove from Account (Del from: Table_X_Contact_Part_Inst)                           */
   /*--------------------------------------------------------------------------------------*/
    ip_web_user_objid  in table_web_user.objid%type,
    ip_ESN             in table_part_inst.part_serial_no%type,
    ip_user_login_name in varchar2 DEFAULT 'SA',  --CR43005
    op_err_code        out varchar2,
    op_err_msg         out varchar2
);

procedure MAKE_ESN_PRIMARY (
   /*----------------------------------------------------------------*/
   /*  Make esn the primary/default of the account                   */
   /*----------------------------------------------------------------*/
    ip_web_user_objid in table_web_user.objid%type,
    ip_esn             in table_part_inst.part_serial_no%type,
    op_err_code        out varchar2,
    op_err_msg         out varchar2
);
--------------------------------------------------------------------------------
  procedure update_contact_consent (ipv_cust_id             sa.table_contact.x_cust_id%type,
                                    ipv_contact_objid       sa.table_contact.objid%type,
                                    ipv_pin                 sa.table_x_contact_add_info.x_pin%type,
                                    ipv_dob                 varchar2, --(String mm/dd/yyyy format)
                                    ipv_consent_email       sa.table_x_contact_add_info.x_do_not_email%type,
                                    ipv_consent_phone       sa.table_x_contact_add_info.x_do_not_phone%type,
                                    ipv_consent_sms         sa.table_x_contact_add_info.x_do_not_sms%type,
                                    ipv_consent_mail        sa.table_x_contact_add_info.x_do_not_mail%type,
                                    ipv_consent_prerecorded sa.table_x_contact_add_info.x_prerecorded_consent%type,
                                    ipv_consent_mobile_ads  sa.table_x_contact_add_info.x_do_not_mobile_ads%type,
                                    ipv_user                sa.table_user.s_login_name%type
                                    );
--------------------------------------------------------------------------------
  procedure update_contact_consent (ipv_contact_objid sa.table_contact.objid%type);
--------------------------------------------------------------------------------
  function CONTACT(p_zip varchar2,
                          p_phone varchar2,
                          p_f_name varchar2,
                          p_l_name varchar2,
                          p_m_init varchar2,
                          p_add_1 varchar2,
                          p_add_2 varchar2,
                          p_city varchar2,
                          p_st varchar2,
                          P_Country Varchar2,
                          p_fax varchar2,
                          P_Email Varchar2,
                          p_dob varchar2, --(String mm/dd/yyyy format)
                          ip_do_not_phone in table_x_contact_add_info.x_do_not_phone%type, -- (NEW)
                          ip_do_not_mail in table_x_contact_add_info.x_do_not_mail%type, -- (NEW)
                          ip_do_not_sms in table_x_contact_add_info.x_do_not_sms%type, -- (NEW)
                          ip_prer_consent in table_x_contact_add_info.x_prerecorded_consent%type,
                          ip_mobile_ads in table_x_contact_add_info.x_do_not_mobile_ads%type,
                          ip_pin in table_x_contact_add_info.x_pin%type,
                          ip_squestion in table_web_user.x_secret_questn%type,
                          ip_sanswer in table_web_user.x_secret_ans%type,
                          ip_dummy_email in number,  -- 1:create a dummy account, 0: email should be provided
                          ip_overwrite_esn in number,  -- 1: Allow movement of an active esn between accounts, 0: Not allow movement of an active esn
                          ip_do_not_email in number, --1: Not Allow email communivations, 0: Allow email communications
                          P_Brand Varchar2, -- (creating a contact only)
                          p_pw in table_web_user.password%type,    --  (creating a contact only)
                          p_c_objid number, -- (updating a contact only)
                          p_esn in table_part_inst.part_serial_no%type,  -- (Add ESN to Account)
                          ip_user in sa.table_user.s_login_name%type
                          ) return varchar2;
--------------------------------------------------------------------------------
  Procedure Web_User_Prc (
      ip_webuser2contact in table_web_user.web_user2contact%type,
      ip_login  in table_web_user.login_name%type,
      ip_squestion in table_web_user.x_secret_questn%type,
      ip_sanswer in table_web_user.x_secret_ans%type,
      ip_pw in  table_web_user.password%type,
      ip_dummy_email in number,  -- 1:create a dummy account, 0: email should be provided
      op_web_user_objid out table_web_user.objid%type,
      op_err_code OUT VARCHAR2,
      op_err_msg out varchar2
  );
--------------------------------------------------------------------------------
 function ADD_MISSING_CONTACT (ip_esn varchar2,
                               ip_user varchar2) return varchar2;
--------------------------------------------------------------------------------
  procedure fix_missing_cai_bus_org(ip_contact_objid varchar2);
--------------------------------------------------------------------------------


procedure add_esn_to_group (
    ip_user            in varchar2,
    ip_web_user_objid  in varchar2,
    ip_group_objid     in varchar2,
    ip_esn             in varchar2,
    ip_esn_nick_name   in varchar2,
    op_err_code        out varchar2,
    op_err_msg         out varchar2);

function delete_group_member (
    ip_esn      in varchar2,
    ip_reason   in varchar2) return varchar2;


procedure link_esn_to_account (
    ip_user            in varchar2,
    ip_web_user_objid  in varchar2,
    ip_group_objid     in varchar2,
    ip_esn             in varchar2,
    ip_esn_nick_name   in varchar2,
    op_err_code        out varchar2,
    op_err_msg         out varchar2);

procedure update_dummy_account (
    ip_user            in varchar2,
    ip_web_user_objid  in varchar2,
    ip_new_login_name  in varchar2,
    ip_new_pin         in varchar2,
    ip_new_dob         in varchar2,
    ip_first_name      in varchar2,
    ip_last_name       in varchar2,
    op_err_code        out varchar2,
    op_err_msg         out varchar2);

function get_esn_by_contact (
	ip_contact_objid 	in varchar2) return varchar2;
end;
/