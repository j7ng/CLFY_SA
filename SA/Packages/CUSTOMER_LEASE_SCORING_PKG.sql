CREATE OR REPLACE PACKAGE sa.customer_lease_scoring_pkg AS
 /******************************************************************************/
 /* Copyright 2002 Tracfone Wireless Inc. All rights reserved */
 /*
 * --$RCSfile: CUSTOMER_LEASE_SCORING_PKG.sql,v $
  --$Revision: 1.21 $
  --$Author: skambhammettu $
  --$Date: 2018/03/01 19:13:31 $
  --$ $Log: CUSTOMER_LEASE_SCORING_PKG.sql,v $
  --$ Revision 1.21  2018/03/01 19:13:31  skambhammettu
  --$ Change in get_group_summary
  --$
  --$ Revision 1.19  2017/06/16 21:26:11  nmuthukkaruppan
  --$ CR50154  - ST LTO - Update with Sub release Tag.
  --$
  --$ Revision 1.18  2017/05/19 19:11:54  nmuthukkaruppan
  --$ CR50154 - Added Comments
  --$
  --$ Revision 1.17  2017/04/25 16:04:41  nmuthukkaruppan
  --$ CR50154 - Added new input Lease_Scope to show the scope of the lease in TAS
  --$
  --$ Revision 1.16  2017/04/11 21:54:52  smeganathan
  --$ removed get_full_account_summary overloaded procedure
  --$
  --$ Revision 1.15  2017/04/11 19:07:45  sgangineni
  --$ CR48944 - Changes by Sabu
  --$
  --$ Revision 1.14  2017/01/24 20:29:42  smeganathan
  --$ CR47564 Merged with 1/23 prod release
  --$
  --$ Revision 1.12  2016/11/15 19:25:58  vyegnamurthy
  --$ CR46039
  --$
  --$ Revision 1.12  2016/11/10 23:05:57  SMEGANATHAN
  --$ CR46039 - New proc p_get_info_for_pin added
  /* NAME: SA.CUSTOMER_LEASE_SCORING_PKG */
  /* PURPOSE:      CUSTOMER_LEASE_SCORING_PKG -CR37233                          */
  /* FREQUENCY:                                                                 */
  /* PLATFORMS:    Oracle 11g AND newer versions.                               */
  /*                                                                            */
  /* REVISIONS:                                                                 */
  /* VERSION   DATE        WHO          PURPOSE                                 */
  /* -------   ---------- ---------     ----------------------------------------*/
  /*  1.0      09/22/2015 Veda          Initial  Revision                       */
  /*  1.1      11/22/2015 SEMGANATHAN / Changes for Total Wireless Plus CR39389 */
  /*                      JPENA                                                 */
  /******************************************************************************/
--
-- Procedure to update the group id called by SOA
PROCEDURE update_lease_group_id ( i_application_req_num IN  VARCHAR2 ,
                                  i_account_group_id    IN  NUMBER   ,
                                  o_error_code          OUT NUMBER   ,
                                  o_error_msg           OUT VARCHAR2 );

PROCEDURE p_update_esn_lease_status ( in_esn                 IN  VARCHAR2,
                                      in_application_req_num IN  VARCHAR2,
                                      in_lease_status        IN  VARCHAR2,
                                      in_brand               IN  VARCHAR2,
                                      in_client_id           IN  VARCHAR2,
                                      in_smp                 IN  VARCHAR2 DEFAULT NULL, -- new parameter for TW+ CR39389
                                      in_account_group_id    IN  NUMBER DEFAULT NULL,   -- new parameter for TW+ CR39389
									  in_merchant_id         IN  VARCHAR2 DEFAULT NULL, --CR41570 Dollar General
                                      out_error_code         OUT NUMBER,
                                      out_error_msg          OUT VARCHAR2,
                                      in_lease_scope         IN  VARCHAR2 DEFAULT NULL);  --CR50154 ST LTO

