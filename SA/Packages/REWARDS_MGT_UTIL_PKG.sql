CREATE OR REPLACE PACKAGE sa.rewards_mgt_util_pkg
AS
 --$RCSfile: REWARDS_MGT_UTIL_PKG.sql,v $
 --$Revision: 1.44 $
 --$Author: abustos $
 --$Date: 2018/04/02 19:41:49 $
 --$ $Log: REWARDS_MGT_UTIL_PKG.sql,v $
 --$ Revision 1.44  2018/04/02 19:41:49  abustos
 --$ CR55200 - Change signature of proc p_reward_request_processing
 --$
 --$ Revision 1.43  2018/03/30 20:57:18  abustos
 --$ CR55200 - Correct Syntax
 --$
 --$ Revision 1.42  2018/03/30 20:52:38  abustos
 --$ CR55200 - New input parameter i_web_account_id for p_reward_request_processing
 --$
 --$ Revision 1.41  2018/03/12 22:05:10  rmorthala
 --$ Added new procedure p_reward_request_processing
 --$
 --$ Revision 1.39  2017/12/12 17:09:37  rmorthala
 --$ *** empty log message ***
 --$
 --$ Revision 1.33  2016/09/16 12:49:27  sethiraj
 --$ CR41473-LRP2-Added Modification History Template
 --$
 --$ Revision 1.32  2016/09/06 17:50:21  pamistry
 --$ CR41473 - LRP2 Added new column Opt IN / OUT functionality for Email and SMS
 --$


--------------------------------------------------------------------------------------------
-- Author: snulu (Sujatha Nulu)
-- Date: 2015/10/01
-- <CR# 33098>
-- Loyalty Rewards Program is to build a capability to give rewards for certain customer Actions
-- and increase the Life Time value of the customer.
-- This program is precisely targeting the customers who fall under the umbrella of Straight Talk.
--------------------------------------------------------------------------------------------

 PROCEDURE p_customer_is_enrolled
        ( in_cust_key             IN VARCHAR2,
          in_cust_value           IN VARCHAR2,
          in_program_name         IN VARCHAR2,
          in_enrollment_type      IN VARCHAR2,
          in_brand                IN VARCHAR2,
          out_enrollment_status   OUT VARCHAR2,
          out_enrollment_elig_status  OUT VARCHAR2, --Modified for 2269
          out_err_code            OUT NUMBER,
          out_err_msg             OUT VARCHAR2
        );

 PROCEDURE p_customer_in_promo_group
        ( in_cust_key              IN VARCHAR2,
          in_cust_value           IN VARCHAR2,
          in_program_name         IN VARCHAR2,
          in_benefit_type_code    IN VARCHAR2,
          in_promo_group          IN VARCHAR2,
          in_brand                IN VARCHAR2,
          out_promotional_flag    OUT VARCHAR2,
          out_err_code            OUT NUMBER,
          out_err_msg             OUT VARCHAR2
        );
