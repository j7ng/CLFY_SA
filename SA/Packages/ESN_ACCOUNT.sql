CREATE OR REPLACE PACKAGE sa.esn_account IS
 /****************************************************************************
  ****************************************************************************
  * $Revision: 1.6 $
  * $Author: oimana $
  * $Date: 2018/03/26 20:07:34 $
  * $Log: ESN_ACCOUNT.sql,v $
  * Revision 1.6  2018/03/26 20:07:34  oimana
  * CR57178 - Package Specs
  *
  * Revision 1.18  2018/03/26 16:54:55  oimana
  * CR57178 - Package Body
  *
  *
  *****************************************************************************
  *****************************************************************************/
--
--
PROCEDURE add_esn_to_acct (ip_web_user_objid   IN     sa.table_web_user.objid%TYPE,
                           ip_esn_nick_name    IN     sa.table_x_contact_part_inst.x_esn_nick_name%TYPE,
                           ip_esn              IN     sa.table_part_inst.part_serial_no%TYPE,
                           ip_overwrite_esn    IN     NUMBER,     -- 1: Allow movement of an active esn between accounts, 0: Not allow movement of an active esn
                           ip_user             IN     sa.table_user.s_login_name%TYPE,
                           ip_sourcesystem     IN     VARCHAR2,
                           op_err_code         OUT    VARCHAR2,
                           op_err_msg          OUT    VARCHAR2);
--
--
PROCEDURE esn_account_contact (p_zip                IN  VARCHAR2,
                               p_phone              IN  VARCHAR2,
                               p_f_name             IN  VARCHAR2,
                               p_l_name             IN  VARCHAR2,
                               p_m_init             IN  VARCHAR2,
                               p_add_1              IN  VARCHAR2,
                               p_add_2              IN  VARCHAR2,
                               p_city               IN  VARCHAR2,
                               p_st                 IN  VARCHAR2,
                               p_country            IN  VARCHAR2,
                               p_fax                IN  VARCHAR2,
                               p_email              IN  VARCHAR2,
                               p_dob                IN  VARCHAR2,                                       --(String mm/dd/yyyy format)
                               ip_do_not_phone      IN  table_x_contact_add_info.x_do_not_phone%TYPE,   -- (NEW)
                               ip_do_not_mail       IN  table_x_contact_add_info.x_do_not_mail%TYPE,    -- (NEW)
                               ip_do_not_sms        IN  table_x_contact_add_info.x_do_not_sms%TYPE,     -- (NEW)
                               ip_prer_consent      IN  table_x_contact_add_info.x_prerecorded_consent%TYPE,
                               ip_mobile_ads        IN  table_x_contact_add_info.x_do_not_mobile_ads%TYPE,
                               ip_pin               IN  table_x_contact_add_info.x_pin%TYPE,
                               ip_squestion         IN  table_web_user.x_secret_questn%TYPE,
                               ip_sanswer           IN  table_web_user.x_secret_ans%TYPE,
                               ip_email             IN  NUMBER,           -- 1:create a dummy account, 0: email should be provided
                               ip_overwrite_esn     IN  NUMBER,           -- 1: Allow movement of an active esn between accounts, 0: Not allow movement of an active esn
                               ip_do_not_email      IN  NUMBER,           -- 1: Not Allow email communivations, 0: Allow email communications
                               p_brand              IN  VARCHAR2,         -- (creating a contact only)
                               p_pw                 IN  table_web_user.password%TYPE,        -- (creating a contact only)
                               p_c_objid            IN  NUMBER,           -- (updating a contact only)
                               p_esn                IN  table_part_inst.part_serial_no%TYPE, -- (Add ESN to Account)
                               ip_user              IN  sa.table_user.s_login_name%TYPE,
                               p_shipping_address1  IN  VARCHAR2,
                               p_shipping_address2  IN  VARCHAR2,
                               p_shipping_city      IN  VARCHAR2,
                               p_shipping_state     IN  VARCHAR2,
                               p_shipping_zip       IN  VARCHAR2,
                               p_language           IN  VARCHAR2,
                               ip_esn_nick_name     IN  VARCHAR2,
                               ip_sourcesystem      IN  VARCHAR2,
                               op_web_user_objid    OUT table_web_user.objid%TYPE,
                               op_contact_objid     OUT NUMBER,
                               op_err_code          OUT VARCHAR2,
                               op_out_msg           OUT VARCHAR2);
