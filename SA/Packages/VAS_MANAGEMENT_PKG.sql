CREATE OR REPLACE PACKAGE sa."VAS_MANAGEMENT_PKG"
as
/***************************************************************************************************/
--$RCSfile: VAS_MANAGEMENT_PKG.sql,v $
--$Revision: 1.27 $
--$Author: sinturi $
--$Date: 2017/11/20 17:25:10 $
--$ $Log: VAS_MANAGEMENT_PKG.sql,v $
--$ Revision 1.27  2017/11/20 17:25:10  sinturi
--$ Added order type variable to update vas min proc
--$
--$ Revision 1.26  2017/11/02 21:28:34  smeganathan
--$ changes in deenroll vas to return payment source id
--$
--$ Revision 1.25  2017/10/30 22:00:47  smeganathan
--$ changes in update vas and subscribe vas
--$
--$ Revision 1.24  2017/10/26 22:18:31  smeganathan
--$ overloaded check claim device procedure
--$
--$ Revision 1.23  2017/10/23 18:44:03  smeganathan
--$ added procedure to update min and changes in subscribe vas
--$
--$ Revision 1.22  2017/10/20 14:26:36  smeganathan
--$ added new procedures for asurion
--$
--$ Revision 1.21  2017/10/11 17:32:23  smeganathan
--$ added new procedure transfer vas
--$
--$ Revision 1.20  2017/10/04 21:25:35  smeganathan
--$ added refund code
--$
--$ Revision 1.19  2017/10/04 21:20:50  smeganathan
--$ added refund code
--$
--$ Revision 1.18  2017/10/03 15:02:58  smeganathan
--$ added vas_final_cancellation and overloaded deenroll_vas_program
--$
--$ Revision 1.17  2017/09/28 21:46:43  smeganathan
--$ new procedures for VAS proration
--$
--$ Revision 1.16  2017/09/20 21:56:12  smeganathan
--$ New procedures for VAS Asurion project
--$
--$ Revision 1.15  2017/08/28 17:25:15  smeganathan
--$ Added new procedures for Asurion HPP
--$
--$ Revision 1.13  2017/01/04 19:48:48  rpednekar
--$ CR47191
--$
--$ Revision 1.12  2016/12/30 23:31:44  rpednekar
--$ CR47191 - New function GET_ILD_PURCHASE_COUNT added.
--$
--$ Revision 1.11  2016/06/08 17:10:05  skota
--$ Modiied the GETSERVICEFORPIN procedure
--$
--$ Revision 1.10  2013/08/22 16:25:30  akuthadi
--$ 2 new functions get_vas_service_id_by_pin, get_vas_service_param_val
--$
--$ Revision 1.9  2013/04/24 20:36:36  icanavan
--$ NEW PACKAGE
--$
--$ Revision 1.8  2013/04/24 15:51:40  icanavan

--$
/***************************************************************************************************/
  /*===============================================================================================*/
  /*                                                                                               */
  /* PURPOSE  : Package has been developed to manage VALUE ADDED SERVICES                          */
  /*                                                                                               */
  /* REVISION   DATE       WHO            PURPOSE                                                  */
  /* --------------------------------------------------------------------------------------------- */
  /* 1.0        03/28/2013  ICanavan     CR21443 Initial  Revision  */
  /* 1.1        04/20/2013  ICanavan     CR21443 more services      */
  /*===============================================================================================*/


PROCEDURE RecordSubscription (
-- *********************************************************
-- This service is called from SOA services to record the VAS transaction
-- *********************************************************
  ip_type          IN  VARCHAR2,
  ip_value         IN  VARCHAR2,
  ip_service_id    IN  VARCHAR2,
  op_result       OUT NUMBER,
  op_msg          OUT VARCHAR2 ) ;

PROCEDURE UpdateSubscriptionforMINC (
-- *********************************************************
-- This service is called from IGATE during a MINC transaction
-- will look for the min and deactivate the existing VAS and activate
-- again for the new min
-- *********************************************************

  ip_oldmin in varchar2, ip_newmin in varchar2,
  op_result out number, op_msg out varchar2 ) ;


PROCEDURE getServices (
-- *********************************************************
-- A basic service that returns available VAS services  from a VIEW created from
-- X_VAS_PROGRAMS, X_VAS_PARAMS,  and X_VAS_VALUES
-- Output:  List of VAS Service Objects filtered by BUSINESS from VAS_PROGRAMS_VIEW
-- *********************************************************
ip_bus_org  IN varchar2, -- BRAND required
Services    OUT sys_refcursor,
op_result   OUT number,
op_msg      OUT varchar2 ) ;