--CR42428
 PROCEDURE p_customer_in_promo_group
        ( in_cust_key              IN VARCHAR2,
          in_cust_value           IN VARCHAR2,
          in_program_name         IN VARCHAR2,
          in_benefit_type_code    IN VARCHAR2,
          in_brand                IN VARCHAR2,
          out_promotional_flag    OUT VARCHAR2,
          out_err_code            OUT NUMBER,
          out_err_msg             OUT VARCHAR2
        );

  PROCEDURE P_ENROLL_CUST_IN_PROGRAM
         (
          IN_CUST_KEY        IN VARCHAR2,
          IN_CUST_VALUE      IN VARCHAR2,
          IN_BRAND           in varchar2
         ,X_SUBSCRIBER_ID    in varchar2
         ,X_MIN              in varchar2
         ,X_ESN              in varchar2
         ,IN_PROGRAM_NAME    in varchar2
         ,in_benefit_type    in varchar2
         ,IN_ENROLLMENT_TYPE in varchar2
         ,IN_ENROLL_CHANNEL  IN VARCHAR2   -- CR41665 added
         ,IN_ENROLL_MIN      IN VARCHAR2   -- CR41665 added
         ,out_err_code       out number
         ,out_err_msg        out varchar2);


  --CR55200
  --Procedure is to provide the rewrad points for past 30days transactions after enrollment in LRP.
  PROCEDURE p_reward_request_processing (i_web_account_id IN  VARCHAR2,
                                         out_err_code     OUT NUMBER,
                                         out_err_msg      OUT VARCHAR2
                                        );

 PROCEDURE p_enroll_cust_in_program
        ( in_brand          IN VARCHAR2
         ,in_web_account_id  IN VARCHAR2
         ,x_subscriber_id    IN VARCHAR2
         ,x_min              IN VARCHAR2
         ,x_esn              IN VARCHAR2
         ,in_program_name    IN VARCHAR2
         ,in_benefit_type    IN VARCHAR2
         ,in_enrollment_type IN VARCHAR2
         ,in_enroll_channel  IN VARCHAR2  -- CR41665 added
         ,in_enroll_min      IN VARCHAR2  -- CR41665 added
         ,out_err_code       OUT NUMBER
         ,out_err_msg        OUT VARCHAR2
        );

 PROCEDURE p_enroll_cust_in_program
        ( in_brand          IN VARCHAR2
         ,in_web_account_id  IN VARCHAR2
         ,x_subscriber_id    IN VARCHAR2
         ,x_min              IN VARCHAR2
         ,x_esn              IN VARCHAR2
         ,in_program_name    IN VARCHAR2
         ,in_benefit_type    IN VARCHAR2
         ,in_enrollment_type IN VARCHAR2
         ,in_source_system   IN VARCHAR2
         ,out_err_code       OUT NUMBER
         ,out_err_msg        OUT VARCHAR2
        );

 PROCEDURE p_deenroll_cust_from_program
        ( in_key               IN VARCHAR2
         ,in_value              IN VARCHAR2
         ,in_program_name       IN VARCHAR2
         ,in_benefit_type       IN VARCHAR2
         ,in_enrollment_type    IN VARCHAR2
         ,in_brand              IN VARCHAR2
         ,out_err_code          OUT NUMBER
         ,out_err_msg           OUT VARCHAR2
         );
-- this procedure is for non loyalty program enrollment.
  PROCEDURE p_deenroll_esn_from_program(
            in_brand           IN VARCHAR2 ,
            in_web_account_id  IN VARCHAR2 ,
            x_subscriber_id    IN VARCHAR2 ,
            x_min              IN VARCHAR2 ,
            x_esn              IN VARCHAR2 ,
            in_program_name    IN VARCHAR2 ,
            in_benefit_type    IN VARCHAR2 ,
            in_enrollment_type IN VARCHAR2 ,
            out_err_code       OUT NUMBER ,
            out_err_msg        OUT VARCHAR2);
--
 PROCEDURE p_get_benefit_program_info
        ( in_program_name             IN VARCHAR2,
          in_benefit_type_code        IN VARCHAR2,
          in_brand                    IN VARCHAR2,
          out_benefit_info_list       OUT benefits_info_tab,
          out_err_code                OUT NUMBER,
          out_err_msg                 OUT VARCHAR2
          );

 FUNCTION f_create_btrans_from_event
         (
           in_event IN q_payload_t
         )
 RETURN typ_lrp_benefit_trans;

