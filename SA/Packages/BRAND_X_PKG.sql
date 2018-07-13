CREATE OR REPLACE PACKAGE sa."BRAND_X_PKG" AS
 --------------------------------------------------------------------------------------------
 --$RCSfile: BRAND_X_PKG.sql,v $
 --$Revision: 1.61 $
 --$Author: oimana $
 --$Date: 2018/04/30 17:58:12 $
 --$ $Log: BRAND_X_PKG.sql,v $
 --$ Revision 1.61  2018/04/30 17:58:12  oimana
 --$ CR55465 - Package Specs
 --$
 --$ Revision 1.56  2018/01/25 22:41:12  skambhammettu
 --$ New procedure get_discount_amount
 --$
 --$ Revision 1.54  2018/01/16 16:50:42  skambhammettu
 --$ NEW PROCEDURE DEACTIVATE_MEMBER
 --$
 --$ Revision 1.51  2018/01/09 15:47:52  skambhammettu
 --$ New procedures delete_stage,get_member_min_by_group
 --$
 --$ Revision 1.50  2018/01/03 21:40:09  skambhammettu
 --$ Adding new input parameter to get_member_min_by_group
 --$
 --$ Revision 1.47  2017/10/12 19:18:43  smacha
 --$ Merged to Prod version.
 --$
 --$ Revision 1.41  2017/09/22 14:04:40  nsurapaneni
 --$ Code Merge with CR48846
 --$
 --$ Revision 1.35  2017/08/15 20:42:39  tpathare
 --$ Merged after 8/9
 --$
 --$ Revision 1.25  2017/05/16 19:37:32  vlaad
 --$ Merged with 5/16 Prod release for CR48643
 --$
 --$ Revision 1.21  2016/10/03 19:15:46  rpednekar
 --$ CR41658
 --$
 --$ Revision 1.20  2016/09/20 22:05:22  rpednekar
 --$ CR41658- New procedure GET_GROUPID_OF_REDEEMED_PIN
 --$
 --$ Revision 1.19  2016/04/19 21:28:51  pamistry
 --$ CR37756 - Overloaded validate_esn_sp_rules procedure to accept list of service_plan
 --$
 --$ Revision 1.18  2016/03/04 17:56:35  sraman
 --$ CR39391- Added a new procedure named update_so_stage_status_by_esn to this package to update x_service_order_stage table based on ESN
 --$
 --$ Revision 1.17  2016/01/27 17:16:58  sraman
 --$ CR39391 -  Merged with production copy
 --$
 --$ Revision 1.16  2016/01/15 19:22:46  smeganathan
 --$ CR39389 Changes for TW plus
 --$
 --$ Revision 1.14  2015/07/09 18:52:16  jpena
 --$ CR36347. Performance improvements on read_account_group and fix ESN parameter datatype.
 --$
 --$ Revision 1.13  2015/03/23 21:08:23  oarbab
 --$ CR33453 add new PROCEDURE ATTACH_PIN_TO_STAGING
 --$
 --$ Revision 1.12  2015/03/22 15:48:31  jpena
 --$ Changes for Total Wireless
 --$
 --$ Revision 1.60  2015/02/09 22:33:53  jpena
 --$ CR32463 - Brand X Changes
 --$
 --------------------------------------------------------------------------------------------
--
/******************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         BRAND_X_PKG                                                  */
/* PURPOSE:      Perform all brand x related actions                          */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 11g AND newer versions.                               */
/*                                                                            */
/* REVISIONS:                                                                 */
/* VERSION  DATE       WHO       PURPOSE                                      */
/* -------  ---------- --------- -------------------------------------------- */
/*  1.0     01/22/2015 Juda Pena Initial  Revision                            */
/******************************************************************************/
/******************************************************************************/
--
--
-- Added on 10/28/2014 by Juda Pena to set the account group master esn
PROCEDURE change_master (ip_account_group_id IN  NUMBER,
                         ip_esn              IN  VARCHAR2,
                         op_err_code         OUT NUMBER,
                         op_err_msg          OUT VARCHAR2,
                         ip_switch_pin_flag  IN  VARCHAR2 DEFAULT 'Y');
--
--
-- Added logic by Juda Pena to create a history row for x_program_trans
PROCEDURE create_program_trans (ip_program_enrolled_id      IN NUMBER,
                                ip_enrollment_status        IN VARCHAR2,
                                ip_enroll_status_reason     IN VARCHAR2,
                                ip_float_given              IN NUMBER,
                                ip_cooling_given            IN NUMBER,
                                ip_grace_period_given       IN NUMBER,
                                ip_trans_date               IN DATE,
                                ip_action_text              IN VARCHAR2,
                                ip_action_type              IN VARCHAR2,
                                ip_reason                   IN VARCHAR2,
                                ip_sourcesystem             IN VARCHAR2,
                                ip_esn                      IN VARCHAR2,
                                ip_exp_date                 IN DATE,
                                ip_cooling_exp_date         IN DATE,
                                ip_update_status            IN VARCHAR2,
                                ip_update_user              IN VARCHAR2,
                                ip_tran2pgm_entrolled       IN NUMBER,
                                ip_trans2site_part          IN NUMBER);