PROCEDURE    getAvailableServicesForPhone (
-- *********************************************************
-- This service returns a list of VAS services available to a phone model.
-- Short Desc:  Return all records from VAS_PROGRAMS_VIEW for selected handsets
-- Short Desc: (X_MTM_PROGRAM_HANDSET)
-- Output:  List of VAS Service Objects (same output as from getServices
-- *********************************************************
   ip_type          IN   VARCHAR2,
   ip_value         IN   VARCHAR2,
   ServicesforPhone OUT SYS_REFCURSOR,
   op_return_value  OUT NUMBER,
   op_return_string OUT VARCHAR2 ) ;

PROCEDURE    getEnrolledServicesForPhone (
-- *********************************************************
-- This service returns all active VAS services a phone is currently enrolled in.
-- Output:  List of VAS Service Objects (same output as from getServices
-- *********************************************************
ip_type                   in varchar2, -- valid objects are ESN, MIN, ACCOUNT
ip_value                  in varchar2, -- this is the object
EnrolledServicesForPhone  out sys_refcursor,
op_result                 out number,
op_msg                    out varchar2 ) ;

PROCEDURE    iseligibleForService (
-- *********************************************************
-- A service that returns "true" or "false" indicating whether or not a phone
-- is eligible for the specified VA service.  Service eligibility could be dependent
-- on many factors, like channel, product line, handset model, handset price,
-- handset age, service location, time, currently enrolled services, and other
-- bundled purchases.
-- Output:  is_eligible - boolean
-- *********************************************************
    ip_type          IN  VARCHAR2,
    ip_value         IN  VARCHAR2,
    ip_service_id    IN  VARCHAR2,
    op_is_eligible   OUT VARCHAR2, -- BOOLEAN,
    op_result        OUT NUMBER,
    op_msg           OUT VARCHAR2 ) ;

PROCEDURE    getTransactionHistoryForPhone (
-- *********************************************************
-- This service returns the VAS transation history of a handset
-- Output:  view
-- *********************************************************
ip_type                   in varchar2, -- valid objects are ESN, MIN, ACCOUNT
ip_value                  in varchar2, -- this is the object
TransactionHistoryForPhone  out sys_refcursor,
op_result                   out number,
op_msg                      out varchar2 ) ;

PROCEDURE    getCounterByEvent (
-- *********************************************************
-- This service returns the curent count of a specific event and account identifier
-- Output:  number
-- *********************************************************
ip_value                    in varchar2, -- this is the object
ip_event                    in varchar2,
op_counter                  out number,
op_result                   out number,
op_msg                      out varchar2 ) ;

PROCEDURE    IncrementCounterForEvent (
-- *********************************************************
-- This service increments the counter of a specific event and account identifier
-- Output:  NONE
-- *********************************************************
ip_value                    in varchar2, -- this is the object
ip_event                    in varchar2,
ip_step                     in number,
op_counter                  out number,
op_result                   out varchar2,
op_msg                      out varchar2 ) ;

PROCEDURE    getServiceforPIN (
-- *********************************************************
-- This service returns the service of the pin entered
-- Output:  service_id
-- *********************************************************

ip_PIN                      in varchar2, -- this is the pin
ip_esn                      in varchar2 default null,
op_service_id               out number,
op_result                   out varchar2,
op_msg                      out varchar2 ) ;

FUNCTION get_vas_service_id_by_pin(in_pin  IN  table_part_inst.x_red_code%TYPE) RETURN x_vas_programs.objid%TYPE;

FUNCTION get_vas_service_param_val(in_vas_id    IN x_vas_programs.objid%TYPE,
                                   in_vas_param IN x_vas_params.vas_param_name%TYPE) RETURN x_vas_values.vas_param_value%TYPE;

--CR47191
FUNCTION GET_ILD_PURCHASE_COUNT( ip_esn        VARCHAR2
                ,ip_min        VARCHAR2
                ,ip_days_period NUMBER DEFAULT 30
                )
RETURN NUMBER;


PROCEDURE   getAvailableServicesForPhone (
   ip_type          IN   VARCHAR2,
   ip_value         IN   VARCHAR2,
   ServicesforPhone OUT SYS_REFCURSOR,
   op_return_value  OUT NUMBER,
   op_return_string OUT VARCHAR2,
   ip_sourcesystem  IN    VARCHAR2
   );

--CR47191
--
-- CR49058 changes starts..
--
PROCEDURE p_get_program_parameter_id  ( i_vas_service_id      IN    NUMBER,
                                        i_auto_pay_flag       IN    VARCHAR2,
                                        o_program_id          OUT   NUMBER,
                                        o_error_code          OUT   VARCHAR2,
                                        o_error_msg           OUT   VARCHAR2
                                      );
--
-- New procedure to get proration applicable flag
PROCEDURE p_get_proration_flag  ( i_program_param_id            IN    VARCHAR2,
                                  o_proration_applicable_flag   OUT   VARCHAR2,
                                  o_error_code                  OUT   VARCHAR2,
                                  o_error_msg                   OUT   VARCHAR2);
--
-- New procedure to get collection of enrolled vas services and its details
PROCEDURE p_get_enrolled_vas_services ( i_esn                       IN  VARCHAR2,
                                        o_vas_program_details_tab   OUT vas_program_details_tab,
                                        o_error_code                OUT VARCHAR2,
                                        o_error_msg                 OUT VARCHAR2
                                      );
--
-- New Procedure to get list of eligbile as well as enrolled VAS services
PROCEDURE p_get_eligible_vas_services ( i_esn                     IN  VARCHAR2,
                                        i_min                     IN  VARCHAR2,
                                        i_bus_org                 IN  VARCHAR2,
                                        i_ecommerce_orderid       IN  VARCHAR2,
                                        i_phone_make              IN  VARCHAR2,
                                        i_phone_model             IN  VARCHAR2,
                                        i_phone_price             IN  NUMBER,
                                        i_activation_zipcode      IN  VARCHAR2,
                                        i_is_byod                 IN  VARCHAR2,
                                        i_enrolled_only           IN  VARCHAR2 DEFAULT 'N',
                                        i_to_esn                  IN  VARCHAR2,
                                        i_process_flow            IN  VARCHAR2 DEFAULT NULL,
                                        o_vas_program_details_tab OUT vas_program_details_tab,
                                        o_error_code              OUT VARCHAR2,
                                        o_error_msg               OUT VARCHAR2
                                      );
--
PROCEDURE p_subscribe_vas  (  i_esn                 IN      VARCHAR2,
                              i_min                 IN      VARCHAR2,
                              i_order_id            IN      VARCHAR2,
                              i_phone_make          IN      VARCHAR2,
                              i_phone_model         IN      VARCHAR2,
                              i_phone_price         IN      NUMBER,
                              i_activation_zipcode  IN      VARCHAR2,
                              i_email_address       IN      VARCHAR2,
                              i_device_price_tier   IN      VARCHAR2,
                              io_programs           IN OUT  subscribe_vas_programs_tab,
                              o_error_code          OUT     VARCHAR2,
                              o_error_msg           OUT     VARCHAR2
                           );
--
PROCEDURE p_get_vas_subscription_info  (  i_esn                 IN    VARCHAR2,
                                          i_min                 IN    VARCHAR2,
                                          i_vendor_contract_id  IN    VARCHAR2,
                                          i_vas_subscription_id IN    VARCHAR2,
                                          o_vas_status          OUT   VARCHAR2,
                                          o_vas_start_date      OUT   DATE,
                                          o_vas_expiry_date     OUT   DATE,
                                          o_site_part_status    OUT   VARCHAR2,
                                          o_error_code          OUT   VARCHAR2,
                                          o_error_msg           OUT   VARCHAR2
                                        );
--
PROCEDURE p_update_vas_enrollment ( i_esn                   IN    VARCHAR2,
                                    i_min                   IN    VARCHAR2,
                                    i_vas_subscription_id   IN    VARCHAR2,
                                    i_program_enroll_id     IN    VARCHAR2,
                                    i_program_param_id      IN    VARCHAR2,
                                    i_status                IN    VARCHAR2,
                                    i_vas_expiry_date       IN    DATE,
                                    o_error_code            OUT   VARCHAR2,
                                    o_error_msg             OUT   VARCHAR2);
--
PROCEDURE p_update_vas_subscription  ( i_esn                IN    VARCHAR2,
                                       i_program_enroll_id  IN    VARCHAR2);
--
PROCEDURE p_update_vas_min  ( i_esn           IN    VARCHAR2,
                              i_min           IN    VARCHAR2,
                              i_order_type    IN    VARCHAR2 DEFAULT NULL,
                              o_error_code    OUT   VARCHAR2,
                              o_error_msg     OUT   VARCHAR2
                            );
--
PROCEDURE p_update_vas_contract_id  ( i_esn                 IN    VARCHAR2,
                                      i_vas_subscription_id IN    VARCHAR2,
                                      i_contract_id         IN    VARCHAR2,
                                      o_error_code          OUT   VARCHAR2,
                                      o_error_msg           OUT   VARCHAR2);
--
PROCEDURE p_check_claim_device  ( i_esn               IN    VARCHAR2,
                                  i_sim               IN    VARCHAR2,
                                  i_is_byod           IN    VARCHAR2 DEFAULT 'N',
                                  o_claim_device_flag OUT   VARCHAR2,
                                  o_old_esn           OUT   VARCHAR2,
                                  o_min               OUT   VARCHAR2,
                                  o_error_code        OUT   VARCHAR2,
                                  o_error_msg         OUT   VARCHAR2
                                );
--
PROCEDURE p_check_claim_device  ( i_old_esn           IN    VARCHAR2,
                                  i_new_esn           IN    VARCHAR2,
                                  o_claim_device_flag OUT   VARCHAR2,
                                  o_error_code        OUT   VARCHAR2,
                                  o_error_msg         OUT   VARCHAR2
                                );
--
PROCEDURE p_calculate_prorated_amount ( i_total_amount            IN    NUMBER,
                                        i_tax_amount              IN    NUMBER,
                                        i_e911_amount             IN    NUMBER,
                                        i_usf_taxamount           IN    NUMBER,
                                        i_rcrf_tax_amount         IN    NUMBER,
                                        i_actual_service_days     IN    NUMBER,
                                        i_remaining_service_days  IN    NUMBER,
                                        o_total_refund_amount     OUT   NUMBER,
                                        o_tax_refund_amount       OUT   NUMBER,
                                        o_e911_refund_amount      OUT   NUMBER,
                                        o_usf_refund_amount       OUT   NUMBER,
                                        o_rcrf_refund_amount      OUT   NUMBER,
                                        o_error_code              OUT   VARCHAR2,
                                        o_error_msg               OUT   VARCHAR2
                                      );
--
PROCEDURE p_calculate_vas_refund  ( i_esn                     IN      VARCHAR2,
                                    i_vas_service_id          IN      VARCHAR2,
                                    i_vas_subscription_id     IN      VARCHAR2,
                                    i_program_id              IN      VARCHAR2,
                                    i_cancel_effective_date   IN      DATE,
                                    o_total_refund_amount     OUT     NUMBER,
                                    o_tax_refund_amount       OUT     NUMBER,
                                    o_e911_refund_amount      OUT     NUMBER,
                                    o_usf_refund_amount       OUT     NUMBER,
                                    o_rcrf_refund_amount      OUT     NUMBER,
                                    o_error_code              OUT     VARCHAR2,
                                    o_error_msg               OUT     VARCHAR2
                                  );
--
PROCEDURE p_transfer_vas    ( i_from_esn              IN      VARCHAR2,
                              i_to_esn                IN      VARCHAR2,
                              io_subscription_id_tab  IN OUT  vas_subscriptions_id_tab,
                              o_error_code            OUT     VARCHAR2,
                              o_error_msg             OUT     VARCHAR2
                            );
--
PROCEDURE p_deenroll_vas_program  ( i_esn                     IN    VARCHAR2,
                                    i_program_id              IN    NUMBER,
                                    i_vas_service_id          IN    NUMBER,
                                    i_status                  IN    VARCHAR2,
                                    i_reason                  IN    VARCHAR2,
                                    i_refund_complete_flag    IN    VARCHAR2,
                                    o_error_code              OUT   VARCHAR2,
                                    o_error_msg               OUT   VARCHAR2
                                  );
--
PROCEDURE p_deenroll_vas_program (  i_esn                 IN    VARCHAR2,
                                    i_deenroll_reason     IN    VARCHAR2,
                                    o_error_code          OUT   VARCHAR2,
                                    o_error_msg           OUT   VARCHAR2
                                 );
--
PROCEDURE p_deenroll_vas_program  ( i_esn                     IN    VARCHAR2,
                                    i_program_id              IN    NUMBER,
                                    i_vas_subscription_id     IN    NUMBER,
                                    i_status                  IN    VARCHAR2,
                                    i_reason                  IN    VARCHAR2,
                                    o_expiry_date             OUT   DATE,
                                    o_contact_objid           OUT   NUMBER,
                                    o_web_user_objid          OUT   NUMBER,
                                    o_program_purch_hdr_objid OUT   NUMBER,
                                    o_payment_source_id       OUT   NUMBER,
                                    o_x_purch_hdr_objid       OUT   NUMBER,
                                    o_error_code              OUT   VARCHAR2,
                                    o_error_msg               OUT   VARCHAR2
                                  );
--
PROCEDURE p_update_vas_subscription  (  i_vas_subscription_id   IN    NUMBER,
                                        o_error_code            OUT   VARCHAR2,
                                        o_error_msg             OUT   VARCHAR2);
--
PROCEDURE p_vas_final_cancellation  ( i_run_date    IN  DATE DEFAULT SYSDATE,
                                      o_error_code  OUT VARCHAR2,
                                      o_error_msg   OUT VARCHAR2);
--
END VAS_MANAGEMENT_PKG;
/