PROCEDURE p_get_time_as_cust_score ( io_application_req_num   IN OUT VARCHAR2,
                                     io_min                   IN OUT VARCHAR2,
                                     in_first_name            IN     VARCHAR2,
                                     in_email_id              IN     VARCHAR2,
                                     in_client_id             IN     VARCHAR2,
                                     out_trans_date           OUT    VARCHAR2,
                                     out_score_code           OUT    VARCHAR2,
                                     out_transaction_id       OUT    VARCHAR2,
                                     out_error_code           OUT    NUMBER,
                                     out_error_msg            OUT    VARCHAR2 );
--
--
PROCEDURE p_group_esn_details ( i_application_req_num   IN      VARCHAR2,
                                o_application_req_num   OUT     VARCHAR2, -- As requested by Service team
                                o_number_of_lines       OUT     VARCHAR2,
                                o_available_lines       OUT     VARCHAR2,
                                o_service_plan_id       OUT     VARCHAR2,
                                o_red_card_code         OUT     VARCHAR2,
                                o_group_id              OUT     VARCHAR2,
                                o_refcursor             OUT     SYS_REFCURSOR ,
                                o_err_code              OUT     NUMBER ,
                                o_err_msg               OUT     VARCHAR2 );
--
-- CR39389 Changes Starts.
-- Procedure which accepts esn and call the overloaded function with application req num
PROCEDURE p_group_esn_details ( i_esn                   IN      VARCHAR2,
                                o_application_req_num   OUT     VARCHAR2,
                                o_number_of_lines       OUT     VARCHAR2,
                                o_available_lines       OUT     VARCHAR2,
                                o_service_plan_id       OUT     VARCHAR2,
                                o_red_card_code         OUT     VARCHAR2,
                                o_group_id              OUT     VARCHAR2,
                                o_refcursor             OUT     SYS_REFCURSOR ,
                                o_err_code              OUT     NUMBER ,
                                o_err_msg               OUT     VARCHAR2 );
-- Procedure which accepts PIN and call the overloaded function with application req num
PROCEDURE p_group_esn_details ( i_red_card_code         IN      VARCHAR2,
                                o_application_req_num   OUT     VARCHAR2,
                                o_number_of_lines       OUT     VARCHAR2,
                                o_available_lines       OUT     VARCHAR2,
                                o_service_plan_id       OUT     VARCHAR2,
                                o_red_card_code         OUT     VARCHAR2,
                                o_group_id              OUT     VARCHAR2,
                                o_refcursor             OUT     SYS_REFCURSOR ,
                                o_err_code              OUT     NUMBER ,
                                o_err_msg               OUT     VARCHAR2 );
--
-- Procedure which accepts group ID and call the overloaded function with application req num
PROCEDURE p_group_esn_details ( i_group_id              IN      VARCHAR2,
                                o_application_req_num   OUT     VARCHAR2,
                                o_number_of_lines       OUT     VARCHAR2,
                                o_available_lines       OUT     VARCHAR2,
                                o_service_plan_id       OUT     VARCHAR2,
                                o_red_card_code         OUT     VARCHAR2,
                                o_group_id              OUT     VARCHAR2,
                                o_refcursor             OUT     SYS_REFCURSOR ,
                                o_err_code              OUT     NUMBER ,
                                o_err_msg               OUT     VARCHAR2 );
-- Procedure which accepts MIN and call the overloaded function with esn
PROCEDURE p_group_esn_details ( i_min                   IN      VARCHAR2,
                                o_application_req_num   OUT     VARCHAR2,
                                o_number_of_lines       OUT     VARCHAR2,
                                o_available_lines       OUT     VARCHAR2,
                                o_service_plan_id       OUT     VARCHAR2,
                                o_red_card_code         OUT     VARCHAR2,
                                o_group_id              OUT     VARCHAR2,
                                o_refcursor             OUT     SYS_REFCURSOR ,
                                o_err_code              OUT     NUMBER ,
                                o_err_msg               OUT     VARCHAR2 );
--
PROCEDURE getaccountsummary ( i_esn                   IN  VARCHAR2,
                              i_security_pin          IN  VARCHAR2,
                              o_application_req_num   OUT VARCHAR2,
                              o_number_of_lines       OUT NUMBER,
                              o_available_lines       OUT NUMBER,
                              o_service_plan_id       OUT VARCHAR2,
                              o_service_plan_name     OUT VARCHAR2,
                              o_group_id              OUT NUMBER,
                              o_group_name            OUT VARCHAR2,
                              o_red_card_code         OUT VARCHAR2,
                              o_brand                 OUT VARCHAR2,
                              o_first_name            OUT VARCHAR2,
                              o_last_name             OUT VARCHAR2,
                              o_login_name            OUT VARCHAR2,
                              o_refcursor             OUT SYS_REFCURSOR ,
                              o_err_code              OUT NUMBER ,
                              o_err_msg               OUT VARCHAR2 );