--
--
-- Added on 12/18/2014 by Juda Pena to retrieve the smp number
FUNCTION convert_pin_to_smp (ip_red_code IN VARCHAR2) RETURN VARCHAR2;
--
--
-- Added on 12/18/2014 by Juda Pena to retrieve the pin number
FUNCTION convert_smp_to_pin (ip_smp IN VARCHAR2) RETURN VARCHAR2;
--
--
-- Added on 12/06/2014 by Juda Pena to update member information
PROCEDURE delete_member (ip_account_group_id        IN     NUMBER,
                         iop_esn                    IN OUT VARCHAR2,
                         ip_account_group_member_id IN     NUMBER,
                         op_err_code                OUT    NUMBER,
                         op_err_msg                 OUT    VARCHAR2,
                         ip_bypass_last_mbr_flag    IN     VARCHAR2 DEFAULT 'N');
--
--
-- Added by Juda Pena on 01/13/2015 to expire a member from the deactivation process (service_deactivation_code.deactservice)
PROCEDURE expire_account_group (ip_esn       IN  VARCHAR2,
                                op_err_code  OUT NUMBER,
                                op_err_msg   OUT VARCHAR2);
--
--
-- Added on 11/06/2014 by Juda Pena to get member status and type (x_service_order_stage) information
FUNCTION get_group_status (ip_account_group_id IN  NUMBER) RETURN VARCHAR2;
--
--
-- Added on 12/17/2014 by Juda Pena to get the group id that has a payment pending record based on a pin
FUNCTION get_pmt_pending_acc_grp_id (ip_red_card_code IN VARCHAR2) RETURN NUMBER;

-- Added on 12/17/2014 by Juda Pena to get the group id that has a payment pending record based on a member esn
FUNCTION get_esn_pmt_pending_acc_grp_id (ip_esn IN VARCHAR2) RETURN NUMBER;
--
--
-- Added on 12/17/2014 by Juda Pena to get the rowtype for the account group based on a member esn
FUNCTION get_group_rec (ip_esn IN VARCHAR2) RETURN x_account_group%ROWTYPE;
--
--
-- Added function by Juda Pena on 01/08/2015 to return the account group member record based on an ESN
FUNCTION get_member_rec (ip_esn IN VARCHAR2) RETURN x_account_group_member%ROWTYPE;
--
--
-- Added by Juda Pena on 2/3/2015 to overload (locally in the BRAND_X_PKG) the service_plan.get_sp_retention_action
PROCEDURE get_retention_action (ip_esn               IN  VARCHAR2,
                                ip_flow_name         IN  VARCHAR2,
                                ip_service_plan_id   IN  NUMBER,
                                ip_red_card_pin      IN  VARCHAR2,
                                op_dest_plan_act_tbl OUT retention_action_typ_tbl,
                                op_err_code          OUT NUMBER,
                                op_err_msg           OUT VARCHAR2);
--
--
PROCEDURE get_red_card_detail (ip_esn             IN  VARCHAR2,
                               ip_red_card_code   IN  VARCHAR2,
                               op_add_on_flag     OUT VARCHAR2,
                               op_service_plan_id OUT NUMBER,
                               op_part_number     OUT VARCHAR2,
                               op_err_code        OUT NUMBER,
                               op_err_msg         OUT VARCHAR2);
--
--
-- Added table function logic to join web user objid data to account groups (by Web OBJID)
FUNCTION get_web_acct_group_info (ip_web_objid IN NUMBER) RETURN t_web_acc_grp_tab PIPELINED;
--
--
-- Added table function logic to join web user objid data to account groups (by ESN)
FUNCTION get_web_acct_group_by_esn (ip_esn IN VARCHAR2) RETURN t_web_acc_grp_tab PIPELINED;
--
--
-- Added on 12/18/2014 by Juda Pena to create a row insert into the member table (with no validations)
PROCEDURE insert_member (ip_account_group_id        IN  NUMBER,
                         ip_esn                     IN  VARCHAR2,
                         ip_promotion_id            IN  NUMBER,
                         ip_status                  IN  VARCHAR2,
                         ip_member_order            IN  NUMBER,
                         ip_subscriber_uid          IN  VARCHAR2,
                         ip_master_flag             IN  VARCHAR2,
                         ip_site_part_id            IN  NUMBER,
                         ip_program_param_id        IN  NUMBER,
                         op_account_group_member_id OUT NUMBER,
                         op_err_code                OUT NUMBER,
                         op_err_msg                 OUT VARCHAR2);
--
--
-- Added on 12/26/2014 by Juda Pena to determine if a pin has been burnt
FUNCTION is_pin_burned (ip_red_code IN VARCHAR2) RETURN VARCHAR2;
--
--
PROCEDURE log_error (ip_error_text   IN VARCHAR2,
                     ip_error_date   IN DATE,
                     ip_action       IN VARCHAR2,
                     ip_key          IN VARCHAR2,
                     ip_program_name IN VARCHAR2);
--
--
-- Added by Juda Pena on 12/26/2014
PROCEDURE reassign_service_order_master (ip_account_group_id  IN  NUMBER,
                                         ip_queued_status     IN  VARCHAR2,  -- QUEUED
                                         op_err_code          OUT NUMBER,
                                         op_err_msg           OUT VARCHAR2);