FUNCTION f_get_svc_plan_benefits(
    in_svc_plan_id       IN VARCHAR2,
    in_program_name      IN x_reward_benefit_program.program_name%TYPE,
    in_benefit_type_code IN x_reward_benefit_program.benefit_type_code%TYPE,
    in_brand             IN x_reward_benefit_program.brand%TYPE,
    in_autorefill_flag   IN VARCHAR2    ) --Modified for CR41661
 RETURN NUMBER;

 FUNCTION f_benefits_prev_awarded(
            in_web_account_id    IN VARCHAR2,
            in_esn               IN VARCHAR2,
            in_program_name      IN VARCHAR2,
            in_trans_type        IN VARCHAR2,
            in_benefit_type_code IN VARCHAR2,
            in_brand             IN VARCHAR2,
            in_svc_plan_id       IN VARCHAR2,
            in_svc_plan_pin      IN VARCHAR2 )
  RETURN BOOLEAN;

  PROCEDURE p_create_benefit_trans(
            ben_trans                   IN typ_lrp_benefit_trans,
            reward_benefit_trans_objid  OUT x_reward_benefit_transaction.objid%TYPE,
            o_transaction_status   out x_reward_benefit_transaction.transaction_status%type);        -- CR41473 08/03/2016 PMistry LRP2 Added new output parameter to return the transaction status.

  FUNCTION f_get_enrollment_benefits
    (
      in_program_name    IN VARCHAR2,
      in_benefit_type    IN VARCHAR2,
      in_enrollment_type IN VARCHAR2
    )
   RETURN NUMBER;

  FUNCTION f_get_cust_benefit_id(
           in_cust_key     IN VARCHAR2,
           in_cust_value   IN VARCHAR2,
           in_program_name IN VARCHAR2,
           in_benefit_type IN VARCHAR2,
           in_brand        IN varchar2 default 'STRAIGHT_TALK')     -- CR41473 Added new parameter to remove hard coded value for STRAIGHT_TALK.
   RETURN NUMBER;

   PROCEDURE p_update_benefit(
      in_cust_key        IN VARCHAR2, -- {OBJECT, ESN, SID, ACCOUNT, MIN}
      in_cust_value      IN VARCHAR2,
      in_program_name    IN VARCHAR2,
      in_benefit_type    IN VARCHAR2,
      in_brand           IN VARCHAR2,
      in_new_min         IN VARCHAR2,
      in_new_esn         IN VARCHAR2,
      in_new_status      IN VARCHAR2, --{AVAILABLE, UNAVAILABLE, USED, CANCELLED, EXPIRED}
      in_new_notes       IN VARCHAR2,
      in_new_expiry_date IN DATE,
      in_change_quantity IN NUMBER, -- this is delta change to make, plus or minus
      in_transaction_status IN VARCHAR2 DEFAULT 'COMPLETE', -- CR41473 - LRP2 - sethriaj
      in_value           IN NUMBER DEFAULT NULL, -- CR41473 - LRP2 - sethriaj
      in_account_status  IN VARCHAR2); --Modified for defect 2269)

  FUNCTION f_create_ben_from_event
         (
           in_event IN q_payload_t
         )
    RETURN typ_lrp_reward_benefit;

  PROCEDURE p_create_benefit(
            benefit               IN typ_lrp_reward_benefit,
    reward_benefit_objid  OUT x_reward_benefit.objid%TYPE );


   PROCEDURE p_compensate_reward_points
          ( btrans            IN OUT typ_lrp_benefit_trans,
            benefit           IN OUT typ_lrp_reward_benefit,
            out_error_num     OUT NUMBER,
            out_error_message OUT VARCHAR2
          );
 -- TAS calls this
  PROCEDURE p_compensate_reward_points
            ( in_source_system        IN VARCHAR2,
              in_program_name         IN x_reward_benefit_program.program_name%TYPE,
              in_brand                IN x_reward_benefit_program.brand%TYPE,
              in_web_account_id       IN x_reward_program_enrollment.web_account_id%TYPE,
              in_min                  IN x_reward_program_enrollment.MIN%TYPE,
              in_esn                  IN x_reward_program_enrollment.esn%TYPE,
              in_action               IN x_reward_benefit_transaction.action%TYPE,
              in_amount               IN x_reward_benefit_transaction.amount%TYPE,
              in_benefit_type_code    IN x_reward_benefit_program.benefit_type_code%TYPE,
              in_action_reason        IN x_reward_benefit_transaction.action_reason%TYPE,
              in_action_notes         in x_reward_benefit_transaction.action_notes%TYPE,
        in_agent_login_name   IN x_reward_benefit_transaction.agent_login_name%TYPE,
              out_error_num     out NUMBER,
              out_error_message out VARCHAR2
            );
   PROCEDURE p_get_corp_card_info
      ( in_esn   IN VARCHAR2,
        in_brand IN VARCHAR2,
        o_corp_status OUT VARCHAR2,
        o_err_code OUT NUMBER,
        o_err_msg OUT VARCHAR2);