--
-- Get the entire list of ESNs tied to a min (account)
PROCEDURE getfullaccountsummary ( i_esn                 IN  VARCHAR2,
                                  i_security_pin        IN  VARCHAR2,
                                  i_bus_org_id          IN  VARCHAR2,
                                  o_application_req_num OUT VARCHAR2,
                                  o_number_of_lines     OUT NUMBER,
                                  o_available_lines     OUT NUMBER,
                                  o_service_plan_id     OUT VARCHAR2,
                                  o_service_plan_name   OUT VARCHAR2,
                                  o_group_id            OUT NUMBER,
                                  o_group_name          OUT VARCHAR2,
                                  o_red_card_code       OUT VARCHAR2,
                                  o_brand               OUT VARCHAR2,
                                  o_first_name          OUT VARCHAR2,
                                  o_last_name           OUT VARCHAR2,
                                  o_login_name          OUT VARCHAR2,
                                  o_refcursor           OUT SYS_REFCURSOR ,
                                  o_err_code            OUT NUMBER ,
                                  o_err_msg             OUT VARCHAR2 );
--
-- Overloaded procedure to get the entire list of ESNs tied to a web login name (email id)
PROCEDURE getfullaccountsummary ( i_login_name          IN  VARCHAR2,
                                  i_security_pin        IN  VARCHAR2,
                                  i_bus_org_id          IN  VARCHAR2,
                                  o_application_req_num OUT VARCHAR2,
                                  o_number_of_lines     OUT NUMBER,
                                  o_available_lines     OUT NUMBER,
                                  o_service_plan_id     OUT VARCHAR2,
                                  o_service_plan_name   OUT VARCHAR2,
                                  o_group_id            OUT NUMBER,
                                  o_group_name          OUT VARCHAR2,
                                  o_red_card_code       OUT VARCHAR2,
                                  o_brand               OUT VARCHAR2,
                                  o_first_name          OUT VARCHAR2,
                                  o_last_name           OUT VARCHAR2,
                                  o_login_name          OUT VARCHAR2,
                                  o_refcursor           OUT SYS_REFCURSOR ,
                                  o_err_code            OUT NUMBER ,
                                  o_err_msg             OUT VARCHAR2 );
-- Overloaded procedure to get the entire list of ESNs tied to a web login name (email id)
PROCEDURE getfullaccountsummary ( i_login_name          IN  VARCHAR2,
                                  i_bus_org_id          IN  VARCHAR2,
                                  o_application_req_num OUT VARCHAR2,
                                  o_number_of_lines     OUT NUMBER,
                                  o_available_lines     OUT NUMBER,
                                  o_service_plan_id     OUT VARCHAR2,
                                  o_service_plan_name   OUT VARCHAR2,
                                  o_group_id            OUT NUMBER,
                                  o_group_name          OUT VARCHAR2,
                                  o_red_card_code       OUT VARCHAR2,
                                  o_brand               OUT VARCHAR2,
                                  o_first_name          OUT VARCHAR2,
                                  o_last_name           OUT VARCHAR2,
                                  o_login_name          OUT VARCHAR2,
                                  o_refcursor           OUT SYS_REFCURSOR ,
                                  o_err_code            OUT NUMBER ,
                                  o_err_msg             OUT VARCHAR2 );
--
-- Procedure to get all the groups related to the web login id. As requested by CBO
--
PROCEDURE get_full_account_summary  ( i_login_name            IN  VARCHAR2,
                                      i_web_user_id           IN  VARCHAR2,
                                      i_group_id              IN  VARCHAR2,
                                      i_bus_org               IN  VARCHAR2,
                                      i_language  IN VARCHAR2 DEFAULT 'ENGLISH',
                                      o_refcursor             OUT SYS_REFCURSOR,
                                      o_error_code            OUT VARCHAR2,
                                      o_error_msg             OUT VARCHAR2);