--
--
-- Added on 12/15/2014 by Juda Pena to replace a member when a phone upgrade or warranty exchange is performed
PROCEDURE replace_member (ip_old_esn            IN  VARCHAR2,
                          ip_new_esn            IN  VARCHAR2,
                          ip_call_trans_id      IN  NUMBER,
                          op_err_code           OUT NUMBER,
                          op_err_msg            OUT VARCHAR2);
--
--
-- Added on 12/09/2014 by Juda Pena to return the next esn to be the master of an account group
FUNCTION select_next_master_esn (ip_account_group_id  IN  NUMBER,
                                 ip_old_master_esn    IN  VARCHAR2) RETURN VARCHAR2;
--
--
-- Added on 12/09/2014 by Juda Pena to return the next member order
FUNCTION select_next_member_order (ip_account_group_id IN NUMBER) RETURN NUMBER;
--
--
-- Added on 12/01/2014 by Juda Pena to create a new account group
PROCEDURE create_service_transaction_log (ip_client_transaction_id  IN  VARCHAR2,
                                          ip_client_id              IN  VARCHAR2,
                                          ip_error_code             IN  VARCHAR2,
                                          ip_error_message          IN  VARCHAR2,
                                          ip_server_transaction_id  IN  VARCHAR2,
                                          ip_custom_message         IN  VARCHAR2,
                                          ip_summary                IN  VARCHAR2,
                                          ip_custom_errcode         IN  VARCHAR2,
                                          ip_payload                IN  CLOB,
                                          ip_flow_name              IN  VARCHAR2,
                                          ip_operation_name         IN  VARCHAR2,
                                          ip_bus_org_id             IN  VARCHAR2,
                                          ip_source_system          IN  VARCHAR2,
                                          ip_instance_id            IN  NUMBER,
                                          ip_instance_name          IN  VARCHAR2,
                                          ip_failure_timestamp      IN  DATE,
                                          ip_failure_source         IN  VARCHAR2,
                                          ip_error_type             IN  VARCHAR2,
                                          ip_failure_target         IN  VARCHAR2,
                                          ip_esn                    IN  VARCHAR2,
                                          ip_min                    IN  VARCHAR2,
                                          ip_red_code               IN  VARCHAR2,
                                          ip_iccid                  IN  VARCHAR2,
                                          op_err_code               OUT NUMBER,
                                          op_err_msg                OUT VARCHAR2);
--
--
-- Added on 11/06/2014 by Juda Pena to create a new account group
PROCEDURE create_account_group (ip_account_group_name         IN  VARCHAR2,
                                ip_service_plan_id            IN  NUMBER,
                                ip_service_plan_feature_date  IN  DATE,
                                ip_program_enrolled_id        IN  NUMBER,
                                ip_status                     IN  VARCHAR2,
                                ip_bus_org_id                 IN  VARCHAR2,
                                op_account_group_id           OUT NUMBER,
                                op_err_code                   OUT NUMBER,
                                op_err_msg                    OUT VARCHAR2);
--
--
--  Added on 12/11/2014 by Juda Pena to determine service plan id for a given group
FUNCTION get_group_service_plan_id (ip_account_group_id IN NUMBER) RETURN NUMBER;
--
--
-- Added on 11/06/2014 by Juda Pena to update account group information
PROCEDURE update_account_group (ip_account_group_id          IN  NUMBER,
                                ip_account_group_name        IN  VARCHAR2,
                                ip_service_plan_id           IN  NUMBER,
                                ip_service_plan_feature_date IN  DATE,
                                ip_program_enrolled_id       IN  NUMBER,
                                ip_status                    IN  VARCHAR2,
                                ip_start_date                IN  DATE,
                                ip_end_date                  IN  DATE,
                                op_err_code                  OUT NUMBER,
                                op_err_msg                   OUT VARCHAR2);
--
--
--Added on 11/24/2014 by Phani Kolipakula to validate the service plan compatibility
FUNCTION valid_service_plan_esn (ip_service_plan_id IN NUMBER,
                                 ip_esn             IN VARCHAR2) RETURN VARCHAR2;
--
--
--Added on 11/24/2014 by Phani Kolipakula to validate the service plan compatibility
FUNCTION valid_service_plan_group (ip_account_group_id       IN NUMBER,
                                   ip_esn                    IN VARCHAR2) RETURN VARCHAR2;
--
--
-- Added on 11/25/2014 by Phani Kolipakula to validate all queued card sp/no lines against the provided red card code sp/no lines.
FUNCTION valid_queued_red_cards (ip_esn           IN VARCHAR2,
                                 ip_red_card_code IN VARCHAR2) RETURN VARCHAR2;
--
--
-- Added on 11/25/2014 by Juda Pena, overloaded to validate all queued pins service plan no. of lines against the provided es service plan no lines.
FUNCTION valid_queued_red_cards (ip_esn             IN VARCHAR2,
                                 ip_service_plan_id IN NUMBER) RETURN VARCHAR2;
--
--
-- Added on 12/09/2014 by Juda Pena to validate red card sp against the account group sp.
FUNCTION incompatible_sp_enrollment (ip_esn            IN VARCHAR2,
                                     ip_red_card_code  IN VARCHAR2) RETURN VARCHAR2;
