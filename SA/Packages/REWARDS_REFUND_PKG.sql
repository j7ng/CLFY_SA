CREATE OR REPLACE package sa.rewards_refund_pkg
is
PROCEDURE p_is_pin_refundable(
    in_esn                IN x_reward_program_enrollment.esn%TYPE,
    in_web_account_id     IN x_reward_program_enrollment.web_account_id%TYPE,
    in_service_plan_pin   IN x_reward_benefit_transaction.svc_plan_pin%TYPE,
    in_program_name       IN x_reward_benefit_program.program_name%TYPE,
    in_trans_type         IN x_reward_benefit_transaction.trans_type%TYPE,
    in_benefit_type_code  IN x_reward_benefit_program.benefit_type_code%TYPE,
    in_brand              IN x_reward_benefit_program.brand%TYPE,
    out_err_code          out NUMBER,
    out_err_msg           out VARCHAR2);


procedure pre_processing(
    ip_purch_id   in varchar2,
    ip_purch_type in varchar2,
    ip_user_name  in varchar2,
    ip_source     in varchar2,
    ip_reason     in varchar2,
    ip_amount     in number,
    op_refund_id out varchar2,
    op_err_code out varchar2,
    op_err_msg out varchar2);

procedure post_processing(
    ip_refund_id         in varchar2,
    ip_refund_type       in varchar2,
    ip_auth_request_id   in varchar2,
    ip_auth_code         in varchar2,
    ip_ics_rcode         in varchar2,
    ip_ics_rflag         in varchar2,
    ip_ics_rmsg          in varchar2,
    ip_request_id        in varchar2,
    ip_auth_avs          in varchar2,
    ip_auth_response     in varchar2,
    ip_auth_time         in varchar2,
    ip_auth_rcode        in varchar2,
    ip_auth_rflag        in varchar2,
    ip_auth_rmsg         in varchar2,
    ip_auth_cv_result    in varchar2,
    ip_score_factors     in varchar2,
    ip_scope_host_severity     in varchar2,
    ip_score_rcode       in varchar2,
    ip_score_rflag       in varchar2,
    ip_score_rmsg        in varchar2,
    ip_score_result      in varchar2,
    ip_score_time_local  in varchar2,
    ip_bill_request_time in varchar2,
    ip_bill_rcode        in varchar2,
    ip_bill_rflag        in varchar2,
    ip_bill_rmsg         in varchar2,
    ip_bill_trans_ref_no in varchar2,
    ip_auth_amount       in varchar2,
    ip_bill_amount       in varchar2,
    op_err_code          out varchar2,
    op_err_msg           out varchar2);

procedure add_item_to_refund (
      ip_hdr_objid in varchar2,
      ip_dtl_objid in varchar2,
      op_err_code  out varchar2,
      op_err_msg   out varchar2);

procedure remove_item_from_refund (
      ip_dtl_objid in varchar2,
      op_err_code  out varchar2,
      op_err_msg   out varchar2);

function remove_reward_points (ip_purch_objid in varchar2,
                               ip_esn varchar2,
                               ip_user_objid in varchar2) return boolean;
procedure p_refund_for_pin (
            in_esn               IN varchar2,
            in_svc_plan_pin      IN varchar2,
			In_Program_Name  	IN varchar2, -- 'LOYALTY_PROGRAM'
			In_Benefit_Type 	IN varchar2, --'LOYALTY_POINTS'
        out_err_code       OUT number,
         out_err_msg        OUT varchar2
                                                );
procedure p_refund_for_charge_back (
          in_cust_key        in varchar2, -- table_x_purch_hdr / x_biz_purch_hdr
          in_cust_value      IN number, -- objid of table_x_purch_hdr / X_Biz_Purch_Hdr
          in_brand           IN varchar2,
         in_program_name    IN varchar2 ,-- 'LOYALTY_PROGRAM'
         in_benefit_type    IN varchar2, --'LOYALTY_POINTS'
         in_partial_pymt_flag IN varchar2 DEFAULT 'N',
        in_partial_pymt_amount IN number, --- Only when partial flag = a??Ya??
         out_err_code       OUT number,
         out_err_msg        OUT varchar2);



end rewards_refund_pkg;
/