procedure p_update_benefit_status (
                i_esn               IN   VARCHAR2,
                i_new_status        IN   VARCHAR2,
                i_brand             IN   VARCHAR2,
                I_Program_Name      IN   VARCHAR2, -- 'LOYALTY_PROGRAM'
                I_Benefit_Type      IN   VARCHAR2, --'LOYALTY_POINTS'
                o_err_code         OUT  NUMBER,
                o_err_msg          OUT  VARCHAR2);



 PROCEDURE p_event_processing
        ( in_event                IN OUT q_payload_t,
          out_err_code            OUT NUMBER,
          out_err_msg             OUT VARCHAR2
        );
-- CR41473 -- LRP2 -- sethiraj

PROCEDURE p_set_rewards_request ( io_objid                      IN OUT NUMBER,
                                  in_notification_id            IN VARCHAR2,
                                  in_notification_type          IN VARCHAR2,
                                  in_notification_date          IN DATE,
                                  in_source_name                IN VARCHAR2,
                                  in_web_user_objid             IN NUMBER,
                                  in_Benefit_Earning_Objid      IN NUMBER,
                                  in_event_name                 IN VARCHAR2,
                                  in_event_type                 IN VARCHAR2,
                                  in_event_date                 IN DATE,
                                  in_event_id                   IN VARCHAR2,
                                  in_event_status               IN VARCHAR2,
                                  in_description                IN VARCHAR2,
                                  in_amount                     IN NUMBER,
                                  in_denomination               IN VARCHAR2,
                                  in_request_received_date      IN DATE,
                                  in_ben_earn_transaction_type  IN VARCHAR2,
                                  out_err_code                  OUT NUMBER,
                                  out_err_msg                   OUT VARCHAR2
                               );

-- CR41473 -- Added for LRP2 -- sethiraj
PROCEDURE p_validate_reward_request ( io_reward_request IN OUT typ_reward_request_obj,
                                      out_err_code      OUT NUMBER,
                                      out_err_msg       OUT VARCHAR2
                                     );
-- CR41473 -- Added for LRP2 -- sethiraj
PROCEDURE p_process_reward_request(   IN_EVENT    IN OUT q_payload_t,
                                      out_err_code      OUT NUMBER,
                                      out_err_msg       OUT VARCHAR2
                                     );
/*
PROCEDURE p_process_reward_request( io_reward_request IN OUT typ_reward_request_tab,
                                    --in_event          IN OUT q_payload_t,
                                    out_err_code      OUT NUMBER,
                                    out_err_msg       OUT VARCHAR2
                                     );
*/
FUNCTION deduct_benefit_points(i_benefit_objid IN number,
                         i_transaction_status IN varchar2,
                         i_points_to_deduct   IN number
                         ) return varchar2;
--CR48643 Added new PROCEDURE to get service plan eligibility to be redeemed through LRP and points required
PROCEDURE check_serv_plan_lrp_elig ( i_service_plan_objid IN  NUMBER,
                                     o_lrp_details        OUT sys_refcursor,
                                     o_err_msg            OUT VARCHAR2,
                                     i_channel            IN VARCHAR2 DEFAULT 'APP' );
END rewards_mgt_util_pkg;
/