--
--
FUNCTION incompatible_sp_enrollment (ip_esn             IN VARCHAR2,
                                     ip_service_plan_id IN NUMBER) RETURN VARCHAR2;
--
--
-- Added on 11/06/2014 by Juda Pena to get member status and type (x_service_order_stage) information
PROCEDURE get_group_master (ip_account_group_id             IN  NUMBER,
                            ip_so_status                    IN VARCHAR2,
                            op_account_group_member_id      OUT NUMBER,
                            op_account_group_status         OUT VARCHAR2,
                            op_account_group_member_status  OUT VARCHAR2,
                            op_type                         OUT VARCHAR2,
                            op_so_stage_objid               OUT NUMBER,
                            op_err_code                     OUT NUMBER,
                            op_err_msg                      OUT VARCHAR2);
--
--
-- Added on 11/13/2014 by Juda Pena to get the email and web user objid
PROCEDURE get_account_info (ip_esn              IN  VARCHAR2,
                            ip_bus_org_id       IN  VARCHAR2,
                            op_email            OUT VARCHAR2,
                            op_web_user_objid   OUT NUMBER,
                            op_account_group_id OUT NUMBER,
                            op_err_code         OUT NUMBER,
                            op_err_msg          OUT VARCHAR2);
--
--
PROCEDURE get_default_group_name (ip_web_user_objid      IN  NUMBER,
                                  op_account_group_name  OUT VARCHAR2);
--
--
-- Added on 11/18/2014 by Juda Pena to get the member and group objids
PROCEDURE get_member_info (ip_esn                         IN  VARCHAR2,
                           op_account_group_member_id     OUT NUMBER,
                           op_account_group_id            OUT NUMBER,
                           op_account_group_member_status OUT VARCHAR2,
                           op_master_flag                 OUT VARCHAR2,
                           op_err_code                    OUT NUMBER,
                           op_err_msg                     OUT VARCHAR2);
--
--
FUNCTION get_account_master_flag (ip_account_group_id IN NUMBER) RETURN VARCHAR2;
--
--
FUNCTION get_master_esn (ip_account_group_id IN NUMBER) RETURN VARCHAR2;
--
--
-- Added on 11/06/2014 by Juda Pena to get the master esn of the group
PROCEDURE get_master_esn (ip_account_group_id        IN  NUMBER,
                          ip_esn                     IN  VARCHAR2,
                          op_master_esn              OUT VARCHAR2,
                          op_account_group_member_id OUT NUMBER,
                          op_err_code                OUT NUMBER,
                          op_err_msg                 OUT VARCHAR2);

-- Added on 10/28/2014 by Juda Pena to set the account group master esn
PROCEDURE set_account_group_master (ip_account_group_id IN NUMBER,
                                    ip_esn              IN VARCHAR2,
                                    op_err_code         OUT VARCHAR2,
                                    op_err_msg          OUT VARCHAR2);
--
--
FUNCTION get_part_num_fea_value (ip_part_number IN VARCHAR2,
                                 ip_fea_name    IN VARCHAR2) RETURN VARCHAR2;
--
--
-- Added on 12/05/2014 by Juda Pena to get the feature value based on a given service plan and feature name
FUNCTION get_feature_value (ip_service_plan_id IN  NUMBER,
                            ip_fea_name        IN  VARCHAR2) RETURN VARCHAR2;
--
--
FUNCTION get_number_of_lines (ip_service_plan_id IN NUMBER) RETURN NUMBER;
--
--
--  Added on 12/1/2014 by Juda Pena to get the group id based on a call_trans_id
PROCEDURE get_account_group_id (ip_call_trans_id    IN  NUMBER,
                                op_account_group_id OUT NUMBER,
                                op_master_flag      OUT VARCHAR2,
                                op_service_plan_id  OUT NUMBER);
--
--
--  Added on 12/1/2014 by Juda Pena to get the group id based on an esn
FUNCTION get_account_group_id (ip_esn            IN VARCHAR2,
                               ip_effective_date IN DATE) RETURN NUMBER;
--
--
FUNCTION get_shared_group_flag (ip_bus_org_id IN VARCHAR2) RETURN VARCHAR2;
--
--
-- Added on 11/19/2014 by Juda Pena to get a valid esn + service plan for a given red card code
PROCEDURE get_red_card_esn_sp (ip_red_card_code    IN  VARCHAR2,
                               op_esn              OUT VARCHAR2,
                               op_service_plan_id  OUT NUMBER);
--
--
-- Added on 11/19/2014 by Juda Pena to get a valid esn for a given red card code
FUNCTION get_dummy_esn (ip_red_card_code IN VARCHAR2) RETURN VARCHAR2;
--
--
-- Added on 11/20/2014 by Juda Pena to
PROCEDURE redeem_plan_group_feasible (ip_account_group_id     IN  NUMBER,
                                      ip_esn                  IN  VARCHAR2,
                                      ip_redeem_now_flag      IN  VARCHAR2,
                                      ip_new_service_plan_id  IN  NUMBER,
                                      op_err_code             OUT NUMBER,
                                      op_err_msg              OUT VARCHAR2);
