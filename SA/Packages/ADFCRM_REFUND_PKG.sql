CREATE OR REPLACE PACKAGE sa.ADFCRM_REFUND_PKG AS

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

procedure add_shipping_rec_to_orders(
    ip_order_id   in varchar2,
    ip_purch_id   in varchar2,
    ip_user_name  in varchar2,
    ip_source     in varchar2,
    ip_amount     in number,
    op_err_code out varchar2,
    op_err_msg out varchar2);

function remove_reward_points (ip_purch_objid in varchar2,
                               ip_esn varchar2,
                               ip_user_objid in varchar2) return boolean;

function get_b2b_order_dtl_rem_bal(ip_dtl_objid varchar2) return number;

type airtime_card_status_rec
IS
  record
  (
    RED_CODE        VARCHAR2(20),
    MASKED_RED_CODE VARCHAR2(20),
    SNP_ESN         VARCHAR2(30),
    PART_NUMBER     VARCHAR2(30),
    DESCRIPTION     VARCHAR2(255),
    RED_UNITS       NUMBER,
    ACCESS_DAYS     NUMBER,
    STATUS          VARCHAR2(20),
    STATUS_DESC     VARCHAR2(100));

type airtime_card_status_tab
IS
  TABLE OF airtime_card_status_rec;

FUNCTION fetch_airtime_card_info(
    in_hdrObjId VARCHAR2)
  RETURN airtime_card_status_tab pipelined;


FUNCTION is_Benefits_Removable(
    in_purchID         VARCHAR2,
    in_esn             VARCHAR2,
    in_brand           VARCHAR2,
    in_deviceType      VARCHAR2,
    in_transactionType VARCHAR2)
  RETURN VARCHAR2;

END ADFCRM_REFUND_PKG;
/