--
--
PROCEDURE web_user_proc (ip_webuser2contact   IN     table_web_user.web_user2contact%TYPE,
                         ip_login             IN     table_web_user.login_name%TYPE,
                         ip_squestion         IN     table_web_user.x_secret_questn%TYPE,
                         ip_sanswer           IN     table_web_user.x_secret_ans%TYPE,
                         ip_pw                IN     table_web_user.password%TYPE,
                         ip_email             IN     NUMBER, -- 1:create a dummy account, 0: email should be provided
                         op_web_user_objid    OUT    table_web_user.objid%TYPE,
                         op_err_code          OUT    VARCHAR2,
                         op_err_msg           OUT    VARCHAR2);
--
--
PROCEDURE esn_dummy_acct_contacts (p_zip                 IN     VARCHAR2,
                                   p_phone               IN     VARCHAR2,
                                   p_f_name              IN     VARCHAR2,
                                   p_l_name              IN     VARCHAR2,
                                   p_m_init              IN     VARCHAR2,
                                   p_add_1               IN     VARCHAR2,
                                   p_add_2               IN     VARCHAR2,
                                   p_city                IN     VARCHAR2,
                                   p_st                  IN     VARCHAR2,
                                   p_country             IN     VARCHAR2,
                                   p_fax                 IN     VARCHAR2,
                                   p_dob                 IN     VARCHAR2,                                       --(String mm/dd/yyyy format)
                                   ip_do_not_phone       IN     table_x_contact_add_info.x_do_not_phone%TYPE,   -- (NEW)
                                   ip_do_not_mail        IN     table_x_contact_add_info.x_do_not_mail%TYPE,    -- (NEW)
                                   ip_do_not_sms         IN     table_x_contact_add_info.x_do_not_sms%TYPE,     -- (NEW)
                                   ip_prer_consent       IN     table_x_contact_add_info.x_prerecorded_consent%TYPE,
                                   ip_mobile_ads         IN     table_x_contact_add_info.x_do_not_mobile_ads%TYPE,
                                   ip_pin                IN     table_x_contact_add_info.x_pin%TYPE,
                                   ip_squestion          IN     table_web_user.x_secret_questn%TYPE,
                                   ip_sanswer            IN     table_web_user.x_secret_ans%TYPE,
                                   ip_email              IN     NUMBER, -- 1:create a dummy account, 0: email should be provided
                                   ip_overwrite_esn      IN     NUMBER, -- 1: Allow movement of an active esn between accounts, 0: Not allow movement of an active esn
                                   ip_do_not_email       IN     NUMBER, -- 1: Not Allow email communivations, 0: Allow email communications
                                   p_brand               IN     VARCHAR2,                             -- (creating a contact only)
                                   p_pw                  IN     table_web_user.password%TYPE,         --  (creating a contact only)
                                   p_c_objid             IN     NUMBER,                               -- (updating a contact only)
                                   p_esn                 IN     table_part_inst.part_serial_no%TYPE,  -- (Add ESN to Account)
                                   ip_user               IN     sa.table_user.s_login_name%TYPE,
                                   p_shipping_address1   IN     VARCHAR2,
                                   p_shipping_address2   IN     VARCHAR2,
                                   p_shipping_city       IN     VARCHAR2,
                                   p_shipping_state      IN     VARCHAR2,
                                   p_shipping_zip        IN     VARCHAR2,
                                   p_language            IN     VARCHAR2,
                                   ip_esn_nick_name      IN     VARCHAR2,
                                   ip_sourcesystem       IN     VARCHAR2,
                                   op_email              IN OUT VARCHAR2,                             -- make this as IN OUT parameter
                                   op_web_user_objid     OUT    table_web_user.objid%TYPE,
                                   op_contact_objid      OUT    NUMBER,
                                   op_err_code           OUT    VARCHAR2,
                                   op_out_msg            OUT    VARCHAR2);
--
--
END esn_account;
/