--
--
-- Added on 12/09/2014 by Juda Pena to wrap the validate esn and service plan for brand x groups
PROCEDURE validate_esn_sp_rules (ip_esn                    IN  VARCHAR2,
                                 ip_service_plan_id        IN  NUMBER,
                                 ip_bus_org_id             IN  VARCHAR2,
                                 op_esn_sp_validation_tab  OUT esn_sp_validation_tab,
                                 op_err_code               OUT NUMBER,
                                 op_err_msg                OUT VARCHAR2);
--
--
-- Overloading Procedure added on 03/28/2016 by sethiraj to accept list of service_plan - CR37756
PROCEDURE validate_esn_sp_rules (ip_esn                   IN  VARCHAR2,
                                 ip_service_plan_id_list  IN  typ_number_array,
                                 ip_bus_org_id            IN  VARCHAR2,
                                 op_esn_sp_validation_tab OUT esn_sp_validation_tab,
                                 op_err_code              OUT NUMBER,
                                 op_err_msg               OUT VARCHAR2);
--
--
-- Added on 11/20/2014 by Juda Pena to wrap the validate_red_card_pkg.main and add more features + service plans for brand x groups
PROCEDURE validate_red_card_sp (ip_red_card_code      IN      VARCHAR2,
                                ip_smpnumber          IN      VARCHAR2,
                                ip_source_system      IN      VARCHAR2,
                                iop_esn               IN OUT  VARCHAR2,
                                ip_bus_org_id         IN      VARCHAR2,
                                ip_client_id          IN      VARCHAR2,
                                op_available_capacity OUT     NUMBER,
                                op_refcursor          OUT     SYS_REFCURSOR,
                                op_err_code           OUT     NUMBER,
                                op_err_msg            OUT     VARCHAR2);

-- Added on 11/20/2014 by Juda Pena to wrap the validate_red_card_pkg.main and add more features for brand x groups
PROCEDURE validate_red_card (ip_red_card_code      IN      VARCHAR2,
                             ip_smpnumber          IN      VARCHAR2,
                             ip_source_system      IN      VARCHAR2,
                             ip_esn                IN OUT  VARCHAR2,
                             ip_bus_org_id         IN      VARCHAR2,  -- TOTAL_WIRELESS
                             op_available_capacity OUT     NUMBER,
                             op_refcursor          OUT     SYS_REFCURSOR,
                             op_err_code           OUT     NUMBER,
                             op_err_msg            OUT     VARCHAR2);
--
--
-- Added on 11/19/2014 by Juda Pena to get/generate the subscriber id
FUNCTION get_subscriber_uid (ip_esn IN VARCHAR2) RETURN VARCHAR2;
--
--
-- Added on 11/19/2014 by phani kolipakula to validate the  ESN active lines and Number of Lines PIN
FUNCTION valid_number_of_lines (ip_esn                IN  VARCHAR2,
                                ip_red_card_code      IN  VARCHAR2,
                                op_available_capacity OUT NUMBER) RETURN VARCHAR2;
--
--
-- Added on 01/21/2015 by Juda Pena to validate
FUNCTION valid_number_of_lines (ip_esn                IN  VARCHAR2,
                                ip_service_plan_id    IN  VARCHAR2) RETURN VARCHAR2;
--
--
-- Added on 11/25/2014 by Phani Kolipakula to validate actual group members against the provided red card code sp/number of lines.
FUNCTION valid_number_of_lines (ip_esn                IN  VARCHAR2,
                                ip_service_plan_id    IN  VARCHAR2,
                                op_available_capacity OUT NUMBER,
                                op_number_of_lines    OUT NUMBER) RETURN VARCHAR2;
--
--
-- Added on 11/06/2014 by Juda Pena to add a account group member
PROCEDURE create_member (ip_account_group_id         IN  NUMBER,
                         ip_esn                      IN  VARCHAR2,
                         ip_promotion_id             IN  NUMBER,
                         ip_status                   IN  VARCHAR2,
                         ip_member_order             IN  NUMBER,
                         op_subscriber_uid           OUT VARCHAR2,
                         op_account_group_member_id  OUT NUMBER,
                         op_err_code                 OUT NUMBER,
                         op_err_msg                  OUT VARCHAR2);
--
--
-- Added on 10/17/2014 by Juda Pena to change the account group service plan
PROCEDURE change_service_plan (ip_account_group_id  IN  NUMBER,
                               ip_service_plan_id   IN  NUMBER,
                               op_err_code          OUT NUMBER,
                               op_err_msg           OUT VARCHAR2);
--
--
-- Added on 11/06/2014 by Juda Pena to update member information
PROCEDURE update_member (ip_account_group_member_id IN  NUMBER,
                         ip_esn                     IN  VARCHAR2,
                         ip_promotion_id            IN  NUMBER,
                         ip_status                  IN  VARCHAR2,
                         ip_start_date              IN  DATE,
                         ip_end_date                IN  DATE,
                         op_err_code                OUT NUMBER,
                         op_err_msg                 OUT VARCHAR2);
--
--
-- Added on 01/08/2015 by Juda Pena to update receive_text_alerts_flag
PROCEDURE update_receive_text_alerts (ip_esn                       IN  VARCHAR2,
                                      ip_receive_text_alerts_flag  IN  VARCHAR2,
                                      op_err_code                  OUT NUMBER,
                                      op_err_msg                   OUT VARCHAR2);
--
--
-- Added on 11/21/2014 by Phani Kolipakula to update the status
PROCEDURE update_so_stage_status (ip_account_group_id       IN  NUMBER,
                                  ip_payment_pending_status IN  VARCHAR2,  -- PAYMENT_PENDING
                                  ip_queued_status          IN  VARCHAR2,  -- QUEUED
                                  ip_prequeued_status       IN  VARCHAR2,  -- TO_QUEUE
                                  op_err_code               OUT NUMBER,
                                  op_err_msg                OUT VARCHAR2);
--
--
-- Added by Juda Pena on 11/20/2014
PROCEDURE complete_master_service_order (ip_account_group_id  IN  NUMBER,
                                         ip_complete_status   IN  VARCHAR2,  -- COMPLETE
                                         ip_queued_status     IN  VARCHAR2,  -- QUEUED
                                         ip_prequeued_status  IN  VARCHAR2,  -- TO_QUEUE
                                         op_err_code          OUT NUMBER,
                                         op_err_msg           OUT VARCHAR2);
--
--
-- Added on 11/10/2014 by phani kolipakula tocreate service order stage
PROCEDURE create_service_order_stage (ip_account_group_member_id  IN  NUMBER,
                                      ip_esn                      IN  VARCHAR2,
                                      ip_sim                      IN  VARCHAR2,
                                      ip_zipcode                  IN  VARCHAR2,
                                      ip_pin                      IN  VARCHAR2,
                                      ip_service_plan_id          IN  NUMBER,
                                      ip_case_id                  IN  NUMBER,
                                      ip_status                   IN  VARCHAR2,
                                      ip_type                     IN  VARCHAR2,
                                      ip_program_param_id         IN  NUMBER,
                                      ip_pmt_source_id            IN  VARCHAR2,
                                      ip_web_objid                IN  NUMBER,
                                      op_service_order_stage_id   OUT NUMBER,
                                      op_err_code                 OUT NUMBER,
                                      op_err_msg                  OUT VARCHAR2);
--
--
-- Added on 10/29/2014 by Juda Pena to create the stage record (wo pragma)
PROCEDURE create_service_order_stage_we (ip_account_group_member_id IN NUMBER,
                                         ip_esn                     IN VARCHAR2,
                                         ip_sim                     IN VARCHAR2,
                                         ip_zipcode                 IN VARCHAR2,
                                         ip_pin                     IN VARCHAR2,
                                         ip_service_plan_id         IN NUMBER,
                                         ip_case_id                 IN NUMBER,
                                         ip_status                  IN VARCHAR2,
                                         ip_type                    IN VARCHAR2,
                                         ip_program_param_id        IN NUMBER,
                                         ip_pmt_source_id           IN VARCHAR2,
                                         ip_web_objid               IN NUMBER,
                                         ip_sourcesystem            IN  VARCHAR2,
                                         ip_bus_org_id              IN  VARCHAR2,
                                         op_service_order_stage_id  OUT NUMBER,
                                         op_err_code                OUT NUMBER,
                                         op_err_msg                 OUT VARCHAR2);
--
--
-- (Overloaded) Added on 01/08/2014 by Juda Pena to create the SOS record (with sourcesystem)
PROCEDURE create_service_order_stage (ip_account_group_member_id IN  NUMBER,
                                      ip_esn                     IN  VARCHAR2,
                                      ip_sim                     IN  VARCHAR2,
                                      ip_zipcode                 IN  VARCHAR2,
                                      ip_pin                     IN  VARCHAR2,
                                      ip_service_plan_id         IN  NUMBER,
                                      ip_case_id                 IN  NUMBER,
                                      ip_status                  IN  VARCHAR2,
                                      ip_type                    IN  VARCHAR2,
                                      ip_program_param_id        IN  NUMBER,
                                      ip_pmt_source_id           IN  VARCHAR2,
                                      ip_web_objid               IN  NUMBER,
                                      ip_sourcesystem            IN  VARCHAR2,
                                      ip_bus_org_id              IN  VARCHAR2,
                                      op_service_order_stage_id  OUT NUMBER,
                                      op_err_code                OUT NUMBER,
                                      op_err_msg                 OUT VARCHAR2);
--
--
-- CR48480 added overloaded procedure to create the SOS record with discount list
PROCEDURE create_service_order_stage (ip_account_group_member_id IN  NUMBER,
                                      ip_esn                     IN  VARCHAR2,
                                      ip_sim                     IN  VARCHAR2,
                                      ip_zipcode                 IN  VARCHAR2,
                                      ip_pin                     IN  VARCHAR2,
                                      ip_service_plan_id         IN  NUMBER,
                                      ip_case_id                 IN  NUMBER,
                                      ip_status                  IN  VARCHAR2,
                                      ip_type                    IN  VARCHAR2,
                                      ip_program_param_id        IN  NUMBER,
                                      ip_pmt_source_id           IN  VARCHAR2,
                                      ip_web_objid               IN  NUMBER,
                                      ip_sourcesystem            IN  VARCHAR2,
                                      ip_bus_org_id              IN  VARCHAR2,
                                      ip_discount_code_list      IN  discount_code_tab,
                                      op_service_order_stage_id  OUT NUMBER,
                                      op_err_code                OUT NUMBER,
                                      op_err_msg                 OUT VARCHAR2);