--
-- Overloading the procedure for WFM CR47564
--
PROCEDURE get_full_account_summary  ( i_login_name            IN  VARCHAR2,
                                      i_web_user_id           IN  VARCHAR2,
                                      i_group_id              IN  VARCHAR2,
                                      i_bus_org               IN  VARCHAR2,
                                      i_esn                   IN  VARCHAR2,
                                      i_min                   IN  VARCHAR2,
                                      i_language  IN VARCHAR2 DEFAULT 'ENGLISH',
                                      o_refcursor             OUT SYS_REFCURSOR,
                                      o_error_code            OUT VARCHAR2,
                                      o_error_msg             OUT VARCHAR2);
--
--
-- Procedure to get all the ESNs related to the group id. As requested by CBO
--
PROCEDURE get_group_summary  ( i_group_id              IN  VARCHAR2,
                               i_bus_org               IN  VARCHAR2,
                               i_language  IN VARCHAR2 DEFAULT 'ENGLISH',
                               o_refcursor             OUT SYS_REFCURSOR,
                               o_error_code            OUT VARCHAR2,
                               o_error_msg             OUT VARCHAR2);
--
PROCEDURE get_credit_refund ( i_account_group_id     IN NUMBER    ,
                              i_new_service_plan_id  IN NUMBER    ,
                              i_start_date           IN DATE      ,
                              o_credit_refund_amount OUT NUMBER   ,
                              o_error_code           OUT NUMBER   ,
                              o_response             OUT VARCHAR2 );
--
PROCEDURE get_data_usage_level ( i_min          IN  VARCHAR2  ,
                                 i_data_usage   IN  NUMBER    , -- expressed in MB
                                 o_usage_level  OUT VARCHAR2  ,
                                 o_error_code   OUT NUMBER    ,
                                 o_response     OUT VARCHAR2  );
--
-- Determine when an ESN is leased or not
PROCEDURE get_esn_leased_flag ( i_esn          IN  VARCHAR2 ,
                                o_leased_flag  OUT VARCHAR2 );
--
-- Get the application_id for the lease
FUNCTION get_application_id ( i_account_group_id IN NUMBER   ,
                              i_red_card_code    IN VARCHAR2 ,
                              i_esn              IN VARCHAR2 ) RETURN VARCHAR2;
--
-- Procedure used to update an esn part inst to Risk Assessment
PROCEDURE set_status_risk_assessment ( i_esn          IN    VARCHAR2  ,
                                       i_user_objid   IN    VARCHAR2  ,
                                       o_message      OUT   VARCHAR2  );
--
-- Procedure to validate the upgrade
PROCEDURE validate_upgrade ( i_from_esn          IN    VARCHAR2  ,
                             i_to_esn            IN    VARCHAR2  ,
                             o_err_code          OUT   VARCHAR2  ,
                             o_err_msg           OUT   VARCHAR2  );
-- CR39389 Changes Ends.
-- CR31456 WARP changes
-- procedure used to validate if an esn and login name are under the same web account
PROCEDURE esn_email_validation ( i_from_esn    IN  VARCHAR2 ,
                                 i_to_esn      IN  VARCHAR2 ,
                                 i_login_name  IN  VARCHAR2 ,
                                 o_error_code  OUT NUMBER   ,
                                 o_error_msg   OUT VARCHAR2 );
--
-- CR46039 changes added the below procedure
PROCEDURE p_get_info_for_pin ( i_red_card         IN    table_x_red_card.x_red_code%TYPE,
                               o_is_redeemed      OUT   VARCHAR2,
                               o_is_reserved      OUT   VARCHAR2,
                               o_redeem_date      OUT   DATE,
                               o_associated_esn   OUT   table_part_inst.part_serial_no%TYPE,
                               o_associated_min   OUT   table_part_inst.part_serial_no%TYPE,
                               o_err_code         OUT   VARCHAR2,
                               o_err_msg          OUT   VARCHAR2);
END customer_lease_scoring_pkg;
-- ANTHILL_TEST PLSQL/SA/Packages/CUSTOMER_LEASE_SCORING_PKG.sql 	CR55236: 1.21
/