--
--
-- Added on 11/10/2014 by phani kolipakula to update service order stage
PROCEDURE update_service_order_stage (ip_service_order_stage_id  IN  NUMBER,
                                      ip_account_group_member_id IN  NUMBER,
                                      ip_esn                     IN  VARCHAR2,
                                      ip_sim                     IN  VARCHAR2,
                                      ip_zipcode                 IN  VARCHAR2,
                                      ip_pin                     IN  VARCHAR2,
                                      ip_service_plan_id         IN  NUMBER,
                                      ip_case_id                 IN  NUMBER,
                                      ip_status                  IN  VARCHAR2,
                                      ip_type                    IN  VARCHAR2,
                                      ip_program_param_id        IN  NUMBER,
                                      ip_pmt_source_id           IN  VARCHAR2,
                                      op_err_code                OUT NUMBER,
                                      op_err_msg                 OUT VARCHAR2);
--
--
-- Added on 11/10/2014 by phani kolipakula to create account group benefit
PROCEDURE create_account_group_benefit (ip_account_group_id         IN  NUMBER,
                                        ip_service_plan_id          IN  NUMBER,
                                        ip_status                   IN  VARCHAR2,
                                        ip_start_date               IN  DATE,
                                        ip_end_date                 IN  DATE,
                                        ip_call_trans_id            IN  NUMBER,
                                        op_account_group_benefit_id OUT NUMBER,
                                        op_err_code                 OUT NUMBER,
                                        op_err_msg                  OUT VARCHAR2);
--
--
-- Added on 11/10/2014 by phani kolipakula to update account group benefit
PROCEDURE update_account_group_benefit (ip_account_group_benefit_id  IN  NUMBER,
                                        ip_account_group_id          IN  NUMBER,
                                        ip_service_plan_id           IN  NUMBER,
                                        ip_status                    IN  VARCHAR2,
                                        ip_start_date                IN  DATE,
                                        ip_end_date                  IN  DATE,
                                        ip_call_trans_id             IN  NUMBER,
                                        op_err_code                  OUT NUMBER,
                                        op_err_msg                   OUT VARCHAR2);
--
--
-- Added by Juda Pena on 03/03/2015 to be used by CBO to provide the get account group summary data
PROCEDURE get_account_group_summary (ip_web_objid         IN  NUMBER,   -- optional
                                     ip_s_login_name      IN  VARCHAR2, -- optional
                                     ip_account_group_id  IN  NUMBER,   -- optional
                                     ip_bus_org_id        IN  VARCHAR2, -- mandatory
                                     op_refcursor         OUT SYS_REFCURSOR,
                                     op_err_code          OUT NUMBER,
                                     op_err_msg           OUT VARCHAR2);

-- Added overloaded on 11/06/2014 by Juda Pena to get member account information
PROCEDURE read_account_group (ip_esn        IN  VARCHAR2,
                              op_refcursor  OUT SYS_REFCURSOR,
                              op_err_code   OUT NUMBER,
                              op_err_msg    OUT VARCHAR2);
--
--
-- Added on 11/10/2014 by Juda Pena read account group.
PROCEDURE read_account_group  (ip_account_group_id  IN  NUMBER,
                               ip_esn               IN  VARCHAR2,
                               op_account_group_tab OUT account_group_member_tab,
                               op_err_code          OUT NUMBER,
                               op_err_msg           OUT VARCHAR2);
--
--
PROCEDURE read_account_group_member (ip_account_group_id        IN NUMBER,
                                     ip_account_group_member_id IN NUMBER,
                                     op_account_group_tab       OUT account_group_member_tab,
                                     op_err_code                OUT NUMBER,
                                     op_err_msg                 OUT VARCHAR2);
--
--
-- Test Stored Procedure to find an esn list, plan and red card available
PROCEDURE get_tw_test_esns (ip_part_class_name  IN  VARCHAR2,
                            op_service_plan_id  OUT NUMBER,
                            op_market_name      OUT VARCHAR2,
                            op_esn_list         OUT VARCHAR2,
                            op_red_card_list    OUT VARCHAR2);
--
--
-- Test Stored Procedure to find an esn list, plan and red card available
PROCEDURE get_tw_test_esns2 (ip_part_class_name  IN  VARCHAR2,
                             op_service_plan_id  OUT NUMBER,
                             op_market_name      OUT VARCHAR2,
                             op_esn_list         OUT VARCHAR2,
                             op_red_card_list    OUT VARCHAR2);
--
--
PROCEDURE get_status_by_esn (ip_esn        IN  VARCHAR2,
                             op_min        OUT VARCHAR2,
                             op_esn        OUT VARCHAR2,
                             op_esn_status OUT VARCHAR2,
                             op_min_status OUT VARCHAR2);
--
--
PROCEDURE get_status_by_min (ip_min        IN  VARCHAR2,
                             op_min        OUT VARCHAR2,
                             op_esn        OUT VARCHAR2,
                             op_esn_status OUT VARCHAR2,
                             op_min_status OUT VARCHAR2);
--
--
-- Added on 10/28/2014 by Juda Pena to find if an open port case exists for a min
FUNCTION port_case_exists (ip_min IN VARCHAR2) RETURN VARCHAR2;
--
--
-- CR33453
PROCEDURE attach_pin_to_staging (ip_group_id  IN  NUMBER,
                                 ip_pin       IN  VARCHAR2,
                                 op_err_code  OUT NUMBER,
                                 op_err_msg   OUT VARCHAR2);
--
--
-- CR39391 - BYOP New Procedure to update the status by ESN
PROCEDURE update_so_stage_status_by_esn (ip_account_group_id  IN  NUMBER,
                                         ip_esn               IN  VARCHAR2,
                                         ip_status            IN  VARCHAR2,
                                         op_err_code          OUT NUMBER,
                                         op_err_msg           OUT VARCHAR2);
--
--
-- CR39391 - BYOP New Procedure to return the status of PIN based on i/p group or Pin
FUNCTION is_pin_burned_by_group_pin_esn (ip_account_group_id IN NUMBER,
                                         ip_esn              IN VARCHAR2,
                                         ip_pin              IN VARCHAR2) RETURN VARCHAR2;
--
--
--CR41658
PROCEDURE get_groupid_of_redeemed_pin (ip_pin        IN  VARCHAR2,
                                       op_esn        OUT VARCHAR2,
                                       op_group_id   OUT VARCHAR2,
                                       op_web_objid  OUT VARCHAR2,
                                       op_error_code OUT VARCHAR2,
                                       op_err_msg    OUT VARCHAR2);
--
--
--Added new function - CR48716
FUNCTION is_master_esn_active (i_esn IN VARCHAR2) RETURN VARCHAR2;
--
--
-- CR48846
PROCEDURE get_member_esn_by_group (i_groupid      IN NUMBER,
                                   o_esn_list_cur OUT SYS_REFCURSOR,
                                   o_err_msg      OUT VARCHAR2);
--
--
-- CR48846 - Return staged flag,pin avialable flag and group service plan id details for an ESN
PROCEDURE get_esn_details (i_esn                        IN VARCHAR2,
                           o_is_staged_flag             OUT VARCHAR2,
                           o_is_pin_available_flag      OUT VARCHAR2,
                           o_group_service_plan_id      OUT NUMBER,
                           o_error_code                 OUT VARCHAR2,
                           o_error_msg                  OUT VARCHAR2);
--
--
-- CR50295
PROCEDURE get_esn_info_from_reserved_pin (ip_pin        IN  VARCHAR2,
                                          op_recordset  OUT SYS_REFCURSOR,
                                          op_error_code OUT VARCHAR2,
                                          op_err_msg    OUT VARCHAR2);
--
--
-- CR50295
PROCEDURE get_bundled_info_from_esn (ip_esn        IN  table_part_inst.part_serial_no%TYPE,
                                     op_recordset  OUT SYS_REFCURSOR,
                                     op_red_code   OUT table_part_inst.x_red_code%TYPE,
                                     op_pin_status OUT table_x_code_table.x_code_name%TYPE,
                                     op_error_code OUT VARCHAR2,
                                     op_err_msg    OUT VARCHAR2);
--
--
--TW Web Common Standards
PROCEDURE get_group_details (i_account_group_id         IN  VARCHAR2,
                             o_is_pin_available_flag    OUT VARCHAR2,
                             o_group_service_plan_id    OUT NUMBER,
                             o_payment_pending_devices  OUT SYS_REFCURSOR,
                             o_error_code               OUT VARCHAR2,
                             o_error_msg                OUT VARCHAR2);
--
--
PROCEDURE delete_stage (i_esn      IN  VARCHAR2,
                        o_response OUT VARCHAR2);
--
--
PROCEDURE get_group_mins (i_groupid      IN  NUMBER,
                          i_master_esn   IN  VARCHAR2,
                          i_min          IN  VARCHAR2,
                          o_min_list_cur OUT SYS_REFCURSOR,
                          o_error_code   OUT NUMBER,
                          o_error_msg    OUT VARCHAR2);
--
--
PROCEDURE deactivate_member (i_account_group_id IN  NUMBER,
                             i_esn              IN  VARCHAR2,
                             i_sourcesystem     IN  VARCHAR2,
                             i_deactreason      IN  VARCHAR2,
                             i_userobjid        IN  VARCHAR2 DEFAULT NULL,
                             o_error_code       OUT NUMBER,
                             o_error_msg        OUT VARCHAR2);
--
--
--TW Web Common Standards
PROCEDURE get_discount_amount (i_account_group_id IN  NUMBER,
                               i_esn              IN  VARCHAR2,
                               i_enrolled_flag    IN  VARCHAR2,
                               i_brand            IN  VARCHAR2,
                               o_discount_amount  OUT NUMBER,
                               o_error_code       OUT NUMBER,
                               o_error_msg        OUT VARCHAR2);
--
--
PROCEDURE get_prg_enroll_objid (i_esn                IN  VARCHAR2,
                                i_prog_enroll_status IN  VARCHAR2 DEFAULT 'ENROLLED',
                                o_prog_enroll_tab    OUT esn_program_enroll_tab,
                                o_error_code         OUT NUMBER,
                                o_error_msg          OUT VARCHAR2);
--
--
END brand_x_